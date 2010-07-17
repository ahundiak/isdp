/* $Id: VRCOProduc2i.I,v 1.3 2001/02/20 01:12:16 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrco / VRCOProduc2i.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRCOProduc2i.I,v $
 *  Revision 1.3  2001/02/20 01:12:16  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.2  2001/02/09 17:12:11  anand
 *  Problems with placement/replacement of CCOMPs.
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:42  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1997/12/16  05:38:18  pinnacle
# Replaced: vrco/VRCOProduc2i.I for:  by apazhani for route
#
# Revision 1.2  1997/12/08  14:25:00  pinnacle
# Replaced: vrco/VRCOProduc2i.I for:  by apazhani for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/04/03  18:15:42  pinnacle
# Replaced: vrco/VRCOProduc2i.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/05/09  14:05:52  pinnacle
# Replaced: vrco/VRCOProduc2i.I for:  by ashankar for route240
#
# Revision 1.3  1996/03/19  22:10:42  pinnacle
# Replaced: vrco/VRCOProduc2i.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/16  21:27:18  pinnacle
# Replaced: vrco/VRCOProduc2i.I for:  by r240_int for route240
#
 *
 * History:
 *  01/15/96  tlb    Add VX_FIproto.h, prototypes
 *  12/08/97  Alwin  Added Method VREvalCorComp. To modify the Correction 
 *                   Components as per the input specified by the user.
 *  12/16/97  Alwin  Modified the method VRUpdateForm, to display the
 *                   bend_sweep of the old_component. for CR179424244
 * Feb 9 2001 Anand  JTS TR MP 3367 - Fix problems with replacement of CCOMPs!
 *
 *************************************************************************/
class implementation VRCOProduct;

#include "dpmacros.h"
#include "VRchgattrdef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRsketchdef.h"
#include "VRMcForm.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VRcsdef.h"
#include "VRmacros.h"
#include "VRDbStruct.h"
#include "VRPid.h"
#include "bsvalues.h"
#include "VRcordef.h"
#include "acrepdef.h"
#include "vrco_pto.h"
#include "vrtools_pto.h"
#include "VRprivmacros.h"
#include "VDmem.h"
#include "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
#include <math.h>
%endsafe

/*
#define MY_DEBUG  
*/

from  GRgraphics import  GRdelete;
from  GRgraphics import  GRdisplay;
from  GRvg       import  GRputsymb;
from  VRGeneric  import  VRGetSupOnCpt;
from  VRGeneric  import  VRGetPlanesOnCpt;
from  VRGeneric  import  VRGetCptGeom;
from  VRGeneric  import  VRGetOrigCoor;
from  VRGeneric  import  VRGetSupports;
from  VRGeneric  import  VRGetParams;
from  VRGeneric  import  VRChgParams;
from  VRGeneric  import  VRGetInstance; 
from  VRGeneric  import  VRSetInstance, ACgive_structure;
from  VRGeneric  import  VRGetCorrections, VRGetStatus;
from  ACncpx     import  ACput_NV_rep;
from  NDnode     import  NDdisplay;
from  VRProduct  import  VRGetSearch;
from  VRCorrection  import  VRChgCorCmpAttrs, VRGetProductName;
  
/* ==================================================================== */

method VRRetrieveLocatedContext (IGRlong *ret)
{
  IGRlong          msg;
  IGRlong          status;
  enum   GRdpmode  Mode;

  *ret = MSSUCC;

  /* Erase last event in case of backup command */
  VRUpdateEvent(  &msg , me->dSplitPoint , &me->event1 );

  VRCircularTreatment (me->Product, &me->SysParamId, &me->ModuleEnv);

#ifdef MY_DEBUG
  printf ("(Sys,User) -> (FormSys,FormUser) : (%d,%d) -> (%d,%d)\n",
          me->SysParamId.objid, me->UsrParamId.objid,
          me->SysParamId.objid, me->UsrParamId.objid);
#endif

  VRGetParamBoxClone( &msg, &me->SavSysParamId, &me->SysParamId);
  VRGetParamBoxClone( &msg, &me->SavUserParamId, &me->UsrParamId);

  if( me->SavMissParamId.objid != NULL_OBJID )
    VRGetParamBoxClone( &msg, &me->SavMissParamId, &me->MissParamId);
  else
  {
    status =
    om$send( msg = message GRgraphics.GRdelete(  &msg, &me->ModuleEnv),
        senderid = my_id,
        targetid = me->MissParamId.objid,
        targetos = me->MissParamId.osnum);

    me->MissParamId.objid = NULL_OBJID;
  }

  /*| Restore Form saved before BACK_UP in ST_FORM or ST_AABBCC !!! */
  status = 
  om$send ( msg = message VRCOProduct.VRRestoreForm (&msg),
       targetid = my_id);
  as$status ();

  if (( me->mytype == VR_PIPEENDS_INSERTION ||
        me->mytype == VR_HVACENDS_INSERTION ||
        me->mytype == VR_HVACTERMDEV_INSERTION) && me->nSysType == VR_DANGLING)
  {
    /* Keep active symb and representation of located dangling */
    /*| PutSymb */
    status =
    om$send( msg = message GRvg.GRputsymb (&msg, &me->Symb),
        targetid = me->CompId.objid,
        targetos = me->CompId.osnum );
    as$status( );

    /*| Set Representation of located component */
    status =
    om$send( msg = message ACncpx.ACput_NV_rep (me->cRep),
        targetid = me->CompId.objid,
        targetos = me->CompId.osnum);
    as$status();
  }

  if( me->CmpId.objid != NULL_OBJID )
  {
    /*| ----- UnDisplay Old dangling ----- */
    Mode = GRbe;
    status =
    om$send( msg = message GRgraphics.GRdisplay
                                    ( &msg, &me->ModuleEnv.md_env.matrix_type,
                                      me->ModuleEnv.md_env.matrix, &Mode, 
                                      &me->ModuleEnv.md_id ),
        targetid = me->CmpId.objid, 
        targetos = me->CmpId.osnum );
  }

  return OM_S_SUCCESS;

} /* end method VRRetrieveLocatedContext */

