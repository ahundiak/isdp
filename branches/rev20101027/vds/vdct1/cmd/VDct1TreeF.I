/* $Id: VDct1TreeF.I,v 1.3 2001/02/08 15:12:20 ad Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/cmd/VDct1TreeF.I
 *
 * Description: Aux Tree Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1TreeF.I,v $
 *      Revision 1.3  2001/02/08 15:12:20  ad
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/11 22:03:42  art
 *      sp merge
 *
# Revision 1.9  2000/12/08  21:28:26  pinnacle
# ah
#
# Revision 1.8  2000/07/20  20:16:12  pinnacle
# js
#
# Revision 1.7  2000/07/06  15:50:08  pinnacle
# pn
#
# Revision 1.6  2000/06/02  15:02:14  pinnacle
# ah
#
# Revision 1.5  2000/05/31  13:38:16  pinnacle
# Replaced: vds/vdct1/cmd/VDct1TreeF.I for:  by pnoel for Service Pack
#
# Revision 1.4  2000/05/23  18:30:54  pinnacle
# Replaced: vds/vdct1/cmd/VDct1TreeF.I for:  by pnoel for Service Pack
#
# Revision 1.3  2000/05/16  14:40:00  pinnacle
# Replaced: vds/vdct1/cmd/VDct1TreeF.I for:  by pnoel for Service Pack
#
# Revision 1.2  2000/05/09  19:17:18  pinnacle
# Replaced: vds/vdct1/cmd/VDct1TreeF.I for:  by pnoel for Service Pack
#
# Revision 1.1  2000/04/20  18:38:04  pinnacle
# Created: vds/vdct1/cmd/VDct1TreeF.I by pnoel for Service Pack
#
# Revision 1.4  2000/01/24  22:11:26  pinnacle
# ah
#
# Revision 1.3  2000/01/11  22:28:50  pinnacle
# ah
#
# Revision 1.1  1999/06/29  18:29:28  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/17/99  ah      creation
 * 01/10/00  pn      updated controls/safeops
 * 05/16/00  pn      updated some display features
 * 05/23/00  pn      updated several display features
 * 05/31/00  pn      installed form view controls
 * 02/08/01  yl      added VDct1ExpandTree and VDct1DisplayRecurse
 ***************************************************************************/

/* Tree Specific Forms Routines */

class implementation VDct1Base;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDfrm.h"
#include "VDsa.h"
#include "VDppl1.h"

#include "VDct1.h"
#include "VDct1Cmd.h"
#include "VDct1CmdTree.h"
#include "VDct1Forms.h"
#include "vdtr_macros.h"
#include "VDmem.h"

#define VDCT_FORM_TREE_COL_ATR          0
#define VDCT_FORM_TREE_COL_EXP          1
#define VDCT_FORM_TREE_COL_QTY          2
#define VDCT_FORM_TREE_COL_VER          3
#define VDCT_FORM_TREE_COL_DESC         4
#define VDCT_FORM_TREE_COL_GRID         5
#define VDCT_FORM_TREE_COL_LEVEL        6
#define VDCT_FORM_G_DISP               15

IGRstat VDct1FormClearTree      (Form form, IGRint gadget);
IGRstat VDct1FormUpdateTreeRow  (Form form, IGRint gadget, TGRid *rowID);

IGRstat VDct1FormContractTreeRow  (Form form, IGRint gadget, IGRint row);
IGRstat VDct1FormContractTreeRowID(Form form, IGRint gadget, TGRid *rowID);

IGRstat VDct1FormExpandTreeRow  (Form form, IGRint gadget, IGRint row);
IGRstat VDct1FormExpandTreeRowID(Form form, IGRint gadget, TGRid *rowID);

IGRstat VDct1FormFindTreeRow(Form    form, 
			     IGRint  gadget, 
			     TGRid  *workID, 
			     IGRint *rowFound);

IGRstat VDct1FormRefreshNodeName(Form    form, 
				 IGRint  gadget, 
				 IGRint  row, 
				 TGRid  *nodeID);

IGRstat VDct1FormFillTreeRow(Form    form, 
			     IGRint  gadget, 
			     IGRint *row, 
			     IGRint  level,
			     TGRid  *nodeID,
			     IGRint  atrFlag,
			     IGRint  expFlag);

IGRstat VDct1FormFillTree(Form form, IGRint gadget, TGRid *setID);

IGRstat VDct1FormExpandTreeAttrRow  (Form form, IGRint gadget, IGRint row);
IGRstat VDct1FormContractTreeAttrRow(Form form, IGRint gadget, IGRint row);

IGRstat VDct1FormDeleteTreeRow  (Form form, IGRint gadget, IGRint row);
IGRstat VDct1FormDeleteTreeRowID(Form form, IGRint gadget, TGRid *rowID);

