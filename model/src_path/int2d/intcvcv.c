/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT

     Determines the  geometric interaction points  between a B-spline curve
     that boundes an area (B-Curve)  and another  B-spline curve (I-Curve).
     The I-Curve is  typically, the  intersection  curve of a surface as it
     interacts with another.
 
  DESCRIPTION

     Given two  B-spline curves, i.e. one B-spline curve that bounds an area
     (B-Curve)  and another B-spline curve (I-Curve), which is typically the
     intersection  curve of a surface, this function outputs all the geomet-
     ric interaction points as it interacts with each other. The  B-Curve is 
     ordered such that it bounds area  on it's right. The I-Curve  does  not 
     bound any area but it's flow direction is significant in that the clas-
     sification of  the  interaction  points  being returned by this will be 
     in terms of this direction.

     A significant output is the  relative containment classification of th-
     ese interaction points.  The  classification  is  in terms  of  how the 
     I-Curve flows with respect  to the area of the B-Curve. That is whether 
     it is IN->OUT, IN->ON, ON->OUT etc.,  where, IN represents inside AREA, 
     OUT represents outside AREA  (or inside HOLE),  ON  represents   on the 
     BOUNDARY.  Thus, there can be 9 possible classes into which the intera-
     ctions fit.

     This function optionally takes in an additional segment for the B and I
     curves respectively,  which  serves to define  the  bounded area in the 
     immediate vicinity of the logical stop point of B Curve  and the way in 
     which the I-Curve  continues  on if it was  part of a succession of the 
     curves.  This input  when present will help return the correct relative 
     orientation when  there is  an  interaction a t the logical stop of the 
     either of the curves. No interaction points  are computed against these 
     adjacent segments.

     The area bounded by the B-Curve depends on the  input  direction vector 
     i.e. viewing vector which differentiates the clockwise and counter-clo-
     ckwise directions, and this is normal to the plane of B-Curve.

     This function is  designed  to be called iteratively over the BS curves 
     that comprise loops (typically closed). For this purpose, the interact-
     ion points at the logical start of these  curves are  ignored.  This is 
     done so that when this function is used to process a loop,  the  vertex 
     point is not processed twice.This behaviour of ignoring the start point
     interaction can be  overriden  by saying ues to the boolean flag in the
     input argument list. Such an override will perhaps be chosen to process 
     the start point interactions in an open loop.

  NOTES

     It may be noted that if the orientation classification is ignored, this
     function behaves like a regular intersection function.

     Care is taken to see that the zero-length tolerance being  passed in is 
     strictly respected.

     If either of the input curves are closed,  the  corresponding 'process_
     start' flag is ignored. This because the start point will get processed
     at the stop point anyway. Also, the adjacent vectors are generated int-
     ernally (any input adjacent vectors are also ignored). Therefore if the  
     caller inputs a closed curve (within the specified lentol), the 'adjvec'
     and 'process_start' arguments should be ignored by the caller.


  ARGUMENTS

     p_bcv           I  Boundary Curve (B-Curve) in B-Spline format.
     b_adjvec        I  Vector defining the segment directly  adjacent  to the 
                        logical stop of the B-Curve in the boundary loop being
                        processed. Could be NULL. (If NULL and the B-Curve it-
                        self forms a closed area, then the  classification  is 
                        correct as all the information is inherent within this
                        curve).
     b_range         I  The min/max range box of the B-Curve. This is input so 
                        that this function does not compute  something already 
                        computed once before,  which will be quite often.  The 
                        justification for this is solely optimization.
     b_reverse       I  Is the B-Curve reversed in direction ? If so, the flow
                        is considered opposite that of the input geometry. But
                        the parameter information returned for the interaction
                        points will still be in  terms of the raw input.  Also 
                        note that the adjacent vector if passed in, applies to
                        the logically flowing stop end of the B-Curve.
     b_process_start I  If set to TRUE, then, if there is an interaction point
                        at the logical start of the B-Curve, return it.

     p_icv           I  Intersection Curve (I-Curve) in B-Spline format.
     i_adjvec        I  Vector defining the segment directly  adjacent  to the
                        logical stop of the I-Curve in the boundary loop being
                        processed. Could be NULL. (If NULL and the B-Curve it-
                        self forms a closed area, then the  classification  is
                        correct as all the information is inherent within this
                        curve).
     i_range         I  The min/max range box of the I-Curve. This is input so
                        that this function does not compute  something already
                        computed once before,  which will be quite often.  The
                        justification for this is solely optimization.
     i_reverse       I  Is the I-Curve reversed in direction ? If so, the flow
                        is considered opposite that of the input geometry. But
                        the parameter information returned for the interaction
                        points will still be in  terms of the raw input.  Also
                        note that the adjacent vector if passed in, applies to
                        the logically flowing stop end of the I-Curve.
     i_process_start I  If set to TRUE, then, if there is an interaction point
                        at the logical start of the I-Curve, return it.

     lentol          I  This value defines the distance within  which 2 points 
                        are said to be coincident.

     p_num_inters    O  The number of interaction points found.  These include 
                        the overlap points. The intersections returned are so-
                        rted on the I-Curve. The overlap regions are the inte-
                        rvening regions between two adjacent points having the
                        classification type : X->ON and ON->Y, where X, Y  are 
                        either IN, OUT or ON. (We should see an  ON->ON  point 
                        only at the ends of the Curves).

     p_cvintpt_list  O  A linked list of PWcvintpt_list structures that conta-
                        in all the information about  the  interaction points. 
                        This structure primarily points to the interaction po-
                        int on I-Curve but also contains the similar informat-
                        ion about this interaction as seen  on  B-Curve.  This 
                        similar information is the 'sibling'  information. The
                        actual points being returned are computed on the resp-
                        ective curves. If this list on input is non-NULL, the 
                        output points are appended to the list. But, note that,
                        'p_num_inters' still reflects only the points found wi-
                        thin this invocation. 
                        SEE also, "PWgmdata.h" and "PWgmint.h" for further ex-
                        planation of the output data-structure.

  RETURN CODE

     This function a code that could be one of the following :

     PW_K_Success  - If everything goes well.
     PW_K_Internal - Any internal failure.
     PW_K_Mixture  - An Informative stuff, saying that there are intersections
                     as well as overlaps.
 
  KEYWORDS

  CAVEATS
 
  HISTORY

     Sanjay                Creation 
     V.Srinivas            Intersection points and overlap points returned by
                           math(BScvcv_int) is checked for nearness to the
                           end points of i-curve and b-curve. If they are 
                           within the lentol, the intersection point is merged
                           with the end point. Written function Push_pts_to_end
                           to do this. At the same time if the distances gene-
			   rated by math(BScvcv_int) is very less the pushing
			   of points to the end points are ignored and proceed-
			   ed for the next.
*/

/* Includes */

#include <stdio.h>
#include <memory.h>
#include <math.h>
#include <malloc.h>

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWerror.h"

#include "igrtypedef.h"
#include "igr.h"
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsvalues.h"

/* Prototypes */

#include "bsbxint.h"
#include "bschgdeppar.h"
#include "bsrev_cv.h"
#include "bscvcv_int.h"
#include "bscrossp.h"
#include "bscveval.h"
#include "bscveval_b.h"
#include "bsorthovec.h"
#include "bscvarrevc.h"
#include "mabcendpts.h"
#include "bsmdistptcv.h"

#include "PWapi/rngbx.h"
#include "PWapi/partol.h"
#include "PWapi/dotp.h"
#include "PWapi/crossp.h"
#include "PWapi/sortvec.h"
#include "PWapi/mkvec.h"
#include "PWapi/ptpargm.h"
#include "PWapi/angle.h"
#include "PWapi/memfunc.h"
#include "PWapi/angtol.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/samepts.h"
#include "PWapi/lenvec.h"
#include "PWapi/sortgmint.h"
#include "PWapi/normvec.h"
#include "PWapi/adjseg.h"
#include "PWapi/revvec.h"

/* Static declarations */

static enum PWtopopostype get_topopos
(
  double     par,
  double     minpar,
  double     maxpar,
  double     partol
);

static PWresult classify_interaction_point_from_curvature
(
  struct IGRbsp_curve    *p_bcv,
  double                 b_par,
  PWvector               *b_tangents,  

  struct IGRbsp_curve    *p_icv,
  double                 i_par,
  PWvector               *i_tangents,

  PWvector               dirvec,
  double                 lentol,

  enum PWcontaintype     intrels[2]
);


static PWresult classify_intersection_point
(
  struct IGRbsp_curve    *p_bcv,
  struct PWadjseg        *p_badjseg,
  PWvector               b_adjvec,
  double                 b_partol,

  struct IGRbsp_curve    *p_icv,
  PWvector               i_adjvec,
  double                 i_partol,

  PWvector               dirvec,
  double                 lentol,

  struct PWcvintpt_list  *p_cvintpt
);

