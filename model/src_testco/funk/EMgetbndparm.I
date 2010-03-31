class implementation Root;

#include "OMerrordef.h"
#include "ems_m_inc.h"
#include "EMS.h"
#include "EMSopt.h"
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"
#include "emserr.h"
#include "msdef.h"
#include "grmessage.h"
#include "alloca.h"
#include "bsxtractpar.h"
#include "bsmkvec.h"
#include "bslenvec.h"

/*
Abstract
    This function assumes that the input surface has edges on u = 0
    and u = 1 (within the user input tolerance) or on v = 0 or v = 1
    (within the user input tolerance) depending on the value of input
    parameter u_or_v.

    If u_or_v = 0, the surface would look like

           (u,v)=(0,1)               (u,v)=(1,1)
             |     maximum v side      |
             |--- ...... --- ...... ---|
             |                         |
             |                         |
             |                         |
             |                         |
             |--- ...... --- ...... ---|
             |     minimum v side      |
             |                         |
           (u,v)=(0,0)               (u,v)=(1,0)

    For u_or_v = 1, the u and v roles are swapped.

    This function goes through the edges of the input surface and gets
    the following information

    if (u_or_v == 0)
      o minimum and maximum v values of the edges on u = 0 and u = 1;
      o number and list of edges (GRid) consists of the boundary on the
        minimum v side and maximum v side.
    else
      o minimum and maximum u values of the edges on v = 0 and v = 1;
      o number and list of edges (GRid) consists of the boundary on the
        minimum u side and maximum u side.

    Fillet surface has the required characteristics as the input surface
    upon which this function was designed originally.


    INPUTS

    surf	- GRid of the input surface
    tolr	- Used in judging if u is 0.0 or u is 1.0 in tests
                  "fabs(u - 0.0) < tolr" or "fabs(u - 1.0) < tolr"
    u_or_v	- u_or_v == 0, then find min and max v values and sides
		  u_or_v == 1, then find min and max u values and sides

    OUTPUTS

    parm_range	- Minimum and maximum v (u) values on u (v) = 0 and
		  u (v) = 1. parm_range should be declared as
		    IGRdouble parm_range[4];

		  Return values are orgainized as

		  if (u_or_v == 0)
		    parm_range[0] = minimum v on u = 0
		    parm_range[1] = maximum v on u = 0
		    parm_range[2] = minimum v on u = 1
		    parm_range[3] = maximum v on u = 1
		  else
		    parm_range[0] = minimum u on v = 0
		    parm_range[1] = maximum u on v = 0
		    parm_range[2] = minimum u on v = 1
		    parm_range[3] = maximum u on v = 1

    num_minbnd_edges
    minbnd_edges
    num_maxbnd_edges
    maxbnd_edges
		- Number of edges and GRid of edges on the minimum v (u)
		  side and maximum v (u) side of the surface.

    msg 	- return code:
    		  INVALID_U_OR_V_PARM (1),	u_or_v invalid
    		  INVALID_SURF_TYPE (2),	no edge endpoints on boundary
		  NO_DYNMEMORY (3),		no dynamic memory


    NOTES

    Memory for minbnd_edges and maxbnd_edges are allocated by this function.


History 
    SY	12/10/92	Creation.
    SY	05/11/93	Take the code of this function out of the Create
			Blend Surface Command code and make it stand alone.
  Sudha 07/02/93        Modified for BSprototypes ansification

*/

/* The following values are used as return
   values for function EMget_bnd_parms */
#define	INVALID_U_OR_V_PARM   	1
#define INVALID_SURF_TYPE	2
#define NO_DYNMEMORY		3

/* The following values are used as return
   values for function EMget_closest_surf_along_direction */
#define FIND_CLOSEST_SURF 0
#define NO_CLOSEST_SURF 1
#define MORE_THAN_ONE_CLOSEST_SURF 2

from EMSsurface import EMgetedges, EMcrvsrfint;
from EMSedge import EMendpts;
from GRgraphics import GRgetrang;


