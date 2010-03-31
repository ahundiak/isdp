#include <stdio.h>
#include <gpipe.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/times.h>
#include "wl.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpdef.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "/usr2/mike/timing/HStiming.h"

#include "hsdef.h"
#include "hsurf.h"
#include "hsmacdef.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "hrstruct.h"

#include "bstypes.h"

#if defined( DL )
#include "dl.h"
#endif

/******/
#include "HSfem_spt.h"
/******/

/*
 * This driver allows HSURF to run without IGE.  To use it:
 *	1) Export HS_STANDALONE_FILE=filename, where filename is the name
 *	   of the data file to be created.
 *	2) Run EMS and shade a window.  The window and object data will be
 *	   written to the file.
 *	3) In the solo directory, use standalone.m to make "solo."
 *	4) Run solo, using the data file created above as the data file.
 */

#define	DEBUG		0
#define	DEBUG_COUNT	0
#define DEBUG_TIMING	1
#define	DEBUG_WAIT	0
#define DEBUG_CURVE	0
#define DEBUG_SURFACE	0

#define KNOT_TOL	0.000005

struct IGRbsp_surface   surf;
struct IGRbsp_curve     curve;
struct IGRpolyline      polyline;
struct IGRpointset      pointset;
struct IGResfct         fem;

char                    *general_geom;
IGRdouble               u_kts[1500];
IGRdouble               v_kts[1500];
IGRdouble               poles[30000];
IGRdouble               wts[1500];
struct                  IGRbsp_bdry_pts bnds[1500];
IGRdouble               bnd_pts[120000];
IGRshort                color_shade[1500];
IGRint                  log_file;

struct window_info
   {
   int                     w_no, pipe_no;
   IGRint                  org_x, org_y;
   IGRint                  x_dits, y_dits;
   IGRdouble               top_range[6];
   IGRdouble               clip_range[6];
   IGRdouble               t_matrix[4][4], r_matrix[4][4];
   IGRint                  num_lights;
   IGRvector               light_vect[8];
   IGRdouble               light_intens[8];
   IGRint                  num_global_lights;
   struct HS_light_source  global_lights[8];
   struct HS_light_source  ambient_light;
   IGRdouble               max_near_shd, max_far_shd;
   IGRint                  screen_door;
   IGRdouble               x_scale, y_scale, z_scale;
   IGRint                  perspective;
   IGRdouble               wld_to_view[4][4];
   IGRdouble               vw_volume[6];
   IGRdouble               eye_pt[3];
   IGRdouble               vrp[3];
   IGRdouble               vpn[3];
   IGRdouble               vup[3];
   IGRint                  grid_on;
   IGRint                  depth_cue;
   IGRdouble               world_to_view_scale;
   IGRint                  can_use_edge2;
   } *w;

static struct window_info *windows[40] =
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

static WLuint32         context_no;
struct WLinit_ret_val   init_ret;
struct WLnative_info	native_info = { 0 };

#define		DS_WINDOW_INFO 		0
#define		DS_OBJECT_INFO 		1
#define		DS_DELETE_INFO		2

static IGRint      num_colors = 10, num_shades = 10;
static IGRint      dith_mode = HS_DITHER_HALFTONED;
static IGRboolean  using_ramps = FALSE;
static IGRdouble   keyed_in_tol = 0.0;
static IGRint      acc_mode;
static IGRint      accuracy;
static IGRint      option;
static IGRint      trans_pat = -1;
static IGRint      style = 0;
static IGRint      act_style;
static IGRint      status;
static IGRint      fpe_present = FALSE;
static int         weight;

IGRboolean   IGEget_using_ramp_mode()
   {
   return( using_ramps );
   }
   
#if defined( RAMPS )
IGRint HSasap1_present ();
#endif

#if DEBUG_COUNT
static int ccount = 0;
static int fcount = 0;
static int lcount = 0;
static int pcount = 0;
static int scount = 0;
static int tcount = 0;
#endif

static WLuint16 lscreen_no;

extern int IGEcmap_color_to_index ();
extern int IGEcmap_color_to_rgb ();
extern int IGEcmap_init ();


#if DEBUG
/*---dump_surface--------------------------------------------------------*/

