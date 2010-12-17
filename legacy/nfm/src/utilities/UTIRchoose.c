#include "machine.h"
#include "NFMRextern.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFIerrordef.h"
#include "UTIerrordef.h"

#define  BUFFER_SIZE  1000

extern   char NFMprint_file[40];

char	 *UTIRup();

UTIchoose_sa( util_name, util_ch, sa_attr, label_value, sa_no, label )
    char 	*util_name;   	/* i - utility ( "A", "B" etc. ) */
    char	*util_ch;
    MEMptr	sa_attr;	/* i - buffer of sa attribute names */
    MEMptr	label_value;	/* i - buffer of label values */
    char	*sa_no; 	/* o - chosen storage area number */
    char	*label; 	/* o - chosen label ( if applicable ) */
{
    int		i;
    int 	tot_data;
    int		count;
    int		ROW_CHOSEN;

    long 	status;

    char	sa_dt[10];

    char	**attr_data_ptr;
    char	**attr_column_ptr;

    struct	SCfree_data_st data;

    static	char *fname = "UTIchoose_sa";

    status = MEMbuild_array( sa_attr );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &sa_attr );
	_NFIdebug(( fname, "MEMbuild_array: <0x%.8x>\n", status ));
	return( status );
    }

/*  Display and choose storage area
 */
    attr_data_ptr    = (char**) sa_attr->data_ptr;
    attr_column_ptr  = (char**) sa_attr->column_ptr;

    data.num_of_rows = sa_attr->rows;
    data.num_of_cols = sa_attr->columns;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.col_size = (int*)malloc( data.num_of_cols * sizeof(int) );

    memset( data.col_size, 0, (data.num_of_cols * sizeof(int) ) );

    data.col_size[0] = 20;	/* SA number */
    data.col_size[1] = 20;	/* SA name */
    data.col_size[2] = 20;	/* Node number */
    data.col_size[3] = 20;	/* Device type */

    data.col_pos = (int*) malloc( data.num_of_cols * sizeof(int) );
    memset( data.col_pos, 0, ( data.num_of_cols * sizeof(int) ) );

    count = 0;
    for( i=0; i<data.num_of_cols; ++i )
    {
 	data.col_pos[i] = count;
	count += data.col_size[i] + 2;
    }

    data.col_just = (int*)malloc(data.num_of_cols*sizeof(int));
    memset( data.col_just, LEFT_JUSTIFIED, (data.num_of_cols*sizeof(int)));

    data.h1_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h1_pos, 0, sizeof(int) + 1 );
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int*)malloc((data.num_of_cols * sizeof( int) ) + 1 );
    memset( data.h2_pos, 0, (data.num_of_cols*sizeof(int)) + 1 );
    count = 0;
    for( i=0; i<data.num_of_cols; ++i )
    {
	data.h2_pos[i] = count;
	count += data.col_size[i] + 2;
    }
    data.h2_pos[i] = -1;

    data.h3_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h3_pos, 0, sizeof( int ) + 1 );
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;

    data.h1_data = (char**) malloc(sizeof(char*) );
    memset( data.h1_data, NULL, (sizeof(char*)));
    NFAput_string( &data.h1_data[0], "" );

    data.h2_data = (char**) malloc(data.num_of_cols*sizeof(char*)+1 );
    memset( data.h2_data, NULL, (data.num_of_cols*sizeof(char*)+1));

    NFAput_string( &data.h2_data[0], attr_column_ptr[0] );
    NFAput_string( &data.h2_data[1], attr_column_ptr[1] );
    NFAput_string( &data.h2_data[2], attr_column_ptr[2] );
    NFAput_string( &data.h2_data[3], attr_column_ptr[3] );

    data.h3_data = (char**) malloc(sizeof(char*));
    memset( data.h3_data, NULL, (sizeof(char*)));
    NFAput_string( &data.h3_data[0], "" );

    sprintf( data.title, "Available Storage Areas for %s : ", util_name );

    data.select_set = (int*) malloc( tot_data * sizeof(int) );
    memset( data.select_set, 0, ( tot_data * sizeof(int) ) );

    data.data = (char**) malloc ( tot_data * sizeof(char*) );
    memset( data.data, NULL, ( tot_data * sizeof(char*) ) );

