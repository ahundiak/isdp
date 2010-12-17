#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "ERR.h"
#include "NDXstruct.h"
#include "DEBUG.h"

long sqlquery()

{
    long   status;
    int    i;
    int    tot_data;
    int    pos;
    int    count = 0;
    int    FORM_FILLED;

    char   **column_ptr;
    char   **format_ptr;
    char   **data_ptr;

    struct SCcolumn_data_st data;
    struct SCfree_data_st   fdata;

    MEMptr db_data = NULL;

    static char *fname = "NFIsqlquery";

    pos = 0;
    data.num_of_rows = 2;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 10;
    data.col_width[1] = 80;

    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Database Query");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "SQL Query");
    NFAput_string (&data.data[2], "Size");

    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n",
		 data.sts));
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
    }

    _NFIdebug(( fname, "SQL string  <%s>\n", data.data[1] ));
    _NFIdebug(( fname, "Buffer Size <%s>\n", data.data[3] ));

    status = NFMRsqlquery ( data.data[1], data.data[3], &db_data );
    if (status != NFM_S_SUCCESS)
    {
	MEMclose (&db_data);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_E_SQLQUERY, NULL, NULL );
        return (status);
    }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    status = MEMbuild_array (db_data);

    column_ptr = (char **) db_data->column_ptr;
    format_ptr = (char **) db_data->format_ptr;
    data_ptr   = (char **) db_data->data_ptr;

    fdata.num_of_rows = db_data->rows;
    fdata.num_of_cols = db_data->columns;
    tot_data = fdata.num_of_rows * fdata.num_of_cols;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0;
    fdata.max_indent = 0;
    fdata.select_set_expected = FALSE;
    fdata.col_size = (int*)malloc( fdata.num_of_cols * sizeof(int) );
    memset( fdata.col_size, 0, (fdata.num_of_cols * sizeof(int) ) );

    for( i=0; i<fdata.num_of_cols; ++i )
        fdata.col_size[i] = 20;

    fdata.col_pos = (int*) malloc( fdata.num_of_cols * sizeof(int) );
    memset( fdata.col_pos, 0, ( fdata.num_of_cols * sizeof(int) ) );

    count = 0;
    for( i=0; i<fdata.num_of_cols; ++i )
    {
 	fdata.col_pos[i] = count;
	count += fdata.col_size[i] + 2;
    }

    fdata.col_just = (int*)malloc(fdata.num_of_cols*sizeof(int));
    memset( fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols*sizeof(int)));

    fdata.h1_pos = (int*)malloc( sizeof(int) + 1 );
    memset( fdata.h1_pos, 0, sizeof(int) + 1 );
    fdata.h1_pos[0] = 0;
    fdata.h1_pos[1] = -1;

    fdata.h2_pos = (int*)malloc((fdata.num_of_cols * sizeof( int) ) + 1 );
    memset( fdata.h2_pos, 0, (fdata.num_of_cols*sizeof(int)) + 1 );
    count = 0;
    for( i=0; i<fdata.num_of_cols; ++i )
    {
	fdata.h2_pos[i] = count;
	count += fdata.col_size[i] + 2;
    }
    fdata.h2_pos[i] = -1;

    fdata.h3_pos = (int*)malloc( sizeof(int) + 1 );
    memset( fdata.h3_pos, 0, sizeof( int ) + 1 );
    fdata.h3_pos[0] = 0;
    fdata.h3_pos[1] = -1;

    fdata.h1_data = (char**) malloc( sizeof(char*) );
    memset( fdata.h1_data, NULL, (sizeof(char*)));
    NFAput_string( &fdata.h1_data[0], "" );

    fdata.h2_data = (char**) malloc(fdata.num_of_cols*sizeof(char*)+1 );
    memset( fdata.h2_data, NULL, (fdata.num_of_cols*sizeof(char*))+1);

    for( i=0; i<fdata.num_of_cols; ++i )
        NFAput_string( &fdata.h2_data[i], column_ptr[i] );

    fdata.h3_data = (char**) malloc( sizeof(char*) );
    memset( fdata.h3_data, NULL, (sizeof(char*)));
    NFAput_string( &fdata.h3_data[0], "" );

    strcpy( fdata.title, "Database Query Results" );

    fdata.select_set = (int*) malloc( tot_data * sizeof(int) );
    memset( fdata.select_set, 0, ( tot_data * sizeof(int) ) );

    fdata.data = (char**) malloc ( tot_data * sizeof(char*) );
    memset( fdata.data, NULL, ( tot_data * sizeof(char*) ) );

