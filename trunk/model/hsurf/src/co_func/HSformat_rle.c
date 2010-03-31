/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/


#include <stdio.h>
#include <math.h>

#include "wl.h"

#include "OMminimum.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "exsysdep.h"

#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "HSpr_render.h"

#include "HSsara.h"
#include "HSrle.h"

#include "HSpr_co_func.h"

/*
 *  Prototype declaration for static functions
 */


#if defined (__)
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C"
   {
#endif

/* HSformat_rle.c */
   static void HSplace_line_in_buffer __ ((int             term_planes,
                                           int             height,
                                           int             width,
                                           int             scanline_number,
                                           char            *pixel_array,
                                           char            *buffer,
                                           short           true_color,
                                           unsigned short  orientation));

   static int HSread_line_from_rle_27 __ ((FILE           *infile,
                                           int            *ScanLine,
                                           int            Length,
                                           unsigned short *Red,
                                           unsigned short *Green,
                                           unsigned short *Blue));

   static void HSscale_and_index_line __ ((int            term_planes,
                                           int            x,
                                           int            Scale,
                                           unsigned short *Red,
                                           unsigned short *Green,
                                           unsigned short *Blue,
                                           char           *Pixels,
                                           char           *buffer,
                                           int            BegX,
                                           int            EndX,
                                           int            BegY,
                                           int            EndY,
                                           int            LineLength,
                                           short          true_color,
                                           unsigned short orientation));

   static void HSunscale_lines_type27 __ ((int            x,
                                           int            Scale,
                                           unsigned short *R[8],
                                           unsigned short *G[8],
                                           unsigned short *B[8],
                                           char           *buffer,
                                           int            term_planes,
                                           int            BegY,
                                           int            EndY,
                                           int            Width,
                                           int            LineLength,
                                           short          true_color,
                                           short          division_factor,
                                           unsigned short orientation));

   static int HSread_line_from_rle10 __ ((FILE *infile,
                                          char *Indices,
                                          int  cmap_offset));

   static int HSread_line_from_rle26 __ ((FILE           *infile,
                                          char           *Indices,
                                          unsigned short run_mask,
                                          unsigned short value_mask,
                                          int            cmap_offset));

   static int HSread_line_from_rle29 __ ((FILE       *infile,
                                          int        *ScanLine,
                                          int        Length,
                                          char       *Indices,
                                          IGRboolean Scannable,
                                          int        cmap_offset));

   static void HSscale_line __ ((int             y,
                                 int             Scale,
                                 char            *LineBuffer,
                                 char            *buffer,
                                 int             hdr_planes,
                                 int             term_planes,
                                 int             BegX,
                                 int             EndX,
                                 unsigned short  orient,
                                 int             line_width ));

   static void HSunscale_lines __ ((int             y,
                                    int             Scale,
                                    char            *LineBuffer[4],
                                    char            *buffer,
                                    int             hdr_planes,
                                    int             term_planes,
                                    int             BegX,
                                    int             EndX,
                                    unsigned short  orient ));

   static void HStranslate_line __(( struct WLcmap_entry *file_cmap,
                                     char                *indices,
                                     int                 length,
                                     int                 width ));

#if defined(__cplusplus)
   }

#endif


#undef __



#define ECHO_READ            0
#define ECHO_READ2           0
#define ECHO_SCALE           0
#define ECHO_UNSCALE         0
#define DEBUG                0

#define SCALE_ONE_EIGHTH     0
#define SCALE_ONE_FOURTH     1
#define SCALE_ONE_HALF       2
#define SCALE_NONE           4
#define SCALE_TWO_TIMES      8
#define SCALE_FOUR_TIMES     16

#define SCALE_UP             1
#define SCALE_DOWN           0

#define RIGHT_SIDE           1
#define LOWER                2
#define HORIZONTAL           4



static int                   xlo;
static int                   xhi;
static int                   ylo;
static int                   yhi;
static int                   LineByLine = FALSE;
static int                   x_0;
static int                   x_1;
static int                   y_0;
static int                   y_1;
static int                   bitmask;
static WLuint32              lwin_no;
static WLuint32              context_no = 0;
static int                   Current_x;
static int                   Current_y;

static struct WLraster_data  image;
static int                   first_putline = TRUE;

/*--- HStranspose ------------------------------------------------------------*/

/*---------------------------------------------
 *
 *  for XGL, I have to pass in pad_size, which is the depth
 *  of the raster data.  (Mike 1/11/96)
 *
 */

#if defined (XGL)
void HStranspose (char *buffer, int size, int pad_size)
#else
void HStranspose (char *buffer, int size)
#endif

/*
NAME
   HStranspose

KEYWORD
   animate

DESCRIPTION
   This function is used to transpose the data in the buffer so that when
   HSwl_put_line is called for vertical scanlines, the image data is "right
   side up". (Environ V  places a image from lower left corner to upper
   right corner of the display - bottom to top.  X places images from upper
   left to lower right corner - top to bottom.

PARAMETERS
   buffer (IN/OUT) - Contains pixel values before and after transposition
   size (IN) - Number of pixels for the scanline

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   03/24/92 Created. -R. Druzynski
*/
{
   int    i;
   int    j;
   int    pixel_size;
   char   temp1;
   short  temp2;
   long   temp3;

   /*----------------------------------------------------------
    *
    *  If XGL, then don't call WLget_raster_size.  This tell us
    *  the depth of the window, but not the depth of the data.
    *  get that from pad_size  I'm conditionally compiling
    *  this change because I don't want to mess with the code on
    *  the other platforms.  (Mike 1/11/96)
    *
    */

#  if defined (XGL)
   pixel_size = (pad_size-1)/8 + 1;
#  else
   WLget_raster_size( lwin_no, 1, 1, &pixel_size);
#  endif

   for (i = 0, j = 1; i < (size / 2); i++, j++)
   {
      if( pixel_size > 1)
      {
         if( pixel_size > 2)
         {
            temp3 = ((long *)buffer)[i];
            ((long *)buffer)[i] = ((long *)buffer)[size - j];
            ((long *)buffer)[size - j] = temp3;
         }
         else
         {
            temp2 = (short)buffer[i];
            ((short *)buffer)[i] = ((short *)buffer)[size - j];
            buffer[size - j] = temp2;
         }
      }
      else
      {
         temp1 = buffer[i];
         buffer[i] = buffer[size - j];
         buffer[size - j] = temp1;
      }
   }
}   /* HStranspose */

/*--- HSwl_put_line ------------------------------------------------------------*/

/*
NAME
   HSwl_put_line

KEYWORD
   animate

DESCRIPTION
   Display of line of rasterdata

PARAMETERS
   buffer (IN)      - Contains data to be displayed
   lwin_no (IN)     - Index of window to display line
   x_loc,y_loc (IN) - Beginning position of display in w_no
   size (IN)        - Number of pixels to display
   pad_size (IN)    - size of the pad for the values (8, 16, 32) (??)
   orientation (IN) - Vertical versus horizontal scanline

RETURN VALUES
   none

HISTORY
   08/05/91 Created. -R. Druzynski
   03/24/92 Added ability to place vertical as well as horizontal image
            lines to the screen. -R. Druzynski
*/

void HSwl_put_line ( char      *buffer,
                     WLuint32  lwin_no,
                     WLuint32  context_no,
                     int       x_loc,
                     int       y_loc,
                     int       size,
                     int       pad_size,
                     int       orientation )

