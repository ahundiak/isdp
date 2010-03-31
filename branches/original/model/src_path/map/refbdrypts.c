/*
  OVERVIEW

  This file consists the functions which refines boundary points and splits
  the array of points with the seams.  These are all helper functions for 
  "pwMapXyzCvToUvOfSf".

  NOTES

  None.

  HISTORY

  09/15/95    Sanjay    Creation
*/

/* Includes */

#include <stdio.h>
#include <math.h>
#include <alloca.h>       /* System */
#include <memory.h>
#include <malloc.h>

#include "igrtypedef.h"
#include "igr.h"        
#include "bs.h"           /* BS math */
#include "bsparameters.h"
#include "bsgeom_cvsf.h"

#include "PWminimum.h"
#include "PWgmdata.h"     /* Pathway */
#include "PWerror.h"

/* Prototypes */

#include "PWapi/refbdrypts.h"
#include "PWapi/cvgeom.h"
#include "PWapi/samepts.h"
#include "PWapi/mdstptgm.h" /* Pathway */
#include "PWapi/sfbnds.h"
#include "PWapi/inspts.h"
#include "PWapi/partol.h"

/* Static functions */

static void insert_uvpts_at_seam
(
  int *num_pts,
  PWpoint2d *p_pts,
  int dir,
  double minpar,
  double maxpar
);

static void split_uvpts_at_seam
(
  int num_pts,
  PWpoint2d *p_pts,
  int dir,
  double minpar,
  double maxpar,

  int *num_grps,
  int *num_pts_grp
);


/*
  ABSTRACT

  Given a set of uv points on the surface, it refines the points which fall 
  on the degenerate xyz boundaries of the surface by looking at their adjacent
  point.

  ARGUMENTS

  p_sf        - I   : Surface geometry
  num_uvpts   - I   : Number of Uv points
  p_uvpts     - I/O : Uv points
  xyztol      - I   : Model space tolerance.

  NOTES

  None.

  KEYWORDS

  Internal API. Helper function.

  HISTORY

  Sanjay   09/15/95    Creation

*/

PWresult pwRefineUvPtsOnDegenBdrysOfSf
(
  struct IGRbsp_surface *p_sf,
  int num_uvpts,
  PWpoint2d *p_uvpts,
  double xyztol
)
{
  PWresult PWsts=PW_K_Success;
  PWboolean degen_u0=FALSE, degen_u1=FALSE, degen_v0=FALSE, degen_v1=FALSE;
  double uvtol=0, u_min=0, u_max=0, v_min=0, v_max=0, *p_nextpt=NULL;
  int inx=0;

  if (num_uvpts < 2)
    goto wrapup;
  
  PWsts = pwGetDegenNatBdrysOfSf (p_sf, xyztol, &degen_u0, &degen_u1, 
                                  &degen_v0, &degen_v1);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  if (!degen_u0 && !degen_u1 && !degen_v0 && !degen_v1)
    goto wrapup;

  u_min = p_sf->u_knots [p_sf->u_order-1];
  v_min = p_sf->v_knots [p_sf->v_order-1];
  u_max = p_sf->u_knots [p_sf->u_num_poles];
  v_max = p_sf->v_knots [p_sf->v_num_poles];

  uvtol = pwGetParTolSf (p_sf, xyztol);

  for (inx=0; inx<num_uvpts; inx++)
  {
    if (inx)
      p_nextpt = &p_uvpts[inx-1][0];
    else
      p_nextpt = &p_uvpts[1][0];

    if ((degen_v0 && (p_uvpts[inx][V] - v_min) < uvtol) ||
        (degen_v1 && (v_max - p_uvpts[inx][V]) < uvtol))
    {
      /*
       * Point lies on the degenerate const-V parametric cure.
       */

      p_uvpts[inx][U] = p_nextpt[U];
    }

    if ((degen_u0 && (p_uvpts[inx][U] - u_min) < uvtol) ||
        (degen_u1 && (u_max - p_uvpts[inx][U]) < uvtol))
    {
      /*
       * Point lies on the degenerate const-U parametric cure.
       */

      p_uvpts[inx][V] = p_nextpt[V];
    }
  }

wrapup :
  
  PW_Wrapup (PWsts, "pwRefineUvPtsOnDegenBdrysOfSf");
  return PWsts;
}


/*
  ABSTRACT

  Inserts the points at the seams of the surface if the input array of points
  crossing the seams of the surface. 

  ARGUMENTS

  p_sf      - I   : Surface geometry
  num_pts   - I/O : Number of UV points
  p_pts     - I/O : UV poitns
 
  NOTES

  Memory will be reallocated in this routine. So, memory for the input points
  must be allocated by a malloc call before calling this function.

  KEYWORDS

  Internal API. Helper function.

  HISTORY

  Sanjay  09/15/95   Creation

*/

