/* $Id: SMCmdSlShr.sl,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/cmd / SMCmdSlShr.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdSlShr.sl,v $
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


/*    File          SMCmdSlShr.sl
      Description   Command object to place a Sheer Deck (projection of a 
		    profile defined by slope )_
      Auteur        Pascale Lacroix (ISDC) 
      Date          Oct-92     
*/

command_string       SMC_M_PlShDcSl,0,SMPlShDcSl
synonym		     SMC_M_MdShDcSl,1,SMMdShDcSl
command_table        "sman.cmd"
class                SMCmdSlShr
super_class          SMCmdSurf
product_name         "$VDS"

form "SMSlSheer",0,0,"-1","-1"
form "SMSlShDef",1,0,"-1","-1"

specification



#define MAX_TEMP	53
#define MAX_PT		50


instance 
{

int			nb_wrk;
struct def_slope	wrk_frame[MAX_PT];
struct GRobj_env	dep_frame;
struct def_slope	frame[MAX_PT];
IGRdouble		z_pos;
IGRdouble		dep_dx;
IGRint			nb_sl;

struct GRobj_env	old_dep_frame;
struct def_slope	old_frame[MAX_PT];
IGRdouble		old_z_pos;
IGRdouble		old_dep_dx;
IGRint			old_nb_sl;


}

implementation

#define AS_DEBUG	1

#define SLNEW	 	519
#define ERASE_F2	521
#define LOAD_FRAME	523
#define LOAD_DEPFR	525
#define INV_LOC		527
#define DEF_FORM	529
#define SLOLD	 	531

#define MAX_TEMP	453
#define MAX_PT		50

%safe

	static int 	x_memo = -1,
			y_memo = -1;
%endsafe			


/*************************************************************************/

state_table

#include "VDSFilter.h"
#include "SMSurf.h"
#include "SMmsg.h"

#define AS_DEBUG	1


#define SLNEW	 	519
#define ERASE_F2	521
#define LOAD_FRAME	523
#define LOAD_DEPFR	525
#define INV_LOC		527
#define DEF_FORM	529
#define SLOLD	 	531

state start

  on CMD_TYPE = PLACE	do message_key SM_M_PlShDcSl
                        do display_form  0
  			state modif_form 
  				
  on CMD_TYPE = MODIFY	do message_key SM_M_MdShDcSl
			state loc_macro

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS		state load_cs
  on GR_UNKNOWN_TYPE.RESTART 		state restart
  on GR_UNKNOWN_TYPE.SLNEW 	do FormOf
  				do FormPos
				do display_form 1 state load_frame
  on GR_UNKNOWN_TYPE.SLOLD 	do FormOf
  				do FormPos
				do display_form 1 state def_slope
  on GR_UNKNOWN_TYPE.LOAD_OCC 	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1 
				do FormOn	state modif_form
  on GR_UNKNOWN_TYPE.LOAD_FRAME	state load_frame
  on GR_UNKNOWN_TYPE.LOAD_DEPFR	state load_dep_frame

state restart

  on CMD_TYPE = PLACE	state modif_form
  				
  on CMD_TYPE = MODIFY	do clear_form state reloc_macro

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.RESTART 	state restart
  on GR_UNKNOWN_TYPE.SLNEW 	do FormOf
  				do FormPos
				do display_form 1 state load_frame
  on GR_UNKNOWN_TYPE.SLOLD 	do FormOf
  				do FormPos
				do display_form 1 state def_slope
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.LOAD_OCC 	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form
  on GR_UNKNOWN_TYPE.LOAD_FRAME	state load_frame
  on GR_UNKNOWN_TYPE.LOAD_DEPFR	state load_dep_frame

state loc_macro
  prompt_key         SM_P_IdSlSh
  accept_key        SM_P_PlAccRej
  locate_class	     "SMSlSheer"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID  do clear_form
				       do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
		       do display_form  0
				state modif_form
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.SLNEW 	do FormOf
  				do FormPos
				do display_form 1 state load_frame
  on GR_UNKNOWN_TYPE.SLOLD 	do FormOf
  				do FormPos
				do display_form 1 state def_slope
  on GR_UNKNOWN_TYPE.RESTART 	state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC 	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form
  on GR_UNKNOWN_TYPE.LOAD_FRAME	state load_frame
  on GR_UNKNOWN_TYPE.LOAD_DEPFR	state load_dep_frame

state reloc_macro
  prompt_key         SM_P_IdSlSh
  accept_key        SM_P_PlAccRej
  locate_class	     "SMSlSheer"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
				state modif_form
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.SLNEW 	do FormOf
  				do FormPos
				do display_form 1 state load_frame
  on GR_UNKNOWN_TYPE.SLOLD 	do FormOf
  				do FormPos
				do display_form 1 state def_slope
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form
  on GR_UNKNOWN_TYPE.LOAD_FRAME	state load_frame
  on GR_UNKNOWN_TYPE.LOAD_DEPFR	state load_dep_frame

