/* $Id: VDdomTest.c,v 1.1 2001/01/11 19:28:37 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vddom/VDdomTest.c
 *
 * Description: Basic dom/tree functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdomTest.c,v $
 *      Revision 1.1  2001/01/11 19:28:37  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  14:00:28  pinnacle
 * ah
 *
 * Revision 1.1  2000/08/05  16:35:24  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/01/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDdom.h"
#include "VDxml.h"
#include "VDfrmc.h"

#include "VDassert.h"

VDASSERT_FFN("vds/vddom/VDdomTest.c");

#define VDDOM_FORM_TREE_G_TREE 26

#define standalone 1

/* ----------------------------------------
 * Form notification routine
 */
static IGRint notify(IGRint    f_label,
		     IGRint    gadget,
		     IGRdouble value,
		     Form      form)
{

  IGRstat retFlag = 1;
  IGRstat sts;
  TGRid   nodeID;
  
  // do it
  switch(gadget) {

  case VDDOM_FORM_TREE_G_TREE:
    VDdomFormNotifyTree(form,gadget,&nodeID);
    break;
    
    case FI_CANCEL:
      VDfrmDeleteForm(form,0);
      break;
      
    case FI_RESET:
      VDfrmResetForm(form);
      break;
                  
  }  // end of switch
  
  // done
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * XML tester
 */
IGRstat VDdomTestXml(IGRint argc, IGRchar *argv[])
{  
  VDASSERT_FN("VDdomTestXml");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid treeID;
  
  Form form;
  
  // Say Hi
  printf("----- %s -----\n",fn);
  
  // Init the display
#if standalone
  sts = VDfrmOpenDisplay(argc,argv);
  VDASSERTW(sts & 1);
#endif

  // Init the system
  VDdomInitSystem(0,0,0);
  
  // Load it
  VDdomGetActiveOsnum(&treeID.osnum);
  VDdomCreateTreeFromXmlFile("test1.xml",&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);

  // Print it
  // VDdomPrintTree(&treeID,stdout);

  // Pop up the form
  sts = VDfrmNewForm(555,"VDct1Tree.F",notify,0,&form);
  VDASSERTW(sts & 1);

  // Fill in tree
  VDfrmShowForm(form);
  VDdomFormFillTree(form, VDDOM_FORM_TREE_G_TREE, &treeID);
  
  // Process it
  VDfrmProcessForms();
  
  // Free It
  VDdomFreeTreeObj(&treeID);
  
  // Done
  retFlag = 1;
  
 wrapup:
#if standalone
  VDfrmCloseDisplay();
#endif
  return retFlag;
}

/* -----------------------------------------------
 * Test simple creation
 */
IGRstat VDdomTestCreate(IGRint argc, IGRchar *argv[])
{
  VDASSERT_FN("VDdomTestCreate");
  
  IGRstat retFlag = 0;
  
  TGRid treeID;
  TGRid parentID;
  TGRid childID;
  
  // Say hi
  printf("----- %s -----\n",fn);
  
  // Init the system
  VDdomInitSystem(0,0,0);
  
  // Get the active osnum
  VDdomGetActiveOsnum(&parentID.osnum);
  parentID.objid = NULL_OBJID;
  
  // Create the tree
  VDdomCreateObj(&parentID, "StagingTree", &treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);
  VDdomAppendAtr(&treeID,"node_name","2210");
  
  // And some psu's
  VDdomCreateObj(&treeID, "PSU", &childID);
  VDdomAppendAtr(&childID,"node_name","1");

  VDdomCreateObj(&treeID, "PSU", &childID);
  VDdomAppendAtr(&childID,"node_name","2");

  VDdomCreateObj(&treeID, "PSU", &childID);
  VDdomAppendAtr(&childID,"node_name","3");

  // Print it
  // VDdomPrintTree(&treeID,stdout);

  // Free
  VDdomFreeTreeObj(&treeID);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
#if standalone
/* -----------------------------------------------
 * main traffic director
 */
IGRstat main(IGRint argc, IGRchar *argv[])
{
  VDASSERT_FN("main");
  
  IGRstat retFlag = 0;
  
  // Init the system
  VDdomInitSystem(0,0,0);
  
  VDdomTestCreate(argc,argv);
  VDdomTestXml   (argc,argv);

  // Free The lists
  VDdomFreeLists();
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
#endif
