/*********************************************************************/
/* fieldWrap.c - 						     */
/* This file contains routines which are used to implement wrap mode */
/*********************************************************************/

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

extern int _FI_fld_set_text_last_row;

static char * _FI_one_space  = " ";
static char * _FI_two_spaces = "  ";


/******************************************************/
/* _FI_fld_add_spaces_after_punct ( ) -If a line ends */
/* with a punctuation character, insure that two      */
/* spaces separate it from the start of the next line.*/
/* Otherwise, insure that one space seperates it from */
/* the start of the next line.			      */
/******************************************************/

static void _FI_fld_add_spaces_after_punct (char  combined_line[])
{
  int len1, len2;

		/* Don't insert space before	*/
		/* next line if line is empty.	*/

  if ( combined_line[0] )
    {
      len1 = strlen ( combined_line ) - 1;
      len2 = len1 - 1;

      if ( combined_line[len1] != ' ' )
	{
	  if (	( combined_line[len1] == '.')	||
		( combined_line[len1] == '?')	||
		( combined_line[len1] == '!')	 )
	    {
	      strcat ( combined_line, _FI_two_spaces );
	    }
	  else
	    {
	      strcat ( combined_line, _FI_one_space );
	    }
	}
      else if ( ( len2 >= 0 )				&&
		( ( combined_line[len2] == '.' )  ||
		  ( combined_line[len2] == '?' )  ||
		  ( combined_line[len2] == '!' )   )	 )
	{
	  strcat ( combined_line, _FI_one_space );
	}
    }
}


/******************************************************************/
/* _FI_fld_refresh_wrap_data ( ) -				  */
/*   This routine is used heavily. It allows only a portion of	  */
/* a field's viewing area to be redrawn. The caller specifies	  */
/* where to start refreshing lines. The function will refresh any */
/* lines at or beyond that point that fall within the field's	  */
/* viewing area.						  */
/*******************************************************************/

int _FI_fld_refresh_wrap_data (struct FIfld_obj  *field,
                               int                start_row)
{
  int		row;
  Window	window = XWINDOW ( field );
  int		x, y;
  int		Xscreen	= XSCREEN( field );


  row = start_row;

  while ( ( row < field->FIfield.roff + field->FIfield.nvr )   &&
	  ( row < field->FIfield.buffer_size )			)
    {
      _FI_fld_refresh_row ( field, window, row );
      row++;
    }

	/*****************************************/
	/* Erase the portion of the viewing area */
	/* that does not have any defined text.  */
	/*****************************************/

  if ( field->FIfield.buffer_size < field->FIfield.nvr )
    {
      x = (int) field->FIgadget.xlo;

      y = (int) field->FIgadget.ylo +
			( field->FIfield.buffer_size *
				    (int) field->FIfield.line_height );

      if ( ( field->FIfield.mode == FI_INSERT )		||
	   ( field->FIfield.mode == FI_APPEND )		 )
	{
	  XSetForeground ( _FI_display, _FI_gc,
			   FI_translate_color ( Xscreen, FI_MED_GREY ));
	}
      else
	{
	  XSetForeground ( _FI_display, _FI_gc,
			   FI_translate_color ( Xscreen, FI_LT_GREY ));
	}

      XFillRectangle ( _FI_display, window, _FI_gc, x, y,
		field->FIgadget.xhi - x, field->FIgadget.yhi - y );
    }

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
  if (!_FI_dont_flush)
    XFlush ( _FI_display );

  return ( FI_SUCCESS );
}


/*--------------------------------------------------------------*/

