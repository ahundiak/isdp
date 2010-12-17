#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

long add_sa ()

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
char   sa_type[NFM_TYPE+1];
char   storage_area[NFM_SANAME+1];
char   node_name[NFM_NODENAME+1];
char   node_num[INTEGER+1];
char   index_num[INTEGER+1];
MEMptr sa_attr = NULL;
MEMptr sa_data = NULL;
MEMptr sa_value = NULL;
NDXptr index;
static char *fname = "NFAadd_sa";

    status = NFAget_node_info (node_name, node_num);
    if (status != NFI_S_SUCCESS)
        return (status);

    status = NFMRquery_add_st_area_attributes (NFMuser_id, &sa_attr, &sa_data,
                                               &sa_value);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&sa_attr);
        MEMclose (&sa_data);
        MEMclose (&sa_value);
        return (status);
        }

    status = MEMbuild_array (sa_attr);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&sa_attr);
        MEMclose (&sa_data);
        MEMclose (&sa_value);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMadd_sa",
			"MEMbuild_array");
        return (status);
        }

    data_ptr = (char **) sa_attr->data_ptr;
    column_ptr = (char **) sa_attr->column_ptr;
    
    NFMRfill_index (sa_attr, &index);

    for (i=0; i<sa_attr->rows*sa_attr->columns; i+=sa_attr->columns)
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
                          (sa_attr->rows*sa_attr->columns),
                          sa_attr->columns, &max_attr_len, &max_syn_len,
                          &max_dtype_len);
    
    data.col_width[0] = max_syn_len + 2;
    data.col_width[1] = 10;
    data.col_width[2] = max_dtype_len;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "Add a Storage Area to Node \'%s\'", node_name);

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

    for (i=pos, j=0; i<tot_data; j+=sa_attr->columns)
        {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0))
            {
            NFAput_string (&data.data[i], data_ptr[j+index.syn]);
            NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);
            if ((strcmp (data_ptr[j+index.list], "0") != 0) &&
		(strcmp (data_ptr[j+index.name], "n_nodeno") != 0 ) )
                {
                status = NFAget_value_list_index (data_ptr[j+index.list],
                            sa_value, data_ptr[j+index.name],
                            data_ptr[j+index.syn], index_num);
                if (status != NFI_S_SUCCESS)
                    {
                    MEMclose (&sa_attr);
                    MEMclose (&sa_value);
                    MEMclose (&sa_data);
                    return (status);
                    }
                NFAput_string (&data.data[i+2], index_num);
		data.selectable[i+2] = 0;
                }

            /* load chosen storage area */
            if (strcmp (data_ptr[j+index.nfm], "n_nodeno") == 0)
                {
                data.selectable[i+2] = 0;
                NFAput_string (&data.data[i+2], node_num);
                }
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<sa_attr->rows*sa_attr->columns; i+=sa_attr->columns)
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

    /* process column form until all information has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n", 
			data.sts));

        if (data.sts != FORM_CANCELED)
            {
            /* make string valid length and strip trailing blanks */
            status = NFAput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFAvalidate_nulls (sa_attr, index, data, pos,
                                        &FORM_FILLED);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&sa_attr);
        MEMclose (&sa_data);
        MEMclose (&sa_value);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }
    
    status = MEMbuild_array (sa_data);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&sa_attr);
        MEMclose (&sa_data);
        MEMclose (&sa_value);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMadd_sa",
			"MEMbuild_array");
        return (status);
        }

    n_data_ptr = (char **) sa_data->data_ptr;

    for (i=pos+2, j=0, k=0; k<sa_data->columns; j+=sa_attr->columns, ++k)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            status = MEMwrite_data (sa_data, data.data[i], 1, k+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&sa_attr);
                MEMclose (&sa_data);
                MEMclose (&sa_value);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
	        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMadd_sa",
				"MEMwrite_data");
                return (status);
                }
            if (strcmp (data_ptr[j+index.nfm], "n_saname") == 0)
                strcpy (storage_area, data.data[i]);

	    if (strcmp (data_ptr[j+index.nfm], "n_type") == 0)
		strcpy (sa_type, data.data[i] );

            i+=data.num_of_cols;
            }
        }

    SCdisplay_msg ("Working..");

    status = NFMRadd_storage_area (NFMuser_id, sa_attr, sa_data);

    switch (status)
        {
        case NFM_S_SUCCESS:
	    if( (strcmp( sa_type, "w" ) == 0 ) ||
		(strcmp( sa_type, "W" ) == 0 ))
		strcpy( NFMworking, storage_area );
	    else
	        strcpy( NFMstorage, storage_area);

            break;
            
        default:
            break;
        }

    _NFIdebug(( fname, "Return from NFMRadd_sa -> 0x%.8x\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);
    MEMclose (&sa_attr);
    MEMclose (&sa_data);
    MEMclose (&sa_value);
    
    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
    
    return (NFI_S_SUCCESS); 
}

long change_sa ()

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
char   index_num[20];
char   sa_type[NFM_TYPE+1];
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
char   current_storage[200];
char   chosen_storage[200];
char   new_storage[200];
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
NDXptr index;
static char *fname = "NFAchange_sa";

    SCdisplay_msg ("Working..");    

/*    strcpy (current_storage,  NFMworking);*/
/*
    strcpy (chosen_storage, NFMstorage);

    _NFIdebug((fname,  "NFMworking is <%s>\n", current_storage));
    _NFIdebug((fname,  "NFMstorage is <%s>\n", chosen_storage));
*/
    status = NFMRquery_change_sa_attributes (NFMuser_id, NFMstorage,
				&attr_list, &data_list, &value_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_sa",
			"MEMbuild_array");
        return (status);
        }

    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_sa",
			"MEMbuild_array");
        return (status);
        }


    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_sa",
			"MEMbuild_array");
        return (status);
        }

    n_data_ptr = (char **) data_list->data_ptr;
    if( data_list->rows == 0 )
    {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFM, NFM_E_NO_ST_AREAS, NULL, NULL );
        return (NFM_E_NO_ST_AREAS);
    }
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
    strcpy (data.title, "Enter Storage Area Information");

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
                _NFIdebug((fname,  "string is <%s>\n", data.data[i]));
            NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);
                _NFIdebug((fname,  "string2 is <%s>\n", data.data[i]));
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

    for (i=pos+2, j=0, k=0; i<tot_data; j+=attr_list->columns, ++k)
        {
        if (((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0)) &&
            (strcmp (data_ptr[j+index.u], "Y") == 0))
            {
            NFAput_string (&data.data[i], n_data_ptr[k]);
            if (strcmp (data_ptr[j+index.list], "0") != 0)
                {

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

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n", 
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
	            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_sa",
				    "MEMwrite_data");
                    return (status);
                    }

                /* save sa name */
                if (strcmp (data_ptr[j+index.nfm], "n_saname") == 0)
                    strcpy (NFMstorage, data.data[i+2]);
                _NFIdebug((fname, "what is NFMstorage<%s>\n",NFMstorage));
                if (strcmp (data_ptr[j+index.nfm], "n_type")== 0)
                   strcpy(sa_type, data.data[i+2]);

                break;
               }

            }
                if ((strcmp (sa_type, "w")== 0) ||
                    (strcmp(sa_type,  "W")== 0)) /* &&
                   (strcmp(NFMworking, NFMstorage)==0))*/
