/* $Id: VDatTreeF.I,v 1.2 2001/01/11 20:23:18 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/cmd/VDatTreeF.I
 *
 * Description: Aux Tree Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatTreeF.I,v $
 *      Revision 1.2  2001/01/11 20:23:18  art
 *      sp merge
 *
# Revision 1.4  2000/10/15  13:58:42  pinnacle
# For ylong
#
# Revision 1.3  2000/08/22  15:14:44  pinnacle
# ah
#
# Revision 1.2  2000/06/27  16:37:52  pinnacle
# ah
#
# Revision 1.1  2000/06/09  19:21:12  pinnacle
# ah
#
# Revision 1.3  1999/01/21  16:07:16  pinnacle
# Replaced: vdat/cmd/VDatTreeF.I for:  by vsrivast for vds
#
# Revision 1.2  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/10/97  ah      creation
 * 01/21/99  vinit   Modified VDatFormFillTree to handle production data sets
 * 08/22/00  ah      Set form status when hiliting
 * 09/28/00  ylong   CR179902008 sort loose pieces by pcmk
 ***************************************************************************/

/* Tree Specific Forms Routines */

class implementation VDatBase;

#include "VDatCmd.h"
#include "v_dbgmacros.h"
#include "VDfrmMacros.h"

/* ------------------------------------------------
 * Clears all selected rows in tree
 */
IGRstat VDatFormClearTree(Form form, IGRint gadget)
{
  IGRstat retFlag = 0;
  IGRint  row,rowMax,sel;
  IGRint  col = VDAT_FORM_C_TREE_NAME;

  rowMax = -1;
  VIfld_get_num_rows(form,gadget,&rowMax);
  for(row = 0; row < rowMax; row++) {

    sel = -1;
    VIfld_get_select(form,gadget,row,col,&sel);
    if (sel == 1) {

      VIfld_set_select(form,gadget,row,col,0);

    }
  }

  retFlag = 1;
  return retFlag;
}

/* ------------------------------------------------
 * Updates a row by contracting then expanding
 */