/*  Now use data buffer
 */
    for( i=0; i<tot_data; i+=data.num_of_cols )
    {
	NFAput_string( &data.data[i],   attr_data_ptr[i]   );
	NFAput_string( &data.data[i+1], attr_data_ptr[i+1] );
	NFAput_string( &data.data[i+2], UTIRup(attr_data_ptr[i+2]));
	NFAput_string( &data.data[i+3], attr_data_ptr[i+3] );
    }
    ROW_CHOSEN = FALSE;
    while( !ROW_CHOSEN )
    {
        status = SCprocess_free_form( &data, NFMprint_file );
        if( data.sts == FORM_CANCELED )
        {
 	    NFAfree_list( data.data, data.num_of_rows, data.num_of_cols );
	    free( data.data );
	    MEMclose( &sa_attr );
	    ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
	    return( NFI_W_FORM_CANCELED );
        }

/*  Pick up storage area number that was selected
 */
        ROW_CHOSEN = FALSE;
        for( i=0; i<data.num_of_rows; ++i )
	    if( data.select_set[i] == 1 )
   	    {
	        ROW_CHOSEN = TRUE;
    	        strcpy( sa_no, data.data[i*data.num_of_cols] );    
 	        strcpy( sa_dt, data.data[(i*data.num_of_cols) + 2] );    
                _NFIdebug(( fname, "Chosen sa_no <%s>\n", sa_no ));
	        break;
	    }
	if( !ROW_CHOSEN )
  	    SCdisplay_msg( "NFM:  Must Enter Storage Area Name.");
        }

    NFAfree_list( data.data, data.num_of_rows, data.num_of_cols );
    free( data.data );
    MEMclose( &sa_attr );

/*  Determine label to be used depending on device type
 */
    status = UTIchoose_label( util_name, util_ch, sa_dt, label_value, label );
    _NFIdebug(( fname, "Chosen label : <%s>\n", label ));

    MEMclose( &label_value );
    
    if( status != UTI_S_SUCCESS )
        return( status );

    return( UTI_S_SUCCESS );
}

/*  User chooses flagged files
 */
UTIchoose_flagged_files( util_name, util_ch, file_value, file_list )
    char        *util_name;	/* i - utility ( "A", "B", "R" or "D" ) */
    char	*util_ch;
    MEMptr	file_value;	/* i - buffer of file values */
    MEMptr	*file_list;	/* o - chosen flagged files */
{
    int		i;
    int 	tot_data;
    int 	count = 0;
    int		mass = 0;
    int		offset;

    long 	status;

    char	str[100];
    char	**value_data_ptr;
    char	**value_column_ptr;

    struct	SCfree_data_st fdata;
    struct	SCfree_data_st data;
	
    static 	char *fname = "UTIchoose_flagged_files";
 
    data.num_of_rows = 2;
    data.num_of_cols = 1;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.max_indent = 0;

    data.col_size = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_size, 0, (data.num_of_cols * sizeof(int)));
    data.col_size[0] = 35;

    data.col_pos = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_pos, 0, (data.num_of_cols * sizeof(int)));
    data.col_pos[0] = 0;

    data.col_just = (int*) malloc( data.num_of_cols * sizeof( int ));
    memset( data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof( int )));

    data.h1_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h1_pos, 0, sizeof(int) + 1 );
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;
         
    data.h2_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h2_pos, 0, sizeof(int) + 1 );
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;

    data.h3_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h3_pos, 0, sizeof(int) + 1 );
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
 
    data.h1_data = (char**)malloc( sizeof(char*) );
    memset( data.h1_data, NULL, sizeof(char*) );
    NFAput_string( &data.h1_data[0], "" );
    
    data.h2_data = (char**)malloc( sizeof(char*) );
    memset( data.h2_data, NULL, sizeof(char*) );
    NFAput_string( &data.h2_data[0], "" );

    data.h3_data = (char**)malloc( sizeof(char*) );
    memset( data.h3_data, NULL, sizeof(char*) );
    NFAput_string( &data.h3_data[0], "" );

    strcpy(data.title, "Establish Item Selection Method" );

    data.select_set = (int*) malloc( tot_data * sizeof(int));
    memset( data.select_set, 0, tot_data * sizeof(int) );

    data.data = (char **) malloc ( tot_data * sizeof (char *));
    memset (data.data, NULL, tot_data * sizeof (char *));

    NFAput_string (&data.data[0], "Select Flagged Items Individually" );
    NFAput_string (&data.data[1], "Select All Flagged Items" );

    status = SCprocess_free_form( &data, NFMprint_file );
    if( data.sts == FORM_CANCELED )
    {
        NFAfree_list(data.data,data.num_of_rows,data.num_of_cols );
        free( data.data );
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return( NFI_W_FORM_CANCELED );
    }
    if( data.select_set[1] == 1 )
	mass = 1;

    NFAfree_list(data.data,data.num_of_rows,data.num_of_cols );
    free( data.data );

