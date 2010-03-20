#include "FImin.h"
#include "FIscroll.h"
#include "FIbtn.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/** <pds-7/6/90  Went through and took out the comments which said **/
/** the stuff got fixed.  It is stable now so the comments are not **/
/** necessary **/

/*********************************************************************
 ** OBSOLETE **
void _FI_scrl_set_erase_color(struct FIscrl_obj  *scroll,
                              int                 erase_color)
{
 scroll->FIgadget.erase_color = erase_color;
 scroll->FIscroll.puck->FIgadget.erase_color = erase_color;
 scroll->FIscroll.btns[0]->FIgadget.erase_color = erase_color;
 scroll->FIscroll.btns[1]->FIgadget.erase_color = erase_color;
 scroll->FIscroll.btns[2]->FIgadget.erase_color = erase_color;
 scroll->FIscroll.btns[3]->FIgadget.erase_color = erase_color;
}
********************************************************************/



/*====================================================================*/

int _FI_scrl_erase (struct FIscrl_obj  *scroll,
                    Window              window)
{
   int ii;

   /** X11-6/15/90-Wipes out entire area, no need to erase buttons. **/
   /** Now scrl_set_erase_color is moot **/

   _FI_generic_erase ((struct FIgadget_obj *)scroll, window);

   scroll->FIscroll.puck->FIgadget.attr_mask |= FI_NOT_DISPLAYED;
   scroll->FIscroll.puck->FIgadget.displayed = FALSE;

   for (ii = 0; ii < 4; ii++)
   {
	  scroll->FIscroll.btns[ii]->FIgadget.attr_mask |= FI_NOT_DISPLAYED;
	  scroll->FIscroll.btns[ii]->FIgadget.displayed = FALSE;
   }

   /** Caused too many XFlush()'s  ********
   _FI_g_erase(scroll->FIscroll.puck);
   _FI_g_erase(scroll->FIscroll.btns[0]);
   _FI_g_erase(scroll->FIscroll.btns[1]);
   _FI_g_erase(scroll->FIscroll.btns[2]);
   _FI_g_erase(scroll->FIscroll.btns[3]);
   ****************************************/
   return (FI_SUCCESS);	/* dmb:03/27/91:Added */
}


/*====================================================================*/
/* dmb:10/10/92:Change floats to doubles for ANSI */
int _FI_scrl_adjust (struct FIscrl_obj  *scroll,
                     double              delta_x,
                     double              delta_y)
{
   _FI_generic_adjust ((struct FIgadget_obj *)scroll, delta_x, delta_y);
   _FI_scrl_calc_bar (scroll);
   return (FI_SUCCESS);
}



/*====================================================================*/

int _FI_scrl_activate (struct FIscrl_obj *scroll)
{
  int ii;

  if (scroll->FIscroll.type == FI_VERTICAL)
   {
	  scroll->FIscroll.btns[PG_UP]->FIgadget.symbol_ptr.sym_index = PG_UP_SYM;
	  scroll->FIscroll.btns[LN_UP]->FIgadget.symbol_ptr.sym_index = LN_UP_SYM;
	  scroll->FIscroll.btns[LN_DN]->FIgadget.symbol_ptr.sym_index = LN_DOWN_SYM;
	  scroll->FIscroll.btns[PG_DN]->FIgadget.symbol_ptr.sym_index = PG_DOWN_SYM;
   }
   else
   {
	  scroll->FIscroll.btns[VW_LT]->FIgadget.symbol_ptr.sym_index = VIEW_LT_SYM;
	  scroll->FIscroll.btns[CH_LT]->FIgadget.symbol_ptr.sym_index = LT_SYM;
	  scroll->FIscroll.btns[CH_RT]->FIgadget.symbol_ptr.sym_index = RT_SYM;;
	  scroll->FIscroll.btns[VW_RT]->FIgadget.symbol_ptr.sym_index = VIEW_RT_SYM;
   }

   _FI_g_activate ((struct FIgadget_obj *)scroll->FIscroll.puck);

   for (ii = 0; ii < 4; ii++)
     {
	  _FI_g_activate ((struct FIgadget_obj *)scroll->FIscroll.btns[ii]);
     }

   scroll->FIgadget.value = scroll->FIrange.low_value;

   _FI_scrl_calc_bar (scroll);

   return (FI_SUCCESS);
}

/*====================================================================*/

void _FI_scrl_calc_puck (struct FIscrl_obj *scroll)
{
   int puck_size;

   if (scroll->FIscroll.type == FI_VERTICAL)
   {
	  puck_size = (int)(scroll->FIscroll.view * ((short)scroll->FIscroll.track_yhi - (short)scroll->FIscroll.track_ylo) + 0.5);

	  if (puck_size < 11)
	    {
		 puck_size = 11;
	    }

	  if (scroll->FIrange.high_value <= scroll->FIrange.low_value)
	    {
		 scroll->FIrange.increment = 0;
	    }
	  else
	    {
		 scroll->FIrange.increment = ((short)scroll->FIscroll.track_yhi - (short)scroll->FIscroll.track_ylo - puck_size) / (ABS(scroll->FIrange.high_value - scroll->FIrange.low_value));
	    }

	  scroll->FIscroll.puck->FIgadget.ylo = (short)scroll->FIscroll.track_ylo + (scroll->FIgadget.value - scroll->FIrange.low_value) * scroll->FIrange.increment;

	  if (scroll->FIscroll.puck->FIgadget.ylo < (float)scroll->FIscroll.track_ylo)
	     {
		 scroll->FIscroll.puck->FIgadget.ylo = scroll->FIscroll.track_ylo;
	     }

	  scroll->FIscroll.puck->FIgadget.yhi =
		scroll->FIscroll.puck->FIgadget.ylo + puck_size;

	  if ( scroll->FIscroll.puck->FIgadget.yhi > (float)scroll->FIscroll.track_yhi)
	  {
		 scroll->FIscroll.puck->FIgadget.yhi = scroll->FIscroll.track_yhi;
	    scroll->FIscroll.puck->FIgadget.ylo =
		scroll->FIscroll.puck->FIgadget.yhi - puck_size;
	  }
   }
   else	/*** Horizontal ***/
   {
	  puck_size = scroll->FIscroll.view * ((short)scroll->FIscroll.track_xhi - (short)scroll->FIscroll.track_xlo) + 0.5;

	  if (puck_size < 11)
            {
		 puck_size = 11;
            }

	  if (scroll->FIrange.high_value <= scroll->FIrange.low_value)
            {
		 scroll->FIrange.increment = 0;
            }
	  else
            {
		 scroll->FIrange.increment = ((short)scroll->FIscroll.track_xhi - (short)scroll->FIscroll.track_xlo - puck_size) / (ABS(scroll->FIrange.high_value -  scroll->FIrange.low_value));
            }

	  scroll->FIscroll.puck->FIgadget.xlo = (short)scroll->FIscroll.track_xlo + (scroll->FIgadget.value - scroll->FIrange.low_value) * scroll->FIrange.increment;

	  if (scroll->FIscroll.puck->FIgadget.xlo < (float)scroll->FIscroll.track_xlo)
	    {
		 scroll->FIscroll.puck->FIgadget.xlo = scroll->FIscroll.track_xlo;
	    }

	  scroll->FIscroll.puck->FIgadget.xhi = scroll->FIscroll.puck->FIgadget.xlo + puck_size;

	  if ( scroll->FIscroll.puck->FIgadget.xhi > (float)scroll->FIscroll.track_xhi)
	  {
		 scroll->FIscroll.puck->FIgadget.xhi = scroll->FIscroll.track_xhi;
		 scroll->FIscroll.puck->FIgadget.xlo = scroll->FIscroll.puck->FIgadget.xhi - puck_size;
	  }
   }
}

