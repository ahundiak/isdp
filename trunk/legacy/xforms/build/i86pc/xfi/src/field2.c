#include "FImin.h"

#include <stdio.h>
#include <ctype.h>

#include "FEI.h"
#include "FIseq.h"
#include "FIscroll.h"
#include "FIbtn.h"
#include "FImcf.h"
#include "FIfield.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/*********************************************************************/
/***  _FI_fld_notify:   changed from "void" to "int"  JAJ:08/31/90 ***/
/***  Returns:  FI_SUCCESS                                         ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_notify (struct FIfld_obj  *field,
                    double             value)
{
  struct FIform_obj *form = field->FIgadget.form;
  int label, status;

  if ( form->notification_routine )
    {
      if ( field->FIfield.flags.is_a_col )
	{
	  label = field->FIgadget.group->FIgadget.label;
	}
      else
	{
	  label = field->FIgadget.label;
	}

					/*** JAJ:01/20/92 ***/
      _FI_notification_type = FI_COMPLETION_NOTIFICATION;


	/***************************************************/
	/**** RECORD the notification before DOING it   ****/
	/***************************************************/

      if ( _FI_record_notification_routine )
	{
	  _FI_record_notification_routine (
				field->FIgadget.form->form_label, label,
				value, field->FIgadget.form );
	}

      form->notification_routine ( field->FIgadget.form->form_label,
				label, value, field->FIgadget.form );

	/*****************************************************/
	/**** make sure form and/or gadget were not       ****/
	/**** deleted by the form's notification routine  ****/
	/*****************************************************/

      status = FIg_is_valid ( (Form)form, label );
      if ( status != FI_SUCCESS )
        {
	  return ( status );
        }
    }

  return ( FI_SUCCESS );
}

/*====================================================================*/

void _FI_fld_hilite (struct FIfld_obj *field)
{
  struct FIfld_obj  *list_id  = field->FIfield.list_id;
  struct FIscrl_obj *vscrl_id = field->FIfield.vscrl_id;
  int	xx;

  if ( IT_IS_DISPLAYABLE ( field ) )
    {
       if ( vscrl_id && field->FIfield.flags.draw_vscrl )
         {
           _FI_g_hilite ( (struct FIgadget_obj *)vscrl_id );
         }

       if ( list_id )
         {
           _FI_g_hilite ( (struct FIgadget_obj *)list_id );
         }

       if (( field->FIfield.flags.draw_hscrl ) &&
           ( field->FIfield.hscrl))
         {
           _FI_g_hilite ( (struct FIgadget_obj *)field->FIfield.hscrl[0] );
           _FI_g_hilite ( (struct FIgadget_obj *)field->FIfield.hscrl[1] );
	}
    }
  else
    {
      if ( vscrl_id && field->FIfield.flags.draw_vscrl )
	{
	  vscrl_id->FIgadget.attr_mask |= FI_HILITED;
          vscrl_id->FIscroll.puck->FIgadget.attr_mask |= FI_HILITED;

          for ( xx = 0; xx < 4; xx++ )
	    {
              vscrl_id->FIscroll.btns[xx]->
				      FIgadget.attr_mask |= FI_HILITED;
	    }
         }

      if ( list_id )
	{
          list_id->FIgadget.attr_mask |= FI_HILITED; 

          if ( list_id->FIfield.vscrl_id && 
                list_id->FIfield.flags.draw_vscrl )
	    {
              list_id->FIfield.vscrl_id->FIgadget.attr_mask |= FI_HILITED;
              for ( xx = 0; xx < 4; xx++ )
		{
		  list_id->FIfield.vscrl_id->FIscroll.btns[xx]->
				      FIgadget.attr_mask |= FI_HILITED;
		}
            }

	  if (( list_id->FIfield.flags.draw_hscrl ) &&
              ( list_id->FIfield.hscrl ))
	    {
              list_id->FIfield.hscrl[0]->FIgadget.attr_mask |= FI_HILITED; 
              list_id->FIfield.hscrl[1]->FIgadget.attr_mask |= FI_HILITED; 
            }
	}

      if (( field->FIfield.flags.draw_hscrl ) &&
          ( field->FIfield.hscrl ))
	{
          field->FIfield.hscrl[0]->FIgadget.attr_mask |= FI_HILITED; 
          field->FIfield.hscrl[1]->FIgadget.attr_mask |= FI_HILITED; 
	}
    }
}


/*====================================================================*/

void _FI_fld_unhilite (struct FIfld_obj *field)
{
  struct FIfld_obj  *list_id  = field->FIfield.list_id;
  struct FIscrl_obj *vscrl_id = field->FIfield.vscrl_id;
  int	xx;

  if ( IT_IS_DISPLAYABLE ( field ) )
    {
      if (  vscrl_id  &&  field->FIfield.flags.draw_vscrl )
	{
          _FI_g_unhilite ( (struct FIgadget_obj *)vscrl_id );
	}

      if ( list_id )
	{
          _FI_g_unhilite ( (struct FIgadget_obj *)list_id );
	}

      if (( field->FIfield.flags.draw_hscrl ) &&
          ( field->FIfield.hscrl ))
	{
          _FI_g_unhilite ( (struct FIgadget_obj *)field->FIfield.hscrl[0] );
          _FI_g_unhilite ( (struct FIgadget_obj *)field->FIfield.hscrl[1] );
	}
    }
  else
    {
      if ( vscrl_id && field->FIfield.flags.draw_vscrl )
	{
	  vscrl_id->FIgadget.attr_mask &= ~FI_HILITED; 
          vscrl_id->FIscroll.puck->FIgadget.attr_mask &= ~FI_HILITED;

          for ( xx = 0; xx < 4; xx++ )
	    {
              vscrl_id->FIscroll.btns[xx]->
				    FIgadget.attr_mask &= ~FI_HILITED;
	    }
	}

      if ( list_id )
	{
          list_id->FIgadget.attr_mask &= ~FI_HILITED; 

          if ( list_id->FIfield.vscrl_id && 
                list_id->FIfield.flags.draw_vscrl )
	    {
	      list_id->FIfield.vscrl_id->FIgadget.attr_mask &= ~FI_HILITED;
              for ( xx = 0; xx < 4; xx++ )
		{
                  list_id->FIfield.vscrl_id->FIscroll.btns[xx]->
				    FIgadget.attr_mask &= ~FI_HILITED;
		}
            }

	  if (( list_id->FIfield.flags.draw_hscrl ) &&
              ( list_id->FIfield.hscrl ))
	    {
              list_id->FIfield.hscrl[0]->FIgadget.attr_mask &= ~FI_HILITED; 
              list_id->FIfield.hscrl[1]->FIgadget.attr_mask &= ~FI_HILITED; 
	    }
	}

      if (( field->FIfield.flags.draw_hscrl ) &&
          ( field->FIfield.hscrl ))
	{
          field->FIfield.hscrl[0]->FIgadget.attr_mask &= ~FI_HILITED; 
          field->FIfield.hscrl[1]->FIgadget.attr_mask &= ~FI_HILITED; 
	}
    }
}


/*====================================================================*/

