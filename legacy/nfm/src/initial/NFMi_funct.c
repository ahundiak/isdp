#include "machine.h"
/*************************************************************************
 *                                                                       *
 *     Module:    NFMfunctions.c                                         *
 *     Author:    Karen Tice                                             *
 *                                                                       *
 *************************************************************************/

#include "INIT.h"

#define NFM_SERVER_NUM 11
#define NOT !

    long sqlstatus;

NFMget_network_types (node_name, tcp, xns, dec)
  char *node_name;
  char *tcp;
  char *xns;
  char *dec;
  
{
  static char *fname = "NFMget_network_types" ;
int    status = NFM_S_SUCCESS;
int    tot_data, i ;
int    FORM_FILLED = FALSE;
struct SCfree_data_st data;

    _NFMdebug ((fname, "Enter <%s>", "NFMget_network_types"));

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
        status = SCprocess_free_form (&data);
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

    _NFMdebug ((fname, "TCP/IP -> <%s>", tcp));
    _NFMdebug ((fname, "XNS    -> <%s>", xns));
    _NFMdebug ((fname, "DECNET -> <%s>", dec));

return (NFM_S_SUCCESS);
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
        
    return (NFM_S_SUCCESS);
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
        else if (strcmp (column_ptr[i], "n_checkin") == 0)
                 index->in = i;
        else if (strcmp (column_ptr[i], "n_checkout") == 0)
                 index->out = i;
        else if (strcmp (column_ptr[i], "n_seqno") == 0)
                 index->seq = i;
         else if (strcmp (column_ptr[i], "n_adviceno") == 0)
                 index->key = i;
        else if (strcmp (column_ptr[i], "n_valueno") == 0)
                 index->list = i;
         }
}


long NFMvalidate_nulls (attr_list, index, data, pos, filled)

    MEMptr attr_list;
    NDXptr index;
    struct SCcolumn_data_st data;
    int  pos;
    int  *filled;


{
  char *fname = "NFMvalidate_nulls" ;
int  i, j;
int  tot_data;
char **data_ptr;
char msg[128];

_NFMdebug ((fname, "ENTER\n")) ;
tot_data = data.num_of_cols * data.num_of_rows;
data_ptr = (char **) attr_list->data_ptr;

for (j=pos; j<tot_data; j+=data.num_of_cols)
    {
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
             (strcmp (data_ptr[i+index.name], data.data[j]) == 0)) &&
             (strcmp (data.data[j+2], "") == 0) &&
             (strcmp (data_ptr[i+index.nul], "N") == 0))
            {
            *filled = FALSE;
            if (strcmp (data_ptr[i+index.syn], "") != 0)
                sprintf (msg, "NFM:  Must enter \"%s\".",
                         data_ptr[i+index.syn]);
            else
                sprintf (msg, "NFM:  Must enter \"%s\".",
                         data_ptr[i+index.name]);
            SCdisplay_msg (msg);
            break;
            }

        if (!(*filled))
            break;
        }
    }

return (NFM_S_SUCCESS);
}


int NFMfree_list (data_list, num_rows, num_cols)
    char   **data_list;
    int    num_rows;
    int    num_cols;

{
    int    status = NFM_S_SUCCESS;
    int    row;
    int    col;
    
    for (row=0; row<num_rows; ++row)
        {
        for (col=0; col<num_cols; ++col)
            {
            if (data_list[(num_cols * row) + col] != NULL)
                {
                free (data_list[(num_cols * row) + col]);
                }
            }
        }

    return (status);
}


int NFMput_string (to_string, string)
    char  **to_string;
    char  *string;

{
    int    status = NFM_S_SUCCESS;

    if (*to_string != NULL)
        {
        free (*to_string);
        *to_string = NULL;
        }

    if (string != NULL)
        {
        *to_string = (char *) malloc (strlen (string) + 1);
        strcpy (*to_string, string);
        }
        
    return (status);
}


int NFMvalidate_string (dtype, string)
    char  *dtype;
    char  *string;

{
  char *fname = "NFMvalidate_string" ;
    int    status = NFM_S_SUCCESS;
    int    i, len;
    
    if (string != NULL)
        {
        status = NFMget_dtype_len (dtype, string, &len);
        for (i=len-1; i>=0; --i)
            {
            if (string[i] != ' ')
                {
                break;
                }
            }
        string[i+1] = '\0';
        }

    return (NFM_S_SUCCESS);
}


int NFMput_buf_string (to_string, string, len)
    char  **to_string;
    char  *string;
    int   len;

{
    int    status = NFM_S_SUCCESS;

    if (string != NULL)
        {
        strncpy (*to_string, string, len);
        }
    else
        {
        strncpy (*to_string, "", len);
        }

    return (status);
}


int NFMput_and_validate_data (data, initial, limit, increment)
    char   **data;
    int    initial;
    int    limit;
    int    increment;

{
char *fname = "NFMput_and_validate_data" ;
int  status, i;

_NFMdebug ((fname, "ENTER\n")) ;
    /* if blank, fill data with "" */
    /* make string valid length and strip trailing blanks */
    for (i=initial; i<limit; i+=increment)
        {
        if (!strlen (data[i]))
	  {
            NFMput_string (&data[i], "");
	  }
        else
	  {
            status = NFMvalidate_string (data[i-1], data[i]);
	  }
      }

    return (NFM_S_SUCCESS);
}



