#include "machine.h"
#include <stdio.h>
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"

long change_catalog ()

{
long   status;
int    i, j, k;
int    tot_data;
int    max_attr_len = 0;
int    max_syn_len = 0;
int    max_dtype_len = 0;
int    pos;
int    count = 0;
int    old_row_count = 0;
int    FORM_FILLED;
struct SCcolumn_data_st data;
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
char   str[1028];
char   loc_name[NFM_CATALOGNAME+1];
char   index_num[20];
char   seqno[20];
MEMptr loc_attr = NULL;
MEMptr loc_data = NULL;
MEMptr loc_value = NULL;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
NDXptr index;
NDXnewptr newindex;
static char *fname = "NFAchange_catalog";

    SCdisplay_msg ("Working..");    

    status = NFMRquery_changeto_loc_attributes (NFMuser_id, loc_name, 
                               NFMcatalog, &loc_attr, &loc_data, &loc_value);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        return (status);
        }

    status = NFMRquery_change_catalog_attributes (NFMuser_id, NFMcatalog,
                                           &attr_list, &data_list, &value_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    status = MEMbuild_array (loc_attr);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        return( NFM_E_MEM );
    }
    data_ptr = (char **) loc_attr->data_ptr;
    column_ptr = (char **) loc_attr->column_ptr;

    NFMRfill_index (loc_attr, &index);

    count = 0;
    for (i=0; i<loc_attr->rows*loc_attr->columns; i+=loc_attr->columns)
        {
        if (strcmp (data_ptr[i+index.u], "Y") == 0)
            ++count;
        }

    _NFIdebug(( fname, "Displayable fields : <%d>\n", count));

    pos = 6;
    data.num_of_rows = count + 2;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    status = NFAfind_len (data_ptr, column_ptr, index, 
                          (loc_attr->rows*loc_attr->columns),
                          loc_attr->columns, &max_attr_len, &max_syn_len,
                          &max_dtype_len);
    
    data.col_width[0] = max_syn_len + 2;
    data.col_width[1] = 10;
    data.col_width[2] = max_dtype_len;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Catalog Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+2; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Attribute");
    NFAput_string (&data.data[1], "Data Type");

    for (i=pos, j=0; i<tot_data; j+=loc_attr->columns)
        {
        if (strcmp (data_ptr[j+index.u], "Y") == 0)
            {
            NFAput_string (&data.data[i], data_ptr[j+index.syn]);
            NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<loc_attr->rows*loc_attr->columns; i+=loc_attr->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.nfm], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "N") == 0) &&
                 (strcmp (data_ptr[i+index.w], "Y") == 0) &&
                 (strcmp (data_ptr[i+index.u], "Y") == 0)))
                {
                data.hidden[j+2] = 1;
                break;
                }
            }
        }

    status = MEMbuild_array (loc_data);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        return( NFM_E_MEM );
    }
    n_data_ptr = (char **) loc_data->data_ptr;

    for (i=pos+2, j=0, k=0; i<tot_data; j+=loc_attr->columns, ++k)
        {
        if (((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0)) &&
            (strcmp (data_ptr[j+index.u], "Y") == 0))
            {
            NFAput_string (&data.data[i], n_data_ptr[k]);

            if (strcmp (data_ptr[j+index.list], "0") != 0)
                {
                /* if there is a value list, display the list and let them
                   choose the value */
                status = NFAget_value_list_index (data_ptr[j+index.list],
                            loc_value, data_ptr[j+index.name],
                            data_ptr[j+index.syn], index_num);
                if (status != NFI_S_SUCCESS)
                    {
                    return (status);
                    }
                NFAput_string (&data.data[i], index_num);
                }

            i+=data.num_of_cols;
            }
        }

    /* process column form until all has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n", 
			data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFAput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFAvalidate_nulls (loc_attr, index, data, pos,
                                        &FORM_FILLED);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    status = MEMbuild_array (loc_data);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        return( NFM_E_MEM );
    }
    n_data_ptr = (char **) loc_data->data_ptr;

    for (i=pos+2, j=0, k=0; k<loc_data->columns; j+=loc_attr->columns, ++k)
        {
        if (((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0)) &&
            (strcmp (data_ptr[j+index.u], "Y") == 0))
            {
            status = MEMwrite_data (loc_data, data.data[i], 1, k+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&loc_attr);
                MEMclose (&loc_data);
                MEMclose (&loc_value);
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
   	        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMchange_catalog",
				"MEMwrite_data");
                return (NFI_E_MEMORY);
                }
            i+=data.num_of_cols;
            }
        }

    SCdisplay_msg ("Working..");    

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

/*********************************************************************
  Enter Attribute Information - Attribute Name, Data Type, and Synonym
**********************************************************************/

    status = MEMbuild_array (attr_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        return( NFM_E_MEM );
    }
    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;
    
    NFMRfill_new_index (attr_list, &newindex);

    _NFIdebug(( fname, "Displayable fields : <%d>\n", attr_list->rows));

    pos = 6;
    data.num_of_rows = attr_list->rows + 2;
    old_row_count = data.num_of_rows;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 2;
    data.select_set_expected = FALSE;
    data.new_rows_expected = TRUE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    status = NFAfind_new_len (data_ptr, column_ptr, newindex, 
                              (attr_list->rows*attr_list->columns),
                              attr_list->columns, &max_attr_len, &max_syn_len,
                              &max_dtype_len);
    
    data.col_width[0] = max_syn_len + 2;
    data.col_width[1] = 10;
    data.col_width[2] = max_dtype_len;
    strcpy (data.title, "Enter Attribute Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos; i<tot_data; i+=data.num_of_cols)
        data.selectable[i+2] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Attribute");
    NFAput_string (&data.data[1], "Data Type");
    NFAput_string (&data.data[2], "Synonym");

    for (i=pos, j=0; i<tot_data; j+=attr_list->columns, i+=data.num_of_cols)
        {
        NFAput_string (&data.data[i], data_ptr[j+newindex.name]);
        NFAput_string (&data.data[i+1], data_ptr[j+newindex.dt]);
        NFAput_string (&data.data[i+2], data_ptr[j+newindex.syn]);
        }

    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n", 
			data.sts));

        if (data.sts != FORM_CANCELED)
            {
            /* make string valid length and strip trailing blanks */
            for (i=pos;
                 i<data.num_of_cols*data.num_of_rows;
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
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    status = MEMbuild_array (data_list);

    n_data_ptr = (char **) data_list->data_ptr;

    /* fill buffer with old/new attributes, data types, synonyms */

    for (i=pos, j=0; j<attr_list->rows; ++j, i+=data.num_of_cols)
        {
        status = MEMwrite_data (attr_list, data.data[i+1], j+1,
                                newindex.new_dt+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMchange_catalog",
			    "MEMwrite_data");
            return (NFI_E_MEMORY);
            }

        status = MEMwrite_data (attr_list, data.data[i+2], j+1,
                                newindex.new_syn+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMchange_catalog",
			    "MEMwrite_data");
            return (NFI_E_MEMORY);
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
                MEMclose (&loc_attr);
                MEMclose (&loc_data);
                MEMclose (&loc_value);
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
	        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_catalog",
				"MEMwrite_data");
                return (NFI_E_MEMORY);
                }

            status = MEMbuild_array (attr_list);
            if( status != MEM_S_SUCCESS )
            {
                _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
                ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
                MEMclose (&loc_attr);
                MEMclose (&loc_data);
                MEMclose (&loc_value);
                MEMclose( &attr_list );
                MEMclose( &data_list );
                MEMclose( &value_list );
                return( NFM_E_MEM );
 	    }
            data_ptr = (char **) attr_list->data_ptr;
            column_ptr = (char **) attr_list->column_ptr;

            }  /* end for */

        /* build a new data buffer with all old attributes plus new ones */

        status = NFMRrebuild_data_buffer (attr_list, &data_list);
        if (status != NFM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
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

    SCdisplay_msg ("Working..");    

/*********************************************************************
  Enter Attribute Information  - Read, Write, Update, Delete, Nulls
**********************************************************************/

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
/* Making all the fields selectable unconditionally - IGI 24 Aug 95 */
        data.selectable[i+1] = 1;
        data.selectable[i+2] = 1;
        data.selectable[i+3] = 1;
        data.selectable[i+4] = 1;
/*
        if (i >= (old_row_count*data.num_of_cols))
            {
            data.selectable[i+1] = 1;
            data.selectable[i+2] = 1;
            data.selectable[i+3] = 1;
            data.selectable[i+4] = 1;
            }
*/
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
        NFAput_string (&data.data[i], data_ptr[j+newindex.name]);
        NFAput_string (&data.data[i+1], data_ptr[j+newindex.r]);
        NFAput_string (&data.data[i+2], data_ptr[j+newindex.w]);
        NFAput_string (&data.data[i+3], data_ptr[j+newindex.u]);
        NFAput_string (&data.data[i+4], data_ptr[j+newindex.d]);
        NFAput_string (&data.data[i+5], data_ptr[j+newindex.nul]);
        }

    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n", 
			data.sts));

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
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    /* fill buffer with old/new attributes, data types, synonyms */

    for (i=pos, j=0; j<(old_row_count-2); ++j, i+=data.num_of_cols)
        {

        status = MEMwrite_data (attr_list, data.data[i+1], j+1,
                                newindex.new_r+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_catalog",
			    "MEMwrite_data");
            return (NFI_E_MEMORY);
            }
        }

