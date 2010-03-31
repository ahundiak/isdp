/* Includes */

#include <stdio.h>
#include <math.h>
#include <memory.h>               /* SYSTEM */
#include <alloca.h>
#include <malloc.h>

#include "OMminimum.h"            /* OM */
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "bs.h"                   /* BS */
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bsvalues.h"

#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSstruct.h"

#include "emsdef.h"               /* MODEL */
#include "emsedgedef.h"
#include "EMSprop.h"

#include "PWminimum.h"            
#include "PWerror.h"              /* Pathway */
#include "PWgmdata.h"
#include "PWattrib.h"

/* Prototypes */

#include "bstagsort.h"
#include "bsmergesort.h"
#include "bscvtgeomcv.h"
#include "bssftgeomsf.h"

#include "PWapi/lpcons.h"        
#include "PWapi/ptpargm.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/degengm.h"
#include "PWapi/dotp.h"
#include "PWapi/mkvec.h"
#include "PWapi/normvec.h"       
#include "PWapi/samepts.h"       
#include "PWapi/rngbx.h"       
#include "PWapi/revvec.h"       
#include "PWapi/memfunc.h"
#include "PWapi/objcons.h"       /* Pathway */
#include "objconn.h"
#include "channel.h"
#include "PWapi/objdel.h"       
#include "PWapi/edprops.h"
#include "PWapi/lpprops.h"
#include "PWapi/edcons.h"
#include "PWapi/partol.h"
#include "PWapi/sfbnds.h"
#include "PWapi/edtype.h"
#include "PWapi/lped.h"
#include "PWapi/edmod.h"
#include "PWapi/edgeom.h"
#include "PWapi/gmdatamem.h"

#include "ptclass.h"

/* Static Functions */

static PWresult GetBdrySplitPts
(
  int     n_int,
  int     n_over,
  double  *p_intpar,
  PWpoint2d *p_intpts,
  double  *p_overpar,
  PWpoint2d *p_overpts,

  PWpoint2d startpt,
  PWpoint2d stoppt,
  double lentol,

  int *num_splits,
  PWpoint2d *p_splitpts
);

static PWboolean get_elem_info
(
  struct PWcvdata *p_elem,
  int num_elems,
  struct PWcvdata *p_elems,
  int *p_props,
  int *p_types,
  int *props,
  int *type
);

static PWresult get_natbdry_info
(
  struct IGRbsp_surface *p_sfgeom,
  double xyztol,

  int bdrycvprops[4],
  int bdrycvtypes[4]
);

static PWresult connect_seams
(
  int num_loops,
  PWobjid *p_loops,
  PWosnum os,
  double uvtol
);

static PWresult seam_insert
(
  struct PWcvdata *p_edgeom,
  int             edprops,
  int             edtype,
  int             num_cvs,
  struct PWcvdata *p_cvdata,
  int             *p_cvprops,
  PWboolean       *p_cvrev,
  int             num_bdry_splits,
  struct PWcvdata *p_bdrycvs,
  int             *p_bdryprops,
  double          uvtol,

  int             *p_numouted,
  struct PWcvdata **p_edoutgm,
  int             **p_edoutprops,
  int             **p_edouttypes
);

static PWboolean inbetween_par_val
(
  double   testval,
  double   startval,
  double   stopval,
  double   uvtol
);

static void sort_pars
(
  double  startval,
  double  stopval,
  double  *valarr,
  int     count,
  double  *sort_arr
);

/* Externs */

extern PWclassid OPP_EMSloop_class_id;

extern void EMgentracer (long *msg, int num_elems, short dim, double *endpts, 
            double *tanvecs, char **elemptrs, double tol, 
            struct EMStraceinfo *trcinfo, int *num_grps, int **num_elems_grp, 
            char ****elems, PWboolean ***elem_rev, PWboolean **grp_closed);

/*
  ABSTRACT

    Given a set of oriented curves in the UV domain of the surface, it returns
    a loop which could form the area or hole on the surface depending on input
    curve direction. The input curves should satisfy one of the following con-
    ditions.
      * The set of input curves should form a closed curve(s).
                           OR
      * End points of the input curves should lie on the natural boundaries of 
        the surface.

  DESCRIPTION

    Given a set of oriented curves in the UV domain of the surface, a loop will
    be created by splitting the natural boundaries of the surface if required,
    and sets all the required properties on the loop. Of course! it is also   
    responsible for creating the edge objects. The loop created can represent
    a face or hole on the surface (which is defined the input curve direction).

  ARGUMENTS

  NOTES

    All the memory will be allocated inside this routine.

  HISTORY

    Aji     06/21/96   Flipped the points being sent in to make vec as 
                       EMgentracer requires that the vectors flow
                       into the curve. Found this during IGES->EMS
                       translation. TR# 159601999.
    Sanjay  09/20/95   Creation
*/

