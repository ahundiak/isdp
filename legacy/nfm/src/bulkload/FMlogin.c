#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

long nfm_login (server, cmd_line_env, cmd_line_user, cmd_line_passwd, 
                login_count)
    char *server;
    char *cmd_line_env;
    char *cmd_line_user;
    char *cmd_line_passwd;
    int  login_count;

{
long   status;
char   env_name[20];
char   env_file [20] ;
char   user[NFM_USERNAME+1];
char   passwd[NFM_PASSWD+1];
char   nodename[NFM_NODENAME+1];
char   pathname[NFM_PATHNAME+1];
char   wa[NFM_SANAME+1];
MEMptr node_info = NULL;
MEMptr sa_info   = NULL;
MEMptr login_defaults = NULL;
static char *fname = "NFAlogin";
long   NFAget_user_pwd();

    _NFIdebug(( fname, "server      <%s>\n", server));
    _NFIdebug(( fname, "environment <%s>\n", cmd_line_env));
    _NFIdebug(( fname, "username    <%s>\n", cmd_line_user));
    _NFIdebug(( fname, "login_count <%d>\n", login_count));

    if (strcmp (cmd_line_env, "") != 0)
        strcpy (env_name, cmd_line_env);
    else
        strcpy (env_name, server);

    sprintf (env_file, "nfme_%s", env_name) ;

    strcpy( user, cmd_line_user );
    strcpy( passwd, cmd_line_passwd );

    if( strcmp( cmd_line_user, "" ) == 0 )
    {
	status = NFAget_user_pwd( user, passwd );
	if( status == NFI_W_COMMAND_CANCELLED )
	    return( status );
	else if( status != NFI_S_SUCCESS )
	    return( NFI_E_FAILURE );
    }

    NFMuser_id = 0 ;

    SCdisplay_msg( "Working.." );

    status = NFMRlog_in (user, passwd, env_file, "NFM") ;
    _NFIdebug(( fname, "Return from NFMRlog_in -> 0x%.8x\n", status));
    if( status != NFM_S_SUCCESS )
	return( NFI_E_FAILURE );

    NFMuser_id = 100 ;

    strcpy (NFMenv, env_name);
    strcpy (NFMuser, user);
    strcpy (NFMpasswd, passwd);
    strcpy (NFMworking, "" );

    status = NFMRread_user_defaults( &login_defaults );
    if( status == NFM_S_SUCCESS )
        status = NFAalpha_defaults_login( login_defaults );
    else
        _NFIdebug(( fname, "Return from NFMRread_user_defaults -> 0x%.8x\n",
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

/* KT - 9/18/92  Moved this because NFMload_user_info will change the
                 current working directory to /usr/nfmadmin and the
                 NFMRadd_default_working_area would use /usr/nfmadmin
                 instead of using the correct path.
*/

#ifndef COMBINED_CLIENT_SERVER
    status = NFMRget_host_info (NFMuser_id, 1) ;
    if (status != NFM_S_SUCCESS)
        _NFIdebug(( fname, "NFMRget_host_info : <0x%.8x>\n", status) );
#else
    status = (long) NFMload_user_info ( "nfmadmin" );
    if (status != NFM_S_SUCCESS)
        _NFIdebug(( fname, "NFMload_user_info : <0x%.8x>\n", status) );
#endif

    MEMclose( &node_info );
    MEMclose( &sa_info );
    MEMclose( &login_defaults );

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg ));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}

long  NFAget_user_pwd( user, passwd )
    char  *user;
    char  *passwd;
{
    int    i;
    int    pos;
    int    FORM_FILLED;
    int    tot_data;
    long   status;
    struct SCcolumn_data_st data;
    static char *fname = "NFAget_user_pwd";

    pos = 3;
    data.num_of_rows = 3;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 10;
    data.col_width[1] = 10;
    data.col_width[2] = 20;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Log In To I/NFM");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+2; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));
    data.hidden[pos+5] = 1;  /* Hide the password */

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string( &data.data[pos], "User Name" );
    NFAput_string( &data.data[pos+1], "char(14)" );
    NFAput_string( &data.data[pos+2], "" );
    NFAput_string( &data.data[pos+3], "Password" );
    NFAput_string( &data.data[pos+4], "char(14)" );
    NFAput_string( &data.data[pos+5], "" );

    do
        {
        FORM_FILLED = TRUE;

        status = SCprocess_column_form (&data, NFMprint_file);

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n", 
		data.sts));

        if (data.sts != FORM_CANCELED)
            {
             if( strcmp( data.data[pos+2], "" ) == 0 )
	 	{
		    FORM_FILLED = FALSE;
		    SCdisplay_msg( "NFM:  Must enter username. " );
		}
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFIdebug(( fname, "%s\n", "Cancel from form. Return."));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    strcpy( user, data.data[pos+2] );
    strcpy( passwd, data.data[pos+5] );

    _NFIdebug(( fname, "User <%s>\n", user ));
    _NFIdebug(( fname, "Passwd <%s>\n", "NOT PRINTED" ));

    return( NFI_S_SUCCESS );
}
