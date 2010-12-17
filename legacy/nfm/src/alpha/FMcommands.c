#include "machine.h"
#include "NFMdef.h"
#include "NFMRextern.h"
#include "WFcommands.h"
#include "SCdef.h"
#include "SCdata.h"
#include "SCstruct.h"

extern struct _ERRstruct _ERRstruct;
extern char SCexec[30];
extern char SCuser_cmd_file[150];
extern char SCadmin_cmd_file[150];

NFMfunction nfm_server_debug_on ()
{
long status;
    
    status = server_debug_on ();
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}

NFMfunction nfm_server_debug_off ()
{
long status;
    
    status = server_debug_off ();
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}

NFMfunction nfm_client_debug_on ()
{
long status= NFM_S_SUCCESS;

#ifndef COMBINED_CLIENT_SERVER    
    status = client_debug_on ();
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
#else
    status = client_combined_debug_on ();
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();        
#endif

return (status);
}

NFMfunction nfm_client_debug_off ()
{
long status= NFM_S_SUCCESS;
    
#ifndef COMBINED_CLIENT_SERVER    
    status = client_debug_off ();
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
#else
    status = client_combined_debug_off();
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
#endif
        
return (status);
}

NFMfunction nfm_print_file ()
{
long status;
    
    status = print_file();
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}

NFMfunction nfm_catalog ()
{
long status;
    
    status = catalog ();
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}

NFAalpha_validate_user_access (user_id, command, workflow, project, catalog,
                               item, revision)
    long    user_id;       /* i - user id for access */
    char    *command;      /* i - command name */
    char    *workflow;     /* i - the valid workflow */
    char    *project;
    char    *catalog;
    char    *item;
    char    *revision;
    
{
    long status;

    SCdisplay_msg ("Working.");

    status = NFMRvalidate_user_access (user_id, command, workflow, project,
                                       catalog, item, revision);
    if (status != NFM_S_SUCCESS)
    {
	NFAset_message();
	SCdisplay_msg( msg );
	ERRreset_struct();
        return (status);
    }
    return( NFI_S_SUCCESS );    
}


NFAalpha_set_to_state ( error_number, error_message )
    long error_number;
    char *error_message;    
{
long status;

    status = NFMRset_wf_state ( "NFM", error_number, error_message );
    if (status != NFM_S_SUCCESS)
    {
	NFAset_message();
	SCdisplay_msg( msg );
	ERRreset_struct();
	return( status );
    }

    ERRreset_struct();
    return (NFI_S_SUCCESS);
        
}


NFMfunction nfm_add_node ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_NODE";
        
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_NODE,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_node ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_delete_node ()
{
long status;
long err_no;
int  subsystem;

static char *fname = "NFA_DELETE_NODE";

    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_NODE,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );

    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_node ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_change_node ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CHANGE_NODE";

    status = NFAactivate_node ();

    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, CHANGE_NODE,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = change_node ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_display_nodes ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_NODES";
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_NODES,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_nodes ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_add_sa ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_SA";
        
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_SA,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_sa ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_delete_storage_area ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_SA";

    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_SA,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_storage_area ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_change_sa ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CHANGE_SA";

    status = NFAactivate_sa ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, CHANGE_SA,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = change_sa ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_change_sa_passwd ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CHANGE_SA_PASSWD";

    status = NFAalpha_validate_user_access (NFMuser_id, CHG_SA_PASSWD,
		NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );

    if (status != NFI_S_SUCCESS)
        return (status);


    status = NFAactivate_sa ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = change_sa_passwd ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_change_wa_passwd ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CHANGE_WA_PASSWD";

    status = NFAalpha_validate_user_access(NFMuser_id, CHANGE_WORKING_AREA_PWD,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = NFAactivate_wa ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = change_wa_passwd ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_add_user ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_USER";
        
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_USER,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_user ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_delete_user ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_USER";
        
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_USER,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_user ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

        
return (status);
}

