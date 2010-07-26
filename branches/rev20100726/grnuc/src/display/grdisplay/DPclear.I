/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	GRwn
	METHOD NAME:	clear

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
									
	NAME       DATA TYPE      	    DESCRIPTION
     ----------   ------------   -----------------------------------

	
-----
%EX%

	ON EXIT:

	NAME       DATA TYPE      	    DESCRIPTION
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


class implementation IGEgragad;


#include "grimport.h"
#include "dpdef.h"

#include "wl.h"
#include "dl.h"

method clear( IGRlong *msg)

{	
    IGRlong status;

    *msg = MSSUCC;
    status = OM_S_SUCCESS;

    /* should send message to GRwscvth2s method to convert */
    /* soft_win_no to hard ware window number              */ 

    ME.IGEgragad->gragad.flags &= ~IS_ACTIVE;

    if (ME.IGEgragad->gragad.gpipe_id >= 0)
    {
       if ( DLdelete_drawing_pipeline( ME.IGEgragad->gragad.gpipe_id ) != DL_SUCCESS )
       {
          status = FALSE;
          *msg  = MSFAIL;
       }    
       else
       {
	  ME.IGEgragad->gragad.gpipe_id = -1;
          status = TRUE;
       }
    }

    return ( status );
}

end implementation IGEgragad;