/*  Now use data buffer
 */
    for( i=0; i<tot_data; ++i )
        NFAput_string( &fdata.data[i], data_ptr[i] );

    status = SCprocess_free_form( &fdata, NFMprint_file );

    MEMclose( &db_data );
    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free( fdata.data );

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long sqlquery_cursor()

{
    long   status;
    long   save_status;
    int    i;
    int    tot_data;
    int    pos;
    int    count = 0;
    int    FORM_FILLED;

    char   **column_ptr;
    char   **format_ptr;
    char   **data_ptr;

    struct SCcolumn_data_st data;
    struct SCfree_data_st   fdata;

    MEMptr db_data = NULL;

    static char *fname = "NFIsqlquery";

    pos = 0;
    data.num_of_rows = 4;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 10;
    data.col_width[1] = 80;

    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Database Query");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "SQL Query");
    NFAput_string (&data.data[2], "Size");
    NFAput_string (&data.data[4], "Rows");
    NFAput_string (&data.data[6], "Cursor");

    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n",
		 data.sts));
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
    }

    _NFIdebug(( fname, "SQL string  <%s>\n", data.data[1] ));
    _NFIdebug(( fname, "Buffer Size <%s>\n", data.data[3] ));
    _NFIdebug(( fname, "Rows <%s>\n", data.data[5] ));
    _NFIdebug(( fname, "Cursors <%s>\n", data.data[7] ));

    status = NFMRsqlquery_cursor( data.data[1], data.data[3], 
	  	atol(data.data[5]), atoi( data.data[7]), &db_data );
    if ((status != NFM_S_SUCCESS) && (status != NFM_I_NO_MORE_BUFFERS) )
    {
	MEMclose (&db_data);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_E_SQLQUERY, NULL, NULL );
        return (NFI_E_SQLQUERY);
    }

    save_status = status;

    status = MEMbuild_array (db_data);

    column_ptr = (char **) db_data->column_ptr;
    format_ptr = (char **) db_data->format_ptr;
    data_ptr   = (char **) db_data->data_ptr;

    if( db_data->rows == 0 )
    {
	MEMclose( &db_data );
	ERRload_struct( NFI, NFI_E_SQLQUERY, NULL, NULL );
	return( NFI_E_SQLQUERY );
    }
    fdata.num_of_rows = db_data->rows;
    fdata.num_of_cols = db_data->columns;
    tot_data = fdata.num_of_rows * fdata.num_of_cols;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0;
    fdata.max_indent = 0;
    fdata.select_set_expected = FALSE;
    fdata.col_size = (int*)malloc( fdata.num_of_cols * sizeof(int) );
    memset( fdata.col_size, 0, (fdata.num_of_cols * sizeof(int) ) );

    for( i=0; i<fdata.num_of_cols; ++i )
        fdata.col_size[i] = 20;

    fdata.col_pos = (int*) malloc( fdata.num_of_cols * sizeof(int) );
    memset( fdata.col_pos, 0, ( fdata.num_of_cols * sizeof(int) ) );

    count = 0;
    for( i=0; i<fdata.num_of_cols; ++i )
    {
 	fdata.col_pos[i] = count;
	count += fdata.col_size[i] + 2;
    }

    fdata.col_just = (int*)malloc(fdata.num_of_cols*sizeof(int));
    memset( fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols*sizeof(int)));

    fdata.h1_pos = (int*)malloc( sizeof(int) + 1 );
    memset( fdata.h1_pos, 0, sizeof(int) + 1 );
    fdata.h1_pos[0] = 0;
    fdata.h1_pos[1] = -1;

    fdata.h2_pos = (int*)malloc((fdata.num_of_cols * sizeof( int) ) + 1 );
    memset( fdata.h2_pos, 0, (fdata.num_of_cols*sizeof(int)) + 1 );
    count = 0;
    for( i=0; i<fdata.num_of_cols; ++i )
    {
	fdata.h2_pos[i] = count;
	count += fdata.col_size[i] + 2;
    }
    fdata.h2_pos[i] = -1;

    fdata.h3_pos = (int*)malloc( sizeof(int) + 1 );
    memset( fdata.h3_pos, 0, sizeof( int ) + 1 );
    fdata.h3_pos[0] = 0;
    fdata.h3_pos[1] = -1;

    fdata.h1_data = (char**) malloc( sizeof(char*) );
    memset( fdata.h1_data, NULL, (sizeof(char*)));
    NFAput_string( &fdata.h1_data[0], "" );

    fdata.h2_data = (char**) malloc(fdata.num_of_cols*sizeof(char*)+1 );
    memset( fdata.h2_data, NULL, (fdata.num_of_cols*sizeof(char*))+1);

    for( i=0; i<fdata.num_of_cols; ++i )
        NFAput_string( &fdata.h2_data[i], column_ptr[i] );

    fdata.h3_data = (char**) malloc( sizeof(char*) );
    memset( fdata.h3_data, NULL, (sizeof(char*)));
    NFAput_string( &fdata.h3_data[0], "" );

    strcpy( fdata.title, "Database Query Results" );

    fdata.select_set = (int*) malloc( tot_data * sizeof(int) );
    memset( fdata.select_set, 0, ( tot_data * sizeof(int) ) );

    fdata.data = (char**) malloc ( tot_data * sizeof(char*) );
    memset( fdata.data, NULL, ( tot_data * sizeof(char*) ) );

