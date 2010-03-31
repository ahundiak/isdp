#include "FImin.h"

#include "FImcf.h"
#include "FIfield.h"
#include "FIappl.h"
#include "FEI.h"
#include <stdio.h>

/*====================================================================*/

int _FI_fld_get_field ( form, label, col, field )
  struct FIform_obj  * form;
  int		       label;
  int		       col;
  struct FIfld_obj  ** field;
{
  struct FIgadget_obj	*gadget;
  struct FImcf_obj	*multicol = 0;

  gadget = _FI_g_get_id ( form, label );

  if ( ! gadget ) return ( FI_NO_SUCH_GADGET );

  if ( gadget->FIgadget.type == FI_FIELD )
    {
      *field = (struct FIfld_obj *)gadget;
    }
  else if ( gadget->FIgadget.type == FI_MULTI_COL )
    {
      multicol = (struct FImcf_obj *)gadget;

      if ( col == -1 )
	{
	  *field = (struct FIfld_obj *) multicol->FIgroup.gadgets
			[multicol->FIgroup.current_active_gadget];
	}
      else
        {
            if ( (col < 0) || (col >= multicol->FImcf.ncol) )
                   return (FI_INVALID_COL);          /* 12/01/89  GMD */

	    *field = (struct FIfld_obj *)multicol->FIgroup.gadgets[col];
        }
    }
  else
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}

/*====================================================================*/

int FIfld_get_select ( form, label, row, col, sel_flg )
  struct FIform_obj *form;
  int	 label;
  int	 row;
  int	 col;
  int	*sel_flg;
{
  int status;
  struct FIfld_obj	*field;

  status = _FI_fld_get_field ( form, label, col, &field );
  if ( status ) return ( status );

    /*** <pds-1/4/90> Check if non-negative ***/

  if ( (row < field->FIfield.buffer_size) && (row >= 0) )
    {
	*sel_flg = field->FIfield.buffer[row].sel;
    }
  else
    {
	*sel_flg = 0;
        return (FI_INVALID_ROW);   /* 12/01/89  GMD */
    }
  return ( FI_SUCCESS );
}


/* This function returns the length of the data at row	*/
/*	so application can malloc space to hold it	*/
   
int FIfld_get_text_length ( form, label, row, col, length )
  struct FIform_obj *form;
  int	 label;
  int	 row;
  int	 col;
  int	*length;
{
  int status;
  struct FIfld_obj	*field;

  status = _FI_fld_get_field ( form, label, col, &field );
  if ( status ) return ( status );

    /*** <pds-1/4/90>  Check if non-negative
    	 <pds-2/21/90> Return a 1 even if the buffer size has not been
    	 	       set up yet.
    ***/

  if (( row < field->FIfield.buffer_size ) && (row >= 0) &&
	field->FIfield.buffer[row].line != NULL /* sml:11-14-92 added */)
    {
      if( field->FIfield.buffer )
	{
	    *length = strlen ( field->FIfield.buffer[row].line ) + 1;
	}
      else
	{
	    *length = 1;
	}
    }
  else
    {
	*length = 0;

        /* GMD 7/12/91   Added (row > 0) check for MAP 2 */

        if (row > 0)   /* In case field has not been visited yet. */
           return (FI_INVALID_ROW);   /* 12/01/89  GMD */
    }
  return ( FI_SUCCESS );
}

/*====================================================================*/

/* This function gets the data at row in the field. */

