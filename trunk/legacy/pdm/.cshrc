# stdcshrc
# Copyright (c) 1992 by Intergraph Corp.

# This is the standard .cshrc delivered to a user.
# It sets up the local environment for each invocation of /bin/csh.
# Users are expected to edit it to meet their own needs. 
#
# NOTE: /bin/ksh is the standard operating environment under CLIX. Not all
# delivered scripts will work under csh. This file is provided as a convenience
# for users who choose to use the csh instead.

set history = 200
set savehist = 100
alias h history
alias more pg -n
alias ls ls -C
alias lo exit
