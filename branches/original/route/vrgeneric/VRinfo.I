/* $Id: VRinfo.I,v 1.4 2002/04/10 19:42:29 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrgeneric / VRinfo.I
 *
 * Description:
     This file contains the methods returning info on a generic
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VRinfo.I,v $
 *        Revision 1.4  2002/04/10 19:42:29  louis
 *        TR5649-standardize tolerances
 *
 *        Revision 1.3  2001/02/20 01:14:15  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.2  2001/01/12 20:44:26  anand
 *        SP merge
 *
# Revision 1.1  2000/05/23  23:18:54  pinnacle
# Created: route/vrgeneric/VRinfo.I by lawaddel for Service Pack
#
# Revision 1.2  1998/05/22  19:14:42  pinnacle
# TR179801102
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.9  1998/03/17  18:35:50  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by kddinov for route
#
# Revision 1.8  1998/03/12  08:23:22  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by apazhani for route
#
# Revision 1.7  1998/03/08  23:04:28  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by kddinov for route
#
# Revision 1.6  1998/02/10  21:24:14  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by lawaddel for route
#
# Revision 1.5  1998/01/26  10:39:48  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by apazhani for route
#
# Revision 1.4  1998/01/22  05:24:54  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by apazhani for route
#
# Revision 1.3  1997/12/11  19:56:52  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by impd for route
#
# Revision 1.2  1997/10/30  17:12:18  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by kddinov for route
#
# Revision 1.6  1997/10/01  20:51:38  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by kddinov for route
#
# Revision 1.5  1997/06/24  21:53:52  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by kddinov for route
#
# Revision 1.4  1997/06/05  15:39:20  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by apazhani for route
#
# Revision 1.3  1997/02/22  00:27:12  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by kddinov for route
#
# Revision 1.2  1996/11/08  04:23:26  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by apazhani for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.9  1996/06/06  13:41:26  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by ashankar for route240
#
# Revision 1.8  1996/05/14  15:43:10  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by ashankar for route240
#
# Revision 1.7  1996/05/01  23:32:04  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by ashankar for route240
#
# Revision 1.6  1996/03/19  22:04:52  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by hverstee for route240
#
# Revision 1.5  1996/01/22  17:48:48  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by azuurhou for route240
#
# Revision 1.4  1996/01/19  11:38:06  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by ashankar for route240
#
# Revision 1.3  1996/01/17  00:02:12  pinnacle
# Replaced: vrgeneric/VRinfo.I for:  by r240_int for route240
#
 *
 * History:
 *        01/15/96        tlb        Add VX_FIproto.h, prototypes
 *        01/18/96        cas        Deleted VX_FIproto.h
 *        06/05/97        Alwin      Made check for Non-Standard components
 *                                   like ANGV, to fetch the correct macro.
 *	  June 1997	  kdd	     Flow Propagation is done by
 *				     VRCorrection.VRPropagateFlow.
 *	  01/22/98        Alwin      In the Md GetModel added a check for
 *				     Comp Code obtained from DB.
 *        02/09/98        law        TR179603574- Resizing ducts failing
 *                                   PARTIAL FIX. fitting to fitting still
 *                                   has problems. Resizing reverses the flow.
 *        03/12/98        Alwin      TR179800781- Re-stated the above check in
 *                                   VRGetModel.
 *        05/22/98        ah         TR179801102 Found some error messages with garbage
 *        04/05/02        law        TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

class implementation VRGeneric;

/*
#define AS_DEBUG  1
#define vdsDEBUG	1
*/

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRdef.h"
#include "VRMath.h"
#include "VRattr_def.h"
#include "vrparameters.h"
#include "VRDbParamDef.h"
#include "VRDbStruct.h"
#include "bserr.h"
#include "asbox.h"
#include "acrepdef.h"
#include "VRPid.h"

#include "vrpdu_pto.h"
#include "vrtools_pto.h"

#include "bstypes.h"
#include "bsparameters.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bslenvec.h"

#include "VRcordef.h"
#include "vrdbgmacros.h"


#define VRMAXCRIT     10

from ACrg_collect  import   ACget_named_attribute;
from ACrg_collect  import   AClist_attribute;
from VRProduct     import   VRGetSpecComp;
from VRProduct     import   VRGetSearch;
from VRProduct     import   VRGetProduct;
from VRCorrection  import   VRGetFlow;

/***********************************************************************/

method VRGetSysType ( IGRlong *msg; IGRshort *nSysType )

