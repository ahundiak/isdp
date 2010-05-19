/* $Id: VDdomTreeF.c,v 1.2 2001/03/11 18:35:11 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vddom/VDdomTreeF.c
 *
 * Description: Basic dom tree gadget routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdomTreeF.c,v $
 *      Revision 1.2  2001/03/11 18:35:11  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/11 19:28:37  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
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

VDASSERT_FFN("vds/vddom/VDdomTreeF.c");

// The Tree
#define VDCT_FORM_TREE_F_NAME         "VDct1Tree.F"
#define VDCT_FORM_TREE_G_SET_NAME      51
#define VDCT_FORM_TREE_G_TREE          26
#define VDCT_FORM_TREE_B_UNSELECT_ALL  12
#define VDCT_FORM_TREE_B_UNHILITE_ALL  13
#define VDCT_FORM_TREE_B_HILITE_SELECT 14
#define VDCT_FORM_TREE_G_DISPLAY       15

// Tree F
#define VDCT_FORM_TREE_COL_ATR          0
#define VDCT_FORM_TREE_COL_EXP          1
#define VDCT_FORM_TREE_COL_QTY          2
#define VDCT_FORM_TREE_COL_VER          3
#define VDCT_FORM_TREE_COL_DESC         4
#define VDCT_FORM_TREE_COL_GRID         5
#define VDCT_FORM_TREE_COL_LEVEL        6
#define VDCT_FORM_TREE_T_WORK          22
#define VDCT_FORM_G_DISP               15

IGRstat VDdomFormClearTree      (Form form, IGRint gadget);
IGRstat VDdomFormUpdateTreeRow  (Form form, IGRint gadget, TGRid *rowID);

IGRstat VDdomFormContractTreeRow  (Form form, IGRint gadget, IGRint row);
IGRstat VDdomFormContractTreeRowID(Form form, IGRint gadget, TGRid *rowID);

IGRstat VDdomFormExpandTreeRow  (Form form, IGRint gadget, IGRint row);
IGRstat VDdomFormExpandTreeRowID(Form form, IGRint gadget, TGRid *rowID);

IGRstat VDdomFormFindTreeRow(Form    form, 
			     IGRint  gadget, 
			     TGRid  *workID, 
			     IGRint *rowFound);

IGRstat VDdomFormRefreshNodeName(Form    form, 
				 IGRint  gadget, 
				 IGRint  row, 
				 TGRid  *nodeID);

IGRstat VDdomFormFillTreeRow(Form    form, 
			     IGRint  gadget, 
			     IGRint *row, 
			     IGRint  level,
			     TGRid  *nodeID,
			     IGRint  atrFlag,
			     IGRint  expFlag);

IGRstat VDdomFormFillTree(Form form, IGRint gadget, TGRid *setID);

IGRstat VDdomFormExpandTreeAttrRow  (Form form, IGRint gadget, IGRint row);
IGRstat VDdomFormContractTreeAttrRow(Form form, IGRint gadget, IGRint row);

IGRstat VDdomFormDeleteTreeRow  (Form form, IGRint gadget, IGRint row);
IGRstat VDdomFormDeleteTreeRowID(Form form, IGRint gadget, TGRid *rowID);

IGRstat VDdomFormNotifyTreeName(Form   form, 
				IGRint gadget, 
				IGRint row, 
				TGRid *treeID);

IGRstat VDdomFormNotifyTree(Form form, IGRint gadget, TGRid *nodeID);

IGRstat VDdomFormNotifyTreeAttr(Form   form, 
				IGRint gadget, 
				IGRint row, 
				TGRid *rootID);

IGRstat VDdomFormNotifyTreeExp(Form   form, 
			       IGRint gadget, 
			       IGRint row, 
			       TGRid *rootID);

/* -----------------------------------------
 * Finds row in tree gadget containing id
 */
