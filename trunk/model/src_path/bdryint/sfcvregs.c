/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */
 
/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT

     Given all the interaction points of the intersection curve on a  surface
     with the surface boundaries, it returns the regions those, 1) lie inside
     the area of the surface 2) lie on the boundaries of the surface. 
 
  DESCRIPTION

     An API which supports Trimming. 

     This function is used to determine the regions  of  the  UV intersection 
     curve (in the UVspace of the surface) those fall in area or on boudaries
     of the surface. The input being all the interaction points in the ascen-
     ding order on the intersection curve, the curve data and the surface ID.

     A significant output is the containment classification of these regions.
     The  classification could be IN or ON. IN refers to inside area  and  ON 
     refers to on the boundary. All the regions which are out of the area  or  
     not on the boundaries will be automatically thrown out by this function.

     If a region is said to be ON the boundary, then the "Edge" with which it 
     is coincident will be stored as an attribute of the region.

  NOTES

     The xyztol is expected to be chord-height tolerance. This  is  tolerance
     against which the overlap in XYZ space is checked.

     Memory for the output linklist is allocated in this function. It  is the
     caller's responsibility to free the memory allocated.
 
  ARGUMENTS

     p_sfgmid    I  Surface geomid consisting the ID, transformation matrix
                    and the matrix type.
     p_cvdata    I  UV-space geometry of the intersection  curve  which  is
                    typically output of the BS math function of sf-sf inte-
                    rsection.
     xyztol      I  The value which defines the distance within which 2 cu-
                    rves/part of curves are overlaping.
     p_cvintpts  I  Sorted interaction point list (in the ascending order of
                    the UV-intersection curve). 

     p_cvregs   I/O A linked list of PWcvregion_list structures that conat-
                    ain all the information about the curve  regions  those
                    fall within the area / on the boundaries of the surface.
                    If this list on input is non-NULL, the  output  regions
                    are appended to the list.

  RETURN CODE

     PW_K_Success     - If everything goes well.
     PW_K_Internal    - Any inetrnal failure.
     PW_K_InvalidArg  - Invalid Arguments.
     PW_K_BspMath     - Any BS math failure.
     PW_K_PathwayMath - Any Pathway math failure.

  KEYWORDS

      Trimming, Intersection, Boundary, Surface, Loop, Edge ...

  CAVEATS
 
  HISTORY

     Sanjay                Creation 
*/

/* Includes */

#include <stdio.h>
#include <math.h>
#include <alloca.h>                 /* Standard C library Includes */
#include <memory.h>

#include "igrtypedef.h"
#include "igr.h"        /* BS Include Stuff */
#include "bs.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bsvalues.h"

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWerror.h"                /* PATHWAY Include Stuff */
#include "PWattribid.h"
#include "PWattrib.h"

/* Prototypes */

#include "bsorthovec.h"
#include "bscvarrevc.h"             /* BS */

#include "PWapi/sfgeom.h"
#include "PWapi/lped.h"
#include "PWapi/edgeom.h"
#include "PWapi/partol.h"
#include "PWapi/sfcvregs.h"
#include "PWapi/ptpargm.h"         /* Pathway */
#include "PWapi/normvec.h"
#include "PWapi/rngbx.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/sfptloc.h"
#include "PWapi/dbglevel.h"
#include "PWapi/eded.h"
#include "PWapi/edprops.h"
#include "PWapi/sortvec.h"
#include "PWapi/mkvec.h"
#include "PWapi/mkcvregs.h"

/* Internal Prototypes */

static PWresult AddNodeAtEnd
(
  struct PWcvintpt_list  **p_cvintpts,
  struct PWcvintpt_list  *p_node, /* to the side of this node */
  struct PWcvdata        *p_cvdata,
  int                    side
);

static PWresult GetCvEndParams
(
  struct PWcvdata  *p_cvdata,
  struct PWcvpt    *p_start_cvpt,
  struct PWcvpt    *p_stop_cvpt
);

static PWresult  ClassifyRegions
(
  struct PWcvintpt_list  **p_cvintpts,
  double                 xyztol,
  double                 uvtol,
  struct PWgeomid        *p_sfgmid,
  struct PWcvdata        *p_cvdata
);

static PWresult VerifySiblingInfo
(
  struct PWcvintpt_list *p_cvintpts, 
  double xyztol, 
  struct PWgeomid *p_sfgmid
);

static PWresult DeleteSpuriousNodes
(
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvdata *p_cvdata,
  struct PWgeomid *p_sfgmid,
  double uvtol
);

static int GetCvRegion
(
  struct PWcvintpt_list  *p_intpt,
  struct PWcvintpt_list  *p_next_intpt,
  double                 partol  /* WHICH ONE TO PASS IN ? */
);

static PWresult GetMidCvUvpt
(
  struct PWcvintpt_list  *p_intpt,
  struct PWcvintpt_list  *p_next_intpt,
  struct PWcvdata        *p_cvdata,
  double                 *pt
);

static PWresult ProcessOffendingNodes
(
  struct PWcvintpt_list  **p_cvintpts,
  struct PWgeomid        *p_sfgmid,
  struct PWcvdata        *p_cvdata
);

static PWresult RearrangeGroupByAngleSort
(
  int                   n_nodes,
  struct PWcvintpt_list **p_cvintpts,
  PWosnum               os,
  struct PWcvdata       *p_cvdata
);

static PWboolean  IsNodeTogglesWithRegion
(
  struct PWcvintpt_list *p_node
);


extern PWresult pwGetRadCenCurvCvdata
(
  struct PWcvdata   *p_cvdata,
  struct PWcvparam  *p_par,
  PWboolean         reverse,
  double            *radius,
  double            *cen_vec
);


/* External Variables */

/* Internal Macros */

#define  DEGENERATE  0
#define  AREA        1
#define  HOLE        2
#define  BDRY        3
#define  ARBIT       3
#define  UNKNOWN     4
#define  OFFENDING   5


