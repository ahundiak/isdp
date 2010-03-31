#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "exsysdep.h"

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hplot.h"
#include "HStl_window.h"
#include "HPglobal.h"
#include "HSrle.h"
#include "HPtiming.h"
#include "HPdef.h"
#include "hpmsg.h"
#include "HPmacros.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"

#include "HPpr_hplot_f.h"

/*------------------------------
 *  for function
 *     HSconv_short
 */

#include "hsanimate.h"
#include "HSpr_rle_uti.h"

/*------------------------------*/


static void HPterminate_scanline27 (int last_scanline);
static void HPterminate_scanline25 (int last_scanline);
static HPanti_alias (void);

/*
 *  Static globals
 *
 *  Output file pointer
 */

static FILE *outfile;

/*
 *  Scanline input buffers
 */

static unsigned char *scan_red_top = NULL;
static unsigned char *scan_green_top = NULL;
static unsigned char *scan_blue_top = NULL;

static unsigned char *scan_red_bot = NULL;
static unsigned char *scan_green_bot = NULL;
static unsigned char *scan_blue_bot = NULL;

/*
 *  Scanline output and temporary buffers
 */

static char *ScanLine;

static unsigned char *sr;

static IGRboolean first_scanline = TRUE;

static unsigned short *scanline;
static int scany = 0;

/*
 *  Function pointer for output type.  Should convert this to
 *  switch.  A per-scanline switch can be all that bad
 */

static void (*terminate_scanline) ();

/*
 *  Debug
 */

#define DEBUG	0

static void HPwrite2X( unsigned char c )
   {
   switch( c & 0xf0 )
      {
      case 0x00: fprintf( outfile, "0" ); break;
      case 0x10: fprintf( outfile, "1" ); break;
      case 0x20: fprintf( outfile, "2" ); break;
      case 0x30: fprintf( outfile, "3" ); break;
      case 0x40: fprintf( outfile, "4" ); break;
      case 0x50: fprintf( outfile, "5" ); break;
      case 0x60: fprintf( outfile, "6" ); break;
      case 0x70: fprintf( outfile, "7" ); break;
      case 0x80: fprintf( outfile, "8" ); break;
      case 0x90: fprintf( outfile, "9" ); break;
      case 0xa0: fprintf( outfile, "a" ); break;
      case 0xb0: fprintf( outfile, "b" ); break;
      case 0xc0: fprintf( outfile, "c" ); break;
      case 0xd0: fprintf( outfile, "d" ); break;
      case 0xe0: fprintf( outfile, "e" ); break;
      case 0xf0: fprintf( outfile, "f" ); break;
      }

   switch( c & 0xf )
      {
      case 0x0: fprintf( outfile, "0" ); break;
      case 0x1: fprintf( outfile, "1" ); break;
      case 0x2: fprintf( outfile, "2" ); break;
      case 0x3: fprintf( outfile, "3" ); break;
      case 0x4: fprintf( outfile, "4" ); break;
      case 0x5: fprintf( outfile, "5" ); break;
      case 0x6: fprintf( outfile, "6" ); break;
      case 0x7: fprintf( outfile, "7" ); break;
      case 0x8: fprintf( outfile, "8" ); break;
      case 0x9: fprintf( outfile, "9" ); break;
      case 0xa: fprintf( outfile, "a" ); break;
      case 0xb: fprintf( outfile, "b" ); break;
      case 0xc: fprintf( outfile, "c" ); break;
      case 0xd: fprintf( outfile, "d" ); break;
      case 0xe: fprintf( outfile, "e" ); break;
      case 0xf: fprintf( outfile, "f" ); break;
      }
   }

/*---HPterminate_scanlinePS------------------------------------------*/