{

  *msg = MSSUCC;

  *nSysType = 0;

  return ( OM_S_SUCCESS );

}/* end VRGetSysType */

/***********************************************************************/

method VRGetCode ( IGRlong *msg; IGRchar *szAABBCC )

{
  SetProc( VRGeneric_VRGetCode ); Begin

  *msg = MSSUCC;

  strcpy ( szAABBCC, me->szAABBCC );

  /*" Component aabbcc code = %s\n",me->szAABBCC*/

  End
  return ( OM_S_SUCCESS );

}/* end VRGetCode */

/***********************************************************************/

method VRGetStatus ( IGRlong *msg; IGRshort *StatusValue)

{

  SetProc( VRGeneric_VRGetStatus ); Begin
  *msg = MSSUCC;

  /*" Status = %d\n",me->Status*/

  *StatusValue = me->Status;

  End
  return ( OM_S_SUCCESS );

}/* end VRGetStatus */

/***********************************************************************/

method VRGetModel ( IGRlong *msg; struct GRid *ModelId;
      struct GRmd_env *md_env )

{

  IGRint      status;
  IGRshort    nSysType;
  IGRlong     retmsg;
  IGRint      NbParams;
  IGRint      EndLoop=0;
  IGRchar     szPathName[100];
  IGRchar     szSearch[VR_SEARCH_LENGTH];
  IGRint      FootIndex=-1;
  IGRchar     szAABBCC[VR_CODE_LENGTH];

  struct  VRSelectAttr  ParamList[VRMAXCRIT];
  struct ret_struct     AttrRst;
  struct  GRid          PbId;
  
  extern IGRboolean IGEstop();

/*  SetProc( VRGeneric_VRGetModel ); Begin   */

  ModelId->objid = NULL_OBJID;

  /* --------------------------------------
   * TR179801102 For some bad components, getting garbage in error
   * messages, inited these variables solved one of the problems
   * Real problem solved in VRGetSearch
   */
  *szSearch = 0;
  *szPathName = 0;
  *szAABBCC = 0;
  
  status = om$send
  ( msg      = message VRGeneric.VRGetCode(msg,szAABBCC),
    targetid = my_id);
  as$status ( action = RET_STATUS );

/*  __DBGpr_str( " Component's Code ", szAABBCC ); */

  /*Check added by alwin - to prevent CRASH. B'cas sometimes it goes into the
  while loop and it'll never come out of it and as a result it ends up in CRASH.
  Added for TR179702601 */

  status =
  om$send ( msg = message VRGeneric.VRGetSysType ( msg, &nSysType ),
       targetid = my_id);
  as$status ( action = RET_STATUS );
 
  if( ( szAABBCC[0] == '\0' ) && ( nSysType != VR_NOZZLE ) )
  {
#ifdef vdsDEBUG
        printf(" -----> Component : NOT found in database\n" );
#endif
/*	End */
	return ( status );
  }

