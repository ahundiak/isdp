/* $Id: VDatMgr.I,v 1.11 2002/02/05 17:13:58 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/cmd/VDatMgr.I
 *
 * Description: Manager Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatMgr.I,v $
 *      Revision 1.11  2002/02/05 17:13:58  ylong
 *      *** empty log message ***
 *
 *      Revision 1.10  2001/10/19 18:29:20  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/06/22 15:20:30  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/06/03 14:43:58  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/05/18 17:39:08  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/03/16 17:04:08  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/02/14 16:45:00  ramarao
 *      Removed __Enter() and __Exit() macros.
 *
 *      Revision 1.4  2001/01/23 13:57:15  ahundiak
 *      mixup
 *
 *      Revision 1.2  2001/01/11 20:23:18  art
 *      sp merge
 *
# Revision 1.3  2000/11/27  19:07:52  pinnacle
# ah
#
# Revision 1.2  2000/10/19  16:25:18  pinnacle
# ah
#
# Revision 1.1  2000/06/27  16:37:32  pinnacle
# ah
#
# Revision 1.8  2000/02/14  19:47:16  pinnacle
# tr179901064
#
# Revision 1.7  2000/01/10  21:33:44  pinnacle
# ah
#
# Revision 1.6  1999/03/17  15:41:06  pinnacle
# tr179900457
#
# Revision 1.5  1999/02/09  20:38:22  pinnacle
# Replaced: vdat/cmd/VDatMgr.I for:  by vsrivast for vds
#
# Revision 1.4  1998/10/25  12:03:50  pinnacle
# ah
#
# Revision 1.3  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.2  1998/09/25  15:44:20  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/10/97  ah      creation
 * 02/14/00  ah      TR179901064 Crashing when getting ref file names.
 * 06/21/00  ah      Cleaned up activate set a bit
 * 10/19/00  ah      Check tags when adding pieces
 * 03/14/01  ah      Added Piece mark Ver 2
 * 05/18/01  ah      TR5223 VDatGetChildForPath Crashes
 * 02/04/02  ylong   TR5973 added message to filter for consumed object
 ***************************************************************************/

class implementation VDatBase;

#include "VDmaster.h"
#include "VDatCmd.h"
#include "VDppl1.h"
#include "VDobj.h"
#include "VDtag.h"
#include "VDlog.h"

#include "v_dbgmacros.h"

#define TRACE_FLAG 0

#define VDAT_FORM_MGR_L_SETS 21

#define VDAT_FORM_MGR_B_SETS  12
#define VDAT_FORM_MGR_B_LEAFS 13
#define VDAT_FORM_MGR_B_TREES 15
#define VDAT_FORM_MGR_B_ATTRS 16
#define VDAT_FORM_MGR_B_REPS  17
#define VDAT_FORM_MGR_B_STAGE 18
#define VDAT_FORM_MGR_B_POST  23
#define VDAT_FORM_MGR_B_PCMK  26
#define VDAT_FORM_MGR_B_PCMK2 25

#define VDAT_FORM_MGR_B_HILITE   19
#define VDAT_FORM_MGR_B_UNHILITE 37

IGRstat VDatCMDMgrFillSets(Form form, IGRint gadget);
IGRstat VDatCMDMgrFillAll (Form form);

IGRstat VDatCMDMgrNotifyObject(TVDatFrmList *fl, TGRobj_env *setOE);
IGRstat VDatCMDMgrNotifyForm  (TVDatFrmList *fl);
IGRstat VDatCMDMgrInit        (TVDatFrmList *fl);
IGRstat VDatCMDMgrDelete      (TVDatFrmList *fl);
IGRstat VDatCMDMgrWakeup      (TVDatFrmList *fl);
IGRstat VDatCMDMgrSleep       (TVDatFrmList *fl);

IGRstat VDatCMDMgrClassList(OM_S_CLASSLIST *classList);

IGRstat VDatCMDMgrNotifySets(TVDatFrmList *fl);

IGRstat VDatCMDMgrAddSet(
  TVDatFrmList *fl,
  TGRid        *setID,
  IGRchar      *setName,
  IGRchar      *setType
);
IGRstat VDatCMDMgrDeleteSet(
  TVDatFrmList *fl,
  TGRid        *setID,
  IGRchar      *setName
);