PWresult pwCreateLoopFromEdgeGeoms
(
  int num_eds,
  struct PWcvdata *p_eddata,
  int *p_edprops,
  int *p_edxyz_type,
  PWboolean *p_edrev,

  struct IGRbsp_surface *p_sfgeom,

  PWosnum os,
  double xyztol,

  int *num_loops,
  PWobjid **p_loops
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWboolean BSsts=TRUE;
  long OMmsg=OM_S_SUCCESS;

  int num_bdrys=0, i=0, j=0, end=0, knt=0, bdry=0, num_bdry_splits=0;
  double u_min=0, v_min=0, u_max=0, v_max=0, uvtol=0, squvtol=0;
  PWpoint2d bdrycvpts[8];
  int bdrycvprops[4], bdrycvtype[4], *p_bdryprops=NULL, *p_bdrytype=NULL;
  int bdryprops=0, bdrytype=0;
  struct PWpoly2d bdrycvs[4], *p_bdrycv=NULL; 
  struct PWcvdata *p_bdrycvs=NULL;

  int num_cvs=0, *p_cvxyz_type=NULL, *p_cvprops=NULL;
  struct PWcvdata *p_cvdata=NULL;
  PWboolean *p_cvrev=NULL;
  int natloc=0, num_full_nateds=0;
  int n_int=0, n_over=0, num=0, *p_indices=NULL;
  double *p_intpar=NULL, *p_overpar=NULL, *p_tmppar=NULL;
  PWpoint2d *p_intpts=NULL, *p_overpts=NULL, *p_tmppts=NULL;
  PWpoint *p_cvendpts=NULL;
  PWboolean natrev=FALSE;
  struct IGRbsp_curve *p_cv=NULL;

  PWboolean start_on_bdry=FALSE, stop_on_bdry=FALSE; 
  PWboolean overlap=FALSE, full_overlap=FALSE;
  PWpoint2d startpt, stoppt;
  double startpar=0, stoppar=0;
  PWboolean is_bdry_split[4];

  int edprops=0, edxyz_type=0;

  PWboolean *p_tmpcvrev=NULL, *p_processcv=NULL, *p_degencv=NULL;
  PWvector2d cvvec, bdryvec;

  int num_splits=0;
  PWpoint2d *p_splitpts=NULL;
  PWboolean is_any_bdry_split=FALSE;
  struct PWcvparam cvpar;
  PWvector tanvec;

  int grp=0, elm=0;
  int num_elems=0, mod_num_elems=0, num_grps=0, *p_num_elems_grp=0; 
  PWboolean **p_elem_rev=NULL, *p_grp_closed=NULL;
  PWpoint2d *p_endpts=NULL, *p_tanvecs=NULL; 
  char **p_elem_ptrs=NULL, ***p_elems=NULL;
  struct EMStraceinfo *p_traceinfo=NULL;

  int n_loops=0, max_edges=0;
  struct PWcvdata *p_edgeom=NULL, edgeom;
  PWobjid *p_edobj=NULL;
 
  PWboolean start_or_stop_are_same = FALSE;
  double *p_bdrypt=NULL;

  int num_outed=0, outed=0;
  struct PWcvdata *p_edoutgm=NULL;
  int  *p_edoutprops=NULL, *p_edouttypes=NULL;

  /* 
   * Initialize the output.
   */
  *num_loops = 0;
  *p_loops = NULL;

  /* 
   * get the surface parametric bounds 
   */
  u_min = p_sfgeom->u_knots [p_sfgeom->u_order-1];
  v_min = p_sfgeom->v_knots [p_sfgeom->v_order-1];
  u_max = p_sfgeom->u_knots [p_sfgeom->u_num_poles];
  v_max = p_sfgeom->v_knots [p_sfgeom->v_num_poles];

  uvtol = pwGetParTolSf (p_sfgeom, xyztol);
  squvtol = uvtol * uvtol;

  /* 
   * get the natural boundaries of the surface. 
   */
  num_bdrys = 4;
  for (i=0; i<num_bdrys; i++)
  {
    bdrycvs[i].num_pts = 2;
    bdrycvs[i].p_pts = (PWpoint2d *) &bdrycvpts[i*2][0];
  }

  bdrycvs[0].p_pts[0][U] = u_min; bdrycvs[0].p_pts[1][U] = u_min;
  bdrycvs[0].p_pts[0][V] = v_min; bdrycvs[0].p_pts[1][V] = v_max;

  bdrycvs[1].p_pts[0][U] = u_min; bdrycvs[1].p_pts[1][U] = u_max;
  bdrycvs[1].p_pts[0][V] = v_max; bdrycvs[1].p_pts[1][V] = v_max;

  bdrycvs[2].p_pts[0][U] = u_max; bdrycvs[2].p_pts[1][U] = u_max;
  bdrycvs[2].p_pts[0][V] = v_max; bdrycvs[2].p_pts[1][V] = v_min;

  bdrycvs[3].p_pts[0][U] = u_max; bdrycvs[3].p_pts[1][U] = u_min;
  bdrycvs[3].p_pts[0][V] = v_min; bdrycvs[3].p_pts[1][V] = v_min;

  PWsts = get_natbdry_info (p_sfgeom, xyztol, bdrycvprops, bdrycvtype);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);


  /*
   * Delete all the input curves which lies on the natural boundaries of the
   * surface.
   */
  if (p_edprops && num_eds)
  {
    p_cvdata = (struct PWcvdata *) alloca (num_eds * sizeof (struct PWcvdata));
    p_cvprops = (int *) alloca (num_eds * sizeof (int));
    p_cvxyz_type = (int *) alloca (num_eds * sizeof (int));
    p_cvrev = (PWboolean *) alloca (num_eds * sizeof (PWboolean));
    OnErrorState (!p_cvdata || !p_cvprops || !p_cvxyz_type || !p_cvrev, PWsts, 
                  SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);

    num_cvs = 0;
    num_full_nateds = 0;

    for (knt=0; knt<num_eds; knt++)
    {
      if (!(p_edprops[knt] & EMED_NATURAL))
      {
        memcpy (&p_cvdata[num_cvs], &p_eddata[knt], sizeof (struct PWcvdata));
        p_cvprops[num_cvs] = p_edprops[knt];
        p_cvxyz_type[num_cvs] = p_edxyz_type[knt];
        p_cvrev[num_cvs] = p_edrev[knt];
        num_cvs ++;
      }
   	  else
	  if (pwGetNatLocation (p_eddata[knt].data.py2d.p_pts, u_min, u_max,
                                 v_min, v_max, &natloc, &natrev))
      {
        num_full_nateds ++;
      }
    }
  }
  else
  {
    num_cvs = num_eds;
    p_cvdata = p_eddata;
    p_cvprops = p_edprops;
    p_cvxyz_type = p_edxyz_type;
    p_cvrev = p_edrev;
  }



  if (!num_cvs || num_full_nateds == 4)
  {
    /*
     * No curves are input / four of the input curves lies on the natural 
     * boundaries of the surface. So the caller want to generate a natural 
     * loop. Generate the natural loop by considering only the natural 
     * boundaries of the input surface.
     */

    p_edobj = (PWobjid *) alloca (num_bdrys * sizeof (PWobjid));
    *p_loops = (PWobjid *) malloc (sizeof (PWobjid)); 
    OnErrorState (!p_edobj || !*p_loops, PWsts, SetError (PW_K_Pathway,
                  PW_K_DynamicMemory), wrapup);

    for (bdry=0; bdry<num_bdrys; bdry++)
    {
      edgeom.datatype = PWcvdata_py2d;
      edgeom.data.py2d = bdrycvs[bdry];

      p_edobj[bdry] = pwCreateEdge (os, &edgeom, bdrycvprops[bdry], 
                                    bdrycvtype[bdry]);
      OnErrorState (p_edobj[bdry] == PW_K_NullObjid, PWsts,
                    SetError (PW_K_Pathway, PW_K_Internal), wrapup);
    }

    (*p_loops)[0] = pwCreateLoopFromEdgeObjs (os, num_bdrys, p_edobj, 
                                                       p_sfgeom);
    OnErrorState ((*p_loops)[0]== PW_K_NullObjid, PWsts, SetError(PW_K_Pathway,
                  PW_K_Internal), wrapup);

    *num_loops = 1;

    if (!num_cvs)
      goto wrapup;
  }

  /*
   * get the end points of all the input curves.
   */
  p_cvendpts = (PWpoint *) alloca (num_cvs * 2 * sizeof (PWpoint));
  OnErrorState (!p_cvendpts, PWsts, SetError (PW_K_Pathway, 
                PW_K_DynamicMemory), wrapup);

  memset (p_cvendpts, 0, num_cvs * 2 * sizeof (PWpoint));

  for (knt=0; knt<num_cvs; knt++)
  {
    pwGetEndPtCvdata (&p_cvdata[knt], p_cvrev[knt], FALSE, p_cvendpts[knt*2]);
    pwGetEndPtCvdata (&p_cvdata[knt], p_cvrev[knt], TRUE, p_cvendpts[knt*2+1]);
  }

  /*
   * get the degneracy of the input curves.
   */
  p_degencv = (PWboolean *) alloca (num_cvs * sizeof (PWboolean));
  OnErrorState (!p_degencv, PWsts, SetError (PW_K_Pathway,
                PW_K_DynamicMemory), wrapup);
  
  for (knt=0; knt<num_cvs; knt++)
  {
    p_degencv[knt] = pwIsDegenCvdata (&p_cvdata[knt], uvtol);
  }

  if (num_cvs == 1 && !p_degencv[0] && 
      pwIsSamePt2d (p_cvendpts[0], p_cvendpts[1], uvtol))
  {
    /*
     * Number of input curves is one and the curve is closed. No need to find
     * the interaction with the boundaries as this will alone form the required
     * loop.
     */

    PWobjid edobj=PW_K_NullObjid;

    if (*num_loops)
      *p_loops = (PWobjid *) realloc (*p_loops, (*num_loops+1) * 
                                                sizeof (PWobjid));
    else
      *p_loops = (PWobjid *) malloc (sizeof (PWobjid));
    OnErrorState (!*p_loops, PWsts, SetError(PW_K_Pathway, PW_K_DynamicMemory),
                  wrapup);

    edobj = pwCreateEdge (os, p_cvdata, p_cvprops[0], p_cvxyz_type[0]);
    OnErrorState (edobj == PW_K_NullObjid, PWsts, SetError (PW_K_Pathway, 
                  PW_K_Internal), wrapup);

    if (p_cvrev[0])
    {
      if (pwIsEdRev (edobj, os))
        pwUnsetEdRev (edobj, os);
      else
        pwSetEdRev (edobj, os);
    }

    (*p_loops)[*num_loops] = pwCreateLoopFromEdgeObjs (os, 1, &edobj, p_sfgeom);
     OnErrorState ((*p_loops)[*num_loops]== PW_K_NullObjid, PWsts,
                   SetError (PW_K_Pathway, PW_K_Internal), wrapup);

    (*num_loops) ++;
    goto wrapup;
  }

  p_tmpcvrev = (PWboolean *) alloca (num_cvs * sizeof (PWboolean));
  OnErrorState (!p_tmpcvrev, PWsts, SetError (PW_K_Pathway,
                PW_K_DynamicMemory), wrapup);

  memcpy (p_tmpcvrev, p_cvrev, num_cvs * sizeof (PWboolean));



  /*
   * split each natural boundary.
   */
  p_intpar = (double *) alloca (num_cvs * 2 * sizeof (double));
  p_intpts = (PWpoint2d *) alloca (num_cvs * 2 * sizeof (PWpoint2d));
  p_overpar = (double *) alloca (num_cvs * 2 * sizeof (double));
  p_overpts = (PWpoint2d *) alloca (num_cvs * 2 * sizeof (PWpoint2d));
  p_indices = (int *) alloca (num_cvs * 2 * sizeof (int));
  p_tmppar = (double *) alloca (num_cvs * 2 * sizeof (double));
  p_tmppts = (PWpoint2d *) alloca (num_cvs * 2 * sizeof (PWpoint2d));
  p_processcv = (PWboolean *) alloca (num_cvs * 2 * sizeof (PWboolean));
  p_splitpts = (PWpoint2d *) alloca (((num_cvs * 2) +1) * 2 * 
                                     sizeof (PWpoint2d));
  p_bdrycvs = (struct PWcvdata *) alloca (((num_cvs * 2) +1) * 4 * 
                                          sizeof (struct PWcvdata));
  p_bdryprops = (int *) alloca (((num_cvs * 2) +1) * 4 * sizeof (int));
  p_bdrytype = (int *) alloca (((num_cvs * 2) +1) * 4 * sizeof (int));
  OnErrorState (!p_intpar || !p_intpts || !p_overpar || !p_indices ||
    !p_overpts, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);


  for (i=0; i<num_cvs; i++)
  {
    if (p_degencv[i])
      p_processcv[i] = FALSE;
    else
      p_processcv[i] = TRUE;
  }

  for (bdry=0; bdry<num_bdrys; bdry++)
  {
    p_bdrycv = &bdrycvs[bdry];
    n_int = 0; n_over = 0;
    full_overlap = FALSE;
    is_bdry_split[bdry] = FALSE;

    for (knt=0; knt<num_cvs; knt++)
    {
      if (!p_processcv[knt])
        continue;

      start_on_bdry = FALSE;
      stop_on_bdry = FALSE;
      overlap = FALSE;

      if (pwMinDistSqPtSeg2d (p_cvendpts[knt*2], p_bdrycv->p_pts[0], 
                       p_bdrycv->p_pts[1], startpt, &startpar) < squvtol)
        start_on_bdry = TRUE;

      if (pwMinDistSqPtSeg2d (p_cvendpts[knt*2+1], p_bdrycv->p_pts[0], 
                       p_bdrycv->p_pts[1], stoppt, &stoppar) < squvtol)
        stop_on_bdry = TRUE;

      if (start_on_bdry && stop_on_bdry)
      {
        /*
         * Start and Stop points are on the boundary.
         */

        if (p_cvdata[knt].datatype == PWcvdata_py2d) 
        {
          if (p_cvdata[knt].data.py2d.num_pts == 2)
            overlap = TRUE;
        }
        else
        {
          p_cv = p_cvdata[knt].datatype == PWcvdata_bspcv ? 
                               p_cvdata[knt].data.p_bspcv :  
                               p_cvdata[knt].data.p_gmbspcv->bspcv;
          if (!p_cv->rational && p_cv->num_poles == 2)
            overlap = TRUE;
        }

        p_processcv[knt] = FALSE;

        if (overlap)
        {
          pwMakeVec2d (startpt, stoppt, cvvec); 
          pwMakeVec2d (p_cvendpts[knt*2], p_cvendpts[knt*2+1], bdryvec); 
          pwNormVec2d (cvvec, cvvec);
          pwNormVec2d (bdryvec, bdryvec);

          if (pwDot2d (cvvec, bdryvec) < 0.0)
          {
            pwSwapDouble (&startpar, &stoppar);
            pwSwapPt (p_cvendpts[knt*2], p_cvendpts[knt*2+1]);
            p_tmpcvrev[knt] = !p_tmpcvrev[knt];
          }

          if (fabs (1.0 - fabs (startpar - stoppar)) < uvtol)
          {
            /*
             * The natural boundary is fully overlapping with  this  input 
             * curve. Ignore this boundary for further processing and move 
             * on to the next boundary curve.
             */

            full_overlap=TRUE;
            break;
          }

          p_overpar[n_over*2] = startpar;
          p_overpar[n_over*2+1] = stoppar;
          memcpy (p_overpts[n_over*2], startpt, sizeof (PWpoint2d));
          memcpy (p_overpts[n_over*2+1], stoppt, sizeof (PWpoint2d)); 
          n_over ++;
        }
        else
        {
          p_intpar[n_int] = startpar;
          p_intpar[n_int+1] = stoppar;
          memcpy (p_intpts[n_int], startpt, sizeof (PWpoint2d));
          memcpy (p_intpts[n_int+1], stoppt, sizeof (PWpoint2d)); 
          n_int += 2;
        }
      }
      else if (start_on_bdry)
      { 
        /*
         * Only start point is on the boundary.
         */

        p_intpar[n_int] = startpar;
        memcpy (p_intpts[n_int], startpt, sizeof (PWpoint2d));
        n_int ++;
      }
      else if (stop_on_bdry)
      { 
        /*
         * Only stop point is on the boundary.
         */

        p_intpar[n_int] = stoppar;
        memcpy (p_intpts[n_int], stoppt, sizeof (PWpoint2d));
        n_int ++;
      }
    }

    if (full_overlap)
      continue;

    if (n_int > 1)
    {
      BSsts = BStagsort (&BSmsg, &n_int, p_intpar, p_indices);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Internal), wrapup);

      for (i=0; i<n_int; i++)
      {
        p_tmppar[i] = p_intpar [p_indices[i]];
        memcpy (p_tmppts[i], p_intpts[p_indices[i]], sizeof (PWpoint2d));
      }

      memcpy (p_intpar, p_tmppar, n_int * sizeof (double));
      memcpy (p_intpts, p_tmppts, n_int * sizeof (PWpoint2d));
    }

    if (n_over)
    {
      num = n_over * 2;
      BSsts = BStagsort (&BSmsg, &num, p_overpar, p_indices);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Internal), wrapup);

      for (i=0; i<num; i++)
      {
        p_tmppar[i] = p_overpar[p_indices[i]];
        memcpy (p_tmppts[i], p_overpts[p_indices[i]], sizeof (PWpoint2d));
      }

      memcpy (p_overpar, p_tmppar, num * sizeof (double));
      memcpy (p_overpts, p_tmppts, num * sizeof (PWpoint2d));
    }

    if (n_int || n_over)
    {
      is_bdry_split[bdry] = TRUE;

      PWsts = GetBdrySplitPts (n_int, n_over, p_intpar, p_intpts, p_overpar,
                          p_overpts, p_bdrycv->p_pts[0], p_bdrycv->p_pts[1],
                          uvtol, &num_splits, p_splitpts);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
    }
    else
    {
      is_bdry_split[bdry] = FALSE;

      num_splits = 1;
      memcpy (p_splitpts[0], p_bdrycv->p_pts[0], sizeof (PWpoint2d));
      memcpy (p_splitpts[1], p_bdrycv->p_pts[1], sizeof (PWpoint2d));
    }

    if (num_splits > 1)
    {
      if (bdrycvtype[bdry] == EMcircle)
        bdrytype = EMcircular_arc;
      else if (bdrycvtype[bdry] == EMellipse)
        bdrytype = EMelliptical_arc;
      else
        bdrytype = bdrycvtype[bdry];

      bdryprops = bdrycvprops[bdry] | EMED_OPEN;
      bdryprops &= ~(EMED_XYZ_CLOSED);
    }
    else
    {
      bdryprops = bdrycvprops[bdry] | EMED_OPEN;
      bdrytype = bdrycvtype[bdry];
    }

    for (i=0; i<num_splits; i++)
    {
      p_bdrycvs[num_bdry_splits].datatype = PWcvdata_py2d;
      p_bdrycvs[num_bdry_splits].data.py2d.num_pts = 2;
      p_bdrycvs[num_bdry_splits].data.py2d.p_pts = 
               (PWpoint2d *) alloca (2 * sizeof (PWpoint2d));;
      memcpy (p_bdrycvs[num_bdry_splits].data.py2d.p_pts, &p_splitpts[i*2][0], 
              2 * sizeof (PWpoint2d));
      p_bdryprops[num_bdry_splits] = bdryprops;
      p_bdrytype[num_bdry_splits] = bdrytype;
      num_bdry_splits ++;
    } 
  }
  
  is_any_bdry_split = FALSE;
  for (i=0; i<num_bdrys; i++)
  {
    if (is_bdry_split[i]) 
    {
      is_any_bdry_split = TRUE;
      break;
    }
  }


  num_elems = num_cvs + (is_any_bdry_split ? num_bdry_splits : 0);
  p_elem_ptrs = (char **) alloca (num_elems * sizeof (char *));
  p_endpts = (PWpoint2d *) alloca (num_elems * 2 * sizeof (PWpoint2d));
  p_tanvecs = (PWvector2d *) alloca (num_elems * 2 * sizeof (PWvector2d));
  p_traceinfo = (struct EMStraceinfo *) alloca (num_elems * 
                                                sizeof (struct EMStraceinfo));
  OnErrorState (!p_elem_ptrs || !p_endpts || !p_tanvecs || !p_traceinfo,
                PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);

  memset (p_traceinfo, 0, num_elems * sizeof (struct EMStraceinfo));

  mod_num_elems = num_elems;

  for (knt=0; knt<num_cvs; knt++)
  {
    p_elem_ptrs[knt] = (char *) &p_cvdata[knt];
    p_traceinfo[knt].degenerate = p_degencv[knt];
    memcpy (p_endpts[knt*2], p_cvendpts[knt*2], sizeof (PWpoint2d));
    memcpy (p_endpts[knt*2+1], p_cvendpts[knt*2+1], sizeof (PWpoint2d));

    if (p_tmpcvrev[knt])
    {
      pwGetMaxParCvdata (&p_cvdata[knt], &cvpar);
      pwGetTangentCvdata (&p_cvdata[knt], &cvpar, TRUE, tanvec);
      pwNormVec2d (tanvec, tanvec);
      memcpy (p_tanvecs[knt*2], tanvec, sizeof (PWvector2d));

      pwGetMinParCvdata (&p_cvdata[knt], &cvpar);
      pwGetTangentCvdata (&p_cvdata[knt], &cvpar, FALSE, tanvec);
      pwNormVec2d (tanvec, tanvec);
      memcpy (p_tanvecs[knt*2+1], tanvec, sizeof (PWvector2d));
    }
    else
    {
      pwGetMinParCvdata (&p_cvdata[knt], &cvpar);
      pwGetTangentCvdata (&p_cvdata[knt], &cvpar, FALSE, tanvec);
      pwNormVec2d (tanvec, tanvec);
      memcpy (p_tanvecs[knt*2], tanvec, sizeof (PWvector2d));

      pwGetMaxParCvdata (&p_cvdata[knt], &cvpar);
      pwGetTangentCvdata (&p_cvdata[knt], &cvpar, TRUE, tanvec);
      pwNormVec2d (tanvec, tanvec);
      memcpy (p_tanvecs[knt*2+1], tanvec, sizeof (PWvector2d));
    }
  }

  for (knt=num_cvs, i=num_cvs; knt<num_elems; knt++)
  {
    start_or_stop_are_same = FALSE;

    for (end=START; end<=STOP; end++)
    {
      p_bdrypt = &p_bdrycvs[knt-num_cvs].data.py2d.p_pts[end][0];

      for (j=0; j<num_cvs; j++)
      {
        if (pwIsSamePt2d (p_bdrypt, p_cvendpts[j*2+end], uvtol))
        {
          start_or_stop_are_same = TRUE;
          break;
        }
      }

      if (start_or_stop_are_same)
        break;
    }

    if (!start_or_stop_are_same)
    {
      p_elem_ptrs[i] = (char *) &p_bdrycvs[knt-num_cvs];
      p_traceinfo[i].degenerate = FALSE;
      memcpy (&p_endpts[i*2][0], p_bdrycvs[knt-num_cvs].data.py2d.p_pts, 
              2 * sizeof (PWpoint2d));

      pwMakeVec2d (p_bdrycvs[knt-num_cvs].data.py2d.p_pts[0], 
                   p_bdrycvs[knt-num_cvs].data.py2d.p_pts[1], tanvec);
      pwNormVec2d (tanvec, tanvec);
      memcpy (p_tanvecs[i*2], tanvec, sizeof (PWvector2d)); 
      pwRevVec2d (tanvec, tanvec);
      memcpy (p_tanvecs[i*2+1], tanvec, sizeof (PWvector2d)); 

      i++; 
    }
    else
      mod_num_elems --;
  }

  num_elems = mod_num_elems;


  /*
   * Run the trace.
   */
  EMgentracer (&OMmsg, num_elems, (short) 2, (double *) p_endpts, 
               (double *) p_tanvecs, p_elem_ptrs, uvtol, p_traceinfo, 
               &num_grps, &p_num_elems_grp, &p_elems, &p_elem_rev, 
               &p_grp_closed);
  OnErrorState (IsError (OMmsg), PWsts, SetError (PW_K_Pathway, PW_K_Internal),
                wrapup);

  /*
   * Validate the trace output.
   */
  n_loops = 0;
  for (grp=0; grp<num_grps; grp++)
  {
    if (p_grp_closed[grp])
    {
      n_loops ++;

     /*
      if (p_num_elems_grp[grp] > max_edges)
        max_edges = p_num_elems_grp[grp];
     */

      for (elm=0; elm<p_num_elems_grp[grp]; elm++)
      {
    /*      OnErrorState (p_elem_rev[grp][elm], PWsts, SetError (PW_K_Pathway, 
                  PW_K_InvalidArg), wrapup);
     */
      }
    }
  }
  max_edges = (num_cvs + num_bdry_splits) * 2; 

  OnErrorState (!n_loops, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                wrapup);


  /*
   * Create the edges and then create the loop for each closed group.
   */ 
  p_edobj  = (PWobjid *) alloca (max_edges * sizeof (PWobjid));
  if (*num_loops)
    *p_loops = (PWobjid *) realloc (*p_loops, (n_loops + (*num_loops)) * sizeof (PWobjid));
  else
    *p_loops = (PWobjid *) malloc (n_loops * sizeof (PWobjid));
  OnErrorState (!p_edobj || !*p_loops, PWsts, SetError (PW_K_Pathway,
                 PW_K_DynamicMemory), wrapup);
  
  for (grp=0; grp<num_grps; grp++)
  {
    if (p_grp_closed[grp])
    {
      for (elm=0, i=0; elm<p_num_elems_grp[grp]; elm++)
      {
        num_outed = 0;
        p_edgeom = (struct PWcvdata *) p_elems[grp][elm];
       
        if (!get_elem_info (p_edgeom, num_cvs, p_cvdata, p_cvprops,
                            p_cvxyz_type, &edprops, &edxyz_type))
        {
          get_elem_info (p_edgeom, num_bdry_splits, p_bdrycvs, 
                         p_bdryprops, p_bdrytype, &edprops, &edxyz_type);
        }

        /*
         * At this point we will check for seam edges. Some of the seam
         * edges may not match with its corresponding edge on the other
         * side of the seam. For that we need to do a end point match and
         * insert an edge if the endpoint match is not obtained.
         */

        seam_insert (p_edgeom, edprops, edxyz_type,num_cvs, p_cvdata, 
                     p_cvprops, p_tmpcvrev, num_bdry_splits,
                     p_bdrycvs, p_bdryprops, uvtol, &num_outed,
                     &p_edoutgm, &p_edoutprops, &p_edouttypes);
        OnErrorState (IsError (PWsts), PWsts,
                      SetError (PW_K_Pathway, PW_K_Internal), wrapup);

        if (num_outed)
        {
          for (outed=0; outed<num_outed; outed++)
          {
            p_edobj[i++] = pwCreateEdge (os, &(p_edoutgm[outed]), 
                                         p_edoutprops[outed], 
                                         p_edouttypes[outed]);
            OnErrorState (p_edobj[i-1] == PW_K_NullObjid, PWsts, 
                          SetError (PW_K_Pathway, PW_K_Internal), wrapup);
          }
        }
        else
        {
          p_edobj[i++] = pwCreateEdge (os, p_edgeom, edprops, edxyz_type);
          OnErrorState (p_edobj[i-1] == PW_K_NullObjid, PWsts,
                        SetError (PW_K_Pathway, PW_K_Internal), wrapup);
        }

        if ( !num_outed)
        {
          for (knt=0; knt<num_cvs; knt++)
          {
            if (p_edgeom == &p_cvdata[knt] && p_tmpcvrev && p_tmpcvrev[knt])
            {
              if (pwIsEdRev (p_edobj[i -1], os))
                pwUnsetEdRev (p_edobj[i-1], os);
              else
                pwSetEdRev (p_edobj[i-1], os);
            }
          }
        }
        if (num_outed)
        {
          for (outed=0; outed < num_outed; outed++)
          {
            pwFreeCvdataGeom (&(p_edoutgm[outed]));
          }
          free (p_edoutgm);
          p_edoutgm = NULL;
          free (p_edoutprops);
          p_edoutprops = NULL;
          free (p_edouttypes);
          p_edouttypes = NULL;
        }
      }

      (*p_loops)[*num_loops] = pwCreateLoopFromEdgeObjs (os, i, p_edobj, 
                                                         p_sfgeom);
      (*num_loops) ++;
    }
  }


