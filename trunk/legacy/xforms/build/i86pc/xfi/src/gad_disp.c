#include "FImin.h"

#include "FIscroll.h"
#include "FIbtn.h"
#include "FIfield.h"
#include "FImcf.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

static int ( *branch_table_display[] ) () =
{
  NULL,
  _FI_sld_display,
  _FI_tog_display,
  _FI_fld_display,
  _FI_cklst_display,
  _FI_dial_display,
  _FI_txt_display,
  _FI_btn_display,
  _FI_line_display,
  _FI_gauge_display,
  _FI_rect_display,
  _FI_sym_display,
  _FI_scrl_display,
  _FI_mcf_display,
  _FI_bezel_display
};


static int ( *branch_table_erase[] ) () =
{
  NULL,
  _FI_sld_erase,
  _FI_generic_erase,
  _FI_fld_erase,
  _FI_cklst_erase,
  _FI_generic_erase,
  _FI_txt_erase,
  _FI_generic_erase,
  _FI_line_erase,
  _FI_gauge_erase,
  _FI_rect_erase,
  _FI_sym_erase,
  _FI_scrl_erase,
  _FI_mcf_erase,
  _FI_generic_erase
};


/*** X11 - This variable was added, because many of the gadgets ***/
/*** were forced to be displayed even though it was in a group. ***/
/*** This caused too many calls to XFlush () and other redundant ***/
/*** calls.  Since the calls are recursive, this static variable ***/
/*** needed to be added.

static int _FI_dont_flush;                Global now
******************************************************************/


/* DISPLAY */

int _FI_g_display (struct FIgadget_obj *gadget,
                   Window               window)
{
  int type = gadget->FIgadget.type;

  if ( ( type != FI_GROUP ) && ( IT_IS_NOT_DISPLAYABLE ( gadget )))
    {
      return ( FI_SUCCESS );
    }

	/* Do not set a group to be displayed */

  if ( type != FI_GROUP )
    {
      gadget->FIgadget.displayed = TRUE;
    }

  if (( window == None ) || ( gadget->FIgadget.form->displayed == 0 ))
    {
      return ( FI_SUCCESS );
    }

  if ( type == FI_GROUP )
    {
      _FI_dont_flush++;
      _FI_grp_pass_on_id_int ( gadget, _FI_g_display, window, 0 );
      _FI_dont_flush--;
    }
  else
    {
	/* The third argument is a complete display flag */
	/* Checklist uses it currently.			 */

	  /*****************************************************/
	  /* sml:07-23-94:TR249401238:                           */
	  /*  if a MCF, adjust its cols to squeeze out excess    */
	  /*  space.  Do this here instead of                    */
	  /*  _FI_g_set_displayable, because _FI_g_display is    */
	  /*  often called without calling _FI_g_set_displayable */
	  /*  and the space isn't squeezed out unless the        */
	  /*  application programmer specifically calls          */
	  /*  FIg_display, which may not occur.                  */
	  /*******************************************************/

	  if (type == FI_MULTI_COL)
	  {
		_FI_mcf_adjust_cols((struct FImcf_obj *)gadget);
 	  }
	  /* end of fix for TR249401238 */
      branch_table_display[type] ( gadget, window, 1 );
    }

	/*** X11-Added this '_FI_dont_flush' variable because	***/
	/*** we only want to flush once per group.		***/

  if ( ! _FI_dont_flush )
    {
      XFlush ( _FI_display );
    }

  return ( FI_SUCCESS );
}


int _FI_g_set_displayable (struct FIgadget_obj *gadget)
{
  switch ( gadget->FIgadget.type )
    {
      case FI_FIELD:
	{
	  struct FIfld_obj *field;

	  field = (struct FIfld_obj *) gadget;

	  if (	( field->FIgadget.label > 0 )			||
		 field->FIfield.flags.is_a_col	 		||
		( field->FIfield.flags.is_a_list	 &&
		 ( !((struct FIfld_obj *) field->FIgadget.user_pointer )
				->FIfield.flags.popup_list ))	 )
	    {
		field->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;
	    }

	  if ( field->FIfield.list_id			  &&
		 ! field->FIfield.flags.popup_list 	   )
	    {
	      field->FIfield.list_id->FIgadget.attr_mask &=
						 ~ FI_NOT_DISPLAYED;
	    }
	}
      break;

  case FI_GROUP:
      _FI_grp_pass_on_id_int ( gadget, _FI_g_set_displayable, 0, 0 );
      break;

  case FI_MULTI_COL:
      gadget->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;

	  /*****************************************************/
	  /* sml:07-23-94:TR249401238:                           */
	  /*  Don't call this here.  Call it in _FI_g_display    */
	  /*  because _FI_g_display is                           */
	  /*  often called without calling _FI_g_set_displayable */
	  /*  and the space isn't squeezed out unless the        */
	  /*  application programmer specifically calls          */
	  /*  FIg_display, which may not occur.                  */
	  /*******************************************************/

/*****      _FI_mcf_adjust_cols ( (struct FImcf_obj *)gadget ); ****/
      break;

  default:
      gadget->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;
      break;
    }
  return ( FI_SUCCESS );
}


