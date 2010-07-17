/* $Id: VLjigFunk2.I,v 1.2 2001/01/16 19:33:38 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	VLinteg/src/platejig / VLjigFunk2.I
 *
 * Description:	2nd group of functions for plate jigs.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLjigFunk2.I,v $
 *	Revision 1.2  2001/01/16 19:33:38  ramarao
 *	*** empty log message ***
 *	
# Revision 1.1  2000/04/10  16:38:06  pinnacle
# initial revision
#
# Revision 1.3  1999/04/09  21:34:26  pinnacle
# Rama Rao SP08
#
# Revision 1.2  1998/10/03  18:45:18  pinnacle
# tr179801478
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.4  1998/04/13  11:21:18  pinnacle
# Replaced: src/platejig/VLjigFunk2.I for:  by rchennup for loft
#
# Revision 1.2  1998/02/06  20:40:46  pinnacle
# Replaced: src/platejig/VLjigFunk2.I for:  by rchennup for loft
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.3  1997/04/11  18:12:56  pinnacle
# Replaced: src/platejig/VLjigFunk2.I for: Use four edge contour VLfindPpPoint() by mfournie for loft
#
# Revision 1.2  1997/04/07  13:31:02  pinnacle
# Replaced: src/platejig/VLjigFunk2.I for: File header added, new vl$externalContour(), orientation  by mfournie for loft
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/04/97   mf		use vl$externalContour() in VLfindPpPoint().
 *	04/07/97   mf		header creation.
 *	04/07/97   mf		orientation problem in VLfindPpPoint().
 *	04/11/97   mf		Use four edge contour  VLfindPpPoint().
 *      09/09/98   RC		orientation problem in VLfindPpPoint(). TR179801478
 *      04/09/99   ah           Rama Rao SP08 Fixes
 *************************************************************************/
/*f <VLjigFunk.I> contains a set of functions used to compute general operations
    in the plate_jigs construction workflow. */

class implementation VLabstract;

#include        <stdio.h>
#include        <math.h>
#include        "vlprototype.h"
#include        "OMerrordef.h"
#include        "OMindex.h"
#include        "AS_status.h"
#include        "grmacros.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"
#include        "grdpb.h"
#include        "gotextdef.h"
#include        "maerr.h"
#include        "bs.h"
#include        "bsparameters.h"
#include        "bsconic.h"
#include        "msdef.h"
#include        "EMSmsgdef.h"
#include        "EMSssprops.h"
#include        "EMSdpb.h"
#include        "dpezmac.h"
#include        "asmacros.h"
#include        "DIdef.h"
#include        "math.h"
#include        "cotxmacros.h"
#include        "ACattrib.h"
#include        "fontdef.h"
#include        "fontmacros.h"
#include        "grmessage.h"

#include        "vsplatedef.h"
#include        "vsmiscmacros.h"

#include        "vlplatejig.h"
#include        "vltablejig.h"
#include        "vlmiscmacros.h"
#include        "vlcontmacros.h"

#include	"bscrossp.h"
#include	"bsdotp.h"
#include	"bsnorvec.h"
#include	"mamulmx.h"

extern	IGRdouble	fabs();

extern	GRclassid	OPP_ACrg_collect_class_id, OPP_SMInfPlane_class_id;

from	ACrg_collect    import  AClist_attribute, ACset_list_attribute;
from	GRgencs		import	GRgetmatrix;
from    SMframe         import  SMfind_frm_syst, SMgive_rel_position;
from    SMfrm_syst      import  SMfind_near_frame, SMfind_frame_objid;

static	IGRboolean rev;

/*
#define	TRACE
*/

/* ========================================================================== */
IGRlong VLupdateId ( msg, NewId, NewEnv, idx, Env, Obj)

/*d This function updates an object with a new one */

/*h 27/05/1994 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;		/*O Completion code           */
	struct	GRid		*NewId;		/*I Tentative object	      */
	struct	GRmd_env	*NewEnv;	/*I Current module info	      */
		IGRint		idx;		/*I No update if == -1	      */
	struct	GRmd_env	*Env;		/*I Current module info	      */
	struct	GRid		*Obj;		/*O Existing copy in Env      */
{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS;

