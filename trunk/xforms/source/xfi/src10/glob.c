
/******************************************************************/
/***   Leave the previous line alone - chng_ident.sh 		***/
/***   updates it automagically during the make.		***/
/******************************************************************/

#define FI_INSIDE_GLOB_C	1

#include "FImin.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/****************************************************************/
/* NOTE: All new variables must be added at the end to maintain	*/
/* 	the correct addresses for the current variables.	*/
/****************************************************************/
/* NOTE: any time a global variable is added its size		*/
/* must be subtracted from the buffer at end of this file.	*/
/****************************************************************/


  /*** USE OTHER SPACE FIRST, INSTEAD OF THIS !!!		***/
char	XFI_DUMMY_FILLER_CHAR_1 [ 144 ]	= {0}; /* dmb:09/28/92:ANSI */

/******************************************************************/
/*** The following global is here so that "opl -a" can be used  ***/
/*** to extract the version number.	-- JAJ:02/04/91         ***/
/***								***/
/***   NOTE: LEAVE 40 characters or so extra, in case           ***/
/***   struct XFORMS_sd_appl_version gets anything added to it. ***/
/***								***/
/***   NOTE: Don't initialize XFORMS_appl_version_id with a     ***/
/***         constant here, because it makes the shared lib	***/
/***	     incompatible with previous versions.		***/
/******************************************************************/

/******************************************************************/
/*** This is for XFORMS_appl_version_id global variable  	***/
/***   it must be set to the version string here, and not 	***/
/***   in glob.c, or the shared lib won't be compatable.	***/
/*** ALSO							***/
/***   Leave the following line alone - chng_ident.sh 		***/
/***   updates it automagically during the make.		***/
/*********************************************  JAJ:02/04/91  *****/

char	_XFI_appl_version_array[512]="01.00.02.04";

char	XFI_DUMMY_FILLER_CHAR_2A [ 64 ]	= {0}; /* dmb:09/28/92:ANSI */

char	_XFI_appl_product_id[64]="SN01253";

char	XFI_DUMMY_FILLER_CHAR_2B [ 64 ]	= {0}; /* dmb:09/28/92:ANSI */


struct XFORMS_sd_appl_version	   /*** sizeof struct = 16 bytes ***/
{
  char *curr_version;
  int   (*version_check_func)();
  char *product_id;
  char *appl_specifics;
}  XFORMS_appl_version_id =
  { _XFI_appl_version_array,
    0,
    _XFI_appl_product_id,
    0
  };
  

  /*** USE OTHER SPACE FIRST, INSTEAD OF THIS !!!		***/
  /*** so that if XFORMS_sd_appl_version structure increases	***/
char	XFI_DUMMY_FILLER_CHAR_3 [ 144 ]	= {0}; /* dmb:09/28/92:ANSI */



		/********************/
		/* Texture patterns */
		/********************/

unsigned long _FIgray12[32]=
{
   0x11111111, 0x00000000, 0x44444444, 0x00000000,
   0x11111111, 0x00000000, 0x44444444, 0x00000000,
   0x11111111, 0x00000000, 0x44444444, 0x00000000,
   0x11111111, 0x00000000, 0x44444444, 0x00000000,
   0x11111111, 0x00000000, 0x44444444, 0x00000000,
   0x11111111, 0x00000000, 0x44444444, 0x00000000,
   0x11111111, 0x00000000, 0x44444444, 0x00000000,
   0x11111111, 0x00000000, 0x44444444, 0x00000000
};

unsigned long _FIgray50[32]=
{
   0xAAAAAAAA, 0x55555555, 0xAAAAAAAA, 0x55555555,
   0xAAAAAAAA, 0x55555555, 0xAAAAAAAA, 0x55555555,
   0xAAAAAAAA, 0x55555555, 0xAAAAAAAA, 0x55555555,
   0xAAAAAAAA, 0x55555555, 0xAAAAAAAA, 0x55555555,
   0xAAAAAAAA, 0x55555555, 0xAAAAAAAA, 0x55555555,
   0xAAAAAAAA, 0x55555555, 0xAAAAAAAA, 0x55555555,
   0xAAAAAAAA, 0x55555555, 0xAAAAAAAA, 0x55555555,
   0xAAAAAAAA, 0x55555555, 0xAAAAAAAA, 0x55555555
};

