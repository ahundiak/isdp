#include "machine.h"
#include "WF.h"

 extern struct WFstruct WFinfo;

long WFget_active_proj_no (proj_no)
     long *proj_no ;
{
  *proj_no = WFinfo.proj_no ;
}

long WFget_command_no (command_no)
     long *command_no ;
{
  *command_no = WFinfo.command ;
}

long WFload_item_no (item_no)
     long item_no ;
{
  WFinfo.item_no = item_no ;
}

long WFload_acl_st (acl_no)
     long acl_no ;
{
  WFinfo.acl = acl_no ;
}

long WFload_wf_struct_for_sts ()
{
  static char *fname = "WFload_wf_struct_for_sts" ;
  long    status ;
  MEMptr  list = NULL ;
  char    **data ;
  char    sql_str [1024] ;
  
  _NFMdebug ((fname, "ENTER\n")) ;

  if (WFinfo.workflow < 1)
    {
      sprintf (sql_str, "select distinct a.n_transitionno, a.n_transitionname,\
a.n_logonsuccess, a.n_logonfailure, b.n_aclname, c.n_statename, a.n_tostate, \
d.n_workflowname, d.n_workflowno \
from nfmtransitions a, nfmacls b, nfmstates c, nfmworkflow d \
WHERE b.n_aclno = %d \
AND a.n_commandno = %d \
AND a.n_workflowno = b.n_workflowno \
AND a.n_workflowno = d.n_workflowno \
AND c.n_stateno = a.n_tostate",
	       WFinfo.acl, WFinfo.command) ;
    }
  else
    {
  sprintf (sql_str, "select distinct a.n_transitionno, a.n_transitionname, \
a.n_logonsuccess, a.n_logonfailure, b.n_aclname, c.n_statename, a.n_tostate \
from nfmtransitions a, nfmacls b, nfmstates c \
WHERE b.n_aclno = %d \
AND a.n_commandno = %d \
AND a.n_workflowno = b.n_workflowno \
AND c.n_stateno = a.n_tostate",
	      WFinfo.acl, WFinfo.command) ;
    }
     
  status = SQLquery (sql_str, &list, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "No transitions\n")) ;
	  ERRload_struct (NFM, NFM_E_NO_TRANSITIONS, "", "") ;
	  return (NFM_E_NO_TRANSITIONS) ;
	}
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "Sql query failed : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  data = (char **) list -> data_ptr ;
  
  WFinfo.transition = atol (data [0]);
  strcpy (WFinfo.transition_name, data [1]) ;
  strcpy (WFinfo.logon_s, data [2]) ;
  strcpy (WFinfo.logon_f, data [3]) ;
  strcpy (WFinfo.acl_name, data [4]) ;
  strcpy (WFinfo.next_statename, data [5]) ;
  WFinfo.next_state = atol (data [6]) ;
  if (WFinfo.workflow < 1)
    {
      strcpy (WFinfo.workflow_name, data [7]) ;
      WFinfo.workflow = atol (data [8]) ;
    }
  status = MEMclose (&list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long WFload_item_name (item_name)
     char *item_name ;
{
  strcpy (WFinfo.item_name, item_name) ;
}

long WFload_item_rev (item_rev)
     char *item_rev ;
{
  strcpy (WFinfo.item_rev, item_rev) ;
}

long WFload_catalog_name (catalog_name)
     char *catalog_name ;
{
  strcpy (WFinfo.catalog_name, catalog_name) ;
}

long WFload_catalog_no (catalog_no)
     long catalog_no ;
{
  WFinfo.catalog_no = catalog_no ;
}





long WFload_wf_struct_using_from_and_to_state (fromstate,tostate)
	long fromstate,tostate;
{
  static char *fname = "WFload_wf_struct_using_from_and_to_state" ;
  long    status ;
  MEMptr  list = NULL ;
  char    **data ;
  char    sql_str [1024],err_str[512] ;
  
  _NFMdebug ((fname, "ENTER: fromstate <%d> tostate <%d>\n",fromstate,tostate)) ;

  if (WFinfo.workflow < 1)
    {
/* Corrupted WFinfo structure */
	  _NFMdebug ((fname, "WFinfo structure has no workflow <%d>\n",WFinfo.workflow)) ;
	  ERRload_struct (NFM, NFM_E_WORKFLOW_NOT_SET, "") ;
	  return(NFM_E_WORKFLOW_NOT_SET);
    }
  else
    {
  sprintf (sql_str, "select distinct a.n_transitionno, a.n_transitionname, \
a.n_commandno, a.n_logonsuccess, a.n_logonfailure, a.n_notify \
from nfmtransitions a \
WHERE a.n_workflowno = %d \
AND a.n_fromstate = %d \
AND a.n_tostate =  %d" ,
	      WFinfo.workflow, fromstate,tostate) ;
    }
     
  status = SQLquery (sql_str, &list, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      MEMclose(&list);
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "There are no transitions satisfying\
workflow_no <%d> : from_state <%d> : to_state <%d>\n",WFinfo.workflow,fromstate,tostate)) ;
	  ERRload_struct (NFM, NFM_E_TRANSITION_WORKFLOW_STATE, "%d%d%d",
WFinfo.workflow,fromstate,tostate) ;
	  return (NFM_E_TRANSITION_WORKFLOW_STATE) ;
	}
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "Sql query failed : status = <0x%.8x>\n",
		  status)) ;
      _NFMdebug ((fname, "Sql query :status = <%s>\n",
		  sql_str)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (list) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose(&list);
      _NFMdebug ((fname, "MEMbuild array first: status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMbuild_array first",
fname,"status",status) ;
      return (NFM_E_MEM_ERR) ;
    }
  
  data = (char **) list -> data_ptr ;

  WFinfo.curr_state = fromstate;
  WFinfo.next_state = tostate;
  
  WFinfo.transition = atol (data [0]);
  strcpy (WFinfo.transition_name, data [1]) ;
  WFinfo.command = atol (data [2]);
  strcpy (WFinfo.logon_s, data [3]) ;
  strcpy (WFinfo.logon_f, data [4]) ;
  strcpy (WFinfo.notify, data [5]) ;
  status = MEMclose (&list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose first: status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMclose first",
fname,"status",status) ;
      return (NFM_E_MEM_ERR) ;
    }

