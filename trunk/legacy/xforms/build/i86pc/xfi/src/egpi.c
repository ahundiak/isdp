#include "FImin.h"

#include <math.h>
#include <values.h>   /* dmb:09/29/92: Added for M_PI in ANSI */
#include "FIdyn.h"
#include "FIgroup.h"
#include "FIbtn.h"
#include "FIfield.h"
#include "FIcklst.h"
#include "FIdial.h"
#include "FItog.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

int _FI_g_set_stan_vars (struct FIgadget_obj  *gadget,
                         struct standard_st   *str)
{
  int	dummy_int;
  float dummy_float;
  int	num_lines, width;

  float delta_y = 0;

  gadget->FIgadget.default_attr_mask =
		gadget->FIgadget.attr_mask = str->attr_mask;

  gadget->FIgadget.default_value =
		gadget->FIgadget.value = str->value;

  if ( gadget->FIgadget.type == FI_FIELD )
    {
      ((struct FIfld_obj *) gadget)->FIfield.prev_sel = -1;
    }

  if ( str->text )
    {
      _FI_s_rep ( (char **) &gadget->FIgadget.text, str->text );

      /*****************************************************/
      /* sml:01-27-94:NO TR (I/FORMS TR 249305159)         */
      /*  Combined 7/16 bit text isn't processed correctly */
      /*  because length is not being computed correctly.  */
      /*  Figure length after getting font_id and type.    */
      /*  Don't do it here.                                */
      /*****************************************************/
      /* gadget->FIgadget.text_length = strlen ( str->text );*/
    }

  if ( str->help_topic )
    {
      _FI_s_rep ( &gadget->FIgadget.help_topic, str->help_topic );
    }

  if ( str->command )
    {
      _FI_s_rep ( &gadget->FIgadget.command, str->command );
    }

  if ( str->fontname )
    {
      _FI_s_rep ( &gadget->FIgadget.fontname, str->fontname );
    }

  gadget->FIgadget.bodysize	= str->bodysize;
  gadget->FIgadget.user_pointer	= str->user_pointer;
  gadget->FIgadget.off_color	= str->off_color;
  gadget->FIgadget.on_color	= str->on_color;
  gadget->FIgadget.off_color2	= str->off_color2;
  gadget->FIgadget.on_color2	= str->on_color2;

  gadget->FIgadget.symbol_ptr.sym_index		= str->symbol_index;
  gadget->FIgadget.on_symbol_ptr.sym_index	= str->symbol_index2;

	/*** Set for dynamic creation because it will	***/
	/***  not be set unless read in from a file	***/

  gadget->FIgadget.sym_width_scale_factor	= 1.0;
  gadget->FIgadget.sym_height_scale_factor	= 1.0;

  gadget->FIgadget.next_in_seq = (int)str->next_in_seq;
  gadget->FIgadget.prev_in_seq = 0;


  /* GMD 8/30/90 Fix problem with FIg_get_font */

  /* dmb:10/05/92:Cast bodysize for ANSI */
  if ( gadget->FIgadget.type == FI_TEXT )
    {
      FI_find_font_id (   gadget->FIgadget.fontname,
			(double)gadget->FIgadget.bodysize,
			(Font *)& gadget->FIgadget.font_id,
			& dummy_float,
			  gadget->FIgadget.type,
			& gadget->FIgadget.font_type );


      /*****************************************************/
      /* sml:01-27-94:NO TR (I/FORMS TR 249305159)         */
      /*  Combined 7/16 bit text isn't processed correctly */
      /*  because length was not being computed correctly. */
      /*  Figure length after getting font_id and type.    */
      /*  Do it here.                                      */
      /*****************************************************/
      gadget->FIgadget.text_length = FI_strlen ( str->text, 
			gadget->FIgadget.font_type );

      FI_calc_text (	  gadget->FIgadget.font_id,
			(char *) gadget->FIgadget.text,
			  gadget->FIgadget.text_length,
			& gadget->FIgadget.font_height,
			& gadget->FIgadget.font_width,
			& dummy_int,
			  gadget->FIgadget.font_type );

      _FI_mlt_get_lines ( gadget->FIgadget.text,
			& num_lines,
			& width,
			  gadget->FIgadget.font_id,
			  gadget->FIgadget.font_type );

      gadget->FIgadget.orig_ysize = (float)
			(num_lines * gadget->FIgadget.font_height);
    }

