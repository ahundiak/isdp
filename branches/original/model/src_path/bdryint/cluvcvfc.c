/*
  OVERVIEW

  This file contains the API for composite curve trimming with respect to the
  face boundaries in the parametric space of the surface. Even though, this 
  function is specially written for Add/Remove Feature, it can be viewed as a
  general function can be useful in Curve Boolean. 

  NOTES

  Even though for the time-being this serves only Add/Remove feature, it can
  be made more generic so that it can be used by other functionalities such as
  2D Curve Boolean.

  HISTORY

  Sanjay         11/06/95          Creation

*/

/* Includes */

#include <stdio.h>
#include <math.h>
#include <memory.h>          /* System */
#include <alloca.h>
#include <malloc.h>

#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "madef.h"

#include "PWminimum.h"
#include "PWgmdata.h"        /* Pathway */
#include "PWgmint.h"        
#include "PWattrib.h"
#include "PWattribid.h"
#include "PWerror.h"

/* Prototypes */

#include "bsxln.h"
#include "bsprptonln.h"
#include "bsxlnln.h"
#include "bsalloccv.h"
#include "bscv_copy.h"

#include "PWapi/cluvcvfc.h"
#include "PWapi/lpprops.h"
#include "PWapi/lped.h"
#include "PWapi/eded.h"
#include "PWapi/sflp.h"
#include "PWapi/sfgeom.h"
#include "PWapi/cvcompcv.h"
#include "PWapi/cvgeom.h"
#include "PWapi/edgeom.h"

#include "PWapi/mx.h"
#include "PWapi/normvec.h"
#include "PWapi/rngbx.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/dotp.h"
#include "PWapi/crossp.h"
#include "PWapi/ptpargm.h"
#include "PWapi/mkvec.h"
#include "PWapi/memfunc.h"
#include "PWapi/partol.h"
#include "PWapi/revgm.h"
#include "PWapi/gmdatamem.h"
#include "PWapi/mapcvonpln.h"
#include "PWapi/partgm.h"
#include "PWapi/sortgmint.h"
#include "PWapi/sfptloc.h"
#include "PWapi/fcint.h"
#include "PWapi/dbglevel.h"
#include "PWapi/revvec.h"

/* Internal Macros */

#define  DEGENERATE  0
#define  AREA        1
#define  HOLE        2
#define  BDRY        3
#define  ARBIT       3
#define  UNKNOWN     4
#define  OFFENDING   5

static PWresult AddNodeAtEnd
(
  struct PWcvintpt_list  **p_cvintpts,
  struct PWcvintpt_list  *p_node, 
  struct PWcvdata        *p_cvdata,
  int                    side
);

static PWresult  ClassifyRegions
(
  struct PWcvintpt_list  **p_cvintpts, 
  double                 xyztol,
  double                 uvtol,
  struct PWgeomid        *p_sfgmid,
  struct PWcvdata        *p_uvcvs
);

static int GetCvRegion
(
  struct PWcvintpt_list  *p_intpt,
  struct PWcvintpt_list  *p_next_intpt,
  double                 tol 
);

static void is_extend_ends
(
  struct PWcvintpt_list *p_startnode,
  struct PWcvintpt_list *p_stopnode,

  PWobjid fcobj,
  PWosnum os,

  PWboolean *extend_start,
  PWboolean *extend_stop
);

static PWboolean extend_line_to_intersect_with_box
(
  PWpoint  startpt,
  PWvector dirvec,
  PWpoint  boxpts[4],
  PWpoint  stoppt
);

static PWresult get_bounded_uvline
(
  struct PWcvdata *p_uvcv,
  PWvector2d extvec,
  PWboolean atstart,

  PWrange2d rngbx,

  PWpoint2d uvln[2]
);

static PWresult get_area_loops
(
  int num_cvs,
  struct PWcvdata *p_cvs,
  struct PWcvintpt_list *p_cvintpts,
  PWboolean reverse,
  PWboolean start_extended,
  PWboolean stop_extended,
  PWosnum os,

  double uvtol,
  
  int *num_loops,
  int **num_edges_loop,
  struct PWgeomloop **p_loops
);

static struct PWcvintpt_list *get_nonvisited_intpt
(
  int num_cvs,
  struct PWcvintpt_list *p_list,
  PWboolean ignore_start,
  PWboolean ignore_stop
);

static struct PWcvintpt_list *get_nonvisited_endintpt
(
  int num_cvs,
  struct PWcvintpt_list *p_list,
  PWboolean ignore_start,
  PWboolean ignore_stop
);

static struct PWcvintpt_list *get_next_intpt_onedge
(
  PWobjid refedobj,
  PWosnum os,
  struct PWcvparam *p_refedpar,
  PWboolean reverse,
  struct PWcvintpt_list *p_refnode,
  double uvtol,
  struct PWcvintpt_list *p_list
);

static struct PWcvintpt_list *get_next_intpt_onloop
(
  PWobjid refedobj,
  PWosnum os,
  struct PWcvparam *p_refedpar,
  PWboolean reverse,
  struct PWcvintpt_list *p_refnode,
  double uvtol,
  struct PWcvintpt_list *p_list
);

static PWresult get_areacv_geom 
(
  int num_cvs, 
  struct PWcvdata *p_cvs, 
  struct PWcvintpt *p_intpt1, 
  struct PWcvintpt *p_intpt2, 

  double uvtol,

  int *num_outcvs,
  struct PWgeomloop **p_outcvs
);

static PWresult get_bdrycv_geom 
(
  struct PWcvintpt *p_intpt1, 
  struct PWcvintpt *p_intpt2, 
  PWboolean reverse_bdry,
  PWosnum os,

  double uvtol,
  
  int *num_outeds,
  struct PWgeomloop **p_outeds
);

static PWresult alloc_cvdata
(
  struct PWcvdata *p_incv,
  struct PWcvdata *p_outcv
);

static PWresult alloc_partcvdata
(
  struct PWcvdata *p_incv,
  struct PWcvdata *p_outcv
);

static PWresult modify_edge_pars
(
  struct PWcvintpt_list *p_list,
  PWosnum os,
  double uvtol
);

static PWresult cnvt_edgepar
(
  PWobjid edobj,
  PWosnum os,
  struct PWcvpt *p_edpt,
  double uvtol,

  struct PWcvparam *p_edpar
);

static PWresult get_edge_endpars
(
  PWobjid edobj,
  PWosnum os,
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar
);

static void regen_curve_indices
(
  struct PWgeomloop **p_loops,
  int num_cvs,
  PWboolean start_extended,
  PWboolean stop_extended
);

/*
  ABSTRACT

  Given a parametric composite curve, it trims the input curve with the face
  boundaries. If the input curve is short enough so that it cannot be trimmed
  it extends the input curve and then trims the curve. It forms closed loops
  out of the trimmed curve and the boundaries and returns them.

  DESCRIPTION

  ARGUMENTS
 
  NOTES

  KEYWORDS

  Internal API

  HISTORY

*/

