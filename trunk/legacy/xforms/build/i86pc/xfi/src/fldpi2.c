#include "FImin.h"

#include "FIscroll.h"
#include "FIbtn.h"
#include "FImcf.h"
#include "FIseq.h"
#include "FIfield.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

extern int _FI_mcf_break_navigation;



int FIfld_get_format_string_length (Form  form,
                                    int   label,
                                    int   col,
                                    int  *format_str_length)
{
  int status;
  struct FIfld_obj *field;


  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  *format_str_length = strlen ( field->FIfield.fmt ) + 1;

  return ( FI_SUCCESS );
}



int FIfld_get_format_string (Form            form,
                             int             label,
                             int             col,
                             unsigned char  *text)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

#if defined(hp9000)
  strcpy ( (char *) text, field->FIfield.fmt );
#else
  strcpy ( text, field->FIfield.fmt );
#endif

  return ( FI_SUCCESS );
}



/*====================================================================*/

int FIfld_set_format_string (Form   form,
                             int    label,
                             int    col,
                             char  *format_string)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  _FI_s_rep ( &field->FIfield.fmt, format_string );

  return ( FI_SUCCESS );
}


/****************************************************************/
/* FIfld_set_list_scroll ( ) -					*/
/*   This function allows the application to control whether	*/
/* it has a vertical scroll bar or horizontal scroll buttons	*/
/* displayed on the associated list.				*/
/****************************************************************/

int FIfld_set_list_scroll (Form  form,
                           int   label,
                           int   vert_flag,
                           int   horz_flag)
{
  struct FIfld_obj *field, *list;
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type != FI_FIELD )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  field = (struct FIfld_obj *) gadget;

  list = field->FIfield.list_id;
  if ( list )
    {
      if ( vert_flag )
	{
	  list->FIfield.flags.draw_vscrl = 1;

	  if ( IT_IS_DISPLAYABLE ( list ) && list->FIfield.vscrl_id )
	    {
	      _FI_g_set_displayable ( (struct FIgadget_obj *)list->FIfield.vscrl_id );

	      _FI_g_display ( (struct FIgadget_obj *)
			list->FIfield.vscrl_id, XWINDOW ( list ) );
	    }
	}
      else
	{
	  list->FIfield.flags.draw_vscrl = 0;

	  if ( list->FIfield.vscrl_id )
	    {
	      _FI_g_erase ( (struct FIgadget_obj *)
					list->FIfield.vscrl_id );

	      list->FIfield.vscrl_id->FIgadget.default_attr_mask |=
						      FI_NOT_DISPLAYED;
	    }
	}

      if ( horz_flag )
	{
	  list->FIfield.flags.draw_hscrl = 1;

	  if ( IT_IS_DISPLAYABLE ( list ) && list->FIfield.hscrl )
	    {
	      _FI_g_set_displayable ( (struct FIgadget_obj *)list->FIfield.hscrl[0]);

	      _FI_g_set_displayable ( (struct FIgadget_obj *)list->FIfield.hscrl[1]);

	      _FI_g_display ( (struct FIgadget_obj *)
			      list->FIfield.hscrl[0], XWINDOW ( list ));

	      _FI_g_display ( (struct FIgadget_obj *)
			      list->FIfield.hscrl[1], XWINDOW ( list ));
	    }
	}
      else
	{
	  list->FIfield.flags.draw_hscrl = 0;

	  if ( list->FIfield.hscrl )
	    {
	      _FI_g_erase ( (struct FIgadget_obj *)
						list->FIfield.hscrl[0]);

	      _FI_g_erase ( (struct FIgadget_obj *)
						list->FIfield.hscrl[1]);

	      list->FIfield.hscrl[0]->FIgadget.default_attr_mask |=
						      FI_NOT_DISPLAYED;

	      list->FIfield.hscrl[1]->FIgadget.default_attr_mask |=
						      FI_NOT_DISPLAYED;
	    }
	}
    }
  return ( FI_SUCCESS );
}


/****************************************************************/
/* FIfld_get_list_scroll ( ) -					*/
/*   This function allows the application to determine whether	*/
/* he has a vertical scroll bar or horizontal scroll buttons	*/
/* displayed on his associated list.				*/
/****************************************************************/

int FIfld_get_list_scroll (Form  form,
                           int   label,
                           int  *vert_flag,
                           int  *horz_flag)
{
  struct FIfld_obj	*field, *list;
  struct FIgadget_obj	*gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type != FI_FIELD )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  field = (struct FIfld_obj *) gadget;

  list = field->FIfield.list_id;
  if ( list )
    {
      if ( list->FIfield.flags.draw_vscrl )
	{
	  *vert_flag = 1;
	}
      else
	{
	  *vert_flag = 0;
	}

      if ( list->FIfield.flags.draw_hscrl )
	{
	  *horz_flag = 1;
	}
      else
	{
	  *horz_flag = 0;
	}
    }
  return ( FI_SUCCESS );
}



