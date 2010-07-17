/* $Id: VROrie.I,v 1.4 2002/04/10 20:44:49 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VROrie.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VROrie.I,v $
 *	Revision 1.4  2002/04/10 20:44:49  louis
 *	TR5649-Standardize tolerance
 *	
 *	Revision 1.3  2001/02/20 01:17:58  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 20:09:23  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  14:12:14  pinnacle
# Created: route/vrtools/VROrie.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/18  00:31:44  pinnacle
# Replaced: vrtools/VROrie.I for:  by r240_int for route240
#
 *
 * History:
 *	04/14/92   K Barbette	Creation: Route release 1.4.5.9
 *	14-APR-92		1.4.5.9 Create function VROrientComp.
 *	9-JUN-94	jim p.  Added capability to flip VR_INLINE_TOPO 
 *				components about the center connect point.
 *
 *	01/17/96   tlb		Add prototypes, 
 *				Change VRorient to ANSII style
 *      05/23/00   law          TR179901422-modified angle processing testing.
 *      04/08/02   law          TR5649-standardize tolerance with VRGetTol
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <math.h>

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "igewindow.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "VRdef.h"
#include "VRcompdef.h"
#include "VRmacros.h"
#include "VRMath.h"
#include "bsparameters.h"
#include "bstypes.h"

#include "AS_status.h"
#include "vrtools_pto.h"
#include "mainvmx.h"
#include "bslenvec.h"
#include "bscrossp.h"
#include "bsroto.h"
#include "maidmx.h"
#include "matypemx.h"
#include "vrdbgmacros.h"

#define AS_DEBUG

/*-------------------------------------------------------------------*/
/*	function VROrientComp
/*
/* 
/* Given the component's graphics, a coordinate system and the
/* justification, this function orientates the graphics.
/* 
/*
/* This function returns 	MSSUCC if specified connect point is free.
/* 				MSFAIL if not.
/*-------------------------------------------------------------------*/

from	ACncpx	import 	GRxform;

IGRint VROrientComp( msg, GraphicsId, Justification, Matrix, dAngle, md_env , ReverseFlag )
			       
IGRlong 		*msg ;         /* O : Return code, MSSUCC or MSFAIL.   */
struct GRid		*GraphicsId ;  /* I : Component's graphic symbol.            */
IGRint			Justification; /* I : Component's connection point number */
IGRdouble		*Matrix;      /* I : Default Orientation and position matrix. */
IGRdouble		dAngle;	       /* I : Rotation angle around the X axis */
struct GRmd_env 	*md_env;
IGRboolean		ReverseFlag;

