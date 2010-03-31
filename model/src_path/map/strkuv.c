/*
  OVERVIEW

  This file contains the API to stroke the UV data if it does not represent the
  true model-space counterpart. 

  NOTES
  
  Helper function for "pwMapXyzCvToUvOfSf".

  HISTORY

  Sanjay   11/20/95    Creation

*/

/* Includes */

#include <stdio.h>
#include <math.h>
#include <alloca.h>         /* System */
#include <memory.h>
#include <malloc.h>

#include "igrtypedef.h"
#include "igr.h"        
#include "bs.h"             /* BS Math */
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bsvalues.h"

#include "PWminimum.h"
#include "PWgmdata.h"       /* Pathway */
#include "PWerror.h"

/* Prototypes */

#include "bssfeval.h"
#include "bsprptonsf.h"     /* BS math */
#include "bssfptseval.h"
#include "bsdistptpts.h"

#include "PWapi/strkuv.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/partol.h"   /* Pathway */
#include "PWapi/inspts.h"

/* Internal Macros */

#define TEST_PARAM  0.5


/*
  ABSTRACT

  Strokes the given uv data, if it does not represent the given xyz data on the
  surface. 

  DESCRIPTION

  Stroking is a recursive process and is done by taking minimum distance point
  from the mid point of a segment into consideration. Only if the distance is
  greater than the input tolerance a point is inserted. An effort has been made
  to take care of across-the-seam conditions. 

  ARGUMENTS

  p_sf           - I : Surface geometry
  num_pts        - I : Number of points
  p_uvpts        - I : Points in the parametric space of the surface.
  p_xyzpts       - I : Points in the model-space of the surface.

  xyztol         - I : Minimum distance tolerance

  num_outpts     - O : Number of output points after stroking
  p_outuvpts     - O : Stroked points in the parametric space of the surface.
  p_outxyzpts    - O : Stroked points in the model space of the surafce.

  NOTES

  All the memory for the output will be allocated by this rotuine. It is the
  responsibility of the caller to de-allocate the memory. One can de-allocate
  the memory by a single "free()" function call.

  KEYWORDS

  Helper Funciton, Internal API.

  CAVEATS

  It takes the mid point of the segment into consideration while computing the
  deviation. It is quite possible that this point may be with in tolerance but
  not the whole segment.

  HISTORY

  Sanjay   11/20/95    Creation
  Aditya   04/10/96    Improvement added for ACIS-EMS xlator. If the
                       xyz points are away from their correspoinding uv
                       pts by more than chttol move the xyz points onto
                       the surface. This will result in a better xyz cv,
                       faster processing as the segments are closer to the
                       surface.

*/

