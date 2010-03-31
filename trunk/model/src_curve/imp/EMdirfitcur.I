class implementation GRsubbc;

/*
  HISTORY

    Sudha  06/16/93     Modified for BSprototype ansification

*/

#include "EMS.h"
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "bserr.h"
#include "bsunwght_p.h"
#include "bsdirfitcv.h"

method EMdirect_fit_curve(
 IGRlong	order;
 IGRboolean	periodic;
 IGRlong	number_of_points;
 IGRpoint	*input_points;
 struct		GRlc_info *linestring;
 IGRvector	*beg_tangent;
 IGRvector	*end_tangent;
 struct		GRvg_construct *construct_list)

{
 IGRboolean	delete_abstract;
 IGRlong	sts, *msg, num_points;
 IGRpoint	*points;
 struct		IGRbsp_curve curve;
/*
 * Initialize
 */
 msg = construct_list->msg;
 *msg = MSSUCC;
 curve.knots = NULL;
 curve.poles = NULL;
 delete_abstract = FALSE;
/*
 * Get the points
 */
 if (input_points)
  {
   num_points = number_of_points;
   points = input_points;
  }
 else
  {
   IGRboolean	status;
   IGRlong	loc_msg;
   struct	GRid *id;
   struct	GRmdenv_info *mdenv_info;
   struct	IGRbsp_curve *curve;

   id = &linestring->located_obj;
   mdenv_info = &linestring->module_info.md_env;
   sts = om$send(
     msg = message GRvg.GRgenabsg(
      msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix,
      (IGRchar **) &curve),
     targetid = id->objid,
     targetos = id->osnum);
    if (! (1 & sts)) goto wrapup;
   if (curve->rational)
    {
     status = BSunwght_p(
      &loc_msg,
      curve->poles,
      curve->weights,
      &curve->num_poles,
      curve->poles);
     delete_abstract = TRUE;
    } /* if (curve->rational) */
   else if (periodic)
    delete_abstract = TRUE;
   num_points = curve->num_poles;
   points = (IGRpoint *) curve->poles;
  }
/*
 * Close the curve, if it is periodic
 */
 if (periodic)
  {
   IGRint	i;

   i = num_points - 1;
   points[i][0] = points[0][0];
   points[i][1] = points[0][1];
   points[i][2] = points[0][2];
  }
/*
 * Call the math
 */
 {
  IGRlong	count, loc_msg;

  count = num_points + order - 1;
  curve.poles = (IGRdouble *) malloc(count * sizeof(IGRpoint));
   if (!curve.poles)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  count += order;
  curve.knots = (IGRdouble *) malloc(count * sizeof(IGRdouble));
   if (!curve.knots)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  BSdirfitcv(
    num_points,
    points, 
    order, 
    beg_tangent ? 1 : 0,
    end_tangent ? 1 : 0,
    periodic, 
    (IGRdouble *)beg_tangent,
    (IGRdouble *)end_tangent,
    &curve,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Load my instance data
 */
 construct_list->geometry = (IGRchar *) &curve;
 sts = om$send(
   msg = message GRvg.GRconstruct(construct_list),
   targetid = my_id);
  if (! (1 & sts)) goto wrapup;
/*
 * End of routine
 */
wrapup:
 if (delete_abstract)
  {
 extern  IGRboolean  GRabsg_del_all();
   IGRboolean	status;

   status = GRabsg_del_all();
  }
 if (curve.knots) free(curve.knots);
 if (curve.poles) free(curve.poles);
 if (! (1 & *msg))
  {
   sts = om$send(
    msg = message Root.delete(1),
    targetid = my_id);
   return(OM_E_ABORT);
  }
 else
  return(OM_S_SUCCESS);
}

end implementation GRsubbc;
