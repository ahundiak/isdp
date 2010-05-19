/* $Id: VDatCmd.c,v 1.7 2001/11/09 14:38:06 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatCmd.C
 *
 * Description: Piece Mark Form Ver 2
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatCmd.c,v $
 *      Revision 1.7  2001/11/09 14:38:06  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/10/19 18:22:33  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/04/12 19:12:26  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/04/03 16:51:04  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/22 14:41:47  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/18 22:50:17  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/16 17:10:45  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/14/01  ah      creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDfrmc.h"

#include "VDctx.h"
#include "VDss.h"
#include "VDat.h"
#include "VDat2Pcmk.h"
#include "VDat2Cmd.h"

VDASSERT_FFN("vdat/pcmk2/VDatCmd.c");

/* ----------------------------------------------------
 * Note: Must keep this in sync with structure
 * defined in COatMgr.u
 *
 * Note: changed the rep name to pcmk2
 */
typedef struct {
  Form form,mgr,set,leaf,tree,stage,pcmk2,attr,pcmk,rpt;
  int gadget;
  int reset;
  VDclassid      classIDs[16];
  OM_S_CLASSLIST classList;
  
} TVDatFrmList;

#define VDAT_FORM_PCMK_B_UNHILITE_ALL  12
#define VDAT_FORM_PCMK_B_UNSELECT_ALL  13
#define VDAT_FORM_PCMK_B_HILITE_SELECT 14

#define VDAT_FORM_PCMK_B_PROCESS       16
#define VDAT_FORM_PCMK_B_GENERATE      16
#define VDAT_FORM_PCMK_B_VERIFY        22
#define VDAT_FORM_PCMK_B_VALIDATE      21
#define VDAT_FORM_PCMK_B_CLEAR         20

#define VDAT_FORM_PCMK_G_PIECES        24
#define VDAT_FORM_PCMK_G_PIECES_NAME    0
#define VDAT_FORM_PCMK_G_PIECES_PCMK    1
#define VDAT_FORM_PCMK_G_PIECES_ID      2
#define VDAT_FORM_PCMK_G_PIECES_COL_BEG 0
#define VDAT_FORM_PCMK_G_PIECES_COL_END 2

#define VDAT_FORM_PCMK_G_NEXT_PCMK 17

#define VDAT_FORM_PCMK_G_SET_NAME 51

#define VDAT_FORM_PCMK_T_STD_VER 19

static TGRid  s_ssID;
static TGRid  s_setID;
static TGRid  s_domTreeID;
static IGRint s_save_ss;
static IGRint s_nextPcmk;

IGRstat VDatCMDPcmk2NotifyForm  (TVDatFrmList *fl);
IGRstat VDatCMDPcmk2ActivateForm(TVDatFrmList *fl);
IGRstat VDatCMDPcmk2ActivateSet (TVDatFrmList *fl);

/* -----------------------------------------------------------
 * Expose the nextPcmk to whomever wants it
 */
void VDatCMDPcmkGetNextPcmk(IGRint *pcmk)
{
  *pcmk = s_nextPcmk;
  return;
}

/* -----------------------------------------------------------
 * Want the object to hilite when user pokes list
 */
static void notifyList(TVDatFrmList *fl, IGRint gadget)
{
  Form form = fl->pcmk2;

  TGRid   leafID;
  IGRint  row,pos;
  IGRint  sel;
  enum GRdpmode mode;

  // Get the row
  row = -1;
  VIfld_get_active_row(form,gadget,&row,&pos);
  if (row < 0) goto wrapup;
  
  VDahFrmGetGRid(form,gadget,row,2,&leafID);
  if (leafID.objid == NULL_OBJID) goto wrapup;
  
  // Hilite or not
  sel = -1;
  VIfld_get_select(form,gadget,row,0,&sel);
  if (sel == 1) mode = GRhd;
  else          mode = GRhe;

  VDctxDisplayNode(&leafID,mode,0);
  
wrapup:
  return;
}

/* ---------------------------------------------------
 * Unselect all leafs
 */
static void notifyUnSelectAll(TVDatFrmList *fl)
{
  Form form = fl->pcmk2;

  VDatFormUnSelectGadget(form,
			 VDAT_FORM_PCMK_G_PIECES,
			 VDAT_FORM_PCMK_G_PIECES_COL_BEG,
			 VDAT_FORM_PCMK_G_PIECES_COL_END);

  return;
}

