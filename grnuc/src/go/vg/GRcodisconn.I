/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: 	GRconnector
     METHOD NAME:	GRdisconn

     Abstract: 	This method will disconnect "me" from the input 
		object using the GRcmpowners, to_components
		channel.
-----
%SC%    

     GRdisconn(msg,owners_id)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *owners_id	   GRid		  structure indicating objid of 
				  object to disconnect me from
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	  completion code
				     - MSSUCC if successful
				     - MSFAIL (severe) if failure
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
	
	MAS     09/08/87 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method disconnects "me" from the input object. 
----*/
/*EH*/

class implementation GRconnector;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

from EMSmigrator import EMparent_disowned;

method GRdisconn(IGRlong *msg; struct GRid *owners_id)
{
    IGRlong  OMmsg;		/* OM return value	*/
    OM_S_CHANSELECT my_chandef,
		owners_chan;
    GRobjid	objid;
    GRspacenum  osnum;
    IGRboolean  discon_rigid=FALSE;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    OMmsg = GRget_to_owner_chansel(&my_chandef);

    if (1 & OMmsg)
    {
        OMmsg = GRget_to_comp_chansel(&owners_chan);

	if ( 1 & OMmsg)
	{
    	    if (me->properties & GR_RIGID_RELATIONSHIP)
    	    {
		om$get_objid_at_index(objid = my_id,
	    	    	p_chanselect = &my_chandef,
	    		index = 0,
	    		objidaddr = &objid,
	    		osnumaddr = &osnum);
	
		if ( objid == owners_id->objid)
		{
		    discon_rigid = TRUE;
	    	    me->properties &= (~GR_RIGID_RELATIONSHIP);
		}
    	    }
            OMmsg = om$send(mode = OM_e_wrt_object,
		msg = message Root.disconnect(	
			owners_chan,my_id,OM_Gw_current_OS,my_chandef),
		senderid = my_id,
		targetid = owners_id->objid,
		targetos = owners_id->osnum);

    	    if (! (1 & OMmsg))
    	    {
	        *msg = MSFAIL;
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

    if (1 & *msg & OMmsg)
    {
      IGRlong loc_msg=MSSUCC;
      OM_S_CHANSELECT to_children;
      om$make_chanselect(channame = "NDchildren.children",
                         p_chanselect = &to_children);
      om$send(msg = message EMSmigrator.EMparent_disowned(&loc_msg,
                    OPPmargs, discon_rigid ? GR_RIGID_RELATIONSHIP : NULL),
              p_chanselect = &to_children);
    }

    return(OMmsg);
}
end implementation GRconnector;

