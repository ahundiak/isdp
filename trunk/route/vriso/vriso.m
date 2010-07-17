/* $Id: vriso.m,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vriso / vriso.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vriso.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.3  1997/01/08  22:54:16  pinnacle
# Replaced: vriso/vriso.m for:  by kddinov for route
#
# Revision 1.2  1997/01/08  21:06:34  pinnacle
# Replaced: vriso/vriso.m for:  by kddinov for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/05/23  22:02:14  pinnacle
# Replaced: vriso/vriso.m for:  by hverstee for route240
#
# Revision 1.3  1996/03/21  23:23:30  pinnacle
# Replaced: vriso/vriso.m for:  by hverstee for route240
#
# Revision 1.2  1996/01/17  00:08:46  pinnacle
# Replaced: vriso/vriso.m for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add BS, ROUTE prototypes
 *
 *************************************************************************/
CC
acc -ansi -Atarg=c300

LIB
$ROUTE/lib/vriso.o

SOURCE
VRiso.S
VRisoi.I
VRiso_fn.I
VRisoform.I
VRIsoBatch.I 
VRITb_iso.I
VRITb_flex.I
VRITb_misc.I
VRITb_fatt.I
VRITb_fcon.I
VRITb_fcmp.I
VRITb_util.I
db_ac.I
fill_big.I
kick_iso.I
VRtriflex.S
VRtriflexi.I
VRtri_fn.I

SPEC
$EXNUC/spec
$GRNUC/spec
$ROUTE/spec
$VDS/spec

INCLUDE
.
$ROUTE/include
$ROUTE/vrinclude
$EXNUC/include
$GRNUC/include
$VDS/include
$PDU/include
$BS/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes
$FORMS/include
$INGRHOME/ums/include 

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
