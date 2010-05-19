/* $Id: SMCmdComp.sl,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */

/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:	SMcomp/SMCmdComp.sl
 *
 * Description:	
 *
 *	This command implements the compartment and hull compartment
 *	creation and modification.
 *
 * Dependencies:
 *	VDCmdAttMgr	Management of the attributes in the form
 *	VDCmdPart	Management of the part selection in the form
 *
 * Revision History:
 *	$Log: SMCmdComp.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/03/05  05:58:50  pinnacle
# Replaced: smcomp/cmd/SMCmdComp.sl for:  by ssranade for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/01/27  18:28:44  pinnacle
# Replaced: smcomp/cmd/SMCmdComp.sl for:  by impd for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.8  1997/03/24  06:53:16  pinnacle
# Replaced: smcomp/cmd/SMCmdComp.sl for:  by ksundar for vds.241
#
# Revision 1.7  1997/02/20  09:18:16  pinnacle
# Replaced: smcomp/cmd/SMCmdComp.sl for:  by ksundar for vds.241
#
# Revision 1.6  1996/11/05  21:52:24  pinnacle
# Replaced: smcomp/cmd/SMCmdComp.sl for: fix for deleting volumes when S2150 button is selected: Rishad  by msmanem for vds.241
#
# Revision 1.5  1996/10/25  14:19:22  pinnacle
# Incorporated fix for TR#179603298.
#
# Revision 1.4  1996/10/06  04:31:18  pinnacle
# Replaced: smcomp/cmd/SMCmdComp.sl for:  by msmanem for vds.241
#
# Revision 1.2  1996/03/09  17:10:30  pinnacle
# Replaced: smcomp/cmd/SMCmdComp.sl for:  by msmanem for pmevds
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	08/01/92	Jean Jasinczuk: 	Creation Date.
 *	10/01 92	JJ: Modif to integrate the user attributes 
 *      12/01/92 	JJ: Take attributes in database
 *	02/01/93 	JJ: A super command object SMCoDb have been made
 *	04/01/93 	JJ: Add compart tracking
 *	04/01/93 	JJ: Recompile for 2.2
 *	08/01/93 	JJ: Update to work with collection and cache.
 *	05/01/94	P. Lacroix :	Subclass SMCmdComp from VDCmdAttMgr
 *			and VDCmdPart instead of SMCoDb that has been removed.
 *	09/18/96	msm. Fix TR #179603074
 *	10/03/96	msm. Copied code from VDCmdPart.VDLoadDbAttr
 *	01/27/98	No conversion of expected_vol & expected_area.
 *	5 Mar 99	Rajendra	TR#179802545 Hide PME button if
 *					connected to SIR
 * -------------------------------------------------------------------------
 */


command_string       SMC_M_CmPl,0,SMPlCm
synonym              SMC_M_CmMd,1,SMMdCm
synonym              SMC_M_CmPlHull,2,SMPlHlCm
synonym              SMC_M_CmMdHull,3,SMMdHlCm
class                SMCmdComp
command_table        "sman.cmd"
super_class          VDCmdPart
super_class          VDCmdAttMgr
product_name        "$VDS"

form "SMComp.O",0,0,"-1","-1"
form "SMComp",1,0,"-1","-1"

/*---------------------
 * specification area
 */

specification

/*+cmd
/* -------------------------------------------------------------------------

  Command Object Class SMCmdComp

  Superclass
	VDCmdAttMgr, VDCmdPart

  Abstract
 	This command implements the compartment and hull compartment
 	creation and modification.


  Methods

     hilite_half	Public		Semi hilite all stored volumes.

     chg_state_locate	Public		Disable all gadget but FI_CANCEL. 
					Usefull for locate.

     locate_comp	Public		Store the located compart and control
					its parameters.

     load_list		Public		Load the lists of dead weight, group 
					and sub group and verify if global 
					data are defined.                    

     read_pdu_review	Public		read the part from pdu ,verify if
					it has already been placed and store
					me->db_info.catalog.

     check_already_placed Public	Check if the given part is already in 
					the dsgn list (compart in current 
					design) or in the list from the
					database (compart placed by checkin).

     control_login	Public		Verify if the user is logged into the 
					database ,erase some gadgets if needed
					and set the me->db_info.catalog.

     realloc_dsgn_list	Public		Realloc if necessary dsgn list.

     add_dsgn_list	Public		Alloc memory and add a part in dsgn list

     construct_dsgn_list Public		Construct the list of family, partnum, 
					prtrev already placed for compartments.

     put_list_attr	Public		Put the correct list of attributes in
					the field and display it.

     control_unit	Public		Get the current unit, and verify that
					all the info are in that unit.

     empty_form_state 	Public		Set me->form_state and 
					me->old_form_state to EMPTY_STATE.

     chg_state_select_db Public		enable or disable some gadgets.

     chg_state_select_pme Public	enable or disable some gadgets for PME
					option.

     chg_state_db	Public		enable or disable the GROUP_SELECT 
					gadgets.

     disp_attr_gadgets	Public		display or erase the gadgets for the
					attributes.



     init_form_new_comp	Public		Initialise the form for a new compart.

     control_comp	Public		display all parameters for the located
					compart and fills the instances with 
					the info.

     SMplace_comp	Public		Construct and place the compart macro

     SMmodif_comp	Public		Modify the compart macro with the 
					parameters saved in the form.

     put_disp_att_in_form Public	Retrieve the display attributes and
					put them in the form.

     put_list_vol	Public		Put The list of the volumes in the form.

     add_locate_volume	Public		Store the located volume and add it 
					in the form.

     select_delete_volume Public	Select the volume to delete.

     put_comp_att_in_form Public	Retrieve main parameters for a compart 
					and display them in form.

     put_geom_info	Public		Get all geometrical info from 
					me->work_att and put them in the form.

     SMChgListVol 	Public		Change the list of volumes when modify.



  Overridden Methods

     init_all			initialise the instances.

     delete_all			free the allocated instances.

     form_position		displays the forms in the right position.

     control_form_state		displays the form depending on its state.

     delete_row                 perform the delete of a row in the a gadget
                                field.

     VDPlaceDbAttInList		Displays the list of attributes of the current
				part.

     VDLoadSelPart		loads the selected part and set the db_info
				structure.

     fill_attr_from_part	parse the static and dynamic attributes to fill
				the me->save_att structure.

     VDReadFromPdu		Read the selected part from PDU, retrieve the
				attributes for that part and fills me->save_att
				structure.

     VDQueryDb			Queries the database for all parts corresponding
				to the select criteria (fills me->parts).

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

     SMqueryCompartments	Query the PME database for unplace Compartments.

  Forms		

	VDEqMain
	VDEqPopup
	ASPlSymb


 -------------------------------------------------------------------------

-cmd*/

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

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

#include "dp.h"
#include "dpmacros.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VDScheckdef.h"
#include "ACdb_info.h"
#include "VDSutil.h"
#include "PDUerror.h"

#include "FI.h"

#include "vdsmacros.h"
#include "SMdef.h"
#include "SMmacros.h"
#include "SMmsg.h"
#include "VDmsg.h"

#include "SMcomp_def.h"
#include "SMCompForm.h"

#include "VDmem.h"
#include "VDPdef.h"
#include "VDPzone.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"


/*+v
 -------------------------------------------------------------------------
*/
instance
{

  struct GRid 		comp_id;
  	/* Id of the working compartment : if modify it's the current 
  	/* compart. If place it's NULL_OBJID if never save and last 
	/* save volume.
	/* */

      
  struct Comp_Volume 	save_vol[SM_MAX_ALLOW_VOL]; 
  struct Comp_Volume 	work_vol[SM_MAX_ALLOW_VOL];
          /* Buffer list of the volumes (temporary save when form displayed)*/ 


  int 			save_nb_vol;
  int			work_nb_vol; 	    /* Number of assigned volume      */
  struct Disp_Opt 	disp;       	    /* Display option for the compart */
  char   		old_name[ATTR_TXT]; /* Name of the placed compartment */
  

  IGRboolean 		state_del;    
	/* If TRUE, the user is selecting volume to del */
 

  struct GRid 		sel_vol;  
	/* Current volumes hilited (other half hilited) */


  IGRboolean 		compart_track; 
	/* TRUE if compart tracking wish by user */  

	
  IGRboolean 		all_defined; 
	/* TRUE if dead weight, group, global data exists */



  IGRint 		nb_alloc_dsgn;  /* Memory allocated for two next list */
  IGRint 		nb_parts_dsgn;  /* Number of part already placed in   */
					/* design file 			      */
  char   		**family_dsgn;  /* List of family name in design file */
  char   		**partnum_dsgn; /* List of partnum in design file     */
  char   		**partrev_dsgn; /* List of partrev in design file     */



  struct ACrg_coll 	work_att[SM_MAX_CO_ATTR];
  IGRshort         	work_att_type[SM_MAX_CO_ATTR];
  int              	work_nb_att;

  struct part_attr 	dyn_att;       /* Dynamic attributes for all parts */


  IGRchar 		save_unit[80]; /* Current distance unit    */
  variable short 	gadg_dist[1];  /* Array of gadget number   */
				       /* to convert at wakeup     */
  variable short 	gadg_area[1];  /* Same for area gadgets    */
  variable short 	gadg_vol[1];   /* Same for volumes gadgets */
  IGRint		select_opt;

  /* This structure should be later changed to include SSCS number */
  variable struct VDPcomp	CompNameDesc[0]; /* Compartment Data */

  IGRchar		CompPMObid[VDPOBID_LEN];
  IGRshort		idx_form;
  IGRboolean		b2150AttSet;	/* Flag to indicate if 2150
					   atts have been set( in the
					   command object instance data )
					   for the currently selected
					   compartment.*/
}
/*
 -------------------------------------------------------------------------
-v*/

