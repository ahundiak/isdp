/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: 	GRconnector
     METHOD NAME:	GRrigidconn

     Abstract: 	This method will connect "me" to a given object 
		using the GRcmpowner  to components channel.

-----
%SC%    

     GRrigidconn(msg,owners_id,owners_index)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *owners_id	   GRid		  structure indicating objid of 
				  object to connect me to
     *owners_index   IGRlong	  index into ordered relation 
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	  completion code
				     - MSSUCC if successful
				     - MSFAIL (severe) if failure
				     - GRNOCONNECT - a rigid owner exists
					an object cannot have 2
					rigid owners
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
		none.
     Methods:
		none.
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
	
	MAS    09/08/87 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method connects "me" to the input object.  
----*/
/*EH*/

class implementation GRconnector;

#include "grimport.h"
#include "msdef.h"
#include "grerr.h"
#include "godef.h"
#include "gocmacros.h"

from GRcmpowner import GRrigid_connecting;
from EMSmigrator import EMparent_owned;

method GRrigidconn(IGRlong *msg; struct GRid *owners_id; 
	IGRlong *owners_index)
{
    IGRlong  	OMmsg,			/* OM return value		*/
		msg1;

    IGRint	rigid_exists;		/* indicator whether rigid 
    					   relationship exists		*/
    OMuint	count;

    struct GRid	go_id;

    OM_S_CHANSELECT my_chandef,
		owners_chan;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    rigid_exists = me->properties & GR_RIGID_RELATIONSHIP;

    if (rigid_exists)
    {
	/* there is a rigid owner. An object cannot have 2 rigid
	 * owners.
	 */

	*msg = GRNOCONNECT;
	OMmsg = OM_E_ABORT;
    }
    else
    {
        OMmsg = GRget_to_owner_chansel(&my_chandef);

        if ( 1 & OMmsg)
	{
            OMmsg = GRget_to_comp_chansel(&owners_chan);

	    if ( 1 & OMmsg)
	    {
		OMmsg = om$get_channel_count(
			objid = my_id,
			p_chanselect = &my_chandef,
			count = &count);
		if (1 & OMmsg)
		{
	    	    if (count)
	    	    {
			/* notify all flexible owners that a rigid owner
			 * is connecting
			 */

			go_id.objid = my_id;
			go_id.osnum = OM_Gw_current_OS;

			om$send(
			    msg = message GRcmpowner.GRrigid_connecting
				(&msg1,&go_id),
			    p_chanselect = &my_chandef);
	    	    }

		    OMmsg = om$send(mode = OM_e_wrt_object,
		    	msg = message Root.connect(
		    	    owners_chan,0,my_id,
			    OM_Gw_current_OS,my_chandef,*owners_index),
		    	senderid = my_id,
		    	targetid = owners_id->objid,
		    	targetos = owners_id->osnum);

		    if (1 & OMmsg)
		    {
		    	me->properties |= GR_RIGID_RELATIONSHIP;
		    }
		    else
		    {
	   	    	*msg = MSFAIL;
		    }
		}
	    }
	    else
	    {
		*msg = MSFAIL;
	    }
	}
	else
	{
	    *msg = MSFAIL;
	}
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_CHANNEL_USED);

    if (1 & *msg & OMmsg)
    {
      IGRlong loc_msg=MSSUCC;
      OM_S_CHANSELECT to_children;
      om$make_chanselect(channame = "NDchildren.children",
                         p_chanselect = &to_children);
      om$send(msg = message EMSmigrator.EMparent_owned(&loc_msg,
      		    OPPmargs, NULL),
              p_chanselect = &to_children);
    }

    return(OMmsg);
}

end implementation GRconnector;
