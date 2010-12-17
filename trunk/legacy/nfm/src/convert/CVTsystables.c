#include "machine.h"
#include "CVT.h"
#include "pwd.h"
#include "NFMversion.h"

  extern struct CVTglobal_st CVTglobal ;

/*       Section 1 - status of table 
nfmactivity           C  or N
nfmarchives           C         
nfmattributes         M         
nfmcatalogs           M         
nfmsignoff            M         
nfmcommands           M         
nfmnodes              C         
nfmprocesses          M         
nfmprograms           N         
nfmprojects           M         
nfmreports            N         
nfmsafiles            C         
nfmsavesets           M         
nfmstoragearea        M         
nfmvalues             M         
nfmlists              M         
nfmworkflow           M         
nfmacls               M         
nfmtables             M         
nfmstates             M         
nfmsyscat             N         
nfmtransitions        M         
nfmusers              C         
nfmsysattributes      C         
*/

int CVTnfmactivity (a_data)
char *a_data;
{
  long status, i, y ;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data ;
  int comma, insert, offset;
  char *fname = "CVTnfmactivity";
  char col[50], dat[100], new_date[25];
  char time[10], date[25];

  _NFMdebug ((fname, "ENTER\n")) ;

  /* get data from the old table */
  if (strcmp(a_data, "nfmactivity") == 0)
  {
    sprintf(sql_str, "SELECT n_username, n_projectname, n_catalogname,\
    n_itemname, n_itemrev, n_fileno, n_date, n_time, n_commandname,\
    n_workflowname, n_aclname, n_transitionname, n_oldstatename,\
    n_newstatename, n_successfail, n_failreason FROM o_%s",a_data);
  }
  else
  { 
    sprintf(sql_str, "SELECT n_username, n_projectname, n_catalogname,\
    n_itemname, n_itemrev, n_fileno, n_date, n_time, n_commandname,\
    n_workflowname, n_aclname, n_transitionname, n_oldstatename,\
    n_newstatename, n_successfail, n_failreason FROM o_nfmactivity Where \
    n_commandname = '%s'", a_data);
  } 
  status = SQLquery (sql_str, &buffer, 32*MEM_SIZE) ;
  if (status != SQL_S_SUCCESS) 
  {
	if (status == SQL_I_NO_ROWS_FOUND)
    {
	  _NFMdebug ((fname, "No rows found.\n"));
	  return (NFM_S_SUCCESS);
    }
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
    _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
    return (NFM_E_SQL_QUERY) ;
  }
  
  status = MEMbuild_array (buffer) ;
     if (status != MEM_S_SUCCESS)
       {
		 ERRload_struct(NFM, NFM_E_MEM, "", "");
	     _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
	     return (NFM_E_MEM);
       } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x.%8x>\n", status)) ;
      return (status) ;
    }

  for (i=0; i<buffer->rows; i++)
    {
      comma = 0 ;
      offset = i*buffer->columns ;
      strcpy (sql_str, "INSERT INTO NFMACTIVITY (") ;
      strcpy (sql_str1, ") VALUES (") ;
      for (y=0; y<buffer->columns; y++)
	{
	  insert = 0 ;
	  if (strcmp (column [y], "n_username") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_username") ;
	      sprintf (dat, "'%s'", data [offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_projectname") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_projectname");
	      sprintf(dat, "'%s'", data [offset+y]);
	    }
	  else if (strcmp (column [y], "n_catalogname") == 0)
	    { 
	      insert = 1;
	      strcpy (col, "n_catalogname");
	      sprintf(dat, "'%s'", data [offset+y]);
	    }
	  else if (strcmp (column[y], "n_itemname") == 0)
	    {
	      insert =1;
	      strcpy(col, "n_itemname");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_itemrev") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_itemrev");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_aclname") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_aclname");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column [y], "n_date") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_date") ;
	      status = _CVTconvert_to_timestamp(data[offset+y], date);
	      if (strlen (data[offset+y+1]))
		strcpy (time, data[offset+y+1]);
	      else
		strcpy (time, "00:00:00") ;
	      status = CVTconvert_to_ansi (date, new_date, time) ;
	      if (status != NFM_S_SUCCESS)
		{
		  NFMrollback_transaction (0) ;
		  _NFMdebug ((fname, "CVTconvert_to_ansi : status = <0x%.8x>\n", status));
		  return (NFM_E_MESSAGE);
		}
	      sprintf (dat, "TIMESTAMP '%s'", new_date) ;
	    }
	  else if (strcmp (column[y], "n_commandname") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_commandname");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_workflowname") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_workflowname");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_transitionname") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_transitionname");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_oldstatename") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_oldstatename");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_newstatename") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_newstatename");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_successfail") == 0)
	    {
	      insert = 1;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		}
	      strcpy(col, "n_successfail");
	      sprintf(dat, "%s", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_failreason") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_failreason");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  if (insert)
	    {
	      if (comma)
		{
		  strcat (sql_str, ", ") ;
		  strcat (sql_str1, ", ") ;
		}
	      else comma = 1 ;
	      strcat (sql_str, col) ;
	      strcat (sql_str1, dat) ;
	    }
	} 
      if (comma)
	{
	  /* strcat (sql_str, ")") ;*/
	  strcat (sql_str1, ")") ;
	  strcat (sql_str, sql_str1) ;
	  /*sprintf(query, sql_str);*/ 
	  status = SQLstmt (sql_str) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      NFMrollback_transaction (0) ;
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    } 
	} 
   }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

