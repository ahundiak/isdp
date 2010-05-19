/* $Id: SMCmdLgCrBk.sl,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/cmd / SMCmdLgCrBk.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdLgCrBk.sl,v $
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


/*    File          SMCmdLgCrBk.sl
      Description   Command object to place a Longitudinal corrugated 
      		    bulkhead by projection of a profile
      Auteur        Pascale Lacroix (ISDC) 
      Date          Oct-92     
*/

command_string       SMC_M_PlCrLnBH,0,SMPlCrLnBH
synonym		     SMC_M_MdCrLnBH,1,SMMdCrLnBH
command_table        "sman.cmd"
class                SMCmdLgCrBk
super_class          SMCmdSurf
product_name         "$VDS"

form "SMLgCrgtBk",0,0,"-1","-1"

specification






instance 
{

struct GRobj_env	point;
char			dir_axis;
char			x_axis;
IGRdouble		hight;
IGRdouble		len1;
IGRdouble		len2;
IGRdouble		period;

struct GRobj_env	old_point;
char			old_dir_axis;
char			old_x_axis;
IGRdouble		old_hight;
IGRdouble		old_len1;
IGRdouble		old_len2;
IGRdouble		old_period;


}

implementation


#define AS_DEBUG	1

#define LOAD_PT		519


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


#define LOAD_PT		519


state start

  on CMD_TYPE = PLACE	do message_key SM_M_PlCrLnBH
                        do display_form  0
  			state modif_form 
  				
  on CMD_TYPE = MODIFY	do message_key SM_M_MdCrLnBH
   			state loc_macro

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_PT	state load_point
  on GR_UNKNOWN_TYPE.LOAD_CS		state load_cs
  on GR_UNKNOWN_TYPE.RESTART 		state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC 	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

state restart

  on CMD_TYPE = PLACE	state modif_form
  				
  on CMD_TYPE = MODIFY	do clear_form state reloc_macro

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_PT	state load_point
  on GR_UNKNOWN_TYPE.RESTART 	state restart
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.LOAD_OCC 	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

state loc_macro
  prompt_key	     SM_P_IdLgCrBH
  accept_key   	     SM_P_PlAccRej
  locate_class	     "SMLgCrgtBk"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID  do clear_form
				       do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
		       do display_form  0
				state modif_form
  on GR_UNKNOWN_TYPE.LOAD_PT	state load_point
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.RESTART 	state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC 	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

state reloc_macro
  prompt_key	     SM_P_IdLgCrBH
  accept_key   	     SM_P_PlAccRej
  locate_class	     "SMLgCrgtBk"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
				state modif_form
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.LOAD_PT	state load_point
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

state  modif_form 
  prompt_key	      SM_P_EntPrmFr
  filter              get_event

  on EX_FORM_FINISHED     	state terminate
  
  
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs

  on GR_UNKNOWN_TYPE.LOAD_PT	state load_point
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.RESTART state restart


		    
state load_cs
  prompt_key	     SM_P_IdCrdStm
  accept_key   	     SM_P_PlAccRej
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
  on GR_UNKNOWN_TYPE.LOAD_PT	state load_point
  on GR_UNKNOWN_TYPE.LOAD_OCC   do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs

state load_point
  prompt_key         SM_P_IdPt
  accept_key   	     SM_P_PlAccRej
  locate_class	     "GRpoint"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID 
			do store_point  
                       		on ERROR state terminate
                       		state modif_form
  on EX_BACK_UP		state modif_form

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_PT	state load_point
  on GR_UNKNOWN_TYPE.LOAD_OCC   do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs


state load_from_occ
  prompt_key         SM_P_LcMacOc
  accept_key   	     SM_P_PlAccRej
  locate_class	     "SMLgCrgtBk"
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

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_PT	state load_point
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs


at init   do init_all
at delete do delete_all
at wakeup do verify_obj
	  do DispAll(GRhhd)

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in SMLgCrBkNtf.I                                           */




action reset_all extern
action store_occ extern

action save_all extern
action clear_form extern
action store_point extern
action DispAll(enum GRdpmode mode) extern

action SMmodif_mac(int nb_att; struct ACrg_coll *ACrg; int nb_new; 
		struct GRid *new) extern


/* ====================== init_all =============================
  
	This action init instances
  
============================================================= */
action init_all
/*.init_all*/
{
 long			test;
 
 om$send(msg = message SMCmdSurf.init_all(&test),
			 	targetid = my_id,
             			mode = OM_e_wrt_message);

 me->point.obj_id.objid = NULL_OBJID;
 me->old_point.obj_id.objid = NULL_OBJID;
 me->dir_axis = 'z';
 me->x_axis = 'x';
 me->hight = 0.;
 me->len1 = 0.;
 me->len2 = 0.;
 me->period = 0;

 me->old_dir_axis = 'z';
 me->old_x_axis = 'x';
 me->old_hight = 0.;
 me->old_len1 = 0.;
 me->old_len2 = 0.;
 me->old_period = 0;

 if(me->mytype == PLACE)
 {
	(void)GetDefName("SMLgCrgtBk_0",me->def_name);
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
 }
 if(x_memo != -1 || y_memo != -1)
                FIf_set_location(me->forms[0].form_ptr,x_memo,y_memo);


 return status;
}
/* ====================== delete_all =============================

    This action delete memory

============================================================= */
action delete_all
{
 IGRlong		test;

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

   	case POINT:
     		_put_response(resp = LOAD_PT);
   		
     		break;
     

 } /* END switch ( gadget_label ) */
  
  
  return OM_S_SUCCESS;
}