void _FI_fld_disable (struct FIfld_obj *field)
{
  struct FIfld_obj  *list_id  = field->FIfield.list_id;
  struct FIscrl_obj *vscrl_id = field->FIfield.vscrl_id;
  int xx;

  if ( IT_IS_DISPLAYABLE( field ) )
    {
      if ( vscrl_id  &&  field->FIfield.flags.draw_vscrl )
	{
          _FI_g_disable ( (struct FIgadget_obj *)vscrl_id );
	}

      if ( list_id  )
      {
         if ( IT_IS_DISPLAYABLE( list_id ))
         {
           _FI_g_disable ( (struct FIgadget_obj *)list_id );
         }
         else   /* popup associated list */
         {
            list_id->FIgadget.attr_mask |= FI_NOT_ENABLED;
         }
      }

      if (  field->FIfield.flags.draw_hscrl  &&
            field->FIfield.hscrl &&
            ( field->FIfield.flags.is_a_col == 0 ) )
	{
          _FI_g_disable ( (struct FIgadget_obj *)field->FIfield.hscrl[0] );
          _FI_g_disable ( (struct FIgadget_obj *)field->FIfield.hscrl[1] );
	}
    }
  else
    {
      if ( vscrl_id && field->FIfield.flags.draw_vscrl )
	{
          vscrl_id->FIgadget.attr_mask |= FI_NOT_ENABLED;
          vscrl_id->FIscroll.puck->FIgadget.attr_mask |= FI_NOT_ENABLED;

	  for ( xx = 0; xx < 4; xx++ )
	    {
              vscrl_id->FIscroll.btns[xx]->
				FIgadget.attr_mask |= FI_NOT_ENABLED;
	    }
	}

      if ( list_id )
	{
          list_id->FIgadget.attr_mask |= FI_NOT_ENABLED;

          if ( list_id->FIfield.vscrl_id && 
                list_id->FIfield.flags.draw_vscrl )
	    {
	      list_id->FIfield.vscrl_id->FIgadget.attr_mask |= FI_NOT_ENABLED;
              for ( xx = 0; xx < 4; xx++ )
		{
                  list_id->FIfield.vscrl_id->FIscroll.btns[xx]->
				FIgadget.attr_mask |= FI_NOT_ENABLED;
		}
	    }

           if (( list_id->FIfield.flags.draw_hscrl ) &&
               ( list_id->FIfield.hscrl ))
           {
              list_id->FIfield.hscrl[0]->FIgadget.attr_mask |= FI_NOT_ENABLED; 
              list_id->FIfield.hscrl[1]->FIgadget.attr_mask |= FI_NOT_ENABLED; 
           }
	}

       if (( field->FIfield.flags.draw_hscrl ) &&
           ( field->FIfield.hscrl ))
         {
           field->FIfield.hscrl[0]->FIgadget.attr_mask |= FI_NOT_ENABLED; 
           field->FIfield.hscrl[1]->FIgadget.attr_mask |= FI_NOT_ENABLED; 
         }
    }
}

/*====================================================================*/

void _FI_fld_enable (struct FIfld_obj *field)
{
  struct FIfld_obj  *list_id  = field->FIfield.list_id;
  struct FIscrl_obj *vscrl_id = field->FIfield.vscrl_id;
  int xx;

  if ( IT_IS_DISPLAYABLE( field ) )
    {
      if ( vscrl_id  &&  field->FIfield.flags.draw_vscrl )
	{
          _FI_g_enable ( (struct FIgadget_obj *)vscrl_id );
	}

      if ( list_id )
      {
        if (IT_IS_DISPLAYABLE ( list_id ) )
        {
          _FI_g_enable ( (struct FIgadget_obj *)list_id );
        }
        else
        {
	      list_id->FIgadget.attr_mask &= ~FI_NOT_ENABLED;

		/* Added this stuff per MAP-2 request   GMD 10/21/91  */

	      if ( list_id->FIfield.vscrl_id )
		{
		  list_id->FIfield.vscrl_id->FIgadget.attr_mask &=
                                                        ~FI_NOT_ENABLED;

                  /* Force these to be set as well    GMD 2/9/92 */

                  list_id->FIfield.vscrl_id->FIscroll.btns[0]->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
                  list_id->FIfield.vscrl_id->FIscroll.btns[1]->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
                  list_id->FIfield.vscrl_id->FIscroll.btns[2]->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
                  list_id->FIfield.vscrl_id->FIscroll.btns[3]->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
                  list_id->FIfield.vscrl_id->FIscroll.puck->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
		}

	      if (list_id->FIfield.flags.draw_hscrl)
		{
		  list_id->FIfield.hscrl[0]->FIgadget.attr_mask &=
                                                        ~FI_NOT_ENABLED;
		  list_id->FIfield.hscrl[1]->FIgadget.attr_mask &=
                                                        ~FI_NOT_ENABLED;
		}
        }
      }

      if (( field->FIfield.flags.draw_hscrl ) &&
          ( field->FIfield.hscrl ))
      {
          _FI_g_enable ( (struct FIgadget_obj *)field->FIfield.hscrl[0] );
          _FI_g_enable ( (struct FIgadget_obj *)field->FIfield.hscrl[1] );
      }
    }
    else
    {
      if ( vscrl_id && field->FIfield.flags.draw_vscrl )
	{
          vscrl_id->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
         vscrl_id->FIscroll.puck->FIgadget.attr_mask &= ~FI_NOT_ENABLED;

	  for ( xx = 0; xx < 4; xx++ )
	    {
              vscrl_id->FIscroll.btns[xx]->
				FIgadget.attr_mask &= ~FI_NOT_ENABLED;
	    }
	}

      if ( list_id )
	{
          list_id->FIgadget.attr_mask &= ~FI_NOT_ENABLED;

          if ( list_id->FIfield.vscrl_id )
	    {
              list_id->FIfield.vscrl_id->FIgadget.attr_mask &=
                                                        ~FI_NOT_ENABLED;

              /* Force these to be set as well    GMD 2/9/92 */

              list_id->FIfield.vscrl_id->FIscroll.btns[0]->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
              list_id->FIfield.vscrl_id->FIscroll.btns[1]->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
              list_id->FIfield.vscrl_id->FIscroll.btns[2]->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
              list_id->FIfield.vscrl_id->FIscroll.btns[3]->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
              list_id->FIfield.vscrl_id->FIscroll.puck->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
	    }

          if ( list_id->FIfield.flags.draw_hscrl )
	    {
              list_id->FIfield.hscrl[0]->FIgadget.attr_mask &=
                                                        ~FI_NOT_ENABLED;
              list_id->FIfield.hscrl[1]->FIgadget.attr_mask &= 
                                                        ~FI_NOT_ENABLED;
	    }
	}

       if (( field->FIfield.flags.draw_hscrl ) &&
           ( field->FIfield.hscrl ))
         {
           field->FIfield.hscrl[0]->FIgadget.attr_mask &= ~FI_NOT_ENABLED; 
           field->FIfield.hscrl[1]->FIgadget.attr_mask &= ~FI_NOT_ENABLED; 
         }
    }
}


