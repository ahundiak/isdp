#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMRlist.h"
#include "NFMdisplays.h"
#include "UMS.h"
#include "NFMtitles.h"

extern long sqlstatus;
char   title[80];
char   WORKING_user[20];
char   Working_user_search[20];

long NFAactivate_project ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;
static  char *fname = "NFAactivate_project";

    if (strcmp (NFMproject, "") != 0)
        return (NFI_S_SUCCESS);

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
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        if (status == NFM_E_NO_PROJECTS_FOUND)
	    return( status );
	else if( status == NFI_W_COMMAND_CANCELLED )
	    return( status );
	else
	    ERRload_struct( NFI, NFI_E_CANNOT_ACTIVATE_PROJECT, NULL,NULL);
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            ROW_CHOSEN = TRUE;
            strcpy (NFMproject, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);
}

long NFAactivate_catalog ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "NFAactivate_catalog";

    if (strcmp (NFMcatalog, "") != 0)
        return (NFI_S_SUCCESS);

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_CATALOGS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Catalogs" );
      }
    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_CATALOGS, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "nfmcatalogs.n_catalogname NOT LIKE '%_rl' ", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        if (status == NFM_E_NO_CATALOGS_FOUND)
	    return( status );
        else if( status == NFI_W_COMMAND_CANCELLED )
            return( status );
        else
            ERRload_struct( NFI, NFI_E_CANNOT_ACTIVATE_CATALOG, NULL,NULL);

        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            ROW_CHOSEN = TRUE;
            strcpy (NFMcatalog, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);
}


long NFAactivate_item ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "NFAactivate_item";

    if (strcmp (NFMitem, "") != 0)
        return (NFI_S_SUCCESS);

    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
        return (status);
        
    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ITEMS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Items" );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_ITEMS, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "", "", NFMcatalog, "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        if (status == NFM_E_NO_ITEMS_FOUND_IN_CAT)
	    return( status );
        else if( status == NFI_W_COMMAND_CANCELLED )
            return( status );
        else
            ERRload_struct( NFI, NFI_E_CANNOT_ACTIVATE_ITEM, NULL, NULL);

        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            ROW_CHOSEN = TRUE;
            strcpy (NFMitem, data.data[j+1]);
            strcpy (NFMrev, data.data[j+2]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);
}


long NFAactivate_set ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "NFAactivate_set";

    if( strcmp (NFMset, "") != 0)
        return (NFI_S_SUCCESS);

    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
        return (status);

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SETS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of I/NFM Sets in Catalog <%s>", NFMcatalog );
      }
        
    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_SETS, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "", "", NFMcatalog, "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        if (status == NFM_E_NO_SETS_FOUND_FOR_CAT)
	    return( status );
        else if( status == NFI_W_COMMAND_CANCELLED )
            return( status );
        else
            ERRload_struct( NFI, NFI_E_CANNOT_ACTIVATE_SET, NULL,NULL);

        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
	    ROW_CHOSEN = TRUE;
            strcpy (NFMset, data.data[j]);
            strcpy (NFMset_rev, data.data[j+1]);
	    NFMset_ind = 1;
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);

}


long NFAactivate_workflow ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
char   old_wf[40];
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "NFAactivate_workflow";

    if (strcmp (NFMworkflow, "") != 0)
        return (NFI_S_SUCCESS);

    strcpy (old_wf, NFMworkflow);

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_WF, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Workflows" );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_WORKFLOWS, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        if (status == NFM_E_NO_WORKFLOWS_FOUND)
	    return( status );
        else if( status == NFI_W_COMMAND_CANCELLED )
            return( status );
        else
            ERRload_struct( NFI, NFI_E_CANNOT_ACTIVATE_WORKFLOW, NULL,NULL);

        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
	    ROW_CHOSEN = TRUE;
            strcpy (NFMworkflow, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (strcmp (NFMworkflow, old_wf) != 0)
        strcpy (NFMacl, "");

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);

}