int _FI_fld_remove_last_word_from_line (int   ac,
                                        int   nc,
                                        char  line[],
                                        char  word[],
                                        int  *pos)
{
  int first_letter;
  int last_letter;

	/************************************************/
	/* Scan from the back of the line to the front, */
	/* discarding all blank characters until the	*/
	/* first non-blank character is encountered.    */
	/************************************************/

  last_letter = strlen ( line ) - 1;

  while ( ( last_letter > 0 ) && ( line[last_letter] == ' ' ) )
    {
      last_letter--;
    }

  first_letter = last_letter;

	/*********************************************************/
	/* Continue scanning backward until a blank character is */
	/* encountered, or you reach the beginning of the line.  */
	/*********************************************************/

  while ( ( first_letter > 0 ) && ( line[first_letter] != ' ') )
    {
      first_letter--;
    }

  if ( first_letter != last_letter )
    {
     /***********************************************************/
     /* If the word is more than a single character in width,	*/
     /* then first check to see if the leading character is	*/
     /* a blank.  If so, then it must not be included as part	*/
     /* of the word.						*/
     /***********************************************************/

      if ( line[first_letter] == ' ')
	{
	  strcpy ( word, & line[first_letter + 1] );
	  word[last_letter - first_letter]= '\0';
	}
      else
	{
	  strcpy ( word, & line[first_letter] );
	}

     /***********************************************************/
     /* If the cursor is inside the last word on the line, then	*/
     /* record it's position inside the word. This will be used */
     /* to keep the cursor in the same position inside the word */
     /* when it moves to the next line. If the cursor is not	*/
     /* inside the word, then a value of -1 is returned to	*/
     /* indicate that the cursor can remain on the current line.*/
     /***********************************************************/

      if ( ac > first_letter )
	{
	  *pos = ac - first_letter + 1;
	}
      else
	{
	  *pos = -1;
	}
    }
  else	/* Handle the case of the one letter word. */
    {
      strcpy ( word, & line[first_letter] );
      word[1]= '\0';
    }

  if ( strlen ( word ) < nc - 1 )
    {
     /*************************************************************/
     /* If the word does not take up the entire line, then	  */
     /* truncate any trailing blanks that the word might contain. */
     /* Then delete the word from the current line.		  */
     /*************************************************************/

      word[last_letter - first_letter + 1] = '\0';

      line[first_letter]= '\0';
    }
  else
    {
     /***********************************************************/
     /* The word takes up the entire line, so bite off the last	*/
     /* character only, and send that back as a word.		*/
     /* Also need to override the normal check on whether the	*/
     /* cursor is inside a word. Since the word takes up the	*/
     /* entire line, it will ALWAYS be inside the word.		*/
     /*								*/
     /* Unfortunately, we only want the cursor to move to the	*/
     /* next line when it is on the last character of a word	*/
     /* that takes up the entire line. There is a special case	*/
     /* here that takes care of this.				*/
     /***********************************************************/

      word[0] = word[last_letter - first_letter];
      word[1] = '\0';
      line[last_letter] = '\0';

      if ( ac >= last_letter )
	{
	  *pos = 0;
	}
      else
	{
	  *pos = -1;
	}
    }

  return ( FI_SUCCESS );
}


/*---------------------------------------------------------*/

void _FI_fld_add_word_to_start_of_line (char  line[],
                                        char  word[])
{
  int	len;
  char	line2[3000];

  /**************************************************************/
  /* This routine appends a word to the beginning of a line.	*/
  /* If the word ends with a punctuation character, then a	*/
  /* double space will be inserted between it and the first	*/
  /* word on the line.  Otherwise, only a single space will	*/
  /* be inserted between it and the first word on the line.	*/
  /**************************************************************/

  len = strlen ( word ) - 1;

  if (	( word[len] == '.') ||
	( word[len] == '?') ||
	( word[len] == '!')  )
    {
      strcat ( word, _FI_two_spaces );
    }
  else
    {
      strcat ( word, _FI_one_space );
    }

  sprintf ( line2, "%s%s", word, line );

  strcpy ( line, line2 );
}


/****************************************************************/
/* _FI_fld_reshuffle_lines () -					*/
/*     This function will combine all lines starting at a	*/
/* specified point into one super-long line.  Then that line	*/
/* will be broken up along wrap boundaries.  This will have	*/
/* the effect of reshuffling the text in the display area.	*/
/*     This function is called when the form is resized, and	*/
/* the text needs to be sorted due to changing display size.	*/
/****************************************************************/

