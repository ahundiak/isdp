/* $Id: SMCmdRptObj.sl,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smreports/cmd / SMCmdRptObj.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdRptObj.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
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
# Revision 1.2  1996/03/05  06:40:54  pinnacle
# Replaced: smreports/cmd/SMCmdRptObj.sl for:  by ksundar for vds.240
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
 *      03/05/96	Sundar 		Included SMCmdReports.h
 * -------------------------------------------------------------------*/

/*    File          SMCmdRptObj.sl
      Description   Command object for place or modify report object
      Auteur        Jean Jasinczuk (ISDC) 
      Date          November 1992
*/

command_string      SMC_M_PlRptObj,0,SMDfSrRp
synonym		    SMC_M_MdRptObj,1,SMMdSrRp
class               SMCmdRptObj
command_table        "sman.cmd"
super_class         CEO_LOCATE
product_name        "$VDS"

form "SMCrtRptObj",0,0,"-1","-1"

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

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "FI.h"

#include "SMdef.h"
#include "SMReports.h"
#include "SMRptObj.h"
#include "SMmacros.h"


#include "SMmsg.h"

instance
{
  struct GRid rep_id;  /* Id of the working rep area */
  
  variable struct RepParent save_parent[1];
  /* List of the parents corresponding to the last save */
  int save_nb_parent; /* Number of  report in preceding list*/

 variable  struct  RepParent work_parent[1];
  /* Buffer for parents  : modified when user add, delete one*/
  int work_nb_parent; /* Number of assigned report */  

  IGRboolean state_list;    /* If TRUE, the user is selecting report to del */
}

/******************************************************************/

implementation

#define AS_DEBUG	1

from GRgraphics import GRdisplay;

%safe
  static int x_pos = -1,y_pos = -1;
%endsafe

/********************************************************************/
state_table

#define TRUE  1
#define FALSE 0

#include "SMCmdReports.h"

#include "SMmsg.h"

state start
  on CMD_TYPE = PLACE 
         do message_key SM_M_PlRptObj
         do init_form_new_rep
         state form_modify
  on CMD_TYPE = MODIFY
         do message_key SM_M_MdRptObj
         state locate_report

state locate_report
prompt_key   SM_P_RpLocRep
accept_key   SM_P_PlAccRej
locate_mask "GRm_DATA | GRm_TEXT_VALUE"
locate_eligible "SMreports"
locate_owner     "LC_RIGID_COMP | LC_RIGID_OWNER |
                  LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
filter locate
  
  on EX_DATA 
   do locate_rep
        on ERROR state .
   do erase_hilite
   do hilite_half
   state form_modify
  

state locate_parent
prompt_key   SM_P_RpLocObj
accept_key   SM_P_PlAccRej
locate_mask  "GRm_DATA | GRm_OBJID | GRm_RESET | GRm_TEXT_VALUE"
locate_class "EMSsurface,EMSsolid,SMreports"
locate_owner  "LC_RIGID_COMP | LC_RIGID_OWNER |
               LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
filter locate_noauto

  on EX_DATA or  EX_OBJID
   do add_locate_parent
      on RETURN_CODE = NO_OBJ_LOCATED do status_key SM_E_RpNoLoc state .
    state .
  on EX_RJT_MOVEON 
   do chg_state_button(&me->ret,TRUE)
   state -

state form_modify
display_form  0
  on CMD_TYPE = PLACE
   do message_key SM_M_PlRptObj state form_rep
  on CMD_TYPE = MODIFY
   do message_key  SM_M_MdRptObj state form_rep
 

state form_rep
display_form  0
prompt_key    SM_P_RpForm
filter	get_event

  on GR_UNKNOWN_TYPE.RELOCATE_OBJ
     on CMD_TYPE = PLACE 
           do erase_hilite
           do init_form_new_rep 
           state .
     on CMD_TYPE = MODIFY  
        do erase_hilite
        do init_form_new_rep 
        state locate_report
   state . 
  on GR_UNKNOWN_TYPE.LOCATE_PARENT
    do chg_state_button(&me->ret,FALSE)
    state locate_parent
  
at init   do form_position
at wakeup do hilite_half
at sleep  do erase_hilite
at delete do delete_all

/*********************************************************************/

action form_notification extern

action init_form_new_rep extern

action control_rep extern

action copy_param( long *sts ; int flag ) extern

action save_parent extern

action save_all extern

action reset_all extern

action add_locate_parent extern

action select_delete_parent extern

action SMplace_rep(long *msg; char *name ; char *desc) extern

action SMmodif_rep(long *msg; char *name ; char *desc) extern

/**********************************************************************/

/*-------------------- action hilite_half --------------------------- */
/*                 Semi hilite all selected reports                   */

action hilite_half
{
  long msg;
  int i;
  
  enum GRdpmode DisplayMode = GRhhd;

  for(i = 0; i< me->work_nb_parent; i++)
   {
     status = om$send(msg = message GRgraphics.GRdisplay
		      (&msg,
		       &me->ModuleInfo.md_env.matrix_type,
		       me->ModuleInfo.md_env.matrix,
		       &DisplayMode,
		       &me->ModuleInfo.md_id ),
		      targetid = me->work_parent[i].id.objid,
		      targetos = me->work_parent[i].id.osnum);
		    
     if(!(status & msg & 1))
      {printf("Error at GRdisplay\n");}
   }  

  *sts = MSSUCC;
  status = OM_S_SUCCESS;
} 

action erase_hilite
{
    status = dp$erase_hilite (msg = &me->ret,
                              objid = me->ModuleInfo.md_id.objid,
                              osnum = me->ModuleInfo.md_id.osnum);
}

/* ----------------------- action chg_state_button ------------- */
/* Change state of gadget when add or delete surface state       */
/* If enable = TRUE enable else disable                          */

action chg_state_button( long *sts ; IGRboolean enable)
{
  if(enable)
   {
     SMVA_enable(me->forms[0].form_ptr,8,
		 G_NAME,G_DESC,G_ADD, G_REMOVE,G_PARENT_LIST,
		 FI_ACCEPT,FI_EXECUTE,FI_RESET);
     FIg_set_state_off(me->forms[0].form_ptr,G_ADD);
     FIg_set_state_off(me->forms[0].form_ptr,G_REMOVE);
     me->state_list = NORMAL_STATE;
   }
  else
   {
     SMVA_disable(me->forms[0].form_ptr,6,
		  G_NAME,G_DESC,G_ADD,
		  FI_ACCEPT,FI_EXECUTE,FI_RESET);
     if(me->state_list == ADD_STATE) /* Add state */
       SMVA_disable(me->forms[0].form_ptr,2,
		    G_REMOVE,G_PARENT_LIST);
   }
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
      FIg_set_text(me->forms[0].form_ptr,G_TITLE,"Place Report Object");
      break;
    case MODIFY:
      FIg_set_text(me->forms[0].form_ptr,G_TITLE,"Modify Report Object");
      break;
    }
  FIfld_set_mode(me->forms[0].form_ptr,G_PARENT_LIST,GI_NAME,FI_REVIEW);
  me->state_list = NORMAL_STATE;
}

action locate_rep
{
  me->rep_id = me->event1.located_object[0].located_obj;
  status = om$send(msg = message SMCmdRptObj.control_rep(sts),
		   targetid = my_id);
  return status;
}

action delete_all
{
  FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);
}

