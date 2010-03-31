
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

/*
DESCRIPTION
	display_img

	Standalone "Display Image"
	   - Execute an animation or slide-show on multiple run-length encoded raster
	   files or do interpolated zoom on one file. The file(s) may be RLE type 27
	   or 29
HISTORY
10/17/91	Completed creation.
								Trevor Mink
*/

#include <stdio.h>
#include <tools.h>
#include <sdl.h>
#include <math.h>
#include "FI.h"
#include "rle_view.h"
#include "hsmsg.h"
#include "hsmachine.h"

#define RUN		1
#define CANCEL		4

/* Toggles */
#define SLIDESHOW_ANIMATE	17
#define STEP_DELAY		18
#define CYCLE			19

/* Fields */
#define WINDOW_FIELD		16
#define FRAME_DELAY		20
#define CYCLE_DELAY		21
#define SCALE_FIELD		23

/* Groups */
#define WINDOW_GROUP		25
#define FRAME_DELAY_GROUP	26
#define CYCLE_DELAY_GROUP	27

/* Button */
#define OPTIONS			28

/* Subform buttons */
#define CLEAR_WINDOW		11
#define DISPLAY_OPTIMIZATION	12
#define DISPLAY_OF_RGB_DATA	13

#define DO_FORM			2
#define FORM			100

#define COMMA			','
#define BLANK			' '
#define TAB			'\t'
#define NEWLINE			'\n'
#define DOLLAR_SIGN		'$'
#define BACKSLASH		'\\'
#define ASCII_ONE		'1'
#define DOUBLE_QUOTE		'\"'

#define DEBUG		0
#define MSGDEBUG	0
#define ENVDEBUG	0

#define APPEARANCE		0
#define SPEED			1

#define DO_24_BIT		0
#define DO_8_BIT		1

/* Zoom mode indicator */
#define EXIT		1
#define NO_ACTION	2

static int true_color;
static int x_dits, y_dits;

static int    chars_in_buffer;

static int FormStatus, plane_mask;
static char filename[200], MsgFile[200];
static int planes, phong_flag, BuffersFilled;
static int win_no, do_form;
static int animate, delay, cycle, scale_factor;
static double FrameDelay[2], CycleDelay[2];
static int vs_no;
static struct scr_info screen_info[MAX_SCREENS];
static struct vlt_slot vlt[17];

/* Support sub-form functionality */
static int WindowErase, Optimize;
static Form main_form_ptr, sub_form_ptr;

/*
 * GetDirectory() returns in 'Directory' the directory name associated with the entry 'Platform' in the
 * file '/usr/ip32/<Platform>'. If this file is non-existent, a null string is returned.
 *
 * HISTORY: 07/26/90	Created.
 *								Trevor Mink
 */

