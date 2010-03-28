/* #######################    APOGEE COMPILED   ######################## */

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "exdef.h"
#include "exmacros.h"

IGRlong	GRsuperconnect(msg,md_id,reffile_id,mgr_id)

IGRlong		*msg;
struct GRid 	*md_id;
GRobjid		*reffile_id;
struct GRid	*mgr_id;

{
    IGRlong 	OMmsg;

    OM_S_CHANSELECT to_chan,
		fr_chan;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

					/* get Super_rfmgr id		*/
    OMmsg = ex$get_super(
	    mod_id = md_id->objid,
	    mod_osnum = md_id->osnum,
	    super_name = "Ref Mgr",
	    super_class = "Super_rfmgr",
	    create = 1,
	    super_id = &mgr_id->objid,
	    super_osnum = &mgr_id->osnum);

    if (1 & OMmsg)
    {					/* set up channel information	*/
	om$make_chanselect(p_chanselect = &to_chan,
		   	channame = "Super_rfmgr.mgr");

	om$make_chanselect(p_chanselect = &fr_chan,
			channame = "GRreffile.to_mgr");

					/*connect attachment to Super	*/
	OMmsg = om$send ( mode = OM_e_wrt_object,
	    msg = message Root.connect
		(to_chan,OM_K_MAXINT,*reffile_id,md_id->osnum,fr_chan,
		 OM_K_MAXINT),
	    senderid = *reffile_id,
	    targetid = mgr_id->objid,
	    targetos = mgr_id->osnum);
    }
    return (OMmsg);

}
end implementation GRreffile;
