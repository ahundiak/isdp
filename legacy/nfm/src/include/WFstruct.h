#include "NFMschema.h"

 struct WFstruct
  {
    char    entity[NFM_ENTITY+1] ;
    char    command_name[NFM_COMMANDNAME+1] ;
    long    command;
    char    workflow_name [NFM_WORKFLOWNAME+1];
    long    workflow;
    char    acl_name [NFM_ACLNAME+1] ;
    long    acl;
    char    transition_name [NFM_TRANSITIONNAME+1];
    long    transition;
    char    current_statename[NFM_STATENAME+1] ;
    long    curr_state;
    char    next_statename[NFM_STATENAME+1] ;
    long    next_state;
    char    proj_name [NFM_PROJECTNAME+1] ;
    long    proj_no;
    char    catalog_name [NFM_CATALOGNAME+1] ;
    long    catalog_no;
    char    item_name [NFM_ITEMNAME+1] ;
    char    item_rev [NFM_ITEMREV+1] ;
    long    item_no;
    char    logon_s[NFM_LOGONSUCCESS+1];
    char    logon_f[NFM_LOGONFAILURE+1];
    char    notify[NFM_NOTIFY+1];

    long    is_command_mapped ;
    char    nfmcommand_name [NFM_COMMANDNAME+1] ;
 
    long    catalog_workflow_no ;
    long    project_workflow_no ;
    long    sdp_workflow_no ;
    long    admin_workflow_no ;
  };