PWresult pwCloseUvCompCvWithFaceBounds
(
  int num_cvs,
  struct PWcvdata *p_uvcvs,  

  PWobjid fcobj,
  PWosnum os,

  PWboolean reverse, /* reverse the bdry curves */

  PWvector2d startextvec,
  PWvector2d stopextvec,
  PWboolean ignoremidcvs,

  double lentol,

  PWboolean *start_extended,
  PWboolean *stop_extended,

  int *num_loops,
  int **num_edges_loop,
  struct PWgeomloop **p_loops
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;

  PWobjid sfobj=PW_K_NullObjid;
  struct IGRbsp_surface *p_sfgeom=NULL;
  struct PWsfdata sfdata;
  short mattyp=MAIDMX;
  PWmatrix idmx;
  PWrange2d fcrng;

  int cv=0, knt=0;
  double tmprng[6], uvtol=0;
  PWrange2d uvcvrng;

  int numint=0;
  struct PWcvintpt_list *p_cvintpts=NULL, *p_intpt=NULL, *p_next_intpt=NULL;
  struct PWcvintpt_list *p_head=NULL, *p_tail=NULL;
  struct PWid fcid;
  PWboolean extend_start=FALSE, extend_stop=FALSE; 

  PWpoint2d startuvln[2], stopuvln[2];
  PWboolean approach=FALSE;
  struct PWcvintpt_list *p_start_intpts=NULL, *p_stop_intpts=NULL;

  int num_endcvs=0, num_mod_cvs=0;
  struct PWcvdata *p_mod_uvcvs=NULL;

  /*
   * Initialize the output.
   */

  *num_loops = 0;
  *num_edges_loop = 0;
  *p_loops = NULL;

  OnErrorState (!pwIsLpFace (fcobj, os), PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  /*
   * Determine whether the loop need to be reversed or not.
   */
  sfobj = pwSfOfLp (fcobj, os);
  OnErrorState (sfobj == PW_K_NullObjid, PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  PWsts = PW_GetSfBspsfStack (sfobj, os, mattyp, pwIdMx (idmx), p_sfgeom);
  OnErrorCode (PWsts, wrapup);
  OnErrorState (!p_sfgeom->planar, PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  uvtol = pwGetParTolSf (p_sfgeom, lentol);

  pwGetLpRange (fcobj, os, fcrng);

  /*
   * Intersect the curves with the face boundaries.
   */

  p_cvintpts = NULL;
  fcid.objid = fcobj;
  fcid.osnum = os;
  sfdata.datatype = PWsfdata_bspsf;
  sfdata.data.p_bspsf = p_sfgeom;

  for (cv=0; cv<num_cvs; 
       !ignoremidcvs ? (cv++) : (cv = (num_cvs > 1) ? (num_cvs-1) : 0))
  {
    /*
     * Get the range box.
     */
    pwGetRangeCvdata (&p_uvcvs[cv], tmprng);
    if (p_uvcvs[cv].datatype == PWcvdata_bspcv || 
        p_uvcvs[cv].datatype == PWcvdata_gmbspcv)
    {
      uvcvrng[MINIMUM][U] = tmprng[0], uvcvrng[MINIMUM][V] = tmprng[1];
      uvcvrng[MAXIMUM][U] = tmprng[3], uvcvrng[MAXIMUM][V] = tmprng[4];
    }
    else
    {
      uvcvrng[MINIMUM][U] = tmprng[0], uvcvrng[MINIMUM][V] = tmprng[1];
      uvcvrng[MAXIMUM][U] = tmprng[2], uvcvrng[MAXIMUM][V] = tmprng[3];
    }

    /*
     * Intersect this uv-curve with the face.
     */
    p_intpt = pwTailCvintptList (p_cvintpts);

    PWsts = pwIntersectWithFace (&fcid, &p_uvcvs[cv], NULL, uvcvrng, &sfdata,
                                 lentol, &p_cvintpts);
    OnErrorCode (PWsts, wrapup);

    p_intpt = p_intpt ? p_intpt->p_next : p_cvintpts;

    /*
     * Sort the intersection points.
     */
    if (p_intpt)
    {
      PWsts = pwSortCvintptList (&p_intpt, uvtol);
      OnErrorCode (PWsts, wrapup);
    }

    /*
     * Set the curve index on the curve ID.
     */
    while (p_intpt)
    {
      p_intpt->intpt.cvpt.cvid = cv;
      p_intpt = p_intpt->p_next;
    }
  }

  /*
   * Delete the duplicate intersections at the ends of the input curves.
   */

  p_intpt = p_cvintpts;
  while (p_intpt && p_intpt->p_next)
  {
    if ((p_intpt->p_next->intpt.cvpt.cvid - p_intpt->intpt.cvpt.cvid) == 1 &&
        pwGetTopoposCvpt (&p_intpt->intpt.cvpt) == PWtopopos_stop &&
        pwGetTopoposCvpt (&p_intpt->p_next->intpt.cvpt) == PWtopopos_start) 
    {
      pwSetContainCvintpt (&p_intpt->intpt, RIGHT, 
                      pwGetContainCvintpt (&p_intpt->p_next->intpt, RIGHT));
      p_intpt = p_intpt->p_next;
      p_next_intpt = p_intpt->p_next;
      pwRemoveCvintptList (&p_cvintpts, p_intpt);
      pwFreeCvintptList (p_intpt);
    }
    else
      p_next_intpt = p_intpt->p_next;

    p_intpt = p_next_intpt;
  }

  numint = pwNumCvintptList (p_cvintpts);

  if (numint > 1)
  {
    /*
     * Classify the regions.
     */
    struct PWgeomid sfgmid;

    sfgmid.id.objid = sfobj;
    sfgmid.id.osnum = os;
    sfgmid.mattyp = mattyp;
    pwIdMx (sfgmid.mat);

    PWsts = ClassifyRegions (&p_cvintpts, lentol, uvtol, &sfgmid, p_uvcvs);
    OnErrorCode (PWsts, wrapup);
  }

  /*
   * Delete the spurious nodes.
   */

  /*
   * Extend the ends if required.
   */
  p_head = pwHeadCvintptList (p_cvintpts);
  p_tail = pwTailCvintptList (p_cvintpts);

  is_extend_ends (p_head, p_tail, fcobj, os, &extend_start, &extend_stop);

  /*
   * Generate infinite lines at the start and stop.
   */
  if (extend_start)
  {
    PWsts = get_bounded_uvline (&p_uvcvs[0], startextvec, TRUE, fcrng, 
                                startuvln);
    OnErrorCode (PWsts, wrapup);
  }

  if (extend_stop)
  {
    PWsts = get_bounded_uvline (&p_uvcvs[num_cvs-1], stopextvec, FALSE, fcrng, 
                                stopuvln);
    OnErrorCode (PWsts, wrapup);
  }

  /*
   * Trim the lines. If they approach make one line. If they do not approach
   * trim them with respect to the rest of the components. 
   */

  approach = FALSE;
  if (extend_start && extend_stop)
  {
    PWvector2d startvec, stopvec;

    pwMakeVec2d (startuvln[0], startuvln[1], startvec);
    pwMakeVec2d (stopuvln[0], stopuvln[1], stopvec);
    pwNormVec2d (startvec, startvec);
    pwNormVec2d (stopvec, stopvec);

    if ((pwDot2d (startvec, stopvec) + 1.0) < uvtol)
    { 
      PWpoint2d tpt;
      double tpar=0;

      /*
       * Extension vectors are parallel and reverse. 
       */
      PWsts = pwProjPtLn2d (stopuvln[0], startuvln[0], startuvln[1], tpt, 
                            &tpar);
      OnErrorCode (PWsts, wrapup);

      if (pwDistSqPtPt2d (stopuvln[0], tpt) < (uvtol * uvtol) && tpar > 0.0)
      {
        PWsts = pwProjPtLn2d (startuvln[0], stopuvln[0], stopuvln[1], tpt, 
                               &tpar);
        OnErrorCode (PWsts, wrapup);

        if (pwDistSqPtPt2d (startuvln[0], tpt) < (uvtol * uvtol) && tpar > 0.0)
        {
          approach = TRUE;
          extend_start = FALSE;
          memcpy (stopuvln[1], startuvln[0], sizeof (PWpoint2d));
        }
      }
    }

    if (!approach)
    {
      int num_lnint=0;
      PWpoint lnpts1[2], lnpts2[2], intpts[2];
      double lnpars1[2], lnpars2[2];

      pwCnvt2dTo3d (2, startuvln, lnpts1);
      pwCnvt2dTo3d (2, stopuvln, lnpts2);
     
      BSxlnln (lnpts1, lnpts2, &num_lnint, intpts, lnpars1, lnpars2, &BSmsg);
      OnErrorState (BSERROR (BSmsg) || num_lnint == 2, PWsts, 
                    SetError (PW_K_Pathway, PW_K_Internal), wrapup);

      if (num_lnint)
      {
        memcpy (startuvln[1], intpts[0], sizeof (PWpoint2d));
        memcpy (stopuvln[1], intpts[0], sizeof (PWpoint2d));
      }
    }
  }
 
  /*
   * Reverse the start uv line.
   */
  if (extend_start) pwSwapPt2d (startuvln[0], startuvln[1]);

  /*
   * Trim the curves w.r.t. to the other segments of the curve.
   */
  if (extend_start)
  {
  }

  if (extend_stop)
  {
  }

  /*
   * Intersect these lines with Face boundaries.
   */
  if (extend_start)
  {
    struct PWcvdata startuvdata; 
    startuvdata.datatype = PWcvdata_py2d;
    startuvdata.data.py2d.num_pts = 2;
    startuvdata.data.py2d.p_pts = startuvln;

    /*
     * Get the range box.
     */
    pwGetRangeCvdata (&startuvdata, tmprng);
    uvcvrng[MINIMUM][U] = tmprng[0], uvcvrng[MINIMUM][V] = tmprng[1];
    uvcvrng[MAXIMUM][U] = tmprng[2], uvcvrng[MAXIMUM][V] = tmprng[3];

    PWsts = pwIntersectWithFace (&fcid, &startuvdata, NULL, uvcvrng, &sfdata,
                                 lentol, &p_start_intpts);
    OnErrorCode (PWsts, wrapup);

    PWsts = pwSortCvintptList (&p_start_intpts, uvtol);
    OnErrorCode (PWsts, wrapup);

    p_intpt = p_start_intpts;
    while (p_intpt)
    {
      p_intpt->intpt.cvpt.cvid = PW_K_NullObjid;
      p_intpt = p_intpt->p_next;
    } 
  }

  if (extend_stop)
  {
    struct PWcvdata stopuvdata; 

    stopuvdata.datatype = PWcvdata_py2d;
    stopuvdata.data.py2d.num_pts = 2;
    stopuvdata.data.py2d.p_pts = stopuvln;

    /*
     * Get the range box.
     */
    pwGetRangeCvdata (&stopuvdata, tmprng);
    uvcvrng[MINIMUM][U] = tmprng[0], uvcvrng[MINIMUM][V] = tmprng[1];
    uvcvrng[MAXIMUM][U] = tmprng[2], uvcvrng[MAXIMUM][V] = tmprng[3];

    PWsts = pwIntersectWithFace (&fcid, &stopuvdata, NULL, uvcvrng, &sfdata,
                                 lentol, &p_stop_intpts);
    OnErrorCode (PWsts, wrapup);

    PWsts = pwSortCvintptList (&p_stop_intpts, uvtol);
    OnErrorCode (PWsts, wrapup);

    p_intpt = p_stop_intpts;
    while (p_intpt)
    {
      p_intpt->intpt.cvpt.cvid = num_cvs;
      p_intpt = p_intpt->p_next;
    } 
  }

  /*
   * Delete the interactions at the ends of the intersection list.
   */
  p_head = pwHeadCvintptList (p_cvintpts);

  if (extend_start && p_start_intpts && p_head && 
      (p_head->intpt.cvpt.cvid == 0) &&
      (pwGetTopoposCvpt (&p_head->intpt.cvpt) == PWtopopos_start))
  {
    if (pwGetContainCvintpt (&p_head->intpt, RIGHT) == PWcontain_out)
    {
      p_intpt = pwTailCvintptList (p_start_intpts);
      pwSetContainCvintpt (&p_intpt->intpt, RIGHT, 
                           pwGetContainCvintpt (&p_head->intpt, RIGHT));
      pwRemoveCvintptList (&p_cvintpts, p_head);
      pwFreeCvintptList (p_head);
    }
    else
    {
      p_intpt = pwTailCvintptList (p_start_intpts);
      pwSetContainCvintpt (&p_head->intpt, LEFT, 
                           pwGetContainCvintpt (&p_intpt->intpt, LEFT));
      pwRemoveCvintptList (&p_start_intpts, p_intpt);
      pwFreeCvintptList (p_intpt);
    }
  }

  p_tail = pwTailCvintptList (p_cvintpts);

  if (extend_stop && p_stop_intpts && p_tail &&
      (p_tail->intpt.cvpt.cvid == (unsigned int) (num_cvs - 1)) &&
      (pwGetTopoposCvpt (&p_tail->intpt.cvpt) == PWtopopos_stop))
  {
    if (pwGetContainCvintpt (&p_tail->intpt, LEFT) == PWcontain_out)
    {
      p_intpt = pwHeadCvintptList (p_stop_intpts);
      pwSetContainCvintpt (&p_intpt->intpt, LEFT, 
                           pwGetContainCvintpt (&p_tail->intpt, LEFT));
      pwRemoveCvintptList (&p_cvintpts, p_tail);
      pwFreeCvintptList (p_tail);
    }
    else
    {
      p_intpt = pwHeadCvintptList (p_stop_intpts);
      pwSetContainCvintpt (&p_tail->intpt, RIGHT, 
                           pwGetContainCvintpt (&p_intpt->intpt, RIGHT));
      pwRemoveCvintptList (&p_stop_intpts, p_intpt);
      pwFreeCvintptList (p_intpt);
    }
  }

  /*
   * Modify the intersection point parameters on the starting line.
   */

  num_endcvs = 0; num_mod_cvs=0;
  if (p_start_intpts)
    num_endcvs ++;
  if (p_stop_intpts)
    num_endcvs ++;

  if (num_endcvs)
  {
    p_mod_uvcvs = (struct PWcvdata *) alloca ((num_cvs + num_endcvs) * 
                                              sizeof (struct PWcvdata));
  }
  else
  {
    p_mod_uvcvs = p_uvcvs;
  }

  if (p_start_intpts)
  { 
    pwPrefixCvintptList (&p_cvintpts, pwTailCvintptList (p_start_intpts));
    p_cvintpts = pwHeadCvintptList (p_cvintpts);

    p_mod_uvcvs[num_mod_cvs].datatype = PWcvdata_py2d;
    p_mod_uvcvs[num_mod_cvs].data.py2d.num_pts = 2;
    p_mod_uvcvs[num_mod_cvs].data.py2d.p_pts = startuvln;
 
    num_mod_cvs ++;
  }

  for (knt=0; knt<num_cvs; knt++)
  {
    memcpy (&p_mod_uvcvs[num_mod_cvs], &p_uvcvs[knt], sizeof (struct PWcvdata));
    num_mod_cvs ++;
  }

  if (p_stop_intpts)
  {
    pwAppendCvintptList (&p_cvintpts, p_stop_intpts);

    p_mod_uvcvs[num_mod_cvs].datatype = PWcvdata_py2d;
    p_mod_uvcvs[num_mod_cvs].data.py2d.num_pts = 2;
    p_mod_uvcvs[num_mod_cvs].data.py2d.p_pts = stopuvln;
    num_mod_cvs ++;
  }  
   
  if (p_start_intpts)
  {
    /*
     * Increase the curve indices.
     */
    p_intpt = p_cvintpts;
    while (p_intpt)
    {
      if (p_intpt->intpt.cvpt.cvid == PW_K_NullObjid)
        p_intpt->intpt.cvpt.cvid = 0;
      else
        p_intpt->intpt.cvpt.cvid += 1;
      p_intpt = p_intpt->p_next;
    } 
  }

  /*
   * Unset the Infonode property.
   */
  p_intpt = p_cvintpts;
  while (p_intpt)
  {
    pwUnsetInfoNodeCvintptList (p_intpt); 
    p_intpt = p_intpt->p_next;
  }

  p_head = pwHeadCvintptList (p_cvintpts);
  pwSetContainCvintpt (&p_head->intpt, PREV, PWcontain_out);
  p_tail = pwTailCvintptList (p_cvintpts);
  pwSetContainCvintpt (&p_tail->intpt, NEXT, PWcontain_out);

  *start_extended = (extend_start && p_start_intpts) ? TRUE : FALSE;
  *stop_extended = (extend_stop && p_stop_intpts) ? TRUE : FALSE;

  PWsts = modify_edge_pars (p_cvintpts, os, uvtol);
  OnErrorCode (PWsts, wrapup);

  PWsts = get_area_loops (num_mod_cvs, p_mod_uvcvs, p_cvintpts, reverse, 
                          *start_extended, *stop_extended, os, uvtol, 
                          num_loops, num_edges_loop, p_loops);
  OnErrorCode (PWsts, wrapup);

  /*
   * Generate the right curve indices.
   */
  if (*start_extended || *stop_extended)
  {
    regen_curve_indices (p_loops, num_cvs, *start_extended, *stop_extended);
  }

wrapup : 

  PW_Wrapup (PWsts, "pwCloseCvWithFace");
  return PWsts;
}


/* ------------------------ Static Functions Listing ------------------------ */


/*
  ABSTRACT

     If there is no interaction point at the start/stop of the intersection
     curve, this function is being called to add a dummy intersection point
     between at the start/stop of the intersection curve. The sibling  info
     of this interaction point is invalid as it is not interacting with the
     any of the surface boundary elements at this point.

     The classification of this interaction point is determined by it's ad-
     jacent interaction point if it is not a arbitrary one. If it is an ar-
     bitrary one, then it is later resolved by point locate.

  NOTES

     All the memory for the output is allocated in this routine.

*/

static PWresult AddNodeAtEnd
(
  struct PWcvintpt_list  **p_cvintpts,
  struct PWcvintpt_list  *p_node, /* to the side of this node */
  struct PWcvdata        *p_cvdata,
  int                    side
)
{
  /* status stuff */
  PWresult  PWsts = PW_K_Success;
  enum PWcontaintype containment=PWcontain_unknown;

  /* new node */
  struct PWcvintpt_list  *p_new_node=NULL;

  /*
   * allocate the memory for the new node
   */
  p_new_node = pwCreateCvintptList (NULL);
  OnErrorState (!p_new_node, PWsts, SetError(PW_K_Trimming, PW_K_DynamicMemory),
                wrapup);

  /*
   * Fill up data on the newly created node
   */
  if (side == LEFT)
  {
    pwGetEndCvptCvdata (p_cvdata, FALSE, FALSE, &p_new_node->intpt.cvpt);

    /*
     * Set the containment properties on this node.
     */
    pwSetContainCvintpt (&p_new_node->intpt, LEFT, PWcontain_unknown);

    if (p_node && !pwIsArbSeqCvintptList (p_node) &&
        (containment = pwGetContainCvintpt (&p_node->intpt, LEFT)) !=
            PWcontain_on)
    {
      pwSetContainCvintpt (&p_new_node->intpt, RIGHT, containment);
    }
    else
      pwSetContainCvintpt (&p_new_node->intpt, RIGHT, PWcontain_unknown);

    /*
     * Prepend the node, so that it becomes the head of the list
     */
    pwPrefixCvintptList (p_cvintpts, p_new_node);
  }
  else
  {
    pwGetEndCvptCvdata (p_cvdata, FALSE, TRUE, &p_new_node->intpt.cvpt);

    /*
     * Set the containment properties on this node.
     */
    if (p_node && !pwIsArbSeqCvintptList (p_node) &&
        (containment = pwGetContainCvintpt (&p_node->intpt, RIGHT)) !=
        PWcontain_on)
    {
      pwSetContainCvintpt (&p_new_node->intpt, LEFT, containment);
    }
    else
      pwSetContainCvintpt (&p_new_node->intpt, LEFT, PWcontain_unknown);

    pwSetContainCvintpt (&p_new_node->intpt, RIGHT, PWcontain_unknown);

    /*
     * Append the node, so that it becomes the tail of the list
     */
    pwAppendCvintptList (p_cvintpts, p_new_node);
  }

  /*
   * FOR THE TIME BEING, SET THE SIBLING ID AS NULL_OBJID. NEED TO BE CHANGED
   * AFTERWARDS.
   */
  p_new_node->intpt.sibling.props = 0;
  p_new_node->intpt.sibling.cvid = PW_K_NullObjid;
  p_new_node->intpt.sibling.cvparam.spaninx = 0;
  p_new_node->intpt.sibling.cvparam.spanpar = 0;
  memset (p_new_node->intpt.sibling.pt, 0, 3 * sizeof(double));

  /*
   * Set the property that this intpt does not contain any sibling info. which
   * states that it is not the result of the interaction between the boundary
   * and the intersection curve but is added to pickup the span.
   */

  pwSetNoSiblingCvintpt (&p_new_node->intpt);

wrapup :

  PW_Wrapup (PWsts, "AddNodeAtEnd");
  return PWsts;
}

/*
  ABSTRACT

     Given the interaction points list, xyztol, uvtol, surface ID and the
     intersection curve data, it classifies the  region  bounded  by  two   
     consequtive nodes by looking at their left and right contaiment pro-
     perties respectively.

     If the rels. are offending and the  region  is  non-degenerate,  the  
     region will be classified by point location by taking   mid point of 
     the region.

     If the rels. are offending and the region is degenerate, the region
     will be classified as "unknown".
 
  NOTES

     The region properties will updated after this call.
*/

static PWresult  ClassifyRegions
(
  struct PWcvintpt_list  **p_cvintpts, 
  double                 xyztol,
  double                 uvtol,
  struct PWgeomid        *p_sfgmid,
  struct PWcvdata        *p_uvcvs
)
{
  /* status stuff */
  PWresult  PWsts=PW_K_Success;

  /* local nodes */
  struct PWcvintpt_list  *p_node=NULL;
  PWosnum os=p_sfgmid->id.osnum;

  /* point locate info */
  enum PWptloctype ptpos=PWptloc_unknown;  
  PWobjid bdry_contain_elem=PW_K_NullObjid, lpid=PW_K_NullObjid;
  PWpoint uvpt={0.0, 0.0, 0.0};
  struct PWcvpt edpt;
  double cvpar=0;
  int cvinx=0;
  struct PWcvparam startcvpar, stopcvpar, cvparam;
 
  /* region containment */
  enum PWcontaintype  reg_cont=PWcontain_unknown; 

  memset (&edpt, 0, sizeof (struct PWcvpt));

  /* for each set of interaction points, classify the region */

  p_node = *p_cvintpts;
  
  if (p_node)
    pwSetContainCvintptList (p_node, PREV, PWcontain_unknown);

  while (p_node && p_node->p_next)
  {
    switch (GetCvRegion (p_node, p_node->p_next, uvtol))
    {
      case AREA : 
        pwSetContainCvintptList (p_node, NEXT, PWcontain_in); 
        pwSetContainCvintptList (p_node->p_next, PREV, PWcontain_in); 
        break;

      case HOLE :
        pwSetContainCvintptList (p_node, NEXT, PWcontain_out);
        pwSetContainCvintptList (p_node->p_next, PREV, PWcontain_out);
        break;

      case BDRY :
        pwSetContainCvintptList (p_node, NEXT, PWcontain_on);
        pwSetContainCvintptList (p_node->p_next, PREV, PWcontain_on);
        break;

      case DEGENERATE :
        pwSetContainCvintptList (p_node, NEXT, PWcontain_unknown);
        pwSetContainCvintptList (p_node->p_next, PREV, PWcontain_unknown);
        break;

      default :
        /*
         * Need for surface point locate.
         */
        memset (uvpt, 0, sizeof (PWpoint));

        if (p_node->intpt.cvpt.cvid == p_node->p_next->intpt.cvpt.cvid)
        {
          cvpar = (p_node->intpt.cvpt.cvparam.spaninx +
                   p_node->intpt.cvpt.cvparam.spanpar +
                   p_node->p_next->intpt.cvpt.cvparam.spaninx +
                   p_node->p_next->intpt.cvpt.cvparam.spanpar) / 2.0;
          cvinx = p_node->intpt.cvpt.cvid; 
        }
        else
        {

          if ((p_node->p_next->intpt.cvpt.cvid - p_node->intpt.cvpt.cvid) > 1)
          {
            cvinx = p_node->intpt.cvpt.cvid + 1;
            pwGetEndCvparCvdata (&p_uvcvs[cvinx], FALSE, FALSE, &startcvpar);
            pwGetEndCvparCvdata (&p_uvcvs[cvinx], FALSE, TRUE, &stopcvpar);
            cvpar = (startcvpar.spaninx + startcvpar.spanpar + 
                     stopcvpar.spaninx + stopcvpar.spanpar) / 2.0;
          }
          else if (pwGetTopoposCvpt (&p_node->intpt.cvpt) != PWtopopos_stop)
          {
            cvinx = p_node->intpt.cvpt.cvid;
            pwGetEndCvparCvdata (&p_uvcvs[cvinx], FALSE, TRUE, &stopcvpar);
            cvpar = (p_node->intpt.cvpt.cvparam.spaninx +
                     p_node->intpt.cvpt.cvparam.spanpar +
                     stopcvpar.spaninx + stopcvpar.spanpar) / 2.0;
          }
          else
          {
            cvinx = p_node->p_next->intpt.cvpt.cvid;
            pwGetEndCvparCvdata (&p_uvcvs[cvinx], FALSE, FALSE, &startcvpar);
            cvpar = (p_node->intpt.cvpt.cvparam.spaninx +
                     p_node->intpt.cvpt.cvparam.spanpar +
                     startcvpar.spaninx + startcvpar.spanpar) / 2.0;
          }
        }

        cvparam.spaninx = (int) cvpar;
        cvparam.spanpar = cvpar - cvparam.spaninx;

        PWsts = pwPtAtParCvdata (&p_uvcvs[cvinx], &cvparam, uvpt);
        OnErrorCode (PWsts, wrapup);

        edpt.p_attrib = NULL;

        PWsts = pwSfPtLocate (p_sfgmid, NULL, uvpt, xyztol, &ptpos, 
                 &bdry_contain_elem, &edpt);
        OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, 
                      PW_K_Internal), wrapup);

        if (edpt.p_attrib)
        {
          pwFreeAttribList (edpt.p_attrib);
          edpt.p_attrib = NULL;
        }

        /*
         * Set the Inter-action point properties 
         */
        switch (ptpos)
        {
          case PWptloc_onstartvtx :
          case PWptloc_onstopvtx :
          case PWptloc_onedge  :

            reg_cont = PWcontain_on;
            lpid = pwGetLpOfEd (bdry_contain_elem, os);
            if (pwGetLpOfEd (p_node->intpt.sibling.cvid, os) != lpid || 
                pwGetLpOfEd (p_node->p_next->intpt.sibling.cvid, os) != lpid)
            {
              /*
               * Probably this is a spurious interaction point. So, no need
               * for us to change it's containment. Set the region cotainm-
               * ent depending on the node containment.
               */
              
              pwSetContainCvintptList (p_node, NEXT, 
                          pwGetContainCvintpt (&p_node->intpt, RIGHT));
              pwSetContainCvintptList (p_node->p_next, PREV, 
                          pwGetContainCvintpt (&p_node->p_next->intpt, LEFT));
              p_node = p_node->p_next;
              continue; 
            }
            break;
 
          case PWptloc_inarea :

            reg_cont = PWcontain_in;
            lpid = bdry_contain_elem;
            break;

          case PWptloc_inhole :

            reg_cont = PWcontain_out;
            lpid = bdry_contain_elem;
            break;

          case PWptloc_outside :
   
            reg_cont = PWcontain_out;
            lpid = bdry_contain_elem;
            break;

          default :

            reg_cont = PWcontain_unknown;
            lpid = PW_K_NullObjid;
            break;
        }

        /* 
         * Set the region containment, depending on the point locate info.
         */
        pwSetContainCvintptList (p_node, NEXT, reg_cont);
        pwSetContainCvintptList (p_node->p_next, PREV, reg_cont);

        if (reg_cont != PWcontain_unknown)
        {
          /*
           * The region is defined clearly
           */

          if (!pwIsArbSeqCvintptList (p_node) ||
              pwGetContainCvintpt (&p_node->intpt, NEXT) == PWcontain_unknown)
          {
            /*
             * This node's relative containment is unknown. So, set it's 
             * containment property same as the region containment.
             */

            if (pwGetDebugLevel () >= PW_K_DebugWarning && 
                !pwIsArbSeqCvintptList (p_node) && 
                pwGetContainCvintpt (&p_node->intpt, NEXT) 
                  != PWcontain_unknown && 
                pwGetContainCvintpt (&p_node->intpt, NEXT) != reg_cont) 
            {
              char reg_str[PW_K_MaxStringLen], cont_str[PW_K_MaxStringLen];

              pwStringContain (reg_cont, reg_str);
              pwStringContain (pwGetContainCvintpt (&p_node->intpt, NEXT),
               cont_str);
              pwDebugLine (PW_K_DebugWarning,
               "Trim: Resetting Rels -- region = %s containment = %s\n",
               reg_str, cont_str);
            }

            pwSetContainCvintpt (&p_node->intpt, NEXT, reg_cont);
          }

          if (!pwIsArbSeqCvintptList (p_node->p_next) ||
              pwGetContainCvintpt (&p_node->p_next->intpt, PREV) == 
                                   PWcontain_unknown)
          {
            /*
             * This node's relative containment is unknown. So, set it's 
             * containment property same as the region containment.
             */

            if (pwGetDebugLevel () >= PW_K_DebugWarning && 
                !pwIsArbSeqCvintptList (p_node->p_next) &&
                pwGetContainCvintpt (&p_node->p_next->intpt, PREV) != 
                  PWcontain_unknown &&
                pwGetContainCvintpt (&p_node->p_next->intpt, PREV) != reg_cont)
            {
              char reg_str[PW_K_MaxStringLen], cont_str[PW_K_MaxStringLen];

              pwStringContain (reg_cont, reg_str);
              pwStringContain (pwGetContainCvintpt (&p_node->p_next->intpt,
               PREV), cont_str);
              pwDebugLine (PW_K_DebugWarning,
               "Trim: Resetting Rels -- region = %s containment = %s\n",
               reg_str, cont_str);
            }

            pwSetContainCvintpt (&p_node->p_next->intpt, PREV, reg_cont);
          }
        }

        /*
         * generate the attribute, to store the loop id
         */
        pwCreateIntAttrib (&p_node->p_attrib, 
          PW_AttribIdent (PW_K_Trimming, PW_K_LoopIdAttr, RIGHT), lpid);
        
        pwCreateIntAttrib (&p_node->p_next->p_attrib, 
          PW_AttribIdent (PW_K_Trimming, PW_K_LoopIdAttr, LEFT), lpid);

        break;
    }
   
    p_node = p_node->p_next;
  }

  if (p_node)
    pwSetContainCvintptList (p_node, NEXT, PWcontain_unknown);

wrapup : 

  /*
   * Free the Attribute list, if any generated by surface point locate.
   */
  if (edpt.p_attrib)
  {
    pwFreeAttribList (edpt.p_attrib);
    edpt.p_attrib = NULL;
  }

  PW_Wrapup (PWsts, "ClassifyRegions");
  return PWsts;
}

/*
  ABSTRACT

     Classifies the region bounded by two interaction points, by looking at
     the left and right containment rels of the nodes.

     If the rels. are toggling (IN/IN, OUT/OUT or ON/ON) and the region  is
     non-degenerate and also they are not arbitrary then return the  node's
     classification of the region classification (IN/OUT/ON).

     If region is degenerate one, then return DEGENERATE.

     If the rels are not toggling and one of them is NOT an arbitrary node,
     then return the rel of this node as region classification.

     If the rels are not toggling, then return OFFENDING.

  NOTES

     None
*/

static int GetCvRegion
(
  struct PWcvintpt_list  *p_intpt,
  struct PWcvintpt_list  *p_next_intpt,
  double                 tol  /* WHICH ONE TO PASS IN ? */
)
{
  enum PWcontaintype intpt_cont, next_intpt_cont, cont;
  enum PWtopopostype intpt_pos, next_intpt_pos;
  PWboolean          intpt_arbit=FALSE, next_intpt_arbit=FALSE, degen=FALSE;

  intpt_pos = pwGetTopoposCvpt (&p_intpt->intpt.cvpt);
  next_intpt_pos = pwGetTopoposCvpt (&p_next_intpt->intpt.cvpt);

  /*
   * Only if the topological position of this interaction point and next inter-
   * action points are same, there is a posibility of degeneracy, otherwise no
   * dgenracy. Check for the degeneracy against the incoming tolerance again.
   */

  if (intpt_pos == next_intpt_pos)
  {
    degen = (pwDistSqPtPt (p_intpt->intpt.cvpt.pt, p_next_intpt->intpt.cvpt.pt)
                  < (tol * tol)) ? TRUE : FALSE;
  }
  else
  {
    degen = FALSE;
  }

  /*
   * get the containment and the arbitrariness of this interaction point and
   * the next interaction point.
   */

  intpt_cont       = pwGetContainCvintpt (&p_intpt->intpt, RIGHT);
  next_intpt_cont  = pwGetContainCvintpt (&p_next_intpt->intpt, LEFT);
  intpt_arbit      = pwIsArbSeqCvintptList (p_intpt);
  next_intpt_arbit = pwIsArbSeqCvintptList (p_next_intpt);

  /*
   * if the rels does not toggle i.e. offending, and none of the rel is
   * 'unknown' (as unknown supposed to be considered as the wild card)
   * then return OFFENDING if not this span is degenerate else return
   * DEGENERATE.
   */

  if ((intpt_cont != next_intpt_cont) && (intpt_cont != PWcontain_unknown) &&
      (next_intpt_cont != PWcontain_unknown))
  {
    if (degen)
      return DEGENERATE;
    else
      return OFFENDING;
  }

  /*
   * if the both nodes are not 'Arbitrary' then
   *   if they are toggling correctly (except unknown)
   *   then
   *     return AREA/HOLE/BDRY
   *   else if one of the nodes is of 'unknown' rel
   *   then
   *     return AREA/HOLE/BDRY depending on the 'known' rel
   *   else (means 'unknown')
   *     if degenerate return DEGENERATE
   *     else return UNKNOWN
   *   fi
   * else
   *
   */

  if (!intpt_arbit && !next_intpt_arbit)
  {
    if ((intpt_cont == next_intpt_cont) && intpt_cont != PWcontain_unknown)
    {
      /*
       * The nodes are toggling and the containment is not 'unknown', so
       * contaiment is the containment of the nodes.
       */

      cont = intpt_cont;
    }
    else if (intpt_cont == PWcontain_on || next_intpt_cont == PWcontain_on)
    {
      /*
       * The nodes are NOT toggling. The possible combinations are :
       * 1) ? , in/out/on/?  2) in/out/on/?, ?
       * If it is ON, we would like to classify the region as UNKNOWN, the
       * reason being the interaction points are not getting classified
       * correctly in case of ON cases. Please refer to Curve-Region Docu-
       * ment for more info.
       */

      cont = PWcontain_unknown;
    }
    else if (intpt_cont != PWcontain_unknown)
    {
      /*
       * The nodes are NOT toggling. The possible combinations are :
       * 1) in/out, ?
       * So, classify the region as in/out as one of the nodes is clearly
       * defined.
       */

      cont = intpt_cont;
    }
    else
    {
      /*
       * The nodes are NOT toggling. The possible combinations are :
       * 1) ?, in/out/?
       * So, classify the region as in/out/? as one of the nodes is clearly
       * defined.
       */

      cont = next_intpt_cont;
    }
  }
  else if (!intpt_arbit)
    cont = intpt_cont;
  else if (!next_intpt_arbit)
    cont = next_intpt_cont;
  else
    cont = PWcontain_unknown;

  if (cont == PWcontain_in)
    return AREA;
  if (cont == PWcontain_out)
    return HOLE;
  if (cont == PWcontain_on)
    return BDRY;
  if (degen)
    return DEGENERATE;
  else
    return UNKNOWN;
}


/*
  ABSTRACT

  Determines whether to extend the ends of the input composite curve, given the
  end interaction points. The criterion to decide the extension is :

  a. If there is no interaction then extend them.
  b. If the interaction is with a face boundary, then don't extend otherwise
     extend the ends.
  c. If both the inteactions are with the same face boundary, then extend the
     ends.

  NOTES

  Returns the extension flags.

*/

static void is_extend_ends
(
  struct PWcvintpt_list *p_startnode,
  struct PWcvintpt_list *p_stopnode,

  PWobjid fcobj,
  PWosnum os,

  PWboolean *extend_start,
  PWboolean *extend_stop
)
{
  if (!p_startnode && !p_stopnode)
  {
    /*
     * Curve is not interacting with the face boundaries. So, extend the ends.
     */

    *extend_start = TRUE;
    *extend_stop = TRUE;
  }
  else 
  {
    /*
     * Curve is interacting with the face boundaries. 
     */

    PWobjid start_edge=PW_K_NullObjid, stop_edge=PW_K_NullObjid;
    PWobjid start_loop=PW_K_NullObjid, stop_loop=PW_K_NullObjid;
    PWboolean is_start_face=FALSE;
    enum PWcontaintype left_region=PWcontain_in, right_region=PWcontain_in;

    start_edge = p_startnode->intpt.sibling.cvid;
    stop_edge = p_stopnode->intpt.sibling.cvid;
    start_loop = pwGetLpOfEd (start_edge, os);
    stop_loop = pwGetLpOfEd (stop_edge, os);
    is_start_face = pwIsLpFace (start_loop, os);

    *extend_start = TRUE;
    *extend_stop = TRUE;

    if (start_loop == stop_loop) 
    {
      /*
       * Both the end interactions ending on the same loop.
       */

      if (is_start_face)
      {
        /*
         * The interacting loop is a face.
         */

        left_region = pwGetContainCvintpt (&p_startnode->intpt, LEFT);
        right_region = pwGetContainCvintpt (&p_stopnode->intpt, RIGHT);

        if (left_region == PWcontain_out || left_region == PWcontain_unknown)
        {
          /*
           * Left region of the interaction is in hole. No need to extend the
           * start.
           */

          *extend_start = FALSE;
        }

        if (right_region == PWcontain_out || right_region == PWcontain_unknown)
        {
          /*
           * Right region of the interaction is in hole. No need to extend the
           * stop.
           */

          *extend_stop = FALSE;
        }
      }
    }
    else
    {
      if (start_loop == fcobj)
      {
        /*
         * The first interaction is with the outer face boundary. 
         */

        left_region = pwGetContainCvintpt (&p_startnode->intpt, LEFT);
        if (left_region == PWcontain_out || left_region == PWcontain_unknown)
        {
          /*
           * Left region of the interaction is in hole. No need to extend the
           * start.
           */
           
          *extend_start = FALSE;
        }
      }

      if (stop_loop == fcobj)
      {
        /*
         * The last interaction is with the outer face boundary. 
         */

        right_region = pwGetContainCvintpt (&p_stopnode->intpt, RIGHT);
        if (right_region == PWcontain_out || right_region == PWcontain_unknown)
        {
          /*
           * Right region of the interaction is in hole. No need to extend the
           * stop.
           */
           
          *extend_stop = FALSE;
        }
      }
    }
  }
}


/*
  ABSTRACT

  Extends the given line in the given direction to intersect with a planar
  box and returns the stop point. Returns TRUE if the line has an interse-
  ction with the input box otherwise FALSE.

  NOTES

  None.
*/

static PWboolean extend_line_to_intersect_with_box
(
  PWpoint  startpt,
  PWvector dirvec,
  PWpoint  boxpts[4],
  PWpoint  stoppt
)
{
  int i=0, ln_code=0;
  PWboolean intersect=FALSE;
  BSrc BSmsg=BSSUCC;
  PWpoint tpt, intpt; 
  PWvector vec;
  double *p_pt1=NULL, *p_pt2=NULL, par=0;

  for (i=0; i<3; i++)
    tpt[i] = startpt[i] + dirvec[i];

  for (i=0; i<4; i++)
  {
    p_pt1 = boxpts[i];
    p_pt2 = (i) ? boxpts [i-1] : boxpts[3];

    if (BSxln (&BSmsg, p_pt1, p_pt2, startpt, tpt, intpt) && (BSmsg == BSSUCC))
    {
      /*
       * Test whether the intersection point is on bounded line or not.
       */
      
      BSprptonln (p_pt1, p_pt2, intpt, &ln_code, &par, &BSmsg);

      if (ln_code != 0)
      {
        pwMakeVec (startpt, intpt, vec);
        pwNormVec (vec, vec);

        if (pwDot (vec, dirvec) > 0.0)
        {
          intersect = TRUE;
          memcpy (stoppt, intpt, sizeof (PWpoint));
        }
      }
    }

    if (intersect)
      break;
  }

  return intersect;
}

/*
  ABSTRACT

  NOTES
*/

static PWresult get_bounded_uvline
(
  struct PWcvdata *p_uvcv,
  PWvector2d extvec,
  PWboolean atstart,

  PWrange2d rngbx,
  
  PWpoint2d uvln[2]
)
{
  PWresult PWsts=PW_K_Success;

  PWvector dirvec; 
  struct PWcvpt cvpt;
  PWpoint boxpts[4];
  PWpoint startpt, intpt;

  pwGetEndCvptCvdata (p_uvcv, FALSE, (PWboolean) !atstart, &cvpt);
  memcpy (uvln[0], cvpt.pt, sizeof (PWpoint2d));

  if (!extvec)
  {
    PWsts = pwGetTangentCvdata (p_uvcv, &cvpt.cvparam, FALSE, dirvec);
    OnErrorCode (PWsts, wrapup);
  }
  else
  {
    memcpy (dirvec, extvec, sizeof (PWvector2d));
  }

  dirvec[2] = 0.0;
  if (atstart && !extvec) pwRevVec2d (dirvec, dirvec);
  pwNormVec (dirvec, dirvec);

  memset (boxpts, 0, 4 * sizeof (PWpoint));
  boxpts[0][X] = rngbx[0][U];  boxpts[0][Y] = rngbx[0][V]; 
  boxpts[1][X] = rngbx[0][U];  boxpts[1][Y] = rngbx[1][V]; 
  boxpts[2][X] = rngbx[1][U];  boxpts[2][Y] = rngbx[1][V]; 
  boxpts[3][X] = rngbx[1][U];  boxpts[3][Y] = rngbx[0][V]; 

  memcpy (startpt, uvln[0], sizeof (PWpoint2d));
  startpt[2] = 0; 

  if (extend_line_to_intersect_with_box (startpt, dirvec, boxpts, intpt))
    memcpy (uvln[1], intpt, sizeof (PWpoint2d));
  else
    OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                  wrapup);

wrapup :

  PW_Wrapup (PWsts, "get_bounded_uvline");
  return PWsts;
}

