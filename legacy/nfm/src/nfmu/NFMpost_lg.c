#include "machine.h"
#include "NFMU.h"

extern struct NFMglobal_st NFMglobal ;

long NFMadd_default_working_area (nodename, username, pathname, saname,
				  node_info, sa_info)
  char    *nodename;          /*  i - Name of client node                   */
  char    *username;          /*  i - CLIX username                         */
  char    *pathname;          /*  i - Absolute pathname; 
			              Current working directory             */
  char    *saname;            /*  o - Name of working area    */
  MEMptr  node_info;          /*  i - */
  MEMptr  sa_info;            /* i -  */
{
  char *fname = "NFMadd_default_working_area" ;
  long   status ;
  MEMptr sql_buffer = NULL ;
  char   sql_str [1024], **data ;
  long   nodeno, sano, n_owner ;
  char   n_type [NFM_TYPE+1] ;
  long   _NFMadd_default_sa () ;
  long   _NFMadd_default_node () ;

  _NFMdebug ((fname, "nodename %s : username %s : pathname %s\n",
	      nodename, username, pathname));

  sprintf (sql_str, "select b.n_saname, b.n_owner, b.n_type  from nfmnodes a, nfmstoragearea b \
where a.n_nodename = '%s' and b.n_username = '%s' and b.n_pathname = '%s' and \
b.n_devicetype = 'HD' and a.n_nodeno = b.n_nodeno",
	       nodename, username, pathname) ;

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&sql_buffer) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQL query failed : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  if (status != SQL_I_NO_ROWS_FOUND)
    {
      status = MEMbuild_array (sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&sql_buffer) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n", 
		      status)) ;
	  return (NFM_E_MEM) ;
	}

      data = (char **) sql_buffer -> data_ptr ;
      /* [1] - n_owner, [2] - n_type */
      /* the working area must be "W" or "B" and the nfm user or PUBLIC 
	 owns this working area */
      n_owner = atol (data [1]) ;
      strcpy (n_type, data [2]) ;
      if ( ((strcmp (n_type, "W")==0) || (strcmp (n_type, "B") == 0) || (strcmp (n_type, "D") == 0)) &&
	  ((n_owner==NFMglobal.PUBLIC_userno) || (n_owner==NFMglobal.NFMuserno)))
	{
	  strcpy (saname, data [0]) ;
	}
      else
	{
	  _NFMdebug ((fname, "User has no access to this working area\n")) ;
	  strcpy (saname, "") ;
	}
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "node %s and storagearea %s exist previously\n",
		  nodename, saname)) ;
      return (NFM_S_SUCCESS) ;
    }

  MEMclose (&sql_buffer) ;

  /* does node exist ?? */
  sprintf (sql_str, "select n_nodeno from nfmnodes where n_nodename = '%s'",
	   nodename) ;

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&sql_buffer) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQL query failed : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  

  if (status != SQL_I_NO_ROWS_FOUND)
    {
      status = MEMbuild_array (sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&sql_buffer) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n", 
		      status)) ;
	  return (NFM_E_MEM) ;
	}

      data = (char **) sql_buffer -> data_ptr ;
      nodeno = (long) atol (data [0]) ;


      _NFMdebug ((fname, "node no is %d\n", nodeno)) ;
    } /* node with internet exists */
  else
    {
      /* add a node in nfmnodes */
      status =  _NFMadd_default_node (&nodeno, nodename, node_info) ;
      if (status != NFM_S_SUCCESS)
	{
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "NFMadd_node : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}
    }

  MEMclose (&sql_buffer) ;

  _NFMdebug ((fname, "node no is %d\n", nodeno)) ;
  
  status =  _NFMadd_default_sa (&sano, nodename, username, pathname, 
				saname, nodeno, sa_info) ;
  if ((status != NFM_S_SUCCESS) && (status != NFM_E_DUP_ST_AREA))
    {
      _NFMdebug ((fname, "Add storagea area failed : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_S_SUCCESS) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL : saname is %s\n", saname)) ;
  return (NFM_S_SUCCESS) ;
}
  
  
long _NFMadd_default_sa (sano, nodename, username, path, saname, nodeno, 
			 sano_info) 
     long *sano ;
     char *nodename, *username, *path ;
     char *saname ;
     long nodeno ;
     MEMptr sano_info ;
{
  static char *fname = "_NFMadd_default_sa" ;
  long status, i, offset ;
  char *sql_str, *values, *cols, **data, tmp_str [50];
  char wa_type [NFM_TYPE+1], e_passwd [NFM_PASSWD+1] ;
  char e_passwd_t [NFM_PASSWD+1] ;

  _NFMdebug ((fname, "ENTER : nodename %s username %s path %s\n",
	      nodename, username, path)) ;

  status = NFMget_serial_slot (NFMglobal.NFMuserid, "nfmstoragearea", "n_sano",
			       sano) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get serial slot failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  sprintf (saname, "wa-%d", *sano) ;

  _NFMdebug ((fname, "saname is %s\n", saname)) ;

  status = MEMbuild_array (sano_info) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }

  cols = (char *) malloc (sano_info->rows * 25) ;
  if (cols == NULL)
    {
      _NFMdebug ((fname, "malloc failed\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  values = (char *) malloc (sano_info->rows * 25) ;
  if (values == NULL)
    {
      free (cols) ;
      _NFMdebug ((fname, "malloc failed\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  sql_str = (char *) malloc ((sano_info->rows * 50)+ 500) ;
  if (sql_str == NULL)
    {
      free (cols) ;
      free (values);
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      _NFMdebug ((fname, "malloc failed\n")) ;
      return (NFM_E_MALLOC) ;
    }

  data = (char **) sano_info -> data_ptr ;
  cols [0] = 0 ; values [0] = 0 ;

  for (i=0; i<sano_info->rows; i++)
    {
      offset = i*sano_info->columns ;
      sprintf (tmp_str, ", %s", data [offset]) ;
      strcat (cols, tmp_str) ;
      sprintf (tmp_str, ", '%s'", data [offset+1]) ;
      strcat (values, tmp_str) ;
    }

  if (! strcmp (NFMglobal.client_type, "PC"))
    {
      strcpy (wa_type, "D") ;
    }
  else
    {
      strcpy (wa_type, "W") ;
    }

  status = NFMencrypt ("", e_passwd) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Encrypting passwd failed\n")) ;
      return (status) ;
    }

  status = NFMparse_string (e_passwd, e_passwd_t) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : Parse String : status = <0x%.8x>\n", 
		  status)) ;
      return (status) ;
    }

  sprintf (sql_str, "Insert into nfmstoragearea (n_sano, n_saname, n_nodeno, n_username, n_passwd, n_pathname, n_devicetype, n_type, n_owner %s) \
values  (%d, '%s', %d, '%s', '%s', '%s', 'HD', '%s', %d %s)",
	   cols, *sano, saname, nodeno, username, e_passwd_t, path, wa_type, 
	   NFMglobal.NFMuserno, values);
  
  status = SQLstmt (sql_str) ;
  if (status != SQL_S_SUCCESS)
    {
      free (cols) ;
      free (values) ;
      free (sql_str) ;
      if (status == SQL_E_DUPLICATE_VALUE)
	{
	  _NFMdebug ((fname, "Duplicate storagearea\n")) ;
	  return (NFM_E_DUP_ST_AREA) ;
	}
      _NFMdebug ((fname, "SQL stmt failed : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  free (cols) ;
  free (values) ;
  free (sql_str) ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMadd_default_node (nodeno, nodename, node_info)
     long *nodeno ;
     char *nodename ;
     MEMptr node_info;
{
  static char *fname = "_NFMadd_default_node" ;
  long status, i, offset, n_machid_exists, n_opsys_exists ; 
  char *values, *cols, *sql_str, **data, tmp_str [200];
  
  _NFMdebug ((fname, "ENTER\n")) ;

  status = NFMget_serial_slot (NFMglobal.NFMuserid, "nfmnodes", "n_nodeno", 
			       nodeno) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "get serial slot : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  status = MEMbuild_array (node_info) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname,  "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  cols = (char *) malloc ((node_info->rows * 25) + 512) ;
  if (cols == NULL)
    {
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      _NFMdebug ((fname, "malloc failed\n")) ;
      return (NFM_E_MALLOC) ;
    }

  values = (char *) malloc ((node_info->rows * 25) + 512) ;
  if (values == NULL)
    {
      free (cols) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      _NFMdebug ((fname, "malloc failed\n")) ;
      return (NFM_E_MALLOC) ;
    }

  sql_str = (char *) malloc ((node_info->rows * 50) + 512) ;
  if (sql_str == NULL)
    {
      free (cols) ;
      free (values);
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      _NFMdebug ((fname, "malloc failed\n")) ;
      return (NFM_E_MALLOC) ;
    }
		 
  data = (char **) node_info -> data_ptr ;
  n_machid_exists = 0 ;
  n_opsys_exists = 0 ;
  cols [0] =0 ; values [0] = 0 ;

  for (i=0; i<node_info->rows ; i++)
    {
      offset = i*node_info->columns ;
      if (strcmp (data [offset], "n_machid") == 0)
	{
	  n_machid_exists = 1 ;
	}
      else if (strcmp (data [offset], "n_opsys") == 0)
	{
	  n_opsys_exists = 1 ;
	}

      _NFMdebug ((fname, "column %s data %s\n", 
		  data [offset], data [offset+1]));

      sprintf (tmp_str, ", %s", data [offset]);
      strcat (cols, tmp_str) ;
      sprintf (tmp_str, ", '%s'", data [offset+1]) ;
      strcat (values, tmp_str) ;
    }
  
  if (! n_machid_exists)
    {
      _NFMdebug ((fname, "machid does not exist in buffer -> default to CLIX\n")) ;
      strcat (cols, " ,n_machid") ;
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
      /* Copying UNIX for machine_id for SUN - SSRS - 7/12/93 */
      strcat (values,  ",  'UNIX'") ;
#else
        strcat (values, ", 'CLIX'") ;
#endif
    }

  if (! n_opsys_exists)
    {
      _NFMdebug ((fname, "opsys does not exist in buffer -> default to UNIX\n")) ;
      strcat (cols, " ,n_opsys") ;
      strcat (values, ", 'UNIX'") ;
    }

  sprintf (sql_str, "Insert into nfmnodes \
(n_nodeno, n_nodename %s) \
  values \
  (%d, '%s' %s)",
      cols, *nodeno, nodename, values) ;

free (cols) ;
free (values) ;
    status = SQLstmt (sql_str) ;
if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
{
  free (sql_str) ;
  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
  _NFMdebug ((fname, "SQLstmt : status = <0x%.8x>\n", status)) ;
  return (NFM_E_SQL_STMT) ;
}
free (sql_str) ;
_NFMdebug ((fname, "SUCCESSFUL : nodeno is %d\n", *nodeno)) ;
return (NFM_S_SUCCESS) ;
  }








