/*
Name
        COundelete.t

Description
        This file contains the transition table for the Undelete and the
        Undelete On/Off commands.

History
        mrm     08/16/88    COBbed from existing commands
*/

class               COchange
super_class         COdpb
super_class         COtools
super_class         CEO_GSLOCATE
command_object      GRMUndelete, COch_undelete, GRUnE
synonym             GRMUndelOnOff, COch_undel_toggle, GRTgUn
product_name        "$PLATFORM"
options             "si"
spec_path           "$GRNUC/co/spec"
start_state         start

state_table

#include "cochindex.h"
#include "grmessage.h"

state start
    on CMD_TYPE = COch_undelete
        do use_events ()
            on RETURN_CODE = GR_F_UndelOff
                do status_key GR_F_UndelOff
                state terminate
            on RETURN_CODE = GR_F_NothUndel
                do status_key GR_F_NothUndel
                state terminate
            on SUCCESS
                state terminate
            on FAILURE
                do status_key GR_F_ErrEncCantUndel
                state terminate
        state terminate
    on CMD_TYPE = COch_undel_toggle
        do use_events ()
            on RETURN_CODE = 0
                do status_key GR_I_UndelOff
                state terminate
            on RETURN_CODE = 1
                do status_key GR_I_UndelOn
                state terminate
        state terminate
