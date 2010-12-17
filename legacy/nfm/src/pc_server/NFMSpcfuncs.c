#include "machine.h"
#include "NFMpc.h"
#include "WFcommands.h"

extern struct NFMglobal_st NFMglobal ;
extern int IN_PIPE, OUT_PIPE ;
extern char *buffer ;

long NFMSpc_log_in (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   user_name [NFM_USERNAME + 1], passwd[NFM_PASSWD+1];
  char   environment [20], application[NFM_APPLICATION +1];
  
  char *fname = "NFMSlog_in";
  out_list = out_list ;
  
  status = PCmem_read_data (in_list, 1, 1, user_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, passwd) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (passwd) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 3, environment) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (environment) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 4, application) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "SRV_get_data_in_column_name (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "username %s : password %s : environment %s : application %s\n",
	      user_name, passwd, environment, application)) ;

  status = NFMlog_in (user_name, passwd, environment, application) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
      return (status);
    }
/** this is used in creating the default working area to set the type to D **/
  strcpy (NFMglobal.client_type, "PC") ;
  
  _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}


long NFMSpc_logout (in_list, out_list)
char *in_list;
char *out_list;
{
long   status;

char *fname = "NFMSlogout";
out_list= out_list ;
status = NFMlogoff ();

_NFMSdebug(( fname, "status -> <0x%.8x>\n", status));
in_list = in_list ;
if( status != NFM_S_SUCCESS )
    return( status);

return (NFM_S_SUCCESS);

}


long NFMSpc_post_log_in (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   internet_address [NFM_NODENAME+1], cwd [NFM_PATHNAME+1] ;
  char   nfs_node [NFM_NFS+1], nfs_sa [NFM_NFS+1] ;
  char   saname [NFM_SANAME+1] ;
  char   str [500] ;
  MEMptr sa_info = NULL, node_info = NULL ;
  
  
  char *fname = "NFMSlog_in";

  status = PCmem_read_data (in_list, 1, 1, internet_address) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (internet_address) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, saname) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (cwd) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 3, cwd) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (cwd) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 4, nfs_node) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (nfs_node) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 5, nfs_sa) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "(nfs_sa) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "internet address %s : cwd %s : nfs_node %s : nfs_sa %s\n",
	      internet_address, saname, cwd, nfs_node, nfs_sa)) ;

    status = MEMopen( &node_info, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEMopen : <0x%.8x>", status ));
        return( NFM_E_MEM );
    }

    status = MEMwrite_format(node_info,  "n_columnname", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( NFM_E_MEM );
    }    	
    status = MEMwrite_format( node_info, "n_value", "char(15)" );
    if( status != MEM_S_SUCCESS )
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( NFM_E_MEM );
    }    	

    strcpy (str, "n_machid\001PC\001") ;
    status = MEMwrite (node_info, str);
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>",
                   status));
        return (NFM_E_MEM) ;
      }

    strcpy (str, "n_opsys\001MS_DOS\001") ;
    status = MEMwrite (node_info, str);
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>",
                   status));
        return (NFM_E_MEM) ;
      }

    strcpy (str, "n_tcpip\001Y\001") ;
    status = MEMwrite (node_info, str);
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>",
                   status));
        return (NFM_E_MEM) ;
      }

    strcpy (str, "n_xns\001N\001") ;
    status = MEMwrite (node_info, str);
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>",
                   status));
        return (NFM_E_MEM) ;
      }

    strcpy (str, "n_decnet\001N\001") ;
    status = MEMwrite (node_info, str);
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>",
                   status));
        return (NFM_E_MEM) ;
      }

    strcpy (str, "n_netware\001N\001") ;
    status = MEMwrite (node_info, str);
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>",
                   status));
        return (NFM_E_MEM) ;
      }

    sprintf (str, "n_nfs\001%s\001", nfs_node) ;
    status = MEMwrite (node_info, str);
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>",
                   status));
        return (NFM_E_MEM) ;
      }

    status = MEMopen( &sa_info, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEMopen : <0x%.8x>", status ));
        return( NFM_E_MEM );
    }

    status = MEMwrite_format(sa_info,  "n_columnname", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( NFM_E_MEM );
    }    	
    status = MEMwrite_format( sa_info, "n_value", "char(15)" );
    if( status != MEM_S_SUCCESS )
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( NFM_E_MEM );
    }    	

    strcpy (str, "n_nfs\001N\001") ;
    sprintf (str, "n_nfs\001%s\001", nfs_sa) ;
    status = MEMwrite (sa_info, str);
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite : <0x%.8x>",
                   status));
        return (NFM_E_MEM) ;
      }

  status = NFMadd_default_working_area (internet_address, "nfmadmin",
					cwd, saname,
					node_info, sa_info) ;
    if (status != NFM_S_SUCCESS)
      {
	_NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
	return (status);
      }

  strcpy (out_list, saname) ;

  status = MEMclose (&node_info) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }

  status = MEMclose (&sa_info) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }
  
  _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}


