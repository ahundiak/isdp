/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

#if defined RIS4
#include "sql.h"
#include "ris_err.h"
#elif defined RIS5
#include "ris.h"
#include "ris_err.h"
#else
#include "sql.h"
#include "RISdic_err.h"
#endif

extern char *dba_datbas, *dba_errtxt, *dba_schema_list;
extern int dba_default_schema, dba_batch_mode, dba_dap_batch_mode;
extern struct dba_sch *dba_csch, *dba_fsch;
extern struct dba_ent *dba_cent;

/* Function:	dba_attach_db 

Description: 	invokes an RIS default schema command using the specified
		schema name

Author: 	Brian Potter */

int dba_attach_db (schema, msg)
char *schema;
int msg;
{
  char sqltxt[100];
  int status, pass, schnum;
  int (*func)();
  struct dba_sch *tsch=0;
  static char name[32], *current_schema, password[32];
  static int first=1;

  if (strlen (schema) == 0)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_INV_SCHNAM, NP, 0, NP, NP));
    status = 99;  goto attach_error; }

  pass = (sscanf (schema, "%[^.].%s", name, password) == 2) ? 1 : 0;

  status = sscanf (name, "%d", &schnum);
  if (status == 1) {
    for (tsch=dba_fsch; tsch; tsch=tsch->nsch)
      if (tsch->schema == schnum) break;
    if (!tsch) {
      strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_SCHEMA, "%ld", 0, 
        (long) schnum, NP));
      status = 99;
      goto attach_error;
    }
    strcpy (name, tsch->name);
  }
  if (msg) {
    func = dba_inq_service (DBA_PRINT_MSG);
    if (func)
      (*func) (dba_get_msg (DBA_M_ATTACH_DATBAS, "%s", 0, name, NP));
  }
  if (first) {
#if defined __WIN32__
    dba_set_blocking_hook (dba_blocking_hook);
    first = 0;
#endif
  }
  status = dba_attached (&current_schema);
  if (status && !strcmp (current_schema, name)) 
    { if (!dba_fsch) dba_add_schema (schema);
    goto skip_attach; }

  if (!dba_schema_list)
    { if (dba_fsch && strcmp (name, dba_fsch->name)) dba_clear_schema_list ();
    dba_add_schema (schema); }

  for (tsch=dba_fsch; tsch; tsch=tsch->nsch)
    if (strcmp (tsch->name, name) == 0) break;
  if (!tsch)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_SCHNAM, "%s", 0, name, NP));
    status = 99;  goto attach_error; }

  if (strlen (tsch->password))
    { strcpy (password, tsch->password);  pass = 1; }

attach:
  if (pass) sprintf (sqltxt, "default schema %s.%s", name, password);
  else sprintf (sqltxt, "default schema %s", name);
  status = dba_exec_sql (sqltxt);
#if defined RIS4 
  if (dba_get_sqlcode() == RIS_E_UNKNOWN_SCHEMA && !pass
#elif defined RIS5
  if (dba_get_sqlcode() == RIS_E_SCHPASS_NOT_SAME && !pass
#else
  if (dba_get_sqlcode() == RISdic_UNKNOWN_SCHEMA && !pass
#endif
    && !dba_batch_mode && !dba_dap_batch_mode)
    { func = dba_inq_service (DBA_GET_PASSWORD);
    if (func) status = (*func) (name, password);
    else status = 99;
    if (status == 99) goto attach_error;
    else if (!status) { 
      strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_PASSWORD, "%s", 0, name, NP));
      status = 99;
      goto attach_error; 
    }
    pass = 1;
    goto attach; 
  }
  else if (dba_get_sqlcode() != RIS_SUCCESS) {
#if defined RIS5
    if (dba_get_sqlcode() == RIS_E_NEED_DECLARE_SCHEMA) {
      status = dba_declare_schema (name);
      if (!status) goto attach; 
    }
#endif
    dba_sqlerr ();
    tsch->password[0] = 0;  
    status = 99;
    goto attach_error; 
  }
  if (pass) strcpy (tsch->password, password);
  tsch->open = 1;

skip_attach:
  strcpy (dba_datbas, name);  
  dba_default_schema = 1;
  status = dba_set_sch_ptr (0, dba_datbas, &dba_csch, 0);
  if (status) goto attach_error;
  dba_cent = 0;
  func = dba_inq_service (DBA_ATTACH_DBFORMS);
  if (func) (*func) ();
  if (msg) 
    { func = dba_inq_service (DBA_CLEAR_MSG);
    if (func) (*func) (); }

  return (status);

attach_error:
  if (!dba_schema_list)
    dba_clear_schema_list ();

  return (status);
}
