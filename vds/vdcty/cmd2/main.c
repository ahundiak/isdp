/* $Id: main.c,v 1.1 2001/01/14 16:01:22 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/copics/main.C
 *
 * Description: Convert xml files to copics
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: main.c,v $
 * Revision 1.1  2001/01/14 16:01:22  art
 * sp merge
 *
 * Revision 1.1  2000/12/06  15:14:48  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/05/00  ah      Creation
 *
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDfrmc.h"

#include "VDdom.h"
#include "VDctx.h"
#include "VDcty.h"

#include "VDct1Cmdx.h"

#include "VDct1Plot.h"

VDASSERT_FFN("vdcty/test/main.c");


IGRstat VDct1TraceFlag(IGRint flag)
{
  return 0;
}

/* -----------------------------------------------
 * Main traffic director
 */
int dom_test1()
{
  VDASSERT_FN("dom_test1");
  
  TGRid treeID;

  TVDctxBaseInfo baseInfo;
  TVDctyAttrInfo attrInfo;

  IGRchar name[32];
  IGRint  i;
  
  // Say Hi
  printf("-------------- Beginning Test --------------\n");

  // Load in the plot tree
  VDdomInitSystem(0,0,0);
  VDdomGetActiveOsnum(&treeID.osnum);
  
  VDdomCreateTreeFromXmlFile("PlotTree_PLOT1.xml",&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);
  VDdomConvertToSetObj(&treeID);
  
  // VDdomPrintTree(&treeID,stdout);
  
  // Get the base information
  VDctxGetBaseInfoID(NULL,&treeID,&baseInfo);
  printf("BaseInfo %s %s %s %s\n",baseInfo.setType,baseInfo.setName,baseInfo.nodeType,baseInfo.nodeName);

  // Get an attribute
  VDctyGetNodeAttrInfo(NULL,NULL,&treeID,VDCT1_PLOT_ATTR_NAME_WINDOW,&attrInfo);
  VDASSERTW(*attrInfo.name);
  printf("AttrInfo %s %s %s\n",attrInfo.name,attrInfo.base,attrInfo.desc);

  // List attributes
  for(i = 0; VDctyGetNodeAttrName(NULL,NULL,&treeID,VDCT1_PLOT_NODE_TYPE_DRAWING,i,name); i++) {
    printf("Attr Name %s\n",name);
  }
  
  // Done
 wrapup:
  return 0;
}

static TVDct1CmdInfo cmdInfo;

/* -----------------------------------------------
 * Main traffic director
 */
int main(int argc, char *argv[])
{
  VDASSERT_FN("main");
  IGRstat sts;
  IGRstat displayOpen;
  
  // Say Hi
  printf("-------------- Beginning Test --------------\n");

  // Get the forms going
  displayOpen = VDfrmOpenDisplay(argc,argv);
  if (!(displayOpen & 1)) goto wrapup;

  // Init the command
  memset(&cmdInfo,0,sizeof(TVDct1CmdInfo));
  cmdInfo.isStandAlone = 1;
  
  sts = VDct1CmdInitRootCmdInfo(&cmdInfo);
  if (!(sts & 1)) {
    printf("*** Problem initializing the command\n");
    goto wrapup;
  }
  
  // Let it rip
  VDfrmProcessForms();

  // Shut down
  // VDct1CmdDeleteRootCmdInfo();

  // Done
 wrapup:
  if (displayOpen & 1) VDfrmCloseDisplay();  
  return 0;
}