int _FI_g_erase (struct FIgadget_obj *gadget)
{
  Window window = XWINDOW ( gadget );
  int type = gadget->FIgadget.type;

  if ( type == FI_GROUP )
    {
      _FI_dont_flush++;
      _FI_grp_pass_on_id_int ( gadget, _FI_g_erase, 0, 0 );
      _FI_dont_flush--;
    }
  else
    {
      if ( IT_IS_NOT_DISPLAYED ( gadget ))
	{
	  gadget->FIgadget.attr_mask |= FI_NOT_DISPLAYED;

		/*** Code to set display bits to off in gadgets ***/
		/*** belonging to parent gadgets. KLUDGE	***/

	  if ( type == FI_MULTI_COL )
	    {
	      struct FImcf_obj *mcfield = (struct FImcf_obj *) gadget;

	      _FI_grp_pass_on_id_int ( (struct FIgadget_obj *) mcfield,
						 _FI_g_erase, 0, 0 );

	      if ( mcfield->FImcf.vscrl_id )
		{
		  _FI_g_erase ( (struct FIgadget_obj *)
					 mcfield->FImcf.vscrl_id );
		}

	      if ( mcfield->FImcf.hscrl_id )
		{
		   _FI_g_erase ( (struct FIgadget_obj *)
					 mcfield->FImcf.hscrl_id );
		}
	    }
	  else if ( type == FI_FIELD )
	    {
	      struct FIfld_obj *field = (struct FIfld_obj *) gadget;

	      if ( field->FIfield.list_id )
		{
		  _FI_g_erase ( (struct FIgadget_obj *)
					 field->FIfield.list_id );
		}

	      if ( field->FIfield.flags.draw_vscrl	&&
					 field->FIfield.vscrl_id )
		{
		  _FI_g_erase ( (struct FIgadget_obj *)
					 field->FIfield.vscrl_id );
		}

	      if ( field->FIfield.flags.draw_hscrl	&&
						 field->FIfield.hscrl )
		{
		   _FI_g_erase ( (struct FIgadget_obj *)
					 field->FIfield.hscrl[0]);

		   _FI_g_erase ( (struct FIgadget_obj *)
					 field->FIfield.hscrl[1]);
		}
	    }
	  else if ( type == FI_SCROLL )
	    {
	      struct FIscrl_obj *scroll = (struct FIscrl_obj *) gadget;

	      _FI_g_erase ( (struct FIgadget_obj *)
					scroll->FIscroll.puck );

	      _FI_g_erase ( (struct FIgadget_obj *)
					scroll->FIscroll.btns[0]);

	      _FI_g_erase ( (struct FIgadget_obj *)
					scroll->FIscroll.btns[1]);

	      _FI_g_erase ( (struct FIgadget_obj *)
					scroll->FIscroll.btns[2]);

	      _FI_g_erase ( (struct FIgadget_obj *)
					scroll->FIscroll.btns[3]);
	    }

	  return ( FI_SUCCESS );
	}

	/* If the form is displayed and the gadget's mask	*/
	/* is set to displayed then erase.			*/

	/* CHUNN added check for not displayed */

      if ( ( window != None )		 		&&
	   gadget->FIgadget.form->displayed		&&
	   ( IT_IS_DISPLAYABLE ( gadget ))		 )
	{
	  XSetForeground ( _FI_display, _FI_gc,
		FI_translate_color ( XSCREEN (gadget),
					ERASE_COLOR (gadget)) );

	  branch_table_erase[type] ( gadget, window );

		/*** X11-Added '_FI_dont_flush' variable because  ***/
		/*** we only want to flush once per group.	  ***/

	  if ( ! _FI_dont_flush )
	    {
	      XFlush ( _FI_display );
	    }
	}
    }

	/* After the erase */

  gadget->FIgadget.attr_mask |= FI_NOT_DISPLAYED;
  gadget->FIgadget.displayed = FALSE;

  return ( FI_SUCCESS );
}