/*********************************************************************/
/***  _FI_fld_call_notify:   changed from "void" to "int"          ***/
/***  Returns:  FI_SUCCESS                          JAJ:08/31/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_call_notify (struct FIfld_obj  *field,
                         int               *complete,
                         double             value)
{
  int status;

  if ( field->FIfield.flags.is_a_col )
    {
      *complete = TRUE;
    }
  else
    {
      *complete = FALSE;

      if ( ! field->FIfield.flags.is_a_list )
	{
	  status = _FI_fld_notify ( field, value );

	    /*** if the field/form was deleted, then return ***/
	  if ( status != FI_SUCCESS )
	    {
	      return ( status );
	    }

	    /* Pass data to gadget if sequenced */

	  _FI_g_pass_data ( (struct FIgadget_obj *)field );
	}
      else if ( field->FIfield.buffer  				&&
		( field->FIfield.buffer[ (int) value].sel & 1)	 )
	{
				/****************/
     				/* Notify field */
				/****************/
	  int len, fld_value;
	  Window window;
	  struct FIfld_obj *parent_fld;


	  window = XWINDOW( field );

	  parent_fld = (struct FIfld_obj *)
				field->FIgadget.user_pointer;

	  fld_value = parent_fld->FIfield.ar;

	  if ( parent_fld->FIfield.buffer_size == 0 )
	    {
	      _FI_fld_set_buffer ( parent_fld, 1, 1 );
	    }

	  len = -1;
	  if ( parent_fld->FIfield.nc )
	    {
			/** Guarantee to copy 16 bit text **/

	      len = FI_move_index (
			    (char *)field->FIfield.buffer[ (int) value].line,
			    0, parent_fld->FIfield.nc,
			    field->FIgadget.font_type );
	    }

	  if ( len < 0 )
	    {
	      len = strlen ( (char *)field->FIfield.buffer[ (int) value].line );
	    }

	  _FI_fld_add_to_line ( parent_fld, fld_value, len + 2 );

#if defined(hp9000)
	  strncpy ( (char *) parent_fld->FIfield.buffer[fld_value].line,
		    (char *) field->FIfield.buffer[ (int) value].line, len + 1 );
#else
	  strncpy ( parent_fld->FIfield.buffer[fld_value].line,
		    field->FIfield.buffer[ (int) value].line, len + 1 );
#endif

	  parent_fld->FIfield.buffer[fld_value].line[len] = 
												(unsigned char) NULL;
	  _FI_fld_refresh_row ( parent_fld, window, fld_value );

		/*********************************/
		/* This guy could be the culprit */
		/*********************************/
				/*** WTF ?  -- JAJ:08/27/91 ***/

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
          if (!_FI_dont_flush)
            XFlush ( _FI_display );

	  if ( field->FIfield.mode == FI_MULTI_SELECT )
	    {
	      if ( ( parent_fld->FIfield.nr == 0 )		  ||
		   ( parent_fld->FIfield.ar <
				( parent_fld->FIfield.nr - 1))	   )
		{
		  if ( parent_fld->FIfield.buffer_size ==
					( parent_fld->FIfield.ar + 1) )
		    {
		      _FI_fld_set_buffer ( parent_fld,
				parent_fld->FIfield.buffer_size + 1, 1);

		      _FI_fld_add_to_line ( parent_fld, fld_value + 1,
								1);

		      parent_fld->FIfield.buffer[fld_value + 1].line[0]= 0;
		    }

			/**************************/
			/* Need to scroll forward */
			/**************************/

		    _FI_fld_next ( parent_fld, 1 );  /* GMD 11/1/90 */

              	    /*****************************
			parent_fld->FIfield.ar++;
              	    ****************************/
		}
	    }

	  if ( parent_fld->FIgadget.form->notification_routine  &&
	 (! ( parent_fld->FIgadget.attr_mask & FI_NO_COMPLETE_NOTIFY )))
	    {
	      status = _FI_fld_notify ( parent_fld, (double) fld_value );

	      if ( status != FI_SUCCESS )
		{
		  return ( status );
		}
	    }

	        /*** Pass data to gadget if data linked		***/
		/*** <pds-2/1/90> Parent field should pass	***/
		/*** its data, not the list.			***/

	  _FI_g_pass_data ( (struct FIgadget_obj *)parent_fld );
	}
    }

  return ( FI_SUCCESS );
}


/*********************************************************************/
/***  _FI_fld_toggle_select_flag:   changed from "void" to "int"   ***/
/***  Returns:  FI_SUCCESS                          JAJ:09/04/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_toggle_select_flag (struct FIfld_obj  *field,
                                Window             window,
                                int                xpos,
                                int                ypos,
                                int               *complete,
                                double            *value)
{
  struct FIfld_obj *parent_fld;
  int		    status;

  parent_fld = (struct FIfld_obj *) field->FIgadget.user_pointer;

  if ( field->FIfield.buffer )
    {
      if ( field->FIfield.mode == FI_SINGLE_SELECT )
	{
	  if ( field->FIfield.flags.roll_thru )
	    {
	      _FI_fld_scrl_next ( field, 1 );
	    }
	  else
	    {
		/*** <pds-2/28/90> Only unselect the rows	 ***/
		/*** which are single select in the column.	 ***/
		/*** ( If it is not a column, do regular stuff.) ***/
		/*** This may seem like a KLUDGE, but it keeps   ***/
		/*** with the theme of field/MCF code.		 ***/

	      if ( field->FIfield.flags.is_a_col )
		{
		  struct FImcf_obj *mcf;
		  struct FIfld_obj *column;
		  int col;

		  mcf = (struct FImcf_obj *) field->FIgadget.group;

		  for ( col = 0; col < (int)mcf->FImcf.ncol; col++ )
		    {
		      column = (struct FIfld_obj *)
					mcf->FIgroup.gadgets[col];

		      if ( ( column->FIfield.mode == FI_SINGLE_SELECT) &&
			   ( column->FIfield.prev_sel > -1)	       )
			{
			  column->FIfield.flags.is_a_col = 0;

			  _FI_fld_un_select_row ( column, window,
					column->FIfield.prev_sel );

			  column->FIfield.flags.is_a_col = 1;
			}
		    }
		}
			/*** Regular stuff ***/
	      else if ( field->FIfield.prev_sel > -1 )
		{
		  _FI_fld_un_select_row ( field, window,
					field->FIfield.prev_sel );
		}

	      _FI_fld_adjust_row_col ( field, xpos, ypos );

	      if ( field->FIfield.prev_sel != field->FIfield.ar )
		{
		  _FI_fld_select_row ( field, window,
						field->FIfield.ar );
		}
	      else
		{
		  if ( field->FIfield.prev_sel > -1 ) /* JAJ 5/21/90 */
		    {
		      _FI_fld_un_select_row ( field, window,
					field->FIfield.prev_sel );
		    }
		  field->FIfield.prev_sel = -1;
		}
	    }
	} /*** field->FIfield.mode == FI_SINGLE_SELECT  ***/
      else	/* multi select */
	{
	  _FI_fld_adjust_row_col ( field, xpos, ypos );

	  if ( field->FIfield.buffer[field->FIfield.ar].sel & 1 )
	    {
	      _FI_fld_un_select_row ( field, window, field->FIfield.ar);
	      field->FIfield.prev_sel = -1;
	    }
	  else
	    {
	      _FI_fld_select_row ( field, window, field->FIfield.ar );
	    }
	}

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
      if (!_FI_dont_flush)
        XFlush ( _FI_display );

	/****************************************/
	/* Take down the assoc list if it is up */
	/****************************************/

      if (  _FI_list_up				&&
	    field->FIfield.flags.is_a_list	&&
	    parent_fld->FIfield.flags.dismiss    )
	{
	  int		fld_value;
	  struct FIfld_obj *loc_parent_fld;

	  loc_parent_fld = (struct FIfld_obj *)
					field->FIgadget.user_pointer;

	  _FI_fld_process_displayed_list ( field );

	  fld_value = loc_parent_fld->FIfield.ar;

	  FIfld_set_text ( (Form) loc_parent_fld->FIgadget.form,
			loc_parent_fld->FIgadget.label,
			fld_value, 0,
		( char *) field->FIfield.buffer[field->FIfield.ar].line,
			0 );

        /**************************************************************/
        /* If the loc_parent_fld field was an FI_REVIEW field, then   */
        /* it will never send a notification.  So, a notification     */
        /* must be sent here if you expect to get one. GMD 1/20/90    */
        /**************************************************************/

	  if ( loc_parent_fld->FIfield.mode == FI_REVIEW )
	    {
	      *value = (double) loc_parent_fld->FIfield.ar;

	      if ( loc_parent_fld->FIfield.flags.by_line	||
		   ! ( loc_parent_fld->FIgadget.attr_mask &
				FI_NO_COMPLETE_NOTIFY )		 )
		{
		  status = _FI_fld_call_notify ( loc_parent_fld,
						complete, *value );

                  /* GMD 1/27/92   Removed check that only bailed out */
                  /*               if there was an error code.        */

		  return ( status );
		}
	    }
            else
	    {
	      /* User complained of getting double notifications when */
	      /* a single select and dismiss popup list had a         */
	      /* selection made. This step insures that only the      */
	      /* Notify on completion will be sent. GMD 1/10/92       */

              return (FI_SUCCESS);
	    }
	}

	/* Notify application of data */

      *value = (double) field->FIfield.ar;

      if ( field->FIfield.flags.by_line  			     ||
	    (! ( field->FIgadget.attr_mask & FI_NO_COMPLETE_NOTIFY )) )
	{
	  status = _FI_fld_call_notify ( field, complete, *value );

	  if ( status != FI_SUCCESS )
	    {
	      return ( status );
	    }
	}
    }
  return ( FI_SUCCESS );
}


/*====================================================================*/

