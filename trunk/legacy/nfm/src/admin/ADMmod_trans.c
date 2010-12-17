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
#include "UMS.h"
#include "NFMstruct.h"
#include "WFcommands.h"
#include "DEBUG.h"
#include "NFMdisplays.h"
#include "NFIcommands.h"
#include "NFMRlist.h"
#include "NFMtitles.h"

extern long sqlstatus;

long ADMprog_to_trans ()

{
long   status;
int    i, j, k, m, x;
int    ROW_CHOSEN = FALSE;
int    FIRST_TRANS = TRUE;
int    NO_TRANS_PROCS = FALSE;
int    MAP_EXISTS = FALSE;
char   pre_post[NFM_PREPOST+1];
char   program_num[21];
char   seq_num[21];
char   program[NFM_PROGRAMNAME+1];
char   transition[NFM_TRANSITIONNAME+1];
char   trans_num[21];
char   trans_state[NFM_STATENAME+1];
char   str[100];
char   title[80];
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr process_list = NULL;
struct SCfree_data_st prog_data;
struct SCfree_data_st trans_data;
NFMlist display_struct;
long   ADMchoose_transitions ();
extern struct NFMglobal_st NFMglobal;
static char *fname = "ADMprog_to_trans";

    _NFMdebug ((fname, "ENTER\n"));

    SCdisplay_msg ("Working..");    

    /* query for the data needed to add programs to transitions */    

/*
KT - This call does not work. Soooo, we have to get the buffers some other way!

    status = NFMquery_process_attributes (NFMuser_id, &attr_list, &data_list,
                                          &value_list);
MEMprint_buffers ("Attribute List", attr_list, _NFMdebug_st.NFMdebug_file);
MEMprint_buffers ("Date List", data_list, _NFMdebug_st.NFMdebug_file);
MEMprint_buffers ("Value List(s)", value_list, _NFMdebug_st.NFMdebug_file);

    if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "NFMquery_process_attributes : <0x%.8x>\n",
                      status));
          ERRload_struct (NFM, NFM_E_MEM, "%s%s", fname,
                          "NFMquery_process_attributes");
          MEMclose (&attr_list);
          MEMclose (&data_list);
          MEMclose (&value_list);
          return (status);
        }
*/

    status = NFMquery_table_information (NFMglobal.NFMuserid, "NFMSYSTEM",
                "nfmprocesses", &attr_list, &data_list, &value_list);

    if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "NFMquery_table_information : <0x%.8x>\n",
                      status));
          ERRload_struct (NFI, NFI_E_FAILURE, NULL, NULL);
          MEMclose (&attr_list);
          MEMclose (&data_list);
          MEMclose (&value_list);
          return (status);
        }

    MEMbuild_array (attr_list);
    MEMbuild_array (data_list);
    column_ptr = (char **) data_list->column_ptr;

/* Get a list of all transition processes for this workflow. We can use 
   this list to avoid re-adding a transition process and/or to sequence the
   processes.

   Update: The query for the process/transitions from this workflow took 
   waaaaay toooo looong. Therefore, the query is for all processes.
*/

    status = SQLquery ("SELECT n_transitionno, n_programno, n_seqno, n_prepost \
FROM nfmprocesses", &process_list, NULL);
    if (status != SQL_S_SUCCESS)
        {
        if (status == SQL_I_NO_ROWS_FOUND)
            NO_TRANS_PROCS = TRUE;
        else
            {
            _NFMdebug ((fname, "SQLquery : <0x%.8x>\n", status));
            ERRload_struct (NFI, NFM_E_SQL_QUERY, NULL);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            MEMclose (&process_list);
            return (status);
            }
        }
    MEMbuild_array (process_list);

