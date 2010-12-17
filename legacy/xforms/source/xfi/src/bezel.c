#include "FImin.h"
#include "FIbezel.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

int _FI_bezel_display (struct FIbez_obj  *bezel,
                       Window             window)
{
   int t_l_color;
   int b_r_color;
   int edge_color;
   int Xscreen = XSCREEN(bezel);
   XRectangle rect;

   if (! _FI_is_in_clip_rectangle (& (bezel->FIgadget)))
	  return (FI_SUCCESS);

   if (bezel->FIgadget.value)
   {
	  t_l_color = FI_SHADOW;
	  b_r_color = FI_GLINT;
   }
   else
   {
	  t_l_color = FI_GLINT;
	  b_r_color = FI_SHADOW;
   }

   if (IT_IS_HILITED(bezel))
	  edge_color = FI_GLINT;
   else
	  edge_color = FI_EDGE;

   _FI_clipping_off ((struct FIgadget_obj *)bezel);   /* Set clipping if necessary */

   /* GMD 3/24/92 */

    rect.x = bezel->FIgadget.xlo;
    rect.y = bezel->FIgadget.ylo;
    rect.width  = bezel->FIgadget.xhi - bezel->FIgadget.xlo;
    rect.height = bezel->FIgadget.yhi - bezel->FIgadget.ylo;

    if ( _FI_form_clipping_on )
    {
      _FI_adjust_clip_rectangle ( &rect );	/** Due to text **/
    }

    XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &rect, 1, Unsorted );

   _FI_draw_bezel (window, (int) bezel->FIgadget.xlo, (int) bezel->FIgadget.ylo, (int) bezel->FIgadget.xhi, (int) bezel->FIgadget.yhi, BEZEL_GADGET_BEZEL, FI_translate_color (Xscreen, t_l_color), FI_translate_color (Xscreen, OFF_COLOR(bezel)), FI_translate_color (Xscreen, b_r_color), FI_translate_color (Xscreen, edge_color), SQUARE);

    rect.x = 0;
    rect.y = 0;
    rect.width  = 2000;
    rect.height = 2000;

    if ( _FI_form_clipping_on )
    {
      _FI_adjust_clip_rectangle ( &rect );	/** Due to text **/
    }

    XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &rect, 1, Unsorted );

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
   if (!_FI_dont_flush)
     XFlush ( _FI_display );

   XFlush (_FI_display);
   return (FI_SUCCESS);	/* dmb:03/27/91:Added */

}