_FI_fld_process_displayed_list (struct FIfld_obj *list)
{
  int xlo = list->FIgadget.xlo - 2;
  int ylo = list->FIgadget.ylo - 2;
  int xhi = list->FIgadget.xhi + 2;
  int yhi = list->FIgadget.yhi + 4;


  list->FIgadget.attr_mask |= FI_NOT_DISPLAYED;
  list->FIgadget.displayed = 0;

  if ( list->FIfield.vscrl_id && list->FIfield.flags.draw_vscrl )
    {
      _FI_g_erase ( (struct FIgadget_obj *) list->FIfield.vscrl_id );
      xhi = list->FIfield.vscrl_id->FIgadget.xhi + 2;
    }

  if ( list->FIfield.hscrl && list->FIfield.flags.draw_hscrl )
    {
      _FI_g_erase ( (struct FIgadget_obj *) list->FIfield.hscrl[0] );
      _FI_g_erase ( (struct FIgadget_obj *) list->FIfield.hscrl[1] );
      yhi = list->FIfield.hscrl[0]->FIgadget.yhi + 2;
    }

  FIf_paint_area ( (Form) list->FIgadget.form, xlo, ylo, xhi, yhi );

  _FI_list_up = FALSE;

  /**************************************************************/
  /* This patch will insure that no item will remain selected	*/
  /* for a popup associated list once that list has been	*/
  /* taken down.						*/
  /**************************************************************/

  if ( list->FIfield.flags.dismiss == 1 )
    {
      list->FIfield.prev_sel = -1;
    }
}


/******************************************************************/
/***   _FI_fld_adjust_row_col ( ) sets the active row and	***/
/***   active character based on the ( x, y ) position.		***/
/******************************************************************/

void _FI_fld_adjust_row_col (struct FIfld_obj  *field,
                             int                xpos,
                             int                ypos)
{
  int		len = 0;
  int		col = 0;
  int		row = 0;
  int		r_index = 0;
  int		ht, wd, ls, xx;
  int		index = -1;
  int		xlow = field->FIgadget.xlo;
  struct FImcf_obj *mcfield;

	/**************************************************/
	/*** Convert x,y coordinates to row and column	***/
	/*** within the display area.			***/
	/**************************************************/

  if ( field->FIfield.line_height )
    {
      row = (ypos - (int) field->FIgadget.ylo ) /
				(int) field->FIfield.line_height;

      if ( row >= field->FIfield.nvr )
	{
	  row = field->FIfield.nvr - 1;
	}

      r_index = row + (int) field->FIfield.roff;
    }

	/*** <pds-12/11/89 - Find the character based	***/
	/*** on the width of each character.		***/

  if ( ( r_index < field->FIfield.buffer_size ) &&
	field->FIfield.buffer[r_index].line 	 )
    {
      index = FI_move_index ( (char *)field->FIfield.buffer[r_index].line, 0,
		field->FIfield.coff, field->FIgadget.font_type );
    }

  if ( ( index > -1 )					&&
	field->FIfield.buffer_size			&&
	field->FIfield.buffer[r_index].line		&&
	field->FIfield.buffer[r_index].line[index]	 )
    {
      while ( col < field->FIfield.nvc - 1 )
	{
/***** sml:10-05-92	calling FI_calc_text has round trip call when
					using X server fonts; just used gadget members
					font_height and font_width and field member
					line_spacing

		  FI_calc_text ( field->FIgadget.font_id,
			(char *) & ( field->FIfield.buffer[r_index].line[index]),
			1, &ht, &wd, &ls, field->FIgadget.font_type );

************/

	  ht = field->FIgadget.font_height;
	  wd = field->FIgadget.font_width;
	  ls = field->FIfield.line_height;

	  if ( field->FIfield.buffer[r_index].line[index]== '\0' )
	    {
	      break;
	    }

	  if ( sbitset( field->FIfield.buffer[r_index].line[index]) &&
	    ( field->FIgadget.font_type == FI_FS_7_OR_16_BIT_FONT_TYPE ))
	    {
	      index += 2;
	    }
	  else
	    {
	      index++;
	    }

	  xlow += wd;

	  if ( xlow < xpos )
	    {
	      col++;
	    }
	  else
	    {
	      break;
	    }
	}
    }

  /* Hebrew 8/2/90 */

  if ( field->FIfield.flags.right_to_left )
    {
      int xint;

	  /*sml:08-11-92 use widest characters here for _FI_s_rep() */
/** not used
 	  char widest_str[10];
	  int status;
**/
/***** sml:10-05-92	calling FI_calc_text has round trip call when
					using X server fonts; just used gadget members
					font_height and font_width and field member
					line_spacing

	  status = _FI_widest_char(field->FIgadget.font_type, widest_str);
      FI_calc_text ( field->FIgadget.font_id, //"m"// widest_str, 1,
			&ht, &wd, &ls, field->FIgadget.font_type );

************/

	  ht = field->FIgadget.font_height;
	  wd = field->FIgadget.font_width;
	  ls = field->FIfield.line_height;

      xint = xpos - (int) field->FIgadget.xlo;
      col = field->FIfield.nvc - 1 - ( xint / wd );
    }

	/*************************/
	/* Create line if needed */
	/*************************/

  if ( field->FIfield.buffer_size == 0 )
    {
      _FI_fld_set_buffer ( field, 1, 1 );

      if ( field->FIfield.flags.is_a_col == 0 )
	{
	  _FI_fld_add_to_line ( field, 0, 1 );
	}
      else
	{
	  mcfield = (struct FImcf_obj *) field->FIgadget.group;

	  for ( xx = 0; xx < (int)mcfield->FImcf.ncol; xx++ )
	    {
	      _FI_fld_add_to_line ((struct FIfld_obj *)mcfield->FIgroup.gadgets[xx], 0, 1 );
	    }
	}
    }

	/**************/
	/* adjust row */
	/**************/

  if ( row >= field->FIfield.buffer_size - field->FIfield.roff )
    {
      row = field->FIfield.buffer_size - field->FIfield.roff - 1;
    }

  field->FIfield.ar = row + (int) field->FIfield.roff;

	/*****************/
	/* adjust column */
	/*****************/

  if ( ! field->FIfield.buffer[field->FIfield.ar].line )
    {
      _FI_fld_add_to_line ( field, field->FIfield.ar, 1 );
    }

	/*** Changed from strlen()12/06/89	***/
	/*** <pds-2/15/90> Added 'font_type'	***/

  len = FI_strlen ( (char *) field->FIfield.buffer[field->FIfield.ar].line,
					field->FIgadget.font_type );

  if ( len > col + field->FIfield.coff )
    {
      field->FIfield.ac = col + field->FIfield.coff;
    }
  else
    {
      field->FIfield.ac = len;
      if ( len < field->FIfield.coff )	/* bring into view */
	{
	  field->FIfield.coff = len - 1;
	  _FI_fld_refresh_data ( field, XWINDOW( field ));
	}
    }

	/*****************************************/
	/* set all columns to the new active row */
	/*****************************************/

  if ( field->FIfield.flags.is_a_col )
    {
      _FI_mcf_set_active_row ( (struct FImcf_obj *)field->FIgadget.group, field );
    }
}


/*====================================================================*/
/*  int num_chars;	** character position ( note byte position ) */
/*  int *xpos, *ypos;	** return the x,y coords 		     */

void _FI_fld_get_xy (struct FIfld_obj *field,
                     int               num_chars,
                     int               *xpos,
                     int               *ypos)
{
  int ht, wd, ls;

/***** sml:10-05-92	calling FI_calc_text has round trip call when
					using X server fonts; just used gadget members
					font_height and font_width and field member
					line_spacing

		sml:10-05-92	Maybe not, maybe so
		sml:11-12-92	need to calc_text for 7/16 text mixture
*******/

  if (field->FIgadget.font_type == 2) /* get width of 7/16 char */
  {
	FI_calc_text ( field->FIgadget.font_id,
	(char *) & ( field->FIfield.buffer[field->FIfield.ar].line[
	    FI_move_index (
		(char *) field->FIfield.buffer[field->FIfield.ar].line, 0,
		field->FIfield.coff, field->FIgadget.font_type )]),
	num_chars, &ht, &wd, &ls, field->FIgadget.font_type );

  }
  else
  {
	  /* sml:10-05-92
	     wd is width of string up  to data point; use FI_move_index
		 compute exact character in case of mixture of 7- and
		 16-bit chars
		 Don't do this right now; this temporary solution will
		 break if using mixture of 7- and 16-bit text
	  */
	  wd = field->FIgadget.font_width * num_chars;
		/*		* FI_move_index (
		field->FIfield.buffer[field->FIfield.ar].line, 0,
		field->FIfield.coff, field->FIgadget.font_type); */
  }
	  ht = field->FIgadget.font_height;
	  ls = field->FIfield.line_height;
/**********/

  /* Fix cursor in column zero problem for SUN  */
  /*        GMD 4/5/91                          */

  if ( num_chars == 0 )
    {
      wd = 0;
    }

  *xpos = (int) field->FIgadget.xlo + wd;

  *ypos = (int) field->FIgadget.ylo +
	( ( field->FIfield.ar - field->FIfield.roff) *
				(int) field->FIfield.line_height );
}


