
#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include <math.h>

#include "bs.h"
#include "bsparameters.h"

#include "vedef.h"
#include "ve.h"
#include "veerr.h"



#ifdef	PARTIAL_TOL
#undef	PARTIAL_TOL
#endif
#ifdef	PARAM_TOL
#undef	PARAM_TOL
#endif
#ifdef	PARALLEL_TOL
#undef	PARALLEL_TOL
#endif

#define DEBUG_FIND_TRANS	0
#define DEBUG_OVERLAP		0
#define PARAM_TOL		0.0001
#define PARTIAL_TOL		0.00000001
#define PARALLEL_TOL		0.99


/**********************
 * EXTERNAL FUNCTIONS *
 **********************/

void			VEmerge_visibs ();
void			VEinsert_temp_node ();
void			VEfree_temp_node ();
struct VEtemp_node	*VEalloc_temp_node ();
void			BSxtractpar ();
void                    BScvkttol2();
void			BScveval ();
void			VEcvcv_int_3d ();

void			VEget_unweighted_pole_storage();
IGRboolean 		BSadd_ktr();



/***********************
 * EXTERNALL VARIABLES *
 ***********************/

extern IGRboolean	VEperspective;


/*******************
 * LOCAL VARIABLES *
 *******************/

static IGRdouble            line_knots[4] = {0.0, 0.0, 1.0, 1.0};
static IGRdouble            line_poles[6];
static IGRdouble            global_cht;
static IGRdouble            min_param, max_param;
static IGRdouble	    global_knot_tol;

static struct IGRbsp_curve global_line = { 2,                /* order                 */
	                                   FALSE, FALSE,     /* periodic, non-uniform */
	                                   2, line_poles,    /* num_poles, poles      */
	                                   4, line_knots,    /* num_knots, knots      */
	                                   FALSE, NULL,      /* ratinal, weights      */
	                                   FALSE, FALSE,     /* planar, phy_closed    */
	                                   0, NULL };        /* num_boudnaries, bdrys */

static struct IGRbsp_curve  *global_curve;




/*-- VEget_exact_transition_pt -----------------------------------------*/

static IGRboolean	VEget_exact_transition_pt (curve, trans_index, param, x, y, z)

struct IGRbsp_curve	*curve;
IGRint			trans_index;
IGRdouble		*param, *x, *y, *z;

