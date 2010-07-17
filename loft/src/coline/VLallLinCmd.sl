/*
  File           VLallLinCmd.sl 
  Creation Date  december 92

  History:
*/


command_string       VLC_M_PLACE_BASE_BUTT,   		0, VLPlBsBt
synonym              VLC_M_PLACE_WATER_LINE,  		1, VLPlWtLn
synonym              VLC_M_PLACE_BASE_SEAM,   		2, VLPlBsSm
synonym              VLC_M_PLACE_CURVED_BUTT, 		3, VLPlCrBt
synonym              VLC_M_PLACE_CURVED_SEAM, 		4, VLPlCrSm
synonym              VLC_M_TRACE_ELEMENT,     		5, VLTrEl
synonym              VLC_M_MODIFY_BASE_BUTT,  		6, VLMdBsBt
synonym              VLC_M_MODIFY_BASE_SEAM,  		7, VLMdBsSm
synonym              VLC_M_MODIFY_WATER_LINE, 		8, VLMdWtLn
synonym              VLC_M_MODIFY_CURVED_BUTT,		9, VLMdCrBt
synonym              VLC_M_MODIFY_CURVED_SEAM,		10, VLMdCrSm
synonym              VLC_M_MODIFY_TRACED_ELEMENT,	11, VLMdTrEl
command_table        "vl.cmd"
class                VLallLinCmd
super_class          VLgenLinCmd
product_name         "$LOFT"

/*form "VLallLine",0,2,0,0*/

specification

#include <stdio.h>
#include "FI.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "macro.h"
#include "griodef.h"
#include "growner.h"
#include "vlglinedef.h"
#include "DItypedef.h"
#include "VDSudp_mac.h"
#include "vlbline.h"
#include "VDSpathdef.h"

instance
{
  variable struct GRid	info[1];
  int			nb_info;
  variable struct GRid	old_info[1];
  int			old_nb_info;
  struct GRid		cs_plug;
}

implementation

#include "AS_status.h"
#include "vlmsg.h"
#include "expmacros.h"
#include "expression.h"
#include "DIdef.h"
#include "vlbline.h"
#include "nddef.h"
#include "VDSpathdef.h"

extern void COB_FI_form_notification();
extern struct GRid MANwk_hull;
%safe
static int xx=-1,yy,heig,wid,screen;
%endsafe
from GRgraphics import GRdisplay;
from	NDnode	import	NDchg_state;

/*************************************************************************/

state_table

#include "griodef.h"
#include "vlglinedef.h"
#include "vlmsg.h"
#include "vlbline.h"
#include "VDSpathdef.h"

state start
  on CMD_TYPE = 0     do
                        message_key     VL_M_PlBButt
                        state is_hull_here
  on CMD_TYPE = 1     do
                        message_key     VL_M_PlWatL 
                        state is_hull_here
  on CMD_TYPE = 2     do
                        message_key     VL_M_PlBSeam
                        state is_hull_here
  on CMD_TYPE = 3     do
                        message_key     VL_M_PlCurvButt
                        state is_hull_here
  on CMD_TYPE = 4     do
                        message_key     VL_M_PlCurvSeam
                        state is_hull_here
  on CMD_TYPE = 5     do
                        message_key     VL_M_TraceEL
                        state is_hull_here
  on CMD_TYPE = 6     do
                        message_key     VL_M_ModBButt
                        state loc_butt

  on CMD_TYPE = 7     do
                        message_key     VL_M_ModBSeam
                        state loc_seam

  on CMD_TYPE = 8     do
                        message_key     VL_M_ModWat
                        state loc_wat
  on CMD_TYPE = 9     do
                        message_key     VL_M_ModCurButt
                        state loc_butt
  on CMD_TYPE = 10     do
                        message_key     VL_M_ModCurSeam
                        state loc_seam
  on CMD_TYPE = 11     do
                        message_key     VL_M_ModTracedEl
                        state loc_trace

state is_hull_here
    on CMD_TYPE <= 5          do  VLis_hull_defined (&me->ret, G_HULL_NAME)
                                  on RETURN_CODE = YES	state def_info
                        		                state locate_hull

state loc_butt
   prompt_key           VL_P_LocButts
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "+VLbutLine"
   filter               locate

   on EX_DATA or EX_STRING or EX_OBJID
                do VLcontrol_line
                   on RETURN_CODE = MY_ERROR            state .
                                                        state modify_form

