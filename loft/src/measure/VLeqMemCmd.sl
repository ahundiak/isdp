command_string  VLC_M_PLMISQ, 0, VLPlMiSq
command_table   "vl.cmd"
class           VLeqMemCmd
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
#define MY_ERROR        530

instance
{
          struct GRobj_env 			surf,joint;
variable  struct GRobj_env                      frames[1];
                 IGRint				nb_frame;
}

implementation

#include	"AS_status.h"
#include	"msdef.h"
#include	"vlmsg.h"
#include	"expmacros.h"
#include	"expression.h"
#include	"DIdef.h"
#include	"nddef.h"
#include	"coparamac.h"
#include	"VDSpathdef.h"
#include	"VDSudp_mac.h"
#define MY_ERROR        530
from ci_macro import init;
from GRgraphics import GRdelete;
extern  GRclassid       OPP_nci_macro_class_id;
extern char *strchr();
/*************************************************************************/

state_table

#include "griodef.h"
#include "msdef.h"
#include "vlmsg.h"
#define MY_ERROR        530

state start
        message_key             VL_S_PL_EQ
        prompt_key              VL_P_FRAME
        accept_key              VL_M_ACC_W_N_FR
        locate_eligible         "+EMSplane"
        locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_OBJID or EX_STRING or EX_DATA  
                    do   control_frames(&me->ret) 
                    do   chaine_locate
                                                      state frame

state frame
        prompt_key              VL_P_FRAME_MVO
        accept_key              VL_M_ACC_W_N_FR
        locate_eligible         "+EMSplane"
        locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_RJT_MOVEON                              state surf
        on EX_OBJID or EX_STRING or EX_DATA  
                    do   control_frames(&me->ret) 
                    do   chaine_locate
                                                      state .
state surf
  prompt_key           VL_P_SURFACE
  accept_key	       VL_M_ACC_SURF
  locate_class         "+EMSsubbs"
  locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                        LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  filter               locate

  on EX_BACK_UP                        state -
  on EX_DATA or EX_STRING or EX_OBJID
            do control_surf (&me->ret)  
              on RETURN_CODE = MY_ERROR  state .
                                         state loc_joint

state loc_joint
  message_key          VL_S_PL_EQ
  prompt_key           VL_P_JOINT
  accept_key           VL_M_LOWER_POS
  locate_class         "GRcurve"
  locate_owner         "LC_RIGID_COMP  | LC_RIGID_OWNER |
                        LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  filter               locate

  on EX_BACK_UP                                state -
  on EX_DATA or EX_STRING or EX_OBJID
             do control_joint (&me->ret)
                on RETURN_CODE = MY_ERROR      state .
                                               state .


at init do my_cob_init

action chaine_locate
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

action control_joint (int *sts)
{
IGRdouble		accept_button[3],winMat[16];
IGRlong			loc_msg;
struct  GRvg_construct  cst;
struct GRid		win,MAC,refID,TEMP[100];
IGRint			j,i,suc;

  me->joint.obj_id = me->event1.located_object[0].located_obj;
  me->joint.mod_env = me->event1.located_object[0].module_info;

  VLinitCnst(&cst);
  accept_button[0] = me->event1.event.button.x;
  accept_button[1] = me->event1.event.button.y;
  accept_button[2] = me->event1.event.button.z;
  win.objid = me->event1.event.button.objid;
  win.osnum = me->event1.event.button.osnum;
  status= VLcreWinRef(accept_button, win, (IGRboolean)TRUE,
                      &cst, (IGRboolean)FALSE, winMat, &refID, &loc_msg );
  if (!(status&loc_msg&1)) {
    me->ret = *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_BadPlc,time=0,seconds=0);
    goto quit;
  }
  TEMP[0] = refID;
  TEMP[1] = me->surf.obj_id;
  TEMP[2] = me->joint.obj_id;
  for (j=0,i=3; j< me->nb_frame;j++,i++)
    TEMP[i] = me->frames[j].obj_id; 
     
  MAC.objid  = NULL_OBJID;
  MAC.osnum  = me->ModuleInfo.md_id.osnum;
  status = om$construct (classid = OPP_nci_macro_class_id,
                         osnum   = MAC.osnum,
                         p_objid = &(MAC.objid));
  if (!(status&1)) {
    *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_BadPlc,time=0,seconds=0);
    goto quit;
  }
  status = om$send( msg = message ci_macro.init(  &suc,
                                                0,
                                                "miterSquare",
                                                i,
                                                TEMP,
                                                NULL,
                                                &(me->ModuleInfo) ),
             targetid = MAC.objid,
             targetos = MAC.osnum);
  if (!(status&suc&1)) {
    om$send( msg = message  GRgraphics.GRdelete( &loc_msg,
                                                 &(me->ModuleInfo) ),
                           targetid = TEMP[0].objid,
                           targetos = TEMP[0].osnum );
    *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_BadPlc,time=0,seconds=0);
    goto quit;
  }
}

action control_surf (int *sts)
{
  me->surf.obj_id = me->event1.located_object[0].located_obj;
  me->surf.mod_env = me->event1.located_object[0].module_info;
}

action control_frames (int *sts)
{
struct GRobj_env        *LocatedObjects;
struct GRid             tmp;
int                     nb_obj,nb_supprim;
int                     i,j;

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
    as$make_source( go_grid = LocatedObjects[i].obj_id,
                    mod_env = &LocatedObjects[i].mod_env,
                    as_os   =me->ModuleInfo.md_id.osnum ,
                    as_grid = &tmp);
    for (j=0; j<me->nb_frame;j++)
    {
      if (me->frames[j].obj_id.objid == tmp.objid)
      {
        LocatedObjects[i].obj_id.objid = NULL_OBJID;/* it is already here */
        nb_supprim++;
        break;
      }
    }
  }

  if (nb_supprim)
    ex$message(msgnumb = VL_E_ObjInList,time=0,seconds=0);

  if(nb_obj - nb_supprim + me->nb_frame >
                                om$dimension_of( varray = me->frames)) {
    om$vla_set_dimension(varray = me->frames,size =
                                      nb_obj-nb_supprim+me->nb_frame);
  }
  for (i=0; i<nb_obj; i++)
  {
    if (LocatedObjects[i].obj_id.objid == NULL_OBJID) continue;
    as$make_source( go_grid = LocatedObjects[i].obj_id,
                    mod_env = &LocatedObjects[i].mod_env,
                    as_os   =me->ModuleInfo.md_id.osnum ,
                    as_grid = &LocatedObjects[i].obj_id);
    me->frames[i+me->nb_frame] = LocatedObjects[i];
  }
  me->nb_frame += nb_obj - nb_supprim;

}

action my_cob_init
{
  me->joint.obj_id.objid = NULL_OBJID;
  me->surf.obj_id.objid = NULL_OBJID;
  me->nb_frame = 0;
}
