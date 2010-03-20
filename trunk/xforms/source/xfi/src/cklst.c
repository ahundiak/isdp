#include "FImin.h"
#include "FIcklst.h"
#include "FItext.h"

#include <stdio.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/*********************************************/
/* sml:05-05-94:NO TR:HP Port                */
/*  If using POSIX conventions (as we are),  */
/*  then PATH_MAX is not defined.            */
/*********************************************/
#ifndef PATH_MAX
#define PATH_MAX 1023
#endif

void _FI_cklst_get_area (struct FIcklst_obj  *cklst,
                         int                 *xlo,
                         int                 *ylo,
                         int                 *xhi,
                         int                 *yhi)
{
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

  *xlo = cklst->FIgadget.xlo;
  *xhi = cklst->FIgadget.xhi;

  *yhi = cklst->FIgadget.yhi;
  *ylo = cklst->FIgadget.ylo;

	/*** Adjust the ylo if the symbol or text ***/
	/*** is larger than the box size.	  ***/

  if ( y_offset > cklst->FIcklst.box_size )
    {
      *ylo += ( ( cklst->FIcklst.box_size - y_offset ) / 2 );
    }
}



int _FI_cklst_erase (struct FIcklst_obj  *cklst,
                     Window               window)
{
  int xlo;
  int ylo;
  int xhi;
  int yhi;

  _FI_cklst_get_area ( cklst, &xlo, &ylo, &xhi, &yhi );

  XFillRectangle ( _FI_display, window, _FI_gc, xlo, ylo,
					xhi - xlo + 5, yhi - ylo + 5 );

  return ( FI_SUCCESS );
}