static PWresult classify_overlap_point
(
  struct IGRbsp_curve    *p_bcv,
  struct PWadjseg        *p_badjseg,
  PWvector               b_adjvec,
  double                 b_partol,

  struct IGRbsp_curve    *p_icv,
  PWvector               i_adjvec,
  double                 i_partol,

  PWvector               dirvec,
  double                 lentol,

  int                    int_type,

  struct PWcvintpt_list  *p_cvintpt
);

enum PWcontaintype get_rel_from_angles
(
  double  ang1, 
  double  ang2,
  double  angtol  
);

static struct PWcvintpt_list *get_adjacent_node 
(
  int num_nodes,
  struct PWcvintpt_list *p_list,
  struct PWcvintpt_list *p_node,
  PWboolean left,
  PWboolean sibling,
  PWboolean closed,
  double minpar,
  double maxpar,
  double partol
);

PWresult Push_pts_to_end
(
  BSrc                   *BSmsg,
  struct IGRbsp_curve    *p_icv,
  struct IGRbsp_curve    *p_bcv,
  int                    pn_int, 
  double                 *p_intpts, 
  double                 *p_ipar,
  double                 *p_bpar, 
  double                 lentol 
);

extern PWresult pwGetCvFwBwTangents
(
  struct IGRbsp_curve  *p_cv,
  double               par,
  PWboolean            reverse,
  double               partol,
  PWvector             tangents[2]
);


/* Local Defines */

#define   START_OVERLAP  1
#define   STOP_OVERLAP   2

#define   FW    0
#define   BW    1

