/* $Revision: 1.1 $ */

	/**********************************************************/
	/*** Forms Environment Interface Function Pointers	***/
	/**********************************************************/

extern int (* FI_activate_help)	( Form form );

extern int (* FI_calc_text) ( int font_id, char * text, int length,
			      int * height, int * width,
			      int * line_spacing, int font_type );

extern int (* FI_draw_text) ( int window, int font_id, char * text,
			      int length, int xpos, int ypos,
			      int font_height, int * nx, int * ny,
			      int font_type );


/*** "bodysize" declaration changed from "float" to "double",	***/
/*** as per NOTE # 1 above -- JAJ:01/14/92			***/
extern int (* FI_find_font_id) ( char * fontname, double bodysize,
				 int * font_id, float * actual_bodysize,
				 int gadget_type, int * font_type );

extern int (* FI_find_form) ( char * path, char * form_name );

extern int (* FI_find_symbol_path_and_id ) ( char * path,
					     char * symbol_name,
					     int  * symbol_id );

extern int (* FI_get_keyboard_data) ( char *character, int *count,
				      int font_type );

extern int (* FI_map_character)	( unsigned char * character );

extern int (* FI_move_index) ( unsigned char * string, int index,
			       int num_chars, int font_type );

extern int (* FI_process_data) ( int data_type, char * data_string,
				 Form form );

extern int (* FI_strlen) ( char	* string, int font_type );

extern int (* FI_set_window_attr) ( int window_number );

extern int (* FI_translate_color) ( int vs, int color );


	/**************************/
	/*** Forms Functions	***/
	/**************************/

extern int FI_append_FSfont_path ( char *FSfont_path );

extern int FI_append_font_path ( char *font_path );

extern int FI_append_form_path ( char *form_path );

extern int FI_append_symbol_path ( char *symbol_path );

extern int FI_calc_closest_colors ( int vs,
				    struct vlt_slot *current_vlt,
				    int current_vlt_num_slots );

extern int FI_clear_event ( long event );

extern int FI_enter ( void );

extern int FI_forms_active ( void );

extern int FI_get_FSfont_path ( char font_path[] );

extern int FI_get_FSfont_path_length ( int *font_path_length );

extern int FI_get_env ( int function_code, int (**func_ptr )() );

extern int FI_get_font_path ( char font_path[] );

extern int FI_get_font_path_length ( int *font_path_length );

extern int FI_get_form ( int window, Form *form );

extern int FI_get_form_by_name ( char *name, Form *form_ptr );

extern int FI_get_form_menu_type ( Form form_menu,
				   int *form_menu_type );

extern int FI_get_form_path ( char form_path[] );

extern int FI_get_form_path_length ( int *form_path_length );

extern int FI_get_graphic_env ( int function_code, int (**routine)() );

extern int FI_get_keyboard_buffer ( char **buffer, int *size );

extern int FI_get_last_notification_type ( int *notify_type );

extern int FI_get_num_forms_menus ( int * num_forms_menus );

extern int FI_get_forms_menus ( Form forms_menus_array[],
				int * num_forms_menus );

extern int FI_get_quiet_mode ( int *quiet_mode );

extern int FI_get_record_notification_routine ( void (**routine)() );

extern int FI_get_symbol_path ( char symbol_path[] );

extern int FI_get_symbol_path_length ( int *symbol_path_length );

extern int FI_load_font ( char *fontname, int bodysize,
			  int *actual_bodysize,
			  int *font_id );

/*** "title_bodysize" declaration changed from "float" to "double", ***/
/*** "message_bodysize" decl. changed from "float" to "double",     ***/
/*** as per NOTE # 1 above -- JAJ:01/14/92			    ***/
extern int FI_message_box  ( int screen, int xpos, int ypos,
			     char *title,	 int title_color,
			     char *title_font,	 double title_bodysize,
			     char *message,	 int message_color,
			    char *message_font, double message_bodysize,
			     int display_mode, int line_length );

