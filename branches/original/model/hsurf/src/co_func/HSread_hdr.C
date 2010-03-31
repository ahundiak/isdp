/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <FI.h>

#include "wl.h"

#include "exsysdep.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "hsmacdef.h"
#include "msmacros.h"
#include "msdef.h"
#include "exmacros.h"
#include "exdef.h"

#include "hsmessage.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "hsmachine.h"
#include "hskyoptypes.h"
#include "HSsara.h"

#define MAX_DIM                5461

#define MESSAGE_STRIP_HEIGHT   54

/*
 * Prototype files must be included after all structures are defined.
 */

struct RLEvlt_slot
{
   unsigned long pixel;
   unsigned short red;
   unsigned short green;
   unsigned short blue;
   char flags;
   char pad;
};

struct envV_vlt_slot
{
   unsigned short v_slot;
   unsigned short v_red;
   unsigned short v_green;
   unsigned short v_blue;
};

#include "HSpr_co_func.h"

static char file_o_files[132] = "\0";

#define ECHO_READ    0
#define SCALE_DOWN   0
#define SCALE_UP     1

#define DEBUG        0

#define USE_FILES_CT 0
#define USE_WIN_CT   1

#define IGDS         1
#define ENV_V        2


/*--- HSalter_vlt ------------------------------------------------------------*/

void HSalter_vlt ( WLuint32            context_no,
                   struct WLcmap_entry *cmap,
                   int                 cmap_siz )
/*
NAME
      HSalter_vlt

KEYWORD
      animate

DESCRIPTION
      This function sets up the vlt for an indexed rle file to be displayed
      based upon the color table stored in the header of the file

PARAMETERS
      context_no (IN) - context number
      cmap (IN)       - Color table to load
      cmap_size (IN)  - Number of colors in the table

GLOBALS USED
      none

RETURN VALUES
      none

HISTORY
      --/--/-- Created. -???
      04/29/92 Documented. -Trevor Mink

      02/04/93 WL converted.  - M. Lanier

*/
{
   int                  depth;
   int                  cmap2_siz;
   int                  i;
   struct WLcmap_entry  cmap2[512];

   for(i = 0; i<512; i++ )
   {
      cmap[i].slot =i;
   }

   if( WLget_context_depth( context_no, &depth ) == WL_SUCCESS )
   {
      WLget_number_of_color_cells( context_no, &cmap2_siz );

      if( WLread_cmap_entries( context_no, cmap2_siz, cmap2 ) == WL_SUCCESS )
      {
         if( cmap_siz > cmap2_siz )
         {
            cmap_siz = cmap2_siz;
         }

         for( i=0; i<cmap_siz; i++)
         {
            cmap2[i].red   = cmap[i].red;
            cmap2[i].green = cmap[i].green;
            cmap2[i].blue  = cmap[i].blue;
            cmap2[i].flags = cmap[i].flags;
         }

         WLload_cmap_entries( context_no, cmap2_siz, cmap2 );
      }
   }
}   /* HSalter_vlt */

/*--- HSread_rle_header ------------------------------------------------------*/

int HSread_rle_header (char                 *name,
                       char                 *file_o_files,
                       WLuint32             context_no,
                       WLuint32             lwin_no,
                       int                  term_planes,
                       int                  *rle_type,
                       IGRboolean           *Scannable,
                       int                  *hdr_planes,
                       int                  fcount,
                       short                *data_type_modifier,
                       short                *wds_to_follow,
                       struct frame         *frames,
                       int                  scale,
                       int                  *ct_to_use,
                       struct WLcmap_entry  *cmap,
                       int                  *offset,
                       unsigned short       *orientation )

