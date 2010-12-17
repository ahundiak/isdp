#include "machine.h"
/*************************************************************************
 *                                                                       *
 *     Module:    NFMfunctions.c                                         *
 *     Author:    Karen Tice                                             *
 *                                                                       *
 *************************************************************************/

#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "NFMRextern.h"
#include "ERR.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "SCextern.h"
#include "NDXstruct.h"
#include "DEBUG.h"
#include "NFIerrordef.h"
#include "NFIcommands.h"
#include "NFMRlist.h"
#include "UMS.h"
#include "NFMtitles.h"
#define NFM_SERVER_NUM 11
#define NOT !

    long sqlstatus;

NFMget_network_types (node_name, tcp, xns, dec)
  char *node_name;
  char *tcp;
  char *xns;
  char *dec;
  
{
int    status = NFI_S_SUCCESS;
int    i;
int    tot_data;
int    FORM_FILLED = FALSE;
struct SCfree_data_st data;
static char *fname = "NFMget_network_types";

    _NFIdebug ((fname, "ENTER\n"));

    data.num_of_rows = 3;
    data.num_of_cols = 1;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_MULTI_ROW;
    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_size[0] = 8;

    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));
    
    data.col_pos[0] = 0;

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;
    
    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFMput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (tot_data * (sizeof (char *)));
    memset (data.h2_data, NULL, tot_data * (sizeof (char *)));
    NFMput_string (&data.h2_data[0], "Network:");
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFMput_string (&data.h3_data[0], "");
    
    sprintf (data.title, "Choose Network Protocol/s for <%s>", node_name);

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFMput_string (&data.data[0], "TCP/IP");
    NFMput_string (&data.data[1], "XNS");
    NFMput_string (&data.data[2], "DECNET");

    strcpy (tcp, "N");
    strcpy (xns, "N");
    strcpy (dec, "N");
        
    do
        {
        FORM_FILLED = FALSE;
 /* The missing second parameter was added by MVR 19/11/93 */
        status = SCprocess_free_form (&data,  NFMprint_file);
        SCclear_msg ();

        if (data.sts == FORM_ACCEPTED)
            {
            for (i=0; i<data.num_of_rows; ++i)
                {
                if (data.select_set[i] == 1)
                    {
                    FORM_FILLED = TRUE;

                         if (strcmp (data.data[i*data.num_of_cols],
                             "TCP/IP") == 0)
                             strcpy (tcp, "Y");
                    else if (strcmp (data.data[i*data.num_of_cols],
                             "XNS") == 0)
                             strcpy (xns, "Y");
                    else if (strcmp (data.data[i*data.num_of_cols],
                             "DECNET") == 0)
                             strcpy (dec, "Y");
                    }
                }
            }

        else if (data.sts == FORM_SELECTED)
                {
                FORM_FILLED = TRUE;
                strcpy (tcp, "Y");
                strcpy (xns, "Y");
                strcpy (dec, "Y");
                }

        if (FORM_FILLED == FALSE)
            SCdisplay_msg ("NFM:  Must Choose Network Protocol/s.");
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        return (NFM_E_FAILURE);
        }

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    _NFMdebug ((fname, "TCP/IP : <%s>; XNS : <%s>; DECNET : <%s>\n",
               tcp, xns, dec));

return (NFI_S_SUCCESS);
}


NFMget_dtype_len (data_ptr1, data_ptr2, len)
    char  *data_ptr1;
    char  *data_ptr2;
    int   *len;
    
