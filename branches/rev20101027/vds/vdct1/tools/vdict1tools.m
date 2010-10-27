/* $Id: vdict1tools.m,v 1.4 2001/10/02 15:59:34 paul_noel Exp $  */

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
 *      $Log: vdict1tools.m,v $
 *      Revision 1.4  2001/10/02 15:59:34  paul_noel
 *      Update for new tools for ppls
 *
 *      Revision 1.3  2001/03/14 15:10:04  paul_noel
 *      Add VDtrToolsPPL.I
 *
 *      Revision 1.2  2001/02/02 12:28:04  jayadev
 *      Update for handling additions to the Create Table By Stage Command adding the VDct1 Base Class trees to functionality
 *
 *      Revision 1.1  2001/01/12 15:08:18  art
 *      sp merge
 *
# Revision 1.1  2000/07/31  13:38:02  pinnacle
# pn
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
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      creation
 * 01/12/01  ah      sp merge
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VDtrTools.I
VDtrToolsTbl.I
VDtrToolsPPL.I
/* VDtrToolsIO.I */
#else
VDtrTools.I
VDtrToolsTbl.I
VDtrToolsPPL.I
/* VDtrToolsIO.I */
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdict1tools.o
#else
$VDS/lib/vdict1tools.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
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

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
