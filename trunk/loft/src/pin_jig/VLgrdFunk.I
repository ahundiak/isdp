/* $Id: VLgrdFunk.I,v 1.1.1.1 2001/01/04 21:11:33 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	VLinteg/src/pin_jig / VLgrdFunk.I
 *
 * Description:	Set of functions to evaluate average normal and transformation
 *		matrix to balance grphics objects.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLgrdFunk.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.3  1998/04/15  05:47:28  pinnacle
# Replaced: src/pin_jig/VLgrdFunk.I for:  by rchennup for loft
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.5  1997/04/09  14:42:12  pinnacle
# Replaced: src/pin_jig/VLgrdFunk.I for: file header + vl$externalContour() by mfournie for loft
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/21/93   jll		fix in VLevalFromMat() & VLevalAvNor().
 *	04/09/97   mf           file header + vl$externalContour()
 *************************************************************************/

class implementation VLabstract;

#include	<stdio.h>
#include	<math.h>
#include	<string.h>
#include	"vlprototype.h"
#include	"OMerrordef.h"
#include	"godef.h"
#include	"nddef.h"
#include	"maerr.h"
#include	"bs.h"
#include	"bsparameters.h"
#include	"bsvalues.h"
#include	"EMSmsgdef.h"
#include	"msdef.h"
#include	"OMindex.h"
#include	"OMmacros.h"
#include	"EMSssprops.h"
#include	"EMSdpb.h"
#include	"grmacros.h"
#include	"dpezmac.h"
#include	"math.h"
#include	"AS_status.h"
#include	"asmacros.h"

#include	"bscrossp.h"
#include	"bsdotp.h"
#include	"bsfreesf.h"
#include	"bslenvec.h"
#include	"bsmkvec.h"
#include	"bsnorvec.h"
#include	"bssfarrevn.h"
#include	"bsxtractpar.h"

#include	"mainvmx.h"
#include	"mamulmx.h"
#include	"marotmx.h"
#include	"matypemx.h"

#include	"vsplatedef.h"
#include	"vsmiscmacros.h"
#include	"vlplatejig.h"
#include	"vlfloor.h"
#include	"vlgrdef.h"
#include	"vlgrmacros.h"
#include	"vlcontmacros.h"

extern	GRclassid	OPP_GRcurve_class_id;
extern	GRclassid	OPP_GRlbsys_class_id;
extern	GRclassid	OPP_VSimgFeature_class_id;
extern	GRclassid	OPP_VSplate_class_id;
extern	GRclassid	OPP_VSfrzBeam_class_id;
extern	GRclassid	OPP_VSstfBeam_class_id;
extern	GRclassid	OPP_VLmrkLine_class_id;

extern  IGRdouble       VLatan2();

from	EMSsubbs	import	EMget_boundaries, EMget_props;
from	GRgencs		import	GRgetmatrix;
from	GRlinear	import	GRgetpolyline;


/*	#define	TRACE  */

/*==========================================================================*/

IGRlong VLevalFromMat (
	struct 	GRobj_env	*LocObj,  /*I The input graphic objects     */
		IGRint		NumObj,   /*I Number of graphic objects     */
		IGRchar		*side,	  /*I Side of the VSplate	    */
		IGRdouble	offset,   /*I Ground to lowest point	    */
		IGRint		Jigtype,  /*I IDX_J1: avg nrm, IDX_J2: Y=0  */
	struct	IGRplane	*Normal,  /*I Normal of support surface     */
	struct	GRmd_env	*Env,	  /*I Module environment	    */
		IGRdouble	*FromMat, /*O Transformation matrix	    */
		IGRlong		*msg      /*O Return code MSSUCC or MSFAIL  */
	)

/*d This function evaluates, from a list of graphic objects containing
   at list one surface, a transformation matrix.
   it performs first an average normal evaluation, computes a ponctual
   center of gravity. According a ground direction we find the lower
   point of the surface and translate this point by the offset value. */

/*h 20-Oct-92 JLL creation date
    05-Nov-93 MF  updates with minimum rectangle based method to determine
		  X and Y axis.
*/

/*c Beginning of function */

