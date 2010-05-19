/* $Id: VDatMgr.I,v 1.2 2001/02/14 16:45:20 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/imp/VDatMgr.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatMgr.I,v $
 *      Revision 1.2  2001/02/14 16:45:20  ramarao
 *      Removed __Enter() and __Exit() macros.
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.4  2000/02/14  19:47:16  pinnacle
# tr179901064
#
# Revision 1.3  1998/11/07  14:02:58  pinnacle
# ah
#
# Revision 1.2  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.8  1998/03/06  21:22:06  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      creation
 *
 ***************************************************************************/

class implementation VDatBase;

#include "VDdir.h"
#include "v_dbgmacros.h"

/* ------------------------------------------------------
 * Builds path to named manager object 
 * Later, may need to be able to handle transient space as well
 */
IGRstat VDatGetSetMgrPath(VDosnum osnum, IGRchar *mgrPath)
{
  *mgrPath = 0;

  di$give_pathname(osnum = osnum, pathname = mgrPath);
  if (*mgrPath == 0) return 0;

  //printf("mgrPath %d '%s'\n",osnum,mgrPath);
  
  DIstrcat(mgrPath,"IGENOD");    
  DIstrcat(mgrPath,"VDatSetMgr");
  
  return 1;
}

/* ------------------------------------------------------
 * Gets the manager
 */
IGRstat VDatGetSetMgr(VDosnum osnum, TGRid *objID)
{
  IGRstat retFlag = 0;
  IGRchar mgrPath[DI_PATH_MAX];

  // Hi

  // Init
  objID->objid = NULL_OBJID;

  // Set desired os to search
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &objID->osnum);
  else objID->osnum = osnum;

  *mgrPath = 0;
  VDatGetSetMgrPath(objID->osnum,mgrPath);
  if (*mgrPath == 0) {

    // Should be ok, get this on os=0
#if 0
    printf("Could not build manager name while getting manager for osnum %d\n",
    objID->osnum);
#endif
    goto wrapup;
  }

  di$translate(
    objname = mgrPath,
    p_objid = &objID->objid
  );
  if (objID->objid == NULL_OBJID) {
//  printf("Manager object does not exist\n");
    goto wrapup;
  }

  // Check and verify everything in set
  // VDatVerifyMgr(objID);

//VDbroPrintObj(objID);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Creates a new manager object
 */
IGRstat VDatCreateSetMgr(VDosnum osnum, TGRid *mgrID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar mgrPath[DI_PATH_MAX];

  TGRid rdbCacheID;
  TGRid rdbPostsID;
  TGRid rdbAttrsID;
  TGRid rdbMacsID;
  TGRid rdbSetsID;

  TGRid setsID;

  // Hi

  // Create object
  UI_status("Creating SetManager...");
  vdat$CreateBase(
    name = VDAT_CLASSN_SET_MGR,
    type = VDAT_CLASSI_SET_MGR,
    osnum  = osnum,
    baseID = mgrID
  );
  if (mgrID->objid == NULL_OBJID) goto wrapup;

  // Standard path name
  *mgrPath = 0;
  VDatGetSetMgrPath(mgrID->osnum,mgrPath);
  if (*mgrPath == 0) goto wrapup;

  di$rm_name (regexp  = mgrPath, osnum = mgrID->osnum);
  di$add_name(objname = mgrPath, osnum = mgrID->osnum, objid = mgrID->objid);

  // Add Cache
  sts = VDatRDBCreateCache(mgrID,&rdbCacheID);
  if (rdbCacheID.objid == NULL_OBJID) goto wrapup;
  if (!(sts & 1)) goto wrapup;

  // Add Postable Tables
  sts = VDatRDBCreatePosts(&rdbCacheID,&rdbPostsID);
  if (rdbPostsID.objid == NULL_OBJID) goto wrapup;
  if (!(sts & 1)) goto wrapup;

  // Add RDB Sets
  sts = VDatRDBCreateSets(&rdbCacheID,&rdbSetsID);
  if (rdbSetsID.objid == NULL_OBJID) goto wrapup;
  if (!(sts & 1)) goto wrapup;

  // Add RDB Attrs
  sts = VDatRDBCreateAttrs(&rdbCacheID,&rdbAttrsID);
  if (rdbAttrsID.objid == NULL_OBJID) goto wrapup;
  if (!(sts & 1)) goto wrapup;

  // Add RDB Macros
  sts = VDatRDBCreateMacs(&rdbCacheID,&rdbMacsID);
  if (rdbMacsID.objid == NULL_OBJID) goto wrapup;
  if (!(sts & 1)) goto wrapup;

  // Add Regular Set List
  sts = VDatCreateSets(mgrID,&setsID);
  if (!(sts & 1)) goto wrapup;

  // Done
  retFlag = 1;

wrapup:
  if (retFlag != 1) {
    UI_status("Problem Creating Manager Object\n");
    VDatDeleteBase(mgrID);
    mgrID->objid = NULL_OBJID;
  }
  else UI_status("Created SetManager");

  return retFlag;
}

end implementation VDatBase;

