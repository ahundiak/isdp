#include "FImin.h"

#include "FIscroll.h"
#include "FIbtn.h"
#include "FImcf.h"
#include "FIfield.h"
#include "FEI.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"


/*====================================================================*/

int _FI_fld_get_field (struct FIform_obj  *form,
                       int                 label,
                       int                 col,
                       struct FIfld_obj  **field)
{
  struct FIgadget_obj *gadget;
  struct FImcf_obj *multicol;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type == FI_FIELD )
    {
      *field = (struct FIfld_obj *) gadget;
    }
  else if ( gadget->FIgadget.type == FI_MULTI_COL )
    {
      multicol = (struct FImcf_obj *) gadget;

      if ( col == -1 )
	{
	  *field = (struct FIfld_obj *) multicol->FIgroup.gadgets[
			      multicol->FIgroup.current_active_gadget];
	}
      else
	{
	  if (( col < 0 ) || ( col >= (int)multicol->FImcf.ncol ))
	    {
	      return ( FI_INVALID_COL );
	    }

	  *field = (struct FIfld_obj *) multicol->FIgroup.gadgets[col];
	}
    }
  else
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_get_select (Form  form,
                      int   label,
                      int   row,
                      int   col,
                      int  *sel_flg)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
						col, &field );
  if ( status )
    {
      return ( status );
    }

  if ( ( row < field->FIfield.buffer_size ) && ( row >= 0 ) )
    {
      *sel_flg = field->FIfield.buffer[row].sel;
    }
  else
    {
      *sel_flg = 0;
      return ( FI_INVALID_ROW );
    }

  return ( FI_SUCCESS );
}


/********************************************************/
/* This function returns the length of the data at row	*/
/* so application can malloc space to hold it.		*/
/********************************************************/

int FIfld_get_text_length (Form   form,
                           int    label,
                           int    row,
                           int    col,
                           int   *length)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form,
					label, col, &field );
  if ( status )
    {
      return ( status );
    }

	/*** <pds-2/21/90> Return a 1 even if the	***/
	/***  buffer size has not been set up yet.	***/

  if ( ( row < field->FIfield.buffer_size ) && ( row >= 0 ) )
    {
      if ( field->FIfield.buffer )
	{
          /* GMD 3/20/92   Added check for NULL line */

          if (field->FIfield.buffer[row].line)
	     *length = strlen ( (char *)field->FIfield.buffer[row].line ) + 1;
          else
             *length = 1;
	}
      else
	{
	  *length = 1;
	}
    }
  else
    {
      *length = 0;
		      /* GMD 7/12/91   Added (row > 0) check for MAP2 */
      if ( row > 0 )  /* In case field has not been visited yet.      */
	{
	  return ( FI_INVALID_ROW );
	}
    }
  return ( FI_SUCCESS );
}


/*====================================================================*/

/* This function gets the data at row in the field. */

