
/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     IGEwindow
        METHOD NAME:    movicon

        Abstract:
                This method will handle window move icon .
                (move window, stretch window, stretch and move window)
-----
%SC%

        VALUE = movicon (*msg, *win_no,*flag,*minx,*miny,*maxx,*maxy)

-----
%EN%

        ON ENTRY:
                                                                        
        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
      *win_no      IGRint        pointer to hardware window number
      *flag        IGRint        flag = 0 move, 1 stretch, 2 stretch+move
      *minx        IGRint      
      *miny        IGRint
      *maxx        IGRint
      *maxy        IGRint
        
         This method will update window size information in instance
         data and send update message to self.
----*/
/*EH*/


class implementation IGEwindow;

#ifdef CLIX
#include <sdl.h>
#endif
#include "wl.h"
#include "cm.h"
#include "igewindef.h"
#include "igewinmacros.h"


method movicon( IGRlong *msg; IGRint *win_no; IGRint *flag;
        IGRint *minx;IGRint *miny; IGRint *maxx; IGRint *maxy)
{       
        
    IGRlong status;
    IGRint  x_extent, y_extent;
    IGRint  tmp_x_min;
    IGRint  tmp_y_min;
    IGRint  tmp_x_max;
    IGRint  tmp_y_max;
    struct WLbounds bounds;
#ifdef ENV5
    WLuint16 new_lscreen_no;
    WLuint32 new_context_no;
    WLuint32 new_win_no;
#endif
	status = OM_S_SUCCESS;

   
	*msg = MSSUCC;

#ifdef ENV5
	if(wn_changed_vs(*flag))
    	{
           if (ME.IGEwindow->screen_no == LEFT_SCREEN)
           {
              ME.IGEwindow->screen_no = RIGHT_SCREEN;
           }
           else
           {
              ME.IGEwindow->screen_no = LEFT_SCREEN;
           }

           /* change the screen in WL, remember that the window */
	   /* number will change                                */
           new_lscreen_no = EXget_logical_screen_number( ME.IGEwindow->screen_no );
           status = CMget_active_context( new_lscreen_no, &new_context_no );
           if ( status != CM_SUCCESS )
	   {
              *msg = MSFAIL;
	      return( OM_E_ERROR );
	   }

           status = WLchange_window_screen( ME.IGEgadget->win_no, new_context_no,
 	                                    new_lscreen_no, &new_win_no );

           if ( status != WL_SUCCESS )
	   {
              *msg = MSFAIL;
	      return( OM_E_ERROR );
	   }

           ME.IGEgadget->win_no = new_win_no;
           *win_no = new_win_no;
	}
#endif
	if (ME.IGEwindow->win_type == NO_BORDER)
	{
    	   *minx += ME.IGEwindow->left_space;
    	   *miny += ME.IGEwindow->top_space;
    	   *maxx -= ME.IGEwindow->right_space;
    	   *maxy -= ME.IGEwindow->bottom_space;
	}

	if ((ME.IGEwindow->win_type == NO_BORDER) &&
	    (ME.IGEwindow->flags & WIN_IS_ACTIVE))
	{
	   tmp_x_min = ME.IGEgadget->min_x_dep;
	   tmp_y_min = ME.IGEgadget->min_y_dep;
	   tmp_x_max = ME.IGEgadget->max_x_dep;
	   tmp_y_max = ME.IGEgadget->max_y_dep;


	
    	   ME.IGEgadget->min_x_dep = *minx;
    	   ME.IGEgadget->min_y_dep = *miny;
    	   ME.IGEgadget->max_x_dep = *maxx;
    	   ME.IGEgadget->max_y_dep = *maxy;

	   if  (ME.IGEwindow->draw_border == TRUE)
	   {

	      status = om$send(msg = message IGEwindow.draw_border(0xffffffff),
			    targetid = my_id);
	   }
	   else
	   {
	      status = om$send(msg = message IGEwindow.draw_border(0),
			    targetid = my_id);
	   }

           if ( ! ( 1 & status ) )
           {
              om$report_error(sts = status );
              *msg = MSFAIL;
           }


	    ME.IGEgadget->min_x_dep = tmp_x_min;
	    ME.IGEgadget->min_y_dep = tmp_y_min;
	    ME.IGEgadget->max_x_dep = tmp_x_max;
	    ME.IGEgadget->max_y_dep = tmp_y_max;

	}

#ifdef X11
     /* change flag to 4 so updat will be called */
    	if( ((ME.IGEgadget->max_x_dep - ME.IGEgadget->min_x_dep) != 
	                                               ( *maxx - *minx) ) ||
            ((ME.IGEgadget->max_y_dep - ME.IGEgadget->min_y_dep) != 
	                                               ( *maxy - *miny) ) )
        {
/*           *flag = 4;	   */
/*printf("setting flag to 4\n");           */
	}
#endif
       /* Notify WL of the window size/position change */
       bounds.x = *minx;
       bounds.y = *miny;
       bounds.width = *maxx - *minx + 1;
       bounds.height = *maxy - *miny + 1;

       status = WLwindow_bounds_changed( ME.IGEgadget->win_no, &bounds );
       if ( status != WL_SUCCESS )
       {
          *msg = MSFAIL;
	  return( OM_E_ERROR );
       }

       status = om$send(mode = OM_e_wrt_message,
                     msg = message IGEgadget.movicon(msg, win_no, flag, 
                                                minx, miny, maxx, maxy),
                     senderid = my_id,
                     targetid = my_id);

       if ( ! ( 1 & status ) )
       {
           om$report_error(sts = status );
           *msg = MSFAIL;
       }

       ME.IGEgadget->min_x_dep = *minx;
       ME.IGEgadget->min_y_dep = *miny;
       ME.IGEgadget->max_x_dep = *maxx;
       ME.IGEgadget->max_y_dep = *maxy;



/*   get extents  */

	   ige$inq_term_info( 	x_extent = &x_extent,
				y_extent = &y_extent);


     x_extent--;
     y_extent--;


/* recalculate indepent values     */

    ME.IGEgadget->min_x_indep = (IGRdouble) *minx/x_extent;
    ME.IGEgadget->min_y_indep = (IGRdouble) *miny/y_extent;
    ME.IGEgadget->max_x_indep = (IGRdouble) *maxx/x_extent;
    ME.IGEgadget->max_y_indep = (IGRdouble) *maxy/y_extent;


    return ( status );
}

end implementation IGEwindow;
