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

long sqlstmt()

{
    long   status;
    int    i;
    int    tot_data;
    int    pos;
    int    FORM_FILLED;

    struct SCcolumn_data_st data;

    static char *fname = "NFInfm_sqlstmt";

    pos = 0;
    data.num_of_rows = 1;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 15;
    data.col_width[1] = 200;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter SQL Statement");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "SQL Statement");

    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n", 
		data.sts));

        if (data.sts != FORM_CANCELED)
            status = NFAvalidate_string ("char(200)", data.data[1]);
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
    }

    status = NFMRsqlstmt ( data.data[1] );

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if( status != NFM_S_SUCCESS )
    {
	ERRload_struct( NFI, NFI_E_SQLSTMT, NULL, NULL );
	return( status );
    }

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg ));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}
