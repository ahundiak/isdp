/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>
#include "dmalloc.def"
#include "cursor.def"

#if defined RIS4
#include "sql.h"
#elif defined RIS5
#include "ris.h"
#else
#include "sql.h"
#include "RISerror.h"
#endif

extern char *dba_errtxt;

/* Function:	dba_read_mscolumns

Description: 	reads the mscolumns table for the specified entity

Author: 	Brian Potter
*/
int dba_read_mscolumns (schema, entnum, mscolumns, attnums, 
  defvals, aliases, formats)
char *schema, **mscolumns, ***defvals, ***aliases, ***formats;
int entnum, **attnums;
{
  char sqltxt[200];
  int status, cnt, itmp;
  long ind;
  sqlda *desc;
  static numcols=0;
  static char *s1_ptr, **dv_ptr, **al_ptr, **fm_ptr;
  static int *i1_ptr;
  static unsigned long s1_size=0, i1_size=0;

  if (!s1_size)
    { s1_size = 500;  i1_size = 100;
    s1_ptr = dba_dmalloc (s1_size, DM_STATIC);
    i1_ptr = (int *) dba_dcalloc (4, i1_size, DM_STATIC);
    dv_ptr = (char **) dba_dcalloc (4, i1_size, DM_STATIC);
    al_ptr = (char **) dba_dcalloc (4, i1_size, DM_STATIC);
    fm_ptr = (char **) dba_dcalloc (4, i1_size, DM_STATIC); }
    
  for (cnt=1; cnt<=numcols; ++cnt)
    { i1_ptr[cnt] = 0;
    if (dv_ptr[cnt]) { dba_dfree (dv_ptr[cnt]);  dv_ptr[cnt] = 0; }
    if (al_ptr[cnt]) { dba_dfree (al_ptr[cnt]);  al_ptr[cnt] = 0; }
    if (fm_ptr[cnt]) { dba_dfree (fm_ptr[cnt]);  fm_ptr[cnt] = 0; } }
  numcols = 0;
  s1_ptr[0] = 0;
  sprintf (sqltxt,
    "select * from %s.mscolumns where entitynum = %d", schema, entnum);

  status = dba_select (DBA_C1, &desc, sqltxt);
  if (status != RIS_SUCCESS) goto done;

  for (cnt=0; cnt < desc->sqld; ++cnt)
    { desc->sqlvar[cnt].sqldata 
      = dba_dmalloc (desc->sqlvar[cnt].sqllen+1, DM_SQLVAR);
    desc->sqlvar[cnt].sqlind = &ind; }

  for (;;)
    { status = dba_fetch (DBA_C1, desc); 
    if (status != RIS_SUCCESS) break;
    ++numcols;
    itmp = strlen (s1_ptr);
    if (itmp + 100 > s1_size)
      { s1_size += 500;  s1_ptr = dba_drealloc (s1_ptr, s1_size); }
    if (numcols >= i1_size)
      { i1_size += 100;
      i1_ptr = (int *) dba_drealloc (i1_ptr, i1_size * 4);
      dv_ptr = (char **) dba_drealloc (dv_ptr, i1_size * 4);
      al_ptr = (char **) dba_drealloc (al_ptr, i1_size * 4);
      fm_ptr = (char **) dba_drealloc (fm_ptr, i1_size * 4);
      memset (&(i1_ptr)[i1_size-100], 0, 400);
      memset (&(dv_ptr)[i1_size-100], 0, 400);
      memset (&(al_ptr)[i1_size-100], 0, 400);
      memset (&(fm_ptr)[i1_size-100], 0, 400); }

    for (cnt=0; cnt < desc->sqld; ++cnt) 
      { desc->sqlvar[cnt].sqldata[desc->sqlvar[cnt].sqllen] = 0;
      if (strcmp (desc->sqlvar[cnt].sqlname.sqlnamec, "attrnum") == 0)
        i1_ptr[numcols] = * (int *) desc->sqlvar[cnt].sqldata;
      else if (strcmp (desc->sqlvar[cnt].sqlname.sqlnamec, "column_name") == 0)
        { strcat (s1_ptr, desc->sqlvar[cnt].sqldata);
        strcat (s1_ptr, " "); }
      else if (strcmp (desc->sqlvar[cnt].sqlname.sqlnamec, "alias_name") == 0)
        { if (strlen (desc->sqlvar[cnt].sqldata))
          al_ptr[numcols] = dba_dstrdup (desc->sqlvar[cnt].sqldata, DM_TMP); }
      else if (strcmp (desc->sqlvar[cnt].sqlname.sqlnamec, "column_format")==0)
        { if (strlen (desc->sqlvar[cnt].sqldata))
          fm_ptr[numcols] = dba_dstrdup (desc->sqlvar[cnt].sqldata, DM_TMP); }
      else if (strcmp (desc->sqlvar[cnt].sqlname.sqlnamec, "default_value")==0)
        { if (strlen (desc->sqlvar[cnt].sqldata))
          dv_ptr[numcols] = dba_dstrdup (desc->sqlvar[cnt].sqldata, DM_TMP); }
    }
  }

  for (cnt=0; cnt < desc->sqld; ++cnt) dba_dfree (desc->sqlvar[cnt].sqldata);

  status = dba_close_cursor (DBA_C1);
  if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }

done:
  *mscolumns = s1_ptr;
  *attnums = i1_ptr;
  *defvals = dv_ptr;
  *aliases = al_ptr;
  *formats = fm_ptr;

  return (numcols);
}
