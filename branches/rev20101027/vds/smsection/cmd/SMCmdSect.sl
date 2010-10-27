/* $Id: SMCmdSect.sl,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsection/cmd / SMCmdSect.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdSect.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*    File          SMCmdSect.sl
      Description   Command object for place or modify calcution section
      Auteur        Jean Jasinczuk (ISDC) 
      Date          October 92

      Modification:
      March 93 : Add control of unit
      April 93 : Compile for 2.2
*/

command_string       SMC_M_SectPl,0,SMPlClSc
synonym              SMC_M_SectMd,1,SMMDClSc
class                SMCmdSect
command_table        "sman.cmd"
super_class          VDS_LOCATE
product_name        "$VDS"

form "SMCalSect",0,0,"-1","-1"

specification

#include <stdio.h>
#include <string.h>
#include <math.h>
#include "OMmacros.h"
#include  "growner.h"
#include  "coparamac.h"
#include "asmacros.h"

#include "dp.h"
#include "dpmacros.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACrg_collect.h"

#include "FI.h"

#include "SMdef.h"
#include "SMmacros.h"
#include "SMsection.h"

#include "SMmsg.h"

instance
{
  struct GRid sect_id;  /* Id of the working section */

  variable struct GRid save_comp[1];
  variable struct GRmd_env save_comp_env[1];

  /* List of the compart corresponding to the last save */

  int save_nb_comp; /* Number of  polygon in preceding list*/

  variable struct GRid work_comp[1];
  variable struct GRmd_env work_comp_env[1];

  /* Buffer for compart : modified when user add, delete one*/

  int work_nb_comp; /* Number of assigned polygon */  

  struct GRid     save_frame[2 * SM_MAX_PARTS];
  struct GRmd_env save_frame_env[2 * SM_MAX_PARTS];
  /* List of frame id if multi part section */
  int save_nb_frame;

  struct GRid     work_frame[2 * SM_MAX_PARTS];
  struct GRmd_env work_frame_env[2 * SM_MAX_PARTS];

  /* Buffer of frame id if multi part section */ 

  int work_nb_frame;

  struct SMSectInfo save_info;     /* The info of the section */
  struct SMSectInfo work_info;     /* Buffer for  info of section */ 

  IGRchar save_unit[80];          /* Current distance unit */
}

/******************************************************************/

implementation

#define AS_DEBUG	1

#include "UOMdef.h"
#include "UOMmacros.h"
#include "AS_status.h"

from NDnode import NDdisplay;
from GRgraphics import GRdisplay;

%safe
  static int x_pos = -1,y_pos = -1;
%endsafe

/********************************************************************/
state_table

#define TRUE  1
#define FALSE 0


#include "SMsection.h"

#include "SMmsg.h"
#include "VDSFilter.h"

state start
  on CMD_TYPE = PLACE 
         do message_key SM_M_ScPl
         do init_form_new_sect
         state form_modify
  on CMD_TYPE = MODIFY
         do message_key SM_M_ScMd
         state locate_sect

state locate_sect
erase_form 0
prompt_key   SM_P_ScLocSec
accept_key   SM_P_PlAccRej
locate_mask "GRm_DATA | GRm_TEXT_VALUE"
locate_eligible "SMsection"
locate_owner     "LC_RIGID_COMP | LC_RIGID_OWNER |
                  LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
filter vds_locate
  
  on EX_DATA or EX_STRING
   do locate_sect
        on ERROR state .
   do erase_hilite
   do hilite_half
   state form_modify
  

state locate_comp
prompt_key   SM_P_ScLocComp
accept_key   SM_P_PlAccRej
locate_mask "GRm_DATA | GRm_OBJID | GRm_RESET | GRm_TEXT_VALUE"
locate_class "SMcomp"
locate_owner  "LC_RIGID_COMP | LC_RIGID_OWNER |
               LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
filter vds_locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID
   do add_locate_comp
      on RETURN_CODE = NO_OBJ_LOCATED do status_key SM_E_ScNoLocComp state .
   state .

  on EX_RJT_MOVEON 
   do chg_state_button(&me->ret,TRUE)
   state -

state locate_fr_frm
prompt_key   SM_P_ScLocFrFr
accept_key   SM_P_PlAccRej
locate_mask "GRm_DATA | GRm_RESET | GRm_TEXT_VALUE"
locate_class "SMframe"
locate_owner  "LC_RIGID_COMP | LC_RIGID_OWNER |
               LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
filter vds_locate

  on EX_DATA or EX_STRING
   do add_locate_frame 
     on RETURN_CODE = TOO_MUCH_OBJECT do status_key SM_E_ScTooMuchFr state .
     on RETURN_CODE = NO_OBJ_LOCATED do status_key  SM_E_ScBadFrNum state .
   state locate_to_frm

  on EX_RJT_MOVEON 
    do chg_state_button(&me->ret,TRUE)
    state -

