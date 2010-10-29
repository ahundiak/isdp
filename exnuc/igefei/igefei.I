class implementation Root;

from super_cmd import help, help_topic;

%safe
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <exsysdep.h>
#include <igewinmacros.h>

#ifndef NT
#include <sys/param.h>
#else
#define MAXPATHLEN _MAX_PATH
#endif

#include "FI.h"
#include "FEI.h"
#include "FIappl.h"

#ifdef NT
#include "shampub.h"
#endif

#ifdef ENV5
#include "FIdyn.h"
#include "MI.h"
#include "tools.h"
#include "FIproto_pub.h"
#endif

#include "igrtypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "OMerrordef.h"

#include "FS.h"

#include "FSBmap.h"
#include "limits.h"	  /* need this for PATH_MAX #define */
#include "femacros.h"

#include "exlocaledef.h"
#include "exlocale.h"
#include "exproto.h"
#include "wl.h"
#include "cm.h"
#include "exfi.h"

#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>

extern Display *EXdisplay;
static int (*FEI_translate_color)();

extern int EX_logkbd;

#include <XFIproto_pub.h>
#endif

/**********************************************************/
/*** IMPORTANT NOTE:					***/
/***   the fidef.h needs to included last because of	***/
/***   defines for ci. FI_ALPHA, FI_INT, etc. collision	***/
/***   with new forms defines				***/
/**********************************************************/


static int sendHelp( unsigned short, unsigned int );
static int sendHelpTopic( unsigned short, unsigned int, int, char * );

/* Local defines */


#define ROLL_THRU		10		/* RAP */
#define SELECT_LIST		11		/* RAP */
#define ROW_SELECT		12		/* RAP */



#define ROP		 	0
#define IFB		 	1
#define PATH_LENGTH	 	256
#define ABS(x)	         	((x) < 0 ? -(x) : (x))

#define IGE_COLOR_OFFSET 	10000
#define	DIR_ALLOC_SIZE		10

#define MAX_DISTANCE_SQUARED  	3.0 * ( 65472.0 *  65472.0)

/*** Global variables ***/



/*** Local variables ***/

#ifdef ENV5
static struct vlt_slot	* IGEFEI_fixed_vlt	 = 0;
static int	          IGEFEI_fixed_vlt_size = 0;
static int            IGE_running_on_server = 0;
#endif

static char		 IGE_language[15];

static struct EXFI_data_st f_data;

static int		 kanji_font_id = 0;

#ifdef ENV5
static struct scr_info	 FEI_info[MAX_SCREENS];
#endif

static  double double_x;
static  double double_y;


static	char ** IGEFEI_FSfont_path 	 = 0;
static  int	IGEFEI_FSfont_path_index = 0;
static  int	IGEFEI_FSfont_path_size  = 0;

static struct font_st 
{
   char fontname[15];
   int bodysize;
   int font_id;
   int font_type;
} * fonts;

static int font_array_size;
static int next_font;
static int load_fs_fonts;

#ifdef ENV5
/**************************/
/*** Journaling externs ***/
/**************************/

#endif

/*** Exnuc externs ***/

extern int	EX_delete_win();
extern int      RAPFormListener();


/*** Menu subsystem externs ***/

extern int _MS_check_ptr();
extern Form	MS_pocket_menu;
extern Form	MS_bar_menu;
extern Form	MS_panel_menu;
%endsafe

%safe

#argsused
int IGE_record_routine (

  int    form_label,
  int    g_label,
  double value,
  Form   form)
{
  int type, i, num_rows, selected;
  char form_name[15];

	/* Zero out structure */

  memset ( (char *) &f_data, 0, sizeof( struct EXFI_data_st ) );
	/* Build form structure */

  f_data.label = g_label;
  f_data.index = (int)value;

		/* Determine type of f_data */

  FIg_get_type ( form, g_label, &type );

  if ( ( type == FI_BUTTON )	|| ( type == FI_TOGGLE ) ||
       ( type == FI_SYM )	|| ( type == FI_TEXT )   ||
       ( type == FI_CHECKLIST )				  )
    {
	f_data.type = EXFI_STATE;
	f_data.value.state = (char)value;
    }
  else if ( ( type == FI_FIELD ) || ( type == FI_MULTI_COL ) )
    {
      long attr;
      int row = (int) value;
      int column = 0;	/* Default */
      int dummy;

	/*********************************************/
	/* if it is a mcf then get the active column */
	/*********************************************/

      if ( type == FI_MULTI_COL )
	{
	  FImcf_get_active_col ( form, g_label, &column, &dummy );

		/* See if the row selection button was hit */

	  if ( value == -1 )
	    {
		f_data.type = ROW_SELECT;

		FIfld_get_active_row ( form, g_label,
					&f_data.index, &dummy );

		/* See if the row was selected or unselected */

		FIfld_get_select ( form, g_label, f_data.index,
				  	   0, &f_data.select_flag );

		goto quit;
	    }
	}

	/* Store the column in the sts member of the structure */

      f_data.max_index = column;

		/* Determine what type of field it is */

      FIfld_get_type ( form, g_label, column, &type );

	/* Use numbers because of difference between FI.h and fidef.h */

      FIfld_get_attr ( form, g_label, column, &attr );

      if ( attr & FI_ROLL_THRU )
	{
	  f_data.type = ROLL_THRU;
	}
      else if ( type == 1 )
	{
	  double double_value;

	  f_data.type = EXFI_INT;

 	  FIfld_get_value ( form, g_label, row, column,
				&double_value, &f_data.select_flag,
				&dummy );

	  f_data.value.ivalue = (int) double_value;
	}
      else if ( type == 2 )
	{
	  f_data.type = EXFI_DOUBLE;

 	  FIfld_get_value ( form, g_label, row, column,
			    &f_data.value.dvalue, &f_data.select_flag,
			    &dummy );
	}
      else
	{
	  f_data.type = EXFI_ALPHA;

		/* 130 is max for alpha */

	  FIfld_get_text ( form, g_label, row, column,
				 130, (unsigned char *)&f_data.value.alpha[0],
				 &f_data.select_flag, &dummy );
	}

      /* Added this to get associated list to work in RAP.  Doree 7/2/93 */

      if ( (attr & FI_ASSOCIATED_LIST) || (attr & FI_POPUP_ASSO_LIST) )
      {
          FIfld_get_list_num_rows(form, g_label, 0, &num_rows);

          for (i = 0; i < num_rows; i++)
          {
              FIfld_get_list_select(form, g_label, i, 0, &selected);
              if (selected)
              {
                  f_data.index = i;
                  f_data.select_flag = EXFI_SELECTED;
                  break;
              }
          }
      }

    }
  else
    {
	/* sliders and Dials */

	f_data.type = EXFI_DOUBLE;
	f_data.value.dvalue = value;
    }

quit:

  FIf_get_name ( form, form_name );

	/* Call RAPFormListener and give data structure */

  RAPFormListener ( form_name, &f_data );
#ifdef X11
return(1);
#endif
#ifdef NT
  return 1;
#endif
}



void IGE_fei_get_set_help_topic ( form, get_set_flag, help_topic )
  Form form;
  int  get_set_flag; /* 0 = set, 1 = get */
  char *help_topic;
{
  unsigned int	 cmd_oid;
  unsigned short cmd_os;
  int		 status;

  status = FIf_get_cmd_oid_os ( form, & cmd_oid, & cmd_os );

  if ( ! status )
    { /*** set the help topic ***/
      status = sendHelpTopic( cmd_os, cmd_oid, get_set_flag, help_topic );

      if ( ! ( status & 1 ) )
        {
          fprintf ( stderr,
	    "IGEFEI_ERROR:  IGE_fei_get_set_help_topic -- error super_cmd.help_topic status = 0x%x\n",
	  status );
	}
    }
}



int IGEfei_activate_help ( form )
  Form form;
{
  unsigned int	 cmd_oid;
  unsigned short cmd_os;
  int		 status;

  status = FIf_get_cmd_oid_os ( form, & cmd_oid, & cmd_os );

  if ( status )
    {
      fprintf ( stderr,
	"IGEFEI_ERROR:  IGEfei_activate_help -- error FIf_get_cmd_oid_os status = %d\n",
	status );
      return(0);
    }

    /*** call the help process ***/
  status = sendHelp( cmd_os, cmd_oid );

  if ( ! ( status & 1 ) )
    {
      fprintf ( stderr,
        "IGEFEI_ERROR:  IGEfei_activate_help -- error send to (%d,%d) of super_cmd.help() status = 0x%x\n",
	cmd_oid, cmd_os, status );
    }
return (1);
}  /*** IGEfei_activate_help() ***/


#ifdef ENV5
int IGE_get_refresh_area_data ( window, vs, xlo, ylo, xhi, yhi,
			   axlo, aylo, axhi, ayhi, opmask )
  int * window;
  int * vs;
  int * xlo;
  int * ylo;
  int * xhi;
  int * yhi;
  int * axlo;
  int * aylo;
  int * axhi;
  int * ayhi;
  int * opmask;
{
  int status;
  status = JNL_get_refresh_area_data ( window, vs, xlo, ylo, xhi, yhi,
				    axlo, aylo, axhi, ayhi, opmask );
  if ( JNL_playback() )
    {
	*opmask |= WN_WAS_COVERED;
    }
return (status);
}
#endif


void IGE_record_rap_point ( form, xpos, ypos, button, trans )
  Form form;
  int *xpos;
  int *ypos;
  int *button;
  int *trans;
{

  char form_name[15];

	/* Zero out structure */

  memset ( (char *) &f_data, 0, sizeof( struct EXFI_data_st ) );


	/* Build form structure */

  f_data.type  = EXFI_POINT;
  f_data.value.btn.x = *xpos;
  f_data.value.btn.y = *ypos;
  f_data.value.btn.numb = *button;
  f_data.value.btn.down = *trans;	/* Ignore original purpose */

  FIf_get_name ( form, form_name );

	/* Call RAPFormListener and give data structure */

  RAPFormListener ( form_name, &f_data );
}

#ifdef ENV5

int IGE_inq_button_data ( window, xpos, ypos, button, trans, ttag )
  int *window;
  int *xpos;
  int *ypos;
  int *button;
  int *trans;
  int *ttag;
{
  int (*btn_routine)();
  int (*int_routine)();
  int gadget_label;
  Form form;
  int status;

	/* Get inq info */

  JNL_inq_button_data ( window, xpos, ypos, button, trans, ttag );


	/* See if the window is over a form */

  FI_get_form ( *window, &form );

  if ( ! form ) return(1);


	/* See if form has either routine defined */

  FIf_get_button_intercept_routine ( form, &int_routine );

  FIf_get_button_event_routine ( form, &btn_routine );


  if ( JNL_playback() )
    {
		/* If the form has a button intercept routine
		   or a button event routine set up then pass
		   the point on */

	if ( ( int_routine ) || ( btn_routine ) ) return(1);

		/* See if there is a gadget under the point */

	status = FIf_find_gadget ( form, FI_FORM_GROUP,
			*xpos, *ypos, &gadget_label );

	if ( status )
	  {
		/* Set the window to -1 so that the form
	   	   will not claim this point */

		*window = -1;
	  }
    }
  else
    {
	/* If this point is over a form that 		*/
	/*   has a button_intercept or button_event	*/
	/*   routine defined then record this point	*/

      if ( int_routine )
	{
	  IGE_record_rap_point ( form, xpos, ypos, button, trans );
	}
      else if ( btn_routine )
	{
		/* See if the point is over a gadget */

	  status = FIf_find_gadget ( form, FI_FORM_GROUP,
					*xpos, *ypos, &gadget_label );

		/* If it is not then record point */

	  if ( status )
	    IGE_record_rap_point ( form, xpos, ypos, button, trans );
	}
    }
return (1);
}

