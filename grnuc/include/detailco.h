#ifndef drawcomp_include
#define drawcomp_include

/*
 * Command types.
 */
#define CO_realigndv    0
#define CO_attachmd     1
#define CO_auxview      2
#define CO_drawsheet    3
#define CO_drawview     4
#define CO_prinview     5
#define CO_detachmd     6
#define CO_dropalgn     7
#define CO_layeroff     8
#define CO_layeron      9
#define CO_manageds     10
#define CO_scaledv      11
#define CO_scaleref     12
#define CO_activedv     13
#define CO_revref       14
#define CO_revdv        15

/*
 * Send foreign messages.
 */
#define CO_put_drawview_desc            0
#define CO_display_cs                   1
#define CO_get_drawview_scale           2
#define CO_get_drawview_label           3
#define CO_display_drawview_layers      4
#define CO_detach_model                 5
#define CO_display_drawing_views        6
#define CO_display_drawing_attachments  7
#define CO_drop_alignment               8
#define CO_get_projection_angle         9
#define CO_realign_drawing_view         10
#define CO_get_cs_id                    11

/* 
 * Types of text to construct.
 */
#define CO_name                         0
#define CO_scale                        1

/*
 * Review Form Labels
 */
#define CO_title        11
#define CO_mcf   	12
#define CO_msg          10
#define CO_col1         14
#define CO_col2         15
#define CO_col3         16

/*
 * Error Messages
 */
#define CO_no_ref_files	151515

/*
 * dsco stuff.*****************************************************************
 */

/* Form labels */
#define MAIN_FORM                  0
#define STANDARD_FORM              1
#define SHEET_FORM                 2
#define REVREF_FORM                3
#define REVDV_FORM                 4

/* Subform Modes */
#define ADD_MODE                   0
#define MOD_MODE                   1

/* Gadget labels for the review edit drawing sheet standards form */
#define EXIT_BUTTON                1
#define EXIT_RETURN_BUTTON         2
#define QUIT_BUTTON                4
#define WINDOW_BUTTON              5
#define HELP_BUTTON                6
#define FORM_TITLE_TEXT            11
#define STANDARD_FIELD             12
#define UNITS_TOGGLE               13
#define ANGLE_TOGGLE               14
#define SHEET_FIELD                15
#define MSG_FIELD                  10
#define NAME_FIELD                 16
#define STD_ADD_BUTTON             20
#define STD_DEL_BUTTON             22
#define STD_MOD_BUTTON             23
#define SHT_ADD_BUTTON             24
#define SHT_DEL_BUTTON             25
#define SHT_MOD_BUTTON             26
#define IMPERIAL_CHECK             27
#define METRIC_CHECK               28
#define FIRST_CHECK                29
#define THIRD_CHECK                30
#define VIEW_SCALE_FIELD           31
#define FILE_TOGGLE                32
#define FILENAME_FIELD             33
#define VIEW_CELL_TEXT             34
#define VIEW_CELL_FIELD            35
#define WIDTH_FIELD                36
#define HEIGHT_FIELD               37
#define FIT_TOGGLE                 38
#define ACTIVE_TOGGLE              39

/* Toggles for Setting me->mask (IGRuint) */
#define UNITS_TOG             0x01      /* .... ...1 */
#define ANGLE_TOG             0x02      /* .... ..1. */

/* Bit manipulation macros */
#define   _is_on(x,y)        ( ((x)  & (y)) ? 1 : 0 )
#define   _toggle(x,y)       (x) ^= (y)
#define   _turn_on(x,y)      (x) |= (y)
#define   _turn_off(x,y)     (x) &= ( ~(y) )

/* Misc defines */
#define ALL_TOGGLES           0
#define EXIT_SAVE             0
#define EXIT_SAVE_RETURN      1
#define EXIT_NO_SAVE          2

#define sheet_ndx    0
#define standard_ndx 1


/*
 * Defines and struct for the review forms.
 */
#define EOD  '\004'

struct ref_node
{
    int         depth;
    char *      next;
    char *      data;
};

struct COform_info
{
    char *          form;
    int             label;
    int             depth;
    int             row;
    char            ** list;
};

#define TITLE_FIELD     11
#define OPTIONS_FIELD   12
#define DIR_FIELD       13

#define ENABLEOPT_MODE     -1
#define VIEW_MODE           0
#define ORIENTATION_MODE    1
#define FILENAME_MODE       2
#define SCALE_MODE          3
#define DISABLEOPT_MODE     4

#endif