/*---------------------
 * implementation area
 */

implementation

#include "UOMmacros.h"
#include "AS_status.h"
#include "vdbmacros.h"
#include "SMCompForm.h"


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

#include "SMCompForm.h"
#include "SMmsg.h"
#include "VDSFilter.h"

state start
  
  on CMD_TYPE = PLACE 
         do message_key SM_M_CmPl
         do construct_dsgn_list
            on ERROR state terminate
         do init_db
            on RETURN_CODE = ONLY_ONE_PART
               do init_form_new_comp( &me->ret, TRUE )
                 on ERROR state terminate
               do control_form_state 
               state form_modify 
            on ERROR state terminate
         do chg_state_db(&me->ret,FALSE)
         do empty_form_state
         do control_form_state
         state form_modify
  on CMD_TYPE = MODIFY
         do message_key SM_M_CmMd
         do empty_form_state
         do control_form_state
         state locate_compart
  on CMD_TYPE = PL_COMP_HULL
         do message_key SM_M_CmPlHull
         do init_db
           on RETURN_CODE = ONLY_ONE_PART
                 do init_form_new_comp( &me->ret, TRUE )
                   on ERROR state terminate
                 do empty_form_state
                 do control_form_state 
               state form_modify 
            on ERROR state terminate
         do chg_state_db(&me->ret,FALSE)
         do empty_form_state 
         do control_form_state
         state form_modify
  on CMD_TYPE = MD_COMP_HULL
        do message_key SM_M_CmMdHull
        do empty_form_state  
        do control_form_state
        state locate_compart

state locate_compart
prompt_key   SM_P_LocComp
accept_key   SM_P_PlAccRej
locate_mask "GRm_DATA | GRm_TEXT_VALUE"
locate_eligible "SMcomp"
locate_owner     "LC_RIGID_COMP | LC_RIGID_OWNER |
                  LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
filter vds_locate

  on EX_DATA or EX_STRING or EX_OBJID
   do locate_comp
        on ERROR state .
   do erase_hilite
   do hilite_half
   do chg_state_locate(&me->ret,TRUE)
   do empty_form_state  
   do set_compart_dbtype
   do control_form_state
   state form_modify
  

state locate_vol
prompt_key   SM_P_LocVol
accept_key   SM_P_PlAccRej
locate_mask "GRm_DATA | GRm_OBJID | GRm_RESET | GRm_TEXT_VALUE"
locate_class "EMSsolid,SMcomp"
locate_owner  "LC_RIGID_COMP | LC_RIGID_OWNER |
               LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
filter vds_locate_noauto

  on EX_DATA or  EX_STRING or EX_OBJID
   do add_locate_volume
      on RETURN_CODE = NO_OBJ_LOCATED do status_key SM_E_CmNoLocVol state .
      on RETURN_CODE = TO_MUCH_VOL    do status_key SM_E_CmTooMuchVol
                                      state terminate
   state .
  on EX_RJT_MOVEON 
   do chg_state_locate(&me->ret,TRUE)
   do local_display_form
   state form_comp

state form_modify
execute local_display_form 
  on CMD_TYPE = PLACE
   do message_key SM_M_CmPl state form_comp
  on CMD_TYPE = MODIFY
   do message_key  SM_M_CmMd state form_comp
  on CMD_TYPE  = PL_COMP_HULL 
    do message_key SM_M_CmPlHull state form_comp
  on CMD_TYPE = MD_COMP_HULL 
     do message_key  SM_M_CmMdHull state form_comp

state form_comp
prompt_key    SM_P_CmFrMod
filter	get_event

   on GR_UNKNOWN_TYPE.READ_FROM_PDU
           do VDReadFromPdu
               on ERROR state .
           do erase_hilite
           do init_form_new_comp( &me->ret, TRUE )
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
           do chg_state_select_db(&me->ret,TRUE)
           do init_form_new_comp( &me->ret, TRUE )
               on ERROR state terminate
           do empty_form_state 
           do control_form_state
           state .
 
  on GR_UNKNOWN_TYPE.PME_DATA_SEL
	   do chg_state_select_pme( &me->ret, FALSE)
           do control_form_state
           state .

  on GR_UNKNOWN_TYPE.LOAD_PME_DATA
	   do load2150data
	     on ERROR state .
	   do set_2150_flag
	   do erase_hilite
	   do init_form_new_comp( &me->ret, FALSE )
		on ERROR state terminate
	   state .

  on GR_UNKNOWN_TYPE.BEGIN_VOL_FORM  state init_form_vol

  on GR_UNKNOWN_TYPE.BEGIN_ATTR_FORM  do control_form_state
                                      do put_list_attr
                                      state .
                                     
  on GR_UNKNOWN_TYPE.BEGIN_DISP_FORM  do control_form_state
                                      state .

  on GR_UNKNOWN_TYPE.LOCATE_VOL   do chg_state_locate(&me->ret,FALSE)
                                  state locate_vol

  on GR_UNKNOWN_TYPE.BEGIN_GEOM_FORM  do control_form_state
                                      state .
 
   on GR_UNKNOWN_TYPE.RELOCATE_OBJ
       on CMD_TYPE = MODIFY  or CMD_TYPE = MD_COMP_HULL
                            do erase_hilite
                            do chg_state_locate(&me->ret,FALSE)
                            do empty_form_state
                            do control_form_state
                            state locate_compart
       state .

state init_form_vol

  on CMD_TYPE = PLACE or CMD_TYPE = PL_COMP_HULL
     do control_form_state
       on ERROR state form_comp 
     do put_list_vol
       on RETURN_CODE = LOCATE_VOL
           do chg_state_locate(&me->ret,FALSE)
           state locate_vol
       state form_comp

  on CMD_TYPE = MODIFY or CMD_TYPE = MD_COMP_HULL
      do control_form_state   
        on ERROR state form_comp 
      do put_list_vol
      state form_comp

at init   do init_all
          do control_login
          do form_position
at wakeup do hilite_half
          do control_unit
          do load_list
at sleep  do erase_hilite
at delete do delete_all

/*********************************************************************/


action init_form_new_comp( IGRlong *sts; IGRboolean bClearVols ) extern

action control_comp extern


action SMplace_comp(IGRlong *sts) extern

action SMmodif_comp(IGRlong *sts) extern

action put_disp_att_in_form extern 

action put_list_vol extern

action add_locate_volume extern

action select_delete_volume extern

action put_comp_att_in_form extern

action put_geom_info extern

action SMChgListVol(IGRlong *sts; int *modif_flag) extern

action form_notification extern

action reset_all extern

action save_all extern

action SMqueryCompartments(IGRlong *msg) extern

action load2150data extern

action set_compart_dbtype extern


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
  int  i;

  SetProc( hilite_half ); Begin
  
   *sts = OM_S_SUCCESS;

   for(i = 0; i< me->work_nb_vol; i++)
   {
     if(me->work_vol[i].id.objid == me->sel_vol.objid &&
	me->work_vol[i].id.osnum == me->sel_vol.osnum)
       continue;

     dp$display(msg = &msg, oids = &me->work_vol[i].id, mode = GRhhd); 
     if(!(status & msg & 1)) {printf("Error at GRdisplay\n");}
   }
  if(me->sel_vol.objid != NULL_OBJID)
    dp$display(msg = &msg, oids = &me->sel_vol, mode = GRhd);

  *sts = MSSUCC;
  status = OM_S_SUCCESS;

   End
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

  SetProc ( chg_state_locate ); Begin
   *sts = OM_S_SUCCESS;

  om$send(msg = message SMCmdComp.chg_state_db(sts,state),
	  targetid = my_id);
 
  if(state)
   {
     SMVA_enable(me->forms[me->idx_form].form_ptr,3,G_READ_PDU,G_DATA_SEL,G_PME_OPT);
     FIg_enable(me->forms[me->idx_form].form_ptr,GROUP_VOLUME);
     FIg_set_state_off(me->forms[me->idx_form].form_ptr, G_ADD_VOL);
   }
  else
   {
     if(me->sel_vol.objid != NULL_OBJID)
      {
	dp$display(msg = &msg, oids = &me->sel_vol, mode = GRhhd);
	me->sel_vol.objid = NULL_OBJID;
	SMSetSingleSelectMode(me->forms[me->idx_form].form_ptr,G_VOL_LIST,
			      me->work_nb_vol,2);
      }
     SMVA_disable(me->forms[me->idx_form].form_ptr,3,G_READ_PDU,G_DATA_SEL,G_PME_OPT);
     FIg_disable(me->forms[me->idx_form].form_ptr,GROUP_VOLUME);
   }
   status = OM_S_SUCCESS;
   End
   goto quit;
}



