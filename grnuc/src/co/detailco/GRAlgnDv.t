/*\
Description
    The REALIGN DRAWING VIEW command realigns two drawing views.

History
    jay wallingford 06/20/89    Creation date
\*/

command_string  GRMReAlgnDrwVw,CO_realigndv,GRAlDrV
class           COdetail
super_class     COtools
super_class     CEO_GSLOCATE
spec_path       "$grnuc/co/spec"
product_name    "$SOURCE"
options		"siTC"
start_state     start

state_table
#include <grmessage.h>
#include <referr.h>
#include <grerr.h>
#include <msdef.h>
#include <toolco.h>
#include "detailco.h"

state *
on EX_RESTART                                   state start

state start
    message_key          GRC_M_ReAlgnDrwVw
    prompt_key           GR_P_IdDrwVwRefAlgn
    accept_key           GR_P_AccDrwVw
    relocate_key         GR_E_EleNotFnd
    locate_eligible      "GRdrawview"
    locate_owner         "LC_READ | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS"
    locate_properties    "LC_LC_ONLY | LC_RW | LC_DP_ONLY"
    locate_display       "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter gs_locate
on EX_BACK_UP                                         state .
on EX_DATA or TEXT_VALUE
        do COtools.erase_highlight()
        do COtools.assign ( &me->event1.event.button,
                            &me->window_id,
                            CO_btn_to_grid )
        do COtools.assign ( &me->event1.event.button,
                            me->window_matrix,
                            CO_btn_to_mtx )
        do COtools.assign ( &me->located_chansel,
                            &me->dv_id1,
                            CO_gschan_to_grid )
        do COtools.empty_channel ( &me->located_chansel)
                                                      state have_draw_view1

state have_draw_view1
    prompt_key          GR_P_IdDrwVwAlgn
    accept_key          GR_P_AccDrwVw
    relocate_key        GR_E_EleNotFnd
    locate_eligible     "GRdrawview"
    locate_owner        "LC_GEOM_MOD | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS"
    locate_properties   "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY"
    locate_display      "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter gs_locate
on EX_BACK_UP                                         state -
on EX_DATA or TEXT_VALUE
        do COtools.erase_highlight ()
        do display_mode GRbe
        do display_located
        do send_foreign (CO_realign_drawing_view)
            on RETURN_CODE = "MSFAIL"
                do status_key  GR_E_DrwVwNotOrthoAlgn
                do display_mode GRbd
                do display_located
                do COtools.empty_channel(&me->located_chansel)
                                                     state have_draw_view1
                do display_mode GRbd
                do display_located
                do COtools.empty_channel(&me->located_chansel)
                                                     state have_draw_view1
