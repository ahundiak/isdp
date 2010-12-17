#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"
#include "ERR.h"
#include "DEBUG.h"

long add_signoff_to_users (acl_name)
    char *acl_name;
{
long   status;
long   reset_no;
int    i, j, k, m, n;
int    USERS_CHOSEN = FALSE;
int    override_count;
struct SCfree_data_st user_data;
char   state_num[20];
char   state_name[45];
char   user_num[20];
char   user_name[20];
char   str[100];
char   acl_num[20];
char   index_num[20];
char   override_num[20];
char   override[3];
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
char   **state_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr state_list = NULL;
MEMptr user_list = NULL;
NDXptr index;
static char *fname = "NFAadd_signoff_users";

    SCdisplay_msg ("Working..");    

    /* query for the data needed to add users to the acl */    

    status = NFMRquery_acl_signoff_users (NFMuser_id, acl_name, &attr_list,
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

    _NFIdebug(( fname, "acl_num : <%s>\n", acl_num));

    status = MEMbuild_array (data_list);
/*
    MEMprint_buffers("attr_list", attr_list,  "/dev/console");
    MEMprint_buffers("data_list", data_list,  "/dev/console");
    MEMprint_buffers("value_list", value_list,  "/dev/console");
*/
    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    /* List all signoff states for the given workflow. */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_stateno") == 0)
            {
            reset_no = atoi (attr_ptr[i+index.list]);
            _NFIdebug(( fname, "reset_no : <%ld>\n", reset_no));
            status = MEMreset_buffer_no (value_list, reset_no);
            status = MEMsplit_copy_buffer (value_list, &state_list, 0);
            status = MEMbuild_array (state_list);
/*            MEMprint_buffers("data_value",  state_list,  "/dev/console");*/
            state_ptr = (char **) state_list->data_ptr;
            }
        }

    if (reset_no == 0)
        {
        MEMclose (&attr_list);
        MEMclose (&value_list);
        MEMclose (&data_list);
	ERRload_struct( NFI, NFI_I_NO_SIGNOFF_USERS_REQ, "%s", acl_name );
        return (NFI_W_COMMAND_CANCELLED);
        }

    /* List all users for the given workflow. */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_userno") == 0)
            {
            reset_no = atoi (attr_ptr[i+index.list]);
            _NFIdebug(( fname, "reset_no : <%ld>\n", reset_no));
            status = MEMreset_buffer_no (value_list, reset_no);
            status = MEMsplit_copy_buffer (value_list, &user_list, 0);
            status = MEMbuild_array (user_list);
            }
        }

    /* For each signoff state, list all users and add chosen users to the acl buffer. */

    for (i=0, j=0; i<state_list->rows; ++i)
        {
        j = i * state_list->columns;

        state_num[0] = 0;
        state_name[0] = 0;
        override_num[0] = 0;
        strcpy (state_num, state_ptr[j]);
        strcpy (state_name, state_ptr[j+1]);
        strcpy (override_num, state_ptr[j+2]);
        _NFIdebug(( fname, "state name : <%s>\n", state_name));
        _NFIdebug(( fname, "state num  : <%s>\n", state_num));
        _NFIdebug(( fname, "override num  : <%s>\n",override_num));
  	
   /* If call_case #2, we are just adding another signoff user and
     * it should not be the same number as needed in the acl
     * definition.
   */
	    sprintf (user_data.title, "Choose a signoff user for \'%s\'",   
		     state_name );
	    strcpy( override_num, "1" );

        status = NFAfill_free_list (user_list, &user_data);

        status = SCprocess_free_form (&user_data, NFMprint_file);
        if( user_data.sts == FORM_CANCELED )
     	     {
       		USERS_CHOSEN = FALSE;
 		break;
     	      }

/*        }*/

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
                  _NFIdebug(( fname, "user name : <%s>\n", user_name));
                  _NFIdebug(( fname, "user num  : <%s>\n",user_num));
                   status = NFAoverride_power (user_name, state_name,
                                                 override);

                    str[0] = 0;

                    for (n=0; n<data_list->columns; ++n)
                     {
                       if (strcmp (column_ptr[n], "n_aclno") == 0)
                            strcat (str, acl_num);

                       else if (strcmp (column_ptr[n], "n_stateno") == 0)
                             strcat (str, state_num);

                       else if (strcmp (column_ptr[n], "n_userno") == 0)
                              strcat (str, user_num);

                       else if (strcmp (column_ptr[n], "n_override") == 0)
                                  strcat (str, override);

                       else if (strcmp (column_ptr[n], "n_status") == 0)
                                  strcat (str, "ADD");

                       strcat (str, "\1");
                       }

                    _NFIdebug(( fname, "str : <%s>\n", str));

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
					"NFMadd_signoff_users","MEMwrite");
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
      }
    if (USERS_CHOSEN)
        {
        SCdisplay_msg ("Working..");
        status = NFMRupdate_acl_signoff_users (NFMuser_id, attr_list,
                                               data_list);
        _NFIdebug(( fname, "Retur from NFMadd_signoff_users -> 0x%.8x\n", 
		    status));
        }
    else
        status = NFI_W_COMMAND_CANCELLED;

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&state_list);
    MEMclose (&user_list);

    if (status != NFM_S_SUCCESS)
    {
	if (status == NFI_W_COMMAND_CANCELLED)
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL);
        return (status);
    }

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}
