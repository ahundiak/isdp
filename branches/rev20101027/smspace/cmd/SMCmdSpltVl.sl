/* $Id: SMCmdSpltVl.sl,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/cmd / SMCmdSpltVl.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdSpltVl.sl,v $
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
# Revision 1.2  1995/09/26  20:20:28  pinnacle
# Replaced: smspace/cmd/SMCmdSpltVl.sl for:  by sundar for vds.240
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

/*    File          SMCmdSpltVl.sl
      Description   Command object to place a bounded Volume (or volume)
      		    resulting of splitting and save side operations.
      Auteur        Pascale Lacroix (ISDC) 
      Date          Oct-92     
*/

command_string       SMC_M_PlSplVl,0,SMPlSpVl
synonym		     SMC_M_MdSplVl,1,SMMdSpVl
command_table        "sman.cmd"
class                SMCmdSpltVl
super_class          SMCmdVol
product_name         "$VDS"

form "SMSplitVol",0,0,"-1","-1"

specification


#include "OMmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"

#include "dpmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "coparamac.h"
#include "growner.h"
#include "SMmsg.h"

#include "FI.h"

#include "SMspacecom.h"


#define MAX_SURF 	14
#define MAX_TEMP	15 	/* number of templates */


instance 
{

struct sfinfo 		floor;
struct sfinfo 		ceiling;
int			floor_ceil;


struct sfinfo 		old_floor;
struct sfinfo 		old_ceiling;
int			old_floor_ceil;
}

implementation

#include "msdef.h"
#include "msmacros.h"
#include "AS_status.h"



/*************************************************************************/

state_table

#include "SMmsg.h"
#include "VDSFilter.h"
#include "SMspacecom.h"

#define MAX_SURF 	14
#define MAX_TEMP	15 	/* number of templates */

state start

  on CMD_TYPE = PLACE	do message_key SM_M_PlSplVl
			do reset_form 
                       		on ERROR do status_key SM_E_ErInit state terminate
                        do display_form  0

  				state modif_form 
  				
  on CMD_TYPE = MODIFY	do message_key SM_M_MdSplVl state loc_macro
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

state restart

  on CMD_TYPE = PLACE	state modif_form
  				
  on CMD_TYPE = MODIFY	do clear_form state reloc_macro

  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  
state loc_macro
  prompt_key         SM_P_IdSplVl
  accept_key         SM_P_PlAccRej
  locate_class	     "SMVolBySplt"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID  do clear_form
				       do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
		       do display_form  0
				state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

state reloc_macro
  prompt_key 	     SM_P_IdSplVl
  accept_key         SM_P_PlAccRej
  locate_class	     "SMVolBySplt"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID  do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
				state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

state  modif_form 
  prompt_key 	     SM_P_IdHltTmp 
  accept_key         SM_P_PlAccRej
  locate_class	     "EMSsolid,EMSsurface"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"
  filter              vds_locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID  
  		do store_obj(&me->ret, MAX_SURF)
			on RETURN_CODE = NO_OBJ 
				do status_key SM_S_NoObjFc  state .
			on RETURN_CODE = TOO_FENCE 
				do status_key SM_S_OneFc  state .
                       	on ERROR state terminate
			on RETURN_CODE = MD_FENCE 
				do status_key SM_S_NoFcMd  state .
			do display_normal
			state get_normal
			
  on EX_RJT_MOVEON	do next_row	
                       		on ERROR state terminate
	                   	on RETURN_CODE = LOAD_CEILING	state load_ceil
                        	on RETURN_CODE = END_TEMP do save_all 
								state restart
                        state .                 
  on EX_FORM_FINISHED     	state terminate
  
  
  on GR_UNKNOWN_TYPE.LOAD_FLOOR	state load_floor

  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form

state load_floor
  prompt_key         SM_P_IdFloor
  accept_key         SM_P_PlAccRej
  locate_class       "EMSsurface"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID
                        do store_floor  
                       		on ERROR state terminate
				on RETURN_CODE = NO_OBJ 
				do status_key SM_S_NoObjFc  state .
				on RETURN_CODE = TOO_FENCE 
				do status_key SM_S_OneFc  state .
				on RETURN_CODE = MD_FENCE 
				do status_key SM_S_NoFcMd  state .
			do display_normal
                        state get_normal

  on GR_UNKNOWN_TYPE.RESTART  state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on EX_BACK_UP	state modif_form
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

