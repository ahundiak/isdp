#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

long NFAfill_free_list (value_list, struct_data)
    MEMptr value_list;
    struct SCfree_data_st *struct_data;
{
int    i;
int    tot_data;
int    pos = 0;
char   **data_ptr;
char   **column_ptr;
char   **format_ptr;
struct SCfree_data_st *data;

    data = struct_data;

    SCdisplay_msg ("Working..");

    MEMbuild_array (value_list);

    data_ptr = (char **) value_list->data_ptr;
    column_ptr = (char **) value_list->column_ptr;
    format_ptr = (char **) value_list->format_ptr;

    data->num_of_rows = value_list->rows;
    data->num_of_cols = value_list->columns;

    if (data->num_of_rows == 0)
        return (NFI_E_FAILURE);

    tot_data = data->num_of_cols * data->num_of_rows;
    data->freeze_rows_count = 0;
    data->freeze_cols_count = 1;
    data->max_indent = 0;
    data->select_set_expected = SELECT_SET_MULTI_ROW;

    data->col_size = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_size, 0, (data->num_of_cols * sizeof (int)));

    data->col_size[0] = 15;
    for (i=1; i<data->num_of_cols; ++i)
        data->col_size[i] = 20;

    data->col_pos = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_pos, 0 , (data->num_of_cols * sizeof (int)));

    pos = 0;
    for (i=0; i<data->num_of_cols; ++i)
        {
        data->col_pos[i] = pos;
        pos += data->col_size[i] + 2;
        }

    data->col_just = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_just, LEFT_JUSTIFIED, (data->num_of_cols * sizeof (int)));
    
    data->h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h1_pos, 0, sizeof (int) + 1);
    data->h1_pos[0] = 0;
    data->h1_pos[1] = -1;

    data->h2_pos = (int *) malloc ((data->num_of_cols * sizeof (int)) + 1);
    memset (data->h2_pos, 0, (data->num_of_cols * sizeof (int)) + 1);
    for (i=0; i<data->num_of_cols; ++i)
        data->h2_pos[i] = data->col_pos[i];
    data->h2_pos[i] = -1;
    
    data->h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h3_pos, 0, sizeof (int) + 1);
    data->h3_pos[0] = 0;
    data->h3_pos[1] = -1;
    
    data->h1_data = (char **) malloc (sizeof (char *));
    memset (data->h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h1_data[0], "");
    
    data->h2_data = (char **) malloc (data->num_of_cols * (sizeof (char *)));
    memset (data->h2_data, NULL, data->num_of_cols * (sizeof (char *)));
    for (i=0; i<data->num_of_cols; ++i)
        NFAput_string (&data->h2_data[i], column_ptr[i]);
    
    data->h3_data = (char **) malloc (sizeof (char *));
    memset (data->h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h3_data[0], "");
    
    data->select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data->select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data->data = (char **) malloc (tot_data * sizeof (char *));
    memset (data->data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        NFAput_string (&data->data[i], data_ptr[i]);

    return (NFI_S_SUCCESS);
}


long NFAfill_free_data_list (data_list, value_list, data_col, struct_data)
    MEMptr data_list;
    MEMptr value_list;
    int    data_col;   /* data column to key off of when displaying list */
    struct SCfree_data_st *struct_data;
{
int    i, j, k, m;
int    tot_data;
int    pos = 0;
char   **data_ptr;
char   **column_ptr;
char   **value_ptr;
char   **value_col_ptr;
struct SCfree_data_st *data;
static char *fname = "NFAfill_free_data_list";

    _NFIdebug(( fname, "data col : <%d>\n", data_col));

    data = struct_data;

    SCdisplay_msg ("Working..");

    MEMbuild_array (data_list);

    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    MEMbuild_array (value_list);

    value_ptr = (char **) value_list->data_ptr;
    value_col_ptr = (char **) value_list->column_ptr;

    data->num_of_rows = data_list->rows;
    data->num_of_cols = value_list->columns;

    if (data->num_of_rows == 0)
        return (NFI_E_FAILURE);

    tot_data = data->num_of_cols * data->num_of_rows;
    data->freeze_rows_count = 0;
    data->freeze_cols_count = 1;
    data->max_indent = 0;
    data->select_set_expected = SELECT_SET_MULTI_ROW;

