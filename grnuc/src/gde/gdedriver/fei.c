/*******************************/
/* 	     fei.c	       */
/* FORMS ENVIRONMENT INTERFACE */
/*******************************/

/*
$Log: fei.c,v $
Revision 1.1.1.1  2001/12/17 22:39:36  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:17:11  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:31:32  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  18:00:19  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/07  00:05:11  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:41:19  root
 * COMMENT : Corresponds to Rel201.1 in 2.0.1 RCS
 *
 * Revision 201.1  1992/07/13  20:43:24  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>
#include "tools.h"

#include "FI.h"

#include "FEI.h"

#include "FIappl.h"

#ifndef TRUE
#define TRUE    1
#endif

#ifndef FALSE
#define FALSE   0
#endif

#define ABS(x)	((x) < 0 ? -(x) : (x))



#define SYMLOC "./"
#define FORMLOC "./"


/***********************************************************************

IMPORTANT:
	Refer to the User Interface Programmer's Overview for
	information on how to tailor the form and menu environments to
	your particular application's needs.

***     USE the fei.c located in new_demo/src a the templete to use for 
	your own application.

***********************************************************************/

static struct sym_st {
	
		char symbol_file[15];
		int  font_id;
		
		} * symbols;
		


static struct font_st {
		char fontname[15];
		int	bodysize;
		int	font_id;

		} * fonts;


static int  symbol_array_size;
static int  font_array_size;

static next_font;
static next_symbol;


extern char key_buf[256];


/**********************************************************************/
/* find_closest_font - Given a font name and bodysize, this will try  */
/*		       to find the font_id of the pre-loaded font of  */
/*		       that name, having the closest size to the one  */
/*		       requested.				      */
/* It returns 1 if it finds a suitable font, else it returns 0.	      */
/**********************************************************************/
int find_closest_font ( fontname, bodysize, font_id, actual_bodysize )
  char  * fontname;	   /* input  -- name of font requested	      */
  float	  bodysize;	   /* input  -- size of font requested	      */
  int   * font_id;	   /* output -- font_id of closest match font */
  float * actual_bodysize; /* output -- size of closest match font    */
{
  float   size_diff;
  float   min_size_diff; /* If the font requested is not pre-loaded,  */
			 /*   then this is the difference in the size */
			 /*   asked for and the size of the closest   */
			 /*   pre-loaded font to that size.	      */
  int     min_size_diff_font_index;
			 /* If the font requested is not pre-loaded,  */
			 /*   then this is the index into fonts[]     */
			 /*   of the array which is closest in size   */
			 /*   to the font requested.		      */
  int	  ii;

  min_size_diff = 10000;
  min_size_diff_font_index = -1;

  for ( ii = 0; ii < next_font ; ii ++ )
    {
		/*** Only look at the fonts of that name ***/
      if ( ! strcmp ( fonts[ii].fontname, fontname ) )
        {
	  size_diff = bodysize - fonts[ii].bodysize ;

	  if ( ABS ( size_diff ) <=  0.5 )
	    {   /*** this is "close enough for gov't work" ***/
	       min_size_diff_font_index = ii;
	       break;
	    }
	  else
	    {	/*** If two fonts are both as good a match to   ***/
		/***   the requested font, take the smaller one ***/
	      if ( ABS( ABS(min_size_diff) - ABS(size_diff) ) <= 1.0 )
	        {
		  if ( size_diff > 0 )
		    {
			min_size_diff = size_diff;
			min_size_diff_font_index = ii;
		    }
		}
	      else
		{ /*** if this size is a better match, remember it ***/
		  if ( ABS ( size_diff ) < ABS ( min_size_diff ) )
		    {
		      min_size_diff = size_diff;
		      min_size_diff_font_index = ii;
		    }
		}
	    }

	}	/* end for fonts having same name */

    }  /* end for loop thru fonts[] */

  if ( min_size_diff_font_index != -1 )
    {
	* font_id = fonts[min_size_diff_font_index].font_id;
	* actual_bodysize = fonts[min_size_diff_font_index].bodysize;

	return TRUE;
    }

  return FALSE;

} /* end find_closest_font() */