state locate_to_frm
prompt_key   SM_P_ScLocToFr
accept_key   SM_P_PlAccRej
locate_mask "GRm_DATA | GRm_RESET | GRm_TEXT_VALUE"
locate_class "SMframe"
locate_owner  "LC_RIGID_COMP | LC_RIGID_OWNER |
               LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
filter vds_locate_noauto

  on EX_DATA or EX_STRING
  do add_locate_frame 
     on RETURN_CODE = TOO_MUCH_OBJECT do status_key SM_E_ScTooMuchFr state .
     on RETURN_CODE = NO_OBJ_LOCATED do status_key  SM_E_ScBadFrNum state .
  state .

  on EX_RJT_MOVEON
    do chg_state_button(&me->ret,TRUE)
    state form_modify

state form_modify
display_form  0
  on CMD_TYPE = PLACE
   do message_key SM_M_ScPl state form_sect
  on CMD_TYPE = MODIFY
   do message_key  SM_M_ScMd state form_sect
 

state form_sect
prompt_key    SM_P_ScFrMod
filter	get_event

  on GR_UNKNOWN_TYPE.RELOCATE_OBJ
     on CMD_TYPE = PLACE 
           do erase_hilite
           do init_form_new_sect
           state form_modify
     on CMD_TYPE = MODIFY  
        do erase_hilite
        state locate_sect
   state . 
  on GR_UNKNOWN_TYPE.LOCATE_FR
    do chg_state_button(&me->ret,FALSE)
    do erase_hilite
    state locate_fr_frm
  on GR_UNKNOWN_TYPE.LOCATE_COMP
     do chg_state_button(&me->ret,FALSE)
     state locate_comp
  
at init   do form_position
at wakeup do hilite_half
          do control_unit
at sleep  do erase_hilite
at delete do delete_all

/*********************************************************************/

action form_notification                  extern

action init_form_new_sect                 extern

action control_sect                       extern

action place_sect(IGRlong *msg)           extern

action modif_sect(IGRlong *msg)           extern

action save_all                           extern

action reset_all                          extern

action mode_list                          extern

action add_locate_comp                    extern

action put_sect_param                     extern

action copy_param ( long *sts ; int flag) extern

action add_locate_frame                   extern


/**********************************************************************/

action erase_hilite
{
  status = dp$erase_hilite (msg = &me->ret,
			    objid = me->ModuleInfo.md_id.objid,
			    osnum = me->ModuleInfo.md_id.osnum);
}


action hilite_half
{
  int 			i;
  enum GRdpmode		mode;
  IGRlong		msg;
  struct GRid		go_cs;
  struct GRmd_env	cs_env;


  mode = GRhhd;

  status = SMGetDefCs(TRUE,                   /* take EMS cs */
		      (struct GRid *)NULL,     /* Connected with Db not needed */
		      (IGRshort *)NULL,        /* State not used */ 
		      &go_cs,     
		      (struct GRid *) NULL,    /* Associative cs not needed */
		      &cs_env, /* No mod env */
		      (IGRboolean *)NULL);     /* No flag needed */
 
  status = om$send(msg     = message GRgraphics.GRdisplay(
                                &msg,
                                &cs_env.md_env.matrix_type,
                                cs_env.md_env.matrix,
                                &mode,
                                &me->ModuleInfo.md_id ),
                targetid= go_cs.objid,
                targetos= go_cs.osnum ) ;
       
  as$status();

  

  if(me->work_info.mode == SM_SECT_USER)
    for(i = 0 ; i < me->work_nb_frame; i++)
     {
       status =  om$send(msg = message NDnode.NDdisplay
			 (0, GRhhd, &me->ModuleInfo),
			 targetid = me->work_frame[i].objid,
			 targetos = me->work_frame[i].osnum);
       as$status(action = CONTINUE,
		 msg = "Warning cannot hilight located frame"); 
     }
}

/* ----------------------- action chg_state_button ------------- */
/* Change state of gadget when add or delete polygon state       */
/* If enable = TRUE enable else disable                          */

action chg_state_button( int *sts ; IGRboolean enable)
{
  if(enable)
   {
     SMVA_enable(me->forms[0].form_ptr,10,
		 G_MODE_LIST,G_COMP,G_END_OFFSET,G_NB_SECT,
		 G_SECT_LIST,G_LOCATE_FR,
		 FI_ACCEPT,FI_EXECUTE,FI_RESET);
     FIg_set_state_off(me->forms[0].form_ptr,G_COMP);
     FIg_set_state_off(me->forms[0].form_ptr,G_LOCATE_FR);
   }
  else
   {
     SMVA_disable(me->forms[0].form_ptr,10,
		  G_MODE_LIST,G_COMP,G_END_OFFSET,G_NB_SECT,
		  G_SECT_LIST,G_LOCATE_FR,
		  FI_ACCEPT,FI_EXECUTE,FI_RESET);
   }
}


/* -------------------- action toggle_mode -------------------------- */
/* Display or erase some gadget in the form corresponding to the mode */

