#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMdisplays.h"
#include "NFMRlist.h"
#include "NFMtitles.h"
#include "UMS.h"

char title[80];

long display_nodes ()

{
int    i, j;
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_nodes";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_NODES, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Nodes" );
      }

    NFAfill_list_struct (&display_struct, DSP_NODES, SELECT_SET_SINGLE_ROW, 
	NFM_FULL_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);
   
    if (status == NFI_W_COMMAND_CANCELLED)
        {
	_NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
	return( status );
        }	

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFMRdisplay_nodes : <0x%.8x>\n", status));
	return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (NFMnode, data.data[j]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_nodes_short ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_nodes_short";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_NODES, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Nodes" );
      }

    NFAfill_list_struct (&display_struct, DSP_NODES, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);
   
    if (status == NFI_W_COMMAND_CANCELLED)
        {
	_NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
	return( status );
        }	

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFMRdisplay_nodes : <0x%.8x>\n", status));
	return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_storage_areas ()

{
int     i, j;
long    status;
struct  SCfree_data_st data;
NFMlist display_struct;

static  char *fname = "NFAdisplay_storage_areas";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SA, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Storage Areas" );
      }

    NFAfill_list_struct (&display_struct, DSP_STORAGE_AREAS,
 SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", "", "", "", "", 
 "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        return( status );
        }

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFMRdisplay_storage_areas : <0x%.8x>\n", status));
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (NFMstorage, data.data[j]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_storage_areas_short ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_storage_areas_short";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SA, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Storage Areas" );
      }

    NFAfill_list_struct (&display_struct, DSP_STORAGE_AREAS, 
SELECT_SET_SINGLE_ROW, NFM_SHORT_DISPLAY, -1, "", "", "", "", 
"", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);
   
    if (status == NFI_W_COMMAND_CANCELLED)
        {
	_NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
	return( status );
        }	

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFMRdisplay_elements : <0x%.8x>\n", status));
	return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_working_areas ()

{
int     i, j;
long    status;
char    search[100];
struct  SCfree_data_st data;
NFMlist display_struct;

static  char *fname = "NFAdisplay_working_areas";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_WA, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Working Areas" );
      }

    NFAfill_list_struct (&display_struct, DSP_WORKING_AREAS,
 			 SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, 
			 "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        return( status );
        }

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFMRdisplay_working_areas : <0x%.8x>\n", status));
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (NFMworking, data.data[j]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_user_working_areas ()

{
int     i, j;
long    status;
char    search[100];
struct  SCfree_data_st data;
NFMlist display_struct;

static  char *fname = "NFAdisplay_user_working_areas";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_WA, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Working Areas" );
      }

    sprintf( search, "nfmusers.n_username IN ('PUBLIC', '%s' )", NFMuser );
    NFAfill_list_struct (&display_struct, DSP_WORKING_AREAS,
 			 SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, 
			 search, "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        return( status );
        }

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFMRdisplay_working_areas : <0x%.8x>\n", status));
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (NFMworking, data.data[j]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_users ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_users";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_USERS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Users" );
      }

    NFAfill_list_struct (&display_struct, DSP_USERS, SELECT_SET_SINGLE_ROW,
 NFM_FULL_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        return( status );
        }

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_users_short ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_users_short";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_USERS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Users" );
      }

    NFAfill_list_struct (&display_struct, DSP_USERS, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);
   
    if (status == NFI_W_COMMAND_CANCELLED)
        {
	_NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
	return( status );
        }	

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFMRdisplay_elements : <0x%.8x>\n", status));
	return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_catalogs ()

{
int    i, j;
long   status;
struct SCfree_data_st data;
char   old_cat[NFM_CATALOGNAME+1];
char   new_cat[NFM_CATALOGNAME+1];
NFMlist display_struct;

static char *fname = "NFAdisplay_catalogs";

    strcpy (old_cat, NFMcatalog);
    strcpy (new_cat, NFMcatalog);

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_CATALOGS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Catalogs" );
      }

    NFAfill_list_struct (&display_struct, DSP_CATALOGS, SELECT_SET_SINGLE_ROW,
 NFM_FULL_DISPLAY, -1, "nfmcatalogs.n_catalogname NOT LIKE '%_rl'", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        return( status );
        }

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (new_cat, data.data[j]);
            break;
            }
        }

    if (strcmp (new_cat, old_cat) != 0)
        {
        strcpy (NFMcatalog, new_cat);
        strcpy (NFMitem, "");
        strcpy (NFMrev, "");
	strcpy (NFMset, "" );
	strcpy (NFMset_rev, "" );
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_catalogs_short ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_catalogs_short";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_CATALOGS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Catalogs" );
      }

    NFAfill_list_struct (&display_struct, DSP_CATALOGS, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);
   
    if (status == NFI_W_COMMAND_CANCELLED)
        {
	_NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
	return( status );
        }	

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFMRdisplay_nodes : <0x%.8x>\n", status));
	return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_items ()

