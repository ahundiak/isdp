/* $Id: VDsupEtc.I,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/cmd/imp/VDsupEtc.I
 *
 * Description: Etc Command Implemention
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsupEtc.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/18  15:15:14  pinnacle
# VDsupEtc
#
 *
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      12/17/97  ah      Created
 ***************************************************************************/

class implementation VDsupGen;

#include "VDsupMac.h"
#include "VDsupCmd.h"

#include "bsdistptpt.h"

IGRstat VDsupCMDEtcModifyMacro  (TVDsupEtc *info, TGRid *tl);
IGRstat VDsupCMDEtcPlaceMacro   (TVDsupEtc *info, TGRid *tl);
IGRstat VDsupCMDEtcNotifyExecute(TVDsupEtc *info);

IGRstat VDsupCMDEtcFillCurve(TVDsupEtc *info);
IGRstat VDsupCMDEtcFillTrim (TVDsupEtc *info);

IGRstat VDsupCMDEtcInit  (TVDsupEtc *info);
IGRstat VDsupCMDEtcSleep (TVDsupEtc *info);
IGRstat VDsupCMDEtcWakeup(TVDsupEtc *info);
IGRstat VDsupCMDEtcDelete(TVDsupEtc *info);

/* ------------------------------------------------------
 * Modify existing occurance
 */
IGRstat VDsupCMDEtcModifyMacro(TVDsupEtc *info, TGRid *tl)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint  cn_type;

  TGRid   supID = info->etcID;

  TGRid   tempListId[VDSUP_MAC_MAX_NUM_TEMP];
  IGRlong tempNum;

  /* Make new template list */
  sts = om$send(
    msg = message VDsupGen.VDsupSetTempList(
       tl,VDSUP_I_MAX,NULL,
       &tempNum,tempListId
    ),
    senderid = NULL_OBJID,
    targetid = supID.objid,
    targetos = supID.osnum 
  );
  if (!(sts & 1)) goto wrapup;

  /* Reconnect */
  sts = om$send(
    msg = message NDnode.NDconnect(
      tempNum,tempListId,NULL_GRID,ND_FULL
    ),
    senderid = NULL_OBJID,
    targetid = supID.objid,
    targetos = supID.osnum 
  );
  if (!(sts & 1)) goto wrapup;

  /* Recompute */
  cn_type = ND_COMP;

  nd$wait_batch(
    type = GR_GEOM_POSTED,
    nb_obj     = 1,
    l_object   = &supID,
    l_obj_info = &cn_type
  );
  nd$exec_batch();

  retFlag = 1;

wrapup:
  return retFlag;
}


/* ------------------------------------------------------
 * Create actual occurance
 */
IGRstat VDsupCMDEtcPlaceMacro(TVDsupEtc *info, TGRid *tl)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong sucL;
  IGRint  sucI;

  TGRid   supID;

  TGRid   tempListId[VDSUP_MAC_MAX_NUM_TEMP];
  IGRlong tempNum;

  IGRlong macType;

  IGRchar name[DI_PATH_MAX];

  TGRsymbology symb;

  /* Make the support object */
  supID.osnum = info->env.md_id.osnum;

  sts = om$construct( 
    classid = OPP_VDsupGen_class_id,
    osnum   =  supID.osnum,
    p_objid = &supID.objid 
  );
  if (!(sts&1)) {
    UI_status("Unable to Create Support Macro");
    goto wrapup;
  }

  /* Set The Type */
  macType = VDSUP_MAC_TYPE_ETC;
  sts = om$send(
    msg = message VDsupGen.VDsupSetType(macType),
    senderid = NULL_OBJID,
    targetid = supID.objid,
    targetos = supID.osnum
  );

  /* Generate template List */
  sts = om$send(
    msg = message VDsupGen.VDsupSetTempList(
      tl,
      VDSUP_I_MAX,
      NULL,
     &tempNum,
      tempListId),
    senderid = NULL_OBJID,
    targetid = supID.objid,
    targetos = supID.osnum 
  );

  /* Name it */
  VDahGetNextOccName("etc",name,NULL);
  om$send(
    msg = message GRgraphics.GRchgname(&sucL, &info->env, name ),
    senderid = NULL_OBJID,
    targetid = supID.objid,
    targetos = supID.osnum 
  );

  // Set symb to active
  VDahGetActiveSymbology(&symb);