void _FI_fld_reshuffle_lines (struct FIfld_obj  *field,
                              int                start_line)
{
  char	combined_line[200000];	/*** FIX THIS !!! - JAJ/09/03/91 ***/
  char	heap[600000];		/*** FIX THIS !!! - JAJ/09/03/91 ***/
  int	par_ptr[10000];		/*** FIX THIS !!! - JAJ/09/03/91 ***/
  int	xx, yy;
  int	current_par;
  int	par_index;
  int	current_line;
  int	first_line_paragraph_flag;


  if ( field->FIfield.buffer_size > 0 )
    {
      current_par = 0;
      par_index = 0;
      current_line = start_line;

      if ( field->FIfield.buffer[start_line].paragraph )
	{
	  first_line_paragraph_flag = 1;
	}
      else
	{
	  first_line_paragraph_flag = 0;
	}

      while ( current_line < field->FIfield.buffer_size )
	{
#if defined(hp9000)
	  strcpy ( combined_line,
		 	(char *) field->FIfield.buffer[current_line].line );
#else
	  strcpy ( combined_line,
			    field->FIfield.buffer[current_line].line );
#endif
	  current_line++;

	  while ( (field->FIfield.buffer[current_line].paragraph== 0) &&
		  ( current_line < field->FIfield.buffer_size )        )
	    {
		/******************************************************/
		/* Combine all lines until the next paragraph marker  */
		/* into one large line.  If a line ends with a	      */
		/* punctuation character, insure that two spaces      */
		/* separate it from the start of the next line.	      */
		/* Otherwise insure that one space seperates it from  */
		/* the start of the next line.			      */
		/******************************************************/

	      _FI_fld_add_spaces_after_punct ( combined_line );

#if defined(hp9000)
	      strcat ( combined_line,
			(char *) field->FIfield.buffer[current_line].line );
#else
	      strcat ( combined_line,
			field->FIfield.buffer[current_line].line );
#endif

	      current_line++;
	    }

	  strcpy ( & heap[par_index], combined_line );
	  par_ptr[current_par] = par_index;

	  current_par++;
	  par_index += strlen ( combined_line ) + 1;
	}

	/************************************************/
	/* Clear all paragraph markers and broken word	*/
	/* flags, prior to the text being re-wrapped.	*/
	/************************************************/

      for ( xx = start_line; xx < field->FIfield.buffer_size; xx++ )
	{
	  field->FIfield.buffer[xx].paragraph = 100;
	}

	/********************************************************/
	/* Now perform a set_text function for each paragraph.	*/
	/* The field's buffer_size will be incremented after	*/
	/* each call.  The code uses this to determine where	*/
	/* each new paragraph will begin.			*/
	/********************************************************/

      current_line = start_line;

      for ( xx = 0; xx < current_par; xx++ )
	{
	  for ( yy= current_line; yy < field->FIfield.buffer_size; yy++)
	    {
	      current_line = -1;

	      if ( field->FIfield.buffer[yy].paragraph == 100 )
		{
		  current_line = yy;
		  break;
		}
	    }

	  if ( current_line == -1 )
	    {
	      current_line = field->FIfield.buffer_size;
	    }

	  FIfld_set_text ( (Form) field->FIgadget.form,
				field->FIgadget.label,
				current_line, 0,
				& heap [ par_ptr[xx] ], 0 );

		/*****************************************************/
	        /* The first paragraph reshuffled may or may not     */
	        /* be a complete paragraph.  If it is not, then its  */
		/* paragraph flag should not be set.  All other	     */
		/* paragraphs encountered are guaranteed to be	     */
	        /* complete paragraphs, so their marker must be set. */
		/*****************************************************/

	  if ( current_line == start_line )
	    {
	      if ( first_line_paragraph_flag )
		{
		  field->FIfield.buffer[current_line].paragraph = 1;
		}
	    }
	  else
	    {
	      field->FIfield.buffer[current_line].paragraph = 1;
	    }
	}

	/************************************************/
	/* If the buffer_size is smaller now that the	*/
	/* reshuffle has taken place, then get rid of	*/
	/* the kexcess lines that are no longer needed. */
	/************************************************/

      if ( field->FIfield.buffer[field->FIfield.buffer_size - 1].
						      paragraph == 100 )
	{
	  xx = field->FIfield.buffer_size - 1;

	  while ( field->FIfield.buffer[xx - 1].paragraph == 100 )
	    {
	      xx--;
	    }

	  _FI_fld_set_buffer ( field, xx, 1 );
	}

    }	/* If ( field->FIfield.buffer_size > 0 ) */
}


