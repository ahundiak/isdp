/* $Id: VLmodextCmd.sl,v 1.2 2001/01/16 20:01:05 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLmodextCmd.sl
 *
 * Description: 'Modify Unwrap Extraction' Command Object.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLmodextCmd.sl,v $
 *      Revision 1.2  2001/01/16 20:01:05  ramarao
 *      *** empty log message ***
 *
# Revision 1.5  2000/09/13  20:05:04  pinnacle
# Replaced: loft/src/unwext/VLmodextCmd.sl for:  by rchennup for Service Pack
#
# Revision 1.3  2000/06/26  15:43:54  pinnacle
# ah Added VLunwMisc.h
#
# Revision 1.2  2000/06/25  18:07:42  pinnacle
# Replaced: loft/src/unwext/VLmodextCmd.sl for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/19  14:37:14  pinnacle
# Created: loft/src/unwext/VLmodextCmd.sl by rchennup for Service Pack
#
# Revision 1.5  2000/02/22  17:02:04  pinnacle
# (No comment)
#
# Revision 1.4  2000/02/21  21:46:36  pinnacle
# Replaced VLmodextCmd.sl for Unwrap command by jpulapar
#
# Revision 1.3  2000/02/01  16:08:36  pinnacle
# (No comment)
#
# Revision 1.2  1999/06/01  16:26:34  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.3  1998/04/23  08:25:50  pinnacle
# Replaced: src/unwext/VLmodextCmd.sl for:  by rchennup for loft
#
# Revision 1.2  1998/04/23  05:29:24  pinnacle
# Replaced: src/unwext/VLmodextCmd.sl for:  by smpathak for loft
#
# Revision 1.1  1997/10/28  15:28:10  pinnacle
# Created: src/unwext/VLmodextCmd.sl by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *	04/23/98   Sandeep 	Modification for Form Interface
 *      01/04/2000 Jayadev      Modify multiple unwraps at a time 
 *************************************************************************/

command_string	VLC_M_MODUNWEXT, 0, VLMdUnExt
command_table	"vl.cmd"
class		VLmodextCmd
super_class	VLlocateCmd
product_name	"$LOFT"
form		"VLunwext.frm", 0, 0, "-1", "-1"

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
#include "vlunwext.h"
#include "vlglobals.h"
#define MY_ERROR        530
#define MODIFY          531

instance
{
  double           list_att[UNWEXT_NB_OPT];
  double           old_list_att[UNWEXT_NB_OPT];
  struct GRid	   box;
  struct GRobj_env unwrap;
}

implementation

#include <math.h>
#include "AS_status.h"
#include "FI.h"
#include "msdef.h"
#include "EMSmsgdef.h"
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
#include "VDmem.h"
#include "vddrwattr.h"
#include "vsmiscmacros.h"
#include "ACattrib.h"
#include "madef.h"
#include "vlstructure.h"
#include "vsplatedef.h"
#include "griomacros.h"
#include "griodef.h"
#include "VLunwMisc.h"

%safe
static int xx=-1,yy,heig,wid,screen;
%endsafe


from   NDnode 	    import 	NDget_objects,NDchange_connect;
from   ACrg_collect import 	AClist_attribute;
from   ACrg_collect import 	ACset_list_attribute;
from   GRgraphics   import 	GRdisplay;
from   VLunwrap     import 	getRoots;
from   NDmacro 	    import 	ACreturn_foot;
from   GRvg	    import      GRgetattr, GRputattr;

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
        message_key		VL_S_MODUNWEXT
        prompt_key              VL_P_UNWRAP
        locate_eligible         "VLunwObj"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_BACK_UP		state -
        on EX_DATA or EX_OBJID  do VLstoreResponse (&me->ret)   state EVENT_OBJ
/******************************************************************************/
state EVENT_OBJ
	status_key              VL_S_PROCESS
	prompt                  " "
	execute                 VLstoreLocate (&me->ret)
	execute                 VLfreeList ( &me->ret, 1)
	execute                 VLstoreList ( &me->ret, 0, 1)
        execute			control_unwrap 	
                                on RETURN_CODE = MY_ERROR state - 
        on ELSE                                          state modify_form 
