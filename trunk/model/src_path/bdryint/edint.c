/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT

     Determines all the geometric interaction points between  a  UV-curve  in 
     the UV-space of the surface and an edge, outputs  the interaction points 
     in a linked list.
 
  DESCRIPTION

     Given a UV curve in the UV-space of surface, and edge id, it  outputs all 
     the  geometric interaction points with the edge.The UV curve is typically 
     an intersection curve in the UV-space of the surface as it interacts with 
     another surface.

     A significant output is the relative containment classification of these
     interaction points. The classification is in terms of  how  the UV curve
     is flows with respect to the flow of the edge. That is, whether it is IN
     ->OUT, IN->ON, ON->OUT, etc., where,  'IN' refers to inside  area, 'OUT' 
     refers to outside area (or inside hole),'ON' refers to on the edge. Thus,
     there can be 9  possible classes into which the interactions fit. 

     The direction of flow of edge is such that, it always bounds an area. 

     This function  optionally takes in the XYZ curve data,  to check for the
     pure overlaps in XYZ space  as there is always a  destortion between the
     UV and XYZ spaces. If the  XYZ curve data is not  passed in, extra check
     for the overlap in XYZ space  will not be  carried out and  whatever the
     overlap region found in UV space will be output.

     'uvcv' is the UV-curve, 'xyzcv' is the XYZ-curve, 'xyztol' is the toler-
     ance is XYZ  space (typically chord height tolerance),  'edid'  edge id 
     with which the intersection need to be done. The output from this funct-
     ion is a linked list 'cvintpts', contain  all  the information about the 
     interaction points. This  linked  list structure primarily points to the 
     interaction point on the UV-curve, and also contains the similar inform-
     ation about this interaction as seen on the edge. This similar informat-
     ion is the 'sibling' information. The actual points being  returned  are 
     computed on the respective geometrices i.e. UV-curve and edge.

  NOTES

     Care is taken to see that the zero-length tolerance being  passed  in is  
     strictly respected.

     All the memory for the interaction points is allocated in this function.
     So, it is the caller's responsibility to free the  memory  allocated  by 
     calling respective free function(s).
 
  ARGUMENTS

     p_edid      I  Loop ID, with which the interaction should take place.
     p_uvcv      I  UV-space geometry of the intersection  curve  which  is
                    typically output of the BS math function of sf-sf inte-
                    rsection.
     p_xyzcv     I  The corrseponding model space (XYZ) counterpart for the
                    intersection curve.  Could be NULL. If this is NULL, no
                    overlap check in XYZ space is done.
     uvcvrng     I  The min/max range box of the UV intersection curve.This
                    is input so that this function does not compute someth-
                    ing already computed once before,  which  will be quite
                    often. The justification for this is solely optimization.
     p_sfdata    I  Surface data to which the face belongs. It could be plain
                    B-spline geometry or a plane definition. 
     xyztol      I  The value which defines the distance within which 2 cur-
                    ves/part of curves are overlaping.

     p_cvintpts I/O A linked list of PWcvintpt_list structures that conatain
                    all the information about  the  interaction points. This 
                    structure primarily points to  the interaction points on
                    UV-curve but also contains the similar information about
                    interaction as seen  on  surface  boundaries i.e. Edges. 
                    This  similar information  is the 'sibling' information. 
                    Actual points being returned are computed on the respec-
                    tive curves. If this list on input is non-NULL, the out-
                    put points are appended to the list. 

                    SEE also, "PWgmdata.h" and "PWgmint.h" for further expl-
                    anation of the output data-structure.

  RETURN CODE

     PW_K_Success     - If everything goes well.
     PW_K_Internal    - Any inetrnal failure.
     PW_K_InvalidArg  - Invalid Arguments.
     PW_K_BspMath     - Any BS math failure.
     PW_K_PathwayMath - Any Pathway math failure.

  KEYWORDS

     External API, Interaction, Boundary, Loop, Edge ...

  CAVEATS
 
  HISTORY

     Sanjay                Creation 
*/

/* Includes */

#include <stdio.h>
#include <math.h>              /* System includes */
#include <alloca.h>
#include <memory.h>
#include <malloc.h>

#include "igrtypedef.h"
#include "igr.h"
#include "bs.h"                /* BS includes */
#include "bsgeom_cvsf.h"
#include "bsvalues.h"
#include "madef.h"

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWerror.h"           /* pathway includes */
#include "PWattrib.h"
#include "PWattribid.h"

/* Prototypes */

#include "bsbx2.h"
#include "bssfeval.h"          /* BS prototypes */
#include "bsmdstptcv.h"
#include "bscvarrevc.h"

#include "PWapi/lpprops.h"
#include "PWapi/sfgeom.h"
#include "PWapi/lped.h"
#include "PWapi/edgeom.h"    /* OMuse prototypes */
#include "PWapi/eded.h"
#include "PWapi/edprops.h"
#include "PWapi/aligngm.h"

#include "PWapi/lpint.h"
#include "PWapi/edint.h"
#include "PWapi/partol.h"
#include "PWapi/rngbx.h"
#include "PWapi/intcvcv.h"     /* Pathway prototypes */
#include "PWapi/intpypy2d.h"
#include "PWapi/degengm.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/memfunc.h"
#include "PWapi/normvec.h"
#include "PWapi/ptpargm.h"
#include "PWapi/dotp.h"
#include "PWapi/sfptloc.h"
#include "PWapi/mx.h"
#include "PWapi/pytocv.h"
#include "PWapi/posptgm.h"
#include "PWapi/sfuptrav.h"
#include "PWapi/lpptloc.h"
#include "PWapi/dbglevel.h"

