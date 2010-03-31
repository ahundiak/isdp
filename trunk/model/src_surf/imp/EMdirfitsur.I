/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method performs a direct data fit on a set of input
 linestrings producing a surface.

 Notes

 Read the specification file for documentation.

 History

 06/18/86 : gk  : design date.
 12/23/86 : gk  : Modified to accept unequal number of points
                  in each row.
 12/16/87 : rlw : Total rewrite to kill digital data
 02/17/88 : rlw : Modified to clear surface pointer on math error
 */


class implementation EMSgenbs;

#include "EMS.h"
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "bserr.h"
#include "OMmacros.h"			/* OM_BLOCK_MOVE  stuff */

method EMdirect_fit_surface(
 IGRlong	u_order;
 IGRlong	v_order;
 IGRboolean	u_periodic;
 IGRboolean	v_periodic;
 IGRlong	number_of_linestrings;
 struct		GRlc_info linestrings[];
 struct		GRvg_construct *construct_list)

{
 IGRlong	sts, *msg, i, num_v_points, maximum_points;
 IGRlong	*points_per_linestring;
 IGRpoint	*fit_points;
 struct		IGRbsp_surface *surface;
/*
 * Initialize
 */
 msg = construct_list->msg;
 *msg = MSSUCC;
 surface = NULL;
 fit_points = NULL;
 points_per_linestring = NULL;
/*
 * Get the linestrings
 */
 sts = EFget_matrix_of_linestrings(
   my_id,
   u_periodic, 
   v_periodic,
   number_of_linestrings, 
   linestrings,
   &num_v_points,
   &maximum_points,
   &points_per_linestring,
   &fit_points,
   msg);
  if (! (1 & sts)) goto wrapup;
/*
 * Call the math
 */
 {
  extern   void		BSdirfitsf();
  IGRlong	loc_msg;

  BSdirfitsf(
    num_v_points,
    points_per_linestring,
    fit_points,
    u_order,
    v_order,
    u_periodic, 
    v_periodic, 
    &surface,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     surface = NULL;
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Load my instance data
 */
 construct_list->geometry = (IGRchar *) surface;
 sts = om$send(
   msg = message GRvg.GRconstruct(construct_list),
   targetid = my_id);
  if (! (1 & sts)) goto wrapup;
/*
 * End of routine
 */
wrapup:
 if (fit_points) free(fit_points);
 if (points_per_linestring) free(points_per_linestring);
 if (surface)
  {
 extern  IGRboolean  BSfreesf();
   IGRboolean	status;
   IGRlong	loc_msg;

   status = BSfreesf(&loc_msg, surface);
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

end implementation EMSgenbs;
