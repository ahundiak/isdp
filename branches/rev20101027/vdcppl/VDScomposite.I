/* $Id: VDScomposite.I,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl / VDScomposite.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDScomposite.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
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

class implementation Root;

#include	<stdio.h>

#include        "OMprimitives.h"
#include        "OMmacros.h"
#include        "igetypedef.h"
#include        "igrtypedef.h"
#include        "gr.h"
#include        "igr.h"
#include        "igrdp.h"
#include        "griodef.h"
#include        "growner.h"
#include        "godef.h"
#include        "go.h"
#include        "dp.h"
#include        "grmacros.h"
#include        "bserr.h"
#include        "msdef.h"
#include        "EMSssprops.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"
#include        "emsmapdef.h"
#include        "emsimpdef.h"

extern	void		OrderCrv(), BuildCrv() ;
extern  IGRint          dblcpy();
extern  IGRboolean	dblcmp();
extern 	GRclassid	OPP_EMSgenbs_class_id;
extern 	GRclassid	OPP_EMSplane_class_id;

from	ACcpx		import	ACfind_exp_temp_obj, ACfind_temp_obj;
from	EMSgenbs	import	EMplace_skinning_surface;
from	EMSplane	import	EMplane_of_curve;
from	EMSsubbs	import	EMget_props, EMreduce_range;
from	EMSsurface	import	EMimpose_boundaries;
from	GRcompcurve	import	GRdelete, GRdrop;
from	GRcurve		import	GRendpts;
from	GRgraphics	import	GRcopy;
from	GRvg		import	GRdetplane;
from	NDmacro		import	ACreturn_foot;

/*============================================================================*/
IGRlong EvalPlateDir ( ASElem, NumComp, Orient, RefDir, msg)

	struct		GRid		*ASElem;   /* curves ID		(I)   */
	IGRint				NumComp;   /* curves number	(I)   */
	IGRdouble			Orient;	   /* reverse flag	(I)   */
	struct		IGRplane	*RefDir;   /* reference plane	(O)   */
	IGRlong				*msg;	   /* return code	(O)   */

{

	IGRint				stat=MSSUCC, rc;
	IGRint 				i;
	struct		GRid		AsObj, GrObj;
	IGRboolean			Plane;
	IGRshort			GOmatrix_type;
	IGRdouble			GOmatrix[16];
	GRclassid			obj_classid;
	IGRuchar			props;

  	Plane   = FALSE;
	*msg    = MSSUCC;

  	/* --- here We try the first plane which shoud be the third parent of
     	 	the web***  macro list.
	 	the first plane found will define the orientation of the
	 	web plate wich will placed later on by the regular Place Plate
	 	command in I/STRUCT.
	 	IF the construction is no plane THEN no direction will be set
  	--- */

 
  	for (i=0;i<NumComp;i++) {

		stat = om$send ( msg      = message ACcpx.ACfind_exp_temp_obj (
						&rc,
						2,
						&AsObj ),
				 senderid = NULL_OBJID,
 	      		         targetid = ASElem[i].objid,
	      		         targetos = ASElem[i].osnum );

        	if (stat&1&rc) {
	  		stat = om$send (
				msg      = message NDmacro.ACreturn_foot (
							msg ,
							"",
							&GrObj, 
							&GOmatrix_type, 
							GOmatrix ),
				senderid = NULL_OBJID,
				targetid = AsObj.objid,
	      			targetos = AsObj.osnum );

        		if (!(stat&1&(*msg))) {
EFmsgReport(0,stat,"NDmacro.ACreturn_foot : sts");
EFmsgReport(0,*msg,"NDmacro.ACreturn_foot : msg");
return (stat);
        		}

 			om$get_classid ( osnum     = GrObj.osnum, 
			 		 objid     = GrObj.objid, 
			 		 p_classid = &obj_classid);

 			if (om$is_ancestry_valid (
				subclassid   = obj_classid,
			  	superclassid = OPP_EMSplane_class_id )
				== OM_S_SUCCESS ) {
				Plane = TRUE;
				break;
  			}
		}
  	}


  	if( Plane == FALSE ) return (stat);

  	stat = om$send ( msg      = message EMSsubbs.EMget_props ( msg, &props),
			 senderid = NULL_OBJID,
	   		 targetid = GrObj.objid,
	   		 targetos = GrObj.osnum );
        if (!(stat&1&(*msg))) {
                EFmsgReport(0,stat,"EMSsubbs.EMget_props : sts");
                EFmsgReport(0,*msg,"EMSsubbs.EMget_props : msg");
		goto wrapup;
        }

  	stat = om$send ( msg      = message GRvg.GRdetplane ( 
					   	  msg,
						  &GOmatrix_type, 
						  GOmatrix,
                                           	  RefDir ),
			 senderid = NULL_OBJID,
	  	 	 targetid = GrObj.objid,
	  	 	 targetos = GrObj.osnum );

  	if (!(stat&1&(*msg)))	Plane = FALSE;
  	else 			Plane = TRUE;	

	for (i=0;i<3;i++)
		RefDir->normal[i] = Orient * RefDir->normal[i];
  	if (props & EMSIS_NRML_REVERSED) {
		for (i=0;i<3;i++)
			RefDir->normal[i] = -1.0 * RefDir->normal[i];
	}

  	return (stat);


wrapup:
	return (stat);
}
/*============================================================================*/
/* 	This function builds a encompassing plane 			      */
/*============================================================================*/
IGRlong BuildEmcPlane ( Edges, NumEdg, entries, cst, inv, adj, clo, 
			RefDir, Planar, Plane, msg, delflag)

	struct		GRobj_env	Edges[];
			IGRint		NumEdg;
	struct		GRlc_info	entries[];
	struct		GRvg_construct	*cst;
			IGRshort	*inv;
			IGRboolean	adj;
			IGRboolean	clo;
	struct		IGRplane	RefDir;
			IGRboolean	*Planar;
	struct		GRid		*Plane;
			IGRlong		*msg;
			IGRboolean	delflag;
{

	struct		IGRplane	PlaCou;
	struct		GRlc_info	Contour;
			IGRdouble	bid[6];
			IGRlong		stat=MSSUCC, sts;
			IGRpoint	pt;
			IGRint		i;
			IGRint		siz;
			IGRlong		ret;

	PlaCou.point  = &bid[0];
	PlaCou.normal = &bid[3];

	*msg = BSFAIL;

	for (i=0;i<NumEdg;i++) {
  		entries[i].located_obj = Edges[i].obj_id;
  		entries[i].module_info = Edges[i].mod_env;
	}

	Contour.located_obj.objid = NULL_OBJID;
	Contour.located_obj.osnum = cst->env_info->md_id.osnum;

	BuildCrv ( 2, Edges, NumEdg, inv, adj, clo, entries, cst,
                          &Contour.located_obj, msg);
        if (*msg != BSSUCC) {
		EFmsgReport ( 0, *msg, "BuildCrv() : msg");
                goto wrapup;
        }

	stat = om$send ( msg      = message GRvg.GRdetplane (
					msg,
					&cst->env_info->md_env.matrix_type,
					cst->env_info->md_env.matrix,
					&PlaCou ),
			 senderid = NULL_OBJID,
			 targetid = Contour.located_obj.objid,
			 targetos = Contour.located_obj.osnum );

	if (!(stat&1&(*msg))) {
		*Planar = FALSE;
		stat = OM_S_SUCCESS;
		*msg = MSSUCC;
		goto compcase;
	}
	else {
		*Planar = TRUE;
		for (i=0;i<3;i++) {
			pt[i] = RefDir.point[i] + (100.0 * RefDir.normal[i]);
		}

		Plane->objid  = NULL_OBJID;
		Plane->osnum  = cst->env_info->md_id.osnum;
                cst->geometry = NULL;

                stat = om$construct ( classid = OPP_EMSplane_class_id,
                                      p_objid = &Plane->objid,
                                      osnum   = Plane->osnum );

		siz = sizeof(struct GRmd_env);
		gr$get_module_env ( msg    = msg,
				    sizbuf = &siz,
				    buffer = &(Contour.module_info),
				    nret   = &ret );

		stat = om$send ( msg      = message EMSplane.EMplane_of_curve (
						msg,
						cst,
						&Contour,
						NULL,
						NULL,
						(IGRboolean) FALSE,
						(IGRboolean) TRUE,
						pt,
						NULL ),
			 	 senderid = NULL_OBJID,
				 targetid = Plane->objid,
				 targetos = Plane->osnum );
		if (!(stat&1&(*msg))) {
                        EFmsgReport(0,stat,"EMSplane.EMplane_of_curve : sts");
                        EFmsgReport(0,*msg,"EMSplane.EMplane_of_curve : msg");
                }
	}

compcase:
	if (delflag == TRUE) {	/* For impose boundary case */
		sts = om$send ( msg      = message GRcompcurve.GRdelete (
                                                msg,
                                                cst->env_info ),
			 	senderid = NULL_OBJID,
                        	targetid = Contour.located_obj.objid,
                        	targetos = Contour.located_obj.osnum );
		if (!(sts&1&(*msg))) {
			EFmsgReport(0, sts,"GRcompcurve.GRdelete : sts");
			EFmsgReport(0,*msg,"GRcompcurve.GRdelete : msg");
		}
	}
	else {			/* For skinning surface case */
		sts = om$send ( msg      = message GRcompcurve.GRdrop (
                                                msg,
                                                cst->env_info ),
                        	senderid = NULL_OBJID,
                        	targetid = Contour.located_obj.objid,
                        	targetos = Contour.located_obj.osnum );
		if (!(sts&1&(*msg))) {
			EFmsgReport(0, sts,"GRcompcurve.GRdrop : sts");
			EFmsgReport(0,*msg,"GRcompcurve.GRdrop : msg");
		}
	}

wrapup:
	return (stat);
}
/*============================================================================*/
/* 	This function builds a skinning surface				      */
/*============================================================================*/
IGRlong BuildSkinSrf ( RefDir, Edges, NumEdg, inv, adj, clo, cst, PlaOrSrf, msg)

	struct		IGRplane	RefDir;      /* reference plane   (I) */
	struct		GRobj_env	Edges[];     /* edges array       (I) */
	IGRint				NumEdg;	     /* edges number      (I) */
	IGRshort			*inv;	     /* inversion flags   (I) */
	IGRboolean			adj;	     /* adjusted flag     (I) */
	IGRboolean			clo;	     /* closed flag       (I) */
	struct		GRvg_construct	*cst;	     /* cst		  (I) */
	struct		GRid		*PlaOrSrf;   /* plane/surface     (O) */
	IGRlong				*msg;	     /* return code       (O) */