{
int    i, j;
long   status;
long   display_items_partial();
struct SCfree_data_st data;
char   old_item[NFM_ITEMNAME+1];
char   old_rev[NFM_ITEMREV+1];
char   new_item[NFM_ITEMNAME+1];
char   new_rev[NFM_ITEMREV+1];
NFMlist display_struct;

    static char *fname = "NFAdisplay_items";

    if( NFMRglobal.query_rows > 0 )
    {
	_NFIdebug(( fname, "%s\n", "Using blocked listing ..." ));
	status = display_items_partial();
	return( status );
    }

    strcpy (old_item, NFMitem);
    strcpy (old_rev, NFMrev);
    strcpy (new_item, NFMitem);
    strcpy (new_rev, NFMrev);

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ITEMS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Items in Catalog <%s>", NFMcatalog );
      }

    NFAfill_list_struct (&display_struct, DSP_ITEMS, SELECT_SET_SINGLE_ROW,
 NFM_FULL_DISPLAY, -1, NFMsearch_name, NFMsort_name, NFMcatalog, "", "", "",
 "", title);

    status = NFAdisplay_elements (&data, display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        NFAfree_list_struct (&display_struct);
        return( status );
        }

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        NFAfree_list_struct (&display_struct);
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (new_item, data.data[j+NFMitem_loc]);
            strcpy (new_rev,  data.data[j+NFMrev_loc]);
            break;
            }
        }
    NFAfree_list_struct (&display_struct);

    if ((strcmp (new_item, old_item) != 0) ||
        (strcmp (new_rev, old_rev) != 0))
        {
        strcpy (NFMitem, new_item);
        strcpy (NFMrev, new_rev);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_items_short ()

{
int    i, j;
long   status;
struct SCfree_data_st data;
char   old_item[NFM_ITEMNAME+1];
char   old_rev[NFM_ITEMREV+1];
char   new_item[NFM_ITEMNAME+1];
char   new_rev[NFM_ITEMREV+1];
NFMlist display_struct;

static char *fname = "NFAdisplay_items_short";

    strcpy (old_item, NFMitem);
    strcpy (old_rev, NFMrev);
    strcpy (new_item, NFMitem);
    strcpy (new_rev, NFMrev);

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ITEMS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Items in Catalog <%s>", NFMcatalog );
      }

    NFAfill_list_struct (&display_struct, DSP_ITEMS,
 SELECT_SET_SINGLE_ROW, NFM_SHORT_DISPLAY, -1,
 NFMsearch_name , NFMsort_name,  NFMcatalog, "", "", "", "", title);
    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        return( status );
        }

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }


    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (new_item, data.data[j+NFMitem_loc]);
            strcpy (new_rev, data.data[j+NFMrev_loc]);
            break;
            }
        }

    if ((strcmp (new_item, old_item) != 0) ||
        (strcmp (new_rev, old_rev) != 0))
        {
        strcpy (NFMitem, new_item);
        strcpy (NFMrev, new_rev);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_item_files ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_items_files";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_REVIEW_ITEM, "%s%s", NFMitem, NFMrev)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf( title, "List of Files in Item <%s.%s>", NFMitem, NFMrev );
      }

    NFAfill_list_struct (&display_struct, DSP_ITEM_FILES,
 SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", NFMcatalog,
 NFMitem, NFMrev, "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_items_partial ()

{
int    i, j=0;
int    more_items = TRUE;
long   status;
int   cursor_status;
long   save_status;
long   NFAnew_display_simple_data();
struct SCfree_data_st data;
char   old_item[NFM_ITEMNAME+1];
char   old_rev[NFM_ITEMREV+1];
char   new_item[NFM_ITEMNAME+1];
char   new_rev[NFM_ITEMREV+1];
NFMlist display_struct;
MEMptr syn_list  = NULL;
MEMptr data_list = NULL;
MEMptr fake_list = NULL;

    static char *fname = "NFAdisplay_items_partial";

    strcpy (old_item, NFMitem);
    strcpy (old_rev, NFMrev);
    strcpy (new_item, NFMitem);
    strcpy (new_rev, NFMrev);

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ITEMS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
    {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Items in Catalog <%s>", NFMcatalog );
    }

    NFAfill_list_struct (&display_struct, DSP_ITEMS_PARTIAL,
  	 SELECT_SET_MULTI_ROW, NFM_FULL_DISPLAY, NFMRglobal.query_rows, 
	 NFMsearch_name, NFMsort_name, NFMcatalog, "", "", "", "",title);

    status = NFAget_display_information (display_struct, &syn_list, 
					     &data_list);
    save_status =status;
     
    _NFIdebug((fname, "outside save_status is <0x%.8x>\n", save_status));

    if ((status != NFI_S_SUCCESS) && (status != NFM_I_NO_MORE_BUFFERS))
    {
        NFAfree_list_struct(&display_struct);
        cursor_status =  NFMRdisplay_items_partial (NFMcatalog, NFMsearch_name
                   , NFMsort_name, NFM_FULL_DISPLAY, 0,
        &syn_list, &data_list);
        MEMclose (&syn_list);
        MEMclose (&data_list);
        _NFIdebug(( fname, "NFAget_display_information : <0x%.8x>\n", status));
        return (status);
    }


    _NFIdebug(( fname, "Title <%s>\n", display_struct.title ));

    status = NFAnew_display_simple_data (&data, syn_list, data_list,
		      display_struct.select_set, display_struct.title );

    if( status != NFI_S_SUCCESS )
    {
       NFAfree_list_struct (&display_struct);
       cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
       NFMsearch_name, NFMsort_name, NFM_FULL_DISPLAY, 0,
          &syn_list, &data_list);
       MEMclose( &syn_list );
       MEMclose( &data_list );
       return(status);
    }
    else if (status == NFI_S_SUCCESS)
         {
           if (data_list->rows==0)
           {
            _NFIdebug((fname, "status is <0x%.8x>\n", status));
            return(NFI_S_SUCCESS);
           }
         }  

    if (status == NFI_W_COMMAND_CANCELLED)
    {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        NFAfree_list_struct (&display_struct);
 
        cursor_status =  NFMRdisplay_items_partial (NFMcatalog, 
		NFMsearch_name, NFMsort_name, NFM_FULL_DISPLAY, 0, 
		&syn_list, &data_list);

        _NFIdebug(( fname, "Cursor Close Status <0x%.8x>\n", cursor_status ));
        MEMclose( &syn_list );
        MEMclose( &data_list );
        _NFIdebug((fname, "STATUS5\n"));
        return( NFI_W_COMMAND_CANCELLED );
    }
    else if( save_status == NFM_I_NO_MORE_BUFFERS )
    {
        more_items = FALSE;
        _NFIdebug(( fname, "%s\n", "End of data has been reached" ));
    }

    else if(status != NFI_S_SUCCESS) 
    {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        NFAfree_list_struct (&display_struct);

        cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
        NFMsearch_name, NFMsort_name, NFM_FULL_DISPLAY, 0,
        &syn_list, &data_list);
        _NFIdebug(( fname, "Cursor Close Status <0x%.8x>\n",cursor_status ));
        MEMclose( &syn_list );
    	MEMclose( &data_list );
        return (status);
    }
        else if (status == NFI_S_SUCCESS)
         {
           if (data_list->rows ==0)
           {           
            _NFIdebug((fname, "status1 is <%0x%.8x>\n", status));
            return(NFI_S_SUCCESS);

           }
         }

    for (i=0; i<data.num_of_rows; ++i)
    {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
        {
            strcpy (new_item, data.data[j+NFMitem_loc]);
            strcpy (new_rev,  data.data[j+NFMrev_loc]);
            more_items = FALSE;
            cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
                    NFMsearch_name, NFMsort_name, NFM_FULL_DISPLAY, 0,
                    &syn_list, &data_list);
            _NFIdebug(( fname,"Cursor Close Status <0x%.8x>\n",cursor_status));
            break;
        }
    }


    NFAfree_list_struct (&display_struct);

    if ((strcmp (new_item, old_item) != 0) ||
        (strcmp (new_rev, old_rev) != 0))
    {
        strcpy (NFMitem, new_item);
        strcpy (NFMrev, new_rev);
    }

    while( more_items )
    {
        NFAfill_list_struct (&display_struct, DSP_ITEMS_PARTIAL,
 SELECT_SET_MULTI_ROW, NFM_FULL_DISPLAY, NFMRglobal.query_rows, 
 NFMsearch_name, NFMsort_name, NFMcatalog, "", "", "", "",title);

        status = NFAget_display_information (display_struct, &fake_list, 
					     &data_list);
        save_status = status;
        _NFIdebug((fname, "inside save status is <0x%.8x>\n", save_status));

        if ((status != NFI_S_SUCCESS) && (status != NFM_I_NO_MORE_BUFFERS))
        {
          NFAfree_list_struct (&display_struct);           
          cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
          NFMsearch_name, NFMsort_name, NFM_FULL_DISPLAY, 0,
          &syn_list, &data_list);
          _NFIdebug(( fname, "Cursor Close STATUS <0x%.8x>\n",cursor_status ));
          MEMclose (&syn_list);
	      MEMclose (&data_list);
          _NFIdebug(( fname, "NFAget_display_information : <0x%.8x>\n", status));
           return (status);
        }

        status = NFAnew_display_simple_data (&data, syn_list, data_list,
		      display_struct.select_set, display_struct.title );

        if( status != NFI_S_SUCCESS )
        {

          NFAfree_list_struct (&display_struct);
          cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
          NFMsearch_name, NFMsort_name, NFM_FULL_DISPLAY, 0,
          &syn_list, &data_list);
          _NFIdebug((fname, "Cursor Close Status <0x%.8x>\n", cursor_status ));
          MEMclose( &syn_list );
          MEMclose( &data_list );
          return(status);
         }
        else if (status == NFI_S_SUCCESS)
         {
          if (data_list->rows==0)
           {
             return(NFI_S_SUCCESS);
           }
         }
        if (status == NFI_W_COMMAND_CANCELLED)
        {
            _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
            NFAfree_list_struct (&display_struct);
 	        cursor_status =  NFMRdisplay_items_partial (NFMcatalog, 
     		NFMsearch_name, NFMsort_name, NFM_FULL_DISPLAY, 0, 
    		&syn_list, &data_list);
	        _NFIdebug(( fname, "Cursor3 Close Status <0x%.8x>\n", 
			cursor_status ));
     	    MEMclose( &syn_list );
	        MEMclose( &data_list );
            return( NFI_W_COMMAND_CANCELLED );
          }
	else if( save_status == NFM_I_NO_MORE_BUFFERS ) 
	{
	    more_items = FALSE;
        _NFIdebug(( fname, "Cursor Close Status <0x%.8x>\n",cursor_status ));
	    _NFIdebug(( fname, "%s\n", "End of data has been reached" ));
	}
    else if(status != NFI_S_SUCCESS) 
        {
          _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
           NFAfree_list_struct (&display_struct);
           cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
           NFMsearch_name, NFMsort_name, NFM_FULL_DISPLAY, 0,
           &syn_list, &data_list);
           _NFIdebug(( fname,"Cursor Close Status <0x%.8x>\n",cursor_status ));
     	    MEMclose( &syn_list );
	        MEMclose( &data_list );
            return(status);
        }
         else if (status == NFI_S_SUCCESS)
         {
           if (data_list->rows==0)
            {
               _NFIdebug((fname, "Status <0x%.8x>\n", status));
               return(NFI_S_SUCCESS);
             }
          }

  _NFIdebug((fname,  " what is No of new rows <%d>\n", data.num_of_rows));


        for (i=0; i<data.num_of_rows; ++i)
        {
            _NFIdebug((fname, "is i <%d>\n", i));

            j = i * data.num_of_cols;
            if (data.select_set[i] == 1)
            {
                strcpy (new_item, data.data[j+NFMitem_loc]);
                strcpy (new_rev,  data.data[j+NFMrev_loc]);
        		more_items = FALSE;
                cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
                    NFMsearch_name, NFMsort_name, NFM_FULL_DISPLAY, 0,
                    &syn_list, &data_list);
                _NFIdebug(( fname, "MA6 Cursor Close Status <0x%.8x>\n",
                        cursor_status ));
                break;
            }
        }

        NFAfree_list_struct (&display_struct);

        if ((strcmp (new_item, old_item) != 0) ||
            (strcmp (new_rev, old_rev) != 0))
        {
            strcpy (NFMitem, new_item);
            strcpy (NFMrev, new_rev);
        }

        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
     
	_NFIdebug(( fname, "%s\n", "Get another listing" ));
    } /* end while */

    _NFIdebug((fname, "%s\n", "Get out of loop"));

    MEMclose( &syn_list );
    MEMclose( &data_list );
    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_items_partial_short ()

