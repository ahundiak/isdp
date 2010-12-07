/***************************************************************************
 * I/AIM
 *
 * File:        sir2/VDPaimPost2.c
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimPost2.c,v $
 *      Revision 1.1.2.7  2004/03/29 17:26:53  ahundiak
 *      ah
 *
 *      Revision 1.1.2.6  2004/02/27 15:00:07  ahundiak
 *      ah
 *
 *      Revision 1.1.2.5  2003/08/21 14:32:51  ahundiak
 *      ah
 *
 *      Revision 1.1.2.4  2003/06/11 13:31:19  ahundiak
 *      ah
 *
 *      Revision 1.1.2.3  2003/06/06 20:44:19  ahundiak
 *      ah
 *
 *      Revision 1.1.2.2  2003/06/05 16:45:17  ahundiak
 *      ah
 *
 *      Revision 1.1.2.1  2003/06/04 18:13:42  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/02/03  ah      Creation
 * 08/14/03  ah      TR7971 - Crash due to SIR error message overrunning buffer
 *                          - Also check for attribute values being too long
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDtest.h"
#include "VDpdm.h"
#include "VDrisc.h"
#include "VDobj2.h"
#include "VDdoom.h"
#include "VDdom2.h"

#include "PDUuser.h"
#include "VDScheckdef.h"
#include "ACcheckin.h"

#include "VDPdef.h"
#include "VDPaimUtil.h"
#include "VDPaimPostMan.h"

VDASSERT_FFN("VDPaimPost2.c");

static int   s_numPosted;
static int   s_numErrors;
static FILE *s_logFile;

/* ----------------------------------------------
 * Just something to print out a message
 */
static void printMsg(char *msg)
{
  puts(msg);
  if (s_logFile) fputs(msg,s_logFile);
  return;
}
/* ----------------------------------------------
 * Utility for getting tag infor from a node
 */
void VDPaimGetNodeTag(domNode node, TVDtag *tag)
{
  char comp_tagx[128];
  char *p;

  tag->num = 0;
  tag->ver = 0;

  domGetTextAttrNodeValue(node,VDP_XML_ATTR_COMP_TAGX,comp_tagx);

  p = comp_tagx; if (*p == 0) return;

  p = strchr(p+1,':'); if (!p) return;
  p = strchr(p+1,':'); if (!p) return;
  tag->num = atoi(p+1);
  p = strchr(p+1,':'); if (!p) return;
  tag->ver = atoi(p+1);

  return;
}

/* ----------------------------------------------
 * Delete a placement
 */
static void deletePlacement(domNode fileInfoNode, domNode placementNode)
{
  int  sts;
  int  code       = VDP_POST_PLACMNT;
  int  actionCode = VDP_POST_PLACMNT_DELETE;

  char fileTypeDesc [32];
  char asirClassName[32];
  char mdcID[64];
  char objid[32];

  int   bufLen;
  char *buf;

  char prefix[32];
  char msg[256];

  /* Grab some data */
  VDPaimFIGetFileTypeDesc  (fileInfoNode,fileTypeDesc);
  VDPaimFIGetModelContextID(fileInfoNode,mdcID);

  domGetTextAttrNodeValue(placementNode,VDP_XML_ATTR_OBJID,objid);
  domGetTextAttrNodeValue(placementNode,VDP_XML_ATTR_ASIR_CLASS_NAME,asirClassName);

  sprintf(prefix,"F S I : [2/%s] ",objid);
#if 0
  printf("Do Delete %s\n",objid);
  if (1) goto wrapup;
#endif
  /* And do it */
  sts = VDPaimPostManRequest(&bufLen,&buf,
    "ddssss",
    code,actionCode,
    fileTypeDesc,
    objid,mdcID,
    asirClassName);

  if (!sts)
  {
    sprintf(msg,"%s Object is deleted\n",prefix);
    printMsg(msg);
    s_numPosted++;
    return;
  }
  sprintf(msg,"%s Error while deleting object,\n %s\n",
    prefix,VDPaimPostManGetErrorMsg());
  printMsg(msg);
  s_numErrors++;

wrapup:
  return;
}

