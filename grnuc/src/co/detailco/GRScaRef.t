/*\
Description
    The SCALE REREFERENCE FILE command is used to change the scale factor
    of a refernce file.  The reference file is scaled by a factor times 
    the current scale value of the reference file scale.

History
    Gray Winn       04/23/87    Creation date.
    Gray Winn       06/01/88    Change for reference files.
    jay wallingford 06/20/89    rewritten
    dkk             08/24/94    added LC_RIGID_COMP to owner_action
\*/

command_string  GRMScRefFl,CO_scaleref,GRScRfFl
class           COdetail
super_class     COtools
super_class     CEO_GSLOCATE
spec_path       "$grnuc/co/spec"
start_state     start
options		"siTC"
product_name    "$SOURCE"

state_table
#include <grmessage.h>
#include <lcdef.h>
#include <toolco.h>
#include "detailco.h"

state *
on EX_RESTART  do COtools.erase_highlight ()    state start

state start
   message_key  GRC_M_ScRefFl
   prompt_key   GR_P_EntScFac
   filter       get_event
on EX_BACK_UP                                   state .
on SCALAR      do COtools.assign ( &me->event1.event.value,
                                   &me->scale,
                                   CO_dbl_to_dbl )
                                                state have_scale_factor

state have_scale_factor
    prompt_key           GR_P_IdRefFl
    accept_key           GR_P_AccOrgSc
    relocate_key         GR_E_EleNotFnd
    locate_class         "GRreffile"
    locate_owner         "LC_GEOM_MOD | LC_NO_REF_OBJECTS | LC_RIGID_COMP"
    locate_properties    "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY"
    locate_display       "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    locate_mask          "GRm_TEXT_VALUE | GRm_DATA"
    filter               gs_locate
on EX_BACK_UP                                   state -
on EX_DATA
                do COtools.erase_highlight()
                do COtools.assign ( &me->event1.event.button,
                                    &me->window_id,
                                    CO_btn_to_grid )
                do COtools.assign ( &me->event1.event.button,
                                    me->window_matrix,
                                    CO_btn_to_mtx )
                do display_mode GRbe
                do display_located
                do scale_reference_file
                do display_mode GRbd
                do display_located 
                do COtools.empty_channel(&me->located_chansel) 
                                                state have_scale_factor
