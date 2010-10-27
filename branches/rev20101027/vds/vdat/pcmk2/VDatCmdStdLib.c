/* $Id: VDatCmdStdLib.c,v 1.1 2002/02/28 22:23:11 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatCmdStdLib.c
 *
 * Description:	Command object for managing standard piece library
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatCmdStdLib.c,v $
 *      Revision 1.1  2002/02/28 22:23:11  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/09/02  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDtest.h"
#include "VDrisc.h"
#include "VDfrmc.h"
#include "VDgeomc.h"
#include "VDbuf.h"
#include "VDxdom.h"
#include "VDctx.h"
#include "VDval.h"
#include "VDvalLike.h"
#include "VDvalConv.h"
#include "VDss.h"
#include "VDtag.h"
#include "stdarg.h"
#include "glib.h"

VDASSERT_FFN("VDatCmdStdLib.c");

typedef struct
{ 
  Form   form;
  IGRint ready;
  IGRint loop;
  IGRint test;
  TGRid  doomID;
  TGRid  treeID;
  
  IGRint  statusRow;
  IGRchar curFileName[64];
  IGRchar xmlFileName[64];
  IGRchar domFileName[64];
  IGRchar logFileName[64];
  IGRchar calFileName[64];
  
} Ts_info;

static Ts_info *s;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;

#define VDAT_FORM_STD_LIB_NUM  110
#define VDAT_FORM_STD_LIB_NAME "VDatStdLib.F"

#define VDAT_FORM_STD_LIB_G_BOUNCE_NO_UPDATE 12
#define VDAT_FORM_STD_LIB_G_BOUNCE_UPDATE    13
#define VDAT_FORM_STD_LIB_G_EMPTY_STD_GEOM2  14
#define VDAT_FORM_STD_LIB_T_MASTER           16

/* -----------------------------------------------
 * Be careful about trailing blanks
 * Looks like they get stripped when queried from database?
 * Need to test what is actually on the database
 * Maybe add a trailing character just to keep length fixed
 */
static void stripBlanks(IGRchar *str)
{
  IGRchar *p;
  
  for(p = str + strlen(str) - 1; (p >= str) && (*p == ' '); p--);
  *(p+1) = 0;
  return;
  
}

  
/* -----------------------------------------------
 * For comparing
 */
