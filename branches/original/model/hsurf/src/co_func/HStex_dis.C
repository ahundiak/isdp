
/*		Apogee Compliant

$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $

*/


#include <stdio.h>

#include "wl.h"

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

#include "HSrle.h"
#include "hsanimate.h"
#include "math.h"
#include "HSsara.h"
#include "hskyoptypes.h"

#include "HSpr_co_func.h"

#define ECHO_READ 	0
#define ECHO_READ2	0
#define ECHO_READ3	0
#define ECHO_SCALE	0
#define ECHO_UNSCALE	0
#define DEBUG		0
#define DEBUG2		0


#define SCALE_ONE_FOURTH	1
#define SCALE_ONE_HALF		2
#define SCALE_NONE		4
#define SCALE_TWO_TIMES		8
#define SCALE_FOUR_TIMES	16

#define SCALE_UP		1
#define SCALE_DOWN		0

/*---HSread_type27------------------------------------------*/

HSread_type27 (FILE            *f_ptr,
               short           Height,
               short           Width,
               int             xMin,
               int             yMin,
               int             xMax,
               int             yMax,
               int             vertical,
               unsigned short  *sph_rgb)

/*
NAME
        HSread_type27

DESCRIPTION
        Reads a type27 raster file.

PARAMETERS
        f_ptr (IN)    - file containing type27 raster file
        Width (IN)    - width of raster image
        Height (IN)   - height of raster image
        xMin (IN)     - mininum x pixel of image to read from
        yMin (IN)     - minimum y pixel of image to read from
        xMax (IN)     - maximum x pixel of image to read from
        yMax (IN)     - maximum y pixel of image to read from
        vertical (IN) - whether image is vertical or horizontal
        sph_rgb (OUT) - array of rgb values returned

GLOBALS USED
        none

HISTORY
        ??/??/91    Yvonne Chu
           Created
*/
{
   int             k;
   int             l;
   int             m;
   int             i;
   int             j;
   int             LineRead = TRUE;

   unsigned short  *Red;
   unsigned short  *Green;
   unsigned short  *Blue;
   int             length_i;
   int             length_j;
   int             area_k;

   length_i = xMax - xMin + 1;
   length_j = yMax - yMin + 1;
   area_k = length_i * length_j;

   if (vertical)
   {
      Red = (unsigned short *) malloc (Height * sizeof (unsigned short));
      Green = (unsigned short *) malloc (Height * sizeof (unsigned short));
      Blue = (unsigned short *) malloc (Height * sizeof (unsigned short));

      for (i = 0; i <= xMax && LineRead; i++)
      {
         LineRead = HSread_line_from_rle27 (f_ptr,
                                            &k,
                                            Height,
                                            Red,
                                            Green,
                                            Blue);
         m = i - xMin;

         if (LineRead && i >= xMin)
         {
            l = yMax - yMin;

            for (j = yMin; j <= yMax; j++)
            {
               sph_rgb[MY_RED * area_k + m * length_j + l] = Red[j];
               sph_rgb[MY_GRN * area_k + m * length_j + l] = Green[j];
               sph_rgb[MY_BLU * area_k + m * length_j + l] = Blue[j];

               l--;
            }
         }
      }
   }
   else
   {
      Red = (unsigned short *) malloc (Width * sizeof (unsigned short));
      Green = (unsigned short *) malloc (Width * sizeof (unsigned short));
      Blue = (unsigned short *) malloc (Width * sizeof (unsigned short));

      for (i = 0; i <= yMax && LineRead; i++)
      {
         LineRead = HSread_line_from_rle27( f_ptr,
                                            &k,
                                            Width,
                                            Red,
                                            Green,
                                            Blue);

         m = i - yMin;

         if (LineRead && i >= yMin)
         {
            l = 0;

            for (j = xMin; j <= xMax; j++)
            {
               sph_rgb[MY_RED * area_k + l * length_j + m] = Red[j];
               sph_rgb[MY_GRN * area_k + l * length_j + m] = Green[j];
               sph_rgb[MY_BLU * area_k + l * length_j + m] = Blue[j];
               l++;
            }
         }
      }
   }
   if (Red)
   {
      free(Red);
      Red=NULL;
   }

   if (Green)
   {
      free(Green);
      Green=NULL;
   }
 
   if (Blue)
   {
      free(Blue);
      Blue=NULL;
   }
}   /* HSread_type27() */

