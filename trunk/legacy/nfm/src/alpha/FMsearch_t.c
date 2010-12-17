#include "machine.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMRlist.h"

/* This file contains all the OS specific type definitions */
/* M. S. Sai Prasad.  9 Dec 93.                            */

#include "NFMporttypes.h"

long NFAsearch_attr_form (form, c_attr_buffer, f_attr_buffer)
    struct SCfree_data_st *form;
    MEMptr c_attr_buffer;
    MEMptr f_attr_buffer;
{
int  i, j, k;
int  tot_data;
int  count;
long status;
char **c_column_ptr;
char **c_format_ptr;
char **c_data_ptr;
char **f_column_ptr;
char **f_format_ptr;
char **f_data_ptr;
struct SCfree_data_st *data;
NDXptr c_index;
NDXptr f_index;
static char *fname = "NFAsearch_attr_form";

    data = form;

    status = MEMbuild_array (c_attr_buffer);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild_array");
        return (NFI_E_MEMORY);
        }

    if (_NFMdebug_st.NFIdebug_on)
    {
        MEMprint_buffers ("CATALOG ATTR LIST", c_attr_buffer,_NFMdebug_st.NFIdebug_file);
        MEMprint_buffers ("FILE_CAT ATTR LIST", c_attr_buffer,_NFMdebug_st.NFIdebug_file);
    }

    c_column_ptr = (char **) c_attr_buffer->column_ptr;
    c_format_ptr = (char **) c_attr_buffer->format_ptr;
    c_data_ptr = (char **) c_attr_buffer->data_ptr;
        
    NFMRfill_index (c_attr_buffer, &c_index);

    status = MEMbuild_array (f_attr_buffer);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild_array");
        return (NFI_E_MEMORY);
        }

    f_column_ptr = (char **) f_attr_buffer->column_ptr;
    f_format_ptr = (char **) f_attr_buffer->format_ptr;
    f_data_ptr = (char **) f_attr_buffer->data_ptr;
        
    NFMRfill_index (f_attr_buffer, &f_index);
        
    count = 0;
    for (i=0; i<c_attr_buffer->rows*c_attr_buffer->columns;i+=c_attr_buffer->columns)
        {
        if (strcmp (c_data_ptr[i+c_index.r], "Y") == 0)
            ++count;
        }

    for (i=0; i<f_attr_buffer->rows*f_attr_buffer->columns;i+=f_attr_buffer->columns)
        {
        if (strcmp (f_data_ptr[i+f_index.r], "Y") == 0)
            ++count;
        }

    _NFIdebug(( fname, "Total rows       : <%d>\n", 
		c_attr_buffer->rows+f_attr_buffer->rows));
    _NFIdebug(( fname, "Displayable fields : <%d>\n", count));

    data->num_of_rows = count + 1;
    data->num_of_cols = 2;
    tot_data = data->num_of_cols * data->num_of_rows;
    data->freeze_rows_count = 0;
    data->freeze_cols_count = 0;
    data->select_set_expected = SELECT_SET_SINGLE_ROW;
    data->max_indent = 0;

    data->col_size = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_size, 0, (data->num_of_cols * sizeof (int)));
    data->col_size[0] = 20;
    data->col_size[1] = 12;
    
    sprintf (data->title, "Choose Attribute");

    data->col_pos = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_pos, 0, (data->num_of_cols * sizeof (int)));
    data->col_pos[0] = 0;
    data->col_pos[1] = 22;

    data->col_just = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_just, LEFT_JUSTIFIED, (data->num_of_cols * sizeof (int)));

    data->select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data->select_set, 0, (tot_data * sizeof (int)));

    data->h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h1_pos, 0, sizeof (int) + 1);
    data->h1_pos[0] = 0;
    data->h1_pos[1] = -1;
    
    data->h2_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h2_pos, 0, sizeof (int) + 1);
    data->h2_pos[0] = 0;
    data->h2_pos[1] = -1;
    
    data->h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h3_pos, 0, sizeof (int) + 1);
    data->h3_pos[0] = 0;
    data->h3_pos[1] = -1;
    
    /* allocate and initialize space to store data */

    data->h1_data = (char **) malloc (sizeof (char *));
    memset (data->h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h1_data[0], "");
    
    data->h2_data = (char **) malloc (sizeof (char *));
    memset (data->h2_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h2_data[0], "");
    
    data->h3_data = (char **) malloc (sizeof (char *));
    memset (data->h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h3_data[0], "");
    
    data->data = (char **) malloc (tot_data * sizeof (char *));
    memset (data->data, NULL, (tot_data * sizeof (char *)));

    /* put open-paren into data structure */
    NFAput_string (&data->data[0], "( ");
    NFAput_string (&data->data[1], "(open paren)");