NFMfunction nfm_change_user ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CHANGE_USER";

    status = NFAalpha_validate_user_access (NFMuser_id, CHANGE_USER,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = NFAactivate_user ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = change_user ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_change_user_passwd ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CHANGE_USER_PASSWD";
 
    status = NFAalpha_validate_user_access (NFMuser_id, CHG_USER_PASSWD,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = NFAactivate_user ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = change_user_passwd ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_change_self_passwd ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CHANGE_SELF_PASSWD";
        
    status = NFAalpha_validate_user_access (NFMuser_id, CHANGE_PASSWD,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = change_self_passwd ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_define_active_data ()
{
long status;
static char *fname = "NFA_DEFINE_ACTIVE_DATA";

    status = define_active_data ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}


NFMfunction nfm_add_project ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_PROJECT";
        
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_PROJECT,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_project ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_delete_project ()
{
long status;
long err_no;
int  subsystem;

static char *fname = "NFA_DELETE_PROJECT";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_PROJECT,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_project ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_change_project ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CHANGE_PROJECT";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, CHANGE_PROJECT,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = change_project ();

    _NFIdebug((fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_add_project_acl_map ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_CAT_ACL_MAP";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_CAT_ACL_PROJ_MAP,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_project_acl_map ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_delete_project_acl_map ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_CAT_ACL_PROJ_MAP";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access(NFMuser_id,DELETE_CAT_ACL_PROJ_MAP,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_project_acl_map ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_add_project_sa_map ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_CAT_SA_PROJ_MAP";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_CAT_SA_PROJ_MAP,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_project_sa_map ();
/*
    if (status != NFI_S_SUCCESS)
       return (status);
*/
    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_delete_project_sa_map ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_CAT_SA_PROJ_MAP";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_CAT_SA_PROJ_MAP,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_project_sa_map ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_display_project_members ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_PROJECT_ITEMS";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_PROJECT_ITEMS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_project_members ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_add_project_members ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DEFINE_PROJECT_MEMBERS";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_ITEMS_TO_PROJECT,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_project_members ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_delete_project_members ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DEFINE_PROJECT_MEMBERS";
        
   status = NFAalpha_validate_user_access(NFMuser_id,DELETE_ITEMS_FROM_PROJECT,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_project_members ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_create_catalog ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CREATE_CATALOG";
        
    status = NFAalpha_validate_user_access (NFMuser_id, CREATE_CATALOG,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = create_catalog ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_change_catalog ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CHANGE_CATALOG";

    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, CHANGE_CATALOG,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = change_catalog ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_delete_catalog ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_CATALOG";

    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_CATALOG,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_catalog ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_add_catalog_acl_map ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_CAT_ACL_MAP";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_CAT_ACL_MAP,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_catalog_acl_map ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_delete_catalog_acl_map ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_CAT_ACL_MAP";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_CAT_ACL_MAP,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_catalog_acl_map ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_add_catalog_sa_map ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_CAT_SA_MAP";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_CAT_SA_MAP,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_catalog_sa_map ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_delete_catalog_sa_map ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_CAT_SA_MAP";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_CAT_SA_MAP,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_catalog_sa_map ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_add_item ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_ITEM";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_ITEM,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_item ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_add_files_to_item ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_FILES_TO_ITEM";

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
   
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_FILES_TO_ITEM,
                "", "", NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_files_to_item ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        

return (status);
}

NFMfunction nfm_delete_files_from_item ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_FILES_FROM_ITEM";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_FILES_FROM_ITEM,
                "", "", NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

     status = delete_files_from_item ();

     _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

     NFAset_message();
     SCdisplay_msg( msg );

    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

     return (status);
}

NFMfunction nfm_change_file_attributes ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CHANGE_FILE_ATTRIBUTES";

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
   
    status = NFAalpha_validate_user_access (NFMuser_id, CHANGE_FILE_ATTRIBUTES,
                "", "", NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = change_file_attributes ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_where_used_set ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_WHERE_USED_SET";
      
/*    status = NFAactivate_set ();

    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
  */      

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_WHERE_USED_SET,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
          return (status);

    status = display_where_used_set ();
 
     _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_display_where_used_project ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_WHERE_USED_PROJECT";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access(NFMuser_id, LIST_WHERE_USED_PROJECT,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_where_used_project ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_update_item ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_UPDATE_ITEM";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, CHANGE_ITEM,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = update_item ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

        
return (status);
}


NFMfunction nfm_delete_item ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_ITEM";

    if( NFMlist_driven )
    {   
	status = delete_item_from_list();
    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
	return( status );
    }

    if (strcmp( NFMitem, "") == 0)
     {
       status = NFAactivate_item ();
       if (status != NFI_S_SUCCESS)
        {
           NFAset_message();
           SCdisplay_msg( msg );
           ERRreset_struct();
           return (status);
         }          
      }

    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_ITEM,
                 NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);
/*
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
*/
    status = delete_item ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
          
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_lock_item ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_LOCK_ITEM";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, LOCK_ITEM,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = lock_item ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_unlock_item ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_UNLOCK_ITEM";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, UNLOCK_ITEM,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = unlock_item ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_purge_item_versions ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_PURGE_ITEM_VERSIONS";


    status = NFAalpha_validate_user_access (NFMuser_id, PURGE_FILE_VERSIONS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = purge_versions ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_roll_version_forward ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ROLL_VERSION_FORWARD";
  
    status = NFAalpha_validate_user_access (NFMuser_id, ROLL_FILE_VERSION_FWD,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = roll_version_forward ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_change_item_workflow ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CHANGE_ITEM_WORKFLOW";
        
    if( NFMlist_driven )
    {
	status = change_item_workflow_from_list();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
         
    status = NFAalpha_validate_user_access (NFMuser_id, CHANGE_WF_OF_ITEM,
                 NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = change_item_workflow ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

        
return (status);
}


NFMfunction nfm_display_set_members ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_SET_MEMBERS";

    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access(NFMuser_id,LIST_SET_MEMBERS,
                NFMworkflow, NFMproject, NFMcatalog, NFMset, NFMset_rev );
    if (status != NFI_S_SUCCESS)
        return (status);
    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    status = display_set_members ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_display_sets ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_SETS";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access(NFMuser_id,LIST_ITEMS,
                NFMworkflow, NFMproject, NFMcatalog, NFMset, NFMset_rev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_sets ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_add_set_item ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_SET_ITEM";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_ITEM,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_set_item ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_checkin_item ()
{
long status;
static char *fname = "NFA_CHECKIN_ITEM";

    if( strcmp( NFMworking, "" ) == 0 )
    {
        status = NFAactivate_wa ();
        if (status != NFI_S_SUCCESS)
        {
            NFAset_message();
            SCdisplay_msg( msg );
            ERRreset_struct();
            return (status);
        }
    }

    if( NFMlist_driven )
    {
	status = checkin_item_from_list();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );   
        ERRreset_struct();  
        return (status);
    }

    status = checkin_item ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}

NFMfunction nfm_checkout_item ()
{
long status;
static char *fname = "NFA_CHECKOUT_ITEM";

    if( strcmp( NFMworking, "" ) == 0 )
    {
        status = NFAactivate_wa ();
        if (status != NFI_S_SUCCESS)
        {
            NFAset_message();
            SCdisplay_msg( msg );
            ERRreset_struct();
            return (status);
        }
    }

    if( NFMlist_driven )
    {
	status = checkout_item_from_list();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
    
    status = checkout_item ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}

NFMfunction nfm_copy_item ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_COPY_ITEM";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

        
    status = NFAalpha_validate_user_access (NFMuser_id, COPY_ITEM,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = copy_item ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

/*
NFMfunction nfm_copy_set ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_COPY_set";
        
    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

        
    status = NFAalpha_validate_user_access (NFMuser_id, COPY_SET,
                NFMworkflow, NFMproject, NFMcatalog, NFMset, NFMset_rev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = copy_set ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}
*/

NFMfunction nfm_copy_item_files ()
{
long status;
static char *fname = "NFA_COPY_ITEM_FILES";
     
    if( strcmp( NFMworking, "" ) == 0 )
    {
        status = NFAactivate_wa ();
        if (status != NFI_S_SUCCESS)
        {
            NFAset_message();
            SCdisplay_msg( msg );
            ERRreset_struct();
            return (status);
        }
    }
   
    if( NFMlist_driven )
    {
  	status = copy_item_files_from_list();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
    
    status = copy_item_files();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}

NFMfunction nfm_save_item_files ()
{
long status;
static char *fname = "NFA_SAVE_ITEM_FILES";
 
        
    if( NFMlist_driven )
    {
	status = save_item_files_from_list();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }
    
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, SAVE_ITEM_FILES,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);
    
    status = save_item_files();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}

NFMfunction nfm_save_set_files ()
{
long status;
static char *fname = "NFA_SAVE_SET_FILES";
     
        
    if( NFMlist_driven )
    {
	status = save_set_files_from_list();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));	
        NFAset_message();
	SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
    
    status = NFAalpha_validate_user_access (NFMuser_id, SAVE_SET_FILES,
                NFMworkflow, NFMproject, NFMcatalog, NFMset, NFMset_rev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = save_set_files();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}

NFMfunction nfm_delete_copied_files ()
{
int  subsystem;
long status;
long err_no;
static char *fname = "NFA_DELETE_COPIED_FILES";
        
    if( strcmp( NFMworking, "" ) == 0 )
    {
        status = NFAactivate_wa ();
        if (status != NFI_S_SUCCESS)
        {
            NFAset_message();
            SCdisplay_msg( msg );
            ERRreset_struct();
            return (status);
        }
    }
/*
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
  */      
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_COPIED_FILES,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);
   
    status = delete_copied_files ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_cancel_item_checkout ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CANCEL_ITEM_CHECKOUT";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
   
    status = cancel_checkout_item ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_add_members ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_MEMBERS";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    if( strcmp( NFMset, "" ) != 0 )
        status = NFAalpha_validate_user_access (NFMuser_id, ADD_ITEMS_TO_SET,
                NFMworkflow, NFMproject, NFMcatalog, NFMset, NFMset_rev );
    else
        status = NFAalpha_validate_user_access (NFMuser_id, ADD_ITEMS_TO_SET,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
  
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_members ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_delete_members ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_MEMBERS";
        
    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id,DELETE_ITEMS_FROM_SET,
                NFMworkflow, NFMproject, NFMcatalog, NFMset, NFMset_rev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_members ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_display_archive_flags ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_ARCHIVE_FLAGS";
        
    status = NFAalpha_validate_user_access (NFMuser_id, ARCHIVE_LIST,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_archive_flags ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_archive ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ARCHIVE";
 
    status = NFAalpha_validate_user_access (NFMuser_id, ARCHIVE,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = create_archive ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_display_backup_flags ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_BACKUP_FLAGS";
        
    status = NFAalpha_validate_user_access (NFMuser_id, BACKUP_LIST,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_backup_flags ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_backup ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_BACKUP";

    status = NFAalpha_validate_user_access (NFMuser_id, BACKUP,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = create_backup ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_display_restore_flags ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_RESTORE_FLAGS";
        
    status = NFAalpha_validate_user_access (NFMuser_id, RESTORE_LIST,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_restore_flags ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_restore ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_RESTORE";

    status = NFAalpha_validate_user_access (NFMuser_id, RESTORE,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = create_restore ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_display_delete_flags ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_DELETE_FLAGS";
        
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_LIST,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_delete_flags ();

    _NFIdebug(( fname, "status  -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_delete ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE";
 
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = create_delete ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_delete_savesets ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_SAVESETS";

    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_SAVESET,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_savesets ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_delete_archives ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_ARCHIVES";
/*
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_ARCHIVE,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);
*/

    status = delete_archives ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_saveset_entries ()
{
long status;
static char *fname = "NFA_DISPLAY_SAVESET_ENTRIES";

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_SAVESETS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_saveset_entries ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}

NFMfunction nfm_display_items_on_tape ()
{
long status;

static char *fname = "NFA_DISPLAY_ITEMS_ON_TAPE";

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_ITEMS_ON_TAPE,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_items_on_tape ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}


NFMfunction nfm_check_set_in ()
{
long status;
static char *fname = "NFA_CHECK_SET_IN";
     
    if( strcmp( NFMworking, "" ) == 0 )
    {
        status = NFAactivate_wa ();
        if (status != NFI_S_SUCCESS)
        {
            NFAset_message();
            SCdisplay_msg( msg );
            ERRreset_struct();
            return (status);
        }
    }

    if( NFMlist_driven )
    {
	status = check_set_in_from_list();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
         
    status = check_set_in ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}

NFMfunction nfm_check_set_out ()
{
long status;
static char *fname = "NFA_CHECK_SET_OUT";
        
    if( strcmp( NFMworking, "" ) == 0 )
    {
        status = NFAactivate_wa ();
        if (status != NFI_S_SUCCESS)
        {
            NFAset_message();
            SCdisplay_msg( msg );
            ERRreset_struct();
            return (status);
        }
    }

    if( NFMlist_driven )
    {
	status = check_set_out_from_list();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
     }

     status = check_set_out ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}

NFMfunction nfm_copy_set_item_files ()
{
long status;
static char *fname = "NFA_COPY_SET_ITEM_FILES";
        
    if( strcmp( NFMworking, "" ) == 0 )
    {
        status = NFAactivate_wa ();
        if (status != NFI_S_SUCCESS)
        {
            NFAset_message();
            SCdisplay_msg( msg );
            ERRreset_struct();
            return (status);
        }
    }

    if( NFMlist_driven )
    {
        status = copy_set_item_files_from_list ();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status); 
    }

    status = copy_set_item_files ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}


NFMfunction nfm_cancel_checkout_set ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CANCEL_CHECKOUT_SET";
        
    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = cancel_checkout_set ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_flag_item_archive ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_FLAG_ITEM_ARCHIVE";
 
    if( NFMlist_driven )
    {
    	status = flag_item_archive_from_list();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, FLAG_ITEM_ARCHIVE,
                 NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = flag_item_archive ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_flag_item_backup ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_FLAG_ITEM_BACKUP";

    if( NFMlist_driven )
    {
 	   status = flag_item_backup_from_list();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
	
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {  
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, FLAG_ITEM_BACKUP,
                 NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = flag_item_backup ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_flag_item_restore ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_FLAG_ITEM_RESTORE";

 if( NFMlist_driven )
    {
      status = flag_item_restore_from_list();
    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
    return( status );
    }

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
 
    status = NFAalpha_validate_user_access (NFMuser_id, FLAG_ITEM_RESTORE,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = flag_item_restore ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_flag_item_delete ()
{
long   status;
long   err_no;
int    subsystem;

static char *fname = "NFA_FLAG_ITEM_DELETE";
 
    if( NFMlist_driven )
    {
    	status = flag_item_delete_from_list();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, FLAG_ITEM_DELETE,
                 NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );

    if (status != NFI_S_SUCCESS)
        return (status);        

    status = flag_item_delete ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );

    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_cancel_item_archive_flag ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CANCEL_ITEM_ARCHIVE_FLAG";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access(NFMuser_id,CANCEL_ITEM_ARCHIVE_FLAG,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

        status = cancel_item_archive_flag ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_cancel_item_backup_flag ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CANCEL_ITEM_BACKUP_FLAG";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id,CANCEL_ITEM_BACKUP_FLAG,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

        status = cancel_item_backup_flag ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_cancel_item_restore_flag ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CANCEL_ITEM_RESTORE_FLAG";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access(NFMuser_id,CANCEL_ITEM_RESTORE_FLAG,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);
 
        status = cancel_item_restore_flag ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_cancel_item_delete_flag ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CANCEL_ITEM_DELETE_FLAG";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access(NFMuser_id,CANCEL_ITEM_DELETE_FLAG,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = cancel_item_delete_flag ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_flag_set_archive ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_FLAG_SET_ARCHIVE";

    if( NFMlist_driven )
    {
    	status = flag_set_archive_from_list();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct(); 
        return (status);
    }
           
    status = NFAalpha_validate_user_access (NFMuser_id, FLAG_SET_ARCHIVE,
                NFMworkflow, NFMproject, NFMcatalog, NFMset, NFMset_rev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = flag_set_archive ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_flag_set_backup ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_FLAG_SET_BACKUP";
        
    if( NFMlist_driven )
    {
        status = flag_set_backup_from_list ();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, FLAG_SET_BACKUP,
                NFMworkflow, NFMproject, NFMcatalog, NFMset, NFMset_rev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = flag_set_backup ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_flag_set_restore ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_FLAG_SET_RESTORE";
        
    if( NFMlist_driven )
    {
    	status = flag_set_restore_from_list ();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, FLAG_SET_RESTORE,
                 NFMworkflow, NFMproject, NFMcatalog, NFMset, NFMset_rev );
        if (status != NFI_S_SUCCESS)
            return (status);

    status = flag_set_restore ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_cancel_set_archive_flag ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CANCEL_SET_ARCHIVE_FLAG";
        
    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, 
	CANCEL_SET_ARCHIVE_FLAG, NFMworkflow, NFMproject, NFMcatalog, 
	NFMset, NFMset_rev);
    if (status != NFI_S_SUCCESS)
        return (status);

    status = cancel_set_archive_flag ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_cancel_set_backup_flag ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CANCEL_SET_BACKUP_FLAG";
        
    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, 
	CANCEL_SET_BACKUP_FLAG, NFMworkflow, NFMproject, NFMcatalog, 
	NFMset, NFMset_rev);
    if (status != NFI_S_SUCCESS)
        return (status);

    status = cancel_set_backup_flag ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_cancel_set_restore_flag ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CANCEL_SET_RESTORE_FLAG";
        
    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, 
	CANCEL_SET_RESTORE_FLAG, NFMworkflow, NFMproject, NFMcatalog, 
	NFMset, NFMset_rev);
    if (status != NFI_S_SUCCESS)
        return (status);

    status = cancel_set_restore_flag ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_flag_project_archive ()
{
int  subsystem;
long status;
long err_no;
static char *fname = "NFA_FLAG_PROJECT_ARCHIVE";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, 
	FLAG_PROJ_FILES_ARCHIVE, NFMworkflow,NFMproject, NFMcatalog, 
	NFMitem, NFMrev );

    if (status != NFI_S_SUCCESS)
        return (status);

    status = flag_project_archive ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );
    NFAalpha_set_to_state ( err_no, msg );
    ERRreset_struct();

return (status);
}


NFMfunction nfm_flag_project_backup ()
{
int  subsystem;
long err_no;
long status;
static char *fname = "NFA_FLAG_PROJECT_BACKUP";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, 
	FLAG_PROJ_FILES_BACKUP, NFMworkflow, NFMproject, NFMcatalog,
	NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = flag_project_backup ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );
    NFAalpha_set_to_state ( err_no, msg );
    ERRreset_struct();

return (status);
}

NFMfunction nfm_flag_project_restore ()
{
int  subsystem;
long err_no;
long status;
static char *fname = "NFA_FLAG_PROJECT_RESTORE";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, 
	FLAG_PROJ_FILES_RESTORE, NFMworkflow, NFMproject, NFMcatalog,
	NFMitem, NFMrev);
    if (status != NFI_S_SUCCESS)
        return (status);
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

    status = flag_project_restore ();

    _NFIdebug(( fname, "static -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );
    NFAalpha_set_to_state ( err_no, msg );
    ERRreset_struct();

return (status);
}


NFMfunction nfm_cancel_project_archive_flag ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CANCEL_PROJECT_ARCHIVE_FLAG";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, 
	CANCEL_ARCHIVE_FLAG_PROJ_FILES, NFMworkflow, NFMproject,
	NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = cancel_project_archive_flag ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_cancel_project_backup_flag ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CANCEL_PROJECT_BACKUP_FLAG";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, 
	CANCEL_BACKUP_FLAG_PROJ_FILES, NFMworkflow, NFMproject, NFMcatalog,
	NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = cancel_project_backup_flag ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );
    NFAalpha_set_to_state ( err_no, msg );
    ERRreset_struct();
        
return (status);
}

NFMfunction nfm_cancel_project_restore_flag ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_CANCEL_PROJECT_RESTORE_FLAG";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, 
	CANCEL_RESTORE_FLAG_PROJ_FILES, NFMworkflow, NFMproject, NFMcatalog,
	NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = cancel_project_restore_flag ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_make_transition ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_MAKE_TRANSITION";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, MAKE_TRANSITION,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = make_transition ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_copy_acl_users ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_copy_acl_users";

    if(strcmp(NFMworkflow,"")==0)
     {
        status = NFAactivate_workflow_for_copy_acl ();
    
        if (status != NFI_S_SUCCESS)
         {
            NFAset_message();
            SCdisplay_msg( msg );
            ERRreset_struct();
            return (status);
          }
       }

     status = NFAalpha_validate_user_access (NFMuser_id, COPY_ACL_USERS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = copy_acl_users ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_add_acl ()
{
long status;
long save_status;
long err_no;
int  subsystem;
char acl_name[25];
char wf_name[25];
static char *fname = "NFA_ADD_ACL";

    /* this is a three part command : add acl and add users to the acl 
       and add signoff users to the signoff states */

    status = NFAalpha_validate_user_access (NFMuser_id, ADD_ACL,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_acl (acl_name, wf_name);

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg ); 
    ERRget_number( &err_no, &subsystem );

    save_status = _ERRstruct.NFMstatus;
/*
    NFAalpha_set_to_state ( err_no, msg );
*/
    if (save_status != NFM_S_SUCCESS)
        return (save_status);
    else if (status == NFI_W_COMMAND_CANCELLED )
	return (status);
/*
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_ACL_USER,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);
*/
    status = add_acl_users (acl_name);

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    save_status = _ERRstruct.NFMstatus;

/*
    NFAalpha_set_to_state ( err_no, msg );
*/
    if (save_status != NFM_S_SUCCESS)
        return (save_status);
/*
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_SIGNOFF_USER,
                wf_name, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);
*/
    status = add_signoff_users (acl_name, 1);

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}





NFMfunction nfm_add_acl_users ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_ACL_USERS";
        
    status = NFAactivate_acl ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_ACL_USER,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_acl_users (NFMacl);

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_delete_acl ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_ACL";
        
    status = NFAactivate_workflow ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_ACL,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );

    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_acl ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );
    NFAalpha_set_to_state ( err_no, msg );
    ERRreset_struct();

return (status);
}


NFMfunction nfm_delete_acl_users ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_ACL_USERS";
        
    status = NFAactivate_acl ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_ACL_USER,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_acl_users (NFMacl);

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_add_signoff_users ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_ADD_SIGNOFF_USERS";
        
    status = NFAactivate_acl ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, ADD_SIGNOFF_USER,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = add_signoff_to_users (NFMacl);

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_delete_signoff_users ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_SIGNOFF_USERS";
        
    status = NFAactivate_acl ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_SIGNOFF_USER,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_signoff_users (NFMacl);

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}

NFMfunction nfm_define_search ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DEFINE_SEARCH_CRITERIA";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, DEFINE_SEARCH_CRITERIA,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = NFAactivate_user_search ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = define_search ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_delete_search ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_SEARCH_CRITERIA";
        
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_SEARCH_CRITERIA,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_search ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_define_sort ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DEFINE_SORT_CRITERIA";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, DEFINE_SORT_CRITERIA,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = NFAactivate_user_search ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = define_sort ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
return (status);
}


NFMfunction nfm_delete_sort ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DELETE_SORT_CRITERIA";
        
    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_SORT_CRITERIA,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_sort ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_signoff()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_SIGNOFF";

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS )
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, SIGNOFF_ITEM,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
      return (status) ;

    status = signoff ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
        
    return (status);

}

/*
NFMfunction nfm_logout()
{
long status;

    status = logout();
    if (status != NFI_S_SUCCESS)
        return (status);
        
return (status);
}
*/

NFMfunction nfm_purge_signoff ()
{
  long status;
  static char *fname = "NFA_PURGE_SIGNOFF";

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS )
      {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
      }

  status = NFAalpha_validate_user_access (NFMuser_id, PURGE_SIGNOFF,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
  if (status != NFI_S_SUCCESS)
    return (status);

  status = purge_signoff ();
  
  _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
  
  NFAset_message();
  SCdisplay_msg( msg );

  return (status);
}


NFMfunction nfm_display_storage_areas ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_STORAGE_AREAS";
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_SA,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );

    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_storage_areas ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_working_areas ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_WORKING_AREAS";
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_WORKING_AREA, 
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_working_areas ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_user_working_areas ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_USER_WORKING_AREAS";
        
    status = NFAalpha_validate_user_access (NFMuser_id,LIST_USER_WORKING_AREA, 
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_user_working_areas ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_users ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_USERS";
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_USERS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_users ();

    _NFIdebug(( fname, "static -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_catalogs ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_CATALOGS";
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_CATALOGS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_catalogs ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_items ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_ITEMS";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_ITEMS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_items ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_items_short ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_ITEMS_SHORT";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_ITEMS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_items_short ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_item_files ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_ITEM_FILES";
        
    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, REVIEW_ITEM,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_item_files ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_items_partial ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_ITEMS_PARTIAL";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_ITEMS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_items_partial ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_items_partial_short ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_ITEMS_PARTIAL_SHORT";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_ITEMS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_items_partial_short ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_search_across_catalogs ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_SEARCH_ACROSS_CATALOGS";

/* ma-- i comment this part out because it should not requires you to have
   an active search criteria. TR 92w2602.  9-1-92 */
 
    status = NFAactivate_search_ac_cat ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_ITEMS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = search_across_catalogs ();
    if (status != NFI_S_SUCCESS)
     {
       NFAset_message();
       SCdisplay_msg( msg );
       ERRget_number( &err_no, &subsystem );
       return (status);
      }
    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_workflows ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_WORKFLOWS";
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_WORKFLOWS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_workflows ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_workflows_short ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_WORKFLOWS";
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_WORKFLOWS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_workflows_short ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_acls ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_ACLS";
        
    status = NFAactivate_workflow ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_ACLS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_acls ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_aclusers ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_ACLUSERS";
        
    status = NFAactivate_acl ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_ACL_CLASS_USERS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );

    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_aclusers ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_classes ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_CLASSES";
        
    status = NFAactivate_workflow ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_CLASSES,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_classes ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_search ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_SEARCH";

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_SEARCH_CRITERIA,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_search ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_review_search ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_REVIEW_SEARCH";

    status = NFAactivate_search ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_SEARCH_CRITERIA,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = review_search ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_sort ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_SORT";

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_SORT_CRITERIA,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_sort ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_review_sort ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_REVIEW_SORT";

    status = NFAactivate_sort ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_SORT_CRITERIA,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = review_sort ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_signoff_users ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_SIGNOFF_USERS";
        
    status = NFAactivate_acl ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_ACL_SIGNOFF_USERS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_signoff_users ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_so_on_item ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_SIGNOFF_ON_ITEM";

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS )
      {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
      }
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_SIGNOFF_ON_ITEM,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_signoff_on_item ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_so_history ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_SO_HISTORY";

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS )
      {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
      }
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_SIGNOFF_HISTORY,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_signoff_history ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_projects ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_PROJECTS";
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_PROJECTS,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_projects ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_catalog_acl_mapping ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_CATALOG_ACL_MAPPING";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_CAT_ACL_MAP,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_catalog_acl_mapping ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n",status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_catalog_sa_mapping ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_CATALOG_SA_MAPPING";
        
    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_CAT_SA_MAP,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );

    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_catalog_sa_mapping ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_project_acl_mapping ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_PROJECT_ACL_MAPPING";
        
    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_PROJ_CAT_ACL_MAP,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_project_acl_mapping ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n",status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_project_sa_mapping ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_PROJECT_SA_MAPPING";

    status = NFAactivate_project ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_PROJ_CAT_SA_MAP,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_project_sa_mapping ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_archives ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_ARCHIVES";

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_ARCHIVES,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = display_archives ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_load_workflow ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_LOAD_WORKFLOW";

#ifndef COMBINED_CLIENT_SERVER        
    status = NFAalpha_validate_user_access (NFMuser_id, LOAD_WORKFLOW,
                                            "", "", "", "", "");
    if (status != NFI_S_SUCCESS)
        return (status);

    status = load_workflow ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );
#endif        
        
    NFAset_message();
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    _NFIdebug((fname, "Exiting..\n"));
return (status);
}

NFMfunction nfm_display_local_files ()
{
long status;
   
    if( strcmp( NFMworking, "" ) == 0 )
    {
        status = NFAactivate_wa ();
        if (status != NFI_S_SUCCESS)
        {
            NFAset_message();
            SCdisplay_msg( msg );
            ERRreset_struct();
            return (status);
        }
    }	

    status = display_local_files ();

    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}

NFMfunction nfm_begin_record ()
{
long status;

    status = begin_record ();

    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}

NFMfunction nfm_end_record ()
{
long status;

    status = end_record ();

    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}

NFMfunction nfm_begin_playback ()
{
long status;

    status = begin_playback ();

    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}

NFMfunction nfm_review_environment ()
{
long status;

    status = review_environment ();

        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
return (NFI_S_SUCCESS);
}

NFMfunction nfm_plot_item ()
{
long status;

static char *fname = "NFAplot_item";

#if defined(OS_SUNOS) || defined(OS_SOLARIS) || \
    defined(OS_SCO_UNIX) || defined(OS_HPUX)

    ERRload_struct(NFM, NFM_E_PLOT_NOT_CLIX, NULL, NULL);
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
    return(NFI_S_SUCCESS);

#else

    if( NFMlist_driven )
    {
    	status = plot_item_from_list();
        _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
     }

    status = NFAactivate_item ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );   
        ERRreset_struct();  
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, PLOT_ITEM,
                NFMworkflow, NFMproject, NFMcatalog, NFMitem, NFMrev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = plot_item ();

    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
#endif
}

NFMfunction nfm_plot_set ()
{
long status;

static char *fname = "NFAplot_set";

#if defined(OS_SUNOS) || defined(OS_SOLARIS) || \
    defined(OS_SCO_UNIX) || defined(OS_HPUX)

    ERRload_struct(NFM, NFM_E_PLOT_NOT_CLIX, NULL, NULL);
    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();
    return(NFI_S_SUCCESS);

#else

    if( NFMlist_driven )
    {
   	   status = plot_set_from_list();
       _NFIdebug(( fname, "status -> <0x%.8x>\n", status));
        NFAset_message();
        SCdisplay_msg( msg );
        ERRreset_struct();
        return( status );
    }

    status = NFAactivate_set ();
    if (status != NFI_S_SUCCESS)
    {
        NFAset_message();
        SCdisplay_msg( msg );   
        ERRreset_struct();  
        return (status);
    }
    status = NFAalpha_validate_user_access (NFMuser_id, PLOT_SET,
                NFMworkflow, NFMproject, NFMcatalog, NFMset, NFMset_rev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = plot_set ();

    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
#endif
}


NFMfunction nfm_sqlquery ()
{
long status;

    status = sqlquery_cursor ();

    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}

NFMfunction nfm_delete_label ()
{
long status;

static char *fname = "NFAdelete_label";

    _NFIdebug(( fname, "%s\n", "Call delete_label" ));

    status = NFAalpha_validate_user_access (NFMuser_id, DELETE_TAPE_LABELS,
                "", "", "", "", "" );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = delete_label ();

    NFAset_message();
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}