    data->col_size = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_size, 0, (data->num_of_cols * sizeof (int)));

    data->col_size[0] = 15;
    for (i=1; i<data->num_of_cols; ++i)
        data->col_size[i] = 20;

    data->col_pos = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_pos, 0 , (data->num_of_cols * sizeof (int)));

    pos = 0;
    for (i=0; i<data->num_of_cols; ++i)
        {
        data->col_pos[i] = pos;
        pos += data->col_size[i] + 2;
        }

    data->col_just = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_just, LEFT_JUSTIFIED, (data->num_of_cols * sizeof (int)));
    
    data->h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h1_pos, 0, sizeof (int) + 1);
    data->h1_pos[0] = 0;
    data->h1_pos[1] = -1;

    data->h2_pos = (int *) malloc ((data->num_of_cols * sizeof (int)) + 1);
    memset (data->h2_pos, 0, (data->num_of_cols * sizeof (int)) + 1);
    for (i=0; i<data->num_of_cols; ++i)
        data->h2_pos[i] = data->col_pos[i];
    data->h2_pos[i] = -1;
    
    data->h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h3_pos, 0, sizeof (int) + 1);
    data->h3_pos[0] = 0;
    data->h3_pos[1] = -1;
    
    data->h1_data = (char **) malloc (sizeof (char *));
    memset (data->h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h1_data[0], "");
    
    data->h2_data = (char **) malloc (data->num_of_cols * (sizeof (char *)));
    memset (data->h2_data, NULL, data->num_of_cols * (sizeof (char *)));
    for (i=0; i<data->num_of_cols; ++i)
        NFAput_string (&data->h2_data[i], value_col_ptr[i]);
    
    data->h3_data = (char **) malloc (sizeof (char *));
    memset (data->h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h3_data[0], "");
    
    data->select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data->select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data->data = (char **) malloc (tot_data * sizeof (char *));
    memset (data->data, NULL, (tot_data * sizeof (char *)));

    for (j=data_col,i=0;
         j<data_list->rows*data_list->columns, i<tot_data;
         j+=data_list->columns)
        {
        for (k=0; k<value_list->columns*value_list->rows; k+=value_list->columns)
            {
            if (strcmp (data_ptr[j], value_ptr[k]) == 0)
                {
                for (m=0; m<value_list->columns; ++m)
                    {
                    NFAput_string (&data->data[i++], value_ptr[k+m]);
                    }

                }  /* if value matches data */

            }  /* end for all value rows */

        }  /* end for all data rows */

    return (NFI_S_SUCCESS);
}


long NFAexclusive_fill_free_list (data_list, value_list, data_col, struct_data)
    MEMptr data_list;
    MEMptr value_list;
    int    data_col;   /* data column to key off of when displaying list */
    struct SCfree_data_st *struct_data;
{
int    i, j, k, m;
int    tot_data;
int    pos = 0;
int    IN_DATA_LIST;
char   **data_ptr;
char   **column_ptr;
char   **value_ptr;
char   **value_col_ptr;
struct SCfree_data_st *data;
static char *fname = "NFAexclusive_fill_free_list";

    _NFIdebug(( fname, "data col : <%d>\n", data_col));

    data = struct_data;

    SCdisplay_msg ("Working..");

    MEMbuild_array (data_list);

    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    MEMbuild_array (value_list);

    value_ptr = (char **) value_list->data_ptr;
    value_col_ptr = (char **) value_list->column_ptr;

    data->num_of_rows = (value_list->rows) - (data_list->rows);
    data->num_of_cols = value_list->columns;

    if (data->num_of_rows == 0)
        return (NFI_E_FAILURE);

    _NFIdebug(( fname, "rows : <%d>\n", data->num_of_rows));
    _NFIdebug(( fname, "cols : <%d>\n", data->num_of_cols));

    tot_data = data->num_of_cols * data->num_of_rows;
    data->freeze_rows_count = 0;
    data->freeze_cols_count = 1;
    data->max_indent = 0;
    data->select_set_expected = SELECT_SET_MULTI_ROW;

    data->col_size = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_size, 0, (data->num_of_cols * sizeof (int)));

    data->col_size[0] = 15;
    for (i=1; i<data->num_of_cols; ++i)
        data->col_size[i] = 20;

    data->col_pos = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_pos, 0 , (data->num_of_cols * sizeof (int)));

    pos = 0;
    for (i=0; i<data->num_of_cols; ++i)
        {
        data->col_pos[i] = pos;
        pos += data->col_size[i] + 2;
        }

    data->col_just = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_just, LEFT_JUSTIFIED, (data->num_of_cols * sizeof (int)));
    
    data->h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h1_pos, 0, sizeof (int) + 1);
    data->h1_pos[0] = 0;
    data->h1_pos[1] = -1;

    data->h2_pos = (int *) malloc ((data->num_of_cols * sizeof (int)) + 1);
    memset (data->h2_pos, 0, (data->num_of_cols * sizeof (int)) + 1);
    for (i=0; i<data->num_of_cols; ++i)
        data->h2_pos[i] = data->col_pos[i];
    data->h2_pos[i] = -1;
    
    data->h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h3_pos, 0, sizeof (int) + 1);
    data->h3_pos[0] = 0;
    data->h3_pos[1] = -1;
    
    data->h1_data = (char **) malloc (sizeof (char *));
    memset (data->h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h1_data[0], "");
    
    data->h2_data = (char **) malloc (data->num_of_cols * (sizeof (char *)));
    memset (data->h2_data, NULL, data->num_of_cols * (sizeof (char *)));
    for (i=0; i<data->num_of_cols; ++i)
        NFAput_string (&data->h2_data[i], value_col_ptr[i]);
    
    data->h3_data = (char **) malloc (sizeof (char *));
    memset (data->h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h3_data[0], "");
    
    data->select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data->select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data->data = (char **) malloc (tot_data * sizeof (char *));
    memset (data->data, NULL, (tot_data * sizeof (char *)));

    for (k=0, i=0;
         k<value_list->columns*value_list->rows, i<tot_data;
         k+=value_list->columns)
        {
        IN_DATA_LIST = FALSE;
        for (j=data_col; j<data_list->rows*data_list->columns;
             j+=data_list->columns)
            {
            if (strcmp (value_ptr[k], data_ptr[j]) == 0)
                {
                IN_DATA_LIST = TRUE;
                break;
                }
 
            }  /* end for all data rows */

        if (!IN_DATA_LIST)
            {
            for (m=0; m<value_list->columns; ++m)
                {
                NFAput_string (&data->data[i++], value_ptr[k+m]);
                }

            }  /* if value row is not in data list */

        }  /* end for all value rows */

    return (NFI_S_SUCCESS);
}


