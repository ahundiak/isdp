
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $

HISTORY

        Sudha   07/27/93        Modified for BSprototypes ansification
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdio.h>

#include "wl.h"

#include "bserr.h"
#include "bs.h"
#include "bsparameters.h"
#include "bschrdlkts.h"

#include "hsncdef.h"
#include "hnmilling.h"
#include "hnerror.h"
#include "hnorient.h"
#include "hnsimulate.h"
#include "hntiming.h"
#include "hntoolpath.h"
#include "hnmill.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hsdisplay.h"
#include "hstiler.h"
#include "HSsara.h"

#include "HSpr_ncv_fun.h"
#include "HSpr_co_func.h"

#define DEBUG              FALSE
#define SHOW_DISPLAY_LIST  FALSE

#define NORMALIZE(vector)                                              \
{                                                                      \
   length = sqrt((vector[0] * vector[0]) + (vector[1] * vector[1]) +   \
            (vector[2] * vector[2]));                                  \
   vector[0] /= length;                                                \
   vector[1] /= length;                                                \
   vector[2] /= length;                                                \
}


/**********************
 * EXTERNAL VARIABLES *
 **********************/

extern int                      IGEstop();
extern IGRboolean               NCget_next_position();

extern struct NC_error_flags    NCerror_flags;
extern struct NC_shading_parms  NCshading;
extern struct NC_sim_data       NCsim_data;
extern struct NC_tool_orient    NCtool_orient;
extern struct NC_toolpath_data  NCtoolpath_data;
extern struct NC_window_parms   NCwindow;


/*******************
 * LOCAL VARIABLES *
 *******************/

static double               *ncv_display_list;   /* the display list */
static struct IGRbsp_curve  *ncv_tool_curve;     /* the tool curve */

static IGRboolean           ncv_wireframe;
static IGRboolean           ncv_first_toolpath;
static IGRboolean           first_move;
static IGRboolean           ncv_single_step;
static IGRboolean           ncv_tool_exists;
static IGRboolean           ncv_new_tool;
static IGRint               ncv_global_speed;
static IGRboolean           ncv_use_toolpath_speed;
static IGRboolean           ncv_use_new_interactive_speed;
static IGRboolean           ncv_using_toolpath_trans;
static IGRint               ncv_original_tool_color;
static IGRint               ncv_original_tool_trans;
static IGRint               ncv_prev_toolpath_color;
static IGRint               ncv_command_count;

#if NC_TIMING
/*-----NCinit_timing----------------------------------------------------------*/
static void NCinit_timing ()

/*
 * ABSTRACT:   NCinit_timing initializes the nc_timing_data structure.
 *
 * HISTORY:   06/15/89  Created.         C. M. Jablonski
 */

{
   IGRint   count;

   for (count = 0; count < NUM_NC_TIMES; count++)
   {
      nc_timing_data[count].num_calls = 0;
      nc_timing_data[count].total_time = 0.0;
   }

   sprintf(nc_timing_data[NCtd_INIT].name, "%s", "(1) Initialization:    ");
   sprintf(nc_timing_data[NCtd_DO_STEP].name,"%s", "(2) Step Execution:    ");
   sprintf(nc_timing_data[NCtd_MOVE_TOOL].name, "%s",
                                        "  (A) Move Tool:       ");
   sprintf(nc_timing_data[NCtd_BRESENHAM].name, "%s",
                                        "    (a) Bresenham:     ");
   sprintf(nc_timing_data[NCtd_SUBTRACT_SIM].name, "%s",
                                        "      (1) SUBTRACT SIM:");
   sprintf(nc_timing_data[NCtd_PAINT_SIM].name, "%s",
                                        "      (2) PAINT SIM:   ");
   sprintf(nc_timing_data[NCtd_BUILD_SWVOL].name, "%s",
                                        "  (A) Build Swvol:     ");
   sprintf(nc_timing_data[NCtd_DEX_SWVOL].name, "%s",
                                        "  (B) Dxlz Swvol:      ");
   sprintf(nc_timing_data[NCtd_SUBTRACT_DEX].name, "%s",
                                        "    (a) SUBTRACT SWVOL:");
   sprintf(nc_timing_data[NCtd_PAINT].name, "%s",
                                        "    (b) PAINT SWVOL:   ");
   sprintf(nc_timing_data[NCtd_CLEANUP].name, "%s",
                                        "(3) Cleanup:           ");
   sprintf(nc_timing_data[NCtd_TILE].name, "%s",
                                        "Five Axis tiling       ");
}


/*-----NCreport_timing--------------------------------------------------------*/
static void NCreport_timing ()

/*
 * ABSTRACT:   NCreport_timing prints out the timing results.
 *
 * HISTORY:   06/15/89  Created.         C. M. Jablonski
 */

{
   IGRdouble   total_time;
   IGRint      count;

   total_time = nc_timing_data[NCtd_INIT].total_time +
                nc_timing_data[NCtd_DO_STEP].total_time +
                nc_timing_data[NCtd_CLEANUP].total_time;

   fprintf(stderr, "\nTotal time = %lf seconds\n\n", total_time);
   fprintf(stderr,
        "                            CALLS    CPU TIME  TIME/CALL  PERCENT\n" );
   fprintf(stderr,
        "                         ----------- --------- ---------  -------\n" );

   for (count = 0; count < NUM_NC_TIMES; count++)
   {
      fprintf(stderr, "%24s %11d %9.2lf %9.4lf  %7.2lf\n",
                    nc_timing_data[count].name,
                    nc_timing_data[count].num_calls,
                    nc_timing_data[count].total_time,
                    (nc_timing_data[count].num_calls) ?
                    (nc_timing_data[count].total_time /
                    (float)nc_timing_data[count].num_calls) : 0.0,
                    ((nc_timing_data[count].total_time / total_time) * 100.0));
   }
}
#endif


