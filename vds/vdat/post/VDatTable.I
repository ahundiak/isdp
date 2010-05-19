class implementation VDatBase;

#include "VDris.h"

#include "VDobj.h"
#include "VDfld.h"
#include "VDsa.h"
#include "VDsaProto.h"
#include "VDbt.h"

IGRstar VDatFldGetPostAttrs(IGRchar *i_tableName, TVDatFld *o_flds, IGRint *o_cnt)
{
  IGRstat retFlag = 0;
  TGRid   tableID;

  TVDflds   flds;
  TVDfld   *fld1;
  TVDatFld *fld2;
  
  IGRint  i;
  
  // Init
  *o_cnt = 0;
  
  // Get the table object
  vdsa$GetTableObj(tableName = i_tableName, tableID = &tableID);
  if (tableID.objid == NULL_OBJID) goto wrapup;
  
  // And it's attributes
  vdbt$GetAttrs(objID = &tableID, flds = &flds);

  // Convert to old format
  for(i = 0; i < flds.cnt; i++) {

    fld1 = &flds.fld[i];
    fld2 = &o_flds[i];

    memset(fld2,0,sizeof(TVDatFld));
    fld2->type = fld1->type;
    strcpy(fld2->name,fld1->name);
  }
  *o_cnt = flds.cnt;
  retFlag = 1;
  
wrapup:
  return retFlag;
  
}


end implementation VDatBase;

