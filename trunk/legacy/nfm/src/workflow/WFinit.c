#include "machine.h"
#include "WF.h"

  extern struct NFMglobal_st NFMglobal ;
/*** it cleans schema from all workflows and loads nfm workflows */
long _NFMreload_nfm_workflows (comm_filename, sdp_filename,
			       admin_filename, cat_filename,
			       proj_filename, item_filename)
     char *comm_filename, *sdp_filename ;
     char *admin_filename, *cat_filename ;
     char *proj_filename, *item_filename ;
{
  char *fname = "_NFMreload_all_workflows" ;
  long status  ;
  long _NFMclean_workflows_from_schema () ;
  long _NFMinitialize_workflow () ;

  _NFMdebug ((fname, "ENTER\n")) ;
  
  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "failed : status = <0x%.8x>\n")) ;
      return (status) ;
    }
  
  status = _NFMclean_workflows_from_schema () ;
  if (status != NFM_S_SUCCESS) 
    {
      _NFMdebug ((fname, "failed : status = <0x%.8x>\n")) ;
      NFMrollback_transaction (0) ;
      return (status) ;
    }
  
  
  status = _NFMinitialize_workflow (comm_filename, sdp_filename,
				    admin_filename, cat_filename,
				    proj_filename, item_filename) ;

  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "failed : status = <0x%.8x>\n")) ;
      NFMrollback_transaction (0) ;
      return (status) ;
    }
  
  status = NFMset_autocommit_on (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "failed : status = <0x%.8x>\n")) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMclean_workflows_from_schema ()
{
  char *fname = "_NFMclean_workflows_from_schema" ;
  char sql_str [1024] ;
  long status ;

  /* tables deleted 
     - nfmacess 
     - nfmacls
     - nfmaclusers
     - nfmclasses
     - nfmcommands
     - nfmprojects 
     - nfmsignoffusers
     - nfmstates
     - nfmtransitions
     - nfmworkflow
     - nfmprojectaclmap
     - nfmcatalogaclmap
     - nfmcatalogs
*/
  
  strcpy (sql_str, "delete from nfmaccess") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql stmt failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT,"", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  strcpy (sql_str, "delete from nfmacls") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql stmt failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT,"", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  strcpy (sql_str, "delete from nfmaclusers") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql stmt failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT,"", "") ;
      return (NFM_E_SQL_STMT) ;
    }
  strcpy (sql_str, "delete from nfmclasses") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql stmt failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT,"", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  strcpy (sql_str, "delete from nfmcommands") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql stmt failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT,"", "") ;
      return (NFM_E_SQL_STMT) ;
    }
  strcpy (sql_str, "delete from nfmprojects") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql stmt failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT,"", "") ;
      return (NFM_E_SQL_STMT) ;
    }
  strcpy (sql_str, "delete from nfmsignoffusers") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql stmt failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT,"","") ;
      return (NFM_E_SQL_STMT) ;
    }

  strcpy (sql_str, "delete from nfmstates where n_stateno > 1") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql stmt failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT,"", "") ;
      return (NFM_E_SQL_STMT) ;
    }
  strcpy (sql_str, "delete from nfmtransitions") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql stmt failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT,"", "") ;
      return (NFM_E_SQL_STMT) ;
    }
  strcpy (sql_str, "delete from nfmworkflow") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql stmt failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT,"", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  strcpy (sql_str, "delete from nfmprojectaclmap") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql stmt failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT,"", "") ;
      return (NFM_E_SQL_STMT) ;
    }
  strcpy (sql_str, "delete from nfmcatalogaclmap") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql stmt failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT,"", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  strcpy (sql_str, "delete from nfmcatalogs") ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Sql stmt failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT,"", "") ;
      return (NFM_E_SQL_STMT) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMinitialize_workflow (comm_filename, sdp_filename,
			      admin_filename, cat_filename,
			      proj_filename, item_filename)
     char  *comm_filename;
     char  *sdp_filename;
     char  *admin_filename;
     char  *proj_filename;
     char  *cat_filename;
     char  *item_filename;
{
  char *fname = "_NFMinitialize_workflow" ;
  long    status;
  long    WFload_sdp_workflow ();
  long    WFload_admin_workflow ();
  long    WFload_catalog_workflow ();
  long    WFload_project_workflow ();
  long    WFload_item_workflow ();
  
  _NFMdebug ((fname, "Command File = <%s> : Sdp File = <%s> : Admin File = <%s> : Catalog File = <%s> : Catalog File = <%s> : Proj File = <%s> : Item File < %s>\n",
	      comm_filename, sdp_filename, admin_filename, cat_filename,
	      proj_filename, item_filename)) ;
  
  status = WFload_commands (NFMglobal.NFMuserid, "NFM", comm_filename);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Commands : status = <0x%.8x>\n", status));
      return (status);
    }
  
  status = _WFload_sdp_workflow (sdp_filename);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load SDP Work Flow : status = <0x%.8x>\n",
		status));
      return (status);
    } 
  
  status = _WFload_admin_workflow (admin_filename);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Admin Work Flow : status = <0x%.8x>\n",
		status));
      return (status);
    } 
  
  status = _WFload_catalog_workflow (cat_filename);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Catalog Work Flow : status = <0x%.8x>\n",
		status));
      return (status);
    } 
  
  status = _WFload_project_workflow (proj_filename);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Table Work Flow : status = <0x%.8x>\n",
		status));
      return (status);
    } 
  
  
  status =  _WFload_item_workflow (item_filename);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Item Work Flow : status = <0x%.8x>\n",
		status));
      return (status);
    } 
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long _WFload_sdp_workflow (file_name)
     char   *file_name;
{
  char *fname = "_WFload_sdp_workflow" ;
  long     status;
  long     WFload_acl ();
  
  _NFMdebug ((fname, "Sdp filename = <%s>\n", file_name)) ;
  
  status = WFload_workflow (NFMglobal.NFMuserid, "NFM", file_name);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Workflow : status = <0x%.8x>\n", status));
      return (status);
    }
  
  status = WFload_acl (NFMglobal.NFMuserid, NFMglobal.NFMusername,
		       "NFM_SDP_WORKFLOW", "NFM_SDP_ACL");
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Acl : status = <0x%.8x>\n", status));
      return (status);
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long _WFload_admin_workflow (file_name)
     char   *file_name;
{
  char *fname = "_WFload_admin_workflow" ;
  long     status;
  long     WFload_acl ();
  
  _NFMdebug ((fname, "File Name = <%s>\n", file_name));
  
  status = WFload_workflow (NFMglobal.NFMuserid, "NFM", file_name);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Workflow : status = <0x%.8x>\n", status));
      return (status);
    }
  
  status = WFload_acl (NFMglobal.NFMuserid, NFMglobal.NFMusername,
		       "NFM_ADMIN_WORKFLOW", "NFM_ADMIN_ACL");
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load acl : status = <0x%.8x>\n", status));
      return (status);
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long _WFload_catalog_workflow (file_name)
     char   *file_name;
{
  char *fname = "_WFload_catalog_workflow" ;
  long     status;
  long     WFload_acl ();
  
  _NFMdebug ((fname, "File Name = <%s>\n", file_name));
  
  status = WFload_workflow (NFMglobal.NFMuserid, "NFM", file_name);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Workflow : status = <0x%.8x>\n", status));
      return (status);
    }
  
  status = WFload_acl (NFMglobal.NFMuserid, NFMglobal.NFMusername,
		       "NFM_CATALOG_WORKFLOW", "NFM_CATALOG_ACL");
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Acl : status = <0x%.8x>\n", status));
      return (status);
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long _WFload_project_workflow (file_name)
     char   *file_name;
{
  char *fname = "_WFload_project_workflow" ;
  long     status;
  long     WFload_acl ();
  
  _NFMdebug ((fname, "file name <%s>\n", file_name));
  
  status = WFload_workflow (NFMglobal.NFMuserid, "NFM", file_name);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Workflow : status = <0x%.8x>\n", status));
      return (status);
    }
  
  status = WFload_acl (NFMglobal.NFMuserid, NFMglobal.NFMusername,
		       "NFM_PROJECT_WORKFLOW", "NFM_PROJECT_ACL");
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Acl : status = <0x%.8x>\n", status));
      return (status);
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long _WFload_item_workflow (file_name)
     char   *file_name;
{
  char *fname = "_WFload_item_workflow" ;
  long     status;
  long     WFload_acl ();
  
  _NFMdebug ((fname, "File Name = <%s>\n", file_name));
  
  status = WFload_workflow (NFMglobal.NFMuserid, "NFM", file_name);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Workflow : status = <0x%.8x>\n", status));
      return (status);
    }
  
  
  status = WFload_acl (NFMglobal.NFMuserid, NFMglobal.NFMusername,
		       "NFM_ITEM_WORKFLOW", "NFM_ITEM_ACL");
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Load Acl : status = <0x%.8x>\n", status));
      return (status);
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