long NFAfind_acl_name (acl_name)
    char *acl_name;

{
int  tot_data;
long status;
int  FORM_FILLED = FALSE;
struct SCcolumn_data_st data;
static char *fname = "NFAfind_acl_name"; 

    data.num_of_rows = 1;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 10;
    data.col_width[1] = 20;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "%s", "Enter ACL Name");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[1] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "ACL Name");

    /* process column form until an ACL Name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        if (data.sts != FORM_CANCELED)
            {
            status = NFAvalidate_string ("char(20)", data.data[1]);
            if (strcmp (data.data[1], "") == 0)
                {
                FORM_FILLED = FALSE;
                SCdisplay_msg ("NFM:  Must Enter ACL Name.");
                }
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    strcpy (acl_name, data.data[1]);

    _NFIdebug(( fname, "ACL Name : <%s>\n", acl_name));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    return (NFI_S_SUCCESS);
}


long NFAget_value_list_index (list_num, value_list, attr_name, synonym,
                              index_num)
    char   *list_num;
    MEMptr value_list;
    char   *attr_name;
    char   *synonym;
    char   *index_num;

{
int  tot_data;
int  i, j, pos;
long status;
int  no_row_selected = TRUE;
long list_no;
long NFAget_range_value();
char **data_ptr;
char **column_ptr;
struct SCfree_data_st data;
static char *fname = "NFAget_value_list_index"; 

    list_no = atol (list_num);

    _NFIdebug(( fname, "list_no : <%d>\n", list_no));

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMbuild" );
        return (NFI_E_MEMORY);
        }

    status = MEMreset_buffer_no (value_list, list_no);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMreset" );
        return (NFI_E_MEMORY);
        }

    data_ptr = (char **) value_list->data_ptr;
    column_ptr = (char **) value_list->column_ptr;

    /* if there are no rows, return ERROR */

    if (value_list->rows == 0)
        return (NFI_E_FAILURE);

    /* Check to see if this is a range attribute */
    if( strcmp( data_ptr[0], "NFM_RANGE" ) == 0 )
    {
    	status = NFAget_range_value (list_num, value_list, attr_name, 
				     synonym, index_num);
	_NFIdebug(( fname, "NFAget_range_value <0x%.8x>\n", status ));
	return( status );	
    }
    /* if there is only one row, use this index without displaying it  */

    if (value_list->rows == 1)
        {
        strcpy (index_num, data_ptr[0]);
        return (NFI_S_SUCCESS);
        }

    data.num_of_rows = value_list->rows;
    data.num_of_cols = value_list->columns;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0 , (data.num_of_cols * sizeof (int)));

    data.col_size[0] = 15;
    for (i=1; i<data.num_of_cols; ++i)
        data.col_size[i] = 30;

    pos = 0;
    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));

    for (i=0; i<data.num_of_cols; ++i)
        {
        data.col_pos[i] = pos;
        pos += data.col_size[i] + 2;
        }

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;
/*
    for (i=0; i<data.num_of_cols; ++i)
        data.h2_pos[i] = data.col_pos[i];
    data.h2_pos[i] = -1;
*/  
    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (data.num_of_cols * (sizeof (char *)));
    memset (data.h2_data, NULL, data.num_of_cols * (sizeof (char *)));
    NFAput_string (&data.h2_data[0], "");
/*
    for (i=0; i<data.num_of_cols; ++i)
        NFAput_string (&data.h2_data[i], column_ptr[i]);
*/
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");

    if (strcmp (synonym, "") != 0)
        sprintf (data.title, "Choose \'%s\'", synonym);
    else
        sprintf (data.title, "Choose \'%s\'", attr_name);

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        {
	_NFIdebug(( fname, "data_ptr <%s>\n", data_ptr[i]));
        NFAput_string (&data.data[i], data_ptr[i]);
        }

    status = SCprocess_free_form (&data, NFMprint_file);
    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
            {
            no_row_selected = FALSE;
            strcpy (index_num, data.data[j]);
               break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (no_row_selected)
        return (NFI_E_FAILURE);
    else
        return (NFI_S_SUCCESS);
}

long NFAget_value_list_index_name (list_num, value_list, attr_name, synonym,
                              index_name)
    char   *list_num;
    MEMptr value_list;
    char   *attr_name;
    char   *synonym;
    char   *index_name;

