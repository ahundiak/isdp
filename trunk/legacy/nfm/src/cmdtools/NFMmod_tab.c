#include "machine.h"
#include "CMDTOOLS.h"

  extern struct NFMglobal_st NFMglobal ;

 long NFMchange_table (user_id, table_type, table_name,
                       attr_list, data_list, value_list)
   long      user_id;
   char      *table_type, *table_name;
   MEMptr    attr_list, data_list, value_list;
   {
     static char *fname = "NFMchange_table" ;
     long     status, atol ();
     long     NFMchange_attributes ();
     long     NFMchange_actual_attributes ();
     long     NFMreset_change_attributes ();
     long     _NFMcheck_dup_name () ;

     _NFMdebug ((fname, "Table Type  = <%s> : Table Name = <%s>\n", 
		 table_type, table_name));
     user_id = user_id ;
     NFMchange_case (table_type, 1);

     status = _NFMcheck_dup_name (attr_list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "check dup : status = <0x%.8x>\n",
		   status));
	 return (status) ;
       }

     status = NFMchange_attributes (NFMglobal.NFMuserid, table_type, table_name,
              attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Load Table Attr Failed : status = <0x%.8x>\n",
        status));
        return (status);         
      }

     status = NFMchange_actual_attributes (NFMglobal.NFMuserid,
              table_name, attr_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMreset_change_attributes (NFMglobal.NFMuserid, table_type, table_name,
        attr_list, data_list, value_list);
        _NFMdebug ((fname, "Mod Actual Table Failed : status = <0x%.8x>\n",
        status));
        return (status);         
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMchange_actual_attributes (user_id, table_name, attr_list)
   long     user_id;
   char     *table_name;
   MEMptr   attr_list;
   {
     static char *fname = "NFMchange_actual_attributes" ;
     long     status;
     char     **column, **data;
     long     a1, b1, a2, b2;
     long     x, y, z, count;
     char     sql_str [2048];

     _NFMdebug ((fname, "Table Name = <%s>\n", table_name));
     user_id = user_id ;
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (status);
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a1 = -1;  b1 = -1;  a2 = -1;  b2 = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))          a1 = y;
        else if (! strcmp (column [y], "n_datatype"))      b1 = y;
        else if (! strcmp (column [y], "new_n_name"))      a2 = y;
        else if (! strcmp (column [y], "new_n_datatype"))  b2 = y;
      }

     z = 0;

     while (z < attr_list -> rows)
      {
        count = attr_list -> columns * z;

         if ((! strlen (data [count + a2])) &&
             (! strlen (data [count + b2]))) break;
         else z = z + 1;
      }

     _NFMdebug ((fname, "Original Rows = <%d> : Total Rows = <%d>\n", 
		 z, attr_list->rows));

     for (x = z; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        sprintf (sql_str, "ALTER TABLE %s ADD %s %s",
                 table_name, data [count + a1], data [count + b1]);

        status = SQLexec_imm (sql_str);
        if (status != SQL_S_SUCCESS)
         {
           ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
           _NFMdebug ((fname, "Alter Table (ADD) : status = <0x%.8x>\n",
		       status));
           return (NFM_E_SQL_STMT);        
         }
      }

     /* Change Data Type */
/*************   RIS DOES NOT SUPPORT 3/1/91 ***************/

/*   for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if (! strcmp (data [count + b1], data [count + b2]))
         {
           sprintf (sql_str, "ALTER TABLE %s MODIFY (%s %s)",
                    table_name, data [count + a1], count + b2]);
 
           status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Mod Data Type : status = <0x%.8x>\n",
	      status));
              return (NFM_E_SQL_STMT);        
            }        
         }
      }
*/
     /* Change Attr Name */
/*************   RIS DOES NOT SUPPORT 3/1/91 ***************/
/*   for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if (! strcmp (data [count + a1], data [count + a2]))
         {
           sprintf (sql_str, "RENAM COLUMN %s.%s %s",
                    table_name, data [count + a1], data [count + a2]);
 
           status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS)
            {
	       ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Mod Attr Name : status = <0x%.8x>\n",
	      status));
              return (NFM_E_SQL_STMT);        
            }        
         }
      }
*/
     /* Drop the Attributes */
/*************   RIS DOES NOT SUPPORT 3/1/91 ***************/
/*   for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if (! strcmp (data [count + a2], "delete"))
         {
           sprintf (sql_str, "ALTER TABLE %s DROP %s",
                    table_name, data [count + a1];
 
           status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS)
            {
	       ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Mod Attr Name : status = <0x%.8x>\n",
	      status));
              return (NFM_E_SQL_STMT);        
            }        
         }
      }
*/
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMchange_attributes (user_id, table_type, table_name,
                            attr_list, data_list, value_list)
   long      user_id;
   char      *table_type, *table_name;
   MEMptr    attr_list, data_list, value_list;
   {
     static char *fname = "NFMchange_attributes";
     long     status, atol ();
     char     **column, **data, **data1;
     long     x, y, z, count;
     char     sql_str [4092], sql_str1 [1024];
     char     sql_str2 [1024], value [50];
     long     table_no, attr_no;

     long     a1, b1, c1, d1, e1, f1, g1, h1;
     long     i1, j1, k1, l1, m1, n1, o1, p1, q1 ;
     long     a2, b2, c2, d2, e2, f2, g2, h2;
     long     i2, j2, k2, l2, m2, n2, o2, p2, q2;
     long     _NFMchange_value_info ();

     _NFMdebug ((fname, "Table Type  = <%s> : Table Name = <%s>\n", 
		 table_type, table_name));
     user_id = user_id ;
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a1 = -1; b1 = -1; c1 = -1; d1 = -1; e1 = -1; f1 = -1; g1 = -1;
     h1 = -1; i1 = -1; j1 = -1; k1 = -1; l1 = -1; m1 = -1; n1 = -1;
     o1 = -1; p1 = -1; q1 = -1 ;

     a2 = -1; b2 = -1; c2 = -1; d2 = -1; e2 = -1; f2 = -1; g2 = -1;
     h2 = -1; i2 = -1; j2 = -1; k2 = -1; l2 = -1; m2 = -1; n2 = -1;
     o2 = -1; p2 = -1; q2 = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))            a1 = y;
        else if (! strcmp (column [y], "n_datatype"))        b1 = y;
        else if (! strcmp (column [y], "n_synonym"))         c1 = y;
        else if (! strcmp (column [y], "n_read"))            f1 = y;
        else if (! strcmp (column [y], "n_write"))           g1 = y;
        else if (! strcmp (column [y], "n_update"))          h1 = y;
        else if (! strcmp (column [y], "n_delete"))          i1 = y;
        else if (! strcmp (column [y], "n_null"))            j1 = y;
