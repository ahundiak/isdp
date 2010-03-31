#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HPglobal.h"
#include "HPmacros.h"
#include "HPdef.h"
#include "dump.h"


/*---dump_header------------------------------------------------*/

int dump_header ( FILE *ofp )

   {
   int status;  /* return code from called functions */

   status = HPread_header ();
   if (status) return HSplot_error;

   fprintf (ofp, "header\n");
   fprintf (ofp, "  file_type                : %c%c\n", 
      HPheader.file_type[0], HPheader.file_type[1] );

   if (HPheader.version <= 2176)
      fprintf (ofp, "  version                  : 1 3 0 0\n");
   else
      fprintf (ofp, "  version                  : %d %d %d %d\n",
               (HPheader.version >> 12) & 15, (HPheader.version >> 8) & 15,
               (HPheader.version >> 4) & 15, HPheader.version & 15);

   fprintf (ofp, "  world_to_viewport_scale  : " );
   WriteDouble( ofp, HPheader.world_to_viewport_scale );

   if (HPheader.save_plotfile)
      fprintf (ofp, "  plotfile                 : save\n");
   else
      fprintf (ofp, "  plotfile                 : delete\n");

   if (HPheader.save_rasterfile)
      fprintf (ofp, "  rasterfile               : save\n");
   else
      fprintf (ofp, "  rasterfile               : delete\n");

   fprintf (ofp, "  textfile                 : %s\n", HPheader.input_textfile);
   fprintf (ofp, "  rasterfile               : %s\n", HPheader.rasterfile);

   fprintf (ofp, "  xsize, ysize             : " );
   WriteDouble( ofp, HPheader.xsize );
   fprintf (ofp, "                           : " ); 
   WriteDouble( ofp, HPheader.ysize );

   fprintf (ofp, "  line_width_constant      : " );
   WriteDouble( ofp, HPheader.line_width_constant );

   fprintf (ofp, "  max_line_width           : %d\n", HPheader.max_line_width);
   fprintf (ofp, "  user_line_width          : %d\n", HPheader.user_line_width);
   fprintf (ofp, "  shading_style            : %d\n", HPheader.shading_style);

   fprintf( ofp, "  size_x, size_y           : " );
   WriteDouble( ofp, HPheader.size_x );
   fprintf( ofp, "                           : " );
   WriteDouble( ofp, HPheader.size_y );

   fprintf( ofp, "  plotter_resolution       : " );
   WriteDouble( ofp, HPheader.plotter_resolution );

   fprintf( ofp, "  raster_type              : %1d\n", HPheader.raster_type );

   fprintf( ofp, "  queue                    : %s\n", HPheader.queue );
   fprintf( ofp, "  date                     : %s\n", HPheader.date );

   if (HPheader.save_textfile)
      fprintf (ofp, "  textfile                 : save\n");
   else
      fprintf (ofp, "  textfile                 : delete\n");

   if (HPheader.create_textfile)
      fprintf (ofp, "  create textfile          : TRUE\n");
   else
      fprintf (ofp, "  create textfile          : FALSE\n");

   if (HPheader.white_background)
      fprintf (ofp, "  white background         : TRUE\n");
   else
      fprintf (ofp, "  white background         : FALSE\n");

   if (HPheader.black_and_white_edges)
      fprintf (ofp, "  black_and_white_edges    : TRUE\n");
   else
      fprintf (ofp, "  black_and_white_edges    : FALSE\n");


   return HSplot_success;
   }
