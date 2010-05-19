/* $Id: smspacefc.m,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/func / smspacefc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smspacefc.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/29  22:29:22  pinnacle
# TR179701957
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/01/02  10:15:44  pinnacle
# Replaced: smspace/func/smspacefc.m for:  by rgade for vds.240
#
# Revision 1.2  1995/07/30  18:46:20  pinnacle
# Replaced: smspace/func/smspacefc.m for:  by hverstee for vds.240
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
 *	10/29/97	ah		TR179701957 Ref Files Not Working
 *					Moved SMCrtSfBnd to SMspace_int1.I
 * -------------------------------------------------------------------*/

SOURCE

VDmdist.C
SMspace_fn.I
SMspace_int.I
SMspace_int1.I
SMsearchvol.c
SMOrie.I
SMSolUtil.I
SMextcurv.I
SMspcTmpStr.I

LIB
$VDS/lib/smispacefc.o

SPEC
$EXNUC/spec 
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include 
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$PDU/include
$NFMDP/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
