/* $Id: vdcptscmd.m,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpts/vdcptscmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdcptscmd.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:05  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/10/27  16:30:56  pinnacle
# Replaced: vdpts/vdcptscmd.m for:  by jwfrosch for vds
#
# Revision 1.2  1997/06/13  17:48:24  pinnacle
# CR179527294: moved VDfileform.C and VDformUtil.C from vdpts to vdio to keep all subform (input/output) utilities together.
#
# Revision 1.1  1997/05/30  09:18:46  pinnacle
# initial revision
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
*
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	05/30/97	Sundar		Creation Date
 * -------------------------------------------------------------------*/

SOURCE
VDCmdPlPts.S
VDCmdPlPtsi.I

LIB
$VDS/lib/vdcptscmd.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$UMS/include
$EXNUC/include
$GRNUC/include
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
