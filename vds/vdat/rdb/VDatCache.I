/* $Id: VDatCache.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/rdb/VDatCache.I
 *
 * Description: RDB Cache Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatCache.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      11/25/97  ah      creation
 *
 ***************************************************************************/

class implementation VDatBase;

/* ---------------------------------------------------------
 * Gets the rdb cache object
 * if manager is NULL, finds the manager
 */
IGRstar VDatRDBGetCache(TGRid *a_mgrID, TGRid *a_cacheID)
{
  IGRstat retFlag = 0;

  TGRid mgrID;

  a_cacheID->objid = NULL_OBJID;

  if (a_mgrID != NULL) mgrID = *a_mgrID;
  else                 vdat$GetSetMgr(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;

  VDatGetChildByType(&mgrID,VDAT_CLASSI_RDB_CACHE,a_cacheID);
  if (a_cacheID->objid == NULL_OBJID) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------------
 * Create rdb cache object
 * Manager can be NULL for stand alone object
 */
IGRstar VDatRDBCreateCache(TGRid *mgrID, TGRid *cacheID)
{
  IGRstat retFlag = 0;

  // Clear
  cacheID->objid = NULL_OBJID;

  // Create
  vdat$CreateBase(
    name     = VDAT_CLASSN_RDB_CACHE, 
    type     = VDAT_CLASSI_RDB_CACHE,
    parentID = mgrID,
    baseID   = cacheID
  );
  if (cacheID->objid == NULL_OBJID) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;

