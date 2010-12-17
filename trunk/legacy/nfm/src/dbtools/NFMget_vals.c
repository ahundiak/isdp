#include "machine.h"
#include "DBTOOLS.h"
  extern struct NFMglobal_st NFMglobal ;

long _NFMget_data_value (attr_list, data_list, value_list,
			 flag, data_buf_flag)
     MEMptr   attr_list;     /*  modified - attribute buffer */
     MEMptr   *data_list;    /*  modified - data buffer */
     MEMptr   *value_list;   /*  modified - value list */
     char     *flag ;        /*  W = write only, U= update only, A=all*/
     char     *data_buf_flag;/*  N = no rows, R= rows */
{
  static char *fname = "_NFMget_data_value" ;
  long    status, atol ();
  long    x, y, z, count ;
  long    a, b, c, d, e, f, g, h,k ;
  long    no_buffers, l_flag, d_flag ;
  MEMptr  temp_list = NULL;
  char    **column, **data, **data1, **data2 ;
  char    *sql_str, *sql_str1, tmp_str[100] ;
  char    value [100] ;
  MEMptr  attrs = NULL, list_buffer = NULL ;
  char    no_buff [10] ;
  int     comma, row_offset ;
  char    advice_string [NFM_VALUE+1] ;
  
  
  _NFMdebug ((fname, "ENTER\n")) ;
  l_flag = 0 ;
  if (strcmp (flag, "W") == 0) l_flag = 1 ;
  else if (strcmp (flag, "U") == 0) l_flag = 2;

  d_flag = 0 ;
  if (strcmp (data_buf_flag, "N") == 0) d_flag = 1 ;

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
  
  a = -1; b = -1; c = -1; d = -1; e = -1; f = -1; g = -1; h = -1 ; k = -1;
  
  for (y = 0; y < attr_list -> columns; ++y)
    {
      if (! strcmp (column [y], "n_name"))      a = y;
      else if (! strcmp (column [y], "n_datatype"))  b = y;
      else if (! strcmp (column [y], "n_valueno"))   c = y;
/*      else if (! strcmp (column [y], "n_adviceno"))  d = y; */
      else if (! strcmp (column [y], "n_read"))      e = y;
      else if (! strcmp (column [y], "n_write"))     f = y;
      else if (! strcmp (column [y], "n_update"))    g = y;
      else if (! strcmp (column [y], "n_attrno"))    h = y;
      else if (! strcmp (column [y], "n_advice"))    k = y;
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
      
      if (!d_flag)
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
	  
	  sql_str [0] = 0 ;
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
/*********** n_adviceno not in buffer ************
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
******************************************************/
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
  
  comma = 0 ;  
  sprintf (sql_str1, "SELECT %s FROM NFMVALUES a, NFMLISTS b WHERE (a.n_type = 'C' OR a.n_type = 'A') AND (a.n_listno = b.n_listno) AND (",
	   "a.n_attrno, a.n_listno, b.n_value,b.n_value2") ;
/*
	   "a.n_attrno, a.n_listno, b.n_value,b.n_value2,b.n_listname") ;
*/
  
  
  sql_str[0] = 0 ;
  for (x = z; x < attr_list -> rows; ++x)
    {
      count = x * attr_list -> columns  ;

      if (l_flag == 1)
	{
	  if (strcmp (data [count+f], "Y")==0)
	    {
	      if (comma)
		strcat (sql_str, " OR ") ;
	      comma = 1 ;
	      sprintf (tmp_str, "a.n_attrno = %s", data[count + h]) ;
	      strcat (sql_str, tmp_str) ;
	    }
	}
      else if (l_flag == 2)
	{ 
	  if (strcmp (data [count+g], "Y") == 0)
	    {
	      if (comma)
		strcat (sql_str, " OR ") ;
	      comma = 1 ;
	      sprintf (tmp_str, "a.n_attrno = %s", data[count + h]) ;
	      strcat (sql_str, tmp_str) ;
	    }
	}
      else
	{
	  if (comma)
	    strcat (sql_str, " OR ") ;
	  comma = 1 ;
	  sprintf (tmp_str, "a.n_attrno = %s", data[count + h]) ;
	  strcat (sql_str, tmp_str) ;
	}
    } 
  
  
  if (comma) 
    {
      strcat (sql_str1, sql_str) ;
      strcat (sql_str1, " ) ORDER by a.n_attrno, a.n_listno, b.n_value") ;
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
      MEMclose (&list_buffer) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
      _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >", status));
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (attrs) ;
  if (status != MEM_S_SUCCESS) 
    {
      MEMclose (&temp_list);
      MEMclose (data_list);
      MEMclose (value_list);
      MEMclose (&attrs) ;
      MEMclose (&list_buffer) ;
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
      MEMclose (&list_buffer) ;
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
      MEMclose (&list_buffer) ;
      _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		  status));
      return (NFM_E_MEM);
    }
  
  data2 = (char **) attrs->data_ptr ;
  for (y = 0; y <attrs->rows; y++)
    {
      row_offset = y*attrs->columns ;
      advice_string [0] = 0 ;
      
      strcpy (value, data2 [row_offset + 2]) ;
      
      if (strlen (data2 [row_offset+4]) && 
	  strlen (data2 [row_offset+5])) 
	{
	  status = _NFMget_range_list (data2 [row_offset+4], 
				       data2[row_offset+5],
				       &temp_list);
	  if (status != NFM_S_SUCCESS)
	    {
	      MEMclose (&temp_list);
	      MEMclose (&list_buffer) ;
	      MEMclose (&attrs) ;
	      MEMclose (data_list) ;
	      MEMclose (value_list) ;
	      _NFMdebug ((fname, "Get Range List : status = <0x%.8x>\n",
			  status));
	      return (status);        
	    }
	}
      else if (atol(data2 [row_offset+6]) > 0)
	{
	  status = _NFMget_list_list (atol(data2 [row_offset]), 
				      atol(data2[row_offset+6]), 
				      data2 [row_offset+1],
				      &temp_list, list_buffer,
				      advice_string);
	  if (status != NFM_S_SUCCESS)
	    {
	      MEMclose (&temp_list);
	      MEMclose (&list_buffer) ;
	      MEMclose (&attrs) ;
	      MEMclose (value_list) ;
	      MEMclose (data_list) ;
	      _NFMdebug ((fname, "Get Static List : status = <0x%.8x>\n",
			  status));
	      return (status);        
	    }
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
	  if (!d_flag)
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
		      MEMclose (&list_buffer) ;
		      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		      _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				  status));
		      return (NFM_E_MEM);          
		    }
		}
	    }

	  if (strlen (advice_string))
	    {
	      status = MEMwrite_data (attr_list, advice_string, x+1, k+1);
	      if (status != MEM_S_SUCCESS)
		{
		  MEMclose (&temp_list);
		  MEMclose (&attrs);
		  MEMclose (data_list);
		  MEMclose (value_list);
		  MEMclose (&list_buffer) ;
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
		      MEMclose (&list_buffer) ;
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
		      MEMclose (&list_buffer) ;
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
		  MEMclose (&list_buffer) ;
		  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		  _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n",
			      status));
		  return (NFM_E_MEM);          
		}
	      
	      status = MEMno_buffers (*value_list, &no_buffers);
	      sprintf (no_buff, "%d", no_buffers);
