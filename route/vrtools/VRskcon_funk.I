/* $Id: VRskcon_funk.I,v 1.4 2002/04/10 20:44:57 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRskcon_funk.I
 *
 * Description:
 *	This function place a dangling at the end of seg_id. 
 *	This function is called in VRskcontodan.I and VRskdantodan.I files.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRskcon_funk.I,v $
 *	Revision 1.4  2002/04/10 20:44:57  louis
 *	TR5649-Standardize tolerance
 *	
 *	Revision 1.3  2001/02/20 01:18:18  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 20:09:35  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/24  01:33:10  pinnacle
# Created: route/vrtools/VRskcon_funk.I by lawaddel for Service Pack
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
# Revision 1.3  1996/01/18  23:07:24  pinnacle
# Replaced: vrtools/VRskcon_funk.I for:  by r240_int for route240
#
# Revision 1.2  1996/01/18  00:33:18  pinnacle
# Replaced: vrtools/VRskcon_funk.I for:  by r240_int for route240
#
 *
 * History:
 *	02/14/90   momo	   Design date
 *	01/17/96   tlb	   Add prototypes, 
 *	01/18/96   tlb	   Change to ANSII style:
 *				VRskget_all_sol, VRskget_way, 
 *				VRSkIsPipeConnectionValid, 
 *				VRSkIsDanglingConnectionValid
 *      04/08/02   law     TR5649-standardize tolerance with VRGetTol
 *************************************************************************/
class implementation Root;


#include <math.h>
#include "OMerrordef.h"
#include "msdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "csdef.h"
#include "VRdef.h"
#include "VRMath.h"
#include "gr.h"
#include "parametric.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "VRpriv_attr.h"
#include "grdpbmacros.h"
#include "csmacros.h"
#include "asmacros.h"
#include "VRmacros.h"
#include "VRprivmacros.h"
#include "AS_status.h"
#include "VRPid.h"
#include "vrtools_pto.h"
#include "vrinit_pto.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bsmkvec.h"
#include "bscrossp.h"
#include        "vrdbgmacros.h"

#define	AS_DEBUG 1

from	GRcoords	import	GRcvt_to_wld_coords;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			VRskget_all_sol function

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRskget_all_sol( IGRshort	dim,
		IGRshort	which_plane,
		IGRdouble 	*pts,
		IGRdouble 	*lcl_pt1,
		IGRdouble 	*pt2,
		IGRdouble 	*lcl_pt2)
