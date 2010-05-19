/* $Id: VDsaPDM.I,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsa/VDsaPDM.I
 *
 * Description: PDM Part Information
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsaPDM.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/04/10  21:37:36  pinnacle
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
#include "VDsaProto.h"

/* --------------------------------------------------------
 * Interface to PDM information
 */
IGRstar VDsaGetPDM(TGRobj_env *objOE,
		   TGRid      *objID,

		   IGRchar    *fileName,
		   IGRchar    *assembly_cat,
		   IGRchar    *assembly_nam,
		   IGRchar    *assembly_ver,
		   IGRchar    *seqno,
		   IGRchar    *all
		   )
{
  IGRstat retFlag = 0;
  IGRchar path[1024];

  IGRchar cat[128];
  IGRchar nam[128];
  IGRchar ver[128];

  IGRchar data[128];
  IGRchar *p;
  
  TGRid   filesID;
  TVDfld  fld;
  
  // Reset args
  if (fileName)     *fileName = 0;
  if (assembly_cat) *assembly_cat = 0;
  if (assembly_nam) *assembly_nam = 0;
  if (assembly_ver) *assembly_ver = 0;
  if (seqno)        *seqno = 0;
  if (all)          *all   = 0;
  
  // Get the object
  if  (objOE) objID = &objOE->obj_id;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  // Do the seqno
  if (seqno) sprintf(seqno,"%d",objID->objid);

  // Find the file name
  di$give_pathname(osnum = objID->osnum, pathname = path);
  p = strrchr(path,':');
  if (p) strcpy(path,p+1);
  if (*path == 0) goto wrapup;
  
  if (fileName) strcpy(fileName,path);
  
  // Local copies
  *cat = *nam = *ver = 0;

  // Check the cache
  vdsa$GetCache(filesID = &filesID);
  if (filesID.objid != NULL_OBJID) {
    
    // Get the attribute
    *fld.name = 0;
    vdbt$GetAttr(objID = &filesID, name = path, fld = &fld);

    if (*fld.name != 0) {

      // Got it
      strcpy(data,fld.val.txt);
      p = strchr(data,':');
      if (p) {
	*p = 0;
	strcpy(cat,data);
	strcpy(data,p+1);
      }
      p = strchr(data,':');
      if (p) {
	*p = 0;
	strcpy(nam,data);
	strcpy(data,p+1);
      }
      p = strchr(data,':');
      if (p) {
	*p = 0;
	strcpy(ver,data);
	strcpy(data,p+1);
      }
      goto got_data;
    }
  }
  
  // Goto PDM
  *cat = *nam = *ver = 0;
  PDMGetPartInfoGivenFileName(path,cat,nam,ver);
  if ((*cat == 0) || (*nam == 0)) goto wrapup;

  // Add data to record
  strcpy(fld.name,path);
  fld.type = VDFLD_TYPE_TXT;
  sprintf(fld.val.txt,"%s:%s:%s:%d",cat,nam,ver,objID->objid);

  vdbt$UpdAttrs(objID = &filesID, cnt = 1, fld = &fld);
  
  // Xfer the data
got_data:
  if (assembly_cat) strcpy(assembly_cat,cat);
  if (assembly_nam) strcpy(assembly_nam,nam);
  if (assembly_ver) strcpy(assembly_ver,ver);
  
  if (all) strcpy(all,fld.val.txt);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

end implementation VDbtBase;





