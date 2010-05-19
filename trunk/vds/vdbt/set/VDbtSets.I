/* $Id: VDbtSets.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDbtSet.I
 *
 * Description: Set Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbtSets.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/04/08  21:37:22  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/08/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDmaster.h"
#include "VDbt.h"
#include "VDsaProto.h"

/* --------------------------------------
 * Gets a list of sets
 * Loads from database if required
 */
IGRstar VDbtGetSets(VDosnum osnum, TGRid *a_setsID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid setsCacheID;
  TGRid setsID;

  IGRint    i;
  IGRint    cols;
  IGRint    rows = 0;
  IGRchar **buf  = NULL;
  IGRchar   sql[1024];

  TVDfld    *flds = NULL;
  TVDfld    *fld;

  // Arg check
  if (a_setsID) a_setsID->objid = NULL_OBJID;

  // Need the master cache
  vdsa$GetCache(setsID = &setsCacheID);
  if (setsCacheID.objid == NULL_OBJID) goto wrapup;

  // Get the set types
  vdbt$GetObj(
    objID   = &setsCacheID, 
    type    = VDBT_TYPE_SETS,
    childID = &setsID);

  if (setsID.objid != NULL_OBJID) {
    if (a_setsID) *a_setsID = setsID;
    retFlag = 1;
    goto wrapup;
  }

  // Create if logged in
  sts = VDsaVerifyLogin();
  if (!(sts & 1)) goto wrapup;

  // Create the object
  vdbt$CreateBase(type     = VDBT_TYPE_SETS, 
		  name     = "VDsaSets", 
		  parentID = &setsCacheID, 
		  objID    = &setsID);

  if (setsID.objid == NULL_OBJID) goto wrapup;
  if (a_setsID) *a_setsID = setsID;

  // Load the individual set types
  sprintf(sql,
	  "Select set_name,set_type,set_desc "
	  "from vdat_set_keys order by set_type,set_name;");

  rows = cols = 0; buf = NULL;
  sts = VDSsql_query(sql, &cols, &rows, &buf);
  if (!(sts & 1)) goto wrapup;

  if ((buf == NULL) || (cols != 3))  goto wrapup;
  if (rows == 0) goto wrapup;

  // Store list of sets in the object
  flds = _CALLOC(rows,TVDfld);
  if (flds == NULL) goto wrapup;


  // Transfer data
  for(i = 0; i < rows; i++) {

    fld = &flds[i];
    fld->type = VDFLD_TYPE_TXT;
    sprintf(fld->name,"%s:%s",
            buf[(i*cols)+1],
            buf[(i*cols)+0]);    

    strcpy(fld->val.txt,buf[(i*cols)+2]);

  }
   vdbt$SetAttrs(objID = &setsID, fld = flds, cnt = rows);

  // Done
  retFlag = 1;

wrapup:
  if (flds) _FREE(flds);
  if (buf) VdsRisFreeBuffer(buf, rows * cols);
  return retFlag;
}

end implementation VDbtBase;






