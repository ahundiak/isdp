command_string  GRMRvSyOv,0,GRRvSyOv
class           DEnpt
start_state     start
spec_path       "$PLATFORM/spec"
product_name    "$PLATFORM"
command_table   "3416.dpt"

state_table
#include "dedef.h"
#include "lcdef.h"
#include "grmessage.h"

state *
on  EX_BACK_UP or EX_RJT_MOVEON
    do erase_hilite
                                                    state start

state start
    message_key GRC_M_RvSyOv
    prompt_key  GR_P_IdWin
    filter  get_event

    on DATA or TEXT_VALUE
       do erase_hilite
       do store_event_by_index( sts, 0 )
       do show_sym_o
                                                    state get_group

state get_group
    locate_display    "ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
    locate_owner      "LC_READ | LC_REF_OBJECTS"
    locate_class      "GRgraphics"
    unhighlight_mode  "GRhe"
    gslocate_num_inputs 0
    filter gs_locate_noauto

    on EX_OBJID
       do store_event_by_index( sts, 1 )
       do show_only_soo
       do process_group
       on RETURN_CODE = MSFAIL
	  do status_key GR_S_SyOvNtFnd
                                                    state start
       on RETURN_CODE = MSSUCC
	  do status_key GR_I_DpCmpl
                                                    state start
                                                    state start