PWresult pwCvCvInt
(
  struct IGRbsp_curve    *p_bcv,
  struct PWadjseg        *p_badjseg,
  PWrange                b_range,
  PWboolean              b_reverse,
  PWboolean              b_process_start, 

  struct IGRbsp_curve    *p_icv,
  struct PWadjseg        *p_iadjseg,
  PWrange                i_range,
  PWboolean              i_reverse,
  PWboolean              i_process_start,

  PWvector               dirvec,
  double                 lentol,

  int                    *p_num_inters,
  struct PWcvintpt_list  **p_cvintpt_list
)
{
  /* general variables */
  PWboolean   reset_tol=FALSE; /* indicates, whether to reset the basis tol or
                                  not */
  PWboolean   b_reversed=FALSE, i_reversed = FALSE;
                               /* indicates, whether the input curve is got 
                                  reversed or not. If got reversed, we need
                                  reverse them back again at the end of the
                                  routine. */
            
  double      basis_tol=0;     /* basis tol at the start of this routine */
  int         overlap=FALSE, internal_overlap=FALSE;   

  /* loop variables */
  int         ipt=0,inx=0; /* for each interaction point */

  /* minimum and maximum knot values for the interaction curves */
  double      i_minpar=0, i_maxpar=1.0, b_minpar=0, b_maxpar=1.0;
 
  /* status stuff */
  PWresult    PWsts=PW_K_Success; /* pathway */
  BSrc        BSmsg=BSSUCC;       /*   BS    */
  PWboolean   BSsts=TRUE, i_closed=FALSE, b_closed=FALSE;

  /* curve-curve intersection stuff */
  int         n_int=0, mod_n_int=0;
  long        n_over=0, mod_n_over=0;
  double      *p_intpts=NULL, *p_ipar=NULL, *p_bpar=NULL, *p_endpts=NULL;
  double      *p_iover=NULL, *p_bover=NULL; 

  /* parametric tolerances */
  double      b_partol=0, i_partol=0;
  double      *iadjvec=NULL, *badjvec=NULL; 

  double      *p_tpt=NULL;
  PWpoint     istart, istop, bstart, bstop;
  PWvector    b_adjvec, i_adjvec;

  int b_num_int_atstart=0, i_num_int_atstart=0; 
  int b_inx=0, i_inx=0;

  /* topological position of the interaction points */
  enum PWtopopostype  b_topopos=PWtopopos_unknown, i_topopos=PWtopopos_unknown;

  /* out-going interaction points list */
  struct PWcvintpt_list  *p_list=NULL, *p_node=NULL, *p_overlist=NULL; 
 
  /* 
   * validate the incoming arguments
   */
  if (!p_bcv || !b_range || !p_icv || !i_range || !p_num_inters || 
      !p_cvintpt_list)
    OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_InvalidArg),
                  wrapup);

  /*
   * Initialize the output arguments 
   */
  *p_num_inters = 0;

  /*
   * Trivial Check : Box Box Intersection. If no intersection, get out.
   */
  /*******
  if (!pwIsOverlapRngRng (b_range, i_range)) 
    goto wrapup;
  ******/
  if (!BSbxint (&BSmsg, b_range[0], b_range[1], i_range[0], i_range[1]))
    goto wrapup;

  /*
   * Extract the present basis tolerance and set this basis tol to the input
   * tolerance as BScvcv_int routine checks the overalp against the basis tol.
   * Once we set the basis tol with the input tol, we have to reset it at the
   * end of the function. So, whether there is a need to reset the tolerance 
   * or not is stored in a boolean flag i.e. "reset_tol". 
   */

  BSEXTRACTPAR (&BSmsg, BSTOLBASIS, basis_tol);  
  
  BSchgdeppar (lentol, &BSmsg); 
  OnErrorState (BSERROR(BSmsg), PWsts, SetError(PW_K_Trimming, PW_K_Tolerance), 
                wrapup);

  reset_tol = TRUE;

  /*
   * If the curves need to be reversed, reverse the input curves and once it 
   * is reversed, store a flag which indicates that we have reverse the geo-
   * metry  at the end of this routine so that the original geometry will be 
   * sent back. All this jugglary needs to be done, in order not to allocate 
   * any extra memory for storing the reversed curve geometry.
   */

  if (b_reverse)
  {
    /*
     * As the B-Curve needs to be reversed, reverse the geometry and set the
     * flag "b_reversed" to TRUE.
     */

    BSsts = BSrev_cv (&BSmsg, p_bcv);
    OnErrorState (!BSsts || BSERROR(BSmsg), PWsts, SetError(PW_K_Trimming,
                  PW_K_BspMath), wrapup); 

    b_reversed = TRUE;
  }

  if (i_reverse)
  {
    /*
     * As the I-Curve needs to be reversed, reverse the geometry and set the
     * flag "b_reversed" to TRUE.
     */

    BSsts = BSrev_cv (&BSmsg, p_icv);
    OnErrorState (!BSsts || BSERROR(BSmsg), PWsts, SetError(PW_K_Trimming,
                  PW_K_BspMath), wrapup); 

    i_reversed = TRUE;
  }
  
  /*
   * Get all the interaction points between the two curves. 
   */
  BSsts = BScvcv_int (&BSmsg, p_icv, p_bcv, &n_int, &p_intpts, &p_ipar, 
                      &p_bpar, &n_over, &p_endpts, &p_iover, &p_bover);
  OnErrorState (!BSsts || BSERROR(BSmsg), PWsts, SetError(PW_K_Trimming,
                PW_K_Internal), wrapup); 

 
  if (!n_int && !n_over)
  {
    /* 
     * No interaction points between the B-Curve and I-Curve. Hence,  
     * stop the processing.
     */
 
    goto wrapup;
  }

  /* 
   * for the time-being we error out if there is a combination of intersections
   * and overlaps as these are being rare cases in the system. But the code here
   * handles these situations.
   */
  /*******
  OnErrorState ((n_int && n_over), PWsts, SetInfo(PW_K_Trimming, PW_K_Mixture),
                wrapup); 
  *******/

  /*
   * get the parametric range of the interaction curves.
   */
  i_minpar = p_icv->knots[p_icv->order-1];
  i_maxpar = p_icv->knots[p_icv->num_poles];
  b_minpar = p_bcv->knots[p_bcv->order-1];
  b_maxpar = p_bcv->knots[p_bcv->num_poles];

  /*
   * get the parametric tolerances for the interaction curves.
   */
  b_partol = pwGetParTolCv (p_bcv, lentol);
  i_partol = pwGetParTolCv (p_icv, lentol);

  /*
   * get the start and stop points of I and B curves.
   */
  BSsts = MAbcendpts (&BSmsg, p_bcv, bstart, bstop);
  BSsts = MAbcendpts (&BSmsg, p_icv, istart, istop);

  /* Push the intersection points and overlap points 
   * to end points if they are within
   * lentol away from end points
   */
  PWsts = Push_pts_to_end(&BSmsg, p_icv, p_bcv, n_int, p_intpts, p_ipar, 
                                                           p_bpar,lentol);
  OnErrorState (!BSsts || BSERROR(BSmsg), PWsts, SetError(PW_K_Trimming,
                PW_K_Internal), wrapup); 
  PWsts = Push_pts_to_end(&BSmsg, p_icv, p_bcv,2*n_over, p_endpts, p_iover,
                                                           p_bover,lentol);
  OnErrorState (!BSsts || BSERROR(BSmsg), PWsts, SetError(PW_K_Trimming,
                PW_K_Internal), wrapup); 
  /*
   * Determine whether the input curves are closed or not.
   */
  i_closed = p_icv->phy_closed;
  b_closed = p_bcv->phy_closed;

  /*
   * If the interaction point is at the end of the curve, BScvcv_int ret-
   * urns only one interaction point (that to at start) even if the curve  
   * is closed. This suggests us that, we should do special processing in 
   * case of closed curves, as we want process the interaction points at 
   * both the ends i.e. start and stop ends of the interaction curve.
   *
   * If the interaction curve is closed and there is an interaction point
   * at one end of the curve then,
   *   if (process_start is TRUE)
   *   then 
   *     Make a copy of this interaction point with the parameter set to
   *     MAXPAR and increment the number of intersections.
   *   else
   *     Overwrite this interaction point sucht that it becomes the STOP
   *     point interaction point.
   */
  i_inx = -1; b_inx = -2;
  i_num_int_atstart = 0;
  b_num_int_atstart = 0;

  if ((i_closed || b_closed) && n_int)
  {
    /*
     * One/Both of the curves is/are closed and there are pure intersections 
     * between them. 
     */

    for (ipt=0; ipt < n_int && i_closed; ipt++)
    {
      if (pwIsSamePt (&p_intpts[ipt*3], istart, lentol))
      {
        i_inx = ipt;
        i_num_int_atstart = 1;
        break;
      }
    }

    for (ipt=0; ipt < n_int && b_closed; ipt++)
    {
      if (pwIsSamePt (&p_intpts[ipt*3], bstart, lentol))
      {
        b_inx = ipt;
        b_num_int_atstart = 1;
        break;
      }
    }
  }

  if (i_num_int_atstart && b_num_int_atstart && i_inx == b_inx)
  {
    /*
     * Both the curves are closed. Of the pure intersection points, there is 
     * an interaction point at the start of the I-Curve and is also start of 
     * B-Curve.
     */

    if (i_process_start || b_process_start)
    {
      n_int ++;
      p_ipar   = (double *) realloc (p_ipar, n_int * sizeof(double));
      p_bpar   = (double *) realloc (p_bpar, n_int * sizeof(double));
      p_intpts = (double *) realloc (p_intpts, n_int * sizeof(PWpoint));
      memcpy (&p_intpts[(n_int-1) *3], &p_intpts[i_inx*3], 
              sizeof (PWpoint));
    }

    if (i_process_start && b_process_start)
    {
      /*
       * Start point need to be processed for both the curves and will also
       * become the stop for both the curves. So modify the existing inter-
       * action point as start/start and add one more interaction point for
       * stop/stop.
       */

      p_ipar[i_inx] = i_minpar;  p_bpar[i_inx] = b_minpar;
      p_ipar[n_int-1] = i_maxpar;  p_bpar[n_int-1] = b_maxpar;
    }
    else if (i_process_start)
    {
      /*
       * Start point interactions need to be processed for only I-Curve. So,
       * modify the existing interaction point as start of I-Curve/ stop of 
       * B-Curve and an additional interaction point which says stop/stop.
       */

      p_ipar[i_inx] = i_minpar; p_bpar[i_inx] = b_maxpar;
      p_ipar[n_int-1] = i_maxpar; p_bpar[n_int-1] = b_maxpar;
    }
    else if (b_process_start)
    {
      /*
       * Start point interactions need to be processed for only B-Curve. So,
       * modify the existing interaction point as stop of I-Curve/ start of
       * B-Curve and an additional interaction point which says stop/stop.
       */

      p_ipar[i_inx] = i_maxpar; p_bpar[i_inx] = b_minpar;
      p_ipar[n_int-1] = i_maxpar; p_bpar[n_int-1] = b_maxpar;
    }
    else
    {
      /*
       * Start point interactions should not be processed for both the curves.
       * So, modify the existing interaction point as stop/stop. 
       */

      p_ipar[i_inx] = i_maxpar;  p_bpar[i_inx] = b_maxpar;
    }
  }

  else

  {
    if (i_num_int_atstart)
    {
      /*
       * I-Curve is closed. B-Curve may/may not be closed. If closed the 
       * start point interaction of I-Curve is not the start point for 
       * B-Curve.
       */

      if (i_process_start)
      {
        /*
         * I-Curve start points need to be processed.
         */

        if ((b_closed ? !b_num_int_atstart : 
             ((p_bpar[i_inx]-b_minpar) < b_partol ? b_process_start : TRUE)) ||
            (i_inx != b_inx ? TRUE : b_process_start))
        {
          /*
           * This interaction point is not at the start of the B-Curve OR
           * it is at the start of B-Curve and the start of B-Curve needs
           * to be processed. In which case, modify the existing interac-
           * tion point as start of I-Curve and add an additional intera-
           * ction point which says stop of I-Curve/B-Curve param.
           */

          n_int ++;
          p_ipar   = (double *) realloc (p_ipar, n_int * sizeof(double));
          p_bpar   = (double *) realloc (p_bpar, n_int * sizeof(double));
          p_intpts = (double *) realloc (p_intpts, n_int * sizeof(PWpoint));
          memcpy (&p_intpts[(n_int-1) *3], &p_intpts[i_inx*3], 
                  sizeof (PWpoint));
          p_ipar[i_inx] = i_minpar; 
          p_ipar[n_int-1] = i_maxpar; p_bpar[n_int-1] = p_bpar[i_inx]; 
        }
      }
      else
      {
        /*
         * I-Curve start points should not be processed. So, modify the 
         * existing interaction point as Stop of I-Curve.
         */

        p_ipar[i_inx] = i_maxpar;
      }
    }

    if (b_num_int_atstart)
    {
      /*
       * B-Curve is closed. I-Curve may/may not be closed. If closed the
       * start point interaction of I-Curve is not the start point for
       * I-Curve.
       */

      if (b_process_start)
      {
        /*
         * B-Curve start points need to be processed.
         */

        if ((i_closed ? !i_num_int_atstart : 
             ((p_ipar[b_inx]-i_minpar) < i_partol ? i_process_start : TRUE)) ||
            (b_inx != i_inx ? TRUE : i_process_start))
        {
          /*
           * This interaction point is not at the start of the I-Curve OR
           * it is at the start of I-Curve and the start of I-Curve needs
           * to be processed. In which case, modify the existing interac-
           * tion point as start of B-Curve and add an additional intera-
           * ction point which says stop of B-Curve/I-Curve param.
           */

          n_int ++;
          p_ipar   = (double *) realloc (p_ipar, n_int * sizeof(double));
          p_bpar   = (double *) realloc (p_bpar, n_int * sizeof(double));
          p_intpts = (double *) realloc (p_intpts, n_int * sizeof(PWpoint));
          memcpy (&p_intpts[(n_int-1) *3], &p_intpts[b_inx*3], 
                  sizeof (PWpoint));
          p_bpar[b_inx] = b_minpar; 
          p_bpar[n_int-1] = b_maxpar; p_ipar[n_int-1] = p_ipar[b_inx]; 
        }
      }
      else
      {
        /*
         * B-Curve start points should not be processed. So, modify the 
         * existing interaction point as Stop of B-Curve.
         */

        p_bpar[b_inx] = b_maxpar;
      }
    }
  }

  if (i_closed)
  {
    /*
     * I-Curve is closed. So, the tangent at the start point will be the 
     * adjacent vector for the I-Curve. 
     */

    PWsts = pwGetTangentCv (p_icv, i_minpar, FALSE, i_adjvec);
    OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);

    iadjvec = i_adjvec;
  }
  else
  {
    /*
     * I-Curve is not closed.
     */

    if (p_iadjseg)
    {
      /*
       * Adjacent segment information is supplied. Construct a vector between
       * the stop point of I-Curve and the adjacent point to get the adjacent
       * vector.
       */

      p_tpt = istop; 
      pwMakeVec (p_tpt, p_iadjseg->adjpt, i_adjvec);
      pwNormVec (i_adjvec, i_adjvec);
      iadjvec = i_adjvec;
    }
    else
    {
      /*
       * No adjacent segment info. is available. 
       */

      iadjvec  = NULL;
    }
  }

  if (b_closed)
  {
    /*
     * B-Curve is closed. So, the tangent at the start point will be the 
     * adjacent vector for the B-Curve. 
     */

    PWsts = pwGetTangentCv (p_bcv, b_minpar, FALSE, b_adjvec);
    OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);

    badjvec = b_adjvec;
  }
  else
  {
    /*
     * B-Curve is not closed.
     */

    if (p_badjseg)
    { 
      /*
       * Adjacent segment information is supplied. Construct a vector between
       * the stop point of B-Curve and the adjacent point to get the adjacent
       * vector.
       */

      p_tpt = bstop; 
      pwMakeVec (p_tpt, p_badjseg->adjpt, b_adjvec); 
      pwNormVec (b_adjvec, b_adjvec);
      badjvec = b_adjvec;
    }
    else
    {
      /*
       * No adjacent segment info. is available. 
       */

      badjvec  = NULL;
    }
  }

  /*
   * Store the number of intersections and overlap points. Whenever we throw
   * some interaction point, these variables will be updated.
   */

  mod_n_int = n_int;
  mod_n_over = n_over*2;

  /*
   * Process the pure intersection points.
   */

  for (ipt = 0; ipt < n_int; ipt++)
  {
    /*
     * Initialize the loop variables
     */
    p_node = NULL;

    /*
     * get the topological position of the intersection point
     */
    b_topopos = get_topopos (p_bpar[ipt], b_minpar, b_maxpar, b_partol);
    i_topopos = get_topopos (p_ipar[ipt], i_minpar, i_maxpar, i_partol);


    /*
     * Create a node and post the intersection point info into the node.
     */
    p_node = pwCreateCvintptList (&p_list);
    OnErrorState (!p_node, PWsts, SetError(PW_K_Trimming, PW_K_DynamicMemory),
                wrapup); 

    memcpy (p_node->intpt.cvpt.pt, &p_intpts[ipt*3], 3 * sizeof(double));
    p_node->intpt.cvpt.cvparam.spaninx = 0; 
    p_node->intpt.cvpt.cvparam.spanpar = p_ipar[ipt]; 

    memcpy (p_node->intpt.sibling.pt, &p_intpts[ipt*3], 3 * sizeof(double));
    p_node->intpt.sibling.cvparam.spaninx = 0; 
    p_node->intpt.sibling.cvparam.spanpar = p_bpar[ipt]; 

    /*
     * set the topological position of the intersection point.
     */
    pwSetTopoposCvpt (&p_node->intpt.cvpt, i_topopos);
    pwSetTopoposCvpt (&p_node->intpt.sibling, b_topopos);

    /*
     * classify the intersection point.
     */
    PWsts = classify_intersection_point (p_bcv, b_closed ? NULL : p_badjseg, 
                                         badjvec, b_partol, p_icv, iadjvec, 
                                         i_partol,  dirvec, lentol, p_node); 
    OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);
  }

  /*
   * Process overlap regions.
   */

  p_overlist = pwTailCvintptList (p_list);

  for (ipt = 0; ipt < n_over*2; ipt++)
  {
    p_node = NULL;

    /*
     * get the topological position of the intersection point
     */
    b_topopos = get_topopos (p_bover[ipt], b_minpar, b_maxpar, b_partol);
    i_topopos = get_topopos (p_iover[ipt], i_minpar, i_maxpar, i_partol);

    /*
     * Now create a node and post the interaction point info into the node.
     */
    p_node = pwCreateCvintptList (&p_list);
    OnErrorState (!p_node, PWsts, SetError(PW_K_Trimming, PW_K_DynamicMemory),
                wrapup); 

    memcpy (p_node->intpt.cvpt.pt, &p_endpts[ipt*3], 3 * sizeof(double));
    p_node->intpt.cvpt.cvparam.spaninx = 0; 
    p_node->intpt.cvpt.cvparam.spanpar = p_iover[ipt]; 

    memcpy (p_node->intpt.sibling.pt, &p_endpts[ipt*3], 3 * sizeof(double));
    p_node->intpt.sibling.cvparam.spaninx = 0; 
    p_node->intpt.sibling.cvparam.spanpar = p_bover[ipt]; 

    /*
     * set the topological position of the intersection point.
     */
    pwSetTopoposCvpt (&p_node->intpt.cvpt, i_topopos);
    pwSetTopoposCvpt (&p_node->intpt.sibling, b_topopos);

    /*
     * first check, whether this node is an intermediate overlap node. 
     * If it is so, we can set the rels as ON/ON and continue.
     */
    overlap = (ipt%2) ? STOP_OVERLAP : START_OVERLAP;
    internal_overlap = FALSE;

    for (inx=(overlap == START_OVERLAP) ? 1 : 0; inx<n_over*2; inx+=2)
    {
      if (fabs (p_iover[ipt] - p_iover[inx]) < i_partol ||
          (i_closed && (fabs (fabs(p_iover[ipt] - p_iover[inx]) - 
                        (i_maxpar - i_minpar))) < i_partol))
      {
        internal_overlap = TRUE;
        break;
      }
    }

    if (internal_overlap)
    {
      /*
       * This is an internal overlap point. An overlap point which is 
       * start and stop of two overlap regions will be classified as 
       * internal overlap point. The classification of this overlap 
       * point is always ON/ON.
       */

      pwSetContainCvintpt (&p_node->intpt, LEFT, PWcontain_on);
      pwSetContainCvintpt (&p_node->intpt, RIGHT, PWcontain_on);
    }
    else if (!b_closed && b_topopos == PWtopopos_start)
    {
      /*
       * The boundary curve is not closed and the interaction point is at
       * the start of the B-Curve. So, there is no way can classify this 
       * interaction point i.e. we can only set one of the rels. correctly.
       * Set the other rel as unknown. 
       */

      pwSetContainCvintpt (&p_node->intpt, LEFT, PWcontain_unknown);
      pwSetContainCvintpt (&p_node->intpt, RIGHT, PWcontain_unknown);
      if (overlap == START_OVERLAP)
        pwSetContainCvintpt (&p_node->intpt, RIGHT, PWcontain_on);
      else
        pwSetContainCvintpt (&p_node->intpt, LEFT, PWcontain_on);
    }
    else
    {
      /*
       * Neither this a internal overlap point or the start point interaction
       * on B-Curve. It can be classified without any ambiguity. So, classify
       * it.
       */

      PWsts = classify_overlap_point (p_bcv, b_closed ? NULL : p_badjseg,
                                      badjvec, b_partol, p_icv, iadjvec, 
                                      i_partol, dirvec, lentol, overlap, 
                                      p_node); 
      OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);
    }
  }


  /*
   * Now add the overlap points at the start or stop depending on the process
   * start bit.
   */
  p_overlist = p_overlist ? p_overlist->p_next : p_list;
 
  if (p_overlist && (i_closed || b_closed))
  {
    /*
     * There are some overlap regions between the I and B Curves and one or
     * both the curves are closed.
     */

    PWboolean i_over_atstart=FALSE, i_over_atstop=FALSE;
    PWboolean b_over_atstart=FALSE, b_over_atstop=FALSE;
    struct PWcvintpt_list  *p_inode=NULL, *p_bnode=NULL;

    p_node = p_overlist;

    while (p_node)
    {
      if (i_closed && (!i_over_atstart || !i_over_atstop))
      {
        /*
         * I-Curve is cloesd. Check whether there is any overlap region which
         * starts/stops at the end point of I-Curve (start/stop).
         */

        i_topopos = pwGetTopoposCvpt (&p_node->intpt.cvpt);

        if (i_topopos == PWtopopos_start)
        {
          i_over_atstart = TRUE;
          p_inode = p_node;
        }
        else if (i_topopos == PWtopopos_stop)
        { 
          i_over_atstop = TRUE;
          p_inode = p_node;
        }
      }

      if (b_closed && (!b_over_atstart || !b_over_atstop))
      {
        /*
         * B-Curve is cloesd. Check whether there is any overlap region which
         * starts/stops at the end point of B-Curve (start/stop).
         */

        b_topopos = pwGetTopoposCvpt (&p_node->intpt.sibling);

        if (b_topopos == PWtopopos_start)
        {
          b_over_atstart = TRUE;
          p_bnode = p_node;
        }
        else if (b_topopos == PWtopopos_stop)
        {
          b_over_atstop = TRUE;
          p_bnode = p_node;
        }
      }

      p_node = p_node->p_next;
    }

    if ((i_over_atstart && !i_over_atstop) ||
        (i_over_atstop && !i_over_atstart && i_process_start))
    {
      /*
       * I-Curve is closed. I-Curve start point interactions need to be 
       * processed.  There is an overlap region whose one of the end point 
       * is at the start of I-Curve and another end point is not at the
       * stop of I-Curve OR vice-versa. Add an additional interaction 
       * point which is same as this interaction point, but parametrically
       * it will become the stop point interaction for I-Curve.
       */

      p_node = pwCreateCvintptList (&p_list);
      OnErrorState (!p_node, PWsts, SetError(PW_K_Trimming, PW_K_DynamicMemory),
                  wrapup);

      mod_n_over ++;

      memcpy (&p_node->intpt, &p_inode->intpt, sizeof (struct PWcvintpt));
      if (i_over_atstart)
      {
        pwSetTopoposCvpt (&p_node->intpt.cvpt, PWtopopos_stop);
        p_node->intpt.cvpt.cvparam.spanpar = i_maxpar;
      }
      else 
      {
        pwSetTopoposCvpt (&p_node->intpt.cvpt, PWtopopos_start);
        p_node->intpt.cvpt.cvparam.spanpar = i_minpar;
      }
    }

    if (p_inode != p_bnode && ((b_over_atstart && !b_over_atstop) ||
        (b_over_atstop && !b_over_atstart && b_process_start))) 
    {
      /*
       * B-Curve is closed. B-Curve start point interactions need to be
       * processed. The start of B-Curve is not the start of I-Curve. 
       * There is an overlap region whose one of the end point is at the 
       * start of B-Curve and another end point is not at the stop of 
       * B-Curve OR vice-versa. Add an additional interaction point which 
       * is same as this interaction point, but parametrically it will 
       * become the stop point interaction for B-Curve.
       */

      p_node = pwCreateCvintptList (&p_list);
      OnErrorState (!p_node, PWsts, SetError(PW_K_Trimming, PW_K_DynamicMemory),
                  wrapup);

      mod_n_over ++;

      memcpy (&p_node->intpt, &p_bnode->intpt, sizeof (struct PWcvintpt));
      if (b_over_atstart)
      {
        pwSetTopoposCvpt (&p_node->intpt.sibling, PWtopopos_stop);
        p_node->intpt.sibling.cvparam.spanpar = b_maxpar;
      }
      else
      {
        pwSetTopoposCvpt (&p_node->intpt.sibling, PWtopopos_start);
        p_node->intpt.sibling.cvparam.spanpar = b_minpar;
      }
    }
  }

  if ((b_reversed || i_reversed) && p_list)
  {
    double i_par_plus=0.0, b_par_plus=0.0;

    /*
     * One or both of the input curves are reversed. Regenerate the  span 
     * parameters for the reversed curves as the parametric values should
     * always correspond to the natural geometry of the curve.
     */

    b_par_plus = b_maxpar + b_minpar;
    i_par_plus = i_maxpar + i_minpar;

    p_node = p_list;

    while (p_node)
    {
      if (b_reversed)
      {
        p_node->intpt.sibling.cvparam.spanpar = 
             b_par_plus - p_node->intpt.sibling.cvparam.spanpar;
      }

      if (i_reversed)
      {
        p_node->intpt.cvpt.cvparam.spanpar = 
             i_par_plus - p_node->intpt.cvpt.cvparam.spanpar;
      }

      p_node = p_node->p_next;
    }
  }

  /*
   * Set the Info node property for the interaction points with the start if
   * the "process_start" is set to FALSE.
   */
  p_node = p_list;
  while (p_node)
  {
    /*
     * check, whether this parameter is at the start if asked for DONOT PROCESS
     * START. If it is at the start, then set the property as this node Inform-
     * tive node as it is some thing related to overlap region and process the
     * point.
     */
    
    if ((!b_process_start && 
         pwGetTopoposCvpt (&p_node->intpt.sibling) == PWtopopos_start) ||
        (!i_process_start && 
         pwGetTopoposCvpt (&p_node->intpt.cvpt) == PWtopopos_start)) 
    {
      pwSetInfoNodeCvintptList (p_node);
    }

    p_node = p_node->p_next;
  }


  /*
   * Post the number of intersection nodes info.
   */
  *p_num_inters = mod_n_int + mod_n_over;

  /*
   * Sort the intersection list.
   */
  pwSortCvintptList (&p_list, lentol);

  /*
   * Append this intersection list to the incoming list.
   */  
  pwAppendCvintptList (p_cvintpt_list, p_list);
  p_list = NULL;

