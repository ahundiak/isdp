/* $Id: bsptnorsf.c,v 1.1.1.1 2001/01/04 21:07:27 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/bs/bsptnorsf.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: bsptnorsf.c,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:27  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1998/01/09  16:46:00  pinnacle
 * Created: emsfixes/bs/bsptnorsf.c by azuurhou for vds
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      01/09/98        adz             integration date
 ***************************************************************************/



/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSptnorsf

Abstract

    This function accepts data defining a point and a B_spline surface.
    It returns the point and the parameter values of the point on the surface,
    at the base of the normal that passes through the given point .

Synopsis
    void BSptnorsf(surf,pt,n,u,v,bpoint,dist,rc)

    IGRbsp_surface             *surf;
    IGRpoint                   pt;
    IGRint                     *n;
    IGRdouble                  *u,*v;
    IGRpoint                   bpoint;
    IGRdouble                  *dist;
    BSrc                       *rc;

Description
    Given a B_spline surface (surf) and a point (pt),if this routine finds
    the point and parameter value on (surf), then it returns (n = 1), (u),
    (v) as parameter values and (bpoint) as base point on (surf) and (dist)
    between (pt) ,(bpoint). Otherwise, (n = 0) is returned.

Return Values
    If successful, BSSUCC is returned. 

Notes
    If the iteration routine does not find a solution, we still return
the proximity point as a solution.  The number of solutions will still
be 0 though.

Index
    md

Keywords

History
    Vivian W.Ye     4/28/1987   :  Creation date.
    C.S.SAMUELS     8/11/1987   :  Replaced call to BSsfnodpts with
                                   BSsfnodptsm.
    S.G. Catron     02/22/89    :  If there is a degenerate side, then
                                   the starting value for BSptnorpch,
                                   can not be too close to this boundary.
                                   So, the change added, moves the value
                                   off that boundary by a certain amount.
    S.G. Catron     03/29/89    :  Increased the tolerance used to decide
                                   whether to move the value off the 
                                   boundary.
    S.G. Catron     09/12/89    :  Added additional functionality so that
                                   if the iteration routine does not find
                                   a solution, we still return the 
                                   proximity point as a solution.
    S.G. Catron     11/01/89    :  Instead of calling BSsfnodptsm, call
                                   new routine BSsfndpchrg.  
                                   I also try to use static memory for
                                   dynamic arrays, instead of always
                                   allocating.
    S.G. Catron     12/20/89    :  If the surface has over a 100 poles, 
                                   then set the insertion value to 0.
    S.G. Catron     05/15/90    :  Changed insert value for case of 2
                                   poles to 3.
    S.G. Catron     06/20/90    :  Stupid mistake in checking for degen-
                                   erate boundary.  I didn't unweight the
                                   poles.
    S.G. Catron     02/06/91    :  Added call to routine BSmvuvobdcs,
                                   which moves guess value off any
                                   boundaries or cusps.
    S.G. Catron     01/28/92    :  Changed the ratio to be smaller.
                                   It's now based on the knot_tol.
                                   This makes the node value closer
                                   to the boundary, which helps when
                                   we have degenerate cases.
    D. Breden       03/02/93    :  Changed u_insert and v_insert for order
                                   2 from 3 to 4. Note that these statements
                                   should be kept consistent with the ones
                                   in BSptsnorsf and in BSmdarrptsf.
    D. Breden       03/22/93    :  Fixed index problem in i-j-loop.
                                   If BSptnorpch() fails and the surface
                                   has either two poles in v or 2 poles
                                   in u, recall BSptnorpch with mid-u
                                   or mid-v parameter.
    S.G. Catron     04/05/93    :  When BSptnorpch fails with last effort,
                                   initialize output to original uv_par
                                   and not mid-u(mid-v).
    S.G. Catron     12/02/93    :  Changed insert value for order 2 and
                                   num_poles > 2, to 5 instead of 4.
    S.G. Catron     02/16/94    :  Fixed ij loop, because it was not
                                   looping over the entire mesh of node
                                   values. Also use the actual distance
                                   instead of the squared distances.
    S.G. Catron     07/21/94    :  Added code to save next to minimum dist
                                   node values.(Save ones which are not
                                   in same area.)  Then call BSptnorpch 
                                   twice take the one with minimum
                                   distance.(ptnorsf.d14)
    S.G. Catron     07/22/94    :  Don't use anwser from second BSptnorpch
                                   if distance is not less than node point
                                   distance.
    D. Breden       09/04/95    :  Increased values of u_insert and
                                   v_insert.
    C.S. Kirby      11/06/95    :  Replace code with call to BSmdarptsfo.
    C.S. Kirby      10/22/96    :  Replace call to BSmdarptsfo with call
                                   to BSmdptsfo1.
    Vivian Y.Hsu    12/17/97    :  If rc = BSNOSOLUTION returned from
                                   BSmdptsfo1, set rc = BSSUCC and n = 0,
                                   then exit.
*/
#include <math.h>
#include "bs.h"
#include "bsstackalloc.h"
#define  BSVOID  
#include "bsparameters.h"

void BSptnorsf(
struct IGRbsp_surface    *surf,   
IGRpoint                 pt,  
IGRint                   *n,      
IGRdouble                *u,
IGRdouble                *v,
IGRpoint                 bpoint,
IGRdouble                *dist,    
BSrc                     *rc)      
{
#include "bsdbgrc.h"
#include "bsmdptsfo1.h"

  IGRint                num = 1;
  IGRdouble             dist_tol;
  IGRboolean            ret_uvs = TRUE, ret_pts = TRUE,
                        ret_dist = TRUE, ret_all_on_surf = TRUE,
                        ret_nor_surf = TRUE, all_on_surf;
  IGRdouble             uvs[2];
  IGRboolean            pt_nor_surf;

  *rc = BSSUCC;
  *n = 0;

  BSEXTRACTPAR( rc, BSTOLLENVEC, dist_tol );


  BSmdptsfo1( num, (IGRpoint *)pt, surf, dist_tol, ret_uvs, ret_pts,
              ret_dist, ret_nor_surf, ret_all_on_surf, (IGRdouble (*)[2])uvs,
              (IGRpoint *)bpoint, dist, &pt_nor_surf, &all_on_surf, rc );
  if (BSERROR(*rc) && *rc != BSNOSOLUTION)
    goto wrapup;

  if (*rc == BSNOSOLUTION)
  {
    /* Returns n = 0 */
    *rc = BSSUCC;
    goto wrapup;
  }

  if (pt_nor_surf) 
    *n = 1;
  *u = uvs[0];
  *v = uvs[1];

  wrapup:
  if(BSERROR(*rc))
     BSdbgrc(*rc,"BSptnorsf");
  return;
}