/**********************************************************************/
/* load_font - loads a (bs) font into memory, and makes it known to   */
/*	       the forms system.				      */
/**********************************************************************/
int load_font ( fontname, bodysize )
  char * fontname;
  int     bodysize;
{
  int     status;

  char    path[100];
  char    font[16];
	
  sprintf ( font, "%s.%d", fontname, bodysize );	

  strcpy ( path, "/usr/ip32/resrc/bsfont/" );	
  strcat ( path, font );					

  status = Load_symbol_file  ( path, &fonts[next_font].font_id );
  if ( status )
    {
      fprintf(stderr, "FEI: Unable to load font :%s: bodysize %d\n",
						fontname, bodysize );

      return ( FALSE );		
    }

	/* store the name and fontsize in the font array */
		
  strcpy ( fonts[next_font].fontname, fontname );		
  fonts[next_font].bodysize = (int)bodysize;
  next_font++;

		/* Check the font array size */

  if ( next_font >= font_array_size )
    {
	/* Make the font array larger */

      font_array_size += 10;

      fonts = (struct font_st *) realloc ( fonts,
			 font_array_size * sizeof ( struct font_st ) );
    }

  return ( FI_SUCCESS );
}


/* This function loops through the symbol array and checks to see     */
/* if there is a matching symbol file that has already been loaded.   */

int symbol_available ( symbol_file, font_id )
char * symbol_file;
int  * font_id;
{
  int	x;

  for ( x = 0; x < next_symbol; x++ )
    {
	if ( ( strcmp ( symbol_file, symbols[x].symbol_file ) == 0 ) )
	  {
		*font_id = symbols[x].font_id;
		return ( TRUE );
	  }
    }	
  return ( FALSE );
}



/**********************************************************************/
/* load_symbol - loads a symbol file into memory, and makes it known  */
/*	       to the forms system.				      */
/**********************************************************************/
int load_symbol ( symbol_file )
  char * symbol_file;
{
  int  status;

  char path[200];

/*******************************************

	I ADDED THE PATHNAME AS A STRING CONSTANT DEFINE AT TOP OF FILE.

				Steve Lanham 6-22-89

********************************************/

  strcpy ( path, SYMLOC );
  strcat ( path, symbol_file );

  status = Load_symbol_file ( path, &symbols[next_symbol].font_id );

  if ( status )
    {
	fprintf(stderr, "FEI: Unable to load font :%s:\n",symbol_file );
	return ( FALSE );		
    }
  else
    {
	/* Store the name of the symbol in my symbol array */

	strcpy ( symbols[next_symbol].symbol_file, symbol_file );
	next_symbol ++;

		/* Check the size of the symbol array */

	if ( next_symbol >= symbol_array_size )
	  {
			/* Make the symbol array larger */

	    symbol_array_size += 10;
			
	    symbols = ( struct sym_st * ) realloc ( symbols,
			symbol_array_size * sizeof ( struct sym_st ) );
	  }

	return ( TRUE );	
    }
}



/* This function is called when the Forms system needs a slot         */
/* number for a color.  The slot number of the color requested for    */
/* the given vs should be returned. This is called each time a gadget */
/* is going to display so if you dynamically load a color table, then */
/* it is possible to tell the gadget the slot of the new colors       */
/* loaded if requested. The colors are defined in FI.h		      */
   
int FEI_translate_color ( vs, color )
int vs;
int color;		
{
	switch ( color )
	{
		case FI_RED:
			return ( 12 );
		
		case FI_BLUE:
			return ( 10 );
	
		case FI_YELLOW:
			return ( 4 );
					
		case FI_BLACK:
			return ( 0 );
	
		case FI_DK_GREY:
			return ( 6 );
					
		case FI_MED_GREY:
			return ( 2 );
			
		case FI_LT_GREY:
			return ( 5 );		
			
		case FI_GREEN:
			return ( 9 );
			
		case FI_OFF_WHITE:
			return ( 1 );
			
		default: 
			return ( 1 );
	}
}



/* This function allows the application to set up any type of editing */
/* for the keyin gadgets.  The gadget will call this function with    */
/* each character of input.  This is where you can map the control    */
/* characters to #defines in "FI.h" for the particular control        */
/* sequence needed.						      */

