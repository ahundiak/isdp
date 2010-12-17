/* $Revision: 1.1 $ */
#include "dba.ext"
#include "script.def"
#include "dmalloc.def"

#if defined RIS5
#include "ris.h"
#else
#include "sql.h"
#endif

extern char *dba_timestamp_format;

extern sqlda dba_d[];
extern int dba_cur_in_use[];

/*
    Function:	dba_s_select
    Author:	Tim A. Thompson
    Date:	6-AUG-90

    Revisions:
	4-22-92 --  Modified to call dba_close_cursor from the dev platform.
	7-30-92 --  Converted to new Scripting.
	1-12-93 --  Pass 'curs' as an int.
	7-28-93 --  Added support for unions.

------------------------------------------------------------------------------

DBA_SELECT

	Performs a RIS select, using the given cursor, to retrieve rows
	of data from the database.

Availability:	Menus/Reports

Function:	DBA_SELECT (cursor, res, select)

Arguments:	Name		Type	Description


		cursor		int	Number of the cursor to use.
					(Currently must be 0 through 4.)

		reserved	*	Reserved for future use.
					(Send a 0 (null) for this argument
					 for future compatibility.)

		select		char *	String containing select statement
					(including any where clause).

Return Value:	(int)	RIS return code (SQLCODE).  0 = Success.

Examples:

	int status, ind;
	char buffer[30];

	status = dba_select (0, 0, "select mfr_name from manufacturer");
	if (status)
	  dba_report_ris_error ();

	status = dba_fetch (0, 0, buffer, &ind);
	while (status != 100) {
	  status = dba_fetch (0, 0, buffer, &ind);
	  printf ("Manufacturer Name : %s\n", buffer);
	}
	status = dba_close_cursor (0);

NOTE:	The status of the select should ALWAYS be checked even if the
	correctness of the select statement is guaranteed.

	Also, RIS will issue a commit when any sql statement is executed
	if transaction autocommit is turned on (on by default).  This commit
	will close any open cursors.  To prevent this, issue the following
	sql statement BEFORE the select: "set transaction autocommit off".
	After the cursor is closed, issue this statement:
	"set transaction autocommit on".

	Be sure that transaction autocommit is ALWAYS on when the script
	routine exits.  Many DBAccess routines expect autocommit to be on.

------------------------------------------------------------------------------
*/

