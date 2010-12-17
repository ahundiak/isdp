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
#include "ERR.h"

delete_savesets()
{
    long	status;

    int  	i;
    int		j;
    int		k;
    int		tot_data;
    int		total;
    int 	CHOSEN_ONE = FALSE;
    
    char	str[500];
    char 	col_str[150];
    char	**data_ptr;
    char	**syn_ptr;

    MEMptr	chosen    = NULL;
    MEMptr	data_list = NULL;
    MEMptr	syn_list  = NULL;

    struct SCfree_data_st data;
    static char *fname = "NFAdelete_savesets";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_savesets_to_delete( &syn_list, &data_list);
    if (status != NFM_S_SUCCESS)
        {
	MEMclose (&syn_list);
        MEMclose (&data_list);
        return (status);
        }

    status = MEMbuild_array (syn_list);
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &syn_list );
	MEMclose( &data_list );
	_NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild" );
	return( NFI_E_MEMORY );
    }

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &syn_list );
	MEMclose( &data_list );
	_NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild" );
	return( NFI_E_MEMORY );
    }

    data_ptr = (char **) data_list->data_ptr;
    syn_ptr  = (char **) syn_list->data_ptr;

/*  Set up headers before actually selecting the flagged files */

     _NFIdebug ((fname, "Set up headers.\n"));
    data.num_of_rows = data_list->rows;
    data.num_of_cols = (data_list->columns)-3; /* Don't display cat_no,etc. */
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_MULTI_ROW;
    data.col_size =(int*)malloc ( data.num_of_cols * sizeof(int) );
    memset( data.col_size, 0, ( data.num_of_cols * sizeof(int) ));


    data.col_size[0] = 20; /* catalog name */
    data.col_size[1] = 20; /* item name */
    data.col_size[2] = 10; /* item rev */
    data.col_size[3] = 30; /* local filename */
    data.col_size[4] = 12; /* file version */
    data.col_size[5] = 20; /* restore date */

    data.col_pos = (int*) malloc( data.num_of_cols * sizeof(int) );
    memset( data.col_pos, 0, ( data.num_of_cols * sizeof(int) ));

    total = 0;
    for( i = 0; i < data.num_of_cols; ++i )
    {	
        data.col_pos[i] = total;
        total += data.col_size[i] + 2;
    }
    data.col_just =(int*)malloc( data.num_of_cols * sizeof(int) );
    memset( data.col_just, LEFT_JUSTIFIED, ( data.num_of_cols * sizeof(int)));

/*  Set up header information */
/*  Header line 1 is empty */
    data.h1_pos = (int*) malloc ( sizeof(int) +1 );
    memset( data.h1_pos, 0, sizeof(int) + 1 );
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

/*  Malloc and init header line 2 */

    data.h2_pos = (int*)malloc((data.num_of_cols*sizeof(int)) +1 );
    memset( data.h2_pos, 0,(data.num_of_cols *  sizeof(int)) + 1 );

    total = 0;
    for( i = 0; i < data.num_of_cols; ++i )
    {
        data.h2_pos[i] = total;
        total += data.col_size[i] + 2;
    }
    data.h2_pos[i] = -1;

/*  Header line 3 is empty */

    data.h3_pos = (int*) malloc ( sizeof(int) +1 );
    memset( data.h3_pos, 0, sizeof(int) + 1 );
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;

/*  Put in column names ( Headers 1 and 3 are blank ) */

    data.h1_data = (char**) malloc (sizeof(char*));
    memset( data.h1_data, NULL, (sizeof(char*)));
    NFAput_string( &data.h1_data[0], "" );
    data.h2_data = (char**) malloc (tot_data * (sizeof(char*)));
    memset(data.h2_data, NULL, data.num_of_cols * (sizeof(char*)));
    
    _NFIdebug ((fname, "Load column names.\n"));
    for( i=0; i<syn_list->rows; ++i )
        NFAput_string( &data.h2_data[i], syn_ptr[i] );

    data.h3_data = (char**) malloc (sizeof(char*));
    memset( data.h3_data, NULL, (sizeof(char*)));
    NFAput_string( &data.h3_data[0], "" );
    
    sprintf( data.title, "Select Saveset Entries to Delete : " );

    data.select_set = (int*) malloc ( tot_data * sizeof(int) );
    memset( data.select_set, 0, ( tot_data * sizeof(int) ));

/*  Allocate and initialize space to store data */

    data.data = (char**) malloc ( tot_data * sizeof(char*) );
    memset( data.data, NULL, (tot_data * sizeof(char*) ) );

    _NFIdebug ((fname, "Load data.\n"));
    for( i=0,j=0; i < tot_data; i+= data.num_of_cols )
    {
	NFAput_string( &data.data[i],   data_ptr[j] );
        NFAput_string( &data.data[i+1], data_ptr[j+1] );
	NFAput_string( &data.data[i+2], data_ptr[j+2] );
        NFAput_string( &data.data[i+3], data_ptr[j+3] );
        NFAput_string( &data.data[i+4], data_ptr[j+4] );
        NFAput_string( &data.data[i+5], data_ptr[j+5] );
	j+=data_list->columns;
    }