{
int  temp_len1;
int  temp_len2;
char str[5];

    *len = 0;
    temp_len1 = 0;
    temp_len2 = 0;
    
    if (strncmp (data_ptr1, "char", 4) == 0)
        {
        strncpy (str, data_ptr1 + 5, (strlen (data_ptr1) - 6));
        str[strlen(data_ptr1) - 6] = '\0';
        temp_len1 = atoi (str);
        }
    else
        {
        if ((strncmp (data_ptr1, "int", 3) == 0) ||
            (strncmp (data_ptr1, "smallint", 8) == 0))
            {
            temp_len1 = 12;
            }
        else
            {
            if ((strncmp (data_ptr1, "float", 5) == 0) ||
                (strncmp (data_ptr1, "smallfloat", 10) == 0) ||
                (strncmp (data_ptr1, "decimal", 7) == 0) ||
                (strncmp (data_ptr1, "money", 5) == 0))
                {
                temp_len1 = 25;
                }
            else
                {
                if ((strncmp (data_ptr1, "ser", 3) == 0) ||
                    (strncmp (data_ptr1, "date", 4) == 0))
                    {
                    temp_len1 = 10;
                    }
                }
            }
        }
        
    temp_len2 = strlen (data_ptr2);
    
    if (temp_len1 >= temp_len2)
        {
        *len = temp_len2;
        }
    else
        {
        *len = temp_len1;
        }
        
    return (NFI_S_SUCCESS);
}


long NFMfill_index (attr_list, index)

    MEMptr attr_list;
    NDXptr *index;

{
int  i;
char **column_ptr;

    column_ptr = (char **) attr_list->column_ptr;

    for (i=0; i<attr_list->columns; ++i)
        {
             if (strcmp (column_ptr[i], "n_name") == 0)
                 index->name = i;
        else if (strcmp (column_ptr[i], "n_datatype") == 0)
                 index->dt = i;
        else if (strcmp (column_ptr[i], "n_synonym") == 0)
                 index->syn = i;
        else if (strcmp (column_ptr[i], "n_nfmname") == 0)
                 index->nfm = i;
        else if (strcmp (column_ptr[i], "n_opentonfm") == 0)
                 index->open = i;
        else if (strcmp (column_ptr[i], "n_application") == 0)
                 index->app = i;
        else if (strcmp (column_ptr[i], "n_read") == 0)
                 index->r = i;
        else if (strcmp (column_ptr[i], "n_write") == 0)
                 index->w = i;
        else if (strcmp (column_ptr[i], "n_update") == 0)
                 index->u = i;
        else if (strcmp (column_ptr[i], "n_delete") == 0)
                 index->d = i;
        else if (strcmp (column_ptr[i], "n_null") == 0)
                 index->nul = i;
        else if (strcmp (column_ptr[i], "n_keyin") == 0)
                 index->key = i;
        else if (strcmp (column_ptr[i], "n_checkin") == 0)
                 index->in = i;
        else if (strcmp (column_ptr[i], "n_checkout") == 0)
                 index->out = i;
        else if (strcmp (column_ptr[i], "n_seqno") == 0)
                 index->seq = i;
        else if (strcmp (column_ptr[i], "n_listno") == 0)
                 index->list = i;
        }
    return (NFI_S_SUCCESS);
}


long ADMvalidate_nulls (attr_list, index, struct_data, pos, filled)

    MEMptr attr_list;
    NDXptr index;
    struct SCcolumn_data_st *struct_data;
    int  pos;
    int  *filled;


{
int  i, j;
int  tot_data;
char **data_ptr;
char msg[128];
struct SCcolumn_data_st *data;
static char *fname = "ADMvalidate_nulls";

_NFMdebug ((fname, "ENTER\n"));

data = struct_data;

tot_data = data->num_of_cols * data->num_of_rows;
data_ptr = (char **) attr_list->data_ptr;

for (j=pos; j<tot_data; j+=data->num_of_cols)
    {
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (((strcmp (data_ptr[i+index.syn], data->data[j]) == 0) ||
             (strcmp (data_ptr[i+index.nfm], data->data[j]) == 0)) &&
             (strcmp (data->data[j+2], "") == 0) &&
             (strcmp (data_ptr[i+index.nul], "N") == 0))
            {
            *filled = FALSE;
            if (strcmp (data_ptr[i+index.syn], "") != 0)
                sprintf (msg, "NFM:  Must enter \"%s\".",
                         data_ptr[i+index.syn]);
            else
                sprintf (msg, "NFM:  Must enter \"%s\".",
                         data_ptr[i+index.nfm]);
            SCdisplay_msg (msg);
            break;
            }

        if (!(*filled))
            break;
        }
    }