/* 12/8/92 - KT - compiler choked!
  sprintf (sql_str, "select distinct a.n_commandname, a.n_entity, \
a.n_nfmcommandno \
from nfmcommands a \
WHERE a.n_commandno = %d" \
	      , WFinfo.command) ;
*/
  sprintf (sql_str, 
  "select distinct a.n_commandname, a.n_entity, a.n_nfmcommandno from nfmcommands a WHERE a.n_commandno = %d",
   WFinfo.command);

  status = SQLquery (sql_str, &list, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      MEMclose(&list);
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "The nfmcommands table has no entries for \
command number <%d>\n",WFinfo.command)) ;
	  ERRload_struct (NFM, NFM_E_COMMAND_NO_INVALID, "%d", WFinfo.command) ;
	  return (NFM_E_COMMAND_NO_INVALID) ;
	}
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "Sql query failed : status = <0x%.8x>\n",
		  status)) ;
      _NFMdebug ((fname, "Sql query :status = <%s>\n",
		  sql_str)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (list) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose(&list);
      _NFMdebug ((fname, "MEMbuild array second: status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMbuild_array second",
fname,"status",status) ;
      return (NFM_E_MEM_ERR) ;
    }

  data = (char **) list -> data_ptr ;
  strcpy (WFinfo.command_name, data [0]) ;
/* LEAVE THE ENTITY FIELD AS IT IS ( USE MAKE TRANS ENTITY ) 
  		strcpy (WFinfo.entity, data [1]) ;
*/

  WFinfo.is_command_mapped = atol (data [2]);
  status = MEMclose (&list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose second: status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMclose second",
fname,"status",status) ;
      return (NFM_E_MEM_ERR) ;
    }
  status = _WFquery_state_name(WFinfo.curr_state, WFinfo.current_statename);
  if(status != NFM_S_SUCCESS)
  {
	sprintf(err_str,"Cannot get state name for current state <%d> : status <0x%.8x>",WFinfo.curr_state,status);
	_NFMdebug((fname,"%s\n",err_str));
/* ERRload done by lower function

	ERRload_struct(NFM,NFM_E_MESSAGE,"%s",err_str);
*/
	return(status);
  }
  status = _WFquery_state_name(WFinfo.next_state, WFinfo.next_statename);
  if(status != NFM_S_SUCCESS)
  {
	sprintf(err_str,"Cannot get state name for next state <%d> : status <0x%.8x>",WFinfo.next_state,status);
	_NFMdebug((fname,"%s\n",err_str));
/* ERRload done by lower function
	ERRload_struct(NFM,NFM_E_MESSAGE,"%s",err_str);
*/
	return(status);
  }
  if(WFinfo.is_command_mapped )
  {
	status = NFMget_command_name(65535,WFinfo.is_command_mapped,WFinfo.nfmcommand_name);
	if(status != NFM_S_SUCCESS)
	{
		sprintf(err_str,"Cannot get nfmcommand_name for n_nfmcommandno\
 = <%d> : status <0x%.8x>\n",WFinfo.is_command_mapped,status);
		ERRload_struct(NFM,NFM_E_COMMAND_NO_INVALID,"%d",WFinfo.is_command_mapped);
		_NFMdebug((fname,"%s",err_str));
		return(NFM_E_COMMAND_NO_INVALID);
	}
  }

  
  
  _NFMdebug ((fname, "SUCCESSFUL status <0x%.8x>\n",NFM_S_SUCCESS)) ;
  return (NFM_S_SUCCESS);
}