/*
                     (strcmp(current_storage, chosen_storage)==0)&&
                      (strcmp(current_storage, new_storage)==0));
                    strcpy (current_storage, new_storage);
*/
                    strcpy (NFMworking, NFMstorage);
/*
                    _NFIdebug((fname, "current_storage <%s> and new__storage <%s>,NFMworking <%s> \n", current_storage, new_storage, NFMworking));
*/
        }

    SCdisplay_msg ("Working..");    

    status = NFMRchange_sa (NFMuser_id, attr_list, data_list);

    _NFIdebug(( fname, "Return from NFMchange_sa -> 0x%.8x\n", status));

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

long add_util_sa (node_name, node_num)
char   *node_name;
char   *node_num;
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
char   index_num[INTEGER+1];
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
char   storage_area[20];
MEMptr sa_attr = NULL;
MEMptr sa_data = NULL;
MEMptr sa_value = NULL;
NDXptr index;
static char *fname = "NFAadd_util_sa";

    status = NFMRquery_add_st_area_attributes (NFMuser_id, &sa_attr, &sa_data,
                                               &sa_value);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&sa_attr);
        MEMclose (&sa_data);
        MEMclose (&sa_value);
        return (status);
        }

    status = MEMbuild_array (sa_attr);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&sa_attr);
        MEMclose (&sa_data);
        MEMclose (&sa_value);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMadd_util_sa",
			"MEMbuild_array");
        return (NFI_E_MEMORY);
        }

    data_ptr = (char **) sa_attr->data_ptr;
    column_ptr = (char **) sa_attr->column_ptr;
    
    NFMRfill_index (sa_attr, &index);

    for (i=0; i<sa_attr->rows*sa_attr->columns; i+=sa_attr->columns)
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
                          (sa_attr->rows*sa_attr->columns),
                          sa_attr->columns, &max_attr_len, &max_syn_len,
                          &max_dtype_len);
    
    data.col_width[0] = max_syn_len + 2;
    data.col_width[1] = 10;
    data.col_width[2] = max_dtype_len;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "Add a Utilities Storage Area to Node \'%s\'",
		 node_name);

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

    for (i=pos, j=0; i<tot_data; j+=sa_attr->columns)
        {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0))
            {
            NFAput_string (&data.data[i], data_ptr[j+index.syn]);
            NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);

            /* load chosen node number */
            if (strcmp (data_ptr[j+index.nfm], "n_nodeno") == 0)
                {
                data.selectable[i+2] = 0;
                NFAput_string (&data.data[i+2], node_num);
                }
	    else if (strcmp (data_ptr[j+index.nfm], "n_saname") == 0)
		{
		data.selectable[i+2] = 0;
		sprintf( storage_area, "%s-UTIL", node_num );
		NFAput_string (&data.data[i+2], storage_area );
		}
	    else if (strcmp (data_ptr[j+index.nfm], "n_devicetype" ) == 0 )
		{
		data.selectable[i+2] = 0;
		NFAput_string (&data.data[i+2], "HD" );
		}
	    else if (strcmp (data_ptr[j+index.nfm], "n_type" ) == 0 )
		{
		data.selectable[i+2] = 0;
		NFAput_string (&data.data[i+2], "S" );
		}
	    else if (strcmp (data_ptr[j+index.nfm], "n_nfs" ) == 0 )
		{
		data.selectable[i+2] = 0;
		NFAput_string (&data.data[i+2], "N" );
		}
            else if (strcmp (data_ptr[j+index.list], "0") != 0)
                {
                status = NFAget_value_list_index (data_ptr[j+index.list],
                            sa_value, data_ptr[j+index.name],
                            data_ptr[j+index.syn], index_num);
                if (status != NFI_S_SUCCESS)
                    {
                    MEMclose (&sa_attr);
                    MEMclose (&sa_value);
                    MEMclose (&sa_data);
                    return (status);
                    }
                NFAput_string (&data.data[i+2], index_num);
		data.selectable[i+2] = 0;
                }
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<sa_attr->rows*sa_attr->columns; i+=sa_attr->columns)
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

    /* process column form until all information has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n", 
		data.sts));

        if (data.sts != FORM_CANCELED)
            {
            /* make string valid length and strip trailing blanks */
            status = NFAput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFAvalidate_nulls (sa_attr, index, data, pos,
                                        &FORM_FILLED);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        MEMclose (&sa_attr);
        MEMclose (&sa_data);
        MEMclose (&sa_value);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }
    
    status = MEMbuild_array (sa_data);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&sa_attr);
        MEMclose (&sa_data);
        MEMclose (&sa_value);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMadd_util_sa",
			"MEMbuild_array");
        return (NFI_E_MEMORY);
        }

    n_data_ptr = (char **) sa_data->data_ptr;

    for (i=pos+2, j=0, k=0; k<sa_data->columns; j+=sa_attr->columns, ++k)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            status = MEMwrite_data (sa_data, data.data[i], 1, k+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&sa_attr);
                MEMclose (&sa_data);
                MEMclose (&sa_value);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
	        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMadd_util_sa",
			 	"MEMwrite_data");
                return (NFI_E_MEMORY);
                }
            i+=data.num_of_cols;
            }
        }

    SCdisplay_msg ("Working..");

    status = NFMRadd_storage_area (NFMuser_id, sa_attr, sa_data);

    switch (status)
        {
        case NFM_S_SUCCESS:
            break;
            
        default:
            break;
        }

    _NFIdebug(( fname, "Return from NFMRadd_util_sa -> 0x%.8x\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);
    MEMclose (&sa_attr);
    MEMclose (&sa_data);
    MEMclose (&sa_value);
    
    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
    
    return (NFI_S_SUCCESS); 
}