/*
  ABSTRACT

  NOTES
*/

static PWresult get_area_loops
(
  int num_cvs,
  struct PWcvdata *p_cvs,
  struct PWcvintpt_list *p_cvintpts,
  PWboolean reverse,
  PWboolean start_extended,
  PWboolean stop_extended,
  PWosnum os,

  double uvtol,
  
  int *num_loops,
  int **num_edges_loop,
  struct PWgeomloop **p_loops
)
{
  PWresult PWsts=PW_K_Success;
  int bufsize=5, num_edges=0, iter=0;
  enum PWcontaintype containment=PWcontain_unknown;
  struct PWcvintpt_list *p_start_intpt=NULL, *p_intpt=NULL, *p_next_intpt=NULL;
  PWboolean loop_closed=FALSE, ignore_start=FALSE, ignore_stop=FALSE;

  *num_loops = 0;
  *num_edges_loop = 0;
  *p_loops = NULL;

  (*num_edges_loop) = (int *) malloc (bufsize * sizeof (int));
  OnErrorState (!*num_edges_loop, PWsts, SetError (PW_K_Pathway, 
                PW_K_DynamicMemory), wrapup);

  ignore_start = start_extended ? TRUE : FALSE;
  ignore_stop = stop_extended ? TRUE : FALSE;

  for (iter=0; iter<2; iter++)
  {
    while (p_start_intpt = ((iter == 0) ? get_nonvisited_intpt (num_cvs, 
                             p_cvintpts, ignore_start, ignore_stop) : 
     get_nonvisited_endintpt (num_cvs, p_cvintpts, ignore_start, ignore_stop)))
    {
      if (*num_loops > bufsize)
      {
        bufsize += 5;
        (*num_edges_loop) = (int *) realloc (*num_edges_loop, 
                                             bufsize * sizeof (int));
        OnErrorState (!*num_edges_loop, PWsts, SetError (PW_K_Pathway, 
                      PW_K_DynamicMemory), wrapup);
      }
    
      (*num_edges_loop)[*num_loops] = 0;
  
      loop_closed = FALSE;
      p_intpt = p_start_intpt;
  
      do
      {
        pwSetInfoNodeCvintptList (p_intpt);
        containment =  pwGetContainCvintpt (&p_intpt->intpt, RIGHT);
        num_edges = 0;
  
        if (containment == PWcontain_in) 
        {
          p_next_intpt = p_intpt->p_next;
  
          PWsts = get_areacv_geom (num_cvs, p_cvs, &p_intpt->intpt, 
                            &p_next_intpt->intpt, uvtol, &num_edges, p_loops);
          OnErrorCode (PWsts, wrapup);
        }
        else if (containment == PWcontain_on || containment == PWcontain_out)
        {
          p_next_intpt = get_next_intpt_onloop (p_intpt->intpt.sibling.cvid, os,
                             &p_intpt->intpt.sibling.cvparam, reverse, p_intpt, 
                             uvtol, p_cvintpts);
          OnErrorState (!p_next_intpt, PWsts, SetError (PW_K_Pathway, 
                        PW_K_Internal), wrapup);

          PWsts = get_bdrycv_geom (&p_intpt->intpt, &p_next_intpt->intpt, 
                             reverse, os, uvtol, &num_edges, p_loops);
          OnErrorCode (PWsts, wrapup);
        }
        else
        {
          OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                        wrapup);
        }
  
        p_intpt = p_next_intpt;
        (*num_edges_loop) [*num_loops] += num_edges;
  
        if (p_intpt == p_start_intpt)
        {
          loop_closed = TRUE;
        }
        else if (!p_intpt || pwIsInfoNodeCvintptList (p_intpt))
        {
          break;
        }
  
      } while (!loop_closed);

      if (loop_closed)
        (*num_loops) ++;

      if (iter == 1 && *num_loops)
        break;
    } 

    if (*num_loops)
    {
      break;
    }
    else
    {
      ignore_start = FALSE;
      ignore_stop = FALSE;
    }
  }