{
int  tot_data;
int  i, j, pos;
long status;
int  no_row_selected = TRUE;
long list_no;
char **data_ptr;
char **column_ptr;
struct SCfree_data_st data;
static char *fname = "NFAget_value_list_index_name"; 

    list_no = atol (list_num);

    _NFIdebug(( fname, "list_no : <%d>\n", list_no));

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMbuild" );
        return (NFI_E_MEMORY);
        }

    if( _NFMdebug_st.NFIdebug_on )
        MEMprint_buffers( "VALUE LIST", value_list, _NFMdebug_st.NFIdebug_file);

    status = MEMreset_buffer_no (value_list, list_no);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMreset" );
        return (NFI_E_MEMORY);
        }

    data_ptr = (char **) value_list->data_ptr;
    column_ptr = (char **) value_list->column_ptr;

    /* if there are no rows, return ERROR */

    if (value_list->rows == 0)
        return (NFI_E_FAILURE);

    /* if there is only one row, use this index without displaying it  */

    if (value_list->rows == 1)
        {
        strcpy (index_name, data_ptr[1]);
        return (NFI_S_SUCCESS);
        }

    data.num_of_rows = value_list->rows;
    data.num_of_cols = value_list->columns;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0 , (data.num_of_cols * sizeof (int)));

    data.col_size[0] = 15;
    for (i=1; i<data.num_of_cols; ++i)
        data.col_size[i] = 30;

    pos = 0;
    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));

    for (i=0; i<data.num_of_cols; ++i)
        {
        data.col_pos[i] = pos;
        pos += data.col_size[i] + 2;
        }

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;

    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (data.num_of_cols * (sizeof (char *)));
    memset (data.h2_data, NULL, data.num_of_cols * (sizeof (char *)));
    NFAput_string (&data.h2_data[0], "");
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");

    sprintf (data.title, "Choose \'%s\'", synonym);

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        {
	_NFIdebug(( fname, "data_ptr <%s>\n", data_ptr[i]));
        NFAput_string (&data.data[i], data_ptr[i]);
        }

    status = SCprocess_free_form (&data, NFMprint_file);
    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
            {
            no_row_selected = FALSE;
            strcpy (index_name, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (no_row_selected)
        return (NFI_E_FAILURE);
    else
        return (NFI_S_SUCCESS);
}

long NFAget_value_list_index_name_new (list_num, value_list,file_name, 
            attr_name, synonym, index_name)
    char   *list_num;
    MEMptr value_list;
    char   *file_name;
    char   *attr_name;
    char   *synonym;
    char   *index_name;

{
int  tot_data;
int  i, j, pos;
long status;
int  no_row_selected = TRUE;
long list_no;
char **data_ptr;
char **data_ptr1;
char **column_ptr;
char **column_ptr1;
struct SCfree_data_st data;
MEMptr data_list = NULL;
static char *fname = "NFAnewget_value_list_index_name"; 

    list_no = atol (list_num);

    _NFIdebug(( fname, "list_no : <%d>\n", list_no));

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMbuild" );
        return (NFI_E_MEMORY);
        }

    if( _NFMdebug_st.NFIdebug_on )
        MEMprint_buffers( "VALUE LIST", value_list, _NFMdebug_st.NFIdebug_file);

    status = MEMreset_buffer_no (value_list, list_no);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMreset" );
        return (NFI_E_MEMORY);
        }

    data_ptr = (char **) value_list->data_ptr;
    column_ptr = (char **) value_list->column_ptr;

    /* if there are no rows, return ERROR */

    if (value_list->rows == 0)
        return (NFI_E_FAILURE);

    /* if there is only one row, use this index without displaying it  */

    if (value_list->rows == 1)
        {
        strcpy (index_name, data_ptr[1]);
        return (NFI_S_SUCCESS);
        }

    data.num_of_rows = value_list->rows;
    data.num_of_cols = value_list->columns;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0 , (data.num_of_cols * sizeof (int)));

    data.col_size[0] = 15;
    for (i=1; i<data.num_of_cols; ++i)
        data.col_size[i] = 30;

    pos = 0;
    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));

    for (i=0; i<data.num_of_cols; ++i)
        {
        data.col_pos[i] = pos;
        pos += data.col_size[i] + 2;
        }

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;

    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (data.num_of_cols * (sizeof (char *)));
    memset (data.h2_data, NULL, data.num_of_cols * (sizeof (char *)));
    NFAput_string (&data.h2_data[0], "");
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");

    sprintf (data.title, "Choose \'%s\' for file: \'%s\'", synonym,
                   file_name);

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        {
	_NFIdebug(( fname, "data_ptr <%s>\n", data_ptr[i]));
        NFAput_string (&data.data[i], data_ptr[i]);
        }

    status = SCprocess_free_form (&data, NFMprint_file);
    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
            {
            no_row_selected = FALSE;
            strcpy (index_name, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (no_row_selected)
        return (NFI_E_FAILURE);
    else
        return (NFI_S_SUCCESS);
}

long NFAget_value_list_buffer (list_num, value_list, attr_name, synonym,
                               buffer)
    char   *list_num;
    MEMptr value_list;
    char   *attr_name;
    char   *synonym;
    MEMptr *buffer;

{
int  tot_data;
int  i, j, pos;
long status;
int  no_row_selected = TRUE;
long list_no;
char str[50];
char **data_ptr;
char **column_ptr;
struct SCfree_data_st data;
static char *fname = "NFAget_value_list_buffer";            

    list_no = atol (list_num);

    _NFIdebug(( fname, "list_no : <%d>\n", list_no));

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
                            "NFAget_value_list_buffer","MEMbuild" );
        return (NFI_E_MEMORY);
        }

    status = MEMreset_buffer_no (value_list, list_no);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
                            "NFAget_value_list_buffer","MEMreset" );
        return (NFI_E_MEMORY);
        }

    data_ptr = (char **) value_list->data_ptr;
    column_ptr = (char **) value_list->column_ptr;

    /* if there are no rows, return ERROR */

    if (value_list->rows == 0)
        return (NFI_E_FAILURE);

    /* if there is only one row, use this index without displaying it */

    if (value_list->rows == 1)
    {
	sprintf( str, "t_appl\1%s\1", data_ptr[0] );
	status = MEMwrite( *buffer, str );
	if( status != MEM_S_SUCCESS )
	{
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
                            "NFAget_value_list_buffer","MEMwrite" );
            return (NFI_E_MEMORY);
	}
	return( NFI_S_SUCCESS );
    }

    data.num_of_rows = value_list->rows;
    data.num_of_cols = value_list->columns;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_MULTI_ROW;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0 , (data.num_of_cols * sizeof (int)));

    data.col_size[0] = 15;
    for (i=1; i<data.num_of_cols; ++i)
        data.col_size[i] = 20;

    pos = 0;
    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));

    for (i=0; i<data.num_of_cols; ++i)
        {
        data.col_pos[i] = pos;
        pos += data.col_size[i] + 2;
        }

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);

    for (i=0; i<data.num_of_cols; ++i)
        data.h2_pos[i] = data.col_pos[i];
    data.h2_pos[i] = -1;
    
    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (data.num_of_cols * (sizeof (char *)));
    memset (data.h2_data, NULL, data.num_of_cols * (sizeof (char *)));

    for (i=0; i<data.num_of_cols; ++i)
        NFAput_string (&data.h2_data[i], column_ptr[i]);
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");

    if (strcmp (synonym, "") != 0)
        sprintf (data.title, "Choose \'%s\'", synonym);
    else
        sprintf (data.title, "Choose \'%s\'", attr_name);

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        {
        NFAput_string (&data.data[i], data_ptr[i]);
        }

    status = SCprocess_free_form (&data, NFMprint_file);
    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=0; i<data.num_of_rows; ++i)
    {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
        {
            no_row_selected = FALSE;
  	    sprintf( str, "t_appl\1%s\1", data_ptr[j] );
	    status = MEMwrite( *buffer, str );
	    if( status != MEM_S_SUCCESS )
	    {
                ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
                            "NFAget_value_list_buffer","MEMwrite" );
                return (NFI_E_MEMORY);
	    }
        }
    }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (no_row_selected)
        return (NFI_E_FAILURE);
    else
        return (NFI_S_SUCCESS);
}


