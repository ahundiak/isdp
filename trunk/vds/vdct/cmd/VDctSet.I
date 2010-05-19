/* $Id: VDctSet.I,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/cmd/VDatSet.I
 *
 * Description: Set creation form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDctSet.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *      Initial import to CVS
 *
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

#define VDCT_FORM_SET_G_SET_NAME  51
#define VDCT_FORM_SET_G_SET_TYPE  12
#define VDCT_FORM_SET_G_SET_DESC  16
#define VDCT_FORM_SET_G_PIECE_TBL 28
#define VDCT_FORM_SET_G_TREE_TBL  29

#define VDCT_FORM_SET_B_CREATE_SET 20
#define VDCT_FORM_SET_B_DELETE_SET 13
#define VDCT_FORM_SET_B_RENAME_SET 19

IGRstat VDctCmdSetDeleteSet();
IGRstat VDctCmdSetCreateSet();
IGRstat VDctCmdSetRenameSet();

IGRstat VDctCmdSetNotifyType();
IGRstat VDctCmdSetFillTypes ();

IGRstat VDctCmdSetNotifyForm  ();
IGRstat VDctCmdSetActivateForm();

IGRstat VDatCmdSetActivateSet();
IGRstat VDctCmdSetInit(TVDctCmdInfo *a_cmdInfo);

#if 0
/* ----------------------------------------
 * Initializes the form with a new active set
 */
IGRstat VDatCMDSetActivateSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid   setID;
  Form    form = fl->set;

  IGRchar setName[128];
  IGRchar rdbSetType[128];

  // Ignore if the form is not active
  sts = VDatFormIsActive(form);
  if (sts != 1) goto wrapup;

  // get the active set
  VDatCMDAllGetActiveSet(fl,&setID,setName);
  if (setID.objid == NULL_OBJID) goto wrapup;

  VIg_set_text(form,VDAT_FORM_ALL_G_SET_NAME,setName);

  VDatRDBGetSetType (&setID,rdbSetType);
  VDatCMDSetFillMisc(form,  rdbSetType);

  // If the set is in a reference file, disable some gadgets
  if ((setID.objid == NULL_OBJID) || (VDatIsSetInActiveOS(&setID))) {    
    VIg_enable(form,VDAT_FORM_SET_B_CREATE_SET);
    VIg_enable(form,VDAT_FORM_SET_B_DELETE_SET);
    VIg_enable(form,VDAT_FORM_SET_B_RENAME_SET);
    VIg_enable(form,VDAT_FORM_SET_G_SET_TYPE);
  }
  else {
    VIg_disable(form,VDAT_FORM_SET_B_DELETE_SET);
    VIg_disable(form,VDAT_FORM_SET_B_RENAME_SET);
  }
  
  retFlag = 1;
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Delete a set
 */
IGRstat VDatCMDSetDeleteSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  Form    form = fl->set;

  TGRid   setID;

  IGRchar setName [128];
  IGRchar setNameX[128];

  // Use global active set
  VDatCMDAllGetActiveSet(fl,&setID,setName);
  if (setID.objid == NULL_OBJID) goto wrapup;

  // Make sure only active set is meant to be deleted
  *setNameX = 0;
  VIg_get_text(form,VDAT_FORM_ALL_G_SET_NAME,setNameX);
  if (strcmp(setName,setNameX)) {
    VDatCMDStatus(form,"Set Name does not match active set");
    goto wrapup;
  }

  // Delete it
  VDatDeleteBase(&setID);

  // Tell the manager
  VDatCMDMgrDeleteSet(fl,&setID,setName);

  // Done
  VDatCMDStatus(form,"Set Deleted");

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Rename a set
 */
IGRstat VDatCMDSetRenameSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  Form    form = fl->set;

  TGRid   mgrID;
  TGRid   setID;
  TGRid   setIDx;
  TGRid   treeID;
  
  IGRchar setType [128];
  IGRchar setName [128];
  IGRchar setNameX[128];

  // Use global active set
  VDatCMDAllGetActiveSet(fl,&setID,setName);
  if (setID.objid == NULL_OBJID) goto wrapup;

  // Get the new name
  *setNameX = 0;
  VIg_get_text(form,VDAT_FORM_ALL_G_SET_NAME,setNameX);
  if (!strcmp(setName,setNameX)) {
    VIg_set_text(form,10,"Enter new set name first");
    goto wrapup;
  }

  // Get the manager
  vdat$GetSetMgr(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    VIg_set_text(form,10,"No Set Manager found");
    goto wrapup;
  }

  // Get the type
  VDatGetSetType(&setID,setType);
  
  // Make sure set does not already exist
  VDatGetSetByName(&mgrID,setType,setNameX,&setIDx);
  if (setIDx.objid != NULL_OBJID) {
    VIg_set_text(form,10,"Set already exists");
    goto wrapup;
  }

  // Rename
  VDatSetBaseName(&setID,setNameX);

  // If it is a tree then rename the top node as well
  VDatGetTree(&setID,&treeID);
  if (treeID.objid != NULL_OBJID) {
    VDatSetNodeName(&treeID,setNameX);
  }

  // Tell the manager
  VDatCMDMgrRenameSet(fl,&setID,setNameX);

  // Update lists

  VIg_set_text(form,10,"Set Renamed");

  retFlag = 1;