/* ==================== VRIsReducerRequired =============================*/

method  VRIsReducerRequired ( IGRlong *ret )
{
  IGRlong    msg, status;

  /*"ParamBox = (%d,%d)\n",me->SysParamId.osnum, me->SysParamId.objid */

  *ret = VRREDUCER;

  if (me->Flags & SPLITFLAG)
  {
    *ret = VRREDUCER;
    return OM_S_SUCCESS;
  }

  if (!(me->Flags & REDUCERFLAG))
  {
    *ret = MSSUCC;
    if ( !bVR_IS_PID( me->cRep) &&
         VRCheckReducingConsistency (me->Product, &me->SysParamId,
                                                     &me->ModuleEnv))
    {
/*     seen that we do not need this local garbage (see below)
      union    VRparam_attr  ParamAttr;
*/

      status =
      om$send( msg = message VRCOProduct.VRForceDiamValues(&msg),
          targetid = my_id );
      as$status(); 

/*    Now this is a beauty, we modify a parameterbox with values
      contained in an uninitialized union/structure

      @@@@@ revisit later to see what the hell the original
            writer intended here................................

      status = VRModifyParameterBox(  &msg, me->Product, &ParamAttr, 
                                      &me->SysParamId, &me->SysParamId);
*/
      as$status();
    }

    return OM_S_SUCCESS;
  }

  if ( !VRCheckReducingConsistency (me->Product,  &me->SysParamId ,
                                                  &me->ModuleEnv ))
  {
      /*| We need another diameter value */
      *ret = VRREDUCER;
  }
  else
  {
      /*| We DON'T need another diameter value */
      *ret = MSSUCC;
  }

  return  OM_S_SUCCESS;

} /* end method VRIsReducerRequired */

/* ==================================================================== */

method VRChangeActivePocketMenu  (IGRlong *ret)
{
  *ret = MSSUCC;

  if (strcmp (NOTDEFPKTMNU, me->szActivePocketMenuName ))
  {
      VRChangePocketMenu (me->szActivePocketMenuName);
      /*"me->szActivePocketMenuName = %s \n",me->szActivePocketMenuName*/

      me->bPktInquired = TRUE;
      /*"bPktInquired is <%d>\n", me->bPktInquired */
  }
  else
  {
    /*| Pocket menu doesn't exist -> no change */
  }

  return OM_S_SUCCESS;

} /* end method VRChangeActivePocketMenu */

/* ====================================================================  */

