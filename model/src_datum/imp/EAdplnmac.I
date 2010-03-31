class implementation EMAdatpln;

#include "nddef.h"

from EMSdatplnmgr import EMmanage_datum_entry;

method NDcopy_graph(IGRlong *EMmsg;
                    IGRint cp_type;
 		    struct GRmd_env *fr_env,
                                    *to_env;
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
 IGRlong mypos,msg_loc;
 OMuword mgros;
 OM_S_OBJID *newobjid,mgrid;

 status = OM_S_SUCCESS;
 *EMmsg = MSSUCC;
 newobjid = &nd_cp_list[myinx].clone;

 mypos = nd_cp_list[myinx].position;
 
 if (mypos & ND_BODY)
 {
  status = om$send(mode = OM_e_wrt_parent,
                   msg = message EMSdatpln.GRcopy(&msg_loc, fr_env,
                                                 to_env, newobjid),
                   targetid = my_id);
  if (!(1&status&msg_loc)) goto wrapup;

  status = ems$get_datum_plane_mgr(msg = &msg_loc,
                                   osnum = &to_env->md_id.osnum,
                                   mgrid = &mgrid,
                                   mgros = &mgros);
  if (!(1&status&msg_loc)) goto wrapup;

  status = om$send (msg = message EMSdatplnmgr.EMmanage_datum_entry(&msg_loc,
                          EMS_OPT_ADD,
                          *newobjid),
                    targetid = mgrid,
                    targetos = mgros);
  if (!(1&status&msg_loc)) goto wrapup;
 }
 else
 {
  status = om$send (msg = message EMAdatpln.NDcopy_graph(&msg_loc,cp_type,
                          fr_env,to_env,nd_cp_list,list_size,myinx),
                    mode = OM_e_wrt_parent,
                    targetid = my_id);
  EMerr_hndlr(!(1&status&msg_loc), *EMmsg ,MSFAIL, wrapup);
 }
 

wrapup:
 return (status);
}
end implementation EMAdatpln;

