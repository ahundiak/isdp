/* #######################    APOGEE COMPILED   ######################## */
class implementation GRcontext;

#include "grimport.h"
#include "refdef.h"
#include "msdef.h"

GRrefmode(msg,type,matrix,ref_id,ref_osnum,reset)

IGRlong		*msg;
IGRshort	*type;
IGRmatrix	matrix;
GRobjid		*ref_id;
GRspacenum	*ref_osnum;
IGRint		*reset;

{
    IGRshort	flag;

    IGRlong	OMmsg;

    IGRint	mode;

    struct GRid	gr_oid,
		context_id;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
    *reset = 0;

    gr_oid.objid  = *ref_id;
    gr_oid.osnum  = *ref_osnum;

    GRgetctxid(msg,type,matrix,&gr_oid,&context_id);
    if ( 1 & *msg)
    {
        OMmsg = om$send (msg = message GRcontext.GRgetflag
		(msg ,&flag),
	    senderid = *ref_id,
	    targetid = context_id.objid,
	    targetos = context_id.osnum);

   	if (flag & GRCYCLIC_ATTACHMENT)
   	{
	    mode = 0;
	    GRset_expansion_mode(&mode);
	    *reset = 1;
   	}
   }
   return(OMmsg);
}

end implementation GRcontext;