/*.VRskget_all_sol */
{
  IGRchar	cstype[MAX_CS_TYPE];   /* type of active_cs             */
  IGRlong	status;                /* return code                   */
  IGRlong	msg;                   /* return code                   */
  IGRdouble 	tmp_pt[15];            /* used to calculate solution    */
  struct GRid	ref_id;                /* active ref. GRid              */

  SetProc( Func_VRskget_all_sol ); Begin
  if( dim == 1 )
  {
    pts[0]  = pt2[0];
    pts[1]  = pt2[1];
    pts[2]  = pt2[2];

    End
    return( OM_S_SUCCESS );
  }

  if( dim == 3 )
  {
    switch( which_plane )
    {
      case 1 : tmp_pt[0] = lcl_pt1[0];
               tmp_pt[1] = lcl_pt2[1];
               tmp_pt[2] = lcl_pt1[2];
               
               tmp_pt[3] = lcl_pt1[0];
   	       tmp_pt[4] = lcl_pt1[1];
	       tmp_pt[5] = lcl_pt2[2];

               tmp_pt[6] = lcl_pt1[0];
   	       tmp_pt[7] = lcl_pt2[1];
	       tmp_pt[8] = lcl_pt2[2];

               break;

       case 2: tmp_pt[0] = lcl_pt2[0];
               tmp_pt[1] = lcl_pt1[1];
               tmp_pt[2] = lcl_pt1[2];

               tmp_pt[3]  = lcl_pt1[0];
  	       tmp_pt[4]  = lcl_pt1[1];
	       tmp_pt[5]  = lcl_pt2[2];
              
               tmp_pt[6]  = lcl_pt2[0];
  	       tmp_pt[7]  = lcl_pt1[1];
	       tmp_pt[8]  = lcl_pt2[2];

               break;

       case 3: tmp_pt[0] = lcl_pt1[0];
               tmp_pt[1] = lcl_pt2[1];
               tmp_pt[2] = lcl_pt1[2];

               tmp_pt[3]  = lcl_pt2[0];
	       tmp_pt[4]  = lcl_pt1[1];
	       tmp_pt[5]  = lcl_pt1[2];

               tmp_pt[6]  = lcl_pt2[0];
  	       tmp_pt[7]  = lcl_pt2[1];
	       tmp_pt[8]  = lcl_pt1[2];

               break;
    }
  }
  else
  {
    /* dim == 5 */

    tmp_pt[0]  = lcl_pt1[0];
    tmp_pt[1]  = lcl_pt1[1];
    tmp_pt[2]  = lcl_pt2[2];

    tmp_pt[3]  = lcl_pt1[0];
    tmp_pt[4]  = lcl_pt2[1];
    tmp_pt[5]  = lcl_pt2[2];

    tmp_pt[6]  = lcl_pt1[0];
    tmp_pt[7]  = lcl_pt2[1];
    tmp_pt[8]  = lcl_pt1[2];

    tmp_pt[9]  = lcl_pt2[0];
    tmp_pt[10] = lcl_pt1[1];
    tmp_pt[11] = lcl_pt1[2];

    tmp_pt[12] = lcl_pt2[0];
    tmp_pt[13] = lcl_pt2[1];
    tmp_pt[14] = lcl_pt1[2];

  }

  status = VRskget_active_cs( 	(struct GRmd_env *)NULL,&ref_id,
				(IGRdouble *) NULL, cstype );
  as$status( action = RET_STATUS );

  /*| get solution in Word_CS */
  status = om$send( msg      = message GRcoords.GRcvt_to_wld_coords
                                                ( &msg,
                                                  cstype,
  		                                  dim,
                                                  tmp_pt,
                                                  pts ),
                    senderid = NULL_OBJID,
                    targetid = ref_id.objid,
                    targetos = ref_id.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = msg, action = RET_STATUS );
  
  End
  return(OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			VRskget_way function

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRskget_way( 	IGRshort	dim,
		IGRshort	which_plane,
		IGRdouble 	*pts,
		IGRdouble 	*pt1,
		IGRdouble 	*lcl_pt1,
		IGRdouble 	*pt2,
		IGRdouble 	*lcl_pt2)
/*.VRskget_way */
{
  IGRchar	cstype[MAX_CS_TYPE];   /* type of active_cs             */
  IGRlong	status;                /* return code                   */
  IGRlong	msg;                   /* return code                   */
  IGRdouble 	tmp_pt[3];             /* used to calculate solution    */
  struct GRid	ref_id;                /* active ref. GRid              */

  SetProc( Func_VRskget_way ); Begin
  pts[0] = pt1[0];
  pts[1] = pt1[1];
  pts[2] = pt1[2];

  if( dim == 1 )
  {
    pts[3]  = pt2[0];
    pts[4]  = pt2[1];
    pts[5]  = pt2[2];

    return( OM_S_SUCCESS );
  }

  switch( which_plane )
  {
    case 1 : tmp_pt[0] = lcl_pt1[0];
             tmp_pt[1] = lcl_pt2[1];
             tmp_pt[2] = lcl_pt1[2];
               
             break;

     case 2: tmp_pt[0] = lcl_pt2[0];
             tmp_pt[1] = lcl_pt1[1];
             tmp_pt[2] = lcl_pt1[2];

             break;

     case 3: tmp_pt[0] = lcl_pt1[0];
             tmp_pt[1] = lcl_pt2[1];
             tmp_pt[2] = lcl_pt1[2];

             break;
  }

  status = VRskget_active_cs( 	(struct GRmd_env *)NULL, &ref_id,
				(IGRdouble *) NULL, cstype );
  as$status( action = RET_STATUS );

  /*| get solution in Word_CS */
  status = om$send( msg      = message GRcoords.GRcvt_to_wld_coords
                                                ( &msg,
                                                  cstype,
  		                                  1,
                                                  tmp_pt,
                                                  &pts[3] ),
                    senderid = NULL_OBJID,
                    targetid = ref_id.objid,
                    targetos = ref_id.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = msg, action = RET_STATUS );

  pts[6] = pt2[0];
  pts[7] = pt2[1];
  pts[8] = pt2[2];
  
  End
  return(OM_S_SUCCESS);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  			   VRskprint_segments_lengh

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRskprint_segments_lengh( tab1, tab2, nb_case )

IGRdouble 	*tab1;
IGRdouble 	*tab2;
IGRint		nb_case;

/*.VRskprint_segments_lengh */
{
  IGRlong	rc;
  IGRchar	affich[80];
  IGRdouble	lengh[3];
  IGRdouble	my_vect[3];

  /*"nb_case = %d\n", nb_case */
	
  switch( nb_case )
  {
    case 3 : 

      /*"pt1 = %f %f %f\n", tab2[3], tab2[4], tab2[5] */
      /*"pt2 = %f %f %f\n", tab2[6], tab2[7], tab2[8] */

      BSmkvec( &rc, my_vect, &tab2[3], &tab2[6] );

      /*"vect = %f %f %f\n", my_vect[0], my_vect[1], my_vect[2] */

      lengh[2] = BSlenvec( &rc, my_vect );

      /*"lengh[2] = %f\n", lengh[2] */

      if( lengh[2] < VRGetTol(VR_LENGTH_TOL) ) nb_case--;

    case 2 : 

      /*"pt1 = %f %f %f\n", tab2[0], tab2[1], tab2[2] */
      /*"pt2 = %f %f %f\n", tab2[3], tab2[4], tab2[5] */

      BSmkvec( &rc, my_vect, tab2, &tab2[3] );

      /*"vect = %f %f %f\n", my_vect[0], my_vect[1], my_vect[2] */

      lengh[1] = BSlenvec( &rc, my_vect );

      /*"lengh[1] = %f\n", lengh[1] */

      if( lengh[1] < VRGetTol(VR_LENGTH_TOL) ) nb_case--;

    case 1 :  
     
      /*"pt1 = %f %f %f\n", tab1[0], tab1[1], tab1[2] */
      /*"pt2 = %f %f %f\n", tab1[3], tab1[4], tab1[5] */

      BSmkvec( &rc, my_vect, tab1, &tab1[3] );

      /*"vect = %f %f %f\n", my_vect[0], my_vect[1], my_vect[2] */

      lengh[0] = BSlenvec( &rc, my_vect );

      /*"lengh[0] = %f\n", lengh[0] */

      if( lengh[0] < VRGetTol(VR_LENGTH_TOL) ) nb_case--;

      break;
  }

  switch( nb_case )
  {
    case 1 :
     sprintf(affich,"1 segment : %.2lf long", lengh[0] );
     break;

    case 2 :
     sprintf(affich,"2 segments : %.2lf, %.2lf long",lengh[0],lengh[1]);
     break;

    case 3 :
     sprintf(affich,"3 segments : %.2lf, %.2lf, %.2lf long",lengh[0],lengh[1],lengh[2] );
     break;
  }

  /*"affich = %s\n", affich */

  if( ! nb_case ) strcpy( affich,"No segment" );

  UI_status( affich );

  return( OM_S_SUCCESS );

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 VRSkPipeConnectionValid fucntion
 
 CHANGE HISTORY:  momo 22-10-1990 : Design date


 DESCRIPTION  : 

/****************************************************************************/

IGRboolean 
VRSkIsPipeConnectionValid( IGRshort			Product,
			struct 		GRid 		*PipeId,
			IGRdouble			*FirstPt,
			IGRdouble			*NextPt,
			struct 		GRmd_env	*MdEnv)
/*.VRSkIsPipeConnectionValid */
{
  BSrc				bsretcode;
  IGRlong			msg, status;
  IGRdouble			dLength, dPipeRad, dCos;
  IGRdouble			seg_dir[3],pipe_dir[3];
  union		VRparam_attr	param;

  /*C Compute Segment's vector and length */

  BSmkvec( &bsretcode, seg_dir, FirstPt, NextPt );
  dLength = BSlenvec( &bsretcode, seg_dir );

  /*A Verify that Segment is not parallel to the pipe */
  BSnorvec( &bsretcode, seg_dir );
  status =
  VRSkGetPipeVirtualSupportInfo ( PipeId, NULL, MdEnv, NULL, pipe_dir, NULL );
  as$status( action = RET_STATUS );

  dCos = BSdotp( &bsretcode, pipe_dir, seg_dir );

  /*"dCos = %f\n", dCos */

  /*C Cannot connect two parallel segments */
  if( (1-fabs(dCos)) < VRGetTol(VR_DOTPROD_TOL) ) return FALSE;

  /*A In Schematics don't go further */
  if (bVR_IS_PID_ACTIVE) return TRUE;

  /*A Verify that segment is long enough to get out of the pipe */

  /*C get pipe dimension attributes */
  status =
  VR$GetDimensionAttributes(	p_retmsg	= &msg,
				Product		= Product,
		        	p_ComponentId	= PipeId,
				p_DimAttributes	= &param,
				p_MdEnv		= MdEnv );
  as$status();

  if( Product == VR_PIPING ) dPipeRad = param.piping_attr.G_diameter * 0.5;
  else                       dPipeRad = param.hvac_attr.G_width * 0.5;

  /*C Cannot connect a segment which does not get out ot the pipe */
  if ( dLength <= dPipeRad ) return FALSE;


  return TRUE;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  			   VRSkIsDanglingConnectionValid function

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

IGRboolean 
VRSkIsDanglingConnectionValid( 
			IGRshort	IndexOfDangling,
			IGRdouble	*pt1,
			IGRdouble	*pt2,
			IGRdouble	*pt3,
			IGRdouble	*pt4)
/*.VRSkIsDanglingConnectionValid */
{
  BSrc		bsretcode;     /* BS return code                        */
  IGRshort      extend;       
  IGRdouble	dot_p;
  IGRdouble 	v1[3];         /* normal direction between pt1 and pt2  */
  IGRdouble 	v2[3];         /* normal direction between pt3 and pt4  */
  IGRdouble	vcros[3];      /* cross product vector of v1 and v2     */


  extend = FALSE;

  /*"pt1 = %f %f %f\n", pt1[0], pt1[1], pt1[2] */
  /*"pt2 = %f %f %f\n", pt2[0], pt2[1], pt2[2] */
  /*"pt3 = %f %f %f\n", pt3[0], pt3[1], pt3[2] */
  /*"pt4 = %f %f %f\n", pt4[0], pt4[1], pt4[2] */

  BSmkvec( &bsretcode, v1, pt1, pt2 );
  BSmkvec( &bsretcode, v2, pt3, pt4 );
  BSnorvec ( &bsretcode, v1 );
  BSnorvec ( &bsretcode, v2 );

  /*"v1 = %f %f %f\n", v1[0], v1[1], v1[2] */
  /*"v2 = %f %f %f\n", v2[0], v2[1], v2[2] */

  BScrossp( &bsretcode, v1, v2, vcros );

  if( fabs(vcros[0]) < VRGetTol(VR_SQRLEN_TOL) &&
      fabs(vcros[1]) < VRGetTol(VR_SQRLEN_TOL) && 
      fabs(vcros[2]) < VRGetTol(VR_SQRLEN_TOL) ) extend = TRUE;

  /* calculate the dot product between next and previous directions */

  dot_p = BSdotp( &bsretcode, v1, v2 );

  /*"dot_p = %f\n", dot_p */

  if( extend && fabs( IndexOfDangling - dot_p ) < VRGetTol(VR_DOTPROD_TOL) )
     return FALSE;
  else
     return TRUE;

}


end implementation Root;


