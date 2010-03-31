
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

#include <stdlib.h>
#include <stdio.h>

#include "wl.h"

#include "igrtypedef.h"
#include "igewindow.h"
#include "igr.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HSd_macros.h"

#include "HSpr_display.h"

/*---HSrepaint-------------------------------------------------------------------------*/

void HSrepaint( struct IGEdit_range *range )


{

   /* Currently, re-paint only acts on the entire window.  Later it will be
    * modified for sub sets of the window. */

   if( range )
      {
      active_window->x_min = range->xlo;
      active_window->y_min = range->ylo;
      active_window->x_max = range->xhi << 16;
      active_window->y_max = range->yhi;
      }
   else
      {
      active_window->x_min = 0;
      active_window->y_min = 0; 
      active_window->x_max = active_window->x_dits << 16;
      active_window->y_max = active_window->y_dits;
      }

   /* Erase repaint region */

   WLhide_cursor( active_window->win_no, TRUE );
   /*WLclear_window( active_window->win_no );*/

   /* Re-paint region */

   (*active_window->painter[active_window->active_zbuffer]) (  );

   WLshow_cursor( active_window->win_no );
   WLflush( active_window->win_no );

}  /* HSrepaint */
