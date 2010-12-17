/* $Revision: 1.1 $ */
#include "dba.ext"

/*
Function: dba_replace_char_with
Author:   G. I. Huey
Date:     12 Jan, 1994

Description: This function replaces all occurrences of the old_char
             with the new_char.
*/

int dba_replace_char_with(char old_char, char new_char, char *string)
{
  char *ptr;

  if (!string || !old_char || !new_char || old_char == new_char) return(1);

  for (ptr = string; *ptr; ptr++) if (*ptr == old_char) *ptr = new_char;

  return(0);
}

/*
Function: dba_conv_to_dos
Author:   G. I. Huey
Date:     12 Jan, 1994

Description: This function takes a string and converts it to a dos string.
             That is it replaces all occurrences of '/' to '\'.
*/
int dba_conv_to_dos(string)
char *string;
{
  return(dba_replace_char_with('/', '\\', string));
}

/*
Function: dba_conv_to_unix
Author:   G. I. Huey
Date:     12 Jan, 1994

Description: This function takes a string and converts it to a unix string.
             That is it replaces all occurrences of '\' to '/'.
*/
int dba_conv_to_unix(string)
char *string;
{
  return(dba_replace_char_with('\\', '/', string));
}
