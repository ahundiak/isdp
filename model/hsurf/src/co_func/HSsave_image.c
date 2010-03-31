 
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

/*--------------------------------------------------------------------------

      IMPORTANT NOTE:

           Make sure STANDALONE is set to 0 before compiling to make
           co_func.o  in co_func directory. This is the normal setting
           while making the hsurf libraries for EMS.

           If you want to make save_img.o as a standalone library to
           be delivered along with the hsurf libraries do the following.

            1. #define STANDALONE 1

            2. ln save_img.c ../solo/

            2. cd to solo directory

            3. makemake save_img.m makefile

            4. make

            5. #define STANDALONE back to 0 when finished.

-----------------------------------------------------------------------------*/

#define SAVE_10          0
#define SAVE_26          0
#define SAVE_29          1

#define STANDALONE       0

#define ECHO_WRITE       0
#define ECHO_WRITE2      0

/*
 * At this point, we use True Color on the edge II for Save Image.
 */
#define PTC_RGB_BITS     4
#define TRC_RGB_BITS     8

#if !STANDALONE
#include <math.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#endif

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "wl.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HStl_global.h"
#include "hskyoptypes.h"
#include "HSsara.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "HSpr_render.h"

/*
 * Need to include all needed structures before prototypes are included.
 */

#include "hsmachine.h"
#include "hsdef.h"

struct HSRLEvlt_slot
{
   unsigned long pixel;
   unsigned short red;
   unsigned short green;
   unsigned short blue;
   char flags;
   char pad;
};

#include "HSpr_co_func.h"

/*--------------------------*/


/*
 *  Prototype declaration for static functions
 */


/* HSsave_image.c */

static int HSwrite_line_in_rle29 (FILE *, int, char *);


#if SAVE_29
static char *scanline;

#endif

/*--- HSwrite_line_in_rle29 --------------------------------------------------*/

static int HSwrite_line_in_rle29 (FILE  *outfile,
                                  int   DispWidth,
                                  char  *Indices)

/*
NAME
      HSwrite_line_in_rle29

KEYWORD
      save_image

DESCRIPTION
      This function takes the color index values of a line of pixels, arranges
      them in a Run-length Encoding Scheme (type 29), and places this informa-
      tion into a file.

DEPENDENCIES
      'outfile' must be initialized as a unix file and open for writing.

PARAMETERS
      outfile (IN)   - Name of a unix file which should be open for writing.
      DispWidth (IN) - Number of pixels in one scanline.
      Indices (IN)   - Array of length DispWidth containing color table indices.

GLOBALS USED
      scanline (static)

RETURN VALUES
      Number of words to follow read from the header of the next scanline.

HISTORY
      10/19/89 Adapted from a version to write in type 27 rle format.
            -Trevor Mink
*/
{
   short  p = 0;
   short  Head;
   short  index;

#if SCANNABLE_29
   char   Garbage = (char) 0;
   int    Words;
#endif

#if ECHO_WRITE
   fprintf(stderr, "Within HSwrite_line_in_rle29\n");
   fprintf(stderr, "FILE = %d\tDispWidth = %d\n", outfile, DispWidth);
#endif

   index = 0;

   while (index < DispWidth)
   {

      /* Begin with the head of the atom. 'p' will then progress through     */
      /* the tail of the atom (the tail may be only one byte or up to 127    */
      /* bytes)                                                              */

      Head = p;

      /* Check for a run-length of at least three */
      if ( (index < DispWidth - 2) &&
           (Indices[index] == Indices[index + 1]) &&
           (Indices[index] == Indices[index + 2]) )
      {

         /* Use negative to indicate a run-length ( rather than a number of  */
         /* bytes to follow which each contain a shade )                     */

         scanline[p++] = -3;
         scanline[p] = Indices[index];
         index += 3;

#if ECHO_WRITE
         fprintf( stderr, "\nA run-length has begun\n");
         fprintf( stderr, "index = %d\n", index);
         fprintf( stderr, "scanline[Head] = %d\n", scanline[Head]);
         fprintf( stderr, "Indices[index] = %x\tIndices[index+1] = %x\n",
                  Indices[index], Indices[index + 1]);
#endif
         while ( (index < DispWidth) &&
                 (Indices[index] == Indices[index - 1]) &&
                 (scanline[Head] > MAX_NEGATIVE_RUN_LENGTH) )
         {
            /* Remember negative sign for run-length */
            (scanline[Head])--;
            index++;

#if ECHO_WRITE
            fprintf( stderr, "decrementing scanline[Head] to %d and index to %d\n",
                       scanline[Head], index);
#endif
         }
      }
      else
      {
         scanline[p++] = 1;
         scanline[p] = Indices[index++];
         
#if ECHO_WRITE
         fprintf( stderr, "\nDiffering shades are being collected\n");
         fprintf( stderr, "index = %d\tp = %d\n", index, p);
         fprintf( stderr, "scanline[p] = %d\n", scanline[p]);
         fprintf( stderr, "Indices[index] = %x\tIndices[index+1] = %x\t",
                  Indices[index], Indices[index + 1]);
         fprintf( stderr, "Indices[index+2] = %x\n", Indices[index + 2]);
#endif

         while ( (index < DispWidth) &&
               (!(Indices[index] == Indices[index + 1] &&
                Indices[index] == Indices[index + 2])) &&
                (scanline[Head] < MAX_SHADES_IN_TAIL) )
         {
            p++;
            scanline[p] = Indices[index];
            scanline[Head]++;
            index++;
         }
      }
      p++;   /* Start a new Atom */
   }
   fwrite (scanline, p, 1, outfile);

#if SCANNABLE_29
   /* Get Total bytes (p) in terms of words for writing Words-to-follow in   */
   /* the scanline header                                                    */
   Words = (p + 1) / 2 + 2;
#endif

#if ( SCANNABLE_29 & ECHO_WRITE )
   fprintf( stderr, "Total_bytes = %d\tWords to follow = %d\tHere is the rle info\n",
             p, Words);

   for (i = 0; i < p; i++)
   {
      fprintf( stderr, "%d ", scanline[i]);
   }

   fprintf( stderr, "\n");
#endif

#if SCANNABLE_29
   if (((int) (p / 2) * 2) != p)
   {
      /* Write a null pad byte if p is odd */
      fwrite (&Garbage, 1, 1, outfile);
   }
   return (Words);
#endif

}   /* HSwrite_line_in_rle29() */

