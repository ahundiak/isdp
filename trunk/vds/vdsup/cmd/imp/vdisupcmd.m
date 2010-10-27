/* $Id: vdisupcmd.m,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $ */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/cmd/imp/vdisupcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdisupcmd.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/17  21:59:52  pinnacle
# VDsupEtc
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      12/17/97  ah      Creation
 ***************************************************************************/

SOURCE
VDsupEtc.I

LIB
$VDS/lib/vdisupcmd.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
.
$BS/include
$BS/include/prototypes
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude
$VDS/vdinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
