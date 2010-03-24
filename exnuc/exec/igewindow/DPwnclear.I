/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     GRwn
        METHOD NAME:    clear

        Abstract:
                This is the window clear method for the window object.
             it will reset CS_OS_number[hard_w_no] CS_window_id[hard_w_no]
             and use tools' routine to delete window.
-----
%SC%

        VALUE = clear( &msg )

-----
%EN%

        ON ENTRY:
                                                                        
        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

        
-----
%EX%

        ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
       *msg         IGRlong        return condition
                                
-----
%RL%

        RELATIONS REFERENCED:


-----
%NB%

        NOTES:

-----
%CH%

        CHANGE HISTORY

        HT   04/28/86  : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


class implementation IGEwindow;

#include "igewindef.h"
#include "igewinmacros.h"

#include "wl.h"

extern OM_S_OBJID EX_exec_id;
extern uword EX_exec_osnum;

method clear (IGRlong *msg)
{       
    IGRlong status;
    OMuint  count;
    OM_S_CHANSELECT chandef;
    OM_S_CHANSELECT chandef1;
    OM_S_CHANSELECT chandef2;       
    IGRint    x,y;
    IGRint    screen_no;
    IGRint    x_extent;
    IGRint    y_extent;
    WLuint32  lwin;

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

    if( ME.IGEwindow->flags & WIN_IS_ACTIVE)
    {
       screen_no = EX_multi_screen ( ME.IGEwindow->screen_no );

       ige$inq_term_info ( screen_no = screen_no,
                           x_extent  = &x_extent,
                           y_extent  = &y_extent);

       x_extent--;
       y_extent--;

       chandef.type = OM_e_name;
       chandef.u_sel.name = "to_children";

       lwin = ME.IGEgadget->win_no;

       if (ME.IGEwindow->flags &  WIN_IS_COLLAPSED)
       {

          status = WLget_collapse_parms ( lwin, &x, &y );
          if (status != WL_SUCCESS)
          {
             status = OM_E_ERROR;
             goto wrapup;
          }
          status = OM_S_SUCCESS;

          ME.IGEwindow->flags |= COLLAPSE_POS_VALID;

          ME.IGEwindow->collapse_pos[0] = x / (IGRdouble) x_extent;
          ME.IGEwindow->collapse_pos[1] = y / (IGRdouble) y_extent;
       }

       ME.IGEwindow->flags &= ~WIN_IS_ACTIVE;

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
          status = om$send ( msg = message IGEgadget.clear (msg), 
                             senderid = my_id, 
                             p_chanselect = &chandef);
          if (!(status & 1))
          {
             om$report_error(sts = status);
             goto wrapup;
          }
       }

       status = WLdelete_window ( lwin );
       if (status != WL_SUCCESS)
       {
          status = OM_E_ERROR;
          goto wrapup;
       }
       status = OM_S_SUCCESS;

#ifdef ENV5
       DPhandle_event();
#endif

       if (ME.IGEwindow->win_type != SAVE_RESTORE)
       {
          chandef1.type = OM_e_name;
          chandef1.u_sel.name = "IGEwsys.exec";

          chandef2.type = OM_e_name;
          chandef2.u_sel.name = "exec.hw_win";

          status = om$send (msg = message Root.disconnect (chandef2, my_id,
                                               OM_Gw_current_OS, chandef1 ), 
                            senderid = my_id, 
                            targetid = EX_exec_id, 
                            targetos = EX_exec_osnum);
          if (!(status & 1))
          {
             om$report_error(sts = status);
          }
       }
    }

wrapup:

    return ( status );
}

end implementation IGEwindow;
