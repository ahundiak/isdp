class implementation EMSparamvc;

#include "OMmacros.h"
#include "gocmacros.h"
#include "ECmsg.h"
#include "msdef.h"
#include "msmacros.h"

method GRgenabsg (long *msg; short *mattyp; IGRmatrix mat;
                  char **p_absg)
{
  int byte_size;
  long msg_loc, stat_OM;
  struct EMSgeomdata vcgeom;
  struct GRabsg_hdr absg_hdr;
  struct IGRbsp_curve *p_crv;
  struct IGRpolyline poly;
  extern IGRboolean EMcnvtpybsn();
  extern char *GRabsg_alloc();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (msg = message EMSparameter.EMgetdimgeom (&msg_loc, NULL,
             mattyp, mat, NULL, NULL, &vcgeom, NULL), targetid = my_id);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (vcgeom.geomtype != GEOMDATA_LINE, *msg, EMS_E_InvalidCase,
   ret_end);

  GRbc_size (2, 2, FALSE, 0, byte_size);
  absg_hdr.geometry_size = byte_size;
  absg_hdr.id.objid = my_id;
  absg_hdr.id.osnum = OM_Gw_current_OS;
  absg_hdr.matrix_type = *mattyp;
  OM_BLOCK_MOVE (mat, absg_hdr.matrix, sizeof (IGRmatrix));
  p_crv = (struct IGRbsp_curve *) GRabsg_alloc (&msg_loc, &absg_hdr);
  EMerr_hndlr (EMSerror (msg_loc) || !p_crv, *msg, EMS_E_Fail, ret_end);
  GRbc_partition (p_crv, 2, 2, FALSE, 0);

  poly.num_points = 2;
  poly.points = vcgeom.line.line_pt1;
  EMcnvtpybsn (&msg_loc, 3, &poly, p_crv);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  *p_absg = (char *) p_crv;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMpvcgenabs.I");
  return (stat_OM);
}


method GRgetobjinfo(long *msg; struct GRobj_info *info)
{
  *msg = EMS_S_Success;
  ex$message ( buff = info->type, msgnumb = EMS_S_AxisParameter );
  return OM_S_SUCCESS;
}

end implementation EMSparamvc;