/* TVK - 11/03 removed \ in above as shown in below line : warning avoided */


/*
    NFAput_string (&data->data[1], "\(open paren\)");
*/

    
    /* put "attr_name" data in data structure */        
    /* put "data_type" data in data structure */        
    k=2;
    for (i=0; i<c_attr_buffer->rows; ++i)
        {
        j = i * c_attr_buffer->columns;

     /* can only use readable attributes */
	if (strcmp (c_data_ptr[j+c_index.r], "Y" ) == 0)
	    {
            if (strcmp (c_data_ptr[j+c_index.syn], "") == 0)
                NFAput_string (&data->data[k], c_data_ptr[j+c_index.name]);
            else
                NFAput_string (&data->data[k], c_data_ptr[j+c_index.syn]);

            NFAput_string (&data->data[k+1], c_data_ptr[j+c_index.dt]);
	    k += data->num_of_cols;
	    }
        }
    for (i=0; i<f_attr_buffer->rows; ++i)
        {
        j = i * f_attr_buffer->columns;

     /* can only use readable attributes */
	if (strcmp (f_data_ptr[j+f_index.r], "Y" ) == 0)
	    {
            if (strcmp (f_data_ptr[j+f_index.syn], "") == 0)
                NFAput_string (&data->data[k], f_data_ptr[j+f_index.name]);
            else
                NFAput_string (&data->data[k], f_data_ptr[j+f_index.syn]);

            NFAput_string (&data->data[k+1], f_data_ptr[j+f_index.dt]);
	    k += data->num_of_cols;
	    }
        }

    return (NFI_S_SUCCESS);
}



long NFAsearch_oper1_form (form)
    struct SCfree_data_st *form;

{
int  tot_data;
struct SCfree_data_st *data;

    data = form;

    /* set up operator1 form -> oper1 */
    
    data->num_of_rows = 8;
    data->num_of_cols = 2;
    tot_data = data->num_of_cols * data->num_of_rows;
    data->freeze_rows_count = 0;
    data->freeze_cols_count = 0;
    data->select_set_expected = SELECT_SET_SINGLE_ROW;
    data->max_indent = 0;

