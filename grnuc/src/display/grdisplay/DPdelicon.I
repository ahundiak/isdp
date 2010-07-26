/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     IGEgragad
        METHOD NAME:    delicon

        Abstract:
                This method is to handle delete icon DELETE_EVENT
-----
%SC%

        VALUE = delicon (*msg )

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

        HT   04/29/86  : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
        This method will delete window object and env 5 window.
----*/
/*EH*/


class implementation IGEgragad;

#include <stdio.h>
#include "grimport.h"


method delicon( IGRlong *msg )
{       
    IGRlong status;

    *msg = MSSUCC;
    status = OM_S_SUCCESS;

    /* delete window object */
    status = om$send(mode = OM_e_wrt_object,
                     msg = message IGEgragad.delete(1),
                     senderid = my_id,
                     targetid = my_id);
    if ( ! ( 1 & status ) )
    {
#ifdef DEBUG
        printf ( "IGEgragad.delicon> error sending to delicon.\n" );
        om$report_error(sts = status );
#endif
        *msg = MSFAIL;
    }

    return ( status );
}

end implementation IGEgragad;