/*====================================================================*/

void _FI_scrl_calc_bar (struct FIscrl_obj *scroll)
{
   struct FIbtn_obj *line_up;
   struct FIbtn_obj *line_down;
   struct FIbtn_obj *page_up;
   struct FIbtn_obj *page_down;

   int	ii;
   int	two_btn_type, four_btn_type, puck_type;
   int	btn_size, ht, wd, half;

   ht = scroll->FIgadget.yhi - scroll->FIgadget.ylo;
   wd = scroll->FIgadget.xhi - scroll->FIgadget.xlo;

   scroll->FIscroll.track_xlo = scroll->FIscroll.btn_area_xlo = scroll->FIgadget.xlo + BEZEL;

   scroll->FIscroll.track_xhi = scroll->FIscroll.btn_area_xhi = scroll->FIgadget.xhi - BEZEL;

   scroll->FIscroll.track_ylo = scroll->FIscroll.btn_area_ylo = scroll->FIgadget.ylo + BEZEL;

   scroll->FIscroll.track_yhi = scroll->FIscroll.btn_area_yhi = scroll->FIgadget.yhi - BEZEL;

   line_up = scroll->FIscroll.btns[LN_UP];
   line_down = scroll->FIscroll.btns[LN_DN];
   page_up = scroll->FIscroll.btns[PG_UP];
   page_down = scroll->FIscroll.btns[PG_DN];

   for (ii = 0; ii < 4; ii++)
   {
	  scroll->FIscroll.btns[ii]->FIgadget.default_attr_mask &= ~ FI_NOT_DISPLAYED;
	  scroll->FIscroll.btns[ii]->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;
   }

   if (scroll->FIscroll.type == FI_VERTICAL)
   {
	  scroll->FIscroll.btns[PG_UP]->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;
	  scroll->FIscroll.btns[PG_UP]->FIgadget.attr_mask |= FI_NOT_DISPLAYED;
	  scroll->FIscroll.btns[PG_DN]->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;
	  scroll->FIscroll.btns[PG_DN]->FIgadget.attr_mask |= FI_NOT_DISPLAYED;

	  scroll->FIscroll.puck->FIgadget.xlo = scroll->FIgadget.xlo + BEZEL + 1;

	  for (ii = 0; ii < 4; ii++)
	  {
		 scroll->FIscroll.btns[ii]->FIgadget.xlo = scroll->FIscroll.puck->FIgadget.xlo;
	  }

	  scroll->FIscroll.puck->FIgadget.xhi = scroll->FIgadget.xhi - BEZEL - 1;

	  for (ii = 0; ii < 4; ii++)
	  {
		 scroll->FIscroll.btns[ii]->FIgadget.xhi = scroll->FIscroll.puck->FIgadget.xhi;
	  }

      /* Calculate the type of scrl_bar */

	  two_btn_type = BEZEL * 2 + BTN_SIZE * 2 + BUTTON_SPACING * 2 + 2;
	  four_btn_type = BEZEL * 2 + BTN_SIZE * 4 + BUTTON_SPACING * 4 + 4;
	  puck_type = four_btn_type + MIN_SLIDE_AREA + SCROLL_SIZE;

	  scroll->FIscroll.btn_area_yhi = scroll->FIgadget.yhi - BEZEL - 1;

	  if (ht >= puck_type)
	    {
		 scroll->FIscroll.btn_area_ylo = scroll->FIscroll.btn_area_yhi - (BTN_SIZE * 4 + 2);
	    }
	  else
	    {
		 scroll->FIscroll.btn_area_ylo = scroll->FIgadget.ylo + BEZEL + 1;
	    }

	  if (! (scroll->FIgadget.attr_mask & FI_NOT_DISPLAYED) && (ht >= puck_type))
	  {
		 scroll->FIscroll.puck->FIgadget.default_attr_mask &= ~ FI_NOT_DISPLAYED;
		 scroll->FIscroll.puck->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;
	  }
	  else
	  {
		 scroll->FIscroll.puck->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;
         /** scroll->FIscroll.puck->FIgadget.attr_mask |= FI_NOT_DISPLAYED;**/
		 _FI_g_erase ( (struct FIgadget_obj *) scroll->FIscroll.puck);
	  }

	  if ((ht < two_btn_type) && (scroll->FIgadget.orig_ysize <= (scroll->FIgadget.xhi - scroll->FIgadget.xlo)))
	  {
		 wd = BEZEL * 2 + BTN_WD * 2 + BUTTON_SPACING * 2 + 2;

		 scroll->FIgadget.xhi = scroll->FIgadget.xlo + wd;

		 page_up->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;

		 _FI_g_erase ( (struct FIgadget_obj *) page_up);
		 page_down->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;

		 _FI_g_erase ( (struct FIgadget_obj *) page_down);
		 btn_size = ht;

		 line_down->FIgadget.xhi = scroll->FIgadget.xhi - BEZEL - 1;
		 line_down->FIgadget.xlo = line_down->FIgadget.xhi - BTN_WD;
		 line_up->FIgadget.xhi = line_down->FIgadget.xlo - 2;
		 line_up->FIgadget.xlo = line_up->FIgadget.xhi - BTN_WD;
		 line_down->FIgadget.yhi = scroll->FIgadget.yhi - BEZEL - 1;
		 line_down->FIgadget.ylo = scroll->FIgadget.ylo + BEZEL + 1;
		 line_up->FIgadget.yhi = line_down->FIgadget.yhi;
		 line_up->FIgadget.ylo = line_down->FIgadget.ylo;
	  }
	  else
	  {
		 half = (int)(((short) scroll->FIscroll.btn_area_yhi - (short) scroll->FIscroll.btn_area_ylo) / 2.0);
		 btn_size = half / 2;
		 if (btn_size < BTN_SIZE)
		 {
			btn_size = half;
			page_up->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;

			_FI_g_erase ( (struct FIgadget_obj *) page_up);

			page_down->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;

			_FI_g_erase ( (struct FIgadget_obj *) page_down);
		 }

		 line_up->FIgadget.yhi = (float)((short)scroll->FIscroll.btn_area_ylo + half - 1.0);
		 line_up->FIgadget.ylo = line_up->FIgadget.yhi - btn_size + 1;
		 line_down->FIgadget.ylo = (float)((short)scroll->FIscroll.btn_area_ylo + half + 1.0);
		 line_down->FIgadget.yhi = line_down->FIgadget.ylo + btn_size - 1;

		 if (ht >= four_btn_type)
		 {
			page_up->FIgadget.yhi = line_up->FIgadget.ylo - 2;
			page_up->FIgadget.ylo = page_up->FIgadget.yhi - btn_size + 1;
			page_down->FIgadget.ylo = line_down->FIgadget.yhi + 2;
			page_down->FIgadget.yhi = page_down->FIgadget.ylo + btn_size - 1;

			scroll->FIscroll.btns[PG_UP]->FIgadget.default_attr_mask &= ~ FI_NOT_DISPLAYED;
			scroll->FIscroll.btns[PG_UP]->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;
			scroll->FIscroll.btns[PG_DN]->FIgadget.default_attr_mask &= ~ FI_NOT_DISPLAYED;
			scroll->FIscroll.btns[PG_DN]->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;
		 }
		 if (ht >= puck_type)
		 {
			scroll->FIscroll.track_ylo = scroll->FIgadget.ylo + BEZEL + 1;
			scroll->FIscroll.track_yhi = scroll->FIscroll.btn_area_ylo - 2;
			_FI_scrl_calc_puck (scroll);
		 }
	  }
   }
   else	/* horizontal */
   {
	  scroll->FIscroll.puck->FIgadget.ylo = scroll->FIgadget.ylo + BEZEL + 1;
	  for (ii = 0; ii < 4; ii++)
	  {
		 scroll->FIscroll.btns[ii]->FIgadget.ylo = scroll->FIscroll.puck->FIgadget.ylo;
	  }
	  scroll->FIscroll.puck->FIgadget.yhi = scroll->FIgadget.yhi - BEZEL - 1;
	  for (ii = 0; ii < 4; ii++)
	  {
		 scroll->FIscroll.btns[ii]->FIgadget.yhi = scroll->FIscroll.puck->FIgadget.yhi;
	  }
      /* Calculate the type of scrl_bar */

	  two_btn_type = BEZEL * 2 + BTN_SIZE * 2 + BUTTON_SPACING * 2 + 2;
	  four_btn_type = BEZEL * 2 + BTN_SIZE * 4 + BUTTON_SPACING * 4 + 4;
	  puck_type = four_btn_type + MIN_SLIDE_AREA + SCROLL_SIZE;

	  scroll->FIscroll.btn_area_xhi = scroll->FIgadget.xhi - BEZEL - 1;
	  if (wd >= puck_type)
	    {
		 scroll->FIscroll.btn_area_xlo = scroll->FIscroll.btn_area_xhi - (BTN_SIZE * 4 + 2);
	    }
	  else
	    {
		 scroll->FIscroll.btn_area_xlo = scroll->FIgadget.xlo + BEZEL + 1;
	    }

	  if (! (scroll->FIgadget.attr_mask & FI_NOT_DISPLAYED) && (wd >= puck_type))
	  {
		 scroll->FIscroll.puck->FIgadget.default_attr_mask &= ~ FI_NOT_DISPLAYED;
		 scroll->FIscroll.puck->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;
	  }
	  else
	  {
		 scroll->FIscroll.puck->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;
		 scroll->FIscroll.puck->FIgadget.attr_mask |= FI_NOT_DISPLAYED;
		 _FI_g_erase ( (struct FIgadget_obj *) scroll->FIscroll.puck);
	  }

	  half = (int)(((short)scroll->FIscroll.btn_area_xhi - (short) scroll->FIscroll.btn_area_xlo) / 2.0);
	  btn_size = half / 2;

	  if (btn_size < BTN_SIZE)
	  {
		 btn_size = half;
		 scroll->FIscroll.btns[VW_LT]->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;

		 _FI_g_erase ( (struct FIgadget_obj *) scroll->FIscroll.btns[VW_LT]);

		 scroll->FIscroll.btns[VW_RT]->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;

		 _FI_g_erase ( (struct FIgadget_obj *) scroll->FIscroll.btns[VW_RT]);

	  }

	  scroll->FIscroll.btns[CH_LT]->FIgadget.xhi = (short)scroll->FIscroll.btn_area_xlo + half - 1;
	  scroll->FIscroll.btns[CH_LT]->FIgadget.xlo = scroll->FIscroll.btns[CH_LT]->FIgadget.xhi - btn_size + 1;
	  scroll->FIscroll.btns[CH_RT]->FIgadget.xlo = (short)scroll->FIscroll.btn_area_xlo + half + 1;
	  scroll->FIscroll.btns[CH_RT]->FIgadget.xhi = scroll->FIscroll.btns[CH_RT]->FIgadget.xlo + btn_size - 1;

	  if (wd >= four_btn_type)
	  {
		 scroll->FIscroll.btns[VW_LT]->FIgadget.xhi = scroll->FIscroll.btns[CH_LT]->FIgadget.xlo - 2;
		 scroll->FIscroll.btns[VW_LT]->FIgadget.xlo = scroll->FIscroll.btns[VW_LT]->FIgadget.xhi - btn_size + 1;
		 scroll->FIscroll.btns[VW_RT]->FIgadget.xlo = scroll->FIscroll.btns[CH_RT]->FIgadget.xhi + 2;
		 scroll->FIscroll.btns[VW_RT]->FIgadget.xhi = scroll->FIscroll.btns[VW_RT]->FIgadget.xlo + btn_size - 1;
	  }

	  if (wd >= puck_type)
	  {
		 scroll->FIscroll.track_xlo = scroll->FIgadget.xlo + BEZEL + 1;
		 scroll->FIscroll.track_xhi = scroll->FIscroll.btn_area_xlo - 2;
		 _FI_scrl_calc_puck (scroll);
	  }
   }

}

