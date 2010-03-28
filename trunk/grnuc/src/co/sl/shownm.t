command_string  GRMShownm,CO_ni_shownm,GRShNmEl
class           COnpt
start_state     start
spec_path       "$PLATFORM/co/spec"
product_name    "$PLATFORM"
command_table   "3416.dpt"

state_table
#include "coniindex.h"
#include "DIdef.h"
#include "grmessage.h"

at sleep     do erase_hilite

state start
   message_key       GRC_M_Shownm
   prompt_key        GR_P_Shownm
   relocate_key      GR_E_CouNoFndEle
   locate_eligible   "+GRgraphics"
   locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner      "LC_RIGID_COMP | LC_READ | LC_NO_REF_HEADER | LC_REF_OBJECTS | LC_HANDLES"
   locate_display    "ELEM_HILIGHT | LC_ACC_ONE_ELEMENT"
   filter            locate_noauto
   on EX_DATA
        do erase_hilite
        do store_event_by_index( sts, 0 )
        do store_locate_context
        do use_events
           on RETURN_CODE = DIR_W_NAME_NOT_FOUND
                do erase_hilite
                do clear_channels
                do status_key GR_E_CouNoFndEle                 state start
	   on ELSE
	     do save_first_element
             do display_mode GRhd
             do display_first_located_object
	     do clear_channels                              state start

                                                            state start
