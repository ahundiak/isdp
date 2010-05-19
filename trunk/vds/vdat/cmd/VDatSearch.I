/* $Id: VDatSearch.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdat/pocket/VDatSearch.I
 *
 * Description:  This file contains the functions for implementing the
		 search function on the pocket menu form.
 *
 * Dependencies:       
 *                      
 *
 * Notes:
 *
 *
 * Revision History:
 *      $Log: VDatSearch.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/04/09  14:23:54  pinnacle
# Moved from pocket
#
# Revision 1.4  1999/02/09  21:06:18  pinnacle
# Replaced: vdat/pocket/VDatSearch.I for:  by vsrivast for vds
#
# Revision 1.3  1999/01/25  21:19:56  pinnacle
# Replaced: vdat/pocket/VDatSearch.I for:  by vsrivast for vds
#
# Revision 1.1  1999/01/11  22:43:46  pinnacle
# initial revision
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/11/99  vinit   Creation 
 ***************************************************************************/

class implementation VDatBase;

#include "VDppl1.h"
#include "VDatProto.h"
#include "VDsa.h"
#include "VDahFrm.h"
#include "v_dbgmacros.h"

IGRint VDatSearchForNode(TGRid *setID, IGRchar *searchString, TGRid *nodeID);
IGRint VDatRecurseTree(TGRid *treeID, TGRid *nodeID, IGRchar *nodeName, IGRchar *nodeType, IGRint *found);
IGRint VDatExpandTree(Form form, IGRint gadget, TGRid *setID, TGRid *nodeID);
IGRint VDatDisplayRecurse(Form form, IGRint gadget, TGRid *nodeID, IGRint *row);
IGRint VDatDisplayRecurseFabData(Form form, IGRint gadget, TGRid *nodeID, IGRint *row);
IGRint VDatTestNode(TGRid *testID, IGRchar* nodeName, IGRchar *nodeType);
IGRint VDatRecurseGetPcmk(TGRid *parentID, TGRid *nodeID, IGRint  pcmk, IGRint *found);
IGRint VDatTestLeaf(TGRid *testID, IGRint pcmk);
IGRint VDatRecurseGetPcmkForFabData(TGRid *parentID, TGRid *nodeID, IGRint  pcmk, IGRint *found);
IGRint VDatTestPcmk(TGRid *testID, IGRint pcmk);


IGRint VDatSearchForNode(TGRid *setID, IGRchar *searchString, TGRid *nodeID)
{

  TGRid  treeID;
  TGRid  pplID;
  IGRint retFlag;
  IGRint pplRET;
  IGRint i;
  IGRchar	setType[128];
  
  //Init
  retFlag = 0;
  
  // Args Check
  if(setID->objid == NULL_OBJID) goto wrapup;
  if(searchString == NULL) goto wrapup;
  
  VDatRDBGetSetType(setID,setType);
  
  //Load the ppl
  vdppl$Load (name = setType, pplID = &pplID);
  if(pplID.objid == NULL_OBJID)
  {
    printf(" Unable to load %s.e in VDatSearchForNode\n", setType);
    goto wrapup;
  }
  vdppl$SetData (
    pplID = &pplID,
    name  = "SEARCH_STRING",
    size  = 128,
    data  = searchString
  );
  vdppl$SetData (
    pplID = &pplID,
    name  = "SET_ID",
    size  = sizeof(TGRid),
    data  = (IGRchar *) setID
  );
  
  // Run the function
  
  vdppl$Run (pplID = &pplID, name = "searchforNode", ret = &pplRET );
  
  // Get the NodeID
  
  vdppl$GetData (
    pplID = &pplID,
    name  = "NODE_ID",
    size  = sizeof(TGRid),
    data  = (IGRchar *) nodeID
  );
  vdppl$Delete(pplID = &pplID);
  retFlag = 1;
 wrapup:
  return retFlag;
  
}

// Recurse down the tree to find the Node 

