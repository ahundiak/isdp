/* $Id: vsapps.m,v 1.21 2002/05/09 20:04:59 anand Exp $ */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:	struct/pplapp/vsapps.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vsapps.m,v $
 *	Revision 1.21  2002/05/09 20:04:59  anand
 *	Added COz_booFlip.u in the #else - #endif portion.
 *	
 *	Revision 1.20  2002/05/08 15:46:23  ahundiak
 *	ah
 *	
 *	Revision 1.19  2002/05/01 19:48:24  ahundiak
 *	ah
 *	
 *	Revision 1.18  2002/02/28 22:10:17  ahundiak
 *	ah
 *	
 *	Revision 1.17  2002/02/28 21:03:57  ad
 *	Remove VSvalidate as second entry within the MAKE_SP section.
 *	
 *	Revision 1.16  2002/02/06 22:35:45  jayadev
 *	ppl to validate operation graph for features w.r.t consumed state
 *	
 *	Revision 1.15  2002/02/05 15:30:10  ahundiak
 *	ah
 *	
 *	Revision 1.14  2001/11/08 23:51:05  ramarao
 *	Implemented CR# 5437.
 *	
 *	Revision 1.13  2001/11/08 02:49:39  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.12  2001/10/13 17:11:41  ramarao
 *	Fixed TR# 5606.
 *	
 *	Revision 1.11  2001/08/17 23:58:07  jayadev
 *	build error correction
 *	
 *	Revision 1.10  2001/08/12 16:45:32  jayadev
 *	changes for CR# MP5495
 *	
 *	Revision 1.9  2001/05/01 21:27:38  jayadev
 *	ppl for detecting booplates without graphics
 *	
 *	Revision 1.8  2001/05/01 14:55:07  ramarao
 *	Fixed TR# 5140.
 *	
 *	Revision 1.7  2001/04/12 18:26:05  ramarao
 *	Fixed TR# 5015.
 *	
 *	Revision 1.6  2001/03/03 21:28:18  ramarao
 *	Implemented a PPL to recompute the bevels nicely.
 *	
 *	Revision 1.5  2001/02/15 14:24:12  ramarao
 *	Removed PC files.
 *	
 *	Revision 1.4  2001/02/14 20:58:05  jayadev
 *	ppl for etl#6459
 *	
 *	Revision 1.3  2001/01/18 14:38:19  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/17 14:58:59  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:10:02  cvs
 *	Initial import to CVS
 *	
# Revision 1.11  2000/03/07  16:26:02  pinnacle
# by ylong
#
# Revision 1.10  2000/02/29  16:40:28  pinnacle
# ylong
#
# Revision 1.9  2000/02/18  14:41:10  pinnacle
# ylong
#
# Revision 1.8  2000/02/17  20:06:50  pinnacle
# (No comment)
#
# Revision 1.7  2000/02/14  17:35:58  pinnacle
# Replaced: pplapp/vsapps.m for:  by impd252 for struct
#
# Revision 1.6  2000/02/11  21:11:24  pinnacle
# (No comment)
#
# Revision 1.5  2000/02/11  00:23:28  pinnacle
# ylong
#
# Revision 1.4  2000/02/07  14:32:20  pinnacle
# ylong
#
# Revision 1.3  2000/01/27  22:08:58  pinnacle
# (No comment)
#
# Revision 1.1  2000/01/21  23:04:56  pinnacle
# by ylong
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/20/00	ylong		creation
 *	02/07/00	ylong		added CObvl.u and bvlMac.u
 *	02/07/00	ylong		replaced CObvl.u by CObevel.u
 *					replaced bvlMac.u by Bevel.u
 *					added CObevelMod.u
 *	02/18/00	ylong		added EJ_Bevel.u & VA_Bevel.u
 *	02/29/00	ylong		added Fab_Stock.u
 *	03/07/00	ylong		added PlateSide.u
 *	02/14/01	Jayadev		added COz_pppThick.u 
 *	05/01/01	Jayadev		added COz_booplate.u 
 *      08/17/01        Jayadev         forced compiler to look for
 *                                      version.h in $(EXNUC)/include
 *                                      other than $SPXR/vrinclude
 *	05/08/02	ah		Removed COverBevel.u
 * -------------------------------------------------------------------*/

CCIOPT	-Xnoptrchk -Xnoargchk -m -q -I$(EXNUC)/include
#if ISDP_MAKE_SP
CObevel.u
CObevelMod.u
VSupdBevels.u
COz_booplate.u
COz_fixStr.u
COz_booFlip.u
VSvalidate.u
COz_unconsu.u
COz_valFeat.u
VSverBevel.u
#else
COz_booFlip.u
VSverBevel.u
COz_unconsu.u
COVSapps.u
skin_beam.u
COPartMark.u
PartMark.u
CObevelMod.u
CObevel.u
Bevel.u
EJ_Bevel.u
VA_Bevel.u
Fab_Stock.u
PlateSide.u
COcomp_chk.u
COmodBvlAttr.u
COneat_cont.u
COz_fixStr.u
VSreportStr.u
VSvalidate.u
change_bevel.u
feature_id.u
neat_cont.u
srf_rogue.u
COz_pppThick.u
VSupdBevels.u
COz_booplate.u
COz_valFeat.u
COz_proxml.u
#endif