    data->col_size = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_size, 0, (data->num_of_cols * sizeof (int)));
    data->col_size[0] = 8;
    data->col_size[1] = 28;
    
    sprintf (data->title, "Choose Operator");

    data->col_pos = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_pos, 0, (data->num_of_cols * sizeof (int)));
    data->col_pos[0] = 0;
    data->col_pos[1] = 4;

    data->col_just = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_just, LEFT_JUSTIFIED, (data->num_of_cols * sizeof (int)));

    data->select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data->select_set, 0, (tot_data * sizeof (int)));

    data->h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h1_pos, 0, sizeof (int) + 1);
    data->h1_pos[0] = 0;
    data->h1_pos[1] = -1;
    
    data->h2_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h2_pos, 0, sizeof (int) + 1);
    data->h2_pos[0] = 0;
    data->h2_pos[1] = -1;
    
    data->h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h3_pos, 0, sizeof (int) + 1);
    data->h3_pos[0] = 0;
    data->h3_pos[1] = -1;
    
    /* allocate and initialize space to store data */

    data->h1_data = (char **) malloc (sizeof (char *));
    memset (data->h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h1_data[0], "");
    
    data->h2_data = (char **) malloc (sizeof (char *));
    memset (data->h2_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h2_data[0], "");
    
    data->h3_data = (char **) malloc (sizeof (char *));
    memset (data->h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h3_data[0], "");
    
    data->data = (char **) malloc (tot_data * sizeof (char *));
    memset (data->data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data->data[0], "=");
    NFAput_string (&data->data[1], "(Equal)");
    NFAput_string (&data->data[2], "!=");
    NFAput_string (&data->data[3], "(Not Equal)");
    NFAput_string (&data->data[4], ">");
    NFAput_string (&data->data[5], "(Greater than)");
    NFAput_string (&data->data[6], ">=");
    NFAput_string (&data->data[7], "(Greater than or equal to)");
    NFAput_string (&data->data[8], "<");
    NFAput_string (&data->data[9], "(Less than)");
    NFAput_string (&data->data[10], "<=");
    NFAput_string (&data->data[11], "(Less than or equal to)");
    NFAput_string (&data->data[12], "LIKE");
    NFAput_string (&data->data[13], "(Wildcard - \"_\" or \"*\")");
/* TVK - 11/03 removed \ in front of * as seen below : warning avoided */

/*
    NFAput_string (&data->data[13], "(Wildcard - \"_\" or \"\*\")");
*/


    NFAput_string (&data->data[14], "NOT LIKE");
    NFAput_string (&data->data[15], "(Wildcard - \"_\" or \"*\")");
/* TVK - 11/03 removed \ in front of * as seen below : warning avoided */

/*
    NFAput_string (&data->data[15], "(Wildcard - \"_\" or \"\*\")");
*/

     
    return (NFI_S_SUCCESS);
}

/********************************************************************/

long NFAsearch_oper2_form (form)
    struct SCfree_data_st *form;

{
int  tot_data;
struct SCfree_data_st *data;

    data = form;

    /* set up operator2 form -> oper2 */
    
    data->num_of_rows = 4;
    data->num_of_cols = 2;
    tot_data = data->num_of_cols * data->num_of_rows;
    data->freeze_rows_count = 0;
    data->freeze_cols_count = 0;
    data->select_set_expected = SELECT_SET_SINGLE_ROW;
    data->max_indent = 0;

    data->col_size = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_size, 0, (data->num_of_cols * sizeof (int)));
    data->col_size[0] = 3;
    data->col_size[1] = 14;
    
    sprintf (data->title, "Choose Operator");

    data->col_pos = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_pos, 0, (data->num_of_cols * sizeof (int)));
    data->col_pos[0] = 0;
    data->col_pos[1] = 5;

    data->col_just = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_just, LEFT_JUSTIFIED, (data->num_of_cols * sizeof (int)));

    data->select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data->select_set, 0, (tot_data * sizeof (int)));

    data->h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h1_pos, 0, sizeof (int) + 1);
    data->h1_pos[0] = 0;
    data->h1_pos[1] = -1;
    
    data->h2_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h2_pos, 0, sizeof (int) + 1);
    data->h2_pos[0] = 0;
    data->h2_pos[1] = -1;
    
    data->h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h3_pos, 0, sizeof (int) + 1);
    data->h3_pos[0] = 0;
    data->h3_pos[1] = -1;
    
    /* allocate and initialize space to store data */

    data->h1_data = (char **) malloc (sizeof (char *));
    memset (data->h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h1_data[0], "");
    
    data->h2_data = (char **) malloc (sizeof (char *));
    memset (data->h2_data, NULL, sizeof (char *));
    NFAput_string (&data->h2_data[0], "");
    
    data->h3_data = (char **) malloc (sizeof (char *));
    memset (data->h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h3_data[0], "");
    
    data->data = (char **) malloc (tot_data * sizeof (char *));
    memset (data->data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data->data[0], ") ");
    NFAput_string (&data->data[1], "(close paren)");
    NFAput_string (&data->data[2], "AND");
    NFAput_string (&data->data[4], "OR");
    NFAput_string (&data->data[6], "END");
    NFAput_string (&data->data[7], "(done)");
      
    return (NFI_S_SUCCESS);
}

