class implementation VDatBase;

#include "VDris.h"

/* ------------------------------------------
 * Wrapper for different types of keys
 * 13 May 2002 Change to use ris routines
 * I think these are obsolete anyways
 */
IGRstar VDatPOSTGetNextSetKey(IGRkey *theKEY) 
{
  return VDrisGetNextKey("sets",theKEY);
}
IGRstar VDatPOSTGetNextFileKey(IGRkey *theKEY) 
{
  return VDrisGetNextKey("files",theKEY);
}
#if 0
/* --------------------------------------------
 * Generic key routine
 */
IGRstar VDatPOSTGetNextKey(IGRchar *keyName, IGRkey *theKEY)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar sql[256];
  IGRchar **buf = NULL;
  IGRint  rows,cols;

  // Init
  *theKEY = 0;

  // Make sure logged in
  sts = VDatVerifyLogin();
  if (!(sts & 1)) goto wrapup;

  // Get current key
  sprintf(sql,
    "Select key_num from %s where key_type = '%s';",
    VDAT_RDB_TBL_KEYS, keyName
  );
  rows = cols = 0; buf = NULL;
  sts = VDSsql_query(sql, &cols, &rows, &buf);
  if (!(sts & 1)) {
    UI_status("Query for key failed");
    goto wrapup;
  }
  if ((rows < 1) || (buf == NULL)) {
    UI_status("vdat_keys table not initialized");
    goto wrapup;
  }

  *theKEY = atoi(buf[0]);
  VdsRisFreeBuffer(buf, rows * cols);

  // Update new key
  sprintf(sql,
    "Update %s set key_num = %d where key_type = '%s';",
    VDAT_RDB_TBL_KEYS, *theKEY + 1, keyName
  );

  sts = VDSexecute_sql_stmt(sql);
  if (!(sts & 1)) {
    UI_status("Update of key failed");
    goto wrapup;
  }

  retFlag = 1;
wrapup:
  return retFlag;
}
#endif

end implementation VDatBase;

