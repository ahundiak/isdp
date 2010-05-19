/* $Id: SMCmdSlCmbr.sl,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/cmd / SMCmdSlCmbr.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdSlCmbr.sl,v $
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


/*    File          SMCmdSlCmbr.sl
      Description   Command object to place a Camber Deck (projection of a 
		    profile defined by slope _
      Auteur        Pascale Lacroix (ISDC) 
      Date          Oct-92     
*/

command_string       SMC_M_PlCmDcSl,0,SMPlCmDcSl
synonym		     SMC_M_MdCmDcSl,1,SMMdCmDcSl
command_table        "sman.cmd"
class                SMCmdSlCmbr
super_class          SMCmdSurf
product_name         "$VDS"

form "SMSlCamber",0,0,"-1","-1"
form "SMSlDef",1,0,"-1","-1"

specification





instance 
{

IGRdouble		z_pos;
IGRint			symetry;
IGRint			nb_sl;
IGRdouble		*slope;
IGRdouble		*y_dist;

IGRdouble		old_z_pos;
IGRint			old_symetry;
IGRint			old_nb_sl;
IGRdouble		*old_slope;
IGRdouble		*old_y_dist;

}

implementation

#include "AS_status.h"


#define AS_DEBUG	1

#define SLDEF	 	519
#define ERASE_F2	521

#define MAX_TEMP	2
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

#define SLDEF	 	519
#define ERASE_F2	521

#define MAX_TEMP	2
#define MAX_PT		50

state start

  on CMD_TYPE = PLACE	do message_key SM_M_PlCmDcSl
                        do display_form  0
  			state modif_form 
  				
  on CMD_TYPE = MODIFY	do message_key SM_M_MdCmDcSl
			state loc_macro

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS		state load_cs
  on GR_UNKNOWN_TYPE.RESTART 		state restart
  on GR_UNKNOWN_TYPE.SLDEF 	do FormOf
  				do FormPos
				do display_form 1 
				do pos_cursor	state def_slope
  on GR_UNKNOWN_TYPE.LOAD_OCC 	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1 
				do FormOn	state modif_form

state restart

  on CMD_TYPE = PLACE	state modif_form
  				
  on CMD_TYPE = MODIFY	do clear_form state reloc_macro

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.RESTART 	state restart
  on GR_UNKNOWN_TYPE.SLDEF 	do FormOf
  				do FormPos
				do display_form 1 
				do pos_cursor	state def_slope
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.LOAD_OCC 	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form

state loc_macro
  prompt_key         SM_P_IdSlCr
  accept_key        SM_P_PlAccRej
  locate_class	     "SMSlCamber"
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
  on GR_UNKNOWN_TYPE.SLDEF 	do FormOf
  				do FormPos
				do display_form 1 
				do pos_cursor	state def_slope
  on GR_UNKNOWN_TYPE.RESTART 	state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC 	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form

state reloc_macro
  prompt_key         SM_P_IdSlCr
  accept_key        SM_P_PlAccRej
  locate_class	     "SMSlCamber"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
				state modif_form
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.SLDEF 	do FormOf
  				do FormPos
				do display_form 1 
				do pos_cursor	state def_slope
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form

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
  on GR_UNKNOWN_TYPE.SLDEF 	do FormOf
  				do FormPos
				do display_form 1 
				do pos_cursor	state def_slope

  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form

		    
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

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC   do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.SLDEF 	do FormOf
  				do FormPos
				do display_form 1 
				do pos_cursor	state def_slope
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form


state load_from_occ
  prompt_key         SM_P_LcMacOc
  accept_key        SM_P_PlAccRej
  locate_class	     "SMSlCamber"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID 
			do store_occ 
                       		on ERROR state terminate
			state modif_form
				
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

  on EX_BACK_UP			state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.SLDEF 	do FormOf
  				do FormPos
				do display_form 1 
				do pos_cursor	state def_slope
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form

state  def_slope 
  prompt_key          SM_P_EnSlDfFrm
  filter              get_event

  on EX_FORM_FINISHED     	state terminate
  
  
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs

  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.ERASE_F2 	do erase_form 1  
				do FormOn	state modif_form
 


at init   do init_all
at delete do delete_all
at wakeup do verify_obj
	  do DispAll(GRhhd)

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in SMSlCmbrNtf.I                                           */