int CVTnfmarchives (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmarchives";
  char col[50], dat[100], new_date[25], time[25], date[25];
  
  _NFMdebug ((fname, "ENTER\n")) ;
  
  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_archno ON o_%s (n_archiveno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE UNIQUE INDEX o_archlabel ON o_%s (n_label, n_saveset, n_sano)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }

  /* get data from the old table */
  sprintf(sql_str, "SELECT n_archiveno, n_label, n_saveset, n_sano, \
  n_archivedate, n_archivetime, n_novol, n_archivecopies,\
  n_archivesize, n_archivemethod FROM o_%s", table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
	  ERRload_struct(NFM, NFM_E_MEM, "", "");
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  for (i=0; i<buffer->rows; i++)
    {
      comma = 0 ;
      offset = i*buffer->columns ;
      strcpy (sql_str, "INSERT INTO NFMARCHIVES (") ;
      strcpy (sql_str1, ") VALUES (") ;
      for (y=0; y<buffer->columns; y++)
	{
	  insert =0 ;
	  if (strcmp (column [y], "n_archiveno") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		}
	      strcpy (col, "n_archiveno") ;
	      sprintf (dat, "%s", data [offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_label") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_label") ;
	      sprintf (dat, "'%s'", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_saveset") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_saveset") ;
	      sprintf (dat, "'%s'", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_sano") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		}
	      strcpy (col, "n_sano") ;
	      sprintf (dat, "%s", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_archivedate") == 0)
	    {
	      insert = 1 ;
		  if (!strlen(data[offset+y]))
		  {
			insert = 0;
          }
		  if (insert != 0)
		  {
	        strcpy (col, "n_archivedate") ;
	        status = _CVTconvert_to_timestamp(data[offset+y], date);
	        if (strlen (data[offset+y+1]))
		      strcpy (time, data[offset+y+1]);
	        else
		      strcpy (time, "00:00:00") ;
	        status = CVTconvert_to_ansi (date, new_date, time);
	        if (status != NFM_S_SUCCESS)
		    {
		      NFMrollback_transaction (0) ;
		      _NFMdebug ((fname, "CVTconvert_to_ansi : status = <0x%.8x>\n", status));
		      return (NFM_E_MESSAGE);
		   }
	       sprintf (dat, "TIMESTAMP '%s'", new_date) ;
	    }
      }
	  else if (strcmp (column [y], "n_novol") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		}
	      strcpy (col, "n_novol") ;
	      sprintf (dat, "%s", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_archivecopies") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		}
	      strcpy (col, "n_archivecopies") ;
	      sprintf (dat, "%s", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_archivesize") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		}
	      strcpy (col, "n_archivesize") ;
	      sprintf (dat, "%s", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_archivemethod") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_archivemethod") ;
	      sprintf (dat, "'%s'", data[offset+y]) ;
	    }
	  
	  if (insert)
	    {
	      if (comma)
		{
		  strcat (sql_str, ", ") ;
		  strcat (sql_str1, ", ") ;
		}
	      else comma = 1 ;
	      strcat (sql_str, col) ;
	      strcat (sql_str1, dat) ;
	    }
	}
      if (comma)
	{
	  /*strcat (sql_str, ")") ;*/
	  strcat (sql_str1, ")") ;
	  strcat (sql_str, sql_str1) ;
	  /*sprintf(query, sql_str);*/ 

	 status = SQLstmt (sql_str) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      NFMrollback_transaction (0) ;
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
    }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%..8x>\n", status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

int CVTnfmattributes (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024] ;
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  long min_attrno, max_attrno, last_attrno, timestamp_flag ;
  char *fname = "CVTnfmattributes";
  char col[50], dat[100], tmp_str[512] ;
  long CVTcheck_date_name ();

  _NFMdebug ((fname, "ENTER\n")) ;

  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_attrno ON o_%s (n_attrno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE INDEX o_attrtabno ON o_%s (n_tableno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE INDEX o_attrseq ON o_%s (n_seqno, n_tableno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  strcpy (tmp_str, "Select max(n_attrno) from o_nfmattributes") ;

  status = SQLquery (tmp_str, &buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) buffer->data_ptr ;
  last_attrno = atol (data [0]) ;
  _NFMdebug ((fname, "Last attrno in nfmattributes is %d\n", last_attrno)) ;
  status = MEMclose (&buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  min_attrno = 1 ;
  max_attrno = 501;

  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  while (last_attrno >=  min_attrno)
    {
      strcpy (tmp_str, "select n_tableno from nfmtables \
where ((n_tabletype = 'nfmsystem') or \
(n_tablename  = 'catalog' and n_tabletype = 'catalog') or \
  (n_tablename = 'f_catalog' and n_tabletype = 'f_catalog') or \
  (n_tablename = 'nfmsyscat' and n_tabletype = 'catalog') or \
  (n_tablename = 'f_nfmsyscat' and n_tabletype = 'f_catalog'))") ;

  sprintf(sql_str, "SELECT n_attrno, n_tableno, n_name, n_datatype, \
  n_synonym, n_nfmname, n_seqno, n_opentonfm, n_read, n_write,\
  n_update, n_delete, n_null, n_keyin, n_checkin, n_checkout,\
  n_application, n_type, n_lattrno FROM o_%s where n_tableno NOT IN (%s) \
  and n_attrno >= %d and n_attrno < %d \
  order by n_tableno, n_attrno",
	  table_name, tmp_str, min_attrno, max_attrno);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 

  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;

  for (i=0; i<buffer->rows; i++)
    {
      comma = 0 ;
      timestamp_flag = 0 ;
      offset = i*buffer->columns ;
      strcpy (sql_str, "INSERT INTO NFMATTRIBUTES (") ;
      strcpy (sql_str1, ") VALUES (") ;
      for (y=0; y<buffer->columns; y++)
	{
	  insert =0 ;
	  if (strcmp (column [y], "n_attrno") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		}
	      strcpy (col, "n_attrno") ;
	      sprintf (dat, "%s", data [offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_tableno") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		} 
	      strcpy (col, "n_tableno") ;
	      sprintf (dat, "%s", data[offset+y]) ;
	    }
	  else if (strcmp (column[y], "n_name") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_name");
              status = CVTcheck_date_name (data [offset+y], &timestamp_flag) ;
              if (status != NFM_S_SUCCESS)
              {
                 _NFMdebug ((fname, "Failure : check date : status = <0x%.8x>\n",
                             status)) ;
                 return (status) ;
              }
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_synonym") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_synonym");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_datatype") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_datatype");
              if (timestamp_flag)
              strcpy (dat, "'timestamp'") ;
              else
	      sprintf(dat, "'%s'", data[offset + y]);
	    }
	  else if (strcmp (column[y], "n_seqno") == 0)
	    {
	      insert = 1;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		}
	      strcpy(col, "n_seqno");
	      sprintf(dat, "%s", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_read") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_read");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_write") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_write");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_update") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_update");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_delete") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_delete");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_null") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_null");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_checkin") == 0)
	    {
	      insert = 1;
	   strcpy(col, "n_checkin");
	      if (strcmp(data[offset+y], "U") == 0)
		{
		  strcpy(data[offset+y], "Y");
		}
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_checkout") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_checkout");
	      if (strcmp(data[offset+y], "U") == 0)
		{
		  strcpy(data[offset+y], "Y");
		}
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_application") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_application");
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  /*else if (strcmp (column[y], "n_lattrno") == 0)
	    {
	    insert = 1;
	    strcpy(col, "n_lattrno");
	    if (data[offset+y] == "")
	    {
	    strcpy(data[offset+y], 0);
	    }
	    sprintf(dat, "%s", data[offset+y]);
	    }*/
	  
	  if (insert)
	    {
	      if (comma)
		{
		  strcat (sql_str, ", ") ;
		  strcat (sql_str1, ", ") ;
		}
              comma = 1;
	      strcat (sql_str, col) ;
	      strcat (sql_str1, dat) ;
	    }
	}
      if (comma)
	{

	  strcat (sql_str1, ")") ;
	  strcat (sql_str, sql_str1) ;

	  status = SQLstmt (sql_str) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      NFMrollback_transaction (0) ;
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
    }

 status = MEMclose (&buffer) ;
 if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "Failure : MEMclose : status = <0x%.8x>\n", status)) ;
    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
    return (NFM_E_MEM) ;
  }

 min_attrno = max_attrno ;
 max_attrno = max_attrno + 500 ;
} /* while */
  /*status = CVTrename_attr ();
  if (status != NFM_S_SUCCESS)
  {
     NFMrollback_transaction (0) ;
     _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
     return (status); 
  }*/
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

int CVTnfmcatalogs (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmcatalogs";
  char col[50], dat[100], new_date[25], time[25], date[25];
  char tmp_str [512] ;

  _NFMdebug ((fname, "ENTER\n")) ;

  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_catalogno ON o_%s (n_catalogno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE UNIQUE INDEX o_catalogname ON o_%s (n_catalogname)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  /* get data from the old table */
  /*printf("%s\n", table_name);*/
  sprintf(sql_str, "SELECT n_catalogno, n_catalogname, n_catalogdesc, \
  n_stateno, n_aclno, n_application, n_type, n_creator, \
  n_creationdate, n_creationtime, n_updater, n_updatedate, \
  n_updatetime, n_archivestate, n_archiveno, \
  n_pendingflag, n_pendinguser FROM o_%s \
  where n_catalogname != 'nfmsyscat'", table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 

  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  for (i=0; i<buffer->rows; i++)
  {
     offset = i*buffer->columns ;
     strcpy (sql_str, "INSERT INTO NFMCATALOGS (") ;
     strcpy (sql_str1, ") VALUES (") ;
     for (y=0; y<buffer->columns; y++)
       {
	 insert =0 ;
	 if (strcmp (column [y], "n_catalogno") == 0)
	   {
	     insert = 1 ;
	     comma = 1;
             if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma = 1;
	       }
	     strcpy (col, "n_catalogno") ;
	     sprintf (dat, "%s", data [offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_catalogname") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_catalogname") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_catalogdesc") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_catalogdesc") ;
	     strcpy (tmp_str, data [offset+y]) ;
	     NFMparse_string (data[offset+y], tmp_str) ;
	     sprintf (dat, "'%s'", tmp_str) ;
	   }
	 else if (strcmp (column [y], "n_creator") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_creator") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_creationdate") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_creationdate") ;
	     status = _CVTconvert_to_timestamp(data[offset+y], date);
		 if (status != NFM_S_SUCCESS)
		 {
		   _NFMdebug((fname, "_CVTconvert_to_timestamp : status = <0x%.8x>\n", status));
		   return (NFM_E_MESSAGE);
         }
	     if (strlen (data [offset+y+1]))
	       strcpy (time, data[offset+y+1]);
	     else
	       strcpy (time, "00:00:00") ;
	     status = CVTconvert_to_ansi (date, new_date, time);
	     if (status != NFM_S_SUCCESS)
	       {
		 NFMrollback_transaction (0) ;
		 _NFMdebug ((fname, "CVTconvert_to_ansi : status = <0x%.8x>\n", status));
		 return (NFM_E_MESSAGE);
	       }
	     sprintf (dat, "TIMESTAMP '%s'", new_date) ;
	   }
	 else if (strcmp (column [y], "n_updater") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_updater") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_updatedate") == 0)
	   {
	     insert = 1 ;
		 if (!strlen(data[offset+y]))
		 {
		   insert = 0;
         }
		 if (insert != 0)
		 {
	       strcpy (col, "n_updatedate") ;
	       status = _CVTconvert_to_timestamp(data[offset+y], date);
		   if (status != NFM_S_SUCCESS)
		   {
		     _NFMdebug((fname, "_CVTconvert_to_timestamp : status = <0x%.8x>\n", status));
		     return (NFM_E_MESSAGE);
           }
	       if (strlen (data[offset+y+1]))
	         strcpy (time, data[offset+y+1]);
	       else
	         strcpy (time, "00:00:00") ;
	         status = CVTconvert_to_ansi (date, new_date, time);
	         if (status != NFM_S_SUCCESS)
	         {
		       NFMrollback_transaction (0) ;
		       _NFMdebug ((fname, "CVTconvert_to_ansi : status = <0x%.8x>\n", status));
		       return (NFM_E_MESSAGE);
	         }
	         sprintf (dat, "TIMESTAMP '%s'", new_date) ;
	      }
     }  
	 else if (strcmp (column [y], "n_application") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_identifier") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_stateno") == 0)
	   {
	     insert = 1 ;
             if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma = 1;
	       }
	     strcpy (col, "n_stateno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_aclno") == 0)
	   {
	     insert = 1 ;
             if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma = 1;
	       }
	     strcpy (col, "n_aclno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_type") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_type") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 /*else if (strcmp (column [y], "n_archiveno") == 0)
	   {
	   insert = 1 ;
	   strcpy (col, "n_archiveno") ;
	   sprintf (dat, "%s", data[offset+y]) ;
	   }*/
	 else if (strcmp (column [y], "n_archivestate") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_archivestate") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_pendingflag") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_pendingflag") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 
	 if (insert)
	   {
	     if (!comma)
	       {
		 strcat (sql_str, ", ") ;
		 strcat (sql_str1, ", ") ;
	       }
	     strcat (sql_str, col) ;
	     strcat (sql_str1, dat) ;
	   }
	 comma = 0;  
       }
     if (!comma)
       {
	 /*strcat (sql_str, ")") ;*/
	 strcat (sql_str1, ")") ;
	 strcat (sql_str, sql_str1) ;
	 /*sprintf(query, sql_str); */
	 status = SQLstmt (sql_str) ;
	 if (status != SQL_S_SUCCESS)
	   {
	     NFMrollback_transaction (0) ;
	     ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	     _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	     return (NFM_E_SQL_STMT);
	   }
       }
   }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

int CVTnfmsignoff (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024], tmp_str [1024] ;
  MEMptr buffer = NULL, sql_buffer1 = NULL ;
  char **column, **data, **data1 ;
  int comma, insert, offset;
  char *fname = "CVTnfmsignoff";
  char col[50], dat[100], c_stateno[20] ;
  char catalog_name[NFM_CATALOGNAME+1] ;
  long prev_catalog , prev_itemno ;

  _NFMdebug ((fname, "ENTER\n")) ;
  /* get data from the old table */
  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE INDEX o_signoff ON o_%s (n_catalogno, n_itemno, n_userno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }

  sprintf(sql_str, "SELECT n_catalogno, n_itemno, n_userno, \
  n_signoff, n_reason FROM o_%s order by n_catalogno, n_itemno", 
	  table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;

  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%..8x>\n", status)) ;
      return (status) ;
    }
  prev_catalog = -1 ;
  prev_itemno = -1 ;
  catalog_name [0] = 0 ;
  for (i=0; i<buffer->rows; i++)
    {
      comma = 0 ;
      offset = i*buffer->columns ;
      strcpy (sql_str, "INSERT INTO NFMSIGNOFF (") ;
      strcpy (sql_str1, ") VALUES (") ;
      for (y=0; y<buffer->columns; y++)
	{
	  insert =0 ;
	  if (strcmp (column [y], "n_catalogno") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		}
	      strcpy (col, "n_catalogno") ;
	      sprintf (dat, "%s", data [offset+y]) ;
	      if (prev_catalog != atol (data [offset+y]))
		{
		  prev_catalog = atol (data [offset+y]) ;
		  prev_itemno = -1 ;
		  /* get catalogname */
		  sprintf (tmp_str, "Select n_catalogname from o_nfmcatalogs where n_catalogno = %s", data [offset+y]) ;
		  status = SQLquery (tmp_str, &sql_buffer1, MEM_SIZE) ;
		  if (status != SQL_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : SQLquery : status = <0x%.8x>\n",
				  status)) ;
		      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
		      return (NFM_E_SQL_QUERY) ;
		    }

		  status = MEMbuild_array (sql_buffer1) ;
		  if (status != MEM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
				  status)) ;
		      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
		      return (NFM_E_MEM);
		    }
		  data1 = (char **) sql_buffer1->data_ptr ;
		  strcpy (catalog_name, data1 [0]) ;
		  MEMclose (&sql_buffer1) ;
		}
	    }
	  else if (strcmp (column [y], "n_itemno") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_itemno") ;
	      sprintf (dat, "%s", data[offset+y]) ;
	      if (prev_itemno != atol (data [offset+y]))
		{
		  prev_itemno = atol (data [offset+y]) ;
		  /* get stateno */
		  sprintf (tmp_str, "Select n_stateno from %s where n_itemno = %s", catalog_name, data [offset+y]) ;
		  status = SQLquery (tmp_str,  &sql_buffer1, MEM_SIZE) ;
		  if (status != SQL_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : SQLquery : status = <0x%.8x>\n",
				  status)) ;
		      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
		      return (NFM_E_SQL_QUERY) ;
		    }

		  status = MEMbuild_array (sql_buffer1) ;
		  if (status != MEM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
				  status)) ;
		      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
		      return (NFM_E_MEM);
		    }
		  data1 = (char **) sql_buffer1->data_ptr ;
		  strcpy (c_stateno, data1 [0]) ;
		  MEMclose (&sql_buffer1) ;
		}
	    }
	  else if (strcmp (column [y], "n_userno") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		}
	      strcpy (col, "n_userno") ;
	      sprintf (dat, "%s", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_signoff") == 0)
	    {
	      insert = 1 ;
	      if (strcmp (data [offset+y], "H") == 0)
		{
		  strcpy (col, "n_signoff, n_history") ;
		  strcpy (dat, "'X', 'Y'") ;
		}
	      else
		{
		  strcpy (col, "n_signoff, n_history") ;
		  sprintf (dat, "'%s', 'N'", data[offset+y]) ;
		}
	    }
	  else if (strcmp (column [y], "n_reason") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_reason") ;
	      sprintf (dat, "'%s'", data[offset+y]) ;
	    }
	  
	  if (insert)
	    {
	      if (comma)
		{
		  strcat (sql_str, ", ") ;
		  strcat (sql_str1, ", ") ;
		}
	      else comma = 1 ;
	      strcat (sql_str, col) ;
	      strcat (sql_str1, dat) ;
	    }
	}
      if (comma)
	{
	  /*strcat (sql_str, ")") ;*/
	  sprintf (tmp_str, ", %s", c_stateno) ;
	  strcat (sql_str1, tmp_str) ;
	  strcat (sql_str1, ")") ;
	  strcat (sql_str, ", n_stateno") ;
	  strcat (sql_str, sql_str1) ;
	 /* sprintf(query, sql_str);*/ 
	  status = SQLstmt (sql_str) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      NFMrollback_transaction (0) ;
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
    }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
}

