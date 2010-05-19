/* $Id: SMCmdStrSf.sl,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:	smstrsf/SMCmdStrSf.sl
 *
 * Description:	
 *
 *	This command implements the structural surface placement and
 *	modify.
 *
 * Dependencies:
 *	VDCmdAttMgr	Management of the attributes in the form
 *	VDCmdPart	Management of the part selection in the form
 *
 * Revision History:
 *	$Log: SMCmdStrSf.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
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
# Revision 1.4  1996/05/27  05:53:30  pinnacle
# Replaced: smstrsf/cmd/SMCmdStrSf.sl for:  by apazhani for vds.240
#
# Revision 1.3  1996/04/29  06:06:50  pinnacle
# Replaced: smstrsf/cmd/SMCmdStrSf.sl for:  by ksundar for vds.240
#
# Revision 1.2  1995/11/29  13:52:50  pinnacle
# Replaced: ./smstrsf/cmd/SMCmdStrSf.sl for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	02/01/93	Jean Jasinczuk: 	Creation Date.
 *	05/01/94	P. Lacroix :	Subclass SMCmdStrSf from VDCmdAttMgr
 *			and VDCmdPart instead of SMCoDb that has been removed.
 * -------------------------------------------------------------------------
 */


command_string       SMC_M_CmSurfPl,0,SMPlMnSf
synonym              SMC_M_CmSurfMd,1,SMMdMnSf
class                SMCmdStrSf
command_table        "sman.cmd"
super_class          VDCmdPart
super_class          VDCmdAttMgr
product_name        "$VDS"

form "SMStructSurf",0,0,"-1","-1"

/*---------------------
 * specification area
 */

specification

/*+cmd
/* -------------------------------------------------------------------------

  Command Object Class SMCmdStrSf

  Superclass
	VDCmdAttMgr, VDCmdPart

  Abstract
 	This command implements the structural surfaces
 	creation and modification.


  Methods

     hilite_half	Public		Semi hilite all stored volumes.

     chg_state_locate	Public		Disable all gadget but FI_CANCEL. 
					Usefull for locate.

     locate_main_surf	Public		Store the located surface and control
					its parameters.

     read_pdu_review	Public		read the part from pdu ,verify if
					it has already been placed and store
					me->db_info.catalog.

     control_login	Public		Verify if the user is logged into the 
					database ,erase some gadgets if needed
					and set the me->db_info.catalog.

     put_list_attr	Public		Put the correct list of attributes in
					the field and display it.

     control_unit	Public		Get the current unit, and verify that
					all the info are in that unit.

     empty_form_state 	Public		Set me->form_state and 
					me->old_form_state to EMPTY_STATE.

     chg_state_select_db Public		enable or disable some gadgets.

     chg_state_db	Public		enable or disable the GROUP_SELECT 
					gadgets.

     disp_attr_gadgets	Public		display or erase the gadgets for the
					attributes.



     init_form_new_surf	Public		Initialise the form for a new surface.

     control_main_surf	Public		display all parameters for the located
					main surface and fills the instances 
					with the info.

     add_locate_surface	Public		Store the located surface and add it 
					in the form.

     put_surf_att_in_form Public	Retrieve main parameters for a main 
					surface and display them in form.

     put_geom_info	Public		Get all geometrical info from 
					me->work_att and put them in the form.



  Overridden Methods

     init_all			initialise the instances.

     delete_all			free the allocated instances.

     form_position		displays the forms in the right position.

     control_form_state		displays the form depending on its state.

     VDLoadSelPart		loads the selected part and set the db_info
				structure.

     fill_attr_from_part	parse the static and dynamic attributes to fill
				the me->save_att structure.

     VDReadFromPdu		Read the selected part from PDU, retrieve the
				attributes for that part and fills me->save_att
				structure.

     VDLoadDbAttr		Load the static attribute from the me->db_info
				catalog and display them in the me->g_db_list.


     VDSetRgAtt			Set the VDCmdAttMgr instances with my data

     VDSaveListDyn		save the attribute written in the form into
				the instances.

     VDSelectTog		Displays in the right field either the dynamic 
				or static attributes depending on the toggle 
				state.

     form_notification		implements the main gadgets (EXIT, SAVE ...)

     reset_all			called at the FI_RESET.

     save_all			called at the FI_EXECUTE and FI_ACCEPT.


  Forms		

	SMStructSurf	(taken as ME.VDCmdAttMgr->form_att_ptr for the display 
			of the attributes , as ME.VDCmdPart->form_sel_part
			for the search in the datatbase.

	

 -------------------------------------------------------------------------

-cmd*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "go.h"
#include "igrdp.h"
#include "OMmacros.h"

#include "UOMdef.h"
#include "growner.h"
#include "coparamac.h"
#include "asmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VDScheckdef.h"
#include "ACdb_info.h"
#include "VDSutil.h"
#include "PDUerror.h"

#include "dp.h"
#include "dpmacros.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"
#include "FI.h"

#include "vdsmacros.h"
#include "SMdef.h"
#include "SMmacros.h"
#include "SMCompForm.h"
#include "SMmsg.h"
#include "SMStructSf.h"
#include "VDmem.h"

/*+v
 -------------------------------------------------------------------------
*/
instance
{
  struct GRid 	  	surf_id;
  	/* Id of the working surface : if modify it's the current surface */
  	/* If place it's NULL_OBJID if never save and last save surface   */
      
  struct GRid     	sel_surf;      /* Current surface hilited (other half */
				       /* hilited) 			      */
  struct GRmd_env 	surf_env; 
  char   	  	old_name[ATTR_TXT];  /* Name of surface just placed   */

  struct ACrg_coll 	work_att[SM_MAX_CO_ATTR];
  IGRshort         	work_att_type[SM_MAX_CO_ATTR];
  int              	work_nb_att;

  struct part_attr      dyn_att;       /* Dynamic attributes for all parts */


  IGRchar               save_unit[80]; /* Current distance unit    */
  variable short        gadg_dist[1];  /* Array of gadget number   */
                                       /* to convert at wakeup     */
  variable short        gadg_area[1];  /* Same for area gadgets    */
  variable short        gadg_vol[1];   /* Same for volumes gadgets */

}
/*
 -------------------------------------------------------------------------
-v*/

