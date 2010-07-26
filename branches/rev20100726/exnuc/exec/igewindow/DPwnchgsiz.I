class implementation IGEwindow;

#include "igewindef.h"
#include "igewinmacros.h"
#include "wl.h"

method change_gadget_size (IGRlong *msg; IGRint dep_indep;
			   IGRdouble min_x, min_y, max_x, max_y)

{
   IGRlong status = TRUE;
   IGRint  flag = 2; /* move and stretch value */
   IGRint  screen_no;
   IGRint  x_extent;
   IGRint  y_extent;
   IGRint  old_x_extent;
   IGRint  old_y_extent;
   IGRint  new_x_extent;
   IGRint  new_y_extent;
   IGRint  min_x_dep;
   IGRint  min_y_dep;
   IGRint  max_x_dep;
   IGRint  max_y_dep;
   struct WLbounds bounds;

   *msg = MSSUCC;

   screen_no = EX_multi_screen ( ME.IGEwindow->screen_no );

   ige$inq_term_info ( screen_no = screen_no,
                       x_extent  = &x_extent,
                       y_extent  = &y_extent);

   x_extent--;
   y_extent--;

   if (dep_indep == IGE_INDEPENDENT)
   {
      min_x_dep = (min_x * x_extent) + 0.5;
      min_y_dep = (min_y * y_extent) + 0.5;
      max_x_dep = (max_x * x_extent) + 0.5;
      max_y_dep = (max_y * y_extent) + 0.5;
   }
   else
   {
      min_x_dep = min_x + 0.5;
      min_y_dep = min_y + 0.5;
      max_x_dep = max_x + 0.5;
      max_y_dep = max_y + 0.5;
   }

   old_x_extent = ME.IGEgadget->max_x_dep - ME.IGEgadget->min_x_dep;
   old_y_extent = ME.IGEgadget->max_y_dep - ME.IGEgadget->min_y_dep;

   new_x_extent = max_x_dep - min_x_dep;
   new_y_extent = max_y_dep - min_y_dep;

   if ((old_x_extent == new_x_extent) && (old_y_extent == new_y_extent))
   {
      flag = 3;
   }
   else
   {
      if ((min_x_dep == ME.IGEgadget->min_x_dep) && 
          (min_y_dep == ME.IGEgadget->min_y_dep))
      {
         flag = 1;
      }

      if ((min_x_dep == ME.IGEgadget->min_x_dep) && 
          (max_y_dep == ME.IGEgadget->max_y_dep))
      {
         flag = 1;
      }

      if ((max_x_dep == ME.IGEgadget->max_x_dep) && 
          (min_y_dep == ME.IGEgadget->min_y_dep))
      {
         flag = 1;
      }

      if ((max_x_dep == ME.IGEgadget->max_x_dep) && 
          (max_y_dep == ME.IGEgadget->max_y_dep))
      {
        flag = 1;
      }
   }

   if (ME.IGEwindow->flags & WIN_IS_ACTIVE)
   {
      if (ME.IGEwindow->win_type == BORDER)
      {
         bounds.x      = min_x_dep;
         bounds.y      = min_y_dep;
         bounds.width  = max_x_dep - min_x_dep + 1;
         bounds.height = max_y_dep - min_y_dep + 1;

         status = WLset_window_bounds ( ME.IGEgadget->win_no, &bounds );
         if (status != WL_SUCCESS)
         {
            *msg = status = OM_E_ERROR;
            return (status);
         }

         status = om$send ( msg = message IGEwindow.movicon(msg,
                                              &ME.IGEgadget->win_no, &flag,
                                              &min_x_dep, &min_y_dep,
                                              &max_x_dep, &max_y_dep),
                            targetid = my_id);
      }
      else
      {
         min_x_dep -= ME.IGEwindow->left_space;
         min_y_dep -= ME.IGEwindow->top_space;
         max_x_dep += ME.IGEwindow->right_space;
         max_y_dep += ME.IGEwindow->bottom_space;

         bounds.x      = min_x_dep;
         bounds.y      = min_y_dep;
         bounds.width  = max_x_dep - min_x_dep + 1;
         bounds.height = max_y_dep - min_y_dep + 1;

         status = WLset_window_bounds ( ME.IGEgadget->win_no, &bounds );
         if (status != WL_SUCCESS)
         {
            *msg = status = OM_E_ERROR;
            return (status);
         }

         status = om$send ( msg = message IGEwindow.movicon (msg,
                                          &ME.IGEgadget->win_no, &flag,
                                          &min_x_dep, &min_y_dep,
                                          &max_x_dep, &max_y_dep),
                            targetid = my_id);
      }
   }
   else
   {
      ME.IGEgadget->min_x_dep = min_x_dep;
      ME.IGEgadget->min_y_dep = min_y_dep;
      ME.IGEgadget->max_x_dep = max_x_dep;
      ME.IGEgadget->max_y_dep = max_y_dep;

      /*  recalculate independent extents  */

      ME.IGEgadget->min_x_indep = (IGRdouble) min_x_dep/x_extent;
      ME.IGEgadget->min_y_indep = (IGRdouble) min_y_dep/y_extent;
      ME.IGEgadget->max_x_indep = (IGRdouble) max_x_dep/x_extent;
      ME.IGEgadget->max_y_indep = (IGRdouble) max_y_dep/y_extent;
   }

   return ( status );
}			
end implementation IGEwindow;
