/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     IGEwindow
        METHOD NAME:    delete

        Abstract:
                This method is to handle delete 
-----
%SC%

        VALUE = delete (flag )

--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
        This method will delete window object and env 5 window.
----*/
/*EH*/


class implementation IGEwindow;

#include "igewindef.h"
#include "wl.h"

method delete ( int flag )
{       
   IGRlong status;
   OMuint count;
   OM_S_CHANSELECT   chandef;

   chandef.type = OM_e_name;
   chandef.u_sel.name = "to_children";
   status = OM_S_SUCCESS;

#ifdef ENV5
   DPhandle_event();
#endif

   if (ME.IGEwindow->flags & WIN_IS_ACTIVE)
   {
      status = WLdelete_window ( ME.IGEgadget->win_no );
      if (status != WL_SUCCESS)
      {
         status = OM_E_ERROR;
         goto wrapup;
      }
   }

   status = om$get_channel_count ( objid        = my_id, 
                                   p_chanselect = &chandef, 
                                   count        = &count);
   if (!(status & 1))
   {
      om$report_error(sts = status);
      goto wrapup;
   }
                                
   if (count)                           
   {
      status = om$send  ( mode = OM_e_wrt_object, 
                          msg = message IGEgadget.delete(1), 
                          senderid = my_id, 
                          p_chanselect = &chandef);
      if (!(status & 1))
      {
         om$report_error(sts = status);
         goto wrapup;
      }
   }

   /*========================*/
   /*  delete window object  */
   /*========================*/

#ifdef ENV5
   DPhandle_event();
#endif

   status = om$send  ( mode = OM_e_wrt_message, 
                       msg = message Root.delete(1), 
                       senderid = my_id, 
                       targetid = my_id);
   if ( ! ( 1 & status ) )
   {
       printf ( "IGEwindow.delete> error sending to delete.\n" );
       om$report_error(sts = status );
   }

wrapup:

   return ( status );
}

end implementation IGEwindow;
