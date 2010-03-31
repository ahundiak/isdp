#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/fcntl.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hplot.h"
#include "HPglobal.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot.h"

#define	DEBUG	1
#define DONT_COMPILE	0

/*---HPdload_errors--------------------------------------------*/

/*
NAME
	HPdload_errors
	
KEYWORDS
	HSplot
	dload
	
DESCRIPTION
	Traps error message from the dload function and displays
	only those more severe than a warning.  I did this cause
	I was getting some warnings about the shared libraries 
	not having a symbol table.
	
PARAMETERS
	msg	:(IN) : A string containing the error message
	sev	:(IN) : The severity level of the message
	
RETURN VALUES
	none
	
FUNCTIONS CALLED
	fprintf
	
HISTORY
	01/29/92	M. Lanier
		Created
		
*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HPdload_errors( char *msg, int sev )
#else
	void	HPdload_errors( msg, sev )

	char	*msg;
	int	sev;
#endif

	{
		
	/*
	 *  Only display message that are more severe than a warning
	 */
	 
#if defined (CLIXx)
	if( sev > ERR_WARNING )
		fprintf( stderr, "%s\n", msg );
#endif

	}
	
/*---HPdload---------------------------------------------------*/

/*
NAME
	HPdload

KEYWORDS
	HSplot
	dload
		
DESCRIPTION
	Mainly used for debugging.  When the HSplot_DLOAD environment
	variable is set to 1, meaning dynamic loading is enabled for
	HSplot, attempt to dynamic load work.o from the current default
	directory.

PARAMETERS
	filename	:(IN) : string containing the object file to load
		
FUNCTIONS CALLED
	getenv		: get the HSplot_DLOAD environment variable
	sscanf		: parse the HSplot_DLOAD environment variable
	sprintf		: 
	statl		: make sure the file exist.
	trap_errors	: To set the function to trap dload errors
	dload_setopt	: set dload options
	dload		: to dynamically load work.o
	fprintf		:
	
HISTORY
	02/11/92	M. Lanier
		Added filename so caller can specify the dload object
		file.
		
	01/29/92	M. Lanier
		Created
		
*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HPdload( char *filename )
#else
	void	HPdload( filename )

	char	*filename;
#endif

	{
#	if DONT_COMPILE
#	ifdef CLIX
		struct statl	stbuf;
#	else
		struct stat	stbuf;
#	endif

	LOADDESCR	*dload_info;
	int		dload_enabled, newopt;
	char		*expr, *getenv();

	/*
	 *  First check to see if dynamic loading is enabled
	 */
	 
	dload_enabled = 0;
	expr = getenv( "HSplot_DLOAD" );
	if( expr ) sscanf( expr, "%d", &dload_enabled );

	if( dload_enabled == 1 )
		{
			
		/*
		 *  Try and load work.o fro the current default directory
		 *  Does it exist?
		 */

#		ifdef CLIX
			if( !statl( filename, &stbuf ) )
#		else
			if( !stat( filename, &stbuf ) )
#		endif
			{
				
			/*
			 *  The file exist.  Setup a function to trap errors,
			 *  tell dload to redefine the text region pointers
			 *  don't tell us when functions of variables are loaded
			 *  and then dynamic load the file
			 */
			 
			(*trap_errors)( HPdload_errors );
			newopt = dload_setopt( OPT_ADD, TEXTREDEF | PATCH );
			newopt = dload_setopt( OPT_DEL, TEXTWARN | DATAWARN );
			dload_info = dload( filename );
		
			if( dload_info )
				{					
				if( dload_info->unresolved == 0 )
					{
					fprintf( stderr, "HSplot_DLOAD: %s loaded.\n", filename );
					}
				else
					{
					fprintf( stderr, "DLOAD:\n" );
					fprintf( stderr, "  number of unresolved symbols: %d\n", dload_info->unresolved );
					fprintf( stderr, "  number of functions loaded  : %d\n", dload_info->numfuncs );
					}

#				if DEBUG
					{
					int	i;
					fprintf( stderr, "  functions loaded            :\n" );
					for( i=0; i<dload_info->numfuncs; i++ )
						fprintf( stderr, "    %s\n", dload_info->funcnames[i] );
					}
#				endif
				}
			else
				fprintf( stderr, "HSplot_DLOAD: of %s failed\n", filename );
			}
		}
#	endif
	}