/******************************************************************************/
state modify_form
        message_key		VL_S_MODUNWEXT
        prompt_key           	VL_P_ChForm
        filter       		get_event

        /* on EX_BACK_UP		     state - */
        on EX_BACK_UP		     state loc_unw 
        on GR_UNKNOWN_TYPE.MODIFY    state loc_unw

/******************************************************************************/

at init do my_cob_init
at wakeup do form_pos
at sleep do erase_hilite

action control_unwrap
{
  struct GRid	 *lchild = NULL;
  int		 i,j,num = 0;
  long		 loc_msg;
  char		 tmp[50];
  int              code=0,options[UNFOLD_NB_OPTLINE];
  struct ACrg_coll ACrg[UNFOLD_NB_OPT];
  VDpartAttr       attr ;
  
  // Should be able to accept multiple unwraps to modify 
  if(!(me->Cnt1)){
    *sts = MY_ERROR;
    goto quit;
  }
  if (me->unwrap.obj_id.objid = NULL_OBJID) {
    FIg_enable(me->forms[0].form_ptr,FI_ACCEPT);
    FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
    FIg_enable(me->forms[0].form_ptr,FI_RESET);
  }
  //me->unwrap.obj_id = me->event1.located_object[0].located_obj;
  //me->unwrap.mod_env = me->event1.located_object[0].module_info;
  
  me->unwrap.obj_id = me->Lst1[0].obj_id;
  me->unwrap.mod_env = me->Lst1[0].mod_env;

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

   me->box = lchild[0];
   status = om$send(msg = message ACrg_collect.AClist_attribute
                                        (&loc_msg,UNFOLD_NB_OPT,ACrg,&num),
                       targetid = lchild[0].objid,
                       targetos = lchild[0].osnum);
   if (!(status&loc_msg&1)) {
       *sts = MY_ERROR;
       goto quit;
   }
   for (i=0;i<num;i++)
      me->list_att[i] = me->old_list_att[i] = ACrg[i].desc.value.att_exp;

  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_SRFWANTED)) != -1) {
    FIg_set_state(me->forms[0].form_ptr,G_UNW_SURF,
                  (int) ACrg[j].desc.value.att_exp);
    FIg_set_default_value(me->forms[0].form_ptr,G_UNW_SURF,
                          ACrg[j].desc.value.att_exp);
  }
  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_WATONPLATE)) != -1) {
    FIg_set_state(me->forms[0].form_ptr,G_WATONPLATE,
                  (int) ACrg[j].desc.value.att_exp);
    FIg_set_default_value(me->forms[0].form_ptr,G_WATONPLATE,
                          ACrg[j].desc.value.att_exp);
  }
  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_TESSELATION)) != -1) {
    FIg_set_state(me->forms[0].form_ptr,G_TESSELATION,
                  (int) ACrg[j].desc.value.att_exp);
    FIg_set_default_value(me->forms[0].form_ptr,G_TESSELATION,
                          ACrg[j].desc.value.att_exp);
  }
  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_LINES)) != -1) {
    VLdecode((int) ACrg[j].desc.value.att_exp,UNWEXT_NB_OPT, options);
    for ( i=0; i<UNWEXT_NB_OPT; i++)
    {
      if( i<UNWEXT_ATT_IDX_PARENT )
        FIfld_set_select ( me->forms[0].form_ptr, G_LINES, i, 0, options[i]);
      else
	FIfld_set_select ( me->forms[0].form_ptr, G_PRCOPT, 
				i-UNWEXT_ATT_IDX_PARENT, 0, options[i]);
    }
  }

  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_EXPTYPE)) != -1) {
    code = ACrg[j].desc.value.att_exp;
    if (code == NO_EXPANSION) strcpy(tmp,"No Expansion");
    else if (code == GLOBAL_LW_RATIO) strcpy(tmp,"Global Expansion");
         else strcpy(tmp,"Expansion by Marking");
    FIfld_set_text(me->forms[0].form_ptr,G_EXP_TYPE,0,
                   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_EXP_TYPE,
                           0,0,tmp,0,0);
    if (!code) {
      FIg_erase(me->forms[0].form_ptr,G_EXP_X_SCALE);
      FIg_erase(me->forms[0].form_ptr,G_EXP_Y_SCALE);
      FIg_erase(me->forms[0].form_ptr,G_EXP_X_TEXT);
      FIg_erase(me->forms[0].form_ptr,G_EXP_Y_TEXT);
    }
  }

  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_SIDE)) != -1) {
    code = ACrg[j].desc.value.att_exp;
    if (code == BASE_SIDE) strcpy(tmp,"Base");
    else if (code == OFFSET_SIDE) strcpy(tmp,"Offset");
    else if (code == BASE_FLIP) strcpy(tmp,"Base-Flip");
    else if (code == OFFSET_FLIP) strcpy(tmp,"Offset-Flip");

    FIfld_set_text(me->forms[0].form_ptr,G_SIDE,0,
                   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_SIDE,
                           0,0,tmp,0,0);
  }

  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_UNWOPT)) != -1) 
		code = ACrg[j].desc.value.att_exp;
  else		
  {
	code = 0;
	me->list_att[UNFOLD_ATT_IDX_UNWOPT] 
		= me->old_list_att[UNFOLD_ATT_IDX_UNWOPT] = code;
  }
  sprintf( tmp, "%d", code ); 
  FIfld_set_text(me->forms[0].form_ptr,G_UNWOPT,0,0, tmp,FALSE);
  FIfld_set_default_text(me->forms[0].form_ptr,G_UNWOPT,0,0,tmp,0,0);

  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_X_EXPANSION)) != -1) {
    sprintf(tmp,"%g",ACrg[j].desc.value.att_exp);
    FIfld_set_text(me->forms[0].form_ptr,G_EXP_X_SCALE,0,
                   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_EXP_X_SCALE,
                           0,0,tmp,0,0);
  }
  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_Y_EXPANSION)) != -1) {
    sprintf(tmp,"%g",ACrg[j].desc.value.att_exp);
    FIfld_set_text(me->forms[0].form_ptr,G_EXP_Y_SCALE,0,
                   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_EXP_Y_SCALE,
                           0,0,tmp,0,0);
  }
  if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_FIB_RATIO)) != -1) {
      sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
      FIfld_set_text(me->forms[0].form_ptr,G_FIBER_RATIO,0,
                     0, tmp,FALSE);
      FIfld_set_default_text(me->forms[0].form_ptr,G_FIBER_RATIO,
                             0,0,tmp,0,0);
  }

  /* Get the visualization support file */
  attr.Iwant = VD_I_drwVisual ;
  status = om$send ( msg =  message GRvg.GRgetattr( 
					&loc_msg, (char *)&attr ),
		targetid = me->unwrap.obj_id.objid,
		targetos = me->unwrap.obj_id.osnum  );
   if (!(status&loc_msg&1)) {
       *sts = MY_ERROR;
       goto quit;
   }

  strcpy( tmp, attr.aString );

  FIfld_set_text( me->forms[0].form_ptr, 16, 0, 0, tmp, FALSE );
  FIfld_set_default_text( me->forms[0].form_ptr, 16, 0, 0, tmp, 0, 0 );

  status = dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);
  FIf_display( me->forms[0].form_ptr );
}