IGRstat VDatCMDMgrHiLiteSet(TVDatFrmList *fl);

/* -------------------------------------------
 * Saves the pointer to the form information
 * for when non-command routines need to interact
 * with the display commands
 */
static TVDatFrmList *g_fl;

TVDatFrmList *VDatCMDMgrGetFl() 
{
  return g_fl;
}

/* ----------------------------------------
 * New active set was picked
 */
IGRstat VDatCMDMgrActivateSet(TVDatFrmList *fl)
{
  Form  form = fl->mgr;
  TGRid setID;
  TGRid treeID;
  
  // Init
  VDatCMDAllGetActiveSet(fl, &setID, NULL);

  if (VDatIsSetATree(&setID))  {
    VIg_enable(form,VDAT_FORM_MGR_B_TREES);
    VIg_enable(form,VDAT_FORM_MGR_B_STAGE);
  }
  else {
    VIg_disable(form,VDAT_FORM_MGR_B_TREES);
    VIg_disable(form,VDAT_FORM_MGR_B_STAGE);
  }

  // Another attribute check
  UI_status("Checking Set Attributes...");
  VDatCheckBaseAttrs(&setID);
  UI_status("Check Complete");

  // Check attributes following a possible core dump
  UI_status("Checking Set Attributes...");
  VDatCheckBaseAttributes(&setID);
  UI_status("Attribute Check Complete");

  // Verify the set
  UI_status("Checking Set...");
  VDatCheckBase(&setID);
  if (setID.objid != NULL_OBJID) {
    VDatGetTree(&setID,&treeID);    
    if (treeID.objid != NULL_OBJID) VDvalValidateStagingTree(&treeID,NULL);
  }
  UI_status("Check Complete");
  
  // Done
  
  return 1;
}

/* ----------------------------------------
 * Hilite active set
 */
IGRstat VDatCMDMgrHiLiteSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  TGRid   setID,leafsID;

  VDatCMDAllGetActiveSet(fl, &setID, NULL);
  if (setID.objid == NULL_OBJID) goto wrapup;

  // Get the leafs
  VDatGetLeafs(&setID,&leafsID);
  if (leafsID.objid == NULL_OBJID) goto wrapup;

  // Display them
  VDatDisplayNode(&leafsID,GRhhd);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Someone deleted a set
 */
#argsused
IGRstat VDatCMDMgrDeleteSet(
  TVDatFrmList *fl,
  TGRid        *a_setID,
  IGRchar      *a_setName
)
{
  IGRstat retFlag = 0;

  Form   form   = fl->mgr;
  IGRint gadget = VDAT_FORM_MGR_L_SETS;

  TGRid setID;
  
  // Refill list
  VDatCMDMgrFillSets(form, gadget);

  // No set active
  setID.objid = NULL_OBJID;
  setID.osnum = 0;
  VDatCMDAllSetActiveSet(fl, &setID);

  retFlag = 0x999;
  return retFlag;
}

/* --------------------------------------
 * Someone renamed a set
 */
#argsused
IGRstat VDatCMDMgrRenameSet(
  TVDatFrmList *fl,
  TGRid        *a_setID,
  IGRchar      *a_setName
)
{
  IGRstat retFlag = 0;

  Form   form   = fl->mgr;
  IGRint gadget = VDAT_FORM_MGR_L_SETS;
  
  // Refill list
  VDatCMDMgrFillSets(form, gadget);

  // Make it active forcing forms to refresh themselvse
  VDatCMDAllSetActiveSet(fl, a_setID);

  retFlag = 0x999;
  return retFlag;
}

/* --------------------------------------
 * Someone created a set
 */