/*-----NCinit-----------------------------------------------------------------*/

static IGRint NCinit ( struct HSNC_mode_parms mode_parms )

/*
 * ABSTRACT:   NCinit performs the initialization of the ShadedNC code.
 *             It is meant to be called after the workpiece has been tiled.
 *             It initializes the dexel buffers, (using the range of the
 *             workpiece), dexelizes and displays the workpiece, initializes
 *             global data and mode flags.  It returns SNC_NOMEM if there was
 *             an allocation error, SNC_OK otherwise.
 *
 * HISTORY:   07/26/88   Created.                   C. M. Jablonski
 *            08/11/89   Added HSNC_mode_parms      C. M. Jablonski
 */

{
   START_NC_TIMING(NCtd_INIT)

   /* initialize local flags */
   ncv_first_toolpath = TRUE;
   first_move = TRUE;
   ncv_single_step = mode_parms.single_step;
   ncv_tool_exists = FALSE;
   ncv_new_tool = FALSE;
   ncv_use_new_interactive_speed = FALSE;
   ncv_original_tool_color =
   ncv_prev_toolpath_color = HSNC_USE_TOOL_COLOR;
   NCsim_data.active_tool_color = HSNC_USE_TOOL_COLOR;
   ncv_original_tool_trans = 0;
   NCsim_data.active_tool_trans = 0;
   ncv_using_toolpath_trans = FALSE;

   /* initialize global mode flags */
   if (NCsim_data.simulation_mode = 
                 (mode_parms.display_mode == HSNC_SIMULATION))
   {
      NCsim_data.simulation_speed = mode_parms.simulation_speed;
      ncv_global_speed = mode_parms.simulation_speed;
      ncv_use_toolpath_speed = TRUE;
   }

   ncv_wireframe = mode_parms.display_mode == HSNC_SWVOL_TOOL;

   if (mode_parms.shading_style == HSNC_SMOOTH_SHADED)
   {
       NCshading.active_shading_style = NCshading.SMOOTH_SHADING;
   }
   else
   {
       NCshading.active_shading_style = NCshading.CONSTANT_SHADING;
   }

   HSset_dexel_shading_style( NCshading.active_shading_style );

   /* initialize global status flags */
   NCerror_flags.memory_fault = FALSE;

   /* initialize other data structures */
   NCinit_toolpath( NULL );
   NCinit_orientation();
   NCinit_window();

   /* dexelize environment objects */
   if (!NCerror_flags.memory_fault)
      NCdexelize_workpiece();

   /* initialize simulation mode */
   if (NCerror_flags.memory_fault)
   {
      return (SNC_BIGENV);
   }
   else if (NCsim_data.simulation_mode)
   {
      NCinit_simulation();
   }

STOP_NC_TIMING(NCtd_INIT)

   return ( (NCerror_flags.memory_fault) ? (SNC_BIGTOOL) : (SNC_OK) );
}


/*-----NCchange_mode----------------------------------------------------------*/

static IGRint NCchange_mode( IGRboolean              new_interactive_speed,
                             struct HSNC_mode_parms  mode_parms )

/*
 * ABSTRACT:   NCchgmode updates only those mode flags that are allowed to
 *             change during execution.
 *
 * HISTORY: 09/21/88   Created.                      C. M. Jablonski
 *          10/26/88   Added new_interactive_speed   K. M. Jehng
 *          08/11/89   Added HSNC_mode_parms         C. M. Jablonski
 */

{
   IGRint      speed;


   ncv_single_step = mode_parms.single_step;

   if (NCsim_data.simulation_mode)
   {
      if (!ncv_use_toolpath_speed || new_interactive_speed)
      {
         speed = mode_parms.simulation_speed;

         if (NCsim_data.simulation_speed != speed)
         {
            NCupdate_sim_speed( speed );
         }

         if (new_interactive_speed)
         {
            ncv_use_new_interactive_speed = TRUE;
         }
      }
      else
      {
         ncv_use_toolpath_speed = FALSE;
      }
   }

   return ( (NCerror_flags.memory_fault) ? (SNC_BIGTOOL) : (SNC_OK) );
}


/*-----NCdo_step--------------------------------------------------------------*/

static IGRint NCdo_step (void)

/*
 * ABSTRACT:   NCdo_step executes the next path step.  It returns SNC_NOMEM
 *             if there was an allocation error, SNC_OK otherwise.
 *
 * HISTORY:  07/26/88   Created.                   C. M. Jablonski
 *           09/22/88   Added simulation mode      K. M. Jehng
 */

{
   START_NC_TIMING(NCtd_DO_STEP)

   if (NCget_next_position())
   {
      if (NCsim_data.simulation_mode)
      {
         NCmove_sim_tool( ncv_single_step || NCtoolpath_data.end_of_toolpath,
                          first_move );
         first_move = FALSE;
      }
      else
      {
         NCbuild_swept_volume();
         NCdexelize_swvol();
      }
      NCupdate_toolpath_position();
   }

   STOP_NC_TIMING(NCtd_DO_STEP)

   return ( (NCerror_flags.memory_fault) ? (SNC_NOMEM) : (SNC_OK) );
}