#endif

int IGE_delete_win ( window )
  int  window;
{
#ifdef X11
  XDestroyWindow ( EXdisplay, window );
#elif defined( NT )
#elif defined(ENV5)
  Delete_win ( window );
#elif defined( NT )
#else
#error Unknown GUI
#endif
	/* Tell tony that the window was deleted */

  EX_delete_win ( window );
return (1);
}




#ifndef NT
#ifdef X11
#if defined (SPARC)

/*******************************************************************
 *  I got this function from SUN because on SPARC workstations, the
 *  keypad equals '=' button on type 4 keyboards and the keypad minus
 *  '-' on type 5 keyboards are mapped to the same keysym.  
 *
 *  Mike Lanier:  Oct. 13, 1995
 *******************************************************************/

/******************************************************************
 * US Solution Center
 * Sun Microsystems Computer Corporation, Mountain View, CA.
 *
 * Example Program
 *
 * Permission to use, copy, modify, and distribute this software and
 * its documentation for any purpose and without fee is hereby granted,
 * provided that this permission notice appears in all copies and in
 * supporting documentation, and that the name of Sun not be used in
 * advertising or publicity pertaining to distribution of the software
 * without specific prior written permission. Sun makes no representa-
 * tions about the suitability of this software for any purpose. It is
 * provided "as is" without any express or implied warranty.
 *
 * SUN DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FIT-
 * NESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL SUN BE LI-
 * ABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
 * ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
 * PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH
 * THE USE OR PERFORMANCE OF THIS SOFTWARE.
 ******************************************************************
 *
 * File: kbtype.c
 *
 * Owner:  Kevin Chu
 *
 * Description:
 *
 *      Use this program to tell what type of keyboard the
 *      system is using.
 *
 *      This program will get the type and layout of the keyboard.
 *      Type-4, 101A, and type-5 all have a "type" of 4, but
 *      the layout is different.
 *
 *      Type    Layout  Keyboard
 *      ---------------------------
 *      4       0       Sun US Type 4 keyboard
 *      4       1       Also Sun US Type 4 keyboard
 *      4       19      Sun 101A
 *      4       33      Type 5 US
 *      4       34      Type 5 UNIX
 *
 *      There are others.  See the file:
 *
 *              $OPENWINHOME/share/etc/keytables/keytable.map
 *
 *****************************************************************/
#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/kbd.h>
#include <sys/kbio.h>

#define DEVKBD  "/dev/kbd"

static int	KeyboardType = 0;

static int	KeyboardTypeSPARC()
   {
   int     fd;
   int     type;
   int     layout;

   /*
    * If the variable 'KeyboardType' is NOT 0, then this is not the
    * first time this function has been called and, therefore, there
    * is no need to query the system again. I already have the answer
    */

   if (KeyboardType == 0)
      {

      /*
       *  If any of the following operations fails, assume that
       *  the keyboard is type 4.
       */

      if ((fd = open(DEVKBD, O_RDONLY)) < 0) 
         {
         type = 4;
         layout = 0;
         }

      else
      if (ioctl(fd, KIOCTYPE, &type) == -1) 
         {
         type = 4;
         layout = 0;
         }

      else
      if (ioctl(fd, KIOCLAYOUT, &layout) == -1) 
         {
         type = 4;
         layout = 0;
         }

#     if DEBUG
      printf("type = %d layout = %d\n", type, layout);
#     endif

      if( fd >= 0 ) close(fd);

      /*  
       *  Check for type 5, otherwise identify as a type 4
       */

      if( type == 4 && layout == 34 )
         KeyboardType = 5;

      else
         KeyboardType = 4;
      }

   return KeyboardType;
   }
#endif /* SPARC */
static XKeyEvent cludge_event;

int IGE_map_character ( key,character )
  XKeyEvent *key;
  char *character;
{
  KeySym keysym;
  XComposeStatus status;

/***************************************************************

 one monster cludge for xforms and EX_get_keyboard_data
 they do not send the xevent so we will get it here and send it 
 in get_keyboard_data

 IF FI_MAP_CHARACTER is ever changed in xforms this change needs
 to be made                 HERE!!!!!!!!!!!!!!!!!!!!!!!
****************************************************************/

  cludge_event = *key;


   /* sml:11-07-94:                                     */
   /*  Initialize these variables for sun XGL machine */
  keysym = 0;
  status.compose_ptr = NULL;
  status.chars_matched = 0;



  /** 256 is the size of the buffer in _FI_fld_track_keyboard **/

  memset (character, 0, 256);

  XLookupString (key, character, 256, &keysym, &status);

/*fprintf( stderr, "keysym, keycode, state: %x %x %x\n", keysym, key->keycode, key->state );*/

#if defined (SUNOS) || defined (SUNOS5)
   if ( key->state & Mod3Mask ) 
   {
   switch (keysym)
     {
#    if defined (INTEL)
     case  XK_End:
     *character = XK_1;
     return(0);

     case  XK_Next:
     *character = XK_3;
     return(0);

     case  XK_KP_5:
     *character = XK_5;
     return(0);

     case  XK_Home:
     *character = XK_7;
     return(0);

     case  XK_Prior:
     *character = XK_9;
     return(0);

#    endif /* INTEL */

#if defined (SUNOS54) || defined (SUNOS55)
     case  XK_KP_Insert:
#endif
     case  XK_Insert:
     *character = XK_0;
     return(0);

     case XK_R13:
     *character = XK_1;
     return(0);

     case XK_Down:
     *character = XK_2;
     return(0);

     case XK_R15:
     *character = XK_3;
     return(0);

     case XK_Left:
     *character = XK_4;
     return(0);

     case XK_F31:
     *character = XK_5;
     return(0);

     case XK_Right:
     *character = XK_6;
     return(0);

     case XK_R7:
     *character = XK_7;
     return(0);

     case XK_Up:
     *character = XK_8;
     return(0);

     case  XK_R9:
     *character = XK_9;
     return(0);

     case XK_R4:

     /*
      *  On SPARC workstations, the keypad equals '=' on type 4 keyboards
      *  and the keypad minus '-' on type 5 keyboards are mapped to the
      *  same keysym.  In this case, I need to check the keyboard type
      *  to know how to interpret the event
      *
      *  Mike Lanier: Oct 13, 1995
      */

#    if defined (SPARC)
     if( KeyboardTypeSPARC() == 5 )
        *character = XK_minus;
     else
#    endif
        *character = XK_equal;

     return(0);

     case XK_R5:
     *character = XK_slash;
     return(0);

     case XK_R6:
     *character = XK_asterisk;
     return(0);

     case XK_KP_Subtract:
     *character = XK_minus;
     return(0);

     case  XK_KP_Add:
     *character = XK_plus;
     return(0);

     case XK_KP_Enter:
     *character = 0x0d;
     return(0);

     case 0xffff:
#    if defined (INTEL)
          if ( key->keycode == 0x6f )
          {
          *character = XK_period;
          return(0);
          }
#    else
          if ( key->keycode == 0x39 )
          {
          *character = XK_period;
          return(0);
          }
#    endif
     }
  }
#endif /* SUNOS || SUNOS5 */

  switch (keysym)
    {
      case XK_Up:
	*character = FI_UP;
	return (1);

      case XK_Down:
	*character = FI_DOWN;
	return (1);

      case XK_Left:
	*character = FI_LEFT;
	return (1);

      case XK_Right:
	*character = FI_RIGHT;
	return (1);

      case XK_Tab:
      case XK_Prior:
	*character = FI_NEXT_IN_SEQ;
	return (1);

      case XK_BackSpace:
      case XK_Next:
	*character = FI_PREV_IN_SEQ;
	return (1);

      case XK_Delete:
	*character = FI_BS_DEL;
	return (1);

      case XK_KP_0:
	*character = '0';
	return (0);

      case XK_KP_1:
	*character = '1';
	return (0);

      case XK_KP_2:
	*character = '2';
	return (0);

      case XK_KP_3:
	*character = '3';
	return (0);

      case XK_KP_4:
	*character = '4';
	return (0);

      case XK_KP_5:
	*character = '5';
	return (0);

      case XK_KP_6:
	*character = '6';
	return (0);

      case XK_KP_7:
	*character = '7';
	return (0);

      case XK_KP_8:
	*character = '8';
	return (0);

      case XK_KP_9:
	*character = '9';
	return (0);

      case XK_KP_Add:
	*character = '+';
	return (0);

      case XK_KP_Subtract:
	*character = '-';
	return (0);

      case XK_KP_Decimal:
	*character = '.';
	return (0);

      case XK_KP_Enter:
      case XK_Linefeed:
      case XK_Return:
	*character = CR;
	return (0);

      case XK_Home:
      case XK_Begin:
	*character = FI_BOL;
	return (1);

      case XK_End:
	*character = FI_EOL;
	return (1);
    }

  if ( key->state & ControlMask )
    {
      switch (keysym)
	{
	  case XK_p:
	  case XK_P:
	    *character = FI_UP;
	    break;

	  case XK_n:
	  case XK_N:
	    *character = FI_DOWN;
	    break;

	  case XK_b:
	  case XK_B:
	    *character = FI_LEFT;
	    break;

	  case XK_f:
	  case XK_F:
	    *character = FI_RIGHT;
	    break;

	  case XK_a:
	  case XK_A:
	    *character = FI_BOL;
	    break;

	  case XK_e:
	  case XK_E:
	    *character = FI_EOL;
	    break;

	  case XK_d:
	  case XK_D:
	    *character = FI_DEL;
	    break;

	  case XK_k:
	  case XK_K:
	    *character = FI_KILL_LINE;
	    break;

	  case XK_y:
	  case XK_Y:
	    *character = FI_RESTORE;
	    break;

	  case XK_c:
	  case XK_C:
	    *character = FI_UPPER_CASE;
	    break;

	  case XK_l:
	  case XK_L:
	    *character = FI_LOWER_CASE;
	    break;

	  case XK_t:
	  case XK_T:
	    *character = FI_TRANSPOSE;
	    break;

	  case XK_o:
	  case XK_O:
          return(0);
	  /*  break;  not needed with return above*/

          /* GMD 2/14/92   Implemented push mode */

          case XK_r:
          case XK_R:
            *character = FI_TOG_PUSH_MODE;
            break;

	  default:
	    *character = FI_IGNORE_CHAR;
	    break;
	}
      return (1);
    }

  if ( *character == '\0' )
    {
      *character = FI_IGNORE_CHAR;
      return (1);
    }
  else
    {
      return (0);	/** Regular Character **/
    }

} /*** IGE_map_character ( ) ***/
#else