/*** "title_bodysize" declaration changed from "float" to "double", ***/
/*** "message_bodysize" decl. changed from "float" to "double",     ***/
/*** as per NOTE # 1 above -- JAJ:01/14/92			    ***/
extern int FI_message_box2 ( int screen, int xpos, int ypos,
			     char *title,	 int title_color,
			     char *title_font,	 double title_bodysize,
			     char *message,	 int message_color,
			    char *message_font, double message_bodysize,
			     int display_mode, int line_length );

extern int FI_modify_env ( int function_code, int (*func_ptr )() );

extern int FI_modify_graphic_env ( int function_code,
				   int (*routine)() );

extern int FI_msg_box ( char *title, int title_color, char *message,
			int message_color );

extern int FI_msg_box2 ( char *title, int title_color, char *message,
			int message_color );

extern int FI_process_event ( long event_mask );

extern int FI_process_forms ( void );

extern int FI_set_FSfont_path ( char *FSfont_path );

extern int FI_set_font_path ( char *font_path );

extern int FI_set_form_path ( char *form_path );

extern int FI_set_form_path ( char *form_path );

extern int FI_set_keyboard_buffer ( char *buffer, int size );

extern int FI_set_quiet_mode_off ( void );

extern int FI_set_quiet_mode_on ( void );

extern int FI_set_record_notification_routine ( void (*routine)() );

extern int FI_set_symbol_path ( char *symbol_path );

extern int FIbtn_get_auto_pop_up_state ( Form form, int label,
					 int *state );

extern int FIbtn_get_menu_status ( Form form, int label, int *status );

extern int FIbtn_get_palette ( Form form, int label, char *pal_name );

extern int FIbtn_set_auto_pop_up_off ( Form form, int label );

extern int FIbtn_set_auto_pop_up_on ( Form form, int label );

extern int FIbtn_set_menu_status ( Form form, int label, int status );

extern int FIbtn_set_palette ( Form form, int label, char *pal_name );

extern int FIdial_get_border_style ( Form form, int label,
				     int *border_style );

extern int FIdial_get_range ( Form form, int label, float *range );

extern int FIdial_get_zero_location ( Form form, int label,
				      float *zero );

extern int FIdial_set_border_style ( Form form, int label,
				     int border_style );

/*** "range" declaration changed from "float" to "double",	***/
/*** as per NOTE # 1 above -- JAJ:01/14/92			***/
extern int FIdial_set_range ( Form form, int label, double range );

/*** "zero" declaration changed from "float" to "double",	***/
/*** as per NOTE # 1 above -- JAJ:01/14/92			***/
extern int FIdial_set_zero_location ( Form form, int label,
				      double zero );

extern int FIf_collapse ( Form form );

extern int FIf_cvrt_to_perm_win ( Form form );

extern int FIf_delete ( Form form );

extern int FIf_display ( Form form );

extern int FIf_erase ( Form form );

extern int FIf_find_by_area ( Form form, int group_label,
			      int x1, int y1, int x2, int y2,
			      int *num_labels, int **labels );

extern int FIf_find_by_point ( Form form, int group_label,
			       int xpos, int ypos, int max_dist,
			       int *label, int reset_search_flag );

extern int FIf_find_gadget ( Form form, int group_label,
			     int xpos, int ypos, int *label );

extern int FIf_get_SR_vlt ( Form form, struct vlt_slot *SR_vlt,
			    int num_SR_vlt_slots );

extern int FIf_get_SR_vlt_num_slots ( Form form,
				      int *num_SR_vlt_slots );

extern int FIf_get_attr ( Form form, long *form_mask );

extern int FIf_get_button_event_routine ( Form form,
					  int (**routine)() );

extern int FIf_get_button_intercept_routine ( Form form,
					      int (**routine)() );

extern int FIf_get_cmd_oid_os ( Form form, unsigned int *cmd_oid,
				unsigned short *cmd_os );

extern int FIf_get_collapse_location ( Form form, int *xpos,
				       int *ypos );