long NFAactivate_acl ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "NFAactivate_acl";

    if (strcmp (NFMacl, "") != 0)
        return (NFI_S_SUCCESS);

    status = NFAactivate_workflow ();
    if( status != NFI_S_SUCCESS )
	return( status );

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ACLS, "%s", NFMworkflow )) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of I/NFM ACLs in Workflow %s", NFMworkflow );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_ACLS, SELECT_SET_SINGLE_ROW,
NFM_FULL_DISPLAY, -1, "", "", "", "", "", NFMworkflow, "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        if (status == NFM_E_NO_ACLS_FOUND_IN_WF)
	    return( status );
        else if( status == NFI_W_COMMAND_CANCELLED )
            return( status );
        else
            ERRload_struct( NFI, NFI_E_CANNOT_ACTIVATE_ACL, NULL,NULL);

        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
	    ROW_CHOSEN = TRUE;
            strcpy (NFMacl, data.data[j]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);

}

long NFAactivate_node ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "NFAactivate_node";

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_NODES, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Nodes" );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_NODES, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        if (status == NFM_E_NO_NODES_FOUND)
	    return( status );
        else if( status == NFI_W_COMMAND_CANCELLED )
            return( status );
        else
            ERRload_struct( NFI, NFI_E_CANNOT_ACTIVATE_NODE, NULL,NULL);

        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            ROW_CHOSEN = TRUE;
            strcpy (NFMnode, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

        
    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);
}

long NFAactivate_sa ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "NFAactivate_sa";

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SA, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Storage Areas" );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_STORAGE_AREAS, 
	SELECT_SET_SINGLE_ROW, NFM_SHORT_DISPLAY, -1, "", "", "", "", "", "",
	"", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        if (status == NFM_E_NO_STORAGE_AREAS_FOUND)
	    return( status );
        else if( status == NFI_W_COMMAND_CANCELLED )
            return( status );
        else
            ERRload_struct( NFI, NFI_E_CANNOT_ACTIVATE_STORAGE_AREA,NULL,NULL);

        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            ROW_CHOSEN = TRUE;
            strcpy (NFMstorage, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);
}

long NFAactivate_user ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "NFAactivate_user";

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_USERS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Users" );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_USERS, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        if (status == NFM_E_NO_USERS_FOUND)
	    return( status );
        else if( status == NFI_W_COMMAND_CANCELLED )
            return( status );
        else
            ERRload_struct( NFI, NFI_E_CANNOT_ACTIVATE_USER, NULL, NULL );
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            ROW_CHOSEN = TRUE;
            strcpy (WORKING_user, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);
}

long NFAactivate_wa ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
char   search[40];
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "NFAactivate_wa";

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_WA, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Working Areas" );
      }

    SCdisplay_msg ("Working..");

    sprintf( search, "nfmusers.n_username IN ('PUBLIC', '%s' )", NFMuser);
    NFAfill_list_struct (&list_struct, DSP_WORKING_AREAS, 
	SELECT_SET_SINGLE_ROW, NFM_SHORT_DISPLAY, -1, search, 
	"", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        if (status == NFM_E_NO_STORAGE_AREAS_FOUND)
	    return( status );
        else if( status == NFI_W_COMMAND_CANCELLED )
            return( status );
        else
            ERRload_struct( NFI, NFI_E_CANNOT_ACTIVATE_STORAGE_AREA,NULL,NULL);

        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            ROW_CHOSEN = TRUE;
            strcpy (NFMworking, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);
}

long NFAactivate_search ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "NFAactivate_search";

    if( strcmp (NFMsearch_name, "") != 0)
        return (NFI_S_SUCCESS);

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SEARCH, NULL, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Search Criteria Names" );
      }
        
    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_SEARCH, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        if (status == NFM_E_DISPLAY_SEARCHES)
	    return( status );
        else if( status == NFI_W_COMMAND_CANCELLED )
            return( status );
        else
            ERRload_struct( NFI, NFI_E_LIST_SEARCHES, NULL,NULL);

        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
	    ROW_CHOSEN = TRUE;
            strcpy (NFMsearch_name, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);

}

long NFAactivate_sort ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "NFAactivate_sort";

    if( strcmp (NFMsort_name, "") != 0)
        return (NFI_S_SUCCESS);

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SORT, NULL, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Sort Criteria Names" );
      }
        
    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_SORT, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        if (status == NFM_E_DISPLAY_SEARCHES)
	    return( status );
        else if( status == NFI_W_COMMAND_CANCELLED )
            return( status );
        else
            ERRload_struct( NFI, NFI_E_LIST_SORTS, NULL,NULL);

        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
	    ROW_CHOSEN = TRUE;
            strcpy (NFMsort_name, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);

}