/*---------------------
 * implementation area
 */

implementation

#include "UOMmacros.h"
#include "SMcomp_def.h" /* Constante for display */
#include "AS_status.h"
#include "vdbmacros.h"

#define AS_DEBUG	1

%safe
  static int x_pos = -1,y_pos = -1;
%endsafe

from SMmgr import SMGetAttTxt;
extern int VD_PDU_present;

/*---------------------
 * state table area
 */

state_table

#define TRUE  1
#define FALSE 0

#include "SMStructSf.h"
#include "SMmsg.h"
#include "VDSFilter.h"

state start
  on CMD_TYPE = PLACE 
         do message_key SM_M_CmSurfPl
         do init_db
            on RETURN_CODE = ONLY_ONE_PART
               do init_form_new_surf
                 on ERROR state terminate
               do control_form_state 
               state form_modify 
            on ERROR state terminate
         do chg_state_db(&me->ret,FALSE)
         do empty_form_state
         do control_form_state
         state form_modify
  on CMD_TYPE = MODIFY
         do message_key SM_M_CmSurfMd
         do empty_form_state
         do control_form_state
         state locate_main_surface

state locate_main_surface
prompt_key   SM_P_CmLocSurf
accept_key   SM_P_PlAccRej
locate_mask "GRm_DATA | GRm_TEXT_VALUE"
locate_eligible "SMMainSf"
locate_owner     "LC_RIGID_COMP | LC_RIGID_OWNER |
                  LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
filter vds_locate

  on EX_DATA or EX_STRING or EX_OBJID
   do locate_main_surf
        on ERROR state .
   do erase_hilite
   do hilite_half
   do chg_state_locate(&me->ret,TRUE)
   do empty_form_state  
   do control_form_state
   state form_modify
  

state locate_surf
prompt_key   SM_P_CmLocSurf
accept_key   SM_P_PlAccRej
locate_mask "GRm_DATA | GRm_OBJID | GRm_RESET | GRm_TEXT_VALUE | GRm_BACK_UP"
locate_class "EMSsurface"
locate_owner  "LC_RIGID_COMP | LC_RIGID_OWNER |
               LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
filter vds_locate
 
  on EX_DATA or EX_STRING or EX_OBJID
    do add_locate_surface
       on RETURN_CODE = NO_OBJ_LOCATED do status_key SM_E_CmNoLocSurf state .
    do chg_state_locate(&me->ret,TRUE)
    state form_surf
  on EX_BACK_UP
    do chg_state_locate(&me->ret,TRUE)
    state form_surf

state form_modify
display_form  0
  on CMD_TYPE = PLACE
   do message_key  SM_M_CmSurfPl state form_surf
  on CMD_TYPE = MODIFY
   do message_key   SM_M_CmSurfMd state form_surf

state form_surf
prompt_key    SM_P_CmFrMod
filter	get_event

   on GR_UNKNOWN_TYPE.READ_FROM_PDU
           do VDReadFromPdu
               on ERROR state terminate
           do erase_hilite
           do init_form_new_surf 
               on ERROR state terminate
           do chg_state_db(&me->ret,TRUE)
           do empty_form_state 
           do control_form_state
           state .

  on GR_UNKNOWN_TYPE.BEGIN_DATA_SEL
           do chg_state_select_db(&me->ret,FALSE)
           do control_form_state
           do VDLoadDbAttr
              on ERROR state terminate
           state .

  on GR_UNKNOWN_TYPE.LOAD_DATA_SEL
           do VDLoadSelPart
             on ERROR state .
           do erase_hilite
           do init_form_new_surf 
               on ERROR state terminate
           do chg_state_select_db(&me->ret,TRUE)
           do empty_form_state 
           do control_form_state
           state .
 
  on GR_UNKNOWN_TYPE.BEGIN_ATTR_FORM  do control_form_state
                                      do put_list_attr
                                      state .

  on GR_UNKNOWN_TYPE.LOCATE_SURF   do control_form_state
                                      on ERROR state .
                                   do chg_state_locate(&me->ret,FALSE)
                                   state locate_surf

  on GR_UNKNOWN_TYPE.BEGIN_GEOM_FORM  do control_form_state
                                      state .
 
  on GR_UNKNOWN_TYPE.RELOCATE_OBJ
       on CMD_TYPE = MODIFY 
              do erase_hilite
              do chg_state_locate(&me->ret,FALSE)
              do empty_form_state
              do control_form_state
              state locate_main_surface
       state .

at init   do init_all
          do control_login
          do form_position
at wakeup do hilite_half
          do control_unit
at sleep  do erase_hilite
at delete do delete_all

/*********************************************************************/

action form_notification extern

action init_form_new_surf extern

action control_main_surf extern

action reset_all extern

action save_all extern

action add_locate_surface extern

action put_surf_att_in_form extern

action put_geom_info extern