/*
 * Given the index of a pole where a potential transition point may be,
 * this routine will iterate to find the exact parameter and XYZ coordianetes
 * of the transition point.
 *
 * HISTORY: 09/02/87 Created.				S. A. Rapa
 */

   {
   BSrc		rc;
   IGRint	cntr;
   IGRpoint	test_point[3];
   IGRdouble	next_param,
		dxdu, dydu,
		abs_last_dxdu, abs_last_dydu;

#if DEBUG_FIND_TRANS
fprintf (stderr, "   Possible transition near pole # %d\n", trans_index);
#endif

   /*
    * Possible start of overlap region found ... get node value
    * for pole at "trans_index" as first guess of iteration to
    * find solution.
    */

   *param = curve->knots[trans_index + 1];
   for (cntr = trans_index + 2; cntr < trans_index + curve->order; cntr++)
      *param += curve->knots[cntr];
   *param /= (IGRdouble) (curve->order - 1);

   /*
    * If our transition pole is at a sharp point on the curve
    * (i.e. the node value equals any knot used to compute
    * the node since they're all identical), then the middle
    * pole is the exact transition point.
    */

   if (fabs (*param - curve->knots[trans_index + 1]) < PARTIAL_TOL)
      {
      *x = curve->poles[(3 * trans_index)];
      *y = curve->poles[(3 * trans_index) + 1];
      *z = curve->poles[(3 * trans_index) + 2];

#if DEBUG_FIND_TRANS
fprintf (stderr, "   Sharp point: x, y, z = %13.7lf, %13.7lf, %13.7lf\n", *x, *y, *z);
fprintf (stderr, "                param   = %12.10lf\n", *param);
#endif

      return (TRUE);
      }

   /*
    * Iterate to find point where dx/du = 0 and dy/du = 0.
    */

   abs_last_dxdu = 1.0E50;
   abs_last_dydu = 1.0E50;

   for (cntr = 0; cntr < 13; cntr++)
      {
      BScveval (curve, *param, 2, test_point[0], &rc);
      if (rc != BSSUCC)
         {
	 fprintf (stderr, "VEself_ovlp: Error in BScveval # %d.\n", rc);
         return (FALSE);
         }

#if DEBUG_FIND_TRANS
fprintf (stderr, "   Iteration point: x, y, z = %13.7lf, %13.7lf, %13.7lf\n",
		test_point[0][0], test_point[0][1], test_point[0][2]);
fprintf (stderr, "                    param   = %12.10lf\n", *param);
fprintf (stderr, "                    x', x'' = %13.7lf, %13.7lf\n",
		test_point[1][0], test_point[2][0]);
fprintf (stderr, "                    y', y'' = %13.7lf, %13.7lf\n",
		test_point[1][1], test_point[2][1]);
#endif

      dxdu = test_point[1][0];
      dydu = test_point[1][1];

      /* 
       * Have we found the transition point?
       */

      if ((fabs (dxdu) < PARTIAL_TOL) &&
          (fabs (dydu) < PARTIAL_TOL)   )
         {
#if DEBUG_FIND_TRANS
fprintf (stderr, "   Iteration complete.\n");
#endif

         *x = test_point[0][0];
         *y = test_point[0][1];
         *z = test_point[0][2];
         return (TRUE);
         }

      /* 
       * Are dx/du and dy/du BOTH decreasing?
       */

      if ((fabs (dxdu) > (abs_last_dxdu + PARTIAL_TOL)) ||
          (fabs (dydu) > (abs_last_dydu + PARTIAL_TOL))   )
         {
         return (FALSE);
         }

      /*
       * Get next iteration point
       */

      if (fabs (test_point[2][0]) > PARTIAL_TOL)
         next_param = *param - (dxdu / test_point[2][0]);
      else if (fabs (test_point[2][1]) > PARTIAL_TOL)
         next_param = *param - (dydu / test_point[2][1]);
      else
         {
         return (FALSE);
	 }

      /*
       * With non-uniform curves and/or ones with order > 3, the
       * second derrivative may not be constant, even over small
       * regions. Thus, "next_param"  may be outside 
       * of the curve's knot vector.  Check for this & correct.
       */

      if (next_param > max_param)
         *param = (*param + max_param) * 0.5;
      else if (next_param < min_param)
         *param = (*param + min_param) * 0.5;
      else
         *param = next_param;

      abs_last_dxdu = fabs (dxdu);
      abs_last_dydu = fabs (dydu);
      } /* for (cntr = 0; cntr < 13; cntr++) */

   return (FALSE);				/* iteration limit exceeded */
   }


/*-- VEvectors_are_parallel --------------------------------------------*/

static IGRboolean	VEvectors_are_parallel (v1_x, v1_y, v2_x, v2_y)

/*
 * Given two vectors in XY space, this routine will determine if they are
 * parallel (i.e. their dot product is greater than PARALLEL_TOL).
 *
 * HISTORY: 09/02/87 Created.				S. A. Rapa
 */

IGRdouble	v1_x, v1_y, v2_x, v2_y;

   {
   IGRdouble	len, dot;

   /* 
    * Normalize vectors; input vectors must have non-zero length
    */

   len = sqrt ((v1_x * v1_x) + (v1_y * v1_y));
   v1_x /= len;
   v1_y /= len;

   len = sqrt ((v2_x * v2_x) + (v2_y * v2_y));
   v2_x /= len;
   v2_y /= len;

   /*
    * Dot them
    */

   dot = (v1_x * v2_x) + (v1_y * v2_y);

#if DEBUG_FIND_TRANS
fprintf (stderr, "                dot     = %12.10lf\n", dot);
#endif

   if (dot < PARALLEL_TOL)
      return (FALSE);
   else
      return (TRUE);
   }


/*-- VEfind_next_visib_trans_region ------------------------------------*/

static void	VEfind_next_visib_trans_region (curve, is_start,
						param1, param2,
						x, y, z,
						is_transition,
						is_along_line_of_sight)

struct
   IGRbsp_curve	*curve;
IGRboolean	is_start;
IGRdouble	*param1, *param2, *x, *y, *z;
IGRboolean	*is_transition, *is_along_line_of_sight;

