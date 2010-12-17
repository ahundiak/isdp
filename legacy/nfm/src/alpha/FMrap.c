#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "SCrap.h"
#include "NFMRextern.h"

long begin_record()

{
long   status;
int    tot_data;
char   *sts;

struct SCcolumn_data_st data;
static char *fname = "begin_record";

    _NFIdebug ((fname, "Enter.\n"));

    data.num_of_rows = 1;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 10;
    data.col_width[1] = 60;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Record File Name");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[1] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "File Name" );
    NFAput_string (&data.data[1], "/usr/tmp/nfm.record");

    status = SCprocess_column_form (&data, NFMprint_file);
    SCclear_msg ();

    _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

    if (data.sts == FORM_CANCELED)
        {
        _NFIdebug ((fname, "Cancel from form. Return.\n"));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    SCdisplay_msg ("Working..");

    _NFIdebug ((fname, "Record File <%s>\n", data.data[1]));

    sts = start_record( data.data[1] );
    if( sts != NULL )
    {
	sprintf( msg, "NFM:  Error Recording to File '%s'.", data.data[1] );
	_NFIdebug ((fname, "%s\n", msg));
	SCdisplay_msg( msg );
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	return( NFI_E_FAILURE );
    }

    init_rap( TRUE );

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if( status != NFM_S_SUCCESS )
	return( status );

    return (NFI_S_SUCCESS);
}


long end_record ()

{
char *sts;
static char *fname = "end_record";

    _NFIdebug ((fname, "Enter.\n"));

    sts = stop_record();
    init_rap( FALSE );

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
    SCdisplay_msg ("Successful Completion");
 
    return (NFI_S_SUCCESS);
}

long begin_playback ()

{
long   status;
int    tot_data;
int    mode;
int    FORM_FILLED;
char   *sts;

struct SCcolumn_data_st data;
static char *fname = "begin_playback";

    _NFIdebug ((fname, "Enter.\n"));

    data.num_of_rows = 2;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 50;
    data.col_width[1] = 20;

    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Playback Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[2] = 1;
    data.selectable[3] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Record Filename" );
    NFAput_string (&data.data[1], "Mode( s, i, r )");
    NFAput_string (&data.data[2], "/usr/tmp/nfm.record" );
    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
	    if( (data.data[2] == NULL) || (data.data[3] == NULL) )
		{
	        SCdisplay_msg( "NFM:  Must enter all information." );
 	        FORM_FILLED = FALSE;
		}
	    else
		{
		if( (strcmp( data.data[3], "i" ) == 0 ) ||
		    (strcmp( data.data[3], "I" ) == 0 ))
		    mode = IMMEDIATE;
		else if( (strcmp( data.data[3], "r" ) == 0) ||
			 (strcmp( data.data[3], "R" ) == 0))
		    mode = REAL_TIME;
		else if( (strcmp( data.data[3], "s" ) == 0) ||
			 (strcmp( data.data[3], "S" ) == 0))
		    mode = SINGLE_STEP;
		else
		    {
			SCdisplay_msg( "NFM:  Illegal Mode Value." );
			FORM_FILLED = FALSE;
		    }
		}
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFIdebug ((fname, "Cancel from form. Return.\n"));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    stop_playback();

    SCdisplay_msg ("Working..");
  
    sts = start_playback( data.data[2], mode );
    if( sts != NULL )
    {
	sprintf( msg, "NFM:  Error Starting Playback from File '%s'.", data.data[2] );
	_NFIdebug ((fname, "%s\n", msg));
	SCdisplay_msg( msg );
 	sleep(5);
	SCdisplay_msg( sts );
	sleep(5);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	return( NFI_E_FAILURE );
    }
   
    init_rap( TRUE );

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if( status != NFM_S_SUCCESS )
	return( status );

    return (NFI_S_SUCCESS);
}