extern int FIf_get_collapse_symbol ( Form form, char symbol_file[],
				     int *symindex );

extern int FIf_get_color ( Form form, int *color );

extern int FIf_get_initial_notification_routine ( Form form,
						int (**routine)() );

extern int FIf_get_label ( Form form, int *form_label );

extern int FIf_get_location ( Form form, int *xpos, int *ypos );

extern int FIf_get_max_size ( Form form, int *max_xsize,
					 int *max_ysize );

extern int FIf_get_min_size ( Form form, int *min_xsize,
					 int *min_ysize );

extern int FIf_get_name ( Form form, char *name );

extern int FIf_get_next_label ( Form form, int *next_label );

extern int FIf_get_notification_routine ( Form form,
					  int (**routine)() );

extern int FIf_get_orig_location ( Form form, int *xlo, int *ylo );

extern int FIf_get_orig_size ( Form form, int *xsize, int *ysize );

extern int FIf_get_scaling ( Form form, int *scaling_flag );

extern int FIf_get_screen ( Form form, int *screen );

extern int FIf_get_seq ( Form form, int *seq_flag );

extern int FIf_get_size ( Form form, int *xsize, int *ysize );

extern int FIf_get_start_seq ( Form form, int *gadget_label );

extern int FIf_get_user_pointer ( Form form, char **user_pointer );

extern int FIf_get_window ( Form form, int *window );

extern int FIf_get_window_event_routine ( Form form,
					  int (**routine)() );

extern int FIf_get_window_icon_routine ( Form form, int (**routine)() );

extern int FIf_is_collapsed ( Form form, int *status );

extern int FIf_is_displayed ( Form form, int *status );

extern int FIf_is_valid ( Form form );

extern int FIf_look ( Form form, int group_label, char *string );

extern int FIf_new ( int label, char *form_name,
		     int (*notification_routine)(), Form *form );

extern int FIf_paint_area ( Form form, int xlo, int ylo,
				       int xhi, int yhi );

extern int FIf_process_point ( Form form, int xpos, int ypos,
			       int button, int trans, int ttag );

extern int FIf_reset ( Form form );

extern int FIf_save ( Form form, char *path );

extern int FIf_set_SR_vlt ( Form form, struct vlt_slot *SR_vlt,
			    int num_SR_vlt_slots );

extern int FIf_set_attr ( Form form, int form_mask );

extern int FIf_set_button_event_routine ( Form form, int (*routine)() );

extern int FIf_set_button_intercept_routine ( Form form,
					      int (*routine)() );

extern int FIf_set_cmd_oid_os ( Form form, unsigned int cmd_oid,
				unsigned short cmd_os );

extern int FIf_set_collapse_location ( Form form, int xpos, int ypos );

extern int FIf_set_collapse_symbol ( Form form, char *symbol_file,
						int symindex );

extern int FIf_set_color ( Form form, int color );

extern int FIf_set_initial_notification_routine ( Form form,
						  int (*routine)() );

extern int FIf_set_label ( Form form, int form_label );

extern int FIf_set_location ( Form form, int xpos, int ypos );

extern int FIf_set_max_size ( Form form, int xsize, int ysize );

extern int FIf_set_min_size ( Form form, int xsize, int ysize );

extern int FIf_set_notification_routine ( Form form, int (*routine)() );

extern int FIf_set_orig_location ( Form form, int xlo, int ylo );

extern int FIf_set_orig_size ( Form form, int xsize, int ysize );

extern int FIf_set_rel_location ( Form form, int xpos, int ypos,
				  Form base_form );

extern int FIf_set_resize_off ( Form form );

extern int FIf_set_resize_on ( Form form );

extern int FIf_set_revert_size_icon_off ( Form form );

extern int FIf_set_revert_size_icon_on ( Form form );

extern int FIf_set_scaling_off ( Form form );

extern int FIf_set_scaling_on ( Form form );

extern int FIf_set_screen ( Form form, int screen );

extern int FIf_set_seq_off ( Form form );

