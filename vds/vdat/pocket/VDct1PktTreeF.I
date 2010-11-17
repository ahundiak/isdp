/* $Id: VDct1PktTreeF.I,v 1.9.4.1 2002/08/13 14:20:48 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pocket/VDct1PktTreeF.I
 *
 * Description: Aux Tree Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1PktTreeF.I,v $
 *      Revision 1.9.4.1  2002/08/13 14:20:48  ylong
 *      *** empty log message ***
 *
 *      Revision 1.9  2001/11/09 16:28:23  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/10/18 19:23:31  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/06/26 15:18:20  ylong
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/05/25 22:25:50  ylong
 *      CR3986
 *
 *      Revision 1.5  2001/03/05 22:46:55  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/03/02 14:11:42  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/03/01 19:55:13  ylong
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/09 23:42:42  ylong
 *      Renamed
 *
 *      Revision 1.1  2001/02/09 18:23:40  ylong
 *      Migrate from vdct1/cmd2/VDct1TreeF.c
 *
 *      Revision 1.2  2001/02/06 15:14:48  jdsauby
 *      Added VDct1ScanTree
 *
 *      Revision 1.1  2001/01/14 16:21:13  art
 *      sp merge
 *
 * Revision 1.7  2000/12/08  21:33:34  pinnacle
 * ah
 *
 * Revision 1.6  2000/12/08  20:51:12  pinnacle
 * ah
 *
 * Revision 1.5  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.4  2000/11/16  19:48:34  pinnacle
 * pn
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/17/99  ah      creation
 * 01/10/00  pn      updated controls/safeops
 * 05/16/00  pn      updated some display features
 * 05/23/00  pn      updated several display features
 * 05/31/00  pn      installed form view controls
 * 10/18/01  ah      Removed VDdoM code
 * 11/09/01  ah      Removed some class pointer code
 * 08/13/02  ylong   TR5966, trigger vertical scroll responding to click
 ***************************************************************************/

class implementation Root;

//#include "VDtypedefc.h"
//#include "VDfrmc.h"

#include "VDobj.h"
#include "VDtypedef.h"
#include "VDobj2.h"
#include "VDos.h"
#include "VDassert.h"

#include "dpstruct.h"

#include "VDfrmc.h"
#include "VDct1Cmdx.h"
#include "VDct1Forms.h"

#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Trace.h"

#include "VDatPocket.h"

#include "VDctx.h"
#include "vdtr_macros.h"
#include "VDchn.h"

VDASSERT_FFN("vdat/pocket/VDct1TreeF.I");

IGRstat VDct1PKTFormClearTree  (Form form, IGRint gadget);

IGRstat VDct1PKTFormFillTreeRow (Form form, IGRint gadget, IGRint *row, 
				     IGRint level, TGRid *nodeID, 
				     IGRint atrFlag, IGRint expFlag);

IGRstat VDct1PKTFormDeleteTreeRow (Form form, IGRint gadget, IGRint row);

IGRstat VDct1PKTFormContractTreeRowID (Form form, IGRint gadget, TGRid *rowID);

IGRstat VDct1PKTFormExpandTreeRow  (Form form, IGRint gadget, IGRint row);
IGRstat VDct1PKTFormExpandTreeRowID(Form form, IGRint gadget, TGRid *rowID);

IGRstat VDct1PKTFormExpandTreeAttrRow  (Form form, IGRint gadget, IGRint row);
IGRstat VDct1PKTFormContractTreeAttrRow(Form form, IGRint gadget, IGRint row);

IGRstat VDct1PKTFormNotifyTreeAttr(Form form, IGRint gadget, IGRint row, TGRid *rootID);
IGRstat VDct1PKTFormNotifyTreeExp (Form form, IGRint gadget, IGRint row, TGRid *rootID);

/* ------------------------------------------------
 * Need to able to support multiple tree gadget formats
 * so the pocket menu (and possibly other commands) can share
 * this code.
 *
 * Make the internal routines static, public routines
 * to fill in this gadget structure
 *
 * tc = tree column
 *
 * This is still an interim fix, eliminate gadget from all public
 * interfaces, expand this structure to include all gadgets
 * on the form and then pass it to internal routines.
 */
static struct 
{
  IGRint atr,exp,qty,ver,desc,grid,level;
} tc;

static IGRstat isPocketForm(Form form) 
{
  IGRchar form_name[32];
  VDfrmGetFormName(form,form_name);
  if (!strcmp(form_name,"VDatPocket.frm")) return 1;
  if (!strcmp(form_name,"VDdrwTblUpAs.frm")) return 1;
  return 0;
}

static void initTC(Form form)
{
  if (isPocketForm(form)) {
    tc.atr   =  0;  // 0
    tc.exp   =  1;  // 1
    tc.qty   = -1;  // 2
    tc.ver   = -1;  // 3
    tc.desc  =  2;  // 4
    tc.grid  =  3;  // 5
    tc.level =  4;  // 6
    return;
  }
  
  // Regular
  tc.atr   = 0;
  tc.exp   = 1;
  tc.qty   = 2;
  tc.ver   = 3;
  tc.desc  = 4;
  tc.grid  = 5;  
  tc.level = 6;

  return;
}