/*---HSwrite_type27---------------------------------------------------------*/

HSwrite_type27 (WLuint32             lwin_no,
                WLuint32             context_no,
                     int             term_planes,
                    char             *buffer,
                     int             i,
                     int             xMin,
                     int             yMin,
                     int             xMax,
                     int             yMax,
                     unsigned short  sph_rgb[3][RGB_YMAX],
                     int             center_x,
                     int             center_y)


/*
NAME
        HSwrite_type27

DESCRIPTION
        Writes out a line of type27 raster file.

PARAMETERS
        win_no (IN)	 - window to read image
        term_planes (IN) - number of bit planes of window
        buffer (IN)	 - temporary storage to avoid reallocating space
        i (IN)	 	 - current line to write out
        xMin (IN)        - mininum x pixel of image to read from
        yMin (IN)        - minimum y pixel of image to read from
        xMax (IN)        - maximum x pixel of image to read from
        yMax (IN)        - maximum y pixel of image to read from
        sph_rgb (OUT)    - array of rgb values returned
        center_x (IN)	 - x coord of center of image on window
        center_y (IN)	 - y coord of center of image in window

GLOBALS USED
        none

HISTORY
        ??/??/91    Yvonne Chu
           Created
*/
{
   int			j;
   unsigned long	ColorIndex;
   int			y_0;
   int                  y_1;
   int                  bitmask;
   int			Current_x;
   int                  WLsts;

   bitmask = 511;

   y_0 = center_y - ((yMax - yMin) / 2);
   y_1 = center_y + ((yMax - yMin) / 2);
   Current_x = center_x - ((xMax - xMin) / 2) + i;

   for (j = yMin; j < yMax; j++)
   {
      ColorIndex = (unsigned short)IGErgb_to_index( context_no, i + j, j,
                                                    (int) sph_rgb[MY_RED][j],
                                                    (int) sph_rgb[MY_GRN][j],
                                                    (int) sph_rgb[MY_BLU][j]);
                                                   
      if (term_planes == 9)
      {
         ((short *) buffer)[j] = (short) ColorIndex;
      }
      else
      {
         buffer[j] = (char) ColorIndex;
      }
   }

#ifdef INTEL
   HSwl_put_line( buffer,
                  lwin_no,
                  context_no,
                  Current_x,
                  y_0,
                  y_1 - y_0,
                  8,
                  LOWER_LEFT_VERTICAL);
#else
   HSwl_put_line( buffer,
                  lwin_no,
                  context_no,
                  Current_x,
                  y_0,
                  y_1 - y_0,
                  8,
                  UPPER_LEFT_VERTICAL);
#endif

}   /* HSwrite_type27() */


/*---HSreadtexture_type27---------------------------------------------------*/

HSreadtexture_type27 (FILE            *f_ptr,
                      short           Height,
                      short           Width,
                      int             vertical,
                      unsigned short  *texture_rgb)

/*
NAME
        HSreadtexture_type27

DESCRIPTION
        Reads a type27 texture file and scales it by a factor of
        1/2 or 1/4 depending on the desired size passed in
        (Height x Width). Returns the rgb values in texture_rgb.

PARAMETERS
        f_ptr (IN)        - texture file to be read
        Height (IN)       - height of raster image required
        Width (IN)        - width of raster image required
        vertical (IN)     - whether image is vertical or horizontal
        texture_rgb (OUT) - rgb raster file returned
        
GLOBALS USED
        none

HISTORY
        ??/??/91    Yvonne Chu
           Created
*/