/*
NAME
   dump_surface
   
DESCRIPTION
   Dumps out the surface definition to standard output. Debugging tool only.

ARGUMENT
   surf: (IN): surface structure to dump
   
HISTORY
   09/01/86		S. A. Rapa
      created
 */

static void dump_surface( struct IGRbsp_surface *surf )


   {
   IGRint   vi, ui, index, point_cnt;

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
      fprintf (stderr, "  Poles (v, u, x, y, z, w):\n");

      for (vi = 0; vi < surf->v_num_poles; vi++)
         {
         for (ui = 0; ui < surf->u_num_poles; ui++)
            fprintf (stderr, "%5d %5d %13.5lf %13.5lf %13.5lf %13.5lf\n",
                     vi, ui,
                     surf->poles[((vi * surf->u_num_poles) + ui) * 3],
                     surf->poles[((vi * surf->u_num_poles) + ui) * 3 + 1],
                     surf->poles[((vi * surf->u_num_poles) + ui) * 3 + 2],
                     surf->weights[(vi * surf->u_num_poles) + ui]);

         fprintf (stderr, "\n");
         }
      }
   else
      {
      fprintf (stderr, "  Poles (v, u, x, y, z):\n");

      for (vi = 0; vi < surf->v_num_poles; vi++)
         {
         for (ui = 0; ui < surf->u_num_poles; ui++)
            fprintf (stderr, "%5d %5d %13.5lf %13.5lf %13.5lf\n",
                     vi, ui,
                     surf->poles[((vi * surf->u_num_poles) + ui) * 3],
                     surf->poles[((vi * surf->u_num_poles) + ui) * 3 + 1],
                     surf->poles[((vi * surf->u_num_poles) + ui) * 3 + 2]);

         fprintf (stderr, "\n");
         }
      }

   fprintf (stderr, "\n  U knots:\n");

   for (index = 0; index < surf->u_num_knots; index++)
      fprintf (stderr, "%17.9lf\n", surf->u_knots[index]);

   fprintf (stderr, "\n  V knots:\n");

   for (index = 0; index < surf->v_num_knots; index++)
      fprintf (stderr, "%17.9lf\n", surf->v_knots[index]);

   for (index = 0; index < surf->num_boundaries; index++)
      {
      fprintf (stderr, "\n  Boundary %d:\n", index);

      for (point_cnt = 0; point_cnt < surf->bdrys[index].num_points; point_cnt++)
         fprintf (stderr, "%17.9lf %17.9lf \n",
                  surf->bdrys[index].points[2 * point_cnt],
                  surf->bdrys[index].points[2 * point_cnt + 1]);
      }
   }

/*---dump_curve--------------------------------------------------------*/

static void dump_curve (struct IGRbsp_curve *curve)

   {
   IGRint   ui, index;

   fprintf (stderr, "\n\nCurve Definition:\n");
   fprintf (stderr, "  order      = %d\n", curve->order);
   fprintf (stderr, "  num_poles  = %d\n", curve->num_poles);
   fprintf (stderr, "  num_knots  = %d\n", curve->num_knots);
   fprintf (stderr, "  rational   = %d\n\n", curve->rational);

   if (curve->rational != 0)
      {
      fprintf (stderr, "  Poles (u, x, y, z, w):\n");

      for (ui = 0; ui < curve->num_poles; ui++)
         fprintf (stderr, "%5d %13.5lf %13.5lf %13.5lf %13.5lf\n",
                  ui,
                  curve->poles[(ui) * 3] / curve->weights[ui],
                  curve->poles[(ui) * 3 + 1] / curve->weights[ui],
                  curve->poles[(ui) * 3 + 2] / curve->weights[ui],
                  curve->weights[ui]);
      }
   else
      {
      fprintf (stderr, "  Poles (u, x, y, z):\n");

      for (ui = 0; ui < curve->num_poles; ui++)
         fprintf (stderr, "%5d %13.5lf %13.5lf %13.5lf\n",
                  ui,
                  curve->poles[(ui) * 3],
                  curve->poles[(ui) * 3 + 1],
                  curve->poles[(ui) * 3 + 2]);
      }

   fprintf (stderr, "\n  knots:\n");

   for (index = 0; index < curve->num_knots; index++)
      fprintf (stderr, "%17.9lf\n", curve->knots[index]);
   }

#endif  /* DEBUG */