{
   int                    sts;


   /*
      If this is the first putline call, we need to create the raster data
      structure to initialize it.  Otherwise, we just need to adjust the proper
      fields of the image structure.  This will save the thrashing of memory 
      and the cost of making many WLcreate_raster_data calls
   */
   if( first_putline )
   {
      if (orientation == UPPER_LEFT_HORIZONTAL)
      {
         sts = WLcreate_raster_data( lwin_no,
                                     context_no,
                                     &image,
                                     x_loc,
                                     y_loc,
                                     size - 1,
                                     1,
                                     pad_size,
                                     WL_SLOW_BUFFER,
                                     buffer );
      }
      else if( orientation == LOWER_LEFT_VERTICAL)
      {
         /*--------------------------------------------
          *
          *  if XGL, then we have to pass in pad_size so the
          *  function will know the depth of the data
          *
          */

#        if defined (XGL)
         HStranspose (buffer, size, pad_size);
#        else
         HStranspose (buffer, size);
#        endif

         sts = WLcreate_raster_data( lwin_no,
                                     context_no,
                                     &image,
                                     x_loc,
                                     y_loc,
                                     1,
                                     size - 1,
                                     pad_size,
                                     WL_SLOW_BUFFER,
                                     buffer );
      }
      else if( orientation == UPPER_LEFT_VERTICAL)
      { 
         sts = WLcreate_raster_data( lwin_no,
                                     context_no,
                                     &image,
                                     x_loc,
                                     y_loc,
                                     1,
                                     size - 1,
                                     pad_size,
                                     WL_SLOW_BUFFER,
                                     buffer );
      }
      first_putline = FALSE;
   }
   else
   {
      if (orientation == UPPER_LEFT_HORIZONTAL)
      {
         image.buffer = buffer;
         image.y = y_loc;
      }
      else if( orientation == LOWER_LEFT_VERTICAL)
      {
         /*--------------------------------------------
          *
          *  if XGL, then we have to pass in pad_size so the
          *  function will know the depth of the data
          *
          */

#        if defined (XGL)
         HStranspose (buffer, size, pad_size);
#        else
         HStranspose (buffer, size);
#        endif

         image.buffer = buffer;
         image.x = x_loc;
      }
      else if( orientation == UPPER_LEFT_VERTICAL)
      { 
         image.buffer = buffer;
         image.x = x_loc;
      }
   }

   sts = WLput_raster_data( lwin_no,
                            context_no,
                            &image );

}   /* HSwl_put_line */

/*--- HScleanup_putline ------------------------------------------------------*/

void HScleanup_putline( void )

/*
NAME
   HScleanup_putline

KEYWORD
   animate

DESCRIPTION
   This function is used to cleanup the the static variables used in the
   HSwl_put_line function when used by HSwrite_type27 for the Set Active 
   Shading Attributes command.

PARAMETERS
   none

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   10/21/94 Created. - Bob Druzynski
*/

{
   first_putline = TRUE;
   WLfree_raster_data( &image );
}


/*--- HSset_LineByLine_off ---------------------------------------------------*/

void HSset_LineByLine_off (void)

/*
NAME
   HSset_LineByLine_off

KEYWORD
   animate

DESCRIPTION
   This function sets the static necessary to execute buffered display
   rather than using the line-by-line method.

PARAMETERS
   none

GLOBALS USED
   LineByLine (static)

RETURN VALUES
   none

HISTORY
   07/04/90 Created. -Trevor Mink
*/

{
    LineByLine = FALSE;
}   /* HSset_LineByLine_off */

/*--- HSset_LineByLine_on ----------------------------------------------------*/

/*
NAME
   HSset_LineByLine_on

KEYWORD
   animate

DESCRIPTION
   This function set the statics necessary to execute line-by-line display
   rather than using the buffered method.

PARAMETERS
   Window (IN)              - Logical window number
   PlaneMask (IN)           - Mask indicating the planes available for display
   xMin,xMax,yMin,yMax (IN) - Upper left and lower right of image in window

GLOBALS USED
   x_0,y_0,x_1,y_1     - Upper left/Lower right x,y extents
   Current_x,Current_y - Self-explanatory
   xlo,ylo,xhi,yhi     - x,y extents of the window 'w_no'

RETURN VALUES
   none

HISTORY
   07/03/90 Created. -Trevor Mink
*/

void HSset_LineByLine_on ( WLuint32  Window,
                           WLuint32  ContextNumber,
                           int       PlaneMask,
                           int       xMin,
                           int       xMax,
                           int       yMin,
                           int       yMax)

{
   struct WLbounds    area_bounds;
   struct WLbounds    dummy; /* dummy variable for WLget_window_bounds call */


   LineByLine = TRUE;
   lwin_no    = Window;
   context_no = ContextNumber;
   bitmask    = PlaneMask;

#if DEBUG
   fprintf(stderr, "In HSset_LineByLine_on: x_0 = xMin = %d\n", xMin);
   fprintf(stderr, "In HSset_LineByLine_on: y_0 = yMin = %d\n", yMin);
   fprintf(stderr, "In HSset_LineByLine_on: x_1 = xMax = %d\n", xMax);
   fprintf(stderr, "In HSset_LineByLine_on: y_1 = yMax = %d\n", yMax);
#endif

   x_0 = xMin;
   x_1 = xMax;
   y_0 = yMin;
   y_1 = yMax;

   Current_x = x_0;
   Current_y = y_0;

   WLget_window_bounds( lwin_no, &dummy, &area_bounds );

   xhi = area_bounds.width;
   yhi = area_bounds.height;

   xlo = 0;
   ylo = 0;

}   /* HSset_LineByLine_on */

/*--- HSplace_line_in_buffer ------------------------------------------------*/

/*
NAME
   HSplace_line_in_buffer

KEYWORD
   animate

DESCRIPTION
   This function has to be called repeatedly for each vertical scan line
   to cover the entire window. Each scan line would be reformatted in
   'putpixelblock' format and a buffer would be built for later display
   using putblock function.

PARAMETERS
   term_planes (IN)     - number of bit planes on the window
   height (IN)          - Height of the buffer area in number of pixels
   width  (IN)          - Width of the buffer area in number of pixels
   scanline_number (IN) - The vertical scanline number starting at 0 for
                          the leftmost scanline
   pixel_array (IN)     - Pointer to an array of size at least equal to the
                          height of the window containing the pixel values from
                          bottom to top. The pixel_array[0] corresponds to the
                          bottom most pixel
   buffer (OUT)         - Contains all lines accumulated thus far
   true_color (IN)      - Flag indicating whether recall is being done on a
                          workstation that supports TRUE COLOR

GLOBALS USED
   Current_x, y_0, y_1 (statics)

RETURN VALUES
   none

HISTORY
   --/--/-- Created. -Trevor Mink
   04/29/92 Documented. -Trevor Mink
*/

static void HSplace_line_in_buffer (int             term_planes,
                                    int             height,
                                    int             width,
                                    int             scanline_number,
                                    char            *pixel_array,
                                    char            *buffer,
                                    short           true_color,
                                    unsigned short  orientation )

{
   int ii;
   int index;
   int y;
   int pixel_size;

#if DEBUG
   fprintf (stderr, "HSplace_line_in_buffer: height = %d\twidth = %d\t",
            height, width);
   fprintf (stderr, "\tscanline_number = %d\n", scanline_number);
#endif

   /*----------------------------------------------------------
    *
    *  If XGL, then don't call WLget_raster_size.  This tell us
    *  the depth of the window, but not the depth of the data.
    *  get that from true_color  I'm conditionally compiling
    *  this change because I don't want to mess with the code on
    *  the other platforms.  (Mike 1/11/96)
    *
    */

#  if defined (XGL)
   pixel_size = (true_color) ? 4 : 1;
#  else
   WLget_raster_size( lwin_no, 1, 1, &pixel_size );
#  endif

   if (LineByLine)
   {
      index = 0;
      for (ii = 0; ii < height; ii++, index++)
      {
         if (true_color)
         {
            ((long *)buffer)[index] = ((long *)pixel_array)[ii];
         }
         else if (term_planes == 9)        /* GX/GZ machine */
         {
            ((short *)buffer)[index] = ((short *)pixel_array)[ii];
         }
         else
         {
            buffer[index] = pixel_array[ii];
         }
      } /* end: for(ii... */

      if( orientation & HORIZONTAL )
      {
         HSwl_put_line( buffer,
                        lwin_no,
                        context_no,
                        x_0,
                        Current_y,
                        height,
                        pixel_size * 8,
                        orientation);
         Current_y++;
      }
      else
      {
         HSwl_put_line( buffer,
                        lwin_no,
                        context_no,
                        Current_x,
                        y_0,
                        height,
                        pixel_size * 8,
                        orientation);
         Current_x++;
      }
   }
   else
   {
      index = 0;
      y = height - 1;
      for (ii = 0; ii < height; ii++, y--)
      {
         index = y * width + scanline_number;
         if (true_color)
         {
            ((long *)buffer)[index] = ((long *)pixel_array)[ii];
         }
         else if (term_planes == 9)
         {
            /* GX/GZ machine */
            ((short *)buffer)[index] = ((short *)pixel_array)[ii];
         }
         else
         {
            buffer[index] = pixel_array[ii];
         }
      }   /* end: for ii */
   }      /* end: else   */
}   /* HSplace_line_in_buffer */