wrapup :
  /* 
   * reset the basis tolerance 
   */
  if (reset_tol)
    BSchgdeppar (basis_tol, &BSmsg); 

  /*
   * If at all the input curves got reversed, reverse them again so that the
   * actual input geometrices will be output.
   */
  if (b_reversed)
    BSsts = BSrev_cv (&BSmsg, p_bcv);
  
  if (i_reversed)
    BSsts = BSrev_cv (&BSmsg, p_icv);

  /*
   * Free the memory allocated by BScvcv_int routine 
   */
  if (p_intpts) free (p_intpts);
  if (p_ipar)   free(p_ipar);
  if (p_bpar)   free(p_bpar);
  if (p_endpts) free (p_endpts);
  if (p_iover)  free (p_iover);
  if (p_bover)  free (p_bover);

  /*
   * If there is any failure, free the allocated memory
   */
  if (IsError (PWsts) && p_list) 
    pwFreeCvintptList (p_list);

  PW_Wrapup (PWsts, "pwCvCvInt");
  return PWsts;
}

  /*
   DESCRIPTION

   * This function pushes  the intersection points to end points 
   * if they are within lentol away from end points ---V.Srinivas
   */

PWresult Push_pts_to_end
(
  BSrc                   *BSmsg,
  struct IGRbsp_curve    *p_icv,
  struct IGRbsp_curve    *p_bcv,
  int                    pn_int, 
  double                 *p_intpts, 
  double                 *p_ipar,
  double                 *p_bpar, 
  double                  lentol 
)
{
  int                    ipt,i,ptarray[4];
  IGRshort               k,n;
  IGRdouble              dist[4],*pars=NULL,*intpars=NULL,point_par[4];
  double                 i_minpar=0, i_maxpar=1.0, b_minpar=0, b_maxpar=1.0;
  PWboolean              BSsts,flag;
  PWresult               PWsts=PW_K_Success;
  PWpoint                endpts[4];
  struct IGRbsp_curve    *curve;
  long 			 csrc;
  double		 chdtol, bastol;

  flag = FALSE;
  

/* get end points of the input curves */
  BSsts = MAbcendpts (BSmsg, p_bcv, endpts[0], endpts[1]);
  BSsts = MAbcendpts (BSmsg, p_icv, endpts[2], endpts[3]);


/* out of the four end points 
 * process those end points which are closer to the curves.
 * If none of them are closer then exit. 
 */
  for (i=0;i<4;++i)
  {
   curve = i<2 ? p_icv : p_bcv; 
   BSmdistptcv(curve,endpts[i],&k,&n,&pars,&dist[i],&intpars,BSmsg); 
    OnErrorState (BSERROR(*BSmsg), PWsts, SetError(PW_K_Trimming,
                  PW_K_BspMath), wrapup); 
   if(dist[i]<lentol)
   {
      point_par[i] = n>0 ? *pars : *intpars;
      flag = TRUE;
   }
   ptarray[i] = -1;
   free(pars);
   free(intpars);
  }
  
  if(!flag)
     return(PWsts);
 
/*
 * get the parametric range of the interaction curves.
 */
  i_minpar = p_icv->knots[p_icv->order-1];
  i_maxpar = p_icv->knots[p_icv->num_poles];
  b_minpar = p_bcv->knots[p_bcv->order-1];
  b_maxpar = p_bcv->knots[p_bcv->num_poles];

/* For each intersection point check the nearness. 
 * Once the point is merged, both merged point and the
 * end point are not to be considered further.
 * variable ptarray helps in doing so.
 */
  BSEXTRACTPAR(&csrc, BSTOLBASIS, bastol);
  BSEXTRACTPAR(&csrc, BSTOLCHRDHT, chdtol);

  for (ipt=0; ipt < pn_int; ipt++)
  {
   for (i=0; i<4; ++i)
   {
    if(ptarray[i] == i)
       continue;
    if (pwIsSamePt (&p_intpts[ipt*3], endpts[i], lentol) && dist[i]<lentol && dist[i]>(chdtol * bastol))
    {
        p_intpts[ipt*3] = endpts[i][X];       
        p_intpts[ipt*3+1] = endpts[i][Y];       
        p_intpts[ipt*3+2] = endpts[i][Z];       
        if(i<2)
        {
         p_bpar[ipt] = i==0 ? b_minpar : b_maxpar;
         p_ipar[ipt] = point_par[i];
        }  
        else
        {
         p_ipar[ipt] = i==2 ? i_minpar : i_maxpar;
         p_bpar[ipt] = point_par[i];
        }
        ptarray[i]=i;
        break;
    }
   }
  }
 wrapup:
  return(PWsts);
}



  
/*
  DESCRIPTION

    Given the interaction parameter, bounds of parameter and the parametric
    tolerance it returns 'Topological position' of the interaction point.

  NOTES

    None
*/
  