unsigned long _FIgray75[32]=
{
   0x77777777, 0xDDDDDDDD, 0x77777777, 0xDDDDDDDD,
   0x77777777, 0xDDDDDDDD, 0x77777777, 0xDDDDDDDD,
   0x77777777, 0xDDDDDDDD, 0x77777777, 0xDDDDDDDD,
   0x77777777, 0xDDDDDDDD, 0x77777777, 0xDDDDDDDD,
   0x77777777, 0xDDDDDDDD, 0x77777777, 0xDDDDDDDD,
   0x77777777, 0xDDDDDDDD, 0x77777777, 0xDDDDDDDD,
   0x77777777, 0xDDDDDDDD, 0x77777777, 0xDDDDDDDD,
   0x77777777, 0xDDDDDDDD, 0x77777777, 0xDDDDDDDD
};


unsigned long _FIwhite[32]=
{
   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
};

	/*** Used in "required" input field gadgets ***/
unsigned long _FI_enable_pttn3[32]=
{
   0xFEFEFEFE, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xEFEFEFEF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xFEFEFEFE, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xEFEFEFEF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
};

Pixmap _FIpix_gray12 = 0;
Pixmap _FIpix_gray50 = 0;
Pixmap _FIpix_gray75 = 0;
Pixmap _FIpix_white = 0;
Pixmap _FIpix_required = 0;

	/* Standard environment function pointer */

unsigned long (*FI_translate_color)()	= _FI_translate_color;
int	(*FI_calc_text)()		= (int (*) () )_FI_calc_text;
int	(*FI_find_form)()		= _FI_find_form;
int	(*FI_draw_text)()		= _FI_draw_text;
int	(*FI_find_font_id)()		= _FI_find_font_id;
int	(*FI_find_symbol_path_and_id)() = _FI_find_symbol_path_and_id;
int	(*FI_process_data)()		= _FI_default_process_data_function;
int	(*FI_set_window_attr)()		= _FI_default_set_window_attr_function;
int	(*FI_get_keyboard_data)()	= _FI_get_keyboard_data;
int	(*FI_activate_help)()		= _FI_default_activate_help_function;
int	(*FI_map_character)()		= _FI_map_character;
int	(*FI_strlen)()			= _FI_iforms_strlen;
int	(*FI_move_index)()		= (int (*) () )_FI_move_index;
int	(*FI_colormap_notify)()		= _FI_colormap_notify;
int	(*_FI_record_notification_routine)() = NULL;

Display	      *	_FI_display		= 0;

Window		_FI_index_to_Xwindow[MAX_WINDOW + 1]= { 0, 0 };
char		_FI_index_to_Xwindow_dummy_filler[200]	= {0}; /* dmb:09/28/92:ANSI */
GC		_FI_gc				= None;
char		_FI_gc_dummy_filler[64]		= {0}; /* dmb:09/28/92:ANSI */

GC		_FI_text_gc			= None;
char		_FI_text_gc_dummy_filler[64]	= {0}; /* dmb:09/28/92:ANSI */
Colormap	_FI_cmap			= None;
char		_FI_cmap_dummy_filler[200]	= {0}; /* dmb:09/28/92:ANSI */

int		_FI_dont_flush		= 0;

int		FI_display_mode		= TRUE;

int		_FI_forms_active	= 0;
int		_FI_system_set_up	= FALSE;

int		_FI_list_up		  = FALSE;
int		_FI_mcf_Reason_for_notify = 0;
int		_FI_poke_inside_mcf	  = 0;
int		_FI_mcf_break_navigation  = 0;

int		FI_sr_mode		= 0;
int		FI_sr_win_num		= 0;
int		FI_sr_area_num		= 0;

struct FIform_obj *FI_forms[MAX_WINDOW + 1]	= { 0 };
char		_FI_forms_dummy_filler[200]	= {0}; /* dmb:09/28/92:ANSI */

