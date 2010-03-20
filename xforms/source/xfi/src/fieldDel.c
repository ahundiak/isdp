#include "FImin.h"

#include <stdio.h>
#include <ctype.h>

#include "FEI.h"
#include "FIseq.h"
#include "FIscroll.h"
#include "FIbtn.h"
#include "FImcf.h"
#include "FIfield.h"
#include "FIappl.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/********************************************************************/
/*** _FI_fld_maybe_do_line_reshuffling_etc ()-  This is just some ***/
/***	code that is common to both _FI_fld_back_space() and	  ***/
/***	_FI_fld_delete_char() that I put into a function call,	  ***/
/***	to reduce the size of the code.				  ***/
/********************************************  JAJ:09/01/91 *********/

static void _FI_fld_maybe_do_line_reshuffling_etc (struct FIfld_obj *field,
                                                   char      next_line[],
                                                   char      delete_line[])
{
  int	blank_spaces;
  char	word[2000];
  int	del_index;

  if ( next_line[0] )	/*  not NULL string */
    {
      _FI_fld_get_first_word_of_line ( next_line, word );

      if ( word[0] )	/* not NULL string */
	{
	  _FI_fld_calc_remaining_space ( field->FIfield.nvc,
					delete_line, & blank_spaces );

	  if ( strlen(word) + 2 < blank_spaces )
	    {
	      del_index = field->FIfield.nvc - blank_spaces;

	      delete_line [ del_index + 1 ]= ' ';

	      if (  ( delete_line [ del_index ] == '.')	||
		    ( delete_line [ del_index ] == '?')	||
		    ( delete_line [ del_index ] == '!')	 )
		{
		  delete_line [ del_index + 2 ] = ' ';
		  delete_line [ del_index + 3 ] = '\0';
		}
	      else
		{
		  delete_line [ del_index + 2 ] = '\0';/* EOL */
		}

	      strcat ( delete_line, word );

	      _FI_fld_remove_first_word_from_line ( next_line );

		/************************/
		/* Reshuffle lines here */
		/************************/

#if defined(hp9000)
	      strcpy((char *) field->FIfield.buffer[field->FIfield.ar + 1].line,
			    next_line );
#else
	      strcpy (field->FIfield.buffer[field->FIfield.ar + 1].line,
			    next_line );
#endif

	      _FI_fld_reshuffle_up ( field, field->FIfield.ar + 1 );
	    }
	}
    }

	/**************************************/
	/* store delete_line back into buffer */
	/**************************************/

  if ( strlen (delete_line)  >
	strlen ( (char *)field->FIfield.buffer[field->FIfield.ar].line )  )
    {
      _FI_fld_add_to_line ( field, field->FIfield.ar,
					strlen (delete_line) + 2 );
    }

#if defined(hp9000)
  strcpy ((char *) field->FIfield.buffer[field->FIfield.ar].line, delete_line );
#else
  strcpy ( field->FIfield.buffer[field->FIfield.ar].line, delete_line );
#endif
}



/********************************************************************/
/*** _FI_fld_maybe_do_fld_refresh_data()-  This is just some code ***/
/***	that is common to both _FI_fld_back_space() and		  ***/
/***	_FI_fld_delete_char() that I put into a function call,	  ***/
/***	to reduce the size of the code.				  ***/
/********************************************  JAJ:09/01/91 *********/

static void _FI_fld_maybe_do_fld_refresh_data (struct FIfld_obj *field,
                                               Window            window)
{
  if ( field->FIfield.buffer_size >= field->FIfield.nvr )
    {
      if ( field->FIfield.buffer_size <
			( field->FIfield.roff + field->FIfield.nvr ) )
	{
	  if ( field->FIfield.roff != 0 )
	    {
	      field->FIfield.roff--;
	    }

	  _FI_fld_refresh_data ( field, window );
	}
    }
}



/*====================================================================*/

