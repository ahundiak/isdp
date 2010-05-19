/* $Id: VDatLeaf.I,v 1.4 2001/03/13 22:42:14 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/cmd/VDatLeaf.I
 *
 * Description: Leaf Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatLeaf.I,v $
 *      Revision 1.4  2001/03/13 22:42:14  ramarao
 *      Added Event button to the form.
 *
 *      Revision 1.3  2001/03/13 21:57:25  ramarao
 *      Implemented CR# 4063.
 *
 *      Revision 1.2  2001/01/11 20:23:18  art
 *      sp merge
 *
# Revision 1.3  2000/10/30  17:08:18  pinnacle
# ah
#
# Revision 1.2  2000/10/15  13:44:36  pinnacle
# ah
#
# Revision 1.1  2000/06/27  16:37:32  pinnacle
# ah
#
# Revision 1.5  2000/02/23  15:22:00  pinnacle
# ah
#
# Revision 1.4  1998/10/25  12:03:50  pinnacle
# ah
#
# Revision 1.3  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.2  1998/09/25  15:44:20  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.7  1998/02/21  00:02:56  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/10/97  ah      creation
 * 02/22/99  ylong   TR179901068, Sort piece marks in leaf form
 * 02/23/00  ah      Added code to display piece marks for FabData trees
 * 06/21/00  ah      Update status when set activation is complete
 * 10/27/00  ah      Suppressed "Not in tree" print statement.
 * 03/13/01  RR	     Added an Event Button to the Leaf Form.
 ***************************************************************************/

class implementation VDatBase;

#include "VDatCmd.h"
#include "VDppl1.h"
#include "VDobj.h" 
#include "VDsa.h"
#include "VDmem.h"
#include "VDfrm.h"

#define VDAT_FORM_LEAF_G_PLATES 24
#define VDAT_FORM_LEAF_G_BEAMS  30
#define VDAT_FORM_LEAF_G_OTHERS 31
#define VDAT_FORM_LEAF_T_ADD    15
#define VDAT_FORM_LEAF_T_SHOW   16
#define VDAT_FORM_LEAF_T_PCMK   17

#define VDAT_FORM_LEAF_B_UNSELECT_ALL  13
#define VDAT_FORM_LEAF_B_UNHILITE_ALL  12
#define VDAT_FORM_LEAF_B_HILITE_SELECT 14

#define VDAT_FORM_LEAF_B_REMOVE 36
#define VDAT_FORM_LEAF_B_EVENT  18

IGRstat VDatCMDLeafAddToList (Form form, IGRint gadget, TGRid *leafID);
IGRstat VDatCMDLeafAddToLists(Form form, TGRid *leafID);

IGRstat VDatCMDLeafSelectInList (Form form, IGRint gadget, TGRid *leafID);
IGRstat VDatCMDLeafSelectInLists(Form form, TGRid *leafID);

IGRstat VDatCMDLeafHiLiteList  (Form form, IGRint gadget);
IGRstat VDatCMDLeafHiLiteLists (TVDatFrmList *fl);

IGRstat VDatCMDLeafNotifyList  (TVDatFrmList *fl, IGRint gadget);

IGRstat VDatCMDLeafFillList    (Form form, IGRint gadget, TGRid *listID);
IGRstat VDatCMDLeafFillLists   (TVDatFrmList *fl);
IGRstat VDatCMDLeafNotifyForm  (TVDatFrmList *fl);
IGRstat VDatCMDLeafActivateForm(TVDatFrmList *fl);
IGRstat VDatCMDLeafActivateSet (TVDatFrmList *fl);

IGRstat VDatCMDLeafNotifyObject(TVDatFrmList *fl, TVDvlaOE *setVLA);

IGRstat VDatCMDLeafGetSelectedLeafs(TVDatFrmList *fl,TVDvlaID *leafVLA);

/* ---------------------------------------------------
 * Remove Leafs from set
 */
