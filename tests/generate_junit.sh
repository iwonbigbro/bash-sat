#!/bin/bash

# Copyright (C) 2015 Craig Phillips.  All rights reserved.

set -eu

echo '<?xml version="1.0" encoding="UTF-8"?>'

count=$(ls -1 $BUILDROOT/tests/* | wc -l)

printf '<testsuite tests="%d">\n' $count

for t in $BUILDROOT/tests/* ; do
    name=${t##*/}
    class=${name%%_*}

    printf '<testcase classname="%s" name="%s">\n' "$class" "$name"
    if [[ -s $t/output ]] ; then
        echo '<system-out><![CDATA['
        strings $t/output
        echo ']]></system-out>'
    fi

    if [[ -s $t/debug ]] ; then
        echo '<system-err><![CDATA['
        strings $t/debug
        echo ']]></system-err>'
    fi

    if [[ ! -f $t/pass ]] ; then
        echo '<failure type="error">Test failed - see output</failure>'
    fi

    echo '</testcase>'
done

echo '</testsuite>'