static void _FI_fld_set_kill_buffer (struct FIfld_obj *field,
                                     int               count)
{
  int	temp_ar		= field->FIfield.ar;
  int	temp_font_type	= field->FIgadget.font_type;
  int	pos, num_bytes, index;
  int	new_kill_buffer_size;
  char	ch[2];


  if ( count > 0 )
    {
	/*** <pds-2/22/90> Since 'count' is the number of	***/
	/***  characters to make room for, this cannot be	***/
	/***  used to recalc the memory.			***/
	/***  The 7/16bit text was hosing up, because not	***/
	/***  enough memory was being allocated.		***/

      pos = FI_move_index ( (char *)field->FIfield.buffer[temp_ar].line,
				0, field->FIfield.ac, temp_font_type );
      if ( pos < 0 )
	{
	  pos = 0;
	}

      num_bytes = strlen ((char *) & field->FIfield.buffer[temp_ar].line[pos] );

      new_kill_buffer_size = num_bytes * sizeof (unsigned char) + 1;


      if ( ! FI_kill_buffer )
	{
	  FI_kill_buffer = (unsigned char *) calloc ( 1,
						new_kill_buffer_size );

	  if ( ! FI_kill_buffer )
	    {
	      return    /* ( FI_NO_MEMORY ) */ ;
	    }

	  FI_kill_buffer_size = new_kill_buffer_size;
	}
      else if ( new_kill_buffer_size > FI_kill_buffer_size )
	{
          FI_kill_buffer = (unsigned char *) realloc ( FI_kill_buffer,
						new_kill_buffer_size );
	  if ( ! FI_kill_buffer )
	    {
	      FI_kill_buffer_size = 0;
	      return    /* ( FI_NO_MEMORY ) */ ;
	    }

	  FI_kill_buffer_size = new_kill_buffer_size;
	}
    }

  FI_kill_buffer_index = 0;
  pos = field->FIfield.ac;	/** character count! **/

  while ( count-- )
    {
      index = FI_move_index ( (char *)field->FIfield.buffer[temp_ar].line,
					0, pos, temp_font_type );

      ch[0]= field->FIfield.buffer[temp_ar].line[index];
      ch[1]= field->FIfield.buffer[temp_ar].line[index + 1];
      pos++;

      if ( sbitset(ch[0])					 &&
		(temp_font_type == FI_FS_7_OR_16_BIT_FONT_TYPE )  )
	{
	  FI_kill_buffer [ FI_kill_buffer_index++ ] = ch[0];
	  FI_kill_buffer [ FI_kill_buffer_index++ ] = ch[1];
	}
      else
	{
	  if ( ch[0] == '\0' )
	    {
	      FI_kill_buffer [ FI_kill_buffer_index++ ] = CR;
	    }
	  else
	    {
	      FI_kill_buffer [ FI_kill_buffer_index++ ] = ch[0];
	    }
	}
    }
}