_NFMdebug ((fname, "EXIT\n"));
return (NFI_S_SUCCESS);
}

long NFMfind_len (data_ptr, index, rows, cols, max_attr_len, max_syn_len,
                  max_dtype_len)

    char  **data_ptr;
    NDXptr index;
    int   rows;
    int   cols;
    int   *max_attr_len, *max_syn_len, *max_dtype_len;
    
{
int  i;
int  temp_len;
char str[5];

for (i=0; i<rows; i+=cols)
    {
    if (strlen (data_ptr[i+index.name]) > *max_attr_len)
        *max_attr_len = strlen (data_ptr[i+index.name]);

    if (strlen (data_ptr[i+index.syn]) > *max_syn_len)
        *max_syn_len = strlen (data_ptr[i+index.syn]);

    temp_len = 0;

         if (strncmp (data_ptr[i+index.dt], "char", 4) == 0)
             {
             strncpy (str, data_ptr[i+index.dt] + 5,
                      (strlen (data_ptr[i+index.dt]) - 6));
             temp_len = atoi (str);
             }

    else if ((strncmp (data_ptr[i+index.dt], "int", 3) == 0) ||
             (strncmp (data_ptr[i+index.dt], "smallint", 8) == 0))
             temp_len = 12;

    else if (strncmp (data_ptr[i+index.dt], "date", 4) == 0)
             temp_len = 15;

    else if ((strncmp (data_ptr[i+index.dt], "double", 6)  == 0) ||
             (strncmp (data_ptr[i+index.dt], "real", 4)    == 0) ||
             (strncmp (data_ptr[i+index.dt], "decimal", 7) == 0))
             temp_len = 25;

    if (temp_len > *max_dtype_len)
        *max_dtype_len = temp_len;

    }

if (*max_dtype_len > 40)
    *max_dtype_len = 40;

return (NFI_S_SUCCESS);
}

long ADMget_pre_post_seq (program, prog_num, transition, trans_num, trans_state,
                          process_list, pre_post, seq_num)
    char *program;
    char *prog_num;
    char *transition;
    char *trans_num;
    char *trans_state;
    MEMptr process_list;
    char *pre_post;
    char *seq_num;

