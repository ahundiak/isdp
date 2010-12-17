#include "machine.h"
#include "WF.h"

 extern struct WFstruct WFinfo;

 long WFcopy_workflow_structure (user_id, type, wf_str)
   long              user_id;
   long              type;
   struct WFstruct   *wf_str;
   {
     char *fname = "WFcopy_workflow_structure" ;

     _NFMdebug ((fname, "Type    = <%d>\n", type   ));
     user_id=user_id ;
     if (type == 0)
      {
	strcpy (wf_str -> entity, WFinfo.entity) ;
	strcpy (wf_str -> command_name, WFinfo.command_name) ;
	wf_str ->command = WFinfo.command ;
	strcpy (wf_str -> workflow_name, WFinfo.workflow_name) ;
	wf_str -> workflow = WFinfo.workflow ;
	strcpy (wf_str -> acl_name, WFinfo.acl_name) ;
	wf_str -> acl = WFinfo.acl ;
	strcpy (wf_str ->transition_name, WFinfo.transition_name) ;
	wf_str -> transition = WFinfo.transition ;
	strcpy (wf_str -> current_statename, WFinfo.current_statename) ;
	wf_str -> curr_state = WFinfo.curr_state ;
	strcpy (wf_str -> next_statename, WFinfo.next_statename) ;
	wf_str -> next_state = WFinfo.next_state ;
	strcpy (wf_str -> proj_name, WFinfo.proj_name) ;
	wf_str -> proj_no = WFinfo.proj_no ;
	strcpy (wf_str -> catalog_name, WFinfo.catalog_name) ;
	wf_str -> catalog_no = WFinfo.catalog_no ;
	strcpy (wf_str -> item_name, WFinfo.item_name) ;
	strcpy (wf_str -> item_rev, WFinfo.item_rev) ;
	wf_str -> item_no = WFinfo.item_no ;
	strcpy (wf_str -> logon_s, WFinfo.logon_s) ;
	strcpy (wf_str -> logon_f, WFinfo.logon_f) ;
	strcpy (wf_str -> notify, WFinfo.notify) ;
	wf_str -> is_command_mapped = WFinfo.is_command_mapped ;
	strcpy (wf_str -> nfmcommand_name, WFinfo.nfmcommand_name) ;
	wf_str -> catalog_workflow_no  = WFinfo.catalog_workflow_no ;
	wf_str -> project_workflow_no = WFinfo.project_workflow_no ;
	wf_str ->admin_workflow_no  = WFinfo.admin_workflow_no ;
	wf_str ->sdp_workflow_no  = WFinfo.sdp_workflow_no ;
      }
     else
      {
	strcpy (WFinfo.entity, wf_str -> entity) ;
	strcpy (WFinfo.command_name, wf_str -> command_name) ;
	WFinfo.command = wf_str -> command ;
	strcpy (WFinfo.workflow_name, wf_str ->workflow_name) ;
	WFinfo.workflow = wf_str -> workflow ;
	strcpy (WFinfo.acl_name, wf_str -> acl_name) ;
	WFinfo.acl = wf_str ->acl ;
	strcpy (WFinfo.transition_name, wf_str -> transition_name) ;
	WFinfo.transition = wf_str -> transition ;
	strcpy (WFinfo.current_statename, wf_str ->current_statename) ;
	WFinfo.curr_state = wf_str -> curr_state ;
	strcpy (WFinfo.next_statename, wf_str -> next_statename) ;
	WFinfo.next_state = wf_str -> next_state ;
	strcpy (WFinfo.proj_name, wf_str -> proj_name) ;
	WFinfo.proj_no = wf_str -> proj_no ;
	strcpy (WFinfo.catalog_name, wf_str -> catalog_name) ;
	WFinfo.catalog_no = wf_str ->catalog_no ;
	strcpy (WFinfo.item_name, wf_str -> item_name) ;
	strcpy (WFinfo.item_rev, wf_str->item_rev) ;
	WFinfo.item_no = wf_str ->item_no ;
	strcpy (WFinfo.logon_s, wf_str->logon_s) ;
	strcpy (WFinfo.logon_f, wf_str->logon_f) ;
	strcpy (WFinfo.notify, wf_str->notify) ;
	WFinfo.is_command_mapped = wf_str ->is_command_mapped ;
	strcpy (WFinfo.nfmcommand_name, wf_str -> nfmcommand_name) ;
	WFinfo.catalog_workflow_no  = wf_str -> catalog_workflow_no ;
	WFinfo.project_workflow_no = wf_str -> project_workflow_no ;
	WFinfo.admin_workflow_no  = wf_str ->admin_workflow_no ;
	WFinfo.sdp_workflow_no  = wf_str ->sdp_workflow_no ;
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
