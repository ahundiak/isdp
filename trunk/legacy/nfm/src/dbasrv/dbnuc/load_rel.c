/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"
#include "keys.def"

extern char *dba_errtxt, *dba_stext, dba_rel_name[], dba_rel_desc[];
extern unsigned long dba_st_size;
extern struct dba_reltemp *dba_f_reltemp, *dba_l_reltemp, *dba_c_reltemp;

/* Function:	dba_load_relations */
int dba_load_relations (library, template)
char *library, *template;
{
  char ea_spec[151], to_spec[101];
  int status, type, retstat=0, x, y, outer;
  struct dba_library *templib;
  struct dba_reltemp *reltemp;
  struct dba_reltab *reltab;
  struct dba_reljoin *reljoin;
  struct dba_ent *tent;
  struct dba_att *fatt, *tatt;
  int (*serv)();

  status = dba_load_template (library, template, RELATIONS, &templib);
  if (status) return (status);

  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  status = sscanf (dba_stext, "Template_Type %d", &type);
  if (type != RELATIONS) { 
    strcpy (dba_errtxt, dba_get_msg (DBA_E_NOT_RELATIONS_TEMP, "%s", 79,
      template, NP));
    retstat = 99;
    goto end_load;
  }
  dba_delete_current_relations ();
  dba_free_reltemp (template);   
  dba_add_reltemp (template, &reltemp);

  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  status = sscanf (dba_stext, "Template_Name %s", dba_rel_name);
  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  ea_spec[0] = 0;
  status = sscanf (dba_stext, "Template_Description '%[^']'", ea_spec);
  dba_code_to_tic (ea_spec);
  strcpy (dba_rel_desc, ea_spec);

read_file:
  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  if (status != 1) goto end_load;

  if (strncmp (dba_stext, "Table", 5)==0) goto parse_table;
  if (strncmp (dba_stext, "Join", 4)==0) goto parse_reljoin;
  goto read_file;
  
parse_table:
  status = sscanf (dba_stext, "Table %s %d %d", ea_spec, &x, &y);
  status = dba_parse_ent (ea_spec, &tent);
  if (status) { 
    dba_add_error (dba_errtxt);
    goto read_file; 
  }
  dba_malloc_reltab (&reltab);
  reltab->schema = tent->schema;
  strcpy (reltab->table, tent->entnam);
  reltab->x = x;
  reltab->y = y;
  dba_add_reltab (reltemp, reltab);
  goto read_file;

parse_reljoin:
  status = sscanf (dba_stext, "Join %s %s %d", ea_spec, to_spec, &outer);

  status = dba_parse_att (ea_spec, &fatt);
  if (status) { 
    dba_add_error (dba_errtxt);
    goto read_file; 
  }
  status = dba_parse_att (to_spec, &tatt);
  if (status) { 
    dba_add_error (dba_errtxt);
    goto read_file; 
  }
  dba_malloc_reljoin (&reljoin);
  reljoin->f_schema = fatt->schema;
  strcpy (reljoin->f_table, fatt->entnam);
  strcpy (reljoin->f_column, fatt->attnam);

  reljoin->t_schema = tatt->schema;
  strcpy (reljoin->t_table, tatt->entnam);
  strcpy (reljoin->t_column, tatt->attnam);
  reljoin->outer = outer;
  dba_add_reljoin (reltemp, reljoin);
  goto read_file;

end_load:
  dba_lib_close (templib);

  if (reltemp) {
    dba_c_reltemp = reltemp;
    serv = dba_inq_service (DBA_PAINT_RELATIONS);
    if (serv) (*serv)();
  }
  return (retstat);
}
/* Function:	dba_malloc_reltemp */
void dba_malloc_reltemp (template, reltemp)
char *template;
struct dba_reltemp **reltemp;
{
  *reltemp =
    (struct dba_reltemp *) dba_dmalloc (sizeof (struct dba_reltemp), DM_TABLE);
  memset (*reltemp, 0, sizeof (struct dba_reltemp));
  strcpy ((*reltemp)->name, template);
}
/* Function:	dba_malloc_reltab */
void dba_malloc_reltab (reltab)
struct dba_reltab **reltab;
{
  *reltab =
    (struct dba_reltab *) dba_dmalloc (sizeof (struct dba_reltab), DM_TABLE);
  memset (*reltab, 0, sizeof (struct dba_reltab));
}
/* Function:	dba_malloc_reljoin */
void dba_malloc_reljoin (reljoin)
struct dba_reljoin **reljoin;
{
  *reljoin = 
    (struct dba_reljoin *) dba_dmalloc (sizeof (struct dba_reljoin), DM_TABLE);
  memset (*reljoin, 0, sizeof (struct dba_reljoin));
}
/* Function:	dba_add_reltab */
void dba_add_reltab (reltemp, reltab)
struct dba_reltemp *reltemp;
struct dba_reltab *reltab;
{
  if (reltemp->f_reltab)
    reltemp->l_reltab->n_reltab = reltab;
  else
    reltemp->f_reltab = reltab;
 
