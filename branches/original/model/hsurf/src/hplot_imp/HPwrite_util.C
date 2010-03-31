
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $

HISTORY

        Sudha   07/27/93        Modified for BSprototypes ansification

*/

#include <stdio.h>
#include <FI.h>

#include "wl.h"

#include "OMminimum.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "msdef.h"
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "dp.h"
#include "dpstruct.h"

#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"

#include "bstypes.h"
#include "bschrdlkts.h"
#include "bsalloccv.h"

#include "hplot_imp.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hsmsg.h"
#include "hsdef.h"
#include "hslight.h"
#include "hstiler.h"
#include "HStl_element.h"

#include "HSplot_def.h"
#include "HSplot.h"
#include "HSplot_str.h"

#include "de.h"

#include "HSpr_hplot.h"

/*------------------------------
 *  for function
 *     HSget_dpb_data
 */

#include "HSe2_mesher.h"
#include "HSpr_driver.h"

/*------------------------------
 *  for functions
 *     HSconv_double
 *     HSconv_int
 *     HSconv_short
 */

#include "hsanimate.h"
#include "HSrle.h"
#include "HSpr_rle_uti.h"

/*-----------------------------
 *  for function
 *     HSget_trans_grid
 */

#include "hsurf.h"
#include "HSpr_dpb_imp.h"

/*------------------------------*/



#define	MAX_SLOTS	512

#ifdef X11
extern Colormap EXcolormap[];

struct HPvlt_slot
   {
   unsigned long pixel;
   unsigned short v_red;
   unsigned short v_green;
   unsigned short v_blue;
   char flags;
   char pad;
   };

#endif

/*
 *  Static variables
 */

/*
 *  For symbology
 */

static int prev_color;
static int prev_width;
static int prev_style;
static unsigned int style_flags[8];
static int max_width;
static int active_style;
static double prev_tiling_tolerance;
static int prev_accuracy;
static int prev_acc_mode;
static int prev_finish;
static double prev_spec_refl;
static double prev_diff_refl;

/*
 *  For rendering mode
 */

static int prev_mode;
static int prev_trans;

#define	DEBUG			0
#define TRANSLUCENT		127
#define OPAQUE			0

/*---FILE_WRITE--------------------------------------------------------*/

/*
NAME
    FILE_WRITE: macro
        
KEYWORDS
    shaded plotting
    macro
        
DESCRIPTION
    make call to write function and check status
        
PARAMETERS
    x1   :(IN) : file pointer
    x2   :(IN) : data pointer
    x3   :(IN) : byte count
        
HISTORY
    ??/??/??   M. Lanier
        Created
*/

#define FILE_WRITE( x1, x2, x3 )                  \
                                                  \
   {                                              \
   status = write( x1, x2, x3 );                  \
   if( status <= 0 ) return( HS_E_PltFlWrtErr );  \
   }

/*---HPget_max_width_active_style-----------------------------------*/

/*
NAME
    HPget_max_width_active_style
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    return to the caller, the accumulated max line width and
    shading style(s)
        
PARAMETERS
    w    :(OUT): max line width
    s    :(OUT): shading style(s)

GLOBALS USED
    max_width    : the accumulated max line width
    active_style    : the accumulated shading style(s)
                
HISTORY
    ??/??/??    M. Lanier
        Created
*/

void HPget_max_width_active_style( short *w, short *s )


   {
   *w = max_width;
   *s = active_style;
   }

/*---HPwrite_init----------------------------------------------------*/

/*
NAME
    HPwrite_init
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    Initialize the write of a shaded plotfile by initializing
    some local variables
        
GLOBALS USED
    prev_color,    : The previous color, line weight and line style (not
    prev_width     : shading style), rendering mode, translucency mode,
    prev_style     : tiling tolerance, accuracy mode and accuracy.  If
    prev_mode      : the current value is the same as the previous
    prev_trans     : then there is no need to make another entry in the
    prev_tolerance : shaded plotfile
    prev_acc_mode  :
    prev_accuarcy  :
    max_width      : accumulate max line width
    active_style   : accumulate shading style(s)
    style_flags    : ???
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

void HPwrite_init(void)

   {

   /* For symbology */

   prev_color = -1;
   prev_width = -1;
   prev_style = -1;

   style_flags[0] = 0;
   style_flags[1] = 0;
   style_flags[2] = 0;
   style_flags[3] = 0;
   style_flags[4] = 0;
   style_flags[5] = 0;
   style_flags[6] = 0;
   style_flags[7] = 0;

   /* For rendering mode */

   prev_mode = -1;
   prev_trans = -1;

   /* other */

   max_width = 0;
   active_style = 0;

   prev_tiling_tolerance = -1;
   prev_accuracy = -1;
   prev_acc_mode = -1;

   prev_finish = -1;
   prev_spec_refl = -1.0;
   prev_diff_refl = -1.0;
   }


/*---HPwrite_plotfile_header------------------------------------------*/

/*
NAME
    HPwrite_plotfile_header
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    Write the shaded plotfile header into the file
        
PARAMETERS
    info               : (IN) : shaded plotting global information
    world_to_view_scale: (IN) : world to viewport scale
    xsize, ysize       : (IN) : dimensions of the viewport

HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRint HPwrite_plotfile_header( struct HSplot_info *info,
                                         IGRdouble *world_to_viewport_scale,
                                         IGRdouble *xsize,
                                         IGRdouble *ysize )

   {
   struct HPplotfile_header header;
   IGRchar                  reserved[HEADER_FILLER];
   IGRshort                 save_plotfile, save_rasterfile;
   IGRshort                 save_textfile, create_textfile;
   IGRshort                 white_background;
   IGRshort                 black_and_white_edges;
   IGRshort                 exclude_wireframe;
   IGRlong                  status;
   extern char              *getenv();
   char                     *expr;

   memset( reserved, 0, HEADER_FILLER );

   /*
    * version 2000: pryor to endian'ness issue version 2001: 
    * with endian'ness issus resolved
    */

   sprintf( header.file_type, "HS" );
   header.version = 0x3400;
   header.xsize = *xsize;
   header.ysize = *ysize;

   save_plotfile = info->dpb_flags & HS_PLOT_SAVE_PLOTFILE;
   save_rasterfile = info->dpb_flags & HS_PLOT_SAVE_RASTERFILE;
   save_textfile = info->dpb_flags & HS_PLOT_SAVE_TEXTFILE;
   create_textfile = info->dpb_flags & HS_PLOT_CREATE_TEXTFILE;
   white_background = info->dpb_flags & HS_PLOT_WHITE_BACKGROUND;
   black_and_white_edges = info->dpb_flags & HS_PLOT_BLACK_AND_WHITE;
   exclude_wireframe = info->dpb_flags & HS_PLOT_EXCLUDE_WIREFRAME;

   header.size_x = info->size_x;
   header.size_y = info->size_y;
   header.plotter_resolution = info->plotter_resolution;
   header.raster_type = info->raster_type;

   if( header.plotter_resolution == 0.0 )
      header.plotter_resolution = 100.0;
   
   strcpy( header.queue, info->queue );
   strcpy( header.date, info->date );