/*-----NCcleanup--------------------------------------------------------------*/

static void NCcleanup (void)

/*
 * ABSTRACT:   NCcleanup deallocates all memory used in the ShadedNC files
 *             and kicks the tiler out of dexel mode.
 *
 * HISTORY:   07/26/88   Created.         C. M. Jablonski
 */

{
   START_NC_TIMING(NCtd_CLEANUP)

   /* cleanup local data */
   if (ncv_tool_curve)
   {
      if (ncv_tool_curve->poles)
      {
         free( ncv_tool_curve->poles );
         ncv_tool_curve->poles = NULL;
      }

      if (ncv_tool_curve->knots)
      {
         free( ncv_tool_curve->knots );
         ncv_tool_curve->knots = NULL;
      }

      if (ncv_tool_curve->weights)
      {
         free( ncv_tool_curve->weights );
         ncv_tool_curve->weights = NULL;
      }

      free( ncv_tool_curve );
      ncv_tool_curve = NULL;
   }

   /* cleanup other data */
   NCcleanup_dexel_buffers();
   NCcleanup_simulation(TRUE);
   NCcleanup_tool();
   NCcleanup_toolpath();
   NCcleanup_trap();
   NCcleanup_window();

   STOP_NC_TIMING(NCtd_CLEANUP)
}


#if SHOW_DISPLAY_LIST
/*-----print_curve------------------------------------------------------------*/

static void print_curve(struct IGRbsp_curve *curve,
                        IGRboolean            flag )

/*
 * struct IGRbsp_curve *curve (IN) - B-Spline curve to debug
 * IGRboolean            flag (IN) - if TRUE curve dumped in math format
 */

{
   IGRchar  name;
   IGRint   ui;
   IGRint   index;

   if ( flag )
   {
      BSprintbspc( stderr, &name, curve, FALSE );
   }
   else
   {
      fprintf ( stderr, "   order       = %d\n", curve->order);
      fprintf ( stderr, "   num_poles   = %d\n", curve->num_poles);
      fprintf ( stderr, "   num_knots   = %d\n", curve->num_knots);
      fprintf ( stderr, "   rational    = %d\n", curve->rational);
      fprintf ( stderr, "   planar      = %d\n", curve->planar);
      fprintf ( stderr, "   phy_closed  = %d\n", curve->phy_closed);
      fprintf ( stderr, "   periodic    = %d\n", curve->periodic);
      fprintf ( stderr, "   non_uniform = %d\n", curve->non_uniform);
      fprintf ( stderr, "   num_bounds  = %d\n\n", curve->num_boundaries );

      if (curve->rational != 0)
      {
         fprintf ( stderr, "   Poles (u, x, y, z, w):\n");

         for (ui = 0; ui < curve->num_poles; ui++)
         {
            fprintf ( stderr,
                      "  %4d %20.12lf %20.12lf %20.12lf %20.12lf\n",
                      ui,
                      curve->poles[(ui) * 3] / curve->weights[ui],
                      curve->poles[(ui) * 3 + 1] / curve->weights[ui],
                      curve->poles[(ui) * 3 + 2] / curve->weights[ui],
                      curve->weights[ui]);
         }
      }
      else
      {
         fprintf ( stderr, "   Poles (u, x, y, z):\n");
 
         for (ui = 0; ui < curve->num_poles; ui++)
         {
            fprintf ( stderr, " %4d %20.12lf %20.12lf %20.12lf\n",
                      ui,
                      curve->poles[(ui) * 3],
                      curve->poles[(ui) * 3 + 1],
                      curve->poles[(ui) * 3 + 2]);
         }
      }

      fprintf ( stderr, "   Knots:\n");
      for (index = 0; index < curve->num_knots; index++)
      {
         fprintf ( stderr, "   %18.16lf\n", curve->knots[index]);
      }
   }
}
#endif

/*-----read_bsp_curve---------------------------------------------------------*/

static void   read_bsp_curve( struct IGRbsp_curve **curve_parameter )

/*
 * ABSTRACT: Read_bsp_curve reads the coded definition of an IGRbsp_curve out of
 *           the display list and builds the given curve accordingly.  It is
 *           assumed  that the curve structure has NOT been malloced and that
 *           the display list points to the beginning of the curve definition.
 *
 * HISTORY:   07/23/88   Created.         C. M. Jablonski
 */

