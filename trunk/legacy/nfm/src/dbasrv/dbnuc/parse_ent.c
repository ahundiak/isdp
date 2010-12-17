/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>

extern struct dba_sch *dba_csch;

/* Function:	dba_parse_ent 

Description: 	returns an entity pointer when passed an entity spec

Author: 	Brian Potter
*/
int dba_parse_ent (char_ptr, ent_ptr)
char *char_ptr;
struct dba_ent **ent_ptr;
{
  char text[3][31], *entnam=0, *text_ptr;
  int status, num, count, lng, schema=1, entnum=1;
  struct dba_sch *tsch;

  *ent_ptr = 0;

  if (!char_ptr) return (1);

  for (num=count=1; count<=2; ++count)
    { while (*char_ptr == '.') ++char_ptr;
    if (!strlen (char_ptr)) { text[count][0] = 0;  continue; }
    text_ptr = strchr (char_ptr, '.');
    if (text_ptr)
      { if ( *(text_ptr+1) != 0) num = count + 1;
      lng = text_ptr - char_ptr; }
    else lng = strlen (char_ptr);
    strncpy (text[count], char_ptr, lng);  text[count][lng] = 0;
    char_ptr += lng; }
  switch (num)
    { case 0:
      status = 99;  goto dummy_ent;
    case 1:
      schema = 0;
      status = sscanf (text[1], "%d", &entnum);
      if (status == 1)
        { status = dba_get_entnam (entnum, text[1]);
        if (status) goto dummy_ent; }
      entnam = text[1];  break;
    case 2:  case 3:
      status = sscanf (text[1], "%d", &schema);
      if (status == 1)
        { status = dba_set_sch_ptr (schema, NP, &tsch, 1);
        if (status) goto dummy_ent; }
      else
        { status = dba_set_sch_ptr (0, text[1], &tsch, 1);
        if (status) goto dummy_ent;
        schema = tsch->schema; }
      status = sscanf (text[2], "%d", &entnum);
      if (status == 1)
        { status = dba_get_entnam (entnum, text[2]);
        if (status) goto dummy_ent; }
      entnam = text[2];
      break; }
  status = dba_set_ent_ptr (schema, 0, entnam, ent_ptr, 0, 0);
dummy_ent:

  return (status);
}