#  ifdef BIG_ENDIAN
   HSconv_short ( (short *) &header.version, 1 );
   HSconv_double( (double *) world_to_viewport_scale, 1 );
   HSconv_short ( (short *) &save_plotfile, 1 );
   HSconv_short ( (short *) &save_rasterfile, 1 );
   HSconv_short ( (short *) &save_textfile, 1 );
   HSconv_short ( (short *) &create_textfile, 1 );
   HSconv_short ( (short *) &white_background, 1 );
   HSconv_short ( (short *) &black_and_white_edges, 1 );
   HSconv_short ( (short *) &exclude_wireframe, 1 );
   HSconv_double( (double *) &header.xsize, 1 );
   HSconv_double( (double *) &header.ysize, 1 );
   HSconv_double( (double *) &header.size_x, 1 );
   HSconv_double( (double *) &header.size_y, 1);
   HSconv_double( (double *) &header.plotter_resolution, 1);
   HSconv_int   ( (int *) &header.raster_type, 1 );
#  endif

   FILE_WRITE( info->file_id, header.file_type, 2);
   FILE_WRITE( info->file_id, &header.version, sizeof (IGRshort));
   FILE_WRITE( info->file_id, world_to_viewport_scale, sizeof (IGRdouble));
   FILE_WRITE( info->file_id, &save_plotfile, 2);
   FILE_WRITE( info->file_id, &save_rasterfile, 2);
   FILE_WRITE( info->file_id, info->textfile, 80);
   FILE_WRITE( info->file_id, info->rasterfile, 80);
   FILE_WRITE( info->file_id, info->rasterfile, 80);

   FILE_WRITE( info->file_id, &header.xsize, sizeof (double));
   FILE_WRITE( info->file_id, &header.ysize, sizeof (double));

   header.line_width_constant = HP_DEFAULT_LINE_WIDTH_CONSTANT;
   header.max_line_width = HP_DEFAULT_MAX_LINE_WIDTH;
   header.user_line_width = HP_DEFAULT_USER_LINE_WIDTH;

   expr = getenv ("HSplot_LINE_WIDTH_CONSTANT");
   if( expr ) 
      sscanf (expr, "%lf", &header.line_width_constant);
   else
      header.line_width_constant = info->line_width_const;

   expr = getenv ("HSplot_MAX_LINE_WIDTH");
   if( expr ) 
      sscanf (expr, "%d", &header.max_line_width);
   else
      header.max_line_width = info->max_line_width;

   /*
    * get the max width and active style from the util functions.  If this is
    * the first write of the header, it will be the initial values.  If this
    * is the second write of the header, then they will be what was scanned
    * from the data written into the plotfile.  After writing this into the
    * plotfile, go ahead and return.  The first_write flag will be false on
    * the second write
    */

   HPget_max_width_active_style(
            &header.user_line_width,
            &header.shading_style );

#  ifdef BIG_ENDIAN
   HSconv_double( (double *) &header.line_width_constant, 1 );
   HSconv_short ( (short *) &header.max_line_width, 1 );
   HSconv_short ( (short *) &header.user_line_width, 1 );
   HSconv_short ( (short *) &header.shading_style, 1 );
#  endif

   FILE_WRITE( info->file_id, &header.line_width_constant, sizeof (IGRdouble) );
   FILE_WRITE( info->file_id, &header.max_line_width, sizeof (IGRshort) );
   FILE_WRITE( info->file_id, &header.user_line_width, sizeof (IGRshort) );
   FILE_WRITE( info->file_id, &header.shading_style, sizeof (IGRshort) );

   FILE_WRITE( info->file_id, &header.size_x, sizeof( IGRdouble ) );
   FILE_WRITE( info->file_id, &header.size_y, sizeof( IGRdouble ) );
   FILE_WRITE( info->file_id, &header.plotter_resolution, sizeof( IGRdouble ) );
   FILE_WRITE( info->file_id, &header.raster_type, sizeof( IGRint ) );
   FILE_WRITE( info->file_id, &header.queue, sizeof( IGRchar ) * 32 );
   FILE_WRITE( info->file_id, &header.date, sizeof( IGRchar ) * 32 );
   FILE_WRITE( info->file_id, &save_textfile, 2);
   FILE_WRITE( info->file_id, &create_textfile, 2);
   FILE_WRITE( info->file_id, &white_background, 2);
   FILE_WRITE( info->file_id, &black_and_white_edges, 2);
   FILE_WRITE( info->file_id, &exclude_wireframe, 2);

   FILE_WRITE( info->file_id, reserved, HEADER_FILLER );

   return( OM_S_SUCCESS );
   }

/*---HPwrite_colortable-----------------------------------------------*/

/*
NAME
    HPwrite_colortable
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    Write the colortable into the shaded plotfile
        
PARAMETERS
    info        :(IN) : shade plotting global information
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRint HPwrite_colortable( struct HSplot_info *info )

   {
   IGRlong          i, status;
   IGRshort         number_colors;
   unsigned char    command[4];
   unsigned short   num_entries;

   struct HS_light_source    ambient_light;

   struct IGEvlt    vlt[MAX_SLOTS], bgcolor, hilite_color;

   IGRdouble        ambient;
   IGRshort         dred, dgreen, dblue;

   /* get ambient light */

   hs$get_global_lights( ambient_light = &ambient_light );

   ambient = (ambient_light.red + ambient_light.green + ambient_light.blue) / 3;
   ambient = ambient / 255;

   number_colors = MAX_SLOTS;

   status = ige$read_reserved_colors (bgcolor = &bgcolor,
                                      hilite_color = &hilite_color);

   status = ige$read_color_table (num_colors = &number_colors,
                                  colors = vlt);

   info->num_colors = number_colors = 250;
   info->num_shades = 1;

   command[0] = SETUP_COMMAND;
   command[1] = SET_COLOR_TABLE_RGB;

   FILE_WRITE( info->file_id, (char *) command, 2 );

   /*
    * number of slots, number of color times 2 (light and dark) plus hilite
    * and background
    */

   num_entries = ((number_colors) * 2) + 2;