{

/* ---
	this function perform the surface generation based on 4 edges.
	Two types of surface could be generated:
		IF  the 4 edges are lying the same plane THEN we
		  build an plane encompassing the 4 elements.

	        ElSE we perform a skinning surface with two traces and
		  two edges

--- */

	IGRlong				stat=MSSUCC;
	IGRboolean			Planar;
	struct		GRlc_info	trace[2], cross[2], dummy;
	struct  	GRlc_info	entries[4];
	IGRboolean			surface_is_open, absolute_orientation;
	IGRboolean			no_height_scaling;

	IGRpoint			dummypt;


  	*msg = BSFAIL;

	stat = BuildEmcPlane ( Edges, NumEdg, entries, cst, inv, adj, clo,
			       RefDir, &Planar, PlaOrSrf, msg, FALSE);
        if (!(stat&1&(*msg))) {
                EFmsgReport(0,stat,"BuildEmcPlane() : sts");
                EFmsgReport(0,*msg,"BuildEmcPlane() : msg");
		goto wrapup;
        }

  	if (Planar == FALSE) {

		/*--- Build a skinning surface ---*/
		#ifdef TRACE
		for (i=0;i<4;i++) {
			printf ( "entry[%d] : (%d/%d)\n", i,
				 entries[i].located_obj.objid,
				 entries[i].located_obj.osnum);
		} 
		#endif

  		surface_is_open      = TRUE;
  		no_height_scaling    = TRUE;
  		absolute_orientation = FALSE;

		/* Retrieve traces & cross_sections */
		trace[1] = entries[0];
		cross[1] = entries[1];
		trace[0] = entries[2];
		cross[0] = entries[3];

		/* Initialize inversion flags */
		trace[0].geom_parms.polygon_inx = TRUE;
		cross[0].geom_parms.polygon_inx = FALSE;
		trace[1].geom_parms.polygon_inx = FALSE;
		cross[1].geom_parms.polygon_inx = TRUE;

		/* Find start point */
		om$send ( msg      = message GRcurve.GRendpts (
					msg,
					&cst->env_info->md_env.matrix_type,
					cst->env_info->md_env.matrix,
					cross[0].proj_pnt,
					dummypt ),
			  senderid = NULL_OBJID,
	  		  targetid = cross[0].located_obj.objid,
	  		  targetos = cross[0].located_obj.osnum );

		om$send ( msg      = message GRcurve.GRendpts (
					msg,
					&cst->env_info->md_env.matrix_type,
					cst->env_info->md_env.matrix,
					cross[1].proj_pnt,
					dummypt ),
			  senderid = NULL_OBJID,
	  		  targetid = cross[1].located_obj.objid,
	  		  targetos = cross[1].located_obj.osnum );

		om$send ( msg      = message GRcurve.GRendpts (
					msg,
					&cst->env_info->md_env.matrix_type,
					cst->env_info->md_env.matrix,
					trace[0].proj_pnt,
					dummypt ),
			  senderid = NULL_OBJID,
	  		  targetid = trace[0].located_obj.objid,
	  		  targetos = trace[0].located_obj.osnum );

		om$send ( msg      = message GRcurve.GRendpts (
					msg,
					&cst->env_info->md_env.matrix_type,
					cst->env_info->md_env.matrix,
					trace[1].proj_pnt,
					dummypt ),
			  senderid = NULL_OBJID,
	  		  targetid = trace[1].located_obj.objid,
	  		  targetos = trace[1].located_obj.osnum );

#ifdef TRACE
for (i=0;i<2;i++) {
	printf ( "cross[%d] : (%d/%d)\t[ %f, %f, %f]\t<%d>\n", i,
	cross[i].located_obj.objid, cross[i].located_obj.osnum,
	cross[i].proj_pnt[0], cross[i].proj_pnt[1], cross[i].proj_pnt[2],
	cross[i].geom_parms.polygon_inx);
}
for (i=0;i<2;i++) {
	printf ( "trace[%d] : (%d/%d)\t[ %f, %f, %f]\t<%d>\n", i,
	trace[i].located_obj.objid, trace[i].located_obj.osnum,
	trace[i].proj_pnt[0], trace[i].proj_pnt[1], trace[i].proj_pnt[2],
	trace[i].geom_parms.polygon_inx);
}
#endif

		PlaOrSrf->objid  = NULL_OBJID;
		PlaOrSrf->osnum  = cst->env_info->md_id.osnum;
                cst->geometry    = NULL;

                stat = om$construct ( classid = OPP_EMSgenbs_class_id,
                                      p_objid = &PlaOrSrf->objid,
                                      osnum   = PlaOrSrf->osnum );
  		stat = om$send ( 
			msg      = message EMSgenbs.EMplace_skinning_surface (
					msg,
					cst,
					(IGRlong)2,
					trace,
					(IGRlong)2,
					cross,
					surface_is_open,
					NULL,
					absolute_orientation,
					no_height_scaling,
					NULL,
					NULL ),
			senderid = NULL_OBJID,
            		targetid = PlaOrSrf->objid,
            		targetos = PlaOrSrf->osnum );

		if (!(stat&(*msg)&1)) {
			printf ( " on first trial\n");
		/* Inverse cross_sections */
		dummy    = cross[0];
		cross[0] = cross[1];
		cross[1] = dummy;

		/* Inverse traces */
		dummy    = trace[0];
		trace[0] = trace[1];
		trace[1] = dummy;

		/* Set new flags */
		trace[0].geom_parms.polygon_inx = TRUE;
		cross[0].geom_parms.polygon_inx = FALSE;
		trace[1].geom_parms.polygon_inx = FALSE;
		cross[1].geom_parms.polygon_inx = TRUE;

		#ifdef TRACE
		printf("\n");
		for (i=0;i<2;i++) {
			printf ( "cross[%d] : (%d/%d)\t[ %f, %f, %f]\t<%d>\n",
				 i,
				 cross[i].located_obj.objid,
				 cross[i].located_obj.osnum,
				 cross[i].proj_pnt[0],
				 cross[i].proj_pnt[1],
				 cross[i].proj_pnt[2],
				 cross[i].geom_parms.polygon_inx);
		}
		for (i=0;i<2;i++) {
			printf ( "trace[%d] : (%d/%d)\t[ %f, %f, %f]\t<%d>\n",
				 i,
				 trace[i].located_obj.objid,
				 trace[i].located_obj.osnum,
				 trace[i].proj_pnt[0],
				 trace[i].proj_pnt[1],
				 trace[i].proj_pnt[2],
				 trace[i].geom_parms.polygon_inx);
		}
		#endif

		stat = MSSUCC;
		*msg = MSSUCC;
		PlaOrSrf->objid = NULL_OBJID;
  		stat = om$send ( 
			msg      = message EMSgenbs.EMplace_skinning_surface (
					msg,
					cst,
					(IGRlong)2,
					trace,
					(IGRlong)2,
					cross,
					surface_is_open,
					NULL,
					absolute_orientation,
					no_height_scaling,
					NULL,
					NULL ),
			senderid = NULL_OBJID,
            		targetid = PlaOrSrf->objid,
            		targetos = PlaOrSrf->osnum );
		}
		if (!(stat&(*msg)&1)) {
			printf ( " on last trial\n");
			EFmsgReport ( 0, stat,
				"EMSgenbs.EMplace_skinning_surface : sts");
			EFmsgReport ( 0, *msg, 
				"EMSgenbs.EMplace_skinning_surface : suc");
			EFmsgReport ( 0, cst->msg, 
				"EMSgenbs.EMplace_skinning_surface : msg");
			goto wrapup;
  		}

		*msg = MSSUCC;


  	} /* end of skinning case */
wrapup:
	return (stat);
}
/*============================================================================*/
/*	This function extracts the array of endpoints of the edges	      */
/*============================================================================*/
IGRlong ExtractSegPts ( NumComp, Edges, SegPt, msg)

	IGRint				NumComp; /* number of edges	(I)   */
	struct		GRobj_env	*Edges;  /* edges array 	(I)   */
	IGRdouble			*SegPt;  /* endpoints array 	(O)   */
	IGRlong				*msg;	 /* return code		(O)   */

