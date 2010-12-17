#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "ERR.h"
#include "NDXstruct.h"
#include "NFMRlist.h"
#include "NFMdisplays.h"
#include "NFMtitles.h"
#include "UMS.h"

extern long sqlstatus;

long add_project ()

{
long   status;
int    i, j, k;
int    tot_data;
int    max_attr_len = 0;
int    max_syn_len = 0;
int    max_dtype_len = 0;
int    pos;
int    count = 0;
int    FORM_FILLED;
struct SCcolumn_data_st data;
char   lop_name[20];
char   project_name[21];
char   index_num[20];
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
NDXptr index;
static char *fname = "add_project";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_addto_lop_attributes (NFMuser_id, lop_name, &attr_list,
                                             &data_list, &value_list);

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

    NFMRfill_index (attr_list, &index);

    count = 0;
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (data_ptr[i+index.w], "Y") == 0)
            ++count;
        }

    _NFIdebug ((fname, "Displayable fields : <%d>\n", count));

    pos = 6;
    data.num_of_rows = count + 2;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    status = NFAfind_len (data_ptr, column_ptr, index, 
                          (attr_list->rows*attr_list->columns),
                          attr_list->columns, &max_attr_len, &max_syn_len,
                          &max_dtype_len);
    
    data.col_width[0] = max_syn_len + 2;
    data.col_width[1] = 10;
    data.col_width[2] = max_dtype_len;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Project Information");

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

    for (i=pos, j=0; i<tot_data; j+=attr_list->columns)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            if (strcmp (data_ptr[j+index.syn], "") != 0)
                NFAput_string (&data.data[i], data_ptr[j+index.syn]);
            else
                NFAput_string (&data.data[i], data_ptr[j+index.name]);
            NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.nfm], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "N") == 0) &&
                 (strcmp (data_ptr[i+index.w], "Y") == 0)))
                {
                data.hidden[j+2] = 1;
                break;
                }
            }
        }

