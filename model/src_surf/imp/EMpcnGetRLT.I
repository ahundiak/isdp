/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpcone;

#include "EMS.h"

method EMgetRuleLineTable(IGRlong *EMmsg;
                          IGRboolean            nat_edges;
                          IGRint                *u_stripes,
                                                *v_stripes;
                          struct IGRbsp_surface *in_surf;
                          IGRint                *mx_type;
                          IGRmatrix             mx;
                          IGRchar               *in_buffer;
                          IGRint                buffer_size;
                          struct IGResqbs       **rlt)
/*
Astract

    This method is provided so the partial cones and partial cylinders
    use the EMSsubbs method rather than the EMSelpcone method of
    generating the rule line table.

History

    AIC     17 Apr 89       Support MSC.
    AIC     23 Mar 88       Creation Date.
*/
{
  IGRlong               sts;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  sts = om$send(msg = message EMSsubbs.EMgetRuleLineTable(
                    EMmsg,
                    nat_edges,
                    u_stripes,
                    v_stripes,
                    in_surf,
                    mx_type,
                    mx,
                    in_buffer,
                    buffer_size,
                    rlt),
                mode = OM_e_wrt_message, targetid = my_id);

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSpcone.EMgetRuleLineTable")
  return (sts);
}

end implementation EMSpcone;
