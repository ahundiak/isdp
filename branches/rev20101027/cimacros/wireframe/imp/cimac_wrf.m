/* $Id: cimac_wrf.m,v 1.1.1.1 2001/01/04 21:07:22 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/cimacros/wireframe/imp / cimac_wrf.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: cimac_wrf.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:22  cvs
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
VDS_BSstubs.C

LIB
$VDS/lib/vdcimacwrf.o

SPEC
$EXNUC/spec
$GRNUC/spec

INCLUDE
$BS/include
$EXNUC/include
$GRNUC/include
$PDU/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
