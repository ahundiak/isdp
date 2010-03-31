/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

/*
 * AUTHOR:	Steve Rapa
 * DATE:	7/21/86
 *
 * This module contains all of the entry points needed by IGE to perform
 * hidden line/surface removal.


HISTORY

        Sudha	07/27/93	Modified for BSprototypes ansification


 */

#include <stdio.h>
#include <math.h>
#include <FI.h>

#if defined( ENV5 )
#include <EG.h>
#endif

#include "wl.h"

#include "OMminimum.h"
#include "OMprimitives.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "dpstruct.h"
#include "gr.h"
#include "dp.h"
#include "dpdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"

#include "DPdlist.h"

#include "hsurf.h"
#include "hsdef.h"
#include "hstiler.h"
#include "hslight.h"
#include "hsncdef.h"
#include "hsncmacros.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hsmsg.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSlvhl.h"

#include "bsparameters.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "HSpr_driver.h"

#include "bstypes.h"
#include "bsxtractpar.h"


static double eye_pt[3];

extern IGRboolean DPdlist_feedback_in_progress;
extern IGRdouble DPdlist_stroke_tolerance;

/*----------------------------------------------------------------*/

struct text_stuff
   {
   struct DPfnt_os_tbl *fnt_os_ptr;
   IGRint flags;
   IGRint win_no;
   };

static IGRdouble *text_buffer = NULL;
static IGRint max_coords = 300;
static IGRint coords_returned, text_status;

static struct text_stuff text_gragad;


/*----------------------------------------------------------------*/

extern IGRdouble CHT ();

/*extern IGRboolean		HSfrom_solid();*/
extern IGRboolean HSget_top_range ();

/*extern IGRdouble		HSget_pt_basis();*/

extern char *getenv ();

/*
 * local variables
 */

static IGRboolean debug_standalone = FALSE;
static IGRboolean first_call = FALSE;
static IGRint log_file;

static int DS_WINDOW_INFO = 0;
static int DS_OBJECT_INFO = 1;
static int DS_DELETE_INFO = 2;

/*--------------------------------------------------------------------------*/

/*
 * Routines to dump data for standalone debugging
 */

/*---write_fem-------------------------------------------------------------*/

static void write_fem (struct IGResfct * fem_data)

/**
NAME
        write_fem
        
DESCRIPTION
        writes a fem element to the standalone file.
        
PARAMETERS
        fem_data(IN): Pointer to a fem element structure
        
GLOBALS USED
        log_file: output file variable for the standalone file
        
HISTORY
        ??/??/?? 	???
                Created

        01/23/92	M. Lanier
                Addition of this header.
        
**/

   {
   write (log_file, &fem_data->n_mid, sizeof (short));
   write (log_file, fem_data->color_shade, (fem_data->n_mid + 2) * (fem_data->n_mid + 2) * sizeof (IGRshort));
   }

/*---write_surface-------------------------------------------------------------*/

static void write_surface (struct IGRbsp_surface * surf)

/**
NAME
        write_surface
        
DESCRIPTION
        writes a bspline surface into the standalone file
        
PARAMETERS
        surf(IN): Pointer to a bspline surface structure
        
GLOBALS USED
        log_file: output file variable for the standalone file.
        
HISTORY
        ??/??/??	???
                Created
                
        01/23/92	M. Lanier
                Added this header.
                
**/
   {
   IGRint b_num;

   write (log_file, surf, sizeof (struct IGRbsp_surface));
   write (log_file, surf->poles, surf->u_num_poles * surf->v_num_poles * 3 * sizeof (IGRdouble));
   write (log_file, surf->u_knots, surf->u_num_knots * sizeof (IGRdouble));
   write (log_file, surf->v_knots, surf->v_num_knots * sizeof (IGRdouble));

   if (surf->rational)
      write (log_file, surf->weights, surf->u_num_poles * surf->v_num_poles * sizeof (IGRdouble));

   for (b_num = 0; b_num < surf->num_boundaries; b_num++)
      {
      write (log_file, &surf->bdrys[b_num].num_points, sizeof (IGRlong));
      write (log_file, surf->bdrys[b_num].points, surf->bdrys[b_num].num_points * 2 * sizeof (IGRdouble));
      }
   }

/*---write_curve-------------------------------------------------------------------*/

static void write_curve (struct IGRbsp_curve * curve)

/**
NAME
        write_curve
        
DESCRIPTION
        writes a bspline curve into the standalone file
        
PARAMETERS
        curve(IN): Pointer to a bspline curve structure
        
GLOBALS USED
        log_file: Output file variable for the standalone file.
        
HISTORY
        ??/??/??	???
                Created
                
        01/23/92	M. Lanier
                Added this header
                
**/
   {
   write (log_file, curve, sizeof (struct IGRbsp_curve));
   write (log_file, curve->poles, curve->num_poles * 3 * sizeof (IGRdouble));
   write (log_file, curve->knots, curve->num_knots * sizeof (IGRdouble));

   if (curve->rational)
      write (log_file, curve->weights, curve->num_poles * sizeof (IGRdouble));
   }

/*---write_pline--------------------------------------------------------------------*/

static void write_pline (struct IGRpolyline * polyline)

/**
NAME
        write_pline
        
DESCRIPTION
        writes a polyline into the standalone file
        
PARAMETERS
        polyline(IN): Pointer to a polyline structure
        
GLOBALS USED
        log_file: Output file variable for the standalone file.
        
HISTORY
        ??/??/??	???
                Created
                
        01/23/92	M. Lanier
                Added this header.
                
**/

   {
   write (log_file, &polyline->num_points, sizeof (IGRint));
   write (log_file, polyline->points, 3 * polyline->num_points * sizeof (IGRdouble));
   }

/*---write_text--------------------------------------------------------------------*/

static void write_text (void)

/**
NAME
        write_text
        
DESCRIPTION
        writes and array of strokes, representing a text element into
        the standalone file.
        
PARAMETERS
        none
        
GLOBALS USED
        log_file       : Output file variable for the standalone file.
        coords_returned: variable containing the number of strokes to write.
        text_buffer    : array containing the coordinates of the strokes

HISTORY
        ??/??/??	???
                Created
                
        01/23/92	M. Lanier
                Added this header
                
**/
   {
   write (log_file, &coords_returned, sizeof (IGRint));
   write (log_file, text_buffer, 3 * coords_returned * sizeof (IGRdouble));
   }

/*---write_points--------------------------------------------------------------------*/

static void write_points (struct IGRpointset * point_set)

/**
NAME
        write_points
        
DESCRIPTION
        writes a point element into the standalone file
        
PARAMETERS
        point_set: pointer to a set of point elements
        
GLOBALS USED
        log_file: Output file variable for the standalone file
        
HISTORY
        ??/??/??	???
                Created
                
        01/23/92	M. Lanier
                Added this header.
                
**/
   {
   write (log_file, &point_set->num_points, sizeof (IGRint));
   write (log_file, point_set->points, 3 * point_set->num_points * sizeof (IGRdouble));
   }


/*---HSinit_display---------------------------------------------------------*/

