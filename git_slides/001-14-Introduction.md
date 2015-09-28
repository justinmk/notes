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
