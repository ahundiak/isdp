/* $Id: SMCmdVolBnd.sl,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/cmd / SMCmdVolBnd.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdVolBnd.sl,v $
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
# Revision 1.2  1996/02/16  06:44:46  pinnacle
# Replaced: smspace/cmd/SMCmdVolBnd.sl for:  by svkadamb for vds.240
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

/*    File          SMCmdVolBnd.sl
      Description   Command object to place a bounded Volume
      Auteur        Pascale Lacroix (ISDC) 
      Date          July-92     
*/

command_string       SMC_M_PlBndVol,0,SMPlBndVol
synonym		     SMC_M_MdBndVol,1,SMMdBndVol
command_table        "sman.cmd"
class                SMCmdVolBnd
super_class          VDS_LOCATE
product_name         "$VDS"

form "SMBoundSf",0,0,"-1","-1"

specification


#include "OMmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"

#include "csmacros.h"

#include "dp.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "griodef.h" 
#include "griomacros.h"
#include "grdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "coparamac.h"
#include "growner.h"


#include "SMmsg.h"
#include "SMCmdBnd.h"


#define MAX_SURF 	50
#define MAX_TEMP	51 	/* number of templates */


instance 
{
int			nb_objects;	/* input located objects*/
struct GRlc_info 	objects[MAX_SURF];
int			ordered;
char			infinite[MAX_SURF];
char			def_name[MAX_CHAR];
struct GRmd_env		act_env;
int			select_row;
int			old_nb_objects;	
int			old_ordered;
char			old_def_name[MAX_CHAR];
struct GRlc_info 	old_objects[MAX_SURF];
char			old_infinite[MAX_SURF];
struct	sup		*dup;  /* template def (init at reinit_form) */
int			num_vis_row;
int			pos;
struct GRid		macro_id;
struct GRid		old_macro_id;

int			old_track;
int			Track;
struct GRlc_info	track_elt;
struct GRlc_info	oldtrack_elt;
IGRboolean		Fence;
struct GRobj_env  	*FenceObjects;
int			nb_FenceObjects;
int			IndexFcObj;
int			delete_elt;
int			delete_row;

}

implementation
#include "AS_status.h"

#define PLACE    	0
#define MODIFY		1

#define AS_DEBUG	1

#define SEVERE_ERROR    4
#define END_TEMP 	509
#define LOAD_OCC 	511
#define NO_OBJ 		513
#define TOO_FENCE 	515
#define MD_FENCE 	517
#define LOAD_TRACK 	519
#define RESTART 	521
#define LOAD_FORM 	523
#define DEL_ELT 	525

%safe

	static int 	x_memo = -1,
			y_memo = -1;
%endsafe			


/*************************************************************************/

state_table

#include "VDSFilter.h"
#include "SMmsg.h"

#define PLACE    	0
#define MODIFY		1

#define AS_DEBUG	1

#define SEVERE_ERROR    4
#define END_TEMP 	509
#define LOAD_OCC 	511
#define NO_OBJ 		513
#define TOO_FENCE 	515
#define MD_FENCE 	517
#define LOAD_TRACK 	519
#define RESTART 	521
#define LOAD_FORM 	523
#define DEL_ELT 	525


state start

  on CMD_TYPE = PLACE	do reinit_form 
                       on ERROR do status_key SM_E_ErInit state terminate
                        do display_form  0

  				state modif_form 
  on CMD_TYPE = MODIFY	state loc_macro
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_FORM state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC  	do reset_all state load_from_occ

state restart

  on CMD_TYPE = PLACE	state modif_form 
  on CMD_TYPE = MODIFY	do reset_all state reloc_macro

  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_FORM state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC  	do reset_all state load_from_occ
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt

state loc_macro
  prompt_key         SM_P_IdBndVol
  accept_key         SM_P_PlAccRej
  locate_class	     "SMVolBnd"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID  do reset_all
				       do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
		       do display_form  0
				state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_FORM state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC  	do reset_all state load_from_occ

state reloc_macro
  prompt_key	     SM_P_IdBndVol
  accept_key         SM_P_PlAccRej
  locate_class	     "SMVolBnd"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
				state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_FORM state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC  	do reset_all state load_from_occ

state  modif_form 
  prompt_key         SM_P_IdHlgTmp
  accept_key         SM_P_PlAccRej
  locate_class	     "EMSsurface "
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"
  filter              vds_locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID  
  		do store_obj
			on RETURN_CODE = NO_OBJ 
				do status_key SM_S_NoObjFc  state .
			on RETURN_CODE = TOO_FENCE 
				do status_key SM_S_OneFc  state .
                       	on ERROR state terminate
			on RETURN_CODE = MD_FENCE 
				do status_key SM_S_NoFcMd  state .
		do next_row 
                        on RETURN_CODE = END_TEMP do save_all 
							state restart
		state .
			
  on EX_RJT_MOVEON	do next_row	
                        	on RETURN_CODE = END_TEMP do save_all 
							state restart
                        state .                 
  on EX_FORM_FINISHED     	state terminate
  
  on GR_UNKNOWN_TYPE.LOAD_OCC  	do reset_all state load_from_occ

  on GR_UNKNOWN_TYPE.LOAD_TRACK	state load_track
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_FORM state modif_form
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt

			    
state load_track
  prompt_key	     SM_P_IdTrcPt
  accept_key         SM_P_PlAccRej
  locate_class	     "GRpoint"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID 
			do store_track 		state modif_form

  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_FORM state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC  	do reset_all state load_from_occ
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on EX_BACK_UP state -
  