/* ------------------------------------------------
 * Clears all selected rows in tree
 */
IGRstat VDct1PKTFormClearTree(Form form, IGRint gadget)
{
  VDASSERT_FN("VDct1PKTFormClearTree");

  IGRstat retFlag = 0;
  
  IGRint  row,rows,sel;
  IGRint  col = tc.desc;

  // Cycle through
  if (traceFlag) printf(">>> %s\n",fn);
  
  VDfrmGetNumRows(form,gadget,&rows,NULL,NULL);
  for(row = 0; row < rows; row++) {

    VDfrmGetSelect(form,gadget,row,col,&sel);
    if (sel == 1) {
      VDfrmSetSelect(form,gadget,row,col,0);
    }
  }

  retFlag = 1;
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* ------------------------------------------------
 * Updates a row by contracting then expanding
 */
IGRstat VDct1PKTFormUpdateTreeRow(Form form, IGRint gadget,TGRid *rowID)
{
  VDASSERT_FN("VDct1PKTFormUpdateTreeRow");
  
  IGRstat retFlag = 0;
  
  IGRint  row;
  TGRid   childID;
  IGRchar exp[4];

  // Say Hi
  if (traceFlag) printf(">>> %s\n",fn); 
  initTC(form);
  
  // Update the tree gadget
  VDct1PKTFormFindTreeRow(form,gadget,rowID,&row);
  if (row == -1) goto wrapup;

  // Get rid of any attribute expansion
  VDct1PKTFormContractTreeAttrRow(form,gadget,row);

  // Contract it
  VDct1PKTFormContractTreeRow(form,gadget,row);

  // If it has children then expand
  VDctxGetNthTreeChild(rowID,0,&childID); 

  if (childID.objid == NULL_OBJID) strcpy(exp," ");
  else                             strcpy(exp,"-");
  
  VDfrmSetfText(form,gadget,row,tc.exp,exp);
  
  VDct1PKTFormExpandTreeRow(form,gadget,row);

  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* -----------------------------------------
 * Finds row in tree gadget containing id
 */
IGRstat VDct1PKTFormFindTreeRow(Form    form, 
			     IGRint  gadget, 
			     TGRid  *workID, 
			     IGRint *rowFound)
{
  VDASSERT_FN("VDct1PKTFormUpdateTreeRow");
  IGRstat retFlag = 0;
  IGRint  row,rows;
  TGRid   rowID;

  // Init
  *rowFound = -1;
  if (traceFlag) printf(">>> %s\n",fn); 
  initTC(form);
  
  // Cycle through
  VDfrmGetNumRows(form,gadget,&rows,NULL,NULL);
  for(row = 0; row < rows; row++) {

    VDfrmGetfID(form,gadget,row,tc.grid,&rowID);

    if ((rowID.objid == workID->objid) &&
        (rowID.osnum == workID->osnum)) {

      *rowFound = row;
      return 1;
    }
  }
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* ----------------------------------------
 * Handles Node Name Changes
 */
IGRstat VDct1PKTFormRefreshNodeName(Form    form, 
				 IGRint  gadget, 
				 IGRint  row, 
				 TGRid  *nodeID)
{
  VDASSERT_FN("VDct1PKTFormRefreshNodeName");

  IGRstat  retFlag = 0;
  IGRchar  desc[1024];
  IGRchar *pnt;
  IGRint   i;

  IGRint   level;
  IGRchar  buf[128];

  TVDctxBaseInfo baseInfo;

  // Say Hi
  if (traceFlag) printf(">>> %s\n",fn);   
  initTC(form);
  
  // Need level for indenting
  VDfrmGetfText(form,gadget,row,tc.level,buf);
  level = atoi(buf);

  // Indent
  *desc = 0;
  for(i = 0, pnt = desc; i < level; i++) *pnt++ = ' ';
  *pnt = 0;
  
  VDctxGetBaseInfo(nodeID,&baseInfo);
  strcpy(pnt,baseInfo.baseName);
  
  VDfrmSetfText(form,gadget,row,tc.desc,desc);
  //printf("Refreshed  %s\n",desc);
  
  retFlag = 1;
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
  
}

// Expand, Contact, None
#define EXP_EXP "+"
#define EXP_CON "-"
#define EXP_EMP " "

/* ----------------------------------------
 * Fill in one row in tree gadget
 */
IGRstat VDct1PKTFormFillTreeRow(Form    form, 
				    IGRint  gadget, 
				    IGRint *row, 
				    IGRint  level,
				    TGRid  *nodeID,
				    IGRint  atrFlag,
				    IGRint  expFlag)
{
  VDASSERT_FN("VDct1PKTFormFillTreeRow");
  
  IGRstat  retFlag = 0;
  IGRchar  desc[1024];
  IGRchar *pnt;
  IGRint   i;
  IGRchar  buf[128], buf1[128];
  IGRchar *c;
  TVDctxBaseInfo baseInfo;
  TGRid childID;
  TGRid parentID;

  // Say hi
  if (traceFlag) printf(">>> %s\n",fn); 
  
  // Get it's desc
  for(i = 0, pnt = desc; i < level; i++) *pnt++ = ' '; *pnt = 0;
  
  VDctxGetBaseInfo(nodeID,&baseInfo);
  strcpy(pnt,baseInfo.baseName);
  
  VDfrmSetfText(form,gadget,*row,tc.desc,desc);

  // Version column
  VDctxGetTxtAtr(nodeID,"frozen",  desc);
  VDctxGetTxtAtr(nodeID,"assy_rev",buf);
  sprintf(buf1,"%c%s",desc[0],buf);
  strcpy(desc,buf1);

  if (tc.ver >= 0) {
    VDfrmSetfText(form,gadget,*row,tc.ver,desc);
  }
  
  // Qty Column column
  VDctxGetTxtAtr(nodeID,"node_count",desc);
  if (tc.qty >= 0) {   
    VDfrmSetfText(form,gadget,*row,tc.qty,desc);
  }
 
  // Attribute Flag
  if (atrFlag == 0) VDfrmSetfText(form,gadget,*row,tc.atr,EXP_CON);
  else              VDfrmSetfText(form,gadget,*row,tc.atr,EXP_EXP);
  
  // If type is a leaf then no expansion allowed
  if (expFlag == 0) strcpy(desc,EXP_CON);
  else              strcpy(desc,EXP_EXP);

  VDctxGetNthTreeChild(nodeID,0,&childID); 
  if (childID.objid == NULL_OBJID) strcpy(desc,EXP_EMP);
  
  VDfrmSetfText(form,gadget,*row,tc.exp,desc);
  
  // ID
  VDfrmSetfID(form,gadget,*row,tc.grid,nodeID);

  // Level
  sprintf(desc,"%d",level);
  VDfrmSetfText(form,gadget,*row,tc.level,desc);
   
  //VDct1PKTFormUpdateTreeRow(form, gadget, nodeID);
  
  // Done
  *row = *row + 1;
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1PKTFormFillTreeRow(%d)\n",retFlag);
  return retFlag;
}

/* ----------------------------------------
 * Fill in tree gadget
 */
IGRstat VDct1PKTFormFillTree(Form form, IGRint gadget, TGRid *setID)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  IGRint  row;
  IGRuint i;

  TGRid treeID;
  TGRid nodeID;

  // Say Hi
  if (traceFlag) printf(">>> VDct1PKTFormFillTree\n"); 
  initTC(form);
  
  // Clear Field
  VDfrmSetNumRows(form,gadget,0);
  
  // Get the tree id from the set
  VDctxGetTree(setID,&treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  // Put out top node
  row = 0;
  VDct1PKTFormFillTreeRow(form,gadget,&row,0,&treeID,0,1);

  // Put out next level
  for(i = 0; VDctxGetNthTreeChild(&treeID,i,&nodeID); i++) {
    VDct1PKTFormFillTreeRow(form,gadget,&row,1,&nodeID,0,0);
  }

  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1PKTFormFillTree(%d)\n",retFlag);
  return retFlag;
}

/* -----------------------------------------
 * Scans a tree, used to update any required changes
 */
IGRstat VDct1PKTScanTree(TGRid *setID)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  IGRstat sts;
  
  TGRid    treeID;
  TVDct1JD treeJD;
  
  // say hi
  if (traceFlag) printf(">>> VDct1PKTScanTree\n");
  
  // Arg Check
  if( setID->objid == NULL_OBJID ) goto wrapup;

  // get the tree id from the set
  VDct1GetSetTree( setID, &treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  // get some class
  treeJD.cl = VDct1GetTreeClassForNode(&treeID);
  if (treeJD.cl == NULL) goto wrapup;
  treeJD.id = treeID;
  
  sts = _RTCJDB(&treeJD)->updateNodesOnTree(&treeJD);
  if (!(sts & 1)) goto wrapup;

  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VDct1PKTScanTree <%d>\n",retFlag);
  return retFlag;
}

/* ----------------------------------------
 * Appends new set to tree
 * If setID is NULL then just clear form
 */
IGRstat VDct1PKTFormAppendTree(Form form, IGRint gadget, TGRid *setID)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  IGRint  row,i;

  TGRid treeID;
  TGRid nodeID;
  
  // Say Hi
  if (traceFlag) printf(">>> VDct1PKTFormAppendTree\n");
  initTC(form);
  
  // Clear Field
  if (setID == NULL) {
    VDfrmSetNumRows(form,gadget,0);
    retFlag = 1;
    goto wrapup;
  }
  
  // Get the tree id from the set
  VDctxGetTree(setID,&treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;
  
  // Put out top node
  VDfrmGetNumRows(form,gadget,&row,NULL,NULL);
  VDct1PKTFormFillTreeRow(form,gadget,&row,0,&treeID,0,0);

#if 0
  // Put out next level
  for(i = 0;VDctxGetNthTreeChild(&treeID,i,&nodeID); i++){
    VDct1PKTFormFillTreeRow(form,gadget,&row,1,&nodeID,0,0);
  }
#endif

  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1PKTFormAppendTree(%d)\n",retFlag);
  return retFlag;
}

/*----------------------------------------------
 * Routine to recurse up from a node until a displayed node is reached
 * by ylong
 */
IGRstat VDct1PKTFormDisplayRecurse (
		Form	form, 
		IGRint	gadget, 
		TGRid	*nodeID, 
		IGRint	*row)
{

  TGRid   parentID;
  IGRchar name[128];

  // Check if current node is displayed
  if(VDct1PKTFormFindTreeRow(form, gadget, nodeID, row) || nodeID->objid == NULL_OBJID)
  {
    // If so expand the row and increment number of rows
    VDct1PKTFormExpandTreeRow(form, gadget, *row);
    (*row)++;
    return 1;
  }
  else
  {
    vdct1$GetTree1Parent (      objID   = nodeID,
                                nth     = 0,
                                outID   = &parentID);
    if(parentID.objid == NULL_OBJID){
      return 1;
    }

    VDct1PKTFormDisplayRecurse(form, gadget, &parentID, row);
  }

  VDct1PKTFormFindTreeRow(form, gadget, nodeID, row);
  VDct1PKTFormExpandTreeRow(form, gadget, *row);

  return 1;
}


/*------------------------------------------------------------
 * Expand tree on the form till the desired node is displayed
 * by ylong
 */
IGRstat VDct1PKTFormExpandTree (
		Form	form, 
		IGRint	gadget, 
		TGRid	*setID, 
		TGRid	*nodeID)
{
  TGRid   treeID, parentID;
  IGRint  i;
  IGRint  row = -1;

  if(nodeID->objid == NULL_OBJID) return 0;

  // If already displayed then show the row and select it
  VDct1PKTFormFindTreeRow(form,gadget,nodeID,&row);
  if(row > -1)
  {
    VDct1PKTFormContractTreeRow(form,gadget,row);
    VDatFormShowRow(form, gadget, row);
    FIfld_set_select(form, gadget, row, 2, 1);
    return 1;
  }

  // Else Recurse up the tree till a displayed node is reached and expand
  // down from there
  row = 0;
  /* VDct1GetSetTree( setID, &treeID); 
   * It does not work to get tree from set. Has to use  VDctxGetTree.
   */
  VDctxGetTree(setID,&treeID);
  if(treeID.objid == NULL_OBJID)
  {
    return 0;
  }
  else
  {
    VDct1PKTFormDisplayRecurse(form, gadget, nodeID, &row);
  }

  // Select and display the node on form
  VDct1PKTFormFindTreeRow(form,gadget,nodeID,&row);
  VDatFormShowRow(form, gadget, row);
  FIfld_set_select(form, gadget, row, 2, 1);

  return 1;

}


/* ---------------------------------------------
 * Expand a row if it is contracted
 */
IGRstat VDct1PKTFormExpandTreeAttrRow(Form form, IGRint gadget, IGRint row)
{
  VDASSERT_FN("VDct1PKTFormExpandTreeAttrRow");
  
  IGRstat retFlag = 0;
  IGRchar desc[1024],*p;
  IGRchar buf [128];
  TGRid   rootID;
  IGRuint i,level;

  IGRint  cnt;
  TVDfld  flds[VDFLD_MAX_CNT];

  // Say Hi
  if (traceFlag) printf(">>> %s\n",fn);

  // See if expand or contract
  VDfrmGetfText(form,gadget,row,tc.atr,buf);
  if (strcmp(buf,EXP_CON)) goto wrapup;

  // Get the id
  VDfrmGetfID(form,gadget,row,tc.grid,&rootID);
  if (rootID.objid == NULL_OBJID) goto wrapup;

  // Get the level for prefix blanks
  VDfrmGetfText(form,gadget,row,tc.level,buf);
  level = atoi(buf) + 1;

  for(i = 0, p = desc; i < level; i++,p++) *p = ' ';

  // Set expand flag
  VDfrmSetfText(form,gadget,row,tc.atr,EXP_EXP);

  // Insert kids
  row++;

  // Cycle through attributes
  VDctxGetFldAtrs(&rootID,&cnt,flds);
  for(i = 0; i < cnt; i++) {

    /* -------------------------------------------
     * This is field specific
     * Might want to add to the class structure?
     * Or otherwise break out later
     */
    VDfldGetFldDesc(&flds[i],p);

    VDfrmInsertBlankRow(form,gadget,row);
    
    VDfrmSetfText(form,gadget,row,tc.atr,EXP_EMP);
    VDfrmSetfText(form,gadget,row,tc.exp,EXP_EMP);
    VDfrmSetfText(form,gadget,row,tc.desc,desc);
    VDfrmSetfText(form,gadget,row,tc.grid,"");

    sprintf(buf,"%d",level);
    VDfrmSetfText(form,gadget,row,tc.level,buf);
    row++;
  }

  if( cnt > 0 ) {
    IGRint	rowMax = 0;
    VDfrmGetNumRows(form,gadget,&rowMax,NULL,NULL);
    VDfrmSetNumRows(form,gadget,rowMax);
  }

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* ---------------------------------------------
 * Contract a row if it is expanded
 */
IGRstat VDct1PKTFormContractTreeAttrRow(Form form, IGRint gadget, IGRint row)
{
  VDASSERT_FN("VDct1PKTFormContractTreeAttrRow");
  
  IGRstat retFlag = 0;
  IGRchar buf[128];

  IGRint  rowX,rowMax,rowCnt;

  // Say Hi
  if (traceFlag) printf(">>> %s\n",fn);

  // See if expand or contract
  VDfrmGetfText(form,gadget,row,tc.atr,buf);
  if (strcmp(buf,EXP_EXP)) goto wrapup;

  // Set expand flag
  VDfrmSetfText(form,gadget,row,tc.atr,EXP_CON);

  // Delete rows
  VDfrmGetNumRows(form,gadget,&rowMax,NULL,NULL);
  rowMax++;

  strcpy(buf,EXP_EMP);
  row++;

  // Find first row of next object
  for(rowX = row; (rowX < rowMax) && (!strcmp(buf,EXP_EMP)); rowX++) {

    VDfrmGetfText(form,gadget,rowX,tc.atr,buf);
  }

  rowCnt = rowX - row - 1;
  if (rowCnt > 0) {
    VDfrmDeleteRows(form,gadget,row,rowCnt);

    // trigger scroll bar to respond
    VDfrmGetNumRows(form,gadget,&rowMax,NULL,NULL);
    VDfrmSetNumRows(form,gadget,rowMax);
  }


  retFlag = 1;

wrapup: 
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* ---------------------------------------------
 * Expand a row if it is contracted
 */
IGRstat VDct1PKTFormExpandTreeRow(Form form, IGRint gadget, IGRint row)
{
  VDASSERT_FN("VDct1PKTFormExpandTreeRow");
  
  IGRstat retFlag = 0;
  IGRint  level, rowMax;
  IGRchar buf[128];
  TGRid   rootID,nodeID;
  IGRuint i;
  IGRstat sts = 1;
  IGRint  dispFlag; 
  IGRchar c;
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn); 

  // Contract attributes
  VDct1PKTFormContractTreeAttrRow(form, gadget, row);

  // See if expand or contract
  VDfrmGetfText(form,gadget,row,tc.exp,buf);
  if (strcmp(buf,EXP_CON)) goto wrapup;

  // Get level
  VDfrmGetfText(form,gadget,row,tc.level,buf);
  level = atoi(buf);

  // Get the id
  VDfrmGetfID(form,gadget,row,tc.grid,&rootID);
  if (rootID.objid == NULL_OBJID) goto wrapup;
  
  // Set expand flag
  VDfrmSetfText(form,gadget,row,tc.exp,EXP_EXP);

  // read the gadget on the form
  if (isPocketForm(form)) strcpy(buf,"1");
  else VDfrmGetgText(form,VDCT_FORM_TREE_G_DISPLAY,buf);

  // set the value 
  switch(*buf) {   
    case '1': dispFlag = 1; break;  
    case '2': dispFlag = 2; break;   
    case '3': dispFlag = 3; break;  
    case '4': dispFlag = 4; break;  
    case '5': dispFlag = 5; break;
    case '6': dispFlag = 6; break;  
  }

  // Insert kids
  level++;
  row++;
  for(i = 0; VDctxGetNthTreeChild(&rootID,i,&nodeID); i++) {

    // check the rules
    /* ------------------------------------------------
     * This actually interfaces to a ppl
     * Needs to be added to the tree class
     */
    sts = VDct1IsDisplayOK(&nodeID,&dispFlag);

    // wrapper to control the expansion
    if (sts & 1) { 
      VDfrmInsertBlankRow (form,gadget, row);
      VDct1PKTFormFillTreeRow(form,gadget,&row,level,&nodeID,0,0);
    }
    
  }

  // trigger scroll bar to respond
  VDfrmGetNumRows(form,gadget,&rowMax,NULL,NULL);
  VDfrmSetNumRows(form,gadget,rowMax);

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1PKTFormExpandTreeRow(%d)\n",retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Expand row for a given id
 */
IGRstat VDct1PKTFormExpandTreeRowID(Form form, IGRint gadget, TGRid *rowID)
{
  IGRstat retFlag = 0;
  IGRint  row;

  VDct1PKTFormFindTreeRow(form,gadget,rowID,&row);
  if (row < 0) goto wrapup;

  retFlag = VDct1PKTFormExpandTreeRow(form,gadget,row);

  retFlag = 1;
wrapup:
  return 1;
}

/* ---------------------------------------------
 * Contract a row if it is expanded
 */
IGRstat VDct1PKTFormContractTreeRow(Form form, IGRint gadget, IGRint row)
{
  IGRstat retFlag = 0;  
  IGRstat traceFlag = traceFlagx;

  IGRint  level,levelX;
  IGRchar buf[128];

  IGRint  rowX,rowMax,rowCnt;

  // Say Hi
  if (traceFlag) printf(">>> VDct1PKTFormContractTreeRow\n");

  // Contract attributes
  VDct1PKTFormContractTreeAttrRow(form, gadget, row);

  // See if expand or contract
  VDfrmGetfText(form,gadget,row,tc.exp,buf);
  if (strcmp(buf,EXP_EXP)) goto wrapup;

  // Get level
  VDfrmGetfText(form,gadget,row,tc.level,buf);
  level = atoi(buf);

  // Set contract flag
  VDfrmSetfText(form,gadget,row,tc.exp,EXP_CON);

  // Delete rows
  VDfrmGetNumRows(form,gadget,&rowMax,NULL,NULL);
  rowMax++;
  
  levelX = level + 1;
  row++;

  for(rowX = row; (rowX < rowMax) && (levelX > level); rowX++) {
    
    // Find previous level
    VDfrmGetfText(form,gadget,rowX,tc.level,buf);
    levelX = atoi(buf);
  }
  rowCnt = rowX - row - 1;
  if (rowCnt > 0) {
    VDfrmDeleteRows(form,gadget,row,rowCnt);

    // trigger scroll bar to respond
    VDfrmGetNumRows(form,gadget,&rowMax,NULL,NULL);
    VDfrmSetNumRows(form,gadget,rowMax);
  }

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1PKTFormContractTreeRow(%d)\n",retFlag);
  return retFlag;
}

IGRstat VDct1PKTFormContractTreeRowID(Form form, IGRint gadget, TGRid *rowID)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  
  IGRint  row;
  if (traceFlag) printf(">>> VDct1PKTFormContractTreeRowID\n");
  VDct1PKTFormFindTreeRow(form,gadget,rowID,&row);
  if (row < 0) goto wrapup;

  retFlag = VDct1PKTFormContractTreeRow(form,gadget,row);

  retFlag = 1;
wrapup:
  if (traceFlag) printf("<<< VDct1PKTFormContractTreeRowID(%d)\n",retFlag);
  return 1;
}

/* ---------------------------------------------
 * Deletes row from tree
 * Collapse it first to make sure all down stream items
 * Get passed as well
 */
IGRstat VDct1PKTFormDeleteTreeRow(Form form, IGRint gadget, IGRint row)
{
  VDct1PKTFormContractTreeRow(form,gadget,row);
  VDfrmDeleteRows(form,gadget,row,1);
  return 1;
}

IGRstat VDct1PKTFormDeleteTreeRowID(Form form, IGRint gadget, TGRid *rowID)
{
  IGRstat retFlag = 0;
  IGRint row;

  initTC(form);
  
  VDct1PKTFormFindTreeRow(form,gadget,rowID,&row);
  if (row < 0) goto wrapup;

  retFlag = VDct1PKTFormDeleteTreeRow(form,gadget,row);

  retFlag = 1;
wrapup:
  return 1;
}

/* ----------------------------------------
 * Tree expand notification
 */
IGRstat VDct1PKTFormNotifyTreeExp(Form   form, 
				      IGRint gadget, 
				      IGRint row, 
				      TGRid *rootID)
{
  IGRstat  retFlag = 0;
  IGRstat  traceFlag = traceFlagx;
  
  IGRchar  buf[32];
  TGRid    rowID;
  
  // Say HI
  if (traceFlag) printf(">>> VDct1PKTFormNotifyTreeExp\n"); 

  // Unselect it
  VDfrmSetSelect(form,gadget,row,tc.exp,0);

  // See if expand or contract
  VDfrmGetfText(form,gadget,row,tc.exp,buf);

  // Get the id
  VDfrmGetfID(form,gadget,row,tc.grid,&rowID);

  // Pre process it, the op in buf may change
  VDct1PreExpandContractNode(&rowID, buf);
  if (traceFlag) printf("### Back from PreExpandContractNode\n");
  
  VDfrmSetfText(form,gadget,row,tc.exp,buf);

  if (!strcmp(buf,EXP_CON)) {   
    VDct1PKTFormExpandTreeRow(form,gadget,row);
    retFlag = 1;
  }

  if (!strcmp(buf,EXP_EXP)) {   
    VDct1PKTFormContractTreeRow(form,gadget,row);
    retFlag = 1;
  }

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1PKTFormNotifyTreeExp(%d)\n",retFlag);
  return retFlag;
}

/* ----------------------------------------
 * Tree attribute notification
 */
IGRstat VDct1PKTFormNotifyTreeAttr(Form   form, 
				       IGRint gadget, 
				       IGRint row, 
				       TGRid *rootID)
{
  IGRstat  retFlag = 0;
  IGRstat  traceFlag = traceFlagx;
  IGRchar  buf[32];

  // Say Hi
  if (traceFlag) printf(">>> VDct1PKTFormNotifyTreeAttr\n"); 

  // Unselect it
  VDfrmSetSelect(form,gadget,row,tc.atr,0);

  // See if expand or contract
  VDfrmGetfText(form,gadget,row,tc.atr,buf);

  if (!strcmp(buf,EXP_CON)) {    
    VDct1PKTFormExpandTreeAttrRow(form,gadget,row);
    retFlag = 1;
  }

  if (!strcmp(buf,EXP_EXP)) {    
    VDct1PKTFormContractTreeAttrRow(form,gadget,row);
    retFlag = 1;
  }

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1PKTFormNotifyTreeAttr(%d)\n",retFlag);
  return retFlag;
}

IGRstat	VDct1PKTDisplayNode(TGRid *nodeID, enum GRdpmode mode, IGRchar *hOpt)
{
  TGRobj_env	modelOE;
  TGRid		childID, drwID;
  IGRint	i;
  TVDvlaID      drwVLA;
  
  modelOE.obj_id.objid = NULL_OBJID;

  //if( vdtr$IsLeaf(nodeID = nodeID) )  {
    vd$trget_modelObject (	nodeID  = nodeID,
				objOE   = &modelOE);

    if (modelOE.obj_id.objid != NULL_OBJID) {
      if( !strcasecmp( hOpt, "All") || !strcasecmp( hOpt, "Model") ) {
         VD_bulkDisplayByGRobj_envs(mode,1,&modelOE);
      }
      if( !strcasecmp( hOpt, "All") || !strcasecmp( hOpt, "Drawing") ) {
        vdvla_id$Construct(vla = &drwVLA);
        vdchn$GetChildrenByClass (      objOE           = &modelOE,
                                        className       = "VDdrawing",
                                        vla             = &drwVLA);
        for(i = 0; vdvla_id$GetAt(vla=&drwVLA, nth=i, objID=&drwID); i++) {
          gr$display_object(mode = mode, object_id = &drwID);
        }
        vdvla_id$Empty(vla = &drwVLA);
        vdvla_id$Delete(vla = &drwVLA);
      }
    }
  //}

  for(i = 0; VDlnkGet(nodeID,VDCT_CHN_TREE1_TO_CHILD,i,NULL, &childID); i++) {
    VDct1PKTDisplayNode(&childID,mode,hOpt);
  }

wrapup:
  return 1;

}

/* ----------------------------------------
 * Tree name notification
 */
IGRstat VDct1PKTFormNotifyTreeDesc(Form   form, 
				       IGRint gadget, 
				       IGRint row, 
				       TGRid *treeID)
{
  IGRstat	retFlag = 0;
  IGRstat	traceFlag = traceFlagx;
  IGRchar	hOpt[80];
  
  IGRint  treeSel;

  enum GRdpmode mode;
  
  // Say Hi
  if (traceFlag) printf(">>> VDct1PKTFormNotifyTreeDesc\n"); 
  
  // See if row is now selected
  VDfrmGetSelect(form,gadget,row,tc.desc,&treeSel);

  // Check highlight option
  FIg_get_text(form,VDAT_FORM_PKT_G_HILIT_OPT,hOpt);
  if( !strcasecmp( hOpt, "None" )) {
    retFlag = 1;
    goto wrapup;
  }

  // Highlite
  if (treeSel == 0) mode = GRhe;
  else              mode = GRbdhd;
  //else              mode = GRhhd;
  

  //VDctxDisplayNode(treeID,mode,1);
  VDct1PKTDisplayNode(treeID, mode, hOpt);

  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1PKTFormNotifyTreeDesc(%d)\n",retFlag);
  return retFlag;
}

/* ----------------------------------------
 * Tree notification
 */
IGRstat VDct1PKTFormNotifyTree(Form form, IGRint gadget, TGRid *a_nodeID)
{
  VDASSERT_FN("VDct1PKTFormNotifyTree");

  IGRint retFlag = 0;
  IGRint row = -1;
  IGRint sel;

  TGRid nodeID;

  // Say Hi
  //traceFlag = traceFlagx = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  initTC(form);
  
  // Get the row
  VDfrmGetActiveRow(form,gadget,&row,NULL);
  
  // Get ID
  VDfrmGetfID(form,gadget,row,tc.grid,&nodeID);
  
  if (a_nodeID != NULL) *a_nodeID = nodeID;
  if (nodeID.objid == NULL_OBJID) goto wrapup;

  // Expansion Column
  VDfrmGetSelect(form,gadget,row,tc.exp,&sel);

  if (sel == 1) {
    VDct1PKTFormNotifyTreeExp(form,gadget,row,&nodeID);
    retFlag = 1;
    goto wrapup;
  }

  // Attribute Column
  VDfrmGetSelect(form,gadget,row,tc.atr,&sel);
  
  if (sel == 1) {
    VDct1PKTFormNotifyTreeAttr(form,gadget,row,&nodeID);
    retFlag = 1;
    goto wrapup;
  }

  // Only desc column left
  VDct1PKTFormNotifyTreeDesc(form,gadget,row,&nodeID);
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* -------------------------------------------------------------------
 * Fill one row in the set list
 * Called from pocket???
 */
IGRstat VDct1PKTFormFillSetRow(Form form, IGRint gadget, TGRid *setID)
{
  VDASSERT_FN("VDct1PKTFormFillSetRow");
  IGRstat retFlag = 0;

  IGRint  row;
  IGRchar fileName[512],*p;

  TVDctxBaseInfo baseInfo;

  // Say Hi
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  VDASSERTW(form && setID);
  
  // Get the row
  VDfrmGetNumRows(form,gadget,&row,NULL,NULL);
  
  // The file name
  som_convert_os_number_to_name(setID->osnum,fileName);
  p = strrchr(fileName,'/');
  if (p) strcpy(fileName,p+1);
  VDfrmSetfText(form,gadget,row,0,fileName);
  
  // Set type and name
  VDctxGetBaseInfo(setID,&baseInfo);

  VDfrmSetfText(form,gadget,row,1,baseInfo.setName);
  VDfrmSetfText(form,gadget,row,2,baseInfo.setType);
  
  // And the objid
  VDfrmSetfID(form,gadget,row,3,setID);

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VDct1PKTFormFillSetRow(%d)\n",retFlag);
  return retFlag;
}

/* --------------------------------------------------------
 * Fills in list of available sets
 * Mainly intended to be used with the pocket menu
 */
IGRstat VDct1PKTFormFillSets(Form form, IGRint gadget, IGRint clearGadget)
{
  VDASSERT_FN("VDct1PKTFormFillSets");

  IGRstat retFlag = 0;
  TVDosnum osnum;
  TGRid    mgrID,setID,treeID;
  IGRint   i;

  // Say Hi
  if (traceFlag) printf(">>> %s\n",fn);
 
  // Arg check
  VDASSERTW(form);
  
  // Reset gadget if we want to
  if (clearGadget) VDfrmSetNumRows(form,gadget,0);
 
  // Cycle through the os's
  for(osnum = 0; VDosValidate(osnum); osnum++) {
    
    // Get the manager
    VDct1GetManager(osnum,&mgrID);
    if (mgrID.objid != NULL_OBJID) {

      // Cycle through sets
      for(i = 0; VDctxGetNthMgrChild(&mgrID,i,&setID); i++) {
	  
	// Get the real tree
	VDctxGetNthMgrChild(&setID,0,&treeID);

	// Fill it
	VDct1PKTFormFillSetRow(form,gadget,&setID);
	
      }
    }
  }
 
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* --------------------------------------------------------------------------
 * starts at the top row on the form
 * gets the ID of the row
 * updates that row to match it's new data
 * moves on to the next row
 */ 
IGRstat VDct1PKTFormUpdateVRTree(Form form, IGRint gadget)
{
  VDASSERT_FN("VDct1PKTFormUpdateVRTree");
  
  IGRstat retFlag   = 0;
  IGRint  row;
  IGRint  col;
  IGRint  rows;
  TGRid   rowID;
  IGRchar buf[128], buf1[128], buf2[128];
  TVDfld  tmpFld;
  IGRchar *c;
  
  // Say Hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  initTC(form);
  
  // get the number of rows on the form
  VDfrmGetNumRows(form,gadget,&rows,NULL,NULL);

  // loop down through the rows get the id of the row and then update it
  for (row = 0; row < rows; row++) {

    // get the rowID 
    VDfrmGetfID(form,gadget,row,tc.grid,&rowID);

    // get the attributes for that field
    VDctxGetFldAtr(&rowID,"frozen",&tmpFld);
    strcpy(buf,"");
    if (*tmpFld.name != 0) {
      strcpy(buf1,tmpFld.val.txt);
      VDctxGetFldAtr(&rowID,"assy_rev",&tmpFld);
      // printf("tmpFld.val.txt [%s]\n",tmpFld.val.txt);
      
      strcpy(buf2,"");
      if(*tmpFld.name != 0) {
	strcpy(buf2,tmpFld.val.txt);
      }
      sprintf(buf,"%c%s",buf1[0],buf2);
      // printf("This is what the update looks like [%s]\n",buf);
    }
    
    // Set the Rev
    if (tc.ver >= 0) {  
      VDfrmSetfText(form,gadget,row,tc.ver,buf);
    }
    
    VDctxGetFldAtr(&rowID,"node_count",&tmpFld);
    strcpy(buf,"");
    if (*tmpFld.name != 0) {
      strcpy(buf,tmpFld.val.txt);
    }
    
    // Set the Count
    if (tc.qty >= 0) {  
      VDfrmSetfText(form,gadget,row,tc.qty,buf);
    }
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  // say bye
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}


end implementation Root;