IGRstat VDct1FormNotifyTreeName(Form   form, 
				IGRint gadget, 
				IGRint row, 
				TGRid *treeID);

IGRstat VDct1FormNotifyTree(Form form, IGRint gadget, TGRid *a_nodeID);

IGRstat VDct1FormNotifyTreeAttr(Form   form, 
				IGRint gadget, 
				IGRint row, 
				TGRid *rootID);

IGRstat VDct1FormNotifyTreeExp(Form   form, 
			       IGRint gadget, 
			       IGRint row, 
			       TGRid *rootID);

static int traceFlagx;

/* ------------------------------------------------
 * Clears all selected rows in tree
 */
IGRstat VDct1FormClearTree(Form form, IGRint gadget)
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;
  
  IGRint  row,rows,sel;
  IGRint  col = VDCT_FORM_TREE_COL_DESC;

  // Cycle through
  if (traceFlag) printf(">>> VDct1FormClearTree\n");
  
  vdfrm$GetNumRows(form = form, gadget = gadget, rows = &rows);
  for(row = 0; row < rows; row++) {

    vdfrm$GetSelect(form = form, gadget = gadget, row = row, col = col, sel = &sel);
    if (sel == 1) {
      vdfrm$SetSelect(form = form, gadget = gadget, row = row, col = col, sel = 0);
    }
  }

  retFlag = 1;
  if (traceFlag) printf("<<< VDct1FormClearTree(%d)\n",retFlag);
  return retFlag;
}

/* ------------------------------------------------
 * Updates a row by contracting then expanding
 */
IGRstat VDct1FormUpdateTreeRow(Form form, IGRint gadget,TGRid *rowID)
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;
  
  IGRint  row;
  TGRid   childID;
  IGRchar exp[4];

  if (traceFlag) printf(">>> VDct1FormUpdateTreeRow\n"); 
  // Update the tree gadget
  VDct1FormFindTreeRow(form,gadget,rowID,&row);
  if (row == -1) goto wrapup;

  // Get rid of any attribute expansion
  VDct1FormContractTreeAttrRow(form,gadget,row);

  // Contract it
  VDct1FormContractTreeRow(form,gadget,row);

  // If it has children then expand
  vdct1$GetTree1Child(objID = rowID,
		      nth   = 0,
		      outID = &childID); 

  if (childID.objid == NULL_OBJID) strcpy(exp," ");
  else                             strcpy(exp,"-");
  
  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_EXP,
		txt    = exp);
  
  VDct1FormExpandTreeRow(form,gadget,row);

  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1FormUpdateTreeRow(%d)\n",retFlag);
  return retFlag;
}

/* -----------------------------------------
 * Finds row in tree gadget containing id
 */
IGRstat VDct1FormFindTreeRow(
  Form    form, 
  IGRint  gadget, 
  TGRid  *workID, 
  IGRint *rowFound)
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;
  IGRint  row,rows;
  TGRid   rowID;

  // Init
  *rowFound = -1;
  if (traceFlag) printf(">>> VDct1FormFindTreeRow\n"); 
  // Cycle through
  vdfrm$GetNumRows(form = form, gadget = gadget, rows = &rows);
  for(row = 0; row < rows; row++) {

    vdfrm$GetText(form   = form, 
		  gadget = gadget, 
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_GRID,
		  objID  = &rowID);

    if ((rowID.objid == workID->objid) &&
        (rowID.osnum == workID->osnum)) {

      *rowFound = row;
      return 1;
    }
  }
  if (traceFlag) printf("<<< VDct1FormFindTreeRow(%d)\n",retFlag);
  return retFlag;
}

/* ----------------------------------------
 * Handles Node Name Changes
 */
IGRstat VDct1FormRefreshNodeName(Form    form, 
				 IGRint  gadget, 
				 IGRint  row, 
				 TGRid  *nodeID)
{
  IGRstat  retFlag = 0;
  IGRint   traceFlag = traceFlagx;
  IGRchar  desc[1024];
  IGRchar *pnt;
  IGRint   i;

  IGRint   level;
  IGRchar  buf[128];

  TVDctBaseInfo baseInfo;
  if (traceFlag) printf(">>> VDct1FormRefreshNodeName\n");   
  // Need level for indenting
  *buf = 0;
  vdfrm$GetText(form   = form, 
		gadget = gadget, 
		row    = row, 
		col    = VDCT_FORM_TREE_COL_LEVEL,
		txt    = buf);
  level = atoi(buf);

  // Indent
  *desc = 0;
  for(i = 0, pnt = desc; i < level; i++) *pnt++ = ' ';
  *pnt = 0;
  
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  strcpy(pnt,baseInfo.baseName);
  
  vdfrm$SetText(form   = form, 
		gadget = gadget, 
		row    = row, 
		col    = VDCT_FORM_TREE_COL_DESC,
		txt    = desc);
  //printf("Refreshed  %s\n",desc);
  
  retFlag = 1;
  if (traceFlag) printf("<<< VDct1FormRefreshNodeName(%d)\n",retFlag);
  return retFlag;
  
}