{

	IGRint				i, j;
	IGRlong				stat=MSSUCC;

	for (i=0;i<NumComp;i++) {
		for (j=0;j<4;j++) {
			stat =
			om$send ( msg      = message GRcurve.GRendpts ( 
				       msg,
				       &Edges[4*i+j].mod_env.md_env.matrix_type,
				       Edges[4*i+j].mod_env.md_env.matrix,
				       &SegPt[24*i+6*j],
				       &SegPt[24*i+6*j+3] ),
				  senderid = NULL_OBJID,
			  	  targetid = Edges[4*i+j].obj_id.objid,
			  	  targetos = Edges[4*i+j].obj_id.osnum );
        		if (!(stat&1&(*msg))) {
                		EFmsgReport(0,stat,"GRcurve.GRendpts : sts");
                		EFmsgReport(0,*msg,"GRcurve.GRendpts : msg");
        		}
		}
	}
	return (stat);
}
/*============================================================================*/
/*	This function finds the 4 corners of several constructions and	      */
/*	fill on index array pointing on the points arrays.		      */
/*============================================================================*/
IGRboolean FindFourCorners ( NumComp, SegPt, CrnPt, DistTol)

	IGRint 			NumComp;	/* components number	(I)   */
	IGRdouble		*SegPt;		/* endpoints array	(I)   */
	IGRint			*CrnPt;		/* corners index array	(O)   */
	IGRdouble		DistTol;	/* minimal distance	(I)   */

