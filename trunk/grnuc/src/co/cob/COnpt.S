class specification COnpt (1:0) of CEO_LOCATE;


/*
Version 1.2
    srh 
*/


instance COnpt
{
    struct GRlc_dynamics
               dyn_info;

    struct GRevent
               first_event,
               second_event,
               third_event,
               fourth_event,
               fifth_event,
               sixth_event,
               seventh_event;

    struct GRmd_env 
               ConstructInfo,
               FirstContext,
               SecondContext;

    IGRshort
               trim_flag,
               misc_flag;

    IGRchar
              *AttributePointer; /* for gray */

    IGRboolean
               ObjectWasLocated,      /* for CEO_LOCATE channel */
               ObjectOnFirstLocated,
               ObjectOnSecondLocated;

/*----------------------------------------*/
/*--------------- channels ---------------*/
/*----------------------------------------*/

    channel {(rel_ordered)} 
               ToFirstLocated,  /* channel to first  located ele */
               ToSecondLocated; /* channel to second located ele */


};


message setup_dyn_info ( long * sts );

override init;

override wakeup;

override delete;

override sleep;

override filter;

message store_locate_context ( long * sts );

message copy_event ( long           *sts; 
                   struct GRevent *to_event;
                   struct GRevent *from_event );

message copy_event_by_index ( long *sts; int to_index; int from_index );

message store_event_by_index ( long *sts; int index );

message erase_hilite ( long * sts );

message display_first_located_object ( long * sts );

message display_second_located_object ( long * sts );

message get_construct_env_from_dpb ( long * sts );

message verify_active_angle ( IGRlong *sts;
                             IGRshort geom );

message isopen ( long * sts );

message is_physically_open ( long * sts );

message push_accept_event_on_queue ( long * sts );

message push_first_event_on_queue ( long * sts );

message reload_last_point ( long * sts );

message add_point ( long * sts );

message delete_point ( long * sts );

override dynamics;

message const_dynamics ( long *sts; int dyn_index );

message construct_object ( long * sts );

message close_ortho_polygon ( long * sts );

message delete_element ( long * sts );

message use_one_element ( long * sts );

message save_first_element ( long * sts );

message save_second_element ( long * sts );

message use_two_elements ( long * sts );

message set_up_n_elements ( struct GRid  *grids[] );

message locate_two_and_construct ( long * sts );

message disconnect_channel ( long            *sts;
                           OM_S_CHANSELECT *p_chansel );

message clear_channels ( long * sts );

message set_trim_flag_neither ( long * sts );

message set_trim_flag_man_1 ( long * sts );

message set_trim_flag_man_2 ( long * sts );

message set_trim_flag_auto_both ( long * sts );

message use_events ( long * sts );

message make_data_event_tangent_to ( long * sts );

message display_cs_type ( long * sts );

message get_first_name ( long * sts );

message mvdir ( long * sts );

message hilite_element ( long * sts );

message create_directory ( long *sts; IGRchar *dirname );

message add_object_to_directory ( long *sts; OM_S_CHANSELECT *p_chansel );

message start_dir ( long * sts );

message get_channel_count ( long *sts; OM_S_CHANSELECT *chansel );

message display_cdpath ( long * sts );

message store_locate_event_by_index ( long *sts; int index );

message gen_pts_by_spacing_along_element ( long * sts );

message gen_pts_along_element ( long * sts );

message set_default_event_by_index ( long *sts; int index );

message gen_matrix_of_pts_by_row_col_deltas ( long * sts );

message gen_polar_pts ( long * sts );

message DYlinear ( long *sts; int index );

message change_arc_to_circle ( long * sts );

message arc_to_comp_arc ( long * sts );

message extend_arc_by_angle ( long * sts );

message is_active_cell_defined ( long * sts );

message form_init ( int form_index );

message display_active_parms ( IGRlong *sts; IGRlong mask );

message graphic_cd ( long * sts );

message set_misc_flag ( long *sts; int flag_val );

message get_misc_flag ( long * sts );

message diameter_to_radius ( long *sts; int index );

message convert_to_profile ( long * sts );

message show_assoc_mode ( int flag );

message construct_polygon ( long * sts );

message wakeup_form (long *sts; int suppress_flag );

message ignore_skobj ( long * sts );

override SSSetNewElement;

end specification COnpt;