wrapup :

  PW_Wrapup (PWsts, "get_area_loops");
  return PWsts;
}

/*
  ABSTRACT

  NOTES
*/

static struct PWcvintpt_list *get_nonvisited_intpt
(
  int num_cvs,
  struct PWcvintpt_list *p_list,
  PWboolean ignore_start,
  PWboolean ignore_stop
)
{
  struct PWcvintpt_list *p_node=NULL;

  while (p_list)
  {
    if (!pwIsInfoNodeCvintptList (p_list))
    {
      if (!ignore_start && !ignore_stop)
      {
        p_node = p_list;
      }
      else if (ignore_start && ignore_stop)
      {
        if (p_list->intpt.cvpt.cvid != 0 && 
            p_list->intpt.cvpt.cvid != (unsigned int)(num_cvs -1))
          p_node = p_list;
      }
      else if (ignore_start)
      {
        if (p_list->intpt.cvpt.cvid != 0) 
          p_node = p_list;
      }
      else 
      {
        if (p_list->intpt.cvpt.cvid != (unsigned int) (num_cvs -1))
          p_node = p_list;
      }

      if (p_node)
        break;
    }

    p_list = p_list->p_next;
  }

  return p_node;
}

static struct PWcvintpt_list *get_nonvisited_endintpt
(
  int num_cvs,
  struct PWcvintpt_list *p_list,
  PWboolean ignore_start,
  PWboolean ignore_stop
)
{
  struct PWcvintpt_list *p_node=NULL, *p_outnode=NULL;
  double maxpar=0, minpar = 0, refpar=0;

  if (!ignore_start)
  {
    p_node = p_list;
    while (p_node)
    {
      if (!pwIsInfoNodeCvintptList (p_node) && (p_node->intpt.cvpt.cvid == 0))
      {
        refpar = p_node->intpt.cvpt.cvparam.spaninx + 
                 p_node->intpt.cvpt.cvparam.spanpar;
        if (!p_outnode)
        {
          p_outnode = p_node;
          maxpar = refpar;
        }
        else if (refpar > maxpar)
        {
          p_outnode = p_node;
          maxpar = refpar;
        }
      }
      p_node = p_node->p_next;
    }
  }

  if (!ignore_stop && !p_outnode)
  {
    p_node = p_list;

    while (p_node) 
    {
      if (!pwIsInfoNodeCvintptList (p_node) && 
          (p_node->intpt.cvpt.cvid == (unsigned int) (num_cvs -1)))
      {
        refpar = p_node->intpt.cvpt.cvparam.spaninx +
                 p_node->intpt.cvpt.cvparam.spanpar;
        if (!p_outnode)
        {
          p_outnode = p_node;
          minpar = refpar;
        }
        else if (refpar < minpar)
        {
          p_outnode = p_node;
          minpar = refpar;
        }
      }
      p_node = p_node->p_next;
    }
  }

  return p_outnode;
}

