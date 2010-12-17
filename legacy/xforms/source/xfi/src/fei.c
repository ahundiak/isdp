#include <Xlib.h>
#include "FImin.h"

#include "FIappl.h"
#include "FIbtn.h"
#include "FIfield.h"
#include "FEI.h"

#include <X11/keysym.h>

#include <stdio.h>

#include "FS.h"         /* dmb:01/11/93: Was FSX.h */
#include "FSBmap.h"     /* dmb:01/11/93: Was FSXBmap.h */

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

#define COLOR_TABLE_SIZE 14
/*#define FS_TO_X_LINE_SPACING_FUDGE_FACTOR 0.90*/
#define FS_TO_X_LINE_SPACING_FUDGE_FACTOR 1.2


/* GMD 3/3/92   Changed colors to match EMS request  */

static unsigned short _FI_color_table[COLOR_TABLE_SIZE][3]=
{
  /* red, green, blue */

    { 61166, 61166, 56797 },
    { 34952, 34952, 34952 },
    { 00000, 00000, 00000 },
    { 65535, 65535, 00000 },
    { 48059, 48059, 48059 },
    { 21845, 21845, 21845 },
    { 65535, 65535, 65535 },
    { 65535, 00000, 00000 },
    { 00000, 65535, 00000 },
    { 00000, 00000, 65535 },
    { 65535, 65535, 48059 },
    { 56797, 00000, 00000 },
    { 00000, 48059, 00000 },
    { 00000, 00000, 52428 }
};

static unsigned long _FI_pixels[COLOR_TABLE_SIZE];

/* extern int _FI_load_symbol_file(); */

#if defined(SCO)
int FSEnter(int flags)
{
}

int FSNewFont(FontSpec *fontSpec, RangeSpec rangeSpec[], FontId *font)
{
}

int FSReadCharMapFile(char *fileName, CharMapId *charMapId)
{
}

int FSGetTextVect(FontId font, char *text, int length, double x, double y, 
	double *nx, double *ny)
{
}

int FSXDrawText(/*Display display, int screen, Window window, GC gc,
	FontId font, char *text, int length, double x, double y, 
	double *nx, double *ny*/)
{
}

int FSGetBmapInfo(BmapId bmap, BmapInfo *info)
{
}
#endif


int _FI_iforms_strlen (char *s,
                       int font_type)
{
  int count = 0;


  if ( ! s )
    {
      return -1;
    }

  if ( font_type == FI_FS_7_OR_16_BIT_FONT_TYPE )
    {
      while (*s)
	{
	  if ( sbitset(*s) )
	    {
			s++;
	    }
	  s++;
	  count++;
	}
    }
  else	/* font_type = 0,1 ==> 8 bits per character */
    {
      count = strlen (s);
    }

  return count;
}



int _FI_move_index (unsigned char *string,
                    int            index,
                    int            no_char,
                    int            font_type)
{
  int pres_char;
  int new_char;
  int pos;

  pres_char = 0;
  pos = 0;

  while ( pos < index )
    {
      if ( (font_type == FI_FS_7_OR_16_BIT_FONT_TYPE )		&&
				(sbitset(string[pos]))		 )
	{
	  pos += 2;
	}
      else
	{
	  pos += 1;
	}
      pres_char += 1;
    }

  new_char = pres_char + no_char;

  if ( new_char < 0 )
    {
      return (-1);
    }

  pos = 0;
  pres_char = 0;
  while ( (pres_char < new_char) && (string[pos]!= '\0') )
    {
      if ( (font_type == FI_FS_7_OR_16_BIT_FONT_TYPE )		&&
				(sbitset(string[pos]))		 )
	{
	  pos += 2;
	}
      else
	{
	  pos += 1;
	}
      pres_char += 1;
    }
  return (pos);
}



int _FI_symbol_available (char  *symbol_file,
                          int   *font_id,
                          char  *path)
{
  int xx;

  *font_id = -1;   /* In case it can't find it    GMD 4/9/91 */

  for ( xx = 0; xx < _FI_next_symbol; xx++ )
    {
      if ( (strcmp (symbol_file, _FI_symbols[xx].symbol_file) == 0) )
	{
	  *font_id = xx;
	  strcpy ( path, _FI_symbols[xx].path );
	  return ( TRUE );
	}
    }
  return (FALSE);
}


