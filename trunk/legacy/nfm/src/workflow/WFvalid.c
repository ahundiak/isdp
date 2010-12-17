#include "machine.h"
#include "WF.h"
#include "WFcommands.h"

 struct WFstruct WFinfo ;

 extern struct NFMglobal_st NFMglobal ;
/*
    November 1990. 

    This is how the default/user defined workflows are designed 
    to be used by the predecessor(s) of NFM.

    NFM for its user interfaces (and for applns like PDM,DPM etc.)
    provides the following workflows and acls during NFM initialzation.

	WORKFLOW                DEFAULT ACL
 ----------------------------------------------

    (1) NFM_SDP_WORKFLOW	NFM_SDP_ACL
    (2) NFM_ADMIN_WORKFLOW	NFM_SDP_ACL
    (3) NFM_CATALOG_WORKFLOW    NFM_SDP_ACL
    (4) NFM_PROJECT_WORKFLOW    NFM_SDP_ACL
    (5) NFM_ITEM_WORKFLOW       NFM_SDP_ACL

        ACL
 -------------------------------------------

    (1) NFM_SDP_ACL	
    (2) NFM_ADMIN_ACL
    (3) NFM_CATALOG_ACL
    (4) NFM_PROJECT_ACL
    (5) NFM_ITEM_ACL
 
     Each workflow has a default acl to go with it and NFM 
     provides one for each WF it defines. (stored in nfmworkflow)

     All the five ACLs are defined by NFM during initialization 
     and the user initializing (nfmadmin) gets added to all the 
     acls and to every class these acls define.
   
     Note that these ACLs are defined (class structure) in the 
     workflow files.

     Each NFM command is conceptually viewed as dealing with 
     an entity. This provision helps the software (NFM) to limit 
     its SQL queries during its user access validation and set 
     to state. Specifically a resolution on the n_aclno, n_fromstate 
     and even the workflow is possible when preparing queries.
     However, this is not true all the time and NFM does search the 
     schema blindly often. This becomes apparent from the following 
     paragraphs.

     Following are the entities ... 

     (1) NFMSDP
     (2) NFMADMIN
     (3) NFMCATALOG
     (4) NFMPROJECT
     (5) NFMITEM
     (6) NFMNOENTITY

     All the NFM commands (and Appln commands) are expected to 
     declare their entities during initialization. 

     A workflow default or otherwise specifies :: 

     (a) The transition(s) for a subset of commands. 
     (b) Acl .. a list of classes 
     (c) For each transition the classes that the user 
         should belong to inorder to execute 

     Here are the rest of the rules/idiosyncracies ::

     Each of the NFM default workflows deal with the following entities

     (1) NFM_SDP_WORKFLOW   --- NFMSDP, NFMNOENTITY
     (2) NFM_ADMIN_WORKFLOW --- NFMADMIN, NFMNOENTITY
     (3) NFM_CATALOG_WORKFLOW -- NFMCATALOG, NFMNOENTITY
     (4) NFM_PROJECT_WORKFLOW -- NFMPROJECT, NFMNOENTITY
     (5) NFM_ITEM_WORKFLOW ---  NFMITEM, NFMNOENTITY

      A user defined workflow can specify transitions only to 
      commands that deal with entites NFMITEM, NFMNOENTITY.

      Also once defined the workflow cannot be changed in 
      any way.

*/

 long WFvalidate_user_access (user_id, command, workflow_name,
                project_name, catalog_name, item_name, item_rev)
   long    user_id;
   char    *command, *workflow_name;
   char    *project_name, *catalog_name;
   char    *item_name, *item_rev;
   {
     static char *fname = "WFvalidate_user_access" ;
     long       status, atol (), is_add_item ;
     long	_WFsdp_validate();
     long	_WFadmin_validate();
     long	_WFcatalog_validate();
     long	_WFproject_validate();
     long	_WFnoentity_validate();
     long       _WFitem_any_wf_acl_validate();
     long       _WFload_command_in_struct() ;
     long       _WFload_cat_proj_info();
     long       _WFload_cat_item_info() ;

     user_id = user_id ;
     _NFMdebug ((fname, "Application = <%s> : Commands = <%s> : Workflow Name = <%s> : Project Name = <%s> : Table Name = <%s> : Item Name = <%s> : Item Rev = <%s>\n", 
		 NFMglobal.application, command, workflow_name,
		 project_name, catalog_name, item_name, item_rev));

     _WFinit_wfinfo () ;

     status = _NFMsearch_cmd_table_db(command);
     if(status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "_NFMsearch_cmd_table failed status 0x%.8x\n",
		     status));
	 return(status);
       }
     
     NFMreset_message_struct (NFMglobal.NFMuserid);

     strcpy(WFinfo.workflow_name,workflow_name);
     strcpy(WFinfo.item_name,item_name); 
     strcpy(WFinfo.item_rev,item_rev); 
     strcpy(WFinfo.catalog_name,catalog_name); 
     strcpy(WFinfo.proj_name,project_name);

     if (WFinfo.entity[0] == 'S')
      {
        status = _WFsdp_validate(NFMglobal.NFMuserid);
        if (status != NFM_S_SUCCESS)
         {  
           _NFMdebug ((fname, "_WFsdp_validate  : status = <0x%.8x>\n",
           status));
           return (status);           
         }
      }
     else if (WFinfo.entity [0] == 'A') 
      {
        status = _WFadmin_validate(NFMglobal.NFMuserid) ;
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "_WFadmin_validate : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }
     else if (WFinfo.entity [0] == 'C') 
      {
        status = _WFcatalog_validate (NFMglobal.NFMuserid) ;
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "_WFcatalog_validate : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }
     else if (WFinfo.entity [0] == 'P') 
      {
        status = _WFproject_validate (NFMglobal.NFMuserid) ;
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "_WFproject_validate : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }
     else if (WFinfo.entity [0] == 'I')
     {
/* load WFinfo.proj_no, WFinfo.catalog_no */
       status = _WFload_cat_proj_info();
       if (status != NFM_S_SUCCESS)
	 {
	   _NFMdebug ((fname, "_WFload_cat_item_info : status = <0x%.8x>\n",
		       status));
	   return (status);
	 }

        if ((!strcmp(NFMglobal.application,"NFM") || 
	     !strcmp(NFMglobal.application,"nfm")))
	  {
	    /* is command = "Add Item" */
	    
	    if (strcmp (WFinfo.command_name, ADD_ITEM) == 0)
	      {
		status = _WFitem_any_wf_acl_validate (NFMglobal.NFMuserid);
		if (status != NFM_S_SUCCESS)
		  {
		    _NFMdebug ((fname, "_WFitem_any_wf_acl_validate : status = <0x%.8x>\n",
				status));
		    return (status);
		  }
	      }
	    else
	      {
		_NFMdebug ((fname, 
			    "WFvalidate_user_access : Not Add Item\n")) ;

		status = _WFitem_transition_validate (NFMglobal.NFMuserid);
		if (status != NFM_S_SUCCESS)
		  {
		    _NFMdebug ((fname, "_WFitem_db_validate : status = <0x%.8x>\n",
				status)) ;
		    return (status) ;
		  }
	    
		status = _WFitem_user_acl_validate (NFMglobal.NFMuserid);
		if (status != NFM_S_SUCCESS)
		  {
		    _NFMdebug ((fname, "_WFitem_user_acl_validate : status = <0x%.8x>\n",
				status));
		    return (status);
		  }
	      }
	  }
        else if(strlen(NFMglobal.application) && 
		strcmp(NFMglobal.application,"NFM"))
	  {
	    is_add_item = 0 ;
	    if (strcmp (WFinfo.command_name, ADD_ITEM) == 0)
	      {
		_NFMdebug ((fname, "comparing %s : %s \n", 
			    WFinfo.command_name, ADD_ITEM)) ;
		is_add_item = 1 ;
	      }
	    else if ((WFinfo.is_command_mapped == 1) &&
		     ((strcmp (WFinfo.nfmcommand_name, ADD_ITEM) == 0)))

	      {
		_NFMdebug ((fname, "command is mapped comparing %s : %s\n",
			    WFinfo.nfmcommand_name, ADD_ITEM)) ;
		is_add_item = 1 ;
	      }

	    if (is_add_item)
	      {
		_NFMdebug ((fname, 
			    "Command mapped to add item or add set\n")) ;
		status = _WFitem_any_wf_acl_validate (NFMglobal.NFMuserid);
		if (status != NFM_S_SUCCESS)
		  {
		    _NFMdebug ((fname, "_WFitem_any_wf_acl_validate : status = <0x%.8x>\n",
				status));
		    return (status);
		  }
	      }
	    else
	      {
		_NFMdebug ((fname, 
			    "WFvalidate_user_access : Not Add Item\n")) ;
		
		status = _WFitem_transition_validate (NFMglobal.NFMuserid);
		if (status != NFM_S_SUCCESS)
		  {
		    _NFMdebug ((fname, "_WFitem_db_validate : status = <0x%.8x>\n",
				status)) ;
		    return (status) ;
		  }
	
		status = _WFitem_user_acl_validate (NFMglobal.NFMuserid);
		if (status != NFM_S_SUCCESS)
		  {
		    _NFMdebug ((fname, "_WFitem_user_acl_validate : status = <0x%.8x>\n",
				status));
		    return (status);
		  }
	      }
	  }
        else 
	  {
		_NFMdebug ((fname, "Appln not set : status <0x%.8x>\n",
		NFM_E_FAILURE));
		_NFMdebug ((fname, "NFM_APP_ID <%s>\n",
		NFMglobal.application)) ;
  	}
      }
     else if(WFinfo.entity [0] == 'N') 
     {
        status = _WFnoentity_validate (NFMglobal.NFMuserid);
        if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "_WFnoentity_validate : status = <0x%.8x>\n",
	  status));
          return (status);
        }
     }
     else if(WFinfo.entity [0] == 'D') 
     {
       _NFMdebug ((fname, "No check validation\n")) ;
       return (NFM_S_SUCCESS) ;
     }
     else
      {
         status = NFM_E_INVALID_ENTITY;
	 ERRload_struct(NFM,status,"",NULL);
         _NFMdebug ((fname, "Invalid Entity : status = <0x%.8x>\n",
         status));
         return (status);
       }

     if (status != NFM_S_SUCCESS)
      {
	if (_NFMdebug_st.NFMdebug_on == 1) NFMprint_wfinfo () ;
        _NFMdebug ((fname, "NO PRIVILEGE : status = <0x%.8x>\n", status));
        return (status);
      }

     if (WFinfo.transition > 0)
      {
        status = NFMpre_execute_process (WFinfo.transition);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Pre Trans Process : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }

     if (_NFMdebug_st.NFMdebug_on == 1) NFMprint_wfinfo () ;

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);

   }

