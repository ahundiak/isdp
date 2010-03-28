/*

Name
  SSChkOnEle.I

Description

Notes


 */
class implementation Root;

#include <math.h>
#include <bsvalues.h> /* for SOLARIS */

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
#include "godef.h"
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
#include "bsparameters.h"
#include "bsalloccv.h"
#include "bsmdistcvcv.h"
#include "bsmdistptcv.h"
#include "bscvcv_int.h"
#include "malnbcpro.h"
#include "malncbcli.h"
#include "malnlspro.h"
#include "maptbcpro.h"
#include "maptlnpro.h"
#include "maptlsdis.h"
#include "maptsxfor.h"
#include "mapytobc.h"
#include "bsdotp.h"
#include "bsmkvec.h"
#include "bsnorvec.h"

#define SS_PARALLEL_TOL_FOR_EXTENDLINES   (1e-3)

/*

Name
  SSLineToCurve

Abstract
 This routine converts a line into a bspline curve. It returns OM_S_SUCCESS
 if the conversion took place and OM_E_ABORT otherwise.

Synopsis
  static int SSLineToCurve ( PLine, PCurve )
  struct IGRline      IN   *PLine     The line
  struct IGRbsp_curve OUT  **PCurve   The bspline curve

Description

Return Value
  OM_S_SUCCESS  success
  OM_E_ABORT    failure due to failure in BSalloccv or MApytobc

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */

static int SSLineToCurve ( PLine, PCurve )
  struct IGRline      *PLine;
  struct IGRbsp_curve **PCurve;
{
  BSrc                       Rc;
  long                       LocalStatus;

%safe
  static struct IGRpolyline  PolyLine;
  static double              Points [6];
  static struct IGRbsp_curve *PCurve2;
  static int                 FirstTime = 1;
%endsafe

  if (FirstTime)
  {
    short Order = 4;
    long  NumPoles = 7, 
          NumBoundaries = 0;
    int   Rational = 1;
    
    BSalloccv ( Order, NumPoles, Rational, NumBoundaries, &PCurve2, &Rc );
    if (Rc != BSSUCC)
    {
      LocalStatus = MSFAIL;
      goto quit;
    }
 
    PolyLine.num_points = 2;
    PolyLine.points = &Points [0];
    FirstTime = FALSE;
  }
  
  *PCurve = PCurve2;
  memcpy ( &Points [0], PLine->point1, sizeof ( IGRpoint ) );
  memcpy ( &Points [3], PLine->point2, sizeof ( IGRpoint ) );
  MApytobc ( &LocalStatus, &PolyLine, *PCurve );

quit:
  return LocalStatus & 1 ? OM_S_SUCCESS : OM_E_ABORT;
}


/*

Name
  SSBoreLineObjectDistance 

Abstract
  This routine computes the distance between a point/boreline and an object.
  Note: We should return the projected point so that we don't have to 
  re-compute it later.

Synopsis
  static int SSBoreLineObjectDistance (pBoreLine, pObject, Extended, PDistance)
  struct IGRline *pBoreLine   IN  The bore line
  SSObject       *pObject     IN  The object
  int             Extended    IN  Compute the dist for the Xtended element?
  double         *PDistance   OUT The distance

Description

Return Value
  OM_S_SUCCESS  always

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.
  06/06/94 : Sudha	      : Purify fnh fix ( free nonheap memory ).

 */