state  modif_form 
  prompt_key          SM_P_EntPrmFr
  filter              get_event

  on EX_FORM_FINISHED     	state terminate
  
  
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs

  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.SLNEW 	do FormOf
  				do FormPos
				do display_form 1 state load_frame
  on GR_UNKNOWN_TYPE.SLOLD 	do FormOf
  				do FormPos
				do display_form 1 state def_slope
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form
  on GR_UNKNOWN_TYPE.LOAD_FRAME	state load_frame
  on GR_UNKNOWN_TYPE.LOAD_DEPFR	state load_dep_frame

		    
state load_cs
  prompt_key         SM_P_IdCrdStm
  accept_key        SM_P_PlAccRej
  locate_class	     "GRlbsys"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID 
			do store_cs  
                       		on ERROR state terminate
                       		state modif_form
  on EX_BACK_UP		state modif_form

  on GR_UNKNOWN_TYPE.LOAD_OCC   do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.SLNEW 	do FormOf
  				do FormPos
				do display_form 1 state load_frame
  on GR_UNKNOWN_TYPE.SLOLD 	do FormOf
  				do FormPos
				do display_form 1 state def_slope
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form
  on GR_UNKNOWN_TYPE.LOAD_FRAME	state load_frame
  on GR_UNKNOWN_TYPE.LOAD_DEPFR	state load_dep_frame

state load_dep_frame
  prompt_key         SM_P_IdStFr
  accept_key        SM_P_PlAccRej
  status_key	     SM_S_FrDfCsOrd
  locate_class	     "SMframe"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID 
			do store_dep_frame  
                       		on ERROR state terminate
                       		on RETURN_CODE = INV_LOC	state .
                       		state modif_form
  on EX_BACK_UP		state modif_form

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC   do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.LOAD_FRAME	state load_frame
  on GR_UNKNOWN_TYPE.LOAD_DEPFR	state load_dep_frame
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form

state load_frame
  prompt_key         SM_P_IdNxtFr
  accept_key        SM_P_PlAccRej
  status_key	     SM_S_FrDfCsOrd
  locate_class	     "SMframe"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID 
			do store_frame  
                       		on ERROR state terminate
                       		on RETURN_CODE = INV_LOC	state .
                       		state .
  on EX_BACK_UP		state def_slope
  on EX_RJT_MOVEON	state def_slope

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_FRAME	state load_frame
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form

state load_from_occ
  prompt_key         SM_P_LcMacOc
  accept_key        SM_P_PlAccRej
  locate_class	     "SMSlSheer"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID 
			do store_occ 
                       		on ERROR state terminate
			state modif_form
				
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

  on EX_BACK_UP			state modif_form
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.SLNEW 	do FormOf
  				do FormPos
				do display_form 1 state load_frame
  on GR_UNKNOWN_TYPE.SLOLD 	do FormOf
  				do FormPos
				do display_form 1 state def_slope
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form
  on GR_UNKNOWN_TYPE.LOAD_FRAME	state load_frame
  on GR_UNKNOWN_TYPE.LOAD_DEPFR	state load_dep_frame

state  def_slope 
  prompt_key          SM_P_EnSlDfFrm
  execute 	      set_insert_mode(&me->ret, me->forms[1].form_ptr, 
				      DEF_FIELD, 3)
  filter              get_event

  on EX_FORM_FINISHED     	state terminate
  
  
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form
 
  on GR_UNKNOWN_TYPE.LOAD_FRAME	state load_frame


at init   do init_all
at delete do delete_all
at wakeup do verify_obj
	  do DispAll(GRhhd)

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in SMSlShrNtf.I                                           */




action reset_all extern
action store_occ extern

action save_all extern
action clear_form extern
action store_frame extern
action store_dep_frame extern
action FormOn extern
action FormOf extern

action resetdef extern
action savedef extern
action cleardef extern
action DispAll(enum GRdpmode mode) extern
action verify_obj extern

action SMmodif_mac(int nb_att; struct ACrg_coll *ACrg; 
			int nb_new; struct GRid *new) extern

/* ====================== init_all =============================
  
	This action init instances
  
============================================================= */
action init_all
/*.init_all*/
{
 int  			i;
 long			test;
 IGRdouble		x_form1, y_form1;
 
 om$send(msg = message SMCmdSurf.init_all(&test),
			 	targetid = my_id,
             			mode = OM_e_wrt_message);


 me->z_pos = 0.;
 me->dep_dx = 0;
 me->nb_sl = 0;
 me->nb_wrk= 0;
 me->dep_frame.obj_id.objid = NULL_OBJID;

 me->old_z_pos = 0.;
 me->old_dep_dx = 0;
 me->old_nb_sl = 0;
 me->old_dep_frame.obj_id.objid = NULL_OBJID;

 for(i=0;i<MAX_PT;i++){
	me->frame[i].dx =0.;
	me->old_frame[i].dx =0.;
	me->frame[i].slope =0.;
	me->old_frame[i].slope =0.;
	me->frame[i].frame.obj_id.objid = NULL_OBJID;
	me->wrk_frame[i].frame.obj_id.objid = NULL_OBJID;
	me->old_frame[i].frame.obj_id.objid = NULL_OBJID;
 }
 if(x_memo != -1 || y_memo != -1){
	FIf_set_location(me->forms[0].form_ptr,x_memo,y_memo);
	x_form1 = x_memo + 395;
	y_form1 = y_memo ;
	FIf_set_location(me->forms[1].form_ptr,x_form1,y_form1);
 }		

 if(me->mytype == MODIFY) 
		     FIg_set_text(me->forms[0].form_ptr,F_TITLE,
					"Modify Sheer Surface");
 else{
	(void)GetDefName("SMSlSheer_0",me->def_name);
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
 }

 return status;

}


