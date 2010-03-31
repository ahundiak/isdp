command_string  GRMCreateXHatch,0,GRCrCr
class           ECaxhatch
status_display  "Crosshatch","-1","-1"
spec_path       "$MODEL/co/spec"
start_state     start
product_name    "$MODEL"
options         "Tsic"

state_table

#include "coniindex.h"
#include "lcdef.h"
#include "grmessage.h"
#include "comisc.h"

at init    do     display_active_parms(sts,CO_XH_SP_ANG)

at wakeup do status_display_button(1)

state *
on   EX_RESTART      do erase_hilite                   state start

state start
   message_key     GRC_M_CreateXHatch
   prompt_key      GR_P_IdentGeom
   accept_key      GR_P_Acc
   relocate_key    GR_E_CouNoFndEle
   locate_class    "GRpolygon,GRcompcurve,GRorthpoly,GRcircle,GRellipse,GRbspline"
   locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_PHY_CLOSED | IGN_RW_BIT"
   locate_owner "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS | LC_RIGID_COMP"
   filter      gs_locate
on DATA  or 
   EX_OBJID
		do erase_hilite
                do store_event_by_index( sts, 0 )
                do save_first_element
                do display_mode GRbdhd
                do display_first_located_object
                do delete_collection
                                                       state have_wireframe
state have_wireframe
    prompt_key GR_P_AutoDetBndY
    filter get_event
        on EX_RJT_MOVEON     or
           TEXT_VALUE = "y"  or
           TEXT_VALUE = "Y"  or
           TEXT_VALUE = ""
                do status_key GR_I_LcIntBnd
                do auto_load_boundaries                state create_crosshatch
        on TEXT_VALUE = "n"  or
           TEXT_VALUE = "N"   
                       state collect_boundaries
        on DATA   
                do store_event_by_index( sts, 0 )
                do push_first_event_on_queue           state collect_boundaries

state collect_boundaries
    prompt_key      GR_P_IdentHole
    accept_key      GR_P_AccNxtMvOn
    relocate_key    GR_E_CouNoFndEle
    locate_class  "GR3dlinestr,GRpolygon,GRcompcurve,GRorthpoly,GRcircle,GRellipse,GRbspline,GRgrgrp"
    locate_mask   "GRm_DATA | GRm_OBJID | GRm_BACK_UP | GRm_RJT_MOVEON"
    locate_owner  "LC_RIGID_COMP | LC_FLEX_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED" 
    locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_PHY_CLOSED | IGN_RW_BIT"
    filter      gs_locate
on DATA
                do display_mode GRhhd
                do display_located
                do add_to_collection     
                do push_accept_event_on_queue
                do copy_event(sts, &me->event1, &me->event2)
                                                        state .
on EX_OBJID
                do display_mode GRhhd
                do display_located
                do add_to_collection     
                                                        state .
on EX_RJT_MOVEON                                        state create_crosshatch
on EX_BACK_UP   
                do display_mode GRhhd
                do display_located
                do delete_last_entry_collection         state -

state create_crosshatch
on ELSE
                do status_key  GR_P_GenCrosHat
                do locate_two_and_construct 
                do erase_hilite
                do status ""
		do display_mode GRbd
                do display_first_located_object     
                                                        state start
