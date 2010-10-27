/* $Id: SMCmdLtdVol.sl,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/cmd / SMCmdLtdVol.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdLtdVol.sl,v $
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

/*    File          SMCmdLtdVol.sl
      Description   Command object to place a Limited Volume
      Auteur        Pascale Lacroix (ISDC) 
      Date          Oct-92     
*/

command_string       SMC_M_PlLmVl,0,SMPlLmVl
synonym		     SMC_M_MdLmVl,1,SMMdLmVl
command_table        "sman.cmd"
class                SMCmdLtdVol
super_class          SMCmdVol
product_name         "$VDS"

form "SMLimVol",0,0,"-1","-1"

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


#define MAX_SURF 	49
#define MAX_TEMP	50 	/* number of templates */


instance 
{
int			consume;
int			old_consume;

}

implementation

#include "AS_status.h"




/*************************************************************************/

state_table

#include "SMmsg.h"
#include "VDSFilter.h"
#include "SMspacecom.h"

#define MAX_SURF 	49
#define MAX_TEMP	50 	/* number of templates */


state start

  on CMD_TYPE = PLACE	do message_key SM_M_PlLmVl
  			do reset_form 
                       		on ERROR do status_key SM_E_ErInit
						state terminate
                        do display_form  0
  				state modif_form 
  				
  on CMD_TYPE = MODIFY	do message_key SM_M_MdLmVl state loc_macro
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

state restart

  on CMD_TYPE = PLACE	state modif_form 
  				
  on CMD_TYPE = MODIFY	do clear_form state reloc_macro

  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

state loc_macro
  prompt_key         SM_P_IdLmVl
  accept_key         SM_P_PlAccRej
  locate_class	     "SMLtdVol"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING   do clear_form
				       do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
		       do display_form  0
				state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

state reloc_macro
  prompt_key	     SM_P_IdLmVl
  accept_key         SM_P_PlAccRej
  locate_class	     "SMLtdVol"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING   do store_occ
                       on ERROR do status_key SM_E_ErStMc state terminate
				state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

state  modif_form 
  prompt_key         SM_P_IdHltTmp
  accept_key         SM_P_PlAccRej
  locate_class	     "EMSsurface "
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"
  filter              vds_locate_noauto

  on EX_DATA or EX_STRING  
  		do store_obj(&me->ret, MAX_SURF)
			on RETURN_CODE = NO_OBJ 
				do status_key SM_E_ErInvObj  state .
                       	on ERROR state terminate
		do next_row 
                       	on ERROR state terminate
                        on RETURN_CODE = END_TEMP do save_all 
						state restart
                        	
                state .
			
  on EX_RJT_MOVEON	do next_row	
                       		on ERROR state terminate
                        	on RETURN_CODE = END_TEMP do save_all 
                        				state restart
                        state .                 
  on EX_FORM_FINISHED   state terminate
  
  
  on GR_UNKNOWN_TYPE.LOAD_OCC  do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form


state load_from_occ
  prompt_key         SM_P_LcMacOc
  accept_key         SM_P_PlAccRej
  locate_class	     "SMLtdVol"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING  
			do store_occ 
                       		on ERROR state terminate
			state modif_form
				
  on GR_UNKNOWN_TYPE.LOAD_OCC  	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM state modif_form


at init   do init_all
at wakeup do verify_obj
	  do DispAll
at delete do delete_all

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in SMLtdNotif.I                                           */

action reset_form extern
action store_occ extern
action store_obj(long *sts ; int max_obj) extern
action save_all extern
action clear_form extern

action SMmodif_mac(int nb_new; struct GRid *new) extern

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
 me->consume = 0;	
 me->old_consume = 0;	   	
 me->start_index = 1;
 strcpy(me->macro_name,"SMLtdVol");
 strcpy(me->auto_name,"SMLtdVol_0");
 me->nb_col_limits = 2;
	
 if(me->mytype == MODIFY) 
     FIg_set_text(me->forms[0].form_ptr,F_TITLE,"Modify Limited Volume");

goto quit;

}