/*+me
 -------------------------------------------------------------------------
  Public Message locate_comp

  Abstract
	Verify the type of the located object (compart or compart hull)
	Store it in me->comp_id if the type is ok then fills the instances
	with the info and displays all parameters in the form.

  Arguments
	long		*sts	O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/


action locate_comp
{
  char    val_txt[ATTR_TXT];
  IGRlong msg;

  SetProc ( locate_comp ); Begin
   *sts = OM_S_SUCCESS;

  status = om$send(msg = message SMmgr.SMGetAttTxt
		   (&msg,"comp_type",val_txt,(IGRshort *)NULL),
		   targetid = me->event1.located_object[0].located_obj.objid,
		   targetos = me->event1.located_object[0].located_obj.osnum);
  as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);

  switch(me->mytype)
   {
   case MODIFY:
     if(! strcmp(val_txt,"hull compartment"))
      {
	ex$message(msgnumb = SM_E_CmNoCompLoc);
	goto wrapup;
      }
     break;
   case MD_COMP_HULL:
     if(strcmp(val_txt,"hull compartment"))
      {
	ex$message(msgnumb = SM_E_CmNoCompLoc);
	goto wrapup;
      }
     break;
   }

  me->comp_id = me->event1.located_object[0].located_obj;
  om$send(msg = message SMCmdComp.control_comp(sts),
	  targetid = my_id);
  if(!(*sts & 1)) goto wrapup;

  *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   End
   goto quit;


 wrapup:
  *sts = OM_E_ABORT;
  End
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message load_list

  Abstract
	Load the lists of dead weight, group and sub group and verify if global 
	data are defined (set me->all_defined).

  Arguments
	long		*sts	O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/


action load_list
{
  struct GRid  group,global;
  IGRchar      val_txt[256];
  IGRboolean   all_defined = TRUE;
  
  SetProc ( load_list ); Begin
   *sts = OM_S_SUCCESS;

  /* Jean 6/29/93 Don't reload if all have already been loaded */
  if(me->all_defined) {*sts = OM_S_SUCCESS; goto quit;}

  if(me->mytype == PLACE || me->mytype == MODIFY )
   {
     /* Commented for the TR:179603178 
     if(!SMGetActShipAtt(&global,(IGRshort *)NULL,(struct GRmd_env *)NULL)
	|| global.objid == NULL_OBJID)
	{ ex$message(msgnumb = SM_E_SfNoGlob); 
	  all_defined = FALSE; 
	}
     */

     if(!SMget_list_dead_weight(me->forms[me->idx_form].form_ptr,TRUE))
       {ex$message(msgnumb = SM_E_CmNoDead);all_defined = FALSE;} 
	
     if(SMget_list_group(me->forms[me->idx_form].form_ptr,TRUE))
      {
	FIg_get_text(me->forms[me->idx_form].form_ptr,G_GROUP_LIST,val_txt);
	if(val_txt[0] != 0)
	  if(SMfound_object_by_name
	     (val_txt,SM_GRP,&group,(struct GRmd_env *)NULL))
	    SMget_list_sub_group(me->forms[me->idx_form].form_ptr,&group,TRUE);
      }
     else
       {ex$message(msgnumb = SM_E_CmNoGroup); all_defined = FALSE;}
   }

  me->all_defined = all_defined;
  *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   End
   goto quit;
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
  int already_placed;
  char catalog[15];

  SetProc ( read_pdu_review ); Begin
   *sts = OM_S_SUCCESS;

  if(!VD_PDU_present) goto wrapup;
	
  /* don't call this function with me->db_info.catalog, because it erases it*/

  if(!SMReadCompPduReview(SM_COMPART,
			  catalog,rev_partid,rev_revision))
    goto wrapup;

  if(me->compart_track && me->mytype == PLACE)
   {
     om$send(msg = message SMCmdComp.check_already_placed
	     (sts,me->db_info.catalog,rev_partid,rev_revision,&already_placed),
	     targetid = my_id);
     if(already_placed) 
       goto wrapup;
   } 
    
  strcpy(me->db_info.catalog, catalog);

  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  End
  goto quit;

 wrapup:
  *sts = OM_E_ABORT; 
  FIg_set_state_off(me->forms[me->idx_form].form_ptr,G_READ_PDU);
  End
}

/*+me
 -------------------------------------------------------------------------
  Public Message check_already_placed

  Abstract

	Check if the given part is already in the dsgn list (compart in current 
	design) or in the list from the database (compart placed by checkin).

  Arguments
	long	*sts		O 	completion code.
	char	*family		I	family name
	char	*partnum	I	part name
	char	*partrev	I	part rev
	int	*already_placed O	1 if placed, else 0

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

action check_already_placed(long *sts;char *family;char *partnum;char *partrev;
			    int *already_placed)
{
  char  **family_db = NULL,**partnum_db = NULL,**partrev_db = NULL;
  int   nb_parts_db = -1;
  int   i;
  char  my_msg[80];
  
  SetProc ( check_already_placed ); Begin
  *already_placed = 0;
  *sts            = OM_S_SUCCESS;

  if(me->mytype != PLACE || !me->compart_track)
    goto quit; /* We don't verify for other command */

  /* Look at list of compartment place by checkin */
  
  SMGetDbList(&family_db,&partnum_db,&partrev_db,&nb_parts_db);
  if(nb_parts_db > 0 && family_db && partnum_db && partrev_db)
    for(i = 0; i < nb_parts_db; i++)
      if(strcmp(family_db[i] , family)  == 0 &&
	 strcmp(partnum_db[i], partnum) == 0 &&
	 strcmp(partrev_db[i], partrev) == 0)
       {
	 ex$message(msgnumb = SM_I_CmAlreadyPl,buff = my_msg);
	 FIg_set_text(me->forms[me->idx_form].form_ptr,FI_MSG_FIELD,my_msg);
	 *already_placed = 1;
	 goto quit;
       }
  
  /* Look compartment in current file */
  if(me->nb_parts_dsgn && me->family_dsgn && me->partnum_dsgn
     && me->partrev_dsgn)
    for(i = 0; i < me->nb_parts_dsgn; i++)
      if(strcmp(me->family_dsgn[i] , family)  == 0 &&
	 strcmp(me->partnum_dsgn[i], partnum) == 0 &&
	 strcmp(me->partrev_dsgn[i], partrev) == 0)
       {
	 ex$message(msgnumb = SM_I_CmAlreadyPl,buff = my_msg);
	 FIg_set_text(me->forms[me->idx_form].form_ptr,FI_MSG_FIELD,my_msg);
	 *already_placed = 1;
	 goto quit;
       }
   status = OM_S_SUCCESS;
   End
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
  SetProc( control_login ); Begin

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
    FIg_delete(me->forms[me->idx_form].form_ptr,G_READ_PDU);

  /* Set catalog */
  switch(me->mytype)
   {
   case PLACE: case MODIFY:
     strcpy(me->db_info.catalog,"compartment"); break;
   case PL_COMP_HULL: case MD_COMP_HULL:
     strcpy(me->db_info.catalog,"comp_hull"); break;
   }
  me->db_info.quantity = COMPARTMENT_OBJ;
  
  *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   End
   goto quit;
}


/*+me
 -------------------------------------------------------------------------
  Public Message realloc_dsgn_list

  Abstract

	Realloc if necessary the list of placed compartment in the
	current design file =  me->family_dsgn, me->partnum_dsgn 
	and me->partrev_dsgn


  Arguments
	long	*sts		O 	completion code.
	int	add_nb_obj	I	nb_object to add in the list

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/


action realloc_dsgn_list(long *sts; int add_nb_obj)
{
  IGRint new_size;
  
  SetProc ( realloc_dsgn_list ); Begin
  *sts = OM_S_SUCCESS;
  
  new_size = me->nb_parts_dsgn + add_nb_obj;
  if(new_size == 0) goto quit;
  if(me->nb_alloc_dsgn >= new_size)
    goto quit; /* List doesn't need to be resize */
  
  if(me->nb_alloc_dsgn == 0)
   {
     me->family_dsgn = _MALLOC (new_size, char *);
     me->partnum_dsgn = _MALLOC(new_size, char *);
     me->partrev_dsgn = _MALLOC(new_size, char *);
   }
  else
   {
     new_size += 10;
     me->family_dsgn = _REALLOC(me->family_dsgn, new_size, char *);
     me->partnum_dsgn = _REALLOC(me->partnum_dsgn, new_size, char *);
     me->partrev_dsgn = _REALLOC(me->partrev_dsgn, new_size, char *);
   }

  if(!me->family_dsgn || !me->partnum_dsgn || !me->partrev_dsgn)
   {printf("Memory problem\n");*sts = OM_E_ABORT;goto quit;}
  me->nb_alloc_dsgn = new_size;

   status = OM_S_SUCCESS;
   End
   goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message add_dsgn_list

  Abstract

	Realloc if necessary the list of placed compartment in the
	current design file =  me->family_dsgn, me->partnum_dsgn 
	and me->partrev_dsgn and add the given part.


  Arguments
	long	*sts		O 	completion code.
	char 	*family		I	family to add
	char 	*partnum	I	partnum to add
	char 	*partrev	I	partrev to add

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