method VRGetCompMatrix (IGRlong *ret)
{
  IGRlong      retcode, status;
  SetProc(VRCOProduct.VRGetCompMatrix); Begin

  *ret = VRALL_OK;

  if( me->CompId.objid == NULL_OBJID )  *ret = VRNOT_OK;

  /*"Get matrix from the located component ( %d )\n", me->CompId.objid */
  if ( me->nSysType == VR_DANGLING || me->ReplaceCommand )
  {
      __DBGpr_obj(" Get matrix from the located component",me->CompId);
      
    /*| -- Take matrix from the located component that will be replaced -- */
    status = VR$GetMatrix ( p_msg          = &retcode,
                            p_ComponentId  = &me->CompId,
                            p_Matrix       = me->CmpMatrix,
                            p_MdEnv        = &me->ModuleEnv);
    __DBGpr_mat("Component's matrix",me->CmpMatrix);

    /* Below lines added by Anand for JTS TR MP 3367 */
      if( me->CmpType == VR_CONSTR_COMPONENT_TYPE )
      {
	  IGRmatrix	Cpt0Matrix;

	  status = VR$GetMatrix ( p_msg          = &retcode,
				  p_ComponentId  = &me->CompId,
				  CompCpt        = 0,
				  p_Matrix       = Cpt0Matrix,
				  p_MdEnv        = &me->ModuleEnv);
	  __DBGpr_mat("Component's cpt 0 matrix",Cpt0Matrix);

	  /* This is the kludge that has arisen out of macros for constrained
	   * components whose cpt0 and ref do not coincide. For such macros,
	   * you want the matrix of the original component - which has the
	   * orientations of its ref and the coordinates of its Cpt0.  */
	  me->CmpMatrix[3] = Cpt0Matrix[3];
	  me->CmpMatrix[7] = Cpt0Matrix[7];
	  me->CmpMatrix[11]= Cpt0Matrix[11];

	  /* This is necessary to let the system know that cpt 0 of new
	   * component should be located at the cpt 0 of the old component. */
	  me->CptNum = 0;
      }
    /* Above lines added by Anand for JTS TR MP 3367 */

    if( ! ( status & 1 & retcode ) )  *ret = VRNOT_OK;
  }
  else
  {
    if( me->nSysType == VR_PIPE )
    {
      status = VR$GetMatrix ( p_msg         = &retcode,
                              p_SegmentId   = &me->SegId,
                              SegEnd        = 1,
                              p_Matrix      = me->CmpMatrix,
                              p_MdEnv       = &me->ModuleEnv);
    }
    else
    {
      status = VR$GetMatrix ( p_msg          = &retcode,
                              p_ComponentId  = &me->CompId,
                              CompCpt        = me->RetainIndex,
                              p_Matrix       = me->CmpMatrix,
                              p_MdEnv        = &me->ModuleEnv);
    }

    if( ! ( status & 1 & retcode ) )  *ret = VRNOT_OK;

    /* -- Origin = Placement point -- */
    me->CmpMatrix[3]  = me->dSplitPoint[0];
    me->CmpMatrix[7]  = me->dSplitPoint[1];
    me->CmpMatrix[11] = me->dSplitPoint[2];
  }

  /*| ----- Initialize SupOrientation for VRReverse method ----- */
  me->SupOrientation[0] = me->CmpMatrix[0];
  me->SupOrientation[1] = me->CmpMatrix[4];
  me->SupOrientation[2] = me->CmpMatrix[8];
  
  if( me->nSysType != VR_DANGLING )
  {
    me->NbSupports    = 2;
    me->SupOrientation[3] = -me->CmpMatrix[0];
    me->SupOrientation[4] = -me->CmpMatrix[4];
    me->SupOrientation[5] = -me->CmpMatrix[8];
  }
  else
    me->NbSupports    = 1;

  End
  return OM_S_SUCCESS;
}

/* ====================================================================  */

method VRGetReturnCode (IGRlong *ret)
{
  IGRlong      retcode, status;
  IGRint       CompTopo;

  SetProc(VRGetReturnCode); Begin

  me->CptNum = -1;

  if( me->ReplaceCommand )
  {
    status = 
    om$send( msg = message VRCOProduct.VRCheckTopoCoherency( &retcode ),
        targetid = my_id );
    as$status( action = RET_STATUS );

    if( !( retcode & 1 ) )
    {
      ex$message( field = ERROR_FIELD,
                msgnumb = VR_S_InvalidTopo );

      *ret = VRNOT_OK;

      /*| -- Delete Component evaluated -- */
      status = 
      om$send( msg = message GRgraphics.GRdelete( &retcode, &me->ModuleEnv),
          senderid = my_id,
          targetid = me->CmpId.objid,
          targetos = me->CmpId.osnum);
      as$status();

      return OM_S_SUCCESS;
    }
  }

  VRBlankMessage ();

  if( !bVR_IS_PID( me->cRep) )
  {
    CompTopo = VR_INLINE_TOPO;

    if( me->CmpType == VR_CONSTR_COMPONENT_TYPE )
    {
      /*| Constrain component */  
      me->CptNum = VRSkGetJustif( me->Product, &me->SysParamId, &me->ModuleEnv);
    }

    VRCheckCompTopo( &CompTopo, &me->CmpId, &me->ModuleEnv );

    if( CompTopo == VR_CLOSURE_TOPO )   *ret = IS_ENDLINE_COMP;
    if( CompTopo == VR_OLET_TOPO )      *ret = IS_OLET;
    if( CompTopo == VR_ECCENTRIC_TOPO ) me->CptNum = 0;
  }

  /*"ret = %d \n",*ret */
  __DBGpr_int(" instance cpt no",me->CptNum);

  End
  return  OM_S_SUCCESS;

} /* end method VRGetReturnCode */

