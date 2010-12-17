#include "FImin.h"

#include "FIbtn.h"
#include "FIfield.h"
#include <stdio.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/*====================================================================*/

int FIfld_get_list_num_rows (Form  form,
                             int   label,
                             int   col,
                             int  *num_rows)
{
  int		status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							 col, &field );
  if ( status )
    {
      return ( status );
    }

  if ( ! field->FIfield.list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  *num_rows = field->FIfield.list_id->FIfield.buffer_size;
  return ( FI_SUCCESS );
}

/*====================================================================*/

int FIfld_set_list_num_rows (Form  form,
                             int   label,
                             int   col,
                             int   num_rows)
{
  int		status;
  Window	window;
  struct FIfld_obj *field, *list_id;


  if ( num_rows < 0 )
    {
      return FI_INVALID_ROW;
    }

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
						 col, &field );
  if ( status )
    {
      return ( status );
    }

  list_id = field->FIfield.list_id;

  if ( ! list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  _FI_fld_set_buffer ( list_id, num_rows, 1 );

  if ( list_id->FIfield.ar >= list_id->FIfield.buffer_size )
    {
      if ( list_id->FIfield.buffer_size )
	{
	  list_id->FIfield.ar = list_id->FIfield.buffer_size - 1;

               /* Add check to make sure that roff is not set to a  */
               /* negative value by mistake.   GMD 12/2/91          */

          if ( list_id->FIfield.buffer_size >= list_id->FIfield.nvr )
	    {
	      list_id->FIfield.roff = list_id->FIfield.buffer_size -
						 list_id->FIfield.nvr;
	    }
          else
	    {
              list_id->FIfield.roff = 0;
	    }
	}
      else
	{
	  list_id->FIfield.ar = 0;
	  list_id->FIfield.roff = 0;
	}
    }

  window = XWINDOW ( field );

  if (	( window != None )			&&
	 list_id->FIgadget.form->displayed	&&
	 IT_IS_DISPLAYABLE ( list_id )		 )
    {
      _FI_fld_refresh_data ( list_id, window );

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
      if (!_FI_dont_flush)
        XFlush ( _FI_display );

    }

  return ( FI_SUCCESS );
}


/*==============================================================*/
/* This function returns the length of the data at row in	*/
/* the list so application can malloc space to hold it.		*/

int FIfld_get_list_text_length (Form  form,
                                int   label,
                                int   row,
                                int   col,
                                int  *length)
{
  int		status;
  struct FIfld_obj *field;
  struct FIfld_obj *list_id;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							 col, &field );
  if ( status )
    {
      return ( status );
    }

  list_id = field->FIfield.list_id;

  if ( ! list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  if (( row < 0 ) || ( row >= list_id->FIfield.buffer_size ))
    {
      return ( FI_INVALID_ROW );
    }

  *length = strlen ( (char *)list_id->FIfield.buffer[row].line ) + 1;
  return ( FI_SUCCESS );
}


/*======================================================*/
/* This function gets the data at row in the list.	*/

int FIfld_get_list_text (Form            form,
                         int             label,
                         int             row,
                         int             col,
                         int             num_ch,
                         unsigned char  *text,
                         int            *sel_flg)
{
  int		status;
  struct FIfld_obj *field;
  struct FIfld_obj *list_id;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							 col, &field );
  if ( status )
    {
      return ( status );
    }

  list_id = field->FIfield.list_id;
  if ( ! list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  if (( row < list_id->FIfield.buffer_size ) && ( row >= 0 ))
    {
     /* Hebrew 02-08-90 */
      if ( ( field->FIfield.flags.right_to_left )	&&
	   ( field->FIfield.flags.reverse_output )	 )
	{
	  char s1[30000];

	  _FI_flip_string ( (char *)list_id->FIfield.buffer[row].line, s1 );
#if defined(hp9000)
	  strncpy ( (char *) text, s1, num_ch );
#else
	  strncpy ( text, s1, num_ch );
#endif
	}
      else
	{
#if defined(hp9000)
          strncpy ( (char *) text, 
		(char *) list_id->FIfield.buffer[row].line, num_ch );
#else
          strncpy ( text, list_id->FIfield.buffer[row].line, num_ch );
#endif
	}

      text[num_ch - 1]= '\0';

      *sel_flg = (int) list_id->FIfield.buffer[row].sel;
    }
  else
    {
      text[0] = '\0';
      *sel_flg = -1;
      return ( FI_INVALID_ROW );
    }

  return ( FI_SUCCESS );
}

/*=============================================== JAJ:12/04/90 ======*/
/* This function gets the length of default data at a row in the list.*/

