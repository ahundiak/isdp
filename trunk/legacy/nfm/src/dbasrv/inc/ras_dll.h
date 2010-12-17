#include "dba_func.h"
typedef  int  (*RAS_F01) (void);                // dba_attach_file_link
typedef  int  (*RAS_F02) (void);                // dba_attach_note
typedef  int  (*RAS_F03) (void);                // dba_attach_user_link
typedef  int  (*RAS_F04) (char *menu, int label); // dba_build_font_list
typedef  int  (*RAS_F05) (char *filename, int *num_files); // dba_build_note_list
typedef  int  (*RAS_F06) (int *active_count);   // dba_count_active_files
typedef  int  (*RAS_F07) (char *filename, int xo, int yo, int width, int height, int page, int *file_id);  // dba_display_graphics
typedef  int  (*RAS_F08) (int file_id);         // dba_exit_graphics
typedef  int  (*RAS_F09) (void);                // dba_register_raster
typedef  int  (*RAS_F10) (void);                // dba_fit
typedef  void (*RAS_F11) (char *color);         // dba_get_color
typedef  int  (*RAS_F12) (int file_id, int *width, int *height); // dba_get_extents
typedef  void (*RAS_F13) (char *font);          // dba_get_font
typedef  void (*RAS_F14) (int *level);          // dba_get_level
typedef  void (*RAS_F15) (int *line_width);     // dba_get_line_width
typedef  int  (*RAS_F16) (int number, char *filename); // dba_get_notes
typedef  void (*RAS_F17) (double *text_size);   // dba_get_rl_text_size
typedef  int  (*RAS_F18) (int *window, int *win_handle, char *filename);  // dba_get_win_info
typedef  int  (*RAS_F19) (int *window);         // dba_get_window
typedef  int  (*RAS_F20) (char *file);          // dba_grab_rle
typedef  int  (*RAS_F21) (void);                // dba_load_file
typedef  int  (*RAS_F22) (void);                // dba_measure
typedef  int  (*RAS_F23) (void);                // dba_pan
typedef  int  (*RAS_F24) (void);                // dba_place_arc
typedef  int  (*RAS_F25) (void);                // dba_place_arrow
typedef  int  (*RAS_F26) (void);                // dba_place_circle
typedef  int  (*RAS_F27) (void);                // dba_place_filled_circle
typedef  int  (*RAS_F28) (void);                // dba_place_filled_rectangle
typedef  int  (*RAS_F29) (void);                // dba_place_filled_shape
typedef  int  (*RAS_F30) (void);                // dba_place_line
typedef  int  (*RAS_F31) (void);                // dba_place_rectangle
typedef  int  (*RAS_F32) (void);                // dba_place_shape
typedef  int  (*RAS_F33) (void);                // dba_place_symbol
typedef  int  (*RAS_F34) (void);                // dba_place_text
typedef  int  (*RAS_F35) (void);                // dba_plot_window
typedef  int  (*RAS_F36) (void);                // dba_quit
typedef  int  (*RAS_F37) (int change, int nover, int mult); // dba_review_vector_element
typedef  int  (*RAS_F38) (int form_label);      // dba_notify_raster
typedef  int  (*RAS_F39) (void);                // dba_raster_fence
typedef  int  (*RAS_F40) (void);                // dba_raster_fence_multi
typedef  int  (*RAS_F41) (void);                // dba_red_draw_ann_text
typedef  int  (*RAS_F42) (void);                // dba_red_draw_arc
typedef  int  (*RAS_F43) (void);                // dba_red_draw_arrow
typedef  int  (*RAS_F44) (void);                // dba_red_draw_circle
typedef  int  (*RAS_F45) (void);                // dba_red_draw_filled_circle
typedef  int  (*RAS_F46) (void);                // dba_red_draw_filled_rectangle
typedef  int  (*RAS_F47) (void);                // dba_red_draw_filled_shape
typedef  int  (*RAS_F48) (void);                // dba_red_draw_line
typedef  int  (*RAS_F49) (void);                // dba_red_draw_rectangle
typedef  int  (*RAS_F50) (void);                // dba_red_draw_shape
typedef  int  (*RAS_F51) (void);                // dba_red_draw_symbol
typedef  int  (*RAS_F52) (void);                // dba_red_draw_text
typedef  int  (*RAS_F53) (char *path, char *filename, char *redline_filename); // dba_red_get_unique_filename
typedef  char *(*RAS_F54) (char *word);         //*dba_red_hash_ascii_value
typedef  int  (*RAS_F55) (void);                // dba_rotate
typedef  int  (*RAS_F56) (void);                // dba_scroll
typedef  void (*RAS_F57) (char *color);         // dba_set_color
typedef  void (*RAS_F58) (char *font);          // dba_set_font
typedef  void (*RAS_F59) (int level);           // dba_set_level
typedef  void (*RAS_F60) (int line_width);      // dba_set_line_width
typedef  void (*RAS_F61) (double text_size);    // dba_set_rl_text_size
typedef  int  (*RAS_F62) (void);                // dba_show_links
typedef  int  (*RAS_F63) (void);                // dba_update
typedef  int  (*RAS_F64) (void);                // dba_window
typedef  int  (*RAS_F65) (int file_id, int x1, int y1, int x2, int y2); // dba_window_area
typedef  int  (*RAS_F66) (void);                // dba_window_center
typedef  int  (*RAS_F67) (int file_id, char *name); // dba_window_name
typedef  int  (*RAS_F68) (void);                // dba_zoom_in
typedef  int  (*RAS_F69) (void);                // dba_zoom_out
typedef  int  (*RAS_F70) (void);                // dba_g_fence_exists
typedef  int  (*RAS_F71) (int *got_where, struct dba_ent *ent_ptr, char **s1_ptr, unsigned long *s1_size, Form fpt, int label, int row); // dba_g_build_fence
typedef  int  (*RAS_F72) (int change_ent, int no_verify, int multiple); // dba_review_raster_element
typedef  int  (*RAS_F73) (int set, int mode, int view, double zoom, int blink); // dba_locate_raster_graphics
typedef  int  (*RAS_F74) (void);                // dba_g_attach_linkage
typedef  int  (*RAS_F75) (void);                // dba_g_remove_linkage
typedef  int  (*RAS_F76) (void);                // dba_g_remove_fence
typedef  int  (*RAS_F77) (MSG *msg);            // dba_g_process_event
typedef  int  (*RAS_F78) (void);                // dba_g_reset_dmredl
typedef  int  (*RAS_F79) (char *node, char *filename, int page, int flag); // dba_g_load
typedef  int  (*RAS_F80) (char *filename);      // dba_g_init
typedef  int  (*RAS_F81) (void);                // dba_g_exit
typedef  int  (*RAS_F82) (DBA_FUNCTION_TABLE *dba_func_tbl, DBA_VARIABLE_TABLE *dba_vari_tbl); // dba_ras_get_functions
typedef  int  (*RAS_F83) (void);                // dba_place_ellipse
typedef  int  (*RAS_F84) (void);                // dba_place_filled_ellipse
typedef  int  (*RAS_F85) (void);                // dba_place_freehand
typedef  int  (*RAS_F86) (void);                // dba_red_draw_ellipse
typedef  int  (*RAS_F87) (void);                // dba_red_draw_filled_ellipse
typedef  int  (*RAS_F88) (void);                // dba_red_draw_freehand
typedef  int  (*RAS_F89) (int set, int mode, double zoom, int blink); // dba_locate_vector_graphics

