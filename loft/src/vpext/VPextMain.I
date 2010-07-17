/* $Id: VPextMain.I,v 1.1.1.1 2001/01/04 21:11:58 cvs Exp $  */

/***************************************************************************
 * I/EFP
 *
 * File:        vpext/VPextMain.I
 *
 * Description: Extract For Production
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VPextMain.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:11:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/05/24  18:39:42  pinnacle
# ah
#
# Revision 1.7  1998/12/05  23:38:50  pinnacle
# ah
#
# Revision 1.6  1998/12/02  14:58:04  pinnacle
# ah
#
# Revision 1.5  1998/11/29  14:41:50  pinnacle
# ah
#
# Revision 1.4  1998/11/14  14:09:48  pinnacle
# ah
#
# Revision 1.3  1998/06/14  16:13:52  pinnacle
# ah
#
# Revision 1.2  1998/06/04  13:19:16  pinnacle
# ah
#
# Revision 1.1  1998/06/02  17:25:42  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/15/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDtypedef.h"
#include "VDfrm.h"
#include "VDobj.h"
#include "VDvla.h"
#include "VDsa.h"
#include "VDppl1.h"

#include "VDatMaster.h"

#include "VPextCmd.h"
#include "VPpdf.h"

#include "dpmacros.h"

static int traceFlag;
    
/* --------------------------------------------------------
 * Generates file name based on selected set
 * Accesses custom ppl
 */
