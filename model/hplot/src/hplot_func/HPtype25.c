#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "exsysdep.h"
#include "HStl_window.h"
#include "HPglobal.h"
#include "HPdef.h"
#include "hpmsg.h"
#include "HPmacros.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"

/*------------------------------
 *  for function
 *     HSconv_double
 *     HSconv_int
 *     HSconv_short
 */

#include "HSrle.h"
#include "hsanimate.h"
#include "HSpr_rle_uti.h"

/*------------------------------*/

#define TYPE_09		0x0908


/*
NAME
   HPcreate_hdr
        
KEYWORDS
   HSplot
   rasterfile
        
DESCRIPTION
   Create a header block for the output rasterfile
        
PARAMETERS
   file_des	:(IN) :  File pointer to the rasterfile
   rle_type	:(IN) :  The RLE type code
        
GLOBALS USED
   HPglobal	: global structure
      xdits,	: The y/x dit size of the viewport
      ydits	:
   active_window	: global structure
      x_dits	: height of the viewport
                
FUNCTIONS CALLED
   memset
   HSconv_short (Sun only)
   HSconv_double (Sun only)
   HSconv_int (Sun only)

HISTORY
   ??/??/??	M. Lanier
      Created
*/

void HPcreate_hdr (FILE * file_des,
                   IGRint rle_type)

   {
   struct HEADER_BLOCK hdr;

   memset (&hdr, 0, sizeof (hdr));

   /* Write out the header record. */
   hdr.header_type_code = TYPE_09;
   hdr.wds_to_follow = 0x1fe;
   hdr.data_type_code = rle_type;
   hdr.app_type_code = 6;       /* ??? - code of application creating the
                                 * raster file */
   hdr.view_origin_x = 0;
   hdr.view_origin_y = 0;
   hdr.view_origin_z = 0;

   hdr.num_cols = HPglobal.ydits;
   hdr.num_rows = HPglobal.xdits;
   hdr.num_cols = active_window->x_dits - 1;

   hdr.scanline_orient = 0x04;
   hdr.scannable_flag = rle_type == 25;

   hdr.gridfile_version = 0;    /* ??? 2 is the "latest" version of the Oct.
                                 * 12 SDN. The latest in the Nov. 1 SDN is 3.
                                 * I do not know which version I should use.
                                 * KR did not set this field, so I assume it
                                 * defaulted to 0.  */

   /* hdr.junky[2]          = 0; */

#  ifdef BIG_ENDIAN
   HSconv_short ((short *) &hdr.header_type_code, 1);
   HSconv_short ((short *) &hdr.wds_to_follow, 1);
   HSconv_short ((short *) &hdr.data_type_code, 1);
   HSconv_short ((short *) &hdr.app_type_code, 1);
   HSconv_double ((double *) &hdr.view_origin_x, 1);
   HSconv_double ((double *) &hdr.view_origin_y, 1);
   HSconv_double ((double *) &hdr.view_origin_z, 1);
   HSconv_double ((double *) &hdr.view_extent_x, 1);
   HSconv_double ((double *) &hdr.view_extent_y, 1);
   HSconv_double ((double *) &hdr.view_extent_z, 1);
   HSconv_double ((double *) &hdr.transformation, 16);
   HSconv_int ((int *) &hdr.num_cols, 1);
   HSconv_int ((int *) &hdr.num_rows, 1);
   HSconv_short ((short *) &hdr.device_resolution, 1);
   HSconv_int ((int *) hdr.rotation_angle, 2);
   HSconv_int ((int *) hdr.skew_angle, 2);
   HSconv_short ((short *) &hdr.data_type_modifier, 1);
   HSconv_short ((short *) &hdr.reserved3, 1);
   HSconv_double ((double *) &hdr.aspect_ratio, 1);
   HSconv_int ((int *) &hdr.concat_file_ptr, 1);
   HSconv_short ((short *) &hdr.color_table_type, 1);
   HSconv_short ((short *) &hdr.reserved4, 1);
   HSconv_int ((int *) &hdr.num_ctbl_entries, 1);
   HSconv_int ((int *) &hdr.app_packet_pointer, 1);
   HSconv_int ((int *) &hdr.app_packet_length, 1);
#  endif

   FILE_WRITE (&hdr, 1, 0x400, file_des);
   }    /* HPcreate_hdr */

/*---HPcreate_PS_header--------------------------------------------*/