  gadget->FIgadget.xlo = str->xlo;
  gadget->FIgadget.ylo = str->ylo;
  gadget->FIgadget.xhi = str->xhi;
  gadget->FIgadget.yhi = str->yhi;

  gadget->FIgadget.orig_xsize = (float)((short)str->xhi - (short)str->xlo);
  gadget->FIgadget.orig_ysize = (float)((short)str->yhi - (short)str->ylo);

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

	/* Adjust the delta_y if the symbol or text is larger than	*/
	/*  the box size					*/

	/* sml:10-04-93 box_size is set to BOX_SIZE in FIg_new */

	if ( y_offset > cklst->FIcklst.box_size )
    {
      delta_y = delta_y - 
					( cklst->FIcklst.box_size / 2 ) + ( y_offset / 2 );
    }
  }
	
  gadget->FIgadget.ylo += delta_y;
  gadget->FIgadget.yhi += delta_y;	







  gadget->FIgadget.orig_xsize = (float) ((float)(str->xhi) - (float)(str->xlo));
  gadget->FIgadget.orig_ysize = (float) ((float)(str->yhi) - (float)(str->ylo));

  return ( FI_SUCCESS );

}



int FIg_set_standard_variables (Form                 form,
                                int                  label,
                                struct standard_st  *str)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_id_int ( gadget, _FI_g_set_stan_vars,
						(int) str, 0 );
    }
  else
    {
      _FI_g_set_stan_vars ( gadget, str );
    }

  return ( FI_SUCCESS );
}



int FIg_get_line_depth (Form  form,
                        int   label,
                        int  *depth)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if (! gadget)
    {
      return ( FI_NO_SUCH_GADGET );
    }

  * depth = gadget->FIgadget.effect;

  return ( FI_SUCCESS );
}



int FIg_set_line_depth (Form  form,
                        int   label,
                        int   depth)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if (! gadget)
    {
      return ( FI_NO_SUCH_GADGET );
    }

  gadget->FIgadget.effect = depth;

  return ( FI_SUCCESS );
}



int FIg_activate (Form  form,
                  int   label)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
   {
      return ( FI_NO_SUCH_GADGET );
   }

  if ( gadget->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_id_int ( gadget, _FI_g_activate, 0, 0 );
    }
  else
    {
      _FI_g_activate ( gadget );
    }

  return ( FI_SUCCESS );
}



int FIg_set_state (Form  form,
                   int   label,
                   int   state)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  _FI_g_set_state ( gadget, state ? (double) 1.0 : (double) 0.0 );

  return ( FI_SUCCESS );
}



int FIg_get_size (Form  form,
                  int   label,
                  int  *xsize,
                  int  *ysize)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  return ( _FI_g_get_size ( gadget, xsize, ysize ) );
}



int FIg_get_dsize (Form     form,
                   int      label,
                   double  *xsize,
                   double  *ysize)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  return ( _FI_g_get_dsize ( gadget, xsize, ysize ) );
}



int FIg_set_size (Form  form,
                  int   label,
                  int   xsize,
                  int   ysize)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
   {
      return ( FI_NO_SUCH_GADGET );
   }

  gadget->FIgadget.xhi = gadget->FIgadget.xlo + xsize;
  gadget->FIgadget.yhi = gadget->FIgadget.ylo + ysize;

  if ( gadget->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_int ( gadget, FIg_set_size, xsize, ysize );
    }

  return ( FI_SUCCESS );
}



/* This function gets the location of the gadget on the form	*/
/* and stores it into double's instead of int's.		*/

int FIg_get_dlocation (Form     form,
                       int      label,
                       double  *xpos,
                       double  *ypos)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( gadget )
    {
      if (gadget->FIgadget.type == FI_GROUP)
	{
		/* Calculate the size of the group first */

	  _FI_grp_calculate_size ( (struct FIgroup_obj *) gadget);

	  *xpos = gadget->FIgadget.xlo;
	  *ypos = gadget->FIgadget.ylo;
	}
      else if (gadget->FIgadget.type == FI_CHECKLIST)
	{
	  int dummy1, dummy2;
	  int ixpos;
	  int iypos;

	  _FI_cklst_get_area ( (struct FIcklst_obj *)gadget, &ixpos, &iypos,
					&dummy1, &dummy2 );
	  *xpos = ixpos;
	  *ypos = iypos;
	}
      else
	{
	  *xpos = gadget->FIgadget.xlo;
	  *ypos = gadget->FIgadget.ylo;
	}

      return ( FI_SUCCESS );
    }
  else
    {
      return ( FI_NO_SUCH_GADGET );
    }
}