/*
** Set up functions
*/

typedef struct ras_FunctionTable
{
  RAS_F01  f01;                                 // dba_attach_file_link
  RAS_F02  f02;                                 // dba_attach_note
  RAS_F03  f03;                                 // dba_attach_user_link
  RAS_F04  f04;                                 // dba_build_font_list
  RAS_F05  f05;                                 // dba_build_note_list
  RAS_F06  f06;                                 // dba_count_active_files
  RAS_F07  f07;                                 // dba_display_graphics
  RAS_F08  f08;                                 // dba_exit_graphics
  RAS_F09  f09;                                 // dba_register_raster
  RAS_F10  f10;                                 // dba_fit
  RAS_F11  f11;                                 // dba_get_color
  RAS_F12  f12;                                 // dba_get_extents
  RAS_F13  f13;                                 // dba_get_font
  RAS_F14  f14;                                 // dba_get_level
  RAS_F15  f15;                                 // dba_get_line_width
  RAS_F16  f16;                                 // dba_get_notes
  RAS_F17  f17;                                 // dba_get_rl_text_size
  RAS_F18  f18;                                 // dba_get_win_info
  RAS_F19  f19;                                 // dba_get_window
  RAS_F20  f20;                                 // dba_grab_rle
  RAS_F21  f21;                                 // dba_load_file
  RAS_F22  f22;                                 // dba_measure
  RAS_F23  f23;                                 // dba_pan
  RAS_F24  f24;                                 // dba_place_arc
  RAS_F25  f25;                                 // dba_place_arrow
  RAS_F26  f26;                                 // dba_place_circle
  RAS_F27  f27;                                 // dba_place_filled_circle
  RAS_F28  f28;                                 // dba_place_filled_rectangle
  RAS_F29  f29;                                 // dba_place_filled_shape
  RAS_F30  f30;                                 // dba_place_line
  RAS_F31  f31;                                 // dba_place_rectangle
  RAS_F32  f32;                                 // dba_place_shape
  RAS_F33  f33;                                 // dba_place_symbol
  RAS_F34  f34;                                 // dba_place_text
  RAS_F35  f35;                                 // dba_plot_window
  RAS_F36  f36;                                 // dba_quit
  RAS_F37  f37;                                 // dba_review_vector_element
  RAS_F38  f38;                                 // dba_notify_raster
  RAS_F39  f39;                                 // dba_raster_fence
  RAS_F40  f40;                                 // dba_raster_fence_multi
  RAS_F41  f41;                                 // dba_red_draw_ann_text
  RAS_F42  f42;                                 // dba_red_draw_arc
  RAS_F43  f43;                                 // dba_red_draw_arrow
  RAS_F44  f44;                                 // dba_red_draw_circle
  RAS_F45  f45;                                 // dba_red_draw_filled_circle
  RAS_F46  f46;                                 // dba_red_draw_filled_rectangle
  RAS_F47  f47;                                 // dba_red_draw_filled_shape
  RAS_F48  f48;                                 // dba_red_draw_line
  RAS_F49  f49;                                 // dba_red_draw_rectangle
  RAS_F50  f50;                                 // dba_red_draw_shape
  RAS_F51  f51;                                 // dba_red_draw_symbol
  RAS_F52  f52;                                 // dba_red_draw_text
  RAS_F53  f53;                                 // dba_red_get_unique_filename
  RAS_F54  f54;                                 // dba_red_hash_ascii_value
  RAS_F55  f55;                                 // dba_rotate
  RAS_F56  f56;                                 // dba_scroll
  RAS_F57  f57;                                 // dba_set_color
  RAS_F58  f58;                                 // dba_set_font
  RAS_F59  f59;                                 // dba_set_level
  RAS_F60  f60;                                 // dba_set_line_width
  RAS_F61  f61;                                 // dba_set_rl_text_size
  RAS_F62  f62;                                 // dba_show_links
  RAS_F63  f63;                                 // dba_update
  RAS_F64  f64;                                 // dba_window
  RAS_F65  f65;                                 // dba_window_area
  RAS_F66  f66;                                 // dba_window_center
  RAS_F67  f67;                                 // dba_window_name
  RAS_F68  f68;                                 // dba_zoom_in
  RAS_F69  f69;                                 // dba_zoom_out
  RAS_F70  f70;                                 // dba_g_fence_exists
  RAS_F71  f71;                                 // dba_g_build_fence
  RAS_F72  f72;                                 // dba_review_raster_element
  RAS_F73  f73;                                 // dba_locate_raster_graphics
  RAS_F74  f74;                                 // dba_g_attach_linkage
  RAS_F75  f75;                                 // dba_g_remove_linkage
  RAS_F76  f76;                                 // dba_g_remove_fence
  RAS_F77  f77;                                 // dba_g_process_event
  RAS_F78  f78;                                 // dba_g_reset_dmredl
  RAS_F79  f79;                                 // dba_g_load
  RAS_F80  f80;                                 // dba_g_init
  RAS_F81  f81;                                 // dba_g_exit
  RAS_F82  f82;                                 // dba_ras_get_functions
  RAS_F83  f83;                                 // dba_place_ellipse
  RAS_F84  f84;                                 // dba_place_filled_ellipse
  RAS_F85  f85;                                 // dba_place_freehand
  RAS_F86  f86;                                 // dba_red_draw_ellipse
  RAS_F87  f87;                                 // dba_red_draw_filled_ellipse
  RAS_F88  f88;                                 // dba_red_draw_freehand
  RAS_F89  f89;                                 // dba_locate_vector_graphics
} RAS_FUNCTION_TABLE;
