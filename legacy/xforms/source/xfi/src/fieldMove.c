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

/*********************************************************************/
/***  _FI_fld_next:   changed from "void" to "int"                 ***/
/***  Returns:  FI_SUCCESS                          JAJ:09/04/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_next (struct FIfld_obj  *field,
                  int                count)
{
  static short	first_in_grp = TRUE;
  int		scrl_cnt = 0;
  int		len, status;

  if ( field->FIfield.flags.is_a_col  &&  first_in_grp )
    {
      if ( ( field->FIfield.flags.by_line == 1 )	&&
	    field->FIgadget.form->notification_routine   )
	{

		/******************************/
		/* Notify application of data */
		/******************************/

	  status = _FI_fld_notify ( field, (double) field->FIfield.ar );

	  if ( status != FI_SUCCESS )
	    {
	      return ( status );
	    }
	}

	/**************************************************************/
	/* FIfld_set_num_rows( ) has been called to insure that each  */
	/* column in the MCF has the same number of rows. When	      */
	/* columns are dynamically added, the number of rows can      */
	/* be corrupted. 			GMD 10/3/90	      */
	/**************************************************************/

      FIfld_set_num_rows ( (Form) field->FIgadget.form,
				field->FIgadget.group->FIgadget.label,
				field->FIfield.buffer_size );

      first_in_grp = FALSE;

      _FI_grp_pass_on_id_int_always (
			(struct FIgadget_obj *) field->FIgadget.group,
			_FI_fld_next, count, 0 );

      first_in_grp = TRUE;
    }
  else
    {
      if ( field->FIfield.flags.is_a_col == 0 )
	{
	  if (	( field->FIfield.flags.by_line == 1 )		&&
		  field->FIgadget.form->notification_routine 	 )
	    {
	      status = _FI_fld_notify ( field, (double)
						field->FIfield.ar);

	      if ( status != FI_SUCCESS )
		{
		  return ( status );
		}
	    }
	}

      while ( count-- )
	{
	  if ( ( field->FIfield.ar + 1 ) < field->FIfield.buffer_size )
	    {
	      field->FIfield.ar++;

	      if ( field->FIfield.buffer[field->FIfield.ar].line )
		{
			/** <pds-12/08/89 Changed from strlen	**/
			/** <pds-2/15/90 Added 'font_type'	**/

		  len = FI_strlen (
			  (char *)field->FIfield.buffer[field->FIfield.ar].line,
			  field->FIgadget.font_type );
		}
	      else
		{
		  len = 0;
		}

	      if ( field->FIfield.ac > len )
		{
		  field->FIfield.ac = len;
		}

	      if ( ( field->FIfield.ar - field->FIfield.roff ) >=
						field->FIfield.nvr )
		{
		  scrl_cnt++;
		}
	    }
	  else if ( field->FIfield.ar + 1 == field->FIfield.buffer_size)
	    {
	      status = _FI_fld_eol ( field );

	      if ( status != FI_SUCCESS )
		{
		  return ( status );
		}

	      scrl_cnt = 0;
	    }
	}

      if ( scrl_cnt )
	{
	  _FI_fld_scrl_next ( field, scrl_cnt );

	  _FI_fld_set_vscrl ( field );
	}

      if ( field->FIfield.ac < field->FIfield.coff )
	{
	  _FI_fld_scrl_back ( field,
			field->FIfield.coff - field->FIfield.ac );
	}
    }
  return ( FI_SUCCESS );
}


/*********************************************************************/
/***  _FI_fld_previous:   changed from "void" to "int"             ***/
/***  Returns:  FI_SUCCESS                          JAJ:09/04/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_previous (struct FIfld_obj  *field,
                      int                count)
{
  static short	first_in_grp = TRUE;
  int		scrl_cnt = 0;
  int		len, status;

  if ( field->FIfield.flags.is_a_col  &&  first_in_grp  )
    {
      if ( ( field->FIfield.flags.by_line == 1 )		 &&
	     field->FIgadget.form->notification_routine 	  )
	{
		/******************************/
		/* Notify application of data */
		/******************************/

	  status = _FI_fld_notify ( field, (double) field->FIfield.ar );

	  if ( status != FI_SUCCESS )
	    {
	      return ( status );
	    }
	}

      first_in_grp = FALSE;

      _FI_grp_pass_on_id_int_always (
			(struct FIgadget_obj *) field->FIgadget.group,
			_FI_fld_previous, count, 0 );

      first_in_grp = TRUE;
    }
  else
    {
      if ( field->FIfield.flags.is_a_col == 0 )
	{
	  if ( ( field->FIfield.flags.by_line == 1 )		&&
		 field->FIgadget.form->notification_routine 	 )
	    {
	      status = _FI_fld_notify ( field,
					(double) field->FIfield.ar );

	      if ( status != FI_SUCCESS )
		{
		  return ( status );
		}
	    }
	}

      while ( count--)
	{
	  if ( field->FIfield.ar )
	    {
	      field->FIfield.ar--;

	      if ( field->FIfield.buffer[field->FIfield.ar].line )
		{
			/** <pds-12/08/89> Changed from strlen() **/
			/** <pds-2/15/90> Added 'font_type'	 **/

		  len = FI_strlen (
			 (char *)field->FIfield.buffer[field->FIfield.ar].line,
			 field->FIgadget.font_type );
		}
	      else
		{
		  len = 0;
		}

	      if ( field->FIfield.ac > len )
		{
		  field->FIfield.ac = len;
		}

	     if ( field->FIfield.ar < field->FIfield.roff )
		{
		  scrl_cnt++;
		}
	    }
	  else if ( field->FIfield.ar == 0 )
	    {
	      _FI_fld_bol ( field );
	      scrl_cnt = 0;
	    }
	}

      if ( scrl_cnt )
	{
	  _FI_fld_scrl_previous ( field, scrl_cnt );
	  _FI_fld_set_vscrl ( field );
	}

      if ( field->FIfield.ac < field->FIfield.coff )
	{
	  _FI_fld_scrl_back ( field,
			      field->FIfield.coff - field->FIfield.ac );
	}

    }

  return ( FI_SUCCESS );
}


