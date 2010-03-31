
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#include <stdio.h>
#include <FI.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"

#include "HSplot.h"
#include "HSplot_def.h"

#include "wl.h"
#include "HSpr_hplot.h"

#define	PLOTFILE	0
#define	RASTERFILE	1
#define METAFILE	8
#define	INVALID		2
#define DOES_NOT_EXIST	4

#define	IGRshort	short

static struct header_block 
	{
	IGRshort	level_type;	
	IGRshort	wds_to_follow;	
	IGRshort	data_type_code;
	IGRshort	app_type_code;
	} raster_header;
	
/*---HPverify------------------------------------*/

/*
NAME
	HPverify
	
KEYWORDS
	Shaded plotting
	
DESCRIPTION
	Verify that the named file exist and is of
	the proper type
	
PARAMETERS
	f	:(IN) : the name of the file
	t	:(IN) : the type the called expects the file to be
	
RETURN VALUES
	status: tells if the file exist and is of the proper type
	
HISTORY
	??/??/??	M. Lanier
		Created
*/
	
#if defined(__STDC__) || defined(__cplusplus)
	int	HPverify( char *f,
			   int t )
#else
	int	HPverify( f, t )

	char	*f;
	int	t;
#endif

	{
	int	fp;
	char	meta_header[2];
	int	status;
	
	status = t;
	
	fp = open( f, 0 );

	if( fp == -1 )
		{
		status |= DOES_NOT_EXIST;
		}
	else
		{
		if( t == PLOTFILE )
			{
			read( fp, meta_header, 2 );
		
			if( !(meta_header[0] == 'H' &&
			      meta_header[1] == 'S') )
				{
				status |= INVALID;
				}
			}
		else
			{
			if( t == RASTERFILE )
				{
				read( fp, &raster_header, sizeof( struct header_block ) );
				
#				ifdef BIG_ENDIAN
					HSconv_short( &raster_header.level_type, 1 );
					HSconv_short( &raster_header.data_type_code, 1 );
#				endif
			
				if( raster_header.level_type != 0x0908 ||
				   (raster_header.data_type_code != 25 &&
				    raster_header.data_type_code != 27) )
					{
					status |= INVALID;
					}
				}
			}
			
		close( fp );
		}

	return( status );
	}