IGRstat VDatCMDLeafNotifyRemoveLeafs(TVDatFrmList *fl)
{
  IGRstat  retFlag = 0;

  TVDvlaID leafVLA;
  TGRid    leafID;
  TGRid    parentID;
  
  IGRint   i;

  // Init
  VDvlaID_Construct(&leafVLA);

  // Get the leafs
  VDatCMDLeafGetSelectedLeafs(fl,&leafVLA);

  // Cycle through
  for(i = 0; VDvlaID_GetAt(&leafVLA,&leafID,i); i++) {

    VDatGetParentNode(&leafID,&parentID);
    VDatCMDTreeRemoveRow(fl,&leafID); // Tree node is protected

    VDatDeleteBase(&leafID);
    VDatSummarizeNode(&parentID);

  }

  // Update the form
  VDatCMDLeafFillLists(fl);
  
//wrapup:
  VDvlaID_Delete(&leafVLA);
  return retFlag;
}

/* ---------------------------------------------------
 * Unselect all leafs
 */
IGRstat VDatCMDLeafNotifyUnSelectAll(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form    = fl->leaf;
 
  VDatFormUnSelectGadget(form,VDAT_FORM_LEAF_G_PLATES,0,1);
  VDatFormUnSelectGadget(form,VDAT_FORM_LEAF_G_BEAMS, 0,1);
  VDatFormUnSelectGadget(form,VDAT_FORM_LEAF_G_OTHERS,0,1);

  retFlag = 1;
  return retFlag;
}

/* ---------------------------------------------------
 * Unhilite all leafs
 */
#argsused
IGRstat VDatCMDLeafNotifyUnHiLiteAll(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
 
  VDatFormUnHiLiteAll();

  retFlag = 1;
  return retFlag;
}

IGRstat VDatCMDLeafNotifyHiLiteSelect(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form    = fl->leaf;

  VDatFormUnHiLiteAll();
  VDatFormHiLiteGadget(form,VDAT_FORM_LEAF_G_PLATES,0,1);
  VDatFormHiLiteGadget(form,VDAT_FORM_LEAF_G_BEAMS, 0,1);
  VDatFormHiLiteGadget(form,VDAT_FORM_LEAF_G_OTHERS,0,1);
 
  retFlag = 1;
  return retFlag;
}

/* ------------------------------------------
 * Adds any selected items to vla
 */
IGRstat VDatCMDLeafGetSelectedLeaf(Form form, IGRint gadget, TVDvlaID *leafVLA)
{
  IGRstat retFlag;
  IGRint  row,rows,sel;
  TGRid   leafID;

  rows = -1;
  VIfld_get_num_rows(form,gadget,&rows);
  for(row = 0; row < rows; row++) {

    VIfld_get_select(form,gadget,row,0,&sel);
    if (sel == 1) {
      VDahFrmGetGRid(form,gadget,row,1,&leafID);
      if (leafID.objid != NULL_OBJID) {
        VDvlaID_Append(leafVLA,&leafID);
      }
    }
  }
  retFlag = 1;
  return retFlag;
}

/* -----------------------------------------
 * Gets any currently selected leafs
 */
IGRstat VDatCMDLeafGetSelectedLeafs(TVDatFrmList *fl,TVDvlaID *leafVLA)
{
  IGRstat retFlag = 0;
  Form    form = fl->leaf;

  // Make sure active
  //if (VDatFormIsActive(form) != 1) goto wrapup;

  // Do each gadget
  VDatCMDLeafGetSelectedLeaf(form,VDAT_FORM_LEAF_G_PLATES,leafVLA);
  VDatCMDLeafGetSelectedLeaf(form,VDAT_FORM_LEAF_G_BEAMS, leafVLA);
  VDatCMDLeafGetSelectedLeaf(form,VDAT_FORM_LEAF_G_OTHERS,leafVLA);

  retFlag = 1;
//wrapup:
  return retFlag;
}

