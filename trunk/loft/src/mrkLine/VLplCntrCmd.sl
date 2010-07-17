/*d-----------------------------------------------------------------------------


        Class Name:     VLplCntrCmd

        Abstract:       Place Control Line Command

------------------------------------------------------------------------------*/

command_string  VLC_M_CONTROL_LINE, 0, VLPlCoLi
synonym         VLC_M_MODIFY_CNTRL, 1, VLMoCoLi
command_table   "vl.cmd"
class           VLplCntrCmd
super_class     VLlocateCmd
product_name    "$LOFT"

start_state     start

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
#include "DItypedef.h"
#include "VDSpathdef.h"
#include "vlctrl.h"

instance
{
  IGRint			locate_add;
  IGRint			locate_del;
  IGRint			locate_modif;
  variable struct GRobj_env  	cl_line[1];
  variable struct GRobj_env     old_cl_line[1];
  variable int      		num_cl_line[2];
  variable int         		old_num_cl_line[2];
  int                   	nb_cl_line;
  int                   	old_nb_cl_line;
  struct GRid			to_modify;
  struct GRid			old_to_modify;
  IGRchar			*form_ptr;
  struct GRid			box;
  IGRchar			plate_side[100];
  IGRint			one_or_all;
  IGRchar			axis;
}

implementation

#include "AS_status.h"
#include "vlmsg.h"
#include "expmacros.h"
#include "expression.h"
#include "DIdef.h"
#define AS_DEBUG	1
#include "nddef.h"
#include "VDSpathdef.h"
#include "vlctrl.h"

extern void COB_FI_form_notification();
from GRgraphics import GRdisplay;
from	NDnode	import	NDchg_state;

%safe
static int xx=-1,yy,heig,wid,screen;
%endsafe
/*************************************************************************/

state_table

#include "griodef.h"
#include "vlmsg.h"
#include "vlctrl.h"


state start
  on CMD_TYPE = 0     do
			message_key	VL_S_CONTROL_LINE
                        state loc_surf
on CMD_TYPE = 1     do message_key	VL_S_MOD_CNTLINE
			state loc_line
state loc_surf
  prompt	       "Identify Struct Plate(s)/Move on"
  accept_key           VL_M_PLATE
  locate_class         "+VSimgFeature,VSplate"
  locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                        LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  filter	       locate

  on EX_BACK_UP	       					state -
  on EX_DATA or  EX_OBJID
               do VLcontrol_surf (&me->ret)
               do VLchaine_locate
                  on RETURN_CODE = MY_ERROR            	state .
               						state .
  on EX_RJT_MOVEON                                      do VLerase_hilite1
							state modify_form

state loc_line
  prompt_key	       VL_P_CNTLINE
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                        LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_eligible      "VLctrLine"
  filter               locate

  on EX_BACK_UP						 state -
  on EX_DATA or EX_STRING or EX_OBJID
               do VLcontrol_line
                  on RETURN_CODE = MY_ERROR           	 state .
                                                	 state modify_form
  on EX_RJT_MOVEON                                       do VLerase_hilite1
							 state modify_form

state modify_form
 prompt_key		VL_P_ChForm
 filter			get_event

  on GR_UNKNOWN_TYPE.ADD			  	 state loc_surf
  on GR_UNKNOWN_TYPE.MOD_D		  		 state loc_line
  on EX_BACK_UP				  		 state -

at init	do VLform_init
at sleep do VLerase_hilite
at delete do VLerase_frm
at wakeup do VLform_pos
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in VLcntMethod.I                                         */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

action form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr ) extern
action VLsave_all extern

action VLcontrol_line extern

action VLcontrol_surf extern

action VLadd_1_surf (int *msg ; struct GRid *obj) extern

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
    goto quit;
}
 
action VLerase_hilite1
{
int	loc_msg;

  status = dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);
  FIg_set_state_off(me->form_ptr,G_DELETE);
  FIg_set_state_off(me->form_ptr,G_ADD);
  FIg_set_state_off(me->form_ptr,G_MODIF);
  goto quit;
}

action VLerase_hilite
{
int	loc_msg;

  status = dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);
  FIf_get_size(me->form_ptr,&heig,&wid);
  FIf_get_location(me->form_ptr,&xx,&yy);
  FIf_get_screen(me->form_ptr,&screen);
  FIg_disable(me->form_ptr,G_ADD);
  FIg_disable(me->form_ptr,G_DIRECTION);
  FIg_disable(me->form_ptr,G_DELETE);
  FIg_disable(me->form_ptr,G_LIST_SURF);
  FIg_disable(me->form_ptr,G_CTRL_NAME);
  FIg_disable(me->form_ptr,G_PLATE_SIDE);
  FIg_disable(me->form_ptr,G_ONE_OR_ALL);
  FIg_disable(me->form_ptr,FI_ACCEPT);
  FIg_disable(me->form_ptr,FI_EXECUTE);
  FIg_disable(me->form_ptr,FI_RESET);
  FIg_disable(me->form_ptr,FI_CANCEL);
  FIg_disable(me->form_ptr,G_MODIF);
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
  FIg_enable(me->form_ptr,G_ADD);
  FIg_enable(me->form_ptr,G_DIRECTION);
  FIg_enable(me->form_ptr,G_DELETE);
  FIg_enable(me->form_ptr,G_LIST_SURF);
  FIg_enable(me->form_ptr,G_CTRL_NAME);
  FIg_enable(me->form_ptr,G_PLATE_SIDE);
  FIg_enable(me->form_ptr,G_ONE_OR_ALL);
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

action VLform_init
{

/***** covered by superclass

  status = om$send(msg    = message CEO_LOCATE.init( type, str_ptr ),
                   mode   = OM_e_wrt_message,
		   targetid = my_id);

  if (!(status & 1))
  {
    printf("error at CEO_LOCATE.init\n");
    me->state = _terminate;
    return ( OM_I_STOP_SENDING );
  }

**********/

  status = 1;
  me->form_ptr = NULL ;
  FIf_new( 1,
           "VLcntrLine",
           COB_FI_form_notification,
           &me->form_ptr ) ;
  FIf_set_cmd_oid_os( me->form_ptr, my_id, OM_Gw_current_OS ) ;
  if (xx != -1 ) {
    FIf_set_location(me->form_ptr, xx,yy);
    FIf_set_size(me->form_ptr, heig,wid);
    FIf_set_screen(me->form_ptr, screen);
  }
  me->locate_add = 0;
  me->locate_del = 0;
  me->locate_modif = 0;
  me->nb_cl_line = 0;
  me->old_nb_cl_line = 0;
  me->to_modify.objid = NULL_OBJID;
  me->old_to_modify.objid = NULL_OBJID;

   if (me->mytype == 0)  {
     FIg_set_text(me->form_ptr,G_TITLE,"Place Control Line");
     FIg_erase(me->form_ptr,G_MODIF);
   }
   else {
     FIg_set_text(me->form_ptr,G_TITLE,"Modify Control Line");
     FIg_erase(me->form_ptr,G_ONE_OR_ALL);
     FIfld_set_text(me->form_ptr,G_DIRECTION,0,
                    0, "",FALSE);
     FIfld_set_default_text(me->form_ptr,G_DIRECTION,0,
                            0, "",FALSE);
   }
  FIf_display( me->form_ptr ) ;
  goto quit;
}