static void HPterminate_scanlinePS (int last_scanline)
   {
   int i;

   if (!last_scanline)
      {
      for( i=0; i<HPglobal.ydits; i++ )
         {
         if( i != 0 && (i % 12) == 0 ) fprintf( outfile, "\n" );

         fprintf( outfile, "%x%x%x%x%x%x",
            ((scan_red_bot[i] >> 4) & 0xf),   ((scan_red_bot[i]) & 0xf), 
            ((scan_green_bot[i] >> 4) & 0xf), ((scan_green_bot[i]) & 0xf), 
            ((scan_blue_bot[i] >> 4) & 0xf),  ((scan_blue_bot[i]) & 0xf) );
/*
         HPwrite2X( scan_red_bot[i] );
         HPwrite2X( scan_green_bot[i] );
         HPwrite2X( scan_blue_bot[i] );
*/
         }

      fprintf( outfile, "\n" );
      }

   if (last_scanline)
      {

      /*
       * If this was the last scanline, close the output file
       */

      HPwrite_PS_tail( outfile );
      fclose (outfile);

      /*
       * free( scan_red ); 
       * free( scan_blue ); 
       * free( scan_green ); 
       * free( line );
       */
      }
   else
      {

      /*
       * Reinitialize the scanline buffers to 0's
       */

      memset (scan_red_bot, 0, active_window->x_dits);
      memset (scan_green_bot, 0, active_window->x_dits);
      memset (scan_blue_bot, 0, active_window->x_dits);
      }

   } /*HPterminate_scanlinePS */

/*---HPterminate_scanline25------------------------------------------*/

/*
NAME
   HPterminate_scanline25
        
KEYWORD
   HSplot
   type 25
   memory question
                
DESCRIPTION
   Given a scanline's worth of RGB values, convert it to the type 25 raster data
   format and write into the output rasterfile.
        
PARAMETERS
   last_scanline     :(IN) :  Flag that indicates that this is the last scanline
        
GLOBALS USED
   scan_red_bot      :  Array containing the red component of every pixel
                        in the scanline
   scan_green_bot    :  Array containing the green component of every
                        pixel in the scanline
   scan_blue_bot     :  Array containing the blue component of every
                        pixel in the scanline
   scanline          :  Buffer in which to store the type 25 raster data
                        run length.  This is written to the output file.
   active_window     :  Active window global information, specifically referenced
                        x_dits, which is the width of the window in pixels
   outfile           :  File pointer for the output rasterfile
   scany             :  The current scanline index.

ALGORITHM
   The type 25 raster data run length has the following format
        
        15            0   |  The raster data buffer is an array of unsigned shorts
        ---------------
        |_   0x5900  _|   |  Header
        |_    wtf    _|   |  Words to Follow
        |_     x     _|   |  X offset of the scanline run length
        |_     y     _|   |  y offset of the scanline run length
        |_green|blue _|   |  1st run
        |_count|red  _|   |
               .
               .
               .
        |_green|blue _|   |  Last run
        |_count|red  _|   |
        ---------------

FUNCTIONS CALLED
   HSconv_short:  Called only on the SUN, converts SUN formatted short to
                  clipper format
   close       :  Close the output rasterfile
   FILE_WRITE  :  Macro that write the data to the specified file.  Also checks
                  for errors and act if one is found
NOTES
   QUESTION: memory: When last_scanline is true, the values scan_red, scan_green
      and scan_blue are free'd, at least they used to be, this code has been
      commented out.  Question is should these or anything else be free'd
      here, especially when banding.
*/