/* Internal prototypes */

static void map_bs_intpt_to_py
(
  struct PWcvdata       *p_cvdata,
  PWboolean             sibling,
  struct PWcvintpt_list *p_cvintpts
);

static void RefineIfOverlapEndpt
(
  struct PWcvintpt_list *p_node,
  struct PWcvdata *i_cv,
  PWboolean i_reverse,
  PWobjid edid,
  PWosnum os,
  struct PWcvdata *e_cv,
  PWboolean e_reverse,
  double tol
);

static PWboolean is_overlap_region
(
  struct PWcvdata  *p_adata,
  struct PWcvparam *p_apt1,
  struct PWcvparam *p_apt2,
  struct PWcvdata  *p_bdata,
  struct PWcvparam *p_bpt1,
  struct PWcvparam *p_bpt2,
  double           lentol
);

/* Internal Macros/Definitions */

#define NUM_SAMPLE_PTS  4

/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwIntersectWithEdge
(
  struct PWid             *p_edid,
  struct PWcvdata         *p_uvcv,
  struct PWcvdata         *p_xyzcv,
  PWrange2d               uvcvrng,
  struct PWsfdata         *p_sfdata,
  double                  xyztol,
  struct PWcvintpt_list   **p_cvintpts
)
{
  /* status stuff */
  PWresult  PWsts=PW_K_Success;

  /* general stuff */
  double     uvtol=0;
  PWosnum    os;
  PWobjid    next_edge=PW_K_NullObjid;
  PWboolean  edrev=FALSE; /* Is edge reversed */
  PWboolean  cvmap_to_py=FALSE, edmap_to_py=FALSE, cvcv_int=FALSE;
  struct IGRbsp_surface *p_sfgeom=NULL;

  /* tangent info */
  PWpoint          endpt;
  PWvector         tangent;
  struct PWadjseg  adjseg, *p_adjseg=NULL;

  /* edge geometry */
  struct PWcvdata  eddata, cvdata;
  struct PWcvparam edpar;

  /* intersection list */
  struct PWcvintpt_list *p_list=NULL;

  /*
   * Validate the incoming arguments
   */
  if (!p_edid || !p_uvcv || (p_uvcv->datatype == PWcvdata_null) ||
      (p_uvcv->datatype == PWcvdata_py) || !p_sfdata ||
      (p_sfdata->datatype == PWsfdata_plane) || !p_cvintpts)
    OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_InvalidArg),
                  wrapup);
  /* 
   * Initialize the local variables
   */
  os = p_edid->osnum;
  memset (tangent, 0, sizeof (PWvector));
  memset (&eddata, 0, sizeof (struct PWcvdata));
  memset (&cvdata, 0, sizeof (struct PWcvdata));

  /*
   * If the edge is degenrate, don't process this edge. Exit with an 
   * informative error.
   */
  if (pwIsEdDegen (p_edid->objid, p_edid->osnum))
    OnErrorState (TRUE, PWsts, SetInfo (PW_K_Trimming, PW_K_Degenerate), 
                  wrapup);

  /*
   * If there is an edge next to the given edge and if it  is non-degenerate
   * then get it's geometry and evaluate the tangent at the logical start of
   * the edge, which is nothing but the end of the current edge. When  there 
   * is an interaction point at the logical stop of the edge, this  adjacent
   * tangent is used to determine containment classification, as there is an
   * ambiguity as to how the loop flows after this edge and the ambiguity is
   * resolved by this adjacent segemnt (tangent) inforatmion.  
   */

  next_edge = pwGetNextEd (p_edid->objid, os);

  if (next_edge != PW_K_NullObjid && !pwIsEdDegen (next_edge, os))
  {
    /*
     * There is a next edge and is non-degenerate. Get it's natural geometry
     * and evaluate the tangent.
     */
  
    PWsts = PW_GetNatEdGeomStack (next_edge, os, eddata);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

    /*
     * Get the tangent at the logical start of this next edge.
     */
    edrev = pwIsEdRev (next_edge, os);
    if (edrev)
    {
      pwGetMaxParCvdata (&eddata, &edpar);
    }
    else
    {
      pwGetMinParCvdata (&eddata, &edpar);
    } 

    PWsts = pwGetTangentCvdata (&eddata, &edpar, edrev, tangent);
    OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);

    tangent[Z] = 0.0;

    pwGetEndPtCvdata (&eddata, edrev, FALSE, endpt);
    adjseg.adjpt[X] = endpt[X] + 1.0 * tangent[X];
    adjseg.adjpt[Y] = endpt[Y] + 1.0 * tangent[Y];
    adjseg.adjpt[Z] = 0.0;

    p_adjseg = &adjseg;

  } /* if (next_edge ...) */

  memset (&eddata, 0, sizeof (struct PWcvdata));

  /*
   * To get the UV tolerance of the surface  convert the xyztol to uvtol
   * from the surface geometry.
   */
  p_sfgeom = p_sfdata->datatype == PWsfdata_bspsf ? p_sfdata->data.p_bspsf :
                                           p_sfdata->data.p_gmbspsf->bspsf ;

  /*
   * get the surface uv tolerance from xyz
   */
  uvtol = pwGetParTolSf (p_sfgeom, xyztol);

  /*
   * Determine whether to call PyPyInt or CvCvInt depending on the datatypes.
   */
  if (p_uvcv->datatype != PWcvdata_py2d ||
      pwGetEdGeomType (p_edid->objid, os) != PWcvdata_py2d)
  {
    cvcv_int = TRUE;
  }
  else
  {
    cvcv_int = FALSE;
  }

  if (cvcv_int)
  {
    /*
     * get the edge geometry as B-spline and set it's type.
     */
    PWsts = pwGetNatEdGeomAsBspline (p_edid->objid, os, &eddata.data.p_bspcv);
    OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);

    eddata.datatype = PWcvdata_bspcv;    

    if (pwGetEdGeomType (p_edid->objid, os) == PWcvdata_py2d && 
        eddata.data.p_bspcv->num_poles > 2)
    {
      edmap_to_py = TRUE; 
    }

    /*
     * get the intersection curve's geometry as B-spline if it is not so.
     */
    if (p_uvcv->datatype != PWcvdata_bspcv)
    {
      cvdata.datatype = PWcvdata_bspcv;
    
      cvdata.data.p_bspcv = (struct IGRbsp_curve *) 
                                    alloca (sizeof (struct IGRbsp_curve)); 
      cvdata.data.p_bspcv->poles = (double *) 
                  alloca (p_uvcv->data.py2d.num_pts * 3 * sizeof (double));
      cvdata.data.p_bspcv->knots = (double *) 
                  alloca ((p_uvcv->data.py2d.num_pts+2) * sizeof (double));
      cvdata.data.p_bspcv->weights = NULL;

      pwCnvtPy2dToCv (&p_uvcv->data.py2d, uvtol, cvdata.data.p_bspcv);

      if (p_uvcv->data.py2d.num_pts > 2)
      {
        cvmap_to_py = TRUE;
      }
    }
    else
    {
      cvdata.datatype = PWcvdata_bspcv;
      cvdata.data.p_bspcv = p_uvcv->data.p_bspcv;
    }
  }
  else
  {
    PWsts = pwGetNatEdGeom (p_edid->objid, os, &eddata);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

    memcpy (&cvdata, p_uvcv, sizeof (struct PWcvdata));
  } 

  edrev = pwIsEdRev (p_edid->objid, os);

  /*
   * Perform the intersection between the intersection curve and the edge
   */
  PWsts = pwIntersectWithEdgeGeom (p_edid->objid, p_edid->osnum, &eddata, 
                                   edrev, p_adjseg, edmap_to_py,
                                   &cvdata, p_xyzcv, uvcvrng, cvmap_to_py,
                                   p_sfdata, xyztol, uvtol, &p_list);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  /*
   * Append the interaction list to the incoming interaction points list
   */
  pwAppendCvintptList (p_cvintpts, p_list);