/*  Now get the flagged files
 */
    status = MEMbuild_array( file_value );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &file_value );
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

/*  Display and choose storage area
 */
    value_data_ptr   = (char**) file_value->data_ptr;
    value_column_ptr = (char**) file_value->column_ptr;

    fdata.num_of_rows = file_value->rows;
    fdata.num_of_cols = file_value->columns;
    tot_data = fdata.num_of_rows * fdata.num_of_cols;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 1;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_MULTI_ROW;
    fdata.col_size = (int*)malloc( fdata.num_of_cols * sizeof(int) );
    memset( fdata.col_size, 0, (fdata.num_of_cols * sizeof(int) ) );

    _NFIdebug(( fname, "rows : <%d>\n", fdata.num_of_rows ));
    _NFIdebug(( fname, "cols : <%d>\n", fdata.num_of_cols ));

    for( i=0; i<fdata.num_of_cols; ++i )
    {
        NFAfind_max_data_len( value_column_ptr, value_data_ptr, i,
  	   file_value->columns, file_value->rows, &fdata.col_size[i]);
    	_NFIdebug(( fname, "fdata.col_size[%d] <%d>\n",i,fdata.col_size[i] ));
    }

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
    {
/*  Set up offset to link # depending on the utility */
 	if( strcmp( value_column_ptr[i], "Link" ) == 0 )
	{
	    _NFIdebug(( fname, "Link offset <%d>\n", i ));
	    offset = i;
	}
        NFAput_string( &fdata.h2_data[i], value_column_ptr[i] );
    }

    fdata.h3_data = (char**) malloc( sizeof(char*) );
    memset( fdata.h3_data, NULL, (sizeof(char*)));
    NFAput_string( &fdata.h3_data[0], "" );

    sprintf( fdata.title, "Items Flagged for %s : ", util_name );

    fdata.select_set = (int*) malloc( tot_data * sizeof(int) );
    memset( fdata.select_set, 0, ( tot_data * sizeof(int) ) );

    fdata.data = (char**) malloc ( tot_data * sizeof(char*) );
    memset( fdata.data, NULL, ( tot_data * sizeof(char*) ) );

/*  Now use data buffer
 */
    for( i=0; i<tot_data; ++i )
        NFAput_string( &fdata.data[i], value_data_ptr[i] );

    if( !mass )
    {
        status = SCprocess_free_form( &fdata, NFMprint_file );
        if( fdata.sts == FORM_CANCELED )
        {
	    NFAfree_list( fdata.data, fdata.num_of_rows, fdata.num_of_cols );
	    free( fdata.data );
	    MEMclose( &file_value );
   	    ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
	    return( NFI_W_FORM_CANCELED );
        }
    }

