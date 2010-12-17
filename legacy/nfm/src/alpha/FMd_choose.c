#include "machine.h"
#include "NFMdef.h"
#include "NFMdisplays.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMRlist.h"

long NFAdisplay_elements (struct_data, list_struct)
    struct  SCfree_data_st *struct_data;
    NFMlist list_struct;

{
long   status;
long   save_status;
long   NFAget_display_information ();
long   NFAnew_display_simple_data ();
struct SCfree_data_st *data;
MEMptr syn_list  = NULL;
MEMptr data_list = NULL;
static char *fname = "NFAdisplay_elements";

    SCdisplay_msg ("Working..");

    data = struct_data;

    status = NFAget_display_information (list_struct, &syn_list, &data_list);
    if ((status != NFI_S_SUCCESS) && (status != NFM_I_NO_MORE_BUFFERS))
        {
        MEMclose (&syn_list);
	MEMclose (&data_list);
        _NFIdebug(( fname, "NFAget_display_information : <0x%.8x>\n", status));
        return (status);
        }

    save_status = status;

    _NFIdebug(( fname, "Title <%s>\n", list_struct.title ));

    status = NFAnew_display_simple_data (data, syn_list, data_list,
		      list_struct.select_set, list_struct.title );
    if( status != NFI_S_SUCCESS )
    {
	MEMclose( &syn_list );
	MEMclose( &data_list );
        return (status);
    }

    MEMclose( &syn_list );
    MEMclose( &data_list );

    return( save_status );
}


long NFAget_display_information (list, syn_list, data_list)
    NFMlist list;
    MEMptr  *syn_list;
    MEMptr  *data_list;

