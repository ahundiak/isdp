/* $Revision: 1.1 $ */
#include "dba.ext"
#include "script.def"

/*
    Function:	dba_s_add_query
    Author:	Tim A. Thompson
    Date:	2-JUL-90

    Revisions:
	7-21-92  -- Converted to new Scripting.

------------------------------------------------------------------------------

DBA_ADD_QUERY

	Adds a new criterion to the current query criteria.  (Same as the
	Add Query Gadget.

Availability:	Menus Only

Function:	DBA_ADD_QUERY (logical, schema, table, column, relop, attval)

Arguments:	Name		Type	Description


		logical		char *	"AND" or "OR".  Valid only if a query
					criterion already exists, otherwise
					it will be ignored.

		schema		char *	RIS schema name.  (Optional, 0 for
					current schema.)

		table		char *	Table name or number.  (Optional, 0
					for current table.

		column		char *	Column name or number.

		relop		char *	Relational operator
					  =  (equal to)
					  != (not equal to)
					  <  (less than)
					  >  (greater than)
					  <= (less than or equal to)
					  >= (greater than or equal to)
					  !! (substring search)

		attval		char *	Search value

Return Value:	(int)	0	- Success
			not 0	- Failure
		If there is an error, the text describing the error
		is stored in the global variable dba_errtxt.

Example:

	istat = dba_add_query ("AND", 0, 0, "mfr_name", "=", "GoodTire");

------------------------------------------------------------------------------
*/

long dba_s_add_query (bfunc, function, opnum)
functiontype *bfunc, *function;
long opnum;
{
  long status, istat;
  char *logical, *schema, *entnam, *attnam, *relop, *attval,
      entnam_buf[10], schema_buf[10], attnam_buf[10];

  istat = dba_check_num_arguments (bfunc, function, opnum, 6);
  if (istat)
    return (istat);

  istat = dba_get_ptr_from_operand (function, opnum, 0, (void **)&attval, 1, 1,
      SCR_CHAR, 1, 0, dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  istat = dba_get_ptr_from_operand (function, opnum, 1, (void **) &relop, 1, 1,
      SCR_CHAR, 1, 0, dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  istat = dba_get_str_val_from_operand (function, opnum, 2, &attnam,
      attnam_buf, dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  istat = dba_get_str_val_from_operand (function, opnum, 3, &entnam,
      entnam_buf, dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  istat = dba_get_str_val_from_operand (function, opnum, 4, &schema,
      schema_buf, dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  istat = dba_get_ptr_from_operand (function, opnum, 5, (void **)&logical, 1, 1,
      SCR_CHAR, 1, 0, dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  status = dba_add_query (logical, schema, entnam, attnam, relop, attval);

  dba_verbose_result_check (dba_get_function_name (bfunc), status,
      VERB_DBA_FUNCTIONS, 0);
  return dba_store_int_result (function, opnum, status,
      dba_get_function_name (bfunc));
}