long NFMSpc_copy_item (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status, cat_no ;
  char   catalog_name [NFM_CATALOGNAME+1], item_name [NFM_ITEMNAME+1];
  char   item_revision [NFM_ITEMREV+1], working_area [NFM_SANAME+1] ;
  struct NFMwf_info wf_info ;
  struct NFMoperation operation  ;
  char   s_cat_num [50] ;
  
  
  char *fname = "NFMSpc_copy_item";
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog_name) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }


  status = PCmem_read_data (in_list, 1, 2, s_cat_num) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog_name) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 3, item_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item_name) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 4, item_revision) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item_revision) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 5, working_area) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "SRV_get_data_in_column_name (working_area) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog name %s : item name %s : item rev %s : working area %s\n",
	      catalog_name, item_name, item_revision, working_area)) ;

  wf_info.workflow = NFM_WORKFLOW ;
  strcpy (wf_info.command, COPY_ITEM) ;
  strcpy (wf_info.workflow_name, "") ;
  strcpy (wf_info.project_name, "") ;
  strcpy (wf_info.app_name, "") ;
  operation.transfer = NFM_CONDITIONAL_TRANSFER ;
  operation.delete = NFM_CONDITIONAL_DELETE ;
  operation.purge = NFM_PURGE ;

  cat_no = atol (s_cat_num) ;

  status = NFMpccopy_item_files (catalog_name, cat_no, item_name, 
				 item_revision,
				 working_area, wf_info, operation) ;

  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_co_item (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  char *fname = "NFMSpc_co_item";
  long   status, cat_no ;
  char   catalog_name [NFM_CATALOGNAME+1], item_name [NFM_ITEMNAME+1];
  char   item_revision [NFM_ITEMREV+1], working_area [NFM_SANAME+1] ;
  struct NFMwf_info wf_info ;
  struct NFMoperation operation ;
  char   s_cat_num [50] ;

  _NFMdebug ((fname, "ENTER\n")) ;

  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, s_cat_num) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 3, item_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (passwd) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 4, item_revision) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (environment) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 5, working_area) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "SRV_get_data_in_column_name (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog name %s : item name %s : item rev %s : working area %s\n",
	      catalog_name, item_name, item_revision, working_area)) ;

  wf_info.workflow = NFM_WORKFLOW ;
  strcpy (wf_info.command, CHECKOUT_ITEM) ;
  strcpy (wf_info.workflow_name, "") ;
  strcpy (wf_info.project_name, "") ;
  strcpy (wf_info.app_name, "") ;
  operation.transfer = NFM_CONDITIONAL_TRANSFER ;
  operation.delete = NFM_CONDITIONAL_DELETE ;
  operation.purge = NFM_PURGE ;

  cat_no = atol (s_cat_num) ;

  status = NFMpccheckout_item (catalog_name, cat_no, item_name, item_revision,
			     working_area, wf_info, operation) ;

  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_cancel_co_item (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  char *fname = "NFMSpc_cancel_co_item";
  long   status, cat_no ;
  char   catalog_name [NFM_CATALOGNAME+1], item_name [NFM_ITEMNAME+1];
  char   item_revision [NFM_ITEMREV+1] ;
  struct NFMwf_info wf_info ;
  struct NFMoperation operation ;
  char   s_cat_num [50] ;

  _NFMdebug ((fname, "ENTER\n")) ;
  out_list = out_list ;

  status = PCmem_read_data (in_list, 1, 1, catalog_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, s_cat_num) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 3, item_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (passwd) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 4, item_revision) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (environment) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog name %s : item name %s : item rev %s\n",
	      catalog_name, item_name, item_revision)) ;

  wf_info.workflow = NFM_WORKFLOW ;
  strcpy (wf_info.command, CANCEL_ITEM_CHECKOUT) ;
  strcpy (wf_info.workflow_name, "") ;
  strcpy (wf_info.project_name, "") ;
  strcpy (wf_info.app_name, "") ;
  operation.transfer = NFM_CONDITIONAL_TRANSFER ;
  operation.delete = NFM_CONDITIONAL_DELETE ;
  operation.purge = NFM_PURGE ;

  cat_no = atol (s_cat_num) ;

  status = NFMpccancel_check_out_item (catalog_name, cat_no, item_name, item_revision,
			     wf_info, operation) ;

  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_ci_item (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  char *fname = "NFMSpc_ci_item" ;
  long   status, cat_no;
  char   catalog_name [NFM_CATALOGNAME+1], item_name [NFM_ITEMNAME+1];
  char   item_revision [NFM_ITEMREV+1], working_area [NFM_SANAME+1] ;
  char   s_cat_num [50];
  struct NFMwf_info wf_info ;
  struct NFMoperation operation ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, s_cat_num) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 3, item_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (passwd) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 4, item_revision) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (environment) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 5, working_area) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "SRV_get_data_in_column_name (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog name %s : item name %s : item rev %s : working area %s\n",
	      catalog_name, item_name, item_revision, working_area)) ;

  
  wf_info.workflow = NFM_WORKFLOW ;
  strcpy (wf_info.command, CHECKIN_ITEM) ;
  strcpy (wf_info.workflow_name, "") ;
  strcpy (wf_info.project_name, "") ;
  strcpy (wf_info.app_name, "") ;
  operation.transfer = NFM_CONDITIONAL_TRANSFER ;
  operation.delete = NFM_CONDITIONAL_DELETE ;
  operation.purge = NFM_PURGE ;
    
  cat_no = atol (s_cat_num) ;

  status = NFMpccheckin_item (catalog_name, cat_no, item_name, item_revision,
			      working_area, wf_info, operation) ;

  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}


