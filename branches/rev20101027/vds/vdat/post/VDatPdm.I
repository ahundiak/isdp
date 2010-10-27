/* $Id: VDatPdm.I,v 1.3 2001/02/11 17:44:09 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/post/VDatPdm.I
 *
 * Description: Transient object for holding cat,part,rev info
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatPdm.I,v $
 *      Revision 1.3  2001/02/11 17:44:09  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.2  2001/01/11 21:06:42  art
 *      sp merge
 *
# Revision 1.3  2000/08/25  20:01:38  pinnacle
# ah
#
# Revision 1.2  2000/04/13  13:07:46  pinnacle
# tr179901375
#
# Revision 1.1  2000/04/11  18:38:54  pinnacle
# ah
#
# Revision 1.4  2000/02/14  19:47:16  pinnacle
# tr179901064
#
# Revision 1.3  2000/01/10  16:40:10  pinnacle
# Posting Testing
#
# Revision 1.2  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/09/98  ah      creation
 * 01/10/00  ah      Added FAKE catalog capability for testing
 * 02/14/00  ah      TR179901064 Crashing when getting ref file names.
 * 04/06/00  ah      TR179901375 Problem when getting pdm info for files
 * 08/24/00  ah      Use the vdris$IsLoggedin to allow setting default schema
 ***************************************************************************/

class implementation VDatBase;

#include "VDdir.h"
#include "VDrisc.h"

/* ------------------------------------------------------
 * Builds path to named manager object 
 */
IGRstat VDatGetPdmMgrPath(VDosnum osnum, IGRchar *mgrPath)
{
  *mgrPath = 0;

  di$give_pathname(osnum = osnum, pathname = mgrPath);
  if (*mgrPath == 0) return 0;

  DIstrcat(mgrPath,"IGENOD");    
  DIstrcat(mgrPath,"VDatPdmMgr");
  
  return 1;
}

/* ------------------------------------------------------
 * Gets the manager
 */
