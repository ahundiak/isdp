/***************************************************************************
 * I/AIM
 *
 * File:        sir2/VDPaimFileInfo.c
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimFileInfo.c,v $
 *      Revision 1.1.2.6  2004/03/29 17:26:53  ahundiak
 *      ah
 *
 *      Revision 1.1.2.5  2004/02/27 15:00:07  ahundiak
 *      ah
 *
 *      Revision 1.1.2.4  2003/06/11 13:31:19  ahundiak
 *      ah
 *
 *      Revision 1.1.2.3  2003/06/05 16:45:17  ahundiak
 *      ah
 *
 *      Revision 1.1.2.2  2003/06/04 18:13:42  ahundiak
 *      ah
 *
 *      Revision 1.1.2.1  2003/05/30 19:08:54  ahundiak
 *      ah
 *
 *      Revision 1.1  2003/05/27 13:35:59  ahundiak
 *      ah
 *
 *      Revision 1.1  2003/05/16 14:39:34  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/01/03  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"

#include "VDobj2.h"
#include "VDtest.h"
#include "VDdom2.h"
#include "VDship.h"

#include "VDos.h"
#include "VDpdm.h"
#include "VDrisc.h"

#include "VDPdef.h"
#include "VDPaimUtil.h"
#include "VDPaimPostMan.h"

VDASSERT_FFN("VDPaimFileInfo.I");

/* ----------------------------------------------
 * Utility routine for defaulting to the current os
 * if none was specified.
 */
static VDosnum getOS(VDosnum osnum)
{
  if (osnum == OM_K_NOT_AN_OS) 
  {
    VDosGetCurrentOS(&osnum);
  }
  return osnum;
}

/* -----------------------------------------------
 * Create a pdm info node
 */
static domNode createPdmInfoNode(VDosnum osnum, domNode parentNode)
{
  VDASSERT_FN("createPdmInfoNode");

  TVDpdmInfo pdmInfo;
  domNode pdmInfoNode = NULL;

  /* Arg check */
  VDASSERTW(parentNode);
  osnum = getOS(osnum);

  /* Grab the data */
  VDpdmGetPdmInfo(osnum,&pdmInfo);

  /* No node if no info */
  if (*pdmInfo.part == 0) goto wrapup;

  /* Create the node */
  pdmInfoNode = domCreateNode(parentNode,VDP_XML_NODE_ISDP_PDM);

  domCreateTextAttrNode(pdmInfoNode,VDP_XML_ATTR_PDM_CAT,  pdmInfo.catalog);
  domCreateTextAttrNode(pdmInfoNode,VDP_XML_ATTR_PDM_PART, pdmInfo.part);
  domCreateTextAttrNode(pdmInfoNode,VDP_XML_ATTR_PDM_REV,  pdmInfo.rev);
  domCreateTextAttrNode(pdmInfoNode,VDP_XML_ATTR_FILE_NAME,pdmInfo.filename);
  domCreateIntAttrNode (pdmInfoNode,VDP_XML_ATTR_FILE_KEY, pdmInfo.filekey);

  /* Done */
wrapup:
  return pdmInfoNode;
}

/* -----------------------------------------------
 * Execute a query then create a list of attr nodes
 * for each column in the result
 */
static domNode 
domCreateNodeFromPdmTable(domNode parentNode, 
                          char   *nodeName, 
                          char   *tableName, 
                          char   *where)
{
  VDASSERT_FN("domCreateNodeFromPdmTable");

  domNode recNode = NULL;

  TVDrisInfo colRisInfo;
  TVDrisInfo recRisInfo;

  int i,j;
  int recI,colI;

  char sql[256];

  /* Init */
  VDrisInitInfo(&colRisInfo);
  VDrisInitInfo(&recRisInfo);

  /* Arg check */
  VDASSERTW(parentNode);
  VDASSERTW(nodeName  && *nodeName);
  VDASSERTW(tableName && *tableName);

  /* Need to have a schema open */
  if (!VDrisIsSchemaOpen()) goto wrapup;

  /* Grab the columns */
  VDrisQryTableColumns(&colRisInfo,tableName);
  if (colRisInfo.rows == 0) goto wrapup;

  /* Build the data query */
  if (where == NULL) where = "";
  sprintf(sql,"SELECT * FROM %s %s",tableName,where);

  /* Query */
  VDrisQuery(&recRisInfo,sql);
  if (recRisInfo.rows == 0) goto wrapup;

  /* Just to be safe */
  VDASSERTW(colRisInfo.rows == recRisInfo.cols);

  /* Cycle Records */
  for(i = 0; i < recRisInfo.rows; i++)
  {
    /* Build the node */
    recNode = domCreateNode(parentNode,nodeName);
    recI = i * recRisInfo.cols;

    /* Cycle columns */
    for(j = 0; j < recRisInfo.cols; j++)
    {
      colI = j * colRisInfo.cols;

      domCreateTextAttrNode(recNode,
                            colRisInfo.buf[colI + VDRIS_COLI_COLUMNS_NAME],
                            recRisInfo.buf[recI + j]);
    }
  }

  /* Done */
wrapup:

  VDrisFreeInfo(&colRisInfo);
  VDrisFreeInfo(&recRisInfo);

  return recNode;
}