IGRstar VPextCMD_FillFileName(TVPextCMD_Info *info)
{
  IGRstat retFlag = 0;

  IGRchar what[128];
  IGRchar name[128];
  IGRchar hull[128];
  
  Form    form = info->ext.form;

  TGRid   pplID;
  IGRint  pplRET;

  // Ignore if have the default file name
  vdfrm$GetText(form = form, gadget = VPEXT_FORM_G_FILE_NAME, txt = name);
  if (!strcmp(name,"ProdData")) goto wrapup;

  // Determine type of file
  vdfrm$GetText(form = form, gadget = VPEXT_FORM_G_FILE_WHAT, txt = what);
  
  // Determine hull
  vdfrm$GetText(form = form, gadget = VPEXT_FORM_G_FILE_HULL, txt = hull);
  
  // Load the ppl
  vdppl$Load(name = "VPextract", pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(
    pplID = &pplID,
    name  = "SET_ID",
    size  = sizeof(TGRid),
    data  = (IGRchar*)&info->setID);

  vdppl$SetData(
    pplID = &pplID,
    name  = "FILE_WHAT",
    size  =  16,
    data  =  what);

  vdppl$SetData(
    pplID = &pplID,
    name  = "FILE_HULL",
    size  =  16,
    data  =  hull);

  vdppl$Run(pplID = &pplID, name = "genFileName", ret = &pplRET);

  vdppl$GetData(
    pplID = &pplID,
    name  = "FILE_NAME",
    size  = 128,
    data  = name);

  vdppl$Delete(pplID = &pplID);

  // Display it
  vdfrm$SetText(form = form, gadget = VPEXT_FORM_G_FILE_NAME, txt = name);

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Dump out XML Based file
 */
IGRstar VPextCMD_NotifyRun(TVPextCMD_Info *info)
{
  IGRstat retFlag = 1;

  Form    form   = info->ext.form;

  FILE   *fileBin = NULL;

  IGRchar hull       [ 64];
  IGRchar fileStat   [ 64];
  IGRchar fileName   [256];
  IGRchar fileNameBin[256];
  
  IGRchar buf[256];
  
  // Init
  *fileNameBin = 0;

  VPextInitMasterInfo();
  
  // Make sure set was picked
  if (info->setID.objid == NULL_OBJID) {

    // No sets at all!
    vdfrm$SetText(form = form, txt = "Pick a set first");
    goto wrapup;
  }
  
  // Get the output file name
  vdfrm$GetText(form   = form, 
		gadget = VPEXT_FORM_G_FILE_NAME, 
		txt    = fileName);

  if (*fileName == 0) {
    vdfrm$SetText(form = form, txt = "Need to specify a file name");
    goto wrapup;
  }

  // Load the ppl extract routine
  vdppl$Load(name = "VPextract", pplID = &info->pplID);
  if (info->pplID.objid == NULL_OBJID) {
    sprintf(buf,"Could not load PPL '%s'\n","VPextract");
    vdfrm$SetText(form = form, txt = buf);
    goto wrapup;
  }

  // Store some data
  vdppl$SetData(
    pplID = &info->pplID,
    name  = "SET_ID",
    size  = sizeof(TGRid),
    data  = (IGRchar*)&info->setID);

  vdppl$SetData(
    pplID = &info->pplID,
    name  = "FILE_NAME",
    size  = 128,
    data  = fileName);

  vdfrm$GetText(form = form, gadget = VPEXT_FORM_G_FILE_STAT, txt = fileStat);
  vdppl$SetData(
    pplID = &info->pplID,
    name  = "FILE_STAT",
    size  = 16,
    data  = fileStat);
  
  vdfrm$GetText(form = form, gadget = VPEXT_FORM_G_FILE_HULL, txt = hull);
  vdppl$SetData(
    pplID = &info->pplID,
    name  = "FILE_HULL",
    size  =  16,
    data  =  hull);

  // Add extension
  sprintf(fileNameBin,"%s.pdf",fileName);

  // Open It
  fileBin = fopen(fileNameBin,"wb");
  if (fileBin == NULL) {
    sprintf(buf,"Could not open %s for binary writing",fileNameBin);
    vdfrm$SetText(form = form, txt = buf);
    goto wrapup;
  }
  VPpdfSetBinFile(fileBin);

  // Master root object
  VPpdfWriteObjBeg (PDF_OBJ_ROOT);

  // Write out Setup Info
  VPextCMD_ExtractSetup(info);

  // Write out Ship Info
  VPextCMD_ExtractShip(info);

  // Want tree?
  VPextCMD_ExtractTree(info);

  // Want Pieces
  VPextCMD_ExtractProd(info);
  
  // Clean up
  VPpdfWriteObjEnd(PDF_OBJ_ROOT);

  // Close up
  if (fileBin) {
    fclose(fileBin);
    fileBin = NULL;
    VPpdfSetBinFile(NULL);
  }

  // Now verify the binary file just written
  VPpdfVerifyFile(fileNameBin);
  
  // Done
  retFlag = 1;

wrapup:

  // Close up (in case of error)
  if (fileBin) {
    fclose(fileBin);
    VPpdfSetBinFile(NULL);
  }

  VPextDeleteMasterInfo();
  return retFlag;
}

/* --------------------------------------------------------
 * Tree was picked
 */
IGRstar VPextCMD_NotifyTree(TVPextCMD_Info *info)
{
  IGRstat retFlag = 0;
  
  Form   form = info->ext.form;

  VDatFormNotifyTree(form,VPEXT_FORM_G_TREE,NULL);

  retFlag = 1;
  
  return retFlag;
}

/* --------------------------------------------------------
 * Set was picked
 */
IGRstar VPextCMD_NotifySets(TVPextCMD_Info *info)
{
  IGRstat retFlag = 0;
  
  Form   form = info->ext.form;
  IGRint gadget = VPEXT_FORM_G_SETS;

  IGRint row,pos;

  // Get selected row
  row = -1;
  VIfld_get_active_row(form,gadget,&row,&pos);
  if (row < 0) goto wrapup;
  
  // Get the set
  vdfrm$GetText(form   = form, 
		gadget = gadget, 
		row    = row,
		col    = 3,
		objID  = &info->setID);

  // vdobj$Print(objID = &info->setID);

  // Display the tree
  VDatFormFillTree(form,VPEXT_FORM_G_TREE,&info->setID);

  // Fill in the filename
  VPextCMD_FillFileName(info);
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Move to vdbt stuff later 
 */
IGRstat VDbtGetAllSetsInOS(VDosnum osNum, TVDvlaID *setVLA)
{
  IGRstat retFlag = 0;
  
  TGRid mgrID;
  TGRid setsID;
  TGRid setID;
  
  IGRint i;
  
  if (traceFlag) {
    printf(">>> VDbtGetAllSetsInOS %d\n",osNum);
  }

  // Get the manager
  vdat$GetSetMgr(osnum = osNum, mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;

  // Get the sets
  VDatGetSets(&mgrID,&setsID);
  if (setsID.objid == NULL_OBJID) goto wrapup;

  if (traceFlag) {
    vdobj$Print(objID = &setsID);
  }
  
  // Cycle Through
  for(i = 0; VDatGetChildObject(&setsID,i,&setID); i++) {

    VDvlaID_Append(setVLA,&setID);
  }
  
  retFlag = 1;

wrapup:
  return retFlag;
}

IGRstat VDbtGetAllSets(TVDvlaID *setVLA)
{
  IGRstat retFlag = 0;

  VDosnum osNum;
  IGRint  osFlag = 1;
  IGRchar osName[256];
  
  // Just cycle through
  for(osNum = 2; osFlag; osNum++) {

    *osName = 0;
    om$os_number_to_internal_name (osnum = osNum, osname = osName);
    if (*osName == 0) osFlag = 0;
    else {
      
      VDbtGetAllSetsInOS(osNum, setVLA);
    }
    
  }

  retFlag = 1;

//wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Fill in one set row
 */
IGRstar VPextCMD_FillSet(TVPextCMD_Info *info,
			 TGRid  *setID,
			 IGRint *row)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  Form   form = info->ext.form;
  IGRint gadget = VPEXT_FORM_G_SETS;

  IGRchar buf[128],*p;
  
  TGRid   setTypeID;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> VPextCMD_FillSet\n");
    vdobj$Print(objID = setID);
  }

  // Only want trees
  sts = VDatIsSetATree(setID);
  if (!(sts & 1)) goto wrapup;

  // OS Name
  strcpy(buf,OM_GA_OSDs[setID->osnum]->name);
  p = strrchr(buf,'/');
  if (p) strcpy(buf,p+1);

  vdfrm$SetText(form   = form, 
		gadget = gadget, 
		row    = *row,
		col    = 0,
		txt    = buf);

  // Show name for now
  VDatGetBaseName(setID,buf);
  vdfrm$SetText(form   = form, 
		gadget = gadget, 
		row    = *row,
		col    = 1,
		txt    = buf);

  // Get the set type
  VDatRDBGetSet  (setID,&setTypeID);
  VDatGetBaseName(&setTypeID,buf);

  vdfrm$SetText(form   = form, 
		gadget = gadget, 
		row    = *row,
		col    = 2,
		txt    = buf);

  // Store the id
  vdfrm$SetText(form   = form, 
		gadget = gadget, 
		row    = *row,
		col    = 3,
		objID  = setID);

  // Done
  *row = *row + 1;
  retFlag = 1;
  
wrapup:
  // Say Bi
  if (traceFlag) {
    printf("@@@ VPextCMD_FillSet\n");
  }
  return retFlag;
}

/* -----------------------------------------------------
 * Fill in the list of sets
 */
IGRstar VPextCMD_FillSets(TVPextCMD_Info *info)
{
  IGRstat retFlag = 0;

  TVDvlaID setVLA;

  IGRint i,row;
  TGRid  setID;

  Form form = info->ext.form;
  IGRint gadget = VPEXT_FORM_G_SETS;

  // Say Hi
  if (traceFlag) {
    printf(">>> VPextCMD_FillSets\n");
  }
  
  // Get list of all visible sets
  VDvlaID_Construct(&setVLA);
  VDbtGetAllSets(&setVLA);

  // Init the form
  row = 0;
  vdfrm$SetText(form = form, gadget = gadget, rows = 0);
  
  // Cycle through
  for(i = 0; VDvlaID_GetAt(&setVLA,&setID,i); i++) {

    VPextCMD_FillSet(info,&setID,&row);
    
  }
  
//wrapup:

  VDvlaID_Delete(&setVLA);

  // Say Bi
  if (traceFlag) {
    printf("@@@ VPextCMD_FillSets\n");
  }
  return retFlag;
}

/* -----------------------------------------------------
 * An object was selected
 */
#argsused
IGRstar VPextCMD_NotifyObject(TVPextCMD_Info *info, TGRobj_env *setOE)
{
  IGRstat  retFlag = 0;
  TVDvlaOE setVLA;
  
  // Get the objects
  VDvlaOE_Construct(&setVLA);
  VDahGetFenceVLA(setOE, &setVLA);

  // Send them onwards
  // VDatCMDLeafNotifyObject(fl,&setVLA);

  retFlag = 1;
//wrapup:
  VDvlaOE_Delete(&setVLA);
  return retFlag;
}

/* -------------------------------------------
 * The notification routine, called by the ppl
 */
IGRstar VPextCMD_NotifyForm(TVPextCMD_Info *info)
{
  IGRstat retFlag = 0;

  // Arg Check
  if (info == NULL) {
    printf("Form notification reached with NULL Data\n");
    goto wrapup;
  }

  // Form has all global data
  if (info->form == NULL) {
    printf("NULL Form Pointer\n");
    goto wrapup;
  }

  // Should be the manager itself
  if (info->form != info->ext.form) goto wrapup;
  
  switch(info->gadget) {

  case VPEXT_FORM_G_FILE_NAME:
  case VPEXT_FORM_G_FILE_WHAT:
  case VPEXT_FORM_G_FILE_HULL:
    VPextCMD_FillFileName(info);    
    retFlag = 1;
    break;

  case VPEXT_FORM_G_SETS:
    retFlag = VPextCMD_NotifySets(info);
    break;

  case VPEXT_FORM_G_TREE:
    retFlag = VPextCMD_NotifyTree(info);
    break;

  case FI_EXECUTE:
    retFlag = VPextCMD_NotifyRun(info);
    break;

  case FI_ACCEPT:
    retFlag = VPextCMD_NotifyRun(info);
    if (retFlag & 1) retFlag = FI_CANCEL;
    break;

  case FI_CANCEL:
    retFlag = FI_CANCEL;  // Will bubble up and shutdown command
    break;

  default:
    goto wrapup;
  }

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called by ppl to start everything up
 * info has been cleard
 * forms have been created
 */
IGRstar VPextCMD_Init(TVPextCMD_Info *info)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRchar buf[128];
  IGRint  col;
  
  Form form = info->ext.form;
  
  /* Need to be logged in */
#if 0
  sts = VDsaVerifyLogin();
  if (!(sts & 1)) {
    //printf("Logging in\n");
    //NFMlog_in("ahundiak","qwe.poi","pdme_c6017","PDM");
  }
  sts = VDsaVerifyLogin();
  if (!(sts & 1)) {
    UI_status("Please log into PDM first.");
    goto wrapup;
  }
#endif

  traceFlag = 0;
  
  if (traceFlag) {
    printf("----------------------------------------\n");
    printf(">>> VPextCMD_Init\n");
  }
  
  /* List of locate classes */
  sts = VPextCMD_ClassList(&info->classList);
  if (!(sts & 1)) {
    UI_status("Problem getting locatable classes");
    goto wrapup;
  }

  /* Set the objid's to null
   */
  info->ext.id.objid = NULL_OBJID;
  info->setID.objid  = NULL_OBJID;
  
  // Position from file
  vdfrm$LoadFormPosition(form = form);

  // Display manager
  vdfrm$DisplayForm(form = form, flag = &info->ext.dis);
  info->ext.act = 1;

  /* Erase any existing highlites */
  sts = dp$erase_hilite(msg = &msg);

  /* List of sets to choose from */
  VPextCMD_FillSets(info);

   // Pick the first set by default
  vdfrm$GetText(form   = form,
		gadget = VPEXT_FORM_G_SETS,
		col    = 0,
		row    = 0,
		txt    = buf);

  if (*buf) {

    // What a pain
    for(col = 0; col < 3; col++) {
      
      vdfrm$GetText(form   = form,
		    gadget = VPEXT_FORM_G_SETS,
		    col    = col,
		    row    = 0,
		    txt    = buf);

      vdfrm$SetText(form   = form,
		    gadget = VPEXT_FORM_G_SETS,
		    col    = col,
		    row    = 0,
		    txt    = buf,
		    sel    = 1);
    }
    
    FIfld_set_active_row(form,VPEXT_FORM_G_SETS,0,0);
    VPextCMD_NotifySets(info);

  }
  
  /* Done */
  UI_status("Extract For Production Ready");
  retFlag = 1;

  info->initedOK = 1;

wrapup:
  if (traceFlag) {
    printf("@@@ VPextCMD_Init\n");
  }
  return retFlag;
}

/* --------------------------------------
 * Called by ppl to shut things down
 * Not much to do anymore
 */
IGRstar VPextCMD_Delete(TVPextCMD_Info *info)
{
  IGRstat retFlag = 0;
  IGRstat msg;

  // Un hilite
  dp$erase_hilite(msg = &msg);

  // Store position in file
  vdfrm$SaveFormPosition(form = info->ext.form);

  // Delete them
  vdfrm$DeleteForm(form = info->ext.form);

  retFlag = 1;

  return retFlag;
}

IGRstar VPextCMD_Wakeup(TVPextCMD_Info *info)
{
  IGRstat retFlag = 1;

  /* Ignore first one */
  if (info->enableWakeup == 0) goto wrapup;

  /* Wakup all active forms, need to deal with hilite later */
  if (info->ext.act)   vdfrm$DisplayForm(form = info->ext.form);

  retFlag = 1;

wrapup:
  return retFlag;
}

#argsused
IGRstar VPextCMD_Sleep(TVPextCMD_Info *info)
{
  return 1;
}

/* -----------------------------------------------------------
 * Allowable locate classes
 */
static VDclassid classListIDs[8];

IGRstar VPextCMD_ClassList(OM_S_CLASSLIST *classList)
{
  IGRstat retFlag = 0;
  int i = 0;

  classListIDs[i] = 0;
  om$get_classid( 
    classname = "VSplate",
    p_classid = &classListIDs[i]
  ) ;
  if (classListIDs[i] != 0) i++;

  classListIDs[i] = 0;
  om$get_classid( 
    classname = "VSbeam",
    p_classid = &classListIDs[i]
  ) ;
  if (classListIDs[i] != 0) i++;
  /*
  classListIDs[i] = 0;
  om$get_classid( 
    classname = "VDequipment",
    p_classid = &classListIDs[i]
  ) ;
  if (classListIDs[i] != 0) i++;
  */
  classList->p_classes = classListIDs;
  classList->w_count   = i;
  classList->w_flags   = OM_CLST_subclass;

  retFlag = 1;

  return retFlag;
}

end implementation VDbtBase;