  while( EndLoop==0 )
  {
    /*| LOOP */
    EndLoop = IGEstop();

    if ( me->Status & VR_BUILT_IN )
    {
      /*| AABBCC taken as search string */
      sprintf ( szSearch,"%s:%s", VR_MISC_DIR, szAABBCC );
    }
    else
    {
      /*| -- build search string -- */
      status = 
      om$send ( msg = message VRProduct.VRGetSearch
                                ( msg, ModelId, 0, &NbParams, 
                                  ParamList, szSearch, md_env ),
           targetid = my_id);
      as$status ( action = RET_STATUS );

/*      __DBGpr_str( " Search String ", szSearch );  */

      if ( *msg != MSSUCC || !( status & OM_S_SUCCESS ))
      {
/*	End  */
        return ( status );
      }
    }

    /*| -- LOOK FOR PB ID IN DIRECTORIES --- */
    /*| -- build full pathname -- */
    di$give_pathname ( osnum = OM_Gw_current_OS, pathname = szPathName );

    strcat ( szPathName, ":" );
    strcat ( szPathName, szSearch );

    PbId.objid = ModelId->objid;
    PbId.osnum = ModelId->osnum;
    /*" Model Pathname = %s\n",szPathName */
    /*| -- look for the model in the directory -- */
    if ( ! ( di$translate ( objname = szPathName,
                            p_objid = &PbId.objid,
                            p_osnum = &PbId.osnum )& 1 ) )
    {
      /*| -- if model has not been already loaded -- */
      /*| CREATE MODEL */
      /* -- Get component info from specs -- */
      status = 
      om$send ( msg = message VRProduct.VRGetSpecComp
                                     ( msg, NbParams, ParamList,
                                       ModelId, md_env ),
           targetid = my_id);

      if ( *msg != MSSUCC || !( status & 1 ))
      {
        /*| ERROR -> SPEC ACCESS FAILED */
        printf(" -----> Component : %s NOT found in database\n",szSearch);
/*	End  */
        return ( status );
      }

      /*| --- Put the return Pb Id in directories --- */    
      status=
      om$send(msg = message ACncpx.GRputname( msg, szPathName),
         targetid = ModelId->objid ,
         targetos = ModelId->osnum );
      as$status ();
    }
    else
    {
      /*| --- Model already exist --- */
      ModelId->objid = PbId.objid;
      ModelId->osnum = PbId.osnum;
    }

/*    __DBGpr_obj( " Model Id ", *ModelId ); */

    /* ----- if macro name or catalog occurrence are found stop
       else continue if catalog name is still defined --- */


    /*| --- if not catalog name cannot go further --- */
    status = 
    om$send ( msg = message ACncpx.ACgive_structure
                            ( (IGRint *)&retmsg, &FootIndex, 
                               VR_N_CATAL_NAME_AN, &AttrRst, md_env ),
         targetid = ModelId->objid,
         targetos = ModelId->osnum);
    as$status ( action = RET_STATUS );

    if( !(retmsg & MSSUCC) )  break;

    /* --- else if macro name component is defined  --- */
    status = 
    om$send ( msg = message ACncpx.ACgive_structure
                            ( (IGRint *)&retmsg, &FootIndex, 
                               VR_N_MACRO_NAME_AN, &AttrRst, md_env ),
         targetid = ModelId->objid,
         targetos = ModelId->osnum);
     as$status ( action = RET_STATUS );

    if( retmsg & MSSUCC )  break;

    /* --- else if catalog name + occurrence component is defined  --- */
    status = 
    om$send ( msg = message ACncpx.ACgive_structure
                            ( (IGRint *)&retmsg, &FootIndex, 
                               VR_N_CATAL_OCC_AN, &AttrRst, md_env ),
         targetid = ModelId->objid,
         targetos = ModelId->osnum);
    as$status ( action = RET_STATUS );

    if( retmsg & MSSUCC )  break;
  }

/*  End  */
  return ( OM_S_SUCCESS );
}/* end VRGetModel */


/***********************************************************************/

method VRGetMacro (   IGRlong       *msg;
                      IGRchar       *szMacroName;
                      IGRchar       *cRep;
                      IGRshort      *nMacroType;
               struct GRid          *StaticId ;
                      IGRint        *NbMissing;
                      IGRchar     ***MissingNames;
               struct ret_struct   **MissingStr;
               struct GRmd_env      *md_env )

{
  IGRshort    nType, Product;
  IGRint      status;
  IGRint      NeedRep=0,NbTemp;
  IGRint      Index=-1;
  IGRchar    *pMacName;
  IGRchar     pc3Product[50], szTmpName[80];

  struct ret_struct  AttrSt;
  struct GRid        TempList[2], *pDB, TmpDB;

  SetProc( VRGeneric_VRGetMacro ); Begin
  *msg = MSSUCC;
  if ( nMacroType ) *nMacroType = 0;

  /* initialize pointers */
  if ( StaticId ) pDB = StaticId;
  else            pDB = &TmpDB;

  if (szMacroName)pMacName = szMacroName;
  else            pMacName = szTmpName;

  pMacName[0] = 0;

  /* Prepare template list for macro */

  NbTemp = 1;
  
  TempList[0].objid = my_id;
  TempList[0].osnum = OM_Gw_current_OS;

  if ( bVR_IS_PID(me->xform_chan) || nMacroType )
  {
    status = 
    om$send ( msg = message VRGeneric.VRGetSysType ( msg, &nType ),
         targetid = my_id);
    as$status ( action = RET_STATUS );

    if ( nMacroType && nType == VR_PIPE ) *nMacroType = 1;
  }

