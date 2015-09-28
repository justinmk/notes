C:\Users\jkeyes\Desktop\git_slides\000-00-Git_Talk.md
========================================================


                        Git Grip


C:\Users\jkeyes\Desktop\git_slides\000-01-Git_Talk.md
========================================================


                        Git Grip
            git insights and practical results


C:\Users\jkeyes\Desktop\git_slides\000-02-Git_Talk.md
========================================================

# "CLI is too hard/obtuse/difficult"

How many know how to run the PSA Ant build?
(using Eclipse...)
How many know how to use basic features of Photoshop?
(How long did it take to learn?)

C:\Users\jkeyes\Desktop\git_slides\001-01-Git_Insights.md
========================================================


> It is better to have 100 functions operate on one
> data structure than to have 10 functions operate on
> 10 data structures.
-                                      Alan J. Perlis
C:\Users\jkeyes\Desktop\git_slides\001-02-Git_Insights.md
========================================================


> Rule of Representation: Fold knowledge into data so
> program logic can be stupid and robust.
>
> Even the simplest procedural logic is hard for
> humans to verify, but quite complex data structures
> are fairly easy to model and reason about.
-                  ESR, _The Art of Unix Programming_

http://www.faqs.org/docs/artu/
C:\Users\jkeyes\Desktop\git_slides\001-03-Git_Insights.md
========================================================


> Rule 5: Data dominates. If you've chosen the right
> data structures and organized things well, the
> algorithms will almost always be self-evident. Data
> structures, not algorithms, are central to
> programming.
-                  Rob Pike, "5 Rules of Programming"

http://users.ece.utexas.edu/~adnan/pike.html
C:\Users\jkeyes\Desktop\git_slides\001-04-Git_Insights.md
========================================================


> git actually has a simple design, with stable and
> reasonably well-documented data structures. In
> fact, I'm a huge proponent of designing your code
> around the data, rather than the other way around
-                                      Linus Torvalds

https://lwn.net/Articles/193245/
C:\Users\jkeyes\Desktop\git_slides\001-05-Git_Insights.md
========================================================

Initial commit to "git":
https://github.com/git/git/tree/e83c5163316f89bfbde7d9ab23ca2e25604af290

> GIT - the stupid content tracker

* KISS
* Stop trying to be "smart". Don't solve
  application-level problems at inappropriately low
  levels. Instead, build something stable and
  reliable, so that it can be _built upon_.

C:\Users\jkeyes\Desktop\git_slides\001-06-Git_Insights.md
========================================================
# Who cares?

Some thoughts:
- When was the last time you had to "upgrade" a git
  repository?
- Universal backwards compatibility is massively
  valuable: for archives, sharing, recovery, ...
- Objects can be thrown around into any repo for
  sharing. (More on this later...)

C:\Users\jkeyes\Desktop\git_slides\001-07.1-Git_Insights.md
========================================================
# Who cares?

Some thoughts:
- When was the last time you had to "upgrade" a git
  repository?
- Universal backwards compatibility is massively
  valuable: for archives, sharing, recovery, ...
- Objects can be thrown around into any repo for
  sharing. (More on this later...)
C:\Users\jkeyes\Desktop\git_slides\001-09.1-Git_Insights.md
========================================================
# Who cares?

git is being used as the foundation for numerous
applications. (cf. bitcoin)

- git annex
- ...

You can't build on an unreliable foundation.
C:\Users\jkeyes\Desktop\git_slides\001-13-Introduction.md
========================================================
## Staging Area, Index, Cache

All are synonyms. We use "index" in this presentation.
C:\Users\jkeyes\Desktop\git_slides\001-14-Introduction.md
========================================================
fetch: updates the local "database"
(pull: not very interesting. uses fetch underneath)

## Protocols
Local: /path/to/repo/ or file://path/to/repo
SSH: ssh://... no daemon (except SSH) required. Spins
     up remote `git` processes over SSH! This is
     basically equivalent to "local"--we're just
     using basic SSH operations. No git-specific
     services required.

Smart HTTP: requires a daemon
Dumb HTTP:  requires a server-side post-update hook
git:        requires a daemon

https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols
C:\Users\jkeyes\Desktop\git_slides\001-15-Introduction.md
========================================================
rebase: what is actually happening?

