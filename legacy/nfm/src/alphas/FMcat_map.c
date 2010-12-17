#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"

long add_catalog_acl_map ()

{
long   status;
int    i, k, m, n;
int    reset_no;
int    ACLS_CHOSEN = FALSE;
int    acl_index=0;
struct SCfree_data_st acl_data;
char   catalog_num[20];
char   acl_num[20];
char   acl_name[20];
char   str[100];
char   index_num[20];
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr acl_list = NULL;
NDXptr index;
static char *fname = "NFAadd_catalog_acl_map";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_catalog_acl_map (NFMuser_id, NFMcatalog, &attr_list,
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
	_NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	MEMclose( &attr_list );
	MEMclose( &data_list );
	MEMclose( &value_list );
	return( NFM_E_MEM );
    }
    attr_ptr = (char **) attr_list->data_ptr;

    status = MEMbuild_array (value_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        return( NFM_E_MEM );
    }

    NFMRfill_index (attr_list, &index);

    /* find catalog number from values list */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_catalogno") == 0)
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
            strcpy (catalog_num, index_num);
            break;
            }
        }

    _NFIdebug ((fname, "catalog_num : <%s>\n", catalog_num));

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        return( NFM_E_MEM );
    }

    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    /* List all acl/worklows */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_aclno") == 0)
            {
            reset_no = atoi (attr_ptr[i+index.list]);
            _NFIdebug ((fname, "reset_no : <%ld>\n", reset_no));
            status = MEMreset_buffer_no (value_list, reset_no);
            status = MEMsplit_copy_buffer (value_list, &acl_list, 0);
            status = MEMbuild_array (acl_list);
            }
        }

    for (i=0; i<data_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], "n_aclno") == 0)
            {
            acl_index = i;
            break;
            }
        }

    sprintf (acl_data.title, "Choose ACLs for catalog \'%s\'", NFMcatalog);

    status = NFAexclusive_fill_free_list (data_list, acl_list, acl_index, 
                                          &acl_data);
/*
       The  column_ptr address is getting currupted after call to
       NFAexclusive_fill_free_list, so reset the address  CN - 23/2/94
*/
    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;
    if (status != NFI_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_ALL_CAT_ACLS_MAPPED, "%s",NFMcatalog );
        return (NFI_E_ALL_CAT_ACLS_MAPPED);
        }

    status = SCprocess_free_form (&acl_data, NFMprint_file);
 
    /* for each selected acl, add a row */

    for (k=0; k<acl_data.num_of_rows; ++k)
        {

        /* if acl is selected, add a row */
        if (acl_data.select_set[k] == 1)
            {
            ACLS_CHOSEN = TRUE;
            m = k * acl_data.num_of_cols;
            acl_num[0] = 0;
            acl_name[0] = 0;
            strcpy (acl_num, acl_data.data[m]);
            strcpy (acl_name, acl_data.data[m+1]);
            _NFIdebug ((fname, "acl name : <%s>\n", acl_name));
            _NFIdebug ((fname, "acl num  : <%s>\n", acl_num));

            str[0] = 0;

            for (n=0; n<data_list->columns; ++n)
                 {
                      if (strcmp (column_ptr[n], "n_catalogno") == 0)
                          strcat (str, catalog_num);

                 else if (strcmp (column_ptr[n], "n_aclno") == 0)
                          strcat (str, acl_num);

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
                NFAfree_list (acl_data.data, acl_data.num_of_rows,
                              acl_data.num_of_cols);
                free (acl_data.data);
                ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
				"NFMadd_catalog_acl_map", "MEMwrite");
                return (NFI_E_MEMORY);
                }

            status = MEMbuild_array (data_list);
	    if( status != MEM_S_SUCCESS )
	    {
	        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
	        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	        MEMclose( &attr_list );
	        MEMclose( &data_list );
	        MEMclose( &value_list );
                NFAfree_list (acl_data.data, acl_data.num_of_rows,
                              acl_data.num_of_cols);
                free (acl_data.data);
	        return( NFM_E_MEM );
            }
            data_ptr = (char **) data_list->data_ptr;
            column_ptr = (char **) data_list->column_ptr;

            }  /* end if selected acl */

        }  /* end for each acl */

    NFAfree_list (acl_data.data, acl_data.num_of_rows,
                  acl_data.num_of_cols);
    free (acl_data.data);

    if (ACLS_CHOSEN)
        {
        SCdisplay_msg ("Working..");
        status = NFMRupdate_catalog_acl_map (NFMuser_id, attr_list, data_list);
        }
    else
        {
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        status = NFI_W_COMMAND_CANCELLED;
        }

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&acl_list);

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long delete_catalog_acl_map ()

