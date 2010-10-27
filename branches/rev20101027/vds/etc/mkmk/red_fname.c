#include <stdio.h>
#include <string.h>

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
#define SEPARATOR_C	'/'
#elif defined(NT)
#define SEPARATOR_C	'\\'
#else
#error Unknown OS
#endif

char *red_fname (in_name)
 char *in_name;
  {
    int   i = 15, j, k = 0;
    char  temp_str [15];

    while (i--) temp_str [i - 1] = 0;
    i = strlen (in_name);
    j = i;
    while ((--j) && (in_name [j] != SEPARATOR_C));
    while (i >= j)
     {
       temp_str [k] = in_name [j];
       k++; j++;
     }
    temp_str [k] = 0;
   return (temp_str);    
  }