/*---create_window----------------------------------------------*/

WLuint32 create_window (int xmin, int ymin, int xmax, int ymax)

   {
   char                  wname[40];
   struct WLbounds       Bounds;
   WLuint32              lwin_no;
   struct WLcmap_entry   ColorMap[512];
   int                   i, num_color_cells;
   struct WLnative_info  NativeInfo;

   WLget_number_of_color_cells (context_no, &num_color_cells);
   for (i = 0; i < num_color_cells; i++)
      {
      ColorMap[i].slot = i;
      ColorMap[i].flags = 0;
      }

   Bounds.x = xmin;
   Bounds.y = ymin;
   Bounds.width = xmax - xmin + 1;
   Bounds.height = ymax - ymin + 1;

   status = WLcreate_window (lscreen_no,
                             wname,
                             &Bounds,
                             10,
                             context_no,
                             &lwin_no);

   WLget_native_info( lwin_no, context_no, &native_info );

   sprintf (wname, "%1d", native_info.base_win);

   WLset_window_name (lwin_no, wname);
   /*WLget_native_info (lwin_no, context_no, &NativeInfo);*/
   WLIwin_set_event_mask (lwin_no, WL_EXPOSE);
   WLdisplay_window (lwin_no);
   WLclear_window (lwin_no);
   WLhide_cursor (lwin_no, TRUE);
   WLflush (lwin_no);

   return (lwin_no);
   }

/*---read_surface-----------------------------------------------------------*/

void read_surface ()
   {
   IGRint b_num, tmp;
   IGRdouble *this_point;

   read (log_file, &surf, sizeof (struct IGRbsp_surface));
   read (log_file, poles, surf.u_num_poles * surf.v_num_poles * 3 * sizeof (IGRdouble));

   surf.poles = poles;

   read (log_file, u_kts, surf.u_num_knots * sizeof (IGRdouble));

   surf.u_knots = u_kts;

   read (log_file, v_kts, surf.v_num_knots * sizeof (IGRdouble));

   surf.v_knots = v_kts;

   if (surf.rational)
      {
      read (log_file, wts, surf.u_num_poles * surf.v_num_poles * sizeof (IGRdouble));
      surf.weights = wts;
      }

   surf.bdrys = bnds;
   this_point = bnd_pts;

   for (b_num = 0; b_num < surf.num_boundaries; b_num++)
      {
      read (log_file, &tmp, sizeof (IGRlong));

      surf.bdrys[b_num].num_points = tmp;
      surf.bdrys[b_num].points = this_point;

      read (log_file, this_point, surf.bdrys[b_num].num_points * 2 * sizeof (IGRdouble));

      this_point += (surf.bdrys[b_num].num_points * 2);
      }

#  if DEBUG
   dump_surface (&surf);
#  endif
   }

/*---read_curve------------------------------------------------------------*/

void read_curve ()
   {
   read (log_file, &curve, sizeof (struct IGRbsp_curve));
   read (log_file, poles, curve.num_poles * 3 * sizeof (IGRdouble));

   curve.poles = poles;

   read (log_file, u_kts, curve.num_knots * sizeof (IGRdouble));

   curve.knots = u_kts;

   if (curve.rational)
      {
      read (log_file, wts, curve.num_poles * sizeof (IGRdouble));
      curve.weights = wts;
      }

#  if DEBUG
   dump_curve (&curve);
#  endif
   }

/*---read_pline-----------------------------------------------------------*/

void read_pline ()

   {
   read (log_file, &polyline.num_points, sizeof (IGRint));
   read (log_file, bnd_pts, 3 * polyline.num_points * sizeof (IGRdouble));

   polyline.points = bnd_pts;
   }

/*---read_points-----------------------------------------------------------*/

void read_points ()

   {
   read (log_file, &pointset.num_points, sizeof (IGRint));
   read (log_file, bnd_pts, 3 * pointset.num_points * sizeof (IGRdouble));

   pointset.points = bnd_pts;
   }

/*---read_fem-----------------------------------------------------------*/

void read_fem ()

   {
   read (log_file, &fem.n_mid, sizeof (short));
   read (log_file, color_shade, (fem.n_mid + 2) * (fem.n_mid + 2) * sizeof (IGRshort));

   fem.color_shade = color_shade;
   }