int FIfld_get_default_text_length (Form  form,
                                   int   label,
                                   int   row,
                                   int   col,
                                   int  *length)
{
  int		status;
  struct FIfld_obj *field;


  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  /*** <pds-1/4/89> Added check for negative row ***/

  if (( row < field->FIfield.default_size ) && ( row >= 0 ))
    {
      *length = strlen ( (char *)field->FIfield.defaults[row].line ) + 1;
    }
  else
    {
      *length = 1;
      return ( FI_INVALID_ROW );
    }

  return ( FI_SUCCESS );
}



/************************************************************/
/* This function gets the default data at row in the field. */
/************************************************************/

int FIfld_get_default_text (Form            form,
                            int             label,
                            int             row,
                            int             col,
                            int             num_ch,
                            unsigned char  *text,
                            int            *sel_flg)
{
  int status;
  struct FIfld_obj *field;


  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  /*** <pds-1/4/89> Added check for negative row ***/

  if ( ( row < field->FIfield.default_size ) && ( row >= 0 ) )
    {
        /*** Hebrew JAJ:08-20-91 ***/
      if (  field->FIfield.flags.right_to_left  &&
            field->FIfield.flags.reverse_output  )
        {
          char s1[30000];

          _FI_flip_string ( (char *)field->FIfield.defaults[row].line, s1 );
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
		(char *) field->FIfield.defaults[row].line, num_ch );
#else
          strncpy ( text, field->FIfield.defaults[row].line, num_ch );
#endif
        }
        /*** ---Hebrew--- ***/
				    /*** added -1 -- JAJ:11/08/91 ***/
      text[num_ch - 1] = '\0';      /*** JAJ:08/20/91 ***/

      *sel_flg = field->FIfield.defaults[row].sel;
    }
  else
    {
      text[0] = '\0';

      *sel_flg = -1;

      return ( FI_INVALID_ROW );
    }
  return ( FI_SUCCESS );
}



/************************************************************/
/* This function sets the default data at row in the field. */
/************************************************************/

int FIfld_set_default_text (Form   form,
                            int    label,
                            int    row,
                            int    col,
                            char  *text,
                            int    sel_flg)
{
  int	status, len;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

	/********************************************************/
	/* If field is set to wrap mode, truncate any		*/
	/* strings that are too long to fit in the field.	*/
	/********************************************************/

  if (	( field->FIfield.flags.wrap )			&&
	( strlen ( text ) > field->FIfield.nvc )	 )
    {
      text[field->FIfield.nvc] = '\0';
    }

  if ( row < 0 )
    {
      row = 0;
    }

  len = strlen ( text ) + 1;

  if ( row < field->FIfield.default_size )
    {
      if ( field->FIfield.defaults[row].line )
	{
	  field->FIfield.defaults[row].line = ( unsigned char *)
			realloc ( field->FIfield.defaults[row].line,
					len * sizeof ( unsigned char ));
	}
      else
	{
	  field->FIfield.defaults[row].line = ( unsigned char *)
				calloc ( len, sizeof ( unsigned char ));
	}
#if defined(hp9000)
      strcpy ( (char *) field->FIfield.defaults[row].line, text );
#else
      strcpy ( field->FIfield.defaults[row].line, text );
#endif
      field->FIfield.defaults[row].sel = (short) sel_flg;
    }
  else
    {
      _FI_fld_set_defaults ( field, row + 1 );

      if ( field->FIfield.defaults[row].line )	/***  JAJ:03/15/91 ***/
	{
	  free ( field->FIfield.defaults[row].line );
	}

      field->FIfield.defaults[row].line = ( unsigned char *) calloc
				      ( len, sizeof ( unsigned char ));

#if defined(hp9000)
      strcpy ( (char *) field->FIfield.defaults[row].line, text );
#else
      strcpy ( field->FIfield.defaults[row].line, text );
#endif

      field->FIfield.defaults[row].sel = (short) sel_flg;
    }

  if ( row >= field->FIfield.buffer_size )
    {
      _FI_fld_set_buffer ( field, row + 1, 1 );
    }

  _FI_fld_add_to_line ( field, row, len + 2 );

  if ( field->FIfield.nc )
    {
	/*** <pds-12/13/89> Calculate actual bytes to copy ***/

      len = FI_move_index ( text, 0, field->FIfield.nc,
					field->FIgadget.font_type );
      if ( len < 0 )
	{
	  len = strlen ( text );
	}
    }
  else	/*** Copy all bytes ***/
    {
      len = strlen ( text );
    }

/**********************************************************************/
/*                                                                    */
/*  All the following garbage does not need to be done.  Field default*/
/*  text should only be placed into the field during an FIg_reset     */
/*  operation.  Whoever wrote this code originally must have been on  */
/*  drugs.                                                            */
/*         GMD 10/29/91                                               */
/*                                                                    */
/**********************************************************************/
#if defined(hp9000)
    strncpy ( (char *) field->FIfield.buffer[row].line,
			(char *) field->FIfield.defaults[row].line, len );
#else
    strncpy ( field->FIfield.buffer[row].line,
			field->FIfield.defaults[row].line, len );
#endif
    field->FIfield.buffer[row].line[len] = '\0';
    field->FIfield.buffer[row].sel = field->FIfield.defaults[row].sel;
    if ( field->FIfield.buffer[row].sel & 1 )
    {
        if ( ( field->FIfield.mode == FI_SINGLE_SELECT )	&&
			( field->FIfield.prev_sel > -1 )	 )
	  {
	    field->FIfield.buffer[field->FIfield.prev_sel].sel = 0;
	  }

	field->FIfield.prev_sel = row;
    }

  return ( FI_SUCCESS );
}



