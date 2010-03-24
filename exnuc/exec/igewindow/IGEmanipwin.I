/*----
        CLASS NAME:     IGEwindow
        METHOD NAME:    pop_window, collapse_win

        Abstract:
	  	These methods are used to manipulate the window.  With these
		methods a window can be popped to the top, popped to the 
		bottom, collapsed, or uncollapsed.

*/

class implementation IGEwindow;

#include "igewindef.h"
#include "igewinmacros.h"
#include "wl.h"


method pop_window (IGRlong *msg; IGRint flag)

{
   int status;

   *msg = MSSUCC;   

   if (flag == IGE_POP_TO_TOP)
   {
      if ((ME.IGEwindow->flags & WIN_IS_ACTIVE) && 
          (ME.IGEwindow->flags & WIN_IS_ON))
      {
         status = WLpop_window_to_top ( ME.IGEgadget->win_no );
         if (status != WL_SUCCESS)
         {
            return (OM_E_ERROR);
         }
      }
      else
      {
         if ((ME.IGEwindow->flags & WIN_IS_ACTIVE) && 
             (ME.IGEwindow->flags & WIN_IS_ON))
         {
            status = WLpop_window_to_bottom ( ME.IGEgadget->win_no );
            if (status != WL_SUCCESS)
            {
               return (OM_E_ERROR);
            }
         }
      }
   }
   return(1);
}


method set_collapse_pos (IGRlong *msg; IGRint dep_indep;
                         IGRdouble *collapse_pos)
{
   IGRint x_extent;
   IGRint y_extent;
   IGRint screen_no;
   IGRint status = TRUE;

   ME.IGEwindow->flags |= COLLAPSE_POS_VALID;

   if (dep_indep == IGE_INDEPENDENT)
   {
      ME.IGEwindow->collapse_pos[0] = collapse_pos[0];
      ME.IGEwindow->collapse_pos[1] = collapse_pos[1];
   } 
   else
   {
      screen_no = EX_multi_screen ( ME.IGEwindow->screen_no );

      ige$inq_term_info ( screen_no = screen_no,
                          x_extent  = &x_extent,
                          y_extent  = &y_extent );

      x_extent--;
      y_extent--;

      ME.IGEwindow->collapse_pos[0] = (collapse_pos[0] * x_extent) + 0.5;
      ME.IGEwindow->collapse_pos[1] = (collapse_pos[1] * y_extent) + 0.5;
   }
   return(status);
}


method collapse_window (IGRlong *msg; IGRint flag)
{
   IGRint	col_flag;
   IGRint	status = OM_S_SUCCESS;
   IGRint	x_extent;
   IGRint	y_extent;
   IGRint	screen_no;
   IGRint	x;
   IGRint	y;

   *msg = MSSUCC;   

   if (flag == IGE_COLLAPSE_WIN)
   {
      if ((ME.IGEwindow->flags & WIN_IS_ACTIVE) && 
          (ME.IGEwindow->flags & WIN_IS_ON))
      {
         col_flag = 1;
         if (ME.IGEwindow->flags & COLLAPSE_POS_VALID)
         {
            screen_no = EX_multi_screen ( ME.IGEwindow->screen_no );

            ige$inq_term_info ( screen_no = screen_no,
                                x_extent  = &x_extent,
                                y_extent  = &y_extent);
            x_extent--;
            y_extent--;

            x = (int) ((ME.IGEwindow->collapse_pos[0] * x_extent) + 0.5),
            y = (int) ((ME.IGEwindow->collapse_pos[1] * y_extent) + 0.5),

            status = WLset_collapse_parms ( ME.IGEgadget->win_no, x, y,
                                            WL_COLLAPSED );
            if (status != WL_SUCCESS)
            {
               status = OM_E_ERROR;
               goto wrapup;
            }
         }
         else
         {
            status = WLget_collapse_parms ( ME.IGEgadget->win_no, &x, &y );
            if (status != WL_SUCCESS)
            {
               status = OM_E_ERROR;
               goto wrapup;
            }

            status = WLset_collapse_parms ( ME.IGEgadget->win_no, x, y, 1);
            if (status != WL_SUCCESS)
            {
               status = OM_E_ERROR;
               goto wrapup;
            }
         }

         status = om$send (mode = OM_e_wrt_object,
                           msg = message IGEgadget.clpicon (msg, &col_flag),
                           senderid = my_id,
                           targetid = my_id);
         if (!(status & 1))
         {
            goto wrapup;
         }
      }
      ME.IGEwindow->flags |= WIN_IS_COLLAPSED;
   }
   else
   {
      if ((ME.IGEwindow->flags & WIN_IS_ACTIVE) && 
          (ME.IGEwindow->flags & WIN_IS_ON))
      {
         col_flag = 0;

         status = om$send (mode = OM_e_wrt_object,
                           msg = message IGEgadget.clpicon(msg, &col_flag),
                           senderid = my_id,
                           targetid = my_id);
         if (!(status & 1))
         {
            goto wrapup;
         }
      }
      ME.IGEwindow->flags &= ~WIN_IS_COLLAPSED;
   }
wrapup:
   return(status);
}


