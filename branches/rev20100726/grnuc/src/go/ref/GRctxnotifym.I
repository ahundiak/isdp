/* #######################    APOGEE COMPILED   ######################## */


class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "ref.h"
#include "refdef.h"
#include "refpriv.h"

from GRgraphics import GRxform;

method GRnotifymisc(IGRlong *msg )
{

    IGRshort	id_type;

    IGRlong 	i;			/* loop index			*/
    IGRlong 	OMmsg;			/* local return codes		*/

    IGRmatrix id_mx;

    GRobjid	dummy;

    struct GRmd_env env;

    OM_S_CHANSELECT chan;

    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;

    if ( !(me->flags & GRACTIVATED_CONTEXT))
    {
	goto wrapup;
    }
					/* update nested context objects*/
    OMmsg = om$make_chanselect(
		channame = "GRcontext.to_misc",
		p_chanselect = &chan);

    if ( 1 & OMmsg)
    {
	for (i=0; i<16; ++i)
    	{
	    env.md_env.matrix[i] = me->matrix[i];
    	}
    	env.md_env.matrix_type = me->mx_type;

    	Get_invisible_id_from_osnum(me->osnum,&env.md_id.objid);
	env.md_id.osnum = me->osnum;

        MAidmx(msg,id_mx);
        id_type = MAIDMX;

        om$send(
	    msg = message GRgraphics.GRxform
		(msg,&env,&id_type,id_mx,&dummy),
	     p_chanselect = &chan);
    }

    wrapup:

    return( OMmsg );
}

end implementation GRcontext;
