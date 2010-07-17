/* $Id: vlunwext.m,v 1.17 2002/04/16 13:58:57 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/vlunwext.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vlunwext.m,v $
 *      Revision 1.17  2002/04/16 13:58:57  ramarao
 *      Implemented CR# 5993.
 *
 *      Revision 1.16  2001/09/19 14:23:33  ramarao
 *      Implemented CR# 5546.
 *
 *      Revision 1.15  2001/09/15 20:40:28  ramarao
 *      Fixed TR# 5568. Extended the unwrap contour in variable bevel case.
 *
 *      Revision 1.14  2001/07/27 14:08:49  ramarao
 *      Added VLunwprjfc.I file for SP13.
 *
 *      Revision 1.13  2001/07/03 19:16:52  ramarao
 *      Removed VLunwprjfc.I file from makefile list.
 *
 *      Revision 1.12  2001/07/01 16:37:37  ramarao
 *      Fixed CR# 5351.
 *
 *      Revision 1.11  2001/06/27 20:30:09  ramarao
 *      Fixed TR# 5371.
 *
 *      Revision 1.10  2001/06/26 21:26:24  ramarao
 *      Fixed TR# 5245.
 *
 *      Revision 1.9  2001/06/20 23:00:42  ramarao
 *      Fixed a crash problem.
 *
 *      Revision 1.8  2001/06/08 00:28:45  ramarao
 *      Fixed a problem in VLunwGetPointOnPlate() function.
 *
 *      Revision 1.7  2001/05/31 14:35:41  ramarao
 *      Fixed TR# 5270.
 *
 *      Revision 1.6  2001/05/09 14:26:02  ramarao
 *      Fixed ETL# 8192.
 *
 *      Revision 1.5  2001/04/16 17:00:41  ramarao
 *      Implemented CR#4086 on Auto Labeling.
 *
 *      Revision 1.4  2001/04/12 20:38:10  ramarao
 *      Fixed TR# 5025.
 *
 *      Revision 1.3  2001/03/16 23:59:02  ramarao
 *      Fixed CR# 4467
 *
 *      Revision 1.2  2001/01/16 19:56:27  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:56  cvs
 *      Initial import to CVS
 *
# Revision 1.8  2000/03/21  15:39:04  pinnacle
# Replaced: src/unwext/vlunwext.m for:  by impd252 for loft
#
# Revision 1.7  2000/01/18  18:02:04  pinnacle
# ah
#
# Revision 1.6  2000/01/05  04:31:38  pinnacle
# Replaced vlunwext.m by jpulapar for loft
#
# Revision 1.5  2000/01/04  09:06:40  pinnacle
# Updated vlunwext.m for TR179900860 by jpulapar for loft
#
# Revision 1.4  2000/01/04  08:53:46  pinnacle
# Updated vlunwext.m with newfile for label_loft macro by jpulapar for loft
#
# Revision 1.3  1999/05/18  21:27:20  pinnacle
# Added bs protos
#
# Revision 1.2  1999/05/18  16:00:24  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.4  1997/11/03  15:28:18  pinnacle
# Replaced: src/unwext/vlunwext.m for:  by l250_int for loft
#
# Revision 1.3  1997/10/31  19:21:48  pinnacle
# Replaced: src/unwext/vlunwext.m for:  by rchennup for loft
#
# Revision 1.2  1997/10/28  16:17:32  pinnacle
# Replaced: src/unwext/vlunwext.m for:  by rchennup for loft
#
# Revision 1.1  1997/10/28  15:32:36  pinnacle
# Created: src/unwext/vlunwext.m by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *	11/03/97   adz		Moved file VLunwmacrodf.I to VDS.
 *      01/18/00   ah           Added VLunwMisc.I
 *************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VLunwObji.I
VLunwFeati.I
VLunwCreBnd.I
VLpltLabel.I
VLunwObjFk.I
VLunwoutpt.I
VLunwextapi.I
VLextMethod.I
VLunwprjfc.I
VLunwVarBvl.I
VLunwDimBvl.I
VLunwChkLen.I
#else
VLunwextCmd.S
VLunwextCmdi.I
VLmodextCmd.S
VLmodextCmdi.I
VLextMethod.I

VLunwFeat.S
VLunwFeati.I

VLunwObj.S
VLunwObji.I
VLunwObjgr.I
VLunwObjov.I

VLunwMgr.S
VLunwMgrcrt.I
VLunwMgrfunc.I

VLunwchannel.I
VLunwsupport.I
VLunwoutpt.I
VLunwprjfc.I
VLunwprjmap.I
VLunwBndFunk.I
VLunwObjFk.I

VLunwextapi.I
VLdrwfcnsupp.I
VLunwLabel.I

VLatPktLine.I
VLunwCreBnd.I
VLunwDevFunk.I
VLunwmrkchk.I
VLpltLabel.I
VLunwVarBvl.I
VLunwDimBvl.I
VLunwChkLen.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXL)/lib/vlunwext.o
#else
$LOFT/lib/vlunwext.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec
$LOFT/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
$(SPXV)/vdinclude
$(SPXS)/include
$(SPXS)/include/prototypes
$(SPXL)/include
$(SPXL)/include/prototypes
#endif
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
$UMS/include
$STRUCT/include
$STRUCT/include/prototypes
$LOFT/include
$LOFT/include/private
$LOFT/include/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
