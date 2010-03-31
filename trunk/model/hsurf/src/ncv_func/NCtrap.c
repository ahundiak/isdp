
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "wl.h"

#include "dpgraphics.h"
#include "hnmilling.h"
#include "hnerror.h"
#include "hntiming.h"
#include "hsdisplay.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hstiler.h"
#include "hnmill.h"
#include "HSsara.h"

#include "HSpr_ncv_fun.h"
#include "HSpr_co_func.h"

#define DEBUG_TRAP   FALSE


/**********************
 * EXTERNAL VARIABLES *
 **********************/

extern struct NC_error_flags    NCerror_flags;
extern struct NC_shading_parms  NCshading;
extern struct NC_window_parms   NCwindow;


/*******************
 * LOCAL VARIABLES *
 *******************/

static struct trapnode
{
   struct trapezoid   trap;
   IGRint             color;
   IGRint             facet_type;
   struct trapnode    *next;
} *front_traplist = NULL, *back_traplist = NULL;


/*-----NCcleanup_trap---------------------------------------------------------*/

NCcleanup_trap(void)

/*
 * ABSTRACT:   NCcleanup_trap deallocates the trapezoid lists.
 *
 * HISTORY:   09/18/89   Created.         C. M. Jablonski
 *
 */

{
   struct trapnode  *local_trap;
   struct trapnode  *next_trap;


   for ( local_trap = back_traplist;
         local_trap != NULL;
         local_trap = next_trap )
   {
      next_trap = local_trap->next;
      free(local_trap);
   }

   for ( local_trap = front_traplist;
         local_trap != NULL;
         local_trap = next_trap )
   {
      next_trap = local_trap->next;
      free(local_trap);
   }

   front_traplist = NULL;
   back_traplist = NULL;
}


/*-----NCsave_trap------------------------------------------------------------*/

NCsave_trap( struct trapezoid *trap )

/*
 * ABSTRACT:  NCsave_trap adds the given trapezoid to the current trapezoid
 *            list.
 *
 * HISTORY:   08/19/88   Created.         C. M. Jablonski
 *
 */

{
   struct trapnode  *local_trap;
   IGRboolean       front_facing;

   /*
    * Adjust the x,y values of the trapezoid to fit the dexel array.
    * NOTE: if this is an environment object, the dorg values will be 0.
    */

   trap->x0 -= NCwindow.dorg_x;
   trap->x1 -= NCwindow.dorg_x;
   trap->x2 -= NCwindow.dorg_x;
   trap->x3 -= NCwindow.dorg_x;
   trap->ya -= NCwindow.dorg_y;
   trap->yb -= NCwindow.dorg_y;


   /*
    * Perform min/max test on the x and y coordinates of the trapezoid.
    */

   if (trap->x0 < NCwindow.x_min)
   {
      NCwindow.x_min = trap->x0;
   }

   if (trap->x1 > NCwindow.x_max)
   {
      NCwindow.x_max = trap->x1;
   }

   if (trap->x2 < NCwindow.x_min)
   {
      NCwindow.x_min = trap->x2;
   }

   if (trap->x3 > NCwindow.x_max)
   {
      NCwindow.x_max = trap->x3;
   }

   if (trap->yb < NCwindow.y_min)
   {
      NCwindow.y_min = trap->yb;
   }

   if (trap->ya > NCwindow.y_max)
   {
      NCwindow.y_max = trap->ya;
   }


   /*
    * Add the trapezoid to the list.
    */

   if (local_trap = (struct trapnode *)(malloc(sizeof(struct trapnode))))
   {
      local_trap->trap.id = trap->id;
      local_trap->trap.ya = trap->ya;
      local_trap->trap.yb = trap->yb;
      local_trap->trap.x0 = trap->x0;
      local_trap->trap.x1 = trap->x1;
      local_trap->trap.x2 = trap->x2;
      local_trap->trap.x3 = trap->x3;
      local_trap->trap.z0 = trap->z0;
      local_trap->trap.z1 = trap->z1;
      local_trap->trap.z2 = trap->z2;
      local_trap->trap.z3 = trap->z3;

      local_trap->trap.shade0 = trap->shade0;
      local_trap->trap.shade1 = trap->shade1;
      local_trap->trap.shade2 = trap->shade2;
      local_trap->trap.shade3 = trap->shade3;

      HSget_dexel_facet_parms( &local_trap->color,
                               &local_trap->facet_type,
                               &front_facing );

      if (front_facing)
      {
         local_trap->next = front_traplist;
         front_traplist = local_trap;
      }
      else
      {
         local_trap->next = back_traplist;
         back_traplist = local_trap;
      }
   }
   else
   {
      NCerror_flags.memory_fault = TRUE;      /* could not allocate trapezoid */
   }
}


