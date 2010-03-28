/* #######################    APOGEE COMPILED   ######################## */

class implementation GRcontext;

#include "grimport.h"
#include 	"msdef.h"
#include 	"madef.h"
#include 	"refdef.h"

from GRreffile import GRinquireref;

static OM_S_CHANSELECT ref_chan;

%safe
static int chan_initialized=0;
%endsafe

GRfindosnum(msg,context_id,osnum)

IGRlong		*msg;
struct GRid	*context_id;
GRspacenum	*osnum;
{
    IGRchar	filename[256];

    IGRboolean 	pass_on;		/* pass to nested spaces flag	*/

    IGRlong	OMmsg,			/* return codes			*/
		msg1;
    
    struct GRinquire_list inquire_requests[2];
    struct GRmd_env dummy_env;
    int	j;

    *msg =  MSSUCC;
    OMmsg = OM_S_SUCCESS;

    if (!chan_initialized)
    {
	om$make_chanselect(channame = "GRcontext.to_reffile",
	    p_chanselect = &ref_chan);

	chan_initialized = 1;

    }

    /* Get the filename from the reffile object
     */
		
    inquire_requests[0].var = REFERENCE_FILE_NAME;
    inquire_requests[0].var_ptr = (IGRchar *)&filename;
    inquire_requests[0].num_requested = sizeof(filename);
    inquire_requests[1].var = END_REPORT_REQUEST;
		    
    pass_on = 0;

    OMmsg = om$send(
	msg = message GRreffile.GRinquireref
	    (&msg1,&dummy_env,inquire_requests,&j,&pass_on,NULL),
	senderid = context_id->objid,
	targetos = context_id->osnum,
	p_chanselect = &ref_chan,
	from=0, to=0);

    if ( 1 & OMmsg)
    {
        module_build_path(filename);

        OMmsg = om$os_name_to_number(osname=filename,
		p_osnum = osnum);
    }
    if ( !(1 & OMmsg))
    {
	*msg = MSFAIL;
    }

    return (OMmsg);
}
end implementation GRcontext;