state load_ceil
  prompt_key 	     SM_P_IdCeil
  accept_key         SM_P_PlAccRej
  locate_class       "EMSsurface"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID
                        do store_ceiling  
                       		on ERROR state terminate
				on RETURN_CODE = NO_OBJ 
				do status_key SM_S_NoObjFc  state .
				on RETURN_CODE = TOO_FENCE 
				do status_key SM_S_OneFc  state .
				on RETURN_CODE = MD_FENCE 
				do status_key SM_S_NoFcMd  state .

			do display_normal
                        state get_normal

  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ




state  get_normal
  prompt_key          SM_P_IsOrGood
  execute	      GadgOf
  filter              get_event

  on EX_STRING  do GadgOn 
  		do store_orient 
		do next_row 
		           on RETURN_CODE = END_TEMP do save_all 
	                   on RETURN_CODE = LOAD_CEILING	state load_ceil
						state restart
		state modif_form
			
  on EX_DATA		do GadgOn
			do accept_orient
                       		on ERROR state terminate
			do next_row 
                       		on ERROR state terminate
	                   	on RETURN_CODE = LOAD_CEILING	state load_ceil
                        	on RETURN_CODE = END_TEMP do save_all 
                        			state restart
			state modif_form

  on EX_RJT_MOVEON 	do GadgOn
			do reverse_orient
                       		on ERROR state terminate
			do next_row 
                       		on ERROR state terminate
                        	on RETURN_CODE = END_TEMP do save_all 
	                   	on RETURN_CODE = LOAD_CEILING	state load_ceil
                        			state restart
			state modif_form
  
  on GR_UNKNOWN_TYPE.LOAD_OCC   do GadgOn
				do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

  on EX_FORM_FINISHED     state terminate
  
  on GR_UNKNOWN_TYPE.RESTART do GadgOn state restart
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form

		    

state  del_elt
  prompt_key	      SM_P_SelEltDsc
  filter	      get_event

  on EX_FORM_FINISHED     	state terminate
  
  
  on GR_UNKNOWN_TYPE.LOAD_OCC   do GadgOn
				do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

  on EX_FORM_FINISHED     state terminate
  
  on GR_UNKNOWN_TYPE.RESTART do GadgOn state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.DEL_ELT state modif_form


state load_from_occ
  prompt_key         SM_P_LcMacOc
  accept_key         SM_P_PlAccRej
  locate_class	     "SMVolBySplt"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID 
			do store_occ 
                       		on ERROR state terminate
			state modif_form
				
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  

at init   do init_all
at wakeup do verify_obj
	  do DispAll
at delete do delete_all

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in SMSplVNotif.I                                           */


action store_obj(long *sts; int max_obj) extern
action verify_obj extern
action store_floor extern
action store_ceiling extern
action display_normal extern
action store_orient extern
action reverse_orient extern
action accept_orient extern
action GadgOn extern
action GadgOf extern
action DispAll extern
action DispLoc(int index; enum GRdpmode mode) extern
action store_occ extern
action reset_form extern
action clear_form extern
action save_all extern
action delete_elt extern
action SMmodif_mac(unsigned int	VMask;int nb_new; struct GRid *new) extern


/* ====================== init_all =============================
  
	This action init instances
  
============================================================= */
action init_all
/*.init_all*/
{

 status = om$send(msg = message SMCmdVol.init_all(sts),
			mode = OM_e_wrt_message,
		      	targetid = my_id);

 strcpy(me->macro_name,"SMVolBySplt");
 strcpy(me->auto_name,"SMVolBySplt_0");

 me->nb_col_limits = 3;

 me->floor.surf.located_obj.objid 	= NULL_OBJID;
 me->old_floor.surf.located_obj.objid 	= NULL_OBJID;

 me->floor.rev 		= 0;
 me->old_floor.rev	= 0;

 me->ceiling.surf.located_obj.objid 	= NULL_OBJID;
 me->old_ceiling.surf.located_obj.objid = NULL_OBJID;

 me->ceiling.rev 	= 0;
 me->old_ceiling.rev 	= 0;

 me->floor_ceil 	= 0;
 me->old_floor_ceil 	= 0;

 if(me->mytype == MODIFY) 
     FIg_set_text(me->forms[0].form_ptr,F_TITLE,"Modify Split Volume");


status = OM_S_SUCCESS;
goto quit;

}

/* ----------------------------------------------------------------- */ 

