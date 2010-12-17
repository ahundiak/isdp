#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
 
long review_environment ()
{
long   status;
int    i;
int    tot_data;
int    pos;
int    call_login = FALSE;
int    call_logout = TRUE;
int    user_pos;
int    passwd_pos;
int    env_pos;
char   new_server[30];
char   new_user[NFM_USERNAME+1];
char   new_passwd[NFM_PASSWD+1];
char   new_env[30];
char   user[NFM_USERNAME+1];
char   nodename[NFM_NODENAME+1];
char   pathname[NFM_PATHNAME+1];
char   wa[NFM_SANAME+1];
MEMptr node_info = NULL;
MEMptr sa_info   = NULL;
MEMptr login_defaults = NULL;
struct SCcolumn_data_st data;
static char *fname = "NFAreview_environment";

    _NFIdebug ((fname, "Enter.\n"));

    user_pos   = 0;
    passwd_pos = 2;
    env_pos    = 4;
    data.num_of_rows = 3;
#ifndef COMBINED_CLIENT_SERVER
    data.num_of_rows = 4;
    user_pos   = 2;
    passwd_pos = 4;
    env_pos    = 6;
#endif
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 13;
    data.col_width[1] = 30;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Review/Change Environment Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));
    data.hidden[passwd_pos+1] = 1;

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

#ifndef COMBINED_CLIENT_SERVER
    NFAput_string (&data.data[0], "I/NFM Server");
    NFAput_string (&data.data[1], (NFMserver+5) );
#endif
    NFAput_string (&data.data[user_pos], "Username");
    NFAput_string (&data.data[user_pos+1], NFMuser );
    NFAput_string (&data.data[passwd_pos], "Password");
    NFAput_string (&data.data[passwd_pos+1], NFMpasswd );
    NFAput_string (&data.data[env_pos], "Environment");
    NFAput_string (&data.data[env_pos+1], NFMenv );

    status = SCprocess_column_form (&data, NFMprint_file);
    SCclear_msg ();

    _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));
    if( data.sts == FORM_CANCELED )
    {   
	NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
	return( NFI_W_COMMAND_CANCELLED );
    } 

    /*  Check for any changes */
#ifndef COMBINED_CLIENT_SERVER
    sprintf( new_server, "nfms_%s", data.data[1] );
#endif
    strcpy( new_user, data.data[user_pos+1] );
    strcpy( new_passwd, data.data[passwd_pos+1] );
    strcpy( new_env, data.data[env_pos+1] );

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

#ifndef COMBINED_CLIENT_SERVER
    if( strcmp( new_server, NFMserver ) != 0 )
    {
	/*  Call logout */
	_NFIdebug(( fname, "Logout from <%s>\n", NFMenv ));
	sprintf( msg, "NFM:  Logging out from <%s>\n", NFMenv );
	SCdisplay_msg( msg );
	NFMRlogout( (long)0);
	call_logout = FALSE;

	/*  Disconnect */
	_NFIdebug(( fname, "Disconnect from <%s>\n", NFMserver ));
	sprintf( msg, "NFM:  Disconnecting from <%s>\n", (NFMserver+5) );
	NFMRterminate();

	/*  Connect to new server */
	_NFIdebug(( fname, "Connect to <%s>\n", new_server ));
	sprintf( msg, "NFM:  Connecting to <%s>\n", (new_server+5) );
	status = NFMRconnect( new_server );
	if( status != NFM_S_SUCCESS )
	{
	    _NFIdebug(( fname, "NFMRconnect <0x%.8x>\n", status ));
	    return( status );	    
	}
	_NFIdebug(( fname, "%s\n", "Returned from NFMRconnect" ));
    }
#endif

    /*  See if login needs to be called */
    if( strcmp( new_user, NFMuser ) != 0 )
	call_login = TRUE;

    if( strcmp( new_passwd, NFMpasswd ) != 0 )
	call_login = TRUE;

    if( strcmp( new_env, NFMenv ) != 0 )
	call_login = TRUE;

    _NFIdebug(( fname, "new_user <%s>\n", new_user ));
    _NFIdebug(( fname, "new_env  <%s>\n", new_env ));

    if(call_login == TRUE)
    {
	if(call_logout == TRUE)  /* Same server, different env */
	{
	    /*  Logout first */
	    _NFIdebug(( fname, "%s\n", "Logging out" ));
	    NFMRlogout( (long)0);
	}
	
	sprintf( msg, "NFM:  Logging into <%s>", new_env );
	SCdisplay_msg( msg );

	sprintf( msg, "nfme_%s", new_env );
	_NFIdebug(( fname, "Username <%s>\n", new_user ));
	_NFIdebug(( fname, "Environment <%s>\n", new_env ));

	status = NFMRlog_in( new_user, new_passwd, msg, "NFM" );
	if( status != NFM_S_SUCCESS )
	{
	    _NFIdebug(( fname, "NFMRlog_in <0x%.8x>\n", status ));
	    return( status );
	}

	NFAclear_globals();

#ifndef COMBINED_CLIENT_SERVER	
	status = NFMRget_host_info( NFMuser_id, 1 );
	if( status != NFM_S_SUCCESS )
	    _NFIdebug(( fname, "NFMRget_host_info <0x%.8x>\n", status ));
#endif

        status = NFMRread_user_defaults( &login_defaults );
        if( status == NFM_S_SUCCESS )
            status = NFAalpha_defaults_login( login_defaults );
        else
            _NFIdebug(( fname, "Return from NFMRread_user_defaults <0x%.8x>\n",
		    status));

        status =  _NFMget_wa_system_info (nodename, user, pathname, 
				      &node_info, &sa_info);
        _NFIdebug(( fname, "Node <%s>\n", nodename ));
        _NFIdebug(( fname, "User <%s>\n", user ));
        _NFIdebug(( fname, "Path <%s>\n", pathname ));
        if( status == NFM_S_SUCCESS )
        {
            status = NFMRadd_default_working_area(nodename, user, pathname, 
			wa, node_info, sa_info);
            if( status != NFM_S_SUCCESS )
            {
     	        _NFIdebug(( fname, "Return from NFMRadd_default_working_area <0x%.8x>\n", status ));
            }
  	    strcpy( NFMworking, wa );
        }
        else
	    _NFIdebug(( fname, "Return from NFMget_wa_system_info <0x%.8x>\n", 
	            status ));
    }

    MEMclose( &node_info );
    MEMclose( &sa_info );
    MEMclose( &login_defaults );

#ifndef COMBINED_CLIENT_SERVER
    strcpy( NFMserver, new_server );
#endif
    strcpy( NFMenv, new_env );
    strcpy( NFMuser, new_user );
    strcpy( NFMpasswd, new_passwd );

    NFAset_message ();
    SCdisplay_msg (msg);
    ERRreset_struct();

    _NFIdebug((fname, "tell me i'm here\n"));    

    return (NFI_S_SUCCESS);
}







