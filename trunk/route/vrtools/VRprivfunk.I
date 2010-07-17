/* $Id: VRprivfunk.I,v 1.3 2001/02/20 01:18:16 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRprivfunk.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRprivfunk.I,v $
 *	Revision 1.3  2001/02/20 01:18:16  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 20:09:33  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/24  01:32:50  pinnacle
# Created: route/vrtools/VRprivfunk.I by lawaddel for Service Pack
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
# Revision 1.2  1996/01/18  00:33:12  pinnacle
# Replaced: vrtools/VRprivfunk.I for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96   tlb		Add prototypes, 
 *
 *************************************************************************/
/********************************************************************************************/
/*
/*	File 	: VRprivfun.I
/*	Author	: momo ( ISDC, Paris )
/*	Date	: 08-April-92 Route release 1.5
/*	
/********************************************************************************************/

class implementation Root;


#include "OMminimum.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "nddef.h"
#include "VRutildef.h"
#include "exmacros.h"
#include "VRmacros.h"
#include "VRutilmacros.h"
#include "VRdef.h"
#include "VRcordef.h"
#include "VRdimdef.h"
#include "VRparamdef.h"
#include "VRpriv_attr.h"
#include "AS_status.h"
#include "vrtools_pto.h"
#include        "vrdbgmacros.h"

#define AS_DEBUG

from	ACncpx		import	ACgive_structure;
from    NDnode          import  NDget_objects;
from    VRGeneric       import  VRGetSupOnCpt, VRGetSupports;
from    VRCorrection    import  VRGetCptIndex;


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 private function used to get attributs from a given component. for system attributs we return
 only attributes predefined by the system ( active parameters )

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRGetCmpAttributes( p_retmsg, Product, p_CmpId, CmpCptNum, p_SysParamId, p_UserParamId, 
		    p_MissParamId, p_MdEnv )

IGRlong			*p_retmsg;
IGRshort		Product;
struct	GRid		*p_CmpId;
IGRshort		CmpCptNum;
struct	GRid		*p_SysParamId;
struct	GRid		*p_UserParamId;
struct	GRid		*p_MissParamId;
struct	GRmd_env	*p_MdEnv;

/*.VRGetCmpAttributes */
{
  IGRlong  		status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	GRid	ActParamId;


  *p_retmsg = MSSUCC;

  if( ! p_CmpId ) return OM_E_INVARG;
  
  status = VR$GetAttributes(	p_retmsg		= &retcode,
				Product			= Product,
				CloneFlag		= TRUE,
				p_ComponentId		= p_CmpId,
				CmpCptNum		= CmpCptNum,
				p_SysParamId		= p_SysParamId,
				p_UserParamId		= p_UserParamId,
				p_MissParamId		= p_MissParamId,
				p_MdEnv			= p_MdEnv );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );		

  /*^ if( p_SysParamId ) VRprint_user_attr( p_SysParamId ); */	

  status = VR$GetAttributes( 	p_retmsg		= &retcode,
				Product			= Product,
				CloneFlag		= TRUE,
				p_SysParamId		= &ActParamId,
				p_MdEnv			= p_MdEnv );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
	
  status = VR$ModifyCollection(	p_msg			= &retcode,
				Operation		= VR_UPDATE_COLL,
				p_InputCollectionId	= p_SysParamId,
 				p_OutputCollectionId	= &ActParamId );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  *p_SysParamId = ActParamId;

  return OM_S_SUCCESS;

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 private function used to get only dimension attributes from a collection
 
	in piping 	: G_DIAMETER and R_DIAMETER
	in hvac		: G_WIDTH, G_DEPTH, R_WIDTH, R_DEPTH, SHAPE

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRGetDimensionAttributes( p_retmsg, Product, p_CmpId, CmpCptNum, p_SysCollectionId,
			  p_DimAttributes, p_MdEnv )

IGRlong			*p_retmsg;
IGRshort		Product;
struct	GRid		*p_CmpId;
IGRint			CmpCptNum;
struct	GRid		*p_SysCollectionId;
union	VRparam_attr	*p_DimAttributes;
struct	GRmd_env	*p_MdEnv;