/*
  sts = om$send(
    msg = message GRvg.GRputsymb(&sucL, &symb),
    senderid = NULL_OBJID,
    targetid = supID.objid,
    targetos = supID.osnum 
  );
  if (!(sts & sucL & 1)) {
    UI_status("Set Symbology Failed");
    goto wrapup;
  }
*/
  // printf("Symb Color %d, Layer %d\n",symb.display_attr.color,symb.level);

  // Place it
  sts = om$send(  
    msg  = message ACncpx.ACmplace(
      &sucI,
       AChdr_noprotect, 0,
       VDSUP_MAC_NAME,
       tempNum,
       tempListId,
      &info->env 
    ),
    senderid = NULL_OBJID,
    targetid = supID.objid,
    targetos = supID.osnum 
  );
  // VDbroPrintObj(&supID);

  if (!(sts & sucI & 1)) {
    UI_status("Unable to Place Support Macro");
    vd_$bulk_delete(theEnv = &info->env, grids = &supID);
    goto wrapup;
  }

  //VDsupGetNextOccName(NULL,name);
  //FIg_set_text(me->form_ptr,VDSUP_FRM_F_NAME,name);
	
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Place/modify a macro
 */
IGRstat VDsupCMDEtcNotifyExecute(TVDsupEtc *info)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i,cnt;
  Form    form = info->form;
  TGRid   tl[VDSUP_I_MAX];

  // Init
  memset(tl,0,VDSUP_I_MAX * sizeof(TGRid));
  cnt = 0;

  // Need at least one curve
  if (info->crvCNT < 1) goto wrapup;

  // Xfer the trim objects
  cnt = 0;
  sts = VDahMakeSource(&info->trim1OE,&tl[VDSUP_I_REF1]);
  if (sts & 1) cnt++;
  sts = VDahMakeSource(&info->trim2OE,&tl[VDSUP_I_REF2]);
  if (sts & 1) cnt++;

  if (cnt == 1) {
    printf("Only have one trim surface\n");
    goto wrapup;
  }

  // Add in distance
  if ((info->disID.objid != NULL_OBJID) &&
      (info->disID.objid != 0)) {
    tl[VDSUP_I_DIS1] = info->disID;
  }

  // Create It
  if ((info->etcID.objid == NULL_OBJID) ||
      (info->etcID.objid == 0)) {

    // One macro per trace curve
    for(i = 0; i < info->crvCNT; i++) {
      VDahMakeSource(&info->crvOEs[i],&tl[VDSUP_I_TRACE_BEG]);
      VDsupCMDEtcPlaceMacro(info,tl);
    }
    FIg_set_text(form,10,"Macro(s) Placed");
  }
  else {
    // Only modify one at a time
    VDahMakeSource(&info->crvOEs[0],&tl[VDSUP_I_TRACE_BEG]);
    VDsupCMDEtcModifyMacro(info,tl);
    FIg_set_text(form,10,"Macro Modified");
  }

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Picked an etc macro to modify
 */
