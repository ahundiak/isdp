/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BScvsfintrg

Abstract
    This routine intersects a b-spline curve and surface, given a certain
range for each.

Synopsis

    void BScvsfintrg(curve, surf, trng, urng, vrng, nump, intpoints1, tpar1, 
                     uvpar1, numo, overpts1, tover1, uvover1, duplicate, nints,
                     nover, allocpts, allocov, intpoints2, tpar2, uvpar2, 
                     overpts2, tover2, uvover2, rc)

    struct IGRbsp_curve     *curve
    struct IGRbsp_surface   *surf
    IGRdouble               trng[2]
    IGRdouble               urng[2],vrng[2]
    IGRint                  nump
    IGRpoint                *intpoints1
    IGRdouble               *tpar1
    BSpair                  *uvpar1
    IGRint                  numo
    IGRpoint                *overpts1
    IGRdouble               *tover1
    IGRpair                 *uvover1
    IGRboolean              duplicate
    IGRint                  *nints
    IGRint                  *nover
    IGRboolean              *allocpts
    IGRboolean              *allocov
    IGRpoint                **intpoints2
    IGRdouble               **tpar2
    BSpair                  **uvpar2
    IGRpoint                **overpts2
    IGRdouble               **tover2
    BSpair                  **uvover2
    BSrc                    *rc

Description
    Input to this routine is a b-spline curve(curve), a surface(surf) and range
values for the curve parameters and surface parameters(trng, urng, and vrng).  
So this routine only looks for an intersection between the given ranges.
Also, the output is allocated before this routine and thus the amount of space 
which was allocated for the points and overlaps, has to be input(nump and
numo), and a boolean on whether to remove duplicate points is input(duplicate,
if TRUE then remove all duplicate points and if FALSE then only remove
duplicate parameter values).  Output is the number of intersections between the
curve and surface(nints), the intersection points(intpoints1), the parameter 
intersections on curve(tpar1), the parameter intersections on surf(uvpar1 ), 
the number of overlaps found(nover), the overlap end points (overpts1), the 
overlap parameters on curve(tover1), the overlap parameters on surf(uvover1 ), 
and also two booleans for the intersections and overlaps, which tell whether 
this routine had to allocate space for the output, if the caller 
did not have enough (allocpts and allocov).  So, if this routine has to 
allocate the space it is passed back in intpoints2, uvpar2, ect.  This will be 
descussed more in Notes section.
 
Return Values
    If memory cannot be allocated, rc returns BSNOMEMORY. If no error occurs
in one of the called routines, rc returns BSSUCC.

Notes
    The caller allocates the output space for intpoints1, tpar1, and uvpar1
of size nump.  Also the output space for overpts1, tover1, and uvover1
of size numo.  If this routine finds out that there is not enough space
for the intersections, then the boolean allocpts is set to true.  Then the 
output is alloced and returned in intpoints2, tpar2, and uvpar2.
The same is true for the overlaps(allocov=TRUE, then overpts2, ect.)

Index
    md

Keywords

History
    S.G. Catron   01/05/88   : Creation date.
    S.G. Catron   01/27/88   : If BSpl_cv_int finds some points and we have to
                               allocate the output, but then we find out that
                               there are no intersections, then we need to
                               dealloc the output.
    S.G. Catron   01/28/88   : Use a different curve and surface to rotate.
    S.G. Catron   03/10/88   : Forgot in deallocing stuff after wrapup: that 
                               the boxes may not have intersected and thus
                               there is no copysf->planar(which gives a
                               violation when trying to reference this).
    S.G. Catron   09/02/88   : If curve is order 2 with 2 poles,  then we
                               call BSpjmptssf(which is faster).
    S.G. Catron   11/14/89   : At wrapup, move second set of deallocations
                               above first set, because second checks
                               field of surface deleted in first set.
    S.R. Meeth    10/10/90   : fixed several assignments with incompatible
                               operands and moved initialization of
                               intersect to before the error checking.
    S.G. Catron   11/27/90   : Added some code so that it would not error
                               if surface was said to be planar, but was
                               not.  To instead, continue with the normal
                               intersection stuff.
    S.G. Catron   11/30/90   : Routine was not resetting the output 
                               pointer to NULL after memory had been 
                               freed.  This happened when BSpjmptssf found
                               a projection, allocated memory, and then
                               found out the point wasn't really on the 
                               curve and freed it.
    S.G. Catron   01/04/91   : Fixed apogee errors.
	Vivian Y.Hsu  02/14/2000 : In case of surface is planar, I added a statich function
	                           TrimOverlapBScvsfintrg to return overlap solution for
							   planar surface and curve intersetion. For Non-planar surface,
							   this routine has no knowledge about overlap because BScvsfnpint
							   is called which returns no information about overlap.
	Vivian Y.Hsu  02/22/2000   Replace BScvcv_int by BScvcvint that is in ubspm3d already.
	Vivian Y.Hsu  02/23/2000   After free memories for intersection and overlap, set them to NULL.


*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 

#include "bsdefs.h"
#include "bserr.h"
#include "bssfsf_int2.h"
#include "bsstackalloc.h"
#include "bsmalloc.h"
#include "bsstk.h"
#include "bsmemory.h"
#include "bsparameters.h"

