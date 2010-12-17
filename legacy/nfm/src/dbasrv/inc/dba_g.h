/* $Revision: 1.9 $ */
/*
        DBAccess Graphics System Default Values
*/
#ifndef dba_g_global
#define dba_g_global

#include <stdio.h>
#include "FI.h"

#if defined __WIN16__ || defined __WIN32__
#include <windows.h>
#ifdef __DLL__
#include "dba_dll.h"
#endif
#endif

#include "point.h"
#include "iml.h"

#if !defined __WIN16__ && !defined __WIN32__
#include "../forms/dmc.inc"
#include "dmgvPub.h"
#if !defined src_eraster
#include "dmgvProto.h"
#endif
#elif defined __WIN32__
#include "dm_app.h"
#include "utl.h"
#include "gvpub.h"
#include "dmc_pro.h"
#endif

#include "dba_g.def"
#include "dba_g_s.def"
#include "dba.ext"
/*
	DBAccess File Data Linked List
*/

/* 12-dec-1993 for w_rundba.  blp */
#if !defined __WIN16__
#if defined __WIN32__
struct _DM_PrintInfo dba_g_plotinfo;
#else
struct DM_PlotInfo_str dba_g_plotinfo;
#endif
#endif

struct dba_g_red_files *dba_top_redline_file, *dba_redline_file;
struct dba_g_files dba_g_fdata;
struct dba_g_files *dba_g_current_file, *dba_g_first_file, *dba_g_note_file;
int dba_g_num_files = 0;
/*
        Globals used in g_gfdata.c to determine where
        a graphics file might be.
*/
char *dba_files_path;
char *dba_files_drive;
/*
	Globals used for type of redlines and path of redlines
*/
short DMredline;
char *dba_redline_path;
/*
	Table Names for the Linkages
*/
char dba_g_files_table[DBR_MAXNAME], dba_g_links_table[DBR_MAXNAME], 
     dba_g_points_table[DBR_MAXNAME], dba_g_strings_table[DBR_MAXNAME];
/*
	Current Page Text
*/
char dba_current_page_text[64];
/*
	Current Window Number
*/
int dba_current_window_number = 0;
/*
	Control Variables
*/
int dba_g_x1 = 0, dba_g_y1 = 0, dba_g_x2 = 1023, dba_g_y2 = 719;
int dba_fg_color = 2, dba_bg_color = 6, dba_hl_color = 4;
int dba_file_link_color = 11, dba_database_link_color = 8;
int dba_note_link_color = 9, dba_user_link_color = 3, dba_color_used = 0;
int dba_g_width = 400, dba_g_height = 300;
int dba_g_offset_x = 25, dba_g_offset_y = 25;
int dba_g_mdic_x = 0, dba_g_mdic_y = 0;
int dba_g_mdic_width = 550, dba_g_mdic_height = 450;
int dba_menu_mode = 1, dba_window_mode = 0, dba_dec_type = 1;
int dba_raster_menu_disable = 0;
int dba_border_mode = 1;
int dba_overview_mode = 1;
int dba_virtual_screen = 0;
int dba_window_names = 1;
int dba_hot_keys = 1;
/*
	Raster Mode Active Flag
*/
int dba_g_active = 0;
int dba_auto_display_links = 0;
/*
	Type of redlines (dbaccess = 0 / dmredline = 1)
*/
int   dba_redline_mode = 0;
/*
	Review File Linkage Locate Graphics Arguments
*/
int dba_fl_mode = 0, dba_fl_view = 0, dba_fl_blink = 0;
double dba_fl_zoom = 1.0;
/*
	User Linkage Data
*/
int dba_user_entitynum, dba_user_raslink;
long dba_user_mslink;
/*
	Raster Rotation angle
*/
int dba_raster_rotate_angle = 0;
/*
	Fence Type: Rectangular or Multisided, and the Fence Window,
        the fence only applies to one file.
*/
int dba_g_f_type;
#if defined __WIN16__ || __WIN32__
HWND dba_g_fence_window;
#else
int dba_g_fence_window;
#endif
/*
        Linkage Type: Rectangular, Multisided
*/
short dba_linkage_type = 1;
/*
        Linkage function:  Delete, File, Note, Database
*/
short dba_graphics_function;
/*
	Fence Points, and Number of Fence Points
*/
double *dba_g_f_pnts;
int dba_g_num_f_pnts;
/*
	Linkage Points
*/
int *dba_g_ip = NULL;
double *dba_g_dp = NULL;
int dba_g_npts = 0;
int dba_g_irange[4];
double dba_g_drange[6];
/*
	Forms for the DBraster module
*/
Form dba_g_menu_form, dba_g_load_form, dba_g_note_form, dba_g_goto_form,
     dba_g_markup_form, dba_g_text_form;
/*
	Font Variables
*/
char *dba_g_fontname;
short dba_g_font_loaded;
/*
	Iml Variables
*/
char *dba_g_image_data;
int  dba_g_image_size;
char dba_g_node[16], dba_g_net_addr[132];
/*
	Active Markup Parameters
*/
int dba_g_markup_enabled = 0;
int dba_g_links_z = 0;
struct dba_g_active_params_m dba_g_markup_params;
char *dba_g_linkage_where = NULL;
unsigned long dba_g_where_size;
/*
	Linked List of Symbols
*/
struct dba_g_symbols *dba_g_symlist = NULL;
int dba_g_num_symbols = 0;
char dba_markup_symbol_file[64];
/*
        DMANDS Variable.  This variable is used in raster/g_init.c because
        putenv will not let you call putenv() with an automatic variable as
        the argument, then exit the calling function while string is still
        part of the environment.  This variable is used by the DMc software.
*/
char dba_dmands_dir[40];

#endif