/********************************************************************/
/*** _FI_fld_redisplay_line_contents()	-  This is just some code ***/
/***	that is common to both _FI_fld_back_space() and		  ***/
/***	_FI_fld_delete_char() that I put into a function call,	  ***/
/***	to reduce the size of the code.				  ***/
/********************************************  JAJ:09/01/91 *********/
static int _FI_fld_redisplay_line_contents (struct FIfld_obj *field,
                                            unsigned char    *old_str,
                                            unsigned char    *new_str)
{
  Window	window = XWINDOW( field );
  int		Xscreen = XSCREEN( field );
  int		len, x, y, nx, ny, xnew;
  int		status;


  _FI_fld_erase_to_eol ( field, &len, &x, &y );
  _FI_fld_set_kill_buffer ( field, 1 );

#if defined(hp9000)
  strcpy ( (char *) old_str, (char *) new_str );
#else
  strcpy ( old_str, new_str );
#endif

      /********************************************************/
      /* if more than a null and echo - redisplay line	      */
      /* Changed from 1 to 2, just like _FI_fld_delete_char() */
      /********************************************************/

  if ( ( len > 1 ) && ! field->FIfield.flags.no_echo )
    {
      XSetForeground ( _FI_display, _FI_gc,
			FI_translate_color ( Xscreen,
				_FI_fld_get_line_ON_COLOR ( field,
						field->FIfield.ar )));

      XSetBackground ( _FI_display, _FI_gc,
			FI_translate_color ( Xscreen, FI_MED_GREY ) );

	/********************************************************/
	/* if len-1 is greater than strlen, send strlen instead */
	/********************************************************/

      if ( ( len - 1 ) > strlen ( (char *)old_str ) )
	{
	  len = strlen ( (char *)old_str ) + 1;
	}

	/*********** Hebrew 07/01/90 ***********************/

      if ( field->FIfield.flags.right_to_left )
	{
	  char	s2[30000], s1[30000];
	  int	ht, wd, ls;
	  int	num_chars, s2len;
	  int	temp_font_height;
/*	  char widest_str[10]; */

	  _FI_flip_string ( (char *)old_str, s2 );

	  /*sml:08-11-92 use widest characters here for _FI_s_rep() */
	
/***** sml:10-05-92	calling FI_calc_text has round trip call when
					using X server fonts; just used gadget members
					font_height and font_width and field member
					line_spacing
  comment out next calc_text for PC font stuff

	  status = _FI_widest_char(field->FIgadget.font_type, widest_str);
	  FI_calc_text ( field->FIgadget.font_id, //"m"// widest_str, 1,
			    &ht, &wd, &ls, field->FIgadget.font_type );

*****/

/******  sml:10-28-92 add this back in for PC font speed  ******/
	  ht = field->FIgadget.font_height;
	  wd = field->FIgadget.font_width;
	  ls = field->FIfield.line_height;
/******/
	  num_chars = ( field->FIfield.nvc - 1 ) -
			    ( field->FIfield.ac - field->FIfield.coff );

	  x = ( num_chars * wd ) + (int) field->FIgadget.xlo;

	  if (  ( strlen(s2) + 1 ) <= len  )
	    {
	      xnew = x - ( ( strlen((char *)old_str) - 1 ) * wd );
	    }
	  else
	    {
	      s2len = strlen(s2);
	      _FI_shift_string ( s2, s1, s2len - len );

	      strcpy ( s2, s1 );
	      s2len = strlen (s2);
	      xnew = x - ( (s2len - 1) * wd );
	      len++;
	    }

	  temp_font_height = field->FIgadget.font_height;

	 	/****************************************/
		/* Have to push XFontserver fonts down  */
		/*     GMD 8/30/91                      */
	 	/****************************************/
	  if ( field->FIgadget.font_type != 0 ) /* != .snf */
	    {
	      temp_font_height += ( field->FIgadget.font_height / 5 );
	    }

	  status = FI_draw_text ( window, field->FIgadget.font_id,
					s2, len - 1, xnew, y,
				        temp_font_height,
					&nx, &ny,
					field->FIgadget.font_type);

	  if ( status )
	    {
	      return ( status );
	    }
	}
      else
	{
	  int temp_font_height;

	  temp_font_height = field->FIgadget.font_height;

	 	/****************************************/
		/* Have to push XFontserver fonts down  */
		/*     GMD 8/30/91                      */
	 	/****************************************/
	  if ( field->FIgadget.font_type != 0 ) /* != .snf */
	    {
	      temp_font_height += ( field->FIgadget.font_height / 5 );
	    }

          /* GMD    12/20/91 */

          if (len > 1)
             len--;

	  status = FI_draw_text ( window, field->FIgadget.font_id,
					(char *)old_str, len, x, y,
				        temp_font_height,
					&nx, &ny,
					field->FIgadget.font_type);
	  if ( status )
	    {
	      return ( status );
	    }
	}
    }
  return ( FI_SUCCESS );
}