/* Get list of programs. Let them choose one. */

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_PROGRAMS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Programs" );
      }

    NFMfill_list_struct (&display_struct, DSP_PROGRAMS, SELECT_SET_SINGLE_ROW,
              NFM_SHORT_DISPLAY, "", "", "", "", "", "","", title);

    SCdisplay_ref ("Choose Program");
    status = ADMchoose_elements (&prog_data, display_struct);
    SCclear_ref ();
    NFMfree_list_struct (&display_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug ((fname, "ADMchoose_elements : <0x%.8x>\n", status));
        if (status == NFI_W_FORM_CANCELED)
            ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
        else
            ERRload_struct( NFI, NFI_E_CANNOT_ACTIVATE_ITEM, NULL, NULL);

        return (status);
        }

    for (i=0; i<prog_data.num_of_rows; ++i)
        {
        j = i * prog_data.num_of_cols;
        if (prog_data.select_set[i] == 1)
            {
            ROW_CHOSEN = TRUE;
            strcpy (program_num, prog_data.data[j]);
            strcpy (program, prog_data.data[j+1]);
            _NFIdebug ((fname, "Program : <%s:%s>\n", program_num, program));
            }
        }

    NFMfree_list (prog_data.data, prog_data.num_of_rows, prog_data.num_of_cols);
    free (prog_data.data);

/*
   Because the long listing of transitions does not include the transition
   numbers that are needed, we had to call the short report also to get them.

   3.0 - KT - Now we are not even going to call a report. Just a query to 
   return what we need.
*/

    sprintf(msg, "Choose Transitions for Program <%s>", program);
    SCdisplay_ref (msg);
    status = ADMchoose_transitions (&trans_data);
    SCclear_ref ();

    for (k=0; k<trans_data.num_of_rows; ++k)
        {
        /* for each transition selected, find its number and MEMwrite */
        m = k * trans_data.num_of_cols;
        if (trans_data.select_set[k] == 1)
            {
            strcpy (transition, trans_data.data[m]);
            strcpy (trans_state, trans_data.data[m+2]);
            strcpy (trans_num, trans_data.data[m+3]);
            _NFIdebug ((fname, "Transition : <%s:%s:%s>\n", trans_num,
                        transition, trans_state));

            /* find out if the process is to be executed BEFORE or
               AFTER the transition AND
               find the sequence number to add 
            */
            MAP_EXISTS = FALSE;
            status = ADMget_pre_post_seq (program, program_num, transition, 
                                          trans_num, trans_state, process_list,
                                          pre_post, seq_num);
            if (status != NFI_S_SUCCESS)
                {
                if (status == NFI_E_ADD_MAP)
                    {
                    MAP_EXISTS = TRUE;
                    sprintf (msg, "Mapping Exists For <%s>:<%s>", transition,
                             program);
                    SCdisplay_msg (msg);
                    }
                else
                    {
                    _NFIdebug ((fname, "ADMget_pre_post : <0x%.8x>\n", status));
                    ERRload_struct (NFI, NFI_E_FAILURE, NULL, NULL);
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    MEMclose (&value_list);
                    MEMclose (&process_list);
                    return (NFI_E_FAILURE);
                    }
                }

            /* Because of the kludgey way that we had to get the
               process attribute buffers, the data_list has an empty 
               row. We need to "MEMwrite_data" into this row first,
               and then do "MEMwrites" for the rest of the transitions
            */

            if (!MAP_EXISTS)
                {
                if (FIRST_TRANS)
                    {
                    FIRST_TRANS = FALSE;
                    _NFIdebug ((fname, "MEMwrite_data : <%s%s%s%s>\n",
                                trans_num, "", pre_post, program_num));
                    for (x=0; x<data_list->columns; ++x)
                        {
                             if (strcmp (column_ptr[x], "n_transitionno") == 0)
                                 status = MEMwrite_data (data_list, trans_num,
                                                         1, x+1);

                        else if (strcmp (column_ptr[x], "n_seqno") == 0)
                                 status = MEMwrite_data (data_list, seq_num, 1,
                                                         x+1);

                        else if (strcmp (column_ptr[x], "n_prepost") == 0)
                                 status = MEMwrite_data (data_list, pre_post,
                                                         1, x+1);

                        else if (strcmp (column_ptr[x], "n_programno") == 0)
                                 status = MEMwrite_data (data_list, program_num,
                                                         1, x+1);
                        }
                    }

                else
                    {
                    strcpy (str, "");
                    for (x=0; x<data_list->columns; ++x)
                        {
                             if (strcmp (column_ptr[x], "n_transitionno") == 0)
                                 strcat (str, trans_num);
                        else if (strcmp (column_ptr[x], "n_seqno") == 0)
                                 strcat (str, seq_num);
                        else if (strcmp (column_ptr[x], "n_prepost") == 0)
                                 strcat (str, pre_post);
                        else if (strcmp (column_ptr[x], "n_programno") == 0)
                                 strcat (str, program_num);
                        else
                                 strcat (str, "");
                        strcat (str, "\1");
                        }

                    _NFIdebug ((fname, "MEMwrite string : <%s>\n", str));
                    status = MEMwrite (data_list, str);
                    if (status != MEM_S_SUCCESS)
                        {
                        _NFIdebug ((fname, "MEMwrite : <0x%.8x>\n", status));
                        ERRload_struct (NFI, NFI_E_MEM, NULL, NULL);
                        MEMclose (&attr_list);
                        MEMclose (&data_list);
                        MEMclose (&value_list);
                        MEMclose (&process_list);
                        return (status);
                        }

                    status = MEMbuild_array (data_list);
                    column_ptr = (char **) data_list->column_ptr;
                    }
                }
            }

        }

    NFMfree_list (trans_data.data, trans_data.num_of_rows,
                  trans_data.num_of_cols);
    free (trans_data.data);

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("Process Buffer", data_list,
                         _NFMdebug_st.NFIdebug_file);

    status = NFMload_processes (NFMglobal.NFMuserid, attr_list, data_list);
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&process_list);

    _NFIdebug ((fname, "NFMload_processes : <0x%.8x>\n", status));

    return (NFI_S_SUCCESS);
}


