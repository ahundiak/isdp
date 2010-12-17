/* $Revision: 1.1 $ */
#include <stdlib.h>
#include "dba.ext"
#include "script.def"

/*
    Function:  dba_s_get_code_number_text
    Author:    Tim A. Thompson
    Date:      22-FEB-91

    Revisions:
	7-25-92  -- Converted to new Scripting.
	10-23-92 -- Got rid of references to dba_stext.
	9-22-93  -- Don't calc size if buffer pointed to by real c pointer.

------------------------------------------------------------------------------

DBA_GET_CODE_NUMBER

	This function returns the code number for the specified coded
	column's code text.  Since code lists are stored in memory,
	calling this function is quicker than dba_select(), which 
	would go to the database for the value.  It is primarily
	intended for menu script (since menu fields contain code text
	instead of code number), but may be used from any script.

Availability:	Menus/Reports

Function:       DBA_GET_CODE_NUMBER (schema, table, column, code_number,
				     code_text);

Arguments:      Name            Type    Description

                schema          char *  Schema name or number from which
					data is to be retrieved.
					(0 for current schema.)

                table           char *  Table name or number from which 
					data is to be retrieved.  
					(0 for current table.)

                column          char *  Column from which data is to be
                                        retrieved.

		code_number	int *	Returned code number.

                code_text       char *	Code text of the desired code number.

Return Value:   (int)   0       - Success
                        not 0   - Failure -- Error message in dba_errtxt.

Example:
	status = dba_get_code_number ("auto1", "part", "function_code", 
					&number, code_text);

	status = dba_get_code_number (0, 0, "function_code", &number, "CODE");

------------------------------------------------------------------------------
------------------------------------------------------------------------------

DBA_GET_CODE_TEXT

	This function returns the code text for the specified coded
	column's code number.  Since code lists are stored in memory,
	calling this function is quicker than dba_select(), which 
	would go to the database for the value.  It is primarily
	intended for reports, but may be used from any script.

	NOTE:  Processing reports does not change the the current schema
	or table.  For that reason, the schema and table arguments
	should not be defaulted to 0 when this function is called from
	report script unless the report is being run from a menu of the 
	desired schema and table.

Availability:	Menus/Reports

Function:       DBA_GET_CODE_TEXT (schema, table, column, code_number,
				   code_text);

Arguments:      Name            Type    Description

                schema          char *  Schema name or number from which
					data is to be retrieved.
					(0 for current schema.)

                table           char *  Table name or number from which 
					data is to be retrieved.  
					(0 for current table.)

                column          char *  Column from which data is to be
                                        retrieved.

		code_number	int	Code number of the desired code text.

                code_text       (any) * Buffer to contain code text.  Like
                                        DBA_GET_FIELD, this function will
                                        attempt to convert the data type of
                                        the column to the type of 'code_text'.
                                        If 'code_text' is not large enough, 
                                        space will automatically be allocated.

Return Value:   (int)   0       - Success
                        not 0   - Failure -- Error message in dba_errtxt.

Report Script Example:
		status = dba_get_code_text ("auto1", "part", "function_code",
					    c_function_code, text);

Menu Script Example:
		status = dba_get_code_text (0, 0, "function_code", 23, text);

------------------------------------------------------------------------------
*/

