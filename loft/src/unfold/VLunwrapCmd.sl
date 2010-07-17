command_string  VLC_M_UNWRP, 0, VLUnSu
command_table   "vl.cmd"
class           VLunwrapCmd
super_class     VLlocateCmd
product_name    "$LOFT"
status_display  "VLunwrap.frm", "-1", "-1"

start_state     start

specification

#include <stdio.h>
#include "msdef.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "macro.h"
#include "griodef.h"
#include "growner.h"
#include "DItypedef.h"
#include "VDSpathdef.h"
#include "vlunfold.h"
#include "vlglobals.h"
#define MY_ERROR        530

instance
{
               // parameters to put in the ACrg collection
  double			options[UNFOLD_NB_OPT];
  int    			optlines[UNFOLD_NB_OPTLINE];

  int	 			nb_surf; // number of surfaces
  variable struct GRobj_env	surf[1]; // list of surfaces
}

implementation

#include "AS_status.h"
#include "FI.h"
#include "msdef.h"
#include "vlmsg.h"
#include "expmacros.h"
#include "expression.h"
#include "DIdef.h"
#include "nddef.h"
#include "coparamac.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "vlunfold.h"
%safe
static int xx=-1,yy,heig,wid,screen;
%endsafe
#define MY_ERROR        530
/*************************************************************************/

state_table

#include "griodef.h"
#include "msdef.h"
#include "vlmsg.h"
#include "VDSpathdef.h"
#include "vlunfold.h"
#define MY_ERROR        530

state start
  status_key           VL_S_STATUS_FORM
  message_key          VL_S_UNWRAP
  prompt_key           VL_P_SURFACE_OR_PLATE
  accept_key           VL_M_ACC_NT_SURF
  locate_class         "EMSsubbs,VSimgFeature,VSplate"
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
  locate_class         "EMSsubbs,VSimgFeature,VSplate"
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
 me->ret = om$send ( msg      = message VLunwrapCmd.wakeup (pos),
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
int    i;

   me->ret = om$send ( msg      = message VLunwrapCmd.init( type, str_ptr),
                            mode     = OM_e_wrt_parent,
                            targetid = my_id );
  as$status(sts = me->ret);

  status = om$send(msg = message VLunwrapCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_FIB,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_FIB_RATIO] = val;
  sprintf(tmp,"%.2lf",val);
  FIg_set_text(me->status_display_form_ptr,G_FIBER_RATIO,tmp);

  status = om$send(msg = message VLunwrapCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_X_EXP,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_X_EXPANSION] = val;
  sprintf(tmp,"%.2lf",val);
  FIg_set_text(me->status_display_form_ptr,G_EXP_X_SCALE,tmp);

  status = om$send(msg = message VLunwrapCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_Y_EXP,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_Y_EXPANSION] = val;
  sprintf(tmp,"%.2lf",val);
  FIg_set_text(me->status_display_form_ptr,G_EXP_Y_SCALE,tmp);

  status = om$send(msg = message VLunwrapCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_UNW_SURF,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_SRFWANTED] = val;
  FIg_set_state(me->status_display_form_ptr,G_UNW_SURF,(int) val);

  status = om$send(msg = message VLunwrapCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_WATONPLATE,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_WATONPLATE] = val;
  FIg_set_state(me->status_display_form_ptr,G_WATONPLATE,(int) val);

  status = om$send(msg = message VLunwrapCmd.VLgetGlobals
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

  status = om$send(msg = message VLunwrapCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_SIDE,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_SIDE] = val;
  if (me->options[UNFOLD_ATT_IDX_SIDE] == BASE_SIDE)
    FIg_set_text(me->status_display_form_ptr,G_SIDE,"Base");
  else 
    if (me->options[UNFOLD_ATT_IDX_SIDE] == OFFSET_SIDE)
      FIg_set_text(me->status_display_form_ptr,G_SIDE,"Offset");
    else 
      FIg_set_text(me->status_display_form_ptr,G_SIDE,"Max Marking");

  status = om$send(msg = message VLunwrapCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_TESS,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 0;
  }
  me->options[UNFOLD_ATT_IDX_TESSELATION] = val;
  FIg_set_state(me->status_display_form_ptr,G_TESSELATION,(int) val);

  status = om$send(msg = message VLunwrapCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_UNW_CODE,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    val = 31;
  }
  me->options[UNFOLD_ATT_IDX_LINES] = val;
  VLdecode((int) val,UNFOLD_NB_OPTLINE,me->optlines);
  for ( i=0; i<UNFOLD_NB_OPTLINE; i++)
  {
    FIfld_set_select ( me->status_display_form_ptr, G_LINES, i, 0, 
                       me->optlines[i]);
  }

  me->nb_surf = 0;

  goto quit;
}
