/* $Id: VRRCorentiti.I,v 1.4 2001/09/24 15:17:47 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcorrection / VRRCorentiti.I
 *
 * Description:
 *     	This file contains the method to evaluate correction entity.
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRRCorentiti.I,v $
 *	Revision 1.4  2001/09/24 15:17:47  anand
 *	TR 5468
 *	
 *	Revision 1.3  2001/02/20 01:13:22  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 16:06:02  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  22:44:38  pinnacle
# Created: route/vrcorrection/VRRCorentiti.I by lawaddel for Service Pack
#
# Revision 1.2  1999/05/04  13:45:52  pinnacle
# Replaced: vrcorrection/VRRCorentiti.I for:  by sbilla for route
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
# Revision 1.3  1996/01/16  23:26:34  pinnacle
# Replaced: vrcorrection/VRRCorentiti.I for:  by r240_int for route240
#
 *
 * History:
 *  	01/25/91    momo	creation
 *      06/14/95    Lori    	Modified VRGetCorCmpAttrs to not
 *                                make a copy of the system collection
 *                                if the dimensional attributes 
 *                                of the correction component were the 
 *                                same as the current collection. 
 *                                TR#179420979
 *	01/15/96    tlb		Add prototypes
 *      05/04/99    Reddy       Doble value comparision corrected
 *      09/21/01    Anand       TR 5468
 *
 *************************************************************************/


class implementation VRRCorentity;

#include <math.h>
#include <stdio.h>
#include "OMmacros.h"
#include "igrtypedef.h"
#include "bstypes.h"
#include "nddef.h"
#include "VRparamdef.h"
#include "VRpriv_attr.h"
#include "VRprivmacros.h"
#include "bsparameters.h"
#include "VRmacros.h"
#include "AS_status.h"
#include "vrdbgmacros.h"
#include "vrtools_pto.h"
#include "bsdotp.h"

#define AS_DEBUG

from	ACncpx		import	ACset_NV_rep;
from	VRGeneric	import	VRGetCptProp;
from	VRGeneric	import	VRGetCptGeom;
from  	VRGeneric	import	VRGetParams;
from	VRGeneric	import	VRGetNextOnCpt;

extern	OM_S_CHANSELECT	AS_to_comp;

/****************************************************************************/

method VRGetCorLenByCmp( IGRlong			*msg; 
                         struct 	GRid		*CmpId;
                         struct 	GRmd_env	*md_env;
  		         IGRdouble 			*Length )
{
  IGRshort			NbVia=0;
  IGRint			Index, NbParent;
  IGRlong			retcode, status;
  struct	GRid		FatherId[my_nbParent];
  union		VRparam_attr	CmpParams;

  SetProc( VRRCorentity_VRGetCorLenByCmp ); Begin
  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  if( CmpId )
  {
    status = om$send( msg      = message NDnode.NDget_objects
                                 ( ND_ROOT, FatherId, my_nbParent, NULL, 0, 
                                   OM_K_MAXINT, &NbParent
                                 ),
                      targetid = my_id );
    as$status( action = RET_STATUS );

    if( NbParent != my_nbParent )
    {
      as$status( sts = OM_E_ABORT, msg = "Invalid number of parents" );
      End
      return (OM_E_ABORT);
    }

    if( FatherId[0].objid == CmpId->objid ) Index = 0;
    else                                    Index = 1;

    status = om$send( msg      = message VRCorrection.VRGetCorLength
						 ( Index+3, md_env, Length ),
                      targetid = my_id );
    as$status( action = RET_STATUS );

    status = om$send( msg      = message VRGeneric.VRGetNextOnCpt
                                 ( &retcode, me->my_CmpCptIndex[Index], NULL,
                                   NULL, 0, &NbVia, NULL, NULL, md_env ),
                      targetid = CmpId->objid,
                      targetos = CmpId->osnum );

    /*"NbVia = %d\n", NbVia */

    if( NbVia && !(me->my_state&VR_COR_PID_REP) )
    {
      status = VR$GetDimensionAttributes(	p_retmsg        = &retcode,
                                       		Product         = VR_CABLING,
                                		p_ComponentId   = CmpId,
                                      		p_DimAttributes	= &CmpParams,
                                        	p_MdEnv      	= md_env );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );

/*  The increment of the length below, although appears to be a good
    thing to do, is not exactly understood. Further, the 0.25 factor appears
    arbitrary. Per suggestion of Ed Heinhold, the factor is being changed to
    0.01 (Anand for JTS TR MP 5468)
 */
//    *Length += 0.25 * CmpParams.hvac_attr.G_width;
      *Length += 0.01 * CmpParams.hvac_attr.G_width;
    }
  }

  /*"length = %f\n", *Length */
  End
  return OM_S_SUCCESS;

}