{

	IGRint			i;

	for (i=0;i<NumComp;i++) {
#ifdef DEBUG
printf("\ti=%d < %d, DistTol=%f\n", i, NumComp, DistTol);
#endif
		/* CORNER 0 (start curve) */
		CrnPt[4*i] = 8*i;
#ifdef DEBUG
printf("\tCrnPt[%d] = %d\n", 4*i, CrnPt[4*i]);
#endif

		/* CORNER 2 (plate curve) & CORNER 3 (flange curve) */
		if (      (dblcmp( &SegPt[24*i+12],
			           &SegPt[24*i+3],
				   DistTol,
				   3) == TRUE)
	       	       || (dblcmp( &SegPt[24*i+15],
				   &SegPt[24*i+3],
				   DistTol,
				   3) == TRUE) ) {
	        	CrnPt[4*i+2] = 8*i+1;
			if (dblcmp( &SegPt[24*i+18],
			    	    &SegPt[3*CrnPt[4*i]],
			    	    DistTol,
			    	    3) == FALSE)
	                	CrnPt[4*i+3] = 8*i+6;
			else	CrnPt[4*i+3] = 8*i+7;
		}
		else if ( (dblcmp( &SegPt[24*i+18],
				   &SegPt[24*i+3],
				   DistTol,
				   3) == TRUE)
	               || (dblcmp( &SegPt[24*i+21],
				   &SegPt[24*i+3],
				   DistTol,
				   3) == TRUE) ) {
	        	CrnPt[4*i+3] = 8*i+1;
			if (dblcmp( &SegPt[24*i+12],
			            &SegPt[3*CrnPt[4*i]],
			            DistTol,
			            3) == FALSE)
	                	CrnPt[4*i+2] = 8*i+4;
			else	CrnPt[4*i+2] = 8*i+5;
		}
#ifdef DEBUG
printf("\tCrnPt[%d] = %d\n", 4*i+2, CrnPt[4*i+2]);
printf("\tCrnPt[%d] = %d\n", 4*i+3, CrnPt[4*i+3]);
#endif


		/* CORNER 1 (end curve) */
		if      (  (dblcmp( &SegPt[3*CrnPt[4*i+2]],
			    	    &SegPt[24*i+6],
			    	    DistTol,
			    	    3) == FALSE)
	        	&& (dblcmp( &SegPt[3*CrnPt[4*i+3]],
			    	    &SegPt[24*i+6],
			    	    DistTol,
			    	    3) == FALSE) )
			CrnPt[4*i+1] = 8*i+2;
		else if (  (dblcmp( &SegPt[3*CrnPt[4*i+2]],
			    	    &SegPt[24*i+9],
			    	    DistTol,
			    	    3) == FALSE)
	        	&& (dblcmp( &SegPt[3*CrnPt[4*i+3]],
			    	    &SegPt[24*i+9],
			    	    DistTol,
			    	    3) == FALSE) )
			CrnPt[4*i+1] = 8*i+3;
		else 	return FALSE;
#ifdef DEBUG
printf("\tCrnPt[%d] = %d\n", 4*i+1, CrnPt[4*i+1]);
#endif
	}
	return TRUE;
}
/*============================================================================*/
/*	This function finds the common edges of constructions. An index array */
/*	pointing on common corner points is filled. An index array pointing   */
/*	on common edges is also filled.					      */
/*============================================================================*/
IGRboolean CurveNotInContour ( NumComp, SegPt, CrnPt, ComPt, DelCv, DistTol)

	IGRint				NumComp;  /* components number   (I)  */
	IGRdouble			*SegPt;   /* endpoints arrays	 (I)  */
	IGRint				*CrnPt;	  /* corners index array (I)  */
	IGRint				*ComPt;   /* common points index (O)  */
	IGRint				*DelCv;	  /* common edges index  (O)  */
	IGRdouble			DistTol;  /* minimal distance	 (I)  */

{
	IGRint				i, j, k, idx;
	IGRlong				stat=TRUE;

	for (i=1;i<NumComp;i++) {
		idx = 0;
		for (j=0;j<4;j++) {
			for (k=0;k<4;k++) {
				if ( dblcmp ( &SegPt[3*CrnPt[(4*(i-1))+j]],
					      &SegPt[3*CrnPt[(4*i)    +k]],
					      DistTol,
					      3) == TRUE) {
					if (idx > 1) {
						stat = FALSE;
						goto wrapup;
					}
				ComPt[2*i+idx] = CrnPt[(4*i)+k];
				idx = idx + 1;
				}
			}
		}

		for (j=0;j<4;j++) {
			if (  (  (dblcmp ( &SegPt[3*ComPt[2*i]],
					   &SegPt[(24*i)+(6*j)],
					   DistTol,
					   3) == TRUE)
      			      && (dblcmp ( &SegPt[3*ComPt[2*i+1]],
					   &SegPt[(24*i)+(6*j)+3],
					   DistTol,
					   3) == TRUE) )
   			   || (  (dblcmp ( &SegPt[3*ComPt[2*i+1]],
					   &SegPt[(24*i)+(6*j)],
					   DistTol,
					   3) == TRUE)
      			      && (dblcmp ( &SegPt[3*ComPt[2*i]],
					   &SegPt[(24*i)+(6*j)+3],
					   DistTol,
					   3) == TRUE) ) ) {
				DelCv[i] = 4*i+j;
				break;
			}
		}
	}
wrapup:
	return (stat);
}
/*============================================================================*/
/*	This function recognize curves that will be in the final contour. An  */
/*	array of index is fiiles.					      */
/*============================================================================*/
IGRboolean CurveInContour ( NumComp, SegPt, DelCv, ComPt, ActCv, DistTol)

	IGRint			NumComp; /* curves number 	(I)	*/
	IGRdouble		*SegPt;	 /* endpoints array 	(I)	*/
	IGRint			*DelCv;  /* del curves pointers (I)	*/
	IGRint			*ComPt;  /* common points	(I)	*/
	IGRint			*ActCv;  /* selected points	(O)	*/
	IGRdouble		DistTol; /* minimal distance	(I)	*/