{
   short           ScaleFactor;
   int             center_x;
   int             center_y;
   int             xMin = 0;
   int             yMin = 0;
   int             xMax = 0;
   int             yMax = 0;
   int             initial_length;
   int             final_length;
   int             length_x;
   int             length_y;
   int             i;
   int             j;
   int             k;
   int             Index;
   int             LineRead = TRUE;
   unsigned short  *Red[4];
   unsigned short  *Green[4];
   unsigned short  *Blue[4];

   /* Determine scalefactor */
   length_x = SPH_XMAX - SPH_XMIN + 1;
   length_y = SPH_YMAX - SPH_YMIN + 1;

   final_length = ((length_x < length_y) ? length_y : length_x);
   initial_length = ((Width < Height) ? Width : Height);

   if (initial_length >= final_length * 4)
   {
      ScaleFactor = 4;
   }
   else
   {
      if (initial_length >= final_length * 2)
      {
         ScaleFactor = 2;
      }
      else
      {
         ScaleFactor = 1;
      }
   }

   /* Calculate boundary of texture to be read */

   center_x = Width / 2;
   center_y = Height / 2;

   switch (ScaleFactor)
   {
      case 1:
         xMin = center_x - final_length / 2;
         xMax = center_x + final_length / 2 - 1;
         yMin = center_y - final_length / 2;
         yMax = center_y + final_length / 2 - 1;
         break;

      case 2:
         xMin = center_x - final_length;
         xMax = center_x + final_length - 1;
         yMin = center_y - final_length;
         yMax = center_y + final_length - 1;
         break;

      case 4:
         xMin = center_x - final_length * 2;
         xMax = center_x + final_length * 2 - 1;
         yMin = center_y - final_length * 2;
         yMax = center_y + final_length * 2 - 1;
         break;

      default:
         printf ("in default\n");

   }

   /* Allocate buffer for reading */

   if (vertical)
   {
      initial_length = Height;
   }
   else
   {
      initial_length = Width;
   }

   for (i = 0; i < ScaleFactor; i++)
   {
      Red[i] = (unsigned short *) malloc (initial_length
                                          * sizeof (unsigned short));
      Green[i] = (unsigned short *) malloc (initial_length
                                            * sizeof (unsigned short));
      Blue[i] = (unsigned short *) malloc (initial_length
                                           * sizeof (unsigned short));
   }

   for (i = ScaleFactor; i < 4; i++)
   {
      Red[i] = NULL;
      Green[i] = NULL;
      Blue[i] = NULL;
   }


   /* Read texture */

   Index = 0;
   if (vertical)
   {
      for (i = 0; i <= xMax && LineRead; i++)
      {
         j = Index % ScaleFactor;
         LineRead = HSread_line_from_rle27 (f_ptr,
                                            &k,
                                            Height,
                                            Red[j],
                                            Green[j],
                                            Blue[j]);

         /* Do pixel averaging after every 'ScaleFactor' scanlines */
         if (LineRead && i >= xMin)
         {
            Index++;
            if (!(Index % ScaleFactor))
            {
               HSstore_line_type27 (Index / ScaleFactor - 1,
                                    ScaleFactor,
                                    Red,
                                    Green,
                                    Blue,
                                    yMin,
                                    yMax,
                                    vertical,
                                    texture_rgb);
            }
         }
      }
   }
   else
   {
      for (i = 0; i <= yMax && LineRead; i++)
      {
         j = Index % ScaleFactor;
         LineRead = HSread_line_from_rle27( f_ptr,
                                            &k,
                                            Width,
                                            Red[j],
                                            Green[j],
                                            Blue[j]);

         /* Do pixel averaging after every 'ScaleFactor' scanlines */
         if (LineRead && i >= yMin)
         {
            Index++;
            if (!(Index % ScaleFactor))
            {
               HSstore_line_type27( Index / ScaleFactor - 1,
                                    ScaleFactor,
                                    Red,
                                    Green,
                                    Blue,
                                    xMin,
                                    xMax,
                                    vertical,
                                    texture_rgb);
            }
         }
      }
   }
}

/*---HSreadtexture_type25------------------------------------------_*/

HSreadtexture_type25 (int             *fd,
                      short           Height,
                      short           Width,
                      int             vertical,
                      unsigned short  *texture_rgb)