void   HPcreate_PS_header( FILE *fp )
   {
   fprintf( fp, "%%!PS-Adobe-2.0 EPSF-2.0\n" );
   fprintf( fp, "%%%%Title: %s\n", HPglobal.rasterfile );
   fprintf( fp, "%%%%Creator: Intergraph HSplot 3.4  10/21/97\n" );
   fprintf( fp, "%%%%BoundingBox: -47 218 662 573\n" );
   fprintf( fp, "%%%%Pages: 1\n" );
   fprintf( fp, "%%%%DocumentFonts:\n" );
   fprintf( fp, "%%%%EndComments\n" );
   fprintf( fp, "%%%%EndProlog\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "%%%%Page: 1 1\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "%% remember original state\n" );
   fprintf( fp, "/origstate save def\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "%% build a temporary dictionary\n" );
   fprintf( fp, "20 dict begin\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "%% define string to hold a scanline's worth of data\n" );
   fprintf( fp, "/pix %1d string def\n", HPglobal.ydits * 3 );
   fprintf( fp, "\n" );
   fprintf( fp, "%% define space for color conversions\n" );
   fprintf( fp, "/grays %1d string def  %% space for gray scale line\n", HPglobal.ydits );
   fprintf( fp, "/npixls 0 def\n" );
   fprintf( fp, "/rgbindx 0 def\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "%% lower left corner\n" );
   /*fprintf( fp, "-47 218 translate\n" );*/
   fprintf( fp, "0 0 translate\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "%% size of image (on paper, in 1/72inch coords)\n" );
   /*fprintf( fp, "708.98400 500.03200 scale\n" );*/
/*
   fprintf( fp, "%.3f %.3f scale\n", 
      (((double)(HPglobal.ydits))/(HPglobal.resolution/100.0)), 
      (((double)(HPglobal.xdits))/(HPglobal.resolution/100.0)) );
*/
   fprintf( fp, "%.3f %.3f scale\n", 
      (((double)(HPglobal.ydits))/(HPglobal.resolution/76.0)), 
      (((double)(HPglobal.xdits))/(HPglobal.resolution/76.0)) );
   fprintf( fp, "\n" );
   fprintf( fp, "%% define 'colorimage' if it isn't defined\n" );
   fprintf( fp, "%%   ('colortogray' and 'mergeprocs' come from xwd2ps\n" );
   fprintf( fp, "%%     via xgrab)\n" );
   fprintf( fp, "/colorimage where   %% do we know about 'colorimage'?\n" );
   fprintf( fp, "  { pop }           %% yes: pop off the 'dict' returned\n" );
   fprintf( fp, "  {                 %% no:  define one\n" );
   fprintf( fp, "    /colortogray {  %% define an RGB->I function\n" );
   fprintf( fp, "      /rgbdata exch store    %% call input 'rgbdata'\n" );
   fprintf( fp, "      rgbdata length 3 idiv\n" );
   fprintf( fp, "      /npixls exch store\n" );
   fprintf( fp, "      /rgbindx 0 store\n" );
   fprintf( fp, "      0 1 npixls 1 sub {\n" );
   fprintf( fp, "        grays exch\n" );
   fprintf( fp, "        rgbdata rgbindx       get 20 mul    %% Red\n" );
   fprintf( fp, "        rgbdata rgbindx 1 add get 32 mul    %% Green\n" );
   fprintf( fp, "        rgbdata rgbindx 2 add get 12 mul    %% Blue\n" );
   fprintf( fp, "        add add 64 idiv      %% I = .5G + .31R + .18B\n" );
   fprintf( fp, "        put\n" );
   fprintf( fp, "        /rgbindx rgbindx 3 add store\n" );
   fprintf( fp, "      } for\n" );
   fprintf( fp, "      grays 0 npixls getinterval\n" );
   fprintf( fp, "    } bind def\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "    %% Utility procedure for colorimage operator.\n" );
   fprintf( fp, "    %% This procedure takes two procedures off the\n" );
   fprintf( fp, "    %% stack and merges them into a single procedure.\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "    /mergeprocs { %% def\n" );
   fprintf( fp, "      dup length\n" );
   fprintf( fp, "      3 -1 roll\n" );
   fprintf( fp, "      dup\n" );
   fprintf( fp, "      length\n" );
   fprintf( fp, "      dup\n" );
   fprintf( fp, "      5 1 roll\n" );
   fprintf( fp, "      3 -1 roll\n" );
   fprintf( fp, "      add\n" );
   fprintf( fp, "      array cvx\n" );
   fprintf( fp, "      dup\n" );
   fprintf( fp, "      3 -1 roll\n" );
   fprintf( fp, "      0 exch\n" );
   fprintf( fp, "      putinterval\n" );
   fprintf( fp, "      dup\n" );
   fprintf( fp, "      4 2 roll\n" );
   fprintf( fp, "      putinterval\n" );
   fprintf( fp, "    } bind def\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "    /colorimage { %% def\n" );
   fprintf( fp, "      pop pop     %% remove 'false 3' operands\n" );
   fprintf( fp, "      {colortogray} mergeprocs\n" );
   fprintf( fp, "      image\n" );
   fprintf( fp, "    } bind def\n" );
   fprintf( fp, "  } ifelse          %% end of 'false' case\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "%1d %1d 8			%% dimensions of data\n", 
      HPglobal.ydits, HPglobal.xdits );
   fprintf( fp, "[%1d 0 0 -%1d 0 %1d]		%% mapping matrix\n",
      HPglobal.ydits, HPglobal.xdits, HPglobal.xdits );
   fprintf( fp, "{currentfile pix readhexstring pop}\n" );
   fprintf( fp, "false 3 colorimage\n" );
   fprintf( fp, "\n" );

   } /* HPcreate_PS_header */

/*---HPwrite_PS_tail--------------------------------------------*/

void   HPwrite_PS_tail( FILE *fp )
   {
   fprintf( fp, "\n" );
   fprintf( fp, "showpage\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "%% stop using temporary dictionary\n" );
   fprintf( fp, "end\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "%% restore original state\n" );
   fprintf( fp, "origstate restore\n" );
   fprintf( fp, "\n" );
   fprintf( fp, "%%%%Trailer\n" );

   } /* HPwrite_PS_tail */

