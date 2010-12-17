#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"
#include "ERR.h"
#include "DEBUG.h"

define_active_data ()
{
long   status;
int    i;
int    tot_data;
int    pos;
struct SCcolumn_data_st data;
int    FORM_FILLED;
int    final_msg = 0;
int    set_flag  = 0;
char   owner[NFM_USERNAME+1];
static char *fname = "NFAdefine_active_data";

    pos = 0;
    data.num_of_rows = 14;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 20;
    data.col_width[1] = 50;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter NFM Data");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "List Driven" );
    if( NFMlist_driven == 1 )
        NFAput_string (&data.data[1], "TRUE" );
    else
	NFAput_string (&data.data[1], "FALSE" );
    NFAput_string (&data.data[2], "Project Name");
    NFAput_string (&data.data[3], NFMproject );
    NFAput_string (&data.data[4], "Catalog Name");
    NFAput_string (&data.data[5], NFMcatalog );
    NFAput_string (&data.data[6], "Item Name");
    NFAput_string (&data.data[7], NFMitem );
    NFAput_string (&data.data[8], "Item Revision");
    NFAput_string (&data.data[9], NFMrev );
    NFAput_string (&data.data[10], "Set");
    NFAput_string (&data.data[11], NFMset );
    NFAput_string (&data.data[12], "Set Revision" );
    NFAput_string (&data.data[13], NFMset_rev );
    NFAput_string (&data.data[14], "Storage Area");
    NFAput_string (&data.data[15], NFMstorage );
    NFAput_string (&data.data[16], "Search Name");
    NFAput_string (&data.data[17], NFMsearch_name );
    NFAput_string (&data.data[18], "Sort Name");
    NFAput_string (&data.data[19], NFMsort_name );
    NFAput_string (&data.data[20], "Working Area Name");
    NFAput_string (&data.data[21], NFMworking );
    NFAput_string (&data.data[22], "Node Name");
    NFAput_string (&data.data[23], NFMnode );
    NFAput_string (&data.data[24], "Workflow" );
    NFAput_string (&data.data[25], NFMworkflow );
    NFAput_string (&data.data[26], "ACL" );
    NFAput_string (&data.data[27], NFMacl );
/*
    NFAput_string (&data.data[28], "User" );
    NFAput_string (&data.data[29], NFMuser );*/

    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form: <0x%.8x>\n", data.sts));
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

    if( (data.data[1] != NULL) && ( strcmp( data.data[1], "" ) ) )
    {
        NFMlist_driven = 0;
	if( (strcmp( data.data[1], "TRUE" ) == 0 ) ||
    	    (strcmp( data.data[1], "true" ) == 0 ) ||
	    (strcmp( data.data[1], "t" )    == 0 ) ||
	    (strcmp( data.data[1], "T" )    == 0 ))
	    NFMlist_driven = 1;
    }

    if( (data.data[3] != NULL) && ( strcmp( data.data[3], "" ) ) )
    {
	if( strcmp( data.data[3], " " ) == 0 )
	    strcpy( NFMproject, "" );
	else if( strcmp( data.data[3], NFMproject ) )
	{
	    status = NFMRvalidate_project( data.data[3] );
  	    if( status != NFM_S_SUCCESS )
	    {
	        _NFIdebug((fname, "NFMRvalidate_project: <0x%.8x>\n", status));
		final_msg = 1;
 	    }
	    else
                strcpy (NFMproject, data.data[3]);
	}
    }
    else
	strcpy( NFMproject, "" );

    if( (data.data[5] != NULL) && ( strcmp( data.data[5], "" ) ) )
    {
        if( strcmp( data.data[5], " " ) == 0 )
            strcpy( NFMcatalog, "" );
	else if( strcmp( data.data[5], NFMcatalog ) )
	{
            lowcase (data.data[5]);
	    status = NFMRvalidate_catalog( data.data[5] );
	    if( status != NFM_S_SUCCESS )
    	    {
	        _NFIdebug((fname, "NFMRvalidate_catalog: <0x%.8x>\n", status));
	        final_msg = 1;
    	    }
	    else
                strcpy (NFMcatalog, data.data[5]);
                 strcpy(NFMitem, "");
                 strcpy (NFMrev, "");
	}
    }
    else
	strcpy( NFMcatalog, "" );


    if( (data.data[7] != NULL) && ( strcmp( data.data[7], "" ) ) )
    {
        if( strcmp( data.data[7], " " ) == 0 )
            strcpy( NFMitem, "" );

	else if( strcmp( data.data[7], NFMitem ) )
	{
            status = NFMRvalidate_item( NFMcatalog, data.data[7]);
            if( status != NFM_S_SUCCESS )
            {
                _NFIdebug ((fname, "NFMRvalidate_item: <0x%.8x>\n", status));
 	        final_msg = 1;
            }
            else
                strcpy (NFMitem, data.data[7]);
	}
    }
    else
	strcpy( NFMitem, "" );

    if( (data.data[9] != NULL) && ( strcmp( data.data[9], "" ) ) )
    {
        if( strcmp( data.data[9], " " ) == 0 )
            strcpy( NFMrev, "" );

	else if( strcmp( data.data[9], NFMrev ) )
	{
		
            status = NFMRvalidate_revision( NFMcatalog, data.data[7],
					    data.data[9], &set_flag);
            if( status != NFM_S_SUCCESS )
            {
                _NFIdebug ((fname, "NFMRvalidate_rev: <0x%.8x>\n", status));
	        final_msg = 1;
            }

            else
                strcpy (NFMrev, data.data[9]);
	}
    }
    else
	strcpy( NFMrev, "" );

    if( (data.data[11] != NULL) && ( strcmp( data.data[11], "" ) ) )
    {
        if( strcmp( data.data[11], " " ) == 0 )
            strcpy( NFMset, "" );

	else if( strcmp( data.data[11], NFMset ) )
	{
            status = NFMRvalidate_set_item( NFMcatalog, data.data[11]);
            if( status != NFM_S_SUCCESS )
            {
                _NFIdebug((fname,"NFMRvalidate_set_item: <0x%.8x>\n", status));
 	        final_msg = 1;
            }
            else
                strcpy (NFMset, data.data[11]);
	}
    }
    else
	strcpy( NFMset, "" );

    if( (data.data[13] != NULL) && ( strcmp( data.data[13], "" ) ) )
    {
        if( strcmp( data.data[13], " " ) == 0 )
            strcpy( NFMset_rev, "" );

	else if( strcmp( data.data[13], NFMset_rev ) )
	{
            status = NFMRvalidate_set_rev( NFMcatalog, data.data[11],
					    data.data[13]);
            if( status != NFM_S_SUCCESS )
            {
                _NFIdebug ((fname,"NFMRvalidate_set_rev: <0x%.8x>\n", status));
	        final_msg = 1;
            }
            else
                strcpy (NFMset_rev, data.data[13]);
	}
    }
    else
	strcpy( NFMset_rev, "" );

    if( (data.data[15] != NULL) && ( strcmp( data.data[15], "" ) ) )
    {
        if( strcmp( data.data[15], " " ) == 0 )
            strcpy( NFMstorage, "" );

	else if( strcmp( data.data[15], NFMstorage ) )
  	{
	    status = NFMRvalidate_st_area( data.data[15] );
	    if( status != NFM_S_SUCCESS )
	    {
	       _NFIdebug ((fname, "NFMRvalidate_st_area: <0x%.8x>\n", status));
	        final_msg = 1;
	    }
  	    else
                strcpy (NFMstorage, data.data[15]);
	}
    }
    else 
	strcpy( NFMstorage, "" );

    if( (data.data[17] != NULL) && ( strcmp( data.data[17], "" ) ) )
    {
        if( strcmp( data.data[17], " " ) == 0 )
            strcpy( NFMsearch_name, "" );
	
	else if( strcmp( data.data[17], NFMsearch_name ) )
	{
	    status = NFMRvalidate_search( data.data[17], owner );
	    if( status != NFM_S_SUCCESS )
	    {
	        _NFIdebug ((fname, "NFMRvalidate_search: <0x%.8x>\n", status));
	        final_msg = 1;
	    }
	    else
                strcpy (NFMsearch_name, data.data[17]);
	}
    }
    else	
	strcpy( NFMsearch_name, "" );

    if( (data.data[19] != NULL) && ( strcmp( data.data[19], "" ) ) )
    {
        if( strcmp( data.data[19], " " ) == 0 )
            strcpy( NFMsort_name, "" );

	else if( strcmp( data.data[19], NFMsort_name ) )
	{
	    status = NFMRvalidate_sort( data.data[19], owner );
	    if( status != NFM_S_SUCCESS )
	    {
	        _NFIdebug ((fname, "NFMRvalidate_sort: <0x%.8x>\n", status));
  	        final_msg = 1;
	    }
	    else
                strcpy (NFMsort_name, data.data[19]);
	}
    }
    else
        strcpy( NFMsort_name, "" );

    if( (data.data[21] != NULL) && ( strcmp( data.data[21], "" ) ) )
    {
        if( strcmp( data.data[21], " " ) == 0 )
            strcpy( NFMworking, "" );

	else if( strcmp( data.data[21], NFMworking ) )
	{
	    status = NFMRvalidate_working_area( data.data[21], owner );
	    if( status != NFM_S_SUCCESS )
  	    {
	        _NFIdebug ((fname, "NFMRvalidate_wa: <0x%.8x>\n", status));
	        final_msg = 1;
	    }
 	    else
                strcpy (NFMworking, data.data[21]);
	}
    }
    else
	strcpy( NFMworking, "" );

    if( (data.data[23] != NULL) && ( strcmp( data.data[23], "" ) ) )
    {
        if( strcmp( data.data[23], " " ) == 0 )
            strcpy( NFMnode, "" );

	else if( strcmp( data.data[23], NFMnode ) )
	{
	    status = NFMRvalidate_node( data.data[23] );
	    if( status != NFM_S_SUCCESS )
	    {
	        _NFIdebug ((fname, "NFMRvalidate_node: <0x%.8x>\n", status));
	        final_msg = 1;
	    }
	    else
                strcpy (NFMnode, data.data[23]);
	}
    }
    else 
	strcpy( NFMnode, "" );

    if( (data.data[25] != NULL) && ( strcmp( data.data[25], "" ) ) )
    {
        if( strcmp( data.data[25], " " ) == 0 )
            strcpy( NFMworkflow, "" );

	else if( strcmp( data.data[25], NFMworkflow ) )
	{
	    status = NFMRvalidate_workflow( data.data[25] );
	    if( status != NFM_S_SUCCESS )
	    {
	        _NFIdebug((fname,"NFMRvalidate_workflow: <0x%.8x>\n", status));
	        final_msg = 1;
	    }
	    else
                strcpy (NFMworkflow, data.data[25]);
	}
    }
    else 
	strcpy( NFMworkflow, "" );

    if( (data.data[27] != NULL) && ( strcmp( data.data[27], "" ) ) )
    {
        if( strcmp( data.data[27], " " ) == 0 )
            strcpy( NFMacl, "" );

	else if( strcmp( data.data[27], NFMacl ) )
	{
	    status = NFMRvalidate_acl( NFMworkflow, data.data[27] );
	    if( status != NFM_S_SUCCESS )
	    {
	        _NFIdebug ((fname, "NFMRvalidate_acl: <0x%.8x>\n", status));
	        final_msg = 1;
	    }
	    else
                strcpy (NFMacl, data.data[27]);
	}
    }
    else 
	strcpy( NFMacl, "" );

/*
    if( (data.data[29] != NULL) && ( strcmp( data.data[29], "" ) ) )
    {
        if( strcmp( data.data[29], " " ) == 0 )
            strcpy( NFMuser, "" );

	else if( strcmp( data.data[29], NFMuser ) )
	{
	    status = NFMRvalidate_user( data.data[29] );
	    if( status != NFM_S_SUCCESS )
	    {
	        _NFIdebug ((fname, "NFMRvalidate_user: <0x%.8x>\n", status));
	        final_msg = 1;
	    }
	    else
                strcpy (NFMuser, data.data[29]);
	}
    }
    else 
	strcpy( NFMuser, "" );*/

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if( final_msg == 0 )
	ERRload_struct( NFI, NFI_S_SUCCESS, NULL, NULL );

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