/*
       Validation for commands with entity = NFMSDP	
*/

long  _WFsdp_validate(user_id)
long	user_id;
{
     static char *fname = "_WFsdp_validate" ;
     long	status, atol ();
     MEMptr 	list = NULL, return_buffer = NULL ;
     char	**data;
     long	userno1;
     char	sql_str[200], str [500] ;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     strcpy(WFinfo.workflow_name, "NFM_SDP_WORKFLOW");
     
     if(strlen(WFinfo.workflow_name))
     {
     	strcpy (sql_str,"SELECT a.n_workflowno, b.n_stateno, a.n_aclno, \
b.n_statename \
FROM nfmworkflow a, nfmstates b \
WHERE a.n_workflowname = 'NFM_SDP_WORKFLOW' \
and a.n_stateno = b.n_stateno") ;

         status = SQLquery (sql_str, &list, 512);
         if (status != SQL_S_SUCCESS)
         {
            MEMclose (&list);

            if ((status ) == SQL_I_NO_ROWS_FOUND)
            {
       		status = NFM_E_WORKFLOW_NAME;
              	 ERRload_struct(NFM,status,"",NULL);
                _NFMdebug ((fname, "workflow not found : status = <0x%.8x>\n",
           	status));
           	return (status);
	     }
             status = NFM_E_SQL_QUERY;
	     ERRload_struct(NFM,status,"",NULL);
             _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
             status));
             return (status);
         }
    
         status = MEMbuild_array (list);
         if (status != MEM_S_SUCCESS)
         {
		MEMclose(&list);
 	        status = NFM_E_MEM;
        	ERRload_struct(NFM,status,"",NULL);
                _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        	status));
        	return (status); 
	 }

         data = (char **) list -> data_ptr;

         WFinfo.workflow = atol(data[0]);
         WFinfo.curr_state = atol(data[1]);
	 strcpy (WFinfo.current_statename, data [3]) ;
         WFinfo.acl = atol(data[2]);
         MEMclose(&list); list = NULL;
     }

     /* load n_transitionno */
     sprintf (str, "Select a.n_tostate, a.n_transitionno, a.n_transitionname, \
a.n_logonsuccess, a.n_logonfailure, a.n_notify, b.n_statename  \
from NFMTRANSITIONS a, NFMSTATES b \
where a.n_commandno = %d and a.n_workflowno = %d \
and (a.n_fromstate = 0 or a.n_fromstate = 1 or a.n_fromstate = %d) \
and (a.n_tostate = b.n_stateno)",
              WFinfo.command, WFinfo.workflow, WFinfo.curr_state) ;

     status = SQLquery (str, &return_buffer, MEM_SIZE) ;
     if (status != SQL_S_SUCCESS)
       {
         _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
                     status)) ;
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
         return (NFM_E_SQL_QUERY) ;
       }

   
     status = MEMbuild_array (return_buffer) ;
     if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
                     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         return (NFM_E_MEM) ;
       }

     data = (char **) return_buffer->data_ptr ;
     WFinfo.transition = atol (data [1]) ;
     WFinfo.next_state = atol (data [0]) ;
     strcpy (WFinfo.next_statename, data [6]) ; 
     strcpy(WFinfo.logon_s, data[3]);
     strcpy(WFinfo.logon_f, data[4]);
     strcpy(WFinfo.notify, data [5]);
     strcpy(WFinfo.transition_name, data [2]);


     status = MEMclose (&return_buffer) ;
     if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
                     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         return (NFM_E_MEM) ;
       }

