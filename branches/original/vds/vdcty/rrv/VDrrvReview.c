/* $Id: VDrrvReview.c,v 1.11 2002/06/07 20:14:49 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvCreate.C
 *
 * Description: Create Snapshot Command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvReview.c,v $
 *      Revision 1.11  2002/06/07 20:14:49  ahundiak
 *      ah
 *
 *      Revision 1.10  2002/06/04 14:04:26  ahundiak
 *      ah
 *
 *      Revision 1.9  2002/05/02 15:58:09  ahundiak
 *      ah
 *
 *      Revision 1.8  2002/02/28 15:09:24  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/10/19 18:20:55  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/09/04 13:30:33  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/03/19 22:08:14  jdsauby
 *      Moved posting to review
 *
 *      Revision 1.4  2001/03/16 19:05:38  jdsauby
 *      Modified to suit for Posting, File and Database Operations
 *
 *      Revision 1.3  2001/03/13 00:19:32  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/09 22:13:09  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/03/09 15:16:42  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/03/07 16:24:20  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/02/26 15:47:18  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/22 22:42:33  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/20 15:21:32  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/17 14:23:44  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/15/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDfrmc.h"
#include "VDtest.h"
#include "VDctx.h"
#include "VDdoom.h"
#include "VDss.h"

#include "VDrrvCmd.h"

#include <sys/types.h>
#include <dirent.h>

VDASSERT_FFN("vdcty/rrv/VDrrvReview.c");

/* -----------------------------------------------
 * Fill in list of files
 */
void VDfrmFillListFiles(Form form, IGRint gadget, IGRchar *path, IGRchar *filter)
{
  VDASSERT_FN("VDfrmFillListFiles");

  DIR *dp;
  struct dirent *dpx;

  IGRint row = 0;

  IGRchab name;
  IGRchar *p;
  
  // Arg check
  VDASSERTW(form);
  VDfrmSetgListNumRows(form,gadget,0);
  
  // Defaults
  if (path == NULL) path = ".";

  // Open up
  dp = opendir(path);
  if (dp == NULL) goto wrapup;
  
  // Cycle through
  while((dpx = readdir(dp)))
  {
    strcpy(name,dpx->d_name);
    if (filter) p = strstr(name,filter);
    else        p = name;
    if (p) {
      VDfrmSetgListText(form,gadget,row,name);
      if (row == 0) VDfrmSetgText(form,gadget,name);
      row++;
    }    
  }
  closedir(dp);
  
  // Done
 wrapup:
  return;
}

typedef struct
{ 
  Form   form;
  IGRint ready;
  IGRint loop;
  IGRint test;
  
  IGRint  statusRow;

  IGRchar logFileName[64];
  IGRchar calFileName[64];

  TGRid doom1ID;
  TGRid doom2ID;
  TGRid tree1ID;
  TGRid tree2ID;
  TGRid diffsID;

  TVDctxNodeList diffList;
  
} Ts_info;

static Ts_info *s;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;

/* -----------------------------------------------
 * Little status routine
 */
