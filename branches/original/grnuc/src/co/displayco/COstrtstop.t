options			"si" 
product_name		"$GRNUC"
class			COceocmds
command_string		GRMDrftSst,6,GRDrftSst

start_state     stop_state

state_table

#include 	"grmessage.h"
#include        "codpdef.h"

state	stop_state

	execute action2
