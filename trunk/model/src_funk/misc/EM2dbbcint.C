/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

/* end of gr.h replacement */

static void EMgetkeycurve();

#define DEBUG 0

#include "bserr.h"
#include "bsparameters.h"
#include <math.h>
#include "emsmacros_c.h"
#include "EMSerrordef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsinterdef.h"
#include "emserr.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#define LINELINE 0
#define LINEBEZ 1
#define BEZLINE 2
#define BEZBEZ 3
#define MYOTHER 3
#define BEGIN_OVERLAP 0
#define POINT 1
#define END_OVERLAP 1

#include "EMSbstrim.h"


#if DEBUG
 #include <stdio.h>
#endif

#include "bsxspnspn.h"
#include "bsptlnplan.h"
#include "bsnorvec.h"
#include "bscveval.h"


/* ************************************************************************
    
   This function returns the cutting intersections of an incoming line string
   expressed as a bezier curve structure with a bezier curve.

   The caller is responsible for allocating memory for storing the intersection
   details. The maximum number of intersections that can result are
   curve1 order multiplied by curve2 order.  Memory should be allocated
   accordingly.

   History : 
              PP  : 04/07/87         Creation date
              PP  : 12/10/87         Calling BSxspnspn only for determining
                                     the intersection. Before I was
                                     calling a number of special purpose
                                     routines.
              PP  : 01/13/88         Changed the argument to EMget_next_span
                                     to fix a bug related to the case
                                     when a NULL pointer is passed for
                                     adjgeom.
              PP  : 01/26/88         Took care of the one case that I
                                     am not supporting, which happens when
                                     an end point intersection takes place
                                     and the tangents of the beginning 
                                     span and the next span at the int point
                                     are collinear but in opposite directions,
                                     to return an intersection all the time
                                     and set the cb_props as unknown.
              PP  : 02/08/88         Supporting the return of EMS_INT_UNKNOWN
                                     from EMdecideint, when a tangency condition
                                     is detected, to return 
                                     EMSrelorient_unknown.
              PP  : 05/08/88         Support for handling the case when the
                                     intersection happens to be at an endpoint
                                     of an edge and there is no next span
                                     for resolving the ambiguity. In such
                                     a case the intersection is returned 
                                     and its orientation is declared as
                                     EMSrelorient_unknown.
              PP  : 06/01/88         Support for non-cutting intersections
              PP  : 08/24/88         Changed the way I was classifying
                                     intersections by looking at uv comparison
                                     instead of a w comparison. This would
                                     make the results more accurate and the
                                     code slightly slower. Did this in
                                     response to some of the problems we
                                     were having in booleans. 
              PP : 02/12/89          Made changes to handle degenerate
                                     curves. See comments below. Please
                                     note that this handling may be
                                     contrary to the results that
                                     might be expected for the cutting
                                     intersection case.
              Sudha 7/08/93          Modified for BSprototypes ansification
              SCW 13-Feb-1997        included emsmacros_c.h rather than 
                                     emsmacros.h
   ************************************************************************ */

EMbsbscutint (msg_loc, ts, cs, getadjseg, adjgeom, span_info, trim_options,
              no_of_inter,int_pts,my_inters_par, cb_inters_par, my_int_type, 
                         cb_int_type, cb_props)

IGRlong		*msg_loc; /* completion message */
struct IGRbsp_curve *ts; /* bspline geometry representing the test span */
struct IGRbsp_curve *cs; /* bspline geometry representing the cutting
                            span */
IGRlong (*getadjseg) (); /* function which would get the next span
                            geometry */
struct EMSgetadjgeom *adjgeom;
                         /* pointer to structure containing information
                            to obtain the next span geometry */
struct EMthis_spaninfo *span_info;
IGRushort  trim_options;
                         /* Trimming options */
IGRlong		*no_of_inter; /* number of cutting intersections found */
IGRdouble       *int_pts;    /* u,v values of the intersection points */
IGRdouble 	*my_inters_par;
                              /* curve parameter values of int_pts on my
                                 geometry */
IGRdouble 	*cb_inters_par;
                              /* curve parameter values of int_pts on 
                                 cutting bspline geometry */
enum EMScvinttype *my_int_type,
                  *cb_int_type;