/*
 * Finds the first parameter of a point on the curve at which dx/du and
 * dy/du are zero (may indicate a possible visibility transition).
 * Searching for such a point begins from wherever the last one was found, 
 * unless this is the first call for a given curve ("is_start" == TRUE).
 * If "is_along_line_of_sight" is returned as TRUE, then two points are
 * returned, representing a span of the curve which is along the line of
 * sight (and therefore invisible).  In addition, such a span may also be
 * at a place where the curve doubles back on itself; if so, "is_transition"
 * will be TRUE.  "z" always corresponds to "param1".
 *
 * HISTORY: 09/01/87 Created.				S. A. Rapa
 */

 {
   static IGRdouble *pole_ptr,
		    *w_ptr,
		    x2, y2, z2,
		    last_x, last_y,
		    this_x, this_y,
		    next_x, next_y;
   static IGRint    trans_index, next_index;

   IGRdouble	v1_x, v1_y, v2_x, v2_y;
   IGRboolean	t1_found, t2_found,
		next_point_found, pole_skipped;

#if DEBUG_FIND_TRANS
fprintf (stderr, "\nLooking for transition pt, is_start = %d.\n", is_start);
#endif

   *is_along_line_of_sight = FALSE;
   *is_transition	   = FALSE;

   if (is_start)
      {
      pole_ptr = curve->poles;
      this_x = pole_ptr[0];
      this_y = pole_ptr[1];
      if (curve->rational)
         {
         w_ptr = curve->weights;
         this_x /= *w_ptr;
         this_y /= *w_ptr;
         }

      next_index = 0;
      while (next_index < (curve->num_poles - 1))
         {
         next_index++;
         pole_ptr += 3;
         next_x = pole_ptr[0];
         next_y = pole_ptr[1];
         if (curve->rational)
            {
            w_ptr++;
            next_x /= *w_ptr;
            next_y /= *w_ptr;
            }

         if ((fabs (next_x - this_x) > global_cht) ||
             (fabs (next_y - this_y) > global_cht)   )
            break;
         }

      /*
       * If "trans" and "next" are not adjacent, check to see if this is a section
       * of the curve which is moving directly to or from the viewer.
       */

      if (next_index != 1)
         {
         t1_found = VEget_exact_transition_pt
				(curve, 0,		  param1, x, y, z);
         t2_found = VEget_exact_transition_pt
				(curve, (next_index - 1), param2, &x2, &y2, &z2);
         if ((t1_found) && (t2_found))
	    if (fabs (*param1 - *param2) > PARAM_TOL)
	       {
	       *is_along_line_of_sight = TRUE;
	       return;
	       }
	 }
      }

   while ((*is_along_line_of_sight == FALSE) &&
   	  (*is_transition == FALSE)	     &&
	  (next_index < (curve->num_poles - 1)))
      {
      /*
       * Start testing at node corresponding to pole defining a local transition.
       * Identify transition regions as set of distinct poles which "doubles-back"
       * on itself.
       */

      trans_index = next_index;
      last_x = this_x;
      last_y = this_y;
      this_x = next_x;
      this_y = next_y;

      /*
       * Get next unique point in XY space (within tolerance)
       */

      next_point_found = FALSE;
      pole_skipped = FALSE;
      while (next_index < (curve->num_poles - 1))
         {
         next_index++;
         pole_ptr += 3;
         next_x = pole_ptr[0];
         next_y = pole_ptr[1];
         if (curve->rational)
            {
            w_ptr++;
            next_x /= *w_ptr;
            next_y /= *w_ptr;
            }

         if ((fabs (next_x - this_x) > global_cht) ||
             (fabs (next_y - this_y) > global_cht)   )
            {
            next_point_found = TRUE;
            break;
            }

	 pole_skipped = TRUE;
         }

      /*
       * If "trans" and "next" are not adjacent, check to see if this is a section
       * of the curve which is moving directly to or from the viewer.
       */

      if (pole_skipped)
         {
         if (next_point_found == FALSE)
            next_index++;
         t1_found = VEget_exact_transition_pt
				(curve, trans_index,      param1, x, y, z);
         t2_found = VEget_exact_transition_pt
				(curve, (next_index - 1), param2, &x2, &y2, &z2);
         if ((t1_found) && (t2_found))
	    if (fabs (*param1 - *param2) > PARAM_TOL)
	       *is_along_line_of_sight = TRUE;
	 }

      /*
       * Now see if the curve "doubles back" on itself
       */

      if (next_point_found)
         if ((((this_x >= last_x - global_cht) && (this_x >= next_x - global_cht)) ||
	      ((this_x <= last_x + global_cht) && (this_x <= next_x + global_cht))   )
						&&
	     (((this_y >= last_y - global_cht) && (this_y >= next_y - global_cht)) ||
	      ((this_y <= last_y + global_cht) && (this_y <= next_y + global_cht))   ))
 	    {
	    /*
	     * Make sure poles are collinear in XY space
	     */

	    v1_x = this_x - last_x;
	    v1_y = this_y - last_y;
	    v2_x = this_x - next_x;
	    v2_y = this_y - next_y;

	    if (VEvectors_are_parallel (v1_x, v1_y, v2_x, v2_y))
	       {
	       if (*is_along_line_of_sight == FALSE)
		  *is_transition = VEget_exact_transition_pt
					(curve, trans_index, param1, x, y, z);
	       else
		  *is_transition = TRUE;
 	       }
 	    }
      }/* while no points found yet */
   } /* VEfind_next_visib_trans_region */


