
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

/* ASAPII_main.c */

#define ASAPII_GLOBALS 1

#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gpipe.h"
#include "hsdef.h"
#include "hsurf.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "hsmath.h"
#include "AAdef.h"
#include "AAcomm.h"
#include "bsparameters.h"
#include "EG.h"

#include <values.h>
#include <stdio.h>


/*---communications area------------------------------------------------------*/

/* request_buffer 0.5M, answer_buffer 2M */
#define REQUEST_BUFSIZE 0x080000/sizeof(IGRdouble)
#define ANSWER_BUFSIZE  0x200000/sizeof(IGRdouble)

volatile IGRint    ASAPII_comm_int[13] = {0};
volatile IGRchar   *ASAPII_comm_ptr[8];
volatile IGRdouble zz_request_buffer[REQUEST_BUFSIZE];
volatile IGRdouble zz_answer_buffer[ANSWER_BUFSIZE];

/* NOTE: buffer names chosen so they will get loaded as the very LAST items. */
/*	 this allows many changes (including buffer sizes) without	*/
/*	 re-compiling the Clipper side of communications.		*/


/*---asapII globals-----------------------------------------------------------*/

#if STATS
IGRint	num_surfs, num_curves, num_lines, num_activates;
IGRint	num_requests, largest_request, request_total;
IGRint	request_high_bytes, request_high_num;
IGRint	num_answers, largest_answer, answer_total;
IGRint	answer_high_bytes, answer_high_num;
IGRint	num_tri, num_vector;
#define INCR(x) ++x;
#else
#define INCR(x)
#endif

extern EGRGBColor EGcolor;


/*---extern functions---------------------------------------------------------*/

extern IGRint AACL_get_answer_ptr (int, int, char **);
extern void AACL_answer_complete (void);
extern void memcpy (char *, char *, int);
extern void GPCreatePipe (int, int);
extern void fgcolor (int, int);
extern void linestyle (int, int);
extern void weight (int, int);


/*---timers-------------------------------------------------------------------*/

#if TIMING
float request_wait_time = 0.0;
float request_time = 0.0;
float compute_time = 0.0;
float answer_wait_time = 0.0;
float answer_time = 0.0;
float other_time = 0.0;
extern float dtime (float *);

void AA_timer (float *clock)
{
  float timer;
  static float *prev_clock = NULL;

  timer = dtime (NULL);
  if (prev_clock) *prev_clock += timer;
  prev_clock = clock;
} /* AA_timer */
#endif


#if DUMPS
int dumps_enabled = 0;

/*---dump_poles---------------------------------------------------------------*/

void dump_poles
 (IGRlong	rational,
  IGRlong	num_poles,
  IGRdouble	*poles,
  IGRdouble	*weights
 )
{
  IGRint j;

  if (rational)
  {
    fprintf (stderr, "  Poles (u, x, y, z, w) :\n");
    for (j = 0; j < num_poles; ++j)
      fprintf (stderr, "%5d %13.5lf %13.5lf %13.5lf %13.5lf\n", j,
			poles[(j) * 3] / weights[j],
			poles[(j) * 3 + 1] / weights[j],
			poles[(j) * 3 + 2] / weights[j],
			weights[j]);
  }
  else
  {
    fprintf (stderr, "  Poles (u, x, y, z) :\n");
    for (j = 0; j < num_poles; ++j)
      fprintf (stderr, "%5d %13.5lf %13.5lf %13.5lf\n", j,
			poles[(j) * 3],
			poles[(j) * 3 + 1],
			poles[(j) * 3 + 2]);
  }
} /* dump_poles */


/*---HSdump_curve-------------------------------------------------------------*/

static void HSdump_curve (struct IGRbsp_curve *curve)
{
  IGRint index;

  fprintf (stderr, "\n\nCurve Definition:\n");
  fprintf (stderr, "  order      = %d\n", curve->order);
  fprintf (stderr, "  num_poles  = %d\n", curve->num_poles);
  fprintf (stderr, "  num_knots  = %d\n", curve->num_knots);
  fprintf (stderr, "  rational   = %d\n\n", curve->rational);
  fprintf (stderr, "  num_bound  = %d\n\n", curve->num_boundaries);

  dump_poles ((IGRlong) curve->rational, curve->num_poles,
		curve->poles, curve->weights);

  fprintf (stderr, "\n  knots:\n");
  for (index = 0; index < curve->num_knots; ++index)
    fprintf (stderr, "%17.9lf\n", curve->knots[index]);

  if (curve->num_boundaries)
  {
    fprintf (stderr, "\n  boundaries:\n");
    for (index = 0; index < curve->num_boundaries; ++index)
      fprintf (stderr, "%17.9lf  %17.9lf\n",
		curve->bdrys[index*2], curve->bdrys[index*2+1]);
  }
} /* HSdump_curve */


/*---HSdump_surface-----------------------------------------------------------*/

static HSdump_surface
 (struct IGRbsp_surface	*surf)	/* input - surface definition */

