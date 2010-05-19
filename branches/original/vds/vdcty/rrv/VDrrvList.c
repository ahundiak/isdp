/* $Id: VDrrvList.c,v 1.3 2002/06/12 18:28:54 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvList.c
 *
 * Description: List files
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvList.c,v $
 *      Revision 1.3  2002/06/12 18:28:54  ahundiak
 *      ah
 *
 *      Revision 1.2  2002/05/10 19:34:04  ahundiak
 *      ah
 *
 *      Revision 1.1  2002/02/28 21:41:34  ahundiak
 *      ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/28/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDfrmc.h"
#include "VDtest.h"
#include "VDctx.h"
#include "VDdoom.h"
#include "VDss.h"
#include "VDat.h"
#include "glib.h"
#include "VDrrvCmd.h"

VDASSERT_FFN("vdcty/rrv/VDrrvList.c");

typedef struct
{ 
  Form   form;
  IGRint loop;
} Ts_info;

static Ts_info *s;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;

#define VDRRV_FORM_G_FILE_SHOW  14
#define VDRRV_FORM_G_FILE_LIST2 12

/* -----------------------------------------------
 * Parse out one row in the foem
 */
void VDrrvCmdGetInfoFromFileListRow(Form form, IGRint gadget, IGRint row,
				    TVDrrvPurposeInfo *info)
{
  VDASSERT_FN("VDrrvCmdGetInfoFromFileListRow");
  
  IGRchab buf;
  
  // Arg check
  VDASSERTW(info); memset(info,0,sizeof(TVDrrvPurposeInfo));
  VDASSERTW(form);
  
  // Purpose stuff
  VDfrmGetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_PURPOSE,info->purpose);
  VDfrmGetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_UNIT,   info->unit);
  VDfrmGetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_ZONE,   info->zone);
  VDfrmGetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_SYSTEM, info->system);

  // Os number
  VDfrmGetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_OS,buf);
  info->osnum = atoi(buf);

  // File Name
  VDfrmGetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_NAME,info->fileName);

  // Use flag
  VDfrmGetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_USE,buf);
  if (!strcmp(buf,"YES")) info->useFlag = 1;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get a list of YES files to process
 */
void VDrrvCmdGetListYesFiles(Form form, IGRint gadget, IGRint *a_cnt, TVDrrvPurposeInfo **a_infos)
{
  VDASSERT_FN("VDrrvCmdGetListYesFiles");
  
  IGRint row,rows;
  TVDrrvPurposeInfo info;
  TVDrrvPurposeInfo *infos = NULL;
  
  IGRint  cnt;
  IGRchab buf;
  
  // Arg check
  VDASSERTW(a_infos); *a_infos = NULL;
  VDASSERTW(a_cnt);   *a_cnt = 0;
  VDASSERTW(form);

  // Cycle once to count
  cnt = 0;
  VDfrmGetNumRows(form,gadget,&rows,NULL,NULL);
  for(row = 0; row < rows; row++) {
    VDfrmGetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_USE,buf);
    if (!strcmp(buf,"YES")) cnt++;
  }
  if (cnt < 1) goto wrapup;
  
  // Alloc and grab
  infos = g_new(TVDrrvPurposeInfo,cnt);
  cnt = 0;
  for(row = 0; row < rows; row++) {
    VDfrmGetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_USE,buf);
    if (!strcmp(buf,"YES")) {
      VDrrvCmdGetInfoFromFileListRow(form,gadget,row,&infos[cnt]);
      cnt++;
    }
  }
  
  // Return
  *a_cnt   = cnt;
  *a_infos = infos;
  
 wrapup:
  return;
}


/* -----------------------------------------------
 * The logic to determine which files to include
 * in a snapshot
 */
void VDrrvCmdDefaultFileList(Form form, IGRint gadget)
{
  VDASSERT_FN("VDrrvCmdDefaultFileListRow");
  
  IGRint row,rows;

  TVDrrvPurposeInfo curInfo,info;
  
  TGRid   setID;
  
  // Arg check
  VDASSERTW(form);
  
  // Make sure got some rows
  VDfrmGetNumRows(form,gadget,&rows,NULL,NULL);
  if (rows < 1) goto wrapup;

  // First row is the current one
  VDrrvCmdGetInfoFromFileListRow(form,gadget,0,&curInfo);
  
  // Always select the first row
  VDfrmSetfText(form,gadget,0,VDRRV_FORM_G_FILE_LIST_USE,"YES");

  // if have a unit then select all other unit files
  if (*curInfo.unit) {

    VDatGetSetByTypeName("StagingTree",curInfo.unit,&setID);
    
    for(row = 1; row < rows; row++) {
      VDrrvCmdGetInfoFromFileListRow(form,gadget,row,&info);
      if (!strcmp(curInfo.unit,info.unit)) {
	VDfrmSetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_USE,"YES");
      }
      else {
	if (setID.objid != NULL_OBJID) {
	  if (VDrrvIsSetLinkedToOS(&setID,info.osnum)) {
	    VDfrmSetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_USE,"YES");
	  }
	}	
      }
    }
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Fill in a file list row
 */
