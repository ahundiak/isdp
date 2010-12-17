#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMdb.h"
#include "NFMerrordef.h"
#include "SQLstruct.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMstruct.h"
#include "NFMschema.h"
#define TEMPLATE_LEN  8

  extern struct NFMglobal_st NFMglobal ;

 long _NFMcreate_table (table_type, table_name, identifier, table_no,
                       attr_list, data_list, value_list)
   char      *table_type, *table_name, *identifier;
   long      *table_no ;
   MEMptr    attr_list, data_list, value_list;
   {
     static char *fname = "NFMcreate_table" ;
     long     status, user_id ;
     long     _NFMcreate_attributes ();
     long     _NFMload_attributes ();

     _NFMdebug ((fname, "Table Type  = <%s> : Table Name = <%s> : Identifier = <%s>\n", 
		 table_type, table_name, identifier));

     user_id = NFMglobal.NFMuserid ;
     status = _NFMcreate_attributes (table_name, attr_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Create Table Failed : status = <0x%.8x>\n",
        status));
        return (status);         
      }

     
     status = _NFMload_attributes (table_type, table_name, identifier, 
				   table_no,
				   attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Load Table Attr Failed : status = <0x%.8x>\n",
        status));
        return (status);         
      }
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long _NFMcreate_attributes (table_name, attr_list)
   char     *table_name;
   MEMptr   attr_list;
   {
     static char *fname = "NFMcreate_attributes" ;
     long    status;
     char    *sql_str;
     char    **data, **column;
     long    a, b, x, y, count;

     _NFMdebug ((fname, "Create Database/Ris Table  <%s>\n", 
		 table_name));

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",status));
        return (NFM_E_MEM);
      }
     
     sql_str = (char *) malloc (attr_list -> rows * 50) ;
     if (! sql_str)
      {
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }
     sql_str [0] = 0;

     _NFMdebug ((fname, "Table Name  = <%s>\n", table_name));

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1;  b = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
      }

     sprintf (sql_str, "CREATE TABLE %s (", table_name);

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        if (x) strcat (sql_str, ", ");

        strcat (sql_str, data [count + a]);
        strcat (sql_str, " ");
	if (strcmp (data [count + b], "timestamp") == 0)
	  strcat (sql_str, "timestamp") ;
	else
	  strcat (sql_str, data [count + b]);        
      }

     strcat (sql_str, ")");

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);        
        if ((status == SQL_E_DUPLICATE_VALUE)||(status == SQL_E_TABLE_EXISTS))
          {
            ERRload_struct (NFM, NFM_E_DUP_CATALOG, "", NULL);
            _NFMdebug ((fname, "DB Table %s exists : status = <0x%.8x>\n",
                      table_name, NFM_E_DUP_CATALOG));
            return (NFM_E_DUP_CATALOG);
          }

        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		  NFM_E_SQL_STMT));
        return (NFM_E_SQL_STMT);     
      }
