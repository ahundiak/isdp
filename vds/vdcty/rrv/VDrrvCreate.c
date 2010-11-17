/* $Id: VDrrvCreate.c,v 1.21.2.1 2004/02/12 14:55:55 ahundiak Exp $  */

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
 *      $Log: VDrrvCreate.c,v $
 *      Revision 1.21.2.1  2004/02/12 14:55:55  ahundiak
 *      ah
 *
 *      Revision 1.21  2002/05/10 19:34:04  ahundiak
 *      ah
 *
 *      Revision 1.20  2002/05/01 19:59:24  ahundiak
 *      ah
 *
 *      Revision 1.19  2002/02/28 21:41:34  ahundiak
 *      ah
 *
 *      Revision 1.18  2002/01/08 20:30:29  ahundiak
 *      ah
 *
 *      Revision 1.17  2001/11/16 14:28:11  ahundiak
 *      ah
 *
 *      Revision 1.15  2001/10/19 18:20:55  ahundiak
 *      ah
 *
 *      Revision 1.14  2001/06/03 14:50:52  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.13  2001/03/30 20:32:41  jdsauby
 *      js sp
 *
 *      Revision 1.12  2001/03/29 19:36:48  jdsauby
 *      Incorporation of Purpose Info
 *
 *      Revision 1.11  2001/03/22 18:46:23  ahundiak
 *      ah
 *
 *      Revision 1.10  2001/03/19 22:06:20  jdsauby
 *      Added pdm_info and purp_info attributes to tree, moved post to create form
 *
 *      Revision 1.9  2001/03/16 19:05:36  jdsauby
 *      Modified to suit for Posting, File and Database Operations
 *
 *      Revision 1.8  2001/03/13 00:19:32  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/03/11 18:39:42  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/02/17 14:23:44  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/15/01  ah      Creation
 * 01/08/02  ah      Event button was not working
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDfrmc.h"
#include "VDtest.h"

#include "VDlog.h"
#include "VDctx.h"
#include "VDss.h"
#include "VDpdm.h"
#include "VDvalConv.h"
#include "glib.h"

#include "VDrrvCmd.h"

VDASSERT_FFN("vdcty/rrv/VDrrvCreate.c");

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

  TGRid eventID;
  TGRid cmdID;

  TVDpdmPurposeInfo purpose;
  
} Ts_info;

static Ts_info *s;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;


/* -----------------------------------------------
 * Piece Trace Flag
 */
IGRint VDrrvCmdGetCreateTraceFlag()
{
  IGRint flag;
  if (s == NULL) return 0;
  if (s->form == NULL) return 0;
  
  VDfrmGetState(s->form,VDRRV_FORM_CREATE_T_TRACE,&flag);
  return flag;
}
/* -----------------------------------------------
 * Quick Scan Flag
 */
IGRint VDrrvCmdGetCreateQuickFlag()
{
  IGRchab flag;
  if (s == NULL) return 0;
  if (s->form == NULL) return 0;
  
  VDfrmGetgText(s->form,VDRRV_FORM_CREATE_L_SCAN,flag);

  switch(*flag) {
    case '1': 
	return VDVAL_DOM_WANT_MIN;
	
    case '2':
	return VDVAL_DOM_WANT_MED;
    
    case '3':
	return VDVAL_DOM_WANT_GEOM;
    
    default:
	return 0;
  }
	    
}

/* -----------------------------------------------
 * Little status routine
 */