action save_all
{

  int             i,options[UNWEXT_NB_OPT];
  int             num;
  long		 loc_msg;
  char		 tmp[50];
  IGRint		 cn_type,b_mod;
  struct ACrg_coll ACrg[UNFOLD_NB_OPT];
  VDpartAttr       attr ;
  int              put_batch = FALSE, new_setup = FALSE;
  FILE             *setup_file=NULL;
  struct GRid	   *rg_coll=NULL;

  *sts = me->ret = MSFAIL;
  FIg_get_text(me->forms[0].form_ptr,G_FIBER_RATIO,tmp);
  sscanf(tmp,"%lf",&me->list_att[UNFOLD_ATT_IDX_FIB_RATIO]);

  FIg_get_state(me->forms[0].form_ptr,G_UNW_SURF, &i);
  me->list_att[UNFOLD_ATT_IDX_SRFWANTED] = i;

  FIg_get_state(me->forms[0].form_ptr,G_WATONPLATE, &i);
  me->list_att[UNFOLD_ATT_IDX_WATONPLATE] = i;

  FIg_get_text(me->forms[0].form_ptr,G_EXP_TYPE,tmp);
  if (!strcmp(tmp,"Global Expansion")) 
    me->list_att[UNFOLD_ATT_IDX_EXPTYPE] = GLOBAL_LW_RATIO;
  else if (!strcmp(tmp,"Expansion by Marking")) 
         me->list_att[UNFOLD_ATT_IDX_EXPTYPE] = BY_STIFFNERS;
    else if (!strcmp(tmp,"No Expansion")) 
           me->list_att[UNFOLD_ATT_IDX_EXPTYPE] = NO_EXPANSION;

  FIg_get_text(me->forms[0].form_ptr,G_SIDE,tmp);
  if (!strcmp(tmp,"Base")) 
    	me->list_att[UNFOLD_ATT_IDX_SIDE] = BASE_SIDE;
  else if (!strcmp(tmp,"Offset")) 
        me->list_att[UNFOLD_ATT_IDX_SIDE] = OFFSET_SIDE;
  else if (!strcmp(tmp,"Base-Flip"))
	me->list_att[UNFOLD_ATT_IDX_SIDE] = BASE_FLIP;
  else if (!strcmp(tmp,"Offset-Flip"))
        me->list_att[UNFOLD_ATT_IDX_SIDE] = OFFSET_FLIP;

  FIg_get_text(me->forms[0].form_ptr,G_UNWOPT,tmp);
  sscanf(tmp,"%lf",&me->list_att[UNFOLD_ATT_IDX_UNWOPT]);

  FIg_get_text(me->forms[0].form_ptr,G_EXP_X_SCALE,tmp);
  sscanf(tmp,"%lf",&me->list_att[UNFOLD_ATT_IDX_X_EXPANSION]);

  FIg_get_text(me->forms[0].form_ptr,G_EXP_Y_SCALE,tmp);
  sscanf(tmp,"%lf",&me->list_att[UNFOLD_ATT_IDX_Y_EXPANSION]);

  FIg_get_text(me->forms[0].form_ptr, 16,tmp);
  if( setup_file = VLunwOpenSetupFilex( tmp, NULL ) )
  {
     fclose( setup_file );
     setup_file = NULL;
  }
  else
  {
     FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, "Invalid Setup File");
     *sts = MY_ERROR;
     goto quit;
  }

  /* Get the visualization support file */
  attr.Iwant = VD_I_drwVisual ;
  status = om$send ( msg =  message GRvg.GRgetattr( 
					&loc_msg, (char *)&attr ),
		targetid = me->unwrap.obj_id.objid,
		targetos = me->unwrap.obj_id.osnum  );
   if (!(status&loc_msg&1)) {
       *sts = MY_ERROR;
       goto quit;
   }

  if( strcmp( attr.aString, tmp ) )  
  {
     attr.Iwant = VD_I_drwVisual ;
     strcpy( attr.aString, tmp );
     for(i=0;i<me->Cnt1;i++)
     {
         status = om$send ( msg =  message GRvg.GRputattr( 
					&loc_msg, (char *)&attr ),
                targetid = me->Lst1[i].obj_id.objid,
                targetos = me->Lst1[i].obj_id.osnum  );
     }
     new_setup = TRUE;
  }

  FIg_get_state(me->forms[0].form_ptr,G_TESSELATION, &i);
  me->list_att[UNFOLD_ATT_IDX_TESSELATION] = i;

  for (i=0;i<UNWEXT_NB_OPT;i++)
  {
    if( i<UNWEXT_ATT_IDX_PARENT )
       FIfld_get_select(me->forms[0].form_ptr, G_LINES,i,0,&options[i]);
    else
       FIfld_get_select(me->forms[0].form_ptr, G_PRCOPT,
			i-UNWEXT_ATT_IDX_PARENT, 0, &options[i]);
  }
  VLencode ( options, UNWEXT_NB_OPT, &i);
  me->list_att[UNFOLD_ATT_IDX_LINES] = i;

  if (
      new_setup								  ||
      me->list_att[UNFOLD_ATT_IDX_LINES] !=
                             me->old_list_att[UNFOLD_ATT_IDX_LINES]       ||
      me->list_att[UNFOLD_ATT_IDX_TESSELATION] !=
                             me->old_list_att[UNFOLD_ATT_IDX_TESSELATION] ||
      fabs( me->list_att[UNFOLD_ATT_IDX_X_EXPANSION] -
                   me->old_list_att[UNFOLD_ATT_IDX_X_EXPANSION] ) > 1e-6  ||
      fabs( me->list_att[UNFOLD_ATT_IDX_Y_EXPANSION] -
                   me->old_list_att[UNFOLD_ATT_IDX_Y_EXPANSION] ) > 1e-6  ||
      me->list_att[UNFOLD_ATT_IDX_EXPTYPE] !=
                             me->old_list_att[UNFOLD_ATT_IDX_EXPTYPE]     ||
      me->list_att[UNFOLD_ATT_IDX_SIDE] !=
                             me->old_list_att[UNFOLD_ATT_IDX_SIDE]     ||
      me->list_att[UNFOLD_ATT_IDX_SRFWANTED] !=
                             me->old_list_att[UNFOLD_ATT_IDX_SRFWANTED]   ||
      me->list_att[UNFOLD_ATT_IDX_WATONPLATE] !=
                             me->old_list_att[UNFOLD_ATT_IDX_WATONPLATE]   ||
      me->list_att[UNFOLD_ATT_IDX_FIB_RATIO] != 
                             me->old_list_att[UNFOLD_ATT_IDX_FIB_RATIO]    ||
      me->list_att[UNFOLD_ATT_IDX_UNWOPT] !=
			     me->old_list_att[UNFOLD_ATT_IDX_UNWOPT]
    ) {
    put_batch = TRUE;
    strcpy(ACrg[UNFOLD_ATT_IDX_FIB_RATIO].name,UNFOLD_ATT_FIB_RATIO);
    ACrg[UNFOLD_ATT_IDX_FIB_RATIO].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_FIB_RATIO].desc.value.att_exp = 
                                 me->list_att[UNFOLD_ATT_IDX_FIB_RATIO];
    om$send(msg = message VLmodextCmd.VLmodGlobals
                            (&loc_msg,NAM_G_FIB,
                            me->list_att[UNFOLD_ATT_IDX_FIB_RATIO]),
                    targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_FIB_RATIO] =
                             me->list_att[UNFOLD_ATT_IDX_FIB_RATIO];

    strcpy(ACrg[UNFOLD_ATT_IDX_SRFWANTED].name,UNFOLD_ATT_SRFWANTED);
    ACrg[UNFOLD_ATT_IDX_SRFWANTED].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_SRFWANTED].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_SRFWANTED];
    status = om$send(msg = message VLmodextCmd.VLmodGlobals
                                 (&loc_msg,NAM_G_UNW_SURF,
                                  me->list_att[UNFOLD_ATT_IDX_SRFWANTED]),
                        targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_SRFWANTED] =
                             me->list_att[UNFOLD_ATT_IDX_SRFWANTED];

    strcpy(ACrg[UNFOLD_ATT_IDX_WATONPLATE].name,UNFOLD_ATT_WATONPLATE);
    ACrg[UNFOLD_ATT_IDX_WATONPLATE].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_WATONPLATE].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_WATONPLATE];
    status = om$send(msg = message VLmodextCmd.VLmodGlobals
                                 (&loc_msg,NAM_G_WATONPLATE,
                                  me->list_att[UNFOLD_ATT_IDX_WATONPLATE]),
                        targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_WATONPLATE] =
                             me->list_att[UNFOLD_ATT_IDX_WATONPLATE];

    strcpy(ACrg[UNFOLD_ATT_IDX_EXPTYPE].name,UNFOLD_ATT_EXPTYPE);
    ACrg[UNFOLD_ATT_IDX_EXPTYPE].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_EXPTYPE].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_EXPTYPE];
    status = om$send(msg = message VLmodextCmd.VLmodGlobals
                                 (&loc_msg,NAM_G_T_EXP,
                                  me->list_att[UNFOLD_ATT_IDX_EXPTYPE]),
                        targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_EXPTYPE] =
                             me->list_att[UNFOLD_ATT_IDX_EXPTYPE];

    strcpy(ACrg[UNFOLD_ATT_IDX_SIDE].name,UNFOLD_ATT_SIDE);
    ACrg[UNFOLD_ATT_IDX_SIDE].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_SIDE].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_SIDE];
    status = om$send(msg = message VLmodextCmd.VLmodGlobals
                                 (&loc_msg,NAM_G_SIDE,
                                  me->list_att[UNFOLD_ATT_IDX_SIDE]),
                        targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_SIDE] =
                             me->list_att[UNFOLD_ATT_IDX_SIDE];
    
    strcpy(ACrg[UNFOLD_ATT_IDX_X_EXPANSION].name,UNFOLD_ATT_X_EXPANSION);
    ACrg[UNFOLD_ATT_IDX_X_EXPANSION].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_X_EXPANSION].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_X_EXPANSION];
    status = om$send(msg = message VLmodextCmd.VLmodGlobals
                               (&loc_msg,NAM_G_X_EXP,
                                me->list_att[UNFOLD_ATT_IDX_X_EXPANSION]),
                      targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_X_EXPANSION] =
                             me->list_att[UNFOLD_ATT_IDX_X_EXPANSION];

    strcpy(ACrg[UNFOLD_ATT_IDX_Y_EXPANSION].name,UNFOLD_ATT_Y_EXPANSION);
    ACrg[UNFOLD_ATT_IDX_Y_EXPANSION].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_Y_EXPANSION].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_Y_EXPANSION];
    status = om$send(msg = message VLmodextCmd.VLmodGlobals
                               (&loc_msg,NAM_G_Y_EXP,
                                me->list_att[UNFOLD_ATT_IDX_Y_EXPANSION]),
                      targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_Y_EXPANSION] =
                             me->list_att[UNFOLD_ATT_IDX_Y_EXPANSION];

    strcpy(ACrg[UNFOLD_ATT_IDX_TESSELATION].name,UNFOLD_ATT_TESSELATION);
    ACrg[UNFOLD_ATT_IDX_TESSELATION].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_TESSELATION].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_TESSELATION];
    status = om$send(msg = message VLmodextCmd.VLmodGlobals
                                 (&loc_msg,NAM_G_TESS,
                                  me->list_att[UNFOLD_ATT_IDX_TESSELATION]),
                        targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_TESSELATION] =
                             me->list_att[UNFOLD_ATT_IDX_TESSELATION];

    strcpy(ACrg[UNFOLD_ATT_IDX_UNWOPT].name,UNFOLD_ATT_UNWOPT);
    ACrg[UNFOLD_ATT_IDX_UNWOPT].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_UNWOPT].desc.value.att_exp 
		= me->old_list_att[UNFOLD_ATT_IDX_UNWOPT] 
		= me->list_att[UNFOLD_ATT_IDX_UNWOPT] ;

    strcpy(ACrg[UNFOLD_ATT_IDX_LINES].name,UNFOLD_ATT_LINES);
    ACrg[UNFOLD_ATT_IDX_LINES].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[UNFOLD_ATT_IDX_LINES].desc.value.att_exp =
                                 me->list_att[UNFOLD_ATT_IDX_LINES];
    om$send(msg = message VLmodextCmd.VLmodGlobals
                               (&loc_msg,NAM_G_UNW_CODE,
                                me->list_att[UNFOLD_ATT_IDX_LINES]),
                      targetid = my_id);
    me->old_list_att[UNFOLD_ATT_IDX_LINES] =
                             me->list_att[UNFOLD_ATT_IDX_LINES];

