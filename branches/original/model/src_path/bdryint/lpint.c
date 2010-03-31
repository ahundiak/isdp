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
     the UV-space of the surface and the loop boundaries, outputs the intrac-
     tion points in a linked list.
 
  DESCRIPTION

     Given a UV curve in the UV-space of surface, and loop id, it  outputs all 
     the  geometric interaction points with the boundaries of the surface i.e. 
     edges of the loops.The UV curve is typically an intersection curve in the 
     UV-space of the surface as it interacts with another surface.

     A significant output is the relative containment classification of these
     interaction points. The classification is in terms of  how  the UV curve
     is flows with respect to the boundaries defining the surface.  That  is,
     whether it is IN->OUT, IN->ON, ON->OUT, etc., where,  'IN' refers to in-
     side area, 'OUT' refers to outside area (or inside hole),'ON'  refers to
     on the boundary.  Thus,  there can be 9  possible classes into which the
     interactions fit.

     This function  optionally takes in the XYZ curve data,  to check for the
     pure overlaps in XYZ space  as there is always a  destortion between the
     UV and XYZ spaces. If the  XYZ curve data is not  passed in, extra check
     for the overlap in XYZ space  will not be  carried out and  whatever the
     overlap region found in UV space will be output.

     'uvcv' is the UV-curve, 'xyzcv' is the XYZ-curve, 'xyztol' is the toler-
     ance is XYZ  space (typically chord height tolerance),  'lpid'  loop id 
     with which the intersection need to be done. The output from this funct-
     ion is a linked list 'cvintpts', contain  all  the information about the 
     interaction points. This  linked  list structure primarily points to the 
     interaction point on the UV-curve, and also contains the similar inform-
     ation about this interaction as seen on the loop element i.e. edge. This 
     similar information is the 'sibling' information. The actual points being
     returned are computed on the respective geometrices i.e.UV-curve and edge.

  NOTES

     Care is taken to see that the zero-length tolerance being  passed  in is  
     strictly respected.

     All the memory for the interaction points is allocated in this function.
     So, it is the caller's responsibility to free the  memory  allocated  by 
     calling respective free function(s).
 
  ARGUMENTS

     p_lpid      I  Loop ID, with which the interaction should take place.
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

     Sanjay   01/20/95   Creation 

*/

/* Includes */

#include <stdio.h>
#include <math.h>              /* System includes */
#include <alloca.h>
#include <memory.h>

#include "igrtypedef.h"
#include "igr.h"
#include "bs.h"                /* BS includes */
#include "bsgeom_cvsf.h"
#include "bsvalues.h"

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
#include "bschtptstcv.h"

#include "PWapi/lpprops.h"
#include "PWapi/sfgeom.h"
#include "PWapi/lped.h"
#include "PWapi/edgeom.h"    /* OMuse prototypes */
#include "PWapi/eded.h"
#include "PWapi/edprops.h"

#include "PWapi/lpint.h"
#include "PWapi/partol.h"
#include "PWapi/rngbx.h"
#include "PWapi/intpypy2d.h"   /* Pathway prototypes */
#include "PWapi/degengm.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/memfunc.h"
#include "PWapi/edint.h"
#include "PWapi/ptpargm.h"
#include "PWapi/spangm.h"
#include "PWapi/aligngm.h"
#include "PWapi/pytocv.h"
#include "PWapi/sortgmint.h"
#include "PWapi/mkvec.h"
#include "PWapi/revvec.h"
#include "PWapi/normvec.h"
#include "PWapi/dbglevel.h"
#include "PWapi/sfuptrav.h"
#include "PWapi/ptpargm.h"
#include "PWapi/mkcvregs.h"

/* Internal Prototypes */

static PWresult GetAdjacentPoint
(
  struct PWcvdata  *p_cvdata,
  PWboolean        reversed,
  double           lentol,
  PWpoint          adjpt
);

static void AccRejOverlapEndInteractions
(
  struct PWcvintpt_list *p_cvintpts,
  PWosnum os,
  double lentol,
  double overtol
);

struct PWcvintpt_list * GetEndNodeOnCvid
(
  struct PWcvintpt_list *p_cvintpts,
  PWobjid cvid,
  PWboolean sibling,
  PWboolean cvrev,
  PWboolean start
);