/*
NAME
      HSread_rle_header

DESCRIPTION
      This function reads the headers of all the RLE files specified and
      stores the information in the 'frames' array.

KEYWORD
      animate

PARAMETERS
      name (IN)               - String filename whose header will be read
      file_o_files (IN)       - String filename of file of files
      context_no (IN)         - window context number
      lwin_no (IN)            - logical window number
      term_planes (IN)        - Number of bit planes used for color on the
                                current machine
      rle_type (OUT)          - Type of run-length encoding (eg. 10, 15, 26,
                                27, 29)
      Scannable (OUT)         - Whether the raster file has a header at the
                                beginning of each scanline.
      hdr_planes (OUT)        - Number of bit planes used for color on the
                                machine where the file was created.
      fcount (IN)             - Number of the current frame being read
      data_type_modifier (IN) - ??
      wds_to_follow (OUT)     - 16 bit words left in the file
      frames (OUT)            - Structure containing data read from the header
      scale (IN)              - Power of 2 factor by which to scale file
      ct_to_use (IN)          - Colortable to use. If 0, use the file's color
                                table; if 1, use windows.  If file has more
                                planes than the machine can support, set to 1.
      cmap (OUT)              - If ct_to_use is TRUE, then the files color-
                                table is loaded in cmap
      offset(OUT)             - If ct_to_use is FALSE, then this is the offset
                                where the files colortable starts in the cmap.

GLOBALS USED
      none

RETURN VALUES
      0 - Success
      Non-zero - Various types of errors

HISTORY
      04/29/92 Documented. -Trevor Mink
      06/15/93 Added support for file colortable/window colortable toggle.
               - Bob Druzynski
      10/21/93 Added new header style fields to the function.  Also altered
               how EMS determines to use default (window) colortable.
               - Bob Druzynski
*/
{
   char                     message1[200];
   char                     title_msg[100];
   char                     ch;
   FILE                     *f_ptr;
   FILE                     *f_ptr15;
   struct WLcmap_entry      cmap2[512];
   struct RLEvlt_slot       vlt[512];
   struct envV_vlt_slot     color_entry;

   struct HEADER_BLOCK      hdr26;

   struct raster_header     *hdr15;
   int                      ii;
   int                      status;
   int                      size;
   int                      ZoomDirection;
   WLuint32                 flags = 0;
   WLuint16                 red;
   WLuint16                 green;
   WLuint16                 blue;
   int                      color_table_type;
   int                      term_ctbl_entries;
   int                      header_type;


   if (scale == 1)
   {
      ZoomDirection = SCALE_DOWN;
      scale = 4;
   }
   else if (scale == 2)
   {
      ZoomDirection = SCALE_DOWN;
      scale = 2;
   }
   else if (scale == 0)
   {
      ZoomDirection = SCALE_DOWN;
      scale = 8;
   }
   else
   {
      ZoomDirection = SCALE_UP;
      scale /= 4;
   }


   /* Do a validation on the file name before opening it  */
   /* Check to see if the wild card accidentally includes */
   /* directory names in the file specified by the user.  */

   ch = file_o_files[strlen (file_o_files) - 1];

   f_ptr = fopen (name, "r");
   if (f_ptr == NULL)
   {
      ex$message (msgnumb = HS_I_Directory,
                  type    = "%s",
                  var     = `name `,
                  buff    = message1);
      ex$message (msgnumb = HS_W_WarnTitle,
                  buff    = title_msg);

      FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                  title_msg, FI_RED, "swiss742", 36.0,
                  message1, FI_BLACK, "swiss742", 18.0,
                  FI_LEFT_JUSTIFIED, 40);

      if (ch != '~')
      {
         EX_rm (file_o_files);
      }
      return (1);
   }

   WLget_number_of_color_cells( context_no, &term_ctbl_entries );
   status = fread ( &hdr26, sizeof(struct HEADER_BLOCK), 1, f_ptr);

#ifdef BIG_ENDIAN
   HSconvert_header( &hdr26 );
#endif

#if DEBUG
   HSdump_rasterfile_header( &hdr26 );
