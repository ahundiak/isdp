#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"
#include "ERR.h"
extern long sqlstatus;

long review_item ()

{
long   status;
int    i, j, k;
int    tot_data;
int    count = 0;
struct SCfree_data_st data;
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
NDXptr index;

    _NFMR_str ("%s", "Enter review_item");

    SCdisplay_msg ("Working..");    

    status = NFMRquery_item_attributes (NFMuser_id, NFMcatalog, NFMitem,
                                        NFMrev, &attr_list, &data_list,
                                        &value_list);

    _NFMR_num("NFMreview_item : NFMRquery_catalog_attributes : <%ld>", status);

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
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMreview_item",
			"MEMbuild_array");
        return (status);
        }

    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    NFMRfill_index (attr_list, &index);

    count = 0;
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (data_ptr[i+index.r], "Y") == 0)
            ++count;
        }

    _NFMR_num ("NFMreview_item : total rows       : <%d>", attr_list->rows);
    _NFMR_num ("NFMreview_item : displayable rows : <%d>", count);

    data.num_of_rows = count;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = FALSE;
    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_size[0] = 20;
    data.col_size[1] = 40;

    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));
    
    data.col_pos[0] = 0;
    data.col_pos[1] = 22;

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
    NFAput_string (&data.h2_data[0], "");
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");
    
    if (strcmp (NFMrev, "") == 0)
        sprintf (data.title, "Review \"%s\"", NFMitem);
    else
        sprintf (data.title, "Review \"%s.%s\"", NFMitem, NFMrev);

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0, j=0; i<tot_data; j+=attr_list->columns)
        {
        if (strcmp (data_ptr[j+index.r], "Y") == 0)
            {
            if (strcmp (data_ptr[j+index.syn], "") != 0)
                NFAput_string (&data.data[i], data_ptr[j+index.syn]);
            else
                NFAput_string (&data.data[i], data_ptr[j+index.name]);
            i+=data.num_of_cols;
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
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMreview_item",
			"MEMbuild_array");
        return (status);
        }

    n_data_ptr = (char **) data_list->data_ptr;

    for (i=1, j=0, k=0; i<tot_data; j+=attr_list->columns, ++k)
        {
        if (strcmp (data_ptr[j+index.r], "Y") == 0)
            {
            NFAput_string (&data.data[i], n_data_ptr[k]);

/*  Don't need to choose anything from the values list for review !!
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
                }
*/
            i+=data.num_of_cols;
            }
        }

    /* process free form */
    status = SCprocess_free_form (&data, NFMprint_file);

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    
    NFAmake_msg (msg);
    _NFMR_str ("%s", msg);
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


