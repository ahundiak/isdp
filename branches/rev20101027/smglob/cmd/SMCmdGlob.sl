/* $Id: SMCmdGlob.sl,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smglob/cmd / SMCmdGlob.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdGlob.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
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

/*  
   File     SMCmdGlob 
   Date     September 92          
   Auteur   Jean Jasinczuk
  
   History:
*/

   
command_string       SMC_M_DefGlobDat,0,SMDfGlDt
command_table        "sman.cmd"
class                SMCmdGlob
super_class          CEO_LOCATE
product_name         "$VDS"
form "SMGlob",0,0,0,0

/*************************************************************************/
specification
#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "FI.h"
#include "dpmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "asmacros.h"
#include "csmacros.h"

#include "DItypedef.h"
#include "DIdef.h"

#include "UOMmacros.h"
#include "growner.h"
#include "SMdef.h"
#include "SMmacros.h"
#include "SMglob.h"
#include "SMGlobForm.h"

#include "SMmsg.h"

instance
{
  struct ACrg_coll ACrg[NB_GLOB_ATTRIB]; /* The ACrg_coll for the data */
 
  struct SMspec_attrib ship_type[MAX_SHIP_TYPE];
  /* Contains all the ship types (defined in a file) */
  int nb_ship_type; /* Number of ship type */

  struct globname act_glob;  /* The active global data (modif with list select)*/

  struct  GRobj_env act_cs;  /* The active CS (class GRgencs) found at init */
  struct  GRobj_env act_frm;     /* The active frame system found at init */
  struct GRobj_env new_act_frm;  /* The active frame system located during command*/
  struct GRobj_env new_act_cs; /* The active CS located during command (class GRgencs)*/
  IGRint nb_hull; /* Total number of hulls */
  variable struct globname global[3]; /* Array of the glob objects found */
 
  char save_unit[80];  /* EMS external unit at init of the command */
}

/******************************************************************/

implementation
#define AS_DEBUG	1
#include "AS_status.h"
#include "UOMdef.h"

%safe
static int x_form = -1,y_form = -1;
%endsafe

/********************************************************************/
state_table

#define IDENTIFY_HULL   501
#define NO_HULL_DEFINED 502
#define IDENTIFY_CS     503
#define IDENTIFY_FRAME  504

#include "SMmsg.h"


state start
erase_form 0
  
  on CMD_TYPE = 0
    do form_position 
    do init_all
       on ERROR state terminate
    do normal_state
    state form_modify

state form_modify
  display_form  0
  message_key   SM_M_DefGlobDat
  prompt_key    SM_P_GlEntParm
  filter    get_event
  
  on EX_FORM_FINISHED   state terminate 
  on GR_UNKNOWN_TYPE.IDENTIFY_HULL  state identify_hull
  on GR_UNKNOWN_TYPE.IDENTIFY_CS    state identify_cs
  on GR_UNKNOWN_TYPE.IDENTIFY_FRAME state identify_frame_syst

state identify_hull
  erase_form 0
  message_key   SM_M_DefGlobDat
  prompt_key    SM_P_GlIdHull
  accept_key           SM_P_GlAccRej
  locate_eligible  "+EMSsurface"  
  locate_owner      "LC_RIGID_COMP | LC_RIGID_OWNER |
                     LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
  filter locate

  on EX_DATA or EX_STRING do control_new_hull
                          do normal_state
                          state form_modify
  
  on EX_RJT_MOVEON        do normal_state
                          state -  

state identify_cs
  erase_form 0
  prompt_key           SM_P_GlCoord
  accept_key           SM_P_GlAccRej    
  locate_eligible      "+GRgencs"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                        LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
  filter	        locate


  on EX_DATA or EX_STRING do control_coord_syst
                          do normal_state
                          state form_modify            
  

  on EX_RJT_MOVEON   do normal_state
                     state form_modify

 
state identify_frame_syst
  erase_form 0
  prompt_key           SM_P_GlFrmSyst
  accept_key           SM_P_GlAccRej    
  locate_eligible      "SMfrm_syst"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                        LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
  filter	        locate


  on EX_DATA or EX_STRING do control_frame_syst 
                          do normal_state
                          state form_modify            
  
  on EX_RJT_MOVEON        do normal_state
                          state form_modify

at wakeup do control_unit
          do normal_state
at sleep  do erase_hilite
at delete do delete_all

/**********************************************************************/
action form_notification (int form_label; int gadget_label ; double value ;
                          char * form_ptr) extern
action save_all extern

action init_all extern

action reset_all extern

action control_new_hull extern

action modif_glob_data extern

action select_hull_list extern