{
long   status;
int    i, k, m, n, p;
int    reset_no;
int    stat_col=0;
int    ACLS_CHOSEN = FALSE;
int    acl_index=0;
struct SCfree_data_st acl_data;
char   catalog_num[20];
char   index_num[20];
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr acl_list = NULL;
NDXptr index;
static char *fname = "delete_catalog_acl_map";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_catalog_acl_map (NFMuser_id, NFMcatalog, &attr_list,
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
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        return( NFM_E_MEM );
    } 
    attr_ptr = (char **) attr_list->data_ptr;

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
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
        ERRload_struct( NFI, NFI_I_NO_CAT_MAPPINGS, "%s", NFMcatalog );
        return (NFI_S_SUCCESS);
        }

    status = MEMbuild_array (value_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        return( NFM_E_MEM );
    }
    NFMRfill_index (attr_list, &index);

    /* find catalog number from values list */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_catalogno") == 0)
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
            strcpy (catalog_num, index_num);
            break;
            }
        }

    _NFIdebug ((fname, "catalog_num : <%s>\n", catalog_num));

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

    /* List all acl/worklows */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_aclno") == 0)
            {
            reset_no = atoi (attr_ptr[i+index.list]);
            _NFIdebug ((fname, "reset_no : <%ld>\n", reset_no));
            status = MEMreset_buffer_no (value_list, reset_no);
            status = MEMsplit_copy_buffer (value_list, &acl_list, 0);
            status = MEMbuild_array (acl_list);
            }
        }

    sprintf (acl_data.title, "Choose ACLs to delete from catalog \'%s\'", NFMcatalog);

    for (i=0; i<data_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], "n_aclno") == 0)
            {
            acl_index = i;
            break;
            }
        }

    status = NFAfill_free_data_list (data_list, acl_list, acl_index, &acl_data);

    status = SCprocess_free_form (&acl_data, NFMprint_file);
 
    /* for each selected acl, MEMwrite_data "DROP" */

    for (k=0; k<acl_data.num_of_rows; ++k)
        {

        /* if acl is selected, add a row */
        if (acl_data.select_set[k] == 1)
            {
            ACLS_CHOSEN = TRUE;
            m = k * acl_data.num_of_cols;

            for (n=0; n<data_list->rows; ++n)
                {
                p = n * data_list->columns;
                if (strcmp (data_ptr[p+acl_index], acl_data.data[m]) == 0)
                    {
                    status = MEMwrite_data (data_list, "DROP", n+1, stat_col);
                    if (status != MEM_S_SUCCESS)
                        {
                        MEMclose (&attr_list);
                        MEMclose (&data_list);
                        MEMclose (&value_list);
                        NFAfree_list (acl_data.data, acl_data.num_of_rows,
                                      acl_data.num_of_cols);
                        free (acl_data.data);
                        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
			"NFMdelete_catalog_acl_map","MEMwrite_data");
                        return (NFI_E_MEMORY);
                        }

                    }  /* row matches */

                }  /* for each row */

            }  /* end if selected acl */

        }  /* end for each acl */

    NFAfree_list (acl_data.data, acl_data.num_of_rows,
                  acl_data.num_of_cols);
    free (acl_data.data);

    if (ACLS_CHOSEN)
        {
        SCdisplay_msg ("Working..");
        if (_NFMdebug_st.NFIdebug_on)
            MEMprint_buffers ("DATA LIST", data_list, 
				_NFMdebug_st.NFIdebug_file);

        status = NFMRupdate_catalog_acl_map (NFMuser_id, attr_list, data_list);
        }
    else
        {
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        status = NFI_W_COMMAND_CANCELLED;
        }

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&acl_list);

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long add_catalog_sa_map ()

