/* 
  File           VLbutLinCmd.sl 
  Creation Date  November 92

  History:
*/


command_string       VLC_M_PLACE_NEXT_BUTT,0,VLPlNtBt
synonym              VLC_M_MODIFY_NEXT_BUTT,1,VLMdNtBt
command_table        "vl.cmd"
class                VLbutLinCmd
super_class          VLgenLinCmd
product_name         "$LOFT"

/*form "VLbutLine",0,2,0,0*/

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
#include "VDSpathdef.h"
#include "vlbutt.h"

instance
{
  IGRdouble		width;
}

implementation

#include "AS_status.h"
#include "vlmsg.h"
#include "expmacros.h"
#include "expression.h"
#include "DIdef.h"
#include "vlbutt.h"
#include "VDSpathdef.h"
#define AS_DEBUG	1
#include "nddef.h"

extern struct GRid MANwk_hull;
extern void COB_FI_form_notification();
from GRgraphics import GRdisplay;
from	NDnode	import	NDchg_state;

%safe
static int xx=-1,yy,heig,wid,screen;
%endsafe
/*************************************************************************/

state_table

#include "griodef.h"
#include "vlglinedef.h"
#include "vlmsg.h"
#include "vlbutt.h"
#include "VDSpathdef.h"


state start
  on CMD_TYPE = 0     do
			message_key	VL_M_PlcButt
                        state is_hull_here

  on CMD_TYPE = 1     do
                        message_key	VL_M_ModButt
			state loc_butt

state is_hull_here
    on CMD_TYPE = 0          do  VLis_hull_defined (&me->ret, G_HULL_NAME)
                                  on RETURN_CODE = YES  state locate_butt
                                                        state locate_hull

state loc_butt
   prompt_key		VL_P_LocButts
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "+VLbutLine"
   filter		locate

   on EX_DATA or EX_STRING or EX_OBJID
                do VLcontrol_butt
                   on RETURN_CODE = MY_ERROR            state .
                					state modify_form

state modify_form
   prompt_key		VL_P_ChForm
   filter	get_event

	on GR_UNKNOWN_TYPE.PREV			  state locate_butt
	on GR_UNKNOWN_TYPE.HULL			  state locate_hull
	on GR_UNKNOWN_TYPE.ADD			  state locate_waterL
	on GR_UNKNOWN_TYPE.DIRECT		  state vect_def
	on GR_UNKNOWN_TYPE.ALLOWDIR		  state vect_def
	on GR_UNKNOWN_TYPE.SEL_PT		  state locate_sel_pt
	on GR_UNKNOWN_TYPE.MOD_D		  state loc_butt1
	on GR_UNKNOWN_TYPE.MOD		          state modify_form
	on GR_UNKNOWN_TYPE.RET_INFO	          state locate_butt
        on GR_UNKNOWN_TYPE.POINT                  state locate_point2
        on GR_UNKNOWN_TYPE.RESET_BUTT             state start
        on EX_BACK_UP				  state -

state locate_hull
   prompt_key		VL_P_LocHullMO
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "+EMSsurface"
   filter		locate

   on EX_DATA or EX_STRING or EX_OBJID
		do VLcontrol_hull(&me->ret,G_HULL_NAME,G_HULL,G_BUTT_NAME,6)
		   on RETURN_CODE = MY_ERROR            state .
							state locate_butt

  on EX_RJT_MOVEON			do VLerase_hilite1
					state modify_form

  on EX_BACK_UP                                       state -

state locate_waterL
   prompt_key		VL_P_LocWatLine
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "VLwatLine"
   filter		locate

  on EX_DATA or EX_STRING or EX_OBJID
             do VLcontrol_cl_line(&me->ret, 0, G_LIST_WATER)
                  on RETURN_CODE = MY_ERROR            state .
                                                        state .

  on EX_RJT_MOVEON			do VLerase_hilite1
					state modify_form

  on EX_BACK_UP                                       state -


   
state locate_butt
   prompt_key		VL_P_LocButtsMO
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "+VLbutLine"
   filter		locate

   on EX_DATA or EX_STRING or EX_OBJID
              do VLcontrol_obj(&me->ret,0,G_PREV_NAME,G_PREV)
                   on RETURN_CODE = MY_ERROR            state .
                   on RETURN_CODE = INVALID_BUTT            	
					do status "Invalid butt selected"
					state .
          				state locate_waterL

  on EX_RJT_MOVEON			do VLerase_hilite1
					state modify_form

  on EX_BACK_UP                                       state -