  reltemp->l_reltab = reltab;
}
/* Function:	dba_add_reljoin */
void dba_add_reljoin (reltemp, reljoin)
struct dba_reltemp *reltemp;
struct dba_reljoin *reljoin;
{
  if (reltemp->f_reljoin)
    reltemp->l_reljoin->n_reljoin = reljoin;
  else
    reltemp->f_reljoin = reljoin;
 
  reltemp->l_reljoin = reljoin;
}
/* Function:	dba_add_reltemp */
void dba_add_reltemp (template, reltemp)
char *template;
struct dba_reltemp **reltemp;
{
  struct dba_reltemp *t_reltemp;

  for (t_reltemp=dba_f_reltemp; t_reltemp; t_reltemp=t_reltemp->n_reltemp) {
    if (strcmp (t_reltemp->name, template) == 0) {
      *reltemp = t_reltemp;
      return;
    }
  }
  dba_malloc_reltemp (template, reltemp);
  if (dba_f_reltemp)
    dba_l_reltemp->n_reltemp = *reltemp;
  else
    dba_f_reltemp = *reltemp;

  dba_l_reltemp = *reltemp;
}
/* Function:	dba_free_reltemp */
void dba_free_reltemp (template)
char *template;
{
  struct dba_reltemp *reltemp, *c_reltemp, *p_reltemp;
  struct dba_reltab *c_reltab, *t_reltab;
  struct dba_reljoin *c_reljoin, *t_reljoin;

  for (reltemp=dba_f_reltemp; reltemp; reltemp=reltemp->n_reltemp)
    if (strcmp (reltemp->name, template) == 0) break;
  if (!reltemp) return;

  for (c_reltab=t_reltab=reltemp->f_reltab; t_reltab; ) { 
    t_reltab = c_reltab->n_reltab;
    dba_dfree (c_reltab);
    c_reltab = t_reltab; 
  }
  for (c_reljoin=t_reljoin=reltemp->f_reljoin; t_reljoin; ) { 
    t_reljoin = c_reljoin->n_reljoin;
    dba_dfree (c_reljoin);
    c_reljoin = t_reljoin; 
  }
  if (reltemp == dba_f_reltemp) {
    dba_f_reltemp = reltemp->n_reltemp;
    dba_dfree (reltemp);
    return;
  }
  for (c_reltemp=dba_f_reltemp; ; ) {
    if (c_reltemp == reltemp) {
      p_reltemp->n_reltemp = c_reltemp->n_reltemp;
      if (c_reltemp == dba_l_reltemp)
        dba_l_reltemp = p_reltemp;
      dba_dfree (reltemp);
      return;
    }
    p_reltemp = c_reltemp;
    c_reltemp = c_reltemp->n_reltemp;
  }
}
/* Function:    dba_delete_current_relations */
int dba_delete_current_relations ()
{
  struct dba_reltab *c_reltab;
  struct dba_reljoin *c_reljoin;
  int (*serv)();

  if (!dba_c_reltemp) return (0);

  serv = dba_inq_service (DBA_DELETE_RELATION);
  if (serv) {
    for (c_reltab=dba_c_reltemp->f_reltab; c_reltab; ) { 
      (*serv)(c_reltab->group);
      c_reltab = c_reltab->n_reltab;
    }
    for (c_reljoin=dba_c_reltemp->f_reljoin; c_reljoin; ) { 
      (*serv)(c_reljoin->line);
      c_reljoin = c_reljoin->n_reljoin;
    }
  }
  return (0);
}

