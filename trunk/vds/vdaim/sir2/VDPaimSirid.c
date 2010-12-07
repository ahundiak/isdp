/***************************************************************************
 * I/AIM
 *
 * File:        sir2/VDPaimSirid.c
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimSirid.c,v $
 *      Revision 1.1.2.1  2004/03/29 17:26:53  ahundiak
 *      ah
 *
 *      Revision 1.3.2.8  2004/02/27 15:00:07  ahundiak
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/27/04  ah      Creation, For Model-Diagram Linkage
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDpdm.h"
#include "VDrisc.h"
#include "VDobj2.h"
#include "VDdom2.h"

#include "VDPdef.h"
#include "VDPaimUtil.h"
#include "VDPaimPostMan.h"


VDASSERT_FFN("VDPaimSirid.c");

extern VDclassid OPP_VDSroot_class_id;

static domNode s_diagramCacheNode = NULL;

static void processDiagramOS(domNode diagramCacheNode, VDosnum osnum);

static domNode getDiagramCacheNode()
{  
  IGRint  i,cnt;
  VDosnum *osnums = NULL;
  VDosnum  osnum;
  VDosnum  oscur;
  IGRchar  fileName[128];

  /* Make node if need one */
  if (s_diagramCacheNode) return s_diagramCacheNode;
  s_diagramCacheNode = domCreateDoc("diagram_cache");

  /* Need ref oss to check */
  VDosGetCurrentOS(&oscur);
  VDrefGetOSs(&cnt,&osnums);
  for(i = 0; i < cnt; i++) {

    osnum = osnums[i];
    VDosGetFileName(osnum,fileName);
    if ((osnum != oscur) && *fileName) {
      processDiagramOS(s_diagramCacheNode,osnum);
    }
  }

  /* For debugging */
  domSaveDocToFile(s_diagramCacheNode,"diagram_cache.xml");

wrapup:
  if (osnums) free(osnums);
  return s_diagramCacheNode;
}
/* ----------------------------------------------
 * Pulls all the diagram objects with valid id's
 * from the specified os
 */
static void processDiagramOS(domNode diagramCacheNode, VDosnum osnum)
{
  IGRstat msg;

  IGRint fileType;
  TGRid  dadID;

  TGRid *objIDs = NULL;
  TGRid *objID;
  IGRint objCnt = 0;
  IGRint i;

  IGRchar sirid      [128];
  IGRchar tag_number [128];
  IGRchar system_name[128];

  domNode itemNode;

  /* Verify have a diagram os */
  VDPaimGetDADCollector(osnum,0,&dadID);
  if (dadID.objid == NULL_OBJID) return;

  VDcollGetIntAttr(&dadID,SIR_FILE_TYP,&fileType);
  if (fileType != VDP_ASIR_FILE_TYPE_DIAGRAM) return;

  /* Grab the objects */
  VDobjInSpace(&msg, osnum, &objCnt, &objIDs, OPP_VDSroot_class_id);
  
  for(i = 0; i < objCnt; i++)
  {
    objID = &objIDs[i];

    /* Need siris, system_name and tag_number to be a reference */
    VDobjGetTxtAtr(NULL,objID,VDP_ISDP_ATTR_SIRID,      sirid);
    VDobjGetTxtAtr(NULL,objID,VDP_ISDP_ATTR_SYSTEM_NAME,system_name);
    VDobjGetTxtAtr(NULL,objID,VDP_ISDP_ATTR_TAG_NUMBER, tag_number);
    if (*sirid && *system_name && *tag_number)
    {
      itemNode = domCreateNode(diagramCacheNode,"item_node");
      domCreateIntAttrNode (itemNode,VDP_XML_ATTR_OBJID,      objID->objid);
      domCreateTextAttrNode(itemNode,VDP_XML_ATTR_SIRID,      sirid);
      domCreateTextAttrNode(itemNode,VDP_XML_ATTR_SYSTEM_NAME,system_name);
      domCreateTextAttrNode(itemNode,VDP_XML_ATTR_TAG_NUMBER, tag_number);
    }
  }


wrapup:
  if (objIDs) free(objIDs);
  return;
}

/* ----------------------------------------------
 * Call this to match a model object with it's
 * corresponding diagram object and extract the sirid
 */
void VDPaimGetDiagramSirid(TGRid *objID, IGRchar *sirid)
{
  domNode diagramCacheNode;
  domNode itemNode;

  IGRint i;

  IGRchar tag_number1 [128];
  IGRchar tag_number2 [128];
  IGRchar system_name1[128];
  IGRchar system_name2[128];

  /* Init */
  *sirid = 0;

  /* Object need system and tag */
  VDobjGetTxtAtr(NULL,objID,VDP_ISDP_ATTR_SYSTEM_NAME,system_name1);
  VDobjGetTxtAtr(NULL,objID,VDP_ISDP_ATTR_TAG_NUMBER, tag_number1);
  if ((*system_name1 == 0) || (*tag_number1 == 0)) goto wrapup;

  /* Get the cache */
  diagramCacheNode = getDiagramCacheNode();
  if (!diagramCacheNode) goto wrapup;

  /* Look through */
  for(i = 0; itemNode = domGetNthChildNode(diagramCacheNode,i); i++) {

    domGetTextAttrNodeValue(itemNode,VDP_XML_ATTR_SYSTEM_NAME,system_name2);
    domGetTextAttrNodeValue(itemNode,VDP_XML_ATTR_TAG_NUMBER, tag_number2);
    if (!strcmp(system_name1,system_name2) &&
        !strcmp(tag_number1, tag_number2 )) {

      domGetTextAttrNodeValue(itemNode,VDP_XML_ATTR_SIRID,sirid);
      goto wrapup;
    }
  }

wrapup:
  return;
}

void VDPaimDeleteDiagramCache()
{
  if (s_diagramCacheNode) {
    domFreeDoc(s_diagramCacheNode);
    s_diagramCacheNode = NULL;
  }
}