char FEI_map_character ( character )
char *character;
{
    switch ( *character )
    {
        case C_UP    :	*character = FI_UP;
			return (1);
        case C_DOWN  :  *character = FI_DOWN;
			return (1);
        case CTRL_L  :
        case C_LEFT  :	*character = FI_LEFT;
			return (1);
        case CTRL_R  :
        case C_RIGHT :	*character = FI_RIGHT;
			return (1);
	case DEL     :	*character = FI_BS_DEL;
			return (1);

        case CTRL_P  :
        case CTRL_N  :
        case CTRL_F  :
        case CTRL_B  :
        case CTRL_A  :
        case CTRL_E  :
        case CTRL_D  :
        case CTRL_Y  :
        case CTRL_K  :
        case CTRL_C  :
        case CTRL_T  :	return (1);

	case ENTER   :  *character = CR;
			return (0);

	default	:	return (0);
    }
}


int FEI_get_keyboard_data ( character, count )
char * character;
int * count;
{
    
    int i;

    Get_keyboard_data ( count );
    for ( i = 0; i < *count; i++ )
	character[i] = key_buf[i];
}



	
int FEI_process_data ( cmd_type, cmd )
int    cmd_type;
char * cmd;
{
	fprintf(stderr,"CMD_TYPE %d  CMD :%s:\n",cmd_type,cmd );
}



int FEI_calc_text ( font_id, text, length, height, width, line_spacing )
int	font_id;
char    * text;
int	length;
int     * height;
int     * width;
int  	* line_spacing;
{
	int	status;	
	
			/* BSfont */

	status = Inq_string_width ( font_id, text, length, width );
	if ( status )
	  {
	    fprintf ( stderr,"ERROR STRING WIDTH FONT %d\n",status);	
	  }

	status = Inq_font ( font_id, height, &status, &status );
	if ( status )
	  {
	    fprintf ( stderr,"ERROR INQ FONT %d\n",status);	
	  }
			
	*line_spacing = *height;

	return ( status );
}




/* This method draws the font */

int FEI_draw_text ( window, font_id,  text, length, xpos, ypos,
		    font_height, nx, ny )
int	window;
int	font_id;
char *  text;
int	length;
int     xpos;
int     ypos;
int     font_height;
int     * nx;
int     * ny;
{
  int	status;
	
			/* BSfont */

  status = drawsymbols ( window, font_id, xpos, ypos, text, length );

  if ( status )
	fprintf ( stderr, "ERROR drawsymbols %d\n",status );

  return ( status );
}





/* This function returns the path to the font specified in font_name */

int FEI_find_symbol_path_and_id ( path, symbol_name, symbol_id )
char * path;
char * symbol_name;
int  * symbol_id;
{

/**************************************************

	VALUE COPIED INTO path IS NOW A STRING CONSTANT DEFINED AT
	TOP OF FILE.

		steve lanham 6-22-89

***************************************************/

  strcpy ( path, SYMLOC );
  strcat ( path, symbol_name );

		
  if ( ! symbol_available ( symbol_name, symbol_id ) )
    {
	/* At this point the symbol has not been loaded so call	*/
	/* load_symbol() to load this symbol.			*/

	if ( load_symbol ( symbol_name ) )
	  {
	    /* Calling symbol_available() will return	    */
	    /* the symbol_id of the currently loaded symbol */

	      if ( ! symbol_available ( symbol_name, symbol_id ) )

		/* If this point is reached then the symbol was */
		/*   unable to be loaded for some reason.	*/

		fprintf(stderr,
		  "ERROR Loading symbol file %s\n",symbol_name);
		else
			return ( FI_SUCCESS );
	  }
    }

  return ( FI_SUCCESS );
}



/* This function is called when a gadget on the form needs a font_id  */
/* for the font specified.  When the form is scaled then each gadget  */
/* will asked for the font with the appropriate scaled bodysize.      */

/* This function is very critical to the performance of your system.  */
/* This is where you determine what fonts you will allow the forms    */
/* system to have.						      */

/* The forms in your system by default should have been designed      */
/* using a set of standard fonts your application has chosen to use.  */
/* When a form is scaled ( if you allow scaling forms in your system )*/
/* the text will request the new font_id for the scaled text.	      */

/* You will not want to give the forms system every possible bodysize */
/* of a font it requests, since BSfonts have to be pre-stoked before  */
/* running and fontserver fonts take several seconds to calculate.    */