int _FI_cklst_display (struct FIcklst_obj  *cklst,
                       Window               window,
                       int                  display_all_flag)
{
  struct FIform_obj *form = cklst->FIgadget.form;
  int xlo	  = cklst->FIgadget.xlo;
  int ylo	  = cklst->FIgadget.ylo;
  int font_height = cklst->FIgadget.font_height;
  int box_size	  = cklst->FIcklst.box_size;
  int Xscreen	  = form->Xscreen;
  int center_y;
  int num_lines   = 0;
  int y_offset;
  int t_l_color;
  int b_r_color;
  int new_x;
  int new_y;
  int new_x2	  = 0;
  int new_y2	  = 0;
  int edge_color;
  int color;
  unsigned long back_color = FI_translate_color (Xscreen, FI_MED_GREY);
  XGCValues gc_values;


  if ( ! _FI_is_in_clip_rectangle ( & cklst->FIgadget ) )
   {
      return ( FI_SUCCESS );
   }

	  /* Set up colors */

  edge_color = FI_EDGE;
  color = FI_YELLOW;	/* In I/FORMS it is always FI_YELLOW */

  /*
   color = ON_COLOR ( cklst );
  */

  if ( IT_IS_DISABLED ( cklst ) )
    {
      t_l_color = FI_FACE;
      b_r_color = FI_FACE;
    }
  else
    {
      t_l_color = FI_SHADOW;
      b_r_color = FI_GLINT;
    }

  if ( IT_IS_HILITED ( cklst ))
    {
      color = FI_GLINT;
      edge_color = FI_GLINT;
    }

  /* Draw the check box */

  _FI_draw_bezel ( window, xlo, ylo, xlo + box_size, ylo + box_size,
			CKLST_BEZEL_WIDTH,
			FI_translate_color ( Xscreen, t_l_color ),
			back_color,
			FI_translate_color ( Xscreen, b_r_color ),
			FI_translate_color ( Xscreen, edge_color),
			SQUARE );


	/***************************************************/
	/*** Draw the check inside the box ( if needed ) ***/
	/***************************************************/

  if ( cklst->FIgadget.value && IT_HAS_ON_SYMBOL( cklst ) )
    {
	/***************************************/
	/*** Calculate location of the check ***/
	/***************************************/

      new_x = xlo + (int)(5.0 * cklst->FIgadget.sym_width_scale_factor);
      new_y = ylo + ( box_size - cklst->FIcklst.font_height ) / 2;

	/*************************************** JAJ:11/15/90 ***/
	/*** CHANGE for back screen of turquoise 2020 machine	***/
	/*** where closest color mapping scheme maps yellow	***/
	/*** ( check color)onto same slot as medium gray	***/
	/*** (inside box color)maps onto.			***/
	/*** If the vlt slots are the same, then make the	***/
	/*** check mark white instead of yellow.		***/
	/********************************************************/

      color = _FI_g_find_contrasting_on_color ( Xscreen,
		    FI_translate_color ( Xscreen, color ), back_color );

      gc_values.foreground = color;
      gc_values.background = back_color;
      XChangeGC ( _FI_display, _FI_gc,
	      (unsigned long) GCForeground | GCBackground, &gc_values );

      _FI_sym_draw ( window, new_x, new_y, cklst->FIcklst.checkmark_id,
			& cklst->FIgadget.on_symbol_ptr,
			(float) 1.0,  (float) 1.0, Xscreen );
    }


	/********************************************/
	/*** Calculate location of symbol or text ***/
	/********************************************/

  new_x = xlo + box_size + cklst->FIcklst.box_offset;

  if ( IT_HAS_TEXT ( cklst ) )
    {
      center_y	= ylo + (box_size / 2);
      num_lines = cklst->FIgadget.num_lines;
      y_offset	= num_lines * cklst->FIgadget.font_height;
      y_offset += (int )(y_offset * YOFFSET_MULTIPLIER );

      new_y	= center_y - ( y_offset / 2 );
      new_x2	= new_x + cklst->FIgadget.largest_width;
      new_y2	= center_y + ( y_offset / 2 );
    }
  else
    {
      new_y	= ylo + ( box_size - font_height ) / 2;
    }

  if ( IT_IS_HILITED ( cklst ))
    {
      color = FI_GLINT;
    }
  else
    {
      color = OFF_COLOR ( cklst );
    }

  gc_values.foreground = FI_translate_color ( Xscreen, color );
  gc_values.background = FI_translate_color ( Xscreen,
						ERASE_COLOR( cklst ));

  XChangeGC ( _FI_display, _FI_gc,
	    (unsigned long) GCForeground | GCBackground, &gc_values );

  if ( display_all_flag )
    {
      unsigned char *text = cklst->FIgadget.text;

      if ( IT_HAS_TEXT( cklst ) &&  text )
        {
		/*** CHUNN find out why I have to add 4	***/
		/*** to a string with multiple lines.	***/

	  if ( num_lines > 1 )
	    {
	      new_x += 4;
	    }

	  _FI_g_draw_text ( (struct FIgadget_obj *)cklst, new_x, new_y, new_x2, new_y2,
			   text, num_lines, font_height,
			   NO_BORDERS, NO_ERASE );
        }
      else if ( IT_HAS_OFF_SYMBOL( cklst ))
        {
	  _FI_sym_draw ( window, new_x, new_y, cklst->FIgadget.font_id,
			& cklst->FIgadget.symbol_ptr,
			cklst->FIgadget.sym_width_scale_factor,
			cklst->FIgadget.sym_height_scale_factor, Xscreen );
        }
    }

  if ( IT_IS_DISABLED ( cklst )					&&
	(( cklst->FIgadget.attr_mask & FI_NO_DITHERING) == 0)    )
    {
      unsigned long gc_value_mask = GCForeground | GCFillStyle | GCStipple;

      gc_values.foreground = FI_translate_color ( Xscreen, FI_DK_FACE );
      gc_values.stipple    = _FIpix_gray50_array [Xscreen];
      gc_values.fill_style = FillStippled;
      XChangeGC ( _FI_display, _FI_gc, gc_value_mask, &gc_values );

      if ( cklst->FIgadget.value )
	{
		/* Disable check mark */

	  XFillRectangle ( _FI_display, window, _FI_gc,
			   xlo + CKLST_BEZEL_WIDTH + 2,
			   ylo + CKLST_BEZEL_WIDTH + 2,
			   box_size - ( 2 * CKLST_BEZEL_WIDTH ) - 4,
			   box_size - ( 2 * CKLST_BEZEL_WIDTH ) - 4  );
	}

	/* Calculate new_x2, new_y2 for icon */

      if ( IT_HAS_SYMBOL( cklst ))
	{
	  new_x2 = new_x + cklst->FIgadget.font_width;
	  new_y2 = new_y + cklst->FIgadget.font_height;
	}

	/* Disable text-icon */

      XSetForeground ( _FI_display, _FI_gc,
		FI_translate_color ( Xscreen, ERASE_COLOR ( cklst ) ) );

      XFillRectangle ( _FI_display, window, _FI_gc,
			new_x, new_y, new_x2 - new_x, new_y2 - new_y );

      XSetFillStyle ( _FI_display, _FI_gc, FillSolid );
    }

  return ( FI_SUCCESS );
}