wrapup :

  if (!IsError (PWsts) && (p_sfgeom->u_phy_closed || p_sfgeom->v_phy_closed))
  {
    PWsts = connect_seams (*num_loops, *p_loops, os, uvtol);
  }


  if (p_grp_closed) free (p_grp_closed);
  if (p_num_elems_grp) free (p_num_elems_grp);
  if (p_elem_rev) free (p_elem_rev);
  if (p_elems) free (p_elems);

  PW_Wrapup (PWsts, "pwCreateLoopOnSfFromCvs");
  return PWsts;
}


/*
  ABSTRACT

  NOTES

    None.
*/

static PWresult GetBdrySplitPts
(
  int     n_int,
  int     n_over,
  double  *p_intpar,
  PWpoint2d *p_intpts, 
  double  *p_overpar,
  PWpoint2d *p_overpts, 

  PWpoint2d startpt,
  PWpoint2d stoppt,
  double  lentol,

  int *num_splits,
  PWpoint2d *p_splitpts
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWboolean BSsts=TRUE;

  int count=0;
  int n_seg=0, mod_nseg=0, knt=0, i=0, size=0, *p_sortinx=NULL;
  double *p_tmppar=NULL, minpar=0.0, maxpar=1.0, *p_sortpar=NULL;
  PWpoint2d *p_sortpts=NULL, *p_tmppts=NULL;
  PWboolean overlap=FALSE;

  *num_splits = 0;

  size = (n_int + n_over * 2 + 2);
  p_sortinx = (int *) alloca (size * sizeof (int));
  p_tmppar = (double *) alloca (size * sizeof (double));
  p_sortpar = (double *) alloca (size * sizeof (double));
  p_tmppts = (PWpoint2d *) alloca (size * sizeof (PWpoint2d));
  p_sortpts = (PWpoint2d *) alloca (size * sizeof (PWpoint2d));

  OnErrorState (!p_sortinx || !p_tmppar || !p_sortpar || !p_tmppts || 
    !p_sortpts, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);

  if (n_int)
  {
    memcpy (p_tmppar, p_intpar, n_int * sizeof (double));
    memcpy (p_tmppts, p_intpts, n_int * sizeof (PWpoint2d));
  }

  if (n_over)
  {
    memcpy (&p_tmppar[n_int], p_overpar, n_over * 2 * sizeof (double));
    memcpy (&p_tmppts[n_int][0], p_overpts, n_over * 2 * sizeof (PWpoint2d));
  }

  n_seg = n_int + n_over * 2;

  BSsts = BStagsort (&BSmsg, &n_seg, p_tmppar, p_sortinx);
  OnErrorState (BSERROR (BSmsg), PWsts,  SetError (PW_K_Pathway, 
                PW_K_Internal), wrapup);

  mod_nseg = n_seg;

  count = 0;
  for (i=0; i<n_seg; i++)
  {
    if (i && pwIsSamePt2d (p_tmppts[p_sortinx[i]], p_tmppts[p_sortinx[i-1]], 
                           lentol))
    {
      mod_nseg --;
    }
    else
    {
      p_sortpar[count] = p_tmppar[p_sortinx[i]];
      memcpy (p_sortpts[count], p_tmppts[p_sortinx[i]], sizeof (PWpoint2d)); 
      count ++;
    }
  }

  n_seg = mod_nseg;

  if ((p_sortpar[0] - minpar) > lentol)
  {
    memmove (&p_sortpar[1], &p_sortpar[0], n_seg * sizeof (double));
    p_sortpar[0] = minpar;
    memmove (&p_sortpts[1][0], &p_sortpts[0][0], n_seg * sizeof (PWpoint2d));
    memcpy (&p_sortpts[0][0], startpt, sizeof (PWpoint2d));
    n_seg ++;
  }

  if ((maxpar - p_sortpar[n_seg-1]) > lentol)
  {
    p_sortpar[n_seg] = maxpar;
    memcpy (&p_sortpts[n_seg][0], stoppt, sizeof (PWpoint2d));
    n_seg++;
  }

  if (n_seg == 2 && (p_sortpar[0] - minpar) < lentol &&
      (maxpar - p_sortpar[1]) < lentol)
  {
    *num_splits = 1;
    memcpy (p_splitpts, p_sortpts, 2 * sizeof (PWpoint2d));
    goto wrapup;
  }

  for (knt=0; knt<n_seg-1; knt++)
  {
    overlap = FALSE;

    for (i=0; i<n_over; i++)
    {
      if (fabs (p_sortpar[knt] - p_overpar[i*2]) < lentol)
      {
        overlap = TRUE;
        break;
      }
    }

    if (!overlap)
    {
      memcpy (p_splitpts [(*num_splits) * 2], p_sortpts[knt], 
              2 * sizeof (PWpoint2d));
      (*num_splits) ++;
    }
  }

wrapup :

  return PWsts;
}