/*******************************************************************/

    /* set up search form -> form */

long NFAsearch_form (form, form_rows, old_tot_data)
    struct SCcolumn_data_st *form;
    int    form_rows;
    int    *old_tot_data;

{
int  i;
int  tot_data;
struct SCcolumn_data_st *data;

    data = form;

    data->num_of_rows = form_rows;
    data->num_of_cols = 6;
    tot_data = data->num_of_rows * data->num_of_cols;
    *old_tot_data = tot_data;
    data->freeze_rows_count = 0;
    data->select_set_expected = FALSE;

    data->col_width = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_width, 0, (data->num_of_cols * sizeof (int)));
    data->col_width[0] = 5;
    data->col_width[1] = 20;
    data->col_width[2] = 5;
    data->col_width[3] = 20;
    data->col_width[4] = 5;
    data->col_width[5] = 5;

    data->new_rows_expected = FALSE;
    sprintf (data->title, "Search Criteria");

    data->selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data->selectable, 0, (tot_data * sizeof (int)));
    for (i=3; i<tot_data; i+=data->num_of_cols)
        {
        data->selectable[i] = 1;
        }

    data->hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data->hidden, 0, (tot_data * sizeof (int)));

    data->data = (char **) malloc (tot_data * sizeof (char *));
    memset (data->data, NULL, (tot_data * sizeof (char *)));

    return (NFI_S_SUCCESS);
}

long NFAreset_search_form (form, form_rows, old_tot_data, new_tot_data)
    struct SCcolumn_data_st *form;
    int    form_rows;
    int    *old_tot_data;
    int    *new_tot_data;

{
int  i;
struct SCcolumn_data_st *data;

    data = form;

    data->num_of_rows = form_rows;

    *new_tot_data = data->num_of_rows * data->num_of_cols;

    /*  Porting for solaris. Fixed parameter type for realloc().  */
    /*  M.S. Sai Prasad.  9 Dec 93.                               */

    data->selectable = (int *) realloc (data->selectable,  (NFM_SIZE_T)
                                        (*old_tot_data * sizeof (int)) +
                                        (data->num_of_cols * sizeof (int)));

    memset (data->selectable, 0, (*new_tot_data * sizeof (int)));

    for (i=(*new_tot_data)-3; i<(*new_tot_data); i+=data->num_of_cols)
        {
        data->selectable[i] = 1;
        }
  

    /*  Porting for solaris. Fixed parameter type for realloc().  */
    /*  M.S. Sai Prasad.  9 Dec 93.                               */

    data->hidden = (int *) realloc (data->hidden, (NFM_SIZE_T) 
                                    (*old_tot_data * sizeof (int)) +
                                    (data->num_of_cols * sizeof (int)));

    memset (data->hidden, 0, (*new_tot_data * sizeof (int)));
 

    /*  Porting for solaris. Fixed parameter type for realloc().  */
    /*  M.S. Sai Prasad.  9 Dec 93.                               */

    data->data = (char **) realloc (data->data, (NFM_SIZE_T) 
                                    (*old_tot_data * sizeof (char *)) +
                                    (data->num_of_cols * sizeof (char *)));
    for (i=(*old_tot_data); i<(*new_tot_data); ++i)
        {
        data->data[i] = 0;
        }

    *old_tot_data = *new_tot_data;

    return (NFI_S_SUCCESS);
}

/*********************************************************************/

long NFAclear_form_selects (form)
    struct SCfree_data_st *form;

