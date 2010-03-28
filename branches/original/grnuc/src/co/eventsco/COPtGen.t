/*
Name
        COPtGen

Description
        This file contains the transition table for the commands listed
        below.  Each of these commands performs a locate_object and calls a
        method on the located object to return the requested point.
        The "use_events" action calls a function which sends the appropriate
        message.  The function called is specified in an array of pointers
        to functions, indexed by command type.

            point at center
            point at endpoint
            point at keypoint
            point at midpoint
            point at project
            point at perpendicular from
            point at perpendicular to
            point at tangent from
            point at tangent to

History
        mrm     02/16/88    creation
                05/24/89    added auto accept, retrieve locate criteria
                09/25/89    removed auto accept from point at keypoint
                09/26/89    exclude text, raster, reference files
                10/11/89    removed auto accept from point at project
*/

class               COevgen
super_class         CEO_LOCATE
command_object      GRMPtCen,   COev_pt_center,             GRSlPnCn
synonym             GRMPtEnd,   COev_pt_end,                GRSlPnEn
synonym             GRMPtKyPt,  COev_pt_key,                GRSlPnKyp
synonym             GRMPtMidPt, COev_pt_mid,                GRSlPnMd
synonym             GRMPtPrjPt, COev_pt_project,            GRSlPnPrPn
synonym             GRMPtPrpFr, COev_pt_perpendicular_from, GRSlPnPrFr
synonym             GRMPtPrpTo, COev_pt_perpendicular_to,   GRSlPnPrT
synonym             GRMPtTgtFr, COev_pt_tangent_from,       GRSlPnTnFr
synonym             GRMPtTgtTo, COev_pt_tangent_to,         GRSlPnTnT
product_name        "$PLATFORM"
options             "si"
start_state         start

/*-----*/

state_table

#include "lcdef.h"
#include "coevindex.h"
#include "grmessage.h"

#define ACCEPT_POINT 1