int FIfld_get_text ( form, label, row, col, num_ch, text,
						sel_flg, r_pos )
  struct FIform_obj *form;
  int		  label;
  int		  row;
  int		  col;
  int		  num_ch;
  unsigned char * text;
  int	        * sel_flg;
  int	        * r_pos;
{
  int status;
  struct FIfld_obj	*field;
  int i = 0;
  int count = 0;
  int front_pad;
  int real_str_len;
  unsigned char temp_text[30000];
  struct FIgadget_obj * gadget;

  status = _FI_fld_get_field ( form, label, col, &field );
  if ( status ) return ( status );

    /*** <pds-1/4/90> Check if non-negative ***/

  if (    field->FIfield.buffer_size		&&
	( row < field->FIfield.buffer_size )	&&
	( row >= 0 )				 			&&
	field->FIfield.buffer[row].line != NULL /* sml:11-14-92 added */)
    {
      strncpy ( text, field->FIfield.buffer[row].line, num_ch );
      text[num_ch-1] = '\0';
      
      /* Hebrew 01-07-90 */
	if ((field->FIfield.flags.right_to_left) &&
            (field->FIfield.flags.reverse_output))
        {
		char s2[30000];

		Flip_string(text,s2);
		strcpy(text,s2);
	}
      /*-----Hebrew------*/


        /* Append CR to string if the following line has a */
        /* paragraph marker.  (Wrap mode)                  */

      if ( ( row + 1 < field->FIfield.buffer_size )		&&
	   ( field->FIfield.flags.wrap == 1 )	 		&&
	   ( field->FIfield.buffer[row+1].paragraph == 1 )	 )
	{
          strcat (text, "\n");
	}
	          
      *sel_flg = field->FIfield.buffer[row].sel;
      if (  ( row >= field->FIfield.roff )			&& 
	    ( row < field->FIfield.roff + field->FIfield.nvr )	 )
	{
	    *r_pos = row - field->FIfield.roff;
	}
      else
	{
	    *r_pos = -1;
	}
/* map2
    Removed padding spaces for right and center justification fields.  Now the
    user only gets the string with no padding.
    Changed 5-9-91  */


      if ((field->FIgadget.justification == FI_RIGHT_JUSTIFIED) ||
          (field->FIgadget.justification == FI_CENTER_JUSTIFIED))
      {
         gadget = _FI_g_get_id ( form, label );
         temp_text[0] = '\0';
         while ((i < num_ch) && (text[i] == ' '))
           i++;
         front_pad = i;
         real_str_len = num_ch - front_pad - 1;
         for (i = front_pad; i < (front_pad + real_str_len); i++)
         {
           temp_text[count] = text[i];
           count++;
         }
         temp_text[count] = '\0';
         text[0] = '\0';
         strncat (text, temp_text, count);
      }
    }
  else
    {
      strcpy ( text, "" );
      if( field->FIfield.buffer_size )	/* <pds-2/21/90> */
	{
	    *sel_flg = -1;
	    *r_pos = -1;
            return (FI_INVALID_ROW);   /* 12/01/89 */
	}
      else
	{
	    *sel_flg = 0;		/* <pds-2/21/90> */
	    *r_pos = 0;
	}
    }

  return ( FI_SUCCESS );
}

/*====================================================================*/

/* This function sets the data at row in the field. */
/* Hebrew 01-07-90 */
/* Changed text name to apptext */