/* ----------------------------------------
 * Fill in one row in tree gadget
 */
IGRstat VDct1FormFillTreeRow(
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
  IGRstat  traceFlag = traceFlagx;
  IGRchar  desc[1024];
  IGRchar *pnt;
  IGRint   i;
  IGRchar  buf[128], buf1[128];
  IGRchar *c;
  TVDctBaseInfo baseInfo;
  TGRid childID;
  TGRid parentID;
  // TVDct1CmdInfo *cmdInfo;
  if (traceFlag) printf(">>> VDct1FormFillTreeRow\n");   
  // Arg Check
  if (nodeID->objid == NULL_OBJID) goto wrapup;

  // Get it's desc
  for(i = 0, pnt = desc; i < level; i++) *pnt++ = ' '; *pnt = 0;
  
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  strcpy(pnt,baseInfo.baseName);
  
  vdfrm$SetText(form   = form, 
		gadget = gadget, 
		row    = *row, 
		col    = VDCT_FORM_TREE_COL_DESC,
		txt    = desc);

  // Version column
#if 1
  vdsa$GetStruct(objID = nodeID, name = "frozen", txt = desc);
 
  vdsa$GetStruct(objID = nodeID, name = "assy_rev", txt = buf);
  sprintf(buf1,"%c%s",desc[0],buf);
  strcpy(desc,buf1);
#endif
  //strcpy(desc,"VER");
  
  vdfrm$SetText(form   = form, 
		gadget = gadget, 
		row    = *row, 
		col    = VDCT_FORM_TREE_COL_VER,
		txt    = desc);

  // Qty Column column
  vdsa$GetStruct(objID = nodeID, name = "node_count", txt = desc);
  vdfrm$SetText(form   = form, 
		gadget = gadget, 
		row    = *row, 
		col    = VDCT_FORM_TREE_COL_QTY,
		txt    = desc);
 if (traceFlag) printf("we set the attributes here\n");
  
  // Attribute Flag
  if (atrFlag == 0) {
    vdfrm$SetText(form   = form, 
		  gadget = gadget, 
		  row    = *row, 
		  col    = VDCT_FORM_TREE_COL_ATR,
		  txt    = "-");
  }
  
  else {
    vdfrm$SetText(form   = form, 
		  gadget = gadget, 
		  row    = *row, 
		  col    = VDCT_FORM_TREE_COL_ATR,
		  txt    = "+");
  }
  
  // If type is a leaf then no expansion allowed
  if (expFlag == 0) strcpy(desc,"-");
  else              strcpy(desc,"+");

  vdct1$GetTree1Child(objID = nodeID,
		      nth   = 0,
		      outID = &childID); 

  if (childID.objid == NULL_OBJID) strcpy(desc," ");
  
  vdfrm$SetText(form   = form, 
		gadget = gadget, 
		row    = *row, 
		col    = VDCT_FORM_TREE_COL_EXP,
		txt    = desc);
  
  // ID
  vdfrm$SetText(form   = form, 
		gadget = gadget, 
		row    = *row, 
		col    = VDCT_FORM_TREE_COL_GRID,
		objID  = nodeID);

  // Level
  sprintf(desc,"%d",level);
  vdfrm$SetText(form   = form, 
		gadget = gadget, 
		row    = *row, 
		col    = VDCT_FORM_TREE_COL_LEVEL,
		txt    = desc);
   
  //VDct1FormUpdateTreeRow(form, gadget, nodeID);
  
  // Need current parent
  //vdct1$GetTree1Parent(objID = nodeID, outID = &parentID);
  //VDct1FormUpdateTreeRow(cmdInfo->tree.form,VDCT_FORM_TREE_G_TREE,&parentID);
  // Done
  *row = *row + 1;
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1FormFillTreeRow(%d)\n",retFlag);
  return retFlag;
}

/* ----------------------------------------
 * Fill in tree gadget
 */
IGRstat VDct1FormFillTree(Form form, IGRint gadget, TGRid *setID)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  IGRint  row;
  IGRuint i;

  TGRid treeID;
  TGRid nodeID;
  if (traceFlag) printf(">>> VDct1FormFillTree\n"); 
  // Clear Field
  vdfrm$SetNumRows(form = form, gadget = gadget, rows = 0);
  
  // Get the tree id from the set
  vdct1$GetSetTree(setID = setID, treeID = &treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  // Put out top node
  row = 0;
  VDct1FormFillTreeRow(form,gadget,&row,0,&treeID,0,1);

  // Put out next level
  for(i = 0;
      vdct1$GetTree1Child(objID = &treeID,
			  nth   = i,
			  outID = &nodeID); 
      i++){
    
    VDct1FormFillTreeRow(form,gadget,&row,1,&nodeID,0,0);
  }

  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1FormFillTree(%d)\n",retFlag);
  return retFlag;
}