/*
 * Dumps out the surface definition to standard output. Debugging tool only.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

{
  IGRint vi, ui, index, point_cnt;

  fprintf (stderr, "\n\nSurface Definition:\n");
  fprintf (stderr, "  u_order       = %d\n", surf->u_order);
  fprintf (stderr, "  v_order       = %d\n", surf->v_order);
  fprintf (stderr, "  u_num_poles   = %d\n", surf->u_num_poles);
  fprintf (stderr, "  v_num_poles   = %d\n", surf->v_num_poles);
  fprintf (stderr, "  u_num_knots   = %d\n", surf->u_num_knots);
  fprintf (stderr, "  v_num_knots   = %d\n", surf->v_num_knots);
  fprintf (stderr, "  rational      = %d\n\n", surf->rational);

  if (surf->rational != 0)
  {
    fprintf (stderr, "  Poles (v, u, x, y, z, w) :\n");

    for (vi=0; vi<surf->v_num_poles; vi++)
    {
      for (ui=0; ui<surf->u_num_poles; ui++)
	fprintf (stderr, "%5d %5d %13.5lf %13.5lf %13.5lf %13.5lf\n",
		 vi, ui,
		 surf->poles[((vi*surf->u_num_poles) +ui) * 3] /
			surf->weights[(vi*surf->u_num_poles) +ui],
		 surf->poles[((vi*surf->u_num_poles) +ui) * 3 + 1] /
			surf->weights[(vi*surf->u_num_poles) +ui],
		 surf->poles[((vi*surf->u_num_poles) +ui) * 3 + 2] /
			surf->weights[(vi*surf->u_num_poles) +ui],
		 surf->weights[(vi*surf->u_num_poles) +ui]);

      fprintf (stderr, "\n");
    }
  }
  else
  {
    fprintf (stderr, "  Poles (v, u, x, y, z) :\n");

    for (vi=0; vi<surf->v_num_poles; vi++)
    {
      for (ui=0; ui<surf->u_num_poles; ui++)
	fprintf (stderr, "%5d %5d %13.5lf %13.5lf %13.5lf\n",
		 vi, ui,
		 surf->poles[((vi*surf->u_num_poles) +ui) * 3],
		 surf->poles[((vi*surf->u_num_poles) +ui) * 3 + 1],
		 surf->poles[((vi*surf->u_num_poles) +ui) * 3 + 2]);

      fprintf (stderr, "\n");
    }
  }

  fprintf (stderr, "\n  U knots:\n");

  for (index=0; index<surf->u_num_knots; index++)
    fprintf (stderr, "%17.9lf\n", surf->u_knots[index]);

  fprintf (stderr, "\n  V knots:\n");

  for (index=0; index<surf->v_num_knots; index++)
	  fprintf (stderr, "%17.9lf\n", surf->v_knots[index]);

  for (index=0; index<surf->num_boundaries; index++)
  {
    fprintf (stderr, "\n  Boundary %d:\n", index);

    for (point_cnt=0; point_cnt<surf->bdrys[index].num_points; point_cnt++)
      fprintf (stderr, "%17.9lf %17.9lf \n",
	       surf->bdrys[index].points[2 * point_cnt],
	       surf->bdrys[index].points[2 * point_cnt + 1]);
  }
}
#endif

/*---aa_bs_change_par---------------------------------------------------------*/

void aa_bs_change_par (IGRdouble *values)
{
  IGRint rc;
  extern void BSchangepar (IGRint *, IGRint, IGRdouble);
  extern void BSchgdeppar (IGRdouble, IGRint *);

#if DEBUG_INPUT
  fprintf (stderr, "bspar: %lf %lf %lf %lf\n", values[0], values[1],
			values[2], values[3]);
#endif
  BSchgdeppar (values[0], &rc);
  BSchangepar (&rc, BSTOLCHRDHT, values[1]);
  BSchangepar (&rc, BSTOLOFFSET, values[2]);
  BSchangepar (&rc, BSTOLARCLEN, values[3]);
} /* aa_bs_change_par */


/*---send_clip_range----------------------------------------------------------*/

void send_clip_range (char *clip_range)
{
  int	size = 6 * sizeof (IGRdouble);
  char	*buf_ptr;

  AAtimer (&answer_wait_time);
  do
  {
    if (!AACL_get_answer_ptr (size, AA_CLIP_RANGE, &buf_ptr))
    {
      fprintf (stderr, "PANIC: pack too big; can't get here!!\n");
      break;
    }
  }
  while (!buf_ptr);

  AAtimer (&answer_time);
  memcpy (buf_ptr, (char *) clip_range, size);
  AACL_answer_complete ();

} /* send_clip_range */


/*---aa_bsurf_tiler-----------------------------------------------------------*/