#endif

   hdr15 = (struct raster_header *)&hdr26;

   frames->num_cols    = hdr26.num_cols;
   frames->num_rows    = hdr26.num_rows;
   frames->x_min       = 0;
   frames->y_min       = 0;

   *data_type_modifier = hdr26.data_type_modifier;
   *wds_to_follow      = hdr26.wds_to_follow;
   *Scannable          = hdr26.scannable_flag & 0x01;

   *orientation        = hdr26.scanline_orient;

   *hdr_planes         = hdr26.reserved5[105];
   frames->x_min       = hdr26.reserved5[108];
   frames->y_min       = hdr26.reserved5[109];
   frames->vlt_size    = hdr26.num_ctbl_entries;
   color_table_type    = hdr26.color_table_type;

   /* If header planes are "0" then set header planes equal to 8, the number */
   /* of term planes that equals the number of color entries in the color    */
   /* table.  With the new header standard adopted as of 10/20/92 by EMS,    */
   /* header planes may not be stored in the data by images saved with       */
   /* I/DESIGN.  We will now use number of colors in the vlt to determine    */
   /* display options.                                                       */
   if( *hdr_planes == 0)
   {
       *hdr_planes = 8;
   }

   if (ZoomDirection == SCALE_UP)
   {
      if( *orientation == UPPER_LEFT_HORIZONTAL )
      {
         frames->x_max = (frames->x_min + frames->num_cols) * scale - 1;
         frames->y_max = (frames->y_min + frames->num_rows) * scale - 1;
      }
      else
      {
         frames->y_max = (frames->y_min + frames->num_cols) * scale - 1;
         frames->x_max = (frames->x_min + frames->num_rows) * scale - 1;
      }
   }
   else
   {
      if( *orientation == UPPER_LEFT_HORIZONTAL )
      {
         frames->x_max = (frames->x_min + frames->num_cols) / scale - 1;
         frames->y_max = (frames->y_min + frames->num_rows) / scale - 1;
      }
      else
      {
         frames->y_max = (frames->x_min + frames->num_cols) / scale - 1;
         frames->x_max = (frames->y_min + frames->num_rows) / scale - 1;
      }
   }

   *rle_type = hdr26.data_type_code;
   header_type  = hdr26.header_type_code;

   if (( header_type != TYPE_09) ||
          (*rle_type != TYPE_29 && *rle_type != TYPE_26))
   {
      /* The header is neither type29 nor type26 format. */
      if ( *rle_type == TYPE_10)
      {
         /* The header is type 10 */
         *rle_type = TYPE_10;
      }
      else if ((hdr15->data_type == 15) && (hdr15->element_type == 2504))
      {
         /* The header is type 15 */
         *rle_type = TYPE_15;
         frames->num_cols = hdr15->width;
         frames->num_rows = hdr15->height;

         *hdr_planes = hdr15->planes;
         frames->x_min = hdr15->x_off;
         frames->y_min = hdr15->y_off;
         frames->x_max = hdr15->x_off + hdr15->width - 1;
         frames->y_max = hdr15->y_off + hdr15->height - 1;
         frames->vlt_size = hdr15->vlt_size;
      }
      else if ( *rle_type == TYPE_27)
      {
         /* The header is type 27 */
         if( *orientation == UPPER_LEFT_HORIZONTAL )
         {
            frames->x_max = hdr26.num_cols * scale - 1;
            frames->y_max = hdr26.num_rows * scale - 1;
         }
         else
         {
            frames->x_max = hdr26.num_rows * scale - 1;
            frames->y_max = hdr26.num_cols * scale - 1;
         }
      }
      else
      {
         /* Header reflects neither type26, type29, type27, type10, nor
          * type15 format */

         ex$message (msgnumb = HS_I_Not10Not15, type = "%s", var = `name `, buff = message1);
         ex$message (msgnumb = HS_W_WarnTitle, buff = title_msg);

         FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                     title_msg, FI_RED, "swiss742", 36.0,
                     message1, FI_BLACK, "swiss742", 18.0,
                     FI_LEFT_JUSTIFIED, 40);
         if (ch != '~')
            EX_rm (file_o_files);
         return (10);
      }
   }

   if ( ((frames->vlt_size > term_ctbl_entries) ||
         (*hdr_planes  > term_planes)) &&
         (*rle_type != TYPE_27) )
   {
      /* The number of colors stored in the file is more than the current    */
      /* workstation can support.   Default is to use the windows colortable */
      /* and translate.                                                      */

      *ct_to_use = USE_WIN_CT;
   }

   if ( *ct_to_use == USE_FILES_CT )
   {
      /* initialize the colormap to load window slot numbers */
      for( ii = 0; ii<512; ii++ )
      {
         cmap2[ii].slot = ii;
      }

      /* Read the first frame's vlt and load it into the hardware */
      if (fcount == 0)
      {
         if ((*rle_type == TYPE_10) ||
             (*rle_type == TYPE_26) ||
             (*rle_type == TYPE_29))
         {
#if DEBUG
            fprintf (stderr, "Number of planes in the header = %d\n",
                     hdr26.reserved5[105]);
            fprintf (stderr, "Number of planes in the terminal = %d\n",
                     term_planes);
#endif

            /* determine number of color entries in the colormap and load */
            WLread_cmap_entries( context_no, term_ctbl_entries, cmap2 );

            /* determine the offset of the start of the colortable to load */

/*
            HSdetermine_offset( frames->vlt_size,
                                term_ctbl_entries,
                                color_table_type,
                                offset );
*/
            if( color_table_type == ENV_V )
            {
               /* if a environ_V colortable is stored, set file pointer to */
               /* beginning of third header block                          */
               fseek( f_ptr, 1024, SEEK_SET );
            }

            for( ii = 0; ii < frames->vlt_size; ii++ )
            {
               if( color_table_type == IGDS )
               {
                  /* load the colors in hdr26.ctbl[ii] into */
                  /*  cmap2[ii + *offset]                   */
                  cmap2[ii + *offset].slot  = ii + *offset;
                  cmap2[ii + *offset].red   = hdr26.ctbl[ii][0] << 8;
                  cmap2[ii + *offset].green = hdr26.ctbl[ii][1] << 8;
                  cmap2[ii + *offset].blue  = hdr26.ctbl[ii][2] << 8;
                  cmap2[ii + *offset].flags = flags;
               }
               else
               {
                  fread( &color_entry, sizeof(struct envV_vlt_slot), 1, f_ptr);

                  cmap2[ii + *offset].slot  = color_entry.v_slot + *offset;
                  cmap2[ii + *offset].red   = color_entry.v_red;
                  cmap2[ii + *offset].green = color_entry.v_green;
                  cmap2[ii + *offset].blue  = color_entry.v_blue;
                  cmap2[ii + *offset].flags = flags;

                  if( *hdr_planes == 0)
                  {
                     *hdr_planes = term_planes;
                  }
               }
            }
            WLload_cmap_entries( context_no, term_ctbl_entries, cmap2 );
         }
         else if (*rle_type == TYPE_15)
         {
            f_ptr15 = fopen (name, "r");
            if (f_ptr15 == NULL)
            {
               ex$message (msgnumb = HS_I_Directory,
                           type = "%s",
                           var = `name `,
                           buff = message1);
               ex$message (msgnumb = HS_W_WarnTitle,
                           buff = title_msg);

               FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                           title_msg, FI_RED, "swiss742", 36.0,
                           message1, FI_BLACK, "swiss742", 18.0,
                           FI_LEFT_JUSTIFIED, 40);
               if (ch != '~')
                  EX_rm (file_o_files);
               return (1);
            }

            fseek (f_ptr15, 768, 0);
            status = fread (vlt,  hdr15->vlt_size * sizeof(struct RLEvlt_slot),
                            1, f_ptr15);

            for( ii=0; ii<hdr15->vlt_size; ii++ )
            {
               cmap2[ii].slot  = ii;
               cmap2[ii].red   = vlt[ii].red;
               cmap2[ii].green = vlt[ii].green;
               cmap2[ii].blue  = vlt[ii].blue;
               cmap2[ii].flags = vlt[ii].flags;
            }

            HSalter_vlt (context_no, cmap2, (int) hdr15->vlt_size);
            fclose (f_ptr15);
         }   /* load ctbl for type15 */
      }      /* end: if ( fcount == 0 ) */
   }         /* end: if ( ct_to_use == 0 ) */
   else
   {
      /* Read the first frames vlt and load it into cmap, to be used later */
      /* for translation purposes                                          */

      /* initialize the colormaps to load window slot numbers */
      for( ii = 0; ii<512; ii++ )
      {
         cmap2[ii].slot = ii;
         cmap[ii].slot = ii;
      }

      if (fcount == 0)
      {
         if ((*rle_type == TYPE_10) ||
             (*rle_type == TYPE_26) ||
             (*rle_type == TYPE_29))
         {
#if DEBUG
            fprintf (stderr, "Number of planes in the header = %d\n",
                     *hdr_planes);
            fprintf (stderr, "Number of planes in the terminal = %d\n",
                     term_planes);
#endif
            if( color_table_type == ENV_V )
            {
               /* if a environ_V colortable is stored, set file pointer to */
               /* beginning of third header block                          */

               fseek( f_ptr, 1024, SEEK_SET );
            }

            /* read file's colormap into cmap */
            if( color_table_type == IGDS )
            {
               for( ii = 0; ii < frames->vlt_size; ii++ )
               {
                  cmap[ii].slot = ii;

                  /* We need to uncompensate the colors stored in the header's*/
                  /* colortable to make sure the colors are the closest match */
                  /* they can be when translating the file colors to the      */
                  /* window colors.                                           */

                  red   = hdr26.ctbl[ii][0] << 8;
                  green = hdr26.ctbl[ii][1] << 8;
                  blue  = hdr26.ctbl[ii][2] << 8;

                  red = (WLuint16)HScolor_compensate( (int)red, 1);
                  green = (WLuint16)HScolor_compensate( (int)green, 1);
                  blue = (WLuint16)HScolor_compensate( (int)blue, 1);

                  cmap[ii].red = red;
                  cmap[ii].green = green;
                  cmap[ii].blue = blue;
                  cmap[ii].flags = 0;
               }
            }
            else
            {
               for( ii = 0; ii < frames->vlt_size; ii++)
               {
                  fread( &color_entry, sizeof(struct envV_vlt_slot), 1, f_ptr);

                  /* We need to uncompensate the colors stored in the header's*/
                  /* colortable to make sure the colors are the closest match */
                  /* they can be when translating the file colors to the      */
                  /* window colors.                                           */

                  red   = color_entry.v_red;
                  green = color_entry.v_green;
                  blue  = color_entry.v_blue;

                  red = (WLuint16)HScolor_compensate( (int)red, 1);
                  green = (WLuint16)HScolor_compensate( (int)green, 1);
                  blue = (WLuint16)HScolor_compensate( (int)blue, 1);

                  cmap[ii].red   = red;
                  cmap[ii].green = green;
                  cmap[ii].blue  = blue;
                  cmap[ii].flags = 0;

               }
            }
            WLget_number_of_color_cells( context_no, &size );
            WLread_cmap_entries( context_no, size, cmap2 );
         }
         else if (*rle_type == TYPE_15)
         {
            f_ptr15 = fopen (name, "r");
            if (f_ptr15 == NULL)
            {
               ex$message (msgnumb = HS_I_Directory,
                           type = "%s",
                           var = `name `,
                           buff = message1);
               ex$message (msgnumb = HS_W_WarnTitle,
                           buff = title_msg);

               FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                           title_msg, FI_RED, "swiss742", 36.0,
                           message1, FI_BLACK, "swiss742", 18.0,
                           FI_LEFT_JUSTIFIED, 40);
               if (ch != '~')
                  EX_rm (file_o_files);
               return (1);
            }

            fseek (f_ptr15, 768, 0);
            status = fread (vlt,  hdr15->vlt_size * sizeof(struct RLEvlt_slot),
                            1, f_ptr15);

            for( ii = 0; ii < hdr15->vlt_size; ii++ )
            {
               /* We need to uncompensate the colors stored in the header's */
               /* colortable to make sure the colors are the closest match  */
               /* they can be when translating the file colors to the       */
               /* window colors.                                            */
               red = vlt[ii].red;
               green = vlt[ii].green;
               blue = vlt[ii].blue;

               red = (WLuint16)HScolor_compensate( (int)red, 1);
               green = (WLuint16)HScolor_compensate( (int)green, 1);
               blue = (WLuint16)HScolor_compensate( (int)blue, 1);

               cmap[ii].red   = vlt[ii].red;
               cmap[ii].green = vlt[ii].green;
               cmap[ii].blue  = vlt[ii].blue;
               cmap[ii].flags = vlt[ii].flags;
               cmap[ii].slot  = ii;
            }

            fclose (f_ptr15);
         }   /* load ctbl for type15 */
      }      /* end: if ( fcount == 0 ) */
   }         /* end else                */

   fclose (f_ptr);
   return (0);
}   /* HSread_rle_header */

