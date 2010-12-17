#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

nfm_enter (cmd_line_server, cmd_line_env, cmd_line_user, cmd_line_passwd,
	   exec_path)
    char *cmd_line_server;
    char *cmd_line_env;
    char *cmd_line_user;
    char *cmd_line_passwd;
    char *exec_path ;

{
long   status;
int    login_count = 0;
char   server_name[20];
char   env_name[20];
char   server_str[30];
FILE   *fopen (), *init_file;
MEMptr server_list = NULL;

static char *fname = "NFAenter";

    _NFIdebug(( fname, "%s\n", "Entering..." ));
    _NFIdebug(( fname, "Server <%s>\n",  cmd_line_server));
    _NFIdebug(( fname, "Env    <%s>\n",  cmd_line_env));
    _NFIdebug(( fname, "User   <%s>\n",  cmd_line_user));

    SCdisplay_msg ("Working..");

#ifndef COMBINED_CLIENT_SERVER
    strcpy (server_str, "nfms_");
    if (strcmp (cmd_line_server, "") == 0)
        {
        /* get all valid NFM Servers */

        status = NFMls_nodes ("nfms_", &server_list);
	_NFIdebug(( fname, "NFMls_nodes  <0x%.8x>\n", status ));
        if (status != NFM_S_SUCCESS)
            {
	    ERRload_struct( NFI, NFI_E_LIST_SERVERS, NULL, NULL );
            return (NFI_E_FAILURE);
            }

        status = MEMbuild_array (server_list);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&server_list);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","FMenter",
			    "MEMbuild_array" );
            return (NFI_E_FAILURE);
            }

        status = NFAget_server_name (server_list, server_name);
        if (status != NFI_S_SUCCESS)
            {
            MEMclose (&server_list);
	    ERRload_struct( NFI, NFI_E_GET_SERVER_NAME, "%s", server_name );
            return (NFI_E_FAILURE);
            }

        MEMclose (&server_list);

        strcat (server_str, server_name);
        }

    else
        /* use command line server */
        {
        strcpy (server_name, cmd_line_server);
        strcat (server_str, cmd_line_server);
        }

    SCdisplay_msg ("Working..");

    status = NFMRconnect (server_str);

    if (status != NFM_S_SUCCESS)
        {
	ERRload_struct( NFI, NFI_E_CANNOT_CONNECT, "%s", server_name );
        return (NET_E_NO_SERVER_CONNECTION);
        }

    strcpy (NFMserver, server_str);
#endif

    if (strcmp (cmd_line_env, "") == 0)
        {
        /* get all valid NFM environments */

        SCdisplay_msg ("Working..");
  
        status = NFMls_nodes ("nfme_", &server_list);
        if (status != NFM_S_SUCCESS)
            {
	    ERRload_struct( NFI, NFI_E_LIST_SERVERS, NULL, NULL );
            return (NFI_E_FAILURE);
            }

        status = MEMbuild_array (server_list);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&server_list);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","FMenter",
			    "MEMbuild_array" );
            return (NFI_E_FAILURE);
            }

        status = NFAget_env_name (server_list, env_name);
        if (status != NFI_S_SUCCESS)
            {
            MEMclose (&server_list);
	    ERRload_struct( NFI, NFI_E_GET_SERVER_NAME, "%s", env_name );
            return (NFI_E_FAILURE);
            }

        MEMclose (&server_list);

        strcpy (cmd_line_env, env_name);
        }

    do
        {
        status = nfm_login (server_name, cmd_line_env, cmd_line_user,
                            cmd_line_passwd, login_count);
        ++login_count;
        _NFIdebug(( fname, "Return from nfm_login : <0x%.8x>\n", status));
        _NFIdebug(( fname, "Server <%s>\n", cmd_line_server));
        _NFIdebug(( fname, "Env    <%s>\n",  cmd_line_env));
        _NFIdebug(( fname, "User   <%s>\n",  cmd_line_user));

	if( status != NFI_S_SUCCESS )
	    {
	        strcpy( cmd_line_user, "" ); /* Clear out to get login form */
		NFAset_message( );
		SCdisplay_msg( msg );
		ERRreset_struct();
	    }
        }
    while ((status != NFI_S_SUCCESS) && 
           (login_count < 3) &&
           (status != NFI_W_COMMAND_CANCELLED));

    if ((login_count >= 3) && (status != NFI_S_SUCCESS))
        {
	ERRload_struct( NFI, NFI_E_INVALID_USERNAME_PASSWORD, NULL, NULL);
        return (NFI_E_FAILURE);
        }

    if ((login_count < 3) && (status == NFI_W_COMMAND_CANCELLED))
        {
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL);
        return (NFI_W_COMMAND_CANCELLED);
        }

    else 
    {
        _NFIdebug(( fname, "FMenter Returning : <0x%.8x>\n", status));
        return (NFI_S_SUCCESS);
    }
 }
