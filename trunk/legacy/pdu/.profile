#ident	"@(#)stdprofile	1.2	9/1/88 Copyright (c) 1986,1987 by Intergraph Corp."

stty -tabs
umask 2
#switch compile


. .env


CURID=`id | cut -d'(' -f2 | cut -d')' -f1`
PS=`uname -n`
PS1A=`echo '\033[1m'`
PS1B=`echo '\033[0m'`
PS1='$PS1A($PS:$CURID)$PS1B $PWD
-->>'
PS2='su~> '

