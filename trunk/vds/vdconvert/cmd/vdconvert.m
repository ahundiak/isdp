/* $Id: vdconvert.m,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdconvert/cmd / vdconvert.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdconvert.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *	Initial import to CVS
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE
SMCmdCvtCmp.S
SMCmdCvtCmpi.I
SMCmdCvtFrm.S
SMCmdCvtFrmi.I
VDCmdupdbox.S
VDCmdupdboxi.I
VDrtupdcls.S
VDrtupdclsi.I

LIB
$VDS/lib/vdicvrtcmd.o

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$VDS/include
$VDS/vdinclude
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
