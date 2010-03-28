command_string  GRMFncPlEle,0,GRFncPlEle
class           COgrpevent
super_class     CEO_GSLOCATE
product_name    "$SOURCE"
command_table   "4853.dpt"
start_state     start

state_table
#include "grmessage.h"
#include "referr.h"
#include "grerr.h"
#include "msdef.h"

state *
on EX_RESTART                                   state start

state start
   message_key       GRC_M_FncPlEle
   prompt_key        GR_P_IdEle
   accept_key        GR_P_Acc
   relocate_key      GR_E_EleNotFnd
   locate_eligible   "+GRbspline"
   locate_owner      "LC_READ | LC_NO_REF_HEADER | LC_REF_OBJECTS"
   locate_properties "LC_LC_ONLY | LC_RW | LC_DP_ONLY | LC_PLANAR_ONLY | LC_PHY_CLOSED"
   locate_display    "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
   filter gs_locate
on EX_BACK_UP                                         state .
on EX_DATA or TEXT_VALUE
                     do clear_highlight
                     do define_fence
                     do empty_graphics_set
                                                      state start