wrapup :

  if (IsError (PWsts) && p_list)
    pwFreeCvintptList (p_list);

  if (eddata.datatype == PWcvdata_bspcv && eddata.data.p_bspcv)
  {
    if (eddata.data.p_bspcv->poles) free (eddata.data.p_bspcv->poles);
    if (eddata.data.p_bspcv->knots) free (eddata.data.p_bspcv->knots);
    if (eddata.data.p_bspcv->weights) free (eddata.data.p_bspcv->weights);
    free (eddata.data.p_bspcv);
  }
  else if (eddata.data.py2d.p_pts)
  {
    free (eddata.data.py2d.p_pts);
  }

  PW_Wrapup (PWsts, "pwIntersectWithEdge");
  return PWsts;
}

/* ------------------------------------------------------------------------- */
/*                        End of API Source Code                             */
/* ------------------------------------------------------------------------- */


/* ------------------------------------------------------------------------- */
/*                           Helper Functions                                */
/* ------------------------------------------------------------------------- */

/*
  DESCRIPTION

     It takes the pure geometry a boundary element  i.e. edge and the inter-
     section curve outputs all the interaction points by calling either Poly
     Poly intersection or Curve - Curve intersection. If  XYZ  intersection 
     curve is passed in, then an extra check in the XYZ space is done to find
     the pure overlaps in XYZ space and the regions which are not overlaps 
     in XYZ space are processed again. 
*/