/* Internal macros */

#define U_FACTOR  0.3675
#define V_FACTOR  0.7365

/*
  ABSTRACT

  NOTES

  HISTORY
  
    Sanjay  09/20/95  Creation
*/

PWobjid pwCreateLoopFromEdgeObjs
(
  PWosnum os,
  int num_edges,
  PWobjid *p_edges,
  struct IGRbsp_surface *p_sfgeom 
)
{
  int ed=0, num_connected=0;
  PWresult PWsts=PW_K_Success;
  PWobjid  lpobj=PW_K_NullObjid;
  PWboolean is_natural=TRUE;
  OM_S_CHANSELECT to_loop, to_edge;

  lpobj = omCreateObjFromClassid (os, OPP_EMSloop_class_id);
  OnErrorState ((lpobj == PW_K_NullObjid), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  EMmake_chanselect (EMSbd_owner_to_comps, &to_edge);
  EMmake_chanselect (EMSedge_to_owner, &to_loop);

  for (ed=0, num_connected=0; ed<num_edges; ed++, num_connected++)
  {
    PWsts = omConnectObjectAtIndex (lpobj, os, &to_loop, ed, p_edges[ed], os,
                                    &to_edge, 0);
    OnErrorState (IsError (PWsts), PWsts, SetError (PW_K_Pathway,
                  PW_K_InvalidArg), wrapup);

    if (is_natural && !pwIsEdNatural (p_edges[ed], os))
      is_natural = FALSE;
  }

  if (is_natural && num_edges)
    pwSetLpNatural (lpobj, os);
  pwSetLpRange (lpobj, os);
  pwSetLpActive (lpobj, os);

  if (num_edges && p_edges)
  {  
    BSrc BSmsg=BSSUCC;
    PWrange2d lprng;
    PWpoint2d uvpt;
    double chttol=0;
    struct PWsfdata sfdata;
    struct PWid lpid;
    enum PWptloctype ptpos=PWptloc_unknown; 
    PWobjid bdry_contain_elem=PW_K_NullObjid;
    struct PWcvpt bdrypt;

    /*
     * get a point outside the loop range. 
     */
    pwGetLpRange (lpobj, os, lprng);
       
    uvpt[U] = lprng[MAXIMUM][U] + 
              U_FACTOR * (lprng[MAXIMUM][U] - lprng[MINIMUM][U]); 
    uvpt[V] = lprng[MAXIMUM][V] + 
              V_FACTOR * (lprng[MAXIMUM][V] - lprng[MINIMUM][V]); 
/*
    if( uvpt[U] > 1.0)
	  uvpt[U] = 1.0;
	if(uvpt[V] > 1.0)
	  uvpt[V] = 1.0;
*/
    sfdata.datatype = PWsfdata_bspsf;
    sfdata.data.p_bspsf = p_sfgeom;
    lpid.objid = lpobj;
    lpid.osnum = os;
    BSEXTRACTPAR (&BSmsg, BSTOLCHRDHT, chttol);
    memset (&bdrypt, 0, sizeof (struct PWcvpt));

    /*
     * Determine the location of this point with respect to this loop.
     */
    PWsts = LpPtClassify (&lpid, uvpt, chttol, &sfdata, &ptpos, 
                            &bdry_contain_elem, &bdrypt);
    if (bdrypt.p_attrib) pwFreeAttribList (bdrypt.p_attrib);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
    
    switch (ptpos)
    {
      case PWptloc_inarea :
      { 
        /*
         * It is a hole and the point lies in area region.
         */              
      }
      break;
  
      case PWptloc_inhole :
      {
        /*
         * It is a face and the point lies in hole region.
         */              
        pwSetLpFace (lpobj, os);
      }
      break;

      default : 
      {
        OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_Internal),
                      wrapup);
      }
    } 
  }
  