long dba_s_select (bfunc, function, opnum)
functiontype *bfunc, *function;
long opnum;
{
  char *sqltxt;
  sqlda *desc;

  long istat, curs, status;

  istat = dba_check_num_arguments (bfunc, function, opnum, 3);
  if (istat)
    return (istat);

  istat = dba_get_ptr_from_operand (function, opnum, 0, (void **) &sqltxt,
      1, 1, SCR_CHAR, 1, 0, dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  istat = dba_get_int_from_operand (function, opnum, 2, &curs,
      dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  if (curs < 0 || curs > 4) {
    dba_standard_function_error (dba_get_function_name (bfunc));
    dba_add_error (dba_get_msg(DBA_E_SCR_INV_CURSOR, "%ld", 0, curs, NP));
    dba_add_error (dba_get_msg(DBA_E_SCR_EXAMPLE_CURSOR, NP, 0, NP, NP));
    return (99);
  }
  status = dba_select ((int)curs, &desc, sqltxt);

  dba_verbose_result_check (dba_get_function_name (bfunc), status,
      VERB_RIS_FUNCTIONS, 0);
  return dba_store_int_result (function, opnum, status,
      dba_get_function_name (bfunc));
}


/*
    Function:	dba_s_fetch
    Author:	Tim A. Thompson
    Date:	8-AUG-90

    Revisions:
	4-26-92 --  Modified to call dba_close_cursor from the dev platform.
	7-30-92 --  Converted to new Scripting.
	1-12-93 --  Pass 'curs' as an int.

------------------------------------------------------------------------------

DBA_FETCH

	Performs a RIS fetch, using the given cursor, to retrieve rows
	of data from the database.

	(NOTE FOR DEVELOPMENT PLATFORM USERS:  Pass a pointer to a "long"
	or "int" for the "col" arguments when a column of type "smallint" is
	being fetched.  Pass a pointer to a "double" when a column of type
	"real" is being fetched.  These restrictions do not apply to scripting
	users.)


Availability:	Menus/Reports

Function:	DBA_FETCH (cursor, res [, col1, ind1 [, ...]])

Arguments:	Name		Type	Description


		cursor		int	Number of the cursor to use.
					(Currently must be 0 through 4.)

		reserved	*	Reserved for future use.
					(Send a 0 (null) for this argument
					 for future compatibility.)

		col		any *	Pointer to location where data from
					a database column is to be stored.

		ind		long *	Indicates whether the column is null.
					Negative 'ind' value indicates a null
					column.

NOTE:	There can be any number of "col-ind" pairs.  Each set will be matched
	with the corresponding column returned from the database.

	RIS automatically closes all cursors if a "commit" or "rollback"
	statement is issued or an error occurs during the execution of any
	SQL statement.

Return Value:	(int)	RIS return code (SQLCODE).  0 = Success.

Examples:

	int status, ind;
	char buffer[30];

	status = dba_select (0, 0, "select mfr_name from manufacturer");
	if (status)
	  dba_report_ris_error ();

	status = dba_fetch (0, 0, buffer, &ind);
	if (status && status != 100)
	  dba_report_ris_error ();
	else
	  while (status != 100) {
	    status = dba_fetch (0, 0, buffer, &ind);
	    printf ("Manufacturer Name : %s\n", buffer);
	  }
	status = dba_close_cursor (0);

NOTE:	The status of the select and the fetch should ALWAYS be checked.

------------------------------------------------------------------------------
*/

long dba_s_fetch (bfunc, function, opnum)
functiontype *bfunc, *function;
long opnum;
{
  sqlda *desc;
  long istat, num, i, k, coltype, curs, name_length, tmp_type,
      status, is_zero;
  void *valptr;
  operandtype *ptrop;
  union dba_mixed retval;
  char *err, *cptr, *strptr;

  num = dba_get_num_operation_operands (function, opnum);
  if (num < 2) {
    dba_standard_function_error (dba_get_function_name (bfunc));
    dba_add_error (dba_get_msg (DBA_E_SCR_TOO_FEW_ARGS, "%ld", 0, 2L, NP));
    return (99);
  }

  istat = dba_get_int_from_operand (function, opnum, num-1, &curs,
      dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  if (!dba_cur_in_use[curs]) {
    dba_standard_function_error (dba_get_function_name (bfunc));
    dba_add_error (dba_get_msg (DBA_E_SCR_CURSOR_NOT_OPEN, "%ld", 0, curs,NP));
    return (99);
  }

  if ((float)(num - 2) / 2.0 != (long)((float)(num - 2) / 2.0) ||
          num - 2 != dba_d[curs].sqld * 2) {
    dba_standard_function_error (dba_get_function_name (bfunc));
    dba_add_error (dba_get_msg (DBA_E_SCR_NUM_FETCH_ARGS, NP, 0,NP, NP));
    dba_add_error (dba_get_msg (DBA_E_SCR_FETCH_ARGS_EXPECTED, "%ld",
        0, (long) dba_d[curs].sqld, NP));
    return (99);
  }

  for (i=0, k=0; i<num-2; i++, k++) {
    dba_get_operand (function, opnum, num-3-i, &ptrop, &valptr);
    if (ptrop->indir == 1) {
      dba_upgrade_sqltype (&dba_d[curs].sqlvar[k]);
      coltype = dba_d[curs].sqlvar[k].sqltype;
      tmp_type = ptrop->type;
      if (tmp_type == SCR_CHAR && coltype != 1 && coltype != 9 ||
          ((tmp_type == SCR_SHORT || tmp_type == SCR_INT ||
          tmp_type == SCR_LONG || tmp_type == SCR_FLOAT ||
          tmp_type == SCR_DOUBLE) && coltype != 4 && coltype != 8) ||
          tmp_type == SCR_STRUCT || tmp_type == SCR_UNION) {
        dba_standard_function_error (dba_get_function_name (bfunc));
        name_length = dba_d[curs].sqlvar[k].sqlname.sqlnamel;
        err = (char *) dba_dmalloc (name_length + 1, DM_TMP);
        strncpy (err, dba_d[curs].sqlvar[k].sqlname.sqlnamec, name_length);
        err[name_length] = '\0';
        dba_add_error (dba_get_msg (DBA_E_SCR_FETCH_TYPE, "%s", 0, err, NP));
        dba_dfree (err);
        return (99);
      }
      if (coltype == 9) {
        dba_d[curs].sqlvar[k].sqldata =
            (char *) dba_dmalloc (dba_d[curs].sqlvar[k].sqllen,
            DM_TIMESTAMP_TMP);
      }
      else
      {
        if (tmp_type == SCR_CHAR) {
          istat = dba_get_ptr_from_ptrop (ptrop, valptr, (void **) &cptr,
              1, 1, 0, 0, 0, dba_get_function_name (bfunc));
          if (istat)
            return (istat);
          istat = dba_mem_grow (function, opnum, num-3-i,
              dba_d[curs].sqlvar[k].sqllen + 1, (void **) &cptr);
          if (istat)
            return (istat);
          dba_d[curs].sqlvar[k].sqldata = cptr;
          dba_d[curs].sqlvar[k].sqldata[dba_d[curs].sqlvar[k].sqllen] = '\0';
        }
        else
          dba_d[curs].sqlvar[k].sqldata =
              (char *) dba_dmalloc (dba_d[curs].sqlvar[k].sqllen, DM_TMP);
      }
      i++;
    }
    else
    {
      dba_standard_function_error (dba_get_function_name (bfunc));
      dba_add_error (dba_get_msg (DBA_E_SCR_ARG_WRONG_TYPE, "%s", 0,
          dba_get_operand_name (bfunc, ptrop), NP));
      dba_add_error (dba_get_msg (DBA_E_SCR_POINTER_EXPECTED, NP, 0, NP, NP));
      return (99);
    }
    dba_get_operand (function, opnum, num-3-i, &ptrop, &valptr);
    tmp_type = ptrop->type;
    is_zero = dba_has_zero_value (function, opnum, num-3-i, tmp_type,
        ptrop->indir, ptrop->is_real_c);
    if (tmp_type != SCR_SHORT && tmp_type != SCR_INT && tmp_type != SCR_LONG
        && tmp_type != SCR_FLOAT && tmp_type != SCR_DOUBLE
        || ptrop->indir != 1 && !is_zero || ptrop->indir > 1) {
      dba_standard_function_error (dba_get_function_name (bfunc));
      dba_add_error (dba_get_msg (DBA_E_SCR_LONG_INDICATOR, NP, 0, NP, NP));
      return (99);
    }
    else
    {
      if (ptrop->mode == SCR_CONST && !is_zero) {
        dba_standard_function_error (dba_get_function_name (bfunc));
        dba_add_error (dba_get_msg (DBA_E_SCR_DEST_CONST, NP,0,NP,NP));
        return (99);
      }
      else
      {
        dba_d[curs].sqlvar[k].sqlind = (long *) dba_dmalloc (sizeof (long),
            DM_TMP);
      }
    }
  }
  desc = &dba_d[curs];
  status = dba_fetch ((int) curs, desc);

  if (!status) {
    for (i=0, k=0; i<num-2; i+=2, k++) {
      dba_get_operand (function, opnum, num-3-i, &ptrop, &valptr);
      istat = dba_get_ptr_from_ptrop (ptrop, valptr, (void **) &cptr,
          1, 1, 0, 0, 0, dba_get_function_name (bfunc));
      if (istat)
        return (istat);
      if (dba_d[curs].sqlvar[k].sqltype == 9) {
        istat = RISdatetime_to_ascii (dba_d[curs].sqlvar[k].sqldata,
            retval.c, dba_timestamp_format);
        dba_dfree (dba_d[curs].sqlvar[k].sqldata);
        istat = dba_get_ptr_from_operand (function, opnum, num-3-i,
            (void **) &strptr, 1, 1, SCR_CHAR, 1, 0,
            dba_get_function_name (bfunc));
        if (istat)
          return (istat);
        istat = dba_mem_grow (function, opnum, num-3-i, strlen (retval.c)+1,
            (void **) &strptr);
        if (istat)
          return (istat);
        strcpy (strptr, retval.c);
      }
      else if (dba_d[curs].sqlvar[k].sqltype == 4) {
        istat = dba_store_int_to_ptrop (ptrop, valptr,
            *(long *) dba_d[curs].sqlvar[k].sqldata);
        if (istat)
          return (istat);
        dba_dfree (dba_d[curs].sqlvar[k].sqldata);
      }
      else if (dba_d[curs].sqlvar[k].sqltype == 8) {
        istat = dba_store_double_to_ptrop (ptrop, valptr,
            *(double *) dba_d[curs].sqlvar[k].sqldata);
        if (istat)
          return (istat);
        dba_dfree (dba_d[curs].sqlvar[k].sqldata);
      }
      dba_get_operand (function, opnum, num-4-i, &ptrop, &valptr);
      istat = dba_get_ptr_from_ptrop (ptrop, valptr, (void **) &cptr,
          1, 1, 0, 0, 1, dba_get_function_name (bfunc));
      if (istat)
        return (istat);
      if (cptr)
        istat = dba_store_int_to_ptrop (ptrop, valptr,
            *(long *) dba_d[curs].sqlvar[k].sqlind);
      dba_dfree (dba_d[curs].sqlvar[k].sqlind);
    }
  }

  dba_verbose_result_check (dba_get_function_name (bfunc), status, VERB_RIS_FUNCTIONS, 21);
  return dba_store_int_result (function, opnum, status,
      dba_get_function_name (bfunc));
}


#ifdef _DONEIT_
/* Function:  dba_s_close_cursor
   Author:    Tim A. Thompson
   Date:      13-AUG-90

    Revisions:
	4-26-92 --  Modified to call dba_close_cursor from the dev platform.
	7-30-92 --  Converted to new Scripting.
	1-12-93 --  Pass 'curs' as an int (but probably didn't need to since
		    this function is registered now).

------------------------------------------------------------------------------

DBA_CLOSE_CURSOR

	Closes the given RIS cursor.

Availability:	Menus/Reports

Function:	DBA_CLOSE_CURSOR (cursor)

Arguments:	Name		Type	Description


		cursor		int	Number of the cursor to close.
					(Currently must be 0 through 4.)


Return Value:	(int)	RIS return code (SQLCODE).  0 = Success.

Examples:

	int status, ind;
	char buffer[30];

	status = dba_select (0, 0, "select mfr_name from manufacturer");
	if (status)
	  dba_report_ris_error ();

	status = dba_fetch (0, 0, buffer, &ind);
	while (status != 100) {
	  status = dba_fetch (0, 0, buffer, &ind);
	  printf ("Manufacturer Name : %s\n", buffer);
	}
	status = dba_close_cursor (0);

NOTE:	The status of the select should ALWAYS be checked.

------------------------------------------------------------------------------
*/

long dba_s_close_cursor (bfunc, function, opnum)
functiontype *bfunc, *function;
long opnum;
{
  long curs, istat, status;

  istat = dba_check_num_arguments (bfunc, function, opnum, 1);
  if (istat)
    return (istat);

  istat = dba_get_int_from_operand (function, opnum, 0, &curs,
      dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  status = dba_close_cursor ((int)curs);

  dba_verbose_result_check (dba_get_function_name (bfunc), status,
      VERB_RIS_FUNCTIONS, 0);
  return dba_store_int_result (function, opnum, status,
      dba_get_function_name (bfunc));
}
#endif
