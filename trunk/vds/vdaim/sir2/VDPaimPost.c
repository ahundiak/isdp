/***************************************************************************
 * I/AIM
 *
 * File:        sir2/VDPaimFileInfo.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimPost.c,v $
 *      Revision 1.3.2.9  2004/03/29 17:26:53  ahundiak
 *      ah
 *
 *      Revision 1.3.2.8  2004/02/27 15:00:07  ahundiak
 *      ah
 *
 *      Revision 1.3.2.7  2003/09/30 14:27:24  ahundiak
 *      ah
 *
 *      Revision 1.3.2.6  2003/09/04 15:17:35  ahundiak
 *      TR8027
 *
 *      Revision 1.3.2.5  2003/06/11 13:31:19  ahundiak
 *      ah
 *
 *      Revision 1.3.2.4  2003/06/06 20:44:19  ahundiak
 *      ah
 *
 *      Revision 1.3.2.3  2003/06/05 16:45:17  ahundiak
 *      ah
 *
 *      Revision 1.3.2.2  2003/06/04 18:13:42  ahundiak
 *      ah
 *
 *      Revision 1.3.2.1  2003/05/30 19:08:54  ahundiak
 *      ah
 *
 *      Revision 1.3  2003/05/30 13:33:25  ahundiak
 *      ah
 *
 *      Revision 1.2  2003/05/27 13:35:15  ahundiak
 *      ah
 *
 *      Revision 1.1  2003/05/16 14:39:34  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/13/01  ah      Creation
 * 09/04/03  ah      TR8027 Add VRPCComp to postable objects
 * 09/30/03  ah      CR8174 For HVAC, sir tag num == tag_number
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDtest.h"
#include "VDpdm.h"
#include "VDrisc.h"
#include "VDobj2.h"
#include "VDdom2.h"

#include "PDUuser.h"
#include "VDScheckdef.h"
#include "ACcheckin.h"

#include "VDPdef.h"
#include "VDPaimUtil.h"
#include "VDPaimPostMan.h"

#include "VDct1.h"
#include "VDct1Tree.h"

VDASSERT_FFN("VDPaimPost.c");

extern VDclassid OPP_VDSroot_class_id;

/* ----------------------------------------------
 * Utility routine for getting the next sirid for the file
 * Stand alone for now
 * Type = 1 regular single placement
 * Type = 2 Group placement
 */