static enum PWtopopostype get_topopos 
(
  double     par,
  double     minpar,
  double     maxpar,
  double     partol
)
{
  if ((par > maxpar) || (par < minpar))
    return (enum PWtopopostype) PWtopopos_unknown;
  else if ((par - minpar) < partol) 
    return (enum PWtopopostype) PWtopopos_start;
  else if ((maxpar - par) < partol)
    return (enum PWtopopostype) PWtopopos_stop;
  else
    return (enum PWtopopostype) PWtopopos_middle;
}


/*
  DESCRIPTION

    Given an intersection point between the B & I Curves and the curves data, 
    it classifies the relative containment of the intersection point. If the 
    intersection point is at the logical start/stop of the I-Curve and there 
    is adjacent vector info., the corresponding classification will be set 
    as "PWcontain_unknown".
   
  NOTES

    None.
*/

static PWresult classify_intersection_point
(
  struct IGRbsp_curve    *p_bcv,
  struct PWadjseg        *p_badjseg,
  PWvector               b_adjvec,
  double                 b_partol,

  struct IGRbsp_curve    *p_icv,
  PWvector               i_adjvec,
  double                 i_partol,
 
  PWvector               dirvec,
  double                 lentol,

  struct PWcvintpt_list  *p_cvintpt
)
{
  /* Status Stuff */
  PWresult    PWsts=PW_K_Success;

  /* general */
  int         pos=0;
  double      i_par=0.0, b_par=0.0, *badjvec=NULL, *iadjvec=NULL; 
  double      ang1=0.0, ang2=0.0, ang3=0.0, angtol=0.0;
  PWboolean   touching_int=FALSE;

  /* forward and backward tangents */
  PWvector    b_tangents[2], i_tangents[2], ndirvec;

  /* topological position of the intersection point */
  enum PWtopopostype  b_topopos=PWtopopos_unknown, i_topopos=PWtopopos_unknown;

  /* relative containment of the intersection point */
  PWboolean           compute_leftrel=TRUE, compute_rightrel=TRUE;
  enum PWcontaintype  intrels[2];


  angtol = pwGetZeroAngTolRad();
  intrels [LEFT] = intrels[RIGHT] = PWcontain_unknown;

  /*
   * get the normalized direction vector
   */
  pwNormVec (dirvec, ndirvec);
 
  /*
   * get the topological position of the intersection point.
   */
  i_topopos = pwGetTopoposCvpt (&p_cvintpt->intpt.cvpt);
  b_topopos = pwGetTopoposCvpt (&p_cvintpt->intpt.sibling);
 
  /*
   * get forwrad and backward tangents to the intersection and the boundary
   * curves. 
   */
  i_par = p_cvintpt->intpt.cvpt.cvparam.spanpar;

  PWsts = pwGetCvFwBwTangents (p_icv, i_par, FALSE, i_partol, i_tangents);
  OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, PW_K_Internal),
                wrapup);  

  b_par = p_cvintpt->intpt.sibling.cvparam.spanpar;

  PWsts = pwGetCvFwBwTangents (p_bcv, b_par, FALSE, b_partol, b_tangents);
  OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, PW_K_Internal),
                wrapup); 

  /*
   * If the interaction point is at the logical stop of the interaction
   * curve(s) and is supplied with the adjacent segment tangent vector,
   * then this vector needs to considered while classifying the intera-
   * ction point.
   */

  if (b_topopos == PWtopopos_stop && b_adjvec)
    badjvec = b_adjvec;
  else
    badjvec = NULL;

  if (i_topopos == PWtopopos_stop && i_adjvec)
    iadjvec = i_adjvec;
  else
    iadjvec = NULL;

  /*
   * If any of these vectors is degenrate, error out. 
   */
  if (pwLenSqVec (i_tangents[FW]) < MINDOUBLE || 
      pwLenSqVec (i_tangents[BW]) < MINDOUBLE ||
      pwLenSqVec (b_tangents[FW]) < MINDOUBLE ||
      pwLenSqVec (b_tangents[BW]) < MINDOUBLE ||
      (badjvec ? pwLenSqVec (badjvec) < MINDOUBLE : FALSE) ||
      (iadjvec ? pwLenSqVec (iadjvec) < MINDOUBLE : FALSE) )
    OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_Internal), wrapup);

  /*
   * Depending on the topological position of the intersection point, determine
   * whether there is a need to classify the left/right containment or not. 
   */

  if (i_topopos == PWtopopos_start && !p_icv->phy_closed)
  {
    /*
     * Intersection is at the logical start of the I-Curve. So, the LEFT 
     * containment cannot be classified as there is an ambiguity the way
     * the I-Curve flows beyond this point. So, no need to compute the
     * LEFT containment as this will be set as UNKNOWN.
     */
 
    compute_leftrel = FALSE;
  }
  else if (i_topopos == PWtopopos_stop && !p_icv->phy_closed && !i_adjvec)
  {
    /*
     * Intersection at the logical stop of the I-Curve and the I-Curve is  
     * not provided with adjacent segment information. So, the RIGHT con-
     * ainment cannot be classified as there is an ambiguity the way the 
     * I-Curve flows beyond this point. So, set the compute_rightrel to 
     * FALSE as it will be set as UNKNOWN.
     */

    compute_rightrel = FALSE;
  }

  /*
   * Determine whether it is a touching interaction point or a pure interaction
   * point. In case of touching interaction point, we need to take the help of
   * curvature to classify the interaction point.
   */

  pwAngle (badjvec ? badjvec : b_tangents[FW], b_tangents[BW], ndirvec, &ang1);
  if (ang1 <= angtol || fabs (2*M_PI - ang1) <= angtol)
    touching_int = TRUE;

  if (!touching_int && compute_leftrel)
  {
    pwAngle (badjvec ? badjvec : b_tangents[FW], i_tangents[BW], ndirvec, 
             &ang2);
    intrels [LEFT] = get_rel_from_angles (ang1, ang2, angtol);
    if (intrels [LEFT] == PWcontain_on)
      touching_int = TRUE;
  }

  if (!touching_int && compute_rightrel)
  {
    pwAngle (badjvec ? badjvec : b_tangents[FW], 
             iadjvec ? iadjvec : i_tangents[FW], ndirvec, &ang3);
    intrels [RIGHT] = get_rel_from_angles (ang1, ang3, angtol);
    if (intrels [RIGHT] == PWcontain_on)
      touching_int = TRUE;
  }

  if (touching_int)
  {
    if (b_topopos == PWtopopos_stop && p_badjseg)
    {
      struct PWcvdata bdata, idata; 

      bdata.datatype = PWcvdata_bspcv;
      bdata.data.p_bspcv = p_bcv;
      idata.datatype = PWcvdata_bspcv;
      idata.data.p_bspcv = p_icv;

      PWsts = pwClassifyInteractionWithAdjseg (&bdata, FALSE, 
                    p_badjseg->p_cvdata, p_badjseg->reversed,  
                    &p_cvintpt->intpt.sibling, &idata, FALSE,
                    NULL, FALSE, &p_cvintpt->intpt.cvpt, dirvec, 
                    lentol, intrels);
      OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, 
                    PW_K_Internal), wrapup); 

    }
    else
    {
      /*
       * This is a touching intersection. So, need to be classified with the
       * help of curvature.
       */
      PWsts = classify_interaction_point_from_curvature (p_bcv, b_par,
                       b_tangents, p_icv, i_par,  i_tangents,  dirvec, 
                       lentol, intrels);
      OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, 
                    PW_K_Internal), wrapup); 
    }
  }

  if (!compute_leftrel)
  {
    intrels [LEFT] = PWcontain_unknown;
  }

  if (!compute_rightrel)
  {
    intrels [RIGHT] = PWcontain_unknown;
  }

  for (pos=LEFT; pos<=RIGHT; pos++) 
  {
    pwSetContainCvintpt (&p_cvintpt->intpt, pos, intrels[pos]);
  }