/* ----------------------------------------------
 * Bounces placements against post objects
 */
static void bouncePlacementsAgainstPostObjects(
  domNode fileInfoNode, 
  domNode plcsNode,
  domNode objsNode)
{
  domNode plcNode;
  domNode objNode;

  TVDtag plcTag;
  TVDtag objTag;

  int i,j,deleteFlag;

  int plcObjid,objObjid;

  /* Check that we have placements */
  if (!plcsNode) return;

  /* Cycle through */
  for(i = 0; plcNode = domGetNthChildNode(plcsNode,i); i++)
  {
    VDPaimGetNodeTag(plcNode,&plcTag);

    domGetIntAttrNodeValue(plcNode,VDP_XML_ATTR_OBJID,&plcObjid);

    deleteFlag = 1;
    for(j = 0; 
        (objsNode) && 
        (objNode = domGetNthChildNode(objsNode,j)); 
        j++)
    {
      VDPaimGetNodeTag(objNode,&objTag);
      if (objTag.num == plcTag.num) deleteFlag = 0;

      domGetIntAttrNodeValue(objNode,VDP_XML_ATTR_OBJID,&objObjid);

      if ((plcObjid == objObjid) && (plcTag.num == 0) && (plcObjid != 0))
      {
        deleteFlag = 0;
      }
 
    }
    if (deleteFlag)
    {
      deletePlacement(fileInfoNode,plcNode);
    }
  }
}
/* ----------------------------------------------
 * Add attribute to the buffer
 */
static void addInt(TVDPaimBuf *buf, int value)
{
  int len = sizeof(int);

  if ((buf->len + len) >= buf->max)
  {
    buf->max += buf->inc;
    buf->data = (char *)realloc(buf->data,buf->max);
  }
  memcpy(buf->data + buf->len,&value,len);
  buf->len += len;
  return;
}
static void addTxt(TVDPaimBuf *buf, char *value)
{
  int len = strlen(value) + 1;

  if ((buf->len + len) >= buf->max)
  {
    buf->max += buf->inc;
    buf->data = (char *)realloc(buf->data,buf->max);
  }
  memcpy(buf->data + buf->len,value,len);
  buf->len += len;
  return;
}
  
/* ----------------------------------------------
 * Insert or modify a placement
 */
