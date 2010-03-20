
/*****************************************/
/*                                       */
/*   Listing of form labels used in NFB  */
/*                                       */
/*****************************************/

#define F_define          1
#define F_work            2 
#define F_button          3
#define F_button_type     4
#define F_button_palette  5

#define TRUE   1
#define FALSE  0

struct form_data		/* form	initialization structure */
{
    int sr_flag;                /* Save/restore window?          */
    int border_flag;            /* Will the form have a border?  */
    int bezel_flag;             /* Will the form have a bezel?   */
    int collapse;		/* Will form be displayed as     */
                                /* a collapse icon?              */
    
    int resize_flag;            /* Is form resizing allowed?      */
    int revert_flag;            /* Is form revert sizing allowed? */
    int scaling_flag;           /* Is form scaling allowed?       */
    int fit_flag;               /* Is form fitting allowed?       */
			
    int  screen_number;		/* FI_CURRENT_SCRN	*/
				/* FI_DEFAULT_SCRN	*/
				/* FI_HARDCODED_SCRN    */
    int  absolute_screen;
    int  col_pos[2];		/* location of collapsed icon */
    int  win_x1;		/* window location - relative to */
    int  win_y1;		/* upper left corner of screen	 */
    int  win_x2;
    int  win_y2;
    int  x_size;                /* win_x2 - win_x1 */
    int  y_size;                /* win_y2 - win_y1 */
    char form_name[200];        /* name of form */
    char new_form_name[200];
    char symbol_file[200];      /* icon file for collapsed form */
		                /* menu_collapse is the default */
    int  symbol_number;		/* icon # for collapsed form 	 */
				/* 0 - form		*/
				/* 1 - MENU_STRIP	*/
				/* 2 - MENU_PANEL 	*/
    char desc[3][200];          /* description of form */
    
    int draw_flag;     /* Whether data points will be used to define */
                       /* the size of the new work form.             */
};

struct dpb_struct
{
   int bgcolor;

   int grid_flag;
   int grid_master_units;
   int grid_sub_units; 
   
   int off_color;
   int on_color;
   int line_style;
   int line_weight;
   int line_depth;
   
   char font_name[200];
   float bodysize;
   int text_style;
   int text_justification;   

   int expansion1;
   int expansion2;
   int expansion3;
   int expansion4;
   
   char expansion_str[196];
};

struct column_struct
{
   int lines_default_text;
   int lines_list_default_text; 

   int num_cols;
   int field_mode;
   int field_type;

   int replace_text_flag; 
   double maximum_value;
   double minimum_value;

   int line_notification;
   int echo_flag;
   
   int horz_scroll_enable;
   int horz_scroll_display;
   int wrap_flag;
   int required_flag;

   /* Hebrew 8/02/90 */
   int right_to_left_flag;
   int reverse_input_flag;
   int reverse_output_flag;
   int justification;

   char format[200];

   /*  Associated list features  */

   int list_exists_flag;
   int list_verify_flag;

   int list_xsize;
   int list_ysize;
   int list_num_rows;
   int list_num_cols;
   int list_x_pos;
   int list_y_pos;
   int list_mode;
   int list_display_flag;

   int list_draw_flag;
   int list_poke_flag;
};

struct gadget_struct
{
   int display;
   int selectable;
   int hilite;
   int initial_notify;
   int complete_notify;
   int help;
   int cmd_string;
   int data;
   int cmd_key;
   int text_string;
   int text_gadget;
   int dither;
   int vert_scroll_notify;

   char command_string[200];
   char help_topic[200];
   int gadget_label;
   
   double value;
   char font_name[200];
   float bodysize;
   int text_style;
   int text_justification;  
   
   double low_value;
   double high_value;
   double default_value;
   
   int high_display_flag;
   int initial_display_flag;
   int low_display_flag; 
 
   int orientation;
   int display_format;
   int whole_digits;
   int fraction_digits;

   double increment;
   int x_pos;
   int y_pos;
   int x_size;
   int y_size;
   
   char symbol_file[200];
   int on_sym_index;
   int off_sym_index;
   int on_color;
   int off_color;

