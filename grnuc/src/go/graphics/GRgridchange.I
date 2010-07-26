/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRgraphics

     METHOD NAME: GRidchanged

     Abstract: 	This method notifies an owner that the objid of one
	    	of its components has changed.
		
-----
%SC%    

	GRidchanged ( msg, num_ids, new_ids )
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
      *newid	    GRid	  contains the newids of the object
      *num_ids	    IGRshort	  number of new object ids
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				   - MSSUCC if successful     
				   - MSFAIL (severe) if other error
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:   none.

     Methods:   none.

-----
%RL%

     RELATIONS REFERENCED:	None.

-----
%NB%

     NOTES:

-----
%CH%

     CHANGE HISTORY:
	
	KMO     02/09/87 : Design date.
	KMO	03/26/87 : Creation date.
	MAS	04/04/88 : Re-design date.
    dhm 10/18/91 : changed from GR_CLIPPED to GR_CHANGED for notify listeners.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method handles the most generic case of when an
	object's id changes.   The owners on the to_owners channel
	will be sent a GRidchange message.  If they are interested in
	maintaining the relationship with the new object, they can 
	connect to the new object(s).  The notification owners will
	be notified as usual after the completion of the method.

----*/
/*EH*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

from GRcmpowner import GRcomponent_idchanged;

method  GRidchanged( IGRlong *msg; IGRshort *num_ids;
		     struct GRid *new_ids )
{
    IGRlong	OMmsg;
    OM_S_CHANSELECT chan;
    
    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    OMmsg = om$make_chanselect(channame = "GRconnector.to_owners",
	p_chanselect = &chan);

    if ( 1 & OMmsg)
    {
	OMmsg = om$send(msg = message GRcmpowner.GRcomponent_idchanged
		(msg,num_ids,new_ids),
	    p_chanselect = &chan);
    }
    else
    {
	*msg = MSFAIL;
    }	    

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_CHANGED);

    return (OMmsg);
}
end implementation GRgraphics;