/* ====================================================================  */
method VRInsertComponent (IGRlong *ret)
{
  IGRlong      msg;
  IGRlong      status;
  IGRint       i, CompTopo;
  IGRshort     nIndex[VR_MAX_CPTS];
  IGRshort     nCptNum[VR_MAX_CPTS];
  IGRdouble    SplitPoint[3];
  IGRboolean   CorType;

  struct GRid            SupId, NewSegId, SegList[2];
  struct tagCompSegDesc  CompSegDesc;
  enum   GRdpmode        Mode;

  *ret  = MSSUCC;

  VRProcessingMessage();

#ifdef MY_DEBUG
  printf ("insert comp\n");
#endif

  status = dp$erase_hilite ( msg = &msg,
                           osnum = me->ModuleEnv.md_id.osnum);

  for( i=0; i<VR_MAX_CPTS; i++ )  nIndex[i] = -1;

  if ( me->nSysType !=  VR_DANGLING )
  {
#ifdef MY_DEBUG
    printf ("not dangling\n");
#endif

    status = 
    om$send( msg = message VRGeneric.VRGetOrigCoor( &msg, SplitPoint, 
                                                    &me->ModuleEnv ),
        senderid = NULL_OBJID,
        targetid = me->CmpId.objid,
        targetos = me->CmpId.osnum);
    as$status();

#ifdef MY_DEBUG
    printf ("SegId = %d \n",me->SegId.objid);
#endif

    if( me->SegId.objid != NULL_OBJID )
    {
      /*| Spliting Segments for inline insertion */
      status = VR$SplitSegment( p_retmsg  = &msg,
                      p_SegmentToSplitId  = &me->SegId,
                            p_SplitPoint  = SplitPoint,
                                 p_MdEnv  = &me->ModuleEnv,
                          p_NewSegmentId  = &NewSegId );
      as$status();

      SegList[0] = me->SegId;
      SegList[1] = NewSegId;
      nIndex[0]  = 1;
      nIndex[1]  = 0;
      nCptNum[0] = nCptNum[1] = me->CptNum;
    }
    else
    {
      IGRdouble    NextPoint[3];
      IGRint      NbSup=0;
      struct  GRid    prev_seg_id, SupIds[VR_MAX_CPTS];
      struct  GRid    CorId;

      status = 
      om$send( msg = message VRGeneric.VRGetOrigCoor( &msg, NextPoint, 
                        &me->ModuleEnv ),
          senderid = NULL_OBJID,
          targetid = me->CompId.objid,
          targetos = me->CompId.osnum);
      as$status();
  
      status =
      om$send( msg = message VRGeneric.VRGetSupports
                                     ( &msg, VR_MAX_CPTS, SupIds, &NbSup ),
          targetid = me->CompId.objid, 
          targetos = me->CompId.osnum );
      as$status( action = RET_STATUS );

      if( NbSup )  prev_seg_id = SupIds[0];
      else    prev_seg_id.objid = NULL_OBJID;

      me->SegId.osnum = me->ModuleEnv.md_id.osnum;

#ifdef MY_DEBUG
      printf ("place segment %f %f %f\n",
                          NextPoint[0],NextPoint[1],NextPoint[2]);
      printf ("place segment %f %f %f\n",
                          SplitPoint[0],SplitPoint[1],SplitPoint[2]);
#endif
      status =
      VR$PlaceSegment( p_retmsg    = &msg,
                        Product    = me->Product,
                   p_SegmentPt0    = NextPoint,
                   p_SegmentPt1    = SplitPoint,
                    p_PrevSegId    = &prev_seg_id,
                     p_CurMdEnv    = &me->ModuleEnv,
                 p_NewSegmentId    = &me->SegId );

      nIndex[0] = 1;

#ifdef MY_DEBUG
      printf ("to connect\n");
#endif

      status =
      VRConnect( &msg, &me->CmpId, &me->CptNum, me->CmpNbCpts, 
                 &me->SegId, 1, nIndex, &me->ModuleEnv );

      nIndex[0] = 0;

      status =
      VRConnect( &msg, &me->CompId, &me->RetainIndex, me->CmpNbCpts, 
                 &me->SegId, 1, nIndex, &me->ModuleEnv );

#ifdef MY_DEBUG
      printf ("to VRUpdateGeometry\n");
#endif

      VRUpdateGeometry ( &msg, NULL, &me->CmpId, &me->ModuleEnv);

      CorId.objid = NULL_OBJID;
      CorId.osnum = me->ModuleEnv.md_id.osnum;

#ifdef MY_DEBUG
      printf ("to ComputeCorrection\n");
#endif

      status =
      VR$ComputeCorrection(  p_retmsg  = &msg,
                              CorType  = VR_FTF,
                          p_SegmentId  = &me->SegId,
                              p_MdEnv  = &me->ModuleEnv,
                              p_CorId  = &CorId );
      as$status();

      if( CorId.objid != NULL_OBJID )
      {
        status =
        om$send( msg = message NDnode.NDdisplay ( 0, GRbd, &me->ModuleEnv),
            senderid = NULL_OBJID,
            targetid = CorId.objid,
            targetos = CorId.osnum );
        as$status();
      }

      return OM_S_SUCCESS;
    }
  }
  else  
  {
    nCptNum[0] = me->CptNum;
    if( (me->CmpType & VR_CONSTR_COMPONENT_TYPE) && nCptNum[0] == -1 ) 
                                    nCptNum[0] = 0;
  }

  /*"SegId    = %d \n",me->SegId.objid*/
  /*"NewSegId = %d \n",NewSegId.objid*/

  if ( me->nSysType != VR_DANGLING )
    status = VRConnect( &msg, &me->CmpId, nCptNum, me->CmpNbCpts, 
                        SegList, 2, nIndex, &me->ModuleEnv );
  else
  {
    status = VRReConnect( &msg, &me->CompId, &me->CmpId, nCptNum,
                           me->CmpNbCpts, 0, NULL, &me->ModuleEnv );

    /*| -- Delete Component component replaced -- */
    status = 
    om$send( msg = message GRgraphics.GRdelete( &msg, &me->ModuleEnv),
        senderid = NULL_OBJID,
        targetid = me->CompId.objid,
        targetos = me->CompId.osnum);
    as$status();
  }

  if ( me->nSysType != VR_DANGLING )
  {
    CompSegDesc.NbSeg = 2;
    CompSegDesc.SegDesc[0].Fitting = VR_UNKNOWN;
    CompSegDesc.SegDesc[1].Fitting = VR_UNKNOWN;

    CompSegDesc.SegDesc[0].bChangeLength = TRUE;
    CompSegDesc.SegDesc[1].bChangeLength = TRUE;

    CompSegDesc.SegDesc[0].SegId = me->SegId;
    CompSegDesc.SegDesc[1].SegId = NewSegId;

    CorType = VR_UNKNOWN;
    SupId   = me->SegId;

    if ( me->nSysType != VR_PIPE)
    {
      /* -- Set FtF constraint in segment -- */
      /*| Retrieving segment between located and new component */

      CorType = TRUE;

      SupId.objid = NULL_OBJID;
      SupId.osnum = me->ModuleEnv.md_id.osnum;
    
      status = 
      om$send( msg = message VRGeneric.VRGetSupOnCpt 
                             (&msg, me->RetainIndex, &SupId, &me->ModuleEnv),
          targetid = me->CompId.objid,
          targetos = me->CompId.osnum);
      as$status ();
    
      /*"SegId = %d CreaSegId = %d \n", me->SegId.objid, SupId.objid*/

      if ( SupId.objid == me->SegId.objid )
      {
        CompSegDesc.SegDesc[0].Fitting = TRUE;
        CompSegDesc.SegDesc[1].Fitting = VR_UNKNOWN;
        CompSegDesc.SegDesc[0].SegType = BEGIN_OF_SEG;
        CompSegDesc.SegDesc[1].SegType = END_OF_SEG;
      }
      else
      {
        CompSegDesc.SegDesc[0].SegId = NewSegId;
        CompSegDesc.SegDesc[1].SegId = me->SegId;
        CompSegDesc.SegDesc[0].Fitting = TRUE;
        CompSegDesc.SegDesc[1].Fitting = VR_UNKNOWN;
        CompSegDesc.SegDesc[0].SegType = END_OF_SEG;
        CompSegDesc.SegDesc[1].SegType = BEGIN_OF_SEG;
      }
    }

    /*| Spliting Correction for inline insertion */
    status = VR$SplitCorrection( p_retmsg  = &msg,
                                  CorType  = CorType,
                                  p_SegId  = &SupId,
                                  p_CmpId  = &me->CmpId,
                                  p_MdEnv  = &me->ModuleEnv );

    VRUpdateGeometry ( &msg, &CompSegDesc, &me->CmpId, &me->ModuleEnv);
  } 
  else
  {
    struct  GRid  CorId;
    IGRint        NbCor;

    /*C UnDisplay Old dangling */
    Mode = GRbe;
    status =
    om$send( msg = message GRgraphics.GRdisplay
                               ( &msg, &me->ModuleEnv.md_env.matrix_type,
                                 me->ModuleEnv.md_env.matrix, &Mode, 
                                 &me->ModuleEnv.md_id ),
        targetid = me->CompId.objid, 
        targetos = me->CompId.osnum );
    as$status();

  /*C Fix for the error messages that are displayed when the user places
      an eccentric reducer wrt "Center Point". We know that the dangling
      is always going to have only one correction. So we don't need
      all the checks that will be done by the function "VRGetCorr-
      ections". Replace this function call by message "VRGetCorrect-
      ions". This way we can also make the system a bit faster by
      avoiding the unnecessary tests :  Manyam
  */

    /*C get the correction Id */
    CorId.objid = NULL_OBJID;
    status = 
    om$send( msg = message VRGeneric.VRGetCorrections(&msg, 1, &CorId, &NbCor),
        senderid = NULL_OBJID,
        targetid = me->CmpId.objid, 
        targetos = me->CmpId.osnum );
    as$status( action = RET_STATUS );

    /*" VRINSERTCOMPONENT : CorId = %d\n", CorId.objid */
 
    if( CorId.objid != NULL_OBJID )
    {
      status =
      om$send( msg = message NDnode.NDdisplay(0, GRbehe, &me->ModuleEnv ),
          senderid = NULL_OBJID,
          targetid = CorId.objid,
          targetos = CorId.osnum );
      as$status();
    }

    CorId.objid = NULL_OBJID;
    CorId.osnum = me->ModuleEnv.md_id.osnum;

    status = VR$ComputeCorrection( p_retmsg = &msg,
                                    CorType = VR_UNKNOWN,
                                p_SegmentId = &me->SegId,
                                    p_MdEnv = &me->ModuleEnv,
                                    p_CorId = &CorId );
    as$status();
 
    if( CorId.objid != NULL_OBJID )
    {
      status =
      om$send( msg = message NDnode.NDdisplay( 0, GRbd, &me->ModuleEnv),
          senderid = NULL_OBJID,
          targetid = CorId.objid,
          targetos = CorId.osnum );
      as$status();
    }
  }

  Mode = GRbd;
  status = 
  om$send( msg = message GRgraphics.GRdisplay( &msg,
                                     &me->ModuleEnv.md_env.matrix_type,
                                      me->ModuleEnv.md_env.matrix, &Mode,
                                     &me->ModuleEnv.md_id ),
      targetid = me->CmpId.objid, 
      targetos = me->CmpId.osnum );
  as$status();

  if( !bVR_IS_PID( me->cRep) )
  {
    VRCheckCompTopo( &CompTopo, &me->CmpId, &me->ModuleEnv );
    if( CompTopo == VR_CLOSURE_TOPO || CompTopo == VR_SPLIT_TOPO ) 
      *ret = IS_ENDLINE_COMP;
  }

  VRBlankMessage ();

  return  OM_S_SUCCESS;

} /* end method VRInsertComponent */