PWresult pwIntersectWithEdgeGeom
(
  PWobjid		 edid,
  PWosnum		 os,
  struct PWcvdata        *p_eddata,
  PWboolean              edrev,
  struct PWadjseg        *p_adjseg,
  PWboolean              edmap_to_py,

  struct PWcvdata        *p_uvcv,
  struct PWcvdata        *p_xyzcv,
  PWrange2d              uvcvrng,
  PWboolean              cvmap_to_py,

  struct PWsfdata        *p_sfdata,

  double                 xyztol,
  double                 uvtol,

  struct PWcvintpt_list  **p_cvintpts
)
{
  /* status stuff */
  PWresult  PWsts=PW_K_Success;

  /* general stuff */
  int  ed=0, ipt=0, spt=0, num_inters=0;

  /* geometry of the surface */
  struct IGRbsp_surface  *p_sfgeom=NULL;

  /* range of the edge */
  PWrange2d edrng2d, uvcvrng2d;
  PWrange   edrng3d, uvcvrng3d;   
  PWvector  dirvec;

  /* geometry of the edge */
  struct PWpoly2d     *p_edpy=NULL;
  struct IGRbsp_curve *p_edcv=NULL;

  /* geomtry of the intersection curve */
  struct PWpoly2d     *p_ipy=NULL;
  struct IGRbsp_curve *p_icv=NULL; 

  /* tolerances */
  double tol;

  /* check for overlap stuff */
  BSrc       rc=BSSUCC;
  int        n_over=0, n_spurious_over=0, npts=0; 
  double     step=0.0, par=0, sqdist=0, sqxyztol=0;
  PWpoint    sf_xyzpt, cv_xyzpt, pt;
  PWpoint2d  uvpt[NUM_SAMPLE_PTS];

  struct PWcvpt    edpt, edpt1, edpt2;
  struct PWcvparam edpar[NUM_SAMPLE_PTS], tcvpar;
  enum PWcontaintype rel=PWcontain_unknown, nextrel=PWcontain_unknown;

  struct IGRbsp_curve *p_save_edcv=NULL;
  PWboolean spans_removed=FALSE;

  /* Intersection Points info */
  struct PWcvintpt_list  *p_list=NULL, *p_node=NULL, *p_node1=NULL, 
                         *p_node2=NULL;

  /*
   * Validate the incoming arguments 
   */
  if (!p_uvcv || (p_uvcv->datatype == PWcvdata_null) || 
      (p_uvcv->datatype == PWcvdata_py) || !p_cvintpts)
    OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_InvalidArg),
                  wrapup);

  /*
   * Initialization 
   */
  sqxyztol = xyztol * xyztol;
  if (p_sfdata)
    p_sfgeom = (p_sfdata->datatype == PWsfdata_bspsf) ? 
                p_sfdata->data.p_bspsf : p_sfdata->data.p_gmbspsf->bspsf;
  else
    p_sfgeom = NULL;

  /*
   * Initialize the direction vector in case of Curve-Curve intersection
   */
  dirvec[0] = 0.0; dirvec[1] = 0.0; dirvec[2] = 1.0;

  /*
   * Initialize the local intersection list.
   */
  p_list = NULL;

  if (p_eddata->datatype == PWcvdata_py2d)
  {
    /*
     * The incoming edge is a polyline, so need to call Poly-Poly 
     * intersection. Get edge range and adjacent point to the edge 
     * from the adjacent vector.
     */ 
    p_edpy = &p_eddata->data.py2d;
    p_ipy  = &p_uvcv->data.py2d;

    pwGetRange2d (p_edpy->num_pts, p_edpy->p_pts, edrng2d);
    memcpy (uvcvrng2d, uvcvrng, sizeof (PWrange2d));
  }
  else
  {
    /*
     * The incoming edge is BS curve, so, need to call Curve-Curve 
     * intersection. Get the edge range and convert the uv curve 
     * range to 3D format as Curve-Curve Intersection operates in
     * 3D space.
     */
  
    p_edcv = p_eddata->data.p_bspcv;
    pwGetCvRange (p_edcv, edrng3d);

    uvcvrng3d[0][X] = uvcvrng[0][X]; uvcvrng3d[0][Y] = uvcvrng[0][Y];
    uvcvrng3d[0][Z] = 0.0;
    uvcvrng3d[1][X] = uvcvrng[1][0]; uvcvrng3d[1][Y] = uvcvrng[1][Y];
    uvcvrng3d[1][Z] = 0.0;

    if (p_uvcv->datatype == PWcvdata_bspcv)
      p_icv = p_uvcv->data.p_bspcv;
    else
      p_icv = p_uvcv->data.p_gmbspcv->bspcv;
  }

  if (p_xyzcv)
  {
    /*
     * The model space counter part (XYZ space) of the intersection curve
     * is passed in.
     *
     * As there is always destortion between the XYZ and UV space, the
     * overlap in XYZ may not be an overlap in UV or vice-versa. Here,
     * we can do some good job by making use of this XYZ curve data to
     * determine the pure overlaps in XYZ. Increase the UV tolerance by
     * 10 times, so that we do not miss the overlap regions in UV space.
     * Then, check whether the output overlap region is a pure overlap
     * in XYZ or not.
     */

    tol = 10.0 * uvtol;
  }
  else
  {
    /*
     * The model space counter part (XYZ space) of the intersection curve
     * is not present. So, there is no way we can make a comparison betw-
     * een the XYZ and UV spaces. We need to live with the distortion. So,
     * take the input tolerance as the actual tolerance.
     */

    tol = uvtol;
  }

  p_save_edcv = p_edcv;

  /*
   * Intersect the curves twice, first time with increased tolerance, 
   * secondly with the actual tolerance. 
   */
  for (ed = 0; ed < 2; ed++)
  {
    /* 
     * Initialize the loop variables
     */
    num_inters = 0;
    n_over = 0;
    n_spurious_over=0; 

    /*
     * Depending on the geometry type, call either PYPY int or CVCV int.
     */
    if (p_eddata->datatype == PWcvdata_py2d)
    {
      /*
       * The incoming geometrices are poly lines. Call pypyint.
       */

      PWsts = pwIntPyPy2d (p_edpy->num_pts, p_edpy->p_pts, p_adjseg, edrng2d, 
                           edrev, FALSE, p_ipy->num_pts, p_ipy->p_pts, NULL, 
                           uvcvrng2d, FALSE, TRUE, tol, &num_inters, &p_list);
    }
    else
    {
      struct IGRbsp_curve  new_edcv;

      p_edcv = p_save_edcv;

      if (p_edcv->order == 2 && pwNumDegenSpans (p_edcv->num_poles, 
                               (PWpoint *) &p_edcv->poles[0], tol))
      {
        struct PWpoly py;

        new_edcv.poles = alloca (p_edcv->num_poles * sizeof (PWpoint));
        new_edcv.knots = alloca ((p_edcv->num_poles +2) * sizeof (double)); 
        new_edcv.weights = NULL;

        py.num_pts = 0;
        py.p_pts = alloca (p_edcv->num_poles * sizeof (PWpoint));
   
        pwRemoveDegenSpans (p_edcv->num_poles, (PWpoint *) &p_edcv->poles[0], 
                            &py.num_pts, py.p_pts, tol);
        spans_removed = TRUE;

        pwCnvtPyToCv (&py, tol, &new_edcv);
        p_edcv = &new_edcv;
        p_eddata->data.p_bspcv = p_edcv;
      }                              

      /*
       * The incoming geometrices are BS curves. Call cvcvint.
       */

      PWsts = pwCvCvInt (p_edcv, p_adjseg, edrng3d, edrev, FALSE, 
                         p_icv, NULL, uvcvrng3d, FALSE, TRUE, dirvec, 
                         tol, &num_inters, &p_list); 
    }
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup); 

    /*
     * If this is the second time in the loop and there is a mixture of
     * intersection and overlap points, then error out.
     */
    if (ed && GetCode(PWsts) == PW_K_Mixture)
      OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_Mixture),
                    wrapup);  

    /*
     * if the xyz geometry of the intersection curve is provided and if there
     * are any overlap interaction points, then cross check the overlap region 
     * in XYZ as the overlap is found with an increase in the tolerance.
     */
    if (!p_xyzcv || !p_sfdata || ed == 1)
      break;

    /*
     * Intialize the loop variables.
     */
    p_node = p_list; 

    for (ipt=0; ipt<num_inters-1; ipt++, p_node = p_node->p_next)
    {
      if (pwIsCoincCvintptList (p_node, NEXT))
        continue;

      rel     = pwGetContainCvintpt (&p_node->intpt, RIGHT);
      nextrel = pwGetContainCvintpt (&p_node->p_next->intpt, LEFT);

      if (rel == PWcontain_on || nextrel == PWcontain_on)
      {
        /*
         * This could be an  overlap region. So, check for the same in XYZ 
         * space.
         */

        if (pwIsCoincCvintptList (p_node, PREV))
        {
          p_node1 = p_node; p_node2 = p_node->p_next;
          if (!is_overlap_region (p_uvcv, &p_node1->intpt.cvpt.cvparam,
                 &p_node2->intpt.cvpt.cvparam, p_eddata, 
                 &p_node1->intpt.sibling.cvparam,
                 &p_node2->intpt.sibling.cvparam, tol))
          {
            p_node1 = p_node->p_prev; 
          }
        }
        else
        {
          p_node1 = p_node; p_node2 = p_node->p_next;
        }

        if (!p_node1 || !p_node2 || 
            !is_overlap_region (p_uvcv, &p_node1->intpt.cvpt.cvparam,
               &p_node2->intpt.cvpt.cvparam, p_eddata, 
               &p_node1->intpt.sibling.cvparam,
               &p_node2->intpt.sibling.cvparam, tol))
        {
          continue;
        }
       
        memcpy (&edpt1, &p_node1->intpt.sibling, sizeof (struct PWcvpt));
        memcpy (&edpt2, &p_node2->intpt.sibling, sizeof (struct PWcvpt));
 
        /*
         * The region between this node and the next node is an overlap. So 
         * check for the whether this span is an overlap in XYZ space or not
         * by taking some sample points.
         */
        n_over ++;

        /*
         * generate the sample points. This set of sample points always contain
         * end points of the overlap region. 
         */
        if ((edpt1.cvparam.spaninx + edpt1.cvparam.spanpar) >
            (edpt2.cvparam.spaninx + edpt2.cvparam.spanpar))
        {
          memcpy (&edpt, &edpt1, sizeof (struct PWcvpt));
          memcpy (&edpt1, &edpt2, sizeof (struct PWcvpt));
          memcpy (&edpt2, &edpt, sizeof (struct PWcvpt));
        }

        memcpy (&uvpt[0][0], edpt1.pt, 2 * sizeof(double)); 
        memcpy (&uvpt[1][0], edpt2.pt, 2 * sizeof(double));
        memcpy (&edpar[0], &edpt1.cvparam, sizeof(struct PWcvparam));
        memcpy (&edpar[1], &edpt2.cvparam, sizeof(struct PWcvparam));

        /*
         * get the number of sample points and determine the step distance 
         * for each sample point.
         */
        npts = NUM_SAMPLE_PTS;
        step = (edpar[1].spaninx + edpar[1].spanpar - edpar[0].spaninx -
                edpar[0].spanpar);

        if (edpar[0].spaninx == edpar[1].spaninx)
        {
          int     lnpts=0;
          double  partol=0.0;

          if (p_edcv)
            partol = pwGetParTolCv (p_edcv, tol);
          else
            partol = tol / pwDistPtPt2d (uvpt[0], uvpt[1]);
     
          lnpts = (int)(step / partol) + 1;
          if (npts > lnpts)
            npts = lnpts;
          if (npts < 2)
            npts = 2;  
        }

        step /= (npts-1);

        for (spt = 2; spt < npts; spt++)
        {
          par = edpar[0].spaninx + edpar[0].spanpar + (spt - 1) * step; 
          edpar[spt].spaninx = (int) par;
          edpar[spt].spanpar = par - (int) par;

          /*
           * evaluate the UV points at these parameter values.
           */
          PWsts = pwPtAtParCvdata (p_eddata, &edpar[spt], pt);
          OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup); 

          memcpy (uvpt[spt], pt, 2 * sizeof(double));
        }

        for (spt=0; spt<npts; spt++)
        {

          /*
           * evaluate this uvpt on the surface and get the xyz point.
           */
          BSsfeval (p_sfgeom, uvpt[spt][U], uvpt[spt][V], 0, 
                    (IGRpoint *) &sf_xyzpt[0], &rc);
          OnErrorState (rc, PWsts, SetError (PW_K_BspMath, PW_K_Internal), 
                        wrapup); 

          /*
           * get the minimum distance point of this xyzpt on the XYZ inter-
           * section curve and if it is with in the xyz tol continue other-
           * wise break the loop and classify the interaction points as an
           * intersection point rather than overlap.
           */
          sqdist = pwMinDistSqPtCvdata (sf_xyzpt, p_xyzcv, cv_xyzpt, &tcvpar);

          if (sqdist > sqxyztol)
          {
            pwDebugLine (PW_K_DebugWarning, "Trim: Spurious Overlap\n");
            n_spurious_over++;
            break;
          }
          else 
          {
            if (rel != PWcontain_on)
            {
              pwDebugLine (PW_K_DebugWarning, 
                           "Trim: Overlap incorrectly marked\n");
              pwSetContainCvintpt (&p_node->intpt, RIGHT, PWcontain_on);
            }
            else if (nextrel != PWcontain_on)
            {
              pwDebugLine (PW_K_DebugWarning, 
                           "Trim: Overlap incorrectly marked\n");
              pwSetContainCvintpt (&p_node->p_next->intpt, LEFT, PWcontain_on);
            }
          }
        }
      }
    }


    if (n_over && !n_spurious_over)
    {
      /*
       * There are overlap regions and none of them is a spurious overlap 
       * i.e. as compared in XYZ space, so break the loop. In this  case, 
       * we have to do some post-processing since the interaction  points 
       * have been generated with a bigger tolerance  than  specified. We 
       * must attempt to obtain the exact values.
       *
       * Internal  overlap  points  ( topopos == middle ) are  considered 
       * accurate enough. The  real  problem  arises  when an interaction 
       * point is returned at an end-point when it is  not  really at the 
       * end. If we were to  measure  using  the  real tolerance we might 
       * find that the interaction point lies * in the topological middle. 
       */

      for (p_node=p_list; p_node; p_node=p_node->p_next)
        RefineIfOverlapEndpt (p_node, p_uvcv, FALSE, edid, os, p_eddata, edrev,
                              uvtol);

      break;
    }
    else
    {
      /*
       * No true overlaps were found. We need to obtain the intersection
       * points with the correct tolerance. So repeat this process with 
       * the right tolerance.
       */

      if (p_list) pwFreeCvintptList (p_list);
      p_list = NULL;
      tol = uvtol;
    }
  }

  /*
   * If the intersection points need to be transformed from BS to PY format
   * do this.
   */
  if (p_list && cvmap_to_py)
  {
    map_bs_intpt_to_py (p_uvcv, FALSE, p_list);
  }

  if (p_list && edmap_to_py)
  {
    map_bs_intpt_to_py (p_eddata, TRUE, p_list);
  }

  /*
   * Post the edge id info. and convert the parameter info. of the edge 
   * so that it will be in the form of the full edge.
   */
  for (p_node = p_list; p_node; p_node = p_node->p_next)
  {
    p_node->intpt.cvpt.cvid = PW_K_NullObjid; 
    p_node->intpt.sibling.cvid = edid; 
  }


  if (p_list)
    pwAppendCvintptList (p_cvintpts, p_list);
  p_list = NULL;