long ADMchoose_transitions (struct_data)
    struct SCfree_data_st *struct_data;
{
long   status;
int    i, j;
int    tot_data;
int    pos = 0;
int    max_len;
int    no_row_selected = TRUE;
int    NO_TRANS = FALSE;
char   title[80];
char   search_str[1024];
char   **data_ptr;
char   **column_ptr;
char   **format_ptr;
MEMptr data_list = NULL;
struct SCfree_data_st *data;

static char *fname = "ADMchoose_transitions";

    _NFIdebug ((fname, "ENTER\n"));

    data = struct_data;

    SCdisplay_msg ("Working..");

/*
We search for all transitions with a from state not equal to 0.
This search criteria must also have the 'nfmworkflow' table clauses to
narrow down the search.
*/

sprintf (search_str,
"SELECT nfmtransitions.n_transitionname, \
nfmcommands.n_commandname, \
nfmstates.n_statename, \
nfmtransitions.n_transitionno \
from nfmtransitions, nfmcommands, nfmstates, nfmworkflow WHERE \
(nfmcommands.n_commandno = nfmtransitions.n_commandno) AND \
(nfmstates.n_stateno = nfmtransitions.n_fromstate) AND \
(nfmworkflow.n_workflowname = '%s') AND \
(nfmworkflow.n_workflowno = nfmtransitions.n_workflowno) AND \
((nfmtransitions.n_fromstate >= 1) OR (nfmtransitions.n_tostate >= 1)) AND \
(nfmcommands.n_entity != 'D') \
ORDER BY nfmtransitions.n_transitionname", NFMworkflow);

