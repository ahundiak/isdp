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

void _FI_fld_scrl_next (struct FIfld_obj  *field,
                        int                count)
{
  int	len;
  int	flag = 0;

  while ( count-- )
    {
      if ( field->FIfield.buffer_size >
			( field->FIfield.roff + field->FIfield.nvr ))
	{
	  field->FIfield.roff++;

	  if ( field->FIfield.ar < field->FIfield.roff )
	    {
	      field->FIfield.ar++;

		/*** <pds-12/08/89> Changed from strlen ()  ***/

	      len = FI_strlen (
			(char *)field->FIfield.buffer[field->FIfield.ar].line,
			field->FIgadget.font_type );

	      if ( field->FIfield.ac > len )
		{
		  field->FIfield.ac = len;
		}
	    }
	  flag = 1;
	}
      else if ( field->FIfield.flags.roll_thru )
	{
	  field->FIfield.ar = 0;
	  field->FIfield.roff = 0;
	  flag = 1;
	}
    }

  if ( flag )
    {
      _FI_fld_refresh_data ( field, XWINDOW ( field ) );
    }
}


void _FI_fld_scrl_previous (struct FIfld_obj  *field,
                            int                count)
{
  int	len ;
  int	flag = 0;

  while ( count-- )
    {
      if ( field->FIfield.roff )
	{
	  field->FIfield.roff--;

	  if ( field->FIfield.ar - field->FIfield.roff >=
						field->FIfield.nvr )
	    {
	      field->FIfield.ar--;

		/*** <pds-12/08/89> Changed from strlen () ***/

	      len = FI_strlen (
			(char *)field->FIfield.buffer[field->FIfield.ar].line,
			field->FIgadget.font_type );

	      if ( field->FIfield.ac > len )
		{
		  field->FIfield.ac = len;
		}
	    }

	  flag = 1;
	}
    }

  if ( flag )
    {
      _FI_fld_refresh_data ( field, XWINDOW ( field ) );
    }
}


void _FI_fld_scrl_forward (struct FIfld_obj  *field,
                           int                count)
{
  int	flag = 0;
  int	len = 0;
  int	temp_len;
  int	ii;


  if ( field->FIfield.buffer )
    {
	/*** <pds-12/08/89> Changed from strlen ()		***/
	/*** <pds-12/14/89> Find longest line in viewing area	***/

      for ( ii = 0 ; ( ii < field->FIfield.nvr  )	&&
	    ( ii + field->FIfield.roff < field->FIfield.buffer_size );
								ii++ )
	{
	  temp_len = FI_strlen (
		(char *)field->FIfield.buffer[field->FIfield.roff + ii].line,
		field->FIgadget.font_type );

	  if ( temp_len > len )
	    {
	      len = temp_len;
	    }
	}
    }

  while ( count-- )
    {
	/*** <pds-12/15/89> In the append and change fields,	 ***/
	/*** allow the user to scroll the characters off the	 ***/
	/*** field, but in the review and select fields only	 ***/
	/*** allow them to scroll if there is more data to view. ***/

      if (  ( ( len > field->FIfield.coff )		 &&
	      ( ( field->FIfield.mode == FI_INSERT ) ||
		( field->FIfield.mode == FI_APPEND )  )   )	 ||
	    ( len > field->FIfield.coff + field->FIfield.nvc )    )
	{
	  field->FIfield.coff++;

	  if ( field->FIfield.ac < field->FIfield.coff )
	    {
	      field->FIfield.ac++;
	    }
	  flag = 1;
	}
    }

  if ( flag )
    {
      _FI_fld_refresh_data ( field, XWINDOW ( field ) );
    }
}



void _FI_fld_scrl_back (struct FIfld_obj  *field,
                        int                count)
{
  int flag = 0;

  while ( count-- )
    {
      if ( field->FIfield.coff )
	{
	  field->FIfield.coff--;

	  if (	( field->FIfield.ac - field->FIfield.coff >=
					field->FIfield.nvc )	||
		( field->FIfield.mode == FI_REVIEW )		 )
	    {
	      field->FIfield.ac--;
	    }
	  flag = 1;
	}
    }

  if ( flag )
    {
      _FI_fld_refresh_data ( field, XWINDOW ( field ) );
    }
}


