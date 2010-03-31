/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
 Description

 This routine attempts to modify parametric space data such that
 parameters lying on degenerate edges are modified such that their
 distance to the next/previous point is minimized.  In reality the
 parameter on a degenerate edge can be any value, i.e. all parameters are
 equally correct.

 Assumptions

 It is assumed that the input data does not have two consequentive
 points lying on a degenerate edge.

 Arguments

 surface		The input surface.
 par_tol		The input surface's parametric basis tolerance.
 is_degenerate		Input information which tells whether or not the
                        surfaces edges are degenerate.  Can be obtained
			by calling EFfix_classify_degenerate_edges().
 number_of_parameters   The number of input parameters.  May be changed if
			points are present.
 parameters		The input parameters.  May be changed if points
			are present.
 points			If xyz data is present then every time a point is
                        found on a degenerate edge then insert another
			point in the data such that a segment exists
			down the degenerate edge.
 msg			Returned as MSSUCC, MSFAIL, or MANOMEMORY.

 History

 rlw : 11/17/88 : Creation date
 rlw : 11/02/89 : Modified to fix the data if only 2 points are input.
 Sudha 07/09/93 : Modified for BSprototypes anisfication

 */

#include <malloc.h>		/* Defines malloc(), etc. */
#include "bs.h"			/* Type definitions */
#include "bsmemory.h"		/* BSMEMCPY() macro */
#include "msdef.h"		/* Error return codes */
#include "maerr.h"		/* Error return codes */
#include "bsptlnplan.h"
#include "bsfreesf.h"
#include "bsexch_u_v.h"
#include "bsblkmv.h"
#include "bsallocsf.h"

void EFfix_uv_on_degenerate_edges(
 surface,
 par_tol,
 is_degenerate,
 number_of_parameters,
 parameters,
 points,
 msg)

struct		IGRbsp_surface *surface;
IGRdouble	par_tol;
IGRboolean	is_degenerate[2][2];
IGRlong		*number_of_parameters;
BSpair		**parameters;
IGRpoint	**points;
IGRlong		*msg;

{
/*
 * Initialize
 */
 *msg = MSSUCC;
/*
 * This stuff only works if at least 2 points are present and
 * something is degenerate.
 */
 if ((*number_of_parameters < 2) ||
     (! (is_degenerate[0][0] ||
         is_degenerate[0][1] ||
         is_degenerate[1][0] ||
         is_degenerate[1][1])))
  goto wrapup;
/*
 * The natural edges are classified as follows:
 *
 * is_degenerate[0][0] implies u = 0
 * is_degenerate[0][1] implies u = 1
 * is_degenerate[1][0] implies v = 0
 * is_degenerate[1][1] implies v = 1
 */
 {
  IGRlong	i, degenerate_code;
  IGRdouble	u_low, u_hig, v_low, v_hig, *uv, *next_uv;

  u_low = surface->u_knots[surface->u_order - 1];
  u_hig = surface->u_knots[surface->u_num_poles];
  v_low = surface->v_knots[surface->v_order - 1];
  v_hig = surface->v_knots[surface->v_num_poles];
  for (i = 0; i < *number_of_parameters; i++)
   {
    uv = &(*parameters)[i][0];
    if (i)
     next_uv = &(*parameters)[i - 1][0];
    else
     next_uv = &(*parameters)[1][0];
    if ( (((uv[0] - u_low) < par_tol) && is_degenerate[1][0]) ||
         (((u_hig - uv[0]) < par_tol) && is_degenerate[1][1]) )
     {
      degenerate_code = 1;
      uv[1] = next_uv[1];
     }
    else if ( (((uv[1] - v_low) < par_tol) && is_degenerate[0][0]) ||
              (((v_hig - uv[1]) < par_tol) && is_degenerate[0][1]) )
     {
      degenerate_code = 2;
      uv[0] = next_uv[0];
     }
    else
     degenerate_code = 0;
    if (degenerate_code &&
        *points &&
        i &&
        (i != (*number_of_parameters - 1)))
     {
      IGRlong		num_pnts_to_move;
      IGRdouble		*xyz, *next_xyz, *previous_xyz;

      i++;				/* Skip the addition point */
      (*number_of_parameters)++;	/* One more point in the data */
      *parameters = (BSpair *) realloc(
        *parameters,
        *number_of_parameters * sizeof(BSpair));
       if (! *parameters)
        {
         *number_of_parameters = 0;
         *msg = MANOMEMORY;
         goto wrapup;
        }
      *points = (IGRpoint *) realloc(
        *points,
        *number_of_parameters * sizeof(IGRpoint));
       if (! *points)
        {
         *number_of_parameters = 0;
         *msg = MANOMEMORY;
         goto wrapup;
        }
      num_pnts_to_move = *number_of_parameters - i - 1;
      xyz = &(*points)[i][0];
      next_xyz = &(*points)[i + 1][0];
      previous_xyz = &(*points)[i - 1][0];
      BSMEMCPY(
       num_pnts_to_move * sizeof(IGRpoint),
       (IGRchar *)xyz,
       (IGRchar *)next_xyz);
      xyz[0] = previous_xyz[0];		/* Same point in model space */
      xyz[1] = previous_xyz[1];
      xyz[2] = previous_xyz[2];
      uv = &(*parameters)[i][0];
      next_uv = &(*parameters)[i + 1][0];
      BSMEMCPY(
       num_pnts_to_move * sizeof(BSpair),
       (IGRchar *)uv,
       (IGRchar *)next_uv);
      if (degenerate_code == 1)
       {
        uv[0] = (*parameters)[i - 1][0];
        uv[1] = next_uv[1];
       }
      else
       {
        uv[0] = next_uv[0];
        uv[1] = (*parameters)[i - 1][1];
       }
     } /* if (degenerate_code && ...) */
   } /* for (i = 0; i < *number_of_parameters; i++) */
 }
/*
 * Eof
 */
wrapup:
 return;
}