static int SSBoreLineObjectDistance ( pBoreLine, pObject, Extended, PDistance )
  struct IGRline *pBoreLine;
  SSObject       *pObject;
  int            Extended;
  double         *PDistance;
{
  struct IGRline Line;
  double         *Parms, *InterParms;
  short          k, n;
  BSrc           Rc;
  long           LocalStatus;

  *PDistance = MAXFLOAT;
  switch (pObject->type)
  {
    case SSPOINT:
    case SSCOORDSYS :
    {
      if (pBoreLine->point2)
      {
        MAptlsdis ( &LocalStatus, 
                     pObject->KeyPoints[0],
                     (struct IGRline_seg *) pBoreLine, 
                     PDistance );
      }
      else
      {
        MA2ptdis ( &LocalStatus, 
                    pObject->KeyPoints[0],
                    pBoreLine->point1,
                    PDistance );
      }
      break;
    }

    case SSLINE:
    {
      if (pBoreLine->point2)
      {
        IGRpoint Point1, Point2;
        double   UParm1, UParm2;

        Line.point1 = pObject->KeyPoints [0];
        Line.point2 = pObject->KeyPoints [2];
        MA2lndis ( &LocalStatus, &Line, pBoreLine, PDistance );

        /*
         * If Extended is FALSE then we must make sure that we are talking
         * about the segment (not the line)
         */
        if (!Extended)
        {
          MAlnlsproj ( &LocalStatus, 
                       &Line, 
                       (struct IGRline_seg *) pBoreLine, 
                        Point1, 
                        Point2, 
                       &UParm1, 
                       &UParm2 );
          if (UParm1 < 0 || UParm1 > 1.0)
            *PDistance = MAXFLOAT;
        }
      }
      else
      {
        if (Extended)
        {
          Line.point1 = pObject->ExtendedPoints [0];
          Line.point2 = pObject->ExtendedPoints [1];
        }
        else
        {
          Line.point1 = pObject->KeyPoints [0];
          Line.point2 = pObject->KeyPoints [2];
        }
        MAptlsdis ( &LocalStatus, 
                     pBoreLine->point1, 
                    (struct IGRline_seg *) &Line,
                     PDistance );
      }
      break;
    }

    case SSCIRCLE   :
    case SSARC      :
    case SSBSCURVE  :
    {
      if (pBoreLine->point2)
      {
        struct IGRbsp_curve *PCurve;
        double              *Parameters1 = NULL, *Parameters2 = NULL;
        IGRpoint            *Points1 = NULL, *Points2 = NULL;
        int                 NumberOfPoints;
        
        /*
         * Build a bsp curve with the boreline and compute the distance 
         * between the 2 curves.
         */
        SSLineToCurve ( pBoreLine, &PCurve );
        BSmdistcvcv ( pObject->buffers [0].geometry.bspcurve, PCurve,
            &NumberOfPoints, &Parameters1, &Parameters2, &Points1, &Points2, 
            PDistance, &Rc );

        if (Parameters1) free ( Parameters1 );
        if (Parameters2) free ( Parameters2 );
        if (Points1) free ( Points1 );
        if (Points2) free ( Points2 );
      }
      else
      {
        BSmdistptcv ( pObject->buffers [0].geometry.bspcurve, pBoreLine->point1,
            &k, &n, &Parms, PDistance, &InterParms, &Rc );
      }
    }
  }

  return OM_S_SUCCESS;   /* always */
}  


/*

Name
  SSProjectBoreLineOnObject

Abstract
 This routine projects a point (Point) to an object (*pObject) and
 returns the result in ProjectedPoint. 

Synopsis
  static int SSProjectBoreLineOnObject (pBoreLine, 
                                        pObject, 
                                        Extended, 
                                        ProjectedPoint )
  struct IGRline *pBoreLine      IN   The bore line
  SSObject       *pObject        IN   The object (to project the point on)
  int             Extended       IN   Extend the object or not?
  IGRpoint        ProjectedPoint OUT  The projected point

Description

Return Value

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */
static int SSProjectBoreLineOnObject (pBoreLine, 
                                      pObject, 
                                      Extended, 
                                      ProjectedPoint )