long NFMSpc_copy_set (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status, cat_no, set_no;
  char   catalog_name [NFM_CATALOGNAME+1], set_name [NFM_ITEMNAME+1];
  char   set_revision [NFM_ITEMREV+1], working_area [NFM_SANAME+1] ;
  char   s_cat_num [50], s_set_num [50] ;
  long   flag ;
  struct NFMwf_info wf_info ;
  struct NFMoperation operation ;
  
  char *fname = "NFMSpc_copy_set" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, s_cat_num) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 3, set_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (passwd) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 4, set_revision) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (environment) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 5, s_set_num) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (environment) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 6, working_area) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "SRV_get_data_in_column_name (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog name %s : set name %s : set rev %s : working area %s\n",
	      catalog_name, set_name, set_revision, working_area)) ;

  
  wf_info.workflow = NFM_WORKFLOW ;
  strcpy (wf_info.command, COPY_SET_FILES) ;
  strcpy (wf_info.workflow_name, "") ;
  strcpy (wf_info.project_name, "") ;
  strcpy (wf_info.app_name, "") ;
  operation.transfer = NFM_CONDITIONAL_TRANSFER ;
  operation.delete = NFM_CONDITIONAL_DELETE ;
  operation.purge = NFM_PURGE ;
    
  cat_no = atol (s_cat_num) ;
  set_no = atol (s_set_num) ;

  status = NFMvalidate_revision ( catalog_name, set_name, set_revision,
				 &flag ) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  if (flag != 1)
    {
      _NFMSdebug ((fname, "Not  a set : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item is not a set") ;
      return (NFM_E_MESSAGE) ;
    }

  status = NFMpccopy_set_files (catalog_name, cat_no, set_name, set_revision, 
				set_no,  working_area, wf_info,
				NFM_SAME_OPERATION, &operation, 0) ;

  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_co_set (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status, cat_no, set_no;
  char   catalog_name [NFM_CATALOGNAME+1], set_name [NFM_ITEMNAME+1];
  char   set_revision [NFM_ITEMREV+1], working_area [NFM_SANAME+1] ;
  char   s_cat_num [50], s_set_num [50] ;
  long  flag ;
  struct NFMwf_info wf_info ;
  struct NFMoperation operation ;
  
  char *fname = "NFMSpc_co_set" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, s_cat_num) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 3, set_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (passwd) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 4, set_revision) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (environment) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 5, s_set_num) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (environment) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 6, working_area) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "SRV_get_data_in_column_name (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog name %s : set name %s : set rev %s : working area %s\n",
	      catalog_name, set_name, set_revision, working_area)) ;

  
  wf_info.workflow = NFM_WORKFLOW ;
  strcpy (wf_info.command, CHECKOUT_SET) ;
  strcpy (wf_info.workflow_name, "") ;
  strcpy (wf_info.project_name, "") ;
  strcpy (wf_info.app_name, "") ;
  operation.transfer = NFM_CONDITIONAL_TRANSFER ;
  operation.delete = NFM_CONDITIONAL_DELETE ;
  operation.purge = NFM_PURGE ;
    
  cat_no = atol (s_cat_num) ;
  set_no = atol (s_set_num) ;

  status = NFMvalidate_revision ( catalog_name, set_name, set_revision,
				 &flag ) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  if (flag != 1)
    {
      _NFMSdebug ((fname, "Not  a set : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item is not a set") ;
      return (NFM_E_MESSAGE) ;
    }

  status = NFMpccheckout_set (catalog_name, cat_no, set_name, set_revision, 
			     set_no,  working_area, wf_info,
			     NFM_SAME_OPERATION, &operation, 0) ;

  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_cancel_co_set (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  char *fname = "NFMSpc_cancel_co_set" ;
  long   status, cat_no, set_no;
  char   catalog_name [NFM_CATALOGNAME+1], set_name [NFM_ITEMNAME+1];
  char   set_revision [NFM_ITEMREV+1] ;
  char   s_cat_num [50], s_set_num [50] ;
  long   flag ;
  struct NFMwf_info wf_info ;
  struct NFMoperation operation ;
  
  _NFMdebug ((fname, "ENTER\n")) ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, s_cat_num) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 3, set_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (passwd) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 4, set_revision) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (environment) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 5, s_set_num) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (environment) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog name %s : set name %s : set rev %s\n",
	      catalog_name, set_name, set_revision)) ;

  
  wf_info.workflow = NFM_WORKFLOW ;
  strcpy (wf_info.command,CANCEL_SET_CHECKOUT) ;
  strcpy (wf_info.workflow_name, "") ;
  strcpy (wf_info.project_name, "") ;
  strcpy (wf_info.app_name, "") ;
  operation.transfer = NFM_CONDITIONAL_TRANSFER ;
  operation.delete = NFM_CONDITIONAL_DELETE ;
  operation.purge = NFM_PURGE ;
    
  cat_no = atol (s_cat_num) ;
  set_no = atol (s_set_num) ;

  status = NFMvalidate_revision ( catalog_name, set_name, set_revision,
				 &flag ) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  if (flag != 1)
    {
      _NFMSdebug ((fname, "Not  a set : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item is not a set") ;
      return (NFM_E_MESSAGE) ;
    }

  status = NFMpccancel_check_out_set (catalog_name, cat_no, set_name, set_revision, 
			     set_no,  wf_info,
			     NFM_SAME_OPERATION, &operation, 0) ;

  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_ci_set (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status, cat_no, set_no;
  char   catalog_name [NFM_CATALOGNAME+1], set_name [NFM_ITEMNAME+1];
  char   set_revision [NFM_ITEMREV+1], working_area [NFM_SANAME+1] ;
  char   s_cat_num [50], s_set_num [50] ;
  long   flag ;
  struct NFMwf_info wf_info ;
  struct NFMoperation operation ;
  
  char *fname = "NFMSpc_ci_set" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, s_cat_num) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 3, set_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (passwd) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 4, set_revision) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (environment) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 5, s_set_num) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (environment) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 6, working_area) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "SRV_get_data_in_column_name (username) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog name %s : set name %s : set rev %s : working area %s\n",
	      catalog_name, set_name, set_revision, working_area)) ;

  
  wf_info.workflow = NFM_WORKFLOW ;
  strcpy (wf_info.command, CHECKIN_SET) ;
  strcpy (wf_info.workflow_name, "") ;
  strcpy (wf_info.project_name, "") ;
  strcpy (wf_info.app_name, "") ;
  operation.transfer = NFM_CONDITIONAL_TRANSFER ;
  operation.delete = NFM_CONDITIONAL_DELETE ;
  operation.purge = NFM_PURGE ;
    
  cat_no = atol (s_cat_num) ;
  set_no = atol (s_set_num) ;

  status = NFMvalidate_revision ( catalog_name, set_name, set_revision,
				 &flag ) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  if (flag != 1)
    {
      _NFMSdebug ((fname, "Not  a set : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item is not a set") ;
      return (NFM_E_MESSAGE) ;
    }

  status = NFMpccheckin_set (catalog_name, cat_no, set_name, set_revision, 
			     set_no,  working_area, wf_info,
			     NFM_SAME_OPERATION, &operation, 0) ;

  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}


long NFMSpc_flag_item_archive (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   catalog [NFM_CATALOGNAME+1], item [NFM_ITEMNAME +1] ;
  char   rev [NFM_ITEMREV +1] ;
  
  char *fname = "NFMSpc_flag_item_archive" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, item) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 3, rev) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog %s : item %s : rev %s\n",
	      catalog, item, rev)) ;

  status = NFMflag_item_archive (NFMglobal.NFMuserid, catalog, item, rev) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}