/*+me
 -------------------------------------------------------------------------
  Public Message hilite_half

  Abstract
	Semi hilite all stored volumes, hilte the selected one if there
	is one (me->sel_vol).


  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

action hilite_half
{
  long msg;

  *sts = OM_S_SUCCESS;

  if(me->sel_surf.objid != NULL_OBJID)
    dp$display(msg = &msg, oids = &me->sel_surf, mode = GRhhd);

  *sts = MSSUCC;
  status = OM_S_SUCCESS;
  goto quit;

} 

/*+me
 -------------------------------------------------------------------------
  Public Message chg_state_locate

  Abstract
	Disable or enable all gadget but FI_CANCEL (Usefull for locate)
	depending on the argument state.

  Arguments
	long		*sts	O 	completion code.
	IGRboolean	state	I	1 = enable ,0 = disable

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/
action chg_state_locate(long *sts ; IGRboolean state)
{
  IGRlong msg;

  *sts = OM_S_SUCCESS;

  om$send(msg = message SMCmdStrSf.chg_state_db(sts,state),
	  targetid = my_id);
 
  if(state)
   {
     SMVA_enable(me->forms[0].form_ptr,2,G_READ_PDU,G_DATA_SEL);
     FIg_set_state_off(me->forms[0].form_ptr,G_LOCATE_SURF);
   }
  else
   {
     SMVA_disable(me->forms[0].form_ptr,2,G_READ_PDU,G_DATA_SEL);
   }
   *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   goto quit;
}


/*+me
 -------------------------------------------------------------------------
  Public Message locate_main_surf

  Abstract
	Store the located object in me->surf_id then fills the instances
	with the info and displays all parameters in the form.

  Arguments
	long		*sts	O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/


action locate_main_surf
{

  *sts = OM_S_SUCCESS;

  me->surf_id = me->event1.located_object[0].located_obj;
  om$send(msg = message SMCmdStrSf.control_main_surf(sts),
	  targetid = my_id);
  if(!(*sts & 1)) goto wrapup;

  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  goto quit;

 wrapup:
  *sts = OM_E_ABORT;
  return OM_S_SUCCESS;
}




/*+me
 -------------------------------------------------------------------------
  Public Message read_pdu_review

  Abstract
	read the part from pdu ,verify if it has already been placed and 
	store me->db_info.catalog.

  Arguments
	long	*sts		O 	completion code.
	char	*rev_partid	O	retrieved part name
	char	*rev_revision	O	retrieved part rev


  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

action read_pdu_review(long *sts;char *rev_partid;char *rev_revision)
{
  char catalog[15];

  *sts = OM_S_SUCCESS;

  /* don't call this function with me->db_info.catalog, because it erases it*/

  if(!SMReadCompPduReview (SM_SRF, catalog,rev_partid,rev_revision))
   {
     *sts = OM_E_ABORT;
     goto quit;
   }

  strcpy(me->db_info.catalog, catalog);
  *sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message control_login

  Abstract

	Verify if the user is logged into the database ,erase some gadgets if 
	needed and set the me->db_info.catalog.

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

action control_login
{

  *sts = OM_S_SUCCESS;

  om$send(msg = message VDS_LOCATE.VDVerifyLogin(sts),
	  targetid = my_id,
	  mode = OM_e_wrt_message);
  if (!(*sts & 1))
   {
     me->state = _terminate;
     *sts = OM_E_ABORT;
     return OM_I_STOP_SENDING;
   }
  if(!VD_PDU_present)
    FIg_delete(me->forms[0].form_ptr,G_READ_PDU);

  strcpy(me->db_info.catalog,"surface"); 
     
  me->db_info.quantity = SURFACE_OBJ;

  *sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message put_list_attr

  Abstract
	Put the correct list of attributes in the field and display it.
	

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

action put_list_attr
{
  IGRint        type;

  *sts = OM_S_SUCCESS;

  SMStopSingleSelectMode(me->forms[0].form_ptr,G_ATT_LIST,NUM_COL_ATT,
                         FI_APPEND,FI_APPEND, FI_APPEND);

  SMVA_enable(me->forms[0].form_ptr,5,G_ATT_LIST,G_DEL_ATT,
              FI_RESET,FI_ACCEPT,FI_EXECUTE);

  type = me->form_state == DYN_LIST ? 1 : 0;

  om$send(msg = message SMCmdStrSf.VDSetRgAtt(sts),
	     targetid = my_id);

  om$send(msg = message SMCmdStrSf.VDSetAttList(sts, type),targetid = my_id);

  FIg_display(me->forms[0].form_ptr,G_ATT_LIST);

  FIg_set_state(me->forms[0].form_ptr,G_STATIC_TOG,
                me->form_state == DYN_LIST ? TRUE : FALSE);

  FIg_set_state_off(me->forms[0].form_ptr,G_DEL_ATT);

  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  goto quit;

}

/*+me
 -------------------------------------------------------------------------
  Public Message control_unit

  Abstract
	
	Get the current unit, and verify that all the info are in that unit.
	Update these attributes if needed.

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

action control_unit
{
  int     i; 
  IGRlong msg;
  char    tmp[80];
  double  val_db,coef,vol_coef,area_coef;
  char    cur_unit[40];
  short   flag = 1, num_defaults = 1;
  GRIOalias_name alias_name[UOM_K_MAX_DEFS];

  *sts = OM_S_SUCCESS;

  /* Get default unit for distance */
  status = uom$get_default_units(msg           = &msg,
				 table_name    = GRIO_DISTANCE,
				 flag          = &flag,
				 num_defaults  = &num_defaults,
				 default_units = alias_name,
                                 osnum         = me->ModuleInfo.md_id.osnum);
  if(status & 1) strcpy(cur_unit,alias_name[0]);
  else uom$report_error(msg = status);

  if(me->save_unit[0] == '\0')
   {
     strcpy(me->save_unit,cur_unit);
     FIg_set_text(me->forms[0].form_ptr,G_UNIT,cur_unit);
     FIfld_set_default_text(me->forms[0].form_ptr,G_UNIT,0,0,cur_unit,0);
     goto quit;
   }

  /* If unit change during wakeup, change current unit and recompute value */
  if(strcmp(me->save_unit,cur_unit))
   {
     FIg_set_text(me->forms[0].form_ptr,G_UNIT,cur_unit);
     FIfld_set_default_text(me->forms[0].form_ptr,G_UNIT,0,0,cur_unit,0);

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

     area_coef = coef * coef;
     vol_coef  = area_coef * coef;

     i = 0;
     while(me->gadg_dist[i] != 0)
      {
	tmp[0] = '\0';
	FIg_get_text(me->forms[0].form_ptr,me->gadg_dist[i],tmp);
	if(tmp[0] != '\0')
	 {
	   FIg_get_value(me->forms[0].form_ptr,me->gadg_dist[i],&val_db);
	   val_db = val_db * coef;
	   FIg_set_value(me->forms[0].form_ptr,me->gadg_dist[i],val_db);
	 }
	i++;
      }

     i = 0;
     while(me->gadg_area[i] != 0)
      {
	tmp[0] = '\0';
	FIg_get_text(me->forms[0].form_ptr,me->gadg_area[i],tmp);
	if(tmp[0] != '\0')
	 {
	   FIg_get_value(me->forms[0].form_ptr,me->gadg_area[i],&val_db);
	   val_db = val_db * area_coef;
	   FIg_set_value(me->forms[0].form_ptr,me->gadg_area[i],val_db);
	 }
	i++;
      }

     i = 0;
     while(me->gadg_vol[i] != 0)
      {
	tmp[0] = '\0';
	FIg_get_text(me->forms[0].form_ptr,me->gadg_vol[i],tmp);
	if(tmp[0] != '\0')
	 {
	   FIg_get_value(me->forms[0].form_ptr,me->gadg_vol[i],&val_db);
	   val_db = val_db * vol_coef;
	   FIg_set_value(me->forms[0].form_ptr,me->gadg_vol[i],val_db);
	 }
	i++;
      }

     strcpy(me->save_unit,cur_unit);
   }

   status = OM_S_SUCCESS;
   goto quit;

}

