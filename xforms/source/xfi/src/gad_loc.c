#include "FImin.h"

#include "FIscroll.h"
#include "FIbtn.h"
#include "FIfield.h"
#include "FImcf.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"



extern int _FI_fld_new_event;
extern int _FI_fld_new_event_value;
extern Form _FI_fld_new_form;
extern int _FI_fld_new_gadget;
extern int _FI_fld_new_xpos;
extern int _FI_fld_new_ypos;
extern int _FI_fld_new_event_status;

static int ( *branch_table_adjust[]) () =
{
  NULL,
  (int (*) ()) _FI_sld_adjust,
  (int (*) ()) _FI_tog_adjust,
  (int (*) ()) _FI_fld_adjust,
  (int (*) ()) _FI_cklst_adjust,
  (int (*) ()) _FI_dial_adjust,
  (int (*) ()) _FI_txt_adjust,
  (int (*) ()) _FI_btn_adjust,
  (int (*) ()) _FI_generic_adjust,
  (int (*) ()) _FI_generic_adjust,
  (int (*) ()) _FI_generic_adjust,
  (int (*) ()) _FI_sym_adjust,
  (int (*) ()) _FI_scrl_adjust,
  (int (*) ()) _FI_mcf_adjust,
  (int (*) ()) _FI_generic_adjust
};


/* delta_x and delta_y are the multiplication factors	*/
/* on the current x and y dimensions of the gadget.	*/

/* dmb:10/10/92:Change floats to doubles for ANSI */
void _FI_g_adjust_size (struct FIgadget_obj *gadget,
                        double               delta_x,
                        double               delta_y)
{
  int type = gadget->FIgadget.type;

  if ( type == FI_GROUP )
    {
      /* dmb:10/10/92:Change pass_on_*_float to pass_on_*_double for ANSI */
      _FI_grp_pass_on_id_double_always ( gadget, (int (*) ())_FI_g_adjust_size,
						 delta_x, delta_y );
    }
  else
    {
    /* dmb:10/08/92:Added casts to try to clear up menu buttons problem */
      branch_table_adjust[type] ( gadget, (double)delta_x, (double)delta_y );
    }
}


int _FI_g_change_location ( struct FIgadget_obj *gadget,
                            int                  delta_x,
                            int                  delta_y)
{
  struct FIfld_obj * field;
  struct FImcf_obj * temp_mcf;


  gadget->FIgadget.xlo += delta_x;
  gadget->FIgadget.xhi += delta_x;

  /*************************************************/
  /*  sml:10-04-93 NO TR                           */
  /*  (PATTERNED AFTER I/FORMS)                    */
  /*  factor in text offset for checkbox           */
  /*************************************************/
  if (gadget->FIgadget.type == FI_CHECKLIST)
  {
	struct FIcklst_obj *cklst = (struct FIcklst_obj * ) gadget;
	int y_offset;

    if ( IT_HAS_TEXT ( cklst ) )
    {
      y_offset = cklst->FIgadget.num_lines * cklst->FIgadget.font_height;
      y_offset += (int )(y_offset * YOFFSET_MULTIPLIER );
    }
    else
    {
      y_offset = cklst->FIgadget.font_height;
    }
  }

  gadget->FIgadget.ylo += delta_y;
  gadget->FIgadget.yhi += delta_y;

  switch ( gadget->FIgadget.type )
    {
      case FI_GROUP:

	_FI_grp_pass_on_id_int ( gadget, _FI_g_change_location,
						 delta_x, delta_y );
	break;

      case FI_MULTI_COL:

	temp_mcf = (struct FImcf_obj *) gadget;

	_FI_grp_pass_on_id_int ( gadget, _FI_g_change_location,
						 delta_x, delta_y );

        if ( temp_mcf->FImcf.vscrl_id )
	  {
	    _FI_g_change_location ( (struct FIgadget_obj *)
					temp_mcf->FImcf.vscrl_id,
					delta_x, delta_y );
	  }

	if ( temp_mcf->FImcf.hscrl_id )
	  {
	    _FI_g_change_location ( (struct FIgadget_obj *)
					temp_mcf->FImcf.hscrl_id,
					delta_x, delta_y );
          }
	break;


      case FI_FIELD:

	field = (struct FIfld_obj *) gadget;

	if ( field->FIfield.vscrl_id )
	  {
	    _FI_g_change_location ( (struct FIgadget_obj *)
			field->FIfield.vscrl_id, delta_x, delta_y );
          }

	if ( field->FIfield.hscrl )
	  {
	    _FI_g_change_location ( (struct FIgadget_obj *)
					field->FIfield.hscrl[0],
					delta_x, delta_y );

	    _FI_g_change_location ( (struct FIgadget_obj *)
					field->FIfield.hscrl[1],
					delta_x, delta_y );
	  }

	if ( field->FIfield.list_id )
	  {
	    _FI_g_change_location ( (struct FIgadget_obj *)
					field->FIfield.list_id,
					delta_x, delta_y );
	  }
      break;

      case FI_SCROLL:
	_FI_scrl_calc_bar ( (struct FIscrl_obj *)gadget );
	break;

      case FI_DIAL:
	_FI_dial_calc ( (struct FIdial_obj *)gadget );
	break;
    }
  return ( FI_SUCCESS );
}


