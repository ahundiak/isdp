/*

Name
  SSChkDir.I

Description

Notes


 */
class implementation Root;

#include <math.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpmacros.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMdtmacros.h"
#include "msdef.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"
#include "bserr.h"

/* prototypes */
#include "bsdistptpt.h"
#include "bsorthovec.h"
#include "bscrossp.h"
#include "maang2ln.h"
#include "maunitvc.h"

/*

Name
  SSCheckDirection

Abstract

Synopsis
  int SSCheckDirection (
    SSObject *PObject;        IN   The object to check for direction cnstr
    SSObject *PLastObject;    IN   The last object in the list (not used)
    double   Tolerance;       IN   The window tolerance
    double   x, y, z;         IN   The mouse position
    IGRpoint ConstraintPoint; OUT  The point we are constrained to
    IGRpoint KeyPoint;        OUT  The key point we compute the cnstr from
    SSObject **PPObject )     OUT   Pointer to other object

Description
 This routine checks if PObject is parallel/perpendicular to any line in the
 list of known elements.

Return Value

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/06/93 : Shelley R. Heard : header added, implemeted for 2.4

 */
#argsused
int SSCheckDirection ( PObject, PLastObject, Tolerance, x, y, z,
                       ConstraintPoint, KeyPoint, PPObject )