{
long   status;
int    FORM_FILLED = FALSE;
int    tot_data;
int    seq_index = 0;
int    map_count = 0;
char   str[100];
char   seq_str[46];  /* This only allows for about 12 sequences */
struct SCcolumn_data_st data;
long   ADMscan_processes ();
static char *fname = "ADMget_pre_post_seq";

    status = ADMscan_processes (process_list, trans_num, prog_num, &map_count, 
                                seq_str);
    if (status != NFI_S_SUCCESS)
        return (status);

    if (map_count == 0)
        /* there are no mappings for this transition, default seq_num to 1 */
        strcpy (seq_num, "1");
    else
        strcpy (seq_num, "");

    if (map_count == 0)
        data.num_of_rows = 4;
    else
        data.num_of_rows = 8;

    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 46;
    data.col_width[1] = 5;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "Transition <%s>, State <%s>", transition, 
             trans_state);

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    if (map_count == 0)
        seq_index = 7;
    else
        seq_index = 13;

    data.selectable[3] = 1;
    data.selectable[seq_index] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    sprintf (str, "Execute <%s> BEFORE or AFTER", program);
    NFMput_string (&data.data[0], str);
    NFMput_string (&data.data[1], "");
    sprintf (str, "  <%s> (B/A)", transition);
    NFMput_string (&data.data[2], str);
    NFMput_string (&data.data[3], "");
    NFMput_string (&data.data[4], "");
    NFMput_string (&data.data[5], "");

    if (map_count == 0)
        {
        sprintf (str, "Sequence Number (Must Be Unique)");
        NFMput_string (&data.data[6], str);
        NFMput_string (&data.data[7], seq_num);
        }
    else
        {
        /* show existing sequence numbers */
        NFMput_string (&data.data[6], "Existing Sequence Numbers:");
        NFMput_string (&data.data[7], "");
        NFMput_string (&data.data[8], seq_str);
        NFMput_string (&data.data[9], "");
        NFMput_string (&data.data[10], "");
        NFMput_string (&data.data[11], "");
        sprintf (str, "Sequence Number (Must Be Unique)");
        NFMput_string (&data.data[12], str);
        NFMput_string (&data.data[13], seq_num);
        }


    /* process column form until an workflow Name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);

        if (strcmp (data.data[3], "b") == 0)
            NFMput_string (&data.data[3], "B");
        if (strcmp (data.data[3], "a") == 0)
            NFMput_string (&data.data[3], "A");

        if ((strcmp (data.data[3], "B") != 0) &&
            (strcmp (data.data[3], "A") != 0))
            {
            FORM_FILLED = FALSE;
            SCdisplay_msg ("NFM:  Must Enter Execution Time (B/A).");
            }
        if (strcmp (data.data[seq_index], "") == 0)
            {
            FORM_FILLED = FALSE;
            SCdisplay_msg ("NFM:  Must Enter Unique Sequence Number.");
            }
        }

    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
        }

    strcpy (pre_post, data.data[3]);
    strcpy (seq_num, data.data[seq_index]);
    _NFMdebug ((fname, "pre_post <%s>\n", pre_post));
    _NFMdebug ((fname, "sequence_number <%s>\n", seq_num));

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    _NFMdebug ((fname, "Returning NFM_S_SUCCESS.\n"));

return (NFI_S_SUCCESS);
}


long NFMfill_list_struct (list, rep_type, select_set, select_type, search_str,
                          sort_str, catalog, item, rev, workflow, acl, title)

    NFMlist *list;
    int     rep_type;
    int     select_set;
    int     select_type;
    char    *search_str;
    char    *sort_str;
    char    *catalog;
    char    *item;
    char    *rev;
    char    *workflow;
    char    *acl;
    char    *title;
{
    list->rep_type = rep_type;
    list->select_set = select_set;
    list->select_type = select_type;

    list->search = (char *) malloc (2 + (strlen (search_str)));
    strcpy (list->search, search_str);

    list->sort = (char *) malloc (2 + (strlen (sort_str)));
    strcpy (list->sort, sort_str);

    strcpy (list->catalog, catalog);
    strcpy (list->item, item);
    strcpy (list->rev, rev);
    strcpy (list->wf_name, workflow);
    strcpy (list->acl_name, acl);
    strcpy (list->title, title);

    return (NFI_S_SUCCESS);
 }


long NFMfree_list_struct (list)
    NFMlist *list;

{
if (list->search != NULL)
    free (list->search);

if (list->sort != NULL)
    free (list->sort);

return (NFI_S_SUCCESS);
}



long NFMcol_width (data_ptr1, data_ptr2, max_len)

    char  *data_ptr1;
    char  *data_ptr2;
    int   *max_len;

{
int temp_len;
char str[5];

    if (strlen (data_ptr1) > *max_len)
        *max_len = strlen (data_ptr1);

    temp_len = 0;

         if (strncmp (data_ptr2, "char", 4) == 0)
             {
             strncpy (str, data_ptr2 + 5, (strlen (data_ptr2) - 6));
             str[strlen(data_ptr2) - 6] = '\0';
             temp_len = atoi (str);
             }

    else if ((strncmp (data_ptr2, "int", 3) == 0) ||
                 (strncmp (data_ptr2, "smallint", 8) == 0))
             temp_len = 12;

    else if (strncmp (data_ptr2, "timestamp", 9) == 0)
             temp_len = 20 ;

    else if ((strncmp (data_ptr2, "double", 6)  == 0) ||
             (strncmp (data_ptr2, "real", 4)    == 0) ||
(strncmp (data_ptr2, "decimal", 7) == 0))
             temp_len = 25;

    if (temp_len > *max_len)
        *max_len = temp_len;

    if (*max_len > 40)
        *max_len = 40;

    return (NFI_S_SUCCESS);
}

long ADMone_or_all (one_or_all)
    char *one_or_all;

{
int   i;
int   tot_data;
int   FORM_FILLED = FALSE;
long  status = NFM_S_SUCCESS;
struct SCfree_data_st data;
static char *fname = "ADMone_or_all";

_NFMdebug ((fname, "ENTER\n"));

    data.num_of_rows = 2;
    data.num_of_cols = 1;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size,  0,  (data.num_of_cols * sizeof (int)));

    data.col_size[0] = 45;

    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos,  0 ,  (data.num_of_cols * sizeof (int)));

    data.col_pos[0] = 0;

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just,  LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));

    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos,  0,  sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos,  0,  (data.num_of_cols * sizeof (int)) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;

    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos,  0,  sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;

    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data,  NULL,  (sizeof (char *)));
    NFMput_string (&data.h1_data[0],  "");

    data.h2_data = (char **) malloc (tot_data * (sizeof (char *)));
    memset (data.h2_data,  NULL,  tot_data * (sizeof (char *)));
    NFMput_string (&data.h2_data[0],  "");

    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data,  NULL,  (sizeof (char *)));
    NFMput_string (&data.h3_data[0],  "");

    sprintf (data.title,  "Choose Which One To Repair");

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set,  0,  (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data,  NULL,  (tot_data * sizeof (char *)));

    NFMput_string (&data.data[0],  "Individual Catalog");
    NFMput_string (&data.data[1],  "ALL Catalogs ");

    do
        {
        FORM_FILLED = FALSE;
        status = SCprocess_free_form (&data,  NFMprint_file);
        SCclear_msg ();

        if (data.sts == FORM_ACCEPTED)
      {
            for (i=0; i<data.num_of_rows; ++i)
                {
                if (data.select_set[i] == 1)
                    {
                    FORM_FILLED = TRUE;
                    if (strncmp (data.data[i],  "A",  1) == 0)
                        strcpy (one_or_all,  "A");
                    else
                        strcpy (one_or_all,  "O");
                    break;
                    }
                }
            }

        if (FORM_FILLED == FALSE)
            SCdisplay_msg ("NFM:  Must Choose One.");
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFM_str ("Cancel from form. %s",  "Return.");
        NFMfree_list (data.data,  data.num_of_rows,  data.num_of_cols);
        free (data.data);
        ERRload_struct(NFI, NFI_W_FORM_CANCELED, NULL,   NULL);
        return (NFI_W_FORM_CANCELED);
        }

    NFMfree_list (data.data,  data.num_of_rows,  data.num_of_cols);
    free (data.data);

    _NFMdebug ((fname, "EXIT\n"));
    return (NFI_S_SUCCESS);
}



long ADMget_env_name (env_list, env_name)

  MEMptr env_list;
  char   *env_name;
  
{
long   status = NFM_S_SUCCESS;
int    i, j;
int    tot_data;
int    FORM_FILLED = FALSE;
char   **data_ptr;
struct SCfree_data_st data;

    data_ptr = (char **) env_list->data_ptr;

    /* if there is only one valid I/NFM env, return it;
       else, make them choose */

    if (env_list->rows == 1)
        {
        strcpy (env_name, data_ptr[0]);
        return (NFI_S_SUCCESS);
        }

    data.num_of_rows = env_list->rows;
    data.num_of_cols = 1;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_size[0] = 30;

    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));
    
    data.col_pos[0] = 0;

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;
    
    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFMput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (tot_data * (sizeof (char *)));
    memset (data.h2_data, NULL, tot_data * (sizeof (char *)));
    NFMput_string (&data.h2_data[0], "Valid I/NFM Environments :");
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFMput_string (&data.h3_data[0], "");
    
    sprintf (data.title, "Choose I/NFM Environment");

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0, j=0; i<tot_data;
         i+=data.num_of_cols, j+=env_list->columns)
        {
        NFMput_string (&data.data[i], data_ptr[j]);
        }
        
    do
        {
        FORM_FILLED = FALSE;
        status = SCprocess_free_form (&data, NFMprint_file);
        SCclear_msg ();

        if (data.sts == FORM_ACCEPTED)
            {
            for (i=0; i<data.num_of_rows; ++i)
                {
                if (data.select_set[i] == 1)
                    {
                    FORM_FILLED = TRUE;
                    strcpy (env_name, data.data[i]);
                    break;
                    }
                }
            }

        if (FORM_FILLED == FALSE)
            SCdisplay_msg ("NFM:  Must Choose I/NFM Environment.");
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
        }

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

