/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     ABSTRACT   : Modify an unwrap already placed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_ModUnw, 0, VLMdUn
command_table	"vl.cmd"
class		VLmodUnwCmd
super_class	VLlocateCmd
product_name	"$LOFT"
form		"VLmodUnw.frm", 0, 2, "-1", "-1"

start_state	loc_unw

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
#define MODIFY          531

instance
{
  double           list_att[UNFOLD_NB_OPT];
  double           old_list_att[UNFOLD_NB_OPT];
  struct GRid	   box;
  struct GRobj_env unwrap;
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
#include "ACrg_collect.h"
#include "vlunfold.h"
#include "ndmacros.h"
#include "vsmiscmacros.h"
#include "ACattrib.h"
#include "madef.h"
#include "vlstructure.h"
#include "vsplatedef.h"
%safe
static int xx=-1,yy,heig,wid,screen;
%endsafe

from NDnode import NDget_objects;
from ACrg_collect import AClist_attribute;
from ACrg_collect import ACset_list_attribute;
from GRgraphics import GRdisplay;
from VLunwrap import getRoots;
from NDmacro import ACreturn_foot;
#define MY_ERROR        530
#define MODIFY          531
extern GRclassid OPP_VSplate_class_id;

/******************************************************************************/
state_table

#include "griodef.h"
#include "msdef.h"
#include "vlmsg.h"
#include "VDSpathdef.h"
#include "vlunfold.h"
#define MY_ERROR        530
#define MODIFY          531

/******************************************************************************/
state loc_unw
        message_key		VL_S_MOD_UNWRAP
        prompt_key              VL_P_UNWRAP
        locate_eligible         "VLunwrap"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_BACK_UP		     state -
        on EX_DATA or EX_OBJID	do control_unwrap 	
                                on RETURN_CODE = MY_ERROR
                                                         state .
						         state modify_form
/******************************************************************************/
state modify_form
        message_key		VL_S_MOD_UNWRAP
        prompt_key           	VL_P_ChForm
        filter       		get_event

        on EX_BACK_UP		     state -
        on GR_UNKNOWN_TYPE.MODIFY    state loc_unw

/******************************************************************************/

at init do my_cob_init
at wakeup do form_pos
at sleep do erase_hilite

action control_unwrap
{
struct GRid	 *lchild = NULL;
int		 j,i,num = 0;
long		 loc_msg;
char		 tmp[50];
int              code=0,options[UNFOLD_NB_OPTLINE];
struct ACrg_coll ACrg[UNFOLD_NB_OPT];

  if (me->unwrap.obj_id.objid = NULL_OBJID) {
    FIg_enable(me->forms[0].form_ptr,FI_ACCEPT);
    FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
    FIg_enable(me->forms[0].form_ptr,FI_RESET);
  }
  me->unwrap.obj_id = me->event1.located_object[0].located_obj;
  me->unwrap.mod_env = me->event1.located_object[0].module_info;

  status = om$send ( msg =  message NDnode.NDget_objects(
                                                ND_IN_BUF | ND_ROOT,
                                                (struct GRid *)NULL,
                                                0,
                                                &lchild,
                                                0,
                                                OM_K_MAXINT,
                                                &num ),
                senderid  = NULL_OBJID,
                targetid = me->unwrap.obj_id.objid,
                targetos = me->unwrap.obj_id.osnum);
   if (!(status&1))  {
     *sts = MY_ERROR;
     goto quit;
   }
   if (num >= UNFOLD_IDX_BOX) {
     me->box = lchild[UNFOLD_IDX_BOX];
     status = om$send(msg = message ACrg_collect.AClist_attribute
                                        (&loc_msg,UNFOLD_NB_OPT,ACrg,&num),
                       targetid = lchild[UNFOLD_IDX_BOX].objid,
                       targetos = lchild[UNFOLD_IDX_BOX].osnum);
     if (!(status&loc_msg&1)) {
       *sts = MY_ERROR;
       goto quit;
     }
     for (i=0;i<num;i++)
       me->list_att[i] = me->old_list_att[i] = ACrg[i].desc.value.att_exp;
   }
   else {
     *sts = MY_ERROR;
     goto quit;
   }

  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_SRFWANTED)) != -1) {
    FIg_set_state(me->forms[0].form_ptr,G_MD_UNW_SURF,
                  (int) ACrg[j].desc.value.att_exp);
    FIg_set_default_value(me->forms[0].form_ptr,G_MD_UNW_SURF,
                          ACrg[j].desc.value.att_exp);
  }
  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_WATONPLATE)) != -1) {
    FIg_set_state(me->forms[0].form_ptr,G_MD_WATONPLATE,
                  (int) ACrg[j].desc.value.att_exp);
    FIg_set_default_value(me->forms[0].form_ptr,G_MD_WATONPLATE,
                          ACrg[j].desc.value.att_exp);
  }
  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_TESSELATION)) != -1) {
    FIg_set_state(me->forms[0].form_ptr,G_MD_TESSELATION,
                  (int) ACrg[j].desc.value.att_exp);
    FIg_set_default_value(me->forms[0].form_ptr,G_MD_TESSELATION,
                          ACrg[j].desc.value.att_exp);
  }
  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_LINES)) != -1) {
    VLdecode((int) ACrg[j].desc.value.att_exp,UNFOLD_NB_OPTLINE, options);
    for ( i=0; i<UNFOLD_NB_OPTLINE; i++)
    {
      if( i==UNFOLD_ATT_IDX_DISMIN )
        FIg_set_state( me->forms[0].form_ptr, G_MD_DISMIN, !(options[i]) );
      else if( i==UNFOLD_ATT_IDX_FAR )
        FIg_set_state( me->forms[0].form_ptr, G_MD_FAR, options[i] );
      else
        FIfld_set_select ( me->forms[0].form_ptr, G_MD_LINES, i, 0, options[i]);
    }
  }

  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_EXPTYPE)) != -1) {
    code = ACrg[j].desc.value.att_exp;
    if (code == NO_EXPANSION) strcpy(tmp,"No Expansion");
    else if (code == GLOBAL_LW_RATIO) strcpy(tmp,"Global Expansion");
         else strcpy(tmp,"Expansion by Marking");
    FIfld_set_text(me->forms[0].form_ptr,G_MD_EXP_TYPE,0,
                   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_MD_EXP_TYPE,
                           0,0,tmp,0,0);
  }

  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_SIDE)) != -1) {
    code = ACrg[j].desc.value.att_exp;
    if (code == BASE_SIDE) strcpy(tmp,"Base");
    else if (code == OFFSET_SIDE) strcpy(tmp,"Offset");
         else strcpy(tmp,"Max Marking");
    FIfld_set_text(me->forms[0].form_ptr,G_MD_SIDE,0,
                   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_MD_SIDE,
                           0,0,tmp,0,0);
  }

  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_X_EXPANSION)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text(me->forms[0].form_ptr,G_MD_EXP_X_SCALE,0,
                   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_MD_EXP_X_SCALE,
                           0,0,tmp,0,0);
  }
  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_Y_EXPANSION)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text(me->forms[0].form_ptr,G_MD_EXP_Y_SCALE,0,
                   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_MD_EXP_Y_SCALE,
                           0,0,tmp,0,0);
  }
  if (!code) {
    FIg_erase(me->forms[0].form_ptr,G_MD_EXP_X_SCALE);
    FIg_erase(me->forms[0].form_ptr,G_MD_EXP_Y_SCALE);
    FIg_erase(me->forms[0].form_ptr,G_MD_EXP_X_TEXT);
    FIg_erase(me->forms[0].form_ptr,G_MD_EXP_Y_TEXT);
  }
  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_FIB_RATIO)) != -1) {
      sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
      FIfld_set_text(me->forms[0].form_ptr,G_MD_FIBER_RATIO,0,
                     0, tmp,FALSE);
      FIfld_set_default_text(me->forms[0].form_ptr,G_MD_FIBER_RATIO,
                             0,0,tmp,0,0);
  }
  status = dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);
}

