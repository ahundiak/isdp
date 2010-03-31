/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*
HISTORY:

Long Ago: ??  Creation
08/26/92: NP  Modified for ANSI compliance.

*/


#include "EMSfrtdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"

extern IGRchar EMSrltBuffer[RLT_BUFFER_SIZE];

method EMnobdrydisp (IGRlong *msg; IGRushort opts;
                     IGRshort *mattyp; IGRmatrix mat;
                     enum GRdpmode disp_mode;
                     struct GRid *disp_id)
{
  IGRint i, num_bdrys, mattyp_int;
  IGRlong stat_OM, msg_loc;
  struct IGRbsp_surface *srf;
  struct IGResqbs *rlt;
  struct DPele_header srf_dis_buffer;
  struct IGRdisplay disp_attr;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  rlt = NULL;

  stat_OM = EMgetabsg (&msg_loc, mattyp, mat, OM_Gw_current_OS, my_id, &srf);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  mattyp_int = *mattyp;
  stat_OM = om$send (msg = message EMSsubbs.EMgetRuleLineTable (&msg_loc,
             TRUE, NULL, NULL, srf, &mattyp_int, mat,
             EMSrltBuffer, RLT_BUFFER_SIZE, &rlt), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  for (i=0; i<rlt->u_rules; i++)
    rlt->u_num_bound[i] = 0;
  for (i=0; i<rlt->v_rules; i++)
    rlt->v_num_bound[i] = 0;

  disp_attr = ME.GRvg->display_attr;
  dp$build_dis_buffer (buffer = &srf_dis_buffer, type = IGRQS, 
   display_att = &disp_attr, ele_spec_att = rlt, geometry = srf);

  num_bdrys = srf->num_boundaries;
  dp$display (msg = &msg_loc, objid = disp_id->objid, osnum = disp_id->osnum,
   mode = disp_mode, buffer = &srf_dis_buffer);
  srf->num_boundaries = num_bdrys;

ret_end:
  if (rlt && rlt != (struct IGResqbs *)EMSrltBuffer)
    om$dealloc (ptr = rlt);

  EMWRAPUP (*msg, stat_OM, "EMAcyl.EMdispgeomp");
  return (stat_OM);
}

end implementation EMSsubbs;