int IGE_map_character ( character )
  char *character;
{
  /****************************************************************/
  /*** RETURN CODE: 1 = special character (e.g. cursor control)	***/
  /***		    0 = normal printable character		***/
  /****************************************************************/

  switch ( *character )
    {
      case DEL:
	*character = FI_BS_DEL;
	return( 1 );

      case TAB:				/* == CTRL_I */
	*character = FI_NEXT_IN_SEQ;
        return ( 1 );

      case BS:				/* == CTRL_H */
        *character = FI_PREV_IN_SEQ;
        return ( 1 );

      case CTRL_A:
        *character = FI_BOL;
        return ( 1 );

      case CTRL_B:
      case EX_LEFT_ARROW:	/* == CTRL_L:	*/
	*character = FI_LEFT;
	return( 1 );

      case CTRL_C:
        *character = FI_UPPER_CASE;
        return ( 1 );

      case CTRL_D:
        *character = FI_DEL;
        return ( 1 );

      case CTRL_E:
        *character = FI_EOL;
        return ( 1 );

      case CTRL_F:
      case EX_RIGHT_ARROW:	/* == CTRL_R:	*/
	*character = FI_RIGHT;
	return( 1 );

      case ESC:
      case CTRL_G:
      case CTRL_J:
      /* case CTRL_M: -- this is a RETURN, so don't eat it */
      case CTRL_O:
      case CTRL_Q:
      case CTRL_S:
      case CTRL_U:
      case CTRL_V:
      case CTRL_W:
      case CTRL_X:
      case CTRL_Z:
	*character = FI_IGNORE_CHAR;
	return( 1 );

      case CTRL_K:
        *character = FI_KILL_LINE;
        return ( 1 );

      case EX_DOWN_ARROW:	/* == CTRL_N:	*/
	*character = FI_DOWN;
	return( 1 );

      case EX_UP_ARROW:		/* == CTRL_P:	*/
	*character = FI_UP;
	return( 1 );

      case CTRL_T:
        *character = FI_TRANSPOSE;
	return( 1 );

      case CTRL_Y:
        *character = FI_RESTORE;
        return ( 1 );

   /*****************************************************************/
   /*                                                               */
   /* The following cases were already being handled in the EXNUC   */
   /* input stream handler, so I am taking them out of here.        */
   /* There location here was interfering with the input of certain */
   /* Kanji characters that have the first byte's sign bit set.     */
   /*                                                               */
   /*                       GMD 2/5/91                              */
   /*                                                               */
   /*****************************************************************/

   /*****************************************
      case KEYPAD_0:
	*character = '0';
	return( 0 );

      case KEYPAD_1:
	*character = '1';
	return( 0 );

      case KEYPAD_2:
	*character = '2';
	return( 0 );

      case KEYPAD_3:
	*character = '3';
	return( 0 );

      case KEYPAD_4:
	*character = '4';
	return( 0 );

      case KEYPAD_5:
	*character = '5';
	return( 0 );

      case KEYPAD_6:
	*character = '6';
	return( 0 );

      case KEYPAD_7:
	*character = '7';
	return( 0 );

      case KEYPAD_8:
	*character = '8';
	return( 0 );

      case KEYPAD_9:
	*character = '9';
	return( 0 );

      case KEYPAD_PLUS_MINUS:
      case KEYPAD_DIVIDE:
      case KEYPAD_MULTIPLY:
	*character = FI_IGNORE_CHAR;
	return ( 1 );

      case KEYPAD_PLUS:
	*character = '+';
	return( 0 );

      case KEYPAD_MINUS:
	*character = '-';
	return( 0 );

      case KEYPAD_COMMA:
	*character = ',';
	return( 0 );

      case KEYPAD_DOT:
	*character = '.';
	return( 0 );

      case ENTER:
	*character = CR;
	return( 0 );
      ******************************* GMD 2/5/91 **********/

      default:
	return( 0 );
    }
} /*** IGE_map_character ( ) ***/
#endif
#endif

/*********************************************************************/
/*** IGE_translate_color () is coded as per David Holmes 1/18/91   ***/
/*********************************************************************/

int IGE_translate_color ( vs, color )
  int vs;
  int color;
{
#ifdef X11
	/* This will allow the use of absolute
	   slots for gadget colors */

    if ( color >= IGE_COLOR_OFFSET )
	return ( (long)(color - IGE_COLOR_OFFSET) );
   return( (*FEI_translate_color)( vs, color ) );
#elif defined(ENV5)
  int		num_bit_planes;
  int		num_reg_bit_planes;
  int		SRmode, SRwno, SRno_area;
  static int	just_loaded_SR_vlt = 0;
  extern int	Inq_SR_active();

	/**************************************************/
	/*** This will allow the use of absolute slots	***/
	/*** for gadget colors				***/
	/**************************************************/

  if ( color >= IGE_COLOR_OFFSET )
    {
      just_loaded_SR_vlt = 0;

      return ( color - IGE_COLOR_OFFSET );
    }

	/***********************************************/
	/*** See if the form is in Save/Restore mode ***/
	/***********************************************/

  Inq_SR_active ( & SRmode, & SRwno, & SRno_area );

  if ( ! SRmode )
    {
      num_bit_planes	 = FEI_info[vs].vsi_num_planes - 1;
      num_reg_bit_planes = 0;
    }
  else
    {
      num_bit_planes	 = FEI_info[vs].vsi_SR_max_planes ;
      num_reg_bit_planes = FEI_info[vs].vsi_num_planes - 1;
    }


  if ( num_bit_planes < 4 )
    {
      just_loaded_SR_vlt = 0;

	/**********************************************************/
	/*** Do special color mapping for <= 8 different colors ***/
	/***   (Derived by trial and error process.)		***/
	/**********************************************************/

      switch ( color )
	{
	  case FI_OFF_WHITE:
	  case FI_YELLOW:
	  case FI_LT_GREY:
	  case FI_WHITE:
	  case FI_GREEN:
	  case FI_LT_YELLOW:
	    return ( 1 );	/*** bright color ***/

	  case FI_MED_GREY:
	  case FI_BLACK:
	  case FI_DK_GREY:
	  case FI_RED:
	  case FI_BLUE:
	  case FI_DK_RED:
	  case FI_DK_GREEN:
	  case FI_DK_BLUE:
	  default:
	    return ( 0 );	/*** dark color ***/
	}
    }
  else if ( num_bit_planes < 7 )
    {
      just_loaded_SR_vlt = 0;

		/**********************************/
		/*** Map all colors to slots	***/
		/***	0 - dark		***/
		/***	1 - bright		***/
		/***   13 - LT GREY		***/
		/***   14 - MED GREY		***/
		/***   15 - OFF WHITE		***/
		/**********************************/

      switch ( color )
	{
	  case FI_YELLOW:
	  case FI_GREEN:
	  case FI_LT_YELLOW:
	  case FI_RED:
	    return ( 1 );	/*** bright color ***/

	  case FI_BLACK:
	  case FI_DK_GREY:
	  case FI_BLUE:
	  case FI_DK_RED:
	  case FI_DK_GREEN:
	  case FI_DK_BLUE:
	  default:
	    return ( 0 );	/*** dark color ***/

	  case FI_LT_GREY:
	    return ( 13 );	/*** LT GREY ***/

	  case FI_MED_GREY:
	    return ( 14 );	/*** MED GREY ***/

	  case FI_WHITE:
	  case FI_OFF_WHITE:
	    return ( 15 );	/*** OFF WHITE ***/
	}
    }
  else	/*** num_bit_planes >= 7 ***/
    {
      if ( SRmode && ( num_reg_bit_planes < 7 ) )
	{
	    /*******************************************************/
	    /*** At this point, we need to Load_SR_vlt()	 ***/
	    /*** But don't do it again if it has just been done. ***/
	    /*******************************************************/

	  if ( ! just_loaded_SR_vlt )
	    {
	      Load_SR_vlt ( SRwno,  IGEFEI_fixed_vlt,
				IGEFEI_fixed_vlt_size );

	      just_loaded_SR_vlt = 1;
	    }
	}
      else
	{
	  just_loaded_SR_vlt = 0;
	}

      return ( color + 1 );
    }
#elif defined( NT )
  return color;
#else
#error Unknown GUI
#endif

} /*** IGE_translate_color() ***/


#ifndef NT
#ifdef X11
int IGE_get_keyboard_data ( character, count )
  char * character;
  int * count;
{
  char	string[1024];	/*** upped from size 16: GMD:02/05/91 ***/
  *count = 0;	/*** init this to 0, or EX_get_kbd_input() ***/
		/***   blows up			7-18-89    ***/

  EX_get_kbd_input ( &cludge_event,string, count, EX_ALL_ASCII_MODE );
  if ( *count != 1 )
  /*do not write into form buffer unless logical keyboard attached*/
  strncpy ( character, string, *count );

  return FI_SUCCESS;

} /*** IGE_get_keyboard_data ( ) ***/
#else
int IGE_get_keyboard_data ( character, count )
  char * character;
  int * count;
{
  char	string[1024];	/*** upped from size 16: GMD:02/05/91 ***/

  *count = 0;	/*** init this to 0, or EX_get_kbd_input() ***/
		/***   blows up			7-18-89    ***/

  EX_get_kbd_input ( string, count, EX_ALL_ASCII_MODE );

  strncpy ( character, string, *count );

  return FI_SUCCESS;

} /*** IGE_get_keyboard_data ( ) ***/
#endif
#endif

#argsused
#ifndef NT
int IGE_process_data ( cmd_type, cmd, form )
  int     cmd_type;
  char  * cmd;
  Form	form;
#else
int IGE_process_data ( cmd_type, cmd, form, gadget_label )
  int     cmd_type;
  char  * cmd;
  Form	form;
  int   gadget_label;
#endif
{
  int		 resp;
  long		 size;
  unsigned int	 cmd_oid;
  unsigned short cmd_os;
  long		 status;


  if ( cmd_type == FI_HELP_TOPIC_DATA )
    {
	  /*** Set the help topic stored in the command object ***/
	  /*** that the form is talking to ...		       ***/

      status = FIf_get_cmd_oid_os ( form, & cmd_oid, & cmd_os );

      if ( status )
        {
          fprintf ( stderr,
	    "IGE_ERROR:  IGE_process_data -- error FIf_get_cmd_oid_os status = %d\n", status );
          return(0);
        }

        /*** set the help topic ***/
      status = sendHelpTopic( cmd_os, cmd_oid, 0, cmd );

      if ( ! ( status & 1 ) )
        {
          fprintf ( stderr,
            "IGE_ERROR:  IGE_process_data -- error send to (%d,%d) of super_cmd.help_topic(0,'%s') status = 0x%x\n",
	    cmd_oid, cmd_os, cmd, status );
	  return(0);
        }
    }
  else
    {
      if ( cmd_type == FI_CMD_KEY_DATA )
	{
	  resp = EX_CMD_KEY;
	}
      else if ( cmd_type == FI_CMD_STRING_DATA )
	{
	  resp = CMD_STRING;
	}

      /* Chunn added for hermann 11/21/89 */

      resp |= EX_HARDWARE_GENERATED;

      size = strlen ( cmd ) + 1;
      EXputq2 ( &status, FRONT, &resp, &size, cmd, 0 );
    }
return (1);
} /***  IGE_process_data ( ) ***/

