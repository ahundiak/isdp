/* $Id: VDbtPMCmd.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbt/piece_mark/VDbtPMCmd.I
 *
 * Description: Manager Form
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDbtPMCmd.I,v $
 * Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 * Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/04/23  23:33:06  pinnacle
# ah
#
# Revision 1.1  1998/04/22  23:40:16  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/21/98  ah      creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDmaster.h"
#include "VDfrm.h"
#include "VDobj.h"
#include "VDsa.h"

#include "VDbtPMCmd.h"

#include "vdparmacros.h"

#define VDBT_FORM_PM_L_PIECES 12
#define VDBT_FORM_PM_G_NEXT   14

#define VDBT_FORM_PM_B_CLEAR  15
#define VDBT_FORM_PM_B_GEN    16
#define VDBT_FORM_PM_T_SHOW   17


/* --------------------------------------------
 * Stores piece marks
 */
IGRstar VDbtCMD_PM_StoreMarks(TVDbtCMD_PM_Info *info)
{
  IGRstat retFlag = 0;
  IGRstat msg;
  
  Form   form   = info->pm.form;
  IGRint gadget = VDBT_FORM_PM_L_PIECES;
  
  IGRint  row,rows;

  IGRchar buf[1024];
  
  TACrg_coll rg;
  TGRid   objID;
  
  // Init
  strcpy(rg.name,"piece_mark");
  rg.desc.type = AC_ATTRIB_DOUBLE;
  
  // Loop through
  vdfrm$GetText(form = form, gadget = gadget, rows = &rows);

  for(row = 0; row < rows; row++) {

    vdfrm$GetText(form = form, gadget = gadget, row = row, col = 1, txt = buf);
    vdfrm$GetText(form = form, gadget = gadget, row = row, col = 2, objID = &objID);

    if ((*buf != 0) && (objID.objid != NULL_OBJID)) {
      
      rg.desc.value.att_exp = atof(buf);

      vd$modUsrAttributes(sts     = &msg,
			  object  = objID,    
			  nbAttrs = 1,
			  att     = &rg);
    }
  }

  retFlag = 1;
  
  return retFlag;
}

/* --------------------------------------------
 * Clears all piece marks
 */
IGRstar VDbtCMD_PM_ClearMarks(TVDbtCMD_PM_Info *info)
{
  IGRstat retFlag = 0;

  Form   form   = info->pm.form;
  IGRint gadget = VDBT_FORM_PM_L_PIECES;
  
  IGRint  row,rows;
  
  // Loop through
  vdfrm$GetText(form = form, gadget = gadget, rows = &rows);
  for(row = 0; row < rows; row++) {
    vdfrm$SetText(form = form, gadget = gadget, row = row, col = 1);
  }
  
  retFlag = 1;
  return retFlag;
}

/* --------------------------------------------
 * Sequentialy assigns piece marks
 */
IGRstar VDbtCMD_PM_AssignMarks(TVDbtCMD_PM_Info *info)
{
  IGRstat retFlag = 0;

  Form   form   = info->pm.form;
  IGRint gadget = VDBT_FORM_PM_L_PIECES;

  IGRchar buf[1024];
  IGRint  mark;
  
  IGRint  row,rows;

  // Get the starting mark
  vdfrm$GetText(form = form, gadget = VDBT_FORM_PM_G_NEXT, txt = buf);
  mark = atoi(buf);
  if (mark < 1) mark = 1;
  
  // Loop through
  vdfrm$GetText(form = form, gadget = gadget, rows = &rows);
  for(row = 0; row < rows; row++) {
    *buf = 0;
    vdfrm$GetText(form = form, gadget = gadget, row = row, col = 1, txt = buf);
    
    if (*buf == 0) {
      sprintf(buf,"%d",mark);
      vdfrm$SetText(form = form, gadget = gadget, row = row, col = 1, txt = buf);
      mark++;
    }
  }
  
  retFlag = 1;
  return retFlag;
}

/* --------------------------------------------
 * Items were picked with fence
 */