/**********************************************************************/
/* _FI_fld_reshuffle_up ( ) -					      */
/*								      */
/*     This function is used when a word has been deleted from a      */
/* paragraph, and the paragraph needs to be reshuffled.  Only a	      */
/* portion of this paragraph needs to be reshuffled.  As a result,    */
/* the paragraph may use 1 less line than before.  In this case,      */
/* the following paragraphs must all be shifted upwards 1 line to     */
/* fill the gap left by the vacated line.			      */
/*								      */
/*     The sequence of steps taken by this function is as follows:    */
/* First calculate how many lines there are before the next	      */
/* paragraph is reached.  Then form a super long line using lines     */
/* up to the next paragraph.  Then blank the line just before the     */
/* line containing the next paragraph marker.  Next, use	      */
/* FIfld_set_text ( ) to write the newly wrapped data.		      */
/*								      */
/*     At this point see if the last line is still blank. If it is,   */
/* then the following paragraphs need to be shifted upwards one line. */
/**********************************************************************/

void _FI_fld_reshuffle_up (struct FIfld_obj  *field,
                           int                start_line)
{
  char	combined_line[200000];	/*** FIX THIS !!! - JAJ/09/03/91 ***/
  int	xx, lines_to_shuffle, next_paragraph_line;
  int	first_line_paragraph_flag;
  int start_line_delete, lines_to_delete, last_set_text_row;

  if ( field->FIfield.buffer[start_line].paragraph )
    {
      first_line_paragraph_flag = 1;
    }
  else
    {
      first_line_paragraph_flag = 0;
    }

  lines_to_shuffle = 1;
  next_paragraph_line = -1;

  for ( xx = start_line + 1; xx < field->FIfield.buffer_size; xx++ )
    {
      if ( field->FIfield.buffer[xx].paragraph == 1 )
	{
	  next_paragraph_line = xx;
	  break;
	}
      else
	{
	  lines_to_shuffle++;
	}
    }

  combined_line[0]= '\0';

  for ( xx = 0; xx < lines_to_shuffle; xx++ )
    {
	/**************************************************************/
	/* Combine all lines until the next paragraph marker into one */
	/* large line. If a line ends with a punctuation character,   */
	/* Insure that two spaces seperate it from the start of the   */
	/* next line. Otherwise insure that one space seperates it    */
	/* from the start of the next line.			      */
	/**************************************************************/

      _FI_fld_add_spaces_after_punct ( combined_line );

#if defined(hp9000)
      strcat ( combined_line,
	  (char *) field->FIfield.buffer [ start_line + xx ].line );
#else
      strcat ( combined_line,
		      field->FIfield.buffer [ start_line + xx ].line );
#endif
    }

	/**************************************************************/
	/* Blank last line of the current paragraph prior to the wrap */
	/**************************************************************/

  field->FIfield.buffer[start_line + lines_to_shuffle - 1].line[0]='\0';

  FIfld_set_text ( (Form) field->FIgadget.form,
			field->FIgadget.label,
			start_line, 0, combined_line, 0 );

  last_set_text_row = _FI_fld_set_text_last_row;
               
  if ( first_line_paragraph_flag == 1 )
    {
      field->FIfield.buffer[start_line].paragraph = 1;
    }
  else
    {
      field->FIfield.buffer[start_line].paragraph = 0;
    }

   /**********************************************************/
   /* sml:10-04-94:                                          */
   /*  Borrowed from I/FORMS                                 */
   /*                                                        */
   /* sml:09-10-93                                           */
   /*  Code from Randy Hopper (fed sys)                      */
   /*  Delete any lines that were used before but aren't     */
   /*  used now.  Note that _FI_fld_set_text_last_row is set */
   /*  by the previous FIfld_set_text call                   */
   /**********************************************************/

   start_line_delete = last_set_text_row + 1;
   lines_to_delete = start_line + lines_to_shuffle - 
						last_set_text_row - 1;

/***** sml:09-10-93 use lines_to_delete
    sml:10-04-94:                                          
     Borrowed from I/FORMS                                 
   if (field->FIfield.buffer[start_line + lines_to_shuffle - 1].line[0] == 0)
*****/

   if (lines_to_delete > 0)
    {
      if ( next_paragraph_line == -1 )
	{
		/*********************************/
		/* There are no other paragraphs */
		/*********************************/

		/***** sml:09-10-93 use lines_to_delete
    sml:10-04-94:                                          
     Borrowed from I/FORMS                                 
	   _FI_fld_set_buffer ( field,
				field->FIfield.buffer_size - 1, 1 );
		*****/
         _FI_fld_set_buffer (field, 
			field->FIfield.buffer_size - lines_to_delete, 1);
	}

/********************************************************
	sml:10-04-94 Use Randy Hopper code 
		(start_line_delete and lines_to_delete)
*********************************************************/

      else
	{
		/***************************************/
		/* Need to shift buffer up by one line */
		/***************************************/

	  for ( xx = start_line_delete;
			xx < field->FIfield.buffer_size - lines_to_delete; xx++ )
	    {
	      _FI_fld_add_to_line ( field, xx,
		    strlen ( (char *)field->FIfield.buffer[xx + lines_to_delete].line ) + 2 );

#if defined(hp9000)
	      strcpy ( (char *) field->FIfield.buffer[xx].line,
	  	 (char *) field->FIfield.buffer[xx + lines_to_delete].line );
#else
	      strcpy ( field->FIfield.buffer[xx].line,
			field->FIfield.buffer[xx + lines_to_delete].line );
#endif

	      field->FIfield.buffer[xx].sel =
				field->FIfield.buffer[xx + lines_to_delete].sel;

	      field->FIfield.buffer[xx].paragraph =
				field->FIfield.buffer[xx + lines_to_delete].paragraph;
	    }

		/************************/
		/* Get rid of extra line */
		/************************/

	  _FI_fld_set_buffer ( field,
			field->FIfield.buffer_size - lines_to_delete, 1 );

		/************************/
		/* Repaint viewing area */
		/************************/

	  _FI_fld_refresh_wrap_data ( field,
				last_set_text_row + 1 );
	}
    }
}

