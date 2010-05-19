/* $Id: main.c,v 1.1 2001/01/14 16:01:07 art Exp $  */

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
 * Revision 1.1  2001/01/14 16:01:07  art
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

#include "VDdom.h"
#include "VDctx.h"
#include "VDcty.h"

#include "VDct1Plot.h"

VDASSERT_FFN("vdcty/test/main.c");

/* -----------------------------------------------
 * Main traffic director
 */
int main()
{
  VDASSERT_FN("main");
  
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