#argsused
int IGEFEI_DUMMY_calc_text ( font_id, text, length, height, width,
					line_spacing, font_type )
  int	 font_id;
  char * text;
  int	 length;
  int  * height;
  int  * width;
  int  * line_spacing;
  int	 font_type;
{
  return ( FI_SUCCESS );
}


int IGE_calc_text ( font_id, text, length, height, width,
					 line_spacing, font_type )
  int	  font_id;
  char  * text;
  int	  length;
  int   * height;
  int   * width;
  int   * line_spacing;
  int	  font_type;
{
  int	status;
  status = 1;

  if ( font_type == FI_FS_7_OR_16_BIT_FONT_TYPE )
    {
      BmapInfo	font_info;
      double	w, total_w = 0;
#ifndef NT
      double	h;
#endif
      int	ii, index;
      unsigned  char	ch_ptr[2];

      for ( ii = 0, index = 0; ii < length; ii++ )
	{
	  if( ! ( text[index] & 0x80 ) )	/** 8 bit **/
	    {
#ifndef NT
	       status = FSGetTextVect ( font_id, &(text[index++]), 1,
					(double)0, (double)0, &w, &h );
#else
               status = 1;
               fprintf( stderr, "FSGetTextVect NOT called\n" );
#endif
	    }
	  else 	/** 16 bit **/
	    {
	      /*** Sixteen bit mode requires	***/
	      /*** a byte swap before sending 	***/
	      /*** the character to fontserver.	***/

#if defined (LITTLE_ENDIAN) && !defined (X11)
	      ch_ptr[0] = text[index+1];
	      ch_ptr[1] = text[index];
#else
	      ch_ptr[1] = text[index+1];
	      ch_ptr[0] = text[index];
#endif

#ifndef NT
	      status = FSGetTextVect ( kanji_font_id, ch_ptr, 1,
				(double)0, (double)0, &w, &h );
#else
              status = 1;
              fprintf( stderr, "FSGetTextVect NOT called\n" );
#endif
	      index += 2;
            }

	  total_w += w;
          if ( status )
            {
	      fprintf ( stderr,
		"IGE_ERROR: FSGetTextVect -- error code %d\n",status);
            }
	}

      *width = (int)(total_w + 0.5);

#ifndef NT
      if (!(text[0] & 0x80 ))
         status = FSGetBmapInfo ( font_id, &font_info );
      else
         status = FSGetBmapInfo ( kanji_font_id, &font_info );
#else
      status = 1;
      fprintf( stderr, "FSGetBmapInfo NOT called\n" );
#endif

      if ( status )
	{
	  fprintf ( stderr,
		"IGE_ERROR: FSGetBmapInfo -- error code %d\n", status );
	}

/*
      *height = (int)( font_info.bodySize - font_info.descent ) + 3;
*/
      *line_spacing = (int)(font_info.maxExtent - font_info.minExtent);
      *height = *line_spacing;
    }
  else if ( font_type == FI_FS_8_BIT_FONT_TYPE )
    {
      BmapInfo	font_info;
      double	w;
#ifndef NT
      double	h;
#endif

#ifndef NT
      status = FSGetTextVect ( font_id, text, length, 0.0, 0.0,
							 &w, &h );
#else
      status = 1;
      fprintf( stderr, "FSGetTextVect NOT called\n" );
#endif

      if ( status )
	{
	  fprintf ( stderr,
		"IGE_ERROR: FSGetTextVect -- error code %d\n",status);
	}

      *width = (int)(w + 0.5);

#ifndef NT
      FSGetBmapInfo ( font_id, &font_info );
#endif

/*
      *height = (int)( font_info.bodySize - font_info.descent ) + 3;
*/
      *line_spacing = (int)(font_info.maxExtent - font_info.minExtent);
      *height = *line_spacing;
    }
  else
    {
#ifdef ENV5
      status = Inq_string_width ( font_id, text, length, width );

      if ( status )
	{
	  fprintf ( stderr,
	     "IGE_ERROR: Inq_string_width -- error code %d\n", status );
	}

      status = Inq_font ( font_id, height, &status, &status );
      if ( status )
	{
	  fprintf ( stderr,
		"IGE_ERROR: Inq_font -- error code %d\n",status );
	}

      *line_spacing = *height;
#elif defined(X11)
printf("IGE_calc_text: can only handle font_type: FI_FS_8_BIT_FONT_TYPE under X\n");
exit(1);
#elif defined( NT )
printf("IGE_calc_text: can only handle font_type: FI_FS_8_BIT_FONT_TYPE under NT\n");
#else
#error Unknown GUI
#endif
    }

  return ( status );

} /*** IGE_calc_text ( ) ***/


#define sbitset(c) 	( ( (c) & 128 ) ? 1 : 0 )

#ifdef ENV5
/**********************************************************************/
/* This routine which byte a character starts in the string given the */
/* character's position in the string.  The string can have either    */
/* 16 or 7 bit characters mixed together.                             */
/**********************************************************************/

static int Locate_16char_start_byte( cpos, string )
  int	 cpos;		/** INPUT - Character position		**/
  char	*string;	/** INPUT - NULL terminated string	**/
{
  int	index = 0, ii;

  if ( cpos < 1 )
    {
      return (0);		/** assumed zero **/
    }

  for ( ii = 0 ; ii < cpos ; ii++ )
    {
      if ( !string[index] )
	{
	  return (-1);
	}

      if ( !sbitset(string[index]) )
	{
	  index++;
	}
      else
	{
	  index += 2;
	}
    }

  return (index);
}
#endif
// int IGEFEI_SSDrawText(window,font,fontAUX,text,length,x,y,nx,ny,mode)
/*********************************************************************

Doc:

Abstract: Draw text ( determinied by length ) with mixed 7 and
          8 or 16 bit characters.

Algorithm: When there is no aux. font, call FSDrawText, otherwise
           draw character by character.

Return Status: Returns whatever the Font Server sends back.

Bugs:

Notes: o Could be fixed to cut the strings inot sub-strings so
         kerning pairs are displayed.

Examples:

History: 16-MAR-89 MDS Genesis.

	 02-JAN-91 JAJ Copied over from SS.c from I/Forms' "fb";
		       Modified it.

*******************************************************************/
#if 0
  int		window;	  /* Environ V window number in which to draw */
  FontId	font;	  /* Font id of the 7 bit font                */
  FontId	fontAUX;  /* Font id of the 8 or 16 bit font          */
  unsigned char	*text;	  /* Text to draw 			      */
  int		length;	  /* Byte length of text		      */
  double	x,y;	  /* x,y position from which to start drawing */
  double	*nx,*ny;  /* Returns the final x,y position	      */
  int		mode;	
		 /* FI_FS_7_OR_16_BIT_FONT_TYPE - mixed 7 and 16 bits */
#endif
int IGEFEI_SSDrawText(
  int		window,
  FontId	font,
  FontId	fontAUX,
  unsigned char	*text,
  int		length,
  double	x,
  double        y,
  double       *nx,
  double       *ny,
  int		mode)
{
  int		sts;	  /* Return status		*/
  int		pos;      /* Index into string          */
  unsigned short ch;      /* Character id		*/
  unsigned char	*ch_ptr;  /* Pointer to characters	*/
#ifdef X11
  int            lscreen_type;
  WLuint16       lscreen;
  WLuint32       ctx_num;
  struct WLnative_info native_info;
#endif

#ifndef NT
  double        dummy;
#endif

   sts = 1;   /*bad status*/

#ifdef X11
   sts = WLget_active_screen ( &lscreen, &lscreen_type );
   if (sts != WL_SUCCESS) 
   {
   }

   sts = CMget_active_context ( lscreen, &ctx_num );
   if (sts != CM_SUCCESS) 
   {
   }

   sts = WLget_native_info ( window, ctx_num, &native_info );
   if (sts != WL_SUCCESS) 
   {
   }
#endif

   if ( fontAUX == (FontId)NULL )
   {
      /*** If there is no aux. font, use normal Font Server call ***/
#ifdef X11
      sts = FSXDrawText(native_info.display, native_info.screen,
                        native_info.base_win, native_info.gc,
                        font, text, length, x, y, nx, ny);
#elif defined(ENV5)
      sts = FSDrawText(window,font,text,length,x,y,nx,ny);
#elif defined( NT )
      sts = 1;
#else
#error Unknown GUI
#endif
      return(sts);
   }
   else
   {
      pos = 0;
      while ( pos < length )
      {
         /*** Draw the specified length ***/

         if ( sbitset(text[pos]) )
         {
            /*** Sign bit is set ***/

            if ( mode == FI_FS_7_OR_16_BIT_FONT_TYPE )
            {
               /*** Byte swap for sixteen bit font ***/

               ch_ptr = (unsigned char *) &ch;
               ch_ptr[0] = text[pos+1];
               ch_ptr[1] = text[pos];
#ifdef X11
               sts = FSXDrawChar ( native_info.display, native_info.screen, 
                                   native_info.base_win, native_info.gc,
                                   fontAUX, (CharId)ch, x, y + 5.0,
                                   &x, &dummy);
#elif defined(ENV5)
               sts = FSDrawChar ( window, fontAUX, ch, x, y + 5.0,
                                  &x, &dummy);
#elif defined( NT )
               sts = 1;
#else
#error Unknown GUI
#endif
               if ( sts != 0 )
               {
                  return(sts);
               }
               pos+=2;
            }
            else
            {
               /** eight bit font **/
#ifdef X11
               sts = FSXDrawChar ( native_info.display, native_info.screen,
                                   native_info.base_win, native_info.gc,
                                   fontAUX, (CharId)text[pos],x,y,&x,&y);
#elif defined(ENV5)
               sts = FSDrawChar(window,fontAUX, text[pos],x,y,&x,&y);
#elif defined( NT )
               sts = 1;
#else
#error Unknown GUI
#endif
               if ( sts != 0 )
               {
                  return(sts);
               }
               pos+=1;
            }
         }
         else
         {
            /** Seven bit character **/
#ifdef X11
            sts = FSXDrawChar ( native_info.display, native_info.screen,
                                native_info.base_win, native_info.gc,
                                font, (CharId)text[pos],x,y,&x,&y);
#elif defined(ENV5)
            sts = FSDrawChar(window,font, text[pos],x,y,&x,&y);
#elif defined( NT )
            sts = 1;
#else
#error Unknown GUI
#endif
            if ( sts != 0 )
            {
               return(sts);
            }
            pos+=1;
         }
      }
      *nx=x;
      *ny=y;
      return(sts);
   }
}


/* This method draws the font */