void _FI_cklst_track_mouse (struct FIcklst_obj  *cklst,
                            Window               window,
                            int                 *complete,
                            double              *value)
{
  XSetForeground ( _FI_display, _FI_gc,
		   FI_translate_color ( cklst->FIgadget.form->Xscreen,
					cklst->FIgadget.form->bgcolor));

  *value = cklst->FIgadget.value = ! cklst->FIgadget.value;

  _FI_cklst_display ( cklst, window, 0 );

  *complete = TRUE;

  XFlush ( _FI_display );
}



void _FI_cklst_calc_coord (struct FIcklst_obj *cklst)
{
  int ylo	= cklst->FIgadget.ylo;
  int box_size	= cklst->FIcklst.box_size;
  int y_offset;
  int largest_width;


  if ( IT_HAS_TEXT ( cklst ))
    {
      largest_width = cklst->FIgadget.largest_width;
      y_offset = ( cklst->FIgadget.num_lines *
			cklst->FIgadget.font_height ) -
		    (( cklst->FIgadget.num_lines - 1) *
			( cklst->FIgadget.font_height / MLT_DIVISOR));
    }
  else
    {
      largest_width = cklst->FIgadget.font_width;
      y_offset = cklst->FIgadget.font_height;
    }

  /* Calculate the coordinates */

  cklst->FIgadget.xhi = cklst->FIgadget.xlo + largest_width +
				box_size + cklst->FIcklst.box_offset;

  if ( y_offset > box_size )
    {
      cklst->FIgadget.yhi = ylo + ( box_size / 2) + (y_offset / 2);
    }
  else
    {
      cklst->FIgadget.yhi = ylo + box_size;
    }
}


/* dmb:10/10/92:Change floats to doubles for ANSI */
int _FI_cklst_adjust (struct FIcklst_obj *cklst,
                      double              delta_x,
                      double              delta_y)
{
  /* dmb:10/10/92:Added casts for ANSI */
  cklst->FIgadget.xlo = (float)((double)cklst->FIgadget.xlo * delta_x);
  cklst->FIgadget.ylo = (float)((double)cklst->FIgadget.ylo * delta_y);

  /* Load new text font */

  if ( IT_HAS_TEXT( cklst ))
    {
        /***********************************************************/
        /*** ALERT !  ALERT !  STOP !  LOOK !  LISTEN !          ***/
        /***********************************************************/
        /*** _FI_g_change_text MAY CHANGE GADGET'S font_id !!!   ***/
        /*** _FI_g_change_text MAY CHANGE GADGET'S font_type !!! ***/
        /***********************************************************/

      _FI_g_change_text ( (struct FIgadget_obj *)cklst, delta_y );

	/*** Set largest_width to 1 meaning 	***/
	/*** calculate the largest width.	***/

      cklst->FIgadget.largest_width = 1;

     /* CHUNN NEW FONT */

      _FI_mlt_get_lines (  cklst->FIgadget.text,
			 (int *) & cklst->FIgadget.num_lines,
			 (int *) & cklst->FIgadget.largest_width,
			   cklst->FIgadget.font_id,
			   cklst->FIgadget.font_type );
    }
  else
    {
      /* dmb:10/10/92:Added casts for ANSI */
      cklst->FIgadget.sym_width_scale_factor  = (float) 
          ((double)cklst->FIgadget.sym_width_scale_factor * delta_x);
      cklst->FIgadget.sym_height_scale_factor = (float)
           ((double)cklst->FIgadget.sym_height_scale_factor * delta_y);

     /* Change bottom symbol */

      cklst->FIgadget.font_width =
		(float) cklst->FIgadget.symbol_ptr.orig_font_width *
			cklst->FIgadget.sym_width_scale_factor;

      cklst->FIgadget.font_height =
		(float) cklst->FIgadget.symbol_ptr.orig_font_height *
			cklst->FIgadget.sym_height_scale_factor;

      _FI_g_load_symbol ( (struct FIgadget_obj *)cklst );	/*** GMD:08/28/91 ***/
    }

  _FI_cklst_calc_coord ( cklst );

  return ( FI_SUCCESS );
}



