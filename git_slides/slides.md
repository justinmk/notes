========================================================


                        Git Grip


========================================================


                        Git Grip
            git insights and practical results


========================================================
# "CLI is too hard/obtuse/difficult"

How many know how to run the PSA Ant build?
(using Eclipse...)
How many know how to use basic features of Photoshop?
(How long did it take to learn?)

========================================================
# CLI

- common language for speaking about VCS tasks
    - compare GUI frontends: different buttons, different locations, different
      friendly-names
- CLIs are "backwards compatible UIs". GUIs are rarely back-compat
- CLIs make sharing knowledge possible and full-text searchable
- CLIs are scriptable

========================================================


> It is better to have 100 functions operate on one
> data structure than to have 10 functions operate on
> 10 data structures.
-                                      Alan J. Perlis
========================================================


> Rule of Representation: Fold knowledge into data so
> program logic can be stupid and robust.
>
> Even the simplest procedural logic is hard for
> humans to verify, but quite complex data structures
> are fairly easy to model and reason about.
-                  ESR, _The Art of Unix Programming_

http://www.faqs.org/docs/artu/
========================================================


> Rule 5: Data dominates. If you've chosen the right
> data structures and organized things well, the
> algorithms will almost always be self-evident. Data
> structures, not algorithms, are central to
> programming.
-                  Rob Pike, "5 Rules of Programming"

http://users.ece.utexas.edu/~adnan/pike.html
========================================================


> git actually has a simple design, with stable and
> reasonably well-documented data structures. In
> fact, I'm a huge proponent of designing your code
> around the data, rather than the other way around
-                                      Linus Torvalds

https://lwn.net/Articles/193245/
========================================================

Initial commit to "git":
https://github.com/git/git/tree/e83c5163316f89bfbde7d9ab23ca2e25604af290

> GIT - the stupid content tracker

* KISS
* Stop trying to be "smart". Don't solve
  application-level problems at inappropriately low
  levels. Instead, build something stable and
  reliable, so that it can be _built upon_.

========================================================
# Who cares?

Some thoughts:
- When was the last time you had to "upgrade" a git
  repository?
- Universal backwards compatibility is massively
  valuable: for archives, sharing, recovery, ...
- Objects can be thrown around into any repo for
  sharing. (More on this later...)

========================================================
# Who cares?

git is being used as the foundation for numerous
applications. (cf. bitcoin)

- git annex
- ...

You can't build on an unreliable foundation.
========================================================
## Staging Area, Index, Cache

All are synonyms. We use "index" in this presentation.
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
========================================================
stash:

working tree ("workspace"):

branch:
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
========================================================
## dat stash
You can treat stash (e.g. `stash@{0}` is
first/topmost stash) as a _merge commit_--because
`stash@{0}` / `refs/stash` is a merge commit and we
must tell git _which_ parent we want to reference.

* parent 1 of a stash always contains the HEAD commit at
  time of stash.
* parent 2 always contains the index at time of stash.
* parent 3 contains untracked files (`git stash -u`)
* [show gitk screenshot of the stash]

To checkout a stashed file:
    $ git checkout stash@{0} -- <filename>

Reference:
* http://stackoverflow.com/a/1105666/152142
* http://git-scm.com/docs/git-stash
========================================================
## dat stash

`git stash -u` creates a merge commit with 3 parents:

    $ git log stash@{0}

    commit 627dcde6933c8645373415a6769dfdcd5dc7f622
    Merge: 34c9c9c 1490b25 dbe8bec
           ^1      ^2      ^3

As always, the "current branch" at merge-time is the
first parent (^1). `git stash` always puts untracked
files in the third parent (^3). So you can see the
untracked files in a stash via:
    git show stash@{0}^3

========================================================
cat-file vs show
========================================================





#                   DAGummit










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


Git data organization / What's in a repo?
========================================================
Q: Why a DAG? Why not multiply-linked-list?
A: At least one answer: if a commit tracked its children,
   then it wouldn't be immutable.

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
========================================================
# Git data organization / What's in a repo?

* *DAG...*
* Config
* *Working copy...*
========================================================
# Git data organization / What's in a repo?

* *DAG...*
* *Config...*
* Working copy
    * Plain old files. Absolutely nothing git-related
      here. Contents are identical to the case where
      you aren't using git at all.
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

========================================================
# .git/ - Which files actually _matter_?

TODO: holy grail of repo layout:
    git help repository-layout











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

========================================================
# .git/ - your repository "database"

## Q
What happens if we `git init` and then dump in the
`.git/objects/` from an existing repo?

## A
    (_o.o)_









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


========================================================
# .git/ - your repository "database"

Q:  What happens if we corrupt (i.e., modify) the
    contents of `.git/objects/xx/...` file?
    Can we recover?
    Can we estimate the scope of damage?

