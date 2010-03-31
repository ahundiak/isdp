class implementation SKcompcurve;

#include "gocmacros.h"

method SKrecompute_yourself (IGRlong *msg; struct GRmd_env *md_env;
                             IGRshort *mattyp_to_lxyz; IGRdouble *mat_to_lxyz)
{
 OM_S_CHANSELECT       to_cmpnts_chan;
 IGRlong               i, OM_stat, msg_loc;
 OMuint		       count;
 
 OM_stat = OM_S_SUCCESS;
 *msg = EMS_S_Success;

 EMmake_chanselect (GRcmpowner_to_components, &to_cmpnts_chan);
 count = 0;
 om$get_channel_count (object = me, p_chanselect = &to_cmpnts_chan,
                       count = &count);
 if (count)
   {
   for (i=0; i<count; i++)
     {
     OM_stat = om$send (msg = message SKgeometry.SKrecompute_yourself (
                &msg_loc, md_env, mattyp_to_lxyz, mat_to_lxyz),
                p_chanselect = &to_cmpnts_chan, from = i, to = i);
     EMerr_hndlr (EMSerror (OM_stat & msg_loc), *msg, EMS_E_Fail, wrapup);

     if (msg_loc == EMS_I_Degenerate)
       *msg = msg_loc;
     }
   }

wrapup:
  EMWRAPUP(*msg, OM_stat, "SKcompcurve.SKrecompute_yourself");
  GR_NOTIFY_LISTENERS(msg, &OM_stat, GR_GEOM_POSTED);
 return (OM_stat);

}
end implementation SKcompcurve;
