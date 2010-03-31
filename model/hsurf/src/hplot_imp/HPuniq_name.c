
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#include <stdio.h>
#include <string.h>
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


/*
#define FALSE 0
#define TRUE  ~FALSE
*/

/*--- HPgenerate_unique_name --------------------------------------------------------*/

/*
NAME
	HPgenerate_unique_name
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	This function constructs a unique file name that has the
	format: xxxxyyyyyy  where

	   xxxx  - are the unique characters from the machines network address
	           (i.e., 08-00-36-xx-xx-00).  The network address is determined
	           by reading the file corresponding to the machine's node name
	           from the /usr/lib/nodes/owned directory.

	   yyyyyy - are the last six characters of the string that represents
	            the number of seconds that have elapsed since Jan 1, 1970.

PARAMETERS
	node_name	:(IN) : Node name of the workstation
	unique_name	:(OUT): Generated unique name
	
HISTORY
	S.P. Rogers  08/24/88  Creation Date (for Generate Visible Edges)
*/

#if defined(__STDC__) || defined(__cplusplus)
	void HPgenerate_unique_name( char *node_name,
				     char *unique_name )
#else
	void HPgenerate_unique_name( node_name, unique_name )

	char *node_name;
	char *unique_name;
#endif

	{
	char     ch;
	char     filename[60];
	char     string[132];
	char     *node_string;
	char     *search_string;
	char     gmt_string[30];
	short    eof_found;
	short    found;
	int      i;
	int      cnt;
	long     gmt;
	FILE     *fp;
	

	/* open the network address file and find the    */
	/* line that contains the network address string */

	search_string = "Address";
	eof_found = FALSE;
	found = FALSE;

	strcpy( filename, "/usr/lib/nodes/owned/" );
	strcat( filename, node_name );
	
	fp = fopen( filename, "r" );
	
	if ( fp )
	   {
	   do
	     {
	     /* read to the next new-line character */
	     cnt = 0;
	     ch = getc( fp );
	     while (ch != '\n')
	        {
	        string[cnt++] = ch;
	        ch = getc( fp );
	        if ( feof( fp ) )
	           {
	           eof_found = TRUE;
	           break;
	           }
	        }
	     string[cnt++] = '\0';

	     /* see if the search_string is contained in this line */
	     for ( i = 0; i < cnt - strlen( search_string ); i++ )
	        {
	        if ( strncmp( &string[i], search_string, strlen( search_string ) ) == 0 )
	           {
	           found = TRUE;
	           break;
	           }
	        }
	     }
	   while ( (!found) && (!eof_found) );

	   fclose( fp );
	   }  /* end: if ( fp ) */

	if ( found )
	   {
	   /* the Network Address was found */

	   /* skip the first 3 dashes of the Network Address */
	   node_string = string;
	   for ( i = 0; i < 3; i++ )
	      {
	      node_string = strchr( node_string, '-' );
	      node_string++;
	      }

	   /* copy out the 4 characters that we want */
	   unique_name[0] = node_string[0];
	   unique_name[1] = node_string[1];

	   unique_name[2] = node_string[3];
	   unique_name[3] = node_string[4];
	   }
	else
	   {
	   /* attemp to find network address failed => use last 4 chars of node name instead */
	   strncpy( unique_name, &node_name[strlen(node_name)-4], 4 );
	   }
	
	unique_name[4] = '\0';
	
	/* append elapsed seconds stamp to string */
	gmt = time(0);
	sprintf( gmt_string, "%d", gmt );
	strcat( unique_name, &gmt_string[strlen(gmt_string)-6] );

	}  /* HPgenerate_unique_name */

