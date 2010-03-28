command_string  GRC_M_StopRecord,0,GRStopRcrd
class           "RAPcobCO" 
spec_path       "$PLATFORM/spec"
start_state     start
product_name    "$PLATFORM"
command_table   "gr.cmd"               /* this goes in $PLATFORM/config */

state_table
#include "coniindex.h"
#include "grmessage.h"


state start
    msg_key         GRC_M_StopRecord
    execute         does_listener_exist
		       on ERROR
                          do status_key  GR_I_NotRecording
							state terminate
		       on SUCCESS
		          do stop_record
                          do status_key  GR_I_StopRecording
							state terminate
