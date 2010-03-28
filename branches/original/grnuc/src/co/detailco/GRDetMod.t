/*\
Description
    This command can be used to disaccociate a model (i.e. reference file)
    from a drawing view.  The drawing view is not deleted.  The drawing
    view becomes eligible for another model to be attached.

History
    Gray Winn       04/23/87    Creation date.
    Gray Winn       05/26/88    Modified for drawing view concept
    jay wallingford 06/20/89    Rewritten
\*/

command_string  GRMDtcMdl,CO_detachmd,GRDtMdFrDr
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
#include "detailco.h"
#include <toolco.h>

state *
on EX_RESTART        do COtools.erase_highlight()   state start

state start
    message_key       GRC_M_DtcMdl
    prompt_key        GR_P_IdDrwVw
    accept_key        GR_P_AccDrwVw
    relocate_key      GR_E_EleNotFnd
    locate_eligible    "GRdrawview"
    locate_owner      "LC_GEOM_MOD | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS"
    locate_properties "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY"
    locate_display    "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter            gs_locate
on EX_DATA or TEXT_VALUE
        do COtools.erase_highlight ()
        do display_mode GRbe
        do send_foreign (CO_display_drawing_views)
        do send_foreign (CO_detach_model)
        do display_mode GRbd
        do send_foreign (CO_display_drawing_attachments)
        do COtools.empty_channel(&me->located_chansel)
                                                        state start
