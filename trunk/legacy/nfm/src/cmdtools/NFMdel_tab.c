#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMdb.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMstruct.h"

extern struct NFMglobal_st NFMglobal ;

 long NFMdelete_table (user_id, table_type, table_name)
   long      user_id;
   char      *table_type, *table_name;
   {
     static char *fname = "NFMdelete_table" ;
     long     status, status1, error_no;
     int      error_subsystem ;
     char     message [512] ;
     char     sql_str[1024];
     MEMptr   bufr = NULL;
     long     NFMdrop_table ();
     long     NFMunload_attributes ();

     _NFMdebug ((fname, "Table Type  = <%s> : Table name = <%s>\n", 
		 table_type, table_name));

     ERRget_message (message) ;
     ERRget_number (&error_no, &error_subsystem) ;
     _NFMdebug ((fname, "error found was <0x%.8x> subsystem %d\n",
		 error_no, error_subsystem)) ;

     NFMchange_case (table_type, 1);

     if (! strcmp (table_type, "nfmsystem"))
      {
        ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
        _NFMdebug ((fname, "System  Table : status = <0x%.8x>\n",
        NFM_E_FAILURE));
        return (NFM_E_FAILURE);         
      }

     status = NFMunload_attributes (user_id, table_type, table_name);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Unload Attr : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMdrop_table (user_id, table_name);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Drop Table : status = <0x%.8x>\n", status));
         /* This code is added to take care of concurrent create/delete
            catalog problem which will leave the entries dangling in
            some tables [NFMCATALOGS, NFMTABLES etc ..]. To minimize this
            and make Delete catalog more fault tolerant, this code is put.
            - kumar  10.25.93 */
       sprintf(sql_str,"SELECT n_itemno from %s", table_name);
            status1 = SQLquery(sql_str,&bufr,512);
              if(status1 == SQL_S_SUCCESS)
               {
                 MEMclose(&bufr);
        _NFMdebug ((fname, "Drop table : status = <0x%.8x>\n", status));
        return (status);
                }
           MEMclose(&bufr);
      }

     if ((error_subsystem == SQL) && (error_no != SQL_S_SUCCESS))
       {
	 /* reload previous SQL error */
	 _NFMdebug ((fname, "Reloading SQL error <%d>\n", error_no)) ;
	 ERRload_struct (SQL, error_no, "%s", message) ;
	 ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
       }
     else if ((error_subsystem == MEM) && (error_no != MEM_S_SUCCESS))
       {
	 /* reload previous MEM error */
	 _NFMdebug ((fname, "Reloading MEM error <%d>\n", error_no)) ;
	 ERRload_struct (MEM, error_no, "%s", message) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMdrop_table (user_id, table_name)
   long    user_id;
   char    *table_name;
   {
     static char *fname = "NFMdrop_table" ;
     long     status;
     char     sql_str [1024];

     _NFMdebug ((fname, "Table Name  = <%s>\n", table_name));
     user_id = user_id ;

     sprintf (sql_str, "DROP TABLE %s", table_name);

     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_E_UNKNOWN_RELATION))
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
        return (NFM_E_SQL_STMT);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMunload_attributes (user_id, table_type, table_name)
   long   user_id;
   char   *table_type, *table_name;
   {
     static char *fname = "NFMunload_attributes" ;
     long    status, table_no ;
     long   _NFMdelete_n_tableno () ;

     _NFMdebug ((fname, "Table Type = <%s> : Table Name = <%s>\n",
		 table_type, table_name));
     user_id = user_id ;
     status = NFMset_autocommit_off (0) ;
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Set autocommit off : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = NFMget_table_no (NFMglobal.NFMuserid, table_type, table_name,
              &table_no);
     if ((status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
        status));
        return (status);  
      }   
     if (status != SQL_I_NO_ROWS_FOUND)
       {
	 status = _NFMdelete_n_tableno (table_no) ;
	 if (status != NFM_S_SUCCESS) 
	   {
	     NFMrollback_transaction (0);
	     _NFMdebug ((fname, "Unload Value List : status = <0x%.8x>\n",
			 status));
	     return (status);            
	   }
       }

     status = NFMset_autocommit_on (0) ;
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Set autocommit : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);  
   }

 long NFMunload_value_info (user_id, type, attr_no)
   long    user_id;
   char    *type;
   long    attr_no;
   {
     static char *fname = "NFMunload_value_info" ;
     long      status, atol ();
     char      sql_str [1024], value [50];
     long      NFMunload_list_info ();

     _NFMdebug ((fname, "Type = <%s> : Attr No = <%d>\n",
		 type, attr_no));

     sprintf (sql_str, "WHERE %s = %d AND %s = '%s'", 
              "n_attrno", attr_no, "n_type", type);
 
     status = NFMget_attr_value (user_id, "NFMVALUES", "n_listno",
              sql_str, value);
     if ((status != NFM_S_SUCCESS) && (status != NFM_I_BAD_CONDITION))
      {
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     if (atol (value) > 0)
      {
        status = NFMunload_list_info (user_id, atol (value));
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Unload List Info : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }

     sprintf (sql_str, "DELETE FROM %s WHERE %s = %d AND %s = '%s'",
              "NFMVALUES", "n_attrno", attr_no, "n_type", type);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS && 
         (status) != SQL_I_NO_ROWS_FOUND)
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);  
   }

 long NFMunload_list_info (user_id, list_no)
   long    user_id;
   long    list_no;
   {
     static char *fname = "NFMunload_list_info" ;
     long     status;
     char     sql_str [1024];

     _NFMdebug ((fname, "List No = <%d>\n", list_no));

     sprintf (sql_str, "DELETE FROM NFMLISTS WHERE n_listno = %d",
              list_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);
      }

     status = NFMreturn_serial_slot (user_id, "nfmlists",
              "n_listno", list_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Ret Empty Slot : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);  
   }

