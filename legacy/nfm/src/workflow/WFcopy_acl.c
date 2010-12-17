#include "machine.h"
#include "WF.h"

 extern struct WFstruct WFinfo;
 extern struct NFMglobal_st NFMglobal ;

long NFMquery_acl_attributes_condition (condition, attr_list, data_list, 
					value_list)
     char      *condition ;                         /*i - where clause */
     MEMptr    *attr_list, *data_list, *value_list; /*o - */
{
  char *fname = "NFMquery_acl_attributes_condition" ;
  long     status;
  char   sql_str [1024], **data, **column ;
  long   column_of_valueno, row_of_wf_no, i, count, a;
  
  _NFMdebug ((fname, "condition : <%s>\n", condition)) ;
  status = NFMquery_table_attributes (NFMglobal.NFMuserid, "nfmsystem",
				      "nfmacls", attr_list, data_list, 
				      value_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (attr_list);
      MEMclose (data_list);
      MEMclose (value_list);
      _NFMdebug ((fname, "Qry Tab Attr : status = <0x%.8x>\n",
		  status));
      return (status);
    }
  
  status = MEMbuild_array (*attr_list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "","") ;
      return (NFM_E_MEM) ;
    }
  
  data = (char **) (*attr_list) -> data_ptr ;
  column = (char **) (*attr_list) -> column_ptr ;
  
  a = -1; column_of_valueno =-1 ;
  
  for (i=0; i< (*attr_list)->columns; i++)
    {
      if (! strcmp (column [i], "n_name")) a = i ;
      else if (! strcmp (column [i], "n_valueno")) column_of_valueno = i+1 ;
    }
  
  count =0 ;
  row_of_wf_no =-1 ;
  
  for (i=0; i< (*attr_list)->rows; i++)
    {
      count = i * (*attr_list)->columns ;
      if (! (strcmp (data[count + a], "n_workflowno")))
	{
	  row_of_wf_no = i+1 ;
	}
    }
  
  sprintf (sql_str, "select n_workflowno, n_workflowname from nfmworkflow where %s order by n_workflowno", condition) ;
  
  status = _NFMadd_to_value_list_from_query (attr_list,
					     value_list,
					     sql_str,
					     row_of_wf_no,
					     column_of_valueno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);      
}

long NFMget_acl_classes_for_copy (old_aclname, new_wfno,
				  synonym_list, value_list)
     char     *old_aclname;          /*i - aclname */
     long     new_wfno ;             /*i - workflow */
     MEMptr   *synonym_list ;        /*o - synonym list */
     MEMptr   *value_list;           /*o  - buffer */
{
  char *fname = "NFMget_acl_classes_for_copy" ;
  long status, i, offset ;
  char datatype [NFM_DATATYPE+1] ;
  char **data ;
  MEMptr sql_buffer = NULL, tmp_list = NULL ;
  char sql_str [1024], tmp_str [1024], value [200] ;

  _NFMdebug ((fname, "old acl <%s> : workflow of new acl <%d>\n",
	      old_aclname, new_wfno)) ;

  sprintf (tmp_str, "where b.n_aclname = '%s' and a.n_workflowno = b.n_workflowno and a.n_workflowtype = 'I'",
	   old_aclname) ;

  /* original workflow must be 'I' */
  status = NFMget_attr_value (NFMglobal.NFMuserid, "nfmworkflow a, nfmacls b",
			      "COUNT(*)",
			      tmp_str, value) ;
  if ((status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  if (atol (value) == 0)
    {
      _NFMdebug ((fname, "Original workflow is not item workflow\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
		      "Select an item workflow") ;
      return (NFM_E_MESSAGE) ;
    }
  
  /* get classes for old acl, put classes of workflow of new acl in v.l. */

  status = MEMopen (value_list, 2 * MEM_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Open : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
  
  sprintf (datatype, "char(%d)", NFM_CLASSNAME) ;
  status = MEMwrite_format (*value_list, "n_classname", datatype) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = MEMwrite_format (*value_list, "n_classno", "integer") ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  sprintf (sql_str, "Select a.n_classname, a.n_classno from nfmclasses a, nfmacls b where b.n_aclname = '%s' and a.n_workflowno = b.n_workflowno",
	   old_aclname) ;

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  
  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  /* no classes for this workflow */
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "No classes for this workflow") ;
	  _NFMdebug ((fname, "Failure : No classes in this workflow\n")) ;
	  return (NFM_E_MESSAGE) ;
	}

      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  
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
  
  for (i=0; i<sql_buffer->rows; i++)
    {
      offset = i*sql_buffer->columns ;
      sprintf (tmp_str, "%s\001%s\001", data [offset], data [offset+1]) ;
      status = MEMwrite (*value_list, tmp_str) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Failure : MEMwrite : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
    }

  MEMclose (&sql_buffer) ;

  /* open buffer */
  status = MEMopen (synonym_list, 2 * MEM_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Open : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = MEMwrite_format (*synonym_list, "type", "char(5)") ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
  
  sprintf (datatype, "char(%d)", NFM_STATENAME) ;
  status = MEMwrite_format (*synonym_list, "name", datatype) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = MEMwrite_format (*synonym_list, "number", "integer") ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
/***
  sprintf (datatype, "char(%d)", NFM_OVERRIDE) ;
  status = MEMwrite_format (*synonym_list, "override", datatype) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
****/
  status = MEMwrite_format (*synonym_list, "n_valueno", "integer") ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }


  status = MEMwrite_format (*synonym_list, "new_number", "integer") ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }


  sprintf (sql_str, "Select distinct n_classname, n_classno from nfmclasses where n_workflowno = %d",
	   new_wfno) ;

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  
  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  /* no classes for this workflow */
	  _NFMdebug ((fname, "Failure : No classes in this workflow\n")) ;
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "No classes in this workflow") ;
	  return (NFM_E_MESSAGE) ;
	}

      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  
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
  
  for (i=0; i<sql_buffer->rows; i++)
    {
      offset =i *sql_buffer->columns ;
      sprintf (tmp_str, "%s\001%s\001%s\001%s\001\001",
	       "class", data [offset], data [offset+1], "1") ;
      status = MEMwrite (*synonym_list, tmp_str) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
    }

  MEMclose (&sql_buffer) ;

  /* check if signoff are in old and new workflow */
  status = MEMopen (&tmp_list, 2 * MEM_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&tmp_list) ;
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Open : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
  
  sprintf (datatype, "char(%d)", NFM_STATENAME) ;
  status = MEMwrite_format (tmp_list, "n_statename", datatype) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&tmp_list) ;
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = MEMwrite_format (tmp_list, "n_stateno", "integer") ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&tmp_list) ;
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  sprintf (sql_str, "Select distinct a.n_statename, a.n_stateno from nfmstates a, nfmacls b  where b.n_aclname = '%s' and a.n_workflowno = b.n_workflowno and a.n_signoffs > 0",
	   old_aclname) ;

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&tmp_list) ;
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  if (status == SQL_I_NO_ROWS_FOUND)
    {
      MEMclose (&tmp_list) ;
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS) ;
    }

  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&tmp_list) ;
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer -> data_ptr ;
  
  for (i=0; i<sql_buffer->rows; i++)
    {
      offset = i *sql_buffer->columns ;
      sprintf (tmp_str, "%s\001%s\001", data [offset], data[offset+1]) ;
      status = MEMwrite (tmp_list, tmp_str) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&tmp_list) ;
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Failure : MEMwrite : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
    }

  MEMclose (&sql_buffer) ;
