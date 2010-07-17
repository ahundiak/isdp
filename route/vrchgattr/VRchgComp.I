
/* $Id: VRchgComp.I,v 1.3 2001/02/20 01:11:57 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrchgattr/VRchgComp.I
 *
 * Description:
 *   This file contains the method needed to control a recompute of the
 *   objects whose attributes have changed.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRchgComp.I,v $
 *      Revision 1.3  2001/02/20 01:11:57  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/02/09 17:24:13  louis
 *      TR3367-add missing params to additional param form
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:41  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1999/08/04  06:06:50  pinnacle
# Replaced: vrchgattr/VRchgComp.I for: TR 179900778 by aharihar for route
#
# Revision 1.2  1998/11/06  22:44:32  pinnacle
# Replaced: vrchgattr/VRchgComp.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/03/08  23:43:30  pinnacle
# Replaced: vrchgattr/VRchgComp.I for:  by kddinov for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/04/25  13:37:46  pinnacle
# Replaced: vrchgattr/VRchgComp.I for:  by hverstee for route240
#
# Revision 1.2  1996/04/09  19:45:40  pinnacle
# Replaced: vrchgattr/VRchgComp.I for:  by hverstee for route240
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      04/08/96     hv         Split off from VRchgattr.sl
 *	3/98	   KDD		when me->dAirFlowSav changes update component 
 *				using VRGeneric.VRSetFlow method.
 *      11/98      law          tr179801939-raceway tiers not in collections
 *				correctly during sketching or modify.
 *	Aug 04 99  Anand	TR 179900778 - Reorganised sloppy code.
 *      02/08/01   law          TR3367-Adding missing param to additional
 *				parameter form.
 *
 *************************************************************************/

class implementation VRchgattr;

#include "OMprimitives.h"
#include "OMmacros.h"
#include "VRPid.h"
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRcompdef.h"
#include "VRattr_def.h"
#include "vrparameters.h"
#include "VRDbParamDef.h"
#include "VRuserdef.h"
#include "VRact_params.h"
#include "VRpriv_attr.h"
#include "VRprivmacros.h"
#include "VRmacros.h"
#include "VRformdef.h"
#include "VRMcForm.h"
#include "VRDbStruct.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "acrepdef.h"
#include "vrtools_pto.h"
#include "vrchgatt_pto.h"
#include "v_miscmacros.h"
#include "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe


extern  GRclassid  OPP_VRCorrection_class_id;
extern  GRclassid  OPP_VRNozzle_class_id;
extern  GRclassid  OPP_VRCptIn_class_id;

from  NDnode          import  NDget_objects;
from  ACrg_collect    import  AClist_attribute;
from  VRGeneric       import  VRResetCode;
from  VRGeneric       import  VRGetStatus; 
from  VRGeneric       import  VRGetCompDesc;
from  VRGeneric       import  VRIsGeometricAttr;
from  VRGeneric       import  VRGetSysType;
from  VRGeneric       import  VRSetFlow;
from  VRGeneric       import  VRGetParams;
from  VRProduct       import  VRGetProduct;
from  ACncpx	      import  ACgive_structure; /* TR179801939 */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


