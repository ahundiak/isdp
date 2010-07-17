/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/vrrt.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrrt.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/01/16  00:13:32  pinnacle
# Replaced: vrrt/vrrt.m for:  by r250_int for route
#
# Revision 1.1  1998/01/12  23:17:34  pinnacle
# Loading RT functions
#
 *
 * History:
 *	01/05/97	Onay	Creation date.
 *
 *************************************************************************/
LIB
/*
$ROUTE/lib/vrrt.o
*/
./vrrt.o

SOURCE
write.C
read.C
RTeqp.I
dngl.C
piperun.C

/*
llstruct.C
llmisc.C
llinsert.C
str.C
cmp.C
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


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp


