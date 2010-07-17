/* $Id: VLunwextCmd.sl,v 1.3 2002/06/07 14:16:57 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwextCmd.sl
 *
 * Description: 'Unwrap Extraction' Command Object.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwextCmd.sl,v $
 *      Revision 1.3  2002/06/07 14:16:57  ramarao
 *      Fixed TR# 6175. Defalut value for Fiber Ratio will be 0.5.
 *
 *      Revision 1.2  2001/01/16 20:01:25  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/09/13  20:05:52  pinnacle
# Created: loft/src/unwext/VLunwextCmd.sl by rchennup for Service Pack
#
# Revision 1.3  1999/06/01  16:25:22  pinnacle
# (No comment)
#
# Revision 1.2  1998/06/01  15:53:58  pinnacle
# Replaced: src/unwext/VLunwextCmd.sl for:  by smpathak for loft
#
# Revision 1.1  1997/10/28  15:27:50  pinnacle
# Created: src/unwext/VLunwextCmd.sl by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *      06/01/98   Sandeep      File modification for 179800719
 *************************************************************************/

command_string  VLC_M_UNWEXT, 0, VLUnExt
command_table   "vl.cmd"
class           VLunwextCmd
super_class     VLlocateCmd
product_name    "$LOFT"
status_display  "VLunwext.frm", "-1", "-1"

start_state     start

specification

#include <stdio.h>
#include "go.h"
#include "vlunfold.h"
#include "vlunwext.h"

#define MY_ERROR        530

instance
{
               // parameters to put in the ACrg collection
  double			options[UNFOLD_NB_OPT];
  int    			optlines[UNWEXT_NB_OPT];
  char                          setup_file[DI_PATH_MAX];
  int	 			nb_surf; // number of surfaces
  variable struct GRobj_env	surf[1]; // list of surfaces
}

implementation

#include "AS_status.h"
#include "dpmacros.h"
#include "vlmsg.h"
#include "vlglobals.h"

%safe
static int xx=-1,yy,heig,wid,screen;
%endsafe
#define MY_ERROR        530

/*************************************************************************/

state_table

#include "griodef.h"
#include "msdef.h"
#include "vlmsg.h"

state start
  status_key           VL_S_STATUS_FORM
  message_key          VL_S_UNWEXT
  prompt_key           VL_P_PLATE
  accept_key           VL_M_PLATE
  locate_class         "VSimgFeature,VSplate"
  locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                        LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  filter               locate

  on EX_DATA or EX_OBJID
            do VLcontrol_surf (&me->ret)  
                   on MY_ERROR  state .
            do VLchaine_locate
                                       state loc_surf

state loc_surf
  prompt_key           VL_P_SURF_OR_MVO
  accept_key           VL_M_ACC_NT_SURF
  locate_class         "VSimgFeature,VSplate"
  locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                        LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  filter               locate

  on EX_RJT_MOVEON		       state lower

  on EX_DATA or EX_OBJID
            do VLcontrol_surf (&me->ret)
                   on MY_ERROR  state .
            do VLchaine_locate
                                       state .

state lower
  status_key           VL_S_STATUS_FORM
  prompt_key     VL_P_LOWER
  filter         get_event

  on EX_BACK_UP	 state -
  on EX_DATA     
                   do VLgo_unwrap(&me->ret)
                     on RETURN_CODE = MY_ERROR             state .
                                                         state start
at sleep do erase_hilite
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  actions defined in VLunwMethod.I				            */

action VLcontrol_surf extern
action VLgo_unwrap extern
action save_all extern
action form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr ) extern
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VLchaine_locate
{
IGRlong msg;
IGRlong size = sizeof(struct GRevent) - sizeof(long)*2;

    status = ex$putque(msg = &msg,byte=&size,response=(IGRint *)&me->ret,
                       buffer = (IGRchar *) &me->event1.event);
    if (!(status&msg&1)) {
      printf("Pbs In Queue\n");
      me->ret = MY_ERROR;
      goto quit;
    }
}

action erase_hilite
{
int     loc_msg;

  status = dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);

  FIf_get_size(me->status_display_form_ptr,&heig,&wid);
  FIf_get_location(me->status_display_form_ptr,&xx,&yy);
  FIf_get_screen(me->status_display_form_ptr,&screen);
  ex$message(msgnumb=VL_E_Blank);

goto quit;
}

action wakeup
{
 status = 1;
 /* Execute method wakeup of upper class */
 me->StatusDisplay = TRUE;
 me->ret = om$send ( msg      = message VLunwextCmd.wakeup (pos),
                     mode     = OM_e_wrt_parent,
                     targetid = my_id );
  as$status(sts = me->ret);

  if (xx != -1 ) {
    FIf_set_location(me->status_display_form_ptr, xx,yy);
    FIf_set_size(me->status_display_form_ptr, heig,wid);
    FIf_set_screen(me->status_display_form_ptr, screen);
  }
  ex$message(msgnumb=VL_S_STATUS_FORM);
  goto quit;
}