{
	IGRint			i, j;
	IGRint			comidx=0;

	if (NumComp == 0)	return (FALSE);

	for (i=1;i<NumComp;i++) {
		for (j=0;j<2;j++) {
			if (dblcmp ( &SegPt[3*ComPt[2*i+j]],
				     &SegPt[6*ActCv[i-1]],
				     DistTol,
				     3) == TRUE) {
				comidx = 3*ComPt[2*i+j];
				break;
			}
			else if (dblcmp ( &SegPt[3*ComPt[2*i+j]],
				          &SegPt[6*ActCv[i-1]+3],
				          DistTol,
				          3) == TRUE) {
				comidx = 3*ComPt[2*i+j];
				break;
			}
		}
		for (j=0;j<4;j++) {
			if (dblcmp ( &SegPt[6*(4*i+j)],
				     &SegPt[comidx],
				     DistTol,
				     3) == TRUE) {
				if (4*i+j != DelCv[i]) {
					ActCv[i] = 4*i+j;
					break;
				}
			}
			else if (dblcmp ( &SegPt[6*(4*i+j)+3],
				     &SegPt[comidx],
				     DistTol,
				     3) == TRUE) {
				if (4*i+j != DelCv[i]) {
					ActCv[i] = 4*i+j;
					break;
				}
			}
		}
	}

	return (TRUE);
}
/*===========================================================================*/
IGRlong ConstructLine ( NumComp, CrvIn, cst, NewEdge, BaseTol, DistTol)

	IGRint				NumComp;  /* curves number 	(I)   */
	struct		GRobj_env	*CrvIn;	  /* curves array	(I)   */
	struct		GRvg_construct	*cst;	  /* cst		(I)   */
	struct  	GRid		*NewEdge; /* build curve	(O)   */
	IGRdouble			BaseTol;  /* basic tolerance	(I)   */
	IGRdouble			DistTol;  /* minimal distance	(I)   */

{

	IGRint				i;
	IGRlong				msg;
	struct		GRobj_env	*CrvOut;
	IGRshort			*inv;
	IGRboolean			adj;
	IGRboolean			clo;
	struct		GRlc_info	*entries;

	/* Initialization */
	CrvOut  = NULL;
	inv     = NULL;
	entries = NULL;

	/* Memory allocation */
	CrvOut  = (struct GRobj_env *)	om$malloc (
			size = NumComp * sizeof(struct GRobj_env));
	inv     = (IGRshort *)		om$malloc (
			size = NumComp * sizeof(IGRshort));
	entries = (struct GRlc_info *)	om$malloc (
			size = NumComp * sizeof(struct GRlc_info));

	/* Order curves */
	OrderCrv ( CrvIn, NumComp, DistTol, BaseTol,
		          CrvOut, inv, &adj, &clo, &msg);
	if (msg != BSSUCC) {
		EFmsgReport ( 0, msg,"OrderCrv() : msg");
		goto wrapup;
	}
        #ifdef JLL
        printf ("OrderCrv() returns adj=%d, clo=%d, msg=%d\n",
                adj, clo, msg);
        for (i=0;i<NumComp;i++) {
                printf ("CrvIn=(%d/%d)\tCrvOut=(%d/%d)\tinv=%d\n",
                CrvIn[i].obj_id.objid, CrvIn[i].obj_id.osnum,
                CrvOut[i].obj_id.objid, CrvOut[i].obj_id.osnum,
                inv[i] );
        }
        #endif

	/* Build curve */
	for (i=0;i<NumComp;i++) {
		entries[i].module_info = CrvOut[i].mod_env;
		entries[i].located_obj = CrvOut[i].obj_id;
	}
	BuildCrv ( 0, CrvOut, NumComp, inv, adj, clo, entries, cst,
		          NewEdge , &msg);
	if (msg != BSSUCC) {
		EFmsgReport ( 0, msg,"BuildCrv() : msg");
		goto wrapup;
	}

wrapup:
	if (entries != NULL)	om$dealloc ( ptr = entries );
	if (inv != NULL)	om$dealloc ( ptr = inv );
	if (CrvOut != NULL)	om$dealloc ( ptr = CrvOut );

        if (msg == BSSUCC)      return (MSSUCC);
        else                    return (MSFAIL);
}
/*===========================================================================*/
/*	This function prepares the call of ConstructLine(). An array of	      */
/*	points is extracted from the general storage array by using the input */
/*	array of pointers.						      */
/*============================================================================*/
IGRlong GroupCurvesInOne ( NumComp, Edges, ActCv, cst,
			   NewEdge, BaseTol, DistTol)

	IGRint				NumComp;  /* curves number 	(I)   */
	struct		GRobj_env	*Edges;	  /* cuves array 	(I)   */
	IGRint				*ActCv;	  /* points index array (I)   */
	struct		GRvg_construct	*cst;	  /* cst		(I)   */
	struct  	GRid		*NewEdge; /* builded curve	(O)   */
	IGRdouble			BaseTol;  /* basic tolerance	(I)   */
	IGRdouble			DistTol;  /* minimal distance	(I)   */

{

	IGRint				i;
	struct		GRobj_env	*CrvIn;
	IGRlong				stat=MSSUCC;

	/* Initialization */
	CrvIn   = NULL;

	/* Memory allocation */
	CrvIn   = (struct GRobj_env *)	om$malloc (
			size = NumComp * sizeof(struct GRobj_env));

	/* Fill CrvIn GRobj_env structure */
	for (i=0;i<NumComp;i++) CrvIn[i] = Edges[ActCv[i]];

	/* Call line construction */
	stat = ConstructLine ( NumComp, CrvIn, cst, NewEdge, BaseTol, DistTol);
	if (stat != MSSUCC) EFmsgReport ( 0, stat,"ConstructLine() : sts");

	/* Memory deallocation */
	if (CrvIn != NULL)	om$dealloc ( ptr = CrvIn );

	return (stat);
}
/*===========================================================================*/
/*	This function extracts the boundary edges of several constructions.   */
/*============================================================================*/
IGRlong BuildExtFourEdges ( Edges, NumComp, cst, DistTol, BaseTol,
		    	    NewEdges, NewNumEdg, CurveOrig, msg)

	struct		GRobj_env	Edges[];    /* edges array	(I)   */
	IGRint				NumComp;    /* edges number	(I)   */
	struct		GRvg_construct	*cst;	    /* cst		(I)   */
	IGRdouble			DistTol;    /* minimal distance	(I)   */
	IGRdouble			BaseTol;    /* basic tolerance  (I)   */
	struct		GRobj_env	NewEdges[]; /* out edges array  (O)   */
	IGRint				*NewNumEdg; /* out edges number (O)   */
	IGRdouble			*CurveOrig; /* origin points	(O)   */
	IGRlong				*msg;	    /* return code 	(O)   */