  if ( bVR_IS_PID(me->xform_chan) )
  {
    IGRchar  szAABBCC[VR_CODE_LENGTH];

    pDB->objid = NULL_OBJID;

    szAABBCC[0] = 0;

    status =
    om$send ( msg = message VRGeneric.VRGetCode(msg,szAABBCC),
              targetid = my_id);
    as$status ( action = RET_STATUS );
  
    status = om$send( msg = message VRProduct.VRGetProduct( &Product,
                       pc3Product ),
                       targetid = my_id );
 
    /* Check whether the Macro Name is available in the DATABASE
       (in "pid_sym_code" table). This check is very much necessary because 
       for component like ANGV (angle valve), VRGetSysType returns the 
       VR_ELBOW. Which is wrong. From the SysType it fetches a wrong macro,
       during the update of the syatem. This way we prevent the system from 
       picking the wrong macro name. Alwin for TR179701019 */
    if ( szAABBCC[0] && *msg == MSSUCC && Product == VR_PIPING )
    {
      status =
      VRdbGetPidSym ( msg, (IGRshort)VR_PIPING, 0,
                      szAABBCC, pMacName, (IGRchar *) NULL );
      as$status ( action = RET_STATUS );
 
      if( (*msg == MSSUCC) && pMacName[0] ) goto skip;
    }

    switch ( nType )
    {
      case VR_PID_CROSS :
        me->Status |= VR_PID_ONLY;
        /* Symbol is defined in the aabbcc code */
        strcpy ( pMacName, me->szAABBCC );
        break;

      case VR_DANGLING :
        strcpy ( pMacName, VRPID_N_DANG_MACRO );
        break;

      case VR_PIPE :
        if ( Product == VR_PIPING )
             strcpy ( pMacName, VRPID_N_PIPE_MACRO );
        else
             strcpy ( pMacName, VRPID_N_DUCT_MACRO );

        break;

      case VR_REDUCER :
        strcpy ( pMacName, VRPID_N_REDUCER_MACRO );
        break;

      case VR_ELBOW :
        strcpy ( pMacName, VRPID_N_ELBOW_MACRO );
        break;

      case VR_NOZZLE :
        strcpy ( pMacName, VRPID_N_NOZZ_MACRO );
        
      case VR_EQUIPMENT :

        status =
        om$send ( msg = message NDmacro.ACgive_structure 
                                    ( (IGRint *) msg, &Index,
                                      VR_N_MACRO_NAME_AN, &AttrSt, md_env ),
             targetid = my_id);

        if ( status & OM_S_SUCCESS )
        {
          strcpy ( pMacName, AttrSt.var.text_st.text_string );
        }

        /* -- If name has been found -- */
        if ( pMacName[0] ) break;

      default :
        /* Manage manual or DB driven components */
        status =
        om$send ( msg = message VRGeneric.VRGetCode(msg,szAABBCC),
             targetid = my_id);
        as$status ( action = RET_STATUS );

        if ( szAABBCC[0] && *msg == MSSUCC)
        {
          status =
          VRdbGetPidSym ( msg, (IGRshort)VR_PIPING, 0,
                          szAABBCC, pMacName, (IGRchar *) NULL );
          as$status ( action = RET_STATUS );
        }
        else
        {
          End
          return OM_E_ABORT;
        }
        break;

    }/*|end switch */
  }
  else
  {
    /* --------------------------------------- */
    /* -- Get component's static attributes -- */
    /* --------------------------------------- */

    __DBGpr_com( "Calling VRGetModel ... " );
    status = 
    om$send ( msg = message VRGeneric.VRGetModel ( msg, pDB, md_env ),
         targetid = my_id);

    if ( (*msg != MSSUCC) || !(status & OM_S_SUCCESS) )
    {
      __DBGpr_com("Failed to obtain DB info " );
      End
      return status ;
    }

    /* -------------------- */
    /* -- Build Graphics -- */
    /* -------------------- */

    /*| Get macro name from DBParams */

    status = 
    om$send ( msg = message NDmacro.ACgive_structure 
                             ( (IGRint *) msg, &Index,
                              VR_N_MACRO_NAME_AN, &AttrSt, md_env ),
         targetid = pDB->objid,
         targetos = pDB->osnum );

    if ( !(status & OM_S_SUCCESS & (*msg)) )
    {
      /* try to find macro name in the active collections */
      status = 
      om$send ( msg = message NDmacro.ACgive_structure 
                               ( (IGRint *) msg, &Index,
                                VR_N_MACRO_NAME_AN, &AttrSt, md_env ),
           targetid = my_id);

    }/* end try to get macro name from the active collections */

    if ( (status & OM_S_SUCCESS & (*msg)) )
    {
      strcpy ( pMacName, AttrSt.var.text_st.text_string );
      __DBGpr_str( "Macro found : ", pMacName  );
    }

    if ( pDB->objid != NULL_OBJID )
    {
      TempList[NbTemp] = *pDB;
      NbTemp += 1;
    }

  }/* end get macro from database */