merge: what is actually happening?
    Q: What happens when you merge A to B, but undo a change from A _within_ the merge commit?
       How does git know you undid the change, if there isn't a "revert" commit in between?
    A: (tentative--need to verify) Because the merge-commit has A and B as parents,
       the change in question is never analyzed again by git.

how to resolve a conflict?
    1. open the file and remove these markers:
       <<<<<<<, =======, >>>>>>>
    2. `git add` the file.
C:\Users\jkeyes\Desktop\git_slides\001-16-Introduction.md
========================================================
stash:

working tree ("workspace"):

branch:
C:\Users\jkeyes\Desktop\git_slides\002-00-SVN_(Berkeley DB; fsfs)_data_model.md
========================================================
"The FSFS backend places one file per revision in a single
directory; a test import of Mozilla generated hundreds of
thousands of files in this directory, causing performance to
plummet as more revisions were imported. ... Lack of strong error
detection means such errors will be undetected by the repository.
... The Mozilla CVS repository was 2.7GB, imported to Subversion
it grew to 8.2GB. Under Git, it shrunk to 450MB."

    ConnectWise SVN size (Jan 2015):    4.7 GB
    ConnectWise git size (July 2015):   2.3 GB

http://keithp.com/blogs/Repository_Formats_Matter/ (2007)
C:\Users\jkeyes\Desktop\git_slides\002-01-Mercurial_data_model.md
========================================================
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
C:\Users\jkeyes\Desktop\git_slides\005-00-Stash.md
========================================================
## dat stash
You can treat stash (e.g. `stash@{0}` is
first/topmost stash) as a _merge commit_--because
`stash@{0}` / `refs/stash` is a merge commit and we
must tell git _which_ parent we want to reference.

* First parent of a stash always contains the HEAD
  commit at time of stash.
* Second parent always contains the index at time of
  stash.
* [show gitk screenshot of the stash]

To checkout a stashed file:
    $ git checkout stash@{0} -- <filename>

Reference:
* http://stackoverflow.com/a/1105666/152142 
* http://git-scm.com/docs/git-stash 
C:\Users\jkeyes\Desktop\git_slides\005-01-Stash.md
========================================================
## dat stash

C:\Users\jkeyes\Desktop\git_slides\006-01-cat-file_vs_show.md
========================================================
cat-file vs show
C:\Users\jkeyes\Desktop\git_slides\007-01-DAG.md
========================================================





#                   DAGummit










C:\Users\jkeyes\Desktop\git_slides\007-02-DAG.md
========================================================
# Git data organization / What's in a repo?

* DAG (.git/objects): data/contents
    * files never change, only added/removed
    * perfect use-case for hardlinks (local clone)
    * identical contents for all repo clones
* Config: Mnemonics! References to the DAG.
    * mutable files
    * per-user/clone
* Working copy: your playpen/sandbox/mess
    * files frequently change
    * totally irrelevant until `git add`

^^ Three kinds of repository stuff. ^^
   Only DAG matters. ("content addressable")
C:\Users\jkeyes\Desktop\git_slides\007-03-DAG.md
========================================================
# Git data organization / What's in a repo?

* DAG
    * blobs: data files
    * trees: hierarchy records. They specify the
      structure of the blobs and how they connect to
      each other (like a database)
    * commits: snapshots of the _arrangement_ of the
      blobs on the trees
    * Some files (tags) hold metadata about the blobs
* *Config...*
* *Working copy...*
C:\Users\jkeyes\Desktop\git_slides\007-04-DAG.md
========================================================
# Git data organization / What's in a repo?

* *DAG...*
* Config
* *Working copy...*
C:\Users\jkeyes\Desktop\git_slides\007-05-DAG.md
========================================================
# Git data organization / What's in a repo?

* *DAG...*
* *Config...*
* Working copy
    * Plain old files. Absolutely nothing git-related
      here. Contents are identical to the case where
      you aren't using git at all.