#  ifdef BIG_ENDIAN
   HSconv_short ((short *) (&num_entries), 1);
#  endif

   FILE_WRITE( info->file_id, &num_entries, sizeof(unsigned short) );

   /* background */

#  ifdef BIG_ENDIAN
   HSconv_short( (short *) (&bgcolor.red), 1 );
   HSconv_short( (short *) (&bgcolor.green), 1 );
   HSconv_short( (short *) (&bgcolor.blue), 1 );
#  endif

   FILE_WRITE( info->file_id, &bgcolor.red, sizeof (unsigned short) );
   FILE_WRITE( info->file_id, &bgcolor.green, sizeof (unsigned short) );
   FILE_WRITE( info->file_id, &bgcolor.blue, sizeof (unsigned short) );

   /* colors */

   for( i=0; i<number_colors; i++ )
      {
#     ifdef BIG_ENDIAN
      HSconv_short( (short *) (&vlt[i].red), 1 );
      HSconv_short( (short *) (&vlt[i].green), 1 );
      HSconv_short( (short *) (&vlt[i].blue), 1 );
#     endif

      FILE_WRITE( info->file_id, &vlt[i].red, sizeof (unsigned short) );
      FILE_WRITE( info->file_id, &vlt[i].green, sizeof (unsigned short) );
      FILE_WRITE( info->file_id, &vlt[i].blue, sizeof (unsigned short) );

      dred   = (IGRshort)( (double)(vlt[i].red) * ambient );
      dgreen = (IGRshort)( (double)(vlt[i].green) * ambient );
      dblue  = (IGRshort)( (double)(vlt[i].blue) * ambient );

#     ifdef BIG_ENDIAN
      HSconv_short (&dred, 1);
      HSconv_short (&dgreen, 1);
      HSconv_short (&dblue, 1);
#     endif

      FILE_WRITE( info->file_id, &dred, sizeof (unsigned short) );
      FILE_WRITE( info->file_id, &dgreen, sizeof (unsigned short) );
      FILE_WRITE( info->file_id, &dblue, sizeof (unsigned short) );
      }


   /* hilite */

#  ifdef BIG_ENDIAN
   HSconv_short( (short *)(&vlt[MAX_SLOTS - 1].red), 1 );
   HSconv_short( (short *)(&vlt[MAX_SLOTS - 1].green), 1 );
   HSconv_short( (short *)(&vlt[MAX_SLOTS - 1].blue), 1 );
#  endif

   FILE_WRITE( info->file_id, &vlt[MAX_SLOTS-1].red, sizeof(unsigned short) );
   FILE_WRITE( info->file_id, &vlt[MAX_SLOTS-1].green, sizeof(unsigned short) );
   FILE_WRITE( info->file_id, &vlt[MAX_SLOTS-1].blue, sizeof(unsigned short) );

   return( OM_S_SUCCESS );
   }

/*---HPwrite_trans_grid---------------------------------------*/

/*
NAME
    HPwrite_trans_grid
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    Write the translucency grid into the shaded plotfile
        
PARAMETERS
    info    :(IN) : shaded plotting global information
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/
     
IGRint HPwrite_trans_grid( struct HSplot_info *info )

   {
   unsigned char command[3];
   unsigned char gridsize;
   IGRint        gridsize_flag;
   IGRlong       status;

   /* translucency grid */

   HSget_trans_grid( &gridsize_flag );
   gridsize = (gridsize_flag == 0) ? 1 : 3;

   command[0] = SETUP_COMMAND;
   command[1] = SET_TRANSLUCENCY_GRID;
   command[2] = gridsize;

   FILE_WRITE( info->file_id, (char *) command, 3 );

   return( OM_S_SUCCESS );
   }

/*---HPwrite_depth_cues---------------------------------------*/

/*
NAME
    HPwrite_depth_cues
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    write the depth cue information into the shaded plotfile
        
PARAMETERS
    info    :(IN) : shaded plotting global information
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRint HPwrite_depth_cues( struct HSplot_info *info )

   {
   unsigned char command[4];
   IGRuchar      far_depth_cue;
   IGRlong       status;

   /* depth cue intensities */

   hs$get_depth_cues( far_depth_cue = &far_depth_cue );

   command[0] = SETUP_COMMAND;
   command[1] = SET_DEPTH_CUE_INTENSITIES;
   command[2] = 255;
   command[3] = far_depth_cue;

   FILE_WRITE( info->file_id, (char *)command, 4 );

#  if DEBUG
   fprintf( stderr, "depth cue near=%d, far=%d\n", command[2], command[3] );
#  endif

   return( OM_S_SUCCESS );
   }

/*---HPwrite_light_sources---------------------------------------------------*/

/*
NAME
    HPwrite_light_sources
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    write light source structures into the shaded plotfile
        
PARAMETERS
    info    :(IN) : shaded plotting global information
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRint HPwrite_light_sources( struct HSplot_info *info )

   {
   unsigned char command[2];
   IGRlong       status, i;

   struct HS_light_source global_lights[MAX_LIGHTS];
   struct HS_light_source ambient_light;


   /* Store light sources */

   hs$get_global_lights( lights = global_lights,
                  ambient_light = &ambient_light);

   command[0] = SETUP_COMMAND;
   command[1] = SET_GLOBAL_LIGHT_SOURCE;

   for( i=0; i<MAX_LIGHTS; i++ )
      {
      if( global_lights[i].flags & HS_LIGHT_ENABLED )
         {
         FILE_WRITE( info->file_id, command, 2 );

#        ifdef BIG_ENDIAN
         HSconv_double( (double *) global_lights[i].target, 3);
         HSconv_double( (double *) global_lights[i].location, 3);
         HSconv_double( (double *) global_lights[i].direction, 3);
         HSconv_double( (double *)&global_lights[i].radius, 1);
         HSconv_double( (double *)&global_lights[i].angle, 1);
         HSconv_short ( (short *) &global_lights[i].red, 1);
         HSconv_short ( (short *) &global_lights[i].green, 1);
         HSconv_short ( (short *) &global_lights[i].blue, 1);
         HSconv_short ( (short *) &global_lights[i].flags, 1);
#        endif

         FILE_WRITE( info->file_id, &global_lights[i], sizeof(struct HS_light_source) );
         }
      }

   command[0] = SETUP_COMMAND;
   command[1] = SET_AMBIENT_LIGHT_SOURCE;

   FILE_WRITE( info->file_id, command, 2 );

