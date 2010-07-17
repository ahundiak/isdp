/* $Id: VLmiscFunk.I,v 1.3 2001/02/27 17:26:16 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	src/tools / VLmiscFunk.I
 *
 * Description:	Miscellaneous functions.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLmiscFunk.I,v $
 *	Revision 1.3  2001/02/27 17:26:16  ramarao
 *	Filter the consumed objects before showing the count in the status field.
 *	
 *	Revision 1.2  2001/01/16 19:44:15  ramarao
 *	*** empty log message ***
 *	
# Revision 1.3  2000/07/08  16:51:42  pinnacle
# Replaced: loft/src/tools/VLmiscFunk.I for:  by rchennup for Service Pack
#
# Revision 1.2  2000/04/29  20:01:56  pinnacle
# Replaced: loft/src/tools/VLmiscFunk.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/21  21:57:26  pinnacle
# Created: loft/src/tools/VLmiscFunk.I by rchennup for Service Pack
#
# Revision 1.3  2000/02/10  21:48:12  pinnacle
# (No comment)
#
# Revision 1.2  1999/12/30  12:37:34  pinnacle
# Replaced VLmiscFunk.I for TR179900811 by jpulapar for loft
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.3  1998/04/15  16:00:22  pinnacle
# Replaced: src/tools/VLmiscFunk.I for:  by yzhu for loft
#
# Revision 1.2  1998/02/06  15:25:54  pinnacle
# Replaced: src/tools/VLmiscFunk.I for:  by rchennup for loft
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.5  1997/04/11  18:11:36  pinnacle
# Replaced: src/tools/VLmiscFunk.I for:  by mfournie for loft
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/11/97   mf           header file.
 *      09/13/99   Jayadev      modification for TR179900811. Taken the
 *                              underlying solid for getting the range and
 *                              extended that by 5% ,not to miss grabbing 
 *                              legal objects for marking  
 *	02/10/00   Rama Rao	Addeed VLqueryWithNoLocate()
 *				and VLqueryLinesWithNoLocate() functions.
 *************************************************************************/
class implementation VLabstract ;

#include	<stdio.h>
#include        "VDobj.h"
#include	"vlprototype.h"
#include	"OMerrordef.h"
#include	"msdef.h"
#include	"bserr.h"
#include	"maerr.h"
#include	"AS_status.h"
#include	"EMSssprops.h"
#include	"EMSopt.h"
#include	"csdef.h"
#include	"grcoordsys.h"
#include	"exmacros.h"
#include	"grmacros.h"
#include	"macro.h"
#include	"vsmiscmacros.h"
#include        "vsplatedef.h"
#include        "vsgeommacros.h"
#include	"vlmiscmacros.h"
#include        "DItypedef.h"
#include        "DIdef.h"
#include        "DIprims.h"
#include        "DIglob.h"
#include	"bsallocsf.h"
#include	"bsbasisvect.h"
#include	"bscrossp.h"
#include	"bsdotp.h"
#include	"bsfreesf.h"
#include	"bsmdstptcv.h"
#include	"bsmkvec.h"
#include	"bsnorvec.h"
#include	"bssfeval.h"
#include	"bstst_plan.h"

#include	"mamulmx.h"
#include	"matypemx.h"

extern	GRclassid	OPP_ACheader_class_id;
extern	GRclassid	OPP_EMSplane_class_id;
extern	GRclassid	OPP_EMSsfimpbnd_class_id;
extern	GRclassid	OPP_GR3dlineseg_class_id;
extern	GRclassid	OPP_GRgencs_class_id;
extern	GRclassid	OPP_VSplate_class_id;
extern	GRclassid	OPP_VSimgFeature_class_id;

extern	IGRdouble	pow();
extern	void		qsort();

from	EMSloopset	import	EMget_loops;
from	EMSplane	import	EMplane;
from	EMSsubbs	import	EMget_boundaries;
from	EMSsurface	import	EMmk_nat_bdry;
from	GRcurve		import	GRendpts;
from    expression      import  NDgive_value;
/*
#define	TRACE
*/
/*
#define	DEBUG
*/

/* ************************************************************************** */
IGRlong VLvector (	IGRlong		*msg,
			IGRpoint	point1,
			IGRpoint	point2,
			IGRdouble	coef1,
			IGRdouble	coef2,
			IGRboolean	normed,
			IGRvector	vector )

