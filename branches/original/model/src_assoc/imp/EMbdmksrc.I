class implementation EMSboundary;

#include "msdef.h" /* For MSSUCC */

method GRmksource(IGRlong *msg; struct GRid *context_GRid; GRspacenum constr_os;
		   struct GRid *src_GRid; IGRint option)

/***********************************************************************
Description
 This method will create a source/pointer object for a topology element.

Arguments	
 O   *msg	      IGRlong	       completion code
 I   *context_GRid    struct GRid      Context
				       context->objid = NULL_OBJID if no context
                                       exists
 I   *constrs_os      GRspacenum       object space of the dependency
				       (and thus object space of the returned 
				       object) 
 O   *src_GRid	      struct GRid      returned object
 I   option           IGRint           reserved for future use

Return Values
    	- MSSUCC if successful
	- MSFAIL error occurred

History
 07/17/91 : PP : Creation
************************************************************************** */
{
 IGRlong sts;
 struct GRid my_GRid;

 *msg = MSSUCC;
 sts = OM_S_SUCCESS;
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 EFcreate_pointer (msg, NULL, context_GRid, constr_os, 
                      &my_GRid,src_GRid);
 if (!(1&*msg)) *msg = MSFAIL;

 return (sts);
}
end implementation EMSboundary;