	/* Delete old object and copy the new one if needed */
	if (idx != -1) {
		if (Obj->objid != NULL_OBJID)
			sts = gr$delete_object ( msg          = msg,
                                                 md_env       = Env,
                                                 object_id    = Obj,
                                                 display_flag = 0 );

		sts = gr$copy_object ( msg          = msg,
                                       object_id    = NewId,
                                       md_env       = NewEnv,
                                       new_env      = Env,
                                       new_id       = Obj,
                                       display_flag = 0 );
	}

	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLtwoEdgesInDirection
(
	IGRlong		*msg,		/*O Completion code          */
struct	GRmd_env	*Env,		/*I Current module info	     */
	IGRint		nplt,		/*I Number of VS plates	     */
struct	GRobj_env	Plate[],	/*I Array of VS plates       */
	IGRdouble	Axis[],		/*I Ship axis (X,Y or Z)     */
struct	GRobj_env	*Nedge,		/*O Nearest edge	     */
struct	GRobj_env	*Fedge		/*O Farest edge		     */
)
{
	IGRlong		sts=OM_S_SUCCESS, loc_msg;
	IGRint		num=0, i, j, idx, Nidx=-1, Fidx=-1;
struct	GRobj_env	*edge=NULL;
struct	EdgeWork {
	IGRdouble	dot;
	IGRboolean	low;
	IGRdouble	dst;
};
struct	EdgeWork	EW[4];
	IGRpoint	spt, ept, nullpt;
	IGRdouble	dst, max_dist;

	/* Initialize */
	nullpt[0] = nullpt[1] = nullpt[2] = 0.0;

	/* Extract external 4 edges contour from VSplates */
	sts = vl$externalContour ( msg	= msg,
				   num	= nplt,
				   Plat = Plate,
				   side = VS_K_plTopSfPath,
				   Env	= Env,
				   Four = TRUE,
				   nEdg	= &num,
				   Edge	= &edge );
	if (num != 4) {
		printf( "Error in vl$externalContour() returning %d edges\n",
			num );
		*msg = MSFAIL;
	}
	as$status ( sts    = sts,
                    msg    = "vl$externalContour()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Find the two edges most parallel to Axis */
	for ( i=0; i<num; i++ ) {
		EW[i].low = TRUE;

		sts = vl$dotProduct ( msg  = msg,
				      crv1 = &edge[i],
				      vec2 = Axis,
				      dot  = &dst );
		as$status ( sts    = sts,
	                    msg    = "vl$externalContour()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		EW[i].dot = fabs (dst);

		sts = VLendpts ( msg, &edge[i].obj_id, &edge[i].mod_env,
				 spt, ept );
		as$status ( sts    = sts,
	                    msg    = "VLendpts()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		EW[i].dst = VLdistance ( spt, nullpt )
			  + VLdistance ( ept, nullpt );
	}
/* Start Correction - Added for 179702458 */

	idx = 0;
	max_dist = -1.0e+10;
	for( i=0; i<num; ++i )
	{
	  if( EW[i].dot > max_dist )
	  {
	      idx = i;
	      max_dist = EW[i].dot;
	  }
	}
	EW[idx].low = FALSE;

	idx = 0;
	max_dist = -1.0e+10;
	for( i=0; i<num; ++i )
	{
	  if( EW[i].low == TRUE && ( EW[i].dot > max_dist ) )
	  {
	      idx = i;
	      max_dist = EW[i].dot;
	  }
	}
	EW[idx].low = FALSE;

/* End Correction - Added for 179702458 */

/*
	for ( i=0; i<2; i++ ) {
		if (EW[i].low == TRUE) {
			idx = i;
			for ( j=0; j<num; j++ ) {
				if (  (j != i)
				   && (EW[j].low == TRUE)
				   && (EW[j].dot > EW[idx].dot) )	idx = j;
			}
			EW[idx].low = FALSE;
		}
	}
*/
	/* Find Nearest edge */
	dst=1.0e+36;
	for ( i=0; i<num; i++ ) {
		if (EW[i].low == FALSE) {
			if (EW[i].dst < dst) {
				dst = EW[i].dst;
				Nidx = i;
			}
		}
	}
	*Nedge = edge[Nidx];

	/* Find Farest edge */
	for ( i=0; i<num; i++ ) {
		if ( (i != Nidx) && (EW[i].low == FALSE) ) {
			Fidx = i;
			i = num;
		}
	}
	*Fedge = edge[Fidx];

wrapup:
	if (edge) {
		for ( i=0; i<num; i++ ) {
			if (  (i != Nidx) && (i != Fidx)
			   && (edge[i].obj_id.objid != NULL_OBJID) )
				gr$delete_object (
					msg		= &loc_msg,
					md_env		= &edge[i].mod_env,
					object_id	= &edge[i].obj_id,
					display_flag	= 0 );
		}
		om$dealloc (ptr = edge);
		edge = NULL;
	}

	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLorderEndpointInDirection
(
	IGRlong		*msg,		/*O Completion code          */
struct	GRobj_env	*Edg,		/*I Edge object		     */
	IGRdouble	Axis[],		/*I Ship axis (X,Y or Z)     */
	IGRpoint	*Pnt,		/*I Ordered endpoints	     */
	IGRdouble	*Dst		/*O Ordered distances	     */
)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRpoint	spt, ept, val;

	/* Get edge endpts */
	sts = VLendpts ( msg, &Edg->obj_id, &Edg->mod_env, spt, ept );
	as$status ( sts    = sts,
		    msg    = "VLendpts()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Work on start point */
	sts = vl$dotProduct ( msg  = msg,
			      vec1 = spt,
			      nor1 = 0,
			      vec2 = Axis,
			      dot  = &val[0] );
	as$status ( sts    = sts,
		    msg    = "vl$dotProduct()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	val[1] = fabs (val[0]);

	/* Work on end point */
	sts = vl$dotProduct ( msg  = msg,
			      vec1 = ept,
			      nor1 = 0,
			      vec2 = Axis,
			      dot  = &val[0] );
	as$status ( sts    = sts,
		    msg    = "vl$dotProduct()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	val[2] = fabs (val[0]);

	/* Order */
	if (val[1] <= val[2]) {
		Pnt[0][0] = spt[0];
		Pnt[0][1] = spt[1];
		Pnt[0][2] = spt[2];
		Pnt[1][0] = ept[0];
		Pnt[1][1] = ept[1];
		Pnt[1][2] = ept[2];
		Dst[0] = val[1];
		Dst[1] = val[2];
	}
	else {	Pnt[0][0] = ept[0];
		Pnt[0][1] = ept[1];
		Pnt[0][2] = ept[2];
		Pnt[1][0] = spt[0];
		Pnt[1][1] = spt[1];
		Pnt[1][2] = spt[2];
		Dst[0] = val[2];
		Dst[1] = val[1];
	}

wrapup:
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLfindPpPoint ( msg, Fplane, Env, nplt, Plate, Ax, Middle, Space,
			PP_id, Ppnt, Pnum)

/*d This function finds the PP point. */

/*h 28/04/1993 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;		/*O Completion code          */
	struct	GRobj_env	*Fplane;	/*I SMAN frame system plane  */
	struct	GRmd_env	*Env;		/*I Current module info	     */
		IGRint		nplt;		/*I Number of VS plates	     */
	struct	GRobj_env	Plate[];	/*I Array of VS plates       */
		IGRdouble	Ax[];		/*I Ship axis (X,Y or Z)     */
		IGRdouble	Middle;		/*I Middle ship value	     */
		IGRdouble	Space;		/*I Spacing given by user    */
	struct	GRid		*PP_id;		/*O PP point object	     */
		IGRdouble	Ppnt[];		/*O PP point coordinates     */
		IGRint		*Pnum;		/*O Template_jigs max number */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, suc=OM_S_SUCCESS;
	struct	GRid		Point;
		IGRdouble	D1, D2, Dcor1, Dcor2, Dnew, v[8], Axis[3], pt[3];
		IGRdouble	CurrPt[4], FsysPt1[4], FsysPt2[4], Pgeom[3];
	struct	GRid		tmp_id, cs_id, pl_id;
		IGRmatrix	cs_mat;
	struct	IGRplane	plane, inf_pl;
		IGRpoint	point;
		IGRvector	normal;
		BSrc		rc;
	struct	GRid		Fsyst, Fdist;
		IGRdouble	delta;
		IGRint		fr_num, i;
		IGRint		bwd_idx;
		IGRlong		loc_msg;
	struct	GRobj_env	Nedge, Fedge, Edge;
		IGRvector	Faxe, nullvec;
		IGRshort	one=1, four=4;
		IGRpoint	pnt[4];
		IGRdouble	val[6];	/* 0	Nearest edge minimum dist.
					   1	Nearest edge maximum dist.
					   2	Farest edge minimum dist.
					   3	Farest edge maximum dist.
					   4	Minimum distance.
					   5	Maximum distance.
					*/
	/* Initialize */
	Fsyst.objid  = Fdist.objid = NULL_OBJID;
	Fsyst.osnum  = Fdist.osnum = Fplane->mod_env.md_id.osnum;
	Point.objid  = NULL_OBJID;
	Point.osnum  = Env->md_id.osnum;
	Nedge.obj_id.objid = Fedge.obj_id.objid = NULL_OBJID;
	rev = FALSE;

	/* Previously, Axis used to be x-axis always.Because of a bug 
	   ( See TR#179702459 ), Axis is determined by Frame. - Rama Rao */

	/* START CORRECTION */

	inf_pl.point  = &pt[0];
	inf_pl.normal = &Axis[0];

        sts = om$send( msg = message GRvg.GRdetplane(
                                        msg,
                                        &Fplane->mod_env.md_env.matrix_type,
                                        Fplane->mod_env.md_env.matrix,
                                        &inf_pl ),
                         senderid = NULL_OBJID,
                         targetid = Fplane->obj_id.objid,
                         targetos = Fplane->obj_id.osnum );
	as$status ( sts    = sts,
                    msg    = "GRvg.GRdetplane()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* END CORRECTION */

	/* Get Nearest & Farest edges */
	sts = VLtwoEdgesInDirection ( msg, Env, nplt, Plate, Axis,
				      &Nedge, &Fedge );
	as$status ( sts    = sts,
                    msg    = "VLtwoEdgesInDirection()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get and order Nearest edges endpts */
	sts = VLorderEndpointInDirection ( msg, &Nedge, Axis,
					   &pnt[0], &val[0] );
	as$status ( sts    = sts,
		    msg    = "VLorderEndpointInDirection(Nearest)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Get and order Farest edges endpts */
	sts = VLorderEndpointInDirection ( msg, &Fedge, Axis,
					   &pnt[2], &val[2] );
	as$status ( sts    = sts,
		    msg    = "VLorderEndpointInDirection(Farest)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Evaluate minimum and maximum distances */
	val[4] = val[0];
	val[5] = val[1];
	for ( i=0; i<4; i++ ) {
		if (val[i] < val[4])	val[4] = val[i];
		if (val[i] > val[5])	val[5] = val[i];
	}

	if (Axis[0] == 1.0) {
		if (val[1] <= Middle) {
			bwd_idx = 1;
			D1=val[0];
			D2=val[1];
			Edge = Nedge;	}
		else if (val[2] >= Middle) {
			bwd_idx = -1;
			D1=val[3];
			D2=val[2];
			Edge =Fedge;	}
		else { 	printf( "Plates Range [%g,%g] include Middle Ship %g\n",
				val[4], val[5], Middle);
			bwd_idx = -1;
			D1=val[5];
			D2=val[4];
			Edge =Fedge;	}
	}
	else {	bwd_idx=1;
		D1=val[5];
		D2=val[4];
		Edge=Fedge;	}

#ifdef TRACE
printf( "Working on distance D1=%g & D2=%g along axe [%g,%g,%g]\n",
	D1, D2, Axis[0], Axis[1], Axis[2]);
#endif
	/* Find Frame Plane foot <plane> */
	sts = vl$return_foot ( msg     = msg,
			       name    = "plane",
                               objId   = &Fplane->obj_id,
                               footId  = &pl_id );
	as$status ( sts    = sts,
                    msg    = "vl$return_foot<plane>",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get plane geometry */
	plane.point  = point;
	plane.normal = normal;
	sts = om$send ( msg      = message GRvg.GRdetplane (
					msg,
					&Env->md_env.matrix_type,
					Env->md_env.matrix,
					&plane ),
			senderid = NULL_OBJID,
			targetid = pl_id.objid,
			targetos = pl_id.osnum );
	as$status ( sts    = sts,
                    msg    = "GRvg.GRdetplane",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Find Frame Plane template <cs> */
	sts = om$send ( msg      = message ACcpx.ACfind_exp_temp_obj
                                                        ( &suc, 0, &tmp_id),
			senderid = NULL_OBJID,
			targetid = Fplane->obj_id.objid,
			targetos = Fplane->obj_id.osnum );
	as$status ( sts    = sts,
                    msg    = "ACcpx.ACfind_exp_temp_obj",
                    test   = (!(sts & 0x00000001 & suc)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	if( vs$is_ancestry_valid( object  = &tmp_id,
				  classid = OPP_SMInfPlane_class_id ) )
	{

	   struct GRid tmp_cs;
	   /* Find Frame Plane template <cs> */
	   sts = om$send ( msg      = message ACcpx.ACfind_exp_temp_obj
                                                        ( &suc, 0, &tmp_cs ),
			senderid = NULL_OBJID,
			targetid = tmp_id.objid,
			targetos = tmp_id.osnum );
	   as$status ( sts    = sts,
                       msg    = "ACcpx.ACfind_exp_temp_obj",
                       test   = (!(sts & 0x00000001 & suc)),
                       action = GOTO_VALUE,
                       value  = wrapup );
	   tmp_id = tmp_cs;
	}

	/* Get object */
	sts = vl$return_foot ( msg	= msg,
			       objId	= &tmp_id,
			       footId	= &cs_id );
	as$status ( sts    = sts,
                    msg    = "vl$return_foot()",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
	/* Get Frame System CS matrix */
	sts = om$send ( msg = message GRgencs.GRgetmatrix ( msg, cs_mat ),
			senderid = NULL_OBJID,
			targetid = cs_id.objid,
			targetos = cs_id.osnum );
	as$status ( sts    = sts,
                    msg    = "GRgencs.GRgetmatrix",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Convert Axis given for BaseCS into Frame system world */
	for ( i=0; i<3; i++)	v[i] = Axis[i];
	for ( i=3; i<8; i++)	v[i] = 0.0;
	MAmulmx ( &rc, &four, &four, &one, cs_mat, &v[0], &v[4] );
	for ( i=0; i<3; i++)	Faxe[i] = v[4+i];

	/* Convert computed distance in Frame system world */
	for ( i=0; i<3; i++)	CurrPt[i] = D1 * Faxe[i];
	CurrPt[3] = 1.0;
	if (!VDSconvert_coord( CurrPt, FsysPt1, 1, &cs_id, cs_mat) )
		{ *msg = MSFAIL; goto wrapup; }
#ifdef TRACE
printf( "Convert [%g,%g,%g]\t--> [%g,%g,%g]\n",
	 CurrPt[0], CurrPt[1], CurrPt[2], FsysPt1[0], FsysPt1[1], FsysPt1[2] );
#endif
	for ( i=0; i<3; i++)	CurrPt[i] = D2 * Faxe[i];
	if (!VDSconvert_coord( CurrPt, FsysPt2, 1, &cs_id, cs_mat) )
		{ *msg = MSFAIL; goto wrapup; }
#ifdef TRACE
printf( "Convert [%g,%g,%g]\t--> [%g,%g,%g]\n",
	 CurrPt[0], CurrPt[1], CurrPt[2], FsysPt2[0], FsysPt2[1], FsysPt2[2] );
#endif
	/* Evaluate real distances */
	if (BSdotp ( &rc, Faxe, Axis) >= 0.0) {
		Dcor1 = BSdotp ( &rc, Faxe, FsysPt1);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		Dcor2 = BSdotp ( &rc, Faxe, FsysPt2);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	}
	else {	Dcor1 = BSdotp ( &rc, Faxe, FsysPt2);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		Dcor2 = BSdotp ( &rc, Faxe, FsysPt1);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	}
#ifdef TRACE
printf( "Faxe = [%g,%g,%g], FsysPt1 = [%g,%g,%g]\t-->Dcor1 = %g\n",
	Faxe[0], Faxe[1], Faxe[2], FsysPt1[0], FsysPt1[1], FsysPt1[2], Dcor1);
printf( "Faxe = [%g,%g,%g], FsysPt2 = [%g,%g,%g]\t-->Dcor2 = %g\n",
	Faxe[0], Faxe[1], Faxe[2], FsysPt2[0], FsysPt2[1], FsysPt2[2], Dcor2);
#endif

	nullvec[0] = nullvec[1] = nullvec[2] = 0.0;
	/* Correct distances (if needed) */
	if (Axis[0] < 0.0) {
// 	if (BSdotp ( &rc, Faxe, plane.normal) <= 0.0) {
//	if (BSdotp ( &rc, Faxe, nullvec ) <= 0.0) {
		Dcor1 *= -1.0;
		Dcor2 *= -1.0;
	}

	/* Evaluate maximum number of template_jigs */
	*Pnum = 1 + (IGRint) fabs( (Dcor1 - Dcor2) / Space);
#ifdef TRACE
printf( "From %g to %g, there is %d template_jigs\n", Dcor1, Dcor2, *Pnum );
#endif
	/* Find SMAN frame system ID */
	sts = om$send ( msg	 = message SMframe.SMfind_frm_syst (msg,&Fsyst),
			senderid = NULL_OBJID,
			targetid = Fplane->obj_id.objid,
			targetos = Fplane->obj_id.osnum );
	as$status ( sts    = sts,
                    msg    = "SMframe.SMfind_frm_syst",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Find SMAN frame plane number at distance */
	fr_num = 0;
	delta  = 0.0;
	sts = om$send ( msg      = message SMfrm_syst.SMfind_near_frame
						( msg, Dcor1, &fr_num, &delta),
			senderid = NULL_OBJID,
			targetid = Fsyst.objid,
			targetos = Fsyst.osnum );
	if( !(sts&(*msg)&1) )
	{
 	  sts = om$send ( msg      = message SMfrm_syst.SMfind_near_frame
						( msg, (-1*Dcor1), &fr_num, &delta),
			senderid = NULL_OBJID,
			targetid = Fsyst.objid,
			targetos = Fsyst.osnum );
	  rev = TRUE;
	}

	as$status ( sts    = sts,
                    msg    = "SMfrm_syst.SMfind_near_frame",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "Distance %g --> Frame %d + %g\n", Dcor1, fr_num, delta);
#endif

	if ( (Axis[0] < 0.0) && !rev ) {
//	if (BSdotp ( &rc, Faxe, nullvec ) <= 0.0) {
	  --fr_num;
	}
	else if( rev==TRUE )
	{
	  ++fr_num;
	}

	/* Find SMAN frame plane ID at distance */
	sts = om$send ( msg      = message SMfrm_syst.SMfind_frame_objid
						( msg, fr_num, &Fdist ),
			senderid = NULL_OBJID,
			targetid = Fsyst.objid,
			targetos = Fsyst.osnum );
	as$status ( sts    = sts,
                    msg    = "SMfrm_syst.SMfind_frame_objid",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "Frame %d is (%d|%d)\n", fr_num, Fdist.osnum, Fdist.objid );
#endif

	/* Find SMAN frame plane relative position */
	sts = om$send ( msg      = message SMframe.SMgive_rel_position
						( msg, &Dnew),
			senderid = NULL_OBJID,
			targetid = Fdist.objid,
			targetos = Fdist.osnum );
	as$status ( sts    = sts,
                    msg    = "SMfrm_syst.SMgive_rel_position",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if (Dnew < 0.0)	Dnew *= -1.0;

	/* Create PP point */
	sts = VLcreatePtInter ( msg, &Fdist, &Fplane->mod_env, &Edge.obj_id,
				&Edge.mod_env, &Point, Env );
	as$status ( sts    = sts,
                    msg    = "VLcreatePtInter()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	sts = VLcreateDblInter ( msg, &Fdist, &Fplane->mod_env, &Edge.obj_id,
				 &Edge.mod_env, Pgeom, Env );
	as$status ( sts    = sts,
                    msg    = "VLcreatePtInter()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "PP point : (%d|%d) is (%g,%g,%g)\n",
	Point.osnum, Point.objid, Pgeom[0], Pgeom[1], Pgeom[2] );
#endif
	if (PP_id) 	*PP_id = Point;
	else		gr$delete_object ( msg          = &loc_msg,
                                   	   md_env       = Env,
                                   	   object_id    = &Point,
                                   	   display_flag = 0 );
	if (Ppnt)	dblcpy ( Ppnt, Pgeom, 3);

wrapup:
	if (Nedge.obj_id.objid != NULL_OBJID)
		gr$delete_object ( msg          = &loc_msg,
				   md_env       = &Nedge.mod_env,
				   object_id    = &Nedge.obj_id,
				   display_flag = 0 );
	if (Fedge.obj_id.objid != NULL_OBJID)
		gr$delete_object ( msg          = &loc_msg,
				   md_env       = &Fedge.mod_env,
				   object_id    = &Fedge.obj_id,
				   display_flag = 0 );

	return (sts);

/* End of function */
}
/* ========================================================================== */
IGRlong VLsetPlateJigMgrAttr ( msg, value, Attr)

/*d This function builds the parameter box template of VLjigMgr */ 

/*h 20/05/1994 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;	 /*O Completion code                  */
		IGRdouble	value[]; /*I Array of parameters values	      */
	struct	GRid		*Attr;	 /*O Parameter box		      */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i;
	struct	ACrg_coll	attr[NUM_PM_ATTR];

	/* Set the names */
	strcpy ( attr[IDX_PM_GRD].name,  NAM_PM_GRD);
	strcpy ( attr[IDX_PM_EXT1].name, NAM_PM_EXT1);
	strcpy ( attr[IDX_PM_EXT2].name, NAM_PM_EXT2);
	strcpy ( attr[IDX_PM_HOLE].name, NAM_PM_HOLE);
	strcpy ( attr[IDX_PM_INV].name,  NAM_PM_INV);
	strcpy ( attr[IDX_PM_MID].name,  NAM_PM_MID);
	strcpy ( attr[IDX_PM_TYPE].name, NAM_PM_TYPE);
	strcpy ( attr[IDX_PM_OSET].name, NAM_PM_OSET);
	strcpy ( attr[IDX_PM_SPAC].name, NAM_PM_SPAC);
	strcpy ( attr[IDX_PM_NPLT].name, NAM_PM_NPLT);
	strcpy ( attr[IDX_PM_NFRM].name, NAM_PM_NFRM);
	strcpy ( attr[IDX_PM_CODE].name, NAM_PM_CODE);
	strcpy ( attr[IDX_PM_NLIN].name, NAM_PM_NLIN);
	strcpy ( attr[IDX_PM_GROP].name, NAM_PM_GROP);
	strcpy ( attr[IDX_PM_STOP].name, NAM_PM_STOP);
	strcpy ( attr[IDX_PM_STWI].name, NAM_PM_STWI);
	strcpy ( attr[IDX_PM_DIR].name, NAM_PM_DIR );

	/* Set the names */
	for ( i=0; i<NUM_PM_ATTR; i++)  attr[i].desc.type = AC_ATTRIB_DOUBLE;

	/* Set the values */
	attr[IDX_PM_GRD].desc.value.att_exp  = value[IDX_PM_GRD];
	attr[IDX_PM_EXT1].desc.value.att_exp = value[IDX_PM_EXT1];
	attr[IDX_PM_EXT2].desc.value.att_exp = value[IDX_PM_EXT2];
	attr[IDX_PM_HOLE].desc.value.att_exp = value[IDX_PM_HOLE];
	attr[IDX_PM_INV].desc.value.att_exp  = value[IDX_PM_INV];
	attr[IDX_PM_MID].desc.value.att_exp  = value[IDX_PM_MID];
	attr[IDX_PM_TYPE].desc.value.att_exp = value[IDX_PM_TYPE];
	attr[IDX_PM_OSET].desc.value.att_exp = value[IDX_PM_OSET];
	attr[IDX_PM_SPAC].desc.value.att_exp = value[IDX_PM_SPAC];
	attr[IDX_PM_NPLT].desc.value.att_exp = value[IDX_PM_NPLT];
	attr[IDX_PM_NFRM].desc.value.att_exp = value[IDX_PM_NFRM];
	attr[IDX_PM_CODE].desc.value.att_exp = value[IDX_PM_CODE];
	attr[IDX_PM_NLIN].desc.value.att_exp = value[IDX_PM_NLIN];
	attr[IDX_PM_GROP].desc.value.att_exp = value[IDX_PM_GROP];
	attr[IDX_PM_STOP].desc.value.att_exp = value[IDX_PM_STOP];
	attr[IDX_PM_STWI].desc.value.att_exp = value[IDX_PM_STWI];
	attr[IDX_PM_DIR].desc.value.att_exp = value[IDX_PM_DIR];

	/* Create parameter box : construct */
        om$construct ( classid = OPP_ACrg_collect_class_id,
                       osnum   = Attr->osnum,
                       p_objid = &Attr->objid );

        /* Create parameter box : setting */
        sts = om$send ( msg = message ACrg_collect.ACset_list_attribute
                                        ( msg, NUM_PM_ATTR, attr),
                        senderid = NULL_OBJID,
                        targetid = Attr->objid,
                        targetos = Attr->osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACset_list_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);

/* End of function */
}
/* ========================================================================== */
IGRlong VLgetPlateJigMgrAttr ( msg, value, Attr)

/*d This function retrieves the parameter box template of VLjigMgr.
    The caller must allow NUM_PM_ATTR * IGRdouble in <value> */ 

/*h 20/05/1994 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;	 /*O Completion code                  */
		IGRdouble	value[]; /*O Array of parameters values	      */
	struct	GRid		*Attr;	 /*I Parameter box		      */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i, num;
	struct	ACrg_coll	attr[NUM_PM_ATTR];

	/* Get the parameter box */
        sts = om$send ( msg = message ACrg_collect.AClist_attribute
                                        ( msg, NUM_PM_ATTR, attr, &num),
                        senderid = NULL_OBJID,
                        targetid = Attr->objid,
                        targetos = Attr->osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.AClist_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
	/* Fill the output array */
	if (num != NUM_PM_ATTR) {
		printf( "Wait %d parameters and get %d\n", NUM_PM_ATTR, num);
		sts = MSFAIL;
		goto wrapup;
	}
	for ( i=0; i<NUM_PM_ATTR; i++)
		value[i] = attr[i].desc.value.att_exp;


wrapup:
	return (sts);

/* End of function */
}
/* ========================================================================== */
IGRlong VLsetPlateJigObjAttr ( msg, value, Attr)

/*d This function builds the parameter box template of VLjigObj */ 

/*h 24/05/1994 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;	 /*O Completion code                  */
		IGRdouble	value[]; /*I Array of parameters values	      */
	struct	GRid		*Attr;	 /*O Parameter box		      */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i;
	struct	ACrg_coll	attr[NUM_PO_ATTR];

	/* Set the names */
	strcpy ( attr[IDX_PO_REAL].name, NAM_PO_REAL);
	strcpy ( attr[IDX_PO_EXT1].name, NAM_PO_EXT1);
	strcpy ( attr[IDX_PO_EXT2].name, NAM_PO_EXT2);
	strcpy ( attr[IDX_PO_HOLE].name, NAM_PO_HOLE);
	strcpy ( attr[IDX_PO_INV].name,  NAM_PO_INV);
	strcpy ( attr[IDX_PO_MID].name,  NAM_PO_MID);
	strcpy ( attr[IDX_PO_TYPE].name, NAM_PO_TYPE);
	strcpy ( attr[IDX_PO_OSET].name, NAM_PO_OSET);
	strcpy ( attr[IDX_PO_NSRF].name, NAM_PO_NSRF);
	strcpy ( attr[IDX_PO_NLIN].name, NAM_PO_NLIN);
	strcpy ( attr[IDX_PO_STOP].name, NAM_PO_STOP);
	strcpy ( attr[IDX_PO_STWI].name, NAM_PO_STWI);
	strcpy ( attr[IDX_PO_ORDR].name, NAM_PO_ORDR);
	strcpy ( attr[IDX_PO_XCOG].name, NAM_PO_XCOG);
	strcpy ( attr[IDX_PO_YCOG].name, NAM_PO_YCOG);
	strcpy ( attr[IDX_PO_ZCOG].name, NAM_PO_ZCOG);
	strcpy ( attr[IDX_PO_XNRM].name, NAM_PO_XNRM);
	strcpy ( attr[IDX_PO_YNRM].name, NAM_PO_YNRM);
	strcpy ( attr[IDX_PO_ZNRM].name, NAM_PO_ZNRM);

	/* Set the names */
	for ( i=0; i<NUM_PO_ATTR; i++)  attr[i].desc.type = AC_ATTRIB_DOUBLE;

	/* Set the values */
	attr[IDX_PO_REAL].desc.value.att_exp = value[IDX_PO_REAL];
	attr[IDX_PO_EXT1].desc.value.att_exp = value[IDX_PO_EXT1];
	attr[IDX_PO_EXT2].desc.value.att_exp = value[IDX_PO_EXT2];
	attr[IDX_PO_HOLE].desc.value.att_exp = value[IDX_PO_HOLE];
	attr[IDX_PO_INV].desc.value.att_exp  = value[IDX_PO_INV];
	attr[IDX_PO_MID].desc.value.att_exp  = value[IDX_PO_MID];
	attr[IDX_PO_TYPE].desc.value.att_exp = value[IDX_PO_TYPE];
	attr[IDX_PO_OSET].desc.value.att_exp = value[IDX_PO_OSET];
	attr[IDX_PO_NSRF].desc.value.att_exp = value[IDX_PO_NSRF];
	attr[IDX_PO_NLIN].desc.value.att_exp = value[IDX_PO_NLIN];
	attr[IDX_PO_STOP].desc.value.att_exp = value[IDX_PO_STOP];
	attr[IDX_PO_STWI].desc.value.att_exp = value[IDX_PO_STWI];
	attr[IDX_PO_ORDR].desc.value.att_exp = value[IDX_PO_ORDR];
	attr[IDX_PO_XCOG].desc.value.att_exp = value[IDX_PO_XCOG];
	attr[IDX_PO_YCOG].desc.value.att_exp = value[IDX_PO_YCOG];
	attr[IDX_PO_ZCOG].desc.value.att_exp = value[IDX_PO_ZCOG];
	attr[IDX_PO_XNRM].desc.value.att_exp = value[IDX_PO_XNRM];
	attr[IDX_PO_YNRM].desc.value.att_exp = value[IDX_PO_YNRM];
	attr[IDX_PO_ZNRM].desc.value.att_exp = value[IDX_PO_ZNRM];

	/* Create parameter box : construct */
        om$construct ( classid = OPP_ACrg_collect_class_id,
                       osnum   = Attr->osnum,
                       p_objid = &Attr->objid );

        /* Create parameter box : setting */
        sts = om$send ( msg = message ACrg_collect.ACset_list_attribute
                                        ( msg, NUM_PO_ATTR, attr),
                        senderid = NULL_OBJID,
                        targetid = Attr->objid,
                        targetos = Attr->osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACset_list_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);

/* End of function */
}
/* ========================================================================== */
IGRlong VLgetPlateJigObjAttr ( msg, value, Attr)

/*d This function retrieves the parameter box template of VLjigObj.
    The caller must allow NUM_PO_ATTR * IGRdouble in <value> */ 

/*h 24/05/1994 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;	 /*O Completion code                  */
		IGRdouble	value[]; /*O Array of parameters values	      */
	struct	GRid		*Attr;	 /*I Parameter box		      */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i, num;
	struct	ACrg_coll	attr[NUM_PO_ATTR];

	/* Get the parameter box */
        sts = om$send ( msg = message ACrg_collect.AClist_attribute
                                        ( msg, NUM_PO_ATTR, attr, &num),
                        senderid = NULL_OBJID,
                        targetid = Attr->objid,
                        targetos = Attr->osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.AClist_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
	/* Fill the output array */
	if (num != NUM_PO_ATTR) {
		printf( "Wait %d parameters and get %d\n", NUM_PO_ATTR, num);
		sts = MSFAIL;
		goto wrapup;
	}
	for ( i=0; i<NUM_PO_ATTR; i++)
		value[i] = attr[i].desc.value.att_exp;

wrapup:
	return (sts);

/* End of function */
}
/* ========================================================================== */
IGRlong VLbuildJigFixPlane(msg, Klin, Ppnt, Bpln, typ, mid, ord, spa, Env, Plan)

/*d This function constructs the intersecting plane in the fix grid case */

/*h 25/05/1994 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;		/*O Completion code	      */
	struct	GRid		*Klin;		/*I Control line	      */
		IGRdouble	Ppnt[];		/*I The famous PP point	      */
		IGRdouble	Bpln[];		/*I Avg. cog and normal	      */
		IGRint		typ;		/*I Jig type (IDX_J[123])     */
		IGRdouble	mid;		/*I Middle ship X value	      */
		IGRint		ord;		/*I Order in the construction */
		IGRdouble	spa;		/*I Space between planes      */
	struct	GRmd_env	*Env;		/*I Current module info	      */
	struct	GRid		*Plan;		/*O Output plane	      */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i, ori=1;
		IGRdouble	Xpln[6], prod;
		IGRvector	n, Xvec, Yvec;
	struct	IGRplane	Kplane;
		IGRpoint	p;
		BSrc		rc;
	struct	GRvg_construct	cst;

	/* Initialize */
	for ( i=0; i<3; i++)	Xvec[i] = Yvec[i] = 0.0;
	Xvec[0] = Yvec[1] = 1.0;
	Kplane.point  = p;
	Kplane.normal = n;
	VLinitCnst (&cst);
	cst.env_info = Env;

	/* Retrieve PP point coordinates */
        dblcpy ( Xpln, Ppnt, 3);
#ifdef TRACE
printf( "PP point is [%g,%g,%g] and Middle = %g\n", 
	Xpln[0], Xpln[1], Xpln[2], mid);
#endif

	/* Extract plane of the control line */
        sts = VLdetplane ( msg, Klin, Env, &Bpln[3], Xvec, &Kplane);
        as$status ( sts    = sts,
                    msg    = "VLdetplane()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "Kplane is [%g,%g,%g] & [%g,%g,%g]\n",
	Kplane.point[0], Kplane.point[1], Kplane.point[2],
	Kplane.normal[0], Kplane.normal[1], Kplane.normal[2] );
#endif

	/* Set control plane normal to Y in non Shell/Wall case */
        if (typ != IDX_J3) {
                prod = BSdotp ( &rc, Kplane.normal, Yvec);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
                dblcpy ( Kplane.normal, Yvec, 3);
                if (prod < 0.0) for ( i=0; i<3; i++) Kplane.normal[i] *= -1.0;
        }

	/* Take in account the middle ship X value 
	if (fabs(BSdotp( &rc, Xpln, Xvec) ) >= mid) {
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		ori *= -1;
	}
	*/

	if ((BSdotp( &rc, Xpln, Xvec) ) >= 0.0 ) {
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		ori *= -1;
	}

	if( rev == TRUE ) ori *= -1;

	/* Construct section plane */
        BScrossp ( &rc, &Bpln[3], Kplane.normal, &Xpln[3]);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
        BSnorvec ( &rc, &Xpln[3]);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
        for ( i=0; i<3; i++)    Xpln[i] += ori * ord * spa * Xpln[i+3];
#ifdef TRACE
printf( "Section plane is [%g,%g,%g] & [%g,%g,%g]\n",
	Xpln[0], Xpln[1], Xpln[2], Xpln[3], Xpln[4], Xpln[5] );
#endif

	/* Create the section plane */
	sts = VLcreatePlane ( &Xpln[0], &Xpln[3], Env, &cst, Plan, msg);
        as$status ( sts    = sts,
                    msg    = "VLcreatePlane()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);

/* End of function */
}
/* ========================================================================== */

end implementation VLabstract;
