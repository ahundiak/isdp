#include "machine.h"
#include <stdio.h>
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"

long add_acl_users (acl_name)
    char *acl_name;

{
long   status;
long   reset_no;
int    i, j, k, m, n;
int    USERS_CHOSEN = FALSE;
struct SCfree_data_st user_data;
char   class_num[20];
char   class_name[20];
char   user_num[20];
char   user_name[20];
char   str[100];
char   acl_num[20];
char   index_num[20];
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
char   **class_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr class_list = NULL;
MEMptr user_list = NULL;
NDXptr index;
static char *fname = "add_acl_users";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    /* query for the data needed to add users to the acl */    

    status = NFMRquery_acl_class_users (NFMuser_id, acl_name, &attr_list,
                                        &data_list, &value_list);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    attr_ptr = (char **) attr_list->data_ptr;

    status = MEMbuild_array (value_list);

    NFMRfill_index (attr_list, &index);

    /* find acl number from values list */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_aclno") == 0)
            {
            status = NFAget_value_list_index (attr_ptr[i+index.list],
                        value_list, attr_ptr[i+index.name],
                        attr_ptr[i+index.syn], index_num);
            if (status != NFI_S_SUCCESS)
                {
                MEMclose (&attr_list);
                MEMclose (&value_list);
                MEMclose (&data_list);
                return (status);
                }
            strcpy (acl_num, index_num);
            break;
            }
        }

    _NFIdebug ((fname, "acl_num : <%s>\n", acl_num));

    status = MEMbuild_array (data_list);

    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    /* List all user classes for the given workflow. */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_classno") == 0)
            {
            reset_no = atoi (attr_ptr[i+index.list]);
            _NFIdebug ((fname, "reset_no : <%ld>\n", reset_no));
            status = MEMreset_buffer_no (value_list, reset_no);
            status = MEMsplit_copy_buffer (value_list, &class_list, 0);
            status = MEMbuild_array (class_list);
            class_ptr = (char **) class_list->data_ptr;
            }
        }

    /* List all users for the given workflow. */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_userno") == 0)
            {
            reset_no = atoi (attr_ptr[i+index.list]);
            _NFIdebug ((fname, "reset_no : <%ld>\n", reset_no));
            status = MEMreset_buffer_no (value_list, reset_no);
            status = MEMsplit_copy_buffer (value_list, &user_list, 0);
            status = MEMbuild_array (user_list);
            }
        }

    /* For each class, list all users and add chosen users to the acl buffer. */

    for (i=0, j=0; i<class_list->rows; ++i)
        {
        j = i * class_list->columns;

        class_num[0] = 0;
        class_name[0] = 0;
        strcpy (class_num, class_ptr[j]);
        strcpy (class_name, class_ptr[j+1]);
        _NFIdebug ((fname, "class name : <%s>\n", class_name));
        _NFIdebug ((fname, "class num  : <%s>\n", class_num));

        sprintf (user_data.title, "Choose users for class \'%s\'", class_name);

        status = NFAfill_free_list (user_list, &user_data);

        status = SCprocess_free_form (&user_data, NFMprint_file);
        if (user_data.sts == FORM_CANCELED )
	{
	    USERS_CHOSEN = FALSE; 
	    break;
        }
        /* for each selected user, add a row */

        if (user_data.sts != FORM_CANCELED)
            {
            for (k=0; k<user_data.num_of_rows; ++k)
                {

                /* if user is selected, add a row */
                if (user_data.select_set[k] == 1)
                    {
                    USERS_CHOSEN = TRUE;
                    m = k * user_data.num_of_cols;
                    user_num[0] = 0;
                    user_name[0] = 0;
                    strcpy (user_num, user_data.data[m]);
                    strcpy (user_name, user_data.data[m+1]);
                    _NFIdebug ((fname, "user name : <%s>\n",user_name));
                    _NFIdebug ((fname, "user num  : <%s>\n",user_num));

                    str[0] = 0;

                    for (n=0; n<data_list->columns; ++n)
                         {
                              if (strcmp (column_ptr[n], "n_aclno") == 0)
                                  strcat (str, acl_num);

                         else if (strcmp (column_ptr[n], "n_classno") == 0)
                                  strcat (str, class_num);

                         else if (strcmp (column_ptr[n], "n_userno") == 0)
                                  strcat (str, user_num);

                         else if (strcmp (column_ptr[n], "n_status") == 0)
                                  strcat (str, "ADD");

                         strcat (str, "\1");
                         }

                    _NFIdebug ((fname, "str : <%s>\n", str));

                    status = MEMwrite (data_list, str);
                    if (status != MEM_S_SUCCESS)
                        {
                        MEMclose (&attr_list);
                        MEMclose (&data_list);
                        MEMclose (&value_list);
                        NFAfree_list (user_data.data, user_data.num_of_rows,
                                      user_data.num_of_cols);
                        free (user_data.data);
		        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
					"NFMadd_acl_users", "MEMwrite" );
                        return (status);
                        }

                    status = MEMbuild_array (data_list);

                    data_ptr = (char **) data_list->data_ptr;
                    column_ptr = (char **) data_list->column_ptr;

                    }  /* end if selected user */

                }  /* end for each user */

            NFAfree_list (user_data.data, user_data.num_of_rows,
                          user_data.num_of_cols);
            free (user_data.data);

            }  /* end if NOT FORM_CANCELED */

        }  /* end for each class */

    if (USERS_CHOSEN)
        {
        SCdisplay_msg ("Working..");
        status = NFMRupdate_acl_class_users (NFMuser_id, attr_list, data_list);
        _NFIdebug ((fname, "NFMRupdate_class_users -> <0x%.8x>\n", status));
        }
    else
        status = NFI_W_COMMAND_CANCELLED;

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&class_list);
    MEMclose (&user_list);

    if (status != NFM_S_SUCCESS)
        {
        if (status == NFI_W_COMMAND_CANCELLED)
	    ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (status);
        }

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long delete_acl_users (acl_name)
    char *acl_name;