IGRstat VDatCMDLeafEventLeafs( TVDatFrmList *fl)
{
  IGRstat  retFlag = 0;

  TVDvlaID leafVLA;
  TGRid    leafID;
  IGRlong  msg;

  TGRobj_env modelOE;
  Form       form = fl->leaf;
  IGRint     i;

  // Make sure active
  //if (VDatFormIsActive(form) != 1) goto wrapup;

  // Init
  VDvlaID_Construct(&leafVLA);

  // Get the leafs
  VDatCMDLeafGetSelectedLeafs(fl,&leafVLA);
  if( !VDvlaID_GetCnt(&leafVLA) ) goto wrapup;

  // Get the First Leaf Object.
  VDvlaID_GetAt(&leafVLA,&leafID,0);

  // Get The Model Object
  VDtrget_modelObject( &leafID, &modelOE );

  // Put the object in the Event
  ASputobj( &msg, modelOE.obj_id.objid, modelOE.obj_id.osnum,
	    &modelOE.mod_env );

wrapup:

  // Set the button state to off.
  FIg_set_state_off ( form, VDAT_FORM_LEAF_B_EVENT );

  VDvlaID_Delete(&leafVLA);
  return retFlag;
}
  
/* -----------------------------------------
 * Some objects were picked
 */
IGRstat VDatCMDLeafNotifyObject(TVDatFrmList *fl, TVDvlaOE *setVLA)
{
  IGRstat retFlag = 0;
  
  Form    form = fl->leaf;
  TGRid   setID,leafID,lastID;
  IGRint  i,objExt,objNew,state;
  IGRchar buf[128];

  TGRobj_env objOE;
  
  // Ignore if the form is not active
  if (VDatFormIsActive(form) != 1) goto wrapup;

  // Get the active set
  VDatCMDAllGetActiveSet(fl,&setID,NULL);
  if (setID.objid == NULL_OBJID) goto wrapup;

  // The last leaf processed will become the active leaf
  lastID.objid = NULL_OBJID;

  // User feedback
  objExt = objNew = 0;

  // Cycle through
  for(i = 0; VDvlaOE_GetAt(setVLA,&objOE,i); i++ ) {

    // See if already in set
    VDatGetObjectLeaf(&objOE, &setID, &leafID);

    if (leafID.objid != NULL_OBJID) {
      objExt++;
      VDatCMDLeafSelectInLists(form,&leafID);
      lastID = leafID;
    }
    else {

      VIg_get_state(form,VDAT_FORM_LEAF_T_ADD,&state);
      if (state) {

        objNew++;

        VDatCreateLeaf(&setID,&objOE,&leafID);
        if (leafID.objid == NULL_OBJID) {
          printf("Problem creating leaf for\n");
          VDbroPrintObj(&objOE.obj_id);
          goto wrapup;
        }
        else {
          VDatCMDLeafAddToLists(form,&leafID);
          lastID = leafID;
        }
      }
    }
  }

  // Make the last one active
  if (lastID.objid != NULL_OBJID) {
    VDatCMDAllSetActiveLeaf(fl,&lastID);
  }

  // Status
  sprintf(buf,"New %d, Existing %d",objNew,objExt);
  VIg_set_text(form,10,buf);

  retFlag = 1;
wrapup:
  VDatCMDLeafHiLiteLists(fl);
  return retFlag;
}

/* ----------------------------------------
 * Initializes the form with a new active set
 */
IGRstat VDatCMDLeafActivateSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  Form    form = fl->leaf;

  TGRid   setID;
  IGRchar setName[128];
  IGRchar setType[128];

  IGRint  i;

  IGRchar listTxt[64];
  IGRint  listInd;

  TGRid  pplID;
  IGRint pplRET;

  // Ignore if the form is not active
  sts = VDatFormIsActive(form);
  if (sts != 1) goto wrapup;

  // get the active set, if none just clear gadgets
  *setName = 0;
  VDatCMDAllGetActiveSet(fl,&setID,setName);

  // Wait until form pops up to avoid annoying delay
  // Update form
  VIg_set_text(form,VDAT_FORM_ALL_G_SET_NAME,setName);
  UI_status("Filling Leaf Form...");  
  VDatCMDLeafFillLists(fl);
  UI_status("Filled Leaf Form");

  // Disable some gadgets
  if (VDatIsSetInActiveOS(&setID)) {    
    VIg_enable(form,VDAT_FORM_LEAF_T_ADD);
    VIg_enable(form,VDAT_FORM_LEAF_B_REMOVE);
  }
  else {
    VIg_disable(form,VDAT_FORM_LEAF_T_ADD);
    VIg_disable(form,VDAT_FORM_LEAF_B_REMOVE);
  }

  // Update list labels based on active set
  if (setID.objid == NULL_OBJID) {
    for(i = 0; i < 3; i = i + 1) {
      sprintf(listTxt,"List %d",i+1);
      VIg_set_text(form,32 + i,listTxt);
    }
    retFlag = 1;
    goto wrapup;
  }

  VDatRDBGetSetType(&setID,setType);

  vdppl$Load(name = setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) {
    retFlag = 0;
    goto wrapup;
  }

  for(i = 0; i < 3; i = i + 1) {
    listInd = i;
    vdppl$SetData(pplID = &pplID,
                  name  = "LIST_IND",
                  size  = sizeof(IGRint),
                  data  = (char*)&listInd);

    vdppl$Run(pplID = &pplID, name = "getListText", ret = &pplRET);

    vdppl$GetData(pplID = &pplID,
                  name  = "LIST_TEXT",
                  size  = 64,
                  data  = listTxt);
    VIg_set_text(form, 32 + i,listTxt);
  }

  vdppl$Delete(pplID = &pplID);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------
 * Returns either the name or piece mark
 */