enum EMSrelorient *cb_props;  /* properties of the intersection on the
                                 cutting bspline whether it is going from
                                 area to hole or hole to area */
{

 IGRshort 		i; /* loop counter */
 IGRshort		indx;
 BSrc			rc;
 IGRint			n_discr; /* number of discrete intersections */


 IGRboolean		bssts, overlap , proc_int;
 

 IGRdouble		pt[3];
 IGRdouble	        *d_inter,	
                        *par0,
                        *par1;
 

 struct IGRbsp_curve    *ns;
 struct IGRbsp_curve    next_span;
 IGRdouble              poles[3*MAX_ORDER],
                        knots[MAX_ORDER + MAX_ORDER],
                        weights[MAX_ORDER];

 enum EMScvinttype      my_temp_itype,/* temporary storage area for
                                         my intersection type */
                        cb_temp_itype; /* for cutting bspline intersection */ 
                                          
 IGRint			intersection; 

 IGRdouble 		*int_pt;

 struct EMint_info      tsi,
                        csi;

 IGRboolean		ambiguous_case = FALSE;
 IGRboolean		classify_right = FALSE,
                        classify_left = FALSE;
 enum EMSrelorient      cb_temp_props;
 IGRushort      left_side,
                        right_side;
 struct EMSdataselect   indata;
 IGRboolean             atstart, atend;
 IGRboolean		rightinarea = FALSE,leftinarea = FALSE;
 extern void 		EMdecideint();
 extern void 		EMget_next_span ();
 extern IGRboolean      EFclassify_position();

/*
 * Initialisation
 */


 *msg_loc = EMS_S_Success;
 d_inter = par0 = par1 = NULL;
 *no_of_inter = 0;
 csi.is_valid = 0;
 tsi.is_valid = 0;
 overlap = FALSE;

/*
 * We try to use the same memory region sent in by the calling routine to
 * store the intersection parameters. We have the liberty of doing the same
 * as the number of cutting intersections is equal to or less then the 
 * total number
 * of intersections. 
 */

  

  d_inter = int_pts;
  par0 = my_inters_par;
  par1 = cb_inters_par;

 BSxspnspn (ts, cs, MYOTHER, MYOTHER, &n_discr, (IGRpoint *)d_inter, par0, par1,
            &overlap, &rc);
 EMerr_hndlr (BSERROR(rc), *msg_loc, EMS_E_Fail, wrapup);


/*
 * The math routine for determining an overlap condition first checks to
 * see if there are endpoint intersections. If so it checks if the polynomial
 * coefficients of the bezier curves are in tolerance. Hence if there is
 * an overlap, one of the curves has to completely lie on the other in which
 * case accordint to our definition of cutting intersection there is no
 * intersection
 */


 if (n_discr == 0)
 {
  *no_of_inter = 0;
  goto wrapup;
 }

if (overlap)
 n_discr = 2;

{
/*
 * The following code handles the case of a degenerate curve intersecting
 * with another degenerate/non-degenerate curve.
 * If a cutting intersection is desired then no intersection is returned.
 * And if a non-cutting intersection is desired then an intersection is
 * returned.
 */

 IGRint cscode, tscode;
 IGRvector nvec;
 BSrc rc;

  BSptlnplan(cs->num_poles, cs->rational, (IGRpoint *)cs->poles, 
             cs->weights, &cscode, nvec, &rc);
  EMerr_hndlr(BSERROR(rc), *msg_loc, EMS_E_BSerror, wrapup);

  BSptlnplan(ts->num_poles, ts->rational, (IGRpoint *)ts->poles, 
             ts->weights, &tscode, nvec, &rc);
  EMerr_hndlr(BSERROR(rc), *msg_loc, EMS_E_BSerror, wrapup);

  if ((trim_options & EMS_INTER_CUTTING) &&
       ((cscode == POINT) || (tscode == POINT)))
       n_discr = 0;
}

 for (i=0 ; i < n_discr; i++)
 {
  proc_int = TRUE;
  ambiguous_case = FALSE;
  leftinarea = FALSE;
  rightinarea = FALSE;
  left_side = 0;
  right_side = 0;
  classify_right = FALSE;
  classify_left = FALSE;
  intersection = FALSE;
  csi.is_valid = 0;
  tsi.is_valid = 0;
  csi.parameter = par1[i];
  tsi.parameter = par0[i];
  csi.is_valid |= EMIS_PARAMETER_VALID;
  tsi.is_valid |= EMIS_PARAMETER_VALID;
  int_pt = &d_inter[3*i];

  indata.datatype = EMSdata_curve3d;
  indata.data.curve = ts;

/* 
 * Classify the intersection points as being on the left right or middle
 * for both the cutting line and the cut bezier curve
 */

  bssts = EFclassify_position(msg_loc, &indata, &par0[i], &atstart, &atend);
  EMerr_hndlr (!bssts, *msg_loc, *msg_loc, wrapup);

  if (atstart)
   my_temp_itype = EMScvint_lfend;
  else if (atend)
   my_temp_itype = EMScvint_rtend;
  else
   my_temp_itype = EMScvint_middle;

  indata.datatype = EMSdata_curve3d;
  indata.data.curve = cs;

  bssts = EFclassify_position (msg_loc, &indata, &par1[i], &atstart, &atend);
  EMerr_hndlr (!bssts, *msg_loc, *msg_loc, wrapup);

  if (atstart)
   cb_temp_itype = EMScvint_lfend;
  else if (atend)
   cb_temp_itype = EMScvint_rtend;
  else
   cb_temp_itype = EMScvint_middle;

 if (trim_options & EMS_INTER_CUTTING)
 {
  switch (cb_temp_itype)
  {
   case EMScvint_lfend:
    classify_right = TRUE;
    classify_left = FALSE;
    left_side |= EMS_INT_BOUNDARY;
   break;

   case EMScvint_rtend:
    right_side |= EMS_INT_BOUNDARY;
    classify_right = FALSE;
    classify_left = TRUE;
   break;

   case EMScvint_middle:
    classify_right = TRUE;
    classify_left = TRUE;
   break;
  }
 
  switch (my_temp_itype)
  {
/*
 * If the intersection happened at the left end of the cut bezier
 * it is ignored since this would have been trapped by a previous
 * bezier span to this span
 */

   case EMScvint_lfend:
    proc_int = FALSE;
    break;

   case EMScvint_rtend:
/* 
 * If the intersection of the cutting line is at the left or right end
 * Decide whether the cutting line needs to be classified against the
 * test span or the next span. And based on that decide  if the line cuts
 * the curve
 */
{
  IGRboolean consider_test_span;
/*
  IGRdouble par;  */ /* beginning parameter of the next span */
  struct EMint_info nsi;
/*
  void EMgetkeycurve();
*/

  nsi.is_valid = 0;
  next_span.num_poles = 0;
  next_span.poles = (IGRdouble *) poles;
  next_span.knots = (IGRdouble *) knots;
  next_span.weights = (IGRdouble *) weights;
  next_span.bdrys = NULL;
  ns = &next_span;

/*
 * if the intersection on the cutting line string is in the middle then we
 * need to examine both sides of the intersection on the cutting line string
 * and we try to classify whether each side is cutting or not 
 */

  if (overlap)
  {
   if (cb_temp_itype == EMScvint_middle)
    {
    intersection = 0;
    if (par1[END_OVERLAP] > par1[BEGIN_OVERLAP])
    {
     classify_right = TRUE;
     classify_left = FALSE;
     left_side |= EMS_INT_BOUNDARY;
    }
    else if (par1[END_OVERLAP] < par1[BEGIN_OVERLAP])
    {
     classify_left = TRUE;
     classify_right = FALSE;
     right_side |= EMS_INT_BOUNDARY;
    }
    else 
     {
       *msg_loc = EMS_E_InvalidCase;
       goto wrapup;
     }
    }
   else if (cb_temp_itype == EMScvint_lfend)
    {
      intersection = 0;
      classify_right = FALSE;
      classify_left = FALSE;
      right_side |= EMS_INT_BOUNDARY;
      left_side |= EMS_INT_BOUNDARY;
    }
   else if (cb_temp_itype == EMScvint_rtend)
   {
      intersection = 0;
      classify_right = FALSE;
      classify_left = FALSE;
      left_side |= EMS_INT_BOUNDARY;
      right_side |= EMS_INT_BOUNDARY;
   }
  }

  EMget_next_span (msg_loc, span_info, getadjseg, adjgeom,ns);
  EMerr_hndlr (EMis_error(*msg_loc), *msg_loc, EMS_E_Fail, wrapup);
  
  if (*msg_loc == EMS_I_NotFound)
  {
    ambiguous_case = TRUE;
    break;
  }
  
  if (ns->num_poles == 0)
  {
   *msg_loc = EMS_E_InvalidArg;
   goto wrapup;
  }
  
  nsi.parameter = ns->knots[ns->order - 1];
  nsi.is_valid |= EMIS_PARAMETER_VALID;

  if (classify_right)
  {
   csi.is_valid &= ~EMIS_TANGENT_VALID;

   EMgetkeycurve (msg_loc, RIGHT, ts, cs, ns, int_pt, &tsi, &csi, &nsi,
                  &consider_test_span);
   if (*msg_loc == EMS_E_InvalidCase)
   {
    ambiguous_case = TRUE;
    *msg_loc = EMS_S_Success;
   }
   EMerr_hndlr (EMis_error(*msg_loc),*msg_loc, EMS_E_Fail, wrapup);
   

   if (!ambiguous_case)
   {
   if (consider_test_span)
   {
    EMdecideint (msg_loc, FALSE, RIGHT,ts,cs, int_pt, 
                 &csi, &tsi,&right_side);
    EMerr_hndlr (EMis_error(*msg_loc),*msg_loc, EMS_E_Fail, wrapup);
   }
   else
   {
    EMdecideint (msg_loc, TRUE, RIGHT,ns,cs, int_pt, &csi, 
                 &nsi,&right_side);
    EMerr_hndlr (EMis_error(*msg_loc),*msg_loc, EMS_E_Fail, wrapup);
   }
  }
  }

  if (classify_left)
  {

   csi.is_valid &= ~EMIS_TANGENT_VALID;
   
   EMgetkeycurve (msg_loc, LEFT, ts, cs, ns, int_pt, &tsi, &csi, &nsi,
                  &consider_test_span);
   if (*msg_loc == EMS_E_InvalidCase)
   {
    ambiguous_case = TRUE;
    *msg_loc = EMS_S_Success;
   }
   EMerr_hndlr (EMis_error(*msg_loc),*msg_loc, EMS_E_Fail, wrapup);

   if (!ambiguous_case)
   {
   if (consider_test_span)
   {
    EMdecideint (msg_loc, FALSE, LEFT, ts,cs, int_pt, &csi, 
                 &tsi,&left_side);
    EMerr_hndlr (EMis_error(*msg_loc),*msg_loc, EMS_E_Fail, wrapup);
   }
   else
   {
    EMdecideint (msg_loc, TRUE, LEFT,ns,cs, int_pt, &csi, 
                 &nsi,&left_side);
    EMerr_hndlr (EMis_error(*msg_loc),*msg_loc, EMS_E_Fail, wrapup);
   }
  }

  }
 }
   
   break;

   case EMScvint_middle:

   if (overlap)
   {
    if (cb_temp_itype == EMScvint_lfend)
    {
      intersection = 0;
      classify_right = FALSE;
      classify_left = FALSE;
      right_side |= EMS_INT_BOUNDARY;
      left_side |= EMS_INT_BOUNDARY;
    }
   else if (cb_temp_itype == EMScvint_rtend)
   {
      intersection = 0;
      classify_right = FALSE;
      classify_left = FALSE;
      left_side |= EMS_INT_BOUNDARY;
      right_side |= EMS_INT_BOUNDARY;
    }
    else
    {
      *msg_loc = EMS_E_InvalidCase;
      goto wrapup;
    }
   }
   else
   {
    if (classify_right)
    {

     csi.is_valid &= ~EMIS_TANGENT_VALID;

     EMdecideint (msg_loc, FALSE, RIGHT,ts,cs, int_pt, &csi, 
                  &tsi,&right_side);
     EMerr_hndlr (EMis_error (*msg_loc), *msg_loc, EMS_E_Fail, wrapup);
    }

    if (classify_left)
    {
     csi.is_valid &= ~EMIS_TANGENT_VALID;

     EMdecideint (msg_loc, FALSE, LEFT ,ts,cs, int_pt, &csi, 
                  &tsi,&left_side);
     EMerr_hndlr (EMis_error (*msg_loc), *msg_loc, EMS_E_Fail, wrapup);
    }
   }
    break;
  } 
 }
 else /* non cutting intersections */
 {
  left_side = EMS_INT_UNKNOWN;
  right_side = EMS_INT_UNKNOWN;
  proc_int = TRUE;
 }


  if (proc_int)
  {
  if (!ambiguous_case && !((left_side == EMS_INT_UNKNOWN) ||
                          (right_side == EMS_INT_UNKNOWN)))
  {
  if (trim_options & EMS_INTER_BDRYISAREA)
  {
     rightinarea = ((right_side & EMS_INT_LEFT) ? 0 : 1);
     leftinarea = ((left_side & EMS_INT_LEFT) ? 0 : 1);
  }
  else 
  {
      rightinarea = ((right_side & EMS_INT_RIGHT) ? 1 : 0);
      leftinarea = ((left_side & EMS_INT_RIGHT) ? 1 : 0);
  }


   if (rightinarea && !leftinarea)
   {
     intersection = 1;
     cb_temp_props = EMSrelorient_hole_area;
   }
  else if (!rightinarea && leftinarea)
   {
     intersection = 1;
     cb_temp_props = EMSrelorient_area_hole;
   }
  else if (rightinarea && leftinarea)
   cb_temp_props = EMSrelorient_area_area;
  else if (!rightinarea && !leftinarea)
   cb_temp_props = EMSrelorient_hole_hole;

  if ((trim_options & EMS_INTER_STARTPT) &&
      (cb_temp_itype == EMScvint_lfend))
  {
    if (trim_options & EMS_INTER_REMZEROEND)
     intersection = (rightinarea ? 1 : 0);
    else
     intersection = 1;
  }
  else  if ((trim_options & EMS_INTER_STOPPT) &&
      (cb_temp_itype == EMScvint_rtend))
  {
    if (trim_options & EMS_INTER_REMZEROEND)
     intersection = (leftinarea ? 1 : 0);
    else
     intersection = 1;
  }
 }
 else
 {
  intersection = 1;
  cb_temp_props = EMSrelorient_unknown;
 }
}


  if (intersection == 1)
  {
   indx = *no_of_inter;

#if DEBUG
  BScveval (ts, par0[i], 0, (IGRpoint *)pt, &rc);
  EMerr_hndlr (BSERROR(rc), *msg_loc, EMS_E_Fail, wrapup);
  fprintf (stderr, "TS point is %lf %lf \n", pt[0], pt[1]);
  BScveval (cs, par1[i], 0, (IGRpoint *)pt, &rc);
  EMerr_hndlr (BSERROR(rc), *msg_loc, EMS_E_Fail, wrapup);
  fprintf (stderr, "CS point is %lf %lf \n", pt[0], pt[1]);
#endif
   my_inters_par[indx] = par0[i];
   cb_inters_par[indx] = par1[i];
   int_pts[ 3 * indx] = d_inter[ 3 * i];
   int_pts[ 3 * indx + 1] = d_inter[3 * i + 1];
   my_int_type[indx] = my_temp_itype;
   cb_int_type[indx] = cb_temp_itype;
   cb_props[indx] = cb_temp_props;
   ++ (*no_of_inter);
  }
 } /* end for loop */

   
wrapup:
/* Free allocated memory */
 return;
}