{
long   status;
int    i, k, m, n;
int    reset_no=0;
int    ST_AREAS_CHOSEN = FALSE;
int    sa_index=0;
struct SCfree_data_st sa_data;
char   catalog_num[20];
char   sa_num[20];
char   sa_name[NFM_SANAME+1];
char   str[100];
char   index_num[20];
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr sa_list = NULL;
NDXptr index;
static char *fname = "add_catalog_sa_map";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_catalog_sa_map (NFMuser_id, NFMcatalog, &attr_list,
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
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        return( NFM_E_MEM );
    }
    attr_ptr = (char **) attr_list->data_ptr;

    status = MEMbuild_array (value_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        return( NFM_E_MEM );
    }

    NFMRfill_index (attr_list, &index);

    /* find catalog number from values list */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_catalogno") == 0)
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
            strcpy (catalog_num, index_num);
            break;
            }
        }

    _NFIdebug ((fname, "catalog_num : <%s>\n", catalog_num));

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        return( NFM_E_MEM );
    }
    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    /* List all storage areas */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_sano") == 0)
            {
            reset_no = atoi (attr_ptr[i+index.list]);
            _NFIdebug ((fname, "reset_no : <%ld>\n", reset_no));
            status = MEMreset_buffer_no (value_list, reset_no);
            status = MEMsplit_copy_buffer (value_list, &sa_list, 0);
            status = MEMbuild_array (sa_list);
            }
        }

    for (i=0; i<data_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], "n_sano") == 0)
            {
            sa_index = i;
            break;
            }
        }

    sprintf (sa_data.title, "Choose Storage Areas for catalog \'%s\'", NFMcatalog);

    status = NFAexclusive_fill_free_list (data_list, sa_list, sa_index, 
                                          &sa_data);
    if (status != NFI_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_ALL_SA_MAPPED, "%s", NFMcatalog );
        return (NFI_E_ALL_SA_MAPPED);
        }

    status = SCprocess_free_form (&sa_data, NFMprint_file);
 
    /* for each selected storage area, add a row */

    for (k=0; k<sa_data.num_of_rows; ++k)
        {

        /* if storage area is selected, add a row */
        if (sa_data.select_set[k] == 1)
            {
            ST_AREAS_CHOSEN = TRUE;
            m = k * sa_data.num_of_cols;
            sa_num[0] = 0;
            sa_name[0] = 0;
            strcpy (sa_num, sa_data.data[m]);
            strcpy (sa_name, sa_data.data[m+1]);
            _NFIdebug ((fname, "sa name : <%s>\n", sa_name));
            _NFIdebug ((fname, "sa num  : <%s>\n", sa_num));

            str[0] = 0;

            for (n=0; n<data_list->columns; ++n)
                 {
                      if (strcmp (column_ptr[n], "n_catalogno") == 0)
                          strcat (str, catalog_num);

                 else if (strcmp (column_ptr[n], "n_sano") == 0)
                          strcat (str, sa_num);

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
                NFAfree_list (sa_data.data, sa_data.num_of_rows,
                              sa_data.num_of_cols);
                free (sa_data.data);
                ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", 
				"NFMadd_catalog_sa_map","MEMwrite");
                return (NFI_E_MEMORY);
                }

            status = MEMbuild_array (data_list);
	    if( status != MEM_S_SUCCESS )
	    {
	        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
	        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	        MEMclose( &attr_list );
	        MEMclose( &data_list );
	        MEMclose( &value_list );
	        return( NFM_E_MEM );
 	    }
            data_ptr = (char **) data_list->data_ptr;
            column_ptr = (char **) data_list->column_ptr;

            }  /* end if selected storage area */

        }  /* end for each storage area */

    NFAfree_list (sa_data.data, sa_data.num_of_rows,
                  sa_data.num_of_cols);
    free (sa_data.data);

    if (ST_AREAS_CHOSEN)
        {
        SCdisplay_msg ("Working..");
        status = NFMRupdate_catalog_sa_map (NFMuser_id, attr_list, data_list);
        }
    else
        {
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        status = NFI_W_COMMAND_CANCELLED;
        }

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&sa_list);

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long delete_catalog_sa_map ()

