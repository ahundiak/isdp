#include "ris.h"
static short RIScpp_stmt_id0 = -1;

#line 1 "r_sql.rc"
/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

extern char *dba_schema_list, *dba_errtxt;
extern struct dba_sch *dba_csch;

/* Function:	dba_ris_sql */
int dba_ris_sql (sqlptr)

#line 10 "r_sql.rc"

char * sqlptr;

#line 12 "r_sql.rc"

{
  char *text_ptr, command[100], schema[100], *char_ptr;
  int status, count, lng;
  int (*func)();


#line 18 "r_sql.rc"

sqlda u1;

#line 20 "r_sql.rc"


  count = strlen (sqlptr);
  for (lng=0; lng<count; )
    { while (*sqlptr == ' ') { ++lng;  ++sqlptr; }
    text_ptr = dba_strchr (sqlptr, ';');  if (text_ptr) *text_ptr = 0;

    sscanf (sqlptr, "%s", command);
    dba_lower (command);

    if (strcmp (command, "debug") == 0)
      { char_ptr = &sqlptr[5];
      while (*char_ptr == ' ') ++char_ptr;
      status = dba_sql_debug (char_ptr);
      if (status) goto next_sql; }

{RISint_prepare(&RIScpp_stmt_id0,sqlptr,1,0);
}

#line 36 "r_sql.rc"

    if (dba_get_sqlcode() != RIS_SUCCESS) return (dba_get_sqlcode() );
    u1.sqld = 0;  u1.sqln = 0;  u1.sqlvar = 0;
{RISint_describe(RIScpp_stmt_id0,&u1,1);
}

#line 39 "r_sql.rc"

    if (dba_get_sqlcode() != RIS_SUCCESS) 
    if (dba_get_sqlcode() != RIS_SUCCESS) return (dba_get_sqlcode() );

    if (u1.sqld)
      { func = dba_inq_service (DBA_SELECT_FORM);
      if (func)
        { status = (*func) (sqlptr);
        if (status) return (status); } }
    else
      { if (strcmp (command, "default") == 0)
        { dba_lower (sqlptr);
        status = sscanf (sqlptr, "default schema %s", schema);
        if (status == 1)
          { status = dba_attach_db (schema, 1);
          if (status) return (status); }
        goto next_sql; }
      else if (strcmp (command, "create") == 0 
        || strcmp (command, "alter") == 0
        || strcmp (command, "drop") == 0)
        if (dba_csch) {
          dba_csch->built = 0;
          dba_csch->code_built = 0;
        }
{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
}

#line 63 "r_sql.rc"

      if (dba_get_sqlcode() != RIS_SUCCESS) return (dba_get_sqlcode() ); }
  next_sql:
    lng += strlen (sqlptr) + 1;
    if (text_ptr) sqlptr = text_ptr + 1;
    else break; }

  return (0);
}