action save_all
{

int              i, j, options[UNFOLD_NB_OPTLINE];
long		 loc_msg;
char		 tmp[50];
IGRint		 cn_type,b_mod;
struct ACrg_coll ACrg[UNFOLD_NB_OPT];
int              put_batch = FALSE;

  *sts = me->ret = MSFAIL;
  FIg_get_text(me->forms[0].form_ptr,G_MD_FIBER_RATIO,tmp);
  sscanf(tmp,"%lf",&me->list_att[UNFOLD_ATT_IDX_FIB_RATIO]);

  FIg_get_state(me->forms[0].form_ptr,G_MD_UNW_SURF, &i);
  me->list_att[UNFOLD_ATT_IDX_SRFWANTED] = i;

  FIg_get_state(me->forms[0].form_ptr,G_MD_WATONPLATE, &i);
  me->list_att[UNFOLD_ATT_IDX_WATONPLATE] = i;

  FIg_get_text(me->forms[0].form_ptr,G_MD_EXP_TYPE,tmp);
  if (!strcmp(tmp,"Global Expansion")) 
    me->list_att[UNFOLD_ATT_IDX_EXPTYPE] = GLOBAL_LW_RATIO;
  else if (!strcmp(tmp,"Expansion by Marking")) 
         me->list_att[UNFOLD_ATT_IDX_EXPTYPE] = BY_STIFFNERS;
    else if (!strcmp(tmp,"No Expansion")) 
           me->list_att[UNFOLD_ATT_IDX_EXPTYPE] = NO_EXPANSION;

  FIg_get_text(me->forms[0].form_ptr,G_MD_SIDE,tmp);
  if (!strcmp(tmp,"Base")) 
    me->list_att[UNFOLD_ATT_IDX_SIDE] = BASE_SIDE;
  else if (!strcmp(tmp,"Offset")) 
         me->list_att[UNFOLD_ATT_IDX_SIDE] = OFFSET_SIDE;
    else if (!strcmp(tmp,"Max Marking")) 
           me->list_att[UNFOLD_ATT_IDX_SIDE] = MAX_MARK;

  FIg_get_text(me->forms[0].form_ptr,G_MD_EXP_X_SCALE,tmp);
  sscanf(tmp,"%lf",&me->list_att[UNFOLD_ATT_IDX_X_EXPANSION]);

  FIg_get_text(me->forms[0].form_ptr,G_MD_EXP_Y_SCALE,tmp);
  sscanf(tmp,"%lf",&me->list_att[UNFOLD_ATT_IDX_Y_EXPANSION]);

  FIg_get_state(me->forms[0].form_ptr,G_MD_TESSELATION, &i);
  me->list_att[UNFOLD_ATT_IDX_TESSELATION] = i;

  for (i=0;i<UNFOLD_NB_OPTLINE;i++)
  {
    if( i==UNFOLD_ATT_IDX_DISMIN )
    {
      FIg_get_state(me->forms[0].form_ptr, G_MD_DISMIN, &j );
      if( j ) options[UNFOLD_ATT_IDX_DISMIN] = 0;
      else    options[UNFOLD_ATT_IDX_DISMIN] = 1;
    }
    else if( i==UNFOLD_ATT_IDX_FAR )
    {
      FIg_get_state(me->forms[0].form_ptr, G_MD_FAR, &j );
      if( j ) options[UNFOLD_ATT_IDX_FAR] = 1;
      else    options[UNFOLD_ATT_IDX_FAR] = 0;
    }
    else
    FIfld_get_select(me->forms[0].form_ptr, G_MD_LINES,i,0,&options[i]);
  }
  VLencode ( options, UNFOLD_NB_OPTLINE, &i);
  me->list_att[UNFOLD_ATT_IDX_LINES] = i;

  if (
      me->list_att[UNFOLD_ATT_IDX_LINES] !=
                             me->old_list_att[UNFOLD_ATT_IDX_LINES]       ||
      me->list_att[UNFOLD_ATT_IDX_TESSELATION] !=
                             me->old_list_att[UNFOLD_ATT_IDX_TESSELATION] ||
      me->list_att[UNFOLD_ATT_IDX_Y_EXPANSION] !=
                             me->old_list_att[UNFOLD_ATT_IDX_Y_EXPANSION] ||
      me->list_att[UNFOLD_ATT_IDX_X_EXPANSION] !=
                             me->old_list_att[UNFOLD_ATT_IDX_X_EXPANSION] ||
      me->list_att[UNFOLD_ATT_IDX_EXPTYPE] !=
                             me->old_list_att[UNFOLD_ATT_IDX_EXPTYPE]     ||
      me->list_att[UNFOLD_ATT_IDX_SIDE] !=
                             me->old_list_att[UNFOLD_ATT_IDX_SIDE]     ||
      me->list_att[UNFOLD_ATT_IDX_SRFWANTED] !=
                             me->old_list_att[UNFOLD_ATT_IDX_SRFWANTED]   ||
      me->list_att[UNFOLD_ATT_IDX_WATONPLATE] !=
                             me->old_list_att[UNFOLD_ATT_IDX_WATONPLATE]   ||
      me->list_att[UNFOLD_ATT_IDX_FIB_RATIO] != 
                             me->old_list_att[UNFOLD_ATT_IDX_FIB_RATIO]   
    ) {
    put_batch = TRUE;
    strcpy(ACrg[UNFOLD_ATT_IDX_FIB_RATIO].name,UNFOLD_ATT_FIB_RATIO);
    ACrg[UNFOLD_ATT_IDX_FIB_RATIO].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_FIB_RATIO].desc.value.att_exp = 
                                 me->list_att[UNFOLD_ATT_IDX_FIB_RATIO];
    om$send(msg = message VLmodUnwCmd.VLmodGlobals
                            (&loc_msg,NAM_G_FIB,
                            me->list_att[UNFOLD_ATT_IDX_FIB_RATIO]),
                    targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_FIB_RATIO] =
                             me->list_att[UNFOLD_ATT_IDX_FIB_RATIO];

    strcpy(ACrg[UNFOLD_ATT_IDX_SRFWANTED].name,UNFOLD_ATT_SRFWANTED);
    ACrg[UNFOLD_ATT_IDX_SRFWANTED].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_SRFWANTED].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_SRFWANTED];
    status = om$send(msg = message VLmodUnwCmd.VLmodGlobals
                                 (&loc_msg,NAM_G_UNW_SURF,
                                  me->list_att[UNFOLD_ATT_IDX_SRFWANTED]),
                        targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_SRFWANTED] =
                             me->list_att[UNFOLD_ATT_IDX_SRFWANTED];

    strcpy(ACrg[UNFOLD_ATT_IDX_WATONPLATE].name,UNFOLD_ATT_WATONPLATE);
    ACrg[UNFOLD_ATT_IDX_WATONPLATE].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_WATONPLATE].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_WATONPLATE];
    status = om$send(msg = message VLmodUnwCmd.VLmodGlobals
                                 (&loc_msg,NAM_G_WATONPLATE,
                                  me->list_att[UNFOLD_ATT_IDX_WATONPLATE]),
                        targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_WATONPLATE] =
                             me->list_att[UNFOLD_ATT_IDX_WATONPLATE];

    strcpy(ACrg[UNFOLD_ATT_IDX_EXPTYPE].name,UNFOLD_ATT_EXPTYPE);
    ACrg[UNFOLD_ATT_IDX_EXPTYPE].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_EXPTYPE].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_EXPTYPE];
    status = om$send(msg = message VLmodUnwCmd.VLmodGlobals
                                 (&loc_msg,NAM_G_T_EXP,
                                  me->list_att[UNFOLD_ATT_IDX_EXPTYPE]),
                        targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_EXPTYPE] =
                             me->list_att[UNFOLD_ATT_IDX_EXPTYPE];

    strcpy(ACrg[UNFOLD_ATT_IDX_SIDE].name,UNFOLD_ATT_SIDE);
    ACrg[UNFOLD_ATT_IDX_SIDE].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_SIDE].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_SIDE];
    status = om$send(msg = message VLmodUnwCmd.VLmodGlobals
                                 (&loc_msg,NAM_G_SIDE,
                                  me->list_att[UNFOLD_ATT_IDX_SIDE]),
                        targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_SIDE] =
                             me->list_att[UNFOLD_ATT_IDX_SIDE];
    
    strcpy(ACrg[UNFOLD_ATT_IDX_X_EXPANSION].name,UNFOLD_ATT_X_EXPANSION);
    ACrg[UNFOLD_ATT_IDX_X_EXPANSION].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_X_EXPANSION].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_X_EXPANSION];
    status = om$send(msg = message VLmodUnwCmd.VLmodGlobals
                               (&loc_msg,NAM_G_X_EXP,
                                me->list_att[UNFOLD_ATT_IDX_X_EXPANSION]),
                      targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_X_EXPANSION] =
                             me->list_att[UNFOLD_ATT_IDX_X_EXPANSION];

    strcpy(ACrg[UNFOLD_ATT_IDX_Y_EXPANSION].name,UNFOLD_ATT_Y_EXPANSION);
    ACrg[UNFOLD_ATT_IDX_Y_EXPANSION].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_Y_EXPANSION].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_Y_EXPANSION];
    status = om$send(msg = message VLmodUnwCmd.VLmodGlobals
                               (&loc_msg,NAM_G_Y_EXP,
                                me->list_att[UNFOLD_ATT_IDX_Y_EXPANSION]),
                      targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_Y_EXPANSION] =
                             me->list_att[UNFOLD_ATT_IDX_Y_EXPANSION];

    strcpy(ACrg[UNFOLD_ATT_IDX_TESSELATION].name,UNFOLD_ATT_TESSELATION);
    ACrg[UNFOLD_ATT_IDX_TESSELATION].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_TESSELATION].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_TESSELATION];
    status = om$send(msg = message VLmodUnwCmd.VLmodGlobals
                                 (&loc_msg,NAM_G_TESS,
                                  me->list_att[UNFOLD_ATT_IDX_TESSELATION]),
                        targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_TESSELATION] =
                             me->list_att[UNFOLD_ATT_IDX_TESSELATION];

    strcpy(ACrg[UNFOLD_ATT_IDX_LINES].name,UNFOLD_ATT_LINES);
    ACrg[UNFOLD_ATT_IDX_LINES].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_LINES].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_LINES];
    om$send(msg = message VLmodUnwCmd.VLmodGlobals
                               (&loc_msg,NAM_G_UNW_CODE,
                                me->list_att[UNFOLD_ATT_IDX_LINES]),
                      targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_LINES] =
                             me->list_att[UNFOLD_ATT_IDX_LINES];

    status = om$send(msg = message ACrg_collect.ACset_list_attribute
                                      (&loc_msg,UNFOLD_NB_OPT,ACrg ),
                        targetid = me->box.objid,
                        targetos = me->box.osnum);
    if (!(status&loc_msg&1)) {
      ex$message( msgnumb = VL_E_InvColl , buff = tmp);
      FIg_set_text(me->forms[0].form_ptr,FI_MD_MSG_FIELD,tmp);
    }
  }
  if (put_batch) {
      cn_type    = ND_COMP; /* recompute the object */
      status = nd$wait_batch(type        = GR_GEOM_POSTED,
                             nb_obj      = 1,
                             l_object    = &(me->unwrap.obj_id),
                             l_obj_info  = &cn_type );

       nd$mod_batch(request     = ND_INQ,
                    p_ret_mode  = &b_mod );

        if( b_mod != ND_DEFER ){

             ex$message(msgnumb = VL_E_ModUnwrap);
              nd$exec_batch();
        }

      ex$message(msgnumb = VL_E_UnwrapMod);
   }
  *sts = me->ret = MSSUCC;
  goto quit;
}

