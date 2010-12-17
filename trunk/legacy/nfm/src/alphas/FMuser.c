#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"
#include "ERR.h"
#include "DEBUG.h"

extern char WORKING_user[20];

long add_user ()

{
long   status;
int    i, j, k;
int    tot_data;
int    max_attr_len = 0;
int    max_syn_len = 0;
int    max_dtype_len = 0;
int    pos;
int    count = 0;
struct SCcolumn_data_st data;
int    FORM_FILLED;
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr user_attr = NULL;
MEMptr user_data = NULL;
MEMptr user_value = NULL;
NDXptr index;

static char *fname = "NFIadd_user";

    status = NFMRquery_add_user_attributes (NFMuser_id, &user_attr, &user_data,
                                            &user_value);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&user_attr);
        MEMclose (&user_data);
        MEMclose (&user_value);
        return (status);
        }

    status = MEMbuild_array (user_attr);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&user_attr);
        MEMclose (&user_data);
        MEMclose (&user_value);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMadd_user","MEMbuild_array");
        return (status);
        }

    data_ptr = (char **) user_attr->data_ptr;
    column_ptr = (char **) user_attr->column_ptr;
    
    NFMRfill_index (user_attr, &index);

    for (i=0; i<user_attr->rows*user_attr->columns; i+=user_attr->columns)
        {
        if ((strcmp (data_ptr[i+index.r], "Y") == 0) ||
            (strcmp (data_ptr[i+index.w], "Y") == 0))
            ++count;
        }

    _NFIdebug(( fname, "Displayable fields : <%d>\n", count));

    pos = 6;
    data.num_of_rows = count + 2;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    status = NFAfind_len (data_ptr, column_ptr, index, 
                          (user_attr->rows*user_attr->columns),
                          user_attr->columns, &max_attr_len, &max_syn_len,
                          &max_dtype_len);
    
    data.col_width[0] = max_syn_len + 2;
    data.col_width[1] = 10;
    data.col_width[2] = max_dtype_len;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Add a User to I/NFM");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+2; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Attribute");
    NFAput_string (&data.data[1], "Data Type");

    for (i=pos, j=0; i<tot_data; j+=user_attr->columns)
        {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0))
            {
            NFAput_string (&data.data[i], data_ptr[j+index.syn]);
            NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<user_attr->rows*user_attr->columns; i+=user_attr->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.nfm], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "N") == 0) &&
                 (strcmp (data_ptr[i+index.w], "Y") == 0)))
                {
                data.hidden[j+2] = 1;
                break;
                }
            }
        }

    /* process column form until file_name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug((fname, "Return from SCprocess_column_form -> %d\n", 
			data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFAput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFAvalidate_nulls (user_attr, index, data, pos,
                                        &FORM_FILLED);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&user_attr);
        MEMclose (&user_data);
        MEMclose (&user_value);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    status = MEMbuild_array (user_data);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&user_attr);
        MEMclose (&user_data);
        MEMclose (&user_value);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMadd_user","MEMbuild_array");
        return (status);
        }

    n_data_ptr = (char **) user_data->data_ptr;

    for (i=pos+2, j=0, k=0; k<user_data->columns; j+=user_attr->columns, ++k)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            status = MEMwrite_data (user_data, data.data[i], 1, k+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&user_attr);
                MEMclose (&user_data);
                MEMclose (&user_value);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
	        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMadd_user",
				"MEMwrite_data");
                return (status);
                }
            i+=data.num_of_cols;
            }
        }

    status = NFMRtic_it( user_data );
    if( status != NFM_S_SUCCESS )
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&user_attr);
        MEMclose (&user_data);
        MEMclose (&user_value);
        ERRload_struct( NFI, NFI_E_ADD_USER, NULL, NULL );
        return( NFI_E_ADD_USER );
    }

    SCdisplay_msg ("Working..");    

    status = NFMRadd_user (NFMuser_id, user_attr, user_data);

    _NFIdebug(( fname, "Return from NFMRadd_user -> <0x%.8x>\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);
    MEMclose (&user_attr);
    MEMclose (&user_data);
    MEMclose (&user_value);

    if (status != NFM_S_SUCCESS)
	return( status );
    
    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
    
    return (NFI_S_SUCCESS); 
}


long change_user ()

{
long   status;
int    i, j, k;
int    tot_data;
int    max_attr_len = 0;
int    max_syn_len = 0;
int    max_dtype_len = 0;
int    pos;
int    count = 0;
int    FORM_FILLED;
struct SCcolumn_data_st data;
char   user_name[21];
char   index_num[20];
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
NDXptr index;

static char *fname = "NFIchange_user";

    SCdisplay_msg ("Working..");    

    status = NFMRquery_change_user_attributes (NFMuser_id, WORKING_user,&attr_list, 
					       &data_list, &value_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);

    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    status = MEMbuild_array (value_list);

    NFMRfill_index (attr_list, &index);

    count = 0;
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (((strcmp (data_ptr[i+index.r], "Y") == 0) ||
            (strcmp (data_ptr[i+index.w], "Y") == 0)) &&
            (strcmp (data_ptr[i+index.u], "Y") == 0))
            ++count;
        }

    _NFIdebug(( fname, "Displayable fields : <%d>\n", count));

    pos = 6;
    data.num_of_rows = count + 2;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    status = NFAfind_len (data_ptr, column_ptr, index, 
                          (attr_list->rows*attr_list->columns),
                          attr_list->columns, &max_attr_len, &max_syn_len,
                          &max_dtype_len);
    
    data.col_width[0] = max_syn_len + 2;
    data.col_width[1] = 10;
    data.col_width[2] = max_dtype_len;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter User Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+2; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Attribute");
    NFAput_string (&data.data[1], "Data Type");

    for (i=pos, j=0; i<tot_data; j+=attr_list->columns)
        {
        if (((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0)) &&
            (strcmp (data_ptr[j+index.u], "Y") == 0))
            {
            if (strcmp (data_ptr[j+index.syn], "") != 0)
                NFAput_string (&data.data[i], data_ptr[j+index.syn]);
            else
                NFAput_string (&data.data[i], data_ptr[j+index.name]);
            NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.nfm], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "N") == 0) &&
                 (strcmp (data_ptr[i+index.w], "Y") == 0) &&
                 (strcmp (data_ptr[i+index.u], "Y") == 0)))
                {
                data.hidden[j+2] = 1;
                break;
                }
            }
        }

    /* if attribute is readable but not writeable, suppress input */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.nfm], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "Y") == 0) &&
                 (strcmp (data_ptr[i+index.w], "N") == 0) &&
                 (strcmp (data_ptr[i+index.u], "Y") == 0)))
                {
                data.selectable[j+2] = 0;
                break;
                }
            }
        }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMchange_user",
			"MEMbuild_array");
        return (status);
        }

    n_data_ptr = (char **) data_list->data_ptr;

    for (i=pos+2, j=0, k=0; i<tot_data; j+=attr_list->columns, ++k)
        {
        if (((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0)) &&
            (strcmp (data_ptr[j+index.u], "Y") == 0))
            {
            NFAput_string (&data.data[i], n_data_ptr[k]);

            if (strcmp (data_ptr[j+index.list], "0") != 0)
                {
                /* if there is a value list, display the list and let them
                   choose the value */
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
                }

            i+=data.num_of_cols;
            }
        }

    /* process column form until file_name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "return from SCprocess_column_form -> %d\n", 
			data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFAput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);
            status = NFAvalidate_nulls (attr_list, index, data, pos,
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
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=pos; i<tot_data; i+=data.num_of_cols)
        {
        for (j=0, k=0; k<data_list->columns; j+=attr_list->columns, ++k)
            {
            if (((strcmp (data_ptr[j+index.syn], data.data[i]) == 0) ||
                 (strcmp (data_ptr[j+index.name], data.data[i]) == 0)) &&
                 ((strcmp (data_ptr[j+index.w], "Y") == 0) &&
                 (strcmp (data_ptr[j+index.u], "Y") == 0)))
                {
                status = MEMwrite_data (data_list, data.data[i+2], 1, k+1);
                if (status != MEM_S_SUCCESS)
                    {
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    MEMclose (&value_list);
                    NFAfree_list(data.data,data.num_of_rows, data.num_of_cols);
                    free (data.data);
	            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_user",
				    "MEMwrite_data");
                    return (status);
                    }

                /* save user name */
                if (strcmp (data_ptr[j+index.nfm], "n_username") == 0)
		{
		    strcpy (user_name, data.data[i+2] );
                    strcpy (WORKING_user, data.data[i+2]);
		}
                break;
                }
            }
        }

    status = NFMRtic_it( data_list );
    if( status != NFM_S_SUCCESS )
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_CHANGE_USER, "%s", WORKING_user );
        return( NFI_E_CHANGE_USER );
    }

    SCdisplay_msg ("Working..");    

    status = NFMRchange_user (NFMuser_id, attr_list, data_list);

    _NFIdebug(( fname, "return from NFMchange_user -> <0x%.8>x", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    
    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