IGRint EMcross_prod (tol, v1, v2, val)
IGRdouble *tol, v1[], v2[], *val;
{
 IGRint sign;
/*
 * Increase the collinearity tolerance to take care of
 * curve curve idiosyncracies
 */
 *val = v1[X]*v2[Y] - v1[Y]*v2[X];
 if (*val > (*tol)) sign = POSITIVE;
 else if (*val < -(*tol)) sign = NEGATIVE;
 else
 sign = ZERO;
 return (sign);
}

IGRint EMdot_prod (tol, v1, v2, val)
IGRdouble *tol, v1[], v2[], *val;
{
 IGRint sign;
 *val = v1[X]*v2[X] + v1[Y]*v2[Y];
 if (*val > *tol) sign = POSITIVE;
 else if (*val < -(*tol)) sign =  NEGATIVE;
 else
 sign = ZERO;
 return (sign);
}

static void EMgetkeycurve (msg_loc, csoption, ts, cs ,ns, int_pt, tsi, csi, nsi,
                           consider_test_span)

IGRlong *msg_loc;
IGRboolean csoption; /* cs option
                        Left : Consider the part of cs curve which spans from
                               int point to the end point of the curve
                        right : consider the part of cs curve which spans from
                               int point to the begin point. Hence the tangent
                               vector that will be considered for classification
                               will be in the direction of parametrization
                               for left option and opposite to the direction
                               of parametrization for the right option */