/*******
	      if (strcmp (data2 [row_offset +1], "C") == 0)
		offset = c ;
	      else 
		if (strcmp (data2 [row_offset +1], "A") == 0)
		  offset = d ;
***********/
	      status = MEMwrite_data (attr_list, no_buff, 
				      x + 1, c + 1);
	      if (status != MEM_S_SUCCESS)
		{
		  MEMclose (data_list) ;
		  MEMclose (value_list) ;
		  MEMclose (&attrs) ;
		  MEMclose (&list_buffer) ;
		  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		  _NFMdebug ((fname, "MEM Write Data : < 0x%.8x >",
			      status));
		  return (NFM_E_MEM) ;
		}
	    }
	}
      else
	{
	  MEMclose (data_list) ;
	  MEMclose (value_list) ;
	  MEMclose (&attrs) ;
	  MEMclose (&list_buffer) ;
	  ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
	  _NFMdebug ((fname, "Corrupted System : < 0x%.8x >\n",
		      NFM_E_CORRUPTED_SYSTEM) );
	  return (NFM_E_CORRUPTED_SYSTEM) ;
	}
    }
  
  MEMclose (&attrs) ;
  MEMclose (&list_buffer) ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}



long _NFMget_range_list (min, max, list)
     char     *min, *max;
     MEMptr   *list;
   {
     char *fname = "_NFMget_range_list" ;
     long    status;
     char    sql_str [512], datatype [20] ;
     
     _NFMdebug ((fname, "Min = <%s> : Max = <%s>\n", 
		 min, max));
     status = MEMopen (list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
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
     
     sprintf (datatype, "char(%d)", NFM_MINVALUE) ;
     status = MEMwrite_format (*list, "n_minvalue", datatype) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (list);
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
		     status));
	 return (NFM_E_MEM); 
       }
     sprintf (datatype, "char(%d)", NFM_MAXVALUE) ;
     status = MEMwrite_format (*list, "n_maxvalue", datatype) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (list);
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
		     status));
	 return (NFM_E_MEM); 
       }
     
     sprintf (sql_str, "%s\001%s\001%s\001",
              "NFM_RANGE", min, max) ;
     
     status = MEMwrite (*list, sql_str);
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (list);
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
	 return (NFM_E_MEM);
       }
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

