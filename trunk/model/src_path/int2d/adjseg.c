
/* Includes */

#include <stdio.h>
#include <memory.h>
#include <math.h>
#include <alloca.h>
#include <malloc.h>

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWerror.h"

#include "igrtypedef.h"
#include "igr.h"
#include "bs.h"
#include "bsparameters.h"
#include "bsvalues.h"
#include "bsgeom_cvsf.h"

/* Prototypes */

#include "bsrev_cv.h"
#include "bscvcv_int.h"
#include "bscrossp.h"
#include "bscveval_b.h"
#include "bscvarrevc.h"
#include "bsfreecv.h"
#include "bscveval2.h"

#include "PWapi/rngbx.h"
#include "PWapi/partol.h"
#include "PWapi/dotp.h"
#include "PWapi/crossp.h"
#include "PWapi/mkvec.h"
#include "PWapi/ptpargm.h"
#include "PWapi/angle.h"
#include "PWapi/memfunc.h"
#include "PWapi/angtol.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/samepts.h"
#include "PWapi/lenvec.h"
#include "PWapi/adjseg.h"
#include "PWapi/normvec.h"
#include "PWapi/pytocv.h"
#include "PWapi/spangm.h"
#include "PWapi/revvec.h"
#include "PWapi/intcvcv.h"

#define  FW  0
#define  BW  1

static void pull_tangent
(
  PWvector tangent,
  PWpoint  intpt,
  PWpoint  cenvec,
  double   dist,
  PWvector ptangent
);

static int get_pull_direction
(
  double   b_rad,
  PWvector b_cvec,
  PWvector b_vec,
  double   i_rad,
  PWvector i_cvec,
  PWvector i_vec,
  double   tol
);

static void get_pull_rad_and_vec
(
  PWboolean bb_bf_same,
  PWboolean bb_i_same,
  PWboolean bf_i_same,

  int  bb_pull,
  int  bf_pull,
  int  i_pull,

  double b_bwd_rad,
  double b_fwd_rad,
  double irad,
  double minrad,

  double *bb_cvec,

  double *bb_nvec,
  double *bf_nvec,
  double *invec,

  double *pullrad,
  double *cvec
);

static PWboolean are_vecs_same
(
  PWvector vec1,
  PWvector vec2,
  PWvector ndirvec,
  double   angtol,
  double   *angle
);

static void get_right_pull_distances
(
  double *pull_rad1,
  double *pull_rad2
);