wrapup :

  if (IsError (PWsts) && lpobj != PW_K_NullObjid)
  {
    /*
     * Some error occured. Disconnect all the edges from the loop and then
     * delete the construct loop.
     */
    for (ed=0; ed<num_connected; ed++)
      omDisconnectObject (lpobj, os, &to_loop, p_edges[ed], os, &to_edge);

    omDeleteObject (lpobj, os);
    lpobj = PW_K_NullObjid;
  }

  PW_Wrapup (PWsts, "pwCreateLoopFromEdgeObjs");
  return lpobj;
}

static PWresult get_natbdry_info
(
  struct IGRbsp_surface *p_sfgeom,
  double xyztol,

  int bdrycvprops[4],
  int bdrycvtypes[4]
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;

  int seam0=0, seam1=0, nonseam0=0, nonseam1=0;

  struct BSgeom_bsp_surf gmsf;

  memset (&gmsf, 0, sizeof (struct BSgeom_bsp_surf));
  memset (bdrycvprops, 0, 4 * sizeof (int));
  memset (bdrycvtypes, 0, 4 * sizeof (int));

  gmsf.bounded = TRUE;
  gmsf.geom_prop = FALSE;
  gmsf.bspsf = p_sfgeom;

  BSsftgeomsf (&gmsf, TRUE, 0, &BSmsg);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, PW_K_Internal),
                wrapup);

  if (p_sfgeom->u_phy_closed || p_sfgeom->v_phy_closed)
  {
    if (p_sfgeom->u_phy_closed)
    {
      seam0 = 0; seam1 = 2;
      nonseam0 = 1; nonseam1 = 3;
    }
    else 
	{
      seam0 = 1; seam1 = 3;
      nonseam0 = 0; nonseam1 = 2;
    }
  }
  else
  {
    if (p_sfgeom->u_order == 3)
    {
      seam0 = 0; seam1 = 2;
      nonseam0 = 1; nonseam1 = 3;
    }
    else 
    {
      seam0 = 1; seam1 = 3;
      nonseam0 = 0; nonseam1 = 2;
    }
  }

  switch (gmsf.type)
  {
    case BSRECT_PLANE : 
    {
      bdrycvtypes[0] = EMlinesegment;
      bdrycvtypes[1] = EMlinesegment;
      bdrycvtypes[2] = EMlinesegment;
      bdrycvtypes[3] = EMlinesegment;
    }
    break;

    case BSSPHERE :
    {
      bdrycvtypes[0] = EMpoint;
      bdrycvtypes[1] = EMcircular_arc;
      bdrycvtypes[2] = EMpoint;
      bdrycvtypes[3] = EMcircular_arc;

      bdrycvprops[0] = EMED_DEGENERATE;
      bdrycvprops[1] = EMED_SEAM | EMED_SUBORDINATE | EMED_TANGENT;
      bdrycvprops[2] = EMED_DEGENERATE;
      bdrycvprops[3] = EMED_SEAM | EMED_TANGENT;
    }
    break;

    case BSFULL_CYL :
    {
      bdrycvtypes[seam0] = EMlinesegment;
      bdrycvtypes[seam1] = EMlinesegment;
      bdrycvtypes[nonseam0] = EMcircle;
      bdrycvtypes[nonseam1] = EMcircle;

      bdrycvprops[seam0] = EMED_SEAM | EMED_SUBORDINATE | EMED_TANGENT;
      bdrycvprops[seam1] = EMED_SEAM | EMED_TANGENT;
      bdrycvprops[nonseam0] = EMED_XYZ_CLOSED;
      bdrycvprops[nonseam1] = EMED_XYZ_CLOSED;
    }
    break;

    case BSFULL_CONE :
    case BSPART_CONE : 
    {
      PWboolean degen_u0=FALSE, degen_v0=FALSE, degen_u1=FALSE, degen_v1=FALSE;
      PWboolean partcone=FALSE;

      partcone = (gmsf.type == BSPART_CONE) ? TRUE : FALSE;

      PWsts = pwGetDegenNatBdrysOfSf (p_sfgeom, xyztol, &degen_u0, &degen_u1,
                                      &degen_v0, &degen_v1);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

      bdrycvtypes[seam0] = EMlinesegment;
      bdrycvtypes[seam1] = EMlinesegment;
      if ((nonseam0 == 1 && degen_v1) || (nonseam0 == 0 && degen_u0))
        bdrycvtypes[nonseam0] = EMpoint;
      else
        bdrycvtypes[nonseam0] = partcone ? EMcircular_arc : EMcircle;
      if ((nonseam1 == 3 && degen_v0) || (nonseam1 == 2 && degen_u1))
        bdrycvtypes[nonseam1] = EMpoint;
      else
        bdrycvtypes[nonseam1] = partcone ? EMcircular_arc : EMcircle;

      bdrycvprops[seam0] = partcone ? 0 : (EMED_SEAM | EMED_SUBORDINATE | 
                                           EMED_TANGENT);
      bdrycvprops[seam1] = partcone ? 0 : (EMED_SEAM | EMED_TANGENT);
      bdrycvprops[nonseam0] = partcone ? 0 : EMED_XYZ_CLOSED;
      bdrycvprops[nonseam1] = partcone ? 0 : EMED_XYZ_CLOSED;
      if ((nonseam0 == 1 && degen_v1) || (nonseam0 == 0 && degen_u0))
        bdrycvprops[nonseam0] |= EMED_DEGENERATE;
      if ((nonseam1 == 3 && degen_v0) || (nonseam1 == 2 && degen_u1))
        bdrycvprops[nonseam1] |= EMED_DEGENERATE;
    }
    break;

    case BSPART_CYL :
    {
      bdrycvtypes[seam0] = EMlinesegment;
      bdrycvtypes[seam1] = EMlinesegment;
      bdrycvtypes[nonseam0] = EMcircular_arc;
      bdrycvtypes[nonseam1] = EMcircular_arc;
    }
    break;

    case BSTORUS :
    {
      bdrycvtypes [0] = EMcircle;
      bdrycvtypes [1] = EMcircle;
      bdrycvtypes [2] = EMcircle;
      bdrycvtypes [3] = EMcircle;
	 
      bdrycvprops[0] = EMED_SEAM | EMED_XYZ_CLOSED | EMED_SUBORDINATE | 
                       EMED_TANGENT;
      bdrycvprops[1] = EMED_SEAM | EMED_XYZ_CLOSED | EMED_SUBORDINATE | 
                       EMED_TANGENT;
      bdrycvprops[2] =  EMED_SEAM | EMED_XYZ_CLOSED | EMED_TANGENT ; 
      bdrycvprops[3] =  EMED_SEAM | EMED_XYZ_CLOSED | EMED_TANGENT; 
    }
    break;

    case BSPART_TORUS :
    {
      int base0=0, base1=0, rev0=0, rev1=0;
      PWboolean base_closed=FALSE, rev_closed=FALSE;

      if (gmsf.gencv_ind == 0)
      {
        base0 = 1; base1 = 3;
        rev0 = 0; rev1 = 2;
        if (p_sfgeom->u_phy_closed)
          base_closed = TRUE;
        else if (p_sfgeom->v_phy_closed)
          rev_closed = TRUE;
      }
      else
      {
        base0 = 0; base1 = 2;
        rev0 = 1; rev1 = 3;
        if (p_sfgeom->v_phy_closed)
          base_closed = TRUE;
        else if (p_sfgeom->u_phy_closed)
          rev_closed = TRUE;
      }

      bdrycvtypes [base0] = base_closed ? EMcircle : EMcircular_arc;
      bdrycvtypes [base1] = base_closed ? EMcircle : EMcircular_arc;
      bdrycvtypes [rev0] = rev_closed ? EMcircle : EMcircular_arc; 
      bdrycvtypes [rev1] = rev_closed ? EMcircle : EMcircular_arc; 
      bdrycvprops[base0] = base_closed ? (EMED_SEAM | EMED_XYZ_CLOSED | 
                                          EMED_SUBORDINATE | EMED_TANGENT) : 0;
      bdrycvprops[rev0] = rev_closed ? (EMED_SEAM | EMED_XYZ_CLOSED | 
                                        EMED_TANGENT) : 0;
      bdrycvprops[base1] = base_closed ? (EMED_SEAM | EMED_XYZ_CLOSED |
                                          EMED_SUBORDINATE | EMED_TANGENT) : 0;
      bdrycvprops[rev1] = rev_closed ? (EMED_SEAM | EMED_XYZ_CLOSED |
                                        EMED_TANGENT) : 0;
    }
    break;

    case BSPART_SPHERE : 
    {
      PWboolean rev_closed=FALSE;
      PWboolean degen_u0=FALSE, degen_v0=FALSE, degen_u1=FALSE, degen_v1=FALSE;

      PWsts = pwGetDegenNatBdrysOfSf (p_sfgeom, xyztol, &degen_u0, &degen_u1,
                                      &degen_v0, &degen_v1);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

      rev_closed = p_sfgeom->v_phy_closed ? TRUE : FALSE;

      bdrycvtypes[0] = degen_u0 ? EMpoint : (rev_closed ? EMcircle : 
                                                          EMcircular_arc);
      bdrycvtypes[1] = EMcircular_arc;
      bdrycvtypes[2] = degen_u1 ? EMpoint : (rev_closed ? EMcircle :
                                                          EMcircular_arc);
      bdrycvtypes[3] = EMcircular_arc;

      bdrycvprops[0] = degen_u0 ? EMED_DEGENERATE : 0;
      bdrycvprops[1] = rev_closed ? (EMED_SEAM | EMED_SUBORDINATE | 
                                     EMED_TANGENT) : 0;
      bdrycvprops[2] = degen_u1 ? EMED_DEGENERATE : 0;
      bdrycvprops[3] = rev_closed ? (EMED_SEAM | EMED_TANGENT) : 0;
    }
    break;

    case BSSF_OF_PROJ :
    case BSSF_OF_REV : 
    {
      struct BSgeom_bsp_curve gmcv;
      int basetype=0, base0=0, base1=0, projrev0=0, projrev1=0; 
      int projrevtype0=0, projrevtype1=0;
      PWboolean base_closed=FALSE, rev_closed=FALSE;

      if (gmsf.gencv_ind == 0)
      {
        base0 = 1; base1 = 3;
        projrev0 = 0; projrev1 = 2;
        if (p_sfgeom->u_phy_closed)
          base_closed = TRUE;
        
        if (p_sfgeom->v_phy_closed)
          rev_closed = TRUE;
      }
      else
      {
        base0 = 0; base1 = 2;
        projrev0 = 1; projrev1 = 3;
        if (p_sfgeom->v_phy_closed)
          base_closed = TRUE;
        
        if (p_sfgeom->u_phy_closed)
          rev_closed = TRUE;
      }

      if (gmsf.type == BSSF_OF_PROJ)
      {
        projrevtype0 = EMlinesegment;
        projrevtype1 = EMlinesegment;
      }
      else
      {
        PWboolean degen_u0=FALSE, degen_v0=FALSE, degen_u1=FALSE, 
                  degen_v1=FALSE;

        PWsts = pwGetDegenNatBdrysOfSf (p_sfgeom, xyztol, &degen_u0, &degen_u1,
                                        &degen_v0, &degen_v1);
        OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
 
        if (gmsf.gencv_ind == 0)
        {
          projrevtype0 = degen_v0 ? EMpoint : (rev_closed ? EMcircle : 
                                                            EMcircular_arc);
          projrevtype1 = degen_v1 ? EMpoint : (rev_closed ? EMcircle : 
                                                            EMcircular_arc);
        }
        else
        {
          projrevtype0 = degen_u0 ? EMpoint : (rev_closed ? EMcircle : 
                                                            EMcircular_arc);
          projrevtype1 = degen_u1 ? EMpoint : (rev_closed ? EMcircle : 
                                                            EMcircular_arc);
        }
      }

      memset (&gmcv, 0, sizeof (struct BSgeom_bsp_curve));
      gmcv.type = (gmsf.sfgen_cv->order == 3) ? BSCIRC_ARC : BSGEN_BSP_CV;
      gmcv.bspcv = gmsf.sfgen_cv;

      BScvtgeomcv (&gmcv, &gmcv, &BSmsg);
      basetype = pwGetEdTypeFromBsType (gmcv.type);

      bdrycvtypes[base0] = basetype;
      bdrycvtypes[base1] = basetype;
      bdrycvtypes[projrev0] = projrevtype0;
      bdrycvtypes[projrev1] = projrevtype0;

      bdrycvprops[base0] = base_closed ? EMED_XYZ_CLOSED : 0;
      bdrycvprops[base1] = base_closed ? EMED_XYZ_CLOSED : 0;
      bdrycvprops[projrev0] = rev_closed ? EMED_XYZ_CLOSED : 0;
      bdrycvprops[projrev1] = rev_closed ? EMED_XYZ_CLOSED : 0;
  
      if(p_sfgeom->u_phy_closed)
      {
        bdrycvprops[0] |=  EMED_SEAM;
        bdrycvprops[2] |=  EMED_SEAM | EMED_SUBORDINATE;
      }
  
      if(p_sfgeom->v_phy_closed)
      {
        bdrycvprops[1] |=  EMED_SEAM;
        bdrycvprops[3] |=  EMED_SEAM | EMED_SUBORDINATE;
      }

    }
    break;

    default :
    {
      PWboolean degen_u0=FALSE, degen_v0=FALSE, degen_u1=FALSE, degen_v1=FALSE;


      PWsts = pwGetDegenNatBdrysOfSf (p_sfgeom, xyztol, &degen_u0, &degen_u1,
                                      &degen_v0, &degen_v1);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

      bdrycvtypes[0] = bdrycvtypes[1] = EMfreeform_curve;
      bdrycvtypes[2] = bdrycvtypes[3] = EMfreeform_curve;

      if (degen_u0)
        bdrycvtypes[0] = EMpoint;
      else if (p_sfgeom->v_order == 2 && !p_sfgeom->v_non_uniform) 
        bdrycvtypes[0] = p_sfgeom->v_num_poles == 2 ? EMlinesegment : 
                                                      EMlinestring;
      if (degen_v1)
        bdrycvtypes[1] = EMpoint;
      else if (p_sfgeom->u_order == 2 && !p_sfgeom->u_non_uniform) 
        bdrycvtypes[1] = p_sfgeom->u_num_poles == 2 ? EMlinesegment : 
                                                      EMlinestring;
      if (degen_u1)
        bdrycvtypes[2] = EMpoint;
      else if (p_sfgeom->v_order == 2 && !p_sfgeom->v_non_uniform) 
        bdrycvtypes[2] = p_sfgeom->v_num_poles == 2 ? EMlinesegment : 
                                                      EMlinestring;
      if (degen_v0)
        bdrycvtypes[3] = EMpoint;
      else if (p_sfgeom->u_order == 2 && !p_sfgeom->u_non_uniform) 
        bdrycvtypes[3] = p_sfgeom->u_num_poles == 2 ? EMlinesegment : 
                                                      EMlinestring;

      bdrycvprops[0] = degen_u0 ? EMED_DEGENERATE : 
                   (p_sfgeom->u_phy_closed ? EMED_SEAM | EMED_SUBORDINATE : 0);
      bdrycvprops[1] = degen_v1 ? EMED_DEGENERATE :
                   (p_sfgeom->v_phy_closed ? EMED_SEAM : 0);
      bdrycvprops[2] = degen_u1 ? EMED_DEGENERATE :
                   (p_sfgeom->u_phy_closed ? EMED_SEAM : 0);
      bdrycvprops[3] = degen_v0 ? EMED_DEGENERATE :
                   (p_sfgeom->v_phy_closed ? EMED_SEAM | EMED_SUBORDINATE : 0);
    }
    break;    
  }

