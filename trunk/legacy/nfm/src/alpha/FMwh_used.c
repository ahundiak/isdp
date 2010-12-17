/*******************************************************************************
Function calls NFMRwhere_used_set, NFMRwhere_used_project have 'NFMuser_id' as
the first argument( total 6 arguments ). Where as the function bodies in nfmr/
NFMRdisplays.c donot have this argument ( have only other 5 arguments ).

The NFMuser_id argument is removed to confirm with the number of function args
in nfmr/NFMRdisplays.c. The change is to be incorporated into SPC.  
            CRN - 26 Aug 94 
*******************************************************************************/
#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "ERR.h"
#include "DEBUG.h"

long where_used_set ()

{
long   status;
int    i;
int    tot_data;
int    max_len = 0;
int    pos = 0;
struct SCfree_data_st data;
char   **data_ptr;
char   **column_ptr;
char   **format_ptr;
MEMptr info_list = NULL;
MEMptr info = NULL;
static char *fname = "NFIwhere_used_set";

    SCdisplay_msg ("Working..");    

    status = NFMRdisplay_where_used_set (NFMcatalog, NFMitem, 
                     NFMrev,&info_list, &info);

    _NFIdebug(( fname, "NFMRdisplay_where_used_set <0x%.8x>\n", status));

    if (status != NFM_S_SUCCESS)
        {
        MEMclose(&info_list);
        MEMclose (&info);
        return (status);
        }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMwhere_used_set",
			"MEMbuild_array");
        return (status);
        }

    data_ptr = (char **) info->data_ptr;
    column_ptr = (char **) info->column_ptr;
    format_ptr = (char **) info->format_ptr;
    
    data.num_of_rows = info->rows;
    data.num_of_cols = info->columns;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 1;
    data.max_indent = 0;
    data.select_set_expected = FALSE;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0, (data.num_of_cols * sizeof (int)));
    for (i=0; i<data.num_of_cols; ++i)
        {
        max_len = 0;
        status = NFAcol_width (column_ptr[i], format_ptr[i], &max_len);
        if (max_len > 25)
            max_len = 25;
        data.col_size[i] = max_len;
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
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
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
    for (i=0; i<info->columns; ++i)
        {
        NFAput_string (&data.h2_data[i], column_ptr[i]);
        }
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");
    
    sprintf (data.title, "Sets Containing \'%s.%s\'", NFMitem, NFMrev);

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        {
        NFAput_string (&data.data[i], data_ptr[i]);
        }

    /* process free form */
    status = SCprocess_free_form (&data, NFMprint_file);

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&info);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    MEMclose (&info_list);
    MEMclose (&info);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long where_used_project ()

{
long   status;
int    i;
int    tot_data;
int    max_len = 0;
int    pos = 0;
struct SCfree_data_st data;
char   **data_ptr;
char   **column_ptr;
char   **format_ptr;
MEMptr info_list = NULL;
MEMptr info = NULL;
static char *fname = "NFIwhere_used_project";

    SCdisplay_msg ("Working..");    

    status = NFMRdisplay_where_used_project (NFMcatalog, NFMitem, 
              NFMrev,&info_list, &info);

    _NFIdebug(( fname, "NFMRdisplay_where_used_project <0x%.8x>\n", status));

    if (status != NFM_S_SUCCESS)
        {
          MEMclose (&info_list);
          MEMclose (&info);
          return (status);
        }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMwhere_used_project",
			"MEMbuild_array");
        return (status);
        }

    data_ptr = (char **) info->data_ptr;
    column_ptr = (char **) info->column_ptr;
    format_ptr = (char **) info->format_ptr;
    
    data.num_of_rows = info->rows;
    data.num_of_cols = info->columns;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 1;
    data.max_indent = 0;
    data.select_set_expected = FALSE;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0, (data.num_of_cols * sizeof (int)));
    for (i=0; i<data.num_of_cols; ++i)
        {
        max_len = 0;
        status = NFAcol_width (column_ptr[i], format_ptr[i], &max_len);
        if (max_len > 25)
            max_len = 25;
        data.col_size[i] = max_len;
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
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
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
    for (i=0; i<info->columns; ++i)
        {
        NFAput_string (&data.h2_data[i], column_ptr[i]);
        }
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");
    
    sprintf (data.title, "Projects Containing \'%s.%s\'", NFMitem, NFMrev);

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        {
        NFAput_string (&data.data[i], data_ptr[i]);
        }

    /* process free form */
    status = SCprocess_free_form (&data, NFMprint_file);

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&info);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    MEMclose (&info_list);
    MEMclose (&info);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