/*-- VEprocess_trans_pt ----------------------------------------*/

static void	VEprocess_trans_pt (edge,
				    trans_param, last_trans, next_trans,
				    trans_x, trans_y, trans_z)

struct VEedge_header	*edge;
IGRdouble		trans_param, last_trans, next_trans,
			trans_x, trans_y, trans_z;

/*
 * Given a transition point on an edge, project it along the line of sight
 * and note where the projection intersects the curve.  If it intersects at 
 * a point nearer than the transition point, then the transition is
 * invisible and nothing is done.  Otherwise the transition and the next
 * furthest intersection (if it exists) are put on the temp-node list
 * for the edge.  If intersections exist with the same z as the transition
 * point, they are all added to the temp-list & the next furthest intersection
 * is ignored.
 *
 * HISTORY: 09/01/87 Created				S. A. Rapa
 */

   {
   BSrc			rc;
   IGRint		num_int, num_over,
			index;
   IGRdouble		int_param, int_z, this_z,
			*cv_par, *cv_over,
			*ln_par, *ln_over;
   IGRpoint		*int_pts, *end_pts;
   IGRboolean		same_z_int_exists, far_z_int_exists,
			free_ints, free_overs;

   /*
    * Compute projection line coordinates from transition point.
    */

   line_poles[0] = trans_x;
   line_poles[1] = trans_y;
   line_poles[3] = trans_x;
   line_poles[4] = trans_y;

#if DEBUG_OVERLAP
fprintf (stderr, "\nTransition pt: params  = %12.10lf, %12.10lf, %12.10lf\n",
					last_trans, trans_param, next_trans  );
fprintf (stderr, "                   x, y, z = %13.7lf, %13.7lf, %13.7lf\n",
			trans_x, trans_y, trans_z);
#endif

   /*
    * Project transition point onto curve
    */

   VEcvcv_int_3d (&rc,			/* BSSUCC or BSNOMEMORY              */
                  &global_line,		/* curves to be intersected          */
                  global_curve,
                  &num_int,		/* number of intersections           */
                  &int_pts,		/* cartesian values of intersections */
                  &ln_par, &cv_par,	/* u-values of the intersections     */
                  &num_over,		/* number of overlap regions         */
                  &end_pts,		/* overlap endpoints in xyz-space    */
                  &ln_over, &cv_over,	/* overlap endpoints in u            */
                  &free_ints,
                  &free_overs);
   if (rc != BSSUCC)
      {
      fprintf (stderr, "VEself_overlap: error in BScvcvint # %d\n", rc);
      goto end_process_trans_pt;
      }

   /*
    * If the transition point is obscured by another part of the curve,
    * don't add it to the "temp list".
    */

   for (index = 0; index < num_int; index++)
      if (int_pts[index][2] < (trans_z - global_cht))
         if ((cv_par[index] < last_trans) || (cv_par[index] > next_trans))
	    {
#if DEBUG_OVERLAP
fprintf (stderr, "Transition point is invisible.\n");
#endif

	    goto end_process_trans_pt;
	    }

   /*
    * If same-Z intersections exist, add all of them to the "temp list".
    * Otherwise just add the one intersection closest to the viewer.
    * Also add the transition point.
    */

   VEinsert_temp_node (trans_param, edge, global_knot_tol);

   int_z = 1.0E50;
   same_z_int_exists = FALSE;
   far_z_int_exists  = FALSE;

   for (index = 0; index < num_int; index++)
      {
      this_z = int_pts[index][2];

#if DEBUG_OVERLAP
fprintf (stderr, "Intersection param, z   = %12.10lf, %13.7lf\n", cv_par[index], this_z);
#endif

      if ((cv_par[index] < last_trans) ||
          (cv_par[index] > next_trans)   )			/* not the transition pt */
         {
         if (this_z < (trans_z + global_cht))			/* same-z intersection   */
            {
#if DEBUG_OVERLAP
fprintf (stderr, "   Same Z intersection at %12.10lf.\n", cv_par[index]);
#endif

	    VEinsert_temp_node (cv_par[index], edge, global_knot_tol);
	    same_z_int_exists = TRUE;
	    }
         else							/* far-z intersection	*/
            if (this_z < int_z)
               {
               int_z = this_z;
               int_param = cv_par[index];
	       far_z_int_exists = TRUE;
               }
	 } /* if not the transition pt */
      } /* for (index = 0; index < num_int; index++) */

   if ((same_z_int_exists == FALSE) &&
       (far_z_int_exists == TRUE)     )
      {
#if DEBUG_OVERLAP
fprintf (stderr, "   Different Z intersection at %12.10lf.\n", int_param);
#endif

      VEinsert_temp_node (int_param, edge, global_knot_tol);
      }

end_process_trans_pt:
   if ((int_pts) && (free_ints))
      {
      free((char *) int_pts);
      free((char *) ln_par);
      free((char *) cv_par);
      }
   if ((end_pts) && (free_overs))
      {
      free((char *) end_pts);
      free((char *) ln_over);
      free((char *) cv_over);
      }
   } /* VEprocess_trans_pt */