int _FI_g_hilite (struct FIgadget_obj *gadget)
{
  Window window = XWINDOW ( gadget );
  int type = gadget->FIgadget.type;
  int ii;

  if ( type == FI_GROUP )
    {
      _FI_dont_flush++;
      _FI_grp_pass_on_id_int ( gadget, _FI_g_hilite, 0, 0 );
      _FI_dont_flush--;
    }
  else
    {
      if ( IT_IS_HILITED ( gadget ))
	{
	  return ( FI_SUCCESS );
	}

      gadget->FIgadget.attr_mask |= FI_HILITED;

      switch ( type )
	{
	  case FI_MULTI_COL:
		 _FI_dont_flush++;
		 _FI_mcf_hilite ( (struct FImcf_obj *)gadget );
		 _FI_dont_flush--;
		 break;

	  case FI_FIELD:
		 _FI_dont_flush++;
		 _FI_fld_hilite ( (struct FIfld_obj *) gadget );
		 _FI_dont_flush--;
		 break;

	  case FI_SCROLL:

	    /********************************************************
	    _FI_g_hilite (((struct FIscrl_obj *)gadget)->FIscroll.puck);
	    for ( ii = 0; ii < 4; ii++ )
	      {
		_FI_g_hilite (((struct FIscrl_obj *) gadget )
						->FIscroll.btns[i]);
	      }
	    ********************************************************/

	    ( (struct FIscrl_obj *) gadget )->FIscroll.puck->
				FIgadget.attr_mask |= FI_HILITED;

	    for ( ii = 0; ii < 4; ii++ )
	      {
		((struct FIscrl_obj *) gadget )->FIscroll.btns[ii]->
				FIgadget.attr_mask |= FI_HILITED;
	      }
	}
    }

  if (	( window != None )			&&
	 gadget->FIgadget.form->displayed	&&
	 ( ! _FI_dont_flush )			 )
    {
      _FI_g_display ( gadget, window );
    }

  return ( FI_SUCCESS );
}


int _FI_g_unhilite (struct FIgadget_obj *gadget)
{
  Window window = XWINDOW ( gadget );
  int type = gadget->FIgadget.type;
  int ii;

  if ( type == FI_GROUP )
    {
      _FI_dont_flush++;
      _FI_grp_pass_on_id_int ( gadget, _FI_g_unhilite, 0, 0 );
      _FI_dont_flush--;
    }
  else
    {
      if ( ! ( IT_IS_HILITED ( gadget )))
	{
	  return ( FI_SUCCESS );
	}

      gadget->FIgadget.attr_mask &= ~ FI_HILITED;

      switch ( type )
	{
	  case FI_MULTI_COL:
		 _FI_dont_flush++;
		 _FI_mcf_unhilite ( (struct FImcf_obj *) gadget );
		 _FI_dont_flush--;
		 break;

	  case FI_FIELD:
		 _FI_dont_flush++;
		 _FI_fld_unhilite ( (struct FIfld_obj *)gadget );
		 _FI_dont_flush--;
		 break;

	  case FI_SCROLL:

	    /********************************************************
	    _FI_g_unhilite (((struct FIscrl_obj *)gadget)->
							FIscroll.puck);
	    for ( ii = 0; ii < 4; ii++ )
	      {
		_FI_g_unhilite (((struct FIscrl_obj *) gadget )
						->FIscroll.btns[i]);
	      }
	    ********************************************************/

	    ((struct FIscrl_obj *) gadget )->FIscroll.puck->
				FIgadget.attr_mask &= ~ FI_HILITED;

	    for ( ii = 0; ii < 4; ii++ )
	      {
		( (struct FIscrl_obj *) gadget )->FIscroll.btns[ii]->
				FIgadget.attr_mask &= ~ FI_HILITED;
	      }
	}
    }

  if ( ( window != None )			&&
	 gadget->FIgadget.form->displayed	&&
	 ( ! _FI_dont_flush )			 )
    {
      _FI_g_display ( gadget, window );
    }

  return ( FI_SUCCESS );

}


