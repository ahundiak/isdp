#include <stdio.h>

#define	SIZE_OF_REST (512-2-2-8-2-2-80-80-80-8-8-8)

static char	rest[SIZE_OF_REST];	/* buffer for rest of header */
static char	junk[80];

struct	HPplotfile_header
	{
	char		file_type[2];
	short		version;
	double		world_to_viewport_scale;
	char		save_metafile;
	char		save_rasterfile;
	char		metafile[80];
	char		rasterfile[80];
	double		xsize, ysize;
	double		line_width_constant;
	short		max_line_width;
	short		user_line_width;
	};
	
static struct HPplotfile_header		HPheader;

/*---read_header----------------------------------------------------------*/

int read_header( infil )
	
FILE	*infil;

	{
	int	sts;			/* return code from called functions */

	/*
	 *  Get the file type from the header and make sure this is 
	 *  the correct one for this metafile interpreter
	 */
	 
	sts  = fread( HPheader.file_type,                sizeof(char),   2, infil );
	sts |= fread( &HPheader.version,                 sizeof(short),  1, infil );
	sts |= fread( &HPheader.world_to_viewport_scale, sizeof(double), 1, infil );
	sts |= fread( &HPheader.save_metafile,           2,                 1, infil );
	sts |= fread( &HPheader.save_rasterfile,         2,                 1, infil );
	sts |= fread( junk,                              sizeof(char),  80, infil );
	sts |= fread( HPheader.rasterfile,               sizeof(char),  80, infil );
	sts |= fread( junk,                              sizeof(char),  80, infil );
	sts |= fread( &HPheader.xsize,                   sizeof(double), 1, infil );
	sts |= fread( &HPheader.ysize,                   sizeof(double), 1, infil );
	sts |= fread( &HPheader.line_width_constant,     sizeof(double), 1, infil );
	
	sts |= fread( rest,               sizeof(char),   SIZE_OF_REST, infil  );
	}

/*---write_header----------------------------------------------------------*/

int write_header( outfil )
	
FILE	*outfil;

	{
	int	sts;			/* return code from called functions */

	/*
	 *  Get the file type from the header and make sure this is 
	 *  the correct one for this metafile interpreter
	 */
	 
	sts  = fwrite( HPheader.file_type,                sizeof(char),   2, outfil );
	sts |= fwrite( &HPheader.version,                 sizeof(short),  1, outfil );
	sts |= fwrite( &HPheader.world_to_viewport_scale, sizeof(double), 1, outfil );
	sts |= fwrite( &HPheader.save_metafile,           2,                 1, outfil );
	sts |= fwrite( &HPheader.save_rasterfile,         2,                 1, outfil );
	sts |= fwrite( junk,                              sizeof(char),  80, outfil );
	sts |= fwrite( HPheader.rasterfile,               sizeof(char),  80, outfil );
	sts |= fwrite( junk,                              sizeof(char),  80, outfil );
	sts |= fwrite( &HPheader.xsize,                   sizeof(double), 1, outfil );
	sts |= fwrite( &HPheader.ysize,                   sizeof(double), 1, outfil );
	sts |= fwrite( &HPheader.line_width_constant,     sizeof(double), 1, outfil );
	
	sts |= fwrite( rest,               sizeof(char),   SIZE_OF_REST, outfil  );
	}