IGRstat VDdomFormFindTreeRow(Form    form, 
			     IGRint  gadget, 
			     TGRid  *workID, 
			     IGRint *rowFound)
{
  VDASSERT_FN("VDdomFormFindTreeRow");
  
  IGRstat retFlag = 0;
  IGRint  row,rows;
  TGRid   rowID;

  // Init
  if (rowFound == NULL) goto wrapup;
  *rowFound = -1;

  // Cycle through
  VDfrmGetNumRows(form,gadget,&rows,NULL,NULL);  
  for(row = 0; row < rows; row++) {

    VDfrmGetfID(form,gadget,row,VDCT_FORM_TREE_COL_GRID,&rowID);

    if ((rowID.objid == workID->objid) &&
        (rowID.osnum == workID->osnum)) {

      *rowFound = row;
      return 1;
    }
  }

 wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Fill in one row in tree gadget
 */
IGRstat VDdomFormFillTreeRow(Form    form, 
			     IGRint  gadget, 
			     IGRint *rowx, 
			     IGRint  level,
			     TGRid  *nodeID,
			     IGRint  atrFlag,
			     IGRint  expFlag)
{
  VDASSERT_FN("VDdomFormFillTreeRow");
  
  IGRstat  retFlag = 0;

  IGRchar  desc[1024];
  IGRchar *pnt;
  IGRint   i;

  IGRchar  buf[128], buf1[128];
  IGRchar *c;
  
  IGRint row;

  TGRid childID;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);
 
  // Arg Check
  VDASSERTW(nodeID);
  VDASSERTW(rowx);
  row = *rowx;
  
  // Description
  for(i = 0, pnt = desc; i < level; i++) *pnt++ = ' '; *pnt = 0;
  VDdomGetObjDesc(nodeID,pnt);  
  VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_DESC,desc);

  // Attribute Flag
  if (atrFlag == 0) strcpy(desc,"-");
  else              strcpy(desc,"+");
  VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_ATR,desc);

  // Expansion flag
  if (expFlag == 0) strcpy(desc,"-");
  else              strcpy(desc,"+");

  VDdomGetNthChildObj(nodeID,0,&childID);
  if (childID.objid == NULL_OBJID) strcpy(desc," ");
  
  VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_EXP,desc);
 
  // Save the nodes address
  VDfrmSetfID(form,gadget,row,VDCT_FORM_TREE_COL_GRID,nodeID);

  // Level
  sprintf(desc,"%d",level);
  VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_LEVEL,desc);
   
  // Done
  *rowx = *rowx + 1;
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* ----------------------------------------
 * Fill in tree gadget
 */
