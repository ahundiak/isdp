/* $Id: vdprotos.m,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdprotos/vdprotos.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdprotos.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:05  cvs
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
# Revision 1.1  1995/11/29  14:24:52  pinnacle
# Created: ./vdprotos/vdprotos.m by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/29/95	adz		creation date
 *
 ***************************************************************************/

SOURCE
VDforms.C

LIB
$VDS/lib/vdiprotos.o

SPEC
$EXNUC/spec 
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$FORMS/include
$VDS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