/* ====================================================================  */
method VRChangeComponent (IGRlong *ret)
{
  IGRlong   msg;
  IGRlong   status;
  IGRchar   OldSearch[50], NewSearch[50];
  IGRint    NbParamList=0, TopoReturnCode;
  IGRshort  CmpTopo, CmpType;

  struct GRid           NullId;
  struct GRid           NewSysParamId, NewUsrParamId, NewMissParamId;
  struct GRid           OldSysParamId, OldUsrParamId, OldMissParamId;
  struct VRGenInfo      Instance;
  struct VRSelectAttr   ParamList;
  enum   GRdpmode       mode;

  SetProc(VRCOProduct.VRChangeComponent); Begin

  *ret = MSSUCC;

  NullId.objid = NULL_OBJID;
  NullId.osnum = me->ModuleEnv.md_id.osnum;
  OldSearch[0] = NewSearch[0] = '\0';

  VRProcessingMessage ();

  /*| ----- UnDisplay Old component ----- */
  mode = GRbe;
  status =
  om$send( msg  = message GRgraphics.GRdisplay
                          ( &msg, &me->ModuleEnv.md_env.matrix_type,
                             me->ModuleEnv.md_env.matrix, &mode, 
                            &me->ModuleEnv.md_id ),
       targetid = me->CompId.objid, 
       targetos = me->CompId.osnum );
  as$status();

  /*| --- Check if it is the same component with different params --- */

/**** COMMENTED FOR TR179601883 -Shankar *****
  status = 
  om$send( msg = message VRProduct.VRGetSearch( &msg, &NullId, 0, 
                                                &NbParamList, &ParamList,
                                                 OldSearch, &me->ModuleEnv ),
      senderid = NULL_OBJID,
      targetid = me->CompId.objid, 
      targetos = me->CompId.osnum );
  as$status();

  status = 
  om$send( msg = message VRProduct.VRGetSearch( &msg, &NullId, 0,
                                                &NbParamList, &ParamList,
                                                 NewSearch, &me->ModuleEnv ),
      senderid = NULL_OBJID,
      targetid = me->CmpId.objid, 
      targetos = me->CmpId.osnum );
  as$status();

  if( !strcmp( OldSearch, NewSearch ) )
  {
    IGRchar     TmpString[100];
    IGRint      TmpInt;

    status =
    om$send( msg = message VRGeneric.VRGetParams(&msg, &OldSysParamId, 
                                            &OldUsrParamId, &OldMissParamId),
        senderid = NULL_OBJID,
        targetid = me->CompId.objid,
        targetos = me->CompId.osnum);
    as$status();

    status =
    om$send( msg = message VRGeneric.VRGetParams(&msg, &NewSysParamId, 
                                            &NewUsrParamId, &NewMissParamId),
        senderid = NULL_OBJID,
        targetid = me->CmpId.objid,
        targetos = me->CmpId.osnum);
    as$status();

    status =
    om$send( msg = message VRGeneric.VRChgParams(&msg, &NewSysParamId, 
                                             &NewUsrParamId, &NewMissParamId),
        senderid = NULL_OBJID,
        targetid = me->CompId.objid,
        targetos = me->CompId.osnum);
    as$status();
  
    status = VRUpdateGeometry ( &msg, NULL, &me->CompId, &me->ModuleEnv);

    status =
    om$send( msg = message VRGeneric.VRChgParams(&msg, &OldSysParamId, 
                                             &OldUsrParamId, &OldMissParamId),
        senderid = NULL_OBJID,
        targetid = me->CmpId.objid,
        targetos = me->CmpId.osnum);
    as$status();

    status =
    om$send( msg = message VRGeneric.VRGetInstance( &msg, &Instance ),
        senderid = NULL_OBJID,
        targetid = me->CompId.objid,
        targetos = me->CompId.osnum);
    as$status();

    strcpy( TmpString, Instance.szNumber );
    strcpy( Instance.szNumber, me->CmpNumber );
    strcpy( me->CmpNumber, TmpString );

    strcpy( TmpString, Instance.szNotes );
    strcpy( Instance.szNotes, me->CmpNotes );
    strcpy( me->CmpNotes, TmpString );

    TmpString[0] = Instance.cNoMtoFlg;
    Instance.cNoMtoFlg = me->CmpNoMtoFlag;
    me->CmpNoMtoFlag = TmpString[0];

    TmpInt     = Instance.nOption;
    Instance.nOption = me->CmpOption;
    me->CmpOption   = TmpInt;

    status =
    om$send( msg = message VRGeneric.VRSetInstance( &msg, &Instance ),
        senderid = NULL_OBJID,
        targetid = me->CompId.objid,
        targetos = me->CompId.osnum);
    as$status();

    NullId.objid     = me->CompId.objid;
    me->CompId.objid = me->CmpId.objid;
    me->CmpId.objid  = NullId.objid;

    return OM_S_SUCCESS;
  }
**********  Commented for TR179601883 -Shankar.****/

  /* -- Orient with specified amgle -- */
#ifdef vdsDEBUG
printf("call orientcomp with objid %d, cpt %d\n", me->CmpId.objid, me->CptNum);
#endif 
  VR$OrientComp( p_retmsg = &msg,
     p_CmpId  = &me->CmpId,
     Justif   = me->CptNum,
     Matrix   = me->CmpMatrix,
     p_MdEnv  = &me->ModuleEnv
          );  

   /*| ----- Disconnect old comp and connect new one ----- */
  status = VRReConnect( &msg, &me->CompId, &me->CmpId, NULL, me->CmpNbCpts, 
                         0, NULL, &me->ModuleEnv );

  /*| ----- Display New component ----- */
  status = 
  om$send( msg = message NDnode.NDdisplay( 0, GRbd, &me->ModuleEnv ),
      targetid = me->CmpId.objid, 
      targetos = me->CmpId.osnum );
  as$status();

  /*C  Modified me->CompId to me->CmpId, the old component may be a bad
  /*C  component, like an 'ERROR COMPONENT'. Mallik.
   */
  VRGetSpecialInformations( &msg,&CmpTopo,&CmpType,&me->CmpId,&me->ModuleEnv);

  TopoReturnCode = VRIsTopoCompatible(me->Product,CmpTopo,me->nInitialCompTopo);

  /*| ----- Special OLET correction processing ----- */
  if (TopoReturnCode & TEE_TO_OLET || TopoReturnCode & OLET_TO_TEE)
  {
    /*| Tee to Olet process needed */
    /*^
      printf ("SegFit is <%d>, CmpId is <%d>\n",
                    me->SegId.objid, me->CmpId.objid);*/

    status = VRSpecialCorrectionProcessing ( &msg, TopoReturnCode,
                                             &me->SegId, &me->CmpId, 
                                             &me->ModuleEnv );
    as$status ();
    as$status (sts = msg);
  }

  VRBlankMessage ();

  End
  return  OM_S_SUCCESS;
}