/*--- HSget_num_frames -------------------------------------------------------*/

/*
NAME
      HSget_num_frames

KEYWORD
      animate

DESCRIPTION
      This function opens the given 'filename'(s) (Wildcard(s) may be included
      and it may be a file containing filenames) and returns the number of
      frames represented.

PARAMETERS
      filename (IN) - Filename input by the user (Potentially w/wildcards
            and/or tilde

GLOBALS USED
      none

RETURN VALUES
      Number of files to be displayed/animated

HISTORY
      09/24/90 Created. -Trevor Mink
*/

int HSget_num_frames (char *filename)

{
   char ch;
   char name[132];
   int  len;
   int  test;
   int  status;
   int  num_files = 1;
   FILE *name_file_ptr;

   len = strlen (filename);
   test = strspn ("*", filename);

   if (test != 0)
   {
      ch = '*';
   }
   else
   {
      ch = filename[len - 1];
   }

   /* Check for multiple files (wildcard or file-of-files used) */
   if (test || filename[len - 1] == '~')
   {
      status = HSget_file_o_files (filename, &name_file_ptr, file_o_files);

      for(num_files = -1; status != EOF; num_files++)
      {
         status = fscanf(name_file_ptr, "%s\n", name);
      }
      fclose(name_file_ptr);

      if (ch != '~')
      {
         EX_rm(file_o_files);
      }
   }
   return (num_files);

}   /* HSget_num_frames */