/*
NAME
        HSreadtexture_type25

DESCRIPTION
        Reads a type25 texture file and scales it by a factor of
        1/2 or 1/4 depending on the desired size passed in
        (Height x Width). Returns the rgb values in texture_rgb.

PARAMETERS
        fd (IN)           - texture file to be read
        Height (IN)       - height of raster image required
        Width (IN)        - width of raster image required
        vertical (IN)     - whether image is vertical or horizontal
        texture_rgb (OUT) - rgb raster file returned
        
GLOBALS USED
        none

HISTORY
        ??/??/91    Yvonne Chu
           Created
*/
{
   short ScaleFactor;
   int center_x, center_y;
   int xMin = 0, yMin = 0, xMax = 0, yMax = 0;
   int initial_length, final_length, length_x, length_y;
   int i, j, Index, LineRead = TRUE;
   unsigned char *Red[4], *Green[4], *Blue[4];
   unsigned short file_buf[1000];

   /* Determine scalefactor */
   length_x = SPH_XMAX - SPH_XMIN + 1;
   length_y = SPH_YMAX - SPH_YMIN + 1;

   final_length = ((length_x < length_y) ? length_y : length_x);
   initial_length = ((Width < Height) ? Width : Height);

   if (initial_length >= final_length * 4)
   {
      ScaleFactor = 4;
   }
   else
   {
      if (initial_length >= final_length * 2)
      {
         ScaleFactor = 2;
      }
      else
      {
         ScaleFactor = 1;
      }
   }

   /* Calculate boundary of texture to be read */

   center_x = Width / 2;
   center_y = Height / 2;

   switch (ScaleFactor)
   {
      case 1:
         xMin = center_x - final_length / 2;
         xMax = center_x + final_length / 2 - 1;
         yMin = center_y - final_length / 2;
         yMax = center_y + final_length / 2 - 1;
         break;

      case 2:
         xMin = center_x - final_length;
         xMax = center_x + final_length - 1;
         yMin = center_y - final_length;
         yMax = center_y + final_length - 1;
         break;

      case 4:
         xMin = center_x - final_length * 2;
         xMax = center_x + final_length * 2 - 1;
         yMin = center_y - final_length * 2;
         yMax = center_y + final_length * 2 - 1;
         break;

      default:
         printf ("in default\n");

   }

   /* Allocate buffer for reading */

   if (vertical)
   {
      initial_length = Height;
   }
   else
   {
      initial_length = Width;
   }

   for (i = 0; i < ScaleFactor; i++)
   {
      Red[i] = (unsigned char *) malloc (initial_length
                                           * sizeof (unsigned char));
      Green[i] = (unsigned char *) malloc (initial_length
                                             * sizeof (unsigned char));
      Blue[i] = (unsigned char *) malloc (initial_length
                                            * sizeof (unsigned char));
   }

   for (i = ScaleFactor; i < 4; i++)
   {
      Red[i] = NULL;
      Green[i] = NULL;
      Blue[i] = NULL;
   }


   /* Read texture */

   Index = 0;
   if (vertical)
   {
      for (i = 0; i <= xMax && LineRead; i++)
      {
         j = Index % ScaleFactor;

         LineRead = HSread_type25_scanline (fd, file_buf, Height,
                                               Red[j], Green[j], Blue[j]);

         /* Do pixel averaging after every 'ScaleFactor' scanlines */
         if (LineRead && i >= xMin)
         {
            Index++;
            if (!(Index % ScaleFactor))
            {
               HSstore_line_type25 (Index / ScaleFactor - 1,
                                    ScaleFactor,
                                    Red,
                                    Green,
                                    Blue,
                                    yMin,
                                    yMax,
                                    vertical,
                                    texture_rgb);
            }
         }
      }
   }
   else
   {
      for (i = 0; i <= yMax && LineRead; i++)
      {
         j = Index % ScaleFactor;

         LineRead = HSread_type25_scanline( fd,
                                            file_buf,
                                            Height,
                                            Red[j],
                                            Green[j],
                                            Blue[j]);

         /* Do pixel averaging after every 'ScaleFactor' scanlines */
         if (LineRead && i >= yMin)
         {
            Index++;
            if (!(Index % ScaleFactor))
            {
               HSstore_line_type25 (Index / ScaleFactor - 1,
                                    ScaleFactor,
                                    Red,
                                    Green,
                                    Blue,
                                    xMin,
                                    xMax,
                                    vertical,
                                    texture_rgb);
            }
         }
      }
   }
}

/*---HSstore_line_type27---------------------------------------------*/

HSstore_line_type27 (int             index_i,
                     int             ScaleFactor,
                     unsigned short  *R[4],
                     unsigned short  *G[4],
                     unsigned short  *B[4],
                     int             Beg,
                     int             End,
                     int             vertical,
                     unsigned short  *texture_rgb)

