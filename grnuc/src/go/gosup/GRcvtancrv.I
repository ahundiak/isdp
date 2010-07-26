/*
 * Description
 *    This function returns the model space point, tangent vector and radius
 *    of curvature of a curve at a given u parameter.
 *
 * Arguments
 *    struct GRid   GRid_in     objid and osnum of the input curve.
 *    IGRdouble     uparm       input u parameter on the curve.
 *    IGRpoint      outpoint    output model space point. NULL if not needed.
 *    IGRvector     tan         output tangent vector at uparm. NULL if 
 *                              not needed.
 *    IGRdouble     *radcrv     output radius of curvature value at uparm.
 *                              NULL if not needed.
 *
 * History
 *    dhm    11/05/91    creation date.
 */

class implementation GRcurve;

#include <stdio.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "OMlimits.h"
#include "exdef.h"
#include "ex.h"
#include "godef.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

#define MAXRAD  1e+300

int GRget_curve_tan_radcrv(GRid_in, uparm, outpoint, tan, radcrv)
struct GRid   GRid_in;
IGRdouble     uparm;
IGRpoint      outpoint;
IGRvector     tan;
IGRdouble     *radcrv;
{

  IGRlong    status, msg;
  IGRpoint   poly[2];
  struct GRparms   spar;
  struct GRmd_env  md_env;

  status = OM_S_SUCCESS;

  gr$get_module_env(buffer = &md_env);

  /*
   * Return the point at the input u parameter.
   */

  if (outpoint)
  {
    status = om$send(msg = message GRvg.EMptatpr(&msg,
                           &md_env.md_env.matrix_type, md_env.md_env.matrix,
                           &uparm, 1, outpoint),
                     senderid = NULL_OBJID,
                     targetid = GRid_in.objid,
                     targetos = GRid_in.osnum);
    if (!(1&status))
    {
      printf("\n GRvg.EMpratpt failed in GRcvtancrv.I \n");
      goto quit;
    }

  }

  if (tan)
  {
    spar.u = uparm;
    status = om$send(msg = message GRcurve.EMcvtanorm(&msg,
                           &md_env.md_env.matrix_type, md_env.md_env.matrix,
                           NULL, 1, &spar, NULL, NULL, 1.0, NULL, TRUE,
                           FALSE, (double *)poly, NULL),
                     senderid = NULL_OBJID,
                     targetid = GRid_in.objid,
                     targetos = GRid_in.osnum);
    if (!(1&status))
    {
      printf("\n GRcurve.EMcvtanorm failed in GRcvtancrv.I \n");
      goto quit;
    }

    tan[0] = poly[1][0] - poly[0][0];
    tan[1] = poly[1][1] - poly[0][1];
    tan[2] = poly[1][2] - poly[0][2];

  }

  if (radcrv)
  {
    spar.u = uparm;
    status = om$send(msg = message GRcurve.EMcvradcrv(&msg,
                           &md_env.md_env.matrix_type, md_env.md_env.matrix,
                           NULL, 1, &spar, NULL, NULL, MAXRAD, NULL, radcrv,
                           NULL, NULL, NULL, NULL),
                     senderid = NULL_OBJID,
                     targetid = GRid_in.objid,
                     targetos = GRid_in.osnum);
    if (!(1&status))
    {
      printf("\n GRcurve.EMcvradcrv failed in GRcvtancrv.I \n");
      goto quit;
    }

  }

quit:
  return (status);

}

end implementation GRcurve;