{
int    i, j=0;
int    more_items = TRUE;
long   status;
long   cursor_status;
long   save_status;
long   NFAnew_display_simple_data();
struct SCfree_data_st data;
char   old_item[NFM_ITEMNAME+1];
char   old_rev[NFM_ITEMREV+1];
char   new_item[NFM_ITEMNAME+1];
char   new_rev[NFM_ITEMREV+1];
NFMlist display_struct;
MEMptr syn_list  = NULL;
MEMptr data_list = NULL;
MEMptr fake_list = NULL;

static char *fname = "NFAdisplay_items_partial_short";

    strcpy (old_item, NFMitem);
    strcpy (old_rev, NFMrev);
    strcpy (new_item, NFMitem);
    strcpy (new_rev, NFMrev);

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ITEMS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
    {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Items in Catalog <%s>", NFMcatalog );
    }

    NFAfill_list_struct (&display_struct, DSP_ITEMS_PARTIAL,
  	 SELECT_SET_SINGLE_ROW, NFM_SHORT_DISPLAY, NFMRglobal.query_rows, 
	 NFMsearch_name, NFMsort_name, NFMcatalog, "", "", "", "",title);

    status = NFAget_display_information (display_struct, &syn_list, 
					     &data_list);

    save_status = status;

    if ((status != NFI_S_SUCCESS) && (status != NFM_I_NO_MORE_BUFFERS))
    {
        NFAfree_list_struct(&display_struct);
        cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
        NFMsearch_name, NFMsort_name, NFM_SHORT_DISPLAY, 0,
        &syn_list, &data_list);
        MEMclose (&syn_list);
        MEMclose (&data_list);
        _NFIdebug(( fname, "NFAget_display_information : <0x%.8x>\n", status));
        return (status);
    }

    _NFIdebug(( fname, "Title <%s>\n", display_struct.title ));

    status = NFAnew_display_simple_data (&data, syn_list, data_list,
		      display_struct.select_set, display_struct.title );

    if( status != NFI_S_SUCCESS )
    {

        NFAfree_list_struct(&display_struct);
        cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
        NFMsearch_name, NFMsort_name, NFM_SHORT_DISPLAY, 0,
        &syn_list, &data_list);
        MEMclose( &syn_list );
    	MEMclose( &data_list );
        return (status);
    }
   
    else if (status== NFI_S_SUCCESS)
        {
          if (data_list->rows ==0)
             return(NFI_S_SUCCESS);
        }

    if (status == NFI_W_COMMAND_CANCELLED)
    {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        NFAfree_list_struct (&display_struct);
        cursor_status =  NFMRdisplay_items_partial (NFMcatalog, 
		NFMsearch_name, NFMsort_name, NFM_SHORT_DISPLAY, 0, 
		&syn_list, &data_list);
        _NFIdebug(( fname, "Cursor Close Status <0x%.8x>\n", cursor_status ));
        MEMclose( &syn_list );
        MEMclose( &data_list );
        return( NFI_W_COMMAND_CANCELLED );
    }
    else if( save_status == NFM_I_NO_MORE_BUFFERS )
    {
        more_items = FALSE;
        _NFIdebug(( fname, "%s\n", "End of data has been reached" ));
    }
    else if(status != NFI_S_SUCCESS) 
    {

        NFAfree_list_struct(&display_struct);
        cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
        NFMsearch_name, NFMsort_name, NFM_SHORT_DISPLAY, 0,
        &syn_list, &data_list);
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        NFAfree_list_struct (&display_struct);
        MEMclose( &syn_list );
    	MEMclose( &data_list );
        return (status);
    }
   
    else if (status == NFI_S_SUCCESS)
       {
         if (data_list->rows==0)
          return(NFI_S_SUCCESS);
       }

    for (i=0; i<data.num_of_rows; ++i)
    {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
        {
            strcpy (new_item, data.data[j+NFMitem_loc]);
            strcpy (new_rev,  data.data[j+NFMrev_loc]);
            more_items = FALSE;
            cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
                   NFMsearch_name, NFMsort_name, NFM_SHORT_DISPLAY, 0,
                    &syn_list, &data_list);
            _NFIdebug(( fname,"Cursor Close Status <0x%.8x>\n",cursor_status));
            break;
        }
    }

    NFAfree_list_struct (&display_struct);

    if ((strcmp (new_item, old_item) != 0) ||
        (strcmp (new_rev, old_rev) != 0))
    {
        strcpy (NFMitem, new_item);
        strcpy (NFMrev, new_rev);
    }

    while( more_items )
    {
        NFAfill_list_struct (&display_struct, DSP_ITEMS_PARTIAL,
 SELECT_SET_SINGLE_ROW, NFM_SHORT_DISPLAY, NFMRglobal.query_rows, 
 NFMsearch_name, NFMsort_name, NFMcatalog, "", "", "", "",title);

        status = NFAget_display_information (display_struct, &fake_list, 
					     &data_list);

        save_status = status;

        if ((status != NFI_S_SUCCESS) && (status != NFM_I_NO_MORE_BUFFERS))
        {
            MEMclose (&syn_list);
  	    MEMclose (&data_list);
            _NFIdebug(( fname, "NFAget_display_information : <0x%.8x>\n", status));
            return (status);
        }

        status = NFAnew_display_simple_data (&data, syn_list, data_list,
		      display_struct.select_set, display_struct.title );
        if( status != NFI_S_SUCCESS )
        {
       
           NFAfree_list_struct(&display_struct);
           cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
           NFMsearch_name, NFMsort_name, NFM_SHORT_DISPLAY, 0,
           &syn_list, &data_list);
   	       MEMclose( &syn_list );
	       MEMclose( &data_list );
           return (status);
        }
       
       else if (status == NFI_S_SUCCESS)
          {
            if (data_list->rows==0)
             return(NFI_S_SUCCESS);
           }

        if (status == NFI_W_COMMAND_CANCELLED)
        {
            _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
            NFAfree_list_struct (&display_struct);
 	    cursor_status =  NFMRdisplay_items_partial (NFMcatalog, 
		NFMsearch_name, NFMsort_name, NFM_SHORT_DISPLAY, 0, 
		&syn_list, &data_list);
	    _NFIdebug(( fname, "Cursor Close Status <0x%.8x>\n", 
			cursor_status ));
	    MEMclose( &syn_list );
	    MEMclose( &data_list );
            return( NFI_W_COMMAND_CANCELLED );
        }
	else if( save_status == NFM_I_NO_MORE_BUFFERS )
	{
	    more_items = FALSE;
	    _NFIdebug(( fname, "%s\n", "End of data has been reached" ));
	}
        else if(status != NFI_S_SUCCESS) 
        {

          NFAfree_list_struct (&display_struct);
          cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
          NFMsearch_name, NFMsort_name, NFM_SHORT_DISPLAY, 0,
          &syn_list, &data_list);
          _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
          NFAfree_list_struct (&display_struct);
          MEMclose( &syn_list );
	      MEMclose( &data_list );
          return (status);
         }
       
        else if (status == NFI_S_SUCCESS)
           {
             if (data_list->rows ==0)
               return(NFI_S_SUCCESS);
           }

        for (i=0; i<data.num_of_rows; ++i)
        {
            j = i * data.num_of_cols;
            if (data.select_set[i] == 1)
            {
                strcpy (new_item, data.data[j+NFMitem_loc]);
                strcpy (new_rev,  data.data[j+NFMrev_loc]);
		more_items = FALSE;
                cursor_status =  NFMRdisplay_items_partial (NFMcatalog,
                    NFMsearch_name, NFMsort_name, NFM_SHORT_DISPLAY, 0,
                    &syn_list, &data_list);
                _NFIdebug(( fname, "Cursor Close Status <0x%.8x>\n",
                        cursor_status ));
                break;
            }
        }
        NFAfree_list_struct (&display_struct);

        if ((strcmp (new_item, old_item) != 0) ||
            (strcmp (new_rev, old_rev) != 0))
        {
            strcpy (NFMitem, new_item);
            strcpy (NFMrev, new_rev);
        }

        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	_NFIdebug(( fname, "%s\n", "Get another listing" ));
    } /* end while */

    MEMclose( &syn_list );
    MEMclose( &data_list );

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_where_used_set ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_where_used_set";

    SCdisplay_msg ("Working..");


    if ((status = (long) UMSGetByNum
      (title, NFT_P_LIST_USED_SETS, "%s%s", NFMitem, NFMrev)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "Sets Where Item <%s> Revision <%s> is Used",
		 NFMset, NFMset_rev );
      }

    NFAfill_list_struct (&display_struct, DSP_WHERE_USED_SET,
 SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", NFMcatalog, NFMitem, 
 NFMrev, "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n",status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_where_used_project ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_where_used_project";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
       (title, NFT_P_LIST_USED_PRJS, "%s%s", NFMitem, NFMrev))!= UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf(title, "Projects Where Item <%s>  Revision <%s> is Used",
		NFMitem, NFMrev );
      }

    NFAfill_list_struct (&display_struct, DSP_WHERE_USED_PROJECT, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", NFMcatalog, NFMitem, 
NFMrev, "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_workflows ()

{
int    i, j;
long   status;
char   old_wf[NFM_WORKFLOWNAME+1];
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_workflows";

    strcpy (old_wf, NFMworkflow);

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_WF, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Workflows" );
      }

    NFAfill_list_struct (&display_struct, DSP_WORKFLOWS, SELECT_SET_SINGLE_ROW,
 NFM_FULL_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (NFMworkflow, data.data[j]);
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
        
    return (NFI_S_SUCCESS);
}

long display_workflows_short ()

{
int    i, j;
long   status;
char   old_wf[NFM_WORKFLOWNAME+1];
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_workflows_short";

    strcpy (old_wf, NFMworkflow);

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_WF, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Workflows" );
      }

    NFAfill_list_struct (&display_struct, DSP_WORKFLOWS, SELECT_SET_SINGLE_ROW,
 NFM_SHORT_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (NFMworkflow, data.data[j]);
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
        
    return (NFI_S_SUCCESS);
}


long display_acls ()

{
int    i, j;
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_acls";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ACLS, "%s", NFMworkflow)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of ACLs in Workflow <%s>", NFMworkflow );
      }

    NFAfill_list_struct (&display_struct, DSP_ACLS, SELECT_SET_SINGLE_ROW,
 NFM_FULL_DISPLAY, -1, "", "", "", "", "", NFMworkflow, "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (NFMacl, data.data[j]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_acls_short ()

{
int    i, j;
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_acls_short";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ACLS, "%s", NFMworkflow)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of ACLs in Workflow <%s>", NFMworkflow );
      }

    NFAfill_list_struct (&display_struct, DSP_ACLS, SELECT_SET_SINGLE_ROW,
 NFM_SHORT_DISPLAY, -1, "", "", "", "", "", NFMworkflow, "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (NFMacl, data.data[j]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_classes ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_classes";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_CLASSES, "%s", NFMworkflow)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of I/NFM Classes in Workflow <%s>",NFMworkflow );
      }

    NFAfill_list_struct (&display_struct, DSP_CLASSES, SELECT_SET_SINGLE_ROW, 
NFM_FULL_DISPLAY, -1, "", "", "", "", "", NFMworkflow, "", title );

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_classes_short ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_classes_short";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_CLASSES, "%s", NFMworkflow)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of I/NFM Classes in Workflow <%s>",NFMworkflow );
      }

    NFAfill_list_struct (&display_struct, DSP_CLASSES, SELECT_SET_SINGLE_ROW, 
NFM_SHORT_DISPLAY, -1, "", "", "", "", "", NFMworkflow, "", title );

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_search()

