/* $Revision: 1.1 $ */
#include "dba.ext"
extern char *dba_errtxt;
extern int dba_error;

/*
	These stubs are here in order to be able to link the DBA executables 
        without ras.o, because scripting calls these things, and Tim
        says "There is no way to fix it"
*/

/* Function:	dba_g_stub */

dba_g_exit() {}
dba_g_review_linkage() {}
dba_g_attach_linkage() {}
dba_g_locate_graphics() {}
dba_g_locate_set() {}
dba_g_fence_exists() { return (0); }
dba_g_build_fence() {}
dba_g_menu() {}
dba_g_remove_linkage() {}
dba_g_remove_fence() {}
dba_g_fdata() {}
void dba_g_load() {}
dba_g_commands() {}
dba_g_lookup_color() {}
dba_g_black_pixel() {}
dba_g_white_pixel() {}
dba_g_screen_size() {}
/*
dba_iml_init() {}
iml_initialize() {}
*/
/*
get_xns() {}
*/
void dba_build_note_list() {}
void dba_get_notes() {}
void dba_quit() {}
void dba_window() {}
void dba_fit() {}
void dba_update() {}
void dba_load_file() {}
void dba_zoom_in() {}
void dba_zoom_out() {}
void dba_scroll() {}
void dba_raster_fence() {}
void dba_raster_fence_multi() {}
void dba_attach_note() {}
void dba_attach_file_link() {}
void dba_show_links() {}
void dba_pan() {}
void dba_plot_window() {}
void dba_display_graphics() {}
void dba_exit_graphics() {}
void dba_get_extents() {}
void dba_window_area() {}
void dba_attach_user_link() {}
void dba_grab_rle() {}