static PWboolean IsPtAtEndEdge
(
  PWobjid  edobj,
  PWosnum  edos,
  struct PWcvpt *p_edpt,
  PWboolean start,
  double   tol
);

/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwIntersectWithLoop
(
  struct PWid             *p_lpid,
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

  /* osnum */
  PWosnum  os;

  /* Loop range */
  PWrange2d  lprng;
  double     uvtol=0;

  /* loop counts */
  int  ed=0;

  /* boolean value to check whether the range boxes intersects or not */
  PWboolean  intersect=FALSE;
  PWboolean  edrev; /* Is edge reversed */

  /* tangent info */
  struct PWcvparam tpar;

  /* Adjacent edge information */
  struct PWadjseg  *p_adjseg=NULL, adjseg;

  /* geometry of the surface */
  struct IGRbsp_surface  *p_sfgeom=NULL;

  /* number of edges and edges of the loop */
  int      num_edges=0;
  PWobjid  *p_edges=NULL;
  PWobjid  next_edge=PW_K_NullObjid; /* next edge ID */

  /* maximum size for the edge geometry and memory pointer to hold it */
  int     size=0;
  char    *p_memory=NULL;

  /* geometry of the edge */
  struct PWpoly2d     *p_edpy=NULL;
  struct IGRbsp_curve *p_edcv=NULL;
  PWboolean           cvcv_int=FALSE;
  struct PWcvdata     ed_data, adjseg_data;

  /* geomtry of the intersection curve */
  struct PWpoly2d     *p_ipy=NULL;
  struct IGRbsp_curve *p_icv=NULL; 

  /* maximum size calculation */
  struct PWcvdata     tmp_data;
  struct IGRbsp_curve tmp_cv; 
  int  max_poles=0, max_order=2;
  PWboolean rational=FALSE;

  /* Edge intersection info */
  struct PWcvdata   eddata, cvdata;

  /* Map info */
  PWboolean  edmap_to_py=FALSE, cvmap_to_py=FALSE;

  /* Intersection Points info */
  struct PWcvintpt_list  *p_list=NULL, *p_tail=NULL, *p_node=NULL, 
                         *p_nextnode=NULL;

  /*
   * Validate the incoming arguments 
   */
  if (!p_lpid || !p_uvcv || (p_uvcv->datatype == PWcvdata_null) || 
      (p_uvcv->datatype == PWcvdata_py) || !p_sfdata || 
      (p_sfdata->datatype == PWsfdata_plane) || !p_cvintpts)
    OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_InvalidArg),
                  wrapup);

  /* 
   * intialize the osnum  
   */
  os = p_lpid->osnum; 
  memset (&ed_data, 0, sizeof(struct PWcvdata));
  memset (&adjseg_data, 0, sizeof(struct PWcvdata));

  /*
   * get the UV range of the loop 
   */
  pwGetLpRange (p_lpid->objid, os, lprng);

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
   * expand the loop range by uvtol 
   */
  pwExpandRange2d (lprng, uvtol);

  /*
   * Trivial range box check. If they don't intersect goto wrapup.
   */
  intersect = pwIsOverlapRngRng2d (lprng, uvcvrng); 
  OnErrorState (!intersect, PWsts, PWsts, wrapup);

  /*
   * get the edges of the loop 
   */
  num_edges = pwNumEdsOfLp (p_lpid->objid, os);
  OnErrorState (!num_edges, PWsts, SetError (PW_K_Trimming, PW_K_InvalidArg),
                wrapup);

  p_edges = (PWobjid *) alloca (num_edges * sizeof(PWobjid));
  OnErrorState (!p_edges, PWsts, SetError (PW_K_Trimming, PW_K_DynamicMemory),
                wrapup);

  num_edges = pwEdsOfLp (p_lpid->objid, os, p_edges);
  OnErrorState (!num_edges, PWsts, SetError (PW_K_Trimming, PW_K_InvalidArg),
                wrapup);

  /*
   * As a first step, traverse thru all the edges and get the maximum size of
   * the edge. This size will be allocated to the memory pointer and made it
   * to point to the actual structure.
   */
  size = 0;
  memset (&tmp_data, 0, sizeof(struct PWcvdata));

  for (ed = 0; ed < num_edges; ed ++)
  {
    if (pwGetEdGeomType (p_edges[ed], os) == PWcvdata_bspcv)
      tmp_data.data.p_bspcv = &tmp_cv;

    /* 
     * get the edge definition and populate the max_poles, max_order and 
     * rational fields.
     */

    PWsts = pwGetEdDef (p_edges[ed], os, &tmp_data);
    OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);

    switch (tmp_data.datatype)
    {
      case PWcvdata_pt2d :
      case PWcvdata_pt   :
           if (max_poles < 1)
             max_poles = 1;
           break;
 
      case PWcvdata_py2d :
           if (tmp_data.data.py2d.num_pts > max_poles)
             max_poles = tmp_data.data.py2d.num_pts;
           break;

      case PWcvdata_py :
           if (tmp_data.data.py.num_pts > max_poles)
             max_poles = tmp_data.data.py.num_pts;
           break;

      case PWcvdata_bspcv : 
           if (tmp_data.data.p_bspcv->num_poles > max_poles)
             max_poles = tmp_data.data.p_bspcv->num_poles;
           if (tmp_data.data.p_bspcv->order > max_order)
             max_order = tmp_data.data.p_bspcv->order;
           if (!rational && tmp_data.data.p_bspcv->rational)
             rational = TRUE;
           break;

    } /* switch */

  } /* for (ed=0 ...) */

  /* 
   * get the size required for aligned curve data and allocate the memory.
   */
  size = pwAlignCvSize (max_poles, max_order, rational, 0);

  p_memory = (char *) alloca (size);
  OnErrorState (!p_memory, PWsts, SetError (PW_K_Trimming, PW_K_DynamicMemory),
                wrapup);

  /*
   * get the data for the intersection curve
   */
  if (p_uvcv->datatype == PWcvdata_py2d)
    p_ipy = &p_uvcv->data.py2d;
  else if (p_uvcv->datatype == PWcvdata_bspcv)
    p_icv = p_uvcv->data.p_bspcv;
  else if (p_uvcv->datatype == PWcvdata_gmbspcv)
    p_icv = p_uvcv->data.p_gmbspcv->bspcv;

  /*
   * Now loop over thru all the edges and intersect the incoming UV curve
   * with each edge.
   */
  p_list = NULL;

  for (ed = 0; ed < num_edges; ed++)
  {
    /* 
     * Initialize the loop variables
     */ 
    p_adjseg    = NULL;
    edmap_to_py = FALSE;
    cvmap_to_py = FALSE;

    /*
     * If this edge is degenerate, then continue.
     */
    if (pwIsEdDegenTol (p_edges[ed], os, uvtol))
      continue;

    /*
     * Get logical non-degenerate next edge to this edge and evaluate the 
     * tangent at the logical start of this edge which is nothing but the
     * adjacent segment tangent vector. Fill in the adjacent segment info.
     * and send to "Edge Intersect". 
     */

    next_edge = pwGetNextEdNoDegen (p_edges[ed], os, uvtol);

    if (next_edge != PW_K_NullObjid)
    {
      /*
       * There is an edge next to this edge and it is non-degenerate. Get the 
       * natural geometry of the edge.
       */
      PWsts = PW_GetNatEdGeomStack (next_edge, os, adjseg_data);
      OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);

      /*
       * get the start tangent of this edge. If this edge is reversed, and 
       * as we want the tangent at the beginning of the edge, we need to 
       * calculate the tangent at the stop point of the natural geomtry of
       * the edge and reverse it. Always initialize the 'Z' coordinate value
       * of this vector ZERO as we are operating in UV coordinate system.
       */
      edrev = pwIsEdRev (next_edge, os);

      adjseg.p_cvdata = &adjseg_data;
      adjseg.reversed = edrev;
      PWsts = GetAdjacentPoint (&adjseg_data, edrev, uvtol, adjseg.adjpt);
      OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);

      p_adjseg = &adjseg;
    }

    /*
     * get the edge type and edge reversal bit.
     */
    edrev = pwIsEdRev (p_edges[ed], os);

    if (p_uvcv->datatype != PWcvdata_py2d || 
        pwGetEdGeomType (p_edges[ed], os) != PWcvdata_py2d)
    {
      cvcv_int = TRUE;

      /*
       * If the intersection curve is of poly line representation, then get 
       * the B-spline curve representation.
       */
      if (!p_icv)
      {
        p_icv = (struct IGRbsp_curve *) alloca (sizeof (struct IGRbsp_curve));
        p_icv->poles = (double *) alloca (p_ipy->num_pts * 3 * sizeof(double));
        p_icv->knots = (double *) alloca ((p_ipy->num_pts+2) * sizeof(double));
        p_icv->weights = FALSE;

        pwCnvtPy2dToCv (p_ipy, uvtol, p_icv);
      }

      /*
       * get the edge geometry in B-spline format.
       */
      p_edcv = (struct IGRbsp_curve *) &p_memory[0];

      PWsts = pwGetNatEdGeomAsBspline (p_edges[ed], os, &p_edcv);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup); 
    }
    else
    {
      cvcv_int = FALSE;
      
      /*
       * get the Polyline representation of edge geometry
       */
      ed_data.data.py2d.p_pts = (PWpoint2d *) &p_memory[0];

      PWsts = pwGetNatEdGeom (p_edges[ed], os, &ed_data);
      OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup); 

      p_edpy = &ed_data.data.py2d;
    }

    /*
     * Frame the data required for intersection
     */
    if (cvcv_int)
    {
      eddata.datatype = PWcvdata_bspcv;
      eddata.data.p_bspcv = p_edcv;
      cvdata.datatype = PWcvdata_bspcv;
      cvdata.data.p_bspcv = p_icv;
    }
    else
    {
      eddata.datatype = PWcvdata_py2d;
      eddata.data.py2d.num_pts = p_edpy->num_pts;
      eddata.data.py2d.p_pts = p_edpy->p_pts;
      cvdata.datatype = PWcvdata_py2d;
      cvdata.data.py2d.num_pts = p_ipy->num_pts;
      cvdata.data.py2d.p_pts = p_ipy->p_pts;
    }

    /*
     * whether the data need to be converted to PY format or not
     */
    if (cvcv_int)
    {
      if (p_uvcv->datatype == PWcvdata_py2d && p_icv->num_poles > 2)
      {
        cvmap_to_py = TRUE;
      }

      if (pwGetEdGeomType (p_edges[ed], os) == PWcvdata_py2d &&
          p_edcv->num_poles > 2)
      {
        edmap_to_py = TRUE;
      }
    }

    /*
     * get the tail of intersection list, which will get the first node of 
     * intersection between this edge and the intersection curve.
     */
    p_tail = pwTailCvintptList (p_list);

    /*
     * Perform the intersection between the intersection curve and the edge
     */

    PWsts = pwIntersectWithEdgeGeom (p_edges[ed], os, &eddata, edrev, 
                                     p_adjseg, edmap_to_py, &cvdata, 
                                     p_xyzcv, uvcvrng, cvmap_to_py,
                                     p_sfdata, xyztol, uvtol, &p_list);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup); 

    /*
     * Post the edge ID on sibling and convert the data the full edge format
     * if it is a part edge.
     */
    p_node = p_tail ? p_tail->p_next : p_list;
    while (p_node)
    {
      p_node->intpt.cvpt.cvid = PW_K_NullObjid;
      p_node->intpt.sibling.cvid = p_edges[ed];
      pwCvtToEdPar (p_edges[ed], os, &p_node->intpt.sibling.cvparam, &tpar);
      p_node->intpt.sibling.cvparam = tpar;
      p_node = p_node->p_next;
    }

  } /* for (ed=0 ...) */

  AccRejOverlapEndInteractions (p_list, os, uvtol, 10*uvtol);

  /*
   * Delete all the informational nodes.
   */

  p_node = p_list;
  while (p_node)
  {
    if (pwIsInfoNodeCvintptList (p_node))
    {
      p_nextnode = p_node->p_next;
      pwRemoveCvintptList (&p_list, p_node);
      pwFreeCvintptList (p_node);
    }
    else
      p_nextnode = p_node->p_next;

    p_node = p_nextnode;
  }

  /*
   * Sort all the interaction points.
   */
  pwSortCvintptList (&p_list, uvtol);

  if (p_list)
    pwAppendCvintptList (p_cvintpts, p_list);
  p_list = NULL;

