class implementation SKcompcurve;

#include <alloca.h>
#include "nddef.h"

#define FIRST  0
#define LAST   1

method SKcreate_self_constraints (IGRlong *msg; IGRushort opts;
                                  struct GRmd_env *md_env;
                                  IGRint *num_cnstrs; GRobjid **cnstrs)
{
  OM_S_CHANSELECT chan_to_comps;

  *msg = EMS_S_Success;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  return (om$send (msg = OPPmargs, p_chanselect = &chan_to_comps));
}

method SKcheck_degeneracy (IGRlong *msg; IGRushort options; struct GRmd_env *md_env;
                           struct SKsolvevars *solvedvars;
                           GRobjid *degenerate)
{
  OMuint i, count;
  int stat_OM;
  long msg_loc;
  OM_S_CHANSELECT chan_to_comps;
  OM_S_OBJECT_LINKAGE *comp_list;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
                        count = &count);
  if (count) 
  {
    comp_list = (OM_S_OBJECT_LINKAGE *)alloca ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
    stat_OM = om$get_channel_objects ( list = comp_list, size = count, 
                                       count = &count, 
                                       object = me, 
                                       p_chanselect = &chan_to_comps );
    for (i=0; i<count; i++)
    {
      stat_OM = om$send ( msg = message SKgeometry.SKcheck_degeneracy 
                                (&msg_loc, options, md_env, solvedvars, degenerate),
                          targetid = comp_list[i].S_objid, 
                          targetos = comp_list[i].osnum);
      if (msg_loc == EMS_I_Degenerate) 
      {
        *msg = msg_loc;
        break;
      }
    }
  }
  EMWRAPUP ( *msg, stat_OM, "SKcompcurve.SKcheck_degeneracy");
  return (stat_OM);
}

method GRrevparm (IGRlong *msg; struct GRmd_env *md_env)
{
  IGRint  i, j, endinx, ptgeominx[2];
  OMuint  num_comps, count;
  IGRlong stat_OM, msg_loc;
  GRobjid first_pt, proc_pt, proc_first_pt, proc_last_pt;
  OM_S_CHANSELECT chan_to_comps, chan_to_defpts, chan_to_geom;
  OM_S_OBJECT_LINKAGE *geomlist, ptgeomlist[2], ptlist[3];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  first_pt = NULL_OBJID;

  /*
   * Invoke the default implementation
   */

  stat_OM = om$send (mode = OM_e_wrt_parent,
             msg = message SKcompcurve.GRrevparm (&msg_loc, md_env),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Reverse the connection of each of the geometry from the def-pts side.
   * The geometry should continue to look down at the def-pts at the same
   * indices.
   */

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  num_comps = 0;
  om$get_channel_count (object = me,
   p_chanselect = &chan_to_comps, count = &num_comps);
  EMerr_hndlr (!num_comps, *msg, EMS_E_InvalidCase, ret_end);

  geomlist = (OM_p_OBJECT_LINKAGE) alloca (num_comps *
              sizeof (OM_S_OBJECT_LINKAGE));
  EMerr_hndlr (!geomlist, *msg, EMS_E_NoStackMemory, ret_end);

  om$get_channel_objects (object = me,
   p_chanselect = &chan_to_comps, count = &num_comps, size = num_comps,
   list = geomlist);

  EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geom);
  for (i=0; i<num_comps; i++)
    {
    count = 0;
    om$get_channel_objects (objid = geomlist[i].S_objid,
     p_chanselect = &chan_to_defpts, size = 3, count = &count,
     list = ptlist);
    EMerr_hndlr (!count || count > 3, *msg, EMS_E_InvalidCase, ret_end);

    if (i == FIRST)
      first_pt = ptlist[FIRST].S_objid;

    for (endinx=FIRST; endinx<=LAST; endinx++)
      {
      proc_first_pt = ptlist[FIRST].S_objid;
      proc_last_pt = ptlist[count-1].S_objid;
      if (endinx == FIRST)
        proc_pt = proc_first_pt;
      else if (endinx == LAST && i == num_comps-1 && first_pt != proc_last_pt)
        proc_pt = proc_last_pt;
      else 
        continue;

      count = 0;
      om$get_channel_objects (objid = proc_pt, p_chanselect = &chan_to_geom,
       count = &count, size = 2, list = ptgeomlist);
      EMerr_hndlr (!count || count > 2, *msg, EMS_E_InvalidCase, ret_end);

      for (j=0; j<count; j++)
      {
        OMuint tmp_index;
        
        om$get_index (objid_c = ptgeomlist[j].S_objid,
         p_chanselect = &chan_to_defpts, objid = proc_pt,
         indexaddr = &tmp_index );
        ptgeominx [j] = tmp_index;
      }

      om$send (msg = message Root.wild_disconnect (chan_to_geom),
       targetid = proc_pt);

      for (j=0; j<count; j++)
        om$send (msg = message Root.connect (chan_to_geom, ptgeominx[j],
         ptgeomlist[j].S_objid, OM_Gw_current_OS, chan_to_defpts, 0),
         targetid = proc_pt);
      }
    }



ret_end:
  EMWRAPUP (*msg, stat_OM, "SKcompcurve.GRrevparm");
  return (stat_OM);
}

end implementation SKcompcurve;


