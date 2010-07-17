/* -----------------------------------------------
 * Diff two spades files
 */
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDctx.h"
#include "VDgeomc.h"
#include "VDxdom.h"

#include "VLsmsXml.h"
#include "VDcvgXml.h"
#include "VDcvg2.h"
#include "VDpdf2.h"

#include "glib.h"
#include "xdom.h"

VDASSERT_FFN("main.c");

#define PDF_OBJ_PLATESx "PDF_OBJ_PLATES"

/* -----------------------------------------------
 * Print out diff message
 */
static void printDiff(TGRid *plate1ID, TGRid *plate2ID, IGRchar *msg)
{
  IGRchab pcmk1,pcmk2;
  
  if (plate1ID->objid != NULL_OBJID)  VDctxGetTxtAtr(plate1ID,"PDF_ATR_TREE_NODE_PCMK",pcmk1);
  else                                strcpy(pcmk1,"????");
  if (plate2ID->objid != NULL_OBJID)  VDctxGetTxtAtr(plate2ID,"PDF_ATR_TREE_NODE_PCMK",pcmk2);
  else                                strcpy(pcmk2,"????");
  
  printf("--- Found diff for %s %s ---\n",pcmk1,pcmk2);
  printf("    %s\n",msg);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Diff two nodes
 */
static IGRstat diffNodes(TGRid *plate1ID, TGRid *plate2ID, TGRid *node1ID, TGRid *node2ID, IGRint recurseFlag)
{
  VDASSERT_FN("diffPlates");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  xmlNodePtr node1,node2;
  xmlAttrPtr attr1,attr2;

  IGRchar *buf1,*buf2;

  IGRchab  msg;
  IGRchar *msgx;
  
  TGRid  child1ID,child2ID;
  IGRint i;
  
  IGRint diffFound = 0;
  
  // Cycle through attributes
  node1 = xdom_nodeid_get_node(node1ID);
  VDASSERTW(node1);
  node2 = xdom_nodeid_get_node(node2ID);
  VDASSERTW(node2);
  
  for(attr1 = node1->properties; attr1; attr1 = attr1->next) {
    buf1 = (gchar*)xmlGetProp(node1,attr1->name);
    VDASSERTW(buf1);
    buf2 = (gchar*)xmlGetProp(node2,attr1->name);
    if (buf2 == NULL) {
      sprintf(msg,"Attribute %s not in second plate",attr1->name);
      printDiff(plate1ID,plate2ID,msg);
      diffFound = 1;
    }
    else {
      if (strcmp(buf1,buf2)) {
	msgx = g_new(IGRchar,strlen(buf1) + strlen(buf2) + 100);
	sprintf(msgx,"Attribute %s '%s' '%s'",attr1->name,buf1,buf2);	
	printDiff(plate1ID,plate2ID,msgx);
	g_free(msgx);
	diffFound = 1;
      }
    }
    g_free(buf1);
    g_free(buf2);    
  }
  // Check kids
  if (recurseFlag == 0) {
    retFlag = 1;
    goto wrapup;
  }

  // Cycle through kids
  for(i = 0; VDctxGetNthTreeChild(node1ID,i,&child1ID); i++) {
    VDctxGetNthTreeChild(node2ID,i,&child2ID);
    if (child2ID.objid == NULL_OBJID) {
      printDiff(plate1ID,plate2ID,"First plate has more child nodes");
      diffFound = 1;
    }
    else {
      sts = diffNodes(plate1ID,plate2ID,&child1ID,&child2ID,1);
      if (sts == 0) {
	diffFound = 1;
	goto wrapup;
      }
    }
  }
  VDctxGetNthTreeChild(node2ID,i,&child2ID);
  if (child2ID.objid != NULL_OBJID) {
    printDiff(plate1ID,plate2ID,"Second plate has more child nodes");
    diffFound = 1;
  }
      
  // Done
  retFlag = 1;
  
 wrapup:
  if (retFlag && diffFound) retFlag = 0;
  
  return retFlag;
  
}

/* -----------------------------------------------
 * Diff two plate labels
 */
static void diffPlateLabels(TGRid *plate1ID, TGRid *plate2ID)
{
  VDASSERT_FN("diffPlateLabels");
  
  IGRint i1,i2;
  TGRid  label1ID,label2ID;
  
  IGRint flag;
    
  // Init
  i1 = i2 = 0;
  
  // Cycle through, assume holes match up
  while(VDctxGetNthTreeChild(plate1ID,i1,&label1ID)) {

    if (VDctxIsNodeType(&label1ID,"PDF_OBJ_LABEL")) {

      // Find next plate hole from second plate
      flag = 1;
      while(flag) {

	VDctxGetNthTreeChild(plate2ID,i2,&label2ID);
	if (label2ID.objid == NULL_OBJID) {
	  printDiff(plate1ID,plate2ID,"Different number of plate labels");
	  flag = 0;
	}
	else {
	  
	  if (VDctxIsNodeType(&label2ID,"PDF_OBJ_LABEL")) {

	    diffNodes(plate1ID,plate2ID,&label1ID,&label2ID,1);

	    // Done with this label
	    flag = 0;
	  }
	  i2++;
	}
      } 
    }
    i1++;
  }
  
 wrapup:
  return;
}
/* -----------------------------------------------
 * Diff two generic markings
 */
static void diffPlateMarkings(TGRid *plate1ID, TGRid *plate2ID)
{
  VDASSERT_FN("diffPlateMarkings");
  
  IGRint i1,i2;
  TGRid  marking1ID,marking2ID;
  
  IGRchab type1,type2;
  
  IGRint flag;
    
  // Init
  i1 = i2 = 0;
  
  // Cycle through, assume holes match up
  while(VDctxGetNthTreeChild(plate1ID,i1,&marking1ID)) {

    if (VDctxIsNodeType(&marking1ID,"PDF_OBJ_MARKING_LINE")) {

      // Process everything but part markings
      VDctxGetTxtAtr(&marking1ID,"PDF_ATR_MARKING_LINE_TYPE",type1);
      if (1) {
	
	//if (strcmp(type1,"PLATE") && strcmp(type1,"BEAM")) {
	
	// Find next plate hole from second plate
	flag = 1;
	while(flag) {

	  VDctxGetNthTreeChild(plate2ID,i2,&marking2ID);
	  if (marking2ID.objid == NULL_OBJID) {
	    printDiff(plate1ID,plate2ID,"Different number of plate markings");
	    flag = 0;
	  }
	  else {
	  
	    if (VDctxIsNodeType(&marking2ID,"PDF_OBJ_MARKING_LINE")) {

	      //printf("Marking type %s\n",type1);
	      
	      diffNodes(plate1ID,plate2ID,&marking1ID,&marking2ID,1);

	      // Done with this label
	      flag = 0;
	    }
	    i2++;
	  }
	}
      } 
    }
    i1++;
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Diff two plate inner contours
 */
static void diffPlateInnerContours(TGRid *plate1ID, TGRid *plate2ID)
{
  VDASSERT_FN("diffPlateInnerContours");

  IGRstat sts;
  
  IGRint i1,i2;
  TGRid   hole1ID, hole2ID;
  TGRid  bevel1ID,bevel2ID;
  
  IGRint flag;
  
  // Init
  i1 = i2 = 0;
  
  // Cycle through, assume holes match up
  while(VDctxGetNthTreeChild(plate1ID,i1,&hole1ID)) {

    if (VDctxIsNodeType(&hole1ID,"PDF_OBJ_HOLE")) {

      // Find next plate hole from second plate
      flag = 1;
      while(flag) {

	VDctxGetNthTreeChild(plate2ID,i2,&hole2ID);
	if (hole2ID.objid == NULL_OBJID) {
	  printDiff(plate1ID,plate2ID,"Different number of plate holes");
	  flag = 0;
	}
	else {
	  
	  if (VDctxIsNodeType(&hole2ID,"PDF_OBJ_HOLE")) {

	    // Compare attributes
	    sts = diffNodes(plate1ID,plate2ID,&hole1ID,&hole2ID,0);
	    
	    // Check bevels
	    VDctxGetChildNodeByType(&hole1ID,"PDF_OBJ_BEVEL",&bevel1ID);
	    VDctxGetChildNodeByType(&hole2ID,"PDF_OBJ_BEVEL",&bevel2ID);
	    if (bevel1ID.objid != NULL_OBJID && bevel2ID.objid != NULL_OBJID) {

	      sts = diffNodes(plate1ID,plate2ID,&bevel1ID,&bevel2ID,1);

	    }
	    else {
	      if (bevel1ID.objid != NULL_OBJID || bevel2ID.objid != NULL_OBJID) {
		printDiff(plate1ID,plate2ID,"Bevel mismatch on hole");
	      }
	    }

	    // Done with this hole
	    flag = 0;
	  }
	  i2++;
	}
      } 
    }
    i1++;
  }
  
 wrapup:
  return;
}
  
/* -----------------------------------------------
 * Diff two plate edges
 */
static void diffPlateEdges(TGRid *plate1ID, TGRid *plate2ID)
{
  VDASSERT_FN("diffPlateEdges");
  
  IGRint i1,i2;
  TGRid  edge1ID,edge2ID;
  
  IGRint flag;
  
  // Init
  i1 = i2 = 0;
  
  // Cycle through, assume edges match up
  while(VDctxGetNthTreeChild(plate1ID,i1,&edge1ID)) {

    if (VDctxIsNodeType(&edge1ID,"PDF_OBJ_PLATE_EDGE")) {

      // Find next plate edge from second plate
      flag = 1;
      while(flag) {

	VDctxGetNthTreeChild(plate2ID,i2,&edge2ID);
	if (edge2ID.objid == NULL_OBJID) {
	  printDiff(plate1ID,plate2ID,"Different number of plate edges");
	  flag = 0;
	}
	else {
	  
	  if (VDctxIsNodeType(&edge2ID,"PDF_OBJ_PLATE_EDGE")) {

	    diffNodes(plate1ID,plate2ID,&edge1ID,&edge2ID,1);
	        
	    // Done with this edge
	    flag = 0;
	  }
	  i2++;
	}
      } 
    }
    i1++;
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Diff two plates
 */
static void diffPlates(TGRid *plate1ID, TGRid *plate2ID)
{
  VDASSERT_FN("diffPlates");
  
  IGRstat sts;

  // Check top attributes
  sts = diffNodes(plate1ID,plate2ID,plate1ID,plate2ID,0);
  if (sts == 0) goto wrapup;
  
  // Check the outer contour and bevels
  diffPlateEdges(plate1ID,plate2ID);
  
  // Check the inner contours
  diffPlateInnerContours(plate1ID,plate2ID);

  // Check the labels
  diffPlateLabels(plate1ID,plate2ID);

  // Check the markings
  diffPlateMarkings(plate1ID,plate2ID);

 wrapup:
  return;
  
}

/* -----------------------------------------------
 * Cycle through list of plates and find a matching one
 */
static void findPlate(TGRid *findID, TGRid *platesID, TGRid *foundID)
{
  IGRchab pcmk1,name1;
  IGRchab pcmk2,name2;
  
  TGRid  plateID;
  IGRint i;
  
  // Init
  foundID->objid = NULL_OBJID;
  
  // Attributes to math on
  VDctxGetTxtAtr(findID,"PDF_ATR_TREE_NODE_PCMK",pcmk1);
  VDctxGetTxtAtr(findID,"PDF_ATR_TREE_NODE_NAME",name1);
  
  // Cycle through
  for(i = 0; VDctxGetNthTreeChild(platesID,i,&plateID); i++) {
    VDctxGetTxtAtr(&plateID,"PDF_ATR_TREE_NODE_PCMK",pcmk2);
    VDctxGetTxtAtr(&plateID,"PDF_ATR_TREE_NODE_NAME",name2);
    if (!strcmp(pcmk1,pcmk2) && !strcmp(name1,name2)) {
      *foundID = plateID;
      goto wrapup;
    }
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Main routine for diffinf two spades files
 */
void VDpdf2DiffSpadesFiles(IGRchar *fileName1, IGRchar *fileName2)
{
  VDASSERT_FN("VDpdf2DiffSpadesFiles");
  
  TGRid tree1ID,tree2ID;

  TGRid plates1ID,plates2ID;
  TGRid  plate1ID, plate2ID;
  
  IGRint i;
  
  // Init
  tree1ID.objid = NULL_OBJID;
  tree2ID.objid = NULL_OBJID;
  
  // Arg check
  VDASSERTW(fileName1 && *fileName1);
  VDASSERTW(fileName2 && *fileName2);
  printf("--- Diffing %s %s ---\n",fileName1,fileName2);
  
  // Load em
  VDxdomCreateTreeFromXmlFile(fileName1,&tree1ID);
  VDASSERTW(tree1ID.objid != NULL_OBJID);
  VDxdomCreateTreeFromXmlFile(fileName2,&tree2ID);
  VDASSERTW(tree2ID.objid != NULL_OBJID);
  
  // Get the plates section
  VDctxGetChildNodeByType(&tree1ID,"PDF_OBJ_PLATES",&plates1ID);
  VDASSERTW(plates1ID.objid != NULL_OBJID);
  VDctxGetChildNodeByType(&tree2ID,"PDF_OBJ_PLATES",&plates2ID);
  VDASSERTW(plates2ID.objid != NULL_OBJID);
  
  // Cycle through first tree
  for(i = 0; VDctxGetNthTreeChild(&plates1ID,i,&plate1ID); i++) {
    
    // Look it up in second tree
    findPlate(&plate1ID,&plates2ID,&plate2ID);
    if (plate2ID.objid == NULL_OBJID) {
      //printDiff(&plate1ID,&plate2ID,"*** Plate not in second tree\n");
    }
    else {
      diffPlates(&plate1ID,&plate2ID);
    }
  }
  
  // Cycle through in the other direction
  for(i = 0; VDctxGetNthTreeChild(&plates2ID,i,&plate2ID); i++) {
    
    // Look it up in first tree
    findPlate(&plate2ID,&plates1ID,&plate1ID);
    if (plate1ID.objid == NULL_OBJID) {
      //printDiff(&plate1ID,&plate2ID,"*** Plate not in first tree\n");
    }
  }

 wrapup:
  VDctxDeleteNode(&tree1ID);
  VDctxDeleteNode(&tree2ID);
  return;
}