IGRstat VDatCMDMgrAddSet(
  TVDatFrmList *fl,
  TGRid        *setID,
  IGRchar      *setName,
  IGRchar      *setType
)
{
  IGRstat retFlag = 0;
  IGRint  row;
  Form    form = fl->mgr;
  IGRint  gadget = VDAT_FORM_MGR_L_SETS;

  IGRchar  refName[1024];
  IGRchar *pnt;

  // Insert at end
  row = -1;
  VIfld_get_num_rows(form,gadget,&row);
  if (row < 0) goto wrapup;

  // OS Name
  di$give_pathname(osnum = setID->osnum, pathname = refName);
  pnt = strrchr(refName,':');
  if (pnt) strcpy(refName,pnt+1);

  VDahFrmSetTextRC(form,gadget,row,0,refName);
  VDahFrmSetTextRC(form,gadget,row,1,setName);
  VDahFrmSetTextRC(form,gadget,row,2,setType);
  VDahFrmSetGRid  (form,gadget,row,3,setID);

  // Want row to be selected and displayed
  VIfld_set_select(form,gadget,row,0,1);
  VIfld_set_select(form,gadget,row,1,1);
  VIfld_set_select(form,gadget,row,2,1);
  VDatFormShowRow (form,gadget,row);

  // Tell the rest of world about it
  VDatCMDAllSetActiveSet(fl,setID);

  fl->reset = 1;
  retFlag = 0x999;
wrapup:
  return retFlag;
}

/* --------------------------------------
 * User poked a set in the list
 */
IGRstat VDatCMDMgrNotifySets(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  Form    form   = fl->mgr;
  IGRint  gadget = VDAT_FORM_MGR_L_SETS;

  IGRint  row,pos;

  TGRid   setID;

  // Get active row
  row = -1;
  VIfld_get_active_row(form,gadget,&row,&pos);
  if (row < 0) goto wrapup;
  

  // Get the set
  VDahFrmGetGRid(form,gadget,row,3,&setID);  
  if (setID.objid == NULL_OBJID) goto wrapup;
  
  VDatCMDAllSetActiveSet(fl,&setID);

  fl->reset = 1;
  retFlag = 0x999;

wrapup:
  if (retFlag != 0) {
    VIfld_set_select(form,gadget,row,0,1);
    VIfld_set_select(form,gadget,row,1,1);
    VIfld_set_select(form,gadget,row,2,1);
  }
  else {
    VIfld_set_select(form,gadget,row,0,0);
    VIfld_set_select(form,gadget,row,1,0);
    VIfld_set_select(form,gadget,row,2,0);
    VIg_set_text(form,10,"Bad Set Selected");
  }

  return retFlag;
}

/* ----------------------------------------
 * Fill in one file of sets
 */