state loc_seam
   prompt_key           VL_P_LocSeam
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "+VLseaLine"
   filter               locate

   on EX_DATA or EX_STRING or EX_OBJID
                do VLcontrol_line
                   on RETURN_CODE = MY_ERROR            state .
                                                        state modify_form
state loc_wat
   prompt_key           VL_P_LocWatLn
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "+VLwatLine"
   filter               locate

   on EX_DATA or EX_STRING or EX_OBJID
                do VLcontrol_line
                   on RETURN_CODE = MY_ERROR            state .
                                                        state modify_form
state loc_trace
   prompt_key           VL_P_LocTracedEl
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "+VLtrace"
   filter               locate

   on EX_DATA or EX_STRING or EX_OBJID
                do VLcontrol_line
                   on RETURN_CODE = MY_ERROR            state .
                                                        state modify_form
state modify_form
   prompt_key           VL_P_ChForm
   filter       get_event

        on GR_UNKNOWN_TYPE.INFO_D                 state def_info
        on GR_UNKNOWN_TYPE.HULL                   state locate_hull
        on GR_UNKNOWN_TYPE.SEL_PT                 state locate_sel_pt
        on GR_UNKNOWN_TYPE.CS                     state vect_def
        on GR_UNKNOWN_TYPE.ALLOWDIR               state vect_def
        on GR_UNKNOWN_TYPE.MOD1_D                 state locate_butt
        on GR_UNKNOWN_TYPE.MOD2_D                 state locate_seam
        on GR_UNKNOWN_TYPE.MOD3_D                 state locate_wat
        on GR_UNKNOWN_TYPE.MOD4_D                 state locate_trace
        on GR_UNKNOWN_TYPE.MOD                    state modify_form
        on GR_UNKNOWN_TYPE.RET_INFO               state def_info
        on GR_UNKNOWN_TYPE.POINT                  state locate_point2
	on GR_UNKNOWN_TYPE.RESET_ALL		  state start
   	on EX_BACK_UP                             state -

state locate_butt
   prompt_key           VL_P_LocButts
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "+VLbutLine"
   filter               locate


   on EX_DATA or EX_STRING or EX_OBJID
                do VLcontrol_line
                   on RETURN_CODE = MY_ERROR            state .
                                                        state modify_form

   on EX_RJT_MOVEON                                      do VLerase_hilite1
                                                        state modify_form
   on EX_BACK_UP                                        state -

state locate_seam
   prompt_key           VL_P_LocSeam
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "+VLseaLine"
   filter               locate


   on EX_DATA or EX_STRING or EX_OBJID
                do VLcontrol_line
                   on RETURN_CODE = MY_ERROR            state .
                                                        state modify_form

   on EX_RJT_MOVEON                                      do VLerase_hilite1
                                                        state modify_form
   on EX_BACK_UP                                        state -
 
state locate_wat
   prompt_key           VL_P_LocWatLine
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "+VLwatLine"
   filter               locate


   on EX_DATA or EX_STRING or EX_OBJID
                do VLcontrol_line
                   on RETURN_CODE = MY_ERROR            state .
                                                        state modify_form
   on EX_BACK_UP                                        state -

   on EX_RJT_MOVEON                                      do VLerase_hilite1
                                                        state modify_form

state locate_trace
   prompt_key           VL_P_LocTracedEl
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "+VLtrace"
   filter               locate

   on EX_DATA or EX_STRING or EX_OBJID
                do VLcontrol_line
                   on RETURN_CODE = MY_ERROR            state .
                                                        state modify_form
   on EX_BACK_UP                                        state -

   on EX_RJT_MOVEON                                      do VLerase_hilite1
                                                        state modify_form

state locate_hull
   prompt_key		VL_P_LocHullMO
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "+EMSsurface"
   filter		locate


   on EX_DATA or EX_STRING or EX_OBJID
	    do VLcontrol_hull(&me->ret,G_HULL_NAME,G_HULL,G_BUTT_NAME,me->mytype)
		   on RETURN_CODE = MY_ERROR            state .
							state def_info

   on EX_RJT_MOVEON                                      do VLerase_hilite1
                                                        state modify_form
 
   on EX_BACK_UP                                         state -

