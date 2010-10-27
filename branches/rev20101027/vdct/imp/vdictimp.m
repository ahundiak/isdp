/* $Id: vdictimp.m,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/imp/vdictimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdictimp.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/05/28  13:59:18  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      creation
 ***************************************************************************/

SOURCE
VDcla.S
VDcol.S
VDlnk.S
VDctBase.S
VDctLeaf.S

VDclai.I
VDlnki.I
VDcoli.I
VDcol1.I

LIB
$VDS/lib/vdictimp.o

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
$FORMS/include
$PDU/include
$NFMDP/include
$MODEL/include
$UMS/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