long NFAactivate_user_search ()

{
int    i, j;
int    tot_data;
int    FORM_FILLED;
int    Private=0;
long   status;
struct SCfree_data_st fdata;
NFMlist list_struct;

static  char *fname = "NFAactivate_user_search";

    _NFIdebug((fname, "Enter\n"));

    fdata.num_of_rows = 2;
    fdata.num_of_cols =1;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0 ;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_SINGLE_ROW;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));

    fdata.col_size[0] = 25;

    fdata.col_pos = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_pos, 0 , (fdata.num_of_cols * sizeof (int)));

    fdata.col_pos[0] = 0;

    fdata.col_just = (int *) malloc (fdata.num_of_cols * sizeof (int));
     memset (fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols * sizeof (int)));
    fdata.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h1_pos, 0, sizeof (int) + 1);
    fdata.h1_pos[0] = 0;
    fdata.h1_pos[1] = -1;

    fdata.h2_pos = (int *) malloc ((fdata.num_of_cols * sizeof (int)) + 1);
    memset (fdata.h2_pos, 0, (fdata.num_of_cols * sizeof (int)) + 1);
    fdata.h2_pos[0] = 0;
    fdata.h2_pos[1] = -1;

    fdata.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h3_pos, 0, sizeof (int) + 1);
    fdata.h3_pos[0] = 0;
    fdata.h3_pos[1] = -1;

    fdata.h1_data = (char **) malloc (sizeof (char *));
    memset (fdata.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&fdata.h1_data[0], "");

    fdata.h2_data = (char **) malloc (tot_data * (sizeof (char *)));
    memset (fdata.h2_data, NULL, tot_data * (sizeof (char *)));
    NFAput_string (&fdata.h2_data[0], "Valid I/NFM Users :");

    fdata.h3_data = (char **) malloc (sizeof (char *));
    memset (fdata.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&fdata.h3_data[0], "");

    sprintf (fdata.title, "Is This Criteria To Be Public Or Private");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&fdata.data[0], "PUBLIC") ;
    NFAput_string (&fdata.data[1], "PRIVATE") ;
 do
     {
        FORM_FILLED = FALSE;      /* It was FALES */
        status = SCprocess_free_form (&fdata, NFMprint_file);
        SCclear_msg ();

        if (fdata.sts == FORM_CANCELED)
         {
          _NFMdebug ((fname, "Cancel from form. Return.\n"));
          NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
          free (fdata.data);
          ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
          return (NFI_W_FORM_CANCELED);
          }

        if (fdata.sts == FORM_ACCEPTED)
          {
              if (fdata.select_set[0] == 1)
               {
                 FORM_FILLED = TRUE;
                 if (strcmp(fdata.data[0], "PUBLIC") ==0)
/*                 strcpy (Working_user_search, "PUBLIC");*/
                 strcpy(WORKING_user, "PUBLIC");
                  break;
                }
               else if (fdata.select_set[1] == 1)
                {
                  FORM_FILLED = TRUE;
                  /* changed NFMuser to PRIVATE - SSRS 24 Mar 94 */
                  if (strcmp(fdata.data[1], "PRIVATE" ) ==0)
                 /* strcpy (Working_user_search, NFMuser);*/
                  strcpy (WORKING_user, NFMuser);
                  break;
                 }
                else
                    FORM_FILLED = FALSE;
                    SCdisplay_msg ("NFM:  Must Choose User.");

            }

        }
    while ((FORM_FILLED == FALSE) && (fdata.sts != FORM_CANCELED));
    if (fdata.sts == FORM_CANCELED)
        {
        _NFIdebug ((fname, "Cancel from form. Return.\n"));
        NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        free (fdata.data);
        ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
        return (NFI_W_FORM_CANCELED);
        }

    _NFIdebug ((fname, "Owner is  : <%s>\n", Working_user_search));

    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);
  
    return(NFI_S_SUCCESS);
 }
 
