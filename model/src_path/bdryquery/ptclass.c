#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include <memory.h>
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "OMminimum.h"

#include "igrtypedef.h"
#include "igr.h"
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"

#include "PWapi/edintpts.h"
#include "PWapi/partol.h"
#include "PWapi/lpint.h"
#include "PWapi/sortgmint.h"
#include "PWapi/rngbx.h"
#include "PWapi/normvec.h"
#include "PWapi/mkvec.h"

#include "PWapi/ptlocmac.h"
#include "PWapi/lped.h"
#include "PWapi/edgeom.h"
#include "PWapi/xyztol.h"

#include "ptclass.h"

#define MAX_RAYS 10 

static void ExtendRayByTol
(
   PWpoint2d  uvpt,
   PWpoint2d  intuvpt,
   double     uvtol
);

static PWresult GetPointLocation
(
  PWpoint2d         uvpt,
  struct PWsfdata   *p_sfdata,
  struct PWid       *p_lpid,
  int               numpts,
  int               numedges,
  PWobjid           *p_lpedges,
  double            xyztol,
  int               maxallowable_rays,
  enum PWptloctype  *p_ptloc,
  PWobjid           *p_edid,
  struct PWcvpt     *p_edpt
);

static PWboolean BadFlow 
(
  struct PWcvintpt_list *p_cvintpt_list
);

/*
 *   Application function : pwLpPtClassify
 *   -------------------------------------
 *   Description
 *   -----------
 *   This API performs the actual task of classifying a point as
 *   INHOLE or INAREA with respect to a loop. The principle is
 *   based on Ray-firing technique, and getting the classification
 *   of the first (sorted) intersection of the ray with the loop. 
 *   Trivial classification of ONEDGE and ONVERTEX conditions would have
 *   been done by call to another API.
 *
 *   Input
 *   -----
 *   Struct Pid   *p_lpid;
 *
 *   Ppoint2d     uvpt;        * UV point if XYZ point not available *
 *
 *   double       xyztol;      * XYZ tolerance with which ptloc is to be
 *                                tested *
 *
 *   Output
 *   ------
 *   struct Pid *p_bdryid;   * Bdry id if on egde/vertex else PW_NULL_OBJID *
 *
 *   enum PW_PTLOC  ptloc;
 *
 */

/*  Calling LpPtClassify with same arguments. This is done to 
 *  retain older pwLpPtClassify function.    --V.Srinivas
 */ 

PWresult   pwLpPtClassify
( 
  struct PWid             *p_lpid,
  PWpoint2d               uvpt,
  double                  xyztol,
  struct PWsfdata         *p_sfdata,
  enum PWptloctype        *p_ptloc,
  PWobjid                 *p_edid,
  struct PWcvpt           *p_edpt
)
{
  PWresult                retval;

   retval = PW_K_Success;
   retval = LpPtClassify(p_lpid,uvpt,xyztol,p_sfdata,p_ptloc,p_edid,p_edpt);
   return(retval); 
}

 
PWresult   LpPtClassify
( 
  struct PWid             *p_lpid,
  PWpoint2d               uvpt,
  double                  xyztol,
  struct PWsfdata         *p_sfdata,
  enum PWptloctype        *p_ptloc,
  PWobjid                 *p_edid,
  struct PWcvpt           *p_edpt
)
{
  PWresult                retval;
  int                     i, numedges=0, maxallowable_rays=0, 
                          numpts=0, numbsedges=0, numleedges=0;
  PWobjid                 *p_lpedges=NULL, *p_bsedges=NULL, *p_leedges=NULL;
  enum PWcvdatatype       edtype=PWcvdata_null;
  /*
   * Initialization
   */
  retval = PW_K_Success;
  *p_ptloc = PWptloc_unknown;
  *p_edid  = PW_K_NullObjid;
  edtype = PWcvdata_null;
  p_edpt->p_attrib = NULL;

  
  /*
   * Call point locate with a finer tolerance, factored down by
   * bastol / chttol. Tolerance being used to discriminate, it needs
   * to be finer.
   */
  xyztol = xyztol * (pwActiveXYZLenTol() / pwActiveXYZChtTol());

  if (p_sfdata->datatype == PWsfdata_plane)
  OnErrorState (TRUE, retval, SetError (PW_K_PtLocation, PW_K_InvalidArg),
                 wrapup); 

  /* Get all the edges of the loop
   */
  numedges = pwNumEdsOfLp (p_lpid->objid, p_lpid->osnum);

  /* Allocate space for p_lpedges, p_bsedges, p_leedges
   */
  p_lpedges = (PWobjid *)alloca (numedges*sizeof(PWobjid));
  OnErrorState (!p_lpedges, retval, SetError (0, PW_K_DynamicMemory),
                wrapup);

  p_bsedges = (PWobjid *)alloca (numedges*sizeof(PWobjid));
  OnErrorState (!p_bsedges, retval, SetError (0, PW_K_DynamicMemory),
                wrapup);

  p_leedges = (PWobjid *)alloca (numedges*sizeof(PWobjid));
  OnErrorState (!p_leedges, retval, SetError (0, PW_K_DynamicMemory),
                wrapup);

  /*
   *  Get the edgeids of loop
   */
  pwEdsOfLp (p_lpid->objid, p_lpid->osnum, p_lpedges);

  /*
   * Seperate the obtained edges into two categories BS-edges and non-BS
   * edges. Then try constructing the ray with the non-BS edges because
   * that should give a better result. Otherwise try with BS-edges
   */
  for (i=0; i< numedges; i++)
  {
    edtype = pwGetEdGeomType (p_lpedges[i], p_lpid->osnum);
 
    if ((edtype == PWcvdata_bspcv) || (edtype == PWcvdata_gmbspcv))
    {
      p_bsedges[numbsedges] = p_lpedges[i];
      numbsedges++;
    }
    else
    {
      p_leedges[numleedges] = p_lpedges[i];
      numleedges++;
    }
  } 
  if (numedges < 5)
    numpts = 2;
  else
    numpts = 1;
  if (numedges*numpts < MAX_RAYS)
    maxallowable_rays = numedges*numpts;
  else
    maxallowable_rays = MAX_RAYS;

  /*
   * Get the output by calling a static function 
   */
  if (numleedges)
  {
    retval = GetPointLocation (uvpt, p_sfdata, p_lpid, numpts,
                               numleedges, p_leedges, xyztol, 
                               maxallowable_rays,
                               p_ptloc, p_edid, p_edpt);
    OnErrorCode (retval, wrapup);
  }
  if (numbsedges && *p_ptloc != PWptloc_inarea && *p_ptloc != PWptloc_inhole)
  {
    maxallowable_rays = maxallowable_rays - numpts*numleedges;
    retval = GetPointLocation (uvpt, p_sfdata, p_lpid, numpts, 
                               numbsedges, p_bsedges, xyztol, 
                               maxallowable_rays, 
                               p_ptloc, p_edid, p_edpt);
    OnErrorCode (retval, wrapup);
  } 

  wrapup:
  PW_Wrapup (retval, "Function: pwLpPtClassify(). ");
  return retval;  
}/* end of function pwLpPtClassify */



static PWresult GetPointLocation
(
  PWpoint2d         uvpt,
  struct PWsfdata   *p_sfdata,
  struct PWid       *p_lpid,
  int               numpts,
  int               numedges,
  PWobjid           *p_lpedges,
  double            xyztol,
  int               maxallowable_rays,
  enum PWptloctype  *p_ptloc,
  PWobjid           *p_edid,
  struct PWcvpt     *p_edpt
)
{
  PWresult                retval=PW_K_Success;
  int                     i=0, count=0, maxpossible_rays=0;
  struct PWid             loc_Edid;
  PWpoint2d               raypt[2], intuvpt[2];
  PWboolean               good_location_found=FALSE, on_bdry_found=FALSE;
  struct PWcvdata         raycvdata;
  struct PWcvintpt_list   *p_intlist=NULL;
  double                  uvtol=0;
  struct IGRbsp_surface   *p_sfgeom=NULL;
  enum  PWcontaintype     conttyp;
  enum  PWtopopostype     topotyp;          
  PWrange2d               rayrng;
  int                     ray_count=0;


  /*
   * Initialization
   */

  *p_ptloc = PWptloc_unknown;

  loc_Edid.objid = PW_K_NullObjid;
  loc_Edid.osnum = p_lpid->osnum;
  memset (&raycvdata, 0, sizeof (struct PWcvdata));
  p_sfgeom = p_sfdata->datatype == PWsfdata_bspsf ? p_sfdata->data.p_bspsf :
                                             p_sfdata->data.p_gmbspsf->bspsf;
  uvtol = pwGetParTolSf (p_sfgeom, xyztol);

  /*
   * Intersect an edge in the array of edges with the constructed ray. The
   * intersections are sorted along the ray direction. The point's
   * classification is then inferred from the 'containment' information of the
   * first point in the sorted list, provided there are no ambiguities 
   * surrounding the point. The different ambiguous situations are described
   * below. 
   *
   * On finding an ambiguous situation, arising out of intersection with a 
   * specific edge in the array, move on to the next internal point; exhausting
   * all internal points on this edge, move on to the next edge. With each
   * 'moving on' we are regenerating the ray and trying to obtain a 
   * classification. If the limit for total number of rays is reached or we are
   * out of edges and internal points, then this function fails to return
   * a classification.
   *
   * Note: It is recommended that the possibility of the point-to-be-
   * classified lying on a vertex or an edge be elliminated BEFORE calling
   * this function. Though the algorithm coded below will try to handle this
   * as non-ambiguous, the reliability in this situation will not be very
   * good. If such a situation is found, the algorithm searches all other 
   * possibilities first (all other possible rays first). On finding that this
   * is the only unambiguous possibility, returns the ON-edge or ON-vertex
   * classification.
   *
   * An ambiguos result is said to exist if any of the following conditions
   * occur:
   *
   * 1) the first point in the sorted intersection point list is coincident
   * with a subsequent point (if it exists) in the list and it's containment
   * does not 'flow' consistently. That is, the sequence among the two nodes
   * is arbitrary, the condition is ambiguos.
   *
   * 2) the first point is not coincident with a subsequent point, but the
   * subsequent point's (if it exists) containment does not 'flow' 
   * consistently. This may be a stringent requirement as the problem may be
   * with the second point and the classification could have been correctly
   * inferred from the first point's containment. So, in case this is the
   * last ray that can be constructed, we will let the classification proceed
   * based on the first point. This is done with the motive to try hard not
   * to fail.
   *
   * 3) the first point's left containment is not one of IN, OUT 
   * or ON.
   */

  raycvdata.datatype = PWcvdata_py2d;
  raycvdata.data.py2d.num_pts = 2;
  maxpossible_rays = numedges * numpts;
  for (i=0; i<numedges; i++)
  {
    loc_Edid.objid = p_lpedges[i];
    retval = pwEdInternalPts (p_lpedges[i], p_lpid->osnum, numpts, intuvpt);
    OnErrorCode (retval, wrapup);
   
    for (count=0; count<numpts; count++)
    {
      /* 
       * Construct a ray with the input point and the internal point
       * obtained in the previous step. The internal point is made the second
       * point of the ray. Note: Extend the ray by uvtol to get a clear
       * intersection.
       */

      ExtendRayByTol (uvpt, intuvpt[count], uvtol);
      memcpy (raypt[0], uvpt, 2*sizeof(double));
      memcpy (raypt[1], intuvpt[count], 2*sizeof(double));

      raycvdata.data.py2d.p_pts = raypt;
      pwGetRange2d (2, raypt, rayrng);

      ray_count++;

      /* 
       * Intersect the ray with input loop
       */

      if (p_intlist)
      {
        pwFreeCvintptList (p_intlist);
        p_intlist=NULL;
      }
      retval = pwIntersectWithLoop (p_lpid, &raycvdata, NULL, rayrng,
                                    p_sfdata, xyztol, &p_intlist);
      OnErrorCode (retval, wrapup);

      if (!p_intlist)
      {
        continue;
      }

      /* Sort the intpt list 
       */
      retval = pwSortCvintptList (&p_intlist, uvtol);
      OnErrorCode (retval, wrapup);

      /*
       * Initialize check variable.
       */

      good_location_found = FALSE;

      /* 
       * Check whether the first node in intlist is a part of ArbSeq. If not,
       * skip this ray.
       */

      if (!(pwIsArbSeqCvintptList (p_intlist)))
      {
        /*
         * If more rays can be constructed, check if the first node and the
         * second node have their containments 'flowing' smoothly. If not,
         * skip this ray.
         */

        if (ray_count == maxallowable_rays ||
            ray_count == maxpossible_rays ||
            !BadFlow (p_intlist))
        {
          conttyp = pwGetContainCvintpt (&(p_intlist->intpt), LEFT);

          if (conttyp == PWcontain_in)
          {
            good_location_found = TRUE;
            *p_ptloc = PWptloc_inarea;
          }

          else if (conttyp == PWcontain_out)
          {
            good_location_found = TRUE;
            *p_ptloc = PWptloc_inhole;
          }

          else if (conttyp == PWcontain_on && 
                   pwGetTopoposCvpt(&p_intlist->intpt.cvpt) == PWtopopos_start)
          {
            on_bdry_found = TRUE;

            topotyp = pwGetTopoposCvpt (&(p_intlist->intpt.sibling));
            if (topotyp == PWtopopos_start)
            {
              *p_ptloc = PWptloc_onstartvtx;
              pwSetTopoposCvpt (p_edpt, PWtopopos_start);
            }
            else if (topotyp == PWtopopos_stop)
            {
              *p_ptloc = PWptloc_onstopvtx;
              pwSetTopoposCvpt (p_edpt, PWtopopos_stop);
            }
            else
            {
              *p_ptloc = PWptloc_onedge;
              pwSetTopoposCvpt (p_edpt, PWtopopos_middle);
            }
 
            p_edpt->cvparam = p_intlist->intpt.sibling.cvparam;
            memcpy (p_edpt, p_intlist->intpt.sibling.pt, 2*sizeof(double));
            *p_edid = p_intlist->intpt.sibling.cvid;

          } /* if ON Containment */
        } /* if not bad flow */
      } /* if not arbitrary sequence */

      if (good_location_found) 
        break; 

    }/* for-loop over number of points per edge selected */
 
    if (good_location_found) 
      break; 

    if (ray_count >= maxallowable_rays) 
      break;

  }/* for-loop over number of edges */

  /*
   * In case the location found is on boundary and not one that is clearly
   * off the boundary, return an appropriate information code.
   */

  if (!good_location_found && on_bdry_found)
    retval = SetInfo (PW_K_PtLocation, PW_K_Bounds);
  
wrapup:
  if (p_intlist)
    pwFreeCvintptList (p_intlist);
  PW_Wrapup (retval, "GetPointLocation");
  return retval;
}
            

static void ExtendRayByTol
( 
   PWpoint2d  uvpt, 
   PWpoint2d  intuvpt, 
   double     uvtol 
)
{
   PWvector2d    vec, nvec;

   pwMakeVec2d( uvpt, intuvpt, vec );
   pwNormVec2d( vec, nvec );
  
   intuvpt[0] = intuvpt[0] + nvec[0]*2*uvtol;
   intuvpt[1] = intuvpt[1] + nvec[1]*2*uvtol;

   if( intuvpt[0] > 1.0 )
      intuvpt[0] = 1.0;
   else if( intuvpt[0] < 0.0 )
      intuvpt[0] = 0.0;

   if( intuvpt[1] > 1.0 )
      intuvpt[1] = 1.0;
   else if( intuvpt[0] < 0.0 )
      intuvpt[1] = 0.0;

   return;
}


static PWboolean BadFlow 
(
  struct PWcvintpt_list *p_intlist
)
{
  while (p_intlist->p_next)
  {
    if (pwGetContainCvintpt (&p_intlist->intpt, RIGHT) != 
        pwGetContainCvintpt (&p_intlist->p_next->intpt, LEFT))
      return (TRUE);

    p_intlist = p_intlist->p_next;
  }

  return (FALSE);
}
