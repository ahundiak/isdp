#include "FImin.h"

#include "FIscroll.h"
#include "FIbtn.h"
#include "FImcf.h"
#include "FIseq.h"
#include "FIfield.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/*====================================================================*/

int FIfld_get_active_row (Form  form,
                          int   label,
                          int  *row,
                          int  *pos)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							-1, &field );
  if ( status )
    {
      return ( status );
    }

  *row = field->FIfield.ar;

  *pos = field->FIfield.ar - field->FIfield.roff;

  if ( *pos < 0 || *pos > field->FIfield.nvr )
    {
      *pos = -1;	/* not showing */
    }

  return ( FI_SUCCESS );
}



/*====================================================================*/

int FIfld_get_row_offset (Form  form,
                          int   label,
                          int  *row_offset)
{
  struct FIfld_obj	*field;
  struct FIgadget_obj	*gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type == FI_FIELD )
    {
      field = (struct FIfld_obj *) gadget;

      *row_offset = field->FIfield.roff;
    }
  else if ( gadget->FIgadget.type == FI_MULTI_COL )
    {
      _FI_fld_get_field ( (struct FIform_obj *)form, label, 0, &field );

      *row_offset = field->FIfield.roff;
    }
  else
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_get_row_height (Form  form,
                          int   label,
                          int  *row_height)
{
  struct FIfld_obj *field;
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type == FI_FIELD )
    {
      field = (struct FIfld_obj *) gadget;

      *row_height = field->FIfield.line_height;
    }
  else if ( gadget->FIgadget.type == FI_MULTI_COL )
    {
      _FI_fld_get_field ( (struct FIform_obj *)form, label, 0, &field );

      *row_height = field->FIfield.line_height;
    }
  else
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



/*****************************************/
/* This code actually deletes the row.	 */
/*****************************************/

int _FI_fld_delete_rows (struct FIfld_obj  *field,
                         int                start_row,
                         int                num_rows,
                         int               *roff_adjusted)
{
  int xx;
  int xx_minus_num_rows;


  xx = start_row + num_rows;

  if ( xx < field->FIfield.buffer_size )
    {
      for (  ; xx < field->FIfield.buffer_size; xx++ )
	{
	  xx_minus_num_rows = xx - num_rows;

	  _FI_fld_add_to_line ( field, xx_minus_num_rows,
			strlen ( (char *)field->FIfield.buffer[xx].line ) + 2 );

#if defined(hp9000)
	  strcpy ( (char *) field->FIfield.buffer[ xx_minus_num_rows ].line,
				(char *) field->FIfield.buffer[xx].line );
#else
	  strcpy ( field->FIfield.buffer[ xx_minus_num_rows ].line,
				field->FIfield.buffer[xx].line );
#endif

	  field->FIfield.buffer[ xx_minus_num_rows ].sel =
					field->FIfield.buffer[xx].sel;

	  field->FIfield.buffer[ xx_minus_num_rows ].paragraph =
				    field->FIfield.buffer[xx].paragraph;
	}

      _FI_fld_set_buffer ( field,
			field->FIfield.buffer_size - num_rows, 0 );
    }
  else
    {
      _FI_fld_set_buffer ( field, start_row, 0 );
    }

  if ( field->FIfield.roff >
		( field->FIfield.buffer_size - field->FIfield.nvr ) )
    {
      field->FIfield.roff = field->FIfield.buffer_size -
						field->FIfield.nvr;

      if ( field->FIfield.roff < 0 )
	{
	  field->FIfield.roff = 0;
	}

      *roff_adjusted = 1;
    }
  else
    {
      *roff_adjusted = 0;
    }

  return ( FI_SUCCESS );
}



/********************************************************/
/* FIfld_delete_rows ( ) -				*/
/*     This function allows the application to remove	*/
/* lines from a field or MCF gadget. All rows below	*/
/* the targetted rows will move up one slot. The	*/
/* number of rows will be decremented. Finally the	*/
/* display area will be refreshed if the viewing area	*/
/* was affected and the gadget is displayed.		*/
/********************************************************/