/****************************************************************/
/* _FI_fld_reshuffle_down ( ) -					*/
/*								*/
/* This function is used when a word has been added to a	*/
/* paragraph, and the paragraph needs to be reshuffled.  Only a	*/
/* portion of this paragraph needs to be reshuffled.  As a	*/
/* result, the paragraph may use 1 more line than before.  In	*/
/* this case, the following paragraphs must all be shifted	*/
/* downwards 1 line to allow for the new line.			*/
/*								*/
/* The sequence of steps taken by this function is as follows:	*/
/*     First, calculate how many lines there are before the	*/
/* next paragraph is reached.  Then form a super long line	*/
/* using lines up to the next paragraph.  Then save the first	*/
/* line of the new paragraph.  Then blank the line that was	*/
/* just saved.  Next use FIfld_set_text to write the new	*/
/* wrapped data.						*/
/*								*/
/* At this point see if the line is still blank.  If so, then	*/
/* simply replace it with the line that was saved.  If the line	*/
/* is not blank, then a new line must be inserted at this point,*/
/* then lines must be shifted downwards, and the saved line	*/
/* restored to its proper place.				*/
/****************************************************************/

void _FI_fld_reshuffle_down (struct FIfld_obj *field,
                             int               start_line)
{
  char	combined_line[200000];	/*** FIX THIS !!! - JAJ/09/03/91 ***/
  char	save_line[2000];
  int	xx, lines_to_shuffle, next_paragraph_line;
  int	first_line_paragraph_flag;
  Window window = XWINDOW ( field );

  int start_line_delete = 0, lines_to_delete = 0, last_set_text_row;



  if ( field->FIfield.buffer[start_line].paragraph )
    {
      first_line_paragraph_flag = 1;
    }
  else
    {
      first_line_paragraph_flag = 0;
    }

  lines_to_shuffle = 1;
  next_paragraph_line = -1;

  for ( xx = start_line + 1; xx < field->FIfield.buffer_size; xx++ )
    {
      if ( field->FIfield.buffer[xx].paragraph == 1 )
	{
	  next_paragraph_line = xx;
	  break;
	}
      else
	{
	  lines_to_shuffle++;
	}
    }

  combined_line[0] = '\0';

  for ( xx = 0; xx < lines_to_shuffle; xx++ )
    {
	/**************************************************************/
	/* Combine all lines until the next paragraph marker into one */
	/* large line.  If a line ends with a punctuation character,  */
	/* Insure that two spaces seperate it from the start of the   */
	/* next line.  Otherwise, insure that one space seperates it  */
	/* from the start of the next line.			      */
	/**************************************************************/

      _FI_fld_add_spaces_after_punct ( combined_line );

#if defined(hp9000)
      strcat ( combined_line,
	(char *) field->FIfield.buffer[start_line + xx].line );
#else
      strcat ( combined_line,
			field->FIfield.buffer[start_line + xx].line );
#endif
    }

	/*******************************************************/
	/* Save first line of the next paragraph prior to wrap */
	/*******************************************************/

  if ( next_paragraph_line != -1 )
    {
#if defined(hp9000)
      strcpy ( save_line,
		(char *) field->FIfield.buffer[next_paragraph_line].line );
#else
      strcpy ( save_line,
		field->FIfield.buffer[next_paragraph_line].line );
#endif

	/************************************************************/
	/* Blank first line of the next paragraph prior to the wrap */
	/************************************************************/

      field->FIfield.buffer[next_paragraph_line].line[0]= '\0';
    }

  FIfld_set_text ( (Form) field->FIgadget.form,
			field->FIgadget.label,
			start_line, 0, combined_line, 0 );

  last_set_text_row = _FI_fld_set_text_last_row;
                   
  if ( first_line_paragraph_flag == 1 )
    {
      field->FIfield.buffer[start_line].paragraph = 1;
    }
  else
    {
      field->FIfield.buffer[start_line].paragraph = 0;
    }

   /***********************************************************/
   /* sml:10-04-94:                                          */
   /*  Borrowed from I/FORMS                                 */
   /*                                                        */
   /* sml:09-10-93                                            */
   /*  Code from Randy Hopper (fed sys)                       */
   /*  Delete any lines that were used before but aren't      */
   /*  used now.  Note that _FI_fld_set_text_last_row is set  */
   /*  by the previous FIfld_set_text call.                   */
   /***********************************************************/

  start_line_delete = last_set_text_row + 1;
  lines_to_delete = start_line + lines_to_shuffle -
						last_set_text_row - 1;

  if ( lines_to_delete > 0 ) /* adding this if statement */
  {
	if (next_paragraph_line == -1) /* there are no other paragraphs */
	{
	  _FI_fld_set_buffer(field,
				field->FIfield.buffer_size - lines_to_delete, 1);
	}
	else /* need to shift buffer up by one or more lines */
	{
		/*****************************************/
		/* Need to shift buffer down by one line */
		/*****************************************/

	  for (xx = start_line_delete;
			xx < field->FIfield.buffer_size - lines_to_delete; xx++)
	  {
		_FI_fld_add_to_line(field, xx, 
			strlen((char *)field->FIfield.buffer[xx+lines_to_delete].line) + 2);

#if defined(hp9000)
		strcpy((char *) field->FIfield.buffer[xx].line,
		   (char *) field->FIfield.buffer[xx+lines_to_delete].line);
#else
		strcpy(field->FIfield.buffer[xx].line,
			field->FIfield.buffer[xx+lines_to_delete].line);
#endif

		field->FIfield.buffer[xx].sel = 
			field->FIfield.buffer[xx+lines_to_delete].sel;

		field->FIfield.buffer[xx].paragraph = 
			field->FIfield.buffer[xx+lines_to_delete].paragraph;
	  }

	  next_paragraph_line -= lines_to_delete;

	  /* Get rid of the extra lines */
	
	  _FI_fld_set_buffer(field,
			field->FIfield.buffer_size - lines_to_delete, 1);
	}

		/************************/
		/* Repaint viewing area */
		/************************/

	_FI_fld_refresh_wrap_data(field, last_set_text_row+1);
  } /* end of if lines_to_delete > 0 */

  /* Now go ahead and add that extra line, if we need to */

   if ( next_paragraph_line != -1 )
      if ( field->FIfield.buffer[next_paragraph_line].line[0] == '\0' )
      {
		/****************************************/
		/* Restore saved line which was blanked */
		/****************************************/
     
#if defined(hp9000)
         strcpy ( (char *) field->FIfield.buffer[next_paragraph_line].line, 
							save_line );
#else
         strcpy ( field->FIfield.buffer[next_paragraph_line].line, 
							save_line );
#endif

         _FI_fld_refresh_row ( field, window, next_paragraph_line );

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
          if (!_FI_dont_flush)
            XFlush ( _FI_display );
    }
      else
    {
         _FI_fld_set_buffer ( field, 
				field->FIfield.buffer_size + 1, 1 );
         
		/*****************************************/
		/* Need to shift buffer down by one line */
		/*****************************************/

     	 for ( xx = field->FIfield.buffer_size - 1; 
     	      xx > next_paragraph_line + 1; xx-- )
     	 {
            _FI_fld_add_to_line ( field, xx,
		     strlen ( (char *)field->FIfield.buffer[xx - 1].line) + 2 );
#if defined(hp9000)
            strcpy ((char *) field->FIfield.buffer[xx].line,
		(char *) field->FIfield.buffer[xx - 1].line);
#else
            strcpy (field->FIfield.buffer[xx].line,
				field->FIfield.buffer[xx - 1].line);
#endif

            field->FIfield.buffer[xx].sel = 
				field->FIfield.buffer[xx - 1].sel;

            field->FIfield.buffer[xx].paragraph = 
                     field->FIfield.buffer[xx - 1].paragraph;
         }
    
         field->FIfield.buffer[next_paragraph_line + 1].paragraph = 1; 
           
         _FI_fld_add_to_line ( field, next_paragraph_line + 1, 
						strlen (save_line) + 2 );

#if defined(hp9000)
         strcpy ((char *) field->FIfield.buffer[next_paragraph_line + 1].line, 
							save_line );
#else
         strcpy ( field->FIfield.buffer[next_paragraph_line + 1].line, 
							save_line );
#endif

		/************************/
		/* Repaint viewing area */
		/************************/

         _FI_fld_refresh_wrap_data (field, next_paragraph_line + 1);
      }
}