IGRstat VDdomFormFillTree(Form form, IGRint gadget, TGRid *treeID)
{
  VDASSERT_FN("VDdomFormFillTree");
  
  IGRstat retFlag = 0;
  IGRint  row;
  IGRint  i;
  
  TGRid childID;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s %d\n",fn);

  // Clear Field
  VDfrmSetNumRows(form, gadget, 0);
  
  // Make sure have a tree
  if ((treeID == NULL) || (treeID->objid == NULL_OBJID)) {
    retFlag = 1;
    goto wrapup;
  }
 
  // Put out top node
  row = 0;
  VDdomFormFillTreeRow(form,gadget,&row,0,treeID,0,1);

  // Put out next level
  for(i = 0; VDdomGetNthChildObj(treeID,i,&childID); i++) {    
    VDdomFormFillTreeRow(form,gadget,&row,1,&childID,0,0);
  }
    
  // Done
  retFlag = 1;

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* ---------------------------------------------
 * Contract a row if it is expanded
 */
IGRstat VDdomFormContractTreeRow(Form form, IGRint gadget, IGRint row)
{
  VDASSERT_FN("VDdomFormContractTreeRow");
  IGRstat retFlag = 0;  

  IGRint  level,levelX;
  IGRchar buf[128];

  IGRint  rowX,rowMax,rowCnt;

  // Say hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s %d\n",fn,row);

  // Contract attributes
  VDdomFormContractTreeAttrRow(form, gadget, row);

  // See if expand or contract
  VDfrmGetfText(form,gadget,row,VDCT_FORM_TREE_COL_EXP,buf);  
  if (*buf != '+') goto wrapup;

  // Get level
  VDfrmGetfText(form,gadget,row,VDCT_FORM_TREE_COL_LEVEL,buf);  
  level = atoi(buf);

  // Set contract flag
  VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_EXP,"-");  

  // Delete rows
  VDfrmGetNumRows(form,gadget,&rowMax,NULL,NULL);  
  rowMax++;
  
  levelX = level + 1;
  row++;

  for(rowX = row; (rowX < rowMax) && (levelX > level); rowX++) {
    
    // Find previous level
    VDfrmGetfText(form,gadget,rowX,VDCT_FORM_TREE_COL_LEVEL,buf);  
    levelX = atoi(buf);
  }
  rowCnt = rowX - row - 1;
  if (rowCnt > 0) {
    VDfrmDeleteRows(form,gadget,row,rowCnt);
  }

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

IGRstat VDdomFormContractTreeRowID(Form form, IGRint gadget, TGRid *rowID)
{
  VDASSERT_FN("VDdomFormContractTreeRowID");
  
  IGRstat retFlag = 1;
  
  IGRint  row;

  // Get the row
  VDdomFormFindTreeRow(form,gadget,rowID,&row);
  if (row < 0) goto wrapup;

  // Contract it
  VDdomFormContractTreeRow(form,gadget,row);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Expand a row if it is contracted
 */
IGRstat VDdomFormExpandTreeRow(Form form, IGRint gadget, IGRint row)
{
  VDASSERT_FN("VDdomFormExpandTreeRow");
  IGRstat retFlag = 0;

  IGRint  level;
  IGRchar buf[128];
  TGRid   rootID,nodeID;
  IGRuint i;
  IGRstat sts = 1;
  IGRint  dispFlag; 
  IGRchar c;
  
  // Say hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s, Row %d\n",fn,row); 

  // Contract attributes
  VDdomFormContractTreeAttrRow(form, gadget, row);

  // See if expand or contract
  VDfrmGetfText(form,gadget,row,VDCT_FORM_TREE_COL_EXP,buf);
  if (*buf != '-') goto wrapup;

  // Get level
  VDfrmGetfText(form,gadget,row,VDCT_FORM_TREE_COL_LEVEL,buf);
  level = atoi(buf);

  // Get the id
  VDfrmGetfID(form,gadget,row,VDCT_FORM_TREE_COL_GRID,&rootID);
  if (traceFlag) printf("Root ID %d,%d\n",rootID.osnum,rootID.objid);
  if (rootID.objid == NULL_OBJID) goto wrapup;

  // Set expand flag
  VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_EXP,"+");

#if 0
  // Read the gadget on the form
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_G_DISP,
		txt    = buf);
  // set the value 
  switch(*buf) {   
  case '1': dispFlag = 1; break;  
  case '2': dispFlag = 2; break;   
  case '3': dispFlag = 3; break;  
  case '4': dispFlag = 4; break;  
  case '5': dispFlag = 5; break;
  case '6': dispFlag = 6; break;  
  }
#endif

  // Insert kids
  level++;
  row++;
  for(i = 0; VDdomGetNthChildObj(&rootID, i, &nodeID); i++) {

    // check the rules
    //sts = vdct1$IsDiplayOK(rootID     = &nodeID,
    //			   dispOption = &dispFlag);

    // wrapper to control the expansion
    sts = 1;
    if (sts & 1) { 
      VDfrmInsertBlankRow (form,gadget, row);
      VDdomFormFillTreeRow(form,gadget,&row,level,&nodeID,0,0);
    }
    
  }

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

IGRstat VDdomFormExpandTreeRowID(Form form, IGRint gadget, TGRid *rowID)
{
  IGRstat retFlag = 1;
  IGRint  row;

  VDdomFormFindTreeRow(form,gadget,rowID,&row);
  if (row < 0) goto wrapup;

  VDdomFormExpandTreeRow(form,gadget,row);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Tree expand notification
 */
IGRstat VDdomFormNotifyTreeExp(Form   form, 
			       IGRint gadget, 
			       IGRint row, 
			       TGRid *rootID)
{
  VDASSERT_FN("VDdomFormNotifyTreeExp");
  IGRstat  retFlag = 0;
  
  IGRchar  buf[32];
  TGRid    rowID;
  
  // Say hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn); 

  // Unselect it
  VDfrmSetSelect(form,gadget,row,VDCT_FORM_TREE_COL_EXP,0);
  
  // See if expand or contract
  VDfrmGetfText(form,gadget,row,VDCT_FORM_TREE_COL_EXP,buf);
  
  // Get the id
  VDfrmGetfID(form,gadget,row,VDCT_FORM_TREE_COL_GRID,&rowID);

  // Pre process it, the op in buf may change
  // VDct1PreExpandContractNode(&rowID, buf);
  
  if (traceFlag) printf("### Back from PreExpandContractNode\n");
  VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_EXP,buf);
  
  // Process
  switch(*buf) {  

    case '-':
      VDdomFormExpandTreeRow(form,gadget,row);
      retFlag = 1;
      break;

    case '+':
      VDdomFormContractTreeRow(form,gadget,row);
      retFlag = 1;
      break;
  }

  // Done
  retFlag = 1;
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

 wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Tree name notification
 * Kicks off hilite
 */
IGRstat VDdomFormNotifyTreeDesc(Form   form, 
				IGRint gadget, 
				IGRint row, 
				TGRid *treeID)
{
  VDASSERT_FN("VDdomFormNotifyTreeDesc");
  IGRstat retFlag = 0;
  
  IGRint  sel;
#if 0
  enum GRdpmode mode;

  TVDct1JD  treeJD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn); 

  // init
  treeJD.cl = VDct1GetTreeClassForNode(treeID);
  if (treeJD.cl == NULL) goto wrapup;
  treeJD.id = *treeID;
  
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

  _RTCJDB(&treeJD)->displayNode(&treeJD,mode,1);
#endif

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* ---------------------------------------------
 * Expand a row if it is contracted
 */
IGRstat VDdomFormExpandTreeAttrRow(Form form, IGRint gadget, IGRint row)
{
  VDASSERT_FN("VDdomFormExpandTreeAttrRow");
  
  IGRstat retFlag = 0;

  IGRchar desc[1024],*p;
  IGRchar buf [128];
  TGRid   rootID;
  IGRuint i,level;

  IGRint  cnt;
  
  TVDdomAtr *atr;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s %d\n",fn,row);

  // See if expand or contract
  VDfrmGetfText(form,gadget,row,VDCT_FORM_TREE_COL_ATR,buf);
  if (*buf != '-') goto wrapup;

  // Get the id
  VDfrmGetfID(form,gadget,row,VDCT_FORM_TREE_COL_GRID,&rootID);
  if (rootID.objid == NULL_OBJID) goto wrapup;

  // Get the level for prefix blanks
  VDfrmGetfText(form,gadget,row,VDCT_FORM_TREE_COL_LEVEL,buf);
  level = atoi(buf) + 1;

  // Pad it
  for(i = 0, p = desc; i < level; i++,p++) *p = ' ';

  // Set expand flag
  VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_ATR,"+");

  // Insert kids
  row++;

  // Cycle through
  for(i = 0; VDdomGetNthAtr(&rootID,i,&atr); i++) {

    // Get the description
    sprintf(p,"%s = %s",atr->type,atr->value);
    
    // Insert
    VDfrmInsertBlankRow(form, gadget, row);

    // No attributes
    VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_ATR," ");

    // No expansion
    VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_EXP," ");

    // Description
    VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_DESC,desc);

    // No id
    VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_GRID,"");

    // Level
    sprintf(buf,"%d",level);
    VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_LEVEL,buf);
    
    row++;
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
IGRstat VDdomFormContractTreeAttrRow(Form form, IGRint gadget, IGRint row)
{
  VDASSERT_FN("VDdomFormContractTreeAttrRow");
  
  IGRstat retFlag = 0;
  IGRchar buf[128];

  IGRint  rowX,rowMax,rowCnt;

  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s, Row %d\n",fn,row);

  // Get the flag
  VDfrmGetfText(form,gadget,row,VDCT_FORM_TREE_COL_ATR,buf);
  if (*buf != '+') goto wrapup;

  // Set expand flag
  VDfrmSetfText(form,gadget,row,VDCT_FORM_TREE_COL_ATR,"-");
  
  // Delete rows
  VDfrmGetNumRows(form,gadget,&rowMax,NULL,NULL);  
  rowMax++;

  *buf = ' ';
  row++;

  // Find first row of next object
  for(rowX = row; (rowX < rowMax) && (*buf == ' '); rowX++) {
    VDfrmGetfText(form,gadget,rowX,VDCT_FORM_TREE_COL_ATR,buf);    
  }

  // Delete em
  rowCnt = rowX - row - 1;
  if (rowCnt > 0) {
    VDfrmDeleteRows(form,gadget,row,rowCnt);    
  }

  retFlag = 1;
  
 wrapup: 
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);  
  return retFlag;
}