IGRboolean HSinit_display (IGRint win_no,
                                      IGRint org_x,
                                      IGRint org_y,
                                      IGRint x_dits,
                                      IGRint y_dits,
                                      struct DPgra_gad * gadget,
                                      IGRuchar near_depth_cue,
                                      IGRuchar far_depth_cue,
                                      IGRdouble post_rotation[4][4])

/**
NAME
        HSinit_display
        
DESCRIPTION:
        Used whenever a Hidden Line gadget is created or modified.  It sends
        a copy of the gadget's instance data & hidden line data down to
        HSxform and HSdisplay.

PARAMETERS
        win_no		:(IN):  hardware window number
        org_x,  org_y   :(IN):  window origin
        x_dits, y_dits	:(IN):  window extents
        gadget		:(IN):  ptr to gadget instance data
        near_depth_cue	:(IN):  near depth cue value
        far_depth_cue	:(IN):  far depth cue value
        post_rotation	:(IN):  post rotation matrix
        
GLOBALS USED
        tiling_parms	: Structure of tiler parameters
        text_gragad	: Is loaded with info from the gadget parameter
                        : for use in text processing.  Will be used later
                        : in HStile_object
        debug_standalone: (TRUE) if logging to standalone is active
                        : (FALSE) if not.
        first_call	: True until the first attempt to write to the
                        : standalone file.
        log_file	: Output file variable for the standalone file.

RETURN VALUES
        (Always TRUE)
                
FUNCTIONS CALLED
        HSassign_edgeII_vlt_to_window
        HSbuild_rhl2_vlt
        HSget_top_range
        HSget_trans_grid
        HSset_hardware_type
        HSset_hidden_line_display_mode
        HSset_shade_config
        HSset_transparency
        HSsetup_shading_window
        creat
        fprintf
        getenv
        gr$get_hidden_so_on
        ige$inq_term_info
        hs$get_active_shading_symb
        hs$get_colortable_info
        hs$get_config
        hs$get_rhl_info
        hs$get_symbology_modes
        hs$get_global_lights
        write
        
HISTORY:
        09/01/86	S. A. Rapa
         	Created
        
        12/01/86	S. A. Rapa
                added return value which indicates if too many pixels have
                been allocated (FALSE) or not (TRUE).
                
        04/13/87	S. A. Rapa
                Converted to support hsurf shared library

        12/31/87	M. Lanier
                Added ifb_present flag

        02/03/88	M. Lanier
                Removed ifb_present flag

        02/12/88	C. M. Jablonski
                Added fit range

        05/11/90	C. M. Jablonski
                Added style mode, style
                
        01/23/92	M. Lanier
                Added this header.
**/

   {
   IGRint pipe_no;
   IGRdouble *transformation_matrix;
   IGRdouble x_scale, y_scale, z_scale;
   IGRdouble *top_range, dummy[6];
   IGRboolean is_ip32;
   IGRboolean is_persp;
   IGRint num_planes;
   IGRint translucency;
   struct HS_light_source global_lights[MAX_LIGHTS];
   struct HS_light_source ambient_light;
   IGRint num_global_lights;
   char *expr;
   IGRint style_mode;
   IGRint act_style;
   IGRboolean can_use_edge2;
   IGRint show_hidden_tst;
   IGRboolean hidden_line_display;
   IGRint num_colors, num_shades, dith_mode;

   pipe_no = gadget->gpipe_id;

   if (tiling_parms.processing_mode & HS_PMODE_FEEDBACK)
      {
      return (TRUE);
      }

   HSactivate_window (pipe_no);

   /*
    * Save data needed to shade text
    */

   text_gragad.fnt_os_ptr = gadget->fnt_os_ptr;
   text_gragad.flags = gadget->flags;
   text_gragad.win_no = win_no;

   /*
    * Get the top-level range of all objects in the window.
    */

   top_range = dummy;
   if (!HSget_top_range (top_range))
      top_range = NULL;

   if (gadget->flags & IS_PERSP)
      {
      is_persp = TRUE;
      transformation_matrix = (IGRdouble *) gadget->wld_to_view;

      x_scale = post_rotation[0][0];
      y_scale = post_rotation[1][1];
      z_scale = post_rotation[3][2];
      }
   else
      {
      is_persp = FALSE;
      transformation_matrix = (IGRdouble *) gadget->wld_to_viewport;
      }

   /*
    * Get dither mode & color/shade configuration; send data to display
    * module.  Eventually this may be performed only when the color table or
    * dither mode changes.
    */

   hs$get_symbology_modes (style_mode = &style_mode);
   hs$get_active_shading_symb (style = &act_style);
   hs$get_rhl_info (show_hidden = &show_hidden_tst);

   if (active_window->using_ramps)
      {
      struct IGEcontext_info context_info;

      IGEload_context (active_window->context_no, &context_info);

      num_colors = 10;
      num_shades = 10;
      dith_mode = HS_DITHER_HALFTONED;
      HSset_shade_config (
                          pipe_no, 0,
                          context_info.num_ramp_colors,
                          context_info.num_ramp_shades,
                          dith_mode);
      }

   /*
    * Get the translucency grid size; send data to display module. Eventually
    * this may be performed only when the color table or dither mode changes.
    */

   HSget_trans_grid (&translucency);
   HSset_transparency ((translucency == HS_GRID_NARROW));

   /* get the global light sources */
   hs$get_global_lights (lights = global_lights,
                         ambient_light = &ambient_light);

   /*
    * Get the number of planes.
    */

   ige$inq_term_info (num_of_planes = &num_planes);
   is_ip32 = (num_planes == 5);


   /*
    * Determine whether or not the window can use edge2.
    */

   hs$get_symbology_modes (style_mode = &style_mode);
   hs$get_active_shading_symb (style = &act_style);
   can_use_edge2 = ((style_mode == HS_MODE_ACTIVE) &&
      ((act_style == HS_STYLE_SMOOTH) || (act_style == HS_STYLE_CONSTANT)));

   gr$get_hidden_so_on (buffer = &hidden_line_display);
   HSset_hidden_line_display_mode (hidden_line_display);

   /*
    * Send global hidden line data & misc. gadget instance data to display
    * routines.
    */

   HSset_hardware_type (is_ip32);

   eye_pt[0] = gadget->eye_pt[0];
   eye_pt[1] = gadget->eye_pt[1];
   eye_pt[2] = gadget->eye_pt[2];

   HSsetup_shading_window (
                           gadget->wld_to_view,
                           gadget->vw_volume,
                           gadget->eye_pt,
                           gadget->vrp,
                           gadget->vpn,
                           gadget->vup,
                           pipe_no, win_no,

   /*
    * Gadget origin (rel. to window) & range
    */

                           org_x, org_y,
                           x_dits, y_dits,
                           top_range,
                           (IGRdouble *) gadget->dit_clip_range,

   /*
    * Transformations, including perspective
    */

                           transformation_matrix,
                           gadget->rotation,

   /*
    * Light Sources
    */

                           global_lights,
                           &ambient_light,

   /*
    * Depth cue paramters
    */

                           (IGRdouble) near_depth_cue,
                           (IGRdouble) far_depth_cue,

   /*
    * World to viewport scale
    */

                           gadget->vvol_viewport_scale,

   /*
    * Non-uniform scale values (for perspective)
    */

                           x_scale, y_scale, z_scale,

   /*
    * Flags
    */

                           is_persp,
                           gadget->flags & GRID_ON,
                           (near_depth_cue != 255) || (far_depth_cue != 255),
                           can_use_edge2);


   /*
    * Check for standalone debugging.   - CMJ  02/06/90
    */

   expr = getenv ("HS_STANDALONE_FILE");
   if (debug_standalone = (expr && strlen (expr)))
      {
      IGRint temp_int;
      IGRdouble temp_double;

      if (first_call == FALSE)
         {
         first_call = TRUE;
         log_file = creat (expr, 511);
         if (log_file == -1)
            fprintf (stderr, "Error opening logging file (%s).\n", expr);
         }

      write (log_file, &DS_WINDOW_INFO, 4);
      write (log_file, &pipe_no, 4);

      write (log_file, &org_x, sizeof (IGRint));
      write (log_file, &org_y, sizeof (IGRint));
      write (log_file, &x_dits, sizeof (IGRint));
      write (log_file, &y_dits, sizeof (IGRint));
      write (log_file, top_range, 6 * sizeof (IGRdouble));
      write (log_file, gadget->dit_clip_range, 6 * sizeof (IGRdouble));
      write (log_file, transformation_matrix, 16 * sizeof (IGRdouble));
      write (log_file, gadget->rotation, 16 * sizeof (IGRdouble));

      write (log_file, &num_global_lights, sizeof (IGRint));
      write (log_file, global_lights, MAX_LIGHTS * sizeof (struct HS_light_source));
      write (log_file, &ambient_light, sizeof (struct HS_light_source));

      temp_double = (IGRdouble) near_depth_cue;
      write (log_file, &temp_double, sizeof (IGRdouble));

      temp_double = (IGRdouble) far_depth_cue;
      write (log_file, &temp_double, sizeof (IGRdouble));

      temp_int = (translucency == HS_GRID_NARROW);

      write (log_file, &temp_int, sizeof (IGRint));

      write (log_file, &x_scale, sizeof (IGRdouble));
      write (log_file, &y_scale, sizeof (IGRdouble));
      write (log_file, &z_scale, sizeof (IGRdouble));
      write (log_file, &is_persp, sizeof (IGRint));
      write (log_file, gadget->wld_to_view, 16 * sizeof (IGRdouble));
      write (log_file, gadget->vw_volume, 6 * sizeof (IGRdouble));
      write (log_file, gadget->eye_pt, 3 * sizeof (IGRdouble));
      write (log_file, gadget->vrp, 3 * sizeof (IGRdouble));
      write (log_file, gadget->vpn, 3 * sizeof (IGRdouble));
      write (log_file, gadget->vup, 3 * sizeof (IGRdouble));

      temp_int = gadget->flags & GRID_ON;
      write (log_file, &temp_int, sizeof (IGRint));

      temp_int = (near_depth_cue != 255) || (far_depth_cue != 255);
      write (log_file, &temp_int, sizeof (IGRint));

      write (log_file, &gadget->vvol_viewport_scale, sizeof (IGRdouble));

      temp_int = can_use_edge2;
      write (log_file, &temp_int, sizeof (IGRint));
      }

   return (TRUE);
   }