#  ifdef BIG_ENDIAN
   HSconv_double( (double *) ambient_light.target, 3);
   HSconv_double( (double *) ambient_light.location, 3);
   HSconv_double( (double *) ambient_light.direction, 3);
   HSconv_double( (double *)&ambient_light.radius, 1);
   HSconv_double( (double *)&ambient_light.angle, 1);
   HSconv_short ( (short *) &ambient_light.red, 1);
   HSconv_short ( (short *) &ambient_light.green, 1);
   HSconv_short ( (short *) &ambient_light.blue, 1);
   HSconv_short ( (short *) &ambient_light.flags, 1);
#  endif

   FILE_WRITE( info->file_id, &ambient_light, sizeof(struct HS_light_source) );

   return( OM_S_SUCCESS );
   }

/*---HPwrite_view_orientation_and_range----------------------------------------------_*/

/*
NAME
    HPwrite_view_orientation_and_range
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    write the viewport and transformation matrix into the
    shaded plotfile
        
PARAMETERS
    info    :(IN) : shaded plotting global information
    matrix  :(IN) : transformation matrix
    range   :(IN) : viewport
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRint HPwrite_view_orientation_and_range( struct HSplot_info *info,
                                                    IGRdouble *matrix,
                                                    IGRdouble *range )

   {
   unsigned char viewNumber = 1;
   unsigned char command[2];
   IGRlong       status;

   /* view orientation and range */

   command[0] = SETUP_COMMAND;
   command[1] = SET_VIEW_ORIENTATION_RANGE;

#  ifdef BIG_ENDIAN
   HSconv_double( (double *)matrix, 16 );
   HSconv_double( (double *)range, 6 );
#  endif

   FILE_WRITE( info->file_id, (char *) command, 2);
   FILE_WRITE( info->file_id, &viewNumber, sizeof (IGRchar));
   FILE_WRITE( info->file_id, matrix, 16 * sizeof (IGRdouble));
   FILE_WRITE( info->file_id, range, 6 * sizeof (IGRdouble));

   return( OM_S_SUCCESS );
   }

/*---HPwrite_perspective_flag----------------------------------------*/

/*
NAME
    HPwrite_perspective_flag
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    write the perspective flag into the shaded plot file
        
PARAMETERS
    info        :(IN) : shaded plotting global information
    perspective :(IN) : perspective flag
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRint HPwrite_perspective_flag( struct HSplot_info *info,
                                             IGRint perspective )

   {
   unsigned char command[2];
   IGRlong       status;


   /* write perspective parallel flag */

   command[0] = SETUP_COMMAND;

   if( perspective )
      command[1] = SET_VIEW_IN_PERSPECTIVE;
   else
      command[1] = SET_VIEW_IN_PARALLEL;

   FILE_WRITE( info->file_id, (char *) command, 2 );

   return( OM_S_SUCCESS );
   }

/*---HPwrite_other_matrices------------------------------------*/

/*
NAME
    HPwrite_other_matrices
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    write the viewport_to_world, rotation and post_rotation
    matrices into the shaded plot file.
        
PARAMETERS
    info              :(IN) : shaded plotting global information
    viewport_to_world :(IN) : viewport to world matrix
    rotation          :(IN) : rotation matrix
    post_rotation     :(IN) : post rotation matrix
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRint HPwrite_other_matrices( struct HSplot_info *info,
                                        IGRdouble *viewport_to_world,
                                        IGRdouble *rotation,
                                        IGRdouble *post_rotation )

   {
   unsigned char command[2];
   IGRlong       status;

   /* save the rotation matrix for calls to get_graphics_edges */

   memcpy( info->rotation, rotation, 16 * sizeof(IGRdouble) );

   /* viewport to world matrix */

   command[0] = BASIC_ATTR_COMMAND;
   command[1] = SET_VIEWPORT_TO_WLD_MATRIX;

#  ifdef BIG_ENDIAN
   HSconv_double( (double *)viewport_to_world, 16 );
   HSconv_double( (double *)rotation, 16 );

   if( post_rotation )
      HSconv_double( (double *)post_rotation, 16 );
#  endif

   FILE_WRITE( info->file_id, (char *)command, 2 );
   FILE_WRITE( info->file_id, viewport_to_world, 16 * sizeof(IGRdouble) );

   /* rotation matrix */

   command[0] = BASIC_ATTR_COMMAND;
   command[1] = SET_ACTIVE_ROTATION_MATRIX;

   FILE_WRITE( info->file_id, (char *)command, 2 );
   FILE_WRITE( info->file_id, rotation, 16 * sizeof(IGRdouble) );

   if( post_rotation )
      {
      command[0] = BASIC_ATTR_COMMAND;
      command[1] = SET_ACTIVE_POST_ROTATION_MATRIX;

      FILE_WRITE( info->file_id, (char *)command, 2 );
      FILE_WRITE( info->file_id, post_rotation, 16 * sizeof(IGRdouble) );
      }

   return( OM_S_SUCCESS );
   }

/*---HPwrite_hidden_symbology_parms------------------------------------*/

/*
NAME
    HPwrite_hidden_symbology_parms
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    write the hidden_symbology information into the
    shaded plotfile
        
PARAMETERS
    info    :(IN) : shaded plotting global information
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRint HPwrite_hidden_symbology_parms( struct HSplot_info *info )

   {
   unsigned char command[2];
   IGRlong       status;
   IGRboolean    hidden_line_display;
   
   struct GRhesym hidden_symbology;

   /* write the hidden symbology parameters */

   gr$get_hidden_so_on( buffer = &hidden_line_display );
   if( hidden_line_display )
      {
      gr$get_hidden_edge_sym( buffer = &hidden_symbology );

      command[0] = BASIC_ATTR_COMMAND;
      command[1] = SET_HIDDEN_SYMBOLOGY;

      FILE_WRITE( info->file_id, (char *) command, 2 );

#     ifdef BIG_ENDIAN
      HSconv_short( (short *)&hidden_symbology.color, 1 );
      HSconv_short( (short *)&hidden_symbology.flags, 1 );
#     endif

      FILE_WRITE( info->file_id, &hidden_symbology, sizeof(struct GRhesym) );

      HPwrite_line_style( (IGRint *)&info->file_id, hidden_symbology.style );
      }

   return( OM_S_SUCCESS );
   }

