/* $Revision: 1.1 $ */
#include <stdio.h>
#include "dba.ext"
#include <sys/utsname.h>
/* PS 21 june 1995
#ifndef __SUN__
#include <sys/varargs.h>
#endif
*/
#include "machine.h"
#include "NFMRinclude.h"
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "WFcommands.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "NDXstruct.h"
#include "ERR.h"
#include "NFMapi.h"
#include "UMS.h"
#include "dbn.h"

extern struct NFMRglobal_st NFMRglobal;

/* Subba Temp. */
extern FILE *dba_log;

/*
Function: dba_nfm_login

Description: This function makes the network connection and then logs in
             to NFM.
Author: DB Access

Date: 27-Jul-90
*/

int dba_nfm_login(server, user, passwd, environment, debug)

char *server, *user, *passwd, *environment;
int debug;

{
    int status, i;
    int toggles[NFM_DEBUG_SUBSYSTEMS];
    char files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE], message[256],
         env_prefixed[32];
    char server_string[132];

    if (dba_nfm_active) return(DBA_NFM_SUCCESS);

    strcpy(dba_nfm_server, server);
    strcpy(dba_nfm_user, user);
    strcpy(dba_nfm_passwd, passwd);
    strcpy(dba_nfm_env, environment);
/*
	Initialize the NFM error messages
*/
    if (!dba_nfm_message_init)
    {
        status = ERRinit_messages("/usr/ip32/nfm/config/english/messages", 
                 UMS_INDEX);
        if (status != ERR_S_SUCCESS)
        {
	    printf("ERRinit_messages, /usr/ip32/nfm/config/english/messages\n");
            return(status);
        }
    }
    dba_nfm_message_init = TRUE;
/*
	Establish a connection with the NFM server.
*/
    strcpy(server_string,"nfms_");
    strcat(server_string, server);

#ifndef COMBINED_CLIENT_SERVER
    status = NFMRconnect(server_string);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
#endif

    dba_nfm_connected = TRUE;

    sprintf(env_prefixed, "nfme_%s", environment);
    status = NFMRlog_in(user, passwd, env_prefixed, "NFM");

    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
#ifndef COMBINED_CLIENT_SERVER
        NFMRterminate();
#endif
        return(status);
    }
    dba_nfm_active = TRUE;

    if (debug)
    {
        for (i = 0; i < NFM_DEBUG_SUBSYSTEMS; ++i)
        {
	    toggles[i] = 0;
            files[i][0] = '\0';
        }
        toggles[2] = 1;
        toggles[7] = 1;
	toggles[8] = 1;
        toggles[9] = 1;
        toggles[14] = 1;
        strcpy(files[2], "/usr/tmp/debug2.dat");
        strcpy(files[7], "/usr/tmp/debug7.dat");
        strcpy(files[8], "/usr/tmp/debug8.dat");
        strcpy(files[9], "/usr/tmp/debug9.dat");
        strcpy(files[14], "/usr/tmp/debug14.dat");
        status = NFMRall_debug ( toggles, files ); 
        /* status = NFMRclient_debug ( toggles, files ); */

        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();

        if (status != NFM_S_SUCCESS)
        {
	    dba_nfm_get_message(message);
            printf("NFMRall_debug, status = %d\n", status);
        }
    }

#ifndef COMBINED_CLIENT_SERVER
    NFMRget_host_info((long)0, 1);
#endif
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_logout

Description: This function logs out of NFM and then disconnects from the 
             network.

Author: DB Access