PWresult  pwCreateSfCvRegion
(
  struct PWgeomid        *p_sfgmid,    
  struct PWcvdata        *p_cvdata,
  double                 xyztol,
  struct PWcvintpt_list  **p_cvintpts,
  struct PWcvregion_list **p_cvregs
)
{
  /* status and general stuff */
  PWresult  PWsts=PW_K_Success;
  struct PWcvparam maxparam;

  /* tolerances */
  double  uvtol;

  /* geometry */
  struct IGRbsp_surface *p_sfgeom=NULL; 

  /* Curve intersection nodes */
  struct PWcvintpt_list  *p_prev_node=NULL; /* store prev node of the list */
  struct PWcvintpt_list  *p_head, *p_tail;

  /* 
   * validate the incoming arguments 
   */
  if (!p_sfgmid || !p_cvdata || !p_cvintpts || !p_cvregs)
    OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_InvalidArg), 
                  wrapup);

  /*
   * store the prev node of the incoming list
   */
  p_prev_node = (*p_cvintpts) ? (*p_cvintpts)->p_prev : NULL;

  /*
   * get the surface geometry from stack.
   */
  PWsts = PW_GetSfBspsfStack (p_sfgmid->id.objid, p_sfgmid->id.osnum,
                     p_sfgmid->mattyp, p_sfgmid->mat, p_sfgeom);
  OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, PW_K_Internal),
                wrapup);

  /*
   * get the surface uv tolerance from xyz
   */
  uvtol = pwGetParTolSf (p_sfgeom, xyztol);

  /*
   * Step #1 : Add Nodes At The Ends
   *   If there are no nodes at the ends of the intersection curve, then add
   *   the nodes. The relative containment of the added nodes can be inferred
   *   from the adjacent nodes. If the adjacent node is marked 'ArbSeq' then
   *   both left and right relative contaiments of the added node becomes 'Un
   *   known'.
   */
  p_head = *p_cvintpts;
 
  if (!p_head || pwGetTopoposCvpt (&p_head->intpt.cvpt) != PWtopopos_start ||
      p_head->intpt.cvpt.cvparam.spaninx != 0)
  {
    PWsts = AddNodeAtEnd (p_cvintpts, p_head, p_cvdata, LEFT);
    OnErrorState (IsError(PWsts), PWsts, 
                  SetError (PW_K_Trimming, PW_K_Internal), wrapup);
  }

  p_tail = pwTailCvintptList (*p_cvintpts);

  pwGetMaxParCvdata (p_cvdata, &maxparam);

  if (pwGetTopoposCvpt (&p_tail->intpt.cvpt) != PWtopopos_stop ||
      p_tail->intpt.cvpt.cvparam.spaninx != maxparam.spaninx)
  {
    PWsts = AddNodeAtEnd (p_cvintpts, p_tail, p_cvdata, RIGHT);
    OnErrorState (IsError(PWsts), PWsts, 
                  SetError (PW_K_Trimming, PW_K_Internal), wrapup);
  }

  /*
   * Step #2 : Classify Regions
   * 
   */
  PWsts = ClassifyRegions (p_cvintpts, xyztol, uvtol, p_sfgmid, p_cvdata);  
  OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, PW_K_Internal),
                wrapup);

  /*
   * Step #3 : Make sure that all ON regions are bounded by cvpts
   * that have valid 'sibling' information. This may be missing, if one
   * of the bounds of the ON region has been artificially generated
   * above, as one of the nodes-at-end.
   */
  PWsts = VerifySiblingInfo (*p_cvintpts, xyztol, p_sfgmid);
  OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, PW_K_Internal),
                wrapup);

  /*
   * Step #4 : Delete all the interactions with in any ON region. These are 
   * spurious interactions which might got generated because of touching of
   * loops.
   */
  PWsts = DeleteSpuriousNodes (p_cvintpts, p_cvdata, p_sfgmid, uvtol);
  OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, PW_K_Internal),
                wrapup);
  
  /*
   * Step #5 : Process the Offending Nodes
   */
  PWsts = ProcessOffendingNodes (p_cvintpts, p_sfgmid, p_cvdata);
  OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, PW_K_Internal),
                wrapup);

  /*
   * Step #6 : Make Regions
   */
  PWsts = pwMakeCvRegions (p_cvintpts, p_cvdata, p_sfgmid->id.osnum, uvtol, 
                           p_cvregs);
  OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, PW_K_Internal),
                wrapup);

wrapup : 

  /* 
   * reset the prev pointer of the intersection list 
   */
  if (p_prev_node) 
    (*p_cvintpts)->p_prev = p_prev_node;

  PW_WrapupId (PWsts, "pwCreateSfCvRegion", p_sfgmid->id.objid);
  return PWsts;
}


/*
  DESCRIPTION

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
    PWsts = GetCvEndParams (p_cvdata, &p_new_node->intpt.cvpt, NULL);
    OnErrorState (IsError (PWsts), PWsts, 
                  SetError (PW_K_Trimming, PW_K_Internal), wrapup);

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
    PWsts = GetCvEndParams (p_cvdata, NULL, &p_new_node->intpt.cvpt);
    OnErrorState (IsError (PWsts), PWsts,
                  SetError (PW_K_Trimming, PW_K_Internal), wrapup);

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
  DESCRIPTION

     Given the curve data, it extracts the start and stop curve paramters
     in the PWcvpt structure.

  NOTES

     All the memory for the output must be allocated by the caller.
*/

static PWresult GetCvEndParams
(
  struct PWcvdata  *p_cvdata, 
  struct PWcvpt    *p_start_cvpt, 
  struct PWcvpt    *p_stop_cvpt 
)
{
  int     n_pts, dim=3, mininx=0, maxinx=0;
  double  *p_pts=NULL, minpar=0.0, maxpar=1.0;

  if (!p_cvdata || (p_cvdata->datatype == PWcvdata_null) ||
      (!p_start_cvpt && !p_stop_cvpt))
    return SetError (0, PW_K_InvalidArg); 

  if (p_cvdata->datatype == PWcvdata_py2d)
  {
    n_pts = p_cvdata->data.py2d.num_pts;
    p_pts = (double *) p_cvdata->data.py2d.p_pts;
    dim = 2;
    mininx = 0; maxinx = n_pts - 2;
  }
  else if (p_cvdata->datatype == PWcvdata_py)
  {
    n_pts = p_cvdata->data.py.num_pts;
    p_pts = (double *) p_cvdata->data.py.p_pts;
    mininx = 0; maxinx = n_pts - 2;
  }
  else if (p_cvdata->datatype == PWcvdata_bspcv)
  {
    n_pts = p_cvdata->data.p_bspcv->num_poles;
    p_pts = p_cvdata->data.p_bspcv->poles;
    minpar = p_cvdata->data.p_bspcv->knots[p_cvdata->data.p_bspcv->order-1];
    maxpar = p_cvdata->data.p_bspcv->knots[n_pts];
  }
  else 
  {
    n_pts = p_cvdata->data.p_gmbspcv->bspcv->num_poles;
    p_pts = p_cvdata->data.p_gmbspcv->bspcv->poles;
    minpar = p_cvdata->data.p_gmbspcv->bspcv->knots
                [p_cvdata->data.p_gmbspcv->bspcv->order-1];
    maxpar = p_cvdata->data.p_gmbspcv->bspcv->knots[n_pts];
  }

  if (p_start_cvpt)
  {
    p_start_cvpt->pt[2] = 0.0;
    pwSetTopoposCvpt (p_start_cvpt, PWtopopos_start);
    memcpy (p_start_cvpt->pt, p_pts, dim * sizeof(double)); 
    p_start_cvpt->cvparam.spaninx = mininx;
    p_start_cvpt->cvparam.spanpar = minpar;
  }

  if (p_stop_cvpt)
  {
    p_stop_cvpt->pt[2] = 0.0;
    pwSetTopoposCvpt (p_stop_cvpt, PWtopopos_stop);
    memcpy (p_stop_cvpt->pt, &p_pts[(n_pts-1)*dim], dim * sizeof(double));
    p_stop_cvpt->cvparam.spaninx = maxinx;
    p_stop_cvpt->cvparam.spanpar = maxpar;
  }

  return PW_K_Success;
}


