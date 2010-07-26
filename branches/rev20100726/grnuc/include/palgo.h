/******************************************************************************

File: 
 
    palgo.h
 
Description:

    This file defines several structures used in the creation and storage
    of palettes. Error messages for the palette system are also defined in
    this file.
    
******************************************************************************/

#ifndef palette_include
#define palette_include

/*
 * This file depends on FI.h
 */
struct palette_cmd
{
    struct palette *p;
    int             label;
    int             row;
    int             col;
};

struct palette
{
    int     label;
    char *  form;
    int     rows;
    int     cols;
    int     btn_x;
    int     btn_y;
    int     slot;
    struct palette  *next;
    int     props;
};

struct os_palette 
{
    /* form properties */
    int  properties;
    int  color;
    int  rows;
    int  cols;
    int  xpos;
    int  ypos;
    int  xsize;
    int  ysize;
    int  num_cmds;
    int  cmds;

    /* command button properties */
    int  btn_x;
    int  btn_y;
    int  btn_on_color;
    int  btn_off_color;
};

struct os_palette_cmd
{
    int	row;
    int col;
    int symbol;  
    int command_type;
    int command;     /* index into command key array */
    int symbol_file;  /* index into icon file array */
};

/* error messages */
#define PAL_E_ABORT      ( ERRO )
#define PAL_E_INVNAME    (  8 | ERRO )
#define PAL_E_INVSIZE    ( 16 | ERRO )
#define PAL_E_INVCOLOR   ( 32 | ERRO )
#define PAL_E_EXISTS	 ( 64 | ERRO )
#define PAL_W_MAXCMDS    (  8 | WARN )
#define PAL_W_BADSYMB    ( 16 | WARN )
#define PAL_W_BADCMD     ( 32 | WARN )
#define PAL_W_VERCHG     ( 64 | WARN )
#define PAL_W_NOCMD      (128 | WARN )
#define PAL_S_SUCCESS    (  8 | SUCC )

/* palette icons */
#define PAL_DEL_FORM 251

/* properties */                /* indicates that the pallette... */
#define PAL_COLLAPSED   0x0001  /* ...is collapsed */
#define PAL_YADJUSTED   0x0002  /* ...has been moved down 55 pixels (necessary
                                   because pre 1.4.1 palettes need to be moved
                                   down to accomodate the message strip */
#define PAL_AUTODISMISS 0x0004  /* ...will dismiss itself after a selection */
#define PAL_NODISPLAY   0x0008  /* ...should not be displayed */

/* base label */
#define GRpal_group 19

/* misc */
#define PAL_BORDER 	6
#define PAL_MAX_LABEL 	10

/* maximum length of a command string tied to a palette button */
#define PAL_MAX_CMD_LENGTH      128

/* justification of a popup wrt the button that invoked it */
#define PAL_CENTER_JUSTIFY      0x00000001
#define PAL_LEFT_JUSTIFY        0x00000002

/* flag setting for GRpal_save_file() */
#define PAL_DONT_ASK_BEFORE_SAVE  (0)
#define PAL_ASK_BEFORE_SAVE       (1)
     
#endif