{
		BSrc		rc;
		IGRlong		sts=MSFAIL;
		IGRint		i;
		IGRvector	TmpVector;

	*msg = MSFAIL;

	/* Make vector */
	if ( (coef1 == 1.0) && (coef2 == 1.0) ) {
		BSmkvec ( &rc, TmpVector, point1, point2);
		if (rc != BSSUCC)	goto wrapup;
	}
	else {	for ( i=0; i<3; i++)
			TmpVector[i] = (coef2*point2[i]) - (coef1*point1[i]);
	}

	/* Normalize vector */
	if (normed) {	BSnorvec ( &rc, TmpVector);
			if (rc != BSSUCC)	goto wrapup;	}
		
	dblcpy ( vector, TmpVector, 3);
	*msg = MSSUCC;
	sts = MSSUCC;
wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong VLendpts ( msg, Obj, Env, spt, ept)

/*d This debug function extracts the endpoints of an object. */

/*h 14/04/1993 : creation by Marc FOURNIER (ISDC). */

                IGRlong         *msg;           /*O Completion code     */
        struct  GRid            *Obj;           /*I Target object       */
        struct  GRmd_env        *Env;           /*I Target module info  */
                IGRdouble       spt[];          /*O Start point         */
                IGRdouble       ept[];          /*O End point           */

{
/* Beginning of function */

                IGRint          sts=OM_S_SUCCESS;

        /* Call GRendpts message */
        sts = om$send ( msg      = message GRcurve.GRendpts (
                                                msg,
                                                &Env->md_env.matrix_type,
                                                Env->md_env.matrix,
                                                spt,
                                                ept ),
                        senderid = NULL_OBJID,
                        targetid = Obj->objid,
                        targetos = Obj->osnum );
        return (sts);

/* End of function */
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong VLdetplane ( msg, Kline, Env, Normal, Axis, Kplane)

/*d Because the control line is not already planar, this kludge evaluate a
    plane containing it. */

/*h 10/05/93 : creation by Marc FOURNIER (ISDC). */

                IGRlong         *msg;           /*O Completion code     */
        struct  GRid            *Kline;         /*I Control line        */
        struct  GRmd_env        *Env;           /*I Current module env  */
                IGRdouble       *Normal;        /*I Plate(s) normal     */
                IGRdouble       *Axis;          /*I Ship axis           */
        struct  IGRplane        *Kplane;        /*O Resulting plane     */

{
/* Beginning of function */

                IGRlong         sts=OM_S_SUCCESS;
                IGRpoint        Kspt, Kept;
                IGRvector       Kdir;
                IGRint          i;
                BSrc            rc;

        /* Extract endpoints from control line */
        sts = VLendpts ( msg, Kline, Env, Kspt, Kept);
        as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        for ( i=0; i<3; i++)    { Kplane->point[i] = (Kspt[i] + Kept[i]) / 2.0;
                                  Kdir[i]          = Kept[i] - Kspt[i]; }
        BSnorvec ( &rc, Kdir);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

        /* Try regular method */
        sts = om$send ( msg      = message GRvg.GRdetplane (
                                                msg,
                                                &Env->md_env.matrix_type,
                                                Env->md_env.matrix,
                                                Kplane ),
                        senderid = NULL_OBJID,
                        targetid = Kline->objid,
                        targetos = Kline->osnum );
        if ( ((*msg)&1&sts) || (*msg == MANONPLANAR) || (*msg == MASDGENRAT) ) {
                /* Try kludge method */
                BSnorvec ( &rc, Normal);
                if (rc != BSSUCC) goto wrapup;
                BScrossp ( &rc, Kdir, Normal, Kplane->normal);
                if (rc != BSSUCC) goto wrapup;
                BSnorvec ( &rc, Kplane->normal);
                if (rc != BSSUCC) goto wrapup;
        }
        else if (!((*msg)&1&sts)) {
                as$status ( sts    = sts,
                            msg    = "GRvg.GRdetplane",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
        }

        /* Align control line direction along ship axis (if needed) */
        if (Axis) {
                if (BSdotp ( &rc, Kdir, Axis) < 0.0) {
                        for ( i=0; i<3; i++) Kplane->normal[i] *= -1.0; }
                if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
        }
        *msg = MSSUCC;

wrapup:
        return (sts);

/* End of function */
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong VLextractVSplateSurface ( msg, plate_id, plate_env, side,
                                  surface_id, surface_env, sf)

/*d This function extracts the surface supporting an VSplate. If the last
    argument is set to NULL, the IGRbsp_surface structure is not filled.  Else
    the allocated IGRbsp_surface structure must be free by a om$dealloc().
        side : VS_K_plTopSfPath for offset surface
               VS_K_plBotSfPath for base   surface
*/

/*h 29/09/92 : creation by Marc FOURNIER (ISDC).
    09/10/92 : modification by Marc FOURNIER (ISDC).
    11/06/93 : modification by Marc FOURNIER (ISDC).
    19/10/93 : modification by Marc FOURNIER (ISDC). */

                IGRlong         *msg;           /*O Completion code     */
        struct  GRid            *plate_id;      /*I Struct VSplate ID   */
        struct  GRmd_env        *plate_env;     /*I Struct VSplate ENV  */
                IGRchar         *side;          /*I Side of the VSplate */
        struct  GRid            *surface_id;    /*O Support surface ID  */
        struct  GRmd_env        *surface_env;   /*O Support surface ENV */
        struct  IGRbsp_surface  **sf;           /*O Bspline structure   */

{
/* Beginning of function */

                IGRint          sts;
                IGRlong         size;
		IGRmatrix	mat;
		BSrc		rc;
		IGRshort	four=4;
#ifdef	TRACE
		IGRint		i;
#endif

        /* Ask for surface ID */
	sts = vl$return_foot ( msg     = msg,
			       name    = side,
                               objId   = plate_id,
                               objEnv  = plate_env,
                               footId  = surface_id,
                               footEnv = surface_env );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(surface ID)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	dblcpy ( mat, surface_env->md_env.matrix, 16);

	MAmulmx ( &rc, &four, &four, &four, plate_env->md_env.matrix, mat,
		  surface_env->md_env.matrix );
	MAtypemx ( &rc, surface_env->md_env.matrix,
		   &surface_env->md_env.matrix_type );
#ifdef TRACE
printf( "PLATE : (%d|%d) in (%d|%d)\t--> SURFACE : (%d|%d) in (%d|%d)\n",
        plate_id->objid, plate_id->osnum,
        plate_env->md_id.objid, plate_env->md_id.osnum,
        surface_id->objid, surface_id->osnum,
        surface_env->md_id.objid, surface_env->md_id.osnum);
printf( "plate_env matrix x vl$return_foot matrix = surface_env matrix\n");
for ( i=0; i<4; i++)
printf( "[%g,%g,%g,%g]\t[%g,%g,%g,%g]\t[%g,%g,%g,%g]\n",
	plate_env->md_env.matrix[4*i],
	plate_env->md_env.matrix[4*i+1],
	plate_env->md_env.matrix[4*i+2],
	plate_env->md_env.matrix[4*i+3],
	mat[4*i], mat[4*i+1], mat[4*i+2], mat[4*i+3],
	surface_env->md_env.matrix[4*i],
	surface_env->md_env.matrix[4*i+1],
	surface_env->md_env.matrix[4*i+2],
	surface_env->md_env.matrix[4*i+3] );
#endif

        /* Alloc and fill IGRbsp_surface structure (if needed) */
        if (sf) {

                /* Get IGRbsp_surface size */
                sts = om$send ( msg      = message GRvg.GRgetsize (
                                                msg,
                                                &plate_env->md_env.matrix_type,
                                                plate_env->md_env.matrix,
                                                &size ),
                                senderid = NULL_OBJID,
                                targetid = surface_id->objid,
                                targetos = surface_id->osnum );
                as$status ( sts    = sts,
                            msg    = "GRvg.GRgetsize",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

                /* Allocate memory for IGRbsp_surface structure */
                *sf = NULL;
                *sf = (struct IGRbsp_surface *) om$calloc (size = size);

                /* Get IGRbsp_surface geometry */
                sts = om$send ( msg      = message GRvg.GRgetgeom (
                                        msg,
                                        &plate_env->md_env.matrix_type,
                                        plate_env->md_env.matrix,
                                        (IGRchar *) (*sf) ),
                                senderid = NULL_OBJID,
                                targetid = surface_id->objid,
                                targetos = surface_id->osnum );
                as$status ( sts    = sts,
                            msg    = "GRvg.GRgetgeom",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

                /* Get IGRbsp_surface boundaries */
                sts = om$send ( msg      = message EMSsubbs.EMget_boundaries (
                                        msg,
                                        &plate_env->md_env.matrix_type,
                                        plate_env->md_env.matrix,
                                        &(*sf)->on_off,
                                        &(*sf)->num_boundaries,
                                        &(*sf)->bdrys ),
                                senderid = NULL_OBJID,
                                targetid = surface_id->objid,
                                targetos = surface_id->osnum );
                as$status ( sts    = sts,
                            msg    = "EMSsubbs.EMget_boundaries",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
        }

wrapup:
        return (sts);

/* End of function */
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong VLcreatePlane ( Point, Normal, Env, cst, Plane, msg)

/*d This function construct an object EMSplane from a point and a normal. */

/*h 13/11/92 : creation by Marc FOURNIER (ISDC). */

                IGRpoint        Point;        /*I Plane point         */
                IGRvector       Normal;       /*I Plane normal        */
        struct  GRmd_env        *Env;           /*I Current module env  */
        struct  GRvg_construct  *cst;           /*I Construction list   */
        struct  GRid            *Plane;         /*O Constructed plane   */
                IGRlong         *msg;           /*O Completion code     */

{
/* Beginning of function */

                IGRlong         sts=OM_S_SUCCESS;
                IGRint          suc=OM_S_SUCCESS;
                IGRvector       u, v, w;
                BSrc            rc;
                IGRdouble       pts[9];
                IGRint          i;

        /* Construct a set of orthonormal vectors */
        BSbasisvect( &rc, Normal, u, v, w );
        if (rc != BSSUCC) {     *msg = MSFAIL;
                                printf( "Error in BSbasisvect(%g,%g,%g)\n",
                                        Normal[0], Normal[1], Normal[2] );
                                goto wrapup;    }

        /* Construct 3 points of the plane */
        for ( i=0; i<3; i++) {
                pts[i+0] = Point[i];
                pts[i+3] = Point[i] + v[i];
                pts[i+6] = Point[i] + w[i];
        }

        /* Construct EMSplane */
        Plane->objid = NULL_OBJID;
        Plane->osnum = Env->md_id.osnum;
        sts = om$construct ( classid  = OPP_EMSplane_class_id,
                             osnum    = Env->md_id.osnum,
                             p_objid  = &Plane->objid,
                             msg     = message EMSplane.EMplane
                                                ( &suc, cst,
                                                  (IGRpoint *)pts, 3 ) );

        *msg = *(cst->msg);	// EMplane sets suc not cst->msg !

        as$status ( sts    = sts,
                    msg    = "om$construct(EMSplane.EMplane)",
                    test   = (!(sts & 0x00000001 & (*msg) & (suc) )),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup :
        return (sts);

/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLsortPlateImage ( msg, nplt, Iplt, Env, Oplt, nimg)

		IGRlong		*msg;
		IGRint		nplt;
	struct	GRid		*Iplt;
	struct	GRmd_env	*Env;
	struct	GRobj_env	**Oplt;	/* Must be free by caller */
		IGRint		*nimg;

{

		IGRint		i, sts=OM_S_SUCCESS, idx=0;
		IGRlong		size=sizeof(struct GRobj_env);
	struct	GRobj_env	*work;

	/* Initialize and allocate memory */
	*nimg = 0;
	work  = NULL;
	*Oplt = NULL;
	work  = (struct GRobj_env *) om$calloc(size = nplt * size);
	if (!work) { printf( "Unable to allocate %d bytes\n", nplt * size);
		     *msg = MSFAIL; goto wrapup; }
	*Oplt = (struct GRobj_env *) om$calloc(size = nplt * size);
	if (!(*Oplt)) { printf( "Unable to allocate %d bytes\n", nplt * size);
		        *msg = MSFAIL; goto wrapup; }

	/* Retrieve VSplates */
	for ( i=0; i<nplt; i++) {
		sts = vl$return_foot ( msg     = msg,
				       objId   = &Iplt[i],
				       objEnv  = Env,
				       footId  = &work[i].obj_id,
				       footEnv = & work[i].mod_env );
        	as$status ( sts    = sts,
                    	    msg    = "vl$return_foot()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
	}

	/* Sort 1st VSplates */
	for ( i=0; i<nplt; i++) {
		if (vs$is_ancestry_valid(object  = &work[i].obj_id,
					 classid = OPP_VSplate_class_id)) {
			(*Oplt)[idx] = work[i];
			idx++;
		}
	}

	/* Sort 2nd VSimgFeatures */
	for ( i=0; i<nplt; i++) {
		if (vs$is_ancestry_valid(object  = &work[i].obj_id,
					 classid = OPP_VSimgFeature_class_id)) {
			(*Oplt)[idx] = work[i];
			idx++;
			(*nimg)++;
		}
	}

	if (idx != nplt) {
		printf( "Error in VLsortPlateImage : %d VSplates on %d\n",
			idx, nplt);
		*msg = MSFAIL;
	}

wrapup:
	if (work) { om$dealloc(ptr = work);	work = NULL; }
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLcreateLineSeg ( spt, ept, Env, cst, Line, msg)

		IGRdouble	*spt;
		IGRdouble	*ept;
	struct	GRmd_env	*Env;
	struct	GRvg_construct	*cst;
	struct	GRid		*Line;
		IGRlong		*msg;

{
		IGRint		sts=OM_S_SUCCESS;
		IGRdouble	pts[6];
	struct	IGRpolyline	geom;
	
	/* Initialize */
	dblcpy ( &pts[0], spt, 3);
	dblcpy ( &pts[3], ept, 3);
	cst->geometry   = (IGRchar *) &geom;
	geom.num_points = (IGRlong) 2;
	geom.points     = (IGRdouble *) pts;
	Line->objid     = NULL_OBJID;
	Line->osnum	= Env->md_id.osnum;

#ifdef TRACE
printf( "Construct a GR3dlineseg bewtween [%g,%g,%g] and [%g,%g,%g]\n",
	pts[0], pts[1], pts[2], pts[3], pts[4], pts[5] );
#endif

	/* Construct */
	sts = om$construct ( classid = OPP_GR3dlineseg_class_id,
			     osnum   = Line->osnum,
			     p_objid = &Line->objid,
			     msg     = message GRgraphics.GRaltconstruct (cst));
	*msg = *(cst->msg);
       	as$status ( sts    = sts,
                    msg    = "om$construct(OPP_GR3dlineseg_class_id)",
                    test   = (!(sts & 0x00000001 & (*msg))) );

	return (sts);
}
/* ========================================================================== */
IGRlong VLevalUvGridFromSrf ( srfObjEnv, uNumPoints, vNumPoints, opt,
			       srfGeom, uvGrid, msg )

struct GRobj_env	srfObjEnv;	/*I surface from which we 
					    evaluate a four sided surface 
					    with natural edges */
IGRint			uNumPoints;	/*I the number of points to approximate
					    the surface in u direction */
IGRint			vNumPoints;	/*I the number of points to approximate
					    the surface in v direction */
IGRint			opt;		/*I  opt = 0 the function is just
					    used for average normal evaluation
					    so a single value could be returned
					    in case of planar element.
				            opt = 1 we need a grid of values
					    to build later on a subsurface even
					    if the surface is planar.      */
struct IGRbsp_surface	**srfGeom;      /*O the BS geometry of the surface */
struct IGRbsp_surface   **uvGrid;	/*O the uv grid solution.
					    the poles of this surface in the
					    uv space are the parameters to be
					    used to evaluate points and 
					    normales on the surface SrfGeom */
IGRlong			*msg;		/*O return code */

{

	struct  GRobj_env		srfID;
		IGRlong			sts;
		OMuword			face_cl;
		IGRint			i, trinum=0, natur=0, count=0;
	struct  IGRbsp_curve		*curv[50];/* 8-> 50 for TR179800806*/ 	

	struct IGRbsp_surface		*srfGeomPtr;
	struct IGRbsp_surface   	*uvGridPtr;
		IGRshort		planarity;
		IGRdouble		normal[3];
		BSrc			rc;

	/* Initialization */
	srfGeomPtr = NULL;
	uvGridPtr  = NULL;
	*msg       = MSSUCC;
	for ( i=0; i<50; i++) {	curv[i] = NULL; } /* 8-> 50 for TR179800806*/

	/* Retrieve the bs geometry of the support surface */
  	sts = VLgetGeometry ( &srfObjEnv, TRUE, NULL_OBJID, 
  			     (IGRchar **) &srfGeomPtr, msg );
	as$status ( sts    = sts,
                    msg    = "VLgetGeometry()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Average normal case (option = 0) */
	if (opt == 0) {
	
		/* Check if the surface is planar */
		BStst_plan ( srfGeomPtr->u_num_poles * srfGeomPtr->v_num_poles,
		    	     srfGeomPtr->poles, srfGeomPtr->weights,
		             &planarity, normal, &rc);
		if (planarity == TRUE) {
		 	BSallocsf ( 2, 2, 2, 2, FALSE, 0, &uvGridPtr, &rc);
 			if (rc != BSSUCC) {
				printf("Error in BSallocsf()\n");
				*msg = MSFAIL; goto wrapup;	}

			uvGridPtr->u_num_poles = 1;
			uvGridPtr->v_num_poles = 1;
			uvGridPtr->poles[0] = 0.5;
			uvGridPtr->poles[1] = 0.5;
			*msg = MSSUCC;
			goto wrapup;
		}
	}
	#ifdef DEBUG
	printf("srfID = %d, %d\n",srfID.obj_id.objid,srfID.obj_id.osnum); 
	#endif
 
	/* Check the surface we got */
  	om$get_classid ( osnum     = srfObjEnv.obj_id.osnum,
			 objid     = srfObjEnv.obj_id.objid,
		         p_classid = &face_cl ) ;
 
	if (om$is_ancestry_valid ( superclassid = OPP_EMSsfimpbnd_class_id,
			    	   subclassid	= face_cl) == OM_S_SUCCESS) {
 
		#ifdef DEBUG
		printf("it's a EMSsfimpbnd\n");
		#endif
		srfID = srfObjEnv;
	}
	else {	#ifdef DEBUG
		printf("it's a regular surface\n");
		#endif

  		sts = om$send ( msg = message EMSsurface.EMmk_nat_bdry
				( msg, &srfObjEnv.mod_env.md_env, NULL),
		     		senderid = NULL_OBJID,
		     		targetid = srfObjEnv.obj_id.objid, 
		     		targetos = srfObjEnv.obj_id.osnum );
		as$status ( sts    = sts,
	                    msg    = "EMSsurface.EMmk_nat_bdry",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		srfID = srfObjEnv;
	}

	sts = VLextractUvEdges ( msg, &srfObjEnv, &natur, &count, curv);
	as$status ( sts    = sts,
                    msg    = "VLextractUvEdges()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
__DBGpr_bscv( "curve 0", curv[0], &rc);
__DBGpr_bscv( "curve 1", curv[1], &rc);
__DBGpr_bscv( "curve 2", curv[2], &rc);
__DBGpr_bscv( "curve 3", curv[3], &rc);
#endif

	switch (count) {

		case 4:	VLevalUvGridFrom4Cv ( opt, uNumPoints, vNumPoints, curv,
					      &uvGridPtr, &rc);
 			if (rc != BSSUCC) {
				printf("Error in VLevalUvGridFrom4Cv()\n");
				*msg = MSFAIL; goto wrapup;	}
#ifdef DEBUG
printf( "Successfull call of VLevalUvGridFrom4Cv() returning %dX%d patch\n",
	uvGridPtr->u_num_poles, uvGridPtr->v_num_poles );
#endif
			break;

		case 3:	if (uNumPoints > vNumPoints)	trinum = uNumPoints;
			else				trinum = vNumPoints;
			VLevalUvGridFrom3Cv ( trinum, curv, &uvGridPtr, &rc);
 			if (rc != BSSUCC) {
				printf("Error in VLevalUvGridFrom4Cv()\n");
				*msg = MSFAIL; goto wrapup;	}
#ifdef DEBUG
printf( "Successfull call of VLevalUvGridFrom3Cv() returning %dX%d patch\n",
	uvGridPtr->u_num_poles, uvGridPtr->v_num_poles );
#endif
			break;

		default:
			VLevalUvGridFromPnt ( uNumPoints, vNumPoints,
					      srfGeomPtr, &uvGridPtr, &rc);
 			if (rc != BSSUCC) {
				printf("Error in VLevalUvGridFromPnt()\n");
				*msg = MSFAIL; goto wrapup;	}
#ifdef DEBUG
printf( "Successfull call of VLevalUvGridFromPnt() returning %dX%d patch\n",
	uvGridPtr->u_num_poles, uvGridPtr->v_num_poles );
#endif
	}

wrapup:
 	for ( i=0; i<count; i++) {

		if (curv[i]) {	om$dealloc (ptr = curv[i]);
				curv[i] = NULL;	}
	}

 	if (*msg == MSFAIL) {
 		if (srfGeomPtr)	{	om$dealloc (ptr = srfGeomPtr);
			     	  	*srfGeom = NULL; }
		if (uvGridPtr) {	BSfreesf ( &rc, uvGridPtr);
					if (rc != BSSUCC)
			printf( "Error in BSfreecv(uvGridPtr)\n");
			        	*uvGrid = NULL; }
		sts = MSFAIL;
 	}
 	else { 	*srfGeom = srfGeomPtr;
		*uvGrid  = uvGridPtr;
 		sts      = MSSUCC;
	}

	return (sts);
}
/* ========================================================================== */
IGRlong VLquery1 (
		IGRlong		*msg,		/*O Completion code	*/
	struct	GRobj_env	*object,	/*I Queried object	*/
        struct  GRmd_env        *Env,           /*I Target module info  */
		GRclassid	classid,	/*I Class filter	*/
		IGRlong		(*geometric) __((struct	GRobj_env *base_obj,
						 struct GRobj_env *test_obj,
						 struct GRmd_env  *loc_env)),
						/*I Geometric filter	*/
		IGRint		*count,		/*O Number of answers	*/
	struct	GRobj_env	*list[]		/*O Array of answers	*/
)
{
		IGRint		sts=OM_S_SUCCESS, max=0, i;
		IGRshort	world=TRUE;
		GRrange		range,new_range;
	struct	GRmd_env	loc_env;
        struct  GRobj_env       gensolOE;
                IGRdouble       exp_factor;
                IGRint          rangeFlag = 0;
	
	/* Initialize */
	*count  = 0;
	*list   = NULL;
	loc_env = *Env;
	ex$get_modid ( mod_osnum = loc_env.md_id.osnum,
		       mod_id    = &(loc_env.md_id.objid) );

	// Take the EMSgensolid for range calculation - TR179900811
	vdobj$GetFoot(objOE=object,footName = VS_K_plGrCmpName,footOE = &gensolOE);
	if(gensolOE.obj_id.objid == NULL_OBJID) goto wrapup;

	/* Range of <object> */
	sts = om$send ( msg = message GRgraphics.GRgetrang (
					msg,
					&(object->mod_env.md_env.matrix_type),
					object->mod_env.md_env.matrix,
					&world,
					range ),
			senderid = NULL_OBJID,
			targetid = gensolOE.obj_id.objid,
			targetos = gensolOE.obj_id.osnum );
	as$status ( sts    = sts,
                    msg    = "GRgraphics.GRgetrang",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	// Extend the range by so that all the legal marking objects are grabbed
        rangeFlag = VLgiveRangeExp(&exp_factor); 
        if(!rangeFlag) exp_factor = 0.05; // 5% default expansion
	
	for(i=0;i<3;i++)
	  new_range[i] = ((1.0+exp_factor)*range[i]) - (exp_factor*range[i+3]);
	
	for(i=0;i<3;i++)
	  new_range[i+3] = -(exp_factor*range[i]) + ((1.0+exp_factor)*range[i+3]);
	
	/* Range locate on <object> */
	VLrLocRef ( new_range, count, list, &loc_env);
	
	/* Class filter on result */
	VLfilterClass ( *count, *list, count, classid);
	
	/* Geometric filter on result */
	max = *count;
	*count = 0;
	for ( i=0; i<max; i++)
		if ( geometric (object, &((*list)[i]), &loc_env) & 1) {
			(*list)[*count] = (*list)[i];
			(*count)++;
		}

wrapup:
	return (sts);
}


/* ========================================================================== */
IGRlong VLqueryWithNoLocate (
                IGRlong         *msg,           /*O Completion code     */
        struct  GRobj_env       *object,        /*I Queried object      */
        struct  GRmd_env        *Env,           /*I Target module info  */
		IGRint		nb_class,	/*I Number of class     */
                GRclassid       *classids,       /*I Class filter        */
                IGRlong         (*geometric) __((struct GRobj_env *base_obj,
						 GRrange	   range,
                                                 struct GRobj_env *test_obj,
                                                 struct GRmd_env  *loc_env)),
                                                /*I Geometric filter    */
                IGRint          *count,         /*O Number of answers   */
        struct  GRobj_env       *list[]         /*O Array of answers    */
)
{
IGRlong			sts=OM_S_SUCCESS, isConsumed;
IGRint          	i, max=0, rangeFlag=0;
IGRdouble		exp_factor;
IGRshort        	world=TRUE;
IGRchar         	status_msg[128];
GRrange         	range,new_range;
struct GRmd_env         loc_env;
struct GRobj_env        gensolOE;

        /* Initialize */
        *count  = 0;
        *list   = NULL;
        loc_env = *Env;
        ex$get_modid ( mod_osnum = loc_env.md_id.osnum,
                       mod_id    = &(loc_env.md_id.objid) );

        // Take the EMSgensolid for range calculation - TR179900811
        vdobj$GetFoot( objOE    = object,
		       footName = VS_K_plGrCmpName,
		       footOE   = &gensolOE);
        if(gensolOE.obj_id.objid == NULL_OBJID) goto wrapup;

	vs$getRangeOfComposite( msg = msg, 
				composite = &gensolOE, 
				range     = range       );

        // Extend the range by so that all the legal marking objects are grabbed
        rangeFlag = VLgiveRangeExp(&exp_factor); 
        if(!rangeFlag) exp_factor = 0.05; // 5% default expansion

        for(i=0;i<3;i++)
          new_range[i] = ((1.0+exp_factor)*range[i]) - (exp_factor*range[i+3]);

        for(i=0;i<3;i++)
          new_range[i+3] = -(exp_factor*range[i]) + 
			   ((1.0+exp_factor)*range[i+3]);
	/* Function which will NOT LOCATE */
	VD_findall_objects_in_range( new_range, nb_class, classids, 
				     TRUE, loc_env, count, list );

	/* Removed the objects which are consumed */
        max = *count;
        *count = 0;
        for ( i=0; i<max; i++)
        {
	   if( (*list)[i].obj_id.objid == object->obj_id.objid && 
	       (*list)[i].obj_id.osnum == object->obj_id.osnum ) continue;

	   isConsumed = 0;
	   sts = om$send(  msg     = message NDmacro.ACtest_consumed( 
						&isConsumed ),
                           senderid = NULL_OBJID,
                           targetid = (*list)[i].obj_id.objid,
                           targetos = (*list)[i].obj_id.osnum );
           if( !(sts&1) || ( isConsumed & 1 ) ) continue;
	   (*list)[(*count)] = (*list)[i];
	   (*count)++;
        }

        /* Geometric filter on result */
        max = *count;
        *count = 0;
        for ( i=0; i<max; i++)
	{
                sprintf(status_msg, 
		"Validating Objects for AutoMarking ... %d / %d", i+1, max );
                UI_status( status_msg );
		
                if ( geometric (object, new_range, 
		     &((*list)[i]), &loc_env) & 1) 
		{
                        (*list)[*count] = (*list)[i];
                        (*count)++;
                }
	}
wrapup:
        return (sts);
}

/* ========================================================================== */
IGRlong VLqueryLinesWithNoLocate (
                IGRlong         *msg,           /*O Completion code     */
        struct  GRobj_env       *object,        /*I Queried object      */
        struct  GRmd_env        *Env,           /*I Target module info  */
		IGRint		nb_class,	/*I Number of class     */
                GRclassid       *classids,       /*I Class filter        */
                IGRint          *count,         /*O Number of answers   */
        struct  GRobj_env       *list[]         /*O Array of answers    */
)
{
		BSrc		rc;
                IGRint          sts=OM_S_SUCCESS, max=0, i;
                IGRshort        world=TRUE;
                GRrange         range,new_range;
        struct  GRmd_env        loc_env;
	struct  GRobj_env	gensolOE;
                IGRdouble       exp_factor;
                IGRint          rangeFlag = 0;

        /* Initialize */
        *count  = 0;
        *list   = NULL;
        loc_env = *Env;
        ex$get_modid ( mod_osnum = loc_env.md_id.osnum,
                       mod_id    = &(loc_env.md_id.objid) );

        // Take the EMSgensolid for range calculation - TR179900811
        vdobj$GetFoot(  objOE    = object,
			footName = VS_K_plGrCmpName,
			footOE   = &gensolOE );
        if( gensolOE.obj_id.objid == NULL_OBJID ) goto wrapup;

        vs$getRangeOfComposite( msg = msg,
                                composite = &gensolOE,
                                range     = range       );
        as$status ( sts    = sts,
                    msg    = "vs$getRangeOfComposite",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

        // Extend the range by so that all the legal marking objects are grabbed
        rangeFlag = VLgiveRangeExp(&exp_factor); 
        if(!rangeFlag) exp_factor = 0.05; // 5% default expansion

        for(i=0;i<3;i++)
          new_range[i] = ((1.0+exp_factor)*range[i]) - (exp_factor*range[i+3]);

        for(i=0;i<3;i++)
          new_range[i+3] = -(exp_factor*range[i]) + 
			   ((1.0+exp_factor)*range[i+3]);

	/* Function which will NOT LOCATE */
	VD_findall_objects_in_range( new_range, nb_class, classids, TRUE, 
				     loc_env, count, list );

        /* Geometric filter on result */
        max = *count;
        *count = 0;
        for ( i=0; i<max; i++)
        {
		if( VLcheckGenLine( object, &((*list)[i]), 
			&loc_env ) == MSSUCC )
		{
                        (*list)[*count] = (*list)[i];
                        (*count)++;
                }
        }

wrapup:
        return (sts);
}

/* ========================================================================== */
IGRint VLsortSeam ( a, b)

        struct  VLsortTpl     *a, *b;

{
        return ((a->y == b->y) ? 0 : (a->y < b->y) ? -1 : 1);
}
/* ========================================================================== */
IGRlong VLsortPlateSeams ( Plate, side, nseam, Seam, msg)

	struct	GRobj_env	*Plate;		/*I  VSplate object	*/
		IGRchar		*side;		/*I  Side of VSplate	*/
		IGRint		nseam;		/*I  Number of seams	*/
	struct	GRobj_env	*Seam[];	/*IO Array of seams	*/
		IGRlong		*msg;		/*O  Completion code	*/

{
		IGRint		sts=OM_S_SUCCESS, i;
	struct	GRobj_env	Surf, *Work;
	struct	IGRbsp_surface	*sf;
		IGRpoint	cnt, pnt;
		BSrc		rc;
	struct	VLsortTpl	*Sort;
	struct	GRparms		parms;

	/* Initialize */
	sf   = NULL;
	Sort = NULL;
	Work = NULL;
	*msg = MSSUCC;

	/* Exit if no sorting needed */
	if (nseam < 2)	goto wrapup;

	/* Extract support surface form VSplate */
	sts = VLextractVSplateSurface ( msg,
					&Plate->obj_id, &Plate->mod_env, side,
					&Surf.obj_id, &Surf.mod_env, &sf );
	as$status ( sts    = sts,
                    msg    = "VLextractVSplateSurface()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Evaluate center of support surface */
	BSsfeval ( sf, 0.5, 0.5, 0, &cnt, &rc);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

	/* Allocate memory for VLsortTpl structure */
	Sort = om$calloc ( num       = nseam,
			   structure = struct VLsortTpl );

	/* Loop on VLseaLines */
	for ( i=0; i<nseam; i++) {
		sts = om$send ( msg = message GRgraphics.GRptproject (
					msg,
					&(*Seam)[i].mod_env.md_env.matrix_type,
					(*Seam)[i].mod_env.md_env.matrix,
					cnt, pnt, &parms ),
				senderid = NULL_OBJID,
				targetid = (*Seam)[i].obj_id.objid,
				targetos = (*Seam)[i].obj_id.osnum );
		as$status ( sts    = sts,
                    	    msg    = "GRgraphics.GRptproject",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
		Sort[i].idx     = i;
		Sort[i].name[0] = '\0';
		Sort[i].x       = pnt[0] - cnt[0];
		Sort[i].y       = pnt[1] - cnt[1];
		Sort[i].z       = pnt[2] - cnt[2];
		Sort[i].num	= 0;
	}

	/* Sort VLseaLines */
#ifdef TRACE
for ( i=0; i<nseam; i++)
printf( "\t>>>Seam %d has index %d, [%g,%g,%g]\n",
	i, Sort[i].idx, Sort[i].x, Sort[i].y, Sort[i].z);
#endif
	qsort ( Sort, nseam, sizeof(struct VLsortTpl), (int (*)())VLsortSeam);
#ifdef TRACE
for ( i=0; i<nseam; i++)
printf( "\t<<<Seam %d has index %d, [%g,%g,%g]\n",
	i, Sort[i].idx, Sort[i].x, Sort[i].y, Sort[i].z);
#endif

	/* Allocate memory for VLsortTpl structure */
	Work = om$calloc ( num       = nseam,
			   structure = struct GRobj_env );

	for ( i=0; i<nseam; i++)	Work[i]    = (*Seam)[Sort[i].idx];
	for ( i=0; i<nseam; i++)	(*Seam)[i] = Work[i];

wrapup:
	if (Work) {	om$dealloc (ptr = Work);	Work = NULL;    }
	if (Sort) {	om$dealloc (ptr = Sort);	Sort = NULL;    }
	if (sf) {       om$dealloc (ptr = sf);          sf   = NULL;    }
	return (sts);
}
/* ========================================================================== */
IGRlong	VLcheckSurfSurf ( Surf1, Surf2, Env, Inter)

	struct	GRobj_env	*Surf1;		/*I Surface 1		*/
	struct	GRobj_env	*Surf2;		/*I Surface 2		*/
	struct	GRmd_env	*Env;		/*I Environ		*/
	struct	GRobj_env	*Inter;		/*O Intersection 1-2	*/

{

		IGRlong		msg;
		IGRint		sts;
		IGRshort	trim1=0, trim2=1;

	/* Initialize */
	Inter->obj_id.objid = NULL_OBJID;
	Inter->obj_id.osnum = Env->md_id.osnum;
	Inter->mod_env	    = *Env;

	/* Intersect surfaces */
	Inter->mod_env = *Env;
	sts = VLcreateInter ( &msg,
			      &Surf1->obj_id, &Surf1->mod_env, trim1,
			      &Surf2->obj_id, &Surf2->mod_env, trim2,
			      &Inter->obj_id, &Inter->mod_env );

	/* Check intersection */
	if (Inter->obj_id.objid == NULL_OBJID)	sts = MSFAIL;
	else					sts = MSSUCC;
		
	return (sts);
}
/* ========================================================================== */
IGRlong VLquery2 (
		IGRlong		*msg,		/*O Completion code	*/
	struct	GRobj_env	*object,	/*I Queried object	*/
        struct  GRmd_env        *Env,           /*I Target module info  */
		GRclassid	classid,	/*I Class filter	*/
		IGRlong		(*geometric) __((struct	GRobj_env *base_obj,
						 struct GRobj_env *test_obj,
						 struct GRmd_env  *loc_env,
						 struct GRobj_env *resp_obj)),
						/*I Geometric filter	*/
		IGRchar		*side,		/*I Side of VSplate	*/
		IGRint		*count,		/*O Number of answers	*/
	struct	GRobj_env	*list[]		/*O Array of answers	*/
)
{
		IGRint		sts=OM_S_SUCCESS, max=0, i;
		IGRshort	world=TRUE;
		GRrange		range;
	struct	GRmd_env	loc_env;
	struct	GRobj_env	Support, Inter;

	/* Initialize */
	*count  = 0;
	*list   = NULL;
	loc_env = *Env;
	ex$get_modid ( mod_osnum = loc_env.md_id.osnum,
		       mod_id    = &(loc_env.md_id.objid) );

	sts = om$send ( msg = message GRgraphics.GRgetrang (
					msg,
					&(object->mod_env.md_env.matrix_type),
					object->mod_env.md_env.matrix,
					&world,
					range ),
			senderid = NULL_OBJID,
			targetid = object->obj_id.objid,
			targetos = object->obj_id.osnum );
	as$status ( sts    = sts,
                    msg    = "GRgraphics.GRgetrang",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );



	VLrLocRef ( range, count, list, &loc_env);
#ifdef TRACE
printf ( "VLquery2 : after range locate : count = %d\n", *count);
#endif

	/* Class filter on result */
	VLfilterClass ( *count, *list, count, classid);
#ifdef TRACE
printf ( "VLquery2 : after class filter : count = %d\n", *count);
#endif

	/* Geometric filter on result */
	max = *count;
	*count = 0;
	for ( i=0; i<max; i++) {
		sts = VLextractVSplateSurface ( msg,
						&((*list)[i].obj_id),
						&((*list)[i].mod_env),
						side,
						&Support.obj_id,
						&Support.mod_env,
						NULL );
		if ( geometric (object, &Support, &loc_env, &Inter) & 1) {
			(*list)[*count] = Inter;
			(*count)++;
		}
	}
#ifdef TRACE
printf ( "VLquery2 : after geom. filter : count = %d\n", *count);
#endif

wrapup:
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint VLplaceRootHeader ( cs_matrix, mac_name, Env, Result, msg)

/*d This function constructs a coordinate system from "cs_matrix" and an
    ACheader object. Then an occurence of the macro "mac_name" is placed, 
    attached to coordinate system. Then the macro occurence is moved to root 
    and the coordinate system is deleted. */

/*h 22/03/94 : creation by Marc Fournier (COC Shipbuilding). */

		IGRmatrix	cs_matrix;	/*I Coordinate system matrix  */
		IGRchar		*mac_name;	/*I Macro definition name     */
	struct	GRmd_env	*Env;		/*I Local environment	      */
	struct	GRid		*Result;	/*O Root ACheader occurence   */
		IGRlong		*msg;		/*O Completion code	      */

{
/* Beginning of function */

                IGRint          sts=OM_S_SUCCESS;
	struct	GRid		cs_id, dummy;
	struct	GRvg_construct	cst;
	struct	IGRlbsys	lbsy;
	struct	GRcs_construct	args;

	/* Initialize */
	Result->objid = NULL_OBJID;
	Result->osnum = Env->md_id.osnum;
	cs_id.objid   = NULL_OBJID;
	cs_id.osnum   = Env->md_id.osnum;
	VLinitCnst(&cst);

	/* Prepare coordinate system construction */
	dblcpy ( lbsy.matrix, cs_matrix, 16);
	lbsy.diag_pt1[0] = lbsy.diag_pt1[1] = lbsy.diag_pt1[2] = 0.0;
        lbsy.diag_pt2[0] = lbsy.diag_pt2[1] = lbsy.diag_pt2[2] = 0.0;
	args.desc      = NULL;
	args.flag      = CS_CONNECT_TO_MGR | CS_NO_MAKE_ACTIVE;
	cst.class_attr = (IGRchar *) &args;
	cst.geometry   = (IGRchar *) &lbsy;

	/* Construct coordinate system */
	sts = om$construct ( classid = OPP_GRgencs_class_id,
                             osnum   = cs_id.osnum,
                             p_objid = &cs_id.objid,
                             msg     = message GRgraphics.GRconstruct(&cst));
        as$status ( sts    = sts,
                    msg    = "om$construct(GRgraphics.GRconstruct)",
                    test   = (!(sts & 0x00000001 & (*(cst.msg)))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Construct and place an ACheader object */
	sts = vl$placeLoftMacro ( msg		= msg,
				  classid	= OPP_ACheader_class_id,
				  prop		= AChdr_nodisplay,
				  MacName	= mac_name,
				  number	= 1,
				  template	= &cs_id,
				  Env		= Env,
				  ChgState	= FALSE,
				  occ_id	= Result );

	/* Move macro occurence to Root */
	sts = om$send ( msg = message NDnode.NDmove_to_root ( msg, &dummy, Env),
                        senderid = NULL_OBJID,
                        targetid = Result->objid,
                        targetos = Result->osnum );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDmove_to_root",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	if (cs_id.objid != NULL_OBJID)
		gr$delete_object ( msg = msg, md_env = Env, object_id = &cs_id);
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
void VLencode (	IGRint	binary[],	/*I TRUE|FALSE array	*/
		IGRint	number,		/*I Array size		*/
		IGRint	*code	)	/*O Coded value		*/

/*d This function computes the code matching with an array of binary values.

    Example : [0,1,1,0,1] code is 22 (= 0+2+4+0+16).
	      10110 in base 2 is 22 in base 10.	*/

/*h 27/04/94 :	creation by Marc Fournier (COC Shipbuilding). */

{
                IGRint  i;

        *code = 0;
        for ( i=0; i<number; i++) {
#ifdef TRACE
printf( "VLencode : binary[%d] = %d\n", i, binary[i]);
#endif
                if (binary[i])    *code += (IGRint) pow ( 2.0, (IGRdouble) i);
        }
#ifdef TRACE
printf( "\tVLencode = %d\n", *code);
#endif
}
/* ========================================================================== */

/* ========================================================================== */
void VLdecode (	IGRint  code,		/*I Coded value		*/
		IGRint  number,		/*I Array size		*/
		IGRint  binary[] )	/*O TRUE|FALSE array	*/

/*d This function computes an array of binary values matching with the code.
    Output array is allocated by caller.

    Example : 22 array is [0,1,1,0,1].
	      22 in base 10 is 10110 in base 2.	*/

/*h 27/04/94 :	creation by Marc Fournier (COC Shipbuilding). */

{
                IGRint          i, Icode=0;
                IGRdouble       Dcode=0.0, delta=0.0;

#ifdef TRACE
printf( "VLdecode (%d)\n", code);
#endif
        for ( i=0; i<number; i++) {
                binary[i] = 0;
                Dcode = code / 2.0;
                Icode = Dcode;
                delta = Dcode - Icode;
                if (delta)      binary[i] = 1;
#ifdef TRACE
printf( "\tVLdecode : binary[%d] = %d\n", i, binary[i]);
#endif
                code = Dcode;
        }
}
/* ========================================================================== */
IGRint	VLimgKludge (	struct	GRid		*Obj,
			struct	GRmd_env	*Env,
			struct	GRid		*Cmp,
				IGRlong		*msg	)
{
	IGRint		sts=OM_S_SUCCESS;
	IGRshort	typ;
	IGRmatrix	mat;

	/* Initialize */
	*msg = MSSUCC;

	if ( vs$is_ancestry_valid ( object  = Obj,
				    classid = OPP_VSimgFeature_class_id ) ) {
#ifdef TRACE
printf( "(%d|%d) is a VSimgFeature\n", Obj->osnum, Obj->objid);
#endif
		sts = om$send ( msg = message GRowner.GRget_matrix (
						msg,
						&Env->md_env.matrix_type,
                                                Env->md_env.matrix,
						&typ,
						mat ),
				senderid = NULL_OBJID,
				targetid = Obj->objid,
				targetos = Obj->osnum );
	        as$status ( sts    = sts,
	                    msg    = "GRowner.GRget_matrix",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		sts = om$send ( msg = message GRgraphics.GRxform
					( msg, Env, &typ, mat, &Cmp->objid),
				senderid = NULL_OBJID,
				targetid = Cmp->objid,
				targetos = Cmp->osnum );
	        as$status ( sts    = sts,
	                    msg    = "GRgraphics.GRxform",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
#ifdef TRACE
printf( "GRxform on (%d|%d) with :\n", Cmp->osnum, Cmp->objid);
printf( "\t[%g\t%g\t%g\t%g]\n", mat[0],  mat[1],  mat[2],  mat[3] );
printf( "\t[%g\t%g\t%g\t%g]\n", mat[4],  mat[5],  mat[6],  mat[7] );
printf( "\t[%g\t%g\t%g\t%g]\n", mat[8],  mat[9],  mat[10], mat[11] );
printf( "\t[%g\t%g\t%g\t%g]\n", mat[12], mat[13], mat[14], mat[15] );
#endif
	}

wrapup :
	return (sts);
}
/* ========================================================================== */
IGRint VLgiveRangeExp(IGRdouble *exp_factor)
{
   IGRint retFlag = 0;
   long            status1;
   GRspacenum      cur_osnum;
   OM_S_OBJID      cur_objid;
   IGRchar         file_name[DI_PATH_MAX], exp_name[DI_PATH_MAX],
                   cur_dir[DI_PATH_MAX];
   struct GRid     exp_obj;
   IGRint          sts  = OM_E_INVARG;

   *exp_factor = 0.0 ;

   ex$get_cur_mod( id = &cur_objid, osnum = &cur_osnum );

   VDSget_filename(file_name);
   di$pwd(dirname = cur_dir);

   strcat( file_name, ":IGENOD" );
   sprintf(exp_name, "%s:RangeExpFactor", file_name );

   di$cd(dirname = file_name);
   status1 = di$translate(  objname = exp_name,
                            osnum   = cur_osnum,
                            p_objid = &exp_obj.objid);
   if( status1 == DIR_S_SUCCESS)
   {
     sts = om$send ( msg = message expression.NDgive_value (exp_factor),
                     senderid = NULL_OBJID,
                     targetid = exp_obj.objid,
                     targetos = cur_osnum );
     if(sts&1) retFlag = 1;
   }
   di$cd(dirname = cur_dir);

wrapup:
return retFlag;
}
end implementation VLabstract;