/*====================================================================*/
/*  int focus;	      *** X11-5/22/90-When erasing this has no effect */
/*  int block_color;	** cursor color */

void _FI_fld_draw_cursor (struct FIfld_obj  *field,
                          Window             window,
                          int                focus,
                          int                block_color,
                          int                char_color)
{
  int		xpos, ypos, new_x, new_y, wd, ht, ls, index;
  int		Xscreen = XSCREEN( field );
  XGCValues	gc_values;
  unsigned long gc_value_mask;
/** not used
  char widest_str[10];
  int status;
**/
  /* sml-dmb-gmd:10-29-92
	Make sure that this is not a review-only field.
	Otherwise if you try to draw the cursor on a review-only
	field, with no text, and an associated list, a memory
	fault occurs
  */
  if ( field->FIfield.mode == FI_REVIEW )
  {
    return;
  }

  /* Hebrew 7/31/90 */

  if ( field->FIfield.flags.right_to_left )
    {
      if ( field->FIfield.flags.no_echo )
	{
	  index = field->FIfield.nvc - 1;
	}
      else
	{
	  index = ( field->FIfield.nvc - 1) -
			( field->FIfield.ac - field->FIfield.coff);
	}

	  /*sml:08-11-92 use widest characters */
	
/***** sml:10-05-92	calling FI_calc_text has round trip call when
					using X server fonts; just used gadget members
					font_height and font_width and field member
					line_spacing

	  status = _FI_widest_char(field->FIgadget.font_type, widest_str);
      FI_calc_text ( field->FIgadget.font_id, //"m"// widest_str, 1,
			&ht, &wd, &ls, field->FIgadget.font_type );

************/

	  ht = field->FIgadget.font_height;
	  wd = field->FIgadget.font_width;
	  ls = field->FIfield.line_height;

      xpos = (index * wd ) + (int) field->FIgadget.xlo;
      ypos = ( ( field->FIfield.ar - field->FIfield.roff) * ls ) +
					(int) field->FIgadget.ylo;
    }
  else
    {
      if ( field->FIfield.flags.no_echo )
	{
	  index = 0;
	}
      else
	{
	  index = field->FIfield.ac - field->FIfield.coff;
	}

	/********************************/
	/* calculate position of cursor */
	/********************************/

      _FI_fld_get_xy ( field, index, &xpos, &ypos );
    }

	/*****************************/
	/* calculate width of cursor */
	/*****************************/

  index = FI_move_index ( (char *)field->FIfield.buffer[field->FIfield.ar].line,
		0, field->FIfield.ac, field->FIgadget.font_type );

  /* sml:08-13-92 handle empty char case here */

/***** sml:10-05-92	calling FI_calc_text has round trip call when
					using X server fonts; just used gadget members
					font_height and font_width and field member
					line_spacing
******

  if ( field->FIfield.buffer[field->FIfield.ar].line[index] != '\0')
  {
	FI_calc_text ( field->FIgadget.font_id,
	(char *) & ( field->FIfield.buffer[field->FIfield.ar].line[index]),
	1, &ht, &wd, &ls, field->FIgadget.font_type );
  }
  else 
  {
	  status = _FI_widest_char(field->FIgadget.font_type, widest_str);
      FI_calc_text ( field->FIgadget.font_id, widest_str, 1,
			&ht, &wd, &ls, field->FIgadget.font_type );	
  }
************/

  ht = field->FIgadget.font_height;
  wd = field->FIgadget.font_width;
  ls = field->FIfield.line_height;
/************/
	
  if ( wd == 0 )
    {
      wd = field->FIgadget.font_width;
    }

	/***************/
	/* draw cursor */
	/***************/

  gc_value_mask = GCForeground | GCLineWidth;
  gc_values.foreground = FI_translate_color ( Xscreen, block_color );
  gc_values.line_width = 0;

  if ( field->FIfield.flags.required )
    {
      gc_value_mask	   |= GCStipple | GCBackground | GCFillStyle;
      gc_values.background  = FI_translate_color ( Xscreen, FI_WHITE );
      gc_values.stipple	    = _FIpix_required_array [Xscreen];
      gc_values.fill_style  = FillOpaqueStippled;
    }

  XChangeGC ( _FI_display, _FI_gc, gc_value_mask, &gc_values );

  if ( focus )
    {
      XFillRectangle ( _FI_display, window, _FI_gc,
					xpos, ypos, wd, ls );
    }
  else
    {
      XDrawRectangle ( _FI_display, window, _FI_gc,
					xpos, ypos, wd - 1, ls - 1 );
    }

  XSetFillStyle ( _FI_display, _FI_gc, FillSolid );

  if ( ! field->FIfield.buffer[field->FIfield.ar].line )
    {
      _FI_fld_add_to_line ( field, field->FIfield.ar, 1 );

      return;
    }

	/***********************/
	/* redisplay character */
	/***********************/

  if ( (! field->FIfield.flags.no_echo ) && focus )
    {
      int temp_font_height;

      gc_value_mask = GCForeground | GCBackground;
      gc_values.foreground = FI_translate_color (Xscreen, char_color);
      gc_values.background = FI_translate_color (Xscreen, block_color);

      XChangeGC (_FI_display, _FI_gc, gc_value_mask, &gc_values);


      temp_font_height = field->FIgadget.font_height;

	 	/****************************************/
		/* Have to push XFontserver fonts down  */
		/*     GMD 8/30/91                      */
	 	/****************************************/
      if ( field->FIgadget.font_type != 0 )   /* != .snf */
	{
	  temp_font_height += ( field->FIgadget.font_height / 5 );
	}

	/* sml:10-05-92	Make sure that text exists if drawing it */
    if ( field->FIfield.buffer[field->FIfield.ar].line[index] != '\0')
    {
      FI_draw_text ( window, field->FIgadget.font_id,
	    (char *) & ( field->FIfield.buffer[field->FIfield.ar].line[index]),
	    1, xpos, ypos,
	    temp_font_height,
	    &new_x, &new_y, field->FIgadget.font_type);
    }
  }
}


/*====================================================================*/

void _FI_fld_un_select_row (struct FIfld_obj  *field,
                            Window             window,
                            int                row)
{
  struct FImcf_obj *mcf;
  struct FIfld_obj *column;
  int col = 0;

  if ( row < field->FIfield.buffer_size )
    {
	/**************************************************/
	/*** <pds-2/28/90> Handle FI_ROW_SELECT for MCF ***/
	/**************************************************/

      if ( field->FIfield.flags.is_a_col )
	{
	  mcf = (struct FImcf_obj *) field->FIgadget.group;
	  if ( mcf->FImcf.flags.row_select )
	    {
	      for ( col = 0; col < (int)mcf->FImcf.ncol; col++ )
		{
		  column = (struct FIfld_obj *)
					mcf->FIgroup.gadgets[col];

		  if (  ( column->FIfield.mode == FI_SINGLE_SELECT) ||
			( column->FIfield.mode == FI_MULTI_SELECT )   )
		    {
		      column->FIfield.buffer[row].sel &= 0xffff ^ 0x1;
		      _FI_fld_refresh_row ( column, window, row );
		    }
		}
	      col = -1;	/*** flag--already refreshed entire row ***/
	    }
	}

      if ( col != -1 )	/*** regular field or no row select ***/
	{
		/* clear out low order bit */

	  field->FIfield.buffer[row].sel &= 0xffff ^ 0x1;

	  if (  (field->FIfield.mode == FI_SINGLE_SELECT) ||
		(field->FIfield.mode == FI_MULTI_SELECT )  )
	    {
	      _FI_fld_refresh_row ( field, window, row );
	    }
	}
    }
}