/* if attribute is readable but not writeable, suppress input 
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.nfm], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "Y") == 0) &&
                 (strcmp (data_ptr[i+index.w], "N") == 0)))
                {
                data.selectable[j+2] = 0;
                break;
                }
            }
        }
 ** No non_writable attributes will be displayed */

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMadd_project",
			"MEMbuild_array");
        return (status);
        }

    n_data_ptr = (char **) data_list->data_ptr;

    for (i=pos+2, j=0, k=0; i<tot_data; j+=attr_list->columns, ++k)
        {
        if  (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            NFAput_string (&data.data[i], n_data_ptr[k]);

            if (strcmp (data_ptr[j+index.list], "0") != 0)
                {
                /* if there is a value list, display the list and let them
                   choose the value */
                status = NFAget_value_list_index (data_ptr[j+index.list],
                            value_list, data_ptr[j+index.name],
                            data_ptr[j+index.syn], index_num);
                if (status != NFI_S_SUCCESS)
                    {
                    MEMclose (&attr_list);
                    MEMclose (&value_list);
                    MEMclose (&data_list);
                    return (status);
                    }
                NFAput_string (&data.data[i], index_num);
                }

            i+=data.num_of_cols;
            }
        }

    /* process column form until file_name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFAput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFAvalidate_nulls (attr_list, index, data, pos,
                                        &FORM_FILLED);
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

    for (i=pos; i<tot_data; i+=data.num_of_cols)
        {
        for (j=0, k=0; k<data_list->columns; j+=attr_list->columns, ++k)
            {
            if (((strcmp (data_ptr[j+index.syn], data.data[i]) == 0) ||
                 (strcmp (data_ptr[j+index.name], data.data[i]) == 0)) &&
                (strcmp (data_ptr[j+index.w], "Y") == 0))
                {
                status = MEMwrite_data (data_list, data.data[i+2], 1, k+1);
                if (status != MEM_S_SUCCESS)
                    {
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    MEMclose (&value_list);
                    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                    free (data.data);
	            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMadd_project",
				    "MEMwrite_data");
                    return (status);
                    }

                /* save project name */
                if (strcmp (data_ptr[j+index.nfm], "n_projectname") == 0)
                    strcpy (project_name, data.data[i+2]);

                break;
                }
            }
        }

    status = NFMRtic_it( data_list );
    if( status != NFM_S_SUCCESS )
    {
        _NFIdebug ((fname, "NFMRtic_it : <0x%.8x>\n", status));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_ADD_PROJECT, "%s", project_name );
        return( NFI_E_ADD_PROJECT );
    }

    SCdisplay_msg ("Working..");    

    status = NFMRadd_project (NFMuser_id, attr_list, data_list);

    _NFIdebug ((fname, "NFMRadd_project -> <0x%.8x>\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    
    if (status != NFM_S_SUCCESS)
        return (status);

    strcpy (NFMproject, project_name);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long delete_project ()

{
long    status;
int     i, j;
char    project[30];
char    title[80];
NFMlist list_struct;
struct  SCfree_data_st data;
static char *fname = "delete_project";

    _NFIdebug ((fname, "Enter.\n"));

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_PROJECTS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Projects" );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_PROJECTS, SELECT_SET_SINGLE_ROW,
		NFM_SHORT_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        return (status);

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (project, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");    

#ifdef COMBINED_CLIENT_SERVER
    {
    long return_value;
    status = NFMdelete_project (NFMuser_id, project, &return_value);
    }
#else
    status = NFMRdelete_project (NFMuser_id, project);
#endif

    _NFIdebug ((fname, "NFMRdelete_project -> <0x%.8x>\n", status));

    if (status != NFM_S_SUCCESS)
        return (status);

    if( strcmp( project, NFMproject) == 0 )
        strcpy (NFMproject, "");

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



long change_project ()

{
long   status;
int    i, j, k;
int    tot_data;
int    max_attr_len = 0;
int    max_syn_len = 0;
int    max_dtype_len = 0;
int    pos;
int    count = 0;
int    FORM_FILLED;
struct SCcolumn_data_st data;
char   project_name[21];
char   index_num[20];
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
NDXptr index;
static char *fname = "change_project";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_changeto_lop_attributes (NFMuser_id, NFMproject,
                                          &attr_list, &data_list, &value_list);

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

    NFMRfill_index (attr_list, &index);

    count = 0;
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (((strcmp (data_ptr[i+index.r], "Y") == 0) ||
            (strcmp (data_ptr[i+index.w], "Y") == 0)) &&
            (strcmp (data_ptr[i+index.u], "Y") == 0))
            ++count;
        }

    _NFIdebug ((fname, "Displayable fields : <%d>\n", count));

    pos = 6;
    data.num_of_rows = count + 2;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    status = NFAfind_len (data_ptr, column_ptr, index, 
                          (attr_list->rows*attr_list->columns),
                          attr_list->columns, &max_attr_len, &max_syn_len,
                          &max_dtype_len);
    
    data.col_width[0] = max_syn_len + 2;
    data.col_width[1] = 10;
    data.col_width[2] = max_dtype_len;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Project Information");

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

    for (i=pos, j=0; i<tot_data; j+=attr_list->columns)
        {
        if (((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0)) &&
            (strcmp (data_ptr[j+index.u], "Y") == 0))
            {
            if (strcmp (data_ptr[j+index.syn], "") != 0)
                NFAput_string (&data.data[i], data_ptr[j+index.syn]);
            else
                NFAput_string (&data.data[i], data_ptr[j+index.name]);
            NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
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

    /* if attribute is readable but not writeable, suppress input */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.nfm], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "Y") == 0) &&
                 (strcmp (data_ptr[i+index.w], "N") == 0) &&
                 (strcmp (data_ptr[i+index.u], "Y") == 0)))
                {
                data.selectable[j+2] = 0;
                break;
                }
            }
        }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMchange_project",
			"MEMbuild_array");
        return (status);
        }

    n_data_ptr = (char **) data_list->data_ptr;

    for (i=pos+2, j=0, k=0; i<tot_data; j+=attr_list->columns, ++k)
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
                            value_list, data_ptr[j+index.name],
                            data_ptr[j+index.syn], index_num);
                if (status != NFI_S_SUCCESS)
                    {
                    MEMclose (&attr_list);
                    MEMclose (&value_list);
                    MEMclose (&data_list);
                    return (status);
                    }
                NFAput_string (&data.data[i], index_num);
                }

            i+=data.num_of_cols;
            }
        }

    /* process column form until file_name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFAput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFAvalidate_nulls (attr_list, index, data, pos,
                                        &FORM_FILLED);
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

    for (i=pos; i<tot_data; i+=data.num_of_cols)
        {
        for (j=0, k=0; k<data_list->columns; j+=attr_list->columns, ++k)
            {
            if (((strcmp (data_ptr[j+index.syn], data.data[i]) == 0) ||
                 (strcmp (data_ptr[j+index.name], data.data[i]) == 0)) &&
                 ((strcmp (data_ptr[j+index.w], "Y") == 0) &&
                 (strcmp (data_ptr[j+index.u], "Y") == 0)))
                {
                status = MEMwrite_data (data_list, data.data[i+2], 1, k+1);
                if (status != MEM_S_SUCCESS)
                    {
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    MEMclose (&value_list);
                    NFAfree_list(data.data,data.num_of_rows, data.num_of_cols);
                    free (data.data);
	            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMchange_project",
				    "MEMwrite_data");
                    return (status);
                    }
                break;
                }
            }
        }

    status = NFMRtic_it( data_list );
    if( status != NFM_S_SUCCESS )
    {
        _NFIdebug ((fname, "NFMRtic_it : <0x%.8x>\n", status));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_CHANGE_PROJECT, "%s", project_name );
        return( NFI_E_CHANGE_PROJECT );
    }

    SCdisplay_msg ("Working..");    

    status = NFMRchange_project (NFMuser_id, attr_list, data_list);

    _NFIdebug ((fname, "NFMRchange_project -> <0x%.8x>\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

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