/*--- VEmake_span_hidden ---------------------------------------*/

static void	VEmake_span_hidden (parm, node_list, visible_parm)

IGRdouble		parm, visible_parm;
struct VEtemp_node	*node_list;

/*
 * Set the visibility of a temp_node span which contains "parm" ONLY IF
 *    1) "visible_parm" is NOT in that span (see comment below), AND
 *    2) "parm" is NOT within "knot_tol" of a node.
 *
 * HISTORY: 09/01/87 Created				S. A. Rapa
 */

   {
   struct VEtemp_node	*prev_node, *this_node;

   prev_node = node_list;
   this_node = prev_node->next;

   /*
    * Change visibility only if parameter is within a span
    * (i.e it doesn't count if "parm" is on a node)
    */

   while (this_node != NULL)
      {
      if (((prev_node->u + global_knot_tol) < parm) &&
          ((this_node->u - global_knot_tol) > parm)   )
         {
	 /*
	  * Sometimes BScvcvint returns multiple intersections for what
	  * should really be a single point.  This will cause a problem
	  * if it happens within the topmost (visible) span because
	  * we'll accidentally mark it as invisible.  Correct this
	  * by not processing ANY intersections with a span which
	  * contains a known visible point (i.e the topmost span, identified
	  * by "visible_parm") since, theoretically, there can only be one
	  * intersection per span.
	  */

         if ((prev_node->u > visible_parm) ||
             (this_node->u < visible_parm)   )
            {
#if DEBUG_OVERLAP
fprintf (stderr, "   Overlap region at parameter = %12.10lf\n", parm);
#endif

	    this_node->prev_visib = OVERLAPPED;
	    prev_node->next_visib = OVERLAPPED;
	    }

	 break;
	 }

      else
	 {
	 prev_node = this_node;
	 this_node = prev_node->next;
	 }
      } /* while */
   } /* VEmake_span_hidden */


/*--- VEdetermine_visibilities ---------------------------------*/

static void	VEdetermine_visibilities (node_list)