/* ---------------------------------------------------
 * Unhilite all leafs
 */
static void notifyUnHiLiteAll(TVDatFrmList *fl)
{
  VDatFormUnHiLiteAll();
  return;
}

static void notifyHiLiteSelect(TVDatFrmList *fl)
{
  Form  form = fl->pcmk2;

  VDatFormUnHiLiteAll();
  VDatFormHiLiteGadget(form,
		       VDAT_FORM_PCMK_G_PIECES,
		       VDAT_FORM_PCMK_G_PIECES_COL_BEG,
		       VDAT_FORM_PCMK_G_PIECES_COL_END);

  return;
}

/* ----------------------------------------
 * Initializes the form with a new active set
 */
IGRstat VDatCMDPcmk2ActivateSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  Form    form = fl->pcmk2;

  TGRid   setID;
  IGRchar setName[128];

  IGRint errCnt;
  
  IGRchar buf[128];
  
  // Ignore if the form is not active
  sts = VDatFormIsActive(form);
  if (sts != 1) goto wrapup;

  // Reset the active dom tree
  if (s_domTreeID.objid != NULL_OBJID) VDctxDeleteNode(&s_domTreeID);
  s_domTreeID.objid = NULL_OBJID;
  if (s_ssID.objid != NULL_OBJID) VDctxDeleteNode(&s_ssID);
  s_ssID.objid = NULL_OBJID;
  s_nextPcmk = 0;
  
  // get the active set, if none just clear gadgets
  *setName = 0;
  VDatCMDAllGetActiveSet(fl,&setID,setName);
  s_setID = setID;
  s_save_ss = 0;
  
  // Update form
  VIg_set_text(form,VDAT_FORM_PCMK_G_SET_NAME,setName);

  // Create the piece mark tree
  // Maybe should turn on logging???
  if (setID.objid != NULL_OBJID) {

    // Turn on logging
    VDat2SetCmdStatusForm(form);
    VDlogOpenCat        ("pcmk_tree.log");
    VDlogOpenCatCallback("pcmk_tree.cal",VDat2SetCmdStatus);

    // Grab the next piece mark from the ris table
    VDat2RisGetNextPcmk(setName,&s_nextPcmk);
    
    // Do it
    VDat2CreatePcmkTree(&setID,&s_domTreeID,&s_ssID,&errCnt);
    sprintf(buf,"Piece Mark Error Count %d",errCnt);
    VDfrmSetStatus(form,10,buf);
    VDat2FormFillPcmkList(form,
			  VDAT_FORM_PCMK_G_PIECES,
			  VDAT_FORM_PCMK_G_NEXT_PCMK,
			  VDAT_FORM_PCMK_B_PROCESS,
			  &s_domTreeID,
			  &s_ssID,
			   s_nextPcmk);

    // Turn off logging
    VDlogCloseCat("pcmk_tree.log");
    VDlogCloseCat("pcmk_tree.cal");
    VDat2SetCmdStatusForm(NULL);
  }
  
  // Done
  retFlag = 1;
wrapup:

  return retFlag;
}

/* -------------------------------------------
 * The notification routine
 */