/*********************************************************************/
/***  _FI_g_track_mouse:   changed from "void" to "int"            ***/
/***  Returns:  FI_SUCCESS                          JAJ:09/04/90   ***/
/***            FI_NO_SUCH_FORM - means form apparently got        ***/
/***                              deleted by notification routine  ***/
/***            FI_NO_SUCH_GADGET - means gadget apparently got    ***/
/***                              deleted by notification routine  ***/
/*********************************************************************/
int _FI_g_track_mouse (struct FIgadget_obj *gadget,
                       Window               window,
                       int                  xpos,
                       int                  ypos,
                       int                 *complete,
                       double              *value)
{
  int pass_data = 0;
  int type	= gadget->FIgadget.type;
  int status	= FI_SUCCESS;

  _FI_mcf_break_navigation = FALSE;

	_FI_initialize_fld_new_values();
	_FI_fld_new_event = ButtonPress;
	_FI_fld_new_form = (Form) (FI_forms[_FI_Xwindow_to_index (window)]);
	_FI_fld_new_event_value = _FI_select_button;
	_FI_fld_new_xpos = xpos;
	_FI_fld_new_ypos = ypos;

	if (gadget->FIgadget.type == FI_SCROLL && 
			gadget->FIgadget.user_pointer) 
	{
	  struct FIgadget_obj * parent = 
		(struct FIgadget_obj *) gadget->FIgadget.user_pointer;

	  _FI_fld_new_gadget = parent->FIgadget.label;
	  
	}
	else if (gadget->FIgadget.type == FI_FIELD &&
			gadget->FIgadget.user_pointer) 
	{
	  struct FIfld_obj * field = (struct FIfld_obj *) gadget;

	  if (field->FIfield.flags.is_a_list)
	  {
		struct FIgadget_obj * parent = 
		  (struct FIgadget_obj *) gadget->FIgadget.user_pointer;

		_FI_fld_new_gadget = parent->FIgadget.label;
		_FI_fld_new_event_status = FI_SELECTED_ASSOCIATED_LIST;
	  }
	}
	else
	{
	  _FI_fld_new_gadget = gadget->FIgadget.label;
	}


  switch ( type )
    {
      case FI_FIELD:

	status = _FI_fld_track_mouse ( (struct FIfld_obj *)gadget, window, xpos, ypos,
						complete, value );
	if ( status != FI_SUCCESS )
          {
	     return ( status );
          }
	break;

      case FI_BUTTON:

	/* The group must be checked because some field	*/
	/* buttons are not members of a group.		*/

	if ( gadget->FIgadget.group  &&
		( gadget->FIgadget.group->FIgroup.single_select ))
	  {
	    if ( ! gadget->FIgadget.value )
	      {
		status = _FI_btn_track_mouse ( (struct FIbtn_obj *)
						gadget, window,
						complete, value );
		if ( status != FI_SUCCESS )
		  {
		    return ( status );
		  }

		_FI_grp_notify_selected ( gadget );
	      }
	    else
	      {
		gadget->FIgadget.value = 0.0;

		status = _FI_btn_track_mouse ( (struct FIbtn_obj *)
						gadget, window,
						complete, value );

		if ( status != FI_SUCCESS )
		  {
		    return ( status );
		  }
	      }

	/* Set complete to TRUE only if button is not an auto_pop_up */

	    if ( ! ((struct FIbtn_obj *) gadget )->FIbtn.auto_pop_up )
	      {
		*complete = TRUE;
              }

	    pass_data = TRUE;
	  }
	else if ( ! ((struct FIbtn_obj *) gadget )->FIbtn.menu_button )
	  {
	     status = _FI_btn_track_mouse ( (struct FIbtn_obj *)
						gadget, window,
						complete, value );
	     if ( status != FI_SUCCESS )
	      {
		return ( status );
	      }
	     pass_data = TRUE;
	  }

	     /* Don't do any processing for a menu button */

	break;

      case FI_TOGGLE:

	if ( gadget->FIgadget.group->FIgroup.single_select )
	  {
	    if ( ! ( gadget->FIgadget.value ))
	      {
		_FI_tog_track_mouse ( (struct FItog_obj *)gadget, window, complete, value );
		_FI_grp_notify_selected ( gadget );
	      }
	    else
	      {
		gadget->FIgadget.value = 0.0;
		_FI_tog_track_mouse ( (struct FItog_obj *)gadget, window, complete, value );
	      }
	  }
	else
	  {
	    _FI_tog_track_mouse ( (struct FItog_obj *)gadget, window, complete, value );
	  }

	pass_data = TRUE;

	break;


      case FI_CHECKLIST:

	if ( gadget->FIgadget.group->FIgroup.single_select )
	  {
	    if ( ! ( gadget->FIgadget.value ))
	      {
		_FI_cklst_track_mouse ( (struct FIcklst_obj *)gadget, window, complete, value );
		_FI_grp_notify_selected ( gadget );
	      }
	    else
	      {
		gadget->FIgadget.value = 0.0;	/* GMD 10/19/90 */

		_FI_cklst_track_mouse ( (struct FIcklst_obj *)gadget, window, complete, value );
	      }
	  }
	else
	  {
	    _FI_cklst_track_mouse ( (struct FIcklst_obj *)gadget, window, complete, value );
	  }

	pass_data = TRUE;

	break;


      case FI_SLIDER:

	_FI_sld_track_mouse ( (struct FIsld_obj *) gadget,
				window, xpos, ypos, complete, value );
	break;


      case FI_DIAL:

	_FI_dial_track_mouse ( (struct FIdial_obj *)gadget, window, xpos, ypos,
						complete, value );
	break;


      case FI_MULTI_COL:

	status = _FI_mcf_track_mouse ( (struct FImcf_obj *)gadget, window, xpos, ypos,
						 complete, value );
	if ( status != FI_SUCCESS )
   	  {
	    return ( status );
   	  }

	break;


      case FI_SCROLL:

	status = _FI_scrl_track_mouse ( (struct FIscrl_obj *)gadget, window, xpos, ypos,
						complete, value );
	if ( status != FI_SUCCESS )
   	  {
	    return ( status );
   	  }
	break;

	
	/*************************************/
	/*** Text, symbol, line, rect, etc ***/
	/*************************************/

      default:
	*complete = TRUE;
	break;
    }

  if ( *complete )
    {
      _FI_g_common ( gadget );
    }

	/* Pass on data */

  if ( pass_data )
    {
      _FI_g_pass_data ( gadget );
    }


	/*** Set complete to TRUE because menu button needs	***/
	/*** to notify completion but doesn't need to process	***/
	/*** common until later					***/

  if ( ( type == FI_BUTTON )					&& 
	( ((struct FIbtn_obj *) gadget )->FIbtn.menu_button )	 )
    {
      *complete = TRUE;
    }

  return ( status );
}