/* ----------------------------------------
 * Tree attribute notification
 */

IGRstat VDdomFormNotifyTreeAttr(Form   form, 
				IGRint gadget, 
				IGRint row, 
				TGRid *rootID)
{
  VDASSERT_FN("VDdomFormNotifyTreeAttr");
  
  IGRstat  retFlag = 0;
  IGRchar  buf[32];

  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s, Row %d\n",fn,row); 

  // Unselect it
  VDfrmSetSelect(form,gadget,row,VDCT_FORM_TREE_COL_ATR,0);
  
  // See if expand or contract
  VDfrmGetfText(form,gadget,row,VDCT_FORM_TREE_COL_ATR,buf);
  
  switch(*buf) {  

    case '-':
      VDdomFormExpandTreeAttrRow(form,gadget,row);
      retFlag = 1;
      break;

    case '+':
      VDdomFormContractTreeAttrRow(form,gadget,row);
      retFlag = 1;
      break;
  }

  // Done
  retFlag = 1;

 wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* ----------------------------------------
 * Tree notification, returns active nodeDD
 */
IGRstat VDdomFormNotifyTree(Form form, IGRint gadget, TGRid *a_nodeID)
{
  VDASSERT_FN("VDdomFormNotifyTree");
  
  IGRint  retFlag = 0;  
  IGRint  row = -1;
  IGRint  sel;

  TGRid nodeID;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s %d\n",fn,gadget);

  // Arg check
  if (a_nodeID) a_nodeID->objid = NULL_OBJID;

  // Get the row
  VDfrmGetActiveRow(form,gadget,&row,NULL);
  if (traceFlag) printf("Active Row is %d\n",row);
  
  // Get ID
  VDfrmGetfID(form,gadget,row,VDCT_FORM_TREE_COL_GRID,&nodeID);
  if (traceFlag) printf("Active ID  is %d,%d\n",nodeID.osnum,nodeID.objid);
  if (nodeID.objid == NULL_OBJID) goto wrapup;  
  if (a_nodeID) *a_nodeID = nodeID;

  // Expansion Column
  VDfrmGetSelect(form,gadget,row,VDCT_FORM_TREE_COL_EXP,&sel);
  if (traceFlag) printf("Select     is %d\n",sel);
  if (sel == 1) {
    VDdomFormNotifyTreeExp(form,gadget,row,&nodeID);
    retFlag = 1;
    goto wrapup;
  }

  // Attribute Column
  VDfrmGetSelect(form,gadget,row,VDCT_FORM_TREE_COL_ATR,&sel);  
  if (sel == 1) {
    VDdomFormNotifyTreeAttr(form,gadget,row,&nodeID);
    retFlag = 1;
    goto wrapup;
  }

  // Only desc column left
  // VDdomFormNotifyTreeDesc(form,gadget,row,&nodeID);
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}
