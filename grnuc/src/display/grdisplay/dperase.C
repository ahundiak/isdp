/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME	DPerase         
 
     Abstract:		
		This module take pointer to hardware window number and
                pointer to window extents as input, erase the window.
-----
%SC%
     VALUE = DPerase(msg, win_no, rng)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
        win_no     IGRint                   hardware window no.   
        rng       struct DPdit_range        window size
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION

     ----------   ------------   -----------------------------------
     msg           IGRlong 	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure occurred

     VALUE (IGRint)     = TRUE	    - if successful
		          FALSE	    - if failure
-----
%MD%
     MODULES INVOKED:
-----
%NB%
     NOTES:
-----
%CH%
     CHANGE HISTORY:
	
	ht  2/12/86  : Design date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
	
           This program get hardware window number and size of window
       as input, call tools routine to find out bgcolor and erase
       the window. (repaint with bgcolor)

	10/26/92  there is a kludge that needed to be added.  Gpipe does 
	          not draw the right hand side when a filled polygon is
	          clipped, and they are not going to fix it.  There for 
	          whenever the window x_max is not the right hand side of 
	          the window subtract 1 and since the refresh area will
	          be one bigger it will work.  
	          	For X there is a bug currently in there in which you
	          should be sending in xmax-xmin+1.  But since the problem
	          does not show up for X we will leave it alone.  (i.e.:
	          the 2 wrongs make a right.) 
	          	‚Joel Underwood
----*/
/*EH*/

#include "grimport.h"
#include <stdlib.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dp.h"
#include "dpdef.h"
#include "msdef.h"
#include "dpstruct.h"

#include "wl.h"
#include "igecolordef.h"

/* prototype files */
#include "dperase.h"

IGRint DPerase( msg, win_no, rng )

IGRlong *msg;
IGRint *win_no;
struct DPdit_range *rng;

{
   WLcolorref color_ref;
   struct WLrect rect;
#if defined( ENV5 )
   struct WLbounds bounds, area_bounds;
#endif

   *msg = MSSUCC;

#if defined( ENV5 )
   /* This is an EnvV kludge to subtract one off the width of the */
   /* region to erase if the region doesn't extend to the end of */
   /* the window                                                 */
   WLget_window_bounds( *win_no, &bounds, &area_bounds );
   if ( (rng->xhi < rng->xlo + area_bounds.width -1 ) && (rng->xhi > rng->xlo) )
   {
      rng->xhi--;
   }
#endif

   /* set the active foreground color to the background color */
   WLpack_index_colorref( IGE_LOGICAL_BACKGROUND, &color_ref, FALSE );
   WLset_active_symbology( *win_no, color_ref, 0, 0, 0, 
                           WL_SYMB_CHANGE_COLOR );
   rect.x = rng->xlo;
   rect.y = rng->ylo;
   rect.width = rng->xhi - rng->xlo + 1;
   rect.height = rng->yhi - rng->ylo + 1;

   WLset_blendarea( *win_no, NULL, TRUE );
   WLdraw_rectangle( *win_no, &rect, WL_FILL );

   return( (1 & (*msg) ) ? 1 : 0 );

}  /* DPerase */