int FIg_get_location (Form  form,
                      int   label,
                      int  *xpos,
                      int  *ypos)
{
  int status;

  double dxpos;
  double dypos;

  status = FIg_get_dlocation ( form, label, &dxpos, &dypos );

  *xpos = (int) dxpos;
  *ypos = (int) dypos;

  return ( status );
}



/* This function returns the off color for the gadget */

int FIg_get_off_color (Form  form,
                       int   label,
                       int  *off_color)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( gadget )
    {
      *off_color = gadget->FIgadget.off_color;

      return ( FI_SUCCESS );
    }
  else
   {
      return ( FI_NO_SUCH_GADGET );
   }
}


/* This function returns the on color for the gadget */

int FIg_get_on_color (Form  form,
                      int   label,
                      int  *on_color)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( gadget )
    {
      *on_color = gadget->FIgadget.on_color;

      return ( FI_SUCCESS );
    }
  else
    {
      return ( FI_NO_SUCH_GADGET );
    }
}


int FIg_set_on_color (Form  form,
                      int   label,
                      int   on_color)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
   {
      return ( FI_NO_SUCH_GADGET );
   }

  if ( gadget->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_int ( gadget, FIg_set_on_color, on_color, 0 );
    }
  else if ( gadget->FIgadget.type == FI_MULTI_COL )
    {
      _FI_mcf_set_color ( (struct FImcf_obj *)gadget, on_color, 1 );
    }
  else
    {
      gadget->FIgadget.on_color = on_color;
    }

  return ( FI_SUCCESS );
}



int FIg_set_off_color (Form  form,
                       int   label,
                       int   off_color)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if (! gadget)
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_int ( gadget, FIg_set_off_color, off_color, 0 );
    }
  else if ( gadget->FIgadget.type == FI_MULTI_COL )
    {
      _FI_mcf_set_color ((struct FImcf_obj *)gadget, off_color, 0 );
    }
  else
    {
      gadget->FIgadget.off_color = off_color;
    }

  return ( FI_SUCCESS );
}


int FIg_set_color (Form  form,
                   int   label,
                   int   color)
{
  return ( FIg_set_off_color ( form, label, color) );
}



int FIg_get_color (Form  form,
                   int   label,
                   int  *color)
{
  return ( FIg_get_off_color ( form, label, color) );
}



int FIg_get_type (Form  form,
                  int   label,
                  int  *type)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  *type = gadget->FIgadget.type;

  return ( FI_SUCCESS );
}



/***********************************************************/
/* sml:09-27-93 added FIg_is_displayed  NO CR              */
/*              Code from Mike Mathis                      */
/***********************************************************/

int FIg_is_displayed ( Form form, int label, int *displayed )
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  *displayed = (int)gadget->FIgadget.displayed;

  return ( FI_SUCCESS );
}