long _NFMget_list_list (attrno, list_no, type, list, list_buffer,
			  advice_string)
     long     attrno ;
     long     list_no ;
     char     *type;
     MEMptr   *list;
     MEMptr   list_buffer ;
     char     *advice_string ;
{
  char *fname= "_NFMget_list_list" ;
  long    status, break_point, x, offset, atol() ;
  char    sql_str [512], **data ;
  char    datatype [30] ;

  _NFMdebug ((fname, "Attrno = <%d> : List No = <%d> : Type = <%s>\n", 
	      attrno, list_no, type));
  
  if (strcmp (type, "C") == 0)
    {
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
/*******
      sprintf (datatype, "char(%d)", NFM_LISTNAME) ;
      status = MEMwrite_format (*list, "n_listname", datatype) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
*********/
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
	  if (strcmp (type, "C") == 0)
	    {
	      sql_str [0] = 0;
	      /* n_value */		
	      strcat (sql_str, data [offset+2]);     strcat (sql_str, "\1");
	      /* n_value2 */
	      strcat (sql_str, data [offset+3]);     strcat (sql_str, "\1");
	      /* n_listname */		
/*
	      strcat (sql_str, data [offset+4]);     strcat (sql_str, "\1");
*/
	      
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
	      strcpy (advice_string, data [offset+2]) ;
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

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
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
     sprintf (sql_str, "SELECT n_value FROM %s WHERE %s = %d order by n_value", 
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

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS); 
   }



 long NFMbuild_attr_list (list)
   MEMptr   *list;
{
  static char *fname = "NFMbuild_attr_list" ;
  long     status;
  char     datatype [20] ;

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

	sprintf (datatype, "char(%d)", NFM_MINVALUE) ;
	status = MEMwrite_format (*list, "n_minvalue", datatype) ;
	if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }
	sprintf (datatype, "char(%d)", NFM_MAXVALUE) ;
	status = MEMwrite_format (*list, "n_maxvalue", datatype) ;
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

         status = MEMwrite_format (*list, "n_filename", "char(14)") ;
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
 
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS); 
   }

long _NFMbuild_attr_list (list)
     MEMptr   *list;
{
  static char *fname = "_NFMbuild_attr_list" ;
  long     status;
  char     datatype [20] ;
  
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
      
      sprintf (datatype, "char(%d)", NFM_MINVALUE) ;
      status = MEMwrite_format (*list, "n_minvalue", datatype) ;
	if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }
      sprintf (datatype, "char(%d)", NFM_MAXVALUE) ;
      status = MEMwrite_format (*list, "n_maxvalue", datatype) ;
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
      
      status = MEMwrite_format (*list, "n_filename", "char(14)") ;
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

/*************
      sprintf (datatype, "char(%d)", NFM_LISTNAME) ;
      status = MEMwrite_format (*list, "n_listname", datatype) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (list);
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
		      status));
	  return (NFM_E_MEM); 
	}
************/

      sprintf (datatype, "char(%d)", NFM_VALUE2) ;
      status = MEMwrite_format (*list, "n_value2", datatype) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (list);
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
		      status));
	  return (NFM_E_MEM); 
	}
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS); 
}


/*** get data_list and value_list from attr_list ***/