/*-----NCdexelize_workpiece---------------------------------------------------*/

NCdexelize_workpiece(void)

/*
 * ABSTRACT:   NCdexelize_workpiece sends the workpiece trapezoids to the
 *             dexelizer in order to initialize the workpiece dexel array.
 *
 * HISTORY:   07/25/88   Created.         C. M. Jablonski
 *
 */

{
   struct trapnode  *trap;
   struct trapnode  *next_trap;
   int              using_ptc = TRUE;


   if( IGEget_using_ramp_mode() )
   {
      using_ptc = FALSE;
   }

   NCshading.active_color = 1000;

   for ( trap = front_traplist; trap != NULL; trap = next_trap )
   {
      if (NCshading.active_color != trap->color)
      {
         NCshading.active_color = trap->color;

          
         /* After every time NCshading.active_color is changed set red, */
         /* green, and blue                                             */
         if(using_ptc)
         {
            NCget_rgb_from_logical_color(NCshading.active_color,
                                         &(NCshading.active_red),
                                         &(NCshading.active_green),
                                         &(NCshading.active_blue));

            /* the rasterizers are using the element_parms variables */
            HSset_element_color( NCshading.active_color );
         }
      }

      if (!NCerror_flags.memory_fault)
      {
         if( using_ptc )
         {
            if (trap->facet_type == NCshading.SMOOTH_SHADING)
            {
               NCupdate_smooth_dm_block_front_dexels( &(trap->trap) );
            }
            else
            {
               NCupdate_const_dm_block_front_dexels( &(trap->trap) );
            }
         }
         else
         {
            if (trap->facet_type == NCshading.SMOOTH_SHADING)
            {
               if (NCshading.direct)
               {
                  NCupdate_smooth_dm_block_front_dexels( &(trap->trap) );
               }

               else
               {
                  NCupdate_smooth_ht_block_front_dexels( &(trap->trap) );
               }
            }
            else
            {
               if (NCshading.direct)
               {
                  NCupdate_const_dm_block_front_dexels( &(trap->trap) );
               }
               else
               {
                  NCupdate_const_ht_block_front_dexels( &(trap->trap) );
               }
            }
         }
      }
      next_trap = trap->next;
      free(trap);
   }

   for ( trap = back_traplist; trap != NULL; trap = next_trap )
   {
      NCupdate_block_back_dexels( &(trap->trap) );
      next_trap = trap->next;
      free(trap);
   }

   NCwindow.x_min = 0;
   NCwindow.y_min = 0;
   NCwindow.x_max = (NCwindow.dx_dits - 1) << 16;
   NCwindow.y_max = NCwindow.dy_dits - 1;

   WLhide_cursor( NCwindow.win_no, 0 );

   if (!NCerror_flags.memory_fault)
   {
      NCpaint();
   }

   WLshow_cursor( NCwindow.win_no );
   WLflush( NCwindow.win_no );

   front_traplist = NULL;
   back_traplist = NULL;
}


/*-----NCdexelize_swvol-------------------------------------------------------*/

NCdexelize_swvol(void)

/*
 * ABSTRACT:   NCdexelize_swvol sends the swept volume trapezoids to the
 *             dexelizer which will update the dexel array.
 *
 * HISTORY:   07/25/88   Created.                     C. M. Jablonski
 *            09/27/88   Took hide/show cursors out   K. M. Jehng
 *
 */

