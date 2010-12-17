#include "machine.h"
#include <stdio.h>
#include "ERR.h"
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMstruct.h"
#include "SQLerrordef.h"
#include "NFMschema.h"

/*  Function is simply a wrapper so as to eliminate
    prototype include file dependencies - Glenn Scott 2/26/92  */

long NFMquery_acl_attributes (user_id, attr_list, data_list, value_list)
  long      user_id;
  MEMptr    *attr_list;
  MEMptr    *data_list;
  MEMptr    *value_list;
  {
    return (WFquery_acl_attributes
        (user_id, attr_list, data_list, value_list));
  }

/*  Function is simply a wrapper so as to eliminate
    prototype include file dependencies - Glenn Scott 2/26/92  */

long NFMadd_acl (user_id, attr_list, data_list)
  long     user_id;
  MEMptr   attr_list;
  MEMptr   data_list; 
  {
    return (WFadd_acl (user_id, attr_list, data_list));
  }


long NFMdelete_acl (workflow_name, acl_name)
   char *workflow_name ;
   char *acl_name ;
  {
  char *fname = "NFMdelete_acl" ;
  MEMptr buffer = NULL ;
  char   tmp_str [512], **data ;
  long   acl_no, wf_no, status ;

  _NFMdebug ((fname, "ENTER\n")) ;
  sprintf (tmp_str, "Select a.n_workflowno, b.n_aclno from nfmworkflow a, nfmacls b where a.n_workflowname = '%s' and b.n_aclname= '%s' and \
a.n_workflowno = b.n_workflowno",
	   workflow_name, acl_name) ;

  status = SQLquery (tmp_str, &buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "SQL no rows found : status = <0x%.8x>\n",
		      status)) ;
	}
      else
	{
	  _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		      status)) ;
	}
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) buffer -> data_ptr  ;
  wf_no = atol (data [0]) ;
  acl_no = atol (data [1]) ;

  status = MEMclose (&buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  status = _WFdelete_acl (acl_no, wf_no, workflow_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_WFdelete_acl failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
