/*

Name
  SSChkTg.I

Description

Notes


 */
class implementation Root;

#define M_PI_2                1.57079632679489661923
#include <math.h>
#include <bsvalues.h>

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
#include "godef.h"
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
#include "bsparameters.h"

/* prototypes */
#include "bsdistptpt.h"
#include "bsalloccv.h"
#include "bsprptoncv.h"
#include "bslnpttncv.h"
#include "bslntncvpt.h"
#include "bsproj0.h"
#include "maptbcpro.h"


/*

Name
  SSCheckTangency

Abstract
 This routine checks if pObject is tangent to any arcs/circles in the 
 list of known elements. pObject->type can be a line (SSLINE), an arc (SSARC)
 or a circle (SSCIRCLE).

Synopsis
  int SSCheckTangency ( pObject, PLastObject, Tolerance, x, y, z, 
                        ConstraintPoint, KeyPoint, PpObject )
  SSObject *pObject         IN    The object to check for tangency cnstr
  SSObject *PLastObject     IN    The last object in the list (not used) 
  double   Tolerance        IN    The window tolerance
  double   xpos, ypos, zpos IN    The mouse position
  IGRpoint ConstraintPoint  OUT   The point we are constrained to
  IGRpoint KeyPoint         OUT   The key point we compute the cnstr from the 
                                    cursor pos. that satisfies the constraint
  SSObject **PpObject       OUT   Pointer to other object (not used)

Description

Return Value
  SSNONE - if no constraint found
  ConstraintType - if constraint found
  (see notes)

Notes
  This routine will return OM_E_ABORT instead of a Constraint type if on the
  first invocation it is unable to allocate a bspline curve with BSalloccv().
  This is a bad thing to return - review needed!

  Algorithm reworked to fix the Constraint point.  In original prototype, the
  Constraint point was modified when solving for the solution.

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.
  09/15/93 : Shelley R. Heard : Reworked algorythm to fix ConstraintPoint.

 */

