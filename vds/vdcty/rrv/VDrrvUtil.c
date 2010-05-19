/* $Id: VDrrvUtil.c,v 1.8 2002/06/14 13:36:15 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvUtil.C
 *
 * Description: Create Snapshot Command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvUtil.c,v $
 *      Revision 1.8  2002/06/14 13:36:15  ahundiak
 *      ah
 *
 *      Revision 1.7  2002/05/10 19:34:04  ahundiak
 *      ah
 *
 *      Revision 1.6  2002/02/28 21:41:34  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/03/30 20:32:43  jdsauby
 *      js sp
 *
 *      Revision 1.4  2001/03/29 19:36:52  jdsauby
 *      Incorporation of Purpose Info
 *
 *      Revision 1.3  2001/02/26 15:47:18  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/02/22 22:42:33  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/17 14:23:44  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/15/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDctx.h"
#include "VDos.h"
#include "VDobj2.h"
#include "VDpdm.h"
#include "VDat.h"
#include "glib.h"
#include "VDrrvCmd.h"

VDASSERT_FFN("vdcty/rrv/VDrrvUtil.c");

/* -----------------------------------------------
 * Get the default unit and model file
 */
void VDrrvGetDefaultUnitModel(IGRchar *unit, IGRchar *model)
{
  VDASSERT_FN("VDrrvGetDefaultUnitModel");
  
  IGRchar setType[40];
  IGRchar setName[40];
  
  TGRid setID,treeID,leafID;

  TGRobj_env modelOE;
  
  TVDctxBaseInfo baseInfo;
  IGRint cnt;
  IGRint stopWalk = 0;

  VDosnum osnum;

  IGRchar buf[128];
  IGRchar *p;
  
  // Arg check
  VDASSERTW(unit);  *unit  = 0;
  VDASSERTW(model); *model = 0;

  // Should only be 1 set for the test
  VDctxGetStagingTree(&treeID,&baseInfo,&cnt);

  if (cnt == 0) {

    // Assume the current file for now
    VDosGetCurrentOS(&osnum);
    VDosGetFileName(osnum,model);
    strcpy(buf,model);
    if (strlen(buf) > 4) *(buf+4) = 0;
    strcpy(unit,buf);
    goto wrapup;
  }
  
  VDASSERTW(cnt == 1);
  strcpy(unit,baseInfo.treeName);
  
  // Get the model object
  stopWalk = 0;
  modelOE.obj_id.objid = NULL_OBJID;
  VDctxWalkNode(&treeID,1,VDctxWalkProcessGetFirstModelObject,&modelOE,&stopWalk);  
  VDASSERTW(modelOE.obj_id.objid != NULL_OBJID);
  VDosGetFileName(modelOE.obj_id.osnum,model);
  
 wrapup:
  if (unit && *unit)   VDlogPrintFmt(9,0,"Default unit %s",unit);
  else                 VDlogPrintFmt(9,0,"No default unit");

  if (model && *model) VDlogPrintFmt(9,0,"Default model %s",model);
  else                 VDlogPrintFmt(9,0,"No default model");
  
  return;
}