return (NFI_S_SUCCESS);
}



long NFMvalidate_nulls (attr_list, index, data, pos, filled)

    MEMptr attr_list;
    NDXptr index;
    struct SCcolumn_data_st data;
    int  pos;
    int  *filled;

{
int  i, j;
int  tot_data;
char **data_ptr;
char msg[128];

tot_data = data.num_of_cols * data.num_of_rows;
data_ptr = (char **) attr_list->data_ptr;

for (j=pos; j<tot_data; j+=data.num_of_cols)
    {
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
{
        if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
             (strcmp (data_ptr[i+index.nfm], data.data[j]) == 0)) &&
             (strcmp (data.data[j+2], "") == 0) &&
             (strcmp (data_ptr[i+index.w], "Y") == 0) &&
             (strcmp (data_ptr[i+index.nul], "N") == 0))
            {
            *filled = FALSE;
            if (strcmp (data_ptr[i+index.syn], "") != 0)
              sprintf (msg, "NFM:  Must enter \"%s\".", data_ptr[i+index.syn]);
            else
              sprintf (msg, "NFM:  Must enter \"%s\".",data_ptr[i+index.nfm]);
            SCdisplay_msg (msg);
            break;
            }

        if (!(*filled))
            break;
        }
    }
return (NFM_S_SUCCESS);
}

