#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "ERR.h"
#include "NFMRlist.h"
#include "NFMdisplays.h"

#define  BUFFER_SIZE  1000

long roll_version_forward ()

{
int    i;
int    j;
int    k;
int    m;
int    pos;
int    len;
int    count;
int    no_row_selected;
int    tot_data;
long   status;
char   title[80];
char   **syn_ptr;
char   **data_ptr;
char   **col_ptr;
char   **fmt_ptr;
struct SCfree_data_st data;
MEMptr syn_list  = NULL;
MEMptr data_list = NULL;
MEMptr item_version = NULL;
static char *fname = "NFAroll_version_forward";

    SCdisplay_msg ("Working..");    

    status = NFMRget_item_versions( NFMcatalog, NFMitem, NFMrev,
				    &syn_list, &data_list );
    _NFIdebug(( fname, "Return from NFMRget_item_versions -> 0x%.8x\n", 
		status));
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &syn_list );
	MEMclose( &data_list );
  	return( status );
    }

    status = MEMbuild_array( syn_list );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &syn_list );
	MEMclose( &data_list );
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    status = MEMbuild_array( data_list );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &syn_list );
	MEMclose( &data_list );
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    syn_ptr  = (char**)syn_list->data_ptr;
    data_ptr = (char**)data_list->data_ptr;
    col_ptr  = (char**)data_list->column_ptr;
    fmt_ptr  = (char**)data_list->format_ptr;

    /* Check for readable attributes */
    count = 0;
    for( i=0; i<(syn_list->rows*syn_list->columns); i+=syn_list->columns )
	if( strcmp( syn_ptr[i+1], "Y" ) == 0 )
	    ++count;

    data.num_of_rows = data_list->rows;
    data.num_of_cols = count;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 2;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_MULTI_ROW;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0, (data.num_of_cols * sizeof (int)));

    for (i=0,j=0,k=0; i<(syn_list->rows*syn_list->columns); 
		  i+=syn_list->columns, ++j)
    {
        if( strcmp( syn_ptr[i+1], "Y" ) == 0 )
 	{
            len    = 0;
            status = NFAcol_width (syn_ptr[i], fmt_ptr[j], &len);
            if (len > 25)
                len = 25;
            data.col_size[k] = len;
	    ++k;
	}
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
    for (i=0,j=0; i<(syn_list->rows*syn_list->columns);
                  i+=syn_list->columns)
    {
	if( strcmp( syn_ptr[i+1], "Y" ) == 0 )
	{
            NFAput_string (&data.h2_data[j], syn_ptr[i]);
  	    ++j;
	}
    }
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");
    
    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));
    
    strcpy (data.title, "Choose File Version(s) to Roll Forward");

    /* insert data */

    for (i=0,k=0; i<(data_list->rows*data_list->columns);
                  i+=data_list->columns)
    {
	/*  Find readable attributes */
	for( j=0,m=0; j<(syn_list->rows*syn_list->columns);
		  j+=syn_list->columns,++m)
	{
	    if( strcmp( syn_ptr[j+1], "Y" ) == 0 )
	    {
                NFAput_string (&data.data[k], data_ptr[i+m]);
   	        ++k;
	    }
	}
    }

    _NFIdebug(( fname, "%s\n", "Call SCprocess" ));

    status = SCprocess_free_form (&data, NFMprint_file);
    SCclear_msg ();

    _NFIdebug(( fname, "return from SCprocess_column_form -> %d\n", 
			data.sts));
    if (data.sts == FORM_CANCELED)
    {
	MEMclose( &syn_list );
	MEMclose( &data_list );
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

    status = MEMopen( &item_version, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFAroll_version",
			"MEMopen" );
        MEMclose (&item_version);
	NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        return (NFI_E_MEMORY);
    }

    for( i=0; i<data_list->columns; ++i )
    {
        status = MEMwrite_format (item_version, col_ptr[i], fmt_ptr[i]);
        if (status != MEM_S_SUCCESS)
        {
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFAroll_version_forward","MEMwrite_format" );
            MEMclose (&item_version);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            return (NFI_E_MEMORY);  
        }
    }

    for (i=0; i<data.num_of_rows; ++i)
    {
        if (data.select_set[i] == 1)
        {
	    strcpy( title, "" );
	    for( k=0; k<data_list->columns; ++k )
	    {
		j = i*data_list->columns;
  	        strcat( title,  data_ptr[j+k] );
		strcat( title, "\1" );
	    }
            status = MEMwrite (item_version, title);
            if (status != MEM_S_SUCCESS)
            {
                ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", 
			"NFAroll_version_forward", "MEMwrite" );
 	        MEMclose (&item_version);
	        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
 	        return (NFI_E_MEMORY);
	    }
        }
    }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");

    status = NFMRroll_version_forward( NFMcatalog, NFMitem, NFMrev,
				    item_version );

    _NFIdebug(( fname, "Return from NFMRroll_version_forward -> 0x%.8x\n", 
		status));

    MEMclose( &item_version );

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



