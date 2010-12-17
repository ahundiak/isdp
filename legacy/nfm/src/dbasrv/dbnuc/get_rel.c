/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"
#include "dmalloc.def"
#include <string.h>

char *dba_hit_list, *dba_path;
unsigned long dba_hit_size, dba_path_size;

extern struct dba_reltemp *dba_f_reltemp;

/* Function:    dba_get_relations */
int dba_get_relations (option, template, from_table, to_table, fentnam, lentnam,
  ment, att_ptr)
int option;
char *template, *from_table, *to_table;
struct dba_entnam **fentnam, **lentnam;
struct dba_ent *ment;
struct dba_att *att_ptr;
{
  char *table, tabnam[RISMAX], from[RISMAX];
  int status;
  struct dba_reltemp *reltemp;
  struct dba_reltab *reltab;

  for (reltemp=dba_f_reltemp; reltemp; reltemp=reltemp->n_reltemp)
    if (strcmp (template, reltemp->name) == 0) break;
  if (!reltemp) return (0);

  for (reltab=reltemp->f_reltab; reltab; reltab=reltab->n_reltab)
    if (strcmp (from_table, reltab->table) == 0) break;
  if (!reltab) return (0);
  for (reltab=reltemp->f_reltab; reltab; reltab=reltab->n_reltab)
    if (strcmp (to_table, reltab->table) == 0) break;
  if (!reltab) return (0);

  status = dba_create_reljoin_entnam (option, reltemp, from_table, to_table,
    fentnam, lentnam, ment, att_ptr);
  if (status) return (status);

  if (!dba_hit_size) {
    dba_hit_list = dba_dmalloc (1000, DM_STATIC);  
    dba_path = dba_dmalloc (1000, DM_STATIC);
    dba_hit_size = 1000;
    dba_path_size = 1000;
  }
  strcpy (dba_hit_list, from_table);
  strcat (dba_hit_list, " ");
  strcpy (dba_path, from_table);
  strcat (dba_path, " ");
  
  status = dba_get_reljoins (reltemp, from_table, to_table);
  if (status != 2) return (0);

  table = dba_path;
  strcpy (from, from_table);
  for (;;) {
    status = dba_parse_string (&table, tabnam, ' ', 1);
    if (!status) break;
    status = dba_create_reljoin_entnam (option, reltemp, from, tabnam,
      fentnam, lentnam, ment, att_ptr);
    strcpy (from, tabnam);
  }
  return (0);
}
/* Function:    dba_get_reljoins */
int dba_get_reljoins (reltemp, from_table, to_table)
struct dba_reltemp *reltemp;
char *from_table, *to_table;
{
  char *table, tabnam[RISMAX], *end;
  int status;
  
  static char *table_list;
  static unsigned long table_size;
 
  if (!table_size) {
    table_size = 1000;
    table_list = dba_dmalloc (table_size, DM_STATIC);
  }
  strcpy (table_list, "");

  status = dba_get_next_reljoins (reltemp, from_table, to_table, &table_list, 
    &table_size);
  if (!status) return (0);
  if (status == 2) return (2);

  end = strchr (dba_path, 0);
  table = table_list;
  for (;;) {
    status = dba_parse_string (&table, tabnam, ' ', 1);
    if (!status) break;
    *end = 0;
    strcat (dba_path, tabnam);
    strcat (dba_path, " ");
    
    status = dba_get_next_reljoins (reltemp, tabnam, to_table, 0, 0);
    if (status == 2) return (2);
  }
  table = table_list;
  for (;;) {
    status = dba_parse_string (&table, tabnam, ' ', 1);
    if (!status) break;
    *end = 0;
    strcat (dba_path, tabnam);
    strcat (dba_path, " ");
    if (strlen (dba_path) + 2 > dba_hit_size) {
      dba_hit_size = strlen (dba_path) + 1000;
      dba_hit_list = dba_drealloc (dba_hit_list, dba_hit_size);
    }
    strcpy (dba_hit_list, dba_path);
    strcat (dba_hit_list, " ");
    
    status = dba_get_reljoins (reltemp, tabnam, to_table);
    if (status == 2) return (2);
  }
  return (0);
}
/* Function:    dba_get_next_reljoins */
int dba_get_next_reljoins (reltemp, from_table, to_table, table_list, table_size)
struct dba_reltemp *reltemp;
char *from_table, *to_table, **table_list;
unsigned long *table_size;
{
  char *table;
  int hit=0;
  struct dba_reljoin *reljoin;
  
  for (reljoin=reltemp->f_reljoin; reljoin; reljoin=reljoin->n_reljoin) {
    if (strcmp (from_table, reljoin->f_table) == 0)
      table = reljoin->t_table;
    else if (strcmp (from_table, reljoin->t_table) == 0)
      table = reljoin->f_table;
    else table = 0;

    if (table) {
      if (strcmp (table, to_table) == 0) {
        if (strlen (dba_path) + strlen (to_table) + 2 > dba_path_size) {
          dba_path_size += 1000;
          dba_path = dba_drealloc (dba_path, dba_path_size);
        }
        strcat (dba_path, to_table);
        return (2);
      }
      if (!dba_search_string (dba_hit_list, table)) {
        if (table_list) {
          if (strlen (dba_hit_list) + strlen (table) + 2 > dba_hit_size) {
            dba_hit_size += 1000;
            dba_hit_list = dba_drealloc (dba_hit_list, dba_hit_size);
          }
          strcat (dba_hit_list, table);
          strcat (dba_hit_list, " ");

          if (strlen (*table_list) + strlen (table) + 2 > *table_size) {
            *table_size += 1000;
            *table_list = dba_drealloc (*table_list, *table_size);
          }
          strcat (*table_list, table);
          strcat (*table_list, " ");
        }
        hit = 1;
      }
    }
  }
  return (hit);
}
/* Function:    dba_create_reljoin_entnam */
int dba_create_reljoin_entnam (option, reltemp, from_table, to_table,
  fentnam, lentnam, ment, att_ptr)
