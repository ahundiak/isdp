command_string  GRMMdClpD,0,GRMdClPlDp
class           COref
product_name   "$SOURCE"
super_class    COtools
super_class    CEO_GSLOCATE
path           "."
spec_path      "$GRNUC/co/spec"
start_state    start
options        "siCT"

state_table

#include "grmessage.h"
#include "lcdef.h"

state *
on EX_RESTART  do COtools.erase_highlight ()             state start

state start
   message_key          GRC_M_MdClpD
   prompt_key           GR_P_IClpPl
   accept_key           GR_P_AccFrPt
   relocate_key         GR_E_EleNotFnd
   locate_eligible      "GRclippoly"

gslocate_num_inputs 		1
gslocate_spec_mask1 		"GRm_DATA | GRm_STRING"
gslocate_spec_prompt1_key 	GR_P_AccRejAtt

locate_class         "GRclippoly"
locate_owner         "LC_GEOM_MOD | LC_NO_REF_OBJECTS | LC_RIGID_COMP"
locate_properties    "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY"
locate_display       "ALL_WINDOWS | ELEM_HILIGHT | PROJ_ACCEPT_POINT"
locate_mask          "GRm_DATA | GRm_STRING"
accept_mask          "GRm_DATA | GRm_STRING"

filter    gs_locate

on EX_DATA or EX_STRING
                do save_clippoly()       
                do save_from_info()             state have_clipplane
on EX_BACK_UP   do COtools.erase_highlight ()   state .


state have_clipplane
    prompt_key          GR_P_EntDesPt
    dynamics            0 
    filter		get_event

on EX_DATA      do display_mode GRbehe
                do display_located
                do modify_clippoly
                do display_mode GRbd
                do display_located              state start
on EX_BACK_UP   do display_mode GRbdhe
                do display_located              state -
at delete       do COtools.erase_highlight ()

