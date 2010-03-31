/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
#include "emsmacros.h"
#include "EMSerrordef.h"

method EMsplit_surface(IGRlong               *EMmsg;
                       struct GRmd_env       *my_env;
                       struct GRvg_construct *construct_list;
                       IGRint                option;
                       IGRlong               in_numpars,
                                             *out_numpars;
                       IGRdouble             *in_parms,
                                             **out_parms;
                       struct GRid           insrf_id;
                       GRobjid               **out_surf_ids;
                       IGRboolean            *uv_closed,
                                             delete_flag)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure

Assumption

Bugs

History
	
	  gupta 	05/04/87:	design date

Algorithm

      This is the overidden method which is declared at EMSsurface.
      This first invokes the EMSsurface message and then establishes
      the solid or dpr topology.
*/
                   
{
  IGRlong          stat_OM,msg;
  IGRint           num_surf;
 
  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  num_surf = 0;

  /* get the split surfaces */

  stat_OM = om$send(mode = OM_e_wrt_object,
                    msg = message EMSsurface.EMsplit_surface(&msg,
                          my_env, construct_list, option, in_numpars,
                          out_numpars, in_parms, out_parms, 
                          insrf_id, out_surf_ids, uv_closed, delete_flag),
                    targetid = insrf_id.objid,
                    targetos = insrf_id.osnum);
  EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_splsf.EMsplit_surface");
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

  num_surf = *out_numpars + 1;

  /* establish my messed up topology */

  if (num_surf > 1)
   {
    stat_OM = om$send(msg = message EMSsfsplit.EMest_split_top(&msg,
                            option, num_surf, *out_parms,my_env, insrf_id,
                            uv_closed, *out_surf_ids),
                      targetid = my_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMsfsp_splsf.EMest_split_top");
    EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);
   }
wrapup:

   return(stat_OM);
}
end implementation EMSsfsplit;
