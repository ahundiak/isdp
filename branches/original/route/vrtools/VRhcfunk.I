/* $Id: VRhcfunk.I,v 1.2 2002/04/10 20:44:54 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRhcfunk.I
 *
 * Description:
 *	Utility function used to generate HVAC sketch.
 *
 *    Functions : All these functions are used in HVAC and CABLING. 
         - VRModifyHvacSection  : HVAC section manipulation
         - VRSkGetHvacCmpParams : needed to get component connect points
                                  attributes.
         - VRSkUpdateParams     : needed to create an ACrg_collect for 
                                  reducer and transiton in the sketch.
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRhcfunk.I,v $
 *	Revision 1.2  2002/04/10 20:44:54  louis
 *	TR5649-Standardize tolerance
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/05/04  13:49:08  pinnacle
# Replaced: vrtools/VRhcfunk.I for:  by sbilla for route
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
# Revision 1.4  1996/05/15  21:33:54  pinnacle
# Replaced: vrtools/VRhcfunk.I for:  by ashankar for route240
#
# Revision 1.3  1996/01/18  23:07:42  pinnacle
# Replaced: vrtools/VRhcfunk.I for:  by r240_int for route240
#
# Revision 1.2  1996/01/18  00:33:00  pinnacle
# Replaced: vrtools/VRhcfunk.I for:  by r240_int for route240
#
 *
 * History:
 *	06/12/89   momo		Design Date
 *	01/17/96   tlb		Add prototypes, 
 *	01/18/96   tlb		Change VRSkUpdateParams to ANSII style
 *      05/04/99    Reddy       Double value comparision corrected
 *      04/08/02    law         TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/
class implementation Root;

#include <math.h>

#include "msdef.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "grdpbdef.h"
#include "VRcordef.h"
#include "VRparamdef.h"
#include "dppriv.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsvalues.h"
#include "bsparameters.h"
#include "VRdef.h"
#include "VRcompdef.h"
#include "VRMath.h"
#include "VRdimdef.h"
#include "VRstructs.h"
#include "VRpriv_attr.h"
#include "grdpbmacros.h"
#include "VRmacros.h"
#include "AS_status.h"
#include "vrtools_pto.h"
#include "bsmkvec.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsdotp.h"

#define AS_DEBUG

from   	VRCnrlSeg	import	VRGetTopo, VRget_terminators;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			VRModifyHvacSection

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

IGRlong VRModifyHvacSection
	( p_retmsg, Operation, p_InPutSection, p_StartPt, p_EndPt, p_CmpId, CmpCptNum, 
	  p_OutPutSection, p_MdEnv
    	)

IGRlong				*p_retmsg;
IGRint				Operation;
IGRdouble			*p_InPutSection;
IGRdouble			*p_StartPt;
IGRdouble			*p_EndPt;
struct		GRid		*p_CmpId;
IGRint				CmpCptNum;
IGRdouble			*p_OutPutSection;
struct		GRmd_env	*p_MdEnv;

/*.VRModifyHvacSection */
{
  IGRlong  		status=OM_S_SUCCESS , retcode=MSSUCC; 
  IGRmatrix 		tmp_matrix;

  *p_retmsg = MSSUCC;

  switch( Operation )
  {
	case VR_INIT_SECTION:
		{
			struct GRid 	ref_id;                /* active ref. GRid          */
  			IGRchar		cstype[MAX_CS_TYPE];   /* type of active_cs         */

  			/*| get active CS */ 
  			status = VRskget_active_cs( p_MdEnv, &ref_id, tmp_matrix, cstype );
  			as$status( action = RET_STATUS );

  			p_OutPutSection[0] = tmp_matrix[0];
  			p_OutPutSection[1] = tmp_matrix[4];
  			p_OutPutSection[2] = tmp_matrix[8];
  			p_OutPutSection[3] = tmp_matrix[1];
  			p_OutPutSection[4] = tmp_matrix[5];
  			p_OutPutSection[5] = tmp_matrix[9];
  			p_OutPutSection[6] = tmp_matrix[2];
  			p_OutPutSection[7] = tmp_matrix[6];
  			p_OutPutSection[8] = tmp_matrix[10];
    		
    			break;
		}

	case VR_UPDATE_SECTION:
		
		if( p_InPutSection && p_EndPt && p_StartPt )
		{
  			IGRint		i;
  			IGRdouble	vx0[3], vy[3], vz[3];

 			for( i=0; i<3; i++ ) vx0[i] = p_EndPt[i] - p_StartPt[i];

			/*BILLA  Double value comparison problem */
			if( (fabs(vx0[0]) < VRGetTol(VR_DIST_TOL)) &&
                            (fabs(vx0[1]) < VRGetTol(VR_DIST_TOL)) && 
			    (fabs(vx0[2]) < VRGetTol(VR_DIST_TOL)) )
			{
  				status = make_ref( &retcode, p_InPutSection, 
					&p_InPutSection[3], &p_InPutSection[6],
					 vy, vz );
			}
			else
			{
  				status = make_ref( &retcode, vx0, 
					&p_InPutSection[3], &p_InPutSection[6],
					 vy, vz );
			}
  			as$status( action = RET_STATUS );
  			as$status( sts = retcode, action = RET_STATUS );

  			p_OutPutSection[0] = vx0[0];
  			p_OutPutSection[1] = vx0[1];
  			p_OutPutSection[2] = vx0[2];
  			p_OutPutSection[3] = vy[0];
  			p_OutPutSection[4] = vy[1];
  			p_OutPutSection[5] = vy[2];
  			p_OutPutSection[6] = vz[0];
  			p_OutPutSection[7] = vz[1];
  			p_OutPutSection[8] = vz[2];
  		}
  		else
		{
			status = VR$GetMatrix(	p_msg		= &retcode,
						p_ComponentId 	= p_CmpId,
						CompCpt 	= CmpCptNum,
						p_Matrix	= tmp_matrix,
						p_MdEnv		= p_MdEnv );
			as$status( action = RET_STATUS );
			as$status( sts = retcode, action = RET_STATUS );

  			p_OutPutSection[0] = tmp_matrix[0] ;
  			p_OutPutSection[1] = tmp_matrix[4] ;
  			p_OutPutSection[2] = tmp_matrix[8] ;
  			p_OutPutSection[3] = tmp_matrix[1] ;
  			p_OutPutSection[4] = tmp_matrix[5] ;
  			p_OutPutSection[5] = tmp_matrix[9] ;
  			p_OutPutSection[6] = tmp_matrix[2] ;
  			p_OutPutSection[7] = tmp_matrix[6] ;
  			p_OutPutSection[8] = tmp_matrix[10];
		}

		break;

	case VR_SWITCH_SECTION:
		{
  			IGRdouble TmpValue;

			if( ! p_OutPutSection || ! p_InPutSection ) return OM_E_INVARG;
			
  			TmpValue   	   = p_InPutSection[3];
  			p_OutPutSection[3] = p_InPutSection[6];
  			p_OutPutSection[6] = TmpValue;

  			TmpValue   	   = p_InPutSection[4];
  			p_OutPutSection[4] = p_InPutSection[7];
  			p_OutPutSection[7] = TmpValue;

  			TmpValue   	   = p_InPutSection[5];
  			p_OutPutSection[5] = p_InPutSection[8];
  			p_OutPutSection[8] = TmpValue;
		
			break;
		}

	default : break;
  }		

  return OM_S_SUCCESS;

}