state  del_elt
  prompt_key          SM_P_SelEltDsc
  filter	      get_event

  on EX_FORM_FINISHED     	state terminate
  
  
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_FORM state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC  	do reset_all state load_from_occ
  on GR_UNKNOWN_TYPE.DEL_ELT state modif_form

state load_from_occ
  prompt_key         SM_P_IdBndVol
  accept_key         SM_P_PlAccRej
  locate_class	     "SMVolBnd"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID 
			do store_occ state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC  	do reset_all state load_from_occ
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_FORM state modif_form
				
at init   do init_all
at wakeup do verify_obj
	  do DispAll
at delete do delete_all

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in SMBndNotif.I                                           */

action form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr ) extern

action DispLoc(int index; enum GRdpmode mode) extern
action DispAll extern

action store_obj extern

action next_row extern

action reinit_form extern
action store_occ extern

action save_all extern
action reset_all extern
action store_track extern
action verify_obj extern
action delete_elt extern

/* ====================== init_all =============================
  
	This action init instances
  
============================================================= */
action init_all
/*.init_all*/
 {
 int			i;
 IGRlong		msg, sizebuf, nret;
 int			flag = FALSE;

   /*| get current module env */

	*sts = OM_S_SUCCESS;
    	dp$erase_hilite(msg = &msg);
   	sizebuf = sizeof(struct GRmd_env);
    	gr$get_module_env(msg     = &msg,
                      sizbuf  = &sizebuf,
                      buffer  = &me->act_env,
                      nret    = &nret);

	me->macro_id.objid = NULL_OBJID;
	me->old_macro_id.objid = NULL_OBJID;
	me->select_row = 0;
	me->pos = 0;
	me->dup = NULL;
	me->old_nb_objects = 0;
	me->nb_objects = 0;
        me->def_name[0] = '\0';
	me->ordered =0;
	me->old_ordered =0;
        me->old_def_name[0] = '\0';
  	me->delete_elt = 0;
  	me->delete_row = 0;

	me->Fence = FALSE;
	me->FenceObjects = NULL;
	me->nb_FenceObjects = 0;
	me->IndexFcObj = -1;


	me->old_track = 0;
	me->Track = 0;
	me->track_elt.located_obj.objid = NULL_OBJID;
	me->oldtrack_elt.located_obj.objid = NULL_OBJID;
        FIfld_set_text(me->forms[0].form_ptr,TRACK_F,0,0,
					"No Track Element",flag);


        if(x_memo != -1 || y_memo != -1)
                FIf_set_location(me->forms[0].form_ptr,x_memo,y_memo);

	for(i=0;i<MAX_SURF;i++) {
		me->old_infinite[i] = 'Y';	   	
		me->infinite[i] = 'Y';	
		me->objects[i].located_obj.objid = NULL_OBJID;
		me->old_objects[i].located_obj.objid = NULL_OBJID;
	} 
        FIfld_get_num_vis_rows(me->forms[0].form_ptr,INFINITE, 
        &me->num_vis_row);

	if(me->mytype == MODIFY) {
	  ex$message( msgnumb = SM_M_MdBndVol );
	  FIg_set_text(me->forms[0].form_ptr,F_TITLE, "Modify Bounded Volume");
	}
	else{
	  ex$message( msgnumb = SM_M_PlBndVol );
	  FIg_set_text(me->forms[0].form_ptr,F_TITLE, "Place Bounded Volume");
	}
	FIg_erase(me->forms[0].form_ptr,OFFSET);
	FIg_erase(me->forms[0].form_ptr,OFFSET_NAME);
	FIg_erase(me->forms[0].form_ptr, ORIENT);
	FIg_erase(me->forms[0].form_ptr, ORIENT_NAME);

 return status;
}

/* ====================== delete_all =============================
  
	This action delete memory
  
============================================================= */
action delete_all
/*.delete_all*/
{
 IGRlong		msg;
	
 *sts = OM_S_SUCCESS;

 dp$erase_hilite(msg = &msg);

 if(me->FenceObjects != NULL){free(me->FenceObjects);me->FenceObjects = NULL;}

 if ( me->forms[0].form_ptr != NULL )
     FIf_get_location(me->forms[0].form_ptr,&x_memo,&y_memo);

 return status;
}