/*
     sprintf(sql_str,"SELECT b.n_userno FROM %s %s %d %s %d %s %d %s",
     "nfmaccess a, nfmaclusers b ",
     "WHERE a.n_transitionno = ",WFinfo.transition,
     "AND b.n_userno = ", NFMglobal.NFMuserno,
     "AND b.n_aclno = ", WFinfo.acl,
     "AND a.n_classno = b.n_classno");

     status = SQLquery (sql_str, &list, 512);
      MEMclose(&list); list = NULL;
*/
     status = SQLfix_qry_res_5(NFMglobal.NFMuserno,WFinfo.transition,
			       WFinfo.acl,&userno1);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list);

        if (status == SQL_I_NO_ROWS_FOUND)
         {
           status = NFM_E_USER_ACCESS_PRIV;
  	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Privilege Violation : status = <0x%.8x>\n",
           status));
           return (status);
         }
         status = NFM_E_SQL_QUERY;
	 ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
        status));
        return (status);
      }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);     
}

/*
       Validation for commands with entity = NFMADMIN
*/

long  _WFadmin_validate(user_id)
long	user_id;
{
     static char *fname = "_WFadmin_validate" ;
     long	status, userno1;
     MEMptr 	list = NULL ;
     char	**data;
     long	atol () ;
     char	str [500] ;

     list = NULL;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     strcpy (WFinfo.workflow_name, "NFM_ADMIN_WORKFLOW") ;
     WFinfo.workflow = WFinfo.admin_workflow_no ;

/*** current state is alway 1 ***/     
     if (WFinfo.admin_workflow_no > 0)
       {
	 sprintf (str, "Select a.n_tostate, a.n_transitionno, a.n_transitionname, a.n_logonsuccess, a.n_logonfailure, a.n_notify, c.n_statename,  \
d.n_aclno, d.n_aclname \
from NFMTRANSITIONS a, NFMWORKFLOW b, NFMSTATES c, NFMACLS d \
where n_commandno = %d \
and (n_fromstate = 0 or n_fromstate = 1 or n_fromstate = %d) \
and (b.n_workflowno = a.n_workflowno) \
and a.n_tostate = c.n_stateno \
and b.n_workflowno = d.n_workflowno",
		  WFinfo.command, WFinfo.workflow, 1) ;
       }
     else
       {
	 sprintf (str, "Select a.n_tostate, a.n_transitionno, a.n_transitionname, a.n_logonsuccess, a.n_logonfailure, a.n_notify, c.n_statename,  \
d.n_aclno, d.n_aclname, \
b.n_workflowno \
from NFMTRANSITIONS a, NFMWORKFLOW b, NFMSTATES c, NFMACLS d \
where n_commandno = %d \
and (n_fromstate = 0 or n_fromstate = 1 or n_fromstate = %d) \
and b.n_workflowname = 'NFM_ADMIN_WORKFLOW' \
and a.n_workflowno = b.n_workflowno \
and a.n_tostate = c.n_stateno \
and b.n_workflowno = d.n_workflowno",
		  WFinfo.command, WFinfo.workflow, 1) ;
       }

     status = SQLquery (str, &list, MEM_SIZE) ;
     if (status != SQL_S_SUCCESS)
       {
	 MEMclose (&list) ;
	 if (status == SQL_I_NO_ROWS_FOUND)
	   {
	     _NFMdebug ((fname, "Workflow is corrupted\n")) ;
	   }
	 else
	   {
	     _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
			 status)) ;
	   }
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	 return (NFM_E_SQL_QUERY) ;
       }

     status = MEMbuild_array (list) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (&list) ;
	 _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     data = (char **) list->data_ptr ;

     WFinfo.next_state = atol (data [0]) ;
     WFinfo.transition = atol (data [1]) ;
     strcpy(WFinfo.transition_name, data [2]);
     strcpy(WFinfo.logon_s, data[3]);
     strcpy(WFinfo.logon_f, data[4]);
     strcpy(WFinfo.notify, data [5]);
     strcpy (WFinfo.next_statename, data [6]) ;
     WFinfo.acl = atol (data [7]) ;
     strcpy (WFinfo.acl_name, data [8]) ;
     if (WFinfo.admin_workflow_no < 1)
       {
	 WFinfo.workflow = atol (data [9]) ;
	 WFinfo.admin_workflow_no = WFinfo.workflow ;
       }
 

     status = MEMclose (&list) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

/*
     sprintf(sql_str,"SELECT b.n_userno FROM %s %s %d %s %d %s %d %s",
     "nfmaccess a, nfmaclusers b ",
     "WHERE a.n_transitionno = ",WFinfo.transition,
     "AND b.n_userno = ", NFMglobal.NFMuserno,
     "AND b.n_aclno = ", WFinfo.acl,
     "AND a.n_classno = b.n_classno");

     status = SQLquery (sql_str, &list, 512);
      MEMclose(&list); list = NULL;
*/

     status = SQLfix_qry_res_5(NFMglobal.NFMuserno,WFinfo.transition,
			       WFinfo.acl,&userno1);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list);

        if (status == SQL_I_NO_ROWS_FOUND)
         {
           status = NFM_E_USER_ACCESS_PRIV;
   	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Privilege Violation : status = <0x%.8x>\n",
           status));
           return (status);
         }

        status = NFM_E_SQL_QUERY;
	 ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }

/*
       Validation for commands with entity = NFMCATALOG
*/