action form_notification (int form_label; int gadget_label ; double value ;
			    char * form_ptr)
{
 int 			i, stat = OM_S_SUCCESS;
 int  			mylabel, sel_flag, r_pos, num_rows;
 int  			pos, col, row, num_char = MY_MAX_CHAR;
 long			test;
 char 			text[MY_MAX_CHAR];


 if ( form_ptr == NULL ){
     		/*| no form_ptr set */
     		return( OM_E_INVARG ); 
 }
  
 FIg_set_text(form_ptr,FI_MSG_FIELD,"");
 UI_message("");

 switch( gadget_label ){
   
 	case FI_ACCEPT:
 	case FI_EXECUTE:
      
 	case FI_CANCEL: 
      
 	case FI_RESET:
    
   	case INFINITE:

		status = om$send(msg = message SMCmdVol.form_notification(
				form_label, gadget_label,value, form_ptr),
                        mode = OM_e_wrt_message,
                        targetid = my_id);
 		if(!(status & 1)){
			printf("ERROR form_notification \n");
 			return status;
 		}
    		
     		break;
     
   	case LOAD:
		
		if(me->mytype == MODIFY){
			UI_prompt("");
                	stat = om$send(msg = message SMCmdSpltVl.delete_elt(&test),
                                targetid = my_id);

        		if(!(stat & test & 1)){ 
 				ex$message(msgnumb = SM_S_ErrDel);
 				goto quit;
        		} 
                	_put_response(resp = DEL_ELT);
			break;
		}
     		else _put_response(resp = LOAD_OCC);
    		break;
    
   	case OCC_NAME:

   		FIfld_get_text(form_ptr,OCC_NAME,0, 0,
                       		num_char, text,&sel_flag,&r_pos);
 		(void)GetDefName(text,me->def_name);
 		FIg_set_text(form_ptr,OCC_NAME,me->def_name);
                if( me->state == _get_normal)
 			ex$message(msgnumb = SM_S_AreaNeed);
   		
    		break;
        
   	case FLOOR_B:
                	if( me->state == _get_normal){
                         	ex$message(msgnumb = SM_S_AreaNeed);
				break;
                	}
                	if(me->state == _load_ceil){
                         	ex$message(msgnumb = SM_S_CeilNeed);
				break;
                	}
			if(me->floor_ceil == 0) {
				FIfld_set_text(form_ptr, FLOOR_F, 0, 0, 
							    "floor", TRUE);
				FIfld_set_text(form_ptr, FLOOR_F, 0, 1, 
							    "not defined", TRUE);

				FIfld_set_text(form_ptr, FLOOR_F, 0, 2, 
							    "", TRUE);

				FIfld_set_text(form_ptr, FLOOR_F, 1, 0, 
							    "ceiling", FALSE);
				FIfld_set_text(form_ptr, FLOOR_F, 1, 1, 
							    "not defined", FALSE);
				FIfld_set_text(form_ptr, FLOOR_F, 1, 2, 
							    "", FALSE);
				for(i=0;i<3;i++)
                        	 	FIfld_set_select(form_ptr,LIMITS, 
						me->select_row,i, FALSE);
				me->select_row = -2;
                        	FIfld_set_active_row(form_ptr,FLOOR_F, me->select_row, me->pos);

				_put_response(resp = LOAD_FLOOR);
				break;
			}
			else {
				me->floor_ceil = 0;
				dp$erase_hilite(msg = &test);		
		
     				stat = om$send(msg = message SMCmdSpltVl.DispLoc(
     						-2, GRhe),
                        		targetid= my_id ) ;
     				stat = om$send(msg = message SMCmdSpltVl.DispLoc(
     						-1, GRhe),
                        		targetid= my_id ) ;
				
        			if(!(stat & 1)){ 
 					ex$message(msgnumb = SM_S_ErFlCeil);
 					goto quit;
        			} 
 				stat = FIfld_get_num_rows(
 				   me->forms[0].form_ptr,FLOOR_F, &num_rows);
 				if(stat != FI_SUCCESS) {
					printf("error FIfld_get_num_rows: %d\n",stat);
					goto quit;
 				}
 				if(num_rows){
 					stat = FIfld_delete_rows(
 						me->forms[0].form_ptr,FLOOR_F, 
 						0,num_rows);
					if(stat != FI_SUCCESS){
						printf("error FIfld_delete_rows: %d\n",stat);
						goto quit;
					}
 				}
				if(me->Fence == TRUE && 
					(me->IndexFcObj == -2 || me->IndexFcObj == -1))

					me->Fence = FALSE;
 				me->floor.surf.located_obj.objid = NULL_OBJID;
 				me->ceiling.surf.located_obj.objid = NULL_OBJID;
 				me->floor.rev = 0;
 				me->ceiling.rev = 0;
 				
  				_put_response(resp = MODIF_FORM);

                       	}
   		
    		break;

	case FLOOR_F:

                if( (me->state == _load_ceil && me->ceiling.surf.located_obj.objid == NULL_OBJID ) 
		 ||(me->state == _load_floor && me->floor.surf.located_obj.objid == NULL_OBJID) || 
		   me->state == _get_normal){

     			FIfld_get_active_row(form_ptr,FLOOR_F, &row, &pos);
			for(i=0;i<3;i++)
                        	FIfld_set_select(form_ptr,FLOOR_F, row,i, FALSE);
		   	if(me->select_row == -2 || me->select_row == -1){
		   		row = me->select_row + 2;
                        	for(i=0;i<3;i++) 
					FIfld_set_select(form_ptr,FLOOR_F, row,
							i, TRUE);
                       		FIfld_set_active_row(form_ptr,FLOOR_F, row, 
							me->pos);
			}
		   	else {
				row = me->select_row;
                        	for(i=0;i<3;i++) 
					FIfld_set_select(form_ptr,LIMITS, row,
							i, TRUE);
                       		FIfld_set_active_row(form_ptr,LIMITS, row, 
								me->pos);
			}
                        if(me->state == _load_ceil) 
                        	{ex$message(msgnumb = SM_S_CeilNeed);}
                        else if(me->state == _load_floor) 
                        	{ex$message(msgnumb = SM_S_FlooNeed);}
                        else 	{ex$message(msgnumb = SM_S_OrNeed);}
                        break;
                }
      		if(me->delete_elt ){
			for(i=0;i<3;i++){
                           FIfld_set_select(form_ptr,FLOOR_F, 0,i, FALSE);
                           FIfld_set_select(form_ptr,FLOOR_F, 1,i, FALSE);
			}
			
 			FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
					"Must be disconnected with Floor/Ceil button");
			break;
			
		}
		if(me->floor_ceil == 0) {
			for(i=0;i<3;i++){
                           FIfld_set_select(form_ptr,FLOOR_F, 0,i, FALSE);
                           FIfld_set_select(form_ptr,FLOOR_F, 1,i, FALSE);
			}
			break;
			
		}
		if(me->select_row < 0){
			row = me->select_row + 2;
			mylabel = FLOOR_F;
		}
		else {
			row = me->select_row ;
			mylabel = LIMITS;
		}
		for(i=0;i<3;i++)
                        FIfld_set_select(form_ptr,mylabel, row,i, FALSE);
     		FImcf_get_active_col(  form_ptr,FLOOR_F, &col, &pos); 
     		FIfld_get_active_row(form_ptr,FLOOR_F, &row, &pos);
     		FIfld_get_select(form_ptr,FLOOR_F,row, col,&sel_flag);

        	me->select_row = row -2;

     		if(sel_flag == TRUE){
        		stat = om$send(msg = message SMCmdSpltVl.display_normal(&test),
 		      	targetid = my_id);
        		stat = om$send(msg = message SMCmdSpltVl.DispAll
        						(&test),
 		      			targetid = my_id);
        		if(!(stat & test & 1)){ 
 					ex$message(msgnumb = SM_S_ErrDsp);
 					goto quit;
        		} 
        		break;
     		}
  		_put_response(resp = MODIF_FORM);

		break;
    		
   	case LIMITS:
      
                if( (me->state == _load_ceil && me->ceiling.surf.located_obj.objid == NULL_OBJID ) 
		 ||(me->state == _load_floor && me->floor.surf.located_obj.objid == NULL_OBJID) || 
		   me->state == _get_normal){
     			FIfld_get_active_row(form_ptr,LIMITS, &row, &pos);
			for(i=0;i<3;i++)
                        	FIfld_set_select(form_ptr,LIMITS, row,i, FALSE);
		   	if(me->select_row == -2 || me->select_row == -1){
		   		row = me->select_row + 2;
                        	for(i=0;i<3;i++) 
					FIfld_set_select(form_ptr,FLOOR_F, row,
							i, TRUE);
                       		FIfld_set_active_row(form_ptr,FLOOR_F, row, 
							me->pos);
			}
		   	else {
				row = me->select_row;
                        	for(i=0;i<3;i++) 
					FIfld_set_select(form_ptr,LIMITS, row,
							i, TRUE);
                       		FIfld_set_active_row(form_ptr,LIMITS, row, 
								me->pos);
			}
                        if(me->state == _load_ceil) 
                        	{ex$message(msgnumb = SM_S_CeilNeed);}
                        else if(me->state == _load_floor) 
                        	{ex$message(msgnumb = SM_S_FlooNeed);}
                        else 	{ex$message(msgnumb = SM_S_OrNeed);}
                        break;
                }
		if(me->select_row < 0){
			row = me->select_row + 2;
			for(i=0;i<3;i++)
                          FIfld_set_select(form_ptr,FLOOR_F, row,i, FALSE);
		}

     		stat = FIfld_get_num_rows(form_ptr,LIMITS, &num_rows);
     		if(stat != FI_SUCCESS) {
			printf("error FIfld_get_num_rows\n");
			goto quit;
     		}
     		FImcf_get_active_col(  form_ptr,LIMITS, &col, &pos); 
     		FIfld_get_active_row(form_ptr,LIMITS, &row, &pos);
     		FIfld_get_select(form_ptr,LIMITS,row, 0,&sel_flag);

      		if(me->delete_elt ){

			/* get the row to be deleted */
			me->delete_row = (sel_flag == TRUE) ? row : -1;
     			if(sel_flag == TRUE){
				me->select_row = row;
        			stat = om$send(msg = message SMCmdSpltVl.DispAll
        						(&test),
 		      			targetid = my_id);
        			if(!(stat & test & 1)){ 
 					ex$message(msgnumb = SM_S_ErrDsp);
 					goto quit;
        			} 
				me->select_row = 0;
 				FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
					"Valid with disconnect button");
				break;
				
     			}
 			FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
				"Select the Elt to be disconnected");
			break;
		}
     
        	me->select_row = row;
        	me->last_row = row;
		me->pos = pos;
     		FIfld_get_select(form_ptr,LIMITS,me->select_row, 
     						0,&sel_flag);
     		if(sel_flag == TRUE){
        		stat = om$send(msg = message SMCmdSpltVl.display_normal(&test),
 		      	targetid = my_id);
        		stat = om$send(msg = message SMCmdSpltVl.DispAll
        						(&test),
 		      			targetid = my_id);
        		if(!(stat & test & 1)){ 
 					ex$message(msgnumb = SM_S_ErrDsp);
 					goto quit;
        		} 
        		break;
     		}
  		_put_response(resp = MODIF_FORM);
     		break;
     

} /* END switch ( gadget_label ) */
  
  
  return OM_S_SUCCESS;
}
/* ----------------------------------------------------------------- */ 

