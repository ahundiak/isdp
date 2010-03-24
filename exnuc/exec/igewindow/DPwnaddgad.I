
/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     IGEwindow
        METHOD NAME:    add_gadget

        Abstract:

-----
%SC%

        VALUE = clear( msg, gad_id )

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



/* add to dperr.h file later  */

#include "igewindef.h"

method add_gadget( IGRlong *msg; GRobjid *gadget_id; IGRint num_gadgets;)

{       
    IGRint           status;

        *msg = MSSUCC;


         status = om$send( mode = OM_e_wrt_message, 
			   msg = message IGEgadget.add_gadget( msg, gadget_id, 
						     num_gadgets),
                             senderid = my_id, 
                             targetid = my_id);
                       
          if (!(status & 1))
          {
             om$report_error(sts = status);
             goto wrapup;
          }
	  else
	  {
	      if (!(*msg & 1) )
	      {
		 goto wrapup;
	      }
	  }
	    
           if (ME.IGEwindow->flags & WIN_IS_ACTIVE)
           {
              status = om$send( msg = message IGEgadget.activate(msg, 
                                                ME.IGEgadget->win_no),
                             senderid = my_id, 
                             targetid = *gadget_id);
                        
              if (!(status & 1))
              {
                 om$report_error(sts = status);
                 goto wrapup;
              }

        
           }
        

wrapup:

    return ( status );
}

end implementation IGEwindow;
