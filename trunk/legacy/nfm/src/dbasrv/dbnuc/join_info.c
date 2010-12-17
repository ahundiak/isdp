/* $Revision: 1.1 $ */
#include "dba.ext"

extern char dba_report_relations[];
extern int dba_first_menu, dba_mb, dba_rb;
extern struct dba_ent *dba_ment[];
extern struct dba_line *dba_fline, *dba_fsline;

/* Function:	dba_new_join_info */
int dba_new_join_info (join_from, from_schema, from_entnam,
  join_to, to_schema, to_entnam, from_ptr, from_lng, to_ptr, to_lng, outer_ptr)
char *join_from, *from_entnam, *join_to, *to_entnam, **from_ptr, **to_ptr;
int from_schema, to_schema, *outer_ptr;
unsigned long *from_lng, *to_lng;
{
  struct dba_gadget *gadg;
  struct dba_line *tline;
  struct dba_field *tfield;

  if (join_from && strlen (join_from) && join_to && strlen (join_to)) 
    return (0);

  if (from_schema != to_schema) *outer_ptr = 1;

  if (dba_mb) {
    if (dba_check_relations (dba_ment[dba_first_menu]->relations, from_schema,
      from_entnam, to_schema, to_entnam)) return (1);
      
    for (gadg=dba_ment[dba_first_menu]->fgadget; gadg; gadg=gadg->ngadget) {
      if (gadg->schema == to_schema && strcmp (gadg->entnam, to_entnam) == 0
          && gadg->join_from && gadg->join_to 
          && (strlen (gadg->join_from) || strlen (gadg->join_to))) {
        dba_strdup (gadg->join_from, from_ptr, from_lng);
        dba_strdup (gadg->join_to, to_ptr, to_lng);
        *outer_ptr = gadg->outer;
        return (0);
      }
    }
  }
  else if (dba_rb) {
    if (dba_check_relations (dba_report_relations, from_schema, from_entnam,
      to_schema, to_entnam)) return (1);

    for (tline=dba_fsline; tline; tline=tline->nline) {
      if (tline->schema == from_schema 
          && strcmp (tline->entnam, from_entnam) == 0) {
        for (tfield=tline->ffield; tfield; tfield=tfield->nfield) {
          if (tfield->schema == to_schema
              && strcmp (tfield->entnam, to_entnam) == 0
              && tfield->join_from && tfield->join_to 
              && (strlen (tfield->join_from)
              || strlen (tfield->join_to))) {
            dba_strdup (tfield->join_from, from_ptr, from_lng);
            dba_strdup (tfield->join_to, to_ptr, to_lng);
            *outer_ptr = tfield->outer;
            return (0);
          }
        }
      }
    }
    for (tline=dba_fline; tline; tline=tline->nline) {
      if (tline->schema == from_schema 
          && strcmp (tline->entnam, from_entnam) == 0) {
        for (tfield=tline->ffield; tfield; tfield=tfield->nfield) {
          if (tfield->schema == to_schema
              && strcmp (tfield->entnam, to_entnam) == 0
              && tfield->join_from && tfield->join_to 
              && (strlen (tfield->join_from)
              || strlen (tfield->join_to))) {
            dba_strdup (tfield->join_from, from_ptr, from_lng);
            dba_strdup (tfield->join_to, to_ptr, to_lng);
            *outer_ptr = tfield->outer;
            return (0);
          }
        }
      }
    }
  }
  return (0);
}
