/*
Name
        COPtInt

Description
        This file contains the transition table for the point at intersection
        command

History
        mrm     02/17/88    creation
                05/24/89    added auto accept, retrieve locate criteria
                10/26/89    don't push event back on queue for auto accept
                04/17/90    auto-accept two elements
*/

class               COevgen
super_class         CEO_LOCATE
command_object      GRMPtInscPt, COev_pt_intersection, GRSlPnIn
product_name        "$GRNUC"
options             "si"
start_state         locate_first_object

/*-----*/

state_table

#include "lcdef.h"
#include "coevindex.h"
#include "grmessage.h"

#define ACCEPT_POINT 1
#define LOCATE_POINT 2

state *
    on EX_RESTART or EX_BACK_UP
        do erase_hilite_plane ()
        state locate_first_object

state locate_first_object
    message_key GRC_M_PtInscPt
    prompt_key GR_P_IdEle
    accept_key GR_P_AccSecEle
    relocate_key GR_E_EleNotFnd
    locate_mask "GRm_DATA | GRm_OBJID"
    accept_mask "GRm_DATA | GRm_OBJID"
    locate_eligible "+GRbspline"
    locate_stack_size 2
    locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW
                     | IGN_MOD_BIT | IGN_PLANAR_BIT"
    locate_owner "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_RIGID_OWNER
                | LC_NO_FLEX_OWNER | LC_REF_HEADER | LC_REF_OBJECTS"
    locate_display "ALL_WINDOWS | NO_PROJ_ACCEPT_POINT | ACC_REJ_CYCLE | 
                    RELOCATE | LC_REGULAR_HIGHLIGHT | LC_ERASE_LOC_ELEMENT | 
                    SEGMENT_HILIGHT | LC_ACCEPT_CURSOR | LC_Retrieve_Criteria
                    | LC_ACC_ONE_ELEMENT | LC_ACC_TWO_ELEMENT"
    unhilight_mode GRhe
    filter locate
        on EX_DATA or EX_OBJID
            on RETURN_CODE = LC_ONE_ELEM_ACCEPT
                do store_event (ACCEPT_POINT,0)
                do store_event (LOCATE_POINT,2)
                do prompt_key GR_P_IdSecEle
                do display_segment (0, GRhd, GRhd)
                state locate_second_object
            on RETURN_CODE = LC_TWO_ELEM_ACCEPT
                do store_event (ACCEPT_POINT,0)
                do store_event (ACCEPT_POINT,1)
                do store_event (LOCATE_POINT,2)
                do store_event (LOCATE_POINT,3)
                do use_events ()
                    on SUCCESS
                        do push_event (0)
                        do disconnect_located 1
                        state terminate
		    on MANOSOLUTION 
			/* parallel or coincident, so ignore the        */
			/* second auto-accepted object and prompt the   */
			/* user to identify another one.                */
	                do prompt_key GR_P_IdSecEle
	                do display_segment (0, GRhd, GRhd)
	                state locate_second_object
                    on ELSE
                        do status_key GR_E_ErrEncCmdTrm
                        state terminate
                state terminate
            on RETURN_CODE = LC_OBJ_LOCATED
                do store_event (ACCEPT_POINT,0)
                do store_event (LOCATE_POINT,2)
                do push_event (0)
                state locate_second_object
            on ELSE
                state .
            state locate_second_object

state locate_second_object
    prompt_key GR_P_IdSecEle
    accept_key GR_P_AccApIscPt
    relocate_key GR_E_EleNotFnd
    locate_mask "GRm_DATA | GRm_OBJID | GRm_RESTART | GRm_BACK_UP"
    accept_mask "GRm_DATA"
    locate_eligible "+GRbspline"
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
            do erase_hilite_plane ()
            do use_events ()
                on SUCCESS
                    do push_event (0)
                    do disconnect_located 1
                    state terminate
                on MANOSOLUTION 
                    /* parallel or coincident, so prompt the   */
		    /* user to identify another one.           */
                    do status_key GR_E_CantIsectSelEle
	            do prompt_key GR_P_IdSecEle
	            do display_segment (0, GRhd, GRhd)
	            state locate_second_object
                on ELSE
                    do status_key GR_E_ErrEncCmdTrm
                    state terminate
            state terminate
