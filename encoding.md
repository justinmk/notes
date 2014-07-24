It's never too late to write an encoding post, or even a Unicode post, because
encoding is a probably-timeless problem, and UTF will be around for a long time.
UTF familiarity may actually become *more obscure* as Unicode takes over the world
and polyfills every crevice of the "Internet of Things"; things will break less often and 
when these problems do crop up they will be even more confounding and annoying.
Or maybe knowledge of UTF will become twee/sublime pastime studied by hipsters
and bonsai gardeners.

What's really important is that I just debugged a mysterious problem caused by 
string-encoding mismatch. So in the words of Jack Black, [now this is happening.](https://www.youtube.com/watch?v=cDfQo1ANeLM#t=58)

User is assigned password via a UTF16[1] .NET/winform application.
Password is sent to ASP.NET webserver which encrypts Unicode using supersecret algorithm.
By the way, the Encrypt() method's first order of business is to convert the string input to Windows codepage 1252:
  byte[] bytes = Encoding.GetEncoding(1252).GetBytes(plaintext);
Encrypt() makes love to the input and returns it as a .NET (UTF16) string.
So we now have a UTF16 string that contains only characters within the cp1252 codepage.
This is then stored in SQL Server in a varchar field (cp1252, because default collation was not modified).
When the user logs in, the user's `dbo.Member` record, which contains various fields (including varchar and nvarchar)
is retrieved from the database by ADO.NET which fills a .NET `Member` object. The string fields of the 
.NET object are all encoded as UTF16, even the strings stored in the database as varchar (cp1252) fields.
The .NET `Member` object is serialized to a JSON-formatted string. That .NET (UTF16) string
is then (needlessly) converted to a byte array string using the system default encoding
(cp1252), for storage in a cache service.
When the cached `Member` object is retrieved later, it is converted from a byte array to .NET string using a UTF8 decoder.
That JSON-formatted .NET (UTF16) string is then deserialized back to a .NET object.

System works fine for most users, but a few users cannot log in. Why?

If you are comfortable with encodings, you probably noticed that the 
major bug is in the last step. In the horrendous mess above, rife with accidental
comical Rube Goldberg twistings and untwistings, the first time a problem
is encountered is when the string is transformed to context-less bytes, which
are later unpacked with a false context (ie the wrong encoding).

> garbage in, identical garbage out: Any "encoding roundtrip" must begin and end with the same encoding

Password field contains cp1252 characters, the cached `Member` JSON string is
encoded with cp1252 and deserialized as UTF8. That's a glaring problem, but
why did it work sometimes?

UTF8 is a superset of [ISO-8859-1][iso8859]. Encoding/decoding to/from cp1252/iso8859
works as long as the string does not contain characters corresponding to the 
codepoint range 128 to 159 (hex 80 to 9F). In "ASCII" ISO-8859-1 this range 
contains [C1 control characters][controlchars]. In Windows-1252 the same range 
[contains][cp1252] some unusual but printable characters like ƒ (F with a hook) and † (dagger)
and ‡ (double dagger!).

But ASCII <=> cp1252 works fine as long as you don't use these characters.
But the Member password field is a string of random cp1252 characters: it very 
well may contain the text `‡vˆ`, which is encoded in cp1252 and utf8 as
the following byte sequences:

```
   cp1252     utf8
   ===============
   ‡vˆ        ‡vˆ
   ^^^        ^^^
   |||        |||
   ||88       ||CB86
   |76        |76
   87         E280A1
```

(In Vim, try this: `:set encoding=cp1252` then in insert-mode, `<C-V>x87`.
This should emit ‡. If you then `:set encoding=utf8`, then character displays
as the literal byte sequence `<87>` because this codepoint is defined in iso8859
(and utf8) as an unprintable C1 control character. Vim doesn't provide a way
to enter the literal utf8 byte sequence `E280A1`, although you can enter the
Unicode codepoint `2021`)

None of this matters if you stick to one of the following:

- work with characters, not bytes: let the system do the dirty work, don't mainpulate bytes
- if you must work with bytes, do not modify them

After [migrating Plan 9 to Unicode][plan9], Pike and Thompson concluded:

> the actual encoding is relatively unimportant to the software; the adoption
> of large characters and a byte-stream encoding[2] *per se* are much deeper issues.

In other words, once a [system][system][3] no longer _inspects or manipulates_ strings under the assumption that each character 
in the string is a byte, then the internal representation is academic: because
`Replace()`, `Substring()`, `IndexOf()`, etc., are now *characterwise* operations.
If the system receives a byte stream that must be treated as a string (say,
from a pipe in the shell), the stream encoding is sent to the system (that is,
the program running in the shell) and the byte stream must be converted to
the system's internal rerpesentation. In practice a C# programmer may not often
deal with an incoming stream because `Console.In.ReadLine()` provides `stdin` as a .NET string:

```
  static void Main(string[] args) {
      string input = Console.In.ReadLine();
      Console.WriteLine(BitConverter.ToString(Console.InputEncoding.GetBytes(input)));
      Console.WriteLine(input);
  }
```

run the above program and it shows this output:

```
  echo ‡vˆ | smurf.exe
  D8-76-5E-20
  ╪v^
```

Notice that although the cmd.exe terminal displays the pasted cp1252 characters
(‡vˆ / 87-76-88), those bytes are not sent to stdin of `smurf.exe`. Instead,
because `Console.InputEncoding` is IBM437, `ReadLine()` returns IBM437-encoded
string (╪v^ / D8-76-5E). Good times.

But you can read the incoming bytes like this:

```c
  using (Stream stdin = Console.OpenStandardInput())
  using (Stream stdout = Console.OpenStandardOutput()) {
      byte[] buffer = new byte[8];
      int bytes;
      string byteString = "";
      while ((bytes = stdin.Read(buffer, 0, buffer.Length)) > 0) {
          byteString += BitConverter.ToString(buffer);
          stdout.Write(buffer, 0, bytes);
      }
      Console.WriteLine(byteString);
  }
```

run the above program like this:

```
  $ echo ‡vˆ | smurf.exe
  D8-76-5E-20-0D-0A-00-00
  ╪v^
```

This is why Linus maintains that the kernel path parser does not care about anything
except the '/' character, and regard everything else as a blackbox of uninterpreted bytes.

In the diagram above, 'v' character is encoded as 76 in both cp1252 and utf8.
Any byte lower than 128 is converted without loss between cp1252 and utf8.
The `Member` objects in the system, when serialized, were usually within this range.
But the encrypted password field strings occasionally contained characters whose
that correspond to the cp1252 range 128-159 (0x80-0x9F). These bytes were stored
and later retrieved and then *decoded* per utf8. That byte modification is where
things go wrong.

Strings may be regarded as naked byte streams as long as they aren't manipulated.

> Most applications can do very fine with just soft conversion. This is what makes the introduction of UTF-8 on Unix feasible at all. To name two trivial examples, programs such as cat and echo do not have to be modified at all. They can remain completely ignorant as to whether their input and output is ISO 8859-2 or UTF-8, because they handle just byte streams without processing them.
> They only recognize ASCII characters and control codes such as '\n' which do not change in any way under UTF-8.

In Linux, you can save a filepath consisting of random bytes, and those bytes
won't be changes by the kernel at all. You can send and save a string's bytes 
as much as you like. But as soon as you want to inspect or modify the *byte* sequence
as a *character* sequence, you must decode it using the precise encoding with which it was created.

Decoding a byte array using the wrong rules (ie the wrong encoding) is lossy.
A byte array may contain byte sequences that have no defined codepoint for an encoding to map to.

For example:

```
  byte[] randomBytes = new byte[16];
  new Random().NextBytes(randomBytes);

  string utf16str = Encoding.Unicode.GetString(randomBytes);
  var utf16bytes_areEqualTo_originalBytes = randomBytes.SequenceEqual(Encoding.Unicode.GetBytes(utf16str));
  BitConverter.ToString(randomBytes)
  // => "CE-CA-C3-B3-EB-DE-50-4B-3E-7B-3D-D1-36-EB-90-3A"
```

In the code above, `utf16bytes_areEqualTo_originalBytes` is likely to be false
because some of the random bytes may have been munged by `Encoding.Unicode.GetString(randomBytes)`
because they did not translate to a valid UTF16 byte sequence. So now we have this
string:

```
  BitConverter.ToString(Encoding.Unicode.GetBytes(utf16str))
  // => "CE-CA-C3-B3-FD-FF-50-4B-3E-7B-3D-D1-36-EB-90-3A"
  //                 ^^^^^
```

Notice the munged bytes, underlined with `^^^^^`.
Even more data loss occurs if we then translate the UTF16 string to a cp1252 string:

```cs
  var cp1252bytes = Encoding.GetEncoding(1252).GetBytes(utf16str);
  string cp1252str = Encoding.GetEncoding(1252).GetString(cp1252bytes);
  utf16str  // => "쫎돃�䭐笾턽㪐"
  cp1252str // => "????????"
  BitConverter.ToString(cp1252bytes) // => "3F-3F-3F-3F-3F-3F-3F-3F"
```

In this case the conversion found no characters in the source string that had
depage, so byte sequence `3F` is used in their place.

[A very good introduction][kunststube]



[1] "Windows Unicode" ie UTF-16LE
[2] "byte encoding" as opposed to the "16-bit quantities" insisted on by the original
    Unicode Standard which reserved 0xFFFE and 0xFEFF to detect byte order
    in transmission: a "byte encoding" is byte-order independent so it does not
    require such state indicators. (It's also backwards-compatible with US-ASCII.)

    see also: http://programmers.stackexchange.com/a/95452/45819
    > When processing UTF-16, you read a 16-bit value, doing whatever endian
    > conversion is needed. Then, you detect if it is a surrogate pair; if it is,
    > then you read another 16-bit value, combine the two, and from that, you get
    > the Unicode codepoint value.
    >
    > When processing UTF-8, you read an 8-bit value. No endian conversion is
    > possible, since there is only one byte. If the first byte denotes a
    > multi-byte sequence, then you read some number of bytes, as dictated by
    > the multi-byte sequence. Each individual byte is a byte and therefore has
    > no endian conversion. The order of these bytes in the sequence, just as
    > the order of surrogate pairs in UTF-16, is defined by UTF-8.
    >
    > So there can be no endian issues with UTF-8.

[3] such as C# which represents Unicode strings internally as UTF16 byte sequences
[4] cmd.exe happens to use IBM437 codepage, the
    [same codepage as MSDOS](http://en.wikipedia.org/wiki/Code_page_437). FFS, people!
[?] http://doc.cat-v.org/bell_labs/utf-8_history
  important design feature of UTF8 added by Ken Thompson is "self-synchronization":
  > the ability to synchronize a byte stream picked up mid-run, with less that one
  > character being consumed before synchronization

[iso8859]: http://en.wikipedia.org/wiki/ISO/IEC_8859-1
[controlchars]: http://en.wikipedia.org/wiki/C0_and_C1_control_character#C1_set
[cp1252]: http://www.i18nqa.com/debug/table-iso8859-1-vs-windows-1252.html
[kunststube]: http://kunststube.net/encoding/
[unicodefaq]: http://www.cl.cam.ac.uk/~mgk25/unicode.html#mod
[plan9]: http://plan9.bell-labs.com/sys/doc/utf.pdf
[system]: http://commons.wikimedia.org/wiki/File%3ASystem_boundary.svg
