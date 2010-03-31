/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include <values.h>
#include <math.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dpstruct.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "igrdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros_c.h"
#include "EMSmsgdef.h"
#include "SKdef.h"
#include "SKinc.h"
#include "bsprepcircp.h"

/*
  DESCRIPTION

    The memory for the output is assumed to be allocated by the caller.
    Since the only geometry being currently handled is lines and arcs,
    the max number of points that can be output is 2.

  RETURN VALUE

    EMS_S_Success - All went well
    EMS_I_NoIntersection - The geometries did not intersect
    EMS_E_Fail - Some failure

  HISTORY

    SS  :  05/07/90  :  Creation
 Sudha  :  07/02/93  :  Modified for BSprototypes ansification
    SCW :  02/13/97  :  included emsmacros_c.h rather than emsmacros.h

*/

#define X 0
#define Y 1
#define Z 2

#define FIRST	0
#define SECOND	1

#define LINE_LINE  0
#define LINE_CV    1
#define CV_CV      2

static IGRdouble tantol = -1;

void SKgeominters (msg, geom1, geom2, approxpt, numpts, pts)
IGRlong *msg;
struct SKgeomselect *geom1, *geom2;
IGRdouble *approxpt;
IGRint *numpts;
IGRpoint *pts;
{
  IGRboolean overlap;
  struct SKgeomselect *ptr;
  IGRushort where1, where2;
  IGRshort prelim_type, sec_type, blksize;
  IGRlong stat_func, msg_loc;
  IGRdouble lentol, par[4], *ctr, *ctr1, *ctr2, rad, rad1, rad2, temp[2];
  IGRpoint *defpts;
  void SK2dlnln(), SK2dlncir(), SK2dcircir();

  *msg = EMS_S_Success;
  stat_func = TRUE;

  EMerr_hndlr (geom1->geomtype == SKnullgeom || geom2->geomtype == SKnullgeom,
   *msg, EMS_E_InvalidArg, ret_end);

  if (geom1->geomtype == SKline)
    {
    if (geom2->geomtype == SKline)
      prelim_type = LINE_LINE;
    else
      prelim_type = LINE_CV;
    }
  else
    {
    if (geom2->geomtype == SKline)
      {
      ptr = geom1;
      geom1 = geom2;
      geom2 = ptr;
      prelim_type = LINE_CV;
      }
    else
      prelim_type = CV_CV;
    }

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  switch (prelim_type)
    {
    case LINE_LINE:
      SK2dlnln (&msg_loc, lentol, &geom1->geom.line.line,
                &geom2->geom.line.line, pts, &where1, &where2);
      EMerr_hndlr (msg_loc == EMS_I_NoIntersection, *msg, msg_loc,
                   ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      sec_type = geom1->geom.line.type;
      if (sec_type == SEMIINFI_LINE)
        {
        EMerr_hndlr (where1 & SK_BEFORE_START, *msg, EMS_I_NoIntersection,
                     ret_end);
        }
      else if (sec_type == BOUNDED_LINE)
        {
        EMerr_hndlr (!(where1 & SK_ON_SEGMENT), *msg, EMS_I_NoIntersection,
         ret_end);
        }

      sec_type = geom2->geom.line.type;
      if (sec_type == SEMIINFI_LINE)
        {
        EMerr_hndlr (where2 & SK_BEFORE_START, *msg, EMS_I_NoIntersection,
         ret_end);
        }
      else if (sec_type == BOUNDED_LINE)
        {
        EMerr_hndlr (!(where2 & SK_ON_SEGMENT), *msg, EMS_I_NoIntersection,
         ret_end);
        }

      *numpts = 1;
      break;

    case LINE_CV:
      defpts = geom2->geom.bspcurve.defpts;
      ctr = defpts[0];
      rad = sqrt (EM2ddistptpts (defpts[0], defpts[1]));
      SK2dlncir (&msg_loc, lentol, &geom1->geom.line.line, ctr, rad,
       numpts, pts[0], pts[1], &where1, &where2);
      EMerr_hndlr (msg_loc == EMS_I_NoIntersection, *msg, msg_loc,
       ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      sec_type = geom1->geom.line.type;
      if (sec_type == SEMIINFI_LINE)
        {
        EMerr_hndlr (where1 & SK_BEFORE_START && where2 & SK_BEFORE_START,
         *msg, EMS_I_NoIntersection, ret_end);
        if (!(where1 & SK_BEFORE_START) && (where2 & SK_BEFORE_START))
          *numpts = 1;
        else if ((where1 & SK_BEFORE_START) && !(where2 & SK_BEFORE_START))
          {
          *numpts = 1;
          OM_BLOCK_MOVE (pts[1], pts[0], 2 * sizeof (IGRdouble));
          }
        }
      else if (sec_type == BOUNDED_LINE)
        {
        EMerr_hndlr (!(where1 & SK_ON_SEGMENT) && !(where2 & SK_ON_SEGMENT),
         *msg, EMS_I_NoIntersection, ret_end);
        if ((where1 & SK_ON_SEGMENT) && !(where2 & SK_ON_SEGMENT))
          *numpts = 1;
        else if (!(where1 & SK_ON_SEGMENT) && (where2 && SK_ON_SEGMENT))
          {
          *numpts = 1;
          OM_BLOCK_MOVE (pts[1], pts[0], 2 * sizeof (IGRdouble));
          }
        }
      break;

    case CV_CV:
      defpts = geom1->geom.bspcurve.defpts;
      ctr1 = defpts[0];
      rad1 = sqrt (EM2ddistptpts (defpts[0], defpts[1]));
      defpts = geom2->geom.bspcurve.defpts;
      ctr2 = defpts[0];
      rad2 = sqrt (EM2ddistptpts (defpts[0], defpts[1]));

      SK2dcircir (&msg_loc, lentol, ctr1, rad1, ctr2, rad2,
       numpts, pts[0], pts[1], &overlap);       
      EMerr_hndlr (msg_loc == EMS_I_NoIntersection, *msg, msg_loc,
       ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      break;
    }
  
  /*
   * If there are two intersection points return the one closest to the
   * approximate point as the first intersection.
   */

  if (*numpts == 2 &&
      EM2ddistptpts (approxpt, pts[0]) > EM2ddistptpts (approxpt, pts[1]))
    {
    blksize = 2 * sizeof (IGRdouble);
    OM_BLOCK_MOVE (pts[0], temp, blksize);
    OM_BLOCK_MOVE (pts[1], pts[0], blksize);
    OM_BLOCK_MOVE (temp, pts[1], blksize);
    }

ret_end:
  EMWRAPUP (*msg, stat_func, "SKgeominters");
  return;
}



void SKhgeominters (msg, saddle_geom, ride_geom1, ride_geom2, approxpt,
                    num_outgeom, outgeom)
IGRlong *msg;
struct SKgeomselect *saddle_geom, *ride_geom1, *ride_geom2;
IGRdouble *approxpt;
IGRint *num_outgeom;
struct SKgeomselect *outgeom;
{
  IGRshort i, j, k, blksize;
  IGRlong stat_func, msg_loc;
  IGRdouble deltas[2], *distvec, *vec, *ptr1, *ptr2, *optr1, *optr2;
  IGRdouble mdist[2], lentol;
  IGRpoint intpts[2], origpt, *defpts, loc_vec;
  IGRvector dumvec;
  IGRint    dist;
  struct SKline *line;
  struct SKbspcurve *bspcurve, *outbspcurve;
  struct SKdistline *distline;
  struct SKgeomselect *ride_geom[2], loc_ride_geom[2];
  enum SKgeomtype saddle_type, ride_type[2];
  static IGRvector zvec = {0,0,1};
  void SKgeominters();
  IGRdouble SK2dmdistptln(), SK2dmdistptcir();

  *msg = EMS_S_Success;
  stat_func = TRUE;

  saddle_type = saddle_geom->geomtype;
  ride_type[FIRST] = ride_geom1->geomtype;
  ride_type[SECOND] = ride_geom2->geomtype;
  ride_geom[FIRST] = ride_geom1;
  ride_geom[SECOND] = ride_geom2;

  EMerr_hndlr (saddle_type == SKnullgeom || ride_type[FIRST] == SKnullgeom ||
   ride_type[SECOND] == SKnullgeom, *msg, EMS_E_InvalidArg, ret_end);

  EMerr_hndlr (ride_type[FIRST] == ride_type[SECOND], *msg,
   EMS_I_NoIntersection, ret_end);

  if (saddle_type == SKline)
    OM_BLOCK_MOVE (saddle_geom->geom.line.line.point1, origpt,
     sizeof (IGRpoint));
  else if (saddle_type == SKbspcurve &&
           saddle_geom->geom.bspcurve.type == CIRCLE_CIR)
    OM_BLOCK_MOVE (saddle_geom->geom.bspcurve.defpts[1], origpt,
     sizeof (IGRpoint));
  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
 
  for (i=FIRST; i<=SECOND; i++)
    {
    if (ride_type[i] == SKvector)
      {
      vec = ride_geom[i]->geom.vector.vec;
      loc_ride_geom[i].geomtype = SKline;
      line = &loc_ride_geom[i].geom.line;
      ptr1 = line->line.point1 = line->pt1;
      ptr2 = line->line.point2 = line->pt2;
      OM_BLOCK_MOVE (origpt, ptr1, sizeof (IGRpoint));
      for (j=0; j<2; j++)
        ptr2[j] = ptr1[j] + vec[j];
      ptr2[Z] = 0.0;
      line->type = SEMIINFI_LINE;
      }
    else if (ride_type[i] == SKdistline)
      {
      distline = &ride_geom[i]->geom.distline;
      distvec = distline->distvec;
      dist = distline->vecdist;
      vec = distline->dirvec;
      loc_ride_geom[i].geomtype = SKline;
      line = &loc_ride_geom[i].geom.line;
      ptr1 = line->line.point1 = line->pt1;
      ptr2 = line->line.point2 = line->pt2;
      for (j=0; j<2; j++)
        {
        ptr1[j] = origpt[j] + dist * distvec[j];
        ptr2[j] = ptr1[j] + vec[j];
        }
      ptr1[Z] = ptr2[Z] = 0.0;
      line->type = INFI_LINE;
      }
    else if (ride_type[i] == SKbspcurve && 
             ride_geom[i]->geom.bspcurve.type == CIRCLE_CIR)
      {
      bspcurve = &ride_geom[i]->geom.bspcurve;
      defpts = bspcurve->defpts;
      for (j=0; j<2; j++)
        deltas[j] = origpt[j] - defpts[0][j];
      loc_ride_geom[i].geomtype = SKbspcurve;
      outbspcurve = &loc_ride_geom[i].geom.bspcurve;
      for (j=0; j<2; j++)
        {
        for (k=0; k<2; k++)
          outbspcurve->defpts[j][k] = bspcurve->defpts[j][k] + deltas[k];
        outbspcurve->defpts[j][Z] = 0.0;
        }
      outbspcurve->type = CIRCLE_CIR;
      }
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
    }

  SKgeominters (&msg_loc, &loc_ride_geom[FIRST], &loc_ride_geom[SECOND],
   approxpt, num_outgeom, intpts);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NoIntersection, *msg, msg_loc, ret_end);

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  for (i=0; i<*num_outgeom; i++)
    {
    if (saddle_type == SKline)
      {
      outgeom[i].geomtype = SKline;
      line = &outgeom[i].geom.line;
      line->type = saddle_geom->geom.line.type;
      ptr1 = line->line.point1 = line->pt1;
      ptr2 = line->line.point2 = line->pt2;
      OM_BLOCK_MOVE (intpts[i], ptr1, sizeof (IGRpoint));
      ptr1[Z] = 0.0;
      for (j=0; j<2; j++)
        {
        loc_vec[j] = ptr1[j] - saddle_geom->geom.line.pt1[j];
        ptr2[j] = saddle_geom->geom.line.pt2[j] + loc_vec[j];
        }
      ptr2[Z] = 0.0;

      mdist[i] = SK2dmdistptln (&msg_loc, lentol, approxpt, ptr1, ptr2,
                  NULL, NULL);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    else
      {
      outgeom[i].geomtype = SKbspcurve;
      outbspcurve = &outgeom[i].geom.bspcurve;
      outbspcurve->type = CIRCLE_CIR;
      bspcurve = &saddle_geom->geom.bspcurve;
      ptr1 = bspcurve->defpts[0];
      ptr2 = bspcurve->defpts[1];
      optr1 = outbspcurve->defpts[0];
      optr2 = outbspcurve->defpts[1];
      for (j=0; j<2; j++)
        {
        loc_vec[j] = intpts[i][j] - origpt[j];
        optr1[j] = ptr1[j] + loc_vec[j];
        optr2[j] = ptr2[j] + loc_vec[j];
        }
      optr1[Z] = optr2[Z] = 0.0;
      outbspcurve->curve.poles = (double *) outbspcurve->poles;
      outbspcurve->curve.knots = outbspcurve->knots;
      outbspcurve->curve.weights = outbspcurve->weights;
      BSprepcircp (&msg_loc, optr1, optr2, zvec, &outbspcurve->curve, dumvec,
                   &dist);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);

      mdist[i] = SK2dmdistptcir (&msg_loc, lentol, approxpt, optr1,
                  sqrt (EM2ddistptpts (optr1, optr2)), NULL);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }

  if (*num_outgeom == 2 && mdist[SECOND] < mdist[FIRST])
    {
    blksize = sizeof (struct SKgeomselect);
    OM_BLOCK_MOVE (&outgeom[FIRST], loc_ride_geom, blksize);
    OM_BLOCK_MOVE (&outgeom[SECOND], &outgeom[FIRST], blksize);
    OM_BLOCK_MOVE (loc_ride_geom, &outgeom[SECOND], blksize);
    }

ret_end:
  EMWRAPUP (*msg, stat_func, "SKhgeominters");
  return;
}



/*
  The output arguments - whereint1 and whereint2 - return a value specified
  in the include SKinc, which indicates the topological position of the
  point on the infinite line. These output arguments may be specified as NULL.
*/
void SK2dlnln (msg, tol, ln1, ln2, intpt, whereint1, whereint2)
IGRlong *msg;
IGRdouble tol;
struct IGRline *ln1, *ln2;
IGRdouble *intpt;
IGRushort *whereint1, *whereint2;
{
  IGRboolean solvedx, solvedy;
  IGRshort numsolved, i, *sptr; 
  IGRdouble *pt1, *pt2, *pt3, *pt4;
  IGRdouble *ptr1, *ptr2;
  IGRdouble m1, m2, k1, k2, dotp;
  IGRdouble lnvec1[2], lnvec2[2], intptvec[2];
  IGRushort SK2dposonln();

  *msg = EMS_S_Success;
  intpt[Z] = 0.;
  pt1 = ln1->point1;
  pt2 = ln1->point2;
  solvedx = solvedy = FALSE;
  numsolved = 0;
  if (fabs (pt1[X] - pt2[X]) < tol)
    {
    intpt[X] = pt1[X];
    solvedx = TRUE;
    numsolved++;
    }
  if (fabs (pt1[Y] - pt2[Y]) < tol)
    {
    intpt[Y] = pt1[Y];
    solvedy = TRUE;
    numsolved++;
    }
  EMerr_hndlr (numsolved == 2, *msg, EMS_E_Degenerate, ret_end);

  pt3 = ln2->point1;
  pt4 = ln2->point2;
  numsolved = 0;
  if (fabs (pt3[X] - pt4[X]) < tol)
    {
    EMerr_hndlr (solvedx, *msg, EMS_I_NoIntersection, ret_end);
    intpt[X] = pt3[X];
    solvedx = TRUE;
    numsolved++;
    }
  if (fabs (pt3[Y] - pt4[Y]) < tol)
    {
    EMerr_hndlr (solvedy, *msg, EMS_I_NoIntersection, ret_end);
    intpt[Y] = pt3[Y];
    solvedy = TRUE;
    numsolved++;
    }
  EMerr_hndlr (numsolved == 2, *msg, EMS_E_Degenerate, ret_end);

  /*
   * Using the formula:
   * (y2 - y) = (y2 - y1) / (x2 - x1) * (x2 - x) or
   * (y2 - y) = m * (x2 - x) or
   * m * x - y + (y2 - m * x2) = 0 or
   * m * x - y + k = 0
   *
   * The lines are parellel if the slopes (tan of the slope angle) are nearly
   * equal.
   */

  if (!solvedx || !solvedy)
    {
    m1 = (pt2[Y] - pt1[Y]) / (pt2[X] - pt1[X]);
    m2 = (pt4[Y] - pt3[Y]) / (pt4[X] - pt3[X]);
    if (tantol < 0.0)
      tantol = tan (EMS_ZEROANGLE_DEG * M_PI / 180.0);
    EMerr_hndlr (fabs (m1 - m2) < tantol, *msg, EMS_I_NoIntersection,
     ret_end);

    k1 = (pt2[Y] - m1 * pt2[X]);
    k2 = (pt4[Y] - m2 * pt4[X]);

    /*
     * The general intersection point can be computed
     */
   
    if (!solvedx)
      intpt[X] = (k2 - k1) / (m1 - m2);
    if (!solvedy)
      intpt[Y] = m1 * intpt[X] + k1;
    }

  /*
   * Information about the topological location of the intersection
   * point on the line(s) can now be derived.
   */

  if (whereint1)
    *whereint1 = SK2dposonln (pt1, pt2, intpt, tol);
  if (whereint2)
    *whereint2 = SK2dposonln (pt3, pt4, intpt, tol);

ret_end:
  return;
} 


/*
  The output arguments - whereint1 and whereint2 - return a value specified
  in the include SKinc, which indicates the topological position of the
  intersection points on the infinite line. These output arguments may be
  specified as NULL.
*/
void SK2dlncir (msg, tol, ln, circntr, cirrad,
                numints, intpt1, intpt2, whereint1, whereint2)
IGRlong *msg;
IGRdouble tol;
struct IGRline *ln;
IGRdouble *circntr, cirrad;
IGRint *numints;
IGRdouble *intpt1, *intpt2;
IGRushort *whereint1, *whereint2;
{
  IGRlong msg_loc;
  IGRdouble *lnpt1, *lnpt2, cntrln_dist, mdistpt[2];
  IGRdouble lnvec[2], ptvec[2];
  IGRdouble dotp, leglen, lnveclen;
  IGRdouble SK2dmdistptln();
  IGRushort SK2dposonln();

  *msg = EMS_S_Success;

  lnpt1 = ln->point1;
  lnpt2 = ln->point2;

  cntrln_dist = SK2dmdistptln (&msg_loc, tol, circntr, lnpt1, lnpt2, mdistpt,
                 NULL);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  if (fabs (cntrln_dist - cirrad) < tol)
    {
    *numints = 1;

    OM_BLOCK_MOVE (mdistpt, intpt1, 2 * sizeof (IGRdouble));
    OM_BLOCK_MOVE (mdistpt, intpt2, 2 * sizeof (IGRdouble));
    intpt1[Z] = intpt2[Z] = 0.0;

    if (whereint1)
      *whereint1 = SK2dposonln (lnpt1, lnpt2, intpt1, tol);
    if (whereint2)
      *whereint2 = SK2dposonln (lnpt1, lnpt2, intpt2, tol);
    }
  else if (cntrln_dist < cirrad)
    {
    *numints = 2;

    lnvec[X] = lnpt2[X] - lnpt1[X];
    lnvec[Y] = lnpt2[Y] - lnpt1[Y];
    lnveclen = sqrt (lnvec[X] * lnvec[X] + lnvec[Y] * lnvec[Y]);
    lnvec[X] /= lnveclen;
    lnvec[Y] /= lnveclen;
    leglen = sqrt (cirrad * cirrad - cntrln_dist * cntrln_dist);

    intpt1[X] = mdistpt[X] + lnvec[X] * leglen;
    intpt1[Y] = mdistpt[Y] + lnvec[Y] * leglen;
    intpt2[X] = mdistpt[X] - lnvec[X] * leglen;
    intpt2[Y] = mdistpt[Y] - lnvec[Y] * leglen;
    intpt1[Z] = intpt2[Z] = 0.0;

    if (whereint1)
      *whereint1 = SK2dposonln (lnpt1, lnpt2, intpt1, tol);
    if (whereint2)
      *whereint2 = SK2dposonln (lnpt1, lnpt2, intpt2, tol);
    }
  else
    {
    *numints = 0;
    *msg = EMS_I_NoIntersection;
    }

ret_end:
  return;
}



/*
  The output argument overlap indicates whether the two circles were
  coincident (within tolerance) or not. It is optional and could be 
  specified as NULL.
*/
void SK2dcircir (msg, tol, circtr1, cirrad1, circtr2, cirrad2,
                 numints, intpt1, intpt2, overlap)
IGRlong *msg;
IGRdouble tol;
IGRdouble *circtr1, cirrad1;
IGRdouble *circtr2, cirrad2;
IGRint *numints;
IGRdouble *intpt1, *intpt2;
IGRboolean *overlap;
{
  IGRlong msg_loc;
  IGRdouble delx, dely, ctrctr_dist, *tptr, td, r1sq, r2sq, ccdsq, d, k;
  IGRdouble diff1, diff2, ctrvec[2], pctrvec[2], xpt[2];

  *msg = EMS_S_Success;
  intpt1[Z] = intpt2[Z] = 0.;
  if (cirrad1 < cirrad2)
    {
    tptr = circtr1; circtr1 = circtr2; circtr2 = tptr;
    td = cirrad1; cirrad1 = cirrad2; cirrad2 = td;
    }

  delx = circtr2[X] - circtr1[X];
  dely = circtr2[Y] - circtr1[Y];
  ctrctr_dist = sqrt (delx * delx + dely * dely);

  diff1 = ctrctr_dist - (cirrad1 + cirrad2);
  diff2 = cirrad1 - (ctrctr_dist + cirrad2);

  if (ctrctr_dist <= tol && fabs (cirrad1 - cirrad2) <= tol)
    {
    *numints = 0;
    *msg = EMS_I_NoIntersection;
    if (overlap)
      *overlap = TRUE;
    }
  else if (diff1 > tol || diff2 > tol)
    {
    *numints = 0;
    *msg = EMS_I_NoIntersection;
    if (overlap)
      *overlap = FALSE;
    }
  else
    {
    ctrvec[X] = delx / ctrctr_dist;
    ctrvec[Y] = dely / ctrctr_dist;

    if (fabs (diff1) <= tol || fabs (diff2) <= tol)
      {
      *numints = 1;
      if (overlap)
        *overlap = FALSE;

      intpt1[X] = circtr1[X] + ctrvec[X] * cirrad1;
      intpt1[Y] = circtr1[Y] + ctrvec[Y] * cirrad1;
      }
    else
      {
      *numints = 2;
      if (overlap)
        *overlap = FALSE;

      r1sq = cirrad1 * cirrad1;
      r2sq = cirrad2 * cirrad2;
      ccdsq = ctrctr_dist * ctrctr_dist;
      d = (ccdsq + r1sq - r2sq) / (2 * ctrctr_dist);
      k = sqrt (r1sq - d * d);
      xpt[X] = circtr1[X] + ctrvec[X] * d;
      xpt[Y] = circtr1[Y] + ctrvec[Y] * d;
      pctrvec[X] = ctrvec[Y];
      pctrvec[Y] = -ctrvec[X];
     
      intpt1[X] = xpt[X] + pctrvec[X] * k;
      intpt1[Y] = xpt[Y] + pctrvec[Y] * k;
      intpt2[X] = xpt[X] - pctrvec[X] * k;
      intpt2[Y] = xpt[Y] - pctrvec[Y] * k;
      }
    }

ret_end:
  return;
}



IGRushort SK2dposonln (lnpt1, lnpt2, pt, tol)
IGRdouble *lnpt1, *lnpt2, *pt, tol;
{
  IGRshort retval;
  IGRdouble dotp, lnvec[2], ptvec[2];

  lnvec[X] = lnpt2[X] - lnpt1[X];
  lnvec[Y] = lnpt2[Y] - lnpt1[Y];

  ptvec[X] = pt[X] - lnpt1[X];
  ptvec[Y] = pt[Y] - lnpt1[Y];
  if (fabs (ptvec[X]) <= tol && fabs (ptvec[Y]) <= tol &&
      sqrt (ptvec[X] * ptvec[X] + ptvec[Y] * ptvec[Y]) < tol)
    retval = SK_AT_START;
  else
    {
    dotp = lnvec[X] * ptvec[X] + lnvec[Y] * ptvec[Y];
    if (dotp < 0.0)
      retval = SK_BEFORE_START;
    else
      {
      ptvec[X] = pt[X] - lnpt2[X];
      ptvec[Y] = pt[Y] - lnpt2[Y];
      if (fabs (ptvec[X]) <= tol && fabs (ptvec[Y]) <= tol &&
          sqrt (ptvec[X] * ptvec[X] + ptvec[Y] * ptvec[Y]) < tol)
        retval = SK_AT_STOP;
      else
        {
        dotp = lnvec[X] * ptvec[X] + lnvec[Y] * ptvec[Y];
        if (dotp > 0.0)
          retval = SK_AFTER_STOP;
        else
          retval = SK_IN_MIDDLE;
        }
      }
    }
  return (retval);
}

/*
  Any of the output arguments (mdistpt or mlnpar) could be NULL. The value
  returned by the function is the minimum distance.
*/

IGRdouble SK2dmdistptln (msg, tol, pt, lnpt1, lnpt2, mdistpt, mlnpar)
IGRlong *msg;
IGRdouble tol, *pt, *lnpt1, *lnpt2, *mdistpt;
IGRdouble *mlnpar;
{
  IGRdouble lnvec[2], ptvec[2];
  IGRdouble lnveclen, crossp, dotp;
  IGRdouble mdist, lentol, mlen, loc_mlnpar;

  *msg = EMS_S_Success;

  lnvec[X] = lnpt2[X] - lnpt1[X];
  lnvec[Y] = lnpt2[Y] - lnpt1[Y];
  lnveclen = sqrt (lnvec[X] * lnvec[X] + lnvec[Y] * lnvec[Y]);
  EMerr_hndlr (lnveclen < tol, *msg, EMS_E_Degenerate, ret_end);

  ptvec[X] = pt[X] - lnpt1[X];
  ptvec[Y] = pt[Y] - lnpt1[Y];

  crossp = ptvec[X] * lnvec[Y] - ptvec[Y] * lnvec[X];
  mdist = fabs (crossp / lnveclen);

  if (mdistpt || mlnpar)
    {
    dotp = lnvec[X] * ptvec[X] + lnvec[Y] * ptvec[Y];
    mlen = dotp / lnveclen;
    loc_mlnpar = mlen / lnveclen;
    if (mdistpt)
      {
      mdistpt[X] = lnpt1[X] + loc_mlnpar * (lnpt2[X] - lnpt1[X]);
      mdistpt[Y] = lnpt1[Y] + loc_mlnpar * (lnpt2[Y] - lnpt1[Y]);
      }
    if (mlnpar)
      *mlnpar = loc_mlnpar;
    }

ret_end:
  return (mdist);
}


/*
  Any of the output arguments (mdistpt or mlnpar) could be NULL. The value
  returned by the function is the minimum distance.
*/

IGRdouble SK2dmdistptcir (msg, tol, pt, ctr, rad, mdistpt)
IGRlong *msg;
IGRdouble tol, *pt, *ctr, rad, *mdistpt;
{
  IGRushort whereint1, whereint2;
  IGRint num, blksize;
  IGRlong msg_loc;
  IGRdouble mdist, c1, c2, *mdistpt_ptr;
  IGRpoint pt1, pt2, intpt1, intpt2, loc_mdistpt;
  struct IGRline ln;
  void SK2dlncir();

  *msg = EMS_S_Success;

  EMerr_hndlr (rad <= tol, *msg, EMS_E_Degenerate, ret_end);

  c1 = pt[X] - ctr[X];
  c2 = pt[Y] - ctr[Y];
  if (sqrt (c1 * c1 + c2 * c2) <= tol)
    {
    *msg = EMS_I_NotUnique;
    mdist = rad;
    mdistpt[X] = ctr[X] + rad;
    mdistpt[Y] = ctr[Y];
    goto ret_end;
    }

  blksize = 2 * sizeof (IGRdouble);
  OM_BLOCK_MOVE (ctr, pt1, blksize);
  OM_BLOCK_MOVE (pt, pt2, blksize);
  ln.point1 = pt1;
  ln.point2 = pt2;
  SK2dlncir (&msg_loc, tol, &ln, ctr, rad, &num, intpt1, intpt2,
   &whereint1, &whereint2);
  EMerr_hndlr (EMSerror (msg_loc) || num != 2, *msg, EMS_E_Fail, ret_end);

  if (mdistpt)
    mdistpt_ptr = mdistpt;
  else
    mdistpt_ptr = loc_mdistpt;
  if (whereint1 & SK_BEFORE_START)
    OM_BLOCK_MOVE (intpt2, mdistpt_ptr, blksize);
  else
    OM_BLOCK_MOVE (intpt1, mdistpt_ptr, blksize);

  c1 = mdistpt_ptr[X] - pt[X];
  c2 = mdistpt_ptr[Y] - pt[Y];
  mdist = sqrt (c1 * c1 + c2 * c2);

ret_end:
  return (mdist);
}


/*
 * This function rotates a 2D-vector by the given angle (can be specified
 * in degrees - 'angle_in_degrees' is set to TRUE - or specified in
 * radians). The output is the rotated 2D-vector.
 */

void SK2dvecrot (vec, angle, angle_in_degrees, rotvec)
IGRdouble *vec, angle;
IGRboolean angle_in_degrees;
IGRdouble *rotvec;
{
  IGRdouble sinval, cosval;

  if (angle_in_degrees)
    angle *= M_PI / 180.0;
  sinval = sin (angle);
  cosval = cos (angle);
  rotvec[X] = vec[X] * cosval - vec[Y] * sinval;
  rotvec[Y] = vec[X] * sinval + vec[Y] * cosval;
  return;
}
