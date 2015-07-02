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