/*
NAME
        HSstore_line_type27

DESCRIPTION
        Reads a line of type27 texture raster data it by ScaleFactor.
        Return the rgb values in texture_rgb.

PARAMETERS
        index_i (IN)	  - specifies which line of the texture file to read
        ScaleFactor (IN)  - s.e.
        R, G, B (IN)      - temporary storage space
        Beg (IN)          - beg coord of line
        End (IN)     	  - end coord of line
        vertical (IN)	  - whether texture file is stored horizontally or
                            vertically
        texture_rgb (OUT) - rgb texture array returned

GLOBALS USED
        none

HISTORY
        ??/??/91    Yvonne Chu
           Created
*/
{
   int            i;
   int            j;
   int            k;
   int            index_j;
   unsigned long  Red;
   unsigned long  Green;
   unsigned long  Blue;
   int            length_i;
   int            length_j;
   int            area_k;


   length_i = SPH_XMAX - SPH_XMIN + 1;
   length_j = SPH_YMAX - SPH_YMIN + 1;
   area_k = length_i * length_j;

   for (i = Beg; i <= End - ScaleFactor + 1; i += ScaleFactor)
   {
      Red = 0;
      Green = 0;
      Blue = 0;
      for (j = 0; j < ScaleFactor; j++)
      {
         for (k = 0; k < ScaleFactor; k++)
         {
             Red += R[j][i + k];
             Green += G[j][i + k];
             Blue += B[j][i + k];
         }
      }

      /* Get average RGB values */

      if (vertical)
      {
         index_j = (SPH_YMAX - SPH_YMIN) - (i - Beg) / ScaleFactor;

         texture_rgb[MY_RED * area_k + index_i * length_j + index_j] =
                           (Red >> ScaleFactor);
         texture_rgb[MY_GRN * area_k + index_i * length_j + index_j] =
                           (Green >> ScaleFactor);
         texture_rgb[MY_BLU * area_k + index_i * length_j + index_j] =
                           (Blue >> ScaleFactor);
      }
      else
      {
         index_j = (i - Beg) / ScaleFactor;
         texture_rgb[MY_RED * area_k + index_j * length_j + index_i] =
                            (Red >> ScaleFactor);
         texture_rgb[MY_GRN * area_k + index_j * length_j + index_i] =
                            (Green >> ScaleFactor);
         texture_rgb[MY_BLU * area_k + index_j * length_j + index_i] =
                            (Blue >> ScaleFactor);
      }
   }
}

/*---HSstore_line_type25------------------------------------------_*/

HSstore_line_type25 (int             index_i,
                     int             ScaleFactor,
                     unsigned char   *R[4],
                     unsigned char   *G[4],
                     unsigned char   *B[4],
                     int             Beg,
                     int             End,
                     int             vertical,
                     unsigned short  *texture_rgb)

/*
NAME
        HSstore_line_type25

DESCRIPTION
        Reads a line of type25 texture raster data it by ScaleFactor.
        Return the rgb values in texture_rgb.

PARAMETERS
        index_i (IN)	  - specifies which line of the texture file to read
        ScaleFactor (IN)  - s.e.
        R, G, B (IN)      - temporary storage space
        Beg (IN)          - beg coord of line
        End (IN)     	  - end coord of line
        vertical (IN)	  - whether texture file is stored horizontally or
                           vertically
        texture_rgb (OUT) - rgb texture array returned

GLOBALS USED
        none

HISTORY
        ??/??/91    Yvonne Chu
           Created
*/
{
   int            i;
   int            j;
   int            k;
   int            index_j;
   unsigned long  Red;
   unsigned long  Green;
   unsigned long  Blue;
   int            length_i;
   int            length_j;
   int            area_k;


   length_i = SPH_XMAX - SPH_XMIN + 1;
   length_j = SPH_YMAX - SPH_YMIN + 1;
   area_k = length_i * length_j;

   for (i = Beg; i <= End - ScaleFactor + 1; i += ScaleFactor)
   {
      Red = 0;
      Green = 0;
      Blue = 0;
      for (j = 0; j < ScaleFactor; j++)
      {
         for (k = 0; k < ScaleFactor; k++)
         {
            Red += R[j][i + k];
            Green += G[j][i + k];
            Blue += B[j][i + k];
         }
      }

      /* Get average RGB values */

      if (vertical)
      {
         index_j = (SPH_YMAX - SPH_YMIN) - (i - Beg) / ScaleFactor;
         texture_rgb[MY_RED * area_k + index_i * length_j + index_j] =
                     (unsigned short) (Red >> ScaleFactor);
         texture_rgb[MY_GRN * area_k + index_i * length_j + index_j] =
                     (unsigned short) (Green >> ScaleFactor);
         texture_rgb[MY_BLU * area_k + index_i * length_j + index_j] =
                     (unsigned short) (Blue >> ScaleFactor);
      }
      else
      {
         index_j = (i - Beg) / ScaleFactor;
         texture_rgb[MY_RED * area_k + index_j * length_j + index_i] =
                     (unsigned short) (Red >> ScaleFactor);
         texture_rgb[MY_GRN * area_k + index_j * length_j + index_i] =
                     (unsigned short) (Green >> ScaleFactor);
         texture_rgb[MY_BLU * area_k + index_j * length_j + index_i] =
                     (unsigned short) (Blue >> ScaleFactor);
      }
   }
}

