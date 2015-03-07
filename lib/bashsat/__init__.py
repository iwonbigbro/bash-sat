#!/usr/bin/env python

# Copyright (C) 2015 Craig Phillips.  All rights reserved.

import sys, os


def usage():
    sys.stdout.write("""Usage: {prog} [options] [script...]
Summary:
    Static analysis tool for Bash.

Options:
    TBD

Licence:
    New BSD License (BSD-3)
    
Copyright (C) 2015 Craig Phillips.  All rights reserved.
""".format(
        prog=os.path.basename(sys.argv[0])
    ))


def main(argv=sys.argv):
    pass