static int doPlacement(domNode fileInfoNode, domNode objNode, int opFlag)
{
  int retFlag = 0;

  int   sts,mfail;
  char *errmsg = NULL;
  char  msg[256];

  int  code       = VDP_POST_PLACMNT;
  int  actionCode = 0;
  int  i,cnt;

  TVDPaimBuf inBuf;
  TVDPaimBuf outBuf;

  char buf  [128];
  char qty  [128];
  char mdcID[128];
  char cage [128];
  char mino [128];
  char objid[128];
  char sirid[128];
  char name [128];

  char isdpClassName[128];
  char asirClassName[128];

  domNode         objAttrNode;
  domNode tplNode,tplAttrNode;

  char size[32];
  char warn[128];
  int  sizex;

  /* Init */
  memset( &inBuf,0,sizeof(TVDPaimBuf));
  memset(&outBuf,0,sizeof(TVDPaimBuf));
  inBuf.inc = 1000;
  *warn = 0;

  /* -------------------------------------------- 
   * Template node
   */
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_ASIR_CLASS_NAME,asirClassName);
  tplNode = VDPaimGetOccTemplateNode(asirClassName);
  if(tplNode == NULL) goto wrapup;

  /* Create or modify */
  switch(opFlag)
  {
    case 1: actionCode = VDP_POST_PLACMNT_CREATE; break;
    case 2: actionCode = VDP_POST_PLACMNT_MODIFY; break;
    default: goto wrapup;
  }
  addInt(&inBuf,code);
  addInt(&inBuf,actionCode);

  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_COMP_TAGX,buf);
  /* printf("Placing %d %s\n",actionCode,buf); */

  /* Some standard data */
  VDPaimFIGetFileTypeDesc(fileInfoNode,buf);
  addTxt(&inBuf,buf);

  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_OBJID,objid);
  addTxt(&inBuf,objid);

  VDPaimFIGetModelContextID(fileInfoNode,mdcID);
  addTxt(&inBuf,mdcID);

  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_ISDP_CLASS_NAME,isdpClassName);
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_ASIR_CLASS_NAME,asirClassName);
  addTxt(&inBuf,asirClassName);

  /* --------------------------------------------
   * The tag number is the only editable attribute
   * in the header so we need to check it's size
   */
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_SR_TAG_NUM,buf);

  /* Check size */
  tplAttrNode = domGetAttrNode(tplNode,VDP_XML_ATTR_SR_TAG_NUM);
  if (tplAttrNode)
  {
    domGetNodeProp(tplAttrNode,"size",size);
    sizex = atoi(size);
    if (strlen(buf) > sizex)
    {
      sprintf(warn,"WARNING: %s truncated to %d characters\n",
        VDP_XML_ATTR_SR_TAG_NUM,sizex);
      *(buf+sizex) = 0;
    }
  }
  addTxt(&inBuf,buf);

  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_MINO,mino);
  addTxt(&inBuf,mino);

  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_CAGE,cage);
  addTxt(&inBuf,cage);

  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_SIRID,sirid);
  addTxt(&inBuf,sirid);

  /* --------------------------------------------
   * 27 Feb 2004 - Make sure have sirid, some model
   * objects might slip through
   */
  if (*sirid == 0) {
    sprintf (msg,"F S I  : [2/%s] %s %s %s NO SIRID\n",objid,isdpClassName,cage,mino);
    goto wrapup;
  }

  addTxt(&inBuf,mdcID);

  /* Quantity */
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_SR_QUANTITY,qty);
  if (*qty == 0) strcpy(qty,"1");
  addTxt(&inBuf,qty);

  /* Message */
  sprintf (msg,"F S I  : [2/%s] %s %s %s %s %s\n",objid,isdpClassName,cage,mino,sirid,qty);
  printMsg(msg);

  if (*warn) printMsg(warn);

  /* One pass to get number of occ attributes */
  cnt = 0;
  for(i = 0; tplAttrNode = domGetNthChildNode(tplNode,i); i++)
  {
    domGetNodeProp(tplAttrNode,"sir_nvp",buf);
    if (*buf == '1')
    {
      domGetNodeProp(tplAttrNode,"name",name);
      objAttrNode = domGetAttrNode(objNode,name);
      if (objAttrNode) cnt++;
    }
  }
  addInt(&inBuf,cnt);

  /* Name value pairs */
  for(i = 0; tplAttrNode = domGetNthChildNode(tplNode,i); i++)
  {
    domGetNodeProp(tplAttrNode,"sir_nvp",buf);
    if (*buf == '1')
    {
      domGetNodeProp(tplAttrNode,"name",name);
      objAttrNode = domGetAttrNode(objNode,name);
      if (objAttrNode) 
      {
        /* The name */
        domGetNodeProp(objAttrNode,"name",buf);
        addTxt(&inBuf,buf);

        /* The value */
        domGetNodeProp(objAttrNode,"value",buf);

        /* Check size */
        domGetNodeProp(tplAttrNode,"size",size);
        sizex = atoi(size);
        if (strlen(buf) > sizex)
        {
          sprintf(msg,"WARNING: %s truncated to %d characters\n",name,sizex);
          printMsg(msg);
          *(buf+sizex) = 0;
        }
        addTxt(&inBuf,buf);
      }
    }
  }
#if 0
  printf("Do Placement %d %s\n",opFlag,objid);
  if (1) goto wrapup;
