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
     the UV-space of the surface and the surface boundaries, outputs the int-
     raction points in a linked list.
 
  DESCRIPTION

     Given a UV curve in the UV-space of surface, and surface id, it  outputs
     all the  geometric interaction points with the boundaries of the surface
     i.e. edges of the loops. The UV curve is typically an intersection curve
     in the UV-space of the  surface as it interacts with another surface.

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
     ance is XYZ space (typically chord height tolerance),  'sfgmid'  surface
     geomid with which the intersection need to be done. The output from this
     function is a linked list 'cvintpts', contain all the  information about
     the interaction points. This linked list structure  primarily  points to
     the inteaction point on the UV-curve, and also contains the similar inf-
     ormation about this interaction as seen on the loop's element i.e. edge.
     This similar information is the 'sibling' information. The actual points
     returned are computed on the geometrices i.e. UV-curve and edge.

  NOTES

     Care is taken to see that the zero-length tolerance being  passed  in is  
     strictly respected.

     All the memory for the interaction points is allocated in this function.
     So, it is the caller's responsibility to free the  memory  allocated  by 
     calling respective free function(s).
 
  ARGUMENTS

     p_sfgmid    I  Surface geomid consisting the ID, transformation matrix
                    and the matrix type.
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
     xyztol      I  The value which defines the distance within which 2 cu-
                    rves/part of curves are overlaping.

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

#include <stdio.h>
#include <alloca.h>        /* system includes */

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWerror.h"       /* pathway includes */
#include "PWattrib.h"
#include "PWattribid.h"

/* Prototypes */

#include "PWapi/sfgeom.h"
#include "PWapi/sflp.h"
#include "PWapi/fcint.h"
#include "PWapi/partol.h"


/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwIntersectWithSurface
(
  struct PWgeomid         *p_sfgmid,
  struct PWcvdata         *p_uvcv,
  struct PWcvdata         *p_xyzcv,
  PWrange2d               uvcvrng,
  double                  xyztol,
  struct PWcvintpt_list   **p_cvintpts
)
{
  /* status stuff */
  PWresult  PWsts=PW_K_Success;

  /* Faces of surface */
  int          num_faces=0;
  PWobjid      *p_faces=NULL;
  struct PWid  faceid;

  /* Loop count */
  int  face=0;

  /* Surface geometry */
  struct PWsfdata sfdata;

  /* Interaction list */
  struct PWcvintpt_list  *p_list=NULL;

  /* 
   * validate the incoming arguments 
   */
  if (!p_sfgmid || !p_uvcv || !p_cvintpts)
    OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_InvalidArg),
                  wrapup);

  /*
   * get the number of faces of the surface. Typically, a surface having
   * zero faces implies a corrupted surface. But there are situations 
   * encountered in TR#119700155, where the surface only consists of 
   * point-loops (EMSptgralp-s), which for some reason still sticks around.
   * It was deemed prudent to be tolerant of this, rather than return
   * an error in this case. When we have zero faces, exit with an 
   * informational.
   */

  num_faces = pwNumFacesOfSf (p_sfgmid->id.objid, p_sfgmid->id.osnum);
  OnErrorState (!num_faces, PWsts, SetInfo (PW_K_Trimming, PW_K_InvalidArg),
                wrapup); 

  /*
   * allocate the memory for the faces and get all the faces of the surface
   */
  p_faces = (PWobjid *) alloca (num_faces * sizeof(PWobjid));
  OnErrorState (!p_faces, PWsts, SetError (PW_K_Trimming, PW_K_DynamicMemory),
                wrapup);

  num_faces = pwFacesOfSf (p_sfgmid->id.objid, p_sfgmid->id.osnum, p_faces);
  OnErrorState (!num_faces, PWsts, SetError (PW_K_Trimming, PW_K_Internal), 
                wrapup); 

  /* 
   * Initialize the surface data structure 
   */
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
   * Now, intersect the curve with each face of the surface and append the 
   * intersection points to the incoming list.
   */
  faceid.osnum = p_sfgmid->id.osnum;

  for (face=0; face<num_faces; face++)
  {
    faceid.objid = p_faces[face];
  
    PWsts = pwIntersectWithFace (&faceid, p_uvcv, p_xyzcv, uvcvrng, &sfdata,
                                 xyztol, &p_list);
    OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
  }

  pwAppendCvintptList (p_cvintpts, p_list);
  
wrapup :

  if (IsError (PWsts) && p_list)
    pwFreeCvintptList (p_list);
  
  PW_Wrapup (PWsts, "pwIntersectWithSurface");
  return PWsts;
}
 
/* ------------------------------------------------------------------------- */
/*                        End of API Source Code                             */
/* ------------------------------------------------------------------------- */
