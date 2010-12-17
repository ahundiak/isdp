#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "ERR.h"
#include "DEBUG.h"
#include "WFcommands.h"

long add_members ()

{
long   status;
long   catalog_no = -1;
long   item_no    = -1;
long   cit_no     = -1;
int    i;
int    x;
int    tot_data;
int    pos;
int    FORM_FILLED;
char   fmt[NFM_SYNONYM+1];
char   tmp_set[NFM_ITEMNAME+1];
char   tmp_set_rev[NFM_ITEMREV+1];
struct SCcolumn_data_st data;
struct NFMmember_info *members_info;

static char *fname = "NFAadd_set_members";

    SCdisplay_msg ("Working..");    

    pos = 4;
    data.num_of_rows = 2;
    data.num_of_cols = 4;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 15;
    data.col_width[1] = 15;
    data.col_width[2] = 16;
    data.col_width[3] = 15;

    data.new_rows_expected = TRUE;

    strcpy (data.title, "Enter Member Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[pos] = 1;
    data.selectable[pos+1] = 1;
    data.selectable[pos+2] = 1;
    data.selectable[pos+3] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Member Catalog" );
    NFAput_string (&data.data[1], "Member Name" );
    NFAput_string (&data.data[2], "Member Revision" );
    NFAput_string (&data.data[3], "Type ( P or S )");

    /* process column form until file_name has been entered */
    do
    {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n", 
		    data.sts));

        if (data.sts != FORM_CANCELED)
        {
            for (i=pos;
                 i<(data.num_of_cols*data.num_of_rows);
                 i+=data.num_of_cols)
            {
		/* Validate Catalog Name */
		sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
                status = NFAvalidate_string (fmt, data.data[i]);
		if( status != NFI_S_SUCCESS )
		{
		    FORM_FILLED = FALSE;
		    SCdisplay_msg( "NFM:  Catalog Name Is Too Long." );
		}
		/* if( strlen( data.data[i]) == 0 ) */
                if (( data.data[i] == NULL ) || ((data.data[i] != NULL) && (strlen( data.data[i]) == 0 )))
		{
		    FORM_FILLED = FALSE; 
		    SCdisplay_msg ("NFM:  Must Enter Catalog Name.");
		}
		/* Validate Set Name */
		sprintf( fmt, "char(%d)", NFM_ITEMNAME );
                status = NFAvalidate_string (fmt, data.data[i+1]);
		if( status != NFI_S_SUCCESS )
		{
		    FORM_FILLED = FALSE;
		    SCdisplay_msg( "NFM:  Member Name Is Too Long." );
		}
	       /*	if( strlen( data.data[i+1]) == 0 ) */
               if (( data.data[i+1] == NULL ) || ((data.data[i+1] != NULL)&& (strlen( data.data[i+1]) == 0 )))
                 
		{
		    FORM_FILLED = FALSE; 
		    SCdisplay_msg ("NFM:  Must Enter Member Name.");
		}
		/* Validate Set Revision */
		sprintf( fmt, "char(%d)", NFM_ITEMREV );
                status = NFAvalidate_string (fmt, data.data[i+2]);
		if( status != NFI_S_SUCCESS )
		{
		    FORM_FILLED = FALSE;
		    SCdisplay_msg( "NFM:  Revision Is Too Long." );
		}
                if (( data.data[i+2] == NULL ) || ((data.data[i+2] != NULL)&& (strlen( data.data[i+2]) == 0 )))

                {
                    FORM_FILLED = FALSE;
                    SCdisplay_msg ("NFM:  Must Enter Rivision ");
                }  
		/* Validate Type */	
		status = NFAvalidate_P_or_S (data.data[i+3]);
                if( status != NFI_S_SUCCESS )
                {
                    FORM_FILLED = FALSE;
                    SCdisplay_msg( "NFM:  Enter P(rimary) or S(econdary) for type." );
                }
	    }
        }
    }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    SCdisplay_msg( "Working .." );

    members_info = (struct NFMmember_info *)calloc((data.num_of_rows),
                (sizeof( struct NFMmember_info )));

    for( i=0,x=pos; i<(data.num_of_rows-1); ++i,x+=data.num_of_cols )
    {
        (members_info+i)->operation = NFM_ADD_MEMBER;
        (members_info+i)->citno     = cit_no;
        strncpy( (members_info+i)->catalog_name, data.data[x],NFM_CATALOGNAME);
        (members_info+i)->catalog_no = catalog_no;
        strncpy( (members_info+i)->item_name, data.data[x+1], NFM_ITEMNAME );
        strncpy( (members_info+i)->item_rev, data.data[x+2], NFM_ITEMREV );
	(members_info+i)->item_no   = item_no;
        strncpy( (members_info+i)->type, data.data[x+3], NFM_TYPE );
    }

/*  If there is not an active set, then we will be adding members
    to the active item and then making that a set.
 */
    strcpy( tmp_set, NFMitem );
    strcpy( tmp_set_rev, NFMrev );
    if( strcmp( NFMset, "" ) != 0 )
    {
	strcpy( tmp_set, NFMset );
	strcpy( tmp_set_rev, NFMset_rev );
    }
	
    status = NFMRdefine_set_information( NFMcatalog, catalog_no, tmp_set,
		tmp_set_rev, NFM_FILE_STATUS_CHECK, (data.num_of_rows-1), 
		members_info);

    _NFIdebug(( fname, "Return from NFMRdefine_set_information -> 0x%.8x\n", 
		    status));

/**
   Display multiple status'
*/

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (status != NFM_S_SUCCESS)
        return (status);

    strcpy( NFMset, tmp_set );
    strcpy( NFMset_rev, tmp_set_rev );
    strcpy( NFMset_cat, NFMcatalog );

    NFMset_ind = 1;

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg ));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