void aa_bsurf_tiler (char *ptr)
{
  IGRint bound_size, j;
  struct IGRbsp_surface *surf;
  struct qs
  { IGRdouble  range[6];
    IGRdouble  surface_tol, basis_tol, dist_tol, win_cht;
    IGRdouble  u_range[2], v_range[2];
    IGRdouble  clip_range[6];
    struct HS_element_rendering_parms render_parms;
    IGRint     pipe_no, color, options, acc_mode, accuracy;
    IGRint     ele_shading_style, part_of_solid, dont_cull;
    EGRGBColor EGcolor;
  } *q;
  extern void HSbsurf_tiler ();

  surf = (struct IGRbsp_surface *) ptr;
  (char *) q = ptr + on_boundary_of (sizeof (struct IGRbsp_surface), IGRdouble)+
		surf->u_num_poles * surf->v_num_poles * 3 * sizeof (IGRdouble) +
		surf->u_num_knots * sizeof (IGRdouble) +
		surf->v_num_knots * sizeof (IGRdouble);
  if (surf->rational)
    (char *) q += surf->u_num_poles * surf->v_num_poles * sizeof (IGRdouble);

  for (bound_size = j = 0; j < surf->num_boundaries; ++j)
    {
    bound_size += (sizeof (struct IGRbsp_bdry_pts) +
		 (2 * surf->bdrys[j].num_points * sizeof (IGRdouble)));
    }
  (char *) q += bound_size;

#if DEBUG_INPUT
  { char bf[120];
    sprintf (bf, "sf 0x%x u#=%d v#=%d req=%d ans=%d sz=%d\n",
		  ptr - 8, surf->u_num_poles, surf->v_num_poles,
		  REQUEST_BUFFER_COUNT, ANSWER_BUFFER_COUNT,
		  (char *) q - ptr + 8 * sizeof (IGRint) +
			  20 * sizeof (IGRdouble) + sizeof (EGRGBColor));
    fprintf (stderr, "%s", bf);
  }
#endif

#if DUMPS
  if (dumps_enabled)
    HSdump_surface (surf);
#endif

  EGcolor = q->EGcolor;
  send_clip_range ((char *) q->clip_range);
  AAtimer (&compute_time);
  HSbsurf_tiler (q->pipe_no,
		 surf,
		 q->range,
		 q->color,
		 q->options,
		 q->ele_shading_style,
		 &q->render_parms,
		 q->part_of_solid,
		 q->surface_tol,
		 q->basis_tol,
		 q->dist_tol,
		 q->dont_cull,
		 q->acc_mode,
		 q->accuracy,
		 q->win_cht,
		 q->u_range,
		 q->v_range,
		 q->clip_range);
} /* aa_bsurf_tiler */


/*---aa_bcurve_tiler----------------------------------------------------------*/

void aa_bcurve_tiler (char *ptr)
{
  struct IGRbsp_curve *curve;
  struct
  { IGRdouble  win_cht;
    IGRdouble  clip_range[6];
    IGRint     pipe_no, color, options, acc_mode, accuracy, paint;
    EGRGBColor EGcolor;
  } *q;
  extern void HSbcurve_tiler ();

  curve = (struct IGRbsp_curve *) ptr;
  (char *) q = ptr + on_boundary_of (sizeof (struct IGRbsp_curve), IGRdouble) +
		curve->num_poles * 3 * sizeof (IGRdouble) +
		curve->num_boundaries * 2 * sizeof (IGRdouble) +
		curve->num_knots * sizeof (IGRdouble);
  if (curve->rational)
    (char *) q += curve->num_poles * sizeof (IGRdouble);

#if DUMPS
  if (dumps_enabled)
    HSdump_curve (curve);
#endif
#if DEBUG_INPUT
  {
    char bf[120];
    sprintf (bf, "cv 0x%x pol=%d req=%d ans=%d sz=%d\n",
		ptr - 8, curve->num_poles, REQUEST_BUFFER_COUNT,
		ANSWER_BUFFER_COUNT, (char *) q - ptr + 7 * sizeof (IGRdouble) +
				6 * sizeof (IGRint) + sizeof (EGRGBColor));
    fprintf (stderr, "%s", bf);
  }
#endif

  EGcolor = q->EGcolor;
  send_clip_range ((char *) q->clip_range);
  AAtimer (&compute_time);
  HSbcurve_tiler (q->pipe_no,
		  curve,
		  q->color,
		  q->options,
		  q->paint,
		  q->acc_mode,
		  q->accuracy,
		  q->win_cht,
		  q->clip_range);
} /* aa_bcurve_tiler */


/*---aa_init_shd_window-------------------------------------------------------*/

void aa_init_shd_window (char *ptr)
{
  struct isw
  { IGRint screen, win_no, pipe_no, x_dits, y_dits, shading_style;
  } *q;
  extern void HSinit_shading_window ();

  q = (struct isw *) ptr;
  HSinit_shading_window (q->screen,
			 q->win_no,
			 q->pipe_no,
			 q->x_dits,
			 q->y_dits,
			 q->shading_style);
} /* aa_init_shd_window */


/*---aa_setup_shd_window------------------------------------------------------*/

