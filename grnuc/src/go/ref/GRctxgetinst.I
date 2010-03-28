/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetinstance - gets instance data from the context object

Synopsis
    	GRgetinstance(msg,type,matrix,ref_osnum,flag,
		context_info)
	
 	IGRlong	*msg		completion code
	IGRshort *type		matrix type
	IGRmatrix matrix	the environment matix
        GRspacenum *ref_osnum	the object space number of the
				reference file this context 
				represents
	IGRshort *flag		flag from instance data
	struct GRid *context_info information about this context
				object

Description
	This method retrieves the  context information 
	from the instance data of the GRcontext object.

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion

Notes
	None.

History
	MAS  	05/27/87 	Design date.

\*/

class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"

method GRgetinstance(IGRlong *msg;IGRshort *type;IGRmatrix matrix;
	GRspacenum *osnum; IGRshort *flag; struct GRid *context_info)

{
    IGRlong i;				/* loop index			*/
    IGRlong OMmsg;			/* local return codes		*/


    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;

    for (i=0; i<16; ++i)
    {
	matrix[i] = me->matrix[i];
    }
    *type = me->mx_type;
    *osnum = me->osnum;
    *flag = me->flags;

    context_info->objid = my_id;
    context_info->osnum = OM_Gw_current_OS;
 
    return( OMmsg );
}
end implementation GRcontext;