/*.VRGeDimensionAttributes */
{
  IGRint			sts, FootIndex=-1;
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	GRid		ParamId, *p_ParamId;
  struct	ret_struct	ParamAttr;


  *p_retmsg    = MSSUCC;

  if( !p_DimAttributes || ! ( p_SysCollectionId || p_CmpId ) ) return OM_E_INVARG;

  if( p_CmpId )
  {
	/*"cmpId = %d %d\n", p_CmpId->objid, p_CmpId->osnum */

	p_ParamId = &ParamId;
	
      	status = VR$GetAttributes(	p_retmsg        = &retcode,
					Product         = Product,
					p_ComponentId   = p_CmpId,
					CmpCptNum	= CmpCptNum,
					p_SysParamId    = p_ParamId,
                        	        p_MdEnv      	= p_MdEnv );
      	as$status( action = RET_STATUS );
      	as$status( sts = retcode, action = RET_STATUS );
  }
  else p_ParamId = p_SysCollectionId;

  /*"ParamId = %d %d\n", p_ParamId->objid, p_ParamId->osnum */

  if( Product == VR_PIPING )
  {	
     	status = om$send( msg      = message ACncpx.ACgive_structure
                                 	( &sts, &FootIndex, VR_N_GDIAMETER_DB, &ParamAttr, p_MdEnv ),
       	               	  senderid = NULL_OBJID,
		          targetid = p_ParamId->objid,
		          targetos = p_ParamId->osnum );
    	as$status( action = RET_STATUS );
      	as$status( sts = sts, action = RET_STATUS );

      	p_DimAttributes->piping_attr.G_diameter = ParamAttr.var.root_pm_st.value;
      	/*"Cmp_G_diam = %f\n", p_DimAttributes->piping_attr.G_diameter */

      	status = om$send( msg      = message ACncpx.ACgive_structure
                                	( &sts, &FootIndex, VR_N_RDIAMETER_DB, &ParamAttr, p_MdEnv ),
       	               	  senderid = NULL_OBJID,
	  	       	  targetid = p_ParamId->objid,
		       	  targetos = p_ParamId->osnum );
      	as$status( action = RET_STATUS );
      	as$status( sts = sts, action = RET_STATUS );

      	p_DimAttributes->piping_attr.R_diameter = ParamAttr.var.root_pm_st.value;
  	/*"Cmp_R_diam = %f\n", p_DimAttributes->piping_attr.R_diameter */
    }
    else
    {
      	status = om$send( msg      = message ACncpx.ACgive_structure
                                 	( &sts, &FootIndex, VR_N_SHAPE_IN, &ParamAttr, p_MdEnv ),
       	               	  senderid = NULL_OBJID,
		          targetid = p_ParamId->objid,
		          targetos = p_ParamId->osnum );
     	as$status( action = RET_STATUS );
      	as$status( sts = sts, action = RET_STATUS );

      	p_DimAttributes->hvac_attr.shape = ParamAttr.var.root_pm_st.value;
     	/*"Cmp_shape = %d\n", p_DimAttributes->hvac_attr.shape */

      	status = om$send( msg      = message ACncpx.ACgive_structure
                                   	( &sts, &FootIndex, VR_N_WIDTH1_DB, &ParamAttr, p_MdEnv ),
       	               	  senderid = NULL_OBJID,
	  	       	  targetid = p_ParamId->objid,
		       	  targetos = p_ParamId->osnum );
      	as$status( action = RET_STATUS );
      	as$status( sts = sts, action = RET_STATUS );

      	p_DimAttributes->hvac_attr.G_width = ParamAttr.var.root_pm_st.value;
      	/*"Cmp_G_width = %f\n", p_DimAttributes->hvac_attr.G_width */

      	status = om$send( msg      = message ACncpx.ACgive_structure
                                   	( &sts, &FootIndex, VR_N_DEPTH1_DB, &ParamAttr, p_MdEnv ),
       	               	  senderid = NULL_OBJID,
	  	       	  targetid = p_ParamId->objid,
		       	  targetos = p_ParamId->osnum );
      	as$status( action = RET_STATUS );
      	as$status( sts = sts, action = RET_STATUS );

      	p_DimAttributes->hvac_attr.G_depth = ParamAttr.var.root_pm_st.value;
      	/*"Cmp_G_depth = %f\n", p_DimAttributes->hvac_attr.G_depth */

      	status = om$send( msg      = message ACncpx.ACgive_structure
                                  	( &sts, &FootIndex, VR_N_WIDTH2_DB, &ParamAttr, p_MdEnv ),
       	               	  senderid = NULL_OBJID,
	  	       	  targetid = p_ParamId->objid,
		       	  targetos = p_ParamId->osnum );
      	as$status( action = RET_STATUS );
      	as$status( sts = sts, action = RET_STATUS );

      	p_DimAttributes->hvac_attr.R_width = ParamAttr.var.root_pm_st.value;
      	/*"Cmp_R_width = %f\n", p_DimAttributes->hvac_attr.R_width */

      	status = om$send( msg      = message ACncpx.ACgive_structure
                                   	( &sts, &FootIndex, VR_N_DEPTH2_DB, &ParamAttr, p_MdEnv ),
       	               	  senderid = NULL_OBJID,
	  	       	  targetid = p_ParamId->objid,
		       	  targetos = p_ParamId->osnum );
      	as$status( action = RET_STATUS );
      	as$status( sts = sts, action = RET_STATUS );

      	p_DimAttributes->hvac_attr.R_depth = ParamAttr.var.root_pm_st.value;
      	/*"Cmp_R_Depth = %f\n", p_DimAttributes->hvac_attr.R_depth */
  }

  return OM_S_SUCCESS;

}
/**********************************************************/