IGRstat VDatCMDLeafGetLeafName(Form form, TGRid *leafID, IGRchar *leafName)
{
  IGRstat retFlag = 0;
  IGRint  state;

  TGRobj_env pieceOE;
  IGRchar    setType[128];
  
  *leafName = 0;
  
  VIg_get_state(form,VDAT_FORM_LEAF_T_PCMK,&state);
  if (state) {

    vdsa$GetStruct(objID = leafID,
		   name = "pcmk",
		   txt   = leafName);

    /* -------------------------------------------
     * 07 Sep 2000
     *
     * It can happen that multiple nodes get attached to the same
     * piece, not sure how yet.  When this happens, the plate will return
     * a piece mark from one node making it appear that the other node
     * also has a piece mark.
     *
     * So for StagingTree, do not ask the plate for it's pcmk
     *
     *
     */
    if (atoi(leafName) < 1) {

      // If it is not staging tree then ask the plate itself
      VDatRDBGetSetType(leafID,setType);
      if (strcmp(setType,"StagingTree")) {
	
	// Try getting from piece object
	VDatGetLeafObject(leafID, &pieceOE);
	vdsa$GetStruct(objOE = &pieceOE,
		       name = "SA_AST:StagingTree:0:pcmk",
		       txt   = leafName);

	if (atoi(leafName) < 1) strcpy(leafName,"0");
      }
    }
  }
  else {
    VDatGetLeafName(leafID,leafName);
  }
  
  retFlag = 1;
  
  return retFlag;
}

/* ------------------------------
 * Adds leaf to gadget list
 */
IGRstat VDatCMDLeafAddToList(Form form, IGRint gadget, TGRid *leafID)
{
  IGRstat retFlag = 0;

  IGRint  rows;
  IGRchar leafName[128];

  enum GRdpmode mode = GRhhd;

  // Cycle through and find selected rows
  VIfld_get_num_rows(form,gadget,&rows);

  VDatCMDLeafGetLeafName(form,leafID,leafName);
  VDahFrmSetTextRC(form,gadget,rows,0,leafName);
  VDahFrmSetGRid  (form,gadget,rows,1,leafID);
  VIfld_set_select(form,gadget,rows,0,1);

  VDatDisplayNode (leafID,mode);
  VDatFormShowRow (form,gadget,rows);

  retFlag = 1;

//wrapup:
  return retFlag;
}

IGRstat VDatCMDLeafSelectInList(Form form, IGRint gadget, TGRid *a_leafID)
{
  IGRstat retFlag = 0;
  TGRid   leafID;
  IGRint  rows,row;

  enum GRdpmode mode = GRhhd;

  // Cycle through and find the leaf
  VIfld_get_num_rows(form,gadget,&rows);
  for(row = 0; row < rows; row++) {

    VDahFrmGetGRid(form,gadget,row,1,&leafID);

    if ((a_leafID->objid == leafID.objid) &&
        (a_leafID->osnum == leafID.osnum)) {

      VDatDisplayNode(&leafID,mode);
      VIfld_set_select(form,gadget,row,0,1);
      VDatFormShowRow (form,gadget,row);
      retFlag = 1;
      goto wrapup;

    }
  }
  
wrapup:
  return retFlag;
}