long _NFMdelete_application_tables (catalog_name)
     char *catalog_name ;
{
  char *fname = "_NFMdelete_application_tables" ;
  long status, i ;
  MEMptr buffer = NULL ;
  char sql_str [1024], **data ;
  char temp_cat_name[NFM_CATALOGNAME+1];
  
  _NFMdebug ((fname, "catalog name = <%s>\n", catalog_name)) ;
  strcpy (temp_cat_name, catalog_name);
  NFMchange_case (temp_cat_name, 1);

  sprintf (sql_str, "Select n_tablename from nfmtables where n_tabletype = '%s'",
	   temp_cat_name) ;

  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&buffer) ;
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "No application tables found\n")) ;
	  return (NFM_S_SUCCESS) ;
	}
      _NFMdebug ((fname, "SQL query failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&buffer) ;
      _NFMdebug ((fname, "MEMbuild array (buffer) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  data = (char **) buffer->data_ptr ;

  for (i=0; i<buffer->rows; i++)
    {
      status =  NFMdelete_table (NFMglobal.NFMuserid, 
				 catalog_name, data [0]) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Application table %s did not got deleted\n",
		      data [0])) ;
	}
    }
  status = MEMclose (&buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose (buffer) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
long _NFMdelete_n_tableno (table_no) 
     long table_no ;
{
  char *fname = "_NFMdelete_n_tableno" ;
  char sql_str [512] ;
  long status, sql_status, i, offset, atol() ;
  char **data ;
  long prev_attrno =0 , prev_listno = 0 ;
  MEMptr sql_buffer = NULL ;

  _NFMdebug ((fname, "table no %d\n", table_no));
  
  sprintf (sql_str, "select DISTINCT a.n_attrno, c.n_listno from nfmattributes a, nfmvalues b, nfmlists c where a.n_tableno = %d and a.n_attrno = b.n_attrno and b.n_listno = c.n_listno",
	   table_no) ;
  
  sql_status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if ( (sql_status != SQL_S_SUCCESS) && (sql_status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", 
		  sql_status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  sprintf (sql_str, "delete from nfmlists \
where n_listno in (select n_listno from nfmvalues where n_attrno in \
(select n_attrno from nfmattributes where n_tableno = %d))",
	   table_no);

  status = SQLexec_imm (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "SQL failed : status = <0x%.8x>\n",
                  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  sprintf (sql_str, "delete from nfmvalues \
  where n_attrno in (select n_attrno from nfmattributes where n_tableno = %d)",
	   table_no) ;
  status = SQLexec_imm (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "SQL failed : status = <0x%.8x>\n",
                  status)) ;
      return (NFM_E_SQL_STMT) ;
    }

  sprintf (sql_str, "delete from nfmattributes \
  where n_tableno = %d",
	   table_no) ;
  status = SQLexec_imm (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "SQL failed : status = <0x%.8x>\n",
                  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  sprintf (sql_str, "delete from nfmtables where n_tableno = %d",
	   table_no) ;
  status = SQLexec_imm (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "SQLexec_imm : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL) ;
      return (NFM_E_SQL_STMT) ;
    }

  if (sql_status != SQL_I_NO_ROWS_FOUND)
    {
      status = MEMbuild_array (sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
          MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
      
      data = (char **) sql_buffer -> data_ptr ;
      
      prev_attrno = 0 ;
      prev_listno = 0 ;
      for (i=0; i<sql_buffer->rows; i++)
	{
	  offset = sql_buffer->columns*i;
	  if (prev_attrno != atol (data [offset]))
	    {
	      NFMreturn_serial_slot (NFMglobal.NFMuserid, "nfmattributes",
				     "n_attrno", atol (data [offset])) ;
	      prev_attrno = atol (data [offset]) ;
	    }
	  
	  if (prev_listno != atol (data [offset+1]))
	    {
	      NFMreturn_serial_slot (NFMglobal.NFMuserid, "nfmlists",
				     "n_listno", atol (data [offset+1])) ;
	      prev_listno = atol (data [offset+1]) ;
	    }
	}
    }

    status = MEMclose (&sql_buffer) ;
    if (status != MEM_S_SUCCESS)
   {
        _NFMdebug ((fname, "MEMclose (sql_buffer) : status = <0x%.8x>\n",
	      status)) ;
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
   }

  NFMreturn_serial_slot (NFMglobal.NFMuserid, "nfmtables",
			 "n_tableno", table_no) ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