wrapup :

  if (spans_removed) 
    p_eddata->data.p_bspcv = p_save_edcv;

  if (IsError (PWsts) && p_list)
    pwFreeCvintptList (p_list);

  PW_Wrapup (PWsts, "pwIntersectWithEdgeGeom");
  return PWsts;
}

/* ------------------------------------------------------------------------- */
/*                           Static Functions                                */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT

    Maps the BS (order = 2) intersection points to Polyline format. The input
    tolerance is the zero length tolerance. It is assumed that the polyline
    is made of the poles of the BS curve.

  NOTES

    This function will return the span-index and span-parameter assuming that
    knot vector is uniform. The translation from the B-spline curve parameter
    to the span-inx/span-par form for a polyline is an exact mapping, with
    no regard to rounding off to the nearest "vertex". So no tolerance is
    input. 

  HISTORY

    Sanjay  :  In the past  :  Creation
    SS      :  07/02/96     :  There was a bug in the span-inx computation when
                               the parameter was approaching the vertex (~0.99).
                               Removed references to tolerance as these are
                               redundant.
*/

static void map_bs_intpt_to_py
(
  struct PWcvdata       *p_cvdata,
  PWboolean             sibling,
  struct PWcvintpt_list *p_cvintpts
)
{
  double step=0.0, ratio=0.0;
  struct IGRbsp_curve *p_cv=NULL;
  struct PWcvpt *p_cvpt=NULL;
  struct PWcvintpt_list *p_node=NULL;

  p_cv = (p_cvdata->datatype == PWcvdata_bspcv) ? p_cvdata->data.p_bspcv :
          p_cvdata->data.p_gmbspcv->bspcv;

  /*
   * calculate step in the knot vector
   */
  step = 1.0 / (p_cv->num_poles - 1);

  /*
   * Map each node 
   */
  for (p_node = p_cvintpts; p_node; p_node = p_node->p_next)
  {
    if (sibling)
      p_cvpt = &p_node->intpt.sibling;
    else
      p_cvpt = &p_node->intpt.cvpt;

    /*
     * Calculate the span parameter and index for the intersection point.
     */
    ratio = p_cvpt->cvparam.spanpar / step;
    p_cvpt->cvparam.spanpar = ratio - (int) ratio;
    p_cvpt->cvparam.spaninx = (int) ratio;
  }

  return;
}

