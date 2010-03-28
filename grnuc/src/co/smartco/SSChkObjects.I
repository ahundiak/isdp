/*

Name
  SSChkObjects.I

Description
  This file contains the code for determining which constraint/keypoint
  should be selected given the current cursor and list of elements/
  keypoints.  

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
#include "bsmkvec.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"
#include "mapytobc.h"
#include "maang3pt.h"
#include "wl.h"


#define SS_NO_LOCK        (0)
#define SS_LOCK_90        (1)
#define SS_LOCK_180       (2)
#define SS_LOCK_270       (3)
#define SS_LOCK_360       (4)



%safe
static int                 FirstTime = TRUE;
static struct IGRpolyline  PolyLine;
static struct IGRbsp_curve *PNewElement = NULL;
static struct IGRbsp_curve bs_curve;
static double              bs_buffer [40];
%endsafe

/*

Name
  SSCheckObjects

Abstract
  This function determining which constraint/keypoint should be selected 
  given the current cursor and list of elements/ keypoints.  It also takes
  into account the DPB's active constainst mask.

Synopsis
  int SSCheckObjects ( window, x, y, z, PConstraintType )

Description
  OM_S_OBJID  window          (IN)   The window we got the point from
  double      x, y, z         (IN)   The current data point (world coordinates)
  int        *PConstraintType (OUT)  The constraint type found

Return Value
   OM_S_SUCCESS  -  Success
   OM_E_ABORT    -  unable to generate the geometry of a new element

Notes

Index

Keywords

History
  06/28/93 : Shelley R. Heard : Implemented from Henry's prototype for
                                GRNUC 2.4 build.

 */
