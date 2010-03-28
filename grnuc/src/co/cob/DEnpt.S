class specification DEnpt (1:0) of CEO_GSLOCATE, COnpt;


#include "de.h"


instance DEnpt
{

    enum  DEwindow_mode window_mode;    /* how to display */
    struct GRid         window_grid;    /* grid of window of current soo */
    struct GRparms      boundary_parms; /* parms of a point projected    */

    struct IGRdisplay   so_form;
    IGRshort            so_type;
    IGRboolean          so_total;
    IGRboolean          so_flipper;
};


message set_all_windows ( long * sts );

message set_one_window ( long * sts );

message store_boundary_parms ( long * sts );

message display_object ( long * sts );

message display_objid ( int *sts; int ele );

override init;

override sleep;

override filter;

override store_locate_context;

message get_window ( long * sts );

message get_locate_window ( long * sts );

message get_window_by_name ( int *sts; int event );

message create_soo ( long * sts );

message project_locate_point ( int *sts;
                             int  pt;
                             int  ele );

message project_data_point ( int *sts; int ele );

message remove_sym_o ( long * sts );

message show_only_one_soo ( long * sts );

message show_only_soo ( long * sts );

message show_all ( long * sts );

message show_only_man_soo ( long * sts );

message show_all_soo ( long * sts );

message update_all_win ( long * sts );

message update_one_win ( long * sts );

message smart_prompt ( long * sts );

message place_sym_o_form ( long * sts );

override form_notification;

message some_or_all ( long * sts );

override status_disp;

message so_flip_flop ( long * sts );

message so_flip_off ( long * sts );

message show_sym_o ( long * sts );

message is_keypoint ( long * sts );

message process_group ( long * sts );

message store_event ( int f, t );

message erase_hilite_plane ();

end specification DEnpt;