void aa_setup_shd_window (char *ptr)
{
  struct ssw
  { IGRdouble	wld_to_view[4][4], vw_vol[6];
    IGRdouble	eye_pt[3], vrp[3], vpn[3], vup[3];
    IGRdouble	fit_range[6];
    IGRdouble	clip_range[6];
    IGRdouble	transformation_matrix[4][4];
    IGRdouble	rotation_matrix[4][4];
    IGRdouble	max_shade_near;
    IGRdouble	max_shade_far;
    IGRdouble	world_to_viewport_scale;
    IGRdouble	x_persp_scale;
    IGRdouble	y_persp_scale;
    IGRdouble	z_persp_scale;
    struct HS_light_source global_lights[8];
    struct HS_light_source ambient_light;
    IGRint	pipe_no, win_no;
    IGRint	org_x, org_y;
    IGRint	x_dits, y_dits;
    IGRint	perspective;
    IGRint	grid;
    IGRint	depth_cueing;
  } *q;
  IGRboolean can_use_edge2 = TRUE;
  extern void HSsetup_shading_window ();

  q = (struct ssw *) ptr;
  HSsetup_shading_window (q->wld_to_view,
			  q->vw_vol,
			  q->eye_pt,
			  q->vrp,
			  q->vpn,
			  q->vup,
			  q->pipe_no, q->win_no,
			  q->org_x, q->org_y, q->x_dits, q->y_dits,
			  q->fit_range,
			  q->clip_range,
			  q->transformation_matrix,
			  q->rotation_matrix,
			  q->global_lights,
			  &q->ambient_light,
			  q->max_shade_near, q->max_shade_far,
			  q->world_to_viewport_scale,
			  q->x_persp_scale,
			  q->y_persp_scale,
			  q->z_persp_scale,
			  q->perspective,
			  q->grid,
			  q->depth_cueing,
			  can_use_edge2);
} /* aa_setup_shd_window */


/*---aa_reset_xform_matrix----------------------------------------------------*/

void aa_reset_xform_matrix (char *ptr)
{
  struct rxm
  { IGRdouble	t_matrix[4][4];
    IGRdouble	r_matrix[4][4];
    IGRdouble	post_rotation[4][4];
    IGRint	window_no;
  } *q;
  extern void HSreset_transformation_matrix ();

  q = (struct rxm *) ptr;
  HSreset_transformation_matrix (q->window_no,
				 q->t_matrix,
				 q->r_matrix,
				 q->post_rotation);
} /* aa_reset_xform_matrix */


/*---aa_wireframe_clip_range--------------------------------------------------*/

void aa_wireframe_clip_range (char *p)
{
  struct wcr
  { IGRdouble	range[6];
    IGRint	front, back, gpipe_id;
  } *q;
  static struct wcr saved_q;
  extern void GPPutViewport ();
  extern void GPSetZclip (int, int, int);

  if (p)
  {
    q = (struct wcr *) p;
    saved_q = *q;
  }
  else q = &saved_q;
  GPCreatePipe (q->gpipe_id, 0);
  GPPutViewport(q->gpipe_id, q->range[0], q->range[1], q->range[2],
		q->range[3], q->range[4], q->range[5]);
  GPSetZclip(q->gpipe_id, q->front, q->back);
} /* aa_wireframe_clip_range */


/*---aa_stroke_xform_matrix---------------------------------------------------*/

void aa_stroke_xform_matrix (IGRchar *cp)
{
  int gpipe_id, is_persp;
  double *dp;
  extern void GPPutMatrix (int, double *);
  extern void GPCharMatrix (int);
  extern void GPBsplineTol (int, double, double);

  gpipe_id = *(int *) cp;
  dp = (double *) (cp + 2 * sizeof (int));
  is_persp = dp[3] != 0.0 || dp[7] != 0.0 || dp[11] != 0.0 ? 1 : -1;
#if DEBUG_INPUT
  fprintf (stderr, "strok mtx: cp 0x%x  dp 0x%x  is_p %d\n", cp, dp, is_persp);
  fprintf (stderr, "%lf %lf %lf %lf\n", dp[0], dp[1], dp[2], dp[3]);
  fprintf (stderr, "%lf %lf %lf %lf\n", dp[4], dp[5], dp[6], dp[7]);
  fprintf (stderr, "%lf %lf %lf %lf\n", dp[8], dp[9], dp[10], dp[11]);
  fprintf (stderr, "%lf %lf %lf %lf\n", dp[12], dp[13], dp[14], dp[15]);
#endif
  GPCreatePipe (gpipe_id, is_persp);
  GPPutMatrix (gpipe_id, dp);
  GPCharMatrix (gpipe_id);
  dp += 16;
#if DEBUG_INPUT
  fprintf (stderr, "tols: %lf %lf\n", dp[0], dp[1]);
#endif
  GPBsplineTol (gpipe_id, dp[0], dp[1]);
} /* aa_stroke_xform_matrix */


/*---aa_stroke_curve----------------------------------------------------------*/