long  _WFcatalog_validate(user_id)
long	user_id;
{
     static char *fname = "_WFcatalog_validate" ;
     long	status;
     char	**data;
     long	userno1, atol() ;
     char       sql_str [1024] ;
     MEMptr     list = NULL ;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     strcpy (WFinfo.workflow_name, "NFM_CATALOG_WORKFLOW") ;
     WFinfo.workflow = WFinfo.catalog_workflow_no ;

     if(strlen(WFinfo.catalog_name))
     {
       sprintf(sql_str,"SELECT a.n_catalogno, a.n_stateno, a.n_aclno, \
b.n_statename, c.n_aclname \
from NFMCATALOGS a, NFMSTATES b, NFMACLS c \
WHERE a.n_catalogname = '%s'\
AND a.n_stateno = b.n_stateno \
AND a.n_aclno = c.n_aclno",
		   WFinfo.catalog_name) ;
         status = SQLquery (sql_str, &list, 512);

/*** redo this query ****
       status = SQLfix_qry_res_9(WFinfo.catalog_name,&(WFinfo.catalog_no),
                                 &(WFinfo.curr_state),&(WFinfo.acl));
*************************/

       if (status != SQL_S_SUCCESS)
         {
	   if (status == SQL_I_NO_ROWS_FOUND)
	     {
	       status = NFM_E_CAT_NOT_IN_LOC;
	       ERRload_struct(NFM,status,"",NULL);
	       _NFMdebug ((fname, "Catalog not found : status = <0x%.8x>\n",
			   status));
	       return (status);
	     }
	   
	   status = NFM_E_SQL_QUERY;
	   ERRload_struct(NFM,status,"",NULL);
	   _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		       status));
	   return (status);
         }

       status = MEMbuild_array (list) ;
       if (status != MEM_S_SUCCESS)
	 {
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	   _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		       status)) ;
	   return (NFM_E_MEM) ;
	 }
       
       data = (char **) list->data_ptr ;
       
       WFinfo.catalog_no = atol (data [0]) ;
       WFinfo.curr_state = atol (data [1]) ;
       WFinfo.acl = atol (data [2]) ;
       strcpy (WFinfo.current_statename, data [3]) ;
       strcpy (WFinfo.acl_name, data [4]) ;

       status = MEMclose (&list) ;
       if (status != MEM_S_SUCCESS)
	 {
	   _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
		       status)) ;
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	   return (NFM_E_MEM) ;
	 }

     if (WFinfo.catalog_workflow_no > 0)
       {
	 sprintf (sql_str, "Select a.n_tostate, a.n_transitionno, a.n_transitionname, a.n_logonsuccess, a.n_logonfailure, a.n_notify, c.n_statename  \
from NFMTRANSITIONS a, NFMWORKFLOW b, NFMSTATES c \
where a.n_commandno = %d \
and (a.n_fromstate = 0 or a.n_fromstate = 1 or a.n_fromstate = %d) \
and (b.n_workflowno = a.n_workflowno) \
and (a.n_tostate = c.n_stateno)",
		WFinfo.command, WFinfo.curr_state) ;
       }
     else
       {
       sprintf (sql_str, "Select a.n_tostate, a.n_transitionno, a.n_transitionname, a.n_logonsuccess, a.n_logonfailure, a.n_notify, c.n_statename,  \
b.n_workflowno \
from NFMTRANSITIONS a, NFMWORKFLOW b, NFMSTATES c \
where a.n_commandno = %d \
and (a.n_fromstate = 0 or a.n_fromstate = 1 or a.n_fromstate = %d) \
and (b.n_workflowname = 'NFM_CATALOG_WORKFLOW') \
and (a.n_workflowno = b.n_workflowno) \
and (a.n_tostate = c.n_stateno)",
		WFinfo.command, WFinfo.curr_state) ;
     }
       
       status = SQLquery (sql_str, &list, MEM_SIZE) ;
       if (status != SQL_S_SUCCESS)
	 {
	   if (status == SQL_I_NO_ROWS_FOUND)
	     {
	       status = NFMget_transition_error () ;
	       ERRload_struct (NFM, status, "", "") ;
	       return (status) ;
	     }

	   _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		       status)) ;
	   ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	   return (NFM_E_SQL_QUERY) ;
	 }
       
       status = MEMbuild_array (list) ;
       if (status != MEM_S_SUCCESS)
	 {
	   _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		       status)) ;
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	   return (NFM_E_MEM) ;
	 }
       
       data = (char **) list->data_ptr ;
       
       strcpy(WFinfo.transition_name, data [2]);
       WFinfo.transition = atol (data [1]) ;
       WFinfo.next_state = atol (data [0]) ;
       strcpy (WFinfo.next_statename, data [6]) ;
       strcpy(WFinfo.logon_s, data[3]);
       strcpy(WFinfo.logon_f, data[4]);
       strcpy(WFinfo.notify, data [5]);

     if (WFinfo.catalog_workflow_no < 1)
       {
	 WFinfo.workflow = atol (data [7]) ;
	 WFinfo.catalog_workflow_no = WFinfo.workflow ;
       }
       
       status = MEMclose (&list) ;
       if (status != MEM_S_SUCCESS)
	 {
	   _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
		       status)) ;
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	   return (NFM_E_MEM) ;
	 }
/****       
     sprintf(sql_str,"SELECT b.n_userno FROM %s %s %d %s %d %s %d %s",
	     "nfmaccess a, nfmaclusers b ",
	     "WHERE a.n_transitionno = ",WFinfo.transition,
	     "AND b.n_userno = ", NFMglobal.NFMuserno,
	     "AND b.n_aclno = ", WFinfo.acl,
	     "AND a.n_classno = b.n_classno");
******/
       status = SQLfix_qry_res_5 (NFMglobal.NFMuserno,WFinfo.transition,
				  WFinfo.acl,&userno1);

       if (status != SQL_S_SUCCESS)
	 {
	   if ((status ) == SQL_I_NO_ROWS_FOUND)
	     {
	       status = NFM_E_USER_ACCESS_PRIV;
	       ERRload_struct(NFM,status,"",NULL);
	       _NFMdebug ((fname, "Privilege Violation : status = <0x%.8x>\n",
			   status));
	       return (status);
	     }
	   
	   status = NFM_E_SQL_QUERY;
	   ERRload_struct(NFM,status,"",NULL);
	   _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		       status));
	   return (status);
	 }
     }
     else
       {
	 _NFMdebug ((fname, "catalog name was not given\n")) ;
	 
	 if (WFinfo.catalog_workflow_no > 0)
	   {
	     sprintf(sql_str,
		     "SELECT DISTINCT b.n_userno, c.n_aclno, c.n_aclname \
FROM nfmaccess a, nfmaclusers b, nfmacls c \
WHERE  c.n_workflowno = %d \
AND c.n_aclno = b.n_aclno \
AND a.n_classno = b.n_classno \
AND  b.n_userno = %d ", 
		     WFinfo.catalog_workflow_no, NFMglobal.NFMuserno) ;
	   }
	 else
	   {
	     sprintf(sql_str,
		     "SELECT DISTINCT c.n_workflowno, c.n_aclno, c.n_aclname \
FROM nfmaccess a, nfmaclusers b, nfmacls c \
WHERE  c.n_workflowno = (select n_workflowno from nfmworkflow where n_workflowname = 'NFM_CATALOG_WORKFLOW') \
AND c.n_aclno = b.n_aclno \
AND a.n_classno = b.n_classno \
AND  b.n_userno = %d ", 
		NFMglobal.NFMuserno) ;
	   }

	status = SQLquery (sql_str, &list, MEM_SIZE) ;
/*   redo this query 
        status = SQLfix_qry_res_7(NFMglobal.NFMuserno,WFinfo.transition,
				  WFinfo.workflow,&userno1);
*/
        if (status != SQL_S_SUCCESS)
	  {
	    MEMclose (&list);
	    
	    if ((status ) == SQL_I_NO_ROWS_FOUND)
	      {
		status = NFM_E_USER_ACCESS_PRIV;
		ERRload_struct(NFM,status,"",NULL);
		_NFMdebug ((fname, "Privilege Violation : status = <0x%.8x>\n",
			    status));
		return (status);
	      }
	    
	    ERRload_struct(NFM,  NFM_E_SQL_QUERY,"",NULL);
	    _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
			status));
	    return (NFM_E_SQL_QUERY) ;
	  }

	 status = MEMbuild_array (list) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (&list) ;
	     _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
			 status)) ;
	     ERRload_struct (NFM, NFM_E_MEM, "", "");
	     return (NFM_E_MEM) ;
	   }
	 
	 data = (char **) list->data_ptr ;
	 
	 if (WFinfo.catalog_workflow_no < 1)
	   {
	     WFinfo.workflow = atol (data [0]) ;
	     WFinfo.acl = atol (data [1]) ;
	     strcpy (WFinfo.acl_name, data [2]) ;
	     WFinfo.catalog_workflow_no = WFinfo.workflow ;
	   }
	 else
	   {
	     WFinfo.acl = atol (data [1]) ;
	     strcpy (WFinfo.acl_name, data [2]) ;
	   }

	 status = MEMclose (&list) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
			 status)) ;
	     ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	     return (NFM_E_MEM) ;
	   }
       }

     _NFMdebug ((fname, "SUCCESSFUL\n"));
     return (NFM_S_SUCCESS);     
   }


