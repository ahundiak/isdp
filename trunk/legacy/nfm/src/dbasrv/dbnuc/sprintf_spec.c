/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"

extern char dba_text[], *dba_tic_to_code();
extern int dba_db_numbers;

/* Function:	dba_ent_spec */
char *dba_ent_spec (ent_ptr)
struct dba_ent *ent_ptr;
{
  switch (dba_db_numbers)
    { case 0:
      sprintf (dba_text, "%d.%s", ent_ptr->schema, ent_ptr->entnam);
      break;
    case 1:
      sprintf (dba_text, "%d.%d", ent_ptr->schema, ent_ptr->entnum);
      break; }

  return (dba_text);
}
/* Function:	dba_att_spec */
char *dba_att_spec (att_ptr)
struct dba_att *att_ptr;
{
  switch (dba_db_numbers)
    { case 0:
      sprintf (dba_text, "%d.%s.%s",
        att_ptr->schema, att_ptr->entnam, att_ptr->attnam);
      break;
    case 1:
      sprintf (dba_text, "%d.%d.%d",
        att_ptr->schema, att_ptr->entnum, att_ptr->attnum);
      break; }

  return (dba_text);
}
/* Function:	dba_gadg_ent_spec */
char *dba_gadg_ent_spec (gadg)
struct dba_gadget *gadg;
{
  struct dba_ent *tent;

  switch (dba_db_numbers)
    { case 0:
      if (gadg->entnam)
        sprintf (dba_text, "%d.%s", gadg->schema, gadg->entnam);
      else
        sprintf (dba_text, "%d..", gadg->schema);
      break;
    case 1:
      dba_set_ent_ptr (gadg->schema, 0, gadg->entnam, &tent, 1, 0);
      sprintf (dba_text, "%d.%d", tent->schema, tent->entnum);
      break; }

  return (dba_text);
}
/* Function:	dba_gadg_att_spec */
char *dba_gadg_att_spec (gadg)
struct dba_gadget *gadg;
{
  struct dba_ent *tent;
  struct dba_att *tatt;

  switch (dba_db_numbers)
    { case 0:
      if (gadg->entnam && gadg->attnam)
        sprintf (dba_text, "%d.%s.%s",
          gadg->schema, gadg->entnam, gadg->attnam);
      else
        sprintf (dba_text, "%d..", gadg->schema);
      break;
    case 1:
      dba_set_ent_ptr (gadg->schema, 0, gadg->entnam, &tent, 1, 0);
      dba_set_att_ptr (tent, tent->entnam, gadg->attnam, &tatt, 1, 0);
      sprintf (dba_text, "%d.%d.%d",
        tatt->schema, tatt->entnum, tatt->attnum);
      break; }

  return (dba_text);
}
/* Function:	dba_line_ent_spec */
char *dba_line_ent_spec (lin_ptr)
struct dba_line *lin_ptr;
{
  struct dba_ent *tent;

  switch (dba_db_numbers)
    { case 0:
      sprintf (dba_text, "%d.%s", lin_ptr->schema, lin_ptr->entnam);
      break;
    case 1:
      dba_set_ent_ptr (lin_ptr->schema, 0, lin_ptr->entnam, &tent, 1, 0);
      sprintf (dba_text, "%d.%d", tent->schema, tent->entnum);
      break; }

  return (dba_text);
}
/* Function:	dba_field_att_spec */
char *dba_field_att_spec (fld_ptr)
struct dba_field *fld_ptr;
{
  struct dba_ent *tent;
  struct dba_att *tatt;

  switch (dba_db_numbers)
    { case 0:
      sprintf (dba_text, "%d.%s.%s",
        fld_ptr->schema, fld_ptr->entnam, fld_ptr->attnam);
      break;
    case 1:
      dba_set_ent_ptr (fld_ptr->schema, 0, fld_ptr->entnam, &tent, 1, 0);
      dba_set_att_ptr (tent, tent->entnam, fld_ptr->attnam, &tatt, 1, 0);
      sprintf (dba_text, "%d.%d.%d",
        tatt->schema, tatt->entnum, tatt->attnum);
      break; }