long NFAget_value_list_name (list_num, value_list, index_num, name)
    char   *list_num;
    MEMptr value_list;
    char   *index_num;
    char   *name;

{
int  i;
long status;
long list_no;
char **data_ptr;
char **column_ptr;
int  FOUND = FALSE;
static char *fname = "NFAget_value_list_name";

    list_no = atol (list_num);

    _NFIdebug(( fname, "list_no : <%d>\n", list_no));

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
                            "NFAget_value_list_name","MEMbuild" );
        return (NFI_E_MEMORY);
        }

    status = MEMreset_buffer_no (value_list, list_no);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
                            "NFAget_value_list_name","MEMreset" );
        return (NFI_E_MEMORY);
        }

    data_ptr = (char **) value_list->data_ptr;
    column_ptr = (char **) value_list->column_ptr;

    /* if there are no rows, return ERROR */

    if (value_list->rows == 0)
        return (NFI_E_FAILURE);

    FOUND = FALSE;

    for (i=0; i<(value_list->rows*value_list->columns); ++i)
        {
        if (strcmp (index_num, data_ptr[i]) == 0)
            {
            strcpy (name, data_ptr[i+((value_list->columns)-1)]);
            FOUND = TRUE;
            break;
            }
        }

    if (!FOUND)
        return (NFI_E_FAILURE);

    _NFIdebug(( fname, "Name <%s>\n", name));
    return (NFI_S_SUCCESS);
}


long NFAoverride_power (user_name, state_name, override)
    char   *user_name;
    char   *state_name;
    char   *override;

{
int  tot_data;
int  i, j;
int  USERS_CHOSEN = FALSE;
long status;
int  no_row_selected = TRUE;
struct SCfree_data_st data;
     
    data.num_of_rows = 2;
    data.num_of_cols = 1;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0 , (data.num_of_cols * sizeof (int)));
    data.col_size[0] = 3;

    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));
    data.col_pos[0] = 0;

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h2_pos, 0, sizeof (int) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;
    
    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (sizeof (char *));
    memset (data.h2_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h2_data[0], "");
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");
    
    sprintf (data.title, "Does \'%s\' have OVERRIDE power for state \'%s\'?",
             user_name, state_name);

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Yes");
    NFAput_string (&data.data[1], "No");

    /* process free form */
    do
        {
        no_row_selected = TRUE;

        status = SCprocess_free_form (&data, NFMprint_file);
        if (data.sts == FORM_CANCELED)
         {
	   NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
           free (data.data);
           ERRload_struct (NFI,  NFI_W_FORM_CANCELED,  NULL,  NULL);
	   return (NFI_W_FORM_CANCELED);
          }

        for (i=0; i<data.num_of_rows; ++i)
            {
            j = i * data.num_of_cols;
            if (data.select_set[i] == 1)
                {
                no_row_selected = FALSE;
                strncpy (override, data.data[j], 1);
                override[1] = '\0';
                break;
                }
            }
        }
    while ((data.sts == FORM_CANCELED) || (no_row_selected));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    return (NFI_S_SUCCESS);
}