{

	IGRlong				stat=MSSUCC;
	IGRint				i;
	IGRint				StaCv, EndCv=0;
	IGRdouble			*SegPt;
	IGRint				*CrnPt;
	IGRint				*ComPt;
	IGRint				*DelCv;
	IGRint				*PltCv;
	IGRint				*FlgCv;
	IGRdouble			ept[24];

	CrnPt = ComPt = DelCv = PltCv = FlgCv = NULL;

	#ifdef DEBUG
	for (i=0;i<4*NumComp;i++)
		printf( "received edge[%d] is (%d|%d) in (%d|%d)\n", i,
			Edges[i].obj_id.objid, Edges[i].obj_id.osnum,
			Edges[i].mod_env.md_id.objid,
			Edges[i].mod_env.md_id.osnum );
	#endif

	/* Initialize */
	NewEdges[2].obj_id.objid = NULL_OBJID;
	NewEdges[2].obj_id.osnum = cst->env_info->md_id.osnum;


	/* Extract start/end points of curves */
	SegPt = (IGRdouble *)om$malloc ( size = 24*NumComp*sizeof(IGRdouble) );
	stat = ExtractSegPts ( NumComp, Edges, SegPt, msg);
	if (!(stat&(*msg)&1)) {
                EFmsgReport(0,stat,"ExtractSegPts() : sts");
                EFmsgReport(0,*msg,"ExtractSegPts() : msg");
		goto wrapup;
	}


	/* Find the 4 corners of each component */
	CrnPt = (IGRint *)   om$malloc ( size = 4 * NumComp * sizeof(IGRint) );
	if (FindFourCorners( NumComp, SegPt, CrnPt, DistTol) == FALSE) {
		printf("Error in FindFourCorners()\n");
		goto wrapup;
	}

	DelCv = (IGRint *)   om$malloc ( size =     NumComp * sizeof(IGRint) );
	/* Detect if the first curve is a end_curve instead of a start_curve */
	StaCv    = 0;
	DelCv[0] = 1;
	if (NumComp > 1) {
		for (i=0;i<4;i++) {
			if (dblcmp ( &SegPt[3*CrnPt[0]],
				     &SegPt[3*CrnPt[4+i]],
				     DistTol, 3 ) == TRUE) {
				StaCv    = 1;
				DelCv[0] = 0;
				i = 4;
			}
		}
	}
	#ifdef DEBUG
	printf("The start curve is the number %d\n", StaCv);
	#endif


	/* Copy start curve */
	stat = om$send ( msg      = message GRgraphics.GRcopy (
						msg,
						&Edges[StaCv].mod_env,
						cst->env_info,
						&NewEdges[2].obj_id.objid ),
			 senderid = NULL_OBJID,
			 targetid = Edges[StaCv].obj_id.objid,
			 targetos = Edges[StaCv].obj_id.osnum );

	if (!(stat&(*msg)&1)) {
                EFmsgReport(0,stat,"GRgraphics.GRcopy : sts");
                EFmsgReport(0,*msg,"GRgraphics.GRcopy : msg");
		goto wrapup;
	}
/*
printf("\t>>> NewEdges[2] = Edges[%d]\n", StaCv);
NewEdges[2] = Edges[StaCv];
*/


	/* Find common corners & border curves */
	ComPt = (IGRint *)   om$malloc ( size = 2 * NumComp * sizeof(IGRint) );
	ComPt[0] = -1;
	ComPt[1] = -1;

	if (CurveNotInContour ( NumComp, SegPt, CrnPt,
				ComPt, DelCv, DistTol) == FALSE) {
		printf("Error in CurveNotInContour()\n");
		goto wrapup;
	}

	#ifdef DEBUG
	for (i=0;i<NumComp;i++) {
		printf("Curve %d : (%d/%d) not in final countour\n", DelCv[i],
		       Edges[DelCv[i]].obj_id.objid,
		       Edges[DelCv[i]].obj_id.osnum );
	}
	#endif


	/* Determination of PLATE CURVES */
	PltCv = (IGRint *)   om$malloc ( size = NumComp * sizeof(IGRint) );
	PltCv[0] = 2;
	if ( CurveInContour ( NumComp, SegPt, DelCv, ComPt, PltCv, DistTol) == FALSE ) {
		printf ( "Error in CurveInContour()\n");
		goto wrapup;
	}
	stat = GroupCurvesInOne ( NumComp, Edges, PltCv, cst,
			          &NewEdges[0].obj_id, BaseTol, DistTol);
	if (!(stat&1)) {
                EFmsgReport(0,stat,"GroupCurvesInOne() : sts");
		goto wrapup;
	}


	/* Determination of FLANGE CURVES */
	FlgCv = (IGRint *)   om$malloc ( size = NumComp * sizeof(IGRint) );
	FlgCv[0] = 3;
	if ( CurveInContour ( NumComp, SegPt, DelCv, ComPt, FlgCv, DistTol) == FALSE ) {
		printf ( "Error in CurveInContour()\n");
		goto wrapup;
	}
	stat = GroupCurvesInOne ( NumComp, Edges, FlgCv, cst,
			          &NewEdges[1].obj_id, BaseTol, DistTol);
	if (!(stat&1)) {
                EFmsgReport(0,stat,"GroupCurvesInOne() : sts");
		goto wrapup;
	}


	/* Determination of END CURVE */
	if (NumComp == 1) EndCv = 1;
	else {
		for (i=0;i<4;i++) {
			if ( ((4*(NumComp-1)+i) != DelCv[NumComp-1])
			&&   ((4*(NumComp-1)+i) != PltCv[NumComp-1])
			&&   ((4*(NumComp-1)+i) != FlgCv[NumComp-1]) ) {
				EndCv = 4*(NumComp-1)+i;
				break;
			}
		}
	}


	stat = om$send ( msg      = message GRgraphics.GRcopy (
						msg,
						&Edges[EndCv].mod_env,
						cst->env_info,
						&NewEdges[3].obj_id.objid ),
			 senderid = NULL_OBJID,
			 targetid = Edges[EndCv].obj_id.objid,
			 targetos = Edges[EndCv].obj_id.osnum );
	if (!(stat&(*msg)&1)) {
                EFmsgReport(0,stat,"GRgraphics.GRcopy : sts");
                EFmsgReport(0,*msg,"GRgraphics.GRcopy : msg");
		goto wrapup;
	}
	NewEdges[3].obj_id.osnum = cst->env_info->md_id.osnum;
/*
printf("\t>>> NewEdges[3] = Edges[%d]\n", EndCv);
NewEdges[3] = Edges[EndCv];
*/

	for (i=0;i<4;i++) {
		NewEdges[i].mod_env = Edges[0].mod_env;
		stat = om$send ( msg     = message GRcurve.GRendpts ( 
					msg,
					&cst->env_info->md_env.matrix_type,
			       		cst->env_info->md_env.matrix,
					&ept[6*i],
					&ept[6*i+3] ),
			         senderid = NULL_OBJID,
		 	         targetid = NewEdges[i].obj_id.objid,
		 	         targetos = NewEdges[i].obj_id.osnum );
		if (!(stat&1&(*msg))) {
			EFmsgReport ( 0, stat, "GRcurve.GRendpts : sts");
			EFmsgReport ( 0, *msg, "GRcurve.GRendpts : msg");
			goto wrapup;
		}
	}

	/* Control points for Cross sections & Traces */
	dblcpy ( &CurveOrig[0], &ept[0],  3);
	dblcpy ( &CurveOrig[3], &ept[6], 3);
	dblcpy ( &CurveOrig[6], &ept[12], 3);
	dblcpy ( &CurveOrig[9], &ept[18], 3);

	*NewNumEdg = 4;
	*msg = OM_S_SUCCESS;
wrapup:

	if (SegPt) om$dealloc ( ptr = SegPt);
	if (CrnPt) om$dealloc ( ptr = CrnPt);
	if (ComPt) om$dealloc ( ptr = ComPt);
	if (DelCv) om$dealloc ( ptr = DelCv);
	if (PltCv) om$dealloc ( ptr = PltCv);
	if (FlgCv) om$dealloc ( ptr = FlgCv);

	return (stat);
}
/******************************************************************************/