/*
  ABSTRACT

  NOTES
*/

static struct PWcvintpt_list *get_next_intpt_onedge
(
  PWobjid refedobj,
  PWosnum os,
  struct PWcvparam *p_refedpar,
  PWboolean reverse,
  struct PWcvintpt_list *p_refnode,
  double uvtol,
  struct PWcvintpt_list *p_list
)
{
  struct PWcvintpt_list *p_node=NULL, *p_tnode=NULL;
  PWboolean edclosed=FALSE;
  struct PWcvparam *p_edpar=NULL;
  double par=0, refpar=0, new_refpar=0;

  refpar = p_refedpar->spanpar + p_refedpar->spaninx;

  p_tnode = p_list;
  while (p_tnode)
  {
    if (p_tnode != p_refnode && p_tnode->intpt.sibling.cvid == refedobj) 
    {
      p_edpar = &p_tnode->intpt.sibling.cvparam;
      par = p_edpar->spanpar + p_edpar->spaninx;

      if ((reverse ? (par <= refpar) : (par >= refpar)) &&
          (p_node ? (reverse ? (par >= new_refpar) : (par <= new_refpar)) : 
                    TRUE))
      {
        new_refpar = par;
        p_node = p_tnode; 
      }
    }
    p_tnode = p_tnode->p_next;
  }

  if (!p_node)
  {
    PWobjid next_edobj=PW_K_NullObjid;

    next_edobj = pwGetNextEdNoDegen (refedobj, os, uvtol);
    if (next_edobj == refedobj)
      edclosed = TRUE;
    else
      edclosed = FALSE;
  }

  if (edclosed && !p_node)
  {
    struct PWcvparam edpar, tmppar;

    if (reverse)
      get_edge_endpars (refedobj, os, &tmppar, &edpar);
    else
      get_edge_endpars (refedobj, os, &edpar, &tmppar);

    refpar = edpar.spanpar + edpar.spaninx;
    reverse = !reverse; 

    p_tnode = p_list;

    while (p_tnode)
    {
      if (p_tnode != p_refnode && p_tnode->intpt.sibling.cvid == refedobj)
      {
        p_edpar = &p_tnode->intpt.sibling.cvparam;
        par = p_edpar->spanpar + p_edpar->spaninx;

        if ((reverse ? (par <= refpar) : (par >= refpar)) &&
            (p_node ? (reverse ? (par >= new_refpar) : (par <= new_refpar)) :
                    TRUE))
        {
          new_refpar = par;
          p_node = p_tnode; 
        }
      }
      p_tnode = p_tnode->p_next;
    }
  }

  return p_node;
}