#ifdef ENV5
int IGE_draw_text ( window, font_id,  text, length, xpos, ypos,
				font_height, nx, ny, font_type )
  int	  window;
  int	  font_id;
  char  * text;
  int	  length;
  int     xpos;
  int     ypos;
  int     font_height;
  int   * nx;
  int   * ny;
  int	  font_type;
{
  int	status;
  status = 1;/*bad return*/
  if ( font_type == FI_FS_7_OR_16_BIT_FONT_TYPE )
    {
      double next_x;
      double next_y;

	/*** 12/07/89 Calculate the byte length of string ***/
      length = Locate_16char_start_byte( length, text );

      if( length < 0 )
        length = 0;

      if (length)
	{
          status = IGEFEI_SSDrawText ( window, font_id,
			kanji_font_id, text,
			length,
			(double)xpos,
			(double)(ypos + font_height - (font_height / 4)),
			&next_x, &next_y,
			FI_FS_7_OR_16_BIT_FONT_TYPE );
	  if ( status )
            {
 	       fprintf ( stderr,
		"IGE_ERROR: SSdrawText -- error code %d\n",status);
            }
	  *nx = next_x;
          *ny = next_y;
        }
      else
	{
          *nx = xpos;
          *ny = ypos;
	}
    }
  else if ( font_type == FI_FS_8_BIT_FONT_TYPE )
    {
      double next_x;
      double next_y;

      status = FSDrawText ( window, font_id, text, length,
		(double)xpos,
		(double)(ypos + font_height - (font_height / 4)),
	        &next_x, &next_y );

      if ( status )
	{
	  fprintf ( stderr,
		"IGE_ERROR: FSdrawText -- error code %d\n",status);
	}

      *nx = next_x;
      *ny = next_y;
    }
  else
    {
      status = drawsymbols ( window, font_id, xpos, ypos,
						 text, length );

      if ( status )
	{
	  fprintf ( stderr,
		"IGE_ERROR: drawsymbols -- error code %d\n", status );
	}
    }

  return ( status );

} /***  IGE_draw_text ( ) ***/
#endif

#ifdef ENV5
/* This function sets window attributes */

int IGE_set_window_attr ( window )
  int    window;
{
	/* Set up button mode for buttons 0 and 2 */

  Set_button_mode ( window, 0, 0 );
  Set_button_mode ( window, 2, 0 );

	/* Notify journaling of new window created */

  JNL_record_new_window ( window );

  return ( FI_SUCCESS );
}
#endif

#argsused 
int IGEFEI_DUMMY_find_font_id ( fontname, bodysize, font_id,
		       actual_bodysize, gadget_type, font_type )
  char 	* fontname;		/* INPUT & OUTPUT */
  float	  bodysize;		/* INPUT	  */
  int   * font_id;		/* OUTPUT	  */
  int	* actual_bodysize;	/* OUTPUT	  */
  int  	  gadget_type;		/* INPUT	  */
  int	* font_type;		/* OUTPUT	  */
{
  return ( FI_SUCCESS );
}




int IGEFEI_load_FSfont ( fontname, bodysize, actual_bodysize, font_id )
  char * fontname;
  int    bodysize;
  int  * actual_bodysize;
  int  * font_id;
{

  int	status;
  FontSpec fontspec;
  char typeface[50];
#ifndef NT
  int temp_font_id;
#endif
  char charmap[100];

  strcpy (typeface, fontname);
  strcat (typeface, ".tf");
  strcpy (charmap, "dec");

  fontspec.typeface = typeface;
  fontspec.bodySize  = (double)bodysize;
  fontspec.resFactor = 1.0;
  fontspec.aspect    = 1.0;
  fontspec.rotation  = 0.0;
  fontspec.slant     = 0.0;
  fontspec.charMap   = charmap;
  fontspec.flags     = FS_DEMAND | FS_NO_KERN | FS_INT_WIDTHS;

#ifndef NT
  status = FSNewFont( &fontspec, NULL, &temp_font_id );
  *font_id = temp_font_id;
#else
  status = 1;
  fprintf( stderr, "FSNewFont NOT called\n" );
#endif

  if ( status )
  {
     fprintf(stderr,
	   "IGEFEI_ERROR: FSNewFont -- error code %d\n",status);
  }

  if ( ! status )
    {
      *actual_bodysize = bodysize;
      return ( FI_SUCCESS );
    }
  else
    {
      *font_id 	       = -1;
      *actual_bodysize = -1;

      return ( FI_LOAD_FONT_ERROR );
    }

} /*** int IGEFEI_load_FSfont ( ) ***/


#argsused
int font_available ( fontname, bodysize, font_id, font_type )
  char * fontname;
  int    bodysize;
  int  * font_id;
  int  * font_type;
{
  int	ii;

  for ( ii = 0; ii < next_font; ii++ )
    {
	if ( ( strcmp ( fontname, fonts[ii].fontname ) == 0 ) &&
	     ( bodysize == fonts[ii].bodysize ) )
	{
	  *font_id = fonts[ii].font_id;
          *font_type = fonts[ii].font_type;
	  return ( TRUE );
	}
    }	

  return ( FALSE );
}

#argsused
int IGE_find_font_id ( fontname, bodysize, font_id,
		       actual_bodysize, gadget_type, font_type )
  char 	* fontname;		/* INPUT & OUTPUT */
  float	  bodysize;		/* INPUT	  */
  int   * font_id;		/* OUTPUT	  */
  int	* actual_bodysize;	/* OUTPUT	  */
  int  	  gadget_type;		/* INPUT	  */
  int	* font_type;		/* OUTPUT	  */
{
  int	raster_status;
  int	FS_status;
  FS_status = 1;/*error*/
        /**********************************************************/
        /***  Check to see if the font has already been loaded  ***/
        /**********************************************************/

        if (font_available (fontname, (int)bodysize, font_id, font_type))
        {
           *actual_bodysize = (int) bodysize;
           return (FI_SUCCESS);
        }

	/******************************************/
        /*** If a 16 bit font is in use,        ***/
	/*** try loading the font in as a 	***/
	/*** dynamic fontserver font first	***/
	/******************************************/

  if ( load_fs_fonts )
  {
     FS_status = IGEFEI_load_FSfont ( fontname, (int) bodysize,
  				      actual_bodysize, font_id );

     if ( FS_status == FI_SUCCESS )
     {
        if ( kanji_font_id != 0 )
	{
         *font_type = FI_FS_7_OR_16_BIT_FONT_TYPE;
	}
        else
	{
         *font_type = FI_FS_8_BIT_FONT_TYPE;
	}

        strcpy ( fonts[next_font].fontname, fontname );		
        fonts[next_font].bodysize = (int)bodysize;
        fonts[next_font].font_id = *font_id;
        fonts[next_font].font_type = *font_type;
        next_font++;

        if ( next_font >= font_array_size )
        {
	  /* Make the font array larger */

          font_array_size += 10;
		
          fonts = ( struct font_st * ) 
	      realloc ( fonts, sizeof ( struct font_st ) * font_array_size );
        }
        return ( FI_SUCCESS );
     }
  }

  /************************************************/
  /***  Try loading the font as a raster font   ***/
  /************************************************/

#ifdef ENV5
  raster_status = FI_load_font ( fontname, (int)bodysize,
				actual_bodysize, font_id );
#elif defined(X11)
  raster_status = FI_load_font ( fontname, (int)bodysize,
				actual_bodysize, (Font *)font_id, font_type );
#elif defined( NT )
  raster_status = ! FI_SUCCESS;
#else
#error Unknown GUI
#endif
  if ( raster_status == FI_SUCCESS )
    {
      *font_type = FI_RASTER_8_BIT_FONT_TYPE;

      strcpy ( fonts[next_font].fontname, fontname );		
      fonts[next_font].bodysize = (int)bodysize;
      fonts[next_font].font_id = *font_id;
      fonts[next_font].font_type = FI_RASTER_8_BIT_FONT_TYPE;
      next_font++;

      if ( next_font >= font_array_size )
      {
	 /* Make the font array larger */

         font_array_size += 10;
		
         fonts = ( struct font_st * ) 
	      realloc ( fonts,
			sizeof (struct font_st) * font_array_size );
      }
      return ( FI_SUCCESS );
    }

	/******************************************/
        /*** If 16 bit font is not being used,  ***/
	/*** try loading the font as a dynamic 	***/
	/*** fontserver font if a raster font	***/
        /*** cannot be found.                   ***/
	/******************************************/

  if ( load_fs_fonts == 0 )
  {
     FS_status = IGEFEI_load_FSfont ( fontname, (int) bodysize,
  				      actual_bodysize, font_id );

     if ( FS_status == FI_SUCCESS )
     {
        if ( kanji_font_id != 0 )
	{
         *font_type = FI_FS_7_OR_16_BIT_FONT_TYPE;
	}
        else
	{
         *font_type = FI_FS_8_BIT_FONT_TYPE;
	}

        strcpy ( fonts[next_font].fontname, fontname );		
        fonts[next_font].bodysize = (int)bodysize;
        fonts[next_font].font_id = *font_id;
        fonts[next_font].font_type = *font_type;
        next_font++;

        if ( next_font >= font_array_size )
        {
	  /* Make the font array larger */

          font_array_size += 10;
		
          fonts = ( struct font_st * ) 
	      realloc ( fonts, sizeof ( struct font_st ) * font_array_size );
        }
        return ( FI_SUCCESS );
     }
  }

  /********************************************************************/
  fprintf(stderr, "IGE_ERROR: FI_load_font ( \"%s\", %d ): status %d\n",
   	   fontname,(int)bodysize, raster_status );

  fprintf(stderr, "IGE_ERROR: IGEFEI_load_FSfont ( \"%s\", %d ): status %d\n",
   	   fontname,(int)bodysize, FS_status );

  fprintf(stderr,
   "IGE_STAT: Replacing style '%s', size %d with 'mono821b', size 15\n",
	fontname,(int)bodysize );
  /********************************************************************/


	/**************************************************/
	/*** Give them a default font "mono821b"	***/
	/*** which should always be there...		***/
	/**************************************************/
#ifdef ENV5
  raster_status = FI_load_font ( "mono821b", 15, actual_bodysize,
							 font_id );
#elif defined(X11)
  raster_status = FI_load_font ( "mono821b", 15, actual_bodysize,
							 (Font *)font_id,font_type );
#elif defined( NT )
  raster_status = 1;
#else
#error Unknown GUI
#endif
  *font_type = FI_RASTER_8_BIT_FONT_TYPE;

  /*********************************************************************
  if ( raster_status )
    {
      fprintf(stderr,
	"IGE_ERROR: FI_load_font (\"mono821b\", 18 ): status %d\n",
	status );
    }
  *********************************************************************/

  return ( FI_SUCCESS );
}