/******* mms -11/22/92- according to RIS this statement is unneccessary *****
     sprintf (sql_str, "REVOKE ALL ON %s FROM PUBLIC", table_name);

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        sprintf (sql_str, "DROP TABLE %s", table_name);
        SQLexec_imm (sql_str);

        free (sql_str);        
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
        return (NFM_E_SQL_STMT);     
      }
***********************************************************************/
     free (sql_str);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long _NFMload_attributes (table_type, table_name, identifier, table_no,
                          attr_list, data_list, value_list)
   char      *table_type, *table_name, *identifier;
   long      *table_no ;
   MEMptr    attr_list, data_list, value_list;
   {
     static char *fname = "_NFMload_attributes" ;
     long     status, atol (), user_id ;
     long     attr_no;
     char     sql_str [4096];
     char     sql_str1 [2048], sql_str2 [2048];
     long     x, y, count;
     char     **column, **data, **data1;
     long     a, b, c, f, g, h, i, j, k, l, m, n, o, p, q ;
     long     skip_serial_slot ;
     long     _NFMload_value_info ();
     long     _NFMload_advice_info () ;
     long     _NFMdelete_values () ;

     _NFMdebug ((fname, "Table Type  = <%s> : Table Name = <%s> : Identifier = <%s>\n", 
		 table_type, table_name, identifier));
     user_id = NFMglobal.NFMuserid ;
     status = NFMset_autocommit_off (0) ;
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "Locking tables nfmindex and nfmtables\n")) ;

     status = NFMlock_table ("NFMINDEX, NFMTABLES") ;
     if (status != NFM_S_SUCCESS)
       {
       status = NFMlock_table ("NFMINDEX, NFMTABLES") ;
       if (status != NFM_S_SUCCESS)
        {
            /*  Modified by kumar for concurrent access 
            locking the tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
                sleep (30);
               status = NFMlock_table ("NFMINDEX, NFMTABLES") ;
               if (status != NFM_S_SUCCESS) {
                sleep (30);
               status = NFMlock_table ("NFMINDEX, NFMTABLES") ;
               if (status != NFM_S_SUCCESS) {
	 _NFMdebug ((fname, "NFMlock_table failed : status = <0x%.8x>\n",
		     status));
	 return (status) ;
                     }
             }
        } 
       }

     status = NFMget_serial_slot (user_id, "nfmtables",
				  "n_tableno", table_no) ;
     if (status != NFM_S_SUCCESS)
       {
	 NFMrollback_transaction (0) ;
	 _NFMdebug ((fname, "NFMget_serial_slot : status = <0x%.8x>\n",
		     status));
	 return (status) ;
       }

     NFMchange_case (table_type, 1);

     if (! strcmp (table_type, "nfmsystem")) NFMchange_case (table_name, 1) ;

     sprintf (sql_str, "INSERT INTO %s (%s) VALUES (%d, '%s', '%s', '%s')",
              "NFMTABLES", "n_tableno, n_tabletype, n_tablename, n_identifier",
              *table_no, table_type, table_name, identifier);

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction (0); 

        if ((status == SQL_E_DUPLICATE_VALUE)||(status == SQL_E_TABLE_EXISTS))
         {
           ERRload_struct (NFM, NFM_E_DUP_TABLE_NAME, "", NULL);
           _NFMdebug ((fname, "Table Name Exists : status = <0x%.8x>\n",
           NFM_E_DUP_TABLE_NAME));
           return (NFM_E_DUP_TABLE_NAME);           
         }

        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "Sql Stmt Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);
      }

     status = NFMset_autocommit_on (0) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "NFMset autocommit on : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array (attr_list) : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array (data_list) : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     data1   = (char **) data_list -> data_ptr;

     a = -1; b = -1; c = -1; 
     f = -1; g = -1; h = -1; k = -1; l = -1;
     m = -1; n = -1; o = -1; p = -1; j = -1; i =-1 ;
     q = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
        else if (! strcmp (column [y], "n_synonym"))     c = y;
        else if (! strcmp (column [y], "n_read"))        f = y;
        else if (! strcmp (column [y], "n_write"))       g = y;
        else if (! strcmp (column [y], "n_update"))      h = y;
        else if (! strcmp (column [y], "n_delete"))      i = y;
        else if (! strcmp (column [y], "n_null"))        j = y;
        else if (! strcmp (column [y], "n_adviceno"))    k = y;
        else if (! strcmp (column [y], "n_checkin"))     l = y;
        else if (! strcmp (column [y], "n_checkout"))    m = y;
        else if (! strcmp (column [y], "n_application")) n = y;
        else if (! strcmp (column [y], "n_valueno"))     o = y;
        else if (! strcmp (column [y], "n_seqno"))       p = y;
	else if (! strcmp (column [y], "n_advice"))      q = y;
      }

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        NFMchange_case (data [count + a], 1);
      }

     sprintf (sql_str1, "INSERT INTO %s (%s%s%s%s%s) VALUES (%d, ",
              "NFMATTRIBUTES",
              "n_tableno, n_attrno, ",
              "n_name, n_datatype, n_synonym, ",
              "n_read, n_write, n_update, n_delete, ",
              "n_null, n_checkin, n_checkout, n_application, ", 
              "n_lattrno, n_seqno",
              *table_no);

     skip_serial_slot = 0;

     for (x = 0; x < attr_list -> rows; ++x)
      {
         count = attr_list -> columns * x;

        if (!skip_serial_slot)
	  {
	    status = NFMget_serial_slot_wck (user_id, "nfmattributes",
					     "n_attrno", &attr_no,
					     &skip_serial_slot);
	    if (status != NFM_S_SUCCESS)
	      {
		_NFMdebug ((fname, "Get Attr No : status = <0x%.8x>\n",
			  status));
		return (status);
	      }
	  }
	 else
	   {  
	     status = NFMget_serial_slot_no_index(user_id, "nfmattributes",
						  "n_attrno", &attr_no) ;
             if (status != NFM_S_SUCCESS)
               {
                 _NFMdebug ((fname, "Get Attr No : status = <0x%.8x>\n",
                           status));
                 return (status);
               }
	   }

         if (atol (data [count + o]) > 0)
          {
            status = MEMreset_buffer_no (value_list,
                     atol (data [count + o]));
            if (status != MEM_S_SUCCESS)
             {
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "MEM Reset No : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);                
             }

            status = _NFMload_value_info ("C", attr_no, data1 [x], value_list);
            if (status != NFM_S_SUCCESS)
             {
	       _NFMdelete_values (attr_no) ;
               _NFMdebug ((fname, "Load Check Info : status = <0x%.8x>\n",
               status));
               return (status);                
             }
          }
         else if (strlen (data1 [x]))
          {
            status = _NFMload_value_info ("C", attr_no, data1 [x], NULL);
            if (status != NFM_S_SUCCESS)
             {
	       _NFMdelete_values (attr_no) ;
               _NFMdebug ((fname, "Load Check Info : status = <0x%.8x>\n",
               status));
               return (status);                
             }
          }
	 if (strlen (data [count+q]))
	   {
	     status = _NFMload_advice_info (data [count+q], attr_no) ;
	     if (status != NFM_S_SUCCESS)
	       {
		 _NFMdelete_values (attr_no) ;
		 _NFMdebug ((fname, "Load advice Info : status = <0x%.8x>\n",
			     status));
		 return (status);                
	       }
	   }
/******
         if (atol (data [count + k]) > 0)
          {
            status = MEMreset_buffer_no (value_list, atol (data [count + k]));
            if (status != MEM_S_SUCCESS)
             {
	       _NFMdelete_values (attr_no) ;
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "MEM Reset No : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);                
             }
             
            status = _NFMload_value_info ("A", attr_no, "", value_list);
            if (status != NFM_S_SUCCESS) 
             {
	       _NFMdelete_values (attr_no) ;
               NFMrollback_transaction (0); 
               _NFMdebug ((fname, "Load Advice Info : status = <0x%.8x>\n",
               status));
               return (status);                
             }
          }
*************************/
         NFMchange_case (data [count + f], 0);
         NFMchange_case (data [count + g], 0);
         NFMchange_case (data [count + h], 0);
         NFMchange_case (data [count + i], 0);
         NFMchange_case (data [count + j], 0);
         NFMchange_case (data [count + l], 0);
         NFMchange_case (data [count + m], 0);
         NFMchange_case (data [count + n], 0);

         sprintf (sql_str2, 
       "%d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', ",
         attr_no, data [count + a], data [count + b], data [count + c],
         data [count + f], 
         data [count + g], data [count + h], data [count + i],
         data [count + j]);

         sprintf (sql_str, "%s%s '%s', '%s', '%s',  %s, ",
         sql_str1, sql_str2, data [count + l], data [count + m],
         data [count + n], "null");

         if (strlen (data [count + p]))
           strcat (sql_str, data [count + p]);
         else
           strcat (sql_str, "null");

         strcat (sql_str, ")");
   
         status = SQLexec_imm (sql_str);
         if (status != SQL_S_SUCCESS)
          {
            if (status == SQL_E_DUPLICATE_VALUE)
             {
               ERRload_struct (NFM, NFM_E_DUP_ATTR_NAME, "", NULL);
               _NFMdebug ((fname, "Dup Attr : status = <0x%.8x>\n",
               NFM_E_DUP_ATTR_NAME));
               return (NFM_E_DUP_ATTR_NAME);                
             }

            ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
            _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			status));
            return (NFM_E_SQL_STMT);                
          }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long _NFMload_value_info (type, attr_no, def_value, value_list)
   char      *type;
   long      attr_no;
   char      *def_value;
   MEMptr    value_list;
   {
     static char *fname = "_NFMload_value_info" ;
     long    status, user_id ;
     long    x, count;
     char    max [100], min [100];
     long    list_no, prog_no, def_no;
     char    list_num [50] ;
     char    prog_num [50], def_num [50];
     char    **column, **data;
     char    sql_str [1024];
     long    _NFMdelete_n_listno () ;

     _NFMdebug ((fname, "Attr No = <%d> : Def Value = <%s>\n", 
		 attr_no, def_value));

     list_no = 0;     prog_no = 0;
     def_no  = 0;
     min [0] = 0;     max [0] = 0;

     user_id = NFMglobal.NFMuserid ;
     
     if (value_list)
      {
        column = (char **) value_list -> column_ptr;
        data   = (char **) value_list -> data_ptr;
	x = 0 ;
	count = value_list -> columns * x;
	/* only one should be per attribute no */
	
	if (! strcmp (data [count], "NFM_RANGE"))
	  {
	    strcpy (min, data [count + 1]) ;
	    strcpy (max, data [count + 2]) ;
	  }
	else if (! strcmp (data [count], "NFM_DEFAULT"))
	  {
	    if (strlen (data [count + 4]))
	      {
		status = NFMget_program_no (user_id,
					    data [count+4], &def_no) ;
		if (status != NFM_S_SUCCESS)
		  {
		    _NFMdebug ((fname, "Failure : Bad program no : status = <0x%.8x>\n", status)) ;
		    return (status) ;
		  }
	      }
	  }
	else if (! strcmp (data [count], "NFM_PROGRAM"))
	  {
	    if (strlen (data [count + 4]))
	      {
		status = NFMget_program_no (user_id,
					    data [count+4], &prog_no) ;
		if (status != NFM_S_SUCCESS)
		  {
		    _NFMdebug ((fname, "Failure : Get program no : status = <0x%.8x>\n", status)) ;
		    return (status) ;
		  }
	      }
	  }

        for (x = 0; x < value_list -> rows; ++x)
         {
           count = value_list -> columns * x;

           if ((! strcmp (data [count], "NFM_STATIC")) &&
	       (strlen (data [count+3])))
            {
/*	      data = (char **) value_list -> data_ptr;
	      
	      count = value_list -> columns * x;  */
		  
	      if (!list_no)
		{
		  status = NFMget_serial_slot (user_id, "nfmlists",
					       "n_listno", &list_no);
		  if (status != NFM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Get Serial No : status = <0x%.8x>\n",
				  status));
		      return (status);
		    }
		}

	      sprintf (sql_str,
		       "INSERT INTO NFMLISTS (%s) VALUES (%d, '%s')",
		       "n_listno, n_value", list_no, data [count + 3]);
	      
	      status = SQLexec_imm (sql_str);
	      if (status != SQL_S_SUCCESS)
		{
		  _NFMdelete_n_listno (list_no) ;
		  if (status == SQL_E_DUPLICATE_VALUE)
		    {
		      ERRload_struct (NFM, NFM_E_DUP_LIST_VALUE, "", NULL);
		      _NFMdebug ((fname, "Dup Lst Val : status = <0x%.8x>\n",
				  NFM_E_DUP_LIST_VALUE));
		      return (NFM_E_DUP_LIST_VALUE);
		    }
		  
		  ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
		  _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			      status));
		  return (NFM_E_SQL_STMT);            
		}
	    }
	 }
      }

     if ((! strlen (def_value)) && (! def_no)       &&
         (! strlen (min))       && (! strlen (max)) &&
         (! list_no)            && (! prog_no))
      {
        _NFMdebug ((fname, "NO DEF SET UP : status = <0x%.8x>\n",
        NFM_S_SUCCESS));
        return (NFM_S_SUCCESS);
      }

     if (def_no)      sprintf (def_num, "%d", def_no);
     else             sprintf (def_num, "null");

     if (list_no)     sprintf (list_num, "%d", list_no);
     else             sprintf (list_num, "null");

     if (prog_no)     sprintf (prog_num, "%d", prog_no);
     else             sprintf (prog_num, "null");

     if (! strcmp (type, "C")) 
        sprintf (sql_str,
        "%s (%s%s%s) VALUES (%d, '%s', '%s', %s, '%s', '%s', %s, %s)",
        "INSERT INTO NFMVALUES",
        "n_attrno, n_type, n_defaultvalue, n_defaultno, ",
        "n_minvalue, n_maxvalue, ",
        "n_listno, n_programno",
        attr_no, "C", def_value, def_num, min, max,
        list_num, prog_num);
     else if (! strcmp (type, "A"))
        sprintf (sql_str,
        "%s (%s%s) VALUES (%d, '%s', '%s', '%s', %s, %s)",
        "INSERT INTO NFMVALUES",
        "n_attrno, n_type, n_minvalue, n_maxvalue, ",
        "n_listno, n_programno",
        attr_no, "A", min, max, list_num, prog_num);

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
	_NFMdelete_n_listno (list_no) ;
        if (status  == SQL_E_DUPLICATE_VALUE)
         {
           ERRload_struct (NFM, NFM_E_DUP_ATTR_VALUE, "", NULL);
           _NFMdebug ((fname, "Value Exists For Attr : status = <0x%.8x>\n",
           NFM_E_DUP_ATTR_VALUE));
           return (NFM_E_DUP_ATTR_VALUE);
         }

        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Synatx : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

