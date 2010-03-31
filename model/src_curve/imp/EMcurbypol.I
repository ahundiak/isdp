class implementation GRsubbc;

#include "EMS.h"
/*
 History

 02/24/88 : rlw : Modified to not set non-uniform bit if bezier.
 07/14/88 : rlw : Modified to duplicate poles, as math requires, if periodic
 Sudha  06/16/93     Modified for BSprototype ansification
 */

#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "mabcupexp.h"
#include "bserr.h"
#include "bsunwght_p.h"
#include "bschrdlkts.h"

method EMcurve_by_poles(
 IGRlong	order;
 IGRboolean	periodic;
 IGRlong	number_of_points;
 IGRpoint	*input_points;
 struct		GRlc_info *linestring;
 struct		GRvg_construct *construct_list)

{
 IGRboolean	delete_abstract;
 IGRlong	sts, *msg, num_points;
 IGRpoint	*points, *duplicate_poles;
 struct		IGRbsp_curve curve;
/*
 * Initialize
 */
 msg = construct_list->msg;
 *msg = MSSUCC;
 curve.knots = NULL;
 delete_abstract = FALSE;
 duplicate_poles = NULL;
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
 * We have the points, setup the knot vector
 * and other fields of the curve
 */
 curve.order = order;
 curve.periodic = periodic;
 curve.num_poles = num_points;
 curve.poles = (double *) points;
 curve.rational = FALSE;
 curve.weights = NULL;
 curve.num_boundaries = 0;
 curve.bdrys = NULL;
/*
 * Pole duplication logic for periodic curves.
 */
 if (periodic)
  {
   IGRboolean	status;
   IGRlong	total_poles;

   total_poles = curve.num_poles + curve.order - 1;
   duplicate_poles = (IGRpoint *) malloc(total_poles * sizeof(IGRpoint));
    if (! duplicate_poles)
     {
      *msg = MANOMEMORY;
      goto wrapup;
     }
   status = MAbcupexpand(
     msg,
     &curve.order,
     &curve.rational,
     &curve.num_poles,
     (IGRpoint *)curve.poles,
     curve.weights,
     &total_poles,
     duplicate_poles,
     NULL);
    if (! status) goto wrapup;
   curve.num_poles = total_poles;
   curve.poles = (double *) duplicate_poles;
  }
/*
 * Fix the knots
 */
 {
  IGRboolean	status;
  IGRlong	loc_msg;

  curve.num_knots = curve.order + curve.num_poles;
  curve.knots = (double *) malloc(curve.num_knots * sizeof(IGRdouble));
   if (!curve.knots)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  if (curve.order == curve.num_poles)	/* Bezier? */
   curve.non_uniform = FALSE;
  else
   curve.non_uniform = TRUE;
  status = BSchrdlkts(
    &loc_msg,
    &curve.num_poles,
    curve.poles,
    &curve.order,
    &curve.periodic,
    curve.knots);
   if (!status)
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
 if (duplicate_poles) free(duplicate_poles);
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