/*---HSdelete--------------------------------------------------------------*/

void HSdelete (IGRint pipe_no)

/*
NAME
        HSdelete
        
DESCRIPTION
        Removes the window from the list of active shading windows.
        
PARAMETERS
        pipe_no		:(IN) : Gpipe id number for the window
        
GLOBALS USED
        debug_standalone: If we are logging to standalone or not
        log_file	: Output file variable for the standalone file.

FUNCTIONS CALLED
        HSactivated_window
        HSdelete_active_window
        write
        
HISTORY
        09/01/86	S. A. Rapa
                created

        02/16/87	S. A. Rapa
                Removes window from list too.

        04/06/87	S. A. Rapa
                Merged HSdisplay with IGE

        04/10/87	S. A. Rapa
                Conversion to shared library.
                
        01/23/92	M. Lanier
                Added this header
 */

   {
   HSactivate_window (pipe_no);
   HSdelete_active_window ();

   if (debug_standalone)
      {
      write (log_file, &DS_DELETE_INFO, 4);
      write (log_file, &pipe_no, 4);
      }
   }


/*---HSget_window_based_cht------------------------------------------------------*/

void HSget_window_based_cht (IGRdouble * cht,
                                  IGRint pipe_no,
                                  IGRdouble pixel_based_cht,
                                  IGRdouble * range)

/**
NAME
        HSget_window_based_cht
        
DESCRIPTION
        Calculates a window-based chord height tolerance and returns it.

PARAMETERS
        cht		:(OUT) : window based chord height tolerance calculated
        pipe_no		:(IN)  : window gpipe id number
        pixel_based_cht	:(IN)  : pixel based chord height tolerace
        range		:(IN)  : range of the object
        
GLOBAL USED
        (none)
        
FUNCTIONS CALLED
        CHT

HISTORY
        08/30/88	C. M. Jablonski
                created
                
        01/23/92	M. Lanier
                Added this header
                
 */

   {
   *cht = CHT (pipe_no, pixel_based_cht, range);
   }


/*--- HScheck_status ----------------------------------------------------------*/

void HScheck_status (void)

/**
NAME
        HScheck_status
        
DESCRIPTION
        Evaluates the status in the tiler parameters structure
        and, if there is an error displays the appropriate message
        
PARAMETERS
        (none)
        
GLOBALS USED
        tiling_parms	: Pointer to the tiler parameter structure
        active_window	: Pointer to the active window information structure
        
FUNCTIONS CALLED
        FI_message_box
        HSout_of_zrange
        ex$message
        sleep
        sprintf
        
HISTORY
        ??/??/??	???
                Created
                
        01/23/92	M. Lanier
                Added this header
        
**/
   {
   char HSmsg0[45], HSmsg1[45], HSmessage[90];

   switch (tiling_parms.status)
      {
      case HSSTAT_OK:
         break;

      case HSSTAT_ALLOC_ERROR:
         ex$message (msgnumb = HS_E_NoMemory);
         sleep (2);
         break;

      case HSSTAT_BOUND_ERROR:
/*
         ex$message (msgnumb = HS_E_BadBoundary);
         sleep (2);
*/
         break;

      case HSSTAT_MATH_ERROR:
         ex$message (msgnumb = HS_E_BadMathCall);
         sleep (2);
         break;

      case HSSTAT_DEG_SURFACE:
         ex$message (msgnumb = HS_E_DegSurface);
         sleep (2);
         break;

      case HSSTAT_FEM_ERROR:
         ex$message (msgnumb = HS_E_FEMDispNoZBuff);
         break;

      case HSSTAT_VIEW_DYN_LIMIT:

         ex$message (msgnumb = HS_W_VIEWDYNOUT0, buff = HSmsg0);
         ex$message (msgnumb = HS_W_VIEWDYNOUT1, buff = HSmsg1);
         sprintf (HSmessage, "%s %s", HSmsg0, HSmsg1);

         ex$message (msgnumb = HS_W_WarnTitle, buff = HSmsg0);
         FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                         HSmsg0, FI_RED, "swiss742", 36.0,
                         HSmessage, FI_BLACK, "swiss742", 18.0,
                         FI_LEFT_JUSTIFIED, 40);

         break;

      case HSSTAT_OUT_OF_RANGE:

         if (!active_window->user_notified)
            {
            HSout_of_zrange (active_window->win_no);
            active_window->user_notified = TRUE;
            }
         break;

      case HSSTAT_EDGEII_FEM:
         /* Print warning messages that FEM element is ignored */
         ex$message (msgnumb = HS_E_FemCantDisplay, justification = CENTER_JUS);
         break;

      default:
         ex$message (msgnumb = HS_E_EMSError,
                     type = "%d",
                     var = `tiling_parms.status `);
         sleep (2);
         break;
         }
   }