/*--------------------------------------------------------------------*/

int _FI_fld_remove_first_word_from_line (char  line[])
{
  int	first_letter;
  int	last_letter;

  /**************************************************************/
  /* This function removes the first word from a line of text.	*/
  /* It removes any blank characters previous to the word.  It	*/
  /* also removes any blank characters after the word.		*/
  /**************************************************************/

  first_letter = 0;

  while ( ( first_letter < strlen ( line ) )	&&
	  ( line[first_letter] == ' ' )		 )
    {
      first_letter++;
    }

  if ( line[first_letter] && line[first_letter] != ' ' )
    {
      last_letter = first_letter;

      while ( ( last_letter < strlen ( line ) )		&&
	      ( line[last_letter] != ' ')		 )
	{
	  last_letter++;
	}

      if ( last_letter < strlen ( line ) )
	{
	  first_letter = last_letter + 1;
	}
      else
	{
	  first_letter = last_letter;
	}

      while ( ( first_letter < strlen ( line ) )	&&
	      ( line[first_letter] == ' ' )		 )
	{
	  first_letter++;
	}

      strcpy ( line, & line[first_letter] );
    }

  return ( FI_SUCCESS );
}


/*---------------------------------------------------------*/

void _FI_fld_get_first_word_of_line (char  *line,
                                     char   word[])
{
  int first_letter;
  int last_letter;

	/************************************************/
	/* This function determines what the first word	*/
	/* on a line is.  It skips any leading blanks	*/
	/* prior to the first word on the line.		*/
	/************************************************/

  first_letter = 0;

  while ( ( first_letter < strlen ( line ) )	&&
	  ( line[first_letter] == ' ' )		 )
    {
      first_letter++;
    }

  if ( line[first_letter] && line[first_letter] != ' ' )
    {
      last_letter = first_letter;

      while ( ( last_letter < strlen ( line ) )		&&
	      ( line[last_letter] != ' ')		 )
	{
	  last_letter++;
	}

      strncpy ( word, & line[first_letter],
				last_letter - first_letter + 1 );

      word[last_letter - first_letter + 1] = '\0';  /* End of string */
    }
  else
    {
      word[0] = '\0';	/* NULL string */
    }
}


/*--------------------------------------------------------------------*/

void _FI_fld_calc_remaining_space (int    nvc,
                                   char  *line,
                                   int   *blank_spaces)
{
  int xx;

	/*************************************************************/
	/* This function calculates the number of free spaces on     */
	/* a line of text.  It calculates where the last word on the */
	/* line ends.  Then it subtracts this number from the        */
	/* number of visible columns in the row.  Thus any trailing  */
	/* blank characters on the line are not a factor.	     */
	/*************************************************************/

  if ( line[0] == '\0' )
    {
      *blank_spaces = nvc;
    }
  else
    {
      xx = strlen ( line ) - 1;

      while ( ( xx > 0 ) && ( line[xx] == ' ' ) ) 
	{
	  xx--;
	}

      *blank_spaces = nvc - xx;
    }
}