/*
  ABSTRACT

    Given the respective interaction points bounding an overlap region
    on two curves, it rechecks the same by taking a sample point on one
    curve and projecting it on the other curve. This will be done for
    both the input curves to make sure that it is a true overlap region
    between the given bounds. Returns TRUE if it is an overlap region 
    otherwise FALSE.

  NOTES

    None.
*/

static PWboolean is_overlap_region
(
  struct PWcvdata  *p_adata,
  struct PWcvparam *p_apt1,
  struct PWcvparam *p_apt2,
  struct PWcvdata  *p_bdata,
  struct PWcvparam *p_bpt1,
  struct PWcvparam *p_bpt2,
  double           lentol
)
{
  PWresult PWsts=PW_K_Success;
  double  par=0, a_pt[3], b_pt[3], a_minpt[3], b_minpt[3], sqlentol=0;
  double  minpar=0, maxpar=0;
  struct PWcvparam  a_midpt, b_midpt, a_par, b_par;

  a_pt[2] = b_pt[2] = a_minpt[2] = b_minpt[2] = 0.0;
  sqlentol = lentol * lentol;

  par = (p_apt1->spaninx + p_apt1->spanpar +
         p_apt2->spaninx + p_apt2->spanpar) / 2.0;

  a_midpt.spaninx = (int) par;
  a_midpt.spanpar = par - (int) par;

  PWsts = pwPtAtParCvdata (p_adata, &a_midpt, a_pt);
  if (IsError (PWsts))
    return FALSE;

  if (pwMinDistSqPtCvdata (a_pt, p_bdata, b_minpt, &b_par) > sqlentol)
    return FALSE;
  else
  {
    minpar = p_bpt1->spaninx + p_bpt1->spanpar;
    maxpar = p_bpt2->spaninx + p_bpt2->spanpar;
 
    if (minpar > maxpar)
      pwSwapDouble (&minpar, &maxpar);

    par = b_par.spaninx + b_par.spanpar;
    if (par < minpar || par > maxpar)
      return FALSE;
  }
 
  par = (p_bpt1->spaninx + p_bpt1->spanpar + 
         p_bpt2->spaninx + p_bpt2->spanpar) / 2.0;
  b_midpt.spaninx = (int) par;
  b_midpt.spanpar = par - (int) par;

  PWsts = pwPtAtParCvdata (p_bdata, &b_midpt, b_pt);
  if (IsError (PWsts))
    return FALSE;

  if (pwMinDistSqPtCvdata (b_pt, p_adata, a_minpt, &a_par) > sqlentol)
    return FALSE;
  else
  {
    minpar = p_apt1->spaninx + p_apt1->spanpar;
    maxpar = p_apt2->spaninx + p_apt2->spanpar;

    if (minpar > maxpar)
      pwSwapDouble (&minpar, &maxpar);

    par = a_par.spaninx + a_par.spanpar;
    if (par < minpar || par > maxpar)
      return FALSE;
  }

  return TRUE;
}