/*--- HSread_line_from_rle_27 -----------------------------------------------------------*/

static int HSread_line_from_rle_27 (FILE           *infile,
                                    int            *ScanLine,
                                    int            Length,
                                    unsigned short *Red,
                                    unsigned short *Green,
                                    unsigned short *Blue)

/*
NAME
   HSread_line_from_rle_27

KEYWORD
   animate

DESCRIPTION
   This function reads one scanline worth of rle from the file 'infile' and
   places pixel information into the structures 'Red', 'Green', and 'Blue'

SIDE EFFECT
   Sets the value for the 'unscaled' 'ScanLine'.

PARAMETERS
   infile (IN)           - Pointer to unix file open for reading
   ScanLine (OUT)        - Number of the scanline. Only used if SCANNABLE is
                           defined in HSrle.h
   Length (IN)           - Number of pixels to resolve run-length
   Red, Green, Blue (IN) - Color arrays for holding the de-coded rle information

GLOBALS USED
   none

RETURN VALUES
   0 - Unsuccessful read of file
   non-zero - Successful read of file

HISTORY
   07/12/89 Created. -Trevor Mink
   10/20/89 Changed to read rle type 27. -Trevor Mink
*/

{
   int            i;
   int            Count = 0;
   int            EndRun;
   int            Color;
   char           Head;
   unsigned char  Buffer[128];
   unsigned short *RGB = NULL;
   int            bytes_read = TRUE;

#if SCANNABLE
   unsigned short LineHeader[2];
   int            Total_bytes = 0;
   int            Words_to_follow = 0;

   bytes_read = fread (LineHeader, 4 /* bytes */ , 1, infile);

#ifdef BIG_ENDIAN
   HSconv_short ( (short *)LineHeader, 2);
#endif

   Words_to_follow = LineHeader[1];
   Total_bytes += bytes_read;
#endif

#if ECHO_READ
   printf ("LineHeader[0] = %x\n", LineHeader[0]);
   printf ("LineHeader[1] = %x\n", LineHeader[1]);
#endif

#if SCANNABLE
   bytes_read = fread(LineHeader, 4 /* bytes */ , 1, infile);

#ifdef BIG_ENDIAN
   HSconv_short(LineHeader, 2);
#endif

   *ScanLine = LineHeader[0];
   Total_bytes += bytes_read;
#endif

#if ECHO_READ
   printf ("LineHeader[0] = %x\n", LineHeader[0]);
   printf ("LineHeader[1] = %x\n", LineHeader[1]);
#endif
   for (Color = 0; Color < 3; Color++)
   {
      switch (Color)
      {
         case RED:
            RGB = Red;
            break;
         case GREEN:
            RGB = Green;
            break;
         case BLUE:
            RGB = Blue;
            break;
      }

      for ( Count = 0; Count < Length && bytes_read; )
      {
         /* Read another atom 'Head' */
         bytes_read = fread (&Head, 1 /* bytes */ , 1, infile);

         if (bytes_read)
         {
#if SCANNABLE
            Total_bytes += bytes_read;
#endif
            /* Read 'Head' bytes to get the tail of the atom */
            if (Head > 0)
            {
               bytes_read = fread (Buffer, Head, 1, infile);

               if (bytes_read)
               {
#if SCANNABLE
                  Total_bytes += bytes_read;
#endif
                  EndRun = Count + Head;
                  for(i = 0; Count < EndRun && Count < Length; Count++, i++)
                  {
                     RGB[Count] = Buffer[i];
                  }
               }   /* end: if (bytes_read) */
            }
            else
            {
               /* -Head gives the run-length of the shade in next byte */

               bytes_read = fread (Buffer, 1, 1, infile);

               if (bytes_read)
               {
#if SCANNABLE
                  Total_bytes += bytes_read;
#endif
                  EndRun = Count - Head;  /* 'Head' is negative */

                  for ( ; Count < EndRun && Count < Length; Count++ )
                  {
                     RGB[Count] = Buffer[0];
                  }
               } /* end: if (bytes_read)   */
            }    /* end: else              */
         }       /* end: if (bytes_read)   */
      }          /* end: for ( Count = ... */
   }             /* end: for ( Color = ... */

#if SCANNABLE
   /* Check for a pad byte (in the case of odd number of total bytes read) */
   printf ("Total_bytes = %d\n", Total_bytes);
   if ((Total_bytes / 2) < (Words_to_follow + 2))
   {
      bytes_read = fread (Buffer, 1, 1, infile);
   }
#endif

   return (bytes_read);

}   /* HSread_line_from_rle_27() */

/*--- HSscale_and_index_line -------------------------------------------------*/

static void HSscale_and_index_line (int             term_planes,
                                    int             x,
                                    int             Scale,
                                    unsigned short  *Red,
                                    unsigned short  *Green,
                                    unsigned short  *Blue,
                                    char            *Pixels,
                                    char            *buffer,
                                    int             BegX,
                                    int             EndX,
                                    int             BegY,
                                    int             EndY,
                                    int             LineLength,
                                    short           true_color,
                                    unsigned short  orientation )

/*
NAME
   HSscale_and_index_line

KEYWORD
   animate

DESCRIPTION
   This function passes lines to 'HSplace_line_in_buffer'. It stretches
   each line by a factor of 'Scale' and passes each RGB line it gets
   'Scale' times using 'IGErgb_to_index' to dither

PARAMETERS
   term_planes (IN)         - Number of bit planes used for color on the
                              current machine
   x (IN)                   - Vertical scanline number
   Scale (IN)               - Positive power of 2 factor by which to scale line
   Red,Green,Blue (IN)      - Unscaled pixel information
   Pixels (OUT)             - Current scanline of scaled pixel data
   buffer (OUT)             - buffered scaled pixel data
   BegX,EndX,BegY,EndY (IN) - Unscaled, clipped x,y beginning and ending
   LineLength (IN)          - Unscaled, clipped number of pixels
   true_color (IN)          - Boolean indicating recalling on an edge II in 24
                              bit mode

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   07/26/89 Created. -Trevor Mink
   03/13/90 Changed to support TRUE COLOR. -S.P. Rogers
*/
{
   int  i;
   int  j;
   int  k;
   int  y;
   int  Width;
   int  Length;
   int  RealBeg;
   int  RealEnd;

   Width = EndX - BegX + 1;
   Length = EndY - BegY + 1;

#if DEBUG
   fprintf (stderr, "Within HSscale_and_index_line\n");
   fprintf (stderr, "x = %d\tLength = %d\tWidth = %d\tScale = %d\tRed = %x\tGreen = %x\tBlue = %x\tPixels = %x\n",
            x, Length, Width, Scale, Red, Green,
            Blue, Pixels);
   fprintf (stderr,"BegX = %d\tEndX = %d\tBegY = %d\tEndY = %d\n", BegX, EndX, BegY,
            EndY);
#endif

   if( orientation & LOWER)
   {
      RealEnd = LineLength - BegY - 1;
      RealBeg = LineLength - EndY - 1;
   }
   else
   {
      RealEnd = EndY;
      RealBeg = BegY;
   }
   for (j = 0; j < Scale; j++)
   {
      y = Length * Scale - 1;

      for (i = RealBeg; i <= RealEnd; i++)
      {
#if ECHO_SCALE
         fprintf (stderr, "x = %d\ty = %d\t", x, y);
         fprintf (stderr, "red = %d\tgreen = %d\tblue = %d\n", Red[i],
                       Green[i], Blue[i]);
#endif
         for (k = 0; k < Scale; k++)
         {
#if ECHO_SCALE
            printf ("Calling IGErgb_to_index with: Scale = %d\ti = %d\tk = %d\tx = %d\ty = %d\n", Scale, i, k, x, y);
#endif
            if (true_color)
            {
               ((long *) Pixels)[(Scale * (i - RealBeg) + k)] =
                        (Blue[i] << 16) | (Green[i] << 8) | Red[i];
            }
            else if (term_planes == 9)
            {
               ((short *) Pixels)[(Scale * (i - RealBeg) + k)] =
                       (unsigned short)IGErgb_to_index ( context_no,
                                                         x,
                                                         y,
                                                         (IGRint)Red[i],
                                                         (IGRint)Green[i],
                                                         (IGRint)Blue[i]);
            }
            else
            {
               Pixels[(Scale * (i - RealBeg) + k)] =
                       (unsigned char)IGErgb_to_index ( context_no,
                                                        x,
                                                        y,
                                                        (IGRint)Red[i],
                                                        (IGRint)Green[i],
                                                        (IGRint)Blue[i] );
            }
            y--;
         }   /* end: for( k= ... */
#if DEBUG_SCALE
         fprintf (stderr, "x = %d\ty = %d\tcolor = %d\n", x, y, Pixels[i]);
#endif
      }      /* end: for( i= ... */

      HSplace_line_in_buffer( term_planes,
                              (Length * Scale),
                              (Width * Scale),
                              x,
                              Pixels,
                              buffer,
                              true_color,
                              orientation );

      x++;    /* Alters locally only, must reset on getting next scanline */
   } /* end: for( j ...*/
}    /* HSscale_and_index_line() */