int _FI_font_available (char  *font_file,
                        int    bodysize,
                        Font  *font_id,
                        int   *font_type)
{
  int xx;


  for ( xx = 0; xx < _FI_next_font; xx++ )
    {
      if (	(strcmp (font_file, _FI_fonts[xx].fontname) == 0) &&
		(_FI_fonts[xx].bodysize == bodysize)		   )
	{
	  *font_id   = _FI_fonts[xx].font_id;
	  *font_type = _FI_fonts[xx].font_type;

	  return ( TRUE );
	}
    }

	/****************************/
	/*** didn't find the font ***/
	/****************************/

  *font_id   = (Font) -1; /* dmb:09/27/91:typecast */
  *font_type = -1;

  return ( FALSE );
}



int _FI_load_symbol (char  *symbol_file,
                     char  *path)
{
  int xx;
  int status = 1;

  for ( xx = 0; xx < _FI_symbol_path_index; xx++ )
    {
      strcpy ( path, _FI_symbol_path[xx] );
      strcat ( path, "/" );
      strcat ( path, symbol_file );

      status = _FI_load_symbol_file ( path,
				&(_FI_symbols[_FI_next_symbol]) );
      if ( ! status )
	{
	  break;
	}
    }

	/******************************************/
	/*** look in the default directories	***/
	/******************************************/
  if ( status )
    {
     strcpy ( path, "./" );
     strcat ( path, symbol_file );

     status = _FI_load_symbol_file ( path, &(_FI_symbols[_FI_next_symbol]));
    }

  if ( status )
    {
/* dmb:04/23/93:Adding for CR#249202403 */
#if defined(FI_USE_INGRHOME)
     char ingr_root[256] = {NULL};

     /* Get ingr_root once */
     FI_get_ingr_root(ingr_root);

     strcpy (path, ingr_root);
     strcat (path,"/xformsrt/");
#else
     strcpy ( path, "/usr/lib/xformsrt/" );
#endif
/* dmb:04/23/93:End adding for CR#249202403 */

/* dmb:04/09/93:original */
/*     strcpy ( path, "/usr/lib/xformsrt/" ); */

     strcat ( path, symbol_file );

     status = _FI_load_symbol_file ( path, &(_FI_symbols[_FI_next_symbol]));
    }

  if ( status )
    {
     strcpy ( path, "../sym/" );
     strcat ( path, symbol_file );

     status = _FI_load_symbol_file ( path, &(_FI_symbols[_FI_next_symbol]));
              /* 0 = success */
    }

      /* Store the id into the table */

  if ( ! status )
    {
     /* Store the symbol_name in the table */

     strcpy ( _FI_symbols[_FI_next_symbol].symbol_file, 
						symbol_file );

		/* Calloc space for path to symbol */

     _FI_symbols[_FI_next_symbol].path =
			calloc ( strlen ( path ) + 2, sizeof ( char ) );

		/* Store the path where the symbol was found */

     strcpy ( _FI_symbols[_FI_next_symbol].path, path );


     _FI_next_symbol++;

     if ( _FI_next_symbol >= _FI_symbol_array_size )
	{
      _FI_symbols = ( struct _FI_sym_st * ) 
				realloc ( _FI_symbols,
				   ( _FI_symbol_array_size + 5 ) * 
					sizeof ( struct _FI_sym_st ) );

      memset ( &_FI_symbols[_FI_symbol_array_size], 0,
				 5 * sizeof ( struct _FI_sym_st ) );

      _FI_symbol_array_size += 5;
			
	}

    return ( TRUE );	
    }

 return ( FALSE );
}


    /*** X11-5/9/90-This was added to improve performance when	***/
    /*** translating colors.  If the old routine is still there ***/
    /*** you will notice that the XAllocColor() routine was	***/
    /*** called every time.  FI_translate_color()is called ALOT ***/
    /*** and this needed to be stream-lined.			***/

