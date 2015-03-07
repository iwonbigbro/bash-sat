#!/bin/bash

# Copyright (C) 2015 Craig Phillips.  All rights reserved.

cat >bad_script.sh <<BAD_SCRIPT
#!/bin/bash

if true then
    echo Missing semicolon before then.
fi
BAD_SCRIPT

bash-sat bad_script.sh
