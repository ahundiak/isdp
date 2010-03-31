command_string  "z Turn Profile",0,ECturn
class           ECprims
super_class     COtools
super_class     CEO_LOCATE
spec_path       "$GRNUC/spec"
product_name    "$MODEL"
/* status_display  "ECExtFrm","-1","-1",1*/
options	        "siTC"
start_state     start

state_table
#include <OMerrordef.h>
#include <execmsg.h>
#include <grmessage.h>
#include <msdef.h>
#include <toolco.h>
#include <primco.h>

state *
on EX_RESTART                                   state start

state start
    on ELSE
        state get_profile

/* 
 * Locate profile to turn.
 */
state get_profile
    message       "Turn Profile"
    prompt        "Identify profile/curve or select curve from form"
    accept        "Accept/reject with first point of centerline"
    filter locate

on EX_DATA
    do COtools.store_event (&me->event1, EC_CURVE)
    do COtools.store_event (&me->event1, EC_AXIS_POINT1)
    do COtools.erase_highlight()
    state get_axis_point2

state get_axis_point1
    prompt   "Enter origin of centerline"

    filter   get_event

on EX_DATA
    do COtools.store_event (&me->event1, EC_AXIS_POINT1)
    state get_axis_point2

on EX_BACK_UP
    state get_profile

state get_axis_point2
    status   "Back-up to redefine origin of centerline"
    prompt   "Define centerline"
    dynamics EC_DY_CENTERLINE
    filter   get_event

on EX_DATA or EX_VALUE
    do COtools.store_event (&me->event1, EC_AXIS_POINT2)
    do COtools.assign (EC_TURN_END, &me->mode, CO_cin_to_int)
    state get_end_angle

on EX_BACK_UP
    state get_axis_point1

state get_start_angle
    status   "Back-up to redefine centerline"
    prompt   "Enter start angle or move-on"
    dynamics EC_DY_START_ANGLE

    filter   get_event

on ANGLE
    do COtools.store_event (&me->event1, EC_START_ANGLE)
    do COtools.assign (EC_TURN_START_END, &me->mode, CO_cin_to_int)
    state get_end_angle

on EX_RJT_MOVEON
    do COtools.assign (EC_TURN_END, &me->mode, CO_cin_to_int)
    state get_end_angle

on EX_BACK_UP
    state get_axis_point2

state get_end_angle
    status   "Back-up to specify a different start angle"
    prompt   "Enter sweep angle [360]"
    dynamics EC_DY_END_ANGLE

    filter   get_event

on ANGLE
    do COtools.compare (sts, EC_TURN_START_END, &me->mode, CO_cin_to_int)
        on CO_eq 
            do COtools.store (&me->event1, EC_END_ANGLE_WITH_START)
            do project (sts, EC_TURN)
            state get_profile
        on ELSE
            do COtools.store_event (&me->event1, EC_END_ANGLE)
            do project (sts, EC_TURN)
            state get_profile
    state get_profile

on EX_RJT_MOVEON
    do COtools.assign (EC_TURN_FULL, &me->mode, CO_cin_to_int)
    do project (sts, EC_TURN)
    state get_profile

on EX_BACK_UP
    state get_start_angle
    
at init
    do locate_eligible   "GRgraphics"
    do locate_owner      "LC_READ | LC_NO_REF_HEADER | LC_REF_OBJECTS"
    do locate_properties "LC_LC_ONLY | LC_RW | LC_DP_ONLY"
    do locate_display    "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    do COtools.assign (EC_TURN_FULL, &me->mode, CO_cin_to_int)    

at wakeup
    do status_key GR_I_StFmAvail
    do status_display_button(1)

at sleep
    do status_display_button(0)

at delete
    do COtools.erase_highlight()
