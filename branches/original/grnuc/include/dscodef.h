#ifndef dscodef_include
#define dscodef_include

/* Command types */
#define CREATE_DS                  0
#define MANAGE_DS                  1

/* Form labels */
#define MAIN_FORM                  0
#define STANDARD_FORM              1
#define SHEET_FORM                 2

/* Subform Modes */
#define ADD_MODE                   0
#define MOD_MODE                   1

/* Gadget labels */
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

#endif