/* -----------------------------------------------
 * Get data from the DAD collector
 */
static domNode createDadInfoNode(VDosnum osnum, domNode parentNode)
{
  VDASSERT_FN("VDPaimCreateDADNode");

  domNode dadNode = NULL;

  TGRid dadID;
  TGRid drawingID;

  char  buf[128];
  int   val;

  /* Arg check */
  VDASSERTW(parentNode);
  osnum = getOS(osnum);

  /* Grab the collector */
  VDPaimGetDADCollector(osnum,0,&dadID);
  if (dadID.objid == NULL_OBJID) goto wrapup;

  dadNode = domCreateNode(parentNode,VDP_XML_NODE_ISDP_DAD);

  /* Just pull out one at a time for now */
  VDcollGetTextAttr(&dadID,SIR_MODCX_ID,buf);
  domCreateTextAttrNode(dadNode,VDP_XML_ATTR_MDC_ID,buf);

  VDcollGetTextAttr(&dadID,SIR_CNTX_ID,buf);
  domCreateTextAttrNode(dadNode,VDP_XML_ATTR_CONTEXT_ID,buf);

  VDcollGetTextAttr(&dadID,SIR_CNTX_NAME,buf);
  domCreateTextAttrNode(dadNode,VDP_XML_ATTR_CONTEXT_NAME,buf);

  VDcollGetTextAttr(&dadID,SIR_CNTX_TYP,buf);
  domCreateTextAttrNode(dadNode,VDP_XML_ATTR_CONTEXT_TYPE,buf);

  VDcollGetTextAttr(&dadID,SIR_CNTX_DESC,buf);
  domCreateTextAttrNode(dadNode,VDP_XML_ATTR_CONTEXT_DESC,buf);

  VDcollGetIntAttr(&dadID,SIR_FILE_TYP,&val);
  domCreateIntAttrNode(dadNode,VDP_XML_ATTR_FILE_TYPE,val);

  switch(val)
  {
    case M_FILE:   strcpy(buf,"M");   break;
    case D_FILE:   strcpy(buf,"D");   break;
    case A_FILE:   strcpy(buf,"A");   break;
    case ASM_FILE: strcpy(buf,"ASM"); break;
    case DM_FILE:  strcpy(buf,"DM");  break;
    default:       strcpy(buf,"UNKNOWN");
  }
  domCreateTextAttrNode(dadNode,VDP_XML_ATTR_FILE_TYPE_DESC,buf);

  VDcollGetTextAttr(&dadID,SIR_SEQ_NO,buf);
  domCreateTextAttrNode(dadNode,VDP_XML_ATTR_SEQ_NO,buf);

  /* This is acutally in the drawing info collector but
   * let's store it here just to confuse people
   *
   * Not going to use the standard VDgetDiagCtlPar because
   * that only works for the current os
   */
  VDPaimGetDrawingCollector(osnum,&drawingID);
  if (drawingID.objid != NULL_OBJID)
  {
    VDcollGetTextAttr(&drawingID,"pidStatus",buf);
  }
  else strcpy(buf,"-1");
  domCreateTextAttrNode(dadNode,VDP_XML_ATTR_IS_DIAGRAM,buf);

wrapup:

  return dadNode;
}

/* -----------------------------------------------
 * Get data from the AIM/SIR Database
 */
