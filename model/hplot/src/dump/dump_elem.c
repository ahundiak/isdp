#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "gotextdef.h"
#include "hsdef.h"
#include "HStl_window.h"
#include "HPglobal.h"
#include "HPdef.h"
#include "HPmacros.h"
#include "HStin.h"
#include "hpmsg.h"
#include "grdpbdef.h"
#include "dump.h"

/*---dump_element------------------------------------------------------------*/

int dump_element ( FILE      *ofp,       /* output file pointer */
                   IGRchar   command[2], /* command identifier */
                   IGRint    level,      /* graphic level if draw command */
                   IGRdouble range[6],   /* range of element if draw command with range */
                   IGRint    num,        /* number of data items if array */
                   IGRchar   *data_ptr)  /* generic pointer to data buffer */

   {
   IGRint         status;   /* return code from called functions */
   IGRint         j, j2;    /* useful counters */
   IGRint         *itemp;
   IGRchar        str[40];  /* a char string */

   unsigned char  *p_u8;    /* pointer to u8 */
   unsigned short *p_u16;   /* pointer to u16 */
   IGRdouble      *p_dbl;   /* pointer to double */

   IGRchar        u8;       /* an u8 */
   struct GRhesym *hsym;
   unsigned short *user_line_style, pattern;

   struct HS_light_source *p_light;

   switch (command[0])
      {
      case SETUP_COMMAND:
         switch (command[1])
            {
            case SET_MIPMAP_HOME:
               fprintf( ofp, "mipmap_home : %s\n", data_ptr );
               break;

            case SET_USER_LINE_STYLE:

               user_line_style = (unsigned short *) data_ptr;

               fprintf (ofp, "user_line_style            : %1d : ", user_line_style[0]);

               fprintf (ofp, "\"");
               pattern = user_line_style[1];
               for (j = 0; j < 16; j++)
                  {
                  if (pattern & 0x8000)
                     fprintf (ofp, "-");
                  else
                     fprintf (ofp, " ");

                  pattern <<= 1;
                  }

               fprintf (ofp, "\";\n");
               break;

            case SET_COLOR_TABLE_RGB:

               /* check for null table */

               if (num == 0) return HSplot_success;

               fprintf (ofp, "colortable                 : %d 4\n  ", num);

               /* for each table entry, print rgb values */

               p_u16 = (unsigned short *) data_ptr;
               for (j = 0; j < num; ++j)
                  {
                  fprintf (ofp, "( %5d", *p_u16++);
                  fprintf (ofp, " %5d", *p_u16++);
                  fprintf (ofp, " %5d )", *p_u16++);
    
                  if( ((j+1) % 4) == 0 )
                     fprintf( ofp, "\n  " );
                  }

               fprintf( ofp, ";\n" );
               break;

            case SET_TRANSLUCENCY_GRID:
               p_u8 = (unsigned char *) data_ptr;
               fprintf (ofp, "translucency_grid          : %d;\n", *p_u8);
               break;

            case SET_DEPTH_CUE_INTENSITIES:
               p_u8 = (unsigned char *) data_ptr;
               fprintf (ofp, "depth cues                 : %d", *p_u8++);
               fprintf (ofp, " %d\n", *p_u8++);
               break;

            case OLD_WINDOW_LIGHT_SOURCE:
               p_light = (struct HS_light_source *) data_ptr;

               fprintf (ofp, "old_window light\n");
               fprintf (ofp, "  index 0\n");

               if (p_light->flags & HS_LIGHT_POINT)
                  {
                  fprintf (ofp, "  point\n");
                  fprintf (ofp, "  radius %f\n", p_light->radius);
                  }

               fprintf (ofp, "  coord (%14.8f %14.8f %14.8f)\n",
                        p_light->direction[0], p_light->direction[1], p_light->direction[2]);

               fprintf (ofp, "  color (%3d %3d %3d);\n", p_light->red, p_light->green, p_light->blue);
               break;

            case SET_WINDOW_LIGHT_SOURCE:
               p_light = (struct HS_light_source *) data_ptr;

               fprintf (ofp, "window light\n");
               fprintf (ofp, "  index 0\n");

               if (p_light->flags & HS_LIGHT_PARALLEL)
                  {
                  fprintf (ofp, "  parallel\n");
                  fprintf (ofp, "  direction (%14.8f %14.8f %14.8f)\n",
                           p_light->direction[0], p_light->direction[1], p_light->direction[2]);
                  }
               else if (p_light->flags & HS_LIGHT_POINT)
                  {
                  fprintf (ofp, "  location (%14.8f %14.8f %14.8f)\n",
                           p_light->location[0], p_light->location[1], p_light->location[2]);
                  fprintf (ofp, "  point\n");
                  fprintf (ofp, "  radius %f\n", p_light->radius);
                  }
               else if (p_light->flags & HS_LIGHT_SPOT)
                  {
                  fprintf (ofp, "  spot\n");
                  fprintf (ofp, "  direction (%14.8f %14.8f %14.8f)\n",
                           p_light->direction[0], p_light->direction[1], p_light->direction[2]);
                  fprintf (ofp, "  location (%14.8f %14.8f %14.8f)\n",
                           p_light->location[0], p_light->location[1], p_light->location[2]);
                  fprintf (ofp, "  point\n");
                  fprintf (ofp, "  radius %f\n", p_light->radius);
                  fprintf (ofp, "  angle %f\n", p_light->angle);
                  }
               else if (p_light->flags & HS_LIGHT_PENCIL)
                  {
                  fprintf (ofp, "  pencil\n");
                  fprintf (ofp, "  direction (%14.8f %14.8f %14.8f)\n",
                           p_light->direction[0], p_light->direction[1], p_light->direction[2]);
                  fprintf (ofp, "  location (%14.8f %14.8f %14.8f)\n",
                           p_light->location[0], p_light->location[1], p_light->location[2]);
                  fprintf (ofp, "  point\n");
                  fprintf (ofp, "  radius %f\n", p_light->radius);
                  }

               fprintf (ofp, "  color (%3d %3d %3d);\n", p_light->red, p_light->green, p_light->blue);
               break;

            case OLD_GLOBAL_LIGHT_SOURCE:
               p_light = (struct HS_light_source *) data_ptr;

               fprintf (ofp, "old_global_light\n");
               fprintf (ofp, "  index 0\n");

               if (p_light->flags & HS_LIGHT_POINT)
                  {
                  fprintf (ofp, "  point\n");
                  fprintf (ofp, "  radius %f\n", p_light->radius);
                  }

               fprintf (ofp, "  coord (%f %f %f)\n",
                        p_light->direction[0], p_light->direction[1], p_light->direction[2]);
               fprintf (ofp, "  color (%1d %1d %1d);\n", p_light->red, p_light->green, p_light->blue);
               break;

            case SET_GLOBAL_LIGHT_SOURCE:
               p_light = (struct HS_light_source *) data_ptr;

               fprintf (ofp, "global_light               : 0\n");

               if (p_light->flags & HS_LIGHT_PARALLEL)
                  {
                  fprintf (ofp, "  parallel                 : \n");
                  fprintf (ofp, "  direction                : \n   " );
                  WriteDouble3( ofp, p_light->direction );
                  }
               else if (p_light->flags & HS_LIGHT_POINT)
                  {
                  fprintf (ofp, "  location (%14.8f %14.8f %14.8f)\n",
                           p_light->location[0], p_light->location[1], p_light->location[2]);
                  fprintf (ofp, "  point\n");
                  fprintf (ofp, "  radius %f\n", p_light->radius);
                  }
               else if (p_light->flags & HS_LIGHT_SPOT)
                  {
                  fprintf (ofp, "  spot\n");
                  fprintf (ofp, "  direction (%14.8f %14.8f %14.8f)\n",
                           p_light->direction[0], p_light->direction[1], p_light->direction[2]);
                  fprintf (ofp, "  location (%14.8f %14.8f %14.8f)\n",
                           p_light->location[0], p_light->location[1], p_light->location[2]);
                  fprintf (ofp, "  point\n");
                  fprintf (ofp, "  radius %f\n", p_light->radius);
                  fprintf (ofp, "  angle %f\n", p_light->angle);
                  }
               else if (p_light->flags & HS_LIGHT_PENCIL)
                  {
                  fprintf (ofp, "  pencil\n");
                  fprintf (ofp, "  direction (%14.8f %14.8f %14.8f)\n",
                           p_light->direction[0], p_light->direction[1], p_light->direction[2]);
                  fprintf (ofp, "  location (%14.8f %14.8f %14.8f)\n",
                           p_light->location[0], p_light->location[1], p_light->location[2]);
                  fprintf (ofp, "  point\n");
                  fprintf (ofp, "  radius %f\n", p_light->radius);
                  }

               fprintf (ofp, "  color                    : %1d %1d %1d\n", 
                  p_light->red, p_light->green, p_light->blue );
               fprintf (ofp, "  flags                    : %1d\n", p_light->flags );
               break;

            case SET_AMBIENT_LIGHT_SOURCE:
               p_light = (struct HS_light_source *) data_ptr;

               fprintf (ofp, "ambient light              : %1d %1d %1d\n", 
                  p_light->red, p_light->green, p_light->blue);
               break;

            case OLD_AMBIENT_LIGHT_SOURCE:
               p_light = (struct HS_light_source *) data_ptr;

               fprintf (ofp, "old_ambient light\n");
               fprintf (ofp, "  color (%1d %1d %1d);\n", p_light->red, p_light->green, p_light->blue);
               break;

            case SET_VIEW_IN_PARALLEL:
               fprintf (ofp, "view_type                  : parallel;\n");
               break;

            case SET_VIEW_IN_PERSPECTIVE:
               fprintf (ofp, "view_type                  : perspective;\n");
               break;

            case SET_VIEW_ORIENTATION_RANGE:
               fprintf (ofp, "view\n");
               p_dbl = HPglobal.matrix;
               fprintf (ofp, "  matrix                   : \n");
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[0] );
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[4] );
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[8] );
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[12] );

               p_dbl = HPglobal.range;
               fprintf (ofp, "  range                    : \n");
               fprintf( ofp, "   " ); WriteDouble3( ofp, &p_dbl[0] );
               fprintf( ofp, "   " ); WriteDouble3( ofp, &p_dbl[3] );
               break;

            default:
               goto quit;
               }
         break;

      case BASIC_ATTR_COMMAND:
         str[0] = 0;
         switch (command[1])
            {
            case SET_ACTIVE_MIPMAP:
               {
               struct HPmipmap_info *mipmap_info;

               mipmap_info = (struct HPmipmap_info *)data_ptr;

               fprintf( ofp,"mipmap :\n" );
               if( mipmap_info->mipmap_file )
                  fprintf( ofp, "   file : %s\n", mipmap_info->mipmap_file );

               if( mipmap_info->mipmap_home )
                  fprintf( ofp, "   home : %s\n", mipmap_info->mipmap_home );

               switch( mipmap_info->orientation )
                  {
                  case HS_UP:     fprintf( ofp, "orientation : UP\n" ); break;
                  case HS_RUP:    fprintf( ofp, "orientation : RUP\n" ); break;
                  case HS_DOWN:   fprintf( ofp, "orientation : DOWN\n" ); break;
                  case HS_RDOWN:  fprintf( ofp, "orientation : RDOWN\n" ); break;
                  case HS_RIGHT:  fprintf( ofp, "orientation : RIGHT\n" ); break;
                  case HS_RRIGHT: fprintf( ofp, "orientation : RRIGHT\n" ); break;
                  case HS_LEFT:   fprintf( ofp, "orientation : LEFT\n" ); break;
                  case HS_RLEFT:  fprintf( ofp, "orientation : RLEFT\n" ); break;
                  }
               }

               break;

            case SET_HIDDEN_SYMBOLOGY:
               hsym = (struct GRhesym *) data_ptr;

               fprintf (ofp, "hidden_symbology\n");
               if (hsym->flags & DPB_USE_ORIG_COLOR)
                  fprintf (ofp, "  color                    : original\n"  );
               else
                  fprintf (ofp, "  color                    : %1d\n", hsym->color);

               if (hsym->flags & DPB_USE_ORIG_STYLE)
                  fprintf (ofp, "  style                    : original\n"  );
               else
                  fprintf (ofp, "  style                    : %1d\n", hsym->style);

               if (hsym->flags & DPB_USE_ORIG_WEIGHT)
                  fprintf (ofp, "  weight                   : original\n"  );
               else
                  fprintf (ofp, "  weight                   : %1d\n", hsym->weight );

               fprintf( ofp, "  flags                    : %1d\n", hsym->flags );
               break;

            case SET_ACTIVE_TILING_TOLERANCE:
               p_dbl = (IGRdouble *) data_ptr;
               fprintf (ofp, "tiling_tolerance           : " );
               WriteDouble( ofp,  *p_dbl);
               break;

            case SET_ACTIVE_SHADING_ACCURACY:
               p_u16 = (unsigned short *) data_ptr;
               fprintf (ofp, "shading_accuracy           : %d;\n", *p_u16);
               break;

            case SET_OBJECT_INFO:
               itemp = (IGRint *)data_ptr;

               HPglobal.objid = itemp[0];
               HPglobal.osnum = (IGRshort)itemp[1];
 
#              if defined (BIG_ENDIAN)
               HSconv_int  ( &HPglobal.objid, 1 );
               HSconv_short( &HPglobal.osnum, 1 );
#              endif

               fprintf( ofp, "objid_osnum                : %1d %1d\n",
                  HPglobal.objid, HPglobal.osnum );
               break;

            case SET_ACTIVE_PHONG_ATTRIBUTES:
               fprintf( ofp, "phong_attributes\n" );
               fprintf( ofp, "  finish                   : %d\n", HPglobal.elem_finish );

               fprintf( ofp, "  specular reflection      : " );
               WriteDouble( ofp, HPglobal.elem_spec_refl );

               fprintf( ofp, "  diffuse reflection       : " );
               WriteDouble( ofp, HPglobal.elem_diff_refl );

               break;

            case SET_ACTIVE_FG_COLOR_INDEX:
               p_u16 = (unsigned short *) data_ptr;
               fprintf (ofp, "foreground_index           : %d\n", *p_u16);
               break;

            case SET_ACTIVE_LINE_STYLE:
               p_u16 = (unsigned short *) data_ptr;
               fprintf (ofp, "line_style                 : %d\n", *p_u16);
               break;

            case SET_ACTIVE_LINE_WIDTH:
               p_dbl = (double *) data_ptr;
               fprintf (ofp, "line_width                 : " );
               WriteDouble( ofp, *p_dbl);
               break;

            case SET_ACTIVE_RENDERING_MODE:
               u8 = *(unsigned char *) data_ptr & 7;
               fprintf (ofp, "rendering_mode             : ");
               switch (u8)
                  {
                  case 1:
                     fprintf (ofp, "z_buffered smooth shading");
                     break;

                  case 2:
                     fprintf (ofp, "z_buffered constant shading");
                     break;

                  case 3:
                     fprintf (ofp, "z_buffered raster hidden line");
                     break;

                  case 4:
                     fprintf (ofp, "z_buffered filled hidden line");
                     break;

                  case 5:
                     fprintf (ofp, "z_buffered area_fill");
                     break;

                  case 6:
                     fprintf (ofp, "z_buffered styled raster edges");
                     break;

                  case 7:
                     fprintf (ofp, "z_buffered show hidden edges");
                     break;

                  default:
                     fprintf (ofp, "wireframe");
                     break;
                     }

               fprintf (ofp, ";\n");
               break;

            case SET_ACTIVE_TRANSLUCENCY:
               fprintf (ofp, "translucency               : %d;\n", 
                 *(unsigned char *) data_ptr);
               break;

            case SET_VIEWPORT_TO_WLD_MATRIX:
               p_dbl = (IGRdouble *) data_ptr;
               fprintf (ofp, "viewport_to_wld            : \n");
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[0] );
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[4] );
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[8] );
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[12] );
               break;

            case SET_ACTIVE_ROTATION_MATRIX:
               p_dbl = (IGRdouble *) data_ptr;
               fprintf (ofp, "rotation                   : \n");
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[0] );
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[4] );
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[8] );
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[12] );
               break;

            case SET_ACTIVE_POST_ROTATION_MATRIX:
               p_dbl = (IGRdouble *) data_ptr;
               fprintf (ofp, "post_rotation              : \n");
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[0] );
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[4] );
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[8] );
               fprintf( ofp, "   " ); WriteDouble4( ofp, &p_dbl[12] );
               break;

            default:
               goto quit;
               }
         break;

      case PRIMITIVE_COMMAND:
         j2 = 1;
         switch (command[1])
            {
            case NURB_EDGE:
               fprintf (ofp, "edge\n");
               status = dump_curve (ofp, (struct HPnurb_curve_struct *)data_ptr, level, 3);
               if (status)
                  return HSplot_error;
               break;

            case NURB_CURVE:
               fprintf (ofp, "curve\n");
               status = dump_curve (ofp, (struct HPnurb_curve_struct *)data_ptr, level, 3);
               if (status)
                  return HSplot_error;
               break;

            case NURB_SURFACE_WITH_RANGE:
               status = dump_surface (ofp, (struct HPnurb_surface_struct *)data_ptr, level, range);
               if (status)
                  return HSplot_error;
               break;

            case NURB_SURFACE:
               status = dump_surface (ofp, (struct HPnurb_surface_struct *)data_ptr, level, NULL);
               if (status)
                  return HSplot_error;
               break;

            default:
               goto quit;
               }
         break;

         /* error -- unknown command type */
      default:
         goto quit;
         }

   fprintf( ofp, "\n" );

   return HSplot_success;

/* error exit */
quit:
   fprintf (stderr, "scanner unknown command %d:%d\n", command[0], command[1]);
   return HSplot_error;
   }