void GetDirectory( Platform, Directory, LanguageDir )
	char Platform[], Directory[];
	int LanguageDir;
{
	FILE  *fd;
	char  *ch, Filename[50], Temp[50];
	int   i, bytes_read, Found = FALSE;
	char  *ingrhome, *getenv(), fontfile[50];


	if ((ingrhome = getenv("INGRHOME")) == NULL)
        {
           fprintf( stderr, " Can't define INGRHOME\n");
	}
	else
	{
           strcpy (fontfile, ingrhome);
           strcat (fontfile, "/product_data");
           fd = fopen( fontfile, "r" );
	}

	if( !fd ) goto notfound;
	do
	{
		ch = Directory-1;
		do
		{
			ch++;
			bytes_read = fread( ch, 1, 1, fd );
		}
		while( *ch != BLANK && *ch != EOF && bytes_read );
		if( *ch == EOF ) break;

		ch[-1] = '\0';
#if ENVDEBUG
		fprintf( stderr, "Platform = %s\tDirectory = %s\n", Platform, Directory );
#endif
		if( !strcmp( Platform, Directory+1 ) )
		{
			Found = TRUE;
#if ENVDEBUG
			fprintf( stderr, "Found\n" );
#endif
		}

		for( i = 0; i < 4; i++ )
		{
			ch = Directory-1;
			do
			{
				ch++;
				bytes_read = fread( ch, 1, 1, fd );
			}
			while( *ch != BLANK && *ch != NEWLINE && *ch != EOF && bytes_read );
			*ch = '\0';
		}

		if( Found )
		{
#if ENVDEBUG
			fprintf( stderr, "Directory = %s\n", Directory );
#endif
			fclose( fd );
			if( LanguageDir )
			{
				sprintf( Filename, "%s/config", Directory );
				sprintf( Temp, "%s", Filename );
				sprintf( Filename, "%s/language", Temp );
#if ENVDEBUG
				fprintf( stderr, "Filename = %s\n", Filename );
#endif
				fd = fopen( Filename, "r" );
				if( fd )
				{
					fscanf( fd, "%s", Filename );
					if( !Filename[0] || Filename[0] == BLANK || Filename[0] == TAB ||
						Filename[0] == NEWLINE )
					{
						Directory[0] = '\0';
						fprintf( stderr, "ERROR: language not found in file %s/language\n",
							Temp );
					}
#if ENVDEBUG
					fprintf( stderr, "Filename = %s\n", Filename );
#endif
					sprintf( Directory, "%s/%s", Temp, Filename );
#if ENVDEBUG
					fprintf( stderr, "Directory = %s\n", Directory );
#endif
					fclose( fd );
				}
				else
				{
					fprintf( stderr, "ERROR: file %s not found\n", Filename );
					Directory[0] = '\0';
				}
			}
			return;
		}
	}
	while( *ch != EOF && bytes_read );
notfound:
	fclose( fd );
	Directory[0] = '\0';
 	fprintf( stderr, "ERROR: %s entry not found in /usr/ip32/product_data\n", Platform );

} /* GetDirectory */

/*
 * GetMessage() opens hsmessage.msg, the message file, and reads the message numbers and their corresponding
 * text until it finds the message or it finds end of file (EOF).
 *
 * HISTORY: 07/25/90	Created.
 *								Trevor Mink
 */

int GetMessage( MsgNumber, buffer, ParmArray )
	int MsgNumber;
	char *buffer, *ParmArray[];
{
	int Number, bytes_read, Length, ParamIndex;
	FILE *fd;
	char *ch;

	fd = fopen( MsgFile, "r" ); /* Open file for reading */
	if( !fd ) return( EOF );
#if MSGDEBUG
	fprintf( stderr, "File opened\tfd = %d\tLooking for message number: %d\n", fd, MsgNumber );
#endif
	do
	{
		bytes_read = fread( buffer, 1, 9, fd );
		if( bytes_read < 9 )
		{
			fclose( fd );
			return( EOF );
		}
		buffer[9] = (char)NULL;

		sscanf( buffer, "%d,", &Number );
#if MSGDEBUG
		fprintf( stderr, "msgnumb(string) = %s\tmsgnumb(number) = %d\n",
			buffer, Number );
#endif
		if( buffer[8] == COMMA )
		{
			/* Throw away to next BLANK */
			do
			{
				bytes_read = fread( buffer, 1, 1, fd );
				if( !bytes_read )
				{
					fclose( fd );
					return( EOF );
				}
			}
			while( buffer[0] != BLANK );
		}
		/* Get the entire string to the NEWLINE or EOF character */
		ch = buffer - 1;
		do
		{
			ch++;
			bytes_read = fread( ch, 1, 1, fd );
			if( (Number == MsgNumber) && (*ch == DOLLAR_SIGN) )
			{
				if( ch == buffer || ch[-1] != BACKSLASH )
				{
					/* Read the number following the DOLLAR_SIGN */
					ch++;
					bytes_read = fread( ch, 1, 1, fd );

					/* Array indices start at 0 */
					ParamIndex = (int)( *ch - ASCII_ONE );
#if MSGDEBUG
					fprintf( stderr, "ParamIndex = %d\n", ParamIndex );
#endif
					/* Make sure it's a digit 1-9 -> (0-8) */
					/* No double-figures support */
					if( ParamIndex < 9 && ParamIndex >= 0 )
					{
						Length = strlen( ParmArray[ParamIndex] );
						memcpy( (ch-1), ParmArray[ParamIndex], Length );
						ch += (Length-2);
					}
				}
			}
		}
		while( *ch != NEWLINE && *ch != EOF && bytes_read );

		*ch = (char)NULL;
	}
	while( Number != MsgNumber );

	fclose( fd );
	return( 0 );

} /* GetMessage */