action form_notification
{
long  msg;
int   i,options[UNFOLD_NB_OPTLINE];
enum GRdpmode   mode = GRhd;
char            tmp[50],*side;
struct mise_a_plat dev;
OMuword		   TEMP_cl;
struct GRobj_env   plate,surf_id;

  if( form_ptr == NULL ) return( OM_E_INVARG );

  FIg_set_text(form_ptr,FI_MD_MSG_FIELD,"");

  switch(gadget_label) {

    case FI_ACCEPT :
      status = om$send(msg = message VLmodUnwCmd.save_all(&msg),
                       targetid = my_id);

      if(!(status & msg & 1))
      {
        FIg_set_state_off(me->forms[0].form_ptr,FI_ACCEPT);
        ex$message( msgnumb = VL_E_BadPlc);
        goto quit;
      }
      FIg_set_state_off(me->forms[0].form_ptr,FI_ACCEPT);
      _put_response(resp = TERMINATE);

      break;
    case FI_EXECUTE :
      status = om$send(msg = message VLmodUnwCmd.save_all(&msg),
                       targetid = my_id);

      if(!(status & msg & 1))
      {
        FIg_set_state_off(me->forms[0].form_ptr,FI_EXECUTE);
        ex$message( msgnumb = VL_E_BadPlc);
        goto quit;
      }
      FIg_set_state_off(me->forms[0].form_ptr,FI_EXECUTE);
      _put_response(resp = MODIFY);
      break;
    case FI_CANCEL :
      _put_response(resp = TERMINATE);
      break;
    case FI_RESET :
      if (!me->old_list_att[UNFOLD_ATT_IDX_EXPTYPE]) {
        FIg_erase(me->forms[0].form_ptr,G_MD_EXP_X_SCALE);
        FIg_erase(me->forms[0].form_ptr,G_MD_EXP_Y_SCALE);
        FIg_erase(me->forms[0].form_ptr,G_MD_EXP_X_TEXT);
        FIg_erase(me->forms[0].form_ptr,G_MD_EXP_Y_TEXT);
      }
      VLdecode((int) me->old_list_att[UNFOLD_ATT_IDX_LINES],UNFOLD_NB_OPTLINE, 
               options);
      for ( i=0; i<UNFOLD_NB_OPTLINE; i++)
      {
        FIfld_set_select ( me->forms[0].form_ptr, G_MD_LINES, i, 0, options[i]);
      }
      break;
  case G_MD_LOCATE :
     status = dp$erase_hilite(msg=&msg,
                              objid = me->ModuleInfo.md_id.objid,
                              osnum = me->ModuleInfo.md_id.osnum);
    if (me->unwrap.obj_id.objid != NULL_OBJID) {
      status = om$send(msg = message GRgraphics.GRdisplay(
                             &msg,
                             &me->unwrap.mod_env.md_env.matrix_type,
                             me->unwrap.mod_env.md_env.matrix,
                             &mode,
                             &me->ModuleInfo.md_id ),
               targetid = me->unwrap.obj_id.objid,
               targetos = me->unwrap.obj_id.osnum,
               senderid = NULL_OBJID);
      if (!(status & msg & 1))
        VLdispObj(&me->unwrap.obj_id,&(me->unwrap.mod_env),&mode,1);
    }
    FIg_set_state_off(me->forms[0].form_ptr,G_MD_LOCATE);
    _put_response(resp=MODIFY);
    break;
  case G_MD_EXP_TYPE :
    FIg_get_text(me->forms[0].form_ptr,G_MD_EXP_TYPE,tmp);
    if (!strcmp(tmp,"No Expansion")) {
      FIg_erase(me->forms[0].form_ptr,G_MD_EXP_X_SCALE);
      FIg_erase(me->forms[0].form_ptr,G_MD_EXP_Y_SCALE);
      FIg_erase(me->forms[0].form_ptr,G_MD_EXP_X_TEXT);
      FIg_erase(me->forms[0].form_ptr,G_MD_EXP_Y_TEXT);
    } 
    else {
      FIg_display(me->forms[0].form_ptr,G_MD_EXP_X_SCALE);
      FIg_display(me->forms[0].form_ptr,G_MD_EXP_Y_SCALE);
      FIg_display(me->forms[0].form_ptr,G_MD_EXP_X_TEXT);
      FIg_display(me->forms[0].form_ptr,G_MD_EXP_Y_TEXT);
    }
    break;

  case G_MD_SIDE :
      FIg_get_text(me->forms[0].form_ptr,G_MD_SIDE,tmp);
        // Unhighlight old side and normal.
      dp$erase_hilite( msg = &status ) ;

      if (!strcmp(tmp,"Base") || !strcmp(tmp,"Offset")) {
          status = om$send(msg = message VLunwrap.getRoots(
					         &msg,&me->ModuleInfo,
                                                 &dev,&plate,NULL,NULL, NULL,
                                                 NULL,NULL,NULL),
                           targetid = me->unwrap.obj_id.objid,
                           targetos = me->unwrap.obj_id.osnum);
          if (!(status&msg&1)) break;

          om$get_classid( osnum           = plate.obj_id.osnum  ,
                          objid           = plate.obj_id.objid  ,
                          p_classid       = &TEMP_cl      ) ;

          if( om$is_ancestry_valid( superclassid  = OPP_VSplate_class_id,
                                 subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {
            if (!strcmp(tmp,"Base")) side = VS_K_plBotSfPath;
            else                     side =  VS_K_plTopSfPath;
   
              status= om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        side,
                                        &surf_id.obj_id,
                                        &surf_id.mod_env.md_env.matrix_type,
                                        surf_id.mod_env.md_env.matrix ),
                        targetid = plate.obj_id.objid,
                        targetos = plate.obj_id.osnum ) ;
              if (!(status&msg&1)) break;

              if (plate.mod_env.md_env.matrix_type != MAIDMX) {
                i = 4;
                MAmulmx(&status,&i,&i,&i,plate.mod_env.md_env.matrix,
                        surf_id.mod_env.md_env.matrix,
                        surf_id.mod_env.md_env.matrix);
                MAtypemx( &status, surf_id.mod_env.md_env.matrix,
                          &surf_id.mod_env.md_env.matrix_type);
              }
          }
          else
            surf_id = plate;

          vs$bulk_display(count = 1,
                          dpmode = GRhdo,
                          objenvs = &surf_id);
          VSdisplaySurfaceNormal(&status,&surf_id,TRUE,&me->ActiveDisplay,
                                 GRhd);
      }
      break;
  }
}