/*****************************************************************************/
/*
/*	GRvg override
/*
/**/

method GRgetobjinfo( IGRlong			*msg;
                     struct	GRobj_info	*info )
{
   SetProc( VRRCorentity_GRgetobjinfo ); Begin 
   *msg = MSSUCC;

   strcpy( info->type, "Raceway Correction" );
   End
   return(OM_S_SUCCESS);

}

/*****************************************************************************/
/*
/*	assoc override
/*
/**/

method ASconstruct_go( struct GRas *asso_lis; struct GRmd_env *md_env;
		       IGRchar *go_cnst_lis; GRclassid go_classid;
		       IGRboolean altconstruct )
{
  IGRlong status;

  extern GRclassid OPP_VRRComp_class_id;
  
  SetProc( VRRCorentity_VR ); Begin
  status = om$send( mode      = OM_e_wrt_message,
		    msg       = message VRCorrection.ASconstruct_go
					( asso_lis, md_env, go_cnst_lis, 
					  OPP_VRRComp_class_id, altconstruct ),
		    targetid = my_id );
  as$status();

  End
  return OM_S_SUCCESS;
}


/*****************************************************************************/
/*
/* This method get the dimensoin system paramters of a component 
/*
/**/

method VRGetCmpParams( IGRint CompType;
		       union VRparam_attr *PipeParams, *FatherParams,
					  *CmpParams )
{
  IGRshort 	Type;
  IGRint 	status;
  extern int VRGetCmpParams();

  SetProc( VRRCorentity_VRGetCmpParams ); Begin
  if( CompType & VR_REDUCER0 || CompType & VR_REDUCER1 ) Type = VR_RED;
  else							 Type = VR_ADP;
  
  status = VRGetCmpParams
           ( VR_CABLING, Type, PipeParams, FatherParams, CmpParams );
  as$status();

  End
  return OM_S_SUCCESS;
}

/*****************************************************************************/
/*
/* This method change the component system paramters.
/*
/**/

method VRChgCorCmpAttrs( IGRlong *msg; struct GRid *CorCmpId;
		         union VRparam_attr *CmpParams; IGRchar cRep;
			 struct GRmd_env *md_env )
{
	IGRint status;
	extern int VRChgCorCmpAttrs();

        SetProc( VRRCorentity_VRChgCorCmpAttrs ); Begin
        status = VRChgCorCmpAttrs( msg, VR_CABLING, CorCmpId, CmpParams, 
  				   cRep, md_env );
        as$status( action = RET_STATUS );
        as$status( sts = *msg, action = RET_STATUS );

        End
	return OM_S_SUCCESS;
}


/*****************************************************************************/
/*
/* This method get the component system parameters.
/*
/**/
 
method VRGetCorCmpAttrs( IGRlong *msg; union VRparam_attr *CmpParams; 
			 struct GRid *ActParamId, *CmpParamId;
			 struct GRmd_env *md_env )
{
	IGRint status;
	IGRlong retmsg;
        union  VRparam_attr  ActParams;
        