extern int FIf_set_seq_on ( Form form );

extern int FIf_set_size ( Form form, int xsize, int ysize );

extern int FIf_set_start_seq ( Form form, int gadget_label );

extern int FIf_set_user_pointer ( Form form, char *user_pointer );

extern int FIf_set_window_event_routine ( Form form, int (*routine)() );

extern int FIf_set_window_icon_routine ( Form form, int (*routine)() );

extern int FIf_set_window_level ( Form form, int level );

extern int FIf_uncollapse ( Form form );

extern int FIfld_delete_rows ( Form form, int label, int start_row,
			       int num_rows );

extern int FIfld_erase_cursor ( Form form, int label );

extern int FIfld_find_row_and_column ( Form form, int gadget,
				int x, int y, int *row, int *column );

extern int FIfld_get_active_char ( Form form, int label, int col,
				   int *ch, int *pos );

extern int FIfld_get_active_row ( Form form, int label,
				  int *row, int *pos );

extern int FIfld_get_attr ( Form form, int label, int col,
			    long *attr_mask );

extern int FIfld_get_default_text ( Form form, int label, int row,
				    int col, int num_ch,
				    unsigned char *text, int *sel_flg );

extern int FIfld_get_default_text_length ( Form form, int label,
				        int row, int col, int *length );

extern int FIfld_get_format_routine ( Form form, int label, int col,
				      int (**routine)() );

extern int FIfld_get_format_string ( Form form, int label, int col,
					unsigned char *format_string );

extern int FIfld_get_format_string_length ( Form form, int label,
					    int col,
					    int *format_str_length );

extern int FIfld_get_line_color ( Form form, int label, int row,
				  int col, int *color );

extern int FIfld_get_list_default_text ( Form form, int label, int row,
					 int col, int num_ch,
					 unsigned char *text,
					 int *sel_flg );

extern int FIfld_get_list_default_text_length ( Form form, int label,
						int row, int col,
						int *length );

extern int FIfld_get_list_location ( Form form, int label, int col,
				     int *xpos, int *ypos );

extern int FIfld_get_list_mode ( Form form, int label, int col,
				 int *mode );

extern int FIfld_get_list_num_rows ( Form form, int label, int col,
				     int *num_rows );

extern int FIfld_get_list_scroll ( Form form, int label, int *vert_flag,
				   int *horz_flag );

extern int FIfld_get_list_select ( Form form, int label,
				   int row, int col, int *sel_flg );

extern int FIfld_get_list_size ( Form form, int label, int col,
				 int *xsize, int *ysize );

extern int FIfld_get_list_text ( Form form, int label, int row, int col,
			         int num_ch, unsigned char *text,
				 int *sel_flg );

extern int FIfld_get_list_text_length ( Form form, int label, int row,
					int col, int *length );

extern int FIfld_get_max_num_chars ( Form form, int label, int col,
				     int *num_chars );

extern int FIfld_get_max_num_rows ( Form form, int label,
				    int *num_rows );

extern int FIfld_get_mode ( Form form, int label, int col, int *mode );

extern int FIfld_get_num_rows ( Form form, int label, int *num_rows );

extern int FIfld_get_num_vis_chars ( Form form, int label, int col,
				     int *num_chars );

extern int FIfld_get_num_vis_rows ( Form form, int label,
				    int *num_rows );

extern int FIfld_get_row_height ( Form form, int label,
				  int *row_height );

extern int FIfld_get_row_offset ( Form form, int label,
				  int *row_offset );

extern int FIfld_get_select ( Form form, int label, int row, int col,
			      int *sel_flg );

extern int FIfld_get_text ( Form form, int label, int row, int col,
			    int num_ch, unsigned char *text,
			    int *sel_flg, int *r_pos );

extern int FIfld_get_text_length ( Form form, int label, int row,
				   int col, int *length );

extern int FIfld_get_type ( Form form, int label, int col, int *type );

extern int FIfld_get_value ( Form form, int label, int row, int col,
			     double *value, int *sel_flg, int *r_pos );