domNode VDPaimCreateAimInfoNode(VDosnum osnum, domNode parentNode)
{
  VDASSERT_FN("VDPaimCreateAimInfoNode");

  domNode    aimNode = NULL;
  TVDpdmInfo pdmInfo;
  TVDpdmInfo pdmAimInfo;

  TVDPaimBuf buf;

  int sts,cnt;

  char contextId  [128];
  char contextName[128];
  char contextDesc[128];
  char contextType[128];
  char contextRev [128];

  char mdcId [128];
  char mdcRev[128];

  char fileTypeDesc[128];
  char fileType[4];
 
  /* Arg check */
  VDASSERTW(parentNode);
  osnum = getOS(osnum);

  /* Container */
  aimNode = domCreateNode(parentNode,VDP_XML_NODE_ASIR_AIM_INFO);

  /* Must be connected */
  if(!IsPmeEnabled()) goto wrapup;

  /* Query */
  VDpdmGetPdmInfo(osnum,&pdmInfo);
  if (*pdmInfo.catalog == 0) goto wrapup;

  sts = VDPaimPostManRequest(&buf.len,&buf.data,
    "%d%s%s%s",
    VDP_MDC_RECONNECT,
    pdmInfo.catalog,
    pdmInfo.part,
    pdmInfo.rev);
  if (sts) goto wrapup;

  /* Lots of data */
  buf.iter = 0;
  VDPaimPostManExtract(buf.len,buf.data,&buf.iter,
    "%s%s%s%s%s%s%s",
    contextId,contextName,contextDesc,contextType,contextRev,
    mdcId,fileTypeDesc);

  /* File Type */
  strcpy(fileType,"-1");
  if (!strcmp(fileTypeDesc,"M"))   strcpy(fileType,"0");
  if (!strcmp(fileTypeDesc,"D"))   strcpy(fileType,"1");
  if (!strcmp(fileTypeDesc,"A"))   strcpy(fileType,"2");
  if (!strcmp(fileTypeDesc,"ASM")) strcpy(fileType,"3");
  if (!strcmp(fileTypeDesc,"DM"))  strcpy(fileType,"4");

  /* mdc rev requires it's own query */
  sts = VDPaimPostManRequest(&buf.len,&buf.data,
    "%d%s%s%s",
    VDP_GET_MDC_REV,
    pdmInfo.catalog,
    pdmInfo.part,
    pdmInfo.rev);

  if (sts) strcpy(mdcRev,"UNKNOWN");
  else
  {
    buf.iter = 0;
    VDPaimPostManExtract(buf.len,buf.data,&buf.iter,
      "%d%s",&cnt,mdcRev);
  }

  /* Get what aim think is cat part rev */
  sts = VDPaimPostManRequest(&buf.len,&buf.data,
    "%d%s",VDP_GET_CUR_REV,mdcId);
  if (sts) memset(&pdmAimInfo,0,sizeof(TVDpdmInfo));
  else
  {
    buf.iter = 0;
    VDPaimPostManExtract(buf.len,buf.data,&buf.iter,
      "%d%s%s%s",&cnt,pdmAimInfo.catalog,pdmAimInfo.part,pdmAimInfo.rev);
  }

  /* Create the attributes */
  domCreateTextAttrNode(aimNode,VDP_XML_ATTR_MDC_ID,        mdcId);
  domCreateTextAttrNode(aimNode,VDP_XML_ATTR_MDC_REV,       mdcRev);
  domCreateTextAttrNode(aimNode,VDP_XML_ATTR_CONTEXT_ID,    contextId);
  domCreateTextAttrNode(aimNode,VDP_XML_ATTR_CONTEXT_REV,   contextRev);
  domCreateTextAttrNode(aimNode,VDP_XML_ATTR_CONTEXT_NAME,  contextName);
  domCreateTextAttrNode(aimNode,VDP_XML_ATTR_CONTEXT_TYPE,  contextType);
  domCreateTextAttrNode(aimNode,VDP_XML_ATTR_CONTEXT_DESC,  contextDesc);
  domCreateTextAttrNode(aimNode,VDP_XML_ATTR_FILE_TYPE,     fileType);
  domCreateTextAttrNode(aimNode,VDP_XML_ATTR_FILE_TYPE_DESC,fileTypeDesc);

  domCreateTextAttrNode(aimNode,VDP_XML_ATTR_PDM_CAT,  pdmAimInfo.catalog);
  domCreateTextAttrNode(aimNode,VDP_XML_ATTR_PDM_PART, pdmAimInfo.part);
  domCreateTextAttrNode(aimNode,VDP_XML_ATTR_PDM_REV,  pdmAimInfo.rev);
 
wrapup:
  return aimNode;
}
/* -----------------------------------------------
 * Get data from the AIM/SIR Database
 */
