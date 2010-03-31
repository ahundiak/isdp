/*
 * HSpr_co_func.h: The prototype file for the 
 * hsurf/src/co_func directory
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
extern "C" {
#endif


/*---HSrle_util.c---------------------------------------------------------------*/

extern int HSconv_double              __(( double *, int ));
extern int HSconv_short               __(( short *, int ));
extern int HSconv_int                 __(( int *, int ));
extern int HSdump_rasterfile_header   __(( struct HEADER_BLOCK * ));
extern void HSread_rasterfile_header  __(( int *, short *, short *, long *, long *, char *, char * )); 
extern void HSwrite_rasterfile_header __(( int *, short, short, long, long, char *, char * )); 
extern int HSread_type27_scanline     __(( int *, int, int, unsigned char *, unsigned char *, unsigned char * ));
extern int HSread_type25_scanline     __(( int *, unsigned short *, int, unsigned char *, unsigned char *, unsigned char * ));
extern void HSwrite_type27_scanline   __(( int *, int, int, char *, unsigned short *, unsigned short *, unsigned short * ));
extern void HSwrite_type25_scanline   __(( int *, int, int, unsigned short *, unsigned short *, unsigned short *,unsigned short * ));
extern void HSconvert_header          __(( struct HEADER_BLOCK * ));
extern void HSconvert_hdr89           __(( struct TYPE_89_HEADER * ));

#if defined(__cplusplus)
}
#endif


#undef __
