/* $Id: vdpdmsrc.m,v 1.1.1.1 2001/01/04 21:08:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpdm/source / vdpdmsrc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdpdmsrc.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:58  cvs
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
VDSpdmtable.c
VDSpdmfile.c
VDSpdmtmplt.c
VDSdbdbg.c
VDSdblog.C

LIB
vdpdm.o

INCLUDE
.
$VDS/include
$VDS/vdinclude
$NFMDP/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