domNode VDPaimCreateAimPlacementsNode(VDosnum osnum, domNode parentNode)
{
  VDASSERT_FN("VDPaimCreateAimPlacementsNode");

  domNode    postNodes = NULL;
  domNode    postNode;

  TVDpdmInfo pdmInfo;

  TVDPaimBuf buf;

  int sts,cnt,i,maxSeqNum;

  char mdcId  [128];
  char hullApp[128];
  char bufx   [128];

  char sirid[128];
  char objid[128];
  char className[128];
  char relType[128];

  char comp_tagx[128];
  char comp_path[128];

  /* Arg check */
  VDASSERTW(parentNode);
  osnum = getOS(osnum);

  /* Container */
  postNodes = domCreateNode(parentNode,VDP_XML_NODE_ASIR_PLACEMENTS);
 
  /* Must be connected */
  if(!IsPmeEnabled()) goto wrapup;

  /* Pdm Stuff */
  VDpdmGetPdmInfo(osnum,&pdmInfo);
  if (*pdmInfo.catalog == 0) goto wrapup;

  /* Query for MDC_ID */
  sts = VDPaimPostManRequest(&buf.len,&buf.data,
    "%d%s%s%s",
    VDP_GET_MDCOBID,
    pdmInfo.catalog,
    pdmInfo.part,
    pdmInfo.rev);
  if (sts) goto wrapup;

  buf.iter = 0;
  VDPaimPostManExtract(buf.len,buf.data,&buf.iter,
    "%d%s",&cnt,mdcId);
  if (*mdcId == 0) goto wrapup;

  /* Need the current hull_app */
  VDPaimFIGetHullApp(parentNode,hullApp);
  if (*hullApp == 0) goto wrapup;

  /* Query for placements */
  // printf("Placements %d '%s' '%s'\n",VDP_PLACMT_RECONNECT,mdcId,hullApp);

  sts = VDPaimPostManRequest(&buf.len,&buf.data,
    "%d%s%s",VDP_PLACMT_RECONNECT,mdcId,hullApp);
  if (sts) goto wrapup;

  buf.iter = 0;
  VDPaimPostManExtract(buf.len,buf.data,&buf.iter,"%d",&cnt);
  if (cnt == 0) goto wrapup;

  /* Now grab em */
  for(i = 0; i < cnt; i++)
  {
    VDPaimPostManExtract(buf.len,buf.data,&buf.iter,"%s%s%s%s%s%s",
      sirid,objid,comp_tagx,comp_path,className,relType);

    /* ------------------------------------------
     * Only worry about the model placements for now
     */
    if (!strcmp(relType,"M") || 0)
    {
      postNode = domCreateNode(postNodes,VDP_XML_NODE_ASIR_PLACEMENT);
 
      domCreateTextAttrNode(postNode,VDP_XML_ATTR_SIRID,sirid);
      domCreateTextAttrNode(postNode,VDP_XML_ATTR_OBJID,objid);
      domCreateTextAttrNode(postNode,VDP_XML_ATTR_ASIR_CLASS_NAME,className);
      domCreateTextAttrNode(postNode,VDP_XML_ATTR_ASIR_REL_TYPE,  relType);
      domCreateTextAttrNode(postNode,VDP_XML_ATTR_COMP_TAGX,      comp_tagx);
      domCreateTextAttrNode(postNode,VDP_XML_ATTR_COMP_PATH,      comp_path);
    }
    else {
      // printf("PLC %s %s %s %s %s %s\n", 
      // sirid,objid,comp_tagx,comp_path,className,relType);
    }
  }
  if (cnt)
  {
    VDPaimPostManExtract(buf.len,buf.data,&buf.iter,"%d",&maxSeqNum);
    sprintf(bufx,"%d",maxSeqNum);
    domSetNodeProp(postNodes,VDP_XML_ATTR_MAX_SEQ_NUM,bufx);
  }
   
  /* Done */
wrapup:
  return postNodes;
}

/* ----------------------------------------------
 * Helper routine to add predefined occ attrs
 */