wrapup:
  return retFlag;
}
#endif

/* ----------------------------------------
 * Create a set
 */
IGRstat VDctCmdSetCreateSet()
{
  IGRstat retFlag = 0;

  Form    form = cmdInfo->set.form;

  TGRid   mgrID;
  TGRid   setID,treeID;

  TVDctSetName  setName;
  TVDctSetType  setType;

  IGRchar buf[128];

  // Get the name
  vdfrm$GetText(form = form, gadget = VDCT_FORM_SET_G_SET_NAME, txt = buf);
  if (strlen(buf) >= VDCT_SET_NAME_LEN) *(buf+VDCT_SET_NAME_LEN) = 0;
  strcpy(setName,buf);
  if (*setName == 0) {
    vdfrm$SetStatus(form = form,txt = "Enter Set Name");
    goto wrapup;
  }

  // Get The Type
  vdfrm$GetText(form = form, gadget = VDCT_FORM_SET_G_SET_TYPE, txt = buf);
  if (strlen(buf) >= VDCT_SET_TYPE_LEN) *(buf+VDCT_SET_TYPE_LEN) = 0;
  strcpy(setType,buf);
  if (*setType == 0) {
    vdfrm$SetStatus(form = form,txt = "Enter Set Type");
    goto wrapup;
  }

  // Get the manager
  vdct$GetManager(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    vdfrm$SetStatus(form = form,txt = "No Manager!!!");
    goto wrapup;
  }

  
  // Create it
  vdct$CreateSet(mgrID   = &mgrID,
                 setType =  setType,
                 setName =  setName,
                 setID   = &setID);

  if (setID.objid == NULL_OBJID) {
    vdfrm$SetStatus(form = form,txt = "Set Creation Failed");
    goto wrapup;
  }

  sprintf(buf,"Created Set %s.%s",setType,setName);
  vdfrm$SetStatus(form = form,txt = buf);

#if 0
  // Make sure set does not already exist   
  VDatGetSetByName(&mgrID,setType,setName,&setID);
  if (setID.objid != NULL_OBJID) {
    VIg_set_text(form,10,"Set already exists");
    goto wrapup;
  }

  // Create it
  VDatCreateSet(&mgrID,&rdbSetID,setName,&setID);
  if (setID.objid == NULL_OBJID) {
    VIg_set_text(form,10,"Set Creation Failed");
    goto wrapup;
  }

  // Update List
  VIg_set_text(form,10,"Set Created");

  // Now see if tree exists
  VDatRDBGetNodes(&rdbSetID,&rdbNodesID);
  if (rdbNodesID.objid == NULL_OBJID) goto wrapup;

  for(i = 0; VDatGetChildObject(&rdbNodesID,i,&rdbNodeID); i++);
  if (i <= 1) {
    goto set_created;
  }
  i--;
  VDatGetChildObject(&rdbNodesID,i,&rdbNodeID);
  VDatCreateTree(&setID,&rdbNodeID,setName,&treeID);

  if (treeID.objid == NULL_OBJID) {
    VIg_set_text(form,10,"Tree Creation Failed");
    goto wrapup;
  }
  VIg_set_text(form,10,"Set/Tree Created");

set_created:

  // Tell the manager, a new set was added
  VDatCMDMgrAddSet(fl,&setID,setName,setType);

#endif

  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------
 * User changed set type
 */
IGRstat VDatCmdSetNotifyType()
{
  IGRstat retFlag = 0;
  IGRchar buf[128],*p;

  Form form = cmdInfo->set.form;

  // Get type and desc
  vdfrm$GetText(form   = form,
                gadget = VDCT_FORM_SET_G_SET_TYPE,
                txt    = buf);

  // Clean up type
  p = strchr(buf,' ');
  if (p) *p = NULL;
  vdfrm$SetText(form   = form,
                gadget = VDCT_FORM_SET_G_SET_TYPE,
                txt    = buf);

  // Clean desc
  if (p) strcpy(buf,p+1);
  else  *buf = 0;
  vdfrm$SetText(form   = form,
                gadget = VDCT_FORM_SET_G_SET_DESC,
                txt    = buf);

  retFlag = 1;

  return retFlag;
}
/* --------------------------------------------------------
 * Look through config directories for list of sets
 */
FILE *VDctCmdSetOpenListOfSets()
{
  IGRint i;
  IGRchar buf[DI_PATH_MAX];
  FILE *file;

  // Look in local directory
  file = fopen("sets.txt","rt");
  if (file) return file;
  
  // Look in config directory
  for(i = 0; 1; i++) {
    
    // Product specific loading
    *buf = 0;
    ex$get_path( index = i,
		 path  = buf,
		 len   = sizeof(buf),
		 type  = EX_CONFIG_PATH );
    if (*buf == 0) {
      file = NULL;
      return file;
    }
    
    strcat(buf,"config/sets/sets.txt");
        
    file = fopen(buf,"rt");
    if (file != NULL) return file;
  }
}

/* --------------------------------------------------
 * Fills in list of available set types
 */
IGRstat VDctCmdSetFillTypes()
{
  IGRstat retFlag = 0;
  IGRint  row;
  IGRchar buf[128],*p;
  FILE   *file;

  Form   form   = cmdInfo->set.form;
  IGRint gadget = VDCT_FORM_SET_G_SET_TYPE;

  TVDctSetTypeInfo setTypeInfo;

  // Init
  if (traceFlag) printf(">>> VDctCmdSetFillTypes\n");

  // This is very confusing, track down the lockup later
  VIfld_set_list_num_rows(form,gadget,0,0);
  //vdfrm$SetListNumRows(form = form, gadget = gadget, rows = 0);

  vdfrm$SetText(form = form, gadget = gadget, txt = "");

  // Open the list of sets
  file = VDctCmdSetOpenListOfSets();
  if (file == NULL) goto wrapup;
  row = 0;

  // Cycle through
  while(fgets(buf,sizeof(buf),file)) {

    if (!strncmp(buf,"S ",2)) {

      strcpy(buf,buf+2);
      for(p = buf; *p > ' '; p++); *p = 0;
      if (*buf) {

        vdct$GetSetTypeInfo(setType = buf, setTypeInfo = &setTypeInfo);
        if (*setTypeInfo.type) {

          sprintf(buf,"%s %s",setTypeInfo.type,setTypeInfo.desc);
          vdfrm$SetListText(form   = form, 
                            gadget = gadget, 
                            row    = row, 
                            txt    = buf);
          row++;
        }
      }
    }
  }
  fclose(file);

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDctCmdSetFillTypes\n");
  return retFlag;
}

/* -------------------------------------------
 * The notification routine
 */
IGRstat VDctCmdSetNotifyForm()
{
  IGRstat retFlag = 0;

  // Process it
  if (traceFlag) printf(">>> VDctCmdSetNotifyForm\n");
  switch(cmdInfo->gadget) {

  case VDCT_FORM_SET_G_SET_TYPE:
    VDatCmdSetNotifyType();
    break;

  case VDCT_FORM_SET_B_CREATE_SET:
    VDctCmdSetCreateSet();
    break;

  case VDCT_FORM_SET_B_DELETE_SET:
    //VDatCMDSetDeleteSet();
    break;

  case VDCT_FORM_SET_B_RENAME_SET:
    //VDatCMDSetRenameSet();
    break;

  case FI_CANCEL:
    vdfrm$EraseForm(form =  cmdInfo->set.form, 
                    flag = &cmdInfo->set.displayed);
    break;
  }
  retFlag = 1;

//wrapup:
  if (traceFlag) printf("<<< VDctCmdSetNotifyForm\n");
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDctCmdSetActivateForm()
{
  IGRstat retFlag = 0;

  // Ignore if already active for now
  if (cmdInfo->set.displayed) {
    retFlag = 1;
    goto wrapup;
  }
  if (traceFlag) printf(">>> VDctCmdSetActivateForm\n");

  // Display
  vdfrm$DisplayForm(form =  cmdInfo->set.form, 
                    flag = &cmdInfo->set.displayed);

  // Fills in list of available sets
  VDctCmdSetFillTypes();

  // Fills in active set info
  // VDatCMDSetActivateSet(fl);

  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDctCmdSetActivateForm\n");
  return retFlag;
}

/* --------------------------------------------------------
 * Called on startup
 */
IGRstat VDctCmdSetInit(TVDctCmdInfo *a_cmdInfo)
{
  IGRstat retFlag = 0;

  traceFlag = 0;
  if (traceFlag) printf(">>> VDctCmdSetInit\n");

  cmdInfo = a_cmdInfo;
  retFlag = 1;

  if (traceFlag) printf("<<< VDctCmdSetInit\n");
  return retFlag;
}

end implementation VDctBase;
