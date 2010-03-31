#include <stdio.h>
#include <string.h>
#include "wl.h"
#include "preview.h"
#include "file.h"
#include "BMP.h"
#include "readln.h"
#include "PS.h"

#if defined (X11)
#include "timing.h"
#endif

#define	DEBUG	1

typedef unsigned short  ISCL;
 
static short		app_type_code;
static int              sl_num_bytes;
static ISCL             *scanline;

/*---open_file---------------------------------------------------*/

void  open_file( char *filename )

   {
   preview.filename = (char *)malloc( strlen(filename) + 1 );
   strcpy( preview.filename, filename );

   if( (preview.fp = fopen( filename, "rb" )) == NULL )
      {
      printf( "unable to open file: %s\n", filename );
      }
   }

static struct RGBQUAD	*BMPcolortable;

/*---read_header--------------------------------------------------*/

void  read_header()

   {
   struct header_info	*header;
   struct BITMAPFILEHEADER	bh;
   struct BITMAPINFOHEADER	bi;
   int			xfact, yfact, i;
   int			bytes_to_allocate;

   /*
    *  Allocate memory for the header.  Start with 4 bytes.  That will
    *  get us to the words to follow.  Once we know that, we will know 
    *  exactly how much to allow, then we can realloc the header.
    */

   header = (struct header_info *)malloc( 4 );
   fread( header, 1, 0x2, preview.fp );

#  if defined (BIG_ENDIAN)
   ConvShort( &header->level_type, 1 );
#  endif

#  if DEBUG
   fprintf( stderr, "level_type: %x\n", header->level_type );
#  endif

   if( header->level_type == 0x0908 )
      {
      fread( &header->wds_to_follow, 1, 0x2, preview.fp );
#     if defined (BIG_ENDIAN)
      ConvShort( &header->wds_to_follow, 1 );
#     endif

#     if DEBUG
      fprintf( stderr, "wds_to_follow: %x %d\n", header->wds_to_follow, 
                                                 header->wds_to_follow );
#     endif

      bytes_to_allocate = (header->wds_to_follow + 2) * 2;
      header = (struct header_info *)realloc( header, bytes_to_allocate );

      fread( &header->data_type_code, 1, bytes_to_allocate-4, preview.fp );

#     if defined (BIG_ENDIAN)
      ConvShort( &header->data_type_code, 1 );
      ConvShort( &header->app_type_code, 1 );
#     endif

#     if DEBUG
      fprintf( stderr, "data_type_code: %d\n", header->data_type_code );
      fprintf( stderr, "app_type_code: %d\n", header->app_type_code );
#     endif

      preview.data.rle_type = header->data_type_code;
      app_type_code = header->app_type_code;

      if( preview.data.rle_type == 25 || 
          preview.data.rle_type == 27 ||
          preview.data.rle_type == 2 )
         {
#        if defined (BIG_ENDIAN)
         ConvInt( &header->num_rows, 1 );
         ConvInt( &header->num_cols, 1 );
#        endif

#        if DEBUG   
         fprintf( stderr, "num_rows: %d\n", header->num_rows );
         fprintf( stderr, "num_cols: %d\n", header->num_cols );
#        endif

         if( preview.data.rle_type != 2 )
            {
            preview.data.xdits = header->num_rows;
            preview.data.ydits = header->num_cols;
            }
         else
            {
            preview.data.ydits = header->num_rows;
            preview.data.xdits = header->num_cols;
            }

         /*  if running the file molicule.rle, need to add 1 to ydits  */

         xfact = ((preview.data.xdits-1)/preview.width)+1;
         yfact = ((preview.data.ydits-1)/preview.height)+1;
 
         preview.dfact = xfact > yfact ? xfact : yfact;
 
         preview.xpix = preview.data.xdits / preview.dfact;
         preview.ypix = preview.data.ydits / preview.dfact;
 
         preview.num_pixels = (preview.xpix + 2) * (preview.ypix + 2);

#        if DEBUG
         fprintf( stderr, "xfact: %d\n", xfact );
         fprintf( stderr, "yfact: %d\n", yfact );
         fprintf( stderr, "dfact: %d\n", preview.dfact );
         fprintf( stderr, "xpix: %d\n", preview.xpix );
         fprintf( stderr, "ypix: %d\n", preview.ypix );
         fprintf( stderr, "num_pixels: %d\n", preview.num_pixels );
#        endif

         if( preview.data.rle_type == 2 )
            {
            int	ct_bytes;

            ct_bytes = sizeof( struct type2_colortable ) * 256;

            preview.ctbl2 = (struct type2_colortable *)malloc( ct_bytes );

            memcpy( preview.ctbl2, ((char *)header) + 0x0400, ct_bytes );

#           if defined (BIG_ENDIAN)
            for( i=0; i<256; i++ )
               {
               ConvShort( &preview.ctbl2[i].index, 1 );
               ConvShort( &preview.ctbl2[i].red, 1 );
               ConvShort( &preview.ctbl2[i].green, 1 );
               ConvShort( &preview.ctbl2[i].blue, 1 );
               }
#           endif
            }
         }
      }

   else
   if( header->level_type == 0x4d42 )
      {
      unsigned short		s;
      unsigned int		i;

      bh.bfType = header->level_type;
      fread( &i, 1, 4, preview.fp );  bh.bfSize = i;
      fread( &s, 1, 2, preview.fp );  bh.bfReserved1 = s;
      fread( &s, 1, 2, preview.fp );  bh.bfReserved2 = s;
      fread( &i, 1, 4, preview.fp );  bh.bfOffBits = i;

#     if defined (BIG_ENDIAN)
      ConvInt  ( &bh.bfSize, 1 );
      ConvShort( &bh.bfReserved1, 1 );
      ConvShort( &bh.bfReserved2, 1 );
      ConvInt  ( &bh.bfOffBits, 1 );
#     endif

      fread( &i, 1, 4, preview.fp );  bi.biSize = i;
      fread( &i, 1, 4, preview.fp );  bi.biWidth = i;
      fread( &i, 1, 4, preview.fp );  bi.biHeight = i;
      fread( &s, 1, 2, preview.fp );  bi.biPlanes = s;
      fread( &s, 1, 2, preview.fp );  bi.biBitCount = s;
      fread( &i, 1, 4, preview.fp );  bi.biCompression = i;
      fread( &i, 1, 4, preview.fp );  bi.biSizeImage = i;
      fread( &i, 1, 4, preview.fp );  bi.biXPelsPerMeter = i;
      fread( &i, 1, 4, preview.fp );  bi.biYPelsPerMeter = i;
      fread( &i, 1, 4, preview.fp );  bi.biClrUsed = i;
      fread( &i, 1, 4, preview.fp );  bi.biClrImportant = i;

#     if defined (BIG_ENDIAN)
      ConvInt  ( &bi.biSize, 1 );
      ConvInt  ( &bi.biWidth, 1 );
      ConvInt  ( &bi.biHeight, 1 );
      ConvShort( &bi.biPlanes, 1 );
      ConvShort( &bi.biBitCount, 1 );
      ConvInt  ( &bi.biCompression, 1 );
      ConvInt  ( &bi.biSizeImage, 1 );
      ConvInt  ( &bi.biXPelsPerMeter, 1 );
      ConvInt  ( &bi.biYPelsPerMeter, 1 );
      ConvInt  ( &bi.biClrUsed, 1 );
      ConvInt  ( &bi.biClrImportant, 1 );
#     endif

      BMPcolortable = (struct RGBQUAD *)malloc( sizeof( struct RGBQUAD ) * bi.biClrUsed );

      fread( BMPcolortable, 1, sizeof( struct RGBQUAD ) * bi.biClrUsed, preview.fp );

      preview.data.rle_type = BMP;
      preview.data.xdits = bi.biWidth;
      preview.data.ydits = bi.biHeight;
      preview.dfact = 1;
      preview.xpix = preview.data.xdits;
      preview.ypix = preview.data.ydits;
      preview.num_pixels = (preview.xpix+2) * (preview.ypix+2);
      }

   else
   if( header->level_type == 0x2125 )  /* check for Postscript header */
      read_headerPS();

   else
      fprintf( stderr, "Unknown file type\n" );

   } /* read_header */