/*
 *--------color_compensate-------------------------------------------------
 *
 * Given an intensity value in the range [0..65535], return a corresponding
 *   compensated or uncompensated value, depending on the "convert_opt"
 *   flag.
 *
 *    color_compensate:  returns a color-compensated intensity value, given
 *      an uncompensated intensity, or returns an uncompensated intensity
 *      value, given a color-compensated intensity.
 *
 *  Author:  D. H. Holmes				Date:  7/7/89
 */

#define	GAMMA 2.2
#define ONE 65535
#define D_ONE 65535.0

static int color_compensate(intensity, convert_opt)
  int intensity;	/* intensity value - uncompensated or compensated */
  int convert_opt;	/* [0] compensate or [1] uncompensate intensity */
  {
    double temp;	/* intermediate temporary value */

    if (intensity <= 0)
      return (0);
    else if (intensity >= ONE)
      return (ONE);
    else
      {
        if (convert_opt == 1)	/* convert compensated intensity */
          {			/*   to uncompensated intensity  */
            temp = pow (((double)(intensity) / D_ONE), (GAMMA));
            return((int)((temp * D_ONE) + 0.5));
          }
        else	/* convert uncompensated intensity to compensated intensity */
          {
            temp = pow (((double)(intensity) / D_ONE), (1.0 / GAMMA));
            return((int)((temp * D_ONE) + 0.5));
          }
      }
  }	/* color_compensate */

/*--- create_window --------------------------------------------------------------*/

void create_window( w_no, plane_mask )
	int *w_no, *plane_mask;
{
	int ii, vlt_type, true_color_vltno;
	struct vlt_info vlt_info;
	struct scr_info screen_info[MAX_SCREENS];
	struct vlt_slot vlt[256];

	/* construct a hardware window that covers the entire screen */
	Inq_displayed_vs( &vs_no );
	Inq_screen_info( screen_info );

	x_dits = screen_info[vs_no].vsi_x;
	y_dits = screen_info[vs_no].vsi_y - MESSAGE_STRIP_HEIGHT;

	Create_win_no_border( vs_no, 0, 0, x_dits-1, y_dits-1, w_no );

	true_color = screen_info[vs_no].vsi_flags & VSI_24_ZB_ABILITY;

	if( true_color )
	{
		*plane_mask = 0xffffff;
		Alloc_vlt( TRUE_COLOR_VLT, &true_color_vltno );
		/* build the calibrated/uncalibrated vlt */
		for( ii = 0; ii < 256; ii++ )
		{
			vlt[ii].v_slot = ii;
			vlt[ii].v_red = vlt[ii].v_green = vlt[ii].v_blue =
				color_compensate( (ii << 8) , 0 );
		}
		/* load into TRUE COLOR vlt */
		Load_allocated_vlt( vs_no, true_color_vltno, vlt, 256 );
		activevltno( *w_no, true_color_vltno );

		/* enable all available bit planes for the image */
		Inq_vlt_type( true_color_vltno, &vlt_type );
		Inq_vlt_info( vs_no, vlt_type, &vlt_info );
		enabledata( *w_no, IMAGE_DATA, 0xffffff );
		enabledata( *w_no, HIGHLIGHT_DATA, 0x0 );
#if DEBUG
		Read_allocated_vlt( vs_no, true_color_vltno, vlt, 256, 0 );
		for( ii = 0; ii < 256; ii++ )
		{
			fprintf( stderr, "Slot %d\t%d %d %d\n", vlt[ii].v_slot,
				vlt[ii].v_red, vlt[ii].v_green, vlt[ii].v_blue );
		}
		fprintf( stderr, "vlt type = %d\n", vlt_type );
		fprintf( stderr, "vlt:\tstart\tsize\tmax_alloc_vlts\tnum_planes\tbytes_per_pixel\tvlti_flags\n\t%d\t%d\t%d\t\t%d\t\t%d\t\t%x\n",
			vlt_info.vlti_vlt_start, vlt_info.vlti_vlt_size,
			vlt_info.vlti_max_alloc_vlts, vlt_info.vlti_num_planes,
			vlt_info.vlti_num_bytes_per_pixel, vlt_info.vlti_flags );
#endif
	}
	else
	{
		*plane_mask = 0x1FF;
		enableplane( *w_no, *plane_mask );
	}

	Display_win( *w_no );
	Erase_win( *w_no );
	flushbuffer( *w_no );

} /* create_window */