wrapup :

  return PWsts;
}

static PWboolean get_elem_info
(
  struct PWcvdata *p_elem,
  int num_elems,
  struct PWcvdata *p_elems,
  int *p_props,
  int *p_types,
  int *props,
  int *type
)
{
  int i=0;
  PWboolean found=FALSE;

  *props = 0; 
  *type = 0;

  for (i=0; i<num_elems; i++)
  {
    if (p_elem == (&p_elems[i]))
    {
      found = TRUE;
      *props = p_props[i];
      *type = p_types[i];
      break;
    }
  }

  return found;
}

/*
  ABSTRACT
    Given a set of loop ids this function checks for seams and connects them.

  NOTES
    The surface on which the loops are lying should be closed atleast in
    one direction.  It is the responsibility of the user to check for the 
    closure of the surface before calling this function.

    All the four variable are inputs.

  HISTORY
    Gan          06/20/96  Creation
                 This wrapper was needed for processing 144/142 Entites in 
                 IGES->EMS X'lator.
*/

PWresult pwConnectSeams
(
  int num_loops,
  PWobjid *p_loops,
  PWosnum os,
  double uvtol
)
{
  return ( connect_seams(num_loops, p_loops, os, uvtol) );
}

static PWresult connect_seams
(
  int num_loops,
  PWobjid *p_loops,
  PWosnum os,
  double uvtol
)
{
  PWresult PWsts=PW_K_Success;

  int num_seams=0, bufsize=10, num_edges=0, lp=0, ed=0, num_allocated=0; 
  int seam1=0, seam2=0, isodir=0;
  PWobjid *p_seams=NULL, *p_edges=0, seamed1=PW_K_NullObjid, 
          seamed2=PW_K_NullObjid;
  PWboolean is_match=FALSE;
  PWpoint2d endpts1[2], endpts2[2];

  p_seams = (PWobjid *) malloc (bufsize * sizeof (PWobjid));
  OnErrorState (!p_seams, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                wrapup);

  for (lp=0; lp<num_loops; lp++)
  {
    num_edges = pwNumEdsOfLp (p_loops[lp], os);
    OnErrorState (!num_edges, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                  wrapup);

    if (num_edges > num_allocated)
    {
      p_edges = NULL;

      p_edges = (PWobjid *) alloca (num_edges * sizeof (PWobjid));
      OnErrorState (!p_edges, PWsts, SetError (PW_K_Pathway, 
                    PW_K_DynamicMemory), wrapup);
 
      num_allocated = num_edges;
    }

    num_edges = pwEdsOfLp (p_loops[lp], os, p_edges);

    for (ed=0; ed<num_edges; ed++)
    {
      if (pwIsEdSeam (p_edges[ed], os))
      {
        if (num_seams >= bufsize)
        {
          bufsize += 10;
          p_seams = (PWobjid *) realloc (p_seams, bufsize * sizeof (PWobjid));
          OnErrorState (!p_seams, PWsts, SetError (PW_K_Pathway, 
                        PW_K_DynamicMemory), wrapup);
        }

        p_seams [num_seams] = p_edges[ed];
        num_seams ++;
      }
    }
  }


  for (seam1=0; seam1<num_seams; seam1++)
  {
    is_match = FALSE;

    if (p_seams[seam1] == PW_K_NullObjid)
      continue;

    seamed1 = p_seams[seam1];

    pwGetEdEndPts (seamed1, os, endpts1[START], endpts1[STOP]);
    if (fabs (endpts1[START][U] - endpts1[STOP][U]) < uvtol)
      isodir = U;
    else
      isodir = V;

    for (seam2=0; seam2<num_seams; seam2++)
    {
      if (seam2 == seam1 || p_seams[seam2] == PW_K_NullObjid)
        continue;

      pwGetEdEndPts (p_seams[seam2], os, endpts2[START], endpts2[STOP]);

      if (isodir == U && fabs (endpts2[START][U] - endpts2[STOP][U]) < uvtol)
      {
        if ((fabs (endpts1[START][V] - endpts2[STOP][V]) < uvtol) &&
            (fabs (endpts1[STOP][V] - endpts2[START][V]) < uvtol))
        {
          is_match = TRUE;
          seamed2 = p_seams[seam2];
        }
      }
      else if (isodir == V && fabs (endpts1[START][V] - endpts1[STOP][V]) < 
                                                                        uvtol)
      {
        if ((fabs (endpts1[START][U] - endpts2[STOP][U]) < uvtol) &&
            (fabs (endpts1[STOP][U] - endpts2[START][U]) < uvtol))
        {
          is_match = TRUE;
          seamed2 = p_seams[seam2];
        }
      }

      if (is_match)
        break;
    }

    if (is_match)
    {
      p_seams[seam1] = PW_K_NullObjid;
      p_seams[seam2] = PW_K_NullObjid;

      PWsts = pwMakeCommEdgeConn (os, TRUE, TRUE, seamed1, seamed2);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
    }
    else
    {
      pwUnsetEdSeam (seamed1, os);
      pwUnsetEdSubordinate (seamed1, os);	  
      p_seams[seam1] = PW_K_NullObjid;
    }
  }

wrapup :

  if (p_seams) free (p_seams);
  return PWsts;
}