/*--- HScapture_image --------------------------------------------------------*/

int HScapture_image (char            *file_name,
                     unsigned short  x1,
                     unsigned short  y1,
                     unsigned short  dx,
                     unsigned short  dy,
                     WLuint32        lwin_no,
                     WLuint32        context_no)

/*
NAME
      HScapture_image

KEYWORD
      save_image

DESCRIPTION
      This routine saves the raster data in a window or a fence and writes out
      type29 run length encoded raster data in the standard format described in
      SDN 84-007.

PARAMETERS
      file_name (IN)  - Name of the unix file in which the TYPE 29 raster data
                        will be saved. The usual file name conventions apply.
      x1,y1 (IN)      - Pixel coordinates of the upper left corner of the
                        window area to be saved relative to the window origin.
      dx,dy (IN)      - Number of rows and columns to save from the point
                        (x1,y1).
                        NOTE: For the TRUE COLOR case, these deltas will be 
                              switched so that dx means delta y on the screen 
                              and dy means delta x.
      lwin_no (IN)    - Environ V window number of the window to be saved.
      context_no (IN) - Current context number of the window to saved. 

GLOBALS USED
      none. (that I know of)

RETURN VALUES
      0 - Image was successfully saved.
      1 - Image not saved due to file open error.
      2 - Image not saved due to XGetImage failure.

HISTORY
      08/01/88 Created. -Kash J. Rangan
      10/19/89 Fixed documentation of parameters. -S.P. Rogers
      08/27/91 Added X functionality. -R. Druzynski
      04/28/92 Documented. -Trevor Mink
      02/??/93 Converted to WL/DL -R. Druzynski
      12/14/94 Changed orientation of saved Type 27 rgb files to upper left
               horizontal for plotting, I/Scan support -R. Druzynski
 */

