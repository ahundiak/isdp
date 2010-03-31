
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
#include "exmacros.h"

#include "HSplot.h"
#include "HSplot_def.h"

#include "wl.h"
#include "HSpr_hplot.h"

/*---HPfind_seedfile---------------------------------------------*/

/*
NAME
	HPfind_seedfile
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	read the product data file and search the platforms config
	directory for the named seedfile
	
PARAMETERS
	seedfile	:(IN) : Name of the seedfile
	
HISTORY
	??/??/??	M. Lanier
		Create
*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HPfind_seedfile( IGRchar *seedfile )
#else
	IGRint	HPfind_seedfile( seedfile )

	IGRchar	*seedfile;
#endif

	{
	IGRchar	config_dir[128];
	IGRint	i;
	IGRint	sts;
	FILE	*fp;

	sts = 1;	
	for( i=0; (sts==1); i++ )
		{
		sts = ex$get_path( index = i,
				    path = config_dir,
				     len = sizeof( config_dir ) );
				     
		if( sts )
			{
			sprintf( seedfile, "%sconfig/HSplot.seed", config_dir );
			
			if( fp = fopen( seedfile, "r" ) )
				{
				
				/*
				 *  Seed file was found
				 */
				 
				fclose( fp );
				return( 1 );
				}
			}
		}
		
	/*
	 *  If you get here, then no seed file was found
	 */
	 
	return( 0 );
	}