/*
       Validation for commands with entity = NFMPROJECT
*/

long  _WFproject_validate(user_id)
long	user_id;
{
     static char *fname = "_WFproject_validate" ;
     long	status ;
     MEMptr 	list = NULL ;
     char	**data;
     long	userno1, atol () ;
     char	sql_str [512] ;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     strcpy (WFinfo.workflow_name, "NFM_PROJECT_WORKFLOW") ;
     WFinfo.workflow = WFinfo.project_workflow_no ;

     if(strlen(WFinfo.proj_name))
     {
	sprintf(sql_str,"SELECT a.n_projectno, a.n_stateno, a.n_aclno, b.n_statename, c.n_aclname \
from NFMPROJECTS a, NFMSTATES b, NFMACLS c \
WHERE n_projectname = '%s' \
and b.n_stateno = a.n_stateno \
and a.n_aclno = c.n_aclno",
		WFinfo.proj_name);

	status = SQLquery (sql_str, &list, MEM_SIZE) ;
	/******** needs changes **********
	  status = SQLfix_qry_res_10(WFinfo.proj_name,&(WFinfo.proj_no),
	  &(WFinfo.curr_state),&(WFinfo.acl));
	  ***********************************/
	if (status != SQL_S_SUCCESS)
         {
            MEMclose (&list);

            if (status == SQL_I_NO_ROWS_FOUND)
            {
           	status = NFM_E_PROJ_NOT_IN_LOP;
	        ERRload_struct(NFM,status,"",NULL);
           	_NFMdebug ((fname, "Project not found : status = <0x%.8x>\n",
     	 	status));
      	        return (status);
            }

            status = NFM_E_SQL_QUERY;
   	    ERRload_struct(NFM,status,"",NULL);
            _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
            status));
            return (status);
	  }

	status = MEMbuild_array (list) ;
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (&list) ;
	    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
			status)) ;
	    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	    return (NFM_E_MEM) ;
	  }

	data = (char **) list->data_ptr ;
	WFinfo.proj_no  = atol (data[0]) ;
	WFinfo.curr_state  = atol (data [1]) ;
	WFinfo.acl = atol (data [2]) ;
	strcpy (WFinfo.current_statename, data [3]) ;
	strcpy (WFinfo.acl_name, data [4]) ;
	
	status = MEMclose (&list) ;
	if (status != MEM_S_SUCCESS)
	  {
	    _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
			status)) ;
	    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	    return (NFM_E_MEM) ;
	  }
	
	if (WFinfo.project_workflow_no < 1)
	  {
	    sprintf (sql_str, "Select a.n_tostate, a.n_transitionno, a.n_transitionname, \
a.n_logonsuccess, a.n_logonfailure, a.n_notify, \
c.n_statename, b.n_workflowno  \
from NFMTRANSITIONS a, NFMWORKFLOW b, NFMSTATES c \
where a.n_commandno = %d and b.n_workflowname = 'NFM_PROJECT_WORKFLOW' \
and (a.n_fromstate = 0 or a.n_fromstate = 1 or a.n_fromstate = %d) \
and a.n_workflowno = b.n_workflowno \
and a.n_tostate = c.n_stateno",
		     WFinfo.command, WFinfo.curr_state) ;
	  }
	else
	  {
	    sprintf (sql_str, "Select a.n_tostate, a.n_transitionno, a.n_transitionname, \
a.n_logonsuccess, a.n_logonfailure, a.n_notify, \
c.n_statename  \
from NFMTRANSITIONS a, NFMWORKFLOW b, NFMSTATES c \
where a.n_commandno = %d and b.n_workflowname = 'NFM_PROJECT_WORKFLOW' \
and (a.n_fromstate = 0 or a.n_fromstate = 1 or a.n_fromstate = %d) \
and a.n_workflowno = b.n_workflowno \
and a.n_tostate = c.n_stateno",
		     WFinfo.command, WFinfo.curr_state) ;
	  }
	
	status = SQLquery (sql_str, &list, MEM_SIZE) ;
	if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	  {
	    _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
			status)) ;
	    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	    return (NFM_E_SQL_QUERY) ;
	  }
	
	if (status == SQL_I_NO_ROWS_FOUND)
	  {
	    MEMclose (&list) ;
	    status = NFMget_transition_error () ;
	    ERRload_struct (NFM, status, NULL);
	    _NFMdebug ((fname, "No Transition Found : status <0x%.8x>\n",status));
	    return(status);
	  }

	status = MEMbuild_array (list) ;
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (&list) ;
	    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
			status)) ;
	    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	    return (NFM_E_MEM) ;
	  }

	data = (char **) list->data_ptr ;
	
	WFinfo.next_state = atol (data [0]) ;
	WFinfo.transition = atol (data [1]) ;
	strcpy(WFinfo.transition_name, data [2]);
	strcpy(WFinfo.logon_s, data[3]);
	strcpy(WFinfo.logon_f, data[4]);
	strcpy(WFinfo.notify, data [5]);
	strcpy (WFinfo.next_statename, data [6]) ;
	if (WFinfo.project_workflow_no < 1)
	  {
	    WFinfo.workflow = atol (data [7]) ;
	    WFinfo.project_workflow_no = WFinfo.workflow ;
	  }
	
	status = MEMclose (&list) ;
	if (status != MEM_S_SUCCESS)
	  {
	    _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
			status)) ;
	    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	    return (NFM_E_MEM) ;
	  }

