/* $Id: VDsaCache.I,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsa/VDsaCache.I
 *
 * Description: Cache Interface Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsaCache.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/10  21:37:36  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDmaster.h"
#include "VDbt.h"

#include "VDsa.h"
#include "VDsaProto.h"

#include "VDScheckin.h"

/* --------------------------------------------------------
 * Verify Logged In
 */
IGRstar VDsaVerifyLogin()
{
  IGRstat sts;

  sts = VDSverify_login();
  if (sts & 1) return sts;

  UI_status("Not Logged Into PDM");

  return 0;
}

/* --------------------------------------------------------
 * Cache list of records from vds_catalogs
 */
IGRstar VDsaGetCacheCats(TGRid *objID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   miscID;

  // For the query
  IGRint    i;
  IGRint    cols;
  IGRint    rows = 0;
  IGRchar **buf  = NULL;
  IGRchar   sql[1024];

  TVDfld   *flds = NULL;
  IGRchar   data[1024];
  
  // Arg Check
  if (objID == NULL) goto wrapup;
  objID->objid = NULL_OBJID;
  
  // Lives under misc
  VDsaGetCacheMisc(&miscID);
  if (miscID.objid == NULL_OBJID) goto wrapup;

  // Search for the object
  vdbt$GetObj(objID = &miscID, type = VDBT_TYPE_CACHE_CATS, childID = objID);
  if (objID->objid != NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Create if logged into pdu
  sts = VDsaVerifyLogin();
  if (!(sts & 1)) goto wrapup;
  
  // Do the query first
  sprintf(sql,
	  "Select catalog_name,dynamic_table,sch_dyn_table,cit_table,product,equip_ppl "
	  "from vdscatalogs order by catalog_name;");

  rows = cols = 0; buf = NULL;
  sts = VDSsql_query(sql, &cols, &rows, &buf);
  if (!(sts & 1)) goto wrapup;

  if ((buf == NULL) || (rows <= 0) || (cols != 6))  goto wrapup;

  // Allocate room for the data
  flds = _CALLOC(rows,TVDfld);
  if (flds == NULL) goto wrapup;
  
  // Transfer to field list
  for(i = 0; i < rows; i++) {

    // Pack the rest into a string
    sprintf(data,"%s:%s:%s:%s:%s",
	    buf[(i*cols)+1],buf[(i*cols)+2],
	    buf[(i*cols)+3],buf[(i*cols)+4],
	    buf[(i*cols)+5]);

    *(data + VDFLD_MAX_TXT - 1) = 0;
    
    vdfld$Set(fld = &flds[i], 
	      type = VDFLD_TYPE_TXT, 
	      name = buf[(i*cols)+0], 
	      txt = data);
  }

  // Create the object
  vdbt$CreateBase(type     = VDBT_TYPE_CACHE_CATS, 
		  name     = "VDsaCacheCats", 
		  parentID = &miscID, 
		  objID    =  objID);
  
  if (objID->objid == NULL_OBJID) goto wrapup;

  // Add in the attributes
  vdbt$SetAttrs(objID = objID, fld = flds, cnt = rows);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (flds) _FREE(flds);
  
  if (buf) VdsRisFreeBuffer(buf, rows * cols);
  return retFlag;
}

/* --------------------------------------------------------
 * Cache list of files and their post information
 */
IGRstar VDsaGetCacheFiles(TGRid *objID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   miscID;
  
  // Arg Check
  if (objID == NULL) goto wrapup;
  objID->objid = NULL_OBJID;
  
  // Lives under misc
  VDsaGetCacheMisc(&miscID);
  if (miscID.objid == NULL_OBJID) goto wrapup;

  // Search for the object
  vdbt$GetObj(objID = &miscID, type = VDBT_TYPE_CACHE_FILES, childID = objID);
  if (objID->objid != NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Create if logged into pdu
  sts = VDsaVerifyLogin();
  if (!(sts & 1)) goto wrapup;
  
  vdbt$CreateBase(type     = VDBT_TYPE_CACHE_FILES, 
		  name     = "VDsaCacheFiles", 
		  parentID = &miscID, 
		  objID    =  objID);
  
  if (objID->objid == NULL_OBJID) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:

  return retFlag;
}

/* --------------------------------------------------------
 * Main Interface to caching system
 */
IGRstar VDsaGetCache(IGRint trace,
                     TGRid *mgrID,
		     TGRid *miscID,
		     TGRid *tblsID,
		     TGRid *recsID,
		     TGRid *catsID,
		     TGRid *filesID,
		     TGRid *setsID
		     )
{
  IGRstat retFlag = 0;
  
  // Arg Check
  if ( mgrID  != NULL)   mgrID->objid = NULL_OBJID;
  if (miscID  != NULL)  miscID->objid = NULL_OBJID;
  if (tblsID  != NULL)  tblsID->objid = NULL_OBJID;
  if (recsID  != NULL)  recsID->objid = NULL_OBJID;
  if (catsID  != NULL)  catsID->objid = NULL_OBJID;
  if (setsID  != NULL)  setsID->objid = NULL_OBJID;
  if (filesID != NULL) filesID->objid = NULL_OBJID;
  
  // Basically a traffic cop
  if (mgrID != NULL) {
    VDsaGetCacheMgr(mgrID);
    if (mgrID->objid == NULL_OBJID) goto wrapup;
    if (trace) vdbro$PrintObject(objID = mgrID);
  }
  
  if (miscID != NULL) {
    VDsaGetCacheMisc(miscID);
    if (miscID->objid == NULL_OBJID) goto wrapup;
    if (trace) vdbro$PrintObject(objID = miscID);
  }

  if (tblsID != NULL) {
    VDsaGetCacheTbls(tblsID);
    if (tblsID->objid == NULL_OBJID) goto wrapup;
    if (trace) vdbro$PrintObject(objID = tblsID);
  }

  if (recsID != NULL) {
    VDsaGetCacheRecs(recsID);
    if (recsID->objid == NULL_OBJID) goto wrapup;
    if (trace) vdbro$PrintObject(objID = recsID);
  }

  if (catsID != NULL) {
    VDsaGetCacheCats(catsID);
    if (catsID->objid == NULL_OBJID) goto wrapup;
    if (trace) vdbro$PrintObject(objID = catsID);
  }

  if (filesID != NULL) {
    VDsaGetCacheFiles(filesID);
    if (filesID->objid == NULL_OBJID) goto wrapup;
    if (trace) vdbro$PrintObject(objID = filesID);
  }
  
  if (setsID != NULL) {
    VDsaGetCacheSets(setsID);
    if (setsID->objid == NULL_OBJID) goto wrapup;
    if (trace) vdbro$PrintObject(objID = setsID);
  }
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Delete the cache
 */
IGRstar VDsaDeleteCache()
{
  IGRstat retFlag = 0;
  TGRid   mgrID;

  vdsa$GetCache  (mgrID = &mgrID);
  vdbt$DeleteBase(objID = &mgrID);

  retFlag = 1;

  return retFlag;
}

/* --------------------------------------------------------
 * Get a level1 cache object
 */
IGRstar VDsaGetCache1(IGRint type, IGRchar *name, TGRid *objID)
{
  IGRstat retFlag = 0;
  TGRid   mgrID;
  
  // Arg Check
  if (objID == NULL) goto wrapup;
  objID->objid = NULL_OBJID;

  // Get the manager
  VDsaGetCacheMgr(&mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;
  
  // Search for the object
  vdbt$GetObj(objID = &mgrID, type = type, childID = objID);
  if (objID->objid != NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Create and add
  vdbt$CreateBase(type     = type, 
		  name     = name, 
		  parentID = &mgrID, 
		  objID    =  objID);

  if (objID->objid == NULL_OBJID) goto wrapup;

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Misc Cache Object
 */
IGRstar VDsaGetCacheMisc(TGRid *objID)
{
  IGRstat retFlag = 0;
  
  retFlag = VDsaGetCache1(VDBT_TYPE_CACHE_MISC,"VDsaCacheMisc",objID);
  
  return retFlag;
}

/* --------------------------------------------------------
 * Tbls Cache Object
 */
IGRstar VDsaGetCacheTbls(TGRid *objID)
{
  IGRstat retFlag = 0;
  
  retFlag = VDsaGetCache1(VDBT_TYPE_CACHE_TBLS,"VDsaCacheTbls",objID);
  
  return retFlag;
}

/* --------------------------------------------------------
 * Sets Cache Object
 */
IGRstar VDsaGetCacheSets(TGRid *objID)
{
  IGRstat retFlag = 0;
  
  retFlag = VDsaGetCache1(VDBT_TYPE_CACHE_SETS,"VDsaCacheSets",objID);
  
  return retFlag;
}

/* --------------------------------------------------------
 * Recs Cache Object
 */
IGRstar VDsaGetCacheRecs(TGRid *objID)
{
  IGRstat retFlag = 0;
  
  retFlag = VDsaGetCache1(VDBT_TYPE_CACHE_RECS,"VDsaCacheRecs",objID);
  
  return retFlag;
}

/* --------------------------------------------------------
 * Master Cache Object
 */
IGRstar VDsaGetCacheMgr(TGRid *mgrID)
{
  IGRstat retFlag = 0;
  IGRchar mgrPath[1024];

  // Arg Check
  if (mgrID == NULL) goto wrapup;
  mgrID->objid = NULL_OBJID;
  mgrID->osnum = OM_Gw_TransOSnum_0;
  
  // Get the name
  di$give_pathname(osnum = mgrID->osnum, pathname = mgrPath);
  if (*mgrPath == 0) goto wrapup;
  
  //DIstrcat(mgrPath,"IGENOD");
  DIstrcat(mgrPath,"VDbtCacheMgr");

  // Get It
  di$translate(
    objname =  mgrPath,
    p_osnum = &mgrID->osnum,  // Bit redundant but oh well
    p_objid = &mgrID->objid
  );
  if (mgrID->objid != NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }

  // Create It
  vdbt$CreateBase(type = VDBT_TYPE_CACHE_MGR, name = "VDsaCacheMgr", objID = mgrID);
  if (mgrID->objid == NULL_OBJID) goto wrapup;

  // Name it
  di$rm_name (regexp  = mgrPath, osnum = mgrID->osnum);
  di$add_name(objname = mgrPath, osnum = mgrID->osnum, objid = mgrID->objid);
  
  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDbtBase;
