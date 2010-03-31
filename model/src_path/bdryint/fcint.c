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
     the UV-space of the surface and the face boundaries, outputs the intrac-
     tion points in a linked list.
 
  DESCRIPTION

     Given a UV curve in the UV-space of surface, and face id, it  outputs all 
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
     ance is XYZ  space (typically chord height tolerance), 'faceid'  face id 
     with which the intersection need to be done. The output from this funct-
     ion is a linked list 'cvintpts', contain  all  the information about the 
     interaction points. This  linked  list structure primarily points to the 
     interaction point on the UV-curve, and also contains the similar inform-
     ation about this interaction as seen on the loop element i.e. edge. This 
     similar information is the 'sibling' information. The actual points ret-
     urned are computed on the geometrices i.e. UV-curve and edge.

  NOTES

     Care is taken to see that the zero-length tolerance being  passed  in is  
     strictly respected.

     All the memory for the interaction points is allocated in this function.
     So, it is the caller's responsibility to free the  memory  allocated  by 
     calling respective free function(s).
 
  ARGUMENTS

     p_faceid    I  Face ID, with which the interaction should take place.
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
#include <alloca.h>

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWerror.h"       /* pathway includes */
#include "PWattrib.h"
#include "PWattribid.h"

/* Prototypes */

#include "PWapi/sflp.h"
#include "PWapi/lpint.h"
#include "PWapi/partol.h"

/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwIntersectWithFace
(
  struct PWid             *p_faceid,
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

  /* Holes of Face */
  int          num_holes=0;

  /* Interaction list */
  struct PWcvintpt_list  *p_list=NULL;

  /*
   * validate the incoming arguments
   */
  if (!p_sfdata || !p_uvcv || !p_cvintpts)
    OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_InvalidArg),
                  wrapup);

  /*
   * first intersect the curve with the face.
   */
  PWsts = pwIntersectWithLoop (p_faceid, p_uvcv, p_xyzcv, uvcvrng, p_sfdata, 
                               xyztol, &p_list);
  OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);

  /*
   * get the number of holes of the face
   */
  num_holes = pwNumHolesOfFace (p_faceid->objid, p_faceid->osnum);

  if (num_holes)
  {
    /* Holes of Face */
    PWobjid      *p_holes=NULL;
    struct PWid  holeid;
  
    /* Loop count */
    int  hole=0;

    /* 
     * allocate the memory and get the holes of face
     */
    p_holes = (PWobjid *) alloca (num_holes * sizeof(PWobjid));
    OnErrorState (!p_holes, PWsts, SetError (PW_K_Trimming, PW_K_DynamicMemory),
                  wrapup);

    num_holes = pwHolesOfFace (p_faceid->objid, p_faceid->osnum, p_holes);
    OnErrorState (!num_holes, PWsts, SetError (PW_K_Trimming, PW_K_Internal),
                  wrapup);

    /*
     * Now, Intersect the curve with each hole boundary.
     */
    holeid.osnum = p_faceid->osnum;

    for (hole = 0; hole < num_holes; hole++ )
    {
      holeid.objid = p_holes[hole];

      PWsts = pwIntersectWithLoop (&holeid, p_uvcv, p_xyzcv, uvcvrng, p_sfdata,
                                   xyztol, &p_list);
      OnErrorState (IsError(PWsts), PWsts, PWsts, wrapup);
    }
  }

  /*
   * Append the interaction list to the incoming interaction points list
   */
  pwAppendCvintptList (p_cvintpts, p_list);

wrapup :

  if (IsError(PWsts) && p_list)
    pwFreeCvintptList (p_list);

  PW_Wrapup (PWsts, "pwIntersectWithFace");
  return PWsts;
}

/* ------------------------------------------------------------------------- */
/*                        End of API Source Code                             */
/* ------------------------------------------------------------------------- */