/*.VROrientComp */
{
	IGRint		status,i;
	IGRshort		Quatre = 4;
	IGRlong		retmsg;
	BSrc		rc;
	IGRshort	nGrType,nTranType;
	IGRmatrix	dMatrix,dGrMatrix,dTmpMatrix,dTranMatrix;
	IGRdouble	vectorX[3], vectorY[3], vectorZ[3];

        SetProc( Func_VROrientComp ); Begin
	/*"angle = %f\n", dAngle */
	/*"md_env = %d %d\n", md_env->md_id.objid, md_env->md_id.osnum */

  *msg = MSSUCC;
  __DBGpr_obj("GraphicsId",*GraphicsId);
  __DBGpr_mat("input comp matrix",Matrix);
  for( i=0; i<16; i++)	dMatrix[i] = Matrix[i];

  MAidmx ( &retmsg, dGrMatrix );
  MAtypemx( &retmsg, dGrMatrix,&nGrType);

  /* -- Get Gr matrix from graphics -- */
  status =
  VR$GetMatrix (p_msg 		= &retmsg,
		p_ComponentId 	= GraphicsId,
		CompCpt 	= Justification,
		p_Matrix 	= dGrMatrix,
		p_MdEnv 	= md_env);
  if (! (status&1&retmsg) ) goto wrapup;

	/*"Dest X = %f, %f, %f\n",dMatrix[0],dMatrix[4],dMatrix[8] */
	/*"Dest Y = %f, %f, %f\n",dMatrix[1],dMatrix[5],dMatrix[9] */
	/*"Dest Z = %f, %f, %f\n",dMatrix[2],dMatrix[6],dMatrix[10]*/

	/*"From X = %f, %f, %f\n",dGrMatrix[0],dGrMatrix[4],dGrMatrix[8] */
	/*"From Y = %f, %f, %f\n",dGrMatrix[1],dGrMatrix[5],dGrMatrix[9] */
	/*"From Z = %f, %f, %f\n",dGrMatrix[2],dGrMatrix[6],dGrMatrix[10] */

        __DBGpr_mat("dGrMatrix",dGrMatrix);

  /* -- Rotate direction -- */
  if ( fabs(dAngle) > VRGetTol(VR_ANGULAR_TOL) ) /* TR179901422-replace improper test*/
  {
	IGRboolean	bBooleanVar;
	IGRdouble 	dOrig[3];

	dOrig[0]=dOrig[1]=dOrig[2]=0.0;
	vectorX[0] = dMatrix[0];
        vectorX[1] = dMatrix[4];
	vectorX[2] = dMatrix[8];

	vectorY[0] = dMatrix[1];
	vectorY[1] = dMatrix[5];
	vectorY[2] = dMatrix[9];
        __DBGpr_vec("vector X",vectorX);
	bBooleanVar = TRUE;
	BSroto( &rc, dOrig, vectorX, &bBooleanVar, &dAngle, vectorY, vectorY );
        __DBGpr_vec("Rotated vector Y",vectorY);
	BScrossp ( &rc, vectorX, vectorY, vectorZ);
        __DBGpr_vec("Computed rotate vector Z",vectorZ);

	dMatrix[0] = vectorX[0];
	dMatrix[4] = vectorX[1];
	dMatrix[8] = vectorX[2];  

	dMatrix[1] = vectorY[0];
	dMatrix[5] = vectorY[1];
	dMatrix[9] = vectorY[2];

	dMatrix[2]  = vectorZ[0];
	dMatrix[6]  = vectorZ[1];
	dMatrix[10] = vectorZ[2];
  /*"Dest X rotate = %f, %f, %f\n",dMatrix[0],dMatrix[4],dMatrix[8]*/
  /*"Dest Y rotate = %f, %f, %f\n",dMatrix[1],dMatrix[5],dMatrix[9]*/
  /*"Dest Z rotate = %f, %f, %f\n",dMatrix[2],dMatrix[6],dMatrix[10]*/ 
 }

  /* -- Invert Graphics' matrix -- */
  MAinvmx (&retmsg,&Quatre,dGrMatrix,dGrMatrix);

  /* -- Reverse destination matrix if justification is specified */
  /*    ( connection points should point towards the defined X axis) */

  for (i=0; i<16; i++)
	dTmpMatrix[i] = dMatrix[i];

  __DBGpr_int("Justification",Justification);
  __DBGpr_int("ReverseFlag",(int) ReverseFlag);

if (( Justification != VR_CENTER_JUST ) || ReverseFlag )
  {
	/* Reverse X axis */
        __DBGpr_com("REVERSING X AXIS HERE ----------");
	dTmpMatrix[0] *= -1.0;
	dTmpMatrix[4] *= -1.0;
	dTmpMatrix[8] *= -1.0;
        __DBGpr_com("REVERSING Z AXIS HERE ----------");
	/* Reverse Z axis */
	dTmpMatrix[2]  *= -1.0;
	dTmpMatrix[6]  *= -1.0;
	dTmpMatrix[10] *= -1.0;

        __DBGpr_mat("dMatrix",dTmpMatrix);
  }/* end reverse X and Z axes */
  /* -- Compute transformation matrix -- */
  BSmult_mats( 4, 4, dTmpMatrix, FALSE, 4, 4, dGrMatrix, FALSE, dTranMatrix, &rc);

  MAtypemx( &retmsg, dTranMatrix,&nTranType);

  /* -- Apply transformation matrix to graphics -- */
  status =
  om$send ( msg      = message ACncpx.GRxform ( &retmsg, 
					        md_env,
					        &nTranType,
					        dTranMatrix,
					        &GraphicsId->objid),
		     senderid = NULL_OBJID,
		     targetid =  GraphicsId->objid,
		     targetos =  GraphicsId->osnum);

wrapup :

  End
  return status;
}/* end VROrientComp */

