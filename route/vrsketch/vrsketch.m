/* $Id: vrsketch.m,v 1.7 2002/05/18 23:27:27 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrsketch / vrsketch.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrsketch.m,v $
 *	Revision 1.7  2002/05/18 23:27:27  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.6  2001/12/05 15:01:04  louis
 *	tr5901-dep_planes getting deleted
 *	
 *	Revision 1.5  2001/11/08 03:44:31  anand
 *	JTS TR MP 5557
 *	
 *	Revision 1.4  2001/10/02 19:36:09  louis
 *	Fix for TR5470-move segment ends to component origin on insert.
 *	
 *	Revision 1.3  2001/07/09 22:44:59  anand
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/04/03 20:32:09  anand
 *	TR JTS 4485
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:11  cvs
 *	Initial import to CVS
 *	
# Revision 1.5  2000/03/20  06:45:40  pinnacle
# Replaced: vrsketch/vrsketch.m for: CR179801143 by aharihar for route
#
# Revision 1.4  1999/04/20  17:57:48  pinnacle
# (No comment)
#
# Revision 1.3  1999/04/19  21:10:30  pinnacle
# Replaced: vrsketch/vrsketch.m for:  by lawaddel for route
#
# Revision 1.2  1998/05/20  22:32:14  pinnacle
# Replaced: vrsketch/vrsketch.m for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/07  21:12:12  pinnacle
# Replaced: vrsketch/vrsketch.m for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/03/04  22:48:12  pinnacle
# Replaced: vrsketch/vrsketch.m for:  by hverstee for route240
#
# Revision 1.2  1996/01/19  15:10:48  pinnacle
# Replaced: vrsketch/vrsketch.m for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *	03/20/2k   Anand	For lack of a history entry, adding this one!
 *				Actually, split VRsketch.sl into 4 files viz.,
 *				VRsketch.S, VRsketchi.I, VRskformnotify.I
 *				(entry of which has been added to this file)
 *				and VRsketch.t
 *************************************************************************/
CC
acc -ansi -Atarg=c300

LIB
#if ISDP_MAKE_SP
$SPXR/lib/vrsketch.o
#else
$ROUTE/lib/vrsketch.o
#endif

SOURCE
VRsketch.S
VRloadattr.S

VRsketchi.I
VRskformnotify.I
VRloadattri.I
VRPlvlkup.I
VRRlvlkup.I
VRsketchact.I
VRskcrseg.I
VRskcstpt.I
VRskconnect.I
VRppdynamic.I
VRhcdynamic.I
VRskmerge.I
VRplcmpbycod.I
VRHvskupwd.c

SPEC
$ROUTE/spec
$EXNUC/spec
$GRNUC/spec
$EMS/spec
$MODEL/spec
$VDS/spec


INCLUDE
#if ISDP_MAKE_SP
$SPXR/include
$SPXR/vrinclude
$SPXV/include
$SPXV/vdinclude
$SPXR/vrinclude/prototypes
#endif
.
$ROUTE/include
$ROUTE/vrinclude
$EXNUC/include
$GRNUC/include
$EMS/include
$MODEL/include
$BS/include
$VDS/include
$VDS/vdinclude
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