ADMmessage ()
{
static char *fname = "ADMmessage";

/* get the NFM UMS message and display it */

ERRget_specific_message (NFI, msg);
_NFMdebug ((fname, "NFI - %s\n", msg));
/*ERRget_specific_message (NFF, msg);
_NFMdebug ((fname, "NFF - %s\n", msg));*/
ERRget_specific_message (NFMR, msg);
_NFMdebug ((fname, "NFMR - %s\n", msg));
ERRget_specific_message (NETC, msg);
_NFMdebug ((fname, "NETC - %s\n", msg));
ERRget_specific_message (NETS, msg);
_NFMdebug ((fname, "NETS - %s\n", msg));
ERRget_specific_message (NFMS, msg);
_NFMdebug ((fname, "NFMS - %s\n", msg));
ERRget_specific_message (NFM, msg);
_NFMdebug ((fname, "NFM - %s\n", msg));
ERRget_specific_message (SQL, msg);
_NFMdebug ((fname, "SQL - %s\n", msg));
/*ERRget_specific_message (RDB, msg);
_NFMdebug ((fname, "RDB - %s\n", msg));*/
ERRget_specific_message (UTI, msg);
_NFMdebug ((fname, "UTI - %s\n", msg));
ERRget_specific_message (NFI, msg);
_NFMdebug ((fname, "NFI - %s\n", msg));
/*ERRget_specific_message (RPS, msg);
_NFMdebug ((fname, "RPS - %s\n", msg));
*/
ERRget_message (msg);
SCdisplay_msg (msg);
}

long ADMscan_processes (process_list, trans_num, prog_num, map_count, seq_str)
  MEMptr process_list;
  char   *trans_num;
  char   *prog_num;
  int    *map_count;
  char   *seq_str;
  