{
long   status;
int    i, k, m;
int    USERS_CHOSEN = FALSE;
int    status_col = 0;
struct SCfree_data_st user_data;
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr class_list = NULL;
MEMptr user_list = NULL;
NDXptr index;
static char *fname = "NFAdelete_acl_users";

    SCdisplay_msg ("Working..");    

    /* query for the data needed to delete users from the acl */    

    status = NFMRquery_acl_class_users (NFMuser_id, acl_name, &attr_list,
                                        &data_list, &value_list);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    attr_ptr = (char **) attr_list->data_ptr;

    status = MEMbuild_array (value_list);

    NFMRfill_index (attr_list, &index);

    status = MEMbuild_array (data_list);

    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    /* find n_status column */
    for (i=0; i<data_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], "n_status") == 0)
            {
            status_col = i + 1;
            break;
            }
        }
    _NFIdebug(( fname, "%s\n", "Call NFAfill_data_list" ));

    status = NFAfill_data_list (attr_list, data_list, value_list, &user_data);
    if( status == NFI_E_FAILURE )
    {
	_NFIdebug(( fname, "NFAfill_data_list <0x%.8x>\n", status ));
	ERRload_struct( NFI, NFI_E_DELETE_ACL_CLASS_USERS, NULL, NULL );
	return( NFI_E_DELETE_ACL_CLASS_USERS );
    }

    _NFIdebug(( fname, "%s\n", "Return from NFAfill_data_list" ));

    /* For each class, list all users and add chosen users to the acl buffer. */

    sprintf (user_data.title, "Choose ACL Class Users to Delete");

    status = SCprocess_free_form (&user_data, NFMprint_file);

    if (user_data.sts == FORM_CANCELED)
        {
        NFAfree_list (user_data.data, user_data.num_of_rows,
                        user_data.num_of_cols);
        free (user_data.data);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=0; i<user_data.num_of_rows; ++i)
        {
        /* if user is selected, write "DROP" in data list row */
        if (user_data.select_set[i] == 1)
            {
            USERS_CHOSEN = TRUE;
            m = k * user_data.num_of_cols;

            status = MEMwrite_data (data_list, "DROP", i+1, status_col);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list (user_data.data, user_data.num_of_rows,
                              user_data.num_of_cols);
                free (user_data.data);	
	        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMdelete_acl_users",
				"MEMwrite_data" );
                return (status);
                }
                else if (status == FORM_CANCELED)
                 { 
                   ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
                   return (status);
                  }
          
            }  /* end if selected user */

        }  /* end for each user */

    NFAfree_list (user_data.data, user_data.num_of_rows,
                  user_data.num_of_cols);
    free (user_data.data);

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffers ("ACL USER DATA", data_list, _NFMdebug_st.NFIdebug_file);

    if (USERS_CHOSEN)
        {
        SCdisplay_msg ("Working..");
        status = NFMRupdate_acl_class_users (NFMuser_id, attr_list, data_list);
        _NFIdebug ((fname, "NFMRupdate_acl_class_users -> <0x%.8x>\n", status));
        }

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&class_list);
    MEMclose (&user_list);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