state def_info
    prompt_key  	VL_P_LocInfo
    locate_mask		"GRm_STRING | GRm_DATA | GRm_SCALAR | GRm_VALUE
			 | GRm_OBJID"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
    filter		get_event


   on EX_DATA           do VLchaine_locate(&me->ret,EX_DATA,0,0,0)
			  on RETURN_CODE = MY_ERROR	state .
							state locate_info

   on EX_OBJID           do VLchaine_locate(&me->ret,EX_OBJID,0,0,0)
			  on RETURN_CODE = MY_ERROR	state .
							state locate_info

    on EX_STRING 
              		do VLcontrol_exp_info
			  on RETURN_CODE = MY_ERROR	state .
							state modify_form

    on EX_VALUE
              		do VLcontrol_value
			  on RETURN_CODE = MY_ERROR	state .
							state modify_form

   on EX_RJT_MOVEON                                      do VLerase_hilite1
                                                        state modify_form
 
   on EX_BACK_UP                                         state -

state locate_info
    locate_eligible     "+GRbspline,+EMSsurface,EMSplane,GRcompcurve"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
    filter              locate

  on EX_DATA or EX_OBJID
                      do VLcontrol_info
                          on RETURN_CODE = MY_ERROR     state .
                                                        state modify_form

   on EX_RJT_MOVEON                                      do VLerase_hilite1
                                                        state modify_form
 
   on EX_BACK_UP                                         state -

state vect_def
    prompt_key          VL_P_DefDir
    locate_mask         "GRm_STRING | GRm_DATA | GRm_SCALAR | GRm_VALUE
                         | GRm_OBJID"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
    filter              get_event


   on EX_DATA           do VLchaine_locate(&me->ret,EX_DATA,0,0,0)
                          on RETURN_CODE = MY_ERROR     state .
                          on RETURN_CODE =  POINT      state locate_point2
                          on RETURN_CODE =  MODE       state modify_form
							state locate_vect

   on EX_OBJID           do VLchaine_locate(&me->ret,EX_OBJID,0,0,0)
                          on RETURN_CODE = MY_ERROR     state .
                          on RETURN_CODE =  POINT      state locate_point2
                                                        state locate_vect

    on EX_STRING
                        do VLcontrol_exp (&me->ret,G_CS, G_ALLOW_DIR) 
                          on RETURN_CODE = MY_ERROR     state .
                          on RETURN_CODE =  POINT      state locate_point2
                                                        state modify_form

  on EX_RJT_MOVEON                                      do VLerase_hilite1
							state modify_form

  on EX_BACK_UP                                         state -


state locate_vect
    locate_eligible     "+GR3dpoint,GR3dlineseg,GRgencs"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
    filter              locate


  on EX_DATA or EX_OBJID
                      do VLcontrol_data(&me->ret,G_CS, G_ALLOW_DIR)
                          on RETURN_CODE = MY_ERROR     state .
                          on RETURN_CODE =  POINT      state locate_point2
                                                        state modify_form

  on EX_RJT_MOVEON                                      do VLerase_hilite1
							state modify_form
  on EX_BACK_UP						state -

state locate_point2
    prompt_key          VL_P_LocPoint2
    locate_mask         "GRm_STRING | GRm_DATA | GRm_SCALAR | GRm_VALUE
                         | GRm_OBJID"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
    filter              get_event

        on GR_UNKNOWN_TYPE.MOD                  state modify_form

   on EX_DATA           do VLchaine_locate(&me->ret,EX_DATA,0,0,0)
                          on RETURN_CODE = MY_ERROR     state .
                          on GR_UNKNOWN_TYPE.MOD        state modify_form
                                                        state locate_pt2

   on EX_OBJID           do VLchaine_locate(&me->ret,EX_OBJID,0,0,0)
                          on RETURN_CODE = MY_ERROR     state .
                                                        state locate_pt2


    on EX_STRING
                        do VLcontrol_exp2(&me->ret, G_CS, G_ALLOW_DIR)
                          on RETURN_CODE = MY_ERROR     state .
                                                        state modify_form

  on EX_RJT_MOVEON                                      do VLerase_hilite1
							state modify_form

  on EX_BACK_UP                                         state -


