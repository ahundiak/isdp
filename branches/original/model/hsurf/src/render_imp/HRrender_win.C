
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

#if defined (X11)
#define         MESSAGE_STRIP_HEIGHT    54
#endif 

#include <stdio.h>
#include "wl.h"

#include "dpgraphics.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"

#include "igecolor.h"
#include "igecolordef.h"
#include "HSpr_render.h"

/*------------------------
 *  for functions
 *     HSgetMachineInfo
 *     HSassign_edgeII_vlt_to_window
 */
 
#include "hsurf.h"
#include "HSpr_dpb_imp.h"

/*--------------------------*/


#include "igrtypedef.h"
#include "igecolmacros.h"

#include "hsmachine.h"

/*--- HRinit_rendering_window ---------------------------------------------*/

void HRinit_rendering_window( WLuint32  *context_no,
			      WLuint32  *win_no,
			      int       *x_dits,
			      int       *y_dits,
			      int       ignore_edgeII )
			    
/*
DESCRIPTION
	This function creates the full screen window used for rendering
	mode and initializes the color table for rendering.  It returns
	the window number and the x and y size of the window in dits.

HISTORY
	S.P. Rogers  09/07/89  Creation Date
	S.P. Rogers  03/13/90  Changed to support TRUE COLOR
	R. Druzynski 07/12/91  Changed to support 8 or 24 bit display on edgeII
	S.P. Rogers  03/26/92  Changed to use new DPx functions to add window
	                       to EX_win array
        R. Druzynski 05/24/93  Converted to use WL calls for portability

*/

{
   WLuint16               lscreen_no;
   struct WLbounds        bounds;
   struct WLcontext_info  info;
   int                    screen_type;
   int                    width;
   int                    height;
   int                    sts;
   int                    depth;
   WLcolorref             color_ref;

   /* construct a hardware window that covers the entire screen */
   sts = WLget_active_screen( &lscreen_no, &screen_type );
   if( sts != WL_SUCCESS)
   {
#ifdef DEBUG
      fprintf(stderr, "Error getting active screen; Error %d\n", sts);
#endif
   }

   sts = WLget_screen_size( lscreen_no, &width, &height );
   if( sts != WL_SUCCESS)
   {
#ifdef DEBUG
      fprintf(stderr, "Error getting screen size; Error %d\n", sts);
#endif
   }
   
   *x_dits = width;
   *y_dits = height - MESSAGE_STRIP_HEIGHT;

   bounds.x      = 0;
   bounds.y      = 56;
   bounds.width  = *x_dits;
   bounds.height = *y_dits;

   /* get the default context of the screen */
   CMget_active_context( lscreen_no, context_no );

   /* get context_depth to see if on a 24 bit true color machine */
   WLget_context_depth( *context_no, &depth );

   if( depth >= 24 )
   {
      /* On a true color machine.  If ignore_edgeII parameter is true, */
      /* we need to create a new 8 bit context for the window.         */

      if( ignore_edgeII )
      {
         WLget_context_info( *context_no, &info );

         info.base_depth     = 8;
         info.base_cmap_type = WL_CMAP_INDEXED;

         WLcreate_context( lscreen_no, 
                           &info,
                           IGEcmap_color_to_index,
                           IGEcmap_color_to_rgb,
                           IGEcmap_init,
                           context_no);
      }
   }
   
   sts = WLcreate_window( lscreen_no, "Render", &bounds, 0, *context_no, 
                          win_no);

   if( sts != WL_SUCCESS )
   {
#ifdef DEBUG
      fprintf(stderr, "Error creating window\n");
#endif
      win_no = NULL;
   }
   else
   {
      WLdisplay_window( *win_no );

      WLflush( *win_no );

      /* set the background color of the window to the Ems background color */
      WLpack_index_colorref( IGE_LOGICAL_BACKGROUND, &color_ref, FALSE );
      WLset_background( *win_no, color_ref );
      WLclear_window( *win_no );
   }
} /* HRinit_rendering_window() */


/*--- HRdelete_rendering_window ---------------------------------------------*/

void HRdelete_rendering_window( WLuint32  win_no,
				int       ignore_edgeII )

/*
DESCRIPTION
	This function deletes the full screen window.

HISTORY
	S.P. Rogers  09/07/89  Creation Date
	S.P. Rogers  03/13/90  Changed to support TRUE COLOR
	R. Druzynski 07/12/91  Changed to support 8 or 24 bit mode on edgeII
	S.P. Rogers  03/26/92  Changed to use new DPx functions to delete window
	                       from EX_win array
        R. Druzynski 05/24/93  Converted to use WL calls for portability

*/

{
   int sts;

   sts = WLdelete_window( win_no );
   if( sts != WL_SUCCESS )
   {
#ifdef DEBUG
      fprintf(stderr, " Error deleting window\n");
#endif
   }
} /* HRdelete_rendering_window() */