action form_pos
{
  status = 1;
  if (xx != -1 ) {
    FIf_set_location(me->forms[0].form_ptr, xx,yy);
    FIf_set_size(me->forms[0].form_ptr, heig,wid);
    FIf_set_screen(me->forms[0].form_ptr, screen);
  }
  FIg_enable(me->forms[0].form_ptr,G_MD_UNW_SURF);
  FIg_enable(me->forms[0].form_ptr,G_MD_FIBER_RATIO);
  FIg_enable(me->forms[0].form_ptr,G_MD_EXP_TYPE);
  FIg_enable(me->forms[0].form_ptr,G_MD_SIDE);
  FIg_enable(me->forms[0].form_ptr,G_MD_EXP_X_SCALE);
  FIg_enable(me->forms[0].form_ptr,G_MD_EXP_Y_SCALE);
  FIg_enable(me->forms[0].form_ptr,G_MD_TESSELATION);
  FIg_enable(me->forms[0].form_ptr,G_MD_LINES);
  FIg_enable(me->forms[0].form_ptr,FI_ACCEPT);
  FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
  FIg_enable(me->forms[0].form_ptr,FI_RESET);
  FIg_enable(me->forms[0].form_ptr,FI_CANCEL);
  FIg_enable(me->forms[0].form_ptr,G_MD_LOCATE);
  FIg_enable(me->forms[0].form_ptr,G_MD_WATONPLATE);
  if (me->unwrap.obj_id.objid == NULL_OBJID) {
   FIg_disable(me->forms[0].form_ptr,FI_ACCEPT);
   FIg_disable(me->forms[0].form_ptr,FI_EXECUTE);
   FIg_disable(me->forms[0].form_ptr,FI_RESET);
  }
  goto quit;
}