/*--- HSunscale_lines_type27 ------------------------------------------------*/

static void HSunscale_lines_type27 (int            x,
                                    int            Scale,
                                    unsigned short *R[8],
                                    unsigned short *G[8],
                                    unsigned short *B[8],
                                    char           *buffer,
                                    int            term_planes,
                                    int            BegY,
                                    int            EndY,
                                    int            Width,
                                    int            LineLength,
                                    short          true_color,
                                    short          division_factor,
                                    unsigned short orientation )

/*
NAME
   HSunscale_lines_type27

KEYWORD
   animate

DESCRIPTION
   This function does the down-scaling for type 27 rle. Either a 2 X 2 or a
   4 X 4 grouping of pixels is scaled down to one pixel

PARAMETERS
   x (IN)               - Vertical scanline number
   Scale (IN)           - Positive power of 2 factor by which to scale line
   R,G,B (IN/OUT)       - Unscaled pixel information
   buffer (IN/OUT       - Buffered scaled pixel data
   term_planes (IN)     - Number of bit planes used for color on the current
                          machine
   BegY,EndY(IN)        - Unscaled, clipped x,y beginning and ending
   Width (IN)           - self-explanatory
   LineLength (IN)      - Unscaled, clipped number of pixels
   true_color (IN)      - Boolean indicating recalling on an edge II in 24 bit
                          mode
   division_factor (IN) - Used for shift (instead of division) to average pixel
                          values in order to scale down

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   06/28/90 Created. -Trevor Mink
*/
{
   int            y;
   int            i;
   int            j;
   int            k;
   int            index;
   int            Length;
   int            RealBeg;
   int            RealEnd;
   unsigned long  Red;
   unsigned long  Green;
   unsigned long  Blue;
   unsigned long  ColorIndex;
   int            pixel_size;


   /*----------------------------------------------------------
    *
    *  If XGL, then don't call WLget_raster_size.  This tell us
    *  the depth of the window, but not the depth of the data.
    *  get that from true_color  I'm conditionally compiling
    *  this change because I don't want to mess with the code on
    *  the other platforms.  (Mike 1/11/96)
    *
    */

#  if defined (XGL)
   pixel_size = (true_color) ? 4 : 1;
#  else
   WLget_raster_size( lwin_no, 1, 1, &pixel_size );
#  endif

   index = -1;
   Length = EndY - BegY + 1;

#if ECHO_UNSCALE
   fprintf (stderr, "x = %d\tScale = %d\tbuffer = %x\tterm_planes = %d\n",
                     x, Scale, buffer, term_planes);
   fprintf (stderr, "BegY = %d\tEndY = %d\tLineLength = %d\n",
                     BegY, EndY, LineLength);
#endif

   if( orientation & LOWER )
   {
      RealBeg = LineLength - EndY - 1;
      RealEnd = LineLength - BegY - 1;
   }
   else
   {
      RealBeg = BegY;
      RealEnd = EndY;
   }

   y = Length / Scale - 1;
   for (i = RealBeg; i <= (RealEnd - Scale + 1); i += Scale, y--)
   {
      Red   = 0;
      Green = 0;
      Blue  = 0;
      for (j = 0; j < Scale; j++)
      {
         for (k = 0; k < Scale; k++)
         {
            Red   += R[j][i + k];
            Green += G[j][i + k];
            Blue  += B[j][i + k];
#if ECHO_UNSCALE
            fprintf (stderr, "R[%d][%d] = %d\t", j, i + k, R[j][i + k]);
#endif
         }
      }
      /* Get average RGB values */
      Red = (Red >> division_factor);
      Green = (Green >> division_factor);
      Blue = (Blue >> division_factor);

      if (true_color)
      {
         ColorIndex = (unsigned long) ((Blue << 16) | (Green << 8) | Red);
      }
      else
      {
         ColorIndex = (unsigned short) IGErgb_to_index( context_no,
                                                        x,
                                                        y,
                                                       (int)Red,
                                                       (int)Green,
                                                       (int)Blue);
      }

      if (LineByLine)
      {
         index++;
      }
      else
      {
         index = (Width / Scale) * y + x;
      }

#if ECHO_UNSCALE
      fprintf (stderr, "\nRGB = %d, %d, %d\tx, y = %d, %d\n", Red, Green, Blue, x, y);
      fprintf (stderr, "ColorIndex = %d\tindex (into buffer) = %d\n", ColorIndex, index);
#endif

      if (true_color)
      {
         ((unsigned long *) buffer)[index] = (unsigned long) ColorIndex;
      }
      else if (term_planes == 9)
      {
         ((short *) buffer)[index] = (short) ColorIndex;
      }
      else
      {
         buffer[index] = (char)ColorIndex;
      }
   }      /* end: for i */

   if (LineByLine)
   {
      if( orientation & HORIZONTAL)
      {
         HSwl_put_line (buffer,
                        lwin_no,
                        context_no,
                        x_0,
                        Current_y,
                        LineLength / Scale,
                        8 * pixel_size,
                        orientation );
         Current_y++;
      }
      else
      {
         HSwl_put_line (buffer,
                        lwin_no,
                        context_no,
                        Current_x,
                        y_0,
                        LineLength / Scale,
                        8 * pixel_size,
                        orientation );
         Current_x++;
      }
   }

}   /* HSunscale_lines_type27 */

/*--- HSformat_type27 --------------------------------------------------------*/

void HSformat_type27 (FILE            *f_ptr,
                      int             term_planes,
                      short           Height,
                      short           ScaleFactor,
                      char            *buffer,
                      int             xMin,
                      int             yMin,
                      int             xMax,
                      int             yMax,
                      short           true_color,
                      unsigned short  orientation )

/*
NAME
   HSformat_type27

KEYWORD
   animate

DESCRIPTION
   This function formats each scanline of the given file into an array of
   RGB values.

PARAMETERS
   f_ptr (IN)               - Pointer to unix file open for reading
   term_planes (IN)         - Number of bit planes used for color on the
                              current machine
   height (IN)              - Height of the buffer area in number of pixels
   ScaleFactor (IN)         - Positive power of 2 factor by which to scale line
   Pixels (OUT)             - Current scanline of scaled pixel data
   buffer (OUT)             - Buffered scaled pixel data
   xMin,yMin,xMax,yMax (IN) - Unscaled, clipped x,y beginning and ending
   true_color (IN)          - Boolean indicating recalling on an edge II in 24
                              bit mode
   orientation (IN)         - scanline orientation

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   07/26/89 Created. -Trevor Mink
   03/13/90 Changed to support TRUE COLOR. -S.P. Rogers
*/