{
   struct trapnode  *trap;
   struct trapnode  *next_trap;

   register int     x;
   register int     y;
   IGRint           x_min;
   IGRint           x_diff;
   NCzbuf           *tzb;
   register NCzbuf  *zb;
   register NCzbuf  *zb2;
   IGRint           using_ptc = TRUE;


   if( IGEget_using_ramp_mode() )
   {
      using_ptc = FALSE;
   }

   START_NC_TIMING(NCtd_DEX_SWVOL)

   if ((front_traplist) || (back_traplist))
   {
      /*
       * Reset the near-z buffer.
       */

      x_min = NCwindow.x_min >> 16;
      x_diff = (NCwindow.x_max >> 16) - x_min + 1;

      if (x_min & 0x00000001)
      {
         x_min--;
         x_diff++;
      }

      if ((x_min + x_diff) < NCwindow.dx_dits)
      {
         x_diff++;
      }

#if DEBUG
{
      fprintf(stderr,"x_dits = %d, y_dits = %d\n",
                      NCwindow.dx_dits,
                      NCwindow.dy_dits);
      fprintf(stderr,"x_min = %d, x_max = %d, x_diff = %d, x_min+x_diff = %d\n",
                      x_min,
                      (NCwindow.x_max >> 16),
                      x_diff,
                      x_min+x_diff);
      fprintf(stderr,"y_min = %d, y_max = %d\n",
                      NCwindow.y_min,
                      NCwindow.y_max);
}
#endif

      zb =  (NCzbuf *) NCwindow.zbuf + (NCwindow.dx_dits * NCwindow.y_min) +
             x_min;
      tzb = (NCzbuf *) NCwindow.zbuf + (NCwindow.dx_dits * NCwindow.y_min) +
             x_min;
      zb2 = (NCzbuf *) NCwindow.zbuf2 + (NCwindow.dx_dits * NCwindow.y_min) +
             x_min;

      for( x = 0; x < x_diff; x++ )
      {
         *zb = *zb2 = NCbackground_z;
         zb++;
         zb2++;
      }

      zb = (NCzbuf *) NCwindow.zbuf + (NCwindow.dx_dits *
                                                (NCwindow.y_min + 1)) + x_min;
      zb2 = (NCzbuf *) NCwindow.zbuf2 + (NCwindow.dx_dits *
                                                (NCwindow.y_min + 1)) + x_min;

      for( y = (NCwindow.y_min + 1); y <= NCwindow.y_max; y++ )
      {
         memcpy( zb, tzb, sizeof( NCzbuf ) * x_diff );
         memcpy( zb2, tzb, sizeof( NCzbuf ) * x_diff );
         zb += NCwindow.dx_dits;
         zb2 += NCwindow.dx_dits;
      }

      /*
       *  Reset ymin/ymax
       */

      NCwindow.y_min = 0x7fffffff;
      NCwindow.y_max = 0x80000000;


      /*
       * Process the front-facing trapezoids and fill the near-z buffer.
       */

      for ( trap = front_traplist; trap != NULL; trap = next_trap )
      {

#if DEBUG_TRAP
{
         fprintf(stderr,"x0=%d, x1=%d, x2=%d, x3=%d\n",
                         trap->trap.x0,
                         trap->trap.x1,
                         trap->trap.x2,
                         trap->trap.x3);
         fprintf(stderr, "ya=%d, yb=%d\n", trap->trap.ya, trap->trap.yb);
}
#endif

         NCupdate_swvol_front_dexels( &(trap->trap) );
         next_trap = trap->next;
         free(trap);
      }


      /*
       * Process the back-facing trapezoids and subtract the composite dexels.
       */

      for ( trap = back_traplist; trap != NULL; trap = next_trap )
      {

#if DEBUG_TRAP
{
          fprintf(stderr, "TYPE=%d\n", trap->facet_type);
          fprintf(stderr, "x0=%d, x1=%d, x2=%d, x3=%d\n",
                           trap->trap.x0,
                           trap->trap.x1,
                           trap->trap.x2,
                           trap->trap.x3);
          fprintf(stderr, "s0=%d, s1=%d, s2=%d, s3=%d\n",
                           trap->trap.shade0,
                           trap->trap.shade1,
                           trap->trap.shade2,
                           trap->trap.shade3);
          fprintf(stderr, "ya=%d, yb=%d\n", trap->trap.ya, trap->trap.yb);
}
#endif

         if (!NCerror_flags.memory_fault)
         {
            NCshading.active_color = trap->color;

            if(using_ptc)
            {
               /* After every time NCshading.active_color is changed set red, */
               /* green, and blue                                             */
               NCget_rgb_from_logical_color( NCshading.active_color,
                                             &(NCshading.active_red),
                                             &(NCshading.active_green),
                                             &(NCshading.active_blue));

               HSset_element_color( NCshading.active_color );

               if (trap->facet_type == NCshading.SMOOTH_SHADING)
               {
                  NCupdate_smooth_dm_swvol_back_dexels( &(trap->trap) );
               }
               else
               {
                  NCupdate_const_dm_swvol_back_dexels( &(trap->trap) );
               }
            }
            else
            {
               if (trap->facet_type == NCshading.SMOOTH_SHADING)
               {
                  if (NCshading.direct)
                  {
                     NCupdate_smooth_dm_swvol_back_dexels( &(trap->trap) );
                  }
                  else
                  {
                     NCupdate_smooth_ht_swvol_back_dexels( &(trap->trap) );
                  }
               }
               else
               {
                  if (NCshading.direct)
                  {
                     NCupdate_const_dm_swvol_back_dexels( &(trap->trap) );
                  }
                  else
                  {
                     NCupdate_const_ht_swvol_back_dexels( &(trap->trap) );
                  }
               }
            } /* end if(using_ptc) */
         }
            
         next_trap = trap->next;
         free(trap);
      }


      /*
       * Display the result.
       */

      if ((!NCerror_flags.memory_fault) &&
          (NCwindow.y_max > NCwindow.y_min))
      {
         NCpaint();
      }

      front_traplist = NULL;
      back_traplist = NULL;
   }

   STOP_NC_TIMING(NCtd_DEX_SWVOL)
}