int _FI_colormap_notify (Colormap  cmap,
                         int       cmap_size)
{
  int ii;
  int num_color_slots;

  if ( cmap != _FI_cmap )
    {
      unsigned long mask = CWColormap;
      XSetWindowAttributes win_attr;

      _FI_cmap = cmap;
      win_attr.colormap = cmap;

      for ( ii = 0; ii < MAX_WINDOW; ii++ )
	{
	  if (FI_forms[ii])
	    {
	      XChangeWindowAttributes ( _FI_display,
			      FI_forms[ii]->Xwindow, mask, &win_attr );
	    }
	}
    }

   num_color_slots = DisplayCells (_FI_display, DefaultScreen(_FI_display));

   if (num_color_slots < 32)
      cmap_size = 16;

  if ( cmap == DefaultColormap(_FI_display, DefaultScreen(_FI_display)) &&
       (num_color_slots > 31))
    {
      XColor x_color;

      for ( ii = 0; ii < COLOR_TABLE_SIZE; ii++)
      {
	 x_color.pixel	= ii;
	 x_color.red	= _FI_color_table[ii][0];
	 x_color.green  = _FI_color_table[ii][1];
	 x_color.blue	= _FI_color_table[ii][2];
	 x_color.flags  = DoRed | DoGreen | DoBlue;

	 if ( ! XAllocColor ( _FI_display, cmap, &x_color ) )
	 {
/*	 {  dmb:03/25/93: This may be the problem! */
	  /**	sml:03-03-93
			don't pring out this message; failing here won't affect
			colors anyway
	   fprintf ( stderr,
	      "XFORMS: XAllocColor() failed with ii=%d, pixel = %d\n",
	      ii, x_color.pixel );
	  **/
	 }
         _FI_pixels[ii]= x_color.pixel;      
       }  
    }
  else	/** Custom Colormap **/
    {
      XColor *cmap_table;
      int dist, jj;
      double sum, min;

      cmap_table = (XColor *) calloc (sizeof (XColor), cmap_size);

      if ( ! cmap_table )
	{
	  return (FI_SUCCESS);
	}

      for ( ii = 0; ii < cmap_size; ii++ )
	{
	  cmap_table[ii].pixel = ii;
	}

      if ( XQueryColors ( _FI_display, cmap, cmap_table, cmap_size)
							== BadValue )
	{
	  fprintf ( stderr, "XFORMS:XQueryColors()failed\n" );
	}

      /* GMD 3/3/92   Started the search at slot one due to EMS request */

      for ( ii = 0; ii < COLOR_TABLE_SIZE; ii++ )
	{
	  /*** <pds-2/21/91> Could not use DBL_MAX on SUN	    ***/
	  /*** so this is the maximum value that could be	    ***/
	  /*** generated since the color values are unsigned shorts ***/

	  min = 3.0 * (double) INT_MAX * (double) INT_MAX;

	  for ( jj = 1; jj < cmap_size; jj++ )
	    {
	      dist = (int) cmap_table[jj].red -
					(int) _FI_color_table[ii][0];

	      sum = (double) dist * (double) dist;

	      dist = (int) cmap_table[jj].green -
					(int) _FI_color_table[ii][1];

	      sum += ((double) dist * (double) dist);

	      dist = (int) cmap_table[jj].blue -
					(int) _FI_color_table[ii][2];

	      sum += (double) dist * (double) dist;

	      if ( sum < min )
		{
		  min = sum;
		  _FI_pixels[ii]= cmap_table[jj].pixel;

		  if ( ! min )	/* exact match */
		    {
		      break;
		    }
		}
	    }
	}	/* END for ii */

      if (num_color_slots < 32)
      {
         /* Map the 14 logical colors down to 5 actual colors  */
         /* because the range is so restricted on the ROP.     */
         /* GMD 3/18/92                                        */

         _FI_pixels[FI_DK_GREY] = _FI_pixels[FI_BLACK];
         _FI_pixels[FI_BLUE] = _FI_pixels[FI_BLACK];
         _FI_pixels[FI_DK_RED] = _FI_pixels[FI_BLACK];
         _FI_pixels[FI_DK_GREEN] = _FI_pixels[FI_BLACK];
         _FI_pixels[FI_DK_BLUE] = _FI_pixels[FI_BLACK];

         _FI_pixels[FI_GREEN] = _FI_pixels[FI_YELLOW];
         _FI_pixels[FI_LT_YELLOW] = _FI_pixels[FI_YELLOW];
         _FI_pixels[FI_RED] = _FI_pixels[FI_YELLOW];

         _FI_pixels[FI_WHITE] = _FI_pixels[FI_OFF_WHITE];

         /* Leave FI_LT_GREY, FI_MED_GREY, FI_OFF_WHITE, FI_BLACK, and  */
         /*       FI_YELLOW definitions alone.   GMD 3/18/92            */
      }

      if ( cmap_table )
	{
	  free ( cmap_table );
	}
    }

  return ( FI_SUCCESS );
}


