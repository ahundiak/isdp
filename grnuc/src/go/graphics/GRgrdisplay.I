/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GRgraphics
     METHOD NAME:   GRdisplay

     Abstract:      This method sends to the appropriate methods to
                    display a graphics object.

-----
%SC%    

     GRdisplay(msg, type, matrix, mode, display_info)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
      *type       IGRshort       type of the matrix
      *matrix     IGRmatrix      environment transformation matrix
      *mode       GRdpmode       the display mode
      *display_info GRid         window/view information denoting 
                                   where to display the object
        
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:

     Methods:

-----
%RL%

     RELATIONS REFERENCED:
             none.
-----
%NB%

     NOTES:
             none.
-----
%CH%

     CHANGE HISTORY:
        
        MAS     03/27/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
        TBD.
----*/
/*EH*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"
#include "dpmacros.h"

method  GRdisplay(IGRlong *msg; IGRshort *mx_type; IGRmatrix
                  matrix; enum GRdpmode *mode; struct GRid 
                  *display_info)
{
        IGRlong  OMmsg;                 /* OM return code       */

        IGRmatrix *mx[1];               /* pointer to matrix    */

        struct GRid go_objid;           /* info for GRdisbyoid  */

        *msg = MSSUCC;
        OMmsg = OM_S_SUCCESS;

        go_objid.objid = my_id;
        go_objid.osnum = OM_Gw_current_OS;

        mx[0]  = (IGRmatrix *) matrix;

        dp$display(msg = msg,
                   osnum =  display_info->osnum,
                   objid =  display_info->objid,
                   mode  =  *mode,
                   oids  =  &go_objid,
                   mtx_type = mx_type,
                   matrix = mx);

        /*****DLB 2/26/92 - ALWAYS RETURN SUCCESS!!!!!
        if (!(*msg & 1))
        {
            *msg = MSFAIL;
            OMmsg = OM_E_ABORT;
        }
        ********************************************/
        *msg = MSSUCC;
        OMmsg = OM_S_SUCCESS;


        return (OMmsg);
}

end implementation GRgraphics;