/*---HSmalloc---------------------------------------------------------------*/

char *HSmalloc (size)

   int size;

   {
   return ((char *) malloc (size));
   }

/*---read_window_info------------------------------------------------------*/

read_window_info ()

   {
   int         win_no;
   int         x_dits, y_dits;
   IGRboolean  first_time;

   read (log_file, &win_no, 4);

   if (windows[win_no] == 0)
      {
      w = (struct window_info *) malloc (sizeof (struct window_info));
      windows[win_no] = w;
      first_time = TRUE;
      }
   else
      {
      first_time = FALSE;
      w = windows[win_no];
      }

   read (log_file, &w->org_x, sizeof (IGRint));
   read (log_file, &w->org_y, sizeof (IGRint));
   read (log_file, &w->x_dits, sizeof (IGRint));
   read (log_file, &w->y_dits, sizeof (IGRint));
   read (log_file, w->top_range, 6 * sizeof (IGRdouble));
   read (log_file, w->clip_range, 6 * sizeof (IGRdouble));
   read (log_file, w->t_matrix, 16 * sizeof (IGRdouble));
   read (log_file, w->r_matrix, 16 * sizeof (IGRdouble));

   read (log_file, &w->num_global_lights, sizeof (IGRint));
   read (log_file, w->global_lights, sizeof (struct HS_light_source) * 8);
   read (log_file, &w->ambient_light, sizeof (struct HS_light_source));

   read (log_file, &w->max_near_shd, sizeof (IGRdouble));
   read (log_file, &w->max_far_shd, sizeof (IGRdouble));
   read (log_file, &w->screen_door, sizeof (IGRint));
   read (log_file, &w->x_scale, sizeof (IGRdouble));
   read (log_file, &w->y_scale, sizeof (IGRdouble));
   read (log_file, &w->z_scale, sizeof (IGRdouble));
   read (log_file, &w->perspective, sizeof (IGRint));
   read (log_file, w->wld_to_view, 16 * sizeof (IGRdouble));
   read (log_file, w->vw_volume, 6 * sizeof (IGRdouble));
   read (log_file, w->eye_pt, 3 * sizeof (IGRdouble));
   read (log_file, w->vrp, 3 * sizeof (IGRdouble));
   read (log_file, w->vpn, 3 * sizeof (IGRdouble));
   read (log_file, w->vup, 3 * sizeof (IGRdouble));
   read (log_file, &w->grid_on, sizeof (IGRint));
   read (log_file, &w->depth_cue, sizeof (IGRint));
   read (log_file, &w->world_to_view_scale, sizeof (IGRdouble));
   read (log_file, &w->can_use_edge2, sizeof (IGRint));

   if (first_time)
      {
      w->w_no = create_window (
                               w->org_x, w->org_y,
                               w->x_dits + w->org_x,
                               w->y_dits + w->org_y);
      }
   else
      {
      WLdelete_window (w->w_no);
      w->w_no = create_window (
                               w->org_x, w->org_y,
                               w->x_dits + w->org_x,
                               w->y_dits + w->org_y);

      }

   download_colortable ( using_ramps, num_colors, num_shades );

#  if defined( DL )
   status = DLcreate_drawing_pipeline (
                           (w->perspective) ? DL_PERSP_PIPE : DL_ORTHO_PIPE,
                                       w->w_no, &w->pipe_no);
#  endif
   if (first_time)
      {

#  if defined( ENV5 )
      if (fpe_present)
         {
         status = GPCreateWin (1, native_info.base_win, &w->pipe_no);
         }
      else
#  endif
         {
         }
      }

   x_dits = w->x_dits + 1;
   y_dits = w->y_dits + 1;


   HSset_active_max_z (w->pipe_no, act_style, FALSE, 5);

   HSset_shade_config( w->pipe_no, 0, num_colors, num_shades, dith_mode );
                                            
   HSinit_shading_window (lscreen_no, w->w_no, w->pipe_no, x_dits, y_dits);

   HSsetup_shading_window (
                           w->wld_to_view,
                           w->vw_volume,
                           w->eye_pt,
                           w->vrp,
                           w->vpn,
                           w->vup,
                           w->pipe_no, w->w_no,
                           w->org_x, w->org_y, w->x_dits, w->y_dits,
                           w->top_range,
                           w->clip_range,
                           w->t_matrix, w->r_matrix,

                           w->global_lights,
                           &w->ambient_light,

                           w->max_near_shd, w->max_far_shd,
                           w->world_to_view_scale,
                           w->x_scale, w->y_scale, w->z_scale,
                           w->perspective,
                           w->grid_on,
                           w->depth_cue,
                           (w->can_use_edge2 != 0));

   /*HSset_transparency (trans_pat);*/

#  if defined( RAMPS )
   HSset_shade_config (w->pipe_no, 0, num_colors, num_shades, dither);
#  endif
   }

