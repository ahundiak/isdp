command_string GRMChgRefAtt,0,GRCRfFlAt
class          COref
product_name   "$SOURCE"
super_class    COtools
super_class    CEO_GSLOCATE
path           "."
spec_path      "$GRNUC/co/spec"
start_state    start
options        "siCT"

state_table

#include <OMerrordef.h>
#include <execmsg.h>
#include <grmessage.h>
#include <toolco.h>
#include "referr.h"

state *

on EX_RESTART   do COtools.erase_highlight ()   state start

state start

message_key     GRC_M_ChgRefAtt
prompt_key      GR_P_IdRefAtt
accept_key      GR_P_AccRejAtt
relocate_key    GRC_M_AttNotLoc

gslocate_num_inputs 1
gslocate_spec_mask1 "GRm_DATA | GRm_STRING"
gslocate_spec_prompt1_key GR_P_AccRejAtt

locate_eligible "GRreffile,GRdrawview"
locate_owner        "LC_REF_HEADER"
locate_properties   "LC_WRITE_ONLY | LC_LC_ONLY | LC_DP_ONLY"
locate_display  "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
locate_mask     "GRm_DATA | GRm_STRING"
accept_mask     "GRm_DATA | GRm_STRING"

filter    gs_locate

on EX_DATA or EX_STRING                       state get_filename

state get_filename

prompt_key  GR_P_EntFil

filter  get_event

on TEXT_VALUE       do COtools.access_file ( sts,
                                            (CO_file_exists | CO_file_reg | CO_file_read),
                                             me->event1.event.keyin,
                                             0 )
    on MSSUCC       do COref.assign_filename ( me->event1.event.keyin )
                    do COref.assign_name ( "" )
                    do display_mode GRbehe
                    do display_located                  state change_reffile
    on MSFAIL       do status_key GR_E_FlNotFnd         state .
                                                        state .
on EX_BACK_UP       do COtools.erase_highlight()        state -


state change_reffile

execute COref.assign_grid ()

execute change_reference_filename

on OM_I_DUPLICATE_OS 
                    do display_mode GRbd
                    do display_located
                    do error_box_key EX_F_DupIntOSName 
                                                    state start
on MSSUCC           do display_mode GRbd
                    do display_located              state start
on MSFAIL           do display_mode GRbd
                    do display_located              state start

at delete   do COtools.erase_highlight ()
            do status ""

