#include "machine.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

long delete_members ()

{
long   status;
long   catalog_no = -1;
long   item_no    = -1;
long   cit_no     = -1;
int    i;
int    k;
int    j;
int    count;
int    tot_data;
struct SCfree_data_st data;
char   **data_ptr;
char   **syn_ptr;
MEMptr syn_list = NULL;
MEMptr data_list = NULL;
struct NFMmember_info *members_info;

static char *fname = "NFAdelete_set_members";

    SCdisplay_msg ("Working..");    

    status = NFMRdisplay_set_members (NFMcatalog, NFMset, NFMset_rev,
                   "", "", &syn_list, &data_list);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&syn_list);
        MEMclose (&data_list);
	return (status);
        }

    status = MEMbuild_array (syn_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&syn_list);
        MEMclose (&data_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild_array");
        return (status);
        }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&syn_list);
        MEMclose (&data_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname,"MEMbuild_array");
        return (status);
        }

    data_ptr = (char **) data_list->data_ptr;
    syn_ptr  = (char **) syn_list->data_ptr;

    data.num_of_rows = data_list->rows;
    data.num_of_cols = 4;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 2;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_MULTI_ROW;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0, (data.num_of_cols * sizeof (int)));
    data.col_size[0] = 15;
    data.col_size[1] = 15;
    data.col_size[2] = 15;
    data.col_size[3] = 11;

    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));
    data.col_pos[0] = 0;
    data.col_pos[1] = 17;
    data.col_pos[2] = 34;
    data.col_pos[3] = 51;

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = 17;
    data.h2_pos[2] = 34;
    data.h2_pos[3] = 51;
    data.h2_pos[4] = -1;
    
    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (data.num_of_cols * (sizeof (char *)));
    memset (data.h2_data, NULL, data.num_of_cols * (sizeof (char *)));
    NFAput_string (&data.h2_data[0], syn_ptr[0] );
    NFAput_string (&data.h2_data[1], syn_ptr[1] );
    NFAput_string (&data.h2_data[2], syn_ptr[2] );
    NFAput_string (&data.h2_data[3], syn_ptr[3] );
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");
    
    strcpy (data.title, "Choose Members to Delete");

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0, k=0; i<tot_data; i+=data.num_of_cols, k+=data_list->columns)
    {
        NFAput_string (&data.data[i],   data_ptr[k]);
        NFAput_string (&data.data[i+1], data_ptr[k+1]);
        NFAput_string (&data.data[i+2], data_ptr[k+2]);
        NFAput_string (&data.data[i+3], data_ptr[k+3]);
    }

    /* process free form */
    status = SCprocess_free_form (&data, NFMprint_file);

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&syn_list);
        MEMclose (&data_list);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    /* Build the member info structure  */

    for( i=0,count=0; i<data.num_of_rows; ++i )
	if( (data.select_set[i] == 1 ) )
	    ++count;
   

    _NFIdebug(( fname, "Count <%d>\n", count ));

    members_info = (struct NFMmember_info *)calloc((count+1),
                (sizeof( struct NFMmember_info )));

    for( i=0,j=0,k=0; i<data.num_of_rows; ++i,k+=data.num_of_cols )
    {
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
        {
            (members_info+j)->operation = NFM_DROP_MEMBER;
            (members_info+j)->citno     = cit_no;
	    _NFIdebug(( fname, "Cat <%s>  Item <%s>  Rev <%s>  Type <%s>\n",
	data.data[k], data.data[k+1], data.data[k+2], data.data[k+3] ));
            strncpy( (members_info+j)->catalog_name, data.data[k],
		     NFM_CATALOGNAME );
            (members_info+j)->catalog_no = catalog_no;
            strncpy( (members_info+j)->item_name, data.data[k+1], 
		     NFM_ITEMNAME );
            strncpy( (members_info+j)->item_rev, data.data[k+2], 
		     NFM_ITEMREV );
 	    (members_info+j)->item_no   = item_no;
            strncpy( (members_info+j)->type, data.data[k+3], NFM_TYPE );
	    ++j;
        }
    }

    SCdisplay_msg ("Working..");    

    status = NFMRdefine_set_information( NFMcatalog, catalog_no, NFMset,
		NFMset_rev, NFM_FILE_STATUS_CHECK, count, members_info);

    _NFIdebug(( fname, "Return from NFMRdefine_set_information -> 0x%.8x\n", 
		    status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    /* If count equals data.num_of_rows all the members are getting deleted
       and it is no more set - SSRS 04 Apr 94 */
    if ( count == data.num_of_rows )
        strcpy( NFMset, "");
    free (data.data);

    MEMclose (&syn_list);
    MEMclose (&data_list);
    
    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