PWresult pwClassifyInteractionWithAdjseg
(
  struct PWcvdata      *p_bdata,       /* Boundary data */
  PWboolean            b_reverse,     
  struct PWcvdata      *p_badjdata,
  PWboolean            badj_reverse,
  struct PWcvpt        *p_bpt,         /* Intersection point on Boundary 
                                          data */
 
  struct PWcvdata      *p_idata,       /* Intersection data */
  PWboolean            i_reverse,
  struct PWcvdata      *p_iadjdata, 
  PWboolean            iadj_reverse,
  struct PWcvpt        *p_ipt,         /* Intersection point on Intersection 
                                          data */

  PWvector             dirvec,
  double               lentol,

  enum PWcontaintype   intrels[2]      /* Intersection point classification */
)
{
  PWresult  PWsts=PW_K_Success;
  BSrc      BSmsg=BSSUCC;

  double    b_rad=0, badj_rad=0, i_rad[2], kurv=0.0, val=0.0;
  PWpoint   b_cen, badj_cen, i_cen[2];
  PWvector  b_cvec, badj_cvec;

  PWpoint   points[2], ipoints[4], intpt;

  PWvector  ndirvec;
  PWvector  i_tangents[2], b_tangent, badj_tangent; 
  struct  PWcvparam  badjpar;


  if (dirvec)
    pwNormVec (dirvec, ndirvec);
  else
  {
    ndirvec[X] = ndirvec[Y] = 0.0; ndirvec[Z] = 1.0;
  }

  memset (i_tangents, 0, 2*sizeof (PWvector));
  memset (b_tangent, 0, sizeof (PWvector));
  memset (badj_tangent, 0, sizeof (PWvector));

  memcpy (intpt, p_ipt->pt, sizeof (PWpoint));

  PWsts = pwGetTangentCvdata (p_bdata, &p_bpt->cvparam, (PWboolean)!b_reverse, b_tangent);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  if (badj_reverse)
    pwGetMaxParCvdata (p_badjdata, &badjpar);
  else
    pwGetMinParCvdata (p_badjdata, &badjpar);
  
  PWsts = pwGetTangentCvdata (p_badjdata, &badjpar, badj_reverse, 
                              badj_tangent);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
     
  PWsts = pwGetFwBwTangentsCvdata (p_idata, &p_ipt->cvparam, i_reverse, 
                                   lentol, i_tangents);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  if (p_bdata->datatype == PWcvdata_bspcv && p_bdata->data.p_bspcv->order > 2)
  {
    BScvarrevc (p_bdata->data.p_bspcv, (int) 1, &p_bpt->cvparam.spanpar, 
                MAXDOUBLE, &kurv, &b_rad, &points, &BSmsg);
    OnErrorState (BSERROR(BSmsg), PWsts, SetError(PW_K_Trimming, PW_K_BspMath),
                  wrapup);

    memcpy (b_cen, points[1], sizeof (PWpoint));
    pwMakeVec (points[0], points[1], b_cvec);
  }
  else
  {
    b_rad = MAXDOUBLE;
  }

  if (p_badjdata->datatype == PWcvdata_bspcv && 
      p_badjdata->data.p_bspcv->order > 2)
  {
    BScvarrevc (p_badjdata->data.p_bspcv, (int) 1, &badjpar.spanpar,
                MAXDOUBLE, &kurv, &badj_rad, &points, &BSmsg);
    OnErrorState (BSERROR(BSmsg), PWsts, SetError(PW_K_Trimming, PW_K_BspMath),
                  wrapup);

    memcpy (badj_cen, points[1], sizeof (PWpoint));
    pwMakeVec (points[0], points[1], badj_cvec);
  }
  else
  {
    badj_rad = MAXDOUBLE;
  }

  if (p_idata->datatype == PWcvdata_bspcv && p_idata->data.p_bspcv->order > 2)
  {
    double    ikurv[2];
    PWboolean cusp=FALSE;

    PWsts = pwGetFwBwCurvatureBspcv (p_idata->data.p_bspcv, i_reverse,
              p_ipt->cvparam.spanpar, MAXDOUBLE, ikurv, i_rad, ipoints, &cusp);
    OnErrorState (IsError (PWsts), PWsts, SetError(PW_K_Trimming, PW_K_BspMath),
                  wrapup);

    memcpy (i_cen[0], ipoints[1], sizeof (PWpoint));
    memcpy (i_cen[1], ipoints[3], sizeof (PWpoint));
  }
  else
  {
    i_rad[0] = MAXDOUBLE;
    i_rad[1] = MAXDOUBLE;
  }

  pwClassifyPointWithCurvature (b_tangent, badj_tangent, i_tangents[BW], 
                                i_tangents[FW], b_rad, badj_rad, i_rad[0], 
                                i_rad[1], b_cen, badj_cen, i_cen[0], i_cen[1],
                                intpt, ndirvec, lentol, intrels); 
  OnErrorState (IsError (PWsts), PWsts, SetError(PW_K_Trimming, PW_K_BspMath),
                wrapup);

  pwNormVec (i_tangents[0], i_tangents[0]);
  pwNormVec (i_tangents[1], i_tangents[1]);
  pwNormVec (badj_tangent, badj_tangent);

  if ((pwDotLenTol (i_tangents[FW], badj_tangent, lentol, &val) == 
                                                       PWrelvec_aligned) ||
      (pwDotLenTol (i_tangents[BW], badj_tangent, lentol, &val)== 
                                                       PWrelvec_aligned))
  {
    if(fabs (MAXDOUBLE - i_rad[0]) > 10*lentol || 
       fabs (MAXDOUBLE - badj_rad) > 10*lentol)
    {
      int                 i=0, seg=0, pos;
      struct IGRbsp_curve *p_icv=NULL, *p_bcv=NULL;
      struct PWpoly2d     *p_py=NULL;
      PWboolean           free_data=FALSE, overlap=FALSE; 
   
      
      int  n_int=0; 
      long n_over=0;
      double *p_ipar=NULL, *p_bpar=NULL, *p_iover=NULL, *p_bover=NULL,
             *p_intpts, *p_endpts=NULL;

      if (p_idata->datatype == PWcvdata_bspcv)
        p_icv = p_idata->data.p_bspcv;
      else
      {
        p_py = &p_idata->data.py2d;
        p_icv = (struct IGRbsp_curve *) alloca (sizeof (struct IGRbsp_curve));
        p_icv->poles = (double *) alloca (p_py->num_pts * 3 * sizeof(double));
        p_icv->knots = (double *) alloca ((p_py->num_pts+2) * sizeof(double));
        p_icv->weights = FALSE;

        pwCnvtPy2dToCv (p_py, lentol, p_icv);
      }

      if (p_badjdata->datatype == PWcvdata_bspcv)
      {
        struct PWcvdata data;

        memset (&data, 0, sizeof (struct PWcvdata));
        p_bcv = p_badjdata->data.p_bspcv;
       
        if (p_bcv->num_poles != p_bcv->order)
        {
          
          PWsts = pwGetSpanCvdata (p_badjdata, 
                       badj_reverse ? p_bcv->num_poles -1: p_bcv->order - 1, 
                       &data);
          p_bcv = data.data.p_bspcv;
          free_data = TRUE;
        } 
      }
      else
      {
        struct PWpoly2d  py, *p_bpy=NULL;
        PWpoint2d pts[2];
  
        p_bpy = &p_badjdata->data.py2d;
        py.num_pts = 2; py.p_pts = pts;

        if (badj_reverse)
        {
          memcpy (py.p_pts[0], p_bpy->p_pts[p_bpy->num_pts-2], 
                  sizeof (PWpoint2d));
          memcpy (py.p_pts[1], p_bpy->p_pts[p_bpy->num_pts-1], 
                  sizeof (PWpoint2d));
        }
        else
          memcpy (py.p_pts, p_bpy->p_pts, 2 * sizeof (PWpoint2d));

        p_bcv = (struct IGRbsp_curve *) alloca (sizeof (struct IGRbsp_curve));
        p_bcv->poles = (double *) alloca (py.num_pts * 3 * sizeof(double));
        p_bcv->knots = (double *) alloca ((py.num_pts+2) * sizeof(double));
        p_bcv->weights = FALSE;
        pwCnvtPy2dToCv (&py, lentol, p_bcv);
      }

      BScvcv_int (&BSmsg, p_icv, p_bcv, &n_int, &p_intpts, &p_ipar, &p_bpar,
                  &n_over, &p_endpts, &p_iover, &p_bover);
      OnErrorState (BSERROR (BSmsg), PWsts, 
                    SetError (PW_K_Trimming, PW_K_Internal), loc_wrapup);

      overlap = FALSE;
      for (i=0; i<n_over*2; i++)
      {
        if (pwDistPtPt (&p_endpts[i*3], p_ipt->pt) < lentol) 
        {
          overlap = TRUE;
          if (i%2)
            seg = i-1;
          else
            seg = i+1;

          if (i_reverse)
          {
            if (p_iover[i] < p_iover[seg])
              pos = LEFT;
            else
              pos = RIGHT;
          }
          else
          {
            if (p_iover[i] > p_iover[seg])
              pos = LEFT;
            else
              pos = RIGHT;
          }

          break;
        }
      }

      if (overlap)
        intrels [pos] = PWcontain_on;

    loc_wrapup :

      if (p_ipar) free (p_ipar); if (p_bpar) free (p_bpar);
      if (p_iover) free (p_iover); if (p_bover) free (p_bover);
      if (p_intpts) free (p_intpts); if (p_endpts) free (p_endpts);
      if (free_data) BSfreecv (&BSmsg, p_bcv);  
      if (IsError (PWsts)) goto wrapup;
    }
    else if((fabs (MAXDOUBLE - i_rad[0]) < 10*lentol) && 
            (fabs (MAXDOUBLE - badj_rad) < 10*lentol))
    {
      int pos;

      pos = (pwDotLenTol (i_tangents[FW], badj_tangent, lentol, &val) ==
                                          PWrelvec_aligned) ? RIGHT : LEFT;
      intrels [pos] = PWcontain_on;
    }
  }

wrapup :

  PW_Wrapup (PWsts, "pwClassifyInteractionWithAdjseg");
  return PWsts;
}