{
   int             x;
   int             i;
   int             j;
   int             Index;
   int             LineRead = TRUE;
   unsigned short  *Red[8];
   unsigned short  *Green[8];
   unsigned short  *Blue[8];
   short           TempFactor;
   short           division_factor;
   char            *Pixels;
   int             max_line;

#if DEBUG
   fprintf (stderr, "Within HSformat_type27\n");
   fprintf (stderr, "f_ptr = %dHeight = %d\tScale = %d\tbuffer = %x\n",
                         f_ptr, Height, ScaleFactor, buffer);
   fprintf (stderr, "xMin = %d\txMax = %d\tyMin = %d\tyMax = %d\n",
                          xMin, xMax, yMin, yMax);
#endif

   Red[0]   = (unsigned short *)malloc(Height * sizeof(unsigned short));
   Green[0] = (unsigned short *)malloc(Height * sizeof(unsigned short));
   Blue[0]  = (unsigned short *)malloc(Height * sizeof(unsigned short));

   if (true_color)
   {
      /* array of longs */
      Pixels = (char *)malloc((Height + 1) * ScaleFactor /
                                 4 * sizeof(unsigned long));
   }
   else
   {
      /* array of shorts */
      Pixels = (char *)malloc((Height + 1) * ScaleFactor /
                                 4 * sizeof(unsigned short));
   }

   for (i = 1; i < 8; i++)
   {
      Red[i]   = (unsigned short *)NULL;
      Green[i] = (unsigned short *)NULL;
      Blue[i]  = (unsigned short *)NULL;
   }

   if (ScaleFactor == SCALE_ONE_HALF)
   {
      Red[1]   = (unsigned short *)malloc(Height * sizeof(unsigned short));
      Green[1] = (unsigned short *)malloc(Height * sizeof(unsigned short));
      Blue[1]  = (unsigned short *)malloc(Height * sizeof(unsigned short));
   }
   else if (ScaleFactor == SCALE_ONE_FOURTH)
   {
      Red[1]   = (unsigned short *)malloc(Height * sizeof(unsigned short));
      Green[1] = (unsigned short *)malloc(Height * sizeof(unsigned short));
      Blue[1]  = (unsigned short *)malloc(Height * sizeof(unsigned short));

      Red[2]   = (unsigned short *)malloc(Height * sizeof(unsigned short));
      Green[2] = (unsigned short *)malloc(Height * sizeof(unsigned short));
      Blue[2]  = (unsigned short *)malloc(Height * sizeof(unsigned short));

      Red[3]   = (unsigned short *)malloc(Height * sizeof(unsigned short));
      Green[3] = (unsigned short *)malloc(Height * sizeof(unsigned short));
      Blue[3]  = (unsigned short *)malloc(Height * sizeof(unsigned short));
   }
   else if (ScaleFactor == SCALE_ONE_EIGHTH)
   {
      for (i = 1; i < 8; i++)
      {
         Red[i]   = (unsigned short *)malloc(Height * sizeof(unsigned short));
         Green[i] = (unsigned short *)malloc(Height * sizeof(unsigned short));
         Blue[i]  = (unsigned short *)malloc(Height * sizeof(unsigned short));
      }
   }

   if( orientation & HORIZONTAL )
   {
      max_line = yMax;
   }
   else
   {
      max_line = xMax;
   }


   if (ScaleFactor >= 4)
   {
      ScaleFactor /= 4;
      for (i = 0; i <= max_line && LineRead; i++)
      {
         HSupdate_heartbeat ();
         LineRead = HSread_line_from_rle_27 (f_ptr,
                                             &x,
                                             (int)Height,
                                             Red[0],
                                             Green[0],
                                             Blue[0]);
#if !SCANNABLE
         x = (i - xMin) * ScaleFactor;
#endif

         if( orientation & HORIZONTAL )
         {
            if (LineRead && i >= yMin)
            {
               HSscale_and_index_line (term_planes,
                                       x,
                                       ScaleFactor,
                                       Red[0],
                                       Green[0],
                                       Blue[0],
                                       Pixels,
                                       buffer,
                                       yMin,
                                       yMax,
                                       xMin,
                                       xMax,
                                       Height,
                                       true_color,
                                       orientation);
            }
         }
         else
         {
            if (LineRead && i >= xMin)
            {
               HSscale_and_index_line (term_planes,
                                       x,
                                       ScaleFactor,
                                       Red[0],
                                       Green[0],
                                       Blue[0],
                                       Pixels,
                                       buffer,
                                       xMin,
                                       xMax,
                                       yMin,
                                       yMax,
                                       Height,
                                       true_color,
                                       orientation);
            }
         }
      }
   }
   else
   {
      if (ScaleFactor == SCALE_ONE_EIGHTH)
      {
         ScaleFactor = 8;
      }
      else if (ScaleFactor == SCALE_ONE_FOURTH)
      {
         ScaleFactor = 4;
      }
      else
      {
         ScaleFactor = 2;
      }

      division_factor = 0;
      TempFactor = ScaleFactor;
      for (i = 0; i < 8 * sizeof(short) && TempFactor; i++)
      {
         TempFactor = TempFactor >> 1;
         division_factor++;
      }
      division_factor--;
      division_factor = 2 * division_factor;

      Index = 0;
      for (i = 0; i <= xMax && LineRead; i++)
      {
         HSupdate_heartbeat ();
         j = Index % ScaleFactor;
         LineRead = HSread_line_from_rle_27( f_ptr,
                                             &x,
                                             (int)Height,
                                             Red[j],
                                             Green[j],
                                             Blue[j] );

         /* Do pixel averaging after every 'ScaleFactor' scanlines */
         if( orientation & HORIZONTAL )
         {
            if (LineRead && i >= yMin)
            {
               Index++;
               if (!(Index % ScaleFactor))
               {
                  HSunscale_lines_type27 ( (Index / ScaleFactor - 1),
                                           ScaleFactor,
                                           Red,
                                           Green,
                                           Blue,
                                           buffer,
                                           term_planes,
                                           xMin,
                                           xMax,
                                           (yMax - yMin + 1),
                                           Height,
                                           true_color,
                                           division_factor,
                                           orientation);
               }
            }
         }
         else
         {
            if (LineRead && i >= xMin)
            {
               Index++;
               if (!(Index % ScaleFactor))
               {
                  HSunscale_lines_type27 ( (Index / ScaleFactor - 1),
                                           ScaleFactor,
                                           Red,
                                           Green,
                                           Blue,
                                           buffer,
                                           term_planes,
                                           yMin,
                                           yMax,
                                           (xMax - xMin + 1),
                                           Height,
                                           true_color,
                                           division_factor,
                                           orientation);
               }
            }
         }
      }
   }

#if ECHO_READ
   printf ("Completed read and scale for ALL scanlines\n");
#endif

   if (Pixels)
   {
      free ((char *) Pixels);
   }
   for (i = 0; i < 8; i++)
   {
      if (Red[i])
      {
         free ((char *) Red[i]);
      }
      if (Green[i])
      {
         free ((char *) Green[i]);
      }
      if (Blue[i])
      {
         free ((char *) Blue[i]);
      }
   }

   /* We need to cleanup static variable to prepare for the next image */
   first_putline = TRUE;
   WLfree_raster_data( &image );

}   /* HSformat_type27() */

/*---  HSread_line_from_rle10 ------------------------------------------------*/


static int HSread_line_from_rle10 (FILE  *infile,
                                   char  *Indices,
                                   int   cmap_offset)

/*
NAME
   HSread_line_from_rle10

KEYWORD
   animate

DESCRIPTION
   This function reads one scanline worth of type 10 rle from the file
   'infile' and places pixel information into the structure 'Indices' in
   the form of color indices.

PARAMETERS
   infile (IN)       - Pointer to unix file open for reading
   Indices (OUT)     - Color table indices of the decoded rle data
   cmap_offset (IN)  - Number of slots in the cmap that the files colortable is
                       offset

GLOBALS USED
   none

RETURN VALUES
   0 - Unsuccessful read from file
   non-zero - Successful read from file

HISTORY
   07/16/90 Created from Steve Roger's standalone. -Trevor Mink
*/

{
   int                    ii;
   int                    num_rle;
   int                    jj;
   int                    index;
   int                    bytes_read;
   unsigned char          value;
   unsigned short         length;
   struct TYPE_89_HEADER  hdr89;
   struct RLE_RECORD      rle;

   index = 0;
   bytes_read = fread (&hdr89, sizeof(struct TYPE_89_HEADER), 1, infile);
   num_rle = (hdr89.wtf - 2) / 2;

   for (ii = 0; ii < num_rle && bytes_read; ii++)
   {
      bytes_read = fread (&rle, 4, 1, infile);
      if (!bytes_read)
      {
         break;
      }
      value = (unsigned char) (rle.color_shade);
      length = (unsigned short) rle.run_length;
      for (jj = 0; jj < length; jj++)
      {
         Indices[index++] = cmap_offset + value;
      }
   }      /* end: for ii */

   return (bytes_read);

}   /* HSread_line_from_rle10 */

/*---  HSread_line_from_rle26 ------------------------------------------------*/

static int HSread_line_from_rle26 (FILE            *infile,
                                   char            *Indices,
                                   unsigned short  run_mask,
                                   unsigned short  value_mask,
                                   int             cmap_offset)