struct VEtemp_node	*node_list;

   /*
    * Does a series of point projections (curve-curve intersections) to find
    * out which parts of the curve are visible.  Note that a single projection
    * will set all spans but the nearest which contain intersection points
    * to OVERLAPPED; this cuts down on the number of projections needed vs.
    * doing one projection per span.
    * 
    * HISTORY: 09/01/87 Created					S. A. Rapa
    */

   {
   BSrc			rc;
   struct VEtemp_node	*prev_node, *this_node;
   IGRdouble		project_param,
			low_z, low_parm,
			*cv_par, *cv_over,
			*ln_par, *ln_over;
   IGRpoint		*int_pts, *end_pts,
			project_pt;
   IGRint		low_index, index,
			num_int, num_over;
   IGRboolean		free_ints, free_overs;

#if DEBUG_OVERLAP
fprintf (stderr, "\nSetting overlap spans ...\n");
#endif

   prev_node = node_list;
   this_node = prev_node->next;
   while (this_node != NULL)
      {
      if (prev_node->next_visib != OVERLAPPED)
	 {
	 prev_node->next_visib = VISIBLE;
	 this_node->prev_visib = VISIBLE;

	 project_param = (prev_node->u + this_node->u) * 0.5;
	 BScveval (global_curve, project_param, 0, project_pt, &rc);

#if DEBUG_OVERLAP
fprintf (stderr, "Projecting from %18.16lf\n", project_param);
#endif

	 /*
	  * Compute projection line coordinates
	  */

	 line_poles[0] = project_pt[0];
	 line_poles[1] = project_pt[1];
	 line_poles[3] = project_pt[0];
	 line_poles[4] = project_pt[1];

	 VEcvcv_int_3d (&rc,			/* BSSUCC or BSNOMEMORY              */
	                &global_line,		/* curves to be intersected          */
	                global_curve,
	                &num_int,		/* number of intersections           */
	                &int_pts,		/* cartesian values of intersections */
	                &ln_par, &cv_par,	/* u-values of the intersections     */
	                &num_over,		/* number of overlap regions         */
	                &end_pts,		/* overlap endpoints in xyz-space    */
	                &ln_over, &cv_over,	/* overlap endpoints in u            */
	                &free_ints,
	                &free_overs);
	 if (rc != BSSUCC)
	    fprintf (stderr, "VEself_overlap: error in BScvcvint # %d\n", rc);

	 /*
	  * Locate the intersection with the nearest Z ... this
	  * will be ignored later when setting overlaps.
	  */

	 low_z = int_pts[0][2];
	 low_index = 0;
	 low_parm = cv_par[0];
         for (index = 1; index < num_int; index++)
            if (low_z > int_pts[index][2])
	       {
	       low_z = int_pts[index][2];
	       low_index = index;
	       low_parm = cv_par[index];
	       }

	 /*
	  * Now process intersections & set overlap regions
	  */

         for (index = 0; index < num_int; index++)
            if (index != low_index)
	       VEmake_span_hidden (cv_par[index], node_list, low_parm);

	 /*
	  * Free memory used by BScvcvint
	  */

	 if ((int_pts) && (free_ints))
	    {
	    free((char *) int_pts);
	    free((char *) ln_par);
	    free((char *) cv_par);
	    }
	 if ((end_pts) && (free_overs))
	    {
	    free((char *) end_pts);
	    free((char *) ln_over);
	    free((char *) cv_over);
	    }
	 }

      prev_node = this_node;
      this_node = prev_node->next;
      }

   /*
    * Clean up temp list by removing unnecessary nodes.
    */

   prev_node = node_list;
   this_node = prev_node->next;
   while (this_node->next != NULL)
      if (this_node->prev_visib == this_node->next_visib)
         {
	 prev_node->next = this_node->next;
	 VEfree_temp_node (this_node);
	 this_node = prev_node->next;
	 }
      else
	 {
	 prev_node = this_node;
	 this_node = this_node->next;
	 }

   }


/*-- VEcalculate_self_overlaps ---------------------------------------*/

void VEcalculate_self_overlaps( edge, changes_made, elem_range )

	struct VEedge_header *edge;
	IGRboolean           *changes_made;
	IGRdouble            *elem_range;

