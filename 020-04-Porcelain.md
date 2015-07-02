# git log --grep

### Search log messages (OR semantics)
    git log --grep=foo --grep=bar --since=1.month

### Search log messages (OR semantics)
    git log --grep=frotz --author=Linus

`git log --grep` is _not_ line-oriented (it wouldn't
make sense). Use `--all-match` to achieve AND
semantics:

    git log --all-match --grep=frotz --author=Linus

http://gitster.livejournal.com/30195.html