{
long    status;
long    find_status;
static char *fname = "NFAget_display_information";

    SCdisplay_msg ("Working..");

    switch (list.rep_type)
        {
        case DSP_NODES :
            status = NFMRdisplay_nodes (list.search, list.sort, 
			list.select_type, syn_list, data_list );
            _NFIdebug(( fname, "NFMRlist_nodes : <0x%.8x>\n", status));
            break;

        case DSP_STORAGE_AREAS :
            status = NFMRdisplay_storage_areas (list.search, list.sort, 
			list.select_type, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_storage_areas : <0x%.8x>\n",
			status));
            break;

        case DSP_WORKING_AREAS :
            status = NFMRdisplay_working_areas (list.search, list.sort, 
			list.select_type, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_working_areas : <0x%.8x>\n",
			status));
            break;

        case DSP_USERS :
            status = NFMRdisplay_users ( list.search, list.sort,
                        list.select_type, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_users : <0x%.8x>\n", status));
            break;

        case DSP_CATALOGS :
            status = NFMRdisplay_catalogs (list.search, list.sort, 
			list.select_type, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_catalogs : <0x%.8x>\n", status));
            break;

        case DSP_ITEMS :
            status = NFMRdisplay_items (list.catalog, list.search, list.sort,
			list.select_type, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_items : <0x%.8x>\n", status));
	    find_status = NFAfind_attributes( data_list );
	    _NFIdebug(( fname, "NFAfind_attributes <0x%.8x>\n", find_status ));
            break;

        case DSP_ITEMS_PARTIAL :
            status = NFMRdisplay_items_partial (list.catalog, list.search,
		 list.sort, list.select_type, list.rows, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_items_partial <0x%.8x>\n", 
		 status));
	    find_status = NFAfind_attributes( data_list );
	    _NFIdebug(( fname, "NFAfind_attributes <0x%.8x>\n", find_status ));
            break;

        case DSP_ITEM_FILES :
            status = NFMRdisplay_item_files (list.catalog,list.item, list.rev,
			list.search, list.sort, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_item_files : <0x%.8x>\n", status));
            break;

        case DSP_WORKFLOWS :
            status = NFMRdisplay_workflows (list.search, list.sort, 
			list.select_type, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_workflows : <0x%.8x>\n", status));
            break;

        case DSP_ACLS :
            status = NFMRdisplay_acls (list.wf_name, list.search, list.sort, 
			list.select_type, syn_list, data_list );
            _NFIdebug(( fname, "NFMRdisplay_acls : <0x%.8x>\n", status));
            break;

        case DSP_CLASSES :
            status = NFMRdisplay_classes (list.wf_name, list.search, list.sort,
			list.select_type, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_classes : <0x%.8x>\n", status));
            break;

        case DSP_SEARCH :
            status = NFMRdisplay_querys ( "W", list.search, list.sort,
			list.select_type, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_reports : <0x%.8x>\n", status));
            break;

        case DSP_SORT :
            status = NFMRdisplay_querys ("O", list.search, list.sort, 
			list.select_type, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_reports : <0x%.8x>\n", status));
            break;

        case DSP_PROGRAMS :
            status = NFMRdisplay_programs (list.search, list.sort, 
			list.select_type, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_programs : <0x%.8x>\n", status));
            break;

        case DSP_TRANSITIONS :
            status = NFMRdisplay_transitions (list.wf_name, list.search, 
			list.sort, list.select_type, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_transitions : <0x%.8x>\n",status));
            break;

        case DSP_ACLUSERS :
            status = NFMRdisplay_aclusers (list.acl_name, list.search, 
			list.sort, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_aclusers : <0x%.8x>\n", status));
            break;

        case DSP_SIGNOFF_USERS :
            status = NFMRdisplay_signoff_users (list.acl_name, list.search,
                        list.sort, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_signoff_users : <0x%.8x>\n",
			status));
            break;

        case DSP_SO_ON_ITEM:
            status = NFMRdisplay_so_on_item(list.catalog, list.item, list.rev,
                        syn_list, data_list) ;
            _NFIdebug(( fname, "NFMRsignoff_on_item : <0x%.8x>\n",status));
            break ;

        case DSP_SO_HISTORY :
            status = NFMRdisplay_so_history (list.catalog, list.item, list.rev,
                        syn_list, data_list) ;
            _NFIdebug(( fname, "NFMRdisplay_so_history : <0x%.8x>\n",status));
            break ;

        case DSP_PROJECTS :
            status = NFMRdisplay_projects (list.search, list.sort, 
			list.select_type, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_projects : <0x%.8x>\n", status));
            break;

        case DSP_PROJECT_MEMBERS :
            /* list.catalog is actually the project name */
            status = NFMRdisplay_project_members (list.catalog, list.search, 
			list.sort, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_project_members : <0x%.8x>\n", 
			status));
            break;

        case DSP_PROJECT_MEMBERS_PARTIAL :
            status = NFMRdisplay_project_members_partial (list.catalog, 
		 list.search, list.sort, list.rows, syn_list, data_list);
            _NFIdebug((fname, "NFMRdisplay_project_members_partial <0x%.8x>\n",
		 status));
            break;

        case DSP_WHERE_USED_PROJECT :
            /* list.catalog is actually the project name */
            status = NFMRdisplay_where_used_project (list.catalog, list.item,
			list.rev, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_where_used_project : <0x%.8x>\n", 
			status));
            break;

        case DSP_CATALOG_ACL_MAP :
            status = NFMRdisplay_catalog_acl_mapping (list.catalog,list.search,
                        list.sort, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_catalog_acl_mapping : <0x%.8x>\n",
			status));
            break;

        case DSP_CATALOG_SA_MAP :
            status = NFMRdisplay_catalog_sa_mapping (list.catalog, list.search,
                        list.sort, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_catalog_sa_mapping : <0x%.8x>\n", 
			status));
            break;

        case DSP_PROJECT_ACL_MAP :
            /* list.catalog is actually the project name */
            status = NFMRdisplay_project_acl_mapping (list.catalog,list.search,
                        list.sort, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_project_acl_mapping : <0x%.8x>\n",
			status));
            break;

        case DSP_PROJECT_SA_MAP :
            /* list.catalog is actually the project name */
            status = NFMRdisplay_project_sa_mapping (list.catalog, list.search,
                        list.sort, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_project_sa_mapping : <0x%.8x>\n",
			status));
            break;

        case DSP_SETS :
            status = NFMRdisplay_sets (list.catalog, list.search, list.sort, 
			syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_sets : <0x%.8x>\n", status));
            find_status = NFAfind_attributes( data_list );
            _NFIdebug(( fname, "NFAfind_attributes <0x%.8x>\n", find_status ));
            break;

        case DSP_SET_MEMBERS :
            status = NFMRdisplay_set_members (list.catalog, list.item,
			list.rev, list.search, list.sort, syn_list, data_list);
            _NFIdebug((fname, "NFMRdisplay_set_members : <0x%.8x>\n", status));
            break;

        case DSP_SET_MEMBERS_PARTIAL :
            status = NFMRdisplay_set_members_partial (list.catalog, list.item,
		list.rev, list.search, list.sort, list.rows, 
		syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_set_members_partial : <0x%.8x>\n",
		 status));
            break;

        case DSP_WHERE_USED_SET :
            status = NFMRdisplay_where_used_set (list.catalog, list.item,
			list.rev, syn_list, data_list);
            _NFIdebug((fname, "NFMRdisplay_where_used_set : <0x%.8x>\n", 
			status));
            break;

        case DSP_ARCHIVES :
            status = NFMRdisplay_archives (list.search, list.sort, 
			syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_archives : <0x%.8x>\n", status));
            break;

        case DSP_ARCHIVE_FLAGS :
            status = NFMRdisplay_archive_flags (list.search, list.sort, 
			syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_archive_flags : <0x%.8x>\n", 
			status));
            break;

        case DSP_BACKUP_FLAGS :
            status = NFMRdisplay_backup_flags (list.search, list.sort, 
			syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_backup_flags : <0x%.8x>\n", 
			status));
            break;

        case DSP_RESTORE_FLAGS :
            status = NFMRdisplay_restore_flags (list.search, list.sort, 
			syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_restore_flags : <0x%.8x>\n", 
			status));
            break;

        case DSP_DELETE_FLAGS :
            status = NFMRdisplay_delete_flags (list.search, list.sort, 
			syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_delete_flags : <0x%.8x>\n", 
			status));
            break;

        case DSP_LOCAL_FILES :
            status = NFMRdisplay_local_files ( NFMworking, list.search, 
			list.sort, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_local_files : <0x%.8x>\n", 
			status));
            break;

        case DSP_SAVESETS :
            status = NFMRdisplay_savesets ( list.search, 
			list.sort, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_savesets : <0x%.8x>\n", 
			status));
            break;

        case DSP_ITEMS_ON_TAPE :
            status = NFMRdisplay_items_on_tape ( list.search, 
			list.sort, syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_items_on_tape : <0x%.8x>\n", 
			status));
            break;

        case DSP_LABELS :
            status = NFMRdisplay_labels ( list.search, list.sort, 
			syn_list, data_list);
            _NFIdebug(( fname, "NFMRdisplay_labels : <0x%.8x>\n", 
			status));
            break;

        default :
            _NFIdebug(( fname, "Unknown Entity = <%ld>",
                       list.rep_type));
            status = NFI_E_FAILURE;
            break;
        }
    if( status != NFM_S_SUCCESS )
        return (status);

    return (NFI_S_SUCCESS);
}


