#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "ERR.h"

long delete_files_from_item ()

{
long   status;
int    i, j;
int    tot_data;
int    len;
int    pos;
int    no_row_selected = 0;
struct SCfree_data_st data;
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
char   **format_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFAdelete_files_from_item";

    SCdisplay_msg ("Working..");    

    status = NFMRget_file_information (NFMcatalog, NFMitem, NFMrev,
                 NFM_DELETE_FILE_FROM_ITEM, &attr_list, &data_list, 
		 &value_list);
    if (status != NFM_S_SUCCESS)
        {
	_NFIdebug(( fname, "NFMRget_file_information  <0x%.8x>\n", status ));
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
	ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild" );
	return( NFI_E_MEMORY );
    }

    attr_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild" );
        return( NFI_E_MEMORY );
    }

    data_ptr = (char **) data_list->data_ptr;
    format_ptr = (char **) data_list->format_ptr;

    data.num_of_rows = data_list->rows;
    data.num_of_cols = data_list->columns;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 2;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_MULTI_ROW;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0, (data.num_of_cols * sizeof (int)));

    for (i=0,j=0; i<(attr_list->rows*attr_list->columns); 
		  i+=attr_list->columns, ++j)
    {
        len    = 0;
        status = NFAcol_width (attr_ptr[i], format_ptr[j], &len);
        if (len > 25)
            len = 25;
        data.col_size[j] = len;
    }

    pos = 0;
    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));
    for (i=0; i<data.num_of_cols; ++i)
        {
        data.col_pos[i] = pos;
        pos += data.col_size[i] + 2;
        }

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset(data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    for (i=0; i<data.num_of_cols; ++i)
        {
        data.h2_pos[i] = data.col_pos[i];
        }
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
    for (i=0,j=0; i<(attr_list->rows*attr_list->columns);
                  i+=attr_list->columns, ++j)
        NFAput_string (&data.h2_data[j], attr_ptr[i]);
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");
    
    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));
    
    strcpy (data.title, "Choose File(s) to Delete");

    /* insert data */

    for (i=0; i<tot_data; ++i)
        NFAput_string (&data.data[i], data_ptr[i]);

    _NFIdebug(( fname, "%s\n", "Call SCprocess" ));

    status = SCprocess_free_form (&data, NFMprint_file);
    SCclear_msg ();

    _NFIdebug(( fname, "return from SCprocess_column_form -> %d\n", 
			data.sts));
    if (data.sts == FORM_CANCELED)
    {
        status = NFMRreset_file_information (NFMcatalog, NFMitem, NFMrev);
        if( status != NFM_S_SUCCESS )
            _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n",
                        status ));

	MEMclose( &attr_list );
	MEMclose( &data_list );
	MEMclose( &value_list );
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
    }

    for (i=0; i<data.num_of_rows; ++i)
    {
        if (data.select_set[i] == 1)
        {
            no_row_selected = FALSE;
            break;
        }
    }

    if( no_row_selected )
    {
	MEMclose( &attr_list );
	MEMclose( &data_list );
	MEMclose( &value_list );
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        status = NFMRreset_file_information (NFMcatalog, NFMitem, NFMrev);
        if( status != NFM_S_SUCCESS )
            _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n",
                        status ));
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
    }

    for (i=0; i<data.num_of_rows; ++i)
    {
        if (data.select_set[i] == 1)
        {
	    /*  Put a "Y"es in the n_status attribute */
	    _NFIdebug(( fname, "Yes in row <%d>\n", i ));
            status = MEMwrite_data (data_list, "Y",i+1,data_list->columns);
            if (status != MEM_S_SUCCESS)
            {
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list(data.data,data.num_of_rows, 
			     data.num_of_cols);
                free (data.data);
	        status = NFMRreset_file_information (NFMcatalog, NFMitem, 
						     NFMrev);
	        if( status != NFM_S_SUCCESS )
	            _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n",
	                        status ));
                ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
                return (NFM_E_MEM);
            }
        }
    }

    if( _NFMdebug_st.NFIdebug_on )
	MEMprint_buffers( "DATA LIST", data_list, _NFMdebug_st.NFIdebug_file);

    SCdisplay_msg ("Working..");    

    status = NFMRdefine_file_information (NFMcatalog, NFMitem, NFMrev,
			NFM_DELETE_FILE_FROM_ITEM, data_list);

    _NFIdebug(( fname, "return from NFMRdefine_file_information -> 0x%.8x\n", 
		status));

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


