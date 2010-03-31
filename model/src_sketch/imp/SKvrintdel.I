class implementation SKvariable;

#define NUM_STATIC 5

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_SKvalvar_class_id;

from GRgraphics import GRdisplay, GRdelete;
from SKconstraint import SKgetmajconstrs;

method SKintdelete (IGRlong *msg; IGRushort opts;
                    struct GRmd_env *md_env)
{
  IGRboolean deletable;
  IGRint i, num_major_constrs;
  OMuint count;
  IGRlong stat_OM, msg_loc;
  GRobjid *major_constrs, major_constrs_mem[NUM_STATIC];
  GRclassid myclass;
  enum GRdpmode dpmode;
  OM_S_CHANSELECT chan_to_geom, chan_to_constr;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  major_constrs = NULL;

  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geom);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_geom,
   count = &count);

  deletable = TRUE;
  if (count)
    deletable = FALSE;

  if (deletable)
    {
    EMmake_chanselect (SKvariable_to_constraints, &chan_to_constr);
    num_major_constrs = 0;
    major_constrs = major_constrs_mem;
    om$send (msg = message SKconstraint.SKgetmajconstrs (&msg_loc,
     opts, NUM_STATIC, &num_major_constrs, &major_constrs),
     p_chanselect = &chan_to_constr);

    om$get_classid (object = me, p_classid = &myclass);
    if (om$is_ancestry_valid (subclassid = myclass,
         superclassid = OPP_SKvalvar_class_id) == OM_S_SUCCESS &&
        num_major_constrs)
      deletable = FALSE;

    if (deletable)
      {
      om$send (msg = message Root.wild_disconnect (chan_to_constr),
       targetid = my_id);

      dpmode = GRbehe;
      for (i=0; i<num_major_constrs; i++)
        {
        om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
         &md_env->md_env.matrix_type, md_env->md_env.matrix, &dpmode,
         &md_env->md_id), targetid = major_constrs[i]);

        om$send (msg = message GRgraphics.GRdelete (&msg_loc,
         md_env), targetid = major_constrs[i]);
        }

      om$send (msg = message Root.delete (TRUE),targetid = my_id);
      }
    }

  if (major_constrs && major_constrs != major_constrs_mem)
    om$dealloc (ptr = major_constrs);

  EMWRAPUP (*msg, stat_OM, "SKvariable.SKintdelete");
  return (stat_OM);
}

end implementation SKvariable;
