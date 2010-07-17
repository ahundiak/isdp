/* $Id: VSbaMod2.I,v 1.1.1.1 2001/01/04 21:10:13 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbmaxis/VSbaMod2.I
 *
 * Description: Modify Stiffener Axis
 *	        Misc routines 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbaMod2.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:13  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/02/19  18:09:10  pinnacle
# tr179802334
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/04/06  14:24:48  pinnacle
# Channel Macros
#
# Revision 1.2  1998/03/22  14:57:58  pinnacle
# Clipper Warnings
#
# Revision 1.1  1998/03/22  14:03:42  pinnacle
# CR179800676
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 03/22/98  ah        CR179800676 Modify Stiffener Axis
 *    ""               CR179800677 Set axis orientation
 * 04/06/98  ah        Channel macros moved to VDchn.h
 * 02/19/99  ah        TR179802334 Add twisted stiffeners to filter
 ***************************************************************************/

class implementation VSbeamAxis;

#include "VDmaster.h"
#include "VDchn.h"

#include "VDahFrm.h"
#include "VSbaMod.h"

extern VDclassid OPP_VSstfBeam_class_id;
extern VDclassid OPP_VStwsBeam_class_id;

/* ------------------------------------------------
 * Called when new extend function is needed
 * returns true if object needs recompute
 */
