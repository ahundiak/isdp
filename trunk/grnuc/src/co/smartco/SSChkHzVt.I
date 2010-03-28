/*

Name
  SSChkHzVt.I

Description
  Checks for horizontal and vertical constraints for all SSobjects/keypoints

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
#include "maptplpro.h"
#include "maptsxfor.h"
#include "bsxlnarc.h"
#include "bsdistptpt.h"


/*

Name
  SSCheckHzVt

Abstract

Synopsis
  int SSCheckHzVt ( pObject, PLastObject, Tolerance, x, y, z,
                    ConstraintPoint, KeyPoint, PpObject )
  SSObject *pObject         IN  The object to check for horiz/vert cnstr
  SSObject *PLastObject     IN  The last object in the list (not used)
  double   Tolerance        IN  The window tolerance
  double   x, y, z          IN  The mouse position
  IGRpoint ConstraintPoint OUT  The point we are constrained to
  IGRpoint KeyPoint        OUT  The key point we compute the cnstr from
  SSObject **PpObject      OUT  Pointer to other object (not used)

Description
 If the reference plane lock is on then check for horizontal/vertical else
 return with no constraint. KeyPoint is the key point we computed the Hz/Vt
 constraint from.

Return Value
  Constraint type found or SSNONE if non found

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added.

 */

#argsused
int SSCheckHzVt ( pObject, 
		  PLastObject, 
		  Tolerance, 
		  x, y, z,
                  ConstraintPoint, 
		  KeyPoint, 
		  PpObject )
SSObject *pObject;
SSObject *PLastObject;
double   Tolerance;
double   x, y, z;
IGRpoint ConstraintPoint;
IGRpoint KeyPoint;
SSObject **PpObject;
{

  int 
    ConstraintType = SSNONE, 
    PrimaryType = SSNONE, 
    Horizontal, 
    Vertical, 
    index,
    ElligibleConstraints;

  IGRpoint 
    Point1, 
    Point2;

  long
    msg_loc,
    one = 1;


  gr$get_ss_constraints( buffer = &ElligibleConstraints ); 

  if (   SSRefLock 
      && (ElligibleConstraints & (SSACTIVEHORIZONTAL | SSACTIVEVERTICAL)) )
  {
    /* Point1 is the keypoint in RefPlane coords */
    /* Point2 is the cursor   in RefPlane coords */
    Point2[0] = x;
    Point2[1] = y;
    Point2[2] = z;
    MAptsxform ( &msg_loc, &one, SSRefMatrix, Point2, Point2 );

    for (;;)
    {
      for (index = 0; index < pObject->NbKeyPoints; index++)
      {
        /*
         * We ignore key points that are not active
         */
        if (!pObject->KeyPointActive[index]) continue;

        /*
         * We need to project the keypoint and then transform it to the
         * coordinate system of the reference plane. The mouse position is
         * on the plane but is not in the plane's CS.
         */
        MAptplproj( &msg_loc, &pObject->KeyPoints[index], &SSRefPlane, Point1 );
       
        MAptsxform ( &msg_loc, &one, SSRefMatrix, Point1, Point1 );
  
        Vertical = fabs ( Point1[0] - Point2[0] ) < Tolerance;
        Horizontal = fabs ( Point1[1] - Point2[1] ) < Tolerance;
        if ( Vertical | Horizontal )
        {
          memcpy ( ConstraintPoint, Point2, sizeof ( IGRpoint ) );
          if ( Horizontal && (ElligibleConstraints & SSACTIVEHORIZONTAL) )
          {
            ConstraintPoint[1] = Point1[1];
            ConstraintType = SSHORIZONTAL;
          }
          else if ( Vertical && (ElligibleConstraints & SSACTIVEVERTICAL) )
          {
            ConstraintPoint[0] = Point1[0];
            ConstraintType = SSVERTICAL;
          }
  
          /*
           * We cannot have horizontal/horizontal or vertical/vertical
           */
          if (PrimaryType != ConstraintType)
          {
            MAptsxform ( &msg_loc, 
                         &one, 
                         SSInvRefMatrix,
                         ConstraintPoint,
                         ConstraintPoint );
            memcpy ( KeyPoint, pObject->KeyPoints[index], sizeof ( IGRpoint ) );
  
            if (PrimaryType == SSNONE)
            {
              extern int ss_adjust_for_new_arc();
              /*
               * We got it.
               */
              if ( SSNewElementType == SSARC )
              {
	        double *pVector;

                pVector = Horizontal ? SSRefXaxis : SSRefYaxis;
                ss_adjust_for_new_arc (  pVector,
					 KeyPoint, 
                                        &ConstraintType, 
                                         ConstraintPoint );
              }

              PrimaryType = ConstraintType;
              SSSaveLastConstraint ( pObject, 
                                     NULL, 
                                     ConstraintType,
                                     ConstraintPoint,
                                     KeyPoint );
            }
            else
            {
              long           LocalStatus;
              struct IGRline Line1, Line2;
              double         U1, U2;
              IGRpoint       IntersectionPoint;
              GRobjid        Objid = SSLastObject1->grid.objid;
              int            ObjectIndex;
  
              /*
               * We need to compute the point that will satisfy BOTH 
               * constraints. That point is the intersection between the 
               * segments defined by the key point and the constraint point
               * of the last constraint and the ones of this constraint.
               */
              Line1.point1 = SSLastKeypoint;
              Line1.point2 = SSLastConstraintPoint;
              Line2.point1 = KeyPoint;
              Line2.point2 = ConstraintPoint;
              MA2lnisect ( &LocalStatus, 
                           &Line1, 
                           &Line2, 
                           &Tolerance,
                            IntersectionPoint,
                           &U1, 
                           &U2 );
              memcpy ( ConstraintPoint, IntersectionPoint, sizeof (IGRpoint) );
              ConstraintType = 
                 PrimaryType == SSVERTICAL ? SSVHORIZONTAL : SSHVERTICAL;

              /*
               * We got it.
               */
              SSSaveLastConstraint ( pObject, 
                                     NULL, 
                                     ConstraintType, 
                                     ConstraintPoint,
                                     KeyPoint );
              /*
               * We want SSLastObject2 to point to the first object so that we
               * can hilite it.
               */
              for (ObjectIndex = 0; ObjectIndex < SSnb_objects; ObjectIndex++)
	      {
                if (Objid == SSObjects[ObjectIndex].grid.objid)
		{
                  SSLastObject2 = &SSObjects[ObjectIndex];
		  /* when does this get nulled out? */
		}
	      }
              break;
            }
          }
        }
      }
      
      /*
       * If the first object gave us a constraint then we look at the other 
       * ones to have multiple constraints.
       */
      if (ConstraintType == SSHVERTICAL || ConstraintType == SSVHORIZONTAL)
      {
        break;
      }
      else
      {
        if (ConstraintType == SSVERTICAL || ConstraintType == SSHORIZONTAL)
        {
          pObject++;
          if (pObject == PLastObject) break;
        }
        else
        {
          break;
        }
      }
    }
  }

  return ConstraintType;

}