#endif
  /* Do It */
  mfail = 0;
  sts = POSTMAN_REQUEST_ON_CLIX(inBuf.len,   inBuf.data,
                               &outBuf.len,&outBuf.data,
                               &mfail,&errmsg);

  if (sts || mfail)
  {
    char mfail_msg[128];

    s_numErrors++;

    VDgetSrError(mfail,mfail_msg);

    if (!errmsg) errmsg = "NO OTHER ERROR MESSAGE";
    snprintf(msg,sizeof(msg) - 1, "*** Posting failed %d %d %s\n%s\n",
      sts,mfail,mfail_msg,errmsg);
    printMsg(msg);
    goto wrapup;
  }
  s_numPosted++;

  /* Done */
  retFlag = 1;

wrapup:
  if (inBuf.data) free(inBuf.data);
  return retFlag;
}

/* ----------------------------------------------
 * Bounces postPbjects against placements
 */
static void bouncePostObjectsAgainstPlacements(
  domNode fileInfoNode, 
  domNode plcsNode,
  domNode objsNode)
{
  domNode plcNode, objNode;
  TVDtag  plcTag,  objTag;
  int     plcObjid,objObjid;

  int i,j,opFlag;

  /* Check that we have post objects */
  if (!objsNode) return;

  /* Cycle through */
  for(i = 0; objNode = domGetNthChildNode(objsNode,i); i++)
  {
    VDPaimGetNodeTag(objNode,&objTag);
    domGetIntAttrNodeValue(objNode,VDP_XML_ATTR_OBJID,&objObjid);
    opFlag = 1;
    for(j = 0; 
        (plcsNode) && 
        (plcNode = domGetNthChildNode(plcsNode,j)); 
        j++)
    {
      /* Check Tag */
      VDPaimGetNodeTag(plcNode,&plcTag);
      if (objTag.num == plcTag.num) 
      {
        if (objTag.ver == plcTag.ver) opFlag = 0;
        else                          opFlag = 2;
      }
      /* Check objid if no tag */
      domGetIntAttrNodeValue(plcNode,VDP_XML_ATTR_OBJID,&plcObjid);
      if ((plcObjid == objObjid) && (plcTag.num == 0) && (plcObjid != 0))
      {
        opFlag = 2;
      }
    }
    if (opFlag)
    {
      doPlacement(fileInfoNode,objNode,opFlag);
    }
  }
}

/* ----------------------------------------------
 * Actually post the obejcts given a full
 * file info node
 */
IGRstat VDPaimPostObjects(domNode fileInfoNode, 
                          domNode placementsNode, 
                          domNode postObjectsNode)
{
  VDASSERT_FN("VDPaimPostObjects");

  IGRstat retFlag = 1;

  /* Deletes */
  bouncePlacementsAgainstPostObjects(fileInfoNode,placementsNode,postObjectsNode);

  /* Inserts and Updates */
  bouncePostObjectsAgainstPlacements(fileInfoNode,placementsNode,postObjectsNode);

  /* Done */
  return retFlag;

wrapup:
  return retFlag;
}
/* ----------------------------------------------
 * Interface to the existing post command
 */
