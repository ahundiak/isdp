
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:57 $
$Locker:  $
*/
#ifndef HSplot_str_include
#define HSplot_str_include 1
/*
 *  the shaded plotfile header is the following format
 *
 *    field name     bytes   command
 *    ----------     -----   -----------------------------------------------
 *    file_type          2   Should be "HS"
 *    version            2   4 bits per number (1.4.0.0 = 0x1400)
 *    worldScale         8   world to viewport scale
 *    save_plotfile      2   save plotfile flag
 *    save_rasterfile    2   save rasterfile flag
 *    input textfile    80   textfile name
 *    rasterfile        80   rasterfile name
 *    comment           80   (unused)
 *    xsize              8   x plotsize, used by form (window size)
 *    ysize              8   y plotsize, used by form (window size)
 *    line_width_const   8   line width constant, from environment variable
 *    max_line_width     2   max line width an object can have, from envir
 *    user_line_width    2   max user line width in model
 *    shading_style      2   (1 - Non-Rhl, 2 - RHL, 3 - Both)
 *    size_x             8   plot size, x
 *    size_y             8   plot size, y
 *    plotter_resolution 8   plotter resolution
 *    raster_type        4   rasterfile type
 *    queue             32   name of the device queue
 *    date              32   when to submit the plot
 *    save_textfile      2   save textfile flag
 *    create_textfile    2   create textfile flag
 *    white_background   2   plot white_background if false
 *    black_and_white_   2   black and white edges
 *    exclude_wirefram   2   exclude wireframe elements
 *    ---------------- ---   ----------------------------------------------
 *    total            384
 *
 */
 
/*
 *  The plotfile header will be a total of 512 bytes so a filler is
 *  needed.  This will be 512-total
 */
 
#define HEADER_FILLER 512-2-2-8-2-2-80-80-80-8-8-8-2-2-2-8-8-8-4-32-32-2-2-2-2-2

/*
 *  This structure will hold the contents of the plotfile header, but
 *  is not a representation of the format of the plotfile header due to
 *  compiler padding, unused fields, etc.
 */
 
struct HPplotfile_header
   {
   IGRchar    file_type[2];
   IGRshort   version;
   IGRdouble  world_to_viewport_scale;
   IGRshort   save_plotfile;
   IGRshort   save_rasterfile;
   IGRchar    input_textfile[80];
   IGRchar    rasterfile[80];
   IGRdouble  xsize, ysize;
   IGRdouble  line_width_constant;
   IGRshort   max_line_width;
   IGRshort   user_line_width;
   IGRshort   shading_style;
   
   IGRdouble  size_x, size_y;
   IGRdouble  plotter_resolution;
   IGRint     raster_type;
   IGRchar    queue[32];
   IGRchar    date[32];
   IGRshort   save_textfile;
   IGRshort   create_textfile;
   IGRshort   white_background;
   IGRshort   black_and_white_edges;
   IGRshort   exclude_wireframe;
   };
   
#endif