/*
 * get_keyin_from_user() prompt the user for a keyin in message strip 1.
 *
 * HISTORY: 07/20/90	Created from SRo's standalone.
 *								Trevor Mink
 */

static void get_keyin_from_user( prompt, buffer )
	char *prompt, *buffer;
{
	int	cef;

	Enable_events( KEYIN_EVENT );
	Display_message( 3, RIGHT, prompt );
	Process_keyin( 4, LEFT, "" );
	Wait_for_events( KEYIN_EVENT, &cef );
	Get_keyin_data( &chars_in_buffer );
	buffer[chars_in_buffer] = '\0';

} /* get_keyin_from_user */

int WaitForButton( MouseX, MouseY )
	int *MouseX, *MouseY;
{
	int status = 0;
	int Mask, Window, Button, Transition, UnNeeded;
	char MsgBuffer[200];

	Display_message( 3, CENTER, "Zoom In | Pan/Restore | Zoom Out/Exit" );
	Display_message( 4, CENTER, "" );
	while( TRUE )
	{
		if( IGEstop() )
		{
			status = EXIT;
			break;
		}
		Inq_events( &Mask );
		if( Mask & BUTTON_EVENT )
		{
			Get_button_data( &Window, MouseX, MouseY, &Button, &Transition, &UnNeeded );
			if( Transition == DOUBLE_CLICK )
			{
				if( Button == MIDDLE_BUTTON )
				{
					*MouseX = 0;
					*MouseY = 0;
					scale_factor = 4;
					status = 0;
				}
				else if( Button == RIGHT_BUTTON )
					status = EXIT;
				break; /* Out of while( TRUE ) loop */
			}
			else if( Window == win_no )
			{
				status = 0;
				switch( Button )
				{
				case LEFT_BUTTON:
					if( scale_factor == 0 ) scale_factor = 1;
					else if( scale_factor < 16 ) scale_factor *= 2;
					else
					{
						/* WARNING msg here that scale is max already */
						if( !GetMessage( HS_W_ScaleAlreadyMax, MsgBuffer, (char **)0 ) )
						{
							Display_message( 2, CENTER, MsgBuffer );
							sleep( 3 );
							Display_message( 2, LEFT, "" );
						}
						else
							fprintf( stderr,
							"ERROR: Message %d not found in message file hsmessage.msg\n",
								HS_W_ScaleAlreadyMax );
						status = NO_ACTION;
					}
					break;
				case RIGHT_BUTTON:
					if( scale_factor > 1 ) scale_factor /= 2;
					else if( scale_factor == 1 ) scale_factor = 0;
					else
					{
						/* WARNING msg here that scale is min already */
						if( !GetMessage( HS_W_ScaleAlreadyMin, MsgBuffer, (char **)0 ) )
						{
							Display_message( 2, CENTER, MsgBuffer );
							sleep( 3 );
							Display_message( 2, LEFT, "" );
						}
						else
							fprintf( stderr,
							"ERROR: Message %d not found in message file hsmessage.msg\n",
								HS_W_ScaleAlreadyMin );
						status = NO_ACTION;
					}
					break;
				case MIDDLE_BUTTON:
					break;
				}
				break; /* Out of while( TRUE ) loop */
			}
		} else if( Mask & KEYBOARD_EVENT ) {
			status = EXIT;
			break; /* Out of while( TRUE ) loop */
		}
	}
	return( status );

} /* WaitForButton */

static void set_form_defaults()
{
/*	win_no = 0; */

	BuffersFilled = FALSE;
	do_form = FALSE;

	animate = FALSE;
	delay = TRUE;
	cycle = TRUE;
	scale_factor = 4;

	FrameDelay[0] = 5.0;
	FrameDelay[1] = 0.0;
	CycleDelay[0] = 10.0;
	CycleDelay[1] = 1.0;

	if( planes <= 5 )
		Optimize = APPEARANCE;
	else
		Optimize = SPEED;

	WindowErase = FALSE;

} /* set_form_defaults */