/*********************************************************************/
/***  _FI_fld_forward:   changed from "void" to "int"              ***/
/***  Returns:  FI_SUCCESS                          JAJ:09/04/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_forward (struct FIfld_obj  *field,
                     int                count)
{
  int	scrl_cnt = 0;
  int	len, status;

  while ( count--)
    {
	/*** <pds-12/08/89> Changed from strlen()	***/
	/*** <pds-2/15/90> Added 'font_type'		***/

      if ( field->FIfield.buffer[field->FIfield.ar].line )
	{
	  len =
	      FI_strlen ( (char *)field->FIfield.buffer[field->FIfield.ar].line,
					 field->FIgadget.font_type );
	}
      else
	{
	  len = 0;
	}


     /*****************************************************************/
     /* Need to add a check to see if no horizontal scrolling is set. */
     /* If this is the case, and the line is full of characters, and  */
     /* the cursor is currently over the last character in the line,  */
     /* then scroll to the next line. 		GMD 1/3/91	      */
     /*****************************************************************/

      if ( ( ( field->FIfield.flags.lrs == 0 )		     &&
	     ( field->FIfield.ac < len )		     &&
	     ( field->FIfield.ac != field->FIfield.nvc - 1 )  )	     ||
	   ( ( field->FIfield.flags.lrs == 1 )		     &&
	     ( field->FIfield.ac < len )		      )	      )
	{
	  field->FIfield.ac++;
	  if ( field->FIfield.ac - field->FIfield.coff >=
						field->FIfield.nvc )
	    {
			scrl_cnt++;
	    }
	}
      else if ( field->FIfield.ar + 1 < field->FIfield.buffer_size )
	{
	  _FI_fld_bol ( field );

	  status = _FI_fld_next ( field, 1 );
	  if ( status != FI_SUCCESS )
	    {
	      return ( status );
	    }

	  scrl_cnt = 0;
	}
    }

  if ( scrl_cnt )
    {
      _FI_fld_scrl_forward ( field, scrl_cnt );
    }

  return ( FI_SUCCESS );
}


/*********************************************************************/
/***  _FI_fld_back:   changed from "void" to "int"                 ***/
/***  Returns:  FI_SUCCESS                          JAJ:09/04/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_back (struct FIfld_obj *field,
                  int               count)
{
  int scrl_cnt = 0;
  int status;

  while ( count--)
    {
      if ( field->FIfield.ac)
	{
	  field->FIfield.ac--;

	  if ( field->FIfield.ac < field->FIfield.coff )
	    {
	      scrl_cnt++;
	    }
	}
      else if ( field->FIfield.ar )
	{
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

	  scrl_cnt = 0;
	}
    }

  if ( scrl_cnt )
    {
      _FI_fld_scrl_back ( field, scrl_cnt );
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

void _FI_fld_bol (struct FIfld_obj *field)
{
  field->FIfield.ac = 0;

  if ( field->FIfield.coff )
    {
      field->FIfield.coff = 0;

      _FI_fld_refresh_data ( field, XWINDOW( field ));
    }
}


/*********************************************************************/
/***  _FI_fld_eol:   changed from "void" to "int"                  ***/
/***  Returns:  FI_SUCCESS                          JAJ:09/05/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_eol (struct FIfld_obj *field)
{
  int count;
  int status = FI_SUCCESS;

	/*** <pds-12/08/89> Changed from strlen()	***/
	/*** <pds-2/15/90> Added 'font_type'		***/

  count = FI_strlen ( (char *)field->FIfield.buffer[field->FIfield.ar].line,
			field->FIgadget.font_type ) - field->FIfield.ac;

  if (  ( field->FIfield.flags.lrs == 0 )	&&
	( count >= field->FIfield.nvc   )	 )
    {
      count = field->FIfield.nvc - 1;
    }

  if ( count > 0 )
    {
      status = _FI_fld_forward ( field, count );
    }
  else if ( count < 0 )
    {
      status = _FI_fld_back ( field, -count );
    }

  return ( status );
}