int _FI_cklst_activate (struct FIcklst_obj *cklst)
{
  char	temp_path [ PATH_MAX + 1 ];


  if ( IT_HAS_TEXT ( cklst ))
    {
      int dummy1, dummy2;

        /***********************************************************/
        /*** ALERT !  ALERT !  STOP !  LOOK !  LISTEN !          ***/
        /***********************************************************/
        /*** _FI_g_change_text MAY CHANGE GADGET'S font_id !!!   ***/
        /*** _FI_g_change_text MAY CHANGE GADGET'S font_type !!! ***/
        /***********************************************************/

      _FI_g_change_text ( (struct FIgadget_obj *)cklst, 1.0);

     /* Calculate the box offset ( Width of a "j") */

     /* CHUNN NEW FONT */

      FI_calc_text ( cklst->FIgadget.font_id, "j", 1, &dummy1,
			&cklst->FIcklst.box_offset, &dummy2,
			cklst->FIgadget.font_type);

	/*** Set largest_width to 1 meaning 	***/
	/*** calculate the largest width.	***/

      cklst->FIgadget.largest_width = 1;

     /* CHUNN NEW FONT */

      _FI_mlt_get_lines (  cklst->FIgadget.text,
			 (int *) & cklst->FIgadget.num_lines,
			 (int *) & cklst->FIgadget.largest_width,
			   cklst->FIgadget.font_id,
			   cklst->FIgadget.font_type );
    }
  else
    {
     /* SYMBOL GADGET */

      _FI_g_load_symbol ( (struct FIgadget_obj *)cklst );

      cklst->FIcklst.box_offset = 10;

	/*** Set font size based on scale factors if form	***/
	/*** was scaled and the symbol was changed this will	***/
	/*** correct the problem.				***/

      cklst->FIgadget.font_width =
		(float) cklst->FIgadget.symbol_ptr.orig_font_width *
			cklst->FIgadget.sym_width_scale_factor;

      cklst->FIgadget.font_height =
		(float) cklst->FIgadget.symbol_ptr.orig_font_height *
			cklst->FIgadget.sym_height_scale_factor;
    }

  _FI_cklst_calc_coord ( cklst );

	/*** load checkmark in box ***/

  cklst->FIgadget.on_symbol_ptr.sym_index = 16;

  FI_find_symbol_path_and_id ( temp_path, "FIsym",
				& cklst->FIcklst.checkmark_id );

  if ( _FI_sym_load ( "FIsym", (struct FIgadget_obj *)cklst,
			&cklst->FIgadget.on_symbol_ptr ) )
    {
      cklst->FIgadget.on_symbol_ptr.pixmap = (Pixmap) 0;
    }

  cklst->FIcklst.font_width = cklst->FIgadget.on_symbol_ptr.sym_width;

  cklst->FIcklst.font_height = cklst->FIgadget.on_symbol_ptr.sym_height;


	/*** store original width and height ***/

  cklst->FIgadget.on_symbol_ptr.orig_font_width =
					cklst->FIcklst.font_width;

  cklst->FIgadget.on_symbol_ptr.orig_font_height =
					cklst->FIcklst.font_height;

  return ( FI_SUCCESS );
}



int _FI_cklst_find_gadget (struct FIcklst_obj    *cklst,
                           int                    xpos,
                           int                    ypos,
                           struct FIgadget_obj  **search_gadget)
{
  int xlo;
  int ylo;
  int xhi;
  int yhi;

  if (  ( IT_IS_NOT_DISPLAYABLE ( cklst )) ||
	( IT_IS_NOT_DISPLAYED   ( cklst )) ||
	( IT_IS_DISABLED ( cklst ))	    )
    {
      return ( FALSE );
    }

  _FI_cklst_get_area ( cklst, &xlo, &ylo, &xhi, &yhi );

  if ( (xpos >= xlo) && (xpos <= xhi ) &&
       (ypos >= ylo) && (ypos <= yhi )	)
    {
      *search_gadget = (struct FIgadget_obj *) cklst;

      return ( TRUE );
    }

  return ( FALSE );
}