/*        else if (! strcmp (column [y], "n_adviceno"))        k1 = y; */
        else if (! strcmp (column [y], "n_checkin"))         l1 = y;
        else if (! strcmp (column [y], "n_checkout"))        m1 = y;
        else if (! strcmp (column [y], "n_application"))     n1 = y;
        else if (! strcmp (column [y], "n_valueno"))         o1 = y;
        else if (! strcmp (column [y], "n_seqno"))           p1 = y;
        else if (! strcmp (column [y], "n_advice"))          q1 = y;
	     
        else if (! strcmp (column [y], "new_n_name"))        a2 = y;
        else if (! strcmp (column [y], "new_n_datatype"))    b2 = y;
        else if (! strcmp (column [y], "new_n_synonym"))     c2 = y;
        else if (! strcmp (column [y], "new_n_read"))        f2 = y;
        else if (! strcmp (column [y], "new_n_write"))       g2 = y;
        else if (! strcmp (column [y], "new_n_update"))      h2 = y;
        else if (! strcmp (column [y], "new_n_delete"))      i2 = y;
        else if (! strcmp (column [y], "new_n_null"))        j2 = y;
/*        else if (! strcmp (column [y], "new_n_adviceno"))    k2 = y; */
        else if (! strcmp (column [y], "new_n_checkin"))     l2 = y;
        else if (! strcmp (column [y], "new_n_checkout"))    m2 = y;
        else if (! strcmp (column [y], "new_n_application")) n2 = y;
        else if (! strcmp (column [y], "new_n_valueno"))     o2 = y;       
        else if (! strcmp (column [y], "new_n_seqno"))       p2 = y;
        else if (! strcmp (column [y], "new_n_advice"))      q2 = y;
      }

     z = 0 ;
     while (z < attr_list -> rows)
      {
        count = attr_list -> columns * z;

        if ((! strlen (data [count + a2])) &&
            (! strlen (data [count + b2])) &&
            (! strlen (data [count + c2])) &&
            (! strlen (data [count + f2])) &&
            (! strlen (data [count + g2])) &&
            (! strlen (data [count + h2])) &&
            (! strlen (data [count + i2])) &&
            (! strlen (data [count + j2])) &&
/*            (! strlen (data [count + k2])) && */
            (! strlen (data [count + l2])) &&
            (! strlen (data [count + m2])) &&
            (! strlen (data [count + n2])) &&
            (! strlen (data [count + o2])) &&
            (! strlen (data [count + p2])) &&
            (! strlen (data [count + q2]))) break ;
        else 
	    z = z + 1;
      }
/* z points to the first new attribute */
    
     _NFMdebug ((fname, "Original Rows = <%d> : Total Rows = <%d>\n", 
		 z, attr_list->rows));

     status = NFMget_table_no (NFMglobal.NFMuserid, table_type, table_name,
              &table_no);
     if (status != NFM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_BAD_TABLE, "", NULL) ;
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n", status));
        return (status);
      }

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        NFMchange_case (data [count + a1], 1);
        NFMchange_case (data [count + a2], 1);
      }

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "Change Add Attr\n"));

     sprintf (sql_str1, "INSERT INTO %s (%s%s%s%s%s) VALUES (%d, ",
              "NFMATTRIBUTES",
              "n_tableno, n_attrno, ",
	      "n_name, n_datatype, n_synonym, ",
              "n_read, n_write, n_update, n_delete, n_null, ",
	      "n_checkin, n_checkout, n_application, ",
              "n_lattrno, n_seqno", table_no);

     for (x = z; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        status = NFMget_serial_slot (NFMglobal.NFMuserid, "nfmattributes",
                 "n_attrno", &attr_no);
        if (status != NFM_S_SUCCESS)
         {
           NFMrollback_transaction (0);
           _NFMdebug ((fname, "Get Serial No : status = <0x%.8x>\n",
           status));
           return (status);
         }

        if (atol (data [count + o1]) > 0)
         {
           status = MEMreset_buffer_no (value_list,
                    atol (data [count + o1]));
           if (status != MEM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);
            }
           status = _NFMchange_value_info ("C",attr_no, data1 [x],
                    value_list);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Load Value List : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }
        else if (strlen (data1 [x]))
         {
           status = _NFMchange_value_info ("C", attr_no, data1 [x], NULL);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Load Value List : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }
/*
	if (strcmp (data [count + q1], data [count + q2]))
*/
	if (strlen (data [count + q1]))
	  {
	    status = _NFMchange_advice_info (data [count+q1], attr_no) ;
	    if (status != NFM_S_SUCCESS)
	      {
		NFMrollback_transaction (0);
		_NFMdebug ((fname, "Change Advice Info : status = <0x%.8x>\n",
			    status));
		return (status);
	      }
	  }
