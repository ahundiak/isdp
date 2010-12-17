/* $Revision: 1.1 $ */
/* Function:	dba_search_string */
int dba_search_string (string, word)
char *string, *word;
{
  char text[51], *text_ptr;
  int lng, status, count;

  if (!string) return (0);

  for (count=1,text_ptr=string; *text_ptr; ++count,text_ptr+=lng)
    { while (*text_ptr == ' ') ++text_ptr;  if (!(*text_ptr)) break;
    status = sscanf (text_ptr, "%50s", text);  if (status != 1) break;
    if (strcmp (text, word) == 0) return (count);
    lng = strlen (text); }

  return (0);
}