extern int FIfld_get_verify_routine ( Form form, int label, int col,
				      int (**routine)() );

extern int FIfld_insert_blank_row ( Form form, int label, int row );

extern int FIfld_pos_cursor ( Form form, int label, int row, int r_pos,
		             int col, int col_pos, int ch, int ch_pos );

extern int FIfld_set_active_char ( Form form, int label, int col,
				   int ch, int pos );

extern int FIfld_set_active_row ( Form form, int label, int row,
				  int pos );

extern int FIfld_set_attr ( Form form, int label, int col,
			    long attr_mask );

extern int FIfld_set_default_text ( Form form, int label, int row,
				    int col, char *text, int sel_flg );

extern int FIfld_set_format_routine ( Form form, int label, int col,
				      int (*routine)() );

extern int FIfld_set_format_string ( Form form, int label, int col,
				     char *format_string );

extern int FIfld_set_line_color ( Form form, int label,
				  int row, int col, int color );

extern int FIfld_set_list_default_text ( Form form, int label,
					 int row, int col,
					 char *text, int sel_flg );

extern int FIfld_set_list_location ( Form form, int label, int col,
				     int xpos, int ypos );

extern int FIfld_set_list_mode ( Form form, int label, int col,
				 int mode );

extern int FIfld_set_list_num_rows ( Form form, int label, int col,
				     int num_rows );

extern int FIfld_set_list_scroll ( Form form, int label, int vert_flag,
				   int horz_flag );

extern int FIfld_set_list_select ( Form form, int label,
				   int row, int col, int sel_flg );

extern int FIfld_set_list_size ( Form form, int label, int col,
				 int xsize, int ysize );

extern int FIfld_set_list_text ( Form form, int label, int row, int col,
				 char *text, int sel_flg );

extern int FIfld_set_max_num_chars ( Form form, int label, int col,
				     int num_chars );

extern int FIfld_set_max_num_rows ( Form form, int label,
				    int num_rows );

extern int FIfld_set_mode ( Form form, int label, int col, int mode );

extern int FIfld_set_num_rows ( Form form, int label, int num_rows );

extern int FIfld_set_num_vis_chars ( Form form, int label, int col,
				     int num_chars );

extern int FIfld_set_num_vis_rows ( Form form, int label,
				    int num_rows );

extern int FIfld_set_select ( Form form, int label, int row, int col,
			      int sel_flg );

extern int FIfld_set_text ( Form form, int label, int row, int col,
			    char *apptext, int sel_flg );

extern int FIfld_set_type ( Form form, int label, int col, int type );

extern int FIfld_set_value ( Form form, int label, int row, int col,
			     double value, int sel_flg );

extern int FIfld_set_verify_routine ( Form form, int label, int col,
				      int (*routine)() );

extern int FIg_activate ( Form form, int label );

extern int FIg_add_to_group ( Form form, int gadget_label,
			      int group_label );

/*** "delta_x" declaration changed from "float" to "double",	***/
/*** "delta_y" declaration changed from "float" to "double",	***/
/*** as per NOTE # 1 above -- JAJ:01/14/92			***/
extern int FIg_adjust_size ( Form form, int label, double delta_x,
			     double delta_y );

extern int FIg_call_notification_routine ( Form form, int label );

extern int FIg_copy ( Form form, int old_label, int *new_label,
		      int generate_new_label_flag );

extern int FIg_delete ( Form form, int label );

extern int FIg_disable ( Form form, int label );

extern int FIg_display ( Form form, int label );

extern int FIg_enable ( Form form, int label );

extern int FIg_erase ( Form form, int label );

extern int FIg_get_attr ( Form form, int label, int *attr_mask );

extern int FIg_get_color ( Form form, int label, int *color );

extern int FIg_get_command ( Form form, int label, char *command );

extern int FIg_get_command_length ( Form form, int label,
				    int *command_length );

extern int FIg_get_continuous_routine ( Form form, int label,
					int (**cont_routine)() );