state loc_butt1
   prompt_key		VL_P_LocButts
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   locate_eligible      "+VLbutLine"
   filter		locate

   on EX_DATA or EX_STRING or EX_OBJID
                do VLcontrol_butt
                   on RETURN_CODE = MY_ERROR            state .
                					state modify_form
  on EX_RJT_MOVEON			do VLerase_hilite1
					state modify_form

  on EX_BACK_UP                                       state -

state vect_def
    prompt_key		VL_P_DefDir
    locate_mask		"GRm_STRING | GRm_DATA | GRm_SCALAR | GRm_VALUE
			 | GRm_OBJID"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
    filter		get_event

   on EX_DATA           do VLchaine_locate(&me->ret,EX_DATA,0,0,0)
			  on RETURN_CODE = MY_ERROR	state .
	                  on RETURN_CODE = MOD	state modify_form
	                  on RETURN_CODE = POINT	state locate_point2
							state locate_vect

   on EX_OBJID           do VLchaine_locate(&me->ret,EX_OBJID,0,0,0)
			  on RETURN_CODE = MY_ERROR	state .
							state locate_vect

    on EX_STRING 
              		do VLcontrol_exp (&me->ret,G_DIRECTION, G_ALLOW_DIR)
			  on RETURN_CODE = MY_ERROR	state .
	                  on RETURN_CODE = POINT	state locate_point2
							state modify_form

  on EX_RJT_MOVEON			do VLerase_hilite1
					state modify_form

  on EX_BACK_UP                                       state -


state locate_vect
    locate_eligible	"+GR3dpoint,GR3dlineseg,GRgencs"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
    filter		locate

  on EX_DATA or EX_OBJID 
                      do VLcontrol_data(&me->ret,G_DIRECTION, G_ALLOW_DIR)
			  on RETURN_CODE = MY_ERROR	state .
	                  on RETURN_CODE = POINT	state locate_point2
							state modify_form

  on EX_RJT_MOVEON			do VLerase_hilite1
					state modify_form
  on EX_BACK_UP                                       state -

state locate_point2
    prompt_key	        VL_P_LocPoint2
    locate_mask		"GRm_STRING | GRm_DATA | GRm_SCALAR | GRm_VALUE
			 | GRm_OBJID"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
    filter		get_event

        on GR_UNKNOWN_TYPE.MOD                  state modify_form
 
   on EX_DATA           do VLchaine_locate(&me->ret,EX_DATA,0,0,0)
			  on RETURN_CODE = MY_ERROR	state .
	                  on RETURN_CODE = MOD	state modify_form
							state locate_pt2

   on EX_OBJID           do VLchaine_locate(&me->ret,EX_OBJID,0,0,0)
			  on RETURN_CODE = MY_ERROR	state .
							state locate_pt2

    on EX_STRING 
              		do VLcontrol_exp2 (&me->ret,G_DIRECTION,G_ALLOW_DIR)
			  on RETURN_CODE = MY_ERROR	state .
							state modify_form

  on EX_RJT_MOVEON					state modify_form

  on EX_BACK_UP                                         state -


state locate_pt2
   locate_eligible      "+GR3dpoint"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
   filter		locate

    on EX_DATA or EX_OBJID 
                    do VLcontrol_pt2(&me->ret, G_DIRECTION, G_ALLOW_DIR)
		  	  on RETURN_CODE = MY_ERROR	state .
							state modify_form
    on EX_RJT_MOVEON                                    state modify_form

    on EX_BACK_UP                                       state -

state locate_sel_pt
    prompt_key          VL_P_LocSelPt
    locate_mask         "GRm_STRING | GRm_DATA | GRm_SCALAR | GRm_VALUE
                         | GRm_OBJID"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
    filter              get_event

   on EX_DATA       do VLchaine_locate(&me->ret,EX_DATA,G_SEL_PT_NAME,
				     G_SELECT_PT,1)
                          on RETURN_CODE = MY_ERROR     state .
	                  on RETURN_CODE = MOD	state modify_form
	                  on RETURN_CODE = POINT	state modify_form
                                                        state loc_sel_pt

   on EX_OBJID           do VLchaine_locate(&me->ret,EX_OBJID,G_SEL_PT_NAME,
					  G_SELECT_PT,1) 
                          on RETURN_CODE = MY_ERROR     state .
                                                        state loc_sel_pt
    on EX_STRING
                        do VLcontrol_exp_sel (&me->ret,G_SEL_PT_NAME,G_SELECT_PT)
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
                    do VLcontrol_sel_pt (&me->ret,G_SEL_PT_NAME,G_SELECT_PT)

                          on RETURN_CODE = MY_ERROR     state .
                                                        state modify_form

    on EX_RJT_MOVEON                                      do VLerase_hilite1
                                                        state modify_form

    on EX_BACK_UP                                         state -




