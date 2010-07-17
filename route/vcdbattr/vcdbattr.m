/* $Id: vcdbattr.m,v 1.3 2002/05/18 23:27:26 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vcdbattr / vcdbattr.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: vcdbattr.m,v $
 *        Revision 1.3  2002/05/18 23:27:26  anand
 *        Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *        files only) - kind of preparing for the Service Pack cycle!
 *
 *        Revision 1.2  2001/05/30 16:59:01  anand
 *        No TR. bend_rad for backshell.
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1999/01/19  04:51:04  pinnacle
# Replaced: vcdbattr/vcdbattr.m for: CR179701619 by aharihar for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1997/11/30  19:18:16  pinnacle
# Replaced: vcdbattr/vcdbattr.m for:  by impd for route
#
# Revision 1.3  1997/11/30  16:08:52  pinnacle
# Replaced: vcdbattr/vcdbattr.m for:  by r250_int for route
#
# Revision 1.6  1997/11/14  23:17:12  pinnacle
# Replaced: vcdbattr/vcdbattr.m for:  by onayragu for cabling
#
# Revision 1.5  1997/07/14  21:45:20  pinnacle
# Replaced: vcdbattr/vcdbattr.m for:  by hverstee for cabling
#
# Revision 1.4  1997/03/14  18:07:32  pinnacle
# Replaced: vcdbattr/vcdbattr.m for:  by hverstee for cabling
#
# Revision 1.3  1996/10/07  18:46:16  pinnacle
# Replaced: vcdbattr/vcdbattr.m for:  by hverstee for cabling
#
# Revision 1.2  1996/08/30  17:39:28  pinnacle
# Replaced: vcdbattr/vcdbattr.m for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:54:54  pinnacle
# Created: vcdbattr/vcdbattr.m by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        19 Jan 1999     Anand     Added entries for new files on jumpers.
 *
 *************************************************************************/

LIB
$ROUTE_PATH/lib/vcdbattr.o

SOURCE


VCDB.S
VCDBi.I

VCDBgen.S
VCDBgeni.I

VCDBcbgd.S
VCDBcbgdi.I

VCDBGuide.S
VCDBGuidei.I

VCDBbksh.S
VCDBbkshi.I

VCDBcable.S
VCDBcablei.I

VCDBElCab.S
VCDBElCi.I

VCDBFoCab.S
VCDBFoCi.I

VCDBterm.S
VCDBtermi.I

VCDBElTerm.S
VCDBElTi.I

VCDBFoTerm.S
VCDBFoTi.I

VCDB_func.I
VCDB_FOfn.I

VCTAG.S
VCTAGi.I

VCTagMgr.S
VCTagMgri.I

VCDBjumper.S  /* added by alwin for CR179701619 */
VCDBjumperi.I


SPEC
$ROUTE/spec
$VDS/spec
$GRNUC/spec
$EXNUC/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXR/vcinclude
$SPXR/vrinclude
$SPXR/vrinclude/prototypes
$SPXR/include
$SPXV/vdinclude
$SPXV/include
$SPXV/include/prototypes
#endif
$ROUTE/vcinclude
$ROUTE/vrinclude
$ROUTE/vrinclude/prototypes
$ROUTE/include
$VDS/vdinclude
$VDS/include
$VDS/include/prototypes
$PDM/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$BS/include
$BS/include/prototypes
$EXNUC/include
$UMS/include /* added by anand for CR179701619 */
$FORMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp


