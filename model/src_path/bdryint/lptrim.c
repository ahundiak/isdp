/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT

      It trims a UV curve on a surface (typically  an  intersection curve as 
      a result of the intersection with another surface) with respect to the 
      loop boundaries and returns the trimmed intersections falling in AREA/ 
      on BOUNDARIES of the loop.

  DESCRIPTION

      This function is used to determine the regions of the UV curve (in the
      UV-space of the surface) those  fall in area or on boundarie(s) of the
      face. The UV curve is typically, an intersection curve in the UV-space 
      of the surface as interacts with another. The face is made of topolog-
      ical elements such as Loops and Edges.

      A significant output is the containment classification of these regio-
      ns. The classification could be IN or ON. IN refers  to  inside  area,
      and ON refers to on the boundary. All the regions which are out of the
      area or not on boundaries will be automatically  thrown  away by  this
      function.

      This function optionally takes in the XYZ curve data, to check for the
      pure overlaps in XYZ space as there is always a destortion between the
      UV and XYZ spaces. If the XYZ curve data is not passed in, extra check
      for the overlap in XYZ space will not be carried out and  whatever the
      overlap region found in UV space will be output.

      If a region is said to be ON the boundary, then the "Edge" with  which
      the region is coincident will be stored as an attribute of the region.

  NOTES

      The xyztol is expected to be chord-height tolerance. This is tolerance
      against which the overlap in XYZ space is checked.

      Memory for the output linklist is allocated in this function. It is the
      caller's responsibility to free the memory allocated.

  ARGUMENTS

      p_lpid      I  Loop ID against which the trimming need to be done.
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
      p_sfgmid    I  Surface geomid consisting the ID, transformation matrix
                     and the matrix type.
      xyztol      I  The value which defines the distance within which 2 cu-
                     rves/part of curves are overlaping.
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

      Trimming, Intersection, Boundary, Loop, Edge ...

  CAVEATS

  HISTORY

     Sanjay                Creation
*/


/* Includes */

#include <stdio.h>
#include <alloca.h>

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWerror.h"

/* Prototypes */

#include "PWapi/sfgeom.h"
#include "PWapi/lpint.h"
#include "PWapi/sortgmint.h"
#include "PWapi/sfcvregs.h"
#include "PWapi/partol.h"

/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwTrimAgainstLoop
(
  struct PWid             *p_lpid,
  struct PWcvdata         *p_uvcv,
  struct PWcvdata         *p_xyzcv,
  PWrange2d               uvcvrng,
  struct PWgeomid         *p_sfgmid,
  double                  xyztol,
  struct PWcvregion_list  **p_cvregs
)
{
  /* status stuff */
  PWresult  PWsts = PW_K_Success;

  /* surface data */
  struct PWsfdata sfdata;

  /* interaction point list */
  struct PWcvintpt_list *p_cvintpts=NULL;

  /* Initialize */
  sfdata.datatype = PWsfdata_bspsf;
  sfdata.data.p_bspsf = NULL;

  /*
   * get the surface geometry from stack.
   */
  PWsts = PW_GetSfBspsfStack (p_sfgmid->id.objid, p_sfgmid->id.osnum,
                      p_sfgmid->mattyp, p_sfgmid->mat, sfdata.data.p_bspsf);
  OnErrorState (IsError(PWsts), PWsts, SetError (PW_K_Trimming, PW_K_Internal),
                 wrapup);

  /*
   * Intersect the UV curve with the given loop and get all the interaction
   * points in the linked list.
   */
  PWsts = pwIntersectWithLoop (p_lpid, p_uvcv, p_xyzcv, uvcvrng, &sfdata,
                               xyztol, &p_cvintpts);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  /*
   * Sort the interaction points on the intersection curve
   */
  if (p_cvintpts && p_cvintpts->p_next)
  {
    double uvtol;

    /*
     * get the surface uv tolerance from xyz
     */
    uvtol = pwGetParTolSf (sfdata.data.p_bspsf, xyztol);

    /*
     * Sort the interaction points
     */
    PWsts = pwSortCvintptList (&p_cvintpts, uvtol);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
  }

  /*
   * Get the curve regions which points to area/bdry from the above found
   * interaction points.
   */
  PWsts = pwCreateSfCvRegion (p_sfgmid, p_uvcv, xyztol, &p_cvintpts, p_cvregs);
  OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);

wrapup :
  PW_Wrapup (PWsts, "pwTrimAgainstLoop");
  return PWsts;
}
 
/* ------------------------------------------------------------------------- */
/*                        End of API Source Code                             */
/* ------------------------------------------------------------------------- */
