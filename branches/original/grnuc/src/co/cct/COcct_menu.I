class implementation COcctform;

/*
 *   Filename:   COcct_menu.I
 *   Programmer:   C. M. Jablonski
 *   Creation Date:   January 1989
 *
 *   This file contains the actions that manipulate the color mix menus:
 *
 *   update_rgb_gadgets   - updates the rgb gadgets with the active values
 *
 *   update_hls_gadgets   - updates the hls gadgets with the active values
 *
 *   set_slider_maximum   - updates the slider maximum value
 *
 *   update_active_color_display - update everything affected by the 
 *                                 active color 
 *
 *   History:
 */


#include <stdio.h>
#ifdef X11
static Pixmap  default_pattern, pallet_pattern;
#endif
#include "cct.h"

/*----- update_rgb_gadgets ---------------------------------------------------*/
method update_rgb_gadgets ( long * sts )
{
/*
NAME
   COcctform.update_rgb_gadgets
DESCRIPTION
   This updates the rgb gadgets to the current values
PARAMETERS
   sts (out) - the status of the operations
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   double r, g, b;

   r = (me->curr_red * me->slider_maximum) + 0.00005;
   g = (me->curr_green * me->slider_maximum) + 0.00005;
   b = (me->curr_blue * me->slider_maximum) + 0.00005;

#if defined ( DEBUG_CCT )
   printf("update_rgb_gadgets: r %lf g %lf b %lf \n",r,g,b);
#endif
   
   FIg_set_value ( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_RED, r);
   FIg_set_value ( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_RED, r);
   FIg_set_value ( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_GREEN, g); 
   FIg_set_value ( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_GREEN, g); 
   FIg_set_value ( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_BLUE, b);
   FIg_set_value ( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_BLUE, b);

   *sts = OM_S_SUCCESS;
   return( OM_S_SUCCESS );
}


/*----- update_hls_gadgets ---------------------------------------------------*/
method update_hls_gadgets ( long * sts )

{
/*
NAME
   COcctform.update_hls_gadgets
DESCRIPTION
   This updates the hls gadgets to the current values
PARAMETERS
   sts (out) - the status of the operations
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   IGRdouble h, l, s;

   rgb_to_hls( me->curr_red, me->curr_green, me->curr_blue, 
      &me->curr_hue, &me->curr_luminance, &me->curr_saturation );
   h = (( me->curr_hue * me->slider_maximum) / 359.99) + 0.00005;
   l = ( me->curr_luminance * me->slider_maximum) + 0.00005;
   s = ( me->curr_saturation * me->slider_maximum) + 0.00005;

#if defined ( DEBUG_CCT )
   printf("update_hls_gadgets: h %lf l %lf s %lf \n",h,l,s);
#endif

   FIg_set_value ( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_HUE, h );
   FIg_set_value ( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_HUE, h );
   FIg_set_value ( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_LUMINANCE, l );
   FIg_set_value ( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_LUMINANCE, l );
   FIg_set_value ( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_SATURATION, s );
   FIg_set_value ( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_SATURATION, s );

   *sts = OM_S_SUCCESS;
   return( OM_S_SUCCESS );
}


/*----- set_slider_maximum ---------------------------------------------------*/
method set_slider_maximum ( double maximum )
{
/*
NAME
   COcctform.set_slider_maximum
DESCRIPTION
   sets the maximum value of the rgb and hls gadgets
PARAMETERS
   maximum (in) - the maximum value of the gadgets
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   /* set the value */
   me->slider_maximum = maximum;

   /* update the slider ranges */
   FIg_set_high_value ( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_RED, me->slider_maximum);
   FIg_set_high_value ( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_RED, me->slider_maximum);
   FIg_set_high_value ( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_GREEN, me->slider_maximum);
   FIg_set_high_value ( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_GREEN, me->slider_maximum);
   FIg_set_high_value ( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_BLUE, me->slider_maximum);
   FIg_set_high_value ( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_BLUE, me->slider_maximum);
   FIg_set_high_value ( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_HUE, me->slider_maximum);
   FIg_set_high_value ( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_HUE, me->slider_maximum);
   FIg_set_high_value ( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_LUMINANCE, me->slider_maximum);
   FIg_set_high_value ( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_LUMINANCE, me->slider_maximum);
   FIg_set_high_value ( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_SATURATION, me->slider_maximum);
   FIg_set_high_value ( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_SATURATION, me->slider_maximum);

   return( OM_S_SUCCESS );
}


/*----- update_active_color_display -------------------------------------------------------*/
method update_active_color_display ( long * sts )
{
/*
NAME
   COcctform.update_active_color_display
DESCRIPTION
   This function updates gadgets and redraws curr_color indications on form
   i.e.; everything affected by the current color is drawn/updated
PARAMETERS
   sts (out) - status of the method
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   /* update the keyin fields as well */
   *sts = om$send(   msg      = message COcctform.update_rgb_gadgets( sts ),
         targetid   = my_id );
   *sts = om$send(   msg      = message COcctform.update_hls_gadgets( sts ),
         targetid   = my_id );

   *sts = om$send(   msg      = message COcctform.draw_color_block(sts),
         targetid   = my_id );
   *sts = om$send(   msg      = message COcctform.draw_lum_range(sts),
         targetid   = my_id );
   *sts = om$send(   msg      = message COcctform.draw_cross_hairs( sts ),
         targetid   = my_id );
   *sts = om$send(   msg      = message COcctform.draw_lum_ptr(sts),
         targetid   = my_id );

   *sts = OM_S_SUCCESS;
   return (OM_S_SUCCESS);
}

end implementation COcctform;