int _FI_g_disable (struct FIgadget_obj *gadget)
{
  Window window = XWINDOW ( gadget );
  int type = gadget->FIgadget.type;
  int ii;

  if ( type == FI_GROUP )
    {
      _FI_dont_flush++;
      _FI_grp_pass_on_id_int ( gadget, _FI_g_disable, 0, 0 );
      _FI_dont_flush--;
    }
  else
    {
      if ( IT_IS_DISABLED ( gadget ))
		 return ( FI_SUCCESS );

      gadget->FIgadget.attr_mask |= FI_NOT_ENABLED;

      switch ( type )
	{
	  case FI_MULTI_COL:
		 _FI_dont_flush++;
		 _FI_mcf_disable ( (struct FImcf_obj *)gadget );
		 _FI_dont_flush--;
		 break;

		/*** The code for enable ignores these gadgets	***/
	        /*** line, bezel, rect 				***/

	  case FI_BEZEL:
	  case FI_LINE:
	  case FI_RECT:
	    return ( FI_SUCCESS );

	  case FI_FIELD:
		 _FI_dont_flush++;
		 _FI_fld_disable ( (struct FIfld_obj *) gadget );
		 _FI_dont_flush--;
		 break;

	  case FI_SCROLL:

	    /********************************************************
	    _FI_g_disable(((struct FIscrl_obj *)gadget)->FIscroll.puck);
	    for ( ii = 0; ii < 4; ii++ )
	      {
		_FI_g_disable (((struct FIscrl_obj *) gadget )
						->FIscroll.btns[i]);
	      }
	    ********************************************************/

	    ( (struct FIscrl_obj *) gadget )->FIscroll.puck->
				FIgadget.attr_mask |= FI_NOT_ENABLED;

	    for ( ii = 0; ii < 4; ii++ )
	      {
		( (struct FIscrl_obj *) gadget )->FIscroll.btns[ii]->
				FIgadget.attr_mask |= FI_NOT_ENABLED;
	      }
	}
    }

  if ( ( window != None )			&&
	gadget->FIgadget.form->displayed	&&
	( ! _FI_dont_flush )			 )
    {
      _FI_g_display ( gadget, window );
    }

  return ( FI_SUCCESS );
}


int _FI_g_enable (struct FIgadget_obj *gadget)
{
  Window window = XWINDOW ( gadget );
  int type = gadget->FIgadget.type;
  int ii;

  if ( type == FI_GROUP )
    {
      _FI_dont_flush++;
      _FI_grp_pass_on_id_int ( gadget, _FI_g_enable, 0, 0 );
      _FI_dont_flush--;
    }
  else
    {
      if ( ! ( IT_IS_DISABLED ( gadget )))
	{
	  return ( FI_SUCCESS );
	}

      gadget->FIgadget.attr_mask &= ~ FI_NOT_ENABLED;

      switch ( type )
	{
	  case FI_MULTI_COL:
		 _FI_dont_flush++;
		 _FI_mcf_enable ( (struct FImcf_obj *)gadget );
		 _FI_dont_flush--;
		 break;

	  case FI_FIELD:
		 _FI_dont_flush++;
		 _FI_fld_enable ( (struct FIfld_obj *) gadget );
		 _FI_dont_flush--;
		 break;

	  case FI_SCROLL:

	    /********************************************************
	    _FI_g_enable (((struct FIscrl_obj *)gadget)->FIscroll.puck);
	    for ( ii = 0; ii < 4; ii++ )
	      {
		_FI_g_enable (((struct FIscrl_obj *) gadget )
						->FIscroll.btns[i]);
	      }
	    ********************************************************/

	    ( (struct FIscrl_obj *) gadget )->FIscroll.puck->
			FIgadget.attr_mask &= ~ FI_NOT_ENABLED;

	    for ( ii = 0; ii < 4; ii++ )
	      {
		( (struct FIscrl_obj *) gadget )->FIscroll.btns[ii]->
				FIgadget.attr_mask &= ~ FI_NOT_ENABLED;
	      }
	}
    }

  if ( ( window != None )			&&
	 gadget->FIgadget.form->displayed	&&
	 ( ! _FI_dont_flush )			 )
    {
      _FI_g_display ( gadget, window );
    }

  return ( FI_SUCCESS );
}


/******************************************************************/
/*** Kludge to make gadget's on color show up against gadget's	***/
/*** off color on 2- and 4-color screens. -JAJ:11/16/90		***/
/******************************************************************/

/* ARGSUSED */
int _FI_g_find_contrasting_on_color (int screen,
                                     int translated_on_color,
                                     int translated_form_bg_color)
{
  /*****************************************************************

  if ( ! FI_using_SR_vlt && _FI_info[vs].vsi_VLT_size < 16 )
    {
	   / *** Need to find an ON color different *** /
	   / *** from erase color *** /

      for ( ii = 0;
	   ( translated_on_color == translated_form_bg_color ) &&
	   ( ii < 14 ) ; ii ++ )
	{
	  translated_on_color = FI_translate_color ( vs, ii );
	}

      if ( translated_on_color == translated_form_bg_color )
	{
	   / *** VLT slot 0 is always some "dark" color *** /
	   translated_on_color = 0;
	}

      if ( translated_on_color == translated_form_bg_color )
	{
	   / *** highest VLT slot # is always some "bright" color *** /
	  translated_on_color = _FI_info[vs].vsi_VLT_size - 1 ;
	}
    }
  *********************************************************************/


  /* Don't know how to handle this in the X world, so I am returning */
  /* the same value that was passed in for now. */

  return ( translated_on_color );
}
