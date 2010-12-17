/* $Revision: 1.1 $ */
#include "dba.ext"
#include "cursor.def"
#include "dmalloc.def"

#if defined RIS4
#include "sql.h"
#elif defined RIS5
#include "ris.h"
#else
#include "sql.h"
#include "RISerror.h"
#endif

extern char dba_text[], *dba_errtxt;

/* Function:	dba_init_codelist */
int dba_init_codelist (sch_ptr)
struct dba_sch *sch_ptr;
{
  char table_name[RISMAX], column_name[RISMAX], join_table[RISMAX], 
    code_column[RISMAX], text_column[RISMAX], index_column[RISMAX], 
    sqltxt[200];
  int status;
  long ind, index_value=0;
  struct dba_code_list *ccl, *tcl;
  struct dba_coded_column *ccc, *tcc;

/*
#if defined (__WIN16__)
return (0);
#endif
*/

  if (sch_ptr->code_built) return (0);
  sch_ptr->code_built = 1;

  for (ccc=tcc=sch_ptr->fcc; tcc; )
    { tcc = ccc->ncc;  dba_dfree (ccc);  ccc = tcc; }
  sch_ptr->fcc = 0;  sch_ptr->lcc = 0;

  for (ccl=tcl=sch_ptr->fcl; tcl; )
    { tcl = ccl->ncl;  dba_dfree (ccl);  ccl = tcl; }
  sch_ptr->fcl = 0;  sch_ptr->lcl = 0;

  for (ccl=sch_ptr->fcl; ccl; ccl=ccl->ncl)
    ccl->built = 0;

  sprintf (sqltxt,
    "select table_name, column_name, join_table, code_column, text_column, \
    index_column, index_value from %s.mscodelist", sch_ptr->name);

  status = dba_select (DBA_C1, NP, sqltxt);
  if (status != RIS_SUCCESS) return (0);

  for (;;)
    { status = dba_fetch (DBA_C1, NP, table_name, NP, column_name, NP, 
      join_table, NP, code_column, NP, text_column,NP, index_column, NP, 
      &index_value, &ind);
    if (status == END_OF_DATA) break;
    if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }
    if (ind < 0) index_value = 0;
    dba_add_coded_column (sch_ptr, table_name, column_name, join_table,
      code_column, text_column, index_column, index_value); }

  status = dba_close_cursor (DBA_C1);
  if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }

  return (0);
}
/* Function:	dba_add_coded_column */ 
int dba_add_coded_column (sch_ptr, table_name, column_name, join_table,
  code_column, text_column, index_column, index_value)
struct dba_sch *sch_ptr;
char *table_name, *column_name, *join_table, *code_column, *text_column,
  *index_column;
long index_value;
{
  struct dba_coded_column *ccc;

  ccc = (struct dba_coded_column *) 
    dba_dmalloc (sizeof (struct dba_coded_column), DM_CODED_COLUMN);
  memset (ccc, 0, sizeof (struct dba_coded_column));

  if (sch_ptr->fcc) sch_ptr->lcc->ncc = ccc;  else sch_ptr->fcc = ccc;
  sch_ptr->lcc = ccc;

  sprintf (ccc->column, "%s.%s", table_name, column_name);
  strcpy (ccc->join_table, join_table);
  strcpy (ccc->code_column, code_column);
  strcpy (ccc->text_column, text_column);
  if (index_column) strcpy (ccc->index_column, index_column);
  ccc->index_value = index_value;

  return (0);
}
/* Function:	dba_find_codelist */ 
int dba_find_codelist (schema, tabname, colname, cl_ptr)
int schema;
char *tabname, *colname;
struct dba_code_list **cl_ptr;
{
  char sqltxt[200];
  int status;
  long codnum=0;
  long ind;
  sqlda *desc;
  struct dba_sch *tsch;
  struct dba_coded_column *ccc;
  struct dba_code_list *ccl;
  static char *codtxt;
  static unsigned long txtlng=0;

  status = dba_set_sch_ptr (schema, NP, &tsch, 1);
  if (status) return (99);

  if (!tabname) strcpy (tabname, "");
  if (!colname) strcpy (colname, "");
  sprintf (dba_text, "%s.%s", tabname, colname);
  for (ccc=tsch->fcc; ccc; ccc=ccc->ncc)
    if (strcmp (dba_text, ccc->column) == 0) break;
  if (!ccc) return (99);

