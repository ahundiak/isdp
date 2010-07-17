/* $Id:*/

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrrt_STEP/vrrt.m 
 *
 * Description:
 *      This is another copy of the vrrt/vrrt.m file. This might've undergone
 *      some changes while compiling for MariSTEP. That's the reasin these
 *      files are placed in a different directory.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vrrt.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:13:08  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/11/06  20:17:00  pinnacle
# Replaced: vrrt_STEP/vrrt.m for:  by apazhani for route
#
# Revision 1.1  1998/11/06  19:42:08  pinnacle
# initial revision
#
 *
 * History:
 *       Date            Name     Description
 *      11/06/98        Alwin     Creation
 *
 *************************************************************************/

LIB
$ROUTE/lib/vrrt.o

SOURCE
write.C
read.C
RTeqp.I
dngl.C
piperun.C
str.C
cmp.C
mem.C
llcnnct.C
backc.C
symlink.C
dbg.C
diag.C

/*
llmisc.C
llinsert.C
dgstdlb.c
RT_csg.c
csg.c
fun.C
trial.C
tmp.C
drive.C
*/

SPEC
$VDS/spec
$ROUTE/spec
$EXNUC/spec
$GRNUC/spec
$EMS/spec
$MODEL/spec


INCLUDE
.
$ROUTE/include
$ROUTE/vrinclude
$ROUTE/vrrt
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$EMS/include
$MODEL/include
$BS/include
$VDS/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes
$VDS/include
$VDS/vdinclude
.


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp


