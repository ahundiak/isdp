#include "machine.h"
#include "CMDTOOLS.h"

#define F_CAT_TYPE 0
#define CAT_TYPE 1

  extern struct NFMglobal_st NFMglobal ;

/* MMS : This function returns an empty row */
 long NFMquery_table_template (user_id, attr_list)
   long     user_id;
   MEMptr   *attr_list;
   {
     char   *fname = "NFMquery_table_template" ;
     long   status;
     char   sql_str [2048];
     char   **column;
     long   NFMi_template () ;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = NFMi_template (attr_list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "template failed : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMquery_template_definition (table_type, table_name,
				    identifier, attr_list)
   char     *table_type;
   char     *table_name;
   char     *identifier ;
   MEMptr   *attr_list;
   {
     char  *fname = "NFMquery_template_definition" ;
     long   status, template_no ;
     char   sql_str [1024] ;
     long _NFMget_template_no ();

     _NFMdebug ((fname, "Table Type = <%s> : Table Name = <%s> : identifier = <%s>\n",
		 table_type, table_name, identifier)) ;

     NFMchange_case (table_type, 1);
     if (! strcmp (table_name, "nfmsystem")) NFMchange_case (table_name, 1);

     status = _NFMget_template_no (table_type, table_name, identifier,
				  &template_no);
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Get Template No : status = <0x%.8x>\n",
		     status));
	 return (status);
       }
     
     sprintf (sql_str, "n_tableno = %d", template_no);
 
     status = NFMget_table_attr (NFMglobal.NFMuserid, sql_str, "", attr_list);
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (attr_list);
	 _NFMdebug ((fname, "Get Tab Attr : status = <0x%.8x>\n",
		     status));
	 return (status);
       }
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMquery_template_attributes (table_type,table_name, identifier,
                                    attr_list, data_list, value_list)
   char     *table_type;
   char     *table_name;
   char     *identifier;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     char   *fname = "NFMquery_template_attributes" ;
     long   status, template_no ;
     char   sql_str [1024] ;
     long _NFMget_template_no ();
  
     _NFMdebug ((fname, "Table  Type = <%s> : Table Name = <%s>\n",
		 table_type, table_name));

     NFMchange_case (table_type, 1);

     
     if (! strcmp (table_name, "nfmsystem")) NFMchange_case (table_name, 1);

     status = _NFMget_template_no (table_type, table_name, identifier,
			       &template_no);
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
		     status));
	 return (status);
       }
     
     sprintf (sql_str, "n_tableno = %d", template_no) ;

     status = NFMget_table_attr (NFMglobal.NFMuserid, sql_str, "", attr_list);
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (attr_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 _NFMdebug ((fname, "Get Tab Attr : status = <0x%.8x>\n",
		     status));
	 return (status);
       }
/*     
     status = NFMget_data_value (NFMglobal.NFMuserid,
				 *attr_list, data_list, value_list);
*/
     status = _NFMget_data_value (*attr_list, data_list, value_list,
				  "A", "R");

     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (attr_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 _NFMdebug ((fname, "Get Data Values : status = <0x%.8x>\n",
		     status));
	 return (status);
       }
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMquery_template_information (table_type,table_name, identifier,
                                     attr_list, data_list, value_list)
   char     *table_type;
   char     *table_name;
   char     *identifier ;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     char   *fname = "NFMquery_template_information" ;
     long   status, template_no ;
     char   sql_str [1024] ;
     long _NFMget_template_no ();

     _NFMdebug ((fname, "Table  Type = <%s> : Table Name = <%s>\n", 
		 table_type, table_name));

     NFMchange_case (table_type, 1);
     if (! strcmp (table_type, "nfmsystem")) NFMchange_case (table_name, 1);

       status = _NFMget_template_no (table_type, table_name, identifier,
				    &template_no);
        if (status != NFM_S_SUCCESS)
	  {
           _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
           status));
           return (status);
         }
        sprintf (sql_str, "n_tableno = %d", template_no) ;

     status = NFMget_table_attr (NFMglobal.NFMuserid, sql_str, "", attr_list);
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (attr_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 _NFMdebug ((fname, "Tab Attr : status = <0x%.8x>\n", status));
	 return (status);
       }
     
     status = _NFMget_data_info (*attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (attr_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 _NFMdebug ((fname, "Get Data Values : status = <0x%.8x>\n",
		     status));
	 return (status);
       }
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

long NFMcreate_template (table_type, table_name, identifier,
			   attr_list, data_list, value_list)
     char      *table_type, *table_name, *identifier;
     MEMptr    attr_list, data_list, value_list;
{
  char     *fname = "NFMcreate_template" ;
  long     status, table_no ;

  _NFMdebug ((fname, "Table  Name = <%s> : Table Type = <%s> : Identifier = <%s>\n",
              table_type, table_name, identifier)) ;
  
  status = _NFMload_attributes (table_type, table_name, identifier, &table_no,
			       attr_list, data_list, value_list);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "load attributes : status = <0x%.8x>\n",
                status)) ;
      return (status);
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}


 long NFMdelete_template (table_type,table_name, identifier)
   char      *table_type;
   char      *table_name;
   char      *identifier;
   {
     char    *fname = "NFMdelete_template" ;
     long    status;
     char    sql_str [1024];
     long    atol ();
     MEMptr  list = NULL;
     long    x, count, template_no;
     char    **data;
     long _NFMget_template_no ();

     _NFMdebug ((fname, "Table Type  = <%s> : Table Name = <%s> : Identifier = <%s>\n", 
		 table_type, table_name, identifier));


     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = _NFMget_template_no (table_type, table_name, identifier,
				   &template_no);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
        status));
        return (status);  
      }   

     sprintf (sql_str, "SELECT %s FROM %s WHERE %s = %d",
              "n_attrno", "NFMATTRIBUTES", "n_tableno", template_no);

     status = SQLquery (sql_str, &list, 2 * MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         ((status) != SQL_I_NO_ROWS_FOUND))
      {
        MEMclose (&list);
        NFMrollback_transaction (0);
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL query  : status = <0x%.8x>\n",  status));
        return ( NFM_E_SQL_QUERY);            
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        NFMrollback_transaction (0);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);            
      }

     data = (char **) list -> data_ptr;

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;

        status = NFMunload_value_info (NFMglobal.NFMuserid, "A",
                 atol (data [count]));
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           NFMrollback_transaction (0);
           _NFMdebug ((fname, "Unload Value List : status = <0x%.8x>\n",
           status));
           return (status);            
         }

        status = NFMunload_value_info (NFMglobal.NFMuserid, "C",
                 atol (data [count]));
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           NFMrollback_transaction (0);
           _NFMdebug ((fname, "Unload Value List : status = <0x%.8x>\n",
           status));
           return (status);            
         }

        sprintf (sql_str, "DELETE FROM %s WHERE %s = %s",
                 "NFMATTRIBUTES", "n_attrno", data [count]);

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
         {
           MEMclose (&list);
           NFMrollback_transaction (0);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
           _NFMdebug ((fname, "Del Attr Stmt : status = <0x%.8x>\n",
		       status));
           return (NFM_E_SQL_STMT);           
         }

        status = NFMreturn_serial_slot (NFMglobal.NFMuserid, "nfmattributes",
                 "n_attrno", atol (data [count]));
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           NFMrollback_transaction (0);
           _NFMdebug ((fname, "Ret Empty Slot : status = <0x%.8x>\n",
           status));
           return (status);           
         }
      }
     
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);           
      }

     sprintf (sql_str, "DELETE FROM %s WHERE %s = %d",
              "NFMTABLES", "n_tableno", template_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "Del Table Stmt : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);        
      }

     status = NFMreturn_serial_slot (NFMglobal.NFMuserid, "nfmtables",
              "n_tableno", template_no) ;
     if (status != NFM_S_SUCCESS)
      {
        free (sql_str);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Ret Empty Slot : status = <0x%.8x>\n",
        status));
        return (status);           
      }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
        status));
        return (status);
      }
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);  
   }




 long _NFMget_template_no (table_type, table_name, identifier, table_no)
   char    *table_type, *table_name, *identifier;
   long    *table_no;
   {
     static char *fname = "_NFMget_template_no" ;
     long    status, atol ();
     char    sql_str [1024] ;
     MEMptr  buffer = NULL ;
     char   **data ;

     *table_no = 0;

     _NFMdebug ((fname, "Table Type = <%s>  : Table Name = <%s> : Identifier = <%s>\n",
		 table_type, table_name, identifier));

     NFMchange_case (table_type, 1);
     if (! strcmp (table_type, "nfmsystem")) NFMchange_case (table_name, 1);

     sprintf (sql_str, "Select n_tableno from nfmtables where n_tablename = '%s' and n_tabletype = '%s' and n_identifier = '%s'",
	      table_name, table_type, identifier) ;

     status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
     if (status != SQL_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
      }

     status = MEMbuild_array (buffer) ;
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_MEM) ;
       }
     
     data = (char **) buffer->data_ptr;
     *table_no = atol (data [0]) ;

     status = MEMclose (&buffer) ;
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_MEM) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL : Template No = <%d>\n", *table_no));
     return (NFM_S_SUCCESS);
   }

 long NFMchange_template (table_name,table_type, identifier,
                          attr_list, data_list, value_list)
   char      *table_name;  /* I */
   char      *table_type;  /* I */
   char      *identifier ; /* I */
   MEMptr    attr_list, data_list, value_list; /* I */
   {
     char     *fname = "NFMchange_template" ;
     long     status;
     char     sql_str [1024];
     long    _NFMchange_attributes_for_template ();

     _NFMdebug ((fname, "Table  Name = <%s> : table type = <%s> : Identifier = <%s>\n",
		 table_name, table_type, identifier));

     status = _NFMchange_attributes_for_template (table_type, table_name, 
						  identifier,
						  attr_list, data_list, 
						  value_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Load Table Attr Failed : status = <0x%.8x>\n",
		    status));
        return (status);         
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMi_template (attr_list)
   MEMptr    *attr_list;
   {
      static char *fname = "NFMi_template" ;
      long   status;
      char   datatype [50] ;

      _NFMdebug ((fname, "ENTER\n")) ;

      status = MEMopen (attr_list, 2 * MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      sprintf (datatype, "char(%d)", NFM_NAME) ;
      status = MEMwrite_format (*attr_list, "n_name", datatype) ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      sprintf (datatype, "char(%d)", NFM_DATATYPE) ;
      status = MEMwrite_format (*attr_list, "n_datatype", datatype) ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      sprintf (datatype, "char(%d)", NFM_SYNONYM) ;
      status = MEMwrite_format (*attr_list, "n_synonym", datatype) ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      sprintf (datatype, "char(%d)", NFM_APPLICATION);
      status = MEMwrite_format (*attr_list, "n_application", datatype) ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      sprintf (datatype, "char(%d)", NFM_READ) ;
      status = MEMwrite_format (*attr_list, "n_read", datatype) ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      sprintf (datatype, "char(%d)", NFM_WRITE) ;
      status = MEMwrite_format (*attr_list, "n_write", datatype) ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      sprintf (datatype, "char(%d)", NFM_UPDATE) ;
      status = MEMwrite_format (*attr_list, "n_update", datatype) ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      sprintf (datatype, "char(%d)", NFM_DELETE) ;
      status = MEMwrite_format (*attr_list, "n_delete", datatype) ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      sprintf (datatype, "char(%d)", NFM_NULL) ;
      status = MEMwrite_format (*attr_list, "n_null", datatype) ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      sprintf (datatype, "char(%d)", NFM_CHECKIN) ;
      status = MEMwrite_format (*attr_list, "n_checkin", datatype) ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      sprintf (datatype, "char(%d)", NFM_CHECKOUT) ;
      status = MEMwrite_format (*attr_list, "n_checkout", datatype) ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      status = MEMwrite_format (*attr_list, "n_seqno", "integer") ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }


      status = MEMwrite_format (*attr_list, "n_attrno", "integer") ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      status = MEMwrite_format (*attr_list, "n_tableno", "integer") ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      status = MEMwrite_format (*attr_list, "n_valueno", "integer") ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      /* Changed by Karen Tice on 2/2/93 (for PDM) n_adviceno -> n_advice */
      status = MEMwrite_format (*attr_list, "n_advice", "char(40)") ;
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
    }


 long _NFMchange_attributes_for_template (table_type, table_name, identifier,
					  attr_list, data_list, value_list)
   char      *table_type, *table_name, *identifier ;
   MEMptr    attr_list, data_list, value_list;
   {
     static char *fname = "_NFMchange_attributes_for_template";
     long     status, atol ();
     char     **column, **data, **data1;
     long     x, y, z, count;
     char     sql_str [4092], sql_str1 [1024];
     char     sql_str2 [1024], value [50];
     long     table_no, attr_no;

     long     a1, b1, c1, d1, e1, f1, g1, h1;
     long     i1, j1, k1, l1, m1, n1, o1, p1, q1 ;
     long     a2, b2, c2, d2, e2, f2, g2, h2;
     long     i2, j2, k2, l2, m2, n2, o2, p2, q2 ;

     _NFMdebug ((fname, "Table Type  = <%s> : Table Name = <%s> : Identifier = <%s>\n", 
		 table_type, table_name, identifier));

     if (_NFMdebug_st.NFMdebug_on)
       {
	 MEMprint_buffer ("attr list", attr_list, _NFMdebug_st.NFMdebug_file);
	 MEMprint_buffer ("data list", data_list, _NFMdebug_st.NFMdebug_file);
	 MEMprint_buffers ("value list", value_list, _NFMdebug_st.NFMdebug_file);
       }

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
	    (! strlen (data [count + q2])))        break;
        else 
	    z = z + 1;
      }