/*+me
 -------------------------------------------------------------------------
  Public Message empty_form_state

  Abstract
	Set me->form_state and me->old_form_state to EMPTY_STATE.

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

action empty_form_state 
{
  *sts = OM_S_SUCCESS;

  me->old_form_state = me->form_state = EMPTY_STATE; 

  status = OM_S_SUCCESS;
  goto quit;

}



/*+me
 -------------------------------------------------------------------------
  Public Message chg_state_select_db

  Abstract
	enable or disable some gadgets
  Arguments
	long		*sts	O 	completion code.
	IGRboolean	state	I	1 = enable, else disable

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

action chg_state_select_db (long *sts; IGRboolean state)
{
  *sts = OM_S_SUCCESS;


  if(state)
   {
     if(me->save_nb_att != 0)  /* Some data have been loaded */
      {
	SMVA_enable(me->forms[0].form_ptr,3,FI_ACCEPT,FI_EXECUTE,FI_RESET);
      }
     else
       FIg_disable(me->forms[0].form_ptr,GROUP_SELECT);

     SMVA_enable(me->forms[0].form_ptr,2,G_READ_PDU,G_DATA_SEL);
     FIg_set_state_off(me->forms[0].form_ptr, G_DATA_SEL);
   }
  else
   {
     SMVA_disable(me->forms[0].form_ptr,2,G_READ_PDU,G_DATA_SEL);
     SMVA_disable(me->forms[0].form_ptr,2,FI_ACCEPT,FI_EXECUTE);
     FIg_enable(me->forms[0].form_ptr,FI_RESET);
   }

  status = OM_S_SUCCESS;
  goto quit;
}


/*+me
 -------------------------------------------------------------------------
  Public Message chg_state_db

  Abstract
	enable or disable GROUP_SELECT gadgets
  Arguments
	long		*sts	O 	completion code.
	IGRboolean	state	I	1 = enable, else disable

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

action chg_state_db ( long *sts ; IGRboolean state)
{

  *sts = OM_S_SUCCESS;

  if(state)
   {
/*     FIg_enable(me->forms[0].form_ptr,GROUP_MAIN); */
     FIg_enable(me->forms[0].form_ptr,GROUP_SELECT);
     
     SMVA_enable(me->forms[0].form_ptr,3,
		 FI_ACCEPT,FI_EXECUTE,FI_RESET);
     FIg_set_state_off(me->forms[0].form_ptr, G_READ_PDU);
     FIg_set_state_off(me->forms[0].form_ptr, G_DATA_SEL);
   }
  else
   {
/*   Next line supress due to a bug in forms : enable a list associated */
 /*   to field doesnt't work when the list is not displayed */

/*   FIg_disable(me->forms[0].form_ptr,GROUP_MAIN);  */

     FIg_disable(me->forms[0].form_ptr,GROUP_SELECT);
     SMVA_disable(me->forms[0].form_ptr,3,
		  FI_ACCEPT,FI_EXECUTE,FI_RESET);
   }

  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  goto quit;

}



/*+me
 -------------------------------------------------------------------------
  Public Message disp_attr_gadgets

  Abstract
	display or erase the gadgets for the attributes.

  Arguments
	long		*sts	O 	completion code.
	IGRboolean	state	I	1 = display, else erase

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/
 
action disp_attr_gadgets (long *sts;  IGRboolean state)
{

  long mask;
  *sts = OM_S_SUCCESS;


    om$send(msg = message SMCmdStrSf.VDDspGrpGadg(sts,me->forms[0].form_ptr, 
                                                        GROUP_ATT, state),
	    targetid = my_id);

  if(state)
   {
     FImcf_get_attr(me->forms[0].form_ptr,G_ATT_LIST,&mask);
     FImcf_set_attr(me->forms[0].form_ptr,G_ATT_LIST,
		    mask | FI_DISPLAY_VSCROLL);
   }
  else
   {
     /* Display scroll bar of precedeing gadget cause problem, erase them */
     FImcf_get_attr(me->forms[0].form_ptr,G_ATT_LIST,&mask);
     if(mask & FI_DISPLAY_VSCROLL)
       FImcf_set_attr(me->forms[0].form_ptr,G_ATT_LIST,
		      mask ^ FI_DISPLAY_VSCROLL);
   }
  
  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  goto quit;

}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	init_all from VDS_LOCATE

  Abstract
	That method initialise the instances.
	It has been overriden in order to initialise my instances.
	
  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

