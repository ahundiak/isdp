command_string GRMDrpRFS,0,GRDrRfFlSy
class          COref
product_name   "$SOURCE"
super_class    COtools
super_class    CEO_GSLOCATE
path           "."
spec_path      "$GRNUC/co/spec"
start_state    start
options        "siCT"

state_table

#include <grmessage.h>
#include <toolco.h>
#include <lcdef.h>


state *

on EX_RESTART  do COtools.erase_highlight ()           state start

state start

message_key     GRC_M_DrpRFS
prompt_key      GR_P_IdRefAtt
accept_key      GR_P_AccRejAtt
relocate_key    GRC_M_AttNotLoc
gslocate_num_inputs 1
gslocate_spec_mask1 "GRm_DATA | GRm_OBJID | GRm_STRING"
gslocate_spec_prompt1_key GR_P_AccRejAtt

locate_class    "+GRreffile,GRdrawview"
locate_display  "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
locate_properties   "LC_WRITE_ONLY | LC_LC_ONLY | LC_DP_ONLY"
locate_owner        "LC_NON_GEOM_MOD | LC_REF_HEADER | LC_REF_OBJECTS | LC_RIGID_COMP"
locate_mask     "GRm_DATA | GRm_OBJID | GRm_STRING"
accept_mask	"GRm_DATA | GRm_STRING"

filter    gs_locate

on EX_DATA or EX_OBJID or EX_STRING
                        do COtools.erase_highlight ()
                        do display_mode GRbe
			do display_located
                        do drop_ref_symbology 
                        do display_mode GRbd
                        do display_located              state .

at delete   do COtools.erase_highlight ()
            do status ""