/**************************************************************************/

method VRUpdateForm (IGRlong *sts)
{
  IGRint   i, NumMissAttr=0;
  IGRlong  status, msg;
  struct ACrg_coll *MissAttr=NULL;
 
  SetProc( VRUpdateForm of VRCOPiping ); Begin
 
  __DBGpr_obj( " Missing ParamId ", me->MissParamId );

  if( me->MissParamId.objid == NULL_OBJID ) return OM_S_SUCCESS;

  /* added by alwin for CR179424244 */
  status =
  VR$ModifyCollection(    p_msg                 = &msg,
                          Operation             = VR_UPDATE,
                          p_InputCollectionId   = &me->MissParamId,
                          OutNumPar             = &NumMissAttr,
                          OutParList            = &MissAttr );
 
  __DBGpr_int( " Nb. of Missing Parameters ", NumMissAttr );
 
  for( i=0; i<NumMissAttr; i++ )
  {
    /* Check if the bend_sweep attribute is in the Missing Parameters, if so
    then change its value to the old components value. So that when instead of
    displaying the default value in the form we can directly display actual
    "bend_sweep", which user mayn't be knowing. Alwin */
 
    if( !strcmp( MissAttr[i].name, VR_N_BEND_ANG_DB ) )
    {
       IGRint FootIndex = -1;
       struct ret_struct strBendSweep;
 
       __DBGpr_obj( " Old Component's Id ", me->CompId );
 
       /* Get the Old Component's Bend Sweep angle and set it to the new
       component to avoid the Network problems */
       status =
       om$send ( msg = message VRGeneric.ACgive_structure( (IGRint*)&msg,
                                  &FootIndex, VR_N_BEND_ANG_DB,
                                  &strBendSweep, &me->ModuleEnv ),
                                targetid = me->CompId.objid,
                                targetos = me->CompId.osnum );
 
       __DBGpr_dbl( " Bend Sweep Angle of old comp. ",
                                 strBendSweep.var.root_pm_st.value );
 
       if( strBendSweep.var.root_pm_st.value )
       {
         struct ACrg_coll AddAttribute;
 
         strcpy( AddAttribute.name, VR_N_BEND_ANG_DB );
         AddAttribute.desc.type = AC_ATTRIB_DOUBLE;
         AddAttribute.desc.value.att_exp = strBendSweep.var.root_pm_st.value;
 
         /* Accordingly update the collector for it reflect when it displays
         the value later */
         status =
         VR$ModifyCollection(    p_msg                 = &msg,
                                 Operation             = VR_MERGE_COLL,
                                 p_OutputCollectionId  = &me->MissParamId,
                                 NbParamsToModify      = 1,
                                 p_ParamsListToModify  = &AddAttribute );
         goto proceed;
       }
    }
  }
 
proceed:
 
  _FREE( MissAttr );
  /* added by alwin for CR179424244 */
 
  __DBGpr_com( " Displaying the missing parameters " );
  status = VR$DispCollAttr(  pForm  = me->FormUser,
                            Gadget  = USER_ATTR_FLD,
                           pCollId  = &me->MissParamId );
  as$status( action = RET_STATUS );
 
  __DBGpr_com( " Displaying the Form " );
  FIf_display( me->FormUser );

  End
  return  OM_S_SUCCESS;
}