int ss_adjust_for_new_arc ( isectVector,
                            keyPoint, 
                            pconstraintType, 
                            constraintPoint )
  IGRvector isectVector;
  double   *keyPoint;
  int       pconstraintType;
  double   *constraintPoint;
{
  int       status = MSSUCC;
  BSrc      bsrc;
  double    radius;
  double    ortho_endpt[3];
  IGRint    num_ipts = 0;
  IGRpoint  ipts[2];

  ortho_endpt[0] = keyPoint[0] + isectVector[0];
  ortho_endpt[1] = keyPoint[1] + isectVector[1];
  ortho_endpt[2] = keyPoint[2] + isectVector[2];
  
  radius = BSdistptpt( &bsrc,
                        SSNewObject1.KeyPoints [SSARC_CENTER], 
                        SSNewObject1.KeyPoints [SSARC_ENDPT1] );

  BSxlnarc( keyPoint, 
            ortho_endpt, 
            TRUE,  /* infinite line */
            SSNewObject1.KeyPoints [SSARC_CENTER], 
            SSNewObject1.KeyPoints [SSARC_ENDPT1], 
            SSNewObject1.KeyPoints [SSARC_ENDPT1],  /* full circle! */
            SSRefPlane.normal, 
            radius, 
            FALSE,   /* arc start and end vectors not supplied */
            NULL, 
            NULL, 
           &num_ipts, 
            ipts,
           &bsrc);


  if ( bsrc == BSSUCC )
  {
    switch ( num_ipts )
    {
      case 0 :
      {
	pconstraintType = SSNONE;
	break;
      }

      case 1 :
      {
        memcpy ( constraintPoint, ipts[0], sizeof ( IGRpoint ) );
	break;
      }

      case 2 :
      {
	double dist0, dist1;

        dist0 = BSdistptpt( &bsrc,
                            SSNewObject1.KeyPoints [SSARC_ENDPT2], 
                            ipts[0] );

        dist1 = BSdistptpt( &bsrc,
                            SSNewObject1.KeyPoints [SSARC_ENDPT2], 
                            ipts[1] );

        if ( fabs(dist0) < fabs(dist1) )
	{
           memcpy ( constraintPoint, ipts[0], sizeof ( IGRpoint ) );
	}
	else
	{
           memcpy ( constraintPoint, ipts[1], sizeof ( IGRpoint ) );
	}
	break;
      }
    } /* end switch */
  }

  return status;
}

end implementation Root;