/*  Pick up files that were chosen
 */
    _NFIdebug((fname, "Before process_free Form\n"));
    status = MEMopen( file_list, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	_NFIdebug(( fname, "MEMopen <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    status = MEMwrite_format( *file_list, "link_number", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
	_NFIdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }
    
    for( i=0; i<fdata.num_of_rows; ++i )
    {
	if( ( fdata.select_set[i] == 1 ) || mass )
	{
	    strcpy( str, fdata.data[(i*fdata.num_of_cols)+offset]);
	    _NFIdebug(( fname, "Link <%s>\n", str ));
	    status = MEMwrite( *file_list, str );
	    if( status != MEM_S_SUCCESS )
	    {
		_NFIdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
		MEMclose( file_list );
		ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		return( NFM_E_MEM );
	    }
	}
    }

    NFAfree_list( fdata.data, fdata.num_of_rows, fdata.num_of_cols );
    free( fdata.data );

    MEMclose( &file_value );

    _NFIdebug((fname, "Returing Success\n"));
    return( UTI_S_SUCCESS );
}

/* This routine lets the user decide on a new or existing label and gets
 * the label according to the chosen device type
 */
UTIchoose_label( util_name, util_ch, device_type, label_value, label )
    char 	*util_name;   	/* i - utility ( "A" or "B" ) */
    char 	*util_ch;
    char 	*device_type; 	/* i - device type */
    MEMptr	label_value;	/* i - buffer of defined labels */
    char	*label;		/* o - chosen label */
{
    int    tot_data;
    int    status;

    struct SCfree_data_st data;

    if( strcmp( device_type, "HD" ) == 0 )
    {
	strcpy( label, "DISK_" );
	strcat( label, util_ch );
	return( UTI_S_SUCCESS );
    }

    if( strcmp( device_type, "OD" ) == 0 )
    {
 	strcpy( label, "DISK_O" );
	return( UTI_S_SUCCESS );
    }
    if( strcmp( device_type, "FD" ) == 0 )
    {
 	strcpy( label, "DISK_F" );
	return( UTI_S_SUCCESS );
    }
    if( strcmp( device_type, "MO" ) == 0 )
    {
 	strcpy( label, "DISK_J" );
	return( UTI_S_SUCCESS );
    }
    if( strcmp( device_type, "WR" ) == 0 )
    {
 	strcpy( label, "DISK_J" );
	return( UTI_S_SUCCESS );
    }
    if( strcmp( device_type, "CA" ) == 0 )
    {
 	strcpy( label, "DISK_C" );
	return( UTI_S_SUCCESS );
    }

/*  Otherwise we have to choose a label or give a new one.
 *  Force no-labels case to get a new label.
 */
    if( label_value == NULL )
    {
        status = UTIyou_or_me( label );
	if( status != UTI_S_SUCCESS )
            return( status );
        return( UTI_S_SUCCESS );
    }
    data.num_of_rows = 2;
    data.num_of_cols = 1;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.max_indent = 0;

    data.col_size = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_size, 0, (data.num_of_cols * sizeof(int)));
    data.col_size[0] = 15;

    data.col_pos = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_pos, 0, (data.num_of_cols * sizeof(int)));
    data.col_pos[0] = 0;

    data.col_just = (int*) malloc( data.num_of_cols * sizeof( int ));
    memset( data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof( int )));

    data.h1_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h1_pos, 0, sizeof(int) + 1 );
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;
         
    data.h2_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h2_pos, 0, sizeof(int) + 1 );
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;

    data.h3_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h3_pos, 0, sizeof(int) + 1 );
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
 
    data.h1_data = (char**)malloc( sizeof(char*) );
    memset( data.h1_data, NULL, sizeof(char*) );
    NFAput_string( &data.h1_data[0], "" );
    
    data.h2_data = (char**)malloc( sizeof(char*) );
    memset( data.h2_data, NULL, sizeof(char*) );
    NFAput_string( &data.h2_data[0], "" );

    data.h3_data = (char**)malloc( sizeof(char*) );
    memset( data.h3_data, NULL, sizeof(char*) );
    NFAput_string( &data.h3_data[0], "" );

    strcpy (data.title, "Choose Type of Label");

    data.select_set = (int*) malloc( tot_data * sizeof(int));
    memset( data.select_set, 0, tot_data * sizeof(int) );

    data.data = (char **) malloc ( tot_data * sizeof (char *));
    memset (data.data, NULL, tot_data * sizeof (char *));

    NFAput_string (&data.data[0], "New Label" );
    NFAput_string (&data.data[1], "Existing Label" );

    status = SCprocess_free_form( &data, NFMprint_file );

    if( data.select_set[0] == 1 )
    {
        NFAfree_list( data.data, data.num_of_rows, data.num_of_cols );
        free( data.data );
        /* New label */
        status = UTIyou_or_me( label );
    }
    else if( data.select_set[1] == 1 )
    {
        NFAfree_list( data.data, data.num_of_rows, data.num_of_cols );
        free( data.data );
	/* Existing label */
        status = UTIlist_labels( label_value, label );
    }
    else
        SCdisplay_msg( "NFM:  Please choose a label generation method." );

    if( data.sts == FORM_CANCELED || status == NFI_W_FORM_CANCELED )
    {
        SCclear_msg();
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return( NFI_W_FORM_CANCELED );
    }	

    if( status != UTI_S_SUCCESS )
        return( status );

    return( UTI_S_SUCCESS );
}

