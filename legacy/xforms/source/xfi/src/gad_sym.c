#include "FImin.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"


void _FI_g_load_symbol (struct FIgadget_obj *gadget)
{
   int type;

   /* ISDP Add check for NULL */
   if (gadget == NULL) {
     return;
   }
   type = gadget->FIgadget.type;

   /* first free any pixmaps that have been created. */

   _FI_g_free_symbols (gadget);

   if (! gadget->FIgadget.fontname)
     {
	  return;
     }

   FI_find_symbol_path_and_id (FI_data, gadget->FIgadget.fontname, &gadget->FIgadget.font_id);

   /* Setup bottom symbol */

   if (_FI_sym_load (gadget->FIgadget.fontname, gadget, &gadget->FIgadget.symbol_ptr))
   {
/* Do Nothing */
/*	  gadget->FIgadget.symbol_ptr.bitmap = 0; */
   }
   else
   {
	  gadget->FIgadget.symbol_ptr.orig_font_width =
			gadget->FIgadget.symbol_ptr.sym_width;

	  gadget->FIgadget.symbol_ptr.orig_font_height =
			gadget->FIgadget.symbol_ptr.sym_height;

	/*** Multiply by scale factors for case where form is     ***/
	/*** scaled up before any symbol is changed on the gadget ***/

	gadget->FIgadget.font_width =
	   (float) gadget->FIgadget.symbol_ptr.orig_font_width *
		gadget->FIgadget.sym_width_scale_factor;

	gadget->FIgadget.font_height =
	   (float) gadget->FIgadget.symbol_ptr.orig_font_height *
		gadget->FIgadget.sym_height_scale_factor;

        if ((gadget->FIgadget.sym_height_scale_factor > 0.95) &&
            (gadget->FIgadget.sym_height_scale_factor < 1.05) &&
            (gadget->FIgadget.sym_width_scale_factor > 0.95)  &&
            (gadget->FIgadget.sym_width_scale_factor < 1.05))
        {
           /* Do not create pixmap, since scaling is not needed */
        }
        else
        {
           /* create scaled pixmap */

   if (gadget->FIgadget.sym_width_scale_factor  < 1.0 &&
       gadget->FIgadget.sym_height_scale_factor < 1.0)
   {
      _FI_sym_scale_down_x_down_y (XWINDOW(gadget), 
                                    & gadget->FIgadget.symbol_ptr, 
                            (double) gadget->FIgadget.sym_width_scale_factor,
                            (double) gadget->FIgadget.sym_height_scale_factor,
                                     gadget->FIgadget.font_id);
   }
   else if (gadget->FIgadget.sym_width_scale_factor  >= 1.0 &&
            gadget->FIgadget.sym_height_scale_factor >= 1.0)
   {
      _FI_sym_scale_up_x_up_y (XWINDOW(gadget), 
                                   & gadget->FIgadget.symbol_ptr, 
                            (double) gadget->FIgadget.sym_width_scale_factor,
                            (double) gadget->FIgadget.sym_height_scale_factor,
                                     gadget->FIgadget.font_id);
   }
   else if (gadget->FIgadget.sym_width_scale_factor  <  1.0 && 
            gadget->FIgadget.sym_height_scale_factor >= 1.0)
   {
      _FI_sym_scale_down_x_up_y (XWINDOW(gadget), 
                                   & gadget->FIgadget.symbol_ptr, 
                            (double) gadget->FIgadget.sym_width_scale_factor,
                            (double) gadget->FIgadget.sym_height_scale_factor,
                                     gadget->FIgadget.font_id);
   }
   else	/* if (scale_factor_x >= 1.0 && scale_factor_y < 1.0) */
   {
      _FI_sym_scale_up_x_down_y (XWINDOW(gadget), 
                                   & gadget->FIgadget.symbol_ptr, 
                            (double) gadget->FIgadget.sym_width_scale_factor,
                            (double) gadget->FIgadget.sym_height_scale_factor,
                                     gadget->FIgadget.font_id);
   }
        }
   }

   /* Setup top symbol if exists */

   if (((type == FI_BUTTON) || (type == FI_TOGGLE)) && (gadget->FIgadget.on_symbol_ptr.sym_index > 0))
   {
      /* Load top symbol */

	  if (_FI_sym_load (gadget->FIgadget.fontname, gadget, &gadget->FIgadget.on_symbol_ptr))
	  {
/* Do Nothing */
/*		 gadget->FIgadget.on_symbol_ptr.bitmap = 0; */
	  }
	  else
	  {
		 gadget->FIgadget.on_font_width =
			gadget->FIgadget.on_symbol_ptr.sym_width;

		 gadget->FIgadget.on_font_height =
			gadget->FIgadget.on_symbol_ptr.sym_height;

         /* store original width and height */

		 gadget->FIgadget.on_symbol_ptr.orig_font_width =
					gadget->FIgadget.on_font_width;
		 gadget->FIgadget.on_symbol_ptr.orig_font_height =
					gadget->FIgadget.on_font_height;

              if ((gadget->FIgadget.sym_height_scale_factor > 0.95) &&
                  (gadget->FIgadget.sym_height_scale_factor < 1.05) &&
                  (gadget->FIgadget.sym_width_scale_factor > 0.95)  &&
                  (gadget->FIgadget.sym_width_scale_factor < 1.05))
              {
                 /* Do not create pixmap, since scaling is not needed */
              }
              else
              {
                 /* create scaled pixmap */ 

   if (gadget->FIgadget.sym_width_scale_factor  < 1.0 &&
       gadget->FIgadget.sym_height_scale_factor < 1.0)
   {
      _FI_sym_scale_down_x_down_y (XWINDOW(gadget), 
                                    & gadget->FIgadget.on_symbol_ptr, 
                            (double) gadget->FIgadget.sym_width_scale_factor,
                            (double) gadget->FIgadget.sym_height_scale_factor,
                                     gadget->FIgadget.font_id);
   }
   else if (gadget->FIgadget.sym_width_scale_factor  >= 1.0 &&
            gadget->FIgadget.sym_height_scale_factor >= 1.0)
   {
      _FI_sym_scale_up_x_up_y (XWINDOW(gadget), 
                                    & gadget->FIgadget.on_symbol_ptr, 
                            (double) gadget->FIgadget.sym_width_scale_factor,
                            (double) gadget->FIgadget.sym_height_scale_factor,
                                     gadget->FIgadget.font_id);
   }
   else if (gadget->FIgadget.sym_width_scale_factor  <  1.0 && 
            gadget->FIgadget.sym_height_scale_factor >= 1.0)
   {
      _FI_sym_scale_down_x_up_y (XWINDOW(gadget), 
                                    & gadget->FIgadget.on_symbol_ptr, 
                            (double) gadget->FIgadget.sym_width_scale_factor,
                            (double) gadget->FIgadget.sym_height_scale_factor,
                                     gadget->FIgadget.font_id);
   }
   else	/* if (scale_factor_x >= 1.0 && scale_factor_y < 1.0) */
   {
      _FI_sym_scale_up_x_down_y (XWINDOW(gadget), 
                                    & gadget->FIgadget.on_symbol_ptr, 
                            (double) gadget->FIgadget.sym_width_scale_factor,
                            (double) gadget->FIgadget.sym_height_scale_factor,
                                     gadget->FIgadget.font_id);
   }
              }
	  }
   }
}