  if ( !pMacName[0] )
  {
    printf (" -----> No macro name for <%s>\n", me->szAABBCC );
    *msg = MSFAIL;
    End
    return OM_E_ABORT;
  }

skip:

  /*| Test existance of all needed attributes */
  if (NbMissing)
  {
    status =
    VRtest_macro (pMacName, NbTemp,TempList, 
                  NbMissing, MissingNames, MissingStr,md_env);
    if ( !(status & OM_S_SUCCESS) )
    {
      printf(" -----> Macro : %s not found\n", pMacName);
      End
      return OM_E_ABORT;
    }

    if (*NbMissing)
    {
      /*| There are missing parameters. Cannot go further */
      *msg = MSFAIL;
      End
      return OM_S_SUCCESS;
    }

  }/* end test for attributes existance */

  /*| Edit macro definition */

  status =
  VRedit_macro( pMacName, NbTemp, TempList, &NeedRep, md_env);
  if ( !(status & OM_S_SUCCESS) )
  {
    printf(" -----> Macro : %s cannot be placed\n", pMacName);
    /*| ERROR -> NO GRAPHIC BUILT */
    End
    return OM_E_ABORT;
  }

  /*"Need Representation flag = %d\n", NeedRep */

  if ( cRep )
  {
    if ( NeedRep )
        /* Indicates the rep template exists */
        *cRep = me->xform_chan | AC_FREE_REP;
    else
        *cRep = me->xform_chan ;
  }

  End
  return ( OM_S_SUCCESS );

}/* end VRGetMacro */

/**************************************************************************/

method VRGetInstance  (IGRlong       *msg;
                struct VRGenInfo     *Instance)

{
  SetProc( VRGeneric_VRGetInstance ); Begin
  *msg = MSSUCC;

  Instance->nStatus   = me->Status;
  Instance->nOption   = me->nOption;
  Instance->cNoMtoFlg = me->cNoMtoFlg;
  Instance->cRep      = me->xform_chan;
  Instance->nNbTopo   = me->nNbTopo;
  Instance->nNbAttr   = me->nNbAttr;
  Instance->nJustif   = me->nJustif;

  strcpy ( Instance->szAABBCC, me->szAABBCC );
  strcpy ( Instance->szNumber, me->szNumber);
  strcpy ( Instance->szNotes,  me->szNotes);

  End
  return ( OM_S_SUCCESS );

}/* end VRGetInstance */

/***********************************************************************/

method VRGetCompDesc ( IGRlong    *msg;
                struct ACrg_coll  *Param;
                struct GRmd_env   *md_env )
{
  IGRint       status;
  IGRlong      retmsg;
  struct GRid  DBParamId;

  SetProc( VRGeneric_VRGetCompDesc ); Begin
  *msg = MSSUCC;

  if ( bVR_IS_PID(me->xform_chan) )
  {

    if ( !strcmp ( Param->name, VR_N_COMP_TOPO_IN ) )
    {
      /*| -- return error component topology -- */
      Param->desc.type = AC_ATTRIB_DOUBLE;
      switch ( me->nNbCpts )
      {
        case 1 :
          Param->desc.value.att_exp =
          VRP_V_CLOSURE_TOPO;
          break;

        case 2 :
          Param->desc.value.att_exp =
          VRP_V_2_WAYS_TOPO;
          break;

        case 3 :
          Param->desc.value.att_exp =
          VRP_V_3_WAYS_TOPO;
          break;

        default :
          Param->desc.value.att_exp =
          VRP_V_UNDEFINED_TOPO;
          break;
      }
      End
      return OM_S_SUCCESS;
    }
    else if ( !strcmp ( Param->name, VR_N_COMP_TYPE_IN ) )
    {
      /*| -- return error component type -- */
      Param->desc.type = AC_ATTRIB_DOUBLE;
      Param->desc.value.att_exp = VR_V_ERROR_TYPE;
      End
      return OM_S_SUCCESS;
    }
/*
    else
    {
      Param->desc.type = AC_ATTRIB_DOUBLE;
      Param->desc.value.att_exp = -99;
      status = OM_E_INVARG;
    }
    End
    return OM_S_SUCCESS;
*/
  }/* end PID */

  /* -- Get DB param object id -- */
  status = 
  om$send ( msg = message VRGeneric.VRGetModel ( &retmsg, &DBParamId, md_env ),
       targetid = my_id);

