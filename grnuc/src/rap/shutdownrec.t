command_string  GRC_M_ShutdownRcrd,0,GRShRc
class           "RAPcobCO" 
spec_path       "$PLATFORM/spec"
start_state     start
product_name    "$PLATFORM"
command_table   "gr.cmd"               /* this goes in $PLATFORM/config */

state_table
#include "grmessage.h"


state start
    execute         does_listener_exist
		       on ERROR
			  state terminate
		       on SUCCESS
		          do stop_record
			  state terminate
