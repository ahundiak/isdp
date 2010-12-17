#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMdisplays.h"
#include "NFMRlist.h"
#include "ERR.h"
#include "NFMtitles.h"
#include "NFMschema.h"
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
	NFM_FULL_DISPLAY, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);
   
    if (status == NFI_W_FORM_CANCELED)
        {
	_NFMRdebug(( fname, "%s\n", "FORM_CANCELED" ));
	return( status );
        }	

    if (status != NFI_S_SUCCESS)
        {
        _NFMRdebug(( fname, "NFMRdisplay_nodes : <0x%.8x>\n", status));
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
        strcpy (title, "Choose Storage Location To Bulkload From." );
      }

    NFAfill_list_struct (&display_struct, DSP_STORAGE_AREAS,
 SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_FORM_CANCELED)
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
 NFM_FULL_DISPLAY, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_FORM_CANCELED)
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
struct SCfree_data_st data;
char   old_item[NFM_ITEMNAME+1];
char   old_rev[NFM_ITEMREV+1];
char   new_item[NFM_ITEMNAME+1];
char   new_rev[NFM_ITEMREV+1];
NFMlist display_struct;

static char *fname = "NFAdisplay_items";

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
 NFM_FULL_DISPLAY, NFMsearch_name, NFMsort_name, NFMcatalog, "", "", "", "",
title);

    status = NFAdisplay_elements (&data, display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_FORM_CANCELED)
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
            strcpy (new_item, data.data[j]);
            strcpy (new_rev, data.data[j+1]);
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

long display_working_areas ()

{
int     i,  j;
long    status;
struct  SCfree_data_st data;
char    search[100];
NFMlist display_struct;

static  char *fname = "NFAdisplay_working_areas";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title,  NFT_P_LIST_WA,  NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname,  "UMSGetByNum = <0x%.8x>\n",  status));
        strcpy (title,  "List of I/NFM Working Areas" );
      }
        sprintf( search, "nfmusers.n_username IN ('PUBLIC', '%s' )", NFMuser );

        NFAfill_list_struct(&display_struct,DSP_WORKING_AREAS,
        SELECT_SET_SINGLE_ROW, NFM_FULL_DISPLAY, search, "",  "",  
                         "",  "",  "", "",  title);
  

    status = NFAdisplay_elements (&data,  display_struct);

    NFAfree_list_struct (&display_struct);

    if (status == NFI_W_FORM_CANCELED)
        {
        _NFIdebug(( fname,  "%s\n",  "FORM_CANCELED" ));
        return( status );
        }
 if (status != NFI_S_SUCCESS)
        {
       _NFIdebug(( fname,  "NFMRdisplay_storage_areas : <0x%.8x>\n",  status));
        return (status);
        }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (NFMworking,  data.data[j]);
            break;
            }
        }

    NFAfree_list (data.data,  data.num_of_rows,  data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
  _NFIdebug(( fname,  "%s\n",  msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}

