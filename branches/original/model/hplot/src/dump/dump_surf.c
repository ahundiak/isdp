#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "hsdef.h"
#include "HStl_window.h"
#include "HPglobal.h"
#include "HPdef.h"
#include "HPmacros.h"
#include "hpmsg.h"
#include "dump.h"


/*---dump_surface----------------------------------------------------------*/

int dump_surface ( FILE *ofp,                              /* output file pointer */
                   struct HPnurb_surface_struct *surf_ptr, /* pointer to surface struct */
                   int level,                              /* graphic level */
                   IGRdouble range[6])                     /* range or null */

   {
   int    status;  /* return code from called functions */
   int    j, j1;   /* useful counters */
   double *p_dbl;  /* pointer to double */
   char   ch;      /* a char */

   struct HPnurb_curve_struct p_curve;  /* boundary curve(s) */

   fprintf (ofp, "surface\n");
   if (level) fprintf (ofp, "  level                    : %d\n", level);

   if (range)
      {
      p_dbl = range;
      fprintf (ofp, "  range                    : \n");
      fprintf( ofp, "   " ); WriteDouble3( ofp, p_dbl ); p_dbl += 3;
      fprintf( ofp, "   " ); WriteDouble3( ofp, p_dbl ); p_dbl += 3;
      }

   fprintf (ofp, "  order                    : %d %d\n", 
      surf_ptr->surface.u_order, surf_ptr->surface.v_order);

   /* flags */

   if (surf_ptr->surface.u_periodic)    fprintf (ofp, "  u_periodic               :\n");
   if (surf_ptr->surface.v_periodic)    fprintf (ofp, "  v_periodic               :\n");
   if (surf_ptr->surface.u_non_uniform) fprintf (ofp, "  u_non_uniform            :\n");
   if (surf_ptr->surface.v_non_uniform) fprintf (ofp, "  v_non_uniform            :\n");
   if (surf_ptr->surface.rational)      fprintf (ofp, "  rational                 :\n");
   if (surf_ptr->surface.planar)        fprintf (ofp, "  planar                   :\n");
   if (surf_ptr->surface.u_phy_closed)  fprintf (ofp, "  u_phy_closed             :\n");
   if (surf_ptr->surface.v_phy_closed)  fprintf (ofp, "  v_phy_closed             :\n");
   if (surf_ptr->surface.pos_orient)    fprintf (ofp, "  pos_orient               :\n");
   if (surf_ptr->surface.on_off)        fprintf (ofp, "  on_off                   :\n");

   /* poles */

   fprintf (ofp, "  poles                    : %1d %1d\n", 
      surf_ptr->surface.u_num_poles, surf_ptr->surface.v_num_poles );

   p_dbl = surf_ptr->surface.poles;

   for (j = 0; j < surf_ptr->surface.v_num_poles; ++j)
      {
      for (j1 = 0; j1 < surf_ptr->surface.u_num_poles; ++j1)
         {
         fprintf( ofp, "   " ); WriteDouble3( ofp, p_dbl ); p_dbl += 3;
         }

      fprintf( ofp, "\n" );
      }

   /* if non-uniform, get knots (num-poles + order ) (uv) */

   if (surf_ptr->surface.u_non_uniform)
      {
      fprintf (ofp, "  u_knots                  : %d\n", surf_ptr->surface.u_num_knots );
      p_dbl = surf_ptr->surface.u_knots;

      for (j = 0; j < surf_ptr->surface.u_num_knots; ++j)
         {
         fprintf (ofp, "   " );
         WriteDouble( ofp, *p_dbl++);
         }
      }

   if (surf_ptr->surface.v_non_uniform)
      {
      fprintf (ofp, "  v_knots                  : %d\n", surf_ptr->surface.v_num_knots );
      p_dbl = surf_ptr->surface.v_knots;

      for (j = 0; j < surf_ptr->surface.v_num_knots; ++j)
         {
         fprintf (ofp, "   " );
         WriteDouble( ofp, *p_dbl++);
         }
      }

   /* if rational, get weights (num-poles ) */

   if (surf_ptr->surface.rational)
      {
      fprintf (ofp, "  weights                  : %d\n",
         surf_ptr->surface.u_num_poles * surf_ptr->surface.v_num_poles );
      p_dbl = surf_ptr->surface.weights;

      for( j=0; j<(surf_ptr->surface.u_num_poles * surf_ptr->surface.v_num_poles); j++ )
         {
         fprintf (ofp, "   " );
         WriteDouble( ofp, *p_dbl++);
         }
      }

   /* boundary curves */

   fprintf (ofp, "  boundaries               : %d\n", 
      surf_ptr->surface.num_boundaries );

   if (surf_ptr->surface.num_boundaries)
      {
      for (j = 0; j < surf_ptr->surface.num_boundaries; ++j)
         {
         p_curve.curve = surf_ptr->bdry_curves[j];
         p_curve.num_soos = 0;
         p_curve.soos = NULL;

         status = dump_curve (ofp, &p_curve, 0, 2);
         if (status) return HSplot_error;
         }
      }

   return HSplot_success;
   }