static PWresult seam_insert
(
  struct PWcvdata *p_edgeom,
  int             edprops,
  int             edtype,
  int             num_cvs,
  struct PWcvdata *p_cvdata,
  int             *p_cvprops,
  PWboolean       *p_cvrev,
  int             num_bdry_splits,
  struct PWcvdata *p_bdrycvs,
  int             *p_bdryprops,
  double          uvtol,

  int             *p_numouted,
  struct PWcvdata **p_edoutgm,
  int             **p_edoutprops,
  int             **p_edouttypes
)
{
  PWresult  PWsts = PW_K_Success;
  int  i=0, isodir=0, count=0, knt=0;
  PWboolean edrev=0, considered=FALSE, exact_match=FALSE;
  PWpoint endpts[2], smendpts[2];
  double  *store_par_val=NULL;
  double  *splitpt_arr=NULL;
  int seam2=0;

  store_par_val = (double *) alloca ((num_cvs + num_bdry_splits) * 2 * 
                                sizeof (double));
  OnErrorState (!store_par_val, PWsts, SetError (PW_K_Pathway,
                PW_K_DynamicMemory), wrapup);
  memset (store_par_val, 0, (num_cvs + num_bdry_splits) * 2 * sizeof (double));

  
  splitpt_arr = (double *) alloca (((num_cvs + num_bdry_splits) * 2 + 2)* 
                                sizeof (double));
  OnErrorState (!splitpt_arr, PWsts, SetError (PW_K_Pathway,
                PW_K_DynamicMemory), wrapup);
  memset (splitpt_arr, 0, ((num_cvs + num_bdry_splits) * 2 + 2) * sizeof (double));

  /*
   * Check if the current edge is a seam edge. If not, do nothing
   */
  if (!(edprops & EMED_SEAM))
  {
    return PWsts;
  }

  /*
   * If it is a seam edge then go through the input list of edges to see 
   * if there is any corresponding seam edge. If the corresponding seam
   * end points do not match with the present edge then we need to insert
   * another edge breaking this edge or its corresponding edge.
   */

  /*
   * The geometry coming in can be a input curve geometry or a boundary
   * curve geometry. If it is a input curve geometry then we need to 
   * consider the reversal bit in order to get the end points.
   */

  for (knt=0; knt<num_cvs; knt++)
  {
    if (p_edgeom == &p_cvdata[knt] && p_cvrev && p_cvrev[knt])
    {
      edrev = TRUE;
      break;
    }
  }

  /*
   * Get the end points of the input edge geometry
   */
  pwGetEndPtCvdata (p_edgeom, edrev, FALSE, endpts[START]);
  pwGetEndPtCvdata (p_edgeom, edrev, TRUE, endpts[STOP]);

  /*
   * Now we have to see whether it is a seam in the 'U' direction or 'V'
   * direction.
   */
  if (fabs (endpts[START][U] - endpts[STOP][U]) < uvtol)
    isodir = U;
  else
    isodir = V;

  /*
   * We will first traverse the curve data to look for the corresponding
   * seam. If we don't find it we will then look for it in boundary curve
   * list.
   */
  for (seam2 =0; seam2<num_cvs; seam2++)
  {
    /*
     * Initialize within loop
     */
    considered = FALSE;

    if (!(p_cvprops[seam2] & EMED_SEAM)) 
      continue;

    /*
     * Get the end points for this curve
     */
    pwGetEndPtCvdata (&p_cvdata[seam2], p_cvrev[seam2], FALSE, 
                      smendpts[START]);
    pwGetEndPtCvdata (&p_cvdata[seam2], p_cvrev[seam2], TRUE,
                      smendpts[STOP]);

    if ((fabs (endpts[START][U] - smendpts[START][U]) < uvtol) &&
        (fabs (endpts[START][V] - smendpts[START][V]) < uvtol) &&
        (fabs (endpts[STOP][U] - smendpts[STOP][U]) < uvtol) &&
        (fabs (endpts[STOP][V] - smendpts[STOP][V]) < uvtol))
    {
      /* 
       * Same geometry, so continue
       */
      continue;
    } 
     
    if (isodir == U && (fabs (smendpts[START][U] - smendpts[STOP][U])<uvtol))
    {
      if ((fabs (endpts[START][V] - smendpts[STOP][V]) < uvtol) &&
          (fabs (endpts[STOP][V] - smendpts[START][V]) < uvtol))
      {
        exact_match = TRUE;
        break;
      }
      else if ( inbetween_par_val (smendpts[START][V], endpts[START][V],
                                   endpts[STOP][V], uvtol))
      {
        for (i=0; i<count; i++)
        {
          if (smendpts[START][V] == store_par_val[i])
            considered = TRUE;
        }
        if (!considered)
          store_par_val[count++] = smendpts[START][V];
      }
      else if ( inbetween_par_val (smendpts[STOP][V], endpts[START][V],
                                   endpts[STOP][V], uvtol))
      {
        for (i=0; i<count; i++)
        {
          if (smendpts[STOP][V] == store_par_val[i])
            considered = TRUE;
        }
        if (!considered)
          store_par_val[count++] = smendpts[STOP][V];
      }
    }
    else if (isodir == V && fabs (smendpts[START][V] - smendpts[STOP][V]) <
                                                                       uvtol)
    {
      if ((fabs (endpts[START][U] - smendpts[STOP][U]) < uvtol) &&
          (fabs (endpts[STOP][U] - smendpts[START][U]) < uvtol))
      {
        exact_match = TRUE;
        break;
      }
      else if ( inbetween_par_val (smendpts[START][U], endpts[START][U],
                                   endpts[STOP][U], uvtol))
      {
        for (i=0; i<count; i++)
        {
          if (smendpts[START][U] == store_par_val[i])
            considered = TRUE;
        }
        if (!considered)
          store_par_val[count++] = smendpts[START][U];
      }
      else if ( inbetween_par_val (smendpts[STOP][U], endpts[START][U],
                                   endpts[STOP][U], uvtol))
      {
        for (i=0; i<count; i++)
        {
          if (smendpts[STOP][U] == store_par_val[i])
            considered = TRUE;
        }
        if (!considered)
          store_par_val[count++] = smendpts[STOP][U];
      }
    }
  }

  if (!exact_match)
  {
    for (seam2 =0; seam2<num_bdry_splits; seam2++)
    {
      /*
       * Initialize within loop
       */
      considered = FALSE;

      if (!(p_bdryprops[seam2] & EMED_SEAM))
        continue;

      /*
       * Get the end points for this curve
       */
      pwGetEndPtCvdata (&p_bdrycvs[seam2], FALSE, FALSE,
                        smendpts[START]);
      pwGetEndPtCvdata (&p_bdrycvs[seam2], FALSE, TRUE,
                        smendpts[STOP]);

      if ((fabs (endpts[START][U] - smendpts[START][U]) < uvtol) &&
          (fabs (endpts[START][V] - smendpts[START][V]) < uvtol) &&
          (fabs (endpts[STOP][U] - smendpts[STOP][U]) < uvtol) &&
          (fabs (endpts[STOP][V] - smendpts[STOP][V]) < uvtol))
      {
        /*
         * Same geometry, so continue
         */
        continue;
      }

      if (isodir == U && (fabs (smendpts[START][U] - smendpts[STOP][U])<uvtol))
      {
        if ((fabs (endpts[START][V] - smendpts[STOP][V]) < uvtol) &&
            (fabs (endpts[STOP][V] - smendpts[START][V]) < uvtol))
        {
          exact_match = TRUE;
          break;
        }
        else if ( inbetween_par_val (smendpts[START][V], endpts[START][V],
                                     endpts[STOP][V], uvtol))
        {
          for (i=0; i<count; i++)
          {
            if (smendpts[START][V] == store_par_val[i])
              considered = TRUE;
          }
          if (!considered)
            store_par_val[count++] = smendpts[START][V];
        }
        else if ( inbetween_par_val (smendpts[STOP][V], endpts[START][V],
                                     endpts[STOP][V], uvtol))
        {
          for (i=0; i<count; i++)
          {
            if (smendpts[STOP][V] == store_par_val[i])
              considered = TRUE;
          }
          if (!considered)
            store_par_val[count++] = smendpts[STOP][V];
        }
      }
      else if (isodir == V && fabs (smendpts[START][V] - smendpts[STOP][V]) <
                                                                       uvtol)
      {
        if ((fabs (endpts[START][U] - smendpts[STOP][U]) < uvtol) &&
            (fabs (endpts[STOP][U] - smendpts[START][U]) < uvtol))
        {
          exact_match = TRUE;
          break;
        }
        else if ( inbetween_par_val (smendpts[START][U], endpts[START][U],
                                     endpts[STOP][U], uvtol))
        {
          for (i=0; i<count; i++)
          {
            if (smendpts[START][U] == store_par_val[i])
              considered = TRUE;
          }
          if (!considered)
            store_par_val[count++] = smendpts[START][U];
        }
        else if ( inbetween_par_val (smendpts[STOP][U], endpts[START][U],
                                     endpts[STOP][U], uvtol))
        {
          for (i=0; i<count; i++)
          {
            if (smendpts[STOP][U] == store_par_val[i])
              considered = TRUE;
          }
          if (!considered)
            store_par_val[count++] = smendpts[STOP][U];
        }
      }
    } 
  }

  if (exact_match)
    return PWsts;

  if (count)
  {
    /*
     * the input geometry is required to be split. Arrange the parameters
     * in ascending or descending order as required.
     */
    if (isodir == U)
    {
      sort_pars (endpts[START][V], endpts[STOP][V], store_par_val, count,
                    splitpt_arr);
    }
    else
    {
      sort_pars (endpts[START][U], endpts[STOP][U], store_par_val, count,
                    splitpt_arr);
    } 
    
    /*
     * Create the new split geometries and also the corresponding properties
     * arrary.
     */
    
    *p_edoutgm = (struct PWcvdata *) malloc ( (count +1)*
                                                sizeof (struct PWcvdata));
    OnErrorState (!(*p_edoutgm), PWsts, SetError (PW_K_Pathway,
                  PW_K_DynamicMemory), wrapup);
    memset (*p_edoutgm, 0, (count+1)*sizeof (struct PWcvdata));
 
    *p_edoutprops = (int *) malloc ( (count +1) * sizeof (int));
    OnErrorState (!(*p_edoutprops), PWsts, SetError (PW_K_Pathway,
                  PW_K_DynamicMemory), wrapup);
    *p_edouttypes = (int *) malloc ( (count +1) * sizeof (int));
    OnErrorState (!(*p_edouttypes), PWsts, SetError (PW_K_Pathway,
                  PW_K_DynamicMemory), wrapup);

    memset (*p_edoutprops, 0, (count+1)*sizeof (int));
    memset (*p_edouttypes, 0, (count+1)*sizeof (int));

    for (i=0; i<=count; i++)
    {
      (*p_edoutgm)[i].datatype = PWcvdata_py2d;
      (*p_edoutgm)[i].data.py2d.num_pts = 2;
      (*p_edoutgm)[i].data.py2d.p_pts = 
                             (PWpoint2d *) malloc (2* sizeof (PWpoint2d));
      OnErrorState (!((*p_edoutgm)[i].data.py2d.p_pts), PWsts, 
                      SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);

      if (isodir == U)
      {
        (*p_edoutgm)[i].data.py2d.p_pts[START][U]
                                      = p_edgeom->data.py2d.p_pts[START][U];
        (*p_edoutgm)[i].data.py2d.p_pts[STOP][U]
                                      = p_edgeom->data.py2d.p_pts[START][U];
    
        (*p_edoutgm)[i].data.py2d.p_pts[START][V] = splitpt_arr[i];
        (*p_edoutgm)[i].data.py2d.p_pts[STOP][V] = splitpt_arr[i+1];
      }
      else if (isodir == U)
      {
        (*p_edoutgm)[i].data.py2d.p_pts[START][V]
                                      = p_edgeom->data.py2d.p_pts[START][V];
        (*p_edoutgm)[i].data.py2d.p_pts[STOP][V]
                                      = p_edgeom->data.py2d.p_pts[START][V];

        (*p_edoutgm)[i].data.py2d.p_pts[START][U] = splitpt_arr[i];
        (*p_edoutgm)[i].data.py2d.p_pts[STOP][U] = splitpt_arr[i+1];
      }
      /*
       * Set the corresponding property bit
       */
      (*p_edoutprops)[i] = edprops;
      (*p_edoutprops)[i] &= ~EMED_XYZ_CLOSED;
  
      if ((edtype == EMcircle) || (edtype == EMcircular_arc))
        (*p_edouttypes)[i] = EMcircular_arc;
      else if ((edtype == EMellipse) || (edtype == EMelliptical_arc))
        (*p_edouttypes)[i] = EMelliptical_arc;
      else
        (*p_edouttypes)[i] = edtype;
    }
    *p_numouted = count + 1;
  }/* if count */

  wrapup:
    
  if (!PWsts)
  {
    /*
     * Free all the memory allocated by this function
     */
    if (count)
    {
      for (i=0; i<=count; i++)
      {
        pwFreeCvdataGeom ( &(*p_edoutgm)[i]);
      }
      free (*p_edoutgm);
      *p_edoutgm = NULL;
      free (*p_edoutprops);
      *p_edoutprops = NULL;
      free (*p_edouttypes);
      *p_edouttypes = NULL;

      count = 0;
      *p_numouted = 0;
    }
  }
  return PWsts;
}
    