{
   FILE                   *f_ptr = NULL;
   char                   *char_ptr;
   short                  wtf;
   int                    hdr89_off = 0;
   int                    i;
   int                    j;
   int                    status;
   struct TYPE_89_HEADER  hdr89;
   struct HEADER_BLOCK    hdr;
   unsigned short         *Red = NULL;
   unsigned short         *Green = NULL;
   unsigned short         *Blue = NULL;
   int                    x2 = 0;
   int                    MemSize = 0;
   int                    xlo = 0;
   int                    ylo = 0;
   int                    xhi;
   int                    yhi;
   unsigned char          *RGB;
   IGRint                 true_color = FALSE;
   unsigned short         temp;
   int                    calibrate_flag;
   long                   msg;
   short                  Red_Comp;
   short                  Green_Comp;
   short                  Blue_Comp;
   unsigned short         CompensatoryArray[256];

   struct WLraster_data   Image;
   int                    vlt_size;
   struct WLcontext_info  context_info;
   struct WLbounds        win_attr;
   struct WLbounds        dummy;  /* dummy variable for WLget_window_bounds */
                                  /* call                                   */

   struct WLcmap_entry    vlt[512];
   int                    pixel_size;
   
#if ( SAVE_10 | SAVE_26 )
   struct RLE_RECORD      rle;
#endif


   WLget_raster_size( lwin_no, 1, 1, &pixel_size);

   WLget_context_info( context_no, &context_info );

   if ( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      true_color = TRUE;
   }

   if (!true_color)
   {
      f_ptr = fopen (file_name, "w");
      if (f_ptr == NULL)
      {
#if STANDALONE
         fprintf( stderr, "Error Opening File: %s\n", file_name);
#else
         HSfile_error (1);
#endif
         return (1);
      }
   }

   WLget_number_of_color_cells( context_no, &vlt_size );

   /* need to initialize the color map for reading */
   for( i=0; i < 512; i++ )
   {
      vlt[i].slot = i;
   }
   
   WLread_cmap_entries( context_no, vlt_size, vlt );

   /* with the new WL conversion, we need to make sure the colortable size */
   /* will fit the headers standard colortable allotment of 256 slots      */
   if( vlt_size > 256 )
   {
      vlt_size = 256;
   }

   /* Setup type 27 rle for true color image to be saved */

   if (true_color)
   {
      /* Get window coordinates */
      
      WLget_window_bounds( lwin_no, &dummy, &win_attr );

      xlo = win_attr.x;
      xhi = xlo + win_attr.width;
      ylo = win_attr.y;
      yhi = ylo + win_attr.height;

      x2 = x1 + dx;
      MemSize = x2 - x1;

      HSinit_rle( pixel_size, dy, dx, file_name );

      Red = (unsigned short *) malloc (MemSize * sizeof (unsigned short));
      Green = (unsigned short *) malloc (MemSize * sizeof (unsigned short));
      Blue = (unsigned short *) malloc (MemSize * sizeof (unsigned short));

      for (i = 0; i < 256; i++)
      {
         CompensatoryArray[i] = HScolor_compensate (i << 8, 1) >> 8;
      }
   }
   else
   {
      /* write out the type29 header record */
      memset(&hdr, 0, sizeof( struct HEADER_BLOCK ));

      hdr.header_type_code = TYPE_09;
      hdr.wds_to_follow =  766;     /* distance to the next TYPE_89 header */
                                    /* record                              */
      hdr.gridfile_version = 3;
     /* Version 3 */

#if SAVE_10
      hdr.data_type_code = TYPE_10;
#endif

#if SAVE_26
      hdr.data_type_code = TYPE_26;
#endif

#if SAVE_29
      hdr.data_type_code = TYPE_29;
#endif

      hdr.app_type_code = 6;
      hdr.scanline_orient = 0x04;
      
#if ( SCANNABLE_29 & SAVE_29 ) | SAVE_10 | SAVE_26
      hdr.scannable_flag = 0x01;
#endif

#if SAVE_10
      hdr.data_type_modifier = 0;
#endif

#if SAVE_26
      hdr.data_type_modifier = DTM;
#endif

      hdr.view_origin_x = 0;
      hdr.view_origin_y = 0;
      hdr.view_origin_z = 0;

      hdr.num_cols = dx;
      hdr.num_rows = dy + 1;

      hdr.reserved5[105] = (unsigned short)context_info.base_depth;
      hdr.reserved5[108] = x1;
      hdr.reserved5[109] = y1;

      hdr.color_table_type = 1;
      hdr.num_ctbl_entries = vlt_size;

      for (i = 0; i < vlt_size; i++)
      {
#ifdef BIG_ENDIAN      /* need to access the correct character */
         char_ptr = (char *)(&vlt[i].red);
         hdr.ctbl[i][0] = char_ptr[0];

         char_ptr = (char *)(&vlt[i].green);
         hdr.ctbl[i][1] = char_ptr[0];

         char_ptr = (char *)(&vlt[i].blue);
         hdr.ctbl[i][2] = char_ptr[0];
#else
         char_ptr = (char *)(&vlt[i].red);
         hdr.ctbl[i][0] = char_ptr[1];

         char_ptr = (char *)(&vlt[i].green);
         hdr.ctbl[i][1] = char_ptr[1];

         char_ptr = (char *)(&vlt[i].blue);
         hdr.ctbl[i][2] = char_ptr[1];
#endif  /* BIG_ENDIAN*/
      }

#if SAVE_26
      /* Determine the maximum run length from the DTM word in the header */
      /* DTM ( data type modifier ) specifies the field length of run and */
      /* value.  Rounding is done since pow function returns a double     */
         
      max_run = pow (2.0, (double)(hdr.data_type_modifier)) - 1.0 + 0.5;
#endif

#ifdef BIG_ENDIAN
      HSconvert_header (&hdr);
#endif

      status = fwrite(&hdr, sizeof(struct HEADER_BLOCK), 1, f_ptr);

      WLhide_cursor(lwin_no,0);
      WLflush(lwin_no);

#if SAVE_29
      /* Allocate memory for a line.  The worst case line size is the number  */
      /* of pixels in a scanline divided by 127 plus 1, giving the number of  */
      /* 127 bytes segments in the scanline, times 128 (127 shade pixels plus */
      /* the count). Also, add 8 for the 4 word header.                       */
          
      scanline = (char *) malloc ((((dx + 1) / 127) + 1) * 128 + 8);
#endif
   }      /* end else ('true_color' === FALSE) */


   /* create the raster image here to save on space - image & buffer can be  */
   /* reused and we save on function call time                               */

   WLcreate_raster_data( lwin_no,
                         context_no,
                         &Image,
                         x1,
                         y1,
                         dx,
                         1,
                         pixel_size * 8,
                         WL_SLOW_BUFFER,
                         NULL );
        
   for (j = 0; j < dy; ++j)
   {
      HSupdate_heartbeat ();

#if ( ( SAVE_29 & SCANNABLE_29 ) | SAVE_10 | SAVE_26 )
      if (!true_color)
      {
         /* write out header89 records for each scan line */
         hdr89.level_type = TYPE_89;
         hdr89.row = j + 1;
         hdr89.col = 0;
         hdr89_off = ftell(f_ptr);

#ifdef BIG_ENDIAN
         HSconvert_hdr89 (&hdr89);
#endif

         status = fwrite (&hdr89, sizeof (hdr89), 1, f_ptr);
      }
#endif
      /* update the image fields in the raster data to read the proper line */
      Image.y = y1 + j;

      WLget_raster_data( lwin_no, context_no, &Image );

#if ECHO_WRITE2
      fprintf( stderr, "file f_ptr is %d\n", f_ptr);
      fprintf( stderr, "geting line %d from %d to %d in at x = %d\n",
               j, ylo + y1, ylo + y1 + dx, xlo + j + x1);
      fprintf( stderr, "The buffer holds the following:\n");
#endif

      GRsetinqcolcal (&msg, 0, &calibrate_flag);
      if (true_color)
      {
         RGB = (unsigned char *)Image.buffer;
         if (calibrate_flag)
         {
            for (i = 0; i < x2 - x1; i++)
            {
#ifdef BIG_ENDIAN
               /* if big endian, need to get correct characters */
               RGB++;
               Blue_Comp   = (unsigned short)*RGB;
               RGB++;
               Green_Comp = (unsigned short)*RGB;
               RGB++;
               Red_Comp  = (unsigned short)*RGB;
               RGB++;
#else
               Red_Comp   = (unsigned short)*RGB;
               RGB++;
               Green_Comp = (unsigned short)*RGB;
               RGB++;
               Blue_Comp  = (unsigned short)*RGB;
               RGB++;
               RGB++;
#endif
               Red[i]   = CompensatoryArray[Red_Comp];
               Green[i] = CompensatoryArray[Green_Comp];
               Blue[i]  = CompensatoryArray[Blue_Comp];

#if ECHO_WRITE2
               fprintf(stderr, "Pixel %d is %d-%d-%d \n",
                        i, (int)(Red[i]), (int)(Green[i]), (int)(Blue[i]));
#endif
            }
         }
         else
         {
            for (i = 0; i < x2 - x1; i++)
            {
#ifdef BIG_ENDIAN
               /* if big_endian, need to get characters in reverse order. */
               RGB++;
               Blue[i]   = (unsigned short)*RGB;
               RGB++;
               Green[i] = (unsigned short)*RGB;
               RGB++;
               Red[i]  = (unsigned short)*RGB;
               RGB++;
#else
               Red[i]   = (unsigned short)*RGB;
               RGB++;
               Green[i] = (unsigned short)*RGB;
               RGB++;
               Blue[i]  = (unsigned short)*RGB;
               RGB++;
               RGB++;
#endif

#if ECHO_WRITE2
               fprintf(stderr, "Pixel %d is %d-%d-%d \n",
                        i, (int)(Red[i]), (int)(Green[i]), (int)(Blue[i]));
#endif
            }
         }
         HSwrite_line_in_rle27 (x1 + j, MemSize, Red, Green, Blue);

#if ECHO_WRITE2
         fprintf( stderr, "\n");
#endif
      }
      else
      {
#if SAVE_29
         wtf = HSwrite_line_in_rle29 (f_ptr, dx, Image.buffer);
#endif

#if ( SAVE_10 | SAVE_26 )
         old_value = Image.buffer[0];
         temp_len = 0;
         rle_count = 0;

         /* 'dx' means "delta y" for the TRUE COLOR case */
         for (i = 0; i <= (dx); i++)
         {
            value = Image.buffer[i];
            if (value != old_value)
            {
               rle.color_shade = 0;
               /* write an rle record when the pixel value changes */
#endif

#if SAVE_10
               rle.run_length = temp_len;
               *char_ptr = old_value;
               status = fwrite (&rle, sizeof (rle), 1, f_ptr);
               old_value = value;
               temp_len = 1;
               rle_count++;
#endif

#if SAVE_26
               if (temp_len <= max_run)
               {
                  rle.color_shade = temp_len << (16 - DTM);
                  *char_ptr = old_value;
                  status = fwrite (&rle, sizeof(short), 1, f_ptr);
                  rle_count++;
                  temp_len = 1;
                  old_value = value;
               }
               else
               {
                  *char_ptr = old_value;
                  status = fwrite (&rle, sizeof(short), 1, f_ptr);
                  rle_count++;
                  rle.color_shade = temp_len;
                  status = fwrite (&rle, sizeof(short), 1, f_ptr);
                  rle_count++;
                  old_value = value;
                  temp_len = 1;
               }
#endif
#if ( SAVE_10 | SAVE_26 )
            }
            else
               ++temp_len;

         }      /* end of i for loop */

         /* account for the last remaining pixels in a given row that */
         /* may not have changed value in the current scan line       */
#endif
#if SAVE_10
         rle.run_length = temp_len;
         *char_ptr = old_value;
         status = fwrite (&rle, sizeof(rle), 1, f_ptr);
         rle_count++;
         wtf = rle_count * 2 + 2;
#endif
#if SAVE_26
         if (temp_len <= max_run)
         {
            rle.color_shade = temp_len << (16 - DTM);
            *char_ptr = old_value;
            status = fwrite (&rle, sizeof(short), 1, f_ptr);
            rle_count++;
         }
         else
         {
            rle.color_shade = 0;
            *char_ptr = old_value;
            status = fwrite (&rle, sizeof(short), 1, f_ptr);
            rle_count++;
            rle.color_shade = temp_len;
            status = fwrite (&rle, sizeof(short), 1, f_ptr);
            rle_count++;
         }
         wtf = rle_count + 2;
#endif
      }   /* end of else */

#if ( ( SAVE_29 & SCANNABLE_29 ) | SAVE_10 | SAVE_26 )
      if (!true_color)
      {
         /* step back in file to write wtf in TYPE_89 record and reset    */
         /* the file ptr back to the end of file. This has to be done     */
         /* because number of rle records is not known in advance at the  */
         /* time type89 header was written                                */
         fseek(f_ptr, (long)(hdr89_off + 2), 0);

#ifdef BIG_ENDIAN
         HSconv_short(&wtf, 1);
#endif
         status = fwrite(&wtf, 2, 1, f_ptr);
         fseek(f_ptr, 0, 2);
      }
#endif
   }      /* end of j for loop */

   /* need to free the raster data created at beginning of the loop */
   WLfree_raster_data( &Image);

   if (true_color)
   {
      HSfini_rle(0, 0, 0);   /* Close the output file */
   }
   else
   {
#if SAVE_29
      free(scanline);
#endif
      fclose(f_ptr);
   }

   WLshow_cursor(lwin_no);
   WLflush(lwin_no);

   return (0);

}   /* HScapture_image */