IGRstat VDatCMDLeafAddToLists(Form form, TGRid *leafID)
{
  IGRstat retFlag = 0;
  TGRid   listID;

  // See which gadget it is in
  VDatGetParentByType(leafID,VDAT_CLASSI_PLATES,&listID);
  if (listID.objid != NULL_OBJID) {
    VDatCMDLeafAddToList(form,VDAT_FORM_LEAF_G_PLATES,leafID);
    retFlag = 1;
    goto wrapup;
  }
  VDatGetParentByType(leafID,VDAT_CLASSI_BEAMS,&listID);
  if (listID.objid != NULL_OBJID) {
    VDatCMDLeafAddToList(form,VDAT_FORM_LEAF_G_BEAMS,leafID);
    retFlag = 1;
    goto wrapup;
  }
  VDatGetParentByType(leafID,VDAT_CLASSI_OTHERS,&listID);
  if (listID.objid != NULL_OBJID) {
    VDatCMDLeafAddToList(form,VDAT_FORM_LEAF_G_OTHERS,leafID);
    retFlag = 1;
    goto wrapup;
  }

wrapup:
  return retFlag;
}

IGRstat VDatCMDLeafSelectInLists(Form form, TGRid *leafID)
{
  IGRstat retFlag = 0;
  TGRid   listID;

  // See which gadget it is in
  VDatGetParentByType(leafID,VDAT_CLASSI_PLATES,&listID);
  if (listID.objid != NULL_OBJID) {
    VDatCMDLeafSelectInList(form,VDAT_FORM_LEAF_G_PLATES,leafID);
    retFlag = 1;
    goto wrapup;
  }
  VDatGetParentByType(leafID,VDAT_CLASSI_BEAMS,&listID);
  if (listID.objid != NULL_OBJID) {
    VDatCMDLeafSelectInList(form,VDAT_FORM_LEAF_G_BEAMS,leafID);
    retFlag = 1;
    goto wrapup;
  }
  VDatGetParentByType(leafID,VDAT_CLASSI_OTHERS,&listID);
  if (listID.objid != NULL_OBJID) {
    VDatCMDLeafSelectInList(form,VDAT_FORM_LEAF_G_OTHERS,leafID);
    retFlag = 1;
    goto wrapup;
  }

wrapup:
  return retFlag;
}

IGRstat VDatCMDLeafHiLiteList(Form form, IGRint gadget)
{
  IGRstat retFlag;
  TGRid   leafID;
  IGRint  rows,row,sel;

  enum GRdpmode mode = GRhhd;

  // Cycle through and find selected rows
  VIfld_get_num_rows(form,gadget,&rows);
  for(row = 0; row < rows; row++) {

    VIfld_get_select(form,gadget,row,0,&sel);
    if (sel == 1) {

      VDahFrmGetGRid(form,gadget,row,1,&leafID);
      VDatDisplayNode(&leafID,mode);

    }
  }

  retFlag = 1;
  return retFlag;
}

IGRstat VDatCMDLeafHiLiteLists(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form form = fl->leaf;

  // Hard code three lists
  VDatCMDLeafHiLiteList(form,VDAT_FORM_LEAF_G_PLATES);
  VDatCMDLeafHiLiteList(form,VDAT_FORM_LEAF_G_BEAMS);
  VDatCMDLeafHiLiteList(form,VDAT_FORM_LEAF_G_OTHERS);

  retFlag = 1;
  return retFlag;
}

