#include <stdio.h>
#include "BMP.h"

static FILE	*fp = NULL;

/*---BMPopenFile----------------------------------------------*/

char	BMPopenFile( char *filename )
   {
   fp = fopen( filename, "wb" );

   return 1;
   }

/*---BMPcloseFile---------------------------------------------*/

void	BMPcloseFile()
   {
   if( fp )
      {
      fclose( fp );
      fp = NULL;
      }
   }

/*---BMPwriteBITMAPFILEHEADER------------------------------*/

void BMPwriteBITMAPFILEHEADER( struct BITMAPFILEHEADER *bf )
   {
#  if BIG_ENDIAN
   ConvShort( &bf->bfType, 1 );
   ConvInt  ( &bf->bfSize, 1 );
   ConvShort( &bf->bfReserved1, 1 );
   ConvShort( &bf->bfReserved2, 1 );
   ConvInt  ( &bf->bfOffBits, 1 );
#  endif

   fwrite( &bf->bfType,      1, 2, fp );
   fwrite( &bf->bfSize,      1, 4, fp );
   fwrite( &bf->bfReserved1, 1, 2, fp );
   fwrite( &bf->bfReserved2, 1, 2, fp );
   fwrite( &bf->bfOffBits,   1, 4, fp );
   }

/*---BMPwriteBITMAPINFOHEADER------------------------------*/

void BMPwriteBITMAPINFOHEADER( struct BITMAPINFOHEADER *bi )
   {
#  if BIG_ENDIAN
   ConvInt  ( &bi->biSize );
   ConvInt  ( &bi->biWidth );
   ConvInt  ( &bi->biHeight );
   ConvShort( &bi->biPlanes );
   ConvShort( &bi->biBitCount );
   ConvInt  ( &bi->biCompression );
   ConvInt  ( &bi->biSizeImage );
   ConvInt  ( &bi->biXPelsPerMeter );
   ConvInt  ( &bi->biYPelsPerMeter );
   ConvInt  ( &bi->biClrUsed );
   ConvInt  ( &bi->biClrImportant );
#  endif

   fwrite( &bi->biSize,          1, 4, fp );
   fwrite( &bi->biWidth,         1, 4, fp );
   fwrite( &bi->biHeight,        1, 4, fp );
   fwrite( &bi->biPlanes,        1, 2, fp );
   fwrite( &bi->biBitCount,      1, 2, fp );
   fwrite( &bi->biCompression,   1, 4, fp );
   fwrite( &bi->biSizeImage,     1, 4, fp );
   fwrite( &bi->biXPelsPerMeter, 1, 4, fp );
   fwrite( &bi->biYPelsPerMeter, 1, 4, fp );
   fwrite( &bi->biClrUsed,       1, 4, fp );
   fwrite( &bi->biClrImportant,  1, 4, fp );
   }

/*---BMPwriteRGBQUAD--------------------------------------------------*/

void BMPwriteRGBQUAD( int num, struct RGBQUAD *rgb )
   {
   fwrite( rgb, 1, num * RGBQUADsize, fp );
   }

/*---BMPwritePixel--------------------------------------------------*/

void BMPwritePixel( char *p )
   {
   fwrite( p, 1, 1, fp );
   }