/******************************************************************************/
/*									      */
/*	This function copy a surface and impose boundaries on it. If the      */
/*	surface is planar an encompassing plane is built.		      */
/*									      */
/******************************************************************************/
IGRlong BuildImpBndSrf ( support, result, Edges, NumEdg, RefDir,
			 inv, adj, clo, cst, curr_env, msg)

	struct		GRid		support; /* support surface	(I)   */
	struct		GRid		*result; /* built surface	(O)   */
	struct		GRobj_env	Edges[]; /* ordered boundaries	(I)   */
			IGRint		NumEdg;	 /* boundaries' number	(I)   */
	struct		IGRplane	RefDir;  /* reference plane	(I)   */
			IGRshort	*inv;	 /* inversion array	(I)   */
			IGRboolean	adj;	 /* adjustement flag	(I)   */
			IGRboolean	clo;	 /* closed flag		(I)   */
	struct		GRvg_construct	*cst;	 /* construction list	(I)   */
	struct		GRmd_env	curr_env;/* current environment	(I)   */
			IGRlong		*msg;	 /* return message	(O)   */

{

			IGRint		stat=MSSUCC;  /* return code	      */
	struct		GRlc_info	entries[4];   /* ordered boundaries   */
			IGRdouble	area_pts[2];  /* orientation point    */
			IGRboolean	orientation;  /* orientation flag     */
			IGRlong		npoints=0;    /* points' number       */
			IGRpoint	*points;      /* points array	      */
			IGRlong		nbadcrv;      /* bad curves' number   */
			IGRlong		badcrvidx[50];/* bad curves' indexes  */
			IGRushort	map_options;  /* mapping option	      */
			IGRushort	imp_options;  /* impose bound. option */
			IGRint		i;	      /* loop index	      */
			IGRdouble	water_mark;   /* mysterious value ... */
			GRobjid		return_id;    /* new objid	      */
			IGRboolean	Planar;	      /* planar bound. flag   */

	points = NULL;

	/* Try to build an encompassing plane */
	stat = BuildEmcPlane ( Edges, NumEdg, entries, cst, inv, adj, clo,
			       RefDir, &Planar, result, msg, TRUE);
        if (!(stat&1&(*msg))) {
                EFmsgReport(0,stat,"BuildEmcPlane() : sts");
                EFmsgReport(0,*msg,"BuildEmcPlane() : msg");
		goto wrapup;
        }

if (Planar == FALSE) {

	/* Copy support surface */
	stat = om$send ( msg      = message GRgraphics.GRcopy (
						msg,
						&curr_env,
						&curr_env,
						&(result->objid) ),
			 senderid = NULL_OBJID,
			 targetid = support.objid,
			 targetos = support.osnum );
	if (!(stat&1&(*msg))) {
		EFmsgReport( 0, stat, "GRgraphics.GRcopy : sts");
		EFmsgReport( 0, *msg, "GRgraphics.GRcopy : msg");
		goto wrapup;
	}
	result->osnum = curr_env.md_id.osnum;

	/* Fill the struct GRlc_info with edges */
        for (i=0;i<NumEdg;i++) {
                entries[i].located_obj = Edges[i].obj_id;
                entries[i].module_info = Edges[i].mod_env;
        }

	/* Initialization */
	area_pts[0] = 0.005;
	area_pts[1] = 0.005;
	orientation = FALSE;
	npoints     = 0;
	nbadcrv = 0;
	map_options = EMMapBnd_WantStatMsg
		    | EMMapBnd_WantBadCurves
		    | EMMapBnd_StrokeIfNeeded;
	imp_options = EMImpBnd_WantStatMsg | EMImpBnd_NoStateTree;

	/* Impose boundary on copied surface */
	stat = om$send ( msg      = message EMSsurface.EMimpose_boundaries (
						msg,
						(IGRlong) NumEdg,
						NULL,
						entries,
						area_pts,
						orientation,
						&curr_env,
						&npoints,
						&points,
						&nbadcrv,
						badcrvidx,
						NULL,
						NULL,
						NULL,
						NULL,
						map_options,
						imp_options,
						NULL),
			 senderid = NULL_OBJID,
			 targetid = result->objid,
			 targetos = result->osnum );
	if (!(stat&1&(*msg))) {
		EFmsgReport( 0, stat, "EMSsurface.EMimpose_boundaries : sts");
		EFmsgReport( 0, *msg, "EMSsurface.EMimpose_boundaries : msg");
		goto wrapup;
	}

	/* Reduce surface range */
	water_mark = 0.0;
	return_id  = NULL_OBJID;
	stat = om$send ( msg      = message EMSsubbs.EMreduce_range (
						msg,
						&curr_env,
						&return_id,
						water_mark ),
			 senderid = NULL_OBJID,
			 targetid = result->objid,
			 targetos = result->osnum );
	if (!(stat&1&(*msg))) {
		EFmsgReport( 0, stat, "EMSsubbs.EMreduce_range : sts");
		EFmsgReport( 0, *msg, "EMSsubbs.EMreduce_range : msg");
		goto wrapup;
	}
	result->objid = return_id;
}

wrapup:
	if ( (points != NULL) && (npoints != 0) ) {
		om$dealloc (ptr = points);
		points = NULL;
	}
	return (stat);
}	
/******************************************************************************/