IGRstat VDPaimGetNextSirid(VDosnum osnum, int type, char *sirid)
{
  VDASSERT_FN("VDPaimGetNextSirid");

  IGRstat retFlag = 0;

  TGRid   dadID;
  IGRint  seqNum;
  IGRchar buf[128];
  IGRchar typec;

  TVDpdmInfo pdmInfo;

  /* Arg Check */
  VDASSERTW(sirid); *sirid = 0;
  if (osnum == OM_K_NOT_AN_OS) VDosGetCurrentOS(&osnum);

  /* Get the sequence number */
  VDPaimGetDADCollector(osnum,0,&dadID);
  if (dadID.objid == NULL_OBJID) goto wrapup;

  VDcollGetTextAttr(&dadID,SIR_SEQ_NO,buf);
  seqNum = atoi(buf);
  if (seqNum < 1) goto wrapup;

  /* Need file key */
  VDpdmGetPdmInfo(osnum,&pdmInfo);
  if (pdmInfo.filekey < 1) goto wrapup;

  /* process type */
  switch(type)
  {
    case 2:  typec = 'G'; break;
    default: typec = '1';
  }

  /* Build the new one */
  sprintf(sirid,"%d-%04d-%c",pdmInfo.filekey,seqNum,typec);

  /* Update collector */
  sprintf(buf,"%d",seqNum + 1);
  VDcollSetTextAttr(&dadID,SIR_SEQ_NO,buf);
 
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Copy attribute from an isdp object
 * to a dom node
 */
static domNode addObjAtr(TGRid   *objID, 
                         IGRchar *objAttrName, 
                         IGRchar *xmlAttrName, 
                         domNode  objNode,
                         IGRchar *buf)
{
  IGRstat sts;
  domNode objAttrNode = NULL;

  *buf = 0;

  sts = VDobjGetTxtAtr(NULL,objID,objAttrName,buf);
  if (sts) {
    if (!strcasecmp(buf,"NULL")) *buf = 0;
    objAttrNode = domCreateTextAttrNode(objNode,xmlAttrName,buf);
  }
  return objAttrNode;
}
/* ----------------------------------------------
 * Queries an object for an occerence template
 * attribute and adds to the node
 *
 * The attribute is only added if the object actually has one
 */
static void addTemplateAttr(TGRid *objID, domNode templateAttrNode, domNode objNode)
{
  IGRstat sts;

  domNode objAttrNode;
  char name   [32];
  char ignore [32];
  char buf   [128];

  /* Get the name */
  domGetNodeProp(templateAttrNode,"name",name);
  if (*name == 0) goto wrapup;

  /* See if it should be ignored */
  domGetNodeProp(templateAttrNode,"ignore",ignore);
  if (*ignore == '1') goto wrapup;

  /* See if already have the value */
  objAttrNode = domGetAttrNode(objNode,name);
  if (objAttrNode) goto wrapup;

  /* And add it */
  objAttrNode = addObjAtr(objID,name,name,objNode,buf);

wrapup:
  return;
}

/* ----------------------------------------------
 * Pretty much follow the routine from sir
 */
#define VDP_XML_ATTR_IS_EQP "is_eqp"

void VDPaimComputeSirTagNum(domNode objNode)
{
  char SrTagNum[128];

  char eqp_number[128];
  char tag_number[128];

  char system_name[128];

  char asirClassName[128];

  /* Init */
  strcpy(SrTagNum,"");

  /* Check by class type */
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_ASIR_CLASS_NAME,asirClassName);

  /* Groups just use whatever user entered */
  if (!strcmp(asirClassName,VDP_SIR_GROUP_CLASS))
  {
    goto wrapup;
  }
  /* Equipment */
  if (!strcmp(asirClassName,VDP_SIR_EQUIP_CLASS))
  {
    domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_EQP_NUMBER,eqp_number);
    if (*eqp_number) strcpy(SrTagNum,eqp_number);
    domSetTextAttrNodeValue(objNode,VDP_XML_ATTR_SR_TAG_NUM,SrTagNum);
    goto wrapup;
  }
  /* CR8174 HVAC Components just use tag number */
  if (!strcmp(asirClassName,VDP_SIR_HVAC_CLASS))
  {
    domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_TAG_NUMBER, tag_number);
    if (*tag_number) strcpy(SrTagNum,tag_number);
    domSetTextAttrNodeValue(objNode,VDP_XML_ATTR_SR_TAG_NUM,SrTagNum);
    goto wrapup;
  }

  /* Must be distributative */
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_SYSTEM_NAME,system_name);
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_TAG_NUMBER, tag_number);
  if (*system_name && *tag_number)
  {
    sprintf(SrTagNum,"%s-%s",system_name,tag_number);
  }
  domSetTextAttrNodeValue(objNode,VDP_XML_ATTR_SR_TAG_NUM,SrTagNum);

wrapup:
  return;
}
/* ----------------------------------------------
 * Pretty much follow the routine from sir
 */
void VDPaimComputeLocation(domNode objNode)
{
  char fwdFrame   [128];
  char compartment[128];
  char location   [128];
  char loc_x      [128];
  char *p,*p2;
  double x;

  /* Start by adjusting the fwdFrNode */
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_LOC_X,loc_x);
  x = fabs(atof(loc_x)) / 1000.0;
  sprintf(fwdFrame,"%f",x);
  p = strchr(fwdFrame,'.');
  if (p) *p = 0;
  domSetTextAttrNodeValue(objNode,VDP_XML_ATTR_FWD_FR,fwdFrame);
  
  /* Make sure have a compartment */
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_COMPT_NUMBER,compartment);
  if (*compartment == 0) goto wrapup;

  /* Find the end of frame in the compartment */
  p = strchr(compartment,'-');
  if (p == NULL) goto wrapup;
  p2 = strchr(p+1,'-');
  if (p2 == NULL) goto wrapup;

  /* Make sure we don't already have one */
#if 0
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_LOCATION,location);
  if (*location) goto wrapup;