wrapup :

  if (IsError (PWsts) && p_list)
    pwFreeCvintptList (p_list);

  PW_Wrapup (PWsts, "pwIntersectWithLoop");
  return PWsts;
}

/* ------------------------------------------------------------------------- */
/*                      End of API Source Code                               */
/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */
/*                     Support Functions Listing                             */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT

    Given the adjacent edge data and the length tolerance it gets the adjacent 
    point (which is first span end point). If edge happened to be a polyline, 
    it get's the first non-degenerate span end point otherwise a point on the
    tangent vector with 100 times lentol distance.

  NOTES

    None.
*/ 

static PWresult GetAdjacentPoint
(
  struct PWcvdata  *p_cvdata,
  PWboolean        reversed,
  double           lentol,
  PWpoint          adjpt
)
{
  PWresult   PWsts=PW_K_Success;

  int        i;
  PWpoint    endpt;
  PWvector   tangent;
  PWpoint2d  segpts[2];
  struct PWcvparam cvpar;

  memset (tangent, 0, sizeof (PWvector));

  if (reversed)
    pwGetMaxParCvdata (p_cvdata, &cvpar);
  else
    pwGetMinParCvdata (p_cvdata, &cvpar);

  if (p_cvdata->datatype == PWcvdata_py2d &&
      pwGetNonDegenSpanPy2d (&p_cvdata->data.py2d, cvpar.spaninx, lentol, 
                             segpts))
  {
    pwMakeVec2d (segpts[0], segpts[1], tangent);
    if (reversed) pwRevVec2d (tangent, tangent);
  }
  else
  {
    PWsts = pwGetTangentCvdata (p_cvdata, &cvpar, reversed, tangent);
    OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);

    pwNormVec (tangent, tangent);
    for (i=0; i<3; i++)
      tangent[i] *= 100 * lentol;
  }

  pwGetEndPtCvdata (p_cvdata, reversed, FALSE, endpt);

  adjpt[X] = endpt[X] + tangent[X];
  adjpt[Y] = endpt[Y] + tangent[Y];
  adjpt[Z] = 0.0;