/**********************************************************************/
/* _FI_fld_back_space()- Deletes character prior to the field cursor */
/***			    changed from "void" to "int"           ***/
/***  Returns:  FI_SUCCESS                          JAJ:09/04/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_back_space (struct FIfld_obj *field)
{
  Window	 window = XWINDOW( field );
  int		 status;
  unsigned char *old_str, *new_str;


  if ( field->FIfield.flags.wrap == 0 )
    {
      if ( field->FIfield.ac )
	{
	  int m_index;

		/***********************************************/
		/* not at beginning of line - remove character */
		/***********************************************/

	  m_index = FI_move_index (
			(char *)field->FIfield.buffer[field->FIfield.ar].line,
			0, field->FIfield.ac - 1,
			field->FIgadget.font_type );

	  old_str = & field->FIfield.buffer[field->FIfield.ar].line[m_index ];

         /*************************************************************
          new_str = &( field->FIfield.buffer[field->FIfield.ar].line[
	   FI_move_index( field->FIfield.buffer[field->FIfield.ar].line,
		0, field->FIfield.ac, field->FIgadget.font_type )]);
         *************************************************************/

	  new_str = old_str + FI_move_index ( (char *)old_str, 0, 1,
					field->FIgadget.font_type );

	  status = _FI_fld_back ( field, 1 );

          /* GMD 2/14/92    Needed for push mode  */

          if (FI_push_mode_flag)
             FI_push_mode_ac = field->FIfield.ac;

	  if ( status != FI_SUCCESS )
	    {
	      return ( status );
	    }

					/*** JAJ:09/01/91 ***/
	  status = _FI_fld_redisplay_line_contents ( field,
						     old_str, new_str );
	  if ( status != FI_SUCCESS )
	    {
	      return ( status );
	    }
	}
      else if ( ( field->FIfield.ac == 0 )			&&
		( field->FIfield.ar )			 	&&
		( field->FIfield.flags.is_a_col == 0 )		&&
		( ( field->FIfield.mode != FI_APPEND )   ||
		  ( field->FIfield.ar ==
			field->FIfield.buffer_size - 1 )  )	  )
	{
		/* delete CR */

	  status = _FI_fld_previous ( field, 1 );
	  if ( status != FI_SUCCESS )
	    {
	      return ( status );
	    }

	  status = _FI_fld_eol ( field );
	  if ( status != FI_SUCCESS )
	    {
	      return ( status );
	    }

	  _FI_fld_delete_eol ( field );
	}
    }
  else	/* wrap mode is enabled */
    {
      if ( field->FIfield.ac )
	{
		/* not at beginning of line - remove character */

	  int	ar, ac;
	  char	delete_line[2000];
	  char	next_line[2000];

	  ar = field->FIfield.ar;
	  ac = field->FIfield.ac;

		/************************************************/
		/* Determine contents of active line, next line */
		/* Next line will be blanked if row exists but  */
		/* has a paragraph marker.			*/
		/************************************************/

#if defined(hp9000)
	  strcpy ( delete_line, (char *) field->FIfield.buffer[ar].line );
#else
	  strcpy ( delete_line, field->FIfield.buffer[ar].line );
#endif
	  next_line[0]= '\0';

	  if (( field->FIfield.buffer_size - 1 ) > ar )
	    {
	      if ( field->FIfield.buffer[ar + 1].paragraph == 0 )
		{
#if defined(hp9000)
		  strcpy ( next_line,
			(char *) field->FIfield.buffer[ar + 1].line );
#else
		  strcpy ( next_line,
				field->FIfield.buffer[ar + 1].line );
#endif
		}
	    }

         /***************************************************/
         /* Delete character before the cursor, if possible */
         /***************************************************/

	  if ( ac <= strlen (delete_line) )
	    {
	      strcpy ( & delete_line[ac - 1], & delete_line[ac] );

						/*** JAJ:09/01/91 ***/
	      _FI_fld_maybe_do_line_reshuffling_etc ( field,
					      next_line, delete_line );

	      status = _FI_fld_back ( field, 1 );
	      if ( status != FI_SUCCESS )
		{
		  return ( status );
		}

	      if ( field->FIfield.ac > strlen (delete_line) )
		{
		  field->FIfield.ac = strlen (delete_line);
		}

	      _FI_fld_refresh_row ( field, window, field->FIfield.ar );

						/*** JAJ:09/01/91 ***/
	      _FI_fld_maybe_do_fld_refresh_data ( field, window );
	    }
	}
      else if ( ( field->FIfield.ac == 0 )			    &&
		( field->FIfield.ar )				    &&
		( field->FIfield.flags.is_a_col == 0 )		    &&
		(( field->FIfield.mode != FI_APPEND)             ||
	 ( field->FIfield.ar == field->FIfield.buffer_size - 1 )  )  )
	{	
		/*************/
		/* delete CR */
		/*************/

	  if ( field->FIfield.buffer[field->FIfield.ar].paragraph == 1 )
	    {
	      field->FIfield.buffer[field->FIfield.ar].paragraph = 0;
	    }

	  if ( field->FIfield.buffer[field->FIfield.ar].paragraph == 0 )
	    {
	      status = _FI_fld_previous ( field, 1 );
	      if ( status != FI_SUCCESS )
		{
		  return ( status );
		}

		/*** <pds-12/08/89> Changed from strlen()	***/
		/*** <pds-2/15/90> Added 'font_type'		***/

	      field->FIfield.ac = FI_strlen (
			(char *)field->FIfield.buffer[field->FIfield.ar].line,
			field->FIgadget.font_type );

	      _FI_fld_reshuffle_up ( field, field->FIfield.ar );

						/*** JAJ:09/01/91 ***/
	      _FI_fld_maybe_do_fld_refresh_data ( field, window );
	    }
	}
    }

  return ( FI_SUCCESS );
}