IGRstat VSbaCMD_ModExecuteExtend(TVSbaModInfo *info,
				 IGRchar       cmdKey,
				 TGRid        *axisID)
{
  IGRstat retFlag = 1;
  IGRstat sts,msg;
  
  TVSbaToggles frm,ins;
  
  // Get data from form
  VSbaCMD_ModGetToggles(info,&frm);
  
  // Get data from object
  sts = om$send(msg = message VSbeamAxis.VSgetExtend(&msg,&ins.ext1,&ins.ext2),
		senderid = NULL_OBJID,
		targetid = axisID->objid,
		targetos = axisID->osnum);  

  // Three cases
  switch(cmdKey) {
    
  case 'B':
    if ((frm.ext1 == ins.ext1) && (frm.ext2 == ins.ext2)) goto wrapup;
    break;
    
  case 'C':
    if (frm.ext1 == ins.ext1) goto wrapup;
    frm.ext2 = ins.ext2;
    break;
    
  case 'D':
    if (frm.ext2 == ins.ext2) goto wrapup;
    frm.ext1 = ins.ext1;
    break;
  }
  
  // Change the object
  sts = om$send(msg = message VSbeamAxis.VSputExtend(&msg,frm.ext1,frm.ext2),
		senderid = NULL_OBJID,
		targetid = axisID->objid,
		targetos = axisID->osnum);  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Called when old extend function is needed
 * returns true if object needs recompute
 */
#argsused
IGRstat VSbaCMD_ModExecuteExt(TVSbaModInfo *info,
			      IGRchar       cmdKey,
			      TGRid        *axisID)
{
  IGRstat retFlag = 1;
  IGRstat sts,msg;
  
  TVSbaToggles frm,ins;
  
  // Get data from form
  VSbaCMD_ModGetToggles(info,&frm);
  
  // Get data from object
  sts = om$send(msg = message VSbeamAxis.VSgetExtendFlag(&msg,&ins.ext),
		senderid = NULL_OBJID,
		targetid = axisID->objid,
		targetos = axisID->osnum);  

  if (frm.ext == ins.ext) goto wrapup;
    
  // Change the object
  sts = om$send(msg = message VSbeamAxis.VSputExtendFlag(&msg,frm.ext),
		senderid = NULL_OBJID,
		targetid = axisID->objid,
		targetos = axisID->osnum);  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Called for parameterize function
 * returns true if object needs recompute
 */
#argsused
IGRstat VSbaCMD_ModExecutePar(TVSbaModInfo *info,
			      IGRchar       cmdKey,
			      TGRid        *axisID)
{
  IGRstat retFlag = 1;
  IGRstat sts,msg;
  
  TVSbaToggles frm,ins;
  
  // Get data from form
  VSbaCMD_ModGetToggles(info,&frm);
  
  // Get data from object
  sts = om$send(msg = message VSbeamAxis.VSgetByCurve(&msg,&ins.par),
		senderid = NULL_OBJID,
		targetid = axisID->objid,
		targetos = axisID->osnum);  

  if (frm.par == ins.par) goto wrapup;
    
  // Change the object
  sts = om$send(msg = message VSbeamAxis.VSputByCurve(&msg,frm.par),
		senderid = NULL_OBJID,
		targetid = axisID->objid,
		targetos = axisID->osnum);  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Called for switchinh plate side
 * returns true if object needs recompute
 */
#argsused
IGRstat VSbaCMD_ModExecuteSide(TVSbaModInfo *info,
			       IGRchar       cmdKey,
			       TGRid        *axisID)
{
  IGRstat retFlag = 1;
  IGRstat sts,msg;
  
  TVSbaToggles frm,ins;
  
  // Get data from form
  VSbaCMD_ModGetToggles(info,&frm);
  
  // Get data from object
  sts = om$send(msg = message VSbeamAxis.VSgetPlateSide(&msg,&ins.side),
		senderid = NULL_OBJID,
		targetid = axisID->objid,
		targetos = axisID->osnum);  

  if (frm.side == ins.side) goto wrapup;
    
  // Change the object
  sts = om$send(msg = message VSbeamAxis.VSputPlateSide(&msg,frm.side),
		senderid = NULL_OBJID,
		targetid = axisID->objid,
		targetos = axisID->osnum);  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Make the toggles easier
 */
IGRstar VSbaCMD_ModGetToggles(TVSbaModInfo *info, TVSbaToggles *tog) 
{
  IGRstat retFlag = 0;
  Form form = info->form;
  
  VIg_get_state(form,VSBA_FORM_MOD_T_SIDE,&tog->side);
  VIg_get_state(form,VSBA_FORM_MOD_T_EXT, &tog->ext);
  VIg_get_state(form,VSBA_FORM_MOD_T_EXT1,&tog->ext1);
  VIg_get_state(form,VSBA_FORM_MOD_T_EXT2,&tog->ext2);
  VIg_get_state(form,VSBA_FORM_MOD_T_PAR, &tog->par);

  retFlag = 1;
  return retFlag;
}
  
IGRstar VSbaCMD_ModSetToggles(TVSbaModInfo *info, TVSbaToggles *tog) 
{
  IGRstat retFlag = 0;
  Form form = info->form;
  
  VIg_set_state(form,VSBA_FORM_MOD_T_SIDE,tog->side);
  VIg_set_state(form,VSBA_FORM_MOD_T_EXT, tog->ext);
  VIg_set_state(form,VSBA_FORM_MOD_T_EXT1,tog->ext1);
  VIg_set_state(form,VSBA_FORM_MOD_T_EXT2,tog->ext2);
  VIg_set_state(form,VSBA_FORM_MOD_T_PAR, tog->par);

  retFlag = 1;
  return retFlag;
}
  

/* ---------------------------------------
 * Recursive routine to find VSbeamAxis
 * In heirarchy
 * Normally, one would use VSgetOperationHistory to extract the same
 * Information, just curious to see how it all works
 */
IGRstar VSbaGetBeamAxis(TGRobj_env *stiffOE, TGRobj_env *axisOE)
{
  IGRstat retFlag = 0;

  VDclassid classID;

  TGRobj_env objOE;
  TGRid      srcID;

  // Check have object
  if (stiffOE->obj_id.objid == NULL_OBJID) goto wrapup;

  // Get the class id
  om$get_classid(
    objid = stiffOE->obj_id.objid,
    osnum = stiffOE->obj_id.osnum,
    p_classid = &classID
  );

  // See if reached the source beam or
  // Tr179802334 Twisted beam
  if ((classID == OPP_VSstfBeam_class_id) || (classID == OPP_VStwsBeam_class_id)) {

    /* Second parent is an ACpretend to the beam axis
     * we want the beam axis itself and not a foot
     * so we cannot just use get parent
     */
    vdchn$Get(il_objOE  = stiffOE, 
	      ic_IDX    = VDCHN_IDX_PARENT,
	      ir_objIDX = 1,
	      or_objID  = &srcID);
    
    vdchn$Get(il_objID  = &srcID, 
	      ic_IDX    = VDCHN_IDX_PARENT,
	      ir_objIDX = 0,
	      or_objID  = &axisOE->obj_id);
    
    if (axisOE->obj_id.objid == NULL_OBJID) goto wrapup;

    // Should always be in the same space as the stiffener
    axisOE->mod_env = stiffOE->mod_env;

    // Check the class id just to be sure
    om$get_classid(
		   objid = axisOE->obj_id.objid,
		   osnum = axisOE->obj_id.osnum,
		   p_classid = &classID
		   );
    if (classID != OPP_VSbeamAxis_class_id) {
      printf("Second parent of a stiffener is not a beam axis!\n");
      vdbro$PrintObject(objOE = stiffOE);
      vdbro$PrintObject(objOE = axisOE);
      axisOE->obj_id.objid = NULL_OBJID;
      goto wrapup;
    }
    
    /* Got it */
    retFlag = 1;
    goto wrapup;
    
  }

  // 1st parent will be the next beam on chain
  VDahGetParent(stiffOE,0,&objOE);
  if (objOE.obj_id.objid == NULL_OBJID) goto wrapup;

  retFlag = VSbaGetBeamAxis(&objOE,axisOE);

wrapup:
  if (retFlag != 1) {
    axisOE->obj_id.objid = NULL_OBJID;
  }
  return retFlag;
}

/* --------------------------------------------
 * Utility for getting a parent then 
 * changing the id into an oe
 */
IGRstar VDahGetParent(TGRobj_env *objOE, IGRint i, TGRobj_env *parOE)
{
  IGRstat retFlag = 0;
  TGRid   srcID;
  
  // Arg Check
  if (parOE == NULL) goto wrapup;
  parOE->obj_id.objid = NULL_OBJID;

  if ((objOE == NULL) || (objOE->obj_id.objid == NULL_OBJID))  goto wrapup;

  // Get the parent
  srcID.objid = NULL_OBJID;
  vdchn$Get(il_objOE = objOE, ic_IDX = VDCHN_IDX_PARENT, ir_objIDX = i, or_objID = &srcID);
  if (srcID.objid == NULL_OBJID) goto wrapup;
  
  // Unsource it
  VDahGetObjectEnv(&srcID,parOE);
  if (parOE->obj_id.objid == NULL_OBJID) goto wrapup;
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

end implementation VSbeamAxis;