{
int    i, j;
int    trans_index = 0;
int    prog_index = 0;
int    seq_index = 0;
char   **data_ptr;
char   **column_ptr;
static char *fname = "NFMscan_processes";

    _NFIdebug ((fname, "Enter.\n"));

    data_ptr = (char **) process_list->data_ptr;
    column_ptr = (char **) process_list->column_ptr;

    /* get n_transitionno and n_programno indexes */
    for (i=0; i<process_list->columns; ++i)
        {
             if (strcmp (column_ptr[i], "n_transitionno") == 0)
                 trans_index = i;
        else if (strcmp (column_ptr[i], "n_programno") == 0)
                 prog_index = i;
        else if (strcmp (column_ptr[i], "n_seqno") == 0)
                 seq_index = i;
        }

    /* initialize sequence array */
    strcpy (seq_str, "");

    /* search the process list for all n_transitionno's that = trans_num */
    /* if the process is already attached to the transition, exit */
    for (i=0; i<process_list->rows; ++i)
        {
        j = i * process_list->columns;
        if (strcmp (data_ptr[j+trans_index], trans_num) == 0)
            {
            /* transition number found in list */
            if (strcmp (data_ptr[j+prog_index], prog_num) == 0)
                {
                /* the transition/process mapping already exists */
                _NFMdebug ((fname, "Mapping Exists <%s:%s>\n", trans_num,
                            prog_num));
                return (NFI_E_ADD_MAP);
                }
            else
                {
                _NFMdebug ((fname, "Sequence Exists <%s:%s>\n", trans_num,
                            data_ptr[j+seq_index]));
                *map_count = *map_count + 1;
                strcat (seq_str, "  ");
                strcat (seq_str, data_ptr[j+seq_index]);
                }
            }
        }

    _NFIdebug ((fname, "Exit.\n"));
    return (NFI_S_SUCCESS);
}


long ADMconfirm( title, confirmed )
    char *title;
    int  *confirmed;

{
int     tot_data;
long    status = NFI_S_SUCCESS;
struct  SCfree_data_st data;

    data.num_of_rows = 2;
    data.num_of_cols = 1;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.max_indent = 0;

    data.col_size = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_size, 0, (data.num_of_cols * sizeof(int)));
    data.col_size[0] = 5;

    data.col_pos = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_pos, 0, (data.num_of_cols * sizeof(int)));
    data.col_pos[0] = 0;

    data.col_just = (int*) malloc( data.num_of_cols * sizeof( int ));
    memset( data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof(int )));

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
    NFMput_string( &data.h1_data[0], "" );

    data.h2_data = (char**)malloc( sizeof(char*) );
    memset( data.h2_data, NULL, sizeof(char*) );
    NFMput_string( &data.h2_data[0], "" );

    data.h3_data = (char**)malloc( sizeof(char*) );
    memset( data.h3_data, NULL, sizeof(char*) );
    NFMput_string( &data.h3_data[0], "" );

    sprintf (data.title, "Are you SURE you want to %s?", title );

    data.select_set = (int*) malloc( tot_data * sizeof(int));
    memset( data.select_set, 0, tot_data * sizeof(int) );

    data.data = (char **) malloc ( tot_data * sizeof (char *));
    memset (data.data, NULL, tot_data * sizeof (char *));

    NFMput_string (&data.data[0], "Yes" );
    NFMput_string (&data.data[1], "No" );

    status = SCprocess_free_form( &data, NFMprint_file );
    *confirmed = 0;

    if( data.select_set[0] == 1 )
        *confirmed = 1;

    else if( data.select_set[1] == 1 )
        *confirmed = 0;

    if( data.sts == FORM_CANCELED || (*confirmed == 0) )
    {
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        *confirmed = 0;
        return( NFI_W_COMMAND_CANCELLED );
    }

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    return (NFI_S_SUCCESS);
}