  if ( !(status & OM_S_SUCCESS) || (retmsg != MSSUCC) )
  {
    /*| No Model --> ERROR COMPONENT */
    status = OM_S_SUCCESS;

    if ( !strcmp ( Param->name, VR_N_COMP_TOPO_IN ) )
    {
      /*| -- return error component topology -- */
      Param->desc.type = AC_ATTRIB_DOUBLE;
      Param->desc.value.att_exp = VRP_V_UNDEFINED_TOPO;
    }
    else if ( !strcmp ( Param->name, VR_N_COMP_TYPE_IN ) )
    {
      /*| -- return error component type -- */
      Param->desc.type = AC_ATTRIB_DOUBLE;
      Param->desc.value.att_exp = VR_V_ERROR_TYPE;
    }
    else
    {
      /*| -- return UNKNOWN value -- */
      *msg = MSFAIL;
      Param->desc.type = AC_ATTRIB_DOUBLE;
      Param->desc.value.att_exp = -99;
      status = OM_E_INVARG;
    }
  }/* end error component treatment */
  else
  {
    /* -- Forward message to DB param object -- */
    status = 
    om$send ( msg = message ACrg_collect.ACget_named_attribute 
            ( msg, Param ),
      targetid = DBParamId.objid,
      targetos = DBParamId.osnum );

  }/* end generic treatment */

  End
  return status;
}/* end VRGetCompDesc */

/***********************************************************************/

/*------------------------
# This method in fact gets the flow from the owner correction.
------------------------*/

method VRGetFlow (   IGRlong   *msg;
                     IGRshort   nCpNum;
                     IGRshort  *nFlowDir ;
                     IGRdouble *dFlowRate;
            struct   GRmd_env  *md_env )
{
  BSrc			rc={1};
  IGRint       		status;
  IGRlong      		retmsg;
  IGRint       		NbCors;
  IGRshort		Direction={1}; 
  IGRdouble		MyCptCoord[3], Cpt0[3], Cpt1[3], V0[3], V1[3], V2[3];

  struct ACrg_coll      Attrlst; /* TR179603574 */
  struct GRid  		CorId;
  struct GRid  		SParam; /*TR179603574 */
  struct VRCorrection_common attr;

  IGRdouble    BSlenvec();

SetProc( VRGeneric.VRGetFlow); Begin 
  *msg=MSSUCC;

  if ( !nFlowDir && !dFlowRate ) goto wrapup; 

  if ( nFlowDir )   *nFlowDir = VR_FLOW_UNKNOWN;

  /* TR179603574 - 0 flowrate causes failure with fitting to fitting */
  if ( dFlowRate )  {
	 *dFlowRate = 0.0;

    status =
    om$send (msg = message VRGeneric.VRGetParams
                                       (&retmsg, &SParam, NULL, NULL),
                          targetid = my_id);

         strcpy (Attrlst.name, VR_N_FLOW_RATE_DB),
         Attrlst.desc.type = AC_ATTRIB_DOUBLE;



         status = om$send( msg     = message ACrg_collect.ACget_named_attribute
                                           ( &retmsg, &Attrlst ),
                          targetid = SParam.objid,
                          targetos = SParam.osnum);
         as$status();

         if ( status & 1) *dFlowRate = Attrlst.desc.value.att_exp;
  }


__DBGpr_int("VRGetFlow for       ", (int) my_id); 

  /* -- Check if this component is owned by a correction -- */
  /* The correction treatment is exactly the same as in VRmod.I: VRSetFlow   */