/*
  DESCRIPTION

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
  struct PWcvdata        *p_cvdata
)
{
  /* status stuff */
  PWresult  PWsts=PW_K_Success;

  /* local nodes */
  struct PWcvintpt_list  *p_node=NULL;
  PWosnum os=p_sfgmid->id.osnum;

  /* point locate info */
  enum PWptloctype ptpos=PWptloc_unknown; 
  PWobjid          bdry_contain_elem=PW_K_NullObjid, lpid=PW_K_NullObjid;
  PWpoint2d        uvpt={0.0, 0.0};
  struct PWcvpt    edpt;
 
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
         * Need to surface point locate
         */
        PWsts = GetMidCvUvpt (p_node, p_node->p_next, p_cvdata, uvpt); 
        OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, 
                      PW_K_Internal), wrapup);

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
               * Probably these are spurious interaction points. If any one
               * of the two points does not have a sibling (their loop 
               * affiliation is not known), then set the containment between
               * the two nodes as "unknown". Else, retain the containments as
               * pointed to by the points themselves (these may or may not
               * conflict. Further processing will take care of it).
               */

              enum PWcontaintype rt_contain, lf_contain;
    
              if (pwIsNoSiblingCvintpt (&p_node->intpt) || 
                  pwIsNoSiblingCvintpt (&p_node->p_next->intpt))
              {
                rt_contain = PWcontain_unknown;
                lf_contain = PWcontain_unknown;
              }
              else
              {
                rt_contain = pwGetContainCvintpt (&p_node->intpt, RIGHT);
                lf_contain = pwGetContainCvintpt (&p_node->p_next->intpt,LEFT);
              }

              pwSetContainCvintptList (p_node, NEXT, rt_contain);
              pwSetContainCvintptList (p_node->p_next, PREV, lf_contain);
                          
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
  DESCRIPTION

  Given the interaction points list this function makes sure that all
  ON regions are bounded by cvpts with valid sibling information.
*/

static PWresult VerifySiblingInfo
(
  struct PWcvintpt_list  *p_cvintpts, 
  double                 xyztol,
  struct PWgeomid        *p_sfgmid
)
{
  int side;
  PWresult PWsts=PW_K_Success;
  struct PWcvintpt_list *p_node=NULL;
  enum PWptloctype ptpos=PWptloc_unknown; 
  PWobjid bdry_contain_elem=PW_K_NullObjid;
  struct PWcvpt edpt;

  while (p_cvintpts && p_cvintpts->p_next)
  {
    for (side=NEXT, p_node=p_cvintpts;
         side>=PREV; 
         side--, p_node=p_cvintpts->p_next)
    {
      if (pwGetContainCvintptList (p_node, side) == PWcontain_on &&
          pwIsNoSiblingCvintpt (&p_node->intpt))
      {
        edpt.cvid = PW_K_NullObjid;
        PWsts = pwSfPtLocate (p_sfgmid, NULL, 
                 p_node->intpt.cvpt.pt, xyztol, &ptpos, 
                 &bdry_contain_elem, &edpt);
        OnErrorState (IsError (PWsts) || edpt.cvid == PW_K_NullObjid, PWsts,
         SetError (PW_K_Trimming, PW_K_Internal), wrapup);
  
        memcpy (&p_node->intpt.sibling, &edpt, sizeof (struct PWcvpt));
        pwUnsetNoSiblingCvintpt (&p_node->intpt);
      }
    }

    p_cvintpts = p_cvintpts->p_next;
  }

wrapup: 
  PW_Wrapup (PWsts, "VerifySiblingInfo");
  return (PWsts);
}


/*
  DESCRIPTION

    Deletes all the interactions with in any overlap region as these are
    spurious interactions which might got generated because of touching 
    of loops.

  NOTES

    None.
*/

static PWresult DeleteSpuriousNodes 
(
  struct PWcvintpt_list **p_cvintpts, 
  struct PWcvdata *p_cvdata,
  struct PWgeomid *p_sfgmid,
  double uvtol
)
{
  PWresult PWsts=PW_K_Success;
  int i=0, num_nodes=0;
  struct PWcvintpt_list *p_node=NULL, *p_next_node=NULL, *p_tmp_node=NULL;
  PWobjid coinced=PW_K_NullObjid;
  PWosnum os=p_sfgmid->id.osnum;
  double par=0;
  PWpoint midpt;
  PWboolean found=FALSE;
  struct PWcvparam midpar, *p_startpar=NULL, *p_stoppar=NULL;

  for (p_node = *p_cvintpts; p_node && p_node->p_next; p_node = p_node->p_next)
  {
    num_nodes = 0;
    found = FALSE;

    if (pwGetContainCvintpt (&p_node->intpt, RIGHT) == PWcontain_on)
    {
      for (p_next_node = p_node->p_next; p_next_node; 
           p_next_node = p_next_node->p_next)
      {
        num_nodes ++;

        if (pwGetContainCvintpt (&p_next_node->intpt, LEFT) == PWcontain_on &&
            pwGetLpOfEd (p_node->intpt.sibling.cvid, os) == 
            pwGetLpOfEd (p_next_node->intpt.sibling.cvid, os))
        {
          /*
           * This region is ON the boundary, which means that it is coincident
           * with one of the edges. So, get the intervening  edge  with  which
           * the region is coincident and store it as an attribute.
           */

          p_startpar = &p_node->intpt.cvpt.cvparam;
          p_stoppar = &p_next_node->intpt.cvpt.cvparam;
          par = ( p_startpar->spaninx + p_startpar->spanpar +
                  p_stoppar->spaninx  + p_stoppar->spanpar ) / 2.0;
          midpar.spaninx = (int) par;
          midpar.spanpar = par - (int) par;
  
          PWsts = pwPtAtParCvdata (p_cvdata, &midpar, midpt);
          OnErrorState (IsError (PWsts), PWsts, SetError (PW_K_Trimming,
                        PW_K_Internal), wrapup);

          coinced = PW_K_NullObjid;
          coinced = pwGetInterveningEdge (os, p_node->intpt.sibling.cvid, 
                        pwGetTopoposCvpt (&p_node->intpt.sibling),
                        p_next_node->intpt.sibling.cvid, 
                        pwGetTopoposCvpt (&p_next_node->intpt.sibling),
                        midpt, uvtol);

          if (coinced != PW_K_NullObjid)
          {
            found = TRUE;
            break;
          }
        }
      }  

      if (found && num_nodes > 1)
      {
        pwDebugLine (PW_K_DebugWarning, 
                     "Trim: Deleting %d Spurious Interactions\n", num_nodes-1);

        p_tmp_node = p_node->p_next;

        for (i=0; i<num_nodes-1; i++, p_tmp_node = p_next_node)
        {
          p_next_node = p_tmp_node->p_next;
          pwRemoveCvintptList (p_cvintpts, p_tmp_node);
          pwFreeCvintptList (p_tmp_node);
        }    

      }
    }
  }

wrapup :

  PW_Wrapup (PWsts, "DeleteSpuriousNodes");
  return PWsts;
}