int SSCheckObjects ( window, x, y, z, PConstraintType )
OM_S_OBJID window          /* The window we got the point from          IN  */;
double     x, y, z         /* The current data point                    IN  */;
int        *PConstraintType/* The constraint type                       OUT */;
/*
 * This routine hilites the relevant potential constraint that can
 * be found using the current data point among the objects that we 
 * have in our list. This routine has basically two loops: one outer
 * loop on the known elements and one inner loop on the constraints
 * we want to check. When a constraint is recognized the object makes
 * it to the beginning of the list. This gives a preference to constraints
 * on recently selected elements. It also prevents often selected elements
 * from going out of the list.
 * Note that before the double loop we check if we can recognize a constraint
 * on the newly created element.
 */
{
  int            i;
  int            status = OM_S_SUCCESS;
  long           msg;
  double         Tolerance;
  SSObject       *PObject = NULL;
  IGRpoint       ConstraintPoint, KeyPoint, FirstPoint, LastPoint;
  struct IGRline BoreLine;
  int            ConstraintsMask;

  *PConstraintType = SSNONE;
  BoreLine.point1 = FirstPoint;
  BoreLine.point2 = LastPoint;
  SSGetWindowTolerance ( window, x, y, z, &Tolerance, NULL, &BoreLine );
  status = gr$get_ss_constraints ( buffer = &ConstraintsMask );
  /* 
   * set whether or not to turn on text during display of constraints
   * SRH 09/12/93
   */
  SSDisplayMode = ( ConstraintsMask &  SSTEXTDISPLAYED );

  /*
   * We loop on each object to find out if it matches one of the constraints 
   * we want to look for.
   */
  for (i = 0; i < SSnb_objects; i++)
  {
    if (SSHasMoved ( SSCHECK ))
      break;
 
    /*
     * We loop on each constraint we want to recognize.
     * Precidence:
     *  Keypoint
     *  Intersection
     *  On Element
     *  
     */
    if ( ConstraintsMask & SSACTIVEKEYPOINT  )
    {
      *PConstraintType = SSCheckCoincident ( &SSObjects [i], 
                                             &SSObjects [SSnb_objects],
                                              Tolerance, 
                                             &BoreLine, 
                                              ConstraintPoint,
                                              KeyPoint, 
                                              NULL );
    }
    if (*PConstraintType != SSNONE)
    {
      break;
    }
    if ( ConstraintsMask & SSACTIVEONELE     || 
         ConstraintsMask & SSACTIVEONEXELE   || 
         ConstraintsMask & SSACTIVEINTERSECT   )
    {
      *PConstraintType = SSCheckOnElement ( &SSObjects [i],
                                            &SSObjects [SSnb_objects], 
                                             Tolerance, 
                                            &BoreLine,
                                             FALSE,
                                             ConstraintPoint,
                                             KeyPoint, 
                                            &PObject );
    }
    if (*PConstraintType != SSNONE)
    {
      break;
    }
  }
  
  if (*PConstraintType == SSNONE)
  {
    double                d_num_dits;
    int                   i_num_dits;
    int                   i_x, i_y, flag;
    WLuint32              l_window; 
    int                   region_empty = FALSE;

    /*
     * Let's check with the R-tree if the mouse is on any object.  We only
     * bother look if the cursor is within dit tolerance of a "lit dit".
     */
    WLmouse_win_position( &l_window, 
                          &i_x, 
                          &i_y, 
                          &flag); 

    gr$get_dit_tolerance ( buffer = &d_num_dits );
    i_num_dits = (int) d_num_dits;
    status = WLis_region_empty( l_window,
                                i_x,
                                i_y,
                                i_num_dits, 
                               &region_empty);
    if ( ! region_empty )
    {
      SSFindObject ( window, x, y, z, PConstraintType );
    }
    /*
     * We want to make sure that we have the "best" constraint. 
     */
    if (*PConstraintType != SSNONE)
    {
      if ( ConstraintsMask & SSACTIVEKEYPOINT  )
      {
        *PConstraintType = SSCheckCoincident ( &SSObjects [0], 
                                               &SSObjects [SSnb_objects],
                                                Tolerance, 
                                               &BoreLine,
                                                ConstraintPoint,
                                                KeyPoint,
                                                NULL );
      }
      if (*PConstraintType == SSNONE)
      {  
        if ( ConstraintsMask & SSACTIVEONELE     ||
             ConstraintsMask & SSACTIVEONEXELE   || 
             ConstraintsMask & SSACTIVEINTERSECT   )
        {
          *PConstraintType = SSCheckOnElement ( &SSObjects [0], 
                                                &SSObjects [SSnb_objects], 
                                                 Tolerance, 
                                                &BoreLine, 
                                                 FALSE, /* extend */
                                                 ConstraintPoint, 
                                                 KeyPoint,
                                                &PObject );
        }
      }
    }    
    else
    {
      for (i = 0; i < SSnb_objects; i++)
      {
        
        if (SSHasMoved ( SSCHECK ))
        {
          break;
        }
    
        if (ConstraintsMask & (SSACTIVEHORIZONTAL | SSACTIVEVERTICAL))
        {
          *PConstraintType = SSCheckHzVt ( &SSObjects [i], 
                                           &SSObjects [SSnb_objects], 
                                            Tolerance, 
                                            x, 
                                            y, 
                                            z, 
                                            ConstraintPoint,
                                            KeyPoint,
                                            NULL );
        }
        if (*PConstraintType != SSNONE)
        {
          break;
        }

        if ( ConstraintsMask & SSACTIVEONELE     ||
             ConstraintsMask & SSACTIVEONEXELE   || 
             ConstraintsMask & SSACTIVEINTERSECT   )
        {
          *PConstraintType = SSCheckOnElement ( &SSObjects [i], 
                                                &SSObjects [SSnb_objects], 
                                                 Tolerance, 
                                                &BoreLine, 
                                                 TRUE, /* extend */
                                                 ConstraintPoint,
                                                 KeyPoint,
                                                &PObject );
        }
        if (*PConstraintType != SSNONE)
        {
          break;
        }
      }
    }
  }

  /*
   * Check if we can recognize a constraint on the new element being created.
   */
  if ( (SSNewElementType != SSNONE) && 
       ( *PConstraintType == SSNONE || *PConstraintType == SSONELEMENT ) )
  {
    long                       loc_msg;
    SSObject                   NewObjects [2];
    int                        old_constraint_type;
    
    old_constraint_type = *PConstraintType;

    if (FirstTime)
    {
      PolyLine.num_points = 2;
      PolyLine.points = SSNewPoints [0];

      /* big enough for arc or line */
      bs_curve.order          =  4;
      bs_curve.periodic       =  1;
      bs_curve.non_uniform    =  1;
      bs_curve.num_poles      =  7;
      bs_curve.poles          = &bs_buffer[0];
      bs_curve.num_knots      =  11;
      bs_curve.knots          = &bs_buffer[21];
      bs_curve.rational       =  1;
      bs_curve.weights        = &bs_buffer[32];
      bs_curve.planar         =  1;
      bs_curve.phy_closed     =  0;
      bs_curve.num_boundaries =  0;
      bs_curve.bdrys          =  NULL;

      PNewElement = &bs_curve;
      FirstTime = FALSE;
    }

    switch (SSNewElementType)    
    {
      case SSLINE: 
      {
        /* 
         * Check for horizontal/vertical
         */
        NewObjects [0].type = SSLINE;
        NewObjects [0].NbKeyPoints = 1; 
        memcpy ( &NewObjects [0].KeyPoints [0] [0],  
                 &SSNewPoints [0] [0], 
                  sizeof ( IGRpoint ) );
        NewObjects [0].KeyPointActive[0] = TRUE;
        NewObjects [0].NbBuffers = 0;
        NewObjects [0].buffers = NULL;
        NewObjects [0].grid.objid = NULL_OBJID;

        if (  ConstraintsMask & (SSACTIVEHORIZONTAL | SSACTIVEVERTICAL) &&
            *PConstraintType != SSONELEMENT  )
        {
          *PConstraintType = SSCheckHzVt ( &NewObjects [0], 
                                           &NewObjects [1], 
                                            Tolerance, 
                                            x,
                                            y, 
                                            z, 
                                            ConstraintPoint, 
                                            KeyPoint, 
                                            NULL );
        }

        if (*PConstraintType != SSNONE && *PConstraintType != SSONELEMENT )
        {
            status = OM_S_SUCCESS;
            goto wrapup;
        }

        /*
         * No luck for horizontal/vertical, we now check for Parallel and
         * Perpendicular.
         * 
         * Generate the curve for the new element
         */
        SSNewPoints [1] [0] = NewObjects [0].KeyPoints [1] [0] = x;
        SSNewPoints [1] [1] = NewObjects [0].KeyPoints [1] [1] = y;
        SSNewPoints [1] [2] = NewObjects [0].KeyPoints [1] [2] = z;

        NewObjects [0].NbKeyPoints = 2; 
        MApytobc ( &loc_msg, &PolyLine, PNewElement );

        if (loc_msg & 1)
        {
          struct DPele_header Buffer;
            
          NewObjects [0].NbBuffers = 1;
          NewObjects [0].buffers = &Buffer;
          Buffer.geometry.bspcurve = PNewElement;
          if ( *PConstraintType != SSONELEMENT  )
          {
            *PConstraintType = SSCheckDirection ( &NewObjects [0], 
                                                  &NewObjects [1], 
                                                   Tolerance, 
                                                   x,
                                                   y,
                                                   z,
                                                   ConstraintPoint,
                                                   KeyPoint,
                                                   NULL );
            if (*PConstraintType != SSNONE)
            {
              status = OM_S_SUCCESS;
              goto wrapup;
            }
          }

          /*
           * Check for tangency with other arcs/circles even if we already
           * have an ON ELEMENT constraint.  This is the one case we override
           * ON ELEMENT.  SRH 9/21/93
           */
          if ( ConstraintsMask & SSACTIVETANGENT )
          {
            *PConstraintType = SSCheckTangency ( &NewObjects [0],
                                                 &NewObjects [1], 
                                                  Tolerance,
                                                  x,
                                                  y,
                                                  z,
                                                  ConstraintPoint,
                                                  KeyPoint,
                                                  NULL );
          }
          /*
           * We may have overriden the On Element constraint; if SSCheckTangency
           * returns SSNONE and if *PConstraintType was SSONELEMENT, then we
           * reset it.
           */
          if (*PConstraintType == SSNONE && old_constraint_type == SSONELEMENT )
          {
            /* then we overwrote and need to reset it */
             *PConstraintType = SSONELEMENT; 
          }

          if (*PConstraintType != SSNONE)
          {
            status = OM_S_SUCCESS;
            goto wrapup;
          }
        }      
        break;
      }
      
      case SSARC:
      {
        int    lock_flag = SS_NO_LOCK;
        double angles[3];
        
        /* 
         * added at last minute (9/28/93) for Place Profile arc sweep lock 
         * support; we utilize the SSNewObject1/2 globals as "ghost" elements
         */
        SSNewObject1.type = SSARC;
        SSNewObject1.NbKeyPoints = 3; /* we ommit the midpoint */

        /*
         * here we expect SSNewPoints[0] to be the start pt and SSNewPoints[1]
         * to be the center point; SSNewPoints[2] is the cursor pt/end pt 
         */
        memcpy ( SSNewObject1.KeyPoints[SSARC_ENDPT1], 
                 SSNewPoints[0], 
                 sizeof (IGRpoint) );

        memcpy ( SSNewObject1.KeyPoints[SSARC_CENTER], 
                 SSNewPoints[1], 
                 sizeof (IGRpoint) );

        SSNewObject1.KeyPoints [SSARC_ENDPT2] [0] = SSNewPoints [2] [0] = x;
        SSNewObject1.KeyPoints [SSARC_ENDPT2] [1] = SSNewPoints [2] [1] = y;
        SSNewObject1.KeyPoints [SSARC_ENDPT2] [2] = SSNewPoints [2] [2] = z;

        SSNewObject1.KeyPointActive [SSARC_ENDPT1] = TRUE;
        SSNewObject1.KeyPointActive [SSARC_CENTER] = FALSE;
        SSNewObject1.KeyPointActive [SSARC_ENDPT2] = FALSE;

        SSNewObject1.NbBuffers = 0;
        SSNewObject1.buffers = NULL;
        SSNewObject1.grid.objid = NULL_OBJID;

        /*
         * Since NO Keypoints are active don't wory about vertical / horizontal.
         * we check for Parallel and Perpendicular for the two vectors defined
         * by <startpt,centerpt> and <centerpt,cursorpt>.  If these are close
         * to 90,180,270 - we constrain with prependicular (or colinear in the
         * case of 180).  This is done by measuring the angle by 3 points and
         * taking the compliment when the SSNewFlag is set to 0;
         */
        if ( MAang3pt( &msg,
                        SSNewObject1.KeyPoints [SSARC_ENDPT1], 
                        SSNewObject1.KeyPoints [SSARC_CENTER], 
                        SSNewObject1.KeyPoints [SSARC_ENDPT2],
                        angles ) )
        {
          angles[0] = (SSNewFlag) ? angles[0] : (2 * M_PI) - angles[0];        
        }
        else
        {
          status = OM_E_ABORT;
          goto wrapup;
        }

        if ( IS_NEAR_90( angles[0]) )
        {
          /*
           * 90 degree lock - perpendicular
           */
          lock_flag = SS_LOCK_90;
          *PConstraintType = SSCARDINAL90; 

        } 
        else if ( IS_NEAR_180( angles[0]) )
        {
          /*
           * 180 degree lock - colinear
           */
          lock_flag = SS_LOCK_180;
          *PConstraintType = SSCARDINAL180; 
        } 
        else if ( IS_NEAR_270( angles[0]) )
        {
          /*
           * 270 degree lock - perpendicular
           */
          lock_flag = SS_LOCK_270;
          *PConstraintType = SSCARDINAL270;
        }
        else if ( IS_NEAR_360( angles[0]) )
        {
          /*
           * 360 degree lock 
           */
          lock_flag = SS_LOCK_360;
          *PConstraintType = SSCARDINAL180; /* yes, on purpose! */
        }
        /*
         *  get key points and constraint points for display elements
         */
        if ( lock_flag )
        {
          IGRpoint lock_pt;
          status = ssget_arc_lock_pt( 
                     lock_flag,
                     SSNewObject1.KeyPoints [SSARC_CENTER], 
                     SSNewObject1.KeyPoints [SSARC_ENDPT1], 
                     SSNewObject1.KeyPoints [SSARC_ENDPT2],
                     lock_pt );
          if (!(status&1))
          {
            status = OM_E_ABORT;
            *PConstraintType = SSNONE;
            goto wrapup;
          }
          /* Save last constraint info */
          SSSaveLastConstraint ( &SSNewObject1,
                                  NULL, 
                                  *PConstraintType,
                                  lock_pt,
                                  lock_pt );
        }

        /*
         * We may have overriden the On Element constraint; if we have a
         * returns SSNONE and if *PConstraintType was SSONELEMENT, then we
         * reset it.
         */
        if ( *PConstraintType == SSNONE && old_constraint_type == SSONELEMENT )
        {
          /* then we overwrote it and need to reset it */
          *PConstraintType = SSONELEMENT; 
        }

        if (*PConstraintType != SSNONE)
        {
          status = OM_S_SUCCESS;
          goto wrapup;
        }
        break;
      }
      
      case SSCIRCLE:
      {
        break;
      }
    }
  }

wrapup:

  return status;  
}