  if ( me->Status & VR_CORRECTION )
  {
    status =
    om$send ( msg = message VRGeneric.VRGetCorrections
                                       (&retmsg, 1, &CorId, &NbCors),
         targetid = my_id);
    as$status ( action = RET_STATUS );

  }
  else
  {
    /* -- Get correction on connect point -- */
    /*KLUDGE FOR OLETS : Got thru GetNeighbors to get correction on cpt 0 */
    IGRshort     nStatus;
    IGRint       TmpNbNei;
    struct GRid  TmpNeiId;

    status=
    om$send ( msg = message VRGeneric.VRGetNeighbors
                                     ( &retmsg, nCpNum, nCpNum, &TmpNbNei,
                                        &TmpNeiId, NULL, md_env),
         targetid = my_id);
    as$status ( action = RET_STATUS );
    if (TmpNeiId.objid == NULL_OBJID) {
       *msg = MSFAIL;
       End
       return OM_S_SUCCESS;}

    status =
    om$send ( msg = message VRGeneric.VRGetStatus (&retmsg, &nStatus),
         targetid = TmpNeiId.objid,
         targetos = TmpNeiId.osnum );
    as$status ( action = RET_STATUS );

    if ( nStatus & VR_CORRECTION )
    {
      status =
      om$send ( msg = message VRGeneric.VRGetCorrections
                                        (&retmsg, 1, &CorId, &NbCors),
           targetid = TmpNeiId.objid,
           targetos = TmpNeiId.osnum );
      as$status ( action = RET_STATUS );
    }
    else
    {
      status =
      om$send ( msg = message VRGeneric.VRGetCorOnCpt
                                        (&retmsg, nCpNum, &CorId, md_env),
           targetid = my_id);
      as$status ( action = RET_STATUS );
    }
  }/* end not correction component treatment */

__DBGpr_obj("Using VRCorrection  ", CorId);

/*-------------------
#  Get Flow Direction from correction.
-------------------*/
  if ( nFlowDir ) { 

     status= om$send (msg = message VRGeneric.VRGetCptGeom 
				(&retmsg, nCpNum, MyCptCoord, NULL,NULL,md_env),
                 targetid = my_id);

     status= om$send (msg = message VRGeneric.VRGetCptGeom 
				(&retmsg, (IGRshort) 0, Cpt0, NULL,NULL,md_env),
                 targetid = CorId.objid,
                 targetos = CorId.osnum );

     status= om$send (msg = message VRGeneric.VRGetCptGeom 
				(&retmsg, (IGRshort) 1, Cpt1, NULL,NULL,md_env),
                 targetid = CorId.objid,
                 targetos = CorId.osnum );

     /* reverse flow direction if needed */

     BSmkvec ( &rc, V0, MyCptCoord, Cpt0);

     if (BSlenvec (&rc, V0) < VRGetTol(VR_LENGTH_TOL) )     { Direction = 1; } 
     else {
	BSmkvec ( &rc, V2, MyCptCoord, Cpt1); 
        if (BSlenvec (&rc, V2) < VRGetTol(VR_LENGTH_TOL) ) { Direction = -1; }
        else { 
            BSmkvec ( &rc, V1, Cpt0, Cpt1);
	    if (BSdotp(   &rc, V0, V1 ) < 0 )  { Direction = -1; }
        }
     }

     attr.Iwant = VRCorrection_FlowDirection;
 
     status = om$send ( msg = message VRCorrection.GRgetattr
                                      (&retmsg, (IGRchar *) &attr),
                   targetid = CorId.objid,
                   targetos = CorId.osnum );
 
     *nFlowDir = (IGRshort) attr.FlowDirection * Direction ;

__DBGpr_int("Flow Direction      ", (int) *nFlowDir);
  }



/*-------------------
#  Get Flow rate form correction 
-------------------*/
  if ( dFlowRate ) { 
     attr.Iwant = VRCorrection_FlowValue;
 
     status = om$send ( msg = message VRCorrection.GRgetattr
                                      (&retmsg, (IGRchar *) &attr),
                   targetid = CorId.objid,
                   targetos = CorId.osnum );

     *dFlowRate = attr.FlowValue; 

__DBGpr_dbl("Flow Rate           ", (double) *dFlowRate);
  } 

  goto wrapup; 


wrapup:

End
  return OM_S_SUCCESS;

}/* end VRGetFlow */

/***********************************************************************/

method VRGetOrientationDef (IGRlong     *msg ;
                     struct GRid        *PrimaryId;
                            IGRshort    *nPosOnPri;
                            IGRdouble   *dPrimary;
                     struct GRid        *SecondaryId;
                            IGRshort    *nPosOnSec;
                            IGRdouble   *dSecondary)
{

  SetProc( VRGeneric_VRGetOrientationDef ); Begin
  *msg = MSSUCC;

  if (PrimaryId)   PrimaryId->objid = NULL_OBJID;

  if (nPosOnPri)  *nPosOnPri = -1;

  if (dPrimary)   *dPrimary = 1.0;

  if (SecondaryId) SecondaryId->objid = NULL_OBJID;

  if (nPosOnSec)   *nPosOnSec = -1;

  if (dSecondary)  *dSecondary = 1.0;

  End
  return OM_S_SUCCESS;

}/* end VRGetOrientationDef */

/***********************************************************************/

method VRIsGeometricAttr ( IGRlong    *msg;
                           IGRint      NbAttr;
                           IGRchar    *AttrNames[]; 
                           IGRboolean *bIsGeometric;
                    struct GRmd_env   *md_env )