/*====================================================================*/

void _FI_fld_select_row (struct FIfld_obj  *field,
                         Window             window,
                         int                row)
{
  struct FImcf_obj *mcf;
  struct FIfld_obj *column;
  int col = 0;


  if ( row < field->FIfield.buffer_size )
    {
	/**************************************************/
	/*** <pds-2/28/90> Handle FI_ROW_SELECT for MCF ***/
	/**************************************************/

      if ( field->FIfield.flags.is_a_col )
	{
	  mcf = (struct FImcf_obj *) field->FIgadget.group;
	  if ( mcf->FImcf.flags.row_select )
	    {
	      for ( col = 0; col < (int)mcf->FImcf.ncol; col++ )
		{
		  column = (struct FIfld_obj *)
					    mcf->FIgroup.gadgets[col];

		  if ( column->FIfield.mode == FI_MULTI_SELECT )
		    {
		      column->FIfield.buffer[row].sel |= 0x0001;
		      column->FIfield.prev_sel = row;
		      _FI_fld_refresh_row ( column, window, row );
		    }
		  else if ( column->FIfield.mode == FI_SINGLE_SELECT )
		    {
		      if ( column->FIfield.prev_sel > -1 )
			{
			  column->FIfield.flags.is_a_col = 0;
			  _FI_fld_un_select_row ( column, window,
					column->FIfield.prev_sel );
			  column->FIfield.flags.is_a_col = 1;
			}
		      column->FIfield.buffer[row].sel |= 0x0001;
		      column->FIfield.prev_sel = row;
		      _FI_fld_refresh_row ( column, window, row );
		    }
		}

	      col = -1;	/*** flag--already refreshed entire row ***/
	    }
	}

      if ( col != -1 )	/*** regular field or no row select ***/
	{
	  field->FIfield.buffer[row].sel |= 0x0001;
	  field->FIfield.prev_sel = row;

	  if (  ( field->FIfield.mode == FI_SINGLE_SELECT )	||
		( field->FIfield.mode == FI_MULTI_SELECT  )	 )
	    {
	      _FI_fld_refresh_row ( field, window, row );
	    }
	}

     /* Pass data to gadget if sequenced */

      _FI_g_pass_data ( (struct FIgadget_obj *)field );
    }
}


/*====================================================================*/

void _FI_fld_refresh_row (struct FIfld_obj  *field,
                          Window             window,
                          int                row)
{
  int	len, nx, ny;
  short x1, y1, x2, y2;
  int	Xscreen = XSCREEN( field );
  int	bgcolor;


  if (	( window == None )				||
	( field->FIgadget.form->displayed == 0 )	||
	IT_IS_NOT_DISPLAYABLE( field )			 )
    {
      return;
    }

	/****************************************************/
	/* If row is in viewing area and echoed, redisplay  */
	/****************************************************/

  if ( (! field->FIfield.flags.no_echo )			&&
	( row >= field->FIfield.roff)				&&
	( row < field->FIfield.roff + field->FIfield.nvr )	 )
    {
	/*************************/
	/* calculate coordinates */
	/*************************/

      x1 = (short) field->FIgadget.xlo;
      y1 = (short) ( field->FIgadget.ylo +
			( (row - field->FIfield.roff) *
				(int) field->FIfield.line_height ) );

      if ( field->FIfield.list_id || field->FIfield.flags.roll_thru )
	{
	  x2 = field->FIgadget.xhi - ROLL_THROUGH_SYM_WIDTH +
							FIELD_BEZEL;
	}
      else
	{
	  x2 = (short) field->FIgadget.xhi;
	}

      y2 = y1 + (int) field->FIfield.line_height;

	/*******************/
	/* draw background */
	/*******************/

      if ( ( field->FIfield.mode == FI_INSERT )		 ||
	   ( field->FIfield.mode == FI_APPEND )		  )
	{
          bgcolor = FI_translate_color ( Xscreen, FI_MED_GREY );
			                 /* GMD 4/19/91 */
	}
      else
	{
          bgcolor = FI_translate_color ( Xscreen, FI_LT_GREY );
			                 /* GMD 4/19/91 */
	}

      XSetForeground ( _FI_display, _FI_gc, bgcolor );

      if ( field->FIfield.flags.required )
	{
	  XGCValues gc_values;
	  unsigned long gc_value_mask;

	  XSetBackground ( _FI_display, _FI_gc,
			FI_translate_color ( Xscreen, FI_WHITE ) );

	  gc_value_mask	       = GCStipple | GCBackground | GCFillStyle;
	  gc_values.background =
			      FI_translate_color ( Xscreen, FI_WHITE );
	  gc_values.stipple    = _FIpix_required_array [Xscreen];
	  gc_values.fill_style = FillOpaqueStippled;
	  XChangeGC ( _FI_display, _FI_gc, gc_value_mask, &gc_values );
	}

      XFillRectangle ( _FI_display, window, _FI_gc,
					x1, y1, x2 - x1, y2 - y1 );

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
      if (!_FI_dont_flush)
        XFlush ( _FI_display );

      if ( field->FIfield.flags.required )
	{
	  XSetFillStyle ( _FI_display, _FI_gc, FillSolid );
	}

      if ( field->FIfield.buffer[row].line )
	{
		/*******************************************/
		/*** Calculate length for selection box. ***/
		/*** 12/07/89 Changed from strlen()	 ***/
		/*** <pds-2/15/90> Added 'font_type 	 ***/

	  len = FI_strlen ( (char *) field->FIfield.buffer[row].line,
		     field->FIgadget.font_type ) - field->FIfield.coff;

	  if ( len < 0 )
	    {
	      len = 0;
	    }

	  if ( len > field->FIfield.nvc )
	    {
	      len = field->FIfield.nvc;
	    }

		/**********************************/
		/* draw selection box - if needed */
		/**********************************/

	  if ( ( field->FIfield.buffer[row].sel & 0x0001)	&&
	     ( ( field->FIfield.mode == FI_SINGLE_SELECT ) ||
	       ( field->FIfield.mode == FI_MULTI_SELECT  )  )	 )
	    {
              bgcolor = FI_translate_color ( Xscreen, FI_MED_GREY );
              				          /* GMD 4/19/91 */

	      XSetForeground ( _FI_display, _FI_gc, bgcolor );

	      XFillRectangle ( _FI_display, window, _FI_gc,
					x1, y1, x2 - x1, y2 - y1 );
	    }

		/*************/
		/* draw text */
		/*************/

	  if ( ( field->FIfield.buffer[row].sel & 1 )		||
	       ( field->FIfield.mode < FI_REVIEW    )		||
	       ( field->FIfield.mode > FI_MULTI_SELECT )	 )
	    {
	      XSetForeground ( _FI_display, _FI_gc,
		  FI_translate_color ( Xscreen,
			_FI_fld_get_line_ON_COLOR ( field, row ) ) );
	    }
	  else
	    {
	      XSetForeground ( _FI_display, _FI_gc,
		  FI_translate_color ( Xscreen,
			_FI_fld_get_line_OFF_COLOR ( field, row ) ) );
	    }

						/* GMD 4/19/91 */
	  XSetBackground ( _FI_display, _FI_gc, bgcolor );


		/************************************/
		/* Added no-echo check 11/30/89 GMD */
		/************************************/

	  if ( ! field->FIfield.flags.no_echo )
	    {
		/* Hebrew 8/1/90 */
	      if ( field->FIfield.flags.right_to_left )
		{
		  char	s1[30000], s2[30000];
		  int	xnew, ht, wd, ls;
		  int	temp_font_height;
/*		  char widest_str[10];
		  int status;
*/

#if defined(hp9000)
		  strncpy ( s1,
		  (char *) &field->FIfield.buffer[row].line[field->FIfield.coff],
			len);
#else
		  strncpy ( s1,
		  &field->FIfield.buffer[row].line[field->FIfield.coff],
			len);
#endif

		  s1[len]= 0;
		  _FI_flip_string ( s1, s2 );

		  /*sml:08-11-92 use widest characters here for _FI_s_rep() */
	
/***** sml:10-05-92	calling FI_calc_text has round trip call when
					using X server fonts; just used gadget members
					font_height and font_width and field member
					line_spacing

		  status = _FI_widest_char(field->FIgadget.font_type, widest_str);
		    FI_calc_text ( field->FIgadget.font_id, //"m"// widest_str, 1,
			&ht, &wd, &ls, field->FIgadget.font_type );

************/

	  ht = field->FIgadget.font_height;
	  wd = field->FIgadget.font_width;
	  ls = field->FIfield.line_height;

		  xnew = (int) field->FIgadget.xlo;
		  xnew += ( field->FIfield.nvc - len ) * wd;

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

		  FI_draw_text ( window, field->FIgadget.font_id,
				s2, len, xnew, y1,
				temp_font_height,
				&nx, &ny, field->FIgadget.font_type);
		}
	      else
		{
		  int	temp_font_height;

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

		  FI_draw_text ( window, field->FIgadget.font_id,
			(char *) & ( field->FIfield.buffer[row].line[
				FI_move_index (
					(char *) field->FIfield.buffer[row].line,
					0, field->FIfield.coff,
					field->FIgadget.font_type )]),
			len, x1, y1,
			temp_font_height,
			&nx, &ny, field->FIgadget.font_type);
		}
	    }
	}
    }
}