/* ----------------------------------------
 * Appends new set to tree
 * If setID is NULL then just clear form
 */
IGRstat VDct1FormAppendTree(Form form, IGRint gadget, TGRid *setID)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  IGRint  row;
  //IGRuint i;

  TGRid treeID;
  //TGRid nodeID;

  // Say Hi
  if (traceFlag) printf(">>> VDct1FormAppendTree\n");

  // Clear Field
  if (setID == NULL) {
    vdfrm$SetNumRows(form = form, gadget = gadget, rows = 0);
    retFlag = 1;
    goto wrapup;
  }
  
  // Get the tree id from the set
  vdct1$GetSetTree(setID = setID, treeID = &treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  // Put out top node
  vdfrm$GetNumRows(form = form, gadget = gadget, rows = &row);
  VDct1FormFillTreeRow(form,gadget,&row,0,&treeID,0,0);

#if 0
  // Put out next level
  for(i = 0;
      vdct1$GetTree1Child(objID = &treeID,
			  nth   = i,
			  outID = &nodeID); 
      i++){
    
    VDct1FormFillTreeRow(form,gadget,&row,1,&nodeID,0,0);
  }
#endif

  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1FormAppendTree(%d)\n",retFlag);
  return retFlag;
}

/*----------------------------------------------
 * Routine to recurse up from a node until a displayed node is reached
 * by ylong
 */
IGRstat VDct1DisplayRecurse(Form form, IGRint gadget, TGRid *nodeID, IGRint *row)
{

  TGRid   parentID;
  IGRchar name[128];

  // Check if current node is displayed
  if(VDct1FormFindTreeRow(form, gadget, nodeID, row))
  {
    // If so expand the row and increment number of rows
    VDct1FormExpandTreeRow(form, gadget, *row);
    (*row)++;
    return 1;
  }
  else if (nodeID->objid == NULL_OBJID)
  {
    return 1;
  }
  else
  {
    vdct1$GetTree1Parent (	objID	= nodeID, 
				nth	= 0, 
			 	outID	= &parentID); 
    VDct1DisplayRecurse(form, gadget, &parentID, row);
  }

  VDct1FormFindTreeRow(form, gadget, nodeID, row);
  VDct1FormExpandTreeRow(form, gadget, *row);

  return 1;
}


/*----------------------------------------------
 * Expand tree on the form till the desired node is displayed
 * by ylong
 */
IGRstat VDct1ExpandTree(Form form, IGRint gadget, TGRid *setID, TGRid *nodeID)
{
  TGRid   treeID, chldID, parentID;
  IGRint  i, cnt = 0;
  IGRint  row = -1;

  if(nodeID->objid == NULL_OBJID) return 0;

  // If already displayed then show the row and select it
  VDct1FormFindTreeRow(form,gadget,nodeID,&row);
  if(row > -1)
  {
    VDct1FormContractTreeRow(form,gadget,row);
    VDatFormShowRow(form, gadget, row);
    FIfld_set_select(form, gadget, row, 2, 1);
    return 1;
  }

  // Else Recurse up the tree till a displayed node is reached and expand 
  // down from there
  row = 0;
  vdtr$GetSetTree(setID  = setID,
                  treeID = &treeID);
  if(treeID.objid == NULL_OBJID)
  {
    return 0;
  }
  else
  {
    VDct1DisplayRecurse(form, gadget, nodeID, &row);
  }

  // Select and display the node on form
  VDct1FormFindTreeRow(form,gadget,nodeID,&row);
  VDatFormShowRow(form, gadget, row);
  FIfld_set_select(form, gadget, row, 2, 1);

  return 1;

}

/* ---------------------------------------------
 * Expand a row if it is contracted
 */