void addOccAttrNode(domNode occNode,char *name,char *type, int size)
{
  domNode occAttrNode;
  char namex[32];
  int i;

  /* See if have an existing one */
  for(i = 0; occAttrNode = domGetNthChildNode(occNode,i); i++)
  {
    domGetNodeProp(occAttrNode,"name",namex);
    if (!strcmp(name,namex)) return;
  }
  /* Add it */
  occAttrNode = domCreateNode(occNode,"attr");
  domSetNodeTextProp(occAttrNode,"name",name);
  domSetNodeTextProp(occAttrNode,"type",type);
  domSetNodeIntProp (occAttrNode,"size",size);
 
  return;
}

/* ----------------------------------------------
 * Load occurence template
 */
domNode VDPaimCreateOccTemplateNode(domNode parentNode, char *templateName)
{
  int sts;
  int cnt,i;

  int   bufLen,iter;
  char *buf;

  char name[32];
  char type[32];
  int  size;

  domNode occNode = NULL;
  domNode occAttrNode;

  /* Execute the query */
  sts = VDPaimPostManRequest(&bufLen,&buf,"ds",VDP_GET_OCC_TEMPLATE,templateName);
  if (sts) goto wrapup;

  occNode = domCreateNode(parentNode, VDP_XML_NODE_ASIR_TEMPLATE);
  domSetNodeTextProp(occNode,VDP_XML_ATTR_ASIR_CLASS_NAME,templateName);
 
  /* Extract */
  iter = 0;
  VDPaimPostManExtract(bufLen,buf,&iter,"d",&cnt);

  /* Cycle through */
  for(i = 0; i < cnt; i++)
  {
    occAttrNode = domCreateNode(occNode,"attr");

    VDPaimPostManExtract(bufLen,buf,&iter,"%32s%32s%d",name,type,&size);

    domSetNodeTextProp(occAttrNode,"name",name);
    domSetNodeTextProp(occAttrNode,"type",type);
    domSetNodeIntProp (occAttrNode,"size",size);
  }  

  /* I'm a little bit reluctant to do this but the existing asir code
   * basically has 9 additional attributes which may or may not be in
   * the real template.
   * Add em if they are not
   */
  addOccAttrNode(occNode,VDP_XML_ATTR_MACRO_NAME ,"string",40);
  addOccAttrNode(occNode,VDP_XML_ATTR_SYSTEM_NAME,"string",40);
  addOccAttrNode(occNode,VDP_XML_ATTR_TAG_NUMBER, "string",40);
  addOccAttrNode(occNode,VDP_XML_ATTR_EQP_PARTNO, "string",40);
  addOccAttrNode(occNode,VDP_XML_ATTR_MINO,       "string",40);
  addOccAttrNode(occNode,VDP_XML_ATTR_CAGE,       "string",40);
  addOccAttrNode(occNode,VDP_XML_ATTR_EQP_NUMBER, "string",40);
  addOccAttrNode(occNode,VDP_XML_ATTR_SIRID,      "string",40);
  addOccAttrNode(occNode,VDP_XML_ATTR_FWD_FR,     "string",40);

wrapup:
  return occNode;
}
/* ----------------------------------------------
 * Load all occurence templates
 */
domNode VDPaimCreateOccTemplateNodes(domNode parentNode)
{
  domNode node = NULL;

  if (parentNode) node = domCreateNode(parentNode,VDP_XML_NODE_ASIR_TEMPLATES);
  else            node = domCreateDoc (           VDP_XML_NODE_ASIR_TEMPLATES);

  VDPaimCreateOccTemplateNode(node,"SrEquip");
  VDPaimCreateOccTemplateNode(node,"SrPiping");
  VDPaimCreateOccTemplateNode(node,"SrRway");
  VDPaimCreateOccTemplateNode(node,"SrHvac");
  VDPaimCreateOccTemplateNode(node,"SrGrpPlc");

  return node;
}

/* -----------------------------------------------
 * Grab a bunch of file info stuff
 */