/*
 *           cp|   .
 *            -+-
 *             |
 *              \
 *               \ v2
 *                \
 *                 \    v90
 *      .         - o --------> .
 *                ^ ^
 *                | |
 *                r |v1
 *                | |
 *                | |
 *                v |
 *                _ .
 *
 */
int ssget_arc_lock_pt( lock_flag, cnt, e1, cp, e2 )
  int lock_flag; /* IN  - should be 90/180/270 only */
  double *cnt;   /* IN  - center point of arc       */
  double *e1;    /* IN  - start point on arc        */
  double *cp;    /* IN  - cursor point              */
  double *e2;    /* OUT - actual lock point on arc  */
{
  double radius = 0.0;
  BSrc   bsrc; 
  int    rc = MSFAIL; /* being pessimistic here ... */
  IGRvector v1, v2, normal, v90;

  radius = BSdistptpt( &bsrc, cnt, e1 );

  BSmkvec ( &bsrc, v1, e1, cnt ); 
  if ( bsrc != BSSUCC ) { goto wrapup; }

  if ( lock_flag == SS_LOCK_90 || lock_flag == SS_LOCK_270 )
  {
    BSmkvec ( &bsrc, v2, cnt, cp );
    if ( bsrc != BSSUCC ) { goto wrapup; }

    if ( !BScrossp ( &bsrc, v1, v2, normal ) )      { goto wrapup; }
    if ( !BScrossp ( &bsrc, normal, v1, v90 ) )     { goto wrapup; }
    if ( !BSnorvec ( &bsrc, v2 ) )                  { goto wrapup; }
    if ( !BSnorvec ( &bsrc, normal ) )              { goto wrapup; }
    if ( !BSnorvec ( &bsrc, v90 ) )                 { goto wrapup; }
  }

  if ( !BSnorvec ( &bsrc, v1 ) )                    { goto wrapup; }


  rc = MSSUCC; /* OK, now we're optimistic ... */

  if ( lock_flag == SS_LOCK_90 || lock_flag == SS_LOCK_270 )
  {
    e2[0] = cnt[0] + ( radius * v90[0] );
    e2[1] = cnt[1] + ( radius * v90[1] );
    e2[2] = cnt[2] + ( radius * v90[2] );
  }
  else if ( lock_flag == SS_LOCK_180 )
  {
    e2[0] = cnt[0] + ( radius * v1[0] );
    e2[1] = cnt[1] + ( radius * v1[1] );
    e2[2] = cnt[2] + ( radius * v1[2] );
  }
  else if ( lock_flag == SS_LOCK_360 )
  {
    e2[0] = e1[0];
    e2[1] = e1[1];
    e2[2] = e1[2];
  }
  
wrapup:
  return  rc;
}

end implementation Root;