IGRstat VDrrvGetDefaultCreateData(TVDpdmPurposeInfo *p_info,
                                  IGRchar           *model)
{
  VDASSERT_FN("VDrrvGetDefaultCreateData");

  IGRstat retFlag = 1;
  IGRstat sts;

  TVDpdmPurposeInfo  info;

  VDosnum  osnum;
  IGRchab  m_file;

  // arg check
  VDASSERTW(model); *model = 0;
  VDASSERTW(p_info); memset(p_info,0,sizeof(TVDpdmPurposeInfo));
  
  *m_file = 0;
  memset(&info,0,sizeof(info));

  // At least get a unit and a model
  VDrrvGetDefaultUnitModel(info.unit,m_file);
  if (m_file) strcpy(model,m_file);
  if (*info.unit) strcpy(p_info->unit,info.unit);
  retFlag = 1;
  
  // Get Purpose info
  VDosGetCurrentOS(&osnum);
  VDpdmGetPurposeInfo(osnum,p_info);
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * See if a file matching the purpose info exists
 */
IGRstat VDrrvFindPurposeInfo(TVDpdmPurposeInfo *a_purposeInfo, VDosnum *a_osnum)
{
  VDASSERT_FN("VDrrvFindPurposeInfo");
  IGRstat retFlag = 0;
  
  VDosnum *osnums = NULL;
  IGRint i,cnt;
  
  TVDpdmPurposeInfo purposeInfo;
  
  // Arg check
  if (a_osnum) *a_osnum = NULL_OSNUM;
  VDASSERTW(a_purposeInfo && *a_purposeInfo->purpose);
  
  // Cycle through os's
  VDrefGetOSs(&cnt,&osnums);
  for(i = 0; i < cnt; i++) {
    VDpdmGetPurposeInfo(osnums[i],&purposeInfo);
    //printf("Purpose %2d %s %s\n",osnum,a_purposeInfo->unit,purposeInfo.unit);
    if (!strcmp(purposeInfo.purpose,a_purposeInfo->purpose) &&
	!strcmp(purposeInfo.unit,   a_purposeInfo->unit) &&
	!strcmp(purposeInfo.zone,   a_purposeInfo->zone)) {
      if (a_osnum) *a_osnum = osnums[i];
      retFlag = 1;
      goto wrapup;
    }
  }

 wrapup:
  g_free(osnums);
  return retFlag;
}

typedef struct 
{
  IGRchar prefix[8];
  IGRchar midfix[8];
  IGRint  oddFlag;
  IGRint  evenFlag;
  VDosnum osnum;
  IGRint  gotIt;
} Tinfo;

/* -----------------------------------------------
 * A walking process to determine if any 
 * attached pieces are in the desired unit hull
 *
 * Looking for filenames beginning with ZONE193
 * as passed in the data arguments
 */
static void walkPieceFileOS(TGRid *nodeID, void *data, IGRint *stopWalk)
{
  TGRobj_env modelOE;
  IGRchar fileName[128];
  IGRchar *p;
  
  IGRint len;
  
  //IGRint *osnum = data;
  Tinfo *info = data;
  
  // See if have one
  VDctxGetModelObject(nodeID,&modelOE);
  if (modelOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Get the filename
  VDosGetFileName(modelOE.obj_id.osnum,fileName);
  if (*fileName == 0) goto wrapup;
  
  // Check prefix
  len = strlen(info->prefix);
  if (len) {
    if (strncmp(info->prefix,fileName,len)) goto wrapup;
    strcpy(fileName,fileName+len);
  }
  
  // Check midfix
  len = strlen(info->midfix);
  if (len) {
    if (strncmp(info->midfix,fileName,len)) goto wrapup;
    strcpy(fileName,fileName+len);
  }

  // Check odd or even
  if (info->oddFlag || info->evenFlag) {
    
    p = strchr(fileName,'.');
    if ((p == NULL) || (p == fileName)) goto wrapup;
    p--;
    switch (*p) {
      case '0': case '2': case '4': case '6': case '8':
	if (info->oddFlag) goto wrapup;
	break;
      case '1': case '3': case '5': case '7': case '9':
	if (info->evenFlag) goto wrapup;
	break;
    }
  }
  
  // Got it
  info->osnum = modelOE.obj_id.osnum;
  info->gotIt = 1;
  *stopWalk   = 1;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Have a staging tree 
 * Set it's purpose and it's model file purpose
 */
static void autoSetStagingTreePurposeInfo(TGRid *setID)
{
  IGRstat sts;
  
  TVDpdmPurposeInfo purposeInfo;
  
  IGRchab unit;
  
  IGRint stopWalk = 0;
  
  Tinfo info;
  
  IGRchar fileName[128];
  
  
  // Set name is the unit
  VDatGetSetName(setID,unit);
  
  // Does this file need setting?
  VDpdmGetPurposeInfo(setID->osnum,&purposeInfo);

  // Wonder if we should error check the purpose here?

  // Set it
  if (*purposeInfo.purpose == 0) {
    
    // Setup the purpose
    memset(&purposeInfo,0,sizeof(TVDpdmPurposeInfo));
    strcpy(purposeInfo.purpose,"unit_prod");
    strcpy(purposeInfo.unit,unit);

    // Apply it
    VDpdmSetPurposeInfo(setID->osnum,&purposeInfo);
    
  }
  
  // See if the unit_hull purpose is already set
  memset(&purposeInfo,0,sizeof(TVDpdmPurposeInfo));
  strcpy(purposeInfo.purpose,"unit_hull");
  strcpy(purposeInfo.unit,unit);
  sts = VDrrvFindPurposeInfo(&purposeInfo,NULL);
  if (sts & 1) goto wrapup;

  // Track it down using links
  memset(&info,0,sizeof(Tinfo));
  VDosGetFileName(setID->osnum,fileName);
  strncpy(info.prefix,fileName,4);
  strcpy (info.midfix,"193");
  info.oddFlag = 1;
  VDctxWalkNode(setID,1,walkPieceFileOS,&info,&stopWalk);
  if (info.gotIt) {
    VDpdmSetPurposeInfo(info.osnum,&purposeInfo); 
  }
  
 wrapup:
  return;
}
/* -----------------------------------------------
 * Have a fab_data 
 * Set it's purpose
 */
static void autoSetFabDataPurposeInfo(TGRid *setID, IGRchar *unit)
{
  IGRstat sts;
  
  TVDpdmPurposeInfo purposeInfo;
  
  // Does this file need setting?
  VDpdmGetPurposeInfo(setID->osnum,&purposeInfo);

  // Set it
  if (*purposeInfo.purpose == 0) {
    
    // Setup the purpose
    memset(&purposeInfo,0,sizeof(TVDpdmPurposeInfo));
    strcpy(purposeInfo.purpose,"unit_fabdata");
    strcpy(purposeInfo.unit,unit);

    // Apply it
    VDpdmSetPurposeInfo(setID->osnum,&purposeInfo);
    
  }

 wrapup:
  return;
}

/* -----------------------------------------------
 * Check one os to see if it can be set
 */
static void autoSetPurposeInfoOS(VDosnum osnum, IGRchar *unit)
{
  VDASSERT_FN("autoSetPurposeInfoOS");
  
  TVDpdmPurposeInfo info;
  
  TGRid mgrID,setsID,setID;
  
  IGRint i;

  IGRchab setType;
  
  // if (traceFlag || 0) printf(">>> autoSetPurposeInfoOS %d\n",osnum);
  
  // Have staging tree?
  VDatGetSetMgr(osnum,&mgrID);
  if (mgrID.objid != NULL_OBJID) {

    VDatGetSets(&mgrID,&setsID);
    
    // Cycle once looking for single staging tree
    for(i = 0; VDatGetChildObject(&setsID,i,&setID); i++) {
  
      VDatGetSetType(&setID,setType);
      
      if (!strcmp(setType,"StagingTree")) {
	autoSetStagingTreePurposeInfo(&setID);
	if (*unit == 0) VDatGetSetName(&setID,unit);
	else            strcpy(unit,"XXXX");
      }
    }
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Given an unit, see if other purposes can be set
 */
static void autoSetUnitPurposeInfoOS(VDosnum osnum, IGRchar *unit)
{
  VDASSERT_FN("autoUnitSetPurposeInfoOS");
  
  TVDpdmPurposeInfo info;
  
  TGRid mgrID,setsID,setID;
  
  IGRint i;

  IGRchab setType;
  
  // Looking for specific tree types
  VDatGetSetMgr(osnum,&mgrID);
  if (mgrID.objid != NULL_OBJID) {

    VDatGetSets(&mgrID,&setsID);
    
    // Cycle once looking for single staging tree
    for(i = 0; VDatGetChildObject(&setsID,i,&setID); i++) {
  
      VDatGetSetType(&setID,setType);
      
      if (!strcmp(setType,"FabData")) {
	autoSetFabDataPurposeInfo(&setID,unit);
      }
    }
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Standalone function to set purpose info automatically
 * when possible
 */
void VDrrvAutoSetPurposeInfo()
{
  VDASSERT_FN("VDrrvAutoSetPurposeInfo");
  
  VDosnum *osnums = NULL;
  IGRint i,cnt;
  
  IGRchab unit;
  
  // Init
  *unit = 0;
  
  // Get ref osnums
  VDrefGetOSs(&cnt,&osnums);
  for(i = 0; i < cnt; i++) {
    autoSetPurposeInfoOS(osnums[i],unit);
  }
  // If a unit popped out then cycle again and maybe
  // set a few more
  if ((*unit >= '0') && (*unit <= '9')) {  
    for(i = 0; i < cnt; i++) {
      autoSetUnitPurposeInfoOS(osnums[i],unit);
    }
  }
  
 wrapup:
  g_free(osnums);
  return;
}

/* -----------------------------------------------
 * A walking process to determine if any 
 * attached pieces are in the os
 */
static void walkPieceOS(TGRid *nodeID, void *data, IGRint *stopWalk)
{
  TGRobj_env modelOE;

  IGRint *osnum = data;
  
  // See if have one
  VDctxGetModelObject(nodeID,&modelOE);
  if (modelOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // See if in desired os
  if (modelOE.obj_id.osnum != *osnum) goto wrapup;
  // VDobjPrint2(&modelOE,NULL);
  
  // Flag and done
  *osnum = NULL_OSNUM;
  *stopWalk = 1;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Returns true if the set has any objects from the
 * osnum linked to it
 */
IGRstat VDrrvIsSetLinkedToOS(TGRid *setID, VDosnum osnum)
{
  VDASSERT_FN("VDrrvIsSetLinkedToOS");
  
  IGRstat retFlag = 0;
  
  IGRint stopWalk = 0;
  IGRint stopOS = osnum;
  
  // Arg check
  VDASSERTW(setID && setID->objid != NULL_OBJID);

  // Walk it
  VDctxWalkNode(setID,1,walkPieceOS,&stopOS,&stopWalk);  
  if (stopOS != osnum) {
    retFlag = 1;
  }
  
 wrapup:
  return retFlag;
}

  