wrapup :

  PW_Wrapup(PWsts, "classify_intersection_point");
  return PWsts;
}


/*
  DESCRIPTION

    Given a pure overlap interaction point between the B & I Curves with 
    the adjacent segment info, it classifies the relative containment of 
    the overlap point. The adjacent segment information will be taken 
    into account, only if the overlap point is at the logical stop of the 
    curve. If the interaction happened to be at the logical start/stop 
    without any adjacent segment info, then the respective left/right rels.
    will be set at "PWcontain_unknown". If any curve is closed, then the
    adjacency info. will not be considered as the curve is fully defined. 
  
  NOTES

    None.
*/

static PWresult classify_overlap_point
(
  struct IGRbsp_curve    *p_bcv,
  struct PWadjseg        *p_badjseg,
  PWvector               b_adjvec,
  double                 b_partol,

  struct IGRbsp_curve    *p_icv,
  PWvector               i_adjvec,
  double                 i_partol,
 
  PWvector               dirvec,
  double                 lentol,

  int                    int_pos,

  struct PWcvintpt_list  *p_cvintpt
)
{
  /* Status Stuff */
  PWresult    PWsts=PW_K_Success;

  /* general */
  int         pos=LEFT;
  double      i_par=0.0, b_par=0.0, *badjvec=NULL, *iadjvec=NULL; 
  double      ang1=0.0, ang2=0.0, angtol=0.0;
  PWboolean   touching_int=FALSE;

  /* topological position of the intersection point */
  enum PWtopopostype  b_topopos=PWtopopos_unknown, i_topopos=PWtopopos_unknown;

  /* forward and backward tangents */
  PWvector    b_tangents[2], i_tangents[2], ndirvec;

  /* relative containment of the overlap point */
  enum PWcontaintype  intrels[2];
  

  angtol = pwGetZeroAngTolRad();

  /*
   * get the normalized direction vector.
   */
  pwNormVec (dirvec, ndirvec);
 
  /*
   * get the topological position of the intersection point.
   */
  i_topopos = pwGetTopoposCvpt (&p_cvintpt->intpt.cvpt);
  b_topopos = pwGetTopoposCvpt (&p_cvintpt->intpt.sibling);

  /*
   * Depending on whether the given interaction point represents the START or
   * STOP of an overlap region, set the "ON" for one of the rels and determi-
   * ne which one needs to be computed.
   */

  if (int_pos == START_OVERLAP)
  {
    /*
     * The given interaction point represents the START of an overlap region.
     * So, the RIGHT rel represents ON and we need to compute the LEFT rel.
     */

    pos = LEFT;
  }
  else
  {
    /*
     * The given interaction point represents the STOP of an overlap region.
     * So, the LEFT rel represents ON and we need to compute the RIGHT rel.
     */

    pos = RIGHT;
  }

  /*
   * Limiting cases :
   *   As this interaction point is an overlap, one of the rels is ON and the
   *   other needs to be classified. Following blocks takes care of the over-
   *   laps, which needs to be classified as UNKNOWN. 
   */

  if (i_topopos == PWtopopos_start && !p_icv->phy_closed)
  {
    /*
     * Overlap starting at the logical start of intersection curve. As  it
     * is already clear that the right rel is "ON" as it is being start point 
     * interaction the left rel is "UNKNOWN". So set the properties and return.
     */

    intrels[pos] = PWcontain_unknown;
    goto wrapup;
  }

  else if (i_topopos == PWtopopos_stop && !i_adjvec) 
  {
    /*
     * Overlap ending  at the logical stop of intersection curve and there
     * is no adjacent segment information. As it is already clear that the 
     * left rel is "ON" (overlap) and it is being stop point interaction 
     * without any adjacent segment info, the left rel is "UNKNOWN". So set 
     * the properties and return.
     */

    intrels[pos] = PWcontain_unknown;
    goto wrapup;
  }

  /*
   * get forwrad and backward tangents to the intersection and the boundary
   * curves. 
   */

  i_par = p_cvintpt->intpt.cvpt.cvparam.spanpar;

  PWsts = pwGetCvFwBwTangents (p_icv, i_par, FALSE, i_partol, i_tangents);
  OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, PW_K_Internal),
                wrapup);  

  b_par = p_cvintpt->intpt.sibling.cvparam.spanpar;

  PWsts = pwGetCvFwBwTangents (p_bcv, b_par, FALSE, b_partol, b_tangents);
  OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, PW_K_Internal),
                wrapup);  

  /*
   * If the interaction point is at the logical stop of the interaction
   * curve(s) and is supplied with the adjacent segment tangent vector,
   * then this vector needs to considered while classifying the intera-
   * ction point.
   */

  if (b_topopos == PWtopopos_stop && b_adjvec)
    badjvec = b_adjvec;
  else
    badjvec = NULL;

  if (i_topopos == PWtopopos_stop && i_adjvec)
    iadjvec = i_adjvec;
  else
    iadjvec = NULL;

  /*
   * If any of these vectors is degenrate, error out.
   */

  if (pwLenSqVec (i_tangents[FW]) < MINDOUBLE ||
      pwLenSqVec (i_tangents[BW]) < MINDOUBLE ||
      pwLenSqVec (b_tangents[FW]) < MINDOUBLE ||
      pwLenSqVec (b_tangents[BW]) < MINDOUBLE ||
      (badjvec ? pwLenSqVec (badjvec) < MINDOUBLE : FALSE) ||
      (iadjvec ? pwLenSqVec (iadjvec) < MINDOUBLE : FALSE) )
    OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_Internal), wrapup);

  pwAngle (badjvec ? badjvec : b_tangents[FW], b_tangents[BW], ndirvec, &ang1);
  if (ang1 <= angtol || fabs (2*M_PI - ang1) <= angtol)
    touching_int = TRUE;

  if (!touching_int)
  {
    pwAngle (badjvec ? badjvec : b_tangents[FW], 
          (pos == LEFT) ? i_tangents[BW] : iadjvec ? iadjvec : i_tangents[FW],
          ndirvec, &ang2);
    intrels [pos] = get_rel_from_angles (ang1, ang2, angtol);
    if (intrels [pos] == PWcontain_on)
      touching_int = TRUE;
  }

  if (touching_int)
  {
    if (b_topopos == PWtopopos_stop && p_badjseg)
    {
      struct PWcvdata bdata, idata;

      bdata.datatype = PWcvdata_bspcv;
      bdata.data.p_bspcv = p_bcv;
      idata.datatype = PWcvdata_bspcv;
      idata.data.p_bspcv = p_icv;

      PWsts = pwClassifyInteractionWithAdjseg (&bdata, FALSE,
                    p_badjseg->p_cvdata, p_badjseg->reversed,
                    &p_cvintpt->intpt.sibling, &idata, FALSE,
                    NULL, FALSE, &p_cvintpt->intpt.cvpt, dirvec,
                    lentol, intrels);
      OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming,
                    PW_K_Internal), wrapup);

    }
    else if (b_topopos != PWtopopos_stop)
    {
      /*
       * This is a touching intersection. So, need to be classified with the
       * help of curvature.
       */
  
      PWsts = classify_interaction_point_from_curvature (p_bcv, b_par,
                       b_tangents, p_icv,  i_par,  i_tangents, dirvec, 
                       lentol, intrels);
      OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming,
                      PW_K_Internal), wrapup);
    }
  }

