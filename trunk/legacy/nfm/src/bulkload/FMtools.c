#include "machine.h"
#include <stdio.h>
#include <time.h>
#include <errno.h>
#include "SCstruct.h"
#include "MEMstruct.h"
#include "SCdef.h"
#include "NFMerrordef.h"
#include "NFIerrordef.h"
#include "NFMRextern.h"
#include "NFMdef.h"
#include "ERR.h"
#include "DEBUG.h"

int NFAmake_msg (mess)
    char *mess;
    
{
    strcpy (mess, "NFM>  ");

    if (strcmp (NFMproject, "") != 0)
        {
        strcat (mess, "PRJ: ");
        strcat (mess, NFMproject);
        strcat (mess, "  ");
        }

    if (strcmp (NFMcatalog, "") != 0)
        {
        strcat (mess, NFMcatalog);
        if (strcmp (NFMitem, "") != 0)
            {
            strcat (mess, " : ");
            strcat (mess, NFMitem);
            if (strcmp (NFMrev, "") != 0)
                {
                strcat (mess, ".");
                strcat (mess, NFMrev);
                }
            }
	}
    if (strcmp (NFMstorage, "") != 0)
        {
        strcat (mess, "  STORAGE: ");
        strcat (mess, NFMstorage);
        }

    if (strcmp (NFMworkflow, "") != 0)
        {
        strcat (mess, "  WF: ");
        strcat (mess, NFMworkflow);
        }

    if (strcmp (NFMacl, "") != 0)
        {
        strcat (mess, "  ACL: ");
        strcat (mess, NFMacl);
        }

    if (strcmp (NFMsearch_name, "") != 0)
        {
        strcat (mess, "  SCR: ");
        strcat (mess, NFMsearch_name);
        }

    if (strcmp (NFMsort_name, "") != 0)
        {
        strcat (mess, "  SRT: ");
        strcat (mess, NFMsort_name);
        }

    return (NFI_S_SUCCESS);
}


int NFAfree_list (data_list, num_rows, num_cols)
    char   **data_list;
    int    num_rows;
    int    num_cols;

{
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

    return (NFI_S_SUCCESS);
}


int NFAput_string (to_string, string)
    char  **to_string;
    char  *string;

{

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
        
    return (NFI_S_SUCCESS);
}


int NFAvalidate_string (dtype, string)
    char  *dtype;
    char  *string;

{
    long   status;
    int    i, len;
    
    if (string != NULL)
        {
        status = NFAget_dtype_len (dtype, string, &len);
        for (i=len-1; i>=0; --i)
            {
            if (string[i] != ' ')
                {
                break;
                }
            }
        string[i+1] = '\0';
        }
    else
        {
        string = (char *) malloc (2);
        strcpy (string, "");
        }

    return (NFI_S_SUCCESS);
}


int NFAvalidate_Y_or_N (string)
    char  *string;

{

    if (string != NULL)
        {
             if (strncmp (string, "n", 1) == 0)
                 strcpy (string, "N");

        else if (strncmp (string, "y", 1) == 0)
                 strcpy (string, "Y");

        if ((strncmp (string, "N", 1) != 0) &&
            (strncmp (string, "Y", 1) != 0))
	    {
	    ERRload_struct( NFI, NFI_E_INVALID_INFORMATION, NULL, NULL );
            return (NFI_E_FAILURE);
	    }
        string[1] = '\0';
        }

    return (NFI_S_SUCCESS);
}


int NFMput_buf_string (to_string, string, len)
    char  **to_string;
    char  *string;
    int   len;

{
    if (string != NULL)
        {
        strncpy (*to_string, string, len);
        }
    else
        {
        strncpy (*to_string, "", len);
        }

    return (NFI_S_SUCCESS);
}


int NFMput_and_validate_data (data, initial, limit, increment)
    char   **data;
    int    initial;
    int    limit;
    int    increment;

{
int  status, i;

    /* if blank, fill data with "" */
    /* make string valid length and strip trailing blanks */
    for (i=initial; i<limit; i+=increment)
        {
        if (data[i] == 0)
            {
            NFAput_string (&data[i], "");
            }
        else
            {
            status = NFAvalidate_string (data[i-1], data[i]);
            }
        }

    return (NFI_S_SUCCESS);
}

NFAdisplay_message_set( title , set_msg)
    char   *title;
    MEMptr set_msg;
{
    long   status;

    int    i;
    int    tot_data;
    int    pos;
    char   **set_msg_ptr;
    
    struct SCcolumn_data_st data;

    static char *fname = "NFAdisplay_message_set";

    set_msg_ptr = (char **) set_msg->data_ptr;

    pos = 0;
    data.num_of_rows = set_msg->rows;
    data.num_of_cols = 1;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 80;

    data.new_rows_expected = FALSE;
    strcpy (data.title, title );

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for( i=0; i<set_msg->rows; ++i )
    {
        NFAput_string (&data.data[i], set_msg_ptr[i]);
    }

    status = SCprocess_column_form (&data, NFMprint_file);
    SCclear_msg ();

    _NFIdebug(( fname, "return from SCprocess_column_form -> %d\n", 
			data.sts));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if( status != NFM_S_SUCCESS )
	return( status );       
 
    return (NFI_S_SUCCESS);
}