/*
    status = om$send(msg = message ACrg_collect.ACset_list_attribute
                                      (&loc_msg,UNFOLD_NB_OPT,ACrg ),
                        targetid = me->box.objid,
                        targetos = me->box.osnum);
    if (!(status&loc_msg&1)) {
      ex$message( msgnumb = VL_E_InvColl , buff = tmp);
      FIg_set_text(me->forms[0].form_ptr,FI_MD_MSG_FIELD,tmp);
    }
*/

    rg_coll = _MALLOC( me->Cnt1, struct GRid ) ;
    for(i=0;i<me->Cnt1;i++)
    {
	rg_coll[i].osnum = me->ModuleInfo.md_id.osnum ;
	om$construct(   classid = OPP_ACrg_collect_class_id,
			osnum   = rg_coll[i].osnum,
			p_objid = &rg_coll[i].objid,
			msg     = message ACrg_collect.ACset_list_attribute
					(&loc_msg,UNFOLD_NB_OPT,ACrg ) );
    }
  }
  if (put_batch) {
    // Should be able to accept multiple unwraps to modify
    for(i=0;i<me->Cnt1;i++)
    {
      struct GRid list_box;
      cn_type    = ND_COMP; /* recompute the object */
      status = om$send ( msg =  message NDnode.NDget_objects(
                                                ND_ROOT,
                                                &list_box,
                                                1,
                                                NULL,
                                                0,
                                                0,
                                                &num ),
                senderid  = NULL_OBJID,
                targetid = me->Lst1[i].obj_id.objid,
                targetos = me->Lst1[i].obj_id.osnum);
      if( !(status&1) ) continue;
      status = om$send ( msg = message NDnode.NDchange_connect(
						1,&list_box,&rg_coll[i] ),
                targetid = me->Lst1[i].obj_id.objid,
                targetos = me->Lst1[i].obj_id.osnum);
      if( !(status&1) ) continue;
     
      status = nd$wait_batch(type        = GR_GEOM_POSTED,
                             nb_obj      = 1,
                             l_object    = &(me->Lst1[i].obj_id),
                             l_obj_info  = &cn_type );
      nd$mod_batch(request     = ND_INQ,
		   p_ret_mode  = &b_mod );
      
      if( b_mod != ND_DEFER ){
	ex$message(msgnumb = VL_E_ModUnwrap);
	nd$exec_batch();
      }
      ex$message(msgnumb = VL_E_UnwrapMod);
    }
  }
  *sts = me->ret = MSSUCC;
  _FREE( rg_coll );
  goto quit;
}

