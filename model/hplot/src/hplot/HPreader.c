#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#if defined (CLIX)
#include <EG.h>
#endif
#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "exsysdep.h"

#include "hstiler.h"
#include "hslight.h"
#include "hplot.h"
#include "hpmsg.h"
#include "hsdisplay.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HPglobal.h"
#include "HPdef.h"
#include "HPmacros.h"
#include "HSd_fixedpt.h"

#include "HPpr_hplot.h"

/*-----------------------
 *
 *  for functions
 *     HPremember_minmax
 *     HPzbuffered_surface
 */

#include "HPpr_hplot_f.h"

/*----------------------
 *
 *  for functions
 *     HSfetch_plotting_xrange
 *     HSreset_plotting_xrange
 */

#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

/*----------------------------
 *  for function
 *     HSconv_double
 *     HSconv_int
 *     HSconv_short
 */

#include "HSrle.h"
#include "hsanimate.h"
#include "HSpr_rle_uti.h"

/*------------------------------*/

/*---HPplotfile_reader--------------------------------------------------*/

/*
NAME
    HPplotfile_reader
        
KEYWORDS
    HSplot
    reader
    plotfile
        
DESCRIPTION
    Read the command header, and in some cases, the command data
    from the shaded plotfile
        
PARAMETERS
    file_ptr    :(IN) : File pointer for the shaded plotfile
    command     :(OUT): The command id
    level       :(OUT): level on which the command exist (obsolete)
    range       :(OUT): range of the command data, if applicable
    data_num    :(OUT): number of items read as command data
    data_ptr    :(OUT): buffer containing the command data,if read

FUNCTIONS CALLED
    memset
    fread
    HSconv_short (Sun only)
    HSconv_int (Sun only)
    HSconv_double (Sun only)
    HPread_color_table
    HPmessage
    HPremember_object_curv
    read_nurb_curve
    HPremember_object_surf
    HSreset_plotting_xrange
    HPzbuffered_surface
    HSfetch_plotting_xrange
    HPremember_minmax
    read_nurb_surf
        
HISTORY
    ??/??/?/    M. Lanier
        Created
*/