/*
  ABSTRACT

  NOTES
*/

static struct PWcvintpt_list *get_next_intpt_onloop
(
  PWobjid refedobj,
  PWosnum os,
  struct PWcvparam *p_refedpar,
  PWboolean reverse,
  struct PWcvintpt_list *p_refnode,
  double uvtol,
  struct PWcvintpt_list *p_list
)
{
  int iter=0;
  PWobjid edobj=PW_K_NullObjid;
  struct PWcvintpt_list *p_node=NULL;
  struct PWcvparam edpar, tmppar;

  edobj = refedobj;
  memcpy (&edpar, p_refedpar, sizeof (struct PWcvparam));

  do
  {
    if (refedobj == edobj)
      iter ++;
    p_node = get_next_intpt_onedge (edobj, os, &edpar, reverse, p_refnode, 
                                    uvtol, p_list);
    if (!p_node)
    {
      if (reverse)
      {
        edobj = pwGetPrevEd (edobj, os);
        get_edge_endpars (edobj, os, &tmppar, &edpar);
      }
      else
      {
        edobj = pwGetNextEd (edobj, os);
        get_edge_endpars (edobj, os, &edpar, &tmppar);
      }
    }
  } while (!p_node && iter != 2);

  return p_node;
}

/*
  ABSTRACT

  NOTES
*/
static PWresult get_areacv_geom 
(
  int num_cvs, 
  struct PWcvdata *p_cvs, 
  struct PWcvintpt *p_intpt1, 
  struct PWcvintpt *p_intpt2, 

  double uvtol,

  int *num_outcvs,
  struct PWgeomloop **p_outcvs
)
{
  PWresult PWsts=PW_K_Success;
  int num_partcvs=0, num_midcvs=0, knt=0;
  int cvinx[2], inx=0;
  struct PWcvparam cvparam[4], midparam;
  enum PWtopopostype topopos[2]={PWtopopos_unknown, PWtopopos_unknown};
  struct PWgeomloop *p_node=NULL;
  PWboolean atstart=FALSE, atstop=FALSE;

  *num_outcvs = 0;
  num_cvs = num_cvs;

  if (pwGetTopoposCvpt (&p_intpt1->cvpt) == PWtopopos_stop)
  {
    cvinx[0] = p_intpt1->cvpt.cvid+1;
    pwGetEndCvparCvdata (&p_cvs[cvinx[0]], FALSE, FALSE, &cvparam[0]);
    topopos[0] = PWtopopos_start;
  }
  else 
  {
    cvinx[0] = p_intpt1->cvpt.cvid;
    memcpy (&cvparam[0], &p_intpt1->cvpt.cvparam, sizeof (struct PWcvparam));
    topopos[0] = pwGetTopoposCvpt (&p_intpt1->cvpt);
  }

  if (pwGetTopoposCvpt (&p_intpt2->cvpt) == PWtopopos_start)
  {
    cvinx[1] = p_intpt2->cvpt.cvid-1;
    pwGetEndCvparCvdata (&p_cvs[cvinx[1]], FALSE, TRUE, &cvparam[3]);
    topopos[1] = PWtopopos_stop;
  }
  else 
  {
    cvinx[1] = p_intpt2->cvpt.cvid;
    memcpy (&cvparam[3], &p_intpt2->cvpt.cvparam, 
            sizeof (struct PWcvparam));
    topopos[1] = pwGetTopoposCvpt (&p_intpt2->cvpt);
  }

  if (cvinx[0] == cvinx[1])
  {
    if (topopos[0] == PWtopopos_start && topopos[1] == PWtopopos_stop)
      num_midcvs = 1;
    else
    {
      atstart = TRUE;
      num_partcvs = 1;
      memcpy (&cvparam[1], &cvparam[3], sizeof (struct PWcvparam));
    }
  }
  else
  {
    num_midcvs = cvinx[1] - cvinx[0] - 1;

    if (topopos[0] == PWtopopos_start)
      num_midcvs ++;  
    else
    {
      atstart = TRUE;
      pwGetEndCvparCvdata (&p_cvs[cvinx[0]], FALSE, TRUE, &cvparam[1]);
      num_partcvs ++;
    }

    if (topopos[1] == PWtopopos_stop)
      num_midcvs ++;
    else
    {
      atstop = TRUE;
      pwGetEndCvparCvdata (&p_cvs[cvinx[1]], FALSE, FALSE, &cvparam[2]);
      num_partcvs ++;
    }
  }

  *num_outcvs = num_midcvs + num_partcvs;

  if (atstart)
  {
    inx = cvinx[0];

    p_node = pwCreateGeomloop (p_outcvs);

    pwGetMidCvpar (&cvparam[0], &cvparam[1], 0.5, &midparam);

    PWsts = alloc_partcvdata (&p_cvs[inx], &p_node->edge);
    OnErrorCode (PWsts, wrapup);

    PWsts = pwPartOfCvdata (&p_cvs[inx], &cvparam[0], &cvparam[1], &midparam,
                            uvtol, &p_node->edge); 
    OnErrorCode (PWsts, wrapup);

    pwCreateIntAttrib (&p_node->p_attrib, PW_AttribIdent (PW_K_Trimming, 
                       PW_K_CurveInxAttr, 0), inx);
  }

  for (knt=0, inx = (atstart ? (cvinx[0]+1) : cvinx[0]); knt<num_midcvs; 
                                                       knt++, inx++)
  {
    p_node = pwCreateGeomloop (p_outcvs);
    OnErrorState (!p_node, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                  wrapup);

    PWsts = alloc_cvdata (&p_cvs[inx], &p_node->edge);
    OnErrorCode (PWsts, wrapup);

    pwCopyCvdata (&p_cvs[inx], &p_node->edge);

    pwCreateIntAttrib (&p_node->p_attrib, PW_AttribIdent (PW_K_Trimming, 
                       PW_K_CurveInxAttr, 0), inx);
  }

  if (atstop)
  {
    inx = cvinx[1];

    p_node = pwCreateGeomloop (p_outcvs);

    pwGetMidCvpar (&cvparam[2], &cvparam[3], 0.5, &midparam);

    PWsts = alloc_partcvdata (&p_cvs[inx], &p_node->edge);
    OnErrorCode (PWsts, wrapup);

    PWsts = pwPartOfCvdata (&p_cvs[inx], &cvparam[2], &cvparam[3], &midparam,
                            uvtol, &p_node->edge); 
    OnErrorCode (PWsts, wrapup);

    pwCreateIntAttrib (&p_node->p_attrib, PW_AttribIdent (PW_K_Trimming, 
                       PW_K_CurveInxAttr, 0), inx);
  }

wrapup :

  PW_Wrapup (PWsts, "get_areacv_geom");
  return PWsts;
}

