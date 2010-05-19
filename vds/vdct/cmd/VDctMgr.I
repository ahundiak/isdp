/* $Id: VDctMgr.I,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/cmd/VDctMgr.I
 *
 * Description: Manager Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDctMgr.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1999/06/30  18:15:14  pinnacle
# ct
#
# Revision 1.2  1999/05/31  16:47:34  pinnacle
# ct
#
# Revision 1.1  1999/05/30  14:30:52  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/29/99  ah      creation
 *
 ***************************************************************************/

class implementation VDctBase;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDfrm.h"
#include "VDppl1.h"

#include "VDct.h"
#include "VDctCmd.h"


static int traceFlag;
static TVDctCmdInfo *cmdInfo;

#define VDCT_FORM_MGR_L_SETS 21
#define VDCT_FORM_MGR_L_SETS_FILE 0
#define VDCT_FORM_MGR_L_SETS_NAME 1
#define VDCT_FORM_MGR_L_SETS_TYPE 2
#define VDCT_FORM_MGR_L_SETS_ID   3

#define VDCT_FORM_MGR_B_SETS  12
#define VDCT_FORM_MGR_B_LEAFS 13
#define VDCT_FORM_MGR_B_TREES 15
#define VDCT_FORM_MGR_B_ATTRS 16
#define VDCT_FORM_MGR_B_REPS  17
#define VDCT_FORM_MGR_B_STAGE 18
#define VDCT_FORM_MGR_B_POST  23
#define VDCT_FORM_MGR_B_PCMK  25

#define VDCT_FORM_MGR_B_HILITE   19
#define VDCT_FORM_MGR_B_UNHILITE 37

IGRstat VDctCmdMgrNotifyObject(TGRobj_env *setOE);
IGRstat VDctCmdMgrNotifyForm  ();
IGRstat VDctCmdMgrInit        (TVDctCmdInfo *a_cmdInfo);
IGRstat VDctCmdMgrDelete      ();
IGRstat VDctCmdMgrWakeup      ();
IGRstat VDctCmdMgrSleep       ();

IGRstat VDctCmdMgrGetFilter();
IGRstat VDctCmdMgrGetDefaultFilter();

#if 0
IGRstat VDatCMDMgrFillSets(Form form, IGRint gadget);
IGRstat VDatCMDMgrFillAll (Form form);
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

  TVDvlaID leafVLA;
  TGRid    leafID;
  
  IGRint   i;
  
  // Init
  VDvlaID_Construct(&leafVLA);
  
  VDatCMDAllGetActiveSet(fl, &setID, NULL);

  if (VDatIsSetATree(&setID))  {
    VIg_enable(form,VDAT_FORM_MGR_B_TREES);
    VIg_enable(form,VDAT_FORM_MGR_B_STAGE);
  }
  else {
    VIg_disable(form,VDAT_FORM_MGR_B_TREES);
    VIg_disable(form,VDAT_FORM_MGR_B_STAGE);
  }

  // Verify all leafs just for grins
  VDatGetLeafsVLA(&setID,&leafVLA);
  for(i = 0; VDvlaID_GetAt(&leafVLA,&leafID,i); i++ ){
    VDatLeafVerifyPiece(&leafID);
  }
  
  // Done
  VDvlaID_Delete(&leafVLA);
  
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
  strcpy(refName,OM_GA_OSDs[setID->osnum]->name);
  pnt = strrchr(refName,'/');
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
#endif

/* --------------------------------------
 * User poked a set in the list
 */
IGRstat VDatCmdMgrNotifySets()
{
  IGRstat retFlag = 0;

  Form    form   = cmdInfo->mgr.form;
  IGRint  gadget = VDCT_FORM_MGR_L_SETS;

  IGRint  row,col,mode;

  TGRid   setID;

  // Get active row
  row = -1;
  vdfrm$GetActiveRow(form = form, gadget = gadget, row = &row);
  if (row < 0) goto wrapup;

  vdfrm$GetText(form   = form, 
		gadget = gadget, 
		row    = row, 
		col    = VDCT_FORM_MGR_L_SETS_ID,
		objID  = &setID);
  if (setID.objid == NULL_OBJID) goto wrapup;
  
  vdobj$Print(objID = &setID);
  
  //VDatCMDAllSetActiveSet(fl,&setID);

  retFlag = 1;

wrapup:
  if (retFlag & 1) mode = 1;
  else {
    mode = 0;
    vdfrm$SetStatus(form = form, txt = "Bad Set Selected");
  }

  for(col = 0; col < 3; col++) {
    vdfrm$SetSelect(form = form, gadget = gadget, row = row, col = col, sel = mode);
  }
  
  return retFlag;
}
#if 0
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
  strcpy(refName,OM_GA_OSDs[osnum]->name);
  pnt = strrchr(refName,'/');
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

  IGRint    refI;
  TGRmd_env refENV;
  TVDvlaENV refEnvVLA;

  // Clear Field
  VIfld_set_num_rows(form,gadget,0);
  row = 0;

  // Get list of files
  VDvlaENV_Construct(&refEnvVLA);
  VDahRefGetRefList (&refEnvVLA);

  for(refI = 0; VDvlaENV_GetAt(&refEnvVLA,&refENV,refI); refI++) {

    VDatCMDMgrFillSet(form, gadget, &row, refENV.md_id.osnum);

  }

  retFlag = 1;