void _FI_g_change_symbol (struct FIgadget_obj *gadget)
{
   float delta_x;
   float delta_y;
   int xsize;
   int ysize;

   /* ISDP Add check for NULL */
   if (gadget == NULL) {
     return;
   }
   xsize = gadget->FIgadget.xhi - gadget->FIgadget.xlo;
   ysize = gadget->FIgadget.yhi - gadget->FIgadget.ylo;

    /*** CHUNN The orig size is used so we can scale relative to ***/
    /***    a gadget and it's readin size versus the forms size  ***/
    /***    This doesn't work for the checklist gadget 		 ***/

   delta_x = (float) xsize / (float) gadget->FIgadget.orig_xsize;
   delta_y = (float) ysize / (float) gadget->FIgadget.orig_ysize;

   gadget->FIgadget.sym_width_scale_factor  = delta_x;
   gadget->FIgadget.sym_height_scale_factor = delta_y;

   /* Change bottom symbol */

   gadget->FIgadget.font_width = (float) gadget->FIgadget.symbol_ptr.orig_font_width * gadget->FIgadget.sym_width_scale_factor;

   gadget->FIgadget.font_height = (float) gadget->FIgadget.symbol_ptr.orig_font_height * gadget->FIgadget.sym_height_scale_factor;

   /* Change top symbol */

/* Test Nothing, just do it */
/*   if (gadget->FIgadget.on_symbol_ptr.bitmap) */
   {
	  gadget->FIgadget.on_font_width = (float) gadget->FIgadget.on_symbol_ptr.orig_font_width * gadget->FIgadget.sym_width_scale_factor;

	  gadget->FIgadget.on_font_height = (float) gadget->FIgadget.on_symbol_ptr.orig_font_height * gadget->FIgadget.sym_height_scale_factor;
   }
}