IGRstat VDatCMDLeafNotifyList(TVDatFrmList *fl, IGRint gadget)
{
  IGRstat retFlag = 0;
  Form form = fl->leaf;

  TGRid   leafID;
  IGRint  row,pos;
  IGRint  sel;
  IGRchar buf[128];
  TGRobj_env pieceOE;
  
  enum GRdpmode mode;

  // Get the row
  row = -1;
  VIfld_get_active_row(form,gadget,&row,&pos);
  if (row < 0) goto wrapup;

  VDahFrmGetGRid(form,gadget,row,1,&leafID);
  if (leafID.objid == NULL_OBJID) goto wrapup;

  // Hilite or not
  sel = -1;
  VIfld_get_select(form,gadget,row,0,&sel);
  if (sel == 1) mode = GRhhd;
  else          mode = GRhe;

  // Hilite
  VDatDisplayNode(&leafID,mode);

  // Update status
  VDatGetLeafObject(&leafID, &pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) strcpy(buf,"MODEL NOT CONNECTED");
  else sprintf(buf,"MODEL %d,%d",pieceOE.obj_id.osnum,pieceOE.obj_id.objid);
  vdfrm$SetStatus(form = form, txt = buf);
  
  // Tell rest of the world
  VDatCMDAllSetActiveLeaf(fl,&leafID);
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/*------------------------------------------------------------
 * Sort Leaf form by peace marks, added by ylong for TR179901068.
 * SortFormByPcmk() is called by VDatCMDLeafFillList().
 */
typedef struct {
  IGRint pcmk ;
  TGRid  leafID ;
} TVDatPcmkSortNode ;

IGRint VDatCMDLeafSortLeafNode(TVDatPcmkSortNode *node1, TVDatPcmkSortNode *node2)
{
  return  ( node1->pcmk - node2->pcmk ) ;
}

IGRstat VDatCMDLeafSortGadgetByPcmk(Form form, IGRint gadget, IGRint numRows)
{
  IGRstat       retFlag   = 0 ;
  TVDatPcmkSortNode  *sortList = NULL ; 
  IGRchar	pcmkStr[128] ;	
  IGRint	row ;

  sortList = _CALLOC( numRows, TVDatPcmkSortNode);
  if( sortList == NULL ) goto wrapup ;

  for( row = 0; row < numRows; row++ ) {
    VDahFrmGetTextRC(form, gadget, row, 0,  pcmkStr );
    VDahFrmGetGRid  (form, gadget, row, 1, &sortList[row].leafID);
    sortList[row].pcmk = atoi(pcmkStr);
  }
	
  qsort((char *)(sortList), 
	numRows, 
	sizeof(TVDatPcmkSortNode), 
	(int (*)())VDatCMDLeafSortLeafNode);

  for( row = 0; row < numRows; row++ ) {
      sprintf(pcmkStr, "%d", sortList[row].pcmk);
      VDahFrmSetTextRC(form, gadget, row, 0,  pcmkStr);
      VDahFrmSetGRid  (form, gadget, row, 1, &sortList[row].leafID);
  }
	
  retFlag = 1 ;

wrapup:
  _FREE( sortList ) ;
  return retFlag ;
}


/* ------------------------------------------
 * Fill up list
 */
IGRstat VDatCMDLeafFillList(Form form, IGRint gadget, TGRid *listID)
{
  IGRstat retFlag = 0;
  TGRid   leafID,nodeID;
  IGRint  i,row;
  IGRchar name[128];
  IGRint  flag,show, pcmkToggle ;

  // Init
  FIfld_set_num_rows(form,gadget,0);
  if (listID->objid == NULL_OBJID) goto wrapup;

  // All or ones not in tree
  flag = 0;
  VIg_get_state(form,VDAT_FORM_LEAF_T_SHOW,&flag);

  // Cycle through
  row = 0;
  for(i = 0; VDatGetChildObject(listID,i,&leafID); i++) {

    show = 1;
    if (flag == 1) {
      VDatGetParentNode(&leafID,&nodeID);
      if (nodeID.objid != NULL_OBJID) {
	show = 0;
	// printf("Not in tree %d\n",leafID.objid);
      }
    }
    if (show == 1) {
      VDatCMDLeafGetLeafName(form,&leafID,name);
      VDahFrmSetTextRC(form,gadget,row,0,name);
      VDahFrmSetGRid  (form,gadget,row,1,&leafID);
      row++;
    }
  }

  // Added by ylong for TR179901068
  VIg_get_state(form,VDAT_FORM_LEAF_T_PCMK,&pcmkToggle);
  if( show == 1 && pcmkToggle ) {
    VDatCMDLeafSortGadgetByPcmk( form, gadget, row ) ;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Fill the leaf gadgets
 */
IGRstat VDatCMDLeafFillLists(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  TGRid   setID,leafsID,listID;

  Form    form = fl->leaf;

  // Empty the gadgets
  VIfld_set_num_rows(form,VDAT_FORM_LEAF_G_PLATES,0);
  VIfld_set_num_rows(form,VDAT_FORM_LEAF_G_BEAMS, 0);
  VIfld_set_num_rows(form,VDAT_FORM_LEAF_G_OTHERS,0);

  // Get the set
  VDatCMDAllGetActiveSet(fl,&setID,NULL);
  if (setID.objid == NULL_OBJID) goto wrapup;

  // Get the leafs
  VDatGetLeafs(&setID,&leafsID);
  if (leafsID.objid == NULL_OBJID) goto wrapup;

  // Hard code three types of sub leafs
  VDatGetChildByType(&leafsID,VDAT_CLASSI_PLATES,     &listID);
  VDatCMDLeafFillList(form,   VDAT_FORM_LEAF_G_PLATES,&listID);

  VDatGetChildByType(&leafsID,VDAT_CLASSI_BEAMS,     &listID);
  VDatCMDLeafFillList(form,   VDAT_FORM_LEAF_G_BEAMS,&listID);

  VDatGetChildByType(&leafsID,VDAT_CLASSI_OTHERS,     &listID);
  VDatCMDLeafFillList(form,   VDAT_FORM_LEAF_G_OTHERS,&listID);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * The notification routine
 */
#argsused
IGRstat VDatCMDLeafNotifyForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form;
  IGRint  gadget;

  // Form has all global data
  form   = fl->form;
  gadget = fl->gadget;

  switch(gadget) {

  case VDAT_FORM_LEAF_T_SHOW: {
    VDatCMDLeafFillLists(fl);
    retFlag = 1;
    goto wrapup;
  }
  case VDAT_FORM_LEAF_T_PCMK: {
    VDatCMDLeafFillLists(fl);
    retFlag = 1;
    goto wrapup;
  }
  case VDAT_FORM_LEAF_G_PLATES : {
    VDatCMDLeafNotifyList(fl,gadget);
    retFlag = 1;
    goto wrapup;
  }
  case VDAT_FORM_LEAF_G_BEAMS : {
    VDatCMDLeafNotifyList(fl,gadget);
    retFlag = 1;
    goto wrapup;
  }
  case VDAT_FORM_LEAF_G_OTHERS : {
    VDatCMDLeafNotifyList(fl,gadget);
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_FORM_LEAF_B_UNSELECT_ALL:  {
    retFlag = VDatCMDLeafNotifyUnSelectAll(fl);
    goto wrapup;
  }
  case VDAT_FORM_LEAF_B_UNHILITE_ALL:  {
    retFlag = VDatCMDLeafNotifyUnHiLiteAll(fl);
    goto wrapup;
  }
  case VDAT_FORM_LEAF_B_HILITE_SELECT: {
    retFlag = VDatCMDLeafNotifyHiLiteSelect(fl);
    goto wrapup;
  }
  case VDAT_FORM_LEAF_B_REMOVE: {
    retFlag = VDatCMDLeafNotifyRemoveLeafs(fl);
    goto wrapup;
  }

  case VDAT_FORM_LEAF_B_EVENT: {
    retFlag = VDatCMDLeafEventLeafs(fl);
    goto wrapup;
  }

  case FI_CANCEL: {
    VIf_erase(form);
    VDatFormSetActive(form,0);
    retFlag = 1;
    goto wrapup;
  }
  }

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDatCMDLeafActivateForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  Form    form;

  // Arg check
  if ((fl == NULL) || (fl->leaf == NULL)) goto wrapup;
  form = fl->leaf;

  // Ignore if already active for now
  sts = VDatFormIsActive(form);
  if (sts == 1) {
    retFlag = 1;
    goto wrapup;
  }

  // Just display
  VIf_display(form);
  VDatFormSetActive(form,1);

  // And activate
  VDatCMDLeafActivateSet(fl);

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;