/*---HPwrite_line_style-----------------------------------------------*/

/*
NAME
    HPwrite_line_style
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    write the line style into the shaded plot file
        
PARAMETERS
    file_id : (IN) : shaded plotfile file id
    style   : (IN) : style index, of style to write
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRint HPwrite_line_style( IGRint *file_id, unsigned short style )

   {
   int            index, mask;
   unsigned char  command[2];    /* igm command code and subcode */
   unsigned short u16;           /* for writing short values */
   IGRlong        status;        /* status from called functions */

   index = style / 32;
   mask = 1 << (style % 32);

   if( !(style_flags[index] & mask) )
      {
      DPinq_style( style, &u16 );

      command[0] = SETUP_COMMAND;
      command[1] = SET_USER_LINE_STYLE;

#     ifdef BIG_ENDIAN
      HSconv_short( (short *)&style, 1 );
      HSconv_short( (short *)&u16, 1 );
#     endif

      FILE_WRITE( *file_id, (char *)command, 2 );
      FILE_WRITE( *file_id, (char *)&style, sizeof(unsigned short) );
      FILE_WRITE( *file_id, (char *)&u16, sizeof(unsigned short) );

      style_flags[index] |= mask;
      }

   return OM_S_SUCCESS;
   }


IGRint  HPwrite_special_symbology( IGRint *file_id, GRobjid objid, GRspacenum osnum )

   {
   IGRlong        status;      /* status from called functions */
   int		finish;
   double	spec_refl, diff_refl;
   double	transparency;
   unsigned char  command[2];  /* igm command code and subcode */

   hs$get_element_shading_symb( objid        = objid,
                                osnum        = osnum,
                                finish       = &finish,
                                spec_refl    = &spec_refl,
                                diff_refl    = &diff_refl );
                                /*
                                transparency = &transparency,
                                tex_orient   = &tex_orient,
                                tex_index    = &tex_index );
                                */

   if( finish != prev_finish ||
       spec_refl != prev_spec_refl ||
       diff_refl != prev_diff_refl )
      {
      prev_finish = finish;
      prev_spec_refl = spec_refl;
      prev_diff_refl = diff_refl;

#     ifdef BIG_ENDIAN
      HSconv_int   ( (int *)&finish, 1 );
      HSconv_double( (double *)&spec_refl, 1 );
      HSconv_double( (double *)&diff_refl, 1 );
#     endif

      command[0] = BASIC_ATTR_COMMAND;
      command[1] = SET_ACTIVE_PHONG_ATTRIBUTES;

      FILE_WRITE( *file_id, (char *)command, 2 );
      FILE_WRITE( *file_id, (char *)&finish, sizeof(finish) );
      FILE_WRITE( *file_id, (char *)&spec_refl, sizeof(spec_refl) );
      FILE_WRITE( *file_id, (char *)&diff_refl, sizeof(diff_refl) );
      }

   return OM_S_SUCCESS;
   }

/*---HPwrite_symbology-----------------------------------------------*/

/*
NAME
    HPwrite_symbology
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    write the symbology information into the shaded plotfile
        
PARAMETERS
    file_id    :(IN) : shaded plotfile file id
    symbology  :(IN) : object symbology structure
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRlong HPwrite_symbology( IGRint *file_id, struct IGRdisplay *symbology )

   {
   double         dbl;         /* for writing double values */
   IGRlong        status;      /* status from called functions */
   unsigned short u16;         /* for writing short values */
   unsigned char  command[2];  /* igm command code and subcode */


   if( symbology->color != prev_color )
      {
      u16 = prev_color = symbology->color;
      command[0] = BASIC_ATTR_COMMAND;
      command[1] = SET_ACTIVE_FG_COLOR_INDEX;

#     ifdef BIG_ENDIAN
      HSconv_short( (short *)&u16, 1 );
#     endif

      FILE_WRITE( *file_id, (char *)command, 2 );
      FILE_WRITE( *file_id, (char *)&u16, sizeof(u16) );
      }

   if( symbology->weight != prev_width )
      {
      u16 = prev_width = symbology->weight;

      if( u16 > max_width )
         {
         max_width = u16;
         }

      command[0] = BASIC_ATTR_COMMAND;
      command[1] = SET_ACTIVE_LINE_WIDTH;

      dbl = (double)u16;

#     ifdef BIG_ENDIAN
      HSconv_double( (double *)&dbl, 1 );
#     endif

      FILE_WRITE( *file_id, (char *)command, 2 );
      FILE_WRITE( *file_id, (double *)&dbl, sizeof(dbl) );
      }

   if( symbology->style != prev_style )
      {
      u16 = prev_style = symbology->style;

      HPwrite_line_style( file_id, u16 );

      command[0] = BASIC_ATTR_COMMAND;
      command[1] = SET_ACTIVE_LINE_STYLE;

#     ifdef BIG_ENDIAN
      HSconv_short( (short *)&u16, 1 );
#     endif

      FILE_WRITE( *file_id, (char *)command, 2 );
      FILE_WRITE( *file_id, (char *)&u16, sizeof(u16) );
      }

   return OM_S_SUCCESS;
   }


/*--- HPwrite_rendering----------------------------------------------*/

/*
NAME
   HPwrite_rendering
        
KEYWORDS
   shaded plotting
        
DESCRIPTION
   write the rendering mode into the shaded plotfile
        
PARAMETERS
   file_id :(IN) : shaded plotfile file id
   obj_id  :(IN) : active object's objid
   osnum   :(IN) : active object's osnum
   style   :(IN) : active rendering mode
        
HISTORY
   ??/??/??    M. Lanier
       Created
*/