    status = SQLquery (search_str, &data_list, NULL);
    if (status != SQL_S_SUCCESS)
        {
        if (status == SQL_I_NO_ROWS_FOUND)
            NO_TRANS = TRUE;
        else
            {
            _NFMdebug ((fname, "SQLquery : <0x%.8x>\n", status));
            ERRload_struct (NFI, NFM_E_SQL_QUERY, NULL);
            MEMclose (&data_list);
            return (status);
            }
        }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
        {
          ERRload_struct (NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild_array");
          return (status);
        }

    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;
    format_ptr = (char **) data_list->format_ptr;

    data->num_of_rows = data_list->rows;
    data->num_of_cols = data_list->columns;
    tot_data = data->num_of_cols * data->num_of_rows;

    data->freeze_rows_count = 0;
    if (data->num_of_cols > 1)
        data->freeze_cols_count = 1;
    else
        data->freeze_cols_count = 0;

    data->max_indent = 0;
    data->select_set_expected = SELECT_SET_MULTI_ROW;

    data->col_size = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_size, 0, (data->num_of_cols * sizeof (int)));
    for (i=0, j=0; i<data_list->columns; ++i)
      {
        max_len = 0;
        status = NFMcol_width (column_ptr[i], format_ptr[i], &max_len);
        if (max_len > 25)
            max_len = 25;
        data->col_size[i] = max_len;
        }
    pos = 0;    
    data->col_pos = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_pos, 0 , (data->num_of_cols * sizeof (int)));
    for (i=0, j=0; i<data->num_of_cols; ++i)
        {
          data->col_pos[i] = pos;
          pos += data->col_size[i] + 2;
        }

    data->col_just = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_just, LEFT_JUSTIFIED, (data->num_of_cols * sizeof (int)));
    
    data->h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h1_pos, 0, sizeof (int) + 1);
    data->h1_pos[0] = 0;
    data->h1_pos[1] = -1;

    data->h2_pos = (int *) malloc ((data->num_of_cols * sizeof (int)) + 1);
    memset (data->h2_pos, 0, (data->num_of_cols * sizeof (int)) + 1);
    for (i=0, j=0; i<data->num_of_cols; ++i)
        {
        data->h2_pos[i] = data->col_pos[i];
        }
    data->h2_pos[i] = -1;
    
    data->h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h3_pos, 0, sizeof (int) + 1);
    data->h3_pos[0] = 0;
    data->h3_pos[1] = -1;
    
    data->h1_data = (char **) malloc (sizeof (char *));
    memset (data->h1_data, NULL, (sizeof (char *)));
    NFMput_string (&data->h1_data[0], "");
    
    data->h2_data = (char **) malloc (data->num_of_cols * (sizeof (char *)));
    memset (data->h2_data, NULL, data->num_of_cols * (sizeof (char *)));

    /* hard code columns in SELECT order */
    NFMput_string (&data->h2_data[0], "Transition Name");
    NFMput_string (&data->h2_data[1], "Command Name");
    NFMput_string (&data->h2_data[2], "From State");
    NFMput_string (&data->h2_data[3], "Trans Number");
    
    data->h3_data = (char **) malloc (sizeof (char *));
    memset (data->h3_data, NULL, (sizeof (char *)));
    NFMput_string (&data->h3_data[0], "");
    
    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_TRANSITIONS, "%s", NFMworkflow)) != UMS_S_SUCCESS)
        {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Transitions" );
        }

    strcpy (data->title, title);

    data->select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data->select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data->data = (char * *) malloc (tot_data * sizeof (char *));
    memset (data->data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        {
        NFMput_string (&data->data[i], data_ptr[i]);
        }

    /* process free form */
    status = SCprocess_free_form (data, NFMprint_file);

    if (data->sts == FORM_CANCELED)
        {
        NFMfree_list (data->data, data->num_of_rows, data->num_of_cols);
        free (data->data);
        MEMclose (&data_list);
        ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
        return (NFI_W_FORM_CANCELED);
        }

    for (i=0; i<data->num_of_rows; ++i)
        {
        if (data->select_set[i] == 1)
            {
            no_row_selected = FALSE;
            break;
            }
        }

    MEMclose (&data_list);

    if (no_row_selected)
        return (NFI_E_CREATE_SELECT_LIST );
    else
        return (NFI_S_SUCCESS);
}

