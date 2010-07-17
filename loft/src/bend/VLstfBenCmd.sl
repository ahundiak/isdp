command_string  VLC_M_PLInBeLn, 0, VLInBeLi
command_table   "vl.cmd"
class           VLstfBenCmd
super_class     VLlocateCmd
product_name    "$LOFT"

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
#define MY_ERROR        530

instance
{
   variable struct GRobj_env		stiff[1];
   IGRint 				nb_stiff;
   IGRint				web;
   IGRint				which_web;
   struct GRid				webL;
   struct GRid				webR;
}
implementation

#include "AS_status.h"
#include "msdef.h"
#include "vlmsg.h"
#include "expmacros.h"
#include "expression.h"
#include "DIdef.h"
#include "nddef.h"
#include "coparamac.h"
#include "grmacros.h"
#include "VDSudp_mac.h"
#include "VDSpathdef.h"
#include "vssectiondef.h"
#include "vlglobals.h"

#define MY_ERROR        530
#define LEFT            542
#define RIGHT           543
/*************************************************************************/

state_table

#include "griodef.h"
#include "msdef.h"
#include "vlmsg.h"
#define MY_ERROR        530
#define LEFT            542
#define RIGHT           543

state start
  message_key             VL_S_PL_INV_BEND_LN

  execute		  VLwhichWeb
  on RETURN_CODE = LEFT  state web_left
  on RETURN_CODE = RIGHT state web_right 

state web_left
  prompt_key	 VL_P_WEBL_OPTION
  filter         get_event

  on EX_DATA        state first_stiff
  on EX_RJT_MOVEON  do VLchangeWeb(&me->ret)
                                                    state first_stiff

state web_right
  prompt_key     VL_P_WEBR_OPTION
  filter         get_event

  on EX_DATA        state first_stiff
  on EX_RJT_MOVEON  do VLchangeWeb(&me->ret)
                                                    state first_stiff

state first_stiff
        prompt_key              VL_P_STIFBEAM
        accept_key              VL_M_ACC_STIFBEAM
        locate_class            "VSbeam"
        locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_DP_ONLY | LC_RW"

        filter                  locate

        on EX_BACK_UP  state start

        on EX_OBJID or EX_STRING or EX_DATA  
                    do   VLcontrol_stiff
                    do   VLchaine_locate
						  state stiff

state stiff
        message_key             VL_S_PL_INV_BEND_LN
        prompt_key              VL_P_STIFBEAM_OR_MVO
        accept_key              VL_M_ACC_STIFBEAM
        locate_class            "VSbeam"
        locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_DP_ONLY | LC_RW"

        filter                  locate

        on EX_RJT_MOVEON                          state lower

        on EX_OBJID or EX_STRING or EX_DATA  
                    do   VLcontrol_stiff
                    on RETURN_CODE = MY_ERROR              state .
                    do   VLchaine_locate
						  state .

state lower
  prompt_key     VL_P_LOWER
  filter         get_event

  on EX_BACK_UP  state -
  on EX_DATA     do VLinverse
                 on RETURN_CODE = MY_ERROR              state .
                                                        state first_stiff

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*    actions defined in VLinvMethod.I                                     */

action VLinverse (long *sts) extern
action VLcontrol_stiff (long *sts) extern
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

action VLwhichWeb (long *sts)
{
  status = status; // to avoid warning during compilation
  if (me->which_web == LEFT) {
    *sts = LEFT;
     me->web = LEFT;
  }
  else {
    *sts = RIGHT;
    me->web = RIGHT;
  }
  goto quit;// to avoid warning during compilation
}

action VLchangeWeb (long *sts)
{
  status = status;// to avoid warning during compilation 
  if (me->web == LEFT) me->web = RIGHT;
  else me->web = LEFT;
  goto quit;// to avoid warning during compilation
}

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

action init
{
long 	loc_msg;
double	val;

  /* Execute method init of supper class */
   status  = om$send ( msg      = message VLstfBenCmd.init( type, str_ptr),
                       mode     = OM_e_wrt_parent,
                       targetid = my_id );
  if (!(status & 1))
  {
    printf("error at VLstfBenCmd.init\n");
    me->state = _terminate;
    return ( OM_I_STOP_SENDING );
  }
  me->nb_stiff = 0;
  status = om$send(msg = message VLstfBenCmd.VLgetGlobals
                                              (&loc_msg,NAM_G_STW,&val),
                       targetid = my_id);
  if (!(status&loc_msg&1)) {
    me->which_web = me->web = RIGHT;
  }
  else {
    if (val == 1) me->which_web = me->web = LEFT;
    else me->which_web = me->web = RIGHT;
  }
  me->webR.osnum = me->ModuleInfo.md_id.osnum;
  me->webR.objid = NULL_OBJID;
  exp$create( exp_name = NULL,
              exp_syntax = VS_K_nmWebR,
              p_exp_id = &(me->webR.objid),
              osnum = me->ModuleInfo.md_id.osnum,
              type_rq = EXP_TEXT );
  me->webL.osnum = me->ModuleInfo.md_id.osnum;
  me->webL.objid = NULL_OBJID;
  exp$create( exp_name = NULL,
              exp_syntax = VS_K_nmWebL,
              p_exp_id = &(me->webL.objid),
              osnum = me->ModuleInfo.md_id.osnum,
              type_rq = EXP_TEXT );
  goto quit;
}
