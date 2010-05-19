/* $Id: vdbs_old.m,v 1.1 2001/01/17 21:14:04 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/bs/vdbs.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdbs_old.m,v $
 *	Revision 1.1  2001/01/17 21:14:04  hans
 *	Added for historic purpose only
 *	
 *	Revision 1.2  2001/01/12 22:22:18  hans
 *	SP16 files added for OLD Model exec.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:27  cvs
 *	Initial import to CVS
 *
# Revision 1.10  2000/12/11  21:32:32  pinnacle
# Replaced: vds/emsfixes/bs/vdbs.m for:  by rchennup for Service Pack
#
# Revision 1.9  2000/11/17  19:19:06  pinnacle
# Replaced: vds/emsfixes/bs/vdbs.m for:  by rchennup for Service Pack
#
# Revision 1.8  2000/11/07  21:10:26  pinnacle
# Replaced: vds/emsfixes/bs/vdbs.m for:  by rchennup for Service Pack
#
# Revision 1.7  2000/10/23  14:43:40  pinnacle
# Replaced: vds/emsfixes/bs/vdbs.m for:  by rchennup for Service Pack
#
# Revision 1.6  2000/07/14  16:08:44  pinnacle
# Replaced: vds/emsfixes/bs/vdbs.m for:  by jwfrosch for Service Pack
#
# Revision 1.5  2000/07/11  22:11:06  pinnacle
# Replaced: vds/emsfixes/bs/vdbs.m for:  by rchennup for Service Pack
#
# Revision 1.4  2000/06/23  23:12:34  pinnacle
# Replaced: vds/emsfixes/bs/vdbs.m for:  by rchennup for Service Pack
#
# Revision 1.3  2000/05/11  16:24:58  pinnacle
# Replaced: vds/emsfixes/bs/vdbs.m for:  by jwfrosch for Service Pack
#
# Revision 1.2  2000/05/10  19:20:00  pinnacle
# (No comment)
#
# Revision 1.1  2000/04/28  20:48:56  pinnacle
# Created: vds/emsfixes/bs/vdbs.m by jwfrosch for Service Pack
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/09/97  adz     Add three files corrections.
 * 03/05/98  ah      Add VDdbgFlags.c for debug flags
 * 05/15/98  ah      An earlier change created a new file bsmdptbscv1.h
 *                   Checked this file into this directory and added .
 *                   To the list of include search paths
 * 05/22/98  ah      TR179801101 Data reduction core dumps bsdta_rdusf.c
 * 06/24/98  ah      TR179801103 Offset curve problem
 * 06/29/99  ah      New bspmath build, get rid of almost everything
 * 12/08/99  ah      Added new functions from loft unwrap
 * 01/05/20  Jayadev Added three new file for loft unwrap
 * 02/15/00  RR      Added two files related to BSmdistcvsf() function
 * 02/28/00  HF      Fix for TR 179901421
 * 05/10/00  HF      Fix for TR 179901376
 * 05/11/00  HF      Fix for TR ???
 *                   Performance and accuracy improvements
 * 07/14/00  HF      Fix for TR 179901384
 * -------------------------------------------------------------------*/

SOURCE
bspch_intop.c		/* for TR 179901421 */
bsx2sf_prj.c            /* for TR 179901376 */
bsmdistcvsf.c           /* for TR ??? Performance and accuracy improvements */
bsmdistsfsf.c           /* for TR ??? Performance and accuracy improvements */
bsmdistlnpl.c           /* for TR ??? Performance and accuracy improvements */
bsmdistplpl.c           /* for TR ??? Performance and accuracy improvements */

bsofk3arc.c		/* TR#179901756 */
bscmpcvoff1.c		/* TR#179901756 */
bscmpmrgoff.c		/* TR#179901756 */
bsmvxsectrc.c           /* for TR 179901384 */
bsunwrap.c		/* Unwrap Related */
bnsb_lop.c		/* TR# 4109	  */
bschk2cvsov.c		/* External Contour Related */
bspt_in_plg.c		/* TR# 4284		    */

#if 0
bsbrapproxs.c		/* for TR 179800857 */
bsdta_rdusf.c
VDdbg_glob.c 		/* for TR 179800857 */
VDdbgFlags.c
FSassert.c              /* fontserver assertions causing core dumps */
bssidecntrs.c           /* From unwrap */
bssplitncvs.c           /* From unwrap */
bschkfxsf2.c            /* From unwrap */
bscmpcvoffl.c           /* From unwrap */
bscmpextoff.c           /* From unwrap */
bspolyxcvcv.c           /* From unwrap */
bsmdistcvsf.c		/* TR#179901061 & 62 */
bscvsfintrg.c		/* TR#179901061 & 62 */
#endif

#if 0
bsdta_rdusf.c
bssfplintlg.c
bssfsfint.c
bsxplngmsfo.c
bsmksfb2cs.c		/* Cross section fix.	*/
bsptnorsf.c		/* Intersection problem	*/
bsboxinvab.c 		/* Intersection problem */
bssfintroff.c		/* 02/20/98 Fix Offset   problem */
bsextpolcv0.c		/* 02/27/98 Fix Extend problem (causing failure of "Split Surface & Bounded Volume") */

FSassert.c              /* fontserver assertions causing core dumps */
bsmvcsnsfvc.c		/* 03/09/98 Cusps compute ... */
VDdbgFlags.c
bscvsfpchtb.c 		/* for TR179800758 */

VDdbg_glob.c 		/* for TR 179800857 */
bsbrapproxs.c		/* for TR 179800857 */

bsmdptbscv.c		/* for TR 179800712 */
bsmdptbscv1.c		/* for TR 179800712 */
bsmnmxpt2.c		/* for TR 179800712 */
bstst_stack.c		/* for TR 179800149 */

bs2cvsoffpg.c  /* TR179801103 */
bscvoff3d.c    /* TR179801103 */
bscvoffsetd.c  /* TR179801103 */
bsspnoffset.c  /* TR179801103 */
bsxycvoff.c    /* TR179801103 */
#endif

LIB
$VDS/etc/needed_dload/dloadbsp.o

INCLUDE
$BS/include
$BS/igr_include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
.

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