at sleep do VLerase_hilite
at delete do VLerase_frm
at wakeup do VLform_pos
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in VLbutMethod.I                                         */

action form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr ) extern
action VLsave_all extern

action VLcontrol_butt extern

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
  FIg_disable(me->form_ptr,G_LENGTH);
  FIg_disable(me->form_ptr,G_PREV);
  FIg_disable(me->form_ptr,G_HULL);
  FIg_disable(me->form_ptr,G_ADD);
  FIg_disable(me->form_ptr,G_DIRECTION);
  FIg_disable(me->form_ptr,G_DELETE);
  FIg_disable(me->form_ptr,G_AUTO);
  FIg_disable(me->form_ptr,G_LIST_WATER);
  FIg_disable(me->form_ptr,G_HULL_NAME);
  FIg_disable(me->form_ptr,G_PREV_NAME);
  FIg_disable(me->form_ptr,G_BUTT_NAME);
  FIg_disable(me->form_ptr,G_ALLOW_DIR);
  FIg_disable(me->form_ptr,G_ALLOWENCE);
  FIg_disable(me->form_ptr,G_EXTRA_ALLOW);
  FIg_disable(me->form_ptr,G_SELECT_PT);
  FIg_disable(me->form_ptr,G_SEL_PT_NAME);
  FIg_disable(me->form_ptr,G_DEV);
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
  FIg_set_state_off(me->form_ptr,G_PREV);
  FIg_set_state_off(me->form_ptr,G_HULL);
  FIg_set_state_off(me->form_ptr,G_ADD);
  FIg_set_state_off(me->form_ptr,G_SELECT_PT);
  FIg_set_state_off(me->form_ptr,G_MODIF);
  me->locate_hull = 0;
  me->locate_prev = 0;
  me->locate_add = 0;
  me->locate_del = 0;
  me->point2 = 0;
  me->locate_pt_select = 0;
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
  FIg_enable(me->form_ptr,G_LENGTH);
  FIg_enable(me->form_ptr,G_PREV);
  FIg_enable(me->form_ptr,G_HULL);
  FIg_enable(me->form_ptr,G_ADD);
  FIg_enable(me->form_ptr,G_DIRECTION);
  FIg_enable(me->form_ptr,G_DELETE);
  FIg_enable(me->form_ptr,G_AUTO);
  FIg_enable(me->form_ptr,G_LIST_WATER);
  FIg_enable(me->form_ptr,G_HULL_NAME);
  FIg_enable(me->form_ptr,G_PREV_NAME);
  FIg_enable(me->form_ptr,G_BUTT_NAME);
  FIg_enable(me->form_ptr,G_ALLOW_DIR);
  FIg_enable(me->form_ptr,G_ALLOWENCE);
  FIg_enable(me->form_ptr,G_EXTRA_ALLOW);
  FIg_enable(me->form_ptr,G_SELECT_PT);
  FIg_enable(me->form_ptr,G_SEL_PT_NAME);
  FIg_enable(me->form_ptr,G_DEV);
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
char		pt_name[256], cur_name[256];
int		j,loc_msg;
IGRlong		msg;
struct  GRsymbology     symb;
IGRchar			tar_dir[DI_PATH_MAX];
IGRdouble        dd;

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
           "VLbutLine",
           COB_FI_form_notification,
           &me->form_ptr ) ;
  FIf_set_cmd_oid_os( me->form_ptr, my_id, OM_Gw_current_OS ) ;
  if (xx != -1 ) {
    FIf_set_location(me->form_ptr, xx,yy);
    FIf_set_size(me->form_ptr, heig,wid);
    FIf_set_screen(me->form_ptr, screen);
  }
  me->locate_hull = 0;
  me->locate_prev = 0;
  me->locate_add = 0;
  me->locate_del = 0;
  me->locate_pt_select = 0;
  me->locate_modif = 0;
  me->point2 = 0;
  me->old_point2 = 0;
  me->nb_cl_line = 0;
  me->old_nb_cl_line = 0;
  me->hull = MANwk_hull;
  me->old_hull = MANwk_hull;
  me->previous.objid = NULL_OBJID;
  me->old_previous.objid = NULL_OBJID;
  me->to_modify.objid = NULL_OBJID;
  me->old_to_modify.objid = NULL_OBJID;
  me->box.objid = NULL_OBJID;
  me->length = 0;
  me->width = 0;
  me->dev = 0;
  me->old_dev = 0;
  me->pt_plug.osnum = me->ModuleInfo.md_id.osnum;
  exp$create(exp_name = NULL,
             exp_syntax = "PT_SELECT",
             p_exp_id = &me->pt_plug.objid,
             osnum = me->pt_plug.osnum,
             type_rq = EXP_TEXT);
  om$send( msg	= message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH),
	   targetid = me->pt_plug.objid,
	   targetos = me->pt_plug.osnum );

  me->al_plug.osnum = me->ModuleInfo.md_id.osnum;
  exp$create(exp_name = NULL,
             exp_syntax = "ALLOW_DIR",
             p_exp_id = &me->al_plug.objid,
             osnum = me->al_plug.osnum,
             type_rq = EXP_TEXT);
  om$send( msg	= message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH),
	   targetid = me->al_plug.objid,
	   targetos = me->al_plug.osnum );

    j = 1;
    dd = 2000;
    status = co$cvt_imp_to_alias(msg = &loc_msg,
                                 unit_type = GRIO_DISTANCE,
                                 working_units = &dd,
                                 osnum =  me->ModuleInfo.md_id.osnum,
                                 num_alias = &j,
                                 cvt_list = pt_name);
    j=0;
    while (pt_name[j] != ' ') j++;
    pt_name[j] = '\0';
    FIfld_set_text(me->form_ptr,G_WIDTH,0,
                   0, pt_name,FALSE);
    FIfld_set_default_text(me->form_ptr,G_WIDTH,0,
                           0, pt_name,FALSE);
    FIg_erase(me->form_ptr,G_WIDTH);
    FIg_erase(me->form_ptr,G_WIDTH_TXT);

   if (me->mytype == 0)  {
     FIg_set_text(me->form_ptr,G_TITLE,"Place Next Butt");
     FIg_erase(me->form_ptr,G_MODIF);
     status = om$send(msg = message VLbutLinCmd.VLparse_str(&loc_msg,"x",&me->cs),
                      targetid = my_id);
    if(!(status & loc_msg & 1))
      ex$message(msgnumb = VL_E_BadDir);
     me->old_cs = me->cs;
     j = 1;
     dd = 10000;
     status = co$cvt_imp_to_alias(msg = &loc_msg,
                                  unit_type = GRIO_DISTANCE,
                                  working_units = &dd,
                                  osnum =  me->ModuleInfo.md_id.osnum,
                                  num_alias = &j,
                                  cvt_list = pt_name);
     j=0;
     while (pt_name[j] != ' ') j++;
     pt_name[j] = '\0';
     FIfld_set_text(me->form_ptr,G_LENGTH,0,
                    0, pt_name,FALSE);
     FIfld_set_default_text(me->form_ptr,G_LENGTH,0,
                            0, pt_name,FALSE);
     j = 1;
     dd = 150;
     status = co$cvt_imp_to_alias(msg = &loc_msg,
                                  unit_type = GRIO_DISTANCE,
                                  working_units = &dd,
                                  osnum =  me->ModuleInfo.md_id.osnum,
                                  num_alias = &j,
                                  cvt_list = pt_name);
     j=0;
     while (pt_name[j] != ' ') j++;
     pt_name[j] = '\0';
     FIfld_set_text(me->form_ptr,G_ALLOWENCE,0,
                    0, pt_name,FALSE);
     FIfld_set_default_text(me->form_ptr,G_ALLOWENCE,0,
                            0, pt_name,FALSE);
     FIfld_set_text(me->form_ptr,G_EXTRA_ALLOW,0,
                    0, "No",FALSE);
     FIfld_set_default_text(me->form_ptr,G_EXTRA_ALLOW,0,
                            0, "No",FALSE);
     if (me->hull.objid != NULL_OBJID) {
       FIg_get_text(me->form_ptr,G_BUTT_NAME,cur_name);
       if ( cur_name[0] == '\0' ) strcpy( cur_name, "Butt" );
       status = om$send(msg = message VLbutLinCmd.VLgetSymbDirName(
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
       me->pt_select = me->pt_plug;
       me->old_pt_select = me->pt_select;
     status = om$send(msg = message VLbutLinCmd.VLparse_str
						(&loc_msg,"-x",&me->allow_dir),
                      targetid = my_id);
    if(!(status & loc_msg & 1))
      ex$message(msgnumb = VL_E_BadDir);
    me->old_allow_dir = me->allow_dir;
  }
   else {
     FIg_set_text(me->form_ptr,G_TITLE,"Modify Next Butt");
     FIfld_set_text(me->form_ptr,G_DIRECTION,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_DIRECTION,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_ALLOW_DIR,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_ALLOW_DIR,0,
                            0, "",FALSE);
     FIfld_set_text(me->form_ptr,G_SEL_PT_NAME,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_SEL_PT_NAME,0,
                            0, "",FALSE);
   }
  FIf_display( me->form_ptr ) ;
  goto quit;
}