IGRstat VDatFormUpdateTreeRow(Form form, IGRint gadget, TGRid *rowID)
{
  IGRstat retFlag = 0;
  IGRint  row;

  // Update the tree gadget
  row = -1;
  VDatFormFindTreeRow(form,gadget,rowID,&row);
  if (row == -1) goto wrapup;

  VDatFormContractTreeRow(form,gadget,row);
  VDatFormExpandTreeRow  (form,gadget,row);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Finds row in tree gadget containing id
 */
IGRstat VDatFormFindTreeRow(
  Form   form, 
  IGRint gadget, 
  TGRid *workID, 
  IGRint *rowFound)
{
  IGRstat retFlag = 0;
  IGRint  row,rowMax;
  TGRid   rowID;

  *rowFound = -1;

  rowMax = -1;
  VIfld_get_num_rows(form,gadget,&rowMax);

  for(row = 0; row < rowMax; row++) {

    rowID.objid = NULL_OBJID;
    VDahFrmGetGRid(form,gadget,row,3,&rowID);

    if ((rowID.objid == workID->objid) &&
        (rowID.osnum == workID->osnum)) {

      *rowFound = row;
      return 1;
    }
  }

  return retFlag;
}

/* ----------------------------------------
 * Handles Node Name Changes
 */
IGRstat VDatFormRefreshNodeName(
  Form    form, 
  IGRint  gadget, 
  IGRint  row, 
  TGRid  *nodeID
  )
{
  IGRstat  retFlag = 0;

  IGRchar  desc[1024];
  IGRchar *pnt;
  IGRint   i;

  IGRint   level;
  IGRchar  buf[128];
  
  // Need level for indenting
  *buf = 0;
  VDahFrmGetTextRC(form,gadget,row,4,buf);
  level = atoi(buf);

  // Indent
  *desc = 0;
  for(i = 0, pnt = desc; i < level; i++) *pnt++ = ' ';
  *pnt = 0;
  
  VDatGetDisplayName(nodeID,pnt);
  VDahFrmSetTextRC(form,gadget,row,2,desc);

  retFlag = 1;
  return retFlag;
  
}


/* ----------------------------------------
 * Fill in one row in tree gadget
 */
IGRstat VDatFormFillTreeRow(
  Form    form, 
  IGRint  gadget, 
  IGRint *row, 
  IGRint  level,
  TGRid  *nodeID,
  IGRint  atrFlag,
  IGRint  expFlag
)
{
  IGRstat  retFlag = 0;
  IGRchar  desc[1024];
  IGRchar *pnt;
  IGRint   i;
  IGRint   type;
  
  // Arg Check
  if (nodeID->objid == NULL_OBJID) goto wrapup;

  // Get it's desc
  for(i = 0, pnt = desc; i < level; i++) *pnt++ = ' ';
  *pnt = 0;
  
  VDatGetDisplayName(nodeID,pnt);
  VDahFrmSetTextRC(form,gadget,*row,2,desc);

  // Attribute Flag
  if (atrFlag == 0) VDahFrmSetTextRC(form,gadget,*row,0,"-");
  else              VDahFrmSetTextRC(form,gadget,*row,0,"+");

  // If type is a leaf then no expansion allowed
  if (expFlag == 0) strcpy(desc,"-");
  else              strcpy(desc,"+");

  type = 0;
  VDatGetBaseType(nodeID,&type);
  if (type == VDAT_CLASSI_LEAF) strcpy(desc," ");

  VDahFrmSetTextRC(form,gadget,*row,1,desc);
  
  // ID
  VDahFrmSetGRid(form,gadget,*row,3,nodeID);

  // Level
  sprintf(desc,"%d",level);
  VDahFrmSetTextRC(form,gadget,*row,4,desc);

  // Done
  *row = *row + 1;
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Fill in tree gadget
 */
IGRstat VDatFormFillTree(Form form, IGRint gadget, TGRid *setID)
{
  IGRstat retFlag = 0;

  IGRint  row;
  IGRuint i;

  TGRid treeID;
  TGRid nodeID;
  TGRid node1ID;

  // Clear Field
  VIfld_set_num_rows(form,gadget,0);

  // See if set was pass
  if (setID != NULL) {
    if (setID->objid == NULL_OBJID) goto wrapup;
    VDatGetTree(setID,&treeID);

    // If treeID is NULL it can be a Production Data set.

    if (treeID.objid == NULL_OBJID) {

	row =0;
	VDatGetChildObject(setID, 0, &node1ID);
    	VDatFormFillTreeRow(form,gadget,&row,0,&node1ID,0,1);


	// Put out the next level
  	for(i = 0; VDatGetChildObject(&node1ID,i,&nodeID); i++){ 
    	VDatFormFillTreeRow(form,gadget,&row,1,&nodeID,0,0);
  	}
      goto wrapup;
    }
  }
  else {
    VDatFormGetTreeID(form,&treeID);
    if (treeID.objid == NULL_OBJID) goto wrapup;
  }

  // Put out top node
  row = 0;
  VDatFormFillTreeRow(form,gadget,&row,0,&treeID,0,1);

  // Put out next level
  for(i = 0; VDatGetChildObject(&treeID,i,&nodeID); i++) {
    VDatFormFillTreeRow(form,gadget,&row,1,&nodeID,0,0);
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Expand a row if it is contracted
 */
IGRstat VDatFormExpandTreeAttrRow(Form form, IGRint gadget, IGRint row)
{
  IGRstat retFlag = 0;
  IGRchar buf[1024];
  IGRchar pre[128];
  TGRid   rootID;
  IGRuint i,level;

  IGRint   cnt;
  TVDatFld flds[128];

  // See if expand or contract
  *buf = 0;
  VDahFrmGetTextRC(form,gadget,row,0,buf);
  if (*buf != '-') goto wrapup;

  // Get the id
  VDahFrmGetGRid(form,gadget,row,3,&rootID);
  if (rootID.objid == NULL_OBJID) goto wrapup;

  // Get the level for prefix blanks
  *buf = 0;
  VDahFrmGetTextRC(form,gadget,row,4,buf);
  level = atoi(buf) + 1;
  for(i = 0; i < level; i++) pre[i] = ' ';
  pre[i] = 0;

  // Set expand flag
  VDahFrmSetTextRC(form,gadget,row,0,"+");

  // Insert kids
  row++;

  cnt = 0;
//VDatFldGetAllAttrs(&rootID,flds,&cnt);

//printf("Got %d attributes\n",cnt);

  VDatFldGetAttrsByPrefix(&rootID,"u_",flds,&cnt);

  VDatFldGetAllAttrs(&rootID,flds,&cnt);

  for(i = 0; i < cnt; i++) {
    *buf = 0;
    switch(flds[i].type) {
      case VDAT_FLD_TYPE_CHAR:   sprintf(buf,"%s%s = %s",  pre,flds[i].name,flds[i].valueTxt); break;
      case VDAT_FLD_TYPE_DOUBLE: sprintf(buf,"%s%s = %.2f",pre,flds[i].name,flds[i].valueDbl); break;
      case VDAT_FLD_TYPE_INT:    sprintf(buf,"%s%s = %d",  pre,flds[i].name,flds[i].valueInt); break;
    }
    VIfld_insert_blank_row(form,gadget,row);
    VDahFrmSetTextRC(form,gadget,row,0," ");
    VDahFrmSetTextRC(form,gadget,row,1," ");
    VDahFrmSetTextRC(form,gadget,row,2,buf);

    sprintf(buf,"%d",level);
    VDahFrmSetTextRC(form,gadget,row,4,buf);

    row++;
  }
   
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Contract a row if it is expanded
 */
IGRstat VDatFormContractTreeAttrRow(Form form, IGRint gadget, IGRint row)
{
  IGRstat retFlag = 0;
  IGRchar buf[128];

  IGRint  rowX,rowMax,rowCnt;

  // See if expand or contract
  *buf = 0;
  VDahFrmGetTextRC(form,gadget,row,0,buf);
  if (*buf != '+') goto wrapup;

  // Set contract flag
  VDahFrmSetTextRC(form,gadget,row,0,"-");

  // Delete rows
  rowMax = 0;
  VIfld_get_num_rows(form,gadget,&rowMax);
  rowMax++;

  *buf = ' ';
  row++;

  for(rowX = row; (rowX < rowMax) && (*buf == ' '); rowX++) {
    *buf = 0;
    VDahFrmGetTextRC(form,gadget,rowX,0,buf);
  }

  rowCnt = rowX - row - 1;
  if (rowCnt > 0) {
    VIfld_delete_rows(form,gadget,row,rowCnt);
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Sort inserted rows based on pcmk, added by ylong for CR179902008
 */
#include "VDmem.h"

typedef struct {
	TGRid	nodeID;
	IGRchar	buf[128];
} TVDsortList;

IGRint	VDatSortPcmk( TVDsortList *e1, TVDsortList *e2 )
{
  IGRchar	buf1[128], buf2[128], *ptr1 = NULL, *ptr2 = NULL;
  IGRint	pcmk1, pcmk2;

  ptr1 = strchr(e1->buf, ',');
  if( ptr1 == NULL ) {
	pcmk1 = 0;
  }
  else {
	strcpy(buf1, e1->buf);
	ptr1 = strtok(buf1, ",");
	pcmk1 = atoi(ptr1);
  }

  ptr2 = strchr(e2->buf, ',');
  if( ptr2 == NULL ) {
	pcmk2 = 0;
  }
  else {
	strcpy(buf2, e2->buf);
	ptr2 = strtok(buf2, ",");
	pcmk2 = atoi(ptr2);
  }

  return (pcmk1 - pcmk2);
}

IGRstat VDatFormSortRows( 
Form	form, 
IGRint	gadget, 
IGRint	level, 
IGRint	end_row, 
IGRint	nrow)
{
  IGRstat retFlag = 0;
  IGRint  i, start_row, j = 0;
  IGRchar buf[128];
  TVDsortList *sortList = NULL;

  if( end_row < 0 || nrow < 1 ) goto wrapup;

  sortList = _CALLOC(nrow, TVDsortList);
  if( sortList == NULL ) goto wrapup;

  start_row = end_row - nrow ;
  for(i = start_row; i < end_row; i++ ) {
    VDahFrmGetTextRC(form, gadget, i, 2, sortList[j].buf);
    VDahFrmGetGRid(form, gadget, i, 3, &sortList[j].nodeID);
    j++;
  }

  qsort((char *)(sortList), nrow, sizeof(TVDsortList), (int (*)())VDatSortPcmk);

  for(i = 0; i< nrow; i++) {
    VDatFormFillTreeRow (form,gadget,&start_row,level,&sortList[i].nodeID,0,0);
  }
  
  retFlag  = 1;
wrapup:
  _FREE(sortList);
  return retFlag;
}

/* ---------------------------------------------
 * Expand a row if it is contracted
 */
IGRstat VDatFormExpandTreeRow(Form form, IGRint gadget, IGRint row)
{
  IGRstat retFlag = 0;
  IGRint  level;
  IGRchar buf[128];
  TGRid   rootID,nodeID;
  IGRuint i;

  // Contract attributes
  VDatFormContractTreeAttrRow(form, gadget, row);

  // See if expand or contract
  *buf = 0;
  VDahFrmGetTextRC(form,gadget,row,1,buf);
  if (*buf != '-') goto wrapup;

  // Get level
  *buf = 0;
  VDahFrmGetTextRC(form,gadget,row,4,buf);
  level = atoi(buf);

  // Get the id
  VDahFrmGetGRid(form,gadget,row,3,&rootID);
  if (rootID.objid == NULL_OBJID) goto wrapup;

  // Set expand flag
  VDahFrmSetTextRC(form,gadget,row,1,"+");

  // Insert kids
  level++;
  row++;
  for(i = 0; VDatGetChildObject(&rootID,i,&nodeID); i++) {
    VIfld_insert_blank_row(form,gadget, row);
    VDatFormFillTreeRow   (form,gadget,&row,level,&nodeID,0,0);
  }

  // Sort inserted rows based on pcmk, added by ylong for CR179902008
  VDatFormSortRows(form, gadget, level, row, i);

  retFlag = 1;

wrapup:
  return retFlag;
}


/* ---------------------------------------------
 * Contract a row if it is expanded
 */
IGRstat VDatFormContractTreeRow(Form form, IGRint gadget, IGRint row)
{
  IGRstat retFlag = 0;
  IGRint  level,levelX;
  IGRchar buf[128];

  IGRint  rowX,rowMax,rowCnt;

  // Contract attributes
  VDatFormContractTreeAttrRow(form, gadget, row);

  // See if expand or contract
  *buf = 0;
  VDahFrmGetTextRC(form,gadget,row,1,buf);
  if (*buf != '+') goto wrapup;

  // Get level
  *buf = 0;
  VDahFrmGetTextRC(form,gadget,row,4,buf);
  level = atoi(buf);

  // Set contract flag
  VDahFrmSetTextRC(form,gadget,row,1,"-");

  // Delete rows
  rowMax = 0;
  VIfld_get_num_rows(form,gadget,&rowMax);
  rowMax++;

  levelX = level + 1;
  row++;

  for(rowX = row; (rowX < rowMax) && (levelX > level); rowX++) {
    *buf = 0;
    VDahFrmGetTextRC(form,gadget,rowX,4,buf);
    levelX = atoi(buf);
  }
  rowCnt = rowX - row - 1;
  if (rowCnt > 0) {
    VIfld_delete_rows(form,gadget,row,rowCnt);
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Deletes row from tree
 * Collapse it first to make sure all down stream items
 * Get passed as well
 */
IGRstat VDatFormDeleteTreeRow(Form form, IGRint gadget, IGRint row)
{
  VDatFormContractTreeRow(form,gadget,row);
  VIfld_delete_rows(form,gadget,row,1);
  return 1;
}
IGRstat VDatFormDeleteTreeRowID(Form form, IGRint gadget, TGRid *rowID)
{
  IGRstat retFlag = 0;
  IGRint row;

  VDatFormFindTreeRow(form,gadget,rowID,&row);
  if (row < 0) goto wrapup;

  retFlag = VDatFormDeleteTreeRow(form,gadget,row);

  retFlag = 1;
wrapup:
  return 1;
}

/* ----------------------------------------
 * Tree expand notification
 */
#argsused

IGRstat VDatFormNotifyTreeExp(
  Form   form, 
  IGRint gadget, 
  IGRint row, 
  TGRid *rootID
)
{
  IGRstat  retFlag = 0;
  IGRchar  buf[32];

  // Unselect it
  VIfld_set_select(form,gadget,row,1,0);

  // See if expand or contract
  *buf = 0;
  VDahFrmGetTextRC(form,gadget,row,1,buf);

  switch(*buf) {  

  case '-': {
    VDatFormExpandTreeRow(form,gadget,row);
    retFlag = 1;
    break;
  }

  case '+': {
    VDatFormContractTreeRow(form,gadget,row);
    retFlag = 1;
    break;
  }
  }
  retFlag = 1;

  return retFlag;
}

/* ----------------------------------------
 * Tree attribute notification
 */
#argsused

IGRstat VDatFormNotifyTreeAttr(
  Form   form, 
  IGRint gadget, 
  IGRint row, 
  TGRid *rootID
)
{
  IGRstat  retFlag = 0;
  IGRchar  buf[32];

  // Unselect it
  VIfld_set_select(form,gadget,row,1,0);

  // See if expand or contract
  *buf = 0;
  VDahFrmGetTextRC(form,gadget,row,0,buf);

  switch(*buf) {  

  case '-': {
    VDatFormExpandTreeAttrRow(form,gadget,row);
    retFlag = 1;
    break;
  }

  case '+': {
    VDatFormContractTreeAttrRow(form,gadget,row);
    retFlag = 1;
    break;
  }
  }
  retFlag = 1;

  return retFlag;
}

/* ----------------------------------------
 * Tree name notification
 */
IGRstat VDatFormNotifyTreeName(
  Form   form, 
  IGRint gadget, 
  IGRint row, 
  TGRid *treeID
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  treeSel,workSel;

  enum GRdpmode mode;

  // See if row is now selected
  treeSel = -1;
  VIfld_get_select(form,gadget,row,2,&treeSel);
  if (treeSel) {

    // See if in select work node mode
    workSel = -1;
    VIg_get_state(form,VDAT_FORM_B_WORK,&workSel);

    if (workSel) {

//      sts = VDatFormFillWork(form,VDAT_FORM_G_WORK,treeID);

      sts = 0;

      if (sts & 1) {
        VIg_set_state   (form,VDAT_FORM_B_WORK,0);
        VIfld_set_select(form,gadget,row,2,0);
        retFlag = 1;
        goto wrapup;
      }
    }
  }

  // Highlite
  if (treeSel == 0) mode = GRhe;
  else              mode = GRhd;

  vdfrm$SetStatus(form = form, txt = "Hiliting...");
  VDatDisplayNode(treeID,mode);
  vdfrm$SetStatus(form = form, txt = "Hiliting Complete.");

  retFlag = 1;

wrapup:

  return retFlag;
}

/* ----------------------------------------
 * Tree notification
 */
IGRstat VDatFormNotifyTree(Form form, IGRint gadget, TGRid *a_nodeID)
{
  IGRint retFlag = 0;

  IGRint row = -1;
  IGRint pos;
  IGRint sel;

  TGRid nodeID;

  // Get the row
  VIfld_get_active_row(form,gadget,&row,&pos);

  // Get ID
  VDahFrmGetGRid(form,gadget,row,3,&nodeID);
  if (a_nodeID != NULL) *a_nodeID = nodeID;
  if (nodeID.objid == NULL_OBJID) goto wrapup;

  // Expansion Column
  VIfld_get_select(form,gadget,row,1,&sel);
  if (sel == 1) {
    VDatFormNotifyTreeExp(form,gadget,row,&nodeID);
    retFlag = 1;
    goto wrapup;
  }

  // Attribute Column
  VIfld_get_select(form,gadget,row,0,&sel);
  if (sel == 1) {
    VDatFormNotifyTreeAttr(form,gadget,row,&nodeID);
    retFlag = 1;
    goto wrapup;
  }

  // Only name column left
  VDatFormNotifyTreeName(form,gadget,row,&nodeID);
  retFlag = 1;

wrapup:
  return retFlag;
}


end implementation VDatBase;