UTIyou_or_me( label )
    char   *label;
{
    int    tot_data;
    int	   status;

    struct SCfree_data_st data;

    static char *fname = "UTIyou_or_me";

    data.num_of_rows = 2;
    data.num_of_cols = 1;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.max_indent = 0;

    data.col_size = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_size, 0, (data.num_of_cols * sizeof(int)));
    data.col_size[0] = 25;

    data.col_pos = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_pos, 0, (data.num_of_cols * sizeof(int)));
    data.col_pos[0] = 0;

    data.col_just = (int*) malloc( data.num_of_cols * sizeof( int ));
    memset( data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof( int )));

    data.h1_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h1_pos, 0, sizeof(int) + 1 );
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;
         
    data.h2_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h2_pos, 0, sizeof(int) + 1 );
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;

    data.h3_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h3_pos, 0, sizeof(int) + 1 );
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
 
    data.h1_data = (char**)malloc( sizeof(char*) );
    memset( data.h1_data, NULL, sizeof(char*) );
    NFAput_string( &data.h1_data[0], "" );
    
    data.h2_data = (char**)malloc( sizeof(char*) );
    memset( data.h2_data, NULL, sizeof(char*) );
    NFAput_string( &data.h2_data[0], "" );

    data.h3_data = (char**)malloc( sizeof(char*) );
    memset( data.h3_data, NULL, sizeof(char*) );
    NFAput_string( &data.h3_data[0], "" );

    strcpy (data.title, "Choose Origination of Label");

    data.select_set = (int*) malloc( tot_data * sizeof(int));
    memset( data.select_set, 0, tot_data * sizeof(int) );

    data.data = (char **) malloc ( tot_data * sizeof (char *));
    memset (data.data, NULL, tot_data * sizeof (char *));

    NFAput_string (&data.data[0], "User Given Label" );
    NFAput_string (&data.data[1], "System Generated Label" );

    status = SCprocess_free_form( &data, NFMprint_file );

    if( data.select_set[0] == 1 )
    {
    	/* User given label */
        _NFIdebug(( fname, "%s\n", "User giving new label" ));
        status = UTIget_label( label );
	return( status );
    }/* end if data.select_set[0] */

    if( data.select_set[1] == 1 )
    {
        /* System generated label */
        _NFIdebug(( fname, "%s\n", "System generated label" ));
	strcpy( label, "SYSLAB" );
    }/* end if data.select_set[1] */

    if( data.sts == FORM_CANCELED )
    {
        NFAfree_list(data.data,data.num_of_rows,data.num_of_cols );
        free( data.data );
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return( NFI_W_FORM_CANCELED );
    }

    NFAfree_list(data.data,data.num_of_rows,data.num_of_cols );
    free( data.data );
    return( UTI_S_SUCCESS );
}