void aa_stroke_curve (char *p)
{
  struct sc
  { IGRint gpipe_id, order, num_poles, rational, num_boundaries,
	   base_color, bundle_size, options, color, style, weight, has_attr;
  } *q;
  IGRint	*attr_indexs = NULL;
  IGRdouble	*poles, *knots, *weights = NULL, *boundaries = NULL;
  GPattribute	*attr_bundles = NULL;
  IGRchar	*ptr;
  extern void GPBsplineCurve ();

  q = (struct sc *) p;
  ptr = p + sizeof (*q);
  poles = (IGRdouble *) ptr;
  ptr += q->num_poles * 3 * sizeof (IGRdouble);
  knots = (IGRdouble *) ptr;
  ptr += (q->num_poles + q->order) * sizeof (IGRdouble);

  if (q->rational)
  {
    weights = (IGRdouble *) ptr;
    ptr += q->num_poles * sizeof (IGRdouble);
  }

  if (q->num_boundaries)
  {
    boundaries = (IGRdouble *) ptr;
    ptr += q->num_boundaries * 2 * sizeof (IGRdouble);
  }

  if (q->has_attr)
  {
    attr_indexs = (IGRint *) ptr;
    ptr += (2 * q->num_boundaries + 1) * sizeof (IGRint);
    attr_bundles = (GPattribute *) ptr;
  }

  fgcolor (0, q->color);
  linestyle (0, q->style);
  weight (0, q->weight);

#if DUMPS
  if (dumps_enabled)
  {
    struct IGRbsp_curve curve;

    curve.order = q->order;
    curve.periodic = 0;
    curve.non_uniform = 1;
    curve.num_poles = q->num_poles;
    curve.poles = poles;
    curve.num_knots = q->num_poles + q->order;
    curve.knots = knots;
    curve.rational = q->rational;
    curve.weights = weights;
    curve.planar = 0;
    curve.phy_closed = 0;
    curve.num_boundaries = q->num_boundaries;
    curve.bdrys = boundaries;
    HSdump_curve (&curve);
  }
#endif

  GPCreatePipe (q->gpipe_id, 0);
  GPBsplineCurve (q->gpipe_id, q->order, q->num_poles, poles, knots, weights,
	q->rational, q->num_boundaries, boundaries, q->base_color,
	attr_indexs, attr_bundles, q->bundle_size, q->options);

} /* aa_stroke_curve */


/*---aa_stroke_surface--------------------------------------------------------*/

void aa_stroke_surface (char *p)
{
  struct ss
  { IGRint	gpipe_id, u_order, v_order, u_num_poles, v_num_poles,
		rational, u_num_rules, v_num_rules, num_boundaries, options,
		color, style, weight;
  } *q;
  IGRint	j, *ip, *u_num_bound = NULL, *v_num_bound = NULL;
  IGRdouble	*dp, *poles, *u_knots, *v_knots, *weights = NULL;
  IGRdouble	*u_rule_values = NULL, *v_rule_values = NULL;
  IGRdouble	**u_bdrys = NULL, **v_bdrys = NULL;
  GPboundary	*bdry_ptr = NULL;
  extern void GPBsplineSurface ();
  extern char *malloc (int);
  extern void free (char *);

  q = (struct ss *) p;
  ip = (int *) (q + 1);

  if (q->u_num_rules)
  {
    u_num_bound = ip;
    ip += q->u_num_rules;
  }

  if (q->v_num_rules)
  {
    v_num_bound = ip;
    ip += q->v_num_rules;
  }

  dp = (double *) on_boundary_of (ip, IGRdouble);

  poles = dp;
  dp += q->u_num_poles * q->v_num_poles * 3;

  u_knots = dp;
  dp += q->u_num_poles + q->u_order;

  v_knots = dp;
  dp += q->v_num_poles + q->v_order;

  if (q->rational)
  {
    weights = dp;
    dp += q->u_num_poles * q->v_num_poles;
  }

  if (q->u_num_rules)
  {
    u_rule_values = dp;
    dp += q->u_num_rules;
    u_bdrys = (IGRdouble **) malloc (q->u_num_rules * sizeof (IGRdouble *));
  }

  if (q->v_num_rules)
  {
    v_rule_values = dp;
    dp += q->v_num_rules;
    v_bdrys = (IGRdouble **) malloc (q->v_num_rules * sizeof (IGRdouble *));
  }

  for (j = 0; j < q->u_num_rules; ++j)
  {
    u_bdrys[j] = dp;
    dp += u_num_bound[j] * 2;
  }

  for (j = 0; j < q->v_num_rules; ++j)
  {
    v_bdrys[j] = dp;
    dp += v_num_bound[j] * 2;
  }

  if (q->num_boundaries)
    bdry_ptr = (GPboundary *) dp;

#if DUMPS
  if (dumps_enabled)
  {
    struct IGRbsp_surface surf;

    surf.u_order = q->u_order;
    surf.v_order = q->v_order;
    surf.u_periodic = surf.v_periodic = FALSE;
    surf.u_non_uniform = surf.v_non_uniform = TRUE;
    surf.u_num_poles = q->u_num_poles;
    surf.v_num_poles = q->v_num_poles;
    surf.poles = poles;
    surf.u_num_knots = q->u_num_poles + q->u_order;
    surf.u_knots = u_knots;
    surf.v_num_knots = q->v_num_poles + q->v_order;
    surf.v_knots = v_knots;
    surf.rational = q->rational;
    surf.weights = weights;
    surf.planar = surf.u_phy_closed = surf.v_phy_closed =
			surf.pos_orient = surf.on_off = FALSE;
    surf.num_boundaries = q->num_boundaries;
    surf.bdrys = (struct IGRbsp_bdry_pts *) bdry_ptr;
    HSdump_surface (&surf);
  }
#endif

  fgcolor (0, q->color);
  linestyle (0, q->style);
  weight (0, q->weight);

  GPCreatePipe (q->gpipe_id, 0);
  GPBsplineSurface (q->gpipe_id, q->u_order, q->v_order,
		    q->u_num_poles, q->v_num_poles,
		    poles, u_knots, v_knots, weights,
		    q->rational, q->u_num_rules, q->v_num_rules,
		    u_rule_values, v_rule_values,
		    NULL, NULL, NULL, NULL, 0, 0,
		    u_num_bound, v_num_bound, u_bdrys, v_bdrys,
		    q->num_boundaries, bdry_ptr, q->options);

  if (q->u_num_rules) free ((char *) u_bdrys);
  if (q->v_num_rules) free ((char *) v_bdrys);

} /* aa_stroke_surface */


