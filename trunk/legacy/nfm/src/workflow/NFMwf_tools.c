#include "machine.h"
#include "WF.h"

extern  struct WFstruct WFinfo;

long _NFMsearch_cmd_table_db(cmd_name)
     char *cmd_name ;
 {
   static char *fname = "_NFMsearch_cmd_table_db" ;
   char   cmd_str [500], **data ;
   MEMptr buffer = NULL, buffer1 = NULL ;
   long   status ;
   
   _NFMdebug ((fname, "cmd_name <%s>\n", cmd_name ));
   
   sprintf (cmd_str,
	    "Select n_commandno,\
n_nfmcommandno, n_entity from nfmcommands where n_commandname = '%s'",
	    cmd_name) ;
   
   status = SQLquery (cmd_str, &buffer, MEM_SIZE) ;
   if (status != SQL_S_SUCCESS)
     {
       MEMclose (&buffer) ;
       if (status == SQL_I_NO_ROWS_FOUND)
	 {
	   _NFMdebug ((fname, "Bad command %s\n", cmd_name)) ;
	   ERRload_struct (NFM, NFM_E_BAD_COMMAND, "", "") ;
	   return (NFM_E_BAD_COMMAND) ;
	 }
       _NFMdebug ((fname, "SQL query : status = <0x%.x8>\n",
		   status)) ;
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
       return (NFM_E_SQL_QUERY) ;
     }
   
   status = MEMbuild_array (buffer) ;
   if (status != MEM_S_SUCCESS)
     {
       MEMclose (&buffer) ;
       _NFMdebug ((fname, "MEMbuild_array : status = <0x%.x8>\n",
		   status)) ;
       ERRload_struct (NFM, NFM_E_MEM, "", "") ;
       return (NFM_E_MEM) ;
     }
   
   data = (char **) buffer->data_ptr ;
   
   WFinfo.command = atol (data [0]) ;
   strcpy(WFinfo.command_name,cmd_name) ;
   strcpy(WFinfo.entity,data [2]) ;
   WFinfo.is_command_mapped = -1 ;

   if (atol (data [1]) != 0)
     {
/******** mapped command ***********/
       sprintf (cmd_str,
		"Select n_commandname, n_entity from nfmcommands \
where n_commandno = %d", WFinfo.command);
       
       status = SQLquery (cmd_str, &buffer1, MEM_SIZE) ;
       if (status != SQL_S_SUCCESS)
	 {
	   MEMclose (&buffer1) ;
	   if (status == SQL_I_NO_ROWS_FOUND)
	     {
	      _NFMdebug ((fname, "Bad nfm command %s\n", cmd_name)) ;
	      ERRload_struct (NFM, NFM_E_BAD_COMMAND, "", "") ;
	      return (NFM_E_BAD_COMMAND) ;
	    }
	   _NFMdebug ((fname, "SQL query : status = <0x%.x8>\n",
		       status)) ;
	   ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	   return (NFM_E_SQL_QUERY) ;
	 }
       
       status = MEMbuild_array (buffer1) ;
       if (status != MEM_S_SUCCESS)
	 {
	   MEMclose (&buffer1) ;
	   _NFMdebug ((fname, "MEMbuild_array : status = <0x%.x8>\n",
		       status)) ;
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	   return (NFM_E_MEM) ;
	 }
       
       data = (char **) buffer1->data_ptr ;

       WFinfo.is_command_mapped = 1 ;
       strcpy(WFinfo.nfmcommand_name,data[0]);
       
       status = MEMclose (&buffer1) ;
       if (status != MEM_S_SUCCESS)
	 {
	   _NFMdebug ((fname, "MEMclose (buffer1) : status = <0x%.8x>\n",
		       status)) ;
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	   return (NFM_E_MEM) ;
	 }
     }
   
   status = MEMclose (&buffer) ;
   if (status != MEM_S_SUCCESS)
     {
       _NFMdebug ((fname, "MEMclose (buffer) : status = <0x%.8x>\n",
		   status)) ;
       ERRload_struct (NFM, NFM_E_MEM, "", "") ;
       return (NFM_E_MEM) ;
     }
   
   _NFMdebug ((fname, "command name %s entity %s command no %d\n",
	       WFinfo.command_name, WFinfo.entity, WFinfo.command)) ;
   if (WFinfo.is_command_mapped == 1)
     _NFMdebug ((fname, "nfm command mapped %s\n",
		 WFinfo.nfmcommand_name)) ;
   return(NFM_S_SUCCESS);		
 }