IGRint EMget_bnd_parms (msg, surf, tolr, u_or_v,
			parm_range,
			num_minbnd_edges, minbnd_edges,
			num_maxbnd_edges, maxbnd_edges)
IGRlong *msg;
struct GRid *surf;
IGRdouble tolr;
IGRint u_or_v;
IGRdouble parm_range[];
IGRint *num_minbnd_edges, *num_maxbnd_edges;
struct GRid **minbnd_edges, **maxbnd_edges;
{
  struct GRid *edges;
  IGRint buf_size, num_edges, i;
  IGRdouble beginpt[2], endpt[2], *uvpts, *ptr_pts, value;
  IGRdouble min_on_0, max_on_0, min_on_1, max_on_1;
  IGRint min_on_0_ind, max_on_0_ind, min_on_1_ind, max_on_1_ind;
  IGRboolean counterclockwise = TRUE, alloced = FALSE;
  IGRlong sts, loc_msg;
  extern IGRdouble fabs();
  
  /* initialize */
  *msg = MSSUCC;
  sts = OM_S_SUCCESS;
  
  /* get parameter space tolerance */
  /*
  BSxtractpar(&loc_msg, BSTOLPARAM, &tolr);
  */

  /* validate u_or_v parameter */
  if (u_or_v != 0 && u_or_v != 1)
  {
    *msg = INVALID_U_OR_V_PARM;
    sts = OM_E_ABORT;
    goto quit;
  }

  buf_size = num_edges = 0;
  sts = om$send(msg = message EMSsurface.EMgetedges(&loc_msg,
						    EMS_OPT_NONDEG_NONSEAM,
						    &edges,
						    &buf_size,
						    &num_edges,
						    NULL,
						    NULL,
						    NULL,
						    NULL),
		senderid = NULL_OBJID,
		targetid = surf->objid,
		targetos = surf->osnum);
  EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
  alloced = TRUE;

  uvpts = (IGRdouble *) alloca(num_edges * 2 * sizeof(IGRdouble));
  ptr_pts = uvpts;
  for (i = 0; i < num_edges; i++)
  {
    sts = om$send(msg = message EMSedge.EMendpts(&loc_msg,
						 beginpt,
						 endpt,
						 NULL,
						 NULL,
						 NULL),
		  senderid = NULL_OBJID,
		  targetid = edges[i].objid,
		  targetos = edges[i].osnum);
    EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
    memcpy(ptr_pts, beginpt, sizeof(IGRdouble) * 2);
    ptr_pts += 2;
  }

  /* get parametric range on u = 0 and u = 1 */
  min_on_0 = min_on_1 = 2.0;
  max_on_0 = max_on_1 = -1.0;
  min_on_0_ind = max_on_0_ind = min_on_1_ind = max_on_1_ind = 0;
  i = 0;
  ptr_pts = uvpts;
  while (i < num_edges)
  {
    if (fabs(ptr_pts[u_or_v]) < tolr)
    {
      value = ptr_pts[(u_or_v + 1) % 2];
      if (value > max_on_0)
      {
	max_on_0 = value;
	max_on_0_ind = i;
      }
      if (value < min_on_0)
      {
	min_on_0 = value;
	min_on_0_ind = i;
      }
    }
    else if (fabs(ptr_pts[u_or_v] - 1.0) < tolr)
    {
      value = ptr_pts[(u_or_v + 1) % 2];
      if (value > max_on_1)
      {
	max_on_1 = value;
	max_on_1_ind = i;
      }
      if (value < min_on_1)
      {
	min_on_1 = value;
	min_on_1_ind = i;
      }
    }
    i++;
    ptr_pts += 2;
  }
  if (fabs(min_on_0 - 2.0) < tolr || fabs(min_on_1 - 2.0) < tolr ||
      fabs(max_on_0 + 1.0) < tolr || fabs(max_on_1 + 1.0) < tolr)
  {
    *msg = INVALID_SURF_TYPE;
    sts = OM_E_ABORT;
    goto quit;
  }
  parm_range[0] = min_on_0;
  parm_range[1] = max_on_0;
  parm_range[2] = min_on_1;
  parm_range[3] = max_on_1;

