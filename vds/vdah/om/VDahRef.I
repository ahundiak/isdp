/* $Id: VDahRef.I,v 1.3 2001/01/11 16:34:31 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDahRef.I
 *
 * Description: Reference file toolkit
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDahRef.I,v $
 *      Revision 1.3  2001/01/11 16:34:31  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:58  art
 *      s merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/11/25  01:16:10  pinnacle
# AssyTree
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      11/25/97  ah      creation
 *
 ***************************************************************************/

class implementation Root;

#include "VDmaster.h"

from GRcontext import GRgetmodule_env;
from GRreffile import GRgetosnum;
from GRreffile import GRgetrfprops;

/* -----------------------------------------
 * Get the ref file manager object
 */
IGRstat VDahRefGetRefMgr(GRspacenum modId_osnum, TGRid *mgrID) 
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid   modID;

  modID.osnum = modId_osnum;
  sts = ex$get_modid(
    mod_osnum =  modID.osnum, 
    mod_id    = &modID.objid
  );
  if (!(sts & 1)) {
    // printf("Problem getting module id\n");
    goto wrapup;
  }

  mgrID->osnum = 0;
  mgrID->objid = NULL_OBJID;

  sts = ex$get_super ( 
    mod_id    = modID.objid,
    mod_osnum = modID.osnum,
    create    = FALSE,

    super_name  =  REFERENCE_FILE_MANAGER,
    super_class = "Super_rfmgr",
    super_id    = &mgrID->objid,
    super_osnum = &mgrID->osnum 
  );
 
  if (!(sts & 1)) {
    printf("Problem Getting Ref Mgr For %d\n",modID.osnum);
    goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Get Matrix for ref object
 */
IGRstat VDahRefGetRefEnv(TGRid *refID, TGRmd_env *refENV)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRid   conID;

  sts = VDahGetChnObject(refID,"GRreffile.to_context",0,&conID);
  if (!(sts & 1)) goto wrapup;

  sts = om$send(
    msg = message GRcontext.GRgetmodule_env(&msg,refENV),
    senderid = NULL_OBJID,
    targetid = conID.objid,
    targetos = conID.osnum
  );

  if (!(sts & msg & 1)) {
    goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * See if one ref obj should be added to list
 */
IGRstat VDahRefAddRef(TGRid *mgrID, IGRuint chnIndex, TVDvlaENV *refEnvVLA)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRid     conID;
  TGRid     refID;
  TGRmd_env refENV;
  VDosnum   refOSnum;

  // Get the object
  sts = VDahGetChnObject(mgrID,"Super_rfmgr.mgr",chnIndex,&refID);
  if (!(sts & 1)) goto wrapup;

  // Verify Loaded
  sts = om$send(
    msg = message GRreffile.GRgetosnum(&msg,&refOSnum),
    senderid = NULL_OBJID,
    targetid = refID.objid,
    targetos = refID.osnum
  );
  if (!(sts & msg & 1)) goto wrapup;

  // Get the env
  sts = VDahGetChnObject(&refID,"GRreffile.to_context",0,&conID);
  if (!(sts & 1)) goto wrapup;

  sts = om$send(
    msg = message GRcontext.GRgetmodule_env(&msg,&refENV),
    senderid = NULL_OBJID,
    targetid = conID.objid,
    targetos = conID.osnum
  );
  if (!(sts & msg & 1)) goto wrapup;

  // Add It
  VDvlaENV_AppendNoDups(refEnvVLA,&refENV);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Get list of ref files
 * There could be quite a few so use vla
 *
 * Don't empty vla here, allows for nested searches
 */
IGRstat VDahRefGetRefList(TVDvlaENV *refEnvVLA)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid     mgrID;
  TGRmd_env curENV;

  IGRint i;

  // Add current OS
  // ex$get_cur_mod (id=&curId.objid, osnum=&curId.osnum);
  // Know that gr call itself uses ex$get_cur_mod
  sts = gr$get_module_env(buffer = &curENV);
  if (!(sts & 1)) goto wrapup;

  VDvlaENV_AppendNoDups(refEnvVLA,&curENV);

  retFlag = 1;

  // get mgr
  sts = VDahRefGetRefMgr(curENV.md_id.osnum,&mgrID);
  if (!(sts & 1)) goto wrapup;

  // Cycle through
  for(i = 0; sts; i++) {
    sts = VDahRefAddRef(&mgrID,i,refEnvVLA);
    if (!(sts & 1)) sts = 0;
  }

wrapup:

  return retFlag;
}

/* -------------------------------------------------
 * Simple test routine
 */
IGRstat VDahRefGetRefListTest()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i;

  TGRmd_env refENV;
  VDosnum   refOSnum;

  TVDvlaENV refEnvVLA;

  printf("-------------------------\n");
  printf("Testing reference file List\n");

  VDvlaENV_Construct(&refEnvVLA);

  sts = VDahRefGetRefList(&refEnvVLA);
  if (!(sts & 1)) goto wrapup;

  for(
    i = 0; 
    VDvlaENV_GetAt(&refEnvVLA,&refENV,i);
    i++
  ) {

    refOSnum = refENV.md_id.osnum;

    printf("%2d %2d %s\n",i,refOSnum,OM_GA_OSDs[refOSnum]->name);

  }
  retFlag = 1;

wrapup:
  VDvlaENV_Delete(&refEnvVLA);
  return retFlag;
}

end implementation Root;