IGRstat VDsupCMDEtcPickedEtc(TVDsupEtc *info, TGRobj_env *etcOE)
{
  IGRstat retFlag = 0;
  IGRchar status[128];
  IGRchar desc [1024];

  IGRlong type;
  IGRint  i;

  Form form = info->form;

  TGRid tl[VDSUP_I_MAX];
  TGRid etcID = etcOE->obj_id;

  TGRobj_env objOE;
    
  // Init
  *status = 0;

  // Make sure in same os
  if (etcID.osnum != info->env.md_id.osnum) {
    strcpy(status,"ETC macro is in a reference file");
    goto wrapup;
  }

  // Check the type
  type = 0;
  om$send(
    msg = message VDsupGen.VDsupGetType(&type),
    senderid = NULL_OBJID,
    targetid = etcID.objid,
    targetos = etcID.osnum
  );
  if (type != VDSUP_MAC_TYPE_ETC) {
    strcpy(status,"Not an ETC macro");
    goto wrapup;
  }

  // Get the arg list
  memset(tl,0,VDSUP_I_MAX * sizeof(TGRid));
  om$send(
    msg = message VDsupGen.VDsupGetTempList(tl,VDSUP_I_MAX,NULL),
    senderid = NULL_OBJID,
    targetid = etcID.objid,
    targetos = etcID.osnum
  );

  // Make it the macro to modify
  info->etcID = etcID;
  VDahGetObjectDesc(&etcID,desc);
  FIg_set_text(form,VDSUP_FORM_ETC_G_ETC,desc);

  // Xfer curves
  info->crvCNT = 0;
  for(i = VDSUP_I_TRACE_BEG; (i<VDSUP_I_TRACE_END)&&(tl[i].objid); i += 2) {

    VDahGetObjectEnv(&tl[i],&objOE);
    if (objOE.obj_id.objid != NULL_OBJID) {
      info->crvOEs[info->crvCNT] = objOE;
      info->crvCNT++;
    }
  }
  VDsupCMDEtcFillCurve(info);

  // Xfer trim
  VDahGetObjectEnv(&tl[VDSUP_I_REF1],&objOE);
  info->trim1OE = objOE;

  VDahGetObjectEnv(&tl[VDSUP_I_REF2],&objOE);
  info->trim2OE = objOE;

  VDsupCMDEtcFillTrim(info);

  // And the distance
  info->disID = tl[VDSUP_I_DIS1];
  if (info->disID.objid == 0) info->disID.objid = NULL_OBJID;
  VDahSetExpForm(&info->disID,form,VDSUP_FORM_ETC_G_DISTANCE);

  // Done
  strcpy(status,"ETC macro found");

wrapup:
  FIg_set_text(form,10,status);
  return retFlag;
}

/* -----------------------------------------
 * Expression changed
 */
IGRstat VDsupCMDEtcNotifyExp(TVDsupEtc *info)
{
  IGRstat retFlag = 0;

  Form   form   = info->form;
  IGRint gadget = VDSUP_FORM_ETC_G_DISTANCE;

  IGRchar status[1024];
  IGRchar str[1024];
  TGRid   expID;

  // Read it in
  *str = 0;
  FIg_get_text(form,gadget,str);

  // Make object
  *status = 0;
  VDahMakeExpObject(str, &expID, status);
  if (expID.objid != NULL_OBJID) {

    // Make it current
    info->disID    = expID;
  }

  // Show results
  FIg_set_text(form,10,status);

  retFlag = 1;
  return retFlag;
}

/* -------------------------------------
 * Trim surface picked
 */