extern int FIg_get_default_value ( Form form, int label,
				   double *default_value );

extern int FIg_get_display ( Form form, int label, int *display_mask );

extern int FIg_get_dlocation ( Form form, int label, double *xpos,
			       double *ypos );

extern int FIg_get_dsize ( Form form, int label, double *xsize,
			   double *ysize );

extern int FIg_get_erase_color ( Form form, int label,
				 int *erase_color );

extern int FIg_get_font ( Form form, int label, char *fontname,
			  float *bodysize );

extern int FIg_get_group_label ( Form form, int label,
				 int *group_label );

extern int FIg_get_help_topic ( Form form, int label,
				char *help_topic );

extern int FIg_get_help_topic_length ( Form form, int label,
				       int *help_topic_length );

extern int FIg_get_high_value ( Form form, int label,
				double *high_value );

extern int FIg_get_increment ( Form form, int label, float *increment );

extern int FIg_get_justification ( Form form, int label, int *just );

extern int FIg_get_line_depth ( Form form, int label, int *depth );

extern int FIg_get_line_style ( Form form, int label, int *style );

extern int FIg_get_line_weight ( Form form, int label, int *wt );

extern int FIg_get_location ( Form form, int label,
				int *xpos, int *ypos );

extern int FIg_get_low_value ( Form form, int label,
				double *low_value );

extern int FIg_get_minor_increments ( Form form, int label,
					int *incrs );

extern int FIg_get_next_in_seq ( Form form, int label,
					int *next_label );

extern int FIg_get_notify ( Form form, int label, int *notify_flag );

extern int FIg_get_off_color ( Form form, int label, int *off_color );

extern int FIg_get_off_color2 ( Form form, int label, int *off_color2 );

extern int FIg_get_off_symbol_index ( Form form, int label,
					int *sym_index );

extern int FIg_get_off_text ( Form form, int label, char *text );

extern int FIg_get_off_text_length ( Form form, int label,
					int *length );

extern int FIg_get_on_color ( Form form, int label, int *on_color );

extern int FIg_get_on_color2 ( Form form, int label, int *on_color2 );

extern int FIg_get_on_symbol_index ( Form form, int label,
					int *sym_index );

extern int FIg_get_on_text ( Form form, int label, char *text );

extern int FIg_get_on_text_length ( Form form, int label, int *length );

extern int FIg_get_orientation ( Form form, int label,
				 int *orientation );

extern int FIg_get_pass_data ( Form form, int label, int *next_label );

extern int FIg_get_size ( Form form, int label,
			  int *xsize, int *ysize );

extern int FIg_get_state ( Form form, int label, int *state );

extern int FIg_get_symbol_file ( Form form, int label,
				 char *symbol_file );

extern int FIg_get_symbol_index ( Form form, int label,
				  int *sym_index );

extern int FIg_get_text ( Form form, int label, char *text );

extern int FIg_get_text_length ( Form form, int label, int *length );

extern int FIg_get_text_style ( Form form, int label, int *style );

extern int FIg_get_type ( Form form, int label, int *type );

extern int FIg_get_user_pointer ( Form form, int label,
				  char **user_pointer );

extern int FIg_get_value ( Form form, int label, double *value );

extern int FIg_get_value_format ( Form form, int label,
				  int *field_width,
				  int *decimal_accuracy );

extern int FIg_hilite ( Form form, int label );

extern int FIg_in_group ( Form form, int gadget_label, int group_label,
			  int *in_group );

extern int FIg_is_valid ( Form form, int gadget_label );

extern int FIg_new ( Form form, int gadget_type, int label );

extern int FIg_reset ( Form form, int label );

extern int FIg_set_attr ( Form form, int label, int attr_mask );

extern int FIg_set_color ( Form form, int label, int color );

extern int FIg_set_command ( Form form, int label, char *command );

extern int FIg_set_continuous_routine ( Form form, int label,
					int (*cont_routine)() );