PWresult pwInsertUvPtsAtSeamsOfSf
(
  struct IGRbsp_surface *p_sf,
  int *num_pts,
  PWpoint2d *p_pts
)
{
  PWresult PWsts=PW_K_Success;
  double u_min=0, v_min=0, u_max=0, v_max=0;

  /* Initialize the output */

  if ((*num_pts < 2) || (!p_sf->u_phy_closed && !p_sf->v_phy_closed))
    OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                  wrapup);

  u_min = p_sf->u_knots [p_sf->u_order-1];
  v_min = p_sf->v_knots [p_sf->v_order-1];
  u_max = p_sf->u_knots [p_sf->u_num_poles];
  v_max = p_sf->v_knots [p_sf->v_num_poles];

  if (p_sf->u_phy_closed)
  {
    /*
     * Surface is closed in U.
     */

    insert_uvpts_at_seam (num_pts, p_pts, U, u_min, u_max);   
  }

  if (p_sf->v_phy_closed)
  {
    /*
     * Surface is closed in V.
     */

    insert_uvpts_at_seam (num_pts, p_pts, V, v_min, v_max);   
  }
 

wrapup : 

  return PWsts; 
}


/*
  ABSTRACT

  Given an array of uv points, it splits these points at the seams of the 
  surface and returns the number of groups.

  ARGUMENTS

  p_sf         - I : Surface geometry
  num_pts      - I : Number of UV points
  p_pts        - I : UV points

  num_grps     - O : Number of groups
  num_pts_grp  - O : Number of points per group

  NOTES

  All the memory for the output must be allocated by the caller. A maximum of
  num_pts must be allocated for num_pts_grp field.

  KEYWORDS

  Internal API, Helper function.

  HISTORY

  Sanjay  09/15/95   Creation
*/
  
PWresult pwSplitUvPtsAtSeamsOfSf
(
  struct IGRbsp_surface *p_sf,
  int num_pts,
  PWpoint2d *p_pts,
  int *num_grps,
  int *num_pts_grp
)
{
  PWresult PWsts=PW_K_Success;
  double u_min=0, v_min=0, u_max=0, v_max=0;

  /* Initialize the output */
  *num_grps = 0;

  if ((num_pts < 2) || (!p_sf->u_phy_closed && !p_sf->v_phy_closed))
    OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                  wrapup);

  u_min = p_sf->u_knots [p_sf->u_order-1];
  v_min = p_sf->v_knots [p_sf->v_order-1];
  u_max = p_sf->u_knots [p_sf->u_num_poles];
  v_max = p_sf->v_knots [p_sf->v_num_poles];

  if (p_sf->u_phy_closed)
  {
    /*
     * Surface is closed in U.
     */
    split_uvpts_at_seam (num_pts, p_pts, U, u_min, u_max, num_grps, 
                         num_pts_grp);
  }
  else
  {
    *num_grps = 1;
    num_pts_grp[0] = num_pts;
  }

  if (p_sf->u_phy_closed)
  {
    /*
     * Surface is closed in U.
     */

    int i=0, cnt=0, loc_num_grps[2], loc_num_pts_grp[2][2];

    for (cnt=0; cnt<*num_grps; cnt++)
    {
      split_uvpts_at_seam (num_pts_grp[cnt], p_pts, V, v_min, v_max, 
                           &loc_num_grps[cnt], loc_num_pts_grp[cnt]);
    }

    *num_grps = 0;

    for (cnt=0; cnt<2; cnt++)
    {
      for (i=0; i<loc_num_grps[cnt]; i++)
        num_pts_grp[(*num_grps)+i] = loc_num_pts_grp[cnt][i];
      (*num_grps) += loc_num_grps[cnt];
    }  
  }

wrapup :

  return PWsts;

}

/*
  ABSTRACT

  Given an array of UV points it splits them at the seams of the surface and
  refines the points at the splits.

  ARGUMENTS

  p_sf        - I : Surface geometry
  num_pts     - I : Number of UV points
  p_pts       - I : UV points
  uvtol       - I : UV tolerance

  num_grps    - O : Number of groups 
  num_outpts  - O : Number of points per group
  p_outpts    - O : Points in each group

  NOTES

  All the memory will be allocated by this routine.

  KEYWORDS
  
  Internal API. Helper function.

  HISTORY

  Sanjay  09/15/95   Creation
*/