/*---read_delete_info-----------------------------------------------------------*/

read_delete_info ()

   {
   int w_no;

   read (log_file, &w_no, 4);

   w = windows[w_no];

   free (w);
   windows[w_no] = NULL;
   }

/*---read_object_info-----------------------------------------------------------*/

read_object_info ()

   {
   int         w_no;
   IGRshort    type;
   IGRdouble   range[6];
   IGRdouble   *upoints, *vpoints;
   IGRdouble   CHT ();
   IGRint      temp_int;
   IGRboolean  part_of_solid, ele_style, dont_cull;

   struct HS_element_rendering_parms *render_parms;

   int         trans_mode;
   int         delete_mode;
   IGRdouble   u_range[2], v_range[2];
   IGRdouble   chord_ht_tol, basis_tol;

   read (log_file, &w_no, 4);

   w = windows[w_no];

   HSactivate_window (w->pipe_no);

   if (w == 0)
      goto wrapup;

   read (log_file, &option, 4);
   read (log_file, &temp_int, 4);   part_of_solid = temp_int;
   read (log_file, &temp_int, 4);   ele_style = temp_int;
   read (log_file, &temp_int, 4);   dont_cull = temp_int;
   read (log_file, &type, sizeof (IGRshort));
   read (log_file, range, 6 * sizeof (IGRdouble));
   read (log_file, u_range, 2 * sizeof (IGRdouble));
   read (log_file, v_range, 2 * sizeof (IGRdouble));
   read (log_file, &chord_ht_tol, sizeof (IGRdouble));
   read (log_file, &basis_tol, sizeof (IGRdouble));
   
   render_parms = (struct HS_element_rendering_parms *) malloc (sizeof (struct HS_element_rendering_parms));
   
   read (log_file, &render_parms->color, sizeof (IGRint));
   read (log_file, &render_parms->transparency, sizeof (double));
   read (log_file, &render_parms->finish, sizeof (int));
   read (log_file, &render_parms->diff_refl, sizeof (double));
   read (log_file, &render_parms->spec_refl, sizeof (double));

   if (!(option & HS_BST_POLYLINE) || !(option & HS_BST_POINT))
      {
      HSactivate_window (w->pipe_no);

      if (style > 0)
         {
         trans_mode = option & GR_BST_TRANSP;
         delete_mode = option & HS_BST_DELETE;

         option = option & !(GR_BST_SMOOTH | GR_BST_CONSTANT |
                             GR_BST_SOLID  | HS_BST_STYLED_EDGES |
                             HS_BST_EDGES  | HS_BST_REV_EDGES);

         switch (style)
            {
            case 1:
               option |= GR_BST_SMOOTH;
               break;

            case 2:
               option |= GR_BST_CONSTANT;
               break;

            case 3:
               option |= GR_BST_SOLID;
               break;

            case 4:
               element_parms.visible_weight = weight;
               option |= HS_BST_EDGES;
               break;

            case 5:
               element_parms.visible_weight = weight;
               option |= HS_BST_REV_EDGES;
               break;

            case 6:
               option |= 0x7fffffff;
               break;
               }

         option |= (trans_mode | delete_mode);
         }
      }

   if (!acc_mode)
      {
      if (keyed_in_tol > 0.0)
         {
         chord_ht_tol = CHT (w->pipe_no,
                             keyed_in_tol,
                             range);
         }
      }


   upoints = (IGRdouble *) 0;
   vpoints = (IGRdouble *) 0;

   switch (type)
      {
      case IGRLB:      /* TEXT */

         read_points ();
         general_geom = (char *) &pointset;

#        if DEBUG_COUNT
         fprintf (stderr, "Tile text #%1d\n", ++tcount);
#        endif

         break;

      case IGRPY:      /* LINESTRING */

         read_pline ();

         general_geom = (char *) &polyline;

#        if DEBUG_COUNT
         fprintf (stderr, "Tile linestring #%1d\n", ++lcount);
#        endif
         break;

      case IGRBS:      /* SURFACE */

         read_surface ();
         general_geom = (char *) &surf;

#        if DEBUG_COUNT
         fprintf (stderr, "Tile surface #%1d\n", ++scount);
#        endif
         break;

      case IGRBC:      /* CURVE */

         read_curve ();
         general_geom = (char *) &curve;

#        if DEBUG_COUNT
         fprintf (stderr, "Tile curve #%1d\n", ++ccount);
#        endif
         break;

      case IGRPS:
      case HS_BST_POINT:       /* POINT */

         read_points ();
         general_geom = (char *) &pointset;

#        if DEBUG_COUNT
         fprintf (stderr, "Tile pointset #%1d\n", ++pcount);
#        endif
         break;

      case IGRFE:

         read_surface ();
         general_geom = (char *) &surf;
         read_fem ();

#        if DEBUG_COUNT
         fprintf (stderr, "Tile FEM color tile #%1d\n", ++fcount);
#        endif
         break;
         }

   /* Shade the object. */

   if (type != IGRBC)
      {
      HSactivate_window (w->pipe_no);
      active_window->context_no = context_no;
      active_window->hwin_no = native_info.base_win;

fgcolor( active_window->hwin_no, render_parms->color * num_shades + 2 );

      HSset_status (HSSTAT_OK);
      HSshade_object ((style == 6) ? (RENDER_IT) : (SHADE_IT),
                      w->pipe_no,
                      type,
                      general_geom,
                      (char *) (&fem),
                      w->clip_range,
                      range,
                      u_range,
                      v_range,
                      acc_mode,
                      accuracy,
                      chord_ht_tol,
                      basis_tol,
                      0.0,
                      render_parms->color,
                      option,
                      ele_style,
                      part_of_solid,
                      dont_cull,
                      pointset.points,
                      pointset.num_points,
                      render_parms,     /* rendering parms		 */
                      NULL);    /* minimum x return value	 */
      }

wrapup:
   ;
   }


