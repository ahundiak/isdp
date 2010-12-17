#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

long add_project_acl_map ()

{
long   status;
int    i, k, m, n;
int    reset_no;
int    MAPS_CHOSEN = FALSE;
int    map_index=0;
struct SCfree_data_st map_data;
char   project_num[20];
char   map_num[20];
char   str[100];
char   index_num[20];
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr map_list = NULL;
NDXptr index;
static char *fname = "add_project_acl_map";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_project_acl_map (NFMuser_id, NFMproject, &attr_list,
                                        &data_list, &value_list);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    if( status != MEM_S_SUCCESS )
    {
	_NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	MEMclose( &attr_list );
	MEMclose( &data_list );
	MEMclose( &value_list );
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }
    attr_ptr = (char **) attr_list->data_ptr;

    status = MEMbuild_array (value_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    NFMRfill_index (attr_list, &index);

    /* find project number from values list */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_projectno") == 0)
            {
            status = NFAget_value_list_index (attr_ptr[i+index.list],
                        value_list, attr_ptr[i+index.name],
                        attr_ptr[i+index.syn], index_num);
            if (status != NFI_S_SUCCESS)
                {
                MEMclose (&attr_list);
                MEMclose (&value_list);
                MEMclose (&data_list);
                return (status);
                }
            strcpy (project_num, index_num);
            break;
            }
        }

    _NFIdebug ((fname, "project_num : <%s>\n", project_num));

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    /* List all mappings */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_mapno") == 0)
            {
            reset_no = atoi (attr_ptr[i+index.list]);
            _NFIdebug ((fname, "reset_no : <%ld>\n", reset_no));
	    if( reset_no == 0 )
	    {
		ERRload_struct( NFI, NFI_I_NO_VALUES, NULL,NULL );
		MEMclose( &attr_list );
		MEMclose( &data_list );
		MEMclose( &value_list );
		return( NFI_I_NO_VALUES );
	    }
            status = MEMreset_buffer_no (value_list, reset_no);
	    if( status != MEM_S_SUCCESS )
  	        {
	        _NFIdebug(( fname, "MEMreset <0x%.8x>\n", status ));
	        MEMclose( &attr_list );
	        MEMclose( &data_list );
	        MEMclose( &value_list );
	        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	        return( NFM_E_MEM );
	        }
            status = MEMsplit_copy_buffer (value_list, &map_list, 0);
	    if( status != MEM_S_SUCCESS )
	        {
	        _NFIdebug(( fname, "MEMsplit <0x%.8x>\n", status ));
	        MEMclose( &attr_list );
	        MEMclose( &data_list );
	        MEMclose( &value_list );
	        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	        return( NFM_E_MEM );
	        }
            status = MEMbuild_array (map_list);
	    if( status != MEM_S_SUCCESS )
	        {
	        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	        MEMclose( &attr_list );
	        MEMclose( &data_list );
	        MEMclose( &value_list );
	        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	        return( NFM_E_MEM );
	        }
            }
        }

    for (i=0; i<data_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], "n_mapno") == 0)
            {
            map_index = i;
            break;
            }
        }

    sprintf (map_data.title, "Choose ACLs for project \'%s\'", NFMproject);

    status = NFAexclusive_fill_free_list (data_list, map_list, map_index, 
                                          &map_data);
    
    /* 1 Mar 94. CN temp . Setting the address of column_ptr */
    column_ptr = (char **) data_list->column_ptr;

    if (status != NFI_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
	ERRload_struct( NFI, NFI_E_ALL_ACLS_MAPPED, "%s", NFMproject );
        return (status);
        }

    status = SCprocess_free_form (&map_data, NFMprint_file);
 
    /* for each selected mapping, add a row */

    for (k=0; k<map_data.num_of_rows; ++k)
        {

        /* if mapping is selected, add a row */
        if (map_data.select_set[k] == 1)
            {
            MAPS_CHOSEN = TRUE;
            m = k * map_data.num_of_cols;
            map_num[0] = 0;
            strcpy (map_num, map_data.data[m]);
            _NFIdebug ((fname, "map num  : <%s>\n", map_num));

            str[0] = 0;

            for (n=0; n<data_list->columns; ++n)
                 {
                      if (strcmp (column_ptr[n], "n_projectno") == 0)
                          strcat (str, project_num);

                 else if (strcmp (column_ptr[n], "n_mapno") == 0)
                          strcat (str, map_num);

                 else if (strcmp (column_ptr[n], "n_status") == 0)
                          strcat (str, "ADD");

                 strcat (str, "\1");
                 }

            _NFIdebug ((fname, "str : <%s>\n", str));

            status = MEMwrite (data_list, str);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list (map_data.data, map_data.num_of_rows,
                              map_data.num_of_cols);
                free (map_data.data);
                ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
                                "NFMadd_project_acl_map","MEMwrite");
                return (status);
                }

            status = MEMbuild_array (data_list);
  	    if( status != MEM_S_SUCCESS )
	    {
	        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	        MEMclose( &attr_list );
	        MEMclose( &data_list );
	        MEMclose( &value_list );
	        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	        return( NFM_E_MEM );
	    }

            data_ptr = (char **) data_list->data_ptr;
            column_ptr = (char **) data_list->column_ptr;

            }  /* end if selected mapping */

        }  /* end for each mapping */

    NFAfree_list (map_data.data, map_data.num_of_rows,
                  map_data.num_of_cols);
    free (map_data.data);

    if (MAPS_CHOSEN)
        {
        SCdisplay_msg ("Working..");
        status = NFMRupdate_project_acl_map (NFMuser_id, attr_list, data_list);
        }
    else
        {
        status = NFI_W_COMMAND_CANCELLED;
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        }

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&map_list);

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long delete_project_acl_map ()

