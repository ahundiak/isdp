/* Includes */

#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include <memory.h>

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"

#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "igr.h"

/* Prototypes */

#include "bsproj0.h"
#include "bsxln.h"

#include "PWapi/conicbnds.h"
#include "PWapi/normvec.h"
#include "PWapi/mkvec.h"
#include "PWapi/lenvec.h"
#include "PWapi/dotp.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/rngbx.h"
#include "PWapi/memfunc.h"

/*
  DESCRIPTION
 
    Given the axis of the cylinder, a point on axis and the range box it 
    returns two points on the axis which will bound the cylinder which 
    will just enclose the given range box in the axis direction. The points
    returned are in the direction of the axis.

  NOTES

    All the memory must be allocated by the caller for the output.
*/

PWresult pwGetBoundsOfCylinder
(
  PWrange rngbx,
  PWpoint axispt,
  PWvector axisvec,
  
  PWpoint base_center,
  PWpoint height_center
)
{
  PWresult   retval;
  int        ii=0;
  double     inf_line[2][3];
  PWvector   naxisvec;
  PWpoint    rngpts[8], projpts[8], maxpt, minpt;
  BSrc       rc;

  retval = PW_K_Success; 

  /*
   * Taking axis point and axis vector an infinite line is constructed. 
   * Actually two points on the infinite line is calculated which is used 
   * by the math function to define an infinite line.
   */

  memcpy (inf_line[0], axispt, sizeof(PWpoint));
  retval = pwNormVec (axisvec, naxisvec);
  OnErrorCode (retval, wrapup);

  for (ii=0; ii<3; ii++)
  {
    inf_line[1][ii] = inf_line[0][ii] + ((double *)naxisvec)[ii];
  }

  /*
   *  Construct a rangebox (having 8 points) given the input range.
   */
  pwGetRngPts (rngbx, rngpts);

  /*
   * Project all the 8 points onto the infinite line. Sort the 8 points
   * to get the minimum and maximum points.
   */
  for (ii=0; ii<8; ii++)
  {
    BSproj0 (&rc, rngpts[ii], inf_line, projpts[ii]);
    OnErrorState (rc != BSSUCC, retval,
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  }

  retval = pwMinMaxPtsAlongVec (8, projpts, naxisvec, maxpt, minpt);
  OnErrorState (IsError (retval), retval, retval, wrapup);

  /*
   * Make the minimum point as the base center and maximum point as the
   * height_center.
   */
  memcpy (base_center, minpt, sizeof (PWpoint));
  memcpy (height_center, maxpt, sizeof (PWpoint));

wrapup:

  PW_Wrapup (retval, "pwGetBoundsOfCylinder ");
  return (retval);

} /* end of function pwGetBoundsOfCylinder */


/*
  DESCRIPTION

    Given the axis vector, a point on the axis, cone half angle, the major
    axis, a point on the generator and a range box it returns the two points
    on the axis of the cone which will bound the cone in height and radii
    at these two points. The cone will bound the given range box in the 
    direction of the axis.

  ARGUMENTS

    rngbx       - I - Range box
    axispt      - I - A point on the axis of the cone
    axisvec     - I - Cone axis vector
    halfangle   - I - Cone half angle 
    genpt       - I - A point on the generator
    majoraxis   - I - The major axis defining the base ellipse 

    base_cenetr - O - Base center for the bounded cone
    base_radius - O - Base radius for the bounded cone
    top_center  - O - Top center for the bounded cone
    top_radius  - O - Top radius for the bounded cone

  NOTES

    All the memory must be allocated by the caller.
*/
 
PWresult pwGetBoundsOfCone
(
  PWrange rngbx,
  PWpoint axispt,
  PWvector axisvec,
  double  tan_halfangle,
  PWpoint   genpt,
  PWvector  majoraxis,
  PWboolean same,
  PWpoint base_center,
  double  *base_radius,
  PWpoint top_center,
  double  *top_radius
)
{
  PWresult          retval=PW_K_Success;
  BSrc              rc=BSSUCC;
  int               ii=0;
  PWpoint           rngpts[8], projpts[8], maxpt, minpt;
  PWpoint           vertexpt, projgenpt;
  PWvector          naxisvec, taxisvec;
  PWvector          nmajoraxis;
  double            inf_gen_line[2][3], inf_axis_line[2][3];
  double            inf_base_line[2][3], dotp=0;
  PWpoint           outbasept;
  double            dist_along=0, dist=0, dist1=0;
  PWboolean         reverse=FALSE;
  

  retval = PW_K_Success;

  /*
   * Get the rangebox minimum and maximum points after projecting onto the
   * axis vector
   */
  memcpy (inf_axis_line[0], axispt, sizeof(PWpoint));
  retval = pwNormVec (axisvec, naxisvec);
  OnErrorCode (retval, wrapup);

  for (ii=0; ii<3; ii++)
  {
    inf_axis_line[1][ii] = inf_axis_line[0][ii] + ((double *)naxisvec)[ii];
  }

  /*
   * Construct a rangebox (having 8 points) given the input range.
   */
  pwGetRngPts (rngbx, rngpts);

  /*
   * Project all the 8 points onto the infinite line. Sort the 8 points
   * to get the minimum and maximum points.
   */
  for (ii=0; ii<8; ii++)
  {
    BSproj0 (&rc, rngpts[ii], inf_axis_line, projpts[ii]);
    OnErrorState (rc != BSSUCC, retval,
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  }

  retval = pwMinMaxPtsAlongVec (8, projpts, naxisvec, maxpt, minpt);
  OnErrorState (IsError (retval), retval, retval, wrapup);
  
  /*
   * Project the generetrix point onto the axis vect and get the magnitude.
   * Use the 'halfangle' to calculate the top point of the cone.
   * Top point and the generetrix point determines the generetrix vector.
   */
  BSproj0 (&rc, genpt, inf_axis_line, projgenpt);
  OnErrorState (rc != BSSUCC, retval,
                SetError (PW_K_BspMath, PW_K_Internal), wrapup);

  /*
   * Get the distance between the projected point and the genpt
   */
  dist = pwDistPtPt (genpt, projgenpt);

  /*
   * Get the distance of the vertex of the cone from projgenpt along the 
   * cone axis
   */
  dist_along = dist/fabs (tan_halfangle);

  /*
   * Get the vertexpt
   */
  if (!same)
  {
    for (ii=0; ii<3; ii++)
    {
      vertexpt[ii] = projgenpt[ii] +  dist_along*naxisvec[ii];
    }
  }
  else
  {
    for (ii=0; ii<3; ii++)
    {
      vertexpt[ii] = projgenpt[ii] -  dist_along*naxisvec[ii];
    }
  }

  /*
   * Construct the infinite generetrix line
   */
  memcpy (inf_gen_line[0], genpt, sizeof (PWpoint));
  memcpy (inf_gen_line[1], vertexpt, sizeof (PWpoint));

  /*
   * Construct the base infinite line. This line should pass through the
   * minimum point as determined before.
   */
  memcpy (inf_base_line[0], minpt, sizeof(PWpoint));

  /*
   * Other point will be along the major axis direction
   */
  retval = pwNormVec (majoraxis, nmajoraxis);
  OnErrorCode (retval, wrapup); 

  for (ii=0; ii<3; ii++)
  {
    inf_base_line[1][ii] = inf_base_line[0][ii] + ((double *)nmajoraxis)[ii];
  }

  /*
   * Intersect the infinite base line and infinite generetrix line to
   * get the intersection point. This point and the base_center point will
   * determine the base radius
   */
  
  BSxln (&rc, inf_base_line[0], inf_base_line[1], inf_gen_line[0], 
         inf_gen_line[1], outbasept);
  OnErrorState (rc != BSSUCC, retval,
                SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  
  /*
   * Minimum point forms the base point of the cone. But for the top point
   * we need to see which point is nearer to the base point, the max point
   * or the vertexpt.
   */
  dist = pwDistPtPt (maxpt, minpt);
  dist1 = pwDistPtPt (vertexpt, minpt);

  /*
   * Now is the time to prepare the outputs
   */
  memcpy (base_center, minpt, sizeof(PWpoint));
  *base_radius = pwDistPtPt (minpt, outbasept);
  if ((dist < dist1) || same)
  {
    memcpy (top_center, maxpt, sizeof(PWpoint));
    if (!same)
    *top_radius = (dist1-dist) * fabs (tan_halfangle);
    else
    *top_radius = (dist1+dist) * fabs (tan_halfangle);
  }
  else
  {
    memcpy (top_center, vertexpt, sizeof(PWpoint));
    *top_radius = 0.0;
  }

  pwMakeVec (base_center, top_center, taxisvec);
  pwNormVec (taxisvec, taxisvec);
  dotp = pwDot (taxisvec, naxisvec);

  if (dotp > 0.0)
  {
    if (tan_halfangle > 0.0)
	  reverse = (*top_radius > *base_radius) ? FALSE : TRUE;
	else
	  reverse = (*top_radius > *base_radius) ? TRUE : FALSE;
  }	  
  else
  {
    if (tan_halfangle < 0.0)
	  reverse = (*top_radius > *base_radius) ? FALSE : TRUE;
	else
	  reverse = (*top_radius > *base_radius) ? TRUE : FALSE;
  }
  
  if (reverse)
  {
    pwSwapDouble (base_radius, top_radius);
	pwSwapPt (base_center, top_center);
  }
    
wrapup:

  PW_Wrapup (retval, "pwGetBoundsOfCone");
  return (retval);

} /* end of function pwGetBoundsOfCone */