/*
  DESCRIPTION

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
  DESCRIPTION
     
     Given two consequtive interactoin nodes and the curve data, it extracts
     a point on the curve which is a mid point between the two given nodes.

  NOTES

     All the memory for the output must be allocated by the caller.
*/ 

static PWresult GetMidCvUvpt 
(
  struct PWcvintpt_list  *p_intpt,
  struct PWcvintpt_list  *p_next_intpt,
  struct PWcvdata        *p_cvdata,
  double                 *p_pt
)
{
  PWresult  PWsts = PW_K_Success;
  struct PWcvparam cvpar;
  double    par,tmppt[3];

  par = (p_intpt->intpt.cvpt.cvparam.spaninx + 
         p_intpt->intpt.cvpt.cvparam.spanpar +
         p_next_intpt->intpt.cvpt.cvparam.spaninx +
         p_next_intpt->intpt.cvpt.cvparam.spanpar) / 2.0;

  cvpar.spaninx = (int) par;
  cvpar.spanpar = par - cvpar.spaninx;

  switch (p_cvdata->datatype)
  {
    case PWcvdata_py2d :
      PWsts = pwPtAtParPy2d (p_cvdata->data.py2d.num_pts, 
                             p_cvdata->data.py2d.p_pts, &cvpar, tmppt); 
    break;

    case PWcvdata_py   :
      PWsts = pwPtAtParPy (p_cvdata->data.py.num_pts, 
                           p_cvdata->data.py.p_pts, &cvpar, tmppt); 
    break;

    case PWcvdata_bspcv   :
      PWsts = pwPtAtParCv (p_cvdata->data.p_bspcv, cvpar.spanpar, tmppt);
    break;
      
    case PWcvdata_gmbspcv :
      PWsts = pwPtAtParCv (p_cvdata->data.p_gmbspcv->bspcv, cvpar.spanpar, tmppt);
    break;

    default :
      PWsts = SetError (PW_K_Trimming, PW_K_InvalidArg);
    break;
  }

  p_pt[U] = tmppt[U];
  p_pt[V] = tmppt[V];

  return PWsts;
}


/*
  DESCRIPTION
     
     It returns TRUE, if the given node toggles with it's region classifi-
     cation, otherwise FASLE.

  NOTES
     
     None
*/

static PWboolean  IsNodeTogglesWithRegion 
(
  struct PWcvintpt_list *p_node
)
{
  enum PWcontaintype nd_cont=PWcontain_unknown;

  if (p_node->p_prev)
  {
    nd_cont = pwGetContainCvintpt (&p_node->intpt, LEFT);

    if (nd_cont == PWcontain_unknown)
      return (PWboolean) FALSE;

    if (pwGetContainCvintptList (p_node, PREV) != nd_cont)
      return (PWboolean) FALSE; 
  }

  if (p_node->p_next)
  {
    nd_cont = pwGetContainCvintpt (&p_node->intpt, RIGHT);

    if (nd_cont == PWcontain_unknown)
      return (PWboolean) FALSE;

    if (pwGetContainCvintptList (p_node, NEXT) != nd_cont)
      return (PWboolean) FALSE;
  }

  return (PWboolean) TRUE;
}

#define SwapIntPts(node1, node2, intpt) \
{ \
  memcpy (&(intpt), &(node1)->intpt, sizeof(struct PWcvintpt)); \
  memcpy (&(node1)->intpt, &(node2)->intpt, sizeof(struct PWcvintpt)); \
  memcpy (&(node2)->intpt, &(intpt), sizeof(struct PWcvintpt)); \
}


/*
  DESCRIPTION

     All the major steps involved in "Curve-Region Generation" will be done
     in this routine.

     Given an interaction points list, surface ID and the curve data it pr-
     ocesses all the offending nodes (the nodes whose relative containment
     classification does not match with the region classification) by rear-
     ranging / deleting them if necessary or by introduction of new nodes.

  NOTES

     All the memory for the output is allocated by this routine.
*/