/*
NAME
    HSread_line_from_rle26

KEYWORD
   animate

DESCRIPTION
   This function reads one scanline worth of type 26 rle from the file
   'infile' and places pixel information into the structure 'Indices'
   in the form of color indices.

PARAMETERS
   infile (IN)      - Pointer to unix filename open for reading
   Indices (OUT)    - Color table indices
   run_mask (IN)    -
   value_mask (IN)  -
   cmap_offset (IN) -  Number of slots in the cmap that the files colortable is
                       offset


GLOBALS USED
   none

RETURN VALUES
   0 - Unsuccessful read from file
   non-zero - Successful read from file

HISTORY
   11/17/89 Created from Steve Roger's standalone. -Trevor Mink
*/

{
   int                    ii;
   int                    jj;
   int                    num_rle;
   int                    length;
   int                    index;
   int                    bytes_read = 0;
   unsigned char          value;
   unsigned short         len_val;
   struct TYPE_89_HEADER  hdr89;

   index = 0;

   /* Read the scannable header to find the number of runs in the scanline */
   /* NOTE: Let's hope the files have scannable headers                    */

   fread (&hdr89, sizeof(struct TYPE_89_HEADER), 1, infile);
   num_rle = hdr89.wtf - 2;

   for (ii = 0; ii < num_rle && bytes_read; ii++)
   {
      bytes_read = fread (&len_val, 2, 1, infile);
      if (!bytes_read)
      {
         break;
      }

      length = (len_val & run_mask) >> (16 - DTM);

      if (length == 0)
      {
         value = len_val & value_mask;
         bytes_read = fread (&len_val, 2, 1, infile);
         if (!bytes_read)
         {
            break;
         }
         length = len_val;
         ii++;
      }
      else
      {
         value = len_val & value_mask;
      }

      for (jj = 0; jj < length; jj++)
      {
         Indices[index++] = cmap_offset + value;
      }
   }      /* end: for ii */

   return (bytes_read);

}   /* read_line_from_rle26 */

/*--- HSread_line_from_rle29 -------------------------------------------------*/

static int HSread_line_from_rle29 (FILE            *infile,
                                   int             *ScanLine,
                                   int             Length,
                                   char            *Indices,
                                   IGRboolean      Scannable,
                                   int             cmap_offset )

/*
NAME
   HSread_line_from_rle29

KEYWORD
   animate

DESCRIPTION
   This function reads one scanline worth of type 29 rle from the file
   'infile' and places pixel information into the structure 'Indices' in
   the form of color indices.

SIDE EFFECT
   Sets the value for the 'unscaled' 'ScanLine'.

PARAMETERS
   infile (IN)       - Pointer to unix file open for reading
   ScanLine (OUT)    - Number of scanline (according to header in file)
   Length (IN)       - Number of pixels to be read
   Indices (OUT)     - Color table indices of de-coded rle data
   cmap_offset (IN ) - Number of slots in the cmap that the file's colortable is
                       offset

GLOBALS USED
   none

RETURN VALUES
   0 - Unsuccessful read from file
   non-zero - Successful read from file

HISTORY
   11/17/89 Created from function to read type 27. -Trevor Mink
*/
{
   int             i;
   int             Count = 0;
   int             EndRun;
   char            Head;
   char            Buffer[128];
   unsigned short  LineHeader[2];
   int             bytes_read = TRUE;
   int             Total_bytes = 0;
   int             Words_to_follow = 0;

   if (Scannable)
   {
      bytes_read = fread (LineHeader, 4 /* bytes */ , 1, infile);
#ifdef BIG_ENDIAN
      HSconv_short ((short *)LineHeader, 2);
#endif
      Words_to_follow = LineHeader[1];

      if (bytes_read)
      {
         Total_bytes += 4;
      }
   }

#if ECHO_READ
   fprintf(stderr, "Length = %d\tIndices = %xWords_to_follow = %d\n",
                    Length, Indices, Words_to_follow);
   fprintf(stderr, "LineHeader[0] = %x (hex)\n", LineHeader[0]);
   fprintf(stderr, "LineHeader[1] = %d (dec)\n", LineHeader[1]);
#endif

   if (Scannable)
   {
      bytes_read = fread (LineHeader, 4 /* bytes */ , 1, infile);
#ifdef BIG_ENDIAN
      HSconv_short ((short *) LineHeader, 2);
#endif
      *ScanLine = LineHeader[0];

      if (bytes_read)
      {
         Total_bytes += 4;
      }
   }

#if ECHO_READ
   fprintf(stderr, "LineHeader[0] = %d (dec)\n", LineHeader[0]);
   fprintf(stderr, "LineHeader[1] = %d (dec)\n", LineHeader[1]);
#endif

   for (Count = 0; (Count < Length) && bytes_read;)
   {
      /* Read another atom 'Head' */
      bytes_read = fread (&Head, 1 /* bytes */ , 1, infile);
#if ECHO_READ
      fprintf(stderr, "\nbytes_read = %d\n", bytes_read);
      fprintf(stderr, "Reading Head = %d\n", Head);
#endif
      if (bytes_read)
      {
         if (Scannable)
         {
            Total_bytes += 1;
         }

         /* Read 'Head' bytes to get the tail of the atom */
         if (Head > 0)
         {
            bytes_read = fread (Buffer, Head, 1, infile);

            if (bytes_read)
            {
               if (Scannable)
               {
                  Total_bytes += Head;
               }

               EndRun = Count + Head;
               for (i = 0; (Count < EndRun) && (Count < Length);  Count++, i++)
               {
                  Indices[Count] =  cmap_offset + Buffer[i];
               }
#if ECHO_READ
               fprintf(stderr, "%d assorted shades\n", Head);
#endif
            }
         }
         else
         {
            /* Read one byte to get the tail of the atom            */
            /* -Head gives the run-length of the shade in next byte */

            bytes_read = fread (Buffer, 1, 1, infile);

            if (bytes_read)
            {
               if (Scannable)
               {
                  Total_bytes += 1;
               }

               EndRun = Count - Head;     /* 'Head' is negative */

               for (; (Count < EndRun) && (Count < Length); Count++)
               {
                  Indices[Count] = cmap_offset + Buffer[0];
               }

#if ECHO_READ
               fprintf(stderr, "Run length = %d of shade: %x\n",
                               -Head, Buffer[0]);
#endif
            }
         }
      }
   }      /* for ( Count = ... */

#if ( ECHO_READ )
   /* Check for a pad byte (in the case of odd number of total bytes read) */
   if (Scannable)
   {
      fprintf(stderr, "Total_bytes = %d\n", Total_bytes);
   }
#endif
   if (Scannable)
   {
      if ((Total_bytes / 2) < (Words_to_follow + 2))
      {
         bytes_read = fread (Buffer, 1, 1, infile);
      }
   }
#if ( ECHO_READ )
   if (Scannable)
   {
      if ((Total_bytes / 2) < (Words_to_follow + 2))
      {
         fprintf(stderr, "Pad byte read\n");
      }
   }
#endif
   return (bytes_read);

}   /* HSread_line_from_rle29() */

/*--- HSscale_line() ---------------------------------------------------------*/

static void HSscale_line (int             y,
                          int             Scale,
                          char            *LineBuffer,
                          char            *buffer,
                          int             hdr_planes,
                          int             term_planes,
                          int             BegX,
                          int             EndX,
                          unsigned short  orient,
                          int             line_width )