{
   WLuint16              *ptr16;
   WLuint16              flags;
   IGRint                index;
   IGRlong               rc;
   struct IGRbsp_curve   *curve;


   if (curve = (struct IGRbsp_curve *)malloc(sizeof(struct IGRbsp_curve)))
   {
      ptr16 = (uint16 *)ncv_display_list++;

      curve->order = *ptr16++;
      flags = *ptr16++;
      curve->num_poles = *(int *)ptr16;


      /* Set the flags */
      curve->periodic   = flags & CV_PERIODIC_M;
      curve->non_uniform   = flags & CV_NON_UNIFORM_M;
      curve->rational   = flags & CV_RATIONAL_M;
      curve->planar   = flags & CV_PLANAR_M;
      curve->phy_closed   = flags & CV_PHY_CLOSED_M;


      /* Read the poles */
      if (curve->poles =
                 (IGRdouble *)malloc(3 * curve->num_poles * sizeof(IGRdouble)))
      {
         for ( index=0; index<3*curve->num_poles; index++ )
         {
            curve->poles[index] = *ncv_display_list++;
         }

         /* Get the knots */
         curve->num_knots = curve->order + curve->num_poles;
         if (curve->knots =
                 (IGRdouble *)malloc(curve->num_knots * sizeof(IGRdouble)))
         {
            if (curve->non_uniform)
            {
               for ( index=0; index<curve->num_knots; index++ )
               {
                  curve->knots[index] = *ncv_display_list++;
               }
            }
            else
            {  /* the curve is uniform, so generate the knot array */
               BSchrdlkts( &rc,
                           &curve->num_poles,
                           curve->poles,
                           &curve->order,
                           &curve->periodic,
                           curve->knots );

               if (rc != BSSUCC)
               {
                  fprintf(stderr,
                      "ERROR in read_bsp_curve: BSchrdlkts returned %ld.", rc);
               }
            }


            /* Get the weights */
            if (curve->rational)
            {
               if (curve->weights =
                  (IGRdouble *)malloc(3 * curve->num_poles * sizeof(IGRdouble)))
               {
                  for ( index=0; index<curve->num_poles; index++ )
                  {
                     curve->weights[index] = *ncv_display_list++;
                  }
               }
               else
               {
                  NCerror_flags.memory_fault = TRUE;    /* could not allocate */
                                                        /* weights            */
               }
            }
            else
            {
               curve->weights = NULL;
            }

            /* Define the boundaries */
            curve->num_boundaries = 0;
            curve->bdrys = NULL;

            *curve_parameter = curve;
         }
         else
         {
            NCerror_flags.memory_fault = TRUE;   /* could not allocate knots */
         }
      }
      else
      {
         NCerror_flags.memory_fault = TRUE;      /* could not allocate poles */
      }
   }
   else
   {
      NCerror_flags.memory_fault = TRUE;         /* could not allocate curve */
   }
}


/*-----NCset_tool-------------------------------------------------------------*/

static IGRint NCset_tool(void)

/*
 * ABSTRACT: NCset_tool performs the set_tool command.  It reads the tool data,
 *           updates the current color, lineweight and linestyle and changes the
 *           active tool.
 *
 * HISTORY: 07/20/88   Created.                     C. M. Jablonski
 *          10/24/88   post tool color              K. M. Jehng
 *          11/02/89   Pull off tool translucency   M. R. Giesy
 */

{
   uint8     *ptr8;
   int16     *ptr16;
   uint32    *ptr32;
   uint32    rgb;
   real32    *fptr32;
   real32    concav_parm;

   /*
    * Read in display data.
    */
   ptr8 = (uint8 *)ncv_display_list; ptr8 += 2;

   /* grab the translucency flag */
   ptr16 = (int16 *) ptr8;
   ncv_original_tool_trans = *ptr16;
   ptr8 += 2;

   fptr32 = (real32 *)ptr8;
   concav_parm = *fptr32;
   fptr32++;

   ptr32 = (uint32 *)fptr32;
   rgb = *ptr32;
   ptr32++;

   ptr16 = (int16 *)ptr32;
   ncv_original_tool_color = *ptr16;
   ptr16++;

   ptr8 = (uint8 *)ptr16;
   NCshading.lineweight = *ptr8++;
   NCshading.linestyle  = *ptr8++;

#if DEBUG
   fprintf( stderr,"   tool translucency = %d\n   concav_parm = %f\n",
                       ncv_original_tool_trans, concav_parm );
   fprintf( stderr,"   rgb = %d\n   tool color = %d\nline weight = %d\n",
                   rgb, ncv_original_tool_color, NCshading.lineweight );
   fprintf( stderr, "   line style = %d\n",  NCshading.linestyle);
#endif

   ncv_display_list += 2;

   /*
    * Update color
    */

   if (NCsim_data.active_tool_color == HSNC_USE_TOOL_COLOR)
   {
      /* we need to set tool color */
      HSset_dexel_color( TRUE,
                         ncv_original_tool_color,
                         &(NCshading.active_color));

      /* After every time NCshading.active_color is changed set red, green, */
      /* and blue                                                           */
      NCget_rgb_from_logical_color( NCshading.active_color,
                                    &(NCshading.active_red),
                                    &(NCshading.active_green),
                                    &(NCshading.active_blue));

      NCsim_data.active_tool_color = NCshading.active_color;
   }
   else   /* we use user defined tool color */
   {
      NCshading.active_color = NCsim_data.active_tool_color;

      /* After every time NCshading.active_color is changed set red, green, */
      /* and blue                                                           */
      NCget_rgb_from_logical_color( NCshading.active_color,
                                    &(NCshading.active_red),
                                    &(NCshading.active_green),
                                    &(NCshading.active_blue));

   }
   if (ncv_prev_toolpath_color == HSNC_USE_TOOL_COLOR)
   {
      ncv_prev_toolpath_color = ncv_original_tool_color;
   }

   if (!ncv_using_toolpath_trans)
   {
      NCsim_data.active_tool_trans = ncv_original_tool_trans;
   }

   /*
    * Cleanup previous tool curve data.
    */

   if (ncv_tool_curve)
   {
      if (ncv_tool_curve->poles)
      {
         free( ncv_tool_curve->poles );
         ncv_tool_curve->poles = NULL;
      }

      if (ncv_tool_curve->knots)
      {
         free( ncv_tool_curve->knots );
         ncv_tool_curve->knots = NULL;
      }

      if (ncv_tool_curve->weights)
      {
         free( ncv_tool_curve->weights );
         ncv_tool_curve->weights = NULL;
      }

      free( ncv_tool_curve );
      ncv_tool_curve = NULL;
   }


   /*
    * Read in tool curve.
    */

   read_bsp_curve( &ncv_tool_curve );

#if SHOW_DISPLAY_LIST
   fprintf(stderr, "   TOOL CURVE:\n");
   print_curve( ncv_tool_curve, 0 );
#endif


   /*
    * Change the active tool.
    */

   if (!NCerror_flags.memory_fault)
   {
      NCchange_active_tool( ncv_tool_curve );
   }

   /*
    * If a toolpath exists and this is simulation, update simulation buffer.
    */

   if ((!NCerror_flags.memory_fault) &&
       (!ncv_first_toolpath) &&
       (NCsim_data.simulation_mode))
   {
      NCupdate_sim_buffer(TRUE);
   }

   ncv_tool_exists = TRUE;
   ncv_new_tool = TRUE;

   return ( (NCerror_flags.memory_fault) ? (SNC_BIGTOOL) : (SNC_OK) );
}