SSObject *PObject;
SSObject *PLastObject;
IGRdouble Tolerance;
IGRdouble x, y, z;
IGRpoint  ConstraintPoint;
IGRpoint  KeyPoint;
SSObject **PPObject;
{
  int    ConstraintType = SSNONE;
  double Measures [3];
  int    Parallel = 0, Perpendicular = 0, ObjectIndex, KeyPointIndex;
  int    ElligibleConstraints = 0x0;
  long   LocalStatus;
  BSrc   Rc;

  /*
   * Check for perpendicular and parallel with other lines; this only
   * is done if the elligible constraints (from DPB) include SSACTIVEPARALLEL
   * and/or SSACTIVEPERPEND.
   */
  gr$get_ss_constraints( buffer = &ElligibleConstraints );
  if (!( ElligibleConstraints && (SSACTIVEPARALLEL | SSACTIVEPERPEND)) )
  {
    goto wrapup;
  }

  for ( ObjectIndex = 0;
        ObjectIndex < SSnb_objects && ConstraintType == SSNONE;
        ObjectIndex++)
  {
    if (SSObjects [ObjectIndex].type == SSLINE)
    {
      MAang2ln ( &LocalStatus,
                  PObject->buffers [0].geometry.bspcurve,
                  SSObjects [ObjectIndex].buffers [0].geometry.bspcurve,
                  Measures );
      /*
       * Check for a tolerance of +/- 1.25 degrees (e.g. angle < 2.5 degrees OR
       * angle < 0.0436332312998 radians.  Measure[0] is the angle in radians.
       */
      Parallel      = ( (Measures [0] <=   SSANGLE_TOLERANCE_RADIANS) &&
                        (Measures [0] >= - SSANGLE_TOLERANCE_RADIANS) );
      Perpendicular = ( (Measures [0] <= PI/2.0 + SSANGLE_TOLERANCE_RADIANS) &&
                        (Measures [0] >= PI/2.0 - SSANGLE_TOLERANCE_RADIANS) );
      if (Parallel || Perpendicular)
      {
        if (Parallel && (ElligibleConstraints & SSACTIVEPARALLEL))
        {
          double *pt1,
                 *pt2,
                 *P3,
                 *P4,
                  Factor,
                  pt1pt2 [3],
                  P5 [3],
                  P6 [3];

          /*
           * The original vector is pt1pt2 and the new vector is P3P4.
           * P5/P6 are P4 projected on the line parallel to pt1pt2.
           * We choose P5 or P6 based on proximity.
           */
          pt1 = &SSObjects[ObjectIndex].buffers[0].geometry.bspcurve->poles[0];
          pt2 = &SSObjects[ObjectIndex].buffers[0].geometry.bspcurve->poles[3];
          P3 = SSNewPoints [0];
          P4 = SSNewPoints [1];
          for ( KeyPointIndex = 0; KeyPointIndex < 3; KeyPointIndex++)
          {
              pt1pt2 [KeyPointIndex] =
                 pt2 [KeyPointIndex] - pt1 [KeyPointIndex];
          }
          MAunitvc ( &LocalStatus, pt1pt2, pt1pt2 );
          Factor = BSdistptpt ( &Rc, P3, P4 );
          for (KeyPointIndex = 0; KeyPointIndex < 3; KeyPointIndex++)
          {
            P5 [KeyPointIndex] =
                P3 [KeyPointIndex] + pt1pt2 [KeyPointIndex] * Factor;
            P6 [KeyPointIndex] =
                P3 [KeyPointIndex] - pt1pt2 [KeyPointIndex] * Factor;
          }

          if (BSdistptpt ( &Rc, P4, P5 ) < BSdistptpt ( &Rc, P4, P6 ))
            memcpy ( ConstraintPoint, P5, sizeof ( IGRpoint ) );
          else
            memcpy ( ConstraintPoint, P6, sizeof ( IGRpoint ) );

          ConstraintType = SSPARALLEL;
          SSSaveLastConstraint ( &SSObjects [ObjectIndex],
                                    NULL,
                                    ConstraintType,
                                  ConstraintPoint,
                                    NULL );
        }
        else if ( ElligibleConstraints & SSACTIVEPERPEND )
        {
          double *pt1,
                   *pt2,
                   *P3,
                   *P4,
                    Factor,
                    pt1pt2 [3],
                    P5 [3],
                    P6 [3],
                    P3P7 [3];

          /*
           * The original vector is pt1pt2 and the new vector is P3P4.
           * P3P7 is the vector normal to pt1pt2. P5 and P6 are the 2
           * possible points on the line normal to pt1pt2. We choose P5 or
           * P6 based on proximity.
           */
          pt1 = &SSObjects[ObjectIndex].buffers[0].geometry.bspcurve->poles[0];
          pt2 = &SSObjects[ObjectIndex].buffers[0].geometry.bspcurve->poles[3];
          P3 = SSNewPoints [0];
          P4 = SSNewPoints [1];

          for (KeyPointIndex = 0; KeyPointIndex < 3; KeyPointIndex++)
          {
            pt1pt2 [KeyPointIndex] = pt2 [KeyPointIndex] - pt1 [KeyPointIndex];
          }

          MAunitvc ( &LocalStatus, pt1pt2, pt1pt2 );

          if (SSRefLock)
          {
            BScrossp ( &Rc, SSRefPlane.normal, pt1pt2, P3P7 );
          }
          else
          {
	    double pt3pt4[3];
	    double normal[3];
            /*
             * We measure the angle between the two lines and use the 
             * normal from the cross products to determine the plane on 
             * which the solution shall lie.
             */
            for ( KeyPointIndex = 0; KeyPointIndex < 3; KeyPointIndex++)
            {
              pt3pt4 [KeyPointIndex] =
                 P4 [KeyPointIndex] - P3 [KeyPointIndex];
            }
            MAunitvc ( &LocalStatus, pt3pt4, pt3pt4 );
            BScrossp ( &Rc, pt3pt4, pt1pt2, normal );
            BScrossp ( &Rc, normal, pt1pt2, P3P7 );
          }

          Factor = BSdistptpt ( &Rc, P3, P4 );
          for (KeyPointIndex = 0; KeyPointIndex < 3; KeyPointIndex++)
          {
            P5 [KeyPointIndex] =
                P3 [KeyPointIndex] + P3P7 [KeyPointIndex] * Factor;
            P6 [KeyPointIndex] =
                P3 [KeyPointIndex] - P3P7 [KeyPointIndex] * Factor;
          }

          if (BSdistptpt ( &Rc, P4, P5 ) < BSdistptpt ( &Rc, P4, P6 ))
          {
            memcpy ( ConstraintPoint, P5, sizeof ( IGRpoint ) );
          }
          else
          {
            memcpy ( ConstraintPoint, P6, sizeof ( IGRpoint ) );
          }

          ConstraintType = SSPERPENDICULAR;
          SSSaveLastConstraint ( &SSObjects [ObjectIndex],
                                  NULL,
                                  ConstraintType,
                                  ConstraintPoint,
                                  NULL );
        }
      }
    }
  }

wrapup :

  return ConstraintType;
}

end implementation Root;
