#include <stdio.h>
#include <string.h>
#define  MAXLEN  512

int MYgethostaddr ( name, address )
char  *name;
char  *address;
{
     FILE   *fp;
     char   *s, str[256], *substr, *token;

     fp = fopen ("/etc/hosts", "r");
     if ( !fp )
     {
          printf("Error opening /etc/hosts file\n");
     	  return ( -1 );
     }

     while ( (s=fgets(str, MAXLEN, fp)) != NULL )
     {
	  substr = strstr ( str, name );
	  if ( substr == NULL )
	       continue;

/* Assuming strictly that a blank is expected as a delimiter  */
/* This may not be always true, as there can also be tabs for */
/* delimiters ins the /etc/hosts file.	      - Vasu 13.02.92 */

	  token = strtok ( str, " ");
	  if ( token == NULL )
	  {
		printf ("Error getting address from the hosts file\n");
		fclose (fp);
	  	return ( -2 );
	  }
	  strcpy (address, token);
	  fclose (fp);
	  return ( 0 );  
     }
     printf ("Could not get address for %s from /etc/hosts file\n");
     fclose (fp);
     return ( -3 );
}
