
/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	IGEwindow
	METHOD NAME:	move_window

	Abstract:
		This method will change the position of a window
-----
%SC%

	VALUE = move_window (*msg ,xlo, ylo, xhi, yhi)

-----
%EN%

	ON ENTRY:
									
	NAME       DATA TYPE      	    DESCRIPTION
     ----------   ------------   -----------------------------------
	
-----
%EX%

	ON EXIT:

	NAME       DATA TYPE      	    DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg         IGRlong         return condition code
				
-----
%RL%

	RELATIONS REFERENCED:


-----
%NB%

	NOTES:

-----
%CH%

	CHANGE HISTORY

	AET   04/20/87  : Creation date.

-----
%PD%
--------------------------------------------------------------------
		M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
      This method will calculate the actual position of the window 
	depending if it is borderless or not and then send a movicon 
	message if the window is active.
----*/
/*EH*/

class implementation IGEwindow;

#include "exnucimport.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "wl.h"

method move_window ( IGRlong *msg; IGRint xlo, ylo, xhi, yhi )
{	
   IGRlong          status = TRUE;
   IGRint           flag  = 2;  /*  move and stretch value  */
   IGRint           x_extent;
   IGRint           y_extent;
   struct WLbounds  bounds;

   if (ME.IGEwindow->flags & WIN_IS_ACTIVE)
   {
      if (ME.IGEwindow->win_type == BORDER)
      {
         bounds.x      = xlo;
         bounds.y      = ylo;
         bounds.width  = xhi - xlo + 1;
         bounds.height = yhi - ylo + 1;

         status = WLset_window_bounds ( ME.IGEgadget->win_no, &bounds );
         if (status != WL_SUCCESS)
         {
            *msg = OM_E_ERROR;
            return (OM_E_ERROR);
         }

         status = om$send ( msg = message IGEwindow.movicon (msg,
                                     &ME.IGEgadget->win_no, &flag, &xlo, &ylo,
                                     &xhi, &yhi),
                            targetid = my_id );
         if (!(1&status)) return (status)
      }
      else
      {
         xlo -= ME.IGEwindow->left_space;
         ylo -= ME.IGEwindow->top_space;
         xhi += ME.IGEwindow->right_space;
         yhi += ME.IGEwindow->bottom_space;

         bounds.x      = xlo;
         bounds.y      = ylo;
         bounds.width  = xhi - xlo + 1;
         bounds.height = yhi - ylo + 1;

         status = WLset_window_bounds ( ME.IGEgadget->win_no, &bounds );
         if (status != WL_SUCCESS)
         {
            *msg = OM_E_ERROR;
            return (OM_E_ERROR);
         }

         status = om$send ( msg = message IGEwindow.movicon ( msg,
                                  &ME.IGEgadget->win_no, &flag, &xlo, &ylo,
                                  &xhi, &yhi ),
                            targetid = my_id);
         if (!(1&status)) return (status);
      }
   }
   else
   {
      ME.IGEgadget->min_x_dep = xlo;
      ME.IGEgadget->min_y_dep = ylo;
      ME.IGEgadget->max_x_dep = xhi;
      ME.IGEgadget->max_y_dep = yhi;

      /*  recalculate independent extents  */

      ige$inq_term_info ( x_extent = &x_extent,
                          y_extent = &y_extent );

      x_extent--;
      y_extent--;

      ME.IGEgadget->min_x_indep = (IGRdouble) xlo/x_extent;
      ME.IGEgadget->min_y_indep = (IGRdouble) ylo/y_extent;
      ME.IGEgadget->max_x_indep = (IGRdouble) xhi/x_extent;
      ME.IGEgadget->max_y_indep = (IGRdouble) yhi/y_extent;
   }
   return ( status );
}

end implementation IGEwindow;