void VDrrvCmdFillFileListRow(Form form, IGRint gadget, IGRint *a_row, VDosnum osnum, IGRint showFlag)
{
  VDASSERT_FN("VDrrvCmdFillFileListRow");
  
  IGRint row;
  IGRchab fileName;
  IGRchab buf;
  
  TVDpdmPurposeInfo purpose;
  
  // Arg check
  VDASSERTW(form);
  VDASSERTW(a_row); row = *a_row;
  
  // Get the name
  VDosGetFileName(osnum,fileName);
  if (*fileName == 0) goto wrapup;
  
  // Only want names starting with a number
  // if ((*fileName < '0') || (*fileName > '9')) goto wrapup;

  // Reject all the 6000 seris
  // if (*fileName == '6') goto wrapup;

  // Get the purpose
  VDpdmGetPurposeInfo(osnum,&purpose);
  if (showFlag == 1) {
    if (!strcmp(purpose.purpose,"planes" ))   goto wrapup;
    if (!strcmp(purpose.purpose,"volumes"))   goto wrapup;
    if (!strcmp(purpose.purpose,"unit_surf")) goto wrapup;
  }
  
  // Fill it in
  sprintf(buf,"%2d",osnum);
  VDfrmSetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_OS,buf);
  VDfrmSetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_NAME,fileName);

  // Purpose stuff
  VDfrmSetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_PURPOSE,purpose.purpose);
  VDfrmSetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_UNIT,   purpose.unit);
  VDfrmSetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_ZONE,   purpose.zone);
  VDfrmSetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_SYSTEM, purpose.system);
  
  // Done
  *a_row = *a_row + 1;

 wrapup:
  return;
}

/* -----------------------------------------------
 * Fill in a file list
 */
void VDrrvCmdFillFileList(Form form, IGRint gadget, IGRint showFlag)
{
  VDASSERT_FN("VDrrvCmdFillFileList");

  IGRint i,cnt;
  VDosnum *osnums = NULL;
  
  IGRint row = 0;
  
  // Arg
  VDASSERTW(form);
  
  // Reset the list
  VDfrmSetNumRows(form,gadget,0);
  
  // Cycle through the ref osnums
  VDrefGetOSs(&cnt,&osnums);
  for(i = 0; i < cnt; i++) {
    VDrrvCmdFillFileListRow(form,gadget,&row,osnums[i],showFlag);
  }

  // Just run the marker from here for now
  VDrrvCmdDefaultFileList(form,gadget);
  
 wrapup:
  g_free(osnums);
  return;
}

/* ---------------------------------------------
 * Toggle the user value
 */
void VDrrvCmdNotifyFileList(Form form, IGRint gadget)
{
  VDASSERT_FN("VDrrvCmdNotifyFileList");
  
  IGRchar buf[32];
  IGRint row;
  
  // Arg check
  VDASSERTW(form);
  
  // Selected row
  VDfrmGetActiveRow(form,gadget,&row,NULL);
  if (row < 0) goto wrapup;
  
  // Toggle
  VDfrmGetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_USE,buf);
  if (!strcmp(buf,"YES")) VDfrmSetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_USE,"NO");
  else                    VDfrmSetfText(form,gadget,row,VDRRV_FORM_G_FILE_LIST_USE,"YES");

  // Clear Select
  // VDfrmSetSelect(form,gadget,row,VDRRV_FORM_G_FILE_LIST_USE,1);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Notification routine
 */
static IGRint notify(IGRint    f_label,
		     IGRint    gadget,
		     IGRdouble value,
		     Form      form)
{
  VDASSERT_FN("notify");
  IGRstat retFlag = 0;

  IGRint showFlag;
  
  // Internal data must be set
  VDASSERTW(s);
  VDASSERTW(s->form);

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

    case VDRRV_FORM_G_FILE_SHOW:
      VDfrmGetState(form,VDRRV_FORM_G_FILE_SHOW,&showFlag);
      VDrrvCmdFillFileList(s->form,VDRRV_FORM_G_FILE_LIST2,showFlag);
      break;

    case VDRRV_FORM_G_FILE_LIST2:
      VDrrvCmdNotifyFileList(s->form,VDRRV_FORM_G_FILE_LIST2);
      break;
      
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the whole thing going
 *
 */
IGRstat VDrrvCmdInitListSnapshot(TVDtestTestInfo *testInfo)
{
  VDASSERT_FN("VDrrvCmdListSnapshot");
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
  
  // Create the form
  sts = VDfrmNewForm(VDRRV_FORM_LIST_NUM,
		     VDRRV_FORM_LIST_NAME,
		     notify,1,&s->form);
  VDASSERTW(sts);
  VDASSERTW(s->form);

  // Display it
  VDfrmDisplayForm(s->form,1,NULL);

  // Fill it
  VDrrvCmdFillFileList(s->form,VDRRV_FORM_G_FILE_LIST2,0);
  
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
void VDrrvCmdLoopListSnapshot()
{
  VDASSERT_FN("VDrrvCmdLoopListSnapshot");
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
void VDrrvCmdKillListSnapshot()
{
  VDASSERT_FN("VDrrvCmdKillListSnapshot");
  
  // Check if running
  if (s == NULL) goto wrapup;

  // Free the form if necessary
  if (s->form) VDfrmDeleteForm(s->form,1);

  // Done
  free(s); s = NULL;
  
 wrapup:
  return;  
}
