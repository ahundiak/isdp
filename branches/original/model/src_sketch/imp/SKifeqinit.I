class implementation SKifequal;

#include "OMmacros.h"

extern OMuword OPP_SKequal_class_id;

method SKinit (IGRlong *msg; IGRushort options;
               struct GRmd_env *md_env;
               IGRint num_pts; GRobjid *pt_ids;
               IGRushort cnstr_props;
               GRobjid *geom_handle;
               IGRchar *moreinfo)

{
  IGRlong OM_stat, msg_loc;
  IGRint i, j, num_eq_cnstrs;
  GRobjid cnstrid, eq_pts[4];

  OM_stat = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /*
   * Create individual equal-length constraints out of a set of
   * four consecutive points. No attempt is being made to find the
   * best (least perturbing) grouping of four. Each of the member
   * constraints is connected up to this interface.
   */

  num_eq_cnstrs = (num_pts/2) - 1;
  for (i=0, j=0; i<num_eq_cnstrs; i++, j+=2)
    {
    OM_BLOCK_MOVE (&pt_ids[j], eq_pts, 4 * sizeof(GRobjid));

    OM_stat = om$construct (classid = OPP_SKequal_class_id,
               msg = message SKconstraint.SKinit (&msg_loc,
               ((options | SK_OPT_NO_MGR_CONNECT) & ~SK_OPT_CREATE_GEOMETRY),
               md_env, 4, eq_pts, cnstr_props, NULL, moreinfo),
               p_objid = &cnstrid);
    EMerr_hndlr (EMSerror (OM_stat & msg_loc), *msg, EMS_E_OMerror, wrapup);

    OM_stat = om$send (msg = message SKinterface.SKconnect_to_member
               (&msg_loc, NULL, cnstrid, MAXINT, MAXINT),
               targetid = my_id);
    EMerr_hndlr (EMSerror (OM_stat & msg_loc), *msg, EMS_E_OMerror, wrapup);
    }
  
  /*
   * Having constructed the member constraints, this interface constraint is
   * then initialized using the default method.
   */

  OM_stat = om$send (mode = OM_e_wrt_parent,
             msg = message SKinterface.SKinit (&msg_loc,
             (options & ~SK_OPT_NO_MGR_CONNECT) | SK_OPT_NO_CONNECT_PTS,
             md_env, num_pts, pt_ids, cnstr_props, geom_handle, moreinfo),
             targetid = my_id);
  EMerr_hndlr (EMSerror (OM_stat & msg_loc), *msg, EMS_E_OMerror, wrapup);

wrapup:
  EMWRAPUP (*msg, OM_stat, "SKifequal.SKinit");
  return (OM_stat);
}

end implementation SKifequal;
