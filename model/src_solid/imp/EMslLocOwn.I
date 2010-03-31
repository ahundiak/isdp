/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsolid;

#include "EMS.h"
# include "msdef.h"         /* MSSUCC               */
# include "EMSmsgdef.h"     /* EMWRAPUP support     */
# include "EMSlcdef.h"      /* LC_...               */

method GRlocate_owner(IGRlong *EMmsg; struct GRlc_cvl *cvl;
                      struct GRlc_path *path; IGRint *path_position)
{
  IGRlong          sts = OM_S_SUCCESS;
  IGRulong loc_props;
  IGRboolean       active_state = FALSE;

  *EMmsg = MSSUCC;

  loc_props = cvl->attributes.obj_attr.owner_action;

  if (!(loc_props & LC_INTERMIDIATE))  /*Speed optimization.*/
  {
    sts = om$send(msg = message EMSsurface.EMisactive(EMmsg,
                        &active_state, NULL), 
                  targetid = my_id);
    if(! (1 & *EMmsg & sts)) goto wrapup;
  }

  if( (loc_props & LC_INTERMIDIATE) || active_state ) 
  {
    sts = om$send(msg = message GRowner.GRlocate_owner(EMmsg, cvl, path,
                  path_position),mode=OM_e_wrt_message,targetid=my_id);
  }
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

end implementation EMSsolid;
