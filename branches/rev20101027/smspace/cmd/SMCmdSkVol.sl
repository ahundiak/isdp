/* $Id: SMCmdSkVol.sl,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/cmd / SMCmdSkVol.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdSkVol.sl,v $
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

/*    File          SMCmdSkVol.sl
      Description   Command object to place a Profile Volume 
      Auteur        Pascale Lacroix (ISDC) 
      Date          Oct-92     
*/

command_string       SMC_M_PlPrVl,0,SMPlPrVl
synonym		     SMC_M_MdPrVl,1,SMMdPrVl
command_table        "sman.cmd"
class                SMCmdSkVol
super_class          SMCmdVol
product_name         "$VDS"

form "SMSkVol",0,0,"-1","-1"

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
#include "FI.h"
#include "SMspacecom.h"



#define MAX_SURF 	99
#define MAX_TEMP	100 	/* number of templates */


instance 
{

int			reverse;
int			old_reverse;

IGRint			normal_flag;
IGRdouble		accept_pt[3];
IGRdouble		Zvect[3];
IGRdouble		tg_vect[3];
struct GRid		CurveId;
}

implementation

#include "msdef.h"
#include "msmacros.h"
#include "AS_status.h"

/* include prototypes */

#include "bserr.h"
#include "bstypes.h"
#include "bscrossp.h"


#define SMDYN 		1

from GRgencs 	import	GRgetmatrix;



/*************************************************************************/

state_table

#include "SMmsg.h"
#include "SMspacecom.h"
#include "VDSFilter.h"

#define MAX_SURF 	99
#define MAX_TEMP	100 	/* number of templates */
#define SMDYN 		1

state start

  on CMD_TYPE = PLACE	do message_key SM_M_PlPrVl
			do reset_form 
                       		on ERROR do status_key SM_E_ErInit
						state terminate
                        do display_form  0
  				state locate_volume 
  				
  on CMD_TYPE = MODIFY	do message_key SM_M_MdPrVl state loc_macro

  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state locate_volume
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

state restart

  on CMD_TYPE = PLACE	state locate_volume 
  				
  on CMD_TYPE = MODIFY	do clear_form state reloc_macro

  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state locate_volume
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  				state load_from_occ
  
state loc_macro
  prompt_key	     SM_P_IdPrVl
  accept_key         SM_P_PlAccRej
  locate_class	     "SMSketchVol"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID  do clear_form
				       do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
		       do display_form  0
				state locate_volume

  on GR_UNKNOWN_TYPE.LOAD_VOLUME state locate_volume
  on GR_UNKNOWN_TYPE.LOAD_CURVE  state locate_curve
  on GR_UNKNOWN_TYPE.RESTART  state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state locate_volume
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

state reloc_macro
  prompt_key	     SM_P_IdPrVl
  accept_key         SM_P_PlAccRej
  locate_class	     "SMSketchVol"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID   do store_occ
                       on ERROR do status_key  SM_E_ErStMc state terminate
				state locate_volume

  on GR_UNKNOWN_TYPE.LOAD_VOLUME state locate_volume
  on GR_UNKNOWN_TYPE.LOAD_CURVE  state locate_curve
  on GR_UNKNOWN_TYPE.MODIF_FORM state locate_volume
  on GR_UNKNOWN_TYPE.RESTART  state restart
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

state  locate_volume
  prompt_key         SM_P_IdVol
  accept_key         SM_P_PlAccRej
  locate_class	     "EMSsolid"
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
			
		do next_row 
                       	on ERROR state terminate
                        on RETURN_CODE = END_TEMP do save_all 
                        			state restart
                        on RETURN_CODE = NEED_SOLID do status_key SM_S_VolNeed
                        				state .
                state locate_curve
			
  on EX_RJT_MOVEON	do next_row	
                       		on ERROR state terminate
                        	on RETURN_CODE = END_TEMP do save_all 
                       				state restart
                        	on RETURN_CODE = NEED_SOLID do status_key SM_S_VolNeed
                        				state .

                        	state locate_curve                 

  on EX_FORM_FINISHED   state terminate
  
  
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

  on GR_UNKNOWN_TYPE.LOAD_VOLUME state locate_volume
  on GR_UNKNOWN_TYPE.MODIF_FORM state locate_volume
  on GR_UNKNOWN_TYPE.LOAD_CURVE  state locate_curve
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.RESTART  state restart

