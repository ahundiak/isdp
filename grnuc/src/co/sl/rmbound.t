command_string  GRMDlSyOv,0,GRDrSnSyOv
class           DEnpt
start_state     start
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"
command_table   "3416.dpt"

state_table
#include "dedef.h"
#include "lcdef.h"
#include "grmessage.h"

at sleep
     do show_all

state *
   on EX_BACK_UP or EX_RJT_MOVEON
        do erase_hilite
        do set_all_windows
                                                        state start

state start
   message_key      GRC_M_DlSyOv
   prompt_key       GR_P_IdSymOvr
   accept_key       GR_P_AcNxSyOv
   relocate_key     GR_E_CouNoFndEle
   locate_class     "GRlineseg,GRlinestr,GRconic,GRpolygon,GRorthpoly,GRorthlnst,GRpllnstr,GRbcsubbc,GRtext"
   locate_properties   "LC_LC_ONLY | LC_RW | LC_DP_ONLY"
   locate_owner   "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS | LC_INVIS_OVERRIDE"
   locate_display   "ELEM_HILIGHT | ALL_WINDOWS"
   on ELSE
                                                        state get_element

state get_element
   filter DE_LOCATE1
   on DATA
        do store_locate_context
        do get_locate_window
        do store_locate_event_by_index( sts, 0 )
        do store_event_by_index( sts, 1 )
        do project_locate_point( sts, 0, 1 )
        do set_one_window
        do display_mode GRbehe
        do display_object
        do erase_hilite
        do remove_sym_o
           on ERROR
              do show_all
              do update_one_win
              do display_object
              do status_key  GR_E_ErrInCalc
                                                        state start
        do display_mode GRbd
        do display_object
        do push_accept_event_on_queue
        do prompt_key GR_P_AcNxSyOv
                                                        state .