/* ARGSUSED */
unsigned long _FI_translate_color (int screen,
                                   int color)
{
  return ( _FI_pixels[color % 14] );
}


int _FI_map_character (XKeyEvent  *key,
                       char       *character)
{
  KeySym keysym;
  XComposeStatus status;

   /*****************************************************/
   /* sml:11-07-94:TR 249407255                         */
   /*  Initialize these variables for sun XGL machine   */
   /*  Otherwise those variables get bogus values in    */
   /*  for every other character that is entered.  That */
   /*  cause every other character not to be displayed. */
   /*****************************************************/

  keysym = 0;
  status.compose_ptr = NULL;
  status.chars_matched = 0;



  /** 256 is the size of the buffer in _FI_fld_track_keyboard **/

  memset (character, 0, 256);

  XLookupString (key, character, 256, &keysym, &status);

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
}


			/*** OBSOLETE in X/Forms ??? ***/
/* ARGSUSED */
int _FI_get_keyboard_data (char  *character,
                           int   *count,
                           int    font_type)
{
  * count = 1;

  return ( FI_SUCCESS );
}


int _FI_calc_text (Font   font_id,
                   char  *text,
                   int    length,
                   int   *height,
                   int   *width,
                   int   *line_spacing,
                   int    font_type)
{
  XCharStruct overall;
  int	status = 0;
  int	direction, ascent, descent;
  int	x, dummy;
  float	dummy_float;

  /* dmb:09/27/91:typecast */
  if ((font_id == 0) || (font_id == (Font)-1))  /* Invalid font  GMD 4/9/91 */
    {
      *width = 8;
      *line_spacing = 12;
      *height = 9;

      return ( 1 );
    }

  if ( font_type == 0 )    /* 8 bit .snf font */
    {
      status = XQueryTextExtents ( _FI_display, font_id, text,
					length, &direction, &ascent,
					&descent, &overall );

      *width		= overall.width;

	  /* sml:08-06-93 need to make line_spacing more like that
					  generated for equivalent fontserver fonts.
					  So fudge it.
      */

      *line_spacing	= (ascent + descent) *
						FS_TO_X_LINE_SPACING_FUDGE_FACTOR /*0.90*/ ;

      *height		= ascent;
    }
  else if ( font_type == 1 )  /* 8 bit Fontserver font */
    {
      BmapInfo	font_info;	
      double	total_w;
      double	h;

      status = FSGetTextVect ( font_id, text, length, 
				(double) 0.0, (double) 0.0, 
				&total_w, &h );
      if ( status )
	{
         fprintf ( stderr, "FONTSERVER ERROR IN GET VECT = %d",
		status );
	}

      *width = (int) ( total_w + 0.5 );

      status = FSGetBmapInfo ( font_id, &font_info );

      if ( status )
	{
	  fprintf ( stderr,
		"FONTSERVER ERROR IN GET BMAP = %d", status );
	}		

      *height = (int) ( font_info.bodySize - font_info.descent );

      *line_spacing = (int) (font_info.maxExtent - font_info.minExtent);
/*******
	sml:08-18-92	don't fudge for now
	sml:07-12-93	put back in
*******/
      dummy_float = *line_spacing - (*line_spacing * 0.15);
      *line_spacing = (int)dummy_float;
/*******/
    }
  else      /* 16 bit Fontserver font */
    {
      BmapInfo		font_info;	
      double		w, total_w = 0;
      double		h;
      int		index, i;
/*      unsigned char	ch_ptr[2]; */


      /*****************************************************/
      /* sml:01-27-94:NO TR (I/FORMS TR 249305159)         */
      /*  Combined 7/16 bit text isn't processed correctly */
      /*  because the 16-bit chars must start on short     */
      /*  aligned addresses.  Add sh_char and sh_ptr to    */
      /*  ensure current 16-bit char is on short alignemnt */
      /*****************************************************/
      unsigned short	sh_char;
      unsigned short	*sh_ptr;
      unsigned char	*ch_ptr;
      unsigned char	ch_temp[2]; 
      int		dummy2;
      Font		dummy1;
      int		bodysize = 20;
      int		font_id_8bit;

	/**********************************************************/
	/* Find the closest mono821b font to the size of the      */
	/* 16 bit font.                                           */
	/**********************************************************/

      for ( x = 0; x < _FI_next_font; x++ )
	{
	  if (_FI_fonts[x].font_id == font_id )
	    {
	      bodysize = (int) _FI_fonts[x].bodysize;
              break;
	    }
	}

/******************	sml:08-10-92  try it without this */
/*	sml:10-30-92	Use this for combined 16-bit and ASCII text  ******/

      if ( !_FI_font_available ( "mono821b", bodysize,
			(Font *) & font_id_8bit, &dummy )	)
	{  
          status = FI_load_font ( "mono821b", bodysize, &dummy,
						&dummy1, &dummy2 );

	  _FI_font_available ( "mono821b", bodysize,
			(Font *) &font_id_8bit, &dummy );
	}		   	
/****************/

       /**********************************************************/
       /* For each character in the string, check to see if the  */
       /* character is an 8 bit character or a 16 bit character. */
       /* Since the 8 bit font and the 16 bit font have seperate */
       /* font ids, a separate FSGetTextVect call is performed   */
       /* for each.                                              */
       /*                                                        */
       /* A running total is kept of the width of each character */
       /* and the total is returned when all characters have     */
       /* been examined.                                         */
       /**********************************************************/

      for ( i = 0, index = 0; i < length; i++ ) 
	{
	  if( !( text[index] & 0x80 ) )	/** 8 bit **/
	    {
		  /* sml:08-10-92 get text vect and bmap info if 8-bit */
	      status = FSGetTextVect ( font_id_8bit, &(text[index++]),
				1, (double) 0.0, (double) 0.0, &w, &h );

	      status = FSGetBmapInfo ( font_id_8bit, &font_info );

	      if ( status )
		  {
	 		fprintf ( stderr, "ERROR GET BMAP = %d\n", status );
		  }
		
	    }
	  else 
	    {
			/** 16 bit **/

		/* sml:06-17-92	Don't do this anymore; XFS will handle */
		/*** Sixteen bit mode requires a byte swap	 ***/
		/*** before sending the character to fontserver. ***/

		/* Don't swap
	      ch_ptr[0] = text [ index + 1 ];
	      ch_ptr[1] = text [ index ];
		*/
/***
	      ch_ptr[0] = text [ index ];
	      ch_ptr[1] = text [ index + 1 ];
***/
/*		  ch_ptr = (unsigned char *) text + index; */

      /*****************************************************/
      /* sml:01-27-94:NO TR (I/FORMS TR 249305159)         */
      /*  Combined 7/16 bit text isn't processed correctly */
      /*  because the 16-bit chars must start on short     */
      /*  aligned addresses.  Add sh_char and sh_ptr to    */
      /*  ensure current 16-bit char is on short alignemnt */
      /*  Swapping here works for Solaris.  Need to test   */
      /*  on other boxes.                                  */
      /*****************************************************/

  /* sml,dmb:08-25-94: ifdef for i86pc (TD solaris) */
#if !defined(i86pc)
#if defined(i386) || defined(sparc) && defined(sun) && defined(SYSV)
		  ch_temp[0] = text[index+1];
		  ch_temp[1] = text[index];
#endif
#endif

#if defined(clipper) || defined(mips) || defined(i86pc)
		  ch_temp[0] = text[index];
		  ch_temp[1] = text[index+1];
#endif
		  sh_ptr = (unsigned short *) ch_temp;
		  sh_char = *sh_ptr;
		  ch_ptr = (unsigned char *) &sh_char;

		  /* sml:08-10-92 get text vect and bmap info if 16-bit */
	      status = FSGetTextVect ( font_id, ch_ptr, 1,
				(double) 0.0, (double) 0.0, &w, &h );

		  if ( status )
	      {
	        fprintf ( stderr, "ERROR GET VECT %d\n", status );
	      }

	      status = FSGetBmapInfo ( font_id, &font_info );

	      if ( status )
		  {
	 		fprintf ( stderr, "ERROR GET BMAP = %d\n", status );
		  }

	      index += 2;
	    } 

	  total_w += w;
	}

      *width = (int) ( total_w + 0.5 );
		
      *height = (int)( font_info.bodySize - font_info.descent );
	  /* sml:08-13-92 try a different approach
      *line_spacing = (int) (font_info.maxExtent - font_info.minExtent);

      dummy_float = *line_spacing - (*line_spacing * 0.15);
	  */
      *line_spacing = (int) (font_info.maxExtent + font_info.minExtent);

      dummy_float = *line_spacing + (*line_spacing * 0.30);


      *line_spacing = (int)dummy_float;
  }

  return ( ! status );
}