{
long   status;
int    i, k, m, n, p;
int    reset_no;
int    stat_col=0;
int    MAPS_CHOSEN = FALSE;
int    map_index=0;
struct SCfree_data_st map_data;
char   project_num[20];
char   index_num[20];
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr map_list = NULL;
NDXptr index;
static char *fname = "delete_project_acl_map";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_project_acl_map (NFMuser_id, NFMproject, &attr_list,
                                        &data_list, &value_list);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    attr_ptr = (char **) attr_list->data_ptr;

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    _NFIdebug ((fname, "data rows : <%d>\n", data_list->rows));

    if (data_list->rows == 0)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
	ERRload_struct( NFI, NFI_E_NO_MAPS, "%s", NFMproject );
        return (NFI_S_SUCCESS);
        }

    status = MEMbuild_array (value_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    NFMRfill_index (attr_list, &index);

    /* find project number from values list */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_projectno") == 0)
            {
            status = NFAget_value_list_index (attr_ptr[i+index.list],
                        value_list, attr_ptr[i+index.name],
                        attr_ptr[i+index.syn], index_num);
            if (status != NFI_S_SUCCESS)
                {
                MEMclose (&attr_list);
                MEMclose (&value_list);
                MEMclose (&data_list);
                return (status);
                }
            strcpy (project_num, index_num);
            break;
            }
        }

    _NFIdebug ((fname, "project_num : <%s>\n", project_num));

    /* find the column for n_status */
    for (i=0; i<data_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], "n_status") == 0)
            {
            stat_col = i + 1;
            break;
            }
        }

    _NFIdebug ((fname, "stat_col : <%d>\n", stat_col));

    /* List all mappings */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_mapno") == 0)
            {
            reset_no = atoi (attr_ptr[i+index.list]);
            _NFIdebug ((fname, "reset_no : <%ld>\n", reset_no));
            status = MEMreset_buffer_no (value_list, reset_no);
	    if( status != MEM_S_SUCCESS )
  	        {
	        _NFIdebug(( fname, "MEMreset <0x%.8x>\n", status ));
	        MEMclose( &attr_list );
	        MEMclose( &data_list );
	        MEMclose( &value_list );
	        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	        return( NFM_E_MEM );
	        }
            status = MEMsplit_copy_buffer (value_list, &map_list, 0);
	    if( status != MEM_S_SUCCESS )
	        {
	        _NFIdebug(( fname, "MEMsplit <0x%.8x>\n", status ));
	        MEMclose( &attr_list );
	        MEMclose( &data_list );
	        MEMclose( &value_list );
	        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	        return( NFM_E_MEM );
	        }
            status = MEMbuild_array (map_list);
	    if( status != MEM_S_SUCCESS )
	        {
	        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	        MEMclose( &attr_list );
	        MEMclose( &data_list );
	        MEMclose( &value_list );
	        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	        return( NFM_E_MEM );
	        }
            }
        }

    sprintf (map_data.title, "Choose ACLs to delete from project \'%s\'", NFMproject);

    for (i=0; i<data_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], "n_mapno") == 0)
            {
            map_index = i;
            break;
            }
        }

    status = NFAfill_free_data_list (data_list, map_list, map_index, &map_data);

    status = SCprocess_free_form (&map_data, NFMprint_file);
 
    /* for each selected mapping, MEMwrite_data "DROP" */

    for (k=0; k<map_data.num_of_rows; ++k)
        {

        /* if mapping is selected, add a row */
        if (map_data.select_set[k] == 1)
            {
            MAPS_CHOSEN = TRUE;
            m = k * map_data.num_of_cols;

            for (n=0; n<data_list->rows; ++n)
                {
                p = n * data_list->columns;
                if (strcmp (data_ptr[p+map_index], map_data.data[m]) == 0)
                    {
                    status = MEMwrite_data (data_list, "DROP", n+1, stat_col);
                    if (status != MEM_S_SUCCESS)
                        {
                        MEMclose (&attr_list);
                        MEMclose (&data_list);
                        MEMclose (&value_list);
                        NFAfree_list (map_data.data, map_data.num_of_rows,
                                      map_data.num_of_cols);
                        free (map_data.data);
 	                ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
                                 "NFMdelete_project_acl_map","MEMwrite_data");
                        return (status);
                        }

                    }  /* row matches */

                }  /* for each row */

            }  /* end if selected mapping */

        }  /* end for each mapping */

    NFAfree_list (map_data.data, map_data.num_of_rows,
                  map_data.num_of_cols);
    free (map_data.data);

    if (MAPS_CHOSEN)
        {
        SCdisplay_msg ("Working..");
        if (_NFMdebug_st.NFIdebug_on)
            MEMprint_buffers ("DATA LIST", data_list, _NFMdebug_st.NFIdebug_file);

        status = NFMRupdate_project_acl_map (NFMuser_id, attr_list, data_list);
        }
    else
        {
        status = NFI_W_COMMAND_CANCELLED;
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        }

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&map_list);

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long add_project_sa_map ()

