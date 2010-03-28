class specification COgrpevent (1:0) of CEO_GSLOCATE;



#include "msdef.h"
#include "igrmacros.h"
#include "exmacros.h"
#include "grdpbmacros.h"
#include "grerr.h"
#include "codef.h"
#include "DIdef.h"
#include "OMindex.h"
#include "ref.h"
#include "refdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "growner.h"
#include "grgsdef.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "comiscmac.h"


instance COgrpevent
{
    IGRint                     layers_defined;         /* TRUE or FALSE  */
    IGRint                     prism_attr;
    IGRint                     layers_mask[DP_NUM_OF_LEVELS/32 + 1];
    IGRint                     file_no;
    IGRint                     inside_outside;
    IGRint                     prism_type;
    IGRchar                    filename[OM_K_MAXOSNAME_LEN];
    GRobjid                    save_EX_active_module;
    GRspacenum                 save_EX_active_OS_num;
    struct GRid                gs_id;
    struct GRid                sv_id;
    struct GRid                window_id;
    struct GRid                fence_id;
    struct GRmd_env            locate_env;
    struct IGRrt_prism         right_prism;
    struct IGRcv_prism         curve_prism;
    struct GRrp_action_args    rp_action_args;
    struct GRsymb_action_args  symb_action_args;
    struct GRdelete_action     delete_action_args;
    variable IGRdouble         prism_poles[];
    variable IGRdouble         prism_weights[];
    variable IGRdouble         prism_knots[];
    variable IGRdouble         prism_boundaries[];
};


message store_window_id ( long * sts );

message construct_graphics_set ( long * sts );

message construct_fence_set ( long * sts );

message start_transition_for_graphics_set ( long * sts );

message build_locate_criteria ( long * sts );

message convert_keyin_to_layer_mask ( long * sts );

message second_pass_criteria_check ( long * sts );

message generate_right_prism_from_view ( long * sts );

message generate_right_prism_from_fence ( long * sts );

message connect_fence_to_fence_set ( long * sts );

message store_right_prism_in_fence_set ( long * sts );

message generate_select_set_from_right_prism ( long * sts );

message generate_select_set_from_all_elements ( long * sts );

message generate_select_set_using_symbology ( long * sts );

message end_transition_for_graphics_set ( long * sts );

message define_graphics_set_from_active_select_set ( long * sts );

message define_active_select_set_from_graphics_set ( long * sts );

message define_active_select_set_from_graphics_set_with_fence ( long * sts );

message put_select_set_on_queue ( long * sts );

message define_color_from_keyin ( long * sts );

message define_weight_from_keyin ( long * sts );

message define_style_from_keyin ( long * sts );

message clear_layers_flag ( long * sts );

message clear_color_flag ( long * sts );

message clear_weight_flag ( long * sts );

message clear_style_flag ( long * sts );

message put_accept_event_on_queue ( long * sts );

message clear_highlight ( long * sts );

message empty_graphics_set ( long * sts );

message perform_post_processing_on_graphics_set ( long * sts );

message check_for_fence ( long * sts );

message check_file_fence_name ( long * sts );

message save_current_file_as_file_fence ( long * sts );

message close_file_fence ( long * sts );

message delete_graphics ( long * sts );

message set_all_layers ( long * sts );

message set_layers_off_in_fence_view ( long * sts );

message parse_y_or_n ( long * sts );

message define_fence ( long * sts );

message set_locate_criteria_on ( long * sts );

message set_locate_criteria_off ( long * sts );

message generate_select_set_for_delete ( long * sts );

end specification COgrpevent;