IGRlong HPwrite_rendering( IGRint *file_id,
                           IGRint obj_id,
                         IGRshort osnum,
                           IGRint *style )
                           
   {
   IGRlong       status;        /* status from called functions */
   unsigned char command[3];    /* igm command code and subcode */
   IGRint        acc_mode;
   IGRint        accuracy;
   IGRdouble     tiling_tolerance;
   IGRdouble     spec_refl, diff_refl, translucency;
   IGRint        style_mode;
   IGRint        fem_mesh, fem_style;
   IGRint        finish;
   IGRint        show_hidden_tst;

   HSget_dpb_data(
          obj_id, osnum,
          &acc_mode, &accuracy,
          &style_mode, style,
          &fem_mesh, &fem_style,
          &finish, &spec_refl, &diff_refl,
          &translucency );

   if( acc_mode == HS_ACCURACY_MODE_WINDOW )
      hs$get_shading_tolerance( tolerance = &tiling_tolerance );

   hs$get_rhl_info( show_hidden = &show_hidden_tst );

#  if DEBUG
   fprintf (stderr, "write rendering objid(%d): accuracy, style, translucency: %d %d %lf\n",
            obj_id, accuracy, *style, translucency);
#  endif

   /* rendering mode */

   switch( *style )
      {
      case HS_STYLE_SMOOTH:
         active_style |= 0x01;
         command[2] = 1;
         break;

      case HS_STYLE_CONSTANT:
         active_style |= 0x01;
         command[2] = 2;
         break;

      case HS_STYLE_RASTER:
         active_style |= 0x02;
         if( show_hidden_tst == HS_SHOW_HIDDEN_EDGES_YES )
            command[2] = 7;
         else
            command[2] = 3;
         break;

      case HS_STYLE_FILLED_RASTER:
         active_style |= 0x02;
         if( show_hidden_tst == HS_SHOW_HIDDEN_EDGES_YES )
            command[2] = 7;
         else
            command[2] = 4;
         break;

      case HS_STYLE_AREAFILL:
         active_style |= 0x01;
         command[2] = 5;
         break;

      default:
         command[2] = 1;
         break;
         }

   if( command[2] != prev_mode )
      {
      command[0] = BASIC_ATTR_COMMAND;
      command[1] = SET_ACTIVE_RENDERING_MODE;
      FILE_WRITE( *file_id, (char *)command, 3 );

      prev_mode = command[2];
      }

   /* translucency */

   command[2] = (translucency >= 0.5) ? TRANSLUCENT : OPAQUE;
   if( command[2] != prev_trans )
      {
      command[0] = BASIC_ATTR_COMMAND;
      command[1] = SET_ACTIVE_TRANSLUCENCY;
      FILE_WRITE( *file_id, (char *)command, 3 );

      prev_trans = command[2];
      }

   command[0] = BASIC_ATTR_COMMAND;
   if( acc_mode == HS_ACCURACY_MODE_WINDOW )
      {
      command[1] = SET_ACTIVE_TILING_TOLERANCE;

      if( tiling_tolerance != prev_tiling_tolerance )
         {
#        ifdef BIG_ENDIAN
         HSconv_double( (double *)&tiling_tolerance, 1 );
#        endif

         FILE_WRITE( *file_id, command, 2 );
         FILE_WRITE( *file_id, &tiling_tolerance, sizeof(double) );

         prev_tiling_tolerance = tiling_tolerance;
         prev_accuracy = -1;
         }
      }
   else
      {
      command[1] = SET_ACTIVE_SHADING_ACCURACY;

      if( accuracy != prev_accuracy )
         {
#        ifdef BIG_ENDIAN
         HSconv_short( (short *)&accuracy, 1 );
#        endif

         FILE_WRITE( *file_id, command, 2 );
         FILE_WRITE( *file_id, (short *)&accuracy, sizeof(short) );

         prev_tiling_tolerance = -1;
         prev_accuracy = accuracy;
         }
      }

   return OM_S_SUCCESS;
   }

/*--- HPwrite_object_info---------------------------------------------*/

/*
NAME
   HPwrite_object_info
        
KEYWORDS
   shaded plotting
        
DESCRIPTION
   write the object information like objid and osnum into the shaded
   plotfile.  This will appear before the object and can be used to 
   trace a bad surface back to the design file
        
PARAMETERS
   file_id :(IN) : shaded plotfile file id
   objid   :(IN) : active object's objid
   osnum   :(IN) : active object's osnum
        
HISTORY
   ??/??/??    M. Lanier
       Created
*/

IGRlong HPwrite_object_info( IGRint *file_id,
                             IGRint objid,
                           IGRshort osnum )
                           
   {
   unsigned char command[3];
   IGRlong       status;

   command[0] = BASIC_ATTR_COMMAND;
   command[1] = SET_OBJECT_INFO;

#  ifdef BIG_ENDIAN
   HSconv_int( (int *)&objid, 1 );
   HSconv_short( (short *)&osnum, 1 );
#  endif

   FILE_WRITE( *file_id, command, 2 );
   FILE_WRITE( *file_id, (int *)&objid, sizeof(int) );
   FILE_WRITE( *file_id, (short *)&osnum, sizeof(short) );

   return OM_S_SUCCESS;
   }

static int scount = 0;
static int ccount = 0;

/*---HPwrite_draw_range----------------------------------------------*/

/*
NAME
    HPwrite_draw_range
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    write the nurb object, shaded plotfile command header
    and range, if available into the shaded plotfile
        
PARAMETERS
    file_id      :(IN) : shaded plotfile file id
    sub_command  :(IN) : tells type of object
    level        :(IN) : object level
    range        :(IN) : object range
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRlong HPwrite_draw_range( IGRint *file_id,
                            IGRint sub_command,
                            IGRint level,
                           GRrange range )

   {
   IGRlong        status;      /* status from called functions */
   unsigned short u16;         /* for writing short values */
   unsigned char  command[2];  /* igm command code and subcode */

   command[0] = PRIMITIVE_COMMAND;
   command[1] = sub_command;

   FILE_WRITE( *file_id, (char *)command, 2 );

   u16 = level;

if( sub_command == NURB_SURFACE || sub_command == NURB_SURFACE_WITH_RANGE )
   {
   u16 = ++scount;
   if( (scount % 1000) == 0 )
   fprintf( stderr, "surface ------------- %1d\n", scount );
   }
else
   {
   u16 = ++ccount;
   if( (ccount % 1000) == 0 )
   fprintf( stderr, "curve --------------- %1d\n", ccount );
   }

#  if DEBUG
   fprintf( stderr, "level ------------- %1d\n", u16 );
#  endif

   FILE_WRITE( *file_id, (char *)&u16, sizeof(u16) );

   if( range != NULL && !(sub_command == NURB_CURVE || sub_command == NURB_SURFACE) )
      {
#     ifdef BIG_ENDIAN
      HSconv_double( (double *)range, 6 );
#     endif

      FILE_WRITE( *file_id, (char *)range, sizeof(double) * 6 );
      }

   return OM_S_SUCCESS;
   }