int FIfld_get_text (Form          form,
                   int            label,
                   int            row,
                   int            col,
                   int            num_ch,
                   unsigned char  text[],
                   int           *sel_flg,
                   int           *r_pos)
{
  struct FIfld_obj *field;
  int		    status;
  unsigned char	    temp_text[30000];



  status = _FI_fld_get_field ( (struct FIform_obj *) form,
					label, col, &field );
  if ( status )
    {
      return ( status );
    }

  if (  field->FIfield.buffer_size		&&
	( row < field->FIfield.buffer_size )	&&
	( row >= 0 )				 )
    {
      /* GMD 3/20/92    Add fix for Null string problem that   */
      /*                Parker located.  Apparently when you   */
      /*                fld_set_num_rows, it does not actually */
      /*                allocate a 64 byte chunk at that time. */
      /*                So when you request a line of text     */
      /*                that has not been initialized here,    */
      /*                you have problems.                     */

      if (field->FIfield.buffer[row].line != NULL)
      {

#if defined(hp9000)
         strncpy ( (char *) text, 
		(char *) field->FIfield.buffer[row].line, num_ch );
#else
         strncpy ( text, field->FIfield.buffer[row].line, num_ch );
#endif
         text[num_ch - 1]= '\0';

		/*---------- Hebrew 01-07-90 --------------*/
         if ( field->FIfield.flags.right_to_left		&&
	      field->FIfield.flags.reverse_output		 )
	 {
	    _FI_flip_string ( (char *)text, (char *)temp_text );
#if defined(hp9000)
	    strcpy ( (char *) text, (char *) temp_text );
#else
	    strcpy ( text, temp_text );
#endif
	 }
      }
      else
         text[0] = '\0';    /* NULL string */


	/************************************************/
	/* Append CR to string if the following line	*/
	/* has a paragraph marker. ( Wrap mode )	*/
	/************************************************/

      if ( ( row + 1 < field->FIfield.buffer_size )		&&
	   ( field->FIfield.flags.wrap == 1 )			&&
	   ( field->FIfield.buffer[row + 1].paragraph == 1 )	 )
	{
#if defined(hp9000)
	  strcat ( (char *) text, "\n" );
#else
	  strcat ( text, "\n" );
#endif
	}

      *sel_flg = field->FIfield.buffer[row].sel;

      if ( ( row >= field->FIfield.roff )			&&
	   ( row < field->FIfield.roff + field->FIfield.nvr )	 )
	{
	  *r_pos = row - field->FIfield.roff;
	}
      else
	{
	  *r_pos = -1;
	}

	/*** MAP2 - GMD 05/09/91  				***/
	/*** Removed padding spaces for right and center	***/
	/*** justification fields.  Now the user only gets the	***/
	/*** string with no padding.				***/

      if ( ( field->FIgadget.justification == FI_RIGHT_JUSTIFIED  )  ||
           ( field->FIgadget.justification == FI_CENTER_JUSTIFIED )   )
	{
	  unsigned char *ch = & text[0];

	  while ( *ch && ( *ch == ' ' ) )
	    {
	      ch++;
	    }

#if defined(hp9000)
	  strcpy ( (char *) temp_text, (char *) ch );
	  strcpy ( (char *) text, (char *) temp_text );
#else
	  strcpy ( temp_text, ch );
	  strcpy ( text, temp_text );
#endif
	}
    }
  else
    {
      text[0] = '\0';

      if ( field->FIfield.buffer_size )
	{
	  *sel_flg = -1;
	  *r_pos = -1;
	  return ( FI_INVALID_ROW );
	}
      else
	{
	  *sel_flg = 0;
	  *r_pos = 0;
	}
    }
  return ( FI_SUCCESS );
}


/********************************************************************/
/*** _FI_fld_do_set_text_add_to_line ( )-  This is just some code ***/
/***  that is called several times in FIfld_set_text( ) that	  ***/
/***  I put into a function call to reduce the size of the code.  ***/
/********************************************  JAJ:09/04/91 *********/

static void _FI_fld_do_set_text_add_to_line (struct FIfld_obj  *field,
                                             int                roff,
                                             int            row_plus_roff,
                                             unsigned char     *t_line,
                                             int            paragraph_flag)
{
  if ( ( roff > 0 ) && ( row_plus_roff >= field->FIfield.buffer_size ) )
    {
      _FI_fld_set_buffer ( field, row_plus_roff + 1, 1 );
    }

  _FI_fld_add_to_line ( field, row_plus_roff, strlen ( (char *)t_line ) + 2 );

#if defined(hp9000)
  strcpy ( (char *) field->FIfield.buffer [ row_plus_roff ].line, 
	(char *) t_line );
#else
  strcpy ( field->FIfield.buffer [ row_plus_roff ].line, t_line );
#endif

  if ( paragraph_flag == 1 )
    {
      field->FIfield.buffer[ row_plus_roff ].paragraph = 1;
    }
  else
    {
      field->FIfield.buffer[ row_plus_roff ].paragraph = 0;
    }
}


/*==================================================*/
/* This function sets the data at row in the field. */
/*==================================================*/

