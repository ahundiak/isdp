/* $Id: macros.m,v 1.9 2001/10/04 22:15:58 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/cimacros/wireframe/macros / macros.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: macros.m,v $
 *	Revision 1.9  2001/10/04 22:15:58  hans
 *	Fix for TR# MP5171
 *	
 *	Revision 1.8  2001/09/07 15:27:53  ramarao
 *	Implemented CR# 5346.
 *	
 *	Revision 1.7  2001/09/05 15:06:21  jayadev
 *	length check for components of merge curve for chtol
 *	
 *	Revision 1.6  2001/07/21 15:40:03  ad
 *	*** empty log message ***
 *	
 *	Revision 1.5  2001/07/21 15:07:51  ad
 *	*** empty log message ***
 *	
 *	Revision 1.4  2001/07/12 20:21:44  jayadev
 *	TR#MP5406
 *	
 *	Revision 1.3  2001/04/19 18:09:25  ramarao
 *	Fixed TR# 4484.
 *	
 *	Revision 1.2  2001/04/02 22:48:51  ramarao
 *	Fixed TR# 4999
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:22  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  2000/02/14  17:37:22  pinnacle
# Replaced: cimacros/wireframe/macros/macros.m for:  by impd252 for vds
#
# Revision 1.2  2000/02/14  16:54:52  pinnacle
# Replaced: cimacros/wireframe/macros/macros.m for:  by impd252 for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/02/09  16:52:36  pinnacle
# ah
#
# Revision 1.2  1997/07/17  20:07:22  pinnacle
# Replaced: cimacros/wireframe/macros/macros.m for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/09/03  18:20:36  pinnacle
# Replaced: cimacros/wireframe/macros/macros.m for:  by v241_int for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/07/25  21:28:34  pinnacle
# Replaced: cimacros/wireframe/macros/*.m for:  by jwfrosch for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *	09/03/96	ah		Added pardel1.u 
 *	02/09/98	ah		Added VDinterf_cvs.u
 *	02/14/00	jvh		Added crv_fill.u
 *	07/21/01	adz		Added area_prop.u (MP5440)
 *	10/04/2001	jwf		Fix for TR# MP5171
 * -------------------------------------------------------------------*/

CCIOPT	-Xnoptrchk -Xnoargchk -m -q
#if ISDP_MAKE_SP
area_prop.u
mass_prop.u
crv_roll.u
crv_pro_n.u
crv_pro_v.u
crv_merge.u
crv_merge_c.u
int_2_elem.u
#else
arc_3pts.u
arc_c2pts.u
area_prop.u
bib_hole.u
ci_mac_bib.u
cir_3pts.u
cir_c2pts.u
collision.u
conic.u
copy.u
cpyalong.u
cpymap.u
cpymir.u
cpymov.u
cpyrot.u
cpyscl.u
crv_bend.u
crv_blend.u
crv_comp.u
crv_dfc_l.u
crv_dfc_p.u
crv_ev_rad.u
crv_fillet.u
crv_fill.u
crv_helix.u
crv_iso.u
crv_lsq_l.u
crv_merge.u
crv_merge_c.u
crv_offset.u
crv_parab.u
crv_pdel.u
crv_pole_p.u
crv_pro_n.u
crv_pro_v.u
crv_roll.u
crv_split.u
crv_spring.u
ell_arc_c.u
ell_axis.u
ell_cent.u
int_2_elem.u
leng_prop.u
mass_prop.u
midpnts.u
src_obj.u
nboolean.u
nors.u
pnt_pro_v.u
pnts.u
poly_nside.u
pt_pos.u
string.u
warea.u
VDSmass.u
pardel.u
pardel1.u
crv_prtlin.u
extelm.u
format_param.u
scal_pro_v.u
lstn2cvs.u
prbtn2cvs.u
crv_corner.u
crv_extract.u
crv_hgen.u
VDinterf_cvs.u
#endif
