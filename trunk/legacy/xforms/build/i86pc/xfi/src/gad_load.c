#include "FImin.h"


#include "FIbtn.h"
#include "FItog.h"
#include "FIgraphic.h"
#include "FIrect.h"
#include "FIline.h"
#include "FIdial.h"
#include "FItext.h"
#include "FIgauge.h"
#include "FIscroll.h"
#include "FIslider.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"


void _FI_read_hooks (struct FIgadget_obj *gadget)
{
  int value;
  int hook = 1;

	/*** If the justification never gets read in, then	***/
	/*** set the justification to FI_CENTER_JUSTIFIED for	***/
	/*** buttons and toggles.				***/

  while ( hook )
    {
      hook = _FI_read_short ();

	/* The size of the hook can be determined by taking
	the one's place integer portion and comparing with 
	the chart below:

		     1, 2	- Double
		     3, 4, 5	- Integer
		     6, 7	- Short
		     8, 9	- Char
	*****************************************************/

      switch ( hook )
	{
	  case 0:
	    break;

	  case 1:	/* INCREMENT */

		/* Load in increment for gadget */
		/* Used for sliders and dials */

	    ((struct FIdial_obj *) gadget )->FIrange.increment =
						 _FI_read_double ();
	    break;


	  case 8:	/* OPPOSITE_DIRECTION */

	    ((struct FIsld_obj *) gadget )->FIrange.display_mask |=
							 FI_MAX_MIN;
	    break;


	  case 9:	/* JUSTIFICATION */

	    gadget->FIgadget.justification = _FI_read_char ();
	    break;


	  case 18:	/* ERASE COLOR */

	    gadget->FIgadget.erase_color = _FI_read_char ();
	    break;

	  default:

		/* Load in the hook based on the number */

	    value = hook % 10;

	    if ( value > 7 )	/* Character */
	      {
		_FI_read_char ();
	      }
	    else if ( value > 5 )	/* Short */
	      {
		_FI_read_short ();
	      }
	    else if ( value > 2 )	/* Integer */
	      {
		_FI_read_int ();
	      }
	    else	/* Double */
	      {
		_FI_read_double ();
	      }
	}
    }
}