long NFAnew_display_simple_data (struct_data, syn_list, data_list, select_set,
				 title)
    struct SCfree_data_st *struct_data;
    MEMptr syn_list;
    MEMptr data_list;
    int    select_set;
    char   *title;
{
long   status;
int    pos;
int    i;
int    j;
int    tot_data;
int    max_len;
int    no_row_selected;
char   **data_ptr;
char   **column_ptr;
char   **format_ptr;
char   **syn_ptr;
struct SCfree_data_st *data;
static char *fname = "NFAnew_display_simple_data";

    _NFIdebug(( fname, "Title <%s>\n", title ));

    data = struct_data;

    SCdisplay_msg ("Working..");

    status = MEMbuild_array (syn_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI,NFI_E_MEMORY,"%s%s","NFMdisplay_simple_data",
			"MEMbuild_array");
        return (NFI_E_MEMORY);
        }

    syn_ptr = (char **) syn_list->data_ptr;

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI,NFI_E_MEMORY,"%s%s","NFMdisplay_simple_data",
			"MEMbuild_array");
        return (NFI_E_MEMORY);
        }
/*  here i should check for data_list = no rows and if it is no rows then
    return success */
       if (data_list->rows == 0)
        {
         status = NFI_S_SUCCESS;
         ERRload_struct(NFI, NFI_S_SUCCESS, NULL, NULL);
         _NFIdebug((fname,  " the status is <%d>\n", status));
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
    for (i=0,j=0; i<(syn_list->columns*syn_list->rows); 
		i+=syn_list->columns,++j)
        {
        max_len = 0;
        status = NFAcol_width (syn_ptr[i], format_ptr[j], &max_len);
        if (max_len > 25)
            max_len = 25;
        data->col_size[j] = max_len;
        }

    pos = 0;
    data->col_pos = (int *) malloc (data->num_of_cols * sizeof (int));
    memset (data->col_pos, 0 , (data->num_of_cols * sizeof (int)));
    for (i=0; i<data->num_of_cols; ++i)
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
    for (i=0; i<data->num_of_cols; ++i)
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
    NFAput_string (&data->h1_data[0], "");
    
    data->h2_data = (char **) malloc (data->num_of_cols * (sizeof (char *)));
    memset (data->h2_data, NULL, data->num_of_cols * (sizeof (char *)));
    for (i=0,j=0; i<data->num_of_cols; ++i,j+=syn_list->columns)
        NFAput_string (&data->h2_data[i], syn_ptr[j]);
    
    data->h3_data = (char **) malloc (sizeof (char *));
    memset (data->h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data->h3_data[0], "");
    
    strcpy (data->title, title);

    data->select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data->select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data->data = (char **) malloc (tot_data * sizeof (char *));
    memset (data->data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        {
        NFAput_string (&data->data[i], data_ptr[i]);
        }

    /* process free form */
    status = SCprocess_free_form (data, NFMprint_file);

    if (data->sts == FORM_CANCELED)
        {
        NFAfree_list (data->data, data->num_of_rows, data->num_of_cols);
        free (data->data);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=0; i<data->num_of_rows; ++i)
        {
        if (data->select_set[i] == 1)
            {
            no_row_selected = FALSE;
            break;
            }
        }
/*  Taken out because it shouldn't really be an error if nothing
 *  is selected.
 
    if( no_row_selected )
	return( NFI_E_CREATE_SELECT_LIST );
 */

    return (NFI_S_SUCCESS);
}



