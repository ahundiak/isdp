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
#include "NFIcommands.h"
#include "NFMdisplays.h"
#include "NFIerrordef.h"
#include "DEBUG.h"



extern MSGptr NFMmsg_ptr, SQLmsg_ptr ;
extern long sqlstatus;

long NFMget_value_list_string (list_num, value_list, attr_name, synonym,
                               index_num, string_val)
    char   *list_num;
    MEMptr value_list;
    char   *attr_name;
    char   *synonym;
    char   *index_num;
    char   *string_val;

{
int  tot_data;
int  i, j, pos;
long status;
int  FORM_FILLED = FALSE;
int  no_row_selected = TRUE;
long list_no;
char acl_name[20];
char **data_ptr;
char **column_ptr;

struct SCfree_data_st data;
            
    _NFMR_str ("%s",  "Enter NFMget_value_list_string");

    list_no = atol (list_num);

    _NFMR_num ("NFMget_value_list_string : list_no : <%d>", list_no);

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
     {
        NFMerr_ret (status);
        _NFMR_num ("NFMget_value_list_string : MEMbuild_array : <0x%.8x>", status);

        return (NFM_E_MEM);
        }

    status = MEMreset_buffer_no (value_list, list_no);
    if (status != MEM_S_SUCCESS)
    {
      NFMerr_ret (status);
      _NFMR_num( "NFMget_value_list_string : MEMreset_buffer_no :<0x%.8x>", status);

        return (NFM_E_MEM);
        }

    data_ptr = (char **) value_list->data_ptr;
    column_ptr = (char **) value_list->column_ptr;

    /* if there are no rows, return ERROR */

    if (value_list->rows == 0)
        return (NFM_E_FAILURE);

    /* if there is only one row, use this index without displaying it */

    if (value_list->rows == 1)
     {
        strcpy (index_num, data_ptr[0]);

        /* this is a kludge for a sticky situation: the real 'value' is
           in the LAST column */

        strcpy (string_val, data_ptr[value_list->columns-1]);

        _NFMR_str ("NFMget_value_list_string : index  : <%s>", index_num);

        _NFMR_str ( "NFMget_value_list_string : string : <%s>", string_val);
        return (NFM_S_SUCCESS);
        }

    data.num_of_rows = value_list->rows;
    data.num_of_cols = value_list->columns;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 1;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0 , (data.num_of_cols * sizeof (int)));
    data.col_size[0] = 5;
    for (i=1; i<data.num_of_cols; ++i)
        data.col_size[i] = 20;

    pos = 0;
    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));
    for (i=0, j=0; i<data.num_of_cols; ++i, j+=value_list->columns)
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
    for (i=0; i<data.num_of_cols; ++i)
        data.h2_pos[i] = data.col_pos[i];
    data.h2_pos[i] = -1;
    
    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (data.num_of_cols * (sizeof (char *)));
    memset (data.h2_data, NULL, data.num_of_cols * (sizeof (char *)));
    for (i=0; i<data.num_of_cols; ++i)
        NFAput_string (&data.h2_data[i], column_ptr[i]);
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");

    if (strcmp (synonym, "") != 0)
        sprintf (data.title, "Choose \'%s\'", synonym);
    else
        sprintf (data.title, "Choose \'%s\'", attr_name);

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        {
        NFAput_string (&data.data[i], data_ptr[i]);
        }

    /* process free form */
    status = SCprocess_free_form (&data, NFMprint_file);

    if (data.sts == FORM_CANCELED)
        {
        _NFMR_str ("%s", "Cancel from form. Return.");
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI,  NFI_W_FORM_CANCELED,  NULL,  NULL );
        return (NFI_W_FORM_CANCELED);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
            {
            no_row_selected = FALSE;
            strcpy (index_num, data.data[j]);

            /* this is a kludge for a sticky situation: the real 'value' is
               in the LAST column */

            strcpy (string_val, data_ptr[j+(value_list->columns-1)]);

            break;
            }
        }

    if (no_row_selected)
        return (NFM_E_FAILURE);
    else
        return (NFM_S_SUCCESS);

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

   _NFMR_str ("NFMget_value_list_string : index  : <%s>", index_num);
   _NFMR_str ("NFMget_value_list_string : string : <%s>", string_val);
   _NFMR_str ("%s", "Exit NFMget_value_list_string");


    return (NFM_S_SUCCESS);
}


long NFMvalidate_list_entity (list_num, value_list, attr_name, attr_value,
                              attr_index)
    char   *list_num;
    MEMptr value_list;
    char   *attr_name;
    char   *attr_value;
    char   *attr_index;