/*********************************************************************/
/***  _FI_fld_hscrl:       changed from "void" to "int"            ***/
/***  Returns:  FI_SUCCESS                          JAJ:09/06/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_vscrl (struct FIfld_obj  *field,
                   double             value)
{
  int		count, roff, status;
  static short	first_in_grp = TRUE;


  if ( field->FIfield.flags.is_a_col  &&  first_in_grp )
    {
      first_in_grp = FALSE;

      _FI_grp_pass_on_id_double_always (
			(struct FIgadget_obj *) field->FIgadget.group,
			_FI_fld_vscrl, value, 0 );

      first_in_grp = TRUE;
    }
  else
    {
      if ( field->FIfield.nvr >= field->FIfield.buffer_size )
	{
		/* can't scroll */
	  return ( FI_SUCCESS );
	}

      if ( value == (double)((int)FI_PAGE_UP) )
	{
	  if ( field->FIfield.roff < field->FIfield.nvr )
	    {
	      count = field->FIfield.roff;
	    }
	  else
	    {
	      count = field->FIfield.nvr;
	    }

	  if ( count > 0 )
	    {
	      _FI_fld_scrl_previous ( field, count );
	    }
	}
      else if ( value == (double)((int)FI_LINE_UP) )
	{
	  _FI_fld_scrl_previous ( field, 1 );
	}
      else if ( value == (double)((int)FI_LINE_DOWN) )
	{
	   _FI_fld_scrl_next ( field, 1 );
	}
      else if ( value == (double)((int)FI_PAGE_DOWN) )
	{
	  if ( field->FIfield.roff + ( 2 * field->FIfield.nvr )   >=
					field->FIfield.buffer_size )
	    {
	      if ( field->FIfield.nvr > field->FIfield.buffer_size )
		{
		  count = 0;
		}
	      else
		{
		  count = field->FIfield.buffer_size	-
			  field->FIfield.roff - field->FIfield.nvr;
		}
	    }
	  else
	    {
	      count = field->FIfield.nvr;
	    }

	  if ( count )
	    {
	      _FI_fld_scrl_next ( field, count );
	    }
	}
      else if ( value == (double)((int)FI_TOP) )
	{
	  if ( field->FIfield.roff )
	    {
	      _FI_fld_scrl_previous ( field, field->FIfield.roff );
	    }
	}
      else if ( value == (double)((int)FI_BOTTOM) )
	{
	  if ( field->FIfield.nvr >=
		    field->FIfield.buffer_size - field->FIfield.roff )
	    {
	      count = 0;
	    }
	  else
	    {
	      count = field->FIfield.buffer_size -
			field->FIfield.roff - field->FIfield.nvr;
	    }

	  if ( count )
	    {
	      _FI_fld_scrl_next ( field, count );
	    }
	}
      else
	{
	  roff = (int) value;

	  if ( roff > field->FIfield.roff )
	    {
	      if ( roff + field->FIfield.nvr >=
					field->FIfield.buffer_size )
		{
		  roff = field->FIfield.buffer_size -
						field->FIfield.nvr;
		}

	      count = roff - field->FIfield.roff;

	      if ( count )
		{
		  _FI_fld_scrl_next ( field, count );
		}
	    }
	  else if ( roff < field->FIfield.roff )
	    {
	      count = field->FIfield.roff - roff;

	      if ( count )
		{
		  _FI_fld_scrl_previous ( field, count );
		}
	    }
	}
    }

  /***************************************************************/
  /* Force vertical scroll bar to return notification for fields */
  /************************************** GMD 8/31/90 ************/

  if ( ! field->FIfield.flags.is_a_col )
    {
      if ( field->FIgadget.form->notification_routine		&&
	   IT_HAS_COMPLETE_NOTIFY ( field )			&&
	   ( field->FIfield.flags.is_a_list == 0 )		&&
	   ( field->FIgadget.attr_mask & FI_VERT_SCROLL_NOTIFY ) )
	{
	  status = _FI_fld_notify ( field, (double) -3.0 );

		/*** if field/form was deleted in notification ***/
		/*** routine, then return ***/
	  if ( status != FI_SUCCESS )
	    {
	      return ( status );
	    }
	}
    }

  return ( FI_SUCCESS );
}
