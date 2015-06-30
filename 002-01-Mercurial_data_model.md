"Mercurial uses a _truncated forward delta scheme where
file revisions are appended to the repository file, as a string of
deltas with occasional complete copies of the file_ (to provide
a time bound on operations). This suffers from two possible
problems--the first is fairly obvious where corrupted writes of
new revisions can affect old revisions of the file. The second is
more subtle--system failure during commit will leave the file
contents half written. Mercurial has recovery techniques to detect
this, but they involve truncating existing files, a piece of the
Linux kernel which has constantly suffered from race conditions
and other adventures."

http://keithp.com/blogs/Repository_Formats_Matter/ (2007)