/* z points to the first new attribute */
    
     _NFMdebug ((fname, "Original Rows = <%d> : Total Rows = <%d>\n", 
		 z, attr_list->rows));

     status = _NFMget_template_no (table_type, table_name, identifier,
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
*/

	if (strcmp (data [count + q1], data [count+q2]))
	  {
	    status = _NFMchange_advice_info (data[count+q2], attr_no) ;
	    if (status != NFM_S_SUCCESS)
	      {
		NFMrollback_transaction (0) ;
		_NFMdebug ((fname, "Change Advice Info : status = <0x%.8x>\n",
			    status)) ;
		return (status) ;
	      }
	  }

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

     /*   Change To New Data Type     */

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
	if ((strcmp (data [count+q1], data [count+q2])) &&
	    (strcmp (data [count+a2], "delete")))
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
	       NFMrollback_transaction (0) ;
	       _NFMdebug ((fname, "Unload Old Advice : status = <0x%.8x>\n",
			   status)) ;
	       return (status) ;
	     }

/********
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

     _NFMdebug ((fname, "Drop Attributes : %s\n"));

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

           status = NFMget_table_name (NFMglobal.NFMuserid, table_type, table_name,
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

 long NFMquery_change_template_information (table_type, table_name, identifier,
					    attr_list, data_list, value_list)
   char     *table_type ;
   char     *table_name ;
   char     *identifier ;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_change_template_information" ;
     long     status, table_no ;
     char     table_str [100] ;

     NFMchange_case (table_type, 1);
     if (! strcmp (table_type, "nfmsystem")) NFMchange_case (table_name, 1);

     _NFMdebug ((fname, "Table Type  = <%s>  : Table Name = <%s>\n", 
		 table_type, table_name));
        
     status = _NFMget_template_no (table_type, table_name, identifier,
				   &table_no);
     if (status != NFM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_BAD_TABLE, "", NULL) ;
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n", status));
        return (status);
      }

     sprintf (table_str, "n_tableno = %d", table_no) ;

     status = NFMquery_change_condition_information (NFMglobal.NFMuserid,
              "", "", table_str, "",
              attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Qry Chg Info : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

long NFMsplit_template_definition (attr_list,
				   attr_list1, attr_list2,
				   identifier_list) 
   MEMptr    attr_list;      /* input - combined attributes */
   MEMptr    *attr_list1;    /* output - catalog attributes */
   MEMptr    *attr_list2;    /* output - f_catalog attributes */
   MEMptr    *identifier_list; /* output - identifier list */
   {
     static char *fname = "NFMsplit_template_definition" ;
     long    status;
     char    *sql_str, *str, *str1;
     MEMptr  sql_buffer = NULL ;
     char    **column, **format, **data, **table_data ;
     char    datatype [30] ;
     long    x, y, count, a, b, or_clause, filetype, offset, e;
     long    table_no, atol();

     _NFMdebug ((fname, "ENTER\n")) ;

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     status = MEMopen (attr_list1, 2 * MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMopen (attr_list2, 2 * MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list1);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     format = (char **) attr_list -> format_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
       {
	 if (! strcmp (column [y], "n_name"))              a = y;
	 else if (! strcmp (column [y], "n_datatype"))     b = y;
	 else if (! strcmp (column [y], "n_tableno"))      e = y;
	 
	 status = MEMwrite_format (*attr_list1, column [y], format [y]);
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (attr_list1);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Write Format : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);
	   }
	 
	 status = MEMwrite_format (*attr_list2, column [y], format [y]);
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (attr_list1);
	     MEMclose (attr_list2);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Write Format : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);
	   }
       }

     sql_str = (char *) malloc (attr_list->rows * 30) ;
     if (sql_str == NULL)
       {
	 _NFMdebug ((fname, "Malloc failed\n")) ;
	 ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	 return (NFM_E_MALLOC) ;
       }

     str = (char *) malloc (attr_list->rows*30 + 100) ;
     if (str == NULL)
       {
	 free (sql_str) ;
	 _NFMdebug ((fname, "Malloc failed\n")) ;
	 ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	 return (NFM_E_MALLOC) ;
       }

     str1 = (char *) malloc (attr_list->rows*30 + 100) ;
     if (str1 == NULL)
       {
	 free (str) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "Malloc failed\n")) ;
	 ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	 return (NFM_E_MALLOC) ;
       }

     or_clause = 0 ;
     sql_str [0] = 0 ;
     for (y = 0; y < attr_list -> rows; ++y)
       {
	 count = y*attr_list->columns ;
	 if (strlen (data[count+e]))
	     {
	       if (or_clause) strcat (sql_str, " ,");
	       else 
		 {
		   or_clause = 1 ;
		 }
	       strcat (sql_str, data [count + e]);
	     }
       }

     sprintf (str, 
	      "select n_tableno, n_tablename, n_identifier from nfmtables where n_tableno IN (%s)",
	      sql_str) ;

     sprintf (str1, 
	      "select DISTINCT n_identifier from nfmtables where n_tableno IN (%s)",
	      sql_str) ;

     status = SQLquery (str, &sql_buffer, MEM_SIZE) ;
     if (status != SQL_S_SUCCESS)
       {
	 free (sql_str) ;
	 free (str) ;
	 _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_SQL_QUERY) ;
       }

     status = SQLquery (str1, identifier_list, MEM_SIZE) ;
     if (status != SQL_S_SUCCESS)
       {
	 free (sql_str) ;
	 free (str) ;
	 _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	 return (NFM_E_SQL_QUERY) ;
       }

     free (sql_str) ;
     free (str1) ;
     free (str) ;

     status = MEMbuild_array (sql_buffer) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     table_data = (char **) sql_buffer -> data_ptr ;

     sql_str = (char *) malloc (attr_list -> row_size);
     if (! sql_str)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_MALLOC);
      }
     sql_str [0] = 0;

     for (x = 0; x < attr_list -> rows; ++x)
      {
         count = attr_list -> columns * x;
         sql_str [0] = 0;

	 table_no = atol (data [count+e]) ;

	 filetype = CAT_TYPE ;

	 for (y=0; y<sql_buffer->rows; y++)
	   {
	     offset = y*sql_buffer->columns ;
	     _NFMdebug ((fname, "%d : %s : %s\n",
			 atol (table_data[offset]), 
			 table_data[offset+1],
			 table_data[offset+2])) ;  

	     if (table_no == atol (table_data[offset]))
	       {
		 if (strcmp (table_data[offset+1], "f_catalog") == 0)
		   filetype = F_CAT_TYPE;
		 else 
		   filetype = CAT_TYPE ;
		 break ;
	       }
	   }
	 
         for (y = 0; y < attr_list -> columns; ++y)
          {
            strcat (sql_str, data [count + y]);
            strcat (sql_str, "\1");
          }

	 if (filetype == F_CAT_TYPE)
	   {
            status = MEMwrite (*attr_list2, sql_str);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               MEMclose (attr_list1);
               MEMclose (attr_list2);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
          }
         else
          {
            status = MEMwrite (*attr_list1, sql_str);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               MEMclose (attr_list1);
               MEMclose (attr_list2);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
          }
      }

     free (sql_str);

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

