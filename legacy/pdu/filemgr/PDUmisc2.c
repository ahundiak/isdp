#include <stdio.h>
#include <PDUfile_def.h>
#include "PDUproto.h"

void PDUfree_string(string)
char  **string;
{
  _pdm_debug("in the function PDUfree_string", 0);

  if ((*string) && (strlen(*string)))
    {
    free(*string);
    *string = NULL;
    }
}

int PDUfree_string_array(string_array, size)
char ***string_array;
int     size;
{
 int     i = 0;

 _pdm_debug("in the function PDUfree_string_array", 0);

 if (*string_array)
    {
     for (i = 0; i < size; ++i)
         {
          if (((*string_array)[i]))
             free((*string_array)[i]);
         }

      *string_array = NULL;
     }

 return(1);
}
