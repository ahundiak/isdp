#include "machine.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMRlist.h"
#include "NFMdisplays.h"
#include "NFMtitles.h"
#include "UMS.h"

char   title[80];

long delete_node ()

{
int    i, j;
long   status;
struct SCfree_data_st data;
char   node_name[30];
NFMlist list_struct;
static  char *fname = "NFAdelete_node";

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
        return (status);

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (node_name, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");

    status = NFMRdelete_node (NFMuser_id, node_name);

    _NFIdebug(( fname, "Return from NFMdelete_node -> 0x%.8x\n", status));

    switch (status)
        {
        case NFM_S_SUCCESS:
            /* if the active node is the deleted one, erase it */
            if (strcmp (NFMnode, node_name) == 0)
                strcpy (NFMnode, "");
            break;
            
        default:
	    break;
        }

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if( status != NFM_S_SUCCESS )
        return (status);

    return( NFI_S_SUCCESS );
}


long delete_storage_area ()

{
int    i, j;
long   status;
struct SCfree_data_st data;
char   storage_area_name[30];
NFMlist list_struct;
static  char *fname = "NFAdelete_storage_area";

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SA, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Storage Areas" );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_STORAGE_AREAS, 
	SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", "", 
	"", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        return (status);

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (storage_area_name, data.data[j]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");

    status = NFMRdelete_storage_area (NFMuser_id, storage_area_name);

    _NFIdebug(( fname, "Return from NFMdelete_storage_area -> %0x%.8x\n", 
		status));

    switch (status)
        {
        case NFM_S_SUCCESS:
            /* if the active storage_area is the deleted one, erase it */
            if (strcmp (NFMstorage, storage_area_name) == 0)
                strcpy (NFMstorage, "");
            if (strcmp (NFMworking, storage_area_name) == 0)
                strcpy (NFMworking, "");
            break;
            
        default:
            break;
        }

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    if( status != NFM_S_SUCCESS )
        return (status);

    return( NFI_S_SUCCESS );
}


long delete_user ()

{
int    i, j;
long   status;
struct SCfree_data_st data;
char   user_name[30];
NFMlist list_struct;
static  char *fname = "NFAdelete_user";

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_USERS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Users" );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_USERS, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "","", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        return (status);

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (user_name, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");

    status = NFMRdelete_user (NFMuser_id, user_name);

    _NFIdebug(( fname, "Return from NFMdelete_user -> 0x%.8x\n", status));

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if( status != NFM_S_SUCCESS )
        return (status);

    return( NFI_S_SUCCESS );
}


long delete_search ()

{
int    i, j;
long   status;
struct SCfree_data_st data;
char   search_name[100];
char   search[100];
NFMlist list_struct;
static  char *fname = "NFAdelete_search";

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SEARCH, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Search Criteria Names" );
      }

    SCdisplay_msg ("Working..");

  sprintf( search, "nfmusers.n_username IN ('PUBLIC', '%s' )", NFMuser);
    NFAfill_list_struct (&list_struct, DSP_SEARCH, SELECT_SET_SINGLE_ROW, 
	NFM_FULL_DISPLAY, -1, search, "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        return (status);

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (search_name, data.data[j]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");

    status = NFMRdelete_query ( search_name );

    _NFIdebug(( fname, "Return from NFMdelete_search -> 0x%.8x\n", status));


    if( status == NFM_S_SUCCESS )
    {
	if( strcmp( search_name, NFMsearch_name ) == 0 )
            strcpy (NFMsearch_name, "");
    }

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    if( status != NFM_S_SUCCESS )
       return (status);

    return( NFI_S_SUCCESS );
}


long delete_sort ()

{
int    i, j;
long   status;
struct SCfree_data_st data;
char   sort_name[30];
NFMlist list_struct;
static  char *fname = "NFAdelete_sort";

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SORT, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Sort Criteria Names" );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_SORT, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "n_type = \'O\'", "", "", "", "", "", "",
	title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        return (status);

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (sort_name, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");

    status = NFMRdelete_query ( sort_name);

    _NFIdebug(( fname, "Return from NFMdelete_sort -> 0x%.8x\n", status));

    if (status == NFM_S_SUCCESS)
    {
	if( strcmp( sort_name, NFMsort_name ) == 0 )
            strcpy (NFMsort_name, "");
    }

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if( status != NFM_S_SUCCESS )
        return (status);

    return( NFI_S_SUCCESS );
}


long purge_signoff ()

{
  long   status;
  static char *fname = "NFApurge_signoff";

  _NFIdebug(( fname, "%s\n", "Enter nfm_purge_signoff"));

  SCdisplay_msg ("Working..");

  status = NFMRpurge_signoff (NFMuser_id, NFMcatalog,
                              NFMitem, NFMrev) ;

  _NFIdebug(( fname, "Return from NFMRpurge_signoff -> 0x%.8x\n", status));

  NFAmake_msg (msg);
  _NFIdebug(( fname, "%s\n", msg));
  SCdisplay_ref (msg);

    if( status != NFM_S_SUCCESS )
      return (status);
 
    return( NFI_S_SUCCESS );
}


long delete_acl ()

{
int    i, j;
long   status;
long   acl_num;
char   acl_name[NFM_ACLNAME+1];
struct SCfree_data_st data;
NFMlist list_struct;
static  char *fname = "NFAdelete_acl";

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ACLS, "%s", NFMworkflow)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of ACLs in Workflow <%s>", NFMworkflow );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_ACLS, 
	SELECT_SET_SINGLE_ROW, NFM_SHORT_DISPLAY, -1, "", "", "", 
	"", "", NFMworkflow, "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        return (status);

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
	    strcpy (acl_name, data.data[j+1] );
            acl_num = atol( data.data[j] );
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");

    status = NFMRdelete_acl( NFMworkflow, acl_name );

    _NFIdebug(( fname, "Return from NFMRdelete_acl -> %0x%.8x\n", status));

    switch (status)
        {
        case NFM_S_SUCCESS:
            /* if the active ACL is the deleted one, erase it */
            if (strcmp (NFMacl, acl_name) == 0)
                strcpy (NFMacl, "");
            break;
            
        default:
            break;
        }

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    if( status != NFM_S_SUCCESS )
        return (status);

    return( NFI_S_SUCCESS );
}


long delete_label ()

{
int    i, j;
long   status;
char   fmt[NFM_SYNONYM+1];
MEMptr data_list = NULL;
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "NFAdelete_label";

    _NFIdebug(( fname, "%s\n", "Entering ... " ));

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_LABELS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Labels" );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_LABELS, SELECT_SET_MULTI_ROW, 
NFM_FULL_DISPLAY, -1, "n_label NOT IN ('DISK_A','DISK_B','DISK_C','DISK_O','DISK_F','DISK_J')", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        return (status);

    status = MEMopen( &data_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	_NFIdebug(( fname, "MEMopen <0x%.8x>\n", status ));
	MEMclose( &data_list );
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_LABEL );
    status = MEMwrite_format( data_list, "n_label", fmt );
    if( status != MEM_S_SUCCESS )
    {
	_NFIdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
	MEMclose( &data_list );
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );	
    }

    for (i=0; i<data.num_of_rows; ++i)
    {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
        {
	    sprintf( fmt, "%s\1", data.data[j] );
	    status = MEMwrite( data_list, fmt );
	    if( status != MEM_S_SUCCESS )
	    {
		_NFIdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
		MEMclose( &data_list );
	        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
	        free (data.data);
		return( status );
	    }
        }
    }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");

    status = NFMRdelete_label( data_list );

    _NFIdebug(( fname, "Return from NFMRdelete_label -> %0x%.8x\n", status));

    MEMclose( &data_list );
  
    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    if( status != NFM_S_SUCCESS )
        return (status);

    return( NFI_S_SUCCESS );
}