static void HPterminate_scanline25 (int last_scanline)

   {
   IGRshort p;
   IGRint count, index;
   unsigned char r, g, b;

   count = 1;
   index = 0;

   r = scan_red_bot[index];
   g = scan_green_bot[index];
   b = scan_blue_bot[index++];

   /*
    * Create the run length header.
    */

   scanline[0] = 0x5900;
   scanline[1] = 0;
   scanline[2] = scany++;
   scanline[3] = 0;
   p = 4;

   /*
    * Examine each pixel in the scanline and accumulate consecutive RGB
    * triplets that are identical or runs.  The type 25 format limits the
    * size of groups to 255, therefore the collecting continues until we find
    * a different RGB or the count exceeds 255.  For each run, which consist
    * of an RGB and count, pack it into two unsigned short and put in the
    * output buffer.
    */

   while (index < active_window->x_dits)
      {
      if (r == scan_red_bot[index] &&
          g == scan_green_bot[index] &&
          b == scan_blue_bot[index] &&
          count < 255)
         {
         count++;
         }
      else
         {
         scanline[p++] = (g << 8) | b;
         scanline[p++] = (count << 8) | r;

         r = scan_red_bot[index];
         g = scan_green_bot[index];
         b = scan_blue_bot[index];

         count = 1;
         }

      index++;
      }

   /*
    * Place the last run in the output buffer, update the words to follow,
    * convert to clipper format (if sun) and write to the output file.
    */

   scanline[p++] = (g << 8) | b;
   scanline[p++] = (count << 8) | r;
   scanline[1] = p - 2;

/*
{
int ii;

fprintf( stderr, "Scanline\n" );

for( ii=0; ii<p; ii++ )
fprintf( stderr, "   %x %d\n", scanline[ii], scanline[ii] );
}
*/

#  if BIG_ENDIAN
   HSconv_short ((short *) scanline, p + 1);
#  endif

   FILE_WRITE (scanline, 1, p * 2, outfile);

   if (last_scanline)
      {

      /*
       * If this was the last scanline, close the output file
       */

      fclose (outfile);

      /*
       * free( scan_red ); 
       * free( scan_blue ); 
       * free( scan_green ); 
       * free( line );
       */
      }
   else
      {

      /*
       * Reinitialize the scanline buffers to 0's
       */

      memset (scan_red_bot, 0, active_window->x_dits);
      memset (scan_green_bot, 0, active_window->x_dits);
      memset (scan_blue_bot, 0, active_window->x_dits);
      }

   } /* HPterminate_scanline25 */

/*---HPterminate_scanline27-----------------------------------*/

/*
NAME
     HPterminate_scanline27
        
KEYWORD
     HSplot
     type 27
        
DESCRIPTION
     takes the scanline defined in scan_red_top, scan_green_top,
     and scan_blue_top and places it into rle type 27 format with
     no altering for anti-aliasing.

PARAMETERS
     last_scanline:  Will be true is this is the last scanline
        
GLOBALS USED
     scan_red_bot      :  Array containing the red component of every pixel
                          in the scanline
     scan_green_bot    :  Array containing the green component of every
                          pixel in the scanline
     scan_blue_bot     :  Array containing the blue component of every
                          pixel in the scanline
     scanline          :  Buffer in which to store the type 25 raster data
                          run length.  This is written to the output file.
     active_window     :  Active window global information, specifically referenced
                          x_dits, which is the width of the window in pixels
     outfile           :  File pointer for the output rasterfile
     scany             :  The current scanline index.

ALGORITHM
     A type 27 run length scanline has the following format
        
     o  The output buffer is an array of unsigned chars
     o  Each scanline run length consist of three sub run length, one
        for red, one for blue and one for green.
     o  Each sub run length consist of a collection of runs.
     o  A run consist of an atom follow by a value or values, depending on the
        run type.  The atom has two purposes, 1) it is a counter and 2) it
        indicates the run type.  Note that the atom's counter can never exceed 127.
     o  The first type of run is a collection of consecutive pixels that have
        the same color value.  This type is denoted by the atom's type value being 
        negative.  The atom's counter value indicates the number of consecutive pixels
        that will be the color value.  This type will have only one color value.
     o  The second type of run is a collection of consecutive pixels that have
        a varying color values.  This type is denoted by the atom's type value being
        positive.  The atom's counter value indicates the number of consecutive pixels
        covered by this run, and the number of color values in the run.
        

FUNCTIONS CALLED
   close       :  Close the output rasterfile
   FILE_WRITE  :  Macro that write the data to the specified file.  Also checks
                    for errors and act if one is found

HISTORY
   12/19/89	Trevor Mink
      Created.

*/