static void setStatus(IGRint flag,IGRchar *msg)
{
  VDASSERT_FN("setStatus");

  IGRchar *p;
  IGRchar buf[256];

  // Arg check
  if (s == NULL)       goto wrapup;
  if (s->form == NULL) goto wrapup;
  if (msg == NULL)     goto wrapup;
    
  // Status Bar
  switch(flag) {
    case VDLOG_INFO:
    case VDLOG_STAT:
      VDfrmSetStatus(s->form,10,msg);
      break;
  }

  // Message box
  switch(flag) {
    case VDLOG_ERROR:
    case VDLOG_WARN:
    case VDLOG_INFO:
    case 9:
      strcpy(buf,msg);
      while(*buf) {
        p = strchr(buf,'\n');
        if (p) *p = 0;
        VDfrmSetfText(s->form,VDRRV_FORM_REVIEW_G_STAT,s->statusRow,0,buf);
        VDfrmShowRow (s->form,VDRRV_FORM_REVIEW_G_STAT,s->statusRow);
        s->statusRow++;
        if (p) strcpy(buf,p+1);
        else *buf = 0;
      }
      break;
  }

  // UI_status
  switch(flag) {
    case VDLOG_STAT:
      UI_status(msg);
      break;
  }

  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the piece node id from the diff id
 * Usually it's diff_node1 but for deleted objects
 * it's in diff_node2
 */
void VDrrvGetNodefromDiff(TGRid *diffID, TGRid *nodeID)
{
  VDASSERT_FN("VDrrvGetNodefromDiff");

  IGRchab buf;
  IGRchar *p;
  
  // Arg check
  VDASSERTW(nodeID);  nodeID->objid  = NULL_OBJID;
  VDASSERTW(diffID && diffID->objid != NULL_OBJID);
  
  // Need a description
  VDctxGetTxtAtr(diffID,VDCTX_ATR_SS_DIFF_NODE1,buf);
  if (!strcmp(buf,"NONE")) {
    VDctxGetTxtAtr(diffID,VDCTX_ATR_SS_DIFF_NODE2,buf);
  }
  if (!strcmp(buf,"NONE")) goto wrapup;

  // Parse it
  nodeID->osnum = atoi(buf);
  p = strchr(buf,',');
  if (p == NULL) goto wrapup;
  nodeID->objid = atoi(p+1);

  // Maybe should validate it

 wrapup:
  return;
}

/* ----------------------------------------------
 * See if any actual attributes changed
 */
static IGRstat haveChangedAttributes(TGRid *nodeID)
{
  IGRint cnt;

  VDctxGetFldAtrs(nodeID,&cnt,NULL);
  if (cnt < 6) return 0;
  return 1;
}

/* ----------------------------------------------
 * Fill in one row
 */
static void fillDiffListRow(Form   form, 
                            IGRint gadget, 
                            IGRint show, 
                            IGRint showx, 
                            IGRint *row, 
                            TGRid *diffID)
{
  IGRchab buf;
  IGRchab pcmk;
  IGRint  i = *row;
  IGRint  changed = haveChangedAttributes(diffID);

  TGRid   nodeID;
  TVDctxBaseInfo baseInfo;

  // Grab all changed attributes
  if (show == 6) {
    showx = 1;
  }

  // Filter types
  VDctxGetTxtAtr(diffID,VDCTX_ATR_SS_DIFF_TYPE,buf);
  switch(*buf) {

    case '1':
      if ((show != 0) && (show != 1)) goto wrapup;
      VDfrmSetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DIFFS_TYPE,"NEW");
      break;

    case '2':
      if ((show != 0) && (show != 2)) goto wrapup;
      VDfrmSetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DIFFS_TYPE,"DEL");
      break;

    case '3':
      if ((show  != 0) && (show != 3) && (show != 6)) goto wrapup;
      if ((showx == 1) && (changed == 0)) goto wrapup;
      if ((showx == 2) && (changed == 1)) goto wrapup;
      VDfrmSetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DIFFS_TYPE,"MOD");
      break;

    case '4':
      if ((show  != 0) && (show != 4) && (show != 6)) goto wrapup;
      if ((showx == 1) && (changed == 0)) goto wrapup;
      if ((showx == 2) && (changed == 1)) goto wrapup;
      VDfrmSetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DIFFS_TYPE,"MOD");
      break;

    case '5':
      if ((show  != 0) && (show != 5) && (show != 6)) goto wrapup;
      if ((showx == 1) && (changed == 0)) goto wrapup;
      if ((showx == 2) && (changed == 1)) goto wrapup;
      VDfrmSetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DIFFS_TYPE,"MOD");
      break;

    default:
      VDfrmSetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DIFFS_TYPE,"???");
  }
  VDfrmSetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DIFFS_NUM,buf);

  // Store the id
  VDfrmSetfID(form,gadget,i,VDRRV_FORM_REVIEW_L_DIFFS_DIFF_ID,diffID);

  // Get the tree node
  VDrrvGetNodefromDiff(diffID,&nodeID);
  VDfrmSetfID(form,gadget,i,VDRRV_FORM_REVIEW_L_DIFFS_NODE_ID,&nodeID);

  // Need a description
  VDctxGetBaseInfo(&nodeID,&baseInfo);
  VDctxGetTxtAtr(&nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmk);
  if (*pcmk) {
    snprintf(buf,sizeof(buf),"%s %s pc%s",
             baseInfo.nodeType,
             baseInfo.nodeName,
             pcmk);
  }
  else {
    snprintf(buf,sizeof(buf),"%s %s",
             baseInfo.nodeType,
             baseInfo.nodeName);
  }
  VDfrmSetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DIFFS_DESC,buf);

  // Inc row
  *row = *row + 1;

wrapup:
  return;
}
 
/* -----------------------------------------------
 * Fill in the diffs list
 */