/*  Open and format buffer for chosen savesets */
    status = MEMopen( &chosen, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &syn_list );
	MEMclose( &data_list );
	_NFIdebug ((fname, "MEMopen: <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname,"MEMopen" );
	return( status );
    }

    sprintf( str, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( chosen, "n_catalogname", str );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &syn_list );
	MEMclose( &data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( chosen, "n_itemname", str );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &syn_list );
	MEMclose( &data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( chosen, "n_itemrev", str );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &syn_list );
	MEMclose( &data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_COFILENAME );
    status = MEMwrite_format( chosen, "n_cofilename", str );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &syn_list );
	MEMclose( &data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_FILEVERSION );
    status = MEMwrite_format( chosen, "n_fileversion", str );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &syn_list );
	MEMclose( &data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_DATE );
    status = MEMwrite_format( chosen, "n_restoredate", str );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &syn_list );
	MEMclose( &data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
   
    status = MEMwrite_format( chosen, "n_catalogno", "integer" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &syn_list );
	MEMclose( &data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( chosen, "n_itemno", "integer" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &syn_list );
	MEMclose( &data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( chosen, "n_fileno", "integer" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &syn_list );
	MEMclose( &data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

/*  Pick up data that was selected */
    _NFIdebug ((fname, "Process form.\n"));
    while( ! CHOSEN_ONE )
    {
	status = SCprocess_free_form( &data, NFMprint_file );
        if( data.sts == FORM_CANCELED )
        {
	    NFAfree_list(data.data,data.num_of_rows,data.num_of_cols );
  	    free( data.data );
	    MEMclose( &data_list );
	    MEMclose( &chosen );
	    ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
	    return( NFI_W_COMMAND_CANCELLED );
        }
        for( i=0,k=0; i<data.num_of_rows; ++i )
        {
            if( data.select_set[i] == 1 )
            {
	        CHOSEN_ONE = TRUE;
		/*  Write to return buffer here */
		strcpy( str, "" );
		for( j=0; j<data_list->columns; ++j )
		{
		    sprintf( col_str, "%s\1%", data_ptr[k+j] );
		    strcat( str, col_str );
		}

		status = MEMwrite( chosen, str );
		if( status != MEM_S_SUCCESS )
		{
		    MEMclose( &chosen );    
	 	    MEMclose( &data_list );
		    NFAfree_list(data.data,data.num_of_rows,data.num_of_cols );
		    free( data.data );	
 	            ERRload_struct( NFI, NFI_E_MEMORY,"%s%s",fname,"MEMwrite");
		    return( status );
		}
            } /* end if data.select */
	    k+=data_list->columns;
        } /* end for loop */
    } /* end while */    
    
    MEMclose( &data_list );
    NFAfree_list(data.data,data.num_of_rows,data.num_of_cols );
    free( data.data );

/*  Now send chosen files back to server
 */

    SCdisplay_msg ("Working..");

    status = NFMRdelete_savesets( chosen );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &chosen );
	return( status );
    }
    MEMclose( &chosen );

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
    
    return( NFI_S_SUCCESS );
}

delete_archives()
{
    long	status;

    int  	i;
    int		tot_data;
    int		total;
    int 	CHOSEN_ONE = FALSE;
    
    char	str[500];
    char	**data_ptr;
    char	**syn_ptr;

    MEMptr	chosen    = NULL;
    MEMptr	data_list = NULL;
    MEMptr	syn_list  = NULL;

    struct SCfree_data_st data;
    static char *fname = "NFAdelete_archives";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_archives_to_delete( &syn_list, &data_list);
    if (status != NFM_S_SUCCESS)
        {
	MEMclose (&syn_list);
        MEMclose (&data_list);
        return (status);
        }

    status = MEMbuild_array (syn_list);
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &syn_list );
	MEMclose( &data_list );
	_NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild" );
	return( NFI_E_MEMORY );
    }

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &syn_list );
	MEMclose( &data_list );
	_NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild" );
	return( NFI_E_MEMORY );
    }

    data_ptr = (char **) data_list->data_ptr;
    syn_ptr  = (char **) syn_list->data_ptr;

/*  Set up headers before actually selecting the flagged files */

    _NFIdebug ((fname, "Set up headers.\n"));
    data.num_of_rows = data_list->rows;
    data.num_of_cols = data_list->columns;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_MULTI_ROW;
    data.col_size =(int*)malloc ( data.num_of_cols * sizeof(int) );
    memset( data.col_size, 0, ( data.num_of_cols * sizeof(int) ));

    data.col_size[0] = 20; /* archive_no */
    data.col_size[1] = 10; /* saveset size */
    data.col_size[2] = 10; /* label size */
    data.col_size[3] = 15; /* archive date size */
    data.col_size[4] = 15; /* archive size size */

    data.col_pos = (int*) malloc( data.num_of_cols * sizeof(int) );
    memset( data.col_pos, 0, ( data.num_of_cols * sizeof(int) ));

    total = 0;
    for( i = 0; i < data.num_of_cols; ++i )
    {	
        data.col_pos[i] = total;
        total += data.col_size[i] + 2;
    }
    data.col_just =(int*)malloc( data.num_of_cols * sizeof(int) );
    memset( data.col_just, LEFT_JUSTIFIED, ( data.num_of_cols * sizeof(int)));

