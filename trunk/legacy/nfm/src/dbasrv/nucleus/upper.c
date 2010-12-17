/* $Revision: 1.1 $ */
/* Function:	dba_upper 

Description: 	same as C toupper for a string

Author: 	Brian Potter
*/
int dba_upper (text_ptr)
char *text_ptr;
{
  int count;

  if (!text_ptr) return (0);

  for (count=0; count<strlen (text_ptr); ++count)

#ifdef HANGUL
    text_ptr[count] = toupper (text_ptr[count] & 0xFF);
#else
    text_ptr[count] = toupper (text_ptr[count]);
#endif

  return (0);
}