static int compareGeomKey(const void *p1, const void *p2)
{
  TGRid *info1ID = (TGRid*)p1;
  TGRid *info2ID = (TGRid*)p2;

  IGRchar *buf1,*buf2;
  
  IGRint cmp;

  // geom_key
  VDctxGetTxtAtrPtr(info1ID,VDCTX_STD_PCMK_ATR_GEOM_KEY,&buf1);
  VDctxGetTxtAtrPtr(info2ID,VDCTX_STD_PCMK_ATR_GEOM_KEY,&buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  return 0;
}

/* -----------------------------------------------
 * avoid dups
 */
static int getGeomKeyGroupCnt(TVDctxNodeList *nodeList, IGRint nth)
{
  VDASSERT_FN("getGeomKeyGroupCnt");

  IGRint cnt = 1;
  
  IGRint sts;
  IGRint j;
  
  // Arg check
  VDASSERTW((nth >= 0) && (nth < nodeList->cnt));

  for(j = nth + 1; j < nodeList->cnt; j++) {
    
    sts = compareGeomKey(&nodeList->listIDs[nth],&nodeList->listIDs[j]);
    if (sts) goto wrapup;
    cnt++;
  }
  
 wrapup:
  // if (cnt > 1) printf("*** Dup Record %4d %d\n",nth,cnt);  
  return cnt;
}

/* -----------------------------------------------
 * Make a tree of standard pieces
 */
static void createPieceTree(IGRint contourFlag, TGRid *treeID) 
{
  VDASSERT_FN("createPieceTree");
  
  IGRint  plateCnt,beamCnt,pieceCnt;
  IGRchab geom_key,grade,thickness;
  
  TGRid *listIDs = NULL;

  TGRid      pieceID;
  TGRobj_env pieceOE;

  IGRint i;
  
  TGRid nodeID;

  VDosnum osnum;

  IGRint want;
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  
  // Current os
  VDosGetCurrentOS(&osnum);

  // Update
  VDfrmSetgText(s->form,10,"Creating Standard Piece Tree...");
  
  // Get list of pieces
  VDobjGetPieces(osnum, &plateCnt, &beamCnt, &listIDs);
  pieceCnt = plateCnt + beamCnt;
  
  // Build the tree
  VDctxCreateXdomTree(VDCTX_NODE_TYPE_SS_OM_PIECES,NULL,treeID);
  
  // Want geometry
  if (contourFlag) want = VDVAL_DOM_WANT_GEOM;
  else             want = VDVAL_DOM_WANT_MED;
  
  // Cycle through
  for(i = 0; i < pieceCnt; i++) {

    // Setup piece
    pieceID = listIDs[i];
    pieceOE.obj_id = pieceID;
    VDobjResetOE(&pieceOE);

    // Get the key
    VDvalGetStdPcmk2Info(&pieceOE,geom_key,grade,thickness);
    if (*geom_key) {
      
      // Create the node
      VDvalConvertPieceToDom(&pieceOE,treeID,&nodeID,NULL,want);
      VDASSERTW(nodeID.objid != NULL_OBJID);

      // Add the geometry key
      stripBlanks(geom_key);
      VDctxAppTxtAtr(&nodeID,VDCTX_STD_PCMK_ATR_GEOM_KEY,geom_key);
    }
  }
  
 wrapup:
  VDfrmSetgText(s->form,10,"Created Standard Piece Tree");
  return;
}

/* -----------------------------------------------
 * Make a tree of posted geometry keys
 */
static void createDataTree(IGRint contourFlag, TGRid *treeID)
{
  VDASSERT_FN("createDataTree");
  
  IGRint want;
  
  TGRid nodeID;
  TVDrisInfo ris;

  IGRchar *geom_txt;
  IGRchar *geom_key;
  
  // Init
  VDrisInitInfo(&ris);
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;

  // Build the tree
  VDctxCreateXdomTree(VDCTX_NODE_TYPE_SS_OM_PIECES,NULL,treeID);
  
  // Must be logged in
  if (!VDrisIsSchemaOpen()) {
    VDfrmSetgText(s->form,10,"Must be logged into PDM");
    goto wrapup;
  }
  VDfrmSetgText(s->form,10,"Querying database for geom_keys...");

  // Query
  sprintf(ris.sql,"Select status,geom_key from std_geom2;");
  VDrisQuery(&ris,NULL);
  
  // Convert to tree
  for(ris.row = 0; ris.row < ris.rows; ris.row++) {

    ris.col = ris.row * ris.cols;
    VDctxCreateNode(treeID,VDCTX_NODE_TYPE_SS_OM_PLATE,NULL,&nodeID);

    geom_key = ris.buf[ris.col+1];
    stripBlanks(geom_key);
    VDctxAppTxtAtr(&nodeID,VDCTX_STD_PCMK_ATR_GEOM_KEY,geom_key);

    VDctxAppTxtAtr(&nodeID,VDCTX_STD_PCMK_ATR_GEOM_STS,ris.buf[ris.col+0]);

    // Want geometry
    if (contourFlag) {
      VDrisSelectStdGeom2(geom_key,&geom_txt);
      if (*geom_txt) VDctxAppTxtAtr(&nodeID,VDCTX_STD_PCMK_ATR_OUTER_CONTOUR,geom_txt);
      else {
	printf("*** No contour in std_geom2 table for ***\n");
	printf("%s\n",geom_key);
      }
    }
  }
  
 wrapup:
  VDfrmSetgText(s->form,10,"Done querying database for geom_keys");
  
  VDrisFreeInfo(&ris);
}
  
/* -----------------------------------------------
 * Get the actual geom outer contour
 */
static void getPieceGeom(TGRid *a_pieceID, IGRchar **a_geom_txt)
{
  VDASSERT_FN("getPieceGeom");
  
  IGRchar *geom_txt;

  TVDtagInfo tagInfo;
  TGRobj_env pieceOE;
 
  TGRid nodeID;
  
  // Arg check
  VDASSERTW(a_geom_txt); *a_geom_txt = 0;
  VDASSERTW(a_pieceID && a_pieceID->objid != NULL_OBJID);
  
  // Might already have it
  VDctxGetTxtAtrPtr(a_pieceID,VDCTX_STD_PCMK_ATR_OUTER_CONTOUR,&geom_txt);
  if (*geom_txt) {
    *a_geom_txt = geom_txt;
    goto wrapup;
  }
  
  // Make a new node with geometry
  VDctxGetCompTagInfo(a_pieceID,&tagInfo);
  if (tagInfo.id.objid == NULL_OBJID) goto wrapup;
  
  pieceOE.obj_id = tagInfo.id;
  VDobjResetOE(&pieceOE);

  VDvalConvertPieceToDom(&pieceOE,NULL,&nodeID,NULL,VDVAL_DOM_WANT_GEOM);
  VDctxGetTxtAtrPtr(&nodeID,VDCTX_STD_PCMK_ATR_OUTER_CONTOUR,&geom_txt);
  if (geom_txt) {
    VDctxAppTxtAtr   (a_pieceID,VDCTX_STD_PCMK_ATR_OUTER_CONTOUR,  geom_txt);
    VDctxGetTxtAtrPtr(a_pieceID,VDCTX_STD_PCMK_ATR_OUTER_CONTOUR,a_geom_txt);
  }
  VDctxDeleteNode(&nodeID);
  
 wrapup:
  return;
}


/* -----------------------------------------------
 * Bounce against database
 */
static void notifyBounce(IGRint updateFlag)
{
  VDASSERT_FN("notifyBounce");
  
  TGRid pieceTreeID;
  TGRid dataTreeID;
  
  TVDctxNodeList pieceList;
  TVDctxNodeList dataList;

  IGRint i;
  IGRint updatePieceCnt = 0;
  
  TGRid *pieceID;
  TGRid *dataID;

  IGRchar *geom_key;
  IGRchar *geom_txt;
  IGRchab  buf;
  
  IGRint isMaster;
  
  // Init
  pieceTreeID.objid = NULL_OBJID;
  dataTreeID.objid  = NULL_OBJID;
  
  VDctxInitNodeList(&pieceList);
  VDctxInitNodeList(&dataList);

  VDfrmGetState(s->form,VDAT_FORM_STD_LIB_T_MASTER,&isMaster);

  // Create tree of local pieces
  createPieceTree(0,&pieceTreeID);
  VDASSERTW(pieceTreeID.objid != NULL_OBJID);

  // Query from the database
  createDataTree(1,&dataTreeID);
  VDASSERTW(dataTreeID.objid != NULL_OBJID);

  VDctxSaveTreeToXmlFile(&dataTreeID,"dataTree.xml");
  
  // Build lists
  VDctxGetNodeListByType(&pieceTreeID,VDCTX_NODE_TYPE_SS_OM_PLATE,&pieceList);
  VDctxGetNodeListByType(&dataTreeID, VDCTX_NODE_TYPE_SS_OM_PLATE,&dataList);

  if (pieceList.cnt) VDctxSortNodeList(&pieceList,compareGeomKey);
  if (dataList.cnt)  VDctxSortNodeList(&dataList, compareGeomKey);

  // Bounce pieces against data
  VDfrmSetgText(s->form,10,"Checking for pieces not in database...");
  for(i = 0; i < pieceList.cnt; i += getGeomKeyGroupCnt(&pieceList,i)) {
    pieceID = &pieceList.listIDs[i];
    if (dataList.cnt == 0) dataID = NULL;
    else dataID = VDctxSearchNodeList(pieceID,&dataList,compareGeomKey);
    if (dataID == NULL) {

      printf("--- Key not in database ---\n");
      VDctxGetTxtAtrPtr(pieceID,VDCTX_STD_PCMK_ATR_GEOM_KEY,&geom_key);
      printf("%s\n",geom_key);

      updatePieceCnt++;
      
      // Need to update?
      if (updateFlag) {
	
	// Need the geometry
	getPieceGeom(pieceID,&geom_txt);
	if (geom_txt) {
	  VDrisInsertStdGeom2(isMaster,geom_key,geom_txt);
	  printf("Updated database.\n");
	}	
      }      
    }
  }
  if (updatePieceCnt) sprintf(buf,"Number of pieces not in database: %d",updatePieceCnt);
  else strcpy(buf,"All pieces were in the database");
  VDfrmSetgText(s->form,10,buf);
  
 wrapup:
  VDctxFreeNodeList(&pieceList);
  VDctxFreeNodeList(&dataList);

  VDctxDeleteNode(&pieceTreeID);
  VDctxDeleteNode(&dataTreeID);
  
  return;
  
}

/* -----------------------------------------------
 * Empty out the table for testing
 * Because of the size of the data, you cannot just
 * delete everything in one swoop, need to go
 * one record at a time
 */
static void notifyEmptyStdGeom2()
{
  TVDrisInfo ris;
  
  IGRchar buf[256];
  IGRint i;
  
  // Init
  VDrisInitInfo(&ris);
  
  // Must be logged in
  if (!VDrisIsSchemaOpen()) {
    VDfrmSetgText(s->form,10,"Must be logged into PDM");
    goto wrapup;
  }
  VDfrmSetgText(s->form,10,"Querying database for geom_keys...");

  // Query
  sprintf(ris.sql,"Select geom_key from std_geom2;");
  VDrisQuery(&ris,NULL);
  
  sprintf(buf,"Deleting %d rows...",ris.rows);
  VDfrmSetgText(s->form,10,buf);
  
  // Convert to tree
  for(i = 0; i < ris.rows; i++) {
    sprintf(buf,"Delete from std_geom2 where geom_key = '%s';",ris.buf[i]);
    VDrisExecute(buf);
  }
    
 wrapup:
  
  VDrisFreeInfo(&ris);
  
  VDfrmSetgText(s->form,10,"Emptied std_geom2");
  
  return;
}

/* -----------------------------------------------
 * Notification routine
 */
IGRint VDatCmdNotifyStdLib(IGRint    f_label,
			   IGRint    gadget,
			   IGRdouble value,
			   Form      form)
{
  VDASSERT_FN("VDatCmdNotifyStdLib");
  IGRstat retFlag = 0;
  IGRstat sts;

  // Internal data must be set
  VDASSERTW(s);
  VDASSERTW(s->form);
  
  // Process it
  switch(gadget) {

    case FI_CANCEL:

      // Shutdown
      VDfrmDeleteForm(s->form,0);
      s->form = NULL;
      s->loop = 0;

      // Break out of locate loop
      VDputResponse(RESET);
      break;

    case VDAT_FORM_STD_LIB_G_BOUNCE_NO_UPDATE:
      notifyBounce(0);
      break;

    case VDAT_FORM_STD_LIB_G_BOUNCE_UPDATE:
      notifyBounce(1);
      break;

    case VDAT_FORM_STD_LIB_G_EMPTY_STD_GEOM2:
      notifyEmptyStdGeom2();
      break;
      
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the whole thing going
 */
IGRstat VDatCmdInitStdLib(void *testInfo)
{
  VDASSERT_FN("VDatCmdInitStdLib");
  IGRstat retFlag = 1;
  IGRstat sts;

  IGRchar buf[128];
  IGRchar schema[32];

  IGRint isMaster;
  
  // Should not be called recursivily
  VDASSERTW(s == NULL);
  
  // Setup structure
  s = g_new0(Ts_info,1);
  
  // Create the form
  VDfrmNewForm(VDAT_FORM_STD_LIB_NUM,
	       VDAT_FORM_STD_LIB_NAME,
	       VDatCmdNotifyStdLib,1,&s->form);
  VDASSERTW(s->form);
  VDfrmDisplayForm(s->form,1,NULL);

  // Should be logged in
  VDrisGetOpenSchema(schema);
  if (*schema == 0) VDfrmSetgText(s->form,10,"NOT Logged into PDM");
  else {
    sprintf(buf,"Logged into %s",schema);
    VDfrmSetgText(s->form,10,buf);
  }
  
  // Master toggle
  isMaster = VDatIsMasterStdLib();
  if (isMaster) VDfrmSetState(s->form,VDAT_FORM_STD_LIB_T_MASTER,1);
  else          VDfrmSetState(s->form,VDAT_FORM_STD_LIB_T_MASTER,0);

  // Done
  retFlag = 1;
 
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Loop on events
 */
static void VDatCmdLoopStdLib()
{
  VDASSERT_FN("VDatCmdLoopStdLib");
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
 */
void VDatCmdKillStdLib()
{
  VDASSERT_FN("VDatCmdKillStdLib");
  
  // Check if running
  if (s == NULL) goto wrapup;

  // Free the form if necessary
  if (s->form) VDfrmDeleteForm(s->form,1);
  
  // Done
  free(s); s = NULL;
  
 wrapup:
  return;  
}