/*
NAME
   HSscale_line (static)

KEYWORD
   animate

DESCRIPTION
   This function scales a line of color table indices up. It duplicates
   pixels twice or four times to accomplish the scaling.

PARAMETERS
   y (IN)           - scanline number
   Scale (IN)       - Positive power of 2 factor by which to scale line
   hdr_planes (IN)  - Number of bit planes used for color on the machine
                      where the file was created.
   term_planes (IN) - Number of bit planes used for color on the
                      current machine
   BegX, EndX (IN)  - Unscaled, clipped x,y beginning and ending
   orient     (IN)  - Scanline orientation
   line_width (IN)  - Width of scanline

GLOBALS USED
   Current_y

RETURN VALUES
   none

HISTORY
   04/20/90 Created. -Trevor Mink
*/
{
   int  i;
   int  j;
   int  k;
   int  index;
   int  Width = 0;
   int  pixel_size;
   int  real_beg;
   int  real_end;


   if( orient & LOWER)
   {
      real_end = line_width - BegX - 1;
      real_beg = line_width - EndX - 1;
   }
   else
   {
      real_end = EndX;
      real_beg = BegX;
   }

   /*----------------------------------------------------------
    *
    *  If XGL, then don't call WLget_raster_size.  This tell us
    *  the depth of the window, but not the depth of the data.
    *  get that from hdr_planes.  I'm conditionally compiling
    *  this change because I don't want to mess with the code on
    *  the other platforms.  (Mike 1/11/96)
    *
    */

#  if defined (XGL)
   pixel_size = (hdr_planes-1)/8 + 1;
#  else
   WLget_raster_size( lwin_no, 1, 1, &pixel_size);
#  endif

   if (LineByLine)
   {
      index = 0;
      Width = EndX - BegX + 1;
   }
   else
   {
      Width = (EndX - BegX + 1) * Scale;
      index = Width * (Scale * y);
   }

#if ECHO_SCALE
   fprintf (stderr, "Width = %d\ty = %d\tScale = %d\tLineBuffer = %x\t",
            Width, y, Scale, LineBuffer, buffer);
   fprintf (stderr, "buffer = %x\thdr_planes = %d\tterm_planes = %d\n",
            hdr_planes, term_planes);
#endif

   for (j = 0; j < Scale; j++)
   {
      for (i = real_beg; i <= real_end; i++)
      {
         for (k = 0; k < Scale; k++, index++)
         {
            if ((hdr_planes < 6) && (term_planes > 6) && (LineBuffer[i] != 0))
            {
               buffer[index] = LineBuffer[i] + 14; /* GX/GZ machine */
            }
            else
            {
               buffer[index] = LineBuffer[i];
            }
         }
      }   /* end: for i */

      if (LineByLine)
      {
         if( orient & HORIZONTAL )
         {
            HSwl_put_line (buffer,
                           lwin_no,
                           context_no,
                           x_0,
                           Current_y,
                           Width * Scale,
                           pixel_size * 8,
                           (int)orient );

            Current_y++;
         }
         else
         {
            HSwl_put_line (buffer,
                           lwin_no,
                           context_no,
                           Current_x,
                           y_0,
                           Width * Scale,
                           pixel_size * 8,
                           (int)orient );

            Current_x++;
         }

         index = 0;
      }
   }
}   /* HSscale_line */

/*--- HSunscale_lines() ------------------------------------------------------*/

static void HSunscale_lines (int             y,
                             int             Scale,
                             char            *LineBuffer[4],
                             char            *buffer,
                             int             hdr_planes,
                             int             term_planes,
                             int             BegX,
                             int             EndX,
                             unsigned short  orient )

/*
NAME
   HSunscale_lines (static)

KEYWORD
   animate

DESCRIPTION
   This function does the down-scaling for type 29 rle. Either a 2 X 2,
   a 4 X 4, or an 8 X 8 grouping of pixels is scaled down to one pixel.
   There's a dither pattern in which each relative position of the grouping
   is represented (once and only once) as the "favored" pixel in deciding
   the color index of the group. This "favored" index is used if there's a
   tie in the group voting. Voting is done by tallying the number of occur-
   ences within the group of all color indices represented.

   An illustration of the dither pattern of 2 X 2 groupings:
   X represents the 'Favored' pixel      X0  0X
   O represents the other pixels         00  00

                                         00  00
                                         X0  0X

PARAMETERS
   y (IN)            - Scanline number
   Scale (IN)        - Positive power of 2 factor by which to scale line
   LineBuffer[] (IN) - Up to 8 lines of pixel data used for pixel averaging
   buffer (OUT)      - Result of pixel averaging (unscaling)
   hdr_planes (IN)   - Number of bit planes used for color on the machine
                       where the file was created.
   term_planes (IN)  - Number of bit planes used for color on the
                       current machine
   BegX, EndX (IN)   - Unscaled, clipped beginning and ending

GLOBALS USED

RETURN VALUES
   none

HISTORY
   06/28/90 Created. -Trevor Mink
*/
{
   int i;
   int j;
   int k;
   int index;
   int Width;
   int ColorIndex;
   int Found;
   int m;
   int Count;
   int Favored = 0;
   int Greatest;
   int GreatestIndex = 0;
   int Counters[16];
   int Indices[16];
   int pixel_size;


   /*----------------------------------------------------------
    *
    *  If XGL, then don't call WLget_raster_size.  This tell us
    *  the depth of the window, but not the depth of the data.
    *  get that from hdr_planes.  I'm conditionally compiling
    *  this change because I don't want to mess with the code on
    *  the other platforms.  (Mike 1/11/96)
    *
    */

#  if defined (XGL)
   pixel_size = (hdr_planes-1)/8 + 1;
#  else
   WLget_raster_size( lwin_no, 1, 1, &pixel_size);
#  endif

   Width = EndX - BegX + 1;

   if (LineByLine)
   {
      index = 0;
   }
   else
   {
      index = (Width / Scale) * y;
   }

   for (i = BegX; i <= (EndX - Scale + 1); i += Scale, index++)
   {
      m = 0;
      for (j = 0; j < Scale; j++)
      {
         for (k = 0; k < Scale; k++)
         {
            ColorIndex = (int) (LineBuffer[j][i + k]);
            if ((j == y % Scale) && (k == (i / Scale) % Scale))
            {
               Favored = j * Scale + k;
            }
            Found = FALSE;
            for (Count = 0; Count < m; Count++)
            {
               if (Indices[Count] == ColorIndex)
               {
                  Counters[Count]++;
               }
               Found = TRUE;
            }
            if (!Found)
            {
               Indices[m] = ColorIndex;
               Counters[m++] = 1;
            }
         }
      }

      /* Find the index in Counters that reflects the greatest frequency */
      Greatest = 0;
      for (j = 0; j < m; j++)
      {
         /* Counters[j] will be >= 1 */
         /* If favored vertex is part of tie, use it */
         if (Counters[j] > Greatest || (Counters[j] == Greatest && j == Favored))
         {
            Greatest = Counters[j];
            GreatestIndex = Indices[j];
         }
      }

      if ((hdr_planes < 6) && (term_planes > 6) && (GreatestIndex != 0))
      {
         buffer[index] = (char) GreatestIndex + 14;  /* GX/GZ machine */
      }
      else
      {
         buffer[index] = (char) GreatestIndex;
      }
   }      /* end: for i */
   if (LineByLine)
   {
      if( orient & HORIZONTAL )
      {
         HSwl_put_line( buffer,
                        lwin_no,
                        context_no,
                        x_0,
                        Current_y,
                        Width / Scale,
                        pixel_size * 8,
                        (int)orient );
         Current_y++;
      }
      else
      {
         HSwl_put_line( buffer,
                        lwin_no,
                        context_no,
                        Current_x,
                        y_0,
                        Width / Scale,
                        pixel_size * 8,
                        (int)orient );
         Current_x++;
      }

      index = 0;
   }

}   /* HSunscale_lines */

/*--- HSformat_indexed() -----------------------------------------------------*/

void HSformat_indexed (FILE                 *f_ptr,
                       int                  Width,
                       int                  Scale,
                       int                  hdr_planes,
                       int                  term_planes,
                       char                 *buffer,
                       int                  xMin,
                       int                  yMin,
                       int                  xMax,
                       int                  yMax,
                       int                  rle_type,
                       IGRboolean           Scannable,
                       short                data_type_modifier,
                       int                  WinColorTable,
                       struct WLcmap_entry  *file_ctbl,
                       int                  cmap_offset,
                       unsigned short       orient )

