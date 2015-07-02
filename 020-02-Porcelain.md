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
