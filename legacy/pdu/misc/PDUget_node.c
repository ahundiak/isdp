#include <stdio.h>
#include <string.h>
#include <PDUstr.h>
#include <PDUproto.h>
#define  MAXLEN  512

int MYget_node_name ( name )
char  *name;
{
     FILE   *fp;
     char   *s, str[256], *substr, *token;

     fp = fopen ("/etc/hosts", "r");
     if ( !fp )
     {
          _pdm_debug("Error opening /etc/hosts file", 0);
     	  return ( -1 );
     }

     while ( (s=fgets(str, MAXLEN, fp)) != NULL )
     {
	  substr = strstr ( str, "loghost" );   /* This entry is expected  */
						/* to be indicative of the */
						/* local host node         */
	  if ( substr == NULL )
	       continue;

/* Assuming strictly that a blank is expected as a delimiter  */
/* This may not be always true, as there can also be tabs for */
/* delimiters ins the /etc/hosts file.	      - Vasu 13.02.92 */

/* Skip the first entry */

	  token = strtok ( str, " ");
	  if ( token == NULL )
	  {
		_pdm_debug ("Error getting address from the hosts file", 0);
		fclose (fp);
	  	return ( -2 );
	  }

/*  This is the node name */

	  token = strtok ( NULL, " ");
	  if ( token == NULL )
	  {
		_pdm_debug ("Error getting local node name in hosts file", 0);
		fclose (fp);
	  	return ( -2 );
	  }
	  strcpy (name, token);
	  fclose (fp);
	  return ( 0 );  
     }
     _pdm_debug ("Could not get client node name from /etc/hosts file", 0);
     fclose (fp);
     return ( -3 );
}