int FIfld_delete_rows (Form  form,
                       int   label,
                       int   start_row,
                       int   num_rows)
{
  Window		window;
  int			xx, roff_adjusted;
  struct FIfld_obj	*field;
  struct FIgadget_obj	*gadget;
  struct FImcf_obj	*multicol = 0;


  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if (	( num_rows  < 1 ) /* Must delete at least one row */	||
	( start_row < 0 ) /* Row must exist */		    	 )
    {
      return ( FI_INVALID_ROW );
    }

  if ( gadget->FIgadget.type == FI_FIELD )
    {
      field = (struct FIfld_obj *) gadget;

      if ( start_row < field->FIfield.buffer_size )
	{
	  _FI_fld_delete_rows ( field, start_row, num_rows,
						&roff_adjusted );
	}
      else
	{
	  return ( FI_INVALID_ROW );
	}
    }
  else if ( gadget->FIgadget.type == FI_MULTI_COL )
    {
      multicol = (struct FImcf_obj *) gadget;

      for ( xx = 0; xx < (int)multicol->FImcf.ncol; xx++ )
	{
	  _FI_fld_get_field ( (struct FIform_obj *)form, label, xx, &field );

	  if ( start_row < field->FIfield.buffer_size )
	    {
              _FI_fld_delete_rows ( field, start_row, num_rows,
						&roff_adjusted );
	    }
	  else
	    {
              return ( FI_INVALID_ROW );
	    }
	}
    }
  else
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  /**************************************************************/
  /* If row was altered in the display area, then refresh	*/
  /* the text in the viewing area of the field/MCF.		*/
  /**************************************************************/

  /**************************************************************/
  /* This test might not work if every row beyond the		*/
  /* display area was deleted. In that case, roff might		*/
  /* have to be adjusted upwards, invalidating this test.	*/
  /**************************************************************/

  if ( ( start_row < ( field->FIfield.roff + field->FIfield.nvr ) )   ||
	roff_adjusted						       )
    {
     window = XWINDOW ( field );

     if ( ( window != None ) && ( IT_IS_DISPLAYED ( gadget )) )
	{
	  if ( gadget->FIgadget.type == FI_MULTI_COL )
	    {
	      for ( xx = 0; xx < (int)multicol->FImcf.ncol; xx++ )
		{
		  _FI_fld_get_field ( (struct FIform_obj *)form, label, xx, &field );

		  _FI_fld_refresh_data ( field, window );
		}
	    }
	  else
	    {
              _FI_fld_refresh_data ( field, window );
            }

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


/****************************************/
/* This code actually inserts the row.	*/
/****************************************/

int _FI_fld_insert_blank_row (struct FIfld_obj  *field,
                              int                row)
{
  int xx, xx_plus_1;


  _FI_fld_set_buffer ( field, field->FIfield.buffer_size + 1, 0 );

  for ( xx = field->FIfield.buffer_size - 2; xx >= row; xx-- )
    {
      xx_plus_1 = xx + 1;

      _FI_fld_add_to_line ( field, xx_plus_1,
		strlen ( (char *)field->FIfield.buffer[xx].line ) + 2 );

#if defined(hp9000)
      strcpy ( (char *) field->FIfield.buffer[ xx_plus_1 ].line,
				(char *) field->FIfield.buffer[xx].line );
#else
      strcpy ( field->FIfield.buffer[ xx_plus_1 ].line,
				field->FIfield.buffer[xx].line );
#endif

      field->FIfield.buffer[ xx_plus_1 ].sel =
					field->FIfield.buffer[xx].sel;

      field->FIfield.buffer[ xx_plus_1 ].paragraph =
				    field->FIfield.buffer[xx].paragraph;
    }

  _FI_fld_add_to_line ( field, row, 1 );

  field->FIfield.buffer[row].line[0]= '\0';

  return ( FI_SUCCESS );
}



/**********************************************************/
/* FIfld_insert_blank_row ( ) -				  */
/*   This function allows the application to add a new	  */
/* blank line to a field or MCF gadget.  All rows	  */
/* starting at the targetted row will move down one	  */
/* slot.  The number of rows will be incremented by	  */
/* Finally the display area will be refreshed if the	  */
/* viewing area was affected and the gadget is displayed. */
/**********************************************************/

int FIfld_insert_blank_row (Form  form,
                            int   label,
                            int   row)
{
  Window	window;
  int		xx;
  struct FIfld_obj *field;
  struct FIgadget_obj *gadget;
  struct FImcf_obj *multicol = 0;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );
  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type == FI_FIELD )
    {
      field = (struct FIfld_obj *) gadget;

      if ( row < field->FIfield.buffer_size )
	{
	  _FI_fld_insert_blank_row ( field, row );
	}
      else
	{
	  return ( FI_INVALID_ROW );
	}
    }
  else if ( gadget->FIgadget.type == FI_MULTI_COL )
    {
      multicol = (struct FImcf_obj *) gadget;

      for ( xx = 0; xx < (int)multicol->FImcf.ncol; xx++ )
	{
	  _FI_fld_get_field ( (struct FIform_obj *)form, label, xx, &field );

	  if ( row < field->FIfield.buffer_size )
	    {
              _FI_fld_insert_blank_row ( field, row );
            }
          else
            {
              return ( FI_INVALID_ROW );
            }
	}
    }
  else
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  /**************************************************************/
  /* If row was altered in the display area, then refresh	*/
  /* the text in the viewing area of the field/MCF.		*/
  /**************************************************************/

  if ( row < ( field->FIfield.roff + field->FIfield.nvr ) )
    {
     window = XWINDOW ( field );

     if ( window != None )
	{
	  if ( gadget->FIgadget.type == FI_MULTI_COL )
	    {
              for ( xx = 0; xx < (int)multicol->FImcf.ncol; xx++ )
		{
		  _FI_fld_get_field ( (struct FIform_obj *)form, label, xx, &field );

		  _FI_fld_refresh_data ( field, window );
		}
            }
          else
            {
              _FI_fld_refresh_data ( field, window );
            }

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

int FIfld_set_active_row (Form  form,
                          int   label,
                          int   row,
                          int   pos)
{
  int status;
  Window window;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							-1, &field );
  if ( status )
    {
      return ( status );
    }

  if ( row < 0 )
    {
      return ( FI_INVALID_ROW );
    }
  else if ( field->FIfield.buffer_size == 0 )
    {
      field->FIfield.ar = 0;
    }
  else if ( row < field->FIfield.buffer_size )
    {
      field->FIfield.ar = row;
    }
  else
    {
     return ( FI_INVALID_ROW );
    }

  if ( pos > field->FIfield.nvr - 1 )
    {
      pos = field->FIfield.nvr - 1;
    }

  window = XWINDOW ( field );

	/*** Change the roll thru value if roll-thru gadget ***/

  if (	( pos > -1 )						      &&
	( field->FIfield.roff != field->FIfield.ar - pos )	      &&
	( field->FIfield.flags.uds || field->FIfield.flags.roll_thru ) )
    {
      field->FIfield.roff = field->FIfield.ar - pos;

      if ( field->FIfield.roff < 0 )
	{
          field->FIfield.roff = 0;
	}

      if ( field->FIfield.roff >
		      field->FIfield.buffer_size - field->FIfield.nvr )
	{
          field->FIfield.roff =
			field->FIfield.buffer_size - field->FIfield.nvr;
	}

      if ( window != None )
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

  if ( field->FIfield.flags.is_a_col )
    {
		/***********************************/
		/* set active row for rest of cols */
		/***********************************/

      _FI_mcf_set_active_row ( (struct FImcf_obj *)field->FIgadget.group, field );

      if ( ( pos > -1 )						&&
         ( window != None )					&&
         ( field->FIgadget.form->displayed )			&&
         ( field->FIfield.roff != field->FIfield.ar - pos )	 )
	{
          _FI_grp_pass_on_id_int_always (
			(struct FIgadget_obj *) field->FIgadget.group,
			_FI_fld_refresh_data, window, 0 );

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
        if (!_FI_dont_flush)
          XFlush ( _FI_display );
	}

      _FI_mcf_set_vscrl ( (struct FImcf_obj *)field->FIgadget.group );
    }
  else
    {
      _FI_fld_set_vscrl ( field );
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_get_num_rows (Form  form,
                        int   label,
                        int  *num_rows)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							-1, &field );
  if ( status )
    {
      return ( status );
    }

  *num_rows = field->FIfield.buffer_size;

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_set_num_rows (Form form,
                        int label,
                        int num_rows)
{
  Window	window;
  int		status;
  struct FIfld_obj *field;
  int		attr;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							-1, &field );
  if ( status )
    {
      return ( status );
    }

  if ( num_rows < 0 )
    {
	/*** changed from "num_rows = 0;"  JAJ:09/06/91 ***/

      return FI_INVALID_ROW;
    }

  _FI_fld_set_buffer ( field, num_rows, 1 );

  if ( field->FIfield.ar >= field->FIfield.buffer_size )
    {
      if ( field->FIfield.buffer_size )
	{
	  field->FIfield.ar = field->FIfield.buffer_size - 1;

               /* Add check to make sure that roff is not set to a  */
               /* negative value by mistake.   GMD 12/4/91          */

          if ( field->FIfield.buffer_size >= field->FIfield.nvr )
	    {
	      field->FIfield.roff = field->FIfield.buffer_size -
						 field->FIfield.nvr;
	    }
          else
	    {
              field->FIfield.roff = 0;
	    }
	}
      else
	{
	  field->FIfield.ar = 0;
	  field->FIfield.roff = 0;
	}

      if ( field->FIfield.flags.is_a_col )
	{
		/* set active row for rest of cols */

	  _FI_mcf_set_active_row ( (struct FImcf_obj *)field->FIgadget.group, field );
	}
    }

  window = XWINDOW ( field );

  if ( window != None )
    {
      if ( field->FIfield.flags.is_a_col )
	{
	  FIg_get_attr ( form, label, &attr );

	  if ( ! ( attr & FI_NOT_DISPLAYED ) )
	    {
              _FI_grp_pass_on_id_int_always (
			(struct FIgadget_obj *) field->FIgadget.group,
			_FI_fld_refresh_data, window, 0 );
            }
	}
      else
	{
          _FI_fld_refresh_data ( field, window );
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

int FIfld_get_max_num_rows (Form  form,
                            int   label,
                            int  *num_rows)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							0, &field );
  if ( status )
    {
      return ( status );
    }

  *num_rows = field->FIfield.nr;

  return ( FI_SUCCESS );
}



/*====================================================================*/

int FIfld_set_max_num_rows (Form  form,
                            int   label,
                            int   num_rows)
{
  struct FIfld_obj *field;
  struct FIgadget_obj *gadget;
  struct FImcf_obj *multicol;
  int xx;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( num_rows < 0 )
    {
      return FI_INVALID_ROW;
    }

  if ( gadget->FIgadget.type == FI_FIELD )
    {
      field = (struct FIfld_obj *) gadget;

      field->FIfield.nr = num_rows;

      if ( ( field->FIfield.nr > field->FIfield.nvr )	||
           ( ! field->FIfield.nr )			 )
	{
          field->FIfield.flags.uds = 1;
	}
      else
	{
          field->FIfield.flags.uds = 0;
	}
    }
  else if ( gadget->FIgadget.type == FI_MULTI_COL )
    {
      multicol = (struct FImcf_obj *) gadget;

      for ( xx = 0; xx < (int)multicol->FImcf.ncol; xx++ )
	{
          _FI_fld_get_field ( (struct FIform_obj *)form, label, xx, &field );

          field->FIfield.nr = num_rows;
	}
    }
  else
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



/*====================================================================*/

int FIfld_get_num_vis_rows (Form  form,
                            int   label,
                            int  *num_rows)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							0, &field );
  if ( status )
    {
      return ( status );
    }

  *num_rows = field->FIfield.nvr;

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_set_num_vis_rows (Form  form,
                            int   label,
                            int   num_rows)
{
  Window	window;
  int		status;
  int		was_displayable = 0;
  struct FIfld_obj *field;
  struct FIgadget_obj *gadget;
  static int	shift_down_flag;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							0, &field );
  if ( status )
    {
      return ( status );
    }

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( num_rows < 1 )
    {
      return FI_INVALID_ROW;
    }

  window = XWINDOW ( field );

  if ( gadget->FIgadget.type == FI_MULTI_COL )
    {
      struct FImcf_obj *mcfield;

      mcfield = (struct FImcf_obj *) gadget;

      if ( mcfield->FImcf.hscrl_id )
	{
          if ( mcfield->FImcf.hscrl_id->FIgadget.ylo >
				( mcfield->FIgadget.yhi + 8.0 ) )
	    {
              shift_down_flag = 1;
            }
          else
            {
              shift_down_flag = 0;
            }
	}

	/******************************************/
	/*** Erase the mcf <pds-1/5/90> and	***/
	/*** save its displayable status	***/
	/******************************************/

      was_displayable = IT_IS_DISPLAYABLE ( mcfield );

      _FI_g_erase ( (struct FIgadget_obj *) mcfield );

	/**************************************************/
	/*** Send the message to all columns in the mcf ***/
	/**************************************************/

      _FI_grp_pass_on_int_always ( (struct FIgadget_obj *) mcfield,
				FIfld_set_num_vis_rows, num_rows, 0 );

	/*** This code will change the mcf scroll bars	***/
	/*** if the field is part of a mcf.		***/

      field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[0];

      if ( field->FIgadget.yhi + 2 != mcfield->FIgadget.yhi )
	{
          mcfield->FIgadget.yhi = field->FIgadget.yhi + 2;

          if ( mcfield->FImcf.hscrl_id )
            {
	      if ( shift_down_flag == 0 )
		{
		  _FI_generic_move_vert ( (struct FIgadget_obj *)mcfield->FImcf.hscrl_id,
			(int) field->FIgadget.group->FIgadget.yhi );
		}
	      else
		{
		  _FI_generic_move_vert ( (struct FIgadget_obj *)mcfield->FImcf.hscrl_id,
		      (int) field->FIgadget.group->FIgadget.yhi + 12 );
		}
            }

          if ( mcfield->FImcf.vscrl_id )
            {
	      mcfield->FImcf.vscrl_id->FIgadget.yhi =
						mcfield->FIgadget.yhi;

	      _FI_g_adjust_size ( (struct FIgadget_obj *)mcfield->FImcf.vscrl_id, 1.0, 1.0 );
            }
	}

	/******************************************************/
	/* Redisplay the mcf <pds-1/5/90> if it was displayed */
	/******************************************************/

      if ( ( window != None )				&&
	         mcfield->FIgadget.form->displayed	&&
	         was_displayable			 )
	{
	  _FI_g_set_displayable ( (struct FIgadget_obj *)mcfield->FIgadget.group );

	  _FI_g_display ( (struct FIgadget_obj *) mcfield, window );
	}

      return ( FI_SUCCESS );
    }

  /**** else it's a FI_FIELD ****/

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							0, &field );

  if ( num_rows == field->FIfield.nvr )
    {
      return ( FI_SUCCESS );
    }

  if ( ! field->FIfield.flags.is_a_col )
    {
      was_displayable = IT_IS_DISPLAYABLE ( field );

      _FI_g_erase ( (struct FIgadget_obj *) field );
    }

  if (	( field->FIgadget.font_width  == 0 )	||
	( field->FIgadget.font_height == 0 )	||
	( field->FIfield.line_height  == 0 )	||
	( field->FIgadget.font_id     == 0 )	 )
    {
      _FI_fld_change_text ( field, 1.0, 1.0 );
    }

  if ( num_rows )
    {
      if ( field->FIfield.nvr == field->FIfield.nr )
	{
	  field->FIfield.nr = num_rows;
	}

      field->FIfield.nvr = num_rows;
    }

  field->FIgadget.yhi = field->FIgadget.ylo +
			field->FIfield.nvr * field->FIfield.line_height;

  if ( field->FIfield.vscrl_id )
    {
      field->FIfield.vscrl_id->FIgadget.yhi = field->FIgadget.yhi + 2;

      _FI_g_adjust_size ( (struct FIgadget_obj *) field->FIfield.vscrl_id, 1.0, 1.0 );
    }

  if ( field->FIfield.hscrl )
    {
      _FI_generic_move_vert ( (struct FIgadget_obj *)field->FIfield.hscrl[0],
					(int) field->FIgadget.yhi + 2 );

      _FI_generic_move_vert ( (struct FIgadget_obj *)field->FIfield.hscrl[1],
					(int) field->FIgadget.yhi + 2 );
    }

  if ( field->FIfield.flags.is_a_col )
    {
      gadget = (struct FIgadget_obj *) field->FIgadget.group;
    }
  else
    {
      gadget = (struct FIgadget_obj *) field;
    }

	/*** <pds-1/5/90> Check to see if the field	***/
	/*** 'was_displayable' before it is to be	***/
	/*** displayed again.				***/

  if (	( window != None )			&&
        gadget->FIgadget.form->displayed	&&
	( ! field->FIfield.flags.is_a_col )	&&
	was_displayable				 )
    {
      _FI_g_set_displayable ( gadget );

      _FI_g_display ( gadget, window );
    }

  return ( FI_SUCCESS );
}