state  locate_curve 
  prompt_key	     SM_P_IdCv
  accept_key         SM_P_PlAccRej
  locate_class	     "GRcurve"
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
			on RETURN_CODE = CLOSED_CURVE
				do status_key SM_S_ClsCv
				do next_row 
                       			on ERROR state terminate
                        		on RETURN_CODE = NEED_CURVE do status_key SM_S_CvNeed
                        				state . 
					on RETURN_CODE = NEED_NORMAL state get_orient
                        		on RETURN_CODE = END_TEMP do save_all 
					state restart
				state .
			on RETURN_CODE = NEED_NORMAL	state get_orient
			
		do next_row 
                       	on ERROR state terminate
                        on RETURN_CODE = END_TEMP do save_all 
                       				state restart
			on RETURN_CODE = NEED_NORMAL	state get_orient
                        on RETURN_CODE = NEED_CURVE do status_key SM_S_CvNeed   state .
                        	
                state .
			
  on EX_RJT_MOVEON	do next_row	
                       		on ERROR state terminate
                        	on RETURN_CODE = END_TEMP do save_all 
                        			state restart
				on RETURN_CODE = NEED_NORMAL state get_orient
                        	on RETURN_CODE = NEED_CURVE do status_key SM_S_CvNeed                        				state .
                        state .                 

  on EX_FORM_FINISHED   state terminate
  
  
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

  on GR_UNKNOWN_TYPE.LOAD_VOLUME state locate_volume
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.MODIF_FORM state locate_volume
  on GR_UNKNOWN_TYPE.LOAD_CURVE  state locate_curve
  on GR_UNKNOWN_TYPE.RESTART state restart


state  del_elt
  prompt_key	      SM_P_SelEltDsc
  filter	      get_event

  on EX_FORM_FINISHED     	state terminate
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

  on GR_UNKNOWN_TYPE.LOAD_VOLUME state locate_volume
  on GR_UNKNOWN_TYPE.MODIF_FORM state locate_volume
  on GR_UNKNOWN_TYPE.LOAD_CURVE  state locate_curve
  on GR_UNKNOWN_TYPE.RESTART state restart
  
  
  on GR_UNKNOWN_TYPE.DEL_ELT state locate_volume


state get_orient
	execute		invalbutton
        prompt_key	SM_P_GvArea
        dynamics        SMDYN
        filter          get_event

  on EX_RJT_MOVEON        do SMInverseNormal  
  			  do restbutton 	state .

  on EX_DATA           	do DispAll
  				do restbutton
        			do next_row 
                       			on ERROR state terminate
                        		on RETURN_CODE = END_TEMP do save_all 
						state restart
				state locate_curve
  on EX_FORM_FINISHED     state terminate
  on GR_UNKNOWN_TYPE.MODIF_FORM state locate_volume
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  				state load_from_occ


state load_from_occ
  prompt_key	     SM_P_LcMacOc
  accept_key         SM_P_PlAccRej
  locate_class	     "SMSketchVol"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID 
			do store_occ 
                       		on ERROR state terminate
			state locate_volume
				
  on GR_UNKNOWN_TYPE.LOAD_OCC  	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

  on GR_UNKNOWN_TYPE.LOAD_VOLUME state locate_volume
  on GR_UNKNOWN_TYPE.MODIF_FORM state locate_volume
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_CURVE  state locate_curve
  on GR_UNKNOWN_TYPE.RESTART  state restart


at init   do init_all
at wakeup do verify_obj
	  do DispAll