action toggle_mode( long *sts ; int mode )
{
  switch(mode)
   {
   case SM_SECT_SGL:
     SMVA_erase(me->forms[0].form_ptr,7,
		G_FROM_FRAME,G_FR_DX,G_TO_FRAME,G_TO_DX,G_NB_SECT_LAB,
		G_SECT_LIST,G_LOCATE_FR);
     SMVA_display(me->forms[0].form_ptr,2,
		  G_NB_SECT_TEXT,G_NB_SECT);
     FIg_set_text(me->forms[0].form_ptr,G_MODE_LIST,"Single Part");
     break;
   case SM_SECT_USER:
     SMVA_erase(me->forms[0].form_ptr,2,
		G_NB_SECT_TEXT,G_NB_SECT);
     SMVA_display(me->forms[0].form_ptr,7,
		G_FROM_FRAME,G_FR_DX,G_TO_FRAME,G_TO_DX,G_NB_SECT_LAB,
		G_SECT_LIST,G_LOCATE_FR);
     FIg_set_text(me->forms[0].form_ptr,G_MODE_LIST,"Multi. Parts");
     break;
   case SM_SECT_AUTO:
     FIg_set_text(me->forms[0].form_ptr,G_MODE_LIST,"Automatic");
     printf("Not yet implemented auto mode\n");
     break;
   }
}

/* ------------------- action control_unit -------------------------------- */
/* Redisplay the unit and recompute field which need recomputing            */

action control_unit
{
  int     i,row,num_rows,col; 
  IGRlong msg;
  char    tmp[80];
  double  val_db,coef;
  char    cur_unit[40];
  short   flag = 1, num_defaults = 1;
  GRIOalias_name  alias_name[UOM_K_MAX_DEFS];

  /* Get default unit for distance */
  status = uom$get_default_units(msg           = &msg,
				 table_name    = GRIO_DISTANCE,
				 flag          = &flag,
				 num_defaults  = &num_defaults,
				 default_units = alias_name,
                                 osnum         = me->ModuleInfo.md_id.osnum);
  if(status & 1) strcpy( cur_unit, alias_name[0] );
  else uom$report_error(msg = status);

  if(me->save_unit[0] == '\0')
   {
     strcpy(me->save_unit,cur_unit);
     goto quit;
   }

  /* If unit change during wakeup, change current unit and recompute value */
  if(strcmp(me->save_unit,cur_unit))
   {
     coef = 1.0;
     status =
       uom$cvt_value_to_value
	 (msg               = &msg,
	  unit_type         = GRIO_DISTANCE,
	  osnum             = me->ModuleInfo.md_id.osnum,
	  alias_to_cvt_from = me->save_unit,
	  alias_to_cvt_to   = cur_unit,
	  num_vals          = 1,
	  values_in         = &coef,
	  values_out        = &coef);
     if(!(status & 1)) uom$report_error( msg = status);
     
     if(SMget_double(me->forms[0].form_ptr,G_END_OFFSET,0,0,&val_db))
      {
	val_db = val_db * coef;
	FIg_set_value(me->forms[0].form_ptr,G_END_OFFSET,val_db);
      }

     /* If multi part, convert all other offset */
     FIg_get_text(me->forms[0].form_ptr,G_MODE_LIST,tmp);
     if(strncmp(tmp,"Multi",5) == 0)
      {
	FIfld_get_num_rows(me->forms[0].form_ptr,G_SECT_LIST,&num_rows);
	for(row = 0; row < num_rows / 2 ; row++)
	  for(col = 1 ; col <= 3; col += 2)
	    if(SMget_double(me->forms[0].form_ptr,G_SECT_LIST,row,col,&val_db))
	       {
		 val_db = val_db * coef;
		 FIfld_set_value(me->forms[0].form_ptr,G_SECT_LIST,row,col,
				 val_db,0);
	       }
	  
      }
     strcpy(me->save_unit,cur_unit);
   }

  *sts = OM_S_SUCCESS;
}

  
/*-------------------- action form_position -------------   */
/* Position all the forms (relative to the main form)       */
/* Delete some gadget following type of the command         */

action form_position
{
  if(x_pos != -1 || y_pos != -1)
    FIf_set_location(me->forms[0].form_ptr,x_pos,y_pos);

  switch(me->mytype)
    {
    case  PLACE:
      FIg_set_text(me->forms[0].form_ptr,G_TITLE,"Place Calc. Sections");
      break;
    case MODIFY:
      FIg_set_text(me->forms[0].form_ptr,G_TITLE,"Modify Calc. Sections");
      FIg_disable(me->forms[0].form_ptr,G_COMP);
      break;
    }

  /* KLUDGE : TEMPORARY NO AXIS */
  SMVA_disable(me->forms[0].form_ptr,3,G_X_AXIS,G_Y_AXIS,G_Z_AXIS);
  me->save_unit[0] = '\0';
}

/* --------------------- action locate_sect ------------------- */

action locate_sect
{
  me->sect_id = me->event1.located_object[0].located_obj;
  status = om$send(msg = message SMCmdSect.control_sect(sts),
		   targetid = my_id);
  return status;
}

action delete_all
{
  FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);
}