wrapup :

  PW_Wrapup (PWsts, "pwIntersectWithLoop : GetAdjacentPoint");
  return PWsts;
}


/*
  DESCRIPTION

  Given the intersection list generated when a curve is intersected with a
  loop, this function tries to resolve discrepancies that may exist between
  the overlap nodes and the pure intersection nodes occurring near vertices.

  In a perfect situation with no discrepancies, an intersection point occurring
  at a vertex will have two intersection points in the list (one at the start
  of an edge and one at the stop of it's adjacent edge). The one at the start
  is marked as informational only. In a later step the informational nodes
  are to be deleted. So an overlap region that starts from a vertex should
  have another corresponding intersection node in the list associated with the
  adjacent edge.

  Discrepancies can occur within such pairs, or such pairs may not be found.
  In either case, it calls for some corrective action.


  ALGORITHM

  This function, first looks for a node that bounds an overlap and then scans
  the rest of the list for the corresponding node of the pair. This search
  is a bit lose in that it is done using the overlap-tolerance.

  One of two things can happen:
  1) The other of the pair is not found. In which case, the existing overlap
     node at this vertex is unconditionally accepted. It's informational nature
     (if it is at the start of an edge) is removed and it becomes a valid node.
  2) The other of the pair is found. In this case, this "other" node is checked
     to see if the incidence is at the vertex. If this incidence is in the
     "middle" of the adjacent edge, then this "other" node is rejected
     (made informational) while the overlap node, incident on the vertex is
     accepted as a valid node.


  ASSUMPTION

  Overlap tolerance (overtol) is bigger than Zero length tolerance (lentol). 
  overtol is used for detecting the overlaps and lentol is used for detecting
  the pure intersection points. 


  NOTES 

  If the "overtol" and "lentol" are equal, then this function does not serve
  any purpose, because the intersection points will be accurate.
*/