long _NFMget_data_info (attr_list, data_list, value_list)
     MEMptr   attr_list;     /*  modified - attribute buffer */
     MEMptr   *data_list;    /*  modified - data buffer */
     MEMptr   *value_list;   /*  modified - value list */
{
  static char *fname = "_NFMget_data_info" ;
  long    status;
  long    x, y, count, atol () ;
  long    a, b, c, e, f, g, h, k, no_buffers ;
  char    **column, **data, **data2 ;
  char    *sql_str, *sql_str1, tmp_str[100] ;
  char    value [100] ;
  MEMptr  attrs = NULL ;
  MEMptr  temp_list = NULL ;
  MEMptr   list_buffer = NULL ;
  char    no_buff [10], advice_string [NFM_VALUE+1] ;
  int     comma, row_offset ;
  
  _NFMdebug ((fname, "ENTER\n")) ;
  
  status = MEMbuild_array (attr_list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array (attr_list) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;
  
  a = -1; b = -1; c = -1; e = -1; f = -1; g = -1; h = -1; k = -1;
  
  for (y = 0; y < attr_list -> columns; ++y)
    {
      if (! strcmp (column [y], "n_name"))      a = y;
      else if (! strcmp (column [y], "n_datatype"))     b = y;
      else if (! strcmp (column [y], "n_valueno"))      c = y;
/*      else if (! strcmp (column [y], "n_adviceno"))     d = y; */
      else if (! strcmp (column [y], "n_read"))         e = y;
      else if (! strcmp (column [y], "n_write"))        f = y;
      else if (! strcmp (column [y], "n_update"))       g = y;
      else if (! strcmp (column [y], "n_attrno"))       h = y;
      else if (! strcmp (column [y], "n_advice"))       k = y;
    }

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
/*      _NFMdebug ((fname, "column name %s format %s\n",
		  data[count +a], data[count+b])) ; */
      
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
/******
      status = MEMwrite_data (attr_list, "0", x+1, d+1) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (data_list);
	  MEMclose (value_list);
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", status));
	  return (NFM_E_MEM);          
	}
*********/
    }
  

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
      strcat (sql_str1, " ) ORDER by a.n_attrno, a.n_listno,b.n_value") ;
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
      MEMclose (data_list) ;
      MEMclose (value_list) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
      _NFMdebug ((fname, "SQL Query Syntax : < 0x%.8x >\n", status));
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (attrs) ;
  if (status != MEM_S_SUCCESS) 
    {
      MEMclose (&attrs) ;
      MEMclose (data_list) ;
      MEMclose (value_list) ;
      _NFMdebug ((fname, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		  status));
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM);
    }
  
  status = MEMbuild_array (list_buffer) ;
  if (status != MEM_S_SUCCESS) 
    {
      MEMclose (&attrs) ;
      MEMclose (data_list) ;
      MEMclose (value_list) ;
      MEMclose (&list_buffer) ;
      _NFMdebug ((fname, "MEMbuild_array(list_buffer) : < 0x%.8x >\n",
		  status));
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM);
    }
  
  status = MEMbuild_array (*data_list) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&attrs) ;
      MEMclose (&list_buffer) ;
      MEMclose (data_list) ;
      MEMclose (value) ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>|n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  data2 = (char **) attrs->data_ptr ;

  for (y = 0; y <attrs->rows; y++)
    {
      advice_string [0] = 0 ; 
      row_offset = y*attrs->columns ;
      
      strcpy (value, data2 [row_offset + 2]) ;

     if (strlen (data2 [row_offset+4]) && strlen (data2 [row_offset+5]))
       {
	 status = _NFMmake_range_buf (data2[row_offset+4],
				      data2[row_offset+5],
				      &temp_list);
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (&attrs) ;
	     MEMclose (&temp_list);
	     MEMclose (data_list) ;
	     MEMclose (value_list) ;
	     MEMclose (&list_buffer) ;
	     _NFMdebug ((fname, "Get Range List : status = <0x%.8x>\n",
			 status));
	     return (status);        
	   }
       }
      
     else if (atol(data2[row_offset+6]) > 0)
      {
/* 	advice_string [0] = 0 ; */
	status =  _NFMmake_list_buf (atol(data2[row_offset+6]),
				      &temp_list, list_buffer, 
				      atol(data2[row_offset]),
				      data2 [row_offset+1],
				      advice_string);
        if (status != NFM_S_SUCCESS)
	  {
	    MEMclose (&temp_list);
	    MEMclose (&attrs) ;
	    MEMclose (data_list) ;
	    MEMclose (value_list) ;
	    MEMclose (&list_buffer) ;
	    _NFMdebug ((fname, "Get Static List : status = <0x%.8x>\n",
			status));
	    return (status);        
	  }
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
	  if (strlen (value))
	    {
	      status = MEMwrite_data (*data_list, value, 1, x + 1);
	      if (status != MEM_S_SUCCESS)
		{
		  MEMclose (&attrs);
		  MEMclose (&temp_list) ;
		  MEMclose (&list_buffer) ;
		  MEMclose (data_list) ;
		  MEMclose (value_list) ;
		  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		  _NFMdebug ((fname, "MEM Wr Data (data_list) : status = <0x%.8x>\n",
			      status));
		  return (NFM_E_MEM);          
		}
	    }

	  if (strlen (advice_string))
	    {
	      status = MEMwrite_data (attr_list, advice_string, x+1, k+1);
	      if (status != MEM_S_SUCCESS)
		{
		  MEMclose (&attrs);
		  MEMclose (value_list) ;
		  MEMclose (data_list) ;
		  MEMclose (&temp_list) ;
		  MEMclose (&list_buffer) ;
		  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		  _NFMdebug ((fname, "MEM Wr Data (attr_list) : status = <0x%.8x>\n",
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
		      MEMclose (&list_buffer) ;
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
		      MEMclose (&list_buffer) ;
		      MEMclose (data_list);
		      MEMclose (value_list);
		      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		      _NFMdebug ((fname, "Append Buffer : status = <0x%.8x>\n",
				  status));
		      return (NFM_E_MEM);          
		    }
		}
	      
	      MEMclose (&temp_list);

	      status = MEMno_buffers (*value_list, &no_buffers);
	      if (status != MEM_S_SUCCESS)
		{
		  MEMclose (data_list) ;
		  MEMclose (value_list) ;
		  MEMclose (&attrs) ;
		  MEMclose (&list_buffer) ;
		  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		  _NFMdebug ((fname, "MEMno_buffers : < 0x%.8x >\n",
			      status));
		  return (NFM_E_MEM) ;
		}
	      sprintf (no_buff, "%d", no_buffers);
	      /* mms - only check type are in value list 
		 if (strcmp (data2 [row_offset +1], "C") == 0)
		 offset = c ;
		 else 
		 if (strcmp (data2 [row_offset +1], "A") == 0)
		 offset = d ;
		 
		 status = MEMwrite_data (attr_list, no_buff, 
		 x + 1, offset + 1) ;
		 */
	      status = MEMwrite_data (attr_list, no_buff, 
				      x + 1, c + 1) ;
	      if (status != MEM_S_SUCCESS)
		{
		  MEMclose (data_list) ;
		  MEMclose (value_list) ;
		  MEMclose (&attrs) ;
		  MEMclose (&list_buffer) ;
		  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		  _NFMdebug ((fname, "MEM Write Data : < 0x%.8x >\n",
			      status));
		  return (NFM_E_MEM) ;
		}
	    }
	}
      else
	{
	  MEMclose (data_list) ;
	  MEMclose (value_list) ;
	  MEMclose (&attrs) ;
	  MEMclose (&temp_list) ;
	  MEMclose (&list_buffer) ;
	  ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
	  _NFMdebug ((fname, "Corrupted Buffers : < 0x%.8x >\n",
		      NFM_E_CORRUPTED_SYSTEM));
	  return (NFM_E_CORRUPTED_SYSTEM) ;
	}
    }
  
  MEMclose (&attrs) ;
  MEMclose (&list_buffer) ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}


