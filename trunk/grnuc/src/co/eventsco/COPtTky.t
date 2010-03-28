/*
Name
        COPtTky

Description
        This file contains the transition table for the tentative keypoint
        snap command.

Notes
        The order in which the return codes from the locate filter are
        checked is very important.  For instance, accepting with a dx=
        keyin returns both GR_UNKNOWN_TYPE and LC_NO_OBJ_LOCATED, but
        GR_UNKNOWN_TYPE is the response which should be processed (i.e.
        return input to the command server).

History
        mrm     02/13/87    creation
                02/22/88    COBbed
                01/12/89    check for unknown input
                05/24/89    added retrieve locate criteria
                03/01/90    display locate coordinates if all objects rejected
*/

class               COevgen
super_class         CEO_LOCATE
command_object      GRMTenKyPtSnp, COev_pt_tentative_key, GRSlTnPnKy
product_name        "$PLATFORM"
options             "si"
start_state         locate_object

/*-----*/

state_table

#include "lcdef.h"
#include "coevindex.h"
#include "grmessage.h"

#define ACCEPT_POINT 1

state locate_object
    message_key GRC_M_TenKyPtSnp
    prompt_key GR_P_IdEle
    accept_key GR_P_AccKyPt
    relocate_key GR_E_EleNotFnd
    locate_mask "GRm_DATA | GRm_OBJID"
    accept_mask "GRm_DATA"
    locate_eligible "~+EMScomposite, GRgrgrp, GRdrawview, GRdvattach"
    locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT
                    | DO_NOT_RELOCATE | LC_ERASE_ALL | LC_Retrieve_Criteria"
    locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW | IGN_MOD_BIT |
                       IGN_PLANAR_BIT"
    locate_owner "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_RIGID_OWNER |
                  LC_NO_FLEX_OWNER | LC_REF_HEADER | LC_REF_OBJECTS"
    execute setup_select_handler ()
    filter locate_noauto
        on EX_RJT_MOVEON                    /* located objects all rejected */
            do display_coords (2)
            state terminate
        on RETURN_CODE = LC_OBJ_LOCATED     /* an object was accepted */
            do store_event (ACCEPT_POINT,0)
            do push_event (0)
            do disconnect_located 1
            state terminate
        on GR_UNKNOWN_TYPE                  /* return input to cmdserver */
            state suspend
        on RETURN_CODE = LC_NO_OBJ_LOCATED  /* no objects located */
            do display_coords (2)
            state terminate
