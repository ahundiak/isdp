/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: 	GRconnector
     METHOD NAME:	GRflexconn

     Abstract: 	This method will connect "me" to a given object 
		through a specified channel.

-----
%SC%    

     GRflexconn(msg,flag,owners_id,owners_index,graphics_index)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *flag	   IGRshort	  flag to indicate action should a 
				     rigid owner exist
				     0 - do not connect
				     1 - connect even if rigid owner
					 present
     *owners_id	   GRid		  structure indicating objid of 
				  object to connect me to
     *owners_index   IGRlong	  index into ordered relation 
     *graphics_index IGRlong	  index into ordered relation 

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	  completion code
				     - MSSUCC if successful
				     - MSFAIL (severe) if failure
				     - GRDEFAULT_USED - requested the
					graphics index be 0 but a 
					rigid owner exists
				     - GRNOCONNECT - a rigid owner exists
					and the flag indicates do not
					connect
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

method GRflexconn(IGRlong *msg; IGRlong *flag; struct GRid *owners_id; 
	IGRlong *owners_index;	IGRlong *graphics_index)
{
    IGRlong  	OMmsg;			/* OM return value		*/
    IGRint	index;			/* index for graphics		*/
    IGRint	rigid_exists;		/* indicator whether rigid 
					   relationship exists		*/

    OM_S_CHANSELECT my_chandef,
		owners_chan;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;
	

    OMmsg = GRget_to_owner_chansel(&my_chandef);

    if ( 1 & OMmsg)
    {
        OMmsg = GRget_to_comp_chansel(&owners_chan);

    	if ( 1 & OMmsg)
    	{
            rigid_exists = me->properties & GR_RIGID_RELATIONSHIP;

            if ( (rigid_exists) && !(*flag))
            {
	    	/* there is a rigid owner and the flag 
		 * indicates do not connect
	     	 */

	    	*msg = GRNOCONNECT;
	    	OMmsg = OM_E_ABORT;
            }
    	    else
    	    {
	        if (rigid_exists & (*graphics_index == 0))
     	        {
	    	    /* can not use index 0 because a rigid owner already 
	     	     * exists
	     	     */

	    	    index = OM_K_MAXINT;
	    	    *msg = GRDEFAULT_USED;
	    	}
	    	else
	    	{
	     	    index = *graphics_index;
	    	}

	    	OMmsg = om$send(mode = OM_e_wrt_object,
		    msg = message Root.connect(
		    	owners_chan,*owners_index,my_id,OM_Gw_current_OS,
		     	my_chandef,index),
		    senderid = my_id,
		    targetid = owners_id->objid,
	 	    targetos = owners_id->osnum);

	        if (! (1 & OMmsg))
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

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_CHANNEL_USED);

    return(OMmsg);
}

end implementation GRconnector;