/*====================================================================*/

int _FI_scrl_display (struct FIscrl_obj  *scroll,
                      Window              window)
{
   int	Xscreen = XSCREEN(scroll);
   int	ii;
   int	edge_color, t_l_color, b_r_color;
   XRectangle rect;

   if ((scroll->FIgadget.attr_mask & FI_NOT_DISPLAYED) || (! _FI_is_in_clip_rectangle (& (scroll->FIgadget))))
     {
	  return ( FI_SUCCESS );
     }

   /* draw outside bezel */

   if (scroll->FIgadget.attr_mask & FI_HILITED)
     {
	  edge_color = FI_GLINT;
     }
   else
     {
	  edge_color = FI_EDGE;
     }

   if (scroll->FIgadget.attr_mask & FI_NOT_ENABLED)
   {
	  t_l_color = FI_FACE;
	  b_r_color = FI_FACE;
   }
   else
   {
	  t_l_color = FI_EDGE;
	  b_r_color = FI_GLINT;
   }

  /* GMD 3/24/92 */

  rect.x = scroll->FIgadget.xlo;
  rect.y = scroll->FIgadget.ylo;
  rect.width  = scroll->FIgadget.xhi - scroll->FIgadget.xlo;
  rect.height = scroll->FIgadget.yhi - scroll->FIgadget.ylo;

  if ( _FI_form_clipping_on )
    {
      _FI_adjust_clip_rectangle ( &rect );	/** Due to text **/
    }

  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &rect, 1, Unsorted );

   _FI_draw_bezel (window, (int) scroll->FIgadget.xlo, (int) scroll->FIgadget.ylo, (int) scroll->FIgadget.xhi, (int) scroll->FIgadget.yhi, BEZEL2, FI_translate_color (Xscreen, t_l_color), FI_translate_color (Xscreen, FI_FACE), FI_translate_color (Xscreen, b_r_color), FI_translate_color (Xscreen, edge_color), SQUARE);

  rect.x = 0;
  rect.y = 0;
  rect.width  = 2000;
  rect.height = 2000;

  if ( _FI_form_clipping_on )
    {
      _FI_adjust_clip_rectangle ( &rect );	/** Due to text **/
    }

  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &rect, 1, Unsorted );

   _FI_scrl_calc_bar (scroll);

   /** X11-6/15/90-Trying to reduce the number of calls to XFlush()
   _FI_g_display(scroll->FIscroll.puck, window); 
   *****************************************************************/

   /** Only display the puck if the default was not displayed **/

   if (! (scroll->FIscroll.puck->FIgadget.default_attr_mask & FI_NOT_DISPLAYED))
   {
	  scroll->FIscroll.puck->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;
	  _FI_btn_display (scroll->FIscroll.puck, window);
	  scroll->FIscroll.puck->FIgadget.displayed = TRUE;
   }

   for (ii = 0; ii < 4; ii++)
   {
      /** X11-6/15/90-Trying to reduce the number of calls to XFlush()
      _FI_g_display(scroll->FIscroll.btns[i], window);
      ****************************************************************/

          if (!(scroll->FIscroll.btns[ii]->FIgadget.attr_mask & FI_NOT_DISPLAYED))
          {
	     _FI_btn_display (scroll->FIscroll.btns[ii], window);
             scroll->FIscroll.btns[ii]->FIgadget.displayed = TRUE;
          }
   }
   return (FI_SUCCESS);	/* dmb:03/27/91:Added */
}