long NFMSpc_flag_item_backup (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   catalog [NFM_CATALOGNAME+1], item [NFM_ITEMNAME +1] ;
  char   rev [NFM_ITEMREV +1] ;
  
  char *fname = "NFMSpc_flag_item_backup" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, item) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 3, rev) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog %s : item %s : rev %s\n",
	      catalog, item, rev)) ;

  status = NFMflag_item_backup (NFMglobal.NFMuserid, catalog, item, rev) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_flag_item_restore (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   catalog [NFM_CATALOGNAME+1], item [NFM_ITEMNAME +1] ;
  char   rev [NFM_ITEMREV +1] ;
  
  char *fname = "NFMSpc_flag_item_restore" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, item) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 3, rev) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog %s : item %s : rev %s\n",
	      catalog, item, rev)) ;

  status = NFMflag_item_restore (NFMglobal.NFMuserid, catalog, item, rev) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_flag_set_archive (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   catalog [NFM_CATALOGNAME+1], item [NFM_ITEMNAME +1] ;
  char   rev [NFM_ITEMREV +1] ;
  long   flag ;
  
  char *fname = "NFMSpc_flag_set_archive" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, item) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 3, rev) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog %s : item %s : rev %s\n",
	      catalog, item, rev)) ;

  status = NFMvalidate_revision ( catalog, item, rev,
				 &flag ) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  if (flag != 1)
    {
      _NFMSdebug ((fname, "Not  a set : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item is not a set") ;
      return (NFM_E_MESSAGE) ;
    }

  status = NFMflag_set_archive (NFMglobal.NFMuserid, catalog, item, rev) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_flag_set_backup (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   catalog [NFM_CATALOGNAME+1], item [NFM_ITEMNAME +1] ;
  char   rev [NFM_ITEMREV +1] ;
  long   flag ;
  
  char *fname = "NFMSpc_flag_set_backup" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, item) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 3, rev) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog %s : item %s : rev %s\n",
	      catalog, item, rev)) ;

  status = NFMvalidate_revision ( catalog, item, rev,
				 &flag ) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  if (flag != 1)
    {
      _NFMSdebug ((fname, "Not  a set : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item is not a set") ;
      return (NFM_E_MESSAGE) ;
    }

  status = NFMflag_set_backup (NFMglobal.NFMuserid, catalog, item, rev) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_flag_set_restore (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   catalog [NFM_CATALOGNAME+1], item [NFM_ITEMNAME +1] ;
  char   rev [NFM_ITEMREV +1] ;
  long   flag ;
  
  char *fname = "NFMSpc_flag_set_restore" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, item) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 3, rev) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog %s : item %s : rev %s\n",
	      catalog, item, rev)) ;

  status = NFMvalidate_revision ( catalog, item, rev,
				 &flag ) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  if (flag != 1)
    {
      _NFMSdebug ((fname, "Not  a set : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item is not a set") ;
      return (NFM_E_MESSAGE) ;
    }

  status = NFMflag_set_restore (NFMglobal.NFMuserid, catalog, item, rev) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}


long NFMSpc_cancel_item_archive (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   catalog [NFM_CATALOGNAME+1], item [NFM_ITEMNAME +1] ;
  char   rev [NFM_ITEMREV +1] ;
  
  static char *fname = "NFMSpc_cancel_item_archive" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, item) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 3, rev) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog %s : item %s : rev %s\n",
	      catalog, item, rev)) ;

  status = NFMcancel_item_archive_flag (NFMglobal.NFMuserid, catalog, item, 
					rev) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_cancel_item_backup (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   catalog [NFM_CATALOGNAME+1], item [NFM_ITEMNAME +1] ;
  char   rev [NFM_ITEMREV +1] ;
  
  static char *fname = "NFMSpc_cancel_item_backup" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, item) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 3, rev) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog %s : item %s : rev %s\n",
	      catalog, item, rev)) ;

  status = NFMcancel_item_backup_flag (NFMglobal.NFMuserid, 
				       catalog, item, rev) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_cancel_item_restore (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   catalog [NFM_CATALOGNAME+1], item [NFM_ITEMNAME +1] ;
  char   rev [NFM_ITEMREV +1] ;
  
  static char *fname = "NFMSpc_cancel_item_restore" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, item) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 3, rev) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog %s : item %s : rev %s\n",
	      catalog, item, rev)) ;

  status = NFMcancel_item_restore_flag(NFMglobal.NFMuserid, catalog, item, rev) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_cancel_set_archive (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   catalog [NFM_CATALOGNAME+1], item [NFM_ITEMNAME +1] ;
  char   rev [NFM_ITEMREV +1] ;
  long   flag ;
  
  static char *fname = "NFMSpc_cancel_set_archive" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, item) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 3, rev) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog %s : item %s : rev %s\n",
	      catalog, item, rev)) ;

  status = NFMvalidate_revision ( catalog, item, rev, 
				 &flag ) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  if (flag != 1)
    {
      _NFMSdebug ((fname, "Not  a set : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item is not a set") ;
      return (NFM_E_MESSAGE) ;
    }

  status = NFMcancel_set_archive_flag (NFMglobal.NFMuserid, 
				       catalog, item, rev) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_cancel_set_backup (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   catalog [NFM_CATALOGNAME+1], item [NFM_ITEMNAME +1] ;
  char   rev [NFM_ITEMREV +1] ;
  long  flag ;
  
  static char *fname = "NFMSpc_cancel_set_backup" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, item) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 3, rev) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog %s : item %s : rev %s\n",
	      catalog, item, rev)) ;

  status = NFMvalidate_revision ( catalog, item, rev,
				 &flag ) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  if (flag != 1)
    {
      _NFMSdebug ((fname, "Not  a set : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item is not a set") ;
      return (NFM_E_MESSAGE) ;
    }

  status = NFMcancel_set_backup_flag (NFMglobal.NFMuserid, catalog, item, rev) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_cancel_set_restore (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   catalog [NFM_CATALOGNAME+1], item [NFM_ITEMNAME +1] ;
  char   rev [NFM_ITEMREV +1] ;
  long   flag ;
  
  
  static char *fname = "NFMSpc_cancel_set_restore" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, catalog) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, item) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  status = PCmem_read_data (in_list, 1, 3, rev) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog %s : item %s : rev %s\n",
	      catalog, item, rev)) ;

  status = NFMvalidate_revision ( catalog, item, rev,
				 &flag ) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  if (flag != 1)
    {
      _NFMSdebug ((fname, "Not  a set : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item is not a set") ;
      return (NFM_E_MESSAGE) ;
    }

  status = NFMcancel_set_restore_flag (NFMglobal.NFMuserid, catalog, 
				       item, rev) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_validate_user_access (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   command [NFM_COMMANDNAME+1], workflow [NFM_WORKFLOWNAME+1] ;
  char   project [NFM_PROJECTNAME+1] ;
  char   catalog [NFM_CATALOGNAME+1], item [NFM_ITEMNAME +1] ;
  char   rev [NFM_ITEMREV +1] ;
  
  static char *fname = "NFMSpc_validate_user_access" ;
  out_list = out_list ;
  status = PCmem_read_data (in_list, 1, 1, command) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, workflow) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (item) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 3, project) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 4, catalog) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 5, item) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 6, rev ) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (rev) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "command %s : workflow %s : project %s : catalog %s : item %s : rev %s\n",
	      command, workflow, project, catalog, item, rev)) ;

  ERRreset_struct () ;
  status = WFvalidate_user_access (NFMglobal.NFMuserid,
                                   command, workflow, project,
                                   catalog, item, rev) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}