int FIfld_set_text ( form, label, row, col, apptext, sel_flg )
  struct FIform_obj *form;
  int	 label;
  int	 row;
  int	 col;
  char	*apptext;
  int	 sel_flg;
{
  extern int _FI_fld_set_text_last_row;

  int		window, status;
  int		len, prev_row;
  struct FIfld_obj	*field;
  struct FIgadget_obj	*gadget;
  struct FImcf_obj	*multicol = 0;
  int		refresh_line = 0;
  int		save_ar;
  char 		*text;
  unsigned char cc; 

  
 
  gadget = _FI_g_get_id ( form, label );

  if ( ! gadget )
    return ( FI_NO_SUCH_GADGET );

  if ( gadget->FIgadget.type == FI_MULTI_COL )
    {
      multicol = (struct FImcf_obj *)gadget;
    }

  status = _FI_fld_get_field ( form, label, col, &field );
  if ( status )
    {
      return ( status );
    }

	/******* Hebrew 01-07-90 ********/

  if ( (field->FIfield.flags.right_to_left)	&&
       (field->FIfield.flags.reverse_input)	 )
    { 
      text = calloc (strlen(apptext)+1, sizeof(char) );
      Flip_string(apptext,text);
    }
  else
    {
      text = apptext;
    }

	/******* Hebrew ********/

  if ( row < 0 )
    {
	row = 0;
    }
  else if ( field->FIfield.nr && ( row > field->FIfield.nr ))
    {
	row = field->FIfield.nr - 1;
    }

  if ( row >= field->FIfield.buffer_size )
    {
		/*** Add new blank line ***/
      _FI_fld_set_buffer ( field, row + 1, 1 );
    }

  if ( ! field->FIfield.flags.wrap )
    {
        /* Allocate more space if  */
        /* needed to hold text.    */

	_FI_fld_add_to_line ( field, row, strlen(text)+2);
    }   

    /*** pds <12/13/89> Changed from strlen()	***/
    /*** pds <2/15/90>  Added 'font_type'	***/

  len = FI_strlen ( text, field->FIgadget.font_type );


	/* PJW - fix coff too */

    /******************************************************************/
    /* Move cursor to end of line if new string is shorter than the   */
    /* current cursor position.                                       */
    /* Else move cursor to the beginning of the line.                 */
    /******************************************************************/

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

    /******************************************************************/
    /* If length of string is greater than the column width, decide   */
    /* what to do based on whether or not wrap mode is set.           */
    /******************************************************************/

    /*** <pds-2/26/90> Was not parsing newlines ('\n') ***/
    /***	if the len was less than 'nc'
    if ( field->FIfield.nc  && ( len >= field->FIfield.nc ))
    ********************************************************/

  if ( field->FIfield.nc )
    {	
      if ( field->FIfield.flags.wrap )
	{
	  int ii;
	  int roff = 0;      /* additional rows needed to hold text */
	  unsigned char t_line[500];
          int paragraph_flag;

          int marker;
          int last_space;
          int continue_loop;
            
          marker = 0;
          continue_loop = 1;
          last_space = -1;

          /* Paragraph flag may already be set so check here  */
          /*           GMD 12/2/91                            */

          paragraph_flag = field->FIfield.buffer[row].paragraph;

          while (continue_loop)
	    {
	     /*********************************************************/
	     /* Scan remainder of line.  For each character, check to */
	     /* see if it is a newline.  If so, take everything up to */
	     /* that point as the current line.  If the character is  */
	     /* a space make a note of its position, in case the next */
	     /* word exceeds line width.  If there are no spaces,     */
	     /* then the super-long word must be cut at the window    */
	     /* boundary.                                             */
	     /*********************************************************/

	      ii = 0;
                
              do
		{
                  cc = text[marker + ii]; 

                  if ( cc == ' ' )   /* Handle space */
                    {
                      last_space = ii;
                    }

                  if ( cc == '\n' )  /* Handle Carriage Return */
		    {
                      strncpy ( t_line, & text[marker], ii );

                      /* t_line[ii-1]='\0'; / * added -1 JAJ:10/21/91 */
                      t_line[ii] = '\0';   /* removed -1 JAJ:10/31/91 */

                      if ((roff > 0) &&
                          (row + roff >= field->FIfield.buffer_size))
                        {
                           _FI_fld_set_buffer (field,
						row + roff + 1, 1 );
                        }      

                      _FI_fld_add_to_line (field, row + roff,
                                           strlen (t_line) + 2);

                      strcpy (field->FIfield.buffer[row + roff].line,
								t_line);

                      if (paragraph_flag == 1)
			{
                         field->FIfield.buffer[row + roff].paragraph= 1;
			}
                      else
			{
                         field->FIfield.buffer[row + roff].paragraph= 0;
			}

		/*** Next line will have a paragraph marker ***/
                      paragraph_flag = 1;

                      marker += ii+1;
                 /*   marker++;    */
                      last_space = -1;
                      roff++;
                      ii = -1000;
                      if (marker >= len)
                         continue_loop = 0;

		    }  /* END Handle Carriage Return */
                  else if ( ii >= (field->FIfield.nvc) - 1)
		    {
				 /* End of view area */

                      if ( last_space != -1 )
                        {
                      	  strncpy (t_line, & text[marker], last_space);

					/* added -1: JAJ:10/21/91 */
                      	  /* t_line[last_space - 1 ] = '\0'; */
					/* removed -1: JAJ:10/31/91 */
                      	  t_line[last_space ] = '\0';

                          if ((roff > 0) &&
                             (row + roff >= field->FIfield.buffer_size))
                            {
                               _FI_fld_set_buffer (field,
						row + roff + 1, 1 );
                            }      

                          _FI_fld_add_to_line (field, row + roff,
                                              strlen (t_line) + 2);

                          strcpy (field->FIfield.buffer[row + roff].line,t_line);
                          if (paragraph_flag == 1)
                            field->FIfield.buffer[row + roff].paragraph = 1;
                          else
                            field->FIfield.buffer[row + roff].paragraph = 0;

			/* Next line will not have a paragraph marker */
                          paragraph_flag = 0;

                      	  if ((marker + last_space + 1) >= len)
                      	    {
                      	      continue_loop = 0;
                      	      ii = -1000;
                      	    }
                      	  else
                      	    {
                      	      marker += last_space + 1;
                      	      last_space = -1;
                      	      roff++;
                      	      ii = -1000;
                      	    }
                        }
                      else   /* Super-long word to be broken apart */
			{
                     /*********************************************/
                     /*sml:07-20-94:TR249404137                   */
                     /* one-character wide wrap field causes      */
                     /* crash.  This isn't perfect, but it avoids */
                     /* the crash.                                */
                     /*********************************************/
                          if (field->FIfield.nvc == 1)
                          {
                       	    strncpy (t_line, &(text[marker]), 1);
                      	    t_line[1] = '\0';
                          }
                     /* end of fix for TR 24940XXX                */
                          else
                          {
                      	    strncpy (t_line, &(text[marker]), 
                      	                  field->FIfield.nvc - 1);
                      	    t_line[field->FIfield.nvc - 1] = '\0';
                          }

                          if ((roff > 0) &&
                             (row + roff >= field->FIfield.buffer_size))
                            {
                              _FI_fld_set_buffer (field,
						row + roff + 1, 1 );
                            }

                          _FI_fld_add_to_line (field, row + roff,
                                              strlen(t_line) + 2);

                         strcpy (field->FIfield.buffer[row + roff].line, t_line);
                         if (paragraph_flag == 1)
                            field->FIfield.buffer[row + roff].paragraph = 1;
                         else
                            field->FIfield.buffer[row + roff].paragraph = 0;

		  /* Next line will not have a paragraph marker */ 
                         paragraph_flag = 0;
    
                      	 if ( (marker + ii) >= len )
                      	   {
                      	     continue_loop = 0;
                      	     ii = -1000;
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
                      	     ii = -1000;
                         }
                     /* end of fix for TR24940XXX                 */
                      	 else
                      	   {
                             marker += ii;
                      	     roff++;
                      	     ii = -1000;
                      	   }
			}
		    }
                  else if ( (marker + ii) == len )  /* End of line */
		    {
                      continue_loop = 0;
                      strcpy (t_line, &(text[marker]));

                      ii = -1000;

                      if ((roff > 0) &&
                          (row + roff >= field->FIfield.buffer_size))
                        {
                          _FI_fld_set_buffer (field, row + roff + 1, 1);
                        }

                      _FI_fld_add_to_line (field, row + roff,
						strlen (t_line) + 2);

                      strcpy (field->FIfield.buffer[row + roff].line,
								t_line);
                      if (paragraph_flag == 1)
                         field->FIfield.buffer[row + roff].paragraph= 1;
                      else
                         field->FIfield.buffer[row + roff].paragraph= 0;
		    }
                   
                  ii++;
		}
              while ( ii >= 0 );  /*** END do ***/

	    }	/*** END contine_loop ***/
              
          window = WIN_NO ( field );

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

          if (( window > -1 ) && ( row >= field->FIfield.roff ) && 
	      ( row < field->FIfield.roff + field->FIfield.nvr ) &&
	        IT_IS_DISPLAYED( field ) && IT_IS_DISPLAYABLE( field ) )
	    {
 	      _FI_fld_refresh_wrap_data (field, row);
	    }
        }
      else if ( len >= field->FIfield.nc )	/*** NO_wrap_crap ***/
	{
	    /*** <pds-12/13/89> Calculate actual bytes to copy	***/
	  int		len2;

	  len2 = FI_move_index ( text, 0, field->FIfield.nc, 
					field->FIgadget.font_type );

	  if( len2 < 0 )
		len2 = strlen( text );

	  strncpy ( field->FIfield.buffer[row].line, text, len2 );

					/* added -1 JAJ:10/21/91 */
					/* removed -1 JAJ:10/31/91 */
          field->FIfield.buffer[row].line[len2] = '\0';   /* GMD 11/15/90 */
	}
    }

  if( !field->FIfield.nc || len < field->FIfield.nc &&
    	!field->FIfield.flags.wrap )
				/* No wrap mode or string length */
    {				/* less than column width	 */

	/* Allocate more space if  */
	/* needed to hold text.    */

      if (field->FIfield.flags.wrap)	
	_FI_fld_add_to_line ( field, row, len + 2 );

      strcpy ( field->FIfield.buffer[row].line, text );

      field->FIfield.buffer[row].paragraph = 0;
	
      if (field->FIgadget.justification)
        {
           save_ar = field->FIfield.ar;
           field->FIfield.ar = row;
           _FI_fld_justify_data (field);
           field->FIfield.ar = save_ar;
        }
    }

  prev_row = -1;

  if (	( field->FIfield.mode == FI_SINGLE_SELECT )	&&
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

  window = WIN_NO ( field );
  if (  ( window > -1 ) && ( row >= field->FIfield.roff )	&& 
	( row < field->FIfield.roff + field->FIfield.nvr )	 )
    {
        if ( gadget->FIgadget.type == FI_MULTI_COL )
	  {
	    if ( IT_IS_DISPLAYABLE( multicol ) )	
	      refresh_line = 1;
	    else
	      refresh_line = 0;
	  }
        else if ( gadget->FIgadget.type == FI_FIELD )
	  {
	    if ( IT_IS_DISPLAYABLE( field ) )
	      refresh_line = 1;
	    else
	      refresh_line = 0;
	  }
    }
  else
    {
      refresh_line = 0;
    }
	      
  if (refresh_line)
    {
      hidecursor ( window );
      _FI_fld_refresh_row ( field, window, row );

      if ( prev_row > -1 )
	_FI_fld_refresh_row ( field, window, prev_row );

      showcursor ( window );
      flushbuffer ( window );
    }

	/**********************************************************/
	/*** free temporarily calloc'ed reversed, right-to-left ***/
	/*** text 			-- JAJ:03/06/91 	***/
	/**********************************************************/

  if ( (field->FIfield.flags.right_to_left)	&&
       (field->FIfield.flags.reverse_input)	 )
    { 
      if ( text )
	{
          free (text);
	}
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_get_value ( form, label, row, col, value, sel_flg, r_pos )
  struct FIform_obj *form;
  int	   label;
  int	   row;
  int	   col;
  double * value;
  int	 * sel_flg;
  int	 * r_pos;
{
  int status, ii, non_space;
  struct FIfld_obj	*field;

  status = _FI_fld_get_field ( form, label, col, &field );
  if ( status ) return ( status );

  if ( field->FIfield.field_type == FI_ALPHA )
	return ( FI_ILLEGAL_VALUES );

    /*** <pds-1/4/89> Check for negative row ***/

  if ( (row < field->FIfield.buffer_size) && (row >= 0) )
    {
      non_space = 0;

	/**********************************************************/
	/*** Fix to right justified fields with nothing but	***/
	/*** blanks to keep them from core dumping ...		***/
	/*************************************  GMD: 05/17/91  ****/
      for ( ii = 0; ii < strlen (field->FIfield.buffer[row].line); ii++)
      {
         if ( field->FIfield.buffer[row].line[ii] != ' ' )
            non_space = 1;
      }

      if ( non_space == 1 )
	{
         sscanf ( field->FIfield.buffer[row].line, "%le", value );
	}
      else
	{
         *value = (double) 0.0;
	}

      *sel_flg = field->FIfield.buffer[row].sel;
      if (  ( row >= field->FIfield.roff )			&& 
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
      if( !field->FIfield.buffer_size ) 	/* <pds-2/26/90> */
	{
	    *sel_flg = 0;
	    *r_pos = 0;
	}
      else
	{
	    *sel_flg = -1;
	    *r_pos = -1;
            return (FI_INVALID_ROW);   /* 12/01/89  GMD */
	}
    }

  return ( FI_SUCCESS );
}

/*====================================================================*/
/* This function sets the data at row in the field. */

int FIfld_set_value ( form, label, row, col, value, sel_flg )
  struct FIform_obj *form;
  int	 label;
  int	 row;
  int	 col;
  double value;
  int	 sel_flg;
{
  int window, status;
  int len, prev_row;
  unsigned char text[200];
  struct FIfld_obj	*field;

  status = _FI_fld_get_field ( form, label, col, &field );
  if ( status ) return ( status );

  if ( row < 0 )
    {
	row = 0;
    }
  else if ( field->FIfield.nr && ( row > field->FIfield.nr ))
    {
	row = field->FIfield.nr - 1;
    }

  if ( row >= field->FIfield.buffer_size )
    {
	_FI_fld_set_buffer ( field, row + 1, 1 );
    }

/* MACK change format if the field is defined as integer ! */

  if (  ( field->FIfield.fmt[0] == 0)			||
        ( field->FIfield.field_type == FI_ALPHA )	 )
    {
       if (field->FIfield.field_type == FI_INT)
          sprintf ( text, "%d", (int)value);
       else
          sprintf ( text, "%lG", value );
    }
  else     /* Formatting is in use */
    {
       if (field->FIfield.field_type == FI_INT)
          sprintf ( text, field->FIfield.fmt, (int)value);
       else
          sprintf ( text, field->FIfield.fmt, value );
    }

  len = strlen (text);

  _FI_fld_add_to_line ( field, row, len + 3 );

    /*** <pds-12/13/89> Recalculate 'len' based on # of characters ***/
    /*** <pds-2/15/90>  Added 'font_type'			   ***/

  len = FI_strlen( text, field->FIgadget.font_type );

  if ( ( field->FIfield.nc ) && ( len >= field->FIfield.nc ) )
    {
      if ( field->FIfield.flags.wrap )
	{
	  int ii, jj;
	  int last_sp = 0;     /* place orignal text to copy at       */
	  int roff = 0;	       /* addition rows needed to hold text   */
	  int *spaces;	       /* indexes of spaces in current string */
	  unsigned char *str;  /* current string                      */

	  spaces = (int *) calloc ( field->FIfield.nc / 2 + 1,
							sizeof (int) );
	  str = &(text[FI_move_index(text, 0, last_sp,
			    	field->FIgadget.font_type)]);
	  do
	    {
			/* find spaces and copy string */

	      jj = -1;
	      for ( ii = 0; ii < field->FIfield.nc; ii++ )
		{
		    if (( str[ii] == SPACE ) || ( str[ii] == NULL ))
			spaces[++jj] = ii;
		}

	      if ( jj < 0 )
		{
		    jj = 0;
		    spaces[jj] = field->FIfield.nc;
		}
	      else if ( spaces[jj] < field->FIfield.nc )
		{
		    spaces[jj] ++;  /* increment to copy blank */
		}

	      strncpy ( field->FIfield.buffer[row + roff].line,
						str, spaces[jj] );

			/* get current string and len */
		
	      last_sp += spaces[jj];
	      str = &(text[FI_move_index(text, 0, last_sp,
					field->FIgadget.font_type)]);
	      len = strlen ( str );
	      if ( len > 0 )	/* add row if needed */
		{
		  if (    !field->FIfield.nr			||
			( row + roff < field->FIfield.nr )	 )
		    {
			roff++;
		    }
		  if ( row + roff >= field->FIfield.buffer_size )
		    {
			_FI_fld_set_buffer ( field, row + roff + 1, 1 );
		    }
		  _FI_fld_add_to_line ( field, row + roff, len + 2);
		}
	    }
	  while ( len > 0 );

	  if ( spaces )
	    {
	      free ( spaces );	/*** JAJ:08/27/90 ***/
	    }
	}
      else
	{
	   /*** <pds-12/13/89> Multiply by 2 in case of 16 bit font ***/
	
	  strncpy ( field->FIfield.buffer[row].line, text,
				    	2 * field->FIfield.nc );
	}
    }
  else
    {
	strcpy ( field->FIfield.buffer[row].line, text );
    }

    /*** <pds-12/13/89> Changed from strlen()	***/
    /*** <pds-2/15/90>  Added 'font_type'	***/
    
  len = FI_strlen( field->FIfield.buffer[row].line,
					field->FIgadget.font_type );

  if ( ( row == field->FIfield.ar ) && ( len < field->FIfield.ac ) )
    {
	field->FIfield.ac = len;
    }

  prev_row = -1;

  if (	( field->FIfield.mode == FI_SINGLE_SELECT )	&&
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

  window = WIN_NO ( field );

  if (	( window > -1 ) && ( row >= field->FIfield.roff )	&& 
	( row < field->FIfield.roff + field->FIfield.nvr )	&&
	  IT_IS_DISPLAYABLE( field )				 )
    {
	hidecursor ( window );

	_FI_fld_refresh_row ( field, window, row );

	if ( prev_row > -1 )
	    _FI_fld_refresh_row ( field, window, prev_row );

	showcursor ( window );
	flushbuffer ( window );
    }

  return ( FI_SUCCESS );
}

/*--------------------------------------------------------------------*/

/**********************************************************************/
/*                                                                    */
/* This function finds the row and column that a data point was       */
/* entered over.  This function only works for fields and MCF's.      */
/*                                                                    */
/**********************************************************************/

int FIfld_find_row_and_column ( form, gadget, x, y, row, column )
  struct FIform_obj *form;
  int   gadget;
  int   x;
  int   y;
  int * row;
  int * column;
{
  int status, dummy;
  int xsize, ysize;
  int xpos, ypos;
  int type;
  char fontname[15];
  float bodysize, actual_bodysize;
  int (*find_font_func)();
  int (*calc_text_func)();
  int font_id, font_type;
  int height, width, line_spacing;
  int num_vis_cols, active_col, pos, first_col;
  int xlo, zz;
  struct FIfld_obj *field;
  char widest_str[10];
  double dx, dy;

   /* check to see if form is good */

  status = FIf_is_displayed (form, &dummy);
  if (status != FI_SUCCESS)
      return (status);

   /* check to see if gadget is good */

  status = FIg_get_size (form, gadget, &xsize, &ysize);
  if (status != FI_SUCCESS)
      return (status);

  status = FIg_get_type (form, gadget, &type);
  if ( (type != FI_FIELD) && (type != FI_MULTI_COL) )
    {
      return (FI_INVALID_GADGET_TYPE);
    }

   /* Calculate the height of each line of text in the field. */
   /* It will be stored in the line_spacing variable.         */

  FIg_get_font (form, gadget, fontname, &bodysize);
  FI_get_env (FI_FIND_FONT_ID, &find_font_func);   /* maybe need '&' */

  find_font_func ( fontname, bodysize, &font_id, &actual_bodysize,
			                   type, &font_type );

  FI_get_env ( FI_CALC_TEXT, &calc_text_func );  /* maybe need '&' */


		/****************************************************/
		/*													*/
		/*	Use widest char to determine char position		*/
		/*													*/
		/****************************************************/
  _FI_get_widest_string(font_type, widest_str);
  calc_text_func ( font_id, 
	/*"xxx"*/ widest_str, /*3*/ 1, &height, &width, &line_spacing,
				                   font_type );

        FI_get_auto_scaling_factors( &dx, &dy );
        line_spacing = (int)((double)line_spacing * dy);

	/*** See if the gadget is a field or a MCF ***/
	/*** and take appropriate action	   ***/

  if (type == FI_FIELD)
    {
      *column = 0;   /* Fields must be column zero */

      FIg_get_location (form, gadget, &xpos, &ypos);
      if (((x >= xpos) && (x <= (xpos + xsize + 2))) &&
          ((y >= ypos) && (y <= (ypos + ysize))))
	{
          /* Insure proper row number is returned.   GMD 1/16/91 */
          status = _FI_fld_get_field (form, gadget, 0, &field);

          *row = ((y - ypos) / line_spacing) + field->FIfield.roff;

		  /* sml:12-30-92  Don't decrement if it's row 0 */
          if (*row >= field->FIfield.buffer_size && *row != 0)
             *row = field->FIfield.buffer_size - 1;
          return (FI_SUCCESS);
	}
      else
	{   /*** poke must have been on scroll bar, ***/
	    /*** scroll button, or border	    ***/

          return (FI_ILLEGAL_VALUES);
	}
    }
  else  /* gadget_type == FI_MULTI_COL */
    {
      /* Figure out how many columns are displayed, and which is  */
      /* displayed first.                                         */

      FImcf_get_num_vis_cols (form, gadget, &num_vis_cols);

      FImcf_get_active_col (form, gadget, &active_col, &pos);

      first_col = active_col - pos;
      
      FIg_get_location (form, gadget, &xpos, &ypos);
      xlo = xpos + 10;  /* Skip past row selection buttons */

      for ( zz = 0; zz < num_vis_cols; zz++)
        {
          FImcf_get_col_size (form, gadget, first_col + zz,
						&xsize, &ysize);

          /*  Add 3 to account for column separation lines  */
          /*           GMD 11/8/90                          */

          if ( ( (x >= xlo ) && (x <= (xlo + xsize + 3))	)  &&
              ( (y >= ypos) && (y <= (ypos + ysize))    )	 )
           {
             *column = first_col + zz;

             /* Insure proper row number is returned.   GMD 1/16/91 */

             status = _FI_fld_get_field (form, gadget, *column, &field);
             *row = ((y - ypos) / line_spacing) + field->FIfield.roff;

             /***********************************************/
             /* sml:02-10-94:TR 249400280                   */
			 /*  First data point on empty MCF says you     */
			 /*  poked row 0 in init notification.          */
             /*  if buffer_size == 0, *row has to be 0      */
             /***********************************************/
             if (field->FIfield.buffer_size == 0)
                *row = 0;

			 /* sml:12-30-92  Don't decrement if it's row 0 */
             /* sml:02-10-94:TR 249400280  add else here    */
    
             else if (*row >= field->FIfield.buffer_size && *row != 0)
                *row = field->FIfield.buffer_size - 1;

             return (FI_SUCCESS);
           }

          xlo += xsize;
			/****************************************************/
			/* sml:03-07-94:TR 249400363                        */
			/*  Change from 3 to 4, because the separators are  */
			/*  3 pixels wide and the next available point is   */
			/*  3+1 or 4 pixels over.                           */
			/****************************************************/
          xlo += 4;    /*3;*/
        }

      /* poke must have been on scroll bar, scroll button, or border */

      return (FI_ILLEGAL_VALUES);
   }
}

