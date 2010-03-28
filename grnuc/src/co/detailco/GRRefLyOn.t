/*\
Description
   The REFERENCE FILE LAYERS ON command is used to define the layers 
   which are to be turned on for a reference file or a drawing view.

History
   Gray Winn    05/11/87    Creation date.
   Gray Winn    05/25/88    Changed to support drawing view.
   jhw          01/22/94    Added ability to locate PDM part reffiles.
\*/

command_string  GRMRefFlLyOn,CO_layeron,GRTrOnLyRf
class           COdetail
super_class     COtools
super_class     CEO_GSLOCATE
spec_path       "$grnuc/co/spec"
start_state     start
options		"siTC"
product_name    "$SOURCE"

state_table
#include "grmessage.h"
#include "lcdef.h"
#include "detailco.h"
#include <toolco.h>

state *
on EX_RESTART  do COtools.erase_highlight ()
               do COtools.empty_channel(&me->located_chansel) 
                                                    state start

state start
   message_key          GRC_M_RefFlLyOn
   prompt_key           GR_P_IdRefFlDrwVw
   accept_key           GR_P_AccRefFlDrwVw
   relocate_key         GR_E_EleNotFnd
   locate_eligible      "GRreffile, GRdrawview"
   locate_owner         "LC_NON_GEOM_MOD | LC_NO_REF_OBJECTS | LC_RIGID_COMP"
   locate_properties    "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY"
   locate_display       "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
   filter               gs_locate
on EX_DATA or TEXT_VALUE                        state have_drawview
on EX_BACK_UP                                   state .

state have_drawview
   prompt_key     GR_P_EntLys
   filter         get_event
on EX_BACK_UP                                   state -
on STRING      do COtools.erase_highlight ()
               do build_drawview_layers
               do change_drawview_layers (sts, 1)
               do display_mode GRbd
               do send_foreign(CO_display_drawview_layers)
                                                state have_drawview