/********************************************************************/
/* _FI_fld_delete_char () - Delete character under the field cursor */
/********************************************************************/

void _FI_fld_delete_char (struct FIfld_obj *field)
{
  Window	 window = XWINDOW( field );
  int		 status;
  unsigned char *old_str, *new_str;


  if ( field->FIfield.flags.wrap == 0 )
    {
      if ( field->FIfield.buffer[field->FIfield.ar].line[field->FIfield.ac])
	{
	  int m_index;

		/*********************************/
		/* remove character cursor is on */
		/*********************************/

	  m_index = FI_move_index (
			(char *)field->FIfield.buffer[field->FIfield.ar].line,
			0, field->FIfield.ac,
			field->FIgadget.font_type );

	  old_str = & ( field->FIfield.buffer[field->FIfield.ar].line[m_index ]);

          /***********************************************************
          new_str = &( field->FIfield.buffer[field->FIfield.ar].line[
           FI_move_index( field->FIfield.buffer[field->FIfield.ar].line,
		0, field->FIfield.ac + 1, field->FIgadget.font_type )]);
          ***********************************************************/

	  new_str = old_str + FI_move_index ( (char *)old_str, 0, 1,
					field->FIgadget.font_type );

          /* GMD 2/14/92   Implement push mode */

          if (FI_push_mode_flag)
             if (FI_push_mode_count)
                FI_push_mode_count--;

					/*** JAJ:09/01/91 ***/
	  status = _FI_fld_redisplay_line_contents ( field,
						     old_str, new_str );
	  if ( status != FI_SUCCESS )
	    {
	      return ;
	    }
	}
      else if ( (field->FIfield.ar + 1 < field->FIfield.buffer_size ) &&
		( field->FIfield.mode != FI_APPEND)		      &&
		(! field->FIfield.flags.is_a_col)		       )
	{
	  _FI_fld_delete_eol ( field );

	  _FI_fld_set_vscrl ( field );
	}
    }
  else	/* Wrap mode is active */
    {
      int	ar, ac;
      char	delete_line[2000];
      char	next_line[2000];

      ar = field->FIfield.ar;
      ac = field->FIfield.ac;

      /************************************************/
      /* Determine contents of active line, next line */
      /* Next line will be blanked if row exists but  */
      /* has a paragraph marker.		      */
      /************************************************/

#if defined(hp9000)
      strcpy ( delete_line, (char *) field->FIfield.buffer[ar].line );
#else
      strcpy ( delete_line, field->FIfield.buffer[ar].line );
#endif

      next_line[0]= '\0';

      if ( ( field->FIfield.buffer_size - 1 ) > ar )
	{
	  if ( field->FIfield.buffer[ar + 1].paragraph == 0 )
	    {
#if defined(hp9000)
	      strcpy ( next_line, (char *) field->FIfield.buffer[ar + 1].line );
#else
	      strcpy ( next_line, field->FIfield.buffer[ar + 1].line );
#endif
	    }
	}

	/**************************************************/
	/* Delete character under the cursor, if possible */
	/**************************************************/

      if ( ac < strlen (delete_line) )
	{
	  strcpy (& delete_line[ac], & delete_line[ac + 1] );

						/*** JAJ:09/01/91 ***/
	  _FI_fld_maybe_do_line_reshuffling_etc ( field,
					      next_line, delete_line );

	  if ( field->FIfield.ac > strlen ( delete_line ))
	    {
	      field->FIfield.ac = strlen ( delete_line );
	    }

	  _FI_fld_refresh_row ( field, window, field->FIfield.ar );

						/*** JAJ:09/01/91 ***/
	  _FI_fld_maybe_do_fld_refresh_data ( field, window );
	}
    }
}



/*====================================================================*/

