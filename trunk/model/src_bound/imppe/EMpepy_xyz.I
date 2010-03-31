/* ###################   APOGEE COMPILED   ################## */
/*
    gupta : 12/07/88 : Creation


    This method returns the geometry of a part edge in a polyline
    format in model space. surf_id and surf_geom can be NULL, in which
    case, this method will fetch the same. This method merely sends the
    message to its owner giving its partinfo.
*/

class implementation EMSpartedge;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSbnd.h"
#include "OMmacros.h"

method EMpyxyz_geometry (IGRlong                *EMmsg;
                         struct GRmd_env        *my_env;
                         struct GRid            *surf_id;
                         struct IGRbsp_surface  *surf_geom;
                         IGRint                 from_spaninx,
                                                num_spans;
                         IGRboolean             reverse;
                         struct EMSpartedinfo   *partinfo;
                         struct IGRpolyline     *pygeom;
                         struct EMSpartolbasis  *partolbasis;
                         IGRint                 *num_iso;
                         struct EMtopology_info *topology;
                         IGRboolean             *swap_valid;
                         IGRint                 *swap_index;
                         IGRushort      options)

{
  IGRlong               stat_OM, msg;
  struct GRid           surf_GRid;
  struct EMSpartedinfo  my_partinfo;
  OM_S_CHANSELECT       to_edge;

/*--------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$make_chanselect(channame = "EMSbd_owner.to_comps",
                               p_chanselect = &to_edge);
  if (! (1 & stat_OM)) goto wrapup;

  if (! partinfo)
   {
    EMput_partinfo (my_partinfo);
    partinfo = &my_partinfo;
   }
 
  if (! surf_id)
   {
    stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                          (&msg, &surf_GRid.objid, NULL),
                       targetid = my_id);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    surf_GRid.osnum = OM_Gw_current_OS;
   }
  else
   {
    surf_GRid.objid = surf_id->objid;
    surf_GRid.osnum = surf_id->osnum;
   }

  stat_OM = om$send(msg = message EMSedge.EMpyxyz_geometry(&msg, my_env,
                          &surf_GRid, surf_geom, from_spaninx, num_spans,
                          reverse, partinfo, pygeom, partolbasis,
                          num_iso, topology, swap_valid, swap_index,
                          options),
                    p_chanselect = &to_edge);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

wrapup: 

  EMWRAPUP (*EMmsg, stat_OM, "EMSpartedge.EMpyxyz_geometry");
  return (stat_OM);
}

end implementation EMSpartedge;