/*---HPconvert_curve---------------------------------------------------*/

/*
NAME
    HPconvert_curve
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    Convert a boundary object into a nurb curve
        
PARAMETERS
    bdry  :(IN) : boundary object
    curve :(OUT): boundary curve
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRlong HPconvert_curve( struct IGRbsp_bdry_pts *bdry,
                            struct IGRbsp_curve **curve )

   {
   int          j;       /* counters */
   IGRshort     order2 = 2;
   IGRboolean   rational = FALSE;
   IGRshort     num_boundaries = 0;
   BSrc         rc;

   BSalloccv( order2, bdry->num_points, rational, num_boundaries, curve, &rc );

   (*curve)->order = order2;
   (*curve)->num_poles = bdry->num_points;

   for( j=0; j<bdry->num_points; j++ )
      {
      (*curve)->poles[3*j]   = bdry->points[2*j];
      (*curve)->poles[3*j+1] = bdry->points[2*j+1];
      (*curve)->poles[3*j+2] = 0.;
      }

   /* BStst_plan for planar         */
   /* BScvtstclsd for closed         */
   /* BSsfarrev0 for (u,v) to (x,y,z)      */

   (*curve)->periodic = FALSE;
   (*curve)->non_uniform = TRUE;
   (*curve)->planar = TRUE;     /* useless now     */
   (*curve)->phy_closed = TRUE;
   (*curve)->rational = rational;
   (*curve)->num_knots = (*curve)->order + (*curve)->num_poles;

   /* non-uniform distributed knot vector */

   BSchrdlkts( &rc,
               &(*curve)->num_poles,
               (*curve)->poles,
               &order2,
               &(*curve)->periodic,
               (*curve)->knots);

   (*curve)->num_boundaries = num_boundaries;

   return OM_S_SUCCESS;
   }

/*---HPwrite_surface_info-------------------------------------------------*/

/*
NAME
    HPwrite_surface_info
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    write surface geometry into the shaded plotfile
        
PARAMETERS
    file_id      :(IN) : shaded plotfile file id
    surface      :(IN) : surface geometry
    surf_type    :(IN) : surface type
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRlong HPwrite_surface_info( IGRint *file_id,
               struct IGRbsp_surface *surface,
                            IGRshort surf_type )


   {
   IGRlong        status;      /* status from called things */
   int            count;       /* counters */
   unsigned short flags = 0;   /* packed surface flags */

#  ifdef BIG_ENDIAN
   int ci, cj;
#  endif

   /* write u and v order */

#  ifdef BIG_ENDIAN
   HSconv_short( (short *)&surface->u_order, 1 );
   HSconv_short( (short *)&surface->v_order, 1 );
#  endif

   FILE_WRITE( *file_id, (char *)&surface->u_order, sizeof(surface->u_order) );
   FILE_WRITE( *file_id, (char *)&surface->v_order, sizeof(surface->v_order) );

#  ifdef BIG_ENDIAN
   HSconv_short( (short *)&surface->u_order, 1 );
   HSconv_short( (short *)&surface->v_order, 1 );
#  endif

   /* pack distributed flags, write the flags and surface type */

   if (surface->u_periodic)      flags |= SF_U_PERIODIC_M;
   if (surface->v_periodic)      flags |= SF_V_PERIODIC_M;
   if (surface->u_non_uniform)   flags |= SF_U_NON_UNIFORM_M;
   if (surface->v_non_uniform)   flags |= SF_V_NON_UNIFORM_M;
   if (surface->rational)        flags |= SF_RATIONAL_M;
   if (surface->planar)          flags |= SF_PLANAR_M;
   if (surface->u_phy_closed)    flags |= SF_U_CLOSED_M;
   if (surface->v_phy_closed)    flags |= SF_V_CLOSED_M;
   if (surface->pos_orient)      flags |= SF_ORIENTATION_M;
   if (surface->on_off)          flags |= SF_SOLID_HOLE_M;

#  ifdef BIG_ENDIAN
   HSconv_short( (short *)&flags, 1 );
   HSconv_short( (short *)&surf_type, 1 );
#  endif

   FILE_WRITE( *file_id, (char *)&flags, sizeof (flags) );
   FILE_WRITE( *file_id, (char *)&surf_type, sizeof (short) );

   /* write u and v number of poles */

#  ifdef BIG_ENDIAN
      {
      IGRlong u_num_poles, v_num_poles;

      u_num_poles = surface->u_num_poles;
      v_num_poles = surface->v_num_poles;

      HSconv_int( (int *)&u_num_poles, 1 );
      HSconv_int( (int *)&v_num_poles, 1 );

      FILE_WRITE( *file_id, (char *)&u_num_poles, sizeof(IGRlong) );
      FILE_WRITE( *file_id, (char *)&v_num_poles, sizeof(IGRlong) );
      }
#  else
   FILE_WRITE( *file_id, (char *)&surface->u_num_poles, sizeof(IGRlong) );
   FILE_WRITE( *file_id, (char *)&surface->v_num_poles, sizeof(IGRlong) );
#  endif

   /* write number of boundaries */

#  ifdef BIG_ENDIAN
      {
      IGRshort num_boundaries;

      num_boundaries = surface->num_boundaries;
      HSconv_short ((short *) &num_boundaries, 1);
      FILE_WRITE( *file_id, (char *)&num_boundaries, sizeof(IGRshort) );
      }
#  else
   FILE_WRITE( *file_id, (char *)&surface->num_boundaries, sizeof(IGRshort) );
#  endif

   /* write poles */

   count = 3 * surface->u_num_poles * surface->v_num_poles;

#  ifdef BIG_ENDIAN
   HSconv_double( (double *)surface->poles, count );
#  endif

   FILE_WRITE( *file_id, (char *)surface->poles, sizeof(IGRdouble) * count );

#  ifdef BIG_ENDIAN
   HSconv_double( (double *)surface->poles, count );
