/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This command object serves as interface for the create blend between
    fillet surfaces. It is used when automatic rounding failed.

  HISTORY

    JSY  :  12/04/92
    scw  :  08/14/94  clarified sleep method
*/

class specification ECcrbldsf (1:2) of ECelements;

#include "dpstruct.h"
#include "bsgeom_cvsf.h"
#include "FI.h"

/* define type for storing fillet surface's parametric range along
 * u = 0 and u = 1.
 * The defined array entry 0: minimum v along u = 0;
 *                   entry 1: maximum v along u = 0;
 *                   entry 2: minimum v along u = 1;
 *                   entry 3: maximum v along u = 1;
 */
typedef IGRdouble ParmRange[4];

/* the following structure used to store fillet imposed boundary
 * num_minbnd_edges: number of edges in the side closing to v = 0
 * minbnd_edges_index: index of the starting edge in the array
 *                     me->bound_edges[]. So the GRid of the edges are from
 *                     me->bound_edges[minbnd_edges_index] to
 *                     me->bound_edges[minbnd_edges_index+num_minbnd_edges-1]
 * num_maxbnd_edges and maxbnd_edges_index are silimar.
 */
struct FilletBnd
{
  IGRint num_minbnd_edges, num_maxbnd_edges;
  IGRint minbnd_edges_index, maxbnd_edges_index;
  struct GRid edge_u0, edge_u1;
};

/* the following structure is used to store the cut back curve information
 * type: one of ISOCV, PLANECUT, or BOUNDARY
 */
struct CutBack
{
  IGRshort type;
  IGRpoint endpt1, endpt2;	/* end points of the cut back curve */
  IGRpoint midpt;		/* middle point of the cut back curve */
  IGRpoint testpt1, testpt2;
  IGRvector testvec1, testvec2;	/* normals of end points to fillet surface */
  union 
  {
    IGRdouble isocv_parm;	/* iso curve parameter */
    struct 
    {
      IGRvector normal;		/* normal of the plane */
      IGRint which_u;		/* start point on u=0 or u=1 */
    } cutpln;			/* plane cut */
    struct
    {
      IGRint index, num_edges;	/* starting edge and number of edges */
    } bdry;			/* boundary of the fillet */
  } cutcv;
};

/*
 * This data structure used to record information about special point
 *
 * pt_coord:	coordinates of the point
 * test_coord:	this is the midpoint coordinates of the same edge where
 *		the special point lies
 * which_fillet: index into located fillets array (me->elems[])
 * surf_index:	index into the array of surfaces that blending curves
 *		lie on (me->on_surfs[])
 * pt_id:	GRid of the construct graphical object
 * edge_id:	GRid of the edge on which the special point lies
 * used:	TRUE if a blend curve connecting this special point has
 *		constructed
 *
 * NOTE: which_fillet will be set to -1 if the special point lies on an
 *       edge of the surface but not located fillet (via dynamics to 
 *       connect to a special edge). In such case, surf_index should be
 *       used in conjunction with edge_id to obtain edge geometry in
 *       EMget_bcxyz_geom call.
 */
struct SpecialPnt
{
  IGRpoint pt_coord, test_coord;
  IGRint which_fillet, surf_index;
  struct GRid pt_id, edge_id;
  IGRboolean used;
};

struct BlendCv
{
  IGRboolean newpt;
  IGRint index1, index2, surf_index;
  IGRdouble u1, u2, ratio1, ratio2;
  IGRboolean dir1, dir2;
  struct IGRbsp_curve *bspcv, *uvcv;
  struct IGRpolyline uvln;
};

/*
 * This structure is used as an argument to the iso curve dynamics
 * function called by dp$dynamics.
 */
struct ECDYN_isocv
{
  struct DPele_header *disp_hd;
  struct BSgeom_bsp_surf geomsurf;
  struct GRlc_info *lc_surf;
  ParmRange parmrange;
  struct IGRbsp_curve *min_xyzedges, *max_xyzedges;
  IGRint num_min_xyzedges, num_max_xyzedges;
  IGRshort pole_direction;
  IGRpoint endpt1, endpt2, midpt;
  IGRpoint testpt1, testpt2;
  IGRvector testvec1, testvec2;
  IGRdouble upar, vpar;
  IGRint side, rc;
};

/*
 * This structure is used as an argument to the defining start point
 * of plane cut dynamics function called by dp$dynamics.
 */
