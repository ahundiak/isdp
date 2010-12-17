#include "machine.h"
#include <stdio.h>
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"

long change_table (table_name, table_type)
    char *table_name;
    char *table_type;

{
long   status;
int    i, j, k;
int    tot_data;
int    pos;
int    count = 0;
int    old_row_count = 0;
int    FORM_FILLED;
struct SCcolumn_data_st data;
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
char   **value_ptr;
char   str[1028];
char   seqno[10];
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
NDXnewptr index;
static char *fname = "NFAchange_table";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_change_table_attributes (NFMuser_id, table_type,
                               table_name, &attr_list, &data_list, &value_list);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);

    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    status = MEMbuild_array (value_list);

    value_ptr = (char **) value_list->data_ptr;

    NFMRfill_new_index (attr_list, &index);

    _NFIdebug ((fname, "Displayable fields : <%d>\n", count));

    pos = 6;
    data.num_of_rows = attr_list->rows + 2;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    old_row_count = data.num_of_rows;

    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 20;
    data.col_width[1] = 10;
    data.col_width[2] = 30;
    data.new_rows_expected = TRUE;
    strcpy (data.title, "Enter Table Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos; i<tot_data; i+=data.num_of_cols)
        {
        data.selectable[i+1] = 1;
        data.selectable[i+2] = 1;
        }

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Attribute");
    NFAput_string (&data.data[1], "Data Type");
    NFAput_string (&data.data[2], "Synonym");

    for (i=pos, j=0; i<tot_data; j+=attr_list->columns)
        {
        NFAput_string (&data.data[i], data_ptr[j+index.name]);
        NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);
        NFAput_string (&data.data[i+2], data_ptr[j+index.syn]);
        i+=data.num_of_cols;
        }

    status = MEMbuild_array (data_list);

    n_data_ptr = (char **) data_list->data_ptr;

    /* process column form until all has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            /* make string valid length and strip trailing blanks */
            for (i=pos; i<(data.num_of_cols*data.num_of_rows);
                 i+=data.num_of_cols)
                {
                /* data type */
                status = NFAvalidate_string ("char(15)", data.data[i+1]);

                /* syn_name */
                status = NFAvalidate_string ("char(40)", data.data[i+2]);

                status = NFAvalidate_data_type (data.data[i+1]);
                if (status != NFI_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, 
                             "NFM:  Invalid data type for attribute \"%s\"",
                             data.data[i]);
                    SCdisplay_msg (msg);
                    break;
                    }
                } /* end for */
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    /* fill buffer with old/new attributes, data types, synonyms */

    for (i=pos, j=0; j<attr_list->rows; ++j, i+=data.num_of_cols)
        {
        status = MEMwrite_data (attr_list, data.data[i+1], j+1, index.new_dt+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMchange_table",
			    "MEMwrite_data");
            return (status);
            }

        status = MEMwrite_data(attr_list, data.data[i+2], j+1, index.new_syn+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_table",
			    "MEMwrite_data");
            return (status);
            }

        }  /* end for filling new attribute, data type synonym values */

    if (old_row_count < data.num_of_rows)
        {
        /* user attributes have been added */
        /* add the new rows to the attribute buffer */

        for (i=old_row_count; i<data.num_of_rows; ++i)
            {
            str[0] = 0;

            k = i * data.num_of_cols;
            for (j=0; j<attr_list->columns; ++j)
                {
                     if (strcmp (column_ptr[j], "n_name") == 0)
                         strcat (str, data.data[k]);
                else if (strcmp (column_ptr[j], "n_datatype") == 0)
                         strcat (str, data.data[k+1]);
                else if (strcmp (column_ptr[j], "n_synonym") == 0)
                         strcat (str, data.data[k+2]);
                else if (strcmp (column_ptr[j], "n_nfmname") == 0)
                         strcat (str, data.data[k]);
                else if (strcmp (column_ptr[j], "n_opentonfm") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_application") == 0)
                         strcat (str, "USR");
                else if (strcmp (column_ptr[j], "n_read") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_write") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_update") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_delete") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_null") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_keyin") == 0)
                         strcat (str, "0");
                else if (strcmp (column_ptr[j], "n_checkin") == 0)
                         strcat (str, "N");
                else if (strcmp (column_ptr[j], "n_checkout") == 0)
                         strcat (str, "N");
                else if (strcmp (column_ptr[j], "n_seqno") == 0)
                         {
                         sprintf (seqno, "%d", i-2);
                         strcat (str, seqno);
                         }
                else if (strcmp (column_ptr[j], "n_listno") == 0)
                         strcat (str, "0");
                else
                         strcat (str, "");

                strcat (str, "\1");

                }  /* end for */

            status = MEMwrite (attr_list, str);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
                ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_table",
				"MEMwrite");
                return (status);
                }

            status = MEMbuild_array (attr_list);

            data_ptr = (char **) attr_list->data_ptr;
            column_ptr = (char **) attr_list->column_ptr;

            }  /* end for */

            status = NFMRrebuild_data_buffer (attr_list, &data_list);
            if (status != NFM_S_SUCCESS)
                {
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
                return (status);
                }

        }  /* end if old_row_count < data.num_of_rows */

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

