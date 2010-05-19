
/*****************************************************************

 
*****************************************************************/
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <malloc.h>

char *string_malloc(a)
char *a;
 {

  char   temp [100], temp1 [100];
  int    i = 0, j = 0, k = 0, l = 0;

  while (i < 100)
   {
     temp [i] = 0;        temp1 [i] = 0;
     i++;
   }
  i = strlen (a) + 1;
  while (a[j] != 0)
   {
     if ((a [j] == '$') && (a[j+1] != '('))
      {
        char *env = 0;

        l = 0;
        j++;
        while ((isalnum (a [j])) || (a [j] == '_'))

         {
           temp1 [l] = a [j];
           l++;         j++;
         }
        temp1 [l] = 0;
        env = (char *)getenv (&temp1[0]);
        strcat (&temp[0], env ? env : &temp1[0]);
        k = strlen (temp);
      }
     else 
      {
        temp [k] = a [j];
        j++;         k++;
      }
   }
  return ( strcpy (malloc (strlen (&temp[0]) +1 ), &temp[0]));
 }
