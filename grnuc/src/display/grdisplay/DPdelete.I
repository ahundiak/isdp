/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     IGEgragad
        METHOD NAME:    delete

        Abstract:
                This method is to handle delete 
-----
%SC%

        VALUE = delete (flag )

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

        HT   07/13/86  : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
        This method will send a pre_delete message to all objects off
the winsup channel and then delete itself.
----*/
/*EH*/


class implementation IGEgragad;

#include <stdlib.h>
#include <stdio.h>
#include "grimport.h"
#include "OMminimum.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "wl.h"
#include "dl.h"

/* prototype files */
%safe
#include "DPfddefvw.h"
#include "GRdpbfunc.h"
%endsafe


from IGEwinsup import pre_delete;

method delete( int flag )
{       
    IGRlong  status;
    IGRlong  msg;
    OMuint   count;
    IGRlong  size_buffer;
    struct EX_button button;
    OM_S_CHANSELECT   chandef;
    GRobjid  default_oid;

    chandef.type = OM_e_name;
    chandef.u_sel.name = "IGEgragad.winsup";
    status = OM_S_SUCCESS;


   status = om$get_channel_count(objid = my_id, 
                                 p_chanselect = &chandef, 
                                 count = &count);



   if (!(status & 1))
   {
        om$report_error(sts = status);
        goto wrapup;
   }
                                
   if (count)                           
   {

      status = om$send  ( mode = OM_e_wrt_object, 
                        msg = message IGEwinsup.pre_delete(&msg), 
                        senderid = my_id, 
                        p_chanselect = &chandef);

      /* protect against unknown objects */
      if (status == OM_E_NOSUCHCLASS ) status = OM_S_SUCCESS;

      if (!(status & 1))
      {
        om$report_error(sts = status);
        goto wrapup;
      }
   }
   size_buffer = sizeof (struct EX_button);
   gr$get_last_point(buffer = (IGRchar *)&button);

   if ( button.objid == my_id)
   {
	dp$find_defaultvw (msg = &msg,flag = DPCONST_VW,
				osnum = OM_Gw_current_OS,
				objid = &default_oid);
	button.objid = default_oid;
	status = gr$put_last_point (buffer = (IGRchar *)&button);
   }

    if (ME.IGEgragad->gragad.gpipe_id >= 0)
    {
	DLdelete_drawing_pipeline( ME.IGEgragad->gragad.gpipe_id );
    }

    /* delete gragad object */

    status = om$send  ( mode = OM_e_wrt_message, 
               msg = message Root.delete(1), 
               senderid = my_id, 
               targetid = my_id);
        

    if ( ! ( 1 & status ) )
    {
#ifdef DEBUG
        printf ( "IGEgragad.delete> error sending to delete.\n" );
        om$report_error(sts = status );
#endif
    }
wrapup:

    return ( status );
}

end implementation IGEgragad;
