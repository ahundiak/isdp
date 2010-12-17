#include "machine.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

long make_transition ()

{
long   status;
int    i, j;
int    tot_data;
int    FORM_FILLED;
int    statename_index = 0;
int    status_index = 0;
struct SCfree_data_st data;
char   **n_data_ptr;
char   **n_column_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
NDXptr index;
static char *fname = "make_transition";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_make_transition (NFMuser_id, &attr_list, &data_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFAmake_transition",
			"MEMbuild_array");
        return (status);
        }

    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFAmake_transition",
			"MEMbuild_array");
        return (status);
        }

    n_data_ptr = (char **) data_list->data_ptr;
    n_column_ptr = (char **) data_list->column_ptr;

    NFMRfill_index (attr_list, &index);

    /* rows is num_of_rows minus 1 because the first row is the current state */
    data.num_of_rows = data_list->rows - 1;
    data.num_of_cols = 1;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_size[0] = 40;

    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));
    
    data.col_pos[0] = 0;

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
    
    data.h2_data = (char **) malloc (tot_data * (sizeof (char *)));
    memset (data.h2_data, NULL, tot_data * (sizeof (char *)));
    NFAput_string (&data.h2_data[0], "Choose Next State:");
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");
    
    sprintf (data.title, "Current State: \"%s\"", n_data_ptr[1]);

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<data_list->columns; ++i)
        {
             if (strcmp (n_column_ptr[i], "n_statename") == 0)
                 statename_index = i + data_list->columns;
        else if (strcmp (n_column_ptr[i], "n_status") == 0)
                 status_index = i;
        }

    for (i=0, j=statename_index;
         i<tot_data;
         ++i, j+=data_list->columns)
        {
        NFAput_string (&data.data[i], n_data_ptr[j]);
        }

    do
        {
        FORM_FILLED = FALSE;
        status = SCprocess_free_form (&data, NFMprint_file);
        SCclear_msg ();

        if (data.sts == FORM_ACCEPTED)
            {
            for (i=0; i<data.num_of_rows; ++i)
                {
                if (data.select_set[i] == 1)
                    {
                    FORM_FILLED = TRUE;
                    break;
                    }
                }
            }

        if (FORM_FILLED == FALSE)
            SCdisplay_msg ("NFM:  Must Choose Next Transition.");
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        if (data.select_set[i] == 1)
            {
            _NFIdebug ((fname, "row -> %d\n", i + 2));
            _NFIdebug ((fname, "col -> %d\n", status_index + 1));
            status = MEMwrite_data (data_list, "NEXT", i+2, status_index+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&attr_list);
                MEMclose (&data_list);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
	        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFAmake_transition",
				"MEMwrite_data" );
                return (status);
                }
            break;
            }
        }

    SCdisplay_msg ("Working..");    

    status = NFMRmake_transition (NFMuser_id, attr_list, data_list);

    _NFIdebug ((fname, "NFMRmake_transition -> <0x%.8x>\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    MEMclose (&attr_list);
    MEMclose (&data_list);
    
    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