IGRstat VDatCMDMgrFillSet(Form form, IGRint gadget, IGRint *row, VDosnum osnum)
{
  IGRstat retFlag = 0;

  TGRid  mgrID;

  TGRid setsID;
  TGRid  setID;

  TGRid rdbSetID;

  IGRchar setName[128];
  IGRchar setType[128];
  IGRchar *pnt;

  IGRchar refName[DI_PATH_MAX];

  IGRint  i;

  // OS Name
  di$give_pathname(osnum = osnum, pathname = refName);
  pnt = strrchr(refName,':');
  if (pnt) strcpy(refName,pnt+1);

  // For active, do ?

  // Get the manager
  vdat$GetSetMgr(osnum = osnum, mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;

  // Get the sets
  VDatGetSets(&mgrID,&setsID);
  if (setsID.objid == NULL_OBJID) goto wrapup;

  // Cycle Through
  for(i = 0; VDatGetChildObject(&setsID,i,&setID); i++) {

    // Show name for now
    VDahFrmSetTextRC(form,gadget,*row,0,refName);

    // Show name for now
    *setName = 0;
    VDatGetBaseName(&setID,setName);
    VDahFrmSetTextRC(form,gadget,*row,1,setName);

    // Get the set type
    VDatRDBGetSet  (&setID,&rdbSetID);
    VDatGetBaseName(&rdbSetID,setType);
    VDahFrmSetTextRC(form,gadget,*row,2,setType);

    // Store the id
    VDahFrmSetGRid(form,gadget,*row,3,&setID);
    
    // Next Row
    *row = *row + 1;
  }

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Fill in list of sets
 */
IGRstat VDatCMDMgrFillSets(Form form, IGRint gadget)
{
  IGRstat retFlag = 0;

  IGRint row;

  VDosnum osnum;
  
  // Clear Field
  VIfld_set_num_rows(form,gadget,0);
  row = 0;

  // Cycle through os numbers
  for(osnum = 0; VDosValidate(osnum); osnum++) {
    VDatCMDMgrFillSet(form, gadget, &row, osnum);    
  }

  retFlag = 1;

//wrapup:
  return retFlag;
}

/* ----------------------------------------------------
 * Fill everything on manager form
 */
IGRstat VDatCMDMgrFillAll(Form form)
{
  IGRstat retFlag = 0;

  if (form == NULL) goto wrapup;

  VDatCMDMgrFillSets(form,VDAT_FORM_MGR_L_SETS);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * The object returned by di$translate maybe consumed
 * and have a child with the same name
 *
 * Actually, in some cases the parent should be consumed
 * but is not
 *
 * Find any children with the same name
 * Recursive Routine
 *
 * Prevent loops if parent is somehow attached to the child
 * Do this with a loop counter just to be safe
 */
IGRstat VDatGetChildForPathx(IGRchar *a_path, IGRint *a_cnt, TGRid *a_parentID, TGRid *a_childID)
{
  IGRstat retFlag = 0;
  IGRstat msg;
  
  IGRchar path[256];
  TGRid   childID;
  IGRint  i;

#if TRACE_FLAG
  printf(">>> VDatGetChildForPath\n");
#endif
  
  // See if should stop
  if (*a_cnt > 100) {
    VDlogPrintObject(VDLOG_ERROR,1,"*** This piece's graph is corrupted ",NULL,a_parentID);
    a_childID->objid = NULL_OBJID;
    goto wrapup;
  }
  *a_cnt = *a_cnt + 1;
  
  // Default to parent
  *a_childID = *a_parentID;
  
  // Really need a path
  if (*a_path == 0) goto wrapup;
  
  // Cycle through kids
  for(i = 0; VDahGetChnObject(a_parentID,"NDchildren.children",i,&childID); i++) {
    *path = 0;
    om$send(msg = message GRgraphics.GRgetname(&msg,path),
	    senderid = NULL_OBJID,
	    targetid = childID.objid,
	    targetos = childID.osnum);
    
    
    if (!strcmp(a_path,path)) {

#if TRACE_FLAG      
      printf("--- Found Child ---\n");
      printf("%s\n",path);
      vdobj$Print(objID = &childID);
#endif

      // Got it
      *a_childID = childID;
      
      // Recurse in case child itself is consumed
      return VDatGetChildForPathx(a_path,a_cnt,&childID,a_childID);
      
    }
  }
  
  // No matches
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Sometimes the filter lets through unwanted objects,
 * Filter this out here
 */
IGRstat VDatCMDMgrFilterObject(TGRobj_env *objOE)
{
  IGRstat retFlag = 1;
  IGRstat sts,msg;
  
  IGRchar path[256];
  
  TGRid objID;
  TGRid objIDx;
  IGRint cnt;
  
  TVDtag tag;

  TGRobj_env	child;

#if TRACE_FLAG
  printf(">>> VDatCMDMgrFilterObject\n");
  vdobj$Print(objOE = objOE);
#endif

  // Is it consumed
  sts = om$send(msg = message NDmacro.ACtest_consumed(&msg),
		senderid = NULL_OBJID,
		targetid = objOE->obj_id.objid,
		targetos = objOE->obj_id.osnum);

  if (sts & msg & 1) {

    child.obj_id.objid = NULL_OBJID;
    VDatGetConsumingChild( objOE, &child);
    path[0] = '\0';
    if(IF_EQ_GRID(objOE->obj_id, child.obj_id)) child.obj_id.objid = NULL_OBJID;
    printf("### This object is being filtered\n");
    vdobj$Print(objOE = objOE);
    printf("is consumed by "); vdobj$Print(objOE = &child);
    printf("You can use COz_unconsu to forcibly unconsume the object\n");
    printf("###\n");

#if TRACE_FLAG
    printf("==== Object is consumed\n");
#endif
    retFlag = 0;
    goto wrapup;
  }
#if TRACE_FLAG
  printf("Object is not consumed\n");
#endif
  
  /* ---------------------------------------------
   * The consumed code should actually catch most problems
   * but lets make sure we have a valid name as well
   */

  // Start by getting full path
  *path = 0;
  om$send(msg = message GRgraphics.GRgetname(&msg,path),
	  senderid = NULL_OBJID,
	  targetid = objOE->obj_id.objid,
	  targetos = objOE->obj_id.osnum);
#if TRACE_FLAG
  printf("Object path '%s'\n",path);
#endif  
  switch(*path) {
  case  0 :
  case ' ':
  case 'V':
    printf("### Filtering out part with unexpected name\n");
    printf("Name %s\n",path);
    vdobj$Print(objOE = objOE);
    printf("###\n");
    retFlag = 0;
    goto wrapup;
  }

  /* ---------------------------------------------
   * Make sure can get the tag, sometimes the model
   * file is bad
   */
  vdtag$GetInfo(objOE = objOE, tag = &tag);
  if (tag.num == 0) {
    printf("### Filtering out part (no tag)\n");
    printf("Name %s\n",path);
    vdobj$Print(objOE = objOE);
    printf("###\n");
    retFlag = 0;
    goto wrapup;
  }

#if TRACE_FLAG
  printf("Object tag %d\n",tag.num);
#endif
  
  // replace this with get consuming child later
  // the consume check turned off

  // Now retrieve it and see if the id's match
  objID.objid = NULL_OBJID;
  di$translate(objname =  path,
	       p_objid = &objID.objid,
	       p_osnum = &objID.osnum);

#if TRACE_FLAG
  printf("Translated object %d,%d\n",objID.osnum,objID.objid);
#endif
  
  // Look for kids with same name
  cnt = 0;
  VDatGetChildForPathx(path,&cnt,&objID,&objIDx);
  if ((objIDx.objid == objOE->obj_id.objid) &&
      (objIDx.osnum == objOE->obj_id.osnum)) {
    goto wrapup;
  }

#if TRACE_FLAG
  printf("Back from getting child\n");
#endif
  
  // Filter mismatches
  printf("### This object is being filtered\n");
  printf("Name %s\n",path);
  vdobj$Print(objOE =  objOE);
  vdobj$Print(objID = &objID);
  vdobj$Print(objID = &objIDx);
  printf("###\n");
  
  // Done
  retFlag = 0;
  
wrapup:
#if TRACE_FLAG
  printf("<<< VDatCMDMgrFilterObject\n");
#endif  
  return retFlag;
}

/* ------------------------------------------------------
 * Wrapper to convert fence into vla
 * later may want to handle mod env better
 */
IGRstat VDahGetFenceVLA(TGRobj_env *objOE, TVDvlaOE *objVLA)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint  cnt = 0;
  IGRint  i;
  TGRobj_env *listOE = NULL;

  as$start_fence(
    set     = &objOE->obj_id,
    set_env = &objOE->mod_env,
    nb_obj  = &cnt,
    p_obj_env = &listOE
  );
  for(i = 0; i < cnt; i++) {
    sts = VDatCMDMgrFilterObject(&listOE[i]);
    if (sts & 1) {  
      VDvlaOE_Append(objVLA,&listOE[i]);
    }
  }
  ASend_fence(); // Frees listOE

  retFlag = 1;
  return retFlag;
}

/* -----------------------------------------------------
 * An object was selected
 */
IGRstat VDatCMDMgrNotifyObject(TVDatFrmList *fl, TGRobj_env *setOE)
{
  IGRstat  retFlag = 0;
  TVDvlaOE setVLA;

  // Get the objects
  VDvlaOE_Construct(&setVLA);
  VDahGetFenceVLA(setOE, &setVLA);

  // Send them onwards
#if TRACE_FLAG
  printf("Got the set, sending them to leafs\n");
#endif
  VDatCMDLeafNotifyObject(fl,&setVLA);
#if TRACE_FLAG
  printf("Got the set, sending them to trees\n");
#endif
  VDatCMDTreeNotifyObject(fl,&setVLA);
#if TRACE_FLAG
  printf("Done processing the set\n");
#endif

  retFlag = 1;
//wrapup:
  VDvlaOE_Delete(&setVLA);
  return retFlag;
}

/* -------------------------------------------
 * The notification routine, called by the ppl
 */
#argsused
IGRstat VDatCMDMgrNotifyForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat msg;

  // Arg Check
  if (fl == NULL) {
    printf("Form notification reached with NULL Data\n");
    goto wrapup;
  }

  // Form has all global data
  if (fl->form == NULL) {
    printf("NULL Form Pointer\n");
    goto wrapup;
  }

  // See which form caused message
  if (fl->form == fl->set) { 
    retFlag = VDatCMDSetNotifyForm(fl);
    goto wrapup;
  }
  if (fl->form == fl->leaf) { 
    retFlag = VDatCMDLeafNotifyForm(fl);
    goto wrapup;
  }
  if (fl->form == fl->tree) { 
    retFlag = VDatCMDTreeNotifyForm(fl);
    goto wrapup;
  }
  if (fl->form == fl->attr) { 
    retFlag = VDatCMDAttrNotifyForm(fl);
    goto wrapup;
  }
  if (fl->form == fl->stage) { 
    retFlag = VDatCMDStageNotifyForm(fl);
    goto wrapup;
  }
  if (fl->form == fl->pcmk) { 
    retFlag = VDatCMDPcmkNotifyForm(fl);
    goto wrapup;
  }
  if (fl->form == fl->rep) { 
    retFlag = VDatCMDPcmk2NotifyForm(fl);
    goto wrapup;
  }

  // Should be the manager itself
  if (fl->form != fl->mgr) goto wrapup;
  
  switch(fl->gadget) {

  case VDAT_FORM_MGR_B_POST: {
    retFlag = VDatPOSTAll();
    goto wrapup;
  }

  case VDAT_FORM_MGR_B_UNHILITE: {
    dp$erase_hilite(msg = &msg);
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_FORM_MGR_B_HILITE: {
    VDatCMDMgrHiLiteSet(fl);
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_FORM_MGR_L_SETS: {
    retFlag = VDatCMDMgrNotifySets(fl);
    goto wrapup;
  }

  case FI_CANCEL: {
    retFlag = FI_CANCEL;  // Will bubble up and shutdown command
    goto wrapup;
  }

  case VDAT_FORM_MGR_B_SETS: {
    retFlag = VDatCMDSetActivateForm(fl);
    goto wrapup;
  }

  case VDAT_FORM_MGR_B_PCMK: {
    retFlag = VDatCMDPcmkActivateForm(fl);
    goto wrapup;
  }
  case VDAT_FORM_MGR_B_PCMK2: {
    retFlag = VDatCMDPcmk2ActivateForm(fl);
    goto wrapup;
  }

  case VDAT_FORM_MGR_B_LEAFS: {
    retFlag = VDatCMDLeafActivateForm(fl);
    goto wrapup;
  }

  case VDAT_FORM_MGR_B_TREES: {
    //printf("Activating Tree Form...\n");
    retFlag = VDatCMDTreeActivateForm(fl);
    //printf("Activating Tree Form Complete\n");
    goto wrapup;
  }

  case VDAT_FORM_MGR_B_ATTRS: {
    retFlag = VDatCMDAttrActivateForm(fl);
    goto wrapup;
  }

  case VDAT_FORM_MGR_B_REPS: {
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_FORM_MGR_B_STAGE: {
    retFlag = VDatCMDStageActivateForm(fl);
    goto wrapup;
  }
  }

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called by ppl to start everything up
 */
IGRstat VDatCMDMgrInit(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRid mgrID;
//TGRid pdmID;
  TGRid setID;

  g_fl = fl;
  
  /* Need to be logged in 
  if (!VDatVerifyLogin()) {
    UI_status("Please log into PDM first.");
    goto wrapup;
  }
*/
  /* Init the pdm info
  VDatGetPdmMgr(1,&pdmID);
  if (pdmID.objid == NULL_OBJID) {
    VDatCreatePdmMgr(1,&mgrID);
  }
*/

  // Make sure have a manager or create one
  vdat$GetSetMgr(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    vdat$CreateSetMgr(mgrID = &mgrID);
  }
  if (mgrID.objid == NULL_OBJID) {
    goto wrapup;
  }

  if (fl->mgr != NULL) {
//  sprintf(buf,"Set Manager %d,%d\n",mgrID.osnum,mgrID.objid);
//  FIg_set_text(fl->mgr,10,buf);
  }

  // Make everything inactive but the manager
  VDatFormSetActive(fl->mgr,  1);
  VDatFormSetActive(fl->set,  0);
  VDatFormSetActive(fl->leaf, 0);
  VDatFormSetActive(fl->tree, 0);
  VDatFormSetActive(fl->attr, 0);
  VDatFormSetActive(fl->stage,0);
  VDatFormSetActive(fl->pcmk, 0);
  VDatFormSetActive(fl->rep,  0);

  // No default active set yet 
  setID.objid = NULL_OBJID;
  setID.osnum = 0;
  VDatCMDAllSetActiveSet(fl,&setID);

  // Default class selection list
  VDatCMDMgrGetDefaultFilter(fl);

  /* Fill Everyting */
  VDatCMDMgrFillAll(fl->mgr);

  /* Erase any existing highlites */
  sts = dp$erase_hilite(msg = &msg);

  /* Done */
  UI_status("Set Manager Ready");
  retFlag = 1;

wrapup:

  if (!(retFlag & 1)) g_fl = NULL;
  
  return retFlag;
}

/* --------------------------------------
 * Called by ppl to shut things down
 * Not much to do anymore
 */
#argsused
IGRstat VDatCMDMgrDelete(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat msg;

  dp$erase_hilite(msg = &msg);

  g_fl = NULL;
  
  retFlag = 1;

  return retFlag;
}

#argsused
IGRstat VDatCMDMgrWakeup(TVDatFrmList *fl)
{
  /* Wakup all active forms, need to deal with hilite later */
  if (VDatFormIsActive(fl->mgr))   VIf_display(fl->mgr);
  if (VDatFormIsActive(fl->set))   VIf_display(fl->set);

  if (VDatFormIsActive(fl->leaf)) {
    VIf_display(fl->leaf);
    VDatCMDLeafHiLiteLists(fl);
  }

  if (VDatFormIsActive(fl->tree))  VIf_display(fl->tree);
  if (VDatFormIsActive(fl->attr))  VIf_display(fl->attr);
  if (VDatFormIsActive(fl->stage)) VIf_display(fl->stage);
  if (VDatFormIsActive(fl->pcmk))  VIf_display(fl->pcmk);
  if (VDatFormIsActive(fl->rep))   VIf_display(fl->rep);

  return 1;
}

#argsused
IGRstat VDatCMDMgrSleep(TVDatFrmList *fl)
{
  return 1;
}

static VDclassid classListIDs[4];

IGRstat VDatCMDMgrClassList(OM_S_CLASSLIST *classList)
{
  IGRstat retFlag = 0;

  om$get_classid( 
    classname = "VSplate",
    p_classid = &classListIDs[0]
  ) ;
  om$get_classid( 
    classname = "VSbeam",
    p_classid = &classListIDs[1]
  ) ;

  classList->p_classes = classListIDs;
  classList->w_count = 2;
  classList->w_flags = OM_CLST_subclass;

  retFlag = 1;

  return retFlag;
}

int VDatCMDMgrGetDefaultFilter(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  om$get_classid( 
    classname = "VDSroot",
    p_classid = &fl->classIDs[0]
  ) ;

  fl->classList.p_classes = fl->classIDs;
  fl->classList.w_count = 1;
  fl->classList.w_flags = OM_CLST_subclass;

  retFlag = 1;

  return retFlag;
}

int VDatCMDMgrGetFilter(TVDatFrmList *fl)
{
  IGRint retFlag = 0;

  TGRid   setID;
  IGRchar setType[128];

  TGRid  pplID;
  IGRint pplRET;

  // Sets the pointer and gets default info
  VDatCMDMgrGetDefaultFilter(fl);

  VDatCMDAllGetActiveSet(fl,&setID,NULL);
  if (setID.objid == NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }
  VDatRDBGetSetType(&setID,setType);

  vdppl$Load(name = setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) {
    retFlag = 0;
    goto wrapup;
  }
  //printf("Get Filter "); vdobj$Print(objID = &pplID);

  vdppl$SetData(pplID = &pplID,
                name  = "CLASS_LIST",
                size  = sizeof( fl->classList),
                data  = (char*)&fl->classList);

  vdppl$Run(pplID = &pplID, name = "getFilter", ret = &pplRET);

  vdppl$GetData(pplID = &pplID,
                name  = "CLASS_LIST",
                size  = sizeof( fl->classList),
                data  = (char*)&fl->classList);

  /* ------------------------------------------
   * Deleting oes not seem to make a difference
   * Always seem to get same pplID for same pplName
   * But whatever is going on, deleting seems safer
   */
   vdppl$Delete(pplID = &pplID);

  retFlag = 1;
wrapup:
  return retFlag;
}

end implementation VDatBase;