#endif
#define BSVOID
#define  MAXNUM  100
#include <math.h>
static void swapBScvsfintrg(
IGRpoint pt1,
IGRpoint	 pt2,
BSpair   pr1,
BSpair	 pr2,
IGRdouble *p1,
IGRdouble 	 *p2)
{
   register IGRdouble tmp;

   tmp = pt1[0];
   pt1[0] = pt2[0];
   pt2[0] = tmp;
   tmp = pt1[1];
   pt1[1] = pt2[1];
   pt2[1] = tmp;
   tmp = pt1[2] ;
   pt1[2] = pt2[2];
   pt2[2] = tmp;
   tmp = pr1[0];
   pr1[0] = pr2[0];
   pr2[0] = tmp;
   tmp = pr1[1];
   pr1[1] = pr2[1];
   pr2[1] = tmp;                 
   tmp = *p1;
   *p1 = *p2;
   *p2 = tmp;
}

/* Given overlap solution obtained from an infinite plane and curve 
intersection (bspl_cv_int), this routine trims the overlap solution with
surface boundaries to find the real overlap solution for the bounded plane.
*/
#define MAX_NUM 10000

static void TrimOverlapBScvsfintrg(

struct IGRbsp_curve     *curve, /* Input, Original curve */
struct IGRbsp_surface   *surf,	/* Input, Original planar surface */
IGRint n_over,					/* Input, number of overlap for infinite plane */
IGRdouble *a,					/* Input, a[0:n_over-1],Start parameter of overlap */
IGRdouble *b,					/* Input, b[0:n_over-1],End parameter of overlapp */
IGRint *nints,					/* Output, number of intersection point found from */
								/* triming the overlap. (point touching the boundary) */
IGRdouble **tpar,				/* Output, parameter of the intersection on curve */
BSpair **uvpar,					/* Output, parameter of the intersection on surface */
IGRpoint **intpts,				/* Output, intersection points */
IGRint *n_over_bound,			/* Output,number of overlap for bounded plane. */
IGRdouble **t_overs,			/* Output, start and end parameters of overlap on curve */
BSpair **uv_overs,				/* Output,start and end parameter of overlap on surface */
IGRpoint **overpts,				/* Output,start and end overlap points */
BSrc *rc
)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsalloccv.h"
#include "bsconstprcv.h"
#include "bsactivsplt.h"
#include "bscvcvint.h"
#include "bstagsort.h"
#include "bscveval.h"
#include "bsprptonsf.h"
#endif 
	struct IGRbsp_curve **bound_cvs = NULL;
	struct IGRbsp_curve **overlap_cvs = NULL;
	IGRint i,j,k,nd,tot_num,tot_tmp;
	IGRshort opt = 2;
	IGRboolean tst_plan = FALSE, need_trim;
	IGRint n_int,n_ov,n_temp;
	IGRdouble *int_pts = NULL,*end_pts = NULL;
	IGRdouble *par0 = NULL, *par1 = NULL, *over0 = NULL, *over1 = NULL;
	IGRboolean found_start, found_end,onsurf;
	IGRdouble bas_tol = 1.0e-6,t,dummy1,dummy2;
	IGRdouble pars[2 * MAX_NUM];
	IGRint subs[MAX_NUM],in_ind[MAX_NUM],n_out = 0;
	IGRpoint pts_array[MAX_NUM],temp_pt[4];
	BSrc rc1 = BSSUCC;
	IGRboolean   out_pt_alloc, out_over_alloc;
	IGRdouble    *tint_pts = NULL;     
	IGRdouble    *tpar0 = NULL;        
	IGRdouble    *tpar1 = NULL;  
	IGRdouble    *tend_pts = NULL;
	IGRdouble    *tover0 = NULL;
	IGRdouble    *tover1 = NULL;

	*rc = BSSUCC;

	*n_over_bound = 0;

	/* Allocate space for output with MAX_NUM. */

	*intpts = (IGRpoint *)BSmalloc((unsigned)(MAX_NUM * sizeof(IGRpoint)));
	if (!(*intpts))
	{
		*rc = BSNOMEMORY;
		goto wrapup;
	}
	*tpar = (IGRdouble *)BSmalloc((unsigned)(MAX_NUM * sizeof(IGRdouble)));
	if (!(*tpar))
	{
		*rc = BSNOMEMORY;
		goto wrapup;
	}

	*uvpar = (BSpair *)BSmalloc((unsigned)(MAX_NUM * sizeof(BSpair)));
	if (!(*uvpar))
	{
		*rc = BSNOMEMORY;
		goto wrapup;
	}

	*overpts = (IGRpoint *)BSmalloc((unsigned)(2 * MAX_NUM * sizeof(IGRpoint)));
	if (!(*overpts))
	{
		*rc = BSNOMEMORY;
		goto wrapup;
	}
	*t_overs = (IGRdouble *)BSmalloc((unsigned)(2 * MAX_NUM * sizeof(IGRdouble)));
	if (!(*t_overs))
	{
		*rc = BSNOMEMORY;
		goto wrapup;
	}

	*uv_overs = (BSpair *)BSmalloc((unsigned)(2 * MAX_NUM * sizeof(BSpair)));
	if (!(*uv_overs))
	{
		*rc = BSNOMEMORY;
		goto wrapup;
	}

	/* Allocate 4 curves  for boundaries of the surface */
	
	bound_cvs = (struct IGRbsp_curve **)BSstackalloc((unsigned)(4 * sizeof(struct IGRbsp_curve *)));
	if (!bound_cvs)
	{
		*rc = BSNOSTKMEMORY;
		goto wrapup;
	}

	for (i = 0; i < 2; ++i)
	{
		bound_cvs[i] = NULL;
		BSalloccv(surf->u_order,surf->u_num_poles,surf->rational,0,&bound_cvs[i],rc);
		if (BSERROR(*rc))
			goto wrapup;
	}

	for (i = 2; i < 4; ++i)
	{
		bound_cvs[i] = NULL;
		BSalloccv(surf->v_order,surf->v_num_poles,surf->rational,0,&bound_cvs[i],rc);
		if (BSERROR(*rc))
			goto wrapup;
	}


	/* Allocate n_over overlap curves */

	overlap_cvs = (struct IGRbsp_curve **)BSstackalloc((unsigned)
		(n_over * sizeof(struct IGRbsp_curve *)));
	if (!overlap_cvs)
	{
		*rc = BSNOSTKMEMORY;
		goto wrapup;
	}

	for (i = 0; i < n_over; ++i)
	{
		overlap_cvs[i] = NULL;
		BSalloccv(curve->order,curve->num_poles,curve->rational,0,&overlap_cvs[i],rc);
		if (BSERROR(*rc))
			goto wrapup;
	}

	/* Extract 4 boundary curves from the planar surface */

	(void)BSconstprcv(rc,surf, &opt,&surf->v_knots[0],&tst_plan,bound_cvs[0]);
	if (BSERROR(*rc))
		goto wrapup;

	(void)BSconstprcv(rc,surf, &opt,&surf->v_knots[surf->v_num_poles],&tst_plan,bound_cvs[1]);
	if (BSERROR(*rc))
		goto wrapup;

	opt = 1;
	(void)BSconstprcv(rc,surf, &opt,&surf->u_knots[0],&tst_plan,bound_cvs[2]);
	if (BSERROR(*rc))
		goto wrapup;

	(void)BSconstprcv(rc,surf, &opt,&surf->u_knots[surf->u_num_poles],&tst_plan,bound_cvs[3]);
	if (BSERROR(*rc))
		goto wrapup;

	/* Extract the overlap part from the curve. */

	for (i = 0; i < n_over; ++i)
	{
		BSactivsplt(rc,curve,&a[i],&b[i],overlap_cvs[i],&tst_plan);
		if (BSERROR(*rc))
			goto wrapup;
	}

	/* Intersect overlap_cvs with bound_cvs */

	*nints = 0;
	n_temp = 0;
	for (i = 0; i < n_over; ++i)
	{
		need_trim = FALSE;
		tot_num = 0;
		n_out = 0;
		for (j = 0; j < 4; ++j)
		{
			BScvcvint( overlap_cvs[i], bound_cvs[j], TRUE, 0, 0, 
           (IGRpoint *) tint_pts, tpar0, tpar1, (IGRpoint *) tend_pts,
           tover0, tover1, &n_int, &n_ov, &out_pt_alloc,
           &out_over_alloc, (IGRpoint **) &int_pts, &par0, &par1, 
           (IGRpoint **) &end_pts, &over0, &over1, rc );
/*
			BScvcv_int(rc, overlap_cvs[i],bound_cvs[j],&n_int,&int_pts,&par0,&par1,
						(IGRlong *)&n_ov,&end_pts,&over0,&over1 );
*/
			if (BSERROR(*rc))
				goto wrapup;
		


			/* Copy intersection, overlap parameter of curve to an array */

			if (tot_num + n_int + 2 * n_ov > MAX_NUM)
			{
				*rc = BSNOMEMORY;
				goto wrapup;
			}

			if (n_int > 0)
			{
				BSMEMCPY((IGRint)(n_int * sizeof(IGRdouble)),(IGRdouble *)par0, (IGRdouble *)&pars[tot_num]);
				BSMEMCPY((IGRint)(3 * n_int * sizeof(IGRdouble)),(IGRdouble *)int_pts, (IGRpoint *)&pts_array[tot_num]);
			}

			if (n_ov > 0)
			{
				BSMEMCPY((IGRint)(2 * n_ov * sizeof(IGRdouble)), (IGRdouble *)over0, (IGRdouble *)&pars[tot_num + n_int]);
				BSMEMCPY((IGRint)(3 * 2 * n_ov * sizeof(IGRdouble)), (IGRdouble *)end_pts, (IGRpoint *)&pts_array[tot_num + n_int]);
			}
			tot_num += n_int + 2 * n_ov;

			if (int_pts)
			{
				BSdealloc((char *) int_pts);
				int_pts = NULL;
			}
			if (par0)
			{
				BSdealloc((char *) par0);
				par0 = NULL;
			}
			if (par1)
			{
				BSdealloc((char *) par1);
				par1 = NULL;
			}
			if (end_pts)
			{
				BSdealloc((char *) end_pts);
				end_pts = NULL;
			}
			if (over0)
			{
				BSdealloc((char *) over0);
				over0 = NULL;
			}
			if (over1)
			{
				BSdealloc((char *) over1);
				over1 = NULL;
			}
		}
		
		if (tot_num > 0 )
		{
			need_trim = TRUE;
		
			/* Check if the start and end points are intersection or overlap */

			found_start = FALSE;
			for (k = 0; k < tot_num; ++k)
			{
				if (fabs(overlap_cvs[i]->knots[0] - pars[k]) < bas_tol)
				{
					found_start = TRUE;
					break;
				}
			}

			
			found_end = FALSE;
			for (k = 0; k < tot_num; ++k)
			{
				if (fabs(overlap_cvs[i]->knots[overlap_cvs[i]->num_poles] - pars[k]) < bas_tol)
				{
					found_end = TRUE;
					break;
				}
			}

			

			if (tot_num + 2> MAX_NUM)
			{
				*rc = BSNOMEMORY;
				goto wrapup;
			}
				
			if (!found_start)
			{
				pars[tot_num] = overlap_cvs[i]->knots[0];
				pts_array[tot_num][0] = overlap_cvs[i]->poles[0];
				pts_array[tot_num][1] = overlap_cvs[i]->poles[1];
				pts_array[tot_num][2] = overlap_cvs[i]->poles[2];

				tot_num += 1;
			}
			if (!found_end)
			{
				pars[tot_num] = overlap_cvs[i]->knots[overlap_cvs[i]->num_poles];
				pts_array[tot_num][0] = overlap_cvs[i]->poles[3 * (overlap_cvs[i]->num_poles-1)];
				pts_array[tot_num][1] = overlap_cvs[i]->poles[3 * (overlap_cvs[i]->num_poles-1) + 1];
				pts_array[tot_num][2] = overlap_cvs[i]->poles[3 * (overlap_cvs[i]->num_poles-1) + 2];
				tot_num += 1;
			}

			(void)BStagsort(rc,&tot_num,pars,subs);
			if (BSERROR(*rc))
				goto wrapup;

			/* Compute the middle points of each segment and mark them "in" or "out" */

			for (k = 0; k < tot_num-1; ++k)
			{
				t = pars[subs[k]] + (pars[subs[k+1]] - pars[subs[k]]) / 2;
		
				BScveval(curve,t,0,temp_pt,rc);
				if (BSERROR(*rc))
					goto wrapup;

				(void)BSprptonsf(rc, surf, temp_pt[0], &dummy1,&dummy2, &onsurf);
				if(BSERROR(*rc))
					goto wrapup;

				if (onsurf)
					in_ind[k] = TRUE;
				else
					in_ind[k] = FALSE;
			}

			if (in_ind[tot_num - 2])
			{
				in_ind[tot_num - 1] = FALSE;
				tot_tmp = tot_num;
			}
			else
				tot_tmp = tot_num - 1;


			/* Now output the segment with mark */
			k = 0;
			found_start = FALSE;
			found_end = FALSE;
			while (k < tot_tmp)
			{
				if (in_ind[k])
				{
					if (found_start == FALSE)
					{
						/*  Save this one as the start of the overlap */

						if (n_temp + 1 >= MAX_NUM)
						{
							*rc = BSNOMEMORY;
							goto wrapup;
						}
						(*t_overs)[n_temp] = pars[subs[k]];
						for (nd = 0; nd < 3; ++nd)
							(*overpts)[n_temp][nd] = pts_array[subs[k]][nd];

			            (void)BSprptonsf(rc, surf, pts_array[subs[k]], &(*uv_overs)[n_temp][0], 
						&(*uv_overs)[n_temp][1], &onsurf);
						if(BSERROR(*rc))
							goto wrapup;

						if (!onsurf)
						{
							*rc = BSINCONSISTENT;
							goto wrapup;
						}

						n_temp += 1;
						found_start = TRUE;
					}
					k++;
				}
				else /* in_ind[k] = FALSE */
				{
					if (found_start == TRUE)
					{
						/* Save this one as the end of the overlap */

						if (n_temp + 1 >= MAX_NUM)
						{
							*rc = BSNOMEMORY;
							goto wrapup;
						}
						(*t_overs)[n_temp] = pars[subs[k]];
						for (nd = 0; nd < 3; ++nd)
							(*overpts)[n_temp][nd] = pts_array[subs[k]][nd];
						
			            (void)BSprptonsf(rc, surf, pts_array[subs[k]], &(*uv_overs)[n_temp][0], 
						&(*uv_overs)[n_temp][1], &onsurf);
						if(BSERROR(*rc))
							goto wrapup;

						if (!onsurf)
						{
							*rc = BSINCONSISTENT;
							goto wrapup;
						}

						n_temp += 1;
						found_start = FALSE;
					}
					else /* found_start = FALSE; */
					{
						n_out++;
						if (n_out == 2)
						{
							/* There is point touch the boundary. Output it as intersection */

							(*tpar)[*nints] = pars[subs[k]];
							for (nd = 0; nd < 3; ++nd)
								(*intpts)[*nints][nd] = pts_array[subs[k]][nd];
						
							(void)BSprptonsf(rc, surf, pts_array[subs[k]], &(*uvpar)[*nints][0], 
							&(*uvpar)[*nints][1], &onsurf);
							if(BSERROR(*rc))
								goto wrapup;
							if (!onsurf)
							{
								*rc = BSINCONSISTENT;
								goto wrapup;
							}
							*nints += 1;
							n_out--;
						}
					}
					k++;
				} /* end of while */
			} /* end of if (tot_num > 0) */
			
		} /* Finished trim the overlap with 4 boundaries. */

		if (!need_trim)
		{
			/* This entire overlap is either inside bounded surface or outside */

			BScveval(curve,a[i],0,&(*overpts)[n_temp],rc);
			if (BSERROR(*rc))
				goto wrapup;

			(void)BSprptonsf(rc, surf, (*overpts)[n_temp], &(*uv_overs)[n_temp][0], 
						   &(*uv_overs)[n_temp][1], &onsurf);
			if(BSERROR(*rc))
				goto wrapup;

			if (onsurf)
			{
				(*t_overs)[n_temp] = a[i];
				n_temp += 1;
				if (n_temp >= MAX_NUM)
				{
					*rc = BSNOMEMORY;
					goto wrapup;
				}
				BScveval(curve,b[i],0,&(*overpts)[n_temp],rc);
				if (BSERROR(*rc))
					goto wrapup;

				(void)BSprptonsf(rc, surf, (*overpts)[n_temp], &(*uv_overs)[n_temp][0], 
							   &(*uv_overs)[n_temp][1], &onsurf);
				if(BSERROR(*rc))
					goto wrapup;
				(*t_overs)[n_temp] = b[i];
				n_temp += 1;

				if (n_temp >= MAX_NUM)
				{
					*rc = BSNOMEMORY;
					goto wrapup;
				}
			}/* else it is outside. We don't want this overlap. */
		}
	}

	/* The number of overalp is half of n_temp */

	if (n_temp %2)
	{
		/* If n_temp is not a even number. Something went wrong. */
		*rc = BSINCONSISTENT;
		goto wrapup;
	}
	*n_over_bound = n_temp / 2;

