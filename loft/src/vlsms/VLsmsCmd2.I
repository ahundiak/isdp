/* $Id: VLsmsCmd2.I,v 1.5 2002/04/24 15:12:51 ahundiak Exp $  */

/***************************************************************************
 * I/EFP
 *
 * File:        vlsms/VLextCmd2.I
 *
 * Description: Extract For Production
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLsmsCmd2.I,v $
 *      Revision 1.5  2002/04/24 15:12:51  ahundiak
 *      ah
 *
 *      Revision 1.4  2002/04/09 20:54:13  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/09/14 13:42:56  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/18 17:55:32  art
 *      ah
 *
# Revision 1.6  2000/12/15  20:03:00  pinnacle
# ah
#
# Revision 1.5  2000/11/27  20:26:08  pinnacle
# ah
#
# Revision 1.4  2000/10/15  13:36:54  pinnacle
# ah
#
# Revision 1.3  2000/06/19  18:39:36  pinnacle
# ah
#
# Revision 1.2  2000/05/03  13:08:46  pinnacle
# ah
#
# Revision 1.1  2000/04/25  16:31:42  pinnacle
# ah
#
# Revision 1.1  2000/02/25  18:16:54  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/15/99  ah      Creation
 *
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"

#include "VDfrmMacros.h"
#include "VDobj.h"
#include "VDvla.h"
#include "VDsa.h"

#include "VDat.h"
#include "VDxml.h"
#include "VDcvg.h"
#include "VLsms.h"
#include "VLsmsCmd.h"

#include "VDassert.h"

VDASSERT_FFN("src/vlsms/VLsmsCmd2.I");

/* --------------------------------------------------------
 * Hack for now
 */
static IGRstat getAllSetsInOS(VDosnum osNum, TVDvlaID *setVLA)
{
  VDASSERT_FN("getAllSetsInOS");
  
  IGRstat retFlag = 0;
  
  TGRid mgrID;
  TGRid setsID;
  TGRid setID;
  
  IGRint i;

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %d\n",fn,osNum);
  }

  // Get the manager
  VDatGetSetMgr(osNum, &mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;

  // Get the sets
  VDatGetSets(&mgrID,&setsID);
  if (setsID.objid == NULL_OBJID) goto wrapup;

  if (traceFlag) {
    vdobj$Print(objID = &setsID);
  }
  
  // Cycle Through
  for(i = 0; VDatGetChildObject(&setsID,i,&setID); i++) {

    VDvlaID_Append(setVLA,&setID);
  }
  
  retFlag = 1;

wrapup:
  // Say Bi
  if (traceFlag) {
    printf("<<< %s %d %d\n",fn,osNum,retFlag);
  }
  return retFlag;
}

