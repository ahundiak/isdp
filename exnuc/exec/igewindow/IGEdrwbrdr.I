/*

        CLASS NAME:     IGEwindow
        METHOD NAME:    draw_border

        Abstract:
         Draw window border - currently only does work for ENV5

        CHANGE HISTORY

        HT   04/28/86  : Creation date.

*/

class implementation IGEwindow;

#ifdef ENV5
#include <tools.h>
#include <sdl.h>
#include <wl.h>
#endif

#include "igewindef.h"
#include "igewinmacros.h"


method draw_border ( IGRint color_index )
{

#ifdef ENV5
   IGRshort	x_low;
   IGRshort	x_high;
   IGRshort	y_low;
   IGRshort	y_high;
   IGRshort	x;
   IGRshort	y;
   IGRint	clip_x_min;
   IGRint	clip_y_min;
   IGRint	clip_x_max;
   IGRint	clip_y_max;
   IGRint	x_extent;
   IGRint	y_extent;
   IGRint	bckgnd_planes;
   IGRint	hilite_plane;
   int		sts;
   int		screen_no;
   int		lscreen_type;
   WLuint16	lscreen;
   WLuint32	ctx_num;
   int		hw_win;
   struct WLnative_info native_info;


   if ((ME.IGEwindow->right_space  != 0) || 
       (ME.IGEwindow->left_space   != 0) || 
       (ME.IGEwindow->top_space    != 0) || 
       (ME.IGEwindow->bottom_space != 0))
   {
      screen_no = EX_multi_screen ( ME.IGEwindow->screen_no );

      ige$inq_term_info ( screen_no         = screen_no,
                          background_planes = &bckgnd_planes,
                          hilite_plane      = &hilite_plane );

      x_extent = ME.IGEgadget->max_x_dep - ME.IGEgadget->min_x_dep;
      y_extent = ME.IGEgadget->max_y_dep - ME.IGEgadget->min_y_dep;

      clip_x_min = (- ME.IGEwindow->left_space);
      clip_y_min = (- ME.IGEwindow->top_space);
      clip_x_max = x_extent + ME.IGEwindow->right_space;
      clip_y_max = y_extent + ME.IGEwindow->bottom_space;

      /*=============================================================*/
      /*  Get the Env5 window number from the logical window number  */
      /*=============================================================*/

      sts = WLget_active_screen ( &lscreen, &lscreen_type );
      if (sts != WL_SUCCESS) 
      {
         return (OM_E_ERROR);
      }

      sts = CMget_active_context ( lscreen, &ctx_num );
      if (sts != WL_SUCCESS) 
      {
         return (OM_E_ERROR);
      }

      sts = WLget_native_info ( ME.IGEgadget->win_no, ctx_num, &native_info );
      if (sts != WL_SUCCESS) 
      {
         return (OM_E_ERROR);
      }

      hw_win = native_info.base_win;

      clipbox ( hw_win, clip_x_min, clip_y_min, clip_x_max, clip_y_max );

      enableplane ( hw_win, bckgnd_planes );

      fgcolor ( hw_win, color_index );
      linestyle ( hw_win, 0xffff );
      weight ( hw_win, 0 );
      blendline ( hw_win, 0xffff );
      hidecursor ( hw_win );

      /*  draw left border  */

      if (ME.IGEwindow->left_space != 0)
      {	
         x_low = (- ME.IGEwindow->left_space);
         x_high = 0;
         y_low = (- ME.IGEwindow->top_space);
         y_high = y_extent + ME.IGEwindow->bottom_space;

         for (x = x_low; x < x_high; x++)
         {
            move ( hw_win, x, y_low );
            draw ( hw_win ,x, y_high );
         }
      }

      /*  draw right border  */

      if (ME.IGEwindow->right_space != 0)
      {	
         x_low = x_extent + 1;
         x_high = x_extent + ME.IGEwindow->right_space +1 ;
         y_low = (- ME.IGEwindow->top_space);
         y_high = y_extent + ME.IGEwindow->bottom_space;

         for (x = x_low; x < x_high; x++)
         {
            move ( hw_win, x, y_low );
            draw ( hw_win, x, y_high );
         }
      }

      /*  draw top border  */

      if (ME.IGEwindow->top_space != 0)
      {	
         x_low = 0;
         x_high =  x_extent;
         y_low = (- ME.IGEwindow->top_space);
         y_high = 0;

         for (y = y_low; y < y_high; y++)
         {
            move ( hw_win, x_low, y );
            draw ( hw_win, x_high, y );
         }
      }

      /*  draw bottom border  */
	
      if (ME.IGEwindow->bottom_space != 0)
      {	
         x_low = 0;
         x_high =  x_extent;
         y_low = y_extent + 1;
         y_high = y_extent + ME.IGEwindow->bottom_space + 1;

         for (y = y_low; y < y_high; y++)
         {
            move ( hw_win, x_low, y );
            draw ( hw_win, x_high, y );
         }
      }

      showcursor ( hw_win );
      flushbuffer ( hw_win );
      enableplane ( hw_win, bckgnd_planes );

      clip_x_min = 0;
      clip_y_min = 0;
      clip_x_max = x_extent;
      clip_y_max = y_extent;

      clipbox ( hw_win, clip_x_min, clip_y_min, clip_x_max, clip_y_max );

   }
#endif

   return(1);
}

end implementation IGEwindow;
