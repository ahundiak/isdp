/* $Id: vdbs_new.m,v 1.1 2001/01/17 21:14:02 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/bs/vdnewbs.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdbs_new.m,v $
 *	Revision 1.1  2001/01/17 21:14:02  hans
 *	Added for historic purpose only
 *	
# Revision 1.10  2001/01/09  16:07:56  pinnacle
# Replaced: vds/emsfixes/bsnew/vdbsnew.m for:  by impd252 for Service Pack
#
# Revision 1.9  2000/12/12  18:41:56  pinnacle
# Replaced: vds/emsfixes/bsnew/vdbsnew.m for:  by rchennup for Service Pack
#
# Revision 1.8  2000/12/11  21:33:18  pinnacle
# Replaced: vds/emsfixes/bsnew/vdbsnew.m for:  by rchennup for Service Pack
#
# Revision 1.7  2000/11/30  21:59:30  pinnacle
# Replaced: vds/emsfixes/bsnew/vdbsnew.m for:  by rchennup for Service Pack
#
# Revision 1.6  2000/11/27  19:56:24  pinnacle
# Replaced: vds/emsfixes/bsnew/vdbsnew.m for:  by jpulapar for Service Pack
#
# Revision 1.5  2000/11/17  19:20:56  pinnacle
# Replaced: vds/emsfixes/bsnew/vdbsnew.m for:  by rchennup for Service Pack
#
# Revision 1.4  2000/11/07  21:11:08  pinnacle
# Replaced: vds/emsfixes/bsnew/vdbsnew.m for:  by rchennup for Service Pack
#
# Revision 1.3  2000/08/31  19:56:42  pinnacle
# Replaced: vds/emsfixes/bsnew/vdbsnew.m for:  by jwfrosch for Service Pack
#
# Revision 1.2  2000/08/25  18:46:20  pinnacle
# Replaced: vds/emsfixes/bsnew/*.m for:  by jwfrosch for Service Pack
#
# Revision 1.1  2000/08/24  16:02:58  pinnacle
# Created: vds/emsfixes/bsnew/vdbsnew.m by jwfrosch for Service Pack
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
 * 08/24/00  HF      List of files to be used with new MODEL executable
 * -------------------------------------------------------------------*/

SOURCE
/*
 * The files in this #if/#endif section MUST be ACTIVATED for PLOAD
 */
#if 0
VDdbg_glob.c 		/* for TR 179800857 */
VDdbgFlags.c
FSassert.c              /* fontserver assertions causing core dumps */
#endif

/*
 * Unwrap files from bs_ot: These are never built into Model and
 *			    must ALWAYS be loaded dynamically !!
 */

bsunwrap.c		/* From unwrap */
bnsb_lop.c              /* TR# 4109    */
bschk2cvsov.c		/* External Contour Related */
bspt_in_plg.c		/* TR# 4284 */

bsflatbspsf.c		/* From unwrap       */
bsflatcrvsf.c		/* From unwrap       */
bsflatrelsf.c		/* From unwrap       */
bsrelaxope.c		/* From unwrap       */

bssfincktm.c            /*                   */
bsfndptin.c             /*                   */
bsclscurve.c            /*                   */
bslldist.c		/* ETL# 5232 && 5230 */
bssfpllgcln.c		/* TR# 4417          */

/*
 * The files in this #if/#endif section can be DEACTIVATED for PLOAD with new MODEL executable
 */
#if 1
bsbrapproxs.c		/* Revert to BSPMATH version */
bssidecntrs.c           /* INCOMPATIBLE with OLD BSPMATH/Model Executable */

bsdta_rdusf.c
bssplitncvs.c           /* From unwrap */
bscmpcvoffl.c           /* From unwrap */

bschkfxsf2.c            /* From unwrap */
bscmpextoff.c           /* From unwrap */
bspolyxcvcv.c           /* From unwrap */
bscvsfintrg.c		/* TR#179901061 & 62 */

bspch_intop.c		/* for TR 179901421 */
bsmdistcvsf.c           /* for TR ??? Performance and accuracy improvements */
bsmdistsfsf.c           /* for TR ??? Performance and accuracy improvements */
bsmdistlnpl.c           /* for TR ??? Performance and accuracy improvements */
bsmdistplpl.c           /* for TR ??? Performance and accuracy improvements */

bsofk3arc.c		/* TR#179901756 */
bscmpcvoff1.c		/* TR#179901756 */
bscmpmrgoff.c		/* TR#179901756 */
bsmvxsectrc.c           /* for TR 179901384 */

bsx2sf_prj.c            /* for TR 179901376 */
marotmx.c               /*                  */

#endif

LIB
$SPXV/etc/needed_dload/dloadbsp_new.o

INCLUDE
./prototypes
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