int _FI_draw_text (Window   window,
                   Font     font_id,
                   char    *text,
                   int      length,
                   int      xpos,
                   int      ypos,
                   int      font_height,
                   int     *nx,
                   int     *ny,
                   int      font_type)
{
  int status;
  int screen;
  Form text_form;
  int window_index;

  /* dmb:09/27/91:typecast */
  if ((font_id == 0) || (font_id == (Font)-1))  /* Invalid font  GMD 4/9/91 */
    {
      return ( FI_SUCCESS );   /* Need to change this    GMD 8/15/91  */
    }

  /* GMD 4/20/92   Need to figure out what screen to display this on */
  /*               by first figuring out what form is associated     */
  /*               with the specified window.                        */

  window_index = _FI_Xwindow_to_index (window);
  text_form = (Form)FI_forms[window_index];

  /* ISDP add check in case windows are used up */
  if( text_form == NULL ){
	return( FI_SUCCESS );
  }
  screen = ((struct FIform_obj *)text_form)->Xscreen;

  if ( font_type == FI_RASTER_8_BIT_FONT_TYPE )    /* 8 bit .snf */
    {
      XSetFont ( _FI_display, _FI_gc, font_id );

      XDrawString ( _FI_display, window, _FI_gc, xpos,
			ypos + font_height, text, length );
    }
  else if ( font_type == FI_FS_8_BIT_FONT_TYPE )   /* 8 bit Fontserver */
    {
      double next_x;
      double next_y;	
	
	/*** Copy the _FI_gc into a temporary _FI_text_gc	***/
	/*** variable, because the FSX calls corrupt the GC	***/
	/*** passed into it.					***/
/* dmb,gmd:01/07/92:Added GCBackground.*/

      XCopyGC ( _FI_display, _FI_gc, GCForeground | GCBackground,
        _FI_text_gc );

      status = FSXDrawText (_FI_display, screen,
                                window, _FI_text_gc, font_id, text, length,
				(double)xpos,
			        (double)(ypos + font_height), 
				&next_x, &next_y );

      if ( status )
	{
	  fprintf ( stderr, "FSDrawText error = %d\n", status );
	}

      *nx = next_x;
      *ny = next_y;		
    }
  else   /* FI_FS_7_OR_16_BIT_FONT_TYPE - 16 bit Fontserver */
    {
      double next_x;
      double next_y;
      int font_id_8bit, x, dummy, dummy2;
	  Font dummy1;
      int bodysize = 20;
		
	/***********************************/
	/* Find the closest mono821b font  */
	/* to the size of the 16 bit font. */
	/***********************************/

      for ( x = 0; x < _FI_next_font; x++ )
	{
	  if ( _FI_fonts[x].font_id == font_id )
	    {
	      bodysize = (int) _FI_fonts[x].bodysize;

	      break;
	    }
	}

      if ( !_FI_font_available ( "mono821b", bodysize,
				(Font *) &font_id_8bit, &font_type /*&dummy*/ ) )
	{  
	  status = FI_load_font ( "mono821b", bodysize, &dummy,
						&dummy1, &dummy2 );

	  _FI_font_available ( "mono821b", bodysize,
				(Font *) &font_id_8bit, &font_type /*&dummy*/ );
	}		   	

	/*** 12/07/89 Calculate the byte length of string ***/
                                              /* 16stuff.c */

      length = _FI_locate_16bit_start_byte ( length, text );

      if ( length < 0 )	
	{
         length = 0;
	}

	/*********************************************************/
	/*  All the credit for the SSdrawText routine goes to    */
	/*  Mark Sullivan of Intergraph Japan.  It allows you to */
	/*  send a string of mixed 7 and 16 bit characters, and  */
	/*  it is smart enough to print them out correctly.      */
	/*                                                       */
	/*  One minor restriction is that both the 8 bit font    */
	/*  and the 16 bit font must be fontserver fonts.        */
	/*********************************************************/

      if ( length )
	{
          status = _FI_16DrawText ( window, font_id_8bit, font_id,
					(unsigned char *) text, length, 
				     (double)xpos, 
	                             (double)(ypos + font_height), 
				     &next_x, &next_y,
					FI_FS_7_OR_16_BIT_FONT_TYPE, font_type,
                                       screen );

	  if ( status )
	    {
	      fprintf ( stderr, "ERROR FSdrawText = %d\n", status );
	    }

	  *nx = next_x;
	  *ny = next_y;		
	}
  }

  return ( FI_SUCCESS );
}


