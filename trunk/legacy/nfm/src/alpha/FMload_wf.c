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
#include "NDXstruct.h"
#include "ERR.h"

extern long sqlstatus;

long load_workflow ()

{
long   status;
int    tot_data;
int    FORM_FILLED;
struct SCcolumn_data_st data;
char   appl_name[5];
char   wf_file_name[50];
static char *fname = "load_workflow";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    data.num_of_rows = 2;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 18;
    data.col_width[1] = 50;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "%s",
             "Enter Workflow File/Path Name (Must Reside on NFMserver Node)");
/* TVK - 11/03 removed \ from above as seen in below line - warning avoided */

/*
             "Enter Workflow File/Path Name \(Must Reside on NFMserver Node\)");
*/


    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[1] = 1;
    data.selectable[3] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Application Name");
    NFAput_string (&data.data[1], "NFM");
    NFAput_string (&data.data[2], "Workflow File/Path");

    /* process column form until an workflow Name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
	    status = NFAvalidate_string ("char(50)", data.data[3]);
            if (strcmp (data.data[3], "") == 0)
                {
                FORM_FILLED = FALSE;
                SCdisplay_msg ("NFM:  Must Enter Workflow File Name.");
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

    strcpy (appl_name, data.data[1]);
    strcpy (wf_file_name, data.data[3]);

    _NFIdebug ((fname, "Application Name : <%s>\n", appl_name));
    _NFIdebug ((fname, "Workflow File Name : <%s>\n", wf_file_name));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");    

    status = NFMRload_workflow (NFMuser_id, appl_name, wf_file_name);

    _NFIdebug ((fname, "NFMload_workflow -> <0x%.8x>\n", status));

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