{
		IGRlong		sts=MSFAIL, size;
		IGRint		i, nplt=0, act, Inorm=1;
	struct	GRobj_env	*Plate, Cntr;
		IGRdouble	dist=0.0, bTol, cTol, dTol, len, wid, e1, e2;
	struct	GRvg_construct	cst;
	struct	GRid		Proj, Fram;
		GRclassid	clid;
		IGRvector	vx, vy, vz, edg1, edg2;
	struct	IGRpolyline	poly;
		BSrc		rc;

	/*c Initialize */
	Plate = NULL;
	VLinitCnst (&cst);
        cst.env_info = Env;
        BSxtractpar ( msg, BSTOLBASIS,  &bTol);
        BSxtractpar ( msg, BSTOLCHRDHT, &cTol);
        dTol = 5 * cTol;
        Cntr.obj_id.objid = NULL_OBJID;
        Cntr.obj_id.osnum = Env->md_id.osnum;
        Proj.objid = NULL_OBJID;
        Proj.osnum = Env->md_id.osnum;
        Fram.objid = NULL_OBJID;
        Fram.osnum = Env->md_id.osnum;
	vx[1] = vx[2] = vy[0] = vy[2] = 0.0;
	vx[0] = vy[1] = 1.0;
	poly.points   = NULL;

#ifdef TRACE
printf( "Normal Plane : [%g,%g,%g] & [%g,%g,%g]\n",
	Normal->point[0], Normal->point[1], Normal->point[2],
	Normal->normal[0], Normal->normal[1], Normal->normal[2] );
#endif

	/*c Allocate memory */
	Plate = om$calloc ( num	      = NumObj,
			    structure = struct GRobj_env );
	if (!Plate) { printf( "Unable to allocate %d bytes\n", 
			      NumObj * sizeof(struct GRobj_env) );
		      *msg = MSFAIL;	goto wrapup; }

	/*c Get only VSplates */
	for ( i=0; i<NumObj; i++) {

		if (  (!vs$is_ancestry_valid(object  = &LocObj[i].obj_id,
					     classid = OPP_GRcurve_class_id))
		   && (!vs$is_ancestry_valid(object  = &LocObj[i].obj_id,
					     classid = OPP_VSfrzBeam_class_id))
		   && (!vs$is_ancestry_valid(object  = &LocObj[i].obj_id,
					     classid = OPP_VSstfBeam_class_id))
		   && (!vs$is_ancestry_valid(object  = &LocObj[i].obj_id,
					     classid = OPP_VLmrkLine_class_id))
		   && (!vs$is_ancestry_valid(object  = &LocObj[i].obj_id,
					     classid = OPP_GRlbsys_class_id))) {

			Plate[nplt] = LocObj[i];
			nplt++;
		}
	}
	if (!nplt) { printf( "No VSplates found in input list ...\n");
		     *msg = MSFAIL;	goto wrapup; }

	/*c Check if average normal have to be inverted */
	for ( i=0; i<3; i++)	vz[i] = -1.0 * Normal->normal[i];

	BSnorvec ( &rc, vz);
	if (rc != BSSUCC) { printf( "Error in BSnorvec()\n" );
                            *msg = MSFAIL; goto wrapup; }

if (Jigtype == IDX_J1) {

	/*c Construct global contour of the VSplates */
	sts = vl$externalContour ( msg	= msg,
				   num	= nplt,
				   Plat	= Plate,
				   side	= side,
				   Env	= Env,
				   Cont = &Cntr );
	as$status ( sts	   = sts,
		    msg	   = "vl$externalContour()",
                    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

#ifdef TRACE
printf( "Cntr : (%d|%d)\n", Cntr.obj_id.osnum, Cntr.obj_id.objid);
#endif

        /*c Project contour in average normal direction */
#ifdef TRACE
printf( "EFproject_any_curve_on_planen :\n");
printf( "[%g,%g,%g] & [%g,%g,%g]\n",
	Normal->point[0], Normal->point[1], Normal->point[2],
	Normal->normal[0], Normal->normal[1], Normal->normal[2] );
#endif
        sts = EFproject_any_curve_on_planen ( msg,
					      &cst,
                                              &Cntr.obj_id,
                                              Env,
                                              Normal,
                                              Normal->normal,
                                              &Proj,
                                              &clid );
	as$status ( sts    = sts,
                    msg    = "EFproject_any_curve_on_planen()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "Proj : (%d|%d)\n", Proj.osnum, Proj.objid);
#endif

	/*c Create minimum rectangle around projected contour */
	sts = vl$minrect ( curve   = &Proj,
			   environ = Env,
			   cst	   = &cst,
			   length  = &len,
			   width   = &wid,
			   frame   = &Fram,
			   msg     = msg );
	as$status ( sts    = sts,
                    msg    = "vl$minrect()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "Fram : (%d|%d)\n", Fram.osnum, Fram.objid);
#endif

	/*c Extract the polyline associated with minimum rectangle */
	poly.num_points = 5;
	size = 3 * poly.num_points * sizeof(IGRdouble);
	poly.points = (IGRdouble *) om$calloc (size = size);
	if (!poly.points) {
                printf( "Unable to allocate %d bytes\n", size);
                poly.points = NULL;
                goto wrapup;
        }
	act = 1;
        sts = om$send ( msg = message GRlinear.GRgetpolyline (
                                                msg,
                                                &Env->md_env.matrix_type,
                                                Env->md_env.matrix,
                                                &act,
                                                &poly ),
			senderid = NULL_OBJID,
                        targetid = Fram.objid,
                        targetos = Fram.osnum );
        as$status ( sts    = sts,
                    msg    = "GRlinear.GRgetpolyline",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/*c Construct first edge */
	BSmkvec ( &rc, edg1, &poly.points[0], &poly.points[3]);
	if (rc != BSSUCC) { printf( "Error in BSmkvec()\n" );
                            *msg = MSFAIL; goto wrapup; }
	BSnorvec ( &rc, edg1);
	if (rc != BSSUCC) { printf( "Error in BSnorvec()\n" );
                            *msg = MSFAIL; goto wrapup; }
	e1 = BSdotp ( &rc, edg1, vx);
	if (rc != BSSUCC) e1 = 0.0;
	if (e1 < 0) {	for ( i=0; i<3; i++)	edg1[i] *= -1.0;
			e1 *= -1;	}

	/*c Construct second edge */
	BSmkvec ( &rc, edg2, &poly.points[3], &poly.points[6]);
	if (rc != BSSUCC) { printf( "Error in BSmkvec()\n" );
                            *msg = MSFAIL; goto wrapup; }
	BSnorvec ( &rc, edg2);
	if (rc != BSSUCC) { printf( "Error in BSnorvec()\n" );
                            *msg = MSFAIL; goto wrapup; }
	e2 = BSdotp ( &rc, edg2, vx);
	if (rc != BSSUCC) e2 = 0.0;
	if (e2 < 0) {	for ( i=0; i<3; i++)	edg2[i] *= -1.0;
			e2 *= -1;	}

	/*c Determine X axis */
	if (e1 > e2)	for ( i=0; i<3; i++)	vx[i] = edg1[i];
	else		for ( i=0; i<3; i++)	vx[i] = edg2[i];

	BScrossp ( &rc, vz, vx, vy);
	if (rc != BSSUCC) { printf( "Error in BScrossp()\n" );
                            *msg = MSFAIL; goto wrapup; }

	BSnorvec ( &rc, vy);
	if (rc != BSSUCC) { printf( "Error in BSnorvec()\n" );
                            *msg = MSFAIL; goto wrapup; }
}
else if (Jigtype == IDX_J2) {

	BSnorvec ( &rc, vz);
	if (rc != BSSUCC) { printf( "Error in BSnorvec()\n" );
                            *msg = MSFAIL; goto wrapup; }

	BScrossp ( &rc, vy, vz, vx);
	if (rc != BSSUCC) { printf( "Error in BScrossp()\n" );
                            *msg = MSFAIL; goto wrapup; }

	BSnorvec ( &rc, vx);
	if (rc != BSSUCC) { printf( "Error in BSnorvec()\n" );
                            *msg = MSFAIL; goto wrapup; }

	BScrossp ( &rc, vx, vy, vz);
	if (rc != BSSUCC) { printf( "Error in BScrossp()\n" );
                            *msg = MSFAIL; goto wrapup; }

	BSnorvec ( &rc, vz);
	if (rc != BSSUCC) { printf( "Error in BSnorvec()\n" );
                            *msg = MSFAIL; goto wrapup; }

	if (!strcmp ( side, VS_K_plBotSfPath))	Inorm = -1;
}
else { 	printf( "Unknown Pin Jig type %d\n", Jigtype);
	goto wrapup;
}

	/*c Control distance */
	sts = VLevalPltCenterNormalDistance
		( Plate, nplt, side, Jigtype, INVNORM_OF, FALSE,
		  NULL, NULL, &dist, msg );
	as$status ( sts = sts,
    		    msg = "VLevalPltCenterNormalDistance()",
    		    test = (!(sts & 0x00000001 & (*msg))),
    		    action = GOTO_VALUE,
    		    value  = wrapup );
	offset += dist;
	
	/*c Build the transformation matrix. */
	for ( i=0; i<3; i++) {
		FromMat[4*i+0] = vx[i];
		FromMat[4*i+1] = vy[i];
		FromMat[4*i+2] = vz[i];
		FromMat[4*i+3] = Normal->point[i] - (offset * vz[i]);
	}
	FromMat[12] = FromMat[13] = FromMat[14] = 0.0;
	FromMat[15] = 1.0;
#ifdef TRACE
for (i=0;i<4;i++)
printf( "\t[%g\t%g\t%g\t%g]\n",
	FromMat[4*i+0], FromMat[4*i+1], FromMat[4*i+2], FromMat[4*i+3] );
#endif

wrapup:

	if (poly.points) { om$dealloc (ptr = poly.points); poly.points = NULL; }
	if (Plate)	 { om$dealloc (ptr = Plate); 	   Plate       = NULL; }
	if (Fram.objid != NULL_OBJID) {
		gr$delete_object ( msg = msg, md_env = Env, object_id = &Fram);
		Fram.objid = NULL_OBJID;	}
	if (Proj.objid != NULL_OBJID) {
		gr$delete_object ( msg = msg, md_env = Env, object_id = &Proj);
		Proj.objid = NULL_OBJID;	}
	if (Cntr.obj_id.objid != NULL_OBJID) {
		gr$delete_object ( msg	     = msg,
				   md_env    = &Cntr.mod_env,
				   object_id = &Cntr.obj_id);
		Cntr.obj_id.objid = NULL_OBJID;	}

	return (sts);

/*c End of function */
}
/*=========================================================================*/

IGRlong VLappFromMat           (struct GRobj_env       *Obj,
                                        IGRint          nobj,
                                 struct GRobj_env       *GndRef,
                                 struct GRvg_construct  *cst,
                                        IGRdouble       *FromMat,
                                        IGRboolean      CopyFlag,
                                        IGRboolean      display,
                                 struct GRobj_env       *Copy,
                                        IGRlong         *msg            )

/*d This fonction apply the transformation which could have been evaluated
    by VLevalFromMat().*/

/*h 20/october/92 JLL creation date */

/*c Beginning of function */
{

		IGRshort	trs_matrix_type;
		IGRint		i;
#ifdef	TRACE
		IGRint		j;
#endif
		IGRshort        four=4, trs_type;
		IGRlong		sts=MSFAIL;
		IGRmatrix	cs_mat, tmp_matrix, trs_matrix;
	struct	GRid		LocCopy;
	struct 	GRobj_env	*TmpSrf;
	struct  GRsymbology     symbology;
		BSrc		rc;

	/*c set the symbology to get the active one on the copy.*/
  	symbology.display_attr.color		= cst->display->color;
  	symbology.display_attr.weight		= cst->display->weight;
  	symbology.display_attr.style		= cst->display->style;
  	symbology.level				= cst->level;

	/*c retrieve the matrix of the ground coordinate system. */
	sts = om$send ( msg      = message GRgencs.GRgetmatrix ( msg, cs_mat),
			senderid = NULL_OBJID,
  	 		targetid = GndRef->obj_id.objid,
  	 		targetos = GndRef->obj_id.osnum );
	as$status ( sts = sts,
    		    msg = "GRgencs.GRgetmatrix",
    		    test = (!(sts & 0x00000001 & (*msg))),
    		    action = GOTO_VALUE,
    		    value  = wrapup );

	/*c Evaluate the transformation matrix.*/
  	MAinvmx ( &rc, &four, FromMat, tmp_matrix);
  	MAmulmx ( &rc, &four, &four, &four, cs_mat, tmp_matrix, trs_matrix);
	MAtypemx( &rc, trs_matrix, &trs_type);

	if (CopyFlag) {

	    	for ( i=0; i<nobj; i++) {
#ifdef TRACE
printf( "GRgraphics.GRcopy(%d|%d)\n",
	Obj[i].obj_id.osnum, Obj[i].obj_id.objid);
printf( "OBJECT MATRIX\tCONSTR MATRIX\tTRANSF MATRIX\n");
for (j=0;j<4;j++)
	printf( "[%g,%g,%g,%g]\t[%g,%g,%g,%g]\t[%g,%g,%g,%g]\n",
		Obj[i].mod_env.md_env.matrix[4*j+0],
		Obj[i].mod_env.md_env.matrix[4*j+1],
		Obj[i].mod_env.md_env.matrix[4*j+2],
		Obj[i].mod_env.md_env.matrix[4*j+3],
		cst->env_info->md_env.matrix[4*j+0],
		cst->env_info->md_env.matrix[4*j+1],
		cst->env_info->md_env.matrix[4*j+2],
		cst->env_info->md_env.matrix[4*j+3],
		trs_matrix[4*j+0],
		trs_matrix[4*j+1],
		trs_matrix[4*j+2],
		trs_matrix[4*j+3] );
#endif

			Copy[i].obj_id.objid = NULL_OBJID;
			Copy[i].obj_id.osnum = cst->env_info->md_id.osnum;
			Copy[i].mod_env      = *(cst->env_info);

			/*c copy of the given one.*/
  			sts = om$send ( msg = message GRgraphics.GRcopy (
						msg,
            					&Obj[i].mod_env,
						&Copy[i].mod_env,
						&Copy[i].obj_id.objid ),
			 		senderid = NULL_OBJID,
	   				targetid = Obj[i].obj_id.objid,
	   				targetos = Obj[i].obj_id.osnum );
			as$status ( sts = sts,
	    		    	    msg = "GRgraphics.GRcopy",
	    		    	    test = (!(sts & 0x00000001 & (*msg))),
	    		    	    action = GOTO_VALUE,
	    		    	    value  = wrapup );
#ifdef TRACE
printf( "Object (%d|%d) in (%d|%d) GRcopied as (%d|%d) in (%d|%d)\n",
	Obj[i].obj_id.osnum, Obj[i].obj_id.objid,
	Obj[i].mod_env.md_id.osnum, Obj[i].mod_env.md_id.objid,
	Copy[i].obj_id.osnum, Copy[i].obj_id.objid,
	Copy[i].mod_env.md_id.osnum, Copy[i].mod_env.md_id.objid );
printf( "From Matrix\tTo Matrix\n");
for (j=0;j<4;j++)
	printf( "\t[%g,%g,%g,%g]\t[%g,%g,%g,%g]\n",
Obj[i].mod_env.md_env.matrix[4*j],  
Obj[i].mod_env.md_env.matrix[4*j+1],
Obj[i].mod_env.md_env.matrix[4*j+2],
Obj[i].mod_env.md_env.matrix[4*j+3],
Copy[i].mod_env.md_env.matrix[4*j],
Copy[i].mod_env.md_env.matrix[4*j+1],
Copy[i].mod_env.md_env.matrix[4*j+2],
Copy[i].mod_env.md_env.matrix[4*j+3] );
#endif

			/*c xform of the given one.*/
  			sts = om$send ( msg = message GRgraphics.GRxform (
						msg,
						&Copy[i].mod_env,
						&trs_type,
						trs_matrix,
						&Copy[i].obj_id.objid ),
			 		senderid = NULL_OBJID,
	   				targetid = Copy[i].obj_id.objid,
	   				targetos = Copy[i].obj_id.osnum );
			as$status ( sts = sts,
	    		    	    msg = "GRgraphics.GRxform",
	    		    	    test = (!(sts & 0x00000001 & (*msg))),
	    		    	    action = GOTO_VALUE,
	    		    	    value  = wrapup );
		
			if (display) {
				/*c Apply the active symbology. */
	       			sts = om$send ( msg = message GRvg.GRputsymb
							( msg, &symbology),
			 	      senderid = NULL_OBJID,
                               	      targetid = Copy[i].obj_id.objid,
	                       	      targetos = Copy[i].obj_id.osnum  );
				as$status ( sts = sts,
	    		    	    	    msg = "GRvg.GRputsymb",
	    		    	    	    test = (!(sts & 0x00000001&(*msg))),
	    		    	    	    action = GOTO_VALUE,
	    		    	    	    value  = wrapup );

				/*c display the object if display = TRUE. */
	 			gr$display_object ( 
		     			object_id = &Copy[i].obj_id,
		     			mode      = GRbd );
			}

	    }
	    /*c End of GRcopy process on each Element.*/

	}
	else{
	/*c copy NOT reqiered then.*/

	    MAtypemx( &rc, trs_matrix, &trs_matrix_type);

	    /*c For all the Graphics objects do: */

	    for ( i=0; i<nobj; i++) {

		if (display) {
			/*c undisplay the object at the previous position.*/
			gr$display_object ( object_id = &Obj[i].obj_id,
		     		            mode      = GRbehe );
		}

		/*c copy and xform of the given one.*/
		TmpSrf = &Obj[i];
  		sts = om$send ( msg = message GRgraphics.GRxform (
					msg,
            				&TmpSrf->mod_env,
					&trs_matrix_type,
					trs_matrix,
					&LocCopy.objid ),
			 	senderid = NULL_OBJID,
	   			targetid = TmpSrf->obj_id.objid,
	   			targetos = TmpSrf->obj_id.osnum );
		as$status ( sts = sts,
	    		    msg = "GRgraphics.GRxform",
	    		    test = (!(sts & 0x00000001 & (*msg))),
	    		    action = GOTO_VALUE,
	    		    value  = wrapup );
		
		LocCopy.osnum = cst->env_info->md_id.osnum;

		/*c display the object if display = TRUE. */
	 	if( display == TRUE )
			gr$display_object ( object_id = &LocCopy,
				    	    mode      = GRbd );

	    }
	    /*c End of GRxform process on each Element.*/

	}

wrapup:
	return(sts);

/*c End of function */
}

/*=========================================================================*/
IGRlong VLevalAvNor( Obj, Nobj, AvgPnt, AvgNrm, msg )

/*d Giving a list of surfaces, This function evaluates an average normal and
    the center of gravity. */


/*h 21-Oct-1992	JLL creation date
    15-Dec-1993	MF correction : inside boundaries
    12-Jan-1994	MF correction : reversed normal property 
    14-Feb-1995 MF enhancement : standardize normal evaluation	*/
	   
struct	GRobj_env	*Obj;		/*I The input graphic objects */
	IGRint		Nobj;		/*I Number of graphic objects */
	IGRdouble	*AvgPnt;	/*O the approximate COG */
	IGRdouble	*AvgNrm;	/*O the approximate average normal */
	IGRlong		*msg;		/*O Return code MSSUCC or MSFAIL */

/*c Beginning of function */
{

	IGRlong		sts=MSFAIL;
	IGRint		i, Nsrf=0;
struct	GRobj_env	*Srf;


	/* Initialize */
	Srf = 0;
	if (Nobj < 1)	goto wrapup;

	/* Allocate memory */
	Srf = om$calloc ( num = Nobj, structure = struct GRobj_env);
	
	/* Find the maximun number of points which will be evaluated. This
	   loop is needed in the case of multiples surfaces.  */
	for ( i=0; i<Nobj; i++) {

		if (  (!vs$is_ancestry_valid(object  = &Obj[i].obj_id,
					     classid = OPP_GRcurve_class_id))
		   && (!vs$is_ancestry_valid(object  = &Obj[i].obj_id,
					     classid = OPP_VSfrzBeam_class_id))
		   && (!vs$is_ancestry_valid(object  = &Obj[i].obj_id,
					     classid = OPP_VSstfBeam_class_id))
		   && (!vs$is_ancestry_valid(object  = &Obj[i].obj_id,
					     classid = OPP_VLmrkLine_class_id))
		   && (!vs$is_ancestry_valid(object  = &Obj[i].obj_id,
					     classid = OPP_GRlbsys_class_id))) {
			Srf[Nsrf] = Obj[i];
			Nsrf++;
		}

	}

	if (!Nsrf)	goto wrapup;
	else {	sts = VLevalSrfGeometry
			( Srf, Nsrf, AvgPnt, AvgNrm, NULL, NULL, msg );
		as$status ( sts = sts,
	    	    	    msg = "VLevalSrfGeometry()",
	    	    	    test = (!(sts & 0x00000001 & (*msg))),
	    	    	    action = GOTO_VALUE,
	    	    	    value  = wrapup );
	}

wrapup:
	if (Srf) {	om$dealloc (ptr = Srf);	Srf = NULL;	}
	return (sts);

/*c End of function */
}
/*=========================================================================*/
IGRlong	VLdirectorCosine ( matrix, angle)

/*d Compute the director cosine of a given vector. */

/*h 21/04/1993 : creation by Marc FOURNIER (ISDC). */
	   
		IGRdouble	*matrix; /*I Input vector */
		IGRdouble	*angle;	 /*O Angles array */

/*c Beginning of function */
{
#ifdef TRACE
		IGRdouble	sA, sB, sC, cA, cB, cC;
#endif
	/*c Find Euler rotations */
	angle[1] = asin(matrix[8]) * -1.0;
	angle[2] = VLatan2 ( matrix[4] / cos(angle[1]) * -1.0,
			     matrix[0] / cos(angle[1]) ) * -1.0;
	angle[0] = VLatan2 ( matrix[9] / cos(angle[1]) * -1.0,
			     matrix[10]/ cos(angle[1]) ) * -1.0;
	if (  (matrix[0] != cos(angle[1]) * cos(angle[2]) )
	   && (matrix[4] != cos(angle[1]) * sin(angle[2]) * -1.0 )
	   && (matrix[8] != sin(angle[1]) * -1.0 ) ) {
		angle[1] = M_PI - angle[1];
		angle[2] = VLatan2 ( matrix[4] / cos(angle[1]) * -1.0,
			   	     matrix[0] / cos(angle[1]) );
		angle[0] = VLatan2 ( matrix[9] / cos(angle[1]) * -1.0,
			   	     matrix[10]/ cos(angle[1]) );
	}

#ifdef TRACE
sA = sin(angle[0]);	sB = sin(angle[1]);	sC = sin(angle[2]);
cA = cos(angle[0]);	cB = cos(angle[1]);	cC = cos(angle[2]);

matrix[0]  = cB * cC;
matrix[1]  = (cA * sC) - (sA * sB * cC);
matrix[2]  = (cA * sB * cC) + (sA * sC);
matrix[4]  = -1.0 * cB * sC;
matrix[5]  = (cA * cC) + (sA * sB * sC);
matrix[6]  = (sA * cC) - (cA * sB * sC);
matrix[8]  = -1.0 * sB;
matrix[9]  = -1.0 * sA * cB;
matrix[10] = cA * cB;

printf( "\t[%g\t%g\t%g\t%g]\n", matrix[0], matrix[1], matrix[2], matrix[3] );
printf( "\t[%g\t%g\t%g\t%g]\n", matrix[4], matrix[5], matrix[6], matrix[7] );
printf( "\t[%g\t%g\t%g\t%g]\n", matrix[8], matrix[9], matrix[10], matrix[11] );
printf( "\t[%g\t%g\t%g\t%g]\n", matrix[12], matrix[13], matrix[14], matrix[15]);
#endif

	return (OM_S_SUCCESS);

/*c End of function */
}
/*=========================================================================*/

/*=========================================================================*/
IGRlong	VLeulerCS (		IGRlong		*msg,
			struct	GRobj_env	*gcs,
				IGRdouble	*ang,
			struct	GRmd_env	*Env,
			struct	GRobj_env	*bcs	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i;
	IGRdouble	Rad[3];
	IGRmatrix	Grd, Eul, Inv, Tmp, Rot;
	IGRshort	Typ, four=4;
	BSrc		rc;
struct	GRid		balCS;
	IGRmatrix	Mx0, Mx1, Mx2;
	IGRvector	Axe;

	/* Initialize */
	*msg = MSFAIL;

	/* Convert entry Euler angles from degrees to radians */
	for ( i=0; i<3; i++ )	Rad[i] = ang[i] / 180.0 * M_PI;

	/* Build elementary rotation matrices */
	Axe[0] = 1.0;	Axe[1] = 0.0;	Axe[2] = 0.0;
	MArotmx ( &rc, Axe, &Rad[0], Mx0 );
	Axe[0] = 0.0;	Axe[1] = 1.0;	Axe[2] = 0.0;
	MArotmx ( &rc, Axe, &Rad[1], Mx1 );
	Axe[0] = 0.0;	Axe[1] = 0.0;	Axe[2] = 1.0;
	MArotmx ( &rc, Axe, &Rad[2], Mx2 );

	/* Build Euler matrix */
	MAmulmx  ( &rc, &four, &four, &four, Mx1, Mx0, Tmp );
	MAmulmx  ( &rc, &four, &four, &four, Mx2, Tmp, Eul );

	/* Get entry ground CS matrix */
	sts = om$send ( msg = message GRgencs.GRgetmatrix ( msg, Grd ),
			senderid = NULL_OBJID,
			targetid = gcs->obj_id.objid,
			targetos = gcs->obj_id.osnum );
	as$status ( sts = sts,
    	    	    msg = "GRgencs.GRgetmatrix",
    	    	    test = (!(sts & 0x00000001 & (*msg))),
    	    	    action = GOTO_VALUE,
    	    	    value  = wrapup );

	/* Build whole transformation matrix */
	MAinvmx  ( &rc, &four, Grd, Inv );
	MAmulmx  ( &rc, &four, &four, &four, Eul, Inv, Tmp );
	MAmulmx  ( &rc, &four, &four, &four, Grd, Tmp, Rot );
	MAtypemx ( &rc, Rot, &Typ );

	/* Delete entry balance CS (if needed) */
	if (bcs->obj_id.objid != NULL_OBJID) {
		sts = gr$delete_object ( msg	   = msg,
					 md_env	   = &bcs->mod_env,
					 object_id = &bcs->obj_id );
		as$status ( sts = sts,
	    	    	    msg = "gr$delete_object()",
	    	    	    test = (!(sts & 0x00000001 & (*msg))),
	    	    	    action = GOTO_VALUE,
	    	    	    value  = wrapup );
	}

	/* Copy entry ground CS in output balance CS */
	bcs->mod_env = *Env;
	sts = gr$copy_object ( msg	    = msg,
			       object_id    = &gcs->obj_id,
			       md_env	    = &gcs->mod_env,
			       new_env	    = &bcs->mod_env,
			       new_id       = &balCS,
			       display_flag = 0 );
	as$status ( sts = sts,
    	    	    msg = "gr$copy_object()",
    	    	    test = (!(sts & 0x00000001 & (*msg))),
    	    	    action = GOTO_VALUE,
    	    	    value  = wrapup );

	/* Apply Euler rotation matrix to output balance CS */
	sts = om$send ( msg = message GRgraphics.GRxform
			( msg, &bcs->mod_env, &Typ, Rot, &balCS.objid ),
			senderid = NULL_OBJID,
			targetid = balCS.objid,
			targetos = balCS.osnum );
	as$status ( sts = sts,
    	    	    msg = "GRgraphics.GRxform",
    	    	    test = (!(sts & 0x00000001 & (*msg))),
    	    	    action = GOTO_VALUE,
    	    	    value  = wrapup );

	/* Make source on output balance CS */
	as$make_source ( go_grid = balCS,
			 mod_env = &bcs->mod_env,
			 as_os   = bcs->mod_env.md_id.osnum,
			 as_grid = &bcs->obj_id );

	/* Make output balance CS support only */
	sts = om$send ( msg = message NDnode.NDchg_state
					( ND_SUP_ONLY, ND_SUP_ONLY ),
			senderid = NULL_OBJID,
			targetid = bcs->obj_id.objid,
			targetos = bcs->obj_id.osnum );
	as$status ( sts = sts,
    	    	    msg = "NDnode.NDchg_state",
    	    	    test = (!(sts & 0x00000001)),
    	    	    action = GOTO_VALUE,
    	    	    value  = wrapup );

	/* Redisplay entry ground CS */
	sts = gr$display_object ( object_id = &gcs->obj_id,
			          md_env    = &gcs->mod_env,
				  mode	    = GRbdhe );
	as$status ( sts = sts,
    	    	    msg = "gr$display_object()",
    	    	    test = (!(sts & 0x00000001)),
    	    	    action = GOTO_VALUE,
    	    	    value  = wrapup );

	/* Highlight output balance CS */
	sts = gr$display_object ( object_id = &bcs->obj_id,
			          md_env    = &bcs->mod_env,
				  mode	    = GRhd );
	as$status ( sts = sts,
    	    	    msg = "gr$display_object()",
    	    	    test = (!(sts & 0x00000001)),
    	    	    action = GOTO_VALUE,
    	    	    value  = wrapup );

wrapup:
	return (sts);
}
/*=========================================================================*/

end implementation VLabstract;