static void setStatus(IGRint flag, IGRchar *msg)
{
  VDASSERT_FN("setStatus");

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
      VDfrmSetfText(s->form,VDRRV_FORM_CREATE_G_STAT,s->statusRow,0,msg);
      VDfrmShowRow (s->form,VDRRV_FORM_CREATE_G_STAT,s->statusRow);
      s->statusRow++;
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

/* ----------------------------------------------
 * Execute or Accept gadget pushed
 * This will create a doom object from the already created tree
 * **/
static IGRstat notifyDoit()
{
  VDASSERT_FN("notifyDoit");

  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid doomID;
  TGRid treeID;

  VDASSERTW(s);
  VDASSERTW(s->form);

  // make sure the tree has been created
  if (s->treeID.objid == NULL_OBJID) {
      VDfrmSetgText(s->form,10,"Snapshot Must be Created First");
      goto wrapup;
  }

  // Make a doom object out of the tree
  treeID = s->treeID;
  if( s->doomID.objid == NULL_OBJID ) {
      VDdoomCreateFromTree(&treeID,&doomID);
      VDASSERTW(doomID.objid != NULL_OBJID);
      s->doomID = doomID;
  }

  // done
  VDfrmSetgText(s->form,10,"Snapshot Object Saved");
  retFlag = 1;

wrapup:
  return retFlag;
}
  
/* -----------------------------------------------
 * Create button was pushed
 */
static void notifyCreate()
{
  VDASSERT_FN("notifyCreate");

  Form   form;
  IGRint infoCnt;
  TVDrrvPurposeInfo *infos = NULL;

  // Test
  VDASSERTW(s);
  VDASSERTW(s->form); form = s->form;
  
  // Display text area
  VDfrmHideg(s->form,VDRRV_FORM_G_FILE_LIST);
  VDfrmHideg(s->form,VDRRV_FORM_G_FILE_HDR);
  VDfrmShowg(s->form,VDRRV_FORM_CREATE_G_STAT);
  
  // Setup logs
  VDlogOpenCat        (s->logFileName);
  VDlogOpenCatCallback(s->calFileName,setStatus);

  VDlogPrintFmt(VDLOG_INFO,0,"Preparing to create new snapshot");

  // Need a list to process
  VDrrvCmdGetListYesFiles(form,VDRRV_FORM_G_FILE_LIST,&infoCnt,&infos);
  if (infoCnt < 1) {
    VDlogPrintFmt(VDLOG_INFO,0,"No files to process");
    goto wrapup;
  }
  VDrrvCreateSnapshots(&s->purpose,infoCnt,infos,&s->treeID);

 wrapup:

  // Free up
  g_free(infos);
    
  // Close logs
  VDlogCloseCat(s->logFileName);
  VDlogCloseCat(s->calFileName);
  
  return;
}

/* -----------------------------------------------
 * Navigate and event sub system
 */
void VDrrvCmdGetNavEventID(TGRid *objID)
{
  VDASSERT_FN("VDrrvGetNavEventID");
  
  VDASSERTW(objID); objID->objid = NULL_OBJID;
  VDASSERTW(s);
  
  *objID = s->eventID;
  
 wrapup:
  return;
}

/* ----------------------------------------------
 * Get object id from selected row in VDRRV_FORM_CREATE_G_STAT
 */
void VDrrvCmdGetObjectFromMsg(TGRid *objID, IGRint *a_sel)
{
  VDASSERT_FN("VDrrvCmdGetObjectFromMsg");

  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  row, sel, pos;
  IGRchab buf;
  IGRchar *bufp = NULL, *ptr = NULL, *comma = NULL, className[32];
  TGRid   obj;

  // Arg check
  VDASSERTW(objID);objID->objid = NULL_OBJID;
  if (a_sel) *a_sel = 0;  
  VDASSERTW(s);
  VDASSERTW(s->form);
  *className = 0;

  // Check select
  VDfrmGetActiveRow(s->form, VDRRV_FORM_CREATE_G_STAT, &row, &pos);
  VDfrmGetSelect   (s->form, VDRRV_FORM_CREATE_G_STAT,  row, 0, &sel);
  if (a_sel) *a_sel = sel;
  
  // Check string
  VDfrmGetfText(s->form, VDRRV_FORM_CREATE_G_STAT, row, 0, buf);
  if (*buf == 0) goto wrapup;
  bufp = buf;

  obj.objid = NULL_OBJID;
  while( bufp ) {
    comma = strchr( bufp, ',' );
    if( !comma ) goto wrapup;

    bufp = comma + 1;

    for( ptr  = comma - 1; isdigit(*ptr);  ptr-- );
    obj.objid = atoi( (comma+1) );
    obj.osnum = atoi( ++ptr );

    if( obj.objid < 1 || obj.osnum < 1 ) {
	obj.objid = NULL_OBJID;
	continue;
    }
    else {
	VDobjGetClassName(NULL,&obj,className);
	if( strstr(buf, className) ) {
	  break;
	}
    }
  }

  if( objID ) *objID = obj;

wrapup:
  return;
}

/* ----------------------------------------------
 * If the row selected in VDRRV_FORM_CREATE_G_STAT contains object,
 * enable Navigate and Event buttons, ylong
 */
static void notifyObject()
{
  VDASSERT_FN("notifyObject");

  IGRstat retFlag = 0;
  IGRstat sts;
  TGRid   objID;
  IGRint  mode;

  IGRint row,pos,sel;
  
  IGRchar buf[256];
  IGRchar *p;

  IGRchar *ptr;
  IGRchar *comma;
  IGRchar  className[32];
  
  IGRint val;
  
  // Arg check
  VDASSERTW(s);
  VDASSERTW(s->form);

  // Unhilite any previously selected object
  if (s->eventID.objid != NULL_OBJID) {
    GRdisplay_object(&s->eventID,NULL,GRheo);
    s->eventID.objid = NULL_OBJID;
    VIg_disable(s->form,VDRRV_FORM_CREATE_B_OBJ_NAV);
    VIg_disable(s->form,VDRRV_FORM_CREATE_B_OBJ_EVENT);
  }

  // Check select
  VDfrmGetActiveRow(s->form, VDRRV_FORM_CREATE_G_STAT, &row, &pos);
  VDfrmGetSelect   (s->form, VDRRV_FORM_CREATE_G_STAT,  row, 0, &sel);
  if (sel == 0) goto wrapup;
  
  // Check string
  VDfrmGetfText(s->form, VDRRV_FORM_CREATE_G_STAT, row, 0, buf);
  if (*buf == 0) goto wrapup;

  // Parse out
  while(1) {

    // osnum,objid
    comma = strchr(buf,',');
    if (comma == NULL) goto wrapup;

    // Osnum
    for(p = comma - 1; (p >= buf) && isdigit(*p);p--);
    val = atoi(p+1);
    if (val <= 0) objID.osnum = NULL_OSNUM;
    else          objID.osnum = val;
    
    // Objid
    val = atoi(comma+1);
    if (val <= 0) objID.objid = NULL_OBJID;
    else          objID.objid = val;

    // Test
    if ((objID.objid != NULL_OBJID) && (objID.osnum != NULL_OSNUM)) {
      VDobjGetClassName(NULL,&objID,className);
      if (strstr(buf,className)) goto got_it;
    }
    for(p = comma + 1; isdigit(*p); p++);
    strcpy(buf,p);
    
  }

 got_it:
  if (objID.objid == NULL_OBJID) goto wrapup;
  s->eventID = objID;

  VIg_enable(s->form,VDRRV_FORM_CREATE_B_OBJ_NAV);
  VIg_enable(s->form,VDRRV_FORM_CREATE_B_OBJ_EVENT);
    
  GRdisplay_object(&objID,NULL,GRhdo);

wrapup:
  return;
}

/* -----------------------------------------------
 * Notification routine
 */
IGRint VDrrvCmdNotifyCreate(IGRint    f_label,
			    IGRint    gadget,
			    IGRdouble value,
			    Form      form)
{
  VDASSERT_FN("VDrrvCmdNotifyCreate");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint pplRet;
  
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
      if (s->treeID.objid != NULL_OBJID) VDctxDeleteNode(&s->treeID);

      // Break out of locate loop
      VDputResponse(RESET);
      break;

    case FI_EXECUTE:
      sts = notifyDoit();  
      break;

    case FI_ACCEPT:
      sts = notifyDoit();
      if (sts) {
	  // Shutdown
	  VDfrmDeleteForm(s->form,0);
	  s->form = NULL;
	  s->loop = 0;
	  if (s->treeID.objid != NULL_OBJID) VDctxDeleteNode(&s->treeID);
	  // Break out of locate loop
	  VDputResponse(RESET);
      }
      break;

    case VDRRV_FORM_CREATE_G_STAT:
      notifyObject();
      break;
      
    case VDRRV_FORM_CREATE_B_CREATE:
      notifyCreate();
      break;

    case VDRRV_FORM_CREATE_B_RVW_LOG:
      if( s->treeID.objid != NULL_OBJID ) VDlogShowCat(s->logFileName);
      break;

    case VDRRV_FORM_CREATE_B_RVW_XML:
      if (s->treeID.objid != NULL_OBJID) {
	  // save tree to XML file
	  VDctxSaveTreeToXmlFile(&s->treeID,s->xmlFileName);
	  VDlogShowCat(s->xmlFileName);
      }
      break;

    case VDRRV_FORM_G_FILE_LIST:
      VDrrvCmdNotifyFileList(s->form,VDRRV_FORM_G_FILE_LIST);
      break;

  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Set the defualt data on the form
 * **/
static void setDefaultFormData(TVDpdmPurposeInfo *info,
	                       IGRchar           *model)
{
  VDASSERT_FN("setDefaultFormData");
  IGRstat sts;

  VDASSERTW(s->form);
  
  // set the text on the form
  VDfrmSetgText(s->form,VDRRV_FORM_CREATE_G_UNIT,   info->unit);
  VDfrmSetgText(s->form,VDRRV_FORM_CREATE_G_ZONE,   info->zone);
  VDfrmSetgText(s->form,VDRRV_FORM_CREATE_G_PURPOSE,info->purpose);
  VDfrmSetgText(s->form,VDRRV_FORM_CREATE_G_SYSTEM, info->system);
  VDfrmSetgText(s->form,VDRRV_FORM_CREATE_G_FILE,   model);

  // Disable a couple of gadgets
  VIg_disable(s->form,VDRRV_FORM_CREATE_B_OBJ_NAV);
  VIg_disable(s->form,VDRRV_FORM_CREATE_B_OBJ_EVENT);

  // done
wrapup:
  return;
}

/* -----------------------------------------------
 * Need this to hook to the ppl
 */
extern IGRint ci_notification(IGRint    f_label,
			      IGRint    gadget,
			      IGRdouble value,
			      Form      form);

/* -----------------------------------------------
 * Get the whole thing going
 */
IGRstat VDrrvCmdInitCreateSnapshot(TVDtestTestInfo *testInfo, VDobjid cmdObjid, VDosnum cmdOsnum)
{
  VDASSERT_FN("VDrrvCmdCreateSnapshot");
  IGRstat retFlag = 1;
  IGRstat sts;
  
  IGRchar unit  [40];
  IGRchar model[128];

  VDosnum osnum;
  
  // Should not be called recursivily
  VDASSERTW(s == NULL);
  
  // Setup structure
  s = calloc(1,sizeof(Ts_info));
  VDASSERTW(s);
  s->doomID.objid  = NULL_OBJID;
  s->treeID.objid  = NULL_OBJID;
  s->eventID.objid = NULL_OBJID;
  
  s->cmdID.objid = cmdObjid;
  s->cmdID.osnum = cmdOsnum;
  
  // Save current file name
  VDosGetCurrentOS(&osnum);
  VDosGetFileName(osnum,s->curFileName);
  VDASSERTW(*s->curFileName);
  sprintf(s->calFileName,"%s.ss.cal",s->curFileName);
  sprintf(s->logFileName,"%s.ss.log",s->curFileName);
  sprintf(s->domFileName,"%s.ss.dom",s->curFileName);
  sprintf(s->xmlFileName,"%s.ss.xml",s->curFileName);

  // Auto set some purposes
  VDrrvAutoSetPurposeInfo();

  // Set the current purpose info
  VDpdmGetPurposeInfo(osnum,&s->purpose);

  // Give the user a chance
  if (*s->purpose.purpose == 0) {
    VDpdmCmdSetPurposeInfo(osnum,&s->purpose);
  }
  
  // Must have a purpose
  if (*s->purpose.purpose == 0) {

    // Lock em out
    sts = VDfrmNewForm(VDRRV_FORM_CREATE_NUM,
		       VDRRV_FORM_CREATE_NAMEX,
		       VDrrvCmdNotifyCreate,1,&s->form);
    VDASSERTW(sts);
    VDASSERTW(s->form);

    VDfrmDisplayForm(s->form,1,NULL);

    retFlag = 1;
    goto wrapup;
  }

 

  // Link to ppl if have one
  if (s->cmdID.objid != NULL_OBJID) {

    sts = VDfrmCreateForm(VDRRV_FORM_CREATE_NUM,
			  VDRRV_FORM_CREATE_NAME,
			  ci_notification,
			  s->cmdID.objid,
			  s->cmdID.osnum,
			  &s->form,1);

  }
  else {
	
    sts = VDfrmNewForm(VDRRV_FORM_CREATE_NUM,
		       VDRRV_FORM_CREATE_NAME,
		       VDrrvCmdNotifyCreate,1,&s->form);
  }  
  VDASSERTW(sts);
  VDASSERTW(s->form);
    
  VDfrmDisplayForm(s->form,1,NULL);

  // Fill in default info
  *model = 0;
  setDefaultFormData(&s->purpose,model);

  // Set up gadgets
  VDfrmHideg(s->form,VDRRV_FORM_CREATE_G_STAT);
  VDfrmShowg(s->form,VDRRV_FORM_G_FILE_LIST);
  VDfrmShowg(s->form,VDRRV_FORM_G_FILE_HDR);
  VDrrvCmdFillFileList(s->form,VDRRV_FORM_G_FILE_LIST,1);

  // Done
  retFlag = 1;
 
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Loop on events
 */
void VDrrvCmdLoopCreateSnapshot()
{
  VDASSERT_FN("VDrrvCmdLoopCreateSnapshot");
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
void VDrrvCmdKillCreateSnapshot()
{
  VDASSERT_FN("VDrrvCmdKillCreateSnapshot");
  
  // Check if running
  if (s == NULL) goto wrapup;

  // Free the form if necessary
  if (s->form) VDfrmDeleteForm(s->form,1);
  
  // Done
  free(s); s = NULL;
  
 wrapup:
  return;  
}

/* -----------------------------------------------
 * Automated testing
 */
void VDtestCreateSnapshot(TVDtestTestInfo *testInfo)
{
  VDASSERT_FN("VDtestCreateSnapshot");
  IGRstat sts;
  
  // Arg check
  VDASSERTW(testInfo);
  
  // Assume it worked
  testInfo->worked = 1;

  // Get started
  sts = VDrrvCmdInitCreateSnapshot(testInfo,NULL_OBJID,NULL_OSNUM);
  VDASSERTW(sts & 1);
  
  // The actual test
  VDrrvCmdNotifyCreate(0,VDRRV_FORM_CREATE_B_CREATE,0.0,NULL);

  // Save any tree 
  if (s->treeID.objid != NULL_OBJID) {
    VDctxSaveTreeToXmlFile(&s->treeID,s->xmlFileName);
  }

  // See if it worked
  //sts = testResults();
  sts = 1;
  if (sts == 1) testInfo->worked = 1;
  else          testInfo->worked = 0;
  
  // Finish up
  if (testInfo->stopWhenDone) {
    VDrrvCmdKillCreateSnapshot();
  }
  else {
    //VDrrvCmdNotifyCreate(0,VDRRV_FORM_CREATE_B_TREE,0.0,NULL);    
    VDrrvCmdLoopCreateSnapshot();
    VDrrvCmdKillCreateSnapshot();
  }
  
 wrapup:
  return;
}