int option;
struct dba_reltemp *reltemp;
char *from_table, *to_table;
struct dba_entnam **fentnam, **lentnam;
struct dba_ent *ment;
struct dba_att *att_ptr;
{
  int (*func)(), hit=0;
  struct dba_reljoin *reljoin;
  
  for (reljoin=reltemp->f_reljoin; reljoin; reljoin=reljoin->n_reljoin) {
    if (strcmp (from_table, reljoin->f_table) == 0
        && strcmp (to_table, reljoin->t_table) == 0) {
      hit = 1;
      switch (option) {
        case 1:
        dba_create_entnam (from_table, to_table, 1, 1, fentnam, lentnam,
          reljoin->f_column, reljoin->t_column);
        break;

        case 2:
        func = dba_inq_service (DBA_CREATE_MENU_OUTJOIN);
        if (func) (*func) (ment, ment->schema, from_table,
          att_ptr, ment->schema, to_table, 0,
          reljoin->f_column, reljoin->t_column);
        break;
      }
    }
    if (strcmp (from_table, reljoin->t_table) == 0
        && strcmp (to_table, reljoin->f_table) == 0) {
      hit = 1;
      switch (option) {
        case 1:
        dba_create_entnam (from_table, to_table, 1, 1, fentnam, lentnam,
          reljoin->t_column, reljoin->f_column);
        break;

        case 2:
        func = dba_inq_service (DBA_CREATE_MENU_OUTJOIN);
        if (func) (*func) (ment, ment->schema, from_table,
          att_ptr, ment->schema, to_table, 0,
          reljoin->t_column, reljoin->f_column);
        break;
      }
    }
  }
  return (hit);
}  
/* Function:    dba_create_entnam */
int dba_create_entnam (from_table, to_table, from_include, where_include,
  fentnam, lentnam, join_from, join_to)
char *from_table, *to_table, *join_from, *join_to;
int from_include, where_include;
struct dba_entnam **fentnam, **lentnam;
{
  struct dba_entnam *tentnam;

  for (tentnam=(*fentnam)->nentnam; tentnam; tentnam=tentnam->nentnam) {
    if (strcmp (tentnam->to_entnam, to_table) == 0
        && strcmp (tentnam->join_from, join_from) == 0
        && strcmp (tentnam->join_to, join_to) == 0) 
      break;
  }
  if (!tentnam) {
    dba_malloc_entnam (&tentnam);
    strcpy (tentnam->from_entnam, from_table);
    strcpy (tentnam->to_entnam, to_table);
    tentnam->from_include = from_include;
    tentnam->where_include = where_include;
    if (!(*fentnam)) *fentnam = tentnam;
    else (*lentnam)->nentnam = tentnam;
    *lentnam = tentnam;
    dba_strdup (join_from, &tentnam->join_from, &tentnam->from_lng);
    dba_strdup (join_to, &tentnam->join_to, &tentnam->to_lng);
  }
  return (0);
}