static void HPterminate_scanline27 (int last_scanline)

   {
   int Color, x_dits;
   short p = 0, Head, index;
   unsigned char *ElectronGun = NULL;

   x_dits = active_window->x_dits - 1;

   /*
    * Generate a sub-run length for each color, R, G and B.
    */

   for (Color = 0; Color < 3; Color++)
      {
      switch (Color)
         {
         case RED:

            /*
             * p is initialize above ( 0 or 8 according to whether SCANNABLE
             * flag is turned on or not )
             */

            ElectronGun = scan_red_bot;
            break;

         case GREEN:
            ElectronGun = scan_green_bot;
            p = 0;
            break;

         case BLUE:
            ElectronGun = scan_blue_bot;
            p = 0;
            break;
            }

      index = 0;

      /*
       * Examine every pixel in the scanline
       */

      while (index < x_dits)
         {

         /*
          * Begin with the head of the atom. 'p' will then progress through
          * the tail of the atom (the tail may be only one byte or up to 127
          * bytes)
          */

         Head = p;

         /*
          * Check for a run-length of at least three.  If the next three
          * pixels have the same value, create a type 1 run.
          */

         if (index < (x_dits - 2) &&
             ElectronGun[index] == ElectronGun[index + 1] &&
             ElectronGun[index] == ElectronGun[index + 2])
            {

            /*
             * Use negative to indicate a run-length ( rather than a number
             * of bytes to follow which each contain a shade )
             */

            ScanLine[p++] = -3;
            ScanLine[p] = ElectronGun[index];
            index += 3;

            /*
             * keep accumulating pixels of the same color, until the count
             * exceeds the limit or a pixel of a different color is found.
             */

            while (index < x_dits &&
                   ElectronGun[index] == ElectronGun[index - 1] &&
                   ScanLine[Head] > /* MAX_NEGATIVE_RUN_LENGTH */ -127)
               {
               (ScanLine[Head])--;      /* Remember negative sign for
                                         * run-length */
               index++;
               }
            }
         else
            {
            ScanLine[p++] = 1;
            ScanLine[p] = ElectronGun[index++];

            /*
             * Continue collecting varying color values until the count hits
             * the limit, or we find three consecutive pixels with the same
             * color.
             */

            while (index < x_dits &&
                   !(index < (x_dits - 2) &&
                     ElectronGun[index] == ElectronGun[index + 1] &&
                     ElectronGun[index] == ElectronGun[index + 2]) &&
                   ScanLine[Head] < MAX_SHADES_IN_TAIL)
               {
               p++;
               ScanLine[p] = ElectronGun[index];
               ScanLine[Head]++;
               index++;

#					if DEBUG
               printf ("incrementing scanline[Head] to %d and index to %d\n",
                       ScanLine[Head], index);
#					endif
               }
            }

         p++;   /* Start a new Atom */
         }

      /*
       * Write the sub-run length into the output file
       */

      FILE_WRITE (ScanLine, 1, p, outfile);
      }

   if (last_scanline)
      {

      /*
       * This was the last scanline, close the output file
       */

      fclose (outfile);

      /*
       * free( scan_red_top ); 
       * free( scan_blue_top ); 
       * free( scan_green_top );
       * free( ScanLine );
       */
      }
   else
      {

      /*
       * Reset the scanline input buffers to 0
       */

      memset (scan_red_bot, 0, x_dits);
      memset (scan_green_bot, 0, x_dits);
      memset (scan_blue_bot, 0, x_dits);
      }

   } /* HPterminate_scanline27 */

/*---HPanti_alias-------------------------------------------------*/

static HPanti_alias (void)

   {
   unsigned char *s1 = NULL, *s2, *s3 = NULL, *s4;
   int colr, ray_x;

   for (colr = 0; colr < 3; colr++)
      {
      switch (colr)
         {
         case 0:
            s1 = scan_red_top;
            s3 = scan_red_bot;
            break;

         case 1:
            s1 = scan_green_top;
            s3 = scan_green_bot;
            break;

         case 2:
            s1 = scan_blue_top;
            s3 = scan_blue_bot;
            break;
            }

      ray_x = 0;
      while (ray_x < active_window->x_dits)
         {
         s2 = s1 + 1;
         s4 = s3 + 1;

         *s1 = (*s1 + *s2 + *s3 + *s4) >> 2;

         s1 = s2;
         s3 = s4;

         ray_x++;
         }
      }

   } /* HPanti_alias */

/*---HPfini_band--------------------------------------------------------------*/