void _FI_g_load (struct FIgadget_obj *gadget,
                 int                  form_version,
                 int                  gadget_version)
{
  int		type = gadget->FIgadget.type;
  int		menu_button;
  struct FIdial_obj * dial;

	/* With version 4 of the form 1.0.0.11		*/
	/* the 20 bytes were changed to 2 hook bytes.	*/

  if ( form_version == 3 )
    {
      _FI_read_double ();
      _FI_read_double ();
      _FI_read_int ();
    }
  else
    {
	/* Check the hook to see what to load in */

      _FI_read_hooks ( gadget );
    }


	/* Load common instance */

  if ( form_version >= 5 )	/*** JAJ:09/29/90 ***/
    {
      gadget->FIgadget.pass_label = _FI_read_int ();
    }
  else
    {
      gadget->FIgadget.pass_label = (int) _FI_read_short ();
    }

  if ( gadget->FIgadget.pass_label == 14648 )
    {
      gadget->FIgadget.pass_label = -1;
    }

  if ( form_version >= 5 )	/*** JAJ:09/29/90 ***/
    {
      gadget->FIgadget.next_in_seq = _FI_read_int ();
    }
  else
    {
      gadget->FIgadget.next_in_seq = (int) _FI_read_short ();
    }

	/* IF flag is set then a menu button */

	/* Load in the instance to see if the gadget is	 */
	/* a menu button.				 */

  menu_button = _FI_read_short ();

  gadget->FIgadget.xlo = _FI_read_short ();
  gadget->FIgadget.ylo = _FI_read_short ();
  gadget->FIgadget.xhi = _FI_read_short ();
  gadget->FIgadget.yhi = _FI_read_short ();

  gadget->FIgadget.orig_xsize = _FI_read_short ();
  gadget->FIgadget.orig_ysize = _FI_read_short ();

  gadget->FIgadget.default_attr_mask =
			gadget->FIgadget.attr_mask = _FI_read_int ();

  gadget->FIgadget.default_value =
			gadget->FIgadget.value = _FI_read_double ();

  gadget->FIgadget.bodysize = _FI_read_short ();

  gadget->FIgadget.sym_width_scale_factor	= _FI_read_short ();
  gadget->FIgadget.sym_height_scale_factor	= _FI_read_short ();

  gadget->FIgadget.text = ( unsigned char *) _FI_reada_string ();

  gadget->FIgadget.help_topic	= _FI_reada_string ();
  gadget->FIgadget.command	= _FI_reada_string ();
  gadget->FIgadget.fontname	= _FI_reada_string ();

  gadget->FIgadget.symbol_ptr.sym_index = _FI_read_char ();
  gadget->FIgadget.on_symbol_ptr.sym_index = _FI_read_char ();

  gadget->FIgadget.off_color	= _FI_read_char ();
  gadget->FIgadget.on_color	= _FI_read_char ();
  gadget->FIgadget.off_color2	= _FI_read_char ();
  gadget->FIgadget.on_color2	= _FI_read_char ();

  gadget->FIgadget.effect	= _FI_read_char ();


		/* Other assignments */

  /* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

  gadget->FIgadget.text_length = FI_strlen ( (char *)gadget->FIgadget.text,
					gadget->FIgadget.font_type );

	/* load specific instance */

  switch ( type )
    {
      case FI_TEXT:

		/* LOAD FUTURE INSTANCE FOR ROTATED AND SPACED TEXT */

      _FI_read_short ();	/* >>>NOT USED<<< WAS BODYWIDTH */

      ((struct FItext_obj *) gadget)->FItext.rotation =
						_FI_read_short ();

      ((struct FItext_obj *) gadget)->FItext.spacing =
						_FI_read_short ();

      gadget->FIgadget.justification = _FI_read_char ();
      break;

  case FI_FIELD:
      _FI_fld_load ( (struct FIfld_obj *)gadget, form_version );
      break;

  case FI_BUTTON:

      ((struct FIbtn_obj *) gadget )->FIbtn.auto_pop_up =
						 _FI_read_char ();

      if ( menu_button )
	{
		/* Read palette name for gadget */

	 ((struct FIbtn_obj *) gadget )->FIbtn.menu_button = 1;

	 ((struct FIbtn_obj *) gadget )->FIbtn.palette =
						_FI_reada_string ();
	}
      break;

  case FI_RECT:

      ((struct FIrect_obj *) gadget )->FIgraphic.line_weight =
						    _FI_read_char ();

      ((struct FIline_obj *) gadget )->FIgraphic.line_style =
						    _FI_read_short ();

      _FI_graphic_activate ( & (((struct FIline_obj *) gadget )->
							FIgraphic ));
      break;

  case FI_LINE:

      ((struct FIline_obj *) gadget )->FIgraphic.line_weight =
						_FI_read_char ();

      ((struct FIline_obj *) gadget )->FIgraphic.line_style =
						 _FI_read_short ();

       /********************************************* JAJ:08/27/91 ****
       ((struct FIline_obj *) gadget )->FIline.num_vertices
                                                    = _FI_read_char ();
       ***************************************************************/

                               /*** JAJ:08/27/91                   ***/
       _FI_read_char ();        /*** num_vertices is no longer used ***/

      _FI_graphic_activate ( & (((struct FIline_obj *) gadget )->
							FIgraphic ));
      break;

  case FI_TOGGLE:

      if ( gadget->FIgadget.attr_mask & FI_TEXT_GADGET )
	{
	   ((struct FItog_obj *) gadget )->FItog.on_text =
			( unsigned char *) _FI_reada_string ();

        /* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

	   ((struct FItog_obj *) gadget )->FItog.on_text_length =
		 FI_strlen ( (char *)((struct FItog_obj *) gadget )->
			FItog.on_text, gadget->FIgadget.font_type );
	}
      break;

  case FI_SCROLL:

      ((struct FIscrl_obj *) gadget )->FIscroll.type =
						 _FI_read_char ();

      ((struct FIscrl_obj *) gadget )->FIscroll.view =
						 _FI_read_double ();

      ((struct FIscrl_obj *) gadget )->FIrange.high_value =
						 _FI_read_double ();

      ((struct FIscrl_obj *) gadget )->FIrange.low_value =
						 _FI_read_double ();
      break;

  case FI_GAUGE:

      ((struct FIgauge_obj *) gadget )->FIgauge.type = _FI_read_char ();

      ((struct FIgauge_obj *) gadget )->FIgauge.minor_increments =
						 _FI_read_double ();

      ((struct FIgauge_obj *) gadget )->FIrange.high_value =
						 _FI_read_double ();
      break;

  case FI_SLIDER:

	/* Sliders before version 5 had a on color of FI_YELLOW   */
	/* and the slider code ignored this and used FI_BLACK.    */
	/* With version 5, the slider's on color can be set in fb */ 

      if ( gadget_version < 5 )
	{
	  gadget->FIgadget.on_color = FI_BLACK;
	}

      ((struct FIsld_obj *) gadget )->FIslider.type = _FI_read_char ();

      ((struct FIsld_obj *) gadget )->FIrange.low_value =
						 _FI_read_double ();

      ((struct FIsld_obj *) gadget )->FIrange.high_value =
						 _FI_read_double ();

      ((struct FIsld_obj *) gadget )->FIrange.display_mask =
						 _FI_read_char ();

      ((struct FIsld_obj *) gadget )->FIrange.field_width =
						 _FI_read_char ();

      ((struct FIsld_obj *) gadget )->FIrange.decimal_accuracy =
						 _FI_read_char ();
      break;

  case FI_DIAL:

      dial = (struct FIdial_obj *) gadget;

      dial->FIdial.direction		= _FI_read_char ();
      dial->FIdial.offset		= _FI_read_double ();
      dial->FIdial.scale		= _FI_read_double ();
      dial->FIdial.minor_tick_inc	= _FI_read_short ();
      dial->FIdial.major_tick_inc	= _FI_read_short ();
      dial->FIrange.display_mask	= _FI_read_char ();
      dial->FIdial.border_style		= _FI_read_char ();
      dial->FIrange.field_width		= _FI_read_char ();
      dial->FIrange.decimal_accuracy	= _FI_read_char ();
      break;


  case FI_MULTI_COL:
      _FI_mcf_load ( (struct FImcf_obj *)gadget, form_version );
      break;
    }
}


void _FI_group_load (struct FIform_obj *form,
                     int                label,
                     int                to_grp_label,
                     int                form_version)
{
  int	ii;
  int	type;
  int	size;
  int	version;
  int	hook = 0;
  int	gad_label;
  struct FIgroup_obj *group;
  struct FIgadget_obj *gadget;


  group = (struct FIgroup_obj *) calloc ( 1,
					sizeof (struct FIgroup_obj ));

  size = _FI_read_short ();

  _FI_grp_alloc ( group, size );

  group->FIgroup.dont_pass_on = _FI_read_char ();
  group->FIgroup.single_select = _FI_read_char ();

	/* This changed with version 4 of the form ver 1.0.0.11 */

  if ( form_version == 3 )
    {
     /* Future 8 bytes */

      _FI_read_double ();
    }
  else
    {
      hook = _FI_read_short ();
    }

  group->FIgadget.label = label;
  group->FIgadget.form = form;
  group->FIgadget.type = FI_GROUP;

	/* Add the group to the group specified by to_grp_label */

  _FI_g_add_to_group ( (struct FIgadget_obj *)group, to_grp_label, 1 );

	/* read in gadgets in the group and add to group */

  for ( ii = 0; ii < size; ii++ )
    {
      type = _FI_read_short ();
      version = _FI_read_short ();


      if ( form_version >= 5 )	/*** JAJ:09/29/90 ***/
	{
	  gad_label = _FI_read_int ();
	}
      else
	{
	  gad_label = (int) _FI_read_short ();
	}

      if ( type == FI_GROUP )
	{
		/* Load in group "gad_label" and add to	*/
		/* group specified by "label".		*/

	  _FI_group_load ( form, gad_label, label, form_version );
	}
      else if ( ! _FI_g_new ( form, type, gad_label, &gadget ))
	{
	  _FI_g_load ( gadget, form_version, version );

		/* Add gadget to group specified by "label" */

	  _FI_g_add_to_group ( gadget, label, 0 );
	}
    }
}