/*
 * init_subform_display() initializes the display of the sub-form 'options'.
 *
 * HISTORY: 08/22/90	Created from action of same name in HSanimate.sl.
 *								Trevor Mink
 */

static void init_subform_display( form_ptr )
	Form form_ptr;
{
	int on_edgeII=FALSE, flags;
	int term_type;

	HSgetMachineInfo(NULL, &term_type, NULL);
	if (term_type == EDGEII_TRC)
		on_edgeII= TRUE ;

	if (on_edgeII)
	{
		if( animate && phong_flag)	/* type 27 data file */
		{
			if( BuffersFilled ) /* means 'buffers_filled' */
				FIg_disable(form_ptr, DISPLAY_OF_RGB_DATA);
			else
				FIg_enable( form_ptr, DISPLAY_OF_RGB_DATA );
			if( Optimize == DO_24_BIT )
				FIg_set_state_off(form_ptr, DISPLAY_OF_RGB_DATA);
			else
				FIg_set_state_on(form_ptr, DISPLAY_OF_RGB_DATA);
		}
		else				/* index data type */
		{
			Optimize = DO_8_BIT;
			FIg_disable(form_ptr, DISPLAY_OF_RGB_DATA);
		}
	}
	else
	{
		FIg_erase(form_ptr, DISPLAY_OF_RGB_DATA);

		if( planes <= 5 && animate && !BuffersFilled )
		{
			FIg_enable( form_ptr, DISPLAY_OPTIMIZATION );

			if( Optimize == APPEARANCE )
				FIg_set_state_on( form_ptr, DISPLAY_OPTIMIZATION );
			else
				FIg_set_state_off( form_ptr, DISPLAY_OPTIMIZATION );
		}
		else
			FIg_disable( form_ptr, DISPLAY_OPTIMIZATION );
	}

} /* init_subform_display */

static void init_form_display( form_ptr )
	Form form_ptr;
{
	int Row;

	FIg_erase( form_ptr, WINDOW_GROUP );

	if( animate )
		FIg_set_state_on( form_ptr, SLIDESHOW_ANIMATE );
	else
		FIg_set_state_off( form_ptr, SLIDESHOW_ANIMATE );

	if( cycle )
		FIg_set_state_off( form_ptr, CYCLE );
	else
		FIg_set_state_on( form_ptr, CYCLE );

	switch( scale_factor )
	{
	case 0:		Row = 3;	break;
	case 1:		Row = 4;	break;
	case 2:		Row = 5;	break;
	case 4:		Row = 0;	break;
	case 8:		Row = 1;	break;
	case 16:	Row = 2;	break;
	}
	FIfld_set_select( form_ptr, SCALE_FIELD, Row, 0, FALSE );

	if( delay )
	{
		FIg_set_state_off( form_ptr, STEP_DELAY );

		FIg_display( form_ptr, FRAME_DELAY_GROUP );
		FIg_set_value( form_ptr, FRAME_DELAY, FrameDelay[animate] );
		if( cycle )
		{
			FIg_display( form_ptr, CYCLE_DELAY_GROUP );
			FIg_set_value( form_ptr, CYCLE_DELAY, CycleDelay[animate] );
		}
		else
			FIg_erase( form_ptr, CYCLE_DELAY_GROUP );
	}
	else
	{
		FIg_set_state_on( form_ptr, STEP_DELAY );

		FIg_erase( form_ptr, FRAME_DELAY_GROUP );
		FIg_erase( form_ptr, CYCLE_DELAY_GROUP );
	}

	if( do_form )
	{
		FIg_disable( form_ptr, SLIDESHOW_ANIMATE );
		FIg_disable( form_ptr, SCALE_FIELD );
	}
	else
	{
		FIg_enable( form_ptr, SLIDESHOW_ANIMATE );
		FIg_enable( form_ptr, SCALE_FIELD );
	}
	do_form = FALSE;

} /* init_form_display */