state start
    on CMD_TYPE = COev_pt_center
        do message_key GRC_M_PtCen
        do accept_key GR_P_Acc
        do locate_eligible "+GRbspline, EMSrevol"

        do locate_display "ALL_WINDOWS | ELEM_HILIGHT | PROJ_ACCEPT_POINT
                        | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT
                        | LC_ERASE_LOC_ELEMENT | LC_Retrieve_Criteria
                        | LC_ACC_ONE_ELEMENT"
        state locate_object

    on CMD_TYPE = COev_pt_end
        do message_key GRC_M_PtEnd
        do accept_key GR_P_AccNrDsrEndPt
        do locate_eligible "+GRcurve"
        do locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT
                        | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT
                        | LC_ERASE_LOC_ELEMENT | LC_Retrieve_Criteria
                        | LC_ACC_ONE_ELEMENT"
        state locate_object

    on CMD_TYPE = COev_pt_key
        do message_key GRC_M_PtKyPt
        do accept_key GR_P_AccNrDsrKyPt
        do locate_eligible "!+EMScompsurf, SKconstraint, DMroot, DMdim, DMsrc, SKgmhndlpt, GRgrgrp, GRdrawview, GRdvattach, GRcompcurve"
        do locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT
                        | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT
                        | LC_ERASE_LOC_ELEMENT | LC_Retrieve_Criteria
                        | LC_ACC_ONE_ELEMENT"
        state locate_object

    on CMD_TYPE = COev_pt_mid
        do message_key GRC_M_PtMidPt
        do accept_key GR_P_Acc
        do locate_eligible "+GRcurve"
        do locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT
                        | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT
                        | LC_ERASE_LOC_ELEMENT | LC_Retrieve_Criteria
                        | LC_ACC_ONE_ELEMENT"
        state locate_object

    on CMD_TYPE = COev_pt_project
        do message_key GRC_M_PtPrjPt
        do accept_key GR_P_AccPtProj
        do locate_eligible "!+EMScompsurf, SKconstraint, DMroot, DMdim, DMsrc, SKgmhndlpt, GRgrgrp, GRsmhdr, GRclhdr, GRdrawview, GRdvattach, GRtext, GRrg, GRreffile, SKmgr"
        do locate_display "ALL_WINDOWS | SEGMENT_HILIGHT | PROJ_ACCEPT_POINT
                        | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT
                        | LC_ERASE_LOC_ELEMENT | LC_Retrieve_Criteria"
        state locate_object

    on CMD_TYPE = COev_pt_perpendicular_from
        do message_key GRC_M_PtPrpFr
        do accept_key GR_P_AccNrDsrPrpPt
        do locate_eligible "!+EMScompsurf, SKconstraint, DMroot, DMdim, DMsrc, SKgmhndlpt, GRgrgrp, GRsmhdr, GRclhdr, GRdrawview, GRdvattach, GRtext, GRrg, GRreffile, SKmgr"
        do locate_display "ALL_WINDOWS | SEGMENT_HILIGHT | PROJ_ACCEPT_POINT
                        | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT
                        | LC_ERASE_LOC_ELEMENT | LC_Retrieve_Criteria
                        | LC_ACC_ONE_ELEMENT"
        state locate_object

    on CMD_TYPE = COev_pt_perpendicular_to
        do message_key GRC_M_PtPrpTo
        do accept_key GR_P_AccNrDsrPrpPt
        do locate_eligible "!+EMScompsurf, SKconstraint, DMroot, DMdim, DMsrc, SKgmhndlpt, GRgrgrp, GRsmhdr, GRclhdr, GRdrawview, GRdvattach, GRtext, GRrg, GRreffile, SKmgr"
        do locate_display "ALL_WINDOWS | SEGMENT_HILIGHT | PROJ_ACCEPT_POINT
                        | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT
                        | LC_ERASE_LOC_ELEMENT | LC_Retrieve_Criteria
                        | LC_ACC_ONE_ELEMENT"
        state locate_object

    on CMD_TYPE = COev_pt_tangent_from
        do message_key GRC_M_PtTgtFr
        do accept_key GR_P_AccNrTgtPt
        do locate_eligible "!+EMScompsurf, SKconstraint, DMroot, DMdim, DMsrc, SKgmhndlpt, GRgrgrp, GRsmhdr, GRclhdr, GRdrawview, GRdvattach, GRtext, GRrg, GRreffile, SKmgr"
        do locate_display "ALL_WINDOWS | SEGMENT_HILIGHT | PROJ_ACCEPT_POINT
                        | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT
                        | LC_ERASE_LOC_ELEMENT | LC_Retrieve_Criteria
                        | LC_ACC_ONE_ELEMENT"
        state locate_object

    on CMD_TYPE = COev_pt_tangent_to
        do message_key GRC_M_PtTgtTo
        do accept_key GR_P_AccNrTgtPt
        do locate_eligible "!+EMSsurface, SKconstraint, DMroot, DMdim, DMsrc, SKgmhndlpt, GRgrgrp, GRsmhdr, GRclhdr, GRdrawview, GRdvattach, GRtext, GRrg, GRreffile, SKmgr"
        do locate_display "ALL_WINDOWS | SEGMENT_HILIGHT | PROJ_ACCEPT_POINT
                        | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT
                        | LC_ERASE_LOC_ELEMENT | LC_Retrieve_Criteria
                        | LC_ACC_ONE_ELEMENT"
        state locate_object

state locate_object
    prompt_key GR_P_IdEle
    relocate_key GR_E_EleNotFnd
    locate_mask "GRm_DATA | GRm_OBJID"
    accept_mask "GRm_DATA"
    locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW
                     | IGN_MOD_BIT | IGN_PLANAR_BIT"
    locate_owner "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_RIGID_OWNER
                | LC_NO_FLEX_OWNER | LC_REF_HEADER | LC_REF_OBJECTS"
    unhilight_mode GRhe
    filter locate
    on EX_DATA or EX_OBJID
       do store_event (ACCEPT_POINT,0)
       do use_events ()
          on SUCCESS or INFORMATION
             do push_event (0)
             do disconnect_located 1
             state terminate
          on ELSE
             do status_key GR_E_ErrEncCmdTrm
             state terminate
       state terminate
