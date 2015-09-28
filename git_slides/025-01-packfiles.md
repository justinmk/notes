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
