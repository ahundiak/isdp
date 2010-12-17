/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"
#include "cursor.def"

#if defined RIS4
#include "sql.h"
#elif defined RIS5
#include "ris.h"
#include "ris_err.h"
#else
#include "sql.h"
#include "RISerror.h"
#endif

extern char *dba_errtxt, *dba_table_order;
extern int dba_default_schema, dba_no_mscatalog;

/* Function:	dba_build_ent 

Description: 	builds an entity list for the specified RIS schema from
		MSCATALOG, if it exists, or the RIS dictionary

Author: 	Brian Potter
*/
int dba_build_ent (sch_ptr)
struct dba_sch *sch_ptr;
{
  char *tablename=0, *alias, sqltxt[200];
  int status, entnum=0, cnt, mscat=0, entitynum, first=1;
  long ind;
  sqlda *desc;
  struct dba_ent *cent, *tent;

  if (sch_ptr->built) return (0);
  if (!dba_default_schema) { 
    status = dba_attach_db (sch_ptr->name, 1);
    if (status) return (99); 
  }
  if (!sch_ptr->open) { 
    status = dba_open_schema (sch_ptr, 1);
    if (status) return (99); 
  }
  entitynum = 0;
  for (cent=tent=sch_ptr->fent; tent; ) { 
    tent = cent->nent;
    dba_free_ent (&cent);
    cent = tent; 
  }
  sch_ptr->fent = 0;

  if (!dba_no_mscatalog) { 
    status = dba_check_for_table (sch_ptr->schema, "mscatalog");
    if (!status) mscat = 1; 
  }
  if (mscat) { 
    sprintf (sqltxt, "select * from %s.mscatalog order by ", sch_ptr->name);
    if (dba_table_order && strlen (dba_table_order))
      strcat (sqltxt, dba_table_order);
    else
      strcat (sqltxt, "entitynum"); 
  }
  else { 
#if defined RIS5
    sprintf (sqltxt, "select table_name from %s.ris5tables order by ", 
#else
    sprintf (sqltxt, "select table_name from %s.ristables order by ", 
#endif
      sch_ptr->name);

  table_order:
    if (dba_table_order && strlen (dba_table_order))
      strcat (sqltxt, dba_table_order);
    else
      strcat (sqltxt, "table_name"); 
  }
  status = dba_select (DBA_C1, &desc, sqltxt);
  if (status != RIS_SUCCESS) {
#if defined RIS5
    if (first
        && (status == RIS_E_UNKNOWN_RELATION
        || status == RIS_E_CANT_ACCESS_V5_DICT_OBJECT)) {
      first = 0;
      sprintf (sqltxt, "select table_name from %s.ristables order by ", 
        sch_ptr->name);
      goto table_order;
    }
#endif
    dba_sqlerr ();
    return (99); 
  }
  for (cnt=0; cnt < desc->sqld; ++cnt) { 
    desc->sqlvar[cnt].sqldata 
      = dba_dmalloc (desc->sqlvar[cnt].sqllen + 1, DM_SQLVAR);
    desc->sqlvar[cnt].sqlind = &ind; 
  }
  for (sch_ptr->enumtot=0;;) { 
    status = dba_fetch (DBA_C1, desc); 
    if (status == END_OF_DATA) break;
    if (status != RIS_SUCCESS) { 
      dba_sqlerr ();
      return (99); 
    }
    alias = 0;

    for (cnt=0; cnt < desc->sqld; ++cnt) { 
      desc->sqlvar[cnt].sqldata[desc->sqlvar[cnt].sqllen] = 0;
      if (strcmp (desc->sqlvar[cnt].sqlname.sqlnamec, "tablename") == 0
        || strcmp (desc->sqlvar[cnt].sqlname.sqlnamec, "table_name") == 0)
        tablename = desc->sqlvar[cnt].sqldata;
      else if (strcmp (desc->sqlvar[cnt].sqlname.sqlnamec, "alias_name") == 0)
        alias = desc->sqlvar[cnt].sqldata;
      else if (strcmp (desc->sqlvar[cnt].sqlname.sqlnamec, "entitynum") == 0)
        entitynum = * (int *) desc->sqlvar[cnt].sqldata; 
    }
    if (mscat) entnum = entitynum;
    else ++entnum;

    dba_malloc_ent (&tent, NP);
    dba_add_ent_ptr (&sch_ptr->fent, &sch_ptr->lent, tent, NP);
    ++sch_ptr->enumtot;

    tent->schema = sch_ptr->schema;
    tent->entnum = entnum;
    while (tablename[strlen (tablename) - 1] == ' ')
      tablename[strlen (tablename) - 1] = 0;
    strcpy (tent->entnam, tablename);
    tent->active = 1; 
    if (alias && strlen (alias)) tent->alias = dba_dstrdup (alias, DM_MEMBER);
    else tent->alias = dba_dstrdup (tablename, DM_MEMBER); 
  }
  for (cnt=0; cnt < desc->sqld; ++cnt) dba_dfree (desc->sqlvar[cnt].sqldata);

  status = dba_close_cursor (DBA_C1);
  if (status != RIS_SUCCESS) { 
    dba_sqlerr ();
    return (99); 
  }
  sch_ptr->built = 1;

  return (0);
}
