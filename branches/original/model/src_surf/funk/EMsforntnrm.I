class implementation EMSsubbs;

#include "OMmacros.h"

#define X 0
#define Y 1
#define Z 2

#define FIRST  0
#define SECOND 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

IGRlong EMgetorntnrm (msg, opts, mattyp, mat, srfid, u, v, pt, norm)
IGRlong *msg;
IGRushort opts;
IGRshort *mattyp;
IGRmatrix mat;
struct GRid *srfid;
IGRdouble u, v;
IGRdouble *pt, *norm;
{
  IGRint i;
  IGRlong msg_loc, stat_OM;
  IGRpoint nrmpts[2];
  struct IGRbsp_surface srfdef;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (msg = message EMSsubbs.EMgetbsdef (&msg_loc,
             &srfdef), targetid = srfid->objid, targetos = srfid->osnum,
             senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message EMSsubbs.EMsftanorm (&msg_loc,
             mattyp, mat, NULL, 1, &u, 1, &v, 1.0, NULL,
             FALSE, TRUE, (IGRdouble *) nrmpts, NULL),
             targetid = srfid->objid, targetos = srfid->osnum,
             senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  BSmkvec (&msg_loc, norm, nrmpts[FIRST], nrmpts[SECOND]);
  if (!srfdef.pos_orient)
    for (i=X; i<=Z; i++)
      norm[i] = -norm[i];
  OM_BLOCK_MOVE (nrmpts[FIRST], pt, sizeof (IGRpoint));

ret_end:
  return (stat_OM);
}

end implementation EMSsubbs;