/*-----NCdexelize_tool--------------------------------------------------------*/

NCdexelize_tool( )

/*
 * ABSTRACT:   NCdexelize_tool sends the tool trapezoids to the dexelizer in
 *             order to initialize the simulation buffer.
 *
 * HISTORY:   09/13/88   Created.                    C. M. Jablonski
 *            09/24/88   Seperated smooth/const ht   K. M. Jehng
 *
 */

{
   struct trapnode  *trap;
   struct trapnode  *next_trap;
   int              using_ptc = TRUE;


   if( IGEget_using_ramp_mode() )
   {
      using_ptc = FALSE;
   }   

   for ( trap = front_traplist; trap != NULL; trap = next_trap )
   {
      if (!NCerror_flags.memory_fault)
      {
         NCshading.active_color = trap->color;

         if( using_ptc )
         {
            HSset_element_color( NCshading.active_color);

            /* mode is pseudo-true-color so use direct mode only */
            if (trap->facet_type == NCshading.SMOOTH_SHADING)
            {
               NCupdate_smooth_dm_tool_front_dexels( &(trap->trap) );
            }
            else
            {
               NCupdate_const_dm_tool_front_dexels( &(trap->trap) );
            }
         }
         else
         {
            /* mode is RAMP based */
            if (trap->facet_type == NCshading.SMOOTH_SHADING)
            {
               if (NCshading.direct)
               {
                  NCupdate_smooth_dm_tool_front_dexels( &(trap->trap) );
               }
               else
               {
                  NCupdate_smooth_ht_tool_front_dexels( &(trap->trap) );
               }
            }
            else
            {
               if (NCshading.direct)
               {
                  NCupdate_const_dm_tool_front_dexels( &(trap->trap) );
               }
               else
               {
                  NCupdate_const_ht_tool_front_dexels( &(trap->trap) );
               }
            }
         }
      }

      next_trap = trap->next;
      free(trap);
   }

   for ( trap = back_traplist; trap != NULL; trap = next_trap )
   {
      if (!NCerror_flags.memory_fault)
      {
         NCshading.active_color = trap->color;

         if( using_ptc )
         {
            /* After every time NCshading.active_color is changed set red, */
            /* green, and blue                                             */

            HSset_element_color( NCshading.active_color);

            if (trap->facet_type == NCshading.SMOOTH_SHADING)
            {
               NCupdate_smooth_dm_tool_back_dexels( &(trap->trap) );
            }
            else
            {
               NCupdate_const_dm_tool_back_dexels( &(trap->trap) );
            }
         }
         else
         {
            /* mode is RAMP based */
            if (trap->facet_type == NCshading.SMOOTH_SHADING)
            {
               if (NCshading.direct)
               {
                  NCupdate_smooth_dm_tool_back_dexels( &(trap->trap) );
               }
               else
               {
                  NCupdate_smooth_ht_tool_back_dexels( &(trap->trap) );
               }
            }
            else
            {
               if (NCshading.direct)
               {
                  NCupdate_const_dm_tool_back_dexels( &(trap->trap) );
               }
               else
               {
                  NCupdate_const_ht_tool_back_dexels( &(trap->trap) );
               }
            }
         }
      }
      next_trap = trap->next;
      free(trap);
   }

   front_traplist = NULL;
   back_traplist = NULL;
}