wrapup:

	if (*nints == 0)
	{
		/* free intpts, tpar and uvpar */

		if (*intpts)
		{
			BSdealloc((char *) *intpts);
			*intpts = NULL;
		}
		if (*tpar)
		{
			BSdealloc((char *) *tpar);
			*tpar = NULL;
		}
		if (*uvpar)
		{
			BSdealloc((char *) *uvpar);
			*uvpar = NULL;
		}
	}

	if (*n_over_bound == 0)
	{
		/* free overpts,t_overs,uv_overs */

		if (*overpts)
		{
			BSdealloc((char *) *overpts);
			*overpts = NULL;
		}
		if (*t_overs)
		{
			BSdealloc((char *) *t_overs);
			*t_overs = NULL;
		}
		if (*uv_overs)
		{
			BSdealloc((char *) *uv_overs);
			*uv_overs = NULL;
		}
	}


	if (bound_cvs)
	{
		for (i = 0; i < 4; ++i)
		{
			if (bound_cvs[i])
			{
				BSfreecv(&rc1, bound_cvs[i]);
				if (BSERROR(rc1) && BSOKAY(*rc))
					*rc = rc1;
				bound_cvs[i] = NULL;
			}
		}
		BSstackdealloc((char *) bound_cvs);
		bound_cvs = NULL;
	}

	if (overlap_cvs)
	{
		for (i = 0; i < n_over; ++i)
		{
			if (overlap_cvs[i])
			{
				BSfreecv(&rc1, overlap_cvs[i]);
				if (BSERROR(rc1) && BSOKAY(*rc))
					*rc = rc1;
				overlap_cvs[i] = NULL;
			}
		}
		BSstackdealloc((char *) overlap_cvs);
		overlap_cvs = NULL;
	}

	return;

}