{
int  i;
int  name_index = 0;
long status;
int  FOUND_IT = FALSE;
long list_no;
char **data_ptr;
char **column_ptr;

 _NFMR_str ("%s", "Enter NFMvalidate_list_entity");
 _NFMR_str ("NFMvalidate_list_entity : list_num   : <%s>", list_num);
 _NFMR_str ("NFMvalidate_list_entity : attr_name  : <%s>", attr_name);
 _NFMR_str ("NFMvalidate_list_entity : attr_value : <%s>", attr_value);

    list_no = atol (list_num);

  _NFMR_num ( "NFMvalidate_list_entity : list_no : <0x%.8x>", list_no);

    status = MEMbuild_array (value_list);
    if (status != MEM_S_SUCCESS)
        {
         NFMerr_ret (status);
        _NFMR_num ("NFMvalidate_list_entity : MEMbuild_array : <0x%.8x>", status);

        return (NFM_E_MEM);
        }

    status = MEMreset_buffer_no (value_list, list_no);
    if (status != MEM_S_SUCCESS)
        {
          NFMerr_ret (status);
         _NFMR_num("NFMvalidate_list_entity : MEMreset_buffer_no : <0x%.8x>", status);

        return (NFM_E_MEM);
        }

    data_ptr = (char **) value_list->data_ptr;
    column_ptr = (char **) value_list->column_ptr;

    /* if there are no rows, return ERROR */

    if (value_list->rows == 0)
        return (NFM_E_FAILURE);

/*
    if (NFMRmsg_ptr.debug_on)
        MEMprint_buffer ("ENTITY VALUES", value_list, NFMRmsg_ptr.debug_file);
*/

    for (i=0; i<value_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], attr_name) == 0)
            {
            name_index = i;
            break;
            }
        }

    FOUND_IT = FALSE;

    for (i=0; i<(value_list->rows*value_list->columns); i+=value_list->columns)
        {
        if (strcmp (data_ptr[i+name_index], attr_value) == 0)
         {
          FOUND_IT = TRUE;
          strcpy (attr_index, data_ptr[i]);
         _NFMR_str ("NFMvalidate_list_entity : <%s>", data_ptr[i]);
         _NFMR_str ( "NFMvalidate_list_entity : <%s>", data_ptr[i+name_index]);

            break;
            }
        }

    if (FOUND_IT)
        return (NFM_S_SUCCESS);
    else
        return (NFM_E_FAILURE);
}


long NFMuser_attr (attr_list, data_list, item)
    MEMptr attr_list;
    MEMptr data_list;
    char   *item;

{
int  tot_data;
int  i, j, k, pos;
long status;
int  FORM_FILLED = FALSE;
int  no_row_selected = TRUE;
int  user_count;
char **data_ptr;
char **column_ptr;
char **ddata_ptr;
char **dcolumn_ptr;
struct SCcolumn_data_st data;
NDXptr index;
            
    _NFMR_str ("%s", "Enter NFMuser_attr");

    status = MEMbuild_array (attr_list);

    NFMRfill_index (attr_list, &index);

    status = MEMbuild_array (data_list);

    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    ddata_ptr = (char **) data_list->data_ptr;
    dcolumn_ptr = (char **) data_list->column_ptr;

    /* find out how many user attributes there are */
    user_count = 0;
    for (i=0; i<(attr_list->rows*attr_list->columns); i+=attr_list->columns)
        {
        if (strcmp (data_ptr[i+index.app], "NFM") != 0)
            ++user_count;
        }

    if (user_count == 0)
        return (NFM_S_SUCCESS);

    pos = 0;
    data.num_of_rows = user_count;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 20;
    data.col_width[1] = 10;
    data.col_width[2] = 30;
    data.new_rows_expected = FALSE;

    sprintf (data.title, "Enter User Attributes for Item <%s>", item);

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+2; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0, j=0;
         i<(attr_list->rows*attr_list->columns);
         i+=attr_list->columns)
        {
        if (strcmp (data_ptr[i+index.app], "NFM") != 0)
            {
            if (strcmp (data_ptr[i+index.syn], "") != 0)
                NFAput_string (&data.data[j], data_ptr[i+index.syn]);
            else
                NFAput_string (&data.data[j], data_ptr[i+index.name]);
            NFAput_string (&data.data[j+1], data_ptr[i+index.dt]);
            j+=data.num_of_cols;
            }
        }

    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

       _NFMR_num ("return from SCprocess_column_form -> %d", data.sts);

        if (data.sts != FORM_CANCELED)
            {
            status = NFMput_and_validate_data (data.data, pos+2, tot_data,
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
        _NFMR_str ("%s", "Cancel from form. Return.");
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI,  NFI_W_FORM_CANCELED,  NULL,  NULL );
        return (NFI_W_FORM_CANCELED);
               }

    for (i=0, j=0; i<(attr_list->rows*attr_list->columns); i+=attr_list->columns)
        {
        if (strcmp (data_ptr[i+index.app], "NFM") != 0)
            {
            for (k=0; k<data_list->columns; ++k)
                {
                if (strcmp (dcolumn_ptr[k], data_ptr[i+index.name]) == 0)
                    {
                    status = MEMwrite_data (data_list, data.data[j+2], 1, k+1);
                    if (status != MEM_S_SUCCESS)
                     {
                       NFMerr_ret (status);
                       NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);

                        free (data.data);
                        _NFMR_num( "NFMuser_attr : MEMwrite_data : <0x%.8x>", status);

                        return (NFM_E_FAILURE);
                        }
                    j+=data.num_of_cols;
                    }
                }
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    _NFMR_str ("%s", "Exit NFMuser_attr");

    return (NFM_S_SUCCESS);
}



