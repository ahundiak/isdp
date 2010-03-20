#include "FImin.h"

#include <stdio.h>

#include "FEI.h"
#include "FIseq.h"
#include "FIscroll.h"
#include "FIbtn.h"
#include "FImcf.h"
#include "FIfield.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

static int Global_add_flag = 0;


/****************************************************/
/* Hebrew 07-31-90 - Routine for inverting a string */
/****************************************************/

void _FI_flip_string (char *str1,
                      char *str2)
{
  int str1_len, ii;

  str1_len = strlen (str1);

  for ( ii = 0; ii < str1_len; ii++ )
    {
      *(str2 + ii) = *(str1 + str1_len - 1 - ii);
    }

  *(str2 + str1_len) = '\0';
}


/**************************************************/
/*** Hebrew 07-01-90 Routine for shifting 	***/
/*** a string(s1) n times left into (s2)	***/
/**************************************************/

void _FI_shift_string (char  s1[],
                       char  s2[],
                       int   n)
{
  int ii, len1;

  len1 = strlen (s1);

  for (ii = n; ii <= len1; ii++)
    {
      s2[ii - n]= s1[ii];
    }

  s2[len1 + 1]= '\0';
}


/*-------Hebrew--------*/
/*********************************************************************/
/***  _FI_fld_add_char:   changed from "void" to "int"             ***/
/***  Returns:  FI_SUCCESS                          JAJ:09/05/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_add_char (struct FIfld_obj *field,
                      unsigned char    *ch,
                      int              *pos)
{
  Window	window	= XWINDOW(field);
  int		Xscreen	= XSCREEN(field);
  int		len, x, y, nx, ny, status, m_index;
  int		display_line = 1;
  unsigned char *str;
  int		wd, ii;


  *pos += 1;

  if ( field->FIfield.field_type != FI_ALPHA )
    {
      if ( isdigit(*ch) )
      {
	  /* Do nothing, digits are OK */
      }
      else
      {
         if (	(*ch == '.') || (*ch == ',') || (*ch == '-')	||
		(*ch == '+') || (*ch == 'e') || (*ch == 'E') )
	 { 
	   if (	( field->FIfield.field_type == FI_INT )	&&
		( *ch != '-' )				&&
		( *ch != '+' )				 )
	   {
		return ( FI_SUCCESS );
	   }
	   else if (	(*ch == '.')	|| (*ch == ',')		||
			(*ch == 'e')	|| (*ch == 'E')		 )
				/* Insure that these characters */
				/* occur only once in a		*/
				/* floating point field.	*/
	   {
	      int field_ar = field->FIfield.ar;

	      for ( ii = 0;
		    ii < strlen ((char *)field->FIfield.buffer[field_ar].line);
				ii++ )
		{
		  if ( field->FIfield.buffer[field_ar].line[ii]== *ch )
		    {
		      return ( FI_SUCCESS );
		    }
		}
	   }
	 }
         else
	 {
	   return ( FI_SUCCESS );
	 }
      }
    } /* if ( field->FIfield.field_type != FI_ALPHA ) */

	/*** <pds-12/12/89> Erase the current line before	***/
	/*** inserting the new character and drawing the new	***/
	/*** text string.  Matching the conditions at the end	***/
	/*** of this procedure.					***/


  /** X11-This caused flashing when the field was being tracked *****

  if ( (! field->FIfield.flags.no_echo ) && ( display_line == 1 ) )
    {
      _FI_fld_draw_cursor ( field, window, 1,
		_FI_fld_get_line_ON_COLOR ( field, field->FIfield.ar ),
							FI_MED_GREY);
    }
  ********************************************************************/


		/***************************/
		/* make room for character */
		/***************************/

  if ( field->FIfield.buffer[field->FIfield.ar].line )
    {
      _FI_fld_add_to_line ( field, field->FIfield.ar,
	   strlen ( (char *)field->FIfield.buffer[field->FIfield.ar].line) + 3);
    }
  else
    {
      _FI_fld_add_to_line ( field, field->FIfield.ar, 3 );
    }

			/********************/
			/* insert character */
			/********************/

  str = & ( field->FIfield.buffer[field->FIfield.ar].line[
		FI_move_index (
			(char *)field->FIfield.buffer[field->FIfield.ar].line,
			0, field->FIfield.ac,
			field->FIgadget.font_type)] );

  len = FI_strlen ( (char *)field->FIfield.buffer[field->FIfield.ar].line,
			field->FIgadget.font_type );

	/********************************/
	/* PJW - still problem for wrap */
	/********************************/

  if ( sbitset(ch[0])						     &&
	( field->FIgadget.font_type == FI_FS_7_OR_16_BIT_FONT_TYPE )  )
    {
      if ( field->FIfield.nc			&&
	   ( len + 1 >= field->FIfield.nc )	&&
	   ( ! field->FIfield.flags.wrap )	 )
	{
	    /*** <pds-12/13/89> This is needed for 16-bit text.	***/
	    /*** <pds-2/15/90> Changed to 'move_index'.		***/

	  m_index = FI_move_index (
		(char *)field->FIfield.buffer[field->FIfield.ar].line,
		0, field->FIfield.nc - 1,
		field->FIgadget.font_type );

	  field->FIfield.buffer[field->FIfield.ar].line[m_index] = '\0';
	}

      _FI_fld_insert_str ( str, ch, 2 );

      *pos += 1;
      len += 2;
    }
  else	/** Bitstream(font_type == 0), 8bit fontserver(1)**/
    {
      if ( field->FIfield.nc 			 &&
	  ( len + 1 >= field->FIfield.nc )	 &&
	  ( ! field->FIfield.flags.wrap )	  )
	{
	    /*** <pds-12/13/89> This is needed for 16-bit text.	***/

	  m_index = FI_move_index (
		(char *)field->FIfield.buffer[field->FIfield.ar].line,
		0, field->FIfield.nc - 1, field->FIgadget.font_type );

	  field->FIfield.buffer[field->FIfield.ar].line[ m_index ]='\0';
	}

      _FI_fld_insert_str ( str, ch, 1 );
      len += 1;
    }

  /********************************************************************/
  /* Check to see if there is room on the previous line for the first */
  /* word on this line. If there is, then reshuffle lines beginning   */
  /* with the previous line, then move the cursor to the far left     */
  /* hand margin of the line where the character was entered.         */
  /*								      */
  /* If the current line has a paragraph marker, then disregard this  */
  /* test.							      */
  /********************************************************************/

  if (	( field->FIfield.ar > 0 )				    &&
	( field->FIfield.buffer[field->FIfield.ar].paragraph == 0 ) &&
	( field->FIfield.flags.wrap == 1 )			     )
    {
      char	word[2000];
      int	spaces;

      _FI_fld_get_first_word_of_line (
		(char *)field->FIfield.buffer[field->FIfield.ar].line, word );

      _FI_fld_calc_remaining_space ( field->FIfield.nvc,
		(char *)field->FIfield.buffer[field->FIfield.ar - 1].line,
		&spaces );

      if ( spaces >= strlen (word) + 2 )
	{
	  if ( Global_add_flag )
	    {
	      field->FIfield.ac = 1;
	    }
	  else
	    {
	      field->FIfield.ac = 0;
	    }

	  Global_add_flag = 0;

	  _FI_fld_reshuffle_up ( field, field->FIfield.ar - 1 );

	  /* sml:02-18-93  if active row is buffer size, i.e.,
			   the last row, then wrap mode puts the
			   cursor on a null row and forms 
			   core dumps.  

			   Reset the active row to the previous
			   one and move the active character one
			   to the right
	  */

	  if (field->FIfield.ar == field->FIfield.buffer_size 
		&& field->FIfield.buffer[field->FIfield.ar].line == 0)
	  {
	    field->FIfield.ar = field->FIfield.ar - 1;
	    field->FIfield.ac = field->FIfield.ac + 1;
	  }

	  return ( FI_SUCCESS );
	}
    }

	/****************************************************/
	/* check for limit on number of characters per line */
	/****************************************************/

  if ( field->FIfield.nc  && ( len >= field->FIfield.nc ) )
    {
      if ( field->FIfield.flags.wrap )
	{
	  char	add_line[2000];
	  char	next_line[2000];
	  char	word[2000];
	  int	new_pos = -1, xx; /* set to -1 to initialize */
	  int	line_len;


        /***********************************************************/
        /* First check to see if the last character on the line    */
        /* is a blank. If so, then delete this character from the  */
        /* end of the line. Then redraw to the end of the line.    */
        /* Added to correct MAP-2 problem.             9/21/90 GMD */
        /***********************************************************/

	  line_len = strlen (
		    (char *)field->FIfield.buffer[field->FIfield.ar].line) - 1;

	  if ( (field->FIfield.buffer[field->FIfield.ar].
					line[line_len] == ' ' )	   &&
	       (field->FIfield.ac != line_len)			    )
	    {
	      field->FIfield.buffer[field->FIfield.ar].
						line[line_len] = '\0';

	      _FI_fld_refresh_row ( field, window, field->FIfield.ar );
	    }
	  else if ( (field->FIfield.flags.uds == 0)		      &&
		    (field->FIfield.buffer_size == field->FIfield.nvr) )
	    {
		/******************************************************/
		/* If it is a non-scrolling wrap field, then prevent  */
		/* the user from being able to type outside of the    */
		/* column boundaries when he is typing in text on the */
		/* last visible line of the column.		      */
		/******************************************************/

	      field->FIfield.buffer[field->FIfield.ar].line[line_len] = '\0';

	      if ( field->FIfield.ac >= field->FIfield.nc )
		{
		  field->FIfield.ac = field->FIfield.nc - 1;
		}

	      _FI_fld_refresh_row ( field, window, field->FIfield.ar );
	    }
	  else
	    {
	      int create_new_line;
	      int need_to_reshuffle;
	      int add_to_end;
	      int no_word;

		/****************************************************/
		/* The current line is too long, so remove the last */
		/* word from the current line, and add it to the    */
		/* beginning of the next line. Then reshuffle all   */
		/* affected lines.				    */
		/*						    */
		/* Don't reshuffle if the next line has a paragraph */
		/* marker. In this case, insert a new line, shift   */
		/* all existing lines downward and write the word   */
		/* to the blank line just inserted.		    */
		/****************************************************/

	      create_new_line = 0;
	      need_to_reshuffle = 1;
	      add_to_end = 0;

		/******************************************************/
		/* If the last character on the line was a space,     */
		/* then there is no need to copy the last word on the */
		/* line to the following line.  This instance will    */
		/* occur when you are at the end of a line and hit    */
		/* the space bar.				      */
		/******************************************************/

	      if ( field->FIfield.buffer[field->FIfield.ar].line[line_len]== ' ')
		{
		  no_word = 1;
		  need_to_reshuffle = 0;
		}
	      else
		{
		  no_word = 0;
		}

#if defined(hp9000)
	      strcpy ( add_line,
		(char *) field->FIfield.buffer[field->FIfield.ar].line );
#else
	      strcpy ( add_line,
			field->FIfield.buffer[field->FIfield.ar].line );
#endif

	      next_line[0]= '\0';

	      if ( (field->FIfield.buffer_size - 1) >
						field->FIfield.ar )
		{
		  if ( field->FIfield.buffer [ field->FIfield.ar + 1 ].
							paragraph == 0 )
		    {
#if defined(hp9000)
		      strcpy ( next_line,
			 (char *) field->FIfield.buffer[field->FIfield.ar + 1].line );
#else
		      strcpy ( next_line,
			 field->FIfield.buffer[field->FIfield.ar + 1].line );
#endif
		    }
		  else
		    {
		      create_new_line = 1;
		      need_to_reshuffle = 0;
		    }
		}
	      else	/* Create new line for text to be written to */
		{
		  _FI_fld_set_buffer ( field,
				field->FIfield.buffer_size + 1, 3);

		  need_to_reshuffle = 0;
		  add_to_end = 1;
		}

	      if ( no_word == 0 )
		{
		  _FI_fld_remove_last_word_from_line (
				field->FIfield.ac, field->FIfield.nc,
				add_line, word, &new_pos );

#if defined(hp9000)
		  strcpy (
			(char *) field->FIfield.buffer[field->FIfield.ar].line,
							add_line );
#else
		  strcpy (
			field->FIfield.buffer[field->FIfield.ar].line,
							add_line );
#endif

		/******************************************************/
		/* If the cursor position is greater than the new     */
		/* length of the current line, then set it to the     */
		/* greatest valid value.			      */
		/******************************************************/

		  if ( field->FIfield.ac >= strlen ( add_line ) )
		    {		    
		      field->FIfield.ac = strlen ( add_line ) - 1;
		    }		    

		  _FI_fld_add_word_to_start_of_line ( next_line, word );
		}
	      else
		{
		  field->FIfield.ac = 0;
		}

		/***************************************************/
		/* Insert a blank line and scoot all lines down to */
		/* make room for the new line if create new line   */
		/* is set.					   */
		/***************************************************/

	      if ( create_new_line )
		{
		  int temp_ar;

			/*********************/
			/* Create a new line */
			/*********************/

		  _FI_fld_set_buffer ( field,
				field->FIfield.buffer_size + 1, 1 );

		  for ( xx = field->FIfield.buffer_size - 1;
				xx > field->FIfield.ar + 1; xx-- )
		    {
		      _FI_fld_add_to_line ( field, xx,
			strlen ( (char *)field->FIfield.buffer[xx - 1].line)
								+ 2);

		      strcpy ( (char *) field->FIfield.buffer[xx].line,
				(char *) field->FIfield.buffer[xx - 1].line );

		      field->FIfield.buffer[xx].sel =
				field->FIfield.buffer[xx - 1].sel;

		      field->FIfield.buffer[xx].paragraph =
				field->FIfield.buffer[xx - 1].paragraph;

		      field->FIfield.buffer[xx].color =
				field->FIfield.buffer[xx - 1].color;
		    }

			/**************************/
			/* Blank out the new line */
			/**************************/

		  temp_ar = field->FIfield.ar + 1;

		  field->FIfield.buffer [ temp_ar ].line[0]	= '\0';
		  field->FIfield.buffer [ temp_ar ].sel		= 0;
		  field->FIfield.buffer [ temp_ar ].paragraph	= 0;
		  field->FIfield.buffer [ temp_ar ].color	= 0;

		  Global_add_flag = 1;
		}

	      _FI_fld_add_to_line ( field, field->FIfield.ar + 1,
					strlen (next_line) + 2 );

#if defined(hp9000)
	      strcpy (
		    (char *) field->FIfield.buffer[field->FIfield.ar + 1].line,
						next_line );
#else
	      strcpy (
		    field->FIfield.buffer[field->FIfield.ar + 1].line,
						next_line );
#endif

	      if ( create_new_line )
		{
		  _FI_fld_refresh_wrap_data ( field, field->FIfield.ar);
		}

	      if ( need_to_reshuffle )
		{
		  _FI_fld_refresh_row ( field, window,
						field->FIfield.ar );

		  _FI_fld_reshuffle_down ( field,
						field->FIfield.ar + 1 );
		}

	      if ( add_to_end )
		{
		  _FI_fld_refresh_row ( field, window, field->FIfield.ar );

		  _FI_fld_refresh_row ( field, window, field->FIfield.ar + 1 );

		  Global_add_flag = 1;
		}

		/******************************************************/
		/* If the cursor was inside the last word of the line */
		/* then move the cursor to the next line in the same  */
		/* position it would have been in if the scroll had   */
		/* not occurred.				      */
		/******************************************************/

	      if ( new_pos > -1 )
		{
		  field->FIfield.ar++;

		  if ( (field->FIfield.ar - field->FIfield.roff) >=
						field->FIfield.nvr   )
		    {
		      _FI_fld_scrl_next ( field, 1 );
		      _FI_fld_refresh_data ( field, window );
		    }

		  if ( no_word == 0 )
		    {
		      field->FIfield.ac = new_pos - 2;
		    }
		  else
		    {
		      field->FIfield.ac = 0;
		    }

		  if ( field->FIfield.ac < 0 )
		    {
		      field->FIfield.ac = 0;
		    }

		  if ( field->FIfield.ac >= strlen (word) )
		    {
		      field->FIfield.ac = strlen (word) - 1;
		    }
		}
	    }
	}
      else
	{
	    /*** <pds-12/13/89> This is needed for 16-bit text.	***/
	    /*** <pds-2/15/90> Changed to 'move_index'		***/

	  m_index = FI_move_index (
			(char *)field->FIfield.buffer[field->FIfield.ar].line,
			0, field->FIfield.nc,
			field->FIgadget.font_type );

	  field->FIfield.buffer[field->FIfield.ar].line[m_index]= 0;

	  _FI_fld_refresh_row ( field, window, field->FIfield.ar );
	}
    }
  else if ( (! field->FIfield.flags.no_echo) && (display_line == 1) )
    {
	/*******************************************/
	/* display character and remainder of line */
	/*******************************************/

      _FI_fld_erase_to_eol ( field, &len, &x, &y );


	/* Hebrew 31-07-90 */

      if ( field->FIfield.flags.right_to_left )
	{
	  int num_chars;
	  int ht, ls;

	  num_chars = (field->FIfield.nvc - 1) -
			(field->FIfield.ac - field->FIfield.coff);

	  FI_calc_text ( field->FIgadget.font_id, "m", 1,
			&ht, &wd, &ls, field->FIgadget.font_type );

	  x = (num_chars * wd) + (int) field->FIgadget.xlo;

	  y = ((field->FIfield.ar - field->FIfield.roff) * ls) +
					(int) field->FIgadget.ylo;
	}
	/*------Hebrew----------*/

      XSetForeground ( _FI_display, _FI_gc,
		FI_translate_color ( Xscreen,
		    _FI_fld_get_line_ON_COLOR (field,
					field->FIfield.ar)) );

      XSetBackground ( _FI_display, _FI_gc,
			FI_translate_color (Xscreen, FI_MED_GREY) );

      if ( len > 0 )
	{
		/* Hebrew 31-07-90 */

	  if ( field->FIfield.flags.right_to_left )
	    {
	      unsigned char s2[30000], s1[30000];
	      int xnew, s2len;
	      int temp_font_height;

	      _FI_flip_string ( (char *) str, (char *) s2 );

	      xnew = x - ((len - 2) * wd);

	      if ( strlen ( (char *) s2) + 1 > len )
		{
			/*** The string to redraw is at ***/
			/*** the boundary of the field ***/

		  if ( strlen ( (char *) s2) == len )
		    {
			/* First time */

		      xnew = x - ((len - 1) * wd);
		      len++;
		    }
		  else
		    {
			/* Passed boundary... */

		      s2len = strlen ( (char *) str);

		      _FI_shift_string ( (char *) s2, (char *) s1,
							(s2len - len));

		      strcpy ( (char *) s2, (char *) s1);

		      s2len = strlen ( (char *) s2);
		      xnew = x - ((s2len - 1) * wd);
		      len++;
		    }
		}

	      temp_font_height = field->FIgadget.font_height;

		 	/****************************************/
			/* Have to push XFontserver fonts down  */
			/*     GMD 8/30/91                      */
		 	/****************************************/
	      if ( field->FIgadget.font_type != 0 )/* != .snf */
		{
		  temp_font_height +=
				( field->FIgadget.font_height / 5 );
		}

	      status = FI_draw_text ( window,
					field->FIgadget.font_id,
					(char *) s2, len - 1, xnew, y,
				        temp_font_height,
					&nx, &ny,
					field->FIgadget.font_type);

	      if ( status )
		{
		  return ( FI_SUCCESS );
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
	      if ( field->FIgadget.font_type != 0 )   /* != .snf */
		{
		  temp_font_height +=
				( field->FIgadget.font_height / 5 );
		}

	      status = FI_draw_text ( window,
				field->FIgadget.font_id,
				(char *) str, len, x, y,
			        temp_font_height,
				&nx, &ny,
				field->FIgadget.font_type);

	      if ( status )
		{
		  return ( FI_SUCCESS );
		}
	    }
	}
    }

	/****************************************/
	/* move cursor forward if room in field */
	/****************************************/

  if ( ( field->FIfield.ac + 1 < field->FIfield.nc )	||
	! field->FIfield.nc				 )
    {
        if (FI_push_mode_flag == 0)   /* GMD 2/14/92  Implement push mode */
        {
		  /*************************************************/
		  /* sml:10-07-94: TR2494006670                    */
		  /*  If in wrap mode and character position is at */
		  /*  end of the line, increment field's ar and    */
		  /*  set its ac so things will work OK later.     */
		  /*************************************************/

		  if (field->FIfield.flags.wrap && len == field->FIfield.nvc &&
			field->FIfield.buffer[field->FIfield.ar].line[len-1] == ' ')
		  {
			field->FIfield.ar++;
			field->FIfield.ac = -1;
		  }
            status = _FI_fld_forward (field, 1);

 	    /*** if the gadget/form was deleted, ***/
	    /*** then return ***/
            if ( status != FI_SUCCESS )
	    {
	       return ( status );
	    }
        }
        else   /* GMD 2/14/92     More push mode stuff */
        {
           if (field->FIfield.nc)
           {
              if ((field->FIfield.ac + FI_push_mode_count) <
                  field->FIfield.nc - 1)
                 FI_push_mode_count += 1;
           }
           else
              FI_push_mode_count += 1;
           _FI_fld_refresh_row (field, window, field->FIfield.ar);
        }
    }

  return ( FI_SUCCESS );

} /*** int _FI_fld_add_char ( ) ***/


