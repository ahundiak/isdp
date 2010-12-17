#include "machine.h"
#include "NFMRextern.h"
#include "NFIerrordef.h"
#include "UTIerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "UTIui.h"
#include "ERR.h"

extern   char NFMprint_file[40];
    
/*  This routine processes information that may have been sent back
 *  from the server concerning OFF-LINE utility operations.
 */
UTIRprocess_status( info )
    MEMptr	info;
{
    long 	status;

    static      char *fname = "UTIRprocess_status";

    _NFIdebug(( fname, "%s\n", "Entering ..." ));

    if(info == NULL) 	/** If nothing is passed, return success **/
	return(UTI_S_SUCCESS);

    status = MEMbuild_array( info );
    if (status != MEM_S_SUCCESS)
    {
        _NFIdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
         ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    if( info->rows > 0 )
    {
        status = UTIRinfo_form( info );
        if( status != UTI_S_SUCCESS )
	    return( status );
    }

    _NFIdebug(( fname, "%s\n", "Exiting ..." ));
    return( UTI_S_SUCCESS );
}
/*  This routine displays script and node information sent back
 *  from the server side pertaining to which OFF-LINE scripts
 *  to execute.
 */
UTIRinfo_form( msg_buf )
    MEMptr	msg_buf;
{
    int		tot_data;
    int		total;
    int		mlen;
    int		i;

    long	status;

    char	**data_ptr;

    struct SCfree_data_st data;

    static      char *fname = "UTIRinfo_form"; 
   
    _NFIdebug(( fname, "%s\n", "Entering ..." ));
    _NFIdebug(( fname, "Rows <%d>\n", msg_buf->rows ));
    _NFIdebug(( fname, "Cols <%d>\n", msg_buf->columns ));

    data.num_of_rows = msg_buf->rows;
    data.num_of_cols = 3;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.select_set_expected = FALSE;
    data.max_indent = 0;

    data.col_size = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_size, 0, (data.num_of_cols * sizeof(int)));
    data.col_size[0] = 40;
    data.col_size[1] = 20;
    data.col_size[2] = 15;


    data.col_pos = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_pos, 0, (data.num_of_cols * sizeof(int)));
    total = 0;
    for( i = 0; i < data.num_of_cols; ++i )
    {
        data.col_pos[i] = total;
        total += data.col_size[i] + 2;
    }

    data.col_just = (int*) malloc( data.num_of_cols * sizeof( int ));
    memset( data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof( int )));

    data.h1_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h1_pos, 0, sizeof(int) + 1 );
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int*) malloc ( (data.num_of_cols * sizeof(int)) +1 );
    memset( data.h2_pos, 0,(data.num_of_cols *  sizeof(int)) + 1 );

    total = 0;
    for( i = 0; i < data.num_of_cols; ++i )
    {
        data.h2_pos[i] = total;
        total += data.col_size[i] + 2;
    }
    data.h2_pos[i] = -1;

    data.h3_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h3_pos, 0, sizeof(int) + 1 );
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
 
    data.h1_data = (char**)malloc( sizeof(char*) );
    memset( data.h1_data, NULL, sizeof(char*) );
    NFAput_string( &data.h1_data[0], "" );

    data.h2_data = (char**) malloc(data.num_of_cols*sizeof(char*)+1 );
    memset( data.h2_data, NULL, (data.num_of_cols*sizeof(char*))+1);
    NFAput_string( &data.h2_data[0], "Script Name" );
    NFAput_string( &data.h2_data[1], "Node Name" );

    data.h3_data = (char**)malloc( sizeof(char*) );
    memset( data.h3_data, NULL, sizeof(char*) );
    NFAput_string( &data.h3_data[0], "" );

    strcpy (data.title,
	    "From These Node(s), Use These Script(s) as 'Nfmutil' Input : " );

    data.select_set = (int*) malloc( tot_data * sizeof(int));
    memset( data.select_set, 0, tot_data * sizeof(int) );

    data.data = (char **) malloc ( tot_data * sizeof (char *));
    memset (data.data, NULL, tot_data * sizeof (char *));

    data_ptr = (char**) msg_buf->data_ptr;

    if(strcmp(data_ptr[2], "DISK_F")==0)
    	NFAput_string( &data.h2_data[2], "" );
    else
    	NFAput_string( &data.h2_data[2], "Tape Label" );

    for( i = 0; i < (msg_buf->rows*msg_buf->columns); i+=msg_buf->columns )
    {
        mlen = strlen( data_ptr[i] );
        if( mlen > 0 )
	{
   	    NFAput_string( &data.data[i],  data_ptr[i]   );
	    NFAput_string( &data.data[i+1],data_ptr[i+1] );

	    /** Filter out Floppy labels **/
	    if(strcmp(data_ptr[i+2], "DISK_F")!=0)
	    	NFAput_string( &data.data[i+2],data_ptr[i+2] );
	    else
	    	NFAput_string( &data.data[i+2],"");
	}
    }

	SCdisplay_msg( " Press <PF1> to Continue or <PF3> To Cancel " );
    status = SCprocess_free_form( &data, NFMprint_file );
    if( data.sts == FORM_CANCELED || status == NFI_W_FORM_CANCELED )
    {
        SCclear_msg();
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return( NFI_W_FORM_CANCELED );
    }

    return( UTI_S_SUCCESS );
}
