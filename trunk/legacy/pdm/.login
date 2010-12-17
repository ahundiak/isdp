# stdlogin
# Copyright (c) 1992 by Intergraph Corp.

# This is the standard .login delivered to a user.
# It sets up the global environment when /bin/csh is used as the login shell.
# Users are expected to edit it to meet their own needs. 
#
# NOTE: /bin/ksh is the standard operating environment under CLIX. Not all
# delivered scripts will work under csh. This file is provided as a convenience
# for users who choose to use the csh instead.

setenv EDITOR vi
setenv TERM vt100
setenv PATH .:/bin:/usr/bin

# setting TZ here
set foo=`grep \= /etc/TIMEZONE | grep -v \# | sed "s/\=/ /"`
setenv $foo
unset foo

cat -s /etc/motd
stty erase "^?" kill "^U" intr "^C"
mail -e 
if ($status == 0) then
  echo "you have mail"
endif
umask 022