/*====================================================================*/

int _FI_fld_find_gadget (struct FIfld_obj      *field,
                         int                    xpos,
                         int                    ypos,
                         struct FIgadget_obj  **search_gadget)
{
  struct FIfld_obj *list_id;


  list_id = field->FIfield.list_id;

  if ( list_id )
    {
      if ( _FI_generic_find_gadget ( (struct FIgadget_obj *) list_id,
		xpos, ypos )	)
	{
	  *search_gadget = (struct FIgadget_obj *) list_id;
	  return ( TRUE );
	}

      if ( list_id->FIfield.hscrl )
	{
	      if ( _FI_generic_find_gadget ( (struct FIgadget_obj *)
				list_id->FIfield.hscrl[0], xpos, ypos ))
		{
	          *search_gadget = (struct FIgadget_obj *)
					      list_id->FIfield.hscrl[0];
	          return ( TRUE );
		}

	      if ( _FI_generic_find_gadget ( (struct FIgadget_obj *)
				list_id->FIfield.hscrl[1], xpos, ypos ))
		{
	          *search_gadget = (struct FIgadget_obj *)
					      list_id->FIfield.hscrl[1];
	          return ( TRUE );
		}
	}

      if ( list_id->FIfield.vscrl_id )
	{
	  if ( _FI_generic_find_gadget ( (struct FIgadget_obj *)
				list_id->FIfield.vscrl_id, xpos, ypos ))
	    {
	      *search_gadget = (struct FIgadget_obj *)
					    list_id->FIfield.vscrl_id;
	      return ( TRUE );
	    }
	}
    }

  if ( _FI_generic_find_gadget ( (struct FIgadget_obj *) field,
							xpos, ypos ))
    {
      if ( xpos >= field->FIgadget.xhi - ROLL_THROUGH_SYM_WIDTH )
	{
	  field->FIgadget.value = (double)((int)FI_ASSOCIATED_LIST);
	}
      else
	{
	  field->FIgadget.value = field->FIfield.ar;
	}

      *search_gadget = (struct FIgadget_obj *) field;

      return ( TRUE );
    }

  if ( field->FIfield.vscrl_id )
    {
      if ( _FI_generic_find_gadget ( (struct FIgadget_obj *)
				field->FIfield.vscrl_id, xpos, ypos ))
	{
	  *search_gadget = (struct FIgadget_obj *)
					field->FIfield.vscrl_id;
	  return ( TRUE );
	}
    }

  if ( field->FIfield.hscrl )
    {
	  if ( _FI_generic_find_gadget ( (struct FIgadget_obj *)
				field->FIfield.hscrl[0], xpos, ypos ))
	    {
	      *search_gadget = (struct FIgadget_obj *)
					field->FIfield.hscrl[0];
	      return ( TRUE );
	    }

	  if ( _FI_generic_find_gadget ( (struct FIgadget_obj *)
				field->FIfield.hscrl[1], xpos, ypos ))
	  {
	    *search_gadget = (struct FIgadget_obj *)
						field->FIfield.hscrl[1];
	    return ( TRUE );
	  }
    }
  return (FALSE );
}


/*********************************************************************/
/***  _FI_fld_change_case:   changed from "void" to "int"          ***/
/***  Returns:  FI_SUCCESS                          JAJ:09/04/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/
/*  int upper_lower_flag;		** 0 == to lower, 1 = to upper */

int _FI_fld_change_case (struct FIfld_obj  *field,
                         int                upper_lower_flag)
{
  int status;

  if ( ! sbitset ( field->FIfield.buffer[field->FIfield.ar].line[
	 FI_move_index ( (char *)field->FIfield.buffer[field->FIfield.ar].line,
			 0, field->FIfield.ac,
			field->FIgadget.font_type )])		)
    {
      int field_ar = field->FIfield.ar;
      int field_ac = field->FIfield.ac;

      if ( upper_lower_flag )
	{
	  field->FIfield.buffer[field_ar].line[field_ac] =
	      toupper ( field->FIfield.buffer[field_ar].line[field_ac]);
	}
      else
	{
	  field->FIfield.buffer[field_ar].line[field_ac]=
	      tolower ( field->FIfield.buffer[field_ar].line[field_ac]);
	}

		/******************/
		/* redisplay char */
		/******************/

		/*** X11-5/22/90-If this routine is being called, ***/
		/*** we must have control of the keyboard. 	  ***/

      _FI_fld_draw_cursor ( field, XWINDOW( field ), 1, FI_MED_GREY,
				_FI_fld_get_line_ON_COLOR (
					(struct FIfld_obj *) field,
							field_ar )  );

      if ( field->FIfield.flags.required == 1 )
	{
	  if ( IT_IS_DISPLAYED( field )			&&
		IT_IS_DISPLAYABLE( field )		&&
		( XWINDOW( field ) != None )		 )
	    {
	      _FI_fld_refresh_row ( field, XWINDOW( field ),
						field->FIfield.ar );
	    }
	}

      status = _FI_fld_forward ( field, 1 );

      if ( status != FI_SUCCESS )
	{
	  return ( status );
	}
    }
  return ( FI_SUCCESS );
}