int FIfld_set_text (Form  form,
                    int   label,
                    int   row,
                    int   col,
                    char *apptext,
                    int   sel_flg)
{
  extern int _FI_fld_set_text_last_row;

  Window		 window;
  int			 len, prev_row, status, save_ar;
  int			 refresh_line = 0;
  struct FIgadget_obj	*gadget;
  struct FIfld_obj	*field;
  struct FImcf_obj	*multicol;
  char			 text[50000];


  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type == FI_MULTI_COL )
    {
      multicol = (struct FImcf_obj *) gadget;
    }
  else
    {
      multicol = 0;
    }

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
						col, &field );
  if ( status )
    {
      return ( status );
    }

  window = XWINDOW ( field );

		/* Hebrew 01-07-90 */

  if (  field->FIfield.flags.right_to_left	&&
	field->FIfield.flags.reverse_input 	 )
    {
      _FI_flip_string ( apptext, text );
    }
  else
    {
      strcpy ( text, apptext );
    }

  if ( row < 0 )
    {
      row = 0;
    }
  else if ( field->FIfield.nr && ( row > field->FIfield.nr ) )
    {
      row = field->FIfield.nr - 1;
    }
  if ( row >= field->FIfield.buffer_size )
    {
			/**********************/
			/* Add new blank line */
			/**********************/

      _FI_fld_set_buffer ( field, row + 1, 1 );
    }

  if ( ! ( field->FIfield.flags.wrap ) )
    {
		/* Allocate more space ( if	*/
		/* needed ) to hold text.	*/

      _FI_fld_add_to_line ( field, row, strlen ( text ) + 2 );
    }

	/*** pds <12/13/89> Changed from strlen () ***/

  len = FI_strlen ( text, field->FIgadget.font_type );


  /* PJW - fix coff too */

  /*******************************************************/
  /* Move cursor to end of line if new string is shorter */
  /* than the current cursor position.			 */
  /* Else move cursor to the beginning of the line.	 */
  /*******************************************************/

  if ( ( row == field->FIfield.ar ) && ( len < field->FIfield.ac ) )
    {
      field->FIfield.ac = len;
      if ( len )
	{
	  if ( field->FIfield.coff >= len )
	    {
	      field->FIfield.coff = len - 1;
	    }
	}
      else
	{
	  field->FIfield.coff = 0;
	}
    }

  /****************************************************************/
  /* If length of string is greater than the column width, decide */
  /* what to do based on whether or not wrap mode is set.	  */
  /****************************************************************/

	/*** <pds-2/26/90> Was not parsing newlines ('\n')	***/
	/*** if the len was less than 'nc'			***
	  if (( field->FIfield.nc )&&( len >= field->FIfield.nc ))
	***********************************************************/

  if ( field->FIfield.nc )
    {
      if ( field->FIfield.flags.wrap )
	{
	  unsigned char t_line[500];
  	  unsigned char	cc;
	  int		ii;
	  int		roff;  /* additional rows needed to hold text */
	  int		paragraph_flag;
	  int		marker;
	  int		last_space;
	  int		continue_loop;

	  roff		 = 0;
	  marker	 = 0;
	  last_space	 = -1;



	  /**************************************************/
	  /* sml:10-05-94                                   */
      /*  Check if this is being placed in middle of    */
	  /*  white space.  If so, set the paragraph        */
	  /*  marker on.  This avoids losing all the white  */
	  /*  space when user is typing in text.            */
	  /**************************************************/
	  if (field->FIfield.flags.wrap)
	  {
		if (row > 0)
		{
#if defined(hp9000)
		  if (field->FIfield.buffer[row - 1].line == NULL ||
		   strcmp((char *)field->FIfield.buffer[row - 1].line, "") == 0)
#else
		  if (field->FIfield.buffer[row - 1].line == NULL ||
			strcmp(field->FIfield.buffer[row - 1].line, "") == 0)
#endif
		  {
			field->FIfield.buffer[row].paragraph = 1;
		  }
/***
		  else
		  {
			field->FIfield.buffer[row].paragraph = 0;
		  }
***/
	 	}
/***
		else
		{
		  field->FIfield.buffer[row].paragraph = 0;
		}
***/
	  }

          /* Check to see if the row already had a paragraph marker */
          /* instead of blindly setting it to zero.  GMD 12/2/91    */

	  paragraph_flag = field->FIfield.buffer[row].paragraph;

	  continue_loop  = 1;

	  while ( continue_loop )
	    {
		/******************************************************/
		/* Scan remainder of line.  For each character, check */
		/* to see if it is a newline.  If so, take everything */
		/* up to that point as the current line.  If the      */
		/* character is a space, make a note of its position, */
		/* in case the next word exceeds line width.  If      */
		/* there are no spaces, then the super-long word must */
		/* be cut at the window boundary.		      */
		/******************************************************/

	      ii = 0;

	      do
		{
		  cc = text[marker + ii];

		  if ( cc == ' ' )	/* Handle space */
		    {
		      last_space = ii;
		    }
		  else if ( cc == '\n')	/* Handle Carriage Return */
		    {
#if defined(hp9000)
		      strncpy ( (char *) t_line, & ( text[marker]), ii );
#else
		      strncpy ( t_line, & ( text[marker]), ii );
#endif
		      t_line[ii]= '\0';

						/*** JAJ:09/04/91 ***/
		      _FI_fld_do_set_text_add_to_line ( field, roff,
				row + roff, t_line, paragraph_flag );

			/* Next line will have a paragraph marker */
		      paragraph_flag = 1;

		      marker    += ( ii + 1 );
		      last_space = -1;
		      roff++;

		      if ( marker >= len )
			{
			  continue_loop = 0;
			}

		      break; /*** out of 'while ( 1 )' loop ***/

		    }	/* END Handle Carriage Return */

						/********************/
						/* End of view area */
						/********************/
		  else if ( ii >= ( field->FIfield.nvc ) - 1 )
		    {
		      if ( last_space != -1 )
			{
#if defined(hp9000)
			  strncpy ((char *) t_line, &text[marker], last_space );
#else
			  strncpy ( t_line, &text[marker], last_space );
#endif
			  t_line[last_space]= '\0';

						/*** JAJ:09/04/91 ***/
			  _FI_fld_do_set_text_add_to_line ( field, roff,
				row + roff, t_line, paragraph_flag );

				/**********************************/
				/*** Next line will NOT have	***/
				/*** a paragraph marker.	***/
				/**********************************/
			  paragraph_flag = 0;

			  if ( ( marker + last_space + 1 ) >= len )
			    {
			      continue_loop = 0;
			    }
			  else
			    {
			      marker += last_space + 1;
			      last_space = -1;
			      roff++;
			    }

		          break; /*** out of 'while ( 1 )' loop ***/
			}
		      else	/* Super-long word to be broken apart */
			{
                     /*********************************************/
                     /*sml:07-20-94:TR249404137                   */
                     /* one-character wide wrap field causes      */
                     /* crash.  This isn't perfect, but it avoids */
                     /* the crash.                                */
                     /*********************************************/
                          if (field->FIfield.nvc == 1)
                          {
#if defined(hp9000)
                       	    strncpy ((char *) t_line, &(text[marker]), 1);
#else
                       	    strncpy (t_line, &(text[marker]), 1);
#endif
                      	    t_line[1] = '\0';
                          }
                     /* end of fix for TR 24940XXX                */
                          else
                          {
#if defined(hp9000)
			  	    strncpy ( (char *) t_line, & text[marker],
							field->FIfield.nvc - 1 );
#else
			  			    strncpy ( t_line, & text[marker],
							field->FIfield.nvc - 1 );
#endif
                          }
			  t_line[field->FIfield.nvc - 1] = '\0';

						/*** JAJ:09/04/91 ***/
			  _FI_fld_do_set_text_add_to_line ( field, roff,
				row + roff, t_line, paragraph_flag );

				/**********************************/
				/*** Next line will NOT have	***/
				/*** a paragraph marker.	***/
				/**********************************/

			  paragraph_flag = 0;

			  if ( ( marker + ii ) >= len )
			    {
			      continue_loop = 0;
			    }
                     /*********************************************/
                     /*sml:07-20-94:TR249404137                   */
                     /* one-character wide wrap field causes      */
                     /* crash.  This isn't perfect, but it avoids */
                     /* the crash.                                */
                     /*********************************************/
                         else if (/*marker == 0 && ii == 0 &&*/
                             field->FIfield.nvc == 1)
                         {
                             marker += ii + 1;
                      	     roff++;
                      	     break; /*ii = -1000;*/
                         }
                     /* end of fix for TR24940XXX                 */
			  else
			    {
			      marker += ii;
			      roff++;
			    }

		          break; /*** out of 'while ( 1 )' loop ***/
			}
		    }
		  else if ( ( marker + ii ) == len )   /* End of line */
		    {
		      continue_loop = 0;

#if defined(hp9000)
		      strcpy ( (char *) t_line, & text[marker] );
#else
		      strcpy ( t_line, & text[marker] );
#endif

						/*** JAJ:09/04/91 ***/
		      _FI_fld_do_set_text_add_to_line ( field, roff,
				row + roff, t_line, paragraph_flag );

		      break; /*** out of 'while ( 1 )' loop ***/
		    }

		  ii++;
		}
	      while ( 1 );

	    }	/*** END continue_loop ***/

          /**************************************************/
          /* sml:09-10-93                                   */
          /*  Code from Randy Hopper (fed sys)              */
          /*  When we call this routine from                */
          /*  _FI_fld_reshuffle_..., we need to know how    */
          /*  many lines our reformatted paragraph took up  */
          /*  so that we can delete any lines that were     */
          /*  used before and aren't used now.              */
          /**************************************************/

                  _FI_fld_set_text_last_row = row + roff;


	  if ( ( window != None )				   &&
	       field->FIgadget.form->displayed			   &&
		( row >= field->FIfield.roff )			   &&
		( row < field->FIfield.roff + field->FIfield.nvr ) &&
		IT_IS_DISPLAYED ( field )			   &&
		IT_IS_DISPLAYABLE ( field )			    )
	    {
	      _FI_fld_refresh_wrap_data ( field, row );
	    }
	}
      else if ( len >= field->FIfield.nc )	/*** NO_wrap_crap ***/
	{
	  /*** <pds-12/13/89> Calculate actual bytes to copy ***/
	  int len2;

	  len2 = FI_move_index ( text, 0, field->FIfield.nc,
					field->FIgadget.font_type );

	  if ( len2 < 0 )
	    {
	      len2 = strlen ( text );
	    }

#if defined(hp9000)
	  strncpy ( (char *) field->FIfield.buffer[row].line, text, len2 );
#else
	  strncpy ( field->FIfield.buffer[row].line, text, len2 );
#endif

	  field->FIfield.buffer[row].line[len2]= '\0';
	}
    }

  if (	 ! field->FIfield.nc					      ||
	( ( len < field->FIfield.nc ) && ! field->FIfield.flags.wrap ) )
	/* No wrap mode or string length   */
	/* less than column width	   */
    {
	/* Allocate more space ( if needed ) to hold text. */

      if ( field->FIfield.flags.wrap )
	{
	  _FI_fld_add_to_line ( field, row, len + 2 );
	}

#if defined(hp9000)
      strcpy ( (char *) field->FIfield.buffer[row].line, text );
#else
      strcpy ( field->FIfield.buffer[row].line, text );
#endif

      field->FIfield.buffer[row].paragraph = 0;

      if ( field->FIgadget.justification )
	{
	  save_ar = field->FIfield.ar;
	  field->FIfield.ar = row;

	  _FI_fld_justify_data ( field );

	  field->FIfield.ar = save_ar;
	}
    }

  prev_row = -1;

  if ( ( field->FIfield.mode == FI_SINGLE_SELECT )	&&
	( field->FIfield.prev_sel > -1 )		 )
    {
      if ( sel_flg )
	{
	  field->FIfield.buffer[field->FIfield.prev_sel].sel = 0;
	  prev_row = field->FIfield.prev_sel;
	}
      else if ( field->FIfield.prev_sel == row )
	{
	  field->FIfield.prev_sel = -1;
	}
    }

  if ( sel_flg )
    {
      field->FIfield.prev_sel = row;
    }

  field->FIfield.buffer[row].sel = sel_flg;
  if ( field->FIfield.flags.roll_thru )
    {
      field->FIfield.ar = row;
      field->FIfield.roff = row;
    }

  if (	( window != None )					&&
	( row >= field->FIfield.roff )				&&
	( row < field->FIfield.roff + field->FIfield.nvr )	 )
    {
      if ( gadget->FIgadget.type == FI_MULTI_COL )
	{
	  if ( IT_IS_DISPLAYABLE ( multicol ) )
	    {
	      refresh_line = 1;
	    }
	  else
	    {
	      refresh_line = 0;
	    }
	}
      else if ( gadget->FIgadget.type == FI_FIELD )
	{
	  if ( IT_IS_DISPLAYABLE ( field ) )
	    {
	      refresh_line = 1;
	    }
	  else
	    {
	      refresh_line = 0;
	    }
	}
    }
  else
    {
      refresh_line = 0;
    }

  if ( refresh_line )
    {
      _FI_fld_refresh_row ( field, window, row );

      if ( prev_row > -1 )
	{
	  _FI_fld_refresh_row ( field, window, prev_row );
	}

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
      if (!_FI_dont_flush)
        XFlush ( _FI_display );
    }

   /** <pds-3/27/91> Now reflect the changes in linked gadgets **/

   _FI_g_pass_data ( gadget );

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_get_value (Form     form,
                     int      label,
                     int      row,
                     int      col,
                     double  *value,
                     int     *sel_flg,
                     int     *r_pos)
{
  struct FIfld_obj *field;
  int		    status;
  int		    non_spaces; 
  unsigned char    *ch;


  status = _FI_fld_get_field ( (struct FIform_obj *) form,
					label, col, &field );
  if ( status )
    {
      return ( status );
    }

  if ( field->FIfield.field_type == FI_ALPHA )
    {
      return ( FI_ILLEGAL_VALUES );
    }

  if (( row < field->FIfield.buffer_size ) && ( row >= 0 ) )
    {
	/**********************************************************/
	/*** Fix to right justified fields with nothing but     ***/
	/*** blanks to keep them from core dumping ...          ***/
	/*************************************  GMD: 05/17/91  ****/

      for ( non_spaces = 0, ch = field->FIfield.buffer[row].line ;
							*ch ; ch++ )
	{
	  if ( *ch != ' ' )
	    {
	      non_spaces = 1;
	      break;
	    }
	}

      if ( non_spaces )
	{
          sscanf ( (char *)field->FIfield.buffer[row].line, "%le", value );
	}
      else
	{
	  *value = (double) 0.0;
	}

      *sel_flg = field->FIfield.buffer[row].sel;

      if ( ( row >= field->FIfield.roff )			&&
	   ( row < field->FIfield.roff + field->FIfield.nvr )	 )
	{
	  *r_pos = row - field->FIfield.roff;
	}
      else
	{
	  *r_pos = -1;
	}
    }
  else
    {
      *value = (double) 0.0;

      if ( ! field->FIfield.buffer_size )
	{
	  *sel_flg = 0;
	  *r_pos = 0;
	}
      else
	{
	  *sel_flg = -1;
	  *r_pos = -1;

	  return ( FI_INVALID_ROW );
	}
    }
  return ( FI_SUCCESS );
}