void _FI_fld_delete_eol (struct FIfld_obj *field)
{
  int len, index;

  index = FI_move_index ( (char *)field->FIfield.buffer[field->FIfield.ar].line,
				0, field->FIfield.ac,
				field->FIgadget.font_type );

  if ( index < 0 )
    {
      index = strlen ( (char *)field->FIfield.buffer[field->FIfield.ar].line );
    }

  if ( field->FIfield.buffer[field->FIfield.ar].line[index]== 0 )
    {
      _FI_fld_set_kill_buffer ( field, 1 );

      if ( ( field->FIfield.ar + 1 ) < field->FIfield.buffer_size )
	{
		/*** <pds-12/08/89 changed from strlen()	***/
		/*** <pds-2/15/90 Added 'font_type'		***/

	  len = FI_strlen (
			(char *)field->FIfield.buffer[field->FIfield.ar].line,
			field->FIgadget.font_type )		      +
		FI_strlen (
		    (char *)field->FIfield.buffer[field->FIfield.ar + 1].line,
			field->FIgadget.font_type );

	  if (  ( field->FIfield.nc && len <= field->FIfield.nc )    ||
		(! field->FIfield.nc )				      )
	    {
	      if ( (! field->FIfield.nc )			      ||
		   (! field->FIfield.buffer[field->FIfield.ar].line )  )
		{
		  int field_ar = field->FIfield.ar;

		   /***************************************************/
		   /*** <pds-12/08/89 recalculate the amount needed ***/
		   /***************************************************/

		  len = strlen ((char *)field->FIfield.buffer[field_ar].line) +
			strlen ((char *)field->FIfield.buffer[field_ar + 1].line );

		  _FI_fld_add_to_line ( field, field_ar, len + 2 );
		}

#if defined(hp9000)
	      strcat ( (char *) field->FIfield.buffer[field->FIfield.ar].line,
		(char *) field->FIfield.buffer[field->FIfield.ar + 1].line );
#else
	      strcat ( field->FIfield.buffer[field->FIfield.ar].line,
		    field->FIfield.buffer[field->FIfield.ar + 1].line );
#endif

	      field->FIfield.buffer[field->FIfield.ar].paragraph = 1;

	      _FI_fld_shift_buffer_up ( field );

	      _FI_fld_set_buffer ( field,
				field->FIfield.buffer_size - 1, 1 );

	      _FI_fld_refresh_data ( field, XWINDOW(field) );
	    }
	}
    }
}

/*====================================================================*/

void _FI_fld_delete_line (struct FIfld_obj *field)
{
  int len, x, y, start_byte;

  if ( field->FIfield.buffer[field->FIfield.ar].line[field->FIfield.ac])
    {
      _FI_fld_erase_to_eol ( field, &len, &x, &y );

	/*************************************************************/
	/** <pds-2/1/90> Support cutting & pasting with 16bit text. **/
	/** This was using 'ac' as a starting reference, but with   **/
	/** 16-bit text the 'start_byte' needed to be used.	    **/
	/*************************************************************/

      start_byte = FI_move_index (
			(char *)field->FIfield.buffer[field->FIfield.ar].line,
			0, field->FIfield.ac,
			field->FIgadget.font_type );

      if ( start_byte < 0 )
        {
	  start_byte = 0;
        }

		/*************************************************/
		/** <pds-2/20/90> '...set_kill_buffer' takes	**/
		/** a character count.				**/
		/*************************************************/

      len = FI_strlen (
	    (char *) & field->FIfield.buffer[field->FIfield.ar].line[start_byte],
			field->FIgadget.font_type );

      _FI_fld_set_kill_buffer ( field, len );

      field->FIfield.buffer[field->FIfield.ar].line[start_byte]= '\0';

      if ( field->FIfield.flags.wrap == 1 )
	{
		/**************************************************/
		/*** delete paragraph marker if cursor is in	***/
		/*** position 0 of the line.			***/
		/**************************************************/

	  if ( field->FIfield.ac == 0 )
	    {
	      field->FIfield.buffer[field->FIfield.ar].paragraph = 0;
	    }

		/*******************/
		/* Reshuffle lines */
		/*******************/

	  if ( field->FIfield.ar != field->FIfield.buffer_size - 1 )
	    {
	      _FI_fld_reshuffle_up ( field, field->FIfield.ar );
	    }
	  else
	    {
	      if ( field->FIfield.ar != 0 )
		{
		  _FI_fld_set_buffer ( field,
				field->FIfield.buffer_size - 1, 1 );

		  field->FIfield.ar--;

		  field->FIfield.ac = strlen (
			(char *)field->FIfield.buffer[field->FIfield.ar].line );
		}
	      else
		{
		  field->FIfield.ac = 0;
		}
	    }
						/*** JAJ:09/01/91 ***/
	  _FI_fld_maybe_do_fld_refresh_data ( field, XWINDOW(field) );
	}
    }
  else if (	( field->FIfield.mode != FI_APPEND )		 &&
		( field->FIfield.flags.is_a_col == 0 )		  )
    {
	/*********************************/
	/*** Don't delete line if MCF. ***/
	/*********************************/

      _FI_fld_delete_eol ( field );
    }
}