int FIfld_get_list_default_text_length (Form  form,
                                        int   label,
                                        int   row,
                                        int   col,
                                        int  *length)
{
  int		status;
  struct FIfld_obj *field;
  struct FIfld_obj *list_id;

  status = _FI_fld_get_field ( (struct FIform_obj *)form, label, col, &field );
  if ( status )
    {
      return ( status );
    }

  list_id = field->FIfield.list_id;
  if ( ! list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  if (( row < list_id->FIfield.default_size ) && ( row >= 0 ))
    {
      *length = strlen ( (char *)list_id->FIfield.defaults[row].line ) + 1;
    }
  else
    {
      *length = 1;
      return ( FI_INVALID_ROW );
    }

  return ( FI_SUCCESS );
}

/*====================================================================*/
/* This function gets the default data at row in the list. */

int FIfld_get_list_default_text (Form           form,
                                 int            label,
                                 int            row,
                                 int            col,
                                 int            num_ch,
                                 unsigned char *text,
                                 int           *sel_flg)
{
  int		status;
  struct FIfld_obj *field;
  struct FIfld_obj *list_id;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
						 col, &field );
  if ( status )
    {
      return ( status );
    }

  list_id = field->FIfield.list_id;
  if ( ! list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  if (( row < list_id->FIfield.default_size ) && ( row >= 0 ))
    {
       /*** Hebrew -- JAJ:11/08/91 ***/
      if (  field->FIfield.flags.right_to_left  &&
            field->FIfield.flags.reverse_output  )
	{
          char s1[30000];

          _FI_flip_string ( (char *)list_id->FIfield.defaults[row].line, s1 );
#if defined(hp9000)
          strncpy ( (char *) text, s1, num_ch );
#else
          strncpy ( text, s1, num_ch );
#endif
	}
      else
	{
#if defined(hp9000)
          strncpy ( (char *) text, 
		(char *) list_id->FIfield.defaults[row].line, num_ch );
#else
          strncpy ( text, list_id->FIfield.defaults[row].line, num_ch );
#endif
	}
       /*** ---Hebrew--- ***/

      text[num_ch - 1]= '\0';

      *sel_flg = (int) list_id->FIfield.defaults[row].sel;
    }
  else
    {
      text[0] = '\0';
      *sel_flg = -1;
      return ( FI_INVALID_ROW );
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_get_list_select (Form form,
                           int label,
                           int row,
                           int col,
                           int *sel_flg)
{
  int		status;
  struct FIfld_obj *field;
  struct FIfld_obj *list_id;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							 col, &field );
  if ( status )
    {
      return ( status );
    }

  list_id = field->FIfield.list_id;
  if ( ! list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  if (( row < list_id->FIfield.buffer_size ) && ( row >= 0 ))
    {
      *sel_flg = (int) list_id->FIfield.buffer[row].sel;
    }
  else
    {
      *sel_flg = -1;
      return ( FI_INVALID_ROW );
    }
  return ( FI_SUCCESS );
}

/*====================================================================*/

int FIfld_set_list_select (Form  form,
                           int   label,
                           int   row,
                           int   col,
                           int   sel_flg)
{
  int		status, prev_row;
  Window	window;
  struct FIfld_obj *field;
  struct FIfld_obj *list_id;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							 col, &field );
  if ( status )
    {
      return ( status );
    }

  list_id = field->FIfield.list_id;
  if ( ! list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  if ( row < 0 )
    {
      return ( FI_INVALID_ROW );
    }

  if ( list_id->FIfield.nr && ( row > list_id->FIfield.nr ))
    {
      return ( FI_INVALID_ROW );
    }

  if ( row >= list_id->FIfield.buffer_size )
    {
      return ( FI_INVALID_ROW );
    }

  prev_row = -1;
  if (	( list_id->FIfield.mode == FI_SINGLE_SELECT )	&&
	( list_id->FIfield.prev_sel != -1 )			 )
    {
      if ( sel_flg )
	{
	  if ( ( list_id->FIfield.prev_sel <
			 list_id->FIfield.buffer_size )		 &&
                    ( list_id->FIfield.prev_sel != -1 )		  )
	    {
	     list_id->FIfield.buffer[list_id->FIfield.prev_sel].sel = 0;
	      prev_row = list_id->FIfield.prev_sel;
	    }
	}
      else if ( list_id->FIfield.prev_sel == row )
	{
	  list_id->FIfield.prev_sel = -1;
	}
    }

  if ( sel_flg )
    {
      list_id->FIfield.prev_sel = row;
    }

  list_id->FIfield.buffer[row].sel = (short) sel_flg;

  window = XWINDOW ( field );

  if ( ( window != None ) && IT_IS_DISPLAYABLE ( list_id ) )
    {
      _FI_fld_refresh_row ( list_id, window, row );

      if ( prev_row > -1 )
	{
	  _FI_fld_refresh_row ( list_id, window, prev_row );
	}

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
      if (!_FI_dont_flush)
        XFlush ( _FI_display );
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/
/* This function sets the data at row in the list. */

int FIfld_set_list_text (Form            form,
                         int             label,
                         int             row,
                         int             col,
                         unsigned char  *text,
                         int             sel_flg)
{
  int		status, fld_row;
  Window	window;
  struct FIfld_obj *field;
  struct FIfld_obj *list_id;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							 col, &field );
  if ( status )
    {
      return ( status );
    }

  list_id = field->FIfield.list_id;
  if ( ! list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  if ( row < 0 )
    {
      return ( FI_INVALID_ROW );
    }

  if ( list_id->FIfield.nr && ( row > list_id->FIfield.nr ))
    {
      return ( FI_INVALID_ROW );
    }

  if ( row >=list_id->FIfield.buffer_size )
    {
      _FI_fld_set_buffer ( list_id, row + 1, 1 );
    }

  _FI_fld_add_to_line ( list_id, row, strlen ( (char *)text ));

#if defined(hp9000)
  strcpy ( (char *) list_id->FIfield.buffer[row].line, (char *) text );
#else
  strcpy ( list_id->FIfield.buffer[row].line, text );
#endif

  list_id->FIfield.buffer[row].sel = (short) sel_flg;



  /* Hebrew 02-08-90 */
  if (	( field->FIfield.flags.right_to_left )		&&
	( field->FIfield.flags.reverse_input )		 )
    {
      char s1[30000];

      _FI_flip_string ( (char *)list_id->FIfield.buffer[row].line, s1 );
#if defined(hp9000)
      strcpy ( (char *) list_id->FIfield.buffer[row].line, s1 );
#else
      strcpy ( list_id->FIfield.buffer[row].line, s1 );
#endif
    }

  if ( sel_flg )
    {
      if (	( ! field->FIfield.nr )				  ||
	   ( field->FIfield.buffer_size + 1 < field->FIfield.nr )  )
	{
	  fld_row = field->FIfield.buffer_size + 1;
	}
      else
	{
	  fld_row = field->FIfield.nr - 1;
	}

      FIfld_set_default_text ( form, label, fld_row, col,
						 (char *)text, sel_flg );
    }

  window = XWINDOW ( field );

  if ( ( window != None ) && IT_IS_DISPLAYABLE ( list_id ) )
    {
      _FI_fld_refresh_row ( list_id, window, row );

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
      if (!_FI_dont_flush)
        XFlush ( _FI_display );
    }

  return ( FI_SUCCESS );
}


/*==============================================================*/
/* This function sets the default data at row in the list.	*/

int FIfld_set_list_default_text (Form form,
                                 int label,
                                 int row,
                                 int col,
                                 char *text,
                                 int sel_flg)
{
  int		status, fld_row, len;
  struct FIfld_obj *field;
  struct FIfld_obj *list_id;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
						 col, &field );
  if ( status )
    {
      return ( status );
    }

  list_id = field->FIfield.list_id;
  if ( ! list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  if ( row < 0 )
    {
      return ( FI_INVALID_ROW );
    }

  len = strlen ( text ) + 1;

  if ( row < list_id->FIfield.default_size )
    {
      if ( list_id->FIfield.defaults[row].line )
	{
	  list_id->FIfield.defaults[row].line = ( unsigned char *)
			 realloc ( list_id->FIfield.defaults[row].line,
				 len * sizeof ( unsigned char ));
	}
      else
	{
	  list_id->FIfield.defaults[row].line = ( unsigned char *)
			 calloc ( len, sizeof ( unsigned char ));
	}
    }
  else
    {
      _FI_fld_set_defaults ( list_id, row + 1 );

     /****** free it first ( if necessary ) JAJ:03/15/91 ******/
      if ( list_id->FIfield.defaults[row].line )
	{
	  free ( list_id->FIfield.defaults[row].line );
	}

      list_id->FIfield.defaults[row].line = ( unsigned char *)
		calloc ( strlen ( text ) + 1, sizeof ( unsigned char ));
    }

#if defined(hp9000)
  strcpy ( (char *) list_id->FIfield.defaults[row].line, text );
#else
  strcpy ( list_id->FIfield.defaults[row].line, text );
#endif

  list_id->FIfield.defaults[row].sel = (short) sel_flg;

  if ( row >= list_id->FIfield.buffer_size )
    {
      _FI_fld_set_buffer ( list_id, row + 1, 1 );
    }

  _FI_fld_add_to_line ( list_id, row, len );

  if ( list_id->FIfield.nc )
    {
      len = list_id->FIfield.nc;
    }

#if defined(hp9000)
  strncpy ( (char *) list_id->FIfield.buffer[row].line,
	 (char *) list_id->FIfield.defaults[row].line, len );
#else
  strncpy ( list_id->FIfield.buffer[row].line,
	 list_id->FIfield.defaults[row].line, len );
#endif

  list_id->FIfield.buffer[row].sel = list_id->FIfield.defaults[row].sel;

  if ( list_id->FIfield.buffer[row].sel & 1 )
    {
      if (( list_id->FIfield.mode == FI_SINGLE_SELECT )	&&
	  ( list_id->FIfield.prev_sel >= 0 )		 )
	{
	  list_id->FIfield.buffer[list_id->FIfield.prev_sel].sel = 0;
	}

      list_id->FIfield.prev_sel = row;
    }

  if ( sel_flg )
    {
      if (	( ! field->FIfield.nr )				   ||
	   ( field->FIfield.default_size + 1 < field->FIfield.nr )  )
	{
	  fld_row = field->FIfield.default_size + 1;
	}
      else
	{
	  fld_row = field->FIfield.nr - 1;
	}

      FIfld_set_default_text ( form, label, fld_row, col,
						 text, sel_flg );
    }

  return ( FI_SUCCESS );
}