  if (!ccc->cl)
    { for (ccl=tsch->fcl; ccl; ccl=ccl->ncl)
      if (strcmp (ccc->join_table, ccl->table) == 0
        && ccc->index_value == ccl->index) 
          { ccc->cl = ccl;  break; } }
  else
    { ccl = ccc->cl; }

  if (!ccl) 
    { ccl = (struct dba_code_list *) 
      dba_dmalloc (sizeof (struct dba_code_list), DM_CODE_LIST);
    memset (ccl, 0, sizeof (struct dba_code_list));
    if (tsch->fcl) tsch->lcl->ncl = ccl;
    else tsch->fcl = ccl;
    tsch->lcl = ccl;
    ccl->ptrs = (char **) dba_dmalloc (400, DM_MEMBER);
    ccl->count = 100;
    ccc->cl = ccl;
    strcpy (ccl->table, ccc->join_table);  ccl->used = 1;
    strcpy (ccl->code_column, ccc->code_column);
    strcpy (ccl->text_column, ccc->text_column);
    strcpy (ccl->index_column, ccc->index_column);
    ccl->index = ccc->index_value; }

  if (!ccl->built)
    { sprintf (sqltxt, "select %s,%s from %s.%s where %s > 0",
      ccc->code_column, ccc->text_column, tsch->name, ccc->join_table,
      ccc->code_column);
    if (ccc->index_value > 0)
      { sprintf (dba_text, " and %s=%d", ccc->index_column, ccc->index_value);
      strcat (sqltxt, dba_text); }
    sprintf (dba_text, " order by %s", ccc->code_column);
    strcat (sqltxt, dba_text);

    status = dba_select (DBA_C1, &desc, sqltxt);
    if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }
    desc->sqlvar[0].sqldata = (char *) &codnum;
    desc->sqlvar[0].sqlind = &ind;

    if (desc->sqlvar[1].sqllen + 1 > txtlng)
      { if (!txtlng)
        { txtlng = desc->sqlvar[1].sqllen + 1;
        codtxt = dba_dmalloc (txtlng, DM_STATIC); }
      else
        { txtlng = desc->sqlvar[1].sqllen + 1;
        codtxt = dba_drealloc (codtxt, txtlng); } }
    desc->sqlvar[1].sqldata = codtxt;  desc->sqlvar[1].sqlind = &ind;
    ccl->length = desc->sqlvar[1].sqllen;

    memset (ccl->ptrs, 0, (int) ccl->count * 4);
    for (;;)
      { status = dba_fetch (DBA_C1, desc);
      if (status == END_OF_DATA) break;
      if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }
      if (codnum >= ccl->count)
        { ccl->ptrs = (char **) dba_drealloc (ccl->ptrs, ((codnum + 100) * 4));
        memset (&(ccl->ptrs)[ccl->count], 0, 
          (int) (codnum + 100 - ccl->count) * 4);
        ccl->count = codnum + 100; }
      if (!ccl->ptrs[codnum])
        ccl->ptrs[codnum] = dba_dmalloc (ccl->length + 1, DM_MEMBER);
      codtxt[ccl->length] = 0;
      strcpy (ccl->ptrs[codnum], codtxt); }
    ccl->codetot = codnum;

    status = dba_close_cursor (DBA_C1);
    if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }

    ccl->built = 1; }

  *cl_ptr = ccl;

  return (0);
}
/* Function:	dba_find_codeval */ 
int dba_find_codeval (code_number, schema, tabname, colname, code_text, alen)
long code_number;
int schema, *alen;
char *tabname, *colname, *code_text;
{
  int status;
  struct dba_code_list *ccl;

  status = dba_find_codelist (schema, tabname, colname, &ccl);
  if (status) return (99);

  *alen = ccl->length;
  if (code_number > ccl->codetot || !ccl->ptrs[code_number])
    { strcpy (code_text, dba_get_msg (DBA_E_INVALID_CODE, NP, *alen, NP, NP));
    return (99); }
  strcpy (code_text, ccl->ptrs[code_number]);

  return (0);
}
/* Function:	dba_find_codenum */ 
int dba_find_codenum (code_number, schema, tabname, colname, code_text)
long *code_number;
int schema;
char *tabname, *colname, *code_text;
{
  int status, count;
  struct dba_code_list *ccl;

  status = dba_find_codelist (schema, tabname, colname, &ccl);
  if (status) return (99);

  for (count=1,*code_number=0; count<=ccl->codetot; ++count)
    { if (!ccl->ptrs[count]) continue;
    if (strcmp (code_text, ccl->ptrs[count]) == 0) *code_number = count; }
  if (!(*code_number)) return (99);

  return (0);
}