int _FI_g_find_gadget (struct FIgroup_obj   *group,
                       int                   xpos,
                       int                   ypos,
                       struct FIgadget_obj **search_gadget)
{
  struct FIgadget_obj *gadget;
  int		ii, zz, qq;
  int		multi_line_text;
  int		start_index, end_index;
  char		t_str[5000];
  int		ht, wd, ls;
  int		x_lo, x_hi, y_lo, y_hi;
  int		status = FI_SUCCESS;


  for ( ii = 0; ii < (int)group->FIgroup.size; ii++ )
    {
      gadget = group->FIgroup.gadgets[ii];

	/*** skip entries that aren't valid ***/

      if ( ! gadget )
        {
	  continue;
        }

      switch ( gadget->FIgadget.type )
	{
	        /* The code for enable ignores these gadgets: */
	        /* line, bezel, rect */

	/*** These gadgets cannot be located because we would	***/
	/*** have to add an algorithm to detect points on a	***/
	/*** line and on edge of rect.				***/

	  case FI_LINE:
	  case FI_BEZEL:
	    break;

	  case FI_GROUP:

	    if ( ! ((struct FIgroup_obj *) gadget )->
						FIgroup.dont_pass_on )
	      {
		if ( _FI_g_find_gadget ( (struct FIgroup_obj *) gadget,
					xpos, ypos, search_gadget ) )
		  {
		    return ( TRUE );
		  }
	      }
	    break;

	  case FI_RECT:

		/* If the rectangle is not a FILLED rectangle,	*/
		/* then continue.				*/

	    if ( gadget->FIgadget.effect != FI_FILLED )
	      {
		break;
	      }

	    if ( _FI_generic_find_gadget ( gadget, xpos, ypos ))
	      {
		*search_gadget = gadget;
		return ( TRUE );
	      }
	    break;


	  case FI_CHECKLIST:

	    if ( _FI_cklst_find_gadget ( (struct FIcklst_obj *) gadget,
					xpos, ypos, search_gadget ))
	      {
		return ( TRUE );
	      }
	    break;

	  case FI_FIELD:
	    if ( _FI_fld_find_gadget ( (struct FIfld_obj *)gadget, xpos, ypos,
						 search_gadget ))
	      {
		return ( TRUE );
	      }
	    break;

	  case FI_MULTI_COL:
	    if ( _FI_mcf_find_gadget ( (struct FImcf_obj *)gadget, xpos, ypos,
						 search_gadget ))
	      {
		return ( TRUE );
	      }
	    break;

	  case FI_TEXT:

	    if ( gadget->FIgadget.text[0] == '\0' )  /* NULL string */
	      {
		break;
	      }

	        /******************************************************/
	        /* This routine checks to see if the datapoint falls  */
	        /* within a rectangle defined by the number of lines  */
	        /* by the length of the longest line.  Thus it is too */
	        /* coarse to be used for multi-line text by itself.   */
	        /******************************************************/

	    status = _FI_generic_find_gadget ( gadget, xpos, ypos );

	    if ( status )
	      {
	           /*************************************************/
	           /* First check to see if it is multi-line text.  */
	           /* Counter variable is incremented once for      */
	           /* each carriage return that is found.           */
	           /*************************************************/

		multi_line_text = 0;

		for ( zz = 0; zz < strlen ( (char *)gadget->FIgadget.text );
								 zz++ )
		  {
		    if ( gadget->FIgadget.text[zz]== '\n')
		      {
			multi_line_text++;
		      }
		  }

			/* if single line handle normally */
		if ( multi_line_text == 0 )
		  {
		    *search_gadget = gadget;
		    return ( TRUE );
		  }
		else
		  {
		    start_index = 0;
		    end_index = 0;

              /*******************************************************/
              /* For each line of text, parse the line of text into  */
              /* the variable t_str.  Then determine its width using */
              /* the FI_calc_text function.  The y position of each  */
              /* line is fixed and can be calculated using the	     */
              /* "ls" ( line spacing ) variable.		     */
              /*						     */
              /* The X position of the text on a particular line can */
              /* vary due to its justification.  If the text is      */
              /* left justified, then each line of text will be      */
              /* located beginning at the xlo for the text gadget.   */
              /*						     */
              /* If the text is right justified, then the end of the */
              /* text will be flush with the xhi of the text.  The   */
              /* value for xhi is equal to the longest string in the */
              /* multi-line string.				     */
              /*						     */
              /* If the text is center justified, you must subtract  */
              /* the width of the current line from the length of    */
              /* the longest line.( which happens to be the width of */
              /* the text gadget )  This value must be divided by 2  */
              /* so that an equal amount of space can be found on    */
              /* either side of the text.  Thus the line begins at   */
              /* xlo + the calculated value.			     */
              /* GMD 1/28/91					     */
              /*******************************************************/

		    for ( zz = 0; zz <= multi_line_text; zz++ )
		      {
			while ( ( gadget->FIgadget.text[end_index] != '\n') &&
			 ( gadget->FIgadget.text[end_index] != '\0' ) )
			  {
			    end_index++;
			  }

			t_str[0]= '\0';

			for ( qq = 0; qq < end_index - start_index; qq++ )
			  {
			    t_str[qq]= gadget->FIgadget.text[start_index + qq];
			  }

			t_str[qq]= '\0';

			if ( strlen ( t_str ) > 0 )
			  {
			    FI_calc_text ( gadget->FIgadget.font_id,
					t_str, strlen (t_str),
					&ht, &wd, &ls,
					gadget->FIgadget.font_type );

			    y_lo = ( ls * zz ) + gadget->FIgadget.ylo;
			    y_hi = y_lo + ls;

			    if ( gadget->FIgadget.justification ==
						FI_LEFT_JUSTIFIED )
			      {
				x_lo = (int) gadget->FIgadget.xlo;
				x_hi = (int) gadget->FIgadget.xlo + wd;
			      }
			    else if ( gadget->FIgadget.justification ==
						FI_RIGHT_JUSTIFIED )
			      {
				x_hi = (int) gadget->FIgadget.xhi;
				x_lo = (int) gadget->FIgadget.xhi - wd ;
			      }
			    else /* FI_CENTER_JUSTIFIED ) */
			      {
				x_lo = (int) (( gadget->FIgadget.xhi +
				      gadget->FIgadget.xlo - wd ) / 2 );
				x_hi = x_lo + wd;
			      }

			    if ( ( xpos >= x_lo ) && ( xpos <= x_hi ) &&
				 ( ypos >= y_lo ) && ( ypos <= y_hi )  )
			      {
				*search_gadget = gadget;
				return ( TRUE );
			      }
			  }

			start_index = end_index + 1;
			end_index = start_index;
		      }
		  }
	      }

	    break;

	  default:

	    if ( _FI_generic_find_gadget ( gadget, xpos, ypos ))
	      {
		*search_gadget = gadget;
		return ( TRUE );
	      }
	    break;
	}
    }
  return ( FALSE );
}