/* PS  20 Sep '95 
    for (i=i, j=j; j<attr_list->rows; ++j, i+=data.num_of_cols)
*/
    for (i=pos, j=0; j<attr_list->rows; ++j, i+=data.num_of_cols)
        {

/* PS 20 Sep '95 */
        status = MEMwrite_data (attr_list, data.data[i+2], j+1, newindex.new_w+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_catalog",
                            "MEMwrite_data");
            return (NFI_E_MEMORY);
            }

/* PS  20 Sep 95 */
        status = MEMwrite_data (attr_list, data.data[i+3], j+1, newindex.new_u+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_catalog",
			    "MEMwrite_data");
            return (NFI_E_MEMORY);
            }

/* PS 20 Sep '95 */
        status = MEMwrite_data (attr_list, data.data[i+4], j+1, newindex.new_d+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_catalog",
			    "MEMwrite_data");
            return (NFI_E_MEMORY);
            }

/* PS 20 Sep 95 */
        status = MEMwrite_data(attr_list, data.data[i+5], j+1, newindex.new_nul+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMchange_catalog",
			    "MEMwrite_data");
            return (NFI_E_MEMORY);
            }

        }  /* end for filling new attribute, data type synonym values */

    status = NFMRtic_it( loc_data );
    if( status != NFM_S_SUCCESS )
    {
        _NFIdebug(( fname, "NFMRtic_it (loc_data) : <0x%.8x>\n", status ));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_CHANGE_CATALOG, "%s", NFMcatalog );
        return( NFI_E_CHANGE_CATALOG );
    }

    status = NFMRtic_it( attr_list );
    if( status != NFM_S_SUCCESS )
    {
        _NFIdebug(( fname, "NFMRtic_it (attr_list) : <0x%.8x>\n", status ));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_CHANGE_CATALOG, "%s", NFMcatalog );
        return( NFI_E_CHANGE_CATALOG );
    }

    status = NFMRtic_it( data_list );
    if( status != NFM_S_SUCCESS )
    {
        _NFIdebug(( fname, "NFMRtic_it (data_list) : <0x%.8x>\n", status ));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_CHANGE_CATALOG, "%s", NFMcatalog );
        return( NFI_E_CHANGE_CATALOG );
    }

    SCdisplay_msg ("Working..");    

    if (_NFMdebug_st.NFIdebug_on)
        {
        MEMprint_buffers ("LOC DATA", loc_data, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers ("CATALOG ATTR", attr_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers ("CATALOG DATA", data_list, _NFMdebug_st.NFIdebug_file);
        }

    status = NFMRchange_catalog (NFMuser_id, loc_attr, loc_data,
                                 attr_list, data_list, value_list);

    _NFIdebug(( fname, "Return from NFMRchange_catalog -> 0x%.8x\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    MEMclose (&loc_attr);
    MEMclose (&loc_data);
    MEMclose (&loc_value);
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    
    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