IGRint VDatRecurseTree(TGRid *parentID, TGRid *nodeID, IGRchar *nodeName, IGRchar *nodeType, IGRint *found)
{
  
  TGRid 	childID;
  IGRint  i;
  
  /*  The End of the tree is reached if the child object is NULL
   *  or is a Leaf
   */
  
  // Search discontinued if node is found.
  
  if((parentID->objid == NULL_OBJID) || (*found == 1))
  {
    return 1;
  }
  if(VDatIsBaseType(parentID, VDAT_CLASSI_LEAF))
  {
    return 1;
  }
  // Get the children and recurse through them	
  
  for(i=0;vdat$GetObj(objID = parentID, nth = i, childID = &childID);i++)
  {
    
    // Test the child
    if(VDatTestNode(&childID, nodeName, nodeType))
    {
      *nodeID = childID;
      *found = 1;
      break;
    }
    else 
      // If child is not found keep going
      VDatRecurseTree(&childID, nodeID, nodeName, nodeType, found);
  }
  return 1;
}


// Test the node

IGRint VDatTestNode(TGRid *testID, IGRchar* nodeName, IGRchar *nodeType)
{

  IGRchar	text1[128];
  IGRchar	text2[128];
  
  vdsa$GetStruct(objID = testID, name = "node_name", txt = text1);
  vdsa$GetStruct(objID = testID, name = "node_type", txt = text2);
  
  if((strcmp(nodeName, text1)==0) && (strcmp(nodeType, text2)== 0))	
    return 1;
  else 
    return 0;
}

/*	The tree is expanded on the form till the desired 
 *	node is displayed
 */

IGRint VDatExpandTree(Form form, IGRint gadget, TGRid *setID, TGRid *nodeID)
{
  
  TGRid   treeID;
  IGRint	i;
  IGRint  row;
  
  // Args Check
  
  if(nodeID->objid == NULL_OBJID) return 0;
  
  // If already displayed then show the row and select it
  
  VDatFormFindTreeRow(form, gadget, nodeID, &row);
  if(row > -1)
  {
    VDatFormContractTreeRow(form, gadget, row);
    VDatFormShowRow(form, gadget, row);
    FIfld_set_select(form, gadget, row, 2, 1);
    return 1;
  }
  
  /* Else Recurse up the tree till a displayed node is
   * reached and expand down from there
   */
  
  // VDatFormContractTreeRow(form, gadget, 0);
  row = 0;
  VDatGetTree(setID, &treeID);
  if(treeID.objid == NULL_OBJID)
    VDatDisplayRecurseFabData(form, gadget, nodeID, &row);
  else
    VDatDisplayRecurse(form, gadget, nodeID, &row);
  
  // Select and display the node on form
  VDatFormFindTreeRow(form, gadget, nodeID, &row);
  // VDatFormContractTreeRow(form, gadget, row);
  VDatFormShowRow(form, gadget, row);
  FIfld_set_select(form, gadget, row, 2, 1);
  return 1;
  
  
}

//	Routine to recurse up from a node until a displayed node is reached

IGRint VDatDisplayRecurse(Form form, IGRint gadget, TGRid *nodeID, IGRint *row)
{
  
  TGRid 	parentID;
  IGRchar name[128];
  
  // Check if current node is displayed
  if((VDatFormFindTreeRow(form, gadget, nodeID, row)) || (nodeID->objid == NULL_OBJID))
  {
    // If so expand the row and increment number of rows
    VDatFormExpandTreeRow(form, gadget, *row);
    (*row)++;
    return 1;
  }
  else
  {
    VDatGetParentNode(nodeID, &parentID);
    VDatDisplayRecurse(form, gadget, &parentID, row);
  }
  
  // Expand the rows
  VDatFormFindTreeRow(form, gadget, nodeID, row);
  VDatFormExpandTreeRow(form, gadget, *row);
  return 1;
  
}

// Display a particular list/leaf of a Production Data Set(FabData)..

