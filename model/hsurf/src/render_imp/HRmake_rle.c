
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/



#include <stdio.h>
#include "wl.h"  

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"

#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSsara.h"

#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "HSrle.h"

#include "HSpr_render.h"

/*---------------------------
 *  for functions
 *     HSwrite_rasterfile_header
 *     HSwrite_type25_scanline
 *     HSwrite_type27
 *     HSwrite_type25_scanline
 */
 
#include "HSpr_co_func.h"

/*---------------------------*/


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
extern "C" {
#endif

/* HRmake_rle.c */
static HRcreate_type27_header __(( int file_des, 
				   int x_dits, 
				   int y_dits));

#if defined(__cplusplus)
}
#endif


#undef __



static int	outfile; 
static char	*scanline;

#define ECHO_WRITE	0

/*---HRcreate_type27_header---------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static HRcreate_type27_header( int file_des,
				       int x_dits,
				       int y_dits )
#else
	static HRcreate_type27_header( file_des, x_dits, y_dits )

	int	file_des;
	int	x_dits, y_dits;
#endif

	{
#	if ECHO_WRITE
		printf ( "Within HRcreate_type27_header\n" );
		printf ( "file_des = %d\tx_dits = %d\ty_dits = %d\tscale_factor = %d\n",
			file_des, x_dits, y_dits, replication_factor);
#	endif

	HSwrite_rasterfile_header( &file_des,
				   /*25,*/
				   TYPE_27,
				   7,
				   x_dits,
				   y_dits,
				   NULL,
				   NULL );
	}


/*---HRwrite_line_in_rle27------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRwrite_line_in_rle27( int scanx,
				    int DisplayLength,
				 unsigned short *Red,
			 unsigned short *Green,
			 unsigned short *Blue )
#else
	void HRwrite_line_in_rle27( scanx, DisplayLength, Red, Green, Blue )

	int		scanx, DisplayLength;
	unsigned short	*Red, *Green, *Blue;
#endif

	{
	HSwrite_type27_scanline(
	/*HSwrite_type25_scanline(*/
		&outfile,
		scanx,
		DisplayLength,
		scanline,
		Red,
		Green,
		Blue );
	}

/*---HRinit_rle--------------------------------------------------------------*/

/*
 * HRinit_rle() opens the Run-Length Encoding file, writes a header to it, and allocates a
 * buffer for a scanline of rle data.
 *
 * HISTORY: ??/??/??	Created by Mike Lanier.
 *	    07/25/89	Added ScaleFactor and FileName parameters.
 *								Trevor Mink
 *
 *	    10/19/89	Changed to support type 27 rle format rather than type 25.
 *								Trevor Mink
 */

#if defined(__STDC__) || defined(__cplusplus)
	int HRinit_rle( int x_dits,
			int y_dits,
		       char *FileName )
#else
	int HRinit_rle( x_dits, y_dits, FileName )
	int x_dits, y_dits;
	char *FileName;
#endif
	
	{

#if ECHO_WRITE
	printf( "Within HRinit_rle\n" );
	printf( "x_dits = %d\ty_dits = %d\tFileName = %s\n",
		x_dits, y_dits, FileName );
#endif
	outfile = creat( FileName, 0777 );
	if ( outfile == -1) return( 1 );

	HRcreate_type27_header( outfile, x_dits, y_dits );

	/*
	 *  Allocate memory for a line.  The worst case line size is
	 *  the number of pixels in a scanline divided by 127 plus 1,
	 *  giving the number of 127 bytes segments in the scanline,
	 *  times 128 (127 shade pixels plus the count). Also, add 8
	 *  for the 4 word header.
	 */

	scanline = (char *)malloc( ( ( y_dits / 127 ) + 1 ) * 128 + 8 );

	return(0);
} /* HRinit_rle() */

/*
 * HRfini_rle() checks for processing having been prematurely ‚STOPped. If so, the header is
 * re-written to reflect the number of x scanlines written. The file is closed regardless.
 *
 * HISTORY: 07/25/89	Created.
 *								Trevor Mink
 *
 * 	    10/19/89	Changed to support type 27 rle format rather than type 25.
 *								Trevor Mink
 */

#if defined(__STDC__) || defined(__cplusplus)
	int HRfini_rle( int scanx,
			int x_dits,
			int y_dits )
#else
	int HRfini_rle( scanx, x_dits, y_dits )
	int scanx, x_dits, y_dits;
#endif
	
	{

#if ECHO_WRITE
	printf( "Within HRfini_rle\n" );
	printf( "scanx = %d\tx_dits = %d\ty_dits = %d\n", scanx, x_dits, y_dits);
#endif

	if (scanx !=  x_dits) {
		lseek( outfile, 0, 0 ); 			    /* Seek to beginning */
		HRcreate_type27_header ( outfile, scanx, y_dits  ); /* Re-write header */
		lseek( outfile, 0, 2 ); 			    /* Seek to end */
	}
	close( outfile );

	/* Free scanline buffer */
	if (scanline) free( (char *) scanline );

	return(0);
} /* HRfini_rle() */
