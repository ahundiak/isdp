
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
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

#define	SAVE_10	0
#define SAVE_26	0
#define SAVE_29	1

#define STANDALONE 0 

#define ECHO_WRITE 	0
#define ECHO_WRITE2	0

/*
 * At this point, we use True Color on the edge II for Save Image.
 */
#define PTC_RGB_BITS	4
#define TRC_RGB_BITS	8

#if !STANDALONE
/*#include "hsurf_import.h"*/
#endif

#ifndef X11
#include <tools.h>
#include <sdl.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "igrtypedef.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HStl_global.h"

#include "dpgraphics.h"

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif


/*
 *  Prototype declaration for static functions
 */


/* save_img.c */
static int HSwrite_line_in_rle29 __((FILE *outfile, int DispWidth, char *Indices));

#if defined(__cplusplus)
}
#endif


#undef __

#ifdef X11
#include "hsmachine.h"
#include "hsdef.h"

extern Display			*EXdisplay;
extern Window			EX_win[];
extern int 			EX_scr[];
extern GC			EXgc[];
extern int			EXscreen;
extern Colormap			EXcolormap[];

struct vlt_slot
{
  unsigned long pixel;
  unsigned short red;
  unsigned short green;
  unsigned short blue;
  char flags;
  char pad;
};
#endif

#if SAVE_29
static char *scanline;
#endif

/*
 * HSwrite_line_in_rle29() takes the color index values of a line of pixels, arranges them
 * in a Run-length Encoding Scheme (type 29), and places this information into a file.
 *
 * DEPENDENCIES:
 *	'outfile' must be initialized as a unix file and open for writing.
 *
 * HISTORY: 10/19/89	Adapted from a version to write in type 27 rle format.
 *								Trevor Mink
 *
 */

static int HSwrite_line_in_rle29( outfile, DispWidth, Indices )
	FILE *outfile;
	int DispWidth;
	char *Indices; {

	short p = 0, Head, index;

#if SCANNABLE_29
	char Garbage = (char) 0;
	int Words;
#endif

#if ECHO_WRITE
	printf( "Within HRwrite_line_in_rle29\n" );
	printf( "FILE = %d\tDispWidth = %d\n", outfile, DispWidth );
#endif

	index = 0;

	while ( index < DispWidth ) {
		/* Begin with the head of the atom. 'p' will then progress through the tail
		   of the atom (the tail may be only one byte or up to 127 bytes)	*/
		Head = p;

		/* Check for a run-length of at least three */
		if ( index < DispWidth - 2 && Indices[index] == Indices[index+1] &&
			Indices[index] == Indices[index+2] ) {

			/* Use negative to indicate a run-length ( rather than a number of
			   bytes to follow which each contain a shade ) */
			scanline[p++] = -3;
			scanline[p] = Indices[index];
			index += 3;
#if ECHO_WRITE
			printf( "\nA run-length has begun\n" );
			printf( "index = %d\n", index );
			printf( "scanline[Head] = %d\n", scanline[Head] );
			printf( "Indices[index] = %x\tIndices[index+1] = %x\n",
				Indices[index], Indices[index+1] );
#endif
			while ( index < DispWidth &&
				Indices[index] == Indices[index-1] &&
				scanline[Head] > MAX_NEGATIVE_RUN_LENGTH ) {

				(scanline[Head])--; /* Remember negative sign for run-length*/
				index++;
#if ECHO_WRITE
				printf( "decrementing scanline[Head] to %d and index to %d\n",
					scanline[Head], index );
#endif
			}

		} else {
			scanline[p++] = 1;
			scanline[p] = Indices[index++];
#if ECHO_WRITE
			printf( "\nDiffering shades are being collected\n" );
			printf( "index = %d\tp = %d\n", index, p );
			printf( "scanline[p] = %d\n", scanline[p] );
			printf( "Indices[index] = %x\tIndices[index+1] = %x\t",
				Indices[index], Indices[index+1] );
			printf( "Indices[index+2] = %x\n", Indices[index+2] );
#endif
			while ( index < DispWidth &&
				! ( Indices[index] == Indices[index+1] &&
				    Indices[index] == Indices[index+2] )
				&& scanline[Head] < MAX_SHADES_IN_TAIL ) {

				p++;
				scanline[p] = Indices[index];
				scanline[Head]++;
				index++;
			}
		}
		p++; /* Start a new Atom */
	}
	fwrite( scanline, p, 1, outfile );

#if SCANNABLE_29
	/* Get Total bytes (p) in terms of words for writing Words-to-follow in the scanline header */
	Words = ( p + 1 ) / 2 + 2;
#endif
#if ( SCANNABLE_29 & ECHO_WRITE )
	printf( "Total_bytes = %d\tWords to follow = %d\tHere is the rle info\n", p, Words );
	for ( i = 0; i < p; i++ )
		printf( "%d ", scanline[i] );
	printf( "\n" );
#endif
#if SCANNABLE_29
	if ( ( (int)(p / 2) * 2 ) != p )
		fwrite( &Garbage, 1, 1, outfile );	/* Write a null pad byte if p is odd */
	return ( Words );
#endif

} /* HRwrite_line_in_rle29() */

