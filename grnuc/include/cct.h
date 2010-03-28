#ifndef cct_include
#define cct_include 1

struct COlog_col_pos
{
   short x;
   short y;
   short width;
   short height;
};

#define LOGICAL_COLOR		1
#define DITHERED_COLOR		2
#define HUE_SAT_BLOCK	        3
#define LUM_RANGE		4
#define SOLID_COLOR		5
#define CROSS_HAIRS             6

#define LOGICAL_COLOR_X		42
#define LOGICAL_COLOR_Y		40
#define LOGICAL_COLOR_WIDTH	32
#define LOGICAL_COLOR_HEIGHT	26
#define LOGICAL_COLOR_SPACE_WIDTH 6
#define LOGICAL_COLOR_SPACE_HEIGHT 6

#define DITHERED_COLOR_X	366
#define DITHERED_COLOR_Y	316
#define DITHERED_COLOR_WIDTH	50
#define DITHERED_COLOR_HEIGHT	50
#define SOLID_COLOR_X 		416
#define SOLID_COLOR_Y		316
#define SOLID_COLOR_WIDTH 	50
#define SOLID_COLOR_HEIGHT	50

#define HUE_SAT_BLOCK_X		355
#define HUE_SAT_BLOCK_Y		40
#define HUE_SAT_BLOCK_WIDTH	362
#define HUE_LUM_GAP_WIDTH	24
#define LUM_RANGE_X		732
#define LUM_RANGE_Y		40
#define LUM_RANGE_WIDTH		28
#define COLOR_HEIGHT		258

#define CCT_FORM_LABEL	1

#define RECTANGLE_HUE_SAT	11
#define RECTANGLE_LUM_RANGE	12
#define RECTANGLE_DITHERED_COLOR	13
#define RECTANGLE_SOLID_COLOR	14
#define TEXT_COLOR	33
#define TEXT_FLAT	34
#define TEXT_COLOR_CODE		41
#define KEYIN_COLOR_CODE	39
#define TEXT_NAME	40
#define KEYIN_NAME	38

#define BUTTON_OPTIONS	116
#define TEXT_PAGE	125
#define KEYIN_PAGE	126
#define SCROLL_PAGE	20

#define TEXT_RED	27
#define TEXT_GREEN	28
#define TEXT_BLUE	29
#define TEXT_HUE	30
#define TEXT_LUMINANCE	32
#define TEXT_SATURATION	31
#define KEYIN_RED	21
#define KEYIN_GREEN	15
#define KEYIN_BLUE	16
#define KEYIN_HUE	17
#define KEYIN_LUMINANCE	18
#define KEYIN_SATURATION	19
#define SCROLL_HUE		22
#define SCROLL_LUMINANCE	23
#define SCROLL_SATURATION	24
#define SCROLL_RED		25
#define SCROLL_GREEN		26
#define SCROLL_BLUE		128

#define COLOR_PALLET_0_0   43
#define COLOR_PALLET_1_1   52

/* Options Subform */
#define OPTIONS_SUBFORM_LABEL	0

#define TEXT_NUM_RAMP_COLORS    30
#define KEYIN_NUM_RAMP_COLORS   28
#define SCROLL_NUM_RAMP_COLORS  29
#define KEYIN_CUBE_SIZE         27
#define TOGGLE_GAMMA_COMPENSATE	24
#define TOGGLE_SCROLL_RANGE	23
#define TOGGLE_NAME_MODE	22
#define KEYIN_FILE_NAME		13
#define BUTTON_ATTACH		16
#define BUTTON_SAVE		15
#define TOGGLE_FILE_TYPE	17
#define FIELD_MESSAGE		10


/* List of gadgets to be adjusted with pallet */
/* 53093 fix PALLET_ADJUST_LIST ? */
#define NUM_PALLET_ADJUST_GADGETS	39

#define CCT_BGNUM	-1		/* BACKGROUND color code			*/
#define CCT_GRNUM	-2		/* GRID color code				*/
#define CCT_HLNUM	-3		/* HIGHLIGHT color code				*/

#define CCT_MAXRGB	0xffff		/* maximum value for a RED, GREEN or BLUE field	*/

#define NAME_SELECT_MODE	TRUE	/* name SELECT mode				*/
#define NAME_RENAME_MODE	FALSE	/* name RENAME mode				*/

#define INTERPOLATE_COLORS_MODE	TRUE	/* interpolate COLORS mode			*/
#define INTERPOLATE_SHADES_MODE	FALSE	/* interpolate SHADES mode			*/

/* color pallet parameters */
#define PALLET_XLOC	42
#define PALLET_YLOC	42
#define MAX_PALLET_WIDTH	498
#define MAX_PALLET_HEIGHT	496
#define MIN_BLOCK_WIDTH	20
#define PALLET_COLOR_HIGHLIGHT_WEIGHT	1
#define PALLET_DELIMITER_LINESTYLE	0xffff

#ifdef X11 
#define         UP              0               /* up           */
#define         DOWN            1               /* down         */
#define         SINGLE_CLICK    2               /* click        */
#define         DOUBLE_DOWN     3               /* double down  */
#define         DOUBLE_CLICK    4               /* double click */
#define         TRIPLE_DOWN     5               /* triple down  */
#define         UP_DOWN_UP      6               /* up down up   */
#define         UP_DOWN         7               /* up down      */
#define         LEFT_BUTTON     0               /* left button */
#define         MIDDLE_BUTTON   1               /* middle button */
#define         RIGHT_BUTTON    2               /* right button */

#define XPALLET_PATTERN_WIDTH 32
#define XPALLET_PATTERN_HEIGHT 32
#define XDEFAULT_PATTERN_WIDTH 32
#define XDEFAULT_PATTERN_HEIGHT 32
#endif 

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* DPcolors.C */
extern IGRint DPchek_clr_tbl __((IGRchar file_nme[]));
extern IGRint DPload_clr_tbl __((IGRchar file_nme[], IGRint *file_type));
extern IGRint DPsave_clr_tbl __((char file_nme[]));
extern IGRint DPret_clr_tbl __((IGRint *msg, IGRchar file_nme[], IGRint *file_type, IGRint *bg_color, IGRint *fg_color, IGRint *hl_color, IGRshort *num_colors, IGRint *colors, IGRshort *num_names, struct IGEcol_names *names));
extern void DPcnv_short __((char *s));
extern void DPcnv_int __((char *s));
extern int DPconv_read __((char *s, int n, int l, FILE *fp1));
extern int DPconv_write __((char *s, int n, int l, FILE *fp1));

/* COcct_hls.I */
extern void rgb_to_hls __((double red, double green, double blue, double *hue, double *luminance, double *saturation));
extern void rgb_from_hls __((double *red, double *green, double *blue, double hue, double luminance, double saturation));

/* COcct_init.I */
extern IGRint COget_raster_data_struct __((  IGRint raster, struct WLraster_data **raster_data_ptr ));
extern void GRCreColorTb_button_intercept_routine __((Form fp, int xpos, int ypos, int button_number, int transition, int time_tag));
extern void GRCreColorTb_window_event_routine __((int f_label, int event, Form fp));
extern void GRCreColorTb_continuous_routine __((int form_label, int gadget_label, double value, Form fp));

/* COcct_input.I */
extern char *CCTget_text __((Form fp, int g_label));

/* COcct_pallet.I */
extern IGRint HRindex_hls __((WLuint32 context_no, IGRint x, IGRint y, IGRdouble hue, IGRdouble luminance, IGRdouble saturation));

#if defined(__cplusplus)
}
#endif


#undef __

#endif /* cct_include */