/*---HSsphmem_man---------------------------------------------------------_*/

HSsphmem_man (unsigned short  **sph_rgb,
              int             SPH_FILE,
              int             GET1_FREE0)

/*
NAME
        HSsphmem_man

DESCRIPTION
        Allocates space for the buffer sph_rgb. If space has already
        been allocated for the sphere raster file SPH_FILE and it
        is requested again (e.g. command stacking), the space is
        reused.

PARAMETERS
     	sph_rgb (OUT)	- buffer allocated
     	SPH_FILE (IN) 	- the sphere raster file whose space is allocated
                          for (e.g. sphdif, sphtrn) used by "Set Active
                          "/" Copy Shading Attributes"
     	GET1_FREE0 (IN) - if 1, malloc/reuse space
                          if 0, frees space if no invokation of "Set
                                Active"/"Copy Shading Attributes" is still
                                using it.
GLOBALS USED
        none

HISTORY
        ??/??/91    Yvonne Chu
           Created
*/

{
   static int             dif_cnt = 0;
   static int             fin000_cnt = 0;
   static int             fin050_cnt = 0;
   static int             fin100_cnt = 0;
   static int             trn_cnt = 0;
   static int             amb_cnt = 0;
   static int             text_cnt = 0;

   static unsigned short  *dif;
   static unsigned short  *fin000;
   static unsigned short  *fin050;
   static unsigned short  *fin100;
   static unsigned short  *trn;
   static unsigned short  *amb;
   static unsigned short  *text;


   if (dif_cnt < 0)
      dif_cnt = 0;

   if (fin000_cnt < 0)
      fin000_cnt = 0;

   if (fin050_cnt < 0)
      fin050_cnt = 0;

   if (fin100_cnt < 0)
      fin100_cnt = 0;

   if (trn_cnt < 0)
      trn_cnt = 0;

   if (amb_cnt < 0)
      amb_cnt = 0;

   if (text_cnt < 0)
      text_cnt = 0;

   switch (SPH_FILE)
   {
      case SPH_DIF:
         if (GET1_FREE0)
         {
            if (dif_cnt == 0)
            {
                dif = (unsigned short *) malloc (3 * RGB_XMAX
                                      * RGB_YMAX * sizeof (unsigned short));
            }

            *sph_rgb = dif;
            dif_cnt++;
         }
         else
         {
            dif_cnt--;
            if (dif_cnt == 0)
            {
                    free (dif);
            }
         }
         break;

      case SPH_FIN000:
         if (GET1_FREE0)
         {
            if (fin000_cnt == 0)
            {
               fin000 = (unsigned short *) malloc (3 * RGB_XMAX
                                      * RGB_YMAX * sizeof (unsigned short));
            }

            *sph_rgb = fin000;
            fin000_cnt++;
         }
         else
         {
            fin000_cnt--;
            if (fin000_cnt == 0)
            {
               free (fin000);
            }
         }
         break;

      case SPH_FIN050:
         if (GET1_FREE0)
         {
            if (fin050_cnt == 0)
            {
                    fin050 = (unsigned short *) malloc (3 * RGB_XMAX
                                      * RGB_YMAX * sizeof (unsigned short));
            }
            *sph_rgb = fin050;
            fin050_cnt++;
         }
         else
         {
            fin050_cnt--;
            if (fin050_cnt == 0)
            {
               free (fin050);
            }
         }
         break;

      case SPH_FIN100:
         if (GET1_FREE0)
         {
            if (fin100_cnt == 0)
            {
               fin100 = (unsigned short *) malloc (3 * RGB_XMAX
                                      * RGB_YMAX * sizeof (unsigned short));
            }
            *sph_rgb = fin100;
            fin100_cnt++;
         }
         else
         {
            fin100_cnt--;
            if (fin100_cnt == 0)
            {
               free (fin100);
            }
         }
         break;

      case SPH_TRN:
         if (GET1_FREE0)
         {
            if (trn_cnt == 0)
            {
               trn = (unsigned short *) malloc (3 * RGB_XMAX *
                                        RGB_YMAX * sizeof (unsigned short));
            }
            *sph_rgb = trn;
            trn_cnt++;
         }
         else
         {
            trn_cnt--;
            if (trn_cnt == 0)
            {
               free (trn);
            }
         }
         break;

      case SPH_AMB:
         if (GET1_FREE0)
         {
            if (amb_cnt == 0)
            {
                amb = (unsigned short *) malloc (3 * RGB_XMAX
                                      * RGB_YMAX * sizeof (unsigned short));
            }
            *sph_rgb = amb;
            amb_cnt++;
         }
         else
         {
            amb_cnt--;
            if (amb_cnt == 0)
            {
                    free (amb);
            }
         }
         break;

      case SPH_TEXT:
         if (GET1_FREE0)
         {
            if (text_cnt == 0)
            {
               text = (unsigned short *) malloc (3 * RGB_XMAX
                                      * RGB_YMAX * sizeof (unsigned short));
            }
            *sph_rgb = text;
            text_cnt++;
         }
         else
         {
            text_cnt--;
            if (text_cnt == 0)
            {
                    free (text);
            }
         }
         break;

      default:
         printf ("HSsphmem_man: default case\n");
         break;
   }
}