/*--------------------------------------------------------------------------*/

/*
NAME
      HSinq_phong_file

KEYWORD
      animate

DESCRIPTION
      This function determines if any of the RLE files that are to be re-
      called are Phong files (i.e., from Create Rendering).  If there is a
      mix of phong an error message is displayed

PARAMETERS
      file_name (IN)          - Filename input by the user (Potentially
                                w/wildcards and/or tilde)
      phong_flag (OUT)        - Boolean indicating type 27
      x_pixels,y_pixels (OUT) - Width and height of file in pixels

GLOBALS USED
      none

RETURN VALUES
      0 - Okay
      1 - Bad directory/filename specified
      2 - Type 27 and non-type27 files are mixed

HISTORY
      04/29/92 Documented. -Trevor Mink
*/

int HSinq_phong_file (char file_name[],
                      int  *phong_flag,
                      int  *x_pixels,
                      int  *y_pixels)

{
   char                name[132];
   char                message1[200];
   char                title_msg[100];
   char                ch;
   short               non_phong_found;
   short               phong_found;
   short               first_phong;
   int                 len;
   int                 test;
   int                 status;
   int                 status2;
   int                 fcount;
   int                 ret_code;
   int                 max_x_pixels;
   int                 max_y_pixels;
   FILE                *name_file_ptr;
   FILE                *f_ptr;
   struct HEADER_BLOCK hdr;

   ret_code = 0;
   fcount = -1;

   max_x_pixels = MAX_DIM;
   max_y_pixels = MAX_DIM;

   non_phong_found = FALSE;
   phong_found = FALSE;
   first_phong = TRUE;

   len = strlen (file_name);
   test = strspn ("*", file_name);

   if (test != 0)
   {
      ch = '*';
   }
   else
   {
      ch = file_name[len - 1];
   }

   status = HSget_file_o_files (file_name, &name_file_ptr, file_o_files);

   if (status == 1)
   {
      ex$message (msgnumb = HS_I_Directory,
                  type    = "%s",
                  var     = `file_name `,
                  buff    = message1);
      ex$message (msgnumb = HS_W_WarnTitle,
                  buff    = title_msg);

      FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                  title_msg, FI_RED, "swiss742", 36.0,
                  message1, FI_BLACK, "swiss742", 18.0,
                  FI_LEFT_JUSTIFIED, 40);

      non_phong_found = FALSE;
      phong_found = FALSE;
      first_phong = TRUE;

      ret_code = 1;
   }
   else
   {
      status2 = fscanf (name_file_ptr, "%s\n", name);

      do
      {
         fcount++;

         /* The following check is made again to guard against any  character */
         /* being appended to the end of the file name read from file of      */
         /* files. This might happen if the raster file mode was set as       */
         /* executable due to the the behavior of ls function. If an asterisk */
         /* is detected at the end of the file it is simply stripped at this  */
         /*  point. This will only truncate the last character.               */

         len = strlen (name);
         if (name[len - 1] == '*')
         {
            name[len - 1] = '\0';
         }

         /* Do a validation on the file name before opening it */
         /* Check to see if the wild card accidentally includes */
         /* directory names in the file specified by the user. */

         if (fcount == MAX_FILES)
         {
            HSfile_error (7);
            status2 = EOF;
            fcount--;
         }
         else
         {
            f_ptr = fopen (name, "r");
            if (f_ptr == NULL)
            {
               ex$message (msgnumb = HS_I_Directory,
                           type    = "%s",
                           var     = `name `,
                           buff    = message1);
               ex$message (msgnumb = HS_W_WarnTitle,
                           buff    = title_msg);
               FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                           title_msg, FI_RED, "swiss742", 36.0,
                           message1, FI_BLACK, "swiss742", 18.0,
                           FI_LEFT_JUSTIFIED, 40);

               ret_code = 1;
               status2 = EOF;
            }
            else
            {
               status = fread (&hdr, sizeof (struct HEADER_BLOCK), 1, f_ptr);
#ifdef BIG_ENDIAN
               HSconvert_header(&hdr);
#endif
               if ((hdr.header_type_code != TYPE_09) ||
                   (hdr.data_type_code != TYPE_27))
               {
                  non_phong_found = TRUE;
               }
               else
               {
                  phong_found = TRUE;
                  if ((hdr.num_rows > max_x_pixels) ||
                      (hdr.num_cols > max_y_pixels))
                  {
                     ex$message (msgnumb = HS_I_RendFileTooBig,
                                 type    = "%s",
                                 var     = `name `,
                                 buff    = message1);
                     ex$message (msgnumb = HS_W_WarnTitle,
                                 buff    = title_msg);
                     FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                              title_msg, FI_RED, "swiss742", 36.0,
                              message1, FI_BLACK, "swiss742", 18.0,
                                 FI_LEFT_JUSTIFIED, 40);

                     ret_code = 2;
                     status2 = EOF;
                  }
                  else if (first_phong)
                  {
                     *y_pixels = hdr.num_cols;
                     *x_pixels = hdr.num_rows;
                     first_phong = FALSE;
                  }
               }

               fclose (f_ptr);

               /* get the next name */
               status2 = fscanf (name_file_ptr, "%s\n", name);

            }   /* end: else */
         }      /* end: else */
      }         /* end: do (fcount ... */
      while (status2 != EOF);

      if (ret_code == 0)
      {
         if (phong_found && non_phong_found)
         {
            ex$message (msgnumb = HS_I_RenderMixup,
                        buff    = message1);
            ex$message (msgnumb = HS_W_WarnTitle,
                        buff    = title_msg);
            FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                        title_msg, FI_RED, "swiss742", 36.0,
                        message1, FI_BLACK, "swiss742", 18.0,
                        FI_LEFT_JUSTIFIED, 40);

            ret_code = 2;
         }
         else if (phong_found)
         {
            *phong_flag = TYPE_27;
         }
         else
         {
            *phong_flag = 0;
         }
      }

      fclose (name_file_ptr);
      if (ch != '~')
      {
         EX_rm (file_o_files);
      }
   }      /* end: else */

   return (ret_code);

}   /* HSinq_phong_file */