action next_row
{
 int	i;
 long	test;
 
 *sts = OM_S_SUCCESS;

 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

 if(me->select_row < 0){
	if(me->select_row == -2){
		me->select_row ++;
		me->pos ++;
		for(i=0;i< 3; i++)
 			FIfld_set_select(me->forms[0].form_ptr, FLOOR_F,
  					1, i, TRUE);

 			FIfld_set_active_row(me->forms[0].form_ptr, FLOOR_F,
   					1, me->pos);
	}
	else{
		me->select_row = me->last_row;
		me->pos ++;
		for(i=0;i< 3; i++)
 			FIfld_set_select(me->forms[0].form_ptr, FLOOR_F,
  					1, i, FALSE);
		for(i=0;i< 3; i++)
 			FIfld_set_select(me->forms[0].form_ptr, LIMITS,
  					me->select_row, i, TRUE);

 			FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,
   				me->select_row, me->pos);
	}
	
 	status = om$send(msg = message SMCmdVol.display_normal(&test),
 		      	targetid = my_id);
 	status = om$send(msg = message SMCmdVol.DispAll(	&test),
 		      targetid = my_id);
 	if(!(status & test & 1)){ 
 		ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
 		return OM_S_SUCCESS;
 	} 
	if(me->select_row == -1) *sts = LOAD_CEILING;

 }
 else {
	status = om$send(msg = message SMCmdVol.next_row(sts),
                        mode = OM_e_wrt_message,
                        targetid = my_id);
 	if(!(status & (*sts) & 1)){
 			*sts = OM_E_ABORT;
			goto quit;
 	}
 }
}