/* This method will be executed only if the user selected component is a
Correction Component. added by Alwin for CR179421374 */
 
method VREvalCorComp ( IGRlong *sts )
{
  IGRshort nStatus, ProductName;
  IGRlong  msg, status;
  struct GRid OwnerId;
 
  status = om$send ( msg = message VRGeneric.VRGetStatus( &msg, &nStatus ),
                                targetid = me->CompId.objid,
                                targetos = me->CompId.osnum );
 
  /* Get the owner "Piping Correction Entity" */
  status = ASget_as_owner( &me->CompId, &OwnerId );
 
  /* Get the product name of the selected component */
  status =
  om$send( msg = message VRCorrection.VRGetProductName( &ProductName ),
                 senderid = NULL_OBJID,
                 targetid = OwnerId.objid,
                 targetos = OwnerId.osnum );
 
  /* Only if the Component is Correction and Product is PIPING allow it*/
  if( ( nStatus & VR_CORRECTION ) && ( ProductName == VR_PIPING ) )
  {
    IGRuchar  cRep;
    IGRint    NbParam;
    union VRparam_attr CmpParams;
    struct VRGenInfo  CmpInst;
 
    /* to change the Component Instance, first get it */
    status = om$send ( msg = message VRGeneric.VRGetInstance ( &msg, &CmpInst ),
                        senderid = NULL_OBJID,
                        targetid = me->CompId.objid,
                        targetos = me->CompId.osnum );
 
    CmpInst.nOption = me->CmpOption;
 
    /* Set the Changed Instance of the Component */
    status = om$send ( msg = message VRGeneric.VRSetInstance ( &msg, &CmpInst ),
                        senderid = NULL_OBJID,
                        targetid = me->CompId.objid,
                        targetos = me->CompId.osnum );
 
    /* Get the Components Parameters from the Component Id itself */
    status = VR$GetDimensionAttributes(      p_retmsg        = &msg,
                                             Product         = ProductName,
                                             p_ComponentId   = &me->CompId,
                                             p_DimAttributes = &CmpParams,
                                             p_MdEnv         = &me->ModuleEnv );
 
    /* This method does the real trick by changing the "Instance option code"
    to the new value, with out any break */
    status = om$send ( msg = message VRCorrection.VRChgCorCmpAttrs ( &msg,
                           &me->CompId, &CmpParams, me->cRep,  &me->ModuleEnv ),
              senderid = NULL_OBJID,
              targetid = OwnerId.objid,
              targetos = OwnerId.osnum );
 
  }
 
  return OM_S_SUCCESS;
}

end implementation VRCOProduct;