action init_all
{
  *sts = OM_S_SUCCESS;

  om$send(msg = message VDCmdPart.init_all(sts),
	  targetid = my_id,
	  mode     = OM_e_wrt_message);	
  if(!(*sts & 1)) goto quit;

  om$send(msg = message VDCmdAttMgr.init_all(sts),
          targetid = my_id,
          mode     = OM_e_wrt_message);

  /* init VDCmdAttMgr instances */

  me->form_sel_part = me->form_att_ptr = me->forms[0].form_ptr;

  me->GadgToggle =  G_STATIC_TOG;
  me->StatDynFld =  G_ATT_LIST;

  /* init VDCmdPart instances */

  me->g_part_grp    = GROUP_DB;
  me->g_db_list     = G_DB_LIST;
  me->g_search      = G_SEARCH;
  me->g_reset       = G_RESET;
  me->g_plus        = G_PLUS;
  me->g_minus       = G_MINUS;
  me->g_num_part    = G_NUM_PART;
  
  /* Jean 28 June 93 Gener default name for surface */
  if(me->mytype == PLACE)    
    GetDefName("SMMainSurf_0",me->old_name);
  else
    me->old_name[0] = '\0';

  *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   goto quit;
}


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	delete_all from VDS_LOCATE

  Abstract
	That method is called at the delete of the command. It basically
	free all the allocated arrays.

	It has been overriden to free my own instances.

  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/


action delete_all
{
  *sts = OM_S_SUCCESS;

  om$send(msg = message VDCmdPart.delete_all(sts),
	  targetid = my_id,
	  mode     = OM_e_wrt_message);

  om$send(msg = message VDCmdAttMgr.delete_all(sts),
          targetid = my_id,
          mode     = OM_e_wrt_message);

  if(me->forms[0].form_ptr)
    FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);

  *sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;
  goto quit;

}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	form_position from VDS_LOCATE

  Abstract
	That method displays the forms in the right position.
	It has been overriden to keep the previous form position, and change
	the title of the form depending on me_>mytype.
	It also read the tightness file, read the setup file.

  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

action form_position
{
  int   xmain,ymain,i;
  static char *surf_type[] = {"deck","l bulk","t bulk","hull","other",NULL};

  *sts = OM_S_SUCCESS;

  me->save_nb_att = 0;

  if(x_pos == -1 || y_pos == -1)
     FIf_get_location(me->forms[0].form_ptr,&xmain,&ymain);
  else 
    {xmain = x_pos; ymain = y_pos;}
  
  FIf_set_location(me->forms[0].form_ptr,xmain,ymain);
  FIgrp_set_pass_on(me->forms[0].form_ptr,GROUP_SELECT);
  FIg_display(me->forms[0].form_ptr,GROUP_SELECT);
 
  if(me->mytype == MODIFY)
   {
     FIg_delete(me->forms[0].form_ptr, G_DATA_SEL);
     FIg_delete(me->forms[0].form_ptr, G_READ_PDU);
   }
  
  /* Put surf type in list */
  i = 0;
  while(surf_type[i])
   {
     VDfld_set_list_text(me->forms[0].form_ptr,G_TYPE,i,0,
			 surf_type[i],0);
     FIfld_set_list_default_text(me->forms[0].form_ptr,G_TYPE, i,0,
				 surf_type[i],0);
     i++;
   }

  om$send(msg = message VDS_LOCATE.VDReadFileAttr(sts,TIGHTNESS_FILE,me->forms[0].form_ptr,G_TIGHTNESS),
	  targetid = my_id);
  if(!(*sts & 1))
    {*sts = OM_E_ABORT; return OM_I_STOP_SENDING;}

  /* Init save_unit to 0 */
  me->save_unit[0] = '\0';

  /* Init number of gadgets to gadget to convert at wakeup */
  om$vla_set_dimension(varray = me->gadg_dist,size = 4);
  om$vla_set_dimension(varray = me->gadg_area,size = 2);

  me->gadg_dist[0] = G_COG_X; me->gadg_dist[1] = G_COG_Y;
  me->gadg_dist[2] = G_COG_Z; me->gadg_dist[3] = 0;
    
  me->gadg_area[0] = G_AREA; me->gadg_area[1] = 0;
  me->gadg_vol[0] = 0;

  *sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;
  goto quit;
       
}


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	control_form_state from VDS_LOCATE

  Abstract
	That method displays or erases some gadget depending on the
	state of the form (me->form_state).

  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

