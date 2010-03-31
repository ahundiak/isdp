/* ###################   APOGEE COMPILED   ################## */
class implementation EMSptedge;

/*
   History

        Sudha   07/06/93        modified for BSprototype includes
*/

#include "EMS.h"
%safe
#include <math.h>
%endsafe
#include "EMSopt.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "mamulmx.h"


method EMuv_transform (
	IGRlong			*EMmsg;
	IGRdouble		matrix[16];
	struct 	EMSpartolbasis	*partolbasis;
	IGRshort		option;
	IGRchar			*null_ptr1;
	IGRchar			*null_ptr2)

{
  IGRdouble         mat_a[4],mat_c[4], partol;
  IGRlong           OM_stat, rc;
  IGRshort          j, l = 4, m = 4, n = 1;
  IGRboolean        status, EFextract_par();

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if (!partolbasis->is_valid)
  {
    OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info (
                        EMmsg, NULL, partolbasis),
                       targetid = my_id);
    EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
  }
  status = EFextract_par (BSTOLLENVEC, partolbasis->tol, &partol, &rc);

  mat_a[0] = ME.EMSptedge->point[0];
  mat_a[1] = ME.EMSptedge->point[1];
  mat_a[2] = 0.0;
  mat_a[3] = 1.0;

  status = MAmulmx (&rc, &l, &m, &n, matrix, mat_a, mat_c);
  EMerr_hndlr ((!status || !(1&rc)),*EMmsg,EMS_E_Fail,wrapup);
  for(j=0; j<2; j++)
   {
    if ( fabs(mat_c[j] - 0.0) < partol) mat_c[j] = 0.0;
    if ( fabs(mat_c[j] - 1.0) < partol) mat_c[j] = 1.0;
   }

  ME.EMSptedge->point[0] = mat_c[0];
  ME.EMSptedge->point[1] = mat_c[1];

wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "In EMSptedge.EMuv_transform");
    return (OM_stat);

}

end implementation EMSptedge;