long ADMprepare_error_form (data_data, struct_data, count, title)
    struct SCfree_data_st data_data;
    struct SCfree_data_st *struct_data;
    int    count;
    char   *title;
{
int    tot_data;
struct SCfree_data_st *err_data;
static char *fname = "ADMprepare_error_form";

    _NFIdebug(( fname, "col_size[0] <%d>\n", data_data.col_size[0]));
    _NFIdebug(( fname, "col_size[1] <%d>\n", data_data.col_size[1]));

    err_data = struct_data;

    err_data->num_of_rows = count;
    err_data->num_of_cols = 2;
    tot_data = err_data->num_of_cols * err_data->num_of_rows;

    err_data->freeze_rows_count = 0;
    err_data->freeze_cols_count = 0;

    err_data->max_indent = 0;
    err_data->select_set_expected = FALSE;

    err_data->col_size = (int *) malloc (err_data->num_of_cols * sizeof (int));
    memset (err_data->col_size, 0, (err_data->num_of_cols * sizeof (int)));

    err_data->col_size[0] = data_data.col_size[0];
    err_data->col_size[1] = 40;

    err_data->col_pos = (int *) malloc (err_data->num_of_cols * sizeof (int));
    memset (err_data->col_pos, 0 , (err_data->num_of_cols * sizeof (int)));
    err_data->col_pos[0] = 0;
    err_data->col_pos[1] = err_data->col_pos[0]+err_data->col_size[0]+3;

    err_data->col_just = (int *) malloc (err_data->num_of_cols * sizeof (int));
    memset (err_data->col_just, LEFT_JUSTIFIED,
                          (err_data->num_of_cols * sizeof (int)));

    err_data->h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (err_data->h1_pos, 0, sizeof (int) + 1);
    err_data->h1_pos[0] = 0;
    err_data->h1_pos[1] = -1;

    err_data->h2_pos = (int *) malloc ((err_data->num_of_cols *sizeof(int))+1);
    memset (err_data->h2_pos, 0, (err_data->num_of_cols * sizeof (int))+ 1);
    err_data->h2_pos[0] = 0;
    err_data->h2_pos[1] = err_data->col_pos[1];
    err_data->h2_pos[2] = -1;

    err_data->h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (err_data->h3_pos, 0, sizeof (int) + 1);
    err_data->h3_pos[0] = 0;
    err_data->h3_pos[1] = -1;

    err_data->h1_data = (char **) malloc (sizeof (char *));
    memset (err_data->h1_data, NULL, (sizeof (char *)));
    NFMput_string (&err_data->h1_data[0], "");

    err_data->h2_data = (char **) malloc (err_data->num_of_cols * (sizeof(char *)));
    memset (err_data->h2_data, NULL, err_data->num_of_cols * (sizeof(char *)));
    NFMput_string (&err_data->h2_data[0], "NFMstorage");
    NFMput_string (&err_data->h2_data[1], "Command Status");

    err_data->h3_data = (char **) malloc (sizeof (char *));
    memset (err_data->h3_data, NULL, (sizeof (char *)));
    NFMput_string (&err_data->h3_data[0], "");

    strcpy (err_data->title, title);

    err_data->select_set = (int *) malloc (tot_data * sizeof (int));
    memset (err_data->select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    err_data->data = (char **) malloc (tot_data * sizeof (char *));
    memset (err_data->data, NULL, (tot_data * sizeof (char *)));

    return (NFM_S_SUCCESS);
}


ADMset_message()
{
    int   subsystem;
    long  error_number;
    long  status;
    char  error_message[200];
    char  id[20];

    static char *fname = "ADMget_message";

    ERRget_number( &error_number, &subsystem );
    _NFMdebug(( fname, "Error Number <0x%.8x>\n", error_number ));

    status = UMSMsgCode( id, error_number,UMS_SUPPRESS_COMP|UMS_SUPPRESS_EXT,
                 NULL, NULL, NULL  );
    if( status != UMS_S_SUCCESS )
    {
        strcpy( id, "" );
 }

    _NFMdebug(( fname, "Message Type <%s>\n", id ));
  if( strcmp( id, "W" ) == 0 )
        sprintf( msg, "Warning - " );
    else if( strcmp( id, "I" ) == 0 )
        sprintf( msg, "Informational - " );
    else
 strcpy( msg, "" );

    ERRget_message( error_message );
    strncat( msg, error_message, (sizeof (msg)) -1);
/*    strcat( msg, error_message );*/

    return( NFM_S_SUCCESS );
}