static PWresult ProcessOffendingNodes 
(
  struct PWcvintpt_list  **p_cvintpts,
  struct PWgeomid        *p_sfgmid,
  struct PWcvdata        *p_cvdata
)
{
  /* Status and Genral stuff */
  PWresult   PWsts=PW_K_Success;
  PWboolean  found=FALSE;
  int        n_nodes=0, n_grp_nodes=0, n_igrp_nodes=0, pos=0, reg=0; 
  int        nd=0, new_nd=0, ind=0, nd1=0, nd2=0, inx=0;
  int        n_cont_nodes=0, *cont_indx=NULL;

  /* Intersection points */
  struct PWcvintpt       intpt;
  struct PWcvintpt_list  *p_node=NULL, **p_grp_nodes=NULL, **p_igrp_nodes=NULL;
  struct PWcvintpt_list  *p_splitter_node, *p_tmp_node=NULL, *p_next_node;

  /* Enumeraters for containment of regions and nodes */
  enum PWcontaintype  prev_reg_cont, next_reg_cont, reg_cont, int_cont;
  enum PWcontaintype  lf_intpt_cont, rt_intpt_cont;
 
  /* Loop Ids */ 
  PWobjid lf_lpid=PW_K_NullObjid, rt_lpid=PW_K_NullObjid, lpid=PW_K_NullObjid;
  PWobjid *p_lpids=NULL, best_lpid=PW_K_NullObjid; 
  int     lp=0, n_lps=0;
  PWosnum os;

  /* 
   * Initialization 
   */
  os = p_sfgmid->id.osnum;
  p_node = *p_cvintpts;

  n_nodes = pwNumCvintptList (p_node);
  if (!n_nodes)
    goto wrapup;

  p_grp_nodes = (struct PWcvintpt_list **) alloca (n_nodes * 
                                          sizeof (struct PWcvintpt_list *)); 
  OnErrorState (!p_grp_nodes, PWsts, SetError (PW_K_Trimming, 
                PW_K_DynamicMemory), wrapup);

  p_igrp_nodes = (struct PWcvintpt_list **) alloca (n_nodes * 
                                          sizeof (struct PWcvintpt_list *)); 
  OnErrorState (!p_grp_nodes, PWsts, SetError (PW_K_Trimming, 
                PW_K_DynamicMemory), wrapup);

  cont_indx = (int *) alloca (n_nodes * sizeof(int));
  OnErrorState (!cont_indx, PWsts, SetError (PW_K_Trimming, 
                PW_K_DynamicMemory), wrapup);

  p_lpids = (PWobjid *) alloca (n_nodes * sizeof(PWobjid));
  OnErrorState (!p_lpids, PWsts, SetError (PW_K_Trimming, PW_K_DynamicMemory), 
                wrapup);
 
  while (p_node)
  {
    /* 
     * Initialize the loop variables
     */ 
    n_lps           = 0;
    n_grp_nodes     = 0;
    n_cont_nodes    = 0;
    p_splitter_node = NULL;

    lf_lpid = PW_K_NullObjid;
    rt_lpid = PW_K_NullObjid;

    /* 
     * check, whether this node toggles with the region
     */
    if (! IsNodeTogglesWithRegion (p_node))
    {
      /*
       * The present node is the first node in the group.
       */
      p_grp_nodes[n_grp_nodes++] = p_node;

      /* 
       * as the node is not toggling with the adjacent region classification,
       * which we call 'offending node' we need to set proper rels on this 
       * interaction point.
       */
      if (pwIsArbSeqCvintptList (p_node))
      {
        p_tmp_node = p_node->p_next;

        while (p_tmp_node)
        {
          if (pwIsCoincCvintptList (p_tmp_node, PREV))
            p_grp_nodes[n_grp_nodes ++] = p_tmp_node;
          else
            break;

          p_tmp_node = p_tmp_node->p_next;
        }
      }
      
      n_igrp_nodes = n_grp_nodes;
      memcpy (p_igrp_nodes, p_grp_nodes, n_igrp_nodes * 
                                         sizeof(struct PWcvintpt_list *));

      p_next_node = p_grp_nodes[n_grp_nodes - 1]->p_next;

      /*
       * get the previous and next region's classifications 
       */
      prev_reg_cont = pwGetContainCvintptList (p_grp_nodes[0], PREV);
      next_reg_cont = pwGetContainCvintptList (p_grp_nodes[n_grp_nodes-1],
                                               NEXT);

      /*
       * Step #1 : Best Sequencing of end nodes and internal nodes. 
       *    a) first arrange the end nodes of this coincident nodes such that
       *       they match correctly with the region classification. If there
       *       are more than one candidate for each end position, then the am-
       *       biguity is resolved by looking at the loop to which the region
       *       belongs i.e. loop-associativity crieterion. So, the node from
       *       the same loop will be given preference. If the ambiguity is not
       *       resolved by this criterion, choose one of the nodes arbitrarily.
       *    b) Then arrange the internal nodes, so that they toggle with each
       *       other.
       */

      for (inx=LEFT; inx<=RIGHT && n_grp_nodes>=2; inx++)
      {
        p_tmp_node = (inx == LEFT) ? p_grp_nodes[0]->p_prev : 
                                     p_grp_nodes[n_grp_nodes-1]->p_next;
        reg_cont = (inx == LEFT) ? prev_reg_cont : next_reg_cont;

        if (reg_cont != PWcontain_unknown && p_tmp_node)
        {
          n_lps     = 0; 
          best_lpid = PW_K_NullObjid;

          /*
           * First get the best loop id.
           */

          if (pwIsArbSeqCvintptList (p_tmp_node))
          { 
            while (p_tmp_node)
            {
              if (pwIsCoincCvintptList (p_tmp_node, 
                                        (inx == LEFT) ? PREV : NEXT))
              {
                if (p_tmp_node->intpt.sibling.cvid != PW_K_NullObjid)
                {
                  p_lpids[n_lps] = pwGetLpOfEd (p_tmp_node->intpt.sibling.cvid,
                                                os);
                  n_lps ++;
                }
              }
              else
                break;

              p_tmp_node = (inx == LEFT) ? p_tmp_node->p_prev :  
                                           p_tmp_node->p_next;
            } 

            if (p_tmp_node && p_tmp_node->intpt.sibling.cvid != PW_K_NullObjid)
            {
              p_lpids[n_lps] = pwGetLpOfEd (p_tmp_node->intpt.sibling.cvid, os);
              n_lps ++;
            }
          }
          else
          {
            if (p_tmp_node->intpt.sibling.cvid != PW_K_NullObjid)
            {
              p_lpids [n_lps] = pwGetLpOfEd (p_tmp_node->intpt.sibling.cvid, os);
              n_lps ++;
            }
          }

          for (lp=0; lp<n_lps && n_lps > 1; lp++)
          {
            for (nd=0; nd<n_grp_nodes; nd++)
            {
              if (pwGetContainCvintpt (&p_grp_nodes[nd]->intpt, inx) == 
                  reg_cont &&
                  p_grp_nodes[nd]->intpt.sibling.cvid != PW_K_NullObjid &&
                  (lpid = pwGetLpOfEd (p_grp_nodes[nd]->intpt.sibling.cvid, os))
                  == p_lpids[lp])
              {
                best_lpid = p_lpids[lp];
                break;
              }
            }
            if (best_lpid != PW_K_NullObjid)
              break;
          }

          if (!n_lps)
            best_lpid = PW_K_NullObjid;
          else if (n_lps == 1)
            best_lpid = p_lpids[0];

          found = FALSE;

          for (ind=(best_lpid == PW_K_NullObjid) ? 1 : 0; ind<2 && !found; 
               ind++)
          {
            for (nd=(inx == LEFT) ? 0 : n_grp_nodes-1; 
                 ((inx == LEFT) ? (nd < n_grp_nodes) : (nd > 0)); 
                 (inx == LEFT) ? (nd++) : (nd--))
            {
              if (pwGetContainCvintpt (&p_grp_nodes[nd]->intpt, inx) == 
                  reg_cont &&
                  (ind == 1) ? TRUE : 
                  (p_grp_nodes[nd]->intpt.sibling.cvid != PW_K_NullObjid &&
                   (pwGetLpOfEd (p_grp_nodes[nd]->intpt.sibling.cvid, os) == 
                   best_lpid)))
              {
                if (inx == LEFT && nd != 0) 
                {
                  SwapIntPts (p_grp_nodes[0], p_grp_nodes[nd], intpt);
                }
                else if (inx == RIGHT && nd != (n_grp_nodes - 1))
                { 
                  SwapIntPts (p_grp_nodes[n_grp_nodes-1], p_grp_nodes[nd], 
                              intpt);
                }
                found = TRUE;
                break;
              }
            }
          }

          if (inx == LEFT)
            lf_lpid = best_lpid;
          else
            rt_lpid = best_lpid;
        }
      }

      /*
       * also get the loop ids from the attributes, if there is any.
       */
      if (lf_lpid == PW_K_NullObjid) 
      {
        if (p_grp_nodes[0]->p_prev && 
            p_grp_nodes[0]->p_prev->intpt.sibling.cvid != PW_K_NullObjid)
        {
          lf_lpid = pwGetLpOfEd (p_grp_nodes[0]->p_prev->intpt.sibling.cvid, 
                                 os);
        }
        else if (!pwGetIntAttrib (p_grp_nodes[0]->p_attrib,
                      PW_AttribIdent (PW_K_Trimming, PW_K_LoopIdAttr, LEFT),
                      (int *) &lf_lpid))
        {
          lf_lpid = PW_K_NullObjid;
        }
      }

      if (rt_lpid == PW_K_NullObjid)
      {
        if (p_grp_nodes[n_grp_nodes-1]->p_next &&
            p_grp_nodes[n_grp_nodes-1]->p_next->intpt.sibling.cvid != 
            PW_K_NullObjid)
        {
          rt_lpid = pwGetLpOfEd (p_grp_nodes[n_grp_nodes-1]->p_next->intpt.
                                 sibling.cvid, os);
        }
        else if (!pwGetIntAttrib (p_grp_nodes[n_grp_nodes-1]->p_attrib,
                      PW_AttribIdent (PW_K_Trimming, PW_K_LoopIdAttr, LEFT),
                      (int *) &rt_lpid))
        {
          rt_lpid = PW_K_NullObjid;
        }
      }

      /*
       * Best Sequencing Of Internal Nodes
       */
      for (nd1 = 0; nd1 < n_grp_nodes - 3; nd1 ++)
      {
        int_cont = pwGetContainCvintpt (&p_grp_nodes[nd1]->intpt, RIGHT);

        for (nd2 = nd1+1; (int_cont != PWcontain_unknown && 
                           nd2 < n_grp_nodes -1); nd2++)
        {
          if (pwGetContainCvintpt (&p_grp_nodes[nd2]->intpt, LEFT) == int_cont)
          {
            if (nd2 != nd1+1)
              SwapIntPts (p_grp_nodes[nd1+1], p_grp_nodes[nd2], intpt);
            break;
          }
        } 
      } 

      /*
       * Wild Card Treatment :
       * 
       *    Dis-ambiguate the "?" rels of the nodes in this group by looking
       * at the Containment Bits of the adjacent nodes. For first node don't
       * check the left containment bit and for the last node don't check the
       * right containment bit. Once the rel is dis-ambiguated, classify the 
       * enclosing region between the node and the adjacent node.
       */ 
      for (nd=0; nd < n_grp_nodes; nd++)
      {
        /*
         * The group consists of more than one node.  
         */
        for (pos=LEFT, reg=PREV; pos <= RIGHT; pos++, reg++)
        {
          /*
           * If it is first node, so don't check for the LEFT containment. 
           */
          if (nd == 0 && pos == LEFT)
            continue;

          /*
           * If it is last node, so don't check for the RIGHT containment. 
           */
          if (nd == n_grp_nodes-1 && pos == RIGHT)
            continue;

          if (pwGetContainCvintpt (&p_grp_nodes[nd]->intpt, pos) == 
                                                     PWcontain_unknown)
          {
            /*
             * if checking for left containment, 
             * then 
             *   get the right containment of the previous node and dis-ambig- 
             *   uate the left rel of this node with this rel and also classify
             *   the previous region.
             * else
             *   get the left containment of the next node and dis-ambiguate 
             *   the right rel of this node with this rel and also classify 
             *   the next region. 
             */ 
            if (pos == LEFT)
            {
              reg_cont = pwGetContainCvintpt (&p_grp_nodes[nd-1]->intpt, RIGHT);
            }
            else
            {
              reg_cont = pwGetContainCvintpt (&p_grp_nodes[nd+1]->intpt, LEFT);
            }
 
            if (reg_cont != PWcontain_unknown)
            { 
              pwSetContainCvintpt (&p_grp_nodes[nd]->intpt, pos, reg_cont);
              pwSetContainCvintptList (p_grp_nodes[nd], reg, reg_cont);
              if (pos == LEFT)
              {
                pwSetContainCvintptList (p_grp_nodes[nd-1], NEXT, reg_cont);
              }
              else
              {
                pwSetContainCvintptList (p_grp_nodes[nd+1], PREV, reg_cont);
              }
            }
          }
        }
      }

      /*
       * Step #2 : Delete all the nodes with IN/IN, OUT/OUT or ON/ON 
       *           classification. 
       *           a) At this stage, just find out what are all the nodes
       *              to be deleted. Make new group by deleting the dele-
       *              table node's address from the group's array.
       *           b) Actual deletion takes place at the end of the loop
       *              i.e. ArrrangeInfo.
       */
      new_nd = 0;
     
      reg_cont = pwGetContainCvintptList (p_grp_nodes[0], LEFT); 
      p_grp_nodes[new_nd] = p_grp_nodes[0];
      new_nd ++;
      for (nd=1; nd<n_grp_nodes; nd++)
      {
        if (pwGetContainCvintptList (p_grp_nodes[nd], LEFT) != reg_cont)
        {
          reg_cont = pwGetContainCvintptList (p_grp_nodes[nd], LEFT);
          p_grp_nodes[new_nd] = p_grp_nodes[nd];
          new_nd ++;
        }
      }
   
      n_grp_nodes = new_nd;

      new_nd = n_grp_nodes-1;
      reg_cont = pwGetContainCvintptList (p_grp_nodes[n_grp_nodes-1], RIGHT);
      p_grp_nodes[new_nd] = p_grp_nodes[n_grp_nodes-1];
      new_nd --;
      for (nd=n_grp_nodes-2; nd>=0; nd--)
      {
        if (pwGetContainCvintptList (p_grp_nodes[nd], RIGHT) != reg_cont)
        {
          reg_cont = pwGetContainCvintptList (p_grp_nodes[nd], RIGHT);
          p_grp_nodes[new_nd] = p_grp_nodes[nd];
          new_nd --;
        }
      }

      for (nd=new_nd+1, nd1=0; nd<n_grp_nodes; nd++, nd1++)
        p_grp_nodes [nd1] = p_grp_nodes[nd]; 
      new_nd = nd1;
      
      n_grp_nodes = new_nd;

      /*
       * Step #3 : If all the nodes got removed in the previous step, 
       *           introduce a splitter node with the rels consistent
       *           with adjacent regions and continue to the next set.
       */
      if (!n_grp_nodes)
      {
        p_splitter_node = (struct PWcvintpt_list *) pwCreateCvintptList (NULL);

        /*
         * set the region classification
         */
        pwSetContainCvintptList (p_splitter_node, PREV, prev_reg_cont); 
        pwSetContainCvintptList (p_splitter_node, NEXT, next_reg_cont); 

        /*
         * set the intpt classification
         */
        pwSetContainCvintpt (&p_splitter_node->intpt, LEFT, prev_reg_cont); 
        pwSetContainCvintpt (&p_splitter_node->intpt, RIGHT, next_reg_cont); 

        /*
         * set the topopos bit
         */
        pwSetTopoposCvpt (&p_splitter_node->intpt.cvpt, PWtopopos_middle); 

        p_splitter_node->intpt.cvpt.cvid = PW_K_NullObjid;
        p_splitter_node->intpt.sibling.cvid = PW_K_NullObjid;

        memcpy (p_splitter_node->intpt.cvpt.pt, p_grp_nodes[0]->intpt.cvpt.pt,
                3 * sizeof (double));
        memcpy (&p_splitter_node->intpt.cvpt.cvparam, 
                &p_grp_nodes[0]->intpt.cvpt.cvparam, sizeof (struct PWcvparam));
        p_splitter_node->intpt.cvpt.cvid = PW_K_NullObjid;
        p_splitter_node->intpt.sibling.cvid = PW_K_NullObjid;

        goto ArrangeInfo;
      }

      /* 
       * Step #4 : Remaining offending nodes needs to be arranged properly.
       *           They can be arranged by one/a sequence of the following
       *           steps :
       *           a) Rearrange the nodes such that, they toggle with the
       *              region classification.
       *           b) If there are more than one candidate for the same slot
       *              the ambiguity can be resolved by loop-connectivity.
       *           c) If there is loop info. to resolve the ambiguity then
       *              the ambiguity can be resolved by angle sort.
       */
      for (reg=0; reg<n_grp_nodes-1; reg++)
      {
        prev_reg_cont = pwGetContainCvintptList (p_grp_nodes[reg], PREV);
        next_reg_cont = pwGetContainCvintptList (p_grp_nodes[reg], NEXT);

        for (nd=reg; nd<n_grp_nodes; nd++)
        {
          if ((prev_reg_cont == pwGetContainCvintpt (&p_grp_nodes[nd]->intpt,
                                                    LEFT)) &&
              (next_reg_cont == pwGetContainCvintpt (&p_grp_nodes[nd]->intpt,
                                                    RIGHT)) )
          {
            if (nd != reg)
            {
              /*
               * swap the nodes by swapping the intersection point info.
               */
              SwapIntPts (p_grp_nodes[reg], p_grp_nodes[nd], intpt);
            }
            break;
          }
        }
      }

      /*
       * Check, whether this group of nodes, consists of nodes with the same
       * classification. If so, these need to be rearranged by either loop 
       * classification / angle sort criterion.  
       */
      /* LOOP CLASSIFICATION */

      for (reg=0; n_grp_nodes >=2 && reg < n_grp_nodes ; 
                                                  reg += (n_grp_nodes - 1))
      {
        lpid = reg ? rt_lpid : lf_lpid;
 
        lf_intpt_cont = pwGetContainCvintpt (&p_grp_nodes[reg]->intpt, LEFT);
        rt_intpt_cont = pwGetContainCvintpt (&p_grp_nodes[reg]->intpt, RIGHT);

        cont_indx[n_cont_nodes] = reg;
        n_cont_nodes = 1;

        nd = reg ? reg - 1 : reg + 1;

        for (; reg ? nd >= 0 : nd < n_grp_nodes ; reg ? nd-- : nd++)
        {
          if ((lf_intpt_cont == pwGetContainCvintpt (&p_grp_nodes[nd]->intpt,
                                                    LEFT)) && 
              (rt_intpt_cont == pwGetContainCvintpt (&p_grp_nodes[nd]->intpt,
                                                    RIGHT)))
          {
            cont_indx[n_cont_nodes] = nd;
            n_cont_nodes ++;
          }
        } 

        /*
         * If the number of contending nodes is gretaer than one, select the
         * one, which is from the loop 'lpid'.
         * ASSUMPTION : 
         *    The assumption in the following block being, deffinitely not 
         *    more than one from the same loop will be contending for the 
         *    same position. (Means, two nodes from the same loop contending
         *    for the same position). Which is a KIND OF IMPOSSIBLE. If at
         *    all this case occurs, we need to ERROR OUT.
         */
        if (n_cont_nodes > 1)
        {
          int n_nodes = 0;

          for(nd = 0; nd < n_cont_nodes; nd++)
          {
            if (pwGetLpOfEd (p_grp_nodes[cont_indx[nd]]->intpt.sibling.cvid, 
                             os) == lpid) 
            {
              n_nodes ++;
              if (n_nodes > 1)
                break;
              if (cont_indx[nd] != reg)
                SwapIntPts (p_grp_nodes[cont_indx[nd]], p_grp_nodes[reg], 
                            intpt);
            }
          }

          OnErrorState (n_nodes > 1, PWsts, SetError (PW_K_Trimming, 
                        PW_K_InvalidArg), wrapup);
        }

        /* ANGLE SORT */

        if (n_cont_nodes > 2)
        {
          struct PWcvintpt_list **p_sort_nodes=NULL;

          p_sort_nodes = (struct PWcvintpt_list **) alloca((n_cont_nodes - 1) *
                                             sizeof(struct PWcvintpt_list *)); 
          for (nd=1; nd<n_cont_nodes; nd++)
            p_sort_nodes[nd-1] = p_grp_nodes[cont_indx[nd]]; 

          PWsts = RearrangeGroupByAngleSort (n_cont_nodes - 1, p_sort_nodes, os, 
                                    p_cvdata);
          OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming,
                        PW_K_Internal), wrapup);

          for (nd=1; nd<n_cont_nodes; nd++)
            p_grp_nodes[cont_indx[nd]] = p_sort_nodes[nd-1];
        }
      }

    ArrangeInfo : 

      /*
       * Now go through the original group nodes, and if it is not there in the 
       * modified group nodes list, then delete it.
       */
      for (ind=0; ind<n_igrp_nodes; ind++)
      {
        p_node = p_igrp_nodes[ind];
        found = FALSE;
        for (nd=0; nd<n_grp_nodes; nd++)
        {
          if (p_node == p_grp_nodes[nd])
          {
            found = TRUE;
            break;
          }
        }

        if (!found)
        {
          pwRemoveCvintptList (p_cvintpts, p_node);
          pwFreeCvintptList (p_node);
        }
        else
        {
          pwUnsetArbSeqCvintptList (p_node); 
        }
      }

      /*
       * Now that we have rearranged the group containing offending nodes, 
       * we should set the containment properties of the region bounded by 
       * the coincident nodes.
       */

      p_node = p_grp_nodes[0];
      for (nd = 0; nd < n_grp_nodes-1; nd++)
      {
        rt_intpt_cont = pwGetContainCvintpt (&p_node->intpt, RIGHT);
        lf_intpt_cont = pwGetContainCvintpt (&p_node->p_next->intpt, LEFT);
        if (rt_intpt_cont == lf_intpt_cont)
        {
          reg_cont = rt_intpt_cont;
          pwSetContainCvintptList (p_node, NEXT, reg_cont);
          pwSetContainCvintptList (p_node->p_next, PREV, reg_cont);
        }
        else
        {
          OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_Internal), 
                        wrapup);
        }

        p_node = p_node->p_next;
      }

      p_node = p_next_node;
    }
    else
      p_node = p_node->p_next;
  }