PWresult pwStrokeUvdataIfNeeded
(
  struct IGRbsp_surface *p_sf,
  int num_pts,
  PWpoint2d *p_uvpts,
  PWpoint *p_xyzpts,

  double xyztol,

  int *num_outpts,
  PWpoint2d **p_outuvpts,
  PWpoint **p_outxyzpts
)
{
  /* Status stuff */

  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;

  int inx=0, uvarray_size=0, xyzarray_size=0, num_seam_pts=0;
  PWboolean status=TRUE, onsrf=FALSE, ins_pt=FALSE, seam_utest=FALSE; 
  PWboolean seam_vtest=FALSE;
  PWboolean uv_already_exists = FALSE, avg_v=TRUE, avg_u=FALSE, end_seg=FALSE;

  double sqxyztol=0, *xyzseg=NULL, *uvseg=NULL, uvpt[4], xyzpt[6], prev_dist=0; 
  double sqdist=0, test_band=0, test_min_u=0, test_max_u=0, test_min_v=0; 
  double bastol=0, exist_uv[2][2], uvdist=0, test_max_v=0;
 
  int bufsize=0;
  double *p_txyzpts=NULL, *p_tuvpts=NULL, minpar=0, u=0, v=0, uvtol=0;
  PWpoint minpt={0,0,0}, sfpt[1];


  /* Initialize the output. */

  *num_outpts = 0;
  *p_outxyzpts = NULL;
  *p_outuvpts = NULL;

  test_band = 0.90;
  test_min_u = (1 - test_band) / 2.0;
  test_max_u = 1 - test_min_u;
  test_min_v = test_min_u;
  test_max_v = test_max_u;

  uvarray_size = xyzarray_size = num_pts;

  BSEXTRACTPAR (&BSmsg, BSTOLLENVEC, bastol);
  sqxyztol = xyztol * xyztol;
  uvtol = pwGetParTolSf (p_sf, xyztol);

  /*
   * It is assumed that the end points of the incoming linestring lie on the 
   * surface. The uvlinstring's segments are evaluated at their mid points. 
   * If this mid point is away from the corresponding model space line segment 
   * by more than chord_height tolerance, a point is inserted at the middle of
   * the model space line_segment. This process is repeated until each line 
   * segment is within chord_height tolerance of its uv counterpart.
   *
   * If the surface is physically closed in one or both directions, the 
   * following check is made while crossing over the seam line. This is done 
   * to avoid infinite looping conditions:
   *
   *  If the end points of uv_linesegment lie outside the test_band, in the 
   *  physically closed direction and the new point inserted happens to be 
   *  lie outside test_band, it is assumed the linesegmentis crossing over 
   *  the seam. In such a situation, the linesegment is sikkped for further 
   *  checking and the control goes to the next segment.
   * 
   */

  bufsize = num_pts + 10;
  *num_outpts = num_pts;

  p_txyzpts = (double *) malloc (bufsize * sizeof (PWpoint));
  p_tuvpts = (double *) malloc (bufsize * sizeof (PWpoint2d));
  OnErrorState (!p_txyzpts || !p_tuvpts, PWsts, SetError (PW_K_Pathway, 
                PW_K_DynamicMemory), wrapup);
   
  memcpy (p_txyzpts, p_xyzpts, num_pts * sizeof (PWpoint));
  memcpy (p_tuvpts, p_uvpts, num_pts * sizeof (PWpoint2d));

 /*
  * Check if the evaluated uv pts and the coresponding xyz points are within
  * cht themselves. If they are not them make sure that the xyz points are
  * moved onto the surface. Without this we will have only the new points
  * that are inserted on the surface and not the original pts might still
  * be away from the sf by >chttol.
  */
  for(inx=0; inx<num_pts; inx++)
  {
    
    BSsfeval (p_sf, p_tuvpts[inx*2], p_tuvpts[inx*2+1], 0, sfpt, &BSmsg);
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_BspMath, 
                  PW_K_Internal), wrapup);
   
	if(sqxyztol < BSdistptpts( &BSmsg, sfpt[0], (double *)&p_txyzpts[inx*3]))
	{
	   memcpy(&p_txyzpts[inx*3], sfpt[0], sizeof(PWpoint));
	}
  }

  inx = 0;
  prev_dist = MAXDOUBLE;

  do
  {
    /*
     * get this uv and xyz segment. 
     */
    xyzseg = &p_txyzpts[inx*3];
    uvseg = &p_tuvpts[inx*2];

    memcpy (exist_uv[0], uvseg, 2 * sizeof(double));
    memcpy (exist_uv[1], &uvseg[2], 2 * sizeof(double));

    seam_utest = seam_vtest = FALSE;

    if (p_sf->u_phy_closed && fabs (uvseg[2] - uvseg[0]) > test_band) 
    {
      /*
       * This parametric segment is running across the U-seam of the surface.
       */

      seam_utest = TRUE;
    }

    if (p_sf->v_phy_closed && fabs (uvseg[3] - uvseg[1]) > test_band) 
    {
      /*
       * This parametric segment is running across the V-seam of the surface.
       */

      seam_vtest = TRUE;
    }

    /*
     * get a middle point of the uv segment, evaluate in xyz and get the 
     * minimum distance from this point to the xyz segment.
     */
    uvpt[0] = uvseg[0] + TEST_PARAM * (uvseg[2] - uvseg[0]);
    uvpt[1] = uvseg[1] + TEST_PARAM * (uvseg[3] - uvseg[1]);

    BSsfeval (p_sf, uvpt[0], uvpt[1], 0, (IGRpoint *)xyzpt, &BSmsg);
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_BspMath, 
                  PW_K_Internal), wrapup);

    sqdist = pwMinDistSqPtSeg (xyzpt, xyzseg, &xyzseg[3], minpt, &minpar);

    if ((sqdist > sqxyztol) && (fabs(sqdist - prev_dist) > bastol))
    {
      /*
       * The minimum distance from the evaluated xyz point to the xyz segment
       * is greater than the tolerance. So, probably we might have to insert
       * a point, if it is not a point on seam. 
       */

      if (*num_outpts >= (bufsize - 2))
      {
        /*
         * Allocate more memory for xyz and uv points.
         */

        bufsize += 10;
       
        p_txyzpts = (double *) realloc (p_txyzpts, bufsize * sizeof (PWpoint)); 
        p_tuvpts = (double *) realloc (p_tuvpts, bufsize * sizeof (PWpoint2d)); 
      }

      /*
       * get a middle point of the xyz segment and get corresponding uv values.
       * This is the uv point to insert. Evaluate the surface at this uv value 
       * to get the exact point on the surface.
       */ 
      uv_already_exists = FALSE;

      prev_dist = sqdist;
      /*******/
      xyzpt[X] = xyzseg[X] + 0.5 * (xyzseg[3+X] - xyzseg[X]);
      xyzpt[Y] = xyzseg[Y] + 0.5 * (xyzseg[3+Y] - xyzseg[Y]);
      xyzpt[Z] = xyzseg[Z] + 0.5 * (xyzseg[3+Z] - xyzseg[Z]);

      status = BSprptonsf (&BSmsg, p_sf, xyzpt, &uvpt[0], &uvpt[1], &onsrf);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_BspMath, 
                    PW_K_Internal), wrapup);
          
      BSsfeval (p_sf, uvpt[0], uvpt[1], 0, (IGRpoint *)xyzpt, &BSmsg);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_BspMath, 
                    PW_K_Internal), wrapup);
  
      /***********/
      ins_pt = TRUE;

      if (seam_utest && ((uvpt[0] >= 0. && uvpt[0] <= test_min_u) ||
                         (uvpt[0] >= test_max_u && uvpt[0] <= 1.0))) 
      {
        /*
         * Evaluated point is on the U-seam. No need to insert the point.
         */
 
        ins_pt = FALSE;
      }

      if (ins_pt && seam_vtest && ((uvpt[1] >= 0. && uvpt[1] <= test_min_v) ||
                                   (uvpt[1] >= test_max_v && uvpt[1] <= 1.0))) 
      {
        /*
         * Evaluated point is on the V-seam. No need to insert the point.
         */
 
        ins_pt = FALSE;
      }

      uv_already_exists = FALSE;

      if(ins_pt)
      {
        /*
         * Need to insert a point. A final check, check to see whether this 
         * point is closure to end points of the uv segment under consider-
         * ation. If not we need to insert a point.
         */

        uvdist = pwDistPtPt2d (exist_uv[1], uvpt);

        if(uvdist < uvtol) 
          uv_already_exists = TRUE;
        else
        {
          uvdist = pwDistPtPt2d (exist_uv[0], uvpt);
          if(uvdist < uvtol) 
            uv_already_exists = TRUE;
        }
      }

      if (ins_pt && !uv_already_exists)
      {
        /* Need to insert a point. So, insert the point. */

        pwInsertPts2d (1, (PWpoint2d *) &uvpt[0], inx+1, *num_outpts, 
                       (PWpoint2d *) p_tuvpts);
        pwInsertPts (1, (PWpoint *) &xyzpt[0], inx+1, *num_outpts, 
                       (PWpoint *) p_txyzpts);
        (*num_outpts) ++;
      } 

      else if (!uv_already_exists)

      {
        num_seam_pts = 0;

        /*
         * It may be possible that the segement under consideration is the 
         * first or the last segment. In such a case only one point needs to 
         * be inserted, either at the begin or at the end.
         */

        if (p_sf->u_phy_closed && !p_sf->v_phy_closed)
        {
          /*
           * Surface is closed in U-direction only.
           */

          u = 0.0; v = 0.0;
          avg_v = TRUE; end_seg = FALSE;

          if (!inx)
          {
            if ((fabs(uvseg[U] - 0.) < uvtol) ||
                (fabs(uvseg[U] - 1.0) < uvtol))  
              end_seg = TRUE;
          }
          else if (inx == *num_outpts - 2)
          {
            if ((fabs(uvseg[U+2] - 0.) < uvtol) ||
                (fabs(uvseg[U+2] - 1.0) < uvtol))  
              end_seg = TRUE;
          } 
   
          if (end_seg)
          {
            u = uvpt[U] < 0.5 ? 0. : 1.0;
            if (!inx)
              uvseg[U] = u;
            else
              uvseg[2+U] = u;
          } 
          else
          {
            u = uvseg[U] < 0.50 ? 0. : 1.0;

            if (fabs(uvseg[U] - u) > uvtol)
            {
              uvpt[num_seam_pts*2] = u;
              num_seam_pts++;
            }
            else
            {
              uvseg[U] = u;
              v = uvseg[V];
              avg_v = FALSE;
            }

            u = uvseg[U] < 0.50 ? 1. : 0.0;

            if (fabs(uvseg[2+U] - u) > uvtol)
            {
              uvpt[num_seam_pts*2] = u;
              num_seam_pts++;
            }
            else
            {
              uvseg[2+U] = u;
              v = uvseg[2+V];
              avg_v = FALSE;
            }

            if (num_seam_pts)
            {
              if (avg_v)
               uvpt[V] = uvpt[2+V] = (uvseg[V] + uvseg[2+V])/2.;
              else
               uvpt[V] = uvpt[2+V] = v;
            }
          } 
        } 

        if (p_sf->v_phy_closed && !p_sf->u_phy_closed)
        {
          /*
           * Surface is closed in V-direction only.
           */

          u = 0; v = 0;
          avg_u = TRUE; 
          end_seg = FALSE;

          if (!inx)
          {
            if ((fabs(uvseg[V] - 0.) < uvtol) ||
                (fabs(uvseg[V] - 1.0) < uvtol))  
              end_seg = TRUE;
          }
          else if (inx == *num_outpts - 2)
          {
            if ((fabs(uvseg[V+2] - 0.) < uvtol) ||
                (fabs(uvseg[V+2] - 1.0) < uvtol))  
              end_seg = TRUE;
          } 
   
          if (end_seg)
          {
            v = uvpt[V] < 0.5 ? 0. : 1.0;
            if (!inx)
              uvseg[V] = v;
            else
              uvseg[2+V] = v;
          }
          else
          {
            v = uvseg[V] < 0.50 ? 0.0 : 1.0;

            if ( fabs(uvseg[V] - v) > uvtol )
            {
              uvpt[num_seam_pts*2+1] = v;
              num_seam_pts++;
            }
            else
            {
              uvseg[V] = v;
              u = uvseg[U];
              avg_u = FALSE;
            }

            v = uvseg[V] < 0.50 ? 1. : 0.0;

            if ( fabs(uvseg[2+V] - v) > uvtol )
            {
              uvpt[num_seam_pts*2+1] = v;
              num_seam_pts++;
            }
            else
            {
              uvseg[2+V] = v;
              u = uvseg[2+U];
              avg_u = FALSE;
            }

            if (num_seam_pts)
            { 
              if (avg_u)
                uvpt[U] = uvpt[2+U] = (uvseg[U] + uvseg[2+U])/2.;
              else
                uvpt[U] = uvpt[2+U] = u;
            }
          } 
        } /* if (p_sf->v_phy_closed && !p_sf->u_phy_closed) */

        if (num_seam_pts)
        {
          /*
           * There are some points to insert at the seams. Insert them.
           */

          BSsfptseval (p_sf, num_seam_pts, uvpt, xyzpt, &BSmsg);
          OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_BspMath, 
                        PW_K_Internal), wrapup);

          pwInsertPts2d (num_seam_pts, (PWpoint2d *) &uvpt[0], inx+1, 
                         *num_outpts, (PWpoint2d *) p_tuvpts);
          pwInsertPts (num_seam_pts, (PWpoint *) &xyzpt[0], inx+1, *num_outpts, 
                       (PWpoint *) &p_txyzpts[0]);

          (*num_outpts) += num_seam_pts;
          inx += (num_seam_pts+1);
        } 

      } /* else for if (ins_pt) */

      else

      {
        inx++;
        prev_dist = MAXDOUBLE;
      }

    } /* if (sqdist > sqxyztol) */

    else

    {
      inx++;
      prev_dist = MAXDOUBLE;
    }

  } while (inx < ((*num_outpts)-1));

  if (*num_outpts != num_pts)
  {
    p_txyzpts = (double *) realloc (p_txyzpts, 
                                    (*num_outpts) * sizeof (PWpoint));
    p_tuvpts = (double *) realloc (p_tuvpts, 
                                   (*num_outpts) * sizeof (PWpoint2d));
    OnErrorState (!p_txyzpts || !p_tuvpts, PWsts, SetError (PW_K_Pathway, 
                  PW_K_DynamicMemory), wrapup);
  }

  *p_outxyzpts = (PWpoint *) &p_txyzpts[0];  
  *p_outuvpts = (PWpoint2d *) &p_tuvpts[0];

wrapup:
 
  if (IsError (PWsts))
  {
    if (p_txyzpts) free (p_txyzpts);
    if (p_tuvpts) free (p_tuvpts);
    *num_outpts = 0; *p_outxyzpts = NULL; *p_outuvpts = NULL;
  } 

  PW_Wrapup (PWsts, "pwStrokeUvdataIfNeeded");
  return PWsts;
} 