/*
 * Set all parts of an edge which are invisible because they are
 * 1) behind another part of the curve, or 2) are long the line
 * of sight to OVERLAPPED.
 *
 * HISTORY: 09/01/87 Created				S. A. Rapa
 */

   {
   BSrc			rc;
   IGRboolean		is_transition, is_along_line_of_sight,
			next_pt_is_transition, next_pt_is_along_line_of_sight;
   IGRdouble		trans_param1, trans_param2,
			next_param1, next_param2,
			last_param1, first_param1,
			trans_x, trans_y, trans_z,
			next_x, next_y, next_z,
			dist_tol, default_dist_tol;
   IGRpoint		test_pt;

   if (VEperspective) return;

   *changes_made = FALSE;

   BSxtractpar (&rc, BSTOLCHRDHT, &global_cht);
   BSxtractpar (&rc, BSTOLLENVEC, &default_dist_tol);

   /*
    * Initialize the projection line structure
    */

   line_poles[2] = elem_range[2];
   line_poles[5] = elem_range[5];

   global_curve = edge->curve;
   min_param = global_curve->knots[global_curve->order - 1];
   max_param = global_curve->knots[global_curve->num_knots - global_curve->order];

   /*
    * Set up tolerance for doing curve intersections
    */

   if ( (edge->type == PARTING) || (edge->type == BOUNDARY) )
      dist_tol = edge->stroke_tol;			/* curve's stroking tol */
   else
      dist_tol = global_cht;
 
   BSchangepar(&rc, BSTOLLENVEC,   dist_tol );
   BSchangepar(&rc, BSTOLSQLENVEC, dist_tol * dist_tol );

   /*
    * Determine the knot tolerance for this edge 
    */

    BScvkttol2( global_curve->order, global_curve->knots,
                global_curve->num_poles, global_curve->poles,
                global_curve->weights, &global_knot_tol, &rc );
                

   /*
    * Are there any transition points for this curve?
    */

   VEfind_next_visib_trans_region( global_curve, TRUE,
  	  	                   &trans_param1, &trans_param2,
				   &trans_x, &trans_y, &trans_z,
				   &is_transition,
				   &is_along_line_of_sight );

   if ( (is_transition) || (is_along_line_of_sight) )
      {
      *changes_made = TRUE;

      /*
       * Initialize temp node list
       */

      edge->temp_list       = VEalloc_temp_node (min_param);
      edge->temp_list->next = VEalloc_temp_node (max_param);

      /*
       * For all potential visibility (overlap) transition points,
       * add appropriate temp nodes to list.
       */

      last_param1 = min_param;
      first_param1 = trans_param1;

      while ( (is_transition) || (is_along_line_of_sight) )
         {
	 /*
	  * Get next transition point; we need the parameter values of
	  * the two adjacent transitions before we can process this one
   	  * since they are used to determine if a curve-curve intersection
	  * point should also be considered a visibility transition or not.
	  */

	 VEfind_next_visib_trans_region( global_curve, FALSE,
			                 &next_param1, &next_param2,
				         &next_x, &next_y, &next_z,
				         &next_pt_is_transition,
				         &next_pt_is_along_line_of_sight );

	 if (! ((next_pt_is_transition) || (next_pt_is_along_line_of_sight)) )
	    next_param1 = max_param;

	 /*
	  * Now process the current transition point
	  */

         if (is_along_line_of_sight)
            VEadd_overlap_region( trans_param1, trans_param2, edge, VISIBLE, global_knot_tol );

	 if (is_transition)
	    VEprocess_trans_pt( edge, trans_param1, last_param1, next_param1,
		                trans_x, trans_y, trans_z );

	 last_param1  = trans_param1;
	 trans_param1 = next_param1;
	 trans_param2 = next_param2;
	 trans_x = next_x;
	 trans_y = next_y;
	 trans_z = next_z;
	 is_transition	      = next_pt_is_transition;
	 is_along_line_of_sight = next_pt_is_along_line_of_sight;

         }  /* end: while */

      /*
       * Do projections from curve endpoints.
       */

      if (! global_curve->phy_closed)
         {
         BScveval( global_curve, min_param, 0, test_pt, &rc );
         VEprocess_trans_pt( edge, min_param, min_param, first_param1,
	  	  	     test_pt[0], test_pt[1], test_pt[2] );
         BScveval( global_curve, max_param, 0, test_pt, &rc );
	 VEprocess_trans_pt( edge, max_param, last_param1, max_param,
			     test_pt[0], test_pt[1], test_pt[2] );
         }

      /*
       * Do some line intersections to find out which spans are visible
       */

      VEdetermine_visibilities( edge->temp_list );

      /*
       * Merge the completed visibility list & free temp nodes
       */

      VEmerge_visibs( edge );
      }  /* end: if ( (is_transition) || (is_along_line_of_sight) ) */

   /*
    * Reset tolerance
    */

   BSchangepar( &rc, BSTOLLENVEC,   default_dist_tol );
   BSchangepar( &rc, BSTOLSQLENVEC, default_dist_tol * default_dist_tol );

   }  /* VEcalculate_self_overlaps */
   


