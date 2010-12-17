/* $Revision: 1.1 $ */
/* Function:	dba_lower 

Description: 	same as C tolower for a string

Author: 	Brian Potter
*/
int dba_lower (text_ptr)
char *text_ptr;
{
  int count;

  if (!text_ptr) return (0);

  for (count=0; count<strlen (text_ptr); ++count)

#ifdef HANGUL
    text_ptr[count] = tolower (text_ptr[count] & 0xFF);
#else
    text_ptr[count] = tolower (text_ptr[count]);
#endif

  return (0);
}