long _NFMsearch_state_table_db (state_no, state_name)
     int	state_no;
     char   *state_name ;
{
  long status ;
  static char *fname = "_NFMsearch_state_table_db" ;
  MEMptr buffer = NULL ;
  char   cmd_str [500] ;
  char   **data ;
  
  _NFMdebug ((fname, "State No : %d\n", state_no));
  
  if(state_no == 0 || state_no == 1)
    {
      _NFMdebug ((fname, "State not defined : SUCCESS\n"));
      return(NFM_S_SUCCESS); 
    }
  
  sprintf (cmd_str,
	   "Select n_statename from nfmstates \
where n_stateno = %d",
	   state_no) ;
  
  status = SQLquery (cmd_str, &buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  ERRload_struct (NFM, NFM_E_BAD_STATE, "", "") ;
	  return (status) ;
	}
	  _NFMdebug ((fname, "SQL query : status = <0x%.x8>\n",
		      status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.x8>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  data = (char **) buffer->data_ptr ;
  
  strcpy (state_name, data[0]) ;
  
  status = MEMclose (&buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return(NFM_S_SUCCESS) ;
}

long WFload_acl (user_id, user_name, wf_name, acl_name)
     long     user_id;
     char     *user_name;
     char     *wf_name, *acl_name;
{
  char *fname = "WFload_acl" ;
  long    status;
  MEMptr  attr_list = NULL, data_list = NULL, value_list = NULL;
  
  _NFMdebug ((fname, "User Name = <%s> : Wf Name = <%s> : Acl Name = <%s>\n",
	      user_name, wf_name, acl_name));
  _NFMdebug ((fname, "        ADD ACL %s", ""));
  
  status = WFquery_acl_attributes (user_id,
				   &attr_list, &data_list, &value_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&attr_list); 
      MEMclose (&data_list);
      MEMclose (&value_list);
      _NFMdebug ((fname, "Qry Acl Attr : status = <0x%.8x>\n", status));
      return (status);
    }
  
  status = WFset_acl (user_id, wf_name, acl_name,
		      attr_list, data_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&attr_list); MEMclose (&data_list);
      _NFMdebug ((fname, "Set Acl : status = <0x%.8x>\n", status));
      return (status);
    }
  
  status = WFadd_acl (user_id, attr_list, data_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&attr_list); MEMclose (&data_list);
      _NFMdebug ((fname, "Enter Acl : status = <0x%.8x>\n", status));
      return (status);
    }
  
  MEMclose (&attr_list);   
  MEMclose (&data_list); 
  MEMclose (&value_list);
  
  _NFMdebug ((fname, "        ADD ACL SUCCESSFUL%s\n", ""));
  _NFMdebug ((fname, "        ADD ACL CLASS USERS %s", ""));
  
  status = WFquery_acl_class_users (user_id, acl_name,
				    &attr_list, &data_list, &value_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&attr_list); 
      MEMclose (&data_list);
      MEMclose (&value_list);
      _NFMdebug ((fname, "ITEM WF : Qry Acl Users : status = <0x%.8x>\n", status));
      return (status);
    }
  
  status = WFset_acl_class_users (user_id, wf_name, user_name,
				  attr_list, data_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&attr_list); MEMclose (&data_list);
      _NFMdebug ((fname, "ITEM WF : Set Acl Class Users : status = <0x%.8x>\n",
		status));
      return (status);
    }
  
  status = WFupdate_acl_class_users (user_id, attr_list, data_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&attr_list); 
      MEMclose (&data_list);
      MEMclose (&value_list);
      _NFMdebug ((fname, "Upd Acl Users : status = <0x%.8x>\n", status));
      return (status);
    }
  
  MEMclose (&attr_list); 
  MEMclose (&data_list); 
  MEMclose (&value_list);
  
  _NFMdebug ((fname, "        ADD ACL CLASS USERS SUCCESSFUL%s\n", ""));
  _NFMdebug ((fname, "        ADD ACL SIGNOFF USERS %s", ""));
  
  status = WFquery_acl_signoff_users (user_id, acl_name,
				      &attr_list, &data_list, &value_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&attr_list); 
      MEMclose (&data_list); 
      MEMclose (&value_list);
      _NFMdebug ((fname, "Qry Acl Signoff Users : status = <0x%.8x>\n",
		status));
      return (status);
    }
  
  status = WFset_acl_signoff_users (user_id, wf_name, user_name,
				    attr_list, data_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&attr_list); MEMclose (&data_list);
      _NFMdebug ((fname, "ITEM WF : Set Acl SignOff Users : status = <0x%.8x>\n", 
		status));
      return (status);
    }
  
  status = WFupdate_acl_signoff_users (user_id, attr_list, data_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&attr_list); 
      MEMclose (&data_list); 
      MEMclose (&value_list);
      _NFMdebug ((fname, "ITEM WF : Upd Acl Signoff Users : status = <0x%.8x>\n",
		status));
      return (status);
    }
  
  MEMclose (&attr_list);
  MEMclose (&data_list);
  MEMclose (&value_list);
  
  _NFMdebug ((fname, "        ADD ACL SIGNOFF USERS SUCCESSFUL%s\n", ""));
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