/*=============================*/
/** Change to INTERNAL calls **/
/*=============================*/

int FIfld_pos_cursor (Form	form,
                      int   label,
                      int   row,
                      int   r_pos,
                      int   col,
                      int   col_pos,
                      int   ch,
                      int   ch_pos)
{
  int status;
  struct FIfld_obj *field;


  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }


  /* Mcf code will return if not a mcf gadget */

  status = FImcf_set_active_col ( form, label, col, col_pos );
  if ( ( status ) && ( status != FI_INVALID_GADGET_TYPE ))
    {
      return ( status );
    }

  status = FIfld_set_active_row ( form, label, row, r_pos );
  if ( status )
    {
      return ( status );
    }

  status = FIfld_set_active_char ( form, label, col, ch, ch_pos );
  if ( status )
    {
      return ( status );
    }

  status = FIg_start_seq ( form, label );

  return ( status );
}


/*===================================================================*/

int FIfld_erase_cursor (Form  form,
                        int   label)
{
  Window window;
  int status;
  struct FIgadget_obj *gadget;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							-1, &field );
  if ( status )
    {
      return ( status );
    }

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  window = XWINDOW ( field );

  if ( ( window != None ) &&  field->FIgadget.form->displayed  )
    {
	/** X11-5/22/90-When erasing cursor focus has no effect **/

      if ( ( field->FIfield.mode == FI_INSERT )		||
	   ( field->FIfield.mode == FI_APPEND )		 )
	{
	  _FI_fld_draw_cursor ( field, window, 1, FI_MED_GREY,
		_FI_fld_get_line_ON_COLOR ( field, field->FIfield.ar ));
	}

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
        if (!_FI_dont_flush)
          XFlush ( _FI_display );
    }

  if ( gadget->FIgadget.type == FI_MULTI_COL )
    {
      _FI_mcf_break_navigation = TRUE;
    }

  return ( FI_SUCCESS );
}



/*====================================================================*/

