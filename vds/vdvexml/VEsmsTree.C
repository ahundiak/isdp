/* $Id: VEsmsTree.C,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

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
 *      $Log: VEsmsTree.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/03/31  17:06:38  pinnacle
 * ah
 *
 * Revision 1.2  2000/03/31  13:20:44  pinnacle
 * ah
 *
 * Revision 1.1  2000/03/24  15:49:10  pinnacle
 * ah
 *
# Revision 1.1  2000/02/25  18:16:54  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/15/99  ah      Creation
 *
 ***************************************************************************/

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDvla.h"
#include "VDsa.h"
#include "VDppl1.h"

#include "VDxml.h"
#include "VDcvg.h"
#include "VEsms.h"

#include "VDat.h"

static int traceFlag;

/* -----------------------------------------------
 * Get the set to write, usually by name
 */
IGRstat VEsmsGetSetToWrite(IGRchar *setName, TGRid *setID)
{
  IGRstat retFlag;
  IGRstat sts;
  
  // Arg check
  if (setID == NULL) goto wrapup;
  setID->objid = NULL_OBJID;

  sts = VDatGetSetByTypeName("StagingTree",setName,setID);
  if (!(sts & 1)) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
/* -------------------------------------
 * Open master xml file
 */
IGRstat VEsmsOpenOutputFile(TVEsmsOutputInfo *info, IGRchar *fileName)
{
  IGRstat        retFlag = 0;
  TVDxmlFileInfo *xml = NULL;
  
  // Say hi
  if (traceFlag) printf(">>> VEsmsOpenOutputFile %s\n",fileName);

  // Arg check
  if (info == NULL) goto wrapup;
  xml = info->xml;
  
  // Open it
  VDxmlOpenOutputFile(xml,fileName,XML_SMS_DOC_TYPE,XML_SMS_DTD);
  if (xml->io.file == NULL) goto wrapup;

  // Master objects
  VDxmlWriteObjBeg(xml,XML_SMS_DOC_TYPE,0,1);
   
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VEsmsOpenOutputFile\n");
  return retFlag;
}

/* --------------------------------------
 * Close the master xml file
 * Optiionally, kick off post process
 */
IGRstat VEsmsCloseOutputFile(TVEsmsOutputInfo *info, IGRint flag)
{
  IGRstat retFlag = 0;
  IGRchar cmd[256];
  
  TVDxmlFileInfo *xml = NULL;

  // Arg check
  if (info == NULL) goto wrapup;
  xml = info->xml;
  
  // Root object
  VDxmlWriteObjEnd(xml,XML_SMS_DOC_TYPE,1);

  // Close it
  VDxmlCloseOutputFile(xml);

  // Kick off process
  switch(flag) {
  case 1:
    sprintf(cmd,"dxf2 %s",xml->io.fileName);
    //system (cmd);
    break;
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Writes the setup information
 */
IGRstat VEsmsWriteSetup(TVEsmsOutputInfo *info)
{
  IGRstat retFlag = 0;
  IGRint  pplRET;

  // Say hi
  if (traceFlag) printf(">>> VEsmsWriteSetup\n");
  
  // Arg check
  if (info == NULL) goto wrapup;
  
  // Let the ppl take care of it
  vdppl$Run(pplID = &info->pplID, name = "extractSetup", ret = &pplRET);
  
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VEsmsWriteSetup\n");
  return retFlag;
}

/* --------------------------------------------------------
 * Writes the ship information
 */
IGRstat VEsmsWriteShip(TVEsmsOutputInfo *info)
{
  IGRstat retFlag = 0;
  IGRint  pplRET;

  // Say hi
  if (traceFlag) printf(">>> VEsmsWriteShip\n");

  // Arg check
  if (info == NULL) goto wrapup;
  
  // Let the ppl take care of it
  vdppl$Run(pplID = &info->pplID, name = "extractShip", ret = &pplRET);
  
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VEsmsWriteShip\n");
  return retFlag;
}

/* -----------------------------------------------
 * Init some of the output data structure
 */
IGRstat VEsmsInitOutputInfo(TVEsmsOutputInfo *info, IGRchar *unitReal, IGRchar *unitTest)
{
  IGRstat retFlag = 0;

  // Say hi
  if (traceFlag) printf(">>> VEsmsInitOutputInfo\n");

  // Init 
  if (info == NULL) goto wrapup;
  memset(info,0,sizeof(TVEsmsOutputInfo));

  // Some data
  if (unitReal) strcpy(info->unitReal,unitReal);
  else          strcpy(info->unitReal,"Test");
  if (unitTest) strcpy(info->unitTest,unitTest);
  else          strcpy(info->unitTest,info->unitReal);

  // Do the hull
  strcpy(info->hull,"lp17");

  // Find the set
  VEsmsGetSetToWrite(info->unitReal, &info->setID);
  if (info->setID.objid == NULL_OBJID) goto wrapup;
  
  // Load the ppl extract routine
  vdppl$Load(name = VE_SMS_PPL_EXTRACT, pplID = &info->pplID);
  if (info->pplID.objid == NULL_OBJID) {
    printf("*** Could not load PPL '%s'\n",VE_SMS_PPL_EXTRACT);
    goto wrapup;
  }

  // The set
  vdppl$SetData(pplID = &info->pplID,
		name  = "SMS_INFO",
		size  = sizeof(TVEsmsOutputInfo*),
		data  = (IGRchar*)&info);
  
  // Easy to write xml
  info->xml = &info->cvg.xml;
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VEsmsInitOutputInfo\n");

  return retFlag;
}

/* --------------------------------------------------------
 * Recursive routine to write 1 tree node
 */
IGRstat VEsmsWriteTreeNode(TVEsmsOutputInfo *info, TGRid *nodeID)
{
  IGRstat retFlag = 0;

  IGRint  type;
  IGRuint i;
  
  TGRid   childID;
  
  IGRint  pplRet;

  // Check the id
  if (nodeID == NULL) goto wrapup;
  if (nodeID->objid == NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }
  info->nodeID = *nodeID;
  
  // Write it
  vdppl$Run(pplID = &info->pplID, 
	    name  = "extractTreeNode", 
	    ret   = &pplRet);
  
  // ReCurse down through the next level
  if (VDatIsLeaf(nodeID)) {
  }
  else {
    // Recursive Loop, add itself
    for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) {
      VEsmsWriteTreeNode(info,&childID);
    }   
  }

  // End the object
  VDxmlWriteObjEnd(info->xml,XML_PDF_TREE_NODE,1);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Extract Tree
 */
IGRstat VEsmsWriteTree(TVEsmsOutputInfo *info)
{
  IGRstat retFlag = 0;
  
  TGRid   nodeID;

  TVDxmlFileInfo *xml = info->xml;
  
  // Make sure set was picked
  if (info->setID.objid == NULL_OBJID) goto wrapup;
  
  // Make sure have a tree
  VDatGetTree(&info->setID,&nodeID);
  if (nodeID.objid == NULL_OBJID) goto wrapup;

  // Start the main tree
  VDxmlWriteObjBeg(xml,XML_PDF_TREE,1,1);
  VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NAME,info->unitReal,1,1);
  VDxmlWriteAtrEnd(xml,1,1);
    
  // Dump out each one
  VEsmsWriteTreeNode(info,&nodeID);
  
  // Clean up
  VDxmlWriteObjEnd(xml,XML_PDF_TREE,1);
    
  // Done
  retFlag = 1;

wrapup:

  return retFlag;
}
  
/* -----------------------------------------------
 * Write tree out
 */
IGRstat VEsmsWriteSetTree(IGRchar *unitReal, 
			  IGRchar *unitTest)
{
  IGRstat retFlag;
  IGRstat sts;
  IGRint  pplRET;
  
  TVEsmsOutputInfo  infox;  // Use a pointer for now
  TVEsmsOutputInfo *info;
  
  IGRchar buf[256];
  
  // Say hi
  traceFlag = 1;
  if (traceFlag) {
    printf("----------------------------\n");
    printf(">>> VEsmsWriteSetTree %s\n",unitReal);
  }
  
  // Init 
  info = &infox;
  sts = VEsmsInitOutputInfo(info,unitReal,unitTest);
  if (!(sts & 1)) goto wrapup;
  
  // Tree specific
  UI_status("Production Tree Extraction ...");
  strcpy(info->what,"tree");

  // Open the main file
  sts = VEsmsOpenOutputFile(info,"SmsTree.xml");
  if (!(sts & 1)) goto wrapup;

  // Write the setup information
  VEsmsWriteSetup(info);

  // Write the ship information
  VEsmsWriteShip(info);

  // Write the tree
  VEsmsWriteTree(info);

  // Done
  retFlag = 1;
  
wrapup:

  // Close the output file
  VEsmsCloseOutputFile(info,0);
  UI_status("Production Tree Extraction Complete");

  if (traceFlag) printf("<<< VEsmsWriteSetTree\n");

  return retFlag;
}

