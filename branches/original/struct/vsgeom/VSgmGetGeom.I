/* $Id: VSgmGetGeom.I,v 1.1 2001/01/16 23:43:49 ramarao Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:        vsgeom/VSgmGetGeom.I
 *
 * Description: Contains a function to retrieve the geometry
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSgmGetGeom.I,v $
 *      Revision 1.1  2001/01/16 23:43:49  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/12/01  21:37:56  pinnacle
# Created: struct/vsgeom/VSgmGetGeom.I by impd252 for Service Pack
#
 *
 * History:
 *      MM/DD/YY   AUTHOR                       DESCRIPTION
 *	12/01/00   adz				Copied from LOFT.
 *
 *************************************************************************/

class implementation VDSroot ;

#include	<stdio.h>
#include	"OMerrordef.h"
#include	"AS_status.h"
#include	"vsmiscmacros.h"

#include	"mamulmx.h"
#include	"matypemx.h"

from	ACheader	import	ACfind_model;
from	EMSsubbs	import	EMget_boundaries;
from	VDlink		import	ACget_model_list;

extern	GRclassid	OPP_VDrelat_hdr_class_id;

/*	#define	TRACE	*/

/* -------------------------------------------------------------------------- */
VSgeom_same_point (pt1, pt2, tol)
IGRdouble *pt1,*pt2, tol; /* I : two points */
{
  if (
      ((pt1[0] - pt2[0] <= tol) && (pt1[0] - pt2[0] >= -tol)) &&
      ((pt1[1] - pt2[1] <= tol) && (pt1[1] - pt2[1] >= -tol)) &&
      ((pt1[2] - pt2[2] <= tol) && (pt1[2] - pt2[2] >= -tol))
     ) {
      return 1;
    }
  else return 0;
}

/* --------------------- copy from LOFT ------------------------------- */

IGRint	VSgm_getGeometry (	struct	GRobj_env	*Object,
				IGRboolean	EdgeFlag,
				OM_S_OBJID	MyStupidId,
				IGRchar		**Geometry,
				IGRlong		*msg	)