PWresult pwSplitAndRefineUvPtsOnSeamsOfSf
(
  struct IGRbsp_surface *p_sf,
  int num_pts,
  PWpoint2d *p_pts,

  double uvtol,

  int *num_grps,
  int **num_outpts,
  PWpoint2d **p_outpts
)
{
  PWresult PWsts=PW_K_Success;

  /* Initialize the output */
  
  *num_grps = 0;
  uvtol = uvtol;

  if ((num_pts < 2) || (!p_sf->u_phy_closed && !p_sf->v_phy_closed))
    OnErrorState (TRUE, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
                  wrapup);

  *num_grps = 1;
  *num_outpts = (int *) malloc (4 * sizeof (int));
  (*num_outpts)[0] = num_pts;
 
  if (*p_outpts != p_pts)
  {
    *p_outpts = (PWpoint2d *) malloc ((num_pts + 8) * sizeof (PWpoint2d));
    OnErrorState (!*p_outpts, PWsts, SetError (PW_K_Pathway, 
                  PW_K_DynamicMemory), wrapup);

    memcpy (*p_outpts, p_pts, num_pts * sizeof (PWpoint2d));
  }
  else
  {
    *p_outpts = (PWpoint2d *) realloc (*p_outpts, (num_pts + 8) * 
                                                  sizeof (PWpoint2d));
    OnErrorState (!*p_outpts, PWsts, SetError (PW_K_Pathway, 
                  PW_K_DynamicMemory), wrapup);
  }

wrapup :

  PW_Wrapup (PWsts, "pwRefineUvPtsOnSeamsOfSf");
  return PWsts;  
}

/* -------------------------- Static Functions ------------------------------ */

/*
  ABSTRACT

  Inserts the points at the seams of the surface in the given direction.

  NOTES

  None.
*/

static void insert_uvpts_at_seam
(
  int *num_pts, 
  PWpoint2d *p_pts,
  int dir,
  double minpar, 
  double maxpar
)
{
  int cnt=0, other_dir=0, inx=0, num_addpts=0;
  PWboolean break_found=FALSE, atend=FALSE;
  double midpar=0, prevpar=0, nextpar=0, par=0, prevdist=0, nextdist=0;
  double refpar=0, refpar1=0, refpar2=0, avgpar=0;
  PWpoint2d addpts[2];

  midpar = (minpar + maxpar) / 2.0;
  other_dir= dir == U ? V : U;

  for (cnt=1; cnt<(*num_pts)-1; cnt++)
  {
    par = p_pts[cnt][dir];
    prevpar = p_pts[cnt-1][dir];
    nextpar = p_pts[cnt+1][dir];

    prevdist = fabs (prevpar - par);
    nextdist = fabs (nextpar - par);

    if (prevdist > midpar)
    {
      break_found = TRUE;
      refpar = nextpar;
      inx = cnt-1;
      atend = cnt == 1 ? TRUE : FALSE;
    }
    else if (nextdist > midpar)
    {
      break_found = TRUE;
      refpar = prevpar;
      inx = cnt+1;
      atend = cnt == (*num_pts) - 2 ? TRUE : FALSE;
    }

    if (break_found)
    {
      if ((refpar - minpar) < (maxpar - refpar))
      {
        refpar1 = minpar; 
        refpar2 = maxpar;
      }
      else
      {
        refpar1 = maxpar;
        refpar2 = minpar;
      }

      if (refpar == refpar2 && atend)
      {
        p_pts[inx][dir] = refpar1;
      }
      else
      {
        avgpar = (p_pts[cnt-1][other_dir] + p_pts[cnt][other_dir]) / 2.0;

        if (refpar != refpar2)
        {
          addpts[num_addpts][dir] = refpar2;
          addpts[num_addpts][other_dir] = avgpar;
          num_addpts++;
        }
     
        if (par != refpar1)
        {
          addpts[num_addpts][dir] = refpar1;
          addpts[num_addpts][other_dir] = avgpar;
          num_addpts++;
        }

        if (num_addpts)
        {
          if (inx == cnt-1)
            inx ++;

          pwInsertPts2d (num_addpts, addpts, inx, *num_pts, p_pts);
          (*num_pts) += num_addpts;
        }
      }  

      break;
    }
  }

  return;
}

/*
  ABSTRACT

  Splits the points at the seams of the surface in the given direction.

  NOTES

  None.
*/

static void split_uvpts_at_seam
(
  int num_pts,
  PWpoint2d *p_pts,
  int dir,
  double minpar, 
  double maxpar,

  int *num_grps,
  int *num_pts_grp
)
{
  int cnt=0;
  double midpar=0;

  *num_grps = 1;
  num_pts_grp[0] = num_pts;

  if (p_pts[0][dir] == minpar || p_pts[0][dir] == maxpar)
    return;

  midpar = (minpar + maxpar) / 2.0;

  for (cnt=1; cnt<num_pts-2; cnt++)
  {
    if (fabs (p_pts[cnt][dir] - p_pts[cnt+1][dir]) > midpar)
    { 
      *num_grps = 2;
      num_pts_grp[0] = cnt+2;
      num_pts_grp[1] = num_pts - (cnt + 2);
      break;
    }
  }

  return;
}

