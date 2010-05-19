/* $Id: SMCmdSpltSf.sl,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/cmd / SMCmdSpltSf.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdSpltSf.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1997/01/30  18:58:30  pinnacle
# Replaced: smspace/cmd/SMCmdSpltSf.sl for:  by jwfrosch for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/03/19  05:08:04  pinnacle
# Replaced: smspace/cmd/SMCmdSpltSf.sl for:  by rgade for vds.240
#
# Revision 1.3  1995/11/22  12:18:04  pinnacle
# Replaced: smspace/cmd/SMCmdSpltSf.sl for:  by rgade for vds.240
#
# Revision 1.2  1995/09/26  20:20:38  pinnacle
# Replaced: smspace/cmd/SMCmdSpltSf.sl for:  by sundar for vds.240
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

/*    File          SMCmdSpltSf.sl
      Description   Command object to place a bounded surface (or volume)
      		    resulting of splitting and save side operations.
      Auteur        Pascale Lacroix (ISDC) 
      Date          Oct-92     
*/

command_string       SMC_M_PlSplSf,0,SMPlSplSf
synonym		     SMC_M_MdSplSf,1,SMMdSplSf
command_table        "sman.cmd"
class                SMCmdSpltSf
super_class          SMCmdVol
product_name         "$VDS"

form "SMSplitSf",0,0,"-1","-1"

specification

#include "OMmacros.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "coparamac.h"
#include "growner.h"
#include "msdef.h"

#include "FI.h"

#include "SMspacecom.h"


#define MAX_SURF 	14
#define MAX_TEMP	17 	/* number of templates */


instance 
{

char			def_name[MY_MAX_CHAR];
double			offset;
double			old_offset;

}

implementation

#include "SMmsg.h"

#include "AS_status.h"



/*************************************************************************/

state_table

#include "SMmsg.h"
#include "VDSFilter.h"
#include "SMspacecom.h"

#define MAX_SURF 	14
#define MAX_TEMP	17 	/* number of templates */

state start

  on CMD_TYPE = PLACE	do message_key SM_M_PlSplSf
			do reset_form 
                       on ERROR do status_key SM_E_ErInit state terminate
                        do display_form  0

  				state load_support
  				
  on CMD_TYPE = MODIFY	do message_key SM_M_MdSplSf state loc_macro
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

state restart

  on CMD_TYPE = PLACE	state modif_form
  				
  on CMD_TYPE = MODIFY	do clear_form state reloc_macro


  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

state loc_macro
  prompt_key         SM_P_IdSplSf
  accept_key         SM_P_PlAccRej
  locate_class	     "SMSpltSrf"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING  do clear_form
				       do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
		       do display_form  0
				state load_support

  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

state reloc_macro
  prompt_key         SM_P_IdSplSf
  accept_key         SM_P_PlAccRej
  locate_class	     "SMSpltSrf"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING  do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
				state load_support

  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

state  modif_form 
  prompt_key 	     SM_P_IdHltTmp
  accept_key         SM_P_PlAccRej
  locate_class	     "EMSsurface"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"
  filter              vds_locate_noauto

  on EX_DATA or EX_STRING  
  		do store_obj(&me->ret, MAX_SURF)
                       		on ERROR state terminate
				on RETURN_CODE = NO_OBJ 
					do status_key SM_E_ErInvObj  state .
				on RETURN_CODE = TOO_FENCE 
					do status_key SM_S_OneFc  state .
				on RETURN_CODE = MD_FENCE 
					do status_key SM_S_NoFcMd  state .
			do display_normal
			state get_normal
			
  on EX_RJT_MOVEON	do next_row	
                       		on ERROR state terminate
                        	on RETURN_CODE = END_TEMP do save_all 
								state restart
                        state .                 
  on EX_FORM_FINISHED     	state terminate
  
  
  on GR_UNKNOWN_TYPE.LOAD_SUPPORT	state load_support
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt

state  load_support 
  prompt_key 	     SM_P_IdSup
  accept_key         SM_P_PlAccRej
  locate_class	     "EMSsurface"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"
  filter              vds_locate_noauto

  on EX_DATA or EX_STRING  or EX_OBJID
  		do store_obj(&me->ret, MAX_SURF)
                       		on ERROR state terminate
				on RETURN_CODE = NO_OBJ 
					do status_key SM_E_ErInvObj  state .
				on RETURN_CODE = TOO_FENCE 
					do status_key SM_S_OneFc  state .
				on RETURN_CODE = MD_FENCE 
					do status_key SM_S_NoFcMd  state .
			do display_normal
			state get_normal
			
  on EX_RJT_MOVEON	do next_row	
                       		on ERROR state terminate
                        	on RETURN_CODE = END_TEMP do save_all 
								state restart
                        state .                 
  on EX_FORM_FINISHED     	state terminate
  
  
  on GR_UNKNOWN_TYPE.LOAD_SUPPORT	state load_support

  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt


state  del_elt
  prompt_key	      SM_P_SelEltDsc
  filter	      get_event

  on EX_FORM_FINISHED     	state terminate
  
  

  on GR_UNKNOWN_TYPE.LOAD_SUPPORT	state load_support
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.DEL_ELT state modif_form

state  get_normal
  execute	      GadgOf
  prompt_key          SM_P_IsOrGood
  filter              get_event

  on EX_STRING   
  		do GadgOn
  		do store_orient 
		do next_row 
		           on RETURN_CODE = END_TEMP do save_all state restart
		state modif_form
			
  on EX_DATA		do GadgOn 
			do accept_orient
                       		on ERROR state terminate
			do next_row 
                        	on RETURN_CODE = END_TEMP do save_all 
                        			state restart
			state modif_form

  on EX_RJT_MOVEON 	do GadgOn
  			do reverse_orient
                       		on ERROR state terminate
  			 
			do next_row 
                        	on RETURN_CODE = END_TEMP do save_all 
                        			state restart
			state modif_form
  
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

		    

state load_from_occ
  prompt_key         SM_P_LcMacOc
  accept_key         SM_P_PlAccRej
  locate_class	     "SMSpltSrf"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING  
			do store_occ 
                       		on ERROR state terminate
			state load_support
				
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.DEL_ELT state del_elt


at init   do init_all
at wakeup do verify_obj
	  do DispAll
at delete do delete_all

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in SMSplNotif.I                                          */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

action store_obj extern
action verify_obj extern
action store_support extern
action store_orient extern
action reverse_orient extern
action accept_orient extern
action GadgOn extern
action GadgOf extern
action next_row extern
action DispLoc(int index; enum GRdpmode mode) extern
action store_occ extern
action reset_form extern
action clear_form extern
action save_all extern
action delete_elt extern

action SMmodif_mac(unsigned int	VMask; IGRdouble offset;
			int nb_new; struct GRid *new) extern

action init_all extern

action form_notification (int form_label; int gadget_label ; double value ;
			    char * form_ptr) extern