{
int    i,j;
long   status;
char   search[100];
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_search";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SEARCH, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Search Criteria Names" );
      }

    sprintf( search, "nfmusers.n_username IN ('PUBLIC', '%s' )", NFMuser );
    NFAfill_list_struct (&display_struct, DSP_SEARCH, SELECT_SET_SINGLE_ROW,
 NFM_FULL_DISPLAY, -1, search, "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (NFMsearch_name, data.data[j]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_sort()

{
int    i,j;
long   status;
char   search[100];
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_sort";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SORT, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Sort Criteria Names" );
      }

    sprintf( search, "nfmusers.n_username IN ('PUBLIC', '%s' )", NFMuser);
    NFAfill_list_struct (&display_struct, DSP_SORT, SELECT_SET_SINGLE_ROW,
 NFM_FULL_DISPLAY, -1, search, "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (NFMsort_name, data.data[j]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_programs ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_programs";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_PROGRAMS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Programs" );
      }

    NFAfill_list_struct (&display_struct, DSP_PROGRAMS, SELECT_SET_SINGLE_ROW, 
NFM_FULL_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_transitions ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_transitions";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_TRANSITIONS, "%s", NFMworkflow)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf(title, "List of I/NFM Transitions in Workflow <%s>", 
			NFMworkflow );
      }

    NFAfill_list_struct (&display_struct, DSP_TRANSITIONS, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", "", "", "", 
NFMworkflow, "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_transitions_short ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_transitions_short";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_TRANSITIONS, "%s", NFMworkflow)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf(title, "List of I/NFM Transitions in Workflow <%s>",
			NFMworkflow );
      }

    NFAfill_list_struct (&display_struct, DSP_TRANSITIONS, 
SELECT_SET_SINGLE_ROW, NFM_SHORT_DISPLAY, -1, "", "", "", "", "", 
NFMworkflow, "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



long display_aclusers ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_aclusers";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ACL_CLASS_USERS, "%s", NFMacl)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Class Users in ACL <%s>", NFMacl );
      }

    NFAfill_list_struct (&display_struct, DSP_ACLUSERS, SELECT_SET_SINGLE_ROW,
NFM_FULL_DISPLAY, -1, "", "", "", "", "", "", NFMacl, title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_signoff_users ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_signoff_users";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ACL_SO_USERS, "%s", NFMacl)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Signoff Users in ACL <%s>", NFMacl );
      }

    NFAfill_list_struct (&display_struct, DSP_SIGNOFF_USERS, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", "", "", "", "", NFMacl,
title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n",status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_projects ()

{
int    i,j;
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_projects";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_PROJECTS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Projects" );
      }

    NFAfill_list_struct (&display_struct, DSP_PROJECTS, SELECT_SET_SINGLE_ROW,
NFM_FULL_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (NFMproject, data.data[j]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_project_members ()

{
long   status;
long   display_project_members_partial();
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_project_members";

    if( NFMRglobal.query_rows > 0 )
    {
	_NFIdebug(( fname, "%s\n", "Using blocked listing ..." ));
	status = display_project_members_partial();
	return( status );
    }

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_PRJ_MEM, "%s", NFMproject)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Items in Project <%s>", NFMproject );
      }

    NFAfill_list_struct (&display_struct, DSP_PROJECT_MEMBERS, 
SELECT_SET_SINGLE_ROW, NFM_SHORT_DISPLAY, -1, "", "", NFMproject, "", "", 
"", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long display_project_members_partial ()

{
int    i, j;
int    more_items = TRUE;
long   status;
long   cursor_status;
long   save_status;
long   NFAnew_display_simple_data();
struct SCfree_data_st data;
NFMlist display_struct;
MEMptr syn_list  = NULL;
MEMptr data_list = NULL;
MEMptr fake_list = NULL;

static char *fname = "NFAdisplay_project_members_partial";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_PRJ_MEM, "%s", NFMproject))!= UMS_S_SUCCESS)
    {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Items in Project <%s>", NFMproject );
    }

    NFAfill_list_struct (&display_struct, DSP_PROJECT_MEMBERS_PARTIAL, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, NFMRglobal.query_rows, 
"", "", NFMproject, "", "", "", "", title);

    status = NFAget_display_information (display_struct, &syn_list,&data_list);
    if ((status != NFI_S_SUCCESS) && (status != NFM_I_NO_MORE_BUFFERS))
    {
        MEMclose (&syn_list);
        MEMclose (&data_list);
        _NFIdebug(( fname, "NFAget_display_information : <0x%.8x>\n", status));
        return (status);
    }

    save_status = status;

    _NFIdebug(( fname, "Title <%s>\n", display_struct.title ));

    status = NFAnew_display_simple_data (&data, syn_list, data_list,
		      display_struct.select_set, display_struct.title );
    if( status != NFI_S_SUCCESS )
    {
        MEMclose( &syn_list );
	MEMclose( &data_list );
        return (status);
    }

    if (status == NFI_W_COMMAND_CANCELLED)
    {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        NFAfree_list_struct (&display_struct);
        cursor_status =  NFMRdisplay_project_members_partial (NFMproject, 
		"", "", 0, &syn_list, &data_list);
        _NFIdebug(( fname, "Cursor Close Status <0x%.8x>\n", cursor_status ));
        MEMclose( &syn_list );
        MEMclose( &data_list );
        return( NFI_W_COMMAND_CANCELLED );
    }
    else if( save_status == NFM_I_NO_MORE_BUFFERS )
    {
        more_items = FALSE;
        _NFIdebug(( fname, "%s\n", "End of data has been reached" ));
    }
    else if(status != NFI_S_SUCCESS) 
    {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        NFAfree_list_struct (&display_struct);
        MEMclose( &syn_list );
	MEMclose( &data_list );
        return (status);
    }

    NFAfree_list_struct (&display_struct);

    while( more_items )
    {
        NFAfill_list_struct (&display_struct, DSP_PROJECT_MEMBERS_PARTIAL, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, NFMRglobal.query_rows, 
"", "", NFMproject, "", "", "", "", title);

        status = NFAget_display_information (display_struct, &fake_list, 
					     &data_list);
        if ((status != NFI_S_SUCCESS) && (status != NFM_I_NO_MORE_BUFFERS))
        {
            MEMclose (&syn_list);
  	    MEMclose (&data_list);
            _NFIdebug(( fname, "NFAget_display_information : <0x%.8x>\n", status));
            return (status);
        }

        save_status = status;

        status = NFAnew_display_simple_data (&data, syn_list, data_list,
		      display_struct.select_set, display_struct.title );
        if( status != NFI_S_SUCCESS )
        {
	    MEMclose( &syn_list );
	    MEMclose( &data_list );
            return (status);
        }
        if (status == NFI_W_COMMAND_CANCELLED)
        {
            _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
            NFAfree_list_struct (&display_struct);
 	    cursor_status =  NFMRdisplay_project_members_partial (NFMproject, 
		"", "", 0, &syn_list, &data_list);
	    _NFIdebug(( fname, "Cursor Close Status <0x%.8x>\n", 
			cursor_status ));
	    MEMclose( &syn_list );
	    MEMclose( &data_list );
            return( NFI_W_COMMAND_CANCELLED );
        }
	else if( save_status == NFM_I_NO_MORE_BUFFERS )
	{
	    more_items = FALSE;
	    _NFIdebug(( fname, "%s\n", "End of data has been reached" ));
	}
        else if(status != NFI_S_SUCCESS) 
        {
            _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
            NFAfree_list_struct (&display_struct);
	    MEMclose( &syn_list );
	    MEMclose( &data_list );
            return (status);
        }

        NFAfree_list_struct (&display_struct);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	_NFIdebug(( fname, "%s\n", "Get another listing" ));
    } /* end while */

    MEMclose( &syn_list );
    MEMclose( &data_list );

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