#endif
  /* Build it up */
  strcpy(location,compartment);
  p = strchr(location,'-');
  strcpy(p+1,fwdFrame);
  strcat(location,p2);

  domSetTextAttrNodeValue(objNode,VDP_XML_ATTR_LOCATION,location);
 
  /* printf("%s %s %s\n",compartment,location,fwdFrame); */

wrapup:
  return;
}

/* ----------------------------------------------
 * SIRID is kind of tricky.  It's really not used
 * anywhere in isdp that I can tell.  Even for sir, objid
 * is really the key for deleting.  
/* ----------------------------------------------
 * Process object for posting
 */
domNode VDPaimGetPostObjectData(domNode fileInfoNode, 
                                domNode fsiNode, 
                                domNode notFsiNode,
                                domNode plcsNode,
                                TGRid  *objID)
{
  domNode objNode = NULL;
  domNode objAttrNode;

  domNode templateNode;
  domNode templateAttrNode;

  IGRchar asirClassName[128];
  IGRchar isdpClassName[128];

  IGRchar dbTypeClassName[128];

  IGRchar fsiExpName[32];
  IGRchar sirid     [32];
  IGRchar siridx    [32];

  IGRint  isEqp;
  IGRint  fsi;
  IGRint  dbType;
  IGRint  i;
  IGRint  sts;
  IGRint  fileType;

  IGRdouble fsiDbl;

  IGRchar buf[128],*p;

  IGRchar   macro_name[128];
  IGRchar  system_name[128];
  IGRchar   tag_number[128];
  IGRchar   eqp_partno[128];
  IGRchar         mino[128];
  IGRchar         cage[128];
  IGRchar   eqp_number[128];
  IGRchar       fwd_fr[128];
  IGRchar compt_number[128];

  IGRchar   comp_tagx[128];
  IGRchar   comp_path[128];

  IGRchar SrTagNum[128];

  /* Arg check */
  if (objID == NULL)              goto wrapup;
  if (objID->objid == NULL_OBJID) goto wrapup;

  /* Grab the class */
  VDobjGetClassName(NULL,objID,isdpClassName);
  if (*isdpClassName == 0) goto wrapup;

  /* Filter by class name and get fsi exp at the same time */
  *fsiExpName = 0;
  if(!strcmp(isdpClassName,"VDequipment")) strcpy(fsiExpName,"SA_EXP:FSI_equip");
  if(!strcmp(isdpClassName,"VREquipment")) strcpy(fsiExpName,"SA_EXP:FSI_equip");
  if(!strcmp(isdpClassName,"VRRComp"))     strcpy(fsiExpName,"SA_EXP:FSI_rway" );
  if(!strcmp(isdpClassName,"VRRCComp"))    strcpy(fsiExpName,"SA_EXP:FSI_rway" );
  if(!strcmp(isdpClassName,"VRPComp"))     strcpy(fsiExpName,"SA_EXP:FSI_pipe" );
  if(!strcmp(isdpClassName,"VRPCComp"))    strcpy(fsiExpName,"SA_EXP:FSI_pipe" );
  if(!strcmp(isdpClassName,"VRHComp"))     strcpy(fsiExpName,"SA_EXP:FSI_hvac" );
  if(!strcmp(isdpClassName,"VRHCComp"))    strcpy(fsiExpName,"SA_EXP:FSI_hvac" );
  if (*fsiExpName == 0) goto wrapup;

  /* Nice flag for later */
  if (!strcmp(fsiExpName,"SA_EXP:FSI_equip")) isEqp = 1;
  else                                        isEqp = 0;

  /* Get the sir class */
  *asirClassName = 0;
  if (!strcmp(isdpClassName,"VDequipment")) strcpy(asirClassName,"SrEquip");
  if (!strcmp(isdpClassName,"VREquipment")) strcpy(asirClassName,"SrEquip");
  if (!strcmp(isdpClassName,"VRPComp"))     strcpy(asirClassName,"SrPiping");
  if (!strcmp(isdpClassName,"VRPCComp"))    strcpy(asirClassName,"SrPiping");
  if (!strcmp(isdpClassName,"VRHComp"))     strcpy(asirClassName,"SrHvac");
  if (!strcmp(isdpClassName,"VRHCComp"))    strcpy(asirClassName,"SrHvac");
  if (!strcmp(isdpClassName,"VRRComp"))     strcpy(asirClassName,"SrRway");
  if (!strcmp(isdpClassName,"VRRCComp"))    strcpy(asirClassName,"SrRway");

  /* Get the fsi status */
  if (isEqp) VDobjGetDblAtr(NULL,objID,fsiExpName,&fsiDbl);
  else
  {
    /* In the itf lab, getting fsi for dangles
     * generate annoying error messages
     */
    char comp_code[32];
    VDobjGetTxtAtr(NULL,objID,"comp_code",comp_code);
    if (strcmp(comp_code,"dangle")) 
    {
      VDobjGetDblAtr(NULL,objID,fsiExpName,&fsiDbl);
    } else fsiDbl = 0.0;
  }

  if (fsiDbl > .5) fsi = 1;
  else             fsi = 0;

  /* Ignore non-fsi for now, maybe want to flag eqp with fsi=1 */
  if (fsi == 0) goto wrapup;

  /* Ignore FIS items attached to a group placement tree */
  sts = VDct1GetModelObjectNode(NULL,objID,VDCT1_TREE_TYPE_GRP_PLACE,NULL,NULL,NULL);
  if (sts & 1) goto wrapup;

  /* Make the object */
  if (fsi) objNode = domCreateNode(fsiNode,   VDP_XML_NODE_ISDP_POST_OBJECT);
  else     objNode = domCreateNode(notFsiNode,VDP_XML_NODE_ISDP_POST_OBJECT);

  /* Standard attributes */
  domCreateIntAttrNode (objNode,"objid",          objID->objid);
  domCreateTextAttrNode(objNode,"isdp_class_name",isdpClassName);
  domCreateTextAttrNode(objNode,"asir_class_name",asirClassName);
  domCreateIntAttrNode (objNode,"fsi",            fsi);
  domCreateIntAttrNode (objNode,"is_eqp",         isEqp);
  
  /* If its not fsi then done */
  if (fsi == 0)
  {
    VDlogPrintW(1,"Non-FSI Object %d %s",objID->objid,isdpClassName);
    goto wrapup;
  }

  /* If dealing with a model file then bounce sirid
   * in diagram file
   */ 
  VDobjGetTxtAtr(NULL,objID,VDP_ISDP_ATTR_SIRID,sirid);
  fileType = VDPaimFIGetFileType(fileInfoNode);
  if (fileType == VDP_ASIR_FILE_TYPE_MODEL) {

    VDPaimGetDiagramSirid(objID,siridx);

    /* Be harsh, must have one */
    if (strcmp(sirid,siridx)) {
      strcpy(sirid,siridx);
      VDobjSetUserTextAttr(NULL,objID,VDP_ISDP_ATTR_SIRID,sirid);
    }
  }
  else {

    /* Assign if necessary */
    if (*sirid == 0)
    {
      /* Might want to check placement information */

      /* Just add one, */
      VDPaimGetNextSirid(objID->osnum,1,sirid);
      if (*sirid == 0)
      {
        VDlogPrintE(1,"*** Problem creating sirid");
        goto wrapup;
      }
      VDobjSetUserTextAttr(NULL,objID,VDP_ISDP_ATTR_SIRID,sirid);
    }
  }
  domCreateTextAttrNode(objNode,VDP_XML_ATTR_SIRID,sirid);

  /* ------------------------------------------
   * Map the db type onto an occurance template
   * The existing asir posting code does not even
   * Check for completely bogus values.  Probably
   * because the FSI check is going to preclude most things
   * from getting this far.
   *
   * I'll check for an expected value but not actually
   * change any of the mappings for now.
   */
  VDobjGetDbInfoType(NULL,objID,&dbType);
  domCreateIntAttrNode(objNode,"db_type",dbType);
  *dbTypeClassName = 0;
  switch(dbType)
  {
    case EQUIPMENT_OBJ:  strcpy(dbTypeClassName,"SrEquip");  break;
    case PIPING_OBJ:     strcpy(dbTypeClassName,"SrPiping"); break;
    case SCH_HVAC_OBJ:   strcpy(dbTypeClassName,"SrHvac");   break;
    case HVAC_OBJ:       strcpy(dbTypeClassName,"SrHvac");   break;
    case RWAY_OBJ:       strcpy(dbTypeClassName,"SrRway");   break;
    case PID_EQUIP_OBJ:  strcpy(dbTypeClassName,"SrPiping"); break;
    case PID_PIPING_OBJ: strcpy(dbTypeClassName,"SrPiping"); break;
  }
  if (strcmp(asirClassName,dbTypeClassName))
  {
    VDlogPrintE(1,"*** Mismatch between asir class name and db type class name");
    VDlogPrintE(1,"    ISDP %s, ASIR %s, db type %d %s",
      isdpClassName,asirClassName,dbType,dbTypeClassName);
    //goto wrapup;
  }

  /* --------------------------------------------
   * Never go around to makeing these attributes
   */
  VDctxGetCompTagx(objID,comp_tagx);
  VDctxGetCompPath(objID,comp_path);
  domCreateTextAttrNode(objNode,VDP_XML_ATTR_COMP_TAGX,comp_tagx);
  domCreateTextAttrNode(objNode,VDP_XML_ATTR_COMP_PATH,comp_path);

  /* Template attributes */
  templateNode = VDPaimGetOccTemplateNode(asirClassName);
  for(i = 0; (templateNode) &&
             (templateAttrNode = domGetNthChildNode(templateNode,i)); 
      i++)
  {
    addTemplateAttr(objID,templateAttrNode,objNode);
  }

  /* --------------------------------------------
   * A lot of variables seem to have NULL or null 
   * in them.  I don't see the point so clear them out
   */
  for(i = 0; objAttrNode = domGetNthChildNode(objNode,i); i++)
  {
    domGetAttrNodeValue(objAttrNode,buf);
    if (!strcasecmp("NULL"))
    {
      domSetAttrNodeValue(objAttrNode,"");
    }
  }
  /* Lookup compartment number, overide any attribute if found */
  VDPaimGetComptNumberForObject(objID, compt_number);
  if (*compt_number)
  {
    domSetTextAttrNodeValue(objNode,VDP_XML_ATTR_COMPT_NUMBER,compt_number);
  }

  /* Try building a sclsis location */
  VDPaimComputeLocation(objNode);

  /* --------------------------------------------
   * SrTagNum
   */
  VDPaimComputeSirTagNum(objNode);

  /* Extract cage and mino from eqp_partno */
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_CAGE,cage);
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_MINO,mino);
  if (isEqp)
  {
    domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_EQP_PARTNO,eqp_partno);
    strcpy(cage,eqp_partno);
    strcpy(mino,eqp_partno);
    p = strchr(cage,'-'); if (p) *p = 0;
    p = strchr(mino,'-'); if (p) strcpy(mino,p+1);
  }
  /* Should check length */
  strupr(cage);
  strupr(mino);
  domSetTextAttrNodeValue(objNode,VDP_XML_ATTR_CAGE,cage);
  domSetTextAttrNodeValue(objNode,VDP_XML_ATTR_MINO,mino);
  
