/* $Id: VDvalStaging.c,v 1.5 2001/08/24 20:00:43 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/VDvalStaging.c
 *
 * Description:	Staging tree Cache
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalStaging.c,v $
 *      Revision 1.5  2001/08/24 20:00:43  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/07/28 17:37:05  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/06/22 15:16:50  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/06/03 15:00:23  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/24 18:50:21  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/21/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDrisc.h"
#include "VDtest.h"
#include "VDxdom.h"
#include "VDctx.h"
#include "VDval.h"

VDASSERT_FFN("VDvalStaging.c");

typedef struct 
{
  TGRid           stagingIDs;
  TGRid           findID;
  TVDctxNodeList  stageTypeList;
  TVDctxNodeList  stageParentList;
  TVDctxNodeList  stagePlatenList;
} Tinfo;

static Tinfo *info;


/* -----------------------------------------------
 * Get the staging from web server
 */
void VDvalWebStaging(TGRid *stagingIDs)
{
  VDASSERT_FN("VDvalWebStaging");

  // Arg check
  VDASSERTW(stagingIDs); stagingIDs->objid = NULL_OBJID;
  
  VDxdomCreateTreeFromWebFile(NULL,"/isdp/staging.xml",stagingIDs);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the staging from xml file
 */
void VDvalFileStaging(TGRid *stagingIDs)
{
  VDASSERT_FN("VDvalFileStaging");

  IGRchab path;
  
  // Arg check
  VDASSERTW(stagingIDs); stagingIDs->objid = NULL_OBJID;

  // Find the file
  VDsysFindFile("config/xml","staging.xml",path);
  if (*path == 0) goto wrapup;
  
  VDxdomCreateTreeFromXmlFile(path,stagingIDs);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Looking up a stage by type is quite common
 * There is actually a noticeable delay caused by the sequential search
 * process so take the time to index the thing
 */
static IGRint compareStageType(const void *p1, const void *p2) 
{
  TGRid *node1ID = (TGRid*)p1;
  TGRid *node2ID = (TGRid*)p2;
  
  IGRchab type1,type2;
  
  VDctxGetTxtAtr(node1ID,"type",type1); strupr(type1);
  VDctxGetTxtAtr(node2ID,"type",type2); strupr(type2);
  
  return strcmp(type1,type2);
}

static IGRint compareStageParent(const void *p1, const void *p2) 
{
  IGRint retFlag;
  
  TGRid *node1ID = (TGRid*)p1;
  TGRid *node2ID = (TGRid*)p2;
  
  IGRchab type1,type2;
  
  VDctxGetTxtAtr(node1ID,"type",type1); strupr(type1);
  VDctxGetTxtAtr(node2ID,"type",type2); strupr(type2);
  
  retFlag = strcmp(type1,type2);
  if (retFlag) return retFlag;

  VDctxGetTxtAtr(node1ID,"parent",type1); strupr(type1);
  VDctxGetTxtAtr(node2ID,"parent",type2); strupr(type2);

  return strcmp(type1,type2);
  
  
}
static IGRint compareStagePlaten(const void *p1, const void *p2) 
{
  IGRint retFlag;
  
  TGRid *node1ID = (TGRid*)p1;
  TGRid *node2ID = (TGRid*)p2;
  
  IGRchab type1,type2;
  
  VDctxGetTxtAtr(node1ID,"type",type1); strupr(type1);
  VDctxGetTxtAtr(node2ID,"type",type2); strupr(type2);
  
  retFlag = strcmp(type1,type2);
  if (retFlag) return retFlag;

  VDctxGetTxtAtr(node1ID,"platen",type1); strupr(type1);
  VDctxGetTxtAtr(node2ID,"platen",type2); strupr(type2);

  return strcmp(type1,type2);
  
}

static void indexStageType()
{
  VDASSERT_FN("indexStageType");
  
  TGRid stageIDs;
  TGRid stageID;
  
  // Find the stages
  VDctxGetChildNodeByType(&info->stagingIDs,"stages",&stageIDs);
  VDASSERTW(stageIDs.objid != NULL_OBJID);

  // Build the list
  VDctxGetNodeListByType(&stageIDs,"stage",&info->stageTypeList);
  
  // Sort em
  VDctxSortNodeList(&info->stageTypeList,compareStageType);
  
 wrapup:
  return;
}
static void indexStageParent()
{
  VDASSERT_FN("indexStageParent");
  
  TGRid stageIDs;
  TGRid stageID;
  
  // Find the stages
  VDctxGetChildNodeByType(&info->stagingIDs,"stage_parents",&stageIDs);
  VDASSERTW(stageIDs.objid != NULL_OBJID);

  // Build the list
  VDctxGetNodeListByType(&stageIDs,"stage_parent",&info->stageParentList);
  
  // Sort em
  VDctxSortNodeList(&info->stageParentList,compareStageParent);
  
 wrapup:
  return;
}
static void indexStagePlaten()
{
  VDASSERT_FN("indexStagePlaten");
  
  TGRid stageIDs;
  TGRid stageID;
  
  // Find the stages
  VDctxGetChildNodeByType(&info->stagingIDs,"stage_platens",&stageIDs);
  VDASSERTW(stageIDs.objid != NULL_OBJID);

  // Build the list
  VDctxGetNodeListByType(&stageIDs,"stage_platen",&info->stagePlatenList);
  
  // Sort em
  VDctxSortNodeList(&info->stagePlatenList,compareStagePlaten);
  
 wrapup:
  return;
}

static void indexStaging()
{
  VDASSERT_FN("indexStaging");
  
  // Just to be safe
  VDASSERTW(info && (info->stagingIDs.objid != NULL_OBJID));

  // Multiple indexes
  indexStageType();
  indexStageParent();
  indexStagePlaten();

  // For searching
  VDxdomCreateTree("find",&info->findID);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * get the staging tree, creating one if necessary
 */
void VDvalGetStaging(TGRid *stagingIDs)
{
  VDASSERT_FN("VDvalGetStagings");

  IGRint flag = 0;
  
  // Arg check
  VDASSERTW(stagingIDs); stagingIDs->objid = NULL_OBJID;

  // See if loaded
  if (info) {
    
    // Is it already loaded
    *stagingIDs = info->stagingIDs;
    if ((stagingIDs->objid != 0) && (stagingIDs->objid != NULL_OBJID)) goto wrapup;
  }
  if (info == NULL) {  
    info = calloc(1,sizeof(Tinfo));
    VDASSERTW(info);
    flag = 1;
  }
  info->stagingIDs.objid = NULL_OBJID;
  
  // Load in text file
  VDvalFileStaging(stagingIDs);
  if (stagingIDs->objid != NULL_OBJID) {
    info->stagingIDs = *stagingIDs;
    if (flag) indexStaging();
    goto wrapup;
  }

  // Try the web
  VDvalWebStaging(stagingIDs);
  if (stagingIDs->objid != NULL_OBJID) {
    info->stagingIDs = *stagingIDs;
    if (flag) indexStaging();
    goto wrapup;
  }

  // Oops
  VDlogPrintFmt(VDLOG_ERROR,1,"*** Unable to load staging tree cache");
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Sometimes the SAF,SAE etc. nodes are presented
 * as being SA with a name of a letter
 * Need to put these back into one name
 *
 * Not sure if this ia actually being used or not
 */
void VDvalGetStageType(IGRchar *type, IGRchar *name, IGRchar *stage_type)
{
  VDASSERT_FN("VDvalGetStageType");

  // Arg check
  VDASSERTW(stage_type); *stage_type = 0;
  VDASSERTW(type);
  strcpy(stage_type,type);
  
  // See i name is relevant
  if (name == NULL) goto wrapup;
  if (strcasecmp(type,"SA")) goto wrapup;
  if (strlen(name) != 1) goto wrapup;
  if ((*name >= '0') && (*name <= '9')) goto wrapup;
  
  // Combine it
  strcat(stage_type,name);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the stage for the given node type and name
 */
void VDvalGetStagingStage(IGRchar *stageType, TGRid *stageID)
{
  VDASSERT_FN("VDvalGetStagingStage");
  
  TGRid stagingIDs;
  
  TGRid *foundID;
  
  // Arg check
  VDASSERTW(stageID); stageID->objid = NULL_OBJID;
  VDASSERTW(stageType && *stageType);

  // Get the complete set
  VDvalGetStaging(&stagingIDs);
  if (stagingIDs.objid == NULL_OBJID) goto wrapup;
  
  // Use the indexed info
  VDctxAppTxtAtr(&info->findID,"type",stageType);
  foundID = VDctxSearchNodeList(&info->findID,&info->stageTypeList,compareStageType);
  if (foundID) *stageID = *foundID;

 wrapup:
  return;
}

/* -----------------------------------------------
 * Simple wrapper to validate stage type
 */
IGRstat VDvalIsStageTypeValid(IGRchar *stageType)
{
  VDASSERT_FN("VDvalIsStageTypeValid");
  IGRstat retFlag = 0;

  TGRid stageID;
  
  // Arg check
  VDASSERTW(stageType && *stageType);
  
  VDvalGetStagingStage(stageType,&stageID);
  if (stageID.objid == NULL_OBJID) goto wrapup;
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * Simple wrapper for min number kids
 */
void VDvalGetStageMinNumKids(IGRchar *stageType, IGRint *numKids)
{
  VDASSERT_FN("VDvalGetStageMinNumKids");

  TGRid stageID;
  IGRchab buf;
  
  // Arg check
  VDASSERTW(numKids); *numKids = 0;
  VDASSERTW(stageType && *stageType);
  
  VDvalGetStagingStage(stageType,&stageID);
  if (stageID.objid == NULL_OBJID) goto wrapup;

  VDctxGetTxtAtr(&stageID,"min_num_kids",buf);
  *numKids = atoi(buf);
  
 wrapup:
  return;
}
/* -----------------------------------------------
 * Simple wrapper for format
 */
void VDvalGetStageFmt(IGRchar *stageType, IGRchar *fmt)
{
  VDASSERT_FN("VDvalGetStageFmt");

  TGRid stageID;
  
  // Arg check
  VDASSERTW(fmt); *fmt = 0;
  VDASSERTW(stageType && *stageType);
  
  VDvalGetStagingStage(stageType,&stageID);
  if (stageID.objid == NULL_OBJID) goto wrapup;

  VDctxGetTxtAtr(&stageID,"fmt",fmt);
  
 wrapup:
  return;
}
/* -----------------------------------------------
 * Simple wrapper for description
 */
void VDvalGetStageDesc(IGRchar *stageType, IGRchar *desc)
{
  VDASSERT_FN("VDvalGetStageDesc");

  TGRid stageID;
  
  // Arg check
  VDASSERTW(desc); *desc = 0;
  VDASSERTW(stageType && *stageType);
  
  VDvalGetStagingStage(stageType,&stageID);
  if (stageID.objid == NULL_OBJID) goto wrapup;

  VDctxGetTxtAtr(&stageID,"desc",desc);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Validates the parent child relationship
 */
IGRstat VDvalIsParentStageTypeValid(IGRchar *stageType, IGRchar *parentStageType)
{
  VDASSERT_FN("VDvalIsParentStageTypeValid");

  IGRstat retFlag = 0;
 
  TGRid stagingIDs;

  TGRid *foundID;
  
  // Arg check
  VDASSERTW(stageType && *stageType);
  VDASSERTW(parentStageType);

  // Get the complete set
  VDvalGetStaging(&stagingIDs);
  if (stagingIDs.objid == NULL_OBJID) goto wrapup;
  
  // Use the indexed info
  VDctxAppTxtAtr(&info->findID,"type",  stageType);
  VDctxAppTxtAtr(&info->findID,"parent",parentStageType);
  
  foundID = VDctxSearchNodeList(&info->findID,&info->stageParentList,compareStageParent);
  if (foundID) retFlag = 1;
    
 wrapup:
  return retFlag;
}
  
/* -----------------------------------------------
 * Validates the platen code
 */
IGRstat VDvalIsStagePlatenValid(IGRchar *stageType, IGRchar *platen)
{
  VDASSERT_FN("VDvalIsStagePlatenValid");

  IGRstat retFlag = 0;
 
  TGRid stagingIDs;

  TGRid *foundID;
  
  // Arg check
  VDASSERTW(stageType && *stageType);
  VDASSERTW(platen);

  // Get the complete set
  VDvalGetStaging(&stagingIDs);
  if (stagingIDs.objid == NULL_OBJID) goto wrapup;
  
  // Use the indexed info
  VDctxAppTxtAtr(&info->findID,"type",  stageType);
  VDctxAppTxtAtr(&info->findID,"platen",platen);
  
  foundID = VDctxSearchNodeList(&info->findID,&info->stagePlatenList,compareStagePlaten);
  if (foundID) retFlag = 1;
 
 wrapup:
  return retFlag;
}
  