  /* determine the orientation of the edges */
  if (min_on_0_ind != (num_edges - 1))
  {
    if (fabs(uvpts[(min_on_0_ind + 1) * 2 + u_or_v]) < tolr)
      counterclockwise = FALSE;
  }
  else
  {
    if (fabs(uvpts[(min_on_0_ind - 1) * 2 + u_or_v]) > tolr)
      counterclockwise = FALSE;
  }

  /* allocate memory */
  *minbnd_edges = (struct GRid *) om$malloc(size = (num_edges - 2) * sizeof(struct GRid));
  if (*minbnd_edges == NULL)
  {
    *msg = NO_DYNMEMORY;
    sts = OM_E_ABORT;
    goto quit;
  }
  *maxbnd_edges = (struct GRid *) om$malloc(size = (num_edges - 2) * sizeof(struct GRid));
  if (*maxbnd_edges == NULL)
  {
    om$dealloc(ptr = *minbnd_edges);
    *msg = NO_DYNMEMORY;
    sts = OM_E_ABORT;
    goto quit;
  }

  /* get boundary edge groups */
  if (max_on_0_ind > min_on_0_ind)
  {
    if (counterclockwise == TRUE)
    {
      *num_minbnd_edges = min_on_1_ind - min_on_0_ind;
      for (i = min_on_0_ind; i < min_on_1_ind; i++)
	memcpy((*minbnd_edges) + i - min_on_0_ind, edges + i, sizeof(struct GRid));

      *num_maxbnd_edges = max_on_0_ind - max_on_1_ind;
      for (i = max_on_1_ind; i < max_on_0_ind; i++)
	memcpy((*maxbnd_edges) + i - max_on_1_ind, edges + i, sizeof(struct GRid));
    }
    else
    {
      if (min_on_1_ind > max_on_0_ind)
      {
	*num_minbnd_edges = num_edges - min_on_1_ind + min_on_0_ind;
	for (i = min_on_1_ind; i < num_edges; i++)
	  memcpy((*minbnd_edges) + i - min_on_1_ind, edges + i, sizeof(struct GRid));
	for (i = 0; i < min_on_0_ind; i++)
	  memcpy((*minbnd_edges) + i + num_edges - min_on_1_ind, edges + i, sizeof(struct GRid));

	*num_maxbnd_edges = max_on_1_ind - max_on_0_ind;
	for (i = max_on_0_ind; i < max_on_1_ind; i++)
	  memcpy((*maxbnd_edges) + i - max_on_0_ind, edges + i, sizeof(struct GRid));
      }
      else
      {
	*num_minbnd_edges = min_on_0_ind - min_on_1_ind;
	for (i = min_on_1_ind; i < min_on_0_ind; i++)
	  memcpy((*minbnd_edges) + i - min_on_1_ind, edges + i, sizeof(struct GRid));

	if (max_on_1_ind > max_on_0_ind)
	{
	  *num_maxbnd_edges = max_on_1_ind - max_on_0_ind;
	  for (i = max_on_0_ind; i < max_on_1_ind; i++)
	    memcpy((*maxbnd_edges) + i - max_on_0_ind, edges + i, sizeof(struct GRid));
	}
	else
	{
	  *num_maxbnd_edges = num_edges - max_on_0_ind + max_on_1_ind;
	  for (i = max_on_0_ind; i < num_edges; i++)
	    memcpy((*maxbnd_edges) + i - max_on_0_ind, edges + i, sizeof(struct GRid));
	  for (i = 0; i < max_on_1_ind; i++)
	    memcpy((*maxbnd_edges) + i + num_edges - max_on_0_ind, edges + i, sizeof(struct GRid));
	}
      }
    }
  }
  else
  {
    if (counterclockwise == TRUE)
    {
      if (min_on_1_ind > min_on_0_ind)
      {
	*num_minbnd_edges = min_on_1_ind - min_on_0_ind;
	for (i = min_on_0_ind; i < min_on_1_ind; i++)
	  memcpy((*minbnd_edges) + i - min_on_0_ind, edges + i, sizeof(struct GRid));

	if (max_on_1_ind > min_on_0_ind)
	{
	  *num_maxbnd_edges = num_edges - max_on_1_ind + max_on_0_ind;
	  for (i = max_on_1_ind; i < num_edges; i++)
	    memcpy((*maxbnd_edges) + i - max_on_1_ind, edges + i, sizeof(struct GRid));
	  for (i = 0; i < max_on_0_ind; i++)
	    memcpy((*maxbnd_edges) + i + num_edges - max_on_1_ind, edges + i, sizeof(struct GRid));
	}
	else
	{
	  *num_maxbnd_edges = max_on_0_ind - max_on_1_ind;
	  for (i = max_on_1_ind; i < max_on_0_ind; i++)
	    memcpy((*maxbnd_edges) + i - max_on_1_ind, edges + i, sizeof(struct GRid));
	}
      }
      else
      {
	*num_minbnd_edges = num_edges - min_on_0_ind + min_on_1_ind;
	for (i = min_on_0_ind; i < num_edges; i++)
	  memcpy((*minbnd_edges) + i - min_on_0_ind, edges + i, sizeof(struct GRid));
	for (i = 0; i < min_on_1_ind; i++)
	  memcpy((*minbnd_edges) + i + num_edges - min_on_0_ind, edges + i, sizeof(struct GRid));

	*num_maxbnd_edges = max_on_0_ind - max_on_1_ind;
	for (i = max_on_1_ind; i < max_on_0_ind; i++)
	  memcpy((*maxbnd_edges) + i - max_on_1_ind, edges + i, sizeof(struct GRid));
      }
    }
    else
    {
      *num_minbnd_edges = min_on_0_ind - min_on_1_ind;
      for (i = min_on_1_ind; i < min_on_0_ind; i++)
	memcpy((*minbnd_edges) + i - min_on_1_ind, edges + i, sizeof(struct GRid));

      *num_maxbnd_edges = max_on_1_ind - max_on_0_ind;
      for (i = max_on_0_ind; i < max_on_1_ind; i++)
	memcpy((*maxbnd_edges) + i - max_on_0_ind, edges + i, sizeof(struct GRid));
    }
  }

