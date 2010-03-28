/*
Name
        COdelete.t

Description
        This file contains the transition table for the Delete command.

History
        mrm     08/16/88    COBbed from existing command
                08/16/89    check return codes to avoid looping
                10/16/89    remove unhighlight_mode and erase after locate
        DLB     04/19/91    added LC_ASSOC & LC_EXT_CONST to locate_owner
*/

class               COchange
super_class         COdpb
super_class         COtools
super_class         CEO_GSLOCATE
command_object      GRMDel, COch_delete, GRDlE
product_name        "$PLATFORM"
options             "si"
spec_path           "$GRNUC/co/spec"
start_state         locate_object

state_table

#include <FI.h>
#include "cochindex.h"
#include "comndef.h"
#include "grmessage.h"

at wakeup
    do COtools.color_menu_button("**DlE", FI_RED)

at sleep
    do COtools.color_menu_button("**DlE", FI_BLACK)

state locate_object
    message_key GRC_M_Del
    prompt_key GR_P_IdEle
    accept_key GR_P_AccNxtEle
    gslocate_spec_prompt1_key GR_P_AccFnc
    relocate_key GR_E_EleNotFnd
    gslocate_num_inputs 1
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    accept_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    gslocate_spec_mask1 "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    locate_eligible "+GRgraphics,GRreffile"
    locate_properties "DELETE_LC_PROPS | LC_RW"
    locate_owner "DELETE_LC_OWNER | LC_DELETE_CMD | LC_REF_OBJECTS"
    locate_display "MANIP_LC_DISFLAG | LC_ACCEPT_CURSOR"
    filter gs_locate_noauto
        on EX_DATA or EX_OBJID or EX_STRING
            do display_mode GRbehe
            do display_located
            do use_events ()
                on SUCCESS or WARNING
                    do disconnect_located 1
                    do COtools.push_event (&me->event1)
                    state .
                on ERROR
                    do status_key GR_E_ErrEncCmdRst
                    do display_mode GRbd
                    do display_located
                    do disconnect_located 1
                    state .
            state .