long NFAfill_data_list (attr_list, data_list, value_list, struct_data)
    MEMptr attr_list;
    MEMptr data_list;
    MEMptr value_list;
    struct SCfree_data_st *struct_data;
{
long   status;
long   NFAget_value_list_string ();
int    i, j, k, q, r;
int    tot_data;
int    pos = 0;
char   string[30];
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
char   **value_ptr;
char   **value_col_ptr;
struct SCfree_data_st *data;
NDXptr index;
static char *fname = "NFAfill_data_list";

    _NFIdebug(( fname, "%s\n", "Entering ..." ));

    data = struct_data;

    SCdisplay_msg ("Working..");

    MEMbuild_array (attr_list);

    attr_ptr = (char **) attr_list->data_ptr;

    NFMRfill_index (attr_list, &index);

    MEMbuild_array (data_list);

    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    MEMbuild_array (value_list);

    value_ptr = (char **) value_list->data_ptr;
    value_col_ptr = (char **) value_list->column_ptr;

    data->num_of_rows = data_list->rows;
    data->num_of_cols = data_list->columns;

    if (data->num_of_rows == 0)
    {
	_NFIdebug(( fname, "%s\n", "No rows in data list" ));
        return (NFI_E_FAILURE);
    }

    tot_data = data->num_of_cols * data->num_of_rows;
    data->freeze_rows_count = 0;
    if (data->num_of_cols == 1)
        data->freeze_cols_count = 0;
    else
        data->freeze_cols_count = 1;

    data->max_indent = 0;
    data->select_set_expected = SELECT_SET_MULTI_ROW;

    data->col_size = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_size, 0, (data->num_of_cols * sizeof (int)));

    for (i=0; i<data->num_of_cols; ++i)
        data->col_size[i] = 15;

    data->col_pos = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_pos, 0 , (data->num_of_cols * sizeof (int)));

    pos = 0;
    for (i=0; i<data->num_of_cols; ++i)
        {
        data->col_pos[i] = pos;
        pos += data->col_size[i] + 2;
        }

    data->col_just = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_just, LEFT_JUSTIFIED, (data->num_of_cols * sizeof (int)));
    
    data->h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h1_pos, 0, sizeof (int) + 1);
    data->h1_pos[0] = 0;
    data->h1_pos[1] = -1;

    data->h2_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h2_pos, 0, sizeof (int) + 1);
    data->h2_pos[0] = 0;
    data->h2_pos[1] = -1;

    data->h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h3_pos, 0, sizeof (int) + 1);
    data->h3_pos[0] = 0;
    data->h3_pos[1] = -1;
    
    data->h1_data = (char **) malloc (sizeof (char *));
    memset (data->h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h1_data[0], "");
    
    data->h2_data = (char **) malloc (sizeof (char *));
    memset (data->h2_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h2_data[0], "");
    
    data->h3_data = (char **) malloc (sizeof (char *));
    memset (data->h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h3_data[0], "");
    
    data->select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data->select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data->data = (char **) malloc (tot_data * sizeof (char *));
    memset (data->data, NULL, (tot_data * sizeof (char *)));

    for (j=0,i=0; j<data_list->rows, i<tot_data; ++j)
        {
        r = j * data_list->columns;
        for (k=0; k<data_list->columns; ++k)
            {
            q = k * attr_list->columns;
      /* if there is a list for this attribute, get string for this index */

            if ((strcmp (attr_ptr[q+index.list], "0") != 0) &&
                (strcmp (attr_ptr[q+index.list], "") != 0))
                {
                status = NFAget_value_list_string (column_ptr[k],
                            data_ptr[r+k], value_list, attr_ptr[q+index.list],
                            string);
                NFAput_string (&data->data[i++], string);
                }
            else
                /* use the data_list value */
                NFAput_string (&data->data[i++], data_ptr[r+k]);

            }  /* end for all data_list columns */

        }  /* end for all data rows */

    return (NFI_S_SUCCESS);
}


long NFAget_value_list_string (column_name, index_num, value_list, list_num,
                               string)
    char   *column_name;
    char   *index_num;
    MEMptr value_list;
    char   *list_num;
    char   *string;

