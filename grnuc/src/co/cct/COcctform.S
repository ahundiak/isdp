class specification COcctform (1:0) of CEO, IGEcolsup;



#ifndef X11 
#include <tools.h>
#else
#include "X11/Xlib.h"
#include "X11/Xutil.h"
#include "cctspec.h"
#endif

#include <stdio.h>
#include "wl.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "FI.h"
#include "cct.h"


instance COcctform
{
					        /* TERMINAL INFORMATION 				*/
	WLcolorref	menu_bg;	        /* colorref of background slot 				*/
	WLcolorref	menu_fg;		/* colorref of foreground slot 				*/
	WLcolorref	menu_hl;	        /* colorref of highlight slot 				*/

					        /* CONFIGURATION DATA 					*/
	IGRshort	num_colors;             /* number of active colors 				*/

						/* ORIGINAL COLOR VALUES 				*/
	variable IGRint 
	   orig_ctbl[DEFAULT_NUM_BG_LOG_HL];    /* the original color table 				*/
	variable
	   struct IGEcol_names orig_names[7];	/* the original color names 				*/

						/* CURRENT COLOR VALUES 				*/
	variable IGRint  
	   modified_ctbl[DEFAULT_NUM_BG_LOG_HL];/* local copy of the ctbl 				*/
	IGRint bg_vlt;				/* the background color VLT 				*/
	IGRint hl_vlt;				/* the highlight color VLT 				*/
	variable
	   struct IGEcol_names modified_names[7];/* local copy of the color names 			*/

	IGRint		last_color;		/* logical index of last active color (dehighlighting)  */

						/* CURRENT COLOR PARAMETERS 				*/
	IGRint		curr_color;		/* current color's logical color number 		*/
	IGRchar		curr_colname[EXFI_STRLEN];/* current color's name 				*/
	IGRdouble	curr_red;		/* current color's red value 		range 0.0-1.0   */
	IGRdouble	curr_green;		/* current color's green value          range 0.0-1.0   */
	IGRdouble	curr_blue;		/* current color's blue value           range 0.0-1.0   */

                                                /* RED GREEN and BLUE are always dominant and the only  */
                                                /* reason for current hue, luminance and saturation is  */
                                                /* for the case of sat=0.0 (l=0.0 l=1.0) hue could be   */
                                                /* anything and the value is forced to 0 and cannot be  */
                                                /* recovered without this saving.                       */
	IGRdouble	curr_hue;		/* current color's hue value 		range 0.0-359.0 */
	IGRdouble	curr_luminance;		/* current color's luminance value      range 0.0-1.0   */
	IGRdouble	curr_saturation;	/* current color's saturation value     range 0.0-1.0   */
	IGRint		curr_color_page;	/* the page you are on (64 logical colors per page)	*/

						/* FILE PARAMETERS 					*/
	IGRchar		file_name[EXFI_STRLEN];	/* color table file name 				*/
	IGRint		file_type;		/* color table file type 				*/

						/* MISCELLANEOUS 					*/
        WLuint32	context_no;		/* context_no of form 					*/
	WLuint32	lwin_no;		/* logical window number of form 			*/
	WLhwin_no	hwin_no;		/* hardware window number of form 			*/
        WLuint16        lscreen_no;		/* logicall screen number of form 			*/
	IGRboolean	name_mode;		/* name mode flag 					*/
	IGRdouble	slider_maximum;		/* current RGB/HLS slider maximum value			*/
	IGRboolean	hit_check_box;		/* TRUE, if user checked out of form 			*/
	IGRint          ignore_X_display;       /*Ignore thr first two FI_DSIPLAY events 		*/
                                                /*Just a kludge to avoid multiple display of the form 	*/
        IGRint          old_active_color;       /* Restore the active color if the user hits an X 	*/
 	IGRint		converted_to_window;	/* form has been converted to a window 			*/

        /* FORM LOCATION AND SIZE DATA */
	variable
	   struct COlog_col_pos log_col_gad[67];/* gadget location and sizes of logical colors		*/
        IGRdouble       dithered_color_x;
        IGRdouble       dithered_color_y;
        IGRdouble       dithered_color_width;
        IGRdouble       dithered_color_height;
        IGRdouble       solid_color_x;
        IGRdouble       solid_color_y;
        IGRdouble       solid_color_width;
        IGRdouble       solid_color_height;
        IGRdouble       hue_sat_block_x;
        IGRdouble       hue_sat_block_y;
        IGRdouble       hue_sat_block_width;
        IGRdouble       lum_range_x;
        IGRdouble       lum_range_y;
        IGRdouble       lum_range_width;
        IGRdouble       color_height;
};


message set_current_color ( int save_current_color, logical_index, display );

message update_color_table ( int * sts );

message restore_color_table ( int * sts );

message get_color_data ( int * sts; int change_original_values );

message initialize_GRCreColorTb ( long * sts );

message window_event_method ( int f_label; int event; Form fp );

override sleep;

message wakeup_GRCreColorTb ( long * sts );

message get_form_gadget_locations ( long * sts );

message button_intercept_method ( Form f_label; int xpos; int ypos; int button_number; int transition; int time_tag );

override form_notification;

message update_rgb_gadgets ( long * sts );

message update_hls_gadgets ( long * sts );

message set_slider_maximum ( double maximum );

message update_active_color_display ( long * sts );

message print_message ( int form_label; int msg_num );

message clear_message_field ( int form_label );

message initialize_GRCreColorTbOp ( int * sts );

message options_form_notification ( int form_label; int gadget_label; double value; Form fp );

message draw_color_block ( long * sts );

message highlight_color_block ( int logical_color_to_highlight; int logical_color_to_dehighlight );

message draw_color_pallet ( long * sts );

message draw_lum_range ( long * sts );

message draw_hue_sat_block (long * sts; IGRboolean recompute_raster );

message draw_cross_hairs ( long * sts );

message draw_lum_ptr ( long * sts );

message map_to_hls (long * sts,x,y);

message toggle_compensation ( long * msg );

end specification COcctform;