/*----------------------------------------------------------------------------*/

/*
NAME
      HSdetermine_offset

KEYWORD
      animate

DESCRIPTION
      This function determines the offset needed when loading a file's
      colortable into a window's colortable.  The offset is determined by
      taking the file's depth to a power of 2 and the window's depth to a
      power of 2, and subtracting the files result from the windows.

      i.e.  files depth = 5
            window depth = 8

            1 << 5 = 32
            1 << 8 = 256

            256 - 32 = 224  so offset is 224 and this is the slot where the
            file's color table will be loaded (from 224 to 256).

PARAMETERS
      file_planes (IN)   -  Number of planes the file has stored.
      term_planes (IN)   -  Number of planes the window uses for color.
      offset      (OUT)  -  the offset of the colortable.

GLOBALS USED
      none

RETURN VALUES
      none

HISTORY
      06/10/93  Created - Bob Druzynski
      10/21/93  Added case where file_planes = 0.  Files saved or translated
                outside of EMS do not use this field.  - Bob Druzynski
*/

void HSdetermine_offset ( int file_ctbl_entries,
                          int term_ctbl_entries,
                          int ctbl_type,
                          int *offset )

{
   if( ctbl_type == IGDS )
   {
      *offset = term_ctbl_entries - file_ctbl_entries;
      if( (*offset < 0) || (*offset > 511))
      {
         *offset = 0;
      }
   }
   else
   {
      *offset = term_ctbl_entries - file_ctbl_entries + 1;

      if( (*offset < 0) || (*offset > 511))
      {
         *offset = 1;
      }
   }
}