long NFMSpc_set_to_state (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status ;
  char   application [NFM_APPLICATION+1] ;
  char   err_message [512] ;
  char   s_err_no [20] ;
  long   error_no ;
  
  static char *fname = "NFMSpc_set_to_state" ;
  out_list = out_list ;

  status = PCmem_read_data (in_list, 1, 1, application) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }


  status = PCmem_read_data (in_list, 1, 2, s_err_no) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }
  error_no = atol (s_err_no) ;

  status = PCmem_read_data (in_list, 1, 3, err_message) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "application %s : error no %d : error message %s\n",
	      application, error_no, err_message)) ;

  /* get error_no and error_msg */

  status = NFMset_wf_state (application, error_no, err_message) ;
  if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
}


long NFMSpc_add_item (in_list, out_list)
char *in_list;
char *out_list;
{
  char *fname = "NFMSpc_add_item" ;
  long status, i ;
  char catalog_name [NFM_CATALOGNAME+1] ;
  MEMptr attr_list = NULL, data_list = NULL, value_list = NULL ;
  char **data, **column ;
  char tmp_str [1024], value [200] ;
  long name_offset, null_offset, write_offset, offset ;
  int  subsystem ;
  long err_no, col, z, offset_z, list_no, valueno_offset ;
  char message [512], **value_ptr ;

  out_list = out_list ;

  _NFMSdebug ((fname, "ENTER\n")) ;
  status=_NFMfind_value_pc_buf (in_list, "n_catalogname", 1, catalog_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog_name <%s>\n", catalog_name)) ;

/*****
  status = NFMvalidate_user_access ( NFMglobal.NFMuserid, ADD_ITEM, 
				    "NFM_ITEM_WORKFLOW",
				    "",
				    catalog_name, "", "");
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
******/

  ERRreset_struct () ;
  status = NFMquery_add_item_attributes (NFMglobal.NFMuserid, catalog_name,
					  &attr_list, &data_list,
					  &value_list) ;
  
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  
  status = MEMbuild_array (attr_list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }
  
  column = (char **) attr_list->column_ptr ;
  data = (char **) attr_list -> data_ptr ;
  
  status = MEMbuild_array (data_list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }
  
  name_offset = -1 ; null_offset = -1 ; write_offset = -1;
  for (i=0; i<attr_list->columns; i++)
    {
      if (strcmp (column [i], "n_name") == 0) name_offset = i ;
      else if (strcmp (column [i], "n_null") == 0) null_offset = i ;
      else if (strcmp (column [i], "n_write") == 0) write_offset = i ;
      else if (strcmp (column [i], "n_valueno") == 0) valueno_offset = i ;
    }
  
  /* check for non-null values */
  for (i=0; i<attr_list->rows; i++)
    {
      col = 0 ;
      offset = attr_list->columns*i;
      /* not null value */
      if (strcmp (data [offset+write_offset], "Y") == 0)
	{
	  tmp_str [0] = 0 ;
	  _NFMdebug ((fname, "columns is <%s>\n", data [offset+name_offset]));
	  if (strcmp (data [offset+name_offset], "n_itemname") == 0)
	    {
	      _NFMfind_value_pc_buf (in_list, "n_itemname", 1, value) ;
	      col = i ;
	      if (strlen (value))
		strcpy (tmp_str, value) ;
	      else
		{
		  if (strcmp (data [offset+null_offset], "N") == 0)
		    {
		      _NFMdebug ((fname, "column <%s> can not be null\n",
				data [offset+name_offset]));
		      return (NFM_E_FAILURE) ;
		    }
		  else continue ;
		}
	      
	    }
	  else if (strcmp (data [offset+name_offset], "n_itemrev") == 0)
	    {
	      _NFMfind_value_pc_buf (in_list, "n_itemrev", 1, value) ;
	      col = i;
	      if (strlen (value))
		strcpy (tmp_str, value) ;
	      else
		{
		  if (strcmp (data [offset+null_offset], "N") == 0)
		    {
		      _NFMdebug ((fname, "column <%s> can not be null\n",
				data [offset+name_offset]));
		      return (NFM_E_FAILURE) ;
		    }
		  else continue ;
		}
	    }
	  else if (strcmp (data [offset+name_offset], "n_itemdesc") == 0)
	    {
	      _NFMfind_value_pc_buf (in_list, "n_description", 1, value) ;
	      col = i;
	      if (strlen (value))
		strcpy (tmp_str, value) ;
	      else
		{
		  if (strcmp (data [offset+null_offset], "N") == 0)
		    {
		      _NFMdebug ((fname, "column <%s> can not be null\n",
				data [offset+name_offset]));
		      return (NFM_E_FAILURE) ;
		    }
		  else continue ;
		}
	    }
	  else if (strcmp (data [offset+name_offset], "n_versionlimit") == 0)
	    {
	      _NFMfind_value_pc_buf (in_list, "n_versionlimit", 1, value) ;
	      col = i;
	      if (strlen (value))
		strcpy (tmp_str, value);
	      else
		{
		  if (strcmp (data [offset+null_offset], "N") == 0)
		    {
		      _NFMdebug ((fname, "column <%s> can not be null\n",
				data [offset+name_offset]));
		      return (NFM_E_FAILURE) ;
		    }
		  else continue ;
		}
	    }
	  else if (strcmp (data [offset+name_offset], "n_aclno") == 0)
	    {
	      _NFMfind_value_pc_buf (in_list, "n_aclname", 1, value) ;
	      col = i;
	      if (strlen (value))
		{
		  list_no = atol (data [offset + valueno_offset]) ;
		  _NFMdebug ((fname, "reset to acl <%d>\n", list_no)) ;
		  if ((status = MEMreset_buffer_no
		       (value_list, list_no)) != MEM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
		      MEMclose (&attr_list) ;
		      MEMclose (&data_list) ;
		      MEMclose (&value_list) ;
		      return (NFM_E_MEM);
		    }
		  
		  _NFMdebug ((fname, "value list has %d rows\n", value_list->rows)) ;
		  
		  value_ptr = (char **) value_list->data_ptr ;
		  
		  for (z=0; z<value_list->rows;z++)
		    {
		      offset_z = z*(value_list->columns) ;
		      _NFMdebug ((fname, "Comparing <%s> with <%s>\n",
				  value, value_ptr[offset_z+2]));
		      
		      if (strcmp (value,
				  value_ptr[offset_z+2]) == 0)
			{
			  strcpy (tmp_str, value_ptr[offset_z]) ;
			  _NFMdebug ((fname, "aclno is <%s>\n", tmp_str)) ;
			  break ;
			}
		    }
		}
	      else
		{
		  if (strcmp (data [offset+null_offset], "N") == 0)
		    {
		      _NFMdebug ((fname, "column <%s> can not be null\n",
				data [offset+name_offset]));
		      return (NFM_E_FAILURE) ;
		    }
		  else continue ;
		}
	    }
	  else if (strcmp (data [offset+name_offset], "n_cofilename") == 0)
	    {
	      _NFMfind_value_pc_buf (in_list, "n_cofilename", 1, value) ;
	      col = i;
	      if (strlen (value))
		strcpy (tmp_str, value) ;
	      else
		{
		  if (strcmp (data [offset+null_offset], "N") == 0)
		    {
		      _NFMdebug ((fname, "column <%s> can not be null\n",
				data [offset+name_offset]));
		      return (NFM_E_FAILURE) ;
		    }
		  else continue ;
		}
	    }
	  else if (strcmp (data [offset+name_offset], "n_filetype") == 0)
	    {
	      _NFMfind_value_pc_buf (in_list, "n_filetype", 1, value) ;
	      col = i;
	      if (strlen (value))
		strcpy (tmp_str, value) ;
	      else
		{
		  if (strcmp (data [offset+null_offset], "N") == 0)
		    {
		      _NFMdebug ((fname, "column <%s> can not be null\n",
				data [offset+name_offset]));
		      return (NFM_E_FAILURE) ;
		    }
		  else continue ;
		}
	    }
	  else if (strcmp (data [offset+name_offset], "n_cisano") == 0)
	    {
	      _NFMfind_value_pc_buf (in_list, "n_cisaname", 1, value) ;
	      col = i;
	      if (strlen (value))
		{
		  list_no = atol (data [offset + valueno_offset]) ;
		  if ((status = MEMreset_buffer_no
		       (value_list, list_no)) != MEM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
		      MEMclose (&attr_list) ;
		      MEMclose (&data_list) ;
		      MEMclose (&value_list) ;
		      return (NFM_E_MEM);
		    }
		  
		  _NFMdebug ((fname, "value list has %d rows\n", 
			      value_list->rows)) ;
		  
		  value_ptr = (char **) value_list->data_ptr ;
		  
		  for (z=0; z<value_list->rows;z++)
		    {
		      offset_z = z*(value_list->columns) ;
		      _NFMdebug ((fname, "Comparing <%s> with <%s>\n",
				  value, value_ptr[offset_z+1]));
		      
		      if (strcmp (value,
				  value_ptr[offset_z+1]) == 0)
			{
			  strcpy (tmp_str, value_ptr[offset_z]) ;
			  break ;
			}
		    }
		}
	      else
		{
		  if (strcmp (data [offset+null_offset], "N") == 0)
		    {
		      _NFMdebug ((fname, "column <%s> can not be null\n",
				data [offset+name_offset]));
		      return (NFM_E_FAILURE) ;
		    }
		  else continue ;
		}
	    }
	  else if (strcmp (data [offset+name_offset], "n_cifilename") == 0)
	    {
	      _NFMfind_value_pc_buf (in_list, "n_cifilename", 1, value) ;
	      col = i;
	      if (strlen (value))
		strcpy (tmp_str, value) ;
	      else
		{
		  if (strcmp (data [offset+null_offset], "N") == 0)
		    {
		      _NFMdebug ((fname, "column <%s> can not be null\n",
				data [offset+name_offset]));
		      return (NFM_E_FAILURE) ;
		    }
		  else continue ;
		}
	    }
	  else 
	    {
	      /* user define attributes */
	    }
	  if (strlen (tmp_str))
	    {
	      _NFMdebug ((fname, "writing <%s> in column <%d>", 
			  tmp_str, col+1));
	      status = MEMwrite_data (data_list, tmp_str, 1, col+1);
	      if (status != MEM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "MEMwrite_data <0x%.8x>\n", status));
		  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
		  return (NFM_E_MEM) ;
		}
	    }
	}
    }
  
  if (_NFMdebug_st.NFMdebug_on)
    {
      MEMprint_buffer ("data list", data_list, _NFMdebug_st.NFMdebug_file) ;
    }
  status = NFMadd_item( NFMglobal.NFMuserid,catalog_name,
			attr_list, data_list) ;
  
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
    }

  ERRget_message ( message ) ;
  ERRget_number (&err_no, &subsystem ) ;
  if (NFMset_wf_state ( "NFM", err_no, message ) != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }	
  _NFMdebug ((fname, "ADD ITEM status <0x%.8x>\n", status)) ;
  return (status) ;
}
  