static void AccRejOverlapEndInteractions
(
  struct PWcvintpt_list *p_cvintpts, 
  PWosnum os,
  double lentol,
  double overtol
)
{
  int knt=0;
  PWobjid adjed=PW_K_NullObjid, thised=PW_K_NullObjid;
  struct PWcvintpt_list *p_node=NULL, *p_adjnode=NULL, *p_overnode=NULL;
  enum PWtopopostype e_topopos=PWtopopos_unknown;

  p_node = p_cvintpts;

  while (p_node && p_node->p_next)
  {
    if ((p_node->intpt.sibling.cvid == p_node->p_next->intpt.sibling.cvid) &&
        (pwGetContainCvintpt (&p_node->intpt, RIGHT) == PWcontain_on) &&
        (pwGetContainCvintpt (&p_node->p_next->intpt, LEFT) == PWcontain_on))
    {
      /*
       * This is an overlap region on a single edge.
       */

      for (knt=START; knt<=STOP; knt++)
      {
        p_overnode = NULL;
        adjed = PW_K_NullObjid;
        e_topopos = (knt == START) ? PWtopopos_start : PWtopopos_stop;

        /*
         * See if this node lies at this vertex (START or STOP). If not,
         * ignore this node.
         */

        if (pwGetTopoposCvpt (&p_node->intpt.sibling) == 
             e_topopos)
        {
          p_overnode = p_node;
        }
        else if (pwGetTopoposCvpt (&p_node->p_next->intpt.sibling) == 
                  e_topopos)
        {
          p_overnode = p_node->p_next;
        }

        if (!p_overnode)
          continue;

        /*
         * Scan all the intersection list to look for a node that has incidence
         * on the adjacent edge of this vertex. In case of ambiguity, pick the
         * one closest to this vertex. Different actions are taken if one
         * such "adjacent" node is found or not.
         */

        thised = p_overnode->intpt.sibling.cvid;
        if (knt == START)
          adjed = pwGetPrevEdNoDegen (thised, os, lentol);
        else
          adjed = pwGetNextEdNoDegen (thised, os, lentol);

        if (adjed == thised || adjed == PW_K_NullObjid)
          p_adjnode = NULL;
        else
          p_adjnode = GetEndNodeOnCvid (p_cvintpts, adjed,  TRUE,
                       pwIsEdRev (adjed, os), (PWboolean)((knt == START) ? (FALSE) : (TRUE)));

        if (p_adjnode)
        {
          /*
           * There is a node at some proximity from this node, which lies
           * on the adjacent edge.
           */
  
          if (pwGetTopoposCvpt (&p_adjnode->intpt.sibling) == PWtopopos_middle)
          {
            /*
             * This interaction point is at the middle of the edge. Need to 
             * find whether it is a spurious interaction point or not. 
             */
            
            if (IsPtAtEndEdge (adjed, os, &p_adjnode->intpt.sibling, 
                 (PWboolean)((e_topopos == PWtopopos_start) ? (FALSE) : (TRUE)), overtol))
            {
              /*
               * There is an intersection node on the adjacent edge which is
               * with in gray-zone tolerance of the vertex. So, what we will
               * do is to set the Info property for this guy (causing an 
               * eventual deletion) and unset the info node property for the
               * overlap interaction point at the vertex (causing it to 
               * survive). The assumption is that the intersection point on
               * adjacent edge was caused dur to geometric noise (or the 
               * gray zone phenomenon).
               */
  
              pwSetInfoNodeCvintptList (p_adjnode);
              pwUnsetInfoNodeCvintptList (p_overnode);
  
              if (pwGetDebugLevel () >= PW_K_DebugWarning)
                pwDebugLine (PW_K_DebugWarning,
                 "Trim: Spurious Interaction on Edge : %d , Surf : %d \n",
                 adjed , pwGetSfOfEd (adjed, os));
            }

            else if (pwIsInfoNodeCvintptList (p_overnode))
            {
              /*
               * Since no interaction point was found on the adjacent edge that
               * corresponded within the gray zone to the vertex, we have to
               * accept the overlap start-point as a valid point. This is how
               * the overlap will be bounded. (Info property is set for
               * start-point interactions).
               */

              pwUnsetInfoNodeCvintptList (p_overnode);
  
              if (pwGetDebugLevel () >= PW_K_DebugWarning)
                pwDebugLine (PW_K_DebugWarning,
                 "Trim: At-Start Overlap accepted on Edge: %d , Surf : %d \n",
                 thised , pwGetSfOfEd (adjed, os));
            } 
          }
        }

        else if (pwIsInfoNodeCvintptList (p_overnode))
        {
          /*
           * There is no matching interaction point for this interaction.
           * So, don't delete this interaction point at any cost (turn off
           * the Info property). This start-point interaction will serve as
           * the bounding node for the overlap. 
           */

          pwUnsetInfoNodeCvintptList (p_overnode);

          if (pwGetDebugLevel () >= PW_K_DebugWarning)
            pwDebugLine (PW_K_DebugWarning,
             "Trim: At-start Overlap accepted on Edge : %d , Surf : %d \n",
             thised, pwGetSfOfEd (adjed, os));
        }
      }
    }

    p_node = p_node->p_next;
  }

  return;
}



