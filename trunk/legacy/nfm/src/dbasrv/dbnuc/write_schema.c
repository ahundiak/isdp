/* $Revision: 1.1 $ */
#include "dba.ext"
#include <errno.h>

extern char *dba_errtxt;

/* Function:	dba_write_schema */
int dba_write_schema (schema, file)
char *schema, *file;
{
  int status, version=2, codetot=0;
  struct dba_sch *tsch;
  struct dba_ent *tent;
  struct dba_att *tatt;
  struct dba_coded_column *ccc;
  FILE *file_ptr;

  status = dba_set_sch_ptr (0, schema, &tsch, 1);
  if (status) return (status);

  file_ptr = fopen (file, "w");
  if (!file_ptr)
    { strcpy (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0, 
      "file", file, errno));
    return (99); }

  fwrite (&version, sizeof (int), 1, file_ptr);
  fwrite (&tsch->enumtot, sizeof (int), 1, file_ptr);
  for (ccc=tsch->fcc; ccc; ccc=ccc->ncc) ++codetot;
  fwrite (&codetot, sizeof (int), 1, file_ptr);

  for (tent=tsch->fent; tent; tent=tent->nent)
    { dba_build_att (tent, tsch->schema);

    fwrite (&tent->entnum, sizeof (int), 1, file_ptr);
    fwrite (tent->entnam, RISMAX, 1, file_ptr);
    fwrite (tent->alias, RISMAX, 1, file_ptr);
    fwrite (&tent->anumtot, sizeof (int), 1, file_ptr);

    for (tatt=tent->fatt; tatt; tatt=tatt->natt)
      { fwrite (&tatt->attnum, sizeof (int), 1, file_ptr);
      fwrite (tatt->attnam, RISMAX, 1, file_ptr);
      fwrite (tatt->alias, RISMAX, 1, file_ptr);
      fwrite (&tatt->atyp, sizeof (int), 1, file_ptr);
      fwrite (&tatt->abyt, sizeof (int), 1, file_ptr);
      fwrite (&tatt->alen, sizeof (int), 1, file_ptr);
      fwrite (tatt->defval, 10, 1, file_ptr);
      if (tatt->format)
        fwrite (tatt->format, 10, 1, file_ptr);
      else
        fwrite ("\0\0\0\0\0\0\0\0\0\0", 10, 1, file_ptr);
      fwrite (&tatt->key, sizeof (int), 1, file_ptr); } }

  for (ccc=tsch->fcc; ccc; ccc=ccc->ncc)
    { fwrite (ccc->column, 65, 1, file_ptr);
    fwrite (ccc->join_table, RISMAX, 1, file_ptr);
    fwrite (ccc->code_column, RISMAX, 1, file_ptr);
    fwrite (ccc->text_column, RISMAX, 1, file_ptr);
    fwrite (ccc->index_column, RISMAX, 1, file_ptr);
    fwrite (&ccc->index_value, sizeof (int), 1, file_ptr); }

  return (0);
}
