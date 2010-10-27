/* $Id: VDvalCmdStdPcmks.c,v 1.6 2002/03/08 16:23:00 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/x3/VDvalStdPcmks.c
 *
 * Description:	Command object for validating standard piece marks
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalCmdStdPcmks.c,v $
 *      Revision 1.6  2002/03/08 16:23:00  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/08/24 20:01:52  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/08/14 19:15:45  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/08/02 15:33:39  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/07/28 17:34:17  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/07/23 16:32:23  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/20/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDtest.h"
#include "VDfrmc.h"
#include "VDgeomc.h"
#include "VDbuf.h"
#include "VDxdom.h"
#include "VDctx.h"
#include "VDval.h"
#include "VDvalLike.h"
#include "VDss.h"
#include "stdarg.h"
#include "glib.h"

VDASSERT_FFN("VDvalStdPcmks.c");

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

#define VDVAL_FORM_STD_PCMKS_NUM  109
#define VDVAL_FORM_STD_PCMKS_NAME "VDvalSP.frm"

#define VDVAL_FORM_STD_PCMKS_G_MODEL_FILE_NAME 12
#define VDVAL_FORM_STD_PCMKS_G_TOLERANCE       13
#define VDVAL_FORM_STD_PCMKS_B_GENERATE_SP     16
#define VDVAL_FORM_STD_PCMKS_B_GENERATE_AP     20
#define VDVAL_FORM_STD_PCMKS_B_LOAD_SP         17
#define VDVAL_FORM_STD_PCMKS_B_LOAD_AP         21
#define VDVAL_FORM_STD_PCMKS_B_VAL_TWO         18
#define VDVAL_FORM_STD_PCMKS_B_VAL_ALL         19

#define VDVAL_FORM_STD_PCMKS_T_REP             22

/* -----------------------------------------------
 * Load the osnum from the form data
 */
