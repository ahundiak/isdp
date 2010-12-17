/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>

extern struct dba_sch *dba_csch;

/* Function:	dba_parse_att 

Description: 	returns an attribute pointer when passed an attribute spec

Author: 	Brian Potter
*/
int dba_parse_att (char_ptr, att_ptr)
char *char_ptr;
struct dba_att **att_ptr;
{
  char text[4][31], *entnam=0, *attnam=0, *text_ptr;
  int status, num, count, lng, schema=1, entnum=1, attnum=1;
  struct dba_sch *tsch;
  struct dba_ent *tent;

  if (!char_ptr) {
    status = 99;
    goto dummy_att; 
  }
  for (num=count=1; count<=3; ++count) {
    while (*char_ptr == '.') ++char_ptr;
    if (!strlen (char_ptr)) {
      text[count][0] = 0;
      continue; 
    }
    text_ptr = strchr (char_ptr, '.');
    if (text_ptr) {
      num = count + 1;
      lng = text_ptr - char_ptr; 
    }
    else lng = strlen (char_ptr);
    if (lng > 30) lng = 30;
    strncpy (text[count], char_ptr, lng);  text[count][lng] = 0;
    char_ptr += lng; 
  }
  switch (num) {
    case 2:
      schema = 0;
      status = sscanf (text[1], "%d", &entnum);
      if (status == 1) {
        status = dba_get_entnam (entnum, text[1]);
        if (status) goto dummy_att; 
      }
      entnam = text[1];
      status = sscanf (text[2], "%d", &attnum);
      if (status == 1) {
        status = dba_get_attnam (entnam, attnum, text[2]);
        if (status) goto dummy_att; 
      }
      attnam = text[2];
      break;
    case 3:  
      status = sscanf (text[1], "%d", &schema);
      if (status == 1) {
        status = dba_set_sch_ptr (schema, NP, &tsch, 1);
        if (status) goto dummy_att; 
      }
      else {
        status = dba_set_sch_ptr (0, text[1], &tsch, 1);
        if (status) goto dummy_att;
        schema = tsch->schema; 
      }
      status = sscanf (text[2], "%d", &entnum);
      if (status == 1) {
        status = dba_get_entnam (entnum, text[2]);
        if (status) goto dummy_att; 
      }
      entnam = text[2];
      status = sscanf (text[3], "%d", &attnum);
      if (status == 1) {
        status = dba_get_attnam (entnam, attnum, text[3]);
        if (status) goto dummy_att; 
      }
      attnam = text[3];
      break; 
    default:
      status = 99;  goto dummy_att;
  }
  dba_lower (entnam);  dba_lower (attnam);
  status = dba_set_ent_ptr (schema, 0, entnam, &tent, 0, 0);
  if (status) goto dummy_att;
  status = dba_set_att_ptr (tent, entnam, attnam, att_ptr, 0, 0);
dummy_att:
/* (cadmap memory leak due to dba_parse_where_text) 8/20/93 blp
  if (status) {
    dba_malloc_att (att_ptr, NP);
    if (schema) (*att_ptr)->schema = schema;
    else if (dba_csch) (*att_ptr)->schema = dba_csch->schema;
    else (*att_ptr)->schema = 1;
    (*att_ptr)->entnum = entnum;
    if (entnam) strcpy ((*att_ptr)->entnam, entnam);
    (*att_ptr)->attnum = attnum;
    if (attnam) strcpy ((*att_ptr)->attnam, attnam); 
  }
*/
  return (status);
}