//wrapup:
  VDvlaENV_Delete(&refEnvVLA);
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

/* ------------------------------------------------------
 * Wrapper to convert fence into vla
 * later may want to handle mod env better
 */
IGRstat VDahGetFenceVLA(TGRobj_env *objOE, TVDvlaOE *objVLA)
{
  IGRstat retFlag = 0;
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
    VDvlaOE_Append(objVLA,&listOE[i]);
  }
  ASend_fence(); // Frees listOE

  retFlag = 1;
  return retFlag;
}
#endif

/* -----------------------------------------------------
 * An object was selected
 */
IGRstat VDctCmdMgrNotifyObject(TGRobj_env *objOE)
{
  IGRstat  retFlag = 0;

  vdobj$Print(objOE = objOE);

  retFlag = 1;
//wrapup:
  return retFlag;
}

/* -------------------------------------------
 * The notification routine, called by the ppl
 */
#argsused
IGRstat VDctCmdMgrNotifyForm()
{
  IGRstat retFlag = 0;
  IGRstat msg;

  // See which form caused message
  if (cmdInfo->form == cmdInfo->set.form) {
    retFlag = VDctCmdSetNotifyForm();
    goto wrapup;
  }

  if (cmdInfo->form == cmdInfo->leaf.form) { 
    // retFlag = VDctCMDLeafNotifyForm();
    goto wrapup;
  }
  if (cmdInfo->form == cmdInfo->tree.form) { 
    // retFlag = VDctCMDTreeNotifyForm();
    goto wrapup;
  }
  if (cmdInfo->form == cmdInfo->attr.form) { 
    // retFlag = VDctCMDAttrNotifyForm();
    goto wrapup;
  }
  if (cmdInfo->form == cmdInfo->stage.form) { 
    // retFlag = VDctCMDStageNotifyForm();
    goto wrapup;
  }
  if (cmdInfo->form == cmdInfo->pcmk.form) { 
    // retFlag = VDctCMDPcmkNotifyForm();
    goto wrapup;
  }

  // Should be the manager itself
  if (cmdInfo->form != cmdInfo->mgr.form) goto wrapup;
  
  switch(cmdInfo->gadget) {

  case VDCT_FORM_MGR_B_POST:
    // retFlag = VDatPOSTAll();
    goto wrapup;

  case VDCT_FORM_MGR_B_UNHILITE:
    dp$erase_hilite(msg = &msg);
    retFlag = 1;
    goto wrapup;

  case VDCT_FORM_MGR_B_HILITE:
    //VDatCmdMgrHiLiteSet(fl);
    retFlag = 1;
    goto wrapup;

  case VDCT_FORM_MGR_L_SETS:
    retFlag = VDatCmdMgrNotifySets();
    goto wrapup;

  case FI_CANCEL:
    retFlag = 1;
    cmdInfo->shutdown = 1;
    goto wrapup;

  case VDCT_FORM_MGR_B_SETS:
    retFlag = VDctCmdSetActivateForm();
    goto wrapup;

  case VDCT_FORM_MGR_B_PCMK:
    // retFlag = VDatCMDPcmkActivateForm();
    goto wrapup;

  case VDCT_FORM_MGR_B_LEAFS:
    // retFlag = VDatCMDLeafActivateForm();
    goto wrapup;

  case VDCT_FORM_MGR_B_TREES:
    // retFlag = VDatCMDTreeActivateForm();
    goto wrapup;

  case VDCT_FORM_MGR_B_ATTRS:
    // retFlag = VDatCMDAttrActivateForm();
    goto wrapup;

  case VDCT_FORM_MGR_B_REPS:
    retFlag = 1;
    goto wrapup;

  case VDCT_FORM_MGR_B_STAGE:
    //retFlag = VDatCMDStageActivateForm();
    goto wrapup;

  }

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Fill in the list of sets for the osnum
 */
IGRstat VDctCmdMgrFillSet(TVDosnum osnum)
{
  IGRstat retFlag = 0;

  TGRid  mgrID;
  TGRid  setID;

  IGRchar *p;
  IGRchar refName[DI_PATH_MAX];

  IGRint  i;
  IGRint  row = 0;

  Form   form   = cmdInfo->mgr.form;
  IGRint gadget = VDCT_FORM_MGR_L_SETS;
  TVDctBaseInfo baseInfo;

  // OS Name
  strcpy(refName,OM_GA_OSDs[osnum]->name);
  p = strrchr(refName,'/');
  if (p) strcpy(refName,p+1);

  // Get the manager
  vdct$GetManager(osnum = osnum, mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;

  // Cycle Through
  //vdfrm$GetNumRows(form = form, gadget = gadget, rows = &row);
  VIfld_get_num_rows(form,gadget,&row);
  //vdfrm$SetText(form = form, gadget = gadget, rows = 0);
  for(i = 0; vdct$GetMgrChild(objID = &mgrID, nth = i, outID = &setID); i++) {

    vdct$GetBaseInfo(objID = &setID, baseInfo = &baseInfo);

    printf("%s %s %s %d %d\n",
           refName,
           baseInfo.setName,
           baseInfo.setType,
           gadget,row);

    vdfrm$SetText(form   = form, 
                  gadget = gadget,
                  row    = row,
                  col    = VDCT_FORM_MGR_L_SETS_FILE,
                  txt    = refName);

    vdfrm$SetText(form   = form, 
                  gadget = gadget,
                  row    = row,
                  col    = VDCT_FORM_MGR_L_SETS_NAME,
                  txt    = baseInfo.setName);

    vdfrm$SetText(form   = form, 
                  gadget = gadget,
                  row    = row,
                  col    = VDCT_FORM_MGR_L_SETS_TYPE,
                  txt    = baseInfo.setType);

    vdfrm$SetText(form   = form, 
                  gadget = gadget,
                  row    = row,
                  col    = VDCT_FORM_MGR_L_SETS_ID,
                  objID  = &setID);

     row++;
  }
#if 0

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
#endif

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called by ppl to start everything up
 */
IGRstat VDctCmdMgrInit(TVDctCmdInfo *a_cmdInfo)
{
  IGRstat retFlag = 0;
  IGRstat msg;

  TGRid mgrID;
  TGRid setID;

  // Say hi
  if (traceFlag) {
    printf(">>> VDctCmdMgrInit\n");
  }

  // Arg check
  if (a_cmdInfo == NULL) {
    printf("*** VDctCmdMgrInit called with NULL command data\n");
    goto wrapup;
  }
  cmdInfo = a_cmdInfo;
  
  // Make sure have a manager or create one
  vdct$GetManager(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    vdct$CreateManager(mgrID = &mgrID);
  }
  if (mgrID.objid == NULL_OBJID) {
    printf("*** Problem Creating Tree Manager\n");
    goto wrapup;
  }

  // Default class selection list
  VDctCmdMgrGetDefaultFilter();

  // Init individual routines
  VDctCmdSetInit(cmdInfo);

  // No default active set yet 
  setID.objid = NULL_OBJID;
  setID.osnum = 0;
  // VDatCMDAllSetActiveSet(&setID);


  /* Fill Everyting */
  VDctCmdMgrFillSet(2);

  /* Erase any existing highlites */
  dp$erase_hilite(msg = &msg);

  /* Done */
  UI_status("Tree Manager Ready");
  retFlag = 1;

  cmdInfo->inittedOK = 1;

wrapup:
  
  return retFlag;
}

/* --------------------------------------
 * Called by ppl to shut things down
 * Not much to do anymore
 */
#argsused
IGRstat VDctCmdMgrDelete()
{
  IGRstat retFlag = 0;
  IGRstat msg;

  dp$erase_hilite(msg = &msg);
  cmdInfo = NULL;
  
  retFlag = 1;

  return retFlag;
}

#argsused
IGRstat VDctCmdMgrWakeup()
{
  /* Wakup all active forms, need to deal with hilite later */
  vdfrm$DisplayForm(form=cmdInfo->mgr.form,   show=cmdInfo->mgr.displayed);
  vdfrm$DisplayForm(form=cmdInfo->set.form,   show=cmdInfo->set.displayed);
  vdfrm$DisplayForm(form=cmdInfo->leaf.form,  show=cmdInfo->leaf.displayed);
  vdfrm$DisplayForm(form=cmdInfo->tree.form,  show=cmdInfo->tree.displayed);
  vdfrm$DisplayForm(form=cmdInfo->attr.form,  show=cmdInfo->attr.displayed);
  vdfrm$DisplayForm(form=cmdInfo->stage.form, show=cmdInfo->stage.displayed);
  vdfrm$DisplayForm(form=cmdInfo->pcmk.form,  show=cmdInfo->pcmk.displayed);
  vdfrm$DisplayForm(form=cmdInfo->mgr.form,   show=cmdInfo->mgr.displayed);

  // Maybe rehilite tree/leaf

  return 1;
}

#argsused
IGRstat VDctCmdMgrSleep()
{
  return 1;
}

#if 0
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

#endif

IGRstat VDctCmdMgrGetDefaultFilter()
{
  IGRstat retFlag = 0;

  om$get_classid( 
    classname = "VDSroot",
    p_classid = &cmdInfo->classIDs[0]
  ) ;

  cmdInfo->classList.p_classes = cmdInfo->classIDs;
  cmdInfo->classList.w_count = 1;
  cmdInfo->classList.w_flags = OM_CLST_subclass;

  retFlag = 1;

  return retFlag;
}

#if 0
int VDctCMDMgrGetFilter()
{
  IGRint retFlag = 0;

  TGRid   setID;
  IGRchar setType[128];

  TGRid  pplID;
  IGRint pplRET;

  // Sets the pointer and gets default info
  VDatCMDMgrGetDefaultFilter();

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
#endif

end implementation VDctBase;
