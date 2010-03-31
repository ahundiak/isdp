#include <stdio.h>

/*---HPversion---------------------------------------------*/

/*
NAME
        HPversion
        
KEYWORD
        HSplot
        version
        
DESCRIPTION
        Displays version information for the current HSplot build
        
GLOBALS USED

FUNCTIONS CALLED

HISTORY
        Thu Feb 16 13:30:18 1995	M. Lanier
                Created
                
*/

void HPversion ()

   {
   char	*getenv(), *envr;

   envr = getenv( "CPUTYPE" );

   printf ("\n");

   if( envr != NULL )
      printf ("HSplot: 3.4 for %s\n", envr);
   else
      printf ("HSplot: 3.4\n");

   printf ("\n");
   }
