/* $Id: macros.m,v 1.3 2001/11/05 16:44:07 jayadev Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/cimacros/surface/macros / macros.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: macros.m,v $
 *	Revision 1.3  2001/11/05 16:44:07  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/05/31 18:25:42  ad
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:21  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/02/17  20:01:12  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/07/17  20:14:52  pinnacle
# Replaced: cimacros/surface/macros/macros.m for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/23  15:09:02  pinnacle
# Replaced: cimacros/surface/macros/macros.m for:  by v240_int for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

CCIOPT        -Xnoargchk -m -q
#if ISDP_MAKE_SP
pla_offext.u
srf_rev.u
#else
int_2_pla.u
int_3_pla.u
int_4_pla.u
pla_bissec.u
pla_encomp.u
pla_ntocrv.u
pla_offext.u
pla_para.u
pla_rect.u
pla_tgt.u
ref_by3pla.u
ref_bypla.u
srf_2blend.u
srf_4bdry.u
srf_Hmiter.u
srf_bend.u
srf_comp.u
srf_cone.u
srf_cyl.u
srf_dcyl.u
srf_dfc.u
srf_ext.u
srf_fillet.u
srf_mblend.u
srf_merge.u
srf_miter.u
srf_netwrk.u
srf_offext.u
srf_offset.u
srf_pro.u
srf_rev.u
srf_ruled.u
srf_skin.u
srf_skin2.u
srf_skin3.u
srf_skin4.u
srf_skin_n.u
srf_sphere.u
srf_torus.u
srf_tube.u
int_sf_pl.u
srf_part.u
ext_bound.u
rev_normal.u
comp_flg.u
comp_web.u
srf_hgencv.u
srf_tangents.u
#endif