long _NFMload_advice_info (advice_string, attr_no)
     char *advice_string ;
     long      attr_no;
{
  char *fname = "_NFMload_advice_info" ;
  long    status, user_id ;
  long    list_no ;
  char    sql_str [1024];
  long    _NFMdelete_n_listno () ;
  
  _NFMdebug ((fname, "Attr No = <%d> : advice string <%s>\n",
	      attr_no, advice_string)) ;
  
  user_id = NFMglobal.NFMuserid ;
  
  status = NFMget_serial_slot (user_id, "nfmlists",
			       "n_listno", &list_no) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get Serial No : status = <0x%.8x>\n",
		  status));
      return (status);
    }
  
  sprintf (sql_str,
	   "INSERT INTO NFMLISTS (n_listno, n_value) VALUES (%d, '%s')",
	   list_no, advice_string) ;
  
  status = SQLexec_imm (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      _NFMdelete_n_listno (list_no) ;
      if (status == SQL_E_DUPLICATE_VALUE)
	{
	  ERRload_struct (NFM, NFM_E_DUP_LIST_VALUE, "", NULL);
	  _NFMdebug ((fname, "Dup Lst Val : status = <0x%.8x>\n",
		      NFM_E_DUP_LIST_VALUE));
	  return (NFM_E_DUP_LIST_VALUE);
	}
      
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
		  status));
      return (NFM_E_SQL_STMT);            
    }
  /*** try to insert or update */
  
  sprintf (sql_str,
	   "INSERT INTO NFMVALUES (n_attrno, n_type, n_listno) values (%d, 'A', %d)",
	   attr_no, list_no) ;
  
  status = SQLexec_imm (sql_str);
  if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
    {
      _NFMdelete_n_listno (list_no) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname, "SQL Stmt Synatx : status = <0x%.8x>\n",
		  status));
      return (NFM_E_SQL_STMT);
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}