wrapup :

  PW_Wrapup (PWsts, "ProcessOffendingNodes");
  return PWsts;  
}

/*
  DESCRIPTION

     Given two coincident intersection nodes contending for the same position, 
     it resolves the ambiguity by giving preference to the node whose incident
     edges immediately enclose the intersection curve. The node that contains
     the edge incident information relating to this pair will be positioned 
     last among the contesting nodes.

  NOTES
    
     None.
*/

static PWresult RearrangeGroupByAngleSort
(
  int                   n_nodes,
  struct PWcvintpt_list **p_cvintpts, 
  PWosnum               os,
  struct PWcvdata       *p_cvdata
)
{
  /* status stuff */
  PWresult   PWsts=PW_K_Success;

  /* loop variables */
  int nd;

  /* edge objects and geometry */
  PWobjid              edge=PW_K_NullObjid;
  struct PWcvdata      *p_eddata=NULL;
  struct PWcvparam     *p_edpar=NULL;
  PWboolean            *p_edrev=FALSE;

  /* Vectors for sorting */
  PWvector2d  sort_vecs[3];  
  int         sort_ind[3];
  PWvector    tmpvec;

  /* Temporary node */
  struct PWcvintpt_list *p_node=NULL;

  /* 
   * If there more than two nodes contending for the same position, this 
   * situation can not be handled as of TODAY Phase #1. So error out.
   */
  OnErrorState (n_nodes > 2, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                wrapup);

  /*
   * get the intersection curve forward tangent
   */
  PWsts = pwGetTangentCvdata (p_cvdata, &p_node->intpt.cvpt.cvparam, FALSE, 
                              tmpvec); 
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  sort_vecs[0][0] = tmpvec[0];
  sort_vecs[0][1] = tmpvec[1];
  
  p_node = *p_cvintpts;

  p_eddata = (struct PWcvdata *) alloca (n_nodes * sizeof(struct PWcvdata));
  p_edpar  = (struct PWcvparam *) alloca (n_nodes * sizeof(struct PWcvparam));
  p_edrev  = (PWboolean *) alloca (n_nodes * sizeof(PWboolean));

  for (nd=0; nd<n_nodes; nd++)
  { 
    p_node = p_cvintpts[nd];
    edge = p_node->intpt.sibling.cvid;
    p_edpar[nd] = p_node->intpt.sibling.cvparam;

    /*
     * get the edge geometry and evaluate the forward and backward tangents
     * the intersection parameter. If the intersection happened to be at the
     * ends, then get the next edge and use the tangent of the next edge as
     * the forward tangent of this edge.
     */

    PWsts = PW_GetNatEdGeomStack (edge, os, (p_eddata[nd]));
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

    p_edrev[nd] = pwIsEdRev (edge, os);

    PWsts = pwGetTangentCvdata (&p_eddata[nd], &p_edpar[nd], p_edrev[nd],
                                tmpvec);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

    sort_vecs[nd+1][0] = tmpvec[0]; sort_vecs[nd+1][1] = tmpvec[1];
  }

  /*
   * Now, Sort the vectors
   */
  PWsts = pwSortVec2d (nd, sort_vecs, sort_ind);  
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  if (GetCode (PWsts) == PW_K_Ambiguous)
  {
    double    radius[2];
    PWvector  cen_vec[2];

    /*
     * get the radius of curvatures of the two edges
     */
    PWsts = pwGetRadCenCurvCvdata (&p_eddata[0], &p_edpar[0], p_edrev[0],
                                   &radius[0], &cen_vec[0][0]);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

    PWsts = pwGetRadCenCurvCvdata (&p_eddata[1], &p_edpar[1], p_edrev[1],
                                   &radius[1], &cen_vec[1][0]);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

    if (radius[0] == MAXDOUBLE && radius[1] == MAXDOUBLE)
      OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_Internal), 
                    wrapup);

    if (radius[0] > radius[1])
      sort_ind[1] = 2;
    else
      sort_ind[1] = 1;
  }

  /*
   * Rearrange the nodes 
   */
  if (sort_ind[1] == 2)
  {
    p_node = p_cvintpts[0];
    p_cvintpts[0] = p_cvintpts[1];
    p_cvintpts[1] = p_node;
  }