int FEI_set_form_icon_path ( )
{
  int	ii;
  int	jj;
  int	kk;

  char path_name[256];
  char search_paths[10000];

  EX_inq_language ( IGE_language );


    /***************************************************************/
    /* This will build all the paths that forms will be found in   */
    /***************************************************************/

  for ( search_paths[0] = '\0', jj = 0, ii = 1; ii ; jj++ )
    {
      if ( ii = ex$get_path ( index = jj, path = path_name,
			         len = sizeof(path_name) ) )
	{
	  strcat ( search_paths, path_name );
	  strcat ( search_paths, "config/" );
	  strcat ( search_paths, IGE_language );
	  strcat ( search_paths, "/forms:" );
	  strcat ( search_paths, path_name );
	  strcat ( search_paths, "config/" );
	  strcat ( search_paths, IGE_language );
	  strcat ( search_paths, "/menus:" );
	}
    }

  FI_set_form_path ( search_paths );


    /***************************************************************/
    /* This will build all the paths that symbols will be found in */
    /***************************************************************/

  for ( search_paths[0] = '\0', jj = 0, ii = 1; ii ; jj++ )
    {
      if ( ii = ex$get_path ( index = jj, path = path_name,
			         len = sizeof(path_name) ) )
	{
	  strcat ( search_paths, path_name );
	  strcat ( search_paths, "config/" );
	  strcat ( search_paths, IGE_language );
	  strcat ( search_paths, "/icons:" );
        }
    }

  FI_set_symbol_path ( search_paths );



    /***************************************************************/
    /* This will build all the paths that FSfonts will be found in */
    /***************************************************************/

  for ( jj = 0, ii = 1; ii ; jj++ )
    {
      if ( ii = ex$get_path ( index = jj, path = path_name,
			         len = sizeof(path_name) ) )
	{
	  strcpy ( search_paths, path_name );
	  strcat ( search_paths, "config/" );
	  strcat ( search_paths, IGE_language );
	  strcat ( search_paths, "/fontfile" );
        }

		/**************************************************/
		/*** see if there's enough room to hold new	***/
		/*** directory entry				***/
		/**************************************************/

      if ( IGEFEI_FSfont_path_index >=  IGEFEI_FSfont_path_size  )
        {
	  if ( IGEFEI_FSfont_path_size  )
	    {
	      IGEFEI_FSfont_path = (char **) realloc (
				IGEFEI_FSfont_path ,
			( IGEFEI_FSfont_path_size  + DIR_ALLOC_SIZE )
						* sizeof (char **) );
	    }
	  else
	    {
	      IGEFEI_FSfont_path = (char **) calloc ( DIR_ALLOC_SIZE,
						sizeof ( char** ) );
	    }

          if ( ! IGEFEI_FSfont_path  )
	    {
	      return ( FI_NO_MEMORY );
	    }

		/****************************************************/
		/*** allocate space for the new directory entries ***/
		/****************************************************/

          for ( kk = IGEFEI_FSfont_path_size ;
		kk < IGEFEI_FSfont_path_size + DIR_ALLOC_SIZE ; kk ++ )
	    {
	      IGEFEI_FSfont_path[kk] = calloc ( MAXPATHLEN + 1,
						 sizeof ( char ) );

              if ( ! IGEFEI_FSfont_path[kk] )
	        {
	          return ( FI_NO_MEMORY );
	        }
	    }

	  IGEFEI_FSfont_path_size   += DIR_ALLOC_SIZE ;
	}

		/**********************************************/
		/*** store temp_dir as a new directory name ***/
		/**********************************************/

      strcpy ( IGEFEI_FSfont_path [IGEFEI_FSfont_path_index],
						search_paths );

      IGEFEI_FSfont_path_index ++;
    }


  return ( FI_SUCCESS );
}

#ifndef NT
#argsused
int IGEFEI_DUMMY_find_symbol_path_and_id ( path, symbol_name, symbol_id )
  char * path;
  char * symbol_name;
  int  * symbol_id;
{
  return ( FI_SUCCESS );
}
#endif


#ifndef NT
#ifdef ENV5
int IGEFEI_Inq_displayed_vs ( vs )
  int * vs;
{
        /*** check to see that we're not on a window-less machine ***/
        /***   before calling Inq_displayed_vs(), because that    ***/
        /***   call will hang up on a window-less machine         ***/
        /***                                  -- JAJ:04/25/90     ***/
    if ( ! IGE_running_on_server )
      {
        Inq_displayed_vs ( vs );
      }
    else  /*** we're running on a window-less machine ***/
      {
        * vs = 0;
      }

  return ( 0 );

}  /*** IGEFEI_Inq_displayed_vs () ***/
#endif
#endif

void IGE_get_menu_scaling_factors(double *p_double_x,double *p_double_y)
{
*p_double_x = double_x;
*p_double_y = double_y;
}



int FEI_enter ()
{
  int	 ii, status;
  int    sixteen_bit_active;
  char   sixteen_bit_typeface[256];
  char   sixteen_bit_charmap[256];
  double sixteen_bit_bodysize;
  char   *xscale;
  char   *yscale;
  char   *scaling_on;
  int xdits;
  int ydits;

#ifdef X11
  WLuint16  lscreen;
  int       lscreen_type;
  WLuint32  ctx_num;
  struct WLnative_info  wl_native_info;
#endif

 
  sixteen_bit_bodysize = 0.;

  /*************************/
  /*                       */
  /*   Set up font table   */
  /*                       */
  /*************************/

  font_array_size = 20;
  fonts = (struct font_st *)
	          calloc (font_array_size, sizeof (struct font_st));
  next_font = 0;

  EX_inq_language ( IGE_language );

	/*************************************************************/
	/*** Do this ( before FI_enter ) to avoid hanging the	   ***/
	/***   process on a window-less  machine -- JAJ:04/25/90   ***/
	/*************************************************************/
#ifdef ENV5
  if ( ( ( Inq_screen_info ( FEI_info ) ) == -1 ) || (ex$is_batch()) )
    {
    	/*** running on a server  -- JAJ:05/04/90 ***/

      IGE_running_on_server = 1;

      FI_set_quiet_mode_on ();

      FI_modify_env ( FI_FIND_SYMBOL_PATH_AND_ID,
				IGEFEI_DUMMY_find_symbol_path_and_id );

      FI_modify_graphic_env ( FI_INQ_DISPLAYED_VS,
				IGEFEI_Inq_displayed_vs  );
    }


	/**********************************/
	/*** Load in a fixed vlt	***/
	/**********************************/

  Get_fixed_vlt ( & IGEFEI_fixed_vlt, & IGEFEI_fixed_vlt_size );


  /*******************************************************************
  for ( ii = 0; ii < IGEFEI_fixed_vlt_size ; ii++ )
    {
      fprintf ( stderr,
	"IGEFEI_fixed_vlt[%d].v_slot = %hd : %8hd, %8hd, %8hd\n",
	ii, IGEFEI_fixed_vlt[ii].v_slot, IGEFEI_fixed_vlt[ii].v_red,
	IGEFEI_fixed_vlt[ii].v_green, IGEFEI_fixed_vlt[ii].v_blue );
    }
  *******************************************************************/


	/**************************************/
	/*** Initialize the forms subsystem ***/
	/**************************************/

  status = FI_enter();
  if (!getenv("EX_USE_NORMAL_BEZEL"))
     FI_use_thin_bezel();
  if ( status != FI_SUCCESS ) return ( status );

#elif defined(X11)

  status = WLget_active_screen ( &lscreen, &lscreen_type );
  if (status != WL_SUCCESS) {
     return (OM_E_ERROR);
  }

  status = CMget_exnuc_forms_context ( lscreen, &ctx_num );
  if (status != CM_SUCCESS) {
     return (OM_E_ERROR);
  }

  status = WLget_native_info_from_context (lscreen, ctx_num, &wl_native_info);
  if (status != WL_SUCCESS) {
     return (OM_E_ERROR);
  }

  status = FI_enter(wl_native_info.display, wl_native_info.colormap, 15);
  if (!getenv("EX_USE_NORMAL_BEZEL"))
     FI_use_thin_bezel();
  if ( status != FI_SUCCESS ) return ( status );

#elif defined( NT )
  printf( "add shamrock call to FI_enter\n" );
  status = 1;
#else
#error Unknown GUI
#endif
  if ( status != FI_SUCCESS )
    return ( status );

  double_x = 1.0;
  double_y = 1.0;
  if (( scaling_on = getenv("EX_ENABLE_SCALE")) && (atoi(scaling_on)))
  {
  ige$inq_term_info (
                      x_extent = &xdits,
                      y_extent = &ydits);

   /*scaling is enabled figure out scale*/
   if (xscale = getenv("FORMS_XSCALE"))
   {
   /*if env variable set call forms with new xscale factors*/
    sscanf(xscale,"%lf",&double_x);
   }
   else
   {
#ifdef CLIX
   double_x = xdits;
   double_x = double_x/1184.;
#endif
   }

   if (yscale = getenv("FORMS_YSCALE"))
   {
   sscanf(yscale,"%lf",&double_y);
   }
   else
   {
#ifdef CLIX
   double_y = ydits;
   double_y = double_y/884.;
#endif
   }
  }
 FI_set_auto_scaling_factors(double_x,double_y);

	/*******************************************************/
	/*** Build all the paths that forms will be found in ***/
	/*******************************************************/

  status = FEI_set_form_icon_path ( );
  if ( status != FI_SUCCESS )
    return ( status );


	/*************************************/
	/*** Initialize the menu subsystem ***/
	/*************************************/

  MS_enter();


	/**********************************/
	/*** Set up the record function ***/
	/**********************************/

  FI_set_record_notification_routine ( IGE_record_routine );


	/************************************/
	/*** Re-map environment functions ***/
	/************************************/
  FI_modify_env ( FI_PROCESS_DATA, 	IGE_process_data );
#ifdef X11
  FI_get_env    ( FI_TRANSLATE_COLOR,		&FEI_translate_color );
  FI_set_graphic_env (FI_NEXT_EVENT,JNL_XNextEvent);
  FI_set_graphic_env (FI_CREATE_WINDOW,JNL_XCreateWindow); 
  FI_set_graphic_env (FI_MASK_EVENT,JNL_XMaskEvent);
  FI_set_graphic_env (FI_CHECK_MASK_EVENT,JNL_XCheckMaskEvent);
  FI_set_graphic_env (FI_CHECK_WINDOW_EVENT,JNL_XCheckWindowEvent);
  FI_set_graphic_env (FI_CHECK_IF_EVENT,JNL_XCheckIfEvent);
  FI_set_graphic_env (FI_IF_EVENT,JNL_XIfEvent);
  FI_set_graphic_env (FI_PUT_BACK_EVENT,JNL_XPutBackEvent);
  FI_set_graphic_env (FI_GRAB_POINTER,JNL_XGrabPointer);
  FI_set_graphic_env (FI_UNGRAB_POINTER,JNL_XUngrabPointer);
  FI_set_graphic_env (FI_MAP_RAISED,JNL_XMapRaised); 
  FI_set_graphic_env (FI_MAP_WINDOW,JNL_XMapWindow); 
  FI_set_graphic_env (FI_UNMAP_WINDOW,JNL_XUnmapWindow); 
  FI_set_graphic_env (FI_WITHDRAW_WINDOW,JNL_XWithdrawWindow); 
  FI_modify_env ( FI_MAP_CHARACTER, 	IGE_map_character );
  FI_set_graphic_env (FI_WINDOW_EVENT,JNL_XWindowEvent);
  if (EX_logkbd)
   {
    /*override only if we have a logical keyboard*/

    FI_modify_env ( FI_GET_KEYBOARD_DATA,	IGE_get_keyboard_data );
   }

#elif defined(ENV5)



  FI_modify_env ( FI_MAP_CHARACTER, 	IGE_map_character );
  FI_modify_env ( FI_SET_WINDOW_ATTR,	IGE_set_window_attr );
  FI_modify_env ( FI_DRAW_TEXT,		IGE_draw_text );
  FI_modify_env ( FI_ACTIVATE_HELP,   	IGEfei_activate_help );
  FI_modify_env ( FI_GET_KEYBOARD_DATA,	IGE_get_keyboard_data );

  if ( ! IGE_running_on_server )
    {
      FI_modify_env ( FI_FIND_FONT_ID,	IGE_find_font_id );
      FI_modify_env ( FI_CALC_TEXT,	IGE_calc_text );
    }
  else
    {
      FI_modify_env ( FI_FIND_FONT_ID,	IGEFEI_DUMMY_find_font_id );
      FI_modify_env ( FI_CALC_TEXT,	IGEFEI_DUMMY_calc_text );
    }


	/**************************************/
	/*** Re-map the Environ V functions ***/
	/**************************************/



  FI_modify_graphic_env ( FI_DELETE_WIN,	IGE_delete_win  );
  FI_modify_graphic_env ( FI_GET_BUTTON_DATA,   EX_get_button_data  );
  FI_modify_graphic_env ( FI_GET_COLLAPSE_DATA, JNL_get_collapse_data );
  FI_modify_graphic_env ( FI_GET_DELETE_DATA,   JNL_get_delete_data  );
  FI_modify_graphic_env ( FI_GET_REFRESH_AREA_DATA,
						IGE_get_refresh_area_data );
  FI_modify_graphic_env ( FI_GET_WIN_USER_ICON_DATA,
						JNL_get_win_user_icon_data );
  FI_modify_graphic_env ( FI_INQ_BUTTON_DATA,   IGE_inq_button_data  );
  FI_modify_graphic_env ( FI_INQ_COLLAPSE_DATA, JNL_inq_collapse_data  );
  FI_modify_graphic_env ( FI_INQ_DELETE_DATA,   JNL_inq_delete_data  );
  FI_modify_graphic_env ( FI_INQ_EVENTS, 	JNL_inq_events  );
  FI_modify_graphic_env ( FI_INQ_WIN_USER_ICON_DATA,
						JNL_inq_win_user_icon_data );
  FI_modify_graphic_env ( FI_WAIT_FOR_NEXT, 	JNL_wait_for_next );
  FI_modify_graphic_env ( FI_INQ_REFRESH_AREA_DATA,
						JNL_inq_refresh_area_data );
#elif defined( NT )
  FI_modify_env ( FI_ACTIVATE_HELP,   	IGEfei_activate_help );
#else
#error Unknown GUI
#endif
  FI_modify_env ( FI_TRANSLATE_COLOR, 	IGE_translate_color );
	/**********************************************************/
	/*** If the language is 16 bit then load the kanji font ***/
	/**********************************************************/

  load_fs_fonts = 0;   /* Assume there is no 16 bit font until proven */
                       /* otherwise.                                  */
  {
    IGRlong		  msg;
    struct EX_locale_var  var_list;
    IGRint		  number_entries;
    struct EX_fonts	 *temp_fonts;
    extern int		  EX_batch_mode;
    extern int		  EX_Gf_defmsgfont;

    sixteen_bit_active = 0;

    if ( !EX_batch_mode )
    {
      if ( !EX_Gf_defmsgfont )
      {
         /* get om param for fast symbol file or FS font */

         var_list.var = EX_number_alias;
         var_list.var_ptr = (struct EX_fonts *) &number_entries;

         ex$inq_locale (msg = &msg,
                     var = &var_list,
                     identifier = "default_message");

         temp_fonts = (struct EX_fonts *)
                 malloc ((sizeof (struct EX_fonts) * number_entries));

         var_list.var = EX_alias_fonts;
         var_list.var_ptr = (struct EX_fonts *) temp_fonts;

         ex$inq_locale (msg = &msg,
                   var = &var_list,
                   flags = EX_Logical_Name | EX_Message,
                   identifier = "default_message");

         for (ii = 0; ii < number_entries; ii++)
         {
           if (temp_fonts[ii].properties & EX_Sixteen_Bit)
             {
               sixteen_bit_active = 1;
               strcpy (sixteen_bit_typeface, temp_fonts[ii].tf);
               strcpy (sixteen_bit_charmap,  temp_fonts[ii].cm);
               sixteen_bit_bodysize = (double)temp_fonts[ii].body_size;
               load_fs_fonts = 1;
             }
         }
      }
    }
  }

  if ( sixteen_bit_active )
    {
      IGRlong msg;

	/**************************************************************/
	/*                                                            */
	/* Load in the 16-bit font using EXNUC font handler.  Then if */
	/* somebody else requests the exact same font within EXNUC,   */
	/* then you will not be maintaining two copies of the same    */
	/* 16-bit font in memory. 				      */
	/*                                                            */
	/**************************************************************/

      if ( fe$add_font (msg = &msg,
             bodysize = sixteen_bit_bodysize,
             typeface = sixteen_bit_typeface,
             charmap = sixteen_bit_charmap,
             flags   = FS_DEMAND,
             font_id = &kanji_font_id) )
        {
        }
    }

  /*************************************************
      fontspec.typeface = sixteen_bit_typeface;
      fontspec.bodySize  = sixteen_bit_bodysize;
      fontspec.resFactor = 1.0;
      fontspec.aspect    = 1.0;
      fontspec.rotation  = 0.0;
      fontspec.slant     = 0.0;
      fontspec.flags     = FS_DEMAND;

      status = FSReadCharMapFile ( sixteen_bit_charmap,
					&fontspec.charMap );

      if ( status )
        {
	  fprintf(stderr,
	   "IGEFEI_ERROR: FSReadCharMapFile -- error code %d\n",status);
        }

#ifndef NT
      status = FSNewFont( &fontspec, NULL, &kanji_font_id );
#else
      status = 1;
      fprintf( stderr, "FSNewFont NOT called\n" );
#endif

      if ( status )
        {
	  fprintf(stderr,
		"IGEFEI_ERROR: FSNewFont -- error code %d\n",status);
        }
  *********************************************************/

  return ( FI_SUCCESS );

}  /*** FEI_enter() ***/