/*====================================================================*/

void _FI_scrl_set_value (struct FIscrl_obj  *scroll,
                         double              value)
{
   double	old_value;
   Window	window = XWINDOW(scroll);
   double	high_minus_low;

   old_value = scroll->FIgadget.value;

/* dmb:10/12/92:FI_TOP is a negative number with a large absolute value */
/*   if (value < FI_TOP) ** DMB,GMD:10/12/92:Original */

   /* dmb:10/12/92:Added casts to all scroll key values for ANSI */
   if (value <= (double)((int)FI_TOP))
   {
	  switch ( (int) value)
	  {
	  case FI_TOP:
	  case FI_LEFT_END:
		 scroll->FIgadget.value = scroll->FIrange.low_value;
		 break;

	  case FI_BOTTOM:
	  case FI_RIGHT_END:
		 scroll->FIgadget.value = scroll->FIrange.high_value;
		 break;

	  case FI_LINE_UP:
	  case FI_COL_LEFT:
		 scroll->FIgadget.value--;
		 break;

	  case FI_LINE_DOWN:
	  case FI_COL_RIGHT:
		 scroll->FIgadget.value++;
		 break;

	  case FI_PAGE_UP:
	  case FI_VIEW_LEFT:
		 if (scroll->FIscroll.view >= 0.50)
		   {
			scroll->FIgadget.value = scroll->FIrange.low_value;
		   }
		 else
		 {
            /* Thanks to Gordon Cross for coming up with the */
            /* following formula for an infinite series. This */
            /* corrects round off error that was occurring */
            /* with the original formula. GMD 11/1/90 */

            /*
             scroll->FIgadget.value -= scroll->FIscroll.view *
             (scroll->FIrange.high_value -
             scroll->FIrange.low_value / ** <pds> + 1 ** /);
            */
			high_minus_low = scroll->FIrange.high_value - scroll->FIrange.low_value;

			scroll->FIgadget.value -= (high_minus_low / (1.0 - scroll->FIscroll.view)) - high_minus_low;
		 }
		 break;

	  case FI_PAGE_DOWN:
	  case FI_VIEW_RIGHT:
		 if (scroll->FIscroll.view >= 0.50)
		   {
			scroll->FIgadget.value = scroll->FIrange.high_value;
		   }
		 else
		 {
            /*
             scroll->FIgadget.value += scroll->FIscroll.view *
             (scroll->FIrange.high_value -
             scroll->FIrange.low_value / ** <pds> + 1 ** /);
            */
			high_minus_low = scroll->FIrange.high_value - scroll->FIrange.low_value;

			scroll->FIgadget.value += (high_minus_low / (1.0 - scroll->FIscroll.view)) - high_minus_low;
		 }
		 break;
	  }
   }
   else
    {
	  scroll->FIgadget.value = value;
    }

   if (scroll->FIgadget.value < scroll->FIrange.low_value)
    {
	  scroll->FIgadget.value = scroll->FIrange.low_value;
    }
   else if (scroll->FIgadget.value > scroll->FIrange.high_value)
    {
	  scroll->FIgadget.value = scroll->FIrange.high_value;
    }

   _FI_g_pass_data ((struct FIgadget_obj *)scroll);

   if ((scroll->FIgadget.value != old_value) && (scroll->FIgadget.displayed) && (! (scroll->FIgadget.attr_mask & FI_NOT_DISPLAYED)))
   {
	  if ((window != None) && scroll->FIgadget.form->displayed)
	  {
		 XSetForeground (_FI_display, _FI_gc, FI_translate_color (XSCREEN(scroll) , FI_LT_GREY));

		 _FI_generic_erase ((struct FIgadget_obj *)scroll->FIscroll.puck, window);
	  }
	  _FI_scrl_calc_puck (scroll);

	  if (! (scroll->FIscroll.puck->FIgadget.default_attr_mask & FI_NOT_DISPLAYED))
	  {
		 scroll->FIscroll.puck->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;
	  }

	  if ((window != None) && scroll->FIgadget.form->displayed)
	  {
		 _FI_g_display ( (struct FIgadget_obj *) scroll->FIscroll.puck, window);

         /** display already flushes XFlush(_FI_display); **/
	  }
   }
}

