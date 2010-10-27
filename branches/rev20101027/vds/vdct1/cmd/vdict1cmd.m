/* $Id: vdict1cmd.m,v 1.2 2001/01/11 22:03:42 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/cmd/vdictcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdict1cmd.m,v $
 *      Revision 1.2  2001/01/11 22:03:42  art
 *      sp merge
 *
# Revision 1.5  2000/12/08  21:28:26  pinnacle
# ah
#
# Revision 1.4  2000/12/08  21:08:34  pinnacle
# ah
#
# Revision 1.3  2000/06/02  15:02:14  pinnacle
# ah
#
# Revision 1.2  2000/04/28  16:25:52  pinnacle
# Replaced: vds/vdct1/cmd/vdict1cmd.m for:  by pnoel for Service Pack
#
# Revision 1.1  2000/04/20  18:38:30  pinnacle
# Created: vds/vdct1/cmd/vdict1cmd.m by pnoel for Service Pack
#
# Revision 1.2  1999/12/08  19:37:34  pinnacle
# ah
#
# Revision 1.1  1999/06/29  18:29:28  pinnacle
# ct
#
# Revision 1.1  1999/05/30  14:30:52  pinnacle
# ct
#
# Revision 1.1  1999/05/28  13:59:18  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      creation
 ***************************************************************************/

SOURCE
VDct1Mgr.I
VDct1Set.I
VDct1Lib.I
VDct1Node.I
VDct1Attr.I
VDct1Free.I
VDct1Part.I
VDct1Tree.I
VDct1TreeF.I

LIB
$VDS/lib/vdict1cmd.o

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