/*====================================================================*/
/*  unsigned char *target_str;	** target string */
/*  unsigned char *src_str;	** source string */
/*  int		 num_insert;	** # of chars to insert */

void _FI_fld_insert_str (unsigned char  *target_str,
                         unsigned char  *src_str,
                         int             num_insert)
{
  unsigned char *tt = target_str;

	/*********************************/
	/* move to the end of the string */
	/*********************************/

  while ( *target_str )
    {
      target_str++;
    }

	/*****************************************/
	/* shift string right 'num_insert' chars */
	/*****************************************/

  while ( tt <= target_str )
    {
      *(target_str + num_insert) = *target_str;
      target_str--;
    }

  target_str = tt;

	/*****************/
	/* insert string */
	/*****************/

  while ( num_insert-- )
    {
      *(target_str++) = *(src_str++);
    }
}



/*********************************************************************/
/***  _FI_fld_add_CR:      added "delete_status" argument          ***/
/***  delete_status =  FI_SUCCESS                   JAJ:08/31/90   ***/
/***          = FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***          = FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_add_CR (struct FIfld_obj  *field,
                    int               *delete_status)
{
  int	 status, coff;
  int	 refresh = FALSE, index;
  int	 ret = FI_SUCCESS;
  double value;

  if (FI_push_mode_flag)      /* GMD 2/14/92    Implement push mode */
     FI_push_mode_flag = 0;

  if ( field->FIfield.flags.wrap == 0 )
    {
      refresh = TRUE;

      value = (double) field->FIfield.ar;

      status = _FI_fld_verify_data ( field );

      if ( status )
	{
	  ret = FI_ILLEGAL_VALUES;
	}
      else	/* valid data */
	{
	  if (	( field->FIfield.field_type != FI_ALPHA)	&&
		  field->FIfield.fmt[0]				 )
	    {
	      char	new_line[2000];
	      double	new_value;
	      int	dummy1, dummy2;

	      if ( strlen (
		   (char *)field->FIfield.buffer[field->FIfield.ar].line) == 0)
		{
		  new_value = 0.0;
		}
	      else
		{
		  FIfld_get_value ( (Form) field->FIgadget.form,
					field->FIgadget.label,
					field->FIfield.ar, 0,
					&new_value, &dummy1, &dummy2 );
		}

	      if ( field->FIfield.field_type == FI_INT )
		{
		  sprintf ( new_line, field->FIfield.fmt,
					(int) new_value );
		}
	      else	/* double */
		{
		  sprintf ( new_line, field->FIfield.fmt, new_value );
		}

			/****************************************/
			/* Allocate space for the new line,	*/
			/* then store it there.			*/
			/****************************************/

	      _FI_fld_add_to_line ( field, field->FIfield.ar,
					strlen (new_line) + 2 );

#if defined(hp9000)
	      strcpy ( (char *) field->FIfield.buffer[field->FIfield.ar].line,
							new_line );
#else
	      strcpy ( field->FIfield.buffer[field->FIfield.ar].line,
							new_line );
#endif

	      _FI_fld_refresh_row ( field, XWINDOW(field),
						field->FIfield.ar );
	    }

	  _FI_fld_justify_data ( field );

	  if ( field->FIfield.flags.is_a_col 			    ||
		 ( field->FIfield.nr  				 &&
		 (field->FIfield.buffer_size == field->FIfield.nr))  )
	    {
	      ret = 1;	/* no more lines */
	    }
	  else if ( (field->FIfield.mode == FI_APPEND)		      &&
		  (field->FIfield.ar + 1 < field->FIfield.buffer_size) )
	    {
	      *delete_status = _FI_fld_next ( field, 1 );

	      if ( *delete_status != FI_SUCCESS )
		{
		  return ( 0 );
		}

	      ret = 0;
	    }
	  else
	    {
	      ret = 0;

	      if ( (field->FIfield.ar + 1 ==
					field->FIfield.buffer_size ) &&
		   (field->FIfield.ac ==
			strlen ( (char *) field->FIfield.buffer[
					field->FIfield.ar].line))     )
		{
			/*****************************************/
			/* at end of buffer - no need to refresh */
			/*****************************************/

		  refresh = FALSE;
		}

			/**********************/
			/* make room for line */
			/**********************/

	      _FI_fld_set_buffer ( field,
				field->FIfield.buffer_size + 1, 1 );

	      _FI_fld_shift_buffer_down ( field );

	      index = FI_move_index (
			(char *)field->FIfield.buffer[field->FIfield.ar].line,
			0, field->FIfield.ac,
			field->FIgadget.font_type );

	      _FI_fld_add_to_line ( field, field->FIfield.ar + 1,
				2 + strlen ( (char *) & (field->FIfield.buffer[
				    field->FIfield.ar].line[index])));

	      field->FIfield.buffer[field->FIfield.ar + 1].color =
			field->FIfield.buffer[field->FIfield.ar].color;

			/************/
			/* add line */
			/************/

	      if ((field->FIgadget.justification == FI_LEFT_JUSTIFIED)
			  && (field->FIfield.field_type == FI_ALPHA )  )
		{
		  int field_ar = field->FIfield.ar;

		    /***********************************************/
		    /*** Put in this additional check for Map2.	 ***/
		    /*** If there is no horz scroll for a field, ***/
		    /*** and the cursor is currently at the end  ***/
		    /*** of the line, then don't copy that	 ***/
		    /*** character to the beginning of the next  ***/
		    /*** line.			GMD 7/15/91      ***/
		    /***********************************************/

		  if ( (field->FIfield.flags.lrs == 0)		 &&
					  /* No Horz scrl */
                       (field->FIfield.ac == field->FIfield.nvc - 1))
		    {
                       /* Do nothing */
                    }
                  else
                    {
#if defined(hp9000)
		      strcpy ( (char *) field->FIfield.buffer[field_ar + 1].line,
		       (char *) & (field->FIfield.buffer[field_ar].line[index]));
#else
		      strcpy ( field->FIfield.buffer[field_ar + 1].line,
		       & (field->FIfield.buffer[field_ar].line[index]));
#endif

		      field->FIfield.buffer[field_ar].line[index]= '\0';
		    }
		}

			/**************************************/
			/* position to beginning of next line */
			/**************************************/

	      coff = field->FIfield.coff;

			/**********************************************/
			/* sml:10-12-94:TR 249406859                  */
			/*  if doing CR on last line in field         */
			/*   don't need to refresh in _FI_fld_next    */
			/*   and later in this function.              */
			/**********************************************/
		  if (field->FIfield.ar - field->FIfield.roff == 
				field->FIfield.nvr -1 )
		  {
			refresh = FALSE;
		  }

	      _FI_fld_bol ( field );

	      *delete_status = _FI_fld_next ( field, 1 );

	      if ( *delete_status != FI_SUCCESS )
		{
			/***************************************/
			/** return "ret", not "delete_status" **/
			/***************************************/

		  return ( ret );
		}

		/*************************************************/
		/* _FI_fld_next( ) did not do the needed refresh */
		/*************************************************/

	      if ( (coff == field->FIfield.coff) && refresh )
		{
		  _FI_fld_refresh_data ( field, XWINDOW(field) );
		}

		/*********************/
		/* adjust scroll bar */
		/*********************/

	      _FI_fld_set_vscrl ( field );
	    }
	}

	/******************************/
	/* Notify application of data */
	/******************************/

      if ( field->FIgadget.form->notification_routine		&&
	   (field->FIfield.nvr == 1)				&&
	   field->FIfield.flags.by_line				&&
	   (! field->FIfield.flags.is_a_col)			 )
	{
	  *delete_status = _FI_fld_notify (field, value);

		/*** if the field/form was deleted, then return ***/

	  if ( *delete_status != FI_SUCCESS )
	    {
	      return (ret);   /** return "ret", not "delete_status" **/
	     }

		/************************************/
		/* Pass data to gadget if sequenced */
		/************************************/

	  _FI_g_pass_data ((struct FIgadget_obj *)field);
	}

      if ( field->FIfield.buffer				&&
	   field->FIfield.buffer[field->FIfield.ar].line	 )
	{
#if defined(hp9000)
	  strcpy ( FI_data,
		(char *) field->FIfield.buffer[field->FIfield.ar].line );
#else
	  strcpy ( FI_data,
		field->FIfield.buffer[field->FIfield.ar].line );
#endif
	}
      else
	{
	  FI_data[0]= (char) NULL;
	}
    }
  else	/* wrap mode */
    {
      int perform_shift, xx;

      if ( ( field->FIfield.flags.uds == 0 )			  &&
	   ( field->FIfield.buffer_size == field->FIfield.nvr )    )
	{
	  ret = 1;
	  _FI_fld_bol ( field );
	}
      else
	{
	  ret = 0;

		/******************************************************/
		/* Need to create a new line, and place a paragraph   */
		/* marker in the line. Existing lines below the       */
		/* insertion point must be shifted downward.	      */
		/******************************************************/

	  if ( field->FIfield.ar < field->FIfield.buffer_size - 1 )
	    {
	      perform_shift = 1;
	    }
	  else
	    {
	      perform_shift = 0;
	    }

	  field->FIfield.ar++;

		/*********************/
		/* Create a new line */
		/*********************/

	  _FI_fld_set_buffer ( field,
				field->FIfield.buffer_size + 1, 1 );

	  if ( perform_shift )
	    {
	      for ( xx = field->FIfield.buffer_size - 1;
				xx > field->FIfield.ar; xx-- )
		{
		  _FI_fld_add_to_line ( field, xx,
		      strlen ((char *)field->FIfield.buffer[xx - 1].line) + 2);

#if defined(hp9000)
		  strcpy ( (char *) field->FIfield.buffer[xx].line,
				(char *) field->FIfield.buffer[xx - 1].line);
#else
		  strcpy ( field->FIfield.buffer[xx].line,
				field->FIfield.buffer[xx - 1].line);
#endif

		  field->FIfield.buffer[xx].sel =
				field->FIfield.buffer[xx - 1].sel;

		  field->FIfield.buffer[xx].paragraph =
				field->FIfield.buffer[xx - 1].paragraph;

		  field->FIfield.buffer[xx].color =
				field->FIfield.buffer[xx - 1].color;
		}
	    }

	  field->FIfield.buffer[field->FIfield.ar].sel = 0;
	  field->FIfield.buffer[field->FIfield.ar].paragraph = 1;

	  _FI_fld_add_to_line ( field, field->FIfield.ar,
	     strlen (
		(char *) field->FIfield.buffer[field->FIfield.ar - 1].line) + 3);

			/************/
			/* add line */
			/************/

#if defined(hp9000)
	  strcpy ( (char *) field->FIfield.buffer[field->FIfield.ar].line,
		(char *) & (field->FIfield.buffer[field->FIfield.ar - 1].
					line[field->FIfield.ac]));
#else
	  strcpy ( field->FIfield.buffer[field->FIfield.ar].line,
		& (field->FIfield.buffer[field->FIfield.ar - 1].
					line[field->FIfield.ac]));
#endif

	  field->FIfield.buffer[field->FIfield.ar - 1].
					line[field->FIfield.ac] = '\0';

	  _FI_fld_refresh_row ( field, XWINDOW(field),
					field->FIfield.ar - 1 );

	  if ( field->FIfield.ar != field->FIfield.buffer_size - 1 )
	    {
	      _FI_fld_reshuffle_up ( field, field->FIfield.ar );

			/**********************************************/
			/* sml:10-12-94:TR 249406859                  */
			/*   don't need to refresh in                 */
            /*   _FI_fld_reshuffle_up and later in this   */
            /*   function.  Set refresh to false.         */
			/**********************************************/

		  refresh = FALSE;
	    }

	  field->FIfield.ar--;

	  _FI_fld_bol ( field );

	  *delete_status = _FI_fld_next ( field, 1 );

		/*** if the field/form was deleted, then return ***/

	  if ( *delete_status != FI_SUCCESS )
	    {
	      return (ret);   /** return "ret", not "delete_status" **/
	    }

			/**********************************************/
			/* sml:10-12-94:TR 249406859                  */
			/*  if doing CR on last visible line in field */
			/*   don't need to refresh in _FI_fld_next    */
			/*   and here in this function.  added if     */
			/**********************************************/
	  if ( (field->FIfield.ar - field->FIfield.roff != 
			field->FIfield.nvr - 1 ) && refresh)
	  {
		_FI_fld_refresh_data ( field, XWINDOW(field) );
	  }
	}
    }

  return ( ret );

} /*** int _FI_fld_add_CR ( ) ***/


/*====================================================================*/

int _FI_fld_shift_buffer_down (struct FIfld_obj *field)
{
  int ii;
  static short first_in_grp = TRUE;

  if (	( field->FIfield.buffer_size > 1 )			&&
	( field->FIfield.ar + 2 < field->FIfield.buffer_size )	 )
    {
      for ( ii = field->FIfield.buffer_size - 1;
				ii > field->FIfield.ar + 1; ii-- )
	{
	  field->FIfield.buffer[ii] = field->FIfield.buffer[ii - 1];
	}

      field->FIfield.buffer[field->FIfield.ar + 1].line = 0;
    }

  if (  field->FIfield.flags.is_a_col  &&  first_in_grp	)
    {
      first_in_grp = FALSE;

      _FI_grp_pass_on_id_int_always (
			(struct FIgadget_obj *) field->FIgadget.group,
			_FI_fld_shift_buffer_down, 0, 0 );

      _FI_mcf_set_vscrl ( (struct FImcf_obj *)field->FIgadget.group );

      first_in_grp = TRUE;
    }

  return ( FI_SUCCESS );
}