int FIg_get_high_value (Form     form,
                        int      label,
                        double  *high_value)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_FIELD:
	*high_value = ((struct FIfld_obj *) gadget)->FIfield.max;
	break;

      case FI_DIAL:
	*high_value = ((struct FIdial_obj *) gadget)->FIdial.scale *
								TWO_PI;
	break;

      case FI_GAUGE:
      case FI_SLIDER:
      case FI_SCROLL:
	*high_value = gadget->FIrange.high_value;
	break;

      default:
        return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_get_low_value (Form    form,
                       int     label,
                       double *low_value)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_FIELD:
	*low_value = ((struct FIfld_obj *) gadget)->FIfield.min;
	break;

      case FI_DIAL:
      case FI_GAUGE:
      case FI_SLIDER:
      case FI_SCROLL:
	*low_value = gadget->FIrange.low_value;
	break;

      default:
        return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_set_high_value (Form    form,
                        int     label,
                        double  high_value)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_FIELD:
	((struct FIfld_obj *) gadget)->FIfield.max = high_value;
	break;

      case FI_DIAL:
	((struct FIdial_obj *) gadget)->FIdial.scale =
						high_value / TWO_PI;
	FIg_display ( form, label );
	break;

      case FI_GAUGE:
      case FI_SCROLL:
      case FI_SLIDER:

	gadget->FIrange.high_value = high_value;

	/* Adjust the value if needed */

	if ( gadget->FIgadget.value > high_value )
	  {
	    gadget->FIgadget.value = high_value;
	  }

	/* Activate sliders because max->min slider		*/
	/* need to be activate for set_value to work properly.	*/

	if ( gadget->FIgadget.type == FI_SLIDER )
	  {
	    _FI_g_activate ( gadget );
	  }
	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_set_low_value (Form    form,
                       int     label,
                       double  low_value)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if (! gadget)
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_FIELD:
	((struct FIfld_obj *) gadget)->FIfield.min = low_value;
	break;

      case FI_DIAL:
      case FI_GAUGE:
      case FI_SCROLL:
      case FI_SLIDER:

	gadget->FIrange.low_value = low_value;

	/* Adjust the value if needed */

	if ( gadget->FIgadget.value < low_value )
	  {
	    gadget->FIgadget.value = low_value;
	  }

	/* Activate sliders because max->min slider		*/
	/* need to be activate for set_value to work properly.	*/

	if ( gadget->FIgadget.type == FI_SLIDER )
	  {
	    _FI_g_activate ( gadget );
	  }
	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_get_attr (Form  form,
                  int   label,
                  int  *attr_mask)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( gadget )
    {
      * attr_mask = gadget->FIgadget.attr_mask;
      return ( FI_SUCCESS );
    }
  else
    {
      return ( FI_NO_SUCH_GADGET );
    }
}



int FIg_set_attr (Form  form,
                  int   label,
                  int   attr_mask)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_int ( gadget, FIg_set_attr, attr_mask, 0 );
    }
  else
    {
      gadget->FIgadget.attr_mask = attr_mask;

      if ( gadget->FIgadget.type == FI_MULTI_COL )
	{
	  /******************************************************/
	  /* sml:10-04-93 don't set non-visible cols of MCF on  */
      /*  (BORROWED FROM I/FORMS) NO TR                     */
	  /******************************************************/

		  /* Set not_displayed bit on for all columns */

	    _FI_grp_pass_on_int ( gadget, FIg_set_attr, 
				attr_mask | FI_NOT_DISPLAYED , 0 );


		  /* Set not_displayed bit bit off for visible columns 
			 if !FI_NOT_DISPLAYED.  There will probably be fewer
			 visible columns than non-visible ones in, say,
			 a 500-col field.
		  */

		if ( !(attr_mask & FI_NOT_DISPLAYED) )
		{
		  struct FImcf_obj *mcf = (struct FImcf_obj *) gadget;
		  int xx;
		  struct FIgadget_obj *field;

		  for ( xx = mcf->FImcf.col_off; 
					xx < (int) (mcf->FImcf.col_off + mcf->FImcf.nvcol);
						xx++)
		  {
			field = mcf->FIgroup.gadgets[xx];
			field->FIgadget.attr_mask &= ~FI_NOT_DISPLAYED;
		  } /* end for visible cols */

		} /* end if not_displayed bit is off */

	} /* if a MCF */
  } /* else not a FI_GROUP */

  return ( FI_SUCCESS );
}



int FIg_get_user_pointer (Form    form,
                          int     label,
                          char  **user_pointer)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  *user_pointer = gadget->FIgadget.user_pointer;

  return ( FI_SUCCESS );
}



int FIg_set_user_pointer (Form   form,
                          int    label,
                          char  *user_pointer)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_int ( gadget, FIg_set_user_pointer,
					(int) user_pointer, 0);
    }
  else
    {
      gadget->FIgadget.user_pointer = user_pointer;
    }

  return ( FI_SUCCESS );
}



int FIg_set_off_symbol_index (Form  form,
                              int   label,
                              int   sym_index)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  /***   being done in activate now   GMD 6/11/91  ***
  _FI_g_free_symbols ( gadget );
  ************************************************/

  gadget->FIgadget.symbol_ptr.sym_index = sym_index;

  _FI_g_activate ( gadget );

  return ( FI_SUCCESS );
}



