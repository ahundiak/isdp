/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method creates a surface using the input linestrings
 as poles.

 Notes

 Read the specification file for documentation.

 History

 06/18/86 : gk  : design date.
 12/19/87 : rlw : Total rewrite to kill digital data
 06/03/88 : rlw : Flag uniform knot vectors as such
 07/14/88 : rlw : Modified to duplicate poles, as math requires, if periodic
 08/26/92 : NP  : Modified for ANSI compliance. Moved static function declaration
		  to global scope. Misc. typecasting.


 */


class implementation EMSgenbs;

#include "EMS.h"
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "bserr.h"
#include "OMmacros.h"			/* OM_BLOCK_MOVE  stuff */

%safe
static	IGRlong RLWexpand_surface_u_poles();
%endsafe

method EMsurface_by_poles(
 IGRlong	u_order;
 IGRlong	v_order;
 IGRboolean	u_periodic;
 IGRboolean	v_periodic;
 IGRlong	number_of_linestrings;
 struct		GRlc_info linestrings[];
 struct		GRvg_construct *construct_list)

{
 IGRlong	sts, *msg, i, num_v_pnts, maximum_points;
 IGRlong	*points_per_linestring;
 IGRpoint	*fit_points, *u_expanded_poles, *v_expanded_poles;
 struct		IGRbsp_surface surface;
/*
 * Initialize
 */
 msg = construct_list->msg;
 *msg = MSSUCC;
 fit_points = NULL;
 points_per_linestring = NULL;
 surface.u_knots = NULL;
 surface.v_knots = NULL;
 u_expanded_poles = NULL;
 v_expanded_poles = NULL;
/*
 * Get the linestrings
 */
 sts = EFget_matrix_of_linestrings(
   my_id,
   u_periodic, 
   v_periodic,
   number_of_linestrings, 
   linestrings,
   &num_v_pnts,
   &maximum_points,
   &points_per_linestring,
   &fit_points,
   msg);
  if (! (1 & sts)) goto wrapup;
/*
 * Initialize the surface structure
 */
 surface.u_order = u_order;
 surface.v_order = v_order;
 surface.u_periodic = u_periodic;
 surface.v_periodic = v_periodic;
 surface.u_num_poles = points_per_linestring[0];
 surface.v_num_poles = num_v_pnts;
 surface.poles = (IGRdouble *)fit_points;
 surface.u_num_knots = 0;
 surface.v_num_knots = 0;
 surface.rational = FALSE;
 surface.weights = NULL;
 surface.u_phy_closed = u_periodic;
 surface.v_phy_closed = v_periodic;
 surface.num_boundaries = 0;
 surface.bdrys = NULL;
/*
 * Pole duplication logic for periodic surfaces.
 */
 if (surface.u_periodic ||
     surface.v_periodic)
  {
   IGRlong	expanded_pole_count;

   if (surface.u_periodic)
    {
     sts = RLWexpand_surface_u_poles(
       &surface,
       &u_expanded_poles,
       &expanded_pole_count,
       msg);
      if (! (1 & sts)) goto wrapup;
     surface.poles = (IGRdouble *)u_expanded_poles;
     surface.u_num_poles = expanded_pole_count;
    } /* if (surface.u_periodic) */
   if (surface.v_periodic)
    {
     extern	IGRboolean BSexch_u_v();
     IGRboolean	status;
     IGRlong	loc_msg, new_v_num_poles, total_poles;
     IGRpoint	*tmp_poles;
     struct	IGRbsp_surface reversed_surface;

     new_v_num_poles = surface.v_num_poles + surface.v_order - 1;
     total_poles = surface.u_num_poles * new_v_num_poles;
     v_expanded_poles = (IGRpoint *) malloc(total_poles * sizeof(IGRpoint));
      if (! v_expanded_poles)
       {
        *msg = MANOMEMORY;
        goto wrapup;
       }
     reversed_surface = surface;
     reversed_surface.poles = (IGRdouble *)v_expanded_poles;
     status = BSexch_u_v(
       &loc_msg,
       &surface,
       &reversed_surface);
      if (loc_msg != BSSUCC)
       {
        *msg = MSFAIL;
        goto wrapup;
       }
     sts = RLWexpand_surface_u_poles(
       &reversed_surface,
       &tmp_poles,
       &expanded_pole_count,
       msg);
      if (! (1 & sts)) goto wrapup;
     
     reversed_surface.poles=(IGRdouble *)tmp_poles;
     reversed_surface.u_num_poles = expanded_pole_count;
     surface.poles = (IGRdouble *)v_expanded_poles;
     status = BSexch_u_v(
       &loc_msg,
       &reversed_surface,
       &surface); free(tmp_poles);
      if (loc_msg != BSSUCC)
       {
        *msg = MSFAIL;
        goto wrapup;
       }
    } /* if (surface.v_periodic) */
  }
/*
 * Fix the knots
 */
 {
  extern   void		BSchrdlskts();
  IGRlong	loc_msg;

 surface.u_num_knots = surface.u_order + surface.u_num_poles;
  surface.u_knots= (IGRdouble *)malloc(surface.u_num_knots * sizeof(IGRdouble));
   if (!surface.u_knots)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  if (surface.u_order == surface.u_num_poles)
   surface.u_non_uniform = FALSE;
  else
   surface.u_non_uniform = TRUE;
 surface.v_num_knots = surface.v_order + surface.v_num_poles;
  surface.v_knots= (IGRdouble *)malloc(surface.v_num_knots * sizeof(IGRdouble));
   if (!surface.v_knots)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  if (surface.v_order == surface.v_num_poles)
   surface.v_non_uniform = FALSE;
  else
   surface.v_non_uniform = TRUE;
  BSchrdlskts(
    surface.u_order,
    surface.v_order,
    surface.u_num_poles,
    surface.v_num_poles,
    surface.u_periodic,
    surface.v_periodic,
    surface.poles,
    surface.u_knots,
    surface.v_knots,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Fix the planar and physically closed bits
 */
 {
  extern   void		BStst_plan();
  extern void   BSsftstclsd();
  extern void   BSsfsetclsd();
  IGRlong	loc_msg, total_poles;
  IGRvector	normal_vector;

  total_poles = surface.u_num_poles * surface.v_num_poles;
  BStst_plan(
    total_poles,
    surface.poles,
    NULL,
    &surface.planar,
    normal_vector,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  if (! (surface.u_periodic && surface.v_periodic))
   {
    BSsftstclsd(
      &surface,
      &loc_msg);
     if (loc_msg != BSSUCC)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
    BSsfsetclsd(
      &surface,
      &loc_msg);
     if (loc_msg != BSSUCC)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
   } /* if (! (surface.u_periodic && surface.v_periodic)) */
 }
/*
 * Load my instance data
 */
 construct_list->geometry = (IGRchar *) &surface;
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
 if (surface.u_knots) free(surface.u_knots);
 if (surface.v_knots) free(surface.v_knots);
 if (u_expanded_poles) free(u_expanded_poles);
 if (v_expanded_poles) free(v_expanded_poles);
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
/*
 * This function expands the u poles of a surface such that
 * the math will recognize them as being periodic.
 *
 * History
 *
 * 07/14/88 : rlw : Creation date
 */
static IGRlong RLWexpand_surface_u_poles(
 surface,
 expanded_poles,
 u_num_poles,
 msg)

struct		IGRbsp_surface *surface;
IGRpoint	**expanded_poles;
IGRlong		*u_num_poles;
IGRlong		*msg;

{
 IGRpoint	*duplicate_poles;
/*
 * Initialize
 */
 *msg = MSSUCC;
 duplicate_poles = NULL;
 *expanded_poles = NULL;
 *u_num_poles = 0;
/*
 * Expand the u poles, if periodic
 */
 if (surface->u_periodic)
  {
   extern	IGRboolean MAbcupexpand();
   IGRboolean	status;
   IGRlong	total_poles, i;
   IGRpoint	*old_pole_pointer, *new_pole_pointer;

   total_poles = surface->u_num_poles + surface->u_order - 1;
   duplicate_poles = (IGRpoint *) malloc(total_poles *
     surface->v_num_poles * sizeof(IGRpoint));
    if (! duplicate_poles)
     {
      *msg = MANOMEMORY;
      goto wrapup;
     }
   old_pole_pointer = (IGRpoint *) surface->poles;
   new_pole_pointer = duplicate_poles;
   for (i = 0; i < surface->v_num_poles; i++)
    {
     status = MAbcupexpand(
       msg,
       &surface->u_order,
       &surface->rational,
       &surface->u_num_poles,
       old_pole_pointer,
       surface->weights,
       &total_poles,
       new_pole_pointer,
       NULL);
      if (! status) goto wrapup;
     old_pole_pointer += surface->u_num_poles;
     new_pole_pointer += total_poles;
    } /* for (i = 0; i < surface->v_num_poles; i++) */
  *u_num_poles = total_poles;
  *expanded_poles = duplicate_poles;
  duplicate_poles = NULL;
 } /* if (surface->u_periodic) */
/*
 * eof
 */
wrapup:
 if (duplicate_poles) free(duplicate_poles);
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}

end implementation EMSgenbs;