extern int FIg_set_default_value ( Form form, int label,
				   double default_value );

extern int FIg_set_display ( Form form, int label, int display_mask );

extern int FIg_set_erase_color ( Form form, int label,
				 int erase_color );

/*** "bodysize" declaration changed from "float" to "double",	***/
/*** as per NOTE # 1 above -- JAJ:01/14/92			***/
extern int FIg_set_font ( Form form, int label, char *fontname,
			  double bodysize );

extern int FIg_set_help_topic ( Form form, int label,
				char *help_topic );

extern int FIg_set_high_value ( Form form, int label,
				double high_value );

/*** "increment" declaration changed from "float" to "double",	***/
/*** as per NOTE # 1 above -- JAJ:01/14/92			***/
extern int FIg_set_increment ( Form form, int label, double increment );

extern int FIg_set_justification ( Form form, int label, int just );

extern int FIg_set_line_depth ( Form form, int label, int depth );

extern int FIg_set_line_style ( Form form, int label, int style );

extern int FIg_set_line_weight ( Form form, int label, int wt );

extern int FIg_set_location ( Form form, int label,
				int xpos, int ypos );

extern int FIg_set_low_value ( Form form, int label, double low_value );

extern int FIg_set_minor_increments ( Form form, int label, int incrs );

extern int FIg_set_next_in_seq ( Form form, int label, int next_label );

extern int FIg_set_notify_off ( Form form, int label );

extern int FIg_set_notify_on ( Form form, int label );

extern int FIg_set_off_color ( Form form, int label, int off_color );

extern int FIg_set_off_symbol_index ( Form form, int label,
				      int sym_index );

extern int FIg_set_off_text ( Form form, int label, char *string );

extern int FIg_set_on_color ( Form form, int label, int on_color );

extern int FIg_set_on_symbol_index ( Form form, int label,
				     int sym_index );

extern int FIg_set_on_text ( Form form, int label, char *text );

extern int FIg_set_orientation ( Form form, int label,
				 int orientation );

extern int FIg_set_pass_data ( Form form, int label, int next_label );

extern int FIg_set_size ( Form form, int label, int xsize, int ysize );

extern int FIg_set_standard_variables ( Form form, int label,
					struct standard_st *str );

extern int FIg_set_state ( Form form, int label, int state );

extern int FIg_set_state_off ( Form form, int label );

extern int FIg_set_state_on ( Form form, int label );

extern int FIg_set_symbol_file ( Form form, int label,
				 char *symbol_file );

extern int FIg_set_symbol_index ( Form form, int label, int sym_index );

extern int FIg_set_text ( Form form, int label, char *text );

extern int FIg_set_text_style ( Form form, int label, int style );

extern int FIg_set_user_pointer ( Form form, int label,
				  char *user_pointer );

extern int FIg_set_value ( Form form, int label, double value );

extern int FIg_set_value_format ( Form form, int label, int field_width,
				  int decimal_accuracy );

extern int FIg_start_seq ( Form form, int label );

extern int FIg_unhilite ( Form form, int label );

extern int FIgrp_add_to_group ( Form form, int group_gadget_label,
				int to_group_label );

extern int FIgrp_callback ( Form form, int group_label,
			    void (*callback_routine)(), int user_arg );

extern int FIgrp_delete ( Form form, int group_label );

extern int FIgrp_get_pass ( Form form, int group_label,
			    int *pass_status );

extern int FIgrp_get_single_select ( Form form, int group_label,
				     int *status );

extern int FIgrp_set_pass_off ( Form form, int group_label );

extern int FIgrp_set_pass_on ( Form form, int group_label );

extern int FIgrp_set_single_select_off ( Form form, int group_label );

extern int FIgrp_set_single_select_on ( Form form, int group_label );

extern int FIh_attach_to_parent ( Form form, Form parent_form );

extern int FIh_callback ( Form form, int mode, int top_flag,
			  void (*routine)(), int user_arg );

extern int FIh_detach_from_parent ( Form form );