 quit:
  if (alloced)
    om$dealloc(ptr = edges);
  return sts;
}


/*
Abstract
    Given a solid and a point on the solid. This function finds a surface
    on the solid that is closest to the point along the user specified
    input direction. The input point is assumed to be located at the
    interior of the surface. In case it is close to an edge, then this
    function will return MORE_THAN_ONE_CLOSEST_SURF. Or if the point is
    off the surface, then NO_CLOSEST_SURF is returned.

    INPUTS

    solid	- Located input solid
    point	- Input point
    dir		- Direction vector along which to find closest surface
    fillet	- This input is optional. If set, then the fillet cannot
		  be returned as the closest surface even if it is. The
		  next closest surface will be returned. Input NULL if
		  such checking is not desired.

    OUTPUTS

    closest_surf- The found surface closest to the input point along the
		  input direction.
    rc		- FIND_CLOSEST_SURF: find one surface
		  NO_CLOSEST_SURF: surface not found. Generally, this means
		                   the input point is not on the solid.
		  MORE_THAN_ONE_CLOSEST_SURF: the point may be close to an
		                              edge.

History 
    SY	12/10/92	Creation.
    SY	06/02/93	Take the code of this function out of the Create
			Blend Surface Command code and make it stand alone.

*/

IGRint EMget_closest_surf_along_direction (rc, solid, point, dir, fillet,
					   closest_surf)