wrapup:
  return objNode;
}

/* ----------------------------------------------
 * Start to grab objects for posting
 */
domNode VDPaimGetPostObjectsData(VDosnum osnum, domNode fileInfoNode, domNode parentNode)
{
  VDASSERT_FN("VDPaimGetPostObjectData");

  IGRstat sts,msg;

  TGRid *objIDs = NULL;
  TGRid *objID;
  IGRint objCnt = 0;
  IGRint i;

  domNode objNodes       = NULL;
  domNode objFsiNodes    = NULL;
  domNode objNotFsiNodes = NULL;

  domNode plcsNode;

  /* Init */
  if (osnum == OM_K_NOT_AN_OS) VDosGetCurrentOS(&osnum);

  if (parentNode) objNodes = domCreateNode(parentNode,VDP_XML_NODE_ISDP_POST_OBJECTS);
  else            objNodes = domCreateDoc (           VDP_XML_NODE_ISDP_POST_OBJECTS);

  objNotFsiNodes = domCreateNode(objNodes,VDP_XML_NODE_ISDP_POST_OBJECTS_NOT_FSI);
  objFsiNodes    = domCreateNode(objNodes,VDP_XML_NODE_ISDP_POST_OBJECTS_FSI);

  /* Reset diagram cache */
  VDPaimDeleteDiagramCache();

  /* Grab vds objects */
  VDobjInActiveSpace(&msg, &objCnt, &objIDs, OPP_VDSroot_class_id);
  if ((objCnt == 0) || (objIDs == NULL))
  {
    VDlogPrintW(1,"*** No VDSroot objects found");
    goto wrapup;
  }
  VDlogPrintI(0,"### Found %d VDSroot objects",objCnt);

  /* Pull out placements node if have one */
  plcsNode = VDPaimFIGetAsirPlacementsNode(fileInfoNode);
 
  /* Cycle through */
  for(i = 0; i < objCnt; i++)
  {
    objID = &objIDs[i];
    VDPaimGetPostObjectData(fileInfoNode,objFsiNodes,objNotFsiNodes,plcsNode,objID);
  }
  VDPaimGetGroups(osnum,objFsiNodes);


wrapup:
  if (objIDs) free(objIDs);

  return objFsiNodes;
}