struct IGRline *pBoreLine;
SSObject       *pObject;
int            Extended;
IGRpoint       ProjectedPoint;
{
  struct IGRline Line;
  double         ProjectionTolerance, UParm, TParm;
  long           LocalStatus;
  BSrc           Rc;
  IGRpoint       Point;
  
  switch (pObject->type)
  {
    case SSPOINT:
    {
      memcpy ( ProjectedPoint, pObject->KeyPoints [0], sizeof ( IGRpoint ) );
      break;
    }

    case SSLINE:
    {
      if (Extended)
      {
        Line.point1 = pObject->ExtendedPoints [0];
        Line.point2 = pObject->ExtendedPoints [1];
      }
      else
      {
        Line.point1 = pObject->KeyPoints [0];
        Line.point2 = pObject->KeyPoints [2];
      }
      
      if (pBoreLine->point2)
      {
        MAlnlsproj ( &LocalStatus, 
                      pBoreLine, 
                    (struct IGRline_seg *) &Line,
                      Point,
                      ProjectedPoint,
                     &UParm,
                     &UParm );
      }
      else
      {
        MAptlnproj ( &LocalStatus,
                      pBoreLine->point1, 
                     &Line, 
                      ProjectedPoint, 
                     &UParm );
      }
      break;
    }

    case SSARC:
    case SSCIRCLE:
    default:
    {
      BSEXTRACTPAR ( &Rc, BSTOLLENVEC, ProjectionTolerance );
      if (pBoreLine->point2)
      {
        MAlnbcproj ( &LocalStatus, 
                      pBoreLine, 
                      pObject->buffers[0].geometry.bspcurve,
                     &ProjectionTolerance,
                      Point, 
                      ProjectedPoint,
                     &TParm, 
                     &UParm );
      }
      else
      {
        MAptbcproj ( &LocalStatus, 
                      pBoreLine->point1,
                      pObject->buffers[0].geometry.bspcurve,
                     &ProjectionTolerance,
                      ProjectedPoint, 
                     &UParm );
      }
    }
  }
  
  return OM_S_SUCCESS;
}


/*

Name
  SSExtendLine

Abstract
 If Extended then this routine returns the extended line for *pObject
 else it simply returns the line. pObject MUST represent a line (type SSLINE).

Synopsis
  static void SSExtendLine ( pObject, Extended, PLine )
    SSObject       *pObject  IN    The object
    int            Extended  IN    To extend or not to extend
    struct IGRline *PLine    OUT   The extended line

Description

Return Value
  none

Notes

Index

Keywords

History
  08/06/93 : Shelley R. Heard : created

 */
static void SSExtendLine ( pObject, Extended, PLine )
SSObject       *pObject /* The object                                   IN  */;
int            Extended /* To extend or not to extend that is the ?     IN  */;
struct IGRline *PLine   /* The extended line                            OUT */;
{
  if (Extended)
  {
    PLine->point1 = pObject->ExtendedPoints [0];
    PLine->point2 = pObject->ExtendedPoints [1];
  }
  else
  {
    PLine->point1 = pObject->KeyPoints [0];
    PLine->point2 = pObject->KeyPoints [2];
  }
}

/*

Name
  SSIntersectCurves

Abstract
 This routine returns the intersection (if any) of 2 curves closest to the
 x, y, z position of the mouse. If an intersection is found it returns TRUE
 and if no intersection is found it returns FALSE.

Synopsis
  int SSIntersectCurves ( pCurve1, pCurve2, MousePosition, IntersectionPoint )
    struct IGRbsp_curve *pCurve1            IN   First curve
    struct IGRbsp_curve *pCurve2            IN   Second curve
    IGRpoint            MousePosition       IN   Mouse position
    IGRpoint            IntersectionPoint   OUT  The intersection point

Description

Return Value
  TRUE   if curves do intersect
  FALSE  if curves do not intersect

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */

int SSIntersectCurves ( pCurve1, pCurve2, MousePosition, IntersectionPoint )
struct IGRbsp_curve *pCurve1            /* First curve                  IN  */;
struct IGRbsp_curve *pCurve2            /* Second curve                 IN  */;
IGRpoint            MousePosition       /* Mouse position               IN  */;
IGRpoint            IntersectionPoint   /* The intersection point       OUT */;
{
  double *Points = NULL, 
         *Dummy1 = NULL,
         *Dummy2 = NULL,
         *Dummy3 = NULL, 
         *Dummy4 = NULL,
         *Dummy5 = NULL,
         Distance,
         MinimumDistance;

  long   DummyCount;

  BSrc   Rc;

  int    NumberOfIntersections,
         LocalStatus,
         Index,
         IntersectionIndex,
         ElligibleConstraints;

  /* 
   * If intersection is not an elligible class, we return FALSE 
   */
  gr$get_ss_constraints( buffer = &ElligibleConstraints );
  if (!(ElligibleConstraints & SSACTIVEINTERSECT))
  {
    LocalStatus = FALSE;
    goto wrapup;
  }

  BScvcv_int ( &Rc, pCurve1, pCurve2, &NumberOfIntersections, &Points, 
    &Dummy1, &Dummy2, &DummyCount, &Dummy3, &Dummy4, &Dummy5 );
  if (NumberOfIntersections)
  {
    if (NumberOfIntersections > 1)
    {
      /*
       * Multiple solutions: we get the closest to the mouse position
       */
      for (IntersectionIndex = 0, MinimumDistance = MAXFLOAT, Index = 0; 
           IntersectionIndex < NumberOfIntersections; IntersectionIndex++)
      {
        Distance = (Points [IntersectionIndex * 3] - MousePosition [0]) * 
          (Points [IntersectionIndex * 3] - MousePosition [0]) +
          (Points [IntersectionIndex * 3 + 1] - MousePosition [1]) * 
          (Points [IntersectionIndex * 3 + 1] - MousePosition [1]) +
          (Points [IntersectionIndex * 3 + 2] - MousePosition [2]) * 
          (Points [IntersectionIndex * 3 + 2] - MousePosition [2]);
        if (Distance < MinimumDistance)
        {
          MinimumDistance = Distance;
          Index = IntersectionIndex;
        }
      }
    }
    else
      Index = 0;

    memcpy ( IntersectionPoint, &Points [Index * 3], sizeof ( IGRpoint ) );
    
    if (Points) free ( Points );
    if (Dummy1) free ( Dummy1 );
    if (Dummy2) free ( Dummy2 );
    if (Dummy3) free ( Dummy3 );
    if (Dummy4) free ( Dummy4 );
    if (Dummy5) free ( Dummy5 );

    LocalStatus = TRUE;
  }
  else
  {
    LocalStatus = FALSE;
  }

wrapup:
  return LocalStatus;
}


/*

Name
  SSIntersectObjects 

Abstract
 This routine computes the intersection point, if any, between object1
 (*pObject1) and object2 (*pObject2). In case of multiple solutions, the
 mouse position (Point) is used to lift the ambiguity. 

Synopsis

  int SSIntersectObjects ( pObject1, 
                           pObject2, 
                           Point, 
                           Extended, 
                           Tolerance, 
                           IntersectionPoint )
  SSObject *pObject1         IN   The first object
  SSObject *pObject2         IN   The object
  IGRpoint Point             IN   The mouse position
  int      Extended          IN   Extend the object or not?
  double   Tolerance         IN   The tolerance to be used
  IGRpoint IntersectionPoint OUT  The intersection point

Description

Return Value
  TRUE if an intersection was found 
  FALSE otherwise.

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */

int SSIntersectObjects ( pObject1, 
                         pObject2, 
                         Point, 
                         Extended, 
                         Tolerance, 
                         IntersectionPoint )
