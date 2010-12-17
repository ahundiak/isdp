#include "machine.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char *getcwd( s, size )
char *s;
int size;
{
   if( s != NULL )
   {
       strcpy(s, getenv( "PWD" ));
       return s;
   }
   else
       return getenv( "PWD" );
}