long _NFMdelete_values (attr_no)
     long attr_no ;
{
  char *fname = "_NFMdelete_values" ;
  char sql_str [512] ;
  long status, atol(), i ;
  char **data, *str = NULL ;
  MEMptr sql_buffer = NULL ;

  _NFMdebug ((fname, "attr no <%d>\n", attr_no));
  
  sprintf (sql_str, "select b.n_listno from nfmvalues a, nfmlists b where a.n_attrno = %d and a.n_listno = b.n_listno",
	   attr_no) ;

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", 
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  if (status != SQL_I_NO_ROWS_FOUND)
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
      str = (char *) malloc (sql_buffer->rows * 30 + 200) ;
      if (str == NULL)
	{
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Malloc failed\n")) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  return (NFM_E_MALLOC) ;
	}

      strcpy (str, "Delete from nfmlists where ") ;
      for (i=0; i<sql_buffer->rows; i++)
	{
	  if (i != 0) strcat (str, " OR ") ;
	  strcat (str, "n_listno = ") ;
	  strcat (str, data[i]) ;
	}
      
      status = SQLexec_imm (str) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  free (str) ;
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Sql exec imm failed : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	  return (NFM_E_SQL_STMT) ;
	}
      
      /******* The slot has to be free ************/
      for (i=0; i<sql_buffer->rows; i++)
	{
	  NFMreturn_serial_slot (NFMglobal.NFMuserid, "nfmlists",
				 "n_listno", atol (data [i])) ;
	}
    }

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose (sql_buffer) : failed = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  sprintf (sql_str, "Delete from nfmvalues where n_attrno = %d", attr_no) ;
  status = SQLexec_imm (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      free (str) ;
      _NFMdebug ((fname, "Sql exec imm failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  free (str) ;
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMdelete_n_listno (list_no) 
long list_no ;
{
  char *fname = "_NFMdelete_n_listno" ;
  char sql_str [512] ;
  long status, atol() ;

  _NFMdebug ((fname, "list no <%d>\n", list_no)) ;
  
  sprintf (sql_str,  "Delete from nfmlists where n_listno = %d",
	  list_no) ;

  status = SQLexec_imm (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql exec imm failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

/******* The slot has to be free ************/
  NFMreturn_serial_slot (NFMglobal.NFMuserid, "nfmlists",
			 "n_listno", list_no) ;

  _NFMdebug ((fname, "SUCCESSFULL\n")) ;
  return (NFM_S_SUCCESS) ;
}


 long NFMcreate_table (user_id, table_type, table_name, identifier, 
                       attr_list, data_list, value_list)
   long      user_id ;
   char      *table_type, *table_name, *identifier;
   MEMptr    attr_list, data_list, value_list;
   {
     static char *fname = "NFMcreate_table" ;
     long     status, table_no;
     long NFMload_attributes ();

     _NFMdebug ((fname, "Table Type  = <%s> : Table Name = <%s>\n", 
		 table_type, table_name, identifier));
     user_id = user_id ;
     status = _NFMcreate_attributes (table_name, attr_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Create Table Failed : status = <0x%.8x>\n",
        status));
        return (status);         
      }

     status = _NFMload_attributes (table_type, table_name, identifier,
				   &table_no,
				   attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
	NFMdelete_table (NFMglobal.NFMuserid, table_type, table_name) ;
        _NFMdebug ((fname, "Load Table Attr Failed : status = <0x%.8x>\n",
        status));
        return (status);         
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


long  _NFMcreate_application_table (catalog_name, identifier_list)
     char   *catalog_name ;
     MEMptr identifier_list ;
{
  char *fname = "_NFMcreate_application_table" ;
  long status, i, table_no, offset, comma, found, pattern_str_len ;
  long template_no, atol();
  char **data, *sql_str, tmp_str [100], *str ;
  MEMptr attr_list = NULL, data_list = NULL, value_list = NULL ;
  MEMptr sql_buffer = NULL ;
  char table_name [NFM_TABLENAME+1];
  long _NFMcreate_index () ;

  _NFMdebug ((fname, "catalog name : %s\n", catalog_name));

  status = MEMbuild_array (identifier_list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array (identifier_list) failed : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }

  data = (char **) identifier_list->data_ptr ;

  sql_str = (char *) malloc (identifier_list->rows*50) ;
  if (sql_str == NULL)
    {
      _NFMdebug ((fname, "Malloc failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  str = (char *) malloc (identifier_list->rows*50+100) ;
  if (str == NULL)
    {
      free (sql_str) ;
      _NFMdebug ((fname, "Malloc failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  comma = 0 ;
  sql_str [0] =0;
  for (i=0; i<identifier_list->rows; i++)
    {
      if (comma) strcat (sql_str, " OR ") ;
      else comma = 1 ;
      sprintf (tmp_str, "n_identifier = '%s'", data [i]);
      strcat (sql_str, tmp_str) ;
    }
  
  sprintf (str, "select n_tablename, n_identifier, n_tableno from nfmtables where (%s) and n_tabletype = 't_appltable'",
	   sql_str) ;

  free (sql_str) ;
  status = SQLquery (str, &sql_buffer, MEM_SIZE) ;
  free (str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", 
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  if (status != SQL_I_NO_ROWS_FOUND)
    {
      _NFMdebug ((fname, "application template for table exists\n")) ;
      status = MEMbuild_array (sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}

      data = (char **) sql_buffer -> data_ptr ;
      for (i=0; i<sql_buffer->rows; i++)
	{
	  offset = sql_buffer->columns*i;

	  template_no = atol (data [offset+2]) ;
	  status = NFMquery_template_attributes ("t_appltable",
						 data[offset],data[offset+1],
						 &attr_list, &data_list,
						 &value_list);
	  if (status != NFM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "query template definition failed : status = <0x%.8x>\n",
			  status)) ;
	      return (status) ;
	    }

/* substitute in the catalog name for the word template in the table_name */

	  pattern_str_len = strlen (data [offset]) ;
	  strcpy (table_name, data[offset]) ;
	  
	  found = 0 ;
	  for (i=0; 
	       i<pattern_str_len && (pattern_str_len-i)>= TEMPLATE_LEN ; i++)
	    {
	      if ((strcmp (&table_name[i], "template") == 0))
		{
		  found = 1;
		  break ;
		}
	    }
	  if (found) 
	    {
	      strcpy (&table_name[i], catalog_name) ;
	      str [NFM_TABLENAME] = 0 ;
	    } 
	  else 
	    {
	      _NFMdebug ((fname, "Bad application template name %s\n",
			  table_name)) ;
	      ERRload_struct (NFM, NFM_E_BAD_APPL_TEMPLATE, "", "") ;
	      return (NFM_E_BAD_APPL_TEMPLATE) ;
	    }
	  
	  _NFMdebug ((fname, "Creating application table %s\n",
		  table_name)) ;

	  status = _NFMcreate_table (catalog_name, table_name, 
				     data [offset+1], 
				     &table_no, attr_list, data_list,
				     value_list) ;
	  if (status != NFM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "create table %s id %s type %s failed : status = <0x%.8x>\n",
			  table_name, "application", data[offset+1], status)) ;
	      return (status) ;
	    }
	  
	  status = _NFMcreate_index (table_name, template_no) ;
	  if (status != NFM_S_SUCCESS)
	    {
	      _NFMdebug ((fname,"create index failed <0x%.8x>\n",
			  status)) ;
	      return (status) ;
	    }

	  status = MEMclose (&attr_list);
	  if (status != MEM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "MEMclose (attr_list) : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }
	  status = MEMclose (&data_list) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "MEMclose (data_list) : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }

	  status = MEMclose (&value_list) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "MEMclose (value_list) : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
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

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long  _NFMcreate_table_with_index (tabletype, tablename, identifier,
				   new_tablename)
     char *tabletype ;       /* n_tabletype from nfmtables */
     char *tablename ;       /* n_tablename from nfmtables */
     char *identifier ;      /* n_identifier from nfmtables */
     char *new_tablename ;   /* given name of table */
{
  char *fname = "_NFMcreate_table_with_index" ;
  long status, table_no ;
  long template_no, atol();
  MEMptr attr_list = NULL, data_list = NULL, value_list = NULL ;
  long _NFMcreate_index () ;

  _NFMdebug ((fname, "tabletype <%s> : tablename <%s> : identifier <%s> : new_tablename <%s>\n",
	      tabletype, tablename, identifier, new_tablename)) ;

  status = _NFMget_template_no (tabletype, tablename, identifier, 
				&template_no) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "get template no : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "application template for table exists\n")) ;
  
  status = NFMquery_template_attributes (tabletype, 
					 tablename, identifier,
					 &attr_list, &data_list,
					 &value_list);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "query template definition failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
	  
  _NFMdebug ((fname, "Creating application table %s\n",
	      new_tablename)) ;
  
  status = _NFMcreate_table ("table", new_tablename, 
			     "",
			     &table_no, attr_list, data_list,
			     value_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "create table %s id %s type %s failed : status = <0x%.8x>\n",
		  new_tablename, identifier, tabletype,  status)) ;
      return (status) ;
    }
  
  status = _NFMcreate_index (new_tablename, template_no) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"create index failed <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  status = MEMclose (&attr_list);
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose (attr_list) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  status = MEMclose (&data_list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose (data_list) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  status = MEMclose (&value_list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose (value_list) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMcreate_index (table_name, template_no) 
char *table_name ;
long template_no ;
{
  char *fname = "_NFMcreate_index" ;
  long i, rows , *num, len, y, offset, offset1, status, atol () ;
  char tmp_str [512], **data ;
  char *ptr, *ptr1, **type_index ;
  char index_name [20], *sql_str ;
  MEMptr buffer = NULL ;

  _NFMdebug ((fname, "table_name %s : template no %d\n",
	      table_name, template_no)) ;
  sprintf (tmp_str, "Select n_synonym, n_name from nfmattributes where n_tableno = %d and n_synonym like '*%%'",
	   template_no) ;
  status = SQLquery (tmp_str, &buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "No index in application table %s\n",
		      table_name)) ;
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
      _NFMdebug ((fname, "MEMbuild array (buffer) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  rows = buffer->rows ;
  data = (char **) buffer->data_ptr ;

  type_index = (char **) malloc (rows*sizeof(char *)) ;
  if (type_index == NULL)
    {
      _NFMdebug ((fname, "malloc failed\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  for (i=0; i<rows; i++)
    {
      type_index[i] = (char *) malloc (2) ;
      if (type_index[i] == NULL)
	{
	  free (type_index) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  _NFMdebug ((fname, "malloc failed\n")) ;
	  return (NFM_E_MALLOC) ;
	}
    }

   num = (long *) malloc (rows * sizeof (long)) ;
  if (num == NULL)
    {
      free_type_index (rows, type_index) ;
      _NFMdebug ((fname, "malloc failed\n")) ;
      return (NFM_E_MALLOC) ;
    }

  for (i=0; i<rows; i++)
    {
      offset = buffer->columns*i ;
      ptr = (char *) strchr (data[offset], '*') ;  /* must be at 0 */
      if (ptr == NULL)
	{
	  free_type_index (rows, type_index) ;
	  free (num) ;
	  _NFMdebug ((fname, "Failure : item %s : %s",
		      data [offset+1], data[offset])) ;
	  ERRload_struct (NFM, NFM_E_BAD_INDEX_APPL_TEMPLATE, "", "") ;
	  return (NFM_E_BAD_INDEX_APPL_TEMPLATE) ;
	}

      if (ptr != data [offset])
	{
	  free_type_index (rows,type_index) ;
	  free (num) ;
	  _NFMdebug ((fname, "Failure : * not in first position in %s\n",
		      data [offset])) ;
	  ERRload_struct (NFM, NFM_E_BAD_INDEX_APPL_TEMPLATE, "", "") ;
	  return (NFM_E_BAD_INDEX_APPL_TEMPLATE) ;
	}

      ++ptr ;
      ptr1 = (char *) strchr (ptr, '*') ;  
      if (ptr == NULL)
	{
	  free_type_index (rows, type_index) ;
	  free (num) ;
	  ERRload_struct (NFM, NFM_E_BAD_INDEX_APPL_TEMPLATE, "", "") ;
	  _NFMdebug ((fname, "Failure : could not found sec * on %s attribute %s\n",
		   data [offset], data [offset+1])) ;
	  return (NFM_E_BAD_INDEX_APPL_TEMPLATE) ;
	}

      len = ptr1 - ptr ;

/*      store first letter  */

      type_index [i][0] = ptr [0] ; 
      type_index [i][1] = 0 ; 

/*      get number after -> store ; 
      store row_number ;
*/
      strncpy (tmp_str, &data [offset][2], len) ;
      num [i] = (long)  atol (tmp_str) ;
    }

  sql_str = (char *) malloc (rows * 60 + 200) ;
  if (sql_str == NULL)
    {
      free_type_index (rows, type_index) ;
      free (num) ;
      _NFMdebug ((fname, "malloc failed sql_str\n"));
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  strcpy (index_name, table_name) ;
  index_name [10] = 0 ;

  for (i=0; i<rows; i++)
    {
      offset = buffer->columns*i ;
      if (type_index [i][0] == ' ') 
	{
	  break ;
	}
      else if (type_index [i][0]== 'U')
	{
	  sprintf (sql_str, "create unique index a_%s_%d on %s (%s ",
		   index_name, num [i], table_name,
		   data[offset+1]);
	}
      else if (type_index[i][0] == 'D')
	{
	  sprintf (sql_str, "create index a_%s_%d on %s (%s ",
		   index_name, num [i], table_name,
		   data[offset+1]);
	}
      else
	{
	  _NFMdebug ((fname, "Failure : wrong type %s\n", type_index [i][0])) ;
          free_type_index (rows, type_index) ;
	  free (num) ;
	  free (sql_str) ;
	  ERRload_struct (NFM, NFM_E_BAD_INDEX_APPL_TEMPLATE, "", "") ;
	  return (NFM_E_BAD_INDEX_APPL_TEMPLATE) ;
	}

      for (y=i+1; y<rows; y++)
	{
	  offset1 = buffer->columns*y ;
	  if ((type_index[i][0] == type_index [y][0])
	      && (num [i] == num [y]))
	    {
	      strcat (sql_str, ",")  ;
	      strcat (sql_str, data [offset1+1]) ;
	      type_index [y][0] = ' ' ;
	    }
	}
      strcat (sql_str,")") ;

      status = SQLexec_imm (sql_str) ;
      if (status != SQL_S_SUCCESS)
	{
	  _NFMdebug ((fname, "SQLexec_imm failed : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	  return (NFM_E_SQL_STMT) ;
	}
    }
  free_type_index (rows, type_index) ;
  free (num) ;
  free (sql_str) ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}


int  free_type_index (rows, index) 
long rows ;
char **index ;
{
  char *fname = "free_type_index" ;
  long i ;

  _NFMdebug ((fname, "ENTER\n")) ;
  
  for (i=0;i<rows; i++)
    free (index [i]) ;

  free (index) ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}




