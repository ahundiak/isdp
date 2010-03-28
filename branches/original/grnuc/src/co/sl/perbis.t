/*

Name
  perbis.t

Description
  State table for "Place Perpendicular Bisector" command

Notes


 */

command_string  GRMPlcPerpBis,CO_ni_perbis,GRPPrBs    
synonym         GRMPlcPerpBis,CO_ni_perbis,EMPPrBs    
class           COnpt
spec_path       "$PLATFORM/spec"
start_state     start
product_name    "$PLATFORM"


state_table
#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"
#include "comisc.h"


state *
on   EX_RESTART                                          state start
on   EX_BACK_UP                                          state .


at wakeup 
  do show_assoc_mode(1)

at sleep 
  do show_assoc_mode(0)

state start
    message_key     GRC_M_PlcPerpBis
    prompt_key      GR_P_IdEleSegBis
    accept_key      GR_P_AccEndSeg
    relocate_key     GR_E_CouNoFndEle
    locate_class    "+GRlineseg, GRlinestr, GRplanar, GRcirarc, GRellarch, GRsubbc"
    locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
    locate_owner         "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS"
    locate_display       "SEGMENT_HILIGHT | ALL_WINDOWS"
    filter      locate
    construct_class   "GR3dlineseg"
on  EX_DATA
	do store_event_by_index( sts, 1 )
        do save_first_element
        do get_construct_env_from_dpb
        do copy_event(sts, &me->event1, &me->event2)
        do store_event_by_index( sts, 0 )
        do erase_hilite                        
        do locate_two_and_construct
	do convert_to_profile                                state start

