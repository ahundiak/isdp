/* $Id: vdreclusfc.m,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/******************************************************************************
 * I/VDS
 *
 * File:        vds240/vdrecluster/func/vdreclusfc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdreclusfc.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:06  cvs
 *      Initial import to CVS
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
# Revision 1.1  1995/12/06  15:57:46  pinnacle
# Created: vdrecluster/func/vdreclusfc.m by jwfrosch for vds.240
#
 *
 * History:
 *      MM/DD/YY      AUTHOR	DESCRIPTION
 *
 ******************************************************************************/

SOURCE

VDClstLib.I   

LIB
$VDS/lib/vdireclusfc.o

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
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude
$VDS/include/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
