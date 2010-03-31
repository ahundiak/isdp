#include <stdio.h>
#include <string.h>
#include "readln.h"
#include "wl.h"
#include "preview.h"
#include "PS.h"

#define DEBUG  1

static unsigned short AtoX( char c )
   {
   switch (c)
      {
      case '0': return 0x0;
      case '1': return 0x1;
      case '2': return 0x2;
      case '3': return 0x3;
      case '4': return 0x4;
      case '5': return 0x5;
      case '6': return 0x6;
      case '7': return 0x7;
      case '8': return 0x8;
      case '9': return 0x9;
      case 'a':
      case 'A': return 0xa;
      case 'b':
      case 'B': return 0xb;
      case 'c':
      case 'C': return 0xc;
      case 'd': 
      case 'D': return 0xd;
      case 'e':
      case 'E': return 0xe;
      case 'f':
      case 'F': return 0xf;
      }

   return 0;
   }

/*---read_headerPS-----------------------------------------------*/

void   read_headerPS()
   {
   char     line[256];
   int      xdits, ydits;
   int      xfact, yfact;
   double   xs, ys;

   /*  File is postscript.  First need to close the file ane re-open  */
   /*  for read ascii access */

   fclose( preview.fp );

   preview.fp = fopen( preview.filename, "ra" );

   /*  Now read the header */

   for( ;; )
      {
      readln( preview.fp, line, 256 );
 
      if( strstr( line, "dimensions of data" ) )
         {
         sscanf( line, "%d %d", &xdits, &ydits );

         preview.data.rle_type = PS;
         preview.data.xdits = xdits;
         preview.data.ydits = ydits;
         preview.num_pixels = (preview.xpix+2) * (preview.ypix+2);

         readln( preview.fp, line, 256 );
         readln( preview.fp, line, 256 );
         readln( preview.fp, line, 256 );
         readln( preview.fp, line, 256 );
         break;
         }

      else
      if( strstr( line, "scale" ) )
         {
         if( line[0] != '/' )
            {
            sscanf( line, "%lf %lf", &xs, &ys );
 
            preview.xpix = (int)xs * 100 / 76;
            preview.ypix = (int)ys * 100 / 76;
            }
         }
      }

   if( preview.xpix > preview.data.xdits ) preview.xpix = preview.data.xdits;
   if( preview.ypix > preview.data.ydits ) preview.ypix = preview.data.ydits;

   xfact = preview.data.xdits/preview.xpix;
   yfact = preview.data.ydits/preview.ypix;

   preview.dfact = xfact > yfact ? xfact : yfact;
 
   preview.num_pixels = (preview.xpix + 2) * (preview.ypix + 2);

#  if DEBUG
   fprintf( stderr, "xfact: %d\n", xfact );
   fprintf( stderr, "yfact: %d\n", yfact );
   fprintf( stderr, "dfact: %d\n", preview.dfact );
   fprintf( stderr, "xpix: %d\n", preview.xpix );
   fprintf( stderr, "ypix: %d\n", preview.ypix );
   fprintf( stderr, "num_pixels: %d\n", preview.num_pixels );
#  endif

   } /* read_headerPS */

struct scanline
   {
   int red;
   int grn;
   int blu;
   };

/*---translate_typePS--------------------------------------------*/

void   translate_typePS()
   {
   int   x, y, i, j, k;
   char  line[256];
   IBUF  *bf, red, grn, blu;
   int   br, r, g, b;
   
   struct scanline *s, *sline, **ss;

   sline = (struct scanline *)malloc( 
      preview.data.xdits * preview.dfact * sizeof( struct scanline ) );

   ss = (struct scanline **)malloc( sizeof( struct scanline *) * preview.dfact );
 
   for( y=0; y<preview.ypix; y++ )
      {
      if( (y % 25) == 0 )
         printf( "PS: %d of %d\n", y, preview.ypix );

      s = sline;

      for( j=0; j<preview.dfact; j++ )
         {
         ss[j] = s;

         readln( preview.fp, line, 256 );

         for( i=0, x=0; x<preview.data.xdits; x++ )
            {
            red = (AtoX(line[i*6  ]) << 4) | AtoX(line[i*6+1]);
            grn = (AtoX(line[i*6+2]) << 4) | AtoX(line[i*6+3]);
            blu = (AtoX(line[i*6+4]) << 4) | AtoX(line[i*6+5]);

            i++;
            if( i >= 12 )
               {
               i = 0;
               readln( preview.fp, line, 256 );
               }

            s->red = red;
            s->grn = grn;
            s->blu = blu;
            s++;
            }
         }

      if( preview.dfact > 1 )
         {
         s = sline;
         for( x=0; x<preview.xpix; x++ )
            {
            r = g = b = 0;

            for( k=0; k<preview.dfact; k++ )
               {
               s = ss[k];

               for( j=0; j<preview.dfact; j++ )
                  {
                  r += s[j].red;
                  g += s[j].grn;
                  b += s[j].blu;
                  }

               ss[k] += preview.dfact;
               }

            sline[x].red = r/(preview.dfact * preview.dfact);
            sline[x].grn = g/(preview.dfact * preview.dfact);
            sline[x].blu = b/(preview.dfact * preview.dfact);

            s += preview.dfact;
            }
         }
 
      bf = (IBUF *)preview.image_buffer + (y * preview.xpix);

      s = sline;
      for( x=0; x<preview.xpix; x++ )
         {
         red = (IBUF)s->red;
         grn = (IBUF)s->grn;
         blu = (IBUF)s->blu;

#        if defined (XGL) || defined (IRIX)
         *bf++ = (blu << 16) | (grn << 8) | red;
#        else
         *bf++ = index_rgb( x, y, red, grn, blu );
#        endif

         *s++;
         }

      }

   }  /* translate_typePS */