/*********************************************************************/
/***  _FI_fld_transpose:   changed from "void" to "int"            ***/
/***  Returns:  FI_SUCCESS                          JAJ:09/05/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/

int _FI_fld_transpose (struct FIfld_obj *field)
{
  int		pos, old_pos;
  unsigned char ch1[2], ch2[2];
  int		status;

	/*** <pds-12/08/89> Changed from strlen()	***/
	/*** <pds-2/15/90> Added 'font_type' 		***/

  if ( field->FIfield.ac < FI_strlen (
			(char *) field->FIfield.buffer[field->FIfield.ar].line,
			field->FIgadget.font_type ) - 1		      )
    {
		/***********************************/
		/* locate characters to be swapped */
		/***********************************/

      /* dmb:09/30/92:Added font_type */
      pos = FI_move_index (
			(char *)field->FIfield.buffer[field->FIfield.ar].line,
			field->FIfield.ac, 0, field->FIgadget.font_type );
      old_pos = pos;

      ch1[0]= field->FIfield.buffer[field->FIfield.ar].line[pos++];

      if ( sbitset(ch1[0])			&&
	  ( field->FIgadget.font_type == FI_FS_7_OR_16_BIT_FONT_TYPE ))
	{
	  ch1[1]= field->FIfield.buffer[field->FIfield.ar].line[pos++];
	}

      ch2[0]= field->FIfield.buffer[field->FIfield.ar].line[pos++];

      if ( sbitset(ch2[0])			&&
	  ( field->FIgadget.font_type == FI_FS_7_OR_16_BIT_FONT_TYPE ))
	{
	  ch2[1]= field->FIfield.buffer[field->FIfield.ar].line[pos++];
	}

			/*******************/
			/* swap characters */
			/*******************/

      pos = old_pos;

      field->FIfield.buffer[field->FIfield.ar].line[pos++]= ch2[0];

      if ( sbitset(ch2[0])				&&
	  ( field->FIgadget.font_type == FI_FS_7_OR_16_BIT_FONT_TYPE ))
	{
	  field->FIfield.buffer[field->FIfield.ar].line[pos++]= ch2[1];
	}

      field->FIfield.buffer[field->FIfield.ar].line[pos++]= ch1[0];

      if ( sbitset(ch1[0])			&&
	   ( field->FIgadget.font_type == FI_FS_7_OR_16_BIT_FONT_TYPE ))
	{
	  field->FIfield.buffer[field->FIfield.ar].line[pos++]= ch1[1];
	}

			/******************/
			/* redisplay char */
			/******************/

	/*** X11-5/22/90-If this routine is being called,	***/
	/*** we must have control of the keyboard.		***/

      _FI_fld_draw_cursor ( field, XWINDOW(field), 1, FI_MED_GREY,
			_FI_fld_get_line_ON_COLOR ( field,
				field->FIfield.ar ));	/* GMD:4/6/90 */

      if ( field->FIfield.flags.required == 1)
	{
	  if (	IT_IS_DISPLAYED (field)			&&
		IT_IS_DISPLAYABLE (field)		&&
		( XWINDOW(field) != None )		 )
	    {
	      _FI_fld_refresh_row ( field, XWINDOW(field),
						field->FIfield.ar );
	    }
	}

      status = _FI_fld_forward ( field, 1 );

      if ( status != FI_SUCCESS )
	{
	  return ( status );
	}
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

int _FI_fld_verify_data (struct FIfld_obj *field)
{
  int		status = FI_SUCCESS;
  int		ii;
  double	value;
  int		num_params;
  int		ar = field->FIfield.ar;


  /***************************************************************/
  /* If the operator specified a validation routine, then skip   */
  /* the normal verification procedures in favor of it.		 */
  /********************************************* GMD 1/3/91 ******/

  if ( field->FIfield.validation )
    {
      status = field->FIfield.validation (
			field->FIfield.buffer[ar].line,
			field->FIfield.field_type );
    }
  else if ( field->FIfield.min != field->FIfield.max )
    {
      num_params = sscanf ( (char *)field->FIfield.buffer[ar].line, "%lf",
							&value );

      if ( ( value < field->FIfield.min )	||
	   ( value > field->FIfield.max )	||
	   ( num_params != 1 )			 )
	{
	  status = FI_ILLEGAL_VALUES;
	}
      else
	{
	  status = FI_SUCCESS;
	}
    }

  if ( field->FIfield.flags.valid_list  &&  field->FIfield.list_id )
    {
      status = FI_ILLEGAL_VALUES;

      for ( ii = 0; ii < field->FIfield.list_id->FIfield.buffer_size;
							ii++ )
	{

#if defined(hp9000)
	  if ( strcmp ( (char *) field->FIfield.buffer[ar].line,
		(char *) field->FIfield.list_id->FIfield.buffer[ii].line ) == 0 )
#else
	  if ( strcmp ( field->FIfield.buffer[ar].line,
		field->FIfield.list_id->FIfield.buffer[ii].line ) == 0 )
#endif
	  {
	    status = FI_SUCCESS;
	    break;
	  }
	}
    }

  if ( status == FI_ILLEGAL_VALUES )
    {
      if ( field->FIfield.default_size )
	{
	  if ( field->FIfield.default_size > ar )
	    {
	      ii = ar;
	    }
	  else
	    {
	      ii = 0;
	    }

#if defined(hp9000)
	  strcpy ( (char *) field->FIfield.buffer[ar].line,
			(char *) field->FIfield.defaults[ii].line );
#else
	  strcpy ( field->FIfield.buffer[ar].line,
			field->FIfield.defaults[ii].line );
#endif
	}
      else
	{
#if defined(hp9000)
	  strcpy ( (char *) field->FIfield.buffer[ar].line, "" );
#else
	  strcpy ( field->FIfield.buffer[ar].line, "" );
#endif
	}

	/*** <pds-12/08/89> Changed from strlen()	***/
	/*** <pds-2/15/90> Added 'font_type'		***/

      field->FIfield.ac = FI_strlen ( (char *)field->FIfield.buffer[ar].line,
					field->FIgadget.font_type );

      if ( IT_IS_DISPLAYED(field)		&&
	   IT_IS_DISPLAYABLE(field)		&&
	  ( XWINDOW( field ) != None )		 )
	{
	  _FI_fld_refresh_row ( field, XWINDOW(field), ar );
	}

      return ( FI_ILLEGAL_VALUES );
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

void _FI_fld_justify_data (struct FIfld_obj *field)
{
  int	 	 ii, len;
  int	 	 field_ar;
  unsigned char	*old_string;
  char	 	 new_string[10000];


  if (	( field->FIgadget.justification != FI_LEFT_JUSTIFIED )	&&
	( ! field->FIfield.flags.lrs )		 		 )
    {
	/************************************************/
	/* First discard any leading blanks on the line */
	/************************************************/

      old_string = field->FIfield.buffer[field->FIfield.ar].line;

      while ( *old_string && *old_string == ' ' )
	{
	  old_string++;
	}

#if defined(hp9000)
      strcpy ( new_string, (char *) old_string );
#else
      strcpy ( new_string, old_string );
#endif

	/***********************************************/
	/* Now discard any trailing blanks on the line */
	/***********************************************/

			/*** streamlined this -- JAJ:08/31/91 ***/
      for ( ii = strlen (new_string) - 1; ii >= 0 ; ii-- )
	{
	  if ( new_string[ii] == ' ' )
	    {
      	      new_string[ii] = '\0';
	    }
	  else
	    {
	      break;
	    }
	}

      _FI_fld_add_to_line ( field, field->FIfield.ar,
					field->FIfield.nvc + 3 );

     /***********************************************/
     /* Copy text into field based on justification */
     /***********************************************/

	/*** <pds-12/13/89> Changed from strlen()	***/
	/*** <pds-2/15/90> Added 'font_type'		***/

      len = FI_strlen ( new_string, field->FIgadget.font_type );

      field_ar = field->FIfield.ar;

      if ( field->FIgadget.justification == FI_RIGHT_JUSTIFIED )
	{
	  for ( ii = 0; ii < ( field->FIfield.nc - len ); ii++ )
	    {
	      field->FIfield.buffer[field_ar].line[ii]= ' ';
	    }
#if defined(hp9000)
	  strcpy ( (char *) &field->FIfield.buffer[field_ar].line[ii],
					(char *) new_string );
#else
	  strcpy ( &field->FIfield.buffer[field_ar].line[ii],
							new_string );
#endif
	}
      else if ( field->FIgadget.justification == FI_CENTER_JUSTIFIED )
	{
	  for ( ii = 0; ii < (( field->FIfield.nc - len ) / 2); ii++ )
	    {
	      field->FIfield.buffer[field_ar].line[ii]= ' ';
	    }

#if defined(hp9000)
	  strcpy ( (char *) &field->FIfield.buffer[field_ar].line[ii],
					(char *) new_string );
#else
	  strcpy ( &field->FIfield.buffer[field_ar].line[ii],
							new_string );
#endif
	}

		/*************************************/
		/* Check to see if form is displayed */
		/*************************************/

      if ( IT_IS_DISPLAYED(field)	&&
	   IT_IS_DISPLAYABLE(field)	&&
	   ( XWINDOW(field) != None )	 )
	{
	  _FI_fld_refresh_row ( field, XWINDOW(field), field_ar );
	}
    }
}
