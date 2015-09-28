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