struct ECDYN_startpt
{
  struct DPele_header disp_hd[2];
  struct IGRbsp_surface *surf;
  struct IGRbsp_curve *bdrycv;
  IGRdouble min_parm, max_parm, uparm;
  IGRpoint min_pt, max_pt;
  IGRint weight1, weight2;
  IGRdouble startpt[3];
  IGRpoint testpt;
  IGRvector testvec;
  IGRint rc;
};

/*
 * This structure is used as an argument to the defining the plane cut
 * dynamics function called by dp$dynamics.
 */
struct ECDYN_planecut
{
  struct DPele_header disp_hd[2];
  struct GRlc_info *lc_surf;
  struct IGRbsp_surface *surf;
  struct IGRbsp_curve *bdrycv;
  IGRdouble min_parm, max_parm, uparm;
  IGRpoint min_pt, max_pt;
  IGRint weight1, weight2;
  IGRdouble startpt[3], normal[3];
  IGRpoint endpt, midpt;
  IGRpoint testpt;
  IGRvector testvec;
  IGRint rc;
};

/*
 * This structure is used as an argument to the specifying blend curve dynamics
 * function called by dp$dynamics.
 */
struct ECDYN_blendcv
{
  struct DPele_header disp_hd[2];
  struct SpecialPnt *ptr_spl_pts;
  IGRint num_spl_pts, *pt_indices, num_edges;
  struct IGRbsp_curve *edges, *fil_edges;
  IGRpoint testpt;
  IGRint index, rc;
};

/*
 * This structure is used as an argument to the specifying blend point on
 * a selected edge function called by dp$dynamics.
 */
struct ECDYN_blendpt
{
  struct DPele_header disp_hd[3];
  IGRpoint edge_pt, testpt;
  IGRint rc;
};

instance ECcrbldsf
{
  Form stat_fm;
  IGRboolean form_displayed, form_avail, moveon;
  IGRint fm_ratio1, fm_ratio2;
  IGRdouble ratio1, ratio2;

  IGRint num_solid;
  variable struct GRlc_info solids[ELEMS_ARRAY_INCR];
  variable struct GRlc_info cls_surfs[ELEMS_ARRAY_INCR];

  IGRint which_u, curr_flt, curr_onsurf_index;
  IGRint curr_pnt_index, curr_unused, curr_blend_index;

  struct IGRbsp_curve *bsp_spl_edge, *bsp_start_edge;
  struct GRid spl_edge_id, start_edge_id, blend_sf;

  struct ECDYN_isocv isocv_buff;
  struct ECDYN_startpt startpt_buff;
  struct ECDYN_planecut planecut_buff;
  struct ECDYN_blendcv blendcv_buff;
  struct ECDYN_blendpt blendpt_buff;
  
  variable ParmRange parm_ranges[ELEMS_ARRAY_INCR];
  variable struct FilletBnd fillet_bounds[ELEMS_ARRAY_INCR];
  variable struct GRid bound_edges[ELEMS_ARRAY_INCR];
  variable struct CutBack cutback_cvs[ELEMS_ARRAY_INCR];
  variable struct GRid on_surfs[ELEMS_ARRAY_INCR];
  variable struct SpecialPnt spl_pts[ELEMS_ARRAY_INCR];
  variable struct BlendCv blend_cvs[ELEMS_ARRAY_INCR];
};

override init,
         wakeup,
         super_cmd.sleep,
         delete,
         execute,
         status_disp;

message dynamics(IGRlong *msg; IGRint dynamcis);

message chk_gen_point(IGRlong *msg; IGRpoint gen_pt; IGRint type);

message refine_cut_curve_endpoints(IGRlong *msg; IGRint index;
				   struct GRid *cls_sf1, *cls_sf2);

message construct_spl_point(IGRlong *msg; IGRpoint pt_coord, test_coord;
			    struct GRid *on_surf, *edge_id; IGRint fillet);

message construct_blend_curve(IGRlong *msg; IGRpoint pt1, pt2;
			      IGRint index1, index2, surf_index;
			      IGRboolean type);

message modify_blend_curve(IGRlong *msg);

message construct_blend_surf(IGRlong *msg);

message check_blend_bdry_intersect(IGRlong *msg);

message do_form(IGRlong *msg; IGRint form_label, gadget_label;
		IGRdouble value);

end specification ECcrbldsf;
