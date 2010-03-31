class implementation EMSdatpln;

#include "nddef.h"

method NDcopy_graph(IGRlong *msg;
                    IGRint cp_type;
 		    struct GRmd_env *fr_env,*to_env;
		    struct NDcp_list *nd_cp_list; 
                    int list_size;
		    int myinx)
/* ****************************************************************
Description
 This override will cause the copy of the datum plane object
 in the context of graph copy.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : Failure in copy.

History
 pp : 07/24/91 : Creation
 **************************************************************** */
{
 IGRlong status;
 IGRint mypos;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;

 mypos = nd_cp_list[myinx].position;
 
 if (mypos & ND_BODY)
 {
   *msg = MSINARG;
   goto wrapup;
 }
 else 
 {
/*
 * Copy myself non-associatively if necessary.
 */
  if (nd_cp_list[myinx].clone == NULL_OBJID)
  {
   status = om$send (msg = message GRgraphics.GRcopy(msg,fr_env, to_env,
                          &nd_cp_list[myinx].clone),
                    targetid = my_id);
   if (!(1&status&*msg)) goto wrapup;
  }
 }
 

wrapup:
 return (status);
}
end implementation EMSdatpln;