/*
     	sprintf(sql_str,"SELECT b.n_userno FROM %s %s %d %s %d %s %d %s",
     	"nfmaccess a, nfmaclusers b ",
     	"WHERE a.n_transitionno = ",WFinfo.transition,
     	"AND b.n_userno = ", NFMglobal.NFMuserno,
     	"AND b.n_aclno = ", WFinfo.acl,
        "AND a.n_classno = b.n_classno");
*/
        status = SQLfix_qry_res_5 (NFMglobal.NFMuserno,WFinfo.transition,
				   WFinfo.acl,&userno1);
        if (status != SQL_S_SUCCESS)
	  {
	    
	    if (status == SQL_I_NO_ROWS_FOUND)
	      {
		status = NFM_E_USER_ACCESS_PRIV;
		ERRload_struct(NFM,status,"",NULL);
		_NFMdebug ((fname, "Privilege Violation : status = <0x%.8x>\n",
			    status));
		return (status);
	      }
	    
	    status = NFM_E_SQL_QUERY;
	    ERRload_struct(NFM,status,"",NULL);
	    _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
			status));
	    return (status);
	  }
      }
     else
     {
       _NFMdebug ((fname, "Project name was not given\n")) ;
       if (WFinfo.project_workflow_no < 1)
	 {
	   sprintf(sql_str,
		   "SELECT c.n_workflowno FROM \
nfmaccess a, nfmaclusers b, nfmacls c, nfmtransitions d WHERE \
b.n_userno = %d \
AND c.n_workflowno = (select n_workflowno from nfmworkflow where n_workflowname = 'NFM_PROJECT_WORKFLOW')  \
AND c.n_aclno = b.n_aclno \
AND a.n_classno = b.n_classno \
AND a.n_transitionno = d.n_transitionno \
AND d.n_commandno = %d",
		   NFMglobal.NFMuserno, WFinfo.command) ;
	 }
       else
	 {
	   sprintf(sql_str,
		   "SELECT b.n_userno \
FROM nfmaccess a, nfmaclusers b, nfmacls c, nfmtransitions d WHERE \
b.n_userno = %d \
AND c.n_workflowno = %d \
AND c.n_aclno = b.n_aclno \
AND a.n_classno = b.n_classno \
AND a.n_transitionno = d.n_transitionno \
AND d.n_commandno = %d",
		   NFMglobal.NFMuserno, WFinfo.workflow, WFinfo.command) ;
	 }

/*********** change *******
        status = SQLfix_qry_res_7(NFMglobal.NFMuserno,WFinfo.transition,
			       WFinfo.workflow,&userno1);
***************************/
       status = SQLquery (sql_str, &list, MEM_SIZE) ;
       if (status != SQL_S_SUCCESS)
	 {
	   MEMclose (&list);

	   if (status == SQL_I_NO_ROWS_FOUND)
          {
           status = NFM_E_USER_ACCESS_PRIV;
           ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Privilege Violation : status = <0x%.8x>\n",
           status));
           return (status);
          }
  
          status = NFM_E_SQL_QUERY;
	  ERRload_struct(NFM,status,"",NULL);
          _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
          status));
          return (status);
      }
       if (WFinfo.project_workflow_no <1)
	 {
	   status = MEMbuild_array (list) ;
	   if (status != MEM_S_SUCCESS)
	     {
	       MEMclose (&list) ;
	       _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
			   status)) ;
	       ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	       return (NFM_E_MEM) ;
	     }
	   
	   data = (char **) list->data_ptr ;
	   WFinfo.workflow = atol (data [0]) ;
	   WFinfo.project_workflow_no = WFinfo.workflow ;
	 }

       status = MEMclose (&list) ;
       if (status != MEM_S_SUCCESS)
	 {
	   _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
		       status)) ;
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	   return (NFM_E_MEM) ;
	 }
     }
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }

long _WFload_cat_proj_info()
{
  static char *fname = "_WFload_cat_proj_info" ;
  long	status, atol ();     
  
  _NFMdebug ((fname, "ENTER\n")) ;
  
  if(strlen(WFinfo.proj_name))
    {
      /*      GET PROJECT NO
	      sprintf(sql_str,"SELECT %s FROM nfmprojects WHERE %s '%s'",
	      "n_projectno ",
	      "n_projectname = ", WFinfo.proj_name);
	      status = SQLquery (sql_str, &list, 512);
	      */
      status = SQLfix_qry_res_11(WFinfo.proj_name,&(WFinfo.proj_no));
      if (status != SQL_S_SUCCESS)
	{
	  
	  if (status == SQL_I_NO_ROWS_FOUND)
            {
	      status = NFM_E_PROJ_NOT_IN_LOP;
	      ERRload_struct(NFM,status,"",NULL);
	      _NFMdebug ((fname, "Project not found : status = <0x%.8x>\n",
			  status));
	      return (status);
            }
	  
	  status = NFM_E_SQL_QUERY;
	  ERRload_struct(NFM,status,"",NULL);
	  _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		      status));
	  return (status);
	}
    }
  
  _NFMdebug ((fname, "table name is %s\n", WFinfo.catalog_name)) ;
  
  if(strlen(WFinfo.catalog_name))
    {
      /*      GET CATALOG NO
	      sprintf(sql_str,"SELECT %s FROM nfmcatalogs WHERE %s '%s'",
	      "n_catalogno ",
	      "n_catalogname = ", WFinfo.catalog_name);
	      status = SQLquery (sql_str, &list, 512);
	      */
      status = SQLfix_qry_res_12(WFinfo.catalog_name,&(WFinfo.catalog_no));
      if (status != SQL_S_SUCCESS)
	{
	  
	  if (status  == SQL_I_NO_ROWS_FOUND)
            {
	      status = NFM_E_CAT_NOT_IN_LOC;
	      ERRload_struct(NFM,status,"",NULL);
	      _NFMdebug ((fname, "Catalog not found : status = <0x%.8x>\n",
			  status));
	      return (status);
            }
	  
	  status = NFM_E_SQL_QUERY;
	  ERRload_struct(NFM,status,"",NULL);
	  _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		      status));
	  return (status);
	}
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

/** all structure reset ***/
_WFinit_wfinfo_login()
{
  char *fname = "_WFinit_wfinfo_login" ;

  _NFMdebug ((fname, "ENTER\n")) ;

     WFinfo.command_name[0] = 0;          WFinfo.command = -1;
     WFinfo.workflow_name [0] =0;         WFinfo.workflow = -1 ;
     WFinfo.acl_name [0] = 0;             WFinfo.acl = -1 ;
     WFinfo.transition_name [0] = 0;      WFinfo.transition = -1;
     WFinfo.current_statename [0] = 0 ;   WFinfo.curr_state = -1;    
     WFinfo.next_statename [0] = 0 ;      WFinfo.next_state = -1;
     WFinfo.proj_name [0] = 0 ;           WFinfo.proj_no = -1 ;
     WFinfo.catalog_name [0] = 0 ;        WFinfo.catalog_no = -1 ;
     WFinfo.item_name [0] = 0 ;           WFinfo.item_no = -1 ;
     WFinfo.item_rev [0] = 0 ;
     WFinfo.nfmcommand_name [0] = 0 ;     WFinfo.is_command_mapped = -1 ;

     WFinfo.logon_s[0] = 0;               WFinfo.logon_f[0] = 0;
     WFinfo.notify[0] = 0;
     WFinfo.catalog_workflow_no = -1 ;
     WFinfo.project_workflow_no = -1 ;
     WFinfo.sdp_workflow_no = -1 ;
     WFinfo.admin_workflow_no = -1;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
}

/** do not reset
   catalog_workflow_no, project_workflow_no, sdp_workflow_no, admin_workflow_no
**/

_WFinit_wfinfo()
{
     WFinfo.command_name[0] = 0;          WFinfo.command = -1;
     WFinfo.workflow_name [0] =0;         WFinfo.workflow = -1 ;
     WFinfo.acl_name [0] = 0;             WFinfo.acl = -1 ;
     WFinfo.transition_name [0] = 0;      WFinfo.transition = -1;
     WFinfo.current_statename [0] = 0 ;   WFinfo.curr_state = -1;    
     WFinfo.next_statename [0] = 0 ;      WFinfo.next_state = -1;
     WFinfo.proj_name [0] = 0 ;           WFinfo.proj_no = -1 ;
     WFinfo.catalog_name [0] = 0 ;        WFinfo.catalog_no = -1 ;
     WFinfo.item_name [0] = 0 ;           WFinfo.item_no = -1 ;
     WFinfo.item_rev [0] = 0 ;
     WFinfo.nfmcommand_name [0] = 0 ;     WFinfo.is_command_mapped = -1 ;

     WFinfo.logon_s[0] = 0;               WFinfo.logon_f[0] = 0;
     WFinfo.notify[0] = 0;
}