method change_screen (IGRlong *msg; IGRint screen)
{
   IGRlong status = TRUE;
#ifdef ENV5
   IGRint  flag  = WN_CHANGED_VS;  /*  move and stretch value  */
   IGRint  vs_no;
   IGRint  xlo,xhi,ylo,yhi;
   IGRint  num_screens;
#endif

   *msg = MSSUCC;

#ifdef ENV5
   if (screen == IGE_SWAP_SCREEN)
   {
      if (ME.IGEwindow->screen_no == RIGHT_SCREEN)
      {
         ME.IGEwindow->screen_no = LEFT_SCREEN;
         screen = IGE_LEFT_SCREEN;
      }
      else
      {
         ME.IGEwindow->screen_no = RIGHT_SCREEN;
         screen = IGE_RIGHT_SCREEN;
      }
   }
   else
   {
      /*========================*/
      /*  check for noop cases  */
      /*========================*/

      if ((screen == IGE_RIGHT_SCREEN) && 
          (ME.IGEwindow->screen_no == RIGHT_SCREEN))
         goto wrapup;

      if ((screen == IGE_LEFT_SCREEN) && 
          (ME.IGEwindow->screen_no == LEFT_SCREEN))
         goto wrapup;

      if (screen == IGE_RIGHT_SCREEN)
         ME.IGEwindow->screen_no = RIGHT_SCREEN;
      else
         ME.IGEwindow->screen_no = LEFT_SCREEN;
   }

   status = WLget_number_of_screens ( &num_screens, NULL );
   if (num_screens == 1) 
   {
      status = OM_S_SUCCESS;
      goto wrapup;
   }

   ige$inq_term_info ( screen_no = screen,
                       vs_no = &vs_no );
	
   if (ME.IGEwindow->flags & WIN_IS_ACTIVE)
   {
      xlo = ME.IGEgadget->min_x_dep;	   
      ylo = ME.IGEgadget->min_y_dep;	   
      xhi = ME.IGEgadget->max_x_dep;	   
      yhi = ME.IGEgadget->max_y_dep;	   

      if (ME.IGEwindow->win_type == BORDER)
      {
         Modify_win_vs(ME.IGEgadget->win_no,xlo,ylo,xhi,yhi,vs_no);

         status = om$send ( msg = message IGEwindow.movicon (msg,
                                   &ME.IGEgadget->win_no, &flag, &xlo, &ylo,
                                   &xhi,&yhi),
                            targetid = my_id);
      }
      else
      {
         xlo -= ME.IGEwindow->left_space;
         ylo -= ME.IGEwindow->top_space;
         xhi += ME.IGEwindow->right_space;
         yhi += ME.IGEwindow->bottom_space;

         Modify_win_vs(ME.IGEgadget->win_no,xlo,ylo,xhi,yhi,vs_no);

         status = om$send ( msg = message IGEwindow.movicon (msg,
                                   &ME.IGEgadget->win_no, &flag, &xlo, &ylo,
                                   &xhi, &yhi),
                            targetid = my_id);
      }
   }
wrapup:
#endif
   return ( status );
}

end implementation IGEwindow;
