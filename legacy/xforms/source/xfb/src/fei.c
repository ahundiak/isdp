/***********************************

		fei.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*********************************************************************/
/* */
/* No functions from this file are used at the current time. */
/* GMD 4/11/91 */
/* */
/*********************************************************************/


#include <stdio.h>

#include <X11/Xlib.h>


#include "iHelp.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"


#define ROP 0
#define IFB 1

#define TYPEFACE_LIST_FLD 22

#include "FI.h"
#include "FIappl.h"

#include "FEI.h"

#define BS_FONTS 1
#define FS_FONTS 0

#define TRUE 1
#define FALSE 0


/*** Japan ***/

extern char LOGKBD;

extern unsigned char key_buf[256];
extern char execute_dir[200];

extern int fonts_to_use;
extern char FS_search_directory[200][256];
extern char BS_search_directory[200][256];
extern char SYM_search_directory[200][256];
extern int FS_dir_count;
extern int BS_dir_count;
extern int SYM_dir_count;

extern Form Font_form;

extern char language[80];

/* sml:08-13-93 make label_font_id extern */
extern int label_font_id; /* Needed by preview form command */

/*** need these two for help system **** 11-14-89 ***/
extern int FB_help_initialized_flag;
extern char FB_help_topic[128];
extern int Two_vscreens_flag;
extern struct vlt_slot vlt2[15];

extern GC xfb_GC;
extern XGCValues GC_values;
extern int hilite_plane;
extern Display *display;

extern int font_count;
extern Font Font_array[200];

int FEI_get_keyboard_data (char *character,
                           int  *count,
                           int   font_type)
{

  if (font_type == 2)
     talk_to_kb ( character, count );

  return ( FI_SUCCESS );
}

/*-------------------------------------------------------------------------*/

int FEI_enter(void)
{
  extern FB_activate_help();

  FI_modify_env ( FI_GET_KEYBOARD_DATA, FEI_get_keyboard_data);

  return ( FI_SUCCESS );
}