long display_catalog_acl_mapping ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_catalog_acl_mapping";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_CAT_ACL_MAP, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of ACL Mappings for Catalog <%s>", NFMcatalog );
      }

    NFAfill_list_struct (&display_struct, DSP_CATALOG_ACL_MAP, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", NFMcatalog, 
"", "", "", "",title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_catalog_sa_mapping ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_catalog_sa_mapping";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_CAT_SA_MAP, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Storage Area Mappings for Catalog <%s>", 
		 NFMcatalog );
      }

    NFAfill_list_struct (&display_struct, DSP_CATALOG_SA_MAP, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", NFMcatalog, 
"", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_project_acl_mapping ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_project_acl_mapping";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_PRJ_ACL_MAP, "%s", NFMproject)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of ACL Mappings for Project <%s>", NFMproject );
      }

    NFAfill_list_struct (&display_struct, DSP_PROJECT_ACL_MAP, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", NFMproject, 
"", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n",status));
        return (status);
        }


    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_project_sa_mapping ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_project_sa_mapping";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_PRJ_SA_MAP, "%s", NFMproject)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Storage Area Mappings for Project <%s>",
		 NFMproject );
      }

    NFAfill_list_struct (&display_struct, DSP_PROJECT_SA_MAP, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", NFMproject, 
"", "", "", "",title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_sets ()

{
int    i,j;
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_sets";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SETS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Sets in Catalog <%s>", NFMcatalog );
      }

    NFAfill_list_struct (&display_struct, DSP_SETS, SELECT_SET_SINGLE_ROW, 
NFM_FULL_DISPLAY, -1, "", "", NFMcatalog, "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (NFMset, data.data[j+NFMitem_loc]);
            strcpy (NFMset_rev, data.data[j+NFMrev_loc]);
	    strcpy (NFMset_cat, NFMcatalog ); 
	    NFMset_ind = 1;
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_set_members ()

{
long   status;
long   display_set_members_partial();
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_set_members";

    if( NFMRglobal.query_rows > 0 )
    {
	_NFIdebug(( fname, "%s\n", "Using blocked listing ..." ));
	status = display_set_members_partial();
	return( status );
    }

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SET_MEM, "%s%s", NFMset, NFMset_rev)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Items in Set <%s.%s>", 
			 NFMset, NFMset_rev );
      }

    NFAfill_list_struct (&display_struct, DSP_SET_MEMBERS, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", NFMcatalog, NFMset, 
NFMset_rev, "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_set_members_partial ()

{
int    i, j;
int    more_items = TRUE;
long   status;
long   cursor_status;
long   NFAnew_display_simple_data();
long   save_status;
struct SCfree_data_st data;
NFMlist display_struct;
MEMptr syn_list  = NULL;
MEMptr data_list = NULL;
MEMptr fake_list = NULL;

static char *fname = "NFAdisplay_set_members_partial";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SET_MEM, "%s%s", NFMset, NFMset_rev)) != UMS_S_SUCCESS)
    {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Items in Set <%s.%s>", NFMset, NFMset_rev );
    }

    NFAfill_list_struct (&display_struct, DSP_SET_MEMBERS_PARTIAL,
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, NFMRglobal.query_rows, 
"", "", NFMcatalog, NFMset, NFMset_rev, "", "",title);

    status = NFAget_display_information (display_struct, &syn_list, 
					     &data_list);
    if ((status != NFI_S_SUCCESS) && (status != NFM_I_NO_MORE_BUFFERS))
    {
        MEMclose (&syn_list);
        MEMclose (&data_list);
        _NFIdebug(( fname, "NFAget_display_information : <0x%.8x>\n", status));
        return (status);
    }

    save_status = status;

    _NFIdebug(( fname, "Title <%s>\n", display_struct.title ));

    status = NFAnew_display_simple_data (&data, syn_list, data_list,
		      display_struct.select_set, display_struct.title );
    if( status != NFI_S_SUCCESS )
    {
        MEMclose( &syn_list );
	MEMclose( &data_list );
        return (status);
    }

    if (status == NFI_W_COMMAND_CANCELLED)
    {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        NFAfree_list_struct (&display_struct);
        cursor_status =  NFMRdisplay_set_members_partial (NFMcatalog, 
		NFMset, NFMset_rev, "", "",	0, &syn_list, &data_list);
        _NFIdebug(( fname, "Cursor Close Status <0x%.8x>\n", cursor_status ));
        MEMclose( &syn_list );
        MEMclose( &data_list );
        return( NFI_W_COMMAND_CANCELLED );
    }
    else if( save_status == NFM_I_NO_MORE_BUFFERS )
    {
        more_items = FALSE;
        _NFIdebug(( fname, "%s\n", "End of data has been reached" ));
    }
    else if(status != NFI_S_SUCCESS) 
    {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        NFAfree_list_struct (&display_struct);
        MEMclose( &syn_list );
	MEMclose( &data_list );
        return (status);
    }

    NFAfree_list_struct (&display_struct);

    while( more_items )
    {
        NFAfill_list_struct (&display_struct, DSP_SET_MEMBERS_PARTIAL,
 SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, NFMRglobal.query_rows, 
 NFMsearch_name, NFMsort_name, NFMcatalog, NFMset, NFMset_rev, "", "",title);

        status = NFAget_display_information (display_struct, &fake_list, 
					     &data_list);
        if ((status != NFI_S_SUCCESS) && (status != NFM_I_NO_MORE_BUFFERS))
        {
            MEMclose (&syn_list);
  	    MEMclose (&data_list);
            _NFIdebug(( fname, "NFAget_display_information : <0x%.8x>\n", status));
            return (status);
        }

        save_status = status;

        status = NFAnew_display_simple_data (&data, syn_list, data_list,
		      display_struct.select_set, display_struct.title );
        if( status != NFI_S_SUCCESS )
        {
	    MEMclose( &syn_list );
	    MEMclose( &data_list );
            return (status);
        }

        if (status == NFI_W_COMMAND_CANCELLED)
        {
            _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
            NFAfree_list_struct (&display_struct);
 	    cursor_status =  NFMRdisplay_set_members_partial (NFMcatalog, 
		NFMset, NFMset_rev, "", "", 0, &syn_list, &data_list);
	    _NFIdebug(( fname, "Cursor Close Status <0x%.8x>\n", 
			cursor_status ));
	    MEMclose( &syn_list );
	    MEMclose( &data_list );
            return( NFI_W_COMMAND_CANCELLED );
        }
	else if( save_status == NFM_I_NO_MORE_BUFFERS )
	{
	    more_items = FALSE;
	    _NFIdebug(( fname, "%s\n", "End of data has been reached" ));
	}
        else if(status != NFI_S_SUCCESS) 
        {
            _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
            NFAfree_list_struct (&display_struct);
	    MEMclose( &syn_list );
	    MEMclose( &data_list );
            return (status);
        }

        NFAfree_list_struct (&display_struct);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	_NFIdebug(( fname, "%s\n", "Get another listing" ));
    } /* end while */

    MEMclose( &syn_list );
    MEMclose( &data_list );

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long display_signoff_on_item ()