/*-- VEadd_knots_at_transition_points ---------------------------------------*/

void VEadd_knots_at_transition_points( curve )

	struct IGRbsp_curve *curve;

	{
	IGRlong      rc;
	IGRint       i;
	IGRint       mult;
	IGRboolean   is_transition;
	IGRboolean   is_along_line_of_sight;
	IGRboolean   first_time;
	IGRdouble    trans_param1;
	IGRdouble    trans_param2;
	IGRdouble    trans_x, trans_y, trans_z;
	IGRint       trans_size;
	IGRint       num_trans;
	IGRdouble    knot_tol;
	IGRdouble    *trans_pts;


	if ( (curve->order == 2) || VEperspective )
	   return;
	   
	BScvkttol2( curve->order, curve->knots,
	            curve->num_poles, curve->poles,
	            curve->weights, &knot_tol, &rc );
                
	BSxtractpar (&rc, BSTOLCHRDHT, &global_cht);

	/* get temporary storage to hold transition points */
	trans_size = (curve->num_poles / 3) + 1;
	
	VEget_unweighted_pole_storage( trans_size, &trans_pts );
	
	min_param = curve->knots[curve->order - 1];
	max_param = curve->knots[curve->num_knots - curve->order];

	/* find all transition points and save them so they */
	/* can be added to the curve later                  */
	first_time = TRUE;
        num_trans = 0;
	do
	   {
	   VEfind_next_visib_trans_region( curve, first_time,
	                                   &trans_param1, &trans_param2,
	                                   &trans_x, &trans_y, &trans_z,
	                                   &is_transition,
	                                   &is_along_line_of_sight );

	   if ( (is_transition) &&
	        (! ( (fabs(trans_param1 - min_param) < knot_tol) ||
	             (fabs(trans_param1 - max_param) < knot_tol) ) ) )
	      {
	      /* transition point that isn't at the min and max parameter of the curve */
	      trans_pts[ num_trans++ ] = trans_param1;
	      }

	   if ( (is_along_line_of_sight) &&
	        (! ( (fabs(trans_param2 - min_param) < knot_tol) ||
	             (fabs(trans_param2 - max_param) < knot_tol) ) ) )
	      {
	      /* line of sight point that isn't at the min and max parameter of the curve */
	      trans_pts[ num_trans++ ] = trans_param2;
	      }
	    
	   if ( first_time )
	      first_time = FALSE;
         
	   }
	while ( is_transition || is_along_line_of_sight );
   
	/* add knots at all of the transition points */
	if ( num_trans > 0 )
	   {
	   /* re-allocate poles, knots and weights for curve so they can */
	   /* hold all of the transition points that were found.         */
	   curve->knots = (IGRdouble *) realloc( curve->knots,
	                              (curve->num_knots + num_trans) * sizeof( IGRdouble ) );
	   curve->poles = (IGRdouble *) realloc( curve->poles,
	                              (curve->num_poles + num_trans) * 3 * sizeof( IGRdouble ) );
	   if ( curve->rational )
	      curve->weights = (IGRdouble *) realloc( curve->weights,
	                              (curve->num_poles + num_trans) * sizeof( IGRdouble ) );

	   mult = 1;
	   for ( i = 0; i < num_trans; i++ )
	      {
	      /* add a knot to the curve at param */
	      BSadd_ktr( &rc, curve, &trans_pts[i], &mult, TRUE );
              		  
	         BS_ERRCHK( rc, "VEadd_knots_at_transition_points: BSadd_ktr failed" );
	      }  /* end: for */
	   
	   }  /* end: if ( num_trans > 0 ) */
	   
	}  /* VEadd_knots_at_transition_points */
