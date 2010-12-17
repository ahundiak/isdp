/* $Revision: 1.1 $ */
/* Function:	dba_strchr 

Description: 	same as C strchr, only won't find character within quotes 
		or tics 

Author: 	Brian Potter
*/
char *dba_strchr (in_string, search_char)
char *in_string, search_char;
{
  int literal=0;

  for (; *in_string!=0; ++in_string)
    { if (*in_string == '"') 
      { if (literal & 1) literal &= ~1;  
      else if (!literal) literal |= 1; }
    else if (*in_string == '\'') 
      { if (literal & 2) literal &= ~2;  
      else if (!literal) literal |= 2; }

    if (literal) continue;

    if (*in_string == search_char) return (in_string); }

  return (0);
}