{
struct SCfree_data_st *data;

    data = form;

    memset (data->select_set, 0,
            (data->num_of_rows * data->num_of_cols * sizeof (int)));

    return (NFI_S_SUCCESS);
}


long NFAverify_row_selected (form, select_index)
    struct SCfree_data_st form;
    int    *select_index;

{
int    i;
int    ROW_SELECTED;
struct SCfree_data_st data;

    data = form;

    if (data.sts == FORM_CANCELED)
        return (NFI_W_COMMAND_CANCELLED);

    ROW_SELECTED = FALSE;
        
    /* make sure that a row has been selected */
    for (i=0; i<data.num_of_rows; ++i)
        {
        if (data.select_set[i] == 1)
            {
            ROW_SELECTED = TRUE;
            *select_index = i;
            break;
            }
        }

    if (ROW_SELECTED)
        return (TRUE);
    else
        return (FALSE);
}

long NFAfind_report_name (rep_type, rep_name, rep_desc)
    char *rep_type;
    char *rep_name;
    char *rep_desc;

{
int  tot_data;
long status;
int  FORM_FILLED = FALSE;
struct SCcolumn_data_st data;
char rep_string[50];
static char *fname = "NFAfind_report_name";
     
    data.num_of_rows = 2;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 30;
    data.col_width[1] = 40;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "Enter %s Name and Description", rep_type);

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[1] = 1;
    data.selectable[3] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    strcpy (rep_string, rep_type);
    strcat (rep_string, " Name");
    NFAput_string (&data.data[0], rep_string);
   
    strcpy (rep_string, rep_type);
    strcat (rep_string, " Description");
    NFAput_string (&data.data[2], rep_string);
    NFAput_string (&data.data[3], "" );

    strcpy (rep_string, "NFM:  Must Enter ");
    strcat (rep_string, rep_type);
    strcat (rep_string, " Name.");

    /* process column form until an Report Name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        if (data.sts != FORM_CANCELED)
            {
            status = NFAvalidate_string ("char(20)", data.data[1]);
	    _NFIdebug(( fname, "Rep Name <%s>\n", data.data[1] ));
            if( (strcmp (data.data[1], "") == 0) || 
	        (strlen( data.data[1]) == 0 ) || (data.data[1] == NULL))
                {
                FORM_FILLED = FALSE;
                SCdisplay_msg (rep_string);
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

    strcpy (rep_name, data.data[1]);
    if( strcmp( data.data[3], "" ) == 0 )
    {
	strcpy( rep_desc, " " );
	_NFIdebug(( fname, "%s\n", "Report Description is empty" ));
    }
    else
    {
	strcpy( rep_desc, data.data[3] );
	_NFIdebug(( fname, "Report Description is <%s>\n", data.data[3] ));
    }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    return (NFI_S_SUCCESS);
}


long NFAfind_report_info (rep_name, file_name)
    char *rep_name;
    char *file_name;

{
int  tot_data;
long status;
int  FORM_FILLED = FALSE;
struct SCcolumn_data_st data;
     
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
    sprintf (data.title, "%s", "Enter Report Name and Format File Name");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[1] = 1;
    data.selectable[3] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Report Name");
    NFAput_string (&data.data[2], "Format File Name");

    /* process column form until an Report File Name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        if (data.sts != FORM_CANCELED)
            {
            status = NFAvalidate_string ("char(20)", data.data[1]);

            status = NFAvalidate_string ("char(50)", data.data[3]);

                 if (strcmp (data.data[1], "") == 0)
                     {
                     FORM_FILLED = FALSE;
                     SCdisplay_msg ("NFM:  Must Enter Report Name.");
                     }
            else if (strcmp (data.data[3], "") == 0)
                     {
                     FORM_FILLED = FALSE;
                     SCdisplay_msg ("NFM:  Must Format File Name.");
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

    strcpy (rep_name, data.data[1]);
    strcpy (file_name, data.data[3]);

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    return (NFI_S_SUCCESS);
}


long NFAsort_attr_form (form, c_attr_buffer)
    struct SCfree_data_st *form;
    MEMptr c_attr_buffer;

{
int  i, j, k;
int  tot_data;
int  count;
long status;
char **column_ptr;
char **format_ptr;
char **data_ptr;
struct SCfree_data_st *data;
NDXptr index;
static char *fname = "NFAdefine_sort";

    data = form;

    status = MEMbuild_array (c_attr_buffer);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFAsort_attr_form",
			"MEMbuild_array");
        return (status);
        }

    column_ptr = (char **) c_attr_buffer->column_ptr;
    format_ptr = (char **) c_attr_buffer->format_ptr;
    data_ptr = (char **) c_attr_buffer->data_ptr;
        
    NFMRfill_index (c_attr_buffer, &index);
        
    count = 0;
    for (i=0;i<c_attr_buffer->rows*c_attr_buffer->columns; i+=c_attr_buffer->columns)
        {
        if (strcmp (data_ptr[i+index.r], "Y") == 0)
            ++count;
        }

    _NFIdebug(( fname, "Displayable fields : <%d>\n", count));

    data->num_of_rows = count;
    data->num_of_cols = 2;
    tot_data = data->num_of_cols * data->num_of_rows;
    data->freeze_rows_count = 0;
    data->freeze_cols_count = 0;
    data->select_set_expected = SELECT_SET_MULTI_ROW;
    data->max_indent = 0;

    data->col_size = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_size, 0, (data->num_of_cols * sizeof (int)));
    data->col_size[0] = 15;
    data->col_size[1] = 12;
    
    sprintf (data->title, "Choose Attribute/s For Ordering");

    data->col_pos = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_pos, 0, (data->num_of_cols * sizeof (int)));
    data->col_pos[0] = 0;
    data->col_pos[1] = 17;

    data->col_just = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_just, LEFT_JUSTIFIED, (data->num_of_cols * sizeof (int)));

    data->select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data->select_set, 0, (tot_data * sizeof (int)));

    data->h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h1_pos, 0, sizeof (int) + 1);
    data->h1_pos[0] = 0;
    data->h1_pos[1] = -1;
    
    data->h2_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h2_pos, 0, sizeof (int) + 1);
    data->h2_pos[0] = 0;
    data->h2_pos[1] = -1;
    
    data->h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data->h3_pos, 0, sizeof (int) + 1);
    data->h3_pos[0] = 0;
    data->h3_pos[1] = -1;
    
    /* allocate and initialize space to store data */

    data->h1_data = (char **) malloc (sizeof (char *));
    memset (data->h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h1_data[0], "");
    
    data->h2_data = (char **) malloc ((data->num_of_cols * sizeof (char *)));
    memset (data->h2_data, NULL, ((data->num_of_cols * sizeof (char *))));
    NFAput_string (&data->h2_data[0], "");
    
    data->h3_data = (char **) malloc (sizeof (char *));
    memset (data->h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h3_data[0], "");
    
    data->data = (char **) malloc (tot_data * sizeof (char *));
    memset (data->data, NULL, (tot_data * sizeof (char *)));

    /* put "attr_name" data in data structure */        
    /* put "data_type" data in data structure */        
    k=0;
    for (i=0; i<c_attr_buffer->rows; ++i)
        {
        j = i * c_attr_buffer->columns;

	if (strcmp (data_ptr[j+index.r], "Y" ) == 0)
    	    {
            if (strcmp (data_ptr[j+index.syn], "") == 0)
                NFAput_string (&data->data[k], data_ptr[j+index.name]);
            else
                NFAput_string (&data->data[k], data_ptr[j+index.syn]);
 
            NFAput_string (&data->data[k+1], data_ptr[j+index.dt]);
	    k+=data->num_of_cols;
	    }
        }

    return (NFI_S_SUCCESS);
}



