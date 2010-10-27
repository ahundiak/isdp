/* $Id: VDsupEtc.I,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/imp/VDsupEtc.I
 *
 * Description: Support Extend Trim
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsupEtc.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/17  22:05:12  pinnacle
# VDsupEtc
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      12/17/97  ah      Created
 ***************************************************************************/
class implementation VDsupGen;

#include "VDsupMisc.h"
#include "VDsupMac.h"
#include "VDsupCons.h"

from GRcurve  import GRendpts;
from GRcurve  import GRdisextend;

extern GRclassid OPP_GRbcsubbc_class_id;

IGRstat VDsupTrimCurve (VDsupConsInfo *info, TGRid *crvId, TGRid *newId);
IGRstat VDsupCloneCurve(VDsupConsInfo *info, TGRid *crvId, TGRid *newId);

IGRstat VDsupExtendCurve(TGRmd_env *env, TGRid *crvID, IGRdouble distance);

IGRstat VDsupCreateEtc(VDsupConsInfo *info, TGRobj_env *crvOE, TGRid *footID);
IGRstat VDsupConsEtc  (VDsupConsInfo *info);

/* ---------------------------------------------
 * Clones a curve usng active symbology
 */
IGRstat VDsupCloneCurve(
  VDsupConsInfo *info,
  TGRid         *crvID,
  TGRid         *newID
)
{
  IGRstat retFlag = 0;
  IGRstat sts,suc;

  TGRbsp_curve *crvBSP  = NULL;
  TGRvg_construct cst;

  // Init
  newID->objid = NULL_OBJID;

  /* Grab Geometry */
  sts = vd_$get_geometry(
    msg      = &suc,
    grobjId  =  crvID,
    grobjEnv =  info->md_env,
    geometry = &crvBSP
  );
  __CheckRC(sts,suc,"Getting Geometry",wrapup);
 
  /* Make the curve */
  VDsupInitCnst(&cst);

  cst.geometry = (char *)crvBSP;
  cst.env_info = info->md_env;

  sts = VDsupConsObj(OPP_GRbcsubbc_class_id,info->md_env,newID);
  __CheckSTS(sts,"Constructing Object",wrapup);

  sts = om$send(
    msg  = message GRgraphics.GRconstruct(&cst),
    senderid = NULL_OBJID,
    targetid = newID->objid,
    targetos = newID->osnum  
  );
  __CheckSTS(sts,"Constructing Object",wrapup);

  retFlag = 1;

wrapup:

  _FREE(crvBSP);
  return retFlag;
}

/* ---------------------------------------------
 * Extend a curve 
 */
IGRstat VDsupExtendCurve(TGRmd_env *env, TGRid *crvID, IGRdouble distance)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong suc;

  IGRpoint pt,pt0,pt1;

  // Check arg
  if ((crvID == NULL) || (crvID->objid == NULL_OBJID)) goto wrapup;
  if (env == NULL) goto wrapup;

  // Check distance
  if (distance < .001) {
    retFlag = 1;
    goto wrapup;
  }

  // Get the endpoints
  sts = om$send(
    msg = message GRcurve.GRendpts(
      &suc,
      &env->md_env.matrix_type,
       env->md_env.matrix,
       pt0,pt1
    ),
    senderid = NULL_OBJID,
    targetid = crvID->objid,
    targetos = crvID->osnum
  );
  if (!(sts & suc & 1)) goto wrapup;

  // Extend it (twice)
  sts = om$send(
    msg = message GRcurve.GRdisextend(&suc,env,pt0,&distance,pt),
    senderid = NULL_OBJID,
    targetid = crvID->objid,
    targetos = crvID->osnum
  );
  if (!(sts & suc & 1)) goto wrapup;
  sts = om$send(
    msg = message GRcurve.GRdisextend(&suc,env,pt1,&distance,pt),
    senderid = NULL_OBJID,
    targetid = crvID->objid,
    targetos = crvID->osnum
  );
  if (!(sts & suc & 1)) goto wrapup;

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Execute it
 */
IGRstat VDsupCreateEtc(VDsupConsInfo *info, TGRobj_env *crvOE, TGRid *footID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong suc;

  TGRid cpyID,trimID;

  // Init
  footID->objid = NULL_OBJID;

  // Arg check
  if ((crvOE == NULL) || (crvOE->obj_id.objid == NULL_OBJID)) goto wrapup;

  // Copy the curve
  cpyID.osnum = info->md_env->md_id.osnum;
  sts = om$send(
    msg = message GRgraphics.GRcopy(
      &suc,
      &crvOE->mod_env,
       info->md_env,
      &cpyID.objid
    ),
    senderid = NULL_OBJID,
    targetid = crvOE->obj_id.objid,
    targetos = crvOE->obj_id.osnum
  );

  if (!(sts & suc & 1)) goto wrapup;
  if (cpyID.objid == NULL_OBJID) goto wrapup;

  // Extend it
  VDsupExtendCurve(info->md_env,&cpyID,info->dis1);

  // Trim or clone
  VDsupTrimCurve(info,&cpyID,&trimID);
  if (trimID.objid == NULL_OBJID) {
    VDsupCloneCurve(info,&cpyID, &trimID);
  }
  if (trimID.objid != NULL_OBJID) {
    vd_$bulk_delete(theEnv = info->md_env, grids = &cpyID);
    cpyID = trimID;
  }

  // Done
  *footID = cpyID;

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ------------------------------------------
 * Construct single support curve
 */
IGRstat VDsupConsEtc(VDsupConsInfo *info)
{
  IGRstat retFlag = 0;
  IGRint  i;

  TGRid      srcID,footID;
  TGRobj_env crvOE;

/*
  printf("===================\n");
  printf("Entered VDsupConsEtc\n");
  printf("Distance %.2f,%d,%d\n",info->dis1,info->traceNum,*info->feetNum);

  VDbroPrintObj(&info->baseObj1Lc.located_obj);
  VDbroPrintObj(&info->baseObj2Lc.located_obj);
*/

  // Sort of a hack to get the trim objects
  info->trim1Lc = info->baseObj1Lc;
  info->trim2Lc = info->baseObj2Lc;

  // By default, feetNum is the max number of feet
  *info->feetNum = 0;

  // Process each parent
  for(i = 0; i < info->traceNum; i++) {

    srcID = info->tl[VDSUP_I_TRACE_BEG + (i * 2)];
    VDahGetObjectEnv(&srcID,&crvOE);

    footID.objid = NULL_OBJID;
    VDsupCreateEtc(info,&crvOE,&footID);

    if (footID.objid != NULL_OBJID) {
       info->feetListId[*info->feetNum] = footID;
      *info->feetNum  = *info->feetNum + 1;

    }
  }
  retFlag = 1;
 
  return retFlag;
}

end implementation VDsupGen;