PWresult pwGetFwBwTangentsCvdata
(
  struct PWcvdata   *p_cvdata,
  struct PWcvparam  *p_cvpar,
  PWboolean         reversed,
  double            lentol,
  PWvector          tangents[2]
)
{
  PWresult PWsts=PW_K_Success;
  double   dist, partol;

  switch (p_cvdata->datatype)
  {
    case PWcvdata_py2d :

      pwMakeVec2d (p_cvdata->data.py2d.p_pts[p_cvpar->spaninx], 
                   p_cvdata->data.py2d.p_pts[p_cvpar->spaninx+1], 
                   reversed ? tangents[1] : tangents[0]);

      dist = pwDistPtPt2d (p_cvdata->data.py2d.p_pts[p_cvpar->spaninx],
                           p_cvdata->data.py2d.p_pts[p_cvpar->spaninx+1]);
      partol = 1.0 / dist;

      if (p_cvdata->data.py2d.num_pts > 2 &&
          (p_cvpar->spanpar < partol ? p_cvpar->spaninx : 
           ((1.0 - p_cvpar->spanpar) < partol)))
      {
        pwMakeVec2d (p_cvdata->data.py2d.p_pts[p_cvpar->spaninx+1], 
                     p_cvdata->data.py2d.p_pts[p_cvpar->spaninx+2], 
                     reversed ? tangents[0] : tangents[1]);
      }
      else
      {
        if (reversed)
          pwRevVec2d (tangents[1], tangents[0]);
        else
          pwRevVec2d (tangents[0], tangents[1]);
      }

      tangents[0][2] = 0.0; tangents[1][2] = 0.0;

    break;

    case PWcvdata_py :

      pwMakeVec (p_cvdata->data.py.p_pts[p_cvpar->spaninx], 
                 p_cvdata->data.py.p_pts[p_cvpar->spaninx+1], 
                 reversed ? tangents[1] : tangents[0]);

      dist = pwDistPtPt (p_cvdata->data.py.p_pts[p_cvpar->spaninx],
                         p_cvdata->data.py.p_pts[p_cvpar->spaninx+1]);
      partol = 1.0 / dist;

      if (p_cvdata->data.py.num_pts > 2 &&
          (p_cvpar->spanpar < partol ? p_cvpar->spaninx : 
           ((1.0 - p_cvpar->spanpar) < partol)))
      {
        pwMakeVec (p_cvdata->data.py.p_pts[p_cvpar->spaninx+1], 
                   p_cvdata->data.py.p_pts[p_cvpar->spaninx+2], 
                   reversed ? tangents[0] : tangents[1]);
      }
      else
      {
        if (reversed)
          pwRevVec (tangents[1], tangents[0]);
        else
          pwRevVec (tangents[0], tangents[1]);
      }

    break;

    case PWcvdata_bspcv :
    case PWcvdata_gmbspcv:

      partol = pwGetParTolCv (p_cvdata->datatype == PWcvdata_bspcv ? 
                 p_cvdata->data.p_bspcv : p_cvdata->data.p_gmbspcv->bspcv, 
                 lentol); 
      PWsts = pwGetCvFwBwTangents (p_cvdata->datatype == PWcvdata_bspcv ?
                p_cvdata->data.p_bspcv : p_cvdata->data.p_gmbspcv->bspcv, 
                p_cvpar->spanpar, reversed, partol, tangents);
               
    break;

    default :
 
      PWsts = SetError (PW_K_PathwayMath, PW_K_InvalidArg);

    break;
  }

  PW_Wrapup (PWsts, "pwGetFwBwTangentsCvdata");
  return PWsts;
}


PWresult pwGetFwBwCurvatureBspcv
(
  struct IGRbsp_curve *p_cv,
  PWboolean           reversed,
  double              par,
  double              max_disp,
  double              *kurv,
  double              *rad,
  PWpoint             points[4],
  PWboolean           *cusp

)
{
  PWresult PWsts=PW_K_Success;
  BSrc     BSmsg=BSSUCC;
  PWpoint  locpts[2];
  double   zero_tol, tpar;

  BSEXTRACTPAR(&BSmsg,BSTOLCLOSETOZERO,zero_tol);

  BScvarrevc (p_cv, (int) 1, &par, max_disp, &kurv[0], &rad[0], &locpts, &BSmsg);
  OnErrorState (BSERROR(BSmsg), PWsts, SetError(PW_K_Trimming, PW_K_BspMath),
                wrapup);

  if (reversed)
    memcpy (&points[2][0], locpts, 2 * sizeof (PWpoint));
  else
    memcpy (points, locpts, 2 * sizeof (PWpoint));

  BSrev_cv (&BSmsg, p_cv);
  tpar = p_cv->knots[p_cv->num_poles] - par;

  BScvarrevc (p_cv, (int) 1, &tpar, max_disp, &kurv[1], &rad[1], &locpts, 
              &BSmsg);
  BSrev_cv (&BSmsg, p_cv);
  OnErrorState (BSERROR(BSmsg), PWsts, SetError(PW_K_Trimming, PW_K_BspMath),
                wrapup);

  if (reversed)
    memcpy (points, locpts, 2 * sizeof (PWpoint));
  else
    memcpy (&points[2][0], locpts, 2 * sizeof (PWpoint));

  if (pwDistPtPt (points[1], points[3]) > zero_tol)
    *cusp = TRUE;

  if (rad[0] < 0) 
  {
    kurv[0] = 0;
    rad[0] = MAXDOUBLE;
  }

  if (rad[1] < 0) 
  {
    kurv[1] = 0;
    rad[1] = MAXDOUBLE;
  }

wrapup :

  PW_Wrapup (PWsts, "pwGetFwBwCurvatureBspcv");
  return PWsts;
}

