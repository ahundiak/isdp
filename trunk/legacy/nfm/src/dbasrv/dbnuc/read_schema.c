/* $Revision: 1.1 $ */
#include "dba.ext"
#include <errno.h>
#include "dmalloc.def"

extern char *dba_errtxt;
extern struct dba_sch *dba_fsch;

/* Function:	dba_read_schema */
int dba_read_schema (schema, file)
char *schema, *file;
{
  char name[RISMAX], password[RISMAX], text[RISMAX];
  int version, codetot, count, acount, anumtot;
  struct dba_sch *tsch;
  struct dba_ent *tent, *cent;
  struct dba_att *tatt;
  struct dba_coded_column *ccc;
  FILE *file_ptr;

  file_ptr = fopen (file, "r");
  if (!file_ptr)
    { strcpy (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0, 
      "file", file, errno));
    return (99); }

  fread (&version, sizeof (int), 1, file_ptr);
  if (version != 2)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_FILE_OUTDATED, "%s", 0, file, NP));
    return (99); }

  sscanf (schema, "%[^.].%s", name, password);

  if (!dba_fsch) dba_add_schema (schema);

  for (tsch=dba_fsch; tsch; tsch=tsch->nsch)
    if (strcmp (tsch->name, name) == 0) break;
  if (!tsch)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_SCHNAM, "%s", 0, name, NP));
    return (99); }

  tsch->built = 1;
  tsch->code_built = 1;
  for (cent=tent=tsch->fent; tent; )
    { tent = cent->nent;  dba_free_ent (&cent);  cent = tent; }
  tsch->fent = 0;

  fread (&tsch->enumtot, sizeof (int), 1, file_ptr);
  fread (&codetot, sizeof (int), 1, file_ptr);

  for (count=0; count<tsch->enumtot; ++count)
    { dba_malloc_ent (&tent, NP);
    dba_add_ent_ptr (&tsch->fent, &tsch->lent, tent, NP);
    tent->schema = tsch->schema;
    fread (&tent->entnum, sizeof (int), 1, file_ptr);
    fread (tent->entnam, RISMAX, 1, file_ptr);
    fread (text, RISMAX, 1, file_ptr);
    tent->alias = dba_dstrdup (text, DM_MEMBER);
    fread (&anumtot, sizeof (int), 1, file_ptr);

    for (acount=0; acount<anumtot; ++acount)
      { dba_malloc_att (&tatt, NP);
      dba_add_att_ptr (tent, tatt, NP);
      fread (&tatt->attnum, sizeof (int), 1, file_ptr);
      fread (tatt->attnam, RISMAX, 1, file_ptr);
      fread (text, RISMAX, 1, file_ptr);
      tatt->alias = dba_dstrdup (text, DM_MEMBER);
      fread (&tatt->atyp, sizeof (int), 1, file_ptr);
      fread (&tatt->abyt, sizeof (int), 1, file_ptr);
      fread (&tatt->alen, sizeof (int), 1, file_ptr);
      fread (text, 10, 1, file_ptr);
      tatt->defval = dba_dstrdup (text, DM_MEMBER);
      fread (text, 10, 1, file_ptr);
      if (strlen (text)) tatt->format = dba_dstrdup (text, DM_MEMBER);
      fread (&tatt->key, sizeof (int), 1, file_ptr); 
      if (tatt->key)
        { ++tent->num_keys;
        tent->key_rec += tatt->abyt + 2; }

      tatt->schema = tent->schema;
      strcpy (tatt->entnam, tent->entnam);
      tatt->entnum = tent->entnum;
      tatt->size = tatt->alen + 1;
      tatt->attval = dba_dmalloc (tatt->size, DM_MEMBER);
      tatt->label = COLUMN;
      tatt->row = acount;
      tatt->column = 1;
      tatt->subtyp = 0;
      tatt->write = 1;
      tatt->decimal = 6;
      tatt->active = 1;
      tatt->exclude = 1; }

    tent->catt = tent->fatt;
    tent->built = 1;
/* 5/15/94 blp
    tent->dis_built = 0; 
*/
  }
  for (count=0; count<codetot; ++count)
    { ccc = (struct dba_coded_column *) 
      dba_dmalloc (sizeof (struct dba_coded_column), DM_CODED_COLUMN);
    memset (ccc, 0, sizeof (struct dba_coded_column));
    if (tsch->fcc) tsch->lcc->ncc = ccc;
    else tsch->fcc = ccc;
    tsch->lcc = ccc;
    fread (ccc->column, 65, 1, file_ptr);
    fread (ccc->join_table, RISMAX, 1, file_ptr);
    fread (ccc->code_column, RISMAX, 1, file_ptr);
    fread (ccc->text_column, RISMAX, 1, file_ptr);
    fread (ccc->index_column, RISMAX, 1, file_ptr);
    fread (&ccc->index_value, sizeof (int), 1, file_ptr); }

  return (0);
}