IGRstat VDct1FormExpandTreeAttrRow(Form form, IGRint gadget, IGRint row)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  IGRchar desc[1024],*p;
  IGRchar buf [128];
  TGRid   rootID;
  IGRuint i,level;

  IGRint  cnt;
  TVDfld *flds;
  if (traceFlag) printf(">>> VDct1FormExpandTreeAttrRow\n"); 
  // See if expand or contract
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_ATR,
		txt    = buf);
  
  if (*buf != '-') goto wrapup;

  // Get the id
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_GRID,
		objID  = &rootID);

  if (rootID.objid == NULL_OBJID) goto wrapup;

  // Get the level for prefix blanks
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_LEVEL,
		txt    = buf);

  level = atoi(buf) + 1;

  for(i = 0, p = desc; i < level; i++,p++) *p = ' ';

  // Set expand flag
  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_ATR,
		txt    = "+");

  // Insert kids
  row++;
  cnt = 0;

  // Grab all attributes
  vdcol$GetAttrs(objID = &rootID, cnt = &cnt, fldp = &flds);

  // printf("Attribute Count %d\n",cnt);
  
  if (flds == NULL) goto wrapup;
  
  for(i = 0; i < cnt; i++) {

    // printf("Attribute %d %s\n",i,flds[i].name);
    
    vdfld$Get(fld = &flds[i], desc = p);

    vdfrm$InsertBlankRow(form = form, gadget = gadget, row = row);
    
    vdfrm$SetText(form   = form,
		  gadget = gadget,
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_ATR,
		  txt    = " ");

    vdfrm$SetText(form   = form,
		  gadget = gadget,
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_EXP,
		  txt    = " ");

    vdfrm$SetText(form   = form,
		  gadget = gadget,
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_DESC,
		  txt    = desc);

    vdfrm$SetText(form   = form,
		  gadget = gadget,
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_GRID,
		  txt    = "");

    sprintf(buf,"%d",level);

    vdfrm$SetText(form   = form,
		  gadget = gadget,
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_LEVEL,
		  txt    = buf);
    row++;
  }
  
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1FormExpandTreeAttrRow(%d)\n",retFlag);
  return retFlag;
}

/* ---------------------------------------------
 * Contract a row if it is expanded
 */
IGRstat VDct1FormContractTreeAttrRow(Form form, IGRint gadget, IGRint row)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  IGRchar buf[128];

  IGRint  rowX,rowMax,rowCnt;
  if (traceFlag) printf(">>> VDct1FormContractTreeAttrRow\n"); 
  // See if expand or contract
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_ATR,
		txt    = buf);
  
  if (*buf != '+') goto wrapup;

  // Set expand flag
  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_ATR,
		txt    = "-");

  // Delete rows
  vdfrm$GetNumRows(form = form, gadget = gadget, rows = &rowMax);
  rowMax++;

  *buf = ' ';
  row++;

  // Find first row of next object
  for(rowX = row; (rowX < rowMax) && (*buf == ' '); rowX++) {

    vdfrm$GetText(form   = form,
		  gadget = gadget,
		  row    = rowX,
		  col    = VDCT_FORM_TREE_COL_ATR,
		  txt    = buf);
  }

  rowCnt = rowX - row - 1;
  if (rowCnt > 0) {
    vdfrm$DeleteRows(form   = form,
		     gadget = gadget,
		     row    = row,
		     cnt    = rowCnt);
  }

  retFlag = 1;

wrapup: 
  if (traceFlag) printf("<<< VDct1FormContractTreeAttrRow(%d)\n",retFlag);
  return retFlag;
}

/* ---------------------------------------------
 * Expand a row if it is contracted
 */
IGRstat VDct1FormExpandTreeRow(Form form, IGRint gadget, IGRint row)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  IGRint  level;
  IGRchar buf[128];
  TGRid   rootID,nodeID;
  IGRuint i;
  IGRstat sts = 1;
  IGRint  dispFlag; 
  IGRchar c;
  
  

  if (traceFlag) printf(">>> VDct1FormExpandTreeRow\n"); 

  // Contract attributes
  VDct1FormContractTreeAttrRow(form, gadget, row);

  // See if expand or contract
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_EXP,
		txt    = buf);

  if (*buf != '-') goto wrapup;

  // Get level
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_LEVEL,
		txt    = buf);
  
  level = atoi(buf);

  // Get the id
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_GRID,
		objID  = &rootID);

  if (rootID.objid == NULL_OBJID) goto wrapup;

  // Set expand flag
  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_EXP,
		txt    = "+");

  // read the gadget on the form
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_G_DISP,
		txt    = buf);
  // set the value 
  switch(*buf) {   
  case '1':
    dispFlag = 1;
    break;  
  case '2':
    dispFlag = 2;
    break;   
  case '3':
    dispFlag = 3;
    break;  
  case '4':
    dispFlag = 4;
    break;  
  case '5':
    dispFlag = 5;
    break;
  case '6':
    dispFlag = 6;
    break;  
  }
  // Insert kids
  level++;
  row++;
  for(i = 0; vdct1$GetTree1Child(objID = &rootID, nth = i, outID = &nodeID); i++) {

    // check the rules
    sts = vdct1$IsDiplayOK(rootID     = &nodeID,
			   dispOption = &dispFlag);

    // wrapper to control the expansion
    if (sts & 1) { 
      vdfrm$InsertBlankRow(form = form, gadget = gadget, row = row);
      VDct1FormFillTreeRow(form,gadget,&row,level,&nodeID,0,0);
    }
    
  }

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1FormExpandTreeRow(%d)\n",retFlag);
  return retFlag;



}
IGRstat VDct1FormExpandTreeRowID(Form form, IGRint gadget, TGRid *rowID)
{
  IGRstat retFlag = 0;
  IGRint  row;

  VDct1FormFindTreeRow(form,gadget,rowID,&row);
  if (row < 0) goto wrapup;

  retFlag = VDct1FormExpandTreeRow(form,gadget,row);

  retFlag = 1;
wrapup:
  return 1;
}