SSObject *pObject1;
SSObject *pObject2;
IGRpoint Point;
int      Extended;
double   Tolerance;
IGRpoint IntersectionPoint;
{
  struct IGRline      Line1, Line2;
  long                LocalStatus = TRUE;
  struct IGRbsp_curve *pCurve1, *pCurve2;
  double              U1, U2;
  
  /*
   * Get rid of the trivial case
   */
  if (pObject1->type == SSPOINT || pObject2->type == SSPOINT)
  {
    LocalStatus = FALSE;
    goto quit;
  }
  
  /*
   * We need to special case for efficiency and to support extended objects
   */
  if (pObject1->type == SSLINE && pObject2->type == SSLINE)
  {
    BSrc       Rc = 0;
    IGRvector  Vector1, Vector2;
    IGRdouble  Dotp = 0.0;

    SSExtendLine ( pObject1, Extended, &Line1 );
    SSExtendLine ( pObject2, Extended, &Line2 );

    /*
     * check for the parallality    - GMK 01/25/94
     */
    BSmkvec (&Rc, Vector1, Line1.point1, Line1.point2);
    if ( Rc != BSSUCC ) { LocalStatus = FALSE; goto quit; }
    BSnorvec(&Rc, Vector1 );
    if ( Rc != BSSUCC ) { LocalStatus = FALSE; goto quit; }

    BSmkvec (&Rc, Vector2, Line2.point1, Line2.point2);
    if ( Rc != BSSUCC ) { LocalStatus = FALSE; goto quit; }
    BSnorvec(&Rc, Vector2 );
    if ( Rc != BSSUCC ) { LocalStatus = FALSE; goto quit; }

    Dotp = BSdotp( &Rc,Vector1,Vector2);
    if ( Rc != BSSUCC ) { LocalStatus = FALSE; goto quit; }

    if ( (1 - fabs(Dotp)) > SS_PARALLEL_TOL_FOR_EXTENDLINES )
    {
      MA2lsisect ( &LocalStatus,
                 (struct IGRline_seg *) &Line1,
                 (struct IGRline_seg *) &Line2,
                 &Tolerance,
                  IntersectionPoint,
                 &U1,
                 &U2 );
      LocalStatus = TRUE;
    }
    else
    {
      LocalStatus = FALSE;
    }
    goto quit;
  }
  else
  {
    if (Extended && pObject1->type == SSLINE || pObject2->type == SSLINE)
    {
      SSObject *pLine = pObject1->type == SSLINE ? pObject1 : pObject2,
                       *pOther = pObject1->type == SSLINE ? pObject2 : pObject1;
      static struct IGRbsp_curve *pBSpline;
      static int                 FirstTime = TRUE;
      struct IGRpolyline         PolyLine;
      double                     PolyPoints [6];
      BSrc                       Rc;
      
      /*
       * We extend the line and then convert the extended line into a b-spline
       */
      SSExtendLine ( pLine, Extended, &Line1 );

      if (FirstTime)
      {
        short Order = 4;
        long  NumPoles = 7, 
              NumBoundaries = 0;
        int   Rational = 1;

        BSalloccv ( Order, NumPoles, Rational, NumBoundaries, &pBSpline, &Rc );
        if (Rc != BSSUCC)
        {
          LocalStatus = OM_E_ABORT;
          goto quit;
        }
        FirstTime = FALSE;
      }
      
      PolyLine.num_points = 2;
      PolyLine.points = PolyPoints;
      memcpy ( PolyPoints, Line1.point1, 3 * sizeof ( double ) );
      memcpy ( &PolyPoints [3], Line1.point2, 3 * sizeof ( double ) );
      MApytobc ( &Rc, &PolyLine, pBSpline );
      pCurve1 = pBSpline;
      pCurve2 = pOther->buffers [0].geometry.bspcurve;
    }
    else
    {
      pCurve1 = pObject1->buffers [0].geometry.bspcurve;
      pCurve2 = pObject2->buffers [0].geometry.bspcurve;
    }

    LocalStatus = (long) SSIntersectCurves ( pCurve1, 
                                             pCurve2, 
                                             Point, 
                                             IntersectionPoint );
  }

quit:
  return (int) LocalStatus;  
}


