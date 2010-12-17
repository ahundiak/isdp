#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMget_table_no (user_id, table_type, table_name, table_no)
   long    user_id;
   char    *table_type, *table_name;
   long    *table_no;
   {
     static char *fname = "NFMget_table_no" ;
     long    status, atol ();
     user_id = user_id ;
     *table_no = 0;

     _NFMdebug ((fname, "Table Type = <%s>  : Table Name = <%s>\n",
		 table_type, table_name));

     NFMchange_case (table_type, 1);
     if (! strcmp (table_type, "nfmsystem")) NFMchange_case (table_name, 1);

     status = SQLfix_qry_res_3 (table_type, table_name, table_no);
     if (status != SQL_S_SUCCESS) 
      {
	if (status == SQL_I_NO_ROWS_FOUND)
	  {
	    _NFMdebug ((fname, "No rows found\n")) ;
	    return (status) ;
	  }
	ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
      }

     _NFMdebug ((fname, "SUCCESSFUL : Table No = <%d>\n", *table_no));
     return (NFM_S_SUCCESS);
   }

 long NFMget_table_name (user_id, table_no, table_type, table_name)
   long    user_id;
   long    table_no;
   char    *table_type, *table_name;
   {
     static char *fname = "NFMget_table_name" ;
     long    status;
     char    sql_str [1024];
     MEMptr  list = NULL;
     char    **data;

     table_type [0] = 0; table_name [0] = 0;
     user_id = user_id ;
     _NFMdebug ((fname, "Table No   = <%d>  : Table Type = <%s>\n",
		 table_no, table_name));

     sprintf (sql_str, "SELECT %s, %s FROM %s WHERE %s = %d",
              "n_tabletype", "n_tablename", 
              "NFMTABLES", "n_tableno", table_no);
 
     status = SQLquery (sql_str, &list, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list);
        _sql_error (status);

        if ((status ) != SQL_I_NO_ROWS_FOUND)
         {
           ERRload_struct (NFM, NFM_E_BAD_TABLE, "", NULL);
           _NFMdebug ((fname, "No Such Table : status = <0x%.8x>\n",
           NFM_E_BAD_TABLE));
           return (NFM_E_BAD_TABLE);
         }

           ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY);
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     data = (char **) list -> data_ptr;

     sprintf (table_type, "%s", data [0]);
     sprintf (table_name, "%s", data [1]);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     _NFMdebug ((fname, "SUCCESSFUL : Table Type = <%s> : Table Name = <%s>\n",
		 table_type, table_name));
     return (NFM_S_SUCCESS);
   }