UTIget_label( label )
    char   *label;
{
    int    tot_data;
    int    FORM_FILLED;
    int    status;

    struct SCcolumn_data_st data;

    static char *fname = "UTIget_label";

    data.num_of_rows = 1;
    data.num_of_cols = 2;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc 
                             (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    data.col_width[0] = 20;
    data.col_width[1] = 7;

    data.new_rows_expected = FALSE;

    strcpy (data.title, "Establish Label Name ");

    data.selectable = (int *) malloc ( tot_data * sizeof (int));
    memset (data.selectable, 0, tot_data * sizeof (int));

    data.hidden = (int *) malloc ( tot_data * sizeof (int));
    memset (data.hidden, 0, tot_data * sizeof (int));

    data.selectable[0] = 0;
    data.selectable[1] = 1;

    data.data = (char **) malloc ( tot_data * sizeof (char *));
    memset (data.data, NULL, tot_data * sizeof (char *));

    NFAput_string (&data.data[0], "Label name  char(6)" );
    NFAput_string (&data.data[1], "" );

    do
    {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        if( ( strlen( data.data[1] ) == 0 ) && (data.sts != FORM_CANCELED ) )
        {
            FORM_FILLED = FALSE;
            SCdisplay_msg( "NFM:  Label name must be entered." );
        }
    } /* end do */
    while( ( FORM_FILLED == FALSE ) && ( data.sts != FORM_CANCELED ) );

    if( data.sts == FORM_CANCELED )
    {
        NFAfree_list( data.data, data.num_of_rows, data.num_of_cols );
        free( data.data );
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return( NFI_W_FORM_CANCELED );
    }

    _NFIdebug(( fname, "User given label --> %s\n", data.data[1] ));

    strcpy( label, data.data[1] );

    NFAfree_list( data.data, data.num_of_rows, data.num_of_cols );
    free( data.data );

    return( UTI_S_SUCCESS );
}

UTIlist_labels( label_value, label )
    MEMptr	label_value;
    char	*label;
{
    int  i;
    int  tot_data;
    int  CHOSEN_ONE;
    long status;

    char **data_ptr;

    struct SCfree_data_st data;

    static char *fname = "UTIlist_labels";

/*  Build form to show labels used 
 */
    status = MEMbuild_array( label_value );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &label_value );
	return( status );
    }

    data_ptr = (char**)label_value->data_ptr;
    data.num_of_rows = label_value->rows;
    data.num_of_cols = 1;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.max_indent = 0;

    data.col_size = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_size, 0, (data.num_of_cols * sizeof(int)));
    data.col_size[0] = 10;
   
    data.col_pos = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_pos, 0, (data.num_of_cols * sizeof(int)));
    data.col_pos[0] = 0;
 
    data.col_just = (int*) malloc( data.num_of_cols * sizeof( int ));
    memset( data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof( int )));

    data.h1_pos = (int*)malloc( sizeof(int) + 1 ); 
    memset( data.h1_pos, 0, sizeof(int) + 1 );
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;
           
    data.h2_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h2_pos, 0, sizeof(int) + 1 );
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;

    data.h3_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h3_pos, 0, sizeof(int) + 1 );
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;

    data.h1_data = (char**)malloc( sizeof(char*) );
    memset( data.h1_data, NULL, sizeof(char*) );
    NFAput_string( &data.h1_data[0], "" );
    
    data.h2_data = (char**)malloc( sizeof(char*) );
    memset( data.h2_data, NULL, sizeof(char*) );
    NFAput_string( &data.h2_data[0], "" );
 
    data.h3_data = (char**)malloc( sizeof(char*) );
    memset( data.h3_data, NULL, sizeof(char*) );
    NFAput_string( &data.h3_data[0], "" );

    strcpy (data.title, "Choose Existing Label");

    data.select_set = (int*) malloc( tot_data * sizeof(int));
    memset( data.select_set, 0, tot_data * sizeof(int) );
    
    data.data = (char **) malloc ( tot_data * sizeof (char *));
    memset (data.data, NULL, tot_data * sizeof (char *));

    for( i=0; i < tot_data; ++i )
        NFAput_string( &data.data[i], data_ptr[i] );

    CHOSEN_ONE = FALSE;
    do
    {
        status = SCprocess_free_form (&data, NFMprint_file);
        for( i = 0; i < data.num_of_rows; ++i )
        {
	    if( data.select_set[i] == 1 )
	    {
		strcpy( label, data.data[i] );
		CHOSEN_ONE = TRUE;
		_NFIdebug(( fname, "Chosen label <%s>\n", label ));
	    }
	} /* end for */
	if( data.sts == FORM_CANCELED )
        {
            NFAfree_list( data.data, data.num_of_rows, data.num_of_cols );
	    free( data.data );
            ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
            return( NFI_W_FORM_CANCELED );
        }	
    } /* end do */
    while( !CHOSEN_ONE );

    NFAfree_list( data.data, data.num_of_rows, data.num_of_cols );
    free( data.data );

    return( UTI_S_SUCCESS );
}