/*
  ABSTRACT

    Given the intersection list and a Cvid, it returns the intersection node
    on Cvid closure to the given end (start/stop). If there is no intersection
    on ths Cvid it returns NULL.

  NOTES

    None.
*/

struct PWcvintpt_list * GetEndNodeOnCvid
(
  struct PWcvintpt_list *p_cvintpts,
  PWobjid cvid,
  PWboolean sibling,
  PWboolean cvrev,
  PWboolean start
)
{
  double dist=0, mindist=0;
  struct PWcvpt *p_cvpt=NULL;
  struct PWcvintpt_list *p_minnode=NULL;

  while (p_cvintpts)
  {
    p_cvpt = sibling ? & p_cvintpts->intpt.sibling : &p_cvintpts->intpt.cvpt;

    if (p_cvpt->cvid == cvid)
    {
      dist = p_cvpt->cvparam.spaninx + p_cvpt->cvparam.spanpar;
 
      if (p_minnode)
      {
        if (start ? (cvrev ? dist > mindist : dist < mindist) :
                    (cvrev ? dist < mindist : dist > mindist))
        p_minnode = p_cvintpts;
        mindist = dist;   
      }
      else 
      {
        p_minnode = p_cvintpts;
        mindist = dist;
      } 
    }

    p_cvintpts = p_cvintpts->p_next;
  }

  return p_minnode;

}