int CVTnfmcommands (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmcommands";
  char col[50], dat[100] ;
  
  _NFMdebug ((fname, "ENTER\n")) ;

  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_commno ON o_%s (n_commandno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE UNIQUE INDEX o_commname ON o_%s (n_commandname)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  /* get data from the old table */
  /*printf("%s\n", table_name);*/
  sprintf(sql_str, "SELECT n_commandno, n_commandname, n_entity, \
  n_transcommand, n_nfmcommandno, n_application \
  FROM o_%s", table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "%s", sql_str) ;
      _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  for (i=0; i<buffer->rows; i++)
    {
      offset = i*buffer->columns ;
      strcpy (sql_str, "INSERT INTO NFMCOMMANDS (") ;
      strcpy (sql_str1, ") VALUES (") ;
      for (y=0; y<buffer->columns; y++)
	{
	  insert =0 ;
	  if (strcmp (column [y], "n_commandno") == 0)
	    {
	      insert = 1 ;
	      comma = 1;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		}
	      strcpy (col, "n_commandno");
	      sprintf (dat, "%s", data [offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_commandname") == 0)
	    {
	      insert = 1 ;
	     strcpy (col, "n_commandname") ;
	      if (strcmp (data[offset+y], "Copy Item") == 0)
		{
		  strcpy(data[offset+y], "Copy Item Files");
		}
	      else if (strcmp (data[offset+y], "Copy Set") == 0)
		{
		  strcpy(data[offset+y], "Copy Set Files");
		}
	      else if (strcmp(data[offset+y], "Display List of Files Flagged for Archive") == 0)
		{
		  strcpy(data[offset+y], "Display List of Items Flagged for Archive");
		}
	      else if (strcmp(data[offset+y], "Display List of Files Flagged for Backup") == 0)
		{
		  strcpy(data[offset+y], "Display List of Items Flagged for Backup");
		}
	      else if (strcmp(data[offset+y], "Display List of Files Flagged for Restore") == 0)
		{
		  strcpy(data[offset+y], "Display List of Items Flagged for Restore");
		}
		  else if (strcmp(data[offset+y], "Display List of Files Flagged for Delete") == 0)
	    {
			strcpy(data[offset+y], "Display List of Items Flagged for Delete") ;
        }
	      else if (strcmp(data[offset+y], "Archive Flagged Files") == 0)
		{
		  strcpy(data[offset+y], "Archive Flagged Items");
		}
	      else if (strcmp(data[offset+y], "Backup Flagged Files") == 0)
		{
		  strcpy(data[offset+y], "Backup Flagged Items");
		}
	      else if (strcmp(data[offset+y], "Restore Flagged Files")== 0)
		{
		  strcpy(data[offset+y], "Restore Flagged Items");
		}
	      else if (strcmp(data[offset+y], "Flag Item Files for Archive") == 0)
		{
		  strcpy(data[offset+y], "Flag Item for Archive");
		}
	      else if (strcmp(data[offset+y], "Flag Item Files for Backup") == 0)
		{
		  strcpy(data[offset+y], "Flag Item for Backup");
		}
	      else if (strcmp(data[offset+y], "Flag Item Files for Restore") == 0)
		{
		  strcpy(data[offset+y], "Flag Item for Restore");
		}
	      else if (strcmp(data[offset+y], "Cancel Archive Flag on Item Files") == 0)
		{
		  strcpy(data[offset+y], "Cancel Archive Flag on Item");
		}
	      else if (strcmp(data[offset+y], "Cancel Backup Flag on Item Files") == 0)
		{
		  strcpy(data[offset+y], "Cancel Backup Flag on Item");
		}
	      else if (strcmp(data[offset+y], "Cancel Restore Flag on Item Files") == 0)
		{
		  strcpy(data[offset+y], "Cancel Restore Flag on Item");
		}
	      else if (strcmp(data[offset+y], "Display List of Where Item Used In Set") == 0)
		{
		  strcpy(data[offset+y], "Display List of Where Item Used In Sets");
		}
	      else if (strcmp(data[offset+y], "Display List of Where Item Used In Project") == 0)
		{
		  strcpy(data[offset+y], "Display List of Where Item Used In Projects");
		}
		else if (strcmp(data[offset+y], "Cancel Backup Flag on Project Files") == 0)
		{
		  strcpy(data[offset+y], "Cancel Backup Flag on Project");
        }
		else if (strcmp(data[offset+y], "Cancel Restore Flag on Project Files") == 0)
		{
		  strcpy(data[offset+y], "Cancel Restore Flag on Project");
        }
		else if (strcmp(data[offset+y], "Flag Project Files for Backup") == 0)
		{
		  strcpy(data[offset+y], "Flag Project for Backup");
        }
		else if (strcmp(data[offset+y], "Flag Project Files for Restore") == 0)
		{
		  strcpy(data[offset+y], "Flag Project for Restore");
        }
		else if (strcmp(data[offset+y], "Purge Signoff Users") == 0)
		{
		  strcpy(data[offset+y], "Purge Signoffs");
        }
	      sprintf (dat, "'%s'", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_application") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_application") ;
	      sprintf (dat, "'%s'", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_transcommand") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_transcommand") ;
	      sprintf (dat, "'%s'", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_entity") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_entity") ;
	      if (strcmp(data[offset+y], "NFMNOENTITY") == 0)
		{
		  strcpy(data[offset+y], "N");
		}
	      else if (strcmp (data[offset+y], "NFMSDP") == 0)
		{ 
		  strcpy(data[offset+y], "S");
		}
	      else if (strcmp (data[offset+y], "NFMADMIN") == 0)
		{
		  strcpy(data[offset+y], "A");
		}
	      else if (strcmp (data[offset+y], "NFMCATALOG") == 0)
		{
		  strcpy(data[offset+y], "C");
		}
	      else if (strcmp (data[offset+y], "NFMPROJECT") == 0)
		{
		  strcpy(data[offset+y], "P");
		}
	      else if (strcmp (data[offset + y], "NFMITEM") == 0)
		{
		  strcpy(data[offset+y], "I");
		}
	      sprintf (dat, "'%s'", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_nfmcommandno") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		  comma = 1;
		}
	      strcpy (col, "n_nfmcommandno") ;
	      sprintf (dat, "%s", data[offset+y]) ;
	    }
	  
	  if (insert)
	    {
	      if (!comma)
		{
		  strcat (sql_str, ", ") ;
		  strcat (sql_str1, ", ") ;
		}
	      strcat (sql_str, col) ;
	      strcat (sql_str1, dat) ;
	    }
	  comma = 0;  
	}
      if (!comma)
	{
	  /*strcat (sql_str, ")") ;*/
	  strcat (sql_str1, ")") ;
	  strcat (sql_str, sql_str1) ;
	  /*sprintf(query, sql_str);*/ 
	  status = SQLstmt (sql_str) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      NFMrollback_transaction (0) ;
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "%s", sql_str);
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
    }
  /*	 status = CVTwf ();*/
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

int CVTnfmnodes (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmnodes";
  char col[50], dat[100], tmp_str [512] ;

  _NFMdebug ((fname, "ENTER\n")) ;

  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_nodeno ON o_%s (n_nodeno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE UNIQUE INDEX o_nodename ON o_%s (n_nodename)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }

  sprintf(sql_str, "SELECT n_nodeno, n_nodename, n_nodedesc, \
  n_machid, n_opsys, n_xns, n_tcpip, n_decnet FROM o_%s", table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%..8x>\n", status)) ;
      return (status) ;
    }
  for (i=0; i<buffer->rows; i++)
  {
    offset = i*buffer->columns ;
    strcpy (sql_str, "INSERT INTO NFMNODES (") ;
    strcpy (sql_str1, ") VALUES (") ;
    for (y=0; y<buffer->columns; y++)
      {
	insert =0 ;
	if (strcmp (column [y], "n_nodeno") == 0)
	  {
	    insert = 1 ;
	    comma = 1;
	    if (strcmp(data[offset+y], "") == 0)
	      {
                insert = 0;
	      }
	    strcpy (col, "n_nodeno") ;
	    sprintf (dat, "%s", data [offset+y]) ;
	  }
	else if (strcmp (column [y], "n_nodename") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_nodename") ;
	    sprintf (dat, "'%s'", data[offset+y]) ;
	  }
	else if (strcmp (column [y], "n_nodedesc") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_nodedesc") ;
	    strcpy (tmp_str, data[offset+y]) ;
	    NFMparse_string (data[offset+y], tmp_str) ;
	    sprintf (dat, "'%s'", tmp_str) ;
	  }
	else if (strcmp (column [y], "n_machid") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_machid") ;
	    sprintf (dat, "'%s'", data[offset+y]) ;
	  }
	else if (strcmp (column [y], "n_opsys") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_opsys") ;
	    sprintf (dat, "'%s'", data[offset+y]) ;
	  }
	else if (strcmp (column[y], "n_xns") == 0)
	  {
	    insert = 1;
	    strcpy(col, "n_xns");
	    sprintf(dat, "'%s'", data[offset+y]);
	  }
	else if (strcmp (column[y], "n_tcpip") == 0)
	  {
	    insert = 1;
	    strcpy(col, "n_tcpip");
	    sprintf(dat, "'%s'", data[offset+y]);
	  }
	else if (strcmp (column[y], "n_decnet") == 0)
	  {
	    insert = 1;
	    strcpy(col, "n_decnet");
	    sprintf(dat, "'%s'", data[offset+y]);
	  }
	
	if (insert)
	  {
	    if (!comma)
	      {
		strcat (sql_str, ", ") ;
		strcat (sql_str1, ", ") ;
	      }
	    strcat (sql_str, col) ;
	    strcat (sql_str1, dat) ;
	  }
	comma = 0;  
      }
    if (!comma)
      {
	/*strcat (sql_str, ")") ;*/
	strcat (sql_str1, ")") ;
	strcat (sql_str, sql_str1) ;
/*	sprintf(query, sql_str);*/ 
	status = SQLstmt (sql_str) ;
	if (status != SQL_S_SUCCESS)
	  {
	    NFMrollback_transaction (0) ;
	    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	   _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	   return (NFM_E_SQL_STMT);
	  }
      }
  }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
}

int CVTnfmprocesses (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmprocesses";
  char col[50], dat[100];

  _NFMdebug ((fname, "ENTER\n")) ;
  
  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_procname ON o_%s (n_transitionno, n_itemno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }

  /* get data from the old table */

  sprintf(sql_str, "SELECT n_transitionno, n_seqno, n_prepost \
  FROM o_%s", table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;

  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  for (i=0; i<buffer->rows; i++)
    {
      comma = 0 ;
      offset = i*buffer->columns ;
      strcpy (sql_str, "INSERT INTO NFMPROCESSES (") ;
      strcpy (sql_str1, ") VALUES (") ;
      for (y=0; y<buffer->columns; y++)
	{
	  insert =0 ;
	  if (strcmp (column [y], "n_transitionno") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  comma = 0 ;
		  _NFMdebug ((fname,
			      "No transition no in this entry break\n"));
		  break ;
		}
	      strcpy (col, "n_transitionno") ;
	      sprintf (dat, "%s", data [offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_seqno") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_seqno") ;
	      strcpy (data[offset+y], "1");
	      sprintf (dat, "%s", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_prepost") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_prepost") ;
	      sprintf (dat, "'%s'", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_itemno") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_programno") ;
	      sprintf (dat, "%s", data[offset+y]) ;
	    }
	  
	  if (insert)
	    {
	      if (comma)
		{
		  strcat (sql_str, ", ") ;
		  strcat (sql_str1, ", ") ;
		}
	      else comma = 1 ;
	      strcat (sql_str, col) ;
	      strcat (sql_str1, dat) ;
	    }
	}
      if (comma)
	{
	  /*strcat (sql_str, ")") ;*/
	  strcat (sql_str1, ")") ;
	  strcat (sql_str, sql_str1) ;
	  /*sprintf(query, sql_str);*/ 
	  status = SQLstmt (sql_str) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      NFMrollback_transaction (0) ;
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
    }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
}

int CVTnfmprograms (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmprograms";
  char col[50], dat[100], tmp_str[512] ;

  _NFMdebug ((fname, "ENTER\n")) ;
  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_progname ON o_%s (n_programname)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }

  /* get data from the old table */
  sprintf(sql_str, "SELECT n_programname, n_programdesc \
  FROM o_%s", table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  for (i=0; i<buffer->rows; i++)
    {
      offset = i*buffer->columns ;
      strcpy (sql_str, "INSERT INTO NFMPROPROGRAMS (") ;
      strcpy (sql_str1, ") VALUES (") ;
      for (y=0; y<buffer->columns; y++)
	{
	  insert =0 ;
	  if (strcmp (column [y], "n_programname") == 0)
	    {
	      insert = 1 ;
	      comma = 1;
	      strcpy (col, "n_programname") ;
	      sprintf (dat, "'%s'", data [offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_programdesc") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_programdesc") ;
	      strcpy (tmp_str, data[offset+y]) ;
	      NFMparse_string (data[offset+y], tmp_str) ;
	      sprintf (dat, "'%s'", tmp_str) ;
	    }
	  
	  if (insert)
	    {
	      if (!comma)
		{
		  strcat (sql_str, ", ") ;
		  strcat (sql_str1, ", ") ;
		}
	      strcat (sql_str, col) ;
	      strcat (sql_str1, dat) ;
	    }
	  comma = 0;  
	}
      if (!comma)
	{
	  /*strcat (sql_str, ")") ;*/
	  strcat (sql_str1, ")") ;
	  strcat (sql_str, sql_str1) ;
	  /*sprintf(query, sql_str);*/ 
	  status = SQLstmt (sql_str) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      NFMrollback_transaction (0) ;
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
    }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

int CVTnfmprojects (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmprojects";
  char col[50], dat[100], tmp_str [512] ;

  _NFMdebug ((fname, "ENTER\n")) ;
  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_projno ON o_%s (n_projectno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE UNIQUE INDEX o_projname ON o_%s (n_projectname)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }

  /* get data from the old table */
  sprintf(sql_str, "SELECT n_projectno, n_projectname, n_projectdesc, \
  n_projectmgr, n_stateno, n_aclno, n_archivestate, n_archiveno, \
  n_pendingflag, n_application FROM o_%s", table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  for (i=0; i<buffer->rows; i++)
  {
     offset = i*buffer->columns ;
     strcpy (sql_str, "INSERT INTO NFMPROJECTS (") ;
     strcpy (sql_str1, ") VALUES (") ;
     for (y=0; y<buffer->columns; y++)
       {
	 insert =0 ;
	 if (strcmp (column [y], "n_projectno") == 0)
	   {
	     insert = 1 ;
	     comma = 1;
             if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
	       }
	     strcpy (col, "n_projectno") ;
	     sprintf (dat, "%s", data [offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_projectname") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_projectname") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_projectdesc") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_projectdesc") ;
	     strcpy (tmp_str, data[offset+y]) ;
	     NFMparse_string(data[offset+y], tmp_str) ;
	     sprintf (dat, "'%s'", tmp_str) ;
	   }
	 else if (strcmp (column [y], "n_projectmgr") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_projectmgr") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_stateno") == 0)
	   {
	     insert = 1 ;
             if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma = 1;
	       }
	     strcpy (col, "n_stateno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	   }
	 else if (strcmp (column[y], "n_aclno") == 0)
	   {
	     insert = 1;
             if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma = 1;
	       }
	     strcpy(col, "n_aclno");
	     sprintf(dat, "%s", data[offset+y]);
	   }
	 else if (strcmp (column[y], "n_archivestate") == 0)
	   {
	     insert = 1;
	     strcpy(col, "n_archivestate");
	     sprintf(dat, "'%s'", data[offset+y]);
	   }
	 else if (strcmp (column[y], "n_archiveno") == 0)
	   {
	     insert = 1;
             if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma = 1;
	       }
	     strcpy(col, "n_archiveno");
	     sprintf(dat, "%s", data[offset+y]);
	   }
	 else if (strcmp (column[y], "n_pendingflag") == 0)
	   {
	     insert = 1;
	     strcpy(col, "n_pendingflag");
	     sprintf(dat, "'%s'", data[offset+y]);
	   }
	 else if (strcmp (column[y], "n_application") == 0)
	   {
	     insert = 1;
	     strcpy(col, "n_application");
	     sprintf(dat, "'%s'", data[offset+y]);
	   }
	 
	 if (insert)
	   {
	     if (!comma)
	       {
		 strcat (sql_str, ", ") ;
		 strcat (sql_str1, ", ") ;
	       }
	     strcat (sql_str, col) ;
	     strcat (sql_str1, dat) ;
	   }
	 comma = 0;  
       }
     if (!comma)
       {
	 /*strcat (sql_str, ")") ;*/
	 strcat (sql_str1, ")") ;
	 strcat (sql_str, sql_str1) ;
	 /*sprintf(query, sql_str); */
	 status = SQLstmt (sql_str) ;
	 if (status != SQL_S_SUCCESS)
	   {
	     NFMrollback_transaction (0) ;
	     ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	     _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	     return (NFM_E_SQL_STMT);
	   }
       }
   }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

int CVTnfmreports (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  long n_reportno  ;
  char *fname = "CVTnfmreports";
  char col[50], dat[100] ;

  _NFMdebug ((fname, "ENTER\n")) ;
  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_reportno ON o_%s (n_reportno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE UNIQUE INDEX o_report ON o_%s (n_reportname, n_application, n_type, n_apptype)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }

  /* get data from the old table */
  sprintf(sql_str, "SELECT n_reportname, n_application, n_type, \
  n_apptype, n_itemno FROM o_%s where n_type = 'W' or n_type = 'O'", 
	  table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  n_reportno = 0 ;
  for (i=0; i<buffer->rows; i++)
    {
      comma = 0 ;
      ++n_reportno ;
     offset = i*buffer->columns ;
     strcpy (sql_str, "INSERT INTO NFMREPORTS (") ;
     strcpy (sql_str1, ") VALUES (") ;
     for (y=0; y<buffer->columns; y++)
       {
	 insert =0 ;
	 if (strcmp (column [y], "n_reportname") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_reportname") ;
	     sprintf (dat, "'%s'", data [offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_application") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_application") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_type") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_type") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_apptype") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_apptype") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column[y], "n_reportno") == 0)
	   {
	     insert =1 ;
	     strcpy (col, "n_reportno");
	     sprintf(dat, "%d", n_reportno) ;
	   }
	 
	 if (insert)
	   {
	     if (comma)
	       {
		 strcat (sql_str, ", ") ;
		 strcat (sql_str1, ", ") ;
	       }
	     comma = 1 ;
	     strcat (sql_str, col) ;
	     strcat (sql_str1, dat) ;
	   }
       }
     if (comma)
       {
	 /*strcat (sql_str, ")") ;*/
	 strcat (sql_str1, ")") ;
	 strcat (sql_str, sql_str1) ;
	 /*sprintf(query, sql_str);*/ 
	 status = SQLstmt (sql_str) ;
	 if (status != SQL_S_SUCCESS)
	   {
	     NFMrollback_transaction (0) ;
	     ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	     _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	     return (NFM_E_SQL_STMT);
	   }
       }
   }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
}

int CVTnfmsafiles (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmsafiles";
  char col[50], dat[100];

  _NFMdebug ((fname, "ENTER\n")) ;
  /* get data from the old table */
  sprintf(sql_str, "SELECT n_sano, n_catalogno, n_itemno, n_filename \
  FROM o_%s", table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  status = NFMset_autocommit_off(0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  for (i=0; i<buffer->rows; i++)
    {
      offset = i*buffer->columns ;
      strcpy (sql_str, "INSERT INTO NFMSAFILES (") ;
      strcpy (sql_str1, ") VALUES (") ;
      for (y=0; y<buffer->columns; y++)
	{
	  insert =0 ;
	  if (strcmp (column [y], "n_sano") == 0)
	    {
	      insert = 1 ;
	      comma = 1;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		  comma = 1;
		}
	      strcpy (col, "n_sano") ;
	      sprintf (dat, "%s", data [offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_catalogno") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		  comma = 1;
		}
	      strcpy (col, "n_catalogno") ;
	      sprintf (dat, "%s", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_itemno") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		  comma = 1;
		}
	      strcpy (col, "n_itemno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_filename") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_filename") ;
	      sprintf (dat, "'%s'", data[offset+y]) ;
	    }
	  
	  if (insert)
	    {
	      if (!comma)
		{
		 strcat (sql_str, ", ") ;
		 strcat (sql_str1, ", ") ;
	       }
	      strcat (sql_str, col) ;
	      strcat (sql_str1, dat) ;
	    }
	  comma = 0;  
	}
      if (!comma)
	{
	  /*strcat (sql_str, ")") ;*/
	 strcat (sql_str1, ")") ;
	 strcat (sql_str, sql_str1) ;
	 /*sprintf(query, sql_str); */
	 status = SQLstmt (sql_str) ;
	 if (status != SQL_S_SUCCESS)
	   {
	     NFMrollback_transaction (0) ;
	     ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	     _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	     return (NFM_E_SQL_STMT);
	   }
       }
    }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
}

int CVTnfmsavesets (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmsavesets";
  char col[50], dat[100];

  _NFMdebug ((fname, "ENTER\n")) ;
  /* get data from the old table */
  sprintf(sql_str, "SELECT n_archiveno, n_catalogno, n_itemno, n_fileno,\
  n_itemstate, n_restoreno, n_restoredate FROM o_%s", table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  for (i=0; i<buffer->rows; i++)
  {
     offset = i*buffer->columns ;
     strcpy (sql_str, "INSERT INTO NFMSAVESETS (") ;
     strcpy (sql_str1, ") VALUES (") ;
     for (y=0; y<buffer->columns; y++)
       {
	 insert =0 ;
	 if (strcmp (column [y], "n_archiveno") == 0)
	   {
	     insert = 1 ;
	     comma = 1;
             if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
	       }
	     strcpy (col, "n_archiveno") ;
	     sprintf (dat, "%s", data [offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_catalogno") == 0)
	   {
	     insert = 1 ;
             if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma = 1;
	       }
	     strcpy (col, "n_catalogno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_itemno") == 0)
	   {
	     insert = 1 ;
             if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma = 1;
	       }
	     strcpy (col, "n_itemno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_fileno") == 0)
	   {
	     insert = 1 ;
             if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma = 1;
	       }
	     strcpy (col, "n_fileno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_itemstate") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_itemstate") ;
		 if (strcmp(data[offset+y], "I") == 0)
		 {
		   strcpy(data[offset+y], "B");
         }
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_restoreno") == 0)
	   {
	     insert = 1 ;
	     if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		   comma = 1;
	       }
	     strcpy (col, "n_restoreno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	   }
	 /*else if (strcmp (column [y], "n_restoredate") == 0)
	   {
	   insert = 1 ;
	   strcpy (col, "n_restoredate") ;
	   sprintf (dat, "TIMESTAMP '%s'", data[offset+y]) ;
	   }*/

	 if (insert)
	   {
	     if (!comma)
	       {
		 strcat (sql_str, ", ") ;
		 strcat (sql_str1, ", ") ;
	       }
	     strcat (sql_str, col) ;
	     strcat (sql_str1, dat) ;
	   }
	 comma = 0;  
       }
     if (!comma)
       {
	 /*strcat (sql_str, ")") ;*/
	 strcat (sql_str1, ")") ;
	 strcat (sql_str, sql_str1) ;
	 /*sprintf(query, sql_str);*/ 
	 status = SQLstmt (sql_str) ;
	 if (status != SQL_S_SUCCESS)
	   {
	     NFMrollback_transaction (0) ;
	     ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	     _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	     return (NFM_E_SQL_STMT);
	   }
       }
   }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
}

int CVTnfmstoragearea (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset, path ;
  char *fname = "CVTnfmstoragearea";
  char col[50], dat[100], e_passwd_t [NFM_PASSWD+1] ;
  char pth[200], newpath[200], system_dir [100], message [512] ;
  struct passwd *pswd_ptr ;

  _NFMdebug ((fname, "ENTER\n")) ;
  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_sano ON o_%s (n_sano)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE UNIQUE INDEX o_saname ON o_%s (n_saname)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE UNIQUE INDEX o_sanode ON o_%s (n_nodeno, n_username, n_pathname, n_devicetype)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  /* get data from the old table */
  sprintf(sql_str, "SELECT n_sano, n_saname, n_nodeno, n_username, \
  n_passwd, n_pathname, n_devicetype, n_type FROM o_%s", table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "%s", sql_str) ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }

  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  path = 0;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : set autocommit off : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  for (i=0; i<buffer->rows; i++)
    {
      offset = i*buffer->columns ;
      strcpy (sql_str, "INSERT INTO NFMSTORAGEAREA (") ;
      strcpy (sql_str1, ") VALUES (") ;
      for (y=0; y<buffer->columns; y++)
	{
	  insert =0 ;
	  if (strcmp (column [y], "n_sano") == 0)
	    {
	      insert = 1 ;
	      comma = 1;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		}
	      strcpy (col, "n_sano") ;
	      sprintf (dat, "%s", data [offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_saname") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_saname") ;
	      if (strcmp(data[offset+y], "REPORTS") == 0)
		{
                  strcpy(data[offset+y], "SYSTEM");
		  pswd_ptr =  getpwnam("nfmadmin");
		  sprintf(pth, "%s", pswd_ptr -> pw_dir);
		  strcat(pth, "/");
		  /*strcpy(pth, "/usr/nfmadmin/");*/
		  strcat(pth, CVTglobal.env_name);
		  strcat(pth, "/");
		  strcat(pth, "system");
                  /* printf("%s\n", pth);*/
		  path = 1;
		}
	      sprintf (dat, "'%s'", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_nodeno") == 0)
	    {
	      insert = 1 ;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		  comma = 1;
		}
	      strcpy (col, "n_nodeno") ;
	      sprintf (dat, "%s", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_username") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_username") ;
	      sprintf (dat, "'%s'", data[offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_passwd") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_passwd") ;
	      status = NFMparse_string (data[offset+y], e_passwd_t) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : Parse strng : status = <0x%.8x>\n",
			      status)) ;
		  return (status) ;
		}
	      sprintf (dat, "'%s'", e_passwd_t) ;
	    }
	  else if (strcmp (column[y], "n_pathname") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_pathname");
	      if (path)
		{
		  strcpy(data[offset+y], pth); 
		}
	      if ((strcmp(data[offset+6], "OD") == 0) ||
		  (strcmp(data[offset+6], "MO") == 0) ||
		  (strcmp(data[offset+6], "WR") == 0) ||
		  (strcmp(data[offset+6], "OF") ==0))
		{
		  status = CVTconvert_optical_path(data[offset+y], newpath);
		  if (status != NFM_S_SUCCESS)
		    {
		      NFMrollback_transaction (0) ;
		      _NFMdebug ((fname, "Bad Path : status = <0x%.8x>\n", status ));
		      return (status);
		    }
		  strcpy(data[offset+y], newpath);
		}
	      sprintf(dat, "'%s'", data[offset+y]);
	      path = 0; 
	    }
	  else if (strcmp (column[y], "n_devicetype") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_devicetype");
	      if ((strcmp(data[offset+y], "OD") == 0) || 
		  (strcmp(data[offset+y],"MO") == 0) ||  
		  (strcmp(data[offset+y], "WR") == 0)) 
		{
		  strcpy(data[offset+y], "CA");
		}
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  else if (strcmp (column[y], "n_type") == 0)
	    {
	      insert = 1;
	      strcpy(col, "n_type");
	      if (strcmp(data[offset+y], "T") == 0)
		{
		  strcpy(data[offset+y], "W");
		}
	      else if (strcmp(data[offset+y], "P") == 0)
		{
		  strcpy(data[offset+y], "B");
		}
	      if ((strcmp(data[offset+6], "OD") == 0) ||
		  (strcmp(data[offset+6], "MO") == 0) ||
		  (strcmp(data[offset+6], "WR") == 0) ||
		  (strcmp(data[offset+6], "FD") == 0))
		{
		  strcpy(data[offset+y], "B");
		}
	      else if ((strcmp(data[offset+6], "UT") == 0) ||
		       (strcmp(data[offset+6], "CT") == 0) ||
		       (strcmp(data[offset+6], "MT") == 0))
		{
		  strcpy(data[offset+y], "U");
		}
	      sprintf(dat, "'%s'", data[offset+y]);
	    }
	  
	  if (insert)
	    {
	      if (!comma)
		{
		  strcat (sql_str, ", ") ;
		  strcat (sql_str1, ", ") ;
		}
	      strcat (sql_str, col) ;
	      strcat (sql_str1, dat) ;
	    }
	  comma = 0;  
	}
      if (!comma)
	{
	  /*strcat (sql_str, ")") ;*/
	  strcat (sql_str1, ")") ;
	  strcat (sql_str, sql_str1) ;
/*	  sprintf(query, sql_str);  */
	  
	  status = SQLstmt (sql_str) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      NFMrollback_transaction (0) ;
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
    }

  /* n_owner for all storagearea to be 1 */
  status = SQLstmt ("update nfmstoragearea set n_owner = 1") ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : SQLstmt : status = <0x%.8x>\n",status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  status = SQLstmt ("update nfmstoragearea set n_type = 'S' where n_saname  like '%-UTIL'") ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Failure : SQLstmt : status = <0x%.8x>\n",status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  status = SQLstmt ("update nfmstoragearea set n_type = 'I' where n_saname = 'NFMFILES'") ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : SQLstmt : status = <0x%.8x>\n",status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  status = SQLstmt ("update nfmstoragearea set n_type = 'S' where n_saname = 'SYSTEM'") ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : SQLstmt : status = <0x%.8x>\n",status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  status = SQLstmt ("update nfmstoragearea set n_type = 'S' where n_saname = 'UTILITIES'") ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : SQLstmt : status = <0x%.8x>\n",status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  status = SQLstmt ("update nfmstoragearea set n_type = 'W' where n_saname = 'nfm'") ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : SQLstmt : status = <0x%.8x>\n",status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  /* Copying reports storage areas to System storage areas */
  /*   printf("MOVING REPORTS STORAGE AREAS TO SYSTEM STORAGE AREA\n");*/
  
  pswd_ptr = getpwnam("nfmadmin");
  sprintf(pth, "%s", pswd_ptr -> pw_dir);
  strcat(pth, "/");
  
  /*******
    sprintf(command, "mkdir %s%s/system", pth, CVTglobal.env_name);
    status = system(command);
    if (status < 0)
    {
    _NFMdebug ((fname, "system : errno %d\n", errno)) ;
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to mkdir failed") ;
    return (NFM_E_MESSAGE) ;
    }
    *********/
  sprintf (system_dir, "%s/%s/system", pswd_ptr -> pw_dir, 
	   CVTglobal.env_name) ;
  status = mkdir (system_dir, 00000775) ;
  if ((status) && (errno != 17))
    {
      NFMrollback_transaction (0) ;
      sprintf (message, "Could not make dir %s : errno %d", 
	       system_dir, errno) ;
      _NFMdebug ((fname, "%s\n", message)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }

  status = (long) chown (system_dir, (int) getuid (), (int) getgid()) ;
  if (status)
    {
      NFMrollback_transaction (0) ;
      sprintf (message, "Could change owner of dir %s : errno %d", 
	       system_dir, errno) ;
      _NFMdebug ((fname, "%s\n", message)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }


  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      NFMrollback_transaction (0) ;
      _NFMdebug ((fname, "Failure : Set autocommit on : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

int CVTnfmtables (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmtables";
  char col[50], dat[100], tmp_str [512] ;

  _NFMdebug ((fname, "ENTER\n")) ;
  /* get data from the old table */

  strcpy (tmp_str, "((n_tabletype != 'nfmsystem') and \
NOT (n_tablename  = 'catalog' and n_tabletype = 'catalog') and \
NOT (n_tablename = 'f_catalog' and n_tabletype = 'f_catalog') and \
NOT (n_tablename = 'nfmsyscat' and n_tabletype = 'catalog') and \
NOT (n_tablename = 'f_nfmsyscat' and n_tabletype = 'f_catalog'))") ;

  sprintf(sql_str, "SELECT n_tableno, n_tablename, n_tabletype \
  FROM o_%s where %s", table_name, tmp_str);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }

  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
    return (NFM_E_MEM);
  } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  for (i=0; i<buffer->rows; i++)
  {
     offset = i*buffer->columns ;
     strcpy (sql_str, "INSERT INTO NFMTABLES (") ;
     strcpy (sql_str1, ") VALUES (") ;
     for (y=0; y<buffer->columns; y++)
       {
	 insert =0 ;
	 if (strcmp (column [y], "n_tableno") == 0)
	   {
	     insert = 1 ;
		 comma = 1;
             if (strcmp(data[offset+y], "") == 0)
             {
               insert = 0;
             }
	     strcpy (col, "n_tableno") ;
	     sprintf (dat, "%s", data [offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_tablename") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_tablename") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_tabletype") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_tabletype") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 
	 if (insert)
	   {
	     if (!comma)
	       {
		 strcat (sql_str, ", ") ;
		 strcat (sql_str1, ", ") ;
	       }
	     strcat (sql_str, col) ;
	     strcat (sql_str1, dat) ;
	   }
	 comma = 0;  
       }
     if (!comma)
       {
	 /*strcat (sql_str, ")") ;*/
	 strcat (sql_str1, ")") ;
	 strcat (sql_str, sql_str1) ;
	 /*sprintf(query, sql_str);*/ 
	 status = SQLstmt (sql_str) ;
	 if (status != SQL_S_SUCCESS)
	   {
	     NFMrollback_transaction (0) ;
	     ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	     _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	     return (NFM_E_SQL_STMT);
	   }
       }
   }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
}

int CVTnfmvalues (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmvalues";
  char col[50], dat[100], tmp_str [512] ;

  _NFMdebug ((fname, "ENTER\n")) ;

  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_valueno ON o_%s (n_attrno, n_type)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }

  /* get data from the old table */
  strcpy (tmp_str, "select n_tableno from nfmtables \
where ((n_tabletype = 'nfmsystem') or \
(n_tablename  = 'catalog' and n_tabletype = 'catalog') or \
(n_tablename = 'f_catalog' and n_tabletype = 'f_catalog') or \
(n_tablename = 'nfmsyscat' and n_tabletype = 'catalog') or \
(n_tablename = 'f_nfmsyscat' and n_tabletype = 'f_catalog'))") ;

  sprintf(sql_str, "SELECT n_attrno, n_defaultno, n_listno, \
  n_defaultvalue, n_maxvalue, n_minvalue, n_programno, n_type \
  FROM o_%s where n_attrno in (select n_attrno from o_nfmattributes where \
  n_tableno NOT IN (%s))", table_name, tmp_str);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      NFMrollback_transaction (0) ;
	  ERRload_struct(NFM, NFM_E_MEM, "", "");
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  for (i=0; i<buffer->rows; i++)
  {
     offset = i*buffer->columns ;
     strcpy (sql_str, "INSERT INTO NFMVALUES (") ;
     strcpy (sql_str1, ") VALUES (") ;
     for (y=0; y<buffer->columns; y++)
       {
	 insert =0 ;
	 if (strcmp (column [y], "n_attrno") == 0)
	   {
		 insert = 1 ;
		 comma = 1;
	     if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
	       }
		 strcpy (col, "n_attrno") ;
		 sprintf (dat, "%s", data [offset+y]) ;
	       }
	 else if (strcmp (column [y], "n_defaultno") == 0)
	   {
	     insert = 1 ;
	     if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma =  1;
	       }
	     strcpy (col, "n_defaultno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_listno") == 0)
	   {
	     insert = 1 ;
	     if (strcmp (data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma = 1;
	       }
	     strcpy (col, "n_listno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_defaultvalue") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_defaultvalue") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_maxvalue") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_maxvalue") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_minvalue") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_minvalue") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_programno") == 0)
	   {
	     insert = 1 ;
	     if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma = 1;
	       }
	     strcpy (col, "n_programno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_type") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_type") ;
	     if (strcmp (data[offset+y], "CHECK") == 0)
	       {
		 strcpy(data[offset+y], "C");
	       }
	     else if (strcmp (data[offset+y], "ADVICE") == 0)
	       {
		 strcpy(data[offset+y], "A");
	       }
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 
	 if (insert)
	   {
	     if (!comma)
	       {
		 strcat (sql_str, ", ") ;
		 strcat (sql_str1, ", ") ;
	       }
	     strcat (sql_str, col) ;
	     strcat (sql_str1, dat) ;
	   }
	 comma = 0;  
       }
     if (!comma)
       {
	 /*strcat (sql_str, ")") ;*/
	 strcat (sql_str1, ")") ;
	 strcat (sql_str, sql_str1) ;
	 /*sprintf(query, sql_str); */
	 status = SQLstmt (sql_str) ;
         if (status != SQL_S_SUCCESS)
	   {
	     NFMrollback_transaction (0) ;
	     ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	     _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	     return (NFM_E_SQL_STMT);
	   }
       }
   }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
}

int CVTnfmworkflow (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmworkflow";
  char col[50], dat[100], tmp_str [512] ;

  _NFMdebug ((fname, "ENTER\n")) ;

  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_wfno ON o_%s (n_workflowno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE UNIQUE INDEX o_wfname ON o_%s (n_workflowname)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  /* get data from the old table */
  sprintf(sql_str, "SELECT n_workflowno, n_workflowname, n_workflowdesc, \
  n_stateno, n_aclno FROM o_%s", table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }

  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
    return (NFM_E_MEM);
  } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  for (i=0; i<buffer->rows; i++)
  {
     offset = i*buffer->columns ;
     strcpy (sql_str, "INSERT INTO NFMWORKFLOW (") ;
     strcpy (sql_str1, ") VALUES (") ;
     for (y=0; y<buffer->columns; y++)
       {
	 insert =0 ;
	 if (strcmp (column [y], "n_workflowno") == 0)
	   {
	     insert = 1 ;
	     comma = 1;
	     if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
	       }
	     strcpy (col, "n_workflowno") ;
	     sprintf (dat, "%s", data [offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_workflowname") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_workflowname") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_stateno") == 0)
	   {
	     insert = 1 ;
	     if (strcmp(data[offset+y], "") == 0)
	       {
		 insert =0;
		 comma = 1;
	       }
	     strcpy (col, "n_stateno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_aclno") == 0)
	   {
	     insert = 1 ;
	     if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma = 1;
	       }
	     strcpy (col, "n_aclno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_workflowdesc") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_workflowdesc") ;
	     strcpy (tmp_str, data [offset+y]) ;
	     NFMparse_string(data[offset+y], tmp_str) ;
	     sprintf (dat, "'%s'", tmp_str) ;
	   }
	 
	 if (insert)
	   {
	     if (!comma)
	       {
		 strcat (sql_str, ", ") ;
		 strcat (sql_str1, ", ") ;
	       }
	     strcat (sql_str, col) ;
	     strcat (sql_str1, dat) ;
	   }
	 comma = 0;  
       }
     if (!comma)
       {
	 /*strcat (sql_str, ")") ;*/
	 strcat (sql_str1, ")") ;
	 strcat (sql_str, sql_str1) ;
	 /*sprintf(query, sql_str); */
	 status = SQLstmt (sql_str) ;
	 if (status != SQL_S_SUCCESS)
	   {
	     NFMrollback_transaction (0) ;
	     ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	     _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	     return (NFM_E_SQL_STMT);
	   }
       }
   }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
}

int CVTnfmacls (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmacls";
  char col[50], dat[100];

  _NFMdebug ((fname, "ENTER\n")) ;
  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_aclno ON o_%s (n_aclno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE INDEX o_aclname ON o_%s (n_aclname)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  /* get data from the old table */
  sprintf(sql_str, "SELECT n_aclno, n_aclname, n_workflowno, \
  n_complete FROM o_%s", table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  for (i=0; i<buffer->rows; i++)
  {
    offset = i*buffer->columns ;
    strcpy (sql_str, "INSERT INTO NFMACLS (") ;
    strcpy (sql_str1, ") VALUES (") ;
    for (y=0; y<buffer->columns; y++)
      {
	insert =0 ;
	if (strcmp (column [y], "n_aclno") == 0)
	  {
	    insert = 1 ;
	    comma = 1;
	    if (strcmp(data[offset+y], "") == 0)
	      {
		insert = 0;
	      }
	    strcpy (col, "n_aclno") ;
	    sprintf (dat, "%s", data [offset+y]) ;
	  }
	else if (strcmp (column [y], "n_aclname") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_aclname") ;
	    sprintf (dat, "'%s'", data[offset+y]) ;
	  }
	else if (strcmp (column [y], "n_workflowno") == 0)
	  {
	    insert = 1 ;
	    if (strcmp(data[offset+y], "") == 0)
	      {
		insert =0;
		comma = 1;
	      }
	    strcpy (col, "n_workflowno") ;
	    sprintf (dat, "%s", data[offset+y]) ;
	  }
	else if (strcmp (column [y], "n_complete") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_complete") ;
	    sprintf (dat, "'%s'", data[offset+y]) ;
	  }
	
	if (insert)
	  {
	    if (!comma)
	      {
		strcat (sql_str, ", ") ;
		strcat (sql_str1, ", ") ;
	      }
	    strcat (sql_str, col) ;
	    strcat (sql_str1, dat) ;
	  }
	comma = 0;  
      }
    if (!comma)
      {
	/*strcat (sql_str, ")") ;*/
	strcat (sql_str1, ")") ;
	strcat (sql_str, sql_str1) ;
/*	sprintf(query, sql_str);*/ 
	status = SQLstmt (sql_str) ;
	if (status != SQL_S_SUCCESS)
	  {
	    NFMrollback_transaction (0) ;
	    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	  }
      }
  }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
}

int CVTnfmlists (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmlists";
  char col[50], dat[100], tmp_str [512] ;

  _NFMdebug ((fname, "ENTER\n")) ;
  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE INDEX o_listno ON o_%s (n_listno, n_value)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }

  /* get data from the old table */
  strcpy (tmp_str, "select n_tableno from nfmtables \
where ((n_tabletype = 'nfmsystem') or \
(n_tablename  = 'catalog' and n_tabletype = 'catalog') or \
(n_tablename = 'f_catalog' and n_tabletype = 'f_catalog') or \
(n_tablename = 'nfmsyscat' and n_tabletype = 'catalog') or \
(n_tablename = 'f_nfmsyscat' and n_tabletype = 'f_catalog'))") ;

  sprintf(sql_str, "SELECT n_listno, n_value FROM o_%s where \
  n_listno in (select n_listno from o_nfmvalues where n_attrno in (select n_attrno from o_nfmattributes where n_tableno NOT IN (%s)))", 
	  table_name, tmp_str);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  for (i=0; i<buffer->rows; i++)
    {
      offset = i*buffer->columns ;
      strcpy (sql_str, "INSERT INTO NFMLISTS (") ;
      strcpy (sql_str1, ") VALUES (") ;
      for (y=0; y<buffer->columns; y++)
	{
	  insert =0 ;
	  if (strcmp (column [y], "n_listno") == 0)
	    {
	      insert = 1 ;
	      comma = 1;
	      if (strcmp(data[offset+y], "") == 0)
		{
		  insert = 0;
		}
	      strcpy (col, "n_listno") ;
	      sprintf (dat, "%s", data [offset+y]) ;
	    }
	  else if (strcmp (column [y], "n_value") == 0)
	    {
	      insert = 1 ;
	      strcpy (col, "n_value") ;
	      sprintf (dat, "'%s'", data[offset+y]) ;
	    }
	  
	  if (insert)
	    {
	      if (!comma)
		{
		  strcat (sql_str, ", ") ;
		  strcat (sql_str1, ", ") ;
		}
	      strcat (sql_str, col) ;
	      strcat (sql_str1, dat) ;
	    }
	  comma = 0;  
	}
      if (!comma)
	{
	  /*strcat (sql_str, ")") ;*/
	  strcat (sql_str1, ")") ;
	  strcat (sql_str, sql_str1) ;
	  /*sprintf(query, sql_str);*/ 
	  status = SQLstmt (sql_str) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      NFMrollback_transaction (0) ;
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	      return (NFM_E_SQL_STMT);
	    }
	}
    }

	strcpy(sql_str, "Insert into nfmlists (n_listno, n_listname, \
	n_value, n_value2) values (41,'devicetypes','TJ','Tape Juke Box')");
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	  return (NFM_E_SQL_STMT);
    }

  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
}

int CVTnfmstates (table_name)
char *table_name;
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data, tmp_str [500] ;
  int comma, insert, offset, prev_wf_no, n_seqno ;
  char *fname = "CVTnfmstates";
  char col[50], dat[100];

  _NFMdebug ((fname, "ENTER\n")) ;
  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_stateno ON o_%s (n_stateno)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE UNIQUE INDEX o_statename ON o_%s (n_workflowno, n_statename)", table_name);
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }

  /* get data from the old table */
  sprintf(sql_str, "SELECT n_stateno, n_statename, n_workflowno, \
  n_signoffs, n_majority, n_transfrom, n_transto FROM o_%s order by n_workflowno, n_stateno", table_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
      return (NFM_E_MEM);
    } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  prev_wf_no = 0 ;
  n_seqno = 1 ;
  for (i=0; i<buffer->rows; i++)
  {
     offset = i*buffer->columns ;
     strcpy (sql_str, "INSERT INTO NFMSTATES (") ;
     strcpy (sql_str1, ") VALUES (") ;
     for (y=0; y<buffer->columns; y++)
       {
	 insert =0 ;
	 if (strcmp (column [y], "n_stateno") == 0)
	   {
	     insert = 1 ;
	     comma = 1;
	     if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
	       }
	     strcpy (col, "n_stateno") ;
	     sprintf (dat, "%s", data [offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_statename") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_statename") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_workflowno") == 0)
	   {
	     insert = 1 ;
	     if (strcmp(data[offset+y], "") == 0)
	       {
		 insert =0;
		 comma = 1;
	       }
	     strcpy (col, "n_workflowno") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	     if (prev_wf_no != atol (data[offset+y]))
	       {
		 n_seqno = 1 ;
		 prev_wf_no = atol (data [offset+y]) ;
	       }
	   }
	 else if (strcmp (column [y], "n_signoffs") == 0)
	   {
	     insert = 1 ;
	     if (strcmp(data[offset+y], "") == 0)
	       {
		 insert = 0;
		 comma = 1;
	       }
	     strcpy (col, "n_signoffs") ;
	     sprintf (dat, "%s", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_majority") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_majority") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_transfrom") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_transfrom") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 else if (strcmp (column [y], "n_transto") == 0)
	   {
	     insert = 1 ;
	     strcpy (col, "n_transto") ;
	     sprintf (dat, "'%s'", data[offset+y]) ;
	   }
	 
	 if (insert)
	   {
	     if (!comma)
	       {
		 strcat (sql_str, ", ") ;
		 strcat (sql_str1, ", ") ;
	       }
	     strcat (sql_str, col) ;
	     strcat (sql_str1, dat) ;
	   }
	 comma = 0;  
       }
     if (!comma)
       {
	 strcat (sql_str,", n_seqno") ;
	 sprintf  (tmp_str, ", %d", n_seqno) ;
	 strcat (sql_str1, tmp_str) ;
	 ++n_seqno ;
	 strcat (sql_str1, ")") ;
	 strcat (sql_str, sql_str1) ;

/*	 sprintf(query, sql_str); */

	 status = SQLstmt (sql_str) ;
	 if (status != SQL_S_SUCCESS)
	   {
	     NFMrollback_transaction (0) ;
	     ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	     _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	     return (NFM_E_SQL_STMT);
	   }
       }
   }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n"));
   return (NFM_S_SUCCESS) ;
}

int CVTnfmsyscat ()
{
  char *fname = "CVTnfmsyscat" ;
  long status ;
  char sql_str[1024]; 

  _NFMdebug ((fname, "ENTER\n")) ;

  sprintf(sql_str, "INSERT INTO NFMSYSCAT (n_rowno, n_infotype,  \
		 n_description) values (1, 'VERSION', '%s')", NFMversion);
  status = SQLstmt (sql_str);
  if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
  {
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
    return (NFM_E_SQL_STMT);
  }

  if (status == SQL_E_DUPLICATE_VALUE)
    _NFMdebug ((fname, "NFMsyscat I/NFM version has already been stamped\n")) ;

  sprintf(sql_str, "INSERT INTO NFMSYSCAT (n_rowno, n_infotype)  \
		 values (2, 'COPY ITEM LOCK')");
  status = SQLstmt (sql_str);
  if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
  {
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
    return (NFM_E_SQL_STMT);
  }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

int CVTnfmtransitions ()
{
  long status, i, y;
  char sql_str[1024], sql_str1[1024];
  MEMptr buffer = NULL;
  char **column, **data;
  int comma, insert, offset;
  char *fname = "CVTnfmtransitions";
  char col[50], dat [100] ;
/*  char new_date[25], time[25], date[25]; */

  /* Create indexes on old tables ****************/

  sprintf(sql_str, "CREATE UNIQUE INDEX o_transno ON o_nfmtransitions (n_transitionno)");
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE UNIQUE INDEX o_transname ON o_nfmtransitions (n_workflowno, n_transitionname, n_fromstate)");
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  sprintf(sql_str, "CREATE UNIQUE INDEX o_transcomm ON o_nfmtransitions (n_workflowno, n_commandno, n_fromstate, n_tostate)");
  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  /* get data from the old table */
  _NFMdebug ((fname, "ENTER\n")) ;
  strcpy (sql_str, "Select n_transitionno, n_transitionname, n_commandno, \
n_fromstate, n_tostate, n_logonsuccess, n_logonfailure, n_notify, \
n_workflowno from o_nfmtransitions") ;

  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
       return (NFM_E_SQL_QUERY) ;
     }

  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
    return (NFM_E_MEM);
  } 
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr ;
  comma = 0 ;
  for (i=0; i<buffer->rows; i++)
  {
    offset = i*buffer->columns ;
    strcpy (sql_str, "INSERT INTO NFMTRANSITIONS (") ;
    strcpy (sql_str1, ") VALUES (") ;
    for (y=0; y<buffer->columns; y++)
      {
	insert =0 ;
	if (strcmp (column [y], "n_transitionno") == 0)
	  {
	    insert = 1 ;
	    comma = 1;
	    strcpy (col, "n_transitionno") ;
	    sprintf (dat, "%s", data [offset+y]) ;
	  }
	else if (strcmp (column [y], "n_transitionname") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_transitionname") ;
	    if (strcmp (data[offset+y], "Copy Item") == 0)
		{
		  strcpy(data[offset+y], "Copy Item Files");
		}
	    else if (strcmp (data[offset+y], "Copy Set") == 0)
		{
		  strcpy(data[offset+y], "Copy Set Files");
		}
	    else if (strcmp(data[offset+y], "Display List of Files Flagged for Archive") == 0)
		{
		  strcpy(data[offset+y], "Display List of Items Flagged for Archive");
		}
	    else if (strcmp(data[offset+y], "Display List of Files Flagged for Backup") == 0)
		{
		  strcpy(data[offset+y], "Display List of Items Flagged for Backup");
		}
	    else if (strcmp(data[offset+y], "Display List of Files Flagged for Restore") == 0)
		{
		  strcpy(data[offset+y], "Display List of Items Flagged for Restore");
		}
	    else if (strcmp(data[offset+y], "Display List of Files Flagged for Delete") == 0)
		{
		  strcpy(data[offset+y], "Display List of Items Flagged for Delete");
		}
	    else if (strcmp(data[offset+y], "Archive Flagged Files") == 0)
		{
		  strcpy(data[offset+y], "Archive Flagged Items");
		}
	    else if (strcmp(data[offset+y], "Backup Flagged Files") == 0)
		{
		  strcpy(data[offset+y], "Backup Flagged Items");
		}
	    else if (strcmp(data[offset+y], "Restore Flagged Files")== 0)
		{
		  strcpy(data[offset+y], "Restore Flagged Items");
		}
	    else if (strcmp(data[offset+y], "Flag Files for Archive") == 0)
		{
		  strcpy(data[offset+y], "Flag Item for Archive");
		}
	    else if (strcmp(data[offset+y], "Flag Files for Backup") == 0)
		{
		  strcpy(data[offset+y], "Flag Item for Backup");
		}
	    else if (strcmp(data[offset+y], "Flag Files for Restore") == 0)
		{
		  strcpy(data[offset+y], "Flag Item for Restore");
		}
	    else if (strcmp(data[offset+y], "Cancel Archive Flag on Files") == 0)
		{
		  strcpy(data[offset+y], "Cancel Archive Flag on Item");
		}
	    else if (strcmp(data[offset+y], "Cancel Backup Flag on Files") == 0)
		{
		  strcpy(data[offset+y], "Cancel Backup Flag on Item");
		}
	    else if (strcmp(data[offset+y], "Cancel Restore Flag on Files") == 0)
		{
		  strcpy(data[offset+y], "Cancel Restore Flag on Item");
		}
	    else if (strcmp(data[offset+y], "Display List of Where Item Used In Set") == 0)
		{
		  strcpy(data[offset+y], "Display List of Where Item Used In Sets");
		}
	    else if (strcmp(data[offset+y], "Display List of Where Item Used In Project") == 0)
		{
		  strcpy(data[offset+y], "Display List of Where Item Used In Projects");
		}
	    else if (strcmp(data[offset+y], "Cancel Backup Flag on Project Files") == 0)
		{
		  strcpy(data[offset+y], "Cancel Backup Flag on Project");
		}
	    else if (strcmp(data[offset+y], "Cancel Restore Flag on Project Files") == 0)
		{
		  strcpy(data[offset+y], "Cancel Restore Flag on Project");
		}
	    else if (strcmp(data[offset+y], "Flag Project Files for Backup") == 0)
		{
		  strcpy(data[offset+y], "Flag Project for Backup");
		}
	    else if (strcmp(data[offset+y], "Flag Project Files for Restore") == 0)
		{
		  strcpy(data[offset+y], "Flag Project for Restore");
		}
	    else if (strcmp(data[offset+y], "Purge Signoff Users") == 0)
		{
		  strcpy(data[offset+y], "Purge Signoffs");
		}
	    sprintf (dat, "'%s'", data[offset+y]) ;
	  }
	else if (strcmp (column [y], "n_commandno") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_commandno") ;
	    sprintf (dat, "%s", data[offset+y]) ;
	  }
	else if (strcmp (column [y], "n_fromstate") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_fromstate") ;
	    sprintf (dat, "%s", data[offset+y]) ;
	  }
	else if (strcmp (column [y], "n_tostate") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_tostate") ;
	    sprintf (dat, "%s", data[offset+y]) ;
	  }
	else if (strcmp (column [y], "n_logonsuccess") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_logonsuccess") ;
	    sprintf (dat, "'%s'", data[offset+y]) ;
	  }
	else if (strcmp (column [y], "n_logonfailure") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_logonfailure") ;
	    sprintf (dat, "'%s'", data[offset+y]) ;
	  }
	else if (strcmp (column [y], "n_notify") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_notify") ;
	    sprintf (dat, "'%s'", data[offset+y]) ;
	  }
	else if (strcmp (column [y], "n_workflowno") == 0)
	  {
	    insert = 1 ;
	    strcpy (col, "n_workflowno") ;
	    sprintf (dat, "%s", data[offset+y]) ;
	  }
	
	if (insert)
	  {
	    if (!comma)
	      {
		strcat (sql_str, ", ") ;
		strcat (sql_str1, ", ") ;
	      }
	    strcat (sql_str, col) ;
	    strcat (sql_str1, dat) ;
	  }
	comma = 0;  
      }
    if (!comma)
      {
	strcat (sql_str1, ")") ;
	strcat (sql_str, sql_str1) ;
	/*sprintf(query, sql_str);*/ 
	
	status = SQLstmt (sql_str) ;
	if (status != SQL_S_SUCCESS)
	  {
	    NFMrollback_transaction (0) ;
	    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	    return (NFM_E_SQL_STMT);
	  }
      }
  }
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

int CVTnfmusers ()
{
  char *fname = "CVTnfmusers" ;
  long status, last_row, user_no ;
  char log_flag[10] ;
  char sql_str[1024];

  _NFMdebug ((fname, "ENTER\n")) ;

  log_flag [0] = 0 ;
  status = CVTquery_cvtlog_entry ("nfmusers",
				  log_flag, &last_row) ;
  if ((status != NFM_S_SUCCESS)  && (status != NFM_I_NO_ROWS_FOUND))
    {
	  ERRload_struct(NFM, NFM_E_FAILURE, "", "");
      _NFMdebug ((fname, "Failure : query cvtlog entry : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_FAILURE) ;
    }
  
  if (strcmp (log_flag, "C"))
    {
      fprintf (stderr, "Performing : Alter table in nfmusers <C>\n") ;
      status = CVTalter_table_add_col ("nfmusers", "n_group", "char(20)") ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : Alter table add columns : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}
	  status = _CVTget_next_slot ("nfmusers", "n_userno", &user_no);
	  sprintf(sql_str, "Insert into nfmusers (n_userno, n_username, n_userdesc) values (%d, '%s', '%s')", user_no, "PUBLIC", "I/NFM Public User");
	  status = SQLstmt(sql_str);
	  if (status != SQL_S_SUCCESS)
	  {
		ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
		_NFMdebug((fname, "Insert stmt failed : status = <0x%.8x>\n", status));
		return (NFM_E_SQL_STMT);
      }
      
      status = CVTupdate_cvtlog ("nfmusers", "C", 0) ;
      if (status != NFM_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_FAILURE, "", "") ;
	  return (NFM_E_FAILURE) ;
	}
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long CVTstamp_status()
{
  char *fname = "CVTstamp_status" ;
  long status, complete, i, offset ;
  long nfmactivity_flag = 0 ;
  long nfmarchives_flag = 0 ;
  long nfmattributes_flag = 0 ;
  long nfmcatalogs_flag = 0 ;
  long nfmsignoff_flag = 0 ;
  long nfmcommands_flag = 0 ;
  long nfmnodes_flag = 0 ;
  long nfmprocesses_flag = 0 ;
  long nfmprograms_flag = 0 ;
  long nfmprojects_flag = 0 ;
  long nfmreports_flag = 0 ;
  long nfmsafiles_flag = 0 ;
  long nfmsavesets_flag = 0 ;
  long nfmstoragearea_flag = 0 ;
  long nfmvalues_flag = 0 ;
  long nfmlists_flag = 0 ;
  long nfmworkflow_flag = 0 ;
  long nfmacls_flag = 0 ;
  long nfmtables_flag = 0 ;
  long nfmstates_flag = 0 ;
  long nfmsyscat_flag = 0 ;
  long nfmtransitions_flag = 0 ;
  long nfmusers_flag = 0 ;
  long nfmsysattributes_flag = 0 ;
  char tmp_str [512] ;
  char **data ;
  MEMptr sql_buffer = NULL ;

  _NFMdebug ((fname, "ENTER\n")) ;
  
  sprintf (tmp_str, "Select n_tablename, n_cvtstatus from nfmconvertlog") ;
  status = SQLquery (tmp_str, &sql_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  if (status != SQL_I_NO_ROWS_FOUND)
    {
      status = MEMbuild_array (sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "failure : status = <0x%.8x>\n", status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}

      data = (char **) sql_buffer->data_ptr ;
      complete = 1 ;
      nfmactivity_flag = 0 ;
      nfmarchives_flag = 0 ;
      nfmattributes_flag = 0 ;
      nfmcatalogs_flag = 0 ;
      nfmsignoff_flag = 0 ;
      nfmcommands_flag = 0 ;
      nfmnodes_flag = 0 ;
      nfmprocesses_flag = 0 ;
      nfmprograms_flag = 0 ;
      nfmprojects_flag = 0 ;
      nfmreports_flag = 0 ;
      nfmsafiles_flag = 0 ;
      nfmsavesets_flag = 0 ;
      nfmstoragearea_flag = 0 ;
      nfmvalues_flag = 0 ;
      nfmlists_flag = 0 ;
      nfmworkflow_flag = 0 ;
      nfmacls_flag = 0 ;
      nfmtables_flag = 0 ;
      nfmstates_flag = 0 ;
      nfmsyscat_flag = 0 ;
      nfmtransitions_flag = 0 ;
      nfmusers_flag = 0 ;
      nfmsysattributes_flag = 0 ;

      for (i=0; i<sql_buffer->rows; i++)
	{
	  if (! complete) break ;
	  offset = i*sql_buffer->columns ;
	  if (! strcmp (data [offset], "nfmactivity"))
	    {
	      nfmactivity_flag = 1 ;
	      if ((strcmp (data[offset+1], "C") &&
		   (strcmp (data[offset+1], "N"))))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmactivity is not C or N\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmarchives"))
	    {
	      nfmarchives_flag = 1 ;
	      if (strcmp (data[offset+1], "C"))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmarchive is not C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmattributes"))
	    {
	      nfmattributes_flag = 1 ;
	      if ((strcmp (data[offset+1], "M"))  &&
		  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmattributes is not M or C : <%s>\n",
			      data [offset+1])) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmcatalogs"))
	    {
	      nfmcatalogs_flag = 1 ;
	      if ((strcmp (data[offset+1], "M"))  &&
		  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmcatalogs is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmsignoff"))
	    {
	      nfmsignoff_flag = 1 ;
	      if ((strcmp (data[offset+1], "M")) &&
                  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmsignoff is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmcommands"))
	    {
	      nfmcommands_flag = 1 ;
	      if ((strcmp (data[offset+1], "M")) &&
                  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmcommands is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmnodes"))
	    {
	      nfmnodes_flag = 1 ;
	      if (strcmp (data[offset+1], "C"))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmnodes is not C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmprocesses"))
	    {
	      nfmprocesses_flag = 1 ;
	      if ((strcmp (data[offset+1], "M")) &&
                  (strcmp (data[offset+1], "C")))

		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmprocesses is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmprograms"))
	    {
	      nfmprograms_flag = 1 ;
	      if ((strcmp (data[offset+1], "N")) &&
                  (strcmp (data[offset+1], "M")) &&
                  (strcmp (data[offset+1], "C")))

		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmprograms is not N or M or c\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmprojects"))
	    {
	      nfmprojects_flag = 1 ;
	      if ((strcmp (data[offset+1], "M")) &&
                  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmprojects is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmreports"))
	    {
	      nfmreports_flag = 1 ;
	      if ((strcmp (data[offset+1], "N")) &&
                  (strcmp (data[offset+1], "M")) &&
		  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmreports is not N or M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmsafiles"))
	    {
	      nfmsafiles_flag = 1 ;
	      if (strcmp (data[offset+1], "C"))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmsafiles is not C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmsavesets"))
	    {
	      nfmsavesets_flag = 1 ;
	      if ((strcmp (data[offset+1], "M")) &&
                  (strcmp (data[offset+1], "C")))

		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmsavesets is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmstoragearea"))
	    {
	      nfmstoragearea_flag = 1 ;
	      if ((strcmp (data[offset+1], "M"))  &&
                  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmstoragearea is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmvalues"))
	    {
	      nfmvalues_flag = 1 ;
	      if ((strcmp (data[offset+1], "M")) &&
                  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmvalues is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmlists"))
	    {
	      nfmlists_flag = 1 ;
	      if ((strcmp (data[offset+1], "M"))  &&
                  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmlists is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset],  "nfmworkflow"))
	    {
	      nfmworkflow_flag = 1 ;
	      if ((strcmp (data[offset+1], "M")) &&
                  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmworkflow is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmacls"))
	    {
	      nfmacls_flag = 1 ;
	      if ((strcmp (data[offset+1], "M"))  &&
                  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmacls is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmtables"))
	    {
	      nfmtables_flag = 1 ;
	      if ((strcmp (data[offset+1], "M")) &&
                  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmtables is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmstates"))
	    {
	      nfmstates_flag = 1 ;
	      if ((strcmp (data[offset+1], "M"))  &&
                  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmstates is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmsyscat"))
	    {
	      nfmsyscat_flag= 1 ;
	      if ((strcmp (data[offset+1], "N")) &&
                  (strcmp (data[offset+1], "M")) &&
                  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmsyscat is not N or M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmtransitions"))
	    {
	      nfmtransitions_flag = 1 ;
	      if ((strcmp (data[offset+1], "M")) &&
                  (strcmp (data[offset+1], "C")))
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmtransitions is not M or C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmusers"))
	    {
	      nfmusers_flag = 1 ;
	      if (strcmp (data[offset+1], "C")) 
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmusers is not C\n")) ;
		}
	    }
	  else if (! strcmp (data [offset], "nfmsysattributes"))
	    {
	      nfmsysattributes_flag = 1 ;
	      if (strcmp (data[offset+1], "C")) 
		{
		  complete = 0 ;
		  _NFMdebug ((fname, "nfmusers is not C\n")) ;
		}
	    }
	}
    }
  else complete = 0 ;

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "failure : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }

  if (complete)
    {
      if ((nfmactivity_flag) && (nfmarchives_flag) &&
	  (nfmattributes_flag) && (nfmcatalogs_flag) &&
	  (nfmsignoff_flag) && (nfmcommands_flag) &&
	  (nfmnodes_flag) && (nfmprocesses_flag) &&
	  (nfmprograms_flag) && (nfmprojects_flag) &&
	  (nfmreports_flag) && (nfmsafiles_flag) &&
	  (nfmsavesets_flag) && (nfmstoragearea_flag) &&
	  (nfmvalues_flag) && (nfmlists_flag) &&
	  (nfmworkflow_flag) && (nfmacls_flag) &&
	  (nfmtables_flag) && (nfmstates_flag) &&
	  (nfmsyscat_flag) && (nfmtransitions_flag) &&
	  (nfmusers_flag) && (nfmsysattributes_flag))
	{
	  status = CVTupdate_cvtlog ("CVTSTATUS1", "C", 0) ;
	  if (status != NFM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	      ERRload_struct (NFM, NFM_E_FAILURE, "", "") ;
	      return (NFM_E_FAILURE) ;
	    }
	}
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long CVTcheck_date_name (n_name, timestamp_flag) 
     char *n_name ;
     long *timestamp_flag ;
{
  char *fname = "CVTcheck_date_name" ;
  struct CVTattr_st *cell = NULL ;

  _NFMdebug ((fname, "ENTER\n")) ;
  *timestamp_flag = 0 ;
  if (CVTglobal.num_of_attr == 0)
    {
      _NFMdebug ((fname, "no date attributes\n")) ;
      return (NFM_S_SUCCESS) ;
    }

  cell = CVTglobal.root_attr ;
  while (cell != NULL)
    {
      if (strcmp (n_name, cell->attr_name) == 0)
	{
	  *timestamp_flag = 1 ;
	  break ;
	}
      cell = cell->next_attr ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

