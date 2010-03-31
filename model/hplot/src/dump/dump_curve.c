#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HPdef.h"
#include "HPglobal.h"
#include "dump.h"

/*---dump_curve------------------------------------------------------*/

int dump_curve ( FILE *ofp,                           /* output file pointer */
                 struct HPnurb_curve_struct *p_curve, /* pointer to curve definition */
                 unsigned short level,                /* graphic level number */
                 int dimension )                      /* dimension of points, 2 or 3 */

   {
   int    j;       /* useful counter */
   double *p_dbl;  /* pointer to double for processing poles */

   /* order */

   fprintf (ofp, "  order                    : %d\n", p_curve->curve.order);
   if (level) 
      fprintf (ofp, "  level                    : %d\n", level);

   /* flags */

   if (p_curve->curve.periodic ||
       p_curve->curve.non_uniform ||
       p_curve->curve.rational ||
       p_curve->curve.planar ||
       p_curve->curve.phy_closed)
      {
      if (p_curve->curve.periodic)    fprintf (ofp, "  periodic                 :\n");
      if (p_curve->curve.non_uniform) fprintf (ofp, "  non_uniform              :\n");
      if (p_curve->curve.rational)    fprintf (ofp, "  rational                 :\n");
      if (p_curve->curve.planar)      fprintf (ofp, "  planar                   :\n");
      if (p_curve->curve.phy_closed)  fprintf (ofp, "  phy_closed               :\n");
      }

   /* poles */

   fprintf (ofp, "  poles                    : %d\n", p_curve->curve.num_poles);
   p_dbl = p_curve->curve.poles;
   for (j = 0; j < p_curve->curve.num_poles; ++j)
      {
      fprintf( ofp, "   " );
      if (dimension == 3)
         {
         WriteDouble3( ofp, p_dbl ); p_dbl += 3;
         }
      else
         {
         WriteDouble2( ofp, p_dbl ); p_dbl += 2;
         }
      }

   /* if non-uniform, get knots */

   if (p_curve->curve.non_uniform)
      {
      fprintf (ofp, "  knots                    : %d\n", p_curve->curve.num_knots );
      p_dbl = p_curve->curve.knots;
      for (j = 0; j < p_curve->curve.num_knots; ++j)
         {
         fprintf (ofp, "   " );
         WriteDouble( ofp, *p_dbl++);
         }
      }

   /* if rational, get weights */

   if (p_curve->curve.rational)
      {
      fprintf (ofp, "  weights                  : %d\n", p_curve->curve.num_poles);
      p_dbl = p_curve->curve.weights;
      for (j = 0; j < p_curve->curve.num_poles; ++j)
         {
         fprintf (ofp, "   " );
         WriteDouble( ofp, *p_dbl++);
         }
      }

   fprintf (ofp, "  soo                      : %d\n", p_curve->num_soos);
   if (p_curve->num_soos > 0)
      dump_curve_soo (ofp, p_curve->soos, p_curve->num_soos);

   return HSplot_success;
   }