/*---aa_stroke_linestring-----------------------------------------------------*/

void aa_stroke_linestring (char *p)
{
  struct sl
  { IGRint gpipe_id, num_points, color, style, weight, pad;
  } *q;
  extern void GPLinestr3D (int, IGRdouble*, int, int);

  q = (struct sl *) p;
  fgcolor (0, q->color);
  linestyle (0, q->style);
  weight (0, q->weight);

  GPCreatePipe (q->gpipe_id, 0);
  GPLinestr3D (q->gpipe_id, (IGRdouble *)(p + sizeof (*q)), q->num_points, 0);

} /* aa_stroke_linestring */


/*---aa_print_statistics------------------------------------------------------*/

void aa_print_statistics (void)
{
  extern void alloc_statistics_print (char *);
#if TIMING
  float ttot, tcom;
#endif

  AAtimer (NULL);
#if TIMING
  tcom = compute_time + request_time + answer_time;
  ttot = tcom + request_wait_time + answer_wait_time;
#endif
#if STATS
  fprintf (stderr, "--- asapII statistics ---\n");
  fprintf (stderr, "surfaces %d  curves %d  lines %d  activates %d",
			num_surfs, num_curves, num_lines, num_activates);
  if (num_tri)
    fprintf (stderr, "\ntriangles %d", num_tri);
#if TIMING
  if (num_tri)
  {
    if (ttot > 0.0)
      fprintf (stderr, "  /sec %6.0f", (float) num_tri / ttot);
    if (tcom > 0.0)
      fprintf (stderr, "  com/sec %6.0f", (float) num_tri / tcom);
  }
#endif
  if (num_vector)
    fprintf (stderr, "\nvectors %d", num_vector);
#if TIMING
  if (num_vector)
  {
    if (ttot > 0.0)
      fprintf (stderr, "  /sec %6.0f", (float) num_vector / ttot);
    if (tcom > 0.0)
      fprintf (stderr, "  com/sec %6.0f", (float) num_vector / tcom);
  }
#endif
  fprintf (stderr, "\nrequests %7d  average %6d  high # %d\n", num_requests,
	num_requests ? (request_total / num_requests) : 0, request_high_num);
  fprintf (stderr, "  total %8d  largest %6d  high %% %5.2f\n",
		request_total, largest_request,
		(float) request_high_bytes * 100.0 /
		(float) sizeof (zz_request_buffer));
  fprintf (stderr, "answers  %7d  average %6d  high # %d\n", num_answers,
	num_answers ? (answer_total / num_answers) : 0, answer_high_num);
  fprintf (stderr, "  total %8d  largest %6d  high %% %5.2f\n",
		answer_total, largest_answer,
		(float) answer_high_bytes * 100.0 /
		(float) sizeof (zz_answer_buffer));
  num_surfs = 0;
  num_curves = 0;
  num_lines = 0;
  num_tri = 0;
  num_vector = 0;
  num_activates = 0;
  num_requests = 0;
  largest_request = 0;
  request_total = 0;
  request_high_bytes = 0;
  request_high_num = 0;
  num_answers = 0;
  largest_answer = 0;
  answer_total = 0;
  answer_high_bytes = 0;
  answer_high_num = 0;
#endif
#if TIMING
  fprintf (stderr, "--- asapII times ---\n");
  fprintf (stderr, "request %7.3f  wait %7.3f\n",
				request_time, request_wait_time);
  fprintf (stderr, "compute %7.3f\n", compute_time);
  fprintf (stderr, "answer  %7.3f  wait %7.3f\n",
				answer_time, answer_wait_time);
  fprintf (stderr, "  compt %7.3f  totl %7.3f\n", tcom, ttot);
  request_wait_time = 0.0;
  request_time = 0.0;
  compute_time = 0.0;
  answer_wait_time = 0.0;
  answer_time = 0.0;
#endif
#if DEBUG_ALLOC
  alloc_statistics_print (NULL);
#endif
#if TIMING || STATS
  fprintf (stderr, "---\n");
#endif
} /* aa_print_statistics */