long NFMSpc_query_add_item_attributes (in_list, out_list)
char *in_list;
char *out_list;
{
  char *fname = "NFMSpc_query_add_item_attributes" ;
  long status, i, y, size, max_count ;
  char catalog_name [NFM_CATALOGNAME+1] ;
  MEMptr attr_list = NULL, data_list = NULL, value_list = NULL ;
  char **data, **column, **data1, **value_ptr ;
  char tmp_str [1024], *temp_list, sql_str [1024] ;
  char val[NFM_NAME+10], val1[NFM_NAME+10] ;
  long name_offset, null_offset, write_offset, offset ;
  long col, z, offset_z, list_no, valueno_offset ;

  out_list = out_list ;

  _NFMSdebug ((fname, "ENTER\n")) ;
  status = PCmem_read_data (in_list, 1, 1, catalog_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog_name <%s>\n", catalog_name)) ;

  status = NFMquery_add_item_attributes (NFMglobal.NFMuserid, catalog_name,
					  &attr_list, &data_list,
					  &value_list) ;
  
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  
  status = MEMbuild_array (attr_list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }
  
  column = (char **) attr_list->column_ptr ;
  data = (char **) attr_list -> data_ptr ;
  
  status = MEMbuild_array (data_list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "Failure : MEMbuild_array (data_list) : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }
  
  data1 = (char **) data_list -> data_ptr ;

  name_offset = -1 ; null_offset = -1 ; write_offset = -1;
  for (i=0; i<attr_list->columns; i++)
    {
      if (strcmp (column [i], "n_name") == 0) name_offset = i ;
      else if (strcmp (column [i], "n_null") == 0) null_offset = i ;
      else if (strcmp (column [i], "n_write") == 0) write_offset = i ;
      else if (strcmp (column [i], "n_valueno") == 0) valueno_offset =i ;
    }
  
  /* build pc buffer */
  status = _NFMpc_build_buffer (&temp_list, 9) ;
  if (status != NFM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }

  /* build header first row is the column name information */
  /* each column to the max */
  for (i =0; i<9; i++)
    {
      for (y=0;y<NFM_NAME+1; y++) strcat (sql_str, " ") ;
      strcat (sql_str, "\001") ;
    }

  status = _NFMpc_write_row (&temp_list, sql_str) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "PC write failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  /* check for non-null values */
  sql_str [0] = 0 ;
  max_count = 9 ;
  col = 0 ;
  for (i=0; i<attr_list->rows; i++)
    {
      offset = attr_list->columns*i;
      /* not null value */
      tmp_str [0] = 0 ;
      val1 [0] = 0 ;
/*      _NFMdebug ((fname, "column is <%s>\n", data [offset+name_offset])); */
      if (strcmp (data [offset+name_offset], "n_itemname") == 0)
	{
	  if (strlen (data1 [i])) 
	    {
	      ++col ;
	      strcpy (tmp_str, data1[i]) ;
	    }
	}
      else if (strcmp (data [offset+name_offset], "n_itemrev") == 0)
	{
	  if (strlen (data1 [i])) 
	    {
	      ++col ;
	      strcpy (tmp_str, data1[i]) ;
	    }
	}
      else if (strcmp (data [offset+name_offset], "n_itemdesc") == 0)
	{
	  if (strlen (data1 [i])) 
	    {
	      ++col ;
	      strcpy (tmp_str, data1[i]) ;
	    }
	}
      else if (strcmp (data [offset+name_offset], "n_versionlimit") == 0)
	{
	  if (strlen (data1 [i])) 
	    {
	      ++col ;
	      strcpy (tmp_str, data1[i]) ;
	    }
	}
      else if (strcmp (data [offset+name_offset], "n_aclno") == 0)
	{
	  if (strlen (data1 [i])) 
	    {
	      list_no = atol (data [offset + valueno_offset]) ;
	      _NFMdebug ((fname, "reset to acl <%d>\n", list_no)) ;
	      if ((status = MEMreset_buffer_no
		   (value_list, list_no)) != MEM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
		  MEMclose (&attr_list) ;
		  MEMclose (&data_list) ;
		  MEMclose (&value_list) ;
		  return (NFM_E_MEM);
		}
	      
	      _NFMdebug ((fname, "value list has %d rows\n", value_list->rows)) ;
	      
	      value_ptr = (char **) value_list->data_ptr ;
	      
	      for (z=0; z<value_list->rows;z++)
		{
		  offset_z = z*(value_list->columns) ;
		  _NFMdebug ((fname, "Comparing <%s> with <%s>\n",
			      data1[i], value_ptr[offset_z]));
		  
		  if (strcmp (data1[i],
			      value_ptr[offset_z]) == 0)
		    {
		      ++col ;
		      strcpy (tmp_str, value_ptr[offset_z+2]) ;
		      strcpy (val1, "n_aclname") ;
		      _NFMdebug ((fname, "aclno is <%s>", val1)) ;
		      break ;
		    }
		}
	    }
	}
      else if (strcmp (data [offset+name_offset], "n_cofilename") == 0)
	{
	  if (strlen (data1 [i])) 
	    {
	      ++col ;
	      strcpy (tmp_str, data1[i]) ;
	    }
	}
      else if (strcmp (data [offset+name_offset], "n_filetype") == 0)
	{
	  if (strlen (data1 [i])) 
	    {
	      ++col ;
	      strcpy (tmp_str, data1[i]) ;
	    }
	}
      else if (strcmp (data [offset+name_offset], "n_cisano") == 0)
	{
	  if (strlen (data1 [i])) 
	    {
	      list_no = atol (data [offset + valueno_offset]) ;
	      if ((status = MEMreset_buffer_no
		   (value_list, list_no)) != MEM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "MEMreset_buffer_no = <0x%.8x>", status));
		  MEMclose (&attr_list) ;
		  MEMclose (&data_list) ;
		  MEMclose (&value_list) ;
		  return (NFM_E_MEM);
		}
	      
	      _NFMdebug ((fname, "value list has %d rows", value_list->rows));
	      
	      value_ptr = (char **) value_list->data_ptr ;
	      
	      for (z=0; z<value_list->rows;z++)
		{
		  offset_z = z*(value_list->columns) ;
		  _NFMdebug ((fname, "Comparing <%s> with <%s>\n", 
			      data1[i], value_ptr [offset_z]));
		  
		  if (strcmp (data1[i],
			      value_ptr[offset_z]) == 0)
		    {
		      ++col ;
		      strcpy (val1, "n_cisaname") ;
		      strcpy (tmp_str, value_ptr[offset_z+2]) ;
		      break ;
		    }
		}
	    }
	}
      else if (strcmp (data [offset+name_offset], "n_cifilename") == 0)
	{
	  if (strlen (data1 [i])) 
	    {
	      ++col ;
	      strcpy (tmp_str, data1[i]) ;
	    }
	}
      else
	{ 
	  continue ;
	}

      if (strlen (tmp_str))
	{
	  _NFMdebug ((fname, "writing <%s> in column 1 : row 1 (column <%s>\n",
		      tmp_str, data [offset+name_offset])) ;
	  strcat (tmp_str, "\001") ;
	  strcat (sql_str, tmp_str) ;
	  sprintf (tmp_str, "%%-%ds", NFM_NAME+1) ;
	  if (strlen (val1))
	    sprintf (val, tmp_str, val1) ;
	  else
	    sprintf (val, tmp_str, data[offset+name_offset]) ;
	  status = PCmem_write_data (temp_list, 1, col, 
				     val) ;
	  if (status != NFM_S_SUCCESS) 
	    {
	      _NFMdebug ((fname, "PCmem_write_data <0x%.8x>\n", status));
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }
	}
      else
	{
	  --max_count ;
	}
    }

/*  _NFMdebug ((fname, "max_count is %d\n", max_count)) ; */
  for (i=max_count; i<9; i++) 
    {
      _NFMdebug ((fname, "i is <%d>\n", i)) ; 
      strcat (sql_str, "\001") ;
    }
  status = _NFMpc_write_row (&temp_list, sql_str) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "PC write failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  if (_NFMdebug_st.NFMdebug_on)
   _NFMpc_print_mem_buffer ("query_add_item _buffer", temp_list,
                            _NFMdebug_st.NFMdebug_file) ;


  /* send default value buffer */
  status = PCmem_get_buffer_size (temp_list, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  
  _NFMdebug ((fname, "size is %d\n", size)) ;
  status = NETbuffer_send (&OUT_PIPE, (char *) temp_list, &size) ;
  if (status != NET_S_SUCCESS)
    {
      _NFMdebug ((fname, "buffer send failed : status = <0x%.8x>\n", status));
      ERRload_struct (NFM, NFM_E_NET, "", "") ;
      return (NFM_E_NET) ;
    }


  _NFMdebug ((fname, "waiting response of client\n")) ;
  status = NETbuffer_receive (&IN_PIPE, (char *) temp_list, &size) ;
  if (status != NET_S_SUCCESS)
    {
      _NFMdebug ((fname, "buffer send failed : status = <0x%.8x>\n", status));
      ERRload_struct (NFM, NFM_E_NET, "", "") ;
      return (NFM_E_NET) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
  
long NFMSpc_display_items (in_list, out_list)
     char *in_list ;
     char *out_list ;
{
  long   status;
  char   catalog_name [NFM_CATALOGNAME+1] ;
  char   search_name [NFM_CATALOGNAME+1] ;
  char   sort_name [NFM_CATALOGNAME+1] ;
  char *fname = "NFMSpc_display_items" ;
  MEMptr syn_list = NULL, data_list = NULL ;
  long  size ;
  char *pc_list = NULL, *buffer= NULL ;
  struct NETbuffer_info *list_ptr ;

  _NFMdebug ((fname, "ENTER\n")) ;

  out_list = out_list ;

  status = PCmem_read_data (in_list, 1, 1, catalog_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (catalog_name) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 2, search_name);
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (search_name) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  status = PCmem_read_data (in_list, 1, 3, sort_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "PCmem_read_data (sort_name) : status = <0x%.8x>\n",
		   status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "catalog_name %s : search name %s : sort name %s\n",
	      catalog_name, search_name, sort_name)) ;

  status = NFMdisplay_items (catalog_name, search_name, sort_name,
			     0, &syn_list, &data_list);
  if (status != NFM_S_SUCCESS)
    {

      _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));
      return (status);
    }

  buffer = (char *) malloc (PC_ALLOCATION_SIZE) ;
  if (buffer == NULL)
    {
      _NFMdebug ((fname, "Failure : Malloc Failed\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }
  /*
    SEND FORMAT
    */

  status = _NFMconvert_format_to_list (data_list, &pc_list) ;
  if (status != NFM_S_SUCCESS)
    {
      if (pc_list) free (pc_list) ;
      free (buffer) ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  list_ptr = (struct NETbuffer_info *) pc_list ;
  list_ptr -> request =  CL_DISPLAY_ITEMS ;
  size = list_ptr -> size ;
  _NFMdebug ((fname, "size is <%d>\n", size)) ;
  status = NETbuffer_send (&OUT_PIPE, (char *) pc_list, &size) ;
  if (status != NET_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  free (pc_list) ;

  status = NETbuffer_receive (&IN_PIPE, (char *) buffer, &size) ;
  if (status != NET_S_SUCCESS)
    {
      free (buffer) ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  /*
    SEND SYNONYM
    */
  status = _NFMconvert_buf_to_list (syn_list, &pc_list) ;
  if (status != NFM_S_SUCCESS)
    {
      free (buffer) ;
      free (pc_list) ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  list_ptr = (struct NETbuffer_info *) pc_list ;
  list_ptr -> request =  CL_DISPLAY_ITEMS ;
  size = list_ptr -> size ;

  _NFMdebug ((fname, "size is <%d>\n", size)) ;
  status = NETbuffer_send (&OUT_PIPE, (char *) pc_list, &size) ;
  if (status != NET_S_SUCCESS)
    {
      free (buffer) ;
      free (pc_list) ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  free (pc_list) ;


  status = NETbuffer_receive (&IN_PIPE, (char *) buffer, &size) ;
  if (status != NET_S_SUCCESS)
    {
      free (buffer) ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

/*
  SEND DATA 
*/

  status = _NFMconvert_buf_to_list (data_list, &pc_list) ;
  if (status != NFM_S_SUCCESS)
    {
      free (buffer) ;
      free (pc_list) ;
      return (status) ;
    }
  list_ptr = (struct NETbuffer_info *) pc_list ;
  
  list_ptr -> request =  CL_DISPLAY_ITEMS ;
  
  status = _NFMsend_by_row_for_display (pc_list) ;
  if (status != NFM_S_SUCCESS)
    {
      free (pc_list) ;
      free (buffer) ;
      return (status) ;
    }

  free (pc_list) ;
  free (buffer) ;
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
