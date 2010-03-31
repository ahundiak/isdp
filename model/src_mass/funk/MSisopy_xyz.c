/* ###################   APOGEE COMPILED   ################## */
/*
    gupta : 01/02/89 : Creation
    Sudha : 06/28/93 : Modified for BSprototype ansification
    SCW   : 02/13/97 : Changed emsmacros inclusion to emsmacros_c


    This function returns the geometry of a iso-curve in a polyline
    format in model space. surf_id and surf_geom can be NULL, in which
    case, this method will fetch the same. If the curve is second order,
    only end points are returned.
*/

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include <math.h>
#include "emsmacros_c.h"
#include "bsconstprcv.h"
#include "bsalloccv.h"

MSpyxyz_geometry (EMmsg, u_dir, param, surf_geom, pygeom)

IGRlong               *EMmsg;
IGRboolean            u_dir;
IGRdouble             *param;
struct IGRbsp_surface *surf_geom;
struct IGRpolyline    *pygeom;

{
  IGRlong               msg;
  IGRshort              option;
  IGRdouble             cht_tol, temp_tol;
  IGRboolean            tst_planar = TRUE;
  struct IGRbsp_curve   *iso_curve;
  IGRboolean            status, EFstroke_the_curve();

/*--------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;

  pygeom->points = NULL;
  iso_curve = NULL;

  if (u_dir)
      BSalloccv (surf_geom->v_order, surf_geom->v_num_poles,
                 surf_geom->rational, NULL, &iso_curve, &msg);
  else
      BSalloccv (surf_geom->u_order, surf_geom->u_num_poles,
                 surf_geom->rational, NULL, &iso_curve, &msg);

  EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  option = u_dir ? 1 : 0;

  BSconstprcv (&msg, surf_geom, &option, param, &tst_planar, iso_curve);
  EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  
  BSEXTRACTPAR(&msg, BSTOLCHRDHT, cht_tol); 

  temp_tol = cht_tol / 10.0;

  status = EFstroke_the_curve (iso_curve, &temp_tol, pygeom, &msg);
  EMerr_hndlr (! status || !(1 & msg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:

  if (iso_curve) free(iso_curve);

  return;
}