long _NFMmake_list_buf (list_no, list, list_buffer, attrno, type, 
			 advice_string)
     long     list_no;
     MEMptr   *list;
     MEMptr   list_buffer ;
     long     attrno ;
     char     *type ;
     char     *advice_string ;
   {
     static char *fname = "_NFMmake_list_buf" ;
     long     status;
     MEMptr   temp_list = NULL;
     char     sql_str [1024];
     char     **data;
     long     x, break_point, offset =-1 ;
     long     NFMbuild_attr_list (), atol() ;

     _NFMdebug ((fname, "List No = <%d> : Type <%s> : Attrno <%d> \n",
		 list_no, type, attrno)) ;

     if (strcmp (type, "C") == 0)
       {
	 status = _NFMbuild_attr_list (list);
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (list);
	     MEMclose (&temp_list);
	     _NFMdebug ((fname, "Build Attr List : status = <0x%.8x>\n",
			 status));
	     return (status); 
	   }
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
	    if (strcmp (type, "C") == 0)
	      {
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
		strcpy (advice_string, data [offset+2]) ;
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

 long _NFMmake_range_buf (min, max, list)
   char     *min, *max;
   MEMptr   *list;
   {
     static char *fname = "_NFMmake_range_buf" ;
     long    status;
     char    sql_str [512], datatype [20] ;

     _NFMdebug ((fname, "Min = <%s> : Max = <%s>\n", 
		 min, max));

     status = MEMopen (list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
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

	sprintf (datatype, "char(%d)", NFM_MINVALUE) ;
	status = MEMwrite_format (*list, "n_minvalue", datatype) ;
	if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }

	sprintf (datatype, "char(%d)", NFM_MAXVALUE) ;
	status = MEMwrite_format (*list, "n_maxvalue", datatype) ;
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }

     
     sprintf (sql_str, "%s\001%s\001%s\001",
	      "NFM_RANGE",min,max) ;


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