/*
NAME
   HPfini_band
        
KEYWORD
   HSplot
   type 25
   type 27
   anti-alias
        
DESCRIPTION
   This function will read the image buffer, which consist of a
   color index, in 5 byte/pixel mode, and color index, color intensity
   in 6 byte/pixel mode, compute RGB values for all pixels and
   place the data in local array for processing by the output functions.

GLOBALS USED
   HPglobal
   active_window
        
FUNCTIONS CALLED
   FILE_WRITE
   HPcreate_hdr
   HPterminate_scanline27
   HPterminate_scanline25
   HPanti_alias
   HPtiming_start
   HPtiming_stop
   HPgenerate_unique_name
   creat
   malloc
   sprintf
        
HISTORY
   ??/??/??	M. Lanier
      Created.

   12/18/89	Trevor Mink
      Added type 27 rle output.

*/

int HPfini_band (void)

   {
   register int x, y;
   register HScbuf *cb;
   unsigned short r, g, b;
   unsigned short *base_color, *delta_color;
   int ydits, x_dits;
   int status;

   char stuff[80];

   HPtiming_start (5);

   if (HPglobal.debug)
      fprintf (stderr, "Make rle file\n");

   status = HP_I_Success;

   if (HPglobal.band_count == 1)
      {

      /*
       *  For type 25 and 27 rasterfile's, open the output file, 
       *  'write binary'.  For PS output files, open the
       *  outputfile, 'write ascii'.  For any other rasterfile
       *  type, print an error message and return
       */

      if( HPglobal.rasterfile_type == HPrasterfile_type_25 ||
          HPglobal.rasterfile_type == HPrasterfile_type_27 )
         outfile = fopen (HPglobal.rasterfile, "wb");

      else
      if( HPglobal.rasterfile_type == HPrasterfile_type_PS )
         outfile = fopen( HPglobal.rasterfile, "wa" );

      else
         {
         fprintf( stderr, "Unsupported rasterfile type\n" );
         return HP_E_UnsupRasFilTyp;
         }

      if (outfile == NULL)
#        if defined CLIX
         {
         HPmessage (HP_F_RasFilErr01, HPglobal.rasterfile,
                    HPmessage_PREFIX_PRODNAME |
                    HPmessage_CONSOLE_WRITE);

         HPgenerate_unique_name (stuff);

         sprintf (HPglobal.rasterfile, "/usr/tmp/%s.rgb", stuff);

         outfile = fopen (HPglobal.rasterfile, "wb");

         if (outfile == NULL)
            {
            HPmessage (HP_F_RasFilErr02, HPglobal.rasterfile,
                       HPmessage_PREFIX_PRODNAME |
                       HPmessage_CONSOLE_WRITE);
            }
         else
#        endif /* CLIX */
            {
            HPmessage (HP_F_RasFilErr03, NULL,
                       HPmessage_PREFIX_PRODNAME |
                       HPmessage_CONSOLE_WRITE);

            HPmessage (HP_F_RasFilErr04, HPglobal.rasterfile,
                       HPmessage_PREFIX_PRODNAME |
                       HPmessage_CONSOLE_WRITE);
            }
#        if defined CLIX
         }
#        endif

      /*
       *  For rasterfiles of type 25 and 27, create a standard
       *  ingr type 9 header.  For rasterfile rastefiles of type
       *  PS, create an appropriate header.  For anything
       *  else, print an error and return
       */

      if (HPglobal.rasterfile_type == HPrasterfile_type_25 ||
          HPglobal.rasterfile_type == HPrasterfile_type_27)
         {
         HPcreate_hdr (outfile, HPglobal.rasterfile_type);
         }

      else
      if (HPglobal.rasterfile_type == HPrasterfile_type_PS)
         {
         HPcreate_PS_header( outfile );
         }

      else
         {
         fprintf( stderr, "Unsupported rasterfile type\n" );
         return HP_E_UnsupRasFilTyp;
         }

      /*
       * Allocate memory for scanline buffers
       */

      if (HPglobal.anti_aliasing)
         {
         scan_red_top = (unsigned char *) malloc (active_window->x_dits + 1);
         scan_green_top = (unsigned char *) malloc (active_window->x_dits + 1);
         scan_blue_top = (unsigned char *) malloc (active_window->x_dits + 1);
         }

      scan_red_bot = (unsigned char *) malloc (active_window->x_dits + 1);
      scan_green_bot = (unsigned char *) malloc (active_window->x_dits + 1);
      scan_blue_bot = (unsigned char *) malloc (active_window->x_dits + 1);

      if (HPglobal.rasterfile_type == HPrasterfile_type_27)
         {

         /*
          * Allocate memory for a line.  The worst case line size is the
          * number of pixels in a scanline divided by 127 plus 1, giving the
          * number of 127 bytes segments in the scanline, times 128 (127
          * shade pixels plus the count).
          */

         ScanLine = (char *) malloc (((active_window->x_dits / 127) + 1) * 128 + 500);

         terminate_scanline = HPterminate_scanline27;
         }

      else
      if (HPglobal.rasterfile_type == HPrasterfile_type_25)
         {

         /*
          * Allocate memory for a scanline. The worst case line size is the
          * number of pixels in a scanline times 4 bytes per pixel plus 8
          * bytes for the header
          */

         scanline = (unsigned short *) malloc ((active_window->x_dits * 4) + 8);

         terminate_scanline = HPterminate_scanline25;
         }

      else
      if (HPglobal.rasterfile_type == HPrasterfile_type_PS)
         {
         terminate_scanline = HPterminate_scanlinePS;
         }

      else
         {
         fprintf( stderr, "Unsupported rasterfile type\n" );
         return HP_E_UnsupRasFilTyp;
         }

      /*
       * Initialize the scanline, bottom only, thats the one we will be
       * filling.
       */

      memset (scan_red_bot, 0, active_window->x_dits);
      memset (scan_green_bot, 0, active_window->x_dits);
      memset (scan_blue_bot, 0, active_window->x_dits);

      /*
       * Set the first scanline flag to true so we will know to make two
       * passes before building the RGB file.
       */

      first_scanline = TRUE;
      }

   if (HPglobal.bytes_per_pixel == 5)
      {
      for (y = HPglobal.overlap; y <= (active_window->y_dits - HPglobal.overlap);)
         {
         if (HPglobal.debug)
            {
            if ((y % 100) == 0)
               fprintf (stderr, "%1d\n", y);
            }

         else
         if( HPglobal.heartbeat )
            HPheartbeat();

         x_dits = active_window->x_dits/* - (HPglobal.overlap << 1)*/;

         cb = (HScbuf *) active_window->cbuf +
            (y * active_window->x_dits + HPglobal.overlap);

         for (x = x_dits; x >= 0; x--)
            {
            if (*cb == 0)
               {
               base_color = (unsigned short *) HPglobal.color_table;

               r = *base_color++;
               g = *base_color++;
               b = *base_color;
               }
            else
               {
               base_color = (unsigned short *) &HPglobal.color_table[*cb][0];

               r = *base_color++;
               g = *base_color++;
               b = *base_color;

               /*
                * dont let the RGB = <0,0,0>.  Versatec does bad things
                */

               if ((r & 0xff00) == 0 &&
                   (g & 0xff00) == 0 &&
                   (b & 0xff00) == 0)
                  {
                  r = 0x100;
                  g = 0x000;
                  b = 0x000;
                  }
               }

            cb++;

            scan_red_bot[x] = (unsigned char) (r >> 8);
            scan_green_bot[x] = (unsigned char) (g >> 8);
            scan_blue_bot[x] = (unsigned char) (b >> 8);
            }

         (*terminate_scanline) ((y == active_window->y_dits - HPglobal.overlap) &&
                           (HPglobal.band_count == (HPglobal.total_bands)));

         y++;

         }
      }

   else 
   if (HPglobal.bytes_per_pixel == 6)
      {
      for (y = HPglobal.overlap; y <= (active_window->y_dits - HPglobal.overlap);)
         {
         if (HPglobal.debug)
            {
            if ((y % 100) == 0)
               fprintf (stderr, "%1d\n", y);
            }

         else
         if( HPglobal.heartbeat )
            HPheartbeat();

         x_dits = active_window->x_dits - (HPglobal.overlap << 1);

         cb = (HScbuf *) active_window->cbuf +
            (y * active_window->x_dits + HPglobal.overlap) * 2;

         for (x = x_dits; x >= 0; x--)
            {
            if (cb[0] == 0)
               {
               base_color = (unsigned short *) HPglobal.color_table;

               r = *base_color++;
               g = *base_color++;
               b = *base_color;
               }
            else
               {
               base_color = (unsigned short *) &HPglobal.color_table[*cb][0];
               delta_color = base_color + 3;

               r = *base_color++ - *delta_color++ * cb[1];
               g = *base_color++ - *delta_color++ * cb[1];
               b = *base_color - *delta_color * cb[1];

               /*
                * dont let the RGB = <0,0,0>.  Versatec does bad things
                */

               if ((r & 0xff00) == 0 &&
                   (g & 0xff00) == 0 &&
                   (b & 0xff00) == 0)
                  {
                  r = 0x100;
                  g = 0x000;
                  b = 0x000;
                  }
               }

            cb += 2;

            scan_red_bot[x] = (unsigned char) (r >> 8);
            scan_green_bot[x] = (unsigned char) (g >> 8);
            scan_blue_bot[x] = (unsigned char) (b >> 8);
            }

         if (HPglobal.anti_aliasing)
            {
            if (y != HPglobal.overlap)
               {
               HPanti_alias ();
               }

            sr = scan_red_bot;
            scan_red_bot = scan_red_top;
            scan_red_top = sr;

            sr = scan_green_bot;
            scan_green_bot = scan_green_top;
            scan_green_top = sr;

            sr = scan_blue_bot;
            scan_blue_bot = scan_blue_top;
            scan_blue_top = sr;

            if (y != HPglobal.overlap)
               {
               (*terminate_scanline) (0);
               }
            }
         else
            {
            (*terminate_scanline) ((y == active_window->y_dits - HPglobal.overlap) &&
                           (HPglobal.band_count == (HPglobal.total_bands)));
            }

         y++;
         }

      if (HPglobal.anti_aliasing)
         (*terminate_scanline) (1);
      }

   else 
   if (HPglobal.bytes_per_pixel == 7)
      {
      for (y = HPglobal.overlap; y <= (active_window->y_dits - HPglobal.overlap);)
         {
         if (HPglobal.debug)
            {
            if ((y % 100) == 0)
               fprintf (stderr, "%1d\n", y);
            }

         else
         if( HPglobal.heartbeat )
            HPheartbeat();

         x_dits = active_window->x_dits - (HPglobal.overlap << 1);

         cb = (HScbuf *) active_window->cbuf +
            (y * active_window->x_dits + HPglobal.overlap) * 3;

         for (x = x_dits; x >= 0; x--)
            {

            /*
             * dont let the RGB = <0,0,0>.  Versatec does bad things
             */

            if (cb[0] == 0 && cb[1] == 0 && cb[2] == 0)
               {
               cb[0] = 1;
               }

            scan_red_bot[x] = cb[0];
            scan_green_bot[x] = cb[1];
            scan_blue_bot[x] = cb[2];

            cb += 3;
            }

         if (HPglobal.anti_aliasing)
            {
            if (y != HPglobal.overlap)
               {
               HPanti_alias ();
               }

            sr = scan_red_bot;
            scan_red_bot = scan_red_top;
            scan_red_top = sr;

            sr = scan_green_bot;
            scan_green_bot = scan_green_top;
            scan_green_top = sr;

            sr = scan_blue_bot;
            scan_blue_bot = scan_blue_top;
            scan_blue_top = sr;

            if (y != HPglobal.overlap)
               {
               (*terminate_scanline) (0);
               }
            }
         else
            {
            (*terminate_scanline) ((y == active_window->y_dits - HPglobal.overlap) &&
                           (HPglobal.band_count == (HPglobal.total_bands)));
            }

         y++;
         }

      if (HPglobal.anti_aliasing)
         (*terminate_scanline) (1);
      }

   HPtiming_stop (5);
   HPtiming_stop (2);
   return (HP_I_Success);
   }