        SetProc( VRRCorentity_VRGetCorCmpAttrs ); Begin
        status = VR$GetDimensionAttributes ( p_retmsg          = &retmsg,
                                             Product           = VR_HVAC,
                                             p_SysCollectionId = ActParamId,
                                             p_DimAttributes   = &ActParams,
                                             p_MdEnv           = md_env);

        /* If the attributes are the same for the correction component as 
           in ActParamId, just use ActParamId - don't copy it */                         
	/*BILLA  Double value comparison problem */
        if ((ActParams.hvac_attr.shape == CmpParams->hvac_attr.shape)
                    &&
            (fabs(ActParams.hvac_attr.G_width - CmpParams->hvac_attr.G_width) < 1e-06)
                    &&
            (fabs(ActParams.hvac_attr.G_depth - CmpParams->hvac_attr.G_depth) < 1e-06)
                    &&
            (fabs(ActParams.hvac_attr.R_width - CmpParams->hvac_attr.R_width) < 1e-06)
                    &&
            (fabs(ActParams.hvac_attr.R_depth - CmpParams->hvac_attr.R_depth) < 1e-06) )
           {
                *CmpParamId = *ActParamId;
                End
                return OM_S_SUCCESS;
           }

        /* need to make a new collection to take into account the 
           new dimensional parameters */
        status = VRModifyParameterBox
             	 ( msg, VR_CABLING, CmpParams, ActParamId, CmpParamId );
	as$status();

        End
	return OM_S_SUCCESS;
}


/*****************************************************************************/
/*
/* This method get given correction template parameters.
/*
/**/

method VRGetTempAttr( IGRlong *msg; struct GRid *TempId, *ActParamId,
		      *UserParamId; union VRparam_attr *TempParams;
		      struct GRmd_env *md_env )
{
  IGRint status;
  extern int VRGetTempAttr();
  SetProc( VRRCorentity_VRGetTempAttr ); Begin
  status = VRGetTempAttr( msg, VR_CABLING, TempId, ActParamId, UserParamId,
			  TempParams, md_env );
  as$status();

  End
  return OM_S_SUCCESS;
}

/*****************************************************************************/

method VRBuild( IGRlong *msg; IGRint OldState; union VRparam_attr *PipeParams,
		*DimParams; struct GRid *ActParamId, *UserParamId; 
		IGRchar *go_cnst_lis; struct GRas *assoc_list;
		struct VRPlaceStr *PlaceStr; struct GRmd_env *md_env )
{
  IGRint			i, j, NbType=2, ComputeTable[5];
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	GRid		ParamsTable[8];
  union		VRparam_attr	DimParamsTable[4];

  SetProc( VRRCorentity_VRBuild ); Begin
  /*| apdate piping tables */
  ComputeTable[0] = VR_TRANS0;
  ComputeTable[1] = VR_REDUCER0;
  ComputeTable[2] = VR_TRANS1;
  ComputeTable[3] = VR_REDUCER1;
  ComputeTable[4] = -1;

  for( i=0,j=0; i<NbType; i++,j+=2 )
  {
	  DimParamsTable[i]        = DimParams[0];
	  DimParamsTable[i+NbType] = DimParams[1];

	  ParamsTable[j]            = ActParamId[0];
	  ParamsTable[j+1]          = UserParamId[0];
	  ParamsTable[j+2*NbType]   = ActParamId[1];
	  ParamsTable[j+1+2*NbType] = UserParamId[1];
  }

  status = om$send( msg      = message VRCorrection.VRCreate
                               ( &retcode, OldState, ComputeTable, ParamsTable,
			         PipeParams, DimParamsTable, go_cnst_lis, 
				 assoc_list, PlaceStr, md_env ),
                    targetid = my_id );
  as$status( action = RET_STATUS );

  End
  return OM_S_SUCCESS;
}

end implementation VRRCorentity;
