/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
	CLASS NAME:	IGEwindow
	METHOD NAME:	clpicon
 
     	Abstract: This method toggles the active bit setting in window
		  instance data and send update message to window if
                  uncollapsed. If the window collapsed, toggle the
                  active bit.
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *flag        IGRint           flag = 0 uncollapsed
					 = 1 collapsed
-----

     	 This method toggles the active bit setting in window
         instance data and send update message to window if
         uncollapsed. If the window collapsed, toggle the
         active bit.
----*/
/*EH*/

class implementation IGEwindow;

#include "igewindef.h"
#include "igewinmacros.h"
#include "wl.h"


method clpicon (IGRlong *msg; IGRint *flag)
{
   IGRlong          status;
   IGRint           screen_no;
   OMuint           count;
   IGRint           x, y;
   IGRint           x_extent;
   IGRint           y_extent;
   OM_S_CHANSELECT  chandef;

   status = OM_S_SUCCESS;
   *msg = MSSUCC;

   screen_no = EX_multi_screen ( ME.IGEwindow->screen_no );

   ige$inq_term_info ( screen_no = screen_no,
                       x_extent  = &x_extent,
                       y_extent  = &y_extent);

   x_extent--;
   y_extent--;

   status = WLget_collapse_parms ( ME.IGEgadget->win_no, &x, &y );
   if (status != WL_SUCCESS)
   {
      status = OM_E_ERROR;
      goto wrapup;
   }

   ME.IGEwindow->flags |= COLLAPSE_POS_VALID;

   ME.IGEwindow->collapse_pos[0] = x / (IGRdouble) x_extent;
   ME.IGEwindow->collapse_pos[1] = y / (IGRdouble) y_extent;

   if (*flag == 0) /* window was uncollapsed  */
   {
      ME.IGEwindow->flags &= ~WIN_IS_COLLAPSED;

#ifdef X11
      ME.IGEwindow->flags &= ~WIN_IS_NOTMAPPED;
#endif

      if (ME.IGEwindow->win_type == NO_BORDER)
      {
         if (ME.IGEwindow->draw_border == TRUE)
         {
            status = om$send (msg = message IGEwindow.draw_border(0xffffffff),
                              targetid = my_id);
         }
         else
         {
            status = om$send (msg = message IGEwindow.draw_border(0),
                              targetid = my_id);
         }
         if (!(status & 1))
         {
            om$report_error(sts = status);
            goto wrapup;
         }
      }
   }
   else /* window was collapsed */
   {
      ME.IGEwindow->flags |= WIN_IS_COLLAPSED;
   }

   chandef.type = OM_e_name;
   chandef.u_sel.name = "to_children";

   status = om$get_channel_count (objid        = my_id, 
                                  p_chanselect = &chandef, 
                                  count        = &count);
   if (!(status & 1))
   {
      om$report_error(sts = status);
      goto wrapup;
   }
				
   if (count)				
   {
      status = om$send (mode = OM_e_wrt_object,
                        msg = message IGEgadget.clpicon (msg,flag),
                        senderid = my_id,
                        p_chanselect = &chandef);
      if ( !(1 & status) )
      {
         om$report_error(sts = status);
         printf("Error: collapse icon send to gadgets clpicon\n");
      }
   }

wrapup:

   return (status);
}
end implementation IGEwindow;