/*-----NCset_tool_orientation-----------------------------------------------------*/

static IGRint NCset_tool_orientation(void)


/*
 * ABSTRACT:   NCset_tool_orientation changes the orientation of the tool.
 *             It reads the new orientation from the display list, changes
 *             the orientation parameters, and updates the tool data.
 *
 * HISTORY:   07/21/88   Created.         C. M. Jablonski
 */

{
   IGRint      index;
   IGRdouble   ncv_rotation[3][3];


   /*
    * Read in new rotation matrix.
    */

   ncv_display_list++;

   /* read in the x-coefficients */
   for( index=0; index<3; index++ )
   {
      ncv_rotation[index][0] = *ncv_display_list++;
   }

   /* read in the y-coefficients */
   for( index=0; index<3; index++ )
   {
      ncv_rotation[index][1] = *ncv_display_list++;
   }

   /* read in the z-coefficients */
   for( index=0; index<3; index++ )
   {
      ncv_rotation[index][2] = *ncv_display_list++;
   }

#if DEBUG
   fprintf(stderr, "   orientation matrix:\n");
   fprintf(stderr, "      %f %f %f\n",
               ncv_rotation[0][0], ncv_rotation[0][1], ncv_rotation[0][2]);
   fprintf(stderr, "      %f %f %f\n",
               ncv_rotation[1][0], ncv_rotation[1][1], ncv_rotation[1][2]);
   fprintf(stderr, "      %f %f %f\n",
               ncv_rotation[2][0], ncv_rotation[2][1], ncv_rotation[2][2]);
#endif

   /* Update orientation parameters */
   NCchange_orientation( ncv_rotation );

   /* If a tool exists, it needs to be rotated to the new orientation */
   if (ncv_tool_exists)
   {
      NCinit_tool_vars();
      if ((NCsim_data.simulation_mode) && (!ncv_first_toolpath))
      {
         NCupdate_sim_buffer(TRUE);
      }
   }

   return ( (NCerror_flags.memory_fault) ? (SNC_BIGTOOL) : (SNC_OK) );
}


/*-----NCset_tax_sub_toolpath-----------------------------------------------------*/

static IGRint NCset_tax_sub_toolpath(void)


/*
 * ABSTRACT:   NCset_tax_sub_toolpath defines the next THREE-AXIS sub-toolpath.
 *             It reads in the sub-toolpath and updates local toolpath data.
 *
 * HISTORY: 07/21/88   Created.                      C. M. Jablonski
 *          10/17/88   Added color, rgb, speed       K. M. Jehng
 *          11/03/89   Pull off tool translucency    M. R. Giesy
 */