#  endif

   /* if u is non-uniform, write u knots */

   if (surface->u_non_uniform)
      {
      count = surface->u_num_knots;

#     ifdef BIG_ENDIAN
      HSconv_double( (double *)surface->u_knots, count );
#     endif

      FILE_WRITE( *file_id, (char *)surface->u_knots, sizeof(IGRdouble) * count );

#     ifdef BIG_ENDIAN
      HSconv_double( (double *)surface->u_knots, count );
#     endif
      }

   /* if v is non-uniform, write v knots */

   if( surface->v_non_uniform )
      {
      count = surface->v_num_knots;

#     ifdef BIG_ENDIAN
      HSconv_double( (double *)surface->v_knots, count );
#     endif

      FILE_WRITE( *file_id, (char *)surface->v_knots, sizeof(IGRdouble) * count);

#     ifdef BIG_ENDIAN
      HSconv_double( (double *)surface->v_knots, count );
#     endif
      }

   /* if surface is rational, write weights */

   if( surface->rational )
      {
      count = surface->u_num_poles * surface->v_num_poles;

#     ifdef BIG_ENDIAN
      HSconv_double( (double *)surface->weights, count );
#     endif

      FILE_WRITE( *file_id, (char *)surface->weights, sizeof(IGRdouble) * count );

#     ifdef BIG_ENDIAN
      HSconv_double( (double *) surface->weights, count );
#     endif
      }

   return( OM_S_SUCCESS );
   }


/*---HPwrite_curve_info---------------------------------------------------*/

/*
NAME
    HPwrite_curve_info
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    write curve geometry into the shaded plotfile
        
PARAMETERS
    file_id      :(IN) : shaded plotfile file pointer
    curve        :(IN) : curve geometry
    dimension    :(IN) : dimension of the curve
    has_soo      :(IN) : if the curve has overrides
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRlong HPwrite_curve_info( IGRint *file_id,
               struct IGRbsp_curve *curve,
                            IGRint dimension,
                        IGRboolean has_soo )

   {
   IGRlong         status;      /* status from called things */
   int             j;           /* counters */
   double          *dptr;
   unsigned short  flags = 0;   /* packed curve flags */

   /* write order */

#  ifdef BIG_ENDIAN
   HSconv_short( (short *)&curve->order, 1 );
#  endif

   FILE_WRITE( *file_id, (char *)&curve->order, sizeof(IGRshort) );

   /* pack distributed flags and write them */

   if( curve->periodic )    flags |= CV_PERIODIC_M;
   if( curve->non_uniform ) flags |= CV_NON_UNIFORM_M;
   if( curve->rational )    flags |= CV_RATIONAL_M;
   if( curve->planar )      flags |= CV_PLANAR_M;
   if( curve->phy_closed )  flags |= CV_PHY_CLOSED_M;
   if( has_soo )            flags |= CV_HAS_SOO;

#  ifdef BIG_ENDIAN
   HSconv_short( (short *)&flags, 1 );
#  endif

   FILE_WRITE( *file_id, (char *)&flags, sizeof(IGRshort) );

   /* write number of poles */

#  ifdef BIG_ENDIAN
      {
      IGRlong num_poles;

      num_poles = curve->num_poles;
      HSconv_int( (int *)&num_poles, 1 );
      
      FILE_WRITE( *file_id, (char *)&num_poles, sizeof(IGRlong) );
      }
#  else
   FILE_WRITE( *file_id, (char *)&curve->num_poles, sizeof(curve->num_poles) );
#  endif

   /* write poles */

   dptr = curve->poles;

#  ifdef BIG_ENDIAN
   HSconv_double( (double *)dptr, curve->num_poles * 3 );
#  endif

   for( j=0; j<curve->num_poles; ++j )
      {
      FILE_WRITE( *file_id, (char *)dptr++, sizeof(IGRdouble) );
      FILE_WRITE( *file_id, (char *)dptr++, sizeof(IGRdouble) );

      if( dimension == 3 )
         {
         FILE_WRITE( *file_id, (char *)dptr++, sizeof(IGRdouble) );
         }
      else
         dptr++;
      }

   /* if curve is non-uniform, write knots */

   if( curve->non_uniform )
      {
#     ifdef BIG_ENDIAN
      HSconv_double( (double *)curve->knots, curve->num_knots );
#     endif

      FILE_WRITE( *file_id, (char *)curve->knots, sizeof(IGRdouble) * curve->num_knots );
      }

   /* if curve is rational, write weights */

   if( curve->rational )
      {
#     ifdef BIG_ENDIAN
      HSconv_double( (double *)curve->weights, curve->num_poles );
#     endif

      FILE_WRITE( *file_id, (char *)curve->weights, sizeof(IGRdouble) * curve->num_poles );
      }

   return OM_S_SUCCESS;
   }

/*---HPwrite_curve_soo---------------------------------------------------*/

/*
NAME
    HPwrite_curve_soo
        
KEYWORDS
    shaded plotting
        
DESCRIPTION
    write override information into the shaded plotfile
        
PARAMETERS
    file_id  :(IN) : shaded plotfile file pointer
    p_parms  :(IN) : override parameters
    p_attr   :(IN) : override attributes
    p_count  :(IN) : number of overrides
    p_type   :(IN) : override type
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRlong HPwrite_curve_soo( IGRint *file_id,
                        IGRdouble *p_parms,
                struct IGRdisplay *p_attr,
                           IGRint p_count,
                           IGRint *p_type )

   {
   int              i;
   IGRlong          status;
   unsigned short   type;

#  ifdef BIG_ENDIAN
      {
      int n;

      n = p_count;
      HSconv_int( &n, 1 );
      FILE_WRITE( *file_id, &n, sizeof(IGRint) );
      }
#  else
   FILE_WRITE( *file_id, &p_count, sizeof(IGRint) );
#  endif


   for( i=0; i<p_count; i++ )
      {
      type = (unsigned short)p_type[i];
#     ifdef BIG_ENDIAN
      HSconv_double( (double *)&p_parms[(i*2)], 1 );
      HSconv_double( (double *)&p_parms[(i*2+1)], 1 );
      HSconv_short ( (short *) &p_attr[i].color, 1 );
      HSconv_short ( (short *) &type, 1 );
#     endif

      FILE_WRITE( *file_id, &p_parms[(i*2)],   sizeof(IGRdouble) );
      FILE_WRITE( *file_id, &p_parms[(i*2+1)], sizeof(IGRdouble));
      FILE_WRITE( *file_id, &p_attr[i].color,  sizeof(unsigned short));
      FILE_WRITE( *file_id, &p_attr[i].style,  sizeof(unsigned char));
      FILE_WRITE( *file_id, &p_attr[i].weight, sizeof(unsigned char));
      FILE_WRITE( *file_id, &type,             sizeof(unsigned short));
      }

   return OM_S_SUCCESS;
   }
