/*
Name
        COsnap

Description
        This file contains the transition table for the snap command.

Notes
        The order in which the return codes from the locate filter are
        checked is very important.

History
        mrm     06/05/90    creation
*/

class               COevgen
super_class         CEO_LOCATE
command_object      GRMPnSnPn, COev_pt_snap, GRPnSnPn
product_name        "$GRNUC"
options             "si"
start_state         locate_object

/*-----*/

state_table

#include "lcdef.h"
#include "coevindex.h"
#include "grmessage.h"

#define ACCEPT_POINT 1
#define LOCATE_POINT 2

state locate_object
    message_key GRC_M_PnSnPn
    prompt_key GR_P_IdEle
    accept_key GR_P_AccKyPt
    relocate_key GR_E_EleNotFnd
    locate_mask "GRm_DATA | GRm_OBJID"
    accept_mask "GRm_DATA"
    locate_eligible "!+EMScomposite,GRgrgrp,GRdrawview,GRdvattach"
    locate_stack_size 2
    locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT
                    | DO_NOT_RELOCATE | LC_ERASE_ALL | LC_Retrieve_Criteria
                    | LC_ACC_ONE_ELEMENT | LC_ACC_TWO_ELEMENT"
    locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW | IGN_MOD_BIT |
                       IGN_PLANAR_BIT"
    locate_owner "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_RIGID_OWNER |
                  LC_NO_FLEX_OWNER | LC_REF_HEADER | LC_REF_OBJECTS"
    filter locate
        on RETURN_CODE = LC_ONE_ELEM_ACCEPT /* one object was auto-accepted */
            do store_event (ACCEPT_POINT,0)
            do use_events ()
                on SUCCESS or INFORMATION
                    do push_event (0)
                    do display_coords (0)
                    do disconnect_located 1
                    state terminate
                on ELSE
                    do status_key GR_E_ErrEncCmdTrm
                    state terminate
            state terminate
        on RETURN_CODE = LC_TWO_ELEM_ACCEPT /* two objects were auto-accepted */
            do store_event (ACCEPT_POINT,0)
            do store_event (ACCEPT_POINT,1)
            do store_event (LOCATE_POINT,2)
            do store_event (LOCATE_POINT,3)
            do use_events ()
                on SUCCESS or INFORMATION
                    do push_event (0)
                    do display_coords (0)
                    do disconnect_located 1
                    state terminate
                on ELSE
                    do status_key GR_E_ErrEncCmdTrm
                    state terminate
            state terminate
/*
        This code may be used with NO_ACC_REJ_CYCLE in the display flag
        to intersect the first two elements found.  For now, the user
        will enter an accept/reject cycle to determine which two objects
        are desired. 

        on RETURN_CODE = LC_OBJS_IN_STACK   /* more than two objects found * /
            do store_event (LOCATE_POINT,0)
            do store_event (LOCATE_POINT,1)
            do store_event (LOCATE_POINT,2)
            do store_event (LOCATE_POINT,3)
            do use_events ()
                on SUCCESS or INFORMATION
                    do push_event (0)
                    do display_coords (0)
                    do disconnect_located 1
                    state terminate
                on ELSE
                    do status_key GR_E_ErrEncCmdTrm
                    state terminate
            state terminate
*/
        on RETURN_CODE = LC_OBJ_LOCATED     /* one object accepted */
            do store_event (ACCEPT_POINT,0)
            do store_event (LOCATE_POINT,2)
            do push_event (0)
            state locate_second_object
        on GR_UNKNOWN_TYPE                  /* return input to cmdserver */
            state suspend
        on RETURN_CODE = LC_NO_OBJ_LOCATED  /* no objects located */
            do display_coords (2)
            state terminate

state locate_second_object
    prompt_key GR_P_IdSecEle
    accept_key GR_P_AccApIscPt
    relocate_key GR_E_EleNotFnd
    locate_mask "GRm_DATA | GRm_OBJID | GRm_RESTART | GRm_BACK_UP"
    accept_mask "GRm_DATA"
    locate_eligible "+GRcurve"
    locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW
                     | IGN_MOD_BIT | IGN_PLANAR_BIT"
    locate_owner "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_RIGID_OWNER
                | LC_NO_FLEX_OWNER | LC_REF_HEADER | LC_REF_OBJECTS"
    locate_display "ALL_WINDOWS | NO_PROJ_ACCEPT_POINT | ACC_REJ_CYCLE | 
                    RELOCATE | LC_REGULAR_HIGHLIGHT | LC_ERASE_LOC_ELEMENT | 
                    SEGMENT_HILIGHT | LC_Retrieve_Criteria | LC_ACC_ONE_ELEMENT"
    unhilight_mode GRhe
    filter locate_noauto
        on EX_DATA
            do store_event (ACCEPT_POINT,1)
            do store_event (LOCATE_POINT,3)
            do display_mode GRhe
            do display_located
            do use_events ()
                on SUCCESS or INFORMATION
                    do push_event (0)
                    do disconnect_located 1
                    state terminate
                on ELSE
                    do status_key GR_E_ErrEncCmdTrm
                    state terminate
            state terminate
        on EX_RESTART or EX_BACK_UP
            state locate_object