/*==================================================*/
/* This function sets the data at row in the field. */

int FIfld_set_value (Form   form,
                    int     label,
                    int     row,
                    int     col,
                    double  value,
                    int     sel_flg)
{
  Window	    window;
  int		    status, len, prev_row;
  unsigned char     text[256];
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form,
						label, col, &field );
  if ( status )
    {
      return ( status );
    }

  window = XWINDOW ( field );

  if ( row < 0 )
    {
      row = 0;
    }
  else if ( field->FIfield.nr && ( row > field->FIfield.nr ) )
    {
      row = field->FIfield.nr - 1;
    }

  if ( row >= field->FIfield.buffer_size )
    {
      _FI_fld_set_buffer ( field, row + 1, 1 );
    }

  /* MACK change format if the field is defined as integer ! */

  if (	( field->FIfield.fmt[0] == 0 )			||
	( field->FIfield.field_type == FI_ALPHA )	 )
    {
      if ( field->FIfield.field_type == FI_INT )
	{
	  sprintf ( (char *)text, "%d", (int) value );
	}
      else
	{
	  sprintf ( (char *)text, "%lG", value );
	}
    }
  else	/* Formatting is in use */
    {
      if ( field->FIfield.field_type == FI_INT )
	{
	  sprintf ( (char *)text, field->FIfield.fmt, (int) value );
	}
      else
	{
	  sprintf ( (char *)text, field->FIfield.fmt, value );
	}
    }

  _FI_fld_add_to_line ( field, row, strlen ( (char *)text ) + 3 );

  /*** <pds-12/13/89> Recalculate 'len' based on number of chars ***/

  len = FI_strlen ( (char *)text, field->FIgadget.font_type );

  if ( ( field->FIfield.nc ) && ( len >= field->FIfield.nc ) )
    {
      if ( field->FIfield.flags.wrap )
	{
	  int	ii, jj, m_index;
	  int	last_sp = 0;	/* place original text to copy at     */
	  int	roff = 0;       /* additional rows needed to hold text*/
	  unsigned char *str;	/* current string		      */
	  int  spaces[10000];   /* indexes of spaces and NULLs        */
				/* in current string */

	  str = & text[0];

	  do
	    {
			/*******************************/
			/* find spaces and copy string */
			/*******************************/

	      jj = -1;
	      for ( ii = 0; ii < field->FIfield.nc; ii++ )
		{
		  if (( str[ii]== SPACE ) || ( str[ii]== (unsigned char) NULL ))
		    {
		      spaces[++jj]= ii;
		    }
		}

	      if ( jj < 0 )
		{
		  jj = 0;
		  spaces[jj]= field->FIfield.nc;
		}
	      else if ( spaces[jj] < field->FIfield.nc )
		{
		  spaces[jj]++;	/* increment to copy blank */
		}

#if defined(hp9000)
	      strncpy ( (char *) field->FIfield.buffer[row + roff].line, 
							(char *) str,
							spaces[jj]);
#else
	      strncpy ( field->FIfield.buffer[row + roff].line, str,
							spaces[jj]);
#endif

		/* get current string and len */

	      last_sp += spaces[jj];

	      m_index = FI_move_index ( (char *)text, 0, last_sp,
					field->FIgadget.font_type );

	      str = & text [ m_index ];

	      len = strlen ( (char *)str );

	      if ( len > 0 )	/* add row if needed */
		{
		  if ( ! field->FIfield.nr			||
			( row + roff < field->FIfield.nr )	 )
		    {
		      roff++;
		    }

		  if ( row + roff >= field->FIfield.buffer_size )
		    {
		      _FI_fld_set_buffer ( field, row + roff + 1, 1 );
		    }

		  _FI_fld_add_to_line ( field, row + roff, len + 2 );
		}
	    }
	  while ( len > 0 );
	}
      else
	{
		/*** <pds-12/13/89> Multiply by 2 in case of	***/
		/*** 16-bit font.				***/

#if defined(hp9000)
	  strncpy ( (char *) field->FIfield.buffer[row].line, (char *) text,
					2 * field->FIfield.nc );
#else
	  strncpy ( field->FIfield.buffer[row].line, text,
					2 * field->FIfield.nc );
#endif
	}
    }
  else
    {
#if defined(hp9000)
      strcpy ( (char *) field->FIfield.buffer[row].line, (char *) text );
#else
      strcpy ( field->FIfield.buffer[row].line, text );
#endif
    }
	  /*** <pds-12/13/89> Changed from strlen () ***/

  len = FI_strlen ( (char *)field->FIfield.buffer[row].line,
					field->FIgadget.font_type );

  if ( ( row == field->FIfield.ar ) && ( len < field->FIfield.ac ) )
    {
      field->FIfield.ac = len;
    }

  prev_row = -1;

  if (	( field->FIfield.mode == FI_SINGLE_SELECT )		&&
	( field->FIfield.prev_sel > -1 )			 )
    {
      if ( sel_flg )
	{
	  field->FIfield.buffer[field->FIfield.prev_sel].sel = 0;
	  prev_row = field->FIfield.prev_sel;
	}
      else if ( field->FIfield.prev_sel == row )
	{
	  field->FIfield.prev_sel = -1;
	}
    }

  if ( sel_flg )
    {
      field->FIfield.prev_sel = row;
    }

  field->FIfield.buffer[row].sel = sel_flg;

  if (	( window != None )					&&
	( row >= field->FIfield.roff )				&&
	( row < field->FIfield.roff + field->FIfield.nvr )	&&
	IT_IS_DISPLAYABLE ( field )				 )
    {
      _FI_fld_refresh_row ( field, window, row );

      if ( prev_row > -1 )
	{
	  _FI_fld_refresh_row ( field, window, prev_row );
	}

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
      if (!_FI_dont_flush)
        XFlush ( _FI_display );
    }

   /** <pds-3/27/91> Now reflect the changes in linked gadgets **/

  if ( field->FIfield.flags.is_a_col )
    {
      _FI_g_pass_data ( (struct FIgadget_obj *) field->FIgadget.group );
    }
  else
    {
      _FI_g_pass_data ( (struct FIgadget_obj *) field );
    }

  return ( FI_SUCCESS );
}


