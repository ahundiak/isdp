#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "NFMschema.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMRlist.h"
#include "NFMdisplays.h"
#include "ERR.h"
#include "NFIcommands.h"
#include "NFIerrordef.h"
#include "DEBUG.h"

extern long sqlstatus;

long ADMchoose_elements (struct_data, list_struct)
    struct SCfree_data_st *struct_data;
    NFMlist list_struct;

{
long   status;
long   ADMget_display_info();
long   ADMdisplay_data ();
struct SCfree_data_st *data;
MEMptr syn_list = NULL;
MEMptr data_list = NULL;

static char *fname = "ADMchoose_elements";

    _NFIdebug ((fname, "ENTER\n"));

    SCdisplay_msg ("Working..");

    data = struct_data;

    status = ADMget_display_info (list_struct, &syn_list, &data_list);
    if (status != NFI_S_SUCCESS)
        {
        MEMclose (&syn_list);
        MEMclose (&data_list);
        _NFMdebug ((fname, "ADMget_display_info : <0x%.8x>\n", status));
        return (status);
        }

    _NFIdebug(( fname, "Title <%s>\n", list_struct.title ));
    status = ADMdisplay_data (data, syn_list,data_list,
                               list_struct.select_set, list_struct.title);

    if( status != NFI_S_SUCCESS )
     {

        MEMclose( &syn_list );
        MEMclose( &data_list );
        return (status);
      }
  
        MEMclose( &syn_list );
        MEMclose( &data_list );

        return( NFI_S_SUCCESS );
}


long ADMget_display_info (list, syn_list, data_list)
    NFMlist list;
    MEMptr *syn_list;
    MEMptr *data_list;
{
int    buff_flag;
long   status;
static char *fname = "ADMget_display_info";

    _NFMdebug ((fname, "ENTER\n"));

    SCdisplay_msg ("Working..");

    switch (list.rep_type)
        {
        case DSP_CATALOGS :
            status = NFMdisplay_catalogs (list.search, list.sort, 
                         list.select_type, syn_list,data_list);
            _NFIdebug ((fname, "NFMdisplay_catalogs : <0x%.8x>\n", status));
             break;

        case DSP_ITEMS :
            status = NFMdisplay_items (list.catalog, list.search, 
                      list.sort, list.select_type, syn_list, data_list);
            _NFIdebug ((fname, "NFMdisplay_items : <0x%.8x>\n", status));
            break;

        case DSP_WORKFLOWS :
            status = NFMdisplay_workflows (list.search, list.sort, 
                         list.select_type, syn_list, data_list);
            _NFIdebug ((fname, "NFMdisplay_workflows : <0x%.8x>\n", status));
            break;

        case DSP_ACLS :
            status = NFMdisplay_acls (list.wf_name,  list.search, 
                list.sort, list.select_type, syn_list, data_list);
            _NFIdebug ((fname, "NFMdisplay_acls : <0x%.8x>\n", status));
            break;

        case DSP_PROGRAMS :
            status = NFMdisplay_programs (list.search, list.sort, 
                        list.select_type, syn_list, data_list);
            _NFIdebug ((fname, "NFMdisplay_programs : <0x%.8x>\n", status));
            break;

        case DSP_TRANSITIONS :
            status = NFMdisplay_transitions (list.wf_name,
                                          list.search, list.sort, 
                                          list.select_type, syn_list, 
                                          data_list);
            _NFIdebug ((fname, "NFMdisplay_transitions : <0x%.8x>\n", status));
            break;

        case DSP_ACLUSERS :
            status = NFMdisplay_aclusers (list.acl_name,
                                       list.search, list.sort, 
                                       syn_list, data_list);
            _NFIdebug ((fname, "NFMdisplay_aclusers : <0x%.8x>\n", status));
            break;

        default :
            _NFIdebug ((fname, "Unknown Entity : <%ld>\n", list.rep_type));
            status = NFI_E_FAILURE;
            break;
        }
    if( status != NFM_S_SUCCESS )
        return (status);

    return (NFI_S_SUCCESS);
}
/*

long ADMchoose_elements (struct_data, list_struct)
    struct SCfree_data_st *struct_data;
    NFMlist list_struct;

{
long   status;
long   ADMdisplay_data ();
struct SCfree_data_st *data;
MEMptr syn_list = NULL;
MEMptr data_list = NULL;

static char *fname = "ADMchoose_elements";

    _NFIdebug ((fname, "ENTER\n"));

    SCdisplay_msg ("Working..");

    data = struct_data;

    status = ADMget_display_info (list_struct, &syn_list, &data_list);
    if (status != NFI_S_SUCCESS)
        {
        MEMclose (&syn_list);
        MEMclose (&data_list);
        _NFMdebug ((fname, "ADMget_display_info : <0x%.8x>\n", status));
        return (status);
        }

    _NFIdebug(( fname, "Title <%s>\n", list_struct.title ));
    status = ADMdisplay_data (data, syn_list,data_list,
                               list_struct.select_set, list_struct.title);

    if( status != NFI_S_SUCCESS )
     {

        MEMclose( &syn_list );
        MEMclose( &data_list );
        return (status);
      }
  
        MEMclose( &syn_list );
        MEMclose( &data_list );
        return( NFI_S_SUCCESS );
}

*/

long ADMdisplay_data (struct_data, syn_list, data_list, select_set,
                           title)
    struct SCfree_data_st *struct_data;
    MEMptr syn_list;
    MEMptr data_list;
    int    select_set;
    char   *title;
{
long   status;
int    i, j;
int    tot_data;
int    pos = 0;
int    max_len;
int    no_row_selected = TRUE;
char   **data_ptr;
char   **column_ptr;
char   **format_ptr;
char   **syn_ptr;
struct SCfree_data_st *data;

static char *fname = "ADMdisplay_data";

    _NFIdebug ((fname, "ENTER\n"));

    data = struct_data;

    SCdisplay_msg ("Working..");

    status = MEMbuild_array (syn_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct (NFI, NFI_E_MEMORY, "%s%s", fname, 
                        "ADMdisplay_data", "MEMbuild_array");
        return (status);
        }

      syn_ptr = (char **) syn_list->data_ptr;

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
    data->select_set_expected = select_set;

    data->col_size = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_size, 0, (data->num_of_cols * sizeof (int)));
    for (i=0, j=0; i<data_list->columns; ++i)
      {
        max_len = 0;
        status = NFMcol_width (syn_ptr[i], format_ptr[i], &max_len);
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
    for (i=0, j=0; i<data->num_of_cols; ++i)
        {
        NFMput_string (&data->h2_data[i], syn_ptr[i]);
        }
    
    data->h3_data = (char **) malloc (sizeof (char *));
    memset (data->h3_data, NULL, (sizeof (char *)));
    NFMput_string (&data->h3_data[0], "");
    
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

    if (no_row_selected)
        return (NFI_E_CREATE_SELECT_LIST );
    else
        return (NFI_S_SUCCESS);
}
