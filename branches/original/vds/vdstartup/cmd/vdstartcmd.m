/* $Id: vdstartcmd.m,v 1.3 2001/08/30 23:20:32 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdstartup/cmd / vdstartcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdstartcmd.m,v $
 *	Revision 1.3  2001/08/30 23:20:32  ad
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/08/20 20:18:08  ad
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/07/30  20:41:22  pinnacle
# Replaced: vdstartup/cmd/vdstartcmd.m for:  by hverstee for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDStrtupFnc.I
#else
VDCmdStrtup.S		/* startup command			*/
VDCmdStrtupi.I
VDStrtupFnc.I
#endif


LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdstartcmd.o
#else
$VDS/lib/vdstartcmd.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$PDU/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$PDU/include
$NFMDP/include
$MODEL/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
