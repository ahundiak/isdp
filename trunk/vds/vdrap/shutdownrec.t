/* $Id: shutdownrec.t,v 1.3 2002/02/28 20:57:25 ad Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrap / shutdownrec.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: shutdownrec.t,v $
 *	Revision 1.3  2002/02/28 20:57:25  ad
 *	Changes VDS into VDS_PATH
 *	
 *	Revision 1.2  2001/03/05 15:45:40  hans
 *	*** empty log message ***
 *	
 *	Revision 1.1  2001/03/02 22:55:56  hans
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

command_string  "z Shutdown ISDP Journaling",0,VDShutRcrd
product_name    "$VDS_PATH"
command_table   "vds.cmd"
options         "isTC"

start_state     start

state_table
#include "grmessage.h"


state start
    execute         does_listener_exist
                       on ERROR
                          state terminate
                       on SUCCESS
                          do stop_record
                          state terminate
