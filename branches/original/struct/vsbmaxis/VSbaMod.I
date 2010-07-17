/* $Id: VSbaMod.I,v 1.3 2001/11/04 17:46:57 jayadev Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbmaxis/VSbaMod.I
 *
 * Description: Modify Stiffener Axis
 *	
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbaMod.I,v $
 *	Revision 1.3  2001/11/04 17:46:57  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/17 00:12:49  ramarao
 *	*** empty log message ***
 *	
# Revision 1.1  2000/08/05  15:55:28  pinnacle
# ah
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/03/22  14:57:58  pinnacle
# Clipper Warnings
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 03/22/98  ah        CR179800676 Modify Stiffener Axis
 *    ""               CR179800677 Set axis orientation
 * 08/05/00  ah        Allow selection of VSbooBeams
 * 10/27/01  Jayadev   TR#MP4292   Hilite Objects selected on form
 ***************************************************************************/

class implementation VSbeamAxis;

#include "VDmaster.h"

#include "VDahFrm.h"
#include "VSbaMod.h"

/* ------------------------------------------------------
 * Modify the macro itself
 */
IGRstar VSbaCMD_ModModifyMacro(TVSbaModInfo *info)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  IGRint  cn_type;
  
  TGRid  parentIDs[4];
  IGRint parentCNT;

  TGRid      axisID;
  TGRobj_env axisOE;
  
  TVSbaToggles tog;
  
  // Make sure we really got one
  if  (info->axisCNT <= 0) goto wrapup;
  if ((info->axisCUR <  0) || (info->axisCUR >= info->axisCNT)) goto wrapup;
  
  // Do the current one for now
  axisOE = info->axisOE;
  axisID = axisOE.obj_id;
  if (axisID.objid == NULL_OBJID) goto wrapup;
  
  // Must have plate and curve
  if (  info->plateOE.obj_id.objid == NULL_OBJID) goto wrapup;
  if (info->supportOE.obj_id.objid == NULL_OBJID) goto wrapup;

  VDahMakeSource(&info->plateOE,&parentIDs[0]);
  if (parentIDs[0].objid == NULL_OBJID) goto wrapup;

  VDahMakeSource(&info->supportOE,&parentIDs[1]);
  if (parentIDs[1].objid == NULL_OBJID) goto wrapup;
  
  parentCNT = 2;
  
  // Check for limits
  if (info->startOE.obj_id.objid == NULL_OBJID) goto no_limits;
  if ( info->stopOE.obj_id.objid == NULL_OBJID) goto no_limits;

  VDahMakeSource(&info->startOE,&parentIDs[2]);
  if (parentIDs[2].objid == NULL_OBJID) goto wrapup;

  VDahMakeSource(&info->stopOE,&parentIDs[3]);
  if (parentIDs[3].objid == NULL_OBJID) goto wrapup;
  
  parentCNT = 4;
  
no_limits:

  // Load toggles from form
  VSbaCMD_ModGetToggles(info,&tog);

  // Side of plate, need to send to any downstream
  // Beams as well so should test if it has changed
  sts = om$send(msg = message VSbeamAxis.VSputPlateSide(&msg,tog.side),
		senderid = NULL_OBJID,
		targetid = axisID.objid,
		targetos = axisID.osnum);

  // Old extend past limiting surfaces
  sts = om$send(msg = message VSbeamAxis.VSputExtendFlag(&msg,tog.ext),
		senderid = NULL_OBJID,
		targetid = axisID.objid,
		targetos = axisID.osnum);

  // Extend past edge of plate to limiting surfaces
  sts = om$send(msg = message VSbeamAxis.VSputExtend(&msg,tog.ext1,tog.ext2),
		senderid = NULL_OBJID,
		targetid = axisID.objid,
		targetos = axisID.osnum);  

  // Parametrize by surface or by curve
  sts = om$send(msg = message VSbeamAxis.VSputByCurve(&msg,tog.par),
		senderid = NULL_OBJID,
		targetid = axisID.objid,
		targetos = axisID.osnum);

  // Do It
  /* Reconnect */
  sts = om$send(
    msg = message NDnode.NDconnect(
      parentCNT,parentIDs,NULL_GRID,ND_FULL
    ),
    senderid = NULL_OBJID,
    targetid = axisID.objid,
    targetos = axisID.osnum 
  );
  if (!(sts & 1)) goto wrapup;

  /* Recompute */
  cn_type = ND_COMP;

  nd$wait_batch(
    type = GR_GEOM_POSTED,
    nb_obj     = 1,
    l_object   = &axisID,
    l_obj_info = &cn_type
  );
  nd$exec_batch();

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Called to execute any possible parent changes
 */