action form_notification
{
long  msg;
int   i,options[UNFOLD_NB_OPTLINE],db_type;
char            tmp[50],*side;
struct mise_a_plat dev;
OMuword		   TEMP_cl;
struct GRobj_env   plate,surf_id;

  if( form_ptr == NULL ) return( OM_E_INVARG );

  switch(gadget_label) {

    case FI_ACCEPT :
      status = om$send(msg = message VLmodextCmd.save_all(&msg),
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
      status = om$send(msg = message VLmodextCmd.save_all(&msg),
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
        FIg_erase(me->forms[0].form_ptr,G_EXP_X_SCALE);
        FIg_erase(me->forms[0].form_ptr,G_EXP_Y_SCALE);
        FIg_erase(me->forms[0].form_ptr,G_EXP_X_TEXT);
        FIg_erase(me->forms[0].form_ptr,G_EXP_Y_TEXT);
        FIg_erase(me->forms[0].form_ptr,G_EXP_X_UNIT_mm);
        FIg_erase(me->forms[0].form_ptr,G_EXP_Y_UNIT_mm);
        FIg_erase(me->forms[0].form_ptr,G_EXP_X_UNIT_in);
        FIg_erase(me->forms[0].form_ptr,G_EXP_Y_UNIT_in);
        FIg_erase(me->forms[0].form_ptr,G_EXP_X_PCENT);
        FIg_erase(me->forms[0].form_ptr,G_EXP_Y_PCENT);
       }
      VLdecode((int) me->old_list_att[UNFOLD_ATT_IDX_LINES],UNWEXT_NB_OPT, 
               options);
      for ( i=0; i<UNWEXT_NB_OPT; i++)
      {
        if( i<UNWEXT_ATT_IDX_PARENT )
           FIfld_set_select ( me->forms[0].form_ptr, G_LINES, i, 0, options[i]);
	else
	   FIfld_set_select ( me->forms[0].form_ptr, G_PRCOPT,
				i-UNWEXT_ATT_IDX_PARENT, 0, options[i]);
      }
      break;

  case G_EXP_TYPE :

    FIg_get_text(me->forms[0].form_ptr,G_EXP_TYPE,tmp);
      if (strcmp(tmp,"No Expansion")) {
        FIg_display(me->forms[0].form_ptr,G_EXP_X_SCALE);
        FIg_display(me->forms[0].form_ptr,G_EXP_Y_SCALE);
        FIg_display(me->forms[0].form_ptr,G_EXP_X_TEXT);
        FIg_display(me->forms[0].form_ptr,G_EXP_Y_TEXT);
        if (strcmp(tmp,"Global Expansion")== 0) {
          FIg_erase(me->forms[0].form_ptr,G_EXP_X_UNIT_mm);
          FIg_erase(me->forms[0].form_ptr,G_EXP_Y_UNIT_mm);
          FIg_erase(me->forms[0].form_ptr,G_EXP_X_UNIT_in);
          FIg_erase(me->forms[0].form_ptr,G_EXP_Y_UNIT_in);
          FIg_display(me->forms[0].form_ptr,G_EXP_X_PCENT);
          FIg_display(me->forms[0].form_ptr,G_EXP_Y_PCENT);
        }
        else {
          status = co$unit_database_type( osnum   = me->ModuleInfo.md_id.osnum ,
                                          db_type = &db_type );
          if (!(status&1)) goto quit;
          if ( db_type == GRIO_UNITS_ARE_ENGLISH ) {
             FIg_erase(me->forms[0].form_ptr,G_EXP_X_PCENT);
             FIg_erase(me->forms[0].form_ptr,G_EXP_Y_PCENT);
             FIg_erase(me->forms[0].form_ptr,G_EXP_X_UNIT_mm);
             FIg_erase(me->forms[0].form_ptr,G_EXP_Y_UNIT_mm);
             FIg_display(me->forms[0].form_ptr,G_EXP_X_UNIT_in);
             FIg_display(me->forms[0].form_ptr,G_EXP_Y_UNIT_in);
          }
          else {
             FIg_erase(me->forms[0].form_ptr,G_EXP_X_PCENT);
             FIg_erase(me->forms[0].form_ptr,G_EXP_Y_PCENT);
             FIg_erase(me->forms[0].form_ptr,G_EXP_X_UNIT_in);
             FIg_erase(me->forms[0].form_ptr,G_EXP_Y_UNIT_in);
             FIg_display(me->forms[0].form_ptr,G_EXP_X_UNIT_mm);
             FIg_display(me->forms[0].form_ptr,G_EXP_Y_UNIT_mm);
          }
        }
      }
      else {
        FIg_erase(me->forms[0].form_ptr,G_EXP_X_SCALE);
        FIg_erase(me->forms[0].form_ptr,G_EXP_Y_SCALE);
        FIg_erase(me->forms[0].form_ptr,G_EXP_X_TEXT);
        FIg_erase(me->forms[0].form_ptr,G_EXP_Y_TEXT);
        FIg_erase(me->forms[0].form_ptr,G_EXP_X_PCENT);
        FIg_erase(me->forms[0].form_ptr,G_EXP_Y_PCENT);
        FIg_erase(me->forms[0].form_ptr,G_EXP_X_UNIT_in);
        FIg_erase(me->forms[0].form_ptr,G_EXP_Y_UNIT_in);
        FIg_erase(me->forms[0].form_ptr,G_EXP_X_UNIT_mm);
        FIg_erase(me->forms[0].form_ptr,G_EXP_Y_UNIT_mm);
        }
      break;


  case G_SIDE :
      FIg_get_text(me->forms[0].form_ptr,G_SIDE,tmp);
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
  FIg_enable(me->forms[0].form_ptr,G_UNW_SURF);
  FIg_enable(me->forms[0].form_ptr,G_FIBER_RATIO);
  FIg_enable(me->forms[0].form_ptr,G_EXP_TYPE);
  FIg_enable(me->forms[0].form_ptr,G_SIDE);
  FIg_enable(me->forms[0].form_ptr,G_EXP_X_SCALE);
  FIg_enable(me->forms[0].form_ptr,G_EXP_Y_SCALE);
  FIg_enable(me->forms[0].form_ptr,G_TESSELATION);
  FIg_enable(me->forms[0].form_ptr,G_LINES);
  FIg_enable(me->forms[0].form_ptr,FI_ACCEPT);
  FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
  FIg_enable(me->forms[0].form_ptr,FI_RESET);
  FIg_enable(me->forms[0].form_ptr,FI_CANCEL);
  FIg_enable(me->forms[0].form_ptr,G_WATONPLATE);
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
  FIg_disable(me->forms[0].form_ptr,G_UNW_SURF);
  FIg_disable(me->forms[0].form_ptr,G_FIBER_RATIO);
  FIg_disable(me->forms[0].form_ptr,G_EXP_TYPE);
  FIg_disable(me->forms[0].form_ptr,G_SIDE);
  FIg_disable(me->forms[0].form_ptr,G_EXP_X_SCALE);
  FIg_disable(me->forms[0].form_ptr,G_EXP_Y_SCALE);
  FIg_disable(me->forms[0].form_ptr,G_TESSELATION);
  FIg_disable(me->forms[0].form_ptr,G_WATONPLATE);
  FIg_disable(me->forms[0].form_ptr,G_LINES);
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
   FIg_set_text(me->forms[0].form_ptr,G_EXP_TYPE," ");
   FIg_set_text(me->forms[0].form_ptr,G_SIDE," ");
   goto quit;            // to avoid warning messages during compilation
}