{
   struct IGRbsp_curve   *curve;
   WLuint8               *ptr8;
   WLint16               *ptr16;
   WLint16               speed;
   WLint16               color;
   WLint16               trans_flag;
   WLuint32              *ptr32;
   WLuint32              rgb;
   IGRboolean            was_five_axis;
   int                   using_ptc = TRUE;
   int                   enter_if;         /* a variable to determine if code */
                                           /* for an if statement should      */
                                           /* execute - needed due to a       */
                                           /* different number of qualifying  */
                                           /* statements                      */

   if( IGEget_using_ramp_mode())
   {
      using_ptc = FALSE;
   }

   /*
    * Read in the sub-toolpath.
    */

   ptr8 = (WLuint8 *)ncv_display_list;
   ptr8 += 2;

   ptr16 = (WLint16 *)ptr8;
   color = *ptr16;
   ptr16++;

   /* update active tool color, if necessary               */
   if (color == HSNC_USE_TOOL_COLOR)
   {
      color = ncv_original_tool_color;
   }

   if (color != ncv_prev_toolpath_color)
   {
      NCupdate_tool_color(color);
   }

   if( using_ptc )
   {
      ncv_prev_toolpath_color = color;
   }

   ptr32 = (WLuint32 *)ptr16;
   rgb = *ptr32; ptr32++;

   ptr16 = (WLint16 *)ptr32;
   speed = *ptr16;

   if (NCsim_data.simulation_mode && !ncv_use_new_interactive_speed)
   {
      if (speed == HSNC_USE_GLOBAL_SPEED)
      {
         speed = ncv_global_speed;
      }

      if (speed != NCsim_data.simulation_speed)
      {
         if (!ncv_first_toolpath)
         {
            NCupdate_sim_speed(speed);
         }
         else
         {
            NCsim_data.simulation_speed = speed;
         }
         ncv_use_toolpath_speed = TRUE;
      }
   }

   /* grab the toolpath translucency flag */
   ptr16++;
   trans_flag = *ptr16;

   if (trans_flag == HSNC_USE_TOOL_TRANS)
   {
      ncv_using_toolpath_trans = FALSE;
   }
   else
   {
      ncv_using_toolpath_trans = TRUE;
   }

   if (ncv_using_toolpath_trans)
   {
      NCsim_data.active_tool_trans = trans_flag;
   }
   else
   {
      NCsim_data.active_tool_trans = ncv_original_tool_trans;
   }

   ncv_display_list += 2;

#if DEBUG
   fprintf(stderr, "   color = %d\n   rgb = %d\n   speed = %d\n",
                   color, rgb, speed );
   fprintf(stderr, "   translucency = %d\n", trans_flag);
#endif

   /*
    * Read in toolpath curve.
    */

   read_bsp_curve( &curve );

#if SHOW_DISPLAY_LIST
   fprintf(stderr, "   TOOLPATH CURVE:\n");
   print_curve( curve, 0 );
#endif


   /*
    * Update toolpath data structures.
    */

   was_five_axis = NCtoolpath_data.five_axis;
   if (!NCerror_flags.memory_fault)
   {
      NCset_tax_toolpath( curve );
   }

   /*
    * If this is the first toolpath, initialize the location.
    */

   if( using_ptc)
   {
      if( (!NCerror_flags.memory_fault) &&
          ((ncv_first_toolpath) || (was_five_axis) ||
          (ncv_prev_toolpath_color!=NCshading.active_color)))
      {
         enter_if = TRUE;
      }
      else
      {
         enter_if = FALSE;
      }
   }
   else
   {
      if( (!NCerror_flags.memory_fault) &&
                  ((ncv_first_toolpath) || (was_five_axis)))
      {
         enter_if = TRUE;
      }
      else
      {
         enter_if = FALSE;
      }
   }

   if ( enter_if )
   {
      NCinit_toolpath_position(curve->poles, NULL);

      /* if a tool has been defined, it needs to be moved to the new location */
      if (ncv_tool_exists)
      {
         NCinit_tool_vars();
         if (NCsim_data.simulation_mode)
         {
            NCupdate_sim_buffer(FALSE);
            if (NCerror_flags.memory_fault)
            {
               return (SNC_BIGTOOL);
            }
         }
      }
      ncv_first_toolpath = FALSE;
   }

   if( using_ptc)
   {
      ncv_prev_toolpath_color = color;
   }
   
   /*
    * Cleanup local data.
    */

   if (curve)
   {
      if (curve->poles)
      {
         free( curve->poles );
         curve->poles = NULL;
      }

      if (curve->knots)
      {
         free( curve->knots );
         curve->knots = NULL;
      }

      if (curve->weights)
      {
         free( curve->weights );
         curve->weights = NULL;
      }

      free( curve );
      curve = NULL;
   }

   return ( (NCerror_flags.memory_fault) ? (SNC_NOMEM) : (SNC_OK) );
}


/*-----NCset_fax_sub_toolpath-------------------------------------------------*/

static IGRint NCset_fax_sub_toolpath(void)

/*
 * ABSTRACT:   NCset_fax_sub_toolpath defines the next FIVE-AXIS sub-toolpath.
 *             It reads in the sub-toolpath and updates local toolpath data.
 *
 * HISTORY:  08/15/89   Created.                      C. M. Jablonski
 *           11/03/89   Pull off tool translucency    M. R. Giesy
 */