void VDrrvFillDiffList(Form   form, 
                       IGRint gadget, 
                       IGRint showGadget, 
                       TVDctxNodeList *diffList)
{
  VDASSERT_FN("VDrrvFillDiffList");

  TGRid  diffID;
  
  IGRint i,j;
  
  IGRchab buf;
  IGRint  show;
  IGRint  showx;

  // Arg check
  VDASSERTW(form); VDfrmSetNumRows(form,gadget,0);

  // What to show
  VDfrmGetgText(form,showGadget,buf); strcat(buf," ");
  show = atoi(buf);
  switch(*(buf+1)) {
    case 'a': showx = 1; break;
    case 'b': showx = 2; break;
    default: showx = 0;
  }

  // Cycle through
  for(i = j = 0; i < diffList->cnt; i++) {
    diffID = diffList->listIDs[i];
    fillDiffListRow(form,gadget,show,showx,&j,&diffID);

  }
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the two dooms to compare
 */
static void getDoomsToCompare(TGRid *a_doom1ID, TGRid *a_doom2ID)
{
  VDASSERT_FN("getDoomsToCompare");

  Form form = s->form;
  IGRint gadget = VDRRV_FORM_REVIEW_L_DOOMS;

  TGRid doom1ID;
  TGRid doom2ID;
  TGRid doomID;
  
  IGRint rows,row,sel;
  
  // Arg check
  VDASSERTW(a_doom1ID); a_doom1ID->objid = NULL_OBJID;
  VDASSERTW(a_doom2ID); a_doom2ID->objid = NULL_OBJID;

  // Need at least two rows
  VDfrmGetNumRows(form,gadget,&rows,NULL,NULL);
  if (rows < 2) {
    VDfrmSetStatus(form,10,"Need at least two trees to compare");
    goto wrapup;
  }

  // One pass for selected rows
  doom1ID.objid = NULL_OBJID;
  doom2ID.objid = NULL_OBJID;
  for(row = 0; row < rows; row++) {
    VDfrmGetSelect(form,gadget,row,0,&sel);
    if (sel) {

      VDfrmGetfID(form,gadget,row,VDRRV_FORM_REVIEW_L_DOOMS_ID,&doomID);
      VDASSERTW(doomID.objid != NULL_OBJID);

      if (doom1ID.objid == NULL_OBJID) doom1ID = doomID;
      else {
	doom2ID = doomID;
	*a_doom1ID = doom1ID;
	*a_doom2ID = doom2ID;
	goto wrapup;
      }
    }
  }
  
  // Just grab first two and be done with it
  VDfrmGetfID(form,gadget,0,VDRRV_FORM_REVIEW_L_DOOMS_ID,a_doom1ID);
  VDfrmGetfID(form,gadget,1,VDRRV_FORM_REVIEW_L_DOOMS_ID,a_doom2ID);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Sort two diff nodes
 */
static int compareDiffNodes(const void *p1, const void *p2) 
{
  TGRid *diff1ID = (TGRid *)p1;
  TGRid *diff2ID = (TGRid *)p2;
  TGRid  node1ID;
  TGRid  node2ID;

  IGRchab buf1,buf2;

  IGRint type1,type2,cmp;

  // Start with diff type
  VDctxGetTxtAtr(diff1ID,VDCTX_ATR_SS_DIFF_TYPE,buf1);
  VDctxGetTxtAtr(diff2ID,VDCTX_ATR_SS_DIFF_TYPE,buf2);
  type1 = atoi(buf1);
  type2 = atoi(buf2);
  if (type1 < type2) return -1;
  if (type1 > type2) return  1;

  // Sort on component name
  VDrrvGetNodefromDiff(diff1ID,&node1ID);
  VDrrvGetNodefromDiff(diff2ID,&node2ID);
  VDctxGetCompName(&node1ID,buf1);
  VDctxGetCompName(&node2ID,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  return 0;
}

/* -----------------------------------------------
 * Compare button was pushed
 */
static void compareDooms()
{
  VDASSERT_FN("compareDooms");

  TGRid doom1ID;
  TGRid doom2ID;
  TGRid diffsID;
  
  TVDdoomInfo info1,info2;

  // Free any existing stuff
  VDctxDeleteNode(&s->tree1ID);
  VDctxDeleteNode(&s->tree2ID);
  VDctxDeleteNode(&s->diffsID);
  VDctxFreeNodeList(&s->diffList);
  s->tree1ID.objid = NULL_OBJID;
  s->tree2ID.objid = NULL_OBJID;
  s->diffsID.objid = NULL_OBJID;
  VDrrvFillDiffList(s->form,
                    VDRRV_FORM_REVIEW_L_DIFFS,
                    VDRRV_FORM_REVIEW_G_SHOW,
                    &s->diffList);

  VDctxEraseHilite();
    
  // Init
  VDdoomInitDoomInfo(&info1);
  VDdoomInitDoomInfo(&info2);
  
  // Start by getting dooms to compare
  getDoomsToCompare(&s->doom1ID,&s->doom2ID);
  if (s->doom1ID.objid == NULL_OBJID) goto wrapup;
  if (s->doom2ID.objid == NULL_OBJID) goto wrapup;

  // Setup logs
  VDlogOpenCat        (s->logFileName);
  VDlogOpenCatCallback(s->calFileName,setStatus);
  
  // Get the trees
  VDlogPrintFmt(VDLOG_INFO,0,"Setting up for compare...");
  
  VDdoomFillDoomInfo(&s->doom1ID,1,&info1);
  VDdoomFillDoomInfo(&s->doom2ID,1,&info2);

  VDlogPrintFmt(VDLOG_INFO,0,"Compare %s %s %s",
		info1.baseInfo.nodeType,
		info1.baseInfo.nodeName,
		info1.ts);

  VDlogPrintFmt(VDLOG_INFO,0,"        %s %s %s",
		info2.baseInfo.nodeType,
		info2.baseInfo.nodeName,
		info2.ts);

  s->tree1ID = info1.treeID;
  s->tree2ID = info2.treeID;
  info1.treeID.objid = NULL_OBJID;
  info2.treeID.objid = NULL_OBJID;
  
  VDrrvCompareTwoTrees(&s->tree1ID,&s->tree2ID,&s->diffsID);

  // Really should always have one
  if (s->diffsID.objid == NULL_OBJID) goto wrapup;

  // Sort
  VDctxGetNodeListByType(&s->diffsID,VDCTX_NODE_TYPE_SS_DIFF,&s->diffList);
  VDctxSortNodeList(&s->diffList,compareDiffNodes);

  // Fill in diff tree
  VDrrvFillDiffList(s->form,
                    VDRRV_FORM_REVIEW_L_DIFFS,
                    VDRRV_FORM_REVIEW_G_SHOW,
                   &s->diffList);
  
 wrapup:

  // Free Up
  VDdoomFreeDoomInfo(&info1);
  VDdoomFreeDoomInfo(&info2);

  VDlogPrintFmt(VDLOG_INFO,0,"Done comparing");

  VDlogCloseCat(s->logFileName);
  VDlogCloseCat(s->calFileName);

  return;
}

/* -----------------------------------------------
 * Check to see if doom already exists.  Check against
 * type, name, and ts_creation.
 * return 1 if loaded, 0 if not loaded.
 * **/
static IGRstat isDoomLoaded(IGRchar  *name,
                            IGRchar  *msg)
{
  VDASSERT_FN("isDoomLoaded");

  IGRstat retFlag = 1;
  IGRstat sts;
  
  IGRint          i,rows;
  TVDctxBaseInfo  baseInfo;
  TGRid           rootID;
  
  IGRchab         f_ts,         // file timestamp
                  l_ts;         // loaded timestamp
  IGRchab         setType,setName;
  Form            form = s->form;
  IGRint          gadget = VDRRV_FORM_REVIEW_L_DOOMS;

  VDASSERTW( (*name != 0) && (name != NULL) );
  sprintf(msg,"%s not valid for loading",name);

  // get root node from file
  VDdoomXmlParseFileForRoot(name, &rootID);
  if (rootID.objid == NULL_OBJID) goto wrapup;

  // get some information to use for comparing
  VDctxGetBaseInfo(&rootID,&baseInfo);
  if (*baseInfo.setType == 0) goto wrapup;
  if (*baseInfo.setName == 0) goto wrapup;
  
  VDctxGetTxtAtr(&rootID,VDCTX_ATR_CREATION_TIMESTAMP,f_ts);
  if (*f_ts == 0) goto wrapup;

  // look at dooms already loaded
  // need number of rows
  rows = 0;
  VDfrmGetNumRows(form,gadget,&rows,NULL,NULL);
  if (rows < 1) {
      sprintf(msg,"Loading %s",name);
      retFlag = 0;
      goto wrapup;
  }

  // check them
  sprintf(msg,"%s Already Loaded",name);
  for (i = 0; i < rows; i++) {
      // get type, name, and ts
      VDfrmGetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DOOMS_TYPE,setType);
      VDfrmGetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DOOMS_NAME,setName);
      VDfrmGetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DOOMS_TS,  l_ts);

      // compare
      if ( (!strcmp(baseInfo.setType,setType))  &&
           (!strcmp(baseInfo.setName,setName))  &&
           (!strcmp(f_ts,            l_ts   )) ) goto wrapup;
  }

  // done, file is not already loaded
  sprintf(msg,"Loading %s",name);
  retFlag = 0;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Create a doom from an xml file
 */
void VDrrvLoadFromFile(IGRchar *name)
{
  VDASSERT_FN("VDrrvLoadFromFile");

  IGRstat sts;
  
  TGRid doomID;
  IGRchab buf;
  
  Form form = s->form;
 
  VDASSERTW( (*name != 0) && (name != NULL) );

  // check to see if doom is already loaded
  sts = isDoomLoaded(name,buf);
  if (sts) {
      VDfrmSetStatus(form,10,buf);
      goto wrapup;
  }

  // Create object
  VDdoomCreateDoomObject(NULL,&doomID);
  VDASSERTW(doomID.objid != NULL_OBJID);
  
  // Load it
  sts = VDdoomLoadFile(0,&doomID,name);
  if (!(sts & 1)) {
    sprintf(buf,"Problem loading %s",name);
    VDfrmSetStatus(form,10,buf);
    goto wrapup;
  }

  // Brag
  sprintf(buf,"Loaded %s",name);
  VDfrmSetStatus(form,10,buf);

  // Update list
  VDrrvCmdFillDoomList(form,VDRRV_FORM_REVIEW_L_DOOMS);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Delete the active doom
 * Active row not working as expected
 * Just delete first selected row
 */
static void deleteDoom()
{
  VDASSERT_FN("deleteDoom");
  
  Form form = s->form;
  IGRint gadget = VDRRV_FORM_REVIEW_L_DOOMS;
  
  TGRid doomID;
  IGRint row,rows,sel;
  
  // Get first selected row
  VDfrmGetNumRows(form,gadget,&rows,NULL,NULL);
  for(row = 0; row < rows; row++) {
    
    VDfrmGetSelect(form,gadget,row,0,&sel);
    if (sel) {      
      VDfrmGetfID(form,gadget,row,VDRRV_FORM_REVIEW_L_DOOMS_ID,&doomID);
      VDASSERTW(doomID.objid != NULL_OBJID);

      // Might regret this later but use this for now
      VDct1DeleteRootObject(&doomID);
      
      // Update list
      VDrrvCmdFillDoomList(form,VDRRV_FORM_REVIEW_L_DOOMS);

      VDfrmSetStatus(form,10,"Deleted snapshot");

      goto wrapup;
      
    }
  }
  
  VDfrmSetStatus(form,10,"Select snapshot to delete first");
  
  // Done
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Row on diff list selected
 */
static void notifyDiffList()
{
  VDASSERT_FN("notifyDiffList");
  
  Form   form = s->form;
  IGRint gadget = VDRRV_FORM_REVIEW_L_DIFFS;

  IGRint row,sel;
  enum GRdpmode mode;

  TGRid diffID,nodeID;
  
  IGRchar buf[256];
  IGRint  type;
  IGRchar *txt;
 
  IGRint cnt,i;
  TVDfld flds[128];
  
  // Make sure have a diff
  if (s->diffsID.objid == NULL_OBJID) goto wrapup;
  
  // Get the row
  VDfrmGetActiveRow(form,gadget,&row,NULL);
  if (row < 0) goto wrapup;

  // Is it selected
  VDfrmGetSelect(form,gadget,row,0,&sel);
  if (sel == 0) mode = GRheo;
  else          mode = GRhdo;

  // Grab the objects
  VDfrmGetfID(form,gadget,row,VDRRV_FORM_REVIEW_L_DIFFS_DIFF_ID,&diffID);
  VDfrmGetfID(form,gadget,row,VDRRV_FORM_REVIEW_L_DIFFS_NODE_ID,&nodeID);
  VDASSERTW(nodeID.objid != NULL_OBJID);

  // VDlogPrintObject(VDLOG_INFO,1,"Display ",NULL,&nodeID);
  
  // Finally!!!
  VDctxDisplayNode(&nodeID,mode,0);
  
  // Thats it for unselected rows
  if (sel == 0) goto wrapup;
  
  // Put out some info
  s->statusRow = 0;
  VDfrmSetNumRows(form,VDRRV_FORM_REVIEW_G_STAT,0);
  
  // The attributes
  VDctxGetFldAtrs(&diffID,&cnt,flds);
  if (cnt < 3) goto wrapup;

  // The type comment
  sprintf(buf,"%s\n",flds[2].val.txt);
  setStatus(9,buf);
    
  // Cycle through
  for(i = 5; i < cnt; i++) {
    VDctxGetTxtAtrPtr(&diffID,flds[i].name,&txt);
    sprintf(buf,"%s %s\n",flds[i].name,txt);
    setStatus(9,buf);
  }
  // The type
  type = atoi(flds[1].val.txt);
  switch(type) {

    // New tag or revised tag
    case 3:
    case 4:
      if (cnt < 6) {
	setStatus(9,"### NO ATTRIBUTES CHANGED");
      }
      break;

    case 5:
      // setStatus(9,"### NOTE TAG NUMBER AND REVISION DID NOT CHANGE");
      break;
      
  }
  VDfrmShowRow(form,VDRRV_FORM_REVIEW_G_STAT,0);
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * View XML was selected, if they want it saved, they
 * can use the save as option on the editor.
 * **/
static void notifyViewXml()
{
  VDASSERT_FN("notifyViewXml");
  Form   form = s->form;
  IGRint gadget = VDRRV_FORM_REVIEW_L_DOOMS;

  IGRint row,sel;

  TGRid   doomID;
  IGRstat sts;
  IGRchab setType,
          setName,
	  fileName;
  
  // Get the row
  VDfrmGetActiveRow(form,gadget,&row,NULL);
  if (row < 0) {
      VDfrmSetStatus(form,10,"Pick Something First");
      goto wrapup;
  }

  // Is it selected
  VDfrmGetSelect(form,gadget,row,0,&sel);
  if (sel == 0) {
      VDfrmSetStatus(form,10,"Pick Something First");
      goto wrapup;
  }

  // Grab the object
  VDfrmGetfID(form,gadget,row,VDRRV_FORM_REVIEW_L_DOOMS_ID,&doomID);
  VDASSERTW(doomID.objid != NULL_OBJID);

  // get type and name for the file name
  VDfrmGetfText(form,gadget,row,VDRRV_FORM_REVIEW_L_DOOMS_TYPE,setType);
  VDfrmGetfText(form,gadget,row,VDRRV_FORM_REVIEW_L_DOOMS_NAME,setName);
  sprintf(fileName,"/usr/tmp/%s_%s.ss.xml",setType,setName);

  // save the file to view
  sts = VDdoomSaveFile(0,&doomID,fileName);
  if (!(sts & 1)) {
      VDfrmSetStatus(form,10,"Problem Making File");
      goto wrapup;
  }

  // open it up for viewing
  VDlogShowCat(fileName);

  // done
wrapup:
  return;
}

/* -----------------------------------
 * Post XML button was pushed
 * **/
static void notifyPostXml()
{
  VDASSERT_FN("notifyPostXml");
  Form   form = s->form;
  IGRint gadget = VDRRV_FORM_REVIEW_L_DOOMS;

  IGRint row,sel;

  TGRid   doomID;
  IGRstat sts;
  IGRchab setType,
          setName,
	  fileName,
	  msg;
  
  // Get the row
  VDfrmGetActiveRow(form,gadget,&row,NULL);
  if (row < 0) {
      VDfrmSetStatus(form,10,"Pick Something First");
      goto wrapup;
  }

  // Is it selected
  VDfrmGetSelect(form,gadget,row,0,&sel);
  if (sel == 0) {
      VDfrmSetStatus(form,10,"Pick Something First");
      goto wrapup;
  }

  // Grab the object
  VDfrmGetfID(form,gadget,row,VDRRV_FORM_REVIEW_L_DOOMS_ID,&doomID);
  VDASSERTW(doomID.objid != NULL_OBJID);

  // get type and name for the file name
  VDfrmGetfText(form,gadget,row,VDRRV_FORM_REVIEW_L_DOOMS_TYPE,setType);
  VDfrmGetfText(form,gadget,row,VDRRV_FORM_REVIEW_L_DOOMS_NAME,setName);
  sprintf(fileName,"/usr/tmp/%s_%s.ss.xml",setType,setName);

  // save the file to view
  sts = VDdoomSaveFile(0,&doomID,fileName);
  if (!(sts & 1)) {
      VDfrmSetStatus(form,10,"Problem Making File");
      goto wrapup;
  }

  // post it
  VDrrvPostXmlSnapshotFile( fileName, msg );

  if (*msg) VDfrmSetStatus(form,10,msg); 
  // done
wrapup:
  return;
}
   
/* -----------------------------------------------
 * Notification routine
 */
IGRint VDrrvCmdNotifyReview(IGRint    f_label,
			    IGRint    gadget,
			    IGRdouble value,
			    Form      form)
{
  VDASSERT_FN("VDrrvCmdNotifyReview");
  IGRstat retFlag = 0;

  // Internal data must be set
  VDASSERTW(s);
  VDASSERTW(s->form);
  
  // Want to kill ops forms when this form is notified
  if (gadget != VDRRV_FORM_REVIEW_B_FILE_OPS) {
      VDrrvCmdKillSnapshotFileOps();
  }
  if (gadget != VDRRV_FORM_REVIEW_B_DB_OPS) {
      VDrrvCmdKillSnapshotDbOps();
  }

  // Process it
  switch(gadget) {

    case FI_CANCEL:

      // Clean up
      VDfrmDeleteForm(s->form,0);
      s->form = NULL;
      s->loop = 0;

      // Break out of locate loop
      VDputResponse(RESET);
      break;

    case VDRRV_FORM_REVIEW_L_DIFFS:
      notifyDiffList();
      break;

    case VDRRV_FORM_REVIEW_G_SHOW:
      VDrrvFillDiffList(s->form,
                        VDRRV_FORM_REVIEW_L_DIFFS,
                        VDRRV_FORM_REVIEW_G_SHOW,
                       &s->diffList);
      break;


#if 0
    case VDRRV_FORM_REVIEW_B_LOAD_FILE:
      loadFromFile();
      break;
#endif
    case VDRRV_FORM_REVIEW_B_COMPARE:
      compareDooms();
      break;

    case VDRRV_FORM_REVIEW_B_DELETE:
      deleteDoom();
      break;
      
    case VDRRV_FORM_REVIEW_B_FILE_OPS:
      VDrrvCmdInitSnapshotFileOps();
      break;
  
    case VDRRV_FORM_REVIEW_B_DB_OPS:
      VDrrvCmdInitSnapshotDbOps();
      break;
  
    case VDRRV_FORM_REVIEW_B_VIEW_XML:
      notifyViewXml();
      break;
  
    case VDRRV_FORM_REVIEW_B_POST_XML:
      notifyPostXml();
      break;
  
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Sort stuff
 */
static IGRint sortDoomInfos(const void *s1, const void *s2)
{
  TVDdoomInfo *d1 = (TVDdoomInfo*) s1;
  TVDdoomInfo *d2 = (TVDdoomInfo*) s2;

  IGRint  cmp;
  
  // Mainly by time stamp (Reverse order)
  cmp = strcmp(d2->ts,d1->ts);
  if (cmp) return cmp;
  
  // Type and name
  cmp = strcmp(d1->baseInfo.nodeType,d2->baseInfo.nodeType);
  if (cmp) return cmp;

  cmp = strcmp(d1->baseInfo.nodeName,d2->baseInfo.nodeName);
  if (cmp) return cmp;

  return 0;
}

/* -----------------------------------------------
 * Fill in list of available dooms
 */
void VDrrvCmdFillDoomList(Form form, IGRint gadget)
{
  VDASSERT_FN("VDrrvFillDoomList");
  IGRstat retFlag = 0;

  TVDdoomInfo *infos = NULL;
  TVDdoomInfo *info  = NULL;
  IGRint i,cnt;

  TGRid doomID;
  
  // Arg check
  VDASSERTW(form);
  
  // Clear
  VDfrmSetNumRows(form,gadget,0);
  
  // Get a list
  VDdoomGetCnt(&cnt);
  if (cnt == 0) goto wrapup;
  infos = calloc(cnt,sizeof(TVDdoomInfo));
  VDASSERTW(infos);
  
  // Cycle through
  for(i = 0; i < cnt; i++) {

    info = &infos[i];
    
    VDdoomGetNthObject(i,&doomID);
    VDASSERTW(doomID.objid != NULL_OBJID);

    VDdoomFillDoomInfo(&doomID,0,info);
    VDASSERTW(info->rootID.objid != NULL_OBJID);
  }
  
  // Sort em
  qsort(infos,cnt,sizeof(TVDdoomInfo),sortDoomInfos);
  
  // Display
  for(i = 0; i < cnt; i++) {
    
    info = &infos[i];
        
    // Display it
    VDfrmSetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DOOMS_TYPE,info->baseInfo.treeType);
    VDfrmSetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DOOMS_NAME,info->baseInfo.treeName);
    VDfrmSetfText(form,gadget,i,VDRRV_FORM_REVIEW_L_DOOMS_TS,  info->ts);
    VDfrmSetfID  (form,gadget,i,VDRRV_FORM_REVIEW_L_DOOMS_ID,  &info->doomID);
        
    
    // Free
    VDdoomFreeDoomInfo(info);    
  }
      
 wrapup:
  if (infos) free(infos);
  
  return;
}

/* -----------------------------------------------
 * Get the whole thing going
 *
 */
IGRstat VDrrvCmdInitReviewSnapshot(TVDtestTestInfo *testInfo)
{
  VDASSERT_FN("VDrrvCmdReviewSnapshot");
  IGRstat retFlag = 0;
  IGRstat sts;

  XEvent event;
  
  IGRchar unit  [40];
  IGRchar model[128];

  VDosnum osnum;
  
  // Should not be called recursivily
  VDASSERTW(s == NULL);

  // Clear screen
  VDctxEraseHilite();
  
  // Setup structure
  s = calloc(1,sizeof(Ts_info));
  VDASSERTW(s);

  // Files
  sprintf(s->calFileName,"review.cal");
  sprintf(s->logFileName,"review.log");

  // Objects
  s->doom1ID.objid = NULL_OBJID;
  s->doom2ID.objid = NULL_OBJID;
  s->tree1ID.objid = NULL_OBJID;
  s->tree2ID.objid = NULL_OBJID;
  s->diffsID.objid = NULL_OBJID;

  VDctxInitNodeList(&s->diffList);
  
  // Create the form
  sts = VDfrmNewForm(VDRRV_FORM_REVIEW_NUM,
		     VDRRV_FORM_REVIEW_NAME,
		     VDrrvCmdNotifyReview,1,&s->form);
  VDASSERTW(sts);
  VDASSERTW(s->form);

  // Display it
  VDfrmDisplayForm(s->form,1,NULL);

  // Fill in default info
  VDrrvCmdFillDoomList(s->form, VDRRV_FORM_REVIEW_L_DOOMS);

  //VDfrmFillListFiles(s->form, VDRRV_FORM_REVIEW_G_FILES,".",".xml");
  VIg_erase(s->form, VDRRV_FORM_REVIEW_G_FILES);
  VIg_erase(s->form, VDRRV_FORM_REVIEW_B_LOAD_FILE);

  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Loop on events
 * Usually called from a test routine
 * really need to add prompts and command name here
 */
void VDrrvCmdLoopReviewSnapshot()
{
  VDASSERT_FN("VDrrvCmdLoopReviewSnapshot");
  IGRstat sts;

  XEvent event;
  
  // Should not be called recursivily
  VDASSERTW(s && s->form);
  
  // Loop until form told to break out
  s->loop = 1;
  while(s->loop) {
    XNextEvent(_FI_display, &event);
    FI_process_event(&event, 0);
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Shuts down
 * Usually called from the ppl command object on
 * something like clear stack.
 */
void VDrrvCmdKillReviewSnapshot()
{
  VDASSERT_FN("VDrrvCmdKillReviewSnapshot");
  
  // Check if running
  if (s == NULL) goto wrapup;

  // Free the form if necessary
  if (s->form) VDfrmDeleteForm(s->form,1);

  // Free the working objects
  VDctxDeleteNode(&s->diffsID);
  VDctxDeleteNode(&s->tree1ID);
  VDctxDeleteNode(&s->tree2ID);

  VDctxFreeNodeList(&s->diffList);

  // File operations form
  VDrrvCmdKillSnapshotFileOps();

  // Done
  free(s); s = NULL;
  
 wrapup:
  return;  
}


/* -----------------------------------------------
 * Automated testing
 */
void VDtestReviewSnapshot(TVDtestTestInfo *testInfo)
{
  VDASSERT_FN("VDtestReviewSnapshot");
  IGRstat sts;
  
  // Arg check
  VDASSERTW(testInfo);
  
  // Assume it worked
  testInfo->worked = 1;

  // Get started
  sts = VDrrvCmdInitReviewSnapshot(testInfo);
  VDASSERTW(sts & 1);
  
  // Push the compare button
  VDrrvCmdNotifyReview(0,VDRRV_FORM_REVIEW_B_COMPARE,0.0,NULL);
  
  // Finish up
  if (testInfo->stopWhenDone) {
    VDrrvCmdKillReviewSnapshot();
  }
  else {
    //VDrrvCmdNotifyReview(0,VDRRV_FORM_CREATE_B_TREE,0.0,NULL);    
    VDrrvCmdLoopReviewSnapshot();
    VDrrvCmdKillReviewSnapshot();
  }
  
 wrapup:
  return;
}