wrapup :
  PW_Wrapup (PWsts, "RearrangeGroupByAngleSort");
  return PWsts;
}


/*
  DESCRIPTION

     Given the curve data, a flag indicating whether the geometry is reversed
     and the curve parameter, it evaluates the radius of  curvature  and  the 
     vector denoting the center of curvature.

  NOTES

     All the memory for the output must be allocated by the caller.
*/  

PWresult pwGetRadCenCurvCvdata
(
  struct PWcvdata   *p_cvdata,
  struct PWcvparam  *p_par, 
  PWboolean         reverse,
  double            *radius,
  double            *cen_vec
)
{
  PWresult  PWsts=PW_K_Success;
  PWvector  tan_vec;
  BSrc      BSmsg=BSSUCC;

  *radius = MAXDOUBLE;  

  switch (p_cvdata->datatype)
  {
    case PWcvdata_bspcv : 
    case PWcvdata_gmbspcv :
    {
      struct IGRbsp_curve *p_cv=NULL;
      double       kurv; 
      PWpoint      points[2];

      p_cv = (p_cvdata->datatype == PWcvdata_bspcv) ? p_cvdata->data.p_bspcv :
                                              p_cvdata->data.p_gmbspcv->bspcv;

      if (p_cv->order > 2)
      {
        BScvarrevc (p_cv, (int) 1, &p_par->spanpar, MAXDOUBLE, &kurv, radius,
                    &points, &BSmsg);
        OnErrorState (BSERROR(BSmsg), PWsts, 
                      SetError (PW_K_BspMath, PW_K_Internal), wrapup);

        pwMakeVec (points[0], points[1], cen_vec);
        pwNormVec (cen_vec, cen_vec);
      }
      else
      {

        pwGetTangentCv (p_cv, p_par->spanpar, reverse, tan_vec); 
        OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);
    
        pwNormVec (tan_vec, tan_vec);

        BSorthovec (&BSmsg, tan_vec, cen_vec);
        OnErrorState (BSERROR(BSmsg), PWsts, 
                      SetError (PW_K_BspMath, PW_K_Internal), wrapup);

        *radius = MAXDOUBLE;
      }
    }
    break;

    case PWcvdata_py2d :
    {
      PWvector  loc_cen_vec;

      pwGetTangentPy2d (&p_cvdata->data.py2d, p_par->spaninx, reverse, tan_vec);
      OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);
   
      tan_vec[Z] = 0.0; 
      pwNormVec (tan_vec, tan_vec);

      BSorthovec (&BSmsg, tan_vec, loc_cen_vec);
      OnErrorState (BSERROR(BSmsg), PWsts, 
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);

      cen_vec[X] = loc_cen_vec[X]; 
      cen_vec[Y] = loc_cen_vec[Y]; 

      *radius = MAXDOUBLE;
    }
    break;

    case PWcvdata_py :
    {
      pwGetTangentPy (&p_cvdata->data.py, p_par->spaninx, reverse, tan_vec);
      OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);

      pwNormVec (tan_vec, tan_vec);

      BSorthovec (&BSmsg, tan_vec, cen_vec);
      OnErrorState (BSERROR(BSmsg), PWsts,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);
      *radius = MAXDOUBLE;
    }
    break;

    default :
      OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                    wrapup);
  } 

wrapup :

  PW_Wrapup (PWsts, "pwGetRadCenCurvCvdata"); 
  return PWsts;
}