/* ---------------------------------------------------------------------------- 

   HScapture_image
 
	This routine saves the raster data in a window or a fence
	and writes out type10 run length encoded raster data in
	the standard format described in SDN 84-007. 

	HISTORY:	Created	 08/01/88	Kash J. Rangan
		 	Fixed documentation of parameters  10/19/89   S.P. Rogers  
			Added X functionality  08/27/91 	R. Druzynski

	USAGE: Follwing is a description of the arguments to the function.

	file_name 	: Pointer to a character string.
			  Name of the unix file in which the TYPE 10
			  raster data would be saved. The usual file
			  name conventions apply. 
			  
	x1,y1		: Shorts representing the pixel coordinates of the
			  upper left corner of the window area to be saved
			  relative to the window origin.

			  x coordinate is horizontal.
			  y coordinate is vertical.

	dx,dy		: Shorts representing the number of rows and columns
			  to save from the point (x1,y1).
			  NOTE: For the TRUE COLOR case, these deltas will be
			  switched so that dx means delta y on the screen and
			  dy means delta x.

	win		: Environ V window number of the window to be
			  saved. Integer.

	Return Value	:	0 - Image was successfully saved.

				1 - The input raster file for saving the
				    image specified by file_name argument
				    could not be opened for writing.

----------------------------------------------------------------------------- */