static void DoAnimate()
{
	int status;

	status = HSrapid_display(win_no, planes, animate, delay, cycle,
		FrameDelay[animate], CycleDelay[animate], true_color, (Optimize==SPEED),
		WindowErase, FALSE );

	if( status == DO_FORM )
		do_form = TRUE;
	else
	{
		do_form = FALSE;

		/* Free the buffers */
		if( animate || cycle ) HSfree_buffers();

		BuffersFilled = FALSE;
	}

} /* DoAnimate */

static void InterpolatedZoom()
{
	int status = 0;
	int MouseX = 0, MouseY = 0;

	create_window( &win_no, &plane_mask );
	if( phong_flag && !true_color )
	{
		if ( (screen_info[vs_no].vsi_VLT_size == 256) &&
			(screen_info[vs_no].vsi_num_planes == 9) )
			HRinit_rgb( win_no, vs_no, 8, FALSE );
			/* we are on an EDGE I => don't use vsi_num_planes. It's wrong */
		else
			HRinit_rgb( win_no, vs_no, planes + 1, FALSE );
	}

	do
	{
		if( status != NO_ACTION )
		{
			(void)HSread_rle_files( win_no, filename, 0, planes, FALSE, scale_factor,
				FALSE, 0.0, 0.0, MouseX, MouseY, phong_flag, TRUE, WindowErase );
		}
		status = WaitForButton( &MouseX, &MouseY );
	}
	while( status != EXIT );

} /* InterpolatedZoom */

static void DoFormInput( form_ptr )
	Form form_ptr;
{
	int Mask;

	Delete_win( win_no );

	FormStatus = 0;
	if( planes >= 8 )
		HRfinish_rgb();
	else
		Loadvlt( vs_no, vlt, 17, 0 );
	init_form_display( form_ptr );
	FIf_display( form_ptr );
	do
	{
		Wait_for_next( BUTTON_EVENT | KEYIN_EVENT | KEYBOARD_EVENT, &Mask );
		FI_process_event( BUTTON_EVENT | KEYIN_EVENT | KEYBOARD_EVENT );
	}
	while( FormStatus != RUN && FormStatus != CANCEL );
	Erase_win( win_no );

} /* DoFormInput */

static void subform_notification( form_label, gadget_label, value, form_ptr )
	int form_label;
	int gadget_label;
	double value;
	Form form_ptr;
{
	switch( gadget_label )
	{
	case CLEAR_WINDOW:
		WindowErase = (WindowErase) ? FALSE : TRUE;
		break;
	case DISPLAY_OPTIMIZATION:
		Optimize = (Optimize == APPEARANCE) ? SPEED : APPEARANCE;
		break;
	case DISPLAY_OF_RGB_DATA:
		Optimize = (Optimize == DO_8_BIT) ? DO_24_BIT : DO_8_BIT;
		if( Optimize == DO_8_BIT ) planes = 8;
#if DEBUG
		fprintf(stderr, "*** number of planes in FORM_NOT = %d\n", me->planes);
#endif
		break;
	case RUN:
		FIg_set_state_off( form_ptr, RUN );
		FIf_erase( form_ptr );
		FIg_set_state_off( main_form_ptr, OPTIONS );
	}

} /* subform_notification */