/*
NAME
   HSformat_indexed

KEYWORD
   animate

DESCRIPTION
   This function formats each scanline of the given file into an array of
   color indices.

PARAMETERS
   f_ptr (IN)               - Pointer to unix file open for reading
   Width  (IN)              - Width of the buffer area in number of pixels
   Scale (IN)               - Positive power of 2 factor by which to scale line
   hdr_planes (IN)          - Number of bit planes used for color on the machine
                              where the file was created.
   term_planes (IN)         - Number of bit planes used for color on the
                              current machine
   buffer (OUT)             - Buffered scaled pixel data
   Pixels (OUT)             - Current scanline of scaled pixel data
   xMin,yMin,xMax,yMax (IN) - Unscaled, clipped x,y beginning and ending
   rle_type (IN)            - Type of run-length encoding (eg. 10, 15, 26, 27,
                              29)
   Scannable (IN)           - Boolean indicating whether the raster file has
                              headers at the beginning of each scanline.
   data_type_modifier (IN)  - ??
   orient (IN)              - scanline orientation

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   11/17/89 Created. -Trevor Mink
*/
{
   int             y;
   int             i;
   int             LineRead = TRUE;
   char            *Indices[8];
   int             ScanLine;
   int             UnScaleFactor;
   int             Index;
   unsigned short  run_mask;
   unsigned short  value_mask;
   int             max_line;


#if ECHO_READ2
   fprintf (stderr, "Within HSformat_indexed\n");
   fprintf (stderr, "f_ptr = %d\tWidth = %d\tScale = %d\tbuffer = %x\n",
                    f_ptr, Width, Scale, buffer);
#endif

   Indices[0] = (char *)malloc(Width);
   Indices[1] = (char *) NULL;
   Indices[2] = (char *) NULL;
   Indices[3] = (char *) NULL;
   Indices[4] = (char *) NULL;
   Indices[5] = (char *) NULL;
   Indices[6] = (char *) NULL;
   Indices[7] = (char *) NULL;

   if (Scale == SCALE_ONE_HALF)
   {
      Indices[1] = (char *)malloc(Width);
   }
   else if (Scale == SCALE_ONE_FOURTH)
   {
      Indices[1] = (char *)malloc(Width);
      Indices[2] = (char *)malloc(Width);
      Indices[3] = (char *)malloc(Width);
   }
   else if (Scale == SCALE_ONE_EIGHTH)
   {
      Indices[1] = (char *)malloc(Width);
      Indices[2] = (char *)malloc(Width);
      Indices[3] = (char *)malloc(Width);
      Indices[4] = (char *)malloc(Width);
      Indices[5] = (char *)malloc(Width);
      Indices[6] = (char *)malloc(Width);
      Indices[7] = (char *)malloc(Width);
   }

   run_mask = pow (2.0, (double) (16 - data_type_modifier)) *
                        (pow (2.0, (double) (data_type_modifier)) - 1.0) + 0.5;
   value_mask = pow (2.0, (double) (16 - data_type_modifier)) - 1.0 + 0.5;


   if( orient & HORIZONTAL )
   {
      max_line = yMax;
   }
   else
   {
      max_line = xMax;
   }

   ScanLine = 0;
   /* For all applicable lines of the file */
   if (Scale >= SCALE_NONE)
   {
      for (i = 0; i <= max_line && LineRead; i++)
      {
         HSupdate_heartbeat ();
         switch (rle_type)
         {
            case TYPE_29:
               LineRead = HSread_line_from_rle29 (f_ptr,
                                                  &y,
                                                  Width,
                                                  Indices[0],
                                                  Scannable,
                                                  cmap_offset);
               if( WinColorTable )
               {
                  HStranslate_line(  file_ctbl, Indices[0], Width, i );
               }
               if (!Scannable)
               {
                  y = i;
               }
               break;
            case TYPE_10:
               LineRead = HSread_line_from_rle10 (f_ptr, Indices[0],
                                                  cmap_offset);
               if( WinColorTable )
               {
                  HStranslate_line( file_ctbl, Indices[0], Width, i );
               }
               break;
            case TYPE_15:
               break;
            case TYPE_26:
               LineRead = HSread_line_from_rle26 (f_ptr, Indices[0], run_mask,
                                          value_mask, cmap_offset);
               if( WinColorTable )
               {
                  HStranslate_line( file_ctbl, Indices[0], Width, i );
               }
               break;
         }

         if( orient & HORIZONTAL )
         {
            if (LineRead && i >= yMin)
            {
               /* Zooming in */
               HSscale_line( ScanLine,
                             Scale / 4,
                             Indices[0],
                             buffer,
                             hdr_planes,
                             term_planes,
                             xMin,
                             xMax,
                             orient,
                             Width );
               ScanLine++;
            }
         }
         else
         {
            if (LineRead && i >= xMin)
            {
               /* Zooming in */
               HSscale_line (ScanLine,
                             Scale / 4,
                             Indices[0],
                             buffer,
                             hdr_planes,
                             term_planes,
                             yMin,
                             yMax,
                             orient,
                             Width);
               ScanLine++;
            }
         }
      }
   }
   else
   {
      if (Scale == SCALE_ONE_FOURTH)
      {
         UnScaleFactor = 4;
      }
      else if (Scale == SCALE_ONE_EIGHTH)
      {
         UnScaleFactor = 8;
      }
      else
      {
         UnScaleFactor = 2;
      }

      Index = 0;

      for (i = 0; i <= max_line && LineRead; i++)
      {
         HSupdate_heartbeat();
         switch (rle_type)
         {
            case TYPE_29:
               LineRead = HSread_line_from_rle29(
                                              f_ptr,
                                              &y,
                                              Width,
                                              Indices[(Index % UnScaleFactor)],
                                              Scannable,
                                              cmap_offset);
               if( WinColorTable )
               {
                  HStranslate_line( file_ctbl,
                                    Indices[(Index % UnScaleFactor)],
                                    Width,
                                    i );
               }
               break;

            case TYPE_10:
               LineRead = HSread_line_from_rle10 (f_ptr,
                                                  Indices[0],
                                                  cmap_offset);

               if( WinColorTable )
               {
                  HStranslate_line( file_ctbl, Indices[0], Width, i );
               }
               break;

            case TYPE_15:
               break;

            case TYPE_26:
               LineRead = HSread_line_from_rle26 (f_ptr, Indices[0], run_mask,
                                          value_mask, cmap_offset);
               if( WinColorTable )
               {
                  HStranslate_line( file_ctbl, Indices[0], Width, i );
               }
               break;
         }

         /* Do pixel averaging after every 'UnScaleFactor' scanlines */
         if( orient & HORIZONTAL )
         {
            if (LineRead && i >= yMin)
            {
               Index++;
               if (!(Index % UnScaleFactor))
               {
                  HSunscale_lines ((Index / UnScaleFactor - 1),
                                    UnScaleFactor,
                                    Indices,
                                    buffer,
                                    hdr_planes,
                                    term_planes,
                                    xMin,
                                    xMax,
                                    orient);
               }
            }
         }
         else
         {
            if (LineRead && i >= xMin)
            {
               Index++;
               if (!(Index % UnScaleFactor))
               {
                  HSunscale_lines ((Index / UnScaleFactor - 1),
                                    UnScaleFactor,
                                    Indices,
                                    buffer,
                                    hdr_planes,
                                    term_planes,
                                    yMin,
                                    yMax,
                                    orient );
               }
            }
         }
      }
   }

#if ECHO_READ
   fprintf(stderr, "LineRead = %d\n", LineRead);
   fprintf(stderr, "Completed read and scale for ALL scanlines\n");
#endif

   for( i = 0; i < 8; i++ )
   {
      if (Indices[i])
      {
         free( (char *)Indices[i] );
      }
   }

#if ECHO_READ
   fprintf(stderr,"Freed Indices buffers\n");
#endif

   /* We need to cleanup static variable to prepare for the next image */
   first_putline = TRUE;
   WLfree_raster_data( &image );

}   /* HSformat_indexed() */


/*---- HStranslate_line ---------------------------------------------------*/

/*
NAME
   HStranslate_line

KEYWORD
   animate

DESCRIPTION
   This function translates a line of color indices from the file colortable
   to the windows colortable.

PARAMETERS
   file_cmap (IN)     : Image file's stored colortable.
   indices   (IN/OUT) : Line of color indices to translate.
   length    (IN)     : Length of the line.
   line_num  (IN)     : Line number of the line.  Used in IGErgb_to_index to
                        determine dither pattern.

GLOBALS USED
   none

RETURN VALUES
   none

HISTORY
   07/15/93 Created. - Bob Druzynski
*/

static void HStranslate_line( struct WLcmap_entry *file_cmap,
                              char                *indices,
                              int                 length,
                              int                 line_num )
{
   int       i;
   WLuint16  R;
   WLuint16  G;
   WLuint16  B;
   WLuint8   index;

   for( i = 0; i < length; i++ )
   {
       index = indices[i];

      /* need to scale down the colors to between 0 and 255 */
       R = file_cmap[index].red >> 8;
       G = file_cmap[index].green >> 8;
       B = file_cmap[index].blue >> 8;

       indices[i] = (char)IGErgb_to_index( context_no,
                                           line_num,
                                           i,
                                          (int)R,
                                          (int)G,
                                          (int)B );
   }
}