/*  User lists flagged files
 */
UTIRlist_flagged_files( util, file_value )
    char 	*util;		/* i - utility */
    MEMptr	file_value;	/* i - buffer of file values */
{
    int		i;
    int		j;
    int 	tot_data;
    int		count;

    long 	status;

    char	**value_data_ptr;
    char	**value_column_ptr;

    struct	SCfree_data_st fdata;
	
    status = MEMbuild_array( file_value );
    if( status != MEM_S_SUCCESS )
    {
	if( status == MEM_E_NULL_LIST )
	{
	    MEMclose( &file_value );
	    ERRload_struct( UTI, UTI_I_NO_FLAGGED_FILES, NULL, NULL );
	    return( UTI_I_NO_FLAGGED_FILES );
	}
	else
	{
  	    MEMclose( &file_value );
	    return( status );
	}
    }

    value_data_ptr   = (char**) file_value->data_ptr;
    value_column_ptr = (char**) file_value->column_ptr;

    if( file_value->rows == 0 )
    {
        MEMclose( &file_value );
        ERRload_struct( UTI, UTI_I_NO_FLAGGED_FILES, NULL, NULL );
        return( UTI_I_NO_FLAGGED_FILES );
    }

    fdata.num_of_rows = file_value->rows;
    fdata.num_of_cols = file_value->columns;
    tot_data = fdata.num_of_rows * fdata.num_of_cols;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 1;
    fdata.max_indent = 0;
    fdata.select_set_expected = FALSE;
    fdata.col_size = (int*)malloc( fdata.num_of_cols * sizeof(int) );
    memset( fdata.col_size, 0, (fdata.num_of_cols * sizeof(int) ) );

    for( i=0; i<fdata.num_of_cols; ++i )
        NFAfind_max_data_len( value_column_ptr, value_data_ptr, i,
  	   file_value->columns, file_value->rows, &fdata.col_size[i]);
    
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

    NFAput_string( &fdata.h2_data[0], value_column_ptr[0] );
    NFAput_string( &fdata.h2_data[1], value_column_ptr[1] );
    NFAput_string( &fdata.h2_data[2], value_column_ptr[2] );
    NFAput_string( &fdata.h2_data[3], value_column_ptr[3] );

    fdata.h3_data = (char**) malloc( sizeof(char*) );
    memset( fdata.h3_data, NULL, (sizeof(char*)));
    NFAput_string( &fdata.h3_data[0], "" );

    sprintf( fdata.title, "Items Flagged for %s : ", util );

    fdata.select_set = (int*) malloc( tot_data * sizeof(int) );
    memset( fdata.select_set, 0, ( tot_data * sizeof(int) ) );

    fdata.data = (char**) malloc ( tot_data * sizeof(char*) );
    memset( fdata.data, NULL, ( tot_data * sizeof(char*) ) );

/*  Now use data buffer
 */
    for( i=0,j=0; i<tot_data; i+=fdata.num_of_cols,j+=file_value->columns )
    {
        NFAput_string( &fdata.data[i],   value_data_ptr[j] );
        NFAput_string( &fdata.data[i+1], value_data_ptr[j+1] );
        NFAput_string( &fdata.data[i+2], value_data_ptr[j+2] );
        NFAput_string( &fdata.data[i+3], value_data_ptr[j+3] );
    }

    status = SCprocess_free_form( &fdata, NFMprint_file );

    NFAfree_list( fdata.data, fdata.num_of_rows, fdata.num_of_cols );
    free( fdata.data );
    MEMclose( &file_value );
    return( UTI_S_SUCCESS );
}

char*
UTIRup( text )
  char *text;
{
	char *str;
	char *ret;

	str = (char*) malloc( strlen( text ) +1 );
	ret = str;
	for( ; *text != '\0'; )
	    *str++ = toupper( *text++ );
        *str = '\0';

	return( ret );
}