IGRstar VSbaCMD_ModExecuteParents
  (TVSbaModInfo *info,
   IGRchar       cmdKey,
   TGRobj_env   *axisOE)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env parentOEs[4];
  TGRid      parentIDs[4];
  IGRint     parentCNT;
 
  // Get existing parents
  VDahGetParent(axisOE,0,&parentOEs[0]);
  VDahGetParent(axisOE,1,&parentOEs[1]);
  VDahGetParent(axisOE,2,&parentOEs[2]);
  VDahGetParent(axisOE,3,&parentOEs[3]);

  // Based on command key, change the parents
  switch(cmdKey){

  case 'E':
    parentOEs[2] = info->startOE;
    parentOEs[3] = info->stopOE;
    break;
    
  case 'F':
    parentOEs[2].obj_id.objid = NULL_OBJID;
    parentOEs[3].obj_id.objid = NULL_OBJID;
    break;

  case 'G':
    parentOEs[2] = info->startOE;
    break;

  case 'H':
    parentOEs[3] = info->stopOE;
    break;
    
  case 'J':
    parentOEs[0] = info->plateOE;
    break;

  case 'L':
    parentOEs[1] = info->supportOE;
    break;

    
  }
  
  // Now source them
  VDahMakeSource(&parentOEs[0],&parentIDs[0]);
  if (parentIDs[0].objid == NULL_OBJID) goto wrapup;
  
  VDahMakeSource(&parentOEs[1],&parentIDs[1]);
  if (parentIDs[1].objid == NULL_OBJID) goto wrapup;

  parentCNT = 2;
  
  VDahMakeSource(&parentOEs[2],&parentIDs[2]);
  VDahMakeSource(&parentOEs[3],&parentIDs[3]);
  
  if ((parentIDs[2].objid != NULL_OBJID) && (parentIDs[3].objid != NULL_OBJID)) {
    parentCNT = 4;
  }
  
  // And attach
  sts = om$send(
    msg = message NDnode.NDconnect(
      parentCNT,parentIDs,NULL_GRID,ND_FULL
    ),
    senderid = NULL_OBJID,
    targetid = axisOE->obj_id.objid,
    targetos = axisOE->obj_id.osnum 
  );
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Called to execute
 */