long dba_s_get_code_number_text (bfunc, function, opnum, mode)
functiontype *bfunc, *function;
long opnum, mode;
{
  long istat, status, len=0, num, dyn;
  unsigned long spare_room;
  void *valptr;
  char *schema, *table, *column, schema_buf[10], table_buf[10], column_buf[10],
       stext[241];
  void *cptr;
  operandtype *ptrop;

  istat = dba_check_num_arguments (bfunc, function, opnum, 5);
  if (istat)
    return (istat);

  istat = dba_get_str_val_from_operand (function, opnum, 4, &schema,
      schema_buf, dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  istat = dba_get_str_val_from_operand (function, opnum, 3, &table,
      table_buf, dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  istat = dba_get_str_val_from_operand (function, opnum, 2, &column,
      column_buf, dba_get_function_name (bfunc));
  if (istat)
    return (istat);

  switch (mode) {
#ifdef _DONEIT_
    case DBA_GET_CODE_NUMBER:
      dba_get_operand (function, opnum, 1, &ptrop, &valptr);
      istat = dba_get_ptr_from_ptrop (ptrop, valptr, &tmpptr, 1, 1, 0, 0, 0,
          dba_get_function_name (bfunc));
      if (istat)
        return (istat);

      istat = dba_get_ptr_from_operand (function, opnum, 0, (void **)&txt,
          1, 1, SCR_CHAR, 1, 0, dba_get_function_name (bfunc));
      if (istat)
        return (istat);

      status = dba_get_code_number (schema, table, column, &val, txt);
      dba_store_int_to_ptrop (ptrop, valptr, (long) val);
      break;
#endif
    case DBA_GET_CODE_TEXT:
      istat = dba_get_int_from_operand (function, opnum, 1, &num,
          dba_get_function_name (bfunc));
      if (istat)
        return (istat);

      dba_get_operand (function, opnum, 0, &ptrop, &valptr);
      istat = dba_get_ptr_from_ptrop (ptrop, valptr, &cptr, 1, 1, 0, 0, 0,
          dba_get_function_name (bfunc));
      if (istat)
        return (istat);

      if (ptrop->is_real_c)
        dyn = 0;
      else
        dyn = dba_calc_ptr_dynamic_size (function, opnum, 0, &spare_room);
      if (ptrop->type == SCR_CHAR && (!dyn || dyn && spare_room > 241)) {
        status = dba_get_code_text (schema, table, column, num, cptr);
        if (!status && dyn && strlen(cptr) > spare_room-1) {
          dba_standard_function_error (dba_get_function_name (bfunc));
          dba_add_error (dba_get_msg(DBA_E_SCR_BUF_OVFLOW1,NP,0,NP,NP));
          dba_add_error (dba_get_msg(DBA_E_SCR_BUF_OVFLOW2,NP,0,NP,NP));
          dba_add_error (dba_get_msg(DBA_E_SCR_BUF_OVFLOW3,NP,0,NP,NP));
          dba_add_error (dba_get_msg(DBA_E_SCR_BUF_OVFLOW4,NP,0,NP,NP));
          return (99);
        }
      }
      else
      {
        status = dba_get_code_text (schema, table, column, num, stext);
        if (!status) {
          switch (ptrop->type) {
            case SCR_CHAR:
              len = strlen (stext);
              if (len > 240) {
                dba_standard_function_error (dba_get_function_name (bfunc));
                dba_add_error (dba_get_msg (DBA_E_SCR_BUF_OVFLOW1, NP, 0,
                    NP, NP));
                dba_add_error (dba_get_msg (DBA_E_SCR_BUF_OVFLOW2, NP, 0,
                    NP, NP));
                dba_add_error (dba_get_msg (DBA_E_SCR_BUF_OVFLOW3, NP, 0,
                    NP, NP));
                dba_add_error (dba_get_msg (DBA_E_SCR_BUF_OVFLOW4, NP, 0,
                    NP, NP));
                return (99);
              }
              if (len > spare_room-1) {
                istat = dba_mem_grow (function, opnum, 0, len+1, &cptr);
                if (istat)
                  return (istat);
              }
              strcpy (cptr, stext);
              break;
            case SCR_SHORT:
            case SCR_INT:
            case SCR_LONG:
              dba_store_int_to_ptrop (ptrop, valptr, atol (stext));
              break;
            case SCR_FLOAT:
            case SCR_DOUBLE:
              dba_store_double_to_ptrop (ptrop, valptr, atof (stext));
              break;
          }
        }
      }
      break;
    default:
      status = -1;
      dba_internal_error ("dba_s_get_code_number_text", "dbs_get_code.c");
  }

  dba_verbose_result_check (dba_get_function_name(bfunc), status,
      VERB_DBA_FUNCTIONS, 0);
  return dba_store_int_result (function, opnum, status,
      dba_get_function_name (bfunc));
}