void BScvsfintrg(
struct IGRbsp_curve     *curve,
struct IGRbsp_surface   *surf,
IGRdouble               trng[2],
IGRdouble               urng[2],
 IGRdouble	vrng[2],
IGRint                  nump,
IGRpoint                *intpoints1,
IGRdouble               *tpar1,
BSpair                  *uvpar1,
IGRint                  numo,
IGRpoint                *overpts1,
IGRdouble               *tover1,
BSpair                  *uvover1,
IGRboolean              duplicate,
IGRint                  *nints,
IGRint                  *nover,
IGRboolean              *allocpts,
IGRboolean              *allocov,
IGRpoint                **intpoints2,
IGRdouble               **tpar2,
BSpair                  **uvpar2,
IGRpoint                **overpts2,
IGRdouble               **tover2,
BSpair                  **uvover2,
BSrc                    *rc)
{    
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bscvoton.h"
#include "bsavgpts.h"
#include "bsprptoncv.h"
#include "bspl_cv_int.h"
#include "bsptnwtold.h"
#include "bsbx2.h"
#include "bsfxcvsfdir.h"
#include "bspjmptssf.h"
#include "bssfoton.h"
#include "bssfnormal.h"
#include "bsprptonsf.h"
#include "bscvsfnpint.h"
#endif 
   IGRlong         totp1;
   IGRpoint        min1,max1,    /* points defining the min-max box for curve*/
                   min2,max2;    /* and surf  */
   IGRboolean      intersect;    /* indicator for box intersection           */
   IGRint          i,j;          /* loop counter                             */
   IGRdouble       dist_tol;     /* distance tolerance value                 */
   IGRdouble       scale = 1;    /* scale factor                             */
   IGRvector       vec;          /* translation vector                       */
   IGRboolean      rotate;       /* indicator for rotation                   */
   IGRdouble       mat[3][3];    /* transformation matrix                    */
   IGRvector       norm1;        /* normal vectors                           */
   IGRpoint        avgpt1;      /* average points                            */
   IGRdouble       *u=NULL,*a=NULL,
                   *b=NULL,su[MAXNUM],
                   sa[MAXNUM],sb[MAXNUM], 
                   *ptr3=NULL;
   BSpair          *ptr2=NULL;
   IGRpoint        *int_points=NULL,sint_points[MAXNUM], 
                   point, *ptr1=NULL;
   IGRint          n_int,n_seg, k;
   IGRboolean      onsurf, bi_directional, planar;
   struct IGRbsp_curve *copycv=NULL;
   struct IGRbsp_surface *copysf=NULL;
   BSrc  rc1;
   IGRboolean int_pointsalloc=FALSE, ualloc=FALSE, aalloc=FALSE,
              balloc=FALSE;

   /* The following is done to suppress lint warnings concerning unused
    * arguments.
    */
   *rc = (BSrc) numo;
   *rc = (BSrc) overpts1;
   *rc = (BSrc) tover1;
   *rc = (BSrc) uvover1;
   *rc = (BSrc) overpts2;
   *rc = (BSrc) tover2;
   *rc = (BSrc) uvover2;

   *rc = BSSUCC;
   intersect = TRUE;   
   *allocpts = FALSE;
   *allocov = FALSE;
   *nints = 0;
   *nover = 0;
   rotate = FALSE;
   
   BSEXTRACTPAR( rc, BSTOLLENVEC, dist_tol);

   (void)BSbx2( rc, &curve->num_poles, (IGRpoint *) curve->poles,
                curve->weights, min1, max1 );
   if (BSERROR(*rc))
   {
      goto wrapup;
   }
   totp1 = surf->u_num_poles * surf->v_num_poles;
   (void)BSbx2( rc, &totp1, (IGRpoint *) surf->poles, surf->weights, min2,
                max2 );
   if (BSERROR(*rc))
   {
     goto wrapup;
   }

   i = 0;

   do
   {
      if (((max1[i] + dist_tol) < min2[i]) || 
         ((max2[i] + dist_tol) < min1[i]))
      {
         intersect = FALSE;
      }
      i++;
   } while ((intersect ) && (i < 3));
   if (!intersect)
   {
      /* the min max boxes do not even intersect */
      goto wrapup;
   }
   if(curve->order == 2 && curve->num_poles == 2 &&
      !(surf->u_num_poles == 2 && surf->v_num_poles == 2) )
   {
      /* make a point and vector out of the line */
      if(curve->rational)
      {
         for(i=0; i<3; i++)
         {
            point[i] = curve->poles[i]/curve->weights[0];
            vec[i] = curve->poles[3+i]/curve->weights[1] - point[i];
         }
      }
      else
      {
         for(i=0; i<3; i++)
         {
            point[i] = curve->poles[i];
            vec[i] = curve->poles[3+i] - point[i];
         }
      }
      n_int = 1;
      bi_directional = FALSE;
      BSpjmptssf(surf, n_int, (IGRpoint *) &point, n_int,
                 (IGRvector *) &vec, urng, vrng, bi_directional, nump,
                 intpoints1, (IGRdouble *) uvpar1, allocpts, nints,
                 intpoints2, (IGRdouble **) uvpar2, rc);
      if(BSERROR(*rc))
         goto wrapup;

      if(*allocpts)
      {
         ptr1 = *intpoints2;
         ptr2 = *uvpar2;
         /* allocate for tpar2 */
         *tpar2 = (IGRdouble *)BSmalloc((unsigned)(*nints *sizeof(IGRdouble)));
         if(!*tpar2)
         {
            *rc = BSNOMEMORY;
            goto wrapup;
         }
         ptr3 = *tpar2;
      }
      else
      {
         ptr1 = intpoints1;
         ptr2 = uvpar1;
         ptr3 = tpar1;
      }
      for(j=0, i=0; i< *nints; i++)
      {
         /* check each point to see if it is on the curve */
         (void)BSprptoncv(rc, curve, ptr1[j], &ptr3[j], &onsurf);
         if(BSERROR(*rc))
            goto wrapup;
         if(! onsurf)
         {
            /* delete point from output by coping over*/
            if( i != *nints -1)
            {
               ptr1[j][0] = ptr1[*nints-1][0];
               ptr1[j][1] = ptr1[*nints-1][1];
               ptr1[j][2] = ptr1[*nints-1][2];
               ptr2[j][0] = ptr2[(*nints-1)][0];
               ptr2[j][1] = ptr2[(*nints-1)][1];
            }
         }
         else
         {
            /* make sure tpars are in ascending order */
            for(k=j; k>0; k--)
            {
               if( ptr3[k] < ptr3[k-1])            
               {
                  /* swap */
                  swapBScvsfintrg(ptr1[k], ptr1[k-1], ptr2[k], ptr2[k-1], 
                                  &ptr3[k], &ptr3[k-1]);
               }
               else
               {
                  break;
               }
            }
            j++;
         }
      }/*for loop*/        
      *nints = j;
      if( *allocpts && *nints <= nump)
      {
         if( *nints > 0 )
         {
            /* now we have enough space in given memory */
            BSMEMCPY(*nints * sizeof(IGRpoint), (IGRchar *) *intpoints2,
                     (IGRchar *) intpoints1);
            BSMEMCPY(*nints * sizeof(BSpair), (IGRchar *) *uvpar2,
                     (IGRchar *) uvpar1);
            BSMEMCPY(*nints * sizeof(IGRdouble), (IGRchar *) *tpar2,
                     (IGRchar *) tpar1);
         }
         BSdealloc((char *)*intpoints2);
         *intpoints2 = NULL;
         BSdealloc((char*)*uvpar2);
         *uvpar2 = NULL;
         BSdealloc((char*)*tpar2);
         *tpar2 = NULL;
         *allocpts = FALSE;
      }
      goto wrapup;
   }
   BSfxcvsfdir( curve, surf, &rotate, mat, rc );
   if (BSERROR(*rc))
   {
     goto wrapup;
   }

   if (rotate)
   {
      BSstkallocv(rc, copycv, curve->num_poles, curve->rational, 
                  curve->num_knots, curve->num_boundaries );
      if(BSERROR(*rc))
         goto wrapup;
      BSstkallosf(rc, copysf, surf->u_num_poles, surf->v_num_poles, 
                  surf->rational, surf->u_num_knots, surf->v_num_knots, 
                  surf->num_boundaries );
      if(BSERROR(*rc))
         goto wrapup;
      
      copysf->num_boundaries = 0;
      vec[0] = 0;
      vec[1] = 0;
      vec[2] = 0;

      BSsfoton( vec, mat, &scale, surf, copysf, rc );
      if (BSERROR(*rc))
      {
         goto wrapup;
      }

      (void)BScvoton(rc, vec, mat, &scale, curve, copycv);
      if (BSERROR(*rc))
      {
         goto wrapup;
      }

      (void)BSbx2( rc, &copycv->num_poles, (IGRpoint *) copycv->poles,
                   copycv->weights, min1, max1);
      if (BSERROR(*rc))
      {
         goto wrapup;
      }
      (void)BSbx2( rc, &totp1, (IGRpoint *) copysf->poles,
                   copysf->weights, min2, max2 );
      if (BSERROR(*rc))
      {
         goto wrapup;
      }
      /* check if the new boxes intersect */
      i = 0;
      intersect = TRUE;
      do
      {
         if (((max1[i] + dist_tol) < min2[i]) || 
            ((max2[i] + dist_tol) < min1[i]))
         {
            intersect = FALSE;
         }
         i++;
      } while ((intersect ) && (i < 3));
   
      if (!intersect)
      {
         /* the new min max boxes do not intersect now */
         goto wrapup;
      }
   }
   else
   {
      copysf = surf;
      copycv = curve;
   }
   
   planar = FALSE;
   (void)BStst_plan(copysf->u_num_poles * copysf->v_num_poles,copysf->poles,
	   copysf->weights,&planar,norm1,rc);
   if (BSERROR(*rc))
	   goto wrapup;
/*
   if (copysf->planar ) 
   {
      planar = TRUE;
      BSsfnormal( copysf, norm1, rc );
      if (BSERROR(*rc))
      {
         if(*rc == BSFAIL )
         {
            *rc = BSSUCC;
            planar = FALSE;
         }
         else
            goto wrapup;
      }
   }
*/
   if ( planar ) 
   {
      (void)BSavgpts( rc, totp1, copysf->poles, copysf->weights, avgpt1 );
      if (BSERROR(*rc))
         goto wrapup;
   
      if( copycv->num_poles > MAXNUM)
      {
         int_points = (IGRpoint *)BSstackalloc((unsigned)( copycv->num_poles *
                                         sizeof(IGRpoint)));
         if(!int_points)
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         int_pointsalloc = TRUE;
         u = (IGRdouble *)BSstackalloc((unsigned)( copycv->num_poles * sizeof 
                                         (IGRdouble )));
         if(! u )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         ualloc = TRUE;         
         a = (IGRdouble *)BSstackalloc((unsigned)( copycv->num_poles * sizeof 
                                         (IGRdouble )));
         if(! a )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         aalloc = TRUE;         
         b = (IGRdouble *)BSstackalloc((unsigned)( copycv->num_poles * sizeof 
                                         (IGRdouble )));
         if(! b )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
         balloc = TRUE;         
      }
      else
      {
         int_points = sint_points;
         u = su;
         a = sa;
         b = sb;
      }
      (void)BSpl_cv_int(rc, copycv, avgpt1, norm1, &n_int,
                        (IGRdouble *) int_points, u, &n_seg, a, b);
      if(BSERROR(*rc))
      {
         goto wrapup;
      }

	  /* Added code to trim overlap */

	  if (n_seg > 0)
	  {
			TrimOverlapBScvsfintrg(copycv,copysf,n_seg,a,b,nints,tpar2,uvpar2,intpoints2,
				  nover,tover2,uvover2,overpts2,rc);
			if (BSERROR(*rc))
				  goto wrapup;
			if (*nints > 0)
				*allocpts = TRUE;
			if (*nover > 0)
				*allocov = TRUE;
	  }
      if( n_int <= nump && *nints == 0)
      {
         for(i=0; i< n_int; i++)
         {
            (void)BSprptonsf(rc, copysf, int_points[i], &uvpar1[*nints][0], 
                       &uvpar1[*nints][1], &onsurf);
            if(BSERROR(*rc))
            {
               goto wrapup;
            }
          /* if point found is on the copysface, then copy intersection to
                output arrays */
            if( onsurf)
            {
               for(j=0; j<3; j++)
               {
                  intpoints1[*nints][j] = int_points[i][j];
               }
               tpar1[*nints] = u[i];
               *nints += 1;
            }            
         }
      }
      else
      {
		 if (*nints == 0) /* No intersection points found in overlap (Touching boundary) */
		 {
			*allocpts = TRUE;
			*intpoints2 = (IGRpoint *)BSmalloc((unsigned)( n_int * sizeof
                                 (IGRpoint )));
			if( !(*intpoints2) )
			{
				*rc = BSNOMEMORY;
				goto wrapup;
			}
			*tpar2 = (IGRdouble *)BSmalloc((unsigned)(n_int*sizeof(IGRdouble )));
			if(! (*tpar2) )
			{
				*rc = BSNOMEMORY;
				goto wrapup;
			}
			*uvpar2 = (BSpair *)BSmalloc((unsigned)( n_int * sizeof(BSpair)));
			if(! (*uvpar2 ))
			{
				*rc = BSNOMEMORY;
				goto wrapup;
			}
		 }
		 else /* Found touching point in overlap.*/
		 {
			 if (*nints + n_int > MAX_NUM)
			 {
				 *rc = BSNOMEMORY;
				 goto wrapup;
			 }
		 }

         if( n_int > 0 )
         {
            for(i=0; i< n_int; i++)
            {
               (void)BSprptonsf(rc,copysf,int_points[i],&(*uvpar2)[*nints][0],
                          &(*uvpar2)[*nints][1], &onsurf);
               if(BSERROR(*rc))
               {
                  goto wrapup;
               }
               /* if point found is on the copysface, then copy intersection to
                  output arrays */
               if( onsurf)
               {
                  for(j=0; j<3; j++)
                  {
                     (*intpoints2)[*nints][j] = int_points[i][j];
                  }
                  (*tpar2)[*nints] = u[i];
                  *nints += 1;
               }            
            }
            if( *nints == 0 )
            {
               *allocpts = FALSE;
               if( *intpoints2 )
               {
                  BSdealloc((char *) *intpoints2 );
                  *intpoints2 = NULL;
               }
               if( *tpar2 )
               {
                  BSdealloc((char *) *tpar2 );
                  *tpar2 = NULL;
               }
               if( *uvpar2 )
               {
                  BSdealloc((char *) *uvpar2 );
                  *uvpar2 = NULL;
               }
            }
         }
      }
   }
   else
   {
      BScvsfnpint( copycv, copysf, trng, urng, vrng, nump, intpoints1, tpar1, 
                   uvpar1, duplicate, nints, allocpts, intpoints2, tpar2, 
                   uvpar2,rc );
      if (BSERROR(*rc))
      {
         goto wrapup;
      }
   }
   if (rotate)
   {
      /* rotate the intersection points */
      if( ! *allocpts )
      {
         for (i=0; i < *nints; i++)
         {
            (void)BSptnwtold( rc, vec, mat, &scale, intpoints1[i], 
                              intpoints1[i] );
            if (BSERROR(*rc))
            {
               goto wrapup;
            }
         }           
      }
      else
      {
         for (i=0; i < *nints; i++)
         {
            (void)BSptnwtold( rc, vec, mat, &scale, (*intpoints2)[i], 
                              (*intpoints2)[i] );
            if (BSERROR(*rc))
            {
               goto wrapup;
            }
         }
      }           
   }
    
   wrapup:

   if( balloc && b )
      BSstackdealloc((char *)b);
   if( aalloc && a)
      BSstackdealloc((char *)a);
   if( ualloc && u)
      BSstackdealloc((char*) u);
   if( int_pointsalloc && int_points)
      BSstackdealloc((char *)int_points);

   if( rotate )
   {
      if( copysf )
      {
         BSstkfreesf(&rc1, copysf);
         if(BSERROR(rc1) && BSOKAY(*rc ) )
            *rc = rc1;
      }
 
      if( copycv )
      {
         BSstkfreecv(&rc1, copycv);
         if(BSERROR(rc1) && BSOKAY(*rc ) )
            *rc = rc1;
      }
   }
   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BScvsfintrg");
   return;
   }
}   