#argsused
SSCheckTangency ( pObject, PLastObject, Tolerance, xpos, ypos, zpos, 
                  ConstraintPoint, KeyPoint, PpObject )
  SSObject *pObject;
  SSObject *PLastObject;
  IGRdouble Tolerance;
  IGRdouble xpos, ypos, zpos;
  IGRpoint  ConstraintPoint;
  IGRpoint  KeyPoint;
  SSObject **PpObject;
{
  int       ConstraintType = SSNONE;
  IGRlong   status;
  int       ObjectIndex;
  BSrc      rc;
  IGRpoint  line[2];
  
  if (pObject->type == SSLINE)
  {
    /*
     * Check for tangency with other arcs/circles
     */
    for (ObjectIndex = 0; 
         ObjectIndex < SSnb_objects && ConstraintType == SSNONE; 
         ObjectIndex++)
    {
      if (SSObjects [ObjectIndex].type == SSARC || 
          SSObjects [ObjectIndex].type == SSCIRCLE)
      {
        double
          uparm,
          delta,
          proj_tol;

        IGRpoint
          fixed_point,
          flex_point,
          proj_flex_pt, 
          tolerance_pt;

        IGRboolean 
          on_curve;

        static struct IGRbsp_curve  *pBSpline = NULL;
        static int                   FirstTime = TRUE;

        /*
         * The minimum distance between the line and the arc/circle must be
         * less than tolerance. We want the line segment to be extended to a 
         * line.
         */
        if (FirstTime)
        {
          short Order = 4;
          long  NumPoles = 7, 
		NumBoundaries = 0;
          int   Rational = 1;

          BSalloccv( Order, NumPoles, Rational, NumBoundaries, &pBSpline, &rc );
          if (rc != BSSUCC) return OM_E_ABORT;  // this is inconsistant !!!
          FirstTime = FALSE;
        }

        /* load up points or tangency check */
        memcpy ( fixed_point, pObject->KeyPoints [0], sizeof ( IGRpoint ) );
        flex_point[0] = xpos; flex_point[1] = ypos; flex_point[2] = zpos;

        /* first look to see if the fixed point in on the curve */
        BSprptoncv( &rc, 
                     SSObjects [ObjectIndex].buffers [0].geometry.bspcurve,
                     fixed_point,
                    &uparm, 
                    &on_curve );

        if ( rc != BSSUCC )
        {
          break;
        }
        else
        {
          if ( on_curve )
          {
            /*
             * get the tangency vector of the curve at the fixed point 
             * location
             */
            BSlntncvpt( &rc,
                        SSObjects [ObjectIndex].buffers [0].geometry.bspcurve,
                        &uparm, 
                        flex_point,
                        pBSpline );
            if ( rc != BSSUCC )
            {
              break;
            }
            /*
             *  We've got the tangent solution!  The flex point's 
             *  projection is the second pole in pBSpline. If the flex
             *  point is within Tolerance of it's projection, then we
             *  have a "hit"; Set KeyPoint and ConstraintType and exit.
             */
            delta = fabs ( BSdistptpt(&rc, flex_point, &pBSpline->poles[3]) );

            if ( rc == BSSUCC && delta < Tolerance)
            {
              memcpy ( KeyPoint, fixed_point, sizeof ( IGRpoint ) );
              memcpy ( ConstraintPoint, &pBSpline->poles[3], sizeof(IGRpoint) );
              ConstraintType = SSTANGENT;
              SSSaveLastConstraint ( &SSObjects [ObjectIndex], 
                                      NULL, 
                                      ConstraintType,
                                      ConstraintPoint,
                                      KeyPoint );
              break;
            }
          }
          else /* not on curve */
          {
            /*
             * The flex point is not on the element; now we have to test
             * to see if the line [ fixed_point, flex_point ] is nearly 
             * collinear to the tangency line of the curve.
             */
            BSEXTRACTPAR ( &rc, BSTOLLENVEC, proj_tol );
            MAptbcproj ( &status, 
                          flex_point,
                          SSObjects [ObjectIndex].buffers [0].geometry.bspcurve,
                         &proj_tol,
                          proj_flex_pt, 
                         &uparm );

            BSlnpttncv( &rc,
                         SSObjects [ObjectIndex].buffers [0].geometry.bspcurve,
                         proj_flex_pt,
                         fixed_point,
                         pBSpline,     /* tangency line */
                        &uparm );

            /*
             * At this point pBSpline is the tangent line trimmed at the
             * curve.  We now test if the true tangent vector (pBSpline) is
             * within a resonable tolerance or the aproximate tangent vector
             * { fixed_point, flex_point }.  This is done by projecting the
             * flex_point onto the tangent vector.  
             */
            memcpy(line[0], &pBSpline->poles[0], sizeof(IGRpoint));
            memcpy(line[1], &pBSpline->poles[3], sizeof(IGRpoint));
            
            BSproj0( &rc, flex_point, line, tolerance_pt );
	    if (rc != BSSUCC) 
	    {
              ConstraintType = SSNONE;
	      goto quit;
            }
            delta = fabs ( BSdistptpt ( &rc, flex_point, tolerance_pt) ); 
            if ( delta < Tolerance )
            {
              /*
               * We have a "hit".  The last check is to see if the 
               * original flex point is within tolerance of the point of
               * tangency on the curve.  If so, we return the point of 
               * tangency (pBSpline->poles[0:2]); if not, we return the 
               * flex points projection onto the tangent vector (tolerance_pt)
               */
              delta = 
                fabs ( BSdistptpt ( &rc, flex_point, &pBSpline->poles[0]) );

              if ( delta < Tolerance )
              {
                memcpy(ConstraintPoint, &pBSpline->poles[0], sizeof(IGRpoint));
                memcpy(KeyPoint, ConstraintPoint, sizeof(IGRpoint));
                ConstraintType = SSTANGENT;
                SSSaveLastConstraint ( &SSObjects [ObjectIndex], 
                                        NULL, 
                                        ConstraintType,
                                        ConstraintPoint,
                                        KeyPoint );
              }
              else
              {
                memcpy (ConstraintPoint, tolerance_pt, sizeof(IGRpoint));
                memcpy (KeyPoint, &pBSpline->poles[0], sizeof(IGRpoint));
                ConstraintType = SSXTANGENT;
                SSSaveLastConstraint ( &SSObjects [ObjectIndex], 
                                        NULL, 
                                        ConstraintType,
                                        ConstraintPoint,
                                        KeyPoint );
              }

	      break;  /* we got it ... leave */
            }
          }
        }
      }
    }
  }

quit:
  return ConstraintType;
}

end implementation Root;