state locate_pt2
   locate_eligible      "+GR3dpoint"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   filter               locate

    on EX_DATA or EX_OBJID
                    do VLcontrol_pt2(&me->ret, G_CS, G_ALLOW_DIR)
                          on RETURN_CODE = MY_ERROR     state .
                                                        state modify_form

    on EX_RJT_MOVEON                                      do VLerase_hilite1
							state modify_form

    on EX_BACK_UP                                         state -

state locate_sel_pt
    prompt_key          VL_P_LocSelPt
    locate_mask         "GRm_STRING | GRm_DATA | GRm_SCALAR | GRm_VALUE
                         | GRm_OBJID"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
    filter              get_event

   on EX_DATA           do VLchaine_locate(&me->ret,EX_DATA,G_SEL_PT_NAME,
                                     G_SELECT_PT,1)
                          on RETURN_CODE = MY_ERROR     state .
                          on GR_UNKNOWN_TYPE.MOD        state modify_form
                          on RETURN_CODE =  POINT      state modify_form
                                                        state loc_sel_pt

   on EX_OBJID           do VLchaine_locate(&me->ret,EX_OBJID,G_SEL_PT_NAME,
                                     G_SELECT_PT,1)
                          on RETURN_CODE = MY_ERROR     state .
                                                        state loc_sel_pt


    on EX_STRING
                        do VLcontrol_exp_sel(&me->ret,G_SEL_PT_NAME,G_SELECT_PT)
                          on RETURN_CODE = MY_ERROR     state .
                                                        state modify_form

  on EX_RJT_MOVEON                                      do VLerase_hilite1
							state modify_form

  on EX_BACK_UP                                         state -


state loc_sel_pt
   locate_eligible      "+GR3dpoint"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   filter               locate

    on EX_DATA or EX_OBJID
                    do VLcontrol_sel_pt(&me->ret,G_SEL_PT_NAME,G_SELECT_PT)
                          on RETURN_CODE = MY_ERROR     state .
                                                        state modify_form

    on EX_RJT_MOVEON                                      do VLerase_hilite1
							state modify_form

    on EX_BACK_UP                                         state -

at sleep do VLerase_hilite
at wakeup do VLform_pos
at delete do VLerase_frm
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in VLallMethod.I                                         */

action form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr ) extern

action VLsave_all extern

action VLcontrol_info extern

action VLcontrol_line extern

action VLcontrol_value extern

action VLcontrol_exp_info extern

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 
action VLerase_hilite
{
int	loc_msg;

  status = dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);
  FIf_get_size(me->form_ptr,&heig,&wid);
  FIf_get_location(me->form_ptr,&xx,&yy);
  FIf_get_screen(me->form_ptr,&screen);
  FIg_disable(me->form_ptr,G_DATA);
  FIg_disable(me->form_ptr,G_HULL);
  FIg_disable(me->form_ptr,G_CS);
  FIg_disable(me->form_ptr,G_HULL_NAME);
  FIg_disable(me->form_ptr,G_DATA_NAME);
  FIg_disable(me->form_ptr,G_BUTT_NAME);
  FIg_disable(me->form_ptr,G_ALLOW_DIR);
  FIg_disable(me->form_ptr,G_ALLOWENCE);
  FIg_disable(me->form_ptr,G_EXTRA_ALLOW);
  FIg_disable(me->form_ptr,G_SELECT_PT);
  FIg_disable(me->form_ptr,G_SEL_PT_NAME);
  FIg_disable(me->form_ptr,G_CS);
  FIg_disable(me->form_ptr,FI_ACCEPT);
  FIg_disable(me->form_ptr,FI_EXECUTE);
  FIg_disable(me->form_ptr,FI_RESET);
  FIg_disable(me->form_ptr,FI_CANCEL);
  FIg_disable(me->form_ptr,G_MODIF);
  goto quit;
}

action VLerase_hilite1
{
int	loc_msg;

  status = dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);
  FIg_set_state_off(me->form_ptr,G_DATA);
  FIg_set_state_off(me->form_ptr,G_HULL);
  FIg_set_state_off(me->form_ptr,G_SELECT_PT);
  FIg_set_state_off(me->form_ptr,G_MODIF);
  me->locate_hull = 0;
  me->locate_prev = 0;
  me->locate_pt_select = 0;
  me->locate_modif = 0;
  me->point2 = 0;
  goto quit;
}