{
int  i, j, k;
long status;
long list_no;
char **data_ptr;
char **column_ptr;
            
static char *fname = "NFAget_value_list_string";

    _NFIdebug(( fname, "list_num : <%s>\n", list_num));

    list_no = atol (list_num);

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMbuild" );
        return (NFI_E_MEMORY);
        }

    status = MEMreset_buffer_no (value_list, list_no);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMreset" );
        return (NFI_E_MEMORY);
        }

    data_ptr = (char **) value_list->data_ptr;
    column_ptr = (char **) value_list->column_ptr;

    for (i=0; i<value_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], column_name) == 0)
            {
            for (k=0; k<value_list->rows; ++k)
                {
                j = k * value_list->columns;
                if (strcmp (data_ptr[j+i], index_num) == 0)
                    {
                    strcpy (string, data_ptr[j+i+1]);
                    break;
                    }
                }
            }
        }

    return (NFI_S_SUCCESS);
}

long NFAget_range_value (list_num, value_list, attr_name, synonym,index_num)
    char   *list_num;
    MEMptr value_list;
    char   *attr_name;
    char   *synonym;
    char   *index_num;

{
int  tot_data;
int  FORM_FILLED = FALSE;
long status;
long list_no;
char attr[NFM_SYNONYM+1];
char **data_ptr;
struct SCcolumn_data_st data;
static char *fname = "NFAget_range_value"; 

    if( strcmp( synonym, "" ) != 0 )
	strcpy( attr, synonym );
    else
	strcpy( attr, attr_name );

    list_no = atol (list_num);

    _NFIdebug(( fname, "list_no : <%d>\n", list_no));

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMbuild" );
        return (NFI_E_MEMORY);
        }

    status = MEMreset_buffer_no (value_list, list_no);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMreset" );
        return (NFI_E_MEMORY);
        }

    data_ptr = (char **) value_list->data_ptr;

    data.num_of_rows = 1;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 20;
    data.col_width[1] = 20;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "Enter %s Between '%s' and '%s'", attr, 
			data_ptr[1], data_ptr[2] );

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[1] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], attr );

    /* process column form until a value has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        if (data.sts != FORM_CANCELED)
            {
            if (strcmp (data.data[1], "") == 0)
                {
                FORM_FILLED = FALSE;
		sprintf( msg, "NFM:  Must Enter %s.", attr );
   		SCdisplay_msg( msg );
                }
	    else
		{
	        if ((atoi (data.data[1]) < atoi (data_ptr[1])) ||
	            (atoi (data.data[1]) > atoi (data_ptr[2])))
		    {
		    FORM_FILLED = FALSE;
		    sprintf( msg, "NFM:  <%s> Not Within Range.",
				   data.data[1]);
		    SCdisplay_msg( msg );
		    }
		}
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    strcpy (index_num, data.data[1]);

    _NFIdebug(( fname, "Range Value : <%s>\n", index_num));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    return (NFI_S_SUCCESS);


}

long NFAnew_get_value_list_index (value_list, list_no, title, value)
    MEMptr value_list ; 
    long   list_no ;
    char   *title ;
    char   *value;

{
int  tot_data;
int  i, j, pos;
long status;
long NFAget_range_value();
char **data_ptr;
char **column_ptr;
struct SCfree_data_st data;
static char *fname = "NFAnew_get_value_list_index"; 

    _NFIdebug(( fname, "list_no : <%d>\n", list_no));

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMbuild" );
        return (NFI_E_MEMORY);
        }

    status = MEMreset_buffer_no (value_list, list_no);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMreset" );
        return (NFI_E_MEMORY);
        }

    data_ptr = (char **) value_list->data_ptr;
    column_ptr = (char **) value_list->column_ptr;

    /* if there are no rows, return ERROR */

    if (value_list->rows == 0)
        return (NFI_E_FAILURE);

    data.num_of_rows = value_list->rows;
    data.num_of_cols = value_list->columns;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0 , (data.num_of_cols * sizeof (int)));

    data.col_size[0] = 15;
    for (i=1; i<data.num_of_cols; ++i)
        data.col_size[i] = 30;

    pos = 0;
    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));

    for (i=0; i<data.num_of_cols; ++i)
        {
        data.col_pos[i] = pos;
        pos += data.col_size[i] + 2;
        }

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;
/*
    for (i=0; i<data.num_of_cols; ++i)
        data.h2_pos[i] = data.col_pos[i];
    data.h2_pos[i] = -1;
*/  
    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (data.num_of_cols * (sizeof (char *)));
    memset (data.h2_data, NULL, data.num_of_cols * (sizeof (char *)));
    NFAput_string (&data.h2_data[0], "");
/*
    for (i=0; i<data.num_of_cols; ++i)
        NFAput_string (&data.h2_data[i], column_ptr[i]);
*/
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");

    sprintf (data.title, "%s", title); 

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        {
	_NFIdebug(( fname, "data_ptr <%s>\n", data_ptr[i]));
        NFAput_string (&data.data[i], data_ptr[i]);
        }

    status = SCprocess_free_form (&data, NFMprint_file);
    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }
    value [0] = 0 ;
    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
            {
            strcpy (value, data.data[j+1]);
            break;
            }
        }
    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

	_NFIdebug ((fname, "SUCCESSFUL : value <%s>\n", value)) ;
    return (NFI_S_SUCCESS);
}


long NFAget_value_list_index_header (value_list, list_no, title, value,
                                     header1, header2)
    MEMptr value_list ; 
    long   list_no ;
    char   *title ;
    char   *value;
    char   *header1;
    char   *header2;

