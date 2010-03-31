class implementation GRsubbc;

/*
  HISTORY

    Sudha  06/16/93     Modified for BSprototype ansification
*/

#include "EMS.h"
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "bserr.h"
#include "bsunwght_p.h"
#include "bsfreecv.h"
#include "bsfitcnvpts.h"

method EMconvex_fit_curve(
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
 struct		IGRbsp_curve *curve;
/*
 * Initialize
 */
 msg = construct_list->msg;
 *msg = MSSUCC;
 curve = NULL;
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
   num_points = curve->num_poles;
   points = (IGRpoint *) curve->poles;
  }
/*
 * Call the math
 */
 {
  IGRlong	loc_msg;

  BSfitcnvpts(
    num_points,
    points, 
    beg_tangent ? 1 : 0,
    end_tangent ? 1 : 0,
    (IGRdouble *)beg_tangent,
    (IGRdouble *)end_tangent,
    TRUE,
    NULL,
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
 construct_list->geometry = (IGRchar *) curve;
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
 if (curve) 
  {
   IGRboolean	status;
   IGRlong	loc_msg;

   status = BSfreecv(&loc_msg, curve);
  }
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
