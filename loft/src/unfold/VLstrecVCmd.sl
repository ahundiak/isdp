command_string  VLC_M_CRESTRVLPL, 0, VLCrStVaPl
command_table   "vl.cmd"
class           VLstrecVCmd
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
#include "gr.h"
#include "VDSpathdef.h"
#include "DItypedef.h"
#include "vlstrechval.h"
#define MY_ERROR        530

instance
{
  int	 			nb_step_in_u;
  int	 			nb_step_in_v;
  variable struct GRobj_env	unw_obj[1];
  int				nb_unw;
}

implementation

#include "AS_status.h"
#include "msdef.h"
#include "vlmsg.h"
#include "expmacros.h"
#include "expression.h"
#include "DIdef.h"
#include "nddef.h"
#include "gr.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "coparamac.h"
#include "vluserkey.h"
#define MY_ERROR        530
extern  GRclassid       OPP_VLstretchV_class_id;
from    VLstretchV	import	create;
from     NDnode         import  NDdelete;
from     GRowner        import  GRget_number_components;
  
/*************************************************************************/

state_table

#include "griodef.h"
#include "msdef.h"
#include "vlmsg.h"
#define MY_ERROR        530

state start
  message_key          VL_S_CRESTRVLPL
  prompt_key           VL_P_UNWRAP
  accept_key           VL_M_ACC_NT_UNW
  locate_class         "VLunwrap, VLunwObj"
  locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                        LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  filter               locate

  on EX_DATA or EX_OBJID
            do VLcontrol_unw(&me->ret)
                       on RETURN_CODE = MY_ERROR        state .
            do VLchaine_locate
                                                        state loc_unw
state loc_unw
  prompt_key           VL_P_UNWRAPMO
  accept_key           VL_M_ACC_NT_UNW
  locate_class         "VLunwrap, VLunwObj"
  locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                        LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  filter               locate

  on EX_RJT_MOVEON                                      state get_step_in_u
  on EX_DATA or EX_OBJID
            do VLcontrol_unw(&me->ret)
            do VLchaine_locate
                                                        state .
	
state get_step_in_u
  prompt_key           VL_P_STEPU_ON_UNW_SURF 
  locate_mask         "GRm_STRING | GRm_OBJID | GRm_RJT_MOVEON | GRm_BACK_UP"
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                           LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  filter              get_event
  on EX_BACK_UP                                         state -
  on EX_STRING             
               do VLcontrol_value(&me->ret,1)
                       on RETURN_CODE = MY_ERROR        state .
							state get_step_in_v

state get_step_in_v
  prompt_key           VL_P_STEPV_ON_UNW_SURF
  locate_mask         "GRm_STRING | GRm_OBJID | GRm_RJT_MOVEON | GRm_BACK_UP"
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                           LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  filter              get_event
  on EX_BACK_UP                                         state -
  on EX_STRING             
               do VLcontrol_value(&me->ret,2)
                       on RETURN_CODE = MY_ERROR        state .
               do VLplace_mac(&me->ret)
                       on RETURN_CODE = MY_ERROR        state .
							state start

at init do VLmy_cob_init


action VLcontrol_value (long *sts; int index)
{
  status = 1; // to avoid warning messages during compilation
  if (index == 1) {
    sscanf(me->event1.event.keyin,"%d",&(me->nb_step_in_u));
    if (me->nb_step_in_u == 0 || me->nb_step_in_u == 1) me->nb_step_in_u = 2;
  }
  else {
    sscanf(me->event1.event.keyin,"%d",&(me->nb_step_in_v));
    if (me->nb_step_in_v == 0 || me->nb_step_in_v == 1) me->nb_step_in_v = 2;
  }
  goto quit;    // to avoid warning messages during compilation
}

action VLplace_mac
{
struct GRid 		MAC;
IGRlong      		loc_msg;
int		        i,nb;
char        		word[DI_PATH_MAX];
enum    GRdpmode        dpmode=GRbd;

  for (i=0;i<me->nb_unw;i++)
  {
    MAC.objid  = NULL_OBJID;
    MAC.osnum  = me->ModuleInfo.md_id.osnum;
    status = om$construct (classid = OPP_VLstretchV_class_id,
                           osnum   = MAC.osnum,
                           p_objid = &(MAC.objid));
    if (!(status&1)) {
        ex$message(msgnumb = VL_E_BadPlc,time=0,seconds=0);
        me->ret= *sts = MY_ERROR;
        goto quit;
    }
    status = om$send( msg = message VLstretchV.create(  &loc_msg,
                                                  &(me->unw_obj[i]),
                                                  me->nb_step_in_u,
                                                  me->nb_step_in_v,
                                                  &(me->ModuleInfo)),
               targetid = MAC.objid,
               targetos = MAC.osnum);
    if (!(status&loc_msg&1)) {
      me->ret= *sts = MY_ERROR;
      goto quit;
    }
            /* check if there is physical foot */
    nb = 0;
    status = om$send ( msg = message GRowner.GRget_number_components
                                                ( &loc_msg, &nb),
                        targetid = MAC.objid,
                        targetos = MAC.osnum  );
    if (!nb) continue;

    if(!(VLgetName(&(me->unw_obj[i].obj_id),word)))
     strcpy(word,"Defined");
    status = om$send(msg = message VLstrecVCmd.VLsetSymbNameDisp(
                                      &loc_msg,
                                      word,
                                      STRETCV_KEY,
                                      &(me->unw_obj[i].obj_id),
                                      MAC,
                                      &dpmode),
                  targetid = my_id );
    if(!(status & loc_msg & 1))
      ex$message(msgnumb = VL_E_BadChgName);
  }
  me->nb_unw = 0;
}

/* get unwrap */
action VLcontrol_unw (long *sts)
{
struct GRobj_env	*LocatedObjects;
int			nb_obj,nb_supprim;
int			i,j;

  status = 1; // to avoid warning messages during compilation
  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects,
                 response = me->response,
                 response_data = me->response_data);

  if (nb_obj == 0)
  {
    me->ret = *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_NoObjLoc,time=0,seconds=0);
    goto quit;
  }
  /* Verify the located objects aren't already in the list */
  nb_supprim = 0;
  for (i=0; i<nb_obj;i++)
  {
    for (j=0; j<me->nb_unw;j++)
    {
      if (me->unw_obj[j].obj_id.objid == LocatedObjects[i].obj_id.objid)
      {
        LocatedObjects[i].obj_id.objid = NULL_OBJID;/* it is already here */
        nb_supprim++;
        break;
      }
    }
  }

  if (nb_supprim)
    ex$message(msgnumb = VL_E_ObjInList,time=0,seconds=0);

  if(nb_obj - nb_supprim + me->nb_unw >
                                om$dimension_of( varray = me->unw_obj)) {
    om$vla_set_dimension(varray = me->unw_obj,size =
                                      nb_obj-nb_supprim+me->nb_unw);
  }
  
  for (i=0; i<nb_obj; i++)
  {
    if (LocatedObjects[i].obj_id.objid == NULL_OBJID) continue;
    me->unw_obj[i+me->nb_unw] = LocatedObjects[i];
  }
  me->nb_unw += nb_obj - nb_supprim;
  goto quit;// to avoid warning messages during compilation 
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
action VLmy_cob_init
{
  status = 1;  // to avoid warning messages during compilation
  me->nb_unw = 0;
  me->nb_step_in_u =2;
  me->nb_step_in_v =2;
  goto quit;           // to avoid warning messages during compilation
}
