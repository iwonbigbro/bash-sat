#!/bin/bash

# Copyright (C) 2015 Craig Phillips.  All rights reserved.

# A simple test runner implementation.

set -Eeu

run_test_sh=$(readlink -f "$BASH_SOURCE")

export BASHCAT_LIBDIR=$(readlink -m ${run_test_sh%/*/*}/lib/bashcat)

export TEST_NAME=$1
export TEST_DATE=$(date -u "+%Y%m%dT%H%M%S")
export TEST_SCRIPT=$(readlink -f "${run_test_sh%/*}/$1/test.sh")
export TEST_SETUP=$(readlink -f "${run_test_sh%/*}/$1/setup.sh")
export TEST_TEARDOWN=$(readlink -f "${run_test_sh%/*}/$1/teardown.sh")
export TEST_ROOT=$BUILDROOT/tests/$1

rm -rf $TEST_ROOT
mkdir -p $TEST_ROOT

function bail() {
    set +xeu
    local e=$1 ; shift
    local p="${FUNCNAME[1]^^} - $TEST_NAME${1:+ [$*]}"
    local debug_line=$(awk 'NR == '$TEST_LINENO' { print gensub(/^\ */, "", ""); exit }' $TEST_SOURCE)

    {

    if [[ $e == 0 ]] ; then
        echo "$p"
        exit $e
    fi

    if [[ -s $TEST_ROOT/output ]] ; then
        echo "$p: OUTPUT_BEG:"
        cat $TEST_ROOT/output
        echo "$p: OUTPUT_END:"
    else
        echo "$p"
    fi

    echo

    echo "    >>>   $debug_line   <<<"
    echo "    >>>   $TEST_STATEMENT   <<<"
    echo
    echo "$p"

    } >&5

    exit $e
}

function err() { bail 1 "$@" ; }
function fail() { bail 1 "$@" ; }
function skip() { bail 0 "$@" ; }
function pass() { bail 0 "$@" ; }

function setup() {
    if [[ -f $TEST_SETUP ]] ; then
        TEST_SETUP_RUN=1

        . $TEST_SETUP
    fi
}

function end_test() {
    if [[ $TEST_RESULT == 0 ]] ; then
        touch $TEST_ROOT/pass

        ( pass ) || true
    else
        ( fail "$TEST_SECTION failure" ) || true
    fi

    if [[ -f $TEST_TEARDOWN ]] ; then
        ( . $TEST_TEARDOWN ) || fail "Teardown failure"
    fi

    exit $TEST_RESULT
}

function section() {
    TEST_SECTION=$1
}

function ondebug() {
    local e=$1 l=$2 al=$3 s=$4 c=$5 fn=$6

    if [[ $e != 0 ]] ; then
        NOTRACE=1
    fi

    if [[ ${NOTRACE:-} != 1 ]] ; then
        TEST_STATEMENT=$c
        TEST_ALT_LINENO=$al
        TEST_LINENO=$l
        TEST_SOURCE=$s
    fi

    if [[ ${TEST_DEBUG:-} ]] ; then
        indent=$(printf "%0${#BASH_SOURCE[@]}d" 0)
        indent=${indent//?/+}

        printf >&5 "%${#indent}s %s:%s:%s(): %s\n" \
            "$indent" "$s" "$l" "$fn" "$c"
    fi
}

if [[ -f ${run_test_sh%/*}/run_test_functions.sh ]] ; then
    . ${run_test_sh%/*}/run_test_functions.sh
fi

exec 5>&1 1>$TEST_ROOT/output 2>&1

section "Initlisation"

TEST_RESULT=1
TEST_SETUP_RUN=

set -T
shopt -s extdebug
trap 'ondebug $? $LINENO $BASH_LINENO "$BASH_SOURCE" "$BASH_COMMAND" "${FUNCNAME:-main}"' DEBUG
trap 'e=$? ; trap DEBUG ; exit $e' ERR
trap 'end_test $?' EXIT

cd $TEST_ROOT

section "Setup"
setup

section "Test"
. $TEST_SCRIPT

TEST_RESULT=0
