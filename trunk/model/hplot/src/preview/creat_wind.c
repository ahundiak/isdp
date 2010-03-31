#include "stdio.h"
#include "wl.h"
#include "error.h"
#include "memory.h"
#include "cmap.h"

#define	FALSE	0

/*--- create_window --------------------------------------------*/

WLuint32 create_window( WLuint16 screen_no,
                        WLuint32 context_no,
                        int x, 
                        int y,
                        int width,
                        int height,
                        WLuint32 *lwin_no,
                        struct WLraster_data *image,
                        char **image_buffer )

   {
   int			sts;
   char			name[256];
   struct WLbounds	bounds;
   WLcolorref		bcolor;

   strcpy( name, "preview" );
   
   bounds.x = x;
   bounds.y = y;
   bounds.width = width;
   bounds.height = height;

   sts = WLcreate_window (screen_no, 
                          name, 
                          &bounds, 
                          5, 
                          context_no, 
                          lwin_no);
   CHECK_WL_ERROR (sts);

   sts = WLinstall_cmap (*lwin_no, context_no);

   WLset_event_mask( *lwin_no, 
      WL_BUTTON |
      WL_KEY |
      WL_USER |
      WL_SWAP_SCREEN |
      WL_TIMER |
      WL_DELETE |
      WL_EXPOSE |
      WL_ENTER_LEAVE_WIN |
      WL_POINTER_MOTION |
      WL_COLLAPSE |
      WL_COLORMAP_NOTIFY );

   sts = WLpack_index_colorref (BLACK, &bcolor, FALSE);
   CHECK_WL_ERROR (sts);

   sts = WLset_background (*lwin_no, bcolor);

   sts = WLdisplay_window (*lwin_no);
   CHECK_WL_ERROR (sts);

   sts = WLclear_window (*lwin_no);
   CHECK_WL_ERROR (sts);

   WLenable_hilite( *lwin_no );

   *image_buffer = MALLOCn( char, (bounds.width * bounds.height));

   WLcreate_raster_data (*lwin_no, 
                         context_no, 
                         image,
                         0, 0, 
                         bounds.width, bounds.height, 
                         8, 
                         WL_SLOW_BUFFER, 
                         (char *) *image_buffer);

   return WL_SUCCESS;
   }    /* create_window */