method VRCompute ( long * sts )
{
  IGRint         status;
  IGRlong        retcode;
  IGRshort       kk;
  IGRint         i, NbCompute=0, NbAttr, AttrInList=0;
  IGRint         cn_type = ND_COMP;
  IGRboolean     bIsGeometric;
  IGRchar       *p_AttrList[VR_MAX_ATTR];
  IGRchar        AttrList[VR_MAX_ATTR*80];
  GRclassid      p_classid;
/* Added for TR179801939 */
  struct  ACrg_coll   TempAttr[VR_MAX_ATTR];
  IGRint  NbTemp, depth_1_rec, depth_2_rec;
  IGRint  no_tiers, list_no_tier1_val, list_no_tier2_val;
  IGRint  list_no_tier1, list_sp_tier1, list_no_tier2, list_sp_tier2;
  IGRdouble tier_sp, list_sp_tier1_val, list_sp_tier2_val;
  IGRdouble depth_val;
  struct  GRid my_grid;

  struct  GRid       *pComputeId=NULL;
  struct  ACrg_coll   CompTopo, list_attr[VR_MAX_ATTR];
  struct ret_struct     ParamAttr;
  IGRint                FootIndex = -1, retstatus;


  SetProc( VRchgattr_VRCompute ); Begin
  /* ------------------------------ */
  /* -- Modify System attributes -- */
  /* ------------------------------ */

  status =
  om$send( msg = message ACrg_collect.AClist_attribute
                             ( &retcode, VR_MAX_ATTR, list_attr, &NbAttr ),
      targetid = me->SMoId.objid,
      targetos = me->SMoId.osnum );
  __CheckRC( status, retcode, "ACrg_collect.AClist_attribute", wrapup );

  __DBGpr_int(" Sys NbAttr",NbAttr);

  if (NbAttr)
  {
    /*| Update system collection */
    status =
    om$send( msg  = message VRchgattr.VRUpdateConnect
                       ( VR_SYSTEM_ATTR, me->NumOfSysCollect, me->SysParamId,
                          &me->SMoId, &me->ModuleInfo ),
         targetid = my_id );
    __CheckRC( status, 1, "VRchgattr.VRUpdateConnect", wrapup );
  }
  /* Processing for TR179801939 */
  depth_1_rec = -1;
  depth_2_rec = -1;
  list_no_tier1 = list_no_tier2 = 0;
  list_sp_tier1 = list_sp_tier2 = 0;
  list_no_tier1_val = list_no_tier2_val = 0;
  list_sp_tier1_val = list_sp_tier2_val = 0.0;

  /* -- Store Attributes names -- tr179801939 */
  for( i=0; i<NbAttr; i++ )
  {
    strcpy( &AttrList[AttrInList*80], list_attr[i].name );
    if(!strcmp(list_attr[i].name,VR_N_NUMTIER1_IN))
    {
      list_no_tier1 = 1;
      list_no_tier1_val = (IGRint) list_attr[i].desc.value.att_exp;
      __DBGpr_int( " no_tier1 found in replace collection ",list_no_tier1_val);
    }
    else if(!strcmp(list_attr[i].name,VR_N_TIERSP1_DB))
    {
      __DBGpr_com(" It shouldn't come here!! Old file?");
      list_sp_tier1 = 1;
      list_sp_tier1_val = list_attr[i].desc.value.att_exp;
      __DBGpr_dbl( " tier1_sp found in replace collection ",list_sp_tier1_val);
    }
    else if(!strcmp(list_attr[i].name,VR_N_NUMTIER2_IN))
    {
      list_no_tier2 = 1;
      list_no_tier2_val = (IGRint) list_attr[i].desc.value.att_exp;
      __DBGpr_int( " no_tier1 found in replace collection ",list_no_tier2_val);
    }
    else if(!strcmp(list_attr[i].name,VR_N_TIERSP2_DB))
    {
      __DBGpr_com(" It shouldn't come here!! Old file?");
      list_sp_tier2 = 1;
      list_sp_tier2_val = list_attr[i].desc.value.att_exp;
      __DBGpr_dbl( " tier1_sp found in replace collection ",list_sp_tier2_val);
    }
    else if(!strcmp(list_attr[i].name,VR_N_DEPTH1_DB))
    {
      depth_1_rec = i;
    }
    else if(!strcmp(list_attr[i].name,VR_N_DEPTH2_DB))
    {
      depth_2_rec = i;
    }

    p_AttrList[AttrInList] = &AttrList[AttrInList*80];    
    AttrInList++;
  }

  /* ---------------------------- */
  /* -- Modify User attributes -- */
  /* ---------------------------- */

  status =
  om$send( msg = message ACrg_collect.AClist_attribute
                               ( &retcode, VR_MAX_ATTR, list_attr, &NbAttr ),
      targetid = me->UMoId.objid,
      targetos = me->UMoId.osnum );
  __CheckRC( status, 1, "ACrg_collect.AClist_attribute", wrapup );

  /* -- Store Attributes names -- */
  for( i=0; i<NbAttr; i++ )
  {
    strcpy( &AttrList[AttrInList*80], list_attr[i].name );
    p_AttrList[AttrInList] = &AttrList[AttrInList*80];    
    AttrInList++;
  }

  { /* -- Get the total number of user attributes modified -- */
    IGRint  NbUserAttr;

    status =
    om$send( msg = message ACrg_collect.AClist_attribute
                                 ( &retcode, 0, NULL, &NbUserAttr ),
        targetid = me->UAdId.objid,
        targetos = me->UAdId.osnum );
    __CheckRC( status, 1, "ACrg_collect.AClist_attribute", wrapup );

    NbAttr+=NbUserAttr;

    status =
    om$send( msg = message ACrg_collect.AClist_attribute
                                  ( &retcode, 0, NULL, &NbUserAttr ),
        targetid = me->UDeId.objid,
        targetos = me->UDeId.osnum );
    __CheckRC( status, 1, "ACrg_collect.AClist_attribute", wrapup );

    NbAttr+=NbUserAttr;
  }/* end of getting the total number of user attributes */

  if (NbAttr)
  {
     /***** TR3367 adding missing parameters to additional param list ******/
     if(me->NumOfLocatedObjects == 1)
     {
        struct GRid SysParamId,UsrParamId,MisParamId;
                status = om$send( msg      = message VRGeneric.VRGetParams(
                                   &kk,&SysParamId,&UsrParamId,&MisParamId),
				targetid = me->LocatedObjects[0].objid,
				targetos = me->LocatedObjects[0].osnum);

			/* -- Modify attributes -- */
		status =
	  	     VR$ModifyCollection (   p_msg      = &retcode,
					Operation  = VR_UPDATE_COLL
	,
					p_InputCollectionId  = &me->UMoId,
					p_OutputCollectionId = &MisParamId );
			as$status ();
     }

    /*| Update user collection */
    status =
    om$send( msg = message VRchgattr.VRUpdateConnect
                        ( VR_USER_ATTR, me->NumOfUserCollect, me->UserParamId,
                        &me->UsrId, &me->ModuleInfo),
        targetid = my_id );
    __CheckRC( status, 1, "VRchgattr.VRUpdateConnect", wrapup );
  }

  /* -- If no modification : return -- */
  if( !AttrInList ) return OM_S_SUCCESS; /* no modification */


  /* -- Check whether the graph has to be recomputed or not -- */
  pComputeId = _MALLOC( me->NumOfLocatedObjects, struct GRid );

  strcpy( CompTopo.name, VR_N_COMP_TOPO_IN );

  for( i=0; i<me->NumOfLocatedObjects; i++ )
  {
    IGRshort  CmpStatus;

    /* get class id to see if this is a nozzle. If so, skip it */

    status =
    om$get_classid( osnum = me->LocatedObjects[i].osnum,
                    objid = me->LocatedObjects[i].objid,
                p_classid = &p_classid );

    if (((om$is_ancestry_valid( subclassid = p_classid,
                              superclassid = OPP_VRNozzle_class_id))
                                                      == OM_S_SUCCESS ) ||
        ((om$is_ancestry_valid( subclassid = p_classid,
                              superclassid = OPP_VRCptIn_class_id))
                                                      == OM_S_SUCCESS ))
                              continue;

    /*    TR 179601741
        in case the pocketmenu network select has been chosen we still
        have to check for the product....... you can't win             */

    status =
    om$send (msg = message VRProduct.VRGetProduct (&kk, NULL),
        targetid = me->LocatedObjects[i].objid,
        targetos = me->LocatedObjects[i].osnum );

    if (kk != me->product) continue;

    /*| See if the component is a correction component */
    status =
    om$send( msg = message VRGeneric.VRGetStatus ( &retcode, &CmpStatus ),
        targetid = me->LocatedObjects[i].objid,
        targetos = me->LocatedObjects[i].osnum );
    as$status();
    if ( !(status&1) ) continue;

    /*"CmpStatus = %d\n", CmpStatus */

/* 3-98 KDD Now we do care about all pipe, HVAC RWAY components */

     if (me->dAirFlowSav > 0.0 ) {  
        status = om$send( msg      = message VRGeneric.VRSetFlow (&retcode, 
                                         0, NULL, &me->dAirFlowSav, 
                                        &me->ModuleInfo),
                          targetid = me->LocatedObjects[i].objid,
                          targetos = me->LocatedObjects[i].osnum );
        as$status();
     }

/* 3-98 KDD commented out 
*
*    if (CmpStatus&VR_CORRECTION)
*    {
*      IGRshort nCmpType;
*
*      /* -- Do not care about other correction components -- 
*      /* -- than pipes -- 
*
*      /*| See if the component is a pipe 
*      status =
*      om$send( msg = message VRGeneric.VRGetSysType ( &retcode, &nCmpType ),
*          targetid = me->LocatedObjects[i].objid,
*          targetos = me->LocatedObjects[i].osnum );
*      as$status();
*      if ( !(status&1) || (nCmpType!=VR_PIPE) ) continue;
*    }
*
*    /*   super kludge implementation, if flowrate is updated
*         propagate to the adjoining corrections..... 
*    else     /*   not for correction components themselves  
*     {
*      if (me->dAirFlowSav > 0)
*      {
*        struct GRid    Children[5];
*        IGRint         NbChildren;
*        IGRint         ii;
*        GRclassid      p_classid;
*
*        status =
*        om$send( msg = message NDnode.NDget_objects
*                     ( ND_CHILDREN, Children, 5,
*                       NULL, 0, OM_K_MAXINT, &NbChildren ),
*            targetid = me->LocatedObjects[i].objid,
*            targetos = me->LocatedObjects[i].osnum );
*        as$status();
*
*        for (ii=0; ii<NbChildren; ii++)
*        {
*
*          status =
*          om$get_classid( osnum = Children[ii].osnum,
*                          objid = Children[ii].objid,
*                      p_classid = &p_classid );
*
*          if ((om$is_ancestry_valid( subclassid = p_classid,
*                                   superclassid = OPP_VRCorrection_class_id))
*                    != OM_S_SUCCESS )  continue;
*
*          status =
*          om$send( msg = message VRCorrection.VRSetFlow
*                        (&retcode, 0, NULL, &me->dAirFlowSav, &me->ModuleInfo),
*              targetid = Children[ii].objid,
*              targetos = Children[ii].osnum );
*          as$status();
*        }
*      }
*    }
*/

/*************************************************************************
 * One should refer to the earlier version of this file to see how sloppy
 * indentation could result in WRONG coding.
 * Reorganised curly braces, some lines of code and corrected indentations to
 * result in the following two if-conditions. Also removed some obsolete code
 * (related to old attributes for tier spacing).
 * 						- Anand for TR 179900778
 *************************************************************************/

    /* Tier processing added for TR179801939 */
    /* If Raceway, check if no_tiers and tier_spacing in list  */
    /* If either is in list */

    NbTemp = 0;

    if(me->product == VR_RWAY && (list_no_tier1 || list_sp_tier1))
    {
	/* If not both in list */
	if( !list_no_tier1 || !list_sp_tier1)
	{
	    __DBGpr_obj(" processing tier1 for ", me->LocatedObjects[i] );

	    /* If no_tiers */
	    if( list_no_tier1 )
	    {
		no_tiers = list_no_tier1_val;
		__DBGpr_com( " no_tiers1 taken from replace collection");
	    }
	    else
	    {
		/* Get the no_tiers from each located object */
		status = om$send( msg    = message ACncpx.ACgive_structure
							    ( &retstatus,
							      &FootIndex,
							      VR_N_NUMTIER1_IN,
							      &ParamAttr,
							      &me->ModuleInfo),
				senderid = NULL_OBJID,
				targetid = me->LocatedObjects[i].objid,
				targetos = me->LocatedObjects[i].osnum );

		if(retstatus == OM_S_SUCCESS)
		    no_tiers = (IGRint) ParamAttr.var.root_pm_st.value;
		else
		    no_tiers = 1;
	    }
	    __DBGpr_int(" no_tiers1 for obj is ", no_tiers);

	    /* If tier spacing */ 
	    if ( list_sp_tier1 )
	    {
		__DBGpr_com(" It shouldn't come here!! Old file?");
		tier_sp = list_sp_tier1_val;
		__DBGpr_dbl(" tiers1_sp for obj is ", tier_sp);
		__DBGpr_com( " tier1_sp taken from replace collection");
		depth_val = no_tiers * tier_sp;
	    }
	    else
	    {
		status = om$send( msg    = message ACncpx.ACgive_structure
							    ( &retstatus,
							      &FootIndex,
							      VR_N_DEPTH1_DB,
							      &ParamAttr,
							      &me->ModuleInfo),
				targetid = me->LocatedObjects[i].objid,
				targetos = me->LocatedObjects[i].osnum );
		depth_val = ParamAttr.var.root_pm_st.value;
	    }

	    /* depth absence is problem, add check here */
	    if(depth_1_rec == -1)
	    {
		/* depth not in replace collection. Update object directly */
	    }
	    else
	    {
		__DBGpr_dbl("computed depth ",depth_val);

		strcpy( TempAttr[NbTemp].name , VR_N_DEPTH1_DB );
		TempAttr[NbTemp].desc.type = AC_ATTRIB_DOUBLE;
		TempAttr[NbTemp].desc.value.att_exp = depth_val;
		NbTemp++;
	    }
	}
    }

    if(me->product == VR_RWAY && (list_no_tier2 || list_sp_tier2))
    {
	/* If not both in list */
	/* This check should be redundant i.e., always true. */
	if( !list_no_tier2 || !list_sp_tier2)
	{
	    __DBGpr_obj(" processing tier2 for ", me->LocatedObjects[i] );

	    /* If no_tiers */
	    if( list_no_tier2 )
	    {
		no_tiers = list_no_tier2_val;
		__DBGpr_com( " no_tiers2 taken from replace collection");
	    }
	    else
	    {
		/* Get the no_tiers from each located object */
		status = om$send( msg    = message ACncpx.ACgive_structure
							    ( &retstatus,
							      &FootIndex,
							      VR_N_NUMTIER2_IN,
							      &ParamAttr,
							      &me->ModuleInfo),
				senderid = NULL_OBJID,
				targetid = me->LocatedObjects[i].objid,
				targetos = me->LocatedObjects[i].osnum );

		if(retstatus == OM_S_SUCCESS)
		    no_tiers = (IGRint) ParamAttr.var.root_pm_st.value;
		else
		    no_tiers = 1;
	    }
	    __DBGpr_int(" no_tiers2 for obj is ", no_tiers);

	    /* If tier spacing */ 
	    if ( list_sp_tier2 )
	    {
		__DBGpr_com(" It shouldn't come here!! Old file?");
		tier_sp = list_sp_tier2_val;
		__DBGpr_dbl(" tiers2_sp for obj is ", tier_sp);
		__DBGpr_com( " tier2_sp taken from replace collection");
		depth_val = no_tiers * tier_sp;
	    }
	    else
	    {
		status = om$send( msg    = message ACncpx.ACgive_structure
							    ( &retstatus,
							      &FootIndex,
							      VR_N_DEPTH2_DB,
							      &ParamAttr,
							      &me->ModuleInfo),
				targetid = me->LocatedObjects[i].objid,
				targetos = me->LocatedObjects[i].osnum );
		depth_val = ParamAttr.var.root_pm_st.value;
	    }

	    /* depth absence is problem, add check here */
	    if(depth_2_rec == -1)
	    {
		/* depth not in replace collection. Update object directly */
	    }
	    else
	    {
		__DBGpr_dbl("computed depth ",depth_val);

		strcpy( TempAttr[NbTemp].name , VR_N_DEPTH2_DB );
		TempAttr[NbTemp].desc.type = AC_ATTRIB_DOUBLE;
		TempAttr[NbTemp].desc.value.att_exp = depth_val;
		NbTemp++;
	    }
	}
    }

    __DBGpr_int(" number updated replace collection values ",NbTemp);
    if(NbTemp)
    {
	status =
	VR$ModifyCollection (   p_msg                   = &retcode,
				Operation               = VR_MERGE_COLL,
				p_ParamsListToModify    = TempAttr,
				NbParamsToModify        = NbTemp,
				p_OutputCollectionId    = &me->SMoId );

	status = om$send( msg  = message VRchgattr.VRUpdateConnect
							 ( VR_SYSTEM_ATTR,
							   me->NumOfSysCollect,
							   me->SysParamId,
							   &me->SMoId,
							   &me->ModuleInfo ),
		      targetid = my_id );
    } 

    /*| Call VRIsGraphicAttr */
    status =
    om$send( msg = message VRGeneric.VRIsGeometricAttr
                                      ( &retcode, AttrInList, p_AttrList,
                                        &bIsGeometric, &me->ModuleInfo ),
        targetid = me->LocatedObjects[i].objid,
        targetos = me->LocatedObjects[i].osnum );
    as$status();
    if ( !(status&1) ) continue;

    if( bIsGeometric )
    {

      if( !(CmpStatus&VR_CORRECTION) )
      {
        IGRint  NewTopo;

        /*| is component */
        pComputeId[NbCompute] = me->LocatedObjects[i];
        NbCompute++;

        /*    reset system components to force re-evaluation    */

        status =
        om$send (msg = message VRGeneric.VRResetCode (&retcode),
            targetid = pComputeId[NbCompute-1].objid,
            targetos = pComputeId[NbCompute-1].osnum );

        /* TEE BY OLET OR OLET BY TEE management */
        status =
        om$send( msg = message VRGeneric.VRGetCompDesc
                                     ( &retcode, &CompTopo, &me->ModuleInfo ),
            targetid = pComputeId[NbCompute-1].objid,
            targetos = pComputeId[NbCompute-1].osnum );
        as$status( action = CONTINUE );

        NewTopo = (IGRint) CompTopo.desc.value.att_exp;

        if(me->BranchType[i] != NewTopo)
        {
          status =
          VRUpdate( &pComputeId[NbCompute-1], me->BranchType[i],
                           NewTopo, &me->ModuleInfo );
          as$status();
          if ( !(status&1) ) continue;
        }
      }
      else
      { 
        IGRint  wait_index;

        /*| It's a correction component */

        status = ASget_as_owner( &me->LocatedObjects[i],
                                  &pComputeId[NbCompute] );
        as$status();
        if ( !(status&1) ) continue;
        
        NDis_waiting(  GR_DELETED, 0, &pComputeId[NbCompute],
             &wait_index, NULL, NULL, 1 );
        if( wait_index != -1 )  NbCompute++;;
      }


    }/* end geometry changed */

    /*"component to compute = %d\n", me->LocatedObjects[i].objid */
    nd$wait_batch(   type = GR_GEOM_POSTED,
               l_object   = &me->LocatedObjects[i],
               l_obj_info = &cn_type,
               nb_obj     = 1 );

  }/* end loop on components */

  /* -- Compute all components and corrections -- */
  nd$exec_batch( mode = 0 );

  /*| Update Construction */

  if( me->NumOfLocatedObjects )
  {
    status =
    VRUpdateConstruction( &retcode,NbCompute,
          pComputeId, &me->ModuleInfo) ;
    as$status();
  }

wrapup :

  ASend_fence();

    me->LocatedObjects   = NULL ;

  _FREE( pComputeId );
  End

  return OM_S_SUCCESS;
}

end implementation VRchgattr;
