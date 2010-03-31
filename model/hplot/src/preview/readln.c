#include <stdio.h>

/*---readln-----------------------------------------*/

/*
 *  Read a line from an ascii file
 */

int	readln( FILE *fp, char *line, int buflen )

   {
   unsigned char	c;
   int			i;

   i = 0;
   while( (c=getc(fp)) != 10 && (i++) < buflen )
      {
      if( c == 0xff ) return 0;
      *line++ = c;
      }

   *line = 0;
   return 1;
   }