int FIfld_get_active_char (Form  form,
                           int   label,
                           int   col,
                           int  *ch,
                           int  *pos)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  *ch = field->FIfield.ac;

  *pos = field->FIfield.ac - field->FIfield.coff;

  if ( *pos < 0 || *pos > field->FIfield.nvc )
    {
      *pos = -1;
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_set_active_char (Form  form,
                           int   label,
                           int   col,
                           int   ch,
                           int   pos)
{
  Window	window;
  int		status, len;
  struct FIfld_obj *field;


  /* MACK check added for invalid col 12/01/89 */

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  if (	( field->FIfield.buffer_size > 0 )			&&
	( field->FIfield.buffer[field->FIfield.ar].line )	 )
    {
      len = FI_strlen ( (char *)field->FIfield.buffer[field->FIfield.ar].line,
					field->FIgadget.font_type );
    }
  else
    {
      len = 0;
    }

	/*** <pds-1/4/90> Added check for negative 'ch' and 'pos'.  ***/
	/*** If the user puts in negative values, he will get 0,    ***/
	/*** because negative values don't mean anything.	    ***/

  if ( ch < 0 )	/* 'ch' negative */
    {
      field->FIfield.ac = 0;
    }
  else if ( ch <= len )
    {
      field->FIfield.ac = ch;
    }
  else	/* 'ch' greater than len */
    {
      field->FIfield.ac = len;
    }

  if ( pos > field->FIfield.nvc - 1 )
    {
      pos = field->FIfield.nvc - 1;
    }
  else if ( pos < 0 )	/* 'pos' negative */
    {
      pos = 0;
    }

  if ( ( pos > -1 )					  &&
	 field->FIfield.flags.lrs			  &&
       ( field->FIfield.coff != field->FIfield.ac - pos )  )
    {
      field->FIfield.coff = field->FIfield.ac - pos;

      if ( field->FIfield.coff < 0 )
	{
	  field->FIfield.coff = 0;
	}

      window = XWINDOW ( field );

      if ( ( window != None ) && ( field->FIgadget.form->displayed ) )
	{
	  _FI_fld_refresh_data ( field, window );

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
          if (!_FI_dont_flush)
            XFlush ( _FI_display );
	}
    }
  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_set_select (Form  form,
                      int   label,
                      int   row,
                      int   col,
                      int   sel_flg)
{
  Window   window;
  int		status, prev_row;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  if ( ( row >= field->FIfield.buffer_size ) || ( row < 0 ) )
    {
      return ( FI_INVALID_ROW );
    }

  prev_row = -1;

  if (	( field->FIfield.mode == FI_SINGLE_SELECT )		&&
	( field->FIfield.prev_sel > -1 )			 )
    {
      if ( sel_flg )
	{
	  if ( field->FIfield.prev_sel < field->FIfield.buffer_size )
	    {
	      field->FIfield.buffer[field->FIfield.prev_sel].sel = 0;
	      prev_row = field->FIfield.prev_sel;
	    }
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

  window = XWINDOW ( field );

  if ( window != None )
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

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_set_verify_routine (Form   form,
                              int    label,
                              int    col,
                              int  (*func)())
{
  int status;
  struct FIfld_obj *field;


  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  field->FIfield.validation = func;

  return ( FI_SUCCESS );
}



int FIfld_get_verify_routine (Form     form,
                              int      label,
                              int      col,
                              int   (**func)())
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  *func = field->FIfield.validation;

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_set_format_routine (Form    form,
                              int     label,
                              int     col,
                              int   (*func)())
{
  int	status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  field->FIfield.format = func;

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_get_format_routine (Form   form,
                              int   label,
                              int   col,
                              int   (**func)())
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  *func = field->FIfield.format;

  return ( FI_SUCCESS );
}



/*====================================================================*/

int FIfld_get_attr (Form   form,
                    int    label,
                    int    col,
                    long  *attr_mask)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  *attr_mask = 0;

  if ( field->FIfield.flags.uds )
    {
      *attr_mask |= FI_VERT_SCROLL;
    }
  else if ( field->FIfield.flags.roll_thru )
    {
      *attr_mask |= FI_ROLL_THRU;
    }

  if ( field->FIfield.flags.lrs )
    {
      *attr_mask |= FI_HORT_SCROLL;
    }
  else if ( field->FIfield.flags.wrap )
    {
      *attr_mask |= FI_WRAP;
    }

  if ( field->FIfield.flags.draw_vscrl )
    {
      *attr_mask |= FI_DISPLAY_VSCROLL;
    }

  if ( field->FIfield.flags.draw_hscrl )
    {
      *attr_mask |= FI_DISPLAY_HSCROLL;
    }

  if ( field->FIfield.flags.clear )
    {
      *attr_mask |= FI_CLEAR_ON_SELECTION;
    }

  if ( field->FIfield.flags.by_line )
    {
      *attr_mask |= FI_NOTIFY_BY_LINE;
    }

  if ( field->FIfield.flags.ascii_only )
    {
      *attr_mask |= FI_ASCII_INPUT_ONLY;
    }

  if ( field->FIfield.flags.no_echo )
    {
      *attr_mask |= FI_NO_ECHO;
    }

  if ( field->FIfield.flags.required )
    {
      *attr_mask |= FI_REQUIRED;
    }

  /* Hebrew 30-07-90 */

  if ( field->FIfield.flags.right_to_left )
    {
      *attr_mask |= FI_RIGHT_TO_LEFT;
    }

  if ( field->FIfield.flags.reverse_input == 1 )
    {
      *attr_mask |= FI_REVERSE_INPUT;
    }

  if ( field->FIfield.flags.reverse_output == 1 )
    {
      *attr_mask |= FI_REVERSE_OUTPUT;
    }

  if ( field->FIfield.list_id )
    {
      if ( field->FIfield.flags.popup_list )
	{
	  *attr_mask |= FI_POPUP_ASSO_LIST;
	}
      else
	{
	  *attr_mask |= FI_ASSOCIATED_LIST;
	}

      if ( field->FIfield.flags.dismiss )
	{
	  *attr_mask |= FI_DISMISS_LIST_ON_SEL;
	}

      if ( field->FIfield.flags.valid_list )
	{
	  *attr_mask |= FI_VALIDATE_BY_LIST;
	}
    }

  return ( FI_SUCCESS );
}



/*====================================================================*/

int FIfld_set_attr (Form  form,
                    int   label,
                    int   col,
                    long  attr_mask)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  field->FIfield.flags.draw_vscrl =
			( attr_mask & FI_DISPLAY_VSCROLL ) ? 1 : 0;

  field->FIfield.flags.draw_hscrl =
			( attr_mask & FI_DISPLAY_HSCROLL ) ? 1 : 0;

  /* Hebrew 30-07-90 */

  if ( attr_mask & FI_RIGHT_TO_LEFT )
    {
      field->FIfield.flags.right_to_left = 1;
    }
  else
    {
      field->FIfield.flags.right_to_left = 0;
    }

  if ( attr_mask & FI_REVERSE_INPUT )
    {
      field->FIfield.flags.reverse_input = 1;
    }
  else
    {
      field->FIfield.flags.reverse_input = 0;
    }

  if ( attr_mask & FI_REVERSE_OUTPUT )
    {
      field->FIfield.flags.reverse_output = 1;
    }
  else
    {
      field->FIfield.flags.reverse_output = 0;
    }

  if ( attr_mask & FI_VERT_SCROLL )
    {
      field->FIfield.flags.uds = 1;
      field->FIfield.flags.roll_thru = 0;
      field->FIfield.nr = 0;

      if ( ! field->FIfield.flags.is_a_col	&&
	   ! field->FIfield.vscrl_id		 )
	{
	  _FI_fld_add_vscrl ( field );
	}
    }
  else
    {
      field->FIfield.flags.uds = 0;

      if ( attr_mask & FI_ROLL_THRU )
	{
	  field->FIfield.flags.roll_thru = 1;
	  field->FIfield.nr = 0;
	  field->FIgadget.xhi += ROLL_THROUGH_SYM_WIDTH;
	}

      if ( field->FIfield.vscrl_id )
	{
	  _FI_g_delete ( (struct FIgadget_obj *)field->FIfield.vscrl_id, TRUE );

	  field->FIfield.vscrl_id = 0;
	}
    }

  if ( attr_mask & FI_HORT_SCROLL )
    {
      field->FIfield.flags.lrs = 1;
      field->FIfield.flags.wrap = 0;
      field->FIfield.nc = 0;

      if ( ! field->FIfield.hscrl )
	{
	  _FI_fld_add_hscrl ( field );
	}
    }
  else
    {
      field->FIfield.flags.lrs = 0;

      if ( attr_mask & FI_WRAP )
	{
	  field->FIfield.flags.wrap = 1;
	}
      else
	{
	  field->FIfield.flags.wrap = 0;
	}
    }

  field->FIfield.flags.clear =
			( attr_mask & FI_CLEAR_ON_SELECTION ) ? 1 : 0;

  field->FIfield.flags.by_line =
			( attr_mask & FI_NOTIFY_BY_LINE ) ? 1 : 0;

  field->FIfield.flags.ascii_only =
			( attr_mask & FI_ASCII_INPUT_ONLY ) ? 1 : 0;

  field->FIfield.flags.no_echo = ( attr_mask & FI_NO_ECHO ) ? 1 : 0;

  field->FIfield.flags.required = ( attr_mask & FI_REQUIRED ) ? 1 : 0;

  if (	( attr_mask & FI_POPUP_ASSO_LIST )		||
	( attr_mask & FI_ASSOCIATED_LIST )		 )
    {
      if ( ! field->FIfield.list_id )	/* create */
	{
	  int list_label;

	  field->FIgadget.xhi += ROLL_THROUGH_SYM_WIDTH;

	  _FI_f_get_next_neg_label ( field->FIgadget.form, &list_label);

	  if ( ! _FI_g_new ( field->FIgadget.form, FI_FIELD,
				list_label, (struct FIgadget_obj **)&field->FIfield.list_id ))
	    {
  	      struct FIfld_obj *tmp_list_id = field->FIfield.list_id;

	      _FI_s_rep ( &tmp_list_id->FIgadget.fontname,
					field->FIgadget.fontname );

	      tmp_list_id->FIgadget.bodysize = field->FIgadget.bodysize;

	      tmp_list_id->FIgadget.off_color = OFF_COLOR ( field );
	      tmp_list_id->FIgadget.on_color = ON_COLOR ( field );
	      tmp_list_id->FIfield.mode = FI_SINGLE_SELECT;
	      tmp_list_id->FIfield.flags.uds = 1;
	      tmp_list_id->FIfield.flags.lrs = 1;
	      tmp_list_id->FIfield.flags.draw_vscrl = 1;
	      tmp_list_id->FIfield.flags.draw_hscrl = 1;
	      tmp_list_id->FIfield.flags.is_a_list = 1;
	      tmp_list_id->FIfield.flags.by_line = 1;
	      tmp_list_id->FIgadget.user_pointer = ( char *) field;
	      tmp_list_id->FIfield.prev_sel = -1;

           /* Hebrew 30-07-90 */

	      if ( attr_mask & FI_RIGHT_TO_LEFT )
		{
		  tmp_list_id->FIfield.flags.right_to_left = 1;
		}
	      else
		{
		  tmp_list_id->FIfield.flags.right_to_left = 0;
		}

	      if ( attr_mask & FI_REVERSE_INPUT )
		{
		  tmp_list_id->FIfield.flags.reverse_input = 1;
		}
	      else
		{
		  tmp_list_id->FIfield.flags.reverse_input = 0;
		}

	      if ( attr_mask & FI_REVERSE_OUTPUT )
		{
		  tmp_list_id->FIfield.flags.reverse_output = 1;
		}
	      else
		{
		  tmp_list_id->FIfield.flags.reverse_output = 0;
		}
	    }
	}

      if ( attr_mask & FI_POPUP_ASSO_LIST )
	{
	  field->FIfield.flags.popup_list = 1;

	  field->FIfield.list_id->FIgadget.attr_mask |=
						FI_NOT_DISPLAYED;

	  field->FIfield.list_id->FIgadget.default_attr_mask |=
						FI_NOT_DISPLAYED;
	}
      else	/* Added re-display GMD 10/3/90 */
	{
	  field->FIfield.flags.popup_list = 0;

	  if ( field->FIfield.list_id->FIgadget.attr_mask &
						FI_NOT_DISPLAYED )
	    {
	      field->FIfield.list_id->FIgadget.attr_mask &=
						~FI_NOT_DISPLAYED;
	    }

	  if ( field->FIfield.list_id->FIgadget.default_attr_mask &
						FI_NOT_DISPLAYED )
	    {
	      field->FIfield.list_id->FIgadget.default_attr_mask &=
						~FI_NOT_DISPLAYED;
	    }
	}
    }
  else if ( field->FIfield.list_id )
    {
      _FI_g_delete ( (struct FIgadget_obj *)field->FIfield.list_id, TRUE );

      field->FIfield.list_id = 0;
    }

	/*** added this if statement -- JAJ:01/22/92 ***/
  if ( ! (attr_mask & FI_POPUP_ASSO_LIST ) )
    {
      field->FIfield.flags.popup_list = 0;
    }

	/*** moved this if statement -- JAJ:01/22/92 ***/
  if ( attr_mask & FI_DISMISS_LIST_ON_SEL )
    {
      field->FIfield.flags.dismiss = 1;
    }
  else
    {
      field->FIfield.flags.dismiss = 0;
    }

	/*** moved this if statement -- JAJ:01/22/92 ***/
  if ( attr_mask & FI_VALIDATE_BY_LIST )
    {
      field->FIfield.flags.valid_list = 1;
    }
  else
    {
      field->FIfield.flags.valid_list = 0;
    }

  return ( FI_SUCCESS );
}



/*====================================================================*/

int FIfld_get_max_num_chars (Form   form,
                             int    label,
                             int    col,
                             int   *num_chars)
{
  int	status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  *num_chars = field->FIfield.nc;

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_set_max_num_chars (Form   form,
                             int   label,
                             int   col,
                             int   num_chars)
{
  int		ii, status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  /*** <pds-1/4/90> Added check for negative 'num_chars' ***/

  if ( num_chars < 0 )
    {
      return FI_ILLEGAL_VALUES;
    }

  if ( num_chars > 32767 )
    {
      num_chars = 32767;
    }

	/*** If the new max nc is less than the current	max nc, ***/
	/*** then refresh the field to eliminate the extra	***/
	/*** characters.					***/

	/* remove data that is beyond the max # of characters range */

  for ( ii = 0; ii < field->FIfield.buffer_size; ii++ )
    {
      if ( strlen ( (char *)field->FIfield.buffer[ii].line ) > num_chars )
	{
	  field->FIfield.buffer[ii].line[num_chars] = '\0';
	}
    }

  field->FIfield.nc = num_chars;

  field->FIfield.flags.lrs =
		(( field->FIfield.nc > field->FIfield.nvc )	||
		( ! field->FIfield.nc )				 );

  if (	( num_chars < field->FIfield.nvc )			   &&
	( XWINDOW ( field ) != None )				   &&
	IT_IS_DISPLAYED ( field ) && IT_IS_DISPLAYABLE ( field )    )
    {
      _FI_fld_refresh_data ( field, XWINDOW ( field ));
    }

  return ( FI_SUCCESS );
}



/*==================================================*/
/* This function gets the data at row in the field. */
/*==================================================*/

int FIfld_get_mode (Form  form,
                    int   label,
                    int   col,
                    int  *mode)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  *mode = field->FIfield.mode;

  return ( FI_SUCCESS );
}



/*====================================================================*/

int FIfld_set_mode (Form  form,
                    int   label,
                    int   col,
                    int   mode)
{
  int	status, ii;
  struct FIfld_obj *field;

  /*** <pds-1/4/90> Check for valid mode ***/

  switch ( mode )
    {
      case FI_REVIEW:
      case FI_SINGLE_SELECT:
      case FI_MULTI_SELECT:
      case FI_APPEND:
      case FI_INSERT:
	break;

      default:
        return ( FI_ILLEGAL_VALUES );
	/* break; */
    }

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  field->FIfield.mode = mode;

  if ( field->FIfield.mode == FI_SINGLE_SELECT )
    {
      for ( ii = 0; ii < field->FIfield.buffer_size; ii++ )
	{
	  field->FIfield.buffer[ii].sel &= 0xffff ^ 0x1;
	}

      if ( field->FIfield.prev_sel > -1 )
	{
	  field->FIfield.buffer[field->FIfield.prev_sel].sel = 1;
	}
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_get_num_vis_chars (Form  form,
                             int   label,
                             int   col,
                             int  *num_chars)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  *num_chars = field->FIfield.nvc;

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_set_num_vis_chars (Form  form,
                             int   label,
                             int   col,
                             int   num_chars)
{
  Window	window;
  int		status, was_displayable;
  struct FIfld_obj *field;
  int form_displayed;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  if ( num_chars == field->FIfield.nvc )
    {
      return ( FI_SUCCESS );
    }
  else if ( num_chars < 1 )
    {
      return FI_ILLEGAL_VALUES;
    }

  FIf_is_displayed (form, &form_displayed);
  was_displayable = IT_IS_DISPLAYABLE ( field );

  /* If the form is erased at the time that this call is made, then    */
  /* a field gadget that thought it was displayed will now think that  */
  /* it is erased.  Change this so that it only erases the gadget if   */
  /* the form is displayed.       GMD 10/2/91                          */

  if (was_displayable && form_displayed)
     _FI_g_erase ( (struct FIgadget_obj *) field );

  if (	( field->FIgadget.font_width  == 0 )	||
	( field->FIgadget.font_height == 0 )	||
	( field->FIfield.line_height  == 0 )	||
	( field->FIgadget.font_id     == 0 )	 )
    {
      _FI_fld_change_text ( field, 1.0, 1.0 );
    }

  if ( num_chars )
    {
      if ( field->FIfield.nvc == field->FIfield.nc )
	{
	  field->FIfield.nc = num_chars;
	}

      field->FIfield.nvc = num_chars;
    }

  field->FIgadget.xhi = field->FIgadget.xlo +
	 ( field->FIfield.nvc * field->FIgadget.font_width );

  if ( field->FIfield.list_id || field->FIfield.flags.roll_thru )
    {
      field->FIgadget.xhi += ROLL_THROUGH_SYM_WIDTH + FIELD_BEZEL;
    }

  if ( field->FIfield.flags.is_a_col )
    {
      _FI_mcf_adjust_cols ( (struct FImcf_obj *)field->FIgadget.group );

      _FI_generic_move_hort ( 
       (struct FIgadget_obj *)((struct FImcf_obj *) field->FIgadget.group )->FImcf.vscrl_id,
	   (int) field->FIgadget.group->FIgadget.xhi );

      if ( was_displayable && form_displayed )
	{
	  _FI_g_set_displayable ( (struct FIgadget_obj *)field->FIgadget.group );

	  _FI_g_display ( (struct FIgadget_obj *) field->FIgadget.group,
					XWINDOW ( field ) );
	}
    }

  if ( field->FIfield.vscrl_id )
    {
      _FI_generic_move_hort ( (struct FIgadget_obj *)field->FIfield.vscrl_id,
				(int) field->FIgadget.xhi + 2 );
    }

  if ( field->FIfield.hscrl )
    {
      field->FIfield.hscrl[0]->FIgadget.xlo = field->FIgadget.xlo - 2;

      field->FIfield.hscrl[0]->FIgadget.xhi = field->FIgadget.xlo +
		(( field->FIgadget.xhi - field->FIgadget.xlo ) / 2 );

      field->FIfield.hscrl[1]->FIgadget.xlo =
				field->FIfield.hscrl[0]->FIgadget.xhi;

      field->FIfield.hscrl[1]->FIgadget.xhi = field->FIgadget.xhi + 2;

      _FI_g_adjust_size ( (struct FIgadget_obj *)field->FIfield.hscrl[0], 1.0, 1.0 );
      _FI_g_adjust_size ( (struct FIgadget_obj *)field->FIfield.hscrl[1], 1.0, 1.0 );
    }

  window = XWINDOW ( field );

	/*** <pds-1/5/90> Check to see if the field		   ***/
	/*** 'was_displayable' before it is to be displayed again. ***/

  if ( ( window != None )			&&
	field->FIgadget.form->displayed		&&
	( ! field->FIfield.flags.is_a_col )	&&
	was_displayable				 )
    {
      _FI_g_set_displayable ( (struct FIgadget_obj *)field );

      _FI_g_display ( (struct FIgadget_obj *) field, window );
    }

  return ( FI_SUCCESS );
}



/*=========================================================*/
/* This function returns the type of the data in the field */
/*=========================================================*/

int FIfld_get_type (Form  form,
                    int   label,
                    int   col,
                    int  *type)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  *type = field->FIfield.field_type;

  return ( FI_SUCCESS );
}


/*==================================================*/
/* This function sets the data at row in the field. */
/*==================================================*/

int FIfld_set_type (Form   form,
                    int    label,
                    int    col,
                    int    type)
{
  int status;
  struct FIfld_obj *field;

  if (	( type != FI_ALPHA )	&&
	( type != FI_INT )	&&
	( type != FI_DOUBLE )	 )
    {
      return FI_ILLEGAL_VALUES;
    }

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  field->FIfield.field_type = type;

  return ( FI_SUCCESS );
}


/*********************************************************************/
/* FIfld_set_line_color ( ) - GMD 4/7/90			     */
/*   This function allows the application to set the color for an    */
/* individual line of text in a field or MCF column.  This function  */
/* can only be done at run-time, since attempts to save a field with */
/* altered colors will not work.  To set the color for the text, use */
/* one of the #define colors from FI.h such as FI_RED.		     */
/*********************************************************************/

int FIfld_set_line_color (Form   form,
                          int    label,
                          int    row,
                          int    col,
                          int    color)
{
  Window window;
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  if ( ( row >= field->FIfield.buffer_size ) || ( row < 0 ) )
    {
      return ( FI_INVALID_ROW );
    }

  if ( color < -1 )
    {
      return ( FI_ILLEGAL_VALUES );
    }

  /*******************************************************************/
  /* A value of -1 will be incremented to make it a 0. A value of 0  */
  /* tells the run-time to use the default off and on colors.        */
  /* A value < 16 means that you want to override the color using    */
  /* one of the defined colors in FI.h.  If the value sent is > 16,  */
  /* then it will be stored as is.				     */
  /*******************************************************************/

  if ( color < 16 )
    {
      color++;
    }

  field->FIfield.buffer[row].color = color;

  window = XWINDOW ( field );

  if ( window != None )
    {
      _FI_fld_refresh_row ( field, window, row );

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
      if (!_FI_dont_flush)
        XFlush ( _FI_display );
    }

  return ( FI_SUCCESS );
}



/**********************************************************************/
/* FIfld_get_line_color ( ) - 			GMD 4/7/90	      */
/* This function allows the application to determine if a field's     */
/* default colors have been overridden for a particular line.  MCFs   */
/* can also examine lines on a column by column basis.  A value of -1 */
/* means that the default color has not been overridden.  Any other   */
/* number should be a #define taken from FI.h such as FI_RED.         */
/**********************************************************************/

int FIfld_get_line_color (Form  form,
                          int   label,
                          int   row,
                          int   col,
                          int  *color)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  if ( ( row >= field->FIfield.buffer_size ) || ( row < 0 ) )
    {
      return ( FI_INVALID_ROW );
    }

  /********************************************************************/
  /* If Color is 16 or less, then decrement the value before sending  */
  /* it back.  The reason for doing this is that I wanted to reserve  */
  /* the 0 value for using the default colors that were defined for   */
  /* the field.  Unfortunately, there is a conflict between using 0   */
  /* for this purpose and the I/FORMS defined color FI_OFF_WHITE      */
  /* which also has a value of 0.				      */
  /*   The solution was to add 1 to each of the forms colors so that  */
  /* 0 could be used to indicate default color.  The run-time code    */
  /* is smart enough to perform the decrement before using the        */
  /* overridden color.  You also need to perform the decrement here   */
  /* to tell the application what color is actually being used.       */
  /********************************************************************/

  *color = field->FIfield.buffer[row].color;

  if ( *color <= 16 )
    {
      ( *color ) --;
    }

  return ( FI_SUCCESS );
}