action control_form_state
{
  IGRboolean attr_gadgets = FALSE,
             geom_gadgets = FALSE,
             db_gadgets   = FALSE,
             main_gadgets = TRUE,
             sel_gadgets  = TRUE;

  char  my_msg[80];
  *sts = OM_S_SUCCESS;


  /* Save dynamic list if it was previously displayed */
  /* If error return to dynamic list */

  if(me->old_form_state == DYN_LIST && me->form_state != DYN_LIST)
   {
     om$send(msg = message SMCmdStrSf.VDSaveListDyn(sts, my_msg),targetid = my_id);
     if(!(*sts & 1))
      {
	me->form_state = DYN_LIST;
	FIg_set_state_on(me->forms[0].form_ptr,G_USER_ATT);
	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
	*sts = OM_E_ABORT;
	goto quit;
      }
   }

  switch(me->form_state)
   {
   case STAT_LIST: case DYN_LIST:
     attr_gadgets = TRUE;  break;
     
   case GEOM_INFO:
     geom_gadgets = TRUE;  break;

   case DB_SELECT:
      db_gadgets = TRUE;  sel_gadgets = FALSE; main_gadgets = FALSE; break;
     
   case EMPTY_STATE:
     break;
   }

  /* First erase than display */
  if(!attr_gadgets)
    om$send(msg = message SMCmdStrSf.disp_attr_gadgets(sts,FALSE),
	    targetid = my_id);
  if(!geom_gadgets)
     om$send(msg = message SMCmdStrSf.VDDspGrpGadg(sts,me->forms[0].form_ptr, 
                                                            GROUP_GEOM, FALSE),
	     targetid = my_id);

  if(!db_gadgets)
    om$send(msg = message SMCmdStrSf.VDDspGrpGadg(sts,me->forms[0].form_ptr, 
                                                        GROUP_DB, FALSE),
	    targetid = my_id);

  if(!sel_gadgets)
    FIg_erase(me->forms[0].form_ptr,GROUP_SELECT);
  if(!main_gadgets)
    FIg_erase(me->forms[0].form_ptr,GROUP_MAIN);

  if(attr_gadgets)
    om$send(msg = message SMCmdStrSf.disp_attr_gadgets(sts,TRUE),
	    targetid = my_id);
  if(geom_gadgets)
    om$send(msg = message SMCmdStrSf.VDDspGrpGadg(sts,me->forms[0].form_ptr, 
                                                        GROUP_GEOM, TRUE),
	    targetid = my_id);

  if(db_gadgets)
    om$send(msg = message SMCmdStrSf.VDDspGrpGadg(sts,me->forms[0].form_ptr, 
                                                        GROUP_DB, TRUE),
	    targetid = my_id);
  if(sel_gadgets)
    FIg_display(me->forms[0].form_ptr,GROUP_SELECT);
  if(main_gadgets)
    FIg_display(me->forms[0].form_ptr,GROUP_MAIN);

  FIg_set_state(me->forms[0].form_ptr,G_USER_ATT,attr_gadgets);
  FIg_set_state(me->forms[0].form_ptr,G_GEOM_INFO,geom_gadgets);
  FIg_set_state(me->forms[0].form_ptr,G_DATA_SEL,db_gadgets);
  *sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;
  goto quit;

}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        VDLoadSelPart from VDCmdPart

  Abstract
	Loads the selected part and fills the db_info structure.
	It has been overriden to load me->save_att with the selected part.

  Algorithm
	send SMCoMianSf.fill_attr_from_part (fills me->save_att)

  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

action VDLoadSelPart
{

  char      my_msg[80];
  int       cur_index;

  *sts = OM_S_SUCCESS;

  /* Change Test Condition 6 June 93 */
  /* Verify if one selected part exists */
  if(me->nb_parts == 0 || me->parts == NULL || me->cur_part <= 0 ||
     me->cur_part > me->nb_parts)
   {
     ex$message( msgnumb = SM_E_CmNoPartSel, buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
     *sts = OM_E_ABORT; return OM_S_SUCCESS;
   }

  cur_index = me->cur_part - 1;
  me->save_nb_att = SM_MAX_CO_ATTR;

  om$send(msg = message SMCmdStrSf.fill_attr_from_part
          (sts,me->parts[cur_index].nb_att,me->parts[cur_index].att,
           me->dyn_att.nb_att,me->dyn_att.att),
          targetid = my_id);
  if(!(*sts & 1))
   { printf("Error copy attributes\n"); *sts = OM_E_ABORT; goto quit; }


  /* Information for checkin */
  strcpy(me->db_info.part_num,
         me->parts[cur_index].att[1].attr.desc.value.att_txt);
  strcpy(me->db_info.revision,
         me->parts[cur_index].att[2].attr.desc.value.att_txt);


  *sts = OM_S_SUCCESS;

   status = OM_S_SUCCESS;
   goto quit;


}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        fill_attr_from_part from VDCmdPart

  Abstract
        Parse the static and dynamic attributes into the structure me->save_att.
	Has been overriden because VDCmdPart only defines it.

  Algorithm
	SMCompDynColl

  Arguments
	long 		     *sts	O	Completion code
	int 		     nb_stat	I	number of static attributes
	struct VDSatt_family *stat_att	I	the static attributes
	int 		     nb_dyn	I	number of dynamic attributes
	struct VDSatt_family *dyn_att)  I	the dynamic attributes

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

action fill_attr_from_part
{
  static struct init_att NeedAtt[] = {
   {"name",AC_ATTRIB_TEXT,""},
  {"surftype",AC_ATTRIB_TEXT,"deck"},
  {"descript",AC_ATTRIB_TEXT,""},
  {"density",AC_ATTRIB_DOUBLE,"1.3"},
  {"tightness",AC_ATTRIB_TEXT,"watertight"},
  { NULL,0,NULL}};

  *sts = OM_S_SUCCESS;

  me->save_nb_att = SM_MAX_CO_ATTR;
  if(!SMParseDynColl(NeedAtt,nb_stat,stat_att,
		     nb_dyn ,dyn_att,
		     me->save_att, me->save_att_type, &me->save_nb_att))
   { printf("Error copy attributes\n"); *sts = OM_E_ABORT; goto quit; }

  /* Add attribute props */

  strcpy(me->save_att[me->save_nb_att].name,"props");
  me->save_att[me->save_nb_att].desc.type = AC_ATTRIB_DOUBLE;
  me->save_att[me->save_nb_att].desc.value.att_exp
    = SM_CMP_DSP_CMP_COG_PT | SM_CMP_DSP_CMP_COG_NAME ;
  me->save_nb_att++;

  /* Add attribute consumme (Default no) */

  strcpy(me->save_att[me->save_nb_att].name,"consume");
  me->save_att[me->save_nb_att].desc.type = AC_ATTRIB_DOUBLE;
  me->save_att[me->save_nb_att].desc.value.att_exp = 0.0; /* Not Consumme */
  me->save_nb_att++;						     

  *sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;
  goto quit;

}


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        VDReadFromPdu from VDCmdPart

  Abstract
	That method is called when the "Read Pdu Review" button is pushed.
	That reads the selected part from PDU and retrieves the attributes for
	that part, then it fills the attribute structures and me->db_info.

	It has been overriden because it was only a definition at 
	VDCmdPart level.

  Algorithm
	- SMCmdStrSf.read_pdu_review (retrieve the selected part in PDU)
	- VDSget_attr (retrieve the attributes for this part)
	- send SMCmdStrSf.fill_attr_from_part (fills me->save_att)
	- fill me->db_info

  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

