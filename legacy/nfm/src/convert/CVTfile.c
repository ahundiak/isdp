#include "machine.h"
#include "CVT.h"

long CVTresolve_file_attrs (catalog)
     char *catalog ;
{
  char *fname = "CVTresolve_file_attrs" ;
  char str [1024], str1 [1024] ;
  long i,j, status, offset, offset1, mv, fv, next ;
  long last_itemno, min_itemno, max_itemno, pi ;
  char **data, **data1 ;
  char prev_status [NFM_STATUS+1] ;
  MEMptr sql_buffer = NULL, sql_buffer1 = NULL ;
  
  _NFMdebug ((fname, "catalog name <%s>\n", catalog)) ;
  sprintf (str1, "select max(n_itemno) from %s", catalog) ;
  status = SQLquery (str1, &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : SQL query : status = <0x%.8x>\n", 
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer->data_ptr ;
  last_itemno = atol (data [0]) ;

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : MEMclose : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  _NFMdebug ((fname, "1..\n")) ;
  _NFMdebug ((fname, "Item no cofilename when created -> n_filenum = 0\n")) ;
  _NFMdebug ((fname, "CASE 1 : n_cofilename = blank n_status = blank, n_fileversion = 0  -> n_filenum = 0\n")) ;
  
  sprintf (str1, "Update f_%s set n_filenum = 0 where n_fileversion = 0  \
and (n_cofilename = '' OR n_cofilename is NULL)",
		       catalog) ;
	      
  status = SQLstmt (str1) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Failure : SQL stmt : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

/*******************************************************************
  _NFMdebug ((fname, "2a..\n")) ;
  _NFMdebug ((fname, "Item has been checked in/out fileversion is 0\n")) ;

  min_itemno = 1 ;
  max_itemno = 501 ;
  while (last_itemno >= min_itemno)
    {
      sprintf (str, "Select b.n_itemnum, b.n_fileversion \
 from %s a,f_%s b \
where (a.n_status != '' OR NOT(a.n_status is NULL)) \
and a.n_itemno >= %d and a.n_itemno < %d \
and (b.n_cofilename != '' OR NOT(b.n_cofilename is NULL)) \
and a.n_itemno = b.n_itemnum \
order by b.n_itemnum, b.n_fileversion",
	       catalog, catalog, min_itemno, max_itemno) ;
      
      status = SQLquery (str, &sql_buffer, MEM_SIZE) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  _NFMdebug ((fname, "Failure : SQL query : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  return (NFM_E_SQL_QUERY) ;
	}
      
      if (status != SQL_I_NO_ROWS_FOUND)
	{
	  status = MEMbuild_array (sql_buffer) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }

	  data = (char **) sql_buffer -> data_ptr ;
	  pi = -1 ; fv = -1 ;
	  
	  for (j=0 ; j<sql_buffer->rows; j++)
	    {
	      offset=j*sql_buffer -> columns; 
	      if (pi != atol(data [offset])) 
		{
		  if (fv == 0)
		    {
		      sprintf (str1, "Update f_%s set n_fileversion=1 \
 where n_itemnum = %d",
			       catalog, pi) ;
		      status = SQLstmt (str1) ;
		      if (status != SQL_S_SUCCESS)
			{
			  _NFMdebug ((fname, "Failure : SQL stmt : status = <0x%.x8>\n",
				      status)) ;
			  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
			  return (NFM_E_SQL_STMT) ;
			}
		    }
		  pi = atol (data [offset]) ;
		  fv = atol (data [offset+1]) ;
		}
	    }
	}
      status = MEMclose (&sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : MEMclose : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
      min_itemno = max_itemno ;
      max_itemno += 500 ;
    }
**************************************************/

  _NFMdebug ((fname, "2b..\n")) ;
  _NFMdebug ((fname, "Item has not checked in n_cofilename was given\n")) ;
  
  sprintf (str1, "Update f_%s set n_filenum = 1 where \
n_fileversion = 0 \
and (n_cofilename is NOT NULL OR NOT(n_cofilename is NULL))",
	   catalog) ;
  status = SQLstmt (str1) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "Failure : SQL stmt : status = <0x%.x8>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }
  

  _NFMdebug ((fname, "3..\n")) ;
  _NFMdebug ((fname, "CASE 3: n_cofilename != blank n_status != blank -> n_filenum = n\n")) ;
  
  min_itemno = 1 ;
  max_itemno = 501 ;
  while (last_itemno >= min_itemno)
    {
      sprintf (str, "Select b.n_fileno,b.n_fileversion,b.n_itemnum,a.n_status, b.n_cofilename \
from %s a,f_%s b \
where (a.n_status is NOT NULL OR NOT(a.n_status is NULL)) \
and a.n_itemno >= %d and a.n_itemno < %d \
and (b.n_cofilename is NOT NULL OR NOT(b.n_cofilename is NULL)) \
and a.n_itemno = b.n_itemnum order by b.n_itemnum,b.n_fileversion,b.n_cofilename",
	       catalog, catalog, min_itemno, max_itemno) ;


      status = SQLquery (str, &sql_buffer1, MEM_SIZE) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  _NFMdebug ((fname, "Failure : SQL query : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  return (NFM_E_SQL_QUERY) ;
	}
/*
      if (_NFMdebug_st.NFMdebug_on)
	{
	  MEMprint_buffer ("sql buffer1", sql_buffer1, 
			   _NFMdebug_st.NFMdebug_file) ;
	}
*/      
      if (status != SQL_I_NO_ROWS_FOUND)
	{
	  status = MEMbuild_array (sql_buffer1) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }
	  data1 = (char **) sql_buffer1 -> data_ptr ;
	  fv = -1 ; next = 1 ; pi = -1 ;  prev_status [0] = 0 ;
	  for (j=0 ; j<sql_buffer1->rows+1; j++)
	    {
	      offset=j*sql_buffer1 -> columns; 
	      if ((j == sql_buffer1->rows) || 
		  ((pi != -1) && (pi != atol(data1 [offset+2]))))
		{
		  if (strcmp (prev_status, "I") == 0)
		      sprintf (str1, "Update f_%s set n_fileco = 'N' where n_itemnum = %d",
			       catalog, pi) ;
		  else 
		      sprintf (str1, "Update f_%s set n_fileco = 'N' where n_itemnum = %d and n_fileversion != %d",
			       catalog, pi, fv) ;

		  status = SQLstmt (str1) ;
		  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
		    {
		      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
				  status)) ;
		      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
		      return (NFM_E_SQL_STMT) ;
		    }
		  next = 1 ;
		  if (j == sql_buffer1->rows) break ;
		}

	      if (fv != atol (data1 [offset+1])) next = 1 ;

	      sprintf (str1, "Update f_%s set n_filenum = %d where n_fileno = %s",
		       catalog, next++, data1 [offset]) ;
	      status = SQLstmt (str1) ;
	      if (status != SQL_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : SQL stmt : status = <0x%.x8>\n",
			      status)) ;
		  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
		  return (NFM_E_SQL_STMT) ;
		}
	      fv = atol (data1 [offset+1]) ;
	      pi = atol(data1 [offset+2]) ;
	      strcpy (prev_status, data1 [offset+3]) ;
	    }
	}

      status = MEMclose (&sql_buffer1) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : MEMclose : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
      
      min_itemno = max_itemno ;
      max_itemno += 500 ;
    }

  _NFMdebug ((fname, "4..\n")) ;
  _NFMdebug ((fname, "CASE 4 : items previously backed up and purged\n")) ;
  min_itemno = 1;
  max_itemno = 501 ;
  while (last_itemno >= min_itemno)
    {
      sprintf (str, "Select b.n_itemnum,a.n_versionlimit,max(b.n_fileversion) \
from %s a, f_%s b where b.n_itemnum = a.n_itemno \
and a.n_itemno >= %d and a.n_itemno < %d \
 group by b.n_itemnum, a.n_versionlimit",
	       catalog, catalog, min_itemno, max_itemno) ;
      
      status = SQLquery (str, &sql_buffer, MEM_SIZE) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  _NFMdebug ((fname, "Failure : Sql query : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  return (status) ;
	}
      
      if (status != SQL_I_NO_ROWS_FOUND)
	{
	  status = MEMbuild_array (sql_buffer) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }
	  
	  data = (char **) sql_buffer -> data_ptr ;
	  
	  sprintf (str, "select a.n_itemno, b.n_fileversion, b.n_fileno \
from %s a, f_%s b \
where b.n_itemnum = a.n_itemno \
and a.n_itemno >= %d and a.n_itemno < %d \
and b.n_archiveno > 0 and a.n_archivestate = 'B' \
order by a.n_itemno, b.n_fileversion",
		   catalog, catalog, min_itemno, max_itemno) ;
	  
	  status = SQLquery (str, &sql_buffer1, MEM_SIZE) ;
	  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	    {
	      _NFMdebug ((fname, "Failure : Sql query : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	      return (status) ;
	    }
	  
	  if (status != SQL_I_NO_ROWS_FOUND)
	    {
	      status = MEMbuild_array (sql_buffer1) ;
	      if (status != MEM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
			      status)) ;
		  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
		  return (NFM_E_MEM) ;
		}
	      
	      data1 = (char **) sql_buffer1 -> data_ptr ;
	      
	      for (i=0; i<sql_buffer1->rows; i++)
		{
		  offset1 = sql_buffer1->columns * i ;
		  for (j=0; j<sql_buffer->rows; j++)
		    {
		      offset = sql_buffer->columns*j ;
		      _NFMdebug ((fname, "comparing itemnos -> %s with %s\n",
				  data [offset] , data1 [offset1])) ;
		      if (atol (data [offset]) == atol (data1 [offset1]))
			{
			  if (strlen (data[offset+2]))
			    {
			      mv = atol (data [offset+2]) ;
			    }
			  else
			    {
			      mv = 1 ;
			    }
			  _NFMdebug ((fname, "FORMULA -> (backed up version) %s <= (max_version) %d - (version limit) %s\n",
				      data1 [offset1+1], mv, data [offset+1])) ;
			  if (atol(data1[offset1+1]) <= mv - atol(data[offset+1]))
			    {
			      sprintf (str, "Update f_%s set n_fileco = 'O' where n_fileno = %s",
				       catalog, data1 [offset1+2]) ;
			      status = SQLstmt (str) ;
			      if (status != SQL_S_SUCCESS)
				{
				  _NFMdebug ((fname, "Failure : Sql stmt : status = <0x%.8x>\n",
					      status)) ;
				  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
				  return (NFM_E_SQL_STMT) ;
				}
			    }
			}
		    }
		}
	    }
	  status = MEMclose (&sql_buffer1) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "Failure : MEMclose : status = <0x%..8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }
	}
      status = MEMclose (&sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : MEMclose : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
      min_itemno = max_itemno ;
      max_itemno += 500 ;
    }

  /* IF ITEM IS CHECKED IN AND ARCHIVED n_fileco = "O" */
  _NFMdebug ((fname, "5..\n")) ;
  _NFMdebug ((fname, "CASE 5 : n_archivestate = 'A' n_status = 'I' -> n_fileco = 'O'\n")) ;

  min_itemno = 1 ;
  max_itemno = 501 ;
  while (last_itemno >= min_itemno)
    {
      sprintf (str, "Select n_fileno from %s a, f_%s b  where a.n_status = 'I' \
and (a.n_archivestate = 'A') \
and (b.n_archiveno > 0) \
and (a.n_itemno = b.n_itemnum ) \
and a.n_itemno >= %d and a.n_itemno < %d",
	       catalog, catalog, min_itemno, max_itemno) ;
      
      status = SQLquery(str, &sql_buffer, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  _NFMdebug((fname, "Failure : Sql query : status = <0x%.8x>\n", status));
	  ERRload_struct(NFM, NFM_E_SQL_QUERY, "", "");
	  return (NFM_E_SQL_QUERY);
	}
      
      if (status != SQL_I_NO_ROWS_FOUND)
	{
	  status = MEMbuild_array (sql_buffer);
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&sql_buffer);
	      _NFMdebug((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n", status));
	      ERRload_struct(NFM, NFM_E_MEM, "", "");
	      return (NFM_E_MEM);
	    }
	  
	  data = (char **) sql_buffer -> data_ptr;
	  
	  for (i=0; i<sql_buffer->rows; i++)
	    {
	      sprintf (str1, "Update f_%s set n_fileco = 'O' where n_fileno = %s",
		       catalog, data[i]) ;
	      
	      status = SQLstmt (str1) ;
	      if (status != SQL_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : SQL stmt : status = <0x%.8x>\n",
			      status)) ;
		  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
		  return (NFM_E_SQL_STMT) ;
		}
	    }
	}
      
      status = MEMclose (&sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : MEMclose : status = <0x%.8x>\n", status));
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
      min_itemno = max_itemno  ;
      max_itemno += 500 ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