action reset_all extern
action store_occ extern

action save_all extern
action clear_form extern
action FormOn extern
action FormOf extern

action resetdef extern
action savedef extern

action SMmodif_mac(int nb_att; struct ACrg_coll *ACrg; int nb_new; 
		struct GRid *new) extern


/* ====================== init_all =============================
  
	This action init instances
  
============================================================= */
action init_all
/*.init_all*/
{
 long  			test;
 IGRdouble		x_form1, y_form1;

 om$send(msg = message SMCmdSurf.init_all(&test),
			 	targetid = my_id,
             			mode = OM_e_wrt_message);

 me->z_pos = 0.;
 me->symetry = 1;
 me->nb_sl = 0;
 me->slope = NULL;
 me->y_dist = NULL;

 me->old_z_pos = 0.;
 me->old_symetry = 1;
 me->old_nb_sl = 0;
 me->old_slope = NULL;
 me->old_y_dist = NULL;
	
 if(x_memo != -1 || y_memo != -1){
	FIf_set_location(me->forms[0].form_ptr,x_memo,y_memo);
	x_form1 = x_memo + 376;
	y_form1 = y_memo ;
	FIf_set_location(me->forms[1].form_ptr,x_form1,y_form1);
 }		

 if(me->mytype == MODIFY) 
		     FIg_set_text(me->forms[0].form_ptr,F_TITLE,
					"Modify Slope Camber");
 else{
	(void)GetDefName("SMSlCamber_0",me->def_name);
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

 x_form1 = x_form0 + 376;
 y_form1 = y_form0 ;
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

 if(me->slope){free(me->slope);me->slope = NULL;}
 if(me->old_slope){free(me->old_slope);me->old_slope = NULL;}
 if(me->y_dist){free(me->y_dist);me->y_dist = NULL;}
 if(me->old_y_dist){free(me->old_y_dist);me->old_y_dist = NULL;}

 if ( me->forms[0].form_ptr != NULL )
     FIf_get_location(me->forms[0].form_ptr,&x_memo,&y_memo);


 return status;
}

/* ----------------------------------------------------------------- */ 

action form_notification (int form_label; int gadget_label ; double value ;
			    char * form_ptr)
{
 int 			state, sel_flag, num_rows, col, row, pos, 
			del, mode, stat = OM_S_SUCCESS;
 long  			test;
 char 			text[MAX_CHAR];
 
        
 if ( form_ptr == NULL ){
     		/*| no form_ptr set */
     		return( OM_E_INVARG ); 
 }
  
 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
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

		case PTDEF_B:
     		stat = om$send(msg = message SMCmdSlCmbr.resetdef(&test),
			 targetid = my_id);
     		if(!(stat & test & 1)){
			printf("ERROR SMCmdSlCmbr.resetdef\n");
			FIg_set_state_off(form_ptr,gadget_label);
			goto quit;
      		}   
     		_put_response(resp = SLDEF);
    		break;
		        
     

	} /* END switch ( gadget_label ) */
}/* END form 0*/
else if ( form_ptr == me->forms[1].form_ptr ){
  
 	switch( gadget_label ){
   
  		case FI_ACCEPT:
  		case FI_EXECUTE:

     		stat = om$send(msg = message SMCmdSlCmbr.savedef(&test),
		      targetid = my_id);
     		if(!(stat & test & 1)){
			FIg_set_state_off(form_ptr,gadget_label);
			goto quit;
      		}   
     		if(gadget_label == FI_ACCEPT) _put_response(resp = ERASE_F2);
			 
     		break;
      
   		case FI_CANCEL: 
     		_put_response(resp = ERASE_F2);
     		break;
     
   		case FI_RESET:
     		stat = om$send(msg = message SMCmdSlCmbr.resetdef(&test),
			 targetid = my_id);
     		break;
	
		case DEL_ROW:
		case INSERT_ROW:
		case DEF_FIELD:

     			om$send(msg = message SMCmdSurf.form_notification
             			(form_label, gadget_label,value,form_ptr),
             			targetid = my_id,
             			mode = OM_e_wrt_message);

     			break;

     

	} /* END switch ( gadget_label ) */
}/* END form 1*/

  
  
  return OM_S_SUCCESS;
}

