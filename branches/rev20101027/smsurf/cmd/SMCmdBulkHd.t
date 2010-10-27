/* $Id: SMCmdBulkHd.t,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/cmd / SMCmdBulkHd.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdBulkHd.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/01/06  20:16:06  pinnacle
# Replaced: smsurf/cmd/SMCmdBulkHd.t for:  by impd for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1997/02/06  21:18:34  pinnacle
# Created: smsurf/cmd/SMCmdBulkHd.t by jwfrosch for vds.241
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
 *	Description	Command object to place a
 *			bulkhead by projection of a profile
 */

command_string		SMC_M_PlBulkHd,0,SMPlBulkHd
synonym			SMC_M_MdBulkHd,1,SMMdBulkHd
/*
command_string		"Place Bulkhead",0,SMPlBulkHd
synonym			"Modify Bulkhead",1,SMMdBulkHd
*/
command_table		"sman.cmd"
class			SMCmdBulkHd
super_class		SMCmdSurf
product_name		"$VDS"
options			"si"

form			"SMBulkHead",0,0,"-1","-1"


/*************************************************************************/

state_table

#include "VDSFilter.h"
#include "SMSurf.h"
#include "SMmsg.h"

#define LOAD_PT		519

state start

  on CMD_TYPE = PLACE	do    message_key SM_M_PlBulkHd		/* message "Place Bulkhead"*/
			do    display_form  0
			state modif_form

  on CMD_TYPE = MODIFY	do    message_key SM_M_MdBulkHd		/* message "Modify Bulkhead"*/
			state loc_macro

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_PT		state load_point
  on GR_UNKNOWN_TYPE.LOAD_CS		state load_cs
  on GR_UNKNOWN_TYPE.RESTART		state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC		do    clear_form
						on ERROR state terminate
					state load_from_occ

state restart

  on CMD_TYPE = PLACE	state modif_form
  on CMD_TYPE = MODIFY	do    clear_form state reloc_macro

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_PT		state load_point
  on GR_UNKNOWN_TYPE.RESTART		state restart
  on GR_UNKNOWN_TYPE.LOAD_CS		state load_cs
  on GR_UNKNOWN_TYPE.LOAD_OCC		do    clear_form
						on ERROR state terminate
					state load_from_occ

state loc_macro
  prompt_key		SM_P_IdBulkHd 	/*	SM_P_IdLgCrBH	*/
  accept_key		SM_P_PlAccRej
  locate_class		"SMbulkhead"
  locate_owner		"LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter	vds_locate

  on EX_DATA or EX_STRING or EX_OBJID	do    clear_form
					do    store_occ
						on ERROR do status_key SM_E_ErStMc state terminate
					do    display_form  0
					state modif_form
  on GR_UNKNOWN_TYPE.LOAD_PT		state load_point
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS		state load_cs
  on GR_UNKNOWN_TYPE.RESTART		state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC		do    clear_form
						on ERROR state terminate
					state load_from_occ

state reloc_macro
  prompt_key		SM_P_IdBulkHd 	/*	SM_P_IdLgCrBH	*/
  locate_class		"SMbulkhead"
  locate_owner		"LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter	vds_locate

  on EX_DATA or EX_STRING or EX_OBJID	do    store_occ
						on ERROR do status_key SM_E_ErStMc state terminate
					state modif_form
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS		state load_cs
  on GR_UNKNOWN_TYPE.LOAD_PT		state load_point
  on GR_UNKNOWN_TYPE.RESTART		state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC		do    clear_form
						on ERROR state terminate
					state load_from_occ

state  modif_form
  prompt_key	SM_P_EntPrmFr
  filter	get_event

  on EX_FORM_FINISHED			state terminate

  on GR_UNKNOWN_TYPE.LOAD_CS		state load_cs

  on GR_UNKNOWN_TYPE.LOAD_PT		state load_point
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC		do    clear_form
						on ERROR state terminate
					state load_from_occ
  on GR_UNKNOWN_TYPE.RESTART		state restart


state load_cs
  prompt_key		SM_P_IdCrdStm
  accept_key		SM_P_PlAccRej
  locate_class		"GRlbsys"
  locate_owner		"LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter		vds_locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID	do    store_cs
						on ERROR state terminate
					state modif_form
  on EX_BACK_UP				state modif_form

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_PT		state load_point
  on GR_UNKNOWN_TYPE.LOAD_OCC		do    clear_form
						on ERROR state terminate
					state load_from_occ
  on GR_UNKNOWN_TYPE.LOAD_CS		state load_cs

state load_point
  prompt_key		SM_P_IdPt
  accept_key		SM_P_PlAccRej
  locate_class		"GRpoint"
  locate_owner		"LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter		vds_locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID	do    store_point
						on ERROR state terminate
					state modif_form
  on EX_BACK_UP				state modif_form

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_PT		state load_point
  on GR_UNKNOWN_TYPE.LOAD_OCC		do    clear_form
						on ERROR state terminate
					state load_from_occ
  on GR_UNKNOWN_TYPE.LOAD_CS		state load_cs


state load_from_occ
  prompt_key		SM_P_LcMacOc
  accept_key		SM_P_PlAccRej
  locate_class		"SMbulkhead"
  locate_owner		"LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter	vds_locate

  on EX_DATA or EX_STRING or EX_OBJID	do    store_occ
						on ERROR state terminate
					state modif_form

  on GR_UNKNOWN_TYPE.LOAD_OCC		do    clear_form
						on ERROR state terminate
					state load_from_occ

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_PT		state load_point
  on GR_UNKNOWN_TYPE.RESTART		state restart
  on GR_UNKNOWN_TYPE.LOAD_CS		state load_cs


at init		do init_all
at delete	do delete_all
at wakeup	do verify_obj
		do DispAll(GRhhd)
