#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "NFMRextern.h"
#include "WFcommands.h"
#include "SCdef.h"
#include "SCdata.h"
#include "SCstruct.h"
#include "NFIerrordef.h"
#include "NFIcommands.h"
#include "ERR.h"
#include "NFMbulk.h"

extern struct _ERRstruct _ERRstruct;
extern char SCexec[30];
extern char SCuser_cmd_file[150];
extern char SCadmin_cmd_file[150];

NFMfunction nfm_debug_on ()
{
long status;
    
    status = debug_on ();
    ERRget_message( msg );
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}

NFMfunction nfm_debug_off ()
{
long status;
    
    status = debug_off ();
    ERRget_message( msg );
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}



NFMfunction nfm_server_debug_on ()
{
long status;

    status = server_debug_on ();
    ERRget_message( msg );
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}

NFMfunction nfm_server_debug_off ()
{
long status;

    status = server_debug_off ();
    ERRget_message( msg );
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}

NFMfunction nfm_client_debug_on ()
{
long status;

    status = client_debug_on ();
    ERRget_message( msg );
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}

NFMfunction nfm_client_debug_off ()
{
long status;

    status = client_debug_off ();
    ERRget_message( msg );
    SCdisplay_msg( msg );
    ERRreset_struct();

return (status);
}

/*
NFMfunction nfm_sqlquery ()
{
long status;
    
    status = sqlquery();
    ERRget_message( msg );
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}

NFMfunction nfm_sqlstmt ()
{
long status;
    
    status = sqlstmt();
    ERRget_message( msg );
    SCdisplay_msg( msg );
    ERRreset_struct();
        
return (status);
}
*/
NFMreset_errors ()

{
    NFMRmsg_ptr.error_no = 0;
    NFMmsg_ptr.error_no = 0;
        

    strcpy (NFMmsg_ptr.error_msg,   "");

    return (NFM_S_SUCCESS);
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
	ERRget_message( msg );
	SCdisplay_msg( msg );
	ERRreset_struct();
        return (status);
    }
    return( NFM_S_SUCCESS );    
}


NFAalpha_set_to_state ( error_number, error_message )
    long error_number;
    char *error_message;    
{
long status;

    status = NFMRset_wf_state ( "NFM", error_number, error_message );
    if (status != NFM_S_SUCCESS)
    {
	ERRget_message( msg );
	SCdisplay_msg( msg );
	ERRreset_struct();
	return( status );
    }

    ERRreset_struct();
    return (NFM_S_SUCCESS);
        
}

NFMfunction nfm_display_nodes ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_NODES";
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_NODES, "",
                                            "", "", "", "");

    if (status != NFM_S_SUCCESS)
        return (status);

    status = display_nodes ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    ERRget_message( msg );
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}

NFMfunction nfm_display_storage_areas ()
{
long status;
long err_no;
int  subsystem;
static char *fname = "NFA_DISPLAY_STORAGE_AREAS";
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_SA, "",
                                            "", "", "", "");

    if (status != NFM_S_SUCCESS)
        return (status);

    status = display_storage_areas ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    ERRget_message( msg );
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
        
    status = NFAalpha_validate_user_access (NFMuser_id, LIST_CATALOGS, "",
                                            "", "", "", "");
    if (status != NFM_S_SUCCESS)
        return (status);

    status = display_catalogs ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    ERRget_message( msg );
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
        ERRget_message( msg );
        SCdisplay_msg( msg );
        ERRreset_struct();
        return (status);
    }

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_ITEMS, "",
                                            "", "", "", "");
    if (status != NFM_S_SUCCESS)
        return (status);

    status = display_items ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    ERRget_message( msg );
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

    status = NFAalpha_validate_user_access (NFMuser_id, LIST_SA, "",
                                            "", "", "", "");
    if (status != NFM_S_SUCCESS)
        return (status);

    status = display_working_areas ();

    _NFIdebug(( fname, "status -> <0x%.8x>\n", status));

    ERRget_message( msg );
    SCdisplay_msg( msg );
    ERRget_number( &err_no, &subsystem );

    NFAalpha_set_to_state ( err_no, msg );

return (status);
}


NFMfunction nfm_bulk_load ()
{
long  status;
long  err_no;
int   i;
long  NFMget_big_list_catalog();
long  max_directory_size;
int subsystem;
static char *fname = "nfm_bulk_load";

    NFMreset_errors ();
    _NFMR_str ("%s", "Call NFMreset_errors");

    status = NFAactivate_catalog ();
    _NFMR_str ("%s", "Call NFAactivate_catalog");
    if (status != NFI_S_SUCCESS)
    {
        _NFMR_num ( "This is status <0x%.8x>", status);
        ERRget_message( msg );
        SCdisplay_msg( msg );
        ERRreset_struct();
        ERRget_number(&err_no,&subsystem);
        return (status);
    }

    status = NFAactivate_sa ();

    _NFMR_str ("%s", "Call NFAactivate_sa");
    if (status != NFI_S_SUCCESS)
    {
        _NFMR_num ( "This is status1 <0x%.8x>", status);	
        ERRget_message( msg );
        SCdisplay_msg( msg );
        ERRreset_struct();
        ERRget_number(&err_no,&subsystem);
        return (status);
    }

        _NFMR_str("%s",  "call this for test");

        status = bulk_load ();

/*    NFAalpha_set_to_state (err_no,msg);*/

    _NFIdebug ((fname, "NFMbulk_load (COMMAND) -> <0x%.8x>",   status));

    ERRget_message( msg );
    SCdisplay_msg( msg );
    ERRreset_struct();
    ERRget_number(&err_no,&subsystem);
   _NFMR_str ("%s", "Exitnig\n");
   return(status);
 }