/* ---------------------------------------------
 * Contract a row if it is expanded
 */
IGRstat VDct1FormContractTreeRow(Form form, IGRint gadget, IGRint row)
{
  IGRstat retFlag = 0;  
  IGRstat traceFlag = traceFlagx;

  IGRint  level,levelX;
  IGRchar buf[128];

  IGRint  rowX,rowMax,rowCnt;
  if (traceFlag) printf(">>> VDct1FormContractTreeRow\n"); 
  // Contract attributes
  VDct1FormContractTreeAttrRow(form, gadget, row);

  // See if expand or contract
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_EXP,
		txt    = buf);

  if (*buf != '+') goto wrapup;

  // Get level
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_LEVEL,
		txt    = buf);
  
  level = atoi(buf);

  // Set contract flag
  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_EXP,
		txt    = "-");

  // Delete rows
  vdfrm$GetNumRows(form = form, gadget = gadget, rows = &rowMax);
  rowMax++;
  
  levelX = level + 1;
  row++;

  for(rowX = row; (rowX < rowMax) && (levelX > level); rowX++) {
    
    // Find previous level
    vdfrm$GetText(form   = form,
		  gadget = gadget,
		  row    = rowX,
		  col    = VDCT_FORM_TREE_COL_LEVEL,
		  txt    = buf);
    levelX = atoi(buf);
  }
  rowCnt = rowX - row - 1;
  if (rowCnt > 0) {
    vdfrm$DeleteRows(form = form, gadget = gadget, row = row, cnt = rowCnt);
  }

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1FormContractTreeRow(%d)\n",retFlag);
  return retFlag;
}

IGRstat VDct1FormContractTreeRowID(Form form, IGRint gadget, TGRid *rowID)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  
  IGRint  row;
  if (traceFlag) printf(">>> VDct1FormContractTreeRowID\n");
  VDct1FormFindTreeRow(form,gadget,rowID,&row);
  if (row < 0) goto wrapup;

  retFlag = VDct1FormContractTreeRow(form,gadget,row);

  retFlag = 1;
wrapup:
  if (traceFlag) printf("<<< VDct1FormContractTreeRowID(%d)\n",retFlag);
  return 1;
}

/* ---------------------------------------------
 * Deletes row from tree
 * Collapse it first to make sure all down stream items
 * Get passed as well
 */
IGRstat VDct1FormDeleteTreeRow(Form form, IGRint gadget, IGRint row)
{
  VDct1FormContractTreeRow(form,gadget,row);
  vdfrm$DeleteRows(form = form, gadget = gadget, row = row, cnt = 1);
  return 1;
}

IGRstat VDct1FormDeleteTreeRowID(Form form, IGRint gadget, TGRid *rowID)
{
  IGRstat retFlag = 0;
  IGRint row;

  VDct1FormFindTreeRow(form,gadget,rowID,&row);
  if (row < 0) goto wrapup;

  retFlag = VDct1FormDeleteTreeRow(form,gadget,row);

  retFlag = 1;
wrapup:
  return 1;
}

/* ----------------------------------------
 * Tree expand notification
 */
#argsused
IGRstat VDct1FormNotifyTreeExp(
  Form   form, 
  IGRint gadget, 
  IGRint row, 
  TGRid *rootID
)
{
  IGRstat  retFlag = 0;
  IGRstat  traceFlag = traceFlagx;
  
  IGRchar  buf[32];
  TGRid    rowID;
  
  if (traceFlag) printf(">>> VDct1FormNotifyTreeExp\n"); 

  // Unselect it
  vdfrm$SetSelect(form   = form, 
		  gadget = gadget, 
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_EXP,
		  sel    = 0);

  // See if expand or contract
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_EXP,
		txt    = buf);

  // Get the id
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_GRID,
		objID  = &rowID);

  // Pre process it, the op in buf may change
#if 1
  vdct1$PreExpandContractNode(nodeID = &rowID,
			      op     = buf);