{
long   status;
int    i, k, m, n;
int    reset_no;
int    MAPS_CHOSEN = FALSE;
int    map_index=0;
struct SCfree_data_st map_data;
char   project_num[20];
char   map_num[20];
char   str[100];
char   index_num[20];
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr map_list = NULL;
NDXptr index;
static char *fname = "add_project_sa_map";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_project_sa_map (NFMuser_id, NFMproject, &attr_list,
                                       &data_list, &value_list);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    attr_ptr = (char **) attr_list->data_ptr;

    status = MEMbuild_array (value_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    NFMRfill_index (attr_list, &index);

    /* find project number from values list */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_projectno") == 0)
            {
            status = NFAget_value_list_index (attr_ptr[i+index.list],
                        value_list, attr_ptr[i+index.name],
                        attr_ptr[i+index.syn], index_num);
            if (status != NFI_S_SUCCESS)
                {
                MEMclose (&attr_list);
                MEMclose (&value_list);
                MEMclose (&data_list);
                return (status);
                }
            strcpy (project_num, index_num);
            break;
            }
        }

    _NFIdebug ((fname, "project_num : <%s>\n", project_num));

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    /* List all mappings */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_mapno") == 0)
            {
            reset_no = atoi (attr_ptr[i+index.list]);
            _NFIdebug ((fname, "reset_no : <%ld>\n", reset_no));
            if( reset_no == 0 )
            {
                ERRload_struct( NFI, NFI_I_NO_VALUES, NULL,NULL );
                MEMclose( &attr_list );
                MEMclose( &data_list );
                MEMclose( &value_list );
                return( NFI_I_NO_VALUES );
            }
            status = MEMreset_buffer_no (value_list, reset_no);
            status = MEMsplit_copy_buffer (value_list, &map_list, 0);
            status = MEMbuild_array (map_list);
            }
        }

    for (i=0; i<data_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], "n_mapno") == 0)
            {
            map_index = i;
            break;
            }
        }

    sprintf (map_data.title, "Choose Storage Areas for project \'%s\'", NFMproject);

    status = NFAexclusive_fill_free_list (data_list, map_list, map_index, 
                                          &map_data);

    /* 1 Mar 94. CN temp . Setting the address of column_ptr */
    column_ptr = (char **) data_list->column_ptr;

    if (status != NFI_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI,  NFI_E_ALL_SA_MAPPED,  "%s",  NFMproject );
        return (NFI_E_ALL_SA_MAPPED);
        }

    status = SCprocess_free_form (&map_data, NFMprint_file);

    /* for each selected mapping, add a row */

    for (k=0; k<map_data.num_of_rows; ++k)
        {

        /* if mapping is selected, add a row */
        if (map_data.select_set[k] == 1)
            {
            MAPS_CHOSEN = TRUE;
            m = k * map_data.num_of_cols;
            map_num[0] = 0;
            strcpy (map_num, map_data.data[m]);
            _NFIdebug ((fname, "sa num  : <%s>\n", map_num));

            str[0] = 0;

            for (n=0; n<data_list->columns; ++n)
                 {
                      if (strcmp (column_ptr[n], "n_projectno") == 0)
                          strcat (str, project_num);

                 else if (strcmp (column_ptr[n], "n_mapno") == 0)
                          strcat (str, map_num);

                 else if (strcmp (column_ptr[n], "n_status") == 0)
                          strcat (str, "ADD");

                 strcat (str, "\1");
                 }

            _NFIdebug ((fname, "str : <%s>\n", str));

            status = MEMwrite (data_list, str);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list (map_data.data, map_data.num_of_rows,
                              map_data.num_of_cols);
                free (map_data.data);
                ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
                                "NFMadd_project_sa_map","MEMwrite");
                return (status);
                }

            status = MEMbuild_array (data_list);

            data_ptr = (char **) data_list->data_ptr;
            column_ptr = (char **) data_list->column_ptr;

            }  /* end if selected mappings */

        }  /* end for each mapping */

    NFAfree_list (map_data.data, map_data.num_of_rows,
                  map_data.num_of_cols);
    free (map_data.data);

    if (MAPS_CHOSEN)
        {
        SCdisplay_msg ("Working..");
        status = NFMRupdate_project_sa_map (NFMuser_id, attr_list, data_list);
        }
    else
        {
        status = NFI_W_COMMAND_CANCELLED;
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        }

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&map_list);

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long delete_project_sa_map ()

