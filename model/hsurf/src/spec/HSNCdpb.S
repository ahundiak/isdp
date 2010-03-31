
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

class specification HSNCdpb (1:0) of global_class;


#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"

instance HSNCdpb
	{
	IGRint		display_mode;
	IGRint		simulation_speed;
	IGRint		shading_style;
	};


override super_construct;

message get_verification_parms(	IGRint *display_mode;
				IGRint *simulation_speed;
				IGRint *shading_style );
message put_verification_parms(	IGRint display_mode;
				IGRint simulation_speed;
				IGRint shading_style );


end specification HSNCdpb;
 
 