/* ----------------------------------------------
 * Batch testing 
 */
extern struct PDUuser   *user;
extern char   VDSenvir_name[];
extern char  *strdup(const char *s1);

void VDPaimTestPostData(TVDtestTestInfo *info)
{
  VDASSERT_FN("VDPaimTestPostData");
  IGRstat sts;

  VDosnum osnum;

  IGRchar *sirServerName;
  IGRchar *pdmSchema;

  TVDPaimServerInfo serverInfo;

  domNode fileInfoNode;
  domNode placementsNode;
  domNode postObjectsNode;

  /* Log it */
  VDlogOpenCat("post_test.log");

  /* Use current osnum */
  VDosGetCurrentOS(&osnum);

  /* Connect to pdm */
  VDrisOpenSchema(NULL);
  if (!VDrisIsSchemaOpen())
  {
    VDlogPrintE(1,"*** Failed to open ris schema\n");
    goto wrapup;
  }
  VDlogPrintI(1,"### Opened ris schema");

  /* Fake a pdu login */
  user = calloc(1,sizeof(struct PDUuser));
  user->username = strdup("axh700");
 
  pdmSchema = getenv("ISDP_SCHEMA");
  if (pdmSchema == NULL) goto wrapup;

  user->environment = strdup(pdmSchema);
  sprintf(VDSenvir_name,"pdme_%s",pdmSchema);

  /* Connect to aim */
  sirServerName = getenv("ISDP_SIR_SERVER");
  if (sirServerName)
  {
    sts = VDPaimPostManConnect(sirServerName);
    if (sts)
    {
      VDlogPrintE(1,"Failed to connect to aim server %s",sirServerName);
      /* goto wrapup; */
    }
    else
    {
      ConnectAIM(SIR);
      EnablePME(1);
      VDPaimGetServerInfo(serverInfo.user,serverInfo.server,serverInfo.env);
      VDlogPrintI(1,"### Connected to aim server %s %s",
        serverInfo.server,serverInfo.env);
    }
  }
  /* Main information */
  fileInfoNode = VDPaimFIInitFileInfoNode(osnum);

  /* Some requested cleanup */
  VDPaimDeleteItemCache();
  VDPaimDeleteFSIExpressions();

  /* --------------------------------------------
   * Add a holder for any template objects 
   * just to keep posted data near the end
   */
  domCreateNode(fileInfoNode,VDP_XML_NODE_ASIR_TEMPLATES);

  /* Add objects */
  postObjectsNode = VDPaimGetPostObjectsData(osnum,fileInfoNode,fileInfoNode);

  /* Data from aim */
  VDPaimCreateAimInfoNode      (osnum,fileInfoNode);
  placementsNode = VDPaimCreateAimPlacementsNode(osnum,fileInfoNode);
  domSetNodeProp(placementsNode,"state","before");

  /* Now actually post the stuff */
  VDPaimPostObjects(fileInfoNode,placementsNode,postObjectsNode);

  placementsNode = VDPaimCreateAimPlacementsNode(osnum,fileInfoNode);
  domSetNodeProp(placementsNode,"state","after");

  /* Close Up */
  domSaveDocToFile(fileInfoNode,"file_info.xml");
  VDPaimFIFreeFileInfoNode();

  /* Done */
  if (info) info->worked = 1;

wrapup:
  VDlogCloseCat("post_test.log");
  return;
}


