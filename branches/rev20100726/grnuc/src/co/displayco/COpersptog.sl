/*
	This file defines and implements the following commands:

	   Toggle Perspective Behavior

		   "Change Perspective Behavior", GRTgPrBh, COTogPerBh, 0

*/

class              COTogPerBh
super_class        CEO_LOCATE
command_string     GRC_M_TogPerBh,0,GRTgPrBh 
product_name       "$GRNUC"
start_state        start

state_table
#include "grmessage.h"

implementation

#include "dpcodef.h"
#include "dpcomacros.h"
#include "grmessage.h"

%safe
#include "DPcodpbi.h"
%endsafe

state start
      message_key GRC_M_TogPerBh
   on ELSE
      do toggle_perspective_flags
      state terminate

/*--- toggle_perspective_flags--------------------------------------------*/

action toggle_perspective_flags
/*
DESCRIPTION
	This action toggles the perspective flags between TRUE and FALSE.
	TRUE means that the eyepoint is moved to change view
	FALSE means that the viewing angle is changed
	It applies to perspective view only and in the functios fit, zoom in,
	zoom out, and window area.
*/

	{
	IGRushort pflag;

	dp$codpb_get_persp_flags( persp_flags= &pflag );
	pflag = pflag ^ PERSP_CHANGE_ANGLE;
	if ( pflag & PERSP_CHANGE_ANGLE )
	{
	   ex$message( msgnumb = GR_I_ChangeAngle );
	}
	else
	{
	   ex$message( msgnumb = GR_I_ChangeEyept );
	}

	dp$codpb_set_persp_flags ( 
		persp_flags = pflag);
	}  /* toggle_perspective_flags */