IGRstar VDbtCMD_PM_NotifyObjectFence(TVDbtCMD_PM_Info *info, TGRobj_env *fenceOE)
{
  IGRstat retFlag = 0;
  
  TGRobj_env *objOEs = NULL;

  IGRint objCNT = 0;

  IGRint i;
  
  // Don't do one without the other
  IGRint  response = 0;
  IGRchar response_data[1024];
  
  *response_data = 0;
  
  as$start_fence(set       = &fenceOE->obj_id,
		 set_env   = &fenceOE->mod_env,
		 nb_obj    = &objCNT,
		 response  = &response,
		 response_data = response_data,
       		 p_obj_env = &objOEs);

  if (response != EX_DATA) goto wrapup;
  
  for(i = 0; i < objCNT; i++) {

    VDbtCMD_PM_NotifyObject(info,&objOEs[i]);
    
  }
  ASend_fence(); // Frees objOEs
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * An object was selected
 */
IGRstar VDbtCMD_PM_NotifyObject(TVDbtCMD_PM_Info *info, TGRobj_env *objOE)
{
  IGRstat  retFlag = 0;

  TGRid    objID;
  
  IGRint   row,rows;

  Form   form   = info->pm.form;
  IGRint gadget = VDBT_FORM_PM_L_PIECES;
  
  IGRchar   buf[1024];
  IGRdouble dbl;
  
  // Arg check
  if (objOE == NULL) goto wrapup;

  // Get the id
  objID = objOE->obj_id;
  if (objID.objid == NULL_OBJID) goto wrapup;
  
  // Turn form on
  if (info->pm.dis == 0) {
    vdfrm$DisplayForm(form = info->pm.form, flag = &info->pm.dis);
    info->pm.act = 1;
  }

  // Process it
  vdfrm$GetText(form = form, gadget = gadget, rows = &rows);
  row = rows;

  // Display name
  vdobj$Get(objOE = objOE, disName = buf);
  vdfrm$SetText(form = form, gadget = gadget, row = row, col = 0, txt = buf);
  
  /* ---------------------------------------------------------------------
   * Non-standard piece marks are currently stored as doubles
   * Standard piece marks are text
   * Need to check posting doubles to text
   */
  dbl = -666;
  vdsa$GetStruct(objOE = objOE, name = "piece_mark", txt = buf, dbl = &dbl);

  if (dbl > 0.0) {
    sprintf(buf,"%.f",dbl);
  }
  
  // 
  vdfrm$SetText(form = form, gadget = gadget, row = row, col = 1, txt = buf);

  // Store the id for later
  vdfrm$SetText(form = form, gadget = gadget, row = row, col = 2, objOE = objOE);

  retFlag = 1;

wrapup:

  return retFlag;
}

/* -------------------------------------------
 * The notification routine, called by the ppl
 */
#argsused
IGRstar VDbtCMD_PM_NotifyForm(TVDbtCMD_PM_Info *info)
{
  IGRstat retFlag = 0;
  //IGRstat msg;

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

  // Should be the main itself
  if (info->form != info->pm.form) goto wrapup;
  
  switch(info->gadget) {

  case FI_CANCEL:
    retFlag = FI_CANCEL;  // Will bubble up and shutdown command
    break;

  case FI_ACCEPT:
    retFlag = VDbtCMD_PM_StoreMarks(info);
    retFlag = FI_CANCEL;
    break;
    
  case VDBT_FORM_PM_B_CLEAR:
    retFlag = VDbtCMD_PM_ClearMarks(info);
    break;

  case VDBT_FORM_PM_B_GEN:
    retFlag = VDbtCMD_PM_AssignMarks(info);
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
IGRstar VDbtCMD_PM_Init(TVDbtCMD_PM_Info *info)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  //TGRid mgrID;
  //TGRid setID;

  /* List of locate classes */
  sts = VDbtCMD_PM_ClassList(&info->classList);
  if (!(sts & 1)) {
    UI_status("Problem getting locatable classes");
    goto wrapup;
  }

  /* Set the objid's to null
   */
  info->pm.id.objid   = NULL_OBJID;

  // Position from file
  vdfrm$LoadFormPosition(form = info->pm.form);

  // Display manager
  // vdfrm$DisplayForm(form = info->pm.form, flag = &info->pm.dis);
  // info->pm.act = 1;

  /* Erase any existing highlites */
  sts = dp$erase_hilite(msg = &msg);

  /* Done */
  UI_status("Piece Mark Ready");
  retFlag = 1;

  info->initedOK = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called by ppl to shut things down
 */
#argsused
IGRstar VDbtCMD_PM_Delete(TVDbtCMD_PM_Info *info)
{
  IGRstat retFlag = 0;
  IGRstat msg;

  // Un hilite
  dp$erase_hilite(msg = &msg);

  // Store position in file
  vdfrm$SaveFormPosition(form = info->pm.form);

  // Delete them
  vdfrm$DeleteForm(form = info->pm.form);

  // Destroy the vla
  if(info->objVLA != NULL) {
    VDvlaOE_Delete(info->objVLA);
  }
  
  retFlag = 1;

  return retFlag;
}

#argsused
IGRstar VDbtCMD_PM_Wakeup(TVDbtCMD_PM_Info *info)
{
  IGRstat retFlag = 1;

  /* Ignore first one */
  if (info->enableWakeup == 0) goto wrapup;

  /* Wakup all active forms, need to deal with hilite later */
  if (info->pm.act)   vdfrm$DisplayForm(form = info->pm.form);

  retFlag = 1;

wrapup:
  return retFlag;
}

#argsused
IGRstar VDbtCMD_PM_Sleep(TVDbtCMD_PM_Info *info)
{
  return 1;
}

static VDclassid classListIDs[8];

IGRstar VDbtCMD_PM_ClassList(OM_S_CLASSLIST *classList)
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