/* Therefore, this routine calls the find_closest_font() function     */
/* which loops through the array of fonts ( which were loaded during  */
/* calls to FEI_enter() by the load_font() function ), looking for    */
/* the font of the requested name having the closest bodysize to the  */
/* size requested.						      */

int FEI_find_font_id ( fontname, bodysize, font_id, actual_bodysize,
							gadget_type )
  char 	* fontname;		/* input & output */
  float	  bodysize;		/* input	  */
  int   * font_id;		/* output	  */
  float	* actual_bodysize;	/* output	  */
  int  	  gadget_type;		/* input	  */
{
  char	  local_fontname[15];	  /* local array to hold font name    */

    	/*** field gadgets MUST have a mono-spaced font ***/
  if ( gadget_type == FI_FIELD  ||  gadget_type == FI_MULTI_COL )
    {
	strcpy ( local_fontname, "mono821" );
    }					
  else
    {
	strcpy ( local_fontname, fontname );
    }		

	/* Check to see if the font requested is loaded already, */
	/* in a bodysize close to the one requested.		 */

  if ( ! find_closest_font ( local_fontname, bodysize, font_id,
						actual_bodysize ) )

    {	/*** The font name requested was not available in ANY size ***/
	/*** Now, if you're using fontserver, you may want to      ***/
	/*** actually generate the font ( but that takes several   ***/
	/*** seconds ), and make it available to the forms system  ***/
	/*** by calling load_font().				   ***/


	/*** This code will simply try to load "mono821" of the    ***/
	/*** requested bodysize, in place of the requested font,   ***/
	/*** and hope that it's there.				   ***/

        if ( ! find_closest_font ( "mono821", bodysize, font_id,
						actual_bodysize ) )
	  {
            if ( ! find_closest_font ( "swiss742", bodysize, font_id,
						actual_bodysize ) )
	      {
				/*** Give up!  ***/
		fprintf ( stderr,
			"\nFEI: Cannot load font '%s' size %5.2f\n",
			local_fontname, bodysize );
	      }
	  }
      }

  return ( FI_SUCCESS );
}



int FEI_find_form ( path, form_name )
char * path;
char * form_name;
{
  strcpy ( path, FORMLOC );
  strcat ( path, form_name );
  return ( FI_SUCCESS );	
}



int FEI_activate_help ( )
{
  fprintf ( stderr, "Activating help...\n");
}



int FEI_set_window_attr ( window )
int    window;			
{
  return ( FI_SUCCESS );	    
}




int FEI_enter ()
{
    float dummy;

    struct FEI_func_st func_st;
    	
    func_st.FEI_translate_color    = FEI_translate_color; 
    func_st.FEI_find_symbol_path_and_id   = FEI_find_symbol_path_and_id;
    func_st.FEI_find_form          = FEI_find_form;   
    func_st.FEI_process_data       = FEI_process_data;         
    func_st.FEI_set_window_attr    = FEI_set_window_attr;     
    func_st.FEI_calc_text          = FEI_calc_text;             
    func_st.FEI_draw_text    	   = FEI_draw_text;                 
    func_st.FEI_find_font_id       = FEI_find_font_id;
    func_st.FEI_get_keyboard_data  = FEI_get_keyboard_data;
    func_st.FEI_activate_help      = FEI_activate_help;
    func_st.FEI_map_character      = FEI_map_character;

    FI_setup_functions ( &func_st );	

	    /* Initialize symbol and font arrays */

	    /* Set symbol array initially to 20 */

    symbol_array_size = 20;
    symbols = ( struct sym_st * )  calloc ( symbol_array_size,
					sizeof ( struct sym_st ) );

	    /* Set symbol array initially to 20 */

    font_array_size = 20;
    fonts   = ( struct font_st * ) calloc ( font_array_size,
					sizeof ( struct font_st ) );

    next_font = 0;

    	/* load BS FONTS */

    load_font ( "swiss742b", 14 );
    load_font ( "swiss742b", 18 );    
    load_font ( "swiss742b", 24 );
    load_font ( "swiss742b", 30 );    
    load_font ( "swiss742b", 36 );    

    load_font ( "mono821", 14 );    
    load_font ( "mono821", 18 );    
    load_font ( "mono821", 24 );    

    next_symbol = 0;    

    load_symbol ( "FIsym" );    

    return ( FI_SUCCESS );	       
}  