wrapup :

  intrels [pos == LEFT ? RIGHT : LEFT] = PWcontain_on;

  for (pos=LEFT; pos<=RIGHT; pos++) 
  {
    pwSetContainCvintpt (&p_cvintpt->intpt, pos, intrels[pos]);
  }

  PW_Wrapup(PWsts, "classify_overlap_point");
  return PWsts;
}


/*
  DESCRIPTION

    Gets the curve's forward and backward tangents at the given parameter.
    'reverse' represents logical direction of the input curve. 

  NOTES

    All the memory for the output must be allocated by the caller.
*/

PWresult pwGetCvFwBwTangents
(
  struct IGRbsp_curve  *p_cv,
  double               par,
  PWboolean            reverse, 
  double               partol,
  PWvector             tangents[2]
)
{
  BSrc      BSmsg=BSSUCC;
  PWresult  PWsts=PW_K_Success;
  int       n_derv=1;
  PWpoint   left_derv[2], right_derv[2];

  PWboolean  eval_bound=TRUE, boundary=FALSE, endpos = FALSE; 

  if (p_cv->phy_closed)
  {
    if (fabs (p_cv->knots[p_cv->order-1] - par) < partol || 
        fabs (p_cv->knots[p_cv->num_poles] - par) < partol)
      endpos = TRUE;
  }

  if (!endpos)
  {
    /*
     * get the forward and backward tangents to the curve at the given parameter
     */
    BScveval_b (&BSmsg, p_cv, &par, &n_derv, &eval_bound, &boundary, left_derv, 
                right_derv);
    OnErrorState (BSERROR(BSmsg), PWsts, SetError(PW_K_Trimming, PW_K_Internal),
                  wrapup);

    if (!boundary)
    {
      memcpy (right_derv, left_derv, 2 * sizeof(PWpoint));
    }
    pwRevVec (left_derv[1], left_derv[1]);

  }
  else
  {
    par = p_cv->knots[p_cv->order-1];
    pwGetTangentCv (p_cv, par, FALSE, &right_derv[1][0]);
    par = p_cv->knots[p_cv->num_poles];
    pwGetTangentCv (p_cv, par, TRUE, &left_derv[1][0]);
    if (reverse)
    {
      reverse = FALSE;
      memcpy (right_derv[0], right_derv[1], sizeof (PWpoint));
      memcpy (right_derv[1], left_derv[1], sizeof (PWpoint));
      memcpy (left_derv[1], right_derv[0], sizeof (PWpoint));
    }
  }

  memcpy (tangents[0], right_derv[1], sizeof(PWpoint));
  memcpy (tangents[1], left_derv[1],  sizeof(PWpoint));

  if (reverse) /* if need to be reversed, reverse the vectors */
  {
    pwRevVec (tangents[0], tangents[0]);
    pwRevVec (tangents[1], tangents[1]);
  }
    
wrapup: 

  PW_Wrapup (PWsts, "pwGetCvFwBwTangents");
  return PWsts;
}