extern int FIh_get_reply_routine ( Form form,
				   void (**reply_routine)() );

extern int FIh_reply_to_parent ( Form form, int user_arg );

extern int FIh_set_reply_routine ( Form form, void (*reply_routine)() );

extern int FImcf_delete_col ( Form form, int label, int col );

extern int FImcf_get_active_col ( Form form, int label,
				  int *col, int *pos );

extern int FImcf_get_attr ( Form form, int label, long *attr_mask );

extern int FImcf_get_col_size ( Form form, int label, int col,
				int *xsize, int *ysize );

extern int FImcf_get_high_value ( Form form, int label, int col,
				  double *value );

extern int FImcf_get_justification ( Form form, int label, int col,
				     int *just );

extern int FImcf_get_low_value ( Form form, int label, int col,
				 double *value );

extern int FImcf_get_num_cols ( Form form, int label, int *num_col );

extern int FImcf_get_num_vis_cols ( Form form, int label,
				    int *num_col );

extern int FImcf_get_scroll_link ( Form form, int master_mcf,
				   int *header_mcf );

extern int FImcf_get_select ( Form form, int label, int row,
			      int *sel_flg );

extern int FImcf_get_view_data ( Form form, int label, int *col_offset,
				 int *num_vis_cols );

extern int FImcf_insert_col ( Form form, int label, int col, int chars,
			      int mode, int Type );

extern int FImcf_set_active_col ( Form form, int label, int col,
				  int pos );

extern int FImcf_set_attr ( Form form, int label, long attr_mask );

extern int FImcf_set_col_size ( Form form, int label, int col,
				int xsize, int ysize );

extern int FImcf_set_high_value ( Form form, int label, int col,
				  double value );

extern int FImcf_set_justification ( Form form, int label, int col,
				     int just );

extern int FImcf_set_low_value ( Form form, int label, int col,
				 double value );

extern int FImcf_set_num_cols ( Form form, int label, int num_col );

extern int FImcf_set_num_vis_cols ( Form form, int label, int num_col );

extern int FImcf_set_scroll_link ( Form form, int master_mcf,
				   int header_mcf );

extern int FImcf_set_select ( Form form, int label, int row,
			      int sel_flg );

extern int FIrect_get_style ( Form form, int label, int *style );

extern int FIrect_set_style ( Form form, int label, int style );

extern int FIscrl_get_view ( Form form, int label, double *view );

extern int FIscrl_set_view ( Form form, int label, double view );


	/**************************/
	/*** Menu Functions	***/
	/**************************/

extern int MI_enter ( void );

extern int MI_get_menu_move_routine ( void (**menu_move_routine)() );

extern int MI_get_palette_vert_offset ( int *offset );

extern int MI_get_tear_off_notification_routine (
					void (**tear_off_routine)() );

extern int MI_get_window_routine ( void (**window_routine)() );

extern int MI_pop_up_button ( Form menu, int gadget_label );

extern int MI_set_menu_move_routine ( void (*menu_move_routine)() );

extern int MI_set_palette_vert_offset ( int offset );

extern int MI_set_tear_off_notification_routine (
					void (*tear_off_routine)() );

extern int MI_set_window_routine ( void (*window_routine)() );

extern int MIm_display ( Form menu );

extern int MIm_new ( int menu_type, int menu_label, char *menu_name,
		     int (*notification_routine)(), Form *menu );

extern int MIm_set_move_icon_off ( Form menu );

extern int MIm_set_move_icon_on ( Form menu );

extern int MS_delete_menus ( void );

extern int MS_display_menus ( void );

extern int MS_enter ( void );

extern int MS_erase_menus ( void );

extern int MS_get_startup_file ( char file[] );

extern int MS_init_menus ( void );

extern int MS_pop_up_last_button ( void );

extern int MS_process_pocket ( int vs, int xpos, int ypos );

extern int MS_save_locations ( char *file );

extern int MS_set_startup_file ( char *file );

extern int MS_swap_menu ( int menu_type, char *menu_name );