static void form_notification( form_label, gadget_label, value, form_ptr )
	int 	form_label;
	int 	gadget_label;
	double 	value;
	Form 	form_ptr;
{
	char 	String[6];
	double 	TimeDelay;
	int 	sel_flag, r_pos, Row, status;

	FormStatus = gadget_label;
	switch ( gadget_label )
	{
	case OPTIONS:
		FIf_new( FORM, "HSDisImagSub", subform_notification, &sub_form_ptr );
		init_subform_display( sub_form_ptr );
		if( WindowErase )
			FIg_set_state_off( sub_form_ptr, CLEAR_WINDOW );
		else
			FIg_set_state_on( sub_form_ptr, CLEAR_WINDOW );
		if( planes <= 5 )
		{
			if( Optimize == APPEARANCE )
				FIg_set_state_on( sub_form_ptr, DISPLAY_OPTIMIZATION );
			else
				FIg_set_state_off( sub_form_ptr, DISPLAY_OPTIMIZATION );
			FIg_display( sub_form_ptr, DISPLAY_OPTIMIZATION );
		}
		else
			FIg_erase( sub_form_ptr, DISPLAY_OPTIMIZATION );
		FIf_display( sub_form_ptr );
		break;
	case SCALE_FIELD:
		FIfld_get_active_row( form_ptr, SCALE_FIELD, &Row, &r_pos );
		scale_factor = 1;
		switch( Row )
		{
		case 0:
			scale_factor = 4;
			break;
		case 1:
			scale_factor = 8;
			break;
		case 2:
			scale_factor = 16;
			break;
		case 3:
			scale_factor = 0;
			break;
		case 4:
			scale_factor = 1;
			break;
		case 5:
			scale_factor = 2;
			break;
		}
		break;
	case SLIDESHOW_ANIMATE:
		animate = ( ( animate ) ? FALSE : TRUE );
		if( animate ) FIg_set_state_on( form_ptr, FRAME_DELAY_GROUP );
		else FIg_set_state_off( form_ptr, FRAME_DELAY_GROUP );
		if( delay )
			FIg_set_value( form_ptr, FRAME_DELAY, FrameDelay[animate] );
		if( cycle )
			FIg_set_value( form_ptr, CYCLE_DELAY, CycleDelay[animate] );
		break;
	case STEP_DELAY:
		delay = ( (  delay ) ? FALSE : TRUE );
		if( delay )
		{
			FIg_display( form_ptr, FRAME_DELAY_GROUP );
			FIg_set_value( form_ptr, FRAME_DELAY, FrameDelay[animate] );
			if( cycle )
			{
				FIg_display( form_ptr, CYCLE_DELAY_GROUP );
				FIg_set_value( form_ptr, CYCLE_DELAY, CycleDelay[animate] );
			}
			else
				FIg_erase( form_ptr, CYCLE_DELAY_GROUP );
		}
		else
		{
			FIg_erase( form_ptr, FRAME_DELAY_GROUP );
			FIg_erase( form_ptr, CYCLE_DELAY_GROUP );
		}
		break;
	case CYCLE:
		cycle = ( ( cycle ) ? FALSE : TRUE );
		if( cycle && delay )
		{
			FIg_display( form_ptr, CYCLE_DELAY_GROUP );
			FIg_set_value( form_ptr, CYCLE_DELAY, CycleDelay[animate] );
		}
		else
			FIg_erase( form_ptr, CYCLE_DELAY_GROUP );
		break;
	case FRAME_DELAY:
		FIfld_get_text( form_ptr, FRAME_DELAY, 0, 0, 10, String, &sel_flag, &r_pos );
		sscanf( String, "%lf", &TimeDelay );
		if( TimeDelay >= 0.0 )
			FrameDelay[animate] = TimeDelay;
		else
			FIg_set_value( form_ptr, FRAME_DELAY, CycleDelay[animate] );
		break;
	case CYCLE_DELAY:
		FIfld_get_text( form_ptr, CYCLE_DELAY, 0, 0, 10, String, &sel_flag, &r_pos );
		sscanf( String, "%lf", &TimeDelay );
		if( TimeDelay >= 0.0 )
			CycleDelay[animate] = TimeDelay;
		else
			FIg_set_value( form_ptr, CYCLE_DELAY, CycleDelay[animate] );
		break;
	case CANCEL:
		FIg_set_state_off( form_ptr, CANCEL );
		(void)FIf_erase( form_ptr );

		do_form = FALSE;

		if( BuffersFilled )
		{
			/* Free the buffers */
			if( animate || cycle ) HSfree_buffers();

			BuffersFilled = FALSE;
		}
		break;
	case RUN:
		FIg_set_state_off( form_ptr, RUN );
		(void)FIf_erase( form_ptr );
		create_window( &win_no, &plane_mask );
		if( phong_flag && !true_color )
		{
			if ( (screen_info[vs_no].vsi_VLT_size == 256) &&
				(screen_info[vs_no].vsi_num_planes == 9) )
				HRinit_rgb( win_no, vs_no, 8, FALSE );
				/* we are on an EDGE I => don't use vsi_num_planes. It's wrong */
			else
				HRinit_rgb( win_no, vs_no, planes + 1, FALSE );
		}

		status = FALSE;
		if( !animate )
		{
			status = HSslide_show( win_no, filename, cycle, planes, scale_factor, delay,
				FrameDelay[animate], CycleDelay[animate], phong_flag, WindowErase );
			if( status == DO_FORM ) do_form = TRUE;
			else do_form = FALSE;
		}
		else
		{
			if( !BuffersFilled )
			{
				status = HSread_rle_files( win_no, filename, cycle, planes, animate,
					scale_factor, delay, FrameDelay[animate], CycleDelay[animate],
					0, 0, phong_flag, TRUE, WindowErase );
				BuffersFilled = TRUE;
			}
			if( !status )
				DoAnimate( form_ptr );
		}
		break;
	default:
		break;
	}

} /* form_notification */