{
long   status;
int    i, k, m, n, p;
int    reset_no;
int    stat_col=0;
int    MAPS_CHOSEN = FALSE;
int    map_index=0;
struct SCfree_data_st map_data;
char   project_num[20];
char   index_num[20];
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr map_list = NULL;
NDXptr index;
static char *fname = "delete_project_sa_map";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_project_sa_map (NFMuser_id, NFMproject, &attr_list,
                                       &data_list, &value_list);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    attr_ptr = (char **) attr_list->data_ptr;

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    _NFIdebug ((fname, "data rows : <%d>\n", data_list->rows));

    if (data_list->rows == 0)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
	ERRload_struct( NFI, NFI_E_NO_MAPS, "%s", NFMproject );
        return (NFI_S_SUCCESS);
        }

    status = MEMbuild_array (value_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    NFMRfill_index (attr_list, &index);

    /* find project number from values list */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_projectno") == 0)
            {
            status = NFAget_value_list_index (attr_ptr[i+index.list],
                        value_list, attr_ptr[i+index.name],
                        attr_ptr[i+index.syn], index_num);
            if (status != NFI_S_SUCCESS)
                {
                MEMclose (&attr_list);
                MEMclose (&value_list);
                MEMclose (&data_list);
                return (status);
                }
            strcpy (project_num, index_num);
            break;
            }
        }

    _NFIdebug ((fname, "project_num : <%s>\n", project_num));

    /* find the column for n_status */
    for (i=0; i<data_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], "n_status") == 0)
            {
            stat_col = i + 1;
            break;
            }
        }

    _NFIdebug ((fname, "stat_col : <%d>\n", stat_col));

    /* List all mappings */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_mapno") == 0)
            {
            reset_no = atoi (attr_ptr[i+index.list]);
            _NFIdebug ((fname, "reset_no : <%ld>\n", reset_no));
            status = MEMreset_buffer_no (value_list, reset_no);
            status = MEMsplit_copy_buffer (value_list, &map_list, 0);
            status = MEMbuild_array (map_list);
            }
        }

    sprintf (map_data.title, "Choose Storage Areas to delete from project \'%s\'", NFMproject);

    for (i=0; i<data_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], "n_mapno") == 0)
            {
            map_index = i;
            break;
            }
        }

    status = NFAfill_free_data_list (data_list, map_list, map_index, &map_data);

    status = SCprocess_free_form (&map_data, NFMprint_file);
 
    /* for each selected storage area, MEMwrite_data "DROP" */

    for (k=0; k<map_data.num_of_rows; ++k)
        {

        /* if mapping is selected, add a row */
        if (map_data.select_set[k] == 1)
            {
            MAPS_CHOSEN = TRUE;
            m = k * map_data.num_of_cols;

            for (n=0; n<data_list->rows; ++n)
                {
                p = n * data_list->columns;
                if (strcmp (data_ptr[p+map_index], map_data.data[m]) == 0)
                    {
                    status = MEMwrite_data (data_list, "DROP", n+1, stat_col);
                    if (status != MEM_S_SUCCESS)
                        {
                        MEMclose (&attr_list);
                        MEMclose (&data_list);
                        MEMclose (&value_list);
                        NFAfree_list (map_data.data, map_data.num_of_rows,
                                      map_data.num_of_cols);
                        free (map_data.data);
	                ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
                                "NFMdelete_project_sa_map","MEMwrite_data");
                        return (status);
                        }

                    }  /* row matches */

                }  /* for each row */

            }  /* end if selected mapping */

        }  /* end for each mapping */

    NFAfree_list (map_data.data, map_data.num_of_rows,
                  map_data.num_of_cols);
    free (map_data.data);

    if (MAPS_CHOSEN)
        {
        SCdisplay_msg ("Working..");
        if (_NFMdebug_st.NFIdebug_on)
            MEMprint_buffers ("DATA LIST", data_list, _NFMdebug_st.NFIdebug_file);

        status = NFMRupdate_project_sa_map (NFMuser_id, attr_list, data_list);
        if (status != NFM_S_SUCCESS)
	    ERRload_struct( NFI, NFI_E_DELETE_PROJ_SA_MAP, "%s", NFMproject);
        }
    else
        {
        status = NFI_W_COMMAND_CANCELLED;
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        }

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&map_list);

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