/************************************************************************/

    pos = 12;
    data.num_of_rows = attr_list->rows + 2;
    data.num_of_cols = 6;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 2;
    data.select_set_expected = FALSE;
    data.new_rows_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 20;
    data.col_width[1] = 7;
    data.col_width[2] = 7;
    data.col_width[3] = 7;
    data.col_width[4] = 7;
    data.col_width[5] = 7;
    strcpy (data.title, "Enter Attribute Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        {
        data.selectable[i] = 1;
        if (i >= (old_row_count*data.num_of_cols))
            {
            data.selectable[i+1] = 1;
            data.selectable[i+2] = 1;
            data.selectable[i+3] = 1;
            data.selectable[i+4] = 1;
            }
        }

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Attribute");
    NFAput_string (&data.data[1], "Read?");
    NFAput_string (&data.data[2], "Write?");
    NFAput_string (&data.data[3], "Update?");
    NFAput_string (&data.data[4], "Delete?");
    NFAput_string (&data.data[5], "Nulls?");

    for (i=pos, j=0; i<tot_data; j+=attr_list->columns, i+=data.num_of_cols)
        {
        NFAput_string (&data.data[i], data_ptr[j+index.name]);
        NFAput_string (&data.data[i+1], data_ptr[j+index.r]);
        NFAput_string (&data.data[i+2], data_ptr[j+index.w]);
        NFAput_string (&data.data[i+3], data_ptr[j+index.u]);
        NFAput_string (&data.data[i+4], data_ptr[j+index.d]);
        NFAput_string (&data.data[i+5], data_ptr[j+index.nul]);
        }

    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            /* make string valid length and strip trailing blanks */
            for (i=pos;
                 i<data.num_of_cols*data.num_of_rows;
                 i+=data.num_of_cols)
                {
                /* read */
                status = NFAvalidate_Y_or_N (data.data[i+1]);
                if (status != NFI_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, "NFM:  Invalid 'READ' for attribute \"%s\"",
                             data.data[i]);
                    SCdisplay_msg (msg);
                    break;
                    }

                /* write */
                status = NFAvalidate_Y_or_N (data.data[i+2]);
                if (status != NFI_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, "NFM:  Invalid 'WRITE' for attribute \"%s\"",
                             data.data[i]);
                    SCdisplay_msg (msg);
                    break;
                    }

                /* update */
                status = NFAvalidate_Y_or_N (data.data[i+3]);
                if (status != NFI_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, "NFM:  Invalid 'UPDATE' for attribute \"%s\"",
                             data.data[i]);
                    SCdisplay_msg (msg);
                    break;
                    }

                /* delete */
                status = NFAvalidate_Y_or_N (data.data[i+4]);
                if (status != NFI_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, "NFM:  Invalid 'DELETE' for attribute \"%s\"",
                             data.data[i]);
                    SCdisplay_msg (msg);
                    break;
                    }

                /* nulls */
                status = NFAvalidate_Y_or_N (data.data[i+5]);
                if (status != NFI_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, "NFM:  Invalid 'NULLS' for attribute \"%s\"",
                             data.data[i]);
                    SCdisplay_msg (msg);
                    break;
                    }

                } /* end for */
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    /* fill buffer with old/new data for read,write,update,nulls... */

    _NFIdebug ((fname, "old row count : <%d>\n", old_row_count));
    _NFIdebug ((fname, "data.num_of_rows : <%d>\n", data.num_of_rows));

    for (i=pos, j=0; j<(old_row_count-2); ++j, i+=data.num_of_cols)
        {
        status = MEMwrite_data (attr_list, data.data[i+1], j+1, index.new_r+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMchange_table",
			    "MEMwrite_data");
            return (status);
            }

        }  /* end for filling new attribute, data type synonym values */

    for (i=i, j=j; j<attr_list->rows; ++j, i+=data.num_of_cols)
        {
        status = MEMwrite_data (attr_list, data.data[i+1], j+1, index.r+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_table",
			    "MEMwrite_data");
            return (status);
            }

        status = MEMwrite_data (attr_list, data.data[i+2], j+1, index.w+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_table",
			    "MEMwrite_data");
            return (status);
            }

        status = MEMwrite_data (attr_list, data.data[i+3], j+1, index.u+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_table",
			    "MEMwrite_data");
            return (status);
            }

        status = MEMwrite_data (attr_list, data.data[i+4], j+1, index.d+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_table",
			    "MEMwrite_data");
            return (status);
            }

        status = MEMwrite_data (attr_list, data.data[i+5], j+1, index.nul+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_table",
			    "MEMwrite_data");
            return (status);
            }

        }  /* end for filling new attribute, data type synonym values */

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

/************************************************************************/

    if (_NFMdebug_st.NFIdebug_on)
        {
        MEMprint_buffers ("CHG TABLE ATTR", attr_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers ("CHG TABLE DATA", data_list, _NFMdebug_st.NFIdebug_file);
        }
    
    SCdisplay_msg ("Working..");    

    status = NFMRchange_table (NFMuser_id, table_type, table_name, attr_list,
                               data_list, value_list);

    _NFIdebug ((fname, "NFMchange_table -> <0x%.8x>\n", status));

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    
    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