/*---HSread_line_from_rle27------------------------------------------_*/

int HSread_line_from_rle27 (FILE            *infile,
                            int             *ScanLine,
                            int             Length,
                            unsigned short  *Red,
                            unsigned short  *Green,
                            unsigned short  *Blue)

/*
NAME
        HSread_line_from_rle27

DESCRIPTION
 	Reads one scanline worth of rle from the file 'infile' and places
 	pixel information into the structures 'Red', 'Green', and 'Blue'.

PARAMETERS
        infile (IN)   - file to read from
        ScanLine (IN) - buffer
        Length (IN)   - len
        Red (OUT)     - r coord of rgb array to be returned
        Green (OUT)   - g coord of rgb array to be returned
        Blue  (OUT)   - b coord of rgb array to be returned

HISTORY
 	07/12/89    Trevor Mink
           Created
 	10/20/89    Trevor Mink
 	   Changed to read rle type 27.
*/

{
   int             i;
   int             Count = 0;
   int             EndRun;
   int             Color;
   char            Head;
   unsigned char   Buffer[127];
   unsigned short  *RGB = NULL;
   int             bytes_read = TRUE;


#if SCANNABLE
   int Total_bytes = 0, Words_to_follow;

   bytes_read = fread (LineHeader, 4 /* bytes */ , 1, infile);
   Words_to_follow = LineHeader[1];

   Total_bytes += bytes_read;
#endif

#if ECHO_READ
   printf ("LineHeader[0] = %x\n", LineHeader[0]);
   printf ("LineHeader[1] = %x\n", LineHeader[1]);
#endif

#if SCANNABLE
   bytes_read = fread (LineHeader, 4 /* bytes */ , 1, infile);
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

      for (Count = 0; Count < Length && bytes_read;)
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
                  for (i = 0; Count < EndRun && Count < Length; Count++, i++)
                  {
                     RGB[Count] = Buffer[i];
                  }
#if ECHO_READ2
                  printf (stderr, "%d different shades follow\n", Head);
#endif
               }
               /* Read one byte to get the tail of the atom */
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

                   for (; Count < EndRun && Count < Length; Count++)
                   {
                      RGB[Count] = Buffer[0];
                   }
                }
#if ECHO_READ2
                fprintf (stderr, "run length of %d follows\n", -Head);
#endif
            }
         }
      }   /* for ( Count = ... */
   }       /* for ( Color = ... */

#if SCANNABLE
   /* Check for a pad byte (in the case of odd number of total bytes read) */
   printf ("Total_bytes = %d\n", Total_bytes);
   if ((Total_bytes / 2) < (Words_to_follow + 2))
   {
      bytes_read = fread (Buffer, 1, 1, infile);
   }
#endif
   return (bytes_read);

}   /* HSread_line_from_rle27() */