/*---AA_report_error----------------------------------------------------------*/

void AA_report_error (int err_code)
{
  char	*buf_ptr;

  AAtimer (&answer_wait_time);
  do
  {
    if (!AACL_get_answer_ptr (sizeof (int), AA_REPORT_ERROR, &buf_ptr))
    {
      fprintf (stderr, "PANIC: pack too big; can't get here!!\n");
      break;
    }
  }
  while (!buf_ptr);

  AAtimer (&answer_time);
  memcpy (buf_ptr, (char *) &err_code, sizeof (int));
  AACL_answer_complete ();
} /* AA_report_error */


/*---main---------------------------------------------------------------------*/

main
 (int	argc,
  char	*argv[]
 )
{
  IGRint request, sts;
  char *request_ptr;
  extern int mprotect (char *, int, int);
  extern int AACL_get_request_ptr (int *, char **);
  extern void AACL_request_complete (void);
  extern void HSactivate_window (int);
  extern void HSdelete_active_window (void);
  extern void HSset_processing_mode (unsigned int);

#if DEBUG_IT
  fprintf (stderr, "begin ASAPII_main\n");
#endif

/* temporary -- disable floating point traps */
  _ASM ("ld.c	fsr,r31");
  _ASM ("andnot	0x20,r31,r31");
  _ASM ("st.c	r31,fsr");

/* disable cache for communication pages */
  sts = mprotect ((char *) ASAPII_comm_int, sizeof (ASAPII_comm_int), 0x57);
  sts = mprotect ((char *) ASAPII_comm_ptr, sizeof (ASAPII_comm_ptr), 0x57);
  sts = mprotect ((char *) zz_request_buffer, sizeof (zz_request_buffer), 0x57);
  sts = mprotect ((char *) zz_answer_buffer, sizeof (zz_answer_buffer), 0x57);

  CLIPPER_WANTS_REQUEST = 0;
  ASAPII_WANTS_REQUEST = 0;
  FAVORED_REQUEST  = CLIPPER_PROCESS;
  CLIPPER_WANTS_ANSWER = 0;
  ASAPII_WANTS_ANSWER = 0;
  FAVORED_ANSWER  = ASAPII_PROCESS;
  REQUEST_BUFFER_COUNT = 0;
  REQUEST_BUFFER_METER = 0;
  REQUEST_BUFFER_SIZE = sizeof (zz_request_buffer);
  ANSWER_BUFFER_COUNT = 0;
  ANSWER_BUFFER_METER = 0;
  ANSWER_BUFFER_SIZE = sizeof (zz_answer_buffer);

  REQUEST_BEGIN = REQUEST_HEAD = REQUEST_TAIL = (char *) zz_request_buffer;
  REQUEST_END = REQUEST_BEGIN + sizeof (zz_request_buffer);
  ANSWER_BEGIN = ANSWER_HEAD = ANSWER_TAIL = (char *) zz_answer_buffer;
  ANSWER_END = ANSWER_BEGIN + sizeof (zz_answer_buffer);

#if DEBUG_COMM
  fprintf (stderr, "CLIPPER_WANTS_REQUEST= %d\n", CLIPPER_WANTS_REQUEST);
  fprintf (stderr, "ASAPII_WANTS_REQUEST = %d\n", ASAPII_WANTS_REQUEST);
  fprintf (stderr, "FAVORED_REQUEST      = %d\n", FAVORED_REQUEST);
  fprintf (stderr, "CLIPPER_WANTS_ANSWER = %d\n", CLIPPER_WANTS_ANSWER);
  fprintf (stderr, "ASAPII_WANTS_ANSWER  = %d\n", ASAPII_WANTS_ANSWER);
  fprintf (stderr, "FAVORED_ANSWER       = %d\n", FAVORED_ANSWER);
  fprintf (stderr, "REQUEST_BUFFER_COUNT = %d\n", REQUEST_BUFFER_COUNT);
  fprintf (stderr, "REQUEST_BUFFER_METER = %d\n", REQUEST_BUFFER_METER);
  fprintf (stderr, "ANSWER_BUFFER_COUNT  = %d\n", ANSWER_BUFFER_COUNT);
  fprintf (stderr, "ANSWER_BUFFER_METER  = %d\n", ANSWER_BUFFER_METER);
  fprintf (stderr, "req head = 0x%x, offset = %d\n", REQUEST_HEAD,
			REQUEST_HEAD - REQUEST_BEGIN);
  fprintf (stderr, "req tail = 0x%x, offset = %d\n", REQUEST_TAIL,
			REQUEST_TAIL - REQUEST_BEGIN);
  fprintf (stderr, "req begin= 0x%x\n", REQUEST_BEGIN);
  fprintf (stderr, "req end  = 0x%x, size = %d\n", REQUEST_END,
			REQUEST_END - REQUEST_BEGIN);
  fprintf (stderr, "ans head = 0x%x, offset = %d\n", ANSWER_HEAD,
			ANSWER_HEAD - ANSWER_BEGIN);
  fprintf (stderr, "ans tail = 0x%x, offset = %d\n", ANSWER_TAIL,
			ANSWER_TAIL - ANSWER_BEGIN);
  fprintf (stderr, "ans begin= 0x%x\n", ANSWER_BEGIN);
  fprintf (stderr, "ans end  = 0x%x, size = %d\n", ANSWER_END,
			ANSWER_END - ANSWER_BEGIN);
#endif

#if STATS
  num_surfs = 0;
  num_curves = 0;
  num_lines = 0;
  num_tri = 0;
  num_vector = 0;
  num_activates = 0;
  num_requests = 0;
  largest_request = 0;
  request_high_bytes = 0;
  request_high_num = 0;
  num_answers = 0;
  largest_answer = 0;
  answer_high_bytes = 0;
  answer_high_num = 0;
#endif

#if DEBUG_IT
  fprintf (stderr, "start loop\n");
#endif

  ASAPII_READY = 1;
  for (;;)
  {
    tiling_parms.status = HSSTAT_OK;
    while (!AACL_get_request_ptr (&request, &request_ptr))
    {
#if TIMING
      if (REQUEST_BUFFER_COUNT || ANSWER_BUFFER_COUNT)
	AAtimer (&request_wait_time);
      else
	AAtimer (&other_time);
#endif
    }
#if TIMING
    AAtimer (&request_time);
    if (other_time < 1.0)
      request_wait_time += other_time;
    other_time = 0.0;
#endif
    INCR (num_requests)
#if DEBUG_IT
    { char bf[20];
      sprintf (bf, "request %d  size %d\n", request, *(int *) REQUEST_HEAD);
      fprintf (stderr, "%s", bf);
    }
#endif

    switch (request)
    {
    case AA_BS_CHANGE_PAR:
      aa_bs_change_par ((IGRdouble *) request_ptr);
      break;
    case AA_BSURF_TILER:
      INCR (num_surfs)
      aa_bsurf_tiler (request_ptr);
      if (tiling_parms.status != HSSTAT_OK)
	AA_report_error (tiling_parms.status);
      break;
    case AA_BCURVE_TILER:
      INCR (num_curves)
      aa_bcurve_tiler (request_ptr);
      if (tiling_parms.status != HSSTAT_OK)
	AA_report_error (tiling_parms.status);
      break;
    case AA_ACTIVATE_WINDOW:
      INCR (num_activates)
      HSactivate_window (*(int *) request_ptr);
      break;
    case AA_INIT_SHD_WINDOW:
      aa_init_shd_window (request_ptr);
      break;
    case AA_SETUP_SHD_WINDOW:
      aa_setup_shd_window (request_ptr);
      break;
    case AA_DEL_ACTIVE_WINDOW:
      HSdelete_active_window ();
      break;
    case AA_RESET_XFORM_MATRIX:
      aa_reset_xform_matrix (request_ptr);
      break;
    case AA_STROKE_XFORM_MATRIX:
      aa_stroke_xform_matrix (request_ptr);
      break;
    case AA_STROKE_CURVE:
      INCR (num_curves)
      aa_stroke_curve (request_ptr);
      break;
    case AA_STROKE_SURFACE:
      INCR (num_surfs)
      aa_stroke_surface (request_ptr);
      break;
    case AA_WIREFRAME_CLIP_RANGE:
      aa_wireframe_clip_range (request_ptr);
      break;
    case AA_STROKE_LINESTRING:
      INCR (num_lines)
      aa_stroke_linestring (request_ptr);
      break;
    case AA_PRINT_STATISTICS:
      aa_print_statistics ();
      break;
    case AA_TOGGLE_DUMPS:
#if DUMPS
      dumps_enabled ^= 1;
#endif
      break;
    default:
      fprintf (stderr, "unknown aa request (%d) .\n", request);
      break;
    }

    AAtimer (&request_time);
#if STATS
    sts = *(int *) REQUEST_HEAD;
    if (sts > largest_request)
      largest_request = sts;
    request_total += sts;
#endif
#if DEBUG_IT2
    { char bf[80];
      sprintf (bf, "req %d done, tile sts %d\n", request, tiling_parms.status);
      fprintf (stderr, "%s", bf);
    }
#endif

    AACL_request_complete ();
  }
} /* main */