long NFMsplit_template_attributes (attr_list, data_list, 
				   attr_list1, data_list1,
				   attr_list2, data_list2,
				   identifier_list)
   MEMptr    attr_list, data_list;      /* input buffer */
   MEMptr    *attr_list1, *data_list1;  /* output - catalog buffers */
   MEMptr    *attr_list2, *data_list2;  /* output - f_catalog buffers */
   MEMptr    *identifier_list ;         /* output - identifier list */
   {
     static char *fname = "NFMsplit_template_attributes" ;
     long    status;
     char    **column, **data;
     char    **data1, **data2, **data3;
     long    x, y, z, count, count1, count2, count3;
     long    a, b, found;
     char    *sql_str1, *sql_str2;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = NFMsplit_template_definition (attr_list,
					    attr_list1, attr_list2,
					    identifier_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Split Cat Def : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }
   
     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
      }

     status = MEMbuild_array (*attr_list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }
 
     data1 = (char **) (*attr_list1) -> data_ptr;

     status = MEMopen (data_list1, 2 * MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     for (x = 0; x < (*attr_list1) -> rows; ++x)
      {
        count = (*attr_list1) -> columns * x;

        status = MEMwrite_format (*data_list1,
                 data1 [count + a], data1 [count + b]);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list1);
           MEMclose (attr_list2);
 
           MEMclose (data_list1);

           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }
      }

     status = MEMbuild_array (*attr_list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);

        MEMclose (data_list1);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }
 
     data2 = (char **) (*attr_list2) -> data_ptr;

     status = MEMopen (data_list2, 2 * MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);

        MEMclose (data_list1);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     for (x = 0; x < (*attr_list2) -> rows; ++x)
      {
        count = (*attr_list1) -> columns * x;

        status = MEMwrite_format (*data_list2,
                 data2 [count + a], data2 [count + b]);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list1);
           MEMclose (attr_list2);
 
           MEMclose (data_list1);
           MEMclose (data_list2);

           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }
      }

     sql_str1 = (char *) malloc ((*data_list1) -> row_size);
     if (! sql_str1)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);

        MEMclose (data_list1);
        MEMclose (data_list2);

        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_MALLOC);
      }
     sql_str1 [0] = 0;

     sql_str2 = (char *) malloc ((*data_list2) -> row_size);
     if (! sql_str2)
      {
        free (sql_str1);

        MEMclose (attr_list1);
        MEMclose (attr_list2);

        MEMclose (data_list1);
        MEMclose (data_list2);

        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_MALLOC);
      }
     sql_str2 [0] = 0;

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str1);
        free (sql_str2);

        MEMclose (attr_list1);
        MEMclose (attr_list2);

        MEMclose (data_list1);
        MEMclose (data_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     data3 = (char **) data_list -> data_ptr;
 
     for (z = 0; z < data_list -> rows; ++z)
      {
        count3 = data_list -> columns * z;

        sql_str1 [0] = 0; sql_str2 [0] = 0;

        for (x = 0; x < attr_list -> rows; ++x)
         {
           count = attr_list -> columns * x;
           found = 0;
          
           for (y = 0; (y < (*attr_list1) -> rows) && (! found); ++y) 
            {
              count1 = (*attr_list1) -> columns * y;
 
              if (! strcmp (data [count + a], data1 [count1 + a]))
               {
                 strcat (sql_str1, data3 [count3 + x]);
                 strcat (sql_str1, "\1");

                 found = 1;
               }
            }

           for (y = 0; (y < (*attr_list2) -> rows) && (! found); ++y) 
            {
              count2 = (*attr_list2) -> columns * y;

              if (! strcmp (data [count + a], data2 [count2 + a]))
               {
                 strcat (sql_str2, data3 [count3 + x]);
                 strcat (sql_str2, "\1");

                 found = 1;
               }              
            }

           if (! found)
            {
              free (sql_str1);
              free (sql_str2);
 
              MEMclose (attr_list1);
              MEMclose (attr_list2);

              MEMclose (data_list1);
              MEMclose (data_list2);

              ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
              _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n",
              NFM_E_CORRUPTED_BUFFERS));
              return (NFM_E_CORRUPTED_BUFFERS);
            }
         }

        status = MEMwrite (*data_list1, sql_str1);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str1);
           free (sql_str2);

           MEMclose (attr_list1);
           MEMclose (attr_list2);

           MEMclose (data_list1);
           MEMclose (data_list2);

	   if (status == MEM_E_EXTRA_DATA)
	     {
	       ERRload_struct (NFM, NFM_E_DUP_ATTR_NAME, "", "") ;
	       return (NFM_E_DUP_ATTR_NAME) ;
	     }

           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }

        status = MEMwrite (*data_list2, sql_str2);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str1);
           free (sql_str2);

           MEMclose (attr_list1);
           MEMclose (attr_list2);

           MEMclose (data_list1);
           MEMclose (data_list2);

	   if (status == MEM_E_EXTRA_DATA)
	     {
	       ERRload_struct (NFM, NFM_E_DUP_ATTR_NAME, "", "") ;
	       return (NFM_E_DUP_ATTR_NAME) ;
	     }

           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }
      }

     free (sql_str1);
     free (sql_str2);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