IGRstar VSbaCMD_ModExecute(TVSbaModInfo *info)
{
  IGRstat retFlag = 0;
  IGRint  cn_type;
  
  Form form = info->form;
  
  IGRint axisCNT = info->axisCNT;
  IGRint axisCUR = info->axisCUR;

  TGRobj_env axisOE;
  TGRid      axisID;
  
  IGRchar cmd[128];
  IGRchar cmdKey;
  
  IGRint  compute;
  IGRint  computeAny = 0;
  
  // First make sure at least one object picked
  if (info->axisOE.obj_id.objid == NULL_OBJID) goto wrapup;
  if ((axisCNT <= 0) || (axisCUR < 0) || (axisCUR >= axisCNT)) goto wrapup;
  
  // Get the actual command
  *cmd = 0;
  VIg_get_text(form,VSBA_FORM_MOD_G_CMD,cmd);
  cmdKey = *cmd;
  
  // An A works on just the current macro
  if (cmdKey == 'A') {
    retFlag =  VSbaCMD_ModModifyMacro(info);
    goto wrapup;
  }

  // The rest of the commands work on all macros
  for(axisCUR = 0; axisCUR < axisCNT; axisCUR++) {

    axisOE = info->axisOEs[axisCUR];
    axisID = info->axisOEs[axisCUR].obj_id;
    compute = 0;
    
    switch(cmdKey) {

    /* ---------------------------------------------------------
    /* Parent Changes
     */
    case 'E':
    case 'F':
    case 'G':
    case 'H':
    case 'J':
    case 'L':
      compute = VSbaCMD_ModExecuteParents(info,cmdKey,&axisOE);
      break;
      
    /* ---------------------------------------------------------
    /* Extend past edge of plate to start/stop limits
     */
    case 'B': // Set both
    case 'C': // Set start only
    case 'D': // Set stop only

      compute = VSbaCMD_ModExecuteExtend(info,cmdKey,&axisID);
      break;
            
    /* ---------------------------------------------------------
    /* Paramertize by surface or support
     */
    case 'K': 

      compute = VSbaCMD_ModExecutePar(info,cmdKey,&axisID);
      break;
      
    /* ---------------------------------------------------------
    /* Old extend past limits
     */
    case 'M': 

      compute = VSbaCMD_ModExecuteExt(info,cmdKey,&axisID);
      break;
      

    /* ---------------------------------------------------------
    /* Need more work here, need to tell beams to shift as well
     */
    case 'I':

      compute = VSbaCMD_ModExecuteSide(info,cmdKey,&axisID);
      break;
      
    } // Switch on command

    /* Recompute */
    if (compute) {
      
      cn_type = ND_COMP;

      nd$wait_batch(type = GR_GEOM_POSTED,
		    nb_obj     = 1,
		    l_object   = &axisID,
		    l_obj_info = &cn_type);
      computeAny = 1;
    }
    
  }  // Loop for each axis

  // Doit
  if (computeAny) nd$exec_batch();
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Gets called when a new set of axis have been picked
 * and stored in the info structure
 */
IGRstar VSbaCMD_ModProcessAxes(TVSbaModInfo *info)
{
  IGRstat retFlag = 0;
  
  // Display form (possibly for the first time)
  info->displayForm = 1; 
  VIf_display(info->form);
  
  // Display the first one
  if (info->axisCNT <= 0) info->axisCUR = -1;
  else                    info->axisCUR =  0;

  // Fill in its data, if none are picked then this will
  // Clear all the data strictures
  VSbaCMD_ModFillStiffAxis(info);
  
  retFlag = 1;

  //wrapup:
  return retFlag;
}

/* --------------------------------------------
 * A new stiffener axis was picked
 */
IGRstar VSbaCMD_ModPickedStiffener(TVSbaModInfo *info, TGRobj_env *stiffOE)
{
  IGRstat retFlag = 0;
  IGRint  gotOne = 0;
  
  TGRobj_env axisOE;

  axisOE.obj_id.objid = NULL_OBJID;
  VSbaGetBeamAxis(stiffOE,&axisOE);

  if (axisOE.obj_id.objid != NULL_OBJID) {
    info->axisCNT = 1;
    info->axisOEs[0] = axisOE;
    gotOne = 1;
  }
  
  if (gotOne) VSbaCMD_ModProcessAxes(info);
  
  retFlag = 1;

//wrapup:
  return retFlag;
}

/* --------------------------------------------
 * A new stiffener axis was picked with fence
 */
IGRstar VSbaCMD_ModPickedStiffenerFence(TVSbaModInfo *info, TGRobj_env *fenceOE)
{
  IGRstat retFlag = 0;
  IGRint  gotOne  = 0;
  
  TGRobj_env  axisOE;
  TGRobj_env *axisOEs = NULL;

  IGRint axisCNT = 0;
  IGRint i,j,noMatch;
  
  // Don't do one without the other
  IGRint  response;
  IGRchar response_data[1024];
  
  *response_data = 0;
   response = 0;
  
  as$start_fence(set       = &fenceOE->obj_id,
		 set_env   = &fenceOE->mod_env,
		 nb_obj    = &axisCNT,
		 response  = &response,
		 response_data = response_data,
       		 p_obj_env = &axisOEs);

  if (response != EX_DATA) goto wrapup;
  /*
  if (response == EX_DATA)   printf("Response was data\n");
  if (response == EX_STRING) printf("String %s\n",response_data);
  */
  
  for(i = 0; (i < axisCNT) && (info->axisCNT < VSBA_AXIS_MAX); i++) {

    axisOE.obj_id.objid = NULL_OBJID;
    VSbaGetBeamAxis(&axisOEs[i],&axisOE);

    if (axisOE.obj_id.objid != NULL_OBJID) {

      // First one clears the existing list
      if (gotOne == 0) {
	gotOne = 1;
	info->axisCNT =  0;
	info->axisCUR = -1;
      }
      
      // Could have dups
      noMatch = 1;
      for(j = 0; (j < info->axisCNT) && (noMatch == 1); j++) {
	if ((axisOE.obj_id.objid == info->axisOEs[j].obj_id.objid) && 
	    (axisOE.obj_id.osnum == info->axisOEs[j].obj_id.osnum)) {
	  noMatch = 0;
	}
      }
      if (noMatch == 1) {
	info->axisOEs[info->axisCNT] = axisOE;
	info->axisCNT++;
      }
      
    }
    
  }
  ASend_fence();
  
  if (gotOne) VSbaCMD_ModProcessAxes(info);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Utility routine to fill gadget
 */
IGRstar VSbaCMD_ModFillObject(Form form, IGRint gadget, TGRobj_env *objOE)
{
  IGRstat retFlag = 0;
  IGRchar desc[1024];

  if (objOE->obj_id.objid == NULL_OBJID) {
    VDahFrmSetTextRC(form,gadget,0,0,"");
    VDahFrmSetTextRC(form,gadget,0,1,"");
    retFlag = 1;
    goto wrapup;
  }

  VDahGetObjectDesc(&objOE->obj_id,desc);
  if (*desc == 0) strcpy(desc,"Defined");

  VDahFrmSetTextRC(form,gadget,0,0,desc);
  VDahFrmSetGRid  (form,gadget,0,1,&objOE->obj_id);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* --------------------------------------------
 * Update the form with the current
 * axis object
 */
IGRstat VSbaCMD_ModFillStiffAxis(TVSbaModInfo *info)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  Form    form = info->form;

  TGRobj_env axisOE;
  TGRid      axisID;
  
  IGRchar    buf[128];
  TVSbaToggles tog;
  
  // First get the current one
  if ((info->axisCNT < 1) || (info->axisCUR < 0) || (info->axisCUR >= info->axisCNT)) {
    axisOE.obj_id.objid = NULL_OBJID;
  }
  else {
    axisOE = info->axisOEs[info->axisCUR];
    info->axisOE = axisOE;
  }
  VSbaCMD_ModFillObject(form,VSBA_FORM_MOD_F_BEAM_AXIS,&axisOE);
  VSbaCMD_ModHiLiteObject(info, &axisOE);
  
  //vdbro$PrintObject(objOE = &axisOE);
  
  // Update the counter
  sprintf(buf,"%2d",info->axisCUR+1);
  VIg_set_text(form,VSBA_FORM_MOD_G_CUR,buf);
  sprintf(buf,"%2d",info->axisCNT);
  VIg_set_text(form,VSBA_FORM_MOD_G_CNT,buf);

  // Fill in parents
  VDahGetParent(&axisOE,0,&info->plateOE);
  VSbaCMD_ModFillObject(form,VSBA_FORM_MOD_F_PLATE,&info->plateOE);

  VDahGetParent(&axisOE,1,&info->supportOE);
  VSbaCMD_ModFillObject(form,VSBA_FORM_MOD_F_SUPPORT,&info->supportOE);

  VDahGetParent(&axisOE,2,&info->startOE);
  VSbaCMD_ModFillObject(form,VSBA_FORM_MOD_F_START,&info->startOE);

  VDahGetParent(&axisOE,3,&info->stopOE);
  VSbaCMD_ModFillObject(form,VSBA_FORM_MOD_F_STOP,&info->stopOE);

  // Get the internal status bits
  axisID = axisOE.obj_id;
  
  // Side of plate, need to send to any downstream
  // Beams as well so should test if it has changed
  sts = om$send(msg = message VSbeamAxis.VSgetPlateSide(&msg,&tog.side),
		senderid = NULL_OBJID,
		targetid = axisID.objid,
		targetos = axisID.osnum);

  // Old extend past limiting surfaces
  sts = om$send(msg = message VSbeamAxis.VSgetExtendFlag(&msg,&tog.ext),
		senderid = NULL_OBJID,
		targetid = axisID.objid,
		targetos = axisID.osnum);

  // Extend past edge of plate to limiting surfaces
  sts = om$send(msg = message VSbeamAxis.VSgetExtend(&msg,&tog.ext1,&tog.ext2),
		senderid = NULL_OBJID,
		targetid = axisID.objid,
		targetos = axisID.osnum);  

  // Parametrize by surface or by curve
  sts = om$send(msg = message VSbeamAxis.VSgetByCurve(&msg,&tog.par),
		senderid = NULL_OBJID,
		targetid = axisID.objid,
		targetos = axisID.osnum);

  // Updates toggles on the form
  VSbaCMD_ModSetToggles  (info,&tog);
  VSbaCMD_ModHiLiteObject(info,&axisOE);
  
  retFlag = 1;

  return retFlag;
}

/* ----------------------------------------------
 * Utility to hilite an object
 */
IGRstat VSbaCMD_ModHiLiteObject(TVSbaModInfo *info, TGRobj_env *objOE)
{
  IGRstat retFlag = 0;
  IGRint  msg;
  IGRint  sel;

  Form form = info->form;

  enum GRdpmode mode = GRhdo;

  // Unhilite anything
  dp$erase_hilite(msg = &msg);
  // Unselect all gadgets
  FIfld_get_select(form,info->gadget,0,0,&sel);

  FIfld_set_select(form,VSBA_FORM_MOD_F_BEAM_AXIS,0,0,0);
  FIfld_set_select(form,VSBA_FORM_MOD_F_BEAM_AXIS,0,1,0);
  FIfld_set_select(form,VSBA_FORM_MOD_F_PLATE,    0,0,0);
  FIfld_set_select(form,VSBA_FORM_MOD_F_PLATE,    0,1,0);
  FIfld_set_select(form,VSBA_FORM_MOD_F_SUPPORT,  0,0,0);
  FIfld_set_select(form,VSBA_FORM_MOD_F_SUPPORT,  0,1,0);
  FIfld_set_select(form,VSBA_FORM_MOD_F_START,    0,0,0);
  FIfld_set_select(form,VSBA_FORM_MOD_F_START,    0,1,0);
  FIfld_set_select(form,VSBA_FORM_MOD_F_STOP,     0,0,0);
  FIfld_set_select(form,VSBA_FORM_MOD_F_STOP,     0,1,0);
  FIfld_set_select(form,VSBA_FORM_MOD_F_STIFF,    0,0,0);
  FIfld_set_select(form,VSBA_FORM_MOD_F_STIFF,    0,1,0);
  //if (sel == 0) goto wrapup;

  FIfld_set_select(form,info->gadget,0,0,1);
  FIfld_set_select(form,info->gadget,0,1,1);

  // Make sure got object
  if (objOE->obj_id.objid == NULL_OBJID) {
    goto wrapup;
  }
  // Hilite
  vd_$bulk_display(dpmode  = mode, 
 	           objenvs = objOE);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Object was picked
 */
IGRstar VSbaCMD_ModPickedObject(TVSbaModInfo *info, TGRobj_env *objOE)
{
  IGRstat retFlag = 0;
  IGRint  gadget = info->gadget;

  if (objOE->obj_id.objid == NULL_OBJID) goto wrapup;

  switch(gadget) {

  case VSBA_FORM_MOD_B_START: {
    info->startOE = *objOE;
    info->gadget  = VSBA_FORM_MOD_F_START;
    break;
    
  }

  case VSBA_FORM_MOD_B_STOP: {
    info->stopOE  = *objOE;
    info->gadget  = VSBA_FORM_MOD_F_STOP;
    break;
    
  }

  case VSBA_FORM_MOD_B_PLATE: {
    info->plateOE = *objOE;
    info->gadget  = VSBA_FORM_MOD_F_PLATE;
    break;
    
  }

  case VSBA_FORM_MOD_B_SUPPORT: {
    info->supportOE = *objOE;
    info->gadget    = VSBA_FORM_MOD_F_SUPPORT;
    break;

  default:
    goto wrapup;
    
  }

  } // Switch

  // Sync form and display
  VSbaCMD_ModFillObject(info->form,info->gadget,objOE);
  FIfld_set_select(info->form,info->gadget,0,0,1);
  VSbaCMD_ModHiLiteObject(info,objOE);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Next/Prev buttons
 */
IGRstar VSbaCMD_ModInc(TVSbaModInfo *info, int inc)
{
  IGRstat retFlag = 0;
  
  IGRint  axisCNT = info->axisCNT;
  IGRint  axisCUR = info->axisCUR;
  
  // Ignore if no beam axis around
  if (axisCNT <= 0) goto wrapup;
  axisCUR += inc;
  
  // Fancy and do warp around
  if (axisCUR < 0)        axisCUR = axisCNT - 1;
  if (axisCUR >= axisCNT) axisCUR = 0;
  
  // Update form
  info->axisCUR = axisCUR;
  VSbaCMD_ModFillStiffAxis(info);
  
  retFlag = 1;

wrapup:
  return retFlag;
}

    
/* ------------------------------------------------------
 * Notification Routine
 */
IGRstar VSbaCMD_ModNotify(TVSbaModInfo *info)
{
  IGRstat retFlag = 1;
  
  switch(info->gadget) {

  case VSBA_FORM_MOD_F_BEAM_AXIS: {
    VSbaCMD_ModHiLiteObject(info,&info->axisOE);
    goto wrapup;
  }
  case VSBA_FORM_MOD_F_PLATE: {
    VSbaCMD_ModHiLiteObject(info,&info->plateOE);
    goto wrapup;
  }
  case VSBA_FORM_MOD_F_SUPPORT: {
    VSbaCMD_ModHiLiteObject(info,&info->supportOE);
    goto wrapup;
  }
  case VSBA_FORM_MOD_F_START: {
    VSbaCMD_ModHiLiteObject(info,&info->startOE);
    goto wrapup;
  }
  case VSBA_FORM_MOD_F_STOP: {
    VSbaCMD_ModHiLiteObject(info,&info->stopOE);
    goto wrapup;
  }

  case VSBA_FORM_MOD_B_HILITE: 
    vd_$bulk_display(dpmode  = GRhd, 
		     objenvs = info->axisOEs, 
		     count   = info->axisCNT);
    goto wrapup;
    
  case VSBA_FORM_MOD_B_NEXT: {
    VSbaCMD_ModInc(info,1);
    goto wrapup;
  }
  case VSBA_FORM_MOD_B_PREV: {
    VSbaCMD_ModInc(info,-1);
    goto wrapup;
  }

  case FI_ACCEPT:
  case FI_EXECUTE: {
    VSbaCMD_ModExecute(info);
    goto wrapup;
  }
  
  case VSBA_FORM_MOD_T_SIDE:
  case VSBA_FORM_MOD_T_EXT:
  case VSBA_FORM_MOD_T_EXT1:
  case VSBA_FORM_MOD_T_EXT2:
  case VSBA_FORM_MOD_T_PAR: {    
    VSbaCMD_ModNotifyToggle(info);
    goto wrapup;
  }
  
  } // Switch

  retFlag = 0;

wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Toggle messages
 */
IGRstar VSbaCMD_ModNotifyToggle(TVSbaModInfo *info)
{
  IGRstat retFlag = 0;
  IGRint  state = 0;
  IGRchar buf[128];
  
  *buf = 0;
  
  VIg_get_state(info->form,info->gadget,&state);
  
  switch(info->gadget) {

  case VSBA_FORM_MOD_T_SIDE:
    if (state) strcpy(buf,"Switch to Offset Surface of Plate");
    else       strcpy(buf,"Switch to Base Surface of Plate");
    break;
    
  case VSBA_FORM_MOD_T_EXT:
    if (state) strcpy(buf,"Extend Beyond Limiting Surfaces");
    else       strcpy(buf,"Don't Extend Beyond Limiting Surfaces");
    break;

  case VSBA_FORM_MOD_T_EXT1:
    if (state) strcpy(buf,"Extend to Start Surface");
    else       strcpy(buf,"Don't Extend to Start Surface");
    break;

  case VSBA_FORM_MOD_T_EXT2:
    if (state) strcpy(buf,"Extend to Stop Surface");
    else       strcpy(buf,"Don't Extend to Start Surface");
    break;

  case VSBA_FORM_MOD_T_PAR:   
    if (state) strcpy(buf,"Paramertize by Support Curve");
    else       strcpy(buf,"Paramertize by Plate Surface");
    break;

  }
  
  VIg_set_text(info->form,10,buf);
  UI_status(buf);
  
  retFlag = 1;
  
  return retFlag;
}
  
/* --------------------------------------
 * Misc stuff
 */
#argsused
IGRstat VSbaCMD_ModInit(TVSbaModInfo *info)
{
  IGRint retFlag = 0;
  IGRint msg,sts;
  IGRint i;
  
  dp$erase_hilite(msg = &msg);
  memset(info,0,sizeof(TVSbaModInfo));

     info->axisOE.obj_id.objid = NULL_OBJID;
    info->plateOE.obj_id.objid = NULL_OBJID;
  info->supportOE.obj_id.objid = NULL_OBJID;
    info->startOE.obj_id.objid = NULL_OBJID;
     info->stopOE.obj_id.objid = NULL_OBJID;
    info->stiffOE.obj_id.objid = NULL_OBJID;

  sts = gr$get_module_env(buffer = &info->env);
  if (!(sts & 1)) goto wrapup;
  
  for(i = 0; i < VSBA_AXIS_MAX; i++) {
    info->axisOEs[i].obj_id.objid = NULL_OBJID;
  }

  info->axisCUR = -1;
  
  retFlag = 1;
wrapup:
  return retFlag;
}
#argsused
IGRstat VSbaCMD_ModSleep(TVSbaModInfo *info)
{
  IGRint msg;
  dp$erase_hilite(msg = &msg);
  return 1;
}
#argsused
IGRstat VSbaCMD_ModWakeup(TVSbaModInfo *info)
{
  //VDsupCMDEtcNotifyHiLite(info,1);
  return 1;
}
#argsused
IGRstat VSbaCMD_ModDelete(TVSbaModInfo *info)
{
  IGRint msg;
  dp$erase_hilite(msg = &msg);
  return 1;
}

/* ----------------------------------------------------
 * List of locate classes
 * Limit to just source stiffeners for now
 * Deal with boolean stiffeners later
 */
static VDclassid classListIDs[8];

IGRstar VDbaCMD_GetClassList(OM_S_CLASSLIST *classList)
{
  IGRstat retFlag = 0;

  om$get_classid(classname = "VSstfBeam",
		 p_classid = &classListIDs[0]);

  om$get_classid(classname = "VSsubBeam",
		 p_classid = &classListIDs[1]);

  om$get_classid(classname = "VSfrzBeam",
		 p_classid = &classListIDs[2]);

  om$get_classid(classname = "VSrflBeam",
		 p_classid = &classListIDs[3]);

  om$get_classid(classname = "VSbooBeam",
		 p_classid = &classListIDs[4]);

  classList->p_classes = classListIDs;
  classList->w_count = 5;
  classList->w_flags = OM_CLST_subclass;

  retFlag = 1;

  return retFlag;
}

end   implementation VSbeamAxis;