action VDReadFromPdu
{

   char   rev_partid[100],rev_revision[81]; 
   struct VDSatt_family *stat_att = NULL,*dyn_att = NULL;
   int    nb_stat,nb_dyn;

    *sts = OM_S_SUCCESS;

   /* Retrieve selected part for pdu */
   om$send(msg = message SMCmdStrSf.read_pdu_review(sts,rev_partid,rev_revision),
	   targetid = my_id);
   if(!(*sts & 1)) { *sts = OM_E_ABORT; goto free_mem;}
   
   /* Number of allocate attribute */
   me->save_nb_att = SM_MAX_CO_ATTR;
   
   /* Retrieves attributes for this parts in database */
   if(!VDSget_attr(me->db_info.catalog,rev_partid,rev_revision,"",
		   &nb_stat,&stat_att,&nb_dyn,&dyn_att))
    { *sts = OM_E_ABORT; goto free_mem; }

     om$send(msg = message SMCmdStrSf.fill_attr_from_part
             (sts,nb_stat,stat_att,nb_dyn,dyn_att),
             targetid = my_id);
     if(!(*sts & 1))
      { printf("Error copy attributes\n"); *sts = OM_E_ABORT; goto free_mem; }


   strcpy(me->db_info.part_num,rev_partid);
   strcpy(me->db_info.revision,rev_revision);
   
   *sts = OM_S_SUCCESS; 

 free_mem:
   /* DEALLOC MEMORY */
   _FREE(stat_att) ;
   _FREE(dyn_att)  ;

   status = OM_S_SUCCESS;
   goto quit;

}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        VDLoadDbAttr from VDCmdPart

  Abstract
	Loads the static attribute (me->att_name) with the info from the 
	database in me->db_info.catalog and display them in me->g_db_list field.

	It has been overriden to modify the display of the form.

  Algorithm
	send VDCmdPart.VDLoadDbAttr
	enable gadget GROUP_SELECT

  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

action VDLoadDbAttr
{

  *sts = OM_S_SUCCESS;

  om$send(msg = message VDCmdPart.VDLoadDbAttr(sts),
             targetid = my_id,
             mode     = OM_e_wrt_message);

  FIg_enable(me->forms[0].form_ptr,GROUP_SELECT);

  *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   goto quit;


}
/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        VDSetRgAtt from VDCmdAttMgr

  Abstract
	Set the list of attributes into the instances.
	It has been overriden because we will not use the user attributes
	(They will be gathered with the dynamic).
  
  Algorithm
	- free the VDCmdAttMgr instances (static_att and dynamic_att)
	- For each attribute in me->work_att list, depending on its type
	add this attribute in me->static_att or me->dynamic_att.

  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

action VDSetRgAtt
{
  IGRshort 	to_static,to_dynamic;
  IGRint	i;

  *sts = OM_S_SUCCESS;

  _FREE(me->static_att) ;
  _FREE(me->dynamic_att) ;


  me->static_att = _MALLOC( me->work_nb_att, struct ACrg_coll);
  if(! me->static_att){ printf("Memory problem\n"); goto wrapup;}

  me->dynamic_att = _MALLOC( me->work_nb_att, struct ACrg_coll);
  if(! me->dynamic_att){ printf("Memory problem\n"); goto wrapup;}

  me->nb_static = me->nb_dynamic = 0;

  for(i=0; i < me->work_nb_att; i++)
   {
       to_static  = me->work_att_type[i] & ( SM_STATIC_ATT | SM_OTHER_ATT);

       if(to_static && (me->work_att_type[i] & SM_SYST_ATT)) 
	 to_static = 0;
       to_dynamic = (me->work_att_type[i] & SM_DYNAMIC_ATT)
	             &&  (me->work_att_type[i] & SM_USER_ATT);
	
       if(to_static){

		/* add the attribute in the static list */
		me->static_att[me->nb_static ++] = me->work_att[i];
	}
	else if (to_dynamic){

		/* add the attribute in the dynamic list */
		me->dynamic_att[me->nb_dynamic ++] = me->work_att[i];
	}
  }
   
   *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   goto quit;

 
  wrapup:
  _FREE(me->static_att) ;
  _FREE(me->dynamic_att) ;
  *sts = OM_E_ABORT;

}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        VDSaveListDyn from VDCmdAttMgr

  Abstract
	Save the dynamic and user attributes into the instances.

	It has been overriden to take into account the fact that the user
	attributes are displayed in the same field than the dynamic ones.
	and to fill my instances me->work_att.


  Arguments
	long 		     *sts	O	Completion code
	IGRchar		     *my_msg    O	Message info

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