/****************************************************************************************/
/*											*/
/*	private function used only in the sketch.					*/
/*											*/
/*	This function switch width and depth to have always the witdh axis in the       */
/*      component's plane. we call this function now only to place an elbow in the 	*/
/*	VR$PlaceCmpByItemNum macro ( VRcreate.I )					*/
/*											*/
/****************************************************************************************/

VRSkGetHvacCmpParams( cmp_param, ParentList, orient_section, md_env, orient_angle )

union		VRparam_attr	*cmp_param;
struct		GRid		*ParentList;
IGRdouble			*orient_section;
struct		GRmd_env	*md_env;
IGRdouble			*orient_angle;

/*.VRSkGetHvacCmpParams */
{
  IGRint	NbCmp;
  BSrc		bsretcode;
  IGRlong	retcode, status;
  IGRdouble	TmpValue, orient_vector[6], cmp1_pt[6], cmp2_pt[6], dotp;
  IGRvector	tmp_vector;
  IGRboolean	TwistParams;

  retcode     = MSSUCC;
  status      = OM_S_SUCCESS;
  TwistParams = FALSE;

  if( orient_section == NULL ) return OM_S_SUCCESS;

  /*"orient_angle = %f\n", *orient_angle */

  status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                               ( &retcode, &NbCmp, md_env, cmp1_pt, NULL ),
                    senderid = NULL_OBJID,
                    targetid = ParentList[0].objid,
                    targetos = ParentList[0].osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"cmp1_pt = %f %f %f\n", cmp1_pt[0], cmp1_pt[1], cmp1_pt[2] */
  /*"cmp1_pt = %f %f %f\n", cmp1_pt[3], cmp1_pt[4], cmp1_pt[5] */

  /* get termination points of seg2 */


  status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                               ( &retcode, &NbCmp, md_env, cmp2_pt, NULL ),
                    senderid = NULL_OBJID,
                    targetid = ParentList[1].objid,
                    targetos = ParentList[1].osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"cmp2_pt = %f %f %f\n", cmp2_pt[0], cmp2_pt[1], cmp2_pt[2] */
  /*"cmp2_pt = %f %f %f\n", cmp2_pt[3], cmp2_pt[4], cmp2_pt[5] */

  BSmkvec( &bsretcode, &orient_vector[0], &cmp1_pt[0], &cmp1_pt[3] );
  BSmkvec( &bsretcode, &orient_vector[3], &cmp2_pt[0], &cmp2_pt[3] );
  BSnorvec( &bsretcode, &orient_vector[0] );
  BSnorvec( &bsretcode, &orient_vector[3] );

  BScrossp( &bsretcode, orient_vector, &orient_vector[3], tmp_vector );
  BSnorvec( &bsretcode, tmp_vector );

  /*"tmp_vector = %f %f %f\n", tmp_vector[0], tmp_vector[1], tmp_vector[2] */
  /*"orient_section = %f %f %f\n", orient_section[0], orient_section[1], orient_section[2] */

  dotp = BSdotp( &bsretcode, orient_section, tmp_vector );

  /*"dotp = %f\n", dotp */
          
  if( ( 1 - fabs( dotp ) ) < VRGetTol(VR_ORTHO_TOL) )
  {
    /*| first width is OUT ==> switch */

    TmpValue                     = cmp_param->hvac_attr.G_width;
    cmp_param->hvac_attr.G_width = cmp_param->hvac_attr.G_depth;
    cmp_param->hvac_attr.G_depth = TmpValue;

    TwistParams = TRUE;
  }

  /*"orient_section = %f %f %f\n", orient_section[3], orient_section[4], orient_section[5] */
  dotp = BSdotp( &bsretcode, &orient_section[3], tmp_vector );

  /*"dotp = %f\n", dotp */
          
  if( ( 1 - fabs( dotp ) ) < VRGetTol(VR_DOTPROD_TOL) )
  {
    /*| second width is OUT ==> switch */

    TmpValue                     = cmp_param->hvac_attr.R_width;
    cmp_param->hvac_attr.R_width = cmp_param->hvac_attr.R_depth;
    cmp_param->hvac_attr.R_depth = TmpValue;

    TwistParams = TRUE;
  }

  if( TwistParams )
  {
    /*BILLA  Double value comparison problem */
    if( fabs( *orient_angle) < VRGetTol(VR_ANGULAR_TOL) )
           *orient_angle = M_PI/2.0;
    else  
           *orient_angle = 0.0; 
  }

  /*"orient_angle = %f\n", *orient_angle */

  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#include "VRprivmacros.h"


VRSkUpdateParams( 	IGRshort			Product,
			struct		GRid		*p_OldActParamId,
			struct		GRid		*p_NewActParamId,
			IGRdouble			*p_ActSection,
			struct		GRmd_env	*p_MdEnv)

/*.VRSkUpdateParams */
{
  IGRlong			status, retcode;
  IGRdouble			TmpValue;
  struct	GRid		LocalActParamId;
  union		VRparam_attr	ActParam;

  status = VR$GetDimensionAttributes( 	p_retmsg	  = &retcode,
				     	Product		  = Product,
				 	p_SysCollectionId = p_OldActParamId,
			        	p_DimAttributes   = &ActParam, 
				 	p_MdEnv		  = p_MdEnv );
  as$status( action = RET_STATUS );

  if( ActParam.hvac_attr.G_width < ActParam.hvac_attr.G_depth )
  {
    TmpValue                   = ActParam.hvac_attr.G_width;
    ActParam.hvac_attr.G_width = ActParam.hvac_attr.G_depth;
    ActParam.hvac_attr.G_depth = TmpValue;

    LocalActParamId.objid = NULL_OBJID;
    LocalActParamId.osnum = p_MdEnv->md_id.osnum;
    status = VRModifyParameterBox
             ( &retcode, Product, &ActParam, p_OldActParamId, &LocalActParamId);
    as$status( action = RET_STATUS );

    /*"created ACrg_collect %d\n", LocalActParamId.objid */

    *p_NewActParamId = LocalActParamId;

    if( p_ActSection )
    {
	/* On permute Y et Z */
	status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
					p_InPutSection	= p_ActSection,
					p_OutPutSection	= p_ActSection );
    }
  }
  else
    *p_NewActParamId = *p_OldActParamId;

  return OM_S_SUCCESS;
}

