#include "machine.h"
#include "DBTOOLS.h"
  extern struct NFMglobal_st NFMglobal ;

 long NFMget_data_value (user_id, attr_list, data_list, value_list)
   long     user_id;       /*  input - user id */
   MEMptr   attr_list;     /*  modified - attribute buffer */
   MEMptr   *data_list;    /*  modified - data buffer */
   MEMptr   *value_list;   /*  modified - value list */
   {
     static char *fname = "NFMget_data_value" ;
     long    status, atol ();
     long    x, y, z, count ;
     long    a, b, c, d, e, f, g, h ;
     long    no_buffers ;
     MEMptr  temp_list = NULL;
     char    **column, **data, **data1, **data2 ;
     char    *sql_str, *sql_str1, tmp_str[100] ;
     char    value [100] ;
     long    _NFMget_value_list ();
     MEMptr  attrs = NULL, list_buffer = NULL ;
     char    no_buff [10] ;
     int     comma, row_offset, offset ;
     long    list_values_exist ;

     /* The attr_list buffer received get offsets for
        n_name, n_datatype, etc */
     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (data_list);
        MEMclose (value_list);
	ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; b = -1; c = -1; d = -1; e = -1; f = -1; g = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
         else if (! strcmp (column [y], "n_valueno"))   c = y;
         else if (! strcmp (column [y], "n_adviceno"))  d = y;
         else if (! strcmp (column [y], "n_read"))      e = y;
         else if (! strcmp (column [y], "n_write"))     f = y;
         else if (! strcmp (column [y], "n_update"))    g = y;
         else if (! strcmp (column [y], "n_attrno"))    h = y;
      }

     /* if data_list existed recover data, otherwise put empty row */

     if (*data_list)
      {
	_NFMdebug ((fname, "data list not EMPTY\n")) ;
	status = MEMopen (&temp_list, MEM_SIZE);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
	    
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
	    return (NFM_E_MEM);          
	  }
	

	/* Create data list if one has not already exist */
	for (x = 0; x < attr_list -> rows; ++x)
	  {
	    count = attr_list -> columns * x;
	    
	    status = MEMwrite_format (temp_list,
				      data [count + a], data [count + b]);
	    if (status != MEM_S_SUCCESS)
	      {
		MEMclose (&temp_list);
		
		MEMclose (data_list);
		MEMclose (value_list);
		
		ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		_NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
			    status));
		return (NFM_E_MEM);          
	      }
	  }

        status = MEMbuild_array (*data_list);
        if (status != MEM_S_SUCCESS)
	  {
           free (sql_str);

           MEMclose (&temp_list);

           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }

	sql_str = (char *) malloc ((*data_list) -> row_size);
	if (! sql_str)
	  {
	    MEMclose (&temp_list);
	    
	    MEMclose (data_list);
	    MEMclose (value_list);
	    
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	    _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
			NFM_E_MALLOC));
	    return (NFM_E_MALLOC);          
	  }

	sql_str [0] = 0;
        z = (*data_list) -> columns;
	
        data1 = (char **) (*data_list) -> data_ptr;
	
        sql_str [0] = 0;
	
        for (y = 0; y < temp_list -> columns; ++y)
	  {
	    if (y < (*data_list) -> columns)  strcat (sql_str, data1 [y]);
	    
           strcat (sql_str, "\1");
         }

        status = MEMclose (data_list);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);

           MEMclose (&temp_list);

           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
	status = MEMsplit_copy_buffer (temp_list, data_list, 0);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (&temp_list);
	    
	    MEMclose (data_list);
	    MEMclose (value_list);
	    
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Split Copy : status = <0x%.8x>\n",
			status));
	    return (NFM_E_MEM);          
	  }
	
	status = MEMclose (&temp_list);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
	    return (NFM_E_MEM);          
	  }
      }
     else
       {
	 _NFMdebug ((fname, "data list is empty\n")) ;
	 z = 0 ;
	 status = MEMopen (data_list, MEM_SIZE);
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
	    return (NFM_E_MEM);          
	  }
	
	/* Create data list if one has not already exist */
	for (x = 0; x < attr_list -> rows; ++x)
	  {
	    count = attr_list -> columns * x;
	    
	    status = MEMwrite_format (*data_list,
				      data [count + a], data [count + b]);
	    if (status != MEM_S_SUCCESS)
	      {
		MEMclose (data_list);
		MEMclose (value_list);
		
		ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		_NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
			    status));
		return (NFM_E_MEM);          
	      }
	  }
	
	sql_str = (char *) malloc ((*data_list) -> row_size);
	if (! sql_str)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
	    
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	    _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
			NFM_E_MALLOC));
	    return (NFM_E_MALLOC);          
	  }
	sql_str [0] = 0;
        for (y = 0; y < (*data_list) -> columns; ++y)
           strcat (sql_str, "\1");

	 status = MEMwrite (*data_list, sql_str);
	 if (status != MEM_S_SUCCESS)
	   {
	     free (sql_str);
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);          
	   }
	 free (sql_str);
       }

     for (x=z; x<attr_list->rows ; ++x) 
       {
	 status = MEMwrite_data (attr_list, "0", x+1, c+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",status));
	     return (NFM_E_MEM);          
	   }

	 status = MEMwrite_data (attr_list, "0", x+1, d+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", 
			 status));
	     return (NFM_E_MEM);          
	   }
       }

     status = MEMbuild_array (attr_list) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Build Array (attr_list) : < 0x%.8x >\n", 
		     status));
	 return (NFM_E_MEM);          
       }

     data   = (char **) attr_list -> data_ptr;

    /* Get default values for the data list and value list buffers */


     comma = 0 ;

     sql_str1 = (char *) malloc (200 + 60 * attr_list->rows) ;
     
     if (!sql_str1) 
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attr_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str1)"));
	 return (NFM_E_MALLOC);          
       }

     sql_str  = (char *) malloc (200 + 60 * attr_list-> rows) ;

     if (!sql_str)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attr_list) ;
	 free (sql_str1) ;
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str)"));
	 return (NFM_E_MALLOC);          
       }


     sprintf (sql_str1, "SELECT %s FROM NFMVALUES WHERE (n_type = 'C' OR n_type = 'A') AND (",
	      "n_attrno, n_type, n_defaultvalue, n_defaultno, n_minvalue, n_maxvalue, n_listno, n_programno") ;
 	      
     sql_str[0] = 0 ;

     for (x = z; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 
	 if (comma)
	   strcat (sql_str, " OR ") ;
	 comma = 1 ;
	 sprintf (tmp_str, "n_attrno = %s", data[count + h]) ;
	 strcat (sql_str, tmp_str) ;
       } 
     
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by n_attrno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &attrs, MEM_SIZE) ;

     if (status != SQL_S_SUCCESS) 
       {
	 if ((status ) == SQL_I_NO_ROWS_FOUND)
	   {
	     MEMclose (&attrs) ;
	     _NFMdebug ((fname, "No Rows found\n"));
	     return (NFM_S_SUCCESS);                 
	   }
	 MEMclose (data_list) ;
	 MEMclose (value_list) ;
	 MEMclose (&attr_list) ;
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >", status));
	 return (NFM_E_SQL_QUERY) ;
       }

     comma = 0 ;

    sprintf (sql_str1, "SELECT %s FROM NFMVALUES a, NFMLISTS b WHERE (a.n_type = 'C' OR a.n_type = 'A') AND (a.n_listno = b.n_listno) AND (",
              "a.n_attrno, a.n_listno, b.n_value") ;

     sql_str[0] = 0 ;

     for (x = z; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 
	 if (comma)
	   strcat (sql_str, " OR ") ;
	 comma = 1 ;
	 sprintf (tmp_str, "a.n_attrno = %s", data[count + h]) ;
	 strcat (sql_str, tmp_str) ;
       } 
     
	
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by a.n_attrno, a.n_listno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &list_buffer, MEM_SIZE) ;

     free (sql_str1) ;
     free (sql_str) ;

     if ((status != SQL_S_SUCCESS)  && (status != SQL_I_NO_ROWS_FOUND))
       {
	 MEMclose (data_list) ;
	 MEMclose (value_list) ;
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >", status));
	 return (NFM_E_SQL_QUERY) ;
       }

     list_values_exist = 1 ;
     if (status == SQL_I_NO_ROWS_FOUND)
       {
	 list_values_exist = 0 ;
       }

     status = MEMbuild_array (attrs) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (list_buffer) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (*data_list) ;
     if (status != MEM_S_SUCCESS)
       {
         MEMclose (&temp_list);
         MEMclose (data_list);
         MEMclose (value_list);

         MEMclose (&attrs) ;

         _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
                   status));
         return (NFM_E_MEM);
       }

      data2 = (char **) attrs->data_ptr ;

     for (y = 0; y <attrs->rows; y++)
       {
	 row_offset = y*attrs->columns ;
	 
	 strcpy (value, data2 [row_offset + 2]) ;
         if (list_values_exist)
	   {
	     status = _NFMget_value_list (atol (data2 [row_offset]), /*attrno */
				     data2 [row_offset + 1], /* type */
				     data2 [row_offset + 4], /* minvalue*/
				     data2 [row_offset + 5], /* maxvalue */
				     atol(data2 [row_offset+3]), /*defno*/
				     atol(data2 [row_offset+6]), /*listno*/
				     atol(data2 [row_offset+7]), /*progno*/
				     value, &temp_list,
				     list_buffer) ;

	 if (status != NFM_S_SUCCESS && status != NFM_E_NO_ATTR_INFO)
	   {
	     MEMclose (&temp_list);
	     MEMclose (&attrs) ;
	     MEMclose (data_list);
	     MEMclose (value_list);
	     
	     _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
		       status));
	     return (status);          
	   }
	   }
else
{
status = NFM_S_SUCCESS ;
}	 
	 /* get row in attr/column in data list */
	 for (x=0; x<attr_list->rows; x++)
	   {
	     count = x*attr_list->columns ;
	     if (strcmp (data2 [row_offset], data [count +h]) == 0)
	       break ;
	   }
	 
	 if (x != attr_list->rows)
	   {
	     if (status != NFM_E_NO_ATTR_INFO)
	       {
		 if (strlen (value))
		   {
		     status = MEMwrite_data (*data_list, value, 1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&temp_list);
			 MEMclose (&attrs);
			 MEMclose (data_list);
			 MEMclose (value_list);
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }
		 
		 if (temp_list)
		   {
		     if (! (*value_list))
		       {
			 status = MEMsplit_copy_buffer (temp_list, value_list, 0);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Copy Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
		     else
		       {
			 status = MEMappend (temp_list, *value_list);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Append Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
		     
		     status = MEMclose (&temp_list);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list);
			 MEMclose (value_list);
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		     
		     status = MEMno_buffers (*value_list, &no_buffers);
		     sprintf (no_buff, "%d", no_buffers);
		     if (strcmp (data2 [row_offset +1], "C") == 0)
		       offset = c ;
		     else 
		       if (strcmp (data2 [row_offset +1], "A") == 0)
			 offset = d ;
		     status = MEMwrite_data (attr_list, no_buff, 
					     x + 1, offset + 1) ;
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list) ;
			 MEMclose (value_list) ;
			 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Write Data : < 0x%.8x >",
				     status));
			 return (NFM_E_MEM) ;
		       }
		   }
	       }
	   }
	 else
	   {
	     MEMclose (data_list) ;
	     MEMclose (value_list) ;
	     MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
	     _NFMdebug ((fname, "Corrupted System : < 0x%.8x >\n",
		       NFM_E_CORRUPTED_SYSTEM) );
	     return (NFM_E_CORRUPTED_SYSTEM) ;
	   }
       }
     
     MEMclose (&attrs) ;
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
  }

 long NFMget_data_value2 (user_id, attr_list, data_list, value_list)
   long     user_id;       /*  input - user id */
   MEMptr   attr_list;     /*  modified - attribute buffer */
   MEMptr   *data_list;    /*  modified - data buffer */
   MEMptr   *value_list;   /*  modified - value list */
   {
     static char *fname = "NFMget_data_value2" ;
     long    status, atol ();
     long    x, y, z, count ;
     long    a, b, c, d, e, f, g, h ;
     long    no_buffers ;
     MEMptr  temp_list = NULL;
     char    **column, **data, **data1, **data2 ;
     char    *sql_str, *sql_str1, tmp_str[100] ;
     char    value [100] ;
     long    _NFMget_value_list ();
     MEMptr  attrs = NULL, list_buffer = NULL ;
     char    no_buff [10] ;
     int     comma, row_offset, offset ;
     long    list_values_exist ;

     /* The attr_list buffer received get offsets for
        n_name, n_datatype, etc */
     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (data_list);
        MEMclose (value_list);
	ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; b = -1; c = -1; d = -1; e = -1; f = -1; g = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
         else if (! strcmp (column [y], "n_valueno"))   c = y;
         else if (! strcmp (column [y], "n_adviceno"))  d = y;
         else if (! strcmp (column [y], "n_read"))      e = y;
         else if (! strcmp (column [y], "n_write"))     f = y;
         else if (! strcmp (column [y], "n_update"))    g = y;
         else if (! strcmp (column [y], "n_attrno"))    h = y;
      }

     /* if data_list existed recover data, otherwise put empty row */

     if (*data_list)
      {
	_NFMdebug ((fname, "data list not EMPTY\n")) ;
	status = MEMopen (&temp_list, MEM_SIZE);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
	    
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
	    return (NFM_E_MEM);          
	  }
	

	/* Create data list if one has not already exist */
	for (x = 0; x < attr_list -> rows; ++x)
	  {
	    count = attr_list -> columns * x;
	    
	    status = MEMwrite_format (temp_list,
				      data [count + a], data [count + b]);
	    if (status != MEM_S_SUCCESS)
	      {
		MEMclose (&temp_list);
		
		MEMclose (data_list);
		MEMclose (value_list);
		
		ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		_NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
			    status));
		return (NFM_E_MEM);          
	      }
	  }

        status = MEMbuild_array (*data_list);
        if (status != MEM_S_SUCCESS)
	  {
           free (sql_str);

           MEMclose (&temp_list);

           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }

	sql_str = (char *) malloc ((*data_list) -> row_size);
	if (! sql_str)
	  {
	    MEMclose (&temp_list);
	    
	    MEMclose (data_list);
	    MEMclose (value_list);
	    
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	    _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
			NFM_E_MALLOC));
	    return (NFM_E_MALLOC);          
	  }

	sql_str [0] = 0;
        z = (*data_list) -> columns;
	
        data1 = (char **) (*data_list) -> data_ptr;
	
        sql_str [0] = 0;
	
        for (y = 0; y < temp_list -> columns; ++y)
	  {
	    if (y < (*data_list) -> columns)  strcat (sql_str, data1 [y]);
	    
           strcat (sql_str, "\1");
         }

        status = MEMclose (data_list);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);

           MEMclose (&temp_list);

           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
	status = MEMsplit_copy_buffer (temp_list, data_list, 0);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (&temp_list);
	    
	    MEMclose (data_list);
	    MEMclose (value_list);
	    
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Split Copy : status = <0x%.8x>\n",
			status));
	    return (NFM_E_MEM);          
	  }
	
	status = MEMclose (&temp_list);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
	    return (NFM_E_MEM);          
	  }
      }
     else
       {
	 _NFMdebug ((fname, "data list is empty\n")) ;
	 z = 0 ;
	 status = MEMopen (data_list, MEM_SIZE);
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
	    return (NFM_E_MEM);          
	  }
	
	/* Create data list if one has not already exist */
	for (x = 0; x < attr_list -> rows; ++x)
	  {
	    count = attr_list -> columns * x;
	    
	    status = MEMwrite_format (*data_list,
				      data [count + a], data [count + b]);
	    if (status != MEM_S_SUCCESS)
	      {
		MEMclose (data_list);
		MEMclose (value_list);
		
		ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		_NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
			    status));
		return (NFM_E_MEM);          
	      }
	  }
	
	sql_str = (char *) malloc ((*data_list) -> row_size);
	if (! sql_str)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
	    
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	    _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
			NFM_E_MALLOC));
	    return (NFM_E_MALLOC);          
	  }
	sql_str [0] = 0;
        for (y = 0; y < (*data_list) -> columns; ++y)
           strcat (sql_str, "\1");

	 status = MEMwrite (*data_list, sql_str);
	 if (status != MEM_S_SUCCESS)
	   {
	     free (sql_str);
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);          
	   }
	 free (sql_str);
       }

     for (x=z; x<attr_list->rows ; ++x) 
       {
	 status = MEMwrite_data (attr_list, "0", x+1, c+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",status));
	     return (NFM_E_MEM);          
	   }

	 status = MEMwrite_data (attr_list, "0", x+1, d+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", 
			 status));
	     return (NFM_E_MEM);          
	   }
       }

     status = MEMbuild_array (attr_list) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Build Array (attr_list) : < 0x%.8x >\n", 
		     status));
	 return (NFM_E_MEM);          
       }

     data   = (char **) attr_list -> data_ptr;

    /* Get default values for the data list and value list buffers */


     comma = 0 ;

     sql_str1 = (char *) malloc (200 + 60 * attr_list->rows) ;
     
     if (!sql_str1) 
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attr_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str1)"));
	 return (NFM_E_MALLOC);          
       }

     sql_str  = (char *) malloc (200 + 60 * attr_list-> rows) ;

     if (!sql_str)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attr_list) ;
	 free (sql_str1) ;
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str)"));
	 return (NFM_E_MALLOC);          
       }


     sprintf (sql_str1, "SELECT %s FROM NFMVALUES WHERE (n_type = 'C' OR n_type = 'A') AND (",
	      "n_attrno, n_type, n_defaultvalue, n_defaultno, n_minvalue, n_maxvalue, n_listno, n_programno") ;
 	      
     sql_str[0] = 0 ;

     for (x = z; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 
	 if (comma)
	   strcat (sql_str, " OR ") ;
	 comma = 1 ;
	 sprintf (tmp_str, "n_attrno = %s", data[count + h]) ;
	 strcat (sql_str, tmp_str) ;
       } 
     
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by n_attrno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &attrs, MEM_SIZE) ;

     if (status != SQL_S_SUCCESS) 
       {
	 if ((status ) == SQL_I_NO_ROWS_FOUND)
	   {
	     MEMclose (&attrs) ;
	     _NFMdebug ((fname, "No Rows found\n"));
	     return (NFM_S_SUCCESS);                 
	   }
	 MEMclose (data_list) ;
	 MEMclose (value_list) ;
	 MEMclose (&attr_list) ;
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >", status));
	 return (NFM_E_SQL_QUERY) ;
       }

     comma = 0 ;

    sprintf (sql_str1, "SELECT %s FROM NFMVALUES a, NFMLISTS b WHERE (a.n_type = 'C' OR a.n_type = 'A') AND (a.n_listno = b.n_listno) AND (",
              "a.n_attrno, a.n_listno, b.n_value, b.n_value2") ;

     sql_str[0] = 0 ;

     for (x = z; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 
	 if (comma)
	   strcat (sql_str, " OR ") ;
	 comma = 1 ;
	 sprintf (tmp_str, "a.n_attrno = %s", data[count + h]) ;
	 strcat (sql_str, tmp_str) ;
       } 
     
	
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by a.n_attrno, a.n_listno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &list_buffer, MEM_SIZE) ;

     free (sql_str1) ;
     free (sql_str) ;

     if ((status != SQL_S_SUCCESS)  && (status != SQL_I_NO_ROWS_FOUND))
       {
	 MEMclose (data_list) ;
	 MEMclose (value_list) ;
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >", status));
	 return (NFM_E_SQL_QUERY) ;
       }

     list_values_exist = 1 ;
     if (status == SQL_I_NO_ROWS_FOUND)
       {
	 list_values_exist = 0 ;
       }

     status = MEMbuild_array (attrs) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (list_buffer) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (*data_list) ;
     if (status != MEM_S_SUCCESS)
       {
         MEMclose (&temp_list);
         MEMclose (data_list);
         MEMclose (value_list);

         MEMclose (&attrs) ;

         _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
                   status));
         return (NFM_E_MEM);
       }

      data2 = (char **) attrs->data_ptr ;

     for (y = 0; y <attrs->rows; y++)
       {
	 row_offset = y*attrs->columns ;
	 
	 strcpy (value, data2 [row_offset + 2]) ;
         if (list_values_exist)
	   {
	     status = _NFMget_value_list2 (atol (data2 [row_offset]), /*attrno */
				     data2 [row_offset + 1], /* type */
				     data2 [row_offset + 4], /* minvalue*/
				     data2 [row_offset + 5], /* maxvalue */
				     atol(data2 [row_offset+3]), /*defno*/
				     atol(data2 [row_offset+6]), /*listno*/
				     atol(data2 [row_offset+7]), /*progno*/
				     value, &temp_list,
				     list_buffer) ;

	 if (status != NFM_S_SUCCESS && status != NFM_E_NO_ATTR_INFO)
	   {
	     MEMclose (&temp_list);
	     MEMclose (&attrs) ;
	     MEMclose (data_list);
	     MEMclose (value_list);
	     
	     _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
		       status));
	     return (status);          
	   }
	   }
else
{
status = NFM_S_SUCCESS ;
}	 
	 /* get row in attr/column in data list */
	 for (x=0; x<attr_list->rows; x++)
	   {
	     count = x*attr_list->columns ;
	     if (strcmp (data2 [row_offset], data [count +h]) == 0)
	       break ;
	   }
	 
	 if (x != attr_list->rows)
	   {
	     if (status != NFM_E_NO_ATTR_INFO)
	       {
		 if (strlen (value))
		   {
		     status = MEMwrite_data (*data_list, value, 1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&temp_list);
			 MEMclose (&attrs);
			 MEMclose (data_list);
			 MEMclose (value_list);
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }
		 
		 if (temp_list)
		   {
		     if (! (*value_list))
		       {
			 status = MEMsplit_copy_buffer (temp_list, value_list, 0);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Copy Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
		     else
		       {
			 status = MEMappend (temp_list, *value_list);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Append Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
		     
		     status = MEMclose (&temp_list);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list);
			 MEMclose (value_list);
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		     
		     status = MEMno_buffers (*value_list, &no_buffers);
		     sprintf (no_buff, "%d", no_buffers);
		     if (strcmp (data2 [row_offset +1], "C") == 0)
		       offset = c ;
		     else 
		       if (strcmp (data2 [row_offset +1], "A") == 0)
			 offset = d ;
		     status = MEMwrite_data (attr_list, no_buff, 
					     x + 1, offset + 1) ;
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list) ;
			 MEMclose (value_list) ;
			 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Write Data : < 0x%.8x >",
				     status));
			 return (NFM_E_MEM) ;
		       }
		   }
	       }
	   }
	 else
	   {
	     MEMclose (data_list) ;
	     MEMclose (value_list) ;
	     MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
	     _NFMdebug ((fname, "Corrupted System : < 0x%.8x >\n",
		       NFM_E_CORRUPTED_SYSTEM) );
	     return (NFM_E_CORRUPTED_SYSTEM) ;
	   }
       }
     
     MEMclose (&attrs) ;
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
  }


 long _NFMget_data_value (attr_list, data_list, value_list)
   MEMptr   attr_list;     /*  modified - attribute buffer */
   MEMptr   *data_list;    /*  modified - data buffer */
   MEMptr   *value_list;   /*  modified - value list */
   {
     static char *fname = "_NFMget_data_value" ;
     long    status, atol ();
     long    x, y, z, count ;
     long    a, b, c, d, e, f, g, h ;
     long    no_buffers ;
     MEMptr  temp_list = NULL;
     char    **column, **data, **data1, **data2 ;
     char    *sql_str, *sql_str1, tmp_str[100] ;
     char    value [100] ;
     long    _NFMget_value_list ();
     MEMptr  attrs = NULL, list_buffer = NULL ;
     char    no_buff [10] ;
     int     comma, row_offset, offset ;
     long    list_values_exist;

     /* The attr_list buffer received get offsets for
        n_name, n_datatype, etc */

     _NFMdebug ((fname, "ENTER\n")) ;

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (data_list);
        MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; b = -1; c = -1; d = -1; e = -1; f = -1; g = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
         else if (! strcmp (column [y], "n_valueno"))   c = y;
         else if (! strcmp (column [y], "n_adviceno"))  d = y;
         else if (! strcmp (column [y], "n_read"))      e = y;
         else if (! strcmp (column [y], "n_write"))     f = y;
         else if (! strcmp (column [y], "n_update"))    g = y;
         else if (! strcmp (column [y], "n_attrno"))    h = y;
      }

     z = 0;

     /* if data_list existed recover data, otherwise put empty row */

     if (*data_list)
      {

	sql_str = (char *) malloc ((*data_list) -> row_size);
	if (! sql_str)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	    _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
			NFM_E_MALLOC));
	    return (NFM_E_MALLOC);          
	  }
	sql_str [0] = 0;
        status = MEMbuild_array (*data_list);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (&temp_list);
           MEMclose (data_list);
           MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }

        z = (*data_list) -> columns;

        data1 = (char **) (*data_list) -> data_ptr;

        sql_str [0] = 0;

        for (y = 0; y < temp_list -> columns; ++y)
         {
           if (y < (*data_list) -> columns)  strcat (sql_str, data1 [y]);

           strcat (sql_str, "\1");
         }

        status = MEMclose (data_list);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (&temp_list);
           MEMclose (data_list);
           MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
	status = MEMsplit_copy_buffer (temp_list, data_list, 0);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (&temp_list);
	    MEMclose (data_list);
	    MEMclose (value_list);
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Split Copy : status = <0x%.8x>\n",
			status));
	    return (NFM_E_MEM);          
	  }
     
	status = MEMclose (&temp_list);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
	    return (NFM_E_MEM);          
	  }
      }
     else
       {
	 _NFMdebug ((fname, "data list is NULL\n")) ;
	status = MEMopen (data_list, MEM_SIZE);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
	    return (NFM_E_MEM);          
	  }
	
	
	 /* Create data list if one has not already exist */
	 for (x = 0; x < attr_list -> rows; ++x)
	   {
	     count = attr_list -> columns * x;
	     
	     status = MEMwrite_format (*data_list,
				       data [count + a], data [count + b]);
	     if (status != MEM_S_SUCCESS)
	       {
		 MEMclose (data_list);
		 MEMclose (value_list);
		 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		 _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
			     status));
		 return (NFM_E_MEM);          
	      }
	   }
	
	 sql_str = (char *) malloc ((*data_list) -> row_size);
	 if (! sql_str)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	    _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
			NFM_E_MALLOC));
	    return (NFM_E_MALLOC);          
	  }

         sql_str [0] = 0 ;
	 for (y = 0; y < (*data_list) -> columns; ++y) strcat (sql_str, "\1");

	 status = MEMwrite (*data_list, sql_str);
	 if (status != MEM_S_SUCCESS)
	   {
	     free (sql_str);
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Write data_list : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);          
	   }
	 free (sql_str);
       }
     

     for (x=z; x<attr_list->rows ; ++x) 
       {
	 status = MEMwrite_data (attr_list, "0", x+1, c+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",status));
	     return (NFM_E_MEM);          
	   }
	 status = MEMwrite_data (attr_list, "0", x+1, d+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", 
			 status));
	     return (NFM_E_MEM);          
	   }
       }

     data   = (char **) attr_list -> data_ptr;

    /* Get default values for the data list and value list buffers */


     comma = 0 ;

     sql_str1 = (char *) malloc (200 + 60 * attr_list->rows) ;
     
     if (!sql_str1) 
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str1)"));
	 return (NFM_E_MALLOC);          
       }

     sql_str  = (char *) malloc (200 + 60 * attr_list-> rows) ;

     if (!sql_str)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 free (sql_str1) ;
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str)"));
	 return (NFM_E_MALLOC);          
       }


     sprintf (sql_str1, "SELECT %s FROM NFMVALUES WHERE (n_type = 'C' OR n_type = 'A') AND (",
	      "n_attrno, n_type, n_defaultvalue, n_defaultno, n_minvalue, n_maxvalue, n_listno, n_programno") ;
 	      
     sql_str[0] = 0 ;

     for (x = z; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 
	 if (comma)
	   strcat (sql_str, " OR ") ;
	 comma = 1 ;
	 sprintf (tmp_str, "n_attrno = %s", data[count + h]) ;
	 strcat (sql_str, tmp_str) ;
       } 
	
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by n_attrno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &attrs, MEM_SIZE) ;

     if (status != SQL_S_SUCCESS) 
       {
	 if ((status ) == SQL_I_NO_ROWS_FOUND)
	   {
	     MEMclose (&attrs) ;
	     _NFMdebug ((fname, "No Rows found"));
	     return (NFM_S_SUCCESS);                 
	   }
	 MEMclose (data_list) ;
	 MEMclose (value_list) ;
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >", status));
	 return (NFM_E_SQL_QUERY) ;
       }

/*     comma = 0 ; */
    sprintf (sql_str1, "SELECT %s FROM NFMVALUES a, NFMLISTS b WHERE (a.n_type = 'C' OR a.n_type = 'A') AND (a.n_listno = b.n_listno) AND (",
              "a.n_attrno, a.n_listno, b.n_value") ;

/** already done previously - mms 
     sql_str[0] = 0 ;
     for (x = z; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 
	 if (comma)
	   strcat (sql_str, " OR ") ;
	 comma = 1 ;
	 sprintf (tmp_str, "a.n_attrno = %s", data[count + h]) ;
	 strcat (sql_str, tmp_str) ;
       } 
****/     
	
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by a.n_attrno, a.n_listno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &list_buffer, MEM_SIZE) ;

     free (sql_str1) ;
     free (sql_str) ;

     if ((status != SQL_S_SUCCESS)  && (status != SQL_I_NO_ROWS_FOUND))
       {
	 MEMclose (data_list) ;
	 MEMclose (value_list) ;
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >", status));
	 return (NFM_E_SQL_QUERY) ;
       }

     list_values_exist = 1 ;
     if (status == SQL_I_NO_ROWS_FOUND)
       {
	 list_values_exist = 0 ;
       }

     status = MEMbuild_array (attrs) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (list_buffer) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (*data_list) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }
     
     data2 = (char **) attrs->data_ptr ;

     for (y = 0; y <attrs->rows; y++)
       {
	 row_offset = y*attrs->columns ;
	 
	 strcpy (value, data2 [row_offset + 2]) ;
	 
	 if (list_values_exist)
	   {
	     status = _NFMget_value_list (atol (data2 [row_offset]),
					  data2 [row_offset + 1], /* type */
					  data2 [row_offset + 4], /* minvalue*/
					  data2 [row_offset + 5], /* maxvalue */
					  atol(data2 [row_offset+3]), /*defno*/
					  atol(data2 [row_offset+6]), /*listno*/
					  atol(data2 [row_offset+7]), /*progno*/
					  value, &temp_list,
					  list_buffer) ;
	     
	     if (status != NFM_S_SUCCESS && status != NFM_E_NO_ATTR_INFO)
	       {
		 MEMclose (&temp_list);
		 MEMclose (&attrs) ;
		 MEMclose (data_list);
		 MEMclose (value_list);
		 
		 _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
			     status));
		 return (status);          
	       }
	   }
	 else
	   {
	     status = NFM_S_SUCCESS ;
	   }

	 /* get row in attr/column in data list */
	 for (x=0; x<attr_list->rows; x++)
	   {
	     count = x*attr_list->columns ;
	     if (strcmp (data2 [row_offset], data [count +h]) == 0)
	       break ;
	   }
	 
	 if (x != attr_list->rows)
	   {
	     if (status != NFM_E_NO_ATTR_INFO)
	       {
		 if (strlen (value))
		   {
		     status = MEMwrite_data (*data_list, value, 1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&temp_list);
			 MEMclose (&attrs);
			 MEMclose (data_list);
			 MEMclose (value_list);
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }
		 
		 if (temp_list)
		   {
		     if (! (*value_list))
		       {
			 status = MEMsplit_copy_buffer (temp_list, value_list, 0);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Copy Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
		     else
		       {
			 status = MEMappend (temp_list, *value_list);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Append Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
		     
		     status = MEMclose (&temp_list);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list);
			 MEMclose (value_list);
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		     
		     status = MEMno_buffers (*value_list, &no_buffers);
		     sprintf (no_buff, "%d", no_buffers);
		     if (strcmp (data2 [row_offset +1], "C") == 0)
		       offset = c ;
		     else 
		       if (strcmp (data2 [row_offset +1], "A") == 0)
			 offset = d ;
		     status = MEMwrite_data (attr_list, no_buff, 
					     x + 1, offset + 1) ;
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list) ;
			 MEMclose (value_list) ;
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Write Data : < 0x%.8x >",
				     status));
			 return (NFM_E_MEM) ;
		       }
		   }
	       }
	   }
	 else
	   {
	     MEMclose (data_list) ;
	     MEMclose (value_list) ;
	     MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
	     _NFMdebug ((fname, "Corrupted System : < 0x%.8x >\n",
		       NFM_E_CORRUPTED_SYSTEM) );
	     return (NFM_E_CORRUPTED_SYSTEM) ;
	   }
       }
     
     MEMclose (&attrs) ;
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
/*** only validate/advisory information for writable attributes ****/
 long _NFMget_data_value_w (attr_list, data_list, value_list)
   MEMptr   attr_list;     /*  modified - attribute buffer */
   MEMptr   *data_list;    /*  modified - data buffer */
   MEMptr   *value_list;   /*  modified - value list */
   {
     static char *fname = "_NFMget_data_value_w" ;
     long    status, atol ();
     long    x, y, z, count ;
     long    a, b, c, d, e, f, g, h ;
     long    no_buffers ;
     MEMptr  temp_list = NULL;
     char    **column, **data, **data1, **data2 ;
     char    *sql_str, *sql_str1, tmp_str[100] ;
     char    value [100] ;
     long    _NFMget_value_list ();
     MEMptr  attrs = NULL, list_buffer = NULL ;
     char    no_buff [10] ;
     int     comma, row_offset, offset ;
     long    list_values_exist;

     /* The attr_list buffer received get offsets for
        n_name, n_datatype, etc */

     _NFMdebug ((fname, "ENTER\n")) ;

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (data_list);
        MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; b = -1; c = -1; d = -1; e = -1; f = -1; g = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
         else if (! strcmp (column [y], "n_valueno"))   c = y;
         else if (! strcmp (column [y], "n_adviceno"))  d = y;
         else if (! strcmp (column [y], "n_read"))      e = y;
         else if (! strcmp (column [y], "n_write"))     f = y;
         else if (! strcmp (column [y], "n_update"))    g = y;
         else if (! strcmp (column [y], "n_attrno"))    h = y;
      }

     z = 0;

     /* if data_list existed recover data, otherwise put empty row */

     if (*data_list)
      {

	sql_str = (char *) malloc ((*data_list) -> row_size);
	if (! sql_str)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	    _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
			NFM_E_MALLOC));
	    return (NFM_E_MALLOC);          
	  }
	sql_str [0] = 0;
        status = MEMbuild_array (*data_list);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (&temp_list);
           MEMclose (data_list);
           MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }

        z = (*data_list) -> columns;

        data1 = (char **) (*data_list) -> data_ptr;

        sql_str [0] = 0;

        for (y = 0; y < temp_list -> columns; ++y)
         {
           if (y < (*data_list) -> columns)  strcat (sql_str, data1 [y]);

           strcat (sql_str, "\1");
         }

        status = MEMclose (data_list);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (&temp_list);
           MEMclose (data_list);
           MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
	status = MEMsplit_copy_buffer (temp_list, data_list, 0);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (&temp_list);
	    MEMclose (data_list);
	    MEMclose (value_list);
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Split Copy : status = <0x%.8x>\n",
			status));
	    return (NFM_E_MEM);          
	  }
     
	status = MEMclose (&temp_list);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
	    return (NFM_E_MEM);          
	  }
      }
     else
       {
	 _NFMdebug ((fname, "data list is NULL\n")) ;
	status = MEMopen (data_list, MEM_SIZE);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
	    return (NFM_E_MEM);          
	  }
	
	
	 /* Create data list if one has not already exist */
	 for (x = 0; x < attr_list -> rows; ++x)
	   {
	     count = attr_list -> columns * x;
	     
	     status = MEMwrite_format (*data_list,
				       data [count + a], data [count + b]);
	     if (status != MEM_S_SUCCESS)
	       {
		 MEMclose (data_list);
		 MEMclose (value_list);
		 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		 _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
			     status));
		 return (NFM_E_MEM);          
	      }
	   }
	
	 sql_str = (char *) malloc ((*data_list) -> row_size);
	 if (! sql_str)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	    _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
			NFM_E_MALLOC));
	    return (NFM_E_MALLOC);          
	  }
	
	 for (y = 0; y < (*data_list) -> columns; ++y)
	  strcat (sql_str, "\1");
     
	 status = MEMwrite (*data_list, sql_str);
	 if (status != MEM_S_SUCCESS)
	   {
	     free (sql_str);
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);          
	   }
	 free (sql_str);
       }
     

     for (x=z; x<attr_list->rows ; ++x) 
       {
	 status = MEMwrite_data (attr_list, "0", x+1, c+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",status));
	     return (NFM_E_MEM);          
	   }
	 status = MEMwrite_data (attr_list, "0", x+1, d+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", 
			 status));
	     return (NFM_E_MEM);          
	   }
       }

     data   = (char **) attr_list -> data_ptr;

    /* Get default values for the data list and value list buffers */


     comma = 0 ;

     sql_str1 = (char *) malloc (200 + 60 * attr_list->rows) ;
     
     if (!sql_str1) 
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str1)"));
	 return (NFM_E_MALLOC);          
       }

     sql_str  = (char *) malloc (200 + 60 * attr_list-> rows) ;

     if (!sql_str)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 free (sql_str1) ;
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str)"));
	 return (NFM_E_MALLOC);          
       }


     sprintf (sql_str1, "SELECT %s FROM NFMVALUES WHERE (n_type = 'C' OR n_type = 'A') AND (",
	      "n_attrno, n_type, n_defaultvalue, n_defaultno, n_minvalue, n_maxvalue, n_listno, n_programno") ;
 	      
     sql_str[0] = 0 ;

     for (x = z; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 if (strcmp (data [count+f], "Y") == 0)
         {
	  if (comma)
	   strcat (sql_str, " OR ") ;
	  comma = 1 ;
	  sprintf (tmp_str, "n_attrno = %s", data[count + h]) ;
	  strcat (sql_str, tmp_str) ;
	}
       } 
	
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by n_attrno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &attrs, MEM_SIZE) ;

     if (status != SQL_S_SUCCESS) 
       {
	 if ((status ) == SQL_I_NO_ROWS_FOUND)
	   {
	     MEMclose (&attrs) ;
	     _NFMdebug ((fname, "No Rows found"));
	     return (NFM_S_SUCCESS);                 
	   }
	 MEMclose (data_list) ;
	 MEMclose (value_list) ;
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >", status));
	 return (NFM_E_SQL_QUERY) ;
       }

/*     comma = 0 ; */
    sprintf (sql_str1, "SELECT %s FROM NFMVALUES a, NFMLISTS b WHERE (a.n_type = 'C' OR a.n_type = 'A') AND (a.n_listno = b.n_listno) AND (",
              "a.n_attrno, a.n_listno, b.n_value") ;

/*
     sql_str[0] = 0 ;
     for (x = z; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 if (strcmp (data [count+f], "Y") == 0)
         {
	  if (comma)
	   strcat (sql_str, " OR ") ;
	  comma = 1 ;
	  sprintf (tmp_str, "a.n_attrno = %s", data[count + h]) ;
	  strcat (sql_str, tmp_str) ;
	}
       } 
*/     
	
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by a.n_attrno, a.n_listno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &list_buffer, MEM_SIZE) ;

     free (sql_str1) ;
     free (sql_str) ;

     if ((status != SQL_S_SUCCESS)  && (status != SQL_I_NO_ROWS_FOUND))
       {
	 MEMclose (data_list) ;
	 MEMclose (value_list) ;
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >", status));
	 return (NFM_E_SQL_QUERY) ;
       }

     list_values_exist = 1 ;
     if (status == SQL_I_NO_ROWS_FOUND)
       {
	 list_values_exist = 0 ;
       }

     status = MEMbuild_array (attrs) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (list_buffer) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (*data_list) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }
     
     data2 = (char **) attrs->data_ptr ;

     for (y = 0; y <attrs->rows; y++)
       {
	 row_offset = y*attrs->columns ;
	 
	 strcpy (value, data2 [row_offset + 2]) ;
	 
	 if (list_values_exist)
	   {
	     status = _NFMget_value_list (atol (data2 [row_offset]),
					  data2 [row_offset + 1], /* type */
					  data2 [row_offset + 4], /* minvalue*/
					  data2 [row_offset + 5], /* maxvalue */
					  atol(data2 [row_offset+3]), /*defno*/
					  atol(data2 [row_offset+6]), /*listno*/
					  atol(data2 [row_offset+7]), /*progno*/
					  value, &temp_list,
					  list_buffer) ;
	     
	     if (status != NFM_S_SUCCESS && status != NFM_E_NO_ATTR_INFO)
	       {
		 MEMclose (&temp_list);
		 MEMclose (&attrs) ;
		 MEMclose (data_list);
		 MEMclose (value_list);
		 
		 _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
			     status));
		 return (status);          
	       }
	   }
	 else
	   {
	     status = NFM_S_SUCCESS ;
	   }

	 /* get row in attr/column in data list */
	 for (x=0; x<attr_list->rows; x++)
	   {
	     count = x*attr_list->columns ;
	     if (strcmp (data2 [row_offset], data [count +h]) == 0)
	       break ;
	   }
	 
	 if (x != attr_list->rows)
	   {
	     if (status != NFM_E_NO_ATTR_INFO)
	       {
		 if (strlen (value))
		   {
		     status = MEMwrite_data (*data_list, value, 1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&temp_list);
			 MEMclose (&attrs);
			 MEMclose (data_list);
			 MEMclose (value_list);
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }
		 
		 if (temp_list)
		   {
		     if (! (*value_list))
		       {
			 status = MEMsplit_copy_buffer (temp_list, value_list, 0);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Copy Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
		     else
		       {
			 status = MEMappend (temp_list, *value_list);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Append Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
		     
		     status = MEMclose (&temp_list);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list);
			 MEMclose (value_list);
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		     
		     status = MEMno_buffers (*value_list, &no_buffers);
		     sprintf (no_buff, "%d", no_buffers);
		     if (strcmp (data2 [row_offset +1], "C") == 0)
		       offset = c ;
		     else 
		       if (strcmp (data2 [row_offset +1], "A") == 0)
			 offset = d ;
		     status = MEMwrite_data (attr_list, no_buff, 
					     x + 1, offset + 1) ;
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list) ;
			 MEMclose (value_list) ;
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Write Data : < 0x%.8x >",
				     status));
			 return (NFM_E_MEM) ;
		       }
		   }
	       }
	   }
	 else
	   {
	     MEMclose (data_list) ;
	     MEMclose (value_list) ;
	     MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
	     _NFMdebug ((fname, "Corrupted System : < 0x%.8x >\n",
		       NFM_E_CORRUPTED_SYSTEM) );
	     return (NFM_E_CORRUPTED_SYSTEM) ;
	   }
       }
     
     MEMclose (&attrs) ;
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }



 long NFMget_data_info (user_id, attr_list, data_list, value_list)
   long     user_id;       /*  input - user id */
   MEMptr   attr_list;     /*  modified - attribute buffer */
   MEMptr   *data_list;    /*  modified - data buffer */
   MEMptr   *value_list;   /*  modified - value list */
   {
     static char *fname = "NFMget_data_info" ;
     long    status, atol ();
     long    x, y, z, count; 
     long    a, b, c, d, e, f, g, h, no_buffers ;
     MEMptr  temp_list = NULL;
     char    **column, **data, **data1, **data2 ;
     char    *sql_str, *sql_str1, tmp_str[100] ;
     char    value [100] ;
     long    _NFMget_value_info ();
     MEMptr  attrs = NULL, list_buffer = NULL ;
     char    no_buff [10] ;
     int     comma, row_offset, offset ;
     long    list_values_exist ;


     /* The attr_list buffer received get offsets for
        n_name, n_datatype, etc */
     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (data_list);
        MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; b = -1; c = -1; d = -1; e = -1; f = -1; g = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
         else if (! strcmp (column [y], "n_valueno"))   c = y;
         else if (! strcmp (column [y], "n_adviceno"))  d = y;
         else if (! strcmp (column [y], "n_read"))      e = y;
         else if (! strcmp (column [y], "n_write"))     f = y;
         else if (! strcmp (column [y], "n_update"))    g = y;
	 else if (! strcmp (column [y], "n_attrno"))    h = y;
      }

     status = MEMopen (&temp_list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (data_list);
        MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);          
      }


     /* Create data list if one has not already exist */
     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        status = MEMwrite_format (temp_list,
                 data [count + a], data [count + b]);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&temp_list);

           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }

     sql_str = (char *) malloc (temp_list -> row_size);
     if (! sql_str)
      {
        MEMclose (&temp_list);

        MEMclose (data_list);
        MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		  NFM_E_MALLOC));
        return (NFM_E_MALLOC);          
      }
     sql_str [0] = 0;

     z = 0;

     /* if data_list existed recover data, otherwise put empty row */

     if (*data_list)
      {
        status = MEMbuild_array (*data_list);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);

           MEMclose (&temp_list);

           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }

        z = (*data_list) -> columns;

        data1 = (char **) (*data_list) -> data_ptr;

        sql_str [0] = 0;

        for (y = 0; y < temp_list -> columns; ++y)
         {
           if (y < (*data_list) -> columns)  strcat (sql_str, data1 [y]);

           strcat (sql_str, "\1");
         }

        status = MEMclose (data_list);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);

           MEMclose (&temp_list);

           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }
     else
      {
        for (y = 0; y < temp_list -> columns; ++y)
           strcat (sql_str, "\1");
      }

     status = MEMwrite (temp_list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);

        MEMclose (&temp_list);

        MEMclose (data_list);
        MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     free (sql_str);

     status = MEMsplit_copy_buffer (temp_list, data_list, 0);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&temp_list);

        MEMclose (data_list);
        MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Split Copy : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     status = MEMclose (&temp_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (data_list);
        MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);          
      }

     for (x=z; x<attr_list->rows ; ++x) 
       {
	 status = MEMwrite_data (attr_list, "0", x+1, c+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",status));
	     return (NFM_E_MEM);          
	   }
	 status = MEMwrite_data (attr_list, "0", x+1, d+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", status));
	     return (NFM_E_MEM);          
	   }
       }


     status = MEMbuild_array (attr_list) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Build Array (attr list) : < 0x%.8x >\n", 
		     status));
	 return (NFM_E_MEM);          
       }

     data   = (char **) attr_list -> data_ptr;


    /* Get default values for the data list and value list buffers */


     sql_str1 = (char *) malloc (200 + 60 * attr_list->rows) ;
     
     if (!sql_str1) 
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str1)"));
	 return (NFM_E_MALLOC);          
       }

     sql_str  = (char *) malloc (200 + 60 * attr_list-> rows) ;

     if (!sql_str)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 free (sql_str1) ;
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str)"));
	 return (NFM_E_MALLOC);          
       }

comma = 0 ;
     sprintf (sql_str1, "SELECT %s FROM NFMVALUES WHERE (n_type = 'C' OR n_type = 'A') AND (",
	      "n_attrno, n_type, n_defaultvalue, n_defaultno, n_minvalue, n_maxvalue, n_listno, n_programno") ;
 	      
     sql_str[0] = 0 ;

     for (x = z; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 
	 if (comma)
	   strcat (sql_str, " OR ") ;
	 comma = 1 ;
	 sprintf (tmp_str, "n_attrno = %s", data[count + c]) ;
	 strcat (sql_str, tmp_str) ;
       } 
	
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by n_attrno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &attrs, MEM_SIZE) ;

     if (status != SQL_S_SUCCESS) 
       {
	 if ((status) == SQL_I_NO_ROWS_FOUND)
	   {
	     MEMclose (&attrs) ;
	     _NFMdebug ((fname, "No Rows found"));
	     return (NFM_S_SUCCESS);                 
	   }
	 MEMclose (data_list) ;
	 MEMclose (value_list) ;
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >\n", status));
	 return (NFM_E_SQL_QUERY) ;
       }

comma = 0 ;
    
    sprintf (sql_str1, "SELECT %s FROM NFMVALUES a, NFMLISTS b WHERE (a.n_type = 'C' OR a.n_type = 'A') AND (a.n_listno = b.n_listno) AND (",
              "a.n_attrno, a.n_listno, b.n_value") ;

      sql_str[0] = 0 ;

     for (x = z; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 
	 if (comma)
	   strcat (sql_str, " OR ") ;
	 comma = 1 ;
	 sprintf (tmp_str, "a.n_attrno = %s", data[count + c]) ;
	 strcat (sql_str, tmp_str) ;
       } 
	
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by a.n_attrno, a.n_listno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &list_buffer, MEM_SIZE) ;

     free (sql_str1) ;
     free (sql_str) ;

     if ((status != SQL_S_SUCCESS)  && (status != SQL_I_NO_ROWS_FOUND))
       {
	 MEMclose (data_list) ;
	 MEMclose (value_list) ;
	 MEMclose (&attrs) ;
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >\n", status));
	 return (NFM_E_SQL_QUERY) ;
       }
     list_values_exist = 1 ;
     if (status == SQL_I_NO_ROWS_FOUND)
     {
        list_values_exist =0 ;
     }
     status = MEMbuild_array (attrs) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (list_buffer) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (*data_list) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }
     
     data2 = (char **) attrs->data_ptr ;
     
     for (y = 0; y <attrs->rows; y++)
       {
	 row_offset = y*attrs->columns ;
	 
	 strcpy (value, data2 [row_offset + 2]) ;
	 if (list_values_exist)
	   {
	     status = _NFMget_value_info (atol (data2 [row_offset]),
				       data2 [row_offset + 1], /* type */
					  data2 [row_offset + 4], /* minvalue*/
					  data2 [row_offset + 5], /* maxvalue */
					  atol(data2 [row_offset+3]), /*defno*/
					  atol(data2 [row_offset+6]), /*listno*/
					  atol(data2 [row_offset+7]), /*progno*/
					  value, &temp_list,
					  list_buffer) ;
	     
	     if (status != NFM_S_SUCCESS && status != NFM_E_NO_ATTR_INFO)
	       {
		 MEMclose (&temp_list);
		 MEMclose (&attrs) ;
		 MEMclose (data_list);
		 MEMclose (value_list);
		 
		 _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
			     status));
		 return (status);          
	       }
	   }
	 else 
	   {
	     status = NFM_S_SUCCESS ;
	   }

	 /* get row in attr/column in data list */
	 for (x=0; x<attr_list->rows; x++)
	   {
	     count = x*attr_list->columns ;
	     if (strcmp (data2 [row_offset], data [count +h]) == 0)
	       break ;
	   }
	 
	 if (x != attr_list->rows)
	   {
	     if (status != NFM_E_NO_ATTR_INFO)
	       {
		 if (strlen (value))
		   {
		     status = MEMwrite_data (*data_list, value, 1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&temp_list);
			 MEMclose (&attrs);
			 MEMclose (data_list);
			 MEMclose (value_list);
			 
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }
		 
		 if (temp_list)
		   {
		     if (! (*value_list))
		       {
			 status = MEMsplit_copy_buffer (temp_list, value_list, 0);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Copy Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
		     else
		       {
			 status = MEMappend (temp_list, *value_list);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Append Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
			 
		     status = MEMclose (&temp_list);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list);
			 MEMclose (value_list);
			 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		     
		     status = MEMno_buffers (*value_list, &no_buffers);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list) ;
			 MEMclose (value_list) ;
			 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEMno_buffers : < 0x%.8x >\n",
				     status));
			 return (NFM_E_MEM) ;
		       }
		     sprintf (no_buff, "%d", no_buffers);
		     if (strcmp (data2 [row_offset +1], "C") == 0)
		       offset = c ;
		     else 
		       if (strcmp (data2 [row_offset +1], "A") == 0)
			 offset = d ;
		     status = MEMwrite_data (attr_list, no_buff, 
					     x + 1, offset + 1) ;
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list) ;
			 MEMclose (value_list) ;
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Write Data : < 0x%.8x >\n",
				     status));
			 return (NFM_E_MEM) ;
		       }
		   }
	       }
	   }
	 else
	   {
	     MEMclose (data_list) ;
	     MEMclose (value_list) ;
	     MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
	     _NFMdebug ((fname, "Corrupted Buffers : < 0x%.8x >\n",
		       NFM_E_CORRUPTED_SYSTEM));
	     return (NFM_E_CORRUPTED_SYSTEM) ;
	   }
       }
     

     MEMclose (&attrs) ;

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


 long _NFMget_value_list (attrno,
			 type, min_value, max_value,
			 def_no, list_no, prog_no,
			 def_value, list, list_buffer)
   long     attrno ;
   char     *type, *min_value, *max_value ;
   long     def_no, list_no, prog_no ;
   char     *def_value;
   MEMptr   *list;
   MEMptr   list_buffer ;
   {
     static char *fname = "_NFMget_value_list" ;
     long      status, atol ();
     long      _NFMget_list_list ();
     long      NFMget_range_list ();
     long      NFMget_program_list ();
     long      NFMget_program_value ();

     _NFMdebug ((fname, "Type       = <%s>  : Min Value = <%s> : Max Value = <%s> : Default No = <%d> : List No = <%d> : Program No = <%d> : Def Value = <%s>\n", 
		 type, min_value, max_value, def_no, list_no, prog_no,
		 def_value));

     if (! strcmp (type, "C"))
      {
        if (def_no > 0 && (! strlen (def_value)))
         {
           status = NFMget_program_value (NFMglobal.NFMuserid,
                    def_no, def_value);
           if (status != NFM_S_SUCCESS)
            {
              MEMclose (list);
              _NFMdebug ((fname, "Get Prog Value : status = <0x%.8x>\n",
              status));
              return (status);        
            }
         }
      }

     if (strlen (min_value) || strlen (max_value))
      {
        status = NFMget_range_list (NFMglobal.NFMuserid,
				    min_value, max_value, list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (list);
           _NFMdebug ((fname, "Get Range List : status = <0x%.8x>\n",
           status));
           return (status);        
         }
      }
     else if (list_no > 0)
      {
        status = _NFMget_list_list (attrno, list_no, list, list_buffer);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (list);
           _NFMdebug ((fname, "Get Static List : status = <0x%.8x>\n",
           status));
           return (status);        
         }
      }
     else if (prog_no > 0)
      {
        status = NFMget_program_list (NFMglobal.NFMuserid, prog_no, list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (list);
           _NFMdebug ((fname, "Get Prog List : status = <0x%.8x>\n",
           status));
           return (status);        
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long _NFMget_value_list2 (attrno,
			 type, min_value, max_value,
			 def_no, list_no, prog_no,
			 def_value, list, list_buffer)
   long     attrno ;
   char     *type, *min_value, *max_value ;
   long     def_no, list_no, prog_no ;
   char     *def_value;
   MEMptr   *list;
   MEMptr   list_buffer ;
   {
     static char *fname = "_NFMget_value_list2" ;
     long      status, atol ();
     long      _NFMget_list_list ();
     long      NFMget_range_list ();
     long      NFMget_program_list ();
     long      NFMget_program_value ();

     _NFMdebug ((fname, "Type       = <%s>  : Min Value = <%s> : Max Value = <%s> : Default No = <%d> : List No = <%d> : Program No = <%d> : Def Value = <%s>\n", 
		 type, min_value, max_value, def_no, list_no, prog_no,
		 def_value));

     if (! strcmp (type, "C"))
      {
        if (def_no > 0 && (! strlen (def_value)))
         {
           status = NFMget_program_value (NFMglobal.NFMuserid,
                    def_no, def_value);
           if (status != NFM_S_SUCCESS)
            {
              MEMclose (list);
              _NFMdebug ((fname, "Get Prog Value : status = <0x%.8x>\n",
              status));
              return (status);        
            }
         }
      }

     if (strlen (min_value) || strlen (max_value))
      {
        status = NFMget_range_list (NFMglobal.NFMuserid,
				    min_value, max_value, list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (list);
           _NFMdebug ((fname, "Get Range List : status = <0x%.8x>\n",
           status));
           return (status);        
         }
      }
     else if (list_no > 0)
      {
        status = _NFMget_list_list2 (attrno, list_no, list, list_buffer);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (list);
           _NFMdebug ((fname, "Get Static List : status = <0x%.8x>\n",
           status));
           return (status);        
         }
      }
     else if (prog_no > 0)
      {
        status = NFMget_program_list (NFMglobal.NFMuserid, prog_no, list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (list);
           _NFMdebug ((fname, "Get Prog List : status = <0x%.8x>\n",
           status));
           return (status);        
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }


 long NFMget_range_list (user_id, min, max, list)
   long     user_id;
   char     *min, *max;
   MEMptr   *list;
   {
     static char *fname = "NFMget_range_list" ;
     long    status;
     char    sql_str [512];

     _NFMdebug ((fname, "Min = <%s> : Max = <%s>\n", 
		 min, max));
     user_id = user_id ;
     status = MEMopen (list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMwrite_format (*list, "n_minvalue", "char(40)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write For : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     status = MEMwrite_format (*list, "n_maxvalue", "char(40)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write For : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     
     sql_str [0] = 0;
     strcpy (sql_str, min);  strcat (sql_str, "\1");
     strcat (sql_str, max);  strcat (sql_str, "\1");


     status = MEMwrite (*list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long _NFMget_list_list (attrno, list_no, list, list_buffer)
   long     attrno ;
   long     list_no ;
   MEMptr   *list;
   MEMptr   list_buffer ;
   {
     static char *fname= "_NFMget_list_list" ;
     long    status, break_point, x, offset, atol() ;
     char    sql_str [512], **data ;
     char    datatype [30] ;

     _NFMdebug ((fname, "Attrno = <%d> : List No = <%d>\n", 
		 attrno, list_no));

     _NFMdebug ((fname, "opening list\n")) ;
     status = MEMopen (list, MEM_SIZE) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMopen : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     sprintf (datatype, "char(%d)", NFM_VALUE) ;
     _NFMdebug ((fname, "MEMwrite format %s %s\n", "n_value", datatype)) ;
     status = MEMwrite_format (*list, "n_value", datatype) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     data = (char **) list_buffer -> data_ptr;

     break_point = 0 ;
     for (x = 0; x < list_buffer -> rows; ++x)
      {
	offset = x *list_buffer->columns ;
/*	_NFMdebug ((fname, "comparing %d : %s and %d : %s\n",
		    list_no, data [offset+1], attrno, data [offset])) ; 
*/
	if ((list_no == atol (data [offset+1])) && 
	     (attrno == atol (data [offset])))
	  {
	    break_point = 1 ;
	    sql_str [0] = 0;
	    
	    strcat (sql_str, data [offset+2]);     strcat (sql_str, "\1");
	    
	    status = MEMwrite (*list, sql_str);
	    if (status != MEM_S_SUCCESS)
	      {
		MEMclose (list);
		ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		_NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			    status));
		return (NFM_E_MEM); 
	      }
	  }
	else
	  {
	    if (break_point) break ;
	  }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long _NFMget_list_list2 (attrno, list_no, list, list_buffer)
   long     attrno ;
   long     list_no ;
   MEMptr   *list;
   MEMptr   list_buffer ;
   {
     static char *fname= "_NFMget_list_list2" ;
     long    status, break_point, x, offset, atol() ;
     char    sql_str [512], **data ;
     char    datatype [30] ;

     _NFMdebug ((fname, "Attrno = <%d> : List No = <%d>\n", 
		 attrno, list_no));

     _NFMdebug ((fname, "opening list\n")) ;
     status = MEMopen (list, MEM_SIZE) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMopen : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     sprintf (datatype, "char(%d)", NFM_VALUE) ;

     status = MEMwrite_format (*list, "n_value", datatype) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     sprintf (datatype, "char(%d)", NFM_VALUE2) ;

     status = MEMwrite_format (*list, "n_value2", datatype) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     data = (char **) list_buffer -> data_ptr;

     break_point = 0 ;
     for (x = 0; x < list_buffer -> rows; ++x)
      {
	offset = x *list_buffer->columns ;
/*	_NFMdebug ((fname, "comparing %d : %s and %d : %s\n",
		    list_no, data [offset+1], attrno, data [offset])) ; 
*/
	if ((list_no == atol (data [offset+1])) && 
	     (attrno == atol (data [offset])))
	  {
	    break_point = 1 ;
	    sql_str [0] = 0;
	    
	    strcat (sql_str, data [offset+2]);     strcat (sql_str, "\1");
	    strcat (sql_str, data [offset+3]);     strcat (sql_str, "\1");
	    
	    status = MEMwrite (*list, sql_str);
	    if (status != MEM_S_SUCCESS)
	      {
		MEMclose (list);
		ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		_NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			    status));
		return (NFM_E_MEM); 
	      }
	  }
	else
	  {
	    if (break_point) break ;
	  }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


 long NFMget_program_list (user_id, program_no, list)
   long     user_id;
   long     program_no;
   MEMptr   *list;
   {
     static char *fname = "NFMget_program_list" ;
     list = list ;
     user_id = user_id ;
     _NFMdebug ((fname, "Program No = <%d>\n", program_no));
     
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMget_program_value (user_id, program_no, value)
   long     user_id;
   long     program_no;
   char     *value;
   {
     static char *fname = "NFMget_program_value" ;
     value [0] = 0;

     _NFMdebug ((fname, "Program No = <%d> :Value = <%s>\n", 
		 program_no, value));
     user_id = user_id ;
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMget_range_info (user_id, min, max, list)
   long     user_id;
   char     *min, *max;
   MEMptr   *list;
   {
     static char *fname = "NFMget_range_info" ;
     long     status;
     char     sql_str [1024];
     long     NFMbuild_attr_list ();

     _NFMdebug ((fname, "Min  = <%s>  : Max = <%s>\n", 
		 min , max));
     user_id = user_id ;
     status = NFMbuild_attr_list (list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (list);
        _NFMdebug ((fname, "Build Attr List : status = <0x%.8x>\n",
        status));
        return (status); 
      }

     sql_str [0] = 0;

     strcpy (sql_str, "NFM_RANGE"); strcat (sql_str, "\1");
     strcat (sql_str, min);         strcat (sql_str, "\1");
     strcat (sql_str, max);         strcat (sql_str, "\1");
                                    strcat (sql_str, "\1");
                                    strcat (sql_str, "\1");
                                    strcat (sql_str, "\1");
                                    strcat (sql_str, "\1");
                                    strcat (sql_str, "\1");

     status = MEMwrite (*list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",status));
        return (NFM_E_MEM); 
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", 
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS); 
   }

 long NFMget_list_info (user_id, list_no, list)
   long     user_id;
   long     list_no;
   MEMptr   *list;
   {
     static char *fname = "NFMget_list_info" ;
     long     status;
     MEMptr   temp_list = NULL;
     char     sql_str [1024];
     char     **data;
     long     x;
     long     NFMbuild_attr_list ();

     _NFMdebug ((fname, "List No = <%d>\n", list_no));
     user_id= user_id ;
     sprintf (sql_str, "SELECT n_value FROM %s WHERE %s = %d", 
              "NFMLISTS", "n_listno", list_no);

     status = SQLquery (sql_str, &temp_list, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&temp_list);
 
        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
            ERRload_struct (NFM, NFM_E_BAD_LIST, "", NULL);
           _NFMdebug ((fname, "No Such List : status = <0x%.8x>\n",
           NFM_E_BAD_LIST));
           return (NFM_E_BAD_LIST);
         }

            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY);
      }

     status = MEMbuild_array (temp_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&temp_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM); 
      }

     status = NFMbuild_attr_list (list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (list);
        MEMclose (&temp_list);
        _NFMdebug ((fname, "Build Attr List : status = <0x%.8x>\n",
        status));
        return (status); 
      }

     data = (char **) temp_list -> data_ptr;

     for (x = 0; x < temp_list -> rows; ++x)
      {
        sql_str [0] = 0;

        strcpy (sql_str, "NFM_STATIC"); strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
        strcat (sql_str, data [x]);     strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");

        status = MEMwrite (*list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (list);
           MEMclose (&temp_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM); 
         }
      }

     status = MEMclose (&temp_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",status));
        return (NFM_E_MEM); 
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS); 
   }


 long NFMget_program_info (user_id, program_no, list)
   long     user_id;
   long     program_no;
   MEMptr   *list;
   {
     static char *fname = "NFMget_program_info" ;
     long     status;
     char     sql_str [1024];
     char     program_name [50];
     long     NFMbuild_attr_list ();

     _NFMdebug ((fname, "Program No = <%d>\n", program_no));

     status = NFMget_program_name (user_id, program_no, program_name);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Prog Name : status = <0x%.8x>\n",
        status));
        return (status); 
      }

     status = NFMbuild_attr_list (list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (list);
        _NFMdebug ((fname, "Build Attr List : status = <0x%.8x>\n",
        status));
        return (status); 
      }

     sql_str [0] = 0;

     strcpy (sql_str, "NFM_PROGRAM");  strcat (sql_str, "\1");
                                       strcat (sql_str, "\1");
                                       strcat (sql_str, "\1");
                                       strcat (sql_str, "\1");
     strcat (sql_str, program_name);   strcat (sql_str, "\1");
                                       strcat (sql_str, "\1");
                                       strcat (sql_str, "\1");
                                       strcat (sql_str, "\1");

     status = MEMwrite (*list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (NFM_E_MEM); 
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS); 
   }

 long NFMget_program_value_info (user_id, program_no, list)
   long     user_id;
   long     program_no;
   MEMptr   *list;
   {
     static char *fname = "NFMget_program_value_info" ;
     long     status;
     char     program_name [50];
     char     *sql_str [1024];
     long     NFMbuild_attr_list ();

     _NFMdebug ((fname, "Program No = <%d>\n", program_no));

     status = NFMget_program_name (user_id, program_no, program_name);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Prog Name : status = <0x%.8x>\n",
         status));
        return (status); 
      }

     status = NFMbuild_attr_list (list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (list);
        _NFMdebug ((fname, "Build Attr List : status = <0x%.8x>\n",
        status));
        return (status); 
      }

     sql_str [0] = 0;

     strcpy (sql_str, "NFM_DEFAULT");   strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
     strcat (sql_str, program_name);    strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");

     status = MEMwrite (*list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (NFM_E_MEM); 
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS); 
   }

 long NFMbuild_attr_list (list)
   MEMptr   *list;
   {
     static char *fname = "NFMbuild_attr_list" ;
     long     status;

     if (! (*list))
      {
	_NFMdebug ((fname, "Building buffer\n")) ;
         status = MEMopen (list, MEM_SIZE); 
         if (status != MEM_S_SUCCESS)
          {
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_input", "char(20)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_minvalue", "char(4)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_maxvalue", "char(40)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_value", "char(40)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_filename", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_type", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_appname", "char(3)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_apptype", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }
      }
 
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS); 
   }
 long _NFMget_data_info (attr_list, data_list, value_list)
   MEMptr   attr_list;     /*  modified - attribute buffer */
   MEMptr   *data_list;    /*  modified - data buffer */
   MEMptr   *value_list;   /*  modified - value list */
{
    static char *fname = "_NFMget_data_info" ;
     long    status;
     long    x, y, count, atol () ;
     long    a, b, c, d, e, f, g, h, no_buffers ;
     char    **column, **data, **data2 ;
     char    *sql_str, *sql_str1, tmp_str[100] ;
     char    value [100] ;
     long    _NFMget_value_info ();
     MEMptr  attrs = NULL ;
     MEMptr  temp_list = NULL ;
    MEMptr   list_buffer = NULL ;
     char    no_buff [10] ;
     int     comma, row_offset, offset ;
    long     list_values_exist ;

    _NFMdebug ((fname, "ENTER\n")) ;

     status = MEMbuild_array (attr_list) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMbuild_array (attr_list) : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_MEM) ;
       }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;
     
     a = -1; b = -1; c = -1; d = -1; e = -1; f = -1; g = -1;
     
     for (y = 0; y < attr_list -> columns; ++y)
       {
        	 if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))     b = y;
         else if (! strcmp (column [y], "n_valueno"))      c = y;
         else if (! strcmp (column [y], "n_adviceno"))     d = y;
         else if (! strcmp (column [y], "n_read"))         e = y;
         else if (! strcmp (column [y], "n_write"))        f = y;
         else if (! strcmp (column [y], "n_update"))       g = y;
         else if (! strcmp (column [y], "n_attrno"))       h = y;
       }

    _NFMdebug ((fname, "a %d b %d c%d\n",
		a, b, c)) ;

     status = MEMopen (data_list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
	 return (NFM_E_MEM);          
       }
     
     /* Create data list */
     
     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
	_NFMdebug ((fname, "column name %s format %s\n",
		    data[count +a], data[count+b])) ;

        status = MEMwrite_format (*data_list,
                 data [count + a], data [count + b]);
        if (status != MEM_S_SUCCESS)
         {
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }

     sql_str = (char *) malloc ((*data_list) -> row_size);
     if (! sql_str)
      {
	ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		    NFM_E_MALLOC));
        return (NFM_E_MALLOC);          
      }
     sql_str [0] = 0;
     
     for (y = 0; y < (*data_list) -> columns; ++y)
       strcat (sql_str, "\1");

     status = MEMwrite (*data_list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
	ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     free (sql_str);

     for (x=0; x<attr_list->rows ; ++x) 
       {
	 status = MEMwrite_data (attr_list, "0", x+1, c+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",status));
	     return (NFM_E_MEM);          
	   }
	 status = MEMwrite_data (attr_list, "0", x+1, d+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", status));
	     return (NFM_E_MEM);          
	   }
       }


     status = MEMbuild_array (attr_list) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Build Array (attr list) : < 0x%.8x >\n", 
		     status));
	 return (NFM_E_MEM);          
       }

     data   = (char **) attr_list -> data_ptr;

    /* Get default values for the data list and value list buffers */

     comma = 0 ;

     sql_str1 = (char *) malloc (200 + 60 * attr_list->rows) ;
     
     if (!sql_str1) 
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str1)"));
	 return (NFM_E_MALLOC);          
       }

     sql_str  = (char *) malloc (200 + 60 * attr_list-> rows) ;

     if (!sql_str)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 free (sql_str1) ;
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str)"));
	 return (NFM_E_MALLOC);          
       }


     sprintf (sql_str1, "SELECT %s FROM NFMVALUES WHERE (n_type = 'C' OR n_type = 'A') AND (",
	      "n_attrno, n_type, n_defaultvalue, n_defaultno, n_minvalue, n_maxvalue, n_listno, n_programno") ;

     sql_str[0] = 0 ;

     for (x = 0; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 if (!strcmp (data[count+h], "-1")) continue ;
	 if (comma)
	   strcat (sql_str, " OR ") ;
	 comma = 1 ;
	   sprintf (tmp_str, "n_attrno = %s", data[count + h]) ;
	 strcat (sql_str, tmp_str) ;
       } 
     
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by n_attrno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &attrs, MEM_SIZE) ;
     if (status != SQL_S_SUCCESS) 
       {
	 if ((status) == SQL_I_NO_ROWS_FOUND)
	   {
	     MEMclose (&attrs) ;
	     _NFMdebug ((fname, "No Rows found\n"));
	     return (NFM_S_SUCCESS);                 
	   }
	 MEMclose (&attrs) ;
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >\n", status));
	 return (NFM_E_SQL_QUERY) ;
       }
    
    comma = 0 ;

    sprintf (sql_str1, "SELECT %s FROM NFMVALUES a, NFMLISTS b WHERE (a.n_type = 'C' OR a.n_type = 'A') AND (a.n_listno = b.n_listno) AND (",
	      "a.n_attrno, a.n_listno, b.n_value") ;

     sql_str[0] = 0 ;

     for (x = 0; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 if (!strcmp (data[count+h], "-1")) continue ;
	 if (comma)
	   strcat (sql_str, " OR ") ;
	 comma = 1 ;
	   sprintf (tmp_str, "a.n_attrno = %s", data[count + h]) ;
	 strcat (sql_str, tmp_str) ;
       } 
     
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by a.n_attrno, a.n_listno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &list_buffer, MEM_SIZE) ;

     free (sql_str1) ;
     free (sql_str) ;

     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
       {
	 MEMclose (&attrs) ;
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >\n", status));
	 return (NFM_E_SQL_QUERY) ;
       }
    list_values_exist = 1 ;
    if (status ==  SQL_I_NO_ROWS_FOUND)
      {
	list_values_exist = 0 ;
      }
     status = MEMbuild_array (attrs) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&attrs) ;
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }
     

     status = MEMbuild_array (list_buffer) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&attrs) ;
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }
    
    status = MEMbuild_array (*data_list) ;
    if (status != MEM_S_SUCCESS)
      {
	_NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>|n",
		    status)) ;
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	return (NFM_E_MEM) ;
      }
    
     data2 = (char **) attrs->data_ptr ;
     
     for (y = 0; y <attrs->rows; y++)
       {
	 row_offset = y*attrs->columns ;
	 
	 strcpy (value, data2 [row_offset + 2]) ;
	 if (list_values_exist)
	   {
	     status = _NFMget_value_info (atol (data2[row_offset]),
					  data2 [row_offset + 1], 
					  data2 [row_offset + 4], 
					  data2 [row_offset + 5], 
					  atol(data2 [row_offset+3]),
					  atol(data2 [row_offset+6]),
					  atol(data2 [row_offset+7]),
					  value, &temp_list,
					  list_buffer);
	     
	     if (status != NFM_S_SUCCESS && status != NFM_E_NO_ATTR_INFO)
	       {
		 MEMclose (&attrs) ;
		 
		 _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
			     status));
		 return (status);          
	       }
	   }
	 else
	   {
	     status = NFM_S_SUCCESS ;
	   }
	 _NFMdebug ((fname, "get row in attr/columns\n")) ;
	 /* get row in attr/column in data list */
	 for (x=0; x<attr_list->rows; x++)
	   {
	     count = x*attr_list->columns ;
	     if (strcmp (data2 [row_offset], data [count +h]) == 0)
	       break ;
	   }
	 
	 if (x != attr_list->rows)
	   {
	     if (status != NFM_E_NO_ATTR_INFO)
	       {
		 if (strlen (value))
		   {
		     status = MEMwrite_data (*data_list, value, 1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&attrs);
			 
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }

		 if (temp_list)
		   {
		     if (! (*value_list))
		       {
			 status = MEMsplit_copy_buffer (temp_list, value_list, 0);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Copy Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
		     else
		       {
			 status = MEMappend (temp_list, *value_list);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Append Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
			 
		     status = MEMclose (&temp_list);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list);
			 MEMclose (value_list);
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		     status = MEMno_buffers (*value_list, &no_buffers);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list) ;
			 MEMclose (value_list) ;
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEMno_buffers : < 0x%.8x >\n",
				     status));
			 return (NFM_E_MEM) ;
		       }
		     sprintf (no_buff, "%d", no_buffers);
		     if (strcmp (data2 [row_offset +1], "C") == 0)
		       offset = c ;
		     else 
		       if (strcmp (data2 [row_offset +1], "A") == 0)
			 offset = d ;

		     status = MEMwrite_data (attr_list, no_buff, 
					     x + 1, offset + 1) ;
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list) ;
			 MEMclose (value_list) ;
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Write Data : < 0x%.8x >\n",
				     status));
			 return (NFM_E_MEM) ;
		       }
		   }
	       }
	   }
	 else
	   {
	     MEMclose (data_list) ;
	     MEMclose (value_list) ;
	     MEMclose (&attrs) ;
	     ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
	     _NFMdebug ((fname, "Corrupted Buffers : < 0x%.8x >\n",
		       NFM_E_CORRUPTED_SYSTEM));
	     return (NFM_E_CORRUPTED_SYSTEM) ;
	   }
       }

     MEMclose (&attrs) ;

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
	       NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long _NFMget_data_value_no_data_rows (attr_list, data_list, value_list)
   MEMptr   attr_list;     /*  modified - attribute buffer */
   MEMptr   *data_list;    /*  modified - data buffer */
   MEMptr   *value_list;   /*  modified - value list */
{
    static char *fname = "_NFMget_data_value_no_data_rows" ;
     long    status;
     long    x, y, count, atol () ;
     long    a, b, c, d, e, f, g, h, no_buffers ;
     char    **column, **data, **data2 ;
     char    *sql_str, *sql_str1, tmp_str[100] ;
     char    value [100] ;
     long    _NFMget_value_info ();
     MEMptr  attrs = NULL ;
     MEMptr  temp_list = NULL, list_buffer = NULL ;
     char    no_buff [10] ;
     int     comma, row_offset, offset ;

    _NFMdebug ((fname, "ENTER\n")) ;

     status = MEMbuild_array (attr_list) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMbuild_array (attr_list) : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_MEM) ;
       }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;
     
     a = -1; b = -1; c = -1; d = -1; e = -1; f = -1; g = -1;
     
     for (y = 0; y < attr_list -> columns; ++y)
       {
        	 if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))     b = y;
         else if (! strcmp (column [y], "n_valueno"))      c = y;
         else if (! strcmp (column [y], "n_adviceno"))     d = y;
         else if (! strcmp (column [y], "n_read"))         e = y;
         else if (! strcmp (column [y], "n_write"))        f = y;
         else if (! strcmp (column [y], "n_update"))       g = y;
         else if (! strcmp (column [y], "n_attrno"))       h = y;
	    
       }

    _NFMdebug ((fname, "a %d b %d c%d\n",
		a, b, c)) ;

     status = MEMopen (data_list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
	 return (NFM_E_MEM);          
       }
     
     /* Create data list */
     
     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
	_NFMdebug ((fname, "column name %s format %s\n",
		    data[count +a], data[count+b])) ;

        status = MEMwrite_format (*data_list,
                 data [count + a], data [count + b]);
        if (status != MEM_S_SUCCESS)
         {
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }

     for (x=0; x<attr_list->rows ; ++x) 
       {
	 status = MEMwrite_data (attr_list, "0", x+1, c+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",status));
	     return (NFM_E_MEM);          
	   }
	 status = MEMwrite_data (attr_list, "0", x+1, d+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", status));
	     return (NFM_E_MEM);          
	   }
       }


     status = MEMbuild_array (attr_list)  ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Build Array (attr_list): < 0x%.8x >\n", 
		     status));
	 return (NFM_E_MEM);          
       }

     data   = (char **) attr_list -> data_ptr;

    /* Get default values for the data list and value list buffers */

     comma = 0 ;

     sql_str1 = (char *) malloc (200 + 60 * attr_list->rows) ;
     
     if (!sql_str1) 
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str1)"));
	 return (NFM_E_MALLOC);          
       }

     sql_str  = (char *) malloc (200 + 60 * attr_list-> rows) ;

     if (!sql_str)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 free (sql_str1) ;
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str)"));
	 return (NFM_E_MALLOC);          
       }


     sprintf (sql_str1, "SELECT %s FROM NFMVALUES WHERE (n_type = 'C' OR n_type = 'A') AND (",
	      "n_attrno, n_type, n_defaultvalue, n_defaultno, n_minvalue, n_maxvalue, n_listno, n_programno") ;
 	      
     sql_str[0] = 0 ;

     for (x = 0; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 if (!strcmp (data[count+h], "-1")) continue ;
	 if (comma)
	   strcat (sql_str, " OR ") ;
	 comma = 1 ;
	   sprintf (tmp_str, "n_attrno = %s", data[count + h]) ;
	 strcat (sql_str, tmp_str) ;
       } 
     
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by n_attrno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &attrs, MEM_SIZE) ;

     if (status != SQL_S_SUCCESS) 
       {
	 if ((status) == SQL_I_NO_ROWS_FOUND)
	   {
	     MEMclose (&attrs) ;
	     _NFMdebug ((fname, "No Rows found\n"));
	     return (NFM_S_SUCCESS);                 
	   }
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >\n", status));
	 return (NFM_E_SQL_QUERY) ;
       }

    comma = 0 ;
    sprintf (sql_str1, "SELECT %s FROM NFMVALUES a, NFMLISTS b WHERE (a.n_type = 'C' OR a.n_type = 'A') AND (a.n_listno = b.n_listno) AND (",
              "a.n_attrno, a.n_listno, b.n_value") ;

     sql_str[0] = 0 ;

     for (x = 0; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 if (!strcmp (data[count+h], "-1")) continue ;
	 if (comma)
	   strcat (sql_str, " OR ") ;
	 comma = 1 ;
	   sprintf (tmp_str, "a.n_attrno = %s", data[count + h]) ;
	 strcat (sql_str, tmp_str) ;
       } 
     
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by a.n_attrno, a.n_listno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &list_buffer, MEM_SIZE) ;

     free (sql_str1) ;
     free (sql_str) ;

     if (status != SQL_S_SUCCESS) 
       {
	 if ((status) == SQL_I_NO_ROWS_FOUND)
	   {
	     MEMclose (&attrs) ;
	     _NFMdebug ((fname, "No Rows found\n"));
	     return (NFM_S_SUCCESS);                 
	   }
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >\n", status));
	 return (NFM_E_SQL_QUERY) ;
       }

     status = MEMbuild_array (attrs) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&attrs) ;
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (list_buffer) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&attrs) ;
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (*data_list) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&attrs) ;
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }
     
     data2 = (char **) attrs->data_ptr ;
     
     for (y = 0; y <attrs->rows; y++)
       {
	 row_offset = y*attrs->columns ;
	 
	 strcpy (value, data2 [row_offset + 2]) ;

	 status = _NFMget_value_list (atol (data2 [row_offset]),
				       data2 [row_offset + 1], 
				       data2 [row_offset + 4], 
				       data2 [row_offset + 5], 
				       atol(data2 [row_offset+3]),
				       atol(data2 [row_offset+6]),
				       atol(data2 [row_offset+7]),
				       value, &temp_list,
				       list_buffer);
	 
	 if (status != NFM_S_SUCCESS && status != NFM_E_NO_ATTR_INFO)
	   {
	     MEMclose (&attrs) ;
	     
	     _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
		       status));
	     return (status);          
	   }

	 /* get row in attr/column in data list */
	 for (x=0; x<attr_list->rows; x++)
	   {
	     count = x*attr_list->columns ;
	     if (strcmp (data2 [row_offset], data [count +h]) == 0)
	       break ;
	   }
	 
	 if (x != attr_list->rows)
	   {
	     if (status != NFM_E_NO_ATTR_INFO)
	       {
		 if (strlen (value))
		   {
		     status = MEMwrite_data (*data_list, value, 1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&attrs);
			 
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }
		 
		 if (temp_list)
		   {
		     if (! (*value_list))
		       {
			 status = MEMsplit_copy_buffer (temp_list, value_list, 0);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Copy Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
		     else
		       {
			 status = MEMappend (temp_list, *value_list);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Append Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
			 
		     status = MEMclose (&temp_list);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list);
			 MEMclose (value_list);
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		     
		     status = MEMno_buffers (*value_list, &no_buffers);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list) ;
			 MEMclose (value_list) ;
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEMno_buffers : < 0x%.8x >\n",
				     status));
			 return (NFM_E_MEM) ;
		       }
		     sprintf (no_buff, "%d", no_buffers);
		     if (strcmp (data2 [row_offset +1], "C") == 0)
		       offset = c ;
		     else 
		       if (strcmp (data2 [row_offset +1], "A") == 0)
			 offset = d ;
		     status = MEMwrite_data (attr_list, no_buff, 
					     x + 1, offset + 1) ;
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list) ;
			 MEMclose (value_list) ;
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Write Data : < 0x%.8x >\n",
				     status));
			 return (NFM_E_MEM) ;
		       }
		   }
	       }
	   }
	 else
	   {
	     MEMclose (data_list) ;
	     MEMclose (value_list) ;
	     MEMclose (&attrs) ;
	     ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
	     _NFMdebug ((fname, "Corrupted Buffers : < 0x%.8x >\n",
		       NFM_E_CORRUPTED_SYSTEM));
	     return (NFM_E_CORRUPTED_SYSTEM) ;
	   }
       }
     

     MEMclose (&attrs) ;

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
	       NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long _NFMget_value_info (attrno, type, min_value, max_value,
			 def_no, list_no, prog_no,
			 def_value, list, list_buffer)
   long      attrno;
   char     *type, *min_value, *max_value ;
   long     def_no, list_no, prog_no ;
   char     *def_value;
   MEMptr   *list;
   MEMptr   list_buffer ;
   {
    char *fname = "_NFMget_value_info" ;
     long      status ;
     long      user_id ;
     long      _NFMmake_list_buf ();
     long      _NFMmake_range_buf ();
     long      NFMget_program_info ();
     long      NFMget_program_value ();

     _NFMdebug ((fname, "attrno = <%d> : Type  = <%s> : Min Value = <%s> : Max Value = <%s> : default No = <%d> : List No = <%d> : Program No = <%d> : Def Value = <%s>\n", 
		 attrno, type, min_value, max_value, def_no, list_no, 
		 prog_no, def_value));

     if (! strcmp (type, "CHECK"))
      {
        if (def_no > 0 && (! strlen (def_value)))
         {
           status = NFMget_program_value (user_id,
                    def_no, def_value);
           if (status != NFM_S_SUCCESS)
            {
              MEMclose (list);
              _NFMdebug ((fname, "Get Prog Value : status = <0x%.8x>\n",
              status));
              return (status);        
            }
         }
      }

     if (strlen (min_value) || strlen (max_value))
      {
        status = _NFMmake_range_buf (min_value, max_value, list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (list);
           _NFMdebug ((fname, "Get Range List : status = <0x%.8x>\n",
           status));
           return (status);        
         }
      }
     else if (list_no > 0)
      {

	status =  _NFMmake_list_buf (list_no, list, list_buffer, attrno) ;
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (list);
           _NFMdebug ((fname, "Get Static List : status = <0x%.8x>\n",
           status));
           return (status);        
         }
      }
     else if (prog_no > 0)
      {
        status = NFMget_program_info (user_id, prog_no, list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (list);
           _NFMdebug ((fname, "Get Prog List : status = <0x%.8x>\n",
           status));
           return (status);        
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long _NFMmake_list_buf (list_no, list, list_buffer, attrno)
   long     list_no;
   MEMptr   *list;
   MEMptr   list_buffer ;
   long     attrno ;
   {
     static char *fname = "_NFMmake_list_buf" ;
     long     status;
     MEMptr   temp_list = NULL;
     char     sql_str [1024];
     char     **data;
     long     x, break_point, offset ;
     long     NFMbuild_attr_list (), atol() ;

     _NFMdebug ((fname, "List No = <%d>\n", list_no));

     status = NFMbuild_attr_list (list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (list);
        MEMclose (&temp_list);
        _NFMdebug ((fname, "Build Attr List : status = <0x%.8x>\n",
        status));
        return (status); 
      }

     data = (char **) list_buffer -> data_ptr;

     break_point = 0 ;
     for (x = 0; x < list_buffer -> rows; ++x)
      {
	offset = x *list_buffer->columns ;
	if ((list_no == atol (data [offset+1])) && 
	     (attrno == atol (data [offset])))
	  {
	    break_point = 1 ;
	    sql_str [0] = 0;
	    
	    strcpy (sql_str, "NFM_STATIC"); strcat (sql_str, "\1");
	    strcat (sql_str, "\1");
	    strcat (sql_str, "\1");
	    strcat (sql_str, data [offset+2]);     strcat (sql_str, "\1");
	    strcat (sql_str, "\1");
	    strcat (sql_str, "\1");
	    strcat (sql_str, "\1");
	    strcat (sql_str, "\1");
	    
	    status = MEMwrite (*list, sql_str);
	    if (status != MEM_S_SUCCESS)
	      {
		MEMclose (list);
		MEMclose (&temp_list);
		ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		_NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			    status));
		return (NFM_E_MEM); 
	      }
	  }
	else
	  {
	    if (break_point) break ;
	  }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS); 
   }
/***********
 long _NFMmake_list_buf (list_no, list)
   long     list_no;
   MEMptr   *list;
   {
     static char *fname = "_NFMmake_list_buf" ;
     long     status;
     MEMptr   temp_list = NULL;
     char     sql_str [1024];
     char     **data;
     long     x;
     long     NFMbuild_attr_list ();

     _NFMdebug ((fname, "List No = <%d>\n", list_no));

     sprintf (sql_str, "SELECT n_value FROM %s WHERE %s = %d", 
              "NFMLISTS", "n_listno", list_no);

     status = SQLquery (sql_str, &temp_list, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&temp_list);
 
        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
            ERRload_struct (NFM, NFM_E_BAD_LIST, "", NULL);
           _NFMdebug ((fname, "No Such List : status = <0x%.8x>\n",
           NFM_E_BAD_LIST));
           return (NFM_E_BAD_LIST);
         }

            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY);
      }

     status = MEMbuild_array (temp_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&temp_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM); 
      }

     status = NFMbuild_attr_list (list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (list);
        MEMclose (&temp_list);
        _NFMdebug ((fname, "Build Attr List : status = <0x%.8x>\n",
        status));
        return (status); 
      }

     data = (char **) temp_list -> data_ptr;

     for (x = 0; x < temp_list -> rows; ++x)
      {
        sql_str [0] = 0;

        strcpy (sql_str, "NFM_STATIC"); strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
        strcat (sql_str, data [x]);     strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");

        status = MEMwrite (*list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (list);
           MEMclose (&temp_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM); 
         }
      }

     status = MEMclose (&temp_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",status));
        return (NFM_E_MEM); 
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS); 
   }
**********************/
 long _NFMmake_range_buf (min, max, list)
   char     *min, *max;
   MEMptr   *list;
   {
     static char *fname = "NFMget_range_list" ;
     long    status;
     char    sql_str [512];

     _NFMdebug ((fname, "Min = <%s> : Max = <%s>\n", 
		 min, max));

     status = MEMopen (list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMwrite_format (*list, "n_minvalue", "char(40)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write For : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     status = MEMwrite_format (*list, "n_maxvalue", "char(40)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write For : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     
     sql_str [0] = 0;
     strcpy (sql_str, min);  strcat (sql_str, "\1");
     strcat (sql_str, max);  strcat (sql_str, "\1");


     status = MEMwrite (*list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

long _NFMadd_to_value_list (attr_list, value_list, table_type, 
			    row, column_of_valueno)
     MEMptr *attr_list ;
     MEMptr *value_list ;
     char   *table_type ;
     long   row ;
     long   column_of_valueno ;
{
  static char *fname = "_NFMadd_to_value_list" ;
  long status, no_buffers ;
  char no_buff [10] ;
  MEMptr temp_list = NULL ;
  char   sql_str [1024] ;

  _NFMdebug ((fname, "table type %s : row %d : column of value %d\n",
	      table_type, row, column_of_valueno)) ;

  sprintf (sql_str, "select distinct (n_identifier) from nfmtables where (n_tablename = 'catalog' or n_tablename = 'f_catalog') and (n_tabletype = '%s')",
	   table_type) ;
  
  status = SQLquery (sql_str, &temp_list, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "No rows found\n")) ;
	  return (status) ;
	}

      _NFMdebug ((fname, "SQLquery : status = <0x%x8>\n",
		  status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  if (temp_list)
    {
      if (! (*value_list))
	{
	  status = MEMsplit_copy_buffer (temp_list, value_list, 0);
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&temp_list);
	      MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	      _NFMdebug ((fname, "Copy Buffer : status = <0x%.8x>\n",
			  status));
	      return (NFM_E_MEM);          
	    }
	}
      else
	{
	  status = MEMappend (temp_list, *value_list);
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&temp_list);
	      MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	      _NFMdebug ((fname, "Append Buffer : status = <0x%.8x>\n",
			  status));
	      return (NFM_E_MEM);          
	    }
	}

      status = MEMclose (&temp_list);
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (value_list);
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n",
		      status));
	  return (NFM_E_MEM);          
	}
      
      status = MEMno_buffers (*value_list, &no_buffers);
      if (status != MEM_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "MEMno_buffers : < 0x%.8x >\n",
		      status));
	  return (NFM_E_MEM) ;
	}
      
      sprintf (no_buff, "%d", no_buffers);

      status = MEMwrite_data (*attr_list, no_buff, 
			      row, column_of_valueno) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (value_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "MEM Write Data : < 0x%.8x >\n",
		      status));
	  return (NFM_E_MEM) ;
	}
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
long _NFMadd_to_value_list_from_query (attr_list, value_list, 
				       sql_query, row, column_of_valueno)
     MEMptr *attr_list ;
     MEMptr *value_list ;
     char  *sql_query ;
     long  row ;
     long  column_of_valueno ;
{
  static char *fname = "_NFMadd_to_value_list_from_query" ;
  long status, no_buffers ;
  char no_buff [10] ;
  MEMptr temp_list = NULL ;

  _NFMdebug ((fname, "row %d : column of valueno %d : sql query -> %s\n",
	      row, column_of_valueno, sql_query)) ;

  status = SQLquery (sql_query, &temp_list, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&temp_list) ;
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "No rows found\n")) ;
	  return (NFM_S_SUCCESS) ;
	}

      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQLquery : status = <0x%x8>\n",
		  status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  if (temp_list)
    {
      if (! (*value_list))
	{
	  status = MEMsplit_copy_buffer (temp_list, value_list, 0);
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&temp_list);
	      MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	      _NFMdebug ((fname, "Copy Buffer : status = <0x%.8x>\n",
			  status));
	      return (NFM_E_MEM);          
	    }
	}
      else
	{
	  status = MEMappend (temp_list, *value_list);
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&temp_list);
	      MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	      _NFMdebug ((fname, "Append Buffer : status = <0x%.8x>\n",
			  status));
	      return (NFM_E_MEM);          
	    }
	}

      status = MEMclose (&temp_list);
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (value_list);
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n",
		      status));
	  return (NFM_E_MEM);          
	}
      
      status = MEMno_buffers (*value_list, &no_buffers);
      if (status != MEM_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "MEMno_buffers : < 0x%.8x >\n",
		      status));
	  return (NFM_E_MEM) ;
	}
      
      sprintf (no_buff, "%d", no_buffers);
      _NFMdebug ((fname, "writing %s into row %d column %d\n",
		  no_buff, row, column_of_valueno));

      status = MEMwrite_data (*attr_list, no_buff, 
			      row, column_of_valueno) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (value_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "MEM Write Data : < 0x%.8x >\n",
		      status));
	  return (NFM_E_MEM) ;
	}
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
/** validation/advisory information for updatable attributes only ***/
 long _NFMget_data_value_u (attr_list, data_list, value_list)
   MEMptr   attr_list;     /*  modified - attribute buffer */
   MEMptr   *data_list;    /*  modified - data buffer */
   MEMptr   *value_list;   /*  modified - value list */
   {
     static char *fname = "_NFMget_data_value_u" ;
     long    status, atol ();
     long    x, y, z, count ;
     long    a, b, c, d, e, f, g, h ;
     long    no_buffers ;
     MEMptr  temp_list = NULL;
     char    **column, **data, **data1, **data2 ;
     char    *sql_str, *sql_str1, tmp_str[100] ;
     char    value [100] ;
     long    _NFMget_value_list ();
     MEMptr  attrs = NULL, list_buffer = NULL ;
     char    no_buff [10] ;
     int     comma, row_offset, offset ;
     long    list_values_exist;

     /* The attr_list buffer received get offsets for
        n_name, n_datatype, etc */

     _NFMdebug ((fname, "ENTER\n")) ;

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (data_list);
        MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; b = -1; c = -1; d = -1; e = -1; f = -1; g = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
         else if (! strcmp (column [y], "n_valueno"))   c = y;
         else if (! strcmp (column [y], "n_adviceno"))  d = y;
         else if (! strcmp (column [y], "n_read"))      e = y;
         else if (! strcmp (column [y], "n_write"))     f = y;
         else if (! strcmp (column [y], "n_update"))    g = y;
         else if (! strcmp (column [y], "n_attrno"))    h = y;
      }

     z = 0;

     /* if data_list existed recover data, otherwise put empty row */

     if (*data_list)
      {

	sql_str = (char *) malloc ((*data_list) -> row_size);
	if (! sql_str)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	    _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
			NFM_E_MALLOC));
	    return (NFM_E_MALLOC);          
	  }
	sql_str [0] = 0;
        status = MEMbuild_array (*data_list);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (&temp_list);
           MEMclose (data_list);
           MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }

        z = (*data_list) -> columns;

        data1 = (char **) (*data_list) -> data_ptr;

        sql_str [0] = 0;

        for (y = 0; y < temp_list -> columns; ++y)
         {
           if (y < (*data_list) -> columns)  strcat (sql_str, data1 [y]);

           strcat (sql_str, "\1");
         }

        status = MEMclose (data_list);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (&temp_list);
           MEMclose (data_list);
           MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
	status = MEMsplit_copy_buffer (temp_list, data_list, 0);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (&temp_list);
	    MEMclose (data_list);
	    MEMclose (value_list);
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Split Copy : status = <0x%.8x>\n",
			status));
	    return (NFM_E_MEM);          
	  }
     
	status = MEMclose (&temp_list);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
	    return (NFM_E_MEM);          
	  }
      }
     else
       {
	 _NFMdebug ((fname, "data list is NULL\n")) ;
	status = MEMopen (data_list, MEM_SIZE);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	    _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
	    return (NFM_E_MEM);          
	  }
	
	
	 /* Create data list if one has not already exist */
	 for (x = 0; x < attr_list -> rows; ++x)
	   {
	     count = attr_list -> columns * x;
	     
	     status = MEMwrite_format (*data_list,
				       data [count + a], data [count + b]);
	     if (status != MEM_S_SUCCESS)
	       {
		 MEMclose (data_list);
		 MEMclose (value_list);
		 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		 _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
			     status));
		 return (NFM_E_MEM);          
	      }
	   }
	
	 sql_str = (char *) malloc ((*data_list) -> row_size);
	 if (! sql_str)
	  {
	    MEMclose (data_list);
	    MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	    _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
			NFM_E_MALLOC));
	    return (NFM_E_MALLOC);          
	  }
	
	 for (y = 0; y < (*data_list) -> columns; ++y)
	  strcat (sql_str, "\1");
     
	 status = MEMwrite (*data_list, sql_str);
	 if (status != MEM_S_SUCCESS)
	   {
	     free (sql_str);
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);          
	   }
	 free (sql_str);
       }
     

     for (x=z; x<attr_list->rows ; ++x) 
       {
	 status = MEMwrite_data (attr_list, "0", x+1, c+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",status));
	     return (NFM_E_MEM);          
	   }
	 status = MEMwrite_data (attr_list, "0", x+1, d+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", 
			 status));
	     return (NFM_E_MEM);          
	   }
       }

     data   = (char **) attr_list -> data_ptr;

    /* Get default values for the data list and value list buffers */


     comma = 0 ;

     sql_str1 = (char *) malloc (200 + 60 * attr_list->rows) ;
     
     if (!sql_str1) 
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str1)"));
	 return (NFM_E_MALLOC);          
       }

     sql_str  = (char *) malloc (200 + 60 * attr_list-> rows) ;

     if (!sql_str)
       {
	 MEMclose (data_list);
	 MEMclose (value_list);
	 free (sql_str1) ;
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _NFMdebug ((fname, "Malloc failed (sql_str)"));
	 return (NFM_E_MALLOC);          
       }


     sprintf (sql_str1, "SELECT %s FROM NFMVALUES WHERE (n_type = 'C' OR n_type = 'A') AND (",
	      "n_attrno, n_type, n_defaultvalue, n_defaultno, n_minvalue, n_maxvalue, n_listno, n_programno") ;
 	      
     sql_str[0] = 0 ;

     for (x = z; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 if (strcmp (data[count+g], "Y") == 0)
	   {
	     if (comma)
	       strcat (sql_str, " OR ") ;
	     comma = 1 ;
	     sprintf (tmp_str, "n_attrno = %s", data[count + h]) ;
	     strcat (sql_str, tmp_str) ;
	   }
       } 
	
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by n_attrno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &attrs, MEM_SIZE) ;

     if (status != SQL_S_SUCCESS) 
       {
	 if ((status ) == SQL_I_NO_ROWS_FOUND)
	   {
	     MEMclose (&attrs) ;
	     _NFMdebug ((fname, "No Rows found"));
	     return (NFM_S_SUCCESS);                 
	   }
	 MEMclose (data_list) ;
	 MEMclose (value_list) ;
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >", status));
	 return (NFM_E_SQL_QUERY) ;
       }

/*     comma = 0 ; */
    sprintf (sql_str1, "SELECT %s FROM NFMVALUES a, NFMLISTS b WHERE (a.n_type = 'C' OR a.n_type = 'A') AND (a.n_listno = b.n_listno) AND (",
              "a.n_attrno, a.n_listno, b.n_value") ;
/*
     sql_str[0] = 0 ;

     for (x = z; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 if (strcmp (data [count+g], "Y") == 0)
	 { 
	 if (comma)
	 strcat (sql_str, " OR ") ;
	 comma = 1 ;
	 sprintf (tmp_str, "a.n_attrno = %s", data[count + h]) ;
	 strcat (sql_str, tmp_str) ;
	 }
       } 
  */   
	
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ORDER by a.n_attrno, a.n_listno") ;
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _NFMdebug ((fname, "No attributes "));
	 return (NFM_S_SUCCESS);                 
       }

     status = SQLquery (sql_str1, &list_buffer, MEM_SIZE) ;

     free (sql_str1) ;
     free (sql_str) ;

     if ((status != SQL_S_SUCCESS)  && (status != SQL_I_NO_ROWS_FOUND))
       {
	 MEMclose (data_list) ;
	 MEMclose (value_list) ;
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >", status));
	 return (NFM_E_SQL_QUERY) ;
       }

     list_values_exist = 1 ;
     if (status == SQL_I_NO_ROWS_FOUND)
       {
	 list_values_exist = 0 ;
       }

     status = MEMbuild_array (attrs) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (list_buffer) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (*data_list) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 MEMclose (&attrs) ;
	 
	 _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status));
	 return (NFM_E_MEM);
       }
     
     data2 = (char **) attrs->data_ptr ;

     for (y = 0; y <attrs->rows; y++)
       {
	 row_offset = y*attrs->columns ;
	 
	 strcpy (value, data2 [row_offset + 2]) ;
	 
	 if (list_values_exist)
	   {
	     status = _NFMget_value_list (atol (data2 [row_offset]),
					  data2 [row_offset + 1], /* type */
					  data2 [row_offset + 4], /* minvalue*/
					  data2 [row_offset + 5], /* maxvalue */
					  atol(data2 [row_offset+3]), /*defno*/
					  atol(data2 [row_offset+6]), /*listno*/
					  atol(data2 [row_offset+7]), /*progno*/
					  value, &temp_list,
					  list_buffer) ;
	     
	     if (status != NFM_S_SUCCESS && status != NFM_E_NO_ATTR_INFO)
	       {
		 MEMclose (&temp_list);
		 MEMclose (&attrs) ;
		 MEMclose (data_list);
		 MEMclose (value_list);
		 
		 _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
			     status));
		 return (status);          
	       }
	   }
	 else
	   {
	     status = NFM_S_SUCCESS ;
	   }

	 /* get row in attr/column in data list */
	 for (x=0; x<attr_list->rows; x++)
	   {
	     count = x*attr_list->columns ;
	     if (strcmp (data2 [row_offset], data [count +h]) == 0)
	       break ;
	   }
	 
	 if (x != attr_list->rows)
	   {
	     if (status != NFM_E_NO_ATTR_INFO)
	       {
		 if (strlen (value))
		   {
		     status = MEMwrite_data (*data_list, value, 1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&temp_list);
			 MEMclose (&attrs);
			 MEMclose (data_list);
			 MEMclose (value_list);
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		   }
		 
		 if (temp_list)
		   {
		     if (! (*value_list))
		       {
			 status = MEMsplit_copy_buffer (temp_list, value_list, 0);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Copy Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
		     else
		       {
			 status = MEMappend (temp_list, *value_list);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (value_list);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _NFMdebug ((fname, "Append Buffer : status = <0x%.8x>\n",
					 status));
			     return (NFM_E_MEM);          
			   }
		       }
		     
		     status = MEMclose (&temp_list);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list);
			 MEMclose (value_list);
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n",
				     status));
			 return (NFM_E_MEM);          
		       }
		     
		     status = MEMno_buffers (*value_list, &no_buffers);
		     sprintf (no_buff, "%d", no_buffers);
		     if (strcmp (data2 [row_offset +1], "C") == 0)
		       offset = c ;
		     else 
		       if (strcmp (data2 [row_offset +1], "A") == 0)
			 offset = d ;
		     status = MEMwrite_data (attr_list, no_buff, 
					     x + 1, offset + 1) ;
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list) ;
			 MEMclose (value_list) ;
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _NFMdebug ((fname, "MEM Write Data : < 0x%.8x >",
				     status));
			 return (NFM_E_MEM) ;
		       }
		   }
	       }
	   }
	 else
	   {
	     MEMclose (data_list) ;
	     MEMclose (value_list) ;
	     MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
	     _NFMdebug ((fname, "Corrupted System : < 0x%.8x >\n",
		       NFM_E_CORRUPTED_SYSTEM) );
	     return (NFM_E_CORRUPTED_SYSTEM) ;
	   }
       }
     
     MEMclose (&attrs) ;
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