/* ------------------------------------------------------------------------ */

static struct VRorient_params 
{
  struct DPele_header   header[2];
  IGRshort		product;
  IGRdouble		*point1;
  IGRdouble		*point2;
  IGRdouble		*normal;
  struct GRmd_env	module_info;
};

static
IGRint VRoridyn( VRinfo,point,matrix,objects,num_objects,buffers,num_buffers,
                    dummy_in1,dummy_in2,dummy_in3,dummy_out1,dummy_out2,
                    dummy_out3 )

struct 		VRorient_params	*VRinfo;
struct 		EX_button      	*point;
IGRdouble                   	*matrix;
struct 		GRid           	**objects;
IGRint                     	*num_objects;
struct 		DPele_header  	**buffers;
IGRint                       	*num_buffers;
IGRchar                      	*dummy_in1;
IGRchar                      	*dummy_in2;
IGRchar                      	*dummy_in3;
IGRchar                      	**dummy_out1;
IGRchar                      	**dummy_out2;
IGRchar                      	**dummy_out3;
/*.VRoridyn */
{
  IGRint 			PointViewDependant ();
  IGRlong			status;
  IGRdouble			Zvector[3];
  IGRint			i;
  BSrc				rc;
  struct	GRmd_env	HeadMdEnv;
  IGRdouble			view_scale, vect_size;
  IGRlong 			which_error, bytes_returned, retcode;
  struct 	win_var_list	var_list[2]; 	

  status  = OM_S_SUCCESS;

  HeadMdEnv = VRinfo->module_info;
  HeadMdEnv.md_id.objid = NULL_OBJID;

  if( VRinfo->product == VR_PIPING )
  {
        /*| Compute Y axis*/
	PointViewDependant ( &point->x, matrix, VRinfo->normal, VRinfo->point1);
  	status = VRget_axis( &point->x, VRinfo->point1, VRinfo->normal, VRinfo->point2 );

	if ( BSlenvec( &rc, VRinfo->point2) < VRGetTol(VR_LENGTH_TOL) ) return(TRUE);
  }

  BScrossp ( &rc, VRinfo->normal, VRinfo->point2, Zvector);

  /* -- Get view_scale to have always the same orientation Tee -- */
  var_list[0].var            = VVOL_VIEWPORT_SCALE;
  var_list[0].var_ptr        = ( char *) &view_scale;  
  var_list[0].num_bytes      = sizeof( IGRdouble );
  var_list[0].bytes_returned = &bytes_returned;
  var_list[1].var = END_PARAM;

  status = dp$inq_set_gragad( msg          = &retcode,
			      osnum        = point->osnum,
			      gragad_objid = point->objid,
			      which_error  = &which_error,
			      var_list     = var_list );
  as$status( action = RET_STATUS );

  vect_size = 40 / view_scale;


  /* -- Initialise Tee display -- */
  for ( i=0; i<3; i++)
  {
	VRinfo->header[0].geometry.polyline->points[i] = VRinfo->point1[i];
	VRinfo->header[1].geometry.polyline->points[i] = VRinfo->point1[i];

	VRinfo->header[0].geometry.polyline->points[i+3] = VRinfo->point1[i] 
						+ vect_size*VRinfo->point2[i];
	VRinfo->header[1].geometry.polyline->points[i+3] = VRinfo->point1[i] 
						+ vect_size*VRinfo->normal[i];
  }

  *buffers = VRinfo->header;
  *num_buffers = 2;

  return(TRUE);

} /* end function VRoridyn */

/* ------------------------------------------------------------------------ */
IGRlong VRorient( 
		IGRshort		product,
		IGRdouble		*dOrigin,
		IGRdouble		*dXaxis,
		IGRdouble		*dYaxis,
		struct 	IGRdisplay      *display,
		struct	GRmd_env	*md_env
		)

