/*
	I/STRUCT
	"Delete Local Database Data" command.
*/
command_string	VSC_M_VSDlLcDtDt,0,VSDlLcDtDt
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSdllcdtCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "vscmddef.h"
#include "VSmsg.h"

state start
	message_key	VS_M_VSDlLcDtDt
	execute		delRDBCache()
        on ELSE
			do status_key VS_I_Done
			do waitTimer( 4 )
			state terminate
/*----------------------------------------------------------------------------*/
