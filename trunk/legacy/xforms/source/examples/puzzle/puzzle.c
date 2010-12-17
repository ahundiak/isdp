#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include <stdio.h>
#include <math.h>
#include <time.h>
#include <FI.h>
#include "puzzle.h"



extern char *strrchr();

Display *display;

static void RandomPuzzle();
static void ShiftDown();
static void ShiftLeft();
static void ShiftRight();
static void ShiftUp();
static void UpdatePuzzle();

/***********************************************************

		function Syntax ()

************************************************************/

/*
 *  This function lists the acceptable command line arguments for this
 *  program.
 */

Syntax (pn, arg)
char *pn, *arg;
{
   printf ("%s: bad argument <%s>\n", pn, arg);
   printf ("-d display. node:display.screen\n");
   printf ("-s synchronize.\n");
   printf ("-? help. Print this message.\n");
}




/*============================================ DEBUG ==========================*/


/***************************************************************

		Sync_on(), Sync_off()

****************************************************************/

/*
 *  Synchronizing can be used to facilitate debugging in XForms, but slows
 *  performance dramatically.
 */

int Sync_on ()
{
   XSynchronize (display, True);
   printf ("Synchronize--ON\n");
   return (FI_SUCCESS);
}

int Sync_off ()
{
   XSynchronize (display, False);
   printf ("Synchronize--OFF\n");
   return (FI_SUCCESS);	
}




/******************************

	RandomPuzzle

******************************/

/*
 * This function scrambles the puzzle randomly.
 */

static void RandomPuzzle( data )
puzzleData	data;
{	int	btn, num, done;
	for( btn = 0; btn < NUM_BTNS; btn++ )
		data[btn] = 0;
	for( num = 1; num < NUM_BTNS; num++ ) {
		btn = rand( ) % NUM_BTNS;
		done = 0;
		while( !done )
			if( !data[btn] ) {
				done = 1;
				data[btn] = num;
			} else btn = (btn+1) % NUM_BTNS;
	}
}




/********************************

	GetDown()

********************************/

int GetDown( data )
puzzleData	data;
{	int	btn;
	for( btn = 0; btn < NUM_BTNS; btn++ )
		if( !data[btn] ) return(btn+TTLL);
	return 0;
}





/********************************************

		ShiftRight()

*********************************************/

static void ShiftRight( push_label, down_label, data )
int		push_label, down_label;
puzzleData	data;
{	int	pushBtn = push_label-TTLL, downBtn = down_label - TTLL;
	while( downBtn != pushBtn ) {
		data[downBtn] = data[downBtn-1];
		downBtn--;
	}
}





/********************************************

		ShiftLeft()

*********************************************/

static void ShiftLeft( push_label, down_label, data )
int		push_label, down_label;
puzzleData	data;
{	int	pushBtn = push_label-TTLL, downBtn = down_label - TTLL;
	while( downBtn != pushBtn ) {
		data[downBtn] = data[downBtn+1];
		downBtn++;
	}
}






/********************************************

		ShiftUp()

*********************************************/

static void ShiftUp( push_label, down_label, data )
int		push_label, down_label;
puzzleData	data;
{	int	pushBtn = push_label-TTLL, downBtn = down_label - TTLL;
	while( downBtn != pushBtn ) {
		data[downBtn] = data[downBtn+4];
		downBtn+=4;
	}
}






/********************************************

		ShiftDown()

*********************************************/

static void ShiftDown( push_label, down_label, data )
int		push_label, down_label;
puzzleData	data;
{	int	pushBtn = push_label-TTLL, downBtn = down_label - TTLL;
	while( downBtn != pushBtn ) {
		data[downBtn] = data[downBtn-4];
		downBtn-=4;
	}
}






/********************************************

		UpdatePuzzle()

*********************************************/

static void UpdatePuzzle( fp, data )
Form		fp;
puzzleData	data;
{	char	buff[256], buff2[256];
	int	btn;
	for( btn = 0; btn < NUM_BTNS; btn++ ) {
		FIg_get_text( fp, btn+TTLL, buff );
		sprintf(buff2,data[btn]?"%d":"", data[btn]);
		if( !data[btn] )	FIg_set_state( fp, btn+TTLL, 1 );
		if( strcmp(buff2,buff) ) {
			FIg_erase( fp, btn+TTLL );
			FIg_set_text( fp, btn+TTLL, buff2 );
			FIg_display( fp, btn+TTLL );
		}
	}
}