{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_signoff_on_item";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SO_ON_ITEM, NULL, NULL))
	 != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Signoffs" );
      }

    NFAfill_list_struct (&display_struct, DSP_SO_ON_ITEM, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", NFMcatalog, 
NFMitem, NFMrev, "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
      }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}


long display_signoff_history ()
{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_signoff_history";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SO_HISTORY, NULL, NULL))
	 != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Signoff History");
      }

    NFAfill_list_struct (&display_struct, DSP_SO_HISTORY, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", NFMcatalog, 
NFMitem, NFMrev, "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
      }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}

long display_archives ()
{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_archives";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ARCHIVES, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Archives" );
      }

    NFAfill_list_struct (&display_struct, DSP_ARCHIVES, SELECT_SET_SINGLE_ROW,
NFM_FULL_DISPLAY, -1, "", "", "", "", "", "", "", title );

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
      }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}

long display_saveset_entries ()
{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_saveset_entries";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SAVESETS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Saveset Entries" );
      }

    NFAfill_list_struct (&display_struct, DSP_SAVESETS, SELECT_SET_SINGLE_ROW,
NFM_FULL_DISPLAY, -1, "", "", "", "", "", "", "", title );

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
      }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}


long display_items_on_tape ()
{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_items_on_tape";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ITEMS_ON_TAPE, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Items on Tape" );
      }

    NFAfill_list_struct (&display_struct, DSP_ITEMS_ON_TAPE, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", "", "", 
"", "", "", title );

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
      }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}