static void getFileInfo(VDosnum osnum, domNode parentNode)
{
  VDASSERT_FN("getFileInfo");

  TVDpdmInfo pdmInfo;

  domNode catNode;
  domNode pdmInfoNode;

  char where[128];
  char buf  [256];

  TGRid drawingID;

  /* Arg check */
  VDASSERTW(parentNode);
  osnum = getOS(osnum);

  /* Make compatible with snapshot system */
  VDpdmGetPdmInfo(osnum,&pdmInfo);
  sprintf(buf,"sir::%d:sir:%d:",pdmInfo.filekey,pdmInfo.filekey);
  domSetNodeTextProp(parentNode,VDP_XML_ATTR_BASE_INFO,buf);
 
  /* Time stamp it */
  VDsysGetTimeStamp(buf);
  domSetNodeTextProp(parentNode,VDP_XML_ATTR_TIMESTAMP,buf);

  /* Go ahead and save the osnum */
  domSetNodeIntProp(parentNode,VDP_XML_ATTR_OSNUM,osnum);

  /* --------------------------------------------
   * Want the diagram control flag
   */  
  VDPaimGetDrawingCollector(osnum,&drawingID);
  if (drawingID.objid != NULL_OBJID)
  {
    VDcollGetTextAttr(&drawingID,"pidStatus",buf);
  }
  else strcpy(buf,"-1");

  domSetNodeTextProp(parentNode,VDP_XML_ATTR_IS_DIAGRAM,buf);

  /* Start with the always popular pdmInfo */
  pdmInfoNode = createPdmInfoNode(osnum,parentNode);
  if (!pdmInfoNode) goto wrapup;

  /* Grab everything out of the main pdm table and store it
   * in an array type format for now
   */
  sprintf(where,
    "WHERE n_itemname='%s' AND n_itemrev='%s'",
    pdmInfo.part,
    pdmInfo.rev);

  catNode = domCreateNodeFromPdmTable(parentNode,VDP_XML_NODE_ISDP_CATALOG,pdmInfo.catalog,where);

  /* Build the hull app string */
  /* 16 Feb 2004 - Updated to use ship_class.xml */
  if (catNode)
  {
    domNode attrNode;
    int  i;
    char hulln[16];
    char hullv[16];
    char hulla[128];

    char shipClassName[16];
    int  shipClassNameLen;
    int  hullNumMax;
    int  hullNum;

    VDshipGetClassName(shipClassName);
    shipClassNameLen = strlen(shipClassName);
    VDshipGetMaxHullNum(&hullNumMax);

    *hulla = 0;
    for(i = 0; attrNode = domGetNthChildNode(catNode,i); i++)
    {
      domGetNodeProp(attrNode,"name",hulln);
      if (!strncasecmp(hulln,shipClassName,shipClassNameLen))
      {
        domGetNodeProp(attrNode,"value",hullv);
        if (!strncasecmp(hullv,"Y",1))
        {
          if (*hulla) strcat(hulla,",");
          strcpy(hulln,hulln+shipClassNameLen);
          strcat(hulla,hulln);
          hullNum = atoi(hulln);
          if (hullNum == hullNumMax) strcat(hulla,"AF");
        }
      }
    }
    domCreateTextAttrNode(catNode,VDP_XML_ATTR_HULL_APP,hulla);
  }
 
  /* Want the state name */
  if (catNode)
  {
    char n_stateno  [32];
    char n_statename[32];

    TVDrisInfo stateRisInfo;

    domGetTextAttrNodeValue(catNode,VDP_XML_ATTR_STATE_NO,n_stateno);

    VDrisInitInfo(&stateRisInfo);
    sprintf(
      stateRisInfo.sql,
      "SELECT n_statename FROM nfmstates WHERE n_stateno = %s",
      n_stateno);
    VDrisQuery(&stateRisInfo,NULL);
    if (stateRisInfo.rows) strcpy(n_statename,stateRisInfo.buf[0]);
    else                   strcpy(n_statename,"UNKNOWN");
    VDrisFreeInfo(&stateRisInfo);

    domCreateTextAttrNode(catNode,VDP_XML_ATTR_STATE_NAME,n_statename);
  }

  /* Same thing for the SIR_PDM_TABLE */
  sprintf(where,
    "WHERE "
    "pdu_catalog='%s' AND "
    "pdu_part='%s'    AND "
    "pdu_revision='%s'",
    pdmInfo.catalog,
    pdmInfo.part,
    pdmInfo.rev);

  domCreateNodeFromPdmTable(parentNode,VDP_XML_NODE_ISDP_SIR_PDM,"sir_pdm_table",where);

  /* --------------------------------------------
   * Think always want the dad if have one
   */  
  createDadInfoNode(osnum,parentNode);

  /* Enabled items */
  VDPaimCreateEnabledItemNodeList(osnum,parentNode);

  /* Transaction List */
  VDPaimCreateTransactionNodeList(osnum,parentNode);

wrapup:

  return;
}

/* -----------------------------------------------
 * Grabs all the basic file information stuff
 * packs it into a node and returns it
 */