{
   WLuint8      *ptr8;
   WLint16      *ptr16;
   WLint16      speed;
   WLint16      color;
   WLint16      trans_flag;
   WLint16      num_points;
   WLuint32     *ptr32;
   WLuint32     rgb;
   IGRpoint     *vert_array;
   IGRpoint     *norm_array = NULL;
   IGRint       index;
   IGRdouble    length;


   /*
    * Read in the sub-toolpath.
    */

   ptr8 = (WLuint8 *)ncv_display_list;
   ptr8 += 2;

   ptr16 = (WLint16 *) ptr8;
   color = *ptr16; ptr16++;

   /* update active tool color, if necessary */
   if (color == HSNC_USE_TOOL_COLOR)
   {
      color = ncv_original_tool_color;
   }

   if (color != ncv_prev_toolpath_color)
   {
      NCupdate_tool_color(color);
   }
   ncv_prev_toolpath_color = color;

   ptr32 = (WLuint32 *) ptr16;
   rgb = *ptr32; ptr32++;

   ptr16 = (WLint16 *)ptr32;
   speed = *ptr16; ptr16++;

   if (NCsim_data.simulation_mode && !ncv_use_new_interactive_speed)
   {
      if (speed == HSNC_USE_GLOBAL_SPEED)
      {
         speed = ncv_global_speed;
      }

      if (speed != NCsim_data.simulation_speed)
      {
         if (!ncv_first_toolpath)
         {
            NCupdate_sim_speed(speed);
         }
         else
         {
            NCsim_data.simulation_speed = speed;
         }
         ncv_use_toolpath_speed = TRUE;
      }
   }

   /* grab the toolpath translucency flag */
   trans_flag = *ptr16;
   if (trans_flag == HSNC_USE_TOOL_TRANS)
   {
      ncv_using_toolpath_trans = FALSE;
   }
   else
   {
      ncv_using_toolpath_trans = TRUE;
   }

   if (ncv_using_toolpath_trans)
   {
      NCsim_data.active_tool_trans = trans_flag;
   }
   else
   {
      NCsim_data.active_tool_trans = ncv_original_tool_trans;
   }

#if DEBUG
   fprintf( stderr, "   color = %d\n   rgb = %d\n   speed = %d\n",
                       color, rgb, speed );
   fprintf( stderr, "   translucency = %d\n", trans_flag);
#endif

   /*
    * Read in toolpath arrays.  NOTE: these arrays will be freed by
    * NCcleanup_toolpath.
    */

   ptr16++;
   num_points = *ptr16;
   ncv_display_list += 2;

   if (!(vert_array = (IGRpoint *)malloc(num_points * sizeof(IGRpoint))) ||
       !(norm_array = (IGRpoint *)malloc(num_points * sizeof(IGRpoint))))
   {
      NCerror_flags.memory_fault = TRUE;
   }
   else
   {
      for (index = 0; index < num_points; index++)
      {
         vert_array[index][0] = *ncv_display_list++;
         vert_array[index][1] = *ncv_display_list++;
         vert_array[index][2] = *ncv_display_list++;
         norm_array[index][0] = *ncv_display_list++;
         norm_array[index][1] = *ncv_display_list++;
         norm_array[index][2] = *ncv_display_list++;
         NORMALIZE( norm_array[index] );
      }
   }


#if SHOW_DISPLAY_LIST
   fprintf(stderr, "   num points = %d\n", num_points);
   fprintf(stderr, "   VERTEX ARRAY:\n");
   for (index = 0; index < num_points; index++)
   {
      fprintf(stderr, "      vert_array[%d] = %f %f %f\n",
                     index, vert_array[index][0], vert_array[index][1],
                     vert_array[index][2]);
   }
   fprintf(stderr, "   NORMAL ARRAY:\n");
   for (index = 0; index < num_points; index++)
   {
      fprintf(stderr, "      norm_array[%d] = %f %f %f\n",
                     index, norm_array[index][0], norm_array[index][1],
                     norm_array[index][2]);
   }
#endif

   /*
    * Update toolpath data structures.
    */

   if (!NCerror_flags.memory_fault)
   {
      NCset_fax_toolpath( num_points,
                          (IGRdouble *)vert_array,
                          (IGRdouble *)norm_array );
   }

   /*
    * If this is the first toolpath, initialize the location.
    */

   if ((!NCerror_flags.memory_fault) && (ncv_first_toolpath))
   {
      NCinit_toolpath_position(vert_array[0], norm_array[0]);

      /* if a tool has been defined, its location and orientation need to be */
      /* updated                                                             */
      if (ncv_tool_exists)
      {
         NCinit_tool_vars();
         if (NCsim_data.simulation_mode)
         {
            NCupdate_sim_buffer(FALSE);
            if (NCerror_flags.memory_fault) return (SNC_BIGTOOL);
         }
      }
      ncv_first_toolpath = FALSE;
   }
   return ( (NCerror_flags.memory_fault) ? (SNC_NOMEM) : (SNC_OK) );
}


/*-----ShadedNC---------------------------------------------------------------*/

int ShadedNC( IGRint                     entry_point,
              struct HSNC_mode_parms     mode_parms,
              IGRdouble                  *disp_list,
              struct HSNC_return_parms   *return_parms )

/*
 * ABSTRACT:  This function acts as the driver for the Shaded NC milling
 *            command.  It contains three entry points: init, execute and 
 *            cleanup.  The init point initializes all data structures.  The
 *            execute point executes the next tool step, and the cleanup point
 *            cleans up all local data structures.
 *
 * RETURN:   int   - status flag.
 *
 * HISTORY: 07/01/88 Created.                            C. M. Jablonski
 *          08/20/88 output current tool, rot, loc       K. M. Jehng
 *          09/27/88 added hide/show cursors             K. M. Jehng
 *          10/26/88 added SNC_CHGMODES                  K. M. Jehng
 *          08/11/89 HSNC_mode_parms, HSNC_return_parms  C. M. Jablonski
 */