/********************************************

		CheckWin()

*********************************************/

int CheckWin( fp, data )
Form		fp;
puzzleData	data;
{	int	btn;
	for( btn = 0; btn < NUM_BTNS-1; btn++ )
		if( btn+1 != data[btn] )	return 0;
	FIg_set_text( fp, FI_MSG_FIELD, "You win!" );
    return 1;
}

int PushButton( fp, label, down, data )
Form		fp;
int		label, down;
puzzleData	data;
{	int	drow, dcol, prow, pcol;
	if( label == down ) {
		FIg_set_state( fp, label, 1 );
		return 1;
	}
	drow = (down-TTLL) / 4;		dcol = (down-TTLL) % 4;
	prow = (label-TTLL) / 4;	pcol = (label-TTLL) % 4;
	if( drow == prow ) {
		if( pcol > dcol )	ShiftLeft( label, down, data );
		else			ShiftRight( label, down, data );
	} else {
		if( prow > drow )	ShiftUp( label, down, data );
		else			ShiftDown( label, down, data );
	}
	FIg_set_state( fp, down, 0 );
	FIg_set_state( fp, label, 1 );
	data[label-TTLL] = 0;
	UpdatePuzzle( fp, data );
	CheckWin( fp, data );
	return 1;
}





/********************************************

		puzzle_note()

*********************************************/

/* ARGSUSED */
int puzzle_note( f_label, g_label, value, fp )
int	f_label, g_label;
double	value;
Form	fp;
{	puzzleData	*data;
	int		downBtn;

	FIg_set_text( fp, FI_MSG_FIELD, "" );
	FIf_get_user_pointer( fp, &data );

	downBtn = GetDown( *data );

	switch( g_label ) {
	case TTLL:
		if( downBtn == g_label || downBtn == TTL || downBtn == TTR ||
		    downBtn == TTRR || downBtn == TLL || downBtn == BLL ||
		    downBtn == BBLL )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case TTL:
		if( downBtn == g_label || downBtn == TTLL || downBtn == TTR ||
		    downBtn == TTRR || downBtn == TL || downBtn == BL ||
		    downBtn == BBL )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case TTR:
		if( downBtn == g_label || downBtn == TTL || downBtn == TTLL ||
		    downBtn == TTRR || downBtn == TR || downBtn == BR ||
		    downBtn == BBR )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case TTRR:
		if( downBtn == g_label || downBtn == TTL || downBtn == TTR ||
		    downBtn == TTLL || downBtn == TRR || downBtn == BRR ||
		    downBtn == BBRR )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case TLL:
		if( downBtn == g_label || downBtn == TTLL || downBtn == TL ||
		    downBtn == TR || downBtn == TRR || downBtn == BLL ||
		    downBtn == BBLL )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case TL:
		if( downBtn == g_label || downBtn == TTL || downBtn == BL ||
		    downBtn == BBL || downBtn == TLL || downBtn == TR ||
		    downBtn == TRR )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case TR:
		if( downBtn == g_label || downBtn == TRR || downBtn == TTR ||
		    downBtn == BR || downBtn == TLL || downBtn == TL ||
		    downBtn == BBR )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case TRR:
		if( downBtn == g_label || downBtn == TL || downBtn == TR ||
		    downBtn == TTRR || downBtn == TLL || downBtn == BRR ||
		    downBtn == BBRR )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case BLL:
		if( downBtn == g_label || downBtn == TTLL || downBtn == TLL ||
		    downBtn == BL || downBtn == BR || downBtn == BRR ||
		    downBtn == BBLL )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case BL:
		if( downBtn == g_label || downBtn == TTL || downBtn == TL ||
		    downBtn == BRR || downBtn == BLL || downBtn == BR ||
		    downBtn == BBL )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case BR:
		if( downBtn == g_label || downBtn == TTR || downBtn == TR ||
		    downBtn == BBR || downBtn == BLL || downBtn == BL ||
		    downBtn == BRR )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case BRR:
		if( downBtn == g_label || downBtn == TTRR || downBtn == TRR ||
		    downBtn == BBRR || downBtn == BLL || downBtn == BL ||
		    downBtn == BR )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case BBLL:
		if( downBtn == g_label || downBtn == TTLL || downBtn == TLL ||
		    downBtn == BLL || downBtn == BBL || downBtn == BBR ||
		    downBtn == BBRR )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case BBL:
		if( downBtn == g_label || downBtn == TTL || downBtn == TL ||
		    downBtn == BL || downBtn == BBLL || downBtn == BBR ||
		    downBtn == BBRR )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case BBR:
		if( downBtn == g_label || downBtn == TTR || downBtn == TR ||
		    downBtn == BR || downBtn == BBLL || downBtn == BBL ||
		    downBtn == BBRR )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case BBRR:
		if( downBtn == g_label || downBtn == TTRR || downBtn == TRR ||
		    downBtn == BRR || downBtn == BBLL || downBtn == BBL ||
		    downBtn == BBR )  PushButton( fp, g_label, downBtn, *data );
		else {
			FIg_set_state( fp, downBtn, 1 ); /* keep down */
			FIg_set_state( fp, g_label, 0 ); /* keep up   */
		}
		break;
	case 34:
		FIg_set_state( fp, downBtn, 0 );
		RandomPuzzle( *data );
		UpdatePuzzle( fp, *data );
		break;
	case FI_ACCEPT:
		if( data )	free( data );
		FIf_delete( fp );
		break;
	}

    return 0;
}