/*
  ABSTRACT

    Given an edge and a point (PWcvpt) on the edge, it returns TRUE if the 
    point coincides with the given end of the edge otherwise FALSE. In case
    of a closed edge, it does not differentiate between the start/stop points.

  NOTES

    None.
*/

static PWboolean IsPtAtEndEdge
(
  PWobjid  edobj,
  PWosnum  edos,
  struct PWcvpt *p_edpt,
  PWboolean start,
  double   tol
)
{
  PWresult PWsts=PW_K_Success;
  PWboolean edrev=FALSE, atend=FALSE;

  if (pwGetEdGeomType (edobj, edos) == PWcvdata_bspcv)
  {
    struct PWcvdata eddata;
    double endpar=0.0, partol=0.0;

    memset (&eddata, 0, sizeof (struct PWcvdata));

    PWsts = PW_GetNatEdGeomStack (edobj, edos, eddata);
    OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);
    
    edrev = pwIsEdRev (edobj, edos);
    partol = pwGetParTolCv (eddata.data.p_bspcv, tol);

    if ((!edrev && start) || (edrev && !start))
      endpar = eddata.data.p_bspcv->knots [eddata.data.p_bspcv->order-1];
    else
      endpar = eddata.data.p_bspcv->knots [eddata.data.p_bspcv->num_poles];

    if (fabs (endpar - p_edpt->cvparam.spanpar) < partol)
      atend = TRUE;
    else if (eddata.data.p_bspcv->phy_closed)
    {
      if ((!edrev && start) || (edrev && !start))
        endpar = eddata.data.p_bspcv->knots [eddata.data.p_bspcv->num_poles];
      else
        endpar = eddata.data.p_bspcv->knots [eddata.data.p_bspcv->order-1];

      if (fabs (endpar - p_edpt->cvparam.spanpar) < partol)
        atend = TRUE;
    }
  }
  else
  {
    double sqtol=tol*tol;
    PWpoint edstart={0.0,0.0,0.0}, edstop={0.0,0.0,0.0};

    pwGetEdEndPts (edobj, edos, edstart, edstop);

    if (pwDistSqPtPt2d (p_edpt->pt, start ? edstart : edstop) < sqtol)
      atend = TRUE;    
  }
 
wrapup :  

  return atend;
}

  