{
  register
  IGRint     i,j;
  IGRlong    retmsg;
  IGRint     status, NbGeomAttr;
  IGRchar   *GeomAttr[100];
  IGRchar    szMacroName[80];

  SetProc( VRGeneric_VRIsGeometricAttr ); Begin
  *msg = MSSUCC;
  *bIsGeometric = FALSE;

  /* -- Get names of attributes template of my graphics -- */
  /* get macro name */

  status = 
  om$send ( msg = message VRGeneric.VRGetMacro
                                  ( &retmsg, szMacroName,
                                  NULL, NULL, NULL, NULL, NULL, NULL, md_env ),
    targetid = my_id);

  if( ! ( status & OM_S_SUCCESS ) ) 
  {
    /* ADDED BY MOMO : 10-09-1992 */
    *bIsGeometric = TRUE;
    End
    return OM_S_SUCCESS;
  }

  /*" Macro name : %s\n",szMacroName */
  status = VRGetTempNames( szMacroName, &NbGeomAttr, GeomAttr);

  /* -- add the names of the attributes used in the search criteria -- */
  /* KLUDGE : the names of the attributes used in the search criteria
  is hardcoded */

  GeomAttr[NbGeomAttr++] = VR_N_COMP_CODE_AN;  /* Component code */
  GeomAttr[NbGeomAttr++] = VR_N_SHAPE_IN;      /* shape ( HVAC ) */
  GeomAttr[NbGeomAttr++] = VR_N_OPTION_IN;     /* Option( Piping ) */
  GeomAttr[NbGeomAttr++] = VR_N_CLASS_AN;      /* Class name ( Piping ) */
  GeomAttr[NbGeomAttr++] = VR_N_PID_SCALE_DB;  /* Pid scale factor */

#ifdef MY_DEBUG
  for (i=0; i<NbGeomAttr; i++ )
     printf ("\t\t Attr[%d] = %s\n",i,GeomAttr[i]);
#endif

  /* -- loop on attributes names and exit if one of them is either
        used as template of the graphics or used in the search criteria -- */

  for (i=0; ( (i<NbAttr) && !(*bIsGeometric) ); i++ )
  {
    /* check attribute in specified list against all geometric attributes */
    for (j=0; ( (j<NbGeomAttr) && !(*bIsGeometric) ); j++ )
      if ( !strcmp(AttrNames[i], GeomAttr[j]) ) *bIsGeometric = TRUE;

  }

  End
  return OM_S_SUCCESS;

}/* end VRIsGeometricAttr */

/***********************************************************************/

method VRGetMatrix (IGRlong   *msg;
                    IGRint     NbTemp;
             struct GRid      *TempList;
                    IGRdouble *dRefMatrix;
             struct GRmd_env  *md_env)

{
  IGRint     i, status;
  IGRshort   nTmpType;
  IGRdouble  dVecteurO[3];   
  BSrc       rc;

  SetProc( VRGeneric_VRGetMatrix ); Begin
  *msg = MSSUCC;

  status =
  om$send ( msg = message GRowner.GRget_matrix ( msg,
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                                    &nTmpType, dRefMatrix ),
  p_chanselect  = &AS_to_comp,
        from    = 0, 
          to    = 0  );
  if ( !(status & OM_S_SUCCESS) )
  {
      End
      return OM_W_ABORT;
  }

  /* -- Norme matrix -- */

  for (i=0; i<3; i++)
  {
    dVecteurO[0] = dRefMatrix[i];
    dVecteurO[1] = dRefMatrix[i+4];
    dVecteurO[2] = dRefMatrix[i+8];
    BSnorvec (&rc, dVecteurO);
    dRefMatrix[i]   = dVecteurO[0];
    dRefMatrix[i+4] = dVecteurO[1];
    dRefMatrix[i+8] = dVecteurO[2];
  }

  End
  return ( OM_S_SUCCESS );

}/* end VRGetMatrix */

method  VRGetCatBehavior(IGRlong   *msg ;      /* I/O - return status     */
                         IGRint    *Category;  /* O   - Category of the Cmp  */
                         IGRint    *Behavior)  /* O   - Behavior of the Cmp  */
{
  SetProc( VRGeneric_VRGetCatBehavior ); Begin
  *msg = MSSUCC;

  /*A default implementation ( no category and no id management) */
  
  if ( Category )  *Category = -1;
  if ( Behavior )  *Behavior = 0;

  End
  return  OM_S_SUCCESS;
  
}/* end VRGetCatBehavior */

end implementation VRGeneric;