/*
  DESCRIPTION 

    Given the angle ang1, between the FWD & BWD tangents of the B-Curve and 
    the angle ang2, between the FWD tangnt of B-Curve and FWD/BWD tangent of
    the I-Curve at an interaction, it returns the corresponding rel. contai-
    nment of the interaction point.

  NOTES

    None.
*/

enum PWcontaintype get_rel_from_angles
(
  double  ang1, /* angle between the forward and backward tangents of the 
                   boundary curve */
  double  ang2, /* angle made by the forward tangent of boundary curve with
                   the fwd/bwd tangent of the intersection curve */
  double  angtol
)
{
  if (fabs (ang1) < angtol || fabs (2*M_PI - ang1) < angtol)
  {
    /*
     * Forward and backward tangents of the B-Curve matches. This could be
     * a cusp point on B-Curve or an END interaction point. If it is CUSP,
     * it represents that the next segment of the curve is tangent to the
     * previous segment. If it is a END interaction point, the NEXT segme-
     * nt to the B-Curve is tangential and is moving backward.
     */

    if (fabs (ang2) < angtol || fabs (2*M_PI - ang2) < angtol)
    {
      /*
       * The FWD/BWD vector of I-Curve matches with B-Curve's FWD tangent. 
       * Represents ON condition.
       */

      return PWcontain_on;
    }
    else
    {
      /*
       * The I-Curve tangent does not fall in between the B-Curve tangents, 
       * when moving in anti-clockwise direction from the FWD tangent to the
       * BWD tangent of the B-Curve. Represents IN condition.
       */

      return PWcontain_in;
    }
  }
  else
  {
    if (fabs (ang2) < angtol || fabs (2*M_PI - ang2) < angtol ||
        fabs (ang1 - ang2) < angtol)
    {
      /*
       * The I-Curve tangent matches with the FWD tangent of B-Curve. 
       * Represents ON condition.
       */

      return PWcontain_on;
    }
    else if (ang2 > ang1)
    {
      /*
       * The I-Curve tangent does not fall in between the B-Curve tangents, 
       * when moving in anti-clockwise direction from the FWD tangent to the
       * BWD tangent of the B-Curve. Represents IN condition.
       */

      return PWcontain_in;
    }
    else
    {
      /*
       * The I-Curve tangent falls in between the B-Curve tangents, when 
       * moving in anti-clockwise direction from the FWD tangent to the
       * BWD tangent of the B-Curve. Represents IN condition.
       */

      return PWcontain_out;
    }
  }
}


/*
  DESCRIPTION

    Given the B and I Curves and the parameter values of the touching intera-
    ction point, it classifies the interaction point with the help of radius 
    of curvatures and the center of curvatures of B and I Curves. The flow 
    direction of B-Curve is determined by it's backward tangent. 

  NOTES
 
    b_tangents and i_tangents contains the forward and backward vectors of
    the B and I Curves at the interaction point. 
    
*/

static PWresult classify_interaction_point_from_curvature
(
  struct IGRbsp_curve    *p_bcv,
  double                 b_par,
  PWvector               *b_tangents, 

  struct IGRbsp_curve    *p_icv,
  double                 i_par,
  PWvector               *i_tangents,

  PWvector               dirvec,
  double                 lentol,

  enum PWcontaintype     intrels[2]
)
{
  PWresult  PWsts=PW_K_Success;
  double    kurv[2], i_rad[2], b_rad[2];
  PWpoint   i_points[4], b_points[4], intpt;
  PWboolean cusp=FALSE;
  PWvector  ndirvec;

  pwNormVec (dirvec, ndirvec);

  if (p_bcv->order != 2)
  {
    pwGetFwBwCurvatureBspcv (p_bcv, FALSE, b_par, MAXDOUBLE, kurv, b_rad, 
                             b_points, &cusp);
    OnErrorState (IsError (PWsts), PWsts, SetError(PW_K_Trimming, PW_K_BspMath),
                  wrapup);
    memcpy (intpt, b_points[0], sizeof (PWpoint));
  }
  else
  {
    b_rad[0] = MAXDOUBLE;
    b_rad[1] = MAXDOUBLE;
  }

  if (p_icv->order != 2)
  {
    pwGetFwBwCurvatureBspcv (p_icv, FALSE, i_par, MAXDOUBLE, kurv, i_rad,
                             i_points, &cusp);
    OnErrorState (IsError (PWsts), PWsts, SetError(PW_K_Trimming, PW_K_BspMath),
                  wrapup);
    memcpy (intpt, i_points[0], sizeof (PWpoint));
  }
  else
  {
    i_rad[0] = MAXDOUBLE;
    i_rad[1] = MAXDOUBLE;
  }

  pwClassifyPointWithCurvature (b_tangents[BW], b_tangents[FW], i_tangents[BW],
                                i_tangents[FW], b_rad[0], b_rad[1], i_rad[0],
                                i_rad[1], b_points[1], b_points[3], i_points[1],
                                i_points[3], intpt, ndirvec, lentol, intrels);

wrapup : 

  PW_Wrapup (PWsts, "classify_interaction_point_from_curvature");
  return PWsts;
}


/*
  DESCRIPTION

    Returns the interaction point adjacent (parametrically) to the given 
    interaction point. Adjacency direction can be defined by a boolean 
    flag 'left'. In case of a closed curve the adjacent interaction returned
    does not necessarily has it's parameter less or greater than the given
    interapoint parameter depending on the boolean flag left being TRUE or
    FALSE. 

  NOTES

    Returns NULL, if no interaction point is found.
*/

static struct PWcvintpt_list *get_adjacent_node
(
  int num_nodes,
  struct PWcvintpt_list *p_list,
  struct PWcvintpt_list *p_node,
  PWboolean left,
  PWboolean sibling,
  PWboolean closed,
  double minpar,
  double maxpar,
  double partol
)
{
  int i=0, j=0;
  double par=0, adjpar=0, nodepar=0;
  PWboolean found=FALSE;
  struct PWcvpt *p_cvpt=NULL;
  struct PWcvintpt_list *p_adj_node=NULL, *p_tnode=NULL;
  enum PWtopopostype topopos=PWtopopos_unknown; 

  p_cvpt  = sibling ? &p_node->intpt.sibling : &p_node->intpt.cvpt;
  topopos = pwGetTopoposCvpt (p_cvpt);
  nodepar = p_cvpt->cvparam.spanpar;

  for (i=0; i < (closed ? 2:1); i++)
  {
    p_tnode = p_list;
    p_adj_node = NULL;

    if (left && topopos == PWtopopos_start && closed)
    {
      nodepar = maxpar;
      i++;
    }
    else if (!left && topopos == PWtopopos_stop && closed)
    {
      nodepar = minpar;
      i++;
    }

    for (j=0, p_tnode=p_list; j<num_nodes; j++, p_tnode=p_tnode->p_next)
    {
      if (p_tnode == p_node)
        continue;

      par = sibling ? p_tnode->intpt.sibling.cvparam.spanpar :
                      p_tnode->intpt.cvpt.cvparam.spanpar ;
      found = FALSE;

      if (left ? (nodepar - par) >= (-partol) : (nodepar - par) <= partol)
      {
        if (!p_adj_node)
          found = TRUE;
        else if (left ? (par - adjpar) <= partol : (par - adjpar) >= (-partol)) 
          found = TRUE;
      }

      if (found)
      {
        adjpar  = par;
        p_adj_node = p_tnode;
      }
    }

    if (!i && closed && !p_adj_node)
    {
      if (left)
        nodepar = maxpar;
      else
        nodepar = minpar;
    }
  }

  return p_adj_node;
}