IGRstat VDPaimCmdPostObjects(FILE *logFile, domNode fileInfoNode, int *numPosted, int *numErrors)
{
  VDASSERT_FN("VDPaimCmdPostObjects");

  IGRstat retFlag = 0;
  VDosnum osnum;

  domNode placementsNode;
  domNode postObjectsNode;
  char buf[128];
  char msg[128];

  /* Arg checks */
  if (logFile) s_logFile = logFile;
  else         s_logFile = stdout;
  *numPosted = 0;
  *numErrors = 0;
  if (fileInfoNode == NULL) goto wrapup;

  s_numPosted = 0;
  s_numErrors = 0;

  /* Use current osnum */
  VDosGetCurrentOS(&osnum);

  /* --------------------------------------------
   * Add a holder for any template objects 
   * just to keep posted data near the end
   */
  domCreateNode(fileInfoNode,VDP_XML_NODE_ASIR_TEMPLATES);

  /* Data from aim */
  VDPaimCreateAimInfoNode(osnum,fileInfoNode);
  placementsNode = VDPaimCreateAimPlacementsNode(osnum,fileInfoNode);
  domSetNodeProp(placementsNode,"state","before");

  /* Add objects */
  postObjectsNode = VDPaimGetPostObjectsData(osnum,fileInfoNode,fileInfoNode);

  /* Now actually post the stuff */
  VDPaimPostObjects(fileInfoNode,placementsNode,postObjectsNode);

  placementsNode = VDPaimCreateAimPlacementsNode(osnum,fileInfoNode);
  domSetNodeProp(placementsNode,"state","after");

  /* Close Up */
  VDosGetFileName(osnum,buf);
  strcat(buf,".sirpost.xml");
  domSaveDocToFile(fileInfoNode,buf);

  // VDPaimUpdatePostTimestamp(fileInfoNode,s_numErrors,1);

  sprintf (msg,"%d Objects Posted, %d Errors.\n",s_numPosted,s_numErrors);
  printMsg(msg);

  *numPosted = s_numPosted;
  *numErrors = s_numErrors;

  /* Done */
  retFlag = 1;

wrapup:
  s_logFile = NULL;
  return retFlag;
}

/* ----------------------------------------------
 * Update the timestamp following a post
 */
IGRstat VDPaimUpdatePostTimestamp(domNode fileInfoNode, int numErrors, int postXmlFile)
{
  IGRstat retFlag = 0;

  domNode pdmInfoNode;

  char sql[256];
  char ts [32];
  int  fileKey;
  int  blobKey = 0;

  /* Arg check */
  if (fileInfoNode == NULL) goto wrapup;

  /* Get the file key */
  pdmInfoNode = VDPaimFIGetPdmInfoNode(fileInfoNode);
  if (pdmInfoNode == NULL) goto wrapup;
  domGetIntAttrNodeValue(pdmInfoNode,VDP_XML_ATTR_FILE_KEY,&fileKey);
  if (fileKey < 1) goto wrapup;

  /* Timestamp */
  domGetNodeProp(fileInfoNode,VDP_XML_ATTR_TIMESTAMP,ts);

  /* Blob the xml file if desired */
  if (postXmlFile)
  {
    VDrisGetNextKey(VDRIS_TBLN_BLOBS, &blobKey);
    domSaveDocToFile(fileInfoNode,"/usr/tmp/sir_blob.xml");
    VDrisInsertBlobRecord(blobKey,"/usr/tmp/sir_blob.xml",0,NULL);
    remove("/usr/tmp/sir_blob.xml");
  }

  /* Reset any existing records */
  sprintf(sql,"UPDATE sir_post SET latest=0 WHERE file_key=%d",fileKey);
  VDrisExecute(sql);

  /* Add new record */
  sprintf(sql,
    "INSERT INTO sir_post VALUES(%d,2,%d,'%s',%d)",
    fileKey,numErrors,ts,blobKey);
  VDrisExecute(sql);

wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * Store the tree in a doom object
 */
IGRstat VDPaimCreateDoomFromTree(domNode treeNode, TGRid *doomID)
{
  IGRstat retFlag = 0;
  char *buf;
  TGRid doomIDx;

  /* Arg check */
  if (doomID == NULL) doomID = &doomIDx;
  doomID->objid = NULL_OBJID;
  if (treeNode == NULL) goto wrapup;

  /* Make a string */
  domSaveDocToBuf(treeNode,&buf);
  if (*buf == NULL) goto wrapup;

  /* Add to doom */
  VDdoomCreateDoomObject(NULL,doomID);
  if (doomID->objid == NULL_OBJID) goto wrapup;
  VDdoomSetData(doomID,-1,buf);
 
wrapup:
  return retFlag;
}


