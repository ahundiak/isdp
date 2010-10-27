/* $Id: elinmaster.sl,v 1.1 2002/04/12 20:48:34 ramarao Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/grnuc/elinmaster.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: elinmaster.sl,v $
 *      Revision 1.1  2002/04/12 20:48:34  ramarao
 *      Moved elinmaster.sl file from emsfixes/grnuc to vdpocket/cmd directory.
 *
 *      Revision 1.1  2001/03/08 19:13:30  ramarao
 *      Added this in elinmaster.sl file in cvs.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/29/00        Rama Rao        Added a new command.
 *	04/12/02	Rama Rao	Moved the command from emsfixes to 
 *					vdpocket/cmd directory.
 ***************************************************************************/
/*\
Description
   This is the command class for the input tool which generates
   all the elements in the master file.

History
   Gray Winn    07/01/87       Creation date.
\*/

command_string  "Elements in Current File",0,GRSlAlF
synonym		"Elements in All Files",100,GRSlAlE
class           COgrpevent
start_state     start
product_name    "$VDS"
command_table   "vds.cmd"

state_table

#include "grmessage.h"
#include "msdef.h"

state start
on CMD_TYPE = 0     do  message   "Elements in Current File"
                    do  status    "Processing all elements in current file"
                    state       process

on CMD_TYPE = 100   do  message	  "Elements in All Files"
            	    do	status	  "Processing all elements in all files"
		    state   process

state process
on ELSE        do clear_layers_flag
               do construct_graphics_set
               do start_transition_for_graphics_set
               do build_locate_criteria
               do generate_select_set_from_all_elements
               do end_transition_for_graphics_set
               do define_active_select_set_from_graphics_set
                   on RETURN_CODE = "MSFAIL"
                        do status_key GR_E_EleNotFnd
                                                   state terminate
               do put_select_set_on_queue
                                                   state terminate