/****************************************************************/
/* This function finds the row and column that a data point was */
/* entered over. This function only works for fields and MCF's. */
/****************************************************************/

int FIfld_find_row_and_column (Form  form,
                               int   gadget,
                               int   x,
                               int   y,
                               int  *row,
                               int  *column)
{
  int		status;
  int		xsize, ysize;
  int		xpos, ypos;
  int		type;
  char		fontname[256];
  double	bodysize;       /* dmb:10/05/92:Changed for ANSI */
  float     actual_bodysize;
  int		font_id, font_type;
  int		height, width, line_spacing;
  int		num_vis_cols, active_col, pos, first_col;
  int		xlo, zz;
  struct FIfld_obj *field;

	/*********************************************/
	/* check to see if form and gadget are valid */
	/*********************************************/

  status = FIg_is_valid ( form, gadget );
  if ( status != FI_SUCCESS )
    {
      return ( status );
    }

  status = FIg_get_type ( form, gadget, &type );
  if ( ( type != FI_FIELD ) && ( type != FI_MULTI_COL ) )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  status = FIg_get_size ( form, gadget, &xsize, &ysize );
  if ( status != FI_SUCCESS )
    {
      return ( status );
    }

	/***********************************************************/
	/* Calculate the height of each line of text in the field. */
	/* It will be stored in the line_spacing variable.	   */
	/***********************************************************/

  FIg_get_font_ANSI ( form, gadget, fontname, &bodysize );

  FI_find_font_id ( fontname, bodysize, (Font *)&font_id,
				&actual_bodysize, type, &font_type );

  FI_calc_text ( font_id, "xxx", 3, &height, &width,
				&line_spacing, font_type );

	/*** See if the gadget is a field or a MCF ***/
	/*** and take appropriate action.	   ***/

  if ( type == FI_FIELD )
    {
      *column = 0;	/* Fields must be column zero */

      FIg_get_location ( form, gadget, &xpos, &ypos );

      if (	( x >= xpos ) && ( x <= ( xpos + xsize + 2 )) &&
		( y >= ypos ) && ( y <= ( ypos + ysize ))	 )
	{
		/*****************************************/
		/* Insure proper row number is returned. */
		/*****************************************/

	  _FI_fld_get_field ( (struct FIform_obj *) form,
						gadget, 0, &field );

	  *row = (( y - ypos ) / line_spacing ) + field->FIfield.roff;

	  if ( *row >= field->FIfield.buffer_size )
	    {
	      *row = field->FIfield.buffer_size - 1;
	    }

	  return ( FI_SUCCESS );
	}
      else
	{
		/*** poke must have been on scroll bar, ***/
		/*** scroll button, or border		***/

		 return ( FI_ILLEGAL_VALUES );
	}
    }
  else	/* gadget_type == FI_MULTI_COL */
    {
	/************************************************/
	/* Figure out how many columns are displayed,	*/
	/* and which is displayed first.		*/
	/************************************************/

      FImcf_get_num_vis_cols ( form, gadget, &num_vis_cols );

      FImcf_get_active_col ( form, gadget, &active_col, &pos );

      first_col = active_col - pos;

      FIg_get_location ( form, gadget, &xpos, &ypos );

      xlo = xpos + 10;	/* Skip past row selection buttons */

      for ( zz = 0; zz < num_vis_cols; zz++ )
	{
	  FImcf_get_col_size ( form, gadget, first_col + zz,
						&xsize, &ysize );

		/* Add 3 to account for column separation lines */
		/* GMD 11/8/90 */

	  if (	( x >= xlo  ) && ( x <= ( xlo + xsize + 3 ))	&&
		( y >= ypos ) && ( y <= ( ypos + ysize    ))	 )
	    {
	      *column = first_col + zz;

		/* Insure proper row number is returned. GMD 1/16/91 */

	      _FI_fld_get_field ( (struct FIform_obj *) form,
					gadget, *column, &field );

	      *row = (( y - ypos ) / line_spacing ) +
						field->FIfield.roff;

	      if ( *row >= field->FIfield.buffer_size )
		{
		  *row = field->FIfield.buffer_size - 1;
		}

	      return ( FI_SUCCESS );
	    }

	  xlo += ( xsize + 3 );
	}

	/******************************************/
	/*** Poke must have been on scroll bar,	***/
	/*** scroll button, or border.		***/
	/******************************************/

      return ( FI_ILLEGAL_VALUES );
    }
}