enum PWcontaintype get_rel_from_angles1
(
  double  ang1, 
  double  ang2, 
  double  angtol
)
{
  if (fabs (ang1) < angtol)
  {
    if (fabs (ang2) < angtol || fabs (2*M_PI - ang2) < angtol)
    {
      return PWcontain_on;
    }
    else
    {
      return PWcontain_out;
    }
  }
  else if (fabs (2*M_PI - ang1) < angtol)
  {
    if (fabs (ang2) < angtol || fabs (2*M_PI - ang2) < angtol)
    {
      return PWcontain_on;
    }
    else
    {
      return PWcontain_in;
    }
  }
  else
  {
    if (fabs (ang2) < angtol || fabs (2*M_PI - ang2) < angtol ||
        fabs (ang1 - ang2) < angtol)
    {
      return PWcontain_on;
    }
    else if (ang2 > ang1)
    {
      return PWcontain_out;
    }
    else
    {
      return PWcontain_in;
    }
  }
}

void pwClassifyPointWithCurvature
(
  PWvector  b_bwd,
  PWvector  b_fwd,
  PWvector  i_bwd,
  PWvector  i_fwd,

  double    b_bwd_rad,
  double    b_fwd_rad,
  double    i_bwd_rad,
  double    i_fwd_rad,

  PWvector  b_bwd_cen,
  PWvector  b_fwd_cen,
  PWvector  i_bwd_cen,
  PWvector  i_fwd_cen,


  PWpoint   intpt,

  PWvector  dirvec,

  double    lentol,

  enum PWcontaintype  intrels[2]
)
{
  double     minrad=0, maxrad=MAXDOUBLE/10.0, val=0, irad=0;
  double     bb_pull_rad=0, bf_pull_rad=0, i_pull_rad=0;
  double     ang1=0, ang2=0, angtol=0;


  PWvector   ib_cvec, if_cvec, bb_cvec, bf_cvec;
  PWvector   ib_nvec, if_nvec, bb_nvec, bf_nvec, ndirvec;
  PWvector   bb_pull_vec, bf_pull_vec, i_pull_vec;

  PWvector   bbwd, bfwd, ivec;

  int        bb_pull=0, bf_pull=0, i_pull=0, inx=0;

  double     *icvec=NULL, *icen=NULL, *invec=NULL;

  PWboolean  bb_i_same=FALSE, bf_i_same=FALSE, bb_bf_same=FALSE; 

  int        numrels=2; /* 0 - bwd only, 1 - fwd only, 2 - both */


  intrels[LEFT] = intrels[RIGHT] = PWcontain_unknown;

  angtol = pwGetZeroAngTolRad();
  pwNormVec (dirvec, ndirvec);

  pwNormVec (i_bwd, ib_nvec);
  pwNormVec (i_fwd, if_nvec);
  pwNormVec (b_bwd, bb_nvec);
  pwNormVec (b_fwd, bf_nvec);

  bb_bf_same = are_vecs_same(bb_nvec, bf_nvec, ndirvec, angtol, &val);

  if (!bb_bf_same && i_bwd_rad < maxrad && i_fwd_rad < maxrad && 
      b_bwd_rad < maxrad && b_fwd_rad < maxrad)
  {
    if ((fabs (b_bwd_rad - i_bwd_rad) < lentol && 
         fabs (b_fwd_rad - i_fwd_rad) < lentol) || 
        (fabs (b_fwd_rad - i_bwd_rad) < lentol &&
         fabs (b_bwd_rad - i_fwd_rad) < lentol))
    {
      if ((are_vecs_same (bb_nvec, ib_nvec, ndirvec, angtol, &val) &&
           are_vecs_same (bf_nvec, if_nvec, ndirvec, angtol, &val)) ||
          (are_vecs_same (bf_nvec, ib_nvec, ndirvec, angtol, &val) &&
           are_vecs_same (bb_nvec, if_nvec, ndirvec, angtol, &val)) )
      {
        intrels[LEFT]  = PWcontain_on;
        intrels[RIGHT] = PWcontain_on;
        goto wrapup;
      } 
    }
  }

  if (b_bwd_rad <= b_fwd_rad && b_bwd_rad <= i_bwd_rad &&
      b_bwd_rad <= i_fwd_rad)
    minrad = b_bwd_rad;
  else if (b_fwd_rad <= b_bwd_rad && b_fwd_rad <= i_bwd_rad &&
      b_fwd_rad <= i_fwd_rad)
    minrad = b_fwd_rad;
  else if (i_bwd_rad <= b_fwd_rad && i_bwd_rad <= b_fwd_rad &&
      i_bwd_rad <= i_fwd_rad)
    minrad = i_bwd_rad;
  else
    minrad = i_fwd_rad;

  if (i_bwd_rad < maxrad) pwMakeVec (intpt, i_bwd_cen, ib_cvec);
  if (i_fwd_rad < maxrad) pwMakeVec (intpt, i_fwd_cen, if_cvec);
  if (b_bwd_rad < maxrad) pwMakeVec (intpt, b_bwd_cen, bb_cvec);
  if (b_fwd_rad < maxrad) pwMakeVec (intpt, b_fwd_cen, bf_cvec);

  for (inx=numrels == 2 ? 0 : numrels; inx<2; inx++)
  {
    bb_pull = bf_pull = i_pull = 0;
    bb_i_same = FALSE; bf_i_same = FALSE;

    if (inx == 0)
    {
      icen = i_bwd_cen; irad = i_bwd_rad; 
      icvec = ib_cvec; invec = ib_nvec;
    }
    else
    {
      icen = i_fwd_cen; irad = i_fwd_rad; 
      icvec = if_cvec; invec = if_nvec;
    }

    if (fabs (irad - b_bwd_rad) < lentol && fabs (irad - b_fwd_rad) < lentol)
    {
      intrels [inx == 0 ? LEFT : RIGHT] = PWcontain_on;
      continue;
    }

    memcpy (bbwd, b_bwd, sizeof (PWvector));
    memcpy (bfwd, b_fwd, sizeof (PWvector));
    memcpy (ivec, invec, sizeof (PWvector));

    bb_i_same = are_vecs_same(bb_nvec, invec, ndirvec, angtol, &val);
    if (bb_bf_same) 
      bf_i_same = bb_i_same;
    else
      bf_i_same = are_vecs_same(bf_nvec, invec, ndirvec, angtol, &val);
  
    if (bb_bf_same || bb_i_same) 
      bb_pull = get_pull_direction (b_bwd_rad, bb_cvec, bb_nvec, irad, icvec, 
                                    invec, maxrad);
    if (!bb_pull && (bb_bf_same || bf_i_same))
      bf_pull = get_pull_direction (b_fwd_rad, bf_cvec, bf_nvec, irad, icvec, 
                                    invec, maxrad);

    if (irad < maxrad)
    {
      if (!bb_pull && !bf_pull && (bb_i_same || bf_i_same))
        i_pull = 1;
      else if (bb_i_same && bf_i_same)
      {
        if (bb_pull && !bf_pull)
          i_pull = bb_pull;
        else if (bf_pull && !bb_pull)
          i_pull = bf_pull;
        else
          i_pull = 0;
      }
      else
        i_pull = 0;
    }
    else
      i_pull = 0;

/*******
    if ((!bb_pull || !bf_pull) && (irad < maxrad) && (bb_i_same || bf_i_same))
      i_pull = 1;
    else if (bb_pull && !bf_pull && (irad < maxrad) && (bb_i_same && bf_i_same))
      i_pull = bb_pull; 
    else if (bf_pull && !bb_pull && (irad < maxrad) && (bb_i_same && bf_i_same))
      i_pull = bf_pull; 
    else 
      i_pull = 0;
*******/


    if (bb_pull) 
    {
      get_pull_rad_and_vec (bb_bf_same, bb_i_same, bf_i_same, bb_pull, 
                            bf_pull, i_pull, b_bwd_rad, b_fwd_rad, irad, 
                            minrad, bb_cvec, bb_nvec, bf_nvec, invec, 
                            &bb_pull_rad, bb_pull_vec);
    }

    if (bf_pull)
    {
      get_pull_rad_and_vec (bb_bf_same, bf_i_same,  bb_i_same,  bf_pull,
                            bb_pull, i_pull, b_fwd_rad, b_bwd_rad, irad,
                            minrad, bf_cvec, bf_nvec, bb_nvec, invec, 
                            &bf_pull_rad, bf_pull_vec);
    }

    if (i_pull)
    {
      if (bb_pull || bf_pull)
        get_pull_rad_and_vec ((PWboolean)((bb_pull) ? bb_i_same : bf_i_same), 
                              (PWboolean)((bb_pull) ? bf_i_same : bb_i_same),  bb_bf_same, 
                              i_pull, bb_pull ? bb_pull : bf_pull, 
                              bb_pull ? bf_pull : bb_pull, irad,
                              bb_pull ? b_bwd_rad : b_fwd_rad, 
                              bb_pull ? b_fwd_rad : b_bwd_rad, minrad,
                              icvec,  invec, bb_pull ? bb_nvec : bf_nvec, 
                              bb_pull ? bf_nvec : bb_nvec,  &i_pull_rad, 
                              i_pull_vec);
      else
        get_pull_rad_and_vec ((PWboolean)((bb_i_same) ? bb_i_same : bf_i_same),
                              (PWboolean)((bb_i_same) ? bf_i_same : bb_i_same),  bb_bf_same,
                              i_pull, bb_i_same ? bb_pull : bf_pull,
                              bb_i_same ? bf_pull : bb_pull, irad,
                              bb_i_same ? b_bwd_rad : b_fwd_rad,
                              bb_i_same ? b_fwd_rad : b_bwd_rad, minrad,
                              icvec,  invec, bb_i_same ? bb_nvec : bf_nvec,
                              bb_i_same ? bf_nvec : bb_nvec,  &i_pull_rad,
                              i_pull_vec);
 
    }

    if (bb_pull && bf_pull) 
      get_right_pull_distances (&bb_pull_rad, &bf_pull_rad);
    else if (bb_pull && i_pull) 
      get_right_pull_distances (&bb_pull_rad, &i_pull_rad);
    else if (bf_pull && i_pull) 
      get_right_pull_distances (&bf_pull_rad, &i_pull_rad);
    else if (bb_pull)
    {
      if (bb_pull_rad > 0.0) bb_pull_rad = 1.0; 
      else bb_pull_rad = -1.0;  
    }
    else if (bf_pull)
    {
      if (bf_pull_rad > 0.0) bf_pull_rad = 1.0; 
      else bf_pull_rad = -1.0;  
    }
    else if (i_pull)
    {
      if (i_pull_rad > 0.0) i_pull_rad = 1.0; 
      else i_pull_rad = -1.0;  
    }
   
    if (bb_pull) 
      pull_tangent (b_bwd, intpt, bb_pull_vec, bb_pull_rad, bbwd);
    if (bf_pull)
      pull_tangent (b_fwd, intpt, bf_pull_vec, bf_pull_rad, bfwd);
    if (i_pull)
      pull_tangent (invec, intpt, i_pull_vec, i_pull_rad, ivec);

    pwAngle (bbwd, bfwd, ndirvec, &ang1);
    pwAngle (bbwd, ivec, ndirvec, &ang2);
    intrels [inx == 0 ? LEFT : RIGHT] = get_rel_from_angles1 (ang1, ang2, 
                                                                    angtol);
  }

wrapup :

  return ;
}