int FIg_set_symbol_index (Form  form,
                          int   label,
                          int   sym_index)
{
  return ( FIg_set_off_symbol_index ( form, label, sym_index ) );
}



int FIg_set_on_symbol_index (Form  form,
                             int   label,
                             int   sym_index)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  /***   being done in activate now   GMD 6/11/91  ***
  _FI_g_free_symbols ( gadget );
  ************************************************/

  gadget->FIgadget.on_symbol_ptr.sym_index = sym_index;

  _FI_g_activate ( gadget );

  return ( FI_SUCCESS );
}



int FIg_get_off_symbol_index (Form  form,
                              int   label,
                              int  *sym_index)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  * sym_index = gadget->FIgadget.symbol_ptr.sym_index;

  return ( FI_SUCCESS );

}



int FIg_get_symbol_index (Form  form,
                          int   label,
                          int  *sym_index)
{
  return ( FIg_get_off_symbol_index ( form, label, sym_index ) );
}



int FIg_get_on_symbol_index (Form  form,
                             int   label,
                             int  *sym_index)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if (! gadget)
    {
      return ( FI_NO_SUCH_GADGET );
    }

  * sym_index = gadget->FIgadget.on_symbol_ptr.sym_index;

  return ( FI_SUCCESS );
}



int FIg_set_justification (Form  form,
                           int   label,
                           int   just)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_int ( gadget, FIg_set_justification, just, 0 );
    }
  else
    {
      gadget->FIgadget.justification = just;
    }

  return ( FI_SUCCESS );
}



int FIg_set_on_text (Form   form,
                     int    label,
                     char  *text)
{
  struct FItog_obj *toggle;

  toggle = (struct FItog_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );

  if ( ! toggle )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( toggle->FIgadget.type != FI_TOGGLE )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  _FI_s_rep ( (char **) &toggle->FItog.on_text, text );

	/**********************************/
	/* re-calculate the string length */
	/**********************************/

  toggle->FItog.on_text_length = strlen (text);

  _FI_g_activate ((struct FIgadget_obj *)toggle );

	/******************/
	/* Display toggle */
	/******************/

  if ( ( IT_IS_DISPLAYED ( toggle )) && ( XWINDOW ( toggle ) != None ))
    {
      _FI_g_display ( (struct FIgadget_obj *) toggle,
					XWINDOW ( toggle ) );
    }

  return ( FI_SUCCESS );
}



int FIg_get_on_text (Form   form,
                     int    label,
                     char  *text)
{
  struct FItog_obj *toggle;

  toggle = (struct FItog_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );

  if ( ! toggle )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( toggle->FIgadget.type != FI_TOGGLE )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

#if defined(hp9000)
  strcpy ( text, (char *) toggle->FItog.on_text );
#else
  strcpy ( text, toggle->FItog.on_text );
#endif

  return ( FI_SUCCESS );
}



int FIg_get_on_text_length (Form   form,
                            int    label,
                            int   *length)
{
  struct FItog_obj *toggle;

  toggle = (struct FItog_obj *) _FI_g_get_id (
			(struct FIform_obj *) form, label );

  if ( ! toggle )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( toggle->FIgadget.type != FI_TOGGLE )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  * length = strlen ( (char *)toggle->FItog.on_text ) + 1;

  return ( FI_SUCCESS );
}



/********************************************************************/
/* This function deletes a gadget on a form.  This also erases it.  */
/* If this is sent to a group gadget, the group itself is left      */
/* alone and all its member gadgets are deleted.		    */
/* Use FIgrp_delete()to delete a group itself ( WITHOUT		    */
/* deleting its gadgets ).					    */
/********************************************************************/

int FIg_delete (Form   form,
                int    label)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  return ( _FI_g_delete ( gadget, TRUE ) );
}



int FIg_new (Form  form,
             int   gadget_type,
             int   label)
{
  struct FIform_obj   * form_ptr = (struct FIform_obj *) form;
  struct FIgadget_obj * gadget;

	/*******************************************************/
	/*** If the label exists, then don't make a new one. ***/
	/*******************************************************/

  if ( _FI_g_get_id ( form_ptr, label ) )
    {
      return ( FI_LABEL_IN_USE );
    }

  return ( _FI_g_new ( form_ptr, gadget_type, label, &gadget ) );
}