action erase_hilite
{
int     loc_msg;

  status = dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);

  FIf_get_size(me->forms[0].form_ptr,&heig,&wid);
  FIf_get_location(me->forms[0].form_ptr,&xx,&yy);
  FIf_get_screen(me->forms[0].form_ptr,&screen);
  FIg_disable(me->forms[0].form_ptr,G_MD_UNW_SURF);
  FIg_disable(me->forms[0].form_ptr,G_MD_FIBER_RATIO);
  FIg_disable(me->forms[0].form_ptr,G_MD_EXP_TYPE);
  FIg_disable(me->forms[0].form_ptr,G_MD_SIDE);
  FIg_disable(me->forms[0].form_ptr,G_MD_EXP_X_SCALE);
  FIg_disable(me->forms[0].form_ptr,G_MD_EXP_Y_SCALE);
  FIg_disable(me->forms[0].form_ptr,G_MD_TESSELATION);
  FIg_disable(me->forms[0].form_ptr,G_MD_LOCATE);
  FIg_disable(me->forms[0].form_ptr,G_MD_WATONPLATE);
  FIg_disable(me->forms[0].form_ptr,G_MD_LINES);
  FIg_disable(me->forms[0].form_ptr,FI_ACCEPT);
  FIg_disable(me->forms[0].form_ptr,FI_EXECUTE);
  FIg_disable(me->forms[0].form_ptr,FI_RESET);
  FIg_disable(me->forms[0].form_ptr,FI_CANCEL);

goto quit;
}

action my_cob_init
{

   status = 1;       // to avoid warning messages during compilation
   me->unwrap.obj_id.objid = NULL_OBJID;
   FIg_set_text(me->forms[0].form_ptr,G_MD_EXP_TYPE," ");
   FIg_set_text(me->forms[0].form_ptr,G_MD_SIDE," ");
   goto quit;            // to avoid warning messages during compilation
}