/*  Set up header information */
/*  Header line 1 is empty */
    data.h1_pos = (int*) malloc ( sizeof(int) +1 );
    memset( data.h1_pos, 0, sizeof(int) + 1 );
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

/*  Malloc and init header line 2 */

    data.h2_pos = (int*)malloc((data.num_of_cols*sizeof(int)) +1 );
    memset( data.h2_pos, 0,(data.num_of_cols *  sizeof(int)) + 1 );

    total = 0;
    for( i = 0; i < data.num_of_cols; ++i )
    {
        data.h2_pos[i] = total;
        total += data.col_size[i] + 2;
    }
    data.h2_pos[i] = -1;

/*  Header line 3 is empty */

    data.h3_pos = (int*) malloc ( sizeof(int) +1 );
    memset( data.h3_pos, 0, sizeof(int) + 1 );
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;

/*  Put in column names ( Headers 1 and 3 are blank ) */

    data.h1_data = (char**) malloc (sizeof(char*));
    memset( data.h1_data, NULL, (sizeof(char*)));
    NFAput_string( &data.h1_data[0], "" );
    data.h2_data = (char**) malloc (tot_data * (sizeof(char*)));
    memset(data.h2_data, NULL, data.num_of_cols * (sizeof(char*)));
    
    _NFIdebug ((fname, "Load column names.\n"));
    for( i=0; i<syn_list->rows; ++i )
        NFAput_string( &data.h2_data[i], syn_ptr[i] );

    data.h3_data = (char**) malloc (sizeof(char*));
    memset( data.h3_data, NULL, (sizeof(char*)));
    NFAput_string( &data.h3_data[0], "" );
    
    sprintf( data.title, "Select Archives to Delete : " );

    data.select_set = (int*) malloc ( tot_data * sizeof(int) );
    memset( data.select_set, 0, ( tot_data * sizeof(int) ));

/*  Allocate and initialize space to store data */

    data.data = (char**) malloc ( tot_data * sizeof(char*) );
    memset( data.data, NULL, (tot_data * sizeof(char*) ) );

    _NFIdebug ((fname, "Load data.\n"));
    for( i=0; i < tot_data; i+= data.num_of_cols )
    {
	NFAput_string( &data.data[i],   data_ptr[i] );
        NFAput_string( &data.data[i+1], data_ptr[i+1] );
	NFAput_string( &data.data[i+2], data_ptr[i+2] );
        NFAput_string( &data.data[i+3], data_ptr[i+3] );
        NFAput_string( &data.data[i+4], data_ptr[i+4] );
    }

    status = MEMopen( &chosen, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	_NFIdebug ((fname, "MEMopen: <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname,"MEMopen" );
	return( status );
    }

    status = MEMwrite_format( chosen, "archive_no", "integer" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	_NFIdebug ((fname, "MEMwrite_format: <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname,"MEMwrite_format" );
	return( status );
    }

/*  Pick up data that was selected */
    _NFIdebug ((fname, "Process form.\n"));
    while( ! CHOSEN_ONE )
    {
	status = SCprocess_free_form( &data, NFMprint_file );
        if( data.sts == FORM_CANCELED )
        {
	    NFAfree_list(data.data,data.num_of_rows,data.num_of_cols );
  	    free( data.data );
	    MEMclose( &data_list );
	    MEMclose( &chosen );
	    ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
	    return( NFI_W_COMMAND_CANCELLED );
        }
        for( i = 0; i < data.num_of_rows; ++i )
        {
            if( data.select_set[i] == 1 )
            {
	        CHOSEN_ONE = TRUE;
		/*  Write to return buffer here */
		sprintf( str, "%s\1%", data.data[i*data.num_of_cols]);
		status = MEMwrite( chosen, str );
		if( status != MEM_S_SUCCESS )
		{
		    MEMclose( &chosen );    
	 	    MEMclose( &data_list );
		    NFAfree_list(data.data,data.num_of_rows,data.num_of_cols );
		    free( data.data );	
 	            ERRload_struct( NFI, NFI_E_MEMORY,"%s%s",fname,"MEMwrite");
		    return( status );
		}
            } /* end if data.select */
        } /* end for loop */
    } /* end while */    
    
    MEMclose( &data_list );
    NFAfree_list(data.data,data.num_of_rows,data.num_of_cols );
    free( data.data );

/*  Now send chosen files back to server
 */

    SCdisplay_msg ("Working..");
    _NFIdebug ((fname, "Call NFMRdelete_archives\n"));
    status = NFMRdelete_archives( chosen );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &chosen );
	return( status );
    }
    MEMclose( &chosen );

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
    
    return( NFI_S_SUCCESS );
}