/*******************************************

		InitPuzzle()

********************************************/

int InitPuzzle( )
{
	puzzleData 	*data;
	Form		fp;
	int		sts, btns;
	time_t clock;
	struct tm *clk;

	clk = localtime( &clock );
	sts = clk->tm_sec + 60 * ( clk->tm_min + 60 * clk->tm_hour );
	srand( sts );

	sts = FIf_new( 555, "puzzle_form", puzzle_note, &fp );
	if( sts ) {
		fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
		return sts;
	}
	sts = FIf_display( fp );

	data = (puzzleData*) malloc( sizeof( puzzleData ) );
	for( btns = 0; btns < NUM_BTNS-1; btns++ )
		(*data)[btns] = btns+1;
	(*data)[NUM_BTNS-1] = 0;

	UpdatePuzzle( fp, *data );
	sts = FIf_set_user_pointer( fp, data );
	return sts;
}





/***********************************************

		main()

***********************************************/

main (argc, argv)
int argc;
char *argv[];
{
   char *display_name = "", *ptr;
   int i, sync = 0;
   int	sts;

   /** Find the display argument after 0th argument **/

   /** Set up program name **/


   ptr = strrchr (argv[0], '/');
   if (ptr)
   {
	  argv[0]= ptr + 1;
   }

   /*** Parse the command line ***/

   for (i = 1; i < argc; i++)
   {
	  if (argv[i][0]!= '-')
		 Syntax (argv[0], argv[i]);

	  switch (argv[i++][1])
	  {
	  case 'd':
		 display_name = argv[i];
		 break;

	  case 's':
		 sync = 1;
		 i--;
		 break;

	  default:
		 Syntax (argv[0], argv[i]);
	  }
   }	/** END for **/

   if ((display = XOpenDisplay (display_name)) == None)
   {
	  fprintf (stderr , "%s: cannot connect to X server %s\n", XDisplayName (display_name));
	  exit (-1);
   }

   if (sync)
   {
	  Sync_on ();
   }

   FSEnter ( display, 0 );

   FI_enter (display, DefaultColormap(display,DefaultScreen(display)) , 32);

	FI_set_form_path( ".:/usr/ip32/forms/examples/puzzle" );

	FI_set_symbol_path( ".:/usr/ip32/forms/examples/puzzle" );

	sts = InitPuzzle( );

	if( !sts )
		FI_process_forms( );

	XCloseDisplay( display );
}