/*---translate_typeBMP-----------------------------------------------*/

void	translate_typeBMP()

   {
   int	y, x;
   char	*s;
   IBUF	*b, red, grn, blu;
   int	br;

   s = (char *)malloc( preview.data.xdits+1 );

   for( y=0; y<preview.ypix; y++ )
      {
      br = fread( s, 1, preview.xpix, preview.fp );
#     if DEBUG
      fprintf( stderr, "scanline: %d: bytes read: %d\n", y, br );
#     endif

      b = (IBUF *)preview.image_buffer + (preview.ypix-y-1) * preview.xpix;
      for( x=0; x<preview.xpix; x++ )
         {
         red = (IBUF)BMPcolortable[s[x]].rgbRed;
         grn = (IBUF)BMPcolortable[s[x]].rgbGreen;
         blu = (IBUF)BMPcolortable[s[x]].rgbBlue;

         *b++ = (blu << 16) | (grn << 8) | red;
         }
      }
   }

/*---translate_type2-----------------------------------------------*/

void	translate_type2()

   {
   int	y, x;
   char	*s;
   IBUF	*b, red, grn, blu;
   int	br;

   b = (IBUF *)preview.image_buffer;
   s = (char *)malloc( preview.data.xdits+1 );

   for( y=0; y<preview.data.ydits; y++ )
      {
      br = fread( s, 1, preview.data.xdits, preview.fp );
#     if DEBUG
      fprintf( stderr, "scanline: %d: bytes read: %d\n", y, br );
#     endif

      for( x=0; x<preview.data.xdits; x++ )
         {
         red = (IBUF)preview.ctbl2[s[x]].red;
         grn = (IBUF)preview.ctbl2[s[x]].green;
         blu = (IBUF)preview.ctbl2[s[x]].blue;

         red = (red >> 8) & 0xff;
         grn = (grn >> 8) & 0xff;
         blu = (blu >> 8) & 0xff;

         b[preview.data.xdits-x] = (blu << 16) | (grn << 8) | red;
         }

      b += preview.data.xdits;
      }
   }

