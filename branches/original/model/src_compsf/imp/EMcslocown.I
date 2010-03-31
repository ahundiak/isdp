/*

if(isactive || (num_comps > 1))
 send wrt message GRowner.GRlocate_owner to myself
else
 send wrt object GRowner.GRlocate_owner to owners

*/
class implementation EMScompsurf;

#include "EMS.h"
# include "msdef.h"         /* MSSUCC               */
# include "EMSmsgdef.h"     /* EMWRAPUP support     */
# include "EMSlcdef.h"      /* LC_...               */

method GRlocate_owner(IGRlong *EMmsg; struct GRlc_cvl *cvl;
                      struct GRlc_path *path; IGRint *path_position)
{
  IGRlong          sts = OM_S_SUCCESS;
  IGRboolean       active_state = FALSE;
  IGRint           num_comps = 0;

  *EMmsg = MSSUCC;

  sts = om$send(msg = message EMSsurface.EMisactive(EMmsg,
                        &active_state, NULL), 
                  targetid = my_id);
  if(! (1 & *EMmsg & sts)) goto wrapup;

  sts = om$send(msg = message GRowner.GRget_number_components(EMmsg, 
        &num_comps), targetid = my_id);
  if(! (1 & *EMmsg & sts)) goto wrapup;

  if( (num_comps > 1) || active_state ) 
    sts = om$send(msg = message GRowner.GRlocate_owner(EMmsg, cvl, path,
                  path_position),mode=OM_e_wrt_message,targetid=my_id);
  else
  {
    OM_S_CHANSELECT to_owners;

    to_owners.type = OM_e_addr;
    to_owners.u_sel.addr = &me^^GRconnector.to_owners;
    sts = om$send(msg = OPPmargs, p_chanselect = &to_owners,from=0,to=0);
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSsolid.GRlocate_owner")
  return(sts);
}

end implementation EMScompsurf;