Date: 17-Jan-90
*/
int dba_nfm_logout()
{
#ifdef COMBINED_CLIENT_SERVER
    char schema[64], passwd[64], string[128];
#endif

    int status=0;

    if (dba_nfm_active)
    {

#ifdef COMBINED_CLIENT_SERVER
        status = dba_nfm_get_schema_name(schema, passwd);
        if (status != DBA_NFM_SUCCESS) return(status);
#endif

	status = NFMRlogout(dba_nfm_userid);
        if (status != NFM_S_SUCCESS)
        {
	    return(status);
        }

#ifdef COMBINED_CLIENT_SERVER
        sprintf(string, "default schema %s.%s", schema, passwd);
        status = dba_ris_exec_sql(string);
#endif
        dba_nfm_active = FALSE;
    }
    if (dba_nfm_connected)
    {
#ifndef COMBINED_CLIENT_SERVER
        NFMRget_host_info((long)0, 0);
	status = NFMRterminate();
#endif
        if (status != NFM_S_SUCCESS)
        {
	    return(status);
        }
        dba_nfm_connected = FALSE;
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_copy

Description: This function is used to perform an NFM copy item files.

Author: DB Access
Date: 27-Jul-90
*/
/*ARGSUSED*/
int dba_nfm_copy(catalog, name, rev, storage, 
                  node, user, passwd, path, filename)
char *catalog, *name, *rev, *storage, 
     *node, *user, *passwd, *path, *filename;
{
    int status;
    struct NFMwf_info wf_info;
    struct NFMoperation operation;
    char *working_area, temp_sa[32];

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }

    dba_nfm_default_schema();

    if (filename && (strlen(filename) > 0))
    {
	status = dba_nfm_change_file(catalog, name, rev, (void *)0,
                                     "n_cofilename", filename);
        if (status != DBA_NFM_SUCCESS)
        {
            ERRget_message(dba_nfm_error_message);
            ERRreset_struct();
	    return(status);
        }
    }

    if (strcmp(storage, "DEFAULT") == 0)
    {
	status = dba_nfm_make_working_area(temp_sa);
        if (status)
        {
	    return(status);
        }

        status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }
    else if ((storage) && (strlen(storage) > 0))
    {
	working_area = storage;
    }
    else
    {
        status = dba_nfm_create_temporary_storage(node, user, path, temp_sa);
        if (status)
        {
            return(status);
        }

        status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }

    if (dba_nfm_workflow)
    {
        wf_info.workflow = NFM_WORKFLOW;
        strcpy(wf_info.command, COPY_ITEM_FILES);
        strcpy(wf_info.workflow_name, "NFM_ITEM_WORKFLOW");
        strcpy(wf_info.app_name, "NFM");
        wf_info.project_name[0] = '\0';
    }
    else
    {
	wf_info.workflow = NFM_NO_WORKFLOW;
    }

    if (dba_nfm_lfm) 
    {
        operation.transfer = NFM_CONDITIONAL_TRANSFER;
        operation.delete = NFM_CONDITIONAL_DELETE;
    }
    else
    {
        operation.transfer = NFM_TRANSFER;
        operation.delete = NFM_DELETE_FILES;
    }

    operation.purge = NFM_PURGE;

    status = NFMRcopy_item_files(catalog, -1, name, rev, 
                                 working_area, wf_info, operation);
    if (status != NFM_S_SUCCESS)
    {
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
        return(status);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_set_copy

Description: This function is used to perform an NFM set copy.

Author: DB Access
Date: 27-Jul-90
*/
/*ARGSUSED*/
int dba_nfm_set_copy(catalog, set_name, set_rev, level, storage, node, 
                 user, passwd, path)

char *catalog, *set_name, *set_rev, *storage, 
     *node, *user, *passwd, *path;
int level;

{
    int status;
    struct NFMwf_info wf_info;
    struct NFMoperation operation[2];
    char *working_area, temp_sa[32];

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    if (strcmp(storage, "DEFAULT") == 0)
    {
	status = dba_nfm_make_working_area(temp_sa);
        if (status)
        {
	    return(status);
        }

        status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }
    else if ((storage) && (strlen(storage) > 0))
    {
	working_area = storage;
    }
    else
    {
        status = dba_nfm_create_temporary_storage(node, user, path, temp_sa);
        if (status)
        {
            return(status);
        }

        status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }

    if (dba_nfm_workflow)
    {
        wf_info.workflow = NFM_WORKFLOW;
        strcpy(wf_info.command, COPY_SET_FILES);
        strcpy(wf_info.workflow_name, "NFM_ITEM_WORKFLOW");
        strcpy(wf_info.app_name, "NFM");
        wf_info.project_name[0] = '\0';
    }
    else
    {
	wf_info.workflow = NFM_NO_WORKFLOW;
    }
    if (dba_nfm_lfm) 
    {
        operation[0].transfer = NFM_CONDITIONAL_TRANSFER;
        operation[0].delete = NFM_CONDITIONAL_DELETE;
    }
    else
    {
        operation[0].transfer = NFM_TRANSFER;
        operation[0].delete = NFM_DELETE_FILES;
    }

    operation[0].purge = NFM_PURGE;
    strcpy(operation[0].catalog, catalog);
    operation[0].catalog_no = -1;
    operation[0].item_name[0] = '\0';
    operation[0].item_rev[0] = '\0';

    memset(&operation[1], 0 , sizeof(struct NFMoperation));

    status = NFMRcopy_set_files(catalog, -1, set_name, set_rev, -1,
                              working_area, wf_info, NFM_SAME_OPERATION,
                              operation, -1);

    if (status != NFM_S_SUCCESS)
    {
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
	return(status);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_checkin

Description: This function is used to perform an NFM checkin.

Author: DB Access
Date: 27-Jul-90
*/
/*ARGSUSED*/
int dba_nfm_checkin(catalog, name, rev, storage, node, user, passwd, 
                    path, filename)
char *catalog, *name, *rev, *storage, *node, *user, 
     *passwd, *path, *filename;
{
    struct NFMwf_info wf_info;
    struct NFMoperation operation;
    char *working_area, temp_sa[32];
    int status;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    if (filename && (strlen(filename) > 0))
    {
	status = dba_nfm_change_file(catalog, name, rev, (void *)0,
                                     "n_cofilename", filename);
        if (status != DBA_NFM_SUCCESS)
        {
            ERRget_message(dba_nfm_error_message);
            ERRreset_struct();

	    return(status);
        }
    }
    if (strcmp(storage, "DEFAULT") == 0)
    {
	status = dba_nfm_make_working_area(temp_sa);
        if (status)
        {
	    return(status);
        }

        status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }
    else if ((storage) && (strlen(storage) > 0))
    {
	working_area = storage;
    }
    else
    {
        status = dba_nfm_create_temporary_storage(node, user, path, temp_sa);
        if (status)
        {
            return(status);
        }

        status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }

    if (dba_nfm_workflow)
    {
        wf_info.workflow = NFM_WORKFLOW;
        strcpy(wf_info.command, CHECKIN_ITEM);
        strcpy(wf_info.workflow_name, "NFM_ITEM_WORKFLOW");
        strcpy(wf_info.app_name, "NFM");
        wf_info.project_name[0] = '\0';
    }
    else
    {
	wf_info.workflow = NFM_NO_WORKFLOW;
    }
    if (dba_nfm_lfm) 
    {
        operation.transfer = NFM_CONDITIONAL_TRANSFER;
        operation.delete = NFM_CONDITIONAL_DELETE;
    }
    else
    {
        operation.transfer = NFM_TRANSFER;
        operation.delete = NFM_DELETE_FILES;
    }
    operation.purge = NFM_PURGE;

    status = NFMRcheckin_item(catalog, -1, name, rev, working_area, wf_info,
                              operation);
    if (status != NFM_S_SUCCESS)
    {
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
        return(status);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_set_checkin

Description: This funtion will perform an NFM checkin of a set.

Author: DB Access
Date: 27-Jul-90
*/

/*ARGSUSED*/
int dba_nfm_set_checkin(catalog, set_name, set_rev, storage, 
                        node, user, passwd, path)
char *catalog, *set_name, *set_rev, *storage, 
     *node, *user, *passwd, *path;
{
    int status;
    struct NFMwf_info wf_info;
    struct NFMoperation operation[2];
    char *working_area, temp_sa[32];

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }

    dba_nfm_default_schema();
    if (strcmp(storage, "DEFAULT") == 0)
    {
	status = dba_nfm_make_working_area(temp_sa);
        if (status)
        {
	    return(status);
        }

        status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }
    else if ((storage) && (strlen(storage) > 0))
    {
	working_area = storage;
    }
    else
    {
        status = dba_nfm_create_temporary_storage(node, user, path, temp_sa);
        if (status)
        {
            return(status);
        }
        
	status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }
    if (dba_nfm_workflow)
    {
        wf_info.workflow = NFM_WORKFLOW;
        strcpy(wf_info.command, CHECKIN_SET);
        strcpy(wf_info.workflow_name, "NFM_ITEM_WORKFLOW");
        strcpy(wf_info.app_name, "NFM");
        wf_info.project_name[0] = '\0';
    }
    else
    {
        wf_info.workflow = NFM_NO_WORKFLOW;
    }
    if (dba_nfm_lfm) 
    {
        operation[0].transfer = NFM_CONDITIONAL_TRANSFER;
        operation[0].delete = NFM_CONDITIONAL_DELETE;
    }
    else
    {
        operation[0].transfer = NFM_TRANSFER;
        operation[0].delete = NFM_DELETE_FILES;
    }
    operation[0].purge = NFM_PURGE;

    strcpy(operation[0].catalog, catalog);
    operation[0].catalog_no = -1;
    operation[0].item_name[0] = '\0';
    operation[0].item_rev[0] = '\0';
    memset(&operation[1], 0 , sizeof(struct NFMoperation));

    status = NFMRcheckin_set(catalog, -1, set_name, set_rev, -1,
                              working_area, wf_info, NFM_SAME_OPERATION,
                              operation, -1);

    if (status != NFM_S_SUCCESS)
    {
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
	return(status);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_checkout
Description: This function will perform an nfm checkout.

Author: DB Access
Date: 27-Jul-90
*/
/*ARGSUSED*/
int dba_nfm_checkout(catalog, name, rev, storage, 
                     node, user, passwd, path, filename)

char *catalog, *name, *rev, *storage, *node, *user, 
     *passwd, *path, *filename;

{
    int status;
    struct NFMwf_info wf_info;
    struct NFMoperation operation;
    char *working_area, temp_sa[32];

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {

	    return(status);
        }
    }
    dba_nfm_default_schema();
    if (filename && (strlen(filename) > 0))
    {
	status = dba_nfm_change_file(catalog, name, rev, (void *)0,
                                     "n_cofilename", filename);
        if (status != DBA_NFM_SUCCESS)
        {
            ERRget_message(dba_nfm_error_message);
            ERRreset_struct();

	    return(status);
        }
    }
    if (strcmp(storage, "DEFAULT") == 0)
    {
	status = dba_nfm_make_working_area(temp_sa);
        if (status)
        {
	    return(status);
        }
        
	status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
	fprintf(dba_log, "Temp Working area created\n");
    }
    else if ((storage) && (strlen(storage) > 0))
    {
	working_area = storage;
    }
    else
    {
        status = dba_nfm_create_temporary_storage(node, user, path, temp_sa);
        if (status)

        {
            return(status);
        }
        
	status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }
    if (dba_nfm_workflow)
    {
        wf_info.workflow = NFM_WORKFLOW;
        strcpy(wf_info.command, CHECKOUT_ITEM);
        strcpy(wf_info.workflow_name, "NFM_ITEM_WORKFLOW");
        strcpy(wf_info.app_name, "NFM");
        wf_info.project_name[0] = '\0';
    }
    else
    {
        wf_info.workflow = NFM_NO_WORKFLOW;
    }
    if (dba_nfm_lfm) 
    {
        operation.transfer = NFM_CONDITIONAL_TRANSFER;
        operation.delete = NFM_CONDITIONAL_DELETE;
    }
    else
    {
        operation.transfer = NFM_TRANSFER;
        operation.delete = NFM_DELETE_FILES;
    }

    operation.purge = NFM_PURGE;

    status = NFMRcheckout_item(catalog, -1, name, rev, 
                               working_area, wf_info, operation);
    if (status != NFM_S_SUCCESS)
    {
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
	return(status);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_set_checkout
Description: This funtion will perform a checkout on an NFM set.

Author: DB Access
Date: 27-Jul-90
*/
/*ARGSUSED*/
int dba_nfm_set_checkout(catalog, set_name, set_rev, level, storage,
                         node, user, passwd, path)
char *catalog, *set_name, *set_rev, *storage, *node, *user, *passwd, *path;
int level;
{
    int status;
    struct NFMwf_info wf_info;
    struct NFMoperation operation[2];
    char *working_area, temp_sa[32];

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    if (strcmp(storage, "DEFAULT") == 0)
    {
	status = dba_nfm_make_working_area(temp_sa);
        if (status)
        {
	    return(status);
        }
        
	status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }
    else if ((storage) && (strlen(storage) > 0))
    {
	working_area = storage;
    }
    else
    {
        status = dba_nfm_create_temporary_storage(node, user, path, temp_sa);
        if (status)
        {
            return(status);
        }
        
	status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }

    if (dba_nfm_workflow)
    {
        wf_info.workflow = NFM_WORKFLOW;
        strcpy(wf_info.command, CHECKOUT_SET);
        strcpy(wf_info.workflow_name, "NFM_ITEM_WORKFLOW");
        strcpy(wf_info.app_name, "NFM");
        wf_info.project_name[0] = '\0';
    }
    else
    {
	wf_info.workflow = NFM_NO_WORKFLOW;
    }
    if (dba_nfm_lfm) 
    {
        operation[0].transfer = NFM_CONDITIONAL_TRANSFER;
        operation[0].delete = NFM_CONDITIONAL_DELETE;
    }
    else
    {
        operation[0].transfer = NFM_TRANSFER;
        operation[0].delete = NFM_DELETE_FILES;
    }
    operation[0].purge = NFM_PURGE;

    strcpy(operation[0].catalog, catalog);
    operation[0].catalog_no = -1;
    operation[0].item_name[0] = '\0';
    operation[0].item_rev[0] = '\0';

    memset(&operation[1], 0 , sizeof(struct NFMoperation));

    status = NFMRcheckout_set(catalog, -1, set_name, set_rev, -1,
                              working_area, wf_info, NFM_SAME_OPERATION,
                              operation, -1);

    if (status != NFM_S_SUCCESS)
    {
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
	return(status);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_add_item

Description: This function is used to add an item to an NFM catalog.

Author: DB Access
Date: 27-Aug-90
*/
int dba_nfm_add_item(catalog, name, rev, desc, aclno, version_limit,
                     cisano, filename, ci_filename, file_type)
char *catalog, *name, *rev, *desc, *filename, *ci_filename, *file_type;
int aclno, version_limit, cisano;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, num_attrs;
    MSGptr app_ptr;
    char **attributes, string[128];
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, ADD_ITEM, "", "",
                                      catalog, "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRquery_add_item_attributes(dba_nfm_userid, catalog,
               &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    MEMbuild_array(data_buffer);

    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    for (i = 0; i < num_attrs; ++i)
    {
	if (strcmp(attributes[i], "n_itemname") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   name, 1, i + 1);

        }
	if (strcmp(attributes[i], "n_itemrev") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   rev, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_itemdesc") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   desc, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_aclno") == 0)
        {
            sprintf(string, "%d", aclno);
	    status = MEMwrite_data(data_buffer, string, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_versionlimit") == 0)
        {
            sprintf(string, "%d", version_limit);
	    status = MEMwrite_data(data_buffer, string, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_cisano") == 0)
        {
            sprintf(string, "%d", cisano);
	    status = MEMwrite_data(data_buffer, string, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_cofilename") == 0)
        {
            if ((filename) && (strlen(filename) > 0))
            {
	        status = MEMwrite_data(data_buffer, 
                                       filename, 1, i + 1);
            }
        }
        if (strcmp(attributes[i], "n_cifilename") == 0)
        {
            if (ci_filename) {
	        status = MEMwrite_data(data_buffer, ci_filename, 
                                       1, i + 1);
	    }
        }
        if (strcmp(attributes[i], "n_filetype") == 0)
        {
            if (file_type) {
	        status = MEMwrite_data(data_buffer, file_type, 
                                       1, i + 1);
	    }
        }

    }
/*
	Add the item
*/
    status = NFMRadd_item(dba_nfm_userid, catalog, attr_buffer,
                          data_buffer);
    app_ptr.error_no = status;    
    ERRget_message(dba_nfm_error_message);
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}

/*
Function: dba_nfm_copy_new_item

Description: This function is used to copy an existing NFM item and
             its associated files. A new item is generated.

Author: DB Access
Date: 27-May-92
*/
int dba_nfm_copy_new_item(catalog, name, rev, new_catalog, new_name, new_rev,
                          new_cofilename, new_cifilename, new_storage)
char *catalog, *name, *rev, *new_catalog, *new_name, *new_rev,
     *new_cofilename, *new_cifilename, *new_storage;
{
    MEMptr attr_buffer = NULL;
    MEMptr data_buffer = NULL;
    MEMptr value_buffer = NULL;
    MEMptr attr_f_buffer = NULL;
    MEMptr  data_f_buffer = NULL;
    MEMptr  value_f_buffer = NULL;
    int status,i,j,num_attrs, action_col = NULL, num_rows, curr_row;
    int intFile_col = 0, newSind = -1;
    MSGptr app_ptr;
    char **attributes, **datas;
    char new_sano[32];

char   **data_ptr;
char   **column_ptr;
char   **format_ptr;
char   **column;
char   **f_data;
char   **format;
MEMptr data_f_list2 = NULL;

long   offset ;
char   *sql_str ;

static char *fname = "NFAcopy_item";
char *debug_file_name = "/usr/tmp/dba.out";


strncpy (_NFMdebug_st.NFMRdebug_file, debug_file_name, NFM_DEBUG_FILE_SIZE);
_NFMdebug_st.NFMRdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';
strncpy (_NFMdebug_st.MEMdebug_file, debug_file_name, NFM_DEBUG_FILE_SIZE);
_NFMdebug_st.MEMdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }

    dba_nfm_default_schema();

    status = NFMRvalidate_user_access(dba_nfm_userid, COPY_ITEM, "", "",
                                      catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRget_item_attr_for_copy(catalog, name, rev, 
               &attr_buffer, &data_buffer, &value_buffer,
               &attr_f_buffer, &data_f_buffer, &value_f_buffer);

    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&attr_buffer);
        MEMclose (&data_buffer);
        MEMclose (&value_buffer);
        MEMclose (&attr_f_buffer);
        MEMclose (&data_f_buffer);
        MEMclose (&value_f_buffer);
	return(status);
    }
    
    status = MEMbuild_array(attr_buffer);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&attr_buffer);
        return(status);
    }

    status = MEMbuild_array(data_buffer);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&data_buffer);
        return(status);
    }

    status = MEMbuild_array(data_f_buffer);
    if (status !=  MEM_S_SUCCESS)
    {
        MEMclose (&attr_buffer);
        return(status);
    }
       
    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    for (i = 0; i < num_attrs; ++i)
    {
        if (strcmp(attributes[i], "n_itemname") == 0)
        {
            status = MEMwrite_data(data_buffer,
                                   new_name, 1, i + 1);
 
        }
        if (strcmp(attributes[i], "n_itemrev") == 0)
        {
            status = MEMwrite_data(data_buffer,
                                   new_rev, 1, i + 1);
        }
    }
 
    NFMRtic_it( data_buffer);

    attributes = (char **) data_f_buffer->column_ptr;
    num_attrs = data_f_buffer->columns;

  for (curr_row = 0; curr_row < data_f_buffer->rows; curr_row++) 
  {
    for (i = 0; i < num_attrs; ++i)
    {
        if (strcmp(attributes[i], "n_action") == 0)
        {
            if ((new_cifilename) && (strlen(new_cifilename) > 0))
                status = MEMwrite_data(data_f_buffer,
                                   "ADD", 1, i + 1);
            else
                status = MEMwrite_data(data_f_buffer,
                                   "ADD", 1 + curr_row, i + 1);
        }
 
        if (strcmp(attributes[i], "n_cifilename") == 0)
        {
/*tmpMahesh
            if ((new_cifilename) && (strlen(new_cifilename) > 0)){
                status = MEMwrite_data(data_f_buffer,
                                   new_cifilename, 1, i + 1);
            }
*/
                status = MEMwrite_data(data_f_buffer,
                                   new_cifilename, 1 + curr_row, i + 1);
        }
        if (strcmp(attributes[i], "n_cofilename") == 0)
        {
            if ((new_cofilename) && (strlen(new_cofilename) > 0)) {
                status = MEMwrite_data(data_f_buffer,
                                   new_cofilename, 1, i + 1);
            }
        }
        if (strcmp(attributes[i], "n_cisano") == 0)
        {
            if ((new_storage) && (strlen(new_storage) > 0)) {
                NFMRget_sa_no(dba_nfm_userid, new_storage, new_sano);
                status = MEMwrite_data(data_f_buffer,
                                   new_sano, 1, i + 1);
            }
        }
        NFMRtic_it( data_f_buffer);
    }
  }

/*Mahesh Not required since data_f_buffer modified to do well 


 if((status=MEMopen(&data_f_list2, 4*MEM_SIZE)) !=MEM_S_SUCCESS )
    {
       return(status);
    }

 f_data = (char **) data_f_buffer->data_ptr;
 column =( char **) data_f_buffer->column_ptr;
 format = (char **) data_f_buffer->format_ptr;

action_col = -1;

  for(i=0 ; i < data_f_buffer->columns; i++)
    {
       if (strcmp (column[i], "n_action") == 0)
       {
      status = MEMwrite_data(data_f_buffer,
                                   "ADD", 1, i + 1);
	 action_col = i ;
       }

     if((status = MEMwrite_format(data_f_list2,column[i],
                                      format[i])) != MEM_S_SUCCESS)
       {
          ERRload_struct(MEM,status,"",NULL);
          MEMclose(&data_f_list2);
          return(status);
       }
     }

    sql_str = (char *) malloc (data_f_buffer->columns*200) ;
   
    if(sql_str == NULL)
       {
         return(ERR_E_MALLOC);
       }
       
   for (i=0; i<data_f_buffer->rows; i++)
       {
         offset = i*data_f_buffer->columns ;
   
         if (strcmp (f_data[offset+action_col], "ADD") == 0)
         {
	   sql_str [0] = 0 ;
	   for (j=0; j<data_f_buffer->columns; j++)
	     {
	       strcat (sql_str, f_data[offset+j]) ;		
	       strcat (sql_str, "\001") ;
	     }
 
	   status = MEMwrite (data_f_list2, sql_str) ;
	   if (status != MEM_S_SUCCESS)
            {
               free (sql_str) ;
               return (status) ;
            }
          }
        }


        free (sql_str);

End Mahesh */

    status = NFMRcopy_item_n(new_catalog, attr_buffer,
                          data_buffer, attr_f_buffer, data_f_buffer);

    app_ptr.error_no = status;    
    ERRget_message(dba_nfm_error_message);
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&data_f_buffer);
    MEMclose(&value_buffer);
    MEMclose(&data_f_list2);

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_add_set

Description: This function is used to add a set to an NFM catalog.

Author: DB Access
Date: 27-Aug-90
*/
int dba_nfm_add_set(catalog, set_name, set_rev, desc, 
                    aclno, version_limit, cisano)
char *catalog, *set_name, *set_rev, *desc;
int aclno, version_limit, cisano;
{
    int status, i, num_attrs;
    char **attributes, string[128];
    MSGptr app_ptr;
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, ADD_SET, "", "",
                                      catalog, "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRquery_add_set_attributes(dba_nfm_userid, catalog,
               &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    MEMbuild_array(data_buffer);
    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    for (i = 0; i < num_attrs; ++i)
    {
	if (strcmp(attributes[i], "n_itemname") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   set_name, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_itemrev") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   set_rev, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_itemdesc") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   desc, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_aclno") == 0)
        {
            sprintf(string, "%d", aclno);
	    status = MEMwrite_data(data_buffer, string, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_versionlimit") == 0)
        {
            sprintf(string, "%d", version_limit);
	    status = MEMwrite_data(data_buffer, string, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_cisano") == 0)
        {
            sprintf(string, "%d", cisano);
	    status = MEMwrite_data(data_buffer, string, 1, i + 1);
        }
    }
/*
	Add the set
*/
    status = NFMRadd_item(dba_nfm_userid, catalog, attr_buffer,
                          data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}

/*
Function: dba_nfm_add_to_set2

Description: This function is used to add a an item to a set, it also
             supports having the set and the items in different
             catalogs. This function makes dba_nfm_add_to_set obsolete
             and it should be removed from the documentation.

Author: DB Access
Date: 15-Aug-92
*/
int dba_nfm_add_to_set2(set_catalog, set_name, set_rev, 
                        catalog, name, rev, type)
char *set_catalog, *set_name, *set_rev, *catalog, *name, *rev, *type;
{
    int status;
    struct NFMmember_info member_info[2];
    MSGptr app_ptr;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, DEFINE_SET_MEMBERS, 
                                      "", "", set_catalog, set_name, set_rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
/*
	Add the item to the set
*/
    member_info[0].operation = NFM_ADD_MEMBER;
    member_info[0].citno = -1;
    strcpy(member_info[0].catalog_name, catalog);
    member_info[0].catalog_no = -1;
    strcpy(member_info[0].item_name, name);
    strcpy(member_info[0].item_rev, rev);
    member_info[0].item_no =  -1;    
    strcpy(member_info[0].type, type);
    memset(&member_info[1], 0 , sizeof(struct NFMmember_info));

    status = NFMRdefine_set_information(set_catalog, -1, set_name,
                                        set_rev, NFM_NO_FILE_STATUS_CHECK,
                                        1, member_info);

    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}
/*
Function: dba_nfm_add_to_set

Description: This function is used to add a an item to a set.

Author: DB Access
Date: 27-Aug-90
*/
int dba_nfm_add_to_set(catalog, set_name, set_rev, name, rev, type)
char *catalog, *set_name, *set_rev, *name, *rev, *type;
{
    int status;
    status = dba_nfm_add_to_set2(catalog, set_name, set_rev, 
                                 catalog, name, rev, type);
    return(status);
}

/*
Function: dba_nfm_create_catalog

Description: This function is used to add a catalog to an NFM database.

Author: DB Access
Date: 27-Aug-90
*/
int dba_nfm_create_catalog(catalog, desc, aclno)
char *catalog, *desc;
int aclno;

{
    int status, rows, cols, row_ndx;
    char string[128], loc_name[21], **column, **data_ptr;
    MSGptr app_ptr;
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL,
           loc_attr = NULL, loc_data = NULL, loc_value = NULL;
    NDXptr index;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, CREATE_CATALOG, "", "",
                                      "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    loc_name[0] = '\0';
    status = NFMRquery_addto_loc_attributes(dba_nfm_userid,
               loc_name, &loc_attr, &loc_data, &loc_value);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    MEMbuild_array(loc_attr);
    MEMbuild_array(loc_data);

    column =  (char **) loc_data->column_ptr;
    cols = loc_attr->columns;
    rows = loc_attr->rows;
    data_ptr = (char **) loc_attr->data_ptr;

    NFMRfill_index(loc_attr, &index);

    for (row_ndx = 0; row_ndx < rows; ++row_ndx)
    {
	if (strcmp(data_ptr[row_ndx*cols+index.name], "n_catalogname") == 0)
        {
	    status = MEMwrite_data(loc_data, 
                                   catalog, 1, row_ndx+1);
        }

	if (strcmp(data_ptr[row_ndx*cols+index.name], "n_catalogdesc") == 0)
        {
	    status = MEMwrite_data(loc_data, 
                                   desc, 1, row_ndx+1);
        }

	if (strcmp(data_ptr[row_ndx*cols+index.name], "n_application") == 0)
        {
	    status = MEMwrite_data(loc_data, 
                                   "NFM", 1, row_ndx+1);
        }

	if (strcmp(data_ptr[row_ndx*cols+index.name], "n_type") == 0)
        {
	    status = MEMwrite_data(loc_data, 
                                   "NFM", 1, row_ndx+1);
        }

	if (strcmp(data_ptr[row_ndx*cols+index.name], "n_aclno") == 0)
        {
            sprintf(string, "%d", aclno);
	    status = MEMwrite_data(loc_data, 
                                   string, 1, row_ndx+1);
        }
    }
    MEMbuild_array(loc_attr);
    MEMbuild_array(loc_data);

    status = NFMRquery_catalog_template(dba_nfm_userid,
               &attr_buffer, &data_buffer, &value_buffer);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    MEMbuild_array(attr_buffer);
    MEMbuild_array(data_buffer);
/*
	Create the Catalog
*/
    status = NFMRcreate_catalog(dba_nfm_userid, loc_attr, loc_data, 
                                attr_buffer, data_buffer, value_buffer);

    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;

    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    if (status != NFM_S_SUCCESS) {
        app_ptr.error_no = status;
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
    }

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    MEMclose(&loc_attr);
    MEMclose(&loc_data);
    MEMclose(&loc_value);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_add_user

Description: This function is used to add a user to NFM.

Author: DB Access
Date: 19-Jan-91
*/
int dba_nfm_add_user(user, passwd, desc, path)
char *user, *passwd, *desc, *path;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, num_attrs;
    MSGptr app_ptr;
    char **attributes;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, ADD_USER, "", "",
                                      "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRquery_add_user_attributes(dba_nfm_userid,
               &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    MEMbuild_array(data_buffer);
    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    for (i = 0; i < num_attrs; ++i)
    {
	if (strcmp(attributes[i], "n_username") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   user, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_passwd") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   passwd, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_userdesc") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   desc, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_emailaddr") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   path, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_application") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   "NFM", 1, i + 1);
        }
    }
/*
	Add the user
*/
    status = NFMRadd_user(dba_nfm_userid, attr_buffer, data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}
/*
Function: dba_nfm_change_user_passwd

Description: This function

Author: DB Access
Date: 19-Jan-91
*/
int dba_nfm_change_user_passwd(user, passwd, new_passwd)
char *user, *passwd, *new_passwd;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status;
    MSGptr app_ptr;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    if (NFMRglobal.administrator)
    {
        status = NFMRvalidate_user_access(dba_nfm_userid, 
                                          CHG_USER_PASSWD, "", "","", "", "");
    }
    else
    {
        status = NFMRvalidate_user_access(dba_nfm_userid, 
                                          CHANGE_PASSWD, "", "","", "", "");
    }
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
/*
	Change the user passwd
*/
    status = NFMRchange_user_passwd(dba_nfm_userid, user,
                passwd, new_passwd);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_add_storage_area

Description: This function is used to add a storage area to NFM

Author: DB Access
Date: 19-Jan-91
*/
int dba_nfm_add_storage_area(storage, node, user, passwd, path, type,
                             sa_type, owner)
char *storage, *node, *user, *passwd, *path, *type, *sa_type, *owner;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, num_attrs;
    MSGptr app_ptr;
    char **attributes, node_num[32], owner_no[32];

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, ADD_SA, "", "",
                                      "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRquery_add_st_area_attributes(dba_nfm_userid,
               &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    MEMbuild_array(data_buffer);
    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    for (i = 0; i < num_attrs; ++i)
    {
	if (strcmp(attributes[i], "n_saname") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   storage, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_nodeno") == 0)
        {
	    status = NFMRget_node_no(dba_nfm_userid, node, node_num);
	    status = MEMwrite_data(data_buffer, node_num, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_username") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   user, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_passwd") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   passwd, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_pathname") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   path, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_devicetype") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   type, 1, i + 1);
        }
        if (sa_type) {
	    if (strcmp(attributes[i], "n_type") == 0)
            {
	        status = MEMwrite_data(data_buffer, 
                                       sa_type, 1, i + 1);
            }
        }
        if (owner) {
	    if (strcmp(attributes[i], "n_owner") == 0)
            {
                NFMRget_user_no(dba_nfm_userid, owner, owner_no);
	        status = MEMwrite_data(data_buffer, 
                                       owner_no, 1, i + 1);
            }
        }

    }
/*
	Add the storage area
*/
    status = NFMRadd_storage_area(dba_nfm_userid, attr_buffer, data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;

    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}

/*
Function: dba_nfm_delete_item

Description: This function is used to add an item to an NFM catalog.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_delete_item(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, DELETE_ITEM, "", "",
                                      catalog, name,
                                      rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
/*
	Delete the item
*/
    status = NFMRdelete_item(dba_nfm_userid, catalog, name,
                             rev);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}


/*
Function: dba_nfm_flag_item_delete

Description: This function is used to add an item to an NFM catalog.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_flag_item_delete(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, FLAG_ITEM_DELETE, "", "",
                                      catalog, name,
                                      rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRflag_item_delete(dba_nfm_userid, catalog, 
                                  name, rev);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_cancel_item_delete

Description: This function is used to cancel a delete flag on an NFM catalog.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_cancel_item_delete(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, CANCEL_ITEM_DELETE_FLAG,
                                       "", "", catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();

    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRcancel_item_delete_flag(dba_nfm_userid, catalog, 
                                  name, rev);

    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_flag_item_backup

Description: This function is used to flag an item for backup.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_flag_item_backup(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, FLAG_ITEM_BACKUP, "", "",
                                      catalog, name,
                                      rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRflag_item_backup(dba_nfm_userid, catalog, 
                                  name, rev);
    
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;

    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_cancel_item_backup

Description: This function is used to cancel the backup flag on an NFM item.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_cancel_item_backup(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, CANCEL_ITEM_BACKUP_FLAG,
                                      "", "", catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRcancel_item_backup_flag(dba_nfm_userid, catalog, 
                                         name, rev);
    
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_delete_catalog

Description: This function is used to delete a catalog.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_delete_catalog(catalog)
char *catalog;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, DELETE_CATALOG, "", "",
                                      catalog, "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
/*
	Delete the catalog
*/
    status = NFMRdelete_catalog(dba_nfm_userid, catalog);

    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_delete_storage_area

Description: This function is used to delete a catalog.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_delete_storage_area(storage)
char *storage;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, DELETE_SA, "", "",
                                      "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
/*
	Delete the storage_area
*/
    status = NFMRdelete_storage_area(dba_nfm_userid, storage);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}
/*
Function: dba_nfm_delete_user

Description: This function is used to delete an NFM user.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_delete_user(user)
char *user;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, DELETE_USER, "", "",
                                      "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
/*
	Delete the catalog
*/
    status = NFMRdelete_user(dba_nfm_userid, user);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}

/*
Function: dba_nfm_load_workflow

Description: This function is used to add an item to an NFM catalog.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_load_workflow(app, wfname)
char *app, *wfname;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, LOAD_WORKFLOW, "", "",
                                      "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
/*
	Load the Workflow
*/
    status = NFMRload_workflow(dba_nfm_userid, app, wfname);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}

/*
Function: dba_nfm_add_acl

Description: This function is used to add an acl to NFM

Author: DB Access
Date: 19-Jan-91
*/
int dba_nfm_add_acl(wfname, aclname)
char *wfname, *aclname;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, num_attrs;
    MSGptr app_ptr;
    char **attributes, wf_num[32];

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, ADD_ACL,"","","","","");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRquery_acl_attributes(dba_nfm_userid,
                  &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    MEMbuild_array(attr_buffer);
    MEMbuild_array(data_buffer);

    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    for (i = 0; i < num_attrs; ++i)
    {
	if (strcmp(attributes[i], "n_aclname") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   aclname, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_workflowno") == 0)
        {
	    status = NFMRget_workflow_no(dba_nfm_userid, wfname, wf_num);
	    status = MEMwrite_data(data_buffer, wf_num, 1, i + 1);
        }
    }
/*
	Add the acl
*/
    status = NFMRadd_acl(dba_nfm_userid, attr_buffer, data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}

/*
Function: dba_nfm_add_acl_user

Description: This function is used to add an acl user

Author: DB Access
Date: 19-Jan-91
*/
int dba_nfm_add_acl_user(aclname, class, user, wfname)
char *aclname, *class, *user, *wfname;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, num_attrs;
    MSGptr app_ptr;
    char **attributes, class_num[32], user_num[32], acl_num[32], wf_num[32];
    char buffstr[128];
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, ADD_ACL_USER, "", "",
                                      "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRquery_acl_class_users(dba_nfm_userid, aclname,
                  &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    MEMbuild_array(attr_buffer);
    MEMbuild_array(data_buffer);

    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    buffstr[0] = '\0';
    for (i = 0; i < num_attrs; ++i)
    {
	if (strcmp(attributes[i], "n_aclno") == 0)
        {
            status = NFMRget_acl_no(dba_nfm_userid, aclname, acl_num);
            strcat(buffstr, acl_num);
        }
	if (strcmp(attributes[i], "n_classno") == 0)
        {
	    status = NFMRget_workflow_no(dba_nfm_userid, 
                            wfname, wf_num);

	    status = NFMRget_class_no(dba_nfm_userid, wf_num, class, 
                                      class_num);
            strcat(buffstr, class_num);
        }
	if (strcmp(attributes[i], "n_userno") == 0)
        {
	    status = NFMRget_user_no(dba_nfm_userid, user, user_num);
            strcat(buffstr, user_num);
        }
	if (strcmp(attributes[i], "n_status") == 0)
        {
            strcat(buffstr, "ADD");
        }
        strcat(buffstr, "\1");
    }
    status = MEMwrite(data_buffer, buffstr);
/*
	Add the acl users
*/
    status = NFMRupdate_acl_class_users(dba_nfm_userid, 
                                        attr_buffer, data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_delete_acl_user

Description: This function delete a user from the acl

Author: DB Access
Date: 17-Dec-91
*/
int dba_nfm_delete_acl_user(aclname, class, user, wfname)
char *aclname, *class, *user, *wfname;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, num_attrs, stat_col=0, acl_col=0, class_col=0, user_col=0,
        curr_row, num_rows, user_found, t1;
    MSGptr app_ptr;
    char **attributes, **datas, class_num[32], user_num[32], 
         acl_num[32], wf_num[32];

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, DELETE_ACL_USER, "", "",
                                      "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRquery_acl_class_users(dba_nfm_userid, aclname,
                  &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    MEMbuild_array(attr_buffer);
    MEMbuild_array(data_buffer);

    status = NFMRget_acl_no(dba_nfm_userid, aclname, acl_num);
    status = NFMRget_workflow_no(dba_nfm_userid, wfname, wf_num);
    status = NFMRget_class_no(dba_nfm_userid, wf_num, class, 
                              class_num);
    status = NFMRget_user_no(dba_nfm_userid, user, user_num);

    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    for (i = 0; i < num_attrs; ++i)
    {
	if (strcmp(attributes[i], "n_status") == 0)
        {
	    stat_col = i;
        }
	if (strcmp(attributes[i], "n_aclno") == 0)
        {
	    acl_col = i;
        }
	if (strcmp(attributes[i], "n_classno") == 0)
        {
	    class_col = i;
        }
	if (strcmp(attributes[i], "n_userno") == 0)
        {
	    user_col = i;
        }
    }

    datas = (char **) data_buffer->data_ptr;
    num_rows = data_buffer->rows;
    curr_row = 0;

    user_found = FALSE;

    while (curr_row < num_rows)
    {
	t1 = curr_row * num_attrs;
        if (strcmp(datas[t1 + acl_col], acl_num) == 0)
        {
	    if (strcmp(datas[t1 + user_col], user_num) == 0)
            {
	        if (strcmp(datas[t1 + class_col], class_num) == 0)
                {
	            MEMwrite_data(data_buffer, "DROP", curr_row + 1, 
                                  stat_col + 1);
                    user_found = TRUE;
                    break;
                }
            }
         }
         ++curr_row;
    }
    if (!user_found) /* FRANK what about closing memory */
    {
        strcpy(dba_nfm_error_message, "Invalid User");
	return(DBA_NFM_INVALID_USER);
    }
/*
	Delete the acl user
*/
    status = NFMRupdate_acl_class_users(dba_nfm_userid, 
                                        attr_buffer, data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}
/*
Function: dba_nfm_get_message

Description: This funtion is used to get the latest message from
             the NFM system. Presumably if an error has just occurred.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_get_message(message)
char *message;
{
    strcpy(message, dba_nfm_error_message);
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_cancel_item

Description: This function is used to cancel the checkout of an item

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_cancel_item(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    struct NFMwf_info wf_info;
    struct NFMoperation operation;

    if (!dba_nfm_active)
    {
        status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
            return(status);
        }
    }
    dba_nfm_default_schema();


    if (dba_nfm_workflow)
    {
        wf_info.workflow = NFM_WORKFLOW;
        strcpy(wf_info.command, CANCEL_ITEM_CHECKOUT);
        strcpy(wf_info.workflow_name, "NFM_ITEM_WORKFLOW");
        strcpy(wf_info.app_name, "NFM");
        wf_info.project_name[0] = '\0';
    }
    else
    {
	wf_info.workflow = NFM_NO_WORKFLOW;
    }

    if (dba_nfm_lfm) 
    {
        operation.transfer = NFM_CONDITIONAL_TRANSFER;
        operation.delete = NFM_CONDITIONAL_DELETE;
    }
    else
    {
        operation.transfer = NFM_TRANSFER;
        operation.delete = NFM_DELETE_FILES;
    }

    operation.purge = NFM_PURGE;
/*
        Cancel the checkout
*/
    status = NFMRcancel_check_out_item(catalog, -1, name, rev, wf_info,
                                       operation);
    if (status != NFM_S_SUCCESS)
    {
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
	return(status);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_cancel_set

Description: This function is used to cancel the checkout of an item

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_cancel_set(catalog, set_name, set_rev)
char *catalog, *set_name, *set_rev;
{
    int status;
    struct NFMwf_info wf_info;
    struct NFMoperation operation[2];

    if (!dba_nfm_active)
    {
        status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
            return(status);
        }
    }
    dba_nfm_default_schema();


    if (dba_nfm_workflow)
    {
        wf_info.workflow = NFM_WORKFLOW;
        strcpy(wf_info.command, CANCEL_SET_CHECKOUT);
        strcpy(wf_info.workflow_name, "NFM_ITEM_WORKFLOW");
        strcpy(wf_info.app_name, "NFM");
        wf_info.project_name[0] = '\0';
    }
    else
    {
	wf_info.workflow = NFM_NO_WORKFLOW;
    }

    if (dba_nfm_lfm) 
    {
        operation[0].transfer = NFM_CONDITIONAL_TRANSFER;
        operation[0].delete = NFM_CONDITIONAL_DELETE;
    }
    else
    {
        operation[0].transfer = NFM_TRANSFER;
        operation[0].delete = NFM_DELETE_FILES;
    }

    operation[0].purge = NFM_PURGE;
    strcpy(operation[0].catalog, catalog);
    operation[0].catalog_no = -1;
    operation[0].item_name[0] = '\0';
    operation[0].item_rev[0] = '\0';

    memset(&operation[1], 0 , sizeof(struct NFMoperation));
/*
        Cancel the checkout
*/
    status = NFMRcancel_check_out_set(catalog, -1, set_name, set_rev, -1, 
                    wf_info, NFM_SAME_OPERATION, operation, -1);
    if (status != NFM_S_SUCCESS)
    {
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
	return(status);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_make_transition

Description: This function is used to make transitions from one state
             to another.

Author: DB Access
Date: 25-Jul-91
*/
int dba_nfm_make_transition(catalog, name, rev, state)
char *catalog, *name, *rev, *state;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, num_attrs = 0, num_rows = 0, name_col = 0,
        stat_col = 0, curr_row, t1, state_found;
    MSGptr app_ptr;
    char **attributes, **datas;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, MAKE_TRANSITION, "", "",
                                      catalog, name,
                                      rev);

    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();

    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRquery_make_transition(dba_nfm_userid, &attr_buffer, 
                                       &data_buffer);

    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();

    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    MEMbuild_array(data_buffer);

    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    for (i = 0; i < num_attrs; ++i)
    {
	if (strcmp(attributes[i], "n_status") == 0)
        {
	    stat_col = i;
        }
	if (strcmp(attributes[i], "n_statename") == 0)
        {
	    name_col = i;
        }
    }

    datas = (char **) data_buffer->data_ptr;
    num_rows = data_buffer->rows;
    curr_row = 0;

    state_found = FALSE;
    while (curr_row < num_rows)
    {
	t1 = curr_row * num_attrs;
        if (strncmp(datas[t1 + name_col], 
            state, strlen(state)) == 0)
        {
	    MEMwrite_data(data_buffer, "NEXT", curr_row + 1, stat_col + 1);
            state_found = TRUE;
            break;
        }
        ++curr_row;
    }

    if (!state_found) /* FRANK what about closing memory */
    {
        strcpy(dba_nfm_error_message, "Invalid State");
        MEMclose(&attr_buffer);
        MEMclose(&data_buffer);
        MEMclose(&value_buffer);
	return(DBA_NFM_INVALID_STATE);
    }
/*
	Make the Transition
*/
    status = NFMRmake_transition(dba_nfm_userid, attr_buffer, data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    if (status != NFM_S_SUCCESS) {
        app_ptr.error_no = status;
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
    }

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_signoff

Description: This function is used to signoff on an NFM item.

Author: DB Access
Date: 25-Apr-92
*/
int dba_nfm_signoff(catalog, name, rev)
char *catalog, *name, *rev;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status;
    MSGptr app_ptr;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, SIGNOFF_ITEM, "", "",
                                      catalog, name,
                                      rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRquery_signoff_attributes(dba_nfm_userid, &attr_buffer, 
                                       &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    MEMbuild_array(data_buffer);
    status = NFMRsignoff(dba_nfm_userid, attr_buffer, data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_build_set_list

Description: This function adds an item name to the list used by add list
             to set. Call this function for each item when building a
             set then call dba_nfm_add_list_to_set.

Author: DB Access

Date: 25-Sep-91
*/
int dba_nfm_build_set_list(name, rev, type)
char *name, *rev, *type;
{
    int status;
    status = dba_nfm_build_set_list2("", name, rev, type);
    return(status);
}

/*
Function: dba_nfm_build_set_list2

Description: This function adds a item name to the list used by add list
             to set. Call this function for each item when building a
             set then call dba_nfm_add_list_to_set. This function also
             supports adding items when the set and the item are in
             different catalogs. This function makes dba_nfm_build_set_list
             obsolete and it should be removed from the documentation.

Author: DB Access

Date: 25-Sep-91
*/
int dba_nfm_build_set_list2(catalog, name, rev, type)

char *catalog, *name, *rev, *type;
{
    if (!dba_nfm_num_items)
    {
	dba_nfm_member_info = 
                (struct NFMmember_info *)malloc(sizeof(struct NFMmember_info));
    }
    else
    {
	dba_nfm_member_info = 
              (struct NFMmember_info *)realloc(dba_nfm_member_info, 
              (dba_nfm_num_items + 1) * sizeof(struct NFMmember_info));
    }
    dba_nfm_member_info[dba_nfm_num_items].operation = NFM_ADD_MEMBER;
    dba_nfm_member_info[dba_nfm_num_items].citno = -1;
    strcpy(dba_nfm_member_info[dba_nfm_num_items].catalog_name, catalog);
    dba_nfm_member_info[dba_nfm_num_items].catalog_no = -1;
    strcpy(dba_nfm_member_info[dba_nfm_num_items].item_name, name);
    strcpy(dba_nfm_member_info[dba_nfm_num_items].item_rev, rev);
    dba_nfm_member_info[dba_nfm_num_items].item_no =  -1;    
    strcpy(dba_nfm_member_info[dba_nfm_num_items].type, type);
    ++dba_nfm_num_items;
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_add_list_to_set

Description: This function is used to add a list of items to a set.

Author: DB Access
Date: 25-Sep-91
*/
int dba_nfm_add_list_to_set(set_catalog, set_name, set_rev)

char *set_catalog, *set_name, *set_rev;
{
    int status, i;
    struct NFMmember_info *mi;

    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
            dba_nfm_free_items();
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, DEFINE_SET_MEMBERS, 
                                      "", "", set_catalog, set_name, set_rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
        dba_nfm_free_items();
	return(status);
    }
/*
	If the catalog for the items is not
        defined it is because it was done with build_set_list so
        make it the same as the set catalog
*/
    mi = dba_nfm_member_info;
    for (i = 0; i < dba_nfm_num_items; ++i)
    {
	if (strlen(mi->catalog_name) == 0)
        {
	    strcpy(mi->catalog_name, set_catalog);
        }
        ++mi;
    }
/*
	Add the items to the set
*/
    status = NFMRdefine_set_information(set_catalog, -1, set_name,
                                        set_rev, NFM_NO_FILE_STATUS_CHECK,
                                        dba_nfm_num_items, dba_nfm_member_info);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        dba_nfm_free_items();
        return(app_ptr.error_no);
    }
    dba_nfm_free_items();
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_drop_set

Description: This function is used to drop all the items from a set.

Author: DB Access
Date: 25-Sep-91
*/
int dba_nfm_drop_set(set_catalog, set_name, set_rev)
char *set_catalog, *set_name, *set_rev;
{
    int status, i, num_attrs, cat_col = 0, rev_col=0, item_col=0, 
        curr_row, num_rows, t1;
    char **attributes, **datas;
    struct NFMmember_info *member_info;

    MSGptr app_ptr;
    MEMptr attr_buffer = NULL, data_buffer = NULL;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
            dba_nfm_free_items();
	    return(status);
        }
    }
    dba_nfm_default_schema();

    status = NFMRvalidate_user_access(dba_nfm_userid, DEFINE_SET_MEMBERS, 
                                      "", "", set_catalog, set_name, set_rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRquery_set_members(dba_nfm_userid, set_catalog,
                      set_name, set_rev, 
                      -1, 0, &attr_buffer, &data_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    MEMbuild_array(data_buffer);

    datas = (char **) data_buffer->data_ptr;
    num_rows = data_buffer->rows;
    if (!num_rows) return(DBA_NFM_SUCCESS);

    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    for (i = 0; i < num_attrs; ++i)
    {
	if (strcmp(attributes[i], "n_catalogname") == 0)
        {
	    cat_col = i;
        }
	if (strcmp(attributes[i], "n_itemname") == 0)
        {
	    item_col = i;
        }
	if (strcmp(attributes[i], "n_itemrev") == 0)
        {
	    rev_col = i;
        }
    }
    member_info = (struct NFMmember_info *) 
               malloc(sizeof (struct NFMmember_info) * num_rows);
    curr_row = 1;
    while (curr_row < num_rows)
    {
	t1 = curr_row * num_attrs;
        member_info[curr_row - 1].operation = NFM_DROP_MEMBER;
        member_info[curr_row - 1].citno = -1;
        strcpy(member_info[curr_row - 1].catalog_name, datas[t1 + cat_col]);
        member_info[curr_row - 1].catalog_no = -1;
        strcpy(member_info[curr_row - 1].item_name, datas[t1 + item_col]);
        strcpy(member_info[curr_row - 1].item_rev, datas[t1 + rev_col]);
        member_info[curr_row - 1].item_no =  -1;    
        strcpy(member_info[curr_row - 1].type, "");
        ++curr_row;
    }
    status = NFMRdefine_set_information(set_catalog, -1, set_name,
                                        set_rev, NFM_NO_FILE_STATUS_CHECK,
                                        num_rows - 1, member_info);
    free(member_info);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_drop_from_set

Description: This function is used to drop an item from a set.

Author: DB Access
Date: 25-Sep-91
*/
int dba_nfm_drop_from_set(catalog, set_name, set_rev, item_name, item_rev)
char *catalog, *set_name, *set_rev, *item_name, *item_rev;
{
    int status;
    status = dba_nfm_drop_from_set2(catalog, set_name, set_rev, 
                               catalog, item_name, item_rev);
    return(status);
}
/*
Function: dba_nfm_drop_from_set2

Description: This function is used to drop an item from a set. It also 
             supports having the items and the set in different catalogs.

Author: DB Access
Date: 25-Sep-91
*/

int dba_nfm_drop_from_set2(set_catalog, set_name, set_rev, 
                           catalog, name, rev)
char *set_catalog, *set_name, *set_rev, *catalog, *name, *rev;
{
    int status;
    struct NFMmember_info member_info[2];
    MSGptr app_ptr;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
            dba_nfm_free_items();
	    return(status);
        }
    }

    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, DEFINE_SET_MEMBERS, 
                                      "", "", set_catalog, set_name, set_rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    member_info[0].operation = NFM_DROP_MEMBER;
    member_info[0].citno = -1;
    strcpy(member_info[0].catalog_name, catalog);
    member_info[0].catalog_no = -1;
    strcpy(member_info[0].item_name, name);
    strcpy(member_info[0].item_rev, rev);
    member_info[0].item_no =  -1;    
    strcpy(member_info[0].type, "");
    memset(&member_info[1], 0 , sizeof(struct NFMmember_info));

    status = NFMRdefine_set_information(set_catalog, -1, set_name,
                                        set_rev, NFM_NO_FILE_STATUS_CHECK,
                                        1, member_info);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_free_items

Description: This function clears out the lists built by
             dba_nfm_build_set_list

Author: DB Access

Date: 10-Aug-91
*/
int dba_nfm_free_items()
{
    if (dba_nfm_member_info)
    {
        free(dba_nfm_member_info);
    }
    dba_nfm_num_items = 0;
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_add_file

Description: This function 

Author: DB Access
Date: 10-Mar-92
*/
int dba_nfm_add_file(catalog, name, rev, filename, storage, ci_filename,
                     file_type)
char *catalog, *name, *rev, *filename, *storage, *ci_filename, *file_type;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, num_attrs, num_rows;
    char **attributes, **value, str[1028], b1[2], **datas;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }

    dba_nfm_default_schema();
    status = NFMRget_file_information(catalog, name, rev, 
                       NFM_ADD_FILE_TO_ITEM, 
                       &attr_buffer, &data_buffer, &value_buffer);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();

    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    MEMbuild_array(data_buffer);

    datas = (char **)data_buffer->data_ptr;
    num_rows = data_buffer->rows;

    attributes = (char **)data_buffer->column_ptr;
    value = (char **) data_buffer->data_ptr;
    num_attrs = data_buffer->columns;

    str[0] = '\0';
    b1[0] = '\1';
    b1[1] = '\0';
    for (i = 0; i < num_attrs; ++i)
    {
	strcat(str, value[i]);
        strcat(str, b1);
    }

    status = MEMwrite(data_buffer, str);
    if (status != MEM_S_SUCCESS)
    {
        return(status);
    }
    MEMbuild_array(data_buffer);
    attributes = (char **)data_buffer->column_ptr;

    for (i = 0; i < num_attrs; ++i)
    {
        if (strcmp(attributes[i], "n_cofilename") == 0)
        {
	    status = MEMwrite_data
             (data_buffer, filename, num_rows + 1, i + 1);
        }
        if (strcmp(attributes[i], "n_cisaname") == 0)
        {
	    status = MEMwrite_data(data_buffer, storage, 
                                   num_rows + 1, i + 1);
        }
        if (strcmp(attributes[i], "n_cifilename") == 0)
        {
            if (ci_filename) {
	        status = MEMwrite_data(data_buffer, ci_filename, 
                                       num_rows + 1, i + 1);
	    }
        }
        if (strcmp(attributes[i], "n_filetype") == 0)
        {
            if (file_type) {
	        status = MEMwrite_data(data_buffer, file_type, 
                                       num_rows + 1, i + 1);
	    }
        }

    }

    status = NFMRdefine_file_information(catalog, name, rev, 
                         NFM_ADD_FILE_TO_ITEM, data_buffer);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();

    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_delete_file

Description: This function 

Author: DB Access
Date: 10-Mar-92
*/
int dba_nfm_delete_file(catalog, name, rev, filename)
char *catalog, *name, *rev, *filename;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, num_attrs, num_rows, stat_col = 0, name_col = 0, curr_row,
        t1, file_found;
    char **attributes, **value, **datas;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRget_file_information(catalog, name, rev, 
                       NFM_DELETE_FILE_FROM_ITEM, 
                       &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    MEMbuild_array(data_buffer);
    datas = (char **)data_buffer->data_ptr;
    num_rows = data_buffer->rows;
    curr_row = 0;

    file_found = FALSE;

    attributes = (char **)data_buffer->column_ptr;
    value = (char **) data_buffer->data_ptr;
    num_attrs = data_buffer->columns;

    for (i = 0; i < num_attrs; ++i)
    {
        if (strcmp(attributes[i], "n_cofilename") == 0)
        {
	    name_col = i;
	}
        if (strcmp(attributes[i], "n_status") == 0)
        {
	    stat_col = i;
        }
    }
    while (curr_row < num_rows)
    {
	t1 = curr_row * num_attrs;
        if (strcmp(datas[t1 + name_col], filename) == 0)
        {
	    MEMwrite_data(data_buffer, "Y", curr_row + 1, 
                                  stat_col + 1);
            file_found = TRUE;
            break;
        }
        ++curr_row;
    }

    if (!file_found) /* FRANK what about closing memory */
    {
        strcpy(dba_nfm_error_message, "File Not Found");
        status = NFMRreset_file_information(catalog, name, rev);
        if (status != NFM_S_SUCCESS)
        {
	    return(status);
        }
	return(DBA_NFM_INVALID_FILENAME);
    }

    status = NFMRdefine_file_information(catalog, name, rev, 
                         NFM_DELETE_FILE_FROM_ITEM, data_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_change_file

Description: This function 

Author: DB Access
Date: 10-Mar-92
*/
int dba_nfm_change_file(catalog, name, rev, filename, c_name, c_value)
char *catalog, *name, *rev, *filename, *c_name, *c_value;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, num_attrs, num_rows, stat_col = 0, name_col = 0, curr_row,
        t1, file_found, c_name_col = 0;
    char **attributes, **value, **datas;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRget_file_information(catalog, name, rev, 
                       NFM_CHANGE_FILE_INFORMATION, 
                       &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    MEMbuild_array(data_buffer);

    datas = (char **)data_buffer->data_ptr;
    num_rows = data_buffer->rows;
    curr_row = 0;

    file_found = FALSE;

    attributes = (char **)data_buffer->column_ptr;
    value = (char **) data_buffer->data_ptr;
    num_attrs = data_buffer->columns;

    for (i = 0; i < num_attrs; ++i)
    {
        if (strcmp(attributes[i], "n_cofilename") == 0)
        {
	    name_col = i;
	}
        if (strcmp(attributes[i], "n_status") == 0)
        {
	    stat_col = i;
        }
        if (strcmp(attributes[i], c_name) == 0)
        {
	    c_name_col = i;
        }
    }

    if (!c_name_col)
    {
        strcpy(dba_nfm_error_message, "Column Name Not Found");
        status = NFMRreset_file_information(catalog, name, rev);
        if (status != NFM_S_SUCCESS)
        {
	    return(status);
        }
	return(DBA_NFM_INVALID_COLUMN);
    }
/*
	If the filename is null then change the first one.
*/
    if ((!filename) || (strlen(filename) == 0))
    {
	MEMwrite_data(data_buffer, "Y", 1, stat_col + 1);
        MEMwrite_data(data_buffer, c_value, 1, c_name_col + 1);
    }
    else
    {
        while (curr_row < num_rows)
        {
	    t1 = curr_row * num_attrs;
            if (strcmp(datas[t1 + name_col], filename) == 0)
            {
	        MEMwrite_data(data_buffer, "Y", curr_row + 1, 
                                  stat_col + 1);
	        MEMwrite_data(data_buffer, c_value, curr_row + 1, 
                                  c_name_col + 1);
                file_found = TRUE;
                break;
            }
            ++curr_row;
        }
        if (!file_found) /* FRANK what about closing memory */
        {
            strcpy(dba_nfm_error_message, "File Not Found");
            status = NFMRreset_file_information(catalog, name, rev);
            if (status != NFM_S_SUCCESS)
            {
	        return(status);
            }
	    return(DBA_NFM_INVALID_FILENAME);
        }
    }
    status = NFMRdefine_file_information(catalog, name, rev, 
                         NFM_CHANGE_FILE_INFORMATION, data_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_change_item

Description: This function 

Author: DB Access
Date: 10-Sep-92
*/

int dba_nfm_change_item(catalog, name, rev, c_name, c_value)
char *catalog, *name, *rev, *c_name, *c_value;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    char **attributes, **value;
    int status, i, num_attrs, col_found = 0;
    MSGptr app_ptr;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, CHANGE_ITEM, 
                                      "", "", catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRprepare_update_item(dba_nfm_userid, catalog, name, rev, 
                       &attr_buffer, &data_buffer, &value_buffer);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    MEMbuild_array(data_buffer);
    attributes = (char **)data_buffer->column_ptr;
    value = (char **) data_buffer->data_ptr;
    num_attrs = data_buffer->columns;

    col_found = FALSE;
    for (i = 0; i < num_attrs; ++i)
    {
        if (strcmp(attributes[i], c_name) == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   c_value, 1, i + 1);
            col_found = TRUE;
        }
    }
    if (!col_found) /* FRANK what about closing memory */
    {
        strcpy(dba_nfm_error_message, "Column Name Not Found");
        status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
        ERRreset_struct();
	return(DBA_NFM_INVALID_COLUMN);
    }
/*
	Change the item
*/
    status = NFMRupdate_item(dba_nfm_userid, catalog, attr_buffer,
                             data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_change_user

Description: This function 

Author: DB Access
Date: 10-Sep-92
*/

int dba_nfm_change_user(user, c_name, c_value)
char *user, *c_name,  *c_value;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    char **attributes, **value;
    int status, i, num_attrs, col_found = 0;
    MSGptr app_ptr;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, CHANGE_USER, 
                                      "", "", "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRquery_change_user_attributes(dba_nfm_userid, 
                       user, &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    MEMbuild_array(data_buffer);
    attributes = (char **)data_buffer->column_ptr;
    value = (char **) data_buffer->data_ptr;
    num_attrs = data_buffer->columns;

    col_found = FALSE;
    for (i = 0; i < num_attrs; ++i)
    {
        if (strcmp(attributes[i], c_name) == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   c_value, 1, i + 1);
            col_found = TRUE;
        }
    }
    if (!col_found) /* FRANK what about closing memory */
    {
        strcpy(dba_nfm_error_message, "Column Name Not Found");
        status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
        ERRreset_struct();
	return(DBA_NFM_INVALID_COLUMN);
    }
/*
	Change the user
*/
    status = NFMRchange_user(dba_nfm_userid, attr_buffer, data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);
    ERRreset_struct();
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_add_multi

Description: This function adds a filename to the list used by checkin
             multi. Call this function for each file when checking
             in multiple files per item, then call dba_nfm_checkin_multi.
Author: DB Access

Date: 10-Aug-91
*/
int dba_nfm_add_multi(filename)

char *filename;
{
    if (strlen(filename) > DBA_NFM_FILE_LENGTH)
    {
	return(DBA_NFM_INVALID_FILENAME);
    }
    if (!dba_nfm_num_files)
    {
	dba_nfm_filelist = (char *)malloc(DBA_NFM_FILE_LENGTH + 1);
    }
    else
    {
	dba_nfm_filelist = (char *)realloc(dba_nfm_filelist, 
                      (dba_nfm_num_files + 1) * (DBA_NFM_FILE_LENGTH + 1));
    }
    strcpy(&dba_nfm_filelist[dba_nfm_num_files * (DBA_NFM_FILE_LENGTH + 1)], 
           filename);
    ++dba_nfm_num_files;
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_checkin_multi

Description: This function is used to perform an NFM checkin, when it
             is desired to have multiple files per item
Author: DB Access
Date: 10-Aug-91
*/
/*ARGSUSED*/
int dba_nfm_checkin_multi(catalog, name, rev, storage, node, user, passwd, 
                    path)
char *catalog, *name, *rev, *node, *user, *passwd, *path, *storage;
{
    struct NFMwf_info wf_info;
    struct NFMoperation operation;
    int status, i, num_attrs, num_rows;
    char **attributes, **value, **datas, ci_storage[32];
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    char *working_area, temp_sa[32];

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
            dba_nfm_free_files();
	    return(status);
        }
    }
    dba_nfm_default_schema();
    if (strcmp(storage, "DEFAULT") == 0)
    {
	status = dba_nfm_make_working_area(temp_sa);
        if (status)
        {
	    return(status);
        }
        
	status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }
    else if ((storage) && (strlen(storage) > 0))
    {
	working_area = storage;
    }
    else
    {
        status = dba_nfm_create_temporary_storage(node, user, path, temp_sa);
        if (status)
        {
            return(status);
        }
        
	status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }

    status = NFMRget_file_information(catalog, name, rev, 
                       NFM_CHANGE_FILE_INFORMATION, 
                       &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    datas = (char **)data_buffer->data_ptr;
    num_rows = data_buffer->rows;

    attributes = (char **)data_buffer->column_ptr;
    value = (char **) data_buffer->data_ptr;
    num_attrs = data_buffer->columns;

    ci_storage[0] = '\0';
    for (i = 0; i < num_attrs; ++i)
    {
        if (strcmp(attributes[i], "n_cisaname") == 0)
        {
            strcpy(ci_storage, value[i]);
        }

    }
    status = NFMRreset_file_information(catalog, name, rev);
    if (status != NFM_S_SUCCESS)
    {
        dba_nfm_free_files();
	return(status);
    }

    for (i = 1; i < dba_nfm_num_files; ++i)
    {
	status = dba_nfm_add_file(catalog, name, rev, 
                   &dba_nfm_filelist[i * (DBA_NFM_FILE_LENGTH + 1)], 
                   ci_storage, (void *)0, (void *)0);
        if (status != DBA_NFM_SUCCESS)
        {
            dba_nfm_free_files();
	    return(status);
        }
    }

    wf_info.workflow = NFM_NO_WORKFLOW;

    operation.transfer = NFM_TRANSFER;
    operation.delete = NFM_DELETE_FILES;
    operation.purge = NFM_PURGE;

    status = NFMRcheckin_item(catalog, -1, name, rev, working_area, 
                              wf_info, operation);
    if (status != NFM_S_SUCCESS)
    {
        dba_nfm_free_files();
	return(status);
    }
    dba_nfm_free_files();
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_free_files

Description: This function clears out the filelist built by
             dba_nfm_add_multi.

Author: DB Access

Date: 10-Aug-91
*/
int dba_nfm_free_files()
{
    if (dba_nfm_filelist)
    {
        free(dba_nfm_filelist);
        dba_nfm_filelist = NULL;
    }
    dba_nfm_num_files = 0;
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_add_user_catalog

Description: This function adds a column name to the list used by create
             user catalog. Call this function for each column when creating
             a catalog that will have user defined columns. Then call
             dba_nfm_create_user_catalog.

Author: DB Access

Date: 10-Aug-91
*/
int dba_nfm_add_user_catalog(name, type, synonym)

char *name, *type, *synonym;
{
    if ((strlen(name) > DBA_NFM_COLUMN_LENGTH) ||
       (strlen(type) > DBA_NFM_COLUMN_LENGTH) ||
       (strlen(synonym) > DBA_NFM_COLUMN_LENGTH))
    {
	return(DBA_NFM_INVALID_DATA);
    }

    if (!dba_nfm_num_columns)
    {
	dba_nfm_c_names = (char *)malloc(DBA_NFM_COLUMN_LENGTH + 1);
	dba_nfm_c_types = (char *)malloc(DBA_NFM_COLUMN_LENGTH + 1);
	dba_nfm_c_synonyms = (char *)malloc(DBA_NFM_COLUMN_LENGTH + 1);
    }
    else
    {
	dba_nfm_c_names = (char *)realloc(dba_nfm_c_names, 
                   (dba_nfm_num_columns + 1) * (DBA_NFM_COLUMN_LENGTH + 1));
	dba_nfm_c_types = (char *)realloc(dba_nfm_c_types, 
                   (dba_nfm_num_columns + 1) * (DBA_NFM_COLUMN_LENGTH + 1));
	dba_nfm_c_synonyms = (char *)realloc(dba_nfm_c_synonyms, 
                   (dba_nfm_num_columns + 1) * (DBA_NFM_COLUMN_LENGTH + 1));
    }
    strcpy
     (&dba_nfm_c_names[dba_nfm_num_columns * (DBA_NFM_COLUMN_LENGTH + 1)],
           name);
    strcpy
     (&dba_nfm_c_types[dba_nfm_num_columns * (DBA_NFM_COLUMN_LENGTH + 1)],
           type);
    strcpy
     (&dba_nfm_c_synonyms[dba_nfm_num_columns * (DBA_NFM_COLUMN_LENGTH+ 1)],
      synonym);
    ++dba_nfm_num_columns;
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_create_user_catalog

Description: This function is used to add a catalog to an NFM database that
             has user defined columns in addition to the standard set.
Author: DB Access
Date: 10-Aug-91
*/
int dba_nfm_create_user_catalog(catalog, desc, aclno)
char *catalog, *desc;
int aclno;

{
    int status, rows, cols, row_ndx, i;
    char string[128], loc_name[21], **column, **data_ptr;
    MSGptr app_ptr;
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL,
           loc_attr = NULL, loc_data = NULL, loc_value = NULL;
    NDXptr index;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    dba_nfm_free_cols();
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, CREATE_CATALOG, "", "",
                                      "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	dba_nfm_free_cols();
	return(status);
    }

    status = NFMRquery_addto_loc_attributes(dba_nfm_userid,
               loc_name, &loc_attr, &loc_data, &loc_value);
    if (status != NFM_S_SUCCESS)
    {
	dba_nfm_free_cols(); 
	return(status);
    }

    MEMbuild_array(loc_attr);
    MEMbuild_array(loc_data);

    column =  (char **) loc_data->column_ptr;
    cols = loc_attr->columns;
    rows = loc_attr->rows;
    data_ptr = (char **) loc_attr->data_ptr;

    NFMRfill_index(loc_attr, &index);

    for (row_ndx = 0; row_ndx < rows; ++row_ndx)
    {

	if (strcmp(data_ptr[row_ndx*cols+index.name], "n_catalogname") == 0)
        {
	    status = MEMwrite_data(loc_data, 
                                   catalog, 1, row_ndx+1);
        }

	if (strcmp(data_ptr[row_ndx*cols+index.name], "n_catalogdesc") == 0)
        {
	    status = MEMwrite_data(loc_data, 
                                   desc, 1, row_ndx+1);
        }

	if (strcmp(data_ptr[row_ndx*cols+index.name], "n_aclno") == 0)
        {
            sprintf(string, "%d", aclno);
	    status = MEMwrite_data(loc_data, 
                                   string, 1, row_ndx+1);
        }

	if (strcmp(data_ptr[row_ndx*cols+index.name], "n_application") == 0)
        {
	    status = MEMwrite_data(loc_data, 
                                   "NFM", 1, row_ndx+1);
        }

	if (strcmp(data_ptr[row_ndx*cols+index.name], "n_type") == 0)
        {
	    status = MEMwrite_data(loc_data, 
                                   "NFM", 1, row_ndx+1);
        }

    }
    status = NFMRquery_catalog_template(dba_nfm_userid,
               &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS) /* FRANK what about closing memory */
    {
	dba_nfm_free_cols();
	return(status);
    }

    for (i = 0; i < dba_nfm_num_columns; ++i)
    {
	dba_nfm_build_cat_field
          (&dba_nfm_c_names[i * (DBA_NFM_COLUMN_LENGTH + 1)],
           &dba_nfm_c_types[i * (DBA_NFM_COLUMN_LENGTH + 1)],
           &dba_nfm_c_synonyms[i * (DBA_NFM_COLUMN_LENGTH + 1)],
           i, attr_buffer);

        MEMbuild_array(attr_buffer);
    }
    NFMRrebuild_data_buffer(attr_buffer, &data_buffer);

    status = NFMRcreate_catalog(dba_nfm_userid, loc_attr, loc_data, 
                                attr_buffer, data_buffer, value_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    MEMclose(&loc_attr);
    MEMclose(&loc_data);
    MEMclose(&loc_value);
    dba_nfm_free_cols();
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

int dba_nfm_build_cat_field(name, type, syn, num, attr_list)
char *name, *type, *syn;
MEMptr attr_list;
int num;
{
    char str[1028], seqno[11];
    char **data_ptr;
    NDXptr attr_index;
    int sts, cols, col_index;
    int rows;

    str[0] = '\0';
    cols = attr_list->columns;
    rows = attr_list->rows;
    data_ptr = (char **) attr_list->data_ptr;

    NFMRfill_index(attr_list, &attr_index);
    for (col_index=0;col_index<cols;col_index++)
    {
        if (col_index==attr_index.name) strcat(str, name);
        if (col_index==attr_index.dt  ) strcat(str, type);
        if (col_index==attr_index.syn ) strcat(str, syn);
        if (col_index==attr_index.app ) strcat(str, "USR");
        if (col_index==attr_index.r   ) strcat(str, "Y");
        if (col_index==attr_index.w   ) strcat(str, "Y");
        if (col_index==attr_index.u   ) strcat(str, "Y");
        if (col_index==attr_index.d   ) strcat(str, "Y");
        if (col_index==attr_index.nul ) strcat(str, "Y");
        if (col_index==attr_index.in  ) strcat(str, "N");
        if (col_index==attr_index.out ) strcat(str, "N");
        if (col_index==attr_index.seq )
        {
           sprintf(seqno,"%d", num + 40 + 1);
           strcat(str,seqno);
        }
        if (col_index==attr_index.list) strcat(str, "0");
        strcat(str, "\1");
      }
      sts = MEMwrite( attr_list, str); /* FRANK what about closing memory */
      return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_free_cols

Description: This function clears out the lists built by
             dba_nfm_add_user_catalog

Author: DB Access

Date: 10-Aug-91
*/
int dba_nfm_free_cols()
{
    if (dba_nfm_c_names)
    {
        free(dba_nfm_c_names);
        dba_nfm_c_names = NULL;
    }
    if (dba_nfm_c_types)
    {
        free(dba_nfm_c_types);
        dba_nfm_c_types = NULL;
    }
    if (dba_nfm_c_synonyms)
    {
        free(dba_nfm_c_synonyms);
        dba_nfm_c_synonyms = NULL;
    }
    if (dba_nfm_values)
    {
        free(dba_nfm_values);
        dba_nfm_values = NULL;
    }
    dba_nfm_num_columns = 0;
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_add_user_data

Description: This function adds a column name and associated data to the list 
             used by add user item. Call this funtion once for each
             column that you wish to define a value for anf then call
             dba_nfm_add_user_item.

Author: DB Access

Date: 10-Aug-91
*/
int dba_nfm_add_user_data(name, value)

char *name, *value;
{
    if ((strlen(name) > DBA_NFM_COLUMN_LENGTH) ||
       (strlen(value) > DBA_NFM_VALUE_LENGTH))
    {
	return(DBA_NFM_INVALID_DATA);
    }

    if (!dba_nfm_num_columns)
    {
	dba_nfm_c_names = (char *)malloc(DBA_NFM_COLUMN_LENGTH + 1);
	dba_nfm_values = (char *)malloc(DBA_NFM_VALUE_LENGTH + 1);
    }
    else
    {
	dba_nfm_c_names = (char *)realloc(dba_nfm_c_names, 
                   (dba_nfm_num_columns + 1) * (DBA_NFM_COLUMN_LENGTH + 1));
	dba_nfm_values = (char *)realloc(dba_nfm_values, 
                   (dba_nfm_num_columns + 1) * (DBA_NFM_VALUE_LENGTH + 1));
    }
    strcpy
      (&dba_nfm_c_names[dba_nfm_num_columns * (DBA_NFM_COLUMN_LENGTH + 1)],
       name);
    strcpy(&dba_nfm_values[dba_nfm_num_columns * (DBA_NFM_VALUE_LENGTH + 1)],
           value);

    ++dba_nfm_num_columns;
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_add_user_item

Description: This function is used to add an item to an NFM catalog when
             the catalog has user defined columns that must recieve
             data.
Author: DB Access
Date: 10-Aug-91
*/
int dba_nfm_add_user_item(catalog, name, rev, desc, aclno, version_limit,
                     cisano, filename, ci_filename, file_type)
char *catalog, *name, *rev, *desc, *filename, *ci_filename, *file_type;
int aclno, version_limit, cisano;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, j, num_attrs;
    MSGptr app_ptr;
    char **attributes, string[128];

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    dba_nfm_free_cols();
	    return(status);
        }
    }

    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, ADD_ITEM, "", "",
                                      catalog, "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	dba_nfm_free_cols();
	return(status);
    }
    status = NFMRquery_add_item_attributes(dba_nfm_userid, catalog,
               &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	dba_nfm_free_cols();
	return(status);
    }
    MEMbuild_array(attr_buffer);
    MEMbuild_array(data_buffer);

    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    for (i = 0; i < num_attrs; ++i)
    {
	if (strcmp(attributes[i], "n_itemname") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   name, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_itemrev") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   rev, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_itemdesc") == 0)
        {
	    status = MEMwrite_data(data_buffer, 
                                   desc, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_aclno") == 0)
        {
            sprintf(string, "%d", aclno);
	    status = MEMwrite_data(data_buffer, string, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_versionlimit") == 0)
        {
            sprintf(string, "%d", version_limit);
	    status = MEMwrite_data(data_buffer, string, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_cisano") == 0)
        {
            sprintf(string, "%d", cisano);
	    status = MEMwrite_data(data_buffer, string, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_cofilename") == 0)
        {
            if ((filename) && (strlen(filename) > 0))
            {
	        status = MEMwrite_data(data_buffer, 
                                       filename, 1, i + 1);
            }
        }
        if (strcmp(attributes[i], "n_cifilename") == 0)
        {
            if (ci_filename) {
	        status = MEMwrite_data(data_buffer, ci_filename, 
                                       1, i + 1);
	    }
        }
        if (strcmp(attributes[i], "n_filetype") == 0)
        {
            if (file_type) {
	        status = MEMwrite_data(data_buffer, file_type, 
                                       1, i + 1);
	    }
        }

        MEMbuild_array(attr_buffer);
        MEMbuild_array(data_buffer);

/*	if (i < 40) continue;*/

        for (j = 0; j < dba_nfm_num_columns; ++j)
        {
           if (strcmp(attributes[i], 
               &dba_nfm_c_names[j * (DBA_NFM_COLUMN_LENGTH + 1)]) == 0)
           {
	       status = MEMwrite_data(data_buffer, 
                         &dba_nfm_values[j * (DBA_NFM_VALUE_LENGTH + 1)],
                         1, i + 1);
           }
	}
    }
    MEMbuild_array(attr_buffer);
    MEMbuild_array(data_buffer);
/*
	Add the item
*/
    status = NFMRadd_item(dba_nfm_userid, catalog, attr_buffer,
                          data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    dba_nfm_free_cols();
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_flag_item_archive

Description: This function is used to flag an item for archive.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_flag_item_archive(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, FLAG_ITEM_ARCHIVE, 
                                      "", "", catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRflag_item_archive(dba_nfm_userid, catalog, 
                                  name, rev);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_cancel_item_archive

Description: This function is used to cancel the archive flag on an NFM item.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_cancel_item_archive(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, CANCEL_ITEM_ARCHIVE_FLAG,
                                      "", "", catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRcancel_item_archive_flag(dba_nfm_userid, catalog, 
                                  name, rev);
    
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_flag_item_restore

Description: This function is used to flag an item for restore.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_flag_item_restore(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, FLAG_ITEM_RESTORE, 
                                      "", "", catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRflag_item_restore(dba_nfm_userid, catalog, 
                                  name, rev);
    
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_cancel_item_restore

Description: This function is used to cancel the restore flag on an NFM item.

Author: DB Access
Date: 20-Jan-90
*/
int dba_nfm_cancel_item_restore(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, CANCEL_ITEM_RESTORE_FLAG,
                                      "", "", catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRcancel_item_restore_flag(dba_nfm_userid, catalog, 
                                  name, rev);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_change_sa_passwd

Description: This function is used to change the storage area passwd

Author: DB Access
Date: 10-Aug-91
*/
int dba_nfm_change_sa_passwd(storage, old_passwd, new_passwd)
char *storage, *old_passwd, *new_passwd;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, CHG_SA_PASSWD,
                                      "", "", "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRchange_storage_area_passwd(dba_nfm_userid, storage, 
                                  old_passwd, new_passwd);

    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_change_wa_passwd

Description: This function is used to change the working area passwd

Author: DB Access
Date: 19-June-97
*/
int dba_nfm_change_wa_passwd(storage, old_passwd, new_passwd)
char *storage, *old_passwd, *new_passwd;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, CHANGE_WORKING_AREA_PWD,
                                      "", "", "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRchange_working_area_passwd(storage, 
                                  old_passwd, new_passwd);

    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_get_schema

Description: This function is used to get the NFM schema name and password
             for the specified environment from the nfme_environment file.

Author: DB Access
Date: 03-Dec-91
*/

int dba_nfm_get_schema(environment, schema, password)
char *environment, *schema, *password;
{
    char env[32], t_str[64], *message, *clh_vbyop();
    
    sprintf(env, "nfme_%s", environment);
    message = clh_vbyop(env, "NETPROP20", t_str, 64);
    if (message)
    {
        strcpy(dba_nfm_error_message, message);
	return(DBA_NFM_NOENV);
    }
    sprintf(t_str, "%*.*s", 25, 25, t_str);
    NFMdecrypt(t_str, schema);

    message = clh_vbyop(env, "NETPROP21", t_str, 64);
    if (message)
    {
        strcpy(dba_nfm_error_message, message);
	return(DBA_NFM_NOENV);
    }
    sprintf(t_str, "%*.*s", 25, 25, t_str);
    NFMdecrypt(t_str, password);
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_get_schema_name

Description: This function is used to get the NFM schema name and password
             for the current environment, it will return an error if
             dba_nfm_login has not been called.

Author: DB Access
Date: 03-Dec-91
*/

dba_nfm_get_schema_name(schema, passwd)
char *schema, *passwd;

{
    int status;
    if (!dba_nfm_active)
    {
	strcpy(dba_nfm_error_message, 
         "DBA/NFM is not active, call DBA_NFM_LOGIN");
        return(DBA_NFM_NOENV);
    }
    status = dba_nfm_get_schema(dba_nfm_env, schema, passwd);
    return(status);
}

/*
Function: dba_nfm_make_working_area

Description: This function create a working area for the current
             directory, and returns its name. If one already exists
             then it just returns the name.

Author: DB Access
Date: 11-Mar-92
*/

dba_nfm_make_working_area(working_area)
char *working_area;
{
    int status;

    char node[32], user[32], *cptr, path[132];

    struct utsname name;
    uname(&name);
    strcpy(node, name.nodename);

    cptr = (char *)getenv("LOGNAME");
    strcpy(user, cptr);    

    getcwd(path, 132);

    status = dba_nfm_create_temporary_storage(node, user, path, working_area);
    if (status != DBA_NFM_SUCCESS)
    {
	return(status);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_create_temporary_storage

Description: This function create a working area given a node, user and
             path unless one already exists for that combination then
             in either case it returns the name.

Author: DB Access
Date: 11-Mar-92
*/

dba_nfm_create_temporary_storage(node, user, path, storage)
char *node, *user, *path, *storage;
{
    int status;
    char str[32];

    MEMptr node_info, sa_info;

    MEMopen(&node_info, MEM_SIZE);
    MEMwrite_format(node_info, "n_name", "char(18)");
    MEMwrite_format(node_info, "n_value", "char(1)");

    MEMopen(&sa_info, MEM_SIZE);
    MEMwrite_format(sa_info, "n_name", "char(18)");
    MEMwrite_format(sa_info, "n_value", "char(1)");

    strcpy(str, "n_xns\1Y");
    MEMwrite(node_info, str);

    strcpy(str, "n_tcpip\1Y");
    MEMwrite(node_info, str);

    strcpy(str, "n_decnet\1N");
    MEMwrite(node_info, str);

    strcpy(str, "n_netware\1N");
    MEMwrite(node_info, str);

    strcpy(str, "n_nfs\1Y");
    MEMwrite(node_info, str);

    strcpy(str, "n_nfs\1N");
    MEMwrite(sa_info, str);

    dba_nfm_default_schema();

    status = NFMRadd_default_working_area(node, user, path, storage,
                                         node_info, sa_info);
    MEMclose(&node_info);
    MEMclose(&sa_info);

    if (status != NFM_S_SUCCESS)
    {
        return(status);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_lock_item

Description: This function is used to lock an NFM item.

Author: DB Access
Date: 10-Jul-92
*/
int dba_nfm_lock_item(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, LOCK_ITEM, 
                                      "", "", catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
    status = NFMRlock_item(dba_nfm_userid, catalog, 
                                  name, rev);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_unlock_item

Description: This function is used to unlock an NFM item.

Author: DB Access
Date: 10-Jul-92
*/
int dba_nfm_unlock_item(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, UNLOCK_ITEM, 
                                      "", "", catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRunlock_item(dba_nfm_userid, catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;
    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_set_local_file_manager

Description: This function is used to toggle the local file manager flag

Author: DB Access
Date: 16-Sep-92
*/
int dba_nfm_set_local_file_manager(state)
int state;
{
    dba_nfm_lfm = state;
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_set_workflow

Description: This function is used to toggle the workflow flag

Author: DB Access
Date: 16-Sep-92
*/
int dba_nfm_set_workflow(state)
int state;
{
    dba_nfm_workflow = state;
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_default_schema

Description: This function does a default schema for the NFM schema assuming
             that dba_nfm_login has already been called.
Author: T. F. Ezell
Date: 10-Mar-90
*/

int dba_nfm_default_schema()
{
    int status;
    char schema[64], passwd[64];
    char string[128];

    status = dba_nfm_get_schema_name(schema, passwd);
    if (status != DBA_NFM_SUCCESS) return(status);

    sprintf(string, "default schema %s.%s", schema, passwd);    
    status = dba_ris_exec_sql(string);
    return(status);
}
/*
Function: dba_nfm_delete_copied_file

Description: This function is used to delete an NFM copy item file.

Author: Jerry Jugovich
Date: 24-Jun-93
*/
/*ARGSUSED*/

int dba_nfm_delete_copied_file(catalog, name, rev, storage, 
                                node, user, passwd, path, filename, version ) 
char *catalog, *name, *rev, *storage; 
char *node, *user, *passwd, *path, *filename;
int version;

{
int    status;
char   search[500], err_mes[500], sqlst[500], title[80], owner[15];
char   *working_area, temp_sa[32];
MEMptr data_list = NULL;
MEMptr sel_data = NULL;
char   d_node[32], d_user[32], *cptr, d_path[132];
static char *fname = "dba_nfm_delete_copied_file";

struct utsname d_name;

    uname(&d_name);
    strcpy(d_node, d_name.nodename);

    cptr = (char *)getenv("LOGNAME");
    strcpy(d_user, cptr);

    getcwd(d_path, 132);

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();

    if (strcmp(storage, "DEFAULT") == 0)
    {
        sprintf ( sqlst, "select n_saname from nfmnodes, nfmstoragearea where \
                          n_username = '%s' and n_pathname = '%s' and \
                          nfmstoragearea.n_nodeno = nfmnodes.n_nodeno and \
                          n_nodename = '%s' ", d_user, d_path, d_node );

        status = NFMRsqlquery ( sqlst, "500", &sel_data ); 

        MEMclose( &sel_data );

        if ( status != NFM_S_SUCCESS ) 
        {
            strcpy ( err_mes, " Default Storage Area Not Found " );
            ERRload_struct( NFM, NFM_E_INVALID_WORKING_AREA, "%s", err_mes );
            ERRget_message(dba_nfm_error_message);
            ERRreset_struct();
            return( status );
        }

        status = dba_nfm_make_working_area(temp_sa);
        if (status)
        {
            return(status);
        }
        
	status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }
    else if ((storage) && (strlen(storage) > 0))
    {
        sprintf ( sqlst, "select n_saname from nfmstoragearea where \
                          n_saname = '%s' ", storage );

        status = NFMRsqlquery ( sqlst, "500", &sel_data ); 

        MEMclose( &sel_data );

        if ( status != NFM_S_SUCCESS ) 
        {
            sprintf ( err_mes, "%s%s", " Storage Area Not Found ", storage );
            ERRload_struct( NFM, NFM_E_INVALID_WORKING_AREA, "%s", err_mes );
            ERRget_message(dba_nfm_error_message);
            ERRreset_struct();
            return( status );
        }
        working_area = storage;
    }
    else
    {
        sprintf ( sqlst, "select n_saname from nfmnodes, nfmstoragearea where \
                          n_username = '%s' and n_pathname = '%s' and \
                          nfmstoragearea.n_nodeno = nfmnodes.n_nodeno and \
                          n_nodename = '%s' ", user, path, node );

        status = NFMRsqlquery ( sqlst, "500", &sel_data ); 

        MEMclose( &sel_data );
        if ( status != NFM_S_SUCCESS ) 
        {
            strcpy ( err_mes, " Storage Area Not Found " );
            ERRload_struct( NFM, NFM_E_INVALID_WORKING_AREA, "%s", err_mes );
            ERRget_message(dba_nfm_error_message);
            ERRreset_struct();
            return( status );
        }

        status = dba_nfm_create_temporary_storage(node, user, path, temp_sa);
        if (status)
        {
            return(status);
        }
        
	status = dba_nfm_change_wa_passwd(temp_sa,"",passwd);
        working_area = temp_sa;
    }

    status = NFMRvalidate_working_area( working_area, owner );
    if( status != NFM_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_INVALID_WORKING_AREA, "%s", working_area );
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
        return( status );
    }
    if (strcmp(dba_nfm_user, "nfmadmin") != 0) {
        if( (strcmp( owner, "PUBLIC" ) == 0 ) ||
            (strcmp( owner, dba_nfm_user )  == 0 ) ||
            (strcmp( owner, "nfmadmin" ) == 0 ) )
        {
             ERRreset_struct();
        }
        else
        {
            strcpy ( err_mes, " User can not Access Storage Area " );
            ERRload_struct( NFM, NFM_E_INVALID_WORKING_AREA, "%s%s", 
                        err_mes, working_area );
            ERRget_message(dba_nfm_error_message);
            ERRreset_struct();
            return( NFM_E_INVALID_WORKING_AREA );
        }
    }
    status = MEMopen( &data_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        ERRload_struct( NFI, NFM_E_MEM_ERR, "%s%s", fname, "MEMopen" );
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
        return (status);
    }

    sprintf( title, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( data_list, "n_catalogname", title );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &data_list );
        ERRload_struct( NFI, NFM_E_MEM_ERR, "%s%s", fname, "MEMwrite_format" );
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
        return (status);
    }

    sprintf( title, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( data_list, "n_itemname", title );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &data_list );
        ERRload_struct( NFI, NFM_E_MEM_ERR, "%s%s", fname, "MEMwrite_format" );
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
        return (status);
    }

    sprintf( title, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( data_list, "n_itemrev", title );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &data_list );
        ERRload_struct( NFI, NFM_E_MEM_ERR, fname, "MEMwrite_format" );
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
        return (status);
    }

    sprintf( title, "char(%d)", NFM_COFILENAME );
    status = MEMwrite_format( data_list, "n_filename", title );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &data_list );
        ERRload_struct( NFI, NFM_E_MEM_ERR, "%s%s",fname, "MEMwrite_format" );
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
        return (status);
    }

    sprintf( title, "char(%d)", NFM_FILEVERSION );
    status = MEMwrite_format( data_list, "n_fileversion", title );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &data_list );
        ERRload_struct( NFI, NFM_E_MEM_ERR, "%s%s", fname, "MEMwrite_format" );
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
        return (status);
    }

    sprintf( search, "%s\1%s\1%s\1%s\1%d\1",
                     catalog, name, rev, filename, version );

    status = MEMwrite( data_list, search );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &data_list );
        ERRload_struct( NFI, NFM_E_MEM_ERR, "%s%s", fname, "MEMwrite" );
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
        return (status);
    }

    status = NFMRdelete_copied_files( working_area, data_list );
    MEMclose( &data_list );
    if (status != NFM_S_SUCCESS)
    {
        sprintf ( err_mes, "Storage area: %s  File: %s  Item: %s Rev: %s Version: %d",
                         working_area, filename, name, rev, version );
        ERRload_struct( NFM, NFM_E_DELETE_COPIED_FILES, "%s", err_mes );
        ERRget_message(dba_nfm_error_message);
        ERRreset_struct();
        return (status);
    }

    return (DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_add_node

Description: This function is used to add a node to NFM

Author: DB Access
Date: 13-Sep-93
*/
int dba_nfm_add_node(node, description, xns, tcp, nfs)
char *node, *description, *xns, *tcp, *nfs;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, num_attrs;
    MSGptr app_ptr;
    char **attributes;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, ADD_NODE, "", "",
                                      "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRquery_add_node_attributes(dba_nfm_userid,
               &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    MEMbuild_array(data_buffer);
    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    for (i = 0; i < num_attrs; ++i)
    {
	if (strcmp(attributes[i], "n_nodename") == 0)
        {
	    status = MEMwrite_data(data_buffer, node, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_nodedesc") == 0)
        {
	    status = MEMwrite_data(data_buffer, description, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_xns") == 0)
        {
	    status = MEMwrite_data(data_buffer, xns, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_tcpip") == 0)
        {
	    status = MEMwrite_data(data_buffer, tcp, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_nfs") == 0)
        {
	    status = MEMwrite_data(data_buffer, nfs, 1, i + 1);
        }
	if (strcmp(attributes[i], "n_netware") == 0)
        {
	    status = MEMwrite_data(data_buffer, "N", 1, i + 1);
        }
	if (strcmp(attributes[i], "n_decnet") == 0)
        {
	    status = MEMwrite_data(data_buffer, "N", 1, i + 1);
        }
    }
/*
	Add the node
*/
    status = NFMRadd_node(dba_nfm_userid, attr_buffer, data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;

    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_delete_node

Description: This function is used to delete a node from NFM

Author: DB Access
Date: 13-Sep-93
*/
int dba_nfm_delete_node(node)
char *node;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, DELETE_NODE, "", "",
                                      "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

/*
	Delete the node
*/
    status = NFMRdelete_node(dba_nfm_userid, node);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;

    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}
/*
Function: dba_nfm_change_node

Description: This function is used to change an NFM node

Author: DB Access
Date: 13-Sep-93
*/
int dba_nfm_change_node(node, c_name, c_value)
char *node, *c_name, *c_value;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, num_attrs, col_found;
    MSGptr app_ptr;
    char **attributes;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, CHANGE_NODE, "", "",
                                      "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRquery_change_node_attributes(dba_nfm_userid, node, 
               &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    MEMbuild_array(data_buffer);
    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    col_found = 0;
    for (i = 0; i < num_attrs; ++i)
    {
	if (strcmp(attributes[i], c_name) == 0)
        {
            col_found = 1;
	    status = MEMwrite_data(data_buffer, c_value, 1, i + 1);
        }
    }
    if (!col_found)
    {
        strcpy(dba_nfm_error_message, "Invalid Column Name");
        MEMclose(&attr_buffer);
        MEMclose(&data_buffer);
        MEMclose(&value_buffer);
	return(DBA_NFM_INVALID_COLUMN);
    }
/*
	Change the node
*/
    status = NFMRchange_node(dba_nfm_userid, attr_buffer, data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;

    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}
/*
Function: dba_nfm_change_storage_area

Description: This function is used to change an NFM storage area

Author: DB Access
Date: 13-Sep-93
*/
int dba_nfm_change_storage_area(storage, c_name, c_value)
char *storage, *c_name, *c_value;
{
    MEMptr attr_buffer = NULL, data_buffer = NULL, value_buffer = NULL;
    int status, i, num_attrs, col_found;
    MSGptr app_ptr;
    char **attributes;

    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, CHANGE_SA, "", "",
                                      "", "", "");
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    status = NFMRquery_change_sa_attributes(dba_nfm_userid, storage, 
               &attr_buffer, &data_buffer, &value_buffer);
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

    MEMbuild_array(data_buffer);
    attributes = (char **) data_buffer->column_ptr;
    num_attrs = data_buffer->columns;
    col_found = 0;
    for (i = 0; i < num_attrs; ++i)
    {
	if (strcmp(attributes[i], c_name) == 0)
        {
            col_found = 1;
	    status = MEMwrite_data(data_buffer, c_value, 1, i + 1);
        }
    }
    if (!col_found)
    {
        strcpy(dba_nfm_error_message, "Invalid Column Name");
        MEMclose(&attr_buffer);
        MEMclose(&data_buffer);
        MEMclose(&value_buffer);
	return(DBA_NFM_INVALID_COLUMN);
    }
/*
	Change the storage area
*/
    status = NFMRchange_sa(dba_nfm_userid, attr_buffer, data_buffer);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;

    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&value_buffer);
    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);
}

/*
Function: dba_nfm_plot_item

Description: This function is used to plot anf NFM item

Author: DB Access
Date: 13-Sep-93
*/
int dba_nfm_plot_item(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, PLOT_ITEM, "", "",
                                      catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

/*
	Plot the Item
*/
    status = NFMRplot_item(catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;

    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}

/*
Function: dba_nfm_plot_set

Description: This function is used to plot anf NFM set

Author: DB Access
Date: 13-Sep-93
*/
int dba_nfm_plot_set(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, PLOT_SET, "", "",
                                      catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

/*
	Plot the Set
*/
    status = NFMRplot_set(catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;

    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}

/*
Function: dba_nfm_save_item

Description: This function is used to save an NFM item

Author: DB Access
Date: 13-Sep-93
*/
int dba_nfm_save_item(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, SAVE_ITEM_FILES, "", "",
                                      catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }

/*
	Save the Item
*/
    status = NFMRsave_item_files(catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;

    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}

/*
Function: dba_nfm_save_set

Description: This function is used to save an NFM set

Author: DB Access
Date: 13-Sep-93
*/
int dba_nfm_save_set(catalog, name, rev)
char *catalog, *name, *rev;
{
    int status;
    MSGptr app_ptr;
    if (!dba_nfm_active)
    {
	status = dba_nfm_login(dba_nfm_server, dba_nfm_user, 
                               dba_nfm_passwd, dba_nfm_env, dba_nfm_dbg);
        if (status)
        {
	    return(status);
        }
    }
    dba_nfm_default_schema();
    status = NFMRvalidate_user_access(dba_nfm_userid, SAVE_SET_FILES, "", "",
                                      catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    ERRreset_struct();
    if (status != NFM_S_SUCCESS)
    {
	return(status);
    }
/*
	Save the Set
*/
    status = NFMRsave_set_files(catalog, name, rev);
    ERRget_message(dba_nfm_error_message);
    app_ptr.error_no = status;

    status = NFMRset_wf_state("NFM", status, dba_nfm_error_message);

    ERRreset_struct();

    if (app_ptr.error_no != NFM_S_SUCCESS)
    {
        return(app_ptr.error_no);
    }
    return(DBA_NFM_SUCCESS);

}