struct FIform_obj *FI_sr_forms[MAX_WINDOW + 1]	= { 0 };
char		_FI_sr_forms_dummy_filler[200]	= {0}; /* dmb:09/28/92:ANSI */

XPoint		_FI_vertices[11]		= { 0, 0 };
char		_FI_vertices_dummy_filler[200]	= {0}; /* dmb:09/28/92:ANSI */

int		MI_palette_vert_offset	= 4;

unsigned char *	FI_kill_buffer		= NULL;
int		FI_kill_buffer_index	= 0;
int		FI_kill_buffer_size	= 0;

char		FI_data[1000]		= { (char) NULL };

char 		*FI_keyin_buffer	= NULL;

char		**_FI_symbol_path	= NULL;
char		**_FI_form_path		= NULL;
char		**_FI_font_path		= NULL;
char		**_FI_FSfont_path	= NULL;
char		**_FI_charmap_path	= NULL;

int		_FI_DUMMY_FILLER_INT1	= 0;
int		_FI_DUMMY_FILLER_INT2	= 0;
int		_FI_DUMMY_FILLER_INT3	= 0;

struct FIgroup_obj *_FI_form_list	= NULL;

int		_FI_num_sym_dirs	= 0;
int		_FI_num_form_dirs	= 0;
int		_FI_num_font_dirs	= 0;
int		_FI_num_FSfont_dirs	= 0;
int		_FI_num_charmap_dirs	= 0;

int		FI_current_screen_width = 0;
int		FI_current_screen_height = 0;

int		FI_message_strip_height	= 0;
int		_FI_form_clipping_on	= FALSE;

int		_FI_clip_xlo		= 0;
int		_FI_clip_ylo		= 0;
int		_FI_clip_xhi		= 0;
int		_FI_clip_yhi		= 0;

int		_FI_symbol_array_size	= 0;
int		_FI_font_array_size	= 0;

int		_FI_next_font		= 0;
int		_FI_next_symbol		= 0;

int		_FI_symbol_path_index	= 0;
int		_FI_symbol_path_size	= 0;

struct _FI_sym_st *_FI_symbols		= 0;
struct _FI_font_st *_FI_fonts		= 0;


	/**************************/
	/* Menu interface globals */
	/**************************/

int	(*MI_tear_off_notify)()		= NULL;
int	(*MI_menu_move_routine)()	= NULL;
int	(*MI_window_routine)()		= NULL;

	/**************************/
	/* Menu subsystem globals */
	/**************************/

struct FIform_obj *MS_pocket_menu	= NULL;
struct FIform_obj *MS_bar_menu		= NULL;
struct FIform_obj *MS_panel_menu	= NULL;


			/*** JAJ:11/11/91 ***/
double	FI_auto_scale_factor_x		= 1.0;
double	FI_auto_scale_factor_y		= 1.0;


/******************************************************************/
/*** PUT NEW VARIABLES HERE AFTER REMOVING PROPER AMOUNT	***/
/*** OF SPACE FROM THE FILLER BUFFER BELOW			***/
/******************************************************************/

/* Graphic environment function pointer */
/*   These added 1/14/92     GMD        */

int (*FI_next_event) () = XNextEvent;

/* sml,dmb:04-29-92       should be Window, not int as documented */
Window (*FI_create_window) () = (Window (*) ()) XCreateWindow;

int _FI_select_button = 2; /* GMD 1/14/92  valid values = 1, 2, or 3  */
                           /*                    left, middle, right  */

					/*** JAJ:01/20/92 ***/
int _FI_notification_type = FI_COMPLETION_NOTIFICATION;

/* More Graphic environment function pointers */
       /* GMD 1/24/92 */

int (*FI_mask_event) () = (int (*) () )XMaskEvent;
int (*FI_check_mask_event) () = (int (*) () )XCheckMaskEvent;
int (*FI_if_event) () = XIfEvent;
int (*FI_put_back_event) () = XPutBackEvent;
int (*FI_send_event) () = (int (*) () )XSendEvent;

/*  GMD 2/24/92     More Graphic environment pointers */

int (*FI_grab_pointer) () = XGrabPointer;
int (*FI_ungrab_pointer) () = XUngrabPointer;

/* GMD 3/10/92  Implement Save/Restore form events lockout */

