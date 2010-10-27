/* $Id: EMbsIntPln.I,v 1.1 2001/01/14 19:14:23 hans Exp $ */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        emsfixes/model/EMbsIntPln.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: EMbsIntPln.I,v $
 *      Revision 1.1  2001/01/14 19:14:23  hans
 *      SP16 modifications
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/15/00        Jayadev         etl#4002 - n_int checked after
 *                                      BSpl_cv_int()
 * -------------------------------------------------------------------*/
/*
 History

 03/14/89 : DLB : Used different return code from EMoutput_point call.
 03/13/89 : rlw : Sort of reworked.
 Sudha  06/16/93     Modified for BSprototype ansification
 */
class implementation GRbspline;

#include "EMS.h"
#include "emserr.h"
#include "gocmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "madef.h"
#include "bs.h"
#include "EMSerrordef.h"
#include "bspl_cv_int.h"

method EMintplane(
 struct GRvg_construct *construct_list;
 struct IGRplane *plane;
 struct GRlc_info *located_object;
 int *number_of_intersections;
 struct GRid **results;
 int *msg)
{
 IGRlong	msg_loc, sts, i;
 IGRdouble	*int_points, *u, *a, *b;
 IGRint		n_int, n_seg;
 struct		IGRbsp_curve *curve;
 struct		GRmdenv_info *mdenv_info;
/*
 * Initialize
 */
 *msg = MSSUCC;
 *number_of_intersections = 0;
 *results = NULL;
 int_points = NULL;
 n_int = n_seg = 0;
 mdenv_info = &located_object->module_info.md_env;
/*
 * Generate abstract data
 */
 {
  IGRchar	*gen_ptr;

  GRgetabsg (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
             &gen_ptr, i);
  EMerr_hndlr (!(1 & msg_loc), *msg, MSFAIL, wrapup);

  curve = (struct IGRbsp_curve *) gen_ptr;
 }
/*
 * Allocate the memory required to perform the intersection
 */
 {
  IGRdouble	*double_ptr;

  double_ptr = (IGRdouble *) malloc(6 * curve->num_poles * sizeof(IGRdouble));
   if (! double_ptr)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  int_points = double_ptr;
  double_ptr += 3 * curve->num_poles;
  a = double_ptr;
  double_ptr += curve->num_poles;
  b = double_ptr;
  double_ptr += curve->num_poles;
  u = double_ptr;
 }
/*
 * Intersect the curve with the plane
 */
 {
  IGRboolean	status;
  IGRlong	rc;

  status = BSpl_cv_int(
    &rc,
    curve,
    plane->point,
    plane->normal,
    &n_int,
    int_points,
    u,
    &n_seg,
    a,
    b);
   if ((rc != BSSUCC) || (n_int == 0))
    {
     *msg = EMS_E_BSerror;
     goto wrapup;
    }
  *number_of_intersections = n_int + n_seg;
   if (! *number_of_intersections) goto wrapup;
  *results = (struct GRid *) malloc(
    *number_of_intersections * sizeof(struct GRid));
   if (! *results)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
 }
/*
 * Construct and display the intersected points
 */
 if (n_int)
  {
   extern	IGRlong EMoutput_point();

   sts = EMoutput_point(
     msg,
     my_id,
     construct_list,
     n_int,
     int_points,
     *results);
    *msg = MSSUCC;                  /*Added by DLB 03/14/89*/
    if (! (1 & sts)) goto wrapup;   /*Also replaced *msg with sts since
                                     * EMoutput_point returns BS codes in
                                     * the msg return code.
                                     */
  } /* if (n_int) */
/*
 * Construct and display the (possible) intersection lines
 */
 if (n_seg)
  {
   GRobjid	objid;
   GRspacenum	osnum;
   struct	GRparms u_start, u_mid, u_end;

   osnum = construct_list->env_info->md_id.osnum;
   for (i = 0; i < n_seg; i++)
    {
     u_start.u = a[i];
     u_mid.u = (a[i] + b[i]) / 2.0;
     u_end.u = b[i];
     sts = om$send(
       msg = message GRcurve.EMpartofcv(
        &msg_loc,
        &mdenv_info->matrix_type,
        mdenv_info->matrix,
        construct_list,
        &u_start,
        &u_mid,
        &u_end,
        &objid),
       targetid = my_id);
      if ((! (1 & msg_loc)) ||
          (! (1 & sts)))
       {
        *msg = MSFAIL;
        goto wrapup;
       }
     (*results)[i + n_int].objid = objid;
     (*results)[i + n_int].osnum = osnum;
    } /* for (i = 0; i < n_seg; i++) */
  } /* if (n_seg) */
/*
 * Eof
 */
wrapup:
 if (int_points) free(int_points);
 if (! (1 & *msg))
  {
   *number_of_intersections = 0;
   if (*results) free(*results);
   *results = NULL;
   return(OM_E_ABORT);
  }
 else
  return(OM_S_SUCCESS);
}

end implementation GRbspline;
