class implementation EMSasptcnstr;

#include "OMmacros.h"
#include "EMSasopts.h"

#define FIRST  0

#define STATIC_MAX_PARENTS 5

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_IGEgadget_class_id;

from EMSparameter import EMgetdimgeom;
from EMSassoc import EMexternal_constraint_changed;

method EMalt_init (IGRlong *msg; IGRushort opts;
                   struct GRmd_env *md_env;
                   IGRint num_parents; 
                   struct GRid *parents; 
                   IGRushort cnstr_props; IGRchar *moreinfo;
                   IGRint num_children;
                   struct GRid *children)
{
  IGRint i;
  IGRlong msg_loc, stat_OM;
  struct EMSasptinfo *asptinfo;
  struct DMkeypt_str dm_keypt;
  struct GRid my_grid;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  asptinfo = (struct EMSasptinfo *) moreinfo;

  me->type = DMkeypt;
  dm_keypt.u_par = 0.0;
  OM_BLOCK_MOVE(asptinfo->pts,dm_keypt.point, sizeof (IGRpoint));
  om$vla_set_dimension(varray = ME.DMsrc->data,size = sizeof (dm_keypt));

  stat_OM = om$send (msg = message NDnode.NDconnect (num_parents, parents,
                           NULL_GRID, ND_ADD),
                     targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$send (msg = message NDnode.NDchg_state (ND_DEL_NO_CH,
             ND_DEL_NO_CH), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

  /*
   * Connect up the children
   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  for (i=0; i<num_children; i++)
    {
    stat_OM = om$send (msg = message NDnode.NDconnect (1, &my_grid, NULL_GRID,
               ND_ADD), targetid = children[i].objid, 
               targetos = children[i].osnum);
    EMomerr_exit (stat_OM, ret_end);
    }

  /*
   * If requested, create a graphics handle for myself and connect
   * it as rigid component.
   */

  if (opts & EMScnstr_connect_geomhandle)
    {
    stat_OM = om$send (msg = message EMSimpcnstr.EMgeomhandle (&msg_loc,
               NULL, md_env, NULL), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSasptcnstr");

  if (stat_OM & *msg & 1)
    {
        om$send ( msg = message EMSassoc.EMexternal_constraint_changed 
                                    (msg, EMext_const_chg_CONSTRAINT_ADDED),
                  targetid = children->objid,
                  targetos = children->osnum );
    }

  return (stat_OM);
}

end implementation EMSasptcnstr;