action VLform_pos
{
  status = 1;
  if (xx != -1 ) {
    FIf_set_location(me->form_ptr, xx,yy);
    FIf_set_size(me->form_ptr, heig,wid);
    FIf_set_screen(me->form_ptr, screen);
  }
  FIg_enable(me->form_ptr,G_DATA);
  FIg_enable(me->form_ptr,G_HULL);
  FIg_enable(me->form_ptr,G_CS);
  FIg_enable(me->form_ptr,G_HULL_NAME);
  FIg_enable(me->form_ptr,G_DATA_NAME);
  FIg_enable(me->form_ptr,G_BUTT_NAME);
  FIg_enable(me->form_ptr,G_ALLOW_DIR);
  FIg_enable(me->form_ptr,G_ALLOWENCE);
  FIg_enable(me->form_ptr,G_EXTRA_ALLOW);
  FIg_enable(me->form_ptr,G_SELECT_PT);
  FIg_enable(me->form_ptr,G_SEL_PT_NAME);
  FIg_enable(me->form_ptr,G_CS);
  FIg_enable(me->form_ptr,FI_ACCEPT);
  FIg_enable(me->form_ptr,FI_EXECUTE);
  FIg_enable(me->form_ptr,FI_RESET);
  FIg_enable(me->form_ptr,FI_CANCEL);
  FIg_enable(me->form_ptr,G_MODIF);
  goto quit;
}

action VLerase_frm
{
  status = 1;
  FIf_erase(me->form_ptr);
  goto quit;
}

