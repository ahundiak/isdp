#include "machine.h"
#include "NFMU.h"

  extern struct NFMglobal_st NFMglobal ;

/**************************************************************************
 *                                                                        *
 *     Function:   NFMchange_working_area_passwd.                         *
 *     Date    :   February 14, 1992                                      *
 *                                                                        *
 *                 This function is used to change an existing working are*
 *                 owned by the user                                      *
 **************************************************************************/

long NFMchange_working_area_passwd (st_name, old_passwd, new_passwd)
     char    *st_name;                  /* I - storagearea area name */
     char    *old_passwd ;              /* I - (decrypted) old passwd */
     char    *new_passwd;               /* I - (decrypted) new passwd */
{
  char *fname = "NFMchange_working_area_passwd" ;
  long      status;
  char      sql_str [1024] ;
  char      **data;
  char      e_old_passwd [51], d_old_passwd [51], e_new_passwd [51];
  char      p_passwd[51];
  long      owner ;
  MEMptr    sql_buffer = NULL;
  
  _NFMdebug ((fname, "St   Name   = <%s>\n", st_name)) ;
  
  sprintf (sql_str, "Select n_owner, n_passwd from nfmstoragearea where n_saname = '%s'",
	   st_name) ;

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", "") ;
	  _NFMdebug ((fname, "Bad storagearea %s\n", st_name)) ;
	  return (NFM_E_BAD_ST_AREA) ;
	}
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer-> data_ptr ;
  owner = atol (data [0]) ;
  strcpy (e_old_passwd, data [1]) ;

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : MEMclose : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  

/* the login user must be the owner */
  if ((!NFMglobal.administrator) && (owner != NFMglobal.NFMuserno))
    {
      _NFMdebug ((fname, "Login user must be the owner of the working area\n")) ;
      ERRload_struct (NFM, NFM_E_LOGIN_USER_MUST_OWN, "", "") ;
      return (NFM_E_LOGIN_USER_MUST_OWN) ;
    }

  if (!NFMglobal.administrator)
    {
      status = NFMdecrypt (e_old_passwd, d_old_passwd);
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "NET Decrypt Passwd : status = <0x%.8x>\n",
		      status));
	  return (status);         
	}
      
      if (strcmp (old_passwd, d_old_passwd))
	{
	  ERRload_struct (NFM, NFM_E_INVALID_PASSWD, "", NULL);
	  _NFMdebug ((fname, "Bad Passwd : status = <0x%.8x>\n", NFM_E_INVALID_PASSWD));
	  return (NFM_E_INVALID_PASSWD);         
	}
    }

  e_new_passwd [0] = 0;      
  status = NFMencrypt (new_passwd, e_new_passwd);
  if (status != NFM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_NET, "", NULL);
      _NFMdebug ((fname, "NET Encrypt Failed : status = <0x%.8x>\n",NFM_E_NET));
      return (status);
    }
  
  status = NFMparse_string (e_new_passwd, p_passwd);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMparse_string Failed : status = <0x%.8x>\n",
		  status));
      return (status);
    }
  
  sprintf (sql_str, "UPDATE NFMSTORAGEAREA SET n_passwd = '%s' \
WHERE n_saname = '%s'",
	   p_passwd, st_name) ;
  
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname, "Sql Stmt : status = <0x%.8x>\n", status));
      return (NFM_E_SQL_STMT);         
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}