/*
  ABSTRACT

  NOTES
*/

static PWresult get_bdrycv_geom 
(
  struct PWcvintpt *p_intpt1, 
  struct PWcvintpt *p_intpt2, 
  PWboolean reverse,
  PWosnum os,

  double uvtol,
  
  int *num_outeds,
  struct PWgeomloop **p_outeds
)
{
  PWresult PWsts=PW_K_Success;
  int num_parteds=0, num_mideds=0, knt=0;
  double par1=0, par2=0;
  PWobjid edobjs[2], edobj=PW_K_NullObjid;
  PWobjid *mid_edobjs=NULL, lpobj=PW_K_NullObjid;
  enum PWtopopostype topopos[2];
  struct PWcvparam edparam[4], tmpparam, midparam[2];
  PWboolean atstart=FALSE, atstop=FALSE; 
  struct PWcvdata edgeom;
  struct PWgeomloop *p_node=NULL;
  
  *num_outeds = 0;

  /*
   * Move from First intersection to Second intersection point and while 
   * moving get all the curves in it's way.
   */
  topopos[0] = pwGetTopoposCvpt (&p_intpt1->sibling);
  topopos[1] = pwGetTopoposCvpt (&p_intpt2->sibling);
  edobjs[0] = p_intpt1->sibling.cvid;
  edobjs[1] = p_intpt2->sibling.cvid;
  
  if (reverse ? topopos[0] == PWtopopos_start : topopos[0] == PWtopopos_stop)
  {
    topopos[0] = reverse ? PWtopopos_stop : PWtopopos_start;
    edobjs[0] = reverse ? pwGetPrevEdNoDegen (edobjs[0], os, uvtol) : 
                          pwGetNextEdNoDegen (edobjs[0], os, uvtol) ; 
    get_edge_endpars (edobjs[0], os, reverse ? &tmpparam : &edparam[0], 
                    reverse ? &edparam[0] : &tmpparam);
  } 
  else
  {
    memcpy (&edparam[0], &p_intpt1->sibling.cvparam, sizeof (struct PWcvparam));
  }

  if (reverse ? topopos[1] == PWtopopos_stop : topopos[1] == PWtopopos_start)
  {
    topopos[1] = reverse ? PWtopopos_start : PWtopopos_stop;
    edobjs[1] = reverse ? pwGetNextEdNoDegen (edobjs[1], os, uvtol) : 
                          pwGetPrevEdNoDegen (edobjs[1], os, uvtol) ; 
    get_edge_endpars (edobjs[1], os, reverse ? &edparam[3] : &tmpparam,
                    reverse ? &tmpparam : &edparam[3]);
  } 
  else
  {
    memcpy (&edparam[3], &p_intpt2->sibling.cvparam, sizeof (struct PWcvparam));
  }

  lpobj = pwGetLpOfEd (edobjs[0], os);
  mid_edobjs = (PWobjid *) alloca (pwNumEdsOfLp (lpobj, os) * 
                                   sizeof (PWobjid)); 

  if ((edobjs[0] == edobjs[1]) && 
      pwGetNextEdNoDegen (edobjs[0], os, uvtol) == edobjs[0])
  {
    /*
     * Edge is closed and both the intersections end on this edge.
     */
    if (reverse ? 
         (topopos[0] == PWtopopos_stop && topopos[1] == PWtopopos_start) : 
         (topopos[0] == PWtopopos_start && topopos[1] == PWtopopos_stop))
    {
      /* Extract the full edge */

      num_mideds = 1;
      mid_edobjs[0] = edobjs[0];
    }
    else
    {
      /* Extract part of the edge */

      num_parteds = 1; atstart = TRUE;
      memcpy (&edparam[1], &edparam[3], sizeof (struct PWcvparam)); 
      par1 = edparam[0].spaninx + edparam[0].spanpar;
      par2 = edparam[1].spaninx + edparam[1].spanpar;
      if (reverse ? (par1 > par2) : (par2 > par1))
      {
        pwGetMidCvpar (&edparam[0], &edparam[1], 0.5, &midparam[0]);
      }
      else
      {
        get_edge_endpars (edobjs[0], os, &midparam[0], &tmpparam);
      }
    } 
  }
  else
  {
    num_parteds = 0;
    num_mideds = 0;

    par1 = edparam[0].spaninx + edparam[0].spanpar;
    par2 = edparam[3].spaninx + edparam[3].spanpar;

    if ((edobjs[0] == edobjs[1]) && (reverse ? (par1 > par2) : (par2 > par1)))
    {
      if (reverse ? 
           (topopos[0] == PWtopopos_stop && topopos[1] == PWtopopos_start) : 
           (topopos[0] == PWtopopos_start && topopos[1] == PWtopopos_stop))
      {
        /* Extract the full edge */

        num_mideds = 1;
        mid_edobjs[0] = edobjs[0];
      }
      else
      {
        /* Extract part of the edge */

        num_parteds = 1; atstart = TRUE;
        memcpy (&edparam[1], &edparam[3], sizeof (struct PWcvparam)); 
        pwGetMidCvpar (&edparam[0], &edparam[1], 0.5, &midparam[0]);
      }
    }
    else
    {
      if (topopos[0] == PWtopopos_middle)
      {
        atstart = TRUE;
        get_edge_endpars (edobjs[0], os, reverse ? &edparam[1] : &tmpparam, 
                        reverse ? &tmpparam : &edparam[1]);
        pwGetMidCvpar (&edparam[0], &edparam[1], 0.5, &midparam[0]);
        num_parteds ++;
      }
      else
      {
        mid_edobjs[num_mideds] = edobjs[0];
        num_mideds ++;
      }

      edobj = reverse ? pwGetPrevEdNoDegen (edobjs[0], os, uvtol) :
                        pwGetNextEdNoDegen (edobjs[0], os, uvtol) ; 
      while (edobj != edobjs[1])
      {
        mid_edobjs[num_mideds] = edobj;
        num_mideds ++;
        edobj = reverse ? pwGetPrevEdNoDegen (edobj, os, uvtol) :
                          pwGetNextEdNoDegen (edobj, os, uvtol) ; 
      }

      if (topopos[1] == PWtopopos_middle)
      {
        atstop = TRUE;
        get_edge_endpars (edobjs[1], os, reverse ? &tmpparam : &edparam[2], 
                        reverse ? &edparam[2] : &tmpparam);
        pwGetMidCvpar (&edparam[2], &edparam[3], 0.5, &midparam[1]);
        num_parteds ++;
      }
      else
      {
        mid_edobjs[num_mideds] = edobjs[1];
        num_mideds ++;
      }
    }
  }


  if (atstart)
  {
    edobj = edobjs[0];

    PWsts = PW_GetEdGeomStack (edobj, os, edgeom);
    OnErrorCode (PWsts, wrapup);

    p_node = pwCreateGeomloop (p_outeds);
    OnErrorState (!p_node, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                  wrapup);

    PWsts = alloc_partcvdata (&edgeom, &p_node->edge);
    OnErrorCode (PWsts, wrapup);

    p_node->free_edge = pwFreeCvdataGeom;

    PWsts = pwPartOfCvdata (&edgeom, reverse ? &edparam[1] : &edparam[0], 
                            reverse ? &edparam[0] : &edparam[1], &midparam[0],
                            uvtol, &p_node->edge);
    OnErrorCode (PWsts, wrapup);

    if (reverse) pwRevCvdata (&p_node->edge);

    /*
     * Create an attribute on this node, which shows the edge id.
     */
    pwCreateIntAttrib (&p_node->p_attrib, PW_AttribIdent (PW_K_Trimming, 
                       PW_K_EdgeIdAttr, 0), edobj);
  }

  for (knt=0; knt<num_mideds; knt++)
  {
    p_node = pwCreateGeomloop (p_outeds);
    OnErrorState (!p_node, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                  wrapup);

    PWsts = PW_GetEdGeomHeap (mid_edobjs[knt], os, p_node->edge);
    OnErrorCode (PWsts, wrapup);

    p_node->free_edge = NULL;

    if (reverse) pwRevCvdata (&p_node->edge);

    pwCreateIntAttrib (&p_node->p_attrib, PW_AttribIdent (PW_K_Trimming, 
                       PW_K_EdgeIdAttr, 0), mid_edobjs[knt]);
  }

  if (atstop)
  {
    edobj = edobjs[1];

    PWsts = PW_GetEdGeomStack (edobj, os, edgeom);
    OnErrorCode (PWsts, wrapup);

    p_node = pwCreateGeomloop (p_outeds);
    OnErrorState (!p_node, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                  wrapup);

    PWsts = alloc_partcvdata (&edgeom, &p_node->edge);
    OnErrorCode (PWsts, wrapup);

    p_node->free_edge = pwFreeCvdataGeom;

    PWsts = pwPartOfCvdata (&edgeom, reverse ? &edparam[3] : &edparam[2], 
                            reverse ? &edparam[2] : &edparam[3], &midparam[1],
                            uvtol, &p_node->edge);
    OnErrorCode (PWsts, wrapup);

    if (reverse) pwRevCvdata (&p_node->edge);

    pwCreateIntAttrib (&p_node->p_attrib, PW_AttribIdent (PW_K_Trimming, 
                       PW_K_EdgeIdAttr, 0), edobj);
  }

  *num_outeds = num_mideds + num_parteds;

wrapup :

  PW_Wrapup (PWsts, "get_bdrycv_geom");
  return PWsts;
}