int SaveRestoreFormsDisplayed = 0;

/* GMD 3/17/92   More graphic environment pointers */

int (*FI_check_if_event) () = XCheckIfEvent;
int (*FI_map_raised) () = XMapRaised;
int (*FI_map_window) () = XMapWindow;

/* GMD 3/18/92   More graphic environment pointers */

int (*FI_configure_window)() = XConfigureWindow;
int (*FI_destroy_window)()   = XDestroyWindow;
int (*FI_iconify_window)()   = XIconifyWindow;
int (*FI_query_pointer)()    = XQueryPointer;
int (*FI_unmap_window)()     = XUnmapWindow;
int (*FI_withdraw_window)()  = XWithdrawWindow;

/* GMD 3/20/92 - Merging stuff together */

int FI_push_mode_flag = 0;    /* GMD 2/14/92   For push mode */
int FI_push_mode_ac = 0;      /* GMD 2/14/92   For push mode */
int FI_push_mode_count = 0;   /* GMD 2/14/92   For push mode */

Pixmap _FIpix_gray12_array[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
Pixmap _FIpix_gray50_array[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
Pixmap _FIpix_gray75_array[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
Pixmap _FIpix_required_array[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };

Colormap _FI_cmap_array[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };   /* GMD 3/16/92 */

/* GMD 3/25/92 */

Form SaveRestoreFormsArray[20] = { NULL };

/* GMD 4/20/92 */

int FI_lock_SR_in_Display = 0;


/* char _FI_shared_library_filler_buffer[676]= { NULL }; */

/* sml:07-24-92 */
short _FI_widest_wcharacter = 0;
short _FI_short_alignment_filler1 = 0;

char _FI_widest_character   = 0;
char _FI_char_alignment_filler1 = 0;
char _FI_char_alignment_filler2 = 0;
char _FI_char_alignment_filler3 = 0;

int FI_font_strategy = 0;	/* sml:06-09-93 */

/* sml:09-15-93     add this function variable  TR 249301984 */
void           (*MI_tear_off_modify_routine)()     = NULL;

/* sml:11-05-93 added for FIfld_get_notify_info() function */
int _FI_fld_new_event = -1;
int _FI_fld_new_event_value = -1;
int _FI_fld_new_xpos = -1;
int _FI_fld_new_ypos = -1 ;


Form _FI_fld_new_form = 0;
int _FI_fld_new_gadget = -1;
int _FI_fld_new_event_status = -1;

/* sml:11-22-93 add override for XWindowEvent */

int (*FI_window_event) () = XWindowEvent;

/* 12-16-93 add override */
int (*FI_check_window_event) () = XCheckWindowEvent;

#if (defined(i386) || defined(sparc) || defined(sun) && defined(SYSV)) || defined(mips)
unsigned int _FI_last_button_transition = 0;
#endif

/* sml:10-04-94 add for wrapping stuff */
int _FI_fld_set_text_last_row = 0;

/********************* End New Variables *****************/

char _FI_shared_library_filler_buffer[620]= { (char) NULL }; 

/*******************************************************************/
/* LIST DATES OF VARIABLES ADDED BELOW IN THE FOLLOWING FORMAT     */
/*								   */
/*   DATE       VARIABLE NAME     SIZE    BUF BEFORE    BUF AFTER  */
/*******************************************************************/
/*								   */
/* 11-05-93 _FI_fld_new_event      4         660          656     */    
/* 11-05-93 _FI_fld_new_event_value 4        656          652     */    
/* 11-05-93 _FI_fld_new_xpos       4         652          648     */    
/* 11-05-93 _FI_fld_new_ypos       4         648          644     */    
/* 11-05-93 _FI_fld_new_form       4         644          640     */    
/* 11-05-93 _FI_fld_new_gadget     4         640          636     */    
/* 11-05-93 _FI_fld_new_event_status 4         636          632   */ 
/* 11-17-93 FI_window_event        4         632          628     */ 
/* 12-16-93 FI_check_window_event  4         628          624     */ 
/* 10-04-94 _FI_fld_set_text_last_row        624          620     */
/*								   */
/*******************************************************************/