long display_archive_flags ()
{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_archive_flags";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ARCHIVE_FLAGS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Items Flagged for Archive" );
      }

    NFAfill_list_struct (&display_struct, DSP_ARCHIVE_FLAGS, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", "", "", 
"", "", "", title );

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
      }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}

long display_backup_flags ()
{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_backup_flags";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_BACKUP_FLAGS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Items Flagged for Backup" );
      }

    NFAfill_list_struct (&display_struct, DSP_BACKUP_FLAGS, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", "", "", 
"", "", "", title );

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
      }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}


long display_restore_flags ()
{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_restore_flags";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_RESTORE_FLAGS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Items Flagged for Restore" );
      }

    NFAfill_list_struct (&display_struct, DSP_RESTORE_FLAGS, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", "", "", 
"", "", "", title );

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
      }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}


long display_delete_flags ()
{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_delete_flags";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_DELETE_FLAGS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Items Flagged for Delete" );
      }

    NFAfill_list_struct (&display_struct, DSP_DELETE_FLAGS, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", "", "", 
"", "", "", title );

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
      }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}


long display_local_files ()
{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_local_files";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_LOCAL_FILES, "%s", NFMworking )) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Local Files in Working Area <%s>",
			NFMworking );
      }

    NFAfill_list_struct (&display_struct, DSP_LOCAL_FILES, 
SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, -1, "", "", "", "", 
"", "", "", title );

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
      }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}


long display_labels ()
{
long   status;
struct SCfree_data_st data;
NFMlist display_struct;

static char *fname = "NFAdisplay_labels";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_LABELS, "", "" )) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Labels" );
      }

    NFAfill_list_struct (&display_struct, DSP_LABELS, SELECT_SET_SINGLE_ROW, 
NFM_FULL_DISPLAY, -1, "", "", "", "", "", "", "", title );

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_COMMAND_CANCELLED)
        return( status );

    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
      }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}