NFMprint_wfinfo ()
{
  static char *fname = "NFMprint_wfinfo" ;
  
  _NFMdebug ((fname, "command name <%s> : command no <%d> : \
workflow name <%s> : workflow no <%d> : \
acl name <%s> : acl no <%d> : \
transition name <%s> : transition no <%d> : \
current state name <%s> : current state no <%d> : \
next state name <%s> : next state no <%d> : \
project name <%s> : proj no <%d> \
catalog name <%s> : catalog no <%d> : \
item name <%s> : item rev <%s> : item no <%d> : \
nfm command name <%s> : if mapped  <%d> : \
logon successful  <%s> : logon failure <%s> : notify <%s> : \
caches : catalog_workflow <%d> : project_workflow <%d> : \
admin_workflow <%d> : sdp_workflow <%d>\n",
	      WFinfo.command_name, WFinfo.command,
	      WFinfo.workflow_name, WFinfo.workflow,
	      WFinfo.acl_name, WFinfo.acl,
	      WFinfo.transition_name, WFinfo.transition,
	      WFinfo.current_statename, WFinfo.curr_state,
	      WFinfo.next_statename, WFinfo.next_state,
	      WFinfo.proj_name, WFinfo.proj_no,
	      WFinfo.catalog_name, WFinfo.catalog_no,
	      WFinfo.item_name, WFinfo.item_rev, WFinfo.item_no,
	      WFinfo.nfmcommand_name, WFinfo.is_command_mapped,
	      WFinfo.logon_s, WFinfo.logon_f,  WFinfo.notify,
	      WFinfo.catalog_workflow_no, WFinfo.project_workflow_no,
	      WFinfo.admin_workflow_no, WFinfo.sdp_workflow_no)) ;
}



/*
        Command with entity = NFMITEM

	Validate using Database 
        Prepare queries using the workflow name provided 
        Currently the user may/may not select a workflow 
        And the Interface(s) may/may not send the workflow
        But if they do use it
  
        This will help in querying the n_transitionno and 
        n_tostate first .
*/

_WFitem_transition_validate(user_id)
long user_id ;
{
  static char *fname = "_WFitem_transition_validate" ;
  long	status, atol ();
  MEMptr 	list = NULL;
  char	**data;
  char	sql_str[512];
  char theItemName[512];  /* to check if ticked - PS */
  char theItemRevn[512];

  _NFMdebug ((fname, "ENTER\n")) ;
  user_id = user_id ;
  if ((strlen(WFinfo.catalog_name)) && (strlen (WFinfo.item_name)))
    {
/* load WFinfo.item_no : WFinfo.curr_state : WFinfo.current_statename : 
        WFinfo.acl  :  WFinfo.acl_name :  WFinfo.workflow :
        WFinfo.workflow_name 
 */
/* take care of the apostropes in the string - PS 4th Dec, 95 */
 
   NFMtic_to_tics(WFinfo.item_name, theItemName);
   NFMtic_to_tics(WFinfo.item_rev, theItemRevn);

      sprintf(sql_str,
	      "SELECT a.n_itemno, a.n_stateno, a.n_aclno, c.n_workflowno, c.n_workflowname, b.n_statename, d.n_aclname \
FROM %s a,NFMSTATES b, NFMWORKFLOW c, NFMACLS d \
WHERE a.n_itemname ='%s' AND a.n_itemrev='%s' AND \
a.n_stateno = b.n_stateno AND \
d.n_workflowno = c.n_workflowno AND \
a.n_aclno = d.n_aclno",
/* pass the ticked values to sql string - tmpPS
              WFinfo.catalog_name, WFinfo.item_name, WFinfo.item_rev) ;
*/
	      WFinfo.catalog_name, 
	      theItemName,
	      theItemRevn) ;
      
      status = SQLquery (sql_str, &list, MEM_SIZE) ;
      if (status != SQL_S_SUCCESS)
	{
	  MEMclose (&list);
	  if ((status ) == SQL_I_NO_ROWS_FOUND)
	    {
	      status = NFM_E_INVALID_ITEM;
	      ERRload_struct (NFM, status, "%s", WFinfo.item_name);
	      _NFMdebug ((fname, "State not found : status = <0x%.8x>\n",
			  status));
	      return (status);
	    }
	  
	  status = NFM_E_SQL_QUERY;
	  ERRload_struct(NFM,status,"",NULL);
	  _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		      status));
	  return (status);
	}
      
      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose(&list);
	  status = NFM_E_MEM;
	  ERRload_struct(NFM,status,"",NULL);
	  _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		      status));
	  return (status); 
	}

      data = (char **) list->data_ptr;
      WFinfo.item_no = atol(data[0]);	  
      WFinfo.curr_state = atol(data[1]);	  
      strcpy (WFinfo.current_statename, data [5]) ;
      WFinfo.acl = atol(data[2]);	  
      strcpy (WFinfo.acl_name, data [6]) ;
      WFinfo.workflow = atol(data[3]);	  
      strcpy(WFinfo.workflow_name,data[4]);	  
      MEMclose(&list); list = NULL;
    }
  else
    {
      _NFMdebug ((fname, "Bad item %s %s in catalog %s\n",
		  WFinfo.item_name, WFinfo.item_rev, WFinfo.catalog_name)) ;
      ERRload_struct (NFM, NFM_E_BAD_ITEM, "", "") ;
      return (NFM_E_BAD_ITEM) ;
    }
/****** load 
     WFinfo.transition  : WFinfo.transition_name :
     WFinfo.next_state  : WFinfo.next_statename :
     WFinfo.logon_s : WFinfo.logon_f : WFinfo.notify 
***********/

  
  sprintf(sql_str,"SELECT %s,%s, %s FROM %s WHERE %s %d %s %d %s %d) %s",
	  "a.n_transitionno,a.n_tostate",
	  "a.n_logonsuccess,a.n_logonfailure,a.n_notify,a.n_transitionname",
	  "b.n_statename",	     
	  "nfmtransitions a, nfmstates b",
	  "a.n_commandno = ", WFinfo.command,
	  "AND a.n_workflowno = ", WFinfo.workflow,
	  "AND (a.n_fromstate = 0 OR a.n_fromstate = 1 OR a.n_fromstate = ",
	  WFinfo.curr_state,
	  "AND a.n_tostate = b.n_stateno");
  
  status = SQLquery (sql_str, &list, MEM_SIZE) ;
  
  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list);
      if ((status ) == SQL_I_NO_ROWS_FOUND)
	{
	  status = NFMget_transition_error () ;
	  ERRload_struct (NFM, status, NULL);
	  _NFMdebug ((fname, "No Transition Found : status = <0x%.8x>\
n",
		      status));
	  return (status);
	}
      status = NFM_E_SQL_QUERY;
      ERRload_struct(NFM,status,"",NULL);
      _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		  status));
      return (status);
    }
  
  
  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose(&list);
      status = NFM_E_MEM;
      ERRload_struct(NFM,status,"",NULL);
      _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		  status));
      return (status);
    }
  
  if(list->rows != 1) 
    {
      MEMclose(&list);
      ERRload_struct(NFM, NFM_E_MULTIPLE_TRANSITIONS,"",NULL);
      _NFMdebug ((fname, "Multiple Transitions\n")) ;
      return(NFM_E_MULTIPLE_TRANSITIONS) ;
    }
  
  data = (char **) list->data_ptr;
  WFinfo.transition = atol(data[0]);
  strcpy(WFinfo.transition_name,data[5]);
  WFinfo.next_state = atol(data[1]);
  strcpy (WFinfo.next_statename, data [6]) ;
  strcpy(WFinfo.logon_s,data[2]);
  strcpy(WFinfo.logon_f,data[3]);
  strcpy(WFinfo.notify,data[4]);
  
  status = MEMclose(&list);
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose (list) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);     
}