HScapture_image( file_name, x1, y1, dx, dy, win )
	char file_name[];
	unsigned short x1, y1, dx, dy;
	int win;
{
	FILE *f_ptr=NULL;
	char *char_ptr;
	short wtf;
	unsigned short *ctbl_ptr;
	int hdr89_off=0, i, j, status, vs_no;
	struct RLE_RECORD rle;
	struct TYPE_89_HEADER hdr89;
	struct HEADER_BLOCK hdr;
	unsigned short *Red=NULL, *Green=NULL, *Blue=NULL;
	int y2=0, MemSize=0;
	int xlo, ylo, xhi, yhi;
	unsigned char *RGB;
	IGRboolean true_color=FALSE;
	unsigned short temp;
        int            calibrate_flag;
        long           msg;
        short          Red_Comp,Green_Comp,Blue_Comp,Red_UnComp,Blue_UnComp,Green_UnComp;
        

#ifdef X11
	int			term_type, num_planes;
	Visual			*visual;
	XColor			color;
	XWindowAttributes 	win_attr;
	Colormap		vlt;
	XImage			*Image;
	char			*buf;
#else
	struct scr_info screen_info[MAX_SCREENS];
	struct vlt_slot vlt[512];
	long buf[1700];
#endif

#ifndef X11
	DPget_win_vs( win, &vs_no );
	Inq_screen_info( screen_info );
	true_color =(( ( screen_info[vs_no].vsi_flags & VSI_TRC_ABILITY )) && (tiling_parms.processing_mode & HS_PMODE_USE_EDGE2))  ? TRUE : FALSE  ;
#else
	vs_no = EXscreen;
	HSgetMachineInfo(&num_planes, &term_type, NULL);
	if (term_type == EDGEII_TRC)
		true_color = TRUE ;
#endif

	if( !true_color )
	{
		f_ptr = fopen( file_name, "w" );
		if ( f_ptr == NULL )
		{
#if STANDALONE
			fprintf(stderr,"Error Opening File: %s\n",file_name);
#else
			HSfile_error( 1 );
#endif

			return( 1 );
		}
	}

#ifndef X11
	Readvlt( vs_no, vlt, screen_info[vs_no].vsi_VLT_size, 0 );
	screen_info[vs_no].vsi_num_planes--;
#else
	vlt = EXcolormap[vs_no];
	num_planes--;
#endif
	/* Setup type 27 rle for true color image to be saved */
	if( true_color )
	{
		temp = dx;
		dx = dy;
		dy = temp;

		/* Get window coordinates */
#ifdef X11
		XGetWindowAttributes(EXdisplay, EX_win[win], &win_attr);
		xlo = win_attr.x;		xhi = xlo + win_attr.width;
		ylo = win_attr.y;		yhi = ylo + win_attr.height;

#else
		Inq_win_region( win, &xlo, &ylo, &xhi, &yhi );
#endif
		y2 = y1+dx+1;
		MemSize = y2 - y1;
		HRinit_rle( dy+1, dx+1, file_name );
		Red = (unsigned short *)malloc( MemSize * sizeof( unsigned short ) );
		Green = (unsigned short *)malloc( MemSize * sizeof( unsigned short ) );
		Blue = (unsigned short *)malloc( MemSize * sizeof( unsigned short ) );
	}
	else
	{
		/* write out the type10 header record */
		memset( &hdr, 0, sizeof( hdr ) );

		hdr.level_type	= TYPE_09;
		hdr.wds_to_follow  = 766;/* distance to the next TYPE_89 header record */

		hdr.gridfile_version = 3;  /* Version 3 */
#if SAVE_10
		hdr.data_type_code = TYPE_10;
#endif
#if SAVE_26
		hdr.data_type_code = TYPE_26;
#endif
#if SAVE_29
		hdr.data_type_code = TYPE_29;
#endif
		hdr.app_type_code  =  6;
		hdr.scanline_orient =0x04;

#if ( SCANNABLE_29 & SAVE_29 ) | SAVE_10 | SAVE_26
		hdr.scannable_flag = 0x01;
#endif

#if SAVE_10
		hdr.data_type_modifier = 0;
#endif
#if SAVE_26
		hdr.data_type_modifier = DTM;
#endif
		hdr.view_origin[0] =  0;
		hdr.view_origin[1] =  0;
		hdr.view_origin[2] =  0;
#ifdef X11
		visual = DefaultVisual(EXdisplay, EX_scr[vs_no]);

		hdr.vlt_size	=  visual->map_entries;
		hdr.planes 	=  (unsigned short)num_planes;
		hdr.num_cols	=  dx;
		hdr.width	=  dx;
#else
		hdr.vlt_size	=  screen_info[vs_no].vsi_VLT_size;
		hdr.planes	=  (unsigned short)screen_info[vs_no].vsi_num_planes;
		hdr.num_cols	=  dx + 1;
		hdr.width	=  dx + 1;
#endif
		hdr.num_rows	=  dy + 1;
		hdr.height	=  dy + 1;
		hdr.x_off	=  x1;
		hdr.y_off	=  y1;
		hdr.color_table_type = 1;

#ifdef X11
		hdr.num_ctbl_entries = visual->map_entries;
#else
		hdr.num_ctbl_entries = screen_info[vs_no].vsi_VLT_size;
#endif
		/* copy the color table into the header structure */

		/* Do this to pad color table with zeros up to next block */
		ctbl_ptr = (unsigned short *) hdr.ctbl;
		for ( i=0; i<384; i++ )
			*ctbl_ptr++ = 0;

		for ( i=0; i<hdr.vlt_size; i++ )
		{
#ifndef X11
			char_ptr = (char *) &vlt[i].v_red;
			hdr.ctbl[i][0] = char_ptr[1];

			char_ptr = (char *) &vlt[i].v_green;
			hdr.ctbl[i][1] = char_ptr[1];

			char_ptr = (char *) &vlt[i].v_blue;
			hdr.ctbl[i][2] = char_ptr[1];
#else
			color.pixel = i;
			XQueryColor(EXdisplay, vlt, &color);

#ifdef BIG_ENDIAN
			char_ptr = (char *) &color.red;
			hdr.ctbl[i][0] = char_ptr[0];

			char_ptr = (char *) &color.green;
			hdr.ctbl[i][1] = char_ptr[0];

			char_ptr = (char *) &color.blue;
			hdr.ctbl[i][2] = char_ptr[0];
#else
			char_ptr = (char *) &color.red;
			hdr.ctbl[i][0] = char_ptr[1];

			char_ptr = (char *) &color.green;
			hdr.ctbl[i][1] = char_ptr[1];

			char_ptr = (char *) &color.blue;
			hdr.ctbl[i][2] = char_ptr[1];
#endif							/* ifdef BIG_ENDIAN */

#endif
		}

#if SAVE_26
		/* Determine the maximum run length from the DTM word in the header */
		/* DTM ( data type modifier ) specifies the field length of run and value */
		/* Rounding is done since pow function returns a double			*/
		max_run = pow( 2.0, (double)(hdr.data_type_modifier)) -1.0 + 0.5;
		/*
		fprintf(stderr,"max_run=%x\n",max_run);
		*/
#endif
		char_ptr = (char *) &rle.color_shade;

#ifdef BIG_ENDIAN
		HSconvert_header(&hdr);
#endif

		status = fwrite(&hdr, sizeof(hdr) , 1, f_ptr);

		DPhidecursor(win);
		DPsync(win, 0);
#if SAVE_29
		/*
		 *  Allocate memory for a line.  The worst case line size is
		 *  the number of pixels in a scanline divided by 127 plus 1,
		 *  giving the number of 127 bytes segments in the scanline,
		 *  times 128 (127 shade pixels plus the count). Also, add 8
		 *  for the 4 word header.
		 */
		scanline = (char *)malloc( ( ( ( dx + 1 ) / 127 ) + 1 ) * 128 + 8 );
#endif
	} /* end else ('true_color' === FALSE) */

	/* 'dy' means "Delta x" for TRUE COLOR case */

	for ( j=0; j<dy; ++j )
	{
		HSupdate_heartbeat();

#if ( ( SAVE_29 & SCANNABLE_29 ) | SAVE_10 | SAVE_26 )
		if( !true_color )
		{
			/* write out header89 records for each scan line */
			hdr89.level_type = TYPE_89;
			hdr89.row = j+1;
			hdr89.col = 0;
			hdr89_off = ftell(f_ptr);
#ifdef BIG_ENDIAN
			HSconvert_hdr89(&hdr89);
#endif
			status = fwrite( &hdr89, sizeof(hdr89), 1, f_ptr );
		}
#endif
#ifndef X11
		if( true_color )
			/* Must give the SCREEN pixel coordinates to 'readscreen' */
			readscreen( vs_no, xlo+j+x1, ylo+y1, xlo+j+x1, ylo+y1+dx, 0, buf );
/*			getline32(win, screen_info[vs_no].vsi_plane_mask, j+x1, y1, j+x1, y1+dx, buf); */
		else
			getline(win, screen_info[vs_no].vsi_plane_mask, x1, 
						j+y1, x1+dx, j+y1, buf);
#else
		if( true_color )
			Image = XGetImage(EXdisplay, EX_win[win], x1+j, y1, 1,
					 dy+1, AllPlanes, ZPixmap);
		else
			Image = XGetImage(EXdisplay, EX_win[win], x1, y1+j, 
					 dx, 1, 0xff, ZPixmap);

		buf = Image->data;
#endif

#if ECHO_WRITE2
		printf( "file f_ptr is %d\n", f_ptr );
		printf( "geting line %d from %d to %d in at x = %d\n", j, ylo+y1, ylo+y1+dx, xlo+j+x1 );
		printf( "The buffer holds the following:\n" );
#endif
                GRsetinqcolcal(&msg,0,&calibrate_flag);
		if( true_color )
		{
			RGB = (unsigned char *)buf;
                        if (calibrate_flag)
                        {
				for( i = 0; i < y2-y1; i++ )
				{        
					Red_Comp = (unsigned short)*RGB; RGB++;
					Green_Comp = (unsigned short)*RGB; RGB++;
					Blue_Comp = (unsigned short)*RGB; RGB++;

                                        Red_UnComp=HScolor_compensate(Red_Comp << 8,1);
                                        Green_UnComp=HScolor_compensate(Green_Comp << 8,1);
                                        Blue_UnComp=HScolor_compensate(Blue_Comp << 8,1);

                                        Red[i] = Red_UnComp >> 8;
                                        Green[i] = Green_UnComp >> 8;
                                        Blue[i] = Blue_UnComp >> 8;
#if ECHO_WRITE2
					printf( "Pixel %d is %d-%d-%d \t", i, (int)(Red[i]), (int)(Green[i]), (int)(Blue[i]) );
#endif
				}
                        }
                        else
                        {   
				for( i = 0; i < y2-y1; i++ )
				{
					Red[i] = (unsigned short)*RGB; RGB++;
					Green[i] = (unsigned short)*RGB; RGB++;
					Blue[i] = (unsigned short)*RGB; RGB++;
#if ECHO_WRITE2
					printf( "Pixel %d is %d-%d-%d \t", i, (int)(Red[i]), (int)(Green[i]), (int)(Blue[i]) );
#endif
				}
                        } 
			HRwrite_line_in_rle27( x1+j, MemSize, Red, Green, Blue );

/*			HRwrite_line_in_rle27( scanx, DisplayLength, Red, Green, Blue ); */
			/* wtf = HSwrite_line_in_rle27( f_ptr, j, (dx + 1), buf ); */
#if ECHO_WRITE2
			printf( "\n" );
#endif
		}
		else
		{
#if SAVE_29
#ifdef X11
			wtf = HSwrite_line_in_rle29( f_ptr, dx, (char *)buf );
#else
			wtf = HSwrite_line_in_rle29( f_ptr, (dx + 1), (char *)buf );
#endif
#endif
#if ( SAVE_10 | SAVE_26 )
			old_value = buf[0];
			temp_len = 0;
			rle_count = 0;

			/* 'dx' means "delta y" for the TRUE COLOR case */
			for (i=0; i<=(dx); i++ )
			{
				value = buf[i];
				if (value != old_value )
				{
					rle.color_shade = 0;
					/* write an rle record when the pixel value changes */
#endif
#if SAVE_10
					rle.run_length = temp_len;
					*char_ptr = old_value;
					status = fwrite(&rle, sizeof(rle) , 1, f_ptr);
					old_value = value;
					temp_len = 1;
					rle_count++;
#endif
#if SAVE_26
					if ( temp_len <= max_run )
					{
						rle.color_shade = temp_len << (16-DTM);
						*char_ptr = old_value;
						status = fwrite(&rle, sizeof(short), 1, f_ptr);
						rle_count++;
						temp_len = 1;
						old_value = value;
					}
					else
					{
						*char_ptr = old_value;
						status = fwrite(&rle, sizeof(short), 1, f_ptr);
						rle_count++;
						rle.color_shade = temp_len;
						status = fwrite(&rle, sizeof(short), 1, f_ptr);
						rle_count++;
						old_value = value;
						temp_len = 1;
					}
#endif
#if ( SAVE_10 | SAVE_26 )
				}
				else
					++temp_len;

			} /* end of i for loop */

			/* account for the last remaining pixels in a given row that */
			/*  may not have changed value in the current scan line      */
#endif
#if SAVE_10
			rle.run_length = temp_len;
			*char_ptr = old_value;
			status = fwrite(&rle, sizeof(rle), 1, f_ptr);
			rle_count++;
			wtf = rle_count*2 + 2;
#endif
#if SAVE_26
			if ( temp_len <= max_run )
			{
				rle.color_shade = temp_len << (16-DTM);
				*char_ptr = old_value;
				status = fwrite(&rle, sizeof(short), 1, f_ptr);
				rle_count++;
			}
			else
			{
				rle.color_shade = 0;
				*char_ptr = old_value;
				status = fwrite(&rle, sizeof(short), 1, f_ptr);
				rle_count++;
				rle.color_shade = temp_len;
				status = fwrite(&rle, sizeof(short), 1, f_ptr);
				rle_count++;
			}
			wtf = rle_count + 2;
#endif
		} /* end of else */

#if ( ( SAVE_29 & SCANNABLE_29 ) | SAVE_10 | SAVE_26 )
		if( !true_color )
		{
			/* step back in file to write wtf in TYPE_89 record and reset   */
			/* the file ptr back to the end of file. This has to be done    */
			/* because number of rle records is not known in advance at the */
			/* time type89 header was written                               */
			fseek(f_ptr,(long)(hdr89_off+2),0);
#ifdef BIG_ENDIAN
			HSconv_short(&wtf,1);
#endif
			status = fwrite(&wtf, 2, 1, f_ptr);
			fseek(f_ptr, 0, 2);
		}
#endif
	} /* end of j for loop */

	if( true_color )
		HRfini_rle( 0,0,0 ); /* Close the output file */
	else
	{
#if SAVE_29
		free( scanline );
#endif
		fclose( f_ptr );
	}

	DPshowcursor( win );
	DPsync( win, 0 );

	return( 0 );

}  /* HScapture_image */