/*---translate_type25----------------------------------------------*/

static void     translate_type25()

   {
   short int   		    	index_rgb();
   int				hx;
   int				sindex;
   int				dvs;
   unsigned short		header, wtf;
	
   register int			dfact;
   register unsigned short	*buffer, *bf;
   register ISCL		r, g, b, count;
   register int			x, y;
   register IBUF		*pb;
   register ISCL		*sc;

   /*
    *  Put the current address of the data buffer, which is a pointer
    *  to words, into a pointer to bytes
    */

   dvs = preview.dfact * preview.dfact;			
   buffer = (unsigned short *)malloc( preview.data.ydits * 4 );
   sindex = preview.dfact;
   memset( scanline, 0, sl_num_bytes );

   /*
    *  Do for every scanline
    */

   while( fread( &header, 1, 2, preview.fp ) > 0 )
      {
      fread( &wtf, 1, 2, preview.fp );
      fread( buffer, 1, 4, preview.fp );

#     if defined (BIG_ENDIAN)
      ConvShort( &wtf, 1 );
      ConvShort( buffer, 2 );
#     endif

/*
fprintf( stderr, "wtf: %d %x\n", wtf, wtf );
fprintf( stderr, "buffer: %x %x\n", buffer[0], buffer[1] );
*/

      bf = buffer;
      x = *bf++;

      if( (x % 25) == 0 )
         printf( "25: %d of %d\n", x, preview.xpix );
					
      sc = &scanline[(*bf++)*3];

      dfact = preview.dfact;
      y = 0;
      wtf >>= 1;
      wtf--;
      while( y <= preview.ypix * preview.dfact /*&& wtf--*/ )
         {
         fread( buffer, 1, 4, preview.fp );

#        if defined (BIG_ENDIAN)
         ConvShort( buffer, 2 );
#        endif

         bf = buffer;
         g = *bf >> 8;
         b = *bf++ & 0xff;
         r = *bf & 0xff;
         count = *bf++ >> 8;

/*
fprintf( stderr, "buffer: %x %x: %d %d %d %d\n", buffer[0], buffer[1], r, g, b, count );
*/
					
         y += count;

         while( count-- )
            {
            *(sc)   += r;
            *(sc+1) += g;
            *(sc+2) += b;

            if( !(--dfact) )
               {
               dfact = preview.dfact;
               sc += 3;
               }
            }
         }
			
      if( !(--sindex) )
         {
				
         /*
          *  The whole scanline has been processed, now generate colortable
          *  indices and place in the image buffer
          */

         pb = &preview.image_buffer[hx=x/preview.dfact] + 
                  preview.xpix * (preview.ypix-1);


         sc = scanline;

         y = preview.ypix;
         while( --y )
            {
            r = *sc++ /= dvs;
            g = *sc++ /= dvs;
            b = *sc++ /= dvs;
				
#           if defined (XGL) || defined (IRIX)
            *pb = ((b) << 16) | ((g) << 8) | (r);
#           else
            *pb = index_rgb( hx, y, r, g, b );
#           endif
            pb -= preview.xpix;
            }
			   	
         sindex = preview.dfact;
         memset( scanline, 0, sl_num_bytes );
         }
      }
   }
	