action add_dsgn_list(long *sts;char *family; char *partnum; char *partrev)
{
  SetProc ( add_dsgn_list ); Begin
   *sts = OM_S_SUCCESS;

  me->family_dsgn[me->nb_parts_dsgn] = _MALLOC(strlen(family)+1, char);
  me->partnum_dsgn[me->nb_parts_dsgn] = _MALLOC(strlen(partnum)+1, char);
  me->partrev_dsgn[me->nb_parts_dsgn] = _MALLOC(strlen(partrev)+1, char);

  if(!me->family_dsgn[me->nb_parts_dsgn] ||
     !me->partnum_dsgn[me->nb_parts_dsgn] ||
     !me->partrev_dsgn[me->nb_parts_dsgn])
   { printf("Not enough memory\n"); *sts = OM_E_ABORT; goto quit;}
  
  strcpy(me->family_dsgn[me->nb_parts_dsgn],family);
  strcpy(me->partnum_dsgn[me->nb_parts_dsgn],partnum);
  strcpy(me->partrev_dsgn[me->nb_parts_dsgn],partrev);
  me->nb_parts_dsgn++;
  *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   End
   goto quit;
}


/*+me
 -------------------------------------------------------------------------
  Public Message construct_dsgn_list

  Abstract

	Construct the list of placed compartment in the
	current design file =  me->family_dsgn, me->partnum_dsgn 
	and me->partrev_dsgn and add the given part.


  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

action construct_dsgn_list
{
  IGRlong          msg;
  struct SMObjList list;
  int              i,j;
  IGRboolean       to_add;
  char             **family_db = NULL,**partnum_db = NULL,**partrev_db = NULL;
  int              nb_parts_db = -1;
  char             family[ATTR_TXT],partnum[ATTR_TXT],partrev[ATTR_TXT];

   SetProc ( construct_dsgn_list ); Begin
   *sts = OM_S_SUCCESS;

  list.list       = NULL;
  list.nb_objects = 0;

  /* Set if compart tracking is wish by user */

  if(!SMGetSymbTrack((char *)NULL,&me->compart_track))
    me->compart_track = 0;
  
  if(me->mytype == PLACE && me->compart_track)
   {
     SMGetDbList(&family_db,&partnum_db,&partrev_db,&nb_parts_db);

     /* Recompute database list if never compute ( nb_parts == -1 ) */ 

     if((!family_db || !partnum_db || !partrev_db) && nb_parts_db != 0)
      {
	if(!SMRecomputeDbList())
	 {printf("Error finding compart placed in database\n");goto wrapup;}

	/* Recover now pointer */

	SMGetDbList(&family_db,&partnum_db,&partrev_db,&nb_parts_db);
      }

     /* Get the list of all compart */

     status = SM$CritSel(msg = &msg, type = SM_COMPART, list  = &list);
     if(!(status & 1) || msg != MSSUCC)
      {printf("Error list of already placed compart\n"); goto wrapup;}
     
     if(list.nb_objects)
      {
	om$send(msg = message SMCmdComp.realloc_dsgn_list(sts,list.nb_objects),
		targetid = my_id);
	if(!(*sts & 1)) goto wrapup;
	
	for(i = 0; i < list.nb_objects; i++)
	 {
	   status = om$send(msg = message SMmgr.SMGetAttTxt
			    (&msg,"family",family,(IGRshort *)NULL),
			    targetid = list.list[i].obj_id.objid,
			    targetos = list.list[i].obj_id.osnum);
	   if(!(status & msg & 1)) continue;
	   
	   status = om$send(msg = message SMmgr.SMGetAttTxt
			    (&msg,"partno",partnum,(IGRshort *)NULL),
			    targetid = list.list[i].obj_id.objid,
			    targetos = list.list[i].obj_id.osnum);
	   if(!(status & msg & 1)) continue;
	   
	   status = om$send(msg = message SMmgr.SMGetAttTxt
			    (&msg,"partrev",partrev,(IGRshort *)NULL),
			    targetid = list.list[i].obj_id.objid,
			    targetos = list.list[i].obj_id.osnum);
	   if(!(status & msg & 1)) continue;
	   
	   to_add = TRUE;
	   
	   /* Do not put same part in db_list and design list */

	   if(nb_parts_db > 0 && family_db && partnum_db && partrev_db)
	     for(j=0; j < nb_parts_db; j++)
	      {
		if(strcmp(family_db[j] , family)  == 0 &&
		   strcmp(partnum_db[j], partnum) == 0 &&
		   strcmp(partrev_db[j], partrev) == 0)
		  to_add = FALSE;
	      }
	   
	   if(to_add)
	    {
	      /* Not already existing, copy in list of placed compart */
	      om$send(msg = message SMCmdComp.add_dsgn_list
		      (sts,family,partnum,partrev),
		      targetid = my_id);
	      if(!(*sts & 1)) goto wrapup; 
	    }
	 }
      }
   }

  if(list.list != NULL) {free(list.list); list.list = NULL;}
  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  End
  goto quit;

 wrapup:
  if(list.list != NULL) {free(list.list); list.list = NULL;}
  *sts = OM_E_ABORT;
  End
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
  IGRint	type;

  SetProc( put_list_attr ); Begin
   *sts = OM_S_SUCCESS;

  SMStopSingleSelectMode(me->forms[me->idx_form].form_ptr,G_ATT_LIST,NUM_COL_ATT,
			 FI_APPEND,FI_APPEND, FI_APPEND);
 
  SMVA_enable(me->forms[me->idx_form].form_ptr,5,G_ATT_LIST,G_DEL_ATT,
	      FI_RESET,FI_ACCEPT,FI_EXECUTE);
		 
  type = me->form_state == DYN_LIST ? 1 : 0;

  om$send(msg = message SMCmdComp.VDSetRgAtt(sts),
	     targetid = my_id);

  om$send(msg = message SMCmdComp.VDSetAttList(sts, type),targetid = my_id);

  FIg_display(me->forms[me->idx_form].form_ptr,G_ATT_LIST);
  
  FIg_set_state(me->forms[me->idx_form].form_ptr,G_STATIC_TOG,
		me->form_state == DYN_LIST ? TRUE : FALSE);

  FIg_set_state_off(me->forms[me->idx_form].form_ptr,G_DEL_ATT); 

  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  End
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

  SetProc ( control_unit ); Begin
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
     FIg_set_text(me->forms[me->idx_form].form_ptr,G_UNIT,cur_unit);
     FIfld_set_default_text(me->forms[me->idx_form].form_ptr,G_UNIT,0,0,cur_unit,0);
     goto quit;
   }

  /* If unit change during wakeup, change current unit and recompute value */

  if(strcmp(me->save_unit,cur_unit))
   {
     FIg_set_text(me->forms[me->idx_form].form_ptr,G_UNIT,cur_unit);
     FIfld_set_default_text(me->forms[me->idx_form].form_ptr,G_UNIT,0,0,cur_unit,0);

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
	FIg_get_text(me->forms[me->idx_form].form_ptr,me->gadg_dist[i],tmp);
	if(tmp[0] != '\0')
	 {
	   FIg_get_value(me->forms[me->idx_form].form_ptr,me->gadg_dist[i],&val_db);
	   val_db = val_db * coef;
	   FIg_set_value(me->forms[me->idx_form].form_ptr,me->gadg_dist[i],val_db);
	 }
	i++;
      }

     i = 0;
     while(me->gadg_area[i] != 0)
      {
	tmp[0] = '\0';
	FIg_get_text(me->forms[me->idx_form].form_ptr,me->gadg_area[i],tmp);
	if(tmp[0] != '\0')
	 {
	   FIg_get_value(me->forms[me->idx_form].form_ptr,me->gadg_area[i],&val_db);
	   val_db = val_db * area_coef;
	   FIg_set_value(me->forms[me->idx_form].form_ptr,me->gadg_area[i],val_db);
	 }
	i++;
      }

     i = 0;
     while(me->gadg_vol[i] != 0)
      {
	tmp[0] = '\0';
	FIg_get_text(me->forms[me->idx_form].form_ptr,me->gadg_vol[i],tmp);
	if(tmp[0] != '\0')
	 {
	   FIg_get_value(me->forms[me->idx_form].form_ptr,me->gadg_vol[i],&val_db);
	   val_db = val_db * vol_coef;
	   FIg_set_value(me->forms[me->idx_form].form_ptr,me->gadg_vol[i],val_db);
	 }
	i++;
      }

     strcpy(me->save_unit,cur_unit);
   }

  *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   End
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
  SetProc ( empty_form_state ); Begin
   *sts = OM_S_SUCCESS;

  me->old_form_state = me->form_state = EMPTY_STATE; 
  me->select_opt = DB_SELECT; 

  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  End
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

  SetProc ( chg_state_select_db ); Begin
   *sts = OM_S_SUCCESS;

  if(state)
   {
     if(me->save_nb_att != 0)  /* Some data have been loaded */
      {
	SMVA_enable(me->forms[me->idx_form].form_ptr,3,FI_ACCEPT,FI_EXECUTE,FI_RESET);
      }
     else
       FIg_disable(me->forms[me->idx_form].form_ptr,GROUP_SELECT);

     SMVA_enable(me->forms[me->idx_form].form_ptr,3,G_READ_PDU,G_DATA_SEL,G_PME_OPT);
     FIg_set_state_off(me->forms[me->idx_form].form_ptr, G_DATA_SEL);
   }
  else
   {
     SMVA_disable(me->forms[me->idx_form].form_ptr,3,G_READ_PDU,G_DATA_SEL,G_PME_OPT);
     SMVA_disable(me->forms[me->idx_form].form_ptr,2,FI_ACCEPT,FI_EXECUTE);
     FIg_enable(me->forms[me->idx_form].form_ptr,FI_RESET);
   }

  status = OM_S_SUCCESS;
  End
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message chg_state_select_pme

  Abstract
	process enabling/disabling of gadgets depending on pme option
  Arguments
	long		*sts	O 	completion code.
	IGRboolean	state	I	1 = enable, else disable

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/


