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

long review_state ()

{
long   status;
int    tot_data;
int    pos;
struct SCcolumn_data_st data;
char   state_name[41];
char   state_number[20];

static char *fname = "NFIreview_state";

    SCdisplay_msg ("Working..");    

    status = NFMRreview_state (NFMuser_id, NFMcatalog, NFMitem, NFMrev,
                               state_number, state_name);

    if (status != NFM_S_SUCCESS)
        return (status);

    pos = 0;
    data.num_of_rows = 1;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 10;
    data.col_width[1] = 20;
    data.new_rows_expected = FALSE;
    if (strcmp (NFMrev, "") == 0)
        sprintf (data.title, "Current State of %s", NFMitem);
    else
        sprintf (data.title, "Current State of %s.%s", NFMitem, NFMrev);

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], state_number);
    NFAput_string (&data.data[1], state_name);

    status = SCprocess_column_form (&data, NFMprint_file);

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


