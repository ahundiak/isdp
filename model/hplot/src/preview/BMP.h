#ifndef BMP_H
#define BMP_H

#define		BMP	-1

#define	BITMAPFILEHEADERsize	14
#define BITMAPINFOHEADERsize	40
#define RGBQUADsize		4

struct BITMAPFILEHEADER
   {
   unsigned short	bfType;		/*  the bytes "BM" for bitmap */
   unsigned int		bfSize;		/*  Total size of the file */
   unsigned short	bfReserved1;	/*  set to 0  */
   unsigned short	bfReserved2;	/*  set to 0  */
   unsigned int		bfOffBits;	/*  Offset to the bitmap bits  */
   };

struct BITMAPINFOHEADER
   {
   unsigned int		biSize;		/*  Size of this structure  */
   long			biWidth;	/*  Width of the bitmap in pixels */
   long			biHeight;	/*  Height of the bitmap in pixels */
   unsigned short	biPlanes;	/*  set to 1 */
   unsigned short	biBitCount;	/*  color bit per pixel (1,4,8 or 24) */
   unsigned int		biCompression;	/*  Compression scheme (0 to none) */
   unsigned int		biSizeImage;	/*  Size of bitmap bits in bytes */
                                        /*  (only required if compression */
                                        /*  is used) */
   long			biXPelsPerMeter; /* Horizonal res in pixels/meter */
   long			biYPelsPerMeter; /* Vertical res in pixels/meter */
   unsigned int		biClrUsed;      /*  Number of colors used in image */
   unsigned int		biClrImportant; /*  Number of important colors in image  */
   };

struct RGBQUAD
   {
   unsigned char	rgbBlue;
   unsigned char	rgbGreen;
   unsigned char	rgbRed;
   unsigned char	rgbReserved;	/* set to 0 */
   };

extern char	BMPopenFile( char * );
extern void	BMPcloseFile();
extern void	BMPwriteBITMAPFILEHEADER( struct BITMAPFILEHEADER * );
extern void	BMPwriteBITMAPINFOHEADER( struct BITMAPINFOHEADER * );
extern void	BMPwriteRGBQUAD( int, struct RGBQUAD * );
extern void	BMPwritePixel( char * );

#endif