{
   IGRint       i;
   IGRint       j;
   IGRint       status = SNC_OK;   /* the status flag */
   IGRboolean   finished_step = FALSE;
   IGRboolean   finished_init = FALSE;
   IGRboolean   initializing = FALSE;
   WLuint8      *command;
   IGRboolean   new_interactive_speed;


   switch (entry_point)
   {
      case SNC_CHGMODE:
      case SNC_CHGMODES:

         /* update those mode flags that are allowed to change during */
         /* execution                                                 */
         new_interactive_speed = (entry_point == SNC_CHGMODES) ? TRUE : FALSE;
         status = NCchange_mode( new_interactive_speed, mode_parms );
         break;

      case (SNC_INIT) :

#if NC_TIMING
         NCinit_timing();
#endif
         /* initialize local data structures */
         initializing = TRUE;
         ncv_command_count = 0;
         ncv_display_list = disp_list;

         ncv_tool_curve = NULL;

         /* initialize mode flags, global variables, dexel buffers and */
         /* display                                                    */
         status = NCinit( mode_parms );

         /* break on error only */
         if (status != SNC_OK)
         {
            break;
         }

         /* execute display list commands until tool and toolpath are defined */
         /* NOTE: NO BREAK */


      case (SNC_EXECUTE) :
         finished_step = FALSE;
         WLhide_cursor( NCwindow.win_no, 0 );
         do{
            if ( (ncv_tool_exists) && (!NCtoolpath_data.end_of_toolpath) )
            {
               /* Execute the next tool step. */
               if (initializing)
               {
                  finished_init = TRUE;
                  if (NCsim_data.simulation_mode)
                  {
                     NCdisplay_sim_tool();   /* display tool   */
                  }
               }
               else
               {
                  status = NCdo_step ();
                  finished_step = TRUE;
               }
            }
            else
            { /* Get the next command */
               command = (WLuint8 *)ncv_display_list;

               if (command[1]!=NC_TOOLPATH_COMMAND)
               { /* Bad command in display list */
#if DEBUG
                  fprintf(stderr,
                    "\nCOMMAND[%d]: DISPLAY LIST ERROR: bad command: (%d,%d)\n",
                                   ncv_command_count, command[0], command[1]);
#endif
                  status = SNC_DLERR;
               }
               else
               {
                  switch (command[0])
                  {
                     case (NC_SET_TOOL):
                     case (NC_SET_TOOLHOLDER):
#if DEBUG
                        fprintf(stderr, "\nCOMMAND[%d]: SET TOOL\n",
                                     ncv_command_count++, command[0]);
#endif
                        status = NCset_tool();
                        break;

                     case (NC_SET_TOOL_ORIENTATION):
#if DEBUG
                        fprintf(stderr, "\nCOMMAND[%d]: SET TOOL ORIENTATION\n",
                                         ncv_command_count++, command[0]);
#endif
                        status = NCset_tool_orientation();
                        break;

                     case (NC_SET_3AX_SUB_TOOLPATH):
                     case (NC_SET_ARC_SUB_TOOLPATH):
#if DEBUG
                        fprintf(stderr,
                                "\nCOMMAND[%d]: SET 3-AXIS SUB-TOOLPATH\n",
                                ncv_command_count++, command[0]);
#endif
                        status = NCset_tax_sub_toolpath();
                        break;

                     case (NC_SET_5AX_SUB_TOOLPATH):
#if DEBUG
                        fprintf(stderr,
                                "\nCOMMAND[%d]: SET 5-AXIS SUB-TOOLPATH\n",
                                ncv_command_count++, command[0]);
#endif
                        status = NCset_fax_sub_toolpath();
                        break;

                     case (NC_END_TOOLPATH):
#if DEBUG
                        fprintf(stderr, "\nCOMMAND[%d]: END TOOLPATH\n",
                                ncv_command_count++, command[0]);
#endif
                        status = SNC_FINISHED;
                        break;

                     default:
                        /* Bad command in display list */
#if DEBUG
                        fprintf(stderr, "\nCOMMAND[%d]: DISPLAY LIST ERROR:" );
                        fprintf(stderr, " bad command: (%d,%d)\n",
                                ncv_command_count, command[0], command[1]);
#endif
                        status = SNC_DLERR;
                        break;
                  }
               }
            }
         }
         while ( (status==SNC_OK) && !(ncv_single_step && finished_step) && 
                  !(IGEstop()) && (!finished_init) );

         WLshow_cursor( NCwindow.win_no );
         WLflush( NCwindow.win_no );

         if (ncv_wireframe)
         {   /* setup the return parameters necessary for wireframe display */
            if (ncv_new_tool)
            {
               return_parms->tool = ncv_tool_curve;   /* new tool */
               ncv_new_tool = FALSE;
            }
            else
            {
                return_parms->tool = NULL;         /* the same tool */
            }

            for (i=0; i<3;i++)
            {
                return_parms->location[i] = NCtoolpath_data.curr_location[i];

                /* We transpose the rotation matrix because NC Verification
                 * uses post-multiplies while the rest of the world uses
                 * pre-multiplies:
                 *
                 *     NC Verification:           Everyone Else:
                 *     (x[0] x[1] x[2])           (x[0] y[0] z[0])
                 *     (y[0] y[1] y[2])           (x[1] y[1] z[1])
                 *     (z[0] z[1] z[2])           (x[2] y[2] z[2])
                 */

               for (j=0; j<3; j++)
               {
                  /* output to NCdistp */
                  return_parms->rotation[i][j] = NCtool_orient.rotation[j][i];
               }
            }

#if DEBUG
            fprintf(stderr,
                    "in shadedNC, return_parms->rotation=\n%lf,%lf,%lf\n%lf,",
                     return_parms->rotation[0][0],
                     return_parms->rotation[0][1],
                     return_parms->rotation[0][2],
                     return_parms->rotation[1][0] );
            fprintf(stderr, " %lf,%lf\n%lf,%lf,%lf\n,",
                     return_parms->rotation[1][1],
                     return_parms->rotation[1][2],
                     return_parms->rotation[2][0],
                     return_parms->rotation[2][1],
                     return_parms->rotation[2][2] );
            fprintf(stderr, " return_parms->location=(%lf,%lf,%lf)\n",
                     return_parms->location[0],
                     return_parms->location[1],
                     return_parms->location[2]);
#endif
         }
         break;

      case (SNC_CLEANUP) :
         NCcleanup();
#if NC_TIMING
         NCreport_timing();
#endif
         break;

      default :
         fprintf(stderr, "ShadedNC called with unknown flag ... %d\n",
                 entry_point);
         status = SNC_ERROR;
         break;
   }

   return ( status );
}
