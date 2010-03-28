/* #######################    APOGEE COMPILED   ######################## */

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"

IGRlong	GRpolyconnect(msg,osnum,poly_objid,reffile_id)

IGRlong		*msg;
GRspacenum	*osnum;
GRobjid		*poly_objid;
GRobjid		*reffile_id;
{
    IGRlong 	OMmsg;

    OM_S_CHANSELECT to_chan,
		fr_chan;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    if (1 & OMmsg)
    {					/* set up channel information	*/
	om$make_chanselect(p_chanselect = &to_chan,
			channame = "GRclippoly.to_attachment");

	om$make_chanselect(p_chanselect = &fr_chan,
		   	channame = "GRreffile.to_clip");

					/*connect attachment to Super	*/
	OMmsg = om$send ( mode = OM_e_wrt_object,
	    msg = message Root.connect
		(to_chan,OM_K_MAXINT,*reffile_id,*osnum,fr_chan,
		 OM_K_MAXINT),
	    senderid = *reffile_id,
	    targetid = *poly_objid,
	    targetos = *osnum);
    }

    return (OMmsg);
}
end implementation GRreffile;