  return (dba_text);
}
/* Function:	dba_column_spec */
char *dba_column_spec (gadg)
struct dba_gadget *gadg;
{
  char *char_ptr, column[RISMAX];
  struct dba_ent *tent;
  struct dba_att *tatt;
  static char *s1_ptr;
  static unsigned long s1_size=0;

  switch (dba_db_numbers)
    { case 0:
      return (dba_tic_to_code (gadg->query));
    case 1:
      if (!s1_size) 
        { s1_size = 100;  s1_ptr = dba_dmalloc (s1_size, DM_STATIC); }
      s1_ptr[0] = 0;
      if (strlen (gadg->entnam))
        { dba_set_ent_ptr (gadg->schema, 0, gadg->entnam, &tent, 1, 0);
        char_ptr = gadg->query;
        while (dba_parse_string (&char_ptr, column, ' ', 1))
          { dba_set_att_ptr (tent, tent->entnam, column, &tatt, 1, 0);
          sprintf (dba_text, "%d ", tatt->attnum);
          if (strlen (s1_ptr) + strlen (dba_text) + 1 > s1_size)
            { s1_size += 100;  s1_ptr = dba_drealloc (s1_ptr, s1_size); }
          strcat (s1_ptr, dba_text); } }
      return (dba_tic_to_code (s1_ptr)); }

  return (0);
}
/* Function:	dba_parse_column_spec */
int dba_parse_column_spec (gadg)
struct dba_gadget *gadg;
{
  char *char_ptr, column[RISMAX];
  int status;
  struct dba_att *tatt;
  static char *s1_ptr;
  static unsigned long s1_size=0;

  if (!s1_size) { s1_size = 100;  s1_ptr = dba_dmalloc (s1_size, DM_STATIC); }
  s1_ptr[0] = 0;
  char_ptr = gadg->query;
  while (dba_parse_string (&char_ptr, column, ' ', 1))
    { sprintf (dba_text, "%d.%s.%s", gadg->schema, gadg->entnam,
      column);
    status = dba_parse_att (dba_text, &tatt);
    if (!status)
      { sprintf (dba_text, "%s ", tatt->attnam);
      if (strlen (s1_ptr) + strlen (dba_text) + 1 > s1_size)
        { s1_size += 100;  s1_ptr = dba_drealloc (s1_ptr, s1_size); }
      strcat (s1_ptr, dba_text); } }
  if (strlen (s1_ptr) + 1 > gadg->query_lng)
    { gadg->query_lng = strlen (s1_ptr) + 1;
    gadg->query = dba_drealloc (gadg->query, gadg->query_lng); }
  strcpy (gadg->query, s1_ptr);

  return (0);
}
/* Function:	dba_join_spec */
char *dba_join_spec (from_schema, from_table, from_join,
  to_schema, to_table, to_join)
int from_schema, to_schema;
char *from_table, *from_join, *to_table, *to_join;
{
  static char join_spec[50];
  struct dba_ent *tent;
  struct dba_att *from_att, *to_att;

  if (from_schema == to_schema 
      && to_table && strcmp (from_table, to_table) == 0)
    { strcpy (join_spec, "'' ''");  return (join_spec); }

  if ((!from_join || !strlen (from_join)) && (!to_join || !strlen (to_join)))
    { strcpy (join_spec, "'' ''");  return (join_spec); }

  strcpy (join_spec, "");
  switch (dba_db_numbers)
    { case 0:
      strcat (join_spec, "'");
      if (from_join) strcat (join_spec, from_join);
      strcat (join_spec, "' '");
      if (to_join) strcat (join_spec, to_join);
      strcat (join_spec, "'");
      break;
    case 1:
      dba_set_ent_ptr (from_schema, 0, from_table, &tent, 1, 0);
      dba_set_att_ptr (tent, tent->entnam, from_join, &from_att, 1, 0);
      dba_set_ent_ptr (to_schema, 0, to_table, &tent, 1, 0);
      dba_set_att_ptr (tent, tent->entnam, to_join, &to_att, 1, 0);
      sprintf (join_spec, "'%d' '%d'", from_att->attnum, to_att->attnum);
      break; }

  return (join_spec);
}
