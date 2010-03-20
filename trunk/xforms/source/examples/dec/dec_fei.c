#include <stdio.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>

#include "FI.h"
#include "FIappl.h"

#include "FEI.h"

/* Does this imply that this will only work with 16-bit characters? */
#define SUPERIMPOSE    129

char FEI_map_character ( key, character )
XKeyEvent	*key;
char		*character;
{
KeySym		keysym;
XComposeStatus	status;


	/** 256 is the size of the buffer **/

	memset( character, 0, 256 );

	XLookupString( key, character, 256, &keysym, &status );

	if( keysym == XK_Super_L || keysym == XK_Super_R )
	    *character = (char) SUPERIMPOSE;

	/** Ignore the shift keys **/

	if( keysym != XK_Shift_L && keysym != XK_Shift_R )
	    Check_for_DEC( *character, character );

	switch ( keysym )
	{
		case XK_Up:
			*character = FI_UP;
			return( 1 );

		case XK_Down:
			*character = FI_DOWN;
			return( 1 );

		case XK_Left:
			*character = FI_LEFT;
			return( 1 );
	
		case XK_Right:
			*character = FI_RIGHT;
			return( 1 );
	
		case XK_Tab:		case XK_Prior:
			*character = FI_NEXT_IN_SEQ;
			return ( 1 );
			
		case XK_BackSpace:	case XK_Next:
			*character = FI_PREV_IN_SEQ;
			return ( 1 );

		case XK_Delete:
			*character = FI_BS_DEL;
			return( 1 );

		case XK_KP_0:
			*character = '0';
			return( 0 );

		case XK_KP_1:
			*character = '1';
			return( 0 );

		case XK_KP_2:
			*character = '2';
			return( 0 );

		case XK_KP_3:
			*character = '3';
			return( 0 );

		case XK_KP_4:
			*character = '4';
			return( 0 );

		case XK_KP_5:
			*character = '5';
			return( 0 );

		case XK_KP_6:
			*character = '6';
			return( 0 );

		case XK_KP_7:
			*character = '7';
			return( 0 );

		case XK_KP_8:
			*character = '8';
			return( 0 );

		case XK_KP_9:
			*character = '9';
			return( 0 );

		case XK_KP_Add:
			*character = '+';
			return( 0 );

		case XK_KP_Subtract:
			*character = '-';
			return( 0 );

		case XK_KP_Decimal:
			*character = '.';
			return( 0 );

		case XK_KP_Enter:	case XK_Linefeed:
			*character = CR;
			return( 0 );

		case XK_Home:		case XK_Begin:
			*character = FI_BOL;
			return( 1 );

		case XK_End:
			*character = FI_EOL;
			return( 1 );
	}

	if( key->state & ControlMask )
	{
		switch( keysym ) {
		case XK_p:	case XK_P:
			*character = FI_UP;
			break;		
		case XK_n:	case XK_N:
			*character = FI_DOWN;
			break;		
		case XK_b:	case XK_B:
			*character = FI_LEFT;
			break;		
		case XK_f:	case XK_F:
			*character = FI_RIGHT;
			break;		
		case XK_a:	case XK_A:
			*character = FI_BOL;
			break;		
		case XK_e:	case XK_E:
			*character = FI_EOL;
			break;		
		case XK_d:	case XK_D:
			*character = FI_DEL;
			break;		
		case XK_k:	case XK_K:
			*character = FI_KILL_LINE;
			break;		
		case XK_y:	case XK_Y:
			*character = FI_RESTORE;
			break;		
		case XK_c:	case XK_C:
			*character = FI_UPPER_CASE;
			break;		
		case XK_l:	case XK_L:
			*character = FI_LOWER_CASE;
			break;		
		case XK_t:	case XK_T:
			*character = FI_TRANSPOSE;
			break;		
		default:
			*character = FI_IGNORE_CHAR;
		}
		return( 1 );
	}

	if( *character == '\0' )
	{
		*character = FI_IGNORE_CHAR;
		return( 1 );
	}
	else
	{
		return( 0 );		/** Regular Character **/
	}
}