/*
 Description

 This routine classifies each of the four natural edges as either
 degenerate in model space or not.

 Arguments

 surface		The surface to be classified.
 is_degnerate		If TRUE then edge is degenerate.
			[0][0] implies edge for v = 0
			[0][1] implies edge for v = 1
			[1][0] implies edge for u = 0
			[1][1] implies edge for u = 1
 msg			MSSUCC     - No problems
			MSFAIL     - Math probably failed
			MANOMEMORY - No memory

 History

 11/17/88 : rlw : Creation date

 */
void EFclassify_degenerate_edges(
 surface,
 is_degenerate,
 msg)

struct		IGRbsp_surface *surface;
IGRboolean	is_degenerate[2][2];
IGRlong		*msg;

{
 struct		IGRbsp_surface *surfaces[2];
/*
 * Initialize
 */
 *msg = MSSUCC;
 surfaces[0] = surface;
 surfaces[1] = NULL;
/*
 * Generate a surface in which the u and v directions are flipped.
 * This is done so that we can extract the u = 0 and u = 1 poles
 * by going down memory lane.
 */
 {
  IGRboolean	status;
  IGRlong	loc_msg;
  struct	IGRbsp_surface *flipped_surface;

  BSallocsf(			/* Note that u and v must be swapped */
    surface->v_order,
    surface->u_order,
    surface->v_num_poles,
    surface->u_num_poles,
    surface->rational,
    0,				/* No boundaries */
    &flipped_surface,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  surfaces[1] = flipped_surface;
  status = BSexch_u_v(
    &loc_msg,
    surface,
    flipped_surface);
   if (loc_msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Classify the edges corresponding to v = 0, v = 1, u = 0, u = 1.
 * If the surface is physically closed then we only need
 * to classify one of the edges as the other must be the same.
 */
 {
  IGRlong	i, j, index[2], loc_msg, loop;
  IGRint	planar_code;
  IGRvector	normal_vector;
  struct	IGRbsp_surface *sf;

  index[0] = 0;
  for (i = 0; i < 2; i++)
   {
    sf = surfaces[i];
    if (sf->v_phy_closed)
     loop = 1;
    else
     {
      loop = 2;
      index[1] = 3 * sf->u_num_poles * (sf->v_num_poles - 1); 
     }
    for (j = 0; j < loop; j++)
     {
      BSptlnplan(
        sf->u_num_poles,
        sf->rational,
        (IGRpoint *)&sf->poles[index[j]],
        sf->weights,
        &planar_code,
        normal_vector,
        &loc_msg);
       if (loc_msg != BSSUCC)
        {
         *msg = MSFAIL;
         goto wrapup;
        }
      is_degenerate[i][j] = (planar_code == 1);
     } /* for (j = 0; j < loop; j++) */
    if (sf->v_phy_closed)
     is_degenerate[i][1] = is_degenerate[i][0];
   } /* for (i = 0; i < 2; i++) */
 }
/*
 * Eof
 */
wrapup:
 if (surfaces[1])
  {
   IGRboolean	status;
   IGRlong	loc_msg;

   status = BSfreesf(
    &loc_msg,
    surfaces[1]);
  } /* if (surfaces[1]) */
 return;
}