#define XGL_LOG	0
#if XGL_LOG
int xgl_log_color = 1;

#endif

/*---HStile_object----------------------------------------------------------*/

void HStile_object (struct DPele_header * element,      /* input - element to be
                                                         * tiled		 */
                         enum GRdpmode * mode,  /* input - display mode 		 */
                         IGRint pipe_no,        /* input - gragad to display
                                                 * in		 */
                         struct IGRdisplay * attributes,        /* input - has adjusted
                                                                 * color		 */
                         struct DPgra_gad * gadget)     /* input - ptr to gadget
                                                         * instance data	 */

/***
NAME
        HStile_object
        
DESCRIPTION
        Tiles a B-spline curve or surface, sending the resulting facets to
        HSxform & HSdisplay so they will display in the appropriate
        hidden line window(s).  HSinit_display must have already been called
        at least once; after HStile_object is called for every object of
        interest it is advisable to make a call to HSflush to clear the buffer.

PARAMETERS
        element		:(IN) :  header structure for the element to tile
        mode;	 	:(IN) :  display mode
        pipe_no		:(IN) :  gpipe id number for window
        attributes	:(IN) :  attribute structure for the element, includes color
        gadget		:(IN) :  pointer to the window's gadget instance data

GLOBALS USED
        tiling_parms	: tiler parameter structure
        HSlvhl		: LVHL algorithm info structure
        text_buffer	: array containing text strokes
        max_coords	: size of the text_buffer
        text_gragad	: gragad info needed to stroke the text
        active_window	: active window info structure
        log_file	: output file variable for the standalone file
        
FUNCTIONS CALLED
        BSxtractpar
        DPtxstrk
        EX_scr
        HSactivate_window
        HScheck_range_with_zbuffer
        HScheck_status
        HSfrom_solid
        HSget_bounded_uv_range
        HSget_curve_geometry_from_pline
        HSget_dpb_data
        HSget_manual_soos_on_edge
        HSget_pt_basis
        HSget_surface_edges
        HSget_window_based_cht
        HSset_element_weights
        HSset_line_style
        HSset_status
        HSshade_object
        HSupdate_activated_completed
        HSupdate_heartbeat
        HSzbuffer_24_locked
        get_color_index
        gr$get_hidden_edge_sym
        hs$get_cull_mode
        hs$get_rhl_info
        hs$get_shading_flags
        hs$get_shading_tolerance
        hsnc$get_verification_parameters
        malloc
        realloc
        write
        write_curve
        write_fem
        write_pline
        write_points
        write_surface
        write_text

HISTORY
        09/01/86	S. A. Rapa
                created
                
        09/02/86	M. Lanier
                added mode parameter
                
        10/22/86	S. A. Rapa
                added variable style, translucency, etc.
                
        02/08/87	S. A. Rapa
                added window-based tolerancing

        03/02/87	S. A. Rapa
                changed interpretation of shading styles.

        03/19/87	S. A. Rapa
                moved highlight to wireframe
                
        04/11/87	S. A. Rapa
                changes to support shared library
                
        04/17/87	S. A. Rapa
                added "attributes" parameter

        01/22/88	C. M. Jablonski
                changes to support back plane cull

        04/22/88	C. M. Jablonski
                send tol to srf tiler for srf check
                
        07/06/88	C. M. Jablonski
                changes to support polylines

        03/03/89	C. M. Jablonski
                added partolbasis

        02/14/90	C. M. Jablonski
                moved sampling and tiling to shade_object

        04/26/90	C. M. Jablonski
                added style mode
                
        01/24/92	M. Lanier
                Added this header.
                For bspline curves, added call to HSget_manual_soos_on_edge
                to get the manual overrides for curves
                
        01/28/92	M. Lanier
                Convert pline to curve if has overrides

        02/12/92	S.P. Rogers
                Changed calls to HSget_surface_edges and HSget_curve_geometry_from_pline
                to always pass element->mdenv_info (fix for symbols in LVHL). Also added
                filter to catch and ignore curves during the first pass of LVHL.
                
        01/025/93
                Remove Conditional compile PSUEDO_TRUE_COLOR_FEM_MESH from around a block
                of code Joel had added.
                
 */

   {
   IGRint acc_mode;
   IGRint accuracy;
   IGRint style_mode;
   IGRint style;
   IGRint color;
   IGRboolean part_of_solid = FALSE;
   IGRint options;
   IGRint pixel_tol;
   IGRdouble win_cht = 0.0;
   IGRdouble basis_tol = 0.0;
   IGRdouble dis_tol = 0.0;
   IGRlong msg;
   IGRint fem_mesh;
   IGRint fem_style;
   IGRdouble u_range[2];
   IGRdouble v_range[2];
   IGRint cull_mode;
   IGRboolean dont_cull;
   IGRboolean ele_style;
   int vs_no;
   char *geometry;
   IGRint element_type;
   IGRshort abs_color;
   struct GRhesym hidden_symbology;
   struct WLcontext_info WLcontext_info;

   struct HS_element_rendering_parms render_parms;
   IGRdouble os_scale;

#  if defined (XGL)
   WLuint32	context_no;
#  endif

#if COMPILE
   IGRint i;
   struct IGResfct fem_tile;
   IGRshort color_shade[512];

#endif
   if (!(tiling_parms.processing_mode & HS_PMODE_FEEDBACK))
      HSupdate_heartbeat ();    /* don't update hearbeat when loading
                                 * dynamics */

   /*
    * Make sure we're trying to tile something we know about
    */

   /*
    * if( element->type == IGRPY ) fprintf( stderr, "IGRPY\n" ); else if(
    * element->type == IGRBC ) fprintf( stderr, "IGRBC\n" ); else if(
    * element->type == IGRBS ) fprintf( stderr, "IGRBS\n" ); else if(
    * element->type == IGRLB ) fprintf( stderr, "IGRLB\n" ); else if(
    * element->type == IGRFE ) fprintf( stderr, "IGRFE\n" ); else if(
    * element->type == IGRFM ) fprintf( stderr, "IGRFM\n" ); else if(
    * element->type == IGRPS ) fprintf( stderr, "IGRPS\n" ); else fprintf(
    * stderr, "unknown object\n" );
    */

   if ((element->type != IGRPY) &&
       (element->type != IGRBC) &&
       (element->type != IGRBS) &&
       (element->type != IGRLB) &&
       (element->type != IGRFE) &&
       (element->type != IGRFM) &&
       (element->type != IGRPS))
      {
      fprintf (stderr, "Unknown object, ignored\n");
      return;
      }

   if ((tiling_parms.processing_mode & HS_PMODE_FEEDBACK) &&
       (tiling_parms.processing_mode & HS_PMODE_FEEDBACK_FULL))
      {
      return;
      }

   /*
    * If the object is a surface, run a test to see if we can trivially
    * reject it.  What this function does is to take the max z of the
    * surface, and compare it against all z's in the zbuffer, bounded by the
    * range box of the surface.  If all z in the range box hide the max z of
    * the surface, it cannot be visible.
    */

   if (element->type == IGRBS)
      if (HScheck_range_with_zbuffer (element->geometry.bspsurf, element->range))
         {
         return;
         }

   HSset_status (HSSTAT_OK);
   HSactivate_window (pipe_no);
   if (tiling_parms.status != HSSTAT_OK)
      goto wrapup;

   /*
    * Get display options.
    */

   HSget_dpb_data (element->tag, OM_Gw_current_OS,
                   &acc_mode, &accuracy,
                   &style_mode, &style,
                   &fem_mesh, &fem_style,
                   &render_parms.finish,
                   &render_parms.spec_refl,
                   &render_parms.diff_refl,
                   &render_parms.transparency);

   ele_style = (style_mode == HS_MODE_ELEMENT);

#if COMPILE
/* this code is temporary for simulating a tri mesh*/
/* By placing triangle polygons this will use those points as the points of triangle*/
/* fem meshes.  This is done in ems.*/
      {
      struct fem_vert femvert[10];
      struct fem_color femcolor[10];
      struct HSfem_tri_mesh femtrimesh;

      fem_style = 2;    /* change fem_style */
      if (fem_style != 0)
         {
         if (element->geometry.polyline->num_points > 9)
            printf ("allocate more memory\n");
         for (i = 0; i < 3; i++)
            {
            femvert[i].x = (float) element->geometry.polyline->points[i * 3];
            femvert[i].y = (float) element->geometry.polyline->points[i * 3 + 1];
            femvert[i].z = (float) element->geometry.polyline->points[i * 3 + 2];
            switch (fem_style)
               {
               case 0:
                  switch (i % 3)
                     {
                     case 0:
                        femcolor[i].red = 255;
                        femcolor[i].green = 0;
                        femcolor[i].blue = 0;
                        break;
                     case 1:
                        femcolor[i].red = 0;
                        femcolor[i].green = 255;
                        femcolor[i].blue = 0;
                        break;
                     case 2:
                        femcolor[i].red = 0;
                        femcolor[i].green = 0;
                        femcolor[i].blue = 255;
                        break;
                        }
                  break;

               case 1:
                  switch (i % 3)
                     {
                     case 0:
                        femcolor[i].red = 255;
                        femcolor[i].green = 255;
                        femcolor[i].blue = 0;
                        break;
                     case 1:
                        femcolor[i].red = 0;
                        femcolor[i].green = 255;
                        femcolor[i].blue = 255;
                        break;
                     case 2:
                        femcolor[i].red = 255;
                        femcolor[i].green = 0;
                        femcolor[i].blue = 255;
                        break;
                        }
                  break;

               case 2:
                  switch (i % 3)
                     {
                     case 0:
                        femcolor[i].red = 171;
                        femcolor[i].green = 171;
                        femcolor[i].blue = 86;
                        break;
                     case 1:
                        femcolor[i].red = 86;
                        femcolor[i].green = 171;
                        femcolor[i].blue = 171;
                        break;
                     case 2:
                        femcolor[i].red = 171;
                        femcolor[i].green = 86;
                        femcolor[i].blue = 171;
                        break;
                        }
                  break;

               case 3:
                  femcolor[i].red = (255 * (i + 1)) / element->geometry.polyline->num_points;
                  femcolor[i].green = (255 * (i + 1)) / (element->geometry.polyline->num_points + 1);
                  femcolor[i].blue = (255 * (element->geometry.polyline->num_points - i)) / element->geometry.polyline->num_points;

               case 4:
                  switch (i % 3)
                     {
                     case 0:
                        femcolor[i].red = 63;
                        femcolor[i].green = 51;
                        femcolor[i].blue = 191;
                        break;
                     case 1:
                        femcolor[i].red = 127;
                        femcolor[i].green = 102;
                        femcolor[i].blue = 127;
                        break;
                     case 2:
                        femcolor[i].red = 191;
                        femcolor[i].green = 153;
                        femcolor[i].blue = 63;
                        break;
                        }
                  break;

               default:
                  break;
                  }
            }

         i = 3;
         element->type = IGRFM;
         femtrimesh.num_verts = i;
         femtrimesh.verts = femvert;
         femtrimesh.colors = femcolor;
         element->ele_spec_att.null = (char *) (&femtrimesh);
         fem_style = HS_FEM_BLENDED;
         fem_mesh = HS_FEM_MESH_ON;
         }
      else
         fem_style = 0;
      }
/* this code is temporary for simulating a tri mesh*/
#endif

#if COMPILE
/* this code is temporary for simulating a fem tile */
   if (element->type == IGRBS)
      {
      element->type = IGRFE;
      fem_tile.n_mid = 1;
      for (i = 0; i < ((fem_tile.n_mid + 2) * (fem_tile.n_mid + 2)); i++)
         color_shade[i] = (IGRshort) ((IGRint) ((0xFFFF * i) / (((fem_tile.n_mid + 2) * (fem_tile.n_mid + 2)) - 1)));
      fem_tile.color_shade = color_shade;
      element->ele_spec_att.null = (char *) (&fem_tile);
      fem_style = HS_FEM_BLENDED;
      }
/* this code is temporary for simulating a fem tile */
#endif

   /*
    * Get HSNC parameters.   - CMJ  02/06/90.
    */

   if (tiling_parms.processing_mode & HS_PMODE_DEXEL)
      {
      hsnc$get_verification_parameters (shading_style = &style);
      if (style == HSNC_SMOOTH_SHADED)
         style = HS_STYLE_SMOOTH;
      else
         style = HS_STYLE_CONSTANT;
      }


   /*
    * If the display mode is erase, we want the display color of the object
    * to be background.
    */

   if ((*mode != GRbe) && (*mode != GRbeheo) && (*mode != GRbehe) &&
       (*mode != GRbehd))
      color = element->dis_att->color;
   else
      color = HS_BACKGROUND_COLOR;

#if XGL_LOG
   xgl_log_color = color;
#endif


   gr$get_hidden_edge_sym (buffer = &hidden_symbology);

   /*
    * Set the visible and hidden style of the object.  The visible style is
    * always the original style, but the hidden style will be either the
    * original or hidden symbology style, depending on the state of the
    * use_orig_style flag.
    */

   if (hidden_symbology.flags & DPB_USE_ORIG_STYLE)
      HSset_line_style (element->dis_att->style, element->dis_att->style);
   else
      HSset_line_style (element->dis_att->style, hidden_symbology.style);


   /*
    * Get the hidden color of the object.  This depends on the state of the
    * use_orig_color flag.  If set, use the original color of the object,
    * else use the hidden symbology color.
    */

   if (hidden_symbology.flags & DPB_USE_ORIG_COLOR)
      {
#     if defined (XGL)

         /*  for XGL, we want to use the 8bit forms context to convert  */
         /*  our logical color index to a physical one because the  */
         /*  active context is 24bit and would return a bad value  */

         CMget_exnuc_forms_context (active_window->vs_no, &context_no);
         ige$get_abs_color_index (context_no = context_no,
                                  log_color = (IGRshort) color,
                                  abs_color = &abs_color);
#     else
         ige$get_abs_color_index (context_no = active_window->context_no,
                                  log_color = (IGRshort) color,
                                  abs_color = &abs_color);
#     endif

      element_parms.hidden_color = abs_color;
      }
   else
      {
#     if defined (XGL)

         /*  for XGL, we want to use the 8bit forms context to convert  */
         /*  our logical color index to a physical one because the  */
         /*  active context is 24bit and would return a bad value  */

         CMget_exnuc_forms_context (active_window->vs_no, &context_no);
         ige$get_abs_color_index (context_no = context_no,
                                  log_color = (IGRshort) hidden_symbology.color,
                                  abs_color = &abs_color);
#     else
         ige$get_abs_color_index (context_no = active_window->context_no,
                                  log_color = (IGRshort) hidden_symbology.color,
                                  abs_color = &abs_color);
#     endif

      element_parms.hidden_color = abs_color;
      }

   /*
    * Set the hidden and visible weight, the visible weight is always the
    * elements original weight, but the hidden weight will be either the
    * hidden symbology weight or the element's original weight, depending on
    * the use_orig_weight flag
    */

   if (hidden_symbology.flags & DPB_USE_ORIG_WEIGHT)
      HSset_element_weights (element->dis_att->weight, element->dis_att->weight);
   else
      HSset_element_weights (element->dis_att->weight, hidden_symbology.weight);


   /*
    * Set a flag in the processing mode to indicate that the normal polyline
    * rasterize cannot be used
    */

   if (element->dis_att->weight == 0 && element->dis_att->style == 0)
      tiling_parms.processing_mode &= ~HS_PMODE_SWINE;
   else
      tiling_parms.processing_mode |= HS_PMODE_SWINE;


   hs$get_cull_mode (cull_mode = &cull_mode);
   dont_cull = (cull_mode == HS_CULL_NO);

   if (acc_mode == HS_ACCURACY_MODE_WINDOW)
      {

      /*
       * Stroking to CHT is requested, so get the CHT for this window.
       */

      /* make the shading tolerance a little finer */
      if (DPdlist_feedback_in_progress)
         {
         /* display list feedback => use world coordinate tolerance */
         DPdlist_get_object_space_scale (OM_Gw_current_OS, &os_scale);
         win_cht = DPdlist_stroke_tolerance / (2.0 * os_scale);
         }
      else
         {
         dp$inq_display_tolerance (pixel_toler = &pixel_tol);
         HSget_window_based_cht (&win_cht, pipe_no, ((double) pixel_tol) / 2.0, element->range);
         }
      }

   /*
    * Get the distol.
    */

   BSxtractpar (&msg, BSTOLLENVEC, &dis_tol);

   /*
    * If RHL/LVHL first pass, surfaces go through, and curve go though if
    * closed curve area is set and the curve is closed and planar.  All other
    * objects are ignored
    */

   if ((tiling_parms.processing_mode & (HS_PMODE_RHL_SURFACE | HS_PMODE_LVHL_SURFACE)))
      {
      if (element->type != IGRBS)
         {
         if (tiling_parms.processing_mode & HS_PMODE_PVHL_SURFACE &&
             (element->type == IGRBC | element->type == IGRPY))
            {
            }
         else
            {
            return;
            }
         }
      }

   /*
    * If in LVHL mode, or RHL 1st pass, update the activated/completed
    * display
    */


   if (tiling_parms.processing_mode & (HS_PMODE_LVHL_SURFACE | HS_PMODE_LVHL_EDGES      /* |
                                           HS_PMODE_RHL_SURFACE */ ))
      HSupdate_activated_completed ();

   /*
    * Set the type-dependent shading parameters.
    */

   switch (element->type)
      {
      case IGRPY:
      case IGRBC:
         switch (style)
            {
            case HS_STYLE_RASTER:
               options = HS_BST_EDGES;
               break;
            case HS_STYLE_FILLED_RASTER:
               options = HS_BST_REV_EDGES;
               break;

            default:
               if ((*mode != GRbe) && (*mode != GRbeheo)
                   && (*mode != GRbehe) && (*mode != GRbehd))
                  options = HS_BST_POLYLINE;
               else
                  options = HS_BST_POLYLINE_DELETE;
               break;
               }

         HSget_manual_soos_on_edge (
                                    (GRobjid) element->tag,
                                    OM_Gw_current_OS,
                                    element->mdenv_info->matrix,
                                    &element->mdenv_info->matrix_type,
                                    element->mdenv_info,
                                    element->dis_att);

         break;

      case IGRBS:

         if ((*mode != GRbe) && (*mode != GRbeheo)
             && (*mode != GRbehe) && (*mode != GRbehd))
            {
            if (render_parms.transparency >= 0.5)
               options = GR_BST_TRANSP;
            else
               options = 0;
            }
         else
            {
            options = ((style == HS_STYLE_RASTER) ||
                       (style == HS_STYLE_FILLED_RASTER))
               ? HS_BST_EDGES_DELETE
               : HS_BST_DELETE;
            }

         switch (style)
            {
            case HS_STYLE_SMOOTH:
               options |= GR_BST_SMOOTH;
               break;
            case HS_STYLE_CONSTANT:
               options |= GR_BST_CONSTANT;
               break;
            case HS_STYLE_RASTER:
               options |= HS_BST_EDGES;
               break;
            case HS_STYLE_FILLED_RASTER:
               options |= HS_BST_REV_EDGES;
               break;
            case HS_STYLE_AREAFILL:
               options |= GR_BST_SOLID;
               break;
               }

         if (part_of_solid = HSfrom_solid (element->tag, OM_Gw_current_OS))
            {
            IGRdouble *mat, det;

            /*
             * if the environment matrix for this surface contains a mirror
             * transformation
             */

            /*
             * (i.e., the determinant < 0), flip the pos_orient field so the
             * surface will
             */
            /* be culled correctly.                                                        */
            mat = element->mdenv_info->matrix;
            det = (mat[5] * mat[10] - mat[6] * mat[9]) * mat[0] -
               (mat[4] * mat[10] - mat[6] * mat[8]) * mat[1] +
               (mat[4] * mat[9] - mat[5] * mat[8]) * mat[2];

            if (det < 0)
               element->geometry.bspsurf->pos_orient = !element->geometry.bspsurf->pos_orient;
            }

         if ((tiling_parms.processing_mode & HS_PMODE_RHL_EDGES) ||
             (tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES))
            {
            HSget_surface_edges (
                                 NULL,
                                 element->tag,
                                 OM_Gw_current_OS,
                                 element->geometry.bspsurf,
                                 element->mdenv_info,
                                 options,
                                 pipe_no,
                                 color,
                                 acc_mode,
                                 accuracy,
                                 win_cht,
                                 gadget->dit_clip_range,
                                 gadget->rotation,
                         tiling_parms.processing_mode & HS_PMODE_RHL_EDGES ?
                             HS_GET_EDGES_MODE_RHL : HS_GET_EDGES_MODE_LVHL,
                                 active_window->perspective,
                                 eye_pt);

            goto wrapup;
            }

         basis_tol = HSget_pt_basis (element->tag, OM_Gw_current_OS);

         HSget_bounded_uv_range (element->tag,
                                 OM_Gw_current_OS,
                                 element->geometry.bspsurf,
                                 u_range,
                                 v_range);

         break;

      case IGRPS:
         if ((*mode != GRbe) && (*mode != GRbeheo)
             && (*mode != GRbehe) && (*mode != GRbehd))
            options = HS_BST_POINT;
         else
            options = HS_BST_POINT_DELETE;

         break;

      case IGRLB:

         switch (style)
            {
            case HS_STYLE_RASTER:
               options = HS_BST_EDGES;
               break;
            case HS_STYLE_FILLED_RASTER:
               options = HS_BST_REV_EDGES;
               break;

            default:
               if ((*mode != GRbe) && (*mode != GRbeheo)
                   && (*mode != GRbehe) && (*mode != GRbehd))
                  options = HS_BST_POLYLINE;
               else
                  options = HS_BST_POLYLINE_DELETE;
               break;
               }

         attributes->style = 0;
         HSset_line_style (0, 0);

         if (text_buffer == NULL)
            text_buffer = (IGRdouble *) malloc (max_coords * 3 *
                                                sizeof (IGRdouble));

         text_status = FALSE;
         while (!text_status)
            {
            coords_returned = max_coords;

            text_status = DPtxstrk (&msg,
                                    element->geometry.lbsys,
                                    element->ele_spec_att.text,
                                    attributes,
                                    text_gragad.win_no,
                                    pipe_no,
                                    text_gragad.fnt_os_ptr,
                                    text_gragad.flags,
                                    element->flags,
                                    0.0, 0,
                                    text_buffer,
                                    &coords_returned);

            if (!text_status)
               {
               max_coords += 100;

               text_buffer = (IGRdouble *)
                  realloc (text_buffer,
                           max_coords * 3 *
                           sizeof (IGRdouble));
               }
            }

         if (coords_returned <= 1)
            {
            coords_returned = 1;
            return;
            }

         break;

      case IGRFE:
         WLget_window_screen (active_window->win_no, (WLuint16 *) & vs_no);
         WLget_context_info (active_window->context_no, &WLcontext_info);

         if (WLcontext_info.base_cmap_type & WL_CMAP_TRUE_COLOR)
            {
            /* fem tiles are not supported in True color mode */
            tiling_parms.status = HSSTAT_EDGEII_FEM;
            goto wrapup;
            }

         if ((*mode != GRbe) && (*mode != GRbeheo) && (*mode != GRbehe) && (*mode != GRbehd))
            {
            options = HS_FEM;
            if (fem_style == HS_FEM_BLENDED)
               options |= HS_FEM_DITHERED;
            if (fem_mesh == HS_FEM_MESH_ON)
               options |= HS_FEM_MESH;
            }
         else
            {
            options = HS_FEM | HS_FEM_DELETE;
            }
         break;

      case IGRFM:

         WLget_window_screen (active_window->win_no, (WLuint16 *) & vs_no);

         if ((*mode != GRbe) && (*mode != GRbeheo)
             && (*mode != GRbehe) && (*mode != GRbehd))
            {
            if (render_parms.transparency >= 0.5)
               options = GR_BST_TRANSP;
            else
               options = 0;
            }

         if (style == HS_STYLE_SMOOTH)
            options |= GR_BST_SMOOTH;
         else
            options |= GR_BST_CONSTANT;

         if (fem_mesh == HS_FEM_MESH_ON)
            options |= HS_FEM_MESH;

         break;

         }


   /*
    * Shade the object.
    */

   element_type = (IGRint) element->type;
   switch (element->type)
      {
      case IGRPY:

         /*
          * The object is a polyline.  If it has manual overrides, we have to
          * get the geometry so that boundaries can be placed on it.  Reset
          * the type so that shade object will treat it like a curve.
          */

         if (HSlvhl.p_count > 0 || tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES)
            {
            HSget_curve_geometry_from_pline (
                                             element->tag,
                                             OM_Gw_current_OS,
                                             element->mdenv_info,
                                             &geometry);

            element_type = (IGRint) IGRBC;
            }
         else
            geometry = (char *) element->geometry.polyline;
         break;

      case IGRBC:
         geometry = (char *) element->geometry.bspcurve;
         break;

      case IGRBS:
         geometry = (char *) element->geometry.bspsurf;
         break;

      case IGRPS:
         geometry = (char *) element->geometry.point_set;
         break;

      case IGRLB:
         geometry = (char *) element->geometry.lbsys;
         break;

      default:
         geometry = (char *) element->geometry.bspcurve;
         break;
         }


   HSshade_object (SHADE_IT,
                   pipe_no,
                   element_type,
                   geometry,
                   element->ele_spec_att.null,
                   gadget->dit_clip_range,
                   element->range,
                   u_range,
                   v_range,
                   acc_mode,
                   accuracy,
                   win_cht,
                   basis_tol,
                   dis_tol,
                   color,
                   options,
                   ele_style,
                   part_of_solid,
                   dont_cull,
                   text_buffer,
                   coords_returned,
                   &render_parms,
                   NULL);       /* minimum x return value	 */


   if (debug_standalone)
      {
      IGRint temp_int;

      write (log_file, &DS_OBJECT_INFO, 4);
      write (log_file, &pipe_no, 4);
      write (log_file, &options, 4);
      temp_int = part_of_solid;
      write (log_file, &temp_int, 4);
      temp_int = ele_style;
      write (log_file, &temp_int, 4);
      temp_int = dont_cull;
      write (log_file, &temp_int, 4);
      write (log_file, &element->type, sizeof (IGRshort));
      write (log_file, element->range, 6 * sizeof (IGRdouble));
      write (log_file, u_range, 2 * sizeof (IGRdouble));
      write (log_file, v_range, 2 * sizeof (IGRdouble));
      write (log_file, &win_cht, sizeof (IGRdouble));
      write (log_file, &basis_tol, sizeof (IGRdouble));
      write (log_file, &color, sizeof (IGRint));
      write (log_file, &render_parms.transparency, sizeof (IGRdouble));
      write (log_file, &render_parms.finish, sizeof (IGRint));
      write (log_file, &render_parms.diff_refl, sizeof (IGRdouble));
      write (log_file, &render_parms.spec_refl, sizeof (IGRdouble));

      switch (element->type)
         {
         case IGRBS:
            write_surface (element->geometry.bspsurf);
            break;
         case IGRBC:
            write_curve (element->geometry.bspcurve);
            break;
         case IGRPY:
            write_pline (element->geometry.polyline);
            break;
         case IGRPS:
            write_points (element->geometry.point_set);
            break;
         case IGRLB:
            write_text ();
            break;
         case IGRFE:
            write_surface (element->geometry.bspsurf);
            write_fem ((struct IGResfct *) element->ele_spec_att.null);
            break;
            }
      }

wrapup:
#if defined( ENV5 )
   if (active_window->type & HShardware_LB_EG)
      {
      /* always leave lighting on and reset the shading model => */
      /* it makes the display list happy because it assumes its  */
      /* always set-up properly during updates                   */
      if (active_window->shading_style == HS_STYLE_SMOOTH)
         {
         EGSetRenderMethod (active_window->EG_vc_no, EG_RENDER_GOUR);
         }
      else
         {
         EGSetRenderMethod (active_window->EG_vc_no, EG_RENDER_FLAT);
         }
      EGSetLightingMode (active_window->EG_vc_no, EG_ON);
      EGSetReflectEqn (active_window->EG_vc_no, EG_REFL_AMB_DIF_SPEC);
      }
#endif

#if defined( OPENGL )
   if (active_window->type & HShardware_LB_OPENGL)
      {
      /* always leave lighting on and reset the shading model => */
      /* it makes the display list happy because it assumes its  */
      /* always set-up properly during updates                   */
      glEnable (GL_LIGHTING);
      if (active_window->shading_style == HS_STYLE_SMOOTH)
         {
         glShadeModel (GL_SMOOTH);
         }
      else
         {
         glShadeModel (GL_FLAT);
         }
      }
#endif
#if defined( XGL )
   if (active_window->type & HShardware_LB_XGL)
      {
      /* always leave lighting on and reset the shading model => */
      /* it makes the display list happy because it assumes its  */
      /* always set-up properly during updates                   */
/*
           glEnable( GL_LIGHTING );
*/

      if (active_window->shading_style == HS_STYLE_SMOOTH)
         {
         xgl_object_set (active_window->xgl_context_3D,
                         XGL_3D_CTX_SURF_FRONT_ILLUMINATION,
                         XGL_ILLUM_PER_VERTEX,
                         XGL_3D_CTX_SURF_BACK_ILLUMINATION,
                         XGL_ILLUM_PER_VERTEX, NULL);
         }
      else
         {
         xgl_object_set (active_window->xgl_context_3D,
                         XGL_3D_CTX_SURF_FRONT_ILLUMINATION,
                         XGL_ILLUM_PER_FACET,
                         XGL_3D_CTX_SURF_BACK_ILLUMINATION,
                         XGL_ILLUM_PER_FACET, NULL);
         }
      }
#endif

   HScheck_status ();
   }


