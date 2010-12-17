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
#include "NFMstruct.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFIcommands.h"
#include "NFIerrordef.h" 
extern long sqlstatus;



extern struct NFMglobal_st NFMglobal;
long ADMcross_ref()

{
long   status;
int    i;
int    tot_data;
int    pos;
struct SCfree_data_st fdata;
char   **column_ptr;
char   **data_ptr;
MEMptr out_list = NULL;
static char *fname = "ADMcross_ref";

    _NFMdebug ((fname, "%s", "ENTER\n"));

    SCdisplay_msg ("Working..");    

    status = NFMlist_f (NFMglobal.NFMuserid, "", "", &out_list);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug((fname, "NFMlist_f status is :<0x%.8x>\n", status));
        ERRload_struct(NFM, NFM_E_NO_ITEMS_FOUND_IN_CAT, NULL, NULL);
        return(status);
     }
    status = MEMbuild_array (out_list);
    if (status != MEM_S_SUCCESS)
     {
       _NFMdebug((fname, "MEMbuild_array status is : <0x%.8x>\n", status));
       ERRload_struct(NFM, NFM_E_MEM, NULL, NULL);
       return (status);
     }
     
    column_ptr = (char **) out_list->column_ptr;
    data_ptr = (char **) out_list->data_ptr;
    
    fdata.num_of_rows = out_list->rows;
    fdata.num_of_cols = out_list->columns;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 2;
    fdata.max_indent = 0;
    fdata.select_set_expected = FALSE;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_size[0] = 15;
    fdata.col_size[1] = 15;
    fdata.col_size[2] = 15;
    fdata.col_size[3] = 13;
    fdata.col_size[4] = 14;
    fdata.col_size[5] = 14;
    fdata.col_size[6] = 14;

    fdata.col_pos = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_pos, 0 , (fdata.num_of_cols * sizeof (int)));
    
    pos = 0;
    for (i=0; i<out_list->columns; ++i)
        {
        fdata.col_pos[i] = pos;
        pos += fdata.col_size[i] + 2;
        }

    fdata.col_just = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols * sizeof (int)));
    
    fdata.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h1_pos, 0, sizeof (int) + 1);
    fdata.h1_pos[0] = 0;
    fdata.h1_pos[1] = -1;

    fdata.h2_pos = (int *) malloc ((fdata.num_of_cols * sizeof (int)) + 1);
    memset (fdata.h2_pos, 0, (fdata.num_of_cols * sizeof (int)) + 1);
    for (i=0; i<out_list->columns; ++i)
        fdata.h2_pos[i] = fdata.col_pos[i];

    fdata.h2_pos[i] = -1;
    
    fdata.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h3_pos, 0, sizeof (int) + 1);
    fdata.h3_pos[0] = 0;
    fdata.h3_pos[1] = -1;
    
    fdata.h1_data = (char **) malloc (sizeof (char *));
    memset (fdata.h1_data, NULL, (sizeof (char *)));
    NFMput_string (&fdata.h1_data[0], "");
    
    fdata.h2_data = (char **) malloc (fdata.num_of_cols * (sizeof (char *)));
    memset (fdata.h2_data, NULL, fdata.num_of_cols * (sizeof (char *)));
    for (i=0; i<out_list->columns; ++i)
        NFMput_string (&fdata.h2_data[i], column_ptr[i]);
    
    fdata.h3_data = (char **) malloc (sizeof (char *));
    memset (fdata.h3_data, NULL, (sizeof (char *)));
    NFMput_string (&fdata.h3_data[0], "");
    
    sprintf (fdata.title, "Cross Reference Listing");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        NFMput_string (&fdata.data[i], data_ptr[i]);

    status = SCprocess_free_form (&fdata, NFMprint_file);

    NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);

    ERRload_struct (NFM, NFM_S_SUCCESS, NULL, NULL);

    _NFMdebug ((fname, "%s", "EXIT\n"));
        
    return (NFM_S_SUCCESS);
}


