/* $Revision: 1.1 $ */
#include "dba.ext"
#include "script.def"

/*
    Function:	dba_s_get_query
    Author:	Tim A. Thompson
    Date:	18-SEP-91

    Revisions:
	8-9-92   -- Converted to new Scripting.

------------------------------------------------------------------------------

DBA_GET_QUERY

	This function returns the current where clause for the
	specified table.  If no where clause exists (via added queries),
	where_clause will be a null string.

Function:       DBA_GET_QUERY (schema, table, where_clause);

Arguments:      Name            Type    Description

                schema          char *  Schema name (0 for current)

                table           char *  Table name (0 for current)

                where_clause	char **	Where clause

Return Value:   (int)   0       - Success
                        not 0   - Failure -- Error message in dba_errtxt.

Examples:
		char *where;
		status = dba_get_query ("schema1", "table1", &where);

		char *where;
		status = dba_get_query (0, 0, &where);

------------------------------------------------------------------------------
*/

long dba_s_get_query (bfunc, function, opnum)
functiontype *bfunc, *function;
long opnum;
{
  long istat, status;
  char *schema, *table, schema_buf[10], table_buf[10], *where_clause;
  void *ptr, *valptr;
  operandtype *ptrop;

  istat = dba_check_num_arguments (bfunc, function, opnum, 3);
  if (istat)
    return (istat);

  istat = dba_get_str_val_from_operand (function, opnum, 2, &schema,
      schema_buf, dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  istat = dba_get_str_val_from_operand (function, opnum, 1, &table,
      table_buf, dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  dba_get_operand (function, opnum, 0, &ptrop, &valptr);
  istat = dba_get_ptr_from_ptrop (ptrop, valptr, &ptr, 2, 1, SCR_CHAR, 1, 0,
      dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  status = dba_get_query (schema, table, &where_clause);

  if (ptrop->is_real_c) {
    ((lvoid *)ptr)->msw = 0;
    ((lvoid *)ptr)->lsw = (unsigned long) where_clause;
  }
  else
    *(void **)ptr = where_clause;

  dba_verbose_result_check (dba_get_function_name (bfunc), status,
      VERB_DBA_FUNCTIONS, 0);
  return dba_store_int_result (function, opnum, status,
      dba_get_function_name (bfunc));
}