/*****************************************************************************/

VRskComputeCmpAngle( CmpOrientSection, ParentId, CmpAngle, ModuleEnv )

IGRdouble			*CmpOrientSection;
struct		GRid		*ParentId;
IGRdouble			*CmpAngle;
struct		GRmd_env	*ModuleEnv;
{
  IGRlong			status, retcode;
  BSrc				bsretcode;
  IGRdouble			Scalar, Point[3], Normal[3];
  struct 	IGRplane	Plane;

  Plane.point  = Point;
  Plane.normal = Normal;

  status = om$send( msg      = message VRCnrlSeg.VRGetTopo
                               ( &retcode, NULL, NULL, &Plane, NULL, NULL,
                                 ModuleEnv 
                               ),
                    senderid = NULL_OBJID,
                    targetid = ParentId->objid,
                    targetos = ParentId->osnum );
  as$status();
  as$status( sts = retcode );

  /*"Ortho = %f %f %f\n", Plane.normal[0], Plane.normal[1], Plane.normal[2] */
  /*"Sect  = %f %f %f\n", CmpOrientSection[0],CmpOrientSection[1],CmpOrientSection[2] */

  Scalar = BSdotp( &bsretcode, Plane.normal, CmpOrientSection );

  /*"Scalar = %f\n", Scalar */

  if( fabs( Scalar ) < VRGetTol(VR_DOTPROD_TOL) ) *CmpAngle = M_PI/2.0;
  else                              *CmpAngle = 0.;

  return OM_S_SUCCESS;
}

end implementation Root;