struct IGRbsp_curve *ts,
                    *cs,
                    *ns;
IGRpoint int_pt;
struct EMint_info *tsi,
                  *csi,
                  *nsi;
IGRboolean *consider_test_span;

{
 IGRdouble csdotts,
           csdotns;
 
 IGRdouble colintol;
 IGRboolean bssts;
 BSrc rc;

 extern IGRint EMcross_prod();


 BSEXTRACTPAR (&rc, BSTOLCOLLINVEC, colintol);

 if (!(csi->is_valid & EMIS_TANGENT_VALID))
 {
   if (csi->is_valid & EMIS_PARAMETER_VALID)
   {
   if (cs->order == 2) /* if the order of the cutting span is 2 the tangent
                           vector can be obtained more trivially */
   {
     IGRshort end,
              begin;

     if (csoption == LEFT)
     {
       end = 0;
       begin = 1;
     }
     else if (csoption == RIGHT)
     {
       end = 1;
       begin = 0;
     }
      csi->is_valid |= EMIS_TANGENT_VALID;
      csi->tangent[X] = cs->poles[3*end + X] - cs->poles[3*begin + X];
      csi->tangent[Y] = cs->poles[3*end + Y] - cs->poles[3*begin + Y];
      csi->tangent[Z] = 0.0;
      bssts = BSnorvec (&rc, csi->tangent);
      EMerr_hndlr (!bssts, *msg_loc, EMS_E_Fail, wrapup);
    } 
    else
    {
      IGRboolean reverse;

      reverse = ((csoption == RIGHT) ? 0 : 1); 
           
      EMget_tangent ( msg_loc, cs, &csi->parameter, reverse, csi->tangent);
      EMerr_hndlr (EMis_error(*msg_loc),*msg_loc, EMS_E_Fail, wrapup);
      csi->is_valid |= EMIS_TANGENT_VALID;
     }
    }
   else *msg_loc = EMS_E_InvalidArg;
   }

 if (!(tsi->is_valid & EMIS_TANGENT_VALID))
 {
  if (tsi->is_valid & EMIS_PARAMETER_VALID)
  {
    tsi->is_valid  |= EMIS_TANGENT_VALID;
  
    EMget_tangent (msg_loc, ts, &tsi->parameter, FALSE, tsi->tangent);
    EMerr_hndlr (EMis_error (*msg_loc), *msg_loc,EMS_E_Fail, wrapup);
  }
  else
   *msg_loc = EMS_E_InvalidArg;
 }
 
                   
 if (!(nsi->is_valid & EMIS_TANGENT_VALID))
 {
  if (nsi->is_valid & EMIS_PARAMETER_VALID)
  {
    nsi->is_valid  |= EMIS_TANGENT_VALID;
  
    EMget_tangent (msg_loc, ns, &nsi->parameter, FALSE, nsi->tangent);
    EMerr_hndlr (EMis_error (*msg_loc), *msg_loc, EMS_E_Fail, wrapup);
  }
  else
   *msg_loc = EMS_E_InvalidArg;
 }

 csdotts = tsi->tangent[X] * csi->tangent[X] +
           tsi->tangent[Y] * csi->tangent[Y];
 
 csdotns = csi->tangent[X] * nsi->tangent[X] +
           csi->tangent[Y] * nsi->tangent[Y];

/*
 * If the  negative tangent vector of the test span at the intersection point
 * is nearer to the tangent vector of the cutting span  then consider the
 * test span or else consider the next span.
 * If both are equally near then consider the test span
 */


 if ((csdotns + csdotts) < -colintol)
   *consider_test_span = TRUE; 
 else if ((csdotns + csdotts) > colintol)
   *consider_test_span = FALSE; 
 else
  {
   *msg_loc = EMS_E_InvalidCase;
  }

wrapup:
 return;
}
