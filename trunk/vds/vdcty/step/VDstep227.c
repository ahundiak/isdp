/* $Id: VDstep227.c,v 1.1.2.1 2004/11/29 16:27:16 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/step/VDstep227.C
 *
 * Description: Export AP227 Command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDstep227.c,v $
 *      Revision 1.1.2.1  2004/11/29 16:27:16  ahundiak
 *      ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/29/04  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDfrmc.h"
#include "VDtest.h"

#include "VDlog.h"
#include "VDctx.h"
#include "VDobj2.h"
#include "VDss.h"
#include "VDpdm.h"
#include "VDvalConv.h"
#include "glib.h"

#include "VDstepCmd.h"

VDASSERT_FFN("vdcty/step/VDstep227.c");

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
      VDfrmSetfText(s->form,VDSTEP_FORM_EXPORT227_G_STATUS,s->statusRow,0,msg);
      VDfrmShowRow (s->form,VDSTEP_FORM_EXPORT227_G_STATUS,s->statusRow);
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

#if 0
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
#endif 

/* ----------------------------------------------
 * Process an object 
 */
static void processObject(TGRobj_env *objOE)
{
    char className[32];
    char compCode [32];
    char compName [32];
    char cpc      [32];

    VDobjGetClassName(objOE,NULL,className);

    VDobjGetTxtAtr(objOE,NULL,"comp_code",     compCode);
    VDobjGetTxtAtr(objOE,NULL,"component_name",compName);
    VDobjGetTxtAtr(objOE,NULL,"cpc_part_num",  cpc);

    if (!strcmp(compCode,"dangle")) return;
    if (!strcmp(compCode,"TAP"))    return;

    if (*compName == 0) return;

    VDlogPrintFmt(VDLOG_INFO,0,"ITEM %s %s %s %s",className,compCode,compName,cpc);
 
    return;
}
/* ----------------------------------------------
 * Export one or more objects
 */
void VDstepCmdObjectExport227(TGRobj_env *locatedOE)
{
    IGRint sts;
    IGRint i;

    TGRobj_env *locOEs;
    TGRobj_env  locOE;
    IGRint      locNum;
 
    // Selection set?
    sts = VDobjIsAncestryValid(locatedOE,NULL,0,"GRgrset");
    if (!(sts & 1)) {
      processObject(locatedOE);
    }
    else {
      VDstart_var_fence(locatedOE,&locNum,&locOEs);
      for(i = 0; i < locNum; i++) {
        locOE = locOEs[i];
        processObject(&locOE);
      }
      ASend_fence(); 

    }
}

/* -----------------------------------------------
 * Notification routine
 */
IGRint VDstepCmdNotifyExport227(IGRint    f_label,
			        IGRint    gadget,
			        IGRdouble value,
			        Form      form)
{
  VDASSERT_FN("VDstepCmdNotifyExport227");
  IGRstat retFlag = 0;
  IGRstat sts = 0;
  IGRchar cmd[256];

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
      //sts = notifyDoit();  
      break;

    case FI_ACCEPT:
      //sts = notifyDoit();
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

      case VDSTEP_FORM_EXPORT227_B_SELECT:
        sprintf(cmd,"/bin/cp data/%s %s",s->xmlFileName,s->xmlFileName);
        system (cmd);
        sprintf(cmd,"/usr/local/bin/gvim %s",s->xmlFileName);
        system (cmd);
      break;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
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
IGRstat VDstepCmdInitExport227(TVDtestTestInfo *testInfo, VDobjid cmdObjid, VDosnum cmdOsnum)
{
  VDASSERT_FN("VDstepCmdInitExport227");
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
  sprintf(s->calFileName,"%s.cal",s->curFileName);
  sprintf(s->logFileName,"%s.log",s->curFileName);
  sprintf(s->domFileName,"%s.ss", s->curFileName);
  sprintf(s->xmlFileName,"%s.xml",s->curFileName);

  // Setup logs
  VDlogOpenCat        (s->logFileName);
  VDlogOpenCatCallback(s->calFileName,setStatus);

  
  // Link to ppl if have one
  if (s->cmdID.objid != NULL_OBJID) {

    sts = VDfrmCreateForm(VDSTEP_FORM_EXPORT227_NUM,
			  VDSTEP_FORM_EXPORT227_NAME,
			  ci_notification,
			  s->cmdID.objid,
			  s->cmdID.osnum,
			  &s->form,1);

  }
  else {
	
    sts = VDfrmNewForm(VDSTEP_FORM_EXPORT227_NUM,
		       VDSTEP_FORM_EXPORT227_NAME,
		       VDstepCmdNotifyExport227,1,&s->form);
  }  
  VDASSERTW(sts);
  VDASSERTW(s->form);
   
  VDfrmSetgText(s->form,VDSTEP_FORM_EXPORT227_G_FILENAME,s->curFileName); 
  VDfrmDisplayForm(s->form,1,NULL);

  // Done
  retFlag = 1;
 
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Loop on events
 */
void VDstepCmdLoopExport227()
{
  VDASSERT_FN("VDstepCmdLoopExport227");
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
void VDstepCmdKillExport227()
{
  VDASSERT_FN("VDstepCmdKillExport227");
  
  // Check if running
  if (s == NULL) goto wrapup;

  // Close logs
  VDlogCloseCat(s->logFileName);
  VDlogCloseCat(s->calFileName);
 
  // Free the form if necessary
  if (s->form) VDfrmDeleteForm(s->form,1);
  
  // Done
  free(s); s = NULL;
  
 wrapup:
  return;  
}