domNode VDPaimGetFileInfo(VDosnum osnum)
{
  domNode rootNode;

  rootNode = domCreateDoc(VDP_XML_NODE_ASIR_FILE_INFO);

  getFileInfo(osnum,rootNode);

  return rootNode;
}

/* -----------------------------------------------
 * Batch creation of file info
 */
void VDPaimTestFileInfo(TVDtestTestInfo *info)
{
  domNode rootNode = NULL;
  VDosnum osnum;

  char xmlFileName[64];

  /* Connect to pdm */
  VDrisOpenSchema(NULL);

  /* Everything goes into a tree */
  rootNode = domCreateDoc(VDP_XML_NODE_ASIR_FILE_INFO);

  /* Use current osnum */
  VDosGetCurrentOS(&osnum);
  getFileInfo(osnum,rootNode);

  /* Enabled items */
  // VDPaimCreateEnabledItemNodeList(osnum,rootNode);

  /* Transaction List */
  // VDPaimCreateTransactionNodeList(osnum,rootNode);

  /* Build a name */
  VDosGetFileName(osnum,xmlFileName);
  strcat(xmlFileName,".sir.xml");

  /* Close Up */
  domSaveDocToFile(rootNode,xmlFileName);
  domFreeDoc(rootNode);

  printf("Generated: %s\n",xmlFileName);

  /* Done */
  if (info) info->worked = 1;
  
wrapup:
  
  return;
}
/* ----------------------------------------------
 * Standard accessor functions for file info
 */
static domNode s_fileInfoNode;

/* ----------------------------------------------
 * Create a static copy of the file info node
 */
domNode VDPaimFIInitFileInfoNode(VDosnum osnum)
{
  s_fileInfoNode = VDPaimGetFileInfo(osnum);
  return s_fileInfoNode;
}
void VDPaimFIFreeFileInfoNode()
{
  if (s_fileInfoNode) domFreeDoc(s_fileInfoNode);
  s_fileInfoNode = NULL;
  return;
}
domNode VDPaimFIGetFileInfoNode()
{
  return s_fileInfoNode;
}

/* ----------------------------------------------
 * File information accessor routines
 */
int VDPaimFIGetDiagCtl(domNode fileInfoNode)
{
  char buf[16];

  /* Init */
  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return -1;

  /* Extract */
  domGetNodeProp(fileInfoNode,VDP_XML_ATTR_IS_DIAGRAM,buf);
  return atoi(buf);
}
int VDPaimFIGetFileType(domNode fileInfoNode)
{
  domNode dadInfoNode;
  int fileType = -1;

  /* Init */
  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return fileType;

  /* Dad node */
  dadInfoNode = domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ISDP_DAD,0);
  if (dadInfoNode == NULL) return fileType;

  /* Extract */
  domGetIntAttrNodeValue(dadInfoNode,VDP_XML_ATTR_FILE_TYPE,&fileType);
  return fileType;
}
char *VDPaimFIGetFileTypeDesc(domNode fileInfoNode, char *fileTypeDesc)
{
  domNode infoNode;

  /* Init */
  *fileTypeDesc = 0;
  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return fileTypeDesc;

  /* info node */
  infoNode = domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ASIR_AIM_INFO,0);
  if (!infoNode)
  {
    infoNode = domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ISDP_DAD,0);
  }
  if (infoNode == NULL) return fileTypeDesc;

  /* Extract */
  domGetTextAttrNodeValue(infoNode,VDP_XML_ATTR_FILE_TYPE_DESC,fileTypeDesc);
  return fileTypeDesc;
}
/* ----------------------------------------------
 * First try the asir node
 * if not use the dad node
 */