IGRstat VDatGetPdmMgr(VDosnum osnum, TGRid *objID)
{
  IGRstat retFlag = 0;
  IGRchar mgrPath[DI_PATH_MAX];

  // Init
  objID->objid = NULL_OBJID;

  // Set desired os to search
  if (osnum == OM_K_NOT_AN_OS) osnum = OM_Gw_TransOSnum_0;
  objID->osnum = osnum;

  *mgrPath = 0;
  VDatGetPdmMgrPath(objID->osnum,mgrPath);
  if (*mgrPath == 0) {
    printf("Could not build manager name while getting pdm manager\n");
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

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Added file to the pdm manager
 */
IGRstat VDatAddFileToPdmFlds(TVDatFld *fld, VDosnum refOSnum)
{
  IGRstat retFlag = 0;

  IGRchar  fileName[DI_PATH_MAX];
  IGRchar *p;
  IGRchar  buf[DI_PATH_MAX];
  
  TVDatPDMInfo info;

  // Need to swap this out with a call to the new pdm function

  // Get file name
  di$give_pathname(osnum = refOSnum, pathname = fileName);
  p = strrchr(fileName,':');
  if (p) strcpy(fileName,p+1);
  //printf("File %s\n",fileName);
  
  // Find pdu info
  memset(&info,0,sizeof(info));
  PDMGetPartInfoGivenFileName(fileName,
			      info.cat,
			      info.part,
			      info.rev);
  
  // Make sure part is in database
  if ((*info.cat == NULL) || (*info.part == NULL)) {

    //goto wrapup;
    
#if 1
    // Fake it for testing
    strcpy(info.cat,"FAKE");
    strcpy(info.part,fileName);
    strcpy(info.rev,"000");
    
    p = strchr(info.part,'.');
    if (p) *p = 0;
#endif

#if 0    
    sprintf(buf,"File Not In PDM '%s'",fileName);
    UI_status(buf);
    printf("%s\n",buf);
    goto wrapup;
#endif

  }

  // Xfer info
  memset(fld,0,sizeof(TVDatFld));

  strcpy (fld->name,fileName);
  sprintf(fld->valueTxt,"%s|%s|%s|",info.cat,info.part,info.rev);
  fld->valueInt = refOSnum;
  fld->type = VDAT_FLD_TYPE_CHAR;

  // Add the key, if the database is not properly initialized
  // then the key will be zero which is ok
  strcpy(info.file,fileName);
  VDatPOSTGetFileKey(&info,TRUE);
  fld->valueDbl = (IGRdouble)info.key;
  
  retFlag = 1;
  
wrapup:
  return retFlag;
  
}

/* -------------------------------------------
 * Creates a new manager object
 */
IGRstat VDatCreatePdmMgr(VDosnum osnum, TGRid *mgrID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar mgrPath[DI_PATH_MAX];

  IGRint i;
  TVDatFld  flds[VDAT_FLD_MAX];

  // Init
  UI_status("Caching Pdm Info...");
  mgrID->objid = NULL_OBJID;
  
  // Must be logged in
  sts = vdris$IsLoggedIn();
  if (!(sts & 1)) goto wrapup;

  // Use transient by default
  if (osnum == OM_K_NOT_AN_OS) osnum = OM_Gw_TransOSnum_0;

  // Create and name the object
  vdat$CreateBase(
    name = VDAT_CLASSN_PDM_MGR,
    type = VDAT_CLASSI_PDM_MGR,
    osnum  = osnum,
    baseID = mgrID
  );
  if (mgrID->objid == NULL_OBJID) goto wrapup;

  // Standard path name
  *mgrPath = 0;
  VDatGetPdmMgrPath(mgrID->osnum,mgrPath);
  if (*mgrPath == 0) goto wrapup;

  di$rm_name (regexp  = mgrPath, osnum = mgrID->osnum);
  di$add_name(objname = mgrPath, osnum = mgrID->osnum, objid = mgrID->objid);

  // Cycle through each os
  i = 0;
  for(osnum = 0; VDosValidate(osnum); osnum++) {
    sts = VDatAddFileToPdmFlds(&flds[i],osnum);
    if (sts & 1) i++;
  }
  VDatFldSetAllAttrs(mgrID,flds,i);

  // Done
  retFlag = 1;

wrapup:

  if (retFlag != 1) {
    UI_status("Problem Caching PDM Info\n");
    VDatDeleteBase(mgrID);
    
  }
  UI_status("Cached PDM Info");
  return retFlag;
}

/* -----------------------------------------
 * Gets part info for an object
 */
IGRstat VDatPOSTGetPDMInfo(
  VDosnum       osnum,
  TVDatPDMInfo *info
)
{
  IGRstat  retFlag = 0;
  TVDatFld flds[VDAT_FLD_MAX];
  IGRint   cnt,i;

  TGRid pdmID;

  IGRchar pdmText[128];
  IGRchar *pnt;

  // Init
  memset(info,0,sizeof(TVDatPDMInfo));

  // Get the pdm manager
  vdat$GetPdmMgr(mgrID = &pdmID);
  if (pdmID.objid == NULL_OBJID) {
    vdat$CreatePdmMgr(mgrID = &pdmID);
  }
  if (pdmID.objid == NULL_OBJID) goto wrapup;

  // Search attribute list
  VDatFldGetAllAttrs(&pdmID,flds,&cnt);

  for(i = 0; i < cnt; i++) {

    if (flds[i].valueInt == osnum) {

      strcpy(info->file,flds[i].name);

      strcpy(pdmText,flds[i].valueTxt);
      pnt = strchr(pdmText,'|');
      if (pnt) {
         *pnt = 0;
        strcpy(info->cat,pdmText);
        strcpy(pdmText,pnt+1);
      }
      pnt = strchr(pdmText,'|');
      if (pnt) {
         *pnt = 0;
        strcpy(info->part,pdmText);
        strcpy(pdmText,pnt+1);
      }
      pnt = strchr(pdmText,'|');
      if (pnt) {
         *pnt = 0;
        strcpy(info->rev,pdmText);
        strcpy(pdmText,pnt+1);
      }
      info->key = (IGRint)flds[i].valueDbl;

      retFlag = 1;
      goto wrapup;
    }
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;