/*---get_string-------------------------------------------------------------*/

get_string (char *a)

   {
   char  c;
   int   i;

   i = 0;
   c = getchar ();
   while ((c = getchar ()) != 10)
      a[i++] = c;

   a[i] = 0;
   }

/*---show_opBtions-----------------------------------------------------------*/

static void   show_options()

   {
   printf( "solo options\n" );
   printf( "   -t <double>    :  tiling tolerance: \n" );
   printf( "                  :  <double> = [0.25..8.0]\n" );
   printf( "                  :  default = 0.5\n" );
   printf( "   -s <int>       :  shading style\n" );
   printf( "                  :  <int> = 1 (smooth)\n" );
   printf( "                  :  <int> = 2 (constant)\n" );
   printf( "                  :  default = (style saved in input file)\n" );
   printf( "   -r             :  set ramp mode on\n" );
   printf( "   -c <int>:<int> :  color/shade configuration\n" );
   printf( "   -d             :  direct mode on\n" );
   printf( "   -p <int>       :  translucency pattern\n" );
   printf( "                  :  <int> = 1, 1x1 pattern\n" );
   printf( "                  :  <int> = 3, 3x3 pattern\n" );
   printf( "                  :  default = 3x3\n" );
   }
   
/*---get_user_options-------------------------------------------------------*/

int get_user_options (int argc, char *argv[])

   {
   char   option, *option_data;

   log_file = -1;
   while (HSgetopt (argc, argv, "-", "t:s:rc:dp:?", &option, &option_data))
      {
      switch (option)
         {
         case 'p':
            switch( option_data[0] )
               {
               case '1':
                  HSset_transparency( 1 );
                  break;

               case '3':
                  HSset_transparency( 0 );
                  break;
               }
            break;
            
         case 'd':
            dith_mode = HS_DITHER_DIRECT;
            break;
            
         case 'c':
            sscanf( option_data, "%d:%d", &num_colors, &num_shades );
            break;
            
         case 'r':
            using_ramps = TRUE;
            break;

         case 's':
            sscanf (option_data, "%d", &style);
            break;

         case 't':
            sscanf (option_data, "%lf", &keyed_in_tol);
            break;

         case 0x7f:
            if (log_file != -1)
               close (log_file);

            if ((log_file = open (option_data, 0)) == -1)
               printf ("Error opening data file: %s.\n", option_data);

            break;
            
         case '?':
            show_options();
            return( 0 );
            }
      }

   return (log_file != -1);
   }