int _FI_find_symbol_path_and_id (char  *path,
                                 char  *symbol_name,
                                 int   *symbol_id)
{
  *symbol_id = 0;

  if (! _FI_symbol_available (symbol_name, symbol_id, path))
    {
      if (_FI_load_symbol (symbol_name, path))
		 _FI_symbol_available (symbol_name, symbol_id, path);
      else
		 return FI_ILLEGAL_VALUES;
    }
  return (FI_SUCCESS);
}

/*  char	*fontname;		** INPUT & OUTPUT */
/* dmb:10/05/92:Changed to double */
/*  double  bodysize;		** INPUT */
/*  Font	*font_id;		** OUTPUT */
/*  float *actual_bodysize;	** OUTPUT */
/*  int	 gadget_type;		** INPUT */
/*  int	*font_type;		** 0 is the default 8bit bitstream */

int _FI_find_font_id (char   *fontname,
                      double  bodysize,
                      Font   *font_id,
                      float  *actual_bodysize,
                      int     gadget_type,
                      int    *font_type)
{
  int sts, actual_size;

printf("_FI_find_font_ID 1\n");

  /**************************************************/
  /* sml:01-10-94:TR 249304932  Purify error        */
  /*   Set this to avoid uninitialized memory read  */
  /**************************************************/

  actual_size = 0;

	/*************************************************/
	/* Set font type to 8 bit mode, .snf format font */
	/*************************************************/
if (font_type == NULL) printf("font_type == NULL\n");
  else *font_type = 0;

	/***********************************/
	/* Passing M2 size to FI_load_font */
	/***********************************/

  sts = FI_load_font ( fontname, (int) bodysize, &actual_size,
						font_id, font_type );
printf("_FI_find_font_id 2\n");
  if ( sts )
    {
      if ( sts == FI_NO_MEMORY )	/* fatal */
	{
	  return ( sts );
	}

		/************************/
		/* Get the default font */
		/************************/
printf("_FI_find_font_id 3\n");

      if ( (gadget_type == FI_FIELD) || (gadget_type == FI_MULTI_COL) )
	{
	  if (! _FI_font_available ("mono821", 18, font_id, font_type))
	    {
	      if ( ! _FI_font_available ( "fixed", 0,
						font_id, font_type ) )
		{
		  return ( FI_LOAD_FONT_ERROR );
		}

	      actual_size = 0;
	    }
	  else
	    {
	      actual_size = 18;	/* used mono821.18 */
	    }
	}
      else
	{
	  if (! _FI_font_available ("dutch801", 18, font_id, font_type))
	    {
	      if ( ! _FI_font_available ( "variable", 0,
						font_id, font_type ) )
		{
		  return ( FI_LOAD_FONT_ERROR );
		}
	      actual_size = 0;
	    }
	  else
	    {
	      actual_size = 18;	/* used dutch801.18 */
	    }
	}
    }

  *actual_bodysize = actual_size;
printf("_FI_find_font_id 4\n");

  return FI_SUCCESS;
}


int _FI_find_form (char  *path,
                   char  *form_name)
{
  int xx;

  for (xx = 0; xx < _FI_num_form_dirs; xx++)
    {
      strcpy (path, _FI_form_path[xx]);
      strcat (path, form_name);

      if (access (path, 0) == 0)
	{
	  break;
	}
    }

  return (FI_SUCCESS);
}
