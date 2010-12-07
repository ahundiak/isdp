/***************************************************************************
 * I/AIM
 *
 * File:        sir2/VDPaimReconn.c
 *
 * Description: Reconnect a DAD to aim
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimReconn.c,v $
 *      Revision 1.1.2.2  2004/02/27 15:00:07  ahundiak
 *      ah
 *
 *      Revision 1.1.2.1  2003/09/10 15:56:22  ahundiak
 *      ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/09/03  ah      Creation, TR8041
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDtest.h"
#include "VDpdm.h"
#include "VDrisc.h"
#include "VDobj2.h"
#include "VDdom2.h"

#include "VDPdef.h"
#include "VDPaimUtil.h"
#include "VDPaimPostMan.h"

VDASSERT_FFN("VDPaimReconn.c");

/* ----------------------------------------------
 * Reconnect DAD if need to
 */
IGRstat VDPaimReconnectDAD(char *msg)
{
  VDASSERT_FN("VDPaimReconnectDAD");

  IGRstat retFlag = 1;

  IGRchar msg_buf[128];
  IGRchar buf[128],*p;

  TGRid dadID;
  VDosnum osnum;
  TVDpdmInfo pdmInfo;

  domNode rootNode = NULL;
  domNode aimNode;
  domNode plcNodes;
  domNode plcNode;
   
  IGRint val,i,seqNum;

  /* Init */
  VDosGetCurrentOS(&osnum);

  /* Arg Check */
  if (msg == NULL) msg = msg_buf;
  *msg = 0;

  /* See if already have a DAD */
  VDPaimGetDADCollector(osnum,0,&dadID);
  if (dadID.objid != NULL_OBJID) 
  {
    strcpy(msg,"DAD Exists, Not reconnecting");
    goto wrapup;
  }

  /* Check aim connection */
  if(IsPmeEnabled() == FALSE)
  {
    strcpy(msg,"AIM server connection required");
    goto wrapup;
  }

  /* Need a bunch of info */
  rootNode = VDPaimGetFileInfo(osnum);
  /* domSaveDocToFile(rootNode,"root.xml"); */
 
  /* Need cat/part/rev */
  VDPaimFIGetPdmInfo(rootNode,&pdmInfo);

  /* No node if no info */
  if (*pdmInfo.catalog == 0) 
  {
    strcpy(msg,"Part not in PDM, not reconnecting");
    goto wrapup;
  }

  /* Grab the sir information */
  aimNode = VDPaimCreateAimInfoNode(osnum,rootNode); 
  domGetTextAttrNodeValue(aimNode,VDP_XML_ATTR_MDC_ID,buf);
  if (*buf == 0)
  {
    strcpy(msg,"No MDC exists, not reconnecting");
    goto wrapup;
  }

  /* Make the collector */
  VDPaimGetDADCollector(osnum,1,&dadID);
  if (dadID.objid == NULL_OBJID)
  {
    strcpy(msg,"Cannot make DAD collector, not reconnecting");
    goto wrapup;
  }
  /* Xfer the attributes */
  domGetTextAttrNodeValue(aimNode,VDP_XML_ATTR_CONTEXT_ID,buf);
  VDcollSetTextAttr(&dadID,SIR_CNTX_ID,buf);

  domGetTextAttrNodeValue(aimNode,VDP_XML_ATTR_CONTEXT_NAME,buf);
  VDcollSetTextAttr(&dadID,SIR_CNTX_NAME,buf);

  domGetTextAttrNodeValue(aimNode,VDP_XML_ATTR_CONTEXT_TYPE,buf);
  VDcollSetTextAttr(&dadID,SIR_CNTX_TYP,buf);

  domGetTextAttrNodeValue(aimNode,VDP_XML_ATTR_CONTEXT_DESC,buf);
  VDcollSetTextAttr(&dadID,SIR_CNTX_DESC,buf);

  domGetIntAttrNodeValue(aimNode,VDP_XML_ATTR_FILE_TYPE,&val);
  VDcollSetIntAttr(&dadID,SIR_FILE_TYP,val);

  domGetTextAttrNodeValue(aimNode,VDP_XML_ATTR_MDC_ID,buf);
  VDcollSetTextAttr(&dadID,SIR_MODCX_ID,buf);

  VDcollSetTextAttr(&dadID,SIR_SEQ_NO,"1");

  /* Make sure pdm table is updated */
  domGetTextAttrNodeValue(aimNode,VDP_XML_ATTR_MDC_REV,buf);
  SirVDUpdCMAttrs(pdmInfo.catalog,pdmInfo.part,pdmInfo.rev,"mdc_rev",buf);

  domGetTextAttrNodeValue(aimNode,VDP_XML_ATTR_CONTEXT_TYPE,buf);
  SirVDUpdCMAttrs(pdmInfo.catalog,pdmInfo.part,pdmInfo.rev,"ctx_type",buf);

  domGetTextAttrNodeValue(aimNode,VDP_XML_ATTR_CONTEXT_NAME,buf);
  SirVDUpdCMAttrs(pdmInfo.catalog,pdmInfo.part,pdmInfo.rev,"ctx_name",buf);

  domGetTextAttrNodeValue(aimNode,VDP_XML_ATTR_CONTEXT_REV,buf);
  SirVDUpdCMAttrs(pdmInfo.catalog,pdmInfo.part,pdmInfo.rev,"ctx_rev",buf);

  /* Now need to update the seq number if there were placements */
  seqNum = 0;
  plcNodes = VDPaimCreateAimPlacementsNode(osnum,rootNode);
  for(i = 0; plcNode = domGetNthChildNode(plcNodes,i); i++)
  {
    domGetTextAttrNodeValue(plcNode,VDP_XML_ATTR_SIRID,buf);
    p = strchr(buf,'-');
    if (p)
    {
      val = atoi(p+1);
      if (val > seqNum) seqNum = val;
    }
  }
  seqNum++;
  sprintf(buf,"%d",seqNum);
  VDcollSetTextAttr(&dadID,SIR_SEQ_NO,buf);
 
  /* Done */
  strcpy(msg,"Reconnected DAD");

wrapup:
  if (rootNode) domFreeDoc(rootNode);
  return retFlag;
}