/*====================================================================*/

int _FI_scrl_track_mouse (struct FIscrl_obj  *scroll,
                          Window              window,
                          int                 xpos,
                          int                 ypos,
                          int                *complete,
                          double             *value)
{
   int status = FI_SUCCESS;
   int no_event, button_released = 0, puck_size = 0;
   int puck_ptr_offset;
   int root_x, root_y, win_x, win_y, btn, old_x, old_y, x, y;
   int available_area, used_area;
   double percentage;
   XEvent event;
   Window root, child;
   char *user_ptr = scroll->FIgadget.user_pointer;
   unsigned int keys_buttons;

   no_event = TRUE;

   if (scroll->FIscroll.type == FI_VERTICAL)
   {
	  if (ypos >= (int)scroll->FIscroll.btn_area_ylo)
	  {
		 btn = -1;

		 if (_FI_generic_find_gadget ( (struct FIgadget_obj *) scroll->FIscroll.btns[LN_UP], xpos, ypos))
		 {
			*value = (double)((int)FI_LINE_UP);
			btn = LN_UP;
		 }
		 else if (_FI_generic_find_gadget ( (struct FIgadget_obj *) scroll->FIscroll.btns[LN_DN], xpos, ypos))
		 {
			*value = (double)((int)FI_LINE_DOWN);
			btn = LN_DN;
		 }
		 else if (_FI_generic_find_gadget ( (struct FIgadget_obj *) scroll->FIscroll.btns[PG_UP], xpos, ypos))
		 {
			*value = (double)((int)FI_PAGE_UP);
			btn = PG_UP;
		 }
		 else if (_FI_generic_find_gadget ( (struct FIgadget_obj *) scroll->FIscroll.btns[PG_DN], xpos, ypos))
		 {
			*value = (double)((int)FI_PAGE_DOWN);
			btn = PG_DN;
		 }

		 if (btn != -1)	/** Button Pressed **/
		 {
			_FI_g_set_state ((struct FIgadget_obj *)scroll->FIscroll.btns[btn], 1.0);

			_FI_generic_timer ( (double) 0.5, 1);

                        /* GMD 1/24/92 */
			button_released = FI_check_mask_event (_FI_display, ButtonReleaseMask , &event);

			while (! _FI_generic_timer ( (double) 0.0, 0) && ! button_released)
			{
                           /* GMD 1/24/92 */
			   button_released = FI_check_mask_event (_FI_display, ButtonReleaseMask , &event);
			}

			while (no_event)
			{
			   _FI_scrl_set_value (scroll, *value);

			   if (scroll->FIrange.cont_routine)
			   {
				  scroll->FIrange.cont_routine (scroll->FIgadget.form->form_label, scroll->FIgadget.label, scroll->FIgadget.value, scroll->FIgadget.form);
			   }
			   else if (scroll->FIgadget.label < 0)
			   {
				  if (((struct FIgadget_obj *) user_ptr)->FIgadget.type == FI_FIELD)
				  {
					 status = _FI_fld_vscrl ((struct FIfld_obj *)user_ptr, *value);

                     /*** if the gadget/form was deleted, ***/
                     /*** then return ***/
					 if (status != FI_SUCCESS)
						return (status);
				  }
				  else if (((struct FIgadget_obj *) user_ptr)->FIgadget.type == FI_MULTI_COL)
				  {
					 status = _FI_mcf_vscrl ((struct FImcf_obj *)user_ptr, *value);
                     /*** if the gadget/form was deleted, ***/
                     /*** then return ***/
					 if (status != FI_SUCCESS)
						return (status);
				  }
			   }

			   XFlush (_FI_display);

			   if (button_released)
			   {
				  no_event = FALSE;
			   }
			   else
			   {
                                  /* GMD  1/24/92 */
				  button_released = FI_check_mask_event (_FI_display, ButtonReleaseMask , &event);
			   }

                           /* GMD 3/5/92 */
                           /* Check to see if the button has been released */
                           /* prior to this function being called, as in   */
                           /* FI_get_transition().                         */

                           FI_query_pointer (_FI_display, window,
                                          &root, &child, &root_x, &root_y,
                                          &win_x, &win_y, &keys_buttons);

                           if (!((keys_buttons & Button1Mask) ||
                                (keys_buttons & Button2Mask) ||
                                (keys_buttons & Button3Mask)))
                                     no_event = FALSE;

			}	/** END while(no_event) Pressing button **/

			_FI_g_set_state ((struct FIgadget_obj *)scroll->FIscroll.btns[btn], 0.0);
		 }
	  }
      /** Poked on Puck **/
	  else if (_FI_generic_find_gadget ( (struct FIgadget_obj *) scroll->FIscroll.puck, xpos, ypos))
	  {
		 int grab;

		 y = old_y = ypos;

		 puck_size = scroll->FIscroll.view * ((short)scroll->FIscroll.track_yhi - (short)scroll->FIscroll.track_ylo) + 0.5;

		 if (puck_size < 11)
		    {
			puck_size = 11;
		    }

         /***************************************************************/
         /* */
         /* puck_ptr_offset tells how many pixels down from the top of */
         /* the puck the mouse pointer was originally poked. This */
         /* distance will be maintained as the cursor is moved up */
         /* and down. GMD 11/16/90 */
         /* */
         /***************************************************************/

		 puck_ptr_offset = ypos - (int) (scroll->FIscroll.puck->FIgadget.ylo);

                 /* GMD 2/18/92 */

		 grab = FI_grab_pointer (_FI_display, window, True, (unsigned int) (ButtonMotionMask | PointerMotionHintMask), GrabModeAsync, GrabModeAsync, window, None, CurrentTime);

		 button_released = ! (grab == GrabSuccess);

		 while (! button_released)
		 {
                        /* GMD 1/24/92 */
			FI_mask_event (_FI_display, (unsigned long) (ButtonPressMask | ButtonReleaseMask | ButtonMotionMask | PointerMotionHintMask), &event);

			if (event.type == ButtonPress || event.type == ButtonRelease)
			{
			   if (event.xbutton.window == window)
			   {
				  xpos = event.xbutton.x;
				  y = event.xbutton.y;
			   }
			   button_released = 1;
			}
			else	/** Motion Notify **/
			{
                           /* GMD 1/24/92 */
			   while (FI_check_mask_event (_FI_display, ButtonMotionMask , &event))
               /** Remove all from queue **/
				  ;

			   FI_query_pointer (_FI_display, window, &root, &child, &root_x, &root_y, &xpos, &y, &keys_buttons);
			}

			if (y != old_y)
			{
               /*** <pds-Calculate puck size ***/
			   puck_size = scroll->FIscroll.view * ((short)scroll->FIscroll.track_yhi - (short)scroll->FIscroll.track_ylo) + 0.5;
			   if (puck_size < 11)
				  puck_size = 11;

			   if ((y - puck_ptr_offset) <= (int)scroll->FIscroll.track_ylo)
			   {
				  *value = (double)((int)FI_TOP);
			   }
			   else if ((y + puck_size - puck_ptr_offset) >= (int)scroll->FIscroll.track_yhi)
			   {
				  *value = (double)((int)FI_BOTTOM);
			   }
			   else
			   {
				  available_area = scroll->FIscroll.track_yhi - scroll->FIscroll.track_ylo - puck_size;

				  used_area = y - puck_ptr_offset - scroll->FIscroll.track_ylo;

				  percentage = ((double) used_area / (double) available_area);

				  *value = percentage * (scroll->FIrange.high_value - scroll->FIrange.low_value) + scroll->FIrange.low_value;
			   }

			   _FI_scrl_set_value (scroll, *value);

			   if (scroll->FIrange.cont_routine)
			   {
				  scroll->FIrange.cont_routine (scroll->FIgadget.form->form_label, scroll->FIgadget.label, scroll->FIgadget.value, scroll->FIgadget.form);
			   }
			   else if (scroll->FIgadget.label < 0)
			   {
				  if (((struct FIgadget_obj *) user_ptr)->FIgadget.type == FI_FIELD)
				  {
					 status = _FI_fld_vscrl ((struct FIfld_obj *)user_ptr, *value);
					 if (status != FI_SUCCESS)
						return (status);
				  }
				  else if (((struct FIgadget_obj *) user_ptr)->FIgadget.type == FI_MULTI_COL)
				  {
					 status = _FI_mcf_vscrl ((struct FImcf_obj *)user_ptr, *value);
					 if (status != FI_SUCCESS)
						return (status);
				  }
			   }

			   XFlush (_FI_display);
			}
			old_y = y;

                           /* GMD 3/5/92 */
                           /* Check to see if the button has been released */
                           /* prior to this function being called, as in   */
                           /* FI_get_transition().                         */

                           FI_query_pointer (_FI_display, window,
                                          &root, &child, &root_x, &root_y,
                                          &win_x, &win_y, &keys_buttons);

                           if (!((keys_buttons & Button1Mask) ||
                                (keys_buttons & Button2Mask) ||
                                (keys_buttons & Button3Mask)))
                                     button_released = 1;

		 }	/** END while middle button down **/

		 if (grab == GrabSuccess)
		   {
                        /* GMD 2/18/92 */
			FI_ungrab_pointer (_FI_display, CurrentTime);
		   }
	  }
	  else	/** Poked in tracking area **/
	  {

         /*** <pds-Calculate puck size ***/

		 puck_size = scroll->FIscroll.view * ((short)scroll->FIscroll.track_yhi - (short)scroll->FIscroll.track_ylo) + 0.5;

		 if (puck_size < 11)
		   {
			puck_size = 11;
		   }

		 if (ypos < (int)(scroll->FIscroll.track_ylo + 1 + puck_size / 2))
		 {
			*value = (double)((int)FI_TOP);
		 }
		 else if (ypos > (int)(scroll->FIscroll.track_yhi - 1 - puck_size / 2))
		 {
			*value = (double)((int)FI_BOTTOM);
		 }
		 else
		 {
			percentage = (double) (ypos - (int) scroll->FIscroll.track_ylo - puck_size / 2) / ((short)scroll->FIscroll.track_yhi - (short) scroll->FIscroll.track_ylo - puck_size);

            /*** <pds-Change to reference from 0 to low_value  ******

            *value = percentage *(scroll->FIrange.high_value - 
		            scroll->FIrange.low_value + 1);

	    *****************************************************/

			*value = percentage * (scroll->FIrange.high_value - scroll->FIrange.low_value) + scroll->FIrange.low_value;
		 }

		 _FI_scrl_set_value (scroll, *value);

		 if (scroll->FIrange.cont_routine)
		 {
			scroll->FIrange.cont_routine (scroll->FIgadget.form->form_label, scroll->FIgadget.label, scroll->FIgadget.value, scroll->FIgadget.form);
		 }
		 else if (scroll->FIgadget.label < 0)
		 {
			if (((struct FIgadget_obj *) user_ptr)->FIgadget.type == FI_FIELD)
			{
			   status = _FI_fld_vscrl ((struct FIfld_obj *)user_ptr, *value);
			   if (status != FI_SUCCESS)
			     {
				  return (status);
			     }
			}
			else if (((struct FIgadget_obj *) user_ptr)->FIgadget.type == FI_MULTI_COL)
			{
			   status = _FI_mcf_vscrl ((struct FImcf_obj *)user_ptr, *value);
			   if (status != FI_SUCCESS)
			     {
				  return (status);
			     }
			}
		 }

		 XFlush (_FI_display);
	  }
   }
   else	/* horizontal */
   {
	  if (xpos >= (int)scroll->FIscroll.btn_area_xlo)
	  {
		 btn = -1;

		 if (_FI_generic_find_gadget ( (struct FIgadget_obj *) scroll->FIscroll.btns[CH_LT], xpos, ypos))
		 {
			*value = (double)((int)FI_COL_LEFT);
			btn = CH_LT;
		 }
		 else if (_FI_generic_find_gadget ( (struct FIgadget_obj *) scroll->FIscroll.btns[CH_RT], xpos, ypos))
		 {
			*value = (double)((int)FI_COL_RIGHT);
			btn = CH_RT;
		 }
		 else if (_FI_generic_find_gadget ( (struct FIgadget_obj *) scroll->FIscroll.btns[VW_LT], xpos, ypos))
		 {
			*value = (double)((int)FI_VIEW_LEFT);
			btn = VW_LT;
		 }
		 else if (_FI_generic_find_gadget ( (struct FIgadget_obj *) scroll->FIscroll.btns[VW_RT], xpos, ypos))
		 {
			*value = (double)((int)FI_VIEW_RIGHT);
			btn = VW_RT;
		 }
		 if (btn != -1)
		 {
			_FI_g_set_state ((struct FIgadget_obj *)scroll->FIscroll.btns[btn], 1.0);

			_FI_generic_timer ( (double) 0.5, 1);

                        /* GMD 1/24/92 */
			button_released = FI_check_mask_event (_FI_display, ButtonReleaseMask , &event);

			while (! _FI_generic_timer ( (double) 0.0, 0) && ! button_released)
			{
                           /* GMD 1/24/92 */
			   button_released = FI_check_mask_event (_FI_display, ButtonReleaseMask , &event);
			}

			while (no_event)
			{
			   _FI_scrl_set_value (scroll, *value);

			   if (scroll->FIrange.cont_routine)
			   {
				  scroll->FIrange.cont_routine (scroll->FIgadget.form->form_label, scroll->FIgadget.label, scroll->FIgadget.value, scroll->FIgadget.form);
			   }
			   else if ( (short) scroll->FIgadget.label < 0)
			   {
				  if (((struct FIgadget_obj *) user_ptr)->FIgadget.type == FI_MULTI_COL)
				  {
					 status = _FI_mcf_hscrl ((struct FImcf_obj *)user_ptr, *value);
					 if (status != FI_SUCCESS)
					     {
						return (status);
					     }
				  }
			   }

			   XFlush (_FI_display);

			   if (button_released)
			   {
				  no_event = FALSE;
			   }
			   else
			   {
                                  /* GMD 1/24/92 */
				  button_released = FI_check_mask_event (_FI_display, ButtonReleaseMask , &event);
			   }

                           /* GMD 3/5/92 */
                           /* Check to see if the button has been released */
                           /* prior to this function being called, as in   */
                           /* FI_get_transition().                         */

                           FI_query_pointer (_FI_display, window,
                                          &root, &child, &root_x, &root_y,
                                          &win_x, &win_y, &keys_buttons);

                           if (!((keys_buttons & Button1Mask) ||
                                (keys_buttons & Button2Mask) ||
                                (keys_buttons & Button3Mask)))
                                     no_event = FALSE;

			}	/** END while(no_event) Pressing button **/

			_FI_g_set_state ((struct FIgadget_obj *)scroll->FIscroll.btns[btn], 0.0);
		 }
	  }	/* Poked on Puck */

	  else if (_FI_generic_find_gadget ( (struct FIgadget_obj *) scroll->FIscroll.puck, xpos, ypos))
	  {
		 int grab;

		 x = old_x = xpos;

		 puck_size = scroll->FIscroll.view * ((short)scroll->FIscroll.track_xhi - (short)scroll->FIscroll.track_xlo) + 0.5;

		 if (puck_size < 11)
		   {
			puck_size = 11;
		   }

         /*************************************************************/
         /* */
         /* puck_ptr_offset tells how many pixels down from the top */
         /* of the puck the mouse pointer was originally poked. This */
         /* distance will be maintained as the cursor is moved up */
         /* and down. GMD 11/16/90 */
         /* */
         /*************************************************************/

		 puck_ptr_offset = xpos - (int) (scroll->FIscroll.puck->FIgadget.xlo);

                 /* GMD 2/18/92 */
		 grab = FI_grab_pointer (_FI_display, window, True, (unsigned int) (ButtonMotionMask | PointerMotionHintMask), GrabModeAsync, GrabModeAsync, window, None, CurrentTime);

		 button_released = ! (grab == GrabSuccess);

		 while (! button_released)
		 {
                        /* GMD 1/24/92 */
			FI_mask_event (_FI_display, (unsigned long) (ButtonPressMask | ButtonReleaseMask | ButtonMotionMask | PointerMotionHintMask), &event);

			if (event.type == ButtonPress || event.type == ButtonRelease)
			{
			   if (event.xbutton.window == window)
			   {
				  x = event.xbutton.x;
				  ypos = event.xbutton.y;
			   }
			   button_released = 1;
			}
			else	/** Motion Notify **/
			{
                           /* GMD 1/24/92 */
			   while (FI_check_mask_event (_FI_display, ButtonMotionMask , &event))
               /** Remove all from queue **/
				  ;

			   FI_query_pointer (_FI_display, window, &root, &child, &root_x, &root_y, &x, &ypos, &keys_buttons);
			}

			if (x != old_x)
			{

               /*** <pds-Calculate puck size ***/

			   puck_size = scroll->FIscroll.view * ((short)scroll->FIscroll.track_xhi - (short)scroll->FIscroll.track_xlo) + 0.5;

			   if (puck_size < 11)
			     {
				  puck_size = 11;
			     }

			   if ((x - puck_ptr_offset) <= (int)scroll->FIscroll.track_xlo)
			   {
				  *value = (double)((int)FI_LEFT_END);
			   }
			   else if ((x + puck_size - puck_ptr_offset) >= (int)scroll->FIscroll.track_xhi)
			   {
				  *value = (double)((int)FI_RIGHT_END);
			   }
			   else
			   {
				  available_area = scroll->FIscroll.track_xhi - scroll->FIscroll.track_xlo - puck_size;

				  used_area = x - puck_ptr_offset - scroll->FIscroll.track_xlo;

				  percentage = ((double) used_area / (double) available_area);

				  *value = percentage * (scroll->FIrange.high_value - scroll->FIrange.low_value) + scroll->FIrange.low_value;
			   }

			   _FI_scrl_set_value (scroll, *value);

			   if (scroll->FIrange.cont_routine)
			   {
				  scroll->FIrange.cont_routine (scroll->FIgadget.form->form_label, scroll->FIgadget.label, scroll->FIgadget.value, scroll->FIgadget.form);
			   }
			   else if (scroll->FIgadget.label < 0)
			   {
				  if (((struct FIgadget_obj *) user_ptr)->FIgadget.type == FI_MULTI_COL)
				  {
					 status = _FI_mcf_hscrl ((struct FImcf_obj *)user_ptr, *value);
					 if (status != FI_SUCCESS)
					   {
						return (status);
					   }
				  }
			   }

			   XFlush (_FI_display);
			}
			old_x = x;

                           /* GMD 3/5/92 */
                           /* Check to see if the button has been released */
                           /* prior to this function being called, as in   */
                           /* FI_get_transition().                         */

                           FI_query_pointer (_FI_display, window,
                                          &root, &child, &root_x, &root_y,
                                          &win_x, &win_y, &keys_buttons);

                           if (!((keys_buttons & Button1Mask) ||
                                (keys_buttons & Button2Mask) ||
                                (keys_buttons & Button3Mask)))
                                     button_released = 1;

		 }	/* END while middle button down */

		 if (grab == GrabSuccess)
		   {
                        /* GMD 2/18/92 */
			FI_ungrab_pointer (_FI_display, CurrentTime);
		   }
	  }
	  else	/** Poked in track area **/
	  {

         /*** <pds-Calculate puck size ***/

		 puck_size = scroll->FIscroll.view * ((short)scroll->FIscroll.track_xhi - (short)scroll->FIscroll.track_xlo) + 0.5;

		 if (puck_size < 11)
		   {
			puck_size = 11;
		   }

		 if (xpos < (int)(scroll->FIscroll.track_xlo + 1 + puck_size / 2))
		 {
			*value = (double)((int)FI_LEFT_END);
		 }
		 else if (xpos > (int)(scroll->FIscroll.track_xhi - 1 - puck_size / 2))
		 {
			*value = (double)((int)FI_RIGHT_END);
		 }
		 else
		 {
			percentage = (double) (xpos - (short) scroll->FIscroll.track_xlo - puck_size / 2) / ((short)scroll->FIscroll.track_xhi - (short) scroll->FIscroll.track_xlo - puck_size);

            /*** <pds-Change to reference from 0 to low_value  *******

            *value = percentage *(scroll->FIrange.high_value -
            scroll->FIrange.low_value + 1);

	    ***************************************************/

			*value = percentage * (scroll->FIrange.high_value - scroll->FIrange.low_value) + scroll->FIrange.low_value;
		 }

		 _FI_scrl_set_value (scroll, *value);

		 if (scroll->FIrange.cont_routine)
		 {
			scroll->FIrange.cont_routine (scroll->FIgadget.form->form_label, scroll->FIgadget.label, scroll->FIgadget.value, scroll->FIgadget.form);
		 }
		 else if (scroll->FIgadget.label < 0)
		 {
			if (((struct FIgadget_obj *) user_ptr)->FIgadget.type == FI_MULTI_COL)
			{
			   status = _FI_mcf_hscrl ((struct FImcf_obj *)user_ptr, *value);
			   if (status != FI_SUCCESS)
			     {
				  return (status);
			     }
			}
		 }

		 XFlush (_FI_display);
	  }
   }

   if ( scroll->FIgadget.label < 0 )
      {
	  *complete = FALSE;
      }
   else
      {
	  *complete = TRUE;
      }

   return (FI_SUCCESS);
}
