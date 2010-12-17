#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMdb.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMget_serial_slot (user_id, table_name, col_name, serial_no)
   long    user_id;
   char    *table_name, *col_name;
   long    *serial_no;
   {
      long     status, atol ();
      char     sql_str [1024], value [50];
      char     *fname="NFMget_serial_slot";

      *serial_no = 0;

      _NFMdebug ((fname, "Table  Name = <%s> : Col Name = <%s>\n", 
		  table_name, col_name));

      sprintf (sql_str, " WHERE n_tablename = '%s'", table_name);
            
      status = NFMget_attr_value (user_id, "NFMINDEX", "MIN(n_indexslot)",
               sql_str, value);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
         return (status); 
       }

      *serial_no = atol (value);
        
      if (*serial_no)
       {
         sprintf (sql_str, "DELETE FROM %s WHERE %s = '%s' AND %s = %d",
                  "NFMINDEX", "n_tablename", table_name, "n_indexslot",
                  *serial_no);

         status = SQLstmt (sql_str);
         if (status != SQL_S_SUCCESS)
          {
            ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
            _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
			status));
            return (NFM_E_SQL_STMT); 
          }

         _NFMdebug ((fname, "EMPTY SLOT EXISTS : status = <0x%.8x>\n",
         *serial_no));
       }
      else 
       {
         sprintf (sql_str, "MAX(%s)", col_name);
            
         status = NFMget_attr_value (user_id, table_name, 
                  sql_str, "", value);
         if (status != NFM_S_SUCCESS)
          {
            _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
            return (status); 
          }

         *serial_no = atol (value) + 1;
          
         _NFMdebug ((fname, "EMPTY SLOT DOESNOT EXISTS <%d>\n", *serial_no));
       }
   
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMreturn_serial_slot (user_id, table_name, col_name, serial_no)
   long     user_id;
   char     *table_name, *col_name;
   long     serial_no;
   {
     static char *fname = "NFMreturn_serial_slot" ;
     long     status, atol ();
     char     sql_str [1024], value [50];

     _NFMdebug ((fname, "Table  Name = <%s> : Col Name = <%s>\n",
		 table_name, col_name));

     sprintf (sql_str, " WHERE %s = %d", col_name, serial_no);
            
     status = NFMget_attr_value (user_id, table_name, col_name,
              sql_str, value);
     if (status != NFM_I_BAD_CONDITION)
      {
        if (status == NFM_S_SUCCESS)
         {
            ERRload_struct (NFM, NFM_E_INDEX_INUSE, "", NULL);
           _NFMdebug ((fname, "Slot Not Free : status = <0x%.8x>\n",
           NFM_E_INDEX_INUSE));
           return (NFM_E_INDEX_INUSE); 
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status); 
      }

     sprintf (sql_str, "MAX(%s)", col_name);
           
     status = NFMget_attr_value (user_id, table_name, sql_str, "", value);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status); 
      }

     if (atol (value) > serial_no)
      {
        sprintf (sql_str, "INSERT INTO NFMINDEX (%s) VALUES ('%s', %d)",
                 "n_tablename, n_indexslot", table_name, serial_no);

        status = SQLstmt (sql_str);
        if ((status != SQL_S_SUCCESS) && 
            (status != SQL_E_DUPLICATE_VALUE))
         {
            ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
           _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
		       status));
           return (NFM_E_SQL_STMT); 
         }
      }

     sprintf (sql_str, "DELETE FROM %s WHERE %s = '%s' AND %s > %d",
              "NFMINDEX", "n_tablename", table_name, "n_indexslot",
              atol (value));

     status = SQLstmt (sql_str);
/*
*    if ((status != SQL_S_SUCCESS) && ((status ) != SQL_I_NO_ROWS_FOUND))
*       DUR 1/6/91
*/
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
            ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
        status));
        return (status); 
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMget_serial_slot_no_index (user_id, table_name, col_name, serial_no)
   long    user_id;
   char    *table_name, *col_name;
   long    *serial_no;
   {
     static char *fname = "NFMget_serial_slot_no_index" ;
      long     status, atol ();
      char     sql_str [1024], value [50];

      *serial_no = 0;

      _NFMdebug ((fname, "Table  Name = <%s> : Col Name = <%s>\n", 
		  table_name, col_name));

      sprintf (sql_str, "MAX(%s)", col_name);
      
      status = NFMget_attr_value (user_id, table_name, 
				  sql_str, "", value);
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
	  return (status); 
	}
      
      *serial_no = atol (value) + 1;
          
      _NFMdebug ((fname, "EMPTY SLOT DOESNOT EXISTS <%d> : SUCCESS\n",
		*serial_no));
   
      return (NFM_S_SUCCESS);
   }


 long NFMget_serial_slot_wck (user_id, table_name, col_name, serial_no,
			     flag)
   long    user_id;
   char    *table_name, *col_name;
   long    *serial_no;
   long    *flag ;
   {
     static char *fname = "NFMget_serial_slot_wck" ;
      long     status, atol ();
      char     sql_str [1024], value [50];

      *serial_no = 0;

      _NFMdebug ((fname, "Table  Name = <%s>  : Col Name = <%s>\n", 
		  table_name, col_name));

      sprintf (sql_str, " WHERE n_tablename = '%s'", table_name);
            
      status = NFMget_attr_value (user_id, "NFMINDEX", "MIN(n_indexslot)",
               sql_str, value);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
         return (status); 
       }

      *serial_no = atol (value);

      *flag = 0 ;
        
      if (*serial_no)
       {
         sprintf (sql_str, "DELETE FROM %s WHERE %s = '%s' AND %s = %d",
                  "NFMINDEX", "n_tablename", table_name, "n_indexslot",
                  *serial_no);

         status = SQLstmt (sql_str);
         if (status != SQL_S_SUCCESS)
          {
            ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
            _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
			status));
            return (NFM_E_SQL_STMT); 
          }

         _NFMdebug ((fname, "EMPTY SLOT EXISTS <%d>\n",  *serial_no));
       }
      else 
       {
	 *flag = 1 ;
         sprintf (sql_str, "MAX(%s)", col_name);
            
         status = NFMget_attr_value (user_id, table_name, 
                  sql_str, "", value);
         if (status != NFM_S_SUCCESS)
          {
            _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
            return (status); 
          }

         *serial_no = atol (value) + 1;
          
         _NFMdebug ((fname, "EMPTY SLOT DOESNOT EXISTS <%d>\n", *serial_no));         
       }
   
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

