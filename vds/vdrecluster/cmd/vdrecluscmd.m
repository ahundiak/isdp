/* $Id: vdrecluscmd.m,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/******************************************************************************
 * I/VDS
 *
 * File:        vds240/vdrecluster/cmd/vdrecluscmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdrecluscmd.m,v $
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
# Revision 1.2  1996/05/22  17:32:06  pinnacle
# Replaced: vdrecluster/cmd/vdrecluscmd.m for:  by jwfrosch for vds.240
#
# Revision 1.1  1995/12/06  15:59:18  pinnacle
# Created: vdrecluster/cmd/vdrecluscmd.m by jwfrosch for vds.240
#
 *
 * History:
 *      MM/DD/YY      AUTHOR    DESCRIPTION
 *
 ******************************************************************************/

SOURCE

VDm_lib.S
VDm_libi.I
VDm_place4.I
COm_libi.I

LIB
$VDS/lib/vdcrecluscmd.o

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

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
