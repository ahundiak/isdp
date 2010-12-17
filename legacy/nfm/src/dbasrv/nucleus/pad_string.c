/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:    dba_pad_string */
int dba_pad_string (text, length, fill_char)
char *text;
int fill_char, length;
{
  int count;

  text[length] = 0;
  for (count=strlen (text); count<length; ++count) 
    text[count] = fill_char;

  return (0);
}