action chg_state_select_pme (long *sts; IGRboolean state)
{

  SetProc ( chg_state_select_pme ); Begin
   *sts = OM_S_SUCCESS;

  if(state)
   {
     SMVA_enable(me->forms[me->idx_form].form_ptr,3,FI_ACCEPT,FI_EXECUTE,FI_RESET);

     SMVA_enable(me->forms[me->idx_form].form_ptr,3,G_READ_PDU,G_DATA_SEL,G_PME_OPT);
/*     FIg_set_state_off(me->forms[me->idx_form].form_ptr, G_PME_OPT); */
     FIg_disable(me->forms[me->idx_form].form_ptr,GROUP_PME);
     FIg_disable(me->forms[me->idx_form].form_ptr,GROUP_SELECT);
   }
  else
   {
/*     SMVA_disable(me->forms[me->idx_form].form_ptr,3,G_READ_PDU,G_DATA_SEL,G_PME_OPT);
     SMVA_disable(me->forms[me->idx_form].form_ptr,2,FI_ACCEPT,FI_EXECUTE); */

     SMVA_enable(me->forms[me->idx_form].form_ptr,3,FI_ACCEPT,FI_EXECUTE,FI_RESET);
     FIg_erase(me->forms[me->idx_form].form_ptr,G_PME_OPT );
     FIg_erase(me->forms[me->idx_form].form_ptr,G_READ_PDU );
     FIg_erase(me->forms[me->idx_form].form_ptr,G_DATA_SEL );

     FIg_enable(me->forms[me->idx_form].form_ptr,GROUP_SELECT);
     FIg_enable(me->forms[me->idx_form].form_ptr,GROUP_PME);
     FIg_enable(me->forms[me->idx_form].form_ptr,GROUP_PME_SEL);
   }

  status = OM_S_SUCCESS;
  End
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

  SetProc ( chg_state_db ); Begin
   *sts = OM_S_SUCCESS;

  if(state)
   {
/*     FIg_enable(me->forms[me->idx_form].form_ptr,GROUP_MAIN); */
     FIg_enable(me->forms[me->idx_form].form_ptr,GROUP_SELECT);
     
     SMVA_enable(me->forms[me->idx_form].form_ptr,3,
		 FI_ACCEPT,FI_EXECUTE,FI_RESET);
     FIg_set_state_off(me->forms[me->idx_form].form_ptr, G_READ_PDU);
     FIg_set_state_off(me->forms[me->idx_form].form_ptr, G_DATA_SEL);
   }
  else
   {
/*   Next line supress due to a bug in forms : enable a list associated */
 /*   to field doesnt't work when the list is not displayed */

/*   FIg_disable(me->forms[me->idx_form].form_ptr,GROUP_MAIN);  */

     FIg_disable(me->forms[me->idx_form].form_ptr,GROUP_SELECT);
     SMVA_disable(me->forms[me->idx_form].form_ptr,3,
		  FI_ACCEPT,FI_EXECUTE,FI_RESET);
   }

  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  End
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

  SetProc ( disp_attr_gadgets ); Begin
   *sts = OM_S_SUCCESS;


    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr, 
                                                        GROUP_ATT, state),
	    targetid = my_id);

  if(state)
   {
     FImcf_get_attr(me->forms[me->idx_form].form_ptr,G_ATT_LIST,&mask);
     FImcf_set_attr(me->forms[me->idx_form].form_ptr,G_ATT_LIST,
		    mask | FI_DISPLAY_VSCROLL);
   }
  else
   {
     /* Display scroll bar of precedeing gadget cause problem, erase them */

     FImcf_get_attr(me->forms[me->idx_form].form_ptr,G_ATT_LIST,&mask);
     if(mask & FI_DISPLAY_VSCROLL)
       FImcf_set_attr(me->forms[me->idx_form].form_ptr,G_ATT_LIST,
		      mask ^ FI_DISPLAY_VSCROLL);
   }
  
  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  End
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

  SetProc( init_all ); Begin
   *sts = OM_S_SUCCESS;

  om$send(msg = message VDCmdPart.init_all(sts),
          targetid = my_id,
          mode     = OM_e_wrt_message);
  
  om$send(msg = message VDCmdAttMgr.init_all(sts),
          targetid = my_id,
          mode     = OM_e_wrt_message);

  me->idx_form = 0;
  
  /* init VDCmdAttMgr instances */
  if( (IsPmeEnabled()) && (me->mytype == PLACE  || me->mytype == MODIFY ) )
  {
    me->idx_form = 1 ;
    //Rajendra Mar 5 TR # 179802545 Hide PME button if connected to SIR.
    if(WhichAim() == SIR )
      FIg_delete(me->forms[me->idx_form].form_ptr, 44);
  }
  else
    me->idx_form = 0 ;

  me->form_sel_part = me->form_att_ptr = me->forms[me->idx_form].form_ptr;

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
  me->select_opt    = DB_SELECT;



  /* Jean 2 June 93 Gener default name for place compartment */

  if(me->mytype == PLACE)    
    GetDefName("SMcomp_0",me->old_name);
  else
    me->old_name[0] = '\0';

  me->all_defined   = FALSE;
  me->nb_alloc_dsgn = 0;
  me->nb_parts_dsgn = 0;
  me->family_dsgn = me->partnum_dsgn = me->partrev_dsgn = NULL;
  me->b2150AttSet = FALSE; /* S2150 attrs not set for currently act comp.*/

  *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   End
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
  SetProc ( delete_all ); Begin
   *sts = OM_S_SUCCESS;

  VDSfree_arrays(me->nb_parts_dsgn,me->family_dsgn,me->partnum_dsgn,
		me->partrev_dsgn);
  me->family_dsgn  = NULL;
  me->partnum_dsgn = NULL;
  me->partrev_dsgn = NULL;

  om$send(msg = message VDCmdPart.delete_all(sts),
          targetid = my_id,
          mode     = OM_e_wrt_message);

  om$send(msg = message VDCmdAttMgr.delete_all(sts),
          targetid = my_id,
          mode     = OM_e_wrt_message);

  FIf_get_location(me->forms[me->idx_form].form_ptr,&x_pos,&y_pos);
  *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   End
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
  int          xmain,ymain;
  struct GRid  setup_obj;

  SetProc ( form_position ); Begin
   *sts = OM_S_SUCCESS;

  me->save_nb_att = 0;

  if(x_pos == -1 || y_pos == -1)
     FIf_get_location(me->forms[me->idx_form].form_ptr,&xmain,&ymain);
  else 
    {xmain = x_pos; ymain = y_pos;}
  
  FIf_set_location(me->forms[me->idx_form].form_ptr,xmain,ymain);
  FIgrp_set_pass_on(me->forms[me->idx_form].form_ptr,GROUP_SELECT);
  FIg_display(me->forms[me->idx_form].form_ptr,GROUP_SELECT);

  switch(me->mytype)
    {
    case  PLACE:
      FIg_set_text(me->forms[me->idx_form].form_ptr,G_COMP_TITLE,"Place Compartment");
      break;
    case MODIFY:
      FIg_set_text(me->forms[me->idx_form].form_ptr,G_COMP_TITLE,"Modify Compartment");
      break;
    case PL_COMP_HULL:
      FIg_set_text(me->forms[me->idx_form].form_ptr,G_COMP_TITLE,"Place Hull Compartment");
      break;
    case MD_COMP_HULL:
      FIg_set_text(me->forms[me->idx_form].form_ptr,G_COMP_TITLE,"Modify Hull Compartment");
      break;
    }
      
  if(me->mytype == MODIFY || me->mytype == MD_COMP_HULL)
   {
     FIg_delete(me->forms[me->idx_form].form_ptr, G_DATA_SEL);
     FIg_delete(me->forms[me->idx_form].form_ptr, G_READ_PDU);
   }
  
  switch(me->mytype)
   {
   case PLACE: case MODIFY:
     FIg_delete(me->forms[me->idx_form].form_ptr,G_HULL_TEXT);
     break;

   case PL_COMP_HULL:  case MD_COMP_HULL:
     FIg_delete(me->forms[me->idx_form].form_ptr,G_DEAD_LIST);
     FIg_delete(me->forms[me->idx_form].form_ptr,G_DEAD_TEXT);
     FIg_delete(me->forms[me->idx_form].form_ptr,G_GROUP_LIST);
     FIg_delete(me->forms[me->idx_form].form_ptr,G_GROUP_TEXT);
   
     FIg_delete(me->forms[me->idx_form].form_ptr,G_INSIDE);
     FIg_delete(me->forms[me->idx_form].form_ptr,G_COEF_COMP);
     FIg_delete(me->forms[me->idx_form].form_ptr,G_PERM_COMP);
     FIg_delete(me->forms[me->idx_form].form_ptr,G_COEF_COMP_TXT);
     FIg_delete(me->forms[me->idx_form].form_ptr,G_PERM_COMP_TXT);
     FIg_delete(me->forms[me->idx_form].form_ptr,G_SUB_GROUP_TEXT);
     FIg_display(me->forms[me->idx_form].form_ptr,G_HULL_TEXT);

     break;
   }

  /* Read tightness file */

  om$send(msg = message SMCmdComp.VDReadFileAttr
	  (sts,TIGHTNESS_FILE,me->forms[me->idx_form].form_ptr,G_TIGHTNESS),
	   targetid = my_id);
  if(!(*sts & 1))
    {*sts = OM_E_ABORT; return OM_I_STOP_SENDING;}

  /* Init save_unit to 0 */
  me->save_unit[0] = '\0';

  /* Init number of gadgets to gadget to convert at wakeup */

  om$vla_set_dimension(varray = me->gadg_dist,size = 4);
  om$vla_set_dimension(varray = me->gadg_area,size = 4);
  om$vla_set_dimension(varray = me->gadg_vol,size = 4);

  me->gadg_dist[0] = G_COG_X; me->gadg_dist[1] = G_COG_Y;
  me->gadg_dist[2] = G_COG_Z; me->gadg_dist[3] = 0;
    
  me->gadg_area[0] = G_EXP_AREA; me->gadg_area[1] = G_TOT_AREA;
  me->gadg_area[2] = G_FLOOR_AREA; me->gadg_area[3] = 0;

  me->gadg_vol[0] = G_EXP_VOL; me->gadg_vol[1] = G_REAL_VOL;
  me->gadg_vol[2] = G_SECT_VOL; me->gadg_vol[3] = 0;
  
  /* Verify compartment setup object exists : if not read default file */
  if(!SMGetSetupObj(&setup_obj)) 
   { ex$message(msgnumb = SM_E_CmErrSetup); goto wrapup;} 
   
  if(setup_obj.objid == NULL_OBJID &&
     !SMReadCompSetup(SETUP_FILE_NAME,&setup_obj))
   { ex$message(msgnumb = SM_E_CmErrSetup); goto wrapup;}
  
  *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   End
   goto quit;


 wrapup:
  me->state = _terminate;
  *sts = OM_E_ABORT;
  End
  return OM_I_STOP_SENDING;
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
  IGRboolean vol_gadgets =  FALSE,
             attr_gadgets = FALSE,
             geom_gadgets = FALSE,
             disp_gadgets = FALSE,
             db_gadgets   = FALSE,
             main_gadgets = FALSE,
             sel_gadgets  = TRUE,
	     pme_sel_gadget = FALSE,
	     pme_gadgets = FALSE;

  char  my_msg[80];

  SetProc( control_form_state ); Begin
   *sts = OM_S_SUCCESS;

  __DBGpr_int ("Form State", me->form_state );
  __DBGpr_int ("Select Option", me->select_opt );

  /* Save dynamic list if it was previously displayed */
  /* If error return to dynamic list */

  if(me->old_form_state == DYN_LIST && me->form_state != DYN_LIST)
   {
     om$send(msg = message SMCmdComp.VDSaveListDyn(sts, my_msg),
				targetid = my_id);
     if(!(*sts & 1))
      {
	me->form_state = DYN_LIST;
	FIg_set_state_on(me->forms[me->idx_form].form_ptr,G_USER_ATT);
	FIg_set_text(me->forms[me->idx_form].form_ptr,FI_MSG_FIELD,my_msg);
	*sts = OM_E_ABORT;
	goto quit;
      }
   }

  if(me->select_opt == DB_SELECT ) main_gadgets = TRUE;
  if(me->select_opt == PME_SELECT) pme_gadgets = pme_sel_gadget = TRUE;
  if(me->select_opt == PME_MODIFY) pme_gadgets = TRUE;

  switch(me->form_state)
   {
   case INC_LIST: case EXC_LIST:
     vol_gadgets = TRUE; break;
   
   case STAT_LIST: case DYN_LIST:
     attr_gadgets = TRUE;  break;

   case GEOM_INFO:
     geom_gadgets = TRUE;  break;

   case DISP_OPT:
     disp_gadgets = TRUE;  break;

   case DB_SELECT:
      db_gadgets = TRUE;  sel_gadgets = FALSE; main_gadgets = FALSE; break;

   case PME_SELECT:
      pme_sel_gadget = TRUE;
   case PME_MODIFY:
      pme_gadgets = TRUE; main_gadgets = FALSE; break;
     
   case EMPTY_STATE:
      main_gadgets = TRUE; break;
   }

  /* First erase than display */
  if(!vol_gadgets){
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr,
                                                    GROUP_VOLUME,FALSE),
	    targetid = my_id);
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr,
                                                    GROUP_VOLUME_TEXT,FALSE),
            targetid = my_id);
  }
  if(!attr_gadgets)
    om$send(msg = message SMCmdComp.disp_attr_gadgets(sts,FALSE),
	    targetid = my_id);
  if(!disp_gadgets){
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr,
                                                    GROUP_DISPLAY,FALSE),
	    targetid = my_id);
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr,
                                                    GROUP_JUSTIF,FALSE),
            targetid = my_id);
  }
  if(!geom_gadgets)
     om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr, 
                                                            GROUP_GEOM, FALSE),
	     targetid = my_id);
  if(!db_gadgets)
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr, 
                                                        GROUP_DB, FALSE),
	    targetid = my_id);

  if(!sel_gadgets)
    FIg_erase(me->forms[me->idx_form].form_ptr,GROUP_SELECT);
  if(!main_gadgets)
    FIg_erase(me->forms[me->idx_form].form_ptr,GROUP_MAIN);

  if(!pme_gadgets)
  {
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr,
							GROUP_PME, FALSE),
	    targetid = my_id);
    FIg_erase(me->forms[me->idx_form].form_ptr,GROUP_PME );
  }

  if(!pme_sel_gadget)
  {
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr,
							GROUP_PME_SEL, FALSE),
	    targetid = my_id);
    FIg_erase(me->forms[me->idx_form].form_ptr,GROUP_PME_SEL );
  }

  if(vol_gadgets){
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr,
                                                    GROUP_VOLUME,TRUE),
	    targetid = my_id);
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr,
                                                    GROUP_VOLUME_TEXT,TRUE),
            targetid = my_id);
  }

  if(attr_gadgets)
    om$send(msg = message SMCmdComp.disp_attr_gadgets(sts,TRUE),
	    targetid = my_id);
  if(disp_gadgets){
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr,
                                                        GROUP_DISPLAY, TRUE),
            targetid = my_id);
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr,
                                                        GROUP_JUSTIF, TRUE),
            targetid = my_id);
  }
  if(geom_gadgets)
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr, 
                                                        GROUP_GEOM, TRUE),
	    targetid = my_id);
  if(db_gadgets)
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr, 
                                                        GROUP_DB, TRUE),
	    targetid = my_id);

  if(pme_sel_gadget)
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr,
							GROUP_PME_SEL, TRUE),
	    targetid = my_id);

  if(pme_gadgets)
    om$send(msg = message SMCmdComp.VDDspGrpGadg(sts,me->forms[me->idx_form].form_ptr,
							GROUP_PME, TRUE),
	    targetid = my_id);

  if( me->select_opt == PME_MODIFY || me->mytype == MODIFY )
  {
    FIg_disable(me->forms[me->idx_form].form_ptr,G_DEF2150_ATTR );
    FIg_erase(me->forms[me->idx_form].form_ptr,G_PME_OPT );
  }

  if(sel_gadgets)
    FIg_display(me->forms[me->idx_form].form_ptr,GROUP_SELECT);
  if(main_gadgets)
    FIg_display(me->forms[me->idx_form].form_ptr,GROUP_MAIN);

  FIg_set_state(me->forms[me->idx_form].form_ptr,G_VOLUMES,vol_gadgets);
  FIg_set_state(me->forms[me->idx_form].form_ptr,G_DISP_OPT,disp_gadgets);
  FIg_set_state(me->forms[me->idx_form].form_ptr,G_USER_ATT,attr_gadgets);
  FIg_set_state(me->forms[me->idx_form].form_ptr,G_GEOM_INFO,geom_gadgets);
  FIg_set_state(me->forms[me->idx_form].form_ptr,G_DATA_SEL,db_gadgets);
  *sts = OM_S_SUCCESS;

  FIf_display(me->forms[me->idx_form].form_ptr);

   status = OM_S_SUCCESS;
   End
   goto quit;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        delete_row from VDS_LOCATE

  Abstract
      performs the delete of a row in the given gadget field .
      It is called when the button G_DEL_ATT is pushed.


      delete row sequence:
                1/ me->delete_flag =0 indicate that the user wants to
                   delete a row


                2/ me->delete_flag =1 indicate that the user wants to store
                   the selected row.

	It has been overriden in order to delete the attribute from the list
	in me->work_att.

  Algorithm

	- send VDCmdAttMgr.delete_row
	- if( !me->del_flag) disable some gadgets
	- else 
		. del_one_attrib in me->work_att (delete the attribute 
		displayed at me->selected_row)
		. enable the gadgets again

  Arguments
        long            *sts            O       Completion code
        char            *form_ptr       I       form pointer
        int             label           I       gadget label where to delete

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

