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
