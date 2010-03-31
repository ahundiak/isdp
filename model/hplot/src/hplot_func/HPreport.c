#include <stdio.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HPglobal.h"

static	char	filename[80];

/*---HPopen_report_file--------------------------------------------------*/

/*
NAME
	HPopen_report_file
	
KEYWORDS
	HSplot
	debug

DESCRIPTION
	Will check for an existing file, HSplot.log in the errlog
	directory.  If found, will open the file for write
	
FUNCTIONS CALLED
	fopen
	fclose
	sprintf
	
RETURN VALUES
	outfile	: File pointer for the report file
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	FILE	*HPopen_report_file( void )
#else
	FILE	*HPopen_report_file()
#endif

	{
	FILE	*outfile;
	
	/*
	 *  Look in 3 places for the HSplot.log file...  /usr/plotwrk/errlog
	 *  /usr/tmp and the current default directory.  If not found in any
	 *  dont open the file.
	 */

	sprintf( filename, "/usr/plotwrk/errlog/HSplot.log" );

	if( (outfile = fopen( filename, "r" )) != NULL )
		{
		fclose( outfile );
		
		outfile = fopen( filename, "w" );
		}
	else
		{
		sprintf( filename, "/usr/tmp/HSplot.log" );
		
		if( (outfile = fopen( filename, "r" )) != NULL )
			{
			fclose( outfile );
			
			outfile = fopen( filename, "w" );
			}
		else
			{
			sprintf( filename, "HSplot.log" );
			
			if( (outfile = fopen( filename, "r" )) != NULL )
				{
				fclose( outfile );
				
				outfile = fopen( filename, "w" );
				}
			}
		}
	
	return( outfile );
	}
	
/*---HPflush_report_file--------------------------------------------------*/

/*
NAME
	HPflush_report_file
	
KEYWORDS
	HSplot
	debug
	
DESCRIPTION
	This will close the report file then reopen it append.  This action
	will cause any pending data to be written to the file, just in case
	process unexpectantly stop due to an abort.
	
PARAMTERS
	outfile	: File pointer for the report file
	
GLOBALS USED
	filename: The name of the report file
	
FUNCTIONS CALLED
	fclose
	fopen

HISTORY
	??/??/??	M. Lanier
		Created	
*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HPflush_report_file( FILE **outfile )
#else
	void	HPflush_report_file( outfile )

	FILE	**outfile;
#endif

	{
	/*FILE	*fopen();*/

	fclose( *outfile );
	*outfile = fopen( filename, "a" );
	}

/*---HPclose_report_file--------------------------------------------------*/

/*
NAME
	HPclose_report_file
	
KEYWORDS
	HSplot
	debug
	
DESCRIPTION
	Close the report file
	
PARAMETERS
	outfile	: File pointer for the report file
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HPclose_report_file( FILE *outfile )
#else
	void	HPclose_report_file( outfile )

	FILE	*outfile;
#endif

	{
	fclose( outfile );
	}

	
/*--HPdisplay_job_information-----------------------------------------------------*/

/*
NAME
	HPdisplay_job_information
	
KEYWORDS
	HSplot
	debug
	
DESCRIPTION
	Write information into the file specified by outfile.
	
PARAMETERS
	outfile: File pointer to which to write the information
	
GLOBALS USED
	HPglobal		: global structure
		xdits, ydits	: Size of the viewport
		tot_phys_mem	: Workstations total main memory
		tot_buf_mem	: main memory available to HSplot
		total_bytes	: memory allocated by HSplot for image/zbuffer
		band_height	: height of the band
		overlap		: number of scanlines that will overlap between bands
		total_band	: Total number of bands
		bytes_per_pixel	: Number of bytes per pixel
		replication_factor: 
		resolution	: Pixel resolution of the output device
		rastfile	: name of the output rasterfile
		line_width_constant:
		
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	HPdisplay_job_information( FILE	*outfile )
#else
	HPdisplay_job_information( outfile )

	FILE	*outfile;
#endif

	{
	fprintf( outfile, "\n\n\n" );
	fprintf( outfile, "\nHSplot --- Job Information\n\n" );
	fprintf( outfile, "   locical plot size  (pixels) ---- %10d %10d\n",	HPglobal.xdits, HPglobal.ydits );
	fprintf( outfile, "   total physical memory (bytes) -- %10d\n", 	HPglobal.tot_phys_mem );
	fprintf( outfile, "   total buffer memory (bytes) ---- %10d\n",		HPglobal.tot_buf_mem );
	fprintf( outfile, "   band buffer size (bytes) ------- %10d\n",		HPglobal.total_bytes );
	fprintf( outfile, "   band height (pixels) ----------- %10d\n",		HPglobal.band_height );
	fprintf( outfile, "   band overlap (pixels) ---------- %10d\n",		HPglobal.overlap );
	fprintf( outfile, "   number of bands ---------------- %10d\n",		HPglobal.total_bands );
	fprintf( outfile, "   bytes per pixel ---------------- %10d\n",         HPglobal.bytes_per_pixel );
	fprintf( outfile, "   replication factor ------------- %10f\n",		HPglobal.replication_factor );
	fprintf( outfile, "   device resolution -------------- %10f\n",		HPglobal.resolution );
	fprintf( outfile, "   rasterfile name ---------------- %s\n",		HPglobal.rasterfile );
	fprintf( outfile, "   line_width_constant ------------ %10f\n",		HPglobal.line_width_constant );
	fprintf( outfile, "\n\n\n" );
	}


	
/*---HPdump_window_info-----------------------------------------------------*/

/*
NAME
	HPdump_window_info
	
KEYWORDS
	HSplot
	reports
	
DESCIPTION
	Write window information to standard error
	
GLOBALS USED
	HPband_info		: globals used
		org_x, org_y	: the origin of the band viewport
		x_dits, ydits	: the size of the band viewport
		clip_range	: the band clip_range
		screen_door	: translucency mode
		z_scale		: factor at which z's are scaled
		perspective	: perspective mode
		grid_on		: 
		world_to_view_scale:
		
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	HPdump_window_info( void )
#else
	HPdump_window_info()
#endif

	{
	fprintf( stderr, "window_info\n" );
	fprintf( stderr, "   org_x, org_y ----- %17d %17d\n", HPband_info.org_x, HPband_info.org_y );
	fprintf( stderr, "   x_dits, y_dits --- %17d %17d\n", HPband_info.x_dits, HPband_info.y_dits );
	fprintf( stderr, "   clip_range ------- %17.8f %17.8f %17.8f\n",
		HPband_info.clip_range[0], HPband_info.clip_range[1], HPband_info.clip_range[2] );
	fprintf( stderr, "                      %17.8f %17.8f %17.8f\n",
		HPband_info.clip_range[3], HPband_info.clip_range[4], HPband_info.clip_range[5] );
	fprintf( stderr, "   screen_door ------ %17d\n", HPband_info.screen_door );
	fprintf( stderr, "   (x,y,z)_scale ---- %17.8f %17.8f %17.8f\n",
		HPband_info.x_scale, HPband_info.y_scale, HPband_info.z_scale );
	fprintf( stderr, "   perspective ------ %17d\n", HPglobal.perspective );
	fprintf( stderr, "   grid_on ---------- %17d\n", HPband_info.grid_on );
	fprintf( stderr, "   world_to_view_scal %17.8f\n", HPband_info.world_to_view_scale );
	}