action delete_row(long *sts; char   *form_ptr; int label)
{
  int  sel,pos;
  char name[ATTR_TXT], my_msg[80];

  SetProc ( delete_row ); Begin
  *sts = OM_S_SUCCESS;

  om$send(msg = message VDCmdAttMgr.delete_row(sts, form_ptr,label),
             targetid = my_id,
             mode     = OM_e_wrt_message);

   if( !me->del_flag)
     SMVA_disable(me->forms[me->idx_form].form_ptr,3,FI_RESET,FI_ACCEPT,FI_EXECUTE);
   else{
        /* One attribute is selected, delete it*/
        if(me->selected_row >= 0) {
            FIfld_get_text(me->forms[me->idx_form].form_ptr,G_ATT_LIST,me->selected_row,GI_NAME,
		    ATTR_TXT,(unsigned char *)name,&sel,&pos);
            name[ATTR_TXT - 1] = '\0';
            del_one_attrib(me->work_att,me->work_att_type,&me->work_nb_att,name);
            ex$message( msgnumb = SM_I_CmAttDel, buff = my_msg);
            FIg_set_text(me->forms[me->idx_form].form_ptr,FI_MSG_FIELD,my_msg);
        }

        /* Enable others attributes */
        SMVA_enable(me->forms[me->idx_form].form_ptr,3,FI_RESET,FI_ACCEPT,FI_EXECUTE);
  }

   status = OM_S_SUCCESS;
   End
   goto quit;

}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        VDPlaceDbAttInList from VDCmdPart

  Abstract
	That method displays the list of the attribute values
	for the current part in me->g_db_list gadget.
	If no part has been already selected it only displays the default
	criteria.

	It has been overriden to look if part have already been placed if 
	compart tracking option is on and to convert expected_area and 
	expected_vol to the current unit.

  Algorithm
	- send VDCmdPart.VDPlaceDbAttInList (displays the attributes of
	  the current part in me->g_db_list).
	- if "expected_area" or "expected_vol" is an attribute of the part,
 	  convert the value to the current unit.
	- if me->compart_track send SMCmdComp.check_already_placed = check
	if that part has been already placed. If it has been already placed, 
	disable the gadget G_LOAD in order to forbid to place that part again.
		

  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

