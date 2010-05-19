/* $Id: SMCmdWind.sl,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smwind/cmd / SMCmdWind.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdWind.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
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
# Revision 1.2  1995/09/25  21:49:12  pinnacle
# Replaced: smwind/cmd/SMCmdWind.sl for:  by sundar for vds.240
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

/*    File          SMCmdWind.sl
      Description   Command object for place or modify wind area polygon
      Auteur        Jean Jasinczuk (ISDC) 
      Date          September 92
*/

command_string       SMC_M_WindPl,0,SMPlWnArPl
synonym              SMC_M_WindMd,1,SMMdWnArPl
class                SMCmdWind
command_table        "sman.cmd"
super_class         CEO_LOCATE
product_name        "$VDS"

form "SMWind",0,0,"-1","-1"

specification

#include <stdio.h>
#include <string.h>
#include <math.h>
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
#include "SMmacros.h"
#include "SMWindForm.h"

#include "SMmsg.h"

instance
{
  struct GRid wind_id;  /* Id of the working wind area */

  struct ACrg_coll WindACrg[SM_WIND_NB_MAX_ATTR]; /* Attributes of the compart */
  int NbWindAtt;          /* Number of attributes for the compart */

  struct Wind_Polygon save_poly[SM_MAX_ALLOW_PLG];
  /* List of the polygons corresponding to the last save */
  int save_nb_poly; /* Number of  polygon in preceding list*/

  struct Wind_Polygon work_poly[SM_MAX_ALLOW_PLG];
  /* Buffer for polygons : modified when user add, delete one*/
  int work_nb_poly; /* Number of assigned polygon */  

  IGRboolean state_del;    /* If TRUE, the user is selecting polygon to del */
}

/******************************************************************/

implementation

#ifdef ENV5
%safe
#include "VX_FIproto.h"
%endsafe
#endif

#define AS_DEBUG	1

from GRgraphics import GRdisplay;

%safe
  static int x_pos = -1,y_pos = -1;
%endsafe

/********************************************************************/
state_table

#define TRUE  1
#define FALSE 0


#include "SMWindForm.h"

#include "SMmsg.h"

state start
  on CMD_TYPE = PLACE 
         do message_key SM_M_WdPl
         do init_form_new_wind
         state form_modify
  on CMD_TYPE = MODIFY
         do message_key SM_M_WdMd
         state locate_wind_area

state locate_wind_area
erase_form 0
erase_form 1
erase_form 2
prompt_key   SM_P_WdLoc
accept_key   SM_P_PlAccRej
locate_mask "GRm_DATA | GRm_TEXT_VALUE"
locate_eligible "SMwind"
locate_owner     "LC_RIGID_COMP | LC_RIGID_OWNER |
                  LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
filter locate
  
  on EX_DATA 
   do locate_wind
        on ERROR state .
   do erase_hilite
   do hilite_half
   state form_modify
  

state locate_poly
prompt_key   SM_P_LocPoly
accept_key   SM_P_PlAccRej
locate_mask "GRm_DATA | GRm_OBJID | GRm_RESET | GRm_TEXT_VALUE"
locate_class "GRlinear"
locate_owner  "LC_RIGID_COMP | LC_RIGID_OWNER |
               LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
filter locate_noauto

  on EX_DATA or  EX_OBJID
   do add_locate_polygon
      on RETURN_CODE = NO_OBJ_LOCATED do status_key SM_E_WdNoLocPoly state .
      on RETURN_CODE = TO_MUCH_POLY   do status_key SM_E_WdTooMuchPoly
                                      state terminate
    state .
  on EX_RJT_MOVEON 
   do chg_state_button(&me->ret,TRUE)
   state -

state form_modify
display_form  0
  on CMD_TYPE = PLACE
   do message_key SM_M_WdPl state form_wind
  on CMD_TYPE = MODIFY
   do message_key  SM_M_WdMd state form_wind
 

state form_wind
display_form  0
prompt_key    SM_P_WdFrMod
filter	get_event

  on GR_UNKNOWN_TYPE.RELOCATE_OBJ
     on CMD_TYPE = PLACE 
           do erase_hilite
           state .
     on CMD_TYPE = MODIFY  
        do erase_hilite
        state locate_wind_area
   state . 
  on GR_UNKNOWN_TYPE.LOCATE_POLY
    do chg_state_button(&me->ret,FALSE)
    state locate_poly
  
at init   do form_position
at wakeup do hilite_half
at sleep  do erase_hilite
at delete do delete_all

/*********************************************************************/

action form_notification extern

action init_form_new_wind extern

action control_wind extern

action save_all extern

action reset_all extern

action add_locate_polygon extern

action select_delete_polygon extern

action SMplace_wind(IGRlong *msg; char *name) extern

action SMmodif_wind(IGRlong *msg; char *name) extern

/**********************************************************************/

/*-------------------- action hilite_half --------------------------- */
/*                 Semi hilite all selected polygons                   */

action hilite_half
{
  long msg;
  int i;
  
  enum GRdpmode DisplayMode = GRhhd;

  for(i = 0; i< me->work_nb_poly; i++)
   {
     status = om$send(msg = message GRgraphics.GRdisplay
		      (&msg,
		       &me->ModuleInfo.md_env.matrix_type,
		       me->ModuleInfo.md_env.matrix,
		       &DisplayMode,
		       &me->ModuleInfo.md_id ),
		      targetid = me->work_poly[i].id.objid,
		      targetos = me->work_poly[i].id.osnum);
		    
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
/* Change state of gadget when add or delete polygon state       */
/* If enable = TRUE enable else disable                          */

action chg_state_button( long *sts ; IGRboolean enable)
{
  if(enable)
   {
     SMVA_enable(me->forms[0].form_ptr,6,
		 G_ADD,G_REMOVE,G_POLY_LIST,FI_ACCEPT,FI_EXECUTE,FI_RESET);
     FIg_set_state_off(me->forms[0].form_ptr,G_ADD);
   }
  else
   {
     SMVA_disable(me->forms[0].form_ptr,4,
		  G_ADD,FI_ACCEPT,FI_EXECUTE,FI_RESET);
     if(me->state_del == FALSE) /* Add state */
       SMVA_disable(me->forms[0].form_ptr,2,
		    G_REMOVE,G_POLY_LIST);
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
      FIg_set_text(me->forms[0].form_ptr,G_TITLE,"Place Wind Area Polygon");
      break;
    case MODIFY:
      FIg_set_text(me->forms[0].form_ptr,G_TITLE,"Modify Wind Area Polygon");
      break;
    }
  FIfld_set_mode(me->forms[0].form_ptr,G_POLY_LIST,GI_NAME,FI_REVIEW);
  me->state_del = FALSE;
}

action locate_wind
{
  me->wind_id = me->event1.located_object[0].located_obj;
  status = om$send(msg = message SMCmdWind.control_wind(sts),
		   targetid = my_id);
  return status;
}

action delete_all
{
  FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);
}