/*.VRorient */
{
  struct	VRorient_params		VRinfo;
  IGRdouble                  		pt_buffer[12]; /* polyline end points        */
  struct       	IGRpolyline     	polyline[2];  /* polyline to display        */
  struct 	IGRdisplay      	Display;      /* Active symbologies         */
  IGRint				i;

  VRinfo.product	   = product;
  VRinfo.module_info       = *md_env;
  VRinfo.point1 	   = dOrigin;
  VRinfo.point2            = dYaxis;
  VRinfo.normal            = dXaxis;

  /*"product = %d \n",product*/

   Display                 = *display;
   Display.weight          = 2;
   polyline [0].num_points = 2;
   polyline [0].points     = pt_buffer;
   polyline [1].num_points = 2;
   polyline [1].points     = &pt_buffer[6];

   for( i=0; i<3; i++ )
   {
    	pt_buffer [i]   = dOrigin[i];
    	pt_buffer [i+3] = dXaxis [i];
    	pt_buffer [i+6] = dOrigin[i];
    	pt_buffer [i+9] = dYaxis [i];
   }

   dp$build_dis_buffer(	buffer      = &VRinfo.header[0],
		  	type        = IGRPY,
		  	display_att = &Display,
		  	geometry    = ( struct IGRpolyline *) &polyline[0] );

   dp$build_dis_buffer(	buffer      = &VRinfo.header[1],
		  	type        = IGRPY,
		  	display_att = &Display,
		  	geometry    = ( struct IGRpolyline *) &polyline[1] );

   dp$dynamics( dyn_fun     = VRoridyn,
	       	information = &VRinfo );

  return OM_S_SUCCESS;

} /* end function VRorient */

/* ------------------------------------------------------------------------- */

static struct VRParams 
{
  struct GRid		Component;
  struct GRmd_env	md_env;
};

static
IGRint VRfollowdyn( VRinfo,point,matrix,objects,num_objects,buffers,num_buffers,
                    dummy_in1,dummy_in2,dummy_in3,dummy_out1,dummy_out2,
                    dummy_out3 )

struct 		VRParams	*VRinfo;
struct 		EX_button      	*point;
IGRdouble                   	*matrix;
struct 		GRid           	**objects;
IGRint                     	*num_objects;
struct 		DPele_header  	**buffers;
IGRint                       	*num_buffers;
IGRchar                      	*dummy_in1;
IGRchar                      	*dummy_in2;
IGRchar                      	*dummy_in3;
IGRchar                      	**dummy_out1;
IGRchar                      	**dummy_out2;
IGRchar                      	**dummy_out3;
/*.VRfollowdyn */
{
  IGRlong	status, retcode;
  IGRdouble	Matrix[16];

  status  = OM_S_SUCCESS;

  status = VR$GetMatrix( p_msg	        = &retcode,
			 p_ComponentId 	= &VRinfo->Component,
			 p_Matrix      	= Matrix,
			 p_MdEnv	= &VRinfo->md_env);

  Matrix[3]  = point->x;
  Matrix[7]  = point->y; 
  Matrix[11] = point->z;

  status = VR$OrientComp( p_retmsg = &retcode,
		       	  p_CmpId  = &VRinfo->Component,
		       	  Matrix   = Matrix,
		       	  p_MdEnv  = &VRinfo->md_env
	              	);

  *objects = &VRinfo->Component;
  *num_objects = 1;

  return(TRUE);

} /* end function VRfollowdyn */

/* ----------------------------------------------------------------------------------- */
IGRlong VRFollowCursor( CmpId, display, md_env )

struct	GRid		*CmpId;
struct 	IGRdisplay      *display;
struct	GRmd_env	*md_env;

/*.VRFollowCursor*/
{
  struct	VRParams		VRinfo;

  VRinfo.md_env		= *md_env;
  VRinfo.Component	= *CmpId;



   dp$dynamics( dyn_fun     = VRfollowdyn,
	       	information = &VRinfo );

  return OM_S_SUCCESS;

} /* end function  VRFollowCursor*/

end implementation Root;
