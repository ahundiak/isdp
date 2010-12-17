#include "machine.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

long add_node ()

{
long   status;
long   u_status;
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
char   node_name[20];
char   node_num[12];
MEMptr node_attr = NULL;
MEMptr node_data = NULL;
MEMptr node_value = NULL;
NDXptr index;
static char *fname = "add_node";

    _NFIdebug ((fname, "Enter.\n"));

    status = NFMRquery_add_node_attributes (NFMuser_id, &node_attr, &node_data,
                                            &node_value);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&node_attr);
        MEMclose (&node_data);
        MEMclose (&node_value);
        return (status);
        }

    status = MEMbuild_array (node_attr);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&node_attr);
        MEMclose (&node_data);
        MEMclose (&node_value);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMadd_node", 
			"MEMbuild_array");
        return (status);
        }

    data_ptr = (char **) node_attr->data_ptr;
    column_ptr = (char **) node_attr->column_ptr;
    
    NFMRfill_index (node_attr, &index);

    for (i=0; i<node_attr->rows*node_attr->columns;i+=node_attr->columns )
        {
        if ((strcmp (data_ptr[i+index.r], "Y") == 0) ||
            (strcmp (data_ptr[i+index.w], "Y") == 0))
            ++count;
        }

    _NFIdebug ((fname, "Displayable fields : <%d>\n", count));

    pos = 6;
    data.num_of_rows = count + 2;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    status = NFAfind_len (data_ptr, column_ptr, index, 
                          (node_attr->rows*node_attr->columns),
                          node_attr->columns, &max_attr_len, &max_syn_len,
                          &max_dtype_len);
    
    data.col_width[0] = max_syn_len + 2;
    data.col_width[1] = 10;
    data.col_width[2] = max_dtype_len;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Add a Node to I/NFM");

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

    for (i=pos, j=0; i<tot_data; j+=node_attr->columns)
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
        for (i=0; i<node_attr->rows*node_attr->columns; i+=node_attr->columns)
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

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFAput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFAvalidate_nulls (node_attr, index, data, pos,
                                        &FORM_FILLED);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&node_attr);
        MEMclose (&node_data);
        MEMclose (&node_value);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    status = MEMbuild_array (node_data);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&node_attr);
        MEMclose (&node_data);
        MEMclose (&node_value);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMadd_node",
			"MEMbuild_array" );
        return (status);
        }

    n_data_ptr = (char **) node_data->data_ptr;

    for (i=pos+2, j=0, k=0; k<node_data->columns; j+=node_attr->columns, ++k)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            status = MEMwrite_data (node_data, data.data[i], 1, k+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&node_attr);
                MEMclose (&node_data);
                MEMclose (&node_value);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
	        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMadd_node",
				"MEMwrite_data" );
                return (status);
                }
            if (strcmp (data_ptr[j+index.nfm], "n_nodename") == 0)
                strcpy (node_name, data.data[i]);
            i+=data.num_of_cols;
            }
        }

    status = NFMRtic_it( node_data );
    if( status != NFM_S_SUCCESS )
    {
	_NFIdebug ((fname,  "NFMRtic_it : <0x%.8x>\n", status));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&node_attr);
        MEMclose (&node_data);
        MEMclose (&node_value);
	return( NFI_E_ADD_NODE );
    }

    SCdisplay_msg ("Working..");    

    status = NFMRadd_node (NFMuser_id, node_attr, node_data);

    switch (status)
        {
        case NFM_S_SUCCESS:
            sprintf (NFMnode, "%s", node_name);
	    /* Add utilities storage area
	     */
	    u_status = NFMRget_node_no( NFMuser_id, node_name, node_num);
	    if( u_status != NFM_S_SUCCESS)
	    {
		break;
	    }
	    _NFIdebug ((fname, "Node number : <%s>\n", node_num));
	    u_status = add_util_sa( node_name, node_num );
	    if( (u_status != NFI_S_SUCCESS) && 
		(u_status != NFI_W_COMMAND_CANCELLED))
	    {
		ERRload_struct( NFI, NFI_E_UTILITIES_SA, "%s", node_name);
		NFAset_message();
		SCdisplay_msg( msg );
		ERRreset_struct();
	    }
            break;
            
        default:
	    break;
        }

    _NFIdebug ((fname, "NFMRadd_node -> <0x%.8x>\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);
    MEMclose (&node_attr);
    MEMclose (&node_data);
    MEMclose (&node_value);
    
    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
    
    return (NFI_S_SUCCESS); 
}