static IGRstat getModelOsnum(VDosnum *osnum) 
{
  IGRstat retFlag = 0;
  IGRchar modelFileName[128];

  // Init
  *osnum = OM_K_NOT_AN_OS;

  // Use the model file name
  VDfrmGetgText(s->form,VDVAL_FORM_STD_PCMKS_G_MODEL_FILE_NAME,modelFileName);  
  VDosGetFileNameOS(modelFileName,osnum);
  if (*osnum == OM_K_NOT_AN_OS) goto wrapup;
  
  // Got one
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the tolerance from the form
 */
static IGRstat getTolerance(IGRdouble *tol) 
{
  IGRstat retFlag = 0;
  IGRchar buf[128];
  
  // Init
  *tol = 3.0;

  // From the form
  VDfrmGetgText(s->form,VDVAL_FORM_STD_PCMKS_G_TOLERANCE,buf);  
  *tol = atof(buf);
  
  // Got one
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Generate xml file
 */
static void notifyGenerateSP()
{
  VDosnum osnum;
  TGRid treeID;
  
  // Init
  treeID.objid = NULL_OBJID;

  UI_status("Generating std_pcmks.xml");
  
  // First need osnum to use
  if (getModelOsnum(&osnum) == 0) goto wrapup;
  
  // Generate
  VDvalCreateStdPieceTreeForOS(osnum,&treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  // Save it
  VDctxSaveTreeToXmlFile(&treeID,"std_pcmks.xml");

 wrapup:
  VDctxDeleteNode(&treeID);
  UI_status("Generated std_pcmks.xml");
  return;
}
/* -----------------------------------------------
 * Generate xml file for all pieces
 */
static void notifyGenerateAP()
{
  VDosnum osnum;
  TGRid treeID;
  
  // Init
  treeID.objid = NULL_OBJID;

  UI_status("Generating pieces.xml");
  
  // First need osnum to use
  if (getModelOsnum(&osnum) == 0) goto wrapup;
  
  // Generate
  VDvalCreatePieceTreeForOS(osnum,&treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  // Save it
  VDctxSaveTreeToXmlFile(&treeID,"pieces.xml");

 wrapup:
  VDctxDeleteNode(&treeID);
  UI_status("Generated pieces.xml");
  return;
}

/* -----------------------------------------------
 * Process one plate in the loaded spades tree
 */
static void placeXmlPiece(TGRid *pieceID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("placeXmlPiece");
    
  IGRchab  type;
  
  TGRobj_env macOE;

  TGRsymbology symb1,symb2;
  IGRint symbFlag = 0;
  
  IGRchab symb;
  IGRchar *p;
  
  // Only want pieces
  VDctxGetNodeType(pieceID,type);
  if (strcmp(type,"ss_om_plate") && strcmp(type,"ss_om_beam")) goto wrapup;

  // Symbology
  VDahGetActiveSymbology(&symb1);
  VDahGetActiveSymbology(&symb2);
  VDctxGetTxtAtr(pieceID,"symbology",symb);
  if (*symb) {
  
    p = strchr(symb,':');
    if (p) {
      symb2.level = atoi(symb);
      strcpy(symb,p+1);
    }
    p = strchr(symb,':');
    if (p) {
      symb2.display_attr.color = atoi(symb);
      strcpy(symb,p+1);
    }
    p = strchr(symb,':');
    if (p) {
      symb2.display_attr.weight = atoi(symb);
      strcpy(symb,p+1);
    }
    p = strchr(symb,':');
    if (p) {
      symb2.display_attr.style = atoi(symb);
      strcpy(symb,p+1);
    }
    
    // Set it
    VDahSetActiveSymbology(&symb2);
    symbFlag = 1;
  }
  
  // Place the macro
  VDbufPlaceMacro("VDxml","xml_piece",NULL,NULL,pieceID,&macOE);
  if (macOE.obj_id.objid == NULL_OBJID) {
    VDlogPrintFmt(VDLOG_ERROR,1,"*** Could not place xml_piece macro");
    goto wrapup;
  }
  
 wrapup:
  if (symbFlag) VDahSetActiveSymbology(&symb1);
  return;
}

/* -----------------------------------------------
 * Load xml file then place macros
 */
static void notifyLoadSP()
{
  VDASSERT_FN("notifyLoadSP");
  
  TGRid treeID;
  IGRint stopWalk = 0;
  
  // Load up
  UI_status("Loading std_pcmks.xml");
  VDxdomCreateTreeFromXmlFile("std_pcmks.xml",&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);
  
  // Walk through
  VDctxWalkNode(&treeID,1,placeXmlPiece,NULL,&stopWalk);

 wrapup:
  VDctxDeleteNode(&treeID);
  UI_status("Loaded std_pcmks.xml");
  return;
}
/* -----------------------------------------------
 * Load xml file then place macros
 */
static void notifyLoadAP()
{
  VDASSERT_FN("notifyLoadAP");
  
  TGRid treeID;
  IGRint stopWalk = 0;
  
  // Load up
  UI_status("Loading pieces.xml");
  VDxdomCreateTreeFromXmlFile("pieces.xml",&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);
  
  // Walk through
  VDctxWalkNode(&treeID,1,placeXmlPiece,NULL,&stopWalk);

 wrapup:
  VDctxDeleteNode(&treeID);
  UI_status("Loaded pieces.xml");
  return;
}
  
/* -----------------------------------------------
 * Validate two pieces in each group
 */
static void notifyValTwo()
{
  VDosnum osnum;
  TGRid treeID;
  IGRint errCnt = 0;
  IGRchar buf[128];
  IGRdouble tol = 4.0;
  
  // Init
  treeID.objid = NULL_OBJID;

  UI_status("Validating two pieces in each group...");
  
  // First need osnum to use
  if (getModelOsnum(&osnum) == 0) goto wrapup;
  
  // And the tolerance
  getTolerance(&tol);
  
  // Generate
  VDvalCreateStdPieceTreeForOS(osnum,&treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  // Validate it
  VDvalValidateStdPieces(&treeID,2,tol,&errCnt);
  
 wrapup:
  VDctxDeleteNode(&treeID);
  sprintf(buf,"Validation Error Count %d",errCnt);
  UI_status(buf);
  
  return;
}

/* -----------------------------------------------
 * Validate all pieces in each group
 */
static void notifyValAll()
{
  VDosnum osnum;
  TGRid treeID;
  IGRint errCnt = 0;
  IGRchar buf[128];
  IGRdouble tol = 4.0;
  
  // Init
  treeID.objid = NULL_OBJID;

  UI_status("Validating allpieces in each group...");
  
  // First need osnum to use
  if (getModelOsnum(&osnum) == 0) goto wrapup;
  
  // And the tolerance
  getTolerance(&tol);
  
  // Generate
  VDvalCreateStdPieceTreeForOS(osnum,&treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  // Validate it
  VDvalValidateStdPieces(&treeID,0,tol,&errCnt);
  
 wrapup:
  VDctxDeleteNode(&treeID);
  sprintf(buf,"Validation Error Count %d",errCnt);
  UI_status(buf);
  
  return;
}

/* -----------------------------------------------
 * Notification routine
 */
IGRint VDvalCmdNotifyStdPcmks(IGRint    f_label,
			      IGRint    gadget,
			      IGRdouble value,
			      Form      form)
{
  VDASSERT_FN("VDvalCmdNotifyStdPcmks");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint state,rep;
  
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

    case VDVAL_FORM_STD_PCMKS_B_GENERATE_SP:
      notifyGenerateSP();
      break;

    case VDVAL_FORM_STD_PCMKS_B_GENERATE_AP:
      notifyGenerateAP();
      break;

    case VDVAL_FORM_STD_PCMKS_B_LOAD_SP:
      notifyLoadSP();
      break;

    case VDVAL_FORM_STD_PCMKS_B_LOAD_AP:
      notifyLoadAP();
      break;

    case VDVAL_FORM_STD_PCMKS_B_VAL_TWO:
      notifyValTwo();
      break;

    case VDVAL_FORM_STD_PCMKS_B_VAL_ALL:
      notifyValAll();
      break;

    case VDVAL_FORM_STD_PCMKS_T_REP:
      VDfrmGetState(form,VDVAL_FORM_STD_PCMKS_T_REP,&state);
      if (state == 0) rep = 1;
      else            rep = 2;
      VDvalSetXmlPieceRep(rep);
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
IGRstat VDvalCmdInitStdPcmks(void *testInfo)
{
  VDASSERT_FN("VDvalCmdInitStdPcmks");
  IGRstat retFlag = 1;
  IGRstat sts;
  
  IGRchar unit          [40];
  IGRchar modelFileName[128];

  IGRint rep;
  
  // Should not be called recursivily
  VDASSERTW(s == NULL);
  
  // Setup structure
  s = g_new0(Ts_info,1);

  // Save current file name
#if 0
  VDosGetCurrentOS(&osnum);
  VDosGetFileName(osnum,s->curFileName);
  VDASSERTW(*s->curFileName);
  sprintf(s->calFileName,"%s.ss.cal",s->curFileName);
  sprintf(s->logFileName,"%s.ss.log",s->curFileName);
  sprintf(s->domFileName,"%s.ss.dom",s->curFileName);
  sprintf(s->xmlFileName,"%s.ss.xml",s->curFileName);
#endif
  
  // Create the form
  VDfrmNewForm(VDVAL_FORM_STD_PCMKS_NUM,
	       VDVAL_FORM_STD_PCMKS_NAME,
	       VDvalCmdNotifyStdPcmks,1,&s->form);
  VDASSERTW(s->form);
  VDfrmDisplayForm(s->form,1,NULL);
  
  // Fill in some default data
  VDrrvGetDefaultUnitModel(unit,modelFileName);
  VDfrmSetgText(s->form,VDVAL_FORM_STD_PCMKS_G_MODEL_FILE_NAME,modelFileName);

  VDfrmSetgText(s->form,VDVAL_FORM_STD_PCMKS_G_TOLERANCE,"2.0");
  
  //VDosGetFileNameOS(modelFileName,&modelOS);

  // Rep data
  VDvalGetXmlPieceRep(&rep);
  switch(rep) {
    case 1:
      VDfrmSetState(s->form,VDVAL_FORM_STD_PCMKS_T_REP,0);
      break;
    case 2:
      VDfrmSetState(s->form,VDVAL_FORM_STD_PCMKS_T_REP,1);
      break;
  }

  // Done
  retFlag = 1;
 
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Loop on events
 */
void VDvalCmdLoopStdPcmks()
{
  VDASSERT_FN("VDvalCmdLoopStdPcmks");
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
void VDvalCmdKillStdPcmks()
{
  VDASSERT_FN("VDvalCmdKillStdPcmks");
  
  // Check if running
  if (s == NULL) goto wrapup;

  // Free the form if necessary
  if (s->form) VDfrmDeleteForm(s->form,1);
  
  // Done
  free(s); s = NULL;
  
 wrapup:
  return;  
}