VRUpdateConstruction( msg, NbCmp, CmpId, md_env )

IGRlong			*msg;
IGRint			NbCmp;
struct	GRid		*CmpId;
struct	GRmd_env	*md_env;

/*.VRupdateConstruction */
{
  IGRshort			CptIndex;
  IGRint			i, j, NbFather, NbSupp;
  IGRlong			retcode=MSSUCC, status=OM_S_SUCCESS;
  GRclassid			CmpClassId;
  struct	GRid		SegId, SupportId[VR_MAX_CPTS];
  struct	GRid		CorFather[my_nbParent];

  SetProc( Func_VRUpdateConstruction ); Begin
  *msg = MSSUCC;

  for( i=0; i<NbCmp; i++ )
  {
    /*"See if the component %d is a correction component\n", CmpId[i].objid */

    om$get_classid( p_classid = &CmpClassId,
                    objid     = CmpId[i].objid,
                    osnum     = CmpId[i].osnum );

    if( om$is_ancestry_valid( superclassid = OPP_VRCorrection_class_id, 
                              subclassid   = CmpClassId ) == OM_S_SUCCESS )
    {
      /*| It's a correction */

      status = om$send( msg      = message NDnode.NDget_objects
                                   ( ND_ROOT, CorFather, my_nbParent, NULL, 0,
                                     OM_K_MAXINT, &NbFather ),
                        senderid = NULL_OBJID,
                        targetid = CmpId[i].objid,
                        targetos = CmpId[i].osnum );
      as$status( action = RET_STATUS );

      /*"Cor Father = %d %d\n", CorFather[0].objid, CorFather[1].objid */

      for( j=0; j<NbFather; j++ )
      {
        status = om$send( msg      = message VRCorrection.VRGetCptIndex
                                     ( &retcode, &CorFather[j], &CptIndex ),
                          senderid = NULL_OBJID,
                          targetid = CmpId[i].objid,
                          targetos = CmpId[i].osnum );
        as$status( action = RET_STATUS );

        /*"Father[%d] CptIndex = %d\n", j, CptIndex */

        status = om$send( msg      = message VRGeneric.VRGetSupOnCpt
                                     ( &retcode, CptIndex, &SegId, md_env ), 
                          senderid = NULL_OBJID,
                          targetid = CorFather[j].objid,
                          targetos = CorFather[j].osnum );
        as$status( action = RET_STATUS );
        as$status( sts = retcode, action = RET_STATUS );

        /*"Sup On Cpt #%d is %d\n", CptIndex, SegId.objid */

        /*| Do Change Segment Length ==> xform the end plane if neccessary */

        status = VRChangeSegLength( 1, -1, &SegId, md_env );
        as$status( action = RET_STATUS );    
      }
    }
    else
    {
      /*| Is a component */

      /*| get component's supports to update construction */

      status = om$send( msg      = message VRGeneric.VRGetSupports
                                 ( &retcode, VR_MAX_CPTS, SupportId, &NbSupp ),
                      senderid = NULL_OBJID,
                      targetid = CmpId[i].objid,
                      targetos = CmpId[i].osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );

      for( j=0; j<NbSupp; j++ )
      {
        /*| Do Change Segment Length ==> xform the end plane if neccessary */
        status = VRChangeSegLength( 1, -1, &SupportId[j], md_env );
        as$status( action = RET_STATUS );
      }
    }
  }

  End
  return OM_S_SUCCESS;
}



end implementation Root;