/*  Now use data buffer
 */
    for( i=0; i<tot_data; ++i )
        NFAput_string( &fdata.data[i], data_ptr[i] );

    status = SCprocess_free_form( &fdata, NFMprint_file );

    while( save_status != NFM_I_NO_MORE_BUFFERS )
    {
        _NFIdebug(( fname, "SQL string  <%s>\n", data.data[1] ));
        _NFIdebug(( fname, "Buffer Size <%s>\n", data.data[3] ));
        _NFIdebug(( fname, "Rows <%s>\n", data.data[5] ));
	MEMclose( &db_data );
	db_data = NULL;

        save_status = NFMRsqlquery_cursor ( data.data[1], data.data[3], 
		  	atol(data.data[5]), atoi( data.data[7] ), &db_data );
        if ((save_status != NFM_S_SUCCESS) && 
	    (save_status != NFM_I_NO_MORE_BUFFERS) )
        {
   	    MEMclose (&db_data);
            NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
            free (fdata.data);
	    ERRload_struct( NFI, NFI_E_SQLQUERY, NULL, NULL );
            return (NFI_E_SQLQUERY);
        }
	status = MEMbuild_array( db_data );
        data_ptr   = (char **) db_data->data_ptr;

	for( i=0; i<tot_data; ++i )
	    NFAput_string( &fdata.data[i], data_ptr[i] );

	status = SCprocess_free_form( &fdata, NFMprint_file );
        if (fdata.sts == FORM_CANCELED)
        {
	    MEMclose( &db_data );
            NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
            free (fdata.data);
  	    ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
            return (NFI_W_FORM_CANCELED);
        }
    }

    MEMclose( &db_data );

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);
    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free( fdata.data );

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}