IGRstat VDatCMDPcmk2NotifyForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 1;
  Form    form;
  IGRint  gadget;

  IGRchab buf;
  IGRint  next;
  IGRint  ver;
  
  // Form has all global data
  form   = fl->form;
  gadget = fl->gadget;
  
  switch(gadget) {

    case VDAT_FORM_PCMK_G_PIECES:
      notifyList(fl,gadget);
      break;

    case VDAT_FORM_PCMK_B_PROCESS:

      VDfrmGetgText(form,VDAT_FORM_PCMK_G_NEXT_PCMK,buf);
      next = atoi(buf);
      
      VDfrmGetgText(form,VDAT_FORM_PCMK_B_PROCESS,buf);
      if (*buf == 'G') {
	VDat2FormNotifyGenerate(form,next,&s_domTreeID);
	VDat2FormFillPcmkList(form,
			      VDAT_FORM_PCMK_G_PIECES,
			      VDAT_FORM_PCMK_G_NEXT_PCMK,
			      VDAT_FORM_PCMK_B_PROCESS,
			      &s_domTreeID,
			      &s_ssID,
			       s_nextPcmk);
      }
      else {
	VDat2FormNotifyVerify(form,next,&s_domTreeID,&s_ssID);
	VDat2FormFillPcmkList(form,
			      VDAT_FORM_PCMK_G_PIECES,
			      VDAT_FORM_PCMK_G_NEXT_PCMK,
			      VDAT_FORM_PCMK_B_PROCESS,
			      &s_domTreeID,
			      &s_ssID,
			       s_nextPcmk);
	VDat2ReportChangedPcmks(&s_setID,&s_domTreeID,&s_ssID);
      }

      // Save a snapshot if the marks are accepted
      s_save_ss = 1;
      
      break;

    case VDAT_FORM_PCMK_B_CLEAR:

      VDat2FormClearPcmkList(&s_domTreeID);

      VDat2FormFillPcmkList(form,
			    VDAT_FORM_PCMK_G_PIECES,
			    VDAT_FORM_PCMK_G_NEXT_PCMK,
			    VDAT_FORM_PCMK_B_PROCESS,
			    &s_domTreeID,
			    &s_ssID,
			     s_nextPcmk);
      break;
      
      
    case VDAT_FORM_PCMK_B_VALIDATE:
      VDat2FormNotifyValidate(form,&s_domTreeID);
      break;
      
    case VDAT_FORM_PCMK_B_UNSELECT_ALL:
      notifyUnSelectAll(fl);
      break;
      
    case VDAT_FORM_PCMK_B_UNHILITE_ALL:
      notifyUnHiLiteAll(fl);
      break;

    case VDAT_FORM_PCMK_B_HILITE_SELECT:
      notifyHiLiteSelect(fl);
      break;

    case VDAT_FORM_PCMK_T_STD_VER:
      VDfrmGetState(form,VDAT_FORM_PCMK_T_STD_VER,&ver);
      if (ver == 0) ver = 1;
      else          ver = 2;
      VDatSetStdPcmkVersion(ver);
      break;
      
    case FI_EXECUTE:
      VDat2FormSyncPcmkList(form,VDAT_FORM_PCMK_G_PIECES,&s_domTreeID);
      VDat2UpdateStagingTreePcmks(&s_setID,&s_domTreeID,&s_ssID,s_save_ss,s_nextPcmk,NULL);
      s_save_ss = 0;
      break;

    case FI_ACCEPT:
      VDat2FormSyncPcmkList(form,VDAT_FORM_PCMK_G_PIECES,&s_domTreeID);
      VDat2UpdateStagingTreePcmks(&s_setID,&s_domTreeID,&s_ssID,s_save_ss,s_nextPcmk,NULL);
      // Let it drop through

    case FI_CANCEL:
      VIf_erase(form);
      VDatFormSetActive(form,0);
      
      if (s_domTreeID.objid != NULL_OBJID) VDctxDeleteNode(&s_domTreeID);
      s_domTreeID.objid = NULL_OBJID;
      if (s_ssID.objid != NULL_OBJID) VDctxDeleteNode(&s_ssID);
      s_ssID.objid  = NULL_OBJID;
      s_setID.objid = NULL_OBJID;
      s_save_ss = 0;
      break;

    case FI_RESET:
      VDatFormSetActive(form,1);
      VDatCMDPcmkActivateSet(fl);
      break;
  }

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDatCMDPcmk2ActivateForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  Form    form;

  IGRint ver;
  
  // Arg check
  if ((fl == NULL) || (fl->pcmk2 == NULL)) goto wrapup;
  form = fl->pcmk2;

  // Ignore if already active for now
  sts = VDatFormIsActive(form);
  if (sts == 1) {
    retFlag = 1;
    goto wrapup;
  }

  // This should be safe
  s_domTreeID.objid = NULL_OBJID;
  s_setID.objid     = NULL_OBJID;
  s_ssID.objid      = NULL_OBJID;
  
  // Just display
  VIf_display(form);
  VDatFormSetActive(form,1);

  // Adjust toggle based on version
  VDatGetStdPcmkVersion(&ver);
  if (ver == 2) VDfrmSetState(form,VDAT_FORM_PCMK_T_STD_VER,1);
  else          VDfrmSetState(form,VDAT_FORM_PCMK_T_STD_VER,0);
  
  // This actually builds a dom tree
  VDatCMDPcmk2ActivateSet(fl);

  retFlag = 1;

wrapup:
  return retFlag;
}