int _FI_g_get_dsize (struct FIgadget_obj *gadget,
                     double              *xsize,
                     double              *ysize)
{
  if ( gadget->FIgadget.type == FI_CHECKLIST )
    {
      int xlo, ylo, xhi, yhi;

      _FI_cklst_get_area ( (struct FIcklst_obj *) gadget,
					 &xlo, &ylo, &xhi, &yhi );
      *xsize = xhi - xlo;
      *ysize = yhi - ylo;
    }
  else
    {
      if ( gadget->FIgadget.type == FI_GROUP )
	{
          /* Calculate the size of the group first */

	  _FI_grp_calculate_size ( (struct FIgroup_obj *) gadget );
	}

     *xsize = gadget->FIgadget.xhi - gadget->FIgadget.xlo;
     *ysize = gadget->FIgadget.yhi - gadget->FIgadget.ylo;
    }

  return ( FI_SUCCESS );
}



/* This function returns the size of the gadget */

int _FI_g_get_size (struct FIgadget_obj *gadget,
                    int                 *xsize,
                    int                 *ysize)
{
  int status = FI_SUCCESS;

  double dxsize;
  double dysize;

  status = _FI_g_get_dsize ( gadget, &dxsize, &dysize );

  *xsize = dxsize;
  *ysize = dysize;

  return ( status );
}








