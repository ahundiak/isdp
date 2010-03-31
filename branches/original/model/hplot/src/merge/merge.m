EXEC
$(hpexec)/merge_pf.x

LINKLIB

COPT
-ga

SRC
$(MODEL)/hplot/src/merge

SOURCE
main.c
header.c
copy.c
copy_ctbl.c
copy_curv.c
copy_surf.c

CC
cc

INCLUDE
$(EXNUC)/include
$(GRNUC)/include
$(hsurf)/src/include
