command_string  GRMXHSpaceAng,0,GRCSpAnCr

/* 
 *  this synonym allows "xh" to be found in the command table 
 */
synonym         GRMXH,0,GRCSpAnCr
class           ECaxhatch
start_state     start
spec_path       "$MODEL/co/spec"
product_name    "$MODEL"
options         "Tsic"

state_table
#include "grmessage.h"

state *
on  EX_RESTART                                              state start
on  EX_BACK_UP                                              state -

state start
    message_key   GRC_M_XHSpaceAng
    on NO_INPUT_PENDING
    do        display_xh_spacing                           state get_spacing
    on ELSE                                                state get_spacing

state get_spacing
    prompt_key    GR_P_EntSpacing
    filter        get_event

   on DISTANCE.GRst_DEFAULT or
      DISTANCE > 0.0
        do change_crosshatch_spacing                       state angle_prompt

   on DISTANCE
        do status_key GR_E_DsLT1                           state .


state angle_prompt
   on NO_INPUT_PENDING
   do        display_xh_angle                              state get_angle
   on ELSE                                                 state get_angle


state get_angle
    prompt_key    GR_P_EntAng
    filter        get_event

    on  ANGLE 
	   do change_crosshatch_angle 
           do status " "                                   state terminate

    on  EX_BACK_UP                                         state start 