/*********************************************************************/
/***  _FI_fld_undelete:   changed from "void" to "int"             ***/
/***  Returns:  FI_SUCCESS                          JAJ:09/04/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_undelete (struct FIfld_obj *field)
{
  int ii = 0;
  int delete_status;

  if ( field->FIfield.flags.wrap == 0 )
    {
      while ( ii < FI_kill_buffer_index )
	{
	  if ( FI_kill_buffer[ii] == CR )
	    {
	      _FI_fld_add_CR ( field, &delete_status );

		/*** if the gadget/form was deleted, then return ***/

	      if ( delete_status != FI_SUCCESS )
		{
		  return ( delete_status );
		}

	      ii++;
	    }
	  else
	    {
	      delete_status = _FI_fld_add_char ( field,
					& FI_kill_buffer[ii], &ii );

		/*** if the gadget/form was deleted, then return ***/

	      if ( delete_status != FI_SUCCESS )
		{
		  return ( delete_status );
		}
	    }
	}
    }
  else	/* wrap mode so insert string in buffer line */
    {
      char	leftover_line[2000];
      char	new_line[2000];
      int	field_ar = field->FIfield.ar;

#if defined(hp9000)
      strcpy ( leftover_line,
	   (char *) & field->FIfield.buffer[field_ar].line[field->FIfield.ac] );
#else
      strcpy ( leftover_line,
	    & field->FIfield.buffer[field_ar].line[field->FIfield.ac] );
#endif

      field->FIfield.buffer[field_ar].line[field->FIfield.ac]= '\0';

      sprintf ( new_line, "%s%s %s",
		      field->FIfield.buffer[field_ar].line,
		      FI_kill_buffer,
		      leftover_line );

      _FI_fld_add_to_line ( field, field_ar, strlen (new_line) + 2 );

#if defined(hp9000)
      strcpy ((char *) field->FIfield.buffer[field->FIfield.ar].line, new_line);
#else
      strcpy ( field->FIfield.buffer[field->FIfield.ar].line, new_line);
#endif

	/*******************/
	/* Reshuffle lines */
	/*******************/

      _FI_fld_reshuffle_down ( field, field->FIfield.ar );

      _FI_fld_refresh_wrap_data ( field, field->FIfield.ar );
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/
/*  int *len;	** number of characters erased **/

void _FI_fld_erase_to_eol (struct FIfld_obj *field,
                           int              *len,
                           int              *x,
                           int              *y)
{
  int Xscreen = XSCREEN( field );
  int ht, wd, ls, x2;
  int tmpx, tmpy, tmplen;	/* Hebrew */
/*  char widest_str[10];
  int status; */

	/*** 12/07/89 changed from strlen()	***/

   /******************************************************************/
   /* GMD 8/26/91   Needed to remove the +1 from the len calculation */
   /*               This was causing 16-bit text display to fail.    */
   /******************************************************************/

  /****************************************************************
  *len = FI_strlen ( field->FIfield.buffer[field->FIfield.ar].line,
	field->FIgadget.font_type ) - field->FIfield.ac + 1;
						/ * len of eol * /
  *****************************************************************/

  *len = FI_strlen ( (char *)field->FIfield.buffer[field->FIfield.ar].line, 
                     field->FIgadget.font_type ) - field->FIfield.ac;

  if ( ( field->FIfield.ac - field->FIfield.coff + *len ) >
						field->FIfield.nvc )
    {
      *len = field->FIfield.nvc -
			( field->FIfield.ac - field->FIfield.coff );
    }

  tmplen = *len;

  _FI_fld_get_xy ( field, field->FIfield.ac - field->FIfield.coff,
							x, y );

  tmpx = *x;
  tmpy = *y;

  if ( field->FIfield.flags.right_to_left )
    {
      int num_chars;
/*	  char widest_str[10]; */

      num_chars = field->FIfield.nvc -
			( field->FIfield.ac - field->FIfield.coff );

	  /*sml:08-11-92 use widest characters here for _FI_s_rep() */
	
/***** sml:10-05-92	calling FI_calc_text has round trip call when
					using X server fonts; just used gadget members
					font_height and font_width and field member
					line_spacing
********
	  status = _FI_widest_char(field->FIgadget.font_type, widest_str);
      FI_calc_text ( field->FIgadget.font_id, //"m"// widest_str, 
		1, &ht, &wd, &ls,
			field->FIgadget.font_type );

************/

/******* sml:10-28-92 add back for PC font speed  */
	  ht = field->FIgadget.font_height;
	  wd = field->FIgadget.font_width;
	  ls = field->FIfield.line_height;
/********/
      *x = ( num_chars * wd ) + (int) field->FIgadget.xlo;

      *y = (( field->FIfield.ar - field->FIfield.roff ) * ls ) +
					(int) field->FIgadget.ylo;
    }

  XSetForeground ( _FI_display, _FI_gc,
		FI_translate_color ( Xscreen, FI_MED_GREY ) );

  if ( field->FIfield.flags.required )
    {
      XGCValues gc_values;
      long gc_value_mask;

      gc_value_mask = GCStipple | GCBackground | GCFillStyle;
      gc_values.background = FI_translate_color ( Xscreen, FI_WHITE );
      gc_values.stipple = _FIpix_required_array [Xscreen];
      gc_values.fill_style = FillOpaqueStippled;
      XChangeGC ( _FI_display, _FI_gc, gc_value_mask, &gc_values );
    }

  /*sml:08-11-92 use widest characters here  */

/***** sml:10-05-92	calling FI_calc_text has round trip call when
					using X server fonts; just used gadget members
					font_height and font_width and field member
					line_spacing

  status = _FI_widest_char(field->FIgadget.font_type, widest_str);
  FI_calc_text ( field->FIgadget.font_id, //"A"// widest_str, 
		1, &ht, &wd, &ls,
		field->FIgadget.font_type );

************/

	  ht = field->FIgadget.font_height;
	  wd = field->FIgadget.font_width;
	  ls = field->FIfield.line_height;

	/**************************************************/
	/*** <pds-2/1/90> Don't erase the field symbols ***/
	/**************************************************/

  if ( field->FIfield.list_id || field->FIfield.flags.roll_thru )
    {
      x2 = field->FIgadget.xhi - ROLL_THROUGH_SYM_WIDTH + FIELD_BEZEL;
    }
  else
    {
      x2 = field->FIgadget.xhi;
    }

	/* Hebrew 31-07-90 */

  if ( field->FIfield.flags.right_to_left )
    {
      x2 = *x;
      *x = field->FIgadget.xlo;
    }

  XFillRectangle ( _FI_display, XWINDOW(field), _FI_gc,
				*x, *y, x2 - *x, ls );

  if ( field->FIfield.flags.required )
    {
      XSetFillStyle ( _FI_display, _FI_gc, FillSolid );
    }

  /* Hebrew 31-07-90 */

  *x = tmpx;
  *y = tmpy;
  *len = tmplen;
}



/*====================================================================*/

void _FI_fld_shift_buffer_up (struct FIfld_obj *field)
{
  int buffer_size = field->FIfield.buffer_size ;
  int field_ar    = field->FIfield.ar ;
  int ii;

  if ( ( buffer_size > 1 ) && ( field_ar + 2 < buffer_size ) )
    {
      for ( ii = field_ar + 1; ii + 1 < buffer_size; ii++ )
	{
         field->FIfield.buffer[ii]= field->FIfield.buffer[ii + 1];
	}

      field->FIfield.buffer[buffer_size - 1].line = '\0';
    }
}