int MS_menus_displayed ( )
{
#ifdef X11
  Window window;
#elif defined(ENV5)
  int window;
#elif defined( NT )
  HWND window;
#else
#error Unknown GUI
#endif
  int num_windows = 0;

  if ( MS_panel_menu )
    {
	/* See if the panel menu is displayed */

      FIf_get_window ( MS_panel_menu, &window );
#ifdef X11
	  if ( window != None )
#elif defined(ENV5)
      if ( window > -1 )
#elif defined( NT )
      printf( "what is a NULL HWND\n" );
      if ( 0 )
#else
#error Unknown GUI
#endif
	{
	  num_windows++;
	}
    }

  if ( MS_bar_menu )
    {
	/* See if the bar menu is displayed */

      FIf_get_window ( MS_bar_menu, &window );
#ifdef X11
	  if ( window != None )
#elif defined(ENV5)
      if ( window > -1 )
#elif defined( NT )
      printf( "what is a NULL HWND\n" );
      if ( 0 )
#else
#error Unknown GUI
#endif
	{
	  num_windows++;
	}
    }

  return ( num_windows );

} /*** int MS_menus_displayed ( )  ***/



int MS_delete_visible_menus()
{
#ifdef X11
	Window window;
#elif defined(ENV5)
  int window;
#elif defined( NT )
  HWND window;
#else
#error Unknown GUI
#endif
  if ( MS_panel_menu )
    {
	/* See if the panel menu is displayed */

      FIf_get_window ( MS_panel_menu, &window );
#ifdef X11
	  if ( window != None )
#elif defined(ENV5)
      if ( window > -1 )
#elif defined( NT )
      printf( "what is a NULL HWND\n" );
      if ( 0 )
#else
#error Unknown GUI
#endif
	{
	  /* Delete the menu */

	  FIf_delete ( MS_panel_menu );
	  _MS_check_ptr ( MS_panel_menu );
	  MS_bar_menu = NULL;
	}
    }

  if ( MS_bar_menu )
    {
	/* See if the bar menu is displayed */

      FIf_get_window ( MS_bar_menu, &window );
#ifdef X11
	  if ( window != None )
#elif defined(ENV5)
      if ( window > -1 )
#elif defined( NT )
      printf( "what is a NULL HWND\n" );
      if ( 0 )
#else
#error Unknown GUI
#endif
	{
		/* Delete the menu */

	  FIf_delete ( MS_bar_menu );
	  _MS_check_ptr ( MS_bar_menu );
	  MS_bar_menu = NULL;
	}
    }

  return ( FI_SUCCESS );

} /*** int MS_delete_visible_menus()  ***/


int MS_refresh_menus ()
{
  MS_swap_menu ( BAR_MENU, "BAR_MENU" );
  MS_swap_menu ( PANEL_MENU, "PANEL_MENU" );
#ifdef X11
  MS_swap_menu ( POCKET_MENU, "POCKET_MENU" );
#endif
  return ( FI_SUCCESS );
}



/**************************************************/
/*** Tony T. calls this for the exnuc window	***/
/***   system. To stay in sync with SR windows	***/
/**************************************************/

int FI_is_SR_active()
{
#ifdef X11
  return(0);
#elif defined(ENV5)
  extern int FI_sr_mode;
  return ( FI_sr_mode );
#elif defined( NT )
  return(0);
#else
#error Unknown GUI
#endif
}



/*******************************************/
/* This function is used for ci processing */
/*      usage = 1   used      		   */
/*      usage = 0   not used  		   */
/*******************************************/
#ifdef X11
void IGE_put_point_on_form ( form, xpos, ypos, button, trans, ttag )
Form form;
int xpos;
int ypos;
int button;
int trans;
Time ttag;
#elif defined(ENV5)
void IGE_put_point_on_form ( form, xpos, ypos, button, trans )
  Form form;
  int  xpos;
  int  ypos;
  int  button;
  int  trans;
#elif defined( NT )
void IGE_put_point_on_form ( form, xpos, ypos, button, trans )
  Form form;
  int  xpos;
  int  ypos;
  int  button;
  int  trans;
#else
#error Unknown GUI
#endif
{
  int (*int_routine)();
  int (*btn_routine)();

  FIf_get_button_intercept_routine ( form, &int_routine );

  FIf_get_button_event_routine ( form, &btn_routine );

  if ( int_routine )
    {
#ifdef X11
	int_routine ( form, xpos, ypos, button, trans, ttag );
#elif defined(ENV5)
	int_routine ( form, xpos, ypos, button, trans, 0 );
#elif defined( NT )
#else
#error Unknown GUI
#endif
    }
  else if ( btn_routine )
    {
#ifdef X11
	FIf_process_point ( form, xpos, ypos, button, trans, ttag );
#elif defined(ENV5)
	FIf_process_point ( form, xpos, ypos, button, trans, 0 );
#elif defined( NT )
#else
#error Unknown GUI
#endif
    }

}  /***  void IGE_put_point_on_form ( )  ***/

int FI_manipulate_form ( ex_data )
  struct EX_form_data_st * ex_data;