{
long   status;
int    i, k, m, n, p;
int    reset_no;
int    stat_col=0;
int    ST_AREAS_CHOSEN = FALSE;
int    sa_index=0;
struct SCfree_data_st sa_data;
char   catalog_num[20];
char   index_num[20];
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr sa_list = NULL;
NDXptr index;
static char *fname = "delete_catalog_acl_map";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_catalog_sa_map (NFMuser_id, NFMcatalog, &attr_list,
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
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        return( NFM_E_MEM );
    }
    attr_ptr = (char **) attr_list->data_ptr;

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
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
        ERRload_struct( NFI, NFI_I_NO_CAT_MAPPINGS, "%s", NFMcatalog);
        return (NFI_S_SUCCESS);
        }

    status = MEMbuild_array (value_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild  <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        return( NFM_E_MEM );
    }
    NFMRfill_index (attr_list, &index);

    /* find catalog number from values list */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_catalogno") == 0)
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
            strcpy (catalog_num, index_num);
            break;
            }
        }

    _NFIdebug ((fname, "catalog_num : <%s>\n", catalog_num));

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

    /* List all storage areas */
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (attr_ptr[i+index.nfm], "n_sano") == 0)
            {
            reset_no = atoi (attr_ptr[i+index.list]);
            _NFIdebug ((fname, "reset_no : <%ld>\n", reset_no));
            status = MEMreset_buffer_no (value_list, reset_no);
            status = MEMsplit_copy_buffer (value_list, &sa_list, 0);
            status = MEMbuild_array (sa_list);
            }
        }

    sprintf (sa_data.title, "Choose Storage Areas to delete from catalog \'%s\'", NFMcatalog);

    for (i=0; i<data_list->columns; ++i)
        {
        if (strcmp (column_ptr[i], "n_sano") == 0)
            {
            sa_index = i;
            break;
            }
        }

    status = NFAfill_free_data_list (data_list, sa_list, sa_index, &sa_data);

    status = SCprocess_free_form (&sa_data, NFMprint_file);
 
    /* for each selected storage area, MEMwrite_data "DROP" */

    for (k=0; k<sa_data.num_of_rows; ++k)
        {

        /* if storage area is selected, add a row */
        if (sa_data.select_set[k] == 1)
            {
            ST_AREAS_CHOSEN = TRUE;
            m = k * sa_data.num_of_cols;

            for (n=0; n<data_list->rows; ++n)
                {
                p = n * data_list->columns;
                if (strcmp (data_ptr[p+sa_index], sa_data.data[m]) == 0)
                    {
                    status = MEMwrite_data (data_list, "DROP", n+1, stat_col);
                    if (status != MEM_S_SUCCESS)
                        {
                        MEMclose (&attr_list);
                        MEMclose (&data_list);
                        MEMclose (&value_list);
                        NFAfree_list (sa_data.data, sa_data.num_of_rows,
                                      sa_data.num_of_cols);
                        free (sa_data.data);
                        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
			  "NFMdelete_catalog_sa_map","MEMwrite_data");
                        return (NFI_E_MEMORY);
                        }

                    }  /* row matches */

                }  /* for each row */

            }  /* end if selected storage area */

        }  /* end for each storage area */

    NFAfree_list (sa_data.data, sa_data.num_of_rows,
                  sa_data.num_of_cols);
    free (sa_data.data);

    if (ST_AREAS_CHOSEN)
        {
        SCdisplay_msg ("Working..");
        if (_NFMdebug_st.NFIdebug_on)
            MEMprint_buffers ("DATA LIST", data_list, 
				_NFMdebug_st.NFIdebug_file);

        status = NFMRupdate_catalog_sa_map (NFMuser_id, attr_list, data_list);
        }
    else
        {
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        status = NFI_W_COMMAND_CANCELLED;
        }

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&sa_list);

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