IGRlong *rc;
struct GRlc_info *solid;
IGRpoint point;
IGRvector dir;
struct GRlc_info *fillet;
struct GRid *closest_surf;
{
  IGRboolean wld_loc = TRUE;
  IGRdouble tolr, bspln_knots[4], *inters_xyz;
  IGRlong pnt_slots, num_ints;
  IGRint i, index, count;
  GRrange range;
  IGRpoint point2, better_line[2];
  IGRvector toint_vec;
  IGRlong sts, msg;
  struct IGRline init_line;
  struct IGRbsp_curve bspln;
  struct GRparms *surf_inters, *cv_inters;
extern IGRboolean EMget_bounded_line() ;

  /* initialize */
  sts = OM_S_SUCCESS;
  BSxtractpar(&msg, BSTOLCHRDHT, &tolr);

  /* get range of the solid */
  sts = om$send(msg = message GRgraphics.GRgetrang(&msg,
						   &solid->module_info.md_env.matrix_type,
						   solid->module_info.md_env.matrix,
						   &wld_loc,
						   range),
		senderid = NULL_OBJID,
		targetid = solid->located_obj.objid,
		targetos = solid->located_obj.osnum);

  /* define the intersecting line */
  point2[0] = point[0] + dir[0];
  point2[1] = point[1] + dir[1];
  point2[2] = point[2] + dir[2];
  
  init_line.point1 = point;
  init_line.point2 = point2;

  /* call function to get a bounded line */
  EMget_bounded_line(range, &init_line, better_line, &msg);

  /* formulate order two B-spline curve */
  bspln.order = 2;
  bspln.periodic = FALSE;
  bspln.non_uniform = FALSE;
  bspln.num_poles = 2;
  bspln.poles = (IGRdouble *) better_line;
  bspln.num_knots = 4;
  bspln.knots = bspln_knots;
  bspln_knots[0] = bspln_knots[1] = 0.0;
  bspln_knots[2] = bspln_knots[3] = 1.0;
  bspln.rational = FALSE;
  bspln.weights = NULL;
  bspln.planar = TRUE;
  bspln.phy_closed = FALSE;
  bspln.num_boundaries = 0;
  bspln.bdrys = NULL;

  /* intersect the B-spline curve with the solid */
  pnt_slots = num_ints = 0;
  surf_inters = cv_inters = NULL;
  inters_xyz = NULL;
  sts = om$send(msg = message EMSsurface.EMcrvsrfint(&msg,
						     NULL,
						     &solid->module_info.md_env,
						     &bspln,
						     NULL,
						     NULL,
						     FALSE,
						     &pnt_slots,
						     &num_ints,
						     NULL,
						     &surf_inters,
						     &cv_inters,
						     &inters_xyz,
						     NULL),
		senderid = NULL_OBJID,
		targetid = solid->located_obj.objid,
		targetos = solid->located_obj.osnum);
  EMerr_hndlr(EMSerror(sts & msg), sts, OM_E_ABORT, quit);

  count = 0;
  for (i = 0; i < num_ints; i++)
  {
    BSmkvec(&msg, toint_vec, point, inters_xyz + 3 * i);
    if (BSlenvec(&msg, toint_vec) < tolr)
    {
      if (!fillet ||
	  surf_inters[i].leaf_id.objid != fillet->located_obj.objid ||
	  surf_inters[i].leaf_id.osnum != fillet->located_obj.osnum)
      {
	index = i;
	count++;
      }
    }
  }
  if (count > 1)
    *rc = MORE_THAN_ONE_CLOSEST_SURF;
  else if (count == 0)
    *rc = NO_CLOSEST_SURF;
  else
  {
    closest_surf->osnum = surf_inters[index].leaf_id.osnum;
    closest_surf->objid = surf_inters[index].leaf_id.objid;
    *rc = FIND_CLOSEST_SURF;
  }
  om$dealloc(ptr = surf_inters);
  om$dealloc(ptr = cv_inters);
  om$dealloc(ptr = inters_xyz);

 quit:
  return sts;
}

end implementation Root;
