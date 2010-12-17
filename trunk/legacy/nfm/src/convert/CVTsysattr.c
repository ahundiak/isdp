#include "machine.h"
#include <stdio.h>
#include <string.h>
#include <sys/utsname.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#include <errno.h>
#include "ERR.h"
#include "DEBUG.h"
#include "SQLerrordef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "CVTstruct.h"
#include "NFMstruct.h"
#include "CVTproto.h"
  
  extern struct CVTglobal_st CVTglobal ;

long CVTconvert_nfmsysattributes ()
{
  char *fname = "CVTconvert_nfmsysattributes" ;
  char log_flag [10] ;
  long status, terminate_flag, step, last_row ;
  long CVTdrop_s_tables ()  ;
  long CVTload_attributes_data ()  ;

  _NFMdebug ((fname, "ENTER\n")) ;


  status = CVTquery_cvtlog_entry ("nfmsysattributes",
				  log_flag, &last_row) ;
  if ((status != NFM_S_SUCCESS)  && (status != NFM_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Failure : query cvtlog entry : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "log flag is <%s>\n", log_flag)) ;
  
  if (status == NFM_I_NO_ROWS_FOUND)
    {
      log_flag[0] = 0 ;
    }
  
/* translate the flag into step no */
  if (! strcmp (log_flag, "B")) step = 1 ;
  else if (! strcmp (log_flag, "U")) step = 2 ;
  else if (! strcmp (log_flag, "D")) step = 3 ;
  else if (! strcmp (log_flag, "R")) step = 4 ;
  else if (! strcmp (log_flag, "T")) step = 5 ;
  else if (! strcmp (log_flag, "N")) step = 6 ;
  else if (! strcmp (log_flag, "M")) step = 7 ;
  else if (! strcmp (log_flag, "C")) step = 8 ;
  else step = 0 ;
  
  terminate_flag = 0 ;
  while ((step < 8) && (!terminate_flag))
    {
      _NFMdebug ((fname, "Performing step %d in table <nfmsysattributes>\n",
		  step)) ;
      switch (step)
	{
	  /**** "B" - begin conversion */
	  /** "B" -  check if nfmtables, nfmcatalogs, nfmattributes, 
	             nfmvalues,  nfmlists are in state "M"  **********/
	  /** "B" -  risload from nfmsysattr.dmp 
	    s_nfmtables
	    s_nfmattributes
	    s_nfmsysattributes
	    s_nfmvalues
	    s_nfmlists
	    **/
	    case 0 :
	      log_flag [0] = 0 ;
	      terminate_flag = 1 ;
	      
	      CVTquery_cvtlog_entry ("nfmtables", log_flag, &last_row) ;
	      if (! strcmp (log_flag, "M"))
		{
		  log_flag [0] = 0 ;
	  CVTquery_cvtlog_entry ("nfmcatalogs", log_flag, &last_row) ;
		  if (! strcmp (log_flag, "M"))
		    {
		      log_flag [0] = 0 ;
		      CVTquery_cvtlog_entry ("nfmattributes", log_flag,
					     &last_row) ;
		      if (! strcmp (log_flag, "M"))
			{
			  log_flag [0] = 0 ;
			  CVTquery_cvtlog_entry ("nfmvalues", log_flag, 
						 &last_row) ;
			  if (! strcmp (log_flag, "M"))
			    {
			      log_flag [0]= 0 ;
			      CVTquery_cvtlog_entry ("nfmlists", log_flag, 
						     &last_row) ;
			      if (! strcmp (log_flag, "M"))
				{
				  terminate_flag = 0 ;
				  status = CVTrisload_s_tables () ;
				  if (status != NFM_S_SUCCESS)
				    {
				      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
				      return (status) ;
				    }
				  
				  status=CVTupdate_cvtlog ("nfmsysattributes",
							   "B", 0) ;
				  if (status != NFM_S_SUCCESS)
				    {
				      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
				      return (status) ;
				    }
				  ++step ;
				}
			    }
			}
		    }
		}
	      break ;
  
	      /** "U" - nothing **/
	      case 1 :
		++step ;
		break ;

	      /** "D" - nothing **/
	    case 2 :
	      ++step ;
	      break ;

	      /** "R" - nothing **/
	    case 3 :
	      ++step ;
	      break ;

	      /** "T" - nothing **/
	    case 4 :
	      ++step ;
	      break ;

	      /** "N" -  load nfmsysattributes new schema specifications **/
	    case 5 :
	      status = CVTrisload_new_tables_spec ("nfmsysattributes") ;
	      if (status != NFM_S_SUCCESS)
		{
		}
	      status = CVTupdate_cvtlog ("nfmsysattributes", "N", 0) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		  return (status) ;
		}
	      ++step ;
	      break ;

	      /** "M" -  (template) load from s_nfmtables to nfmtables, 
		          nfmattributes (template), nfmsysattributes, 
			  nfmvalues, nfmlists **/
	    case 6 :
	      status = CVTload_attributes_data () ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
			      status)) ;
		  return (status) ;
		}
	      status = CVTupdate_cvtlog ("nfmsysattributes", "M", 0) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
		  return (status) ;
		}
	      ++step ;
	      break ;

	      /** "C" - drop s_<tables>  ***/
	    case 7 :
	      status = CVTdrop_s_tables () ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		  return (status) ;
		}
	      status = CVTupdate_cvtlog ("nfmsysattributes", "C", 0) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		  return (status) ;
		}
	      ++step ;
	      break ;
	    }
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long CVTload_attributes_data () 
{
  char *fname = "CVTload_attributes_data" ;
  long status, new_attrno ;
  long _CVTconvert_sys() ;
  long _CVTconvert_template() ;
   
  _NFMdebug ((fname, "ENTER\n")) ;
  
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : Set autocommit on : status = <0x%.8x>\n",status)) ;
      return (status) ;
    }

  status = _CVTget_next_slot ("nfmattributes", "n_attrno", &new_attrno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _CVTconvert_sys (&new_attrno) ;
  if (status != NFM_S_SUCCESS)
    {
      NFMrollback_transaction (0) ;
      _NFMdebug ((fname, "Failure : Convert nfmsysattributes : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  status = _CVTconvert_template (&new_attrno) ;
  if (status != NFM_S_SUCCESS)
    {
      NFMrollback_transaction (0) ;
      _NFMdebug ((fname, "Failure : Convert template : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : Set autocommit on : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _CVTconvert_sys(new_attrno)
     long *new_attrno ;
{  
  char *fname = "_CVTconvert_sys" ;
  long status, offset, i, new_table_no ;
  char sql_str[1024],new_catalog_name [200] ;
  char **t_data , **t_column, message [512] ;
  MEMptr nfmtables_buf = NULL ;
  long Convert_nfmattributes () ;

  _NFMdebug ((fname, "ENTER : nfmsysattrno <%d>\n", *new_attrno)) ;
  strcpy (sql_str, 
	  "SELECT n_tableno, n_tablename, n_tabletype, n_identifier from s_nfmtables where n_tabletype = 'nfmsystem'") ;
  
  status = SQLquery (sql_str, &nfmtables_buf, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  MEMclose (&nfmtables_buf) ;
	  sprintf (message, "Catalog <%s> not found in s_nfmtables",
		   new_catalog_name) ;
	  _NFMdebug ((fname, "Failure : %s\n", message)) ;
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
	  return (NFM_E_MESSAGE) ;
	}
      _NFMdebug ((fname, "SQL query failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (nfmtables_buf) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&nfmtables_buf) ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  t_data = (char **) nfmtables_buf->data_ptr ;
  t_column = (char **) nfmtables_buf->column_ptr ;

  status = _CVTget_next_slot ("nfmtables", "n_tableno", &new_table_no) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  for (i=0; i<nfmtables_buf->rows; i++)
    { 
      offset = i*nfmtables_buf->columns ;
      
      sprintf (sql_str, "INSERT into nfmtables (n_tableno, n_tablename, n_tabletype, n_identifier) values (%d, '%s', '%s', '%s')", new_table_no, t_data[offset+1], t_data[offset+2], t_data [offset+3]);

      status = SQLstmt (sql_str) ;
      if (status != SQL_S_SUCCESS)
	  {
	  _NFMdebug ((fname, "SQL stmt failed : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	  return (NFM_E_SQL_STMT) ;
	  }

      status = Convert_nfmattributes (atol (t_data [offset]), new_table_no,
				      "nfmsysattributes", new_attrno) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : status = <0x%..8x>\n", status)) ;
	  return (status) ;
	}
      ++new_table_no ;
    }
  status = MEMclose (&nfmtables_buf) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _CVTconvert_template (new_attrno)
     long *new_attrno ;
{  
  char *fname = "_CVTconvert_template" ;
  long status, offset, i, new_table_no ;
  char sql_str[1024],new_catalog_name [200] ;
  char **t_data , **t_column, message [512] ;
  MEMptr nfmtables_buf = NULL ;
  long Convert_nfmattributes ();

  _NFMdebug ((fname, "ENTER : nfmattributes n_attrno <%d>\n", 
	      *new_attrno)) ;
  strcpy (sql_str, 
	  "SELECT n_tableno, n_tablename, n_tabletype, n_identifier from s_nfmtables where n_tabletype = 't_basic'") ;
  
  status = SQLquery (sql_str, &nfmtables_buf, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  MEMclose (&nfmtables_buf) ;
	  sprintf (message, "Catalog <%s> not found in s_nfmtables",
		   new_catalog_name) ;
	  _NFMdebug ((fname, "%s\n", message)) ;
	  return (NFM_S_SUCCESS) ;
	}
      _NFMdebug ((fname, "SQL query failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (nfmtables_buf) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&nfmtables_buf) ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  t_data = (char **) nfmtables_buf->data_ptr ;
  t_column = (char **) nfmtables_buf->column_ptr ;

  status = _CVTget_next_slot ("nfmtables", "n_tableno", &new_table_no) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%..8x>\n",status));
      return (status) ;
    }

  for (i=0; i<nfmtables_buf->rows; i++)
    { 
      offset = i*nfmtables_buf->columns ;
      
      sprintf (sql_str, "INSERT into nfmtables (n_tableno, n_tablename, n_tabletype, n_identifier) values (%d, '%s', '%s', '%s')", new_table_no, t_data[offset+1], t_data[offset+2], t_data[offset+3]);

      status = SQLstmt (sql_str) ;
      if (status != SQL_S_SUCCESS)
	  {
	  _NFMdebug ((fname, "SQL stmt failed : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	  return (NFM_E_SQL_STMT) ;
	  }

      status = Convert_nfmattributes (atol (t_data [offset]), new_table_no,
				      "nfmattributes", new_attrno) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
	  return (status) ;
	}
      ++new_table_no ;
    }
  status = MEMclose (&nfmtables_buf) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long Convert_nfmattributes (old_table_no, new_table_no, tablename, new_attrno)
     long old_table_no ;
     long new_table_no ;
     char *tablename ;
     long *new_attrno ;
{
  char *fname = "Convert_nfmattributes" ;
  char sql_str [1024] ;
  long status, i, offset ;
  MEMptr nfmattr_buf = NULL ;
  char **a_data , **a_column ;
  long Convert_nfmvalues_nfmlists () ;

  _NFMdebug ((fname, "old table no is %d : new table no is %d\n",
	      old_table_no, new_table_no)) ;

  sprintf (sql_str, 
	   "SELECT n_attrno, n_name, n_synonym, n_datatype, n_seqno, n_read, n_write, n_update, n_delete, n_null, n_checkin, n_checkout, n_application from s_%s where n_tableno = %d",
	  tablename, old_table_no) ;

  status = SQLquery (sql_str, &nfmattr_buf, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "bad table\n")) ;
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad table") ;
	  return (NFM_E_MESSAGE) ;
	}
      
      _NFMdebug ((fname, "SQLquery : status = <0x%.8>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (nfmattr_buf) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&nfmattr_buf) ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
    
  a_data = (char **) nfmattr_buf->data_ptr ;
  a_column = (char **) nfmattr_buf->column_ptr ;

/* n_attrno must be unique across nfmattributes and nfmsysattributes */

  for (i=0; i<nfmattr_buf->rows; i++)
    {
      _NFMdebug ((fname, "new attrno %d\n", *new_attrno)) ;
      offset = i *nfmattr_buf->columns ;
      sprintf (sql_str, "Insert into %s (n_attrno, n_tableno, n_name, n_synonym, n_datatype, n_seqno, n_read, n_write, n_update, n_delete, n_null, n_checkin, n_checkout, n_application) values (%d, %d, '%s', '%s', '%s', %s, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')",
	       tablename,
	       *new_attrno, new_table_no, 
	       a_data [offset+1],
	       a_data [offset+2],
	       a_data [offset+3],
	       a_data [offset+4],
	       a_data [offset+5],
	       a_data [offset+6],
	       a_data [offset+7],
	       a_data [offset+8],
	       a_data [offset+9],
	       a_data [offset+10],
	       a_data [offset+11],
	       a_data [offset+12]) ;

      status = SQLstmt (sql_str) ;
      if (status != SQL_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	  return (NFM_E_SQL_STMT) ;
	}

      status = Convert_nfmvalues_nfmlists (atol(a_data [offset]),
					   *new_attrno) ; /* n_attrno */
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : status = <0x%.8.x>\n", status)) ;
	  return (status) ;
	}

      ++(*new_attrno) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL")) ;
  return (NFM_S_SUCCESS) ;
}

long Convert_nfmvalues_nfmlists (old_attr_no, new_attr_no)
     long old_attr_no, new_attr_no ;
{
  char *fname = "Convert_nfmvalues_nfmlists" ;
  char sql_str [1024] , sql_str1 [512] ; 
  long status, new_list_no, i, offsetx, offseti, x, insert ;
  MEMptr nfmlists_buf = NULL, nfmvalues_buf = NULL ;
  char **l_data, **v_data, s_list_no [10] ;
  char n_defaultno [20], n_programno [20] ;

  _NFMdebug ((fname, "old attrno %d : new attrno %d\n", 
	      old_attr_no,  new_attr_no)) ;

  sprintf (sql_str, "SELECT n_listno, n_defaultno, n_type, n_defaultvalue, n_maxvalue, n_minvalue, n_programno from s_nfmvalues where n_attrno = %d",
	   old_attr_no) ;

  status = SQLquery (sql_str, &nfmvalues_buf, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "No rows found\n")) ;
	  return (NFM_S_SUCCESS) ;
	}
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (nfmvalues_buf) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  status = _CVTget_next_slot ("nfmlists", "n_listno", &new_list_no) ;
  v_data = (char **) nfmvalues_buf->data_ptr ;

  for (x=0; x<nfmvalues_buf->rows; x++)
    {
      offsetx=nfmvalues_buf->columns*x ;
      sprintf (sql_str1, 
	      "SELECT n_listno from s_nfmvalues where n_attrno = %d",
	      old_attr_no) ;
      sprintf (sql_str, 
	      "SELECT n_listno, n_listname, n_value, n_value2 from s_nfmlists where n_listno in (%s)",
	      sql_str1) ;

      status = SQLquery (sql_str, &nfmlists_buf, MEM_SIZE) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  MEMclose (&nfmlists_buf) ;
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  return (NFM_E_SQL_QUERY) ;
	}

      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  MEMclose (&nfmlists_buf) ;
/* if null then insert NULL
	  n_programno
          n_defaultno
          n_listno
*/
	  strcpy (n_defaultno, v_data[offsetx+1]) ;
	  if (! strlen (v_data[offsetx+1]))
	    {
	      strcpy (n_defaultno, "NULL") ;
	    }
	  strcpy (n_programno,  v_data[offsetx+6]) ;
	  if (! strlen (v_data[offsetx+6]))
	    {
	      strcpy (n_programno, "NULL") ;
	    }
	  sprintf (sql_str, "Insert into nfmvalues (n_attrno, n_listno, n_defaultno, n_type, n_defaultvalue, n_maxvalue, n_minvalue, n_programno) values (%d, %d, %s, '%s', '%s', '%s' , '%s', %s)",
		   new_attr_no, v_data [offsetx],
		   n_defaultno,
		   v_data [offsetx+2],
		   v_data [offsetx+3],
		   v_data [offsetx+4],
		   v_data [offsetx+5],
		   n_programno) ;

	  status = SQLstmt (sql_str) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	      return (NFM_E_SQL_STMT) ;
	    }
	  continue ;
	}

      status = MEMbuild_array (nfmlists_buf) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&nfmlists_buf) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
      
      l_data = (char **) nfmlists_buf->data_ptr ;
      
      
      insert = 1 ;
      for (i=0; i<nfmlists_buf->rows; i++)
	{
	  offseti = i*nfmlists_buf->columns ;
	  sprintf (s_list_no, "%d", new_list_no) ;
	  sprintf (sql_str, "Insert into nfmlists (n_listno, n_listname, n_value, n_value2) values (%d, '%s', '%s', '%s')",
		   new_list_no, 
		   l_data [offseti+1],
		   l_data [offseti+2],
		   l_data [offseti+3]) ;

	  status = SQLstmt (sql_str) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	      return (NFM_E_SQL_STMT) ;
	    }
/* new n_type should chop everything but the first character */
	  if (insert)
	    {
	      strcpy (n_defaultno, v_data[offsetx+1]) ;
	      if (! strlen (v_data[offsetx+1]))
		{
		  strcpy (n_defaultno, "NULL") ;
		}
	      strcpy (n_programno,  v_data[offsetx+6]) ;
	      if (! strlen (v_data[offsetx+6]))
		{
		  strcpy (n_programno, "NULL") ;
		}
	      
	      sprintf (sql_str, "Insert into nfmvalues (n_attrno, n_listno, n_defaultno, n_type, n_defaultvalue, n_maxvalue, n_minvalue, n_programno) values (%d, %d, %s, '%s', '%s', '%s' , '%s', %s)",
		       new_attr_no, new_list_no, 
		       n_defaultno,
		       v_data [offsetx+2],
		       v_data [offsetx+3],
		       v_data [offsetx+4],
		       v_data [offsetx+5],
		       n_programno) ;
	      
	      status = SQLstmt (sql_str) ;
	      if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
		  return (NFM_E_SQL_STMT) ;
		}
	      insert = 0 ;
	    }
	}
      ++new_list_no ;
    }

  _NFMdebug ((fname, "SUCCESSFUL")) ;
  return (NFM_S_SUCCESS) ;
}

int CVTrisload_s_tables ()
{
  char *fname = "CVTrisload_s_tables" ;
  char command [500], message [512] ;
/*  char *p ; */
  char str [100] ;
  FILE *fp ;

  long status ;
  struct stat buf ;

  _NFMdebug ((fname, "ENTER\n")) ;
  
  status = stat ("/usr/ip32/nfm/config/convert/s_tables.dmp", &buf) ;
  if (status)
    {
      strcpy (message, "/usr/ip32/nfm/config/convert/s_tables.dmp not found") ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }
/******
  sprintf(command, "cp /usr/ip32/nfm/config/convert/s_tables.dmp s_tables.dmp") ;
  _NFMdebug ((fname, "executing -> %s\n", command)) ;
  status = system(command);
  if (status)
    {
      _NFMdebug ((fname, "Failure : system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  
  status = chmod ("s_tables.dmp", 00777) ;
  if (status)
    {
      _NFMdebug ((fname, "Failure : system errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "chmod call failed") ;
      return (NFM_E_MESSAGE) ;
    }
*************/
  if (strlen (CVTglobal.schema_passwd))
    {
      sprintf (str, "default schema %s.%s\n", 
	       CVTglobal.schema_name, CVTglobal.schema_passwd) ;
    }
  else
    {
      sprintf (str, "default schema %s\n", CVTglobal.schema_name) ;
    }

  if ((fp = fopen("s_tables.dmp", "w"))==NULL)
    {
      _NFMdebug ((fname, "cannot open file s_tables.dmp for writing\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
		      "Can not open file s_table.dmp") ;
      return (NFM_E_MESSAGE) ;
    }
  fprintf(fp, "%s", str);
  fclose(fp);

  sprintf(command, "cat /usr/ip32/nfm/config/convert/s_tables.dmp >> s_tables.dmp") ;
  _NFMdebug ((fname, "executing -> %s\n", command)) ;
  status = system(command);
  if (status)
    {
      _NFMdebug ((fname, "Failure : system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  

  if (strlen (CVTglobal.schema_passwd))
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i s_tables.dmp -e %s -m w -c 100 -s %s .%s table with data s_nfmtables s_nfmattributes s_nfmsysattributes s_nfmvalues s_nfmlists >> %s",
		  CVTglobal.database,
		  CVTglobal.schema_name, CVTglobal.schema_passwd,
		  _NFMdebug_st.NFMdebug_file);
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i s_tables.dmp -e %s -m w -c 100 -s %s .%s table with data s_nfmtables s_nfmattributes s_nfmsysattributes s_nfmvalues s_nfmlists >/dev/null",
		  CVTglobal.database,
		  CVTglobal.schema_name, CVTglobal.schema_passwd);
	}
    }
  else
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i s_tables.dmp -e %s -m w -c 100 -s %s table with data s_nfmtables s_nfmattributes s_nfmsysattributes s_nfmvalues s_nfmlists >> %s",
		  CVTglobal.database,
		  CVTglobal.schema_name, 
		  _NFMdebug_st.NFMdebug_file);
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i s_tables.dmp -e %s -m w -c 100 -s %s table with data s_nfmtables s_nfmattributes s_nfmsysattributes s_nfmvalues s_nfmlists >/dev/null",
		  CVTglobal.database,
		  CVTglobal.schema_name);
	}
    }

  _NFMdebug ((fname, "executing -> %s\n", command)) ;

  status = system(command);
  if (status)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to risload failed") ;
      return (NFM_E_MESSAGE) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
 }

long CVTdrop_s_tables () 
{

  SQLexec_imm ("DROP table s_nfmtables") ;
  SQLexec_imm ("DROP table s_nfmattributes") ;
  SQLexec_imm ("DROP table s_nfmvalues") ;
  SQLexec_imm ("DROP table s_nfmlists") ;

  return (NFM_S_SUCCESS) ;
}