/*
	23-Oct-92	Created by Jean Luc Loschutz (COC shipbuilding)
	20-Oct-94	Updated by Ludovic Lecorvec (COC shipbuilding)
			Kludge for relative headers.
*/
{
		IGRint		sts, cnt;
	struct	GRobj_env	Graphic;
		BSrc		rc;
		IGRshort	four=4, typ;
		IGRmatrix	mat;
		IGRlong		siz=0;
		IGRchar		*geometry;
	struct	IGRbsp_surface	*surface;
	struct	GRobj_env	model;
#ifdef TRACE
		IGRint		i;
#endif

	/* Initialize */
	geometry  = NULL;
	*Geometry = NULL;

	/* Kludge for relative headers */
	if (vs$is_ancestry_valid ( object  = &Object->obj_id,
				   classid = OPP_VDrelat_hdr_class_id ) ) {
#ifdef TRACE
printf( "\tACheader.ACfind_model on Object (%d|%d)\n",
	Object->obj_id.osnum, Object->obj_id.objid );
for (i=0;i<4;i++)
printf( "\t\t[%g\t%g\t%g\t%g]\n",
	Object->mod_env.md_env.matrix[4*i+0],
	Object->mod_env.md_env.matrix[4*i+1],
	Object->mod_env.md_env.matrix[4*i+2],
	Object->mod_env.md_env.matrix[4*i+3] );
#endif
		/* Get model */
		sts = om$send ( msg = message ACheader.ACfind_model
						( msg, &model.obj_id),
				senderid = MyStupidId,
				targetid = Object->obj_id.objid,
				targetos = Object->obj_id.osnum );
		as$status ( sts    = sts,
			    msg    = "ACheader.ACfind_model",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Get matrix */
		sts = om$send ( msg = message GRowner.GRget_matrix (
					msg,
					&Object->mod_env.md_env.matrix_type,
					Object->mod_env.md_env.matrix,
					&model.mod_env.md_env.matrix_type,
					model.mod_env.md_env.matrix ),
				senderid = MyStupidId,
				targetid = Object->obj_id.objid,
				targetos = Object->obj_id.osnum );
		as$status ( sts    = sts,
			    msg    = "GRowner.GRget_matrix",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
#ifdef TRACE
printf( "\tVDlink.ACget_model_list on model 1 (%d|%d)\n",
	model.obj_id.osnum, model.obj_id.objid );
for (i=0;i<4;i++)
printf( "\t\t[%g\t%g\t%g\t%g]\n",
	model.mod_env.md_env.matrix[4*i+0],
	model.mod_env.md_env.matrix[4*i+1],
	model.mod_env.md_env.matrix[4*i+2],
	model.mod_env.md_env.matrix[4*i+3] );
#endif
		/* Get model */
		sts = om$send ( msg = message VDlink.ACget_model_list
					( msg, 1, &model.obj_id, &cnt),
				senderid = MyStupidId,
				targetid = model.obj_id.objid,
				targetos = model.obj_id.osnum );
		as$status ( sts    = sts,
			    msg    = "VDlink.ACget_model_list",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	
		/* Get geometry */
#ifdef TRACE
printf( "\tVSgm_getGeometry() on model 2 (%d|%d)\n",
	model.obj_id.osnum, model.obj_id.objid );
for (i=0;i<4;i++)
printf( "\t\t[%g\t%g\t%g\t%g]\n",
	model.mod_env.md_env.matrix[4*i+0],
	model.mod_env.md_env.matrix[4*i+1],
	model.mod_env.md_env.matrix[4*i+2],
	model.mod_env.md_env.matrix[4*i+3] );
#endif
		sts = VSgm_getGeometry ( &model, EdgeFlag, MyStupidId,
				      Geometry, msg);
		as$status ( sts    = sts,
			    msg    = "VLnewGetGeometry()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
		goto wrapup;
	}

	/* Get the (first ..) graphic object */
	sts = om$send ( msg = message NDnode.ASreturn_go
					( &Graphic.obj_id, &typ, mat ),
			senderid = MyStupidId,
			targetid = Object->obj_id.objid,
			targetos = Object->obj_id.osnum );
	Graphic.mod_env.md_id.objid = Object->mod_env.md_id.objid;
	Graphic.mod_env.md_id.osnum = Graphic.obj_id.osnum;
	if (sts == OM_W_UNKNOWN_MSG) {
		Graphic = *Object;
		sts = OM_S_SUCCESS;
	}
	else {	/* Apply transformation matrix */
		MAmulmx  ( &rc, &four, &four, &four,
			   Object->mod_env.md_env.matrix,
		   	   mat,
			   Graphic.mod_env.md_env.matrix );
		MAtypemx ( &rc, Graphic.mod_env.md_env.matrix,
		   	   &Graphic.mod_env.md_env.matrix_type );
	}
	as$status ( sts    = sts,
		    msg    = "NDnode.ASreturn_go",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Get the size of the geometry */
	sts = om$send ( msg = message GRvg.GRgetsize (
					msg,
					&Graphic.mod_env.md_env.matrix_type,
					Graphic.mod_env.md_env.matrix,
					&siz ),
			senderid = MyStupidId,
			targetid = Graphic.obj_id.objid,
			targetos = Graphic.obj_id.osnum );
	as$status ( sts    = sts,
		    msg    = "GRvg.GRgetsize",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Allocate memory for geometry */
	geometry = om$calloc (size = siz);
	if (!geometry)	{	*msg = MSFAIL;	goto wrapup;	}

	/* Get the geometry */
#ifdef TRACE
printf( "\tGRvg.GRgetgeom (%d|%d)\n",
	Graphic.obj_id.osnum, Graphic.obj_id.objid );
for (i=0;i<4;i++)
printf( "\t\t[%g\t%g\t%g\t%g]\n",
	Graphic.mod_env.md_env.matrix[4*i+0],
	Graphic.mod_env.md_env.matrix[4*i+1],
	Graphic.mod_env.md_env.matrix[4*i+2],
	Graphic.mod_env.md_env.matrix[4*i+3] );
#endif
	sts = om$send ( msg = message GRvg.GRgetgeom (
					msg,
					&Graphic.mod_env.md_env.matrix_type,
					Graphic.mod_env.md_env.matrix,
					geometry ),
			senderid = MyStupidId,
			targetid = Graphic.obj_id.objid,
			targetos = Graphic.obj_id.osnum );
	as$status ( sts    = sts,
		    msg    = "GRvg.GRgetgeom",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Get edges (if needed) */
	if (EdgeFlag) {
		surface = (struct IGRbsp_surface *) geometry;

		sts = om$send ( msg = message EMSsubbs.EMget_boundaries (
					msg,
					&Graphic.mod_env.md_env.matrix_type,
					Graphic.mod_env.md_env.matrix,
					&surface->on_off,
					&surface->num_boundaries,
					&surface->bdrys ),
				senderid = MyStupidId,
				targetid = Graphic.obj_id.objid,
				targetos = Graphic.obj_id.osnum );
		as$status ( sts    = sts,
			    msg    = "EMSsubbs.EMget_boundaries",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

	}

wrapup:
	if (geometry)	*Geometry = geometry;
	surface  = NULL;
	geometry = NULL;
	return (sts);
}

/* **************************************************************************
  Given a curve, this function retrieve the bsgeometry of  
  the corresponding extended curve 
 * **************************************************************************/
IGRlong VSgm_getExGeometry (	struct	GRobj_env	*GraObj,
					OM_S_OBJID	MyStupidId,
					IGRchar		**ReturnedGeometry,
					IGRlong		*msg )
{
	IGRint	       	ii, k, kP3;
 	IGRchar        	*GenericPointer;
 	IGRlong        	NumBytes, sts;
 struct	IGRbsp_curve   	*cv;
 struct GRprops		ObjProps;
	IGRdouble	a;
 struct GRmd_env       EnvGObj;
 struct GRid	       GObj;
        BSrc	        rc;
        IGRshort	four = 4;

  /*c Initialize */

  GenericPointer = NULL;
  *ReturnedGeometry = NULL;

  /*c retrieve the graphic object */

   GObj.objid = NULL_OBJID;

   sts = om$send( msg      = message NDnode.ASreturn_go( 
					&GObj, 
					&EnvGObj.md_env.matrix_type,
    					EnvGObj.md_env.matrix ),
   		senderid = MyStupidId, 
   		targetid = GraObj->obj_id.objid, 
   		targetos = GraObj->obj_id.osnum );
 
  if (sts == OM_W_UNKNOWN_MSG) {
    GObj = GraObj->obj_id;
    EnvGObj = GraObj->mod_env;
    sts = OM_S_SUCCESS;
  }
  else {  /* Apply transformation matrix */
    if (!(sts&1)) goto wrapup;
    MAmulmx  ( &rc, &four, &four, &four,
               GraObj->mod_env.md_env.matrix,
               EnvGObj.md_env.matrix,
               EnvGObj.md_env.matrix );
    MAtypemx ( &rc, EnvGObj.md_env.matrix,
               &EnvGObj.md_env.matrix_type );
  }

  /*c Compute the number of bytes required */

  sts = om$send	( msg = message GRvg.GRgeomprops( 
					msg,
					&EnvGObj.md_env.matrix_type,
    					EnvGObj.md_env.matrix,
			                &ObjProps ),
   		senderid = MyStupidId, 
   		targetid = GObj.objid, 
   		targetos = GObj.osnum );
	      
  GRabsg_del_by_objid(&GObj.objid,&GObj.osnum); 

  sts = om$send( msg      = message GRvg.GRgetexsize( 
					msg, 
					&EnvGObj.md_env.matrix_type,
    					EnvGObj.md_env.matrix,
					&NumBytes ), 
   		senderid = MyStupidId, 
   		targetid = GObj.objid, 
   		targetos = GObj.osnum );
 
  if( !(1 & sts & *msg) ) goto wrapup;

  /*c malloc the surface */

  GenericPointer = (IGRchar *) om$malloc( size = NumBytes );
  if( !GenericPointer ){
    	*msg = MANOMEMORY; 
    	goto wrapup;
  }

  /*c Get the geometry */

  sts = om$send( msg = message GRvg.GRgetexgeom(
    					msg, 
					&EnvGObj.md_env.matrix_type,
    					EnvGObj.md_env.matrix,
					GenericPointer ),
   		  senderid = MyStupidId, 
   		  targetid = GObj.objid, 
   		  targetos = GObj.osnum );

  if ( !(1 & sts & *msg) ) goto wrapup;


  if( ObjProps.type != 1 ){

  	cv = ( struct IGRbsp_curve * ) GenericPointer;

	if (  (cv->order == 2) && (!cv->phy_closed) ){


	      if( cv->num_poles > 2 ){

	      	   ii = 3 * ( cv->num_poles - 2 );

	    	   for ( k=0; k<3; k++) {
			kP3 = k + 3;
		      	cv->poles[k]      = 501 * cv->poles[k] - 
					    500 * cv->poles[kP3];

		      	cv->poles[kP3+ii] = 501 * cv->poles[kP3+ii] -
					    500 * cv->poles[ii+k];
	           }
	      }
	      else{
	    	   for ( k=0; k<3; k++) {

			kP3 = k + 3;
			a = cv->poles[k];
		      	cv->poles[k]      = 501 * a -  500 * cv->poles[kP3];

		      	cv->poles[kP3] = 501 * cv->poles[kP3] - 500 * a;
	           }
	      }
	}

	cv = NULL;
  }


  *ReturnedGeometry = GenericPointer;
  GenericPointer = NULL;
  *msg = MSSUCC;
  return(MSSUCC);  


wrapup:
 	if (GenericPointer) om$dealloc (ptr = GenericPointer);
  	*ReturnedGeometry = NULL;
  	GenericPointer = NULL;
 	return (MSFAIL);

}

end implementation VDSroot;
