class implementation VDatBase;

#include "VDris.h"
#include "VDpdm.h"

/* --------------------------------------------
 * Gets the id for a given file
 * Attempt to add one if none found if flag is true
 */
IGRstar VDatPOSTGetFileKey(TVDatPDMInfo *info, IGRboolean createKey)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar sql[1024];
  IGRchar **buf = NULL;
  IGRint  rows,cols;
  IGRint  fkey = 0;

  // Init
  info->key = 0;

  // Make sure logged in
  sts = VDatVerifyLogin();
  if (!(sts & 1)) goto wrapup;

  /* -----------------------------------------
   * going to share file keys with the VDPDM functionality.
   * Just Call VDpdmGetFileKeyForCPR from here.
   * ***/
  sts = VDpdmGetFileKeyForCPR( info->cat, info->part, info->rev, &fkey );
  if (fkey == 0) goto wrapup;

  info->key = fkey;
  
#if 0
  // Get current key
  sprintf(sql,
    "Select file_key from %s where "
    "file_cat = '%s' and file_nam = '%s' and file_ver = '%s';",
    VDAT_RDB_TBL_FILE_KEYS,info->cat,info->part,info->rev
  );
  rows = cols = 0; buf = NULL;
  sts = VDSsql_query(sql, &cols, &rows, &buf);
  if (!(sts & 1)) goto wrapup;

  if ((rows > 0) && (buf != NULL)) {
    info->key = atoi(buf[0]);
    VdsRisFreeBuffer(buf, rows * cols);
    retFlag = 1;
    goto wrapup;
  }

  // Try to create?
  if (createKey == FALSE) goto wrapup;

  // Get next key
  VDatPOSTGetNextFileKey(&info->key);
  if (info->key == 0) goto wrapup;

  // Update new key
  sprintf(sql,
    "insert into %s values ("
    "%d,'%s','%s','%s','%s');",
     VDAT_RDB_TBL_FILE_KEYS,
     info->key,info->cat,info->part,info->rev,info->file
  );
  sts = VDSexecute_sql_stmt(sql);
  if (!(sts & 1)) {
    UI_status("Update of file key failed");
    info->key = 0;
    goto wrapup;
  }
#endif
  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;