at delete do delete_all

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in SMSkNotif.I                                           */



action store_obj(long *sts; int max_obj) extern
action verify_obj extern

action next_row extern

action store_occ extern

action reset_form extern
action clear_form extern
action save_all extern
action delete_elt extern
action SMmodif_mac(int nb_new; struct GRid *new) extern

/* ----------------------------------------------------------------- */ 
action restbutton
{
	*sts = OM_S_SUCCESS;
	FIg_enable(me->forms[0].form_ptr, FI_ACCEPT);
	FIg_enable(me->forms[0].form_ptr, FI_EXECUTE);
	FIg_enable(me->forms[0].form_ptr, FI_RESET);
status = OM_S_SUCCESS;
goto quit;


}
/* ----------------------------------------------------------------- */ 

action invalbutton
{
	*sts = OM_S_SUCCESS;
	FIg_disable(me->forms[0].form_ptr, FI_ACCEPT);
	FIg_disable(me->forms[0].form_ptr, FI_EXECUTE);
	FIg_disable(me->forms[0].form_ptr, FI_RESET);
status = OM_S_SUCCESS;
goto quit;

}


/* ====================== init_all =============================
  
	This action init instances
  
============================================================= */
action init_all
/*.init_all*/
{
 *sts = OM_S_SUCCESS;

 status = om$send(msg = message SMCmdVol.init_all(sts),
			mode = OM_e_wrt_message,
		      	targetid = my_id);


 strcpy(me->macro_name,"SMSketchVol");
 strcpy(me->auto_name,"SMSketchVol_0");
 me->nb_col_limits = 2;

 me->normal_flag = 1;
 me->reverse = -1;	
 me->old_reverse = -1;	   	
 if(me->mytype == MODIFY) 
     FIg_set_text(me->forms[0].form_ptr,F_TITLE,"Modify Profile Volume");

status = OM_S_SUCCESS;
goto quit;

}

/* ====================== SMInverseNormal ============================= */

action SMInverseNormal
{
	*sts = OM_S_SUCCESS;

	me->normal_flag *= -1;

status = OM_S_SUCCESS;
goto quit;
}
/******************************************************************************/

action SMget_active_cs_Zvect
{
  IGRlong	msg = MSSUCC;    	/* return code           */
  struct GRid	active_cs_id;     	/* active cs Grid        */
  IGRmatrix     active_cs_matrix; 	/* active cs matrix      */

  /*| get active CS */ 

  *sts = OM_S_SUCCESS;

  active_cs_id.osnum = me->ModuleInfo.md_id.osnum;
  status = cs$get_active_info( msg   = &msg,
                               osnum = active_cs_id.osnum,
                               objid = &active_cs_id.objid );
  as$status( sts = msg, action = RET_STATUS );

  /*| get CS matrix */

  status = om$send( msg      = message GRgencs.GRgetmatrix( &msg,
                                                            active_cs_matrix ),
                    senderid = NULL_OBJID,
                    targetid = active_cs_id.objid, 
                    targetos = active_cs_id.osnum );
  as$status( sts = msg, action = RET_STATUS );

  me->Zvect[0] = active_cs_matrix[2];
  me->Zvect[1] = active_cs_matrix[6];
  me->Zvect[2] = active_cs_matrix[10];

status = OM_S_SUCCESS;
goto quit;


}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method dynamics

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action dynamics
{
  BSrc		bsretcode;
  IGRdouble 	TmpVect[3];

  if( dynamics == SMDYN )
  {
	status = om$send( msg      = message SMCmdSkVol.SMget_active_cs_Zvect( &me->ret ),
			  targetid = my_id );
	as$status( action = RET_STATUS );

  	BScrossp( &bsretcode, me->tg_vect, me->Zvect, TmpVect );

    	SMorient( me->accept_pt, TmpVect, me->tg_vect, me->normal_flag, 
		&me->ActiveDisplay );
  }
 goto quit;

}



/* ----------------------------------------------------------------- */ 