/*---translate_type27----------------------------------------------*/

static void     translate_type27()

   {
   char			n;
   unsigned char		v;
   short int		index_rgb();
   int			hx;
   int			sindex;
   int			dvs;

   register ISCL		r, g, b;
   register int		c;	
   register int		dfact;
   register int		x, y;
   register IBUF		*pb;
   register ISCL		*sc;
   register unsigned char	*buffer, *bf;

   /*
    *  Do for every scanline
    */

   dvs = preview.dfact * preview.dfact;			
   sindex = preview.dfact;
   memset( scanline, 0, sl_num_bytes );
   buffer = (unsigned char *)malloc( 128 );
	
   x = 0;	
   while( x++ < preview.data.xdits )
      {
      if( (x % 25) == 0 )
         printf( "27: %d of %d\n", x, preview.xpix );
		
      /*
       *  process a line for each color; red, green and blue
       */

      c = 3;
      while( c-- )
         {
         y = preview.data.ydits;
			
         /*
          *  Read atoms until you get to the terminator; n=0
          */
			 
         sc = &scanline[c];
         dfact = preview.dfact;
			 
         while( y )
            {
            fread( &n, 1, 1, preview.fp );

            /*
             *  Check the atom type.  If negative then it is a
             *  constant run length atom.  If positive then it is
             *  a shading atom
             */
			 
            if( n < 0 )
               {
				
               /*
                *  Get the value of the atom and fill the 
                *  portion of the scanline
                */
				 
               fread( &v, 1, 1, preview.fp );
               y += n;
               while( n++ )
                  {
                  *sc += v;

                  if( !(--dfact) )
                     {
                     dfact = preview.dfact;
                     sc += 3;
                     }
                  }					
               }
            else
               {
							
               /*
                *  Read n values and place in the scanline
                */

               fread( buffer, 1, n, preview.fp );
               bf = buffer;
               y -= n;
               while( n-- )
                  {
                  *sc += *bf++;
   
                  if( !(--dfact) )
                     {
                     dfact = preview.dfact;
                     sc += 3;
                     }
                  }
               }
            }
         }

      if( !(--sindex) )
         {
         /*
          *  The whole scanline has been processed, now generate colortable
          *  indices and place in the image buffer
          */

         pb = &preview.image_buffer[hx=x/preview.dfact] + preview.xpix * (preview.ypix-1);

         sc = scanline;

         y = preview.ypix;
         while( --y )
            {
            b = *sc++ /= dvs;
            g = *sc++ /= dvs;
            r = *sc++ /= dvs;
				
#           if defined (XGL) || defined (IRIX)
            *pb = ((b) << 16) | ((g) << 8) | (r);
#           else
            *pb = index_rgb( hx, y, r, g, b );
#           endif

            pb -= preview.xpix;
            }
				
         sindex = preview.dfact;
         memset( scanline, 0, sl_num_bytes );
         }
      }
   }
		