action put_attr_in_form(long *sts; IGRshort def) extern 
/**************************************************************************/
action control_coord_syst
{
  char name[DI_PATH_MAX];

  me->new_act_cs.obj_id    = me->event1.located_object[0].located_obj;
  me->new_act_cs.mod_env   = me->event1.located_object[0].module_info;

  /* Cs located is the active cs */ 
  if(me->act_cs.obj_id.objid == me->new_act_cs.obj_id.objid &&
     me->act_cs.obj_id.osnum == me->new_act_cs.obj_id.osnum)
   {
     *sts = OM_S_SUCCESS; goto quit;
   }
   
  SMGetSplitName(&me->new_act_cs.obj_id,name);
  FIg_set_text(me->forms[0].form_ptr,G_CS,name);

  status = as$make_source(go_grid =  me->new_act_cs.obj_id,
			  mod_env = &me->new_act_cs.mod_env,
			  as_os   =  me->ModuleInfo.md_id.osnum,
			  as_grid = &me->new_act_cs.obj_id);
  as$status(action = RET_STATUS);
  
  *sts = OM_S_SUCCESS;
}

action control_frame_syst
{
  char name[DI_PATH_MAX];

  me->new_act_frm.obj_id   = me->event1.located_object[0].located_obj;
  me->new_act_frm.mod_env  = me->event1.located_object[0].module_info;

  SMGetSplitName(&me->new_act_frm.obj_id,name);
  FIg_set_text(me->forms[0].form_ptr,G_FRM,name);
    
  *sts = OM_S_SUCCESS;
}

action normal_state
{
  IGRlong msg;

  if(me->new_act_cs.obj_id.objid != NULL_OBJID)
    dp$display(msg = &msg, oids = &me->new_act_cs.obj_id, mode = GRhe);
  if(me->new_act_frm.obj_id.objid != NULL_OBJID)
    dp$display(msg = &msg, oids = &me->new_act_frm.obj_id, mode = GRhe);
  if(me->act_glob.hull.objid != NULL_OBJID)
    dp$display(msg = &msg, oids = &me->act_glob.hull, mode = GRhhd);

  FIg_set_state_off(me->forms[0].form_ptr,G_ID_CS);
  FIg_set_state_off(me->forms[0].form_ptr,G_ID_HULL);
  FIg_set_state_off(me->forms[0].form_ptr,G_ID_FRM);
  *sts = OM_S_SUCCESS;
}

action erase_hilite
{
  IGRlong msg;

  dp$erase_hilite(msg = &msg);
  *sts = OM_S_SUCCESS;
}

action form_position
{
  if(x_form == -1 || y_form == -1)
   { x_form = 1; y_form = 100; }
  FIf_set_location(me->forms[0].form_ptr,x_form,y_form);
  *sts = OM_S_SUCCESS;
}

action control_unit
{
  int          i; 
  IGRlong      msg;
  char         tmp[80],cur_unit[40];
  double       val_db;
  short        flag = 1, num_defaults = 1;
  GRIOalias_name  alias_name[UOM_K_MAX_DEFS];
  static short gadget_label[] = {G_LPP,G_BMO,G_DMO,G_LOA,G_DDE,G_SHE,G_KEE};

  /* Get default unit for distance */
  status = uom$get_default_units(msg           = &msg,
				 table_name    = GRIO_DISTANCE,
				 flag          = &flag,
				 num_defaults  = &num_defaults,
				 default_units = alias_name,
                                 osnum         = me->ModuleInfo.md_id.osnum);
  if(status & 1) strcpy( cur_unit, alias_name[0] );
  else uom$report_error(msg = status);
 
  /* If unit change during wakeup, change current unit and recompute value */
  if(strcmp(me->save_unit,cur_unit))
   {
     FIg_set_text(me->forms[0].form_ptr,G_UNIT,cur_unit);
     FIfld_set_default_text(me->forms[0].form_ptr,G_UNIT,
			    0,0,cur_unit,0);
     for(i = 0; i < 7; i++)
      {
	tmp[0] = '\0';
	FIg_get_text(me->forms[0].form_ptr,gadget_label[i],tmp);
	if(tmp[0] != '\0')
	 {
	   FIg_get_value(me->forms[0].form_ptr,gadget_label[i],&val_db);
	   status =
	     uom$cvt_value_to_value
	       (msg               = &msg,
		unit_type         = GRIO_DISTANCE,
		osnum             = me->ModuleInfo.md_id.osnum,
		alias_to_cvt_from = me->save_unit,
		alias_to_cvt_to   = cur_unit,
		num_vals          = 1,
		values_in         = &val_db,
		values_out        = &val_db);
	   if(!(status & 1)) uom$report_error( msg = status);
	   FIg_set_value(me->forms[0].form_ptr,gadget_label[i],val_db);
	 }
      }
     strcpy(me->save_unit,cur_unit);
   }

  *sts = OM_S_SUCCESS;
}

action  delete_all
{
  if(me->forms[0].form_ptr)
    FIf_get_location(me->forms[0].form_ptr,&x_form,&y_form);
  *sts = OM_S_SUCCESS;
}

