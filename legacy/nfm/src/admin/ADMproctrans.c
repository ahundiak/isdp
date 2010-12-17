#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "NFMRextern.h"
#include "DEBUG.h"
#include "SCstruct.h"

extern long sqlstatus;



long ADMdisplay_transition_processes ()

{
long   status;
int    i, j;
int    tot_data;
int    pos;
int    max_len;
char   sql_str[1024];
char   **column_ptr;
char   **format_ptr;
char   **data_ptr;
MEMptr info = NULL;
struct SCfree_data_st data;
static char *fname = "ADMdisplay_transition_processes";

    _NFMdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");

    sprintf (sql_str, "SELECT \
a.n_transitionname, \
b.n_statename, \
d.n_seqno, \
c.n_programname, \
d.n_prepost \
FROM \
nfmtransitions a, \
nfmstates b, \
nfmprograms c, \
nfmprocesses d, \
nfmworkflow e \
WHERE \
d.n_transitionno = a.n_transitionno AND \
a.n_fromstate = b.n_stateno AND \
d.n_programno = c.n_programno AND \
a.n_workflowno = e.n_workflowno AND \
e.n_workflowno IN (select n_workflowno from nfmworkflow WHERE \
n_workflowname = '%s') \
order by a.n_transitionname, b.n_statename, d.n_seqno, c.n_programname", 
NFMworkflow);

    status = SQLquery (sql_str, &info, NULL);
    if (status != SQL_S_SUCCESS)
        {
        if (status == SQL_I_NO_ROWS_FOUND)
            {
            sprintf (msg, "No processes defined for the \"%s\" workflow.",
                     NFMworkflow);
            /* The "cat mappings" message is close...*/
            ERRload_struct (NFI, NFI_I_NO_CAT_MAPPINGS, "%s", NFMworkflow);
            return (NFI_S_SUCCESS);
            }
        else
            {
            _NFMdebug ((fname, "SQLquery : <0x%.8x>\n", status));
            ERRload_struct (NFI, NFM_E_SQL_QUERY, NULL);
            MEMclose (&info);
            return (status);
            }
        }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI,NFI_E_MEMORY,"%s%s","NFMdisplay_data",
                        "MEMbuild_array");
        return (status);
        }

    data_ptr = (char **) info->data_ptr;
    column_ptr = (char **) info->column_ptr;
    format_ptr = (char **) info->format_ptr;

    data.num_of_rows = info->rows;
    data.num_of_cols = info->columns;
    tot_data = data.num_of_cols * data.num_of_rows;

    data.freeze_rows_count = 0;
    if (data.num_of_cols > 1)
        data.freeze_cols_count = 1;
    else
        data.freeze_cols_count = 0;

    data.max_indent = 0;
    data.select_set_expected = FALSE;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0, (data.num_of_cols * sizeof (int)));
    for (i=0, j=0; i<info->columns; ++i)
        {
        max_len = 0;
        status = NFMcol_width (column_ptr[i], format_ptr[i], &max_len);
        if (max_len > 25)
            max_len = 25;
            data.col_size[i] = max_len;
        }

    pos = 0;
    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));
    for (i=0; i<data.num_of_cols; ++i)
        {
        data.col_pos[i] = pos;
        pos += data.col_size[i] + 2;
        }

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    for (i=0, j=0; i<data.num_of_cols; ++i)
        {
        data.h2_pos[i] = data.col_pos[i];
        }
    data.h2_pos[i] = -1;
    
    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFMput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (data.num_of_cols * (sizeof (char *)));
    memset (data.h2_data, NULL, data.num_of_cols * (sizeof (char *)));
    for (i=0; i<data.num_of_cols; ++i)
        NFMput_string (&data.h2_data[i], column_ptr[i]);
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFMput_string (&data.h3_data[0], "");
    
    sprintf (data.title, "List of Transition Processes for \"%s\"", NFMworkflow);

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        {
        NFMput_string (&data.data[i], data_ptr[i]);
        }

    /* process free form */
    status = SCprocess_free_form (&data, NFMprint_file);

    _NFMdebug ((fname, "Exit: NFI_S_SUCCESS\n"));
    return (NFI_S_SUCCESS);
}