static int get_pull_direction
(
  double   b_rad, 
  PWvector b_cvec,
  PWvector b_vec,
  double   i_rad,
  PWvector i_cvec,
  PWvector i_vec,
  double   maxrad
)
{
  if (b_rad > maxrad)
    return 0;
  else if (i_rad > maxrad)
    return 1;
  else
  {
    if (pwDot (b_cvec, i_cvec) > 0.0 && pwDot (b_vec, i_vec) > 0.0)
    {
      if (b_rad > i_rad)
        return -1;
      else
        return 1;
    }
    else
      return 1;
  }
}

static PWboolean are_vecs_same
(
  PWvector vec1,
  PWvector vec2,
  PWvector ndirvec,
  double   angtol,
  double   *angle
)
{
  PWresult  PWsts=PW_K_Success;

  /*
   * get the angle between the two vectors and if the angle is with in the
   * specified tolerance return TRUE otherwise FALSE.
   */

  PWsts = pwAngle (vec1, vec2, ndirvec, angle);
  if (IsError (PWsts))
    return FALSE;
  else if (*angle < angtol || fabs (2*M_PI - *angle) < angtol)
    return TRUE;
  else
    return FALSE;
}

static void get_pull_rad_and_vec 
(
  PWboolean bb_bf_same,
  PWboolean bb_i_same,
  PWboolean bf_i_same,

  int  bb_pull,
  int  bf_pull,
  int  i_pull,

  double b_bwd_rad,
  double b_fwd_rad,
  double irad,
  double minrad,

  double *bb_cvec,

  double *bb_nvec,
  double *bf_nvec,
  double *invec,

  double *pullrad,
  PWvector cenvec
)
{
  PWvector nvec;
  double   ang1, ang2, pull_rad, *cvec=NULL; 

  pwCross (bb_nvec, bb_cvec, nvec);
  pwNormVec (nvec, nvec);
  cvec = bb_cvec;

  if (bb_pull == 1)
  {
    if (bb_i_same && bb_bf_same)
    {
      if (bf_pull == 1)
        pull_rad = b_fwd_rad;
      else if (i_pull == 1)
        pull_rad = irad;
      else 
        pull_rad = b_bwd_rad;
    }
    else if (bb_bf_same)
    {
      if (bf_pull == 1)
        pull_rad = b_fwd_rad;
      else
        pull_rad = b_bwd_rad;

      pwAngle (bb_nvec, bb_cvec, nvec, &ang1);
      pwAngle (bb_nvec, invec, nvec, &ang2);
      if (ang2 < ang1)
        cvec = invec;  
    }
    else if (bb_i_same)
    {
      if (i_pull == 1)
        pull_rad = irad;
      else
        pull_rad = b_bwd_rad;

      pwAngle (bb_nvec, bb_cvec, nvec, &ang1);
      pwAngle (bb_nvec, bf_nvec, nvec, &ang2);
      if (ang2 < ang1)
        cvec = bf_nvec;
    }
    else
    {
      pull_rad = b_bwd_rad;
      cvec = bb_cvec;
    }
  }
  else 
  {
    pull_rad = b_bwd_rad;

    if (bb_bf_same && bb_i_same)
    {
      if (bf_pull == 1 || i_pull == 1)
        pull_rad = minrad;
    }
    else if (bb_bf_same)
    {
      if (bf_pull == 1 || i_pull == 1)
        pull_rad = minrad;
      else if (bf_pull == 0)
        pull_rad = -minrad;

      if (pull_rad < 0.0)
      {
        pwAngle (bb_nvec, bb_cvec, nvec, &ang1);
        pwAngle (bb_nvec, invec, nvec, &ang2);
        if (ang2 < ang1)
          cvec = invec;  
      }
    }
    else if (bb_i_same)
    {
      pwRevVec (nvec, nvec);
      pwRevVec (bb_cvec, bb_cvec);
      pwAngle (bb_nvec, bb_cvec, nvec, &ang1);
      pwAngle (bb_nvec, bf_nvec, nvec, &ang2);
      pwRevVec (nvec, nvec);
      pwRevVec (bb_cvec, bb_cvec);
      if (ang2 < ang1)
        cvec = bf_nvec;  
    }

    pull_rad = bb_pull * pull_rad;
  }
 
  *pullrad = 0.5 * pull_rad;
  memcpy (cenvec, cvec, sizeof (PWvector));
}