/*--- main --------------------------------------------------------------------------*/

main()
{
	char 		string[256], language[50];
	extern char 	*optarg;
	int 		status;

	int 		success_msg;
	char 		MsgBuffer[200];

	int 		x_pixels, y_pixels;
	int 		MouseX, MouseY;
	Form 		form_ptr;

	/************************ Setup STOP process ****************************/
	IGEstopinit();  /* Set up process */
	IGEresetstop(); /* initialize 'igestop' to 0 */
	/************************************************************************/

	Enter_tools();

	Inq_displayed_vs( &vs_no );
	Inq_screen_info( screen_info );
	planes = screen_info[vs_no].vsi_num_planes - 1;
	/* Only need colors used in the form (13 - 16) */
	if( planes < 8 )
		Readvlt( vs_no, vlt, 17, 0 );

	/************************ Setup forms environment **********************/
	FI_enter();
	GetDirectory( "Model", language, 1 );
	sprintf( string, "%s/forms", language );
	FI_set_form_path( string );

	sprintf( string, "%s/icons", language );
	FI_set_symbol_path( string );

	FIf_new( FORM, "HSDisplImage", form_notification, &form_ptr );
	main_form_ptr = form_ptr;
	/***********************************************************************/

	sprintf( MsgFile, "%s/messages/hsmessage.msg", language );

	/************************ Setup window environment *********************/
	Set_message_mode( 4 );

	Set_logo( "Display Images" );
	/***********************************************************************/

	Set_keyin_buffer( filename, sizeof( filename ) );
	do
	{
		/* Test whether it's a phong file */
		get_keyin_from_user( "Enter path/filename of Image(s) to display ", filename );
		status = HSinq_phong_file( filename, &phong_flag, &x_pixels, &y_pixels );
	}
	while( status );
/*	Set_keyin_buffer( keyin_buffer, sizeof( keyin_buffer ) );
*/
	Enable_events( KEYIN_EVENT | BUTTON_EVENT | KEYBOARD_EVENT );

	set_form_defaults();

	/* Distinguish between single or multiple files */
	if( HSget_num_frames( filename ) > 1 )
	{
		MouseX = 0;
		MouseY = 0;
		do
		{
			DoFormInput( form_ptr );
		}
		while( do_form );
	}
	else
	{
		animate = FALSE;
		delay = TRUE;
		FrameDelay[0] = 0.0;
		CycleDelay[0] = 0.0;
		cycle = FALSE;
		MouseX = 0;
		MouseY = 0;
		InterpolatedZoom();
	}

	switch ( animate ) {
	case FALSE:
		success_msg = HS_I_ImgDisplayed;
		break;
	case TRUE:
		success_msg = HS_I_ImgAnimated;
		break;
	}

	if( !GetMessage( success_msg, MsgBuffer, (char **)0 ) )
	{
		Display_message( 2, CENTER, MsgBuffer );
		sleep( 3 );
		Display_message( 2, LEFT, "" );
	}
	else
		fprintf( stderr, "ERROR: Message %d not found in message file hsmessage.msg\n",
			success_msg );

	Delete_win( win_no );
	Exit_tools();
	IGEkillstop(); /* Kill STOP process */

/*
	   if ( (image_data[i].rle_type == TYPE_27) && (true_color) )
	      {
*/
		/* put window in TRUE COLOR mode */
/*		colormode( win_no, TRUE_COLOR ); */
/*
	      }
	   else
	      {
*/
	      /* put window in INDEXED MODE */
	      /* colormode( win_no, INDEXED_COLOR ); */
/*
	      }
*/

} /* main */