#endif
  if (traceFlag) printf("### Back from PreExpandContractNode\n");
  
  vdfrm$SetText(form   = form,
                gadget = gadget,
                row    = row,
                col    = VDCT_FORM_TREE_COL_EXP,
                txt    = buf);

  switch(*buf) {  

  case '-': {
    VDct1FormExpandTreeRow(form,gadget,row);
    retFlag = 1;
    break;
  }

  case '+': {
    VDct1FormContractTreeRow(form,gadget,row);
    retFlag = 1;
    break;
  }
  }
  retFlag = 1;
  if (traceFlag) printf("<<< VDct1FormNotifyTreeExp(%d)\n",retFlag);
  return retFlag;
}

/* ----------------------------------------
 * Tree attribute notification
 */
#argsused
IGRstat VDct1FormNotifyTreeAttr(
  Form   form, 
  IGRint gadget, 
  IGRint row, 
  TGRid *rootID
)
{
  IGRstat  retFlag = 0;
  IGRstat  traceFlag = traceFlagx;
  IGRchar  buf[32];

  // Say Hi
  if (traceFlag) printf(">>> VDct1FormNotifyTreeAttr\n"); 

  // Unselect it
  vdfrm$SetSelect(form   = form, 
		  gadget = gadget, 
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_ATR,
		  sel    = 0);

  // See if expand or contract
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_ATR,
		txt    = buf);

  switch(*buf) {  

  case '-': {
    VDct1FormExpandTreeAttrRow(form,gadget,row);
    retFlag = 1;
    break;
  }

  case '+': {
    VDct1FormContractTreeAttrRow(form,gadget,row);
    retFlag = 1;
    break;
  }
  }
  retFlag = 1;
  if (traceFlag) printf("<<< VDct1FormNotifyTreeAttr(%d)\n",retFlag);
  return retFlag;
}
#if 1
/* ----------------------------------------
 * Tree name notification
 */
IGRstat VDct1FormNotifyTreeDesc(
  Form   form, 
  IGRint gadget, 
  IGRint row, 
  TGRid *treeID
)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  
  IGRint  treeSel;

  enum GRdpmode mode;

  // Say Hi
  if (traceFlag) printf(">>> VDct1FormNotifyTreeDesc\n"); 

  // See if row is now selected
  treeSel = -1;
  vdfrm$GetSelect(form   = form,
		  gadget = gadget,
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_DESC,
		  sel    = &treeSel);

  // Highlite
  if (treeSel == 0) mode = GRhe;
  else              mode = GRhhd;

  vdct1$DisplayNode(nodeID = treeID, 
		    mode = mode,
		    flag = 1);
  retFlag = 1;

//wrapup:
  if (traceFlag) printf("<<< VDct1FormNotifyTreeDesc(%d)\n",retFlag);
  return retFlag;
}
#endif// 0k
/* ----------------------------------------
 * Tree notification
 */
IGRstat VDct1FormNotifyTree(Form form, IGRint gadget, TGRid *a_nodeID)
{
  IGRint retFlag = 0;
  IGRstat traceFlag = traceFlagx;  
  IGRint row = -1;
  IGRint sel;

  TGRid nodeID;

  // Say Hi
  // traceFlag = traceFlagx = 1;
  if (traceFlag) printf(">>> VDct1FormNotifyTree\n");

  // Get the row
  vdfrm$GetActiveRow(form = form, gadget = gadget, row = &row);

  // Get ID
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = VDCT_FORM_TREE_COL_GRID,
		objID  = &nodeID);
  
  if (a_nodeID != NULL) *a_nodeID = nodeID;
  if (nodeID.objid == NULL_OBJID) goto wrapup;

  // Expansion Column
  vdfrm$GetSelect(form   = form,
		  gadget = gadget,
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_EXP,
		  sel    = &sel);

  if (sel == 1) {
    VDct1FormNotifyTreeExp(form,gadget,row,&nodeID);
    retFlag = 1;
    goto wrapup;
  }

  // Attribute Column
  vdfrm$GetSelect(form   = form,
		  gadget = gadget,
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_ATR,
		  sel    = &sel);
  
  if (sel == 1) {
    VDct1FormNotifyTreeAttr(form,gadget,row,&nodeID);
    retFlag = 1;
    goto wrapup;
  }

  // Only desc column left
  VDct1FormNotifyTreeDesc(form,gadget,row,&nodeID);
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1FormNotifyTree(%d)\n",retFlag);
  return retFlag;
}

/* -------------------------------------------------------------------
 * Fill one row in the set list
 */