static void pull_tangent
(
  PWvector tangent,
  PWpoint  intpt,
  PWpoint  cenvec,
  double   dist,
  PWvector ptangent
)
{
  int      i;
  PWvector nvec;
  PWpoint  pt, pt1, pt2;

  pwNormVec (cenvec, nvec);

  for (i=0; i<3; i++)
    pt1[i] = intpt[i] + dist * nvec[i];

  pwNormVec (tangent, nvec);

  for (i=0; i<3; i++)
    pt2[i] = intpt[i] + nvec[i];

  for (i=0; i<3; i++)
    pt[i] = (pt1[i] + pt2[i]) / 2.0;

  pwMakeVec (intpt, pt, ptangent);
}

void pwClassifyPointWithCurvature1
(
  PWvector  b_bwd,
  PWvector  b_fwd,
  PWvector  i_bwd,
  PWvector  i_fwd,

  double    b_bwd_rad,
  double    b_fwd_rad,
  double    i_bwd_rad,
  double    i_fwd_rad,

  PWvector  b_bwd_cen,
  PWvector  b_fwd_cen,
  PWvector  i_bwd_cen,
  PWvector  i_fwd_cen,

  PWpoint   intpt,

  PWvector  dirvec,

  double    lentol,

  PWboolean *is_ib_bwd_same,

  enum PWcontaintype  intrels[2]
)
{
  PWboolean  i_bwd_b_bwd_same=FALSE;
  double     dotp=0.0, minrad, rad;

  int        pull_fwd=0, pull_bwd=0, pull=0, inx;
  PWvector   bbwd, bfwd, ibwd, ifwd, bcvec, icvec, bcvec1, bcvec2;
  double     *bcen=NULL, *icen=NULL, brad, irad, pull_fwd_rad, pull_bwd_rad;

  double     ang, angb, angf, angtol;

  intrels[LEFT] = intrels[RIGHT] = PWcontain_unknown;

  dotp = pwDot (b_bwd, i_bwd);
  if (dotp > lentol) 
    i_bwd_b_bwd_same = TRUE;
  else if (pwDot (b_fwd, i_fwd) > lentol)
    i_bwd_b_bwd_same = TRUE;
  else
    i_bwd_b_bwd_same = FALSE;

  if (b_bwd_rad <= b_fwd_rad && b_bwd_rad <= i_bwd_rad && 
      b_bwd_rad <= i_fwd_rad)
    minrad = b_bwd_rad;
  else if (b_fwd_rad <= b_bwd_rad && b_fwd_rad <= i_bwd_rad && 
      b_fwd_rad <= i_fwd_rad)
    minrad = b_fwd_rad;
  else if (i_bwd_rad <= b_fwd_rad && i_bwd_rad <= b_fwd_rad && 
      i_bwd_rad <= i_fwd_rad)
    minrad = i_bwd_rad;
  else
    minrad = i_fwd_rad;

  minrad /= 2.0;

  for (inx=0; inx<2; inx++)
  {
    if (!inx)
    {
      brad = b_bwd_rad; bcen = b_bwd_cen;
      if (i_bwd_b_bwd_same)
      {
        irad = i_bwd_rad; icen = i_bwd_cen;
      }
      else
      {
        irad = i_fwd_rad; icen = i_fwd_cen;
      }
    }
    else
    {
      brad = b_fwd_rad; bcen = b_fwd_cen;
      if (i_bwd_b_bwd_same)
      {
        irad = i_fwd_rad; icen = i_fwd_cen;
      }
      else
      {
        irad = i_bwd_rad; icen = i_bwd_cen;
      }
    }

    if (fabs (MAXDOUBLE - brad) < lentol)
      pull = 0;
    else if (fabs (MAXDOUBLE - irad) < lentol)
      pull = 1;
    else
    {
      pwMakeVec (intpt, bcen, bcvec);
      pwMakeVec (intpt, icen, icvec);

      if (pwDot (icvec, bcvec) > 0.0)
      {
        if (irad > brad)
          pull = 1;
        else 
          pull = -1;
      }
      else
        pull = 1;
    }

    if (!inx) pull_bwd = pull;
    else pull_fwd = pull;
  } 

  memcpy (bbwd, b_bwd, sizeof (PWvector));
  memcpy (bfwd, b_fwd, sizeof (PWvector));
  memcpy (ibwd, i_bwd, sizeof (PWvector));
  memcpy (ifwd, i_fwd, sizeof (PWvector));

  pwMakeVec (intpt, b_bwd_cen, bcvec1);
  pwMakeVec (intpt, b_fwd_cen, bcvec2);

  if (pwDot (bcvec1, bcvec2) > 0.0 &&
      (pull_bwd == 1 && pull_fwd == 1) || (pull_bwd == -1 && pull_fwd == -1))
  {
    pull_bwd_rad = b_fwd_rad;
    pull_fwd_rad = b_bwd_rad;
  }
  else
  {
    pull_bwd_rad = b_bwd_rad;
    pull_fwd_rad = b_fwd_rad;
  }
 

  if (pull_bwd)
  {
    if (pull_bwd == -1)
      rad = -minrad;
    else
      rad = pull_bwd_rad;

    pull_tangent (b_bwd, intpt, b_bwd_cen, rad, bbwd);
  }
  else if (i_bwd_b_bwd_same ? fabs (MAXDOUBLE - i_bwd_rad) > 10 * lentol :
                              fabs (MAXDOUBLE - i_fwd_rad) > 10 * lentol)
  {
    if (i_bwd_b_bwd_same)
      pull_tangent (i_bwd, intpt, i_bwd_cen, minrad, ibwd);
    else
      pull_tangent (i_fwd, intpt, i_fwd_cen, minrad, ifwd);
  }

  if (pull_fwd)
  {
    if (pull_fwd == -1)
      rad = -minrad;
    else
      rad = pull_fwd_rad;

    pull_tangent (b_fwd, intpt, b_fwd_cen, rad, bfwd); 

  }
  else if (i_bwd_b_bwd_same ? fabs (MAXDOUBLE - i_fwd_rad) > 10 * lentol :
                              fabs (MAXDOUBLE - i_bwd_rad) > 10 * lentol)
  {
    if (i_bwd_b_bwd_same)
      pull_tangent (i_fwd, intpt, i_fwd_cen, minrad, ifwd);
    else
      pull_tangent (i_bwd, intpt, i_bwd_cen, minrad, ibwd);
  }

  angtol = pwGetZeroAngTolRad ();

  pwAngle (bbwd, bfwd, dirvec, &ang);
  pwAngle (bbwd, ibwd, dirvec, &angb);
  intrels [LEFT] = get_rel_from_angles1 (ang, angb, angtol);
  
  pwAngle (bbwd, ifwd, dirvec, &angf);
  intrels [RIGHT] = get_rel_from_angles1 (ang, angf, angtol);

  *is_ib_bwd_same = i_bwd_b_bwd_same;

  return; 
}  