/*---ifb_check------------------------------------------------------*/

int ifb_check ()

#  if defined( ENV5 )
   {
   struct scr_info info[MAX_SCREENS];
   int vs_no;

   Inq_displayed_vs (&vs_no);
   Inq_screen_info (info);

   return (info[vs_no].vsi_flags & VSI_DB_ABILITY);
   }

#  else
   {
   return (0);
   }
#  endif

/*---main------------------------------------------------------------------*/

main (int argc, char *argv[])

   {
   IGRint                  status, ii;
   int                     request, screen_type;
   int                     event_flag;
   int                     depth, num_contexts, cmap_type;
   struct WLcontext_info   *contexts;

   if (get_user_options (argc, argv))
      {
      HSinit_timing (0, "standalone");
      HSinit_timing (1, "HSsmooth_shade_opaque_half");
      HSinit_timing (2, "HSsmooth_shade_trans_half");
      HPtiming_start (0);

      cmap_type = WL_CMAP_INDEXED;

      if (accuracy < 1)
         accuracy = 1;

      status = WLinitialize (NULL, NULL);

#     if defined( DL )
      status = DLinitialize ();
#     endif
      status = WLget_active_screen (&lscreen_no, &screen_type);

      status = WLget_screen_contexts (lscreen_no, 0, 0, &num_contexts, &contexts);

      /* find an appropriate context */
      for (ii = 0; ii < num_contexts; ii++)
         {
         if (cmap_type == WL_CMAP_INDEXED)
            {
            if ((contexts[ii].base_cmap_type == WL_CMAP_INDEXED) &&
#              if defined( WIN32 )
                (contexts[ii].base_depth >= 4))
#              else
               (contexts[ii].base_depth >= 8) &&
                (!(contexts[ii].flags & WL_COLORMAP_READ_ONLY)))
#              endif
               {
               break;
               }
            }
         else
            {
            if ((contexts[ii].base_cmap_type == WL_CMAP_TRUE_COLOR) &&
                (contexts[ii].base_depth == 24))
               {
               break;
               }
            }
         }

      if (ii >= num_contexts)
         {
         fprintf (stderr, "Couldn't find an appropriate context\n");
         exit (1);
         }

      status = WLcreate_context (lscreen_no,
                                 &contexts[ii],
                                 IGEcmap_color_to_index,
                                 IGEcmap_color_to_rgb,
                                 IGEcmap_init,
                                 &context_no);

      /* tiling_parms.context_no = context_no; */

#     if defined( ENV5 )
      Enable_events (KEYBOARD_EVENT);
      Set_logo ("Running");
#     elif defined( X11 )
#     endif

      status = WLget_screen_depth (lscreen_no, 1, &depth);

#     if defined( RAMPS )
      fpe_present = HSasap1_present (vs_no);
#     else
      fpe_present = FALSE;
#     endif

fpe_present = TRUE;
      if (fpe_present)
         GPEnter ();

      while (read (log_file, &request, 4) == 4)
         {
         switch (request)
            {
            case DS_WINDOW_INFO:
               read_window_info ();
               break;

            case DS_OBJECT_INFO:
               read_object_info ();
               break;

            case DS_DELETE_INFO:
               read_delete_info ();
               break;

            default:
               printf ("Dont know what %1d is\n", request);
               break;
               }
         }

      HSpaint (1);

      if (fpe_present)
         GPExit ();

      HPtiming_stop (0);
      HPtiming_report ();

      Wait_for_events (KEYBOARD_EVENT, &event_flag);
      Exit_tools ();
      }
   }

/*
#include "hsmachine.h"

HSgetMachineInfo (numplane, termtype, max_col_shd)

   int *numplane;
   int *termtype;
   int *max_col_shd;

   {
   *numplane = 8;
   *termtype = GXGZ;
   *max_col_shd = 240;
   }
*/