action VDSaveListDyn
{

  unsigned char    name[ATTR_TXT],val_txt[ATTR_TXT],type_txt[ATTR_TXT];
  int              num_rows,row,i,sel,pos;
  IGRdouble        val_db;
  int              type,prec_type;
  IGRshort         sm_type;
  
/* Work with buffer to not corrupt if an error occured during saving */

  struct ACrg_coll buf_att[SM_MAX_CO_ATTR]; 
  IGRshort         buf_att_type[SM_MAX_CO_ATTR];
  int              buf_nb_att;

  *sts = OM_S_SUCCESS;

  my_message[0] = '\0';

  memcpy(buf_att,me->work_att, me->work_nb_att * sizeof(struct ACrg_coll));
  memcpy(buf_att_type,me->work_att_type, me->work_nb_att * sizeof(IGRshort));
  buf_nb_att =  me->work_nb_att;
    
  /* Retrieves the value of each attributes keyin in form */

  FIfld_get_num_rows(me->forms[0].form_ptr,G_ATT_LIST,&num_rows);
  
  for(row=0; row < num_rows; row++)
   {
     name[0] = val_txt[0] = type_txt[0] = '\0';
     
     FIfld_get_text(me->forms[0].form_ptr,G_ATT_LIST,row,GI_NAME,ATTR_TXT,
		    name,&sel,&pos);
     
     FIfld_get_text(me->forms[0].form_ptr,G_ATT_LIST,row,GI_VAL,ATTR_TXT,
		    val_txt,&sel,&pos);
     
     FIfld_get_text(me->forms[0].form_ptr,G_ATT_LIST,row,GI_TYPE,ATTR_TXT,
		    type_txt,&sel,&pos);
     name[ATTR_TXT - 1] = val_txt[ATTR_TXT - 1] = type_txt[ATTR_TXT - 1] = 0; 
     
     if(name[0] == '\0')
       if(val_txt[0] == '\0' && type_txt[0] == '\0') continue;
       else
	{
	  ex$message(msgnumb = SM_E_CmNeedAttName,buff = my_message,
		     type = "%d",var = `row`); 
	  *sts = OM_E_ABORT;
	  goto quit;
	}

     prec_type = 0;
     sm_type   = SM_USER_ATT | SM_DYNAMIC_ATT;

     /* Not allow to redefine a system attrib */
     if(SMGetAttr((char*)name,me->work_att,me->work_att_type,me->work_nb_att,
		  &prec_type,(IGRdouble *)NULL,(char *)NULL,&sm_type))
      {
	if(sm_type & SM_SYST_ATT) 
	 {
	   ex$message(msgnumb = SM_E_CmBadNameAttr, buff = my_message,
		      type = "%s",var = `name`); 
	  *sts = OM_E_ABORT;
	   goto quit;
	 }
      }

     switch(type_txt[0])
      {
      case 'd' : case 'D': type = AC_ATTRIB_DOUBLE; break;
      case 't' : case 'T': type = AC_ATTRIB_TEXT; break;
      default:
	ex$message(msgnumb = SM_E_CmBadAttType, buff = my_message,
		   type = "%s",var = `name`); 
	*sts = OM_E_ABORT;
	goto quit; 
      }
     
     /* Not allow to modify type of an attribute */
     if(prec_type != 0 && type != prec_type)
      {
	ex$message(msgnumb = SM_E_CmBadAttType, buff = my_message,
		   type = "%s",var = `name`); 
	*sts = OM_E_ABORT;
	goto quit;
      }

     if(type == AC_ATTRIB_DOUBLE &&
	!SMget_double(me->forms[0].form_ptr,G_ATT_LIST,row,GI_VAL,&val_db))
      {
	ex$message(msgnumb = SM_E_CmBadValAttr, buff = my_message,
		   type = "%s",var = `name`); 
	*sts = OM_E_ABORT;
	goto quit;
      }

     if(!SMSetAttr((char*)name, buf_att,buf_att_type,&buf_nb_att,
		   type, val_db, (char*)val_txt, sm_type, SM_MAX_CO_ATTR )){
  	*sts = OM_E_ABORT;
       	goto quit;
     }
   }

  /* For each user dynamic attributes , verify  if always existing */
  /* If not delete it */
  for(i = 0; i < me->work_nb_att; i++)
   {
     if(me->work_att_type[i] != (SM_USER_ATT | SM_DYNAMIC_ATT))
       continue;
     for(row=0; row < num_rows; row++)
      {
	FIfld_get_text(me->forms[0].form_ptr,G_ATT_LIST,row,GI_NAME,ATTR_TXT,
		       (unsigned char *)name,&sel,&pos);
	if(strcmp((char *)name,me->work_att[i].name) == 0) break;
      }
     if(row == num_rows) /* Attribute no longer exists */
       del_one_attrib(buf_att,buf_att_type,&buf_nb_att,me->work_att[i].name);
   }

  memcpy(me->work_att, buf_att, buf_nb_att  * sizeof(struct ACrg_coll));
  memcpy(me->work_att_type, buf_att_type, buf_nb_att * sizeof(IGRshort));
  me->work_nb_att = buf_nb_att;
  

  *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   goto quit;

}



/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        VDSelectTog from VDCmdAttMgr

  Abstract
	Displays in the right field either the dynamic or static attributes 
        depending on the toggle state.

	It has been overriden in order to set the instances of VDCmdAttMgr
	with my instances.
	If the dynamic attributes are displayed and the user asks for the
	display of the static ones, the dynamic are saved.

  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

action VDSelectTog
{

  IGRint state, type;
  char   my_msg[80];

  *sts = OM_S_SUCCESS;
  
  FIg_get_state(me->forms[0].form_ptr,G_STATIC_TOG,&state);

  /* state = FALSE means STATIC ; state = TRUE means dynamic */

  me->form_state = state ?  DYN_LIST : STAT_LIST;
  type = me->form_state == DYN_LIST ? 1 : 0;
  
  if(me->old_form_state == DYN_LIST && me->form_state == STAT_LIST)
   {
     om$send(msg = message SMCmdStrSf.VDSaveListDyn(sts, my_msg),
	     targetid = my_id);
     /* If fails redisplay  dynamic attributes */
     if(!(*sts & 1))
      {
	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
	FIg_set_state_off(me->forms[0].form_ptr,G_STATIC_TOG);
	me->form_state = DYN_LIST;
	goto quit;
      }
   }
 
  if(me->form_state == DYN_LIST)
    FIg_enable(me->forms[0].form_ptr,G_DEL_ATT);
  else
    FIg_disable(me->forms[0].form_ptr,G_DEL_ATT);
  FIg_set_state_off(me->forms[0].form_ptr,G_DEL_ATT);

  om$send(msg = message SMCmdStrSf.VDSetRgAtt(sts),
	     targetid = my_id);

  om$send(msg = message SMCmdStrSf.VDSetAttList(sts, type),targetid = my_id);
  
  FIg_display(me->forms[0].form_ptr,G_ATT_LIST);


  *sts = OM_S_SUCCESS;

   status = OM_S_SUCCESS;
   goto quit;
}