int HPplotfile_reader( FILE *file_ptr,
                    IGRchar command[2],
                   IGRshort *level,
                  IGRdouble range[6],
                     IGRint *data_num,
                    IGRchar **data_ptr )

   {
   IGRint status;       /* return code from called functions */

   /* element structures -- these must be static as we either return the
    * address */
   /* of same (buffers) or they are used for buffer pointers and alloc sizes */

   static struct GRhesym hsym;
   static struct HS_light_source light_src;
   static struct HS_old_light_source old_light_src;
   static struct HS_old_old_light_source old_old_light_src;
   static struct HPnurb_surface_struct surf;
   static struct HPnurb_curve_struct curve;
   static struct IGRbsp_curve line_poly;
   static struct HPmipmap_info mipmap_info;
   static HPsimple_union simple;        /* simple data types */

   static IGRchar *char_buffer_ptr = NULL;      /* a IGRchar buffer and size */
   static IGRint char_buffer_size = 0;
   static IGRshort *short_buffer_ptr = NULL;    /* a IGRshort buffer and size */
   static IGRint short_buffer_size = 0;
   static IGRdouble matrix[16]; /* a 4x4 or 3x3 transformation matrix */
   static IGRint    two_ints[2];

   static IGRint commands_processed = 0;        /* counter of commands
                                                 * processed */
   static IGRchar initialized = 0;      /* been here flag */
   static IGRint surface_count = 0;
   static IGRint curve_count = 0;

   static unsigned short user_line_style[2];

   static char  *mipmap_home = NULL;

   IGRint surface_type;
   IGRchar view_number;

   IGRint xmin, xmax;
   struct HPbanding_info *object;

   IGRdouble *ele_range;

   /* ------- code ----------------------------------------------------- */

   /* initialize some stuff */

   if( !initialized )
      {
      initialized = 1;

      memset( &light_src, 0, sizeof( struct HS_light_source ) );
      memset( &curve, 0, sizeof( curve ) );
      memset( &surf, 0, sizeof( surf ) );

      char_buffer_size = 32 * 4;
      char_buffer_ptr =( IGRchar * ) calloc( 1, char_buffer_size );

      line_poly.order = 2;
      line_poly.non_uniform = FALSE;
      line_poly.rational = FALSE;
      line_poly.weights = NULL;
      line_poly.num_boundaries = 0;
      line_poly.bdrys = NULL;
      }

   /* read command type, read rest of command, return it */

   *level = 0;
   ele_range = NULL;

   status = fread( command, sizeof( IGRchar ), 2, file_ptr );
   if( status <= 0 ) return HSplot_EOF;

   /* process individual command */

   switch( command[0] )
      {
      case SETUP_COMMAND:
         switch( command[1] )
            {
            case SET_MIPMAP_HOME:
               {
               int n;

               status = fread( &n, sizeof(int), 1, file_ptr );

#              ifdef BIG_ENDIAN
               HSconv_int( &n, 1 );
#              endif

               mipmap_home = (char *)malloc( n+1 );

               status = fread( mipmap_home, n, 1, file_ptr );
                              *data_num = 1;
                              *data_ptr =( IGRchar * ) mipmap_home;

               mipmap_home[n] = 0;
               }
               break;

            case SET_USER_LINE_STYLE:
               status = fread( (IGRchar * ) & simple.u16,
                               sizeof( simple.u16 ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_short( (short *)&simple.u16, 1 );
#              endif

               user_line_style[0] = simple.u16;

               status = fread( (IGRchar * ) & simple.u16,
                               sizeof( simple.u16 ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_short( (short *)&simple.u16, 1 );
#              endif

               user_line_style[1] = simple.u16;

               *data_num = 1;
               *data_ptr =( IGRchar * ) user_line_style;

               break;

            case SET_COLOR_TABLE_RGB:
               status = HPread_color_table( file_ptr,
                                            &short_buffer_ptr,
                                            &short_buffer_size,
                                            data_num );

               if( status )
                  {
                  HPmessage( HP_F_RdClrTbl, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

               *data_ptr =( IGRchar * ) short_buffer_ptr;
               break;

            case SET_TRANSLUCENCY_GRID:
               status = fread( (IGRchar * ) & simple.i8,
                               sizeof( simple.i8 ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdTrnsGrd, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

               *data_num = 1;
               *data_ptr = &simple.i8;
               break;

            case SET_DEPTH_CUE_INTENSITIES:
               status = fread( (char * ) char_buffer_ptr,
                               sizeof( IGRchar ),
                               2,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdDpthCuIntns, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

               *data_num = 2;
               *data_ptr = char_buffer_ptr;
               break;

            case SET_WINDOW_LIGHT_SOURCE:
            case SET_GLOBAL_LIGHT_SOURCE:
            case SET_AMBIENT_LIGHT_SOURCE:
               status = fread( &light_src,
                               sizeof( struct HS_light_source ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdLtSrc, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_double( (double *)light_src.target, 3 );
               HSconv_double( (double *)light_src.location, 3 );
               HSconv_double( (double *)light_src.direction, 3 );
               HSconv_double( (double *)&light_src.radius, 1 );
               HSconv_double( (double *)&light_src.angle, 1 );
               HSconv_short( (short *)&light_src.red, 1 );
               HSconv_short( (short *)&light_src.green, 1 );
               HSconv_short( (short *)&light_src.blue, 1 );
               HSconv_short( (short *)&light_src.flags, 1 );
#              endif

               *data_num = 1;
               *data_ptr =( IGRchar * ) & light_src;
               break;

            case OLD_WINDOW_LIGHT_SOURCE:
            case OLD_GLOBAL_LIGHT_SOURCE:
            case OLD_AMBIENT_LIGHT_SOURCE:
               status = fread( &old_light_src,
                               sizeof( struct HS_old_light_source ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdLtSrc, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_int( (int *)&old_light_src.index, 1 );
               HSconv_int( (int *)&old_light_src.type, 1 );
               HSconv_double( (double *)old_light_src.direction, 3 );
               HSconv_double( (double *)old_light_src.location, 3 );
               HSconv_double( (double *)&old_light_src.radius, 1 );
               HSconv_double( (double *)&old_light_src.angle, 1 );
               HSconv_int( (int *)&old_light_src.red, 1 );
               HSconv_int( (int *)&old_light_src.green, 1 );
               HSconv_int( (int *)&old_light_src.blue, 1 );
#              endif

               *data_num = 1;
               *data_ptr =( IGRchar * ) & old_light_src;
               break;

            case OLD_OLD_WINDOW_LIGHT_SOURCE:
            case OLD_OLD_GLOBAL_LIGHT_SOURCE:
            case OLD_OLD_AMBIENT_LIGHT_SOURCE:
               status = fread( &old_old_light_src,
                               sizeof( struct HS_old_old_light_source ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdLtSrc, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_int( (int *)&old_old_light_src.index, 1 );
               HSconv_int( (int *)&old_old_light_src.type, 1 );
               HSconv_double( (double *)&old_old_light_src.x, 1 );
               HSconv_double( (double *)&old_old_light_src.y, 1 );
               HSconv_double( (double *)&old_old_light_src.z, 1 );
               HSconv_double( (double *)&old_old_light_src.radius, 1 );
               HSconv_int( (int *)&old_old_light_src.red, 1 );
               HSconv_int( (int *)&old_old_light_src.green, 1 );
               HSconv_int( (int *)&old_old_light_src.blue, 1 );
#              endif

               *data_num = 1;
               *data_ptr =( IGRchar * ) & old_old_light_src;
               break;

            case SET_VIEW_ORIENTATION_RANGE:
               status = fread( &view_number,
                               sizeof( view_number ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdVwNmbr, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

               status = fread( HPglobal.matrix,
                               sizeof( IGRdouble ),
                               16,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdMtrx, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_double( (double *)HPglobal.matrix, 16 );
#              endif

               status = fread( HPglobal.range,
                               sizeof( IGRdouble ),
                               6,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdRng, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_double( (double *)HPglobal.range, 6 );
#              endif

               *data_num = 1;
               *data_ptr = NULL;
               break;

            case SET_VIEW_IN_PARALLEL:
            case SET_VIEW_IN_PERSPECTIVE:
               *data_num = 0;
               *data_ptr = NULL;
               break;

            default:
               goto unknown_cmd;
               }
         break;

      case BASIC_ATTR_COMMAND:
         switch( command[1] )
            {
            case SET_ACTIVE_MIPMAP:
               {
               int n;
            
               /* get mipmap filename */
            
               status = fread( &n, sizeof(int), 1, file_ptr );
            
#              if defined (BIG_ENDIAN)
               HSconv_int( &n, 1 );
#              endif
            
               if( n > 0 )
                  {
                  mipmap_info.mipmap_file = (char *)malloc( n+1 );
                  status = fread( mipmap_info.mipmap_file, n, 1, file_ptr );
                  }
               else
                  mipmap_info.mipmap_file = NULL;
            
               /* get mipmap home */
            
               status = fread( &n, sizeof(int), 1, file_ptr );
            
#              if defined (BIG_ENDIAN)
               HSconv_int( &n, 1 );
#              endif

               if( n > 0 )
                  {
                  mipmap_info.mipmap_home = (char *)malloc( n+1 );
                  status = fread( mipmap_info.mipmap_home, n, 1, file_ptr );
                  }
               else
                  mipmap_info.mipmap_home = mipmap_home;

               /* get orientation */
            
               status = fread( &mipmap_info.orientation, sizeof(int), 1, file_ptr );

#              if defined (BIG_ENDIAN)
               HSconv_int( &mipmap_info.orientation, 1 );
#              endif

               }

               *data_num = 1;
               *data_ptr = (char *)&mipmap_info;

               break;

            case SET_HIDDEN_SYMBOLOGY:
               HPglobal.display_hidden_edges = 1;
               status = fread( &hsym,
                               sizeof( struct GRhesym ),
                               1,
                               file_ptr );

#              ifdef BIG_ENDIAN
               HSconv_short( (short *)&hsym.color, 1 );
               HSconv_short( (short *)&hsym.flags, 1 );
#              endif

               *data_num = 1;
               *data_ptr =( IGRchar * ) & hsym;
               break;

            case SET_ACTIVE_TILING_TOLERANCE:
               status = fread( &simple.f64,
                               sizeof( simple.f64 ),
                               1,
                               file_ptr );

#              ifdef BIG_ENDIAN
               HSconv_double( (double *)&simple.f64, 1 );
#              endif

               *data_num = 1;
               *data_ptr =( IGRchar * ) & simple.f64;
               break;

            case SET_ACTIVE_SHADING_ACCURACY:
               status = fread( &simple.i16,
                               sizeof( simple.i16 ),
                               1,
                               file_ptr );

#              ifdef BIG_ENDIAN
               HSconv_short( (short *)&simple.i16, 1 );
#              endif

               *data_num = 1;
               *data_ptr =( IGRchar * ) & simple.i16;
               break;

            case SET_ACTIVE_PHONG_ATTRIBUTES:
               status = fread( &HPglobal.elem_finish,
                               sizeof( HPglobal.elem_finish ),
                               1,
                               file_ptr );

               status = fread( &HPglobal.elem_spec_refl,
                               sizeof( HPglobal.elem_spec_refl ),
                               1,
                               file_ptr );

               status = fread( &HPglobal.elem_diff_refl,
                               sizeof( HPglobal.elem_diff_refl ),
                               1,
                               file_ptr );

#              ifdef BIG_ENDIAN
               HSconv_int   ( (int    *)&HPglobal.elem_finish, 1 );
               HSconv_double( (double *)&HPglobal.elem_spec_refl, 1 );
               HSconv_double( (double *)&HPglobal.elem_diff_refl, 1 );
#              endif

               *data_num = 1;
               *data_ptr =( IGRchar * ) & simple.i16;
               break;

            case SET_ACTIVE_FG_COLOR_INDEX:
               status = fread( &simple.i16,
                               sizeof( simple.i16 ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdClrIndx, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_short( (short *)&simple.i16, 1 );
#              endif

               *data_num = 1;
               *data_ptr =( IGRchar * ) & simple.i16;
               break;

            case SET_ACTIVE_LINE_STYLE:
               status = fread( &simple.i16,
                               sizeof( simple.i16 ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdStylIndx, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_short( (short *)&simple.i16, 1 );
#              endif

               *data_num = 1;
               *data_ptr =( IGRchar * ) & simple.i16;
               break;

            case SET_ACTIVE_LINE_WIDTH:
               status = fread( &simple.f64,
                               sizeof( simple.f64 ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdWdth, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_double( (double *)&simple.f64, 1 );
#              endif

               *data_num = 1;
               *data_ptr =( IGRchar * ) & simple.f64;
               break;

            case SET_ACTIVE_RENDERING_MODE:
               status = fread( &simple.i8,
                               sizeof( simple.i8 ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdRndMd, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

               *data_num = 1;
               *data_ptr = &simple.i8;
               break;

            case SET_ACTIVE_TRANSLUCENCY:
               status = fread( &simple.i8,
                               sizeof( simple.i8 ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdTrns, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

               *data_num = 1;
               *data_ptr = &simple.i8;
               break;

            case SET_VIEWPORT_TO_WLD_MATRIX:
               status = fread( matrix,
                               sizeof( IGRdouble ),
                               16,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdRotMtrx, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_double( (double *)matrix, 16 );
#              endif

               *data_num = 16;
               *data_ptr =( IGRchar * ) matrix;
               break;

            case SET_ACTIVE_ROTATION_MATRIX:
               status = fread( matrix,
                               sizeof( IGRdouble ),
                               16,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdRotMtrx, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_double( (double *)matrix, 16 );
#              endif

               *data_num = 16;
               *data_ptr =( IGRchar * ) matrix;
               break;

            case SET_ACTIVE_POST_ROTATION_MATRIX:
               status = fread( matrix,
                               sizeof( IGRdouble ),
                               16,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdPstRotMtrx, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_double( (double *)matrix, 16 );
#              endif

               *data_num = 16;
               *data_ptr =( IGRchar * ) matrix;
               break;

            case SET_OBJECT_INFO:
               status = fread( &simple.u32,
                               sizeof( simple.u32 ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  return( HSplot_error );
                  }

               two_ints[0] = simple.u32;

               status = fread( &simple.u16,
                               sizeof( simple.u16 ),
                               1,
                               file_ptr );

               if( status <= 0 )
                  {
                  return( HSplot_error );
                  }

               two_ints[1] = (IGRint)simple.u16;

               *data_num = 2;
               *data_ptr =( IGRchar * ) two_ints;
               break;

            default:
               goto unknown_cmd;
               }
         break;

      case PRIMITIVE_COMMAND:

         /* get level number */

         status = fread( level,
                         sizeof( IGRshort ),
                         1,
                         file_ptr );

         if( status <= 0 )
            {
            HPmessage( HP_F_RdLvl, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
            return( HSplot_error );
            }

#        ifdef BIG_ENDIAN
         HSconv_short( (short *)level, 1 );
#        endif

         switch( command[1] )
            {
            case oldNURB_EDGE:
            case oldNURB_CURVE:
               if( HPglobal.rendering_mode != HPmode_WIREFRAME )
                  HPremember_object_curv( file_ptr,
                                          HPglobal.active_color,
                                          HPglobal.translucency,
                                          command[1],
                                          HPglobal.rendering_mode,
                                          HPglobal.tiling_tolerance,
                                          HPglobal.line_width,
                                          HPglobal.line_style,
                                          ++curve_count,
                                          HPglobal.objid,
                                          HPglobal.osnum );

               curve.num_soos = 0;  /* read, pre-3.0 curve */
               status = read_nurb_curve( file_ptr,
                                         3,
                                         &curve.curve,
                                         &curve.num_soos,
                                         &curve.soos );

               if( status )
                  return HSplot_error;

               *data_num = 1;
               *data_ptr =( IGRchar * ) & curve;
               break;

            case NURB_EDGE:
            case NURB_CURVE:
               if( HPglobal.rendering_mode != HPmode_WIREFRAME )
                  if( command[1] != NURB_CURVE || 
                      !(HPglobal.flags & HPflag_Exclude_Wireframe) )
                     HPremember_object_curv( file_ptr,
                                             HPglobal.active_color,
                                             HPglobal.translucency,
                                             command[1],
                                             HPglobal.rendering_mode,
                                             HPglobal.tiling_tolerance,
                                             HPglobal.line_width,
                                             HPglobal.line_style,
                                             ++curve_count,
                                             HPglobal.objid,
                                             HPglobal.osnum );

               curve.num_soos = 1;  /* read, post-3.0 curve */
               status = read_nurb_curve( file_ptr,
                                         3,
                                         &curve.curve,
                                         &curve.num_soos,
                                         &curve.soos );

               if( status )
                  return HSplot_error;

               *data_num = 1;
               *data_ptr =( IGRchar * ) & curve;
               break;

            case NURB_SURFACE_WITH_RANGE:
               status = fread( range,
                               sizeof( double ),
                               6,
                               file_ptr );

               if( status <= 0 )
                  {
                  HPmessage( HP_F_RdSrfRng, NULL, 
                             HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
                  return( HSplot_error );
                  }

#              ifdef BIG_ENDIAN
               HSconv_double( (double *)range, 6 );
#              endif

               ele_range = range;

            case NURB_SURFACE:
               if( HPglobal.rendering_mode != HPmode_WIREFRAME )
                  {

                  object = HPremember_object_surf( file_ptr,
                                                   HPglobal.active_color,
                                                   HPglobal.translucency,
                                                   HPglobal.trans_grid,
                                                   HPglobal.rendering_mode,
                                                   HPglobal.tiling_tolerance,
                                                   HPglobal.line_width,
                                                   HPglobal.line_style,
                                                   ++surface_count,
                                                   HPglobal.objid,
                                                   HPglobal.osnum );

                  HSreset_plotting_xrange(  );

                  status = HPzbuffered_surface( file_ptr,
                                                ele_range,
                                                surface_count );

                  HSfetch_plotting_xrange( &xmin, &xmax );
                  HPremember_minmax( object, xmin, xmax );
                  }
               else
                  {
                  status = read_nurb_surface( file_ptr,
                                              &surf.surface,
                                              &surf.bdry_curves,
                                              &surf.curves_size,
                                              &surface_type );

                  if( status )
                     return HSplot_error;
                  }

               *data_num = 1;
               *data_ptr =( IGRchar * ) & surf;
               break;

            default:
               goto unknown_cmd;
               }
         break;

      default:

         /* error -- unknown command type */
         goto unknown_cmd;
         }

   ++commands_processed;

   return HSplot_success;

/*--- unknown command error ------------------------------------------*/

unknown_cmd:
fprintf( stderr, "command: %d %d\n", command[0], command[1] );
   HPmessage( HP_F_UnkwnCmd, NULL, 
              HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
   return HSplot_error;
   }