   int dial_rotation;
   int dial_bezel;
   double dial_zero_location;
   int dial_ticks;
   
   int line_weight;
   int line_style;
   int line_depth;

   int auto_popup_flag;
 
   char off_text[50000];
   char on_text[50000];
  
   int gadget_type;
   int group;
   int continuous_notify_flag;
   
   int draw_flag;
   int poke_flag;

   /*  all of the following is field stuff  */

   int num_rows;
   int num_cols;
   int visible_cols;
   int field_mode;
   int field_type;

/* Hebrew - 30-01-90 */
   int right_to_left;
   int reverse_input_flag;
   int reverse_output_flag;

   int wrap_flag;
   int required_flag;
   int display_scroll_flag;
   int horz_scroll_flag;
   int vert_scroll_flag;
   int roll_through_flag;
   int scroll_mode;

   int replace_text_flag; 
   char default_str[50000];
   double maximum_value;
   double minimum_value;

   int line_notification;
   int echo_flag;

   /*  Associated list features  */

   int list_exists_flag;
   int list_verify_flag;
   int list_vert_flag;
   int list_horz_flag;

   int list_xsize;
   int list_ysize;
   int list_num_rows;
   int list_num_cols;
   int list_x_pos;
   int list_y_pos;
   int list_mode;
   int list_display_flag;

   int list_draw_flag;
   int list_poke_flag;
};

struct seq_struct 
{
   int gadget;
   int to_gadget;
   int line_color;
   int hilite_flag;
   int display_flag;
   int xlo[3];
   int ylo[3];
   int xhi[3];
   int yhi[3];
};

#define DEFINE_FORM        1
#define SAVE_FORM          2
#define EXIT_FB            3
#define PLACE_BUTTON       4
#define PREVIEW_FORM       5
#define PLACE_FIELD        6
#define PLACE_CHECKLIST    7
#define PLACE_TEXT         8
#define CHANGE_PV          9
#define PLACE_SYMBOL      10
#define PLACE_TOGGLE      11
#define PLACE_CBAR        12
#define PLACE_SLIDER      13
#define PLACE_DIAL        14
#define PLACE_RECTANGLE   15
#define PLACE_LINE        16
#define PLACE_PALETTE     17
#define TOGGLE_FORM_SCALING  18
#define FIT_FORM          19
#define PLACE_ERROR_FIELD 20
#define PLACE_BEZEL       21
#define MOVE_GADGET       22
#define COPY_GADGET       23
#define EDIT_GADGET       24
#define DELETE_GADGET     25
#define PLACE_MULTI_COL   26
#define FENCE_MOVE        27
#define SAVE_PV           28
#define PLACE_GAUGE       29
#define CREATE_SEQUENCE   30
#define DELETE_SEQUENCE   31
#define REVIEW_SEQUENCE   32
#define CREATE_DATA_LINK  33
#define DELETE_DATA_LINK  34
#define REVIEW_DATA_LINK  35
#define CREATE_GROUP      36
#define DROP_FROM_GROUP   37
#define DELETE_GROUP      38
#define FENCE_COPY        39
#define FENCE_DELETE      40
#define GROUP_MOVE        41
#define GROUP_COPY        42
#define GROUP_DELETE      43
#define PLACE_SCROLL      44
#define EXPANDED_PREVIEW  45
#define UNDELETE_GADGET   46
#define FENCE_UNDELETE    47
#define GROUP_UNDELETE    48
#define SHOW_GROUP        49
#define FENCE_EDIT        50
#define GROUP_EDIT        51
#define DISPLAY_CHAR      52
#define DELETE_FORM       53
#define COPY_FORM         54

#define NO_SCROLLING            0
#define VERTICAL_SCROLL_ONLY    1
#define HORIZONTAL_SCROLL_ONLY  2
#define BOTH_DIRECTION_SCROLL   3

/************************************************/
/*                                              */
/*  Constants used to process the startup file  */
/*                                              */
/************************************************/

#define KEYWORD_TOKEN   0
#define STRING_TOKEN    1
#define INTEGER_TOKEN   2
#define OTHER_TOKEN     3

#define FS_FONTS        0
#define BS_FONTS        1
