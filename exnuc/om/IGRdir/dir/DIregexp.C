/*
   ABSTRACT :
   --------

   This file contains the routines used to manage the regular expressions.

   HISTORY :
   -------

   06/15/1988 : HGB - Creation Date
*/

#include <string.h> 
#include <stdio.h> 

#include "OMminimum.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIomac.h"

/* the following definitions are used by the regular expressions
   matching routines. */

#define INIT          register char *sp = instring;
#define GETC()        (*sp++)
#define PEEKC()       (*sp)
#define UNGETC(c)     (--sp)
#define RETURN(c)     return c;
#define ERROR(ic)     RETURN ( NULL )

#ifndef NT
#include <regexp.h>
#endif

#define MAX_BUF 1024

DIpre_pass ( str, string )
             register char *str, *string;
/*
   This functions transforms the received regular expression into an
   understable form for the regular expression compiler.
*/
{
  int i, j, size, length = strlen ( str );

  size = MAX_BUF;
  *string = '^';

  for (i = 0, j = 1; i < length; i++)
      switch (str [i])
      {
        case '?' : string [j++] = '.';
                   break;

        case '*' : string [j++] = '.';

        case '+' : string [j++] = '*'; 
                   break;

        case '.' : string [j++] = '\\';
                   string [j++] = '.';
                   break;

        case '^' : if (str [i-1] != '[')
                   {
                      string [j++] = '\\';
                      string [j++] = '^';
                   }
                   else
                      string [j++] = str [i];
                   break;

        case '$' : string [j++] = '\\';
                   string [j++] = '$';
                   break;

        case '|' : string [j - 1] = '|';
                   break;

        default  : string [j++] = str [i];
      }

  string [j++] = '$';
  string [j] = '\0';
  return(1);
}


DImulti_parse ( line, buffers, count )
                char *line, ***buffers;
                int  *count;
{
  int  i, index, l_index, or_pos, or_length, length = strlen ( line );
  char tmp [MAX_BUF], tmp1 [MAX_BUF], or_ok;
  
  /* count the number of | */
  for (i = 0, *count = 1; i < length; i++)
      if (line [i] == '|')
         if (i)
         {
           if (line [i - 1] != '\\')
              (*count)++;
         }
         else
           (*count)++;

  *buffers = (char **) malloc ( *count * sizeof ( char * ) );

  /* split the lines */
  for (i = 0, index = 0; i < *count; i++)
  {
    /* find a valid or_pos */
    l_index = index;
    for (or_ok = 0; !or_ok; )
    {
      if (i != (*count - 1))
      {
        or_pos = ((int)strchr ( &(line [l_index]), '|' ) - (int)(line))/
                                                               sizeof ( char );
        if (or_pos)
           if (line [or_pos - 1] != '\\')
              or_ok = 1;
           else
              or_ok = 0;
        else
           or_ok = 1;
        l_index++;
      }
      else
      {
        or_pos = length;
        or_ok = 1;
      }
    }

    or_length =  or_pos - index;
    strncpy ( tmp, &(line [index]), or_length );
    tmp [or_length] = '\0';
    index = or_pos + 1;
    
    DIpre_pass ( tmp, tmp1 );
    (*buffers) [i] = (char *) malloc ( MAX_BUF );
#ifndef NT    
    compile ( tmp1, (*buffers) [i], &((*buffers) [i] [MAX_BUF - 1]), (int)'\0' );
#endif    
  }
  return(1);
}


DImulti_step ( key, buffers, count )
               char *key, **buffers;
               int  count;
{
  int i, ok;

#ifndef NT  
  for (i = count - 1, ok = 0; (i >= 0) && (!ok); i--)
      ok = step ( key, buffers [i] );
#endif      

  return ok;
}