int _FI_g_find_parent_gadget (struct FIgroup_obj * group, int xpos, int ypos, struct FIgadget_obj ** search_gadget)
{
  struct FIgadget_obj * gadget;
  int    ii, zz, qq;
  int    multi_line_text;
  int    start_index, end_index;
  char   t_str[500];
  int    ht, wd, ls;
  int    x_lo, x_hi, y_lo, y_hi;
  int    status;

  for ( ii = 0; ii < (int) group->FIgroup.size ; ii++ )
    {
      gadget = group->FIgroup.gadgets[ii];

  	    /*** skip entries that aren't valid ***/
  	    
      if ( ! gadget )
	{
	  continue;
	}

      switch ( gadget->FIgadget.type )
	{
		/* 					    */
		/* The code for enable ignore these gadgets */
		/* line, bezel, rect			    */
		/*					    */

		/* These gadgets cannot be located */
		/*  because we would have to add an */
		/*  algorithm to detect points on a */
		/*  line and on edge of rect.       */

	  case FI_LINE:
	  case FI_BEZEL:
	    continue;

	  case FI_GROUP:		

	    if ( ! ( (struct FIgroup_obj *) 
				gadget)->FIgroup.dont_pass_on )
	      {
		if ( _FI_g_find_gadget ( (struct FIgroup_obj *) gadget,
					xpos, ypos, search_gadget ) )
		  {
		    return ( TRUE );
		  }
	        else
		  {
		    continue;
		  }
	      }
	    else
	      {
		continue;
	      }

	  case FI_RECT:

		    /*** If the rectangle is not a 		***/
		    /***   FILLED rectangle then continue	***/

	    if ( gadget->FIgadget.effect != FI_FILLED )
	      {
		continue;
	      }

 	    if (  _FI_generic_find_gadget ( gadget, xpos, ypos ) )
	      {
		    *search_gadget = gadget;
		    return ( TRUE );
	      }
	    else
	      {
		  continue;
	      }

	  case FI_CHECKLIST:

	    if ( _FI_cklst_find_gadget ( (struct FIcklst_obj *)gadget, xpos, ypos, 
						search_gadget ) )
	      {
		return ( TRUE );
	      }
	    else
	      {
		continue;
	      }
			
	  case FI_FIELD:

	    if ( _FI_fld_find_gadget ( (struct FIfld_obj *) gadget, xpos, ypos,
						search_gadget ) )
	      {
			/* set to parent field, not field member like scroll bar */
			*search_gadget = gadget;
		return ( TRUE );
	      }
	    else
	      {
		continue;
	      }

	  case FI_MULTI_COL:

	    if (  _FI_mcf_find_gadget ( (struct FImcf_obj *)gadget, xpos, ypos,
						search_gadget ) )
	      {
			/* set to parent MCF, not MCF member like scroll bar */
			*search_gadget = gadget;
		return ( TRUE );
	      }
	    else
	      {
		continue;
	      }

          case FI_TEXT:

            if (gadget->FIgadget.text[0] == '\0')     /* NULL string */
	      {
		break;
	      }

                /******************************************************/
                /*                                                    */
                /* This routine checks to see if the datapoint falls  */
                /* within a rectangle defined by the number of lines  */
                /* by the length of the longest line.  Thus it is too */
                /* coarse to be used for multi-line text by itself.   */
                /*                                                    */
                /******************************************************/

	    status = _FI_generic_find_gadget ( gadget, xpos, ypos );

            if (status)
              {
                   /*************************************************/
                   /*                                               */
                   /*  First check to see if it is multi-line text  */
                   /*  Counter variable is incremented once for     */
                   /*  each carriage return that is found.          */
                   /*                                               */
                   /*************************************************/

		multi_line_text = 0;

                for (zz = 0; zz < strlen ((char *)gadget->FIgadget.text); zz++)
                  {
                    if (gadget->FIgadget.text[zz] == '\n')
		      {
                         multi_line_text++;
		      }
                  }

			 /* if single line handle normally */

                if ( multi_line_text == 0 )
                  {
	            *search_gadget = gadget;
		    return ( TRUE );
                  }
                else
                  {
                    start_index = 0;
                    end_index = 0;

                    /**************************************************/
                    /*                                                */
                    /* For each line of text, parse the line of text  */
                    /* into the variable t_str.  Then determine its   */
                    /* width using the FI_calc_text function.  The y  */
                    /* position of each line is fixed and can be      */
                    /* calculated using the ls (line spacing)         */
		    /* variable.                   		      */
                    /*                                                */
                    /* The X position of the text on a particular     */
                    /* line can vary due to its justification.  If    */
                    /* the text is left justified, then each line of  */
                    /* text will be located beginning at the xlo for  */
                    /* the text gadget.                               */
                    /*                                                */
                    /* If the text is right justified, then the end   */
                    /* of the text will be flush with the xhi of the  */
                    /* text.  The value for xhi is equal to the       */
                    /* longest string in the multi-line string.       */
                    /*                                                */
                    /* If the text is center justified, you must      */
                    /* subtract the width of the current line from    */
                    /* the length of the longest line (which happens  */
                    /* to be the width of the text gadget).  This     */
                    /* value must be divided by 2 so that an equal    */
                    /* amount of space can be found on either side of */
		    /* the text.  Thus the line begins at             */
                    /* xlo + the calculated value.                    */
                    /*                                                */
                    /*                    GMD 1/28/91                 */
                    /*                                                */
                    /**************************************************/

                    for ( zz = 0; zz <= multi_line_text; zz++ )
                      {
			while ((gadget->FIgadget.text[end_index] != '\n') &&
                               (gadget->FIgadget.text[end_index] != '\0'))
			  {
                            end_index++;
			  }

                        t_str[0] = 0;
                        for (qq = 0; qq < end_index - start_index; qq++)
			  {
                            t_str[qq] =
				gadget->FIgadget.text[start_index + qq];
			  }
                        t_str[qq] = 0;

                        if (strlen (t_str) > 0)
			  {
                            FI_calc_text ( gadget->FIgadget.font_id,
					  t_str,
                                          strlen (t_str), &ht, &wd, &ls,
                                          gadget->FIgadget.font_type);

                            y_lo = (ls * zz) +
					(int) gadget->FIgadget.ylo;

                            y_hi = y_lo + ls;

                            if ( gadget->FIgadget.justification ==
						 FI_LEFT_JUSTIFIED )
                              {
                                x_lo = (int) gadget->FIgadget.xlo;
                                x_hi = x_lo + wd;
                              }
                            else if ( gadget->FIgadget.justification ==
						FI_RIGHT_JUSTIFIED )
                              {
                                x_hi = (int) gadget->FIgadget.xhi;
                                x_lo = x_hi - wd;
                              }
                            else   /* FI_CENTER_JUSTIFIED) */
                              {
				x_lo = (int)
				  ( (int)gadget->FIgadget.xhi +
				  (int)gadget->FIgadget.xlo - wd ) / 2 ;

                                x_hi = x_lo + wd;
                              }

                            if ((xpos >= x_lo) && (xpos <= x_hi) &&
                                (ypos >= y_lo) && (ypos <= y_hi))
                              {
                                *search_gadget = gadget;
                                return (TRUE);
                              }   
			  }

                         start_index = end_index + 1;
                         end_index = start_index;
                      }
                   }
                }

                break;

	  default:
		if (  _FI_generic_find_gadget ( gadget, xpos, ypos ) )
		  {
			*search_gadget = gadget;
			return ( TRUE );
		  }
	}
    }
  return  ( FALSE );
}