IGRstat VDsupCMDEtcTrim1(TVDsupEtc *info, TGRobj_env *trimOE)
{
  IGRstat retFlag = 0;

  Form form = info->form;

  // Make sure not the same as trim 2
  if ((trimOE->obj_id.objid == info->trim2OE.obj_id.objid) &&
      (trimOE->obj_id.osnum == info->trim2OE.obj_id.osnum)) {
    FIg_set_text(form,10,"Trim surface already used");
    goto wrapup;
  }

  // Transfer it
  info->trim1OE = *trimOE;
  VDsupCMDEtcFillTrim(info);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------
 * Trim surface picked
 */
IGRstat VDsupCMDEtcTrim2(TVDsupEtc *info, TGRobj_env *trimOE)
{
  IGRstat retFlag = 0;
  Form form = info->form;
  
  // Make sure not the same as trim 1
  if ((trimOE->obj_id.objid == info->trim1OE.obj_id.objid) &&
      (trimOE->obj_id.osnum == info->trim1OE.obj_id.osnum)) {
    FIg_set_text(form,10,"Trim surface already used");
    goto wrapup;
  }

  // Transfer it
  info->trim2OE = *trimOE;
  VDsupCMDEtcFillTrim(info);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* -------------------------------------
 * Removes crv from list
 */
IGRstat VDsupCMDEtcRemoveCurve(TVDsupEtc *info, IGRint row)
{
  IGRstat retFlag = 0;
  IGRint  i;

  // Arg check
  if ((row < 0) || (row >= info->crvCNT)) goto wrapup;

  for(i = row+1; i < info->crvCNT; i++) {
    info->crvOEs[i-1] = info->crvOEs[i];
  }
  info->crvCNT--;

  retFlag = 1;
wrapup:
  return retFlag;
}

/* -------------------------------------
 * Drop selected items
 */
IGRstat VDsupCMDEtcNotifyDropCurves(TVDsupEtc *info)
{
  IGRstat retFlag = 0;
  IGRint  msg;

  Form    form   = info->form;
  IGRint  gadget = VDSUP_FORM_ETC_L_CURVES;

  IGRint  row,rows;
  IGRint  sel;

  // Unhilite anything
  dp$erase_hilite(msg = &msg);

  // Get the row
  rows = -1;
  FIfld_get_num_rows(form,gadget,&rows);
  for(row = 0; row < rows; row++) {

    // Filter on selects
    sel = -1;
    FIfld_get_select(form,gadget,row,0,&sel);
    if (sel == 1) {

      FIfld_delete_rows(form,gadget,row,1);
      VDsupCMDEtcRemoveCurve(info,row);
      row--;
      rows--;

    }
  }

  // Applies to trim curves as well
  gadget = VDSUP_FORM_ETC_G_TRIM1;
  sel = -1;
  FIfld_get_select(form,gadget,0,0,&sel);
  if (sel == 1) info->trim1OE.obj_id.objid = NULL_OBJID;

  gadget = VDSUP_FORM_ETC_G_TRIM2;
  sel = -1;
  FIfld_get_select(form,gadget,0,0,&sel);
  if (sel == 1) info->trim2OE.obj_id.objid = NULL_OBJID;

  VDsupCMDEtcFillTrim(info);

  retFlag = 1;
  return retFlag;
}

/* ----------------------------------------------------------
 * Hilite nonsense
 * 0 Is All
 * 1 Is Selected
 */
IGRstat VDsupCMDEtcNotifyHiLite(TVDsupEtc *info, IGRint flag)
{
  IGRstat retFlag = 0;
  IGRint  msg;

  Form    form   = info->form;
  IGRint  gadget = VDSUP_FORM_ETC_L_CURVES;

  IGRint  row,rows;
  IGRint  sel,hilite;
  enum GRdpmode mode;

  TGRobj_env trimOE;

  // Unhilite anything
  dp$erase_hilite(msg = &msg);
  mode = GRhd;

  // Make sure
  if (form == NULL) goto wrapup;

  // Get the row
  rows = -1;
  FIfld_get_num_rows(form,gadget,&rows);
  for(row = 0; row < rows; row++) {

    // Hilite mode
    hilite = 1;

    // Limit to selected rows
    if (flag) {
      sel = -1;
      FIfld_get_select(form,gadget,row,0,&sel);
      if (sel != 1) hilite = 0;
    }

    // Hilite
    if (hilite) {
      vd_$bulk_display(dpmode = mode, objenvs = &info->crvOEs[row]);
    }
  }

  // Trim surfaces as well
  trimOE = info->trim1OE;
  if ((trimOE.obj_id.objid==NULL_OBJID) ||
      (trimOE.obj_id.objid==0)) goto hilite_trim2;
  hilite = 1;
  if (flag) {
    sel = -1;
    FIfld_get_select(form,VDSUP_FORM_ETC_G_TRIM1,0,0,&sel);
    if (sel != 1) hilite = 0;
  }
  if (hilite) {
    vd_$bulk_display(dpmode = mode, objenvs = &trimOE);
  }

hilite_trim2:
  trimOE = info->trim2OE;
  if ((trimOE.obj_id.objid==NULL_OBJID) ||
      (trimOE.obj_id.objid==0)) goto hilite_done;
  hilite = 1;
  if (flag) {
    sel = -1;
    FIfld_get_select(form,VDSUP_FORM_ETC_G_TRIM2,0,0,&sel);
    if (sel != 1) hilite = 0;
  }
  if (hilite) {
    vd_$bulk_display(dpmode = mode, objenvs = &trimOE);
  }

hilite_done:

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * A curve was poked
 */
IGRstat VDsupCMDEtcNotifyCurves(TVDsupEtc *info)
{
  IGRstat retFlag = 0;

  Form   form   = info->form;
  IGRint gadget = VDSUP_FORM_ETC_L_CURVES;

  IGRint  row,pos;
  IGRint  sel;
  enum GRdpmode mode;

  // Get the row
  row = -1;
  FIfld_get_active_row(form,gadget,&row,&pos);
  if (row < 0) goto wrapup;
  if (row >= info->crvCNT) goto wrapup;

  // Hilite or not
  sel = -1;
  FIfld_get_select(form,gadget,row,0,&sel);
  if (sel == 1) mode = GRhd;
  else          mode = GRhe;

  // Hilite
  vd_$bulk_display(dpmode = mode, objenvs = &info->crvOEs[row]);
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * A trim was poked
 */
IGRstat VDsupCMDEtcNotifyTrim1(TVDsupEtc *info)
{
  IGRstat retFlag = 0;

  Form   form   = info->form;
  IGRint gadget = VDSUP_FORM_ETC_G_TRIM1;

  IGRint  sel;
  enum GRdpmode mode;

  // Hilite or not
  sel = -1;
  FIfld_get_select(form,gadget,0,0,&sel);
  if (sel == 1) mode = GRhd;
  else          mode = GRhe;

  // Hilite
  vd_$bulk_display(dpmode = mode, objenvs = &info->trim1OE);
  
  retFlag = 1;

//wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * A trim was poked
 */
IGRstat VDsupCMDEtcNotifyTrim2(TVDsupEtc *info)
{
  IGRstat retFlag = 0;

  Form   form   = info->form;
  IGRint gadget = VDSUP_FORM_ETC_G_TRIM2;

  IGRint  sel;
  enum GRdpmode mode;

  // Hilite or not
  sel = -1;
  FIfld_get_select(form,gadget,0,0,&sel);
  if (sel == 1) mode = GRhd;
  else          mode = GRhe;

  // Hilite
  vd_$bulk_display(dpmode = mode, objenvs = &info->trim2OE);
  
  retFlag = 1;

//wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * ETC was poked
 */
IGRstat VDsupCMDEtcNotifyEtc(TVDsupEtc *info)
{
  IGRstat retFlag = 0;

  Form   form   = info->form;
  IGRint gadget = VDSUP_FORM_ETC_G_ETC;

  IGRint  sel;
  enum GRdpmode mode;

  // Hilite or not
  sel = -1;
  FIfld_get_select(form,gadget,0,0,&sel);
  if (sel == 1) mode = GRhd;
  else          mode = GRhe;

  // Hilite
  vd_$bulk_display(dpmode = mode, theEnv = &info->env, grids = &info->etcID);
  
  retFlag = 1;

//wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Fills the trim curves
 */
IGRstat VDsupCMDEtcFillTrim(TVDsupEtc *info)
{
  IGRstat retFlag = 0;

  Form form = info->form;
  IGRchar desc[1024];

  VDahGetObjectDesc(&info->trim1OE.obj_id,desc);
  FIg_set_text(form,VDSUP_FORM_ETC_G_TRIM1,desc);
  FIfld_set_select(form,VDSUP_FORM_ETC_G_TRIM1,0,0,0);

  VDahGetObjectDesc(&info->trim2OE.obj_id,desc);
  FIg_set_text(form,VDSUP_FORM_ETC_G_TRIM2,desc);
  FIfld_set_select(form,VDSUP_FORM_ETC_G_TRIM2,0,0,0);

  retFlag = 1;
  return retFlag;
}

/* ----------------------------------------
 * Fills the curve list gadget
 */
IGRstat VDsupCMDEtcFillCurve(TVDsupEtc *info)
{
  IGRstat retFlag = 0;

  Form    form = info->form;
  IGRint  gadget = VDSUP_FORM_ETC_L_CURVES;
  IGRint  i;
  IGRchar desc[1024];

  // Init
  if (form == NULL) goto wrapup;
  FIfld_set_num_rows(form,gadget,0);

  // Cycle through
  for(i = 0; i < info->crvCNT; i++) {

    // Get the desc
    VDahGetObjectDesc(&info->crvOEs[i].obj_id,desc);
    FIfld_set_text(form,gadget,i,0,desc,0);
  }

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Adds 1 object to curve list
 */
IGRstat VDsupCMDEtcAddCurve(TVDsupEtc *info, TGRobj_env *objOE)
{
  IGRstat retFlag = 0;
  IGRint  i;

  // Check for dups
  for(i = 0; i < info->crvCNT; i++) {
    if ((objOE->obj_id.objid == info->crvOEs[i].obj_id.objid) &&
        (objOE->obj_id.osnum == info->crvOEs[i].obj_id.osnum)) {
      retFlag = 1;
      goto wrapup;
    }
  }
  // Size check
  if (info->crvCNT >= 64) goto wrapup;

  // Copy it
  info->crvOEs[i] = *objOE;
  info->crvCNT++;

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ------------------------------------------
 * User picked some curves
 */
IGRstat VDsupCMDEtcNotifyCurve(TVDsupEtc *info, TGRobj_env *objOE)
{
  IGRstat retFlag = 0;
  IGRint  cnt = 0;
  IGRint  i;
  TGRobj_env *listOE = NULL;

  // Arg check
  if ((info  == NULL) || 
      (objOE == NULL) || 
      (objOE->obj_id.objid == NULL_OBJID)
  ) goto wrapup;

  // Get the objects
  as$start_fence(
    set       = &objOE->obj_id,
    set_env   = &objOE->mod_env,
    nb_obj    = &cnt,
    p_obj_env = &listOE
  );

  // Copy over non-dups
  for(i = 0; i < cnt; i++) {
    VDsupCMDEtcAddCurve(info, &listOE[i]);
  }
  ASend_fence(); // Frees listOE

  // Fill up the curve gadget
  VDsupCMDEtcFillCurve(info);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ------------------------------------------
 * Form notification routine
 */
IGRstat VDsupCMDEtcNotifyForm(TVDsupEtc *info)
{
  IGRstat retFlag = 0;
  IGRint  msg;

  // Ignore if special locate in progress
  if (info->selInProgress) goto wrapup;

  switch(info->gadget) {

  case FI_ACCEPT:
  case FI_EXECUTE: {
    retFlag = VDsupCMDEtcNotifyExecute(info);
    goto wrapup;
  }
  case VDSUP_FORM_ETC_G_DISTANCE: {
    retFlag = VDsupCMDEtcNotifyExp(info);
    goto wrapup;
  }
  case VDSUP_FORM_ETC_B_HILITE_SEL: {
    retFlag = VDsupCMDEtcNotifyHiLite(info,1);
    goto wrapup;
  }
  case VDSUP_FORM_ETC_B_HILITE_ALL: {
    retFlag = VDsupCMDEtcNotifyHiLite(info,0);
    goto wrapup;
  }
  case VDSUP_FORM_ETC_B_UNHILITE: {
    dp$erase_hilite(msg = &msg);
    goto wrapup;
  }
  case VDSUP_FORM_ETC_B_DROP_CURVES: {
    retFlag = VDsupCMDEtcNotifyDropCurves(info);
    goto wrapup;
  }
  case VDSUP_FORM_ETC_L_CURVES: {
    retFlag = VDsupCMDEtcNotifyCurves(info);
    goto wrapup;
  }
  case VDSUP_FORM_ETC_G_ETC: {
    retFlag = VDsupCMDEtcNotifyEtc(info);
    goto wrapup;
  }
  case VDSUP_FORM_ETC_G_TRIM1: {
    retFlag = VDsupCMDEtcNotifyTrim1(info);
    goto wrapup;
  }
  case VDSUP_FORM_ETC_G_TRIM2: {
    retFlag = VDsupCMDEtcNotifyTrim2(info);
    goto wrapup;
  }
  case FI_RESET: {
    retFlag = VDsupCMDEtcInit(info);
    goto wrapup;
  }
  } // switch
wrapup:
  return retFlag;
}

/* --------------------------------------
 * Misc stuff
 */
#argsused
IGRstat VDsupCMDEtcInit(TVDsupEtc *info)
{
  IGRint retFlag = 0;
  IGRint msg,sts;

  dp$erase_hilite(msg = &msg);

  info->trim1OE.obj_id.objid = NULL_OBJID;
  info->trim2OE.obj_id.objid = NULL_OBJID;

  info->disID.objid = NULL_OBJID;
  info->etcID.objid = NULL_OBJID;

  info->crvCNT = 0;

  sts = gr$get_module_env(buffer = &info->env);
  if (!(sts & 1)) goto wrapup;
  
  retFlag = 1;
wrapup:
  return retFlag;
}
#argsused
IGRstat VDsupCMDEtcSleep(TVDsupEtc *info)
{
  IGRint msg;
  if (info);
  dp$erase_hilite(msg = &msg);
  return 1;
}
#argsused
IGRstat VDsupCMDEtcWakeup(TVDsupEtc *info)
{
  VDsupCMDEtcNotifyHiLite(info,1);
  return 1;
}
#argsused
IGRstat VDsupCMDEtcDelete(TVDsupEtc *info)
{
  IGRint msg;
  if (info);
  dp$erase_hilite(msg = &msg);
  return 1;
}

end   implementation VDsupGen;