{
  Form		form;
  int		status;
  struct EXFI_data_st * g_data = &ex_data->data;
  char		* alpha = g_data->value.alpha;
  int		omform_data_type = g_data->type;
  int		label  = g_data->label;
  int		row    = g_data->index;
  int		select = g_data->select_flag;
  int		column;
  int		iforms_gadget_type;
  int		mode;
  int		form_label = 0;
  int		(*init_notify)() = 0;
  int		gadget_init_notify = 0;
  int		gadget_attr = 0;
  char		proc_data_str[2000];
#ifdef X11
  Time ttag;
  ttag = 0;
#endif
  if ( FI_get_form_by_name ( ex_data->form_name, &form ) )
    {
     	return ( FALSE );
    }

  status = FIg_get_type ( form, label, &iforms_gadget_type );
  if ( status )
    {
      return ( FI_SUCCESS );
    }

  FIf_get_initial_notification_routine ( form, &init_notify );
  FIf_get_label ( form, & form_label );
  FIg_get_attr ( form, label, & gadget_attr );
  gadget_init_notify = init_notify && ( gadget_attr & FI_INITIAL_NOTIFY );

  /* Set the column */   /* I moved this for multi-column problem. Doree */

  column = g_data->max_index;

	/*********************************************************/
	/* If the gadget is a multi_col field then this will	 */
	/*   change the index so the correct field is being used */
	/*********************************************************/

  if ( iforms_gadget_type == FI_MULTI_COL )
    {
      /* Added for RAP multi-column text problem. Doree  8/25/93 */

      FIfld_set_active_row ( form, label, row, row );

      FImcf_set_active_col(form, label, column, column);

      /*** See if the omform_data_type == ROW_SELECT	***/
      /***   meaning that the select button was hit 	***/

      if ( omform_data_type == ROW_SELECT )
	{
          int   (*func_ptr)(), neg_one = -1;
	  FImcf_set_select ( form, label, row, 1 );

          /* Added for RAP multi-column text problem. Doree */

          FIfld_set_active_row ( form, label, row, row );

          /*  Added code here for multi-column select problem in RAP. Doree */

          FIf_get_notification_routine(form, &func_ptr);
          (*func_ptr)(form_label, label, (double) neg_one, form);

	  goto quit;
	}

		/* Change type to field */

      iforms_gadget_type = FI_FIELD;
    }

  /* Added code to handle associative list in RAP.  Doree  7/2/93 */

  if (select == EXFI_SELECTED)
  {
      FIfld_set_list_select(form, label, row, 0, TRUE);
      row = 0;
  }

	/* Determine if the list is a selectable list */

  FIfld_get_mode ( form, label, column, &mode );

  if ( ( mode == FI_SINGLE_SELECT ) || ( mode == FI_MULTI_SELECT ) )
    {
      omform_data_type = SELECT_LIST;
    }

	/* Determine what type of gadget it is */

  if ( omform_data_type == ROLL_THRU )
    {
      FIfld_set_select ( form, label, row, column, 0 );

      if ( gadget_init_notify )
        {
          init_notify ( form_label, label, (double) row, form );
        }
    }
  else if ( omform_data_type == EXFI_POINT )
    {
#ifdef X11
      IGE_put_point_on_form ( form, g_data->value.btn.x,
					g_data->value.btn.y,
					g_data->value.btn.numb,
					g_data->value.btn.down, ttag );
#elif defined(ENV5)
      IGE_put_point_on_form ( form, g_data->value.btn.x,
					g_data->value.btn.y,
					g_data->value.btn.numb,
					g_data->value.btn.down );
#else
#error Unknown GUI
#endif
      return ( TRUE );
    }
  else if ( omform_data_type == EXFI_STATE )
    {
      FIg_set_state ( form, label, g_data->value.state );

      if ( label == FI_CVT_TO_PERM_WIN )
	{
	  FIf_cvrt_to_perm_win ( form );
	  FIg_disable ( form, FI_CVT_TO_PERM_WIN );
	}
      else if ( label == FI_RESET )
	{
	  FIg_reset ( form, FI_FORM_GROUP );
	}

      if ( gadget_init_notify )
        {
          init_notify ( form_label, label,
				(double) g_data->value.state, form );
        }
    }
  else if ( omform_data_type == EXFI_INT )
    {
	  if ( iforms_gadget_type == FI_FIELD )
	    {
	      FIfld_set_value ( form, label, row, column,
				  (double)g_data->value.ivalue,
				   select );

	    }
	  else
	    {
	      FIg_set_value ( form, label,
				(double) g_data->value.ivalue );
	    }


      if ( gadget_init_notify )
        {
          init_notify ( form_label, label,
				(double) g_data->value.ivalue, form );
        }
    }
  else if ( omform_data_type == EXFI_DOUBLE )
    {
	  if ( iforms_gadget_type == FI_FIELD )
	    {
	      FIfld_set_value ( form, label, row, column,
				  g_data->value.dvalue, select );

	    }
	  else
	    {
	      FIg_set_value ( form, label, g_data->value.dvalue );
	    }

      if ( gadget_init_notify )
        {
          init_notify ( form_label, label,
				(double) g_data->value.state, form );
        }
    }
  else if ( omform_data_type == EXFI_ALPHA )
    {
	  if ( iforms_gadget_type == FI_FIELD )
	    {
		FIfld_set_text ( form, label, row, column,
					  alpha, select );

	      if ( gadget_init_notify )
	        {
	          init_notify ( form_label, label,
				(double) row, form );
	        }
	    }
	  else if ( iforms_gadget_type == FI_TEXT )
	    {
		FIg_erase    ( form, label );
		FIg_set_text ( form, label, alpha );
		FIg_display  ( form, label );
	    }
    }
  else if ( omform_data_type == SELECT_LIST )
    {
      FIfld_set_active_row ( form, label, row, 0 );  /* JAJ:10/04/91 */

      FIfld_set_select ( form, label, row, column, select );

      if ( gadget_init_notify )
        {
          init_notify ( form_label, label, (double) row, form );
        }
    }



  FIg_call_notification_routine ( form, label );

  RAPFormListener ( ex_data->form_name, g_data );

quit:
	/*** do extra things that I/Forms does when the ***/
	/*** user pokes a gadget.			***/

  if ( FI_process_data )
    {
      if ( gadget_attr & FI_HELP_TOPIC )
	{
	  FIg_get_help_topic ( form, label, proc_data_str );

	  if ( proc_data_str[0] )
	    {
	      FI_process_data ( FI_HELP_TOPIC_DATA,
					proc_data_str, form );
	    }
	}

      if ( gadget_attr & FI_CMD_KEY )
	{
	  FIg_get_command ( form, label, proc_data_str );

	  if ( proc_data_str[0] )
	    {
	      FI_process_data ( FI_CMD_KEY_DATA, proc_data_str, form );
	    }
	}

      if ( gadget_attr & FI_CMD_STRING )
	{
	  FIg_get_command ( form, label, proc_data_str );

	  if ( proc_data_str[0] )
	    {
	      FI_process_data ( FI_CMD_STRING_DATA,
					proc_data_str, form );
	    }
	}
    }

  return ( TRUE );

}  /*** int FI_manipulate_form ( )  ***/

void MIm_show_cmds ( fout, menu_file )
  FILE *fout;
  char * menu_file;
{
  int status;

  Form menu;

  status = FIf_new ( 100, menu_file, NULL, &menu );
  if ( status )
    {
      char * string;

      switch ( status )
	{
	  case FI_FORM_FILE_NOT_FOUND:
	    string = "menu not found" ;
	    break;

	  case FI_FORM_FILE_READ_ERROR:
	    string = "read error" ;
	    break;

	  case FI_FORM_FILE_OPEN_DENIED:
	    string = "permission denied" ;
	    break;

	  case FI_NO_MEMORY:
	    string = "no memory" ;
	    break;

	  case FI_INVALID_FORMAT:
	    string = "invalid format" ;
	    break;

	  case FI_INVALID_VERSION:
	    string = "invalid version" ;
	    break;

	  default:
	    string = "unknown error" ;
	    break;
	}

	fprintf ( stderr,
	  "IGEFEI_ERROR: MIm_show_cmds -- error %d loading menu \"%s\": %s\n",
          status, menu_file, string );
    }
  else
    {
#ifdef ENV5
	void call_back();
#elif defined(X11)
	int call_back();
#elif defined( NT )
	void call_back();
#else
#error Unknown GUI
#endif
	FIgrp_callback ( menu, FI_FORM_GROUP, call_back, (int)fout );

	FIf_delete ( menu );
    }

} /***  void MIm_show_cmds ( )  ***/

#ifdef ENV5
void call_back ( form, label, fout )
#elif defined(X11)
int call_back ( form, label, fout )
#elif defined( NT )
void call_back ( form, label, fout )
#else
#error Unknown GUI
#endif
  Form form;
  int  label;
  FILE * fout;
{
  int sts;
  int type;
  int attr_mask;
  char palette_name[16];

  FIg_get_attr ( form, label, &attr_mask );

  if ( ( attr_mask & FI_CMD_KEY  ) || ( attr_mask & FI_CMD_STRING  ) )
    {
	int sym_index;

	char form_name[16];
	char command[1000];

	FIf_get_name ( form, form_name );
	FIg_get_command ( form, label, command );
	FIg_get_off_symbol_index ( form, label, &sym_index );

	if ( attr_mask & FI_CMD_KEY  )
	  {
	    type = EX_CMD_KEY;
	  }
	else
	  {
	    type = CMD_STRING;
	  }

	fprintf ( fout, "%d\t\"%s\"\t\"%s\"\t%d\n",type,
				command, form_name, sym_index );
    }

	/* If this button has a palette then dump it */

  sts = FIbtn_get_palette ( form, label, palette_name );

  if ( ( ! sts ) && ( palette_name[0] != '\0' ) )
    {
	MIm_show_cmds ( fout, palette_name );
    }
#ifdef X11
return(1);
#endif
} /*** void call_back ( )  ***/



int MS_dump_menus ( file )
  char * file;
{
  FILE *fout;

  strcpy ( file, "/usr/tmp/MENU_DUMP" );

  if ( fout = (FILE *) fopen ( file, "w" ) )
    {
	MIm_show_cmds ( fout, "BAR_MENU" );
	MIm_show_cmds ( fout, "POCKET_MENU" );
	MIm_show_cmds ( fout, "PANEL_MENU" );

	fclose ( fout );
    }

  return ( FI_SUCCESS );

}  /***  int MS_dump_menus ( )  ***/

#ifdef X11
/*
IGE_colormap_notify( mycolormap, num_slot)
Colormap mycolormap[];
int num_slot;
{
   int (*myfunc)();

        FI_get_env( FI_COLORMAP_NOTIFY, &myfunc );
	(*myfunc)(0,mycolormap[0],num_slot);
	(*myfunc)(1,mycolormap[1],num_slot);
        MSX_colormap_notify();
}*/

#endif
%endsafe

static int sendHelp( unsigned short cmd_os, unsigned int cmd_oid )
{
  return om$send ( senderid = cmd_oid,
	           targetid = cmd_oid,
	           targetos = cmd_os,
	           msg = message super_cmd.help() );
}

static int sendHelpTopic( unsigned short cmd_os, unsigned int cmd_oid,
                          int flag, char *topic )
{
  return om$send ( senderid = cmd_oid,
	           targetid = cmd_oid,
	           targetos = cmd_os,
                   msg = message super_cmd.help_topic( flag, topic ) );
}

end implementation Root;