action VDPlaceDbAttInList
{
 int    	   row, col, already_placed,cur_index;
 char   	   *family,*partnum,*partrev;
 double            val_db;
 char   	   val_txt[80];
 int               num_att;
 struct part_attr  *part; 

  SetProc( VDPlaceDbAttInList ); Begin
  *sts = OM_S_SUCCESS;

  cur_index = me->cur_part - 1; /* Jean : modif 3 June 93 */

  if(cur_index < 0  || cur_index >= me->nb_parts)
  {
     for(row = 0; row < me->nb_stat ; row++)
       for(col = 1; col < 4; col++)
         FIfld_set_text(me->forms[me->idx_form].form_ptr,G_DB_LIST,row,col,"",0);
     FIg_set_text(me->forms[me->idx_form].form_ptr,G_NUM_PART,"");
     *sts = OM_S_SUCCESS;
     goto quit;
  }

  part = &me->parts[cur_index];  /* this is the part to be displayed */


  FIg_set_value(me->form_sel_part,me->g_num_part,(double)(me->cur_part));
  sprintf(val_txt,"%d",me->cur_part);
  FIfld_set_default_text(me->form_sel_part,me->g_num_part,0,0,val_txt,FALSE);

  /* Ignore first attribute : family name */

  for(num_att = 1; num_att < part->nb_att; num_att++)
   {
     row = num_att -1;
     if(part->att[num_att].attr.desc.type == AC_ATTRIB_DOUBLE)
      {
        sprintf(val_txt,"%-9.6g",
                part->att[num_att].attr.desc.value.att_exp);
        FIfld_set_text(me->forms[me->idx_form].form_ptr,G_DB_LIST,row,1,val_txt,0);
      }
     else
      {
        FIfld_set_text(me->forms[me->idx_form].form_ptr,G_DB_LIST,row,1,
                       part->att[num_att].attr.desc.value.att_txt,0);

      }
   }

#ifdef	NOT_NEEDED_FOR_AVD

  /* Jean : Modif 16 June 93 . Convert expected_area and expected_vol
     to current unit      */

  if(cur_index >= 0 && cur_index < me->nb_parts) 
   {
     part = &me->parts[cur_index];

     /* Convert expected_area and expected_vol           */
     for(num_att = 1; num_att < part->nb_att; num_att++)
      {
	if(part->att[num_att].attr.desc.type == AC_ATTRIB_DOUBLE)
	 {
	   if(!strcmp(part->att[num_att].attr.name,"expected_area"))
	    {
	      SMConvSurfIntExt(part->att[num_att].attr.desc.value.att_exp,
			       &val_db,me->ModuleInfo.md_id.osnum);
	      sprintf(val_txt,"%-9.6g",val_db); 
	      FIfld_set_text(me->forms[me->idx_form].form_ptr,G_DB_LIST,num_att - 1,
			     1,val_txt,0);
	    }
	   
	   if(!strcmp(part->att[num_att].attr.name,"expected_vol"))
	    {
	      SMConvVolIntExt(part->att[num_att].attr.desc.value.att_exp,
			      &val_db,me->ModuleInfo.md_id.osnum);
	      sprintf(val_txt,"%-9.6g",val_db); 
	      FIfld_set_text(me->forms[me->idx_form].form_ptr,G_DB_LIST,num_att - 1,
			     1,val_txt,0);
	    }
	 }
      } 
   }
#endif

  /* If compartment tracking, disable "SET" gadget if already placed */
  if(me->compart_track && cur_index >= 0
     && cur_index < me->nb_parts && me->mytype == PLACE)
   {
     /* Retrieve family, partnum, partrev :   */
     /* it's suppose to be 3 first attributes */
     family  = me->parts[cur_index].att[0].attr.desc.value.att_txt;
     partnum = me->parts[cur_index].att[1].attr.desc.value.att_txt;
     partrev = me->parts[cur_index].att[2].attr.desc.value.att_txt;

     om$send(msg = message SMCmdComp.check_already_placed
	     (sts,family,partnum,partrev,&already_placed),
	     targetid = my_id);
     if(already_placed)
       FIg_disable(me->forms[me->idx_form].form_ptr,G_LOAD);
     else
       /* It was not found in db or current file, so enable set */
       FIg_enable(me->forms[me->idx_form].form_ptr,G_LOAD); 
   }

   status = OM_S_SUCCESS;
   End
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
	send SMCmdComp.fill_attr_from_part (fills me->save_att)

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

  SetProc ( VDLoadSelPart ); Begin
   *sts = OM_S_SUCCESS;

  /* Change Test Condition 6 June 93 */   
  /* Verify if one selected part exists */

  if(me->nb_parts == 0 || me->parts == NULL || me->cur_part <= 0 ||
     me->cur_part > me->nb_parts)
   {
     ex$message( msgnumb = SM_E_CmNoPartSel, buff = my_msg);
     FIg_set_text(me->forms[me->idx_form].form_ptr,FI_MSG_FIELD,my_msg);
     *sts = OM_E_ABORT; return OM_S_SUCCESS;
   }
  
  cur_index = me->cur_part - 1;
  me->save_nb_att = SM_MAX_CO_ATTR;

  om$send(msg = message SMCmdComp.fill_attr_from_part
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
   End
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

  SetProc ( fill_attr_from_part ); Begin
   *sts = OM_S_SUCCESS;

  me->save_nb_att = SM_MAX_CO_ATTR;
  if(!SMCompDynColl(nb_stat,stat_att,nb_dyn,dyn_att,
                    me->save_att,me->save_att_type,&me->save_nb_att))
    {
      printf("Erreur parsing attributes from Database\n");
      *sts = OM_E_ABORT;
      goto quit;
    }

   status = OM_S_SUCCESS;
   End
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
	- SMCmdComp.read_pdu_review (retrieve the selected part in PDU)
	- VDSget_attr (retrieve the attributes for this part)
	- send SMCmdComp.fill_attr_from_part (fills me->save_att)
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

   SetProc ( VDReadFromPdu ); Begin
   *sts = OM_S_SUCCESS;


   /* Retrieve selected part from pdu */

   om$send(msg = message SMCmdComp.read_pdu_review(sts,rev_partid,rev_revision),
	   targetid = my_id);
   if(!(*sts & 1)) { *sts = OM_E_ABORT; goto free_mem;}
   
   /* Number of allocate attribute */
   me->save_nb_att = SM_MAX_CO_ATTR;
   
   /* Retrieves attributes for this parts in database */
   if(!VDSget_attr(me->db_info.catalog,rev_partid,rev_revision,"",
		   &nb_stat,&stat_att,&nb_dyn,&dyn_att))
    { *sts = OM_E_ABORT; goto free_mem; }

     om$send(msg = message SMCmdComp.fill_attr_from_part
             (sts,nb_stat,stat_att,nb_dyn,dyn_att),
             targetid = my_id);
     if(!(*sts & 1))
      { printf("Error copy attributes\n"); *sts = OM_E_ABORT; goto free_mem; }


   strcpy(me->db_info.part_num,rev_partid);
   strcpy(me->db_info.revision,rev_revision);
   
   *sts = OM_S_SUCCESS; 

 free_mem:
   /* DEALLOC MEMORY */
   _FREE(stat_att);
   _FREE(dyn_att) ;

   status = OM_S_SUCCESS;
   End
   goto quit;

}
/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        VDQueryDb from VDCmdPart

  Abstract
	That method is called when the "search" button is pushed.
	Queries the database for all parts corresponding to the select 
	criteria . It fills the structure me->parts.

	It has been overriden because we don't need to manage multiple select 
	criteria for the compartment ( There is only one catalog and one select
        criteria based on the static attributes)

  Algorithm
	- send VDCmdPart.VDCstQuery (construct the query with me->name_att)
	- VDquery_parts (queries me->db_info.catalog) that fills me->parts.
	- if me->nb_part send VDCmdPart.VDPlaceDbAttInList (display the
	parts in the form).

  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/


action VDQueryDb 
{
  int               	row;
  struct query_attr 	*query = NULL;
  int             	nb_query = 0;
  char			my_msg[80];

  SetProc( VDqueryDb ); Begin
   *sts = OM_S_SUCCESS;

  if(me->nb_stat <= 0 || me->name_att == NULL) goto quit;
  if(me->parts != NULL)
   {
     VDfree_allocated_parts(me->nb_parts,me->parts,&me->dyn_att);
     me->parts = NULL;
     me->nb_parts = 0;
   }


 /* construct the query list, ie get in the form the attributes that has */
 /* been given a value by the user (col 3 not empty)                     */

 om$send(msg = message VDCmdPart.VDCstQuery(sts, me->nb_stat, me->name_att,
                                        &nb_query, &query),
             targetid = my_id);
 if(!(*sts) & 1){printf("Error VDCstQuery \n"); goto quit;}


  /* Made query */

  if(!VDquery_parts(me->db_info.catalog,
                    me->nb_stat,me->name_att,nb_query,query,me->units_set_exists,
                    &me->nb_parts,&me->parts,&me->dyn_att))
   {
     me->nb_parts = 0;
     me->parts = NULL;
   }

  /* Put attribute of last part found in form */

  if(me->nb_parts == 0 || me->parts == NULL)
   {
     ex$message(msgnumb = SM_E_CmNoPartFound, buff = my_msg);
     FIg_set_text(me->form_sel_part,FI_MSG_FIELD,my_msg);
     FIg_set_value(me->form_sel_part,me->g_num_part,0.0);
     for(row = 0; row < me->nb_stat - 1; row++)
       FIfld_set_text(me->form_sel_part,me->g_db_list,row,1,"",FALSE);
   }
  else
   {
     me->cur_part = me->nb_parts;
     om$send(msg = message VDCmdPart.VDPlaceDbAttInList(sts),
             targetid = my_id);
   }

/* Free before reallocating */

   _FREE(query);

   *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   End
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
  int    row;

  SetProc ( VDLoadDbAttr ); Begin
   *sts = OM_S_SUCCESS;

/* COMMENTED. MALLIK 10/1/96 
  om$send(msg = message VDCmdPart.VDLoadDbAttr(sts),
             targetid = my_id,
             mode     = OM_e_wrt_message);
*/
/* This part of the code copied from VDCmdParti.I */

  if ( me->name_att == NULL )
  {
    me->nb_stat = 0;
    if ( !VDquery_att_name ( me->db_info.catalog, &me->nb_stat, &me->name_att,
                             &me->units_set_exists ) )
    {
      goto wrapup;
    }
  }

  /*
   * Put attribute name in form : ignore first attribute (family name)
   */
  for ( row = 0; row < me->nb_stat - 1; row++ )
  {
    FIfld_set_text ( me->forms[me->idx_form].form_ptr, me->g_db_list, row, 0,
                     me->name_att[row + 1].attr_syn, 0 );
  }

  FIfld_set_num_rows     ( me->forms[me->idx_form].form_ptr, me->g_db_list, me->nb_stat - 1 );
  FIfld_set_max_num_rows ( me->forms[me->idx_form].form_ptr, me->g_db_list, me->nb_stat - 1);

  om$send ( msg      = message VDCmdPart.VDPlaceDbAttInList ( sts ),
            targetid = my_id );

/* END Copied */

  FIg_enable(me->forms[me->idx_form].form_ptr,GROUP_SELECT);

wrapup:
  *sts = OM_S_SUCCESS;
   status = OM_S_SUCCESS;
   End
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

  SetProc ( VDSetRgAtt ); Begin
   *sts = OM_S_SUCCESS;

  if(me->static_att){free(me->static_att); me->static_att = NULL;}
  if(me->dynamic_att){free(me->dynamic_att); me->dynamic_att = NULL;}


  me->static_att = _MALLOC( me->work_nb_att, struct ACrg_coll );
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
   End
   goto quit;

 
  wrapup:

  _FREE(me->static_att);
  _FREE(me->dynamic_att);
  *sts = OM_E_ABORT;
  End

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

   SetProc ( VDSaveListDyn ); Begin
   *sts = OM_S_SUCCESS;

  my_message[0] = '\0';

  memcpy(buf_att,me->work_att, me->work_nb_att * sizeof(struct ACrg_coll));
  memcpy(buf_att_type,me->work_att_type, me->work_nb_att * sizeof(IGRshort));
  buf_nb_att =  me->work_nb_att;
    
  /* Retrieves the value of each attributes keyin in form */

  FIfld_get_num_rows(me->forms[me->idx_form].form_ptr,G_ATT_LIST,&num_rows);
  
  for(row=0; row < num_rows; row++)
   {
     name[0] = val_txt[0] = type_txt[0] = '\0';
     
     FIfld_get_text(me->forms[me->idx_form].form_ptr,G_ATT_LIST,row,GI_NAME,ATTR_TXT,
		    name,&sel,&pos);
     
     FIfld_get_text(me->forms[me->idx_form].form_ptr,G_ATT_LIST,row,GI_VAL,ATTR_TXT,
		    val_txt,&sel,&pos);
     
     FIfld_get_text(me->forms[me->idx_form].form_ptr,G_ATT_LIST,row,GI_TYPE,ATTR_TXT,
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
     if(SMGetAttr(name,me->work_att,me->work_att_type,me->work_nb_att,
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
	!SMget_double(me->forms[me->idx_form].form_ptr,G_ATT_LIST,row,GI_VAL,&val_db))
      {
	ex$message(msgnumb = SM_E_CmBadValAttr, buff = my_message,
		   type = "%s",var = `name`); 
	*sts = OM_E_ABORT;
	goto quit;
      }

     if(!SMSetAttr(name, buf_att,buf_att_type,&buf_nb_att,
		   type, val_db, val_txt, sm_type, SM_MAX_CO_ATTR )){
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
	FIfld_get_text(me->forms[me->idx_form].form_ptr,G_ATT_LIST,row,GI_NAME,ATTR_TXT,
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
   End
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
  
  SetProc ( VDSelectTog ); Begin
   *sts = OM_S_SUCCESS;

  FIg_get_state(me->forms[me->idx_form].form_ptr,G_STATIC_TOG,&state);

  /* state = FALSE means STATIC ; state = TRUE means dynamic */

  me->form_state = state ?  DYN_LIST : STAT_LIST;
  type = me->form_state == DYN_LIST ? 1 : 0;
  
  if(me->old_form_state == DYN_LIST && me->form_state == STAT_LIST)
   {
     om$send(msg = message SMCmdComp.VDSaveListDyn(sts, my_msg),
	     targetid = my_id);
     /* If fails redisplay  dynamic attributes */
     if(!(*sts & 1))
      {
	FIg_set_text(me->forms[me->idx_form].form_ptr,FI_MSG_FIELD,my_msg);
	FIg_set_state_off(me->forms[me->idx_form].form_ptr,G_STATIC_TOG);
	me->form_state = DYN_LIST;
	goto quit;
      }
   }
 
  if(me->form_state == DYN_LIST)
    FIg_enable(me->forms[me->idx_form].form_ptr,G_DEL_ATT);
  else
    FIg_disable(me->forms[me->idx_form].form_ptr,G_DEL_ATT);
  FIg_set_state_off(me->forms[me->idx_form].form_ptr,G_DEL_ATT);

  om$send(msg = message SMCmdComp.VDSetRgAtt(sts),
	     targetid = my_id);

  om$send(msg = message SMCmdComp.VDSetAttList(sts, type),targetid = my_id);
  
  FIg_display(me->forms[me->idx_form].form_ptr,G_ATT_LIST);


  *sts = OM_S_SUCCESS;

   status = OM_S_SUCCESS;
   End
   goto quit;
}

action local_display_form
{
  FIf_display(me->forms[me->idx_form].form_ptr);
  *sts = OM_S_SUCCESS;

   status = OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message set_2150_flag

  Abstract
	Set me->b2150AttSet to TRUE
	This means that S2150 attributes corresponding to the currently
	active compartment have been set in the Command Object instance
	data.

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always

 -------------------------------------------------------------------------
-me*/
action set_2150_flag
{
  SetProc ( set_2150_flag ); Begin
  *sts = OM_S_SUCCESS;

  me->b2150AttSet = TRUE;

  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  End
  goto quit;
}