/*

Name
  SSCheckOnElement

Abstract
 This routine checks for "on element" constraints. Note that if the point
 is on 2 elements, we look for an intersection.

Synopsis
  int SSCheckOnElement ( pObject, PLastObject, Tolerance, pBoreLine, Extended,
                         ConstraintPoint, KeyPoint, PpObject )
    SSObject       *pObject         IN   The object to check for coincid cnstr
    SSObject       *PLastObject     IN   The last object in the list
    double          Tolerance       IN   The window tolerance
    struct IGRline *pBoreLine       IN   The bore line
    int             Extended        IN   Look for extension of the elements?
    IGRpoint        ConstraintPoint OUT  The point we are constrained to
    IGRpoint        KeyPoint        OUT  The key point of the element
    SSObject      **PpObject        OUT  Pointer to other object (intersect)

Description

Return Value
  Constraint type found 
  SSNONE if none found

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */

#argused
SSCheckOnElement ( pObject, PLastObject, Tolerance, pBoreLine, Extended,
                   ConstraintPoint, KeyPoint, PpObject )
SSObject       *pObject;
SSObject       *PLastObject;
double         Tolerance;
struct IGRline *pBoreLine;
int            Extended; 
IGRpoint       ConstraintPoint;
IGRpoint       KeyPoint;
SSObject       **PpObject;
{
  int      ConstraintType = SSNONE;
  int      ElligibleConstraints;
  double   Distance;
  SSObject *pObject2;
  
  /*
   * Extended is only supported for lines
   * NOTE: This is where extended arc support would be handled.
   */
  /* 
  if (Extended && pObject->type != SSLINE)
  {
    ConstraintType = SSNONE;
    goto quit;
  }
   */

  /*
   * We start by computing the distance
   */
  SSBoreLineObjectDistance (pBoreLine, pObject, Extended, &Distance);

  /* 
   * This routine can return more than one type of constaint type.  Before
   * we can return a constaint type, it must be marked elligible in the
   * DPB's elligible constaint mask;  we retrieve that here.
   */
  gr$get_ss_constraints( buffer = &ElligibleConstraints );

  if (Distance < Tolerance) 
  {
    int LocalExtended, Index;
    
    /*
     * This object is close, check if any other object is also close;
     * that would mean that there is a potential intersection. We do it
     * twice, once on regular elements and once on extended elements.
     *
     * PROBLEM!  elements get reordered such that PLastObject is the one
     * we want to intersect and it gets overlooked.
     *
     */
    LocalExtended = Extended; 
    for (Index = 0; Index < 2 && ConstraintType == SSNONE; Index++)
    {
      for ( pObject2 = pObject + 1; 
            pObject2 != PLastObject && ConstraintType == SSNONE; 
            pObject2++)
      {
        if (SSHasMoved ( SSCHECK ))
        {
          /*
           * The mouse has moved, we return a "point on element" constraint
           */
          SSProjectBoreLineOnObject ( pBoreLine, 
                                      pObject, 
                                      Extended,
                                      ConstraintPoint);
          if ( Extended )
          {
            if ( ElligibleConstraints & SSACTIVEONEXELE )
            {
              ConstraintType = SSONXELEMENT;
            }
            else
            {
              ConstraintType = SSNONE;
            }
          }
          else
          {
            ConstraintType = SSONELEMENT;
          }
  
          if ( ElligibleConstraints & SSACTIVEONELE )
          {
            SSSaveLastConstraint ( pObject, 
                                   NULL, 
                                   ConstraintType, 
                                   ConstraintPoint, 
                                   NULL );
            goto quit; /* return with this constraint type */
          }
          else
          {
            ConstraintType = SSNONE;
          }
        }
        
        SSBoreLineObjectDistance ( pBoreLine, 
                                   pObject2,
                                   LocalExtended,
                                  &Distance );

        if (Distance < Tolerance)
        {
          /*
           * We look for an intersection between pObject and pObject2.
           */
          if (SSIntersectObjects ( pObject, 
                                   pObject2,
                                   pBoreLine->point1, 
                                   LocalExtended, 
                                   Tolerance,
                                   ConstraintPoint ))
          {
            *PpObject = pObject2;
            ConstraintType = LocalExtended ? SSXINTERSECT : SSINTERSECT;
            if ( ElligibleConstraints & SSACTIVEINTERSECT )
            {
              SSSaveLastConstraint ( pObject, 
                                     pObject2, 
                                     ConstraintType,
                                     ConstraintPoint,
                                     NULL );
            }
            else
            {
              ConstraintType = SSNONE;
            }
          }
        }
      }
      
      if (LocalExtended || ConstraintType != SSNONE)
      {
        Index = 2;
      }
      else
      {
        LocalExtended = 1;
      }
    }

    if (ConstraintType == SSNONE)
    {
      /*
       * We didn't find any intersection -> are we horizontal/vertical with
       * any key point?
       */
      if (SSRefLock)
      {
        for (pObject2 = pObject + 1; 
             pObject2 != PLastObject && ConstraintType == SSNONE;
             pObject2++)
        {
          if (SSHasMoved ( SSCHECK ))
          {
            /*
             * The mouse has moved, we return a "point on element" constraint
             */
            SSProjectBoreLineOnObject ( pBoreLine, 
                                        pObject, 
                                        Extended, 
                                        ConstraintPoint);
            if ( Extended )
            {
              if ( ElligibleConstraints & SSACTIVEONEXELE )
              {
                ConstraintType = SSONXELEMENT;
              }
              else
              {
                ConstraintType = SSNONE;
              }
            }
            else
            {
              ConstraintType = SSONELEMENT;
            }
  
            if ( ElligibleConstraints & SSACTIVEONELE )
            {
              SSSaveLastConstraint ( pObject, 
                                     NULL,
                                     ConstraintType,
                                     ConstraintPoint,
                                     NULL );
              goto quit; /* return with this constraint type */
            }
            else
            {
              ConstraintType = SSNONE;
            }
          }

          /* check for dual constraint Horizontal */
          ConstraintType = SSCheckHzVt ( pObject2, 
                                         pObject2 + 1, 
                                         Tolerance, 
                                         pBoreLine->point1[0],
                                         pBoreLine->point1[1], 
                                         pBoreLine->point1[2], 
                                         ConstraintPoint,
                                         KeyPoint, 
                                         NULL );
          if (ConstraintType != SSNONE)
          {
            struct IGRpolyline PolyLine;
            double             PolyPoints [6];
            BSrc               Rc;
            long               LocalStatus, one = 1;
            IGRboolean	       on_success = TRUE;
              
            PolyLine.num_points = 2;
            PolyLine.points = PolyPoints;

            ConstraintType = ConstraintType == SSHORIZONTAL
                ? (Extended ? SSONXHORIZONTAL : SSONHORIZONTAL) 
                : (Extended ? SSONXVERTICAL : SSONVERTICAL);

            /*
             * We transform the KeyPoint into the coordinate system of the 
             * reference plane.
             */
            MAptsxform (&LocalStatus, 
                        &one, 
                         SSRefMatrix,
                         KeyPoint,
                        &PolyPoints[0] );
            memcpy ( &PolyPoints [3], &PolyPoints [0], 3 * sizeof ( double ));

            if ( ConstraintType == SSONHORIZONTAL || 
                 ConstraintType == SSONXHORIZONTAL  )
            {
              /*
               * The horizontal line is defined by (x, y) and (x + 1, y)
               */
              PolyPoints [0] += 1.0;
              PolyPoints [3] -= 1.0;
            }
            else
            {
              /*
               * The vertical line is defined by (x, y) and (x, y + 1)
               */
              PolyPoints [1] += 1.0;
              PolyPoints [4] -= 1.0;
            }

            /*
             * We go back to world coordinates and create the B-spline
             */
            MAptsxform ( &LocalStatus, 
                         &one, 
                         SSInvRefMatrix,
                         &PolyPoints[0],
                         &PolyPoints[0] );

            MAptsxform ( &LocalStatus, 
                         &one, 
                          SSInvRefMatrix,
                         &PolyPoints[3],
                         &PolyPoints[3] );

            /*
             * The constraint point is the intersection of the element and the
             * horizontal/vertical line. We need to extend the horizontal/
             * vertical line and in the case of SSONX... we need to extend 
             * the curve as well
             */
            if ( ConstraintType == SSONXHORIZONTAL || 
                 ConstraintType == SSONXVERTICAL )
            {
              struct IGRline Line1, Line2;
              double         U1, U2;

              /*
               * We know that pObject is a line segment -> easy
               */
              Line1.point1 = &PolyPoints [0];
              Line1.point2 = &PolyPoints [3];
              Line2.point1 = pObject->KeyPoints [0];
              Line2.point2 = pObject->KeyPoints [2];
              MA2lnisect ( &LocalStatus, 
                          (struct IGRline_seg *) &Line1, 
                          (struct IGRline_seg *) &Line2, 
                           &Tolerance, 
                            ConstraintPoint, 
                           &U1, 
                           &U2 );
            }
            else
            {
              struct IGRline OriginalLine, ExtendedLine;
              double         FirstPoint[3],
                             SecondPoint[3], 
                             Point1[3], 
                             Point2[3];
              static int    FirstTime = TRUE;
              static struct IGRbsp_curve *pBSpline;

              if (FirstTime)
              {
                short Order = 4;
                long  NumPoles = 7, 
                      NumBoundaries = 0;
                int   Rational = 1;
        
                BSalloccv ( Order, 
                            NumPoles, 
                            Rational,
                            NumBoundaries,
                           &pBSpline,
                           &Rc );
                if (Rc != BSSUCC)
                {
                  ConstraintType = SSNONE;
                  goto quit;
                }
                FirstTime = FALSE;
              }
            
              OriginalLine.point1 = Point1;
              OriginalLine.point2 = Point2;
              memcpy ( Point1, &PolyPoints [0], sizeof ( IGRpoint ) );
              memcpy ( Point2, &PolyPoints [3], sizeof ( IGRpoint ) );
              
              FirstPoint[0] = 
                FirstPoint[1] =
                  FirstPoint[2] = GRDGNLIMITS_MIN_D + 1;

              SecondPoint [0] = 
                SecondPoint [1] =
                  SecondPoint [2] = GRDGNLIMITS_MAX_D - 1;
                
              ExtendedLine.point1 = &PolyPoints [0];
              ExtendedLine.point2 = &PolyPoints [3];
              MAlncbclip ( &LocalStatus, 
                           &OriginalLine,
                            FirstPoint,
                            SecondPoint,
                          (struct IGRline_seg *) &ExtendedLine );
              MApytobc ( &Rc, &PolyLine, pBSpline );

              LocalStatus = SSIntersectCurves ( 
			       pObject->buffers[0].geometry.bspcurve, 
                               pBSpline,
                               pBoreLine->point1,
                               ConstraintPoint );
              if ( !(LocalStatus&1) )
	      {
		/*
		 *  We need to handle the case where this fails. Side effects 
		 *  occur when the two line are parallel and withing locate
		 *  tolerance of one another.  SRH 1/31/94
		 *  Safe fix is use boolean variable and test it later - GMK 02/01/94
		 */
		on_success = FALSE;
              }
            }

            if ( (ElligibleConstraints & SSACTIVEINTERSECT) && on_success )
            {
              SSSaveLastConstraint ( pObject, 
                                     pObject2, 
                                     ConstraintType, 
                                     ConstraintPoint, 
                                     KeyPoint );
            }
            else
            {
              ConstraintType = SSNONE;
            }
            break;
          }
        }
      }

      if ( (ConstraintType == SSNONE) && 
           (ElligibleConstraints & SSACTIVEONELE ))
      {
        /*
         * We didn't find any horizontal/vertical -> it is a point on element
         */
        SSProjectBoreLineOnObject ( pBoreLine, 
                                    pObject, 
                                    Extended, 
                                    ConstraintPoint);
        ConstraintType = Extended ? SSONXELEMENT : SSONELEMENT;
        SSSaveLastConstraint ( pObject, 
                               NULL, 
                               ConstraintType,
                               ConstraintPoint,
                               NULL );
      }
    }
  }

quit:  
  return ConstraintType;
}

end implementation Root;