/*****
  sprintf (sql_str, "Select distinct a.n_statename, a.n_stateno,  b.n_override from nfmstates a, nfmsignoffusers b, nfmacls c where b.n_aclno = c.n_aclno and a.n_stateno = b.n_stateno and c.n_workflowno = %d",
	   new_wfno) ;
******/
  sprintf (sql_str, "Select distinct a.n_statename, a.n_stateno  from nfmstates a, nfmsignoffusers b, nfmacls c where b.n_aclno = c.n_aclno and a.n_stateno = b.n_stateno and c.n_workflowno = %d",
	   new_wfno) ;
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&sql_buffer) ;
      MEMclose (&tmp_list) ;
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  if (status == SQL_I_NO_ROWS_FOUND)
    {
      MEMclose (&sql_buffer) ;
      MEMclose (&tmp_list) ;
      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS) ;
    }

  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      MEMclose (&tmp_str) ;
      _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer -> data_ptr ;
  
  for (i=0; i<sql_buffer->rows; i++)
    {
      offset = i*sql_buffer->columns ;
      sprintf (tmp_str, "%s\001%s\001%s\001%s\001\001", 
	       "state", data [offset], data [offset+1],  "2") ;
      status = MEMwrite (*synonym_list, tmp_str) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&tmp_list) ;
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Failure : MEMwrite : status = <0x%.8x>\n", 
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
    }

  MEMclose (&sql_buffer) ;

  /* attached tmp_list to value_list */
  status = MEMappend (tmp_list, *value_list) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&tmp_list) ;
      _NFMdebug ((fname, "Failure : MEMappend : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  MEMclose (&tmp_list) ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long NFMcopy_acl_users(new_aclname, new_wfno, old_aclname, synonym_list)
     char *new_aclname ;        /* i - new aclname */
     long new_wfno ;            /* i - existing workflow */
     char *old_aclname ;        /* i - existing aclname */
     MEMptr synonym_list ;         /* i - buffer */
{
  char *fname = "NFMcopy_acl_users" ;
  long status, i, offset, j, offset1 ;
  char **data, **column, **data1 ;
  MEMptr sql_buffer = NULL ;
  long type_off, old_number_off,  new_number_off, override_off, aclno ;
  char sql_str [1024], tmp_str [200] ;

  _NFMdebug ((fname, "ENTER\n")) ;
  status = MEMbuild_array (synonym_list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  data = (char **) synonym_list -> data_ptr ;
  column = (char **) synonym_list->column_ptr ;


  /* add acl to nfmacls */
  
  type_off =-1; old_number_off =-1; new_number_off = -1; override_off =-1;
  for (i=0; i<synonym_list->columns; i++)
    {
      if (strcmp (column [i], "type") == 0)      type_off = i;
      else if (strcmp (column [i], "number") == 0) old_number_off = i;
      else if (strcmp (column [i], "new_number") == 0) new_number_off = i;
/*      else if (strcmp (column [i], "override") == 0) override_off = i; */
    }

  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : set autocommit off : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  status = NFMget_serial_slot (NFMglobal.NFMuserid, "nfmacls", "n_aclno",
			       &aclno) ;
  if (status != NFM_S_SUCCESS)
    {
      NFMrollback_transaction (0) ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }


  for (i=0; i<synonym_list->rows; i++)
    {
      offset = i*synonym_list->columns ;
      if (!(atol (data [offset+new_number_off]) > 0)) continue;
      if (strcmp (data [offset+type_off], "class") == 0)
	{
	  /* class */
	  /* update nfmaclusers */
	  sprintf (sql_str, "select n_userno from nfmaclusers where n_aclno = (select n_aclno from nfmacls where n_aclname = '%s') and n_classno = %s",
		   old_aclname, data [offset+new_number_off]) ;
	  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
	  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	    {
	      MEMclose (&sql_buffer) ;
	      NFMrollback_transaction (0) ;
	      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	      return (NFM_E_SQL_QUERY) ;
	    }

	  if (status == SQL_I_NO_ROWS_FOUND)
	    {
	      _NFMdebug ((fname, "No users under acl %s : class %s\n",
			  old_aclname, data [offset+new_number_off])) ;
	      MEMclose (&sql_buffer) ;
	      continue ;
	    }

	  status = MEMbuild_array (sql_buffer) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&sql_buffer) ;
	      NFMrollback_transaction (0) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	      return (NFM_E_MEM) ;
	    }

	  data1 = (char **) sql_buffer->data_ptr ;
	  for (j=0; j<sql_buffer->rows; j++)
	    {
	      sprintf (sql_str, "insert into nfmaclusers (n_aclno, n_classno, n_userno) values (%d, %s, %s)",
		       aclno, data [offset+old_number_off], data1 [j]) ;
	      status = SQLstmt (sql_str) ;
	      if (status != SQL_S_SUCCESS)
		{
		  MEMclose (&sql_buffer) ;
		  NFMrollback_transaction (0) ;
		  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
		  return (NFM_E_SQL_STMT) ;
		}
	    }
	  MEMclose (&sql_buffer) ;
	}
      else
	{
	  /* signoff state */
	  /* class */
	  /* update nfmaclusers */
	  sprintf (sql_str, "select n_userno, n_override from nfmsignoffusers where n_aclno = (select n_aclno from nfmacls where n_aclname = '%s') and n_stateno = %s",
		   old_aclname, data [offset+new_number_off]) ;
	  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
	  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	    {
	      MEMclose (&sql_buffer) ;
	      NFMrollback_transaction (0) ;
	      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	      return (NFM_E_SQL_QUERY) ;
	    }
	  if (status == SQL_I_NO_ROWS_FOUND)
	    {
	      _NFMdebug ((fname, "No signoff users in acl %s : stateno %s\n",
			  old_aclname, data [offset+new_number_off])) ;
	      MEMclose (&sql_buffer) ;
	      continue ;
	    }
	  status = MEMbuild_array (sql_buffer) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&sql_buffer) ;
	      NFMrollback_transaction (0) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	      return (NFM_E_MEM) ;
	    }

	  data1 = (char **) sql_buffer->data_ptr ;
	  for (j=0; j<sql_buffer->rows; j++)
	    {
	      offset1 = j*sql_buffer->columns ;
	      sprintf (sql_str, "insert into nfmsignoffusers (n_aclno, n_stateno, n_userno, n_override) values (%d, %s, %s, '%s')",
		       aclno, data [offset+old_number_off], data1 [offset1],
		       data1 [offset1+1]) ;
	      status = SQLstmt (sql_str) ;
	      if (status != SQL_S_SUCCESS)
		{
		  MEMclose (&sql_buffer) ;
		  NFMrollback_transaction (0) ;
		  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT) ;
		}
	    }
	  MEMclose (&sql_buffer) ;
	}
    }

  status = WFcheck_acl_complete (new_wfno, aclno);
  if (status != NFM_S_SUCCESS          &&
      status != NFM_E_ACL_COMPLETE     &&
      status != NFM_E_ACL_NOT_COMPLETE)
    {
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "Check Acl Usable  : status = <0x%.8x>\n", 
		  status));
      return (status);      
    }
  
  ERRreset_struct () ;
  
  if (status == NFM_E_ACL_COMPLETE)
    {
      strcpy (tmp_str, "Y") ;
    }
  else
    {
      strcpy (tmp_str, "N") ;
    }

  sprintf (sql_str, "insert into nfmacls (n_aclno, n_aclname, n_workflowno, n_complete) values (%d, '%s', %d, '%s')",
	   aclno, new_aclname, new_wfno, tmp_str);

  status = SQLstmt (sql_str) ;
  if (status != SQL_S_SUCCESS)
    {
      NFMrollback_transaction (0) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_STMT) ;
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