/* ====================== FormPos =============================

        This action set the position of the second form

============================================================= */
action FormPos
/*.FormPos*/
{
int	x_form0, y_form0, x_form1, y_form1;

 FIf_get_location(me->forms[0].form_ptr,&x_form0,&y_form0);

 x_form1 = x_form0 + 395;
 y_form1 = y_form0 + 1;
 FIf_set_location(me->forms[1].form_ptr,x_form1,y_form1);
 
  return OM_S_SUCCESS;
}

/* ====================== delete_all =============================

        This action delete memory

============================================================= */
action delete_all
/*.delete_all*/
{
 long	test;

 *sts = OM_S_SUCCESS;

 om$send(msg = message SMCmdSurf.delete_all(&test),
			 	targetid = my_id,
             			mode = OM_e_wrt_message);

 if ( me->forms[0].form_ptr != NULL )
     FIf_get_location(me->forms[0].form_ptr,&x_memo,&y_memo);



 return status;
}

/* ----------------------------------------------------------------- */ 

action form_notification (int form_label; int gadget_label ; double value ;
			    char * form_ptr)
{
 int 			row, col, pos, stat = OM_S_SUCCESS;
 long  			test;

 if ( form_ptr == me->forms[0].form_ptr ){
  
 	switch( gadget_label ){
   
  		case FI_ACCEPT:
  		case FI_EXECUTE:
		case FI_RESET:
		case FI_CANCEL:
   		case LOAD:
   		case OCC_NAME:
   		case EXTENSION:
   		case COORDINATE:
     			om$send(msg = message SMCmdSurf.form_notification
             			(form_label, gadget_label,value,form_ptr),
             			targetid = my_id,
             			mode = OM_e_wrt_message);

     			break;
	
 		case FR_FRAME:   		
     		_put_response(resp = LOAD_DEPFR);
   		
     		break;

		case PTDEF_B:
		if(me->dep_frame.obj_id.objid == NULL_OBJID){
  			FIg_set_text(form_ptr,FI_MSG_FIELD,"Depart Frame must be defined");
			break;
		}
     		stat = om$send(msg = message SMCmdSlShr.resetdef(&test),
			 targetid = my_id);
     		if(!(stat & test & 1)){
			printf("ERROR SMCmdSlShr.resetdef\n");
			FIg_set_state_off(form_ptr,gadget_label);
			goto quit;
      		}   
     		if(me->mytype == MODIFY || me->nb_sl){
     				_put_response(resp = SLOLD);
     				break;
     		}
     		_put_response(resp = SLNEW);
     		
    		break;
		        
     

	} /* END switch ( gadget_label ) */
}/* END form 0*/
else if ( form_ptr == me->forms[1].form_ptr ){
  
 	switch( gadget_label ){
   
  		case FI_ACCEPT:
  		case FI_EXECUTE:

     		stat = om$send(msg = message SMCmdSlShr.savedef(&test),
		      targetid = my_id);
     		if(!(stat & test & 1)){
			FIg_set_state_off(form_ptr,gadget_label);
			goto quit;
      		}   
     		if(gadget_label == FI_ACCEPT) _put_response(resp = ERASE_F2);
			 
     		break;

		case DEF_FIELD:
                FIfld_get_active_row(form_ptr,DEF_FIELD, &row,&pos);
		FImcf_get_active_col(form_ptr,DEF_FIELD,&col,&pos);
		if(col == 0){
 			FIfld_set_text(me->forms[1].form_ptr, DEF_FIELD, row, 2,
                                 "0", FALSE);
		}
		break;	


	      
   		case FI_CANCEL:
     		stat = om$send(msg = message SMCmdSlShr.cleardef(&test),
			 targetid = my_id);
     		_put_response(resp = ERASE_F2);
     		break;
     
   		case FI_RESET:
     		stat = om$send(msg = message SMCmdSlShr.resetdef(&test),
			 targetid = my_id);
 		stat = om$send(msg = message SMCmdSlShr.set_insert_mode(
					&test, me->forms[1].form_ptr, 
				      DEF_FIELD, 3),
  			 	targetid = my_id);
     		break;
	

 		case LOC_FRAME:   		
     		stat = om$send(msg = message SMCmdSlShr.cleardef(&test),
			 targetid = my_id);
     		_put_response(resp = LOAD_FRAME);
     		break;
     

	} /* END switch ( gadget_label ) */
}/* END form 1*/

  
  
  return OM_S_SUCCESS;
}

