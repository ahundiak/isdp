command_string  "z Extrude Profile",0,ECextrude
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
 * Locate profile to extrude.
 */
state get_profile
    message       "Extrude Profile"
    prompt        "Identify profile/curve or select curve on form"
    accept        "Accept/reject profile/curve"
    filter locate

on EX_DATA or TEXT_VALUE
    do COtools.store_event (&me->event1, EC_CURVE)
    do COtools.store_event (&me->event1, EC_FROM_POINT)
    state get_to_point

state get_from_point
    prompt   "Enter first point of extrusion axis"
    filter   get_event

on EX_BACK_UP
    state get_profile

on EX_DATA
    do COtools.store_event (&me->event1, EC_FROM_POINT)
    state get_profile

/*
 * Get to point.
 */
state get_to_point
    status   "Move-on to toggle orthogonality"
    prompt   "Enter second point of extrusion axis"
    dynamics EC_DY_EXTRUDE
    filter   get_event

on EX_BACK_UP
    state get_from_point

on EX_RJT_MOVEON
    do COtools.assign ( !me->mode, &me->mode, CO_cin_to_int )
    state .

on EX_DATA
    do COtools.store_event (&me->event1, EC_TO_POINT)
    do project (sts, EC_EXTRUDE)
    state get_profile

at init
    do locate_eligible   "GRgraphics"
    do locate_owner      "LC_READ | LC_NO_REF_HEADER | LC_REF_OBJECTS"
    do locate_properties "LC_LC_ONLY | LC_RW | LC_DP_ONLY"
    do locate_display    "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    do COtools.assign (EC_EXTRUDE_ORTHO, &me->mode, CO_cin_to_int)

at wakeup
    do status_key GR_I_StFmAvail
    do status_display_button(1)

at sleep
    do status_display_button(0)

at delete
    do COtools.erase_highlight()

