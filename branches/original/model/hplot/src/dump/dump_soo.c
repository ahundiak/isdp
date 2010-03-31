#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "hplot.h"
#include "HPdef.h"
#include "HPglobal.h"
#include "dump.h"

/*---dump_curve_soo------------------------------------------------------*/

int dump_curve_soo ( FILE *ofp,
                     struct HPsoo_info *soo,
                     int num_soos )

   {
   int i;

   for (i = 0; i < num_soos; i++)
      {
      fprintf (ofp, "    %d %d %d %d ",
               soo[i].color, soo[i].style, soo[i].weight,
               soo[i].type);
      WriteDouble2( ofp, soo[i].parms );
      }

   return HSplot_success;
   }