action init
{
long loc_msg;
double val;
char   tmp[50];
int    i,code;

   me->ret = om$send ( msg      = message VLunwextCmd.init( type, str_ptr),
                            mode     = OM_e_wrt_parent,
                            targetid = my_id );
  as$status(sts = me->ret);

  status = om$send(msg = message VLunwextCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_FIB,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0.5;
  }
  me->options[UNFOLD_ATT_IDX_FIB_RATIO] = val;
  sprintf(tmp,"%.2lf",val);
  FIg_set_text(me->status_display_form_ptr,G_FIBER_RATIO,tmp);

  me->options[UNFOLD_ATT_IDX_UNWOPT] = 0.0;

  status = om$send(msg = message VLunwextCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_X_EXP,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_X_EXPANSION] = val;
  sprintf(tmp,"%.2lf",val);
  FIg_set_text(me->status_display_form_ptr,G_EXP_X_SCALE,tmp);

  status = om$send(msg = message VLunwextCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_Y_EXP,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_Y_EXPANSION] = val;
  sprintf(tmp,"%.2lf",val);
  FIg_set_text(me->status_display_form_ptr,G_EXP_Y_SCALE,tmp);

  status = om$send(msg = message VLunwextCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_UNW_SURF,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_SRFWANTED] = val;
  FIg_set_state(me->status_display_form_ptr,G_UNW_SURF,(int) val);

  status = om$send(msg = message VLunwextCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_WATONPLATE,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_WATONPLATE] = val;
  FIg_set_state(me->status_display_form_ptr,G_WATONPLATE,(int) val);

  status = om$send(msg = message VLunwextCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_T_EXP,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_EXPTYPE] = val;

  if (me->options[UNFOLD_ATT_IDX_EXPTYPE] == NO_EXPANSION) {
    FIg_erase(me->status_display_form_ptr,G_EXP_X_SCALE);
    FIg_erase(me->status_display_form_ptr,G_EXP_Y_SCALE);
    FIg_erase(me->status_display_form_ptr,G_EXP_X_TEXT);
    FIg_erase(me->status_display_form_ptr,G_EXP_Y_TEXT);
    FIg_set_text(me->status_display_form_ptr,G_EXP_TYPE,"No Expansion");
  }
  else 
    if (me->options[UNFOLD_ATT_IDX_EXPTYPE] == GLOBAL_LW_RATIO)
      FIg_set_text(me->status_display_form_ptr,G_EXP_TYPE,"Global Expansion");
    else 
      FIg_set_text(me->status_display_form_ptr,G_EXP_TYPE,
                   "Expansion by Marking");

  status = om$send(msg = message VLunwextCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_SIDE,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_SIDE] = val;
  if (me->options[UNFOLD_ATT_IDX_SIDE] == BASE_SIDE)
    FIg_set_text(me->status_display_form_ptr,G_SIDE,"Base");
  else if (me->options[UNFOLD_ATT_IDX_SIDE] == OFFSET_SIDE)
      FIg_set_text(me->status_display_form_ptr,G_SIDE,"Offset");
  else if (me->options[UNFOLD_ATT_IDX_SIDE] == BASE_FLIP)
    FIg_set_text(me->status_display_form_ptr,G_SIDE,"Base-Flip");
  else if (me->options[UNFOLD_ATT_IDX_SIDE] == OFFSET_FLIP)
      FIg_set_text(me->status_display_form_ptr,G_SIDE,"Offset-Flip");

  status = om$send(msg = message VLunwextCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_TESS,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_TESSELATION] = val;
  FIg_set_state(me->status_display_form_ptr,G_TESSELATION,(int) val);

// Modified for 179800719  By Sandeep Pathak.
  status = om$send(msg = message VLunwextCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_UNW_CODE,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
printf("\n VLgetGlobals failed for NAM_G_UNW_CODE ");
    val = 31;
  }
  me->options[UNFOLD_ATT_IDX_LINES] = val;

  VLdecode((int) val, UNWEXT_NB_OPT ,me->optlines);
  for ( i=0; i< UNWEXT_NB_OPT ; i++)
  {
    if( i<UNWEXT_ATT_IDX_PARENT )
    FIfld_set_select ( me->status_display_form_ptr, G_LINES, i, 0, 
                       me->optlines[i]);
    else
       FIfld_set_select(me->status_display_form_ptr, G_PRCOPT,
                        i-UNWEXT_ATT_IDX_PARENT, 0, me->optlines[i]);
  }
/*
  FIfld_set_select ( me->status_display_form_ptr, G_PRCOPT, 
			UNWEXT_OPT_PARENT, 0, 0 );
  me->optlines[UNWEXT_ATT_IDX_PARENT] = 0;

  FIfld_set_select ( me->status_display_form_ptr, G_PRCOPT, 
			UNWEXT_OPT_ADDFEAT, 0, 1 );
  me->optlines[UNWEXT_ATT_IDX_ADDFEAT] = 1;

  FIfld_set_select ( me->status_display_form_ptr, G_PRCOPT, 
			UNWEXT_OPT_AUTOMRK, 0, 0 );
  me->optlines[UNWEXT_ATT_IDX_AUTOMRK] = 0;

  FIfld_set_select ( me->status_display_form_ptr, G_PRCOPT,
			UNWEXT_OPT_ADDSTOK, 0, 1 );
  me->optlines[UNWEXT_ATT_IDX_ADDSTOK] = 1;
*/
  VLencode ( me->optlines, UNWEXT_NB_OPT, &code);
  me->options[UNFOLD_ATT_IDX_LINES] = code;

  me->nb_surf = 0;

  goto quit;
}
