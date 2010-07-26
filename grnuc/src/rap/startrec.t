command_string  GRC_M_StartRecord,0,GRStrtRcrd
class           "RAPcobCO" 
spec_path       "$PLATFORM/spec"
start_state     start
product_name    "$PLATFORM"
command_table   "gr.cmd"               /* this goes in $PLATFORM/config */

state_table
#include "coniindex.h"
#include "grmessage.h"
#include "msdef.h"


state *
on   EX_RESTART                                           state start
on   EX_BACK_UP                                           state -

state start
    msg_key         GRC_M_StartRecord
    execute         does_listener_exist
		       on SUCCESS
                          do status_key  GR_I_AlreadyRecording
			  do remove_last_command
							state terminate
		       on ERROR                         state get_filename

state get_filename
    prompt_key      GR_P_EntFil
    filter          get_event
on  TEXT_VALUE        do have_filename ( sts, 1 ) 
			 on MSINARG
				do status_key  GR_I_FlNotOvwr
							state terminate
			 on ERROR
			    	do status_key  GR_E_CannotOpenFile
							state terminate
			 on SUCCESS
			    do status_key  GR_I_startrecord
							state terminate
							state terminate
on  EX_BACK_UP                                          state .