/*
  ABSTRACT

  NOTES
*/

static PWresult alloc_cvdata
(
  struct PWcvdata *p_incv,
  struct PWcvdata *p_outcv
)
{
  BSrc BSmsg=BSSUCC;
  PWresult PWsts=PW_K_Success;
 
  switch (p_incv->datatype)
  {
    case PWcvdata_py2d : 
      p_outcv->data.py2d.p_pts = (PWpoint2d *) 
          malloc (p_incv->data.py2d.num_pts * sizeof (PWpoint2d)); 
      OnErrorState (!p_outcv->data.py2d.p_pts, PWsts, 
                    SetError (0, PW_K_DynamicMemory), wrapup);
      break;

    case PWcvdata_py : 
      p_outcv->data.py.p_pts = (PWpoint *) 
          malloc (p_incv->data.py.num_pts * sizeof (PWpoint)); 
      OnErrorState (!p_outcv->data.py.p_pts, PWsts, 
                    SetError (0, PW_K_DynamicMemory), wrapup);
      break;

    case PWcvdata_bspcv :
      BSalloccv (p_incv->data.p_bspcv->order, p_incv->data.p_bspcv->num_poles,
        p_incv->data.p_bspcv->rational, 0, &p_outcv->data.p_bspcv, &BSmsg);
      OnErrorState (!p_outcv->data.p_bspcv, PWsts, 
                    SetError (0, PW_K_DynamicMemory), wrapup);
      break;

    case PWcvdata_gmbspcv : 
      p_outcv->data.p_gmbspcv = (struct BSgeom_bsp_curve *) 
                                 malloc (sizeof (struct BSgeom_bsp_curve));
      OnErrorState (!p_outcv->data.p_gmbspcv, PWsts, 
                    SetError (0, PW_K_DynamicMemory), wrapup);
      BSalloccv (p_incv->data.p_gmbspcv->bspcv->order, 
                 p_incv->data.p_gmbspcv->bspcv->num_poles, 
                 p_incv->data.p_gmbspcv->bspcv->rational, 0,
                 &p_outcv->data.p_gmbspcv->bspcv, &BSmsg);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (0, PW_K_DynamicMemory), 
                    wrapup);
      break;

    default : 
      break;
  }

wrapup :
  return PWsts;
}

/*
  ABSTRACT

  NOTES
*/

static PWresult alloc_partcvdata
(
  struct PWcvdata *p_incv,
  struct PWcvdata *p_outcv
)
{
  BSrc BSmsg=BSSUCC;
  PWresult PWsts=PW_K_Success;
 
  switch (p_incv->datatype)
  {
    case PWcvdata_py2d : 
      p_outcv->data.py2d.p_pts = (PWpoint2d *) 
          malloc (p_incv->data.py2d.num_pts * sizeof (PWpoint2d)); 
      OnErrorState (!p_outcv->data.py2d.p_pts, PWsts, 
                    SetError (0, PW_K_DynamicMemory), wrapup);
      break;

    case PWcvdata_py : 
      p_outcv->data.py.p_pts = (PWpoint *) 
          malloc (p_incv->data.py.num_pts * sizeof (PWpoint)); 
      OnErrorState (!p_outcv->data.py.p_pts, PWsts, 
                    SetError (0, PW_K_DynamicMemory), wrapup);
      break;

    case PWcvdata_bspcv :
      BSalloccv (p_incv->data.p_bspcv->order, 
        (p_incv->data.p_bspcv->num_poles * 2 + p_incv->data.p_bspcv->order -1),
        p_incv->data.p_bspcv->rational, 0, &p_outcv->data.p_bspcv, &BSmsg);
      OnErrorState (!p_outcv->data.p_bspcv, PWsts, 
                    SetError (0, PW_K_DynamicMemory), wrapup);
      break;

    case PWcvdata_gmbspcv : 
      p_outcv->data.p_gmbspcv = (struct BSgeom_bsp_curve *) 
                                 malloc (sizeof (struct BSgeom_bsp_curve));
      OnErrorState (!p_outcv->data.p_gmbspcv, PWsts, 
                    SetError (0, PW_K_DynamicMemory), wrapup);
      BSalloccv (p_incv->data.p_gmbspcv->bspcv->order, 
                 (p_incv->data.p_gmbspcv->bspcv->num_poles * 2 + 
                  p_incv->data.p_gmbspcv->bspcv->order - 1),
                  p_incv->data.p_gmbspcv->bspcv->rational, 0,
                 &p_outcv->data.p_gmbspcv->bspcv, &BSmsg); 
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (0, PW_K_DynamicMemory), 
                    wrapup);
      break;

    default : 
      break;
  }

wrapup : 

  return PWsts;
}

/*
  ABSTRACT

  NOTES
*/

static PWresult modify_edge_pars
(
  struct PWcvintpt_list *p_list,
  PWosnum os,
  double uvtol
)
{
  PWresult PWsts=PW_K_Success;
  struct PWcvintpt_list *p_node=NULL;

  p_node = p_list;
  while (p_node)
  {
    PWsts = cnvt_edgepar (p_node->intpt.sibling.cvid, os, 
                          &p_node->intpt.sibling, uvtol, 
                          &p_node->intpt.sibling.cvparam);
    OnErrorCode (PWsts, wrapup);

    p_node = p_node->p_next;
  }

wrapup :

  PW_Wrapup (PWsts, "modify_edge_pars");
  return PWsts;
}

/*
  ABSTRACT

  NOTES
*/

static PWresult cnvt_edgepar
(
  PWobjid edobj,
  PWosnum os,
  struct PWcvpt *p_edpt,
  double uvtol, 

  struct PWcvparam *p_edpar
)
{
  PWresult PWsts=PW_K_Success;
  struct PWcvdata eddata;
  PWpoint minpt;
  enum PWtopopostype topopos=PWtopopos_unknown;

  PWsts = PW_GetEdGeomStack (edobj, os, eddata);
  OnErrorCode (PWsts, wrapup);
  
  topopos = pwGetTopoposCvpt (p_edpt);

  if (topopos == PWtopopos_start)
  {
    pwGetEndCvparCvdata (&eddata, FALSE, FALSE, p_edpar);
  }
  else if (topopos == PWtopopos_stop)
  {
    pwGetEndCvparCvdata (&eddata, FALSE, TRUE, p_edpar);
  }
  else
  {
    PWsts = pwParAtPtCvdata (&eddata, p_edpt->pt, 10 * uvtol, minpt, p_edpar);
    OnErrorCode (PWsts, wrapup);
  }

wrapup :

  PW_Wrapup (PWsts, "cnvt_edgepar");
  return PWsts;
} 


/*
  ABSTRACT

  NOTES
*/

static PWresult get_edge_endpars
(
  PWobjid edobj,
  PWosnum os,
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar
)
{
  PWresult PWsts=PW_K_Success;
  struct PWcvdata eddata;

  PWsts = PW_GetEdGeomStack (edobj, os, eddata);
  OnErrorCode (PWsts, wrapup);
  
  pwGetEndCvparCvdata (&eddata, FALSE, FALSE, p_startpar);
  pwGetEndCvparCvdata (&eddata, FALSE, TRUE, p_stoppar);

wrapup :

  PW_Wrapup (PWsts, "get_edge_endpars");
  return PWsts;
} 


/*
  ABSTRACT

  NOTES

*/

static void regen_curve_indices
(
  struct PWgeomloop **p_loops,
  int num_cvs,
  PWboolean start_extended,
  PWboolean stop_extended
)
{
  int cvinx=0, num_mod_cvs=0;
  struct PWgeomloop *p_node=*p_loops;

  num_mod_cvs = num_cvs;
  if (start_extended)
    num_mod_cvs ++;
  if (stop_extended)
    num_mod_cvs ++;

  while (p_node)
  {
    if (p_node->p_attrib && (p_node->p_attrib->ident ==  
          (PW_AttribIdent (PW_K_Trimming, PW_K_CurveInxAttr, 0))))
    {
      cvinx = p_node->p_attrib->attrib.int_attrib;
      if (start_extended && cvinx == 0) 
      {
        p_node->p_attrib->attrib.int_attrib = -1;
      } 
      else if (stop_extended && (cvinx == (num_mod_cvs-1)))
      {
        p_node->p_attrib->attrib.int_attrib = num_cvs;
      }
      else if (start_extended)
      {
        p_node->p_attrib->attrib.int_attrib -= 1;
      }
    }
    p_node = p_node->p_next;
  }
}

/* ---------------------- End Of Static Functions Listing ------------------- */

/*
  ABSTRACT

  NOTES

*/

void pwCopyCvdata
(
  struct PWcvdata *p_incv,
  struct PWcvdata *p_outcv
)
{
  BSrc BSmsg=BSSUCC;
  p_outcv->datatype = p_incv->datatype;

  switch (p_incv->datatype)
  {
    case PWcvdata_pt2d :
      memcpy (p_outcv->data.pt2d, p_incv->data.pt2d, sizeof (PWpoint2d));
    break;

    case PWcvdata_pt :
      memcpy (p_outcv->data.pt, p_incv->data.pt, sizeof (PWpoint));
    break;

    case PWcvdata_py2d :
      p_outcv->data.py2d.num_pts = p_incv->data.py2d.num_pts;
      memcpy (p_outcv->data.py2d.p_pts, p_incv->data.py2d.p_pts, 
              p_incv->data.py2d.num_pts * sizeof (PWpoint2d));
    break;

    case PWcvdata_py : 
      p_outcv->data.py.num_pts = p_incv->data.py.num_pts;
      memcpy (p_outcv->data.py.p_pts, p_incv->data.py.p_pts, 
              p_incv->data.py.num_pts * sizeof (PWpoint));
    break;

    case PWcvdata_bspcv :
      BScv_copy (&BSmsg, p_incv->data.p_bspcv, p_outcv->data.p_bspcv);
      break;

    case PWcvdata_gmbspcv :
    {
      struct IGRbsp_curve *p_cv=NULL;

      p_cv = p_outcv->data.p_gmbspcv->bspcv;
      memcpy (p_outcv->data.p_gmbspcv, p_incv->data.p_gmbspcv,  
              sizeof (struct BSgeom_bsp_curve));
      p_outcv->data.p_gmbspcv->bspcv = p_cv;
      BScv_copy (&BSmsg, p_incv->data.p_gmbspcv->bspcv, 
                 p_outcv->data.p_gmbspcv->bspcv); 
    }
    break;

    default : 
      break;
  }

  return;
}

/*
  ABSTRACT

  NOTES

*/

void pwGetMidCvpar
(
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  double dist_factor,
  
  struct PWcvparam *p_par
)
{
  double par=0;

  par = (p_startpar->spaninx + p_startpar->spanpar + 
         p_stoppar->spaninx + p_stoppar->spanpar) * dist_factor;
  p_par->spaninx = (int) par;
  p_par->spanpar = par - (int) par;

  return;
}