IGRstat VDct1FormFillSetRow(Form form, IGRint gadget, TGRid *setID)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  IGRint row;
  TVDctBaseInfo baseInfo;
  IGRchar fileName[512],*p;

  // Say Hi
  if (traceFlag) printf(">>> VDct1FormFillSetRow\n");
  
  // Arg check
  if ((form == NULL) || (setID == NULL)) goto wrapup;
  
  // Get the row
  vdfrm$GetNumRows(form = form, gadget = gadget, rows = &row);
  
  // The file name
  om$os_number_to_name (osnum = setID->osnum, osname = fileName);
  p = strrchr(fileName,'/');
  if (p) strcpy(fileName,p+1);
  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = 0,
		txt    = fileName);
  
  // Set type and name
  vdct$GetBaseInfo(objID = setID, baseInfo = &baseInfo);

  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = 1,
		txt    = baseInfo.setName);

  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = 2,
		txt    = baseInfo.setType);
  
  // And the objid
  vdfrm$SetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = 3,
		objID  = setID);

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VDct1FormFillSetRow(%d)\n",retFlag);
  return retFlag;
}

/* --------------------------------------------------------
 * Fills in list of available sets
 * Mainly intended to be used with the pocket menu
 */
IGRstat VDct1FormFillSets(Form form, IGRint gadget, IGRint clearGadget)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  TVDosnum osnum;
  TGRid    mgrID,setID,treeID;
  IGRint   i;

  // Say Hi
  if (traceFlag) printf(">>> VDct1FormFillSets\n");
 
  // Arg check
  if (form == NULL) goto wrapup;
  
  // Reset gadget if we want to
  if (clearGadget) vdfrm$SetNumRows(form = form, gadget = gadget, rows = 0);
 
  // Cycle through the os's
  for(osnum = 0; vdos$Validate(osnum = osnum); osnum++) {
    
    // Get the manager
    vdct1$GetManager(osnum = osnum, mgrID = &mgrID);
    if (mgrID.objid != NULL_OBJID) {

      // Cycle through sets
      for(i = 0; vdct1$GetMgrChild(objID = &mgrID, nth = i, outID = &setID); i++) {
	  
	// Get the real tree
	vdct1$GetMgrChild(objID = &setID, nth = 0, outID = &treeID);

	// Fill it
	VDct1FormFillSetRow(form,gadget,&setID);
	
      }
    }
  }
  
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VDct1FormFillSets(%d)\n",retFlag);
  return retFlag;
}
/* --------------------------------------------------------------------------
 * starts at the top row on the form
 * gets the ID of the row
 * updates that row to match it's new data
 * moves on to the next row
 */ 
IGRstat VDct1FormUpdateVRTree(Form form, IGRint gadget)
{
  IGRstat retFlag   = 0;
  IGRstat traceFlag = traceFlagx;
  IGRint  row;
  IGRint  col;
  IGRint  rows;
  TGRid   rowID;
  IGRchar buf[128], buf1[128], buf2[128];
  TVDfld  tmpFld;
  IGRchar *c;
  

  // Say Hi
  traceFlag = 0;
  if (traceFlag) printf(">>> VDct1FormUpdateVRTree\n");

  // get the number of rows on the form
  vdfrm$GetNumRows(form = form, gadget = gadget, rows = &rows);


  // loop down through the rows get the id of the row and then update it
  for (row = 0; row < rows; row++) {

    // get the rowID 
    vdfrm$GetText(form   = form, 
		  gadget = gadget, 
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_GRID,
		  objID  = &rowID);

    // get the attributes for that field
    vdcol$GetAttr(objID = &rowID, name = "frozen", fld = &tmpFld);
    strcpy(buf,"");
    if (*tmpFld.name != 0) {
      strcpy(buf1,tmpFld.val.txt);
      vdcol$GetAttr(objID = &rowID, name = "assy_rev", fld = &tmpFld);
      // printf("tmpFld.val.txt [%s]\n",tmpFld.val.txt);
      
      strcpy(buf2,"");
      if(*tmpFld.name != 0) {
	strcpy(buf2,tmpFld.val.txt);
      }
      sprintf(buf,"%c%s",buf1[0],buf2);
      // printf("This is what the update looks like [%s]\n",buf);
    }
    
    // Set the Rev
    vdfrm$SetText(form   = form,
		  gadget = gadget,
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_VER,
		  txt    = buf);

    vdcol$GetAttr(objID = &rowID, name = "node_count", fld = &tmpFld);
    strcpy(buf,"");
    if (*tmpFld.name != 0) {
      strcpy(buf,tmpFld.val.txt);
    }
    
    // Set the Count
    vdfrm$SetText(form   = form,
		  gadget = gadget,
		  row    = row,
		  col    = VDCT_FORM_TREE_COL_QTY,
		  txt    = buf);
    
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  // say bye
  if (traceFlag) printf("<<< VDct1FormUpdateVRTree(%d)\n",retFlag);
  return retFlag;
}

				  
end implementation VDct1Base;