/*
  ABSTRACT

  If the point or it's sibling are at an end-point of the respective curves,
  then this function tries to obtain the more accurate interaction point
  w.r.t the new tolerance that has been passed in. That is, this function
  is trying to determine if the end-point interaction is truly so, w.r.t. the
  new tolerance.


  ALGORITHM

  Since this function is called in the narrow context of overlap regions 
  handled above, we will make a simplifying assumption that there will be
  tolerance related issues to be corrected only when we come across end-point
  interaction on the i_cv coupled with an end-point interaction on the e_cv.
  An end-point interaction on either curve that is coupled with a 'middle'
  interaction on the other is considered accurate enough already. So the
  problem further reduces to:
  1) Project the end-point of i_cv onto e_cv, obtain point i_P
  2) Project the end-point of e_cv onto i_cv, obtain point e_P
  3) If i_P or e_P are in the 'middle', then the true interaction point is
     deemed to be this 'middle' point.
  4) Further, if the 'middle' occurs on the e_cv, then the node is never
     an 'informational' node, since we know that in the code above such a 
     property is set only for 'start end-point' interactions. Hence, unset
     this property in this case.
  
  HISTORY

  SS  :  08/18/95   :  Creation
*/

static void RefineIfOverlapEndpt
(
  struct PWcvintpt_list *p_node,
  struct PWcvdata *i_cv,
  PWboolean i_reverse,
  PWobjid edid,
  PWosnum os,
  struct PWcvdata *e_cv,
  PWboolean e_reverse,
  double tol
)
{
  double mindist=0;
  enum PWtopopostype i_topopos, e_topopos;
  PWpoint i_pt={0.0,0.0,0.0}, e_pt={0.0,0.0,0.0}, minpt={0.0,0.0,0.0};
  PWobjid bdry_elem=PW_K_NullObjid;
  PWmatrix mx;
  struct PWcvparam minpar;
  struct PWcvpt bdry_pt;
  struct PWid lpid;
  struct PWsfdata sfgeom;
  enum PWptloctype ptloc=PWptloc_unknown;
  enum PWcontaintype lfrel, rtrel, newrel;

  i_topopos = pwGetTopoposCvpt (&p_node->intpt.cvpt);
  e_topopos = pwGetTopoposCvpt (&p_node->intpt.sibling);
  if ((i_topopos == PWtopopos_start || i_topopos == PWtopopos_stop) &&
      (e_topopos == PWtopopos_start || e_topopos == PWtopopos_stop))
  {
    pwGetEndPtCvdata (i_cv, i_reverse, i_topopos == PWtopopos_stop, i_pt);  
    pwGetEndPtCvdata (e_cv, e_reverse, e_topopos == PWtopopos_stop, e_pt);  

    mindist = pwMinDistSqPtCvdata (i_pt, e_cv, minpt, &minpar);

    if (!pwIsParAtCvEnd (&minpar, e_topopos == PWtopopos_stop, 
          e_cv, e_reverse, tol))
    {
      /*
       * The projected end point of i_cv is not with in tolerance from the
       * e_cv end point. So, it is a middle interaction point on e_cv.
       */ 

      pwInitCvpt (&p_node->intpt.sibling, PWtopopos_middle, minpt, 3,
       minpar.spaninx, minpar.spanpar, p_node->intpt.sibling.cvid);
      pwFreeAttribList (p_node->intpt.sibling.p_attrib);
      
      pwUnsetInfoNodeCvintptList (p_node);

      if (pwGetDebugLevel() >= PW_K_DebugWarning)
        pwDebugLine (PW_K_DebugWarning, 
         "Trim: Corrected Overlap Topopos for Edge : %d , Surface : %d \n",
         edid, pwGetSfOfEd (edid, os));
    }


    minpt[2] = 0.0;
    mindist = pwMinDistSqPtCvdata (e_pt, i_cv, minpt, &minpar);

    if (!pwIsParAtCvEnd (&minpar, i_topopos == PWtopopos_stop, 
          i_cv, i_reverse, tol))
    {
      /*
       * The projected end point of e_cv is not with in tolerance from the
       * end point of i_cv. So, it is the middle interaction point on i_cv.
       */

      pwInitCvpt (&p_node->intpt.cvpt, PWtopopos_middle, minpt, 3,
       minpar.spaninx, minpar.spanpar, p_node->intpt.cvpt.cvid);
      pwFreeAttribList (p_node->intpt.cvpt.p_attrib);

      lpid.objid = pwGetLpOfEd (edid, os);
      lpid.osnum = os;
      sfgeom.datatype = PWsfdata_null;
      sfgeom.data.p_bspsf = NULL;
      PW_GetSfBspsfStack (pwGetSfOfEd (edid, os), os, MAIDMX, pwIdMx (mx), 
       sfgeom.data.p_bspsf);
      if (sfgeom.data.p_bspsf)
        sfgeom.datatype = PWsfdata_bspsf;

      pwLpPtLocate (&lpid, NULL, i_pt, &sfgeom, tol, &ptloc, &bdry_elem, 
       &bdry_pt);

      switch (ptloc)
      {
        case PWptloc_onedge:
          newrel = PWcontain_on;
          break;

        case PWptloc_inarea:
          newrel = PWcontain_in;
          break;

        case PWptloc_inhole:
        case PWptloc_outside:
          newrel = PWcontain_out;
          break;

        default:
          newrel = PWcontain_unknown;
          break;
      }

      if (i_topopos == PWtopopos_start)
      {
        lfrel = newrel;
        rtrel = PWcontain_on;
      }
      else
      {
        lfrel = PWcontain_on;
        rtrel = newrel;
      }

      pwSetContainCvintpt (&p_node->intpt, LEFT, lfrel);
      pwSetContainCvintpt (&p_node->intpt, RIGHT, rtrel);

      if (pwGetDebugLevel() >= PW_K_DebugWarning)
        pwDebugLine (PW_K_DebugWarning, 
         "Trim: Corrected Overlap Topopos on I-curve : %d , Surface : %d \n",
          edid, pwGetSfOfEd (edid, os));
    }
  }

  return;
}