action init
{
char			pt_name[50], cur_name[50];
struct  GRsymbology     symb;
IGRchar                 tar_dir[DI_PATH_MAX];
IGRlong			msg;

  status = om$send(msg    = message VLlocateCmd.init( type, str_ptr ),
                   mode   = OM_e_wrt_message,
		   targetid = my_id);

  if (!(status & 1))
  {
    printf("error at VLlocateCmd.init\n");
    me->state = _terminate;
    return ( OM_I_STOP_SENDING );
  }
  me->form_ptr = NULL ;
  FIf_new( 1,
           "VLallLine",
           COB_FI_form_notification,
           &me->form_ptr ) ;
  FIf_set_cmd_oid_os( me->form_ptr, my_id, OM_Gw_current_OS ) ;
  if (xx != -1 ) {
    FIf_set_location(me->form_ptr, xx,yy);
    FIf_set_size(me->form_ptr, heig,wid);
    FIf_set_screen(me->form_ptr, screen);
  }
  /*me->form_ptr = me->forms[0].form_ptr;*/
  me->hull = MANwk_hull;
  me->old_hull = MANwk_hull;
  me->nb_info = 0;
  me->old_nb_info = 0;
  me->to_modify.objid= NULL_OBJID;
  me->old_to_modify.objid= NULL_OBJID;
  me->locate_hull = 0;
  me->locate_prev = 0;
  me->locate_pt_select = 0;
  me->locate_modif = 0;
  me->point2 = 0;
  me->old_point2 = 0;
  me->box.objid = NULL_OBJID;
  me->allowence = 0;
  me->ext_allow = 0;
  me->cs.osnum = me->ModuleInfo.md_id.osnum;
  exp$create(exp_name = NULL,
                 exp_syntax = "CS",
                 p_exp_id = &me->cs.objid,
                 osnum = me->cs.osnum,
                 type_rq = EXP_TEXT);
  // change state
  om$send( msg	= message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH),
	   targetid = me->cs.objid,
	   targetos = me->cs.osnum );
  me->old_cs = me->cs;
  me->cs_plug = me->cs;
  me->pt_select.osnum = me->ModuleInfo.md_id.osnum;
  exp$create(exp_name = NULL,
                 exp_syntax = "PT_SELECT",
                 p_exp_id = &me->pt_select.objid,
                 osnum = me->pt_select.osnum,
                 type_rq = EXP_TEXT);
  om$send( msg	= message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH),
	   targetid = me->pt_select.objid,
	   targetos = me->pt_select.osnum );

  me->old_pt_select = me->pt_select;
  me->pt_plug = me->pt_select;
  me->allow_dir.osnum = me->ModuleInfo.md_id.osnum;
  exp$create(exp_name = NULL,
                 exp_syntax = "ALLOW_DIR",
                 p_exp_id = &me->allow_dir.objid,
                 osnum = me->allow_dir.osnum,
                 type_rq = EXP_TEXT);
  om$send( msg	= message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH),
	   targetid = me->allow_dir.objid,
	   targetos = me->allow_dir.osnum );

  me->old_allow_dir = me->allow_dir;
  me->al_plug = me->allow_dir;
  switch (me->mytype) {

  case 0 :
    FIg_erase(me->form_ptr,G_MODIF);
    FIg_set_text(me->form_ptr,G_TITLE,"Place Base Butt");
    /* Prepare a default name to use for created butt */
    if (me->hull.objid != NULL_OBJID) {
       FIg_get_text(me->form_ptr,G_BUTT_NAME,cur_name);
       if ( cur_name[0] == '\0' ) strcpy( cur_name, "BButt" );
       status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                           &msg,
                                                           "butt",
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                         targetid = my_id);
       if (!(status&msg&1))
         ex$message(msgnumb = VL_E_BadChgSymb);
       FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
       FIfld_set_default_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
     }
     break;
  
    case 1 :
    FIg_erase(me->form_ptr,G_MODIF);
    FIg_set_text(me->form_ptr,G_TITLE,"Place Water Line");
    /* Prepare a default name to use for created butt */
    if (me->hull.objid != NULL_OBJID) {
       FIg_get_text(me->form_ptr,G_BUTT_NAME,cur_name);
       if ( cur_name[0] == '\0' ) strcpy( cur_name, "WaterL");
       status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                           &msg,
                                                           "watline",
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                         targetid = my_id);
       if (!(status&msg&1))
         ex$message(msgnumb = VL_E_BadChgSymb);
       FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
       FIfld_set_default_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
     }
       FIg_erase(me->form_ptr,G_ALLOW_DIR);
       FIg_erase(me->form_ptr,G_ALLOWENCE);
       FIg_erase(me->form_ptr,G_EXTRA_ALLOW);
       FIg_erase(me->form_ptr,G_EXTRA_TXT);
       FIg_erase(me->form_ptr,G_ALLOW_TXT);
       FIg_erase(me->form_ptr,G_VALUE_TXT);
       FIg_erase(me->form_ptr,G_ALLOW_DIR_TXT);
    break;
    case 2 :
    FIg_erase(me->form_ptr,G_MODIF);
    FIg_set_text(me->form_ptr,G_TITLE,"Place Base Seam");
    /* Prepare a default name to use for created butt */
    if (me->hull.objid != NULL_OBJID) {
       FIg_get_text(me->form_ptr,G_BUTT_NAME,cur_name);
       if ( cur_name[0] == '\0' ) strcpy( cur_name, "BSeam");
       status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                           &msg,
                                                           "seam",
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                         targetid = my_id);
       if (!(status&msg&1))
         ex$message(msgnumb = VL_E_BadChgSymb);
       FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
       FIfld_set_default_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
     }
    break;
    case 3 :
    FIg_erase(me->form_ptr,G_MODIF);
    FIg_set_text(me->form_ptr,G_TITLE,"Place Curved Butt");
    /* Prepare a default name to use for created butt */
    if (me->hull.objid != NULL_OBJID) {
       FIg_get_text(me->form_ptr,G_BUTT_NAME,cur_name);
       if ( cur_name[0] == '\0' ) strcpy( cur_name, "CButt");
       status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                           &msg,
                                                           "butt",
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                         targetid = my_id);
       if (!(status&msg&1))
         ex$message(msgnumb = VL_E_BadChgSymb);
       FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
       FIfld_set_default_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
     }
    break;
    case 4 :
    FIg_erase(me->form_ptr,G_MODIF);
    FIg_set_text(me->form_ptr,G_TITLE,"Place Curved Seam");
    /* Prepare a default name to use for created butt */
    if (me->hull.objid != NULL_OBJID) {
       FIg_get_text(me->form_ptr,G_BUTT_NAME,cur_name);
       if ( cur_name[0] == '\0' ) strcpy( cur_name, "CSeam");
       status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                           &msg,
                                                           "seam",
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                         targetid = my_id);
       if (!(status&msg&1))
         ex$message(msgnumb = VL_E_BadChgSymb);
       FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
       FIfld_set_default_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
     }
    break;
    case 9 :
    case 6 :
    if (me->mytype == 9)
      FIg_set_text(me->form_ptr,G_TITLE,"Modify Curved Butt");
    else
      FIg_set_text(me->form_ptr,G_TITLE,"Modify Base Butt");
    FIfld_set_text(me->form_ptr,G_CS,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_CS,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_ALLOW_DIR,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_ALLOW_DIR,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_SELECT_PT,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_SELECT_PT,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_ALLOWENCE,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_ALLOWENCE,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_EXTRA_ALLOW,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_EXTRA_ALLOW,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_SEL_PT_NAME,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_SEL_PT_NAME,0,
                            0, "",FALSE);
    break;
    case 10 :
    case 7 :
    if (me->mytype == 10)
      FIg_set_text(me->form_ptr,G_TITLE,"Modify Curved Seam");
    else
      FIg_set_text(me->form_ptr,G_TITLE,"Modify Base Seam");
    FIfld_set_text(me->form_ptr,G_CS,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_CS,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_ALLOW_DIR,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_ALLOW_DIR,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_SELECT_PT,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_SELECT_PT,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_ALLOWENCE,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_ALLOWENCE,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_EXTRA_ALLOW,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_EXTRA_ALLOW,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_SEL_PT_NAME,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_SEL_PT_NAME,0,
                            0, "",FALSE);
     break;
    case 8 :
    FIg_set_text(me->form_ptr,G_TITLE,"Modify Water Line");
    FIfld_set_text(me->form_ptr,G_CS,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_CS,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_SELECT_PT,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_SELECT_PT,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_SEL_PT_NAME,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_SEL_PT_NAME,0,
                            0, "",FALSE);
     FIg_erase(me->form_ptr,G_ALLOWENCE);
     FIg_erase(me->form_ptr,G_ALLOW_DIR);
     FIg_erase(me->form_ptr,G_EXTRA_ALLOW);
     FIg_erase(me->form_ptr,G_EXTRA_TXT);
     FIg_erase(me->form_ptr,G_ALLOW_TXT);
     FIg_erase(me->form_ptr,G_VALUE_TXT);
     FIg_erase(me->form_ptr,G_ALLOW_DIR_TXT);
     break;

  case 5 :
    FIg_erase(me->form_ptr,G_ALLOWENCE);
    FIg_erase(me->form_ptr,G_ALLOW_DIR);
    FIg_erase(me->form_ptr,G_EXTRA_ALLOW);
    FIg_erase(me->form_ptr,G_EXTRA_TXT);
    FIg_erase(me->form_ptr,G_ALLOW_TXT);
    FIg_erase(me->form_ptr,G_VALUE_TXT);
    FIg_erase(me->form_ptr,G_ALLOW_DIR_TXT);
    FIg_erase(me->form_ptr,G_MODIF);
    FIg_set_text(me->form_ptr,G_TITLE,"Place Trace Element");
    /* Prepare a default name to use for created traced elements */
    if (me->hull.objid != NULL_OBJID) {
       FIg_get_text(me->form_ptr,G_BUTT_NAME,cur_name);
       if ( cur_name[0] == '\0' ) strcpy( cur_name, "Trace");
       status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                           &msg,
                                                           "trace",
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                         targetid = my_id);
       if (!(status&msg&1))
         ex$message(msgnumb = VL_E_BadChgSymb);
       FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
       FIfld_set_default_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
     }
     break;

    case 11 :
    FIg_set_text(me->form_ptr,G_TITLE,"Modify Trace Element");
    FIfld_set_text(me->form_ptr,G_CS,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_CS,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_SELECT_PT,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_SELECT_PT,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_SEL_PT_NAME,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_SEL_PT_NAME,0,
                            0, "",FALSE);
     FIg_erase(me->form_ptr,G_ALLOWENCE);
     FIg_erase(me->form_ptr,G_ALLOW_DIR);
     FIg_erase(me->form_ptr,G_EXTRA_ALLOW);
     FIg_erase(me->form_ptr,G_EXTRA_TXT);
     FIg_erase(me->form_ptr,G_ALLOW_TXT);
     FIg_erase(me->form_ptr,G_VALUE_TXT);
     FIg_erase(me->form_ptr,G_ALLOW_DIR_TXT);
     break;

  
  }
  FIf_display( me->form_ptr ) ;
  goto quit;
}