/******************************************************************************/
/*									      */
/*	This function retrieves the surface, supporting the construction by : */
/*									      */
/*	     1)	[basis macro]     ---> [support macro]   as template	      */
/*	     2)	[support macro]   ---> [extension macro] as foot	      */
/*	     3)	[extension macro] ---> [support surface] as foot	      */
/*									      */
/*	The case of a basis macro that is already a composite one is treated, */
/*	but only for one level of nesting. The retrieval process is :	      */
/*									      */
/*	     1)	[composite macro] ---> [basis macro]     as template	      */
/*	     2)	[basis macro]     ---> [support macro]   as template	      */
/*	     3)	[support macro]   ---> [extension macro] as foot	      */
/*	     4)	[extension macro] ---> [support surface] as foot	      */
/*									      */
/******************************************************************************/
IGRlong RetrieveFlangeSupport ( basis, surface, key1, key2, key3, msg)

	struct		GRid		basis;	  /* basis macro	(I)   */
	struct		GRid		*surface; /* support surface	(O)   */
			IGRchar		key1[];	  /* support name	(I)   */
			IGRchar		key2[];	  /* extension name     (I)   */
			IGRchar		key3[];	  /* surface name	(I)   */
			IGRlong		*msg;	  /* return message	(O)   */

{

			IGRint		sts, stat=MSSUCC;  /* return code     */
	struct		GRid		support;  /* support macro	      */
	struct		GRid		extend;	  /* extension macro	      */

	/* Retrieve "support" template of basis macro occurence */
	stat = om$send ( msg	  = message ACcpx.ACfind_temp_obj (
						&sts, key1, &support ),
			 senderid = NULL_OBJID,
			 targetid = basis.objid,
			 targetos = basis.osnum );
	if (!(stat&1&(sts))) {
		*msg = sts;
		EFmsgReport( 0, stat, "ACcpx.ACfind_temp_obj : sts");
		EFmsgReport( 0, *msg, "ACcpx.ACfind_temp_obj : msg");
		return (stat);
	}

	/* Retrieve "extension" foot of support macro occurence */
	stat = om$send ( msg	  = message NDmacro.ACreturn_foot ( msg,
								    key2,
								    &extend,
								    NULL,
								    NULL ),
			 senderid = NULL_OBJID,
			 targetid = support.objid,
			 targetos = support.osnum );
	if (!(stat&1&(*msg))) {
		EFmsgReport( 0, stat, "NDmacro.ACreturn_foot : sts");
		EFmsgReport( 0, *msg, "NDmacro.ACreturn_foot : msg");
		return (stat);
	}

	/* Retrieve "surface" foot of extend macro occurence */
	stat = om$send ( msg	  = message NDmacro.ACreturn_foot ( msg,
								    key3,
								    surface,
								    NULL,
								    NULL ),
			 senderid = NULL_OBJID,
			 targetid = extend.objid,
			 targetos = extend.osnum );
	if (!(stat&1&(*msg))) {
		EFmsgReport( 0, stat, "NDmacro.ACreturn_foot : sts");
		EFmsgReport( 0, *msg, "NDmacro.ACreturn_foot : msg");
		return (stat);
	}

	return (stat);
}
/******************************************************************************/
IGRlong RetrieveWebSupport ( basis, surface, key1, key2, key3, key4, msg)

	struct		GRid		basis;	  /* basis macro	(I)   */
	struct		GRid		*surface; /* support surface	(O)   */
			IGRchar		key1[];	  /* support name	(I)   */
			IGRchar		key2[];	  /* support name	(I)   */
			IGRchar		key3[];	  /* extension name     (I)   */
			IGRchar		key4[];	  /* surface name	(I)   */
			IGRlong		*msg;	  /* return message	(O)   */

{

			IGRint		sts, stat=MSSUCC;  /* return code     */
	struct		GRid		support;  /* support macro	      */
	struct		GRid		extend;	  /* extension macro	      */

	/* Retrieve "support" template of basis macro occurence */
	stat = om$send ( msg	  = message ACcpx.ACfind_temp_obj (
						&sts, key1, &support ),
			 senderid = NULL_OBJID,
			 targetid = basis.objid,
			 targetos = basis.osnum );

	if (!(stat&1&sts)) {
		stat = om$send ( msg	  = message ACcpx.ACfind_temp_obj (
						&sts, key2, &support ),
			 	 senderid = NULL_OBJID,
			 	 targetid = basis.objid,
			 	 targetos = basis.osnum );
		if (!(stat&1&sts)) {
			*msg = sts;
			EFmsgReport( 0, stat, "ACcpx.ACfind_temp_obj : sts");
			EFmsgReport( 0, *msg, "ACcpx.ACfind_temp_obj : msg");
			return (stat);
		}
	}


	/* Retrieve "axis" template of support macro occurence */
	stat = om$send ( msg	  = message ACcpx.ACfind_temp_obj ( &sts,
								    key3,
								    &extend ),
			 senderid = NULL_OBJID,
			 targetid = support.objid,
			 targetos = support.osnum );
	if (!(stat&1&sts)) {
		*msg = sts;
		EFmsgReport( 0, stat, "ACcpx.ACfind_temp_obj : sts");
		EFmsgReport( 0, *msg, "ACcpx.ACfind_temp_obj : msg");
		return (stat);
	}

	/* Retrieve "surface" foot of extend macro occurence */
	stat = om$send ( msg	  = message NDmacro.ACreturn_foot ( msg,
								    key4,
								    surface,
								    NULL,
								    NULL ),
			 senderid = NULL_OBJID,
			 targetid = extend.objid,
			 targetos = extend.osnum );
	if (!(stat&1&(*msg))) {
		EFmsgReport( 0, stat, "NDmacro.ACreturn_foot : sts");
		EFmsgReport( 0, *msg, "NDmacro.ACreturn_foot : msg");
		return (stat);
	}

	return (stat);
}
/******************************************************************************/

end implementation Root;
