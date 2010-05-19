/* $Id: VDsupCrv.I,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/imp/VDsupCrv.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsupCrv.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/11/25  15:50:52  pinnacle
# NULL_GRID
#
# Revision 1.3  1997/10/29  15:23:44  pinnacle
# Add VDmaster.h
#
# Revision 1.2  1997/10/28  18:16:14  pinnacle
# Assorted 2.5 Fixes
#
 *
 * History:
 *      MM/DD/YY        AUTHOR   DESCRIPTION
 *      10/28/97        ah       added header
 *      11/25/97        ah       Deleted extern NULL_GRID
 ***************************************************************************/

class implementation VDsupGen;

#include "VDmsg.h"
#include "vdAPImacros.h"

#include "VDsupMisc.h"
#include "VDsupMac.h"
#include "VDsupCons.h"

/* ------------------------------------------
 * Construct single support curve
 */
IGRstat VDsupConsCrv(VDsupConsInfo *info)
{
  TGRid   intId,trimId,footId;
  IGRstat sts,l_ret;
  IGRchar foot_name[DI_PATH_MAX];

  l_ret = MSFAIL;

  /* Intersect Object with Surface */
  intId.objid = NULL_OBJID;
  sts = VDsupGetIntersection(
     info,
    &info->baseSurfLc,
    &info->baseObj1Lc,
    &intId
  );
  __CheckSTS(sts,"Intersecting Surfaces",wrapup);

  /* Trim It */
  trimId.objid = NULL_OBJID;
  sts = VDsupTrimCurve(info,&intId,&trimId);
  __CheckSTS(sts,"Trimming Curve",wrapup);

  if (trimId.objid != NULL_OBJID) {
    vd_$bulk_delete(theEnv = info->md_env, grids = &intId);
    intId = trimId;
  }

  /* Cut It */
  trimId.objid = NULL_OBJID;
  sts = VDsupCutCurve(info,&intId,&trimId);
  __CheckSTS(sts,"Cutting Curve",wrapup);

  if (trimId.objid != NULL_OBJID) {
    footId = trimId;
    vd_$bulk_delete(theEnv = info->md_env, grids = &intId);
  }
  else {
    footId = intId;
  }

  /* Name it */
  sprintf(foot_name,"%s_%02d",info->occName,1);

  di$rm_name(
    regexp = foot_name,
    osnum  = footId.osnum
  );
/*
{
  IGRstat l_msg;

  om$send(
    msg = message GRvg.GRchgname(&l_msg,info->md_env,foot_name),
    senderid = NULL_OBJID,
    targetid = footId.objid,
    targetos = footId.osnum
  );
}
*/
  *info->feetNum = 1;
   info->feetListId[0] = footId;

  l_ret = MSSUCC;

wrapup:
  return l_ret;
}

end implementation VDsupGen;