action form_notification (int form_label; int gadget_label ; double value ;
			    char * form_ptr)
{
 int 			stat = OM_S_SUCCESS;
 int  			sel_flag, num_rows;
 int  			pos, col, row;
 long			test;

 if ( form_ptr == NULL ){
 	/*| no form_ptr set */
     	return( OM_E_INVARG ); 
 }
  
 FIg_set_text(form_ptr,FI_MSG_FIELD,"");
 UI_message("");
  
 switch( gadget_label ){
	case FI_ACCEPT:
	case FI_EXECUTE:
		if(me->state == _get_orient) {
				FIg_set_state_off(form_ptr,gadget_label);
				ex$message(msgnumb = SM_S_AreaNeed);
				break;
		}
   	case FI_CANCEL: 
   	case FI_RESET:
   	case OCC_NAME:
		if(me->state == _get_orient) ex$message(msgnumb = SM_S_AreaNeed);
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
                	stat = om$send(msg = message SMCmdSkVol.delete_elt(&test),
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


	case LIMITS:
		if(me->state == _get_orient) {
     			FIfld_set_select(form_ptr,LIMITS, 1, 0, TRUE);
     			FIfld_set_select(form_ptr,LIMITS, 1, 1, TRUE);
			ex$message(msgnumb = SM_S_AreaNeed);
			break;
		}
     		FImcf_get_active_col(  form_ptr,LIMITS, &col, &pos); 
     		FIfld_get_active_row(form_ptr,LIMITS, &row, &pos);
     		FIfld_get_select(form_ptr,LIMITS,row, 0,&sel_flag);

		if(me->limits[row].surf.located_obj.objid == NULL_OBJID){
 			FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,me->select_row, 
  				me->pos);
			
			break;
		}
      		if(me->delete_elt ){

			/* get the row to be deleted */

			me->delete_row = (sel_flag == TRUE) ? row : -1;
     			if(sel_flag == TRUE){
				me->select_row = row;
        			stat = om$send(msg = message SMCmdSkVol.DispAll
        						(&test),
 		      			targetid = my_id);
        			if(!(stat & test & 1)){ 
 					ex$message(msgnumb = SM_S_ErrDsp);
 					goto quit;
        			} 
				me->select_row = 0;
			}
     			if(row == 0 && sel_flag == TRUE){
     				/* volume cannot be disconnect */
 				FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
 					"The Volume cannot be disconnected");
     				FIfld_set_select(me->forms[0].form_ptr, LIMITS,
     						row, 0, FALSE);
  				FIfld_set_select(me->forms[0].form_ptr, LIMITS,
  						row, 1, FALSE);
				me->delete_row = -1;
  				break;
  			}
     			if(sel_flag == TRUE){
 				FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
					"Valid with disconnect button");
				break;
				
     			}
 			FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
				"Select the Elt to be disconnected");
			break;
		}
      
     		stat = FIfld_get_num_rows(form_ptr,LIMITS, &num_rows);
     		if(stat != FI_SUCCESS) {
			printf("error FIfld_get_num_rows\n");
			goto quit;
     		}
     		FImcf_get_active_col(  form_ptr,LIMITS, &col, &pos); 
     		FIfld_get_active_row(form_ptr,LIMITS, &row, &pos);
     
        	me->select_row = row;
		me->pos = pos;
     		FIfld_get_select(form_ptr,LIMITS,me->select_row, 
     						0,&sel_flag);
     		if(sel_flag == TRUE){
        		stat = om$send(msg = message SMCmdSkVol.DispAll
        						(&test),
 		      			targetid = my_id);
        		if(!(stat & test & 1)){ 
 				ex$message(msgnumb = SM_S_ErrDsp);
 				goto quit;
        		} 
			if(row == 0)     
				_put_response(resp = LOAD_VOLUME);
			_put_response(resp = LOAD_CURVE);
     		}	
     		break;
     

} /* END switch ( gadget_label ) */
  
  
  return OM_S_SUCCESS;
}


