#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMRlist.h"

long add_acl (acl_name, wf_name)
    char *acl_name;
    char *wf_name;
{
long   status;
int    i, j, k;
int    tot_data;
int    FORM_FILLED;
int    count = 0;
struct SCcolumn_data_st data;
char   index_num[20];
char   **data_ptr;
char   **n_data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
NDXptr index;
NFMlist list_struct;
static char *fname = "NFAadd_acl";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_acl_attributes (NFMuser_id, &attr_list, &data_list,
                                       &value_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (NFI_E_FAILURE);
        }

    status = MEMbuild_array (attr_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct(NFI, NFI_E_MEMORY,"%s%s","NFMadd_acl","MEMbuild_array");
        return (NFI_E_FAILURE);
        }

    data_ptr = (char **) attr_list->data_ptr;

    NFMRfill_index (attr_list, &index);

    count = 0;
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if ((strcmp (data_ptr[i+index.r], "Y") == 0) &&
            (strcmp (data_ptr[i+index.w], "Y") == 0))
            ++count;
        }

    _NFIdebug ((fname, "Displayable fields : <%d>\n", count));

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct(NFI, NFI_E_MEMORY,"%s%s","NFMadd_acl","MEMbuild_array");
        return (NFI_E_FAILURE);
        }

    n_data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct(NFI, NFI_E_MEMORY,"%s%s","NFMadd_acl","MEMbuild_array");
        return (NFI_E_FAILURE);
	}

    data.num_of_rows = count;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 15;
    data.col_width[1] = 10;
    data.col_width[2] = 20;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Access Control List Name");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=0; i<tot_data; i+=data.num_of_cols)
        data.selectable[i+2] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "ACL Name");

    for (i=0, j=0; i<tot_data; j+=attr_list->columns)
        {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) &&
            (strcmp (data_ptr[j+index.w], "Y") == 0))
            {
            if (strcmp (data_ptr[j+index.syn], "") != 0)
                NFAput_string (&data.data[i], data_ptr[j+index.syn]);
            else
                NFAput_string (&data.data[i], data_ptr[j+index.name]);
            NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);
            i+=data.num_of_cols;
            }
        }

    for (i=2, j=0, k=0; i<tot_data; j+=attr_list->columns, ++k)
        {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) &&
            (strcmp (data_ptr[j+index.w], "Y") == 0))
            {
            /* see if there is a value list for this attribute */
            if (strcmp (data_ptr[j+index.list], "0") == 0)
                {
                /* if not, insert data from the data list */
                NFAput_string (&data.data[i], n_data_ptr[k]);
                i+=data.num_of_cols;
                }
            else
                {
                /* if so display the list and let them choose the value */
                status = NFAget_value_list_index (data_ptr[j+index.list],
                            value_list, data_ptr[j+index.name],
                            data_ptr[j+index.syn], index_num);
                if (status != NFI_S_SUCCESS)
                    {
                    MEMclose (&attr_list);
                    MEMclose (&value_list);
                    MEMclose (&data_list);
                    return (status);
                    }

                NFAput_string (&data.data[i], index_num);
                data.selectable[i] = 0;

                /* if this is a workflow value list, save the workflow name */
                if (strcmp (data_ptr[j+index.nfm], "n_workflowno") == 0)
                    {
                    status = NFAget_value_list_name (data_ptr[j+index.list],
                                value_list, index_num, wf_name);
                    strcpy(NFMworkflow, wf_name);
                    if (status != NFI_S_SUCCESS)
                        {
                        MEMclose (&attr_list);
                        MEMclose (&value_list);
                        MEMclose (&data_list);
                        return (status);
                        }
                    }
                i+=data.num_of_cols;
                }
            }
        }

    _NFIdebug ((fname, "workflow : <%s>\n", wf_name));

    /* process column form until an ACL Name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFAput_and_validate_data (data.data, 2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFAvalidate_nulls (attr_list, index, data, 2,
                                        &FORM_FILLED);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=0; i<tot_data; i+=data.num_of_cols)
        {
        for (j=0, k=0; k<data_list->columns; j+=attr_list->columns, ++k)
            {
            if (((strcmp (data_ptr[j+index.syn], data.data[i]) == 0) ||
                 (strcmp (data_ptr[j+index.name], data.data[i]) == 0)) &&
                (strcmp (data_ptr[j+index.w], "Y") == 0))
                {
                status = MEMwrite_data (data_list, data.data[i+2], 1, k+1);
                if (status != MEM_S_SUCCESS)
                    {
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    MEMclose (&value_list);
                    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                    free (data.data);
                    ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMadd_acl",
				    "MEMwrite_data");
                    return (NFI_E_FAILURE);
                    }
                if (strcmp (data_ptr[j+index.nfm], "n_aclname") == 0)
                    strcpy (acl_name, data.data[i+2]);
                break;
                }
            }
        }

    _NFIdebug ((fname, "ACL Name : <%s>\n", acl_name));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");    

    status = NFMRadd_acl (NFMuser_id, attr_list, data_list);

    _NFIdebug ((fname, "NFMadd_acl -> <0x%.8x>\n", status));

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    
    if (status == NFM_S_SUCCESS)
        strcpy (NFMacl, acl_name);

    return (NFI_S_SUCCESS);
}