PWresult pwGetFwBwCurvatureBspcv1
(
  struct IGRbsp_curve *p_cv,
  double              par, 
  double              max_disp,
  double              *kurv,
  double              *rad,
  PWpoint             points[4],
  PWboolean           *cusp
  
)
{
  BSrc      rc, BSmsg;
  int       spaninx=0, k=0, inx=0;
  PWresult  PWsts=PW_K_Success;
  PWboolean found=FALSE;
  PWpoint   derv[3], temp, temp2[2];
  double    size=0, size2=0, zero_tol=0, scalar=0, mag;

  /*
   * Extract tolerance
   */
  BSEXTRACTPAR(&rc,BSTOLCLOSETOZERO,zero_tol);

  *cusp = FALSE;
 
  if (!p_cv->rational)
    p_cv->weights = NULL;

  k = p_cv->order;
  OnErrorState (k == 2, PWsts, SetError (PW_K_PathwayMath, PW_K_InvalidArg),
                wrapup);

  spaninx = k - 1;

  if (par >= p_cv->knots[p_cv->num_poles])
  {
    spaninx = p_cv->num_poles - 1;
    found = TRUE;
  }
  
  while (!found && spaninx < p_cv->num_poles)
  {
    if (par < p_cv->knots[spaninx + 1])
      found = TRUE;
    else
      spaninx ++;
  }

  OnErrorState (spaninx >= p_cv->num_poles, PWsts, 
                SetError (PW_K_PathwayMath, PW_K_InvalidArg), wrapup);

  for (inx=0; inx<2; inx++, spaninx++)
  {
    BScveval2 (&BSmsg, k, p_cv->poles, p_cv->weights, p_cv->knots, spaninx, 
               par, derv);
    OnErrorState (BSERROR(BSmsg), PWsts, SetError (PW_K_BspMath, PW_K_Internal), 
                  wrapup);
  
    memcpy (&points[inx*2][0], derv[0], sizeof (PWpoint));
   
    size = derv[1][0] * derv[1][0] + derv[1][1] * derv[1][1] +
           derv[1][2] * derv[1][2];
    size2 = derv[2][0] * derv[2][0] + derv[2][1] * derv[2][1] +
            derv[2][2] * derv[2][2];
    size = sqrt (size);
    size2 = sqrt (size2);
  
    if( size2 < zero_tol )
    {
      kurv[inx] = 0;
      rad[inx] = -1;
    }
    else
    {
      if( size < zero_tol )
      {
        kurv[inx] = -1;   /* this is the case of no curvature */
        rad[inx]  = -1;
      }
      else
      {
        /*
         *  Compute curvature values
         */
        temp[0] = derv[1][1] * derv[2][2] - derv[1][2] * derv[2][1];
        temp[1] = derv[1][2] * derv[2][0] - derv[1][0] * derv[2][2];
        temp[2] = derv[1][0] * derv[2][1] - derv[1][1] * derv[2][0];
  
        size2 = temp[0] * temp[0] + temp[1] * temp[1] + temp[2] * temp[2];
        size2 = sqrt( size2 );
        kurv[inx] = size2 / ( size * size * size );
  
        if( kurv[inx] > zero_tol )
        {
          rad[inx] =  1.0 / kurv[inx];
        }
        else
        {
          rad[inx] = -1;
        }
  
        temp2[0][0] = temp[1] * derv[1][2] - temp[2] * derv[1][1];
        temp2[0][1] = temp[2] * derv[1][0] - temp[0] * derv[1][2];
        temp2[0][2] = temp[0] * derv[1][1] - temp[1] * derv[1][0];
  
        mag = temp2[0][0] * temp2[0][0] + temp2[0][1] * temp2[0][1] + 
              temp2[0][2] * temp2[0][2];
        mag = sqrt(mag);

        if (rad[inx] != -1)
        {
          if (mag < max_disp)
          {
            points[2*inx+1][0] = points[2*inx][0] + rad[inx] * temp2[0][0]/mag;
            points[2*inx+1][1] = points[2*inx][1] + rad[inx] * temp2[0][1]/mag;
            points[2*inx+1][2] = points[2*inx][2] + rad[inx] * temp2[0][2]/mag;
          }
          else
          {
            scalar = rad[inx] * max_disp / mag;
            points[2*inx+1][0] = points[2*inx][0] + scalar * temp2[0][0] / mag;
            points[2*inx+1][1] = points[2*inx][1] + scalar * temp2[0][1] / mag;
            points[2*inx+1][2] = points[2*inx][2] + scalar * temp2[0][2] / mag;
          }
        }
      }
    }

    if (spaninx == k-1 && (par <= p_cv->knots[k-1])) 
    {
      inx = 2; *cusp = FALSE;
    }
    else if (spaninx == (p_cv->num_poles - 1) && 
             (par >= p_cv->knots[p_cv->num_poles])) 
    {
      inx = 2; *cusp = FALSE;
    }
  } 

  if (!*cusp)
  {
    memcpy (&points[2][0], &points[0][0], 2*sizeof (PWpoint));
    kurv[1] = kurv[0]; rad[1] = rad[0];
  }
  else
  {
    if (pwDistPtPt (points[1], points[3]) > zero_tol)
      *cusp = TRUE;
  }

wrapup :

  PW_Wrapup (PWsts, "pwGetFwBwCurvatureBspcv");
  return PWsts;
}

static void get_right_pull_distances
(
  double *pull_rad1, 
  double *pull_rad2
)
{
  if (*pull_rad1 > 0.0 && *pull_rad2 > 0.0)
  {
    if (*pull_rad1 > *pull_rad2)
    {
      *pull_rad1 = 2.0; *pull_rad2 = 1.0;
    }
    else 
    {
      *pull_rad1 = 1.0; *pull_rad2 = 2.0;
    }
  }
  else if(*pull_rad1 < 0.0 && *pull_rad2 < 0.0)
  {
    if (*pull_rad1 < *pull_rad2)
    {
      *pull_rad1 = -2.0; *pull_rad2 = -1.0;
    }
    else
    {
      *pull_rad1 = -1.0; *pull_rad2 = -2.0;
    }
  }
  else 
  {
    if (*pull_rad1 > 0.0)
      *pull_rad1 = 1.0;
    else
      *pull_rad1 = -1.0;

    if (*pull_rad2 > 0.0)
      *pull_rad2 = 1.0;
    else
      *pull_rad2 = -1.0;
  }
}