A:  
    -(n_n`)


========================================================
# .git/ - your repository "database"

Q:  Where are refs stored?

A:  refs (branches, tags, etc.) are just names for ids.
A big repo can get a very large number of refs as a result
of automation, pull requests, etc. So they are stored in
various ways:

1. "loose" as files in .git/refs (e.g. ".git/refs/heads/main")
2. "packed" as entries in .git/packed_refs
3. "reftable" (future), a sorted binary file inspired by JGit
   https://eclipse.googlesource.com/jgit/jgit/+/refs/heads/master/Documentation/technical/reftable.md

https://github.blog/2022-01-24-highlights-from-git-2-35/


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










========================================================
# Reallyreallyreally useful "porcelain"

git log --oneline --graph --decorate
git log -5

git log -G
git log --grep
git grep
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
========================================================
# git-when-merged

Q: When was this commit merged?
   Or, What "merge bubble" is this commit a part of?

A: https://github.com/mhagger/git-when-merged

packfiles
========================================================
Compare "loose" (unpacked) objects which are found in[1]:
    .git/objects/[0-9a-f][0-9a-f]

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
structure."[2]

1: git help gitrepository-layout
2: http://keithp.com/blogs/Repository_Formats_Matter/
3: http://git-scm.com/book/en/v2/Git-Internals-Packfiles

packfiles
========================================================
http://githubengineering.com/counting-objects/
    > Once Git has the full list of objects it needs to send, it needs to
    > compress them into a single packfile (Git always sends packfiles over the
    > network). If the packfile on disk has a given object X stored as a delta
    > against an object Y, it could very well be the case that object X needs
    > to be sent, but object Y doesn't. In this case, object X needs to be
    > decompressed and delta'ed against an object that does need to be sent in
    > the resulting packfile.

========================================================
annotated micro-impl of git
    http://gitlet.maryrosecook.com/docs/gitlet.html

https://codewords.recurse.com/issues/three/unpacking-git-packfiles/
http://gitolite.com/gcs.html#(8)

video: https://speakerdeck.com/bkeepers/git-the-nosql-database

http://maryrosecook.com/blog/post/git-from-the-inside-out

http://wildlyinaccurate.com/a-hackers-guide-to-git/
https://rovaughn.github.io/2015-2-9.html

========================================================
* "Git from the Bottom Up" https://jwiegley.github.io/git-from-the-bottom-up/
* Jeanine Adkisson http://www.jneen.net
    * Emoticons & Presentation format:










XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

the basic data structure in git is the tree.[1]
Git doesn't store data as a series of changesets or differences. TREE.

commit object contains (basically a text file):
    pointer to a tree
    pointers to parent commit(s)
    commit message, author, date

After `git init`, add 3 files.
    `git commit` then checksums each subdirectory (in this case, just the root
    project directory) and stores those tree objects in the Git repository, then
    creates a commit object containing the metadata and a pointer to the root
    project tree.
    Your Git repository now contains five objects:
        1x3 blobs for the contents of each file
        1   tree that lists the directory and contents
        1   commit with the pointer to the root tree, plus the commit metadata
    IMAGE: https://git-scm.com/book/en/v2/book/03-git-branching/images/commit-and-tree.png
        -> It's hashes all the way down!
           hash of commit contents; hash of tree listing; hash of blob contents

each commit records the state of a tree ("snapshot").
this is space-efficient because most of the tree snapshots share content.
the contents are blobs and they are hashed by their contents. this makes it
trivial to know whether a blob can be shared between tree snapshots.
    -> persistent data structure / rich hickey "structural sharing" / immutable!
       a "deep copy" is simply a tree that points to the shared nodes + the new
       nodes.

AGAIN: each commit points to a TREE (not a diff; not a patch[2]).
    -> This means that `cherry-pick` works by _computing_ a diff between the
       commit and its parent; `rebase` is a series of `cherry-pick`; and
       `merge` is (HEAD + MERGE_HEAD - MERGE_BASE).

1. https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell
2. Note that _packfiles_ often store _objects_ as deltas after packing; but
   note a key difference from traditional CVS/SVN-likes: these are not file
   deltas, but deltas between any objects which the packer recognizes as
   contiguous.

   http://githubengineering.com/counting-objects/
       > When trying to minimize the size of a packfile, however, Git mostly
       > disregards history and considers blobs in isolation. To find a delta
       > base for a given blob, Git blindly scans for blobs that look similar
       > to it. Sometimes it will choose the previous version of the same file,
       > but very often it's a blob from an unrelated part of the history.

===
A typical 2-parent merge is called a "3-way merge" because it uses 3 patches[1]:
    two branch tips + common ancestor
                      ^- implication: history before the
                         common ancestor is ignored.

So what is a merge? It is two trees mushed together.
    https://github.com/git/git/blob/master/Documentation/technical/trivial-merge.txt#L77-L94
    Result: Once the merge is _committed_, its "history" doesn't matter.
    Demo:
        git merge --no-commit foo
        git rm --cached bar.txt
        git commit -m "Merged without bar.txt"
    Look at the graph: bar.txt was added in ^2, but does not exist in HEAD. If
    you merge foo again later, there won't be a conflict _unless_ foo has made
    changes to foo.txt since the previous merge.
    Why?
    Because the patch computed from MERGE_BASE..MERGE_HEAD will not include the
    contents of foo.txt unless foo.txt was changed.

    `git show` on a merge-commit shows no changes. Why: by default (without -m)
    it only shows changes _introduced_ by the merge commit itself.
        http://haacked.com/archive/2014/02/21/reviewing-merge-commits/

    ^1, ^2
        The incoming branch (MERGE_HEAD) is always "parent 2". So if you are
        looking at a merge commit in GitHub or GitLab, click the 2nd parent to
        see the changes from a codereview (pull request).

    Recording the merge base (common ancestor) was a key insight of git,
    missing from SVN before 1.5: http://stackoverflow.com/a/612747/152142
        > The important part of a merge is not how it handles conflicts ... but
        > that it should meld the history together right so that you have a new
        > solid base for future merges.
        > In other words, the important part is the trivial part: the naming of the
        > parents, and keeping track of their relationship. Not the clashes.

        > The only thing you need to store is the state of the _tree_ before and
        > after each change.
        > "What files were renamed? Which ones were copied? Which ones were
        > deleted? What lines were added? Which ones were removed? Which lines had
        > changes made inside them? Which slabs of text were copied from one file
        > to another?" You shouldn't have to care about any of these questions and
        > you certainly shouldn't have to keep special tracking data in order to
        > help you answer them: all the changes to the tree (additions, deletes,
        > renames, edits etc) are implicitly encoded in the delta between the two
        > states of the tree; you just track what is the _content_.

So what do you think a "squash" is?

What could a 3-parent (or N-parent...) merge possibly mean?
    since we know that a merge is just a two trees mashed together, it's easy to
    imagine any number of trees mashed together. The resulting commit will list
    N commits as its parents.

Notice that a rebase is a "2-way merge" (AKA: a "patch" ;) over and over--
merging 2 trees (instead of 3) for each commit in the series. A patch (2-way
merge) assumes linear history, whereas a 3-way merge implies divergent history
(branches).

Now that we understand a merge, the idea of a "merge commit" becomes obvious,
and it becomes obvious why the commits in the merged branch may appear "long
ago" in the history graph:
    - those commits were never actually applied to the target branch. Only the
      _merge commit_ exists on the target branch. 
    - the graph shows the commit ancestry; commit-date is irrelevant.

1. https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging

===
How could a branch fail to rebase onto itself?
    A: because changes are computed based by comparing trees, and rebase by
       default "flattens" merges. Use `rebase --preserve-merges` instead.
       http://stackoverflow.com/a/32811891/152142

Note also that rebase tries to skip "very similar" commits (have the same
patch-id) http://git-scm.com/docs/git-patch-id

===
* branch is a ref (pointer) that conveniently moves when you commit.
* HEAD is a ref that notes the current commit.
* tags are also refs (pointers) (with metadata), but they never move.
* "detached HEAD" just means `cat .git/HEAD` lists a raw SHA instead of a branch.
    detached HEAD:
        $ cat .git/HEAD
        6c8e8f90d73d2af8a652f84337fd744ba6d76990
    attached HEAD:
        $ cat .git/HEAD
        ref: refs/heads/trunk


===
Explain each of these lines:
    $ git pull --rebase
    remote: Counting objects: 7, done.                                  # stdin on the remote is forwarded client-side with "remote:" prefix.
    remote: Compressing objects: 100% (4/4), done.
    remote: Total 7 (delta 4), reused 6 (delta 3), pack-reused 0
    Unpacking objects: 100% (7/7), done.
    From https://github.com/justinmk/notes
       33fd48a..941b503  master     -> origin/master
    First, rewinding head to replay your work on top of it...
    Fast-forwarded master to 941b5035cc0b821b2ca1b3066f367506a103decf.

    $ git fetch --all
    Fetching upstream
    remote: Counting objects: 862, done.
    remote: Compressing objects: 100% (649/649), done.
    remote: Total 862 (delta 500), reused 169 (delta 169), pack-reused 44
    Receiving objects: 100% (862/862), 464.12 KiB | 0 bytes/s, done.
    Resolving deltas: 100% (510/510), completed with 49 local objects.
    From https://github.com/neovim/neovim
       641c642..622ec95  master     -> upstream/master
     + 7e16dfc...7d292d0 refs/pull/2506/head -> refs/pull/upstream/2506  (forced update)
     + 59597f0...c413671 refs/pull/3042/head -> refs/pull/upstream/3042  (forced update)
     * [new ref]         refs/pull/3395/head -> refs/pull/upstream/3395
     * [new ref]         refs/pull/3398/head -> refs/pull/upstream/3398
    Fetching justinmk
    Fetching zyx
    From https://github.com/ZyX-I/neovim
       641c642..43dacff  master     -> zyx/master
     + 7e16dfc...7d292d0 shada      -> zyx/shada  (forced update)

