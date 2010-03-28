/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              GRadp 
     METHOD NAME:             color_table_changed
 
     Abstract:

        This method updates color gadgets on all Drawing Parameters Forms
     that are displayed when the color table is changed.

-----
%SC%

     VALUE =  color_table_changed(color_objid,color_osnum)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------
     color_objid  GRobjid        object id of the color object
     color_osnum  GRspacenum     osnum of the color object
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------
     VALUE (IGRlong) =    MSSUCC    - if successful
                          MSFAIL    - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     modules:

     methods:

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        WBC  08/09/88 : Design date.
        WBC  08/09/88 : Creation date.
        dhm  07/13/92 : ANSI conversion.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This method updates color gadgets on all Drawing Parameters Forms
that are displayed when the color table is changed.
----*/
/*EH*/

class implementation   GRadp;

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "gr.h"
#include "OMerrordef.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "adpdef.h"
#include "FI.h"
#include "igewinmacros.h"

method color_table_changed(GRobjid color_objid; GRspacenum color_osnum)
{
    struct IGRdisplay      active_display;
    IGRlong                msg;              /* return code of modules       */
    IGRlong                buffersize;
    IGRlong                nobytes;
    IGRint                 status;
    IGRint                 error_index;
    Form                   form_ptr;
    struct  EX_var_list    var_list[2];

    /*
     * If a save/restore window is active, cannot update the form(s) since this
     * may not be the most recently displayed save/restore window
     */

    if (!(ige$SR_active()))
    {
        buffersize = sizeof(active_display);
        gr$get_active_display(msg = &msg,
                              sizbuf = &buffersize,
                              buffer = &active_display,
                              nret = &nobytes);

        if (!(msg & 1))
        {
            return(OM_S_SUCCESS);
        }

        /*
         * if the Active Drawing Parameters form exists, update the color of
         * its line gadget
         */

        /*
         * update the color of the line gadget on the Active Drawing
         * Parameters form
         */

        var_list[0].var = ADP_COLOR_NUM;
        var_list[0].var_value = (IGRchar *) &active_display.color;
        var_list[1].var = ADP_END_LIST;
        GRupdate_adp(&msg, NULL, var_list, &error_index);

        /*
         * If the Set Active Drawing Parameters form exists and is displayed,
         * send a message notifying it that the color table has changed.
         */

        if (GRcreate_setadp(&msg,FALSE,&form_ptr))
        {
            FIf_is_displayed(form_ptr,&status);

            if (status)
            {
                /*
                 * update the color related gadgets on the Set Active Drawing
                 * Parameters form
                 */

                var_list[0].var = ADP_COLOR_PALETTE;
                var_list[0].var_value = (IGRchar *) &active_display.color;
                var_list[1].var = ADP_END_LIST;
                GRupdate_setadp(&msg,form_ptr,var_list,&error_index);
            }
        }

        /*
         * update any of the Set Active Drawing Parameters subforms that are
         * displayed
         */

        GRupdate_setadp_subforms(&active_display);
    }
    return(OM_S_SUCCESS);
}

end implementation GRadp;