char *VDPaimFIGetModelContextID(domNode fileInfoNode, char *modelContextID)
{
  domNode infoNode;

  /* Init */
  *modelContextID = 0;
  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return modelContextID;

  /* Info node */
  infoNode = domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ASIR_AIM_INFO,0);
  if (!infoNode)
  {
    infoNode = domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ISDP_DAD,0);
  }
  if (infoNode == NULL) return modelContextID;

  /* Extract */
  domGetTextAttrNodeValue(infoNode,VDP_XML_ATTR_MDC_ID,modelContextID);
  return modelContextID;
}
char *VDPaimFIGetHullApp(domNode fileInfoNode, char *buf)
{
  domNode catInfoNode;

  /* Init */
  *buf = 0;

  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return buf;

  /* Catalog Node */
  catInfoNode = domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ISDP_CATALOG,0);
  if (catInfoNode  == NULL) return buf;

  /* Extract */
  return domGetTextAttrNodeValue(catInfoNode,VDP_XML_ATTR_HULL_APP,buf);
}
void VDPaimFIGetPdmInfo(domNode fileInfoNode, TVDpdmInfo *pdmInfo)
{
  domNode pdmInfoNode;

  char buf[32];

  /* Init */
  *pdmInfo->catalog = 0;

  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return;

  /* get the pdm node */
  pdmInfoNode = domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ISDP_PDM,0); 
  if (pdmInfoNode  == NULL) return;

  /* And xfer */
  domGetTextAttrNodeValue(pdmInfoNode,VDP_XML_ATTR_PDM_CAT,  pdmInfo->catalog);
  domGetTextAttrNodeValue(pdmInfoNode,VDP_XML_ATTR_PDM_PART, pdmInfo->part);
  domGetTextAttrNodeValue(pdmInfoNode,VDP_XML_ATTR_PDM_REV,  pdmInfo->rev);
  domGetTextAttrNodeValue(pdmInfoNode,VDP_XML_ATTR_FILE_NAME,pdmInfo->filename);

  domGetTextAttrNodeValue(pdmInfoNode,VDP_XML_ATTR_FILE_KEY,buf);
  pdmInfo->filekey = atoi(buf);
 
  return;
}
domNode VDPaimFIGetCatInfoNode(domNode fileInfoNode)
{
  /* Init */
  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return NULL;

  return domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ISDP_CATALOG,0);
}
domNode VDPaimFIGetPdmInfoNode(domNode fileInfoNode)
{
  /* Init */
  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return NULL;

  return domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ISDP_PDM,0);
}

domNode VDPaimFIGetDADInfoNode(domNode fileInfoNode)
{
  /* Init */
  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return NULL;

  return domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ISDP_DAD,0);
}
domNode VDPaimFIGetSirPdmInfoNode(domNode fileInfoNode)
{
  /* Init */
  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return NULL;

  return domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ISDP_SIR_PDM,0);
}
domNode VDPaimFIGetAsirPlacementsNode(domNode fileInfoNode)
{
  /* Init */
  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return NULL;

  return domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ASIR_PLACEMENTS,0);
}
domNode VDPaimFIGetAsirPlacementsBeforeNode(domNode fileInfoNode)
{
  /* Init */
  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return NULL;

  return domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ASIR_PLACEMENTS_BEFORE,0);
}
domNode VDPaimFIGetAsirPlacementsAfterNode(domNode fileInfoNode)
{
  /* Init */
  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return NULL;

  return domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ASIR_PLACEMENTS_AFTER,0);
}
domNode VDPaimFIGetPostObjectsFSINode(domNode fileInfoNode)
{
  domNode postObjectsNode;

  /* Init */
  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return NULL;

  postObjectsNode =  domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ISDP_POST_OBJECTS,0);
  if (!postObjectsNode) return NULL;

  return domGetNthChildNodeForName(postObjectsNode,VDP_XML_NODE_ISDP_POST_OBJECTS_FSI,0);
}
domNode VDPaimFIGetOccTemplateNode(domNode fileInfoNode, IGRchar *asirClassName)
{
  domNode templateNodes;
  domNode templateNode = NULL;

  int i;

  char buf[128];

  /* Init */
  if (fileInfoNode == NULL) fileInfoNode = s_fileInfoNode;
  if (fileInfoNode == NULL) return NULL;

  /* Get the templates node */
  templateNodes = domGetNthChildNodeForName(fileInfoNode,VDP_XML_NODE_ASIR_TEMPLATES,0);
  if (templateNodes == NULL)
  {
    templateNodes = domCreateNode(fileInfoNode,VDP_XML_NODE_ASIR_TEMPLATES);
  }

  /* Check for existing node */
  for(i = 0; templateNode = domGetNthChildNode(templateNodes,i); i++)
  {
    domGetNodeProp(templateNode,VDP_XML_ATTR_ASIR_CLASS_NAME,buf);
    if (!strcmp(asirClassName,buf)) goto wrapup;
  }

  /* Create it */
  templateNode = VDPaimCreateOccTemplateNode(templateNodes,asirClassName);

  /* Maybe should assert if no template found */
wrapup:
  return templateNode;

}