static void sort_pars 
(
  double  startval, 
  double  stopval, 
  double  *valarr,
  int     count,
  double  *sort_arr
)
{
  int midval=0, i=0, j=0;
  double tmpval=0.0;
  PWboolean reversed=FALSE;

  if (startval > stopval)
  {
    tmpval = stopval;
    stopval = startval;
    startval = tmpval;
    reversed = TRUE;
  }

  sort_arr[0] = startval;
  sort_arr[count+1] = stopval;
  memcpy (&sort_arr[1], valarr, count * sizeof(double));

  for (i=0; i<count+1; i++)
  {
    for (j=i+1; j<count+2; j++)
    {
      if (sort_arr[j] < sort_arr[i])
      {
        tmpval = sort_arr[j];
        sort_arr[j] = sort_arr[i];
        sort_arr[i] = tmpval;
      }
    }
  }

  if (reversed)
  {
    midval = (count+2)/2;
    for (i=0; i< midval; i++)
    {
      tmpval = sort_arr[i];
      sort_arr[i] = sort_arr[count+1-i];
      sort_arr[count+1-i] = tmpval;
    }
  }
}      
    
static PWboolean inbetween_par_val 
(
  double   testval, 
  double   startval, 
  double   stopval, 
  double   uvtol
)
{
  if (stopval > startval)
  {
    if (((testval-startval)>uvtol) && ((stopval -testval)>uvtol))
      return TRUE;
    else
      return FALSE;
  }
  else
  {
    if (((testval-stopval)>uvtol) && ((startval -testval)>uvtol))
      return TRUE;
    else
      return FALSE;
  }
}