/*---translate_image-------------------------------------------------------*/

void    translate_image()

   {
   switch( preview.data.rle_type )
      {
      case 25:
         translate_type25();
         break;

      case 27:
         translate_type27();
         break;

      case 2:
         translate_type2();
         break;

      case BMP:
         translate_typeBMP();
         break;

      case PS:
         translate_typePS();
         break;
      }
   }

#if defined (XGL)
static int	nplanes = 24;
#else
static int	nplanes = 8;
#endif

/*---display_image----------------------------------------------------------*/

void   display_image()

   {
   int			xorg, yorg;
   int			y;
   IBUF 		*cb;
	
#if defined (X11)
   start_timing(1)
#endif

   WLhide_cursor( preview.lwin_no, 0 );
	
   xorg = (preview.width >> 1) - (preview.xpix >> 1);
   yorg = (preview.height >> 1) - (preview.ypix >> 1);

   if( app_type_code != 99 && preview.data.rle_type != 2 )
      {
      WLcreate_raster_data( 
         preview.lwin_no,
         preview.context_no,
         &preview.image,
         xorg, 
         yorg,
         preview.xpix,
         preview.ypix,
         nplanes,
         WL_SLOW_BUFFER,
         (char *)preview.image_buffer );

#if defined (X11)
      start_timing(2)
#endif
      WLput_raster_data(
         preview.lwin_no,
         preview.context_no,
         &preview.image );
#if defined (X11)
      stop_timing(2)
#endif
      }
   else
      {
      if( preview.data.rle_type == 2 )
         {
         cb = preview.image_buffer;

         for( y=xorg; y<(preview.ypix+xorg-1); y++ )
            {
            WLcreate_raster_data( 
               preview.lwin_no,
               preview.context_no,
               &preview.image,
               y, 
               yorg,
               1,
               preview.xpix,
               nplanes,
               WL_SLOW_BUFFER,
               (char *)cb );

#if defined (X11)
            start_timing(2)
#endif
            WLput_raster_data(
               preview.lwin_no,
               preview.context_no,
               &preview.image );
#if defined (X11)
            stop_timing(2)
#endif

            cb += preview.data.xdits;
            }
         }
      else
         {
         cb = (IBUF *)preview.image_buffer + (preview.xpix * (preview.ypix-1));
         for( y=xorg; y<(preview.ypix+xorg-1); y++ )
            {
            WLcreate_raster_data( 
               preview.lwin_no,
               preview.context_no,
               &preview.image,
               y, 
               yorg,
               1,
               preview.xpix,
               nplanes,
               WL_SLOW_BUFFER,
               (char *)cb );

#if defined (X11)
            start_timing(2)
#endif
            WLput_raster_data(
               preview.lwin_no,
               preview.context_no,
               &preview.image );
#if defined (X11)
            stop_timing(2)
#endif

            cb -= preview.xpix;
            }
         }
      }
		
   WLshow_cursor( preview.lwin_no );
   WLflush( preview.lwin_no );

#if defined (X11)
   stop_timing(1)
#endif
   }
	
/*---allocate_memory------------------------------------------------------*/

void  allocate_memory()

   {
   preview.image_buffer = (IBUF *)calloc( preview.num_pixels, sizeof(IBUF) );
   sl_num_bytes = (preview.ypix+2) * sizeof(ISCL) * 3;
   scanline = (ISCL *)malloc( sl_num_bytes );
   }
