#! /bin/sh
# $Id$
#
# Test suite for xmalloc and friends.

# The count starts at 1 and is updated each time ok is printed.  printcount
# takes "ok" or "not ok".
count=1
printcount () {
    echo "$1 $count"
    count=`expr $count + 1`
}

# Run a program expected to succeed, and print ok if it does.
runsuccess () {
    output=`t/xmalloc "$1" "$2" 2>&1 >/dev/null`
    if test $? = 0 && test -z "$output" ; then
        printcount "ok"
    else
        printcount "not ok"
        echo "  $output"
    fi
}

# Run a program expected to fail and make sure it fails with an exit status
# of 2 and the right failure message.  Strip the colon and everything after
# it off the error message since it's system-specific.
runfailure () {
    output=`t/xmalloc "$1" "$2" 2>&1 >/dev/null`
    status=$?
    output=`echo "$output" | sed 's/:.*//'`
    if test $status = 1 && test x"$output" = x"$3" ; then
        printcount "ok"
    else
        printcount "not ok"
        echo "  saw: $output"
        echo "  not: $3"
    fi
}

# Total tests.
echo 16

# First run the tests expected to succeed.
runsuccess "m" "21"
runsuccess "m" "128000"
runsuccess "m" "0"
runsuccess "r" "21"
runsuccess "r" "128000"
runsuccess "s" "21"
runsuccess "s" "128000"

# Now limit our memory to 96KB and then try the large ones again, all of
# which should fail.
ulimit -d 96
runfailure "m" "128000" "failed to malloc 128000 bytes at t/xmalloc.c line 30"
runfailure "r" "128000" "failed to realloc 128000 bytes at t/xmalloc.c line 51"
runfailure "s" "64000" "failed to strdup 64000 bytes at t/xmalloc.c line 75"

# Check our custom error handler.
runfailure "M" "128000" "malloc 128000 t/xmalloc.c 30"
runfailure "R" "128000" "realloc 128000 t/xmalloc.c 51"
runfailure "S" "64000" "strdup 64000 t/xmalloc.c 75"

# Check the smaller ones again just for grins.
runsuccess "m" "21"
runsuccess "r" "32"
runsuccess "s" "64"