{
int  tot_data;
int  i, j, pos;
long status;
long NFAget_range_value();
char **data_ptr;
char **column_ptr;
struct SCfree_data_st data;
static char *fname = "NFAget_value_list_index_header"; 

    _NFIdebug(( fname, "list_no : <%d>\n", list_no));

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMbuild" );
        return (NFI_E_MEMORY);
        }

    status = MEMreset_buffer_no (value_list, list_no);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMreset" );
        return (NFI_E_MEMORY);
        }

    data_ptr = (char **) value_list->data_ptr;
    column_ptr = (char **) value_list->column_ptr;

    /* if there are no rows, return ERROR */

    if (value_list->rows == 0)
        return (NFI_E_FAILURE);

    data.num_of_rows = value_list->rows;
    data.num_of_cols = value_list->columns;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0 , (data.num_of_cols * sizeof (int)));

    data.col_size[0] = 15;
    for (i=1; i<data.num_of_cols; ++i)
        data.col_size[i] = 60;

    pos = 0;
    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));

    for (i=0; i<data.num_of_cols; ++i)
        {
        data.col_pos[i] = pos;
        pos += data.col_size[i] + 2;
        }

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;

    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h1_data[0], header1);
    
    data.h2_data = (char **) malloc (data.num_of_cols * (sizeof (char *)));
    memset (data.h2_data, NULL, data.num_of_cols * (sizeof (char *)));
    NFAput_string (&data.h2_data[0], header2);
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");

    sprintf (data.title, "%s", title); 

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        {
	_NFIdebug(( fname, "data_ptr <%s>\n", data_ptr[i]));
        NFAput_string (&data.data[i], data_ptr[i]);
        }

    status = SCprocess_free_form (&data, NFMprint_file);
    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }
    value [0] = 0 ;
    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
            {
            strcpy (value, data.data[j+1]);
            break;
            }
        }
    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

	_NFIdebug ((fname, "SUCCESSFUL : value <%s>\n", value)) ;
    return (NFI_S_SUCCESS);
}

long NFAget_value_list_index_workflow (list_num, value_list, attr_name, 
               synonym, index_num)
    char   *list_num;
    MEMptr value_list;
    char   *attr_name;
    char   *synonym;
    char   *index_num;

{
int  tot_data;
int  i, j, pos;
long status;
int  no_row_selected = TRUE;
long list_no;
long NFAget_range_value();
char **data_ptr;
char **column_ptr;
struct SCfree_data_st data;
static char *fname = "NFAget_value_list_index_workflow"; 

    list_no = atol (list_num);

    _NFIdebug(( fname, "list_no : <%d>\n", list_no));

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMbuild" );
        return (NFI_E_MEMORY);
        }

    status = MEMreset_buffer_no (value_list, list_no);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname ,"MEMreset" );
        return (NFI_E_MEMORY);
        }

    data_ptr = (char **) value_list->data_ptr;
    column_ptr = (char **) value_list->column_ptr;

    /* if there are no rows, return ERROR */

    if (value_list->rows == 0)
        return (NFI_E_FAILURE);

    /* Check to see if this is a range attribute */
    if( strcmp( data_ptr[0], "NFM_RANGE" ) == 0 )
    {
    	status = NFAget_range_value (list_num, value_list, attr_name, 
				     synonym, index_num);
	_NFIdebug(( fname, "NFAget_range_value <0x%.8x>\n", status ));
	return( status );	
    }
    /* if there is only one row, use this index without displaying it  */

    if (value_list->rows == 1)
        {
        strcpy (index_num, data_ptr[0]);
        return (NFI_S_SUCCESS);
        }

    data.num_of_rows = value_list->rows;
    data.num_of_cols = value_list->columns;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0 , (data.num_of_cols * sizeof (int)));

    data.col_size[0] = 15;
    for (i=1; i<data.num_of_cols; ++i)
        data.col_size[i] = 30;

    pos = 0;
    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));

    for (i=0; i<data.num_of_cols; ++i)
        {
        data.col_pos[i] = pos;
        pos += data.col_size[i] + 2;
        }

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;
/*
    for (i=0; i<data.num_of_cols; ++i)
        data.h2_pos[i] = data.col_pos[i];
    data.h2_pos[i] = -1;
*/  
    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (data.num_of_cols * (sizeof (char *)));
    memset (data.h2_data, NULL, data.num_of_cols * (sizeof (char *)));
    NFAput_string (&data.h2_data[0], "");
/*
    for (i=0; i<data.num_of_cols; ++i)
        NFAput_string (&data.h2_data[i], column_ptr[i]);
*/
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");

    if (strcmp (synonym, "") != 0)
        sprintf (data.title, "Choose \'%s\' of NEW ACL", synonym);
    else
        sprintf (data.title, "Choose \'%s\'", attr_name);

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        {
	_NFIdebug(( fname, "data_ptr <%s>\n", data_ptr[i]));
        NFAput_string (&data.data[i], data_ptr[i]);
        }

    status = SCprocess_free_form (&data, NFMprint_file);
    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
            {
            no_row_selected = FALSE;
            strcpy (index_num, data.data[j]);
               break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (no_row_selected)
        return (NFI_E_FAILURE);
    else
        return (NFI_S_SUCCESS);
}

