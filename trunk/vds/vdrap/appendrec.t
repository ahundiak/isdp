/* $Id: appendrec.t,v 1.3 2002/02/28 20:57:25 ad Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrap / appendrec.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: appendrec.t,v $
 *	Revision 1.3  2002/02/28 20:57:25  ad
 *	Changes VDS into VDS_PATH
 *	
 *	Revision 1.2  2001/03/05 15:45:30  hans
 *	*** empty log message ***
 *	
 *	Revision 1.1  2001/03/02 22:55:52  hans
 *	Created
 *	
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *	03/02/2001	HF		Creation
 *					Adapted from GRNUC "start and record"
 *
 * -------------------------------------------------------------------*/

class           "VDRAPcobCO"

command_string  "Append ISDP Journaling",0,VDApndRcrd
product_name    "$VDS_PATH"
command_table   "vds.cmd"
options         "isTC"

start_state     start

state_table
#include "coniindex.h"
#include "grmessage.h"
#include "msdef.h"


state *
on   EX_RESTART                                           state start
on   EX_BACK_UP                                           state -

state start
    execute         does_listener_exist
                       on SUCCESS
                          do remove_last_command
                                                        state terminate
                       on ERROR                         state get_filename
state get_filename
    prompt_key      GR_P_EntFil
    filter          get_event
on  TEXT_VALUE        do have_filename ( sts, 0 )     /* process filename */
                                    /*        ^ append to file */
                         on MSINARG
                                do status_key  GR_I_FlNotOvwr
                                                        state terminate
                         on ERROR
                            do status_key  GR_E_CannotOpenFile
                                                        state terminate
                         on SUCCESS
                            do status_key  GR_I_AppendFile
                                                        state terminate
                                                        state terminate
on  EX_BACK_UP                                          state .
