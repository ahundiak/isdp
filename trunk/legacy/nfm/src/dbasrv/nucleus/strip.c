/* $Revision: 1.1 $ */
/* Function:	dba_strip_underbars

Description: 	strips trailing underbars from the specified text string

Author: 	Brian Potter
*/
int dba_strip_underbars (text_ptr)
char *text_ptr;
{
  int count;

  for (count=strlen (text_ptr); count>0 && text_ptr[count-1]=='_'; --count)
    text_ptr[count-1] = 0;
/*
  if (!count) strcpy (text_ptr, " ");
*/

  return (0);
}