/*--- HSrender_object ----------------------------------------------------------*/

void HSrender_object (struct IGRbsp_surface * srf,
                           IGRint objid,
                           IGRint osnum,
                           IGRdouble range[6],
                           IGRdouble clip_range[6],
                           struct HS_element_rendering_parms * render_parms,
                           IGRint pipe_no,
                           IGRboolean just_get_range,
                           IGRint * min_x,
                           IGRboolean dont_cull)

/**
NAME
        HSrender_object
        
DESCRIPTION
        HSrender_object renders a bspline surface.  It first retrieves
        the necessary rendering parameters, then finds the surface
        sample points, then calls HSrender_tiler to tile the surface.

PARAMETERS
        srf		:(IN) :  Pointer to the element to render
        objid		:(IN) :  Object id of the element to render
        osnum		:(IN) :  Object space number of the element to render
        range		:(IN) :  Range of the element
        clip_range	:(IN) :  Dit clip range of the viewport
        render_parms	:(IN) :  Rendering parameter for the element
        pipe_no		:(IN) :  Gpipe id number for the window
        just_get_range	:(IN) :  mode flag
        min_x		:(OUT):  Minimum x of the element
        dont_cull	:(IN) :  TRUE, dont cull element,
                                 FALSE, go through normal culling checks
GLOBALS USED
        tiling_parms	: tiler parameter structure
        
FUNCTIONS CALLED
        BSxtractpar
        HSactivate_FACET
        HScheck_status
        HSfrom_solid
        HSget_bounded_uv_range
        HSget_dpb_data
        HSget_pt_basis
        HSget_status
        HSget_window_based_cht
        HSshade_object
        hs$get_shading_tolerance

HISTORY
        07/20/89	C. M. Jablonski
                Created.

        02/14/90	C. M. Jablonski
                Moved sampling/tiling to shade_object
                
        01/24/92	M. Lanier
                Added this header
 */


   {
   IGRint mode;
   IGRint acc_mode;
   IGRint accuracy;
   IGRint style_mode;
   IGRint style;
   IGRint fem_mesh;
   IGRint fem_style;
   IGRlong msg;
   IGRboolean part_of_solid;
   IGRdouble win_cht = 0.0;
   IGRdouble par_basis_tol = 0.0;
   IGRdouble shading_tol = 0.0;
   IGRdouble dis_tol = 0.0;
   struct HS_element_rendering_parms tmp_rp;

   IGRdouble u_range[2];        /* U range of solid portion of surface */
   IGRdouble v_range[2];        /* V range of solid portion of surface */


   HSset_status (HSSTAT_OK);

   /*
    * Get display options.
    */

   HSactivate_window (pipe_no);
   if (tiling_parms.status != HSSTAT_OK)
      goto wrapup;

   par_basis_tol = HSget_pt_basis (objid, osnum);
   part_of_solid = HSfrom_solid (objid, osnum);

   HSget_dpb_data (objid, osnum,
                   &acc_mode, &accuracy,
                   &style_mode, &style,
                   &fem_mesh, &fem_style,
                   &tmp_rp.finish,
                   &tmp_rp.spec_refl,
                   &tmp_rp.diff_refl,
                   &tmp_rp.transparency);

   HSget_bounded_uv_range (objid, osnum, srf, u_range, v_range);

   if (acc_mode == HS_ACCURACY_MODE_WINDOW)
      {

      /*
       * Stroking to CHT is requested, so get the CHT for this window.
       */

      hs$get_shading_tolerance (tolerance = &shading_tol);

      HSget_window_based_cht (&win_cht,
                              pipe_no,
                              shading_tol,
                              range);
      }


   /*
    * Get the distol.
    */

   BSxtractpar (&msg, BSTOLLENVEC, &dis_tol);


   /*
    * Set the mode flag.
    */

   if (just_get_range)
      mode = FIND_ITS_MIN_X;
   else
      mode = RENDER_IT;


   /*
    * Render or determine minimum x of the object.
    */

   HSshade_object (mode,
                   pipe_no,
                   IGRBS,       /* element type flag		 */
                   (char *) srf,
                   NULL,        /* element-specific attributes	 */
                   clip_range,
                   range,
                   u_range,
                   v_range,
                   acc_mode,
                   accuracy,
                   win_cht,
                   par_basis_tol,
                   dis_tol,
                   NULL,        /* element color		 */
                   NULL,        /* element display options	 */
                   NULL,        /* shading style mode		 */
                   part_of_solid,
                   dont_cull,
                   NULL,        /* text stroke buffer		 */
                   NULL,        /* coords returned		 */
                   render_parms,
                   min_x);

wrapup:
   if (!just_get_range)
      HScheck_status ();
   }