_WFitem_user_acl_validate (user_id) 
long user_id ;
{
  static char *fname = "_WFitem_user_acl_validate" ;
  long userno1, status ;
  
  _NFMdebug ((fname, "ENTER\n")) ;
  user_id = user_id ;
/*
     sprintf(sql_str,
     "SELECT b.n_userno FROM %s %s %d %s %d %s %d %s",
     "nfmaccess a, nfmaclusers b ",
     "WHERE a.n_transitionno = ",WFinfo.transition,
     "AND b.n_userno = ", NFMglobal.NFMuserno,
     "AND b.n_aclno = ", WFinfo.acl,
     "AND a.n_classno = b.n_classno");
     status = SQLquery (sql_str, &list, 512);
      MEMclose(&list); list = NULL;
*/
     status = SQLfix_qry_res_5(NFMglobal.NFMuserno,WFinfo.transition,
			       WFinfo.acl,&userno1);
     if (status != SQL_S_SUCCESS)
      {

        if (status  == SQL_I_NO_ROWS_FOUND)
         {
           status = NFM_E_USER_ACCESS_PRIV;
    	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Privilege Violation : status = <0x%.8x>\n",
           status));
           return (status);
         }

        status = NFM_E_SQL_QUERY;
	 ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
        status));
        return (status);
      }
  return (NFM_S_SUCCESS) ;
}


/*
        Command with entity = NFMITEM

	Validate using Database 
*/

long  _WFitem_any_wf_acl_validate (user_id)
long	user_id;
{
     static char *fname = "_WFitem_any_workflow_validate" ;
     long	status;
     MEMptr 	list = NULL;
     long	userno1;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
      /*
 	   sprintf(sql_str,
  	   "SELECT b.n_userno,%s FROM %s %s %d %s %d %s %d) %s %s %s %s",
	   "d.n_logonsuccess,d.n_logonfailure,d.n_notify,d.n_transitionname",
   	   "nfmaccess a, nfmaclusers b, nfmacls c, nfmtransitions d",
           "WHERE d.n_commandno = ", WFinfo.command,
           "AND b.n_userno = ", NFMglobal.NFMuserno,
           "AND (n_fromstate = 0 or n_fromstate = 1 or n_fromstate = ",
            WFinfo.curr_state,
           "AND a.n_transitionno = d.n_transitionno ",
           "AND c.n_workflowno = d.n_workflowno ",
           "AND c.n_aclno = b.n_aclno ",
           "AND a.n_classno = b.n_classno");
     status = SQLquery (sql_str, &list, 512);
 */
     status = SQLfix_qry_res_6(WFinfo.command,NFMglobal.NFMuserno,
			       WFinfo.curr_state,&userno1,
			       WFinfo.logon_s,WFinfo.logon_f,
			       WFinfo.notify,WFinfo.transition_name);
     if (status != SQL_S_SUCCESS)
     {
         MEMclose (&list);
         if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
           status = NFM_E_USER_ACCESS_PRIV;
	 ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Privilege Violation : status = <0x%.8x>\n",
           status));
           return (status);
         }

         status = NFM_E_SQL_QUERY;
	 ERRload_struct(NFM,status,"",NULL);
         _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
          status));
          return (status);
     }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);     
}
long  _WFnoentity_validate(user_id)
long	user_id;
{
  char *fname = "_WFnoentity_validate" ;
     long	status;
     MEMptr 	list = NULL;
     long	userno1;

  _NFMdebug ((fname, "ENTER\n")) ;
  user_id = user_id ;
     list = NULL;
/*
     sprintf(sql_str,
     "SELECT b.n_userno,%s FROM %s %s %d %s %d %s %s %s %s",
     "d.n_logonsuccess,d.n_logonfailure,d.n_notify,d.n_transitionname",
     "nfmaccess a, nfmaclusers b, nfmacls c, nfmtransitions d",
     "WHERE d.n_commandno = ", WFinfo.command,
     "AND b.n_userno = ", NFMglobal.NFMuserno,
     "AND a.n_transitionno = d.n_transitionno ",
     "AND c.n_workflowno = d.n_workflowno ",
     "AND c.n_aclno = b.n_aclno ",
     "AND a.n_classno = b.n_classno");
     status = SQLquery (sql_str, &list, 512);
*/
     status = SQLfix_qry_res_8(WFinfo.command,NFMglobal.NFMuserno,&userno1,
			       WFinfo.logon_s,WFinfo.logon_f,
			       WFinfo.notify,WFinfo.transition_name);
     if (status != SQL_S_SUCCESS)
     {
         MEMclose (&list);
         if (status  == SQL_I_NO_ROWS_FOUND)
         {
           status = NFM_E_USER_ACCESS_PRIV;
	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Privilege Violation : status = <0x%.8x>\n",
           status));
           return (status);
         }

         status = NFM_E_SQL_QUERY;
	 ERRload_struct(NFM,status,"",NULL);
         _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
          status));
          return (status);
     }
/*
     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
     {
     	MEMclose(&list);
  	status = NFM_E_MEM;
	 ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
      	status));
      	return (status); 
     }
     data = (char **) list->data_ptr;
     strcpy(WFinfo.logon_s,data[1]);
     strcpy(WFinfo.logon_f,data[2]);
     strcpy(WFinfo.notify,data[3]);
     strcpy(WFinfo.transition_name,data[4]);
     MEMclose(&list); list = NULL;
*/
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
}


long NFMget_transition_error ()
{
  char *fname = "NFMget_transition_error" ;
  long status ;

  _NFMdebug ((fname, "ENTER\n")) ;
  status = NFM_E_NO_TRANSITIONS ;  

  if (strcmp (WFinfo.command_name, SIGNOFF_ITEM) == 0)
    status = NFM_E_BAD_SIGNOFF;  /* TR#91W4014 B.W. 6/13/91 */
  if (strcmp (WFinfo.entity, "P") == 0)
    {
/* if project is mapped completely (both acl and sa) return NFM_S_SUCCESS else
   return NFM_E_PROJ_NOT_MAPPED */
      status = _NFMcheck_project_complete_mapping (WFinfo.proj_no) ;
    }

  _NFMdebug ((fname, "Returning 0x%.8x\n", status)) ;
  return (status) ;
}