C:\Users\jkeyes\Desktop\git_slides\008-00-.git.md
========================================================
# .git/ - Which files actually _matter_?

    ├── branches          ├── objects
    ├── COMMIT_EDITMSG    │   ├── 03
    ├── config            │   │   └── 82817325a4c33e01c0afc215003cae4222ed1e
    ├── HEAD              ... ...
    ├── hooks             │   ├── 76
    │   └── ...           │   │   ├── 7dc54213a5daaedf9863ccc3debbc6a94e4a7b
    ├── index             │   │   └── f3da338148c77946a2ee948569ff8b3314de47
    ├── info              │   ├── info
    │   └── exclude       │   └── pack
    ├── logs              └── refs
    │   ├── HEAD              ├── heads
    │   └── refs              │   └── master
    │       └── remotes       ├── remotes
                              │   └── origin
                              │       └── master
                              └── tags














C:\Users\jkeyes\Desktop\git_slides\008-01-.git.md
========================================================
# .git/ - your repository "database"

Q:  What is the difference between your local clone
and the remote repo?

A:  Nothing. (Except a little flag in .git/config
that changes git's behavior in the bare repo)

demo: copy .git/ folder from cwsrc2 to local








scp -r jkeyes@cwsrc2:/var/opt/gitlab/git-data/repositories/tools/git_scripts.git .
git config --local --bool core.bare false
[remote "origin"]
    url = git@cwsrc2:tools/git_scripts.git
    fetch = +refs/heads/*:refs/remotes/origin/*

C:\Users\jkeyes\Desktop\git_slides\008-02-.git.md
========================================================
# .git/ - your repository "database"

Q:  What is the difference between a "remote remote"
and a "local remote"?

A:  Nothing, from a UI perspective. But the transport
protocol and the storage strategy (hardlinks) may
differ (unless URL has file:// prefix). (See "Local
Protocol" in the git book[1])

!! During a rebase, even your own workspace may be 
considered a remote!

1:  http://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols#Local-Protocol

demo: clone ~/postman and treat it like a remote


```sh
git clone postman/ zub
cat zub/.git/config
ls zub

ls -1 -i LICENSE
    672772 LICENSE
ls -1 -i ../postman/LICENSE     # Not the same inode!
    799196 ../postman/LICENSE
                                # Same inode!
ls -1 -i .git/objects/da/16c1c6e828c760e71afa6c4e190d5c0593cab8
    806518 .git/objects/da/16c1c6e828c760e71afa6c4e190d5c0593cab8
ls -1 -i ../postman/.git/objects/da/16c1c6e828c760e71afa6c4e190d5c0593cab8
    806518 ../postman/.git/objects/da/16c1c6e828c760e71afa6c4e190d5c0593cab8
find ~ -inum 806518
```
C:\Users\jkeyes\Desktop\git_slides\008-03-.git.md
========================================================
# .git/ - your repository "database"

Q:  What is the difference between your repo, and
another _totally unrelated_ repo?

A:  Nothing... except the actual contents :3
    -(n_n`)

Try this:
  foo/.git/objects (sans `info/packs`) => bar/.git/objects
  # Then concatenate the `info/packs` file (if any):
  cat foo/.git/objects/info/packs >> bar/.git/objects/info/packs

Note: We didn't copy .git/refs/ so `git gc` may
destroy the copied-over objects if we don't save them
with new refs (or migrate the original ones).







scp -r jkeyes@cwsrc2:/var/opt/gitlab/git-data/repositories/tools/git_scripts.git .
git config --local --bool core.bare false
[remote "origin"]
    url = git@cwsrc2:tools/git_scripts.git
    fetch = +refs/heads/*:refs/remotes/origin/*

C:\Users\jkeyes\Desktop\git_slides\008-04-.git.md
========================================================
# .git/ - your repository "database"

## Q
What happens if we `git init` and then dump in the
`.git/objects/` from an existing repo?

## A
    (_o.o)_









C:\Users\jkeyes\Desktop\git_slides\008-05-.git.md
========================================================
# .git/ - your repository "database"

Q:  Can we create an identical commit in two
different repos?

A:  Yes.

```sh
GIT_COMMITTER_DATE='Wed Jul 1 17:00:00 2015 -0400'\
git commit --amend --date='Wed Jul 1 17:00:00 2015 -0400'
```


    v( u_u)v  (7o_o)>










C:\Users\jkeyes\Desktop\git_slides\008-06-.git.md
========================================================
# .git/ - your repository "database"

Q:  What happens if we corrupt (i.e., modify) the
    contents of `.git/objects/xx/...` file?
    Can we recover?
    Can we estimate the scope of damage?

A:  
    -(n_n`)










C:\Users\jkeyes\Desktop\git_slides\008-10-.git.md
========================================================
# .git/logs (reflog)

### What's in .git/logs?
    cat .git/logs/refs/heads/master | tail -5
    cat .git/logs/HEAD | tail -5
    git reflog | head -5

### What happens if we delete .git/logs/ ?
    rm -rf .git/logs/
    git reflog
A:  
    -(n_n`)










C:\Users\jkeyes\Desktop\git_slides\020-01-Porcelain.md
========================================================
# Reallyreallyreally useful "porcelain"

git log --oneline --graph --decorate
git log -5

git log -G
git log --grep
git grep
C:\Users\jkeyes\Desktop\git_slides\020-02-Porcelain.md
========================================================
# git grep

    $ time git grep IDatabase | wc -l
        7426

        real    0m1.258s
        user    0m0.015s
        sys     0m0.031s

    $ time grep -r IDatabase * | wc -l
        9297

        real    1m19.057s
        user    0m12.698s
        sys     0m34.755s
C:\Users\jkeyes\Desktop\git_slides\020-03-Porcelain.md
========================================================
# git grep

### Search only csharp files
    git grep -nE 'IList<[sS]tring>' -- '*.cs'

### Search beta branch at a specific commit (HEAD)
    git grep -nE 'IList<[sS]tring>' beta HEAD -- '*.cs'

### --and --not (extremely powerful!)
    git grep -nE -e 'IList<[sS]tring>' \
      --and --not -e GetErrors beta HEAD -- '*.cs'

`git grep` is _line-oriented_ by default. Use
`--all-match` for _file-oriented_ conditions:

    git grep -l -nE --all-match -e IList -e IDatabase

Try that in VS or Windows...

C:\Users\jkeyes\Desktop\git_slides\020-04-Porcelain.md
========================================================
# git log --grep

### Search log messages (OR semantics)
    git log --grep=foo --grep=bar --since=1.month

### Search log messages (OR semantics)
    git log --grep=frotz --author=Linus

`git log --grep` is _not_ line-oriented (it wouldn't
make sense). Use `--all-match` to achieve AND
semantics:

    git log --all-match --grep=frotz --author=Linus

### Git 2.5 added --invert-grep
    git log --grep='^patch' --invert-grep e271909..HEAD

http://gitster.livejournal.com/30195.html
C:\Users\jkeyes\Desktop\git_slides\023-01-Contrib.md
========================================================
# git-when-merged

Q: When was this commit merged?
   Or, What "merge bubble" is this commit a part of?

A: https://github.com/mhagger/git-when-merged

C:\Users\jkeyes\Desktop\git_slides\025-01-packfiles.md
========================================================
"Compression is done off-line and can be delayed
until after the primary objects are saved to backup
media. This method provides better compression than
any incremental approach, allowing data to be
re-ordered on disk to match usage patterns. … From
measurements made on a wide variety of repositories,
git's compression techniques are far and away the
most successful in reducing the total size of the
repository. The reduced size benefits both download
times and overall repository performance as fewer
pages must be mapped to operate on objects within
a Git repository than within any other repository
structure."[1]

1: http://keithp.com/blogs/Repository_Formats_Matter/
2: http://git-scm.com/book/en/v2/Git-Internals-Packfiles
C:\Users\jkeyes\Desktop\git_slides\199-01-Reference.md
========================================================
annotated micro-impl of git
    http://gitlet.maryrosecook.com/docs/gitlet.html

http://gitolite.com/gcs.html#(8)

video: https://speakerdeck.com/bkeepers/git-the-nosql-database 

http://maryrosecook.com/blog/post/git-from-the-inside-out 

http://wildlyinaccurate.com/a-hackers-guide-to-git/
http://git-scm.com/book/en/v2/Git-Internals-Git-Objects
http://git-scm.com/book/en/v2/Git-Tools-Revision-Selection
https://rovaughn.github.io/2015-2-9.html

C:\Users\jkeyes\Desktop\git_slides\199-02-Credits.md
========================================================
* "Git from the Bottom Up" https://jwiegley.github.io/git-from-the-bottom-up/
* Jeanine Adkisson http://www.jneen.net
    * Emoticons & Presentation format: