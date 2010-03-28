/* #######################    APOGEE COMPILED   ######################## */


class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "ref.h"
#include "refdef.h"

from GRreffile import GRinquireref;
from GRgraphics import GRxform;


method GRregenerate(IGRlong *msg; struct GRmdenv_info *env_info; 
	IGRint *change_flag; struct GRid *context_id)
{
    IGRboolean 	pass_on;		/* pass to nested spaces flag	*/


    IGRint  i;				/* loop index			*/
    IGRlong OMmsg,			/* local return codes		*/
		msg1;


    struct GRmd_env env,
		    new_env;		/* reference file info		*/

    struct GRinquire_list inquire_requests[2];

    OM_S_CHANSELECT 	reffile_chan;


    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;
    *change_flag = FALSE;
    context_id->objid = my_id;
    context_id->osnum = OM_Gw_current_OS;

    if ( me->flags & GRMASTER_CONTEXT)
    {
	goto wrapup;
    }

    OMmsg = om$make_chanselect(channame = "GRcontext.to_reffile",
	p_chanselect = &reffile_chan);

    if ( 1 & OMmsg)		/* get matrix for transformation	*/
    {
	inquire_requests[0].var = ENVIRONMENT_INFO;
	inquire_requests[0].var_ptr = (IGRchar *) &new_env;
	inquire_requests[0].num_requested = sizeof(struct GRmd_env);
	inquire_requests[1].var = END_REPORT_REQUEST;

	env.md_env = *env_info;
	env.md_id.objid = NULL_OBJID;
	pass_on = FALSE;

	/* NOTE: there is only one reference file attachment object
	 * on the channel.
	 */

        OMmsg = om$send(
	    msg = message GRreffile.GRinquireref
		(&msg1,&env,inquire_requests,&i,&pass_on,NULL),
	    p_chanselect = &reffile_chan);
 
	if ( 1 & OMmsg)
	{
	    if (me->mx_type != new_env.md_env.matrix_type)
	    {
		*change_flag = TRUE;
	    	me->mx_type = new_env.md_env.matrix_type;
	    }
	    if ( !(*change_flag))
	    {
    	    	for (i=0; i<16; ++i)
	    	{
		    if (me->matrix[i] != new_env.md_env.matrix[i])
		    {
		 	*change_flag = TRUE;
			me->matrix[i] = new_env.md_env.matrix[i];
		    }
		}
	    }
	    else
	    {
    	    	for (i=0; i<16; ++i)
	    	{
		    me->matrix[i] = new_env.md_env.matrix[i];
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

wrapup:
    return( OMmsg );
}

end implementation GRcontext;
