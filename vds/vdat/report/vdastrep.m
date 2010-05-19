/* $Id: vdastrep.m,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdat/report/vdastrep.m
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdastrep.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/31  13:47:44  pinnacle
# Moved from vdastree
#
# Revision 1.1  1997/11/04  17:43:32  pinnacle
# Created: vdastree/report/vdastrep.m by v250_int for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *	11/01/97	adz	Source files for reporting cmd.
 *	12/30/97	ah	Moved to vdat
 *
 * -------------------------------------------------------------------*/

SOURCE
VDCmdReport.S
VDCmdReporti.I
VDreportproc.I
VDvalfrreprt.I
VDreportform.C
VDreportobjs.C


LIB
$VDS/lib/vdiasreport.o

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
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
$VDS/vdinclude/prototypes
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