/*****************
        if (atol (data [count + k1]) > 0)
         {
           status = MEMreset_buffer_no (value_list,
                    atol (data [count + k1]));
           if (status != MEM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Reset No : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);
            }

           status = _NFMchange_value_info ("A", attr_no, "", value_list);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Load Keyin List : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }
****************************************/

        NFMchange_case (data [count + f1], 0);
        NFMchange_case (data [count + g1], 0);
        NFMchange_case (data [count + h1], 0);
        NFMchange_case (data [count + i1], 0);
        NFMchange_case (data [count + j1], 0);
        NFMchange_case (data [count + l1], 0);
        NFMchange_case (data [count + m1], 0);
        NFMchange_case (data [count + n1], 0);

       sprintf (sql_str2,
       "%d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', ",
       attr_no, data [count + a1], data [count + b1], data [count + c1],
       data [count + f1],
       data [count + g1], data [count + h1], data [count + i1],
       data [count + j1]);

        sprintf (sql_str, "%s%s '%s', '%s', '%s', %s, ",
        sql_str1, sql_str2,
        data [count + l1], data [count + m1],
        data [count + n1], "null");

        if (strlen (data [count + p1]))
          strcat (sql_str, data [count + p1]);
        else
          strcat (sql_str, "null");

        strcat (sql_str, ")");

        status = SQLexec_imm (sql_str);
        if (status != SQL_S_SUCCESS)
         {
           NFMrollback_transaction (0);

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

/************ Change To New Data Type   - RIS Does not support  ********

     _NFMdebug ((fname, "Change Data Type\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + b1], data [count + b2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_datatype", data [count + b2], 
           "n_tableno", table_no, "n_name", data [count + a1]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }
****************************************************************/

     /*   Change To New Synonym     */

     _NFMdebug ((fname, "Change Synonym \n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + c1], data [count + c2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_synonym", data [count + c2], 
           "n_tableno", table_no, "n_name", data [count + a1]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Read   */

     _NFMdebug ((fname, "Change Read\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        NFMchange_case (data [count + f2], 0);

        if ((strcmp (data [count + f1], data [count + f2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_read", data [count + f2], 
           "n_tableno", table_no, "n_name", data [count + a1]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Write   */

     _NFMdebug ((fname, "Change Write\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        NFMchange_case (data [count + g2], 0);

        if ((strcmp (data [count + g1], data [count + g2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_write", data [count + g2], 
           "n_tableno", table_no, "n_name", data [count + a1]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Update   */

     _NFMdebug ((fname, "Change Update\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        NFMchange_case (data [count + h2], 0);

        if ((strcmp (data [count + h1], data [count + h2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_update", data [count + h2], 
           "n_tableno", table_no, "n_name", data [count + a1]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Delete   */

     _NFMdebug ((fname, "Change Delete\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        NFMchange_case (data [count + i2], 0);

        if ((strcmp (data [count + i1], data [count + i2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           if (! strcmp (data [count + n1], "NFM"))
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_DEL_SYS_ATTR, "", NULL);
              _NFMdebug ((fname, "Del For Sys Attr : status = <0x%.8x>\n",
              NFM_E_DEL_SYS_ATTR));
              return (NFM_E_DEL_SYS_ATTR);
            }

           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_delete", data [count + i2], 
           "n_tableno", table_no, "n_name", data [count + a1]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Null   */

     _NFMdebug ((fname, "Change Null\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        NFMchange_case (data [count + j2], 0);

        if ((strcmp (data [count + j1], data [count + j2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_null", data [count + j2], 
           "n_tableno", table_no, "n_name", data [count + a1]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Keyin   */

     _NFMdebug ((fname, "Change Key In\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;
/*         
        if ((strcmp (data [count + k1], data [count + k2])) &&
            (strcmp (data [count + a2], "delete"))) 
*/
        if ((strcmp (data [count + q1], data [count + q2])) &&
            (strcmp (data [count + a2], "delete"))) 
         {
           status = NFMget_attr_no (NFMglobal.NFMuserid, table_type, table_name,
                    data [count + a1], &attr_no);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Get Attr No : status = <0x%.8x>\n",
              status));
              return (status);
            }

	   status = _NFMchange_advice_info (data [count+q2], attr_no) ;
	   if (status != NFM_S_SUCCESS)
	     {
	       NFMrollback_transaction (0);
	       _NFMdebug ((fname, "Unl Old Advice : status = <0x%.8x>\n",
			 status));
	       return (status);
	     }
/**********
	   status = NFMunload_value_info (NFMglobal.NFMuserid, "A", attr_no);
	   if (status != NFM_S_SUCCESS)
	     {
	       NFMrollback_transaction (0);
	       _NFMdebug ((fname, "Unl Old Advice : status = <0x%.8x>\n",
			 status));
	       return (status);
	     }

           if (atol (data [count + k2]) > 0)
            {
              status = MEMreset_buffer_no (value_list,
                       atol (data [count + k2]));
              if (status != MEM_S_SUCCESS)
               {
                 NFMrollback_transaction (0);
		 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                 _NFMdebug ((fname, "MEM Reset No : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_MEM);
               }

              status = _NFMchange_value_info ("A", attr_no, "", value_list);
              if (status != NFM_S_SUCCESS)
               {
                 NFMrollback_transaction (0);
                 _NFMdebug ((fname, "Load Keyin List : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
            }
*********************/
         }        
      }

     /*   Change To New Checkin   */

     _NFMdebug ((fname, "Change Check In\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        NFMchange_case (data [count + l2], 0);

        if ((strcmp (data [count + l1], data [count + l2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_checkin", data [count + l2], 
           "n_tableno", table_no, "n_name", data [count + a1]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Checkout   */

     _NFMdebug ((fname, "Change Check Out\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        NFMchange_case (data [count + m2], 0);

        if ((strcmp (data [count + m1], data [count + m2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_checkout", data [count + m2], 
           "n_tableno", table_no, "n_name", data [count + a1]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Application   */

     _NFMdebug ((fname, "Change Application\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + n1], data [count + n2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           if (! strcmp (data [count + n1], "NFM"))
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_CHANGE_NFM_APP, "", NULL);
              _NFMdebug ((fname, "Changing NFM App : status = <0x%.8x>\n",
              NFM_E_CHANGE_NFM_APP));
              return (NFM_E_CHANGE_NFM_APP);
            }

           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_application", data [count + n2], 
           "n_tableno", table_no, "n_name", data [count + a1]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Seq No   */

     _NFMdebug ((fname, "Change Sequence No\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + p1], data [count + p2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           if (strlen (data [count + p2]))
             sprintf (sql_str,
             "%s %s SET %s = %s WHERE %s = %d AND %s = '%s'",
             "UPDATE", "NFMATTRIBUTES", "n_seqno", data [count + p2], 
             "n_tableno", table_no, "n_name", data [count + a1]);
           else
             sprintf (sql_str,
             "%s %s SET %s = %s WHERE %s = %d AND %s = '%s'",
             "UPDATE", "NFMATTRIBUTES", "n_seqno", "null", 
             "n_tableno", table_no, "n_name", data [count + a1]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*    Change For New Value List */

     _NFMdebug ((fname, "Change Value List\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        attr_no = atol (value);

        if (((strcmp (data [count + o1], data [count + o2]))         ||
             (strcmp (data1 [x], data1 [data_list -> columns + x]))) &&
            (strcmp (data [count + a2], "delete")))
         {
           status = NFMget_attr_no (NFMglobal.NFMuserid, table_type, table_name,
                    data [count + a1], &attr_no);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Get Attr No : status = <0x%.8x>\n",
              status));
              return (status);
            }

           status = NFMunload_value_info (NFMglobal.NFMuserid, "C", attr_no);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Unload Old Check : status = <0x%.8x>\n",
              status));
              return (status);
            }
 
           if (atol (data [count + o2]) > 0)
            {
              status = MEMreset_buffer_no (value_list, 
                       atol (data [count + o2]));
              if (status != MEM_S_SUCCESS)
               {
                 NFMrollback_transaction (0);
		 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                 _NFMdebug ((fname, "MEM Reset No : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_MEM);
               }
 
              status = _NFMchange_value_info ("C", attr_no, data1 [x], value_list);
              if (status != NFM_S_SUCCESS)
               {
                 NFMrollback_transaction (0);
                 _NFMdebug ((fname, "Load Value List : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
            }
           else if (strlen (data1 [x]))
            {
              status = _NFMchange_value_info ("C", attr_no, data1 [x], NULL);
              if (status != NFM_S_SUCCESS)
               {
                 NFMrollback_transaction (0);
                 _NFMdebug ((fname, "Load Value List : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
            }
         }   
      }

     /* Change The Attr Name  */

     _NFMdebug ((fname, "Change Attribute Name\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + a1], data [count + a2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = %s WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_name", data [count + a2], 
           "n_tableno", table_no, "n_name", data [count + a1]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /* Drop The Attr Name  */

     _NFMdebug ((fname, "Drop Attributes\n")) ;

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if (! strcmp (data [count + a2], "delete"))
         {
           if (! strcmp (data [count + n1], "NFM"))
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_DEL_SYS_ATTR, "", NULL);
              _NFMdebug ((fname, "Not Del Sys Attr : status = <0x%.8x>\n",
              NFM_E_DEL_SYS_ATTR));
              return (NFM_E_DEL_SYS_ATTR);              
            }

           status = NFMget_table_name (NFMglobal.NFMuserid, 
				       table_type, table_name,
				       &attr_no);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
              status));
              return (status);
            }

           status = NFMunload_value_info (NFMglobal.NFMuserid, "A", attr_no);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Unload Value List : status = <0x%.8x>\n",
              status));
              return (status);              
            }

           status = NFMunload_value_info (NFMglobal.NFMuserid, "C", attr_no);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Unload Value List : status = <0x%.8x>\n",
              status));
              return (status);              
            }
      
           sql_str [0] = 0;

           sprintf (sql_str, "DELETE FROM %s WHERE %s = %d AND %s = %d",
                    "NFMATTRIBUTES", "n_tableno", table_no,
                    "n_attrno", attr_no);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }

           status = NFMreturn_serial_slot (NFMglobal.NFMuserid, "nfmattributes",
                    "n_attrno", attr_no);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Ret Empty Slot : status = <0x%.8x>\n",
              status));
              return (status);              
            }
         }        
      }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMreset_change_table (user_id, table_type, table_name,
                             attr_list, data_list, value_list)
   {
     static char *fname = "NFMreset_change_table" ;
     long    status;
     long    NFMreset_change_attributes ();
     long    NFMreset_actual_attributes ();

     _NFMdebug ((fname, "Table Type = <%s> : Table Name = <%s>\n", 
		 table_type, table_name));
     user_id = user_id ;
     status = NFMreset_change_attributes (NFMglobal.NFMuserid,
              table_type, table_name, attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Reset Tab Attr : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMreset_actual_attributes (NFMglobal.NFMuserid, table_name, attr_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Reset Act Tab : status = <0x%.8x>\n", status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMreset_actual_attributes (user_id, table_name, attr_list)
   long     user_id;
   char     *table_name;
   MEMptr   attr_list;
   {
     static char *fname = "NFMreset_actual_attributes" ;
     long     status;
     char     **column, **data;
     long     a1, b1, a2, b2;
     long     y, z, count;

     _NFMdebug ((fname, "Table Name = <%s>\n", table_name));
     user_id = user_id ;
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a1 = -1;  b1 = -1;  a2 = -1;  b2 = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))          a1 = y;
        else if (! strcmp (column [y], "n_datatype"))      b1 = y;
        else if (! strcmp (column [y], "new_n_name"))      a2 = y;
        else if (! strcmp (column [y], "new_n_datatype"))  b2 = y;
      }

     if (a1 < 0 || b1 < 0 || a2 < 0 || b2 < 0)
      {
	ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
        _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n",
        NFM_E_CORRUPTED_BUFFERS));
        return (NFM_E_CORRUPTED_BUFFERS);
      }

     z = 0;

     while (z < attr_list -> rows)
      {
        count = attr_list -> columns * z;

        if ((! strlen (data [count + a2])) &&
            (! strlen (data [count + b2])))   break;
        else z = z + 1;
      }

     _NFMdebug ((fname, "Original Rows = <%d> : Totat Rows = <%d>\n",
                z, attr_list->rows));
/*************   RIS DOES NOT SUPPORT 3/1/91 ***************/
/*   for (x = z; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        sprintf (sql_str, "ALTER TABLE %s DROP (%s)",
                 table_name, data [count + a1]);

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
         {
           ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
           _NFMdebug ((fname, "Alt Table (ADD) : status = <0x%.8x>\n",
	   status));
           return (NFM_E_SQL_STMT);        
         }
      }
*/
     /* Change Data Type */
/*************  RIS DOES NOT SUPPORT 3/3/91 **************/     
/*   for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if (! strcmp (data [count + b1], data [count + b2]))
         {
           sprintf (sql_str, "ALTER TABLE %s MODIFY (%s %s)",
                    table_name, data [count + a2], count + b1]);
 
           status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS)
            {
              ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Mod Attr Name : status = <0x%.8x>\n",
	      status));
              return (NFM_E_SQL_STMT);        
            }        
         }
      }
*/
     /* Change Attr Name */
/*************  RIS DOES NOT SUPPORT 3/3/91 **************/     
/*   for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if (! strcmp (data [count + a1], data [count + a2]))
         {
           sprintf (sql_str, "RENAME COLUMN %s.%s TO %s",
                    table_name, data [count + a2], data [count + a1]);
 
           status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Mod Attr Name : status = <0x%.8x>\n",
	      status));
              return (NFM_E_SQL_STMT);        
            }        
         }
      }
*/
     /* Drop the Attributes */
/*************  RIS DOES NOT SUPPORT 3/3/91 **************/     
/*   for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if (! strcmp (data [count + a2], "delete"))
         {
           sprintf (sql_str, "ALTER TABLE %s DROP %s %s",
                    table_name, data [count + a1], data [count + b1];
 
           status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS)
            {
              ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Mod Attr Name : status = <0x%.8x>\n",
	      status));
              return (NFM_E_SQL_STMT);        
            }        
         }
      }
*/
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMreset_change_attributes (user_id, table_type, table_name,
                                  attr_list, data_list, value_list)
   long      user_id;
   char      *table_type, *table_name;
   MEMptr    attr_list, data_list, value_list;
   {
     char *fname = "NFMreset_change_attributes" ;
     long     status, atol ();
     char     **column, **data, **data1;
     long     x, y, z, count;
     char     sql_str [4092], sql_str1 [1024];
     char     sql_str2 [1024] ;
     long     table_no, attr_no;

     long     a1, b1, c1, d1, e1, f1, g1, h1;
     long     i1, j1, k1, l1, m1, n1, o1, p1, q1;
     long     a2, b2, c2, d2, e2, f2, g2, h2;
     long     i2, j2, k2, l2, m2, n2, o2, p2, q2;
     long     _NFMchange_value_info ();

     _NFMdebug ((fname, "Table Type = <%s> : Table Name = <%s>\n", 
		 table_type, table_name));
     user_id = user_id ;
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a1 = -1; b1 = -1; c1 = -1; d1 = -1; e1 = -1; f1 = -1; g1 = -1;
     h1 = -1; i1 = -1; j1 = -1; k1 = -1; l1 = -1; m1 = -1; n1 = -1;
     o1 = -1; p1 = -1; q1 = -1;

     a2 = -1; b2 = -1; c2 = -1; d2 = -1; e2 = -1; f2 = -1; g2 = -1;
     h2 = -1; i2 = -1; j2 = -1; k2 = -1; l2 = -1; m2 = -1; n2 = -1;
     o2 = -1; p2 = -1; q2 = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))            a1 = y;
        else if (! strcmp (column [y], "n_datatype"))        b1 = y;
        else if (! strcmp (column [y], "n_synonym"))         c1 = y;
        else if (! strcmp (column [y], "n_nfmname"))         d1 = y;
        else if (! strcmp (column [y], "n_opentonfm"))       e1 = y;
        else if (! strcmp (column [y], "n_read"))            f1 = y;
        else if (! strcmp (column [y], "n_write"))           g1 = y;
        else if (! strcmp (column [y], "n_update"))          h1 = y;
        else if (! strcmp (column [y], "n_delete"))          i1 = y;
        else if (! strcmp (column [y], "n_null"))            j1 = y;
/*        else if (! strcmp (column [y], "n_adviceno"))        k1 = y; */
        else if (! strcmp (column [y], "n_checkin"))         l1 = y;
        else if (! strcmp (column [y], "n_checkout"))        m1 = y;
        else if (! strcmp (column [y], "n_application"))     n1 = y;
        else if (! strcmp (column [y], "n_valueno"))         o1 = y;
        else if (! strcmp (column [y], "n_seqno"))           p1 = y;
        else if (! strcmp (column [y], "n_advice"))          q1 = y;
	     

        else if (! strcmp (column [y], "new_n_name"))        a2 = y;
        else if (! strcmp (column [y], "new_n_datatype"))    b2 = y;
        else if (! strcmp (column [y], "new_n_synonym"))     c2 = y;
        else if (! strcmp (column [y], "new_n_opentonfm"))   e2 = y;
        else if (! strcmp (column [y], "new_n_read"))        f2 = y;
        else if (! strcmp (column [y], "new_n_write"))       g2 = y;
        else if (! strcmp (column [y], "new_n_update"))      h2 = y;
        else if (! strcmp (column [y], "new_n_delete"))      i2 = y;
        else if (! strcmp (column [y], "new_n_null"))        j2 = y;
/*        else if (! strcmp (column [y], "new_n_adviceno"))    k2 = y; */
        else if (! strcmp (column [y], "new_n_checkin"))     l2 = y;
        else if (! strcmp (column [y], "new_n_checkout"))    m2 = y;
        else if (! strcmp (column [y], "new_n_application")) n2 = y;
        else if (! strcmp (column [y], "new_n_valueno"))      o2 = y;       
        else if (! strcmp (column [y], "new_n_seqno"))       p2 = y;
        else if (! strcmp (column [y], "new_n_advice"))      q2 = y;
      }

     z = 0;

     while (z < attr_list -> rows)
      {
        count = attr_list -> columns * z;

        if ((! strlen (data [count + a2])) &&
            (! strlen (data [count + b2])) &&
            (! strlen (data [count + c2])) &&
            (! strlen (data [count + e2])) &&
            (! strlen (data [count + f2])) &&
            (! strlen (data [count + g2])) &&
            (! strlen (data [count + h2])) &&
            (! strlen (data [count + i2])) &&
            (! strlen (data [count + j2])) &&
            (! strlen (data [count + k2])) &&
            (! strlen (data [count + l2])) &&
            (! strlen (data [count + m2])) &&
            (! strlen (data [count + n2])) &&
            (! strlen (data [count + o2])) &&
            (! strlen (data [count + p2])) &&
            (! strlen (data [count + q2]))) break ;
         else z = z + 1;
      }

     _NFMdebug ((fname, "Original Rows = <%d> : Total Rows = <%d>\n",
		 z, attr_list->rows));

     status = NFMget_table_no (NFMglobal.NFMuserid, table_type, table_name, 
              &table_no);
     if (status != NFM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_BAD_TABLE, "", NULL) ;
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
        status));
        return (status);
      }

     for (x = z; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        sql_str [0] = 0;

        status = NFMget_attr_no (NFMglobal.NFMuserid, table_type, table_name,
                 data [count + a1], &attr_no);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Get Attr No : status = <0x%.8x>\n",
           status));
           return (status);              
         }

        status = NFMunload_value_info (NFMglobal.NFMuserid, "A", attr_no);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Unl Value List : status = <0x%.8x>\n",
           status));
           return (status);              
         }

        status = NFMunload_value_info (NFMglobal.NFMuserid, "C", attr_no);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Unl Value List : status = <0x%.8x>\n",
           status));
           return (status);              
         }
      
        sql_str [0] = 0;

        sprintf (sql_str, "DELETE FROM %s WHERE %s = %d",
                 "NFMATTRIBUTES", "n_attrno", attr_no);

        status = SQLexec_imm (sql_str); 
        if (status != SQL_S_SUCCESS)
         {
	   ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
           _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		       status));
           return (NFM_E_SQL_STMT);              
         }

        status = NFMreturn_serial_slot (NFMglobal.NFMuserid, "nfmattributes",
                 "n_attrno", attr_no);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Ret Empty Slot : status = <0x%.8x>\n",
           status));
           return (status);              
         }
      }        

     /*   Change To New Data Type  Back   */

     _NFMdebug ((fname, "Change Data Type\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + b1], data [count + b2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_datatype", data [count + b1], 
           "n_tableno", table_no, "n_name", data [count + a2]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Syn : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Synonym     */

     _NFMdebug ((fname, "Change Synonym\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + c1], data [count + c2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_synonym", data [count + c1], 
           "n_tableno", table_no, "n_name", data [count + a2]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Read   */

     _NFMdebug ((fname, "Change Read\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + f1], data [count + f2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_read", data [count + f1], 
           "n_tableno", table_no, "n_name", data [count + a2]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Write   */

     _NFMdebug ((fname, "Change Write\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + g1], data [count + g2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_write", data [count + g1], 
           "n_tableno", table_no, "n_name", data [count + a2]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
           status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Update   */

     _NFMdebug ((fname, "Change Update\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + h1], data [count + h2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_update", data [count + h1], 
           "n_tableno", table_no, "n_name", data [count + a2]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Delete   */

     _NFMdebug ((fname, "Change Delete\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + i1], data [count + i2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           if (! strcmp (data [count + n1], "NFM"))
            {
	      ERRload_struct (NFM, NFM_E_DEL_SYS_ATTR, "", NULL);
              _NFMdebug ((fname, "Del Sys Attr : status = <0x%.8x>\n",
              NFM_E_DEL_SYS_ATTR));
              return (NFM_E_DEL_SYS_ATTR);
            }

           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_delete", data [count + i1], 
           "n_tableno", table_no, "n_name", data [count + a2]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Null   */

     _NFMdebug ((fname, "Change Null\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + j1], data [count + j2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_null", data [count + j1], 
           "n_tableno", table_no, "n_name", data [count + a2]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Keyin   */

     _NFMdebug ((fname, "Change Key In\n"));
/********   FORMS INTERFACE UNABLED TO PROVIDE OLD VALUE LIST ******/
/*
     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;
         
        if ((strcmp (data [count + k1], data [count + k2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           status = NFMget_attr_no (NFMglobal.NFMuserid, table_type, table_name,
                    data [count + a2], &attr_no);
           if (status != NFM_S_SUCCESS)
            {
              _NFMdebug ((fname, "Get Attr No : status = <0x%.8x>\n",
              status));
              return (status);
            }

           if (atol (data [count + k2]) > 0)
            {
              status = NFMunload_value_info (NFMglobal.NFMuserid, "A", attr_no);
              if (status != NFM_S_SUCCESS)
               {
                 _NFMdebug ((fname, "Unl Keyin : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
            }
 
           if (atol (data [count + k1]) > 0)
            {
              status = MEMreset_buffer_no (value_list,
                       atol (data [count + k1]));
              if (status != MEM_S_SUCCESS)
	      {
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	      _NFMdebug ((fname, "Reset No : status = <0x%.8x>\n",
	      status));
	      return (NFM_E_MEM);
	      }

              status = _NFMchange_value_info ("A", attr_no, "", value_list);
              if (status != NFM_S_SUCCESS)
               {
                 _NFMdebug ((fname, "Key List : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
            }
         }        
      }
*/
/*********** FORMS INTERFACE UNABLED TO PROVIDE OLD VALUE LIST 3/8/91 *******/
     /*   Change To New Checkin   */

     _NFMdebug ((fname, "Change Check In\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + l1], data [count + l2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_checkin", data [count + l1], 
           "n_tableno", table_no, "n_name", data [count + a2]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Checkout   */

     _NFMdebug ((fname, "Change Check Out\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + m1], data [count + m2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_checkout", data [count + m1], 
           "n_tableno", table_no, "n_name", data [count + a2]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Application   */

     _NFMdebug ((fname, "Change Application\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + n1], data [count + n2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           if (! strcmp (data [count + n1], "NFM"))
            {
	      ERRload_struct (NFM, NFM_E_CHANGE_NFM_APP, "", NULL);
              _NFMdebug ((fname, "Chg NFM App : status = <0x%.8x>\n",
              NFM_E_CHANGE_NFM_APP));
              return (NFM_E_CHANGE_NFM_APP);
            }

           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = '%s' WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_application", data [count + n1], 
           "n_tableno", table_no, "n_name", data [count + a2]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*   Change To New Seq No   */

     _NFMdebug ((fname, "Change Sequence No\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + p1], data [count + p2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = %s WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_seqno", data [count + p1], 
           "n_tableno", table_no, "n_name", data [count + a2]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			  status));
	      return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /*    Change For New Value List */

     _NFMdebug ((fname, "Change Value List\n"));

/*
     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        attr_no = atol (value);

        if (((strcmp (data [count + o1], data [count + o2]))         ||
             (strcmp (data1 [x], data1 [data_list -> columns + x]))) &&
            (strcmp (data [count + a2], "delete")))
         {
           status = NFMget_attr_no (NFMglobal.NFMuserid, table_name, table_type,
                    data [count + a2], &attr_no);
           if (status != NFM_S_SUCCESS)
            {
              _NFMdebug ((fname, "Get Attr No : status = <0x%.8x>\n",
              status));
              return (status);
            }

           status = NFMunload_value_info (NFMglobal.NFMuserid, "C", attr_no);
           if (status != NFM_S_SUCCESS)
            {
              _NFMdebug ((fname, "Unload Old Chk : status = <0x%.8x>\n",
              status));
              return (status);
            }
 
           if (atol (data [count + o1]) > 0)
            {
              status = MEMreset_buffer_no (value_list,
                       atol (data [count + o1]));
              if (status != MEM_S_SUCCESS)
               {
                 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                 _NFMdebug ((fname, "Reset No : status = <0x%.8x>\n",
		 status));
                 return (NFM_E_MEM);
               }
 
              status = _NFMchange_value_info ("C", attr_no, 
	      data1 [data_list -> columns + x], value_list);
              if (status != NFM_S_SUCCESS)
               {
                 _NFMdebug ((fname, "Ld ValLst : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
            }
           else if (strlen (data1 [data_list -> columns + x]))
            {
              status = _NFMchange_value_info ("C",
                       attr_no, data1 [data_list -> columns + x], NULL);
              if (status != NFM_S_SUCCESS)
               {
                 _NFMdebug ((fname, "Ld ValLst : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
            }
         }   
      }
*/
/******* FORMS INTERFACE UNABLED TO PROVIDE OLD VALUES LIST 3/8/91 ***/

     /* Change The Attr Name  */

     _NFMdebug ((fname, "Change Attribute Name\n"));

     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if ((strcmp (data [count + a1], data [count + a2])) &&
            (strcmp (data [count + a2], "delete")))
         {
           sql_str [0] = 0;

           sprintf (sql_str,
           "%s %s SET %s = %s WHERE %s = %d AND %s = '%s'",
           "UPDATE", "NFMATTRIBUTES", "n_name", data [count + a1], 
           "n_tableno", table_no, "n_name", data [count + a2]);

           status = SQLexec_imm (sql_str); 
           if (status != SQL_S_SUCCESS)
            {
              ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);              
            }
         }        
      }

     /* Add The Dropped Attr  */

     _NFMdebug ((fname, "Drop Attributes : %s\n"));

     sprintf (sql_str1,
              "INSERT INTO NFMATTRIBUTES (%s%s%s%s%s) VALUES (%d, ",
              "n_tableno, n_attrno, n_name, n_datatype, n_synonym, ",
              "n_nfmname, n_opentonfm, ",
              "n_read, n_write, n_update, n_delete, n_null, ",
              "n_keyin, n_checkin, n_checkout, n_application, ",
              "n_type, n_lattrno, n_seqno", table_no);


     for (x = 0; x < z; ++x)
      {
        count = attr_list -> columns * x;

        if (! strcmp (data [count + a2], "delete"))
         {
           status = NFMget_serial_slot (NFMglobal.NFMuserid, "nfmattributes",
                    "n_attrno", &attr_no);
           if (status != NFM_S_SUCCESS)
            {
              _NFMdebug ((fname, "Get Ser No : status = <0x%.8x>\n",
              status));
              return (status);
            }

           if (atol (data [count + o1]) > 0)
            {
              status = MEMreset_buffer_no (value_list,
                       atol (data [count + o1]));
              if (status != MEM_S_SUCCESS)
               {
                 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                 _NFMdebug ((fname, "MEMreset_buffer_no : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_MEM);
               }

              status = _NFMchange_value_info ("C",
                       attr_no, data1 [data_list -> columns + x],
                       value_list);
              if (status != NFM_S_SUCCESS)
               {
                 _NFMdebug ((fname, "Ld ValLst : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
            }
           else if (strlen (data1 [data_list -> columns + x]))
            {
              status = _NFMchange_value_info ("C", 
                       attr_no, data1 [data_list -> columns +  x], NULL);
              if (status != NFM_S_SUCCESS)
               {
                 _NFMdebug ((fname, "Ld ValLst : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
            }

/***********************************************************************
                      ****************************
We are commenting this part of the code and replacing it by the few
lines immediately below. We are not sure of what exactly this part 
of the code is intended for. Test this part and inform HSV about
this. Temporary change Done for NFM SERVER HP PORT. - IGI 2 Sep 94.
                      ****************************
	   if (strlen (data [count + q1], data [count + q2]))
	     {
	       status = _NFMchange_value_info (data [count + q2], attr_no);
	       if (status != NFM_S_SUCCESS)
		 {
		   _NFMdebug ((fname, "Ld AdvLst : status = <0x%.8x>\n",
			       status));
		   return (status);
		 }
	     }
***********************************************************************/
	   if (strcmp (data [count + q1], data [count + q2]))
	     {
	       status = _NFMchange_value_info ("C", attr_no, data [count + q2], NULL);
	       if (status != NFM_S_SUCCESS)
		 {
		   _NFMdebug ((fname, "Ld AdvLst : status = <0x%.8x>\n",
			       status));
		   return (status);
		 }
	     }
/**************
           if (atol (data [count + k1]) > 0)
            {
              status = MEMreset_buffer_no (value_list,
                       atol (data [count + k1]));
              if (status != MEM_S_SUCCESS)
               {
                 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                 _NFMdebug ((fname, "Reset No : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_MEM);
               }
 
              status = _NFMchange_value_info ("A",
                       attr_no, "", value_list);
              if (status != NFM_S_SUCCESS)
               {
                 _NFMdebug ((fname, "Ld AdvLst : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
            }
***************************************/

           sprintf (sql_str2,
       "%d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', ",
           attr_no, data [count + a1], data [count + b1],
           data [count + c1],
           data [count + d1], data [count + e1], data [count + f1],
           data [count + g1], data [count + h1], data [count + i1],
           data [count + j1]);
 
           sprintf (sql_str, "%s%s %s, '%s', '%s', '%s', '%s', %s, ",
           sql_str1, sql_str2,
           data [count + l1], data [count + m1],
           data [count + n1], "null");

           if (strlen (data [count + p1]))
             strcat (sql_str, data [count + p1]);
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

              ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);
            }
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }


long _NFMcheck_dup_name (attr_list) 
MEMptr attr_list ;
{    
  static char *fname = "_NFMcheck_dup_name" ;
  long x,y, countx, county, dup, status, a1 ;
  char **column, **data ;

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
      return (NFM_E_MEM);
    }
  
  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;

  a1 = -1 ;
  for (y = 0; y < attr_list -> columns; ++y)
    {
      if (! strcmp (column [y], "n_name"))            a1 = y;
    }
  
  dup = 0 ;
  for (x = 0 ; x < attr_list -> rows; x++)
    {
      countx = attr_list -> columns * x + a1 ;
      for (y = x+1 ;y < attr_list->rows ; y++)
	{
	  county = attr_list -> columns*y + a1 ;
	  if (strcmp (data[countx], data[county]) == 0)
	    {
	      dup = 1 ;
	      break ;
	    }
	}
      if (dup) 
	{
	  ERRload_struct (NFM, NFM_E_DUP_ATTR_NAME, "", "") ;
	  return (NFM_E_DUP_ATTR_NAME) ;
	}
    }

  return (NFM_S_SUCCESS) ;
}
/* this function is almost identical to NFMload_value_info
   but is used by change catalog - in order to avoid any
   problems with create catalog, I created new functions for now MMS */

 long _NFMchange_value_info (type, attr_no, def_value, value_list)
   char      *type;
   long      attr_no;
   char      *def_value;
   MEMptr    value_list;
   {
     static char *fname = "_NFMchange_value_info" ;
     long    status;
     char    max [100], min [100];
     long    list_no, prog_no, def_no;
     char    list_num [50] ;
     char    prog_num [50], def_num [50];
     char    **column, **data;
     char    sql_str [1024];
     long    _NFMchange_list_info ();
     long    _NFMchange_range_info ();

     _NFMdebug ((fname, "Attr No = <%d> : Def Value = <%s>\n",
		 attr_no, def_value));

     list_no = 0;     prog_no = 0;
     def_no  = 0;
     min [0] = 0;     max [0] = 0;
     
     if (value_list)
      {
        column = (char **) value_list -> column_ptr;
        data   = (char **) value_list -> data_ptr;

	if (! strcmp (data [0], "NFM_RANGE"))
	  {
	    status = _NFMchange_range_info (value_list, min, max);
	    if (status != NFM_S_SUCCESS)
	      {
		_NFMdebug ((fname, "Load Range List : status = <0x%.8x>\n",
			  status));
		return (status);
	      }
	  }
	else if (! strcmp (data [0], "NFM_STATIC"))
	  {
	    status = _NFMchange_list_info (value_list, &list_no);
	    if (status != NFM_S_SUCCESS)
	      {
		_NFMdebug ((fname, "Load Keyin List : status = <0x%.8x>\n",
			  status));
		return (status);
	      }
	  }

	if ((! strlen (min)) && (! strlen (max)) && (!list_no) && (! strlen (def_value)))
	  {
	    _NFMdebug ((fname, "NO DEF SET UP : status = <0x%.8x>\n",
		      NFM_S_SUCCESS));
	    return (NFM_S_SUCCESS);
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
	 "n_listno,  n_programno",
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
     
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

long _NFMchange_advice_info (new_advice_string, attr_no) 
     char *new_advice_string ;
     long      attr_no;
{
  char *fname = "_NFMchange_advice_info" ;
  long    status;
  long    list_no ;
  char    sql_str [1024];
  char    c_listno [20] ;
  long    _NFMchange_list_info ();
  long    _NFMchange_range_info ();
  
  _NFMdebug ((fname, "Attr No = <%d> : New advice string = <%s>\n",
	      attr_no, new_advice_string)) ;

/*** try an update **/
  sprintf (sql_str, "where n_attrno = %d and n_type = 'A'",
	   attr_no) ;

  status = NFMget_attr_value (NFMglobal.NFMuserid, "NFMVALUES",
			      "n_listno", sql_str, c_listno) ;
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_BAD_CONDITION))
    {
      _NFMdebug ((fname, "Failure : Get attr value : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  if (status == NFM_I_BAD_CONDITION) /* no rows found */
    {
      status = NFMget_serial_slot (NFMglobal.NFMuserid, "nfmlists",
				   "n_listno", &list_no) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : get serial slot : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}

      sprintf (sql_str,
	       "INSERT INTO NFMVALUES (n_attrno, n_type, n_listno) VALUES (%d, 'A', %d)",
	       attr_no, list_no) ;
      
      status = SQLexec_imm (sql_str);
      if (status != SQL_S_SUCCESS)
	{
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

      sprintf (sql_str,
	       "INSERT INTO NFMLISTS (n_listno, n_value) VALUES (%d, '%s')",
	       list_no, new_advice_string) ;
      
      status = SQLexec_imm (sql_str);
      if (status != SQL_S_SUCCESS)
	{
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
    }
  else
    {
      sprintf (sql_str,
	       "UPDATE NFMVALUES set n_listno = %s where n_type = 'A' and n_attrno = %d", 
	       c_listno, attr_no) ;
      status = SQLexec_imm (sql_str);
      if (status != SQL_S_SUCCESS)
	{
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

      sprintf (sql_str,
	       "UPDATE NFMLISTS set n_value = '%s' where n_listno = %s",
	       new_advice_string, c_listno) ;
      status = SQLexec_imm (sql_str);
      if (status != SQL_S_SUCCESS)
	{
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
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}


 long _NFMchange_list_info (value_list, list_no)
   MEMptr     value_list;
   long       *list_no;
   {
     static char *fname = "_NFMchange_list_info" ;
     long     status, atol ();
     char     **data;
     char     sql_str [1024];
     long     x, count;
     int      value_exist ;

     *list_no = 0;


     data = (char **) value_list -> data_ptr;
     
     status = NFMget_serial_slot (NFMglobal.NFMuserid, "nfmlists",
              "n_listno", list_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Serial No : status = <0x%.8x>\n",
        status));
        return (status);
      }

     value_exist = 0 ;

     for (x = 0; x < value_list -> rows; ++x)
      {
        count = value_list -> columns * x;

        if (! strcmp (data [count], "NFM_STATIC"))
	    {
	      if (strlen (data [count + 3]))
		{
		  value_exist = 1 ;
		  sprintf (sql_str,
			   "INSERT INTO NFMLISTS (%s) VALUES (%d, '%s')",
			   "n_listno, n_value", *list_no, data [count + 3]);
		  
		  status = SQLexec_imm (sql_str);
		  if (status != SQL_S_SUCCESS)
		    {
		      
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
	else
	  {
	    /* if when a non NFM_STATIC is found */
	    break ;
	  }
      }

     if (!value_exist) *list_no = 0 ;

     _NFMdebug ((fname, "SUCCESSFUL : List No = <%d>\n", *list_no));
     return (NFM_S_SUCCESS);
   }

 long _NFMchange_range_info (value_list, min, max)
   MEMptr    value_list;
   char      *min, *max;
   {
     static char *fname = "_NFMchange_range_info" ;
     char     **data;

     _NFMdebug ((fname, "Min = <%s> : Max = <%s>\n", 
		 min, max));

     data = (char **) value_list -> data_ptr;

     /* PER GLENN - check only the first row */

     if (! strcmp (data [0], "NFM_RANGE"))
       {
	 sprintf (min, "%s", data [1]);
	 sprintf (max, "%s", data [2]);
       }

     _NFMdebug ((fname, "SUCCESSFUL : Min = <%s> : Max = <%s>\n", 
		 min, max));
     return (NFM_S_SUCCESS);
   }