IGRint VDatDisplayRecurseFabData(Form form, IGRint gadget, TGRid *nodeID, IGRint *row)
{
  
  TGRid 	parentID;
  
  // Check if current node is displayed
  if((VDatFormFindTreeRow(form, gadget, nodeID, row)) || (nodeID->objid == NULL_OBJID))
  {
    // If so expand the row and increment number of rows
    VDatFormExpandTreeRow(form, gadget, *row);
    (*row)++;
    return 1;
  }
  else
  {
    VDatGetParentByType(nodeID,VDAT_CLASSI_LEAFS, &parentID);
    if (parentID.objid == NULL_OBJID) {
      VDatGetParentByType(nodeID,VDAT_CLASSI_PLATES, &parentID);
    }
    if (parentID.objid == NULL_OBJID) {
      VDatGetParentByType(nodeID,VDAT_CLASSI_BEAMS, &parentID);
    }
    if (parentID.objid == NULL_OBJID) {
      VDatGetParentByType(nodeID,VDAT_CLASSI_OTHERS, &parentID);
    }
    if (parentID.objid == NULL_OBJID){
      return 1;
    }
    VDatDisplayRecurseFabData(form, gadget, &parentID, row);
  }
  // Expand the rows
  VDatFormFindTreeRow(form, gadget, nodeID, row);
  VDatFormExpandTreeRow(form, gadget, *row);
  return 1;

}

IGRint VDatRecurseGetPcmk(TGRid *parentID, TGRid *nodeID, IGRint pcmk, IGRint *found)
{
  TGRid childID;
  IGRint i;
  
  /* Search discontinued if node is found or the parent is a leaf 
   * which has been tested.
   */
  
  if((parentID->objid == NULL_OBJID) || (*found==1))
  {
    return 1;
  }
  // Get the children and recurse through them	
  
  for(i=0;vdat$GetObj(objID = parentID, nth = i, childID = &childID);i++)
  {
    
    // Test the child
    if((VDatIsBaseType(&childID, VDAT_CLASSI_LEAF)) && (VDatTestLeaf(&childID, pcmk)))
    {
      *nodeID = childID;
      *found  = 1;
      break;
    }
	else 
	  // If child is not found keep going
	  VDatRecurseGetPcmk(&childID, nodeID, pcmk, found);
  }
  return 1;
}

IGRint VDatTestLeaf(TGRid *testID, IGRint pcmk)
  
{
  IGRchar name[64];

  vdsa$GetStruct(objID = testID, name = "pcmk", txt = name );
  
  if(pcmk == atoi(name)) return 1;
  
  return 0;
  
}

// Production Data Sets specific recursive routines..

IGRint VDatRecurseGetPcmkForFabData(TGRid *parentID, TGRid *nodeID, IGRint pcmk, IGRint *found)
{
  TGRid childID;
  TGRobj_env objOE ;
  IGRint i;
  
  
  /* Search discontinued if node is found or the parent is a leaf 
   * which has been tested.
   */
  
  if((parentID->objid == NULL_OBJID) || (*found==1))
  {
    return 1;
  }
  // Get the children and recurse through them	
  
  for(i=0;vdat$GetObj(objID = parentID, nth = i, childID = &childID);i++)
  {
    // Test the child
    if(VDatIsBaseType(&childID, VDAT_CLASSI_LEAF)) 
    {	
      VDatGetLeafObject(&childID, &objOE);
      if(VDatTestPcmk(&objOE.obj_id, pcmk))
      {
	*nodeID = childID;
	*found  = 1;
	break;
      }
    }	
    else
    {
      // If child is not found keep going
      VDatRecurseGetPcmkForFabData(&childID, nodeID, pcmk, found);
    }
  }
  return 1;
}

IGRint VDatTestPcmk(TGRid *testID, IGRint pcmk)
  
{
  IGRchar name[64];
  
  vdsa$GetStruct(objID = testID, name = "SA_AST:StagingTree:0:pcmk", txt = name );
  
  
  if(pcmk == atoi(name)) return 1;
  
  return 0;
  
}
end implementation VDatBase;