static IGRstat getAllSets(TVDvlaID *setVLA)
{
  VDASSERT_FN("getAllSets");
  IGRstat retFlag = 0;

  VDosnum osNum;
  IGRint  osFlag = 1;
  IGRchar osName[256];
  
  // Just cycle through
  for(osNum = 2; osFlag; osNum++) {

    *osName = 0;
    om$os_number_to_internal_name (osnum = osNum, osname = osName);
    if (*osName == 0) osFlag = 0;
    else {
      
      getAllSetsInOS(osNum, setVLA);
    }
    
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the set to write, by name
 *
 * Also gets undev and misc sets
 */
IGRstat VLsmsCmdGetSetToWrite(IGRchar *setName, 
			      TGRid   *setID,
			      TGRid   *setIDu,
			      TGRid   *setIDm)
{
  IGRstat retFlag;
  TGRid   setIDx,setTypeID;
  IGRint  i;
  
  TVDvlaID setVLA;

  IGRchar buf[128];
  IGRchar setNameu[32];
  IGRchar setNamem[32];
  
  // Arg check
  if (setID == NULL) goto wrapup;
  setID->objid  = NULL_OBJID;
  setIDu->objid = NULL_OBJID;
  setIDm->objid = NULL_OBJID;
  if (setName == NULL) goto wrapup;
  
  sprintf(setNameu,"%su",setName);
  sprintf(setNamem,"%sm",setName);
  
  // Find the sets
  vdvla_id$Construct(vla = &setVLA);
  getAllSets(&setVLA);
  
  // Cycle through
  for(i = 0; vdvla_id$GetAt(vla = &setVLA, nth = i, objID = &setIDx); i++) {

    // Get the set type
    VDatRDBGetSet  (&setIDx,&setTypeID);
    VDatGetBaseName(&setTypeID,buf);
    if (!strcmp(buf,"StagingTree")) {
      
      // Get the name
      VDatGetBaseName(&setIDx,buf);
      if (!strcmp(setName, buf)) *setID  = setIDx;
      if (!strcmp(setNameu,buf)) *setIDu = setIDx;
      if (!strcmp(setNamem,buf)) *setIDm = setIDx;
    }
  }
  
  // Done
  if (setID->objid != NULL_OBJID) retFlag = 1;
  
wrapup:
  vdvla_id$Delete(vla = &setVLA);
  return retFlag;
}

/* -----------------------------------------------
 * Complete extraction pulling data from form
 */
IGRstat VLsmsCmdWriteSet2(Form form)
{
  IGRstat retFlag;
  IGRstat sts;
  
  TVLsmsCmdInfo   infox;  // Use a pointer for now
  TVLsmsCmdInfo  *info;
  TVDxmlFileInfo *xml;
  
  IGRchar buf[256];
  
  // Init 
  info = &infox;
  memset(info,0,sizeof(TVLsmsCmdInfo));
  UI_status("Production Extraction ...");

  // Open the log files
  sts = VLsmsInitLogFiles();
  if (!(sts & 1)) goto wrapup;

  // Fill in some info
  VLsmsCmdGetInfoFromForm(form,info);
  if (info->setID.objid == NULL_OBJID) goto wrapup;

  // Open the main file
  sts = VLsmsOpenOutputFile(&info->file,"SmsData.xml");
  if (!(sts & 1)) goto wrapup;

  // Header stuff
  VLsmsCmdWriteHeader(info);

  // Write the tree
  info->writeTree = 1;
  VLsmsCmdWriteTree(info);

  // Write the plates
  VLsmsCmdWritePlates(info);

  // Close the output file
  VLsmsCloseOutputFile(&info->file,1);

  // Do the dxf stuff
  if (info->mapLabels || 1) {
    VLsmsLog1(1,1,"--------- Converting SmsData.xml To spades.xml --------\n");
    VLsms2GenerateDxfPdf("SmsData.xml",info->unitReal,info->unitReal,info->preTranslate);
    VLsmsLog1(1,1,"--------- Conversion Complete --------\n");
  }
  /* -------------------------------------------------------
   * The original routine
   * else  VLsmsGenerateDxfPdf("SmsData.xml",info->unitReal,info->unitReal,info->preTranslate);
   */

  // Done
  retFlag = 1;
  
wrapup:

  // Free the plate info
  if (info->plateItems) free(info->plateItems);

  // Close the output file
  // if (info->file) VLsmsCloseOutputFile(&info->file,1);
  UI_status("Production Extraction Complete, See extract.log");

  // Close the log files
  VLsmsCloseLogFiles();
  VDlogShowCat("extract.log");
  
  // Really done
  return retFlag;
}

/* -----------------------------------------------
 * High level interface for writing single
 * unwrap out, suitable for debugging and loading into spades
 */
IGRstat VLsmsCmdWriteUnwrap(TGRobj_env *unwrapOE)
{
  IGRchar fn[] = "VLsmsCmdWriteUnwrap";
  
  IGRstat retFlag;
  IGRstat sts;
  
  TVLsmsCmdInfo   infox;  // Use a pointer for now
  TVLsmsCmdInfo  *info;
  
  IGRchar buf[256];
  IGRchar *p;
  
  TGRobj_env plateOE;
  
  TVDxmlFileInfo *xml;
  
  IGRint traceFlagx = 0;
  
  // Say Hi
  if (traceFlagx) {
    printf(">>> %s\n",fn);
    vdobj$Print(objOE = unwrapOE);
  }
  
  // Init 
  info = &infox;
  memset(info,0,sizeof(TVLsmsCmdInfo));
  UI_status("Production Extraction ...");

  // Start log files
  sts = VLsmsInitLogFiles();
  if (!(sts & 1)) goto wrapup;
  
  // Need to know the set to use
  if (unwrapOE == NULL) goto wrapup;
  VLunwGetPlateForUnwrap(unwrapOE,NULL,&plateOE);
  if (plateOE.obj_id.objid == NULL_OBJID) {
    VLsmsLog1(1,1,"*** Cannot find plate for unwrap\n");
    goto wrapup;
  }
  if (traceFlagx) {
    vdobj$Print(objOE = &plateOE);
  }
  
  //vdobj$Print(objOE = unwrapOE);
  //vdobj$Print(objOE = &plateOE);
  vdsa$GetStruct(objOE = &plateOE,
		 name  = "SA_AST:StagingTree:0:set_name",
		 txt   = info->unitReal);

  // Might be in the undev or misc set???
  p = strrchr(info->unitReal,'u'); if (p) *p = 0;
  p = strrchr(info->unitReal,'m'); if (p) *p = 0;

  strcpy(info->unitTest,info->unitReal);
  //printf("Set %s\n",info->unitReal);
  
  // Find the set
  VLsmsCmdGetSetToWrite(info->unitReal, 
			&info->setID,
			&info->setIDu,
			&info->setIDm);
  if (info->setID.objid == NULL_OBJID) goto wrapup;

  // Open the main file
  sts = VLsmsOpenOutputFile(&info->file,"SmsData.xml");
  if (!(sts & 1)) goto wrapup;  

  // Some data
  strcpy(info->hull,      "LPD17");
  strcpy(info->fileStatus,"0 - Open");
  strcpy(info->fileWhat,  "Plates");
  info->preTranslate = 1;

  // Standard header info
  VLsmsCmdWriteHeader(info);
  
  // Write the tree
  //info->writeTree = writeTree;
  //VLsmsCmdWriteTree(info);

  // Write the plates
  //if (writePlates) VLsmsCmdWritePlates(info);
  xml = &info->file.cvg.xml;
  VDxmlWriteObjBeg(xml,XML_SMS_PLATES,0,1);
  VLsmsWriteUnwrap(&info->file,unwrapOE);
  VDxmlWriteObjEnd(xml,XML_SMS_PLATES,1);

  // Close the output file
  VLsmsCloseOutputFile(&info->file,1);

  // Do the dxf
  VLsms2GenerateDxfPdf("SmsData.xml",info->unitReal,info->unitReal,0);

  // Done
  retFlag = 1;
  
wrapup:

  // Free the plate info
  if (info->plateItems) free(info->plateItems);
  UI_status("Production Extraction Complete, See extract.log");

  // Close log files
  VLsmsCloseLogFiles();
  VDlogShowCat("extract.log");
  
  // Say bye
  if (traceFlagx) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Update the posted staging tree version
 */
IGRstat VLsmsCmdPostTree(Form form)
{
  IGRstat retFlag = 0;
  IGRint  results;
  IGRint  post = 0;
  
  TVDatBlob blob;
  IGRchar buf[256];
  
  // Purpose and set type
  memset(&blob,0,sizeof(TVDatBlob));
  strcpy(blob.purpose, "SPADES");
  strcpy(blob.set_type,"StagingTree");
  
  // Fill in hull
  vdfrm$GetText(form = form, gadget = VLEXT_FORM_G_HULL, txt = blob.hull);

  // Fill in unit
  vdfrm$GetText(form = form, gadget = VLEXT_FORM_G_UNIT, txt = blob.set_name);

  // Post it
  vdfrm$SetStatus(form = form, txt = "Posting tree...");  
  VDatPostBlob(&blob);
  vdfrm$SetStatus(form = form, txt = "Tree has been posted.");
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Fill in the form with initial information
 */
IGRstat VLsmsCmdInitForm(Form form)
{
  IGRstat retFlag = 0;
  IGRint  results;
  IGRint  post = 0;
  
  TVDatBlob blob;
  IGRchar buf[256];
  
  // Make sure logged in
  // VDrisOpenSchema(NULL);
  
  // Purpose and set type
  memset(&blob,0,sizeof(TVDatBlob));
  strcpy(blob.purpose, "SPADES");
  strcpy(blob.set_type,"StagingTree");
  
  // Fill in hull
  strcpy(blob.hull,"LPD17");
  vdfrm$SetText(form = form, gadget = VLEXT_FORM_G_HULL, txt = blob.hull);

  // Fill in unit
  VDatGetSetNameForType(blob.set_type,blob.set_name);
  vdfrm$SetText(form = form, gadget = VLEXT_FORM_G_UNIT, txt = blob.set_name);

  // Enable tree reving
  VIg_enable(form,VLEXT_FORM_B_TREE_REV);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation Root;
