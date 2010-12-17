#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"
#include "NFMRlist.h"
#include "ERR.h"
#include "NFMdisplays.h"
#include "UMS.h"
#include "NFMtitles.h"

extern long sqlstatus;
char   title[80];

long NFAactivate_project ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;
static  char *fname = "nfm_activate_project";

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
	NFM_SHORT_DISPLAY, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
     {
      _NFIdebug ((fname, "NFAdisplay_elements : <0x%.8x>", status));
      if (status == NFM_E_NO_PROJECTS_FOUND)
          return( status );
      else if( status == NFI_W_FORM_CANCELED )
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
    _NFMR_str ("%s", msg);
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

static  char *fname = "nfm_activate_catalog";

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
	NFM_SHORT_DISPLAY, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug ((fname,"NFAdisplay_elements : <0x%.8x>", status));
        if (status == NFM_E_NO_CATALOGS_FOUND)
	    return( status );
        else if( status == NFI_W_FORM_CANCELED )
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
    _NFMR_str ("%s", msg);
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

static  char *fname = "nfm_activate_item";

    if (strcmp (NFMitem, "") != 0)
        return (NFI_S_SUCCESS);

    status = NFAactivate_catalog ();
    if (status != NFI_S_SUCCESS)
        return (status);
        
    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ITEMS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Items" );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_ITEMS, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, "", "", NFMcatalog, "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug ((fname, "NFAdisplay_elements : <0x%.8x>", status));
        if (status == NFM_E_NO_ITEMS_FOUND_IN_CAT)
	    return( status );
        else if( status == NFI_W_FORM_CANCELED )
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
    _NFIdebug ((fname, "%s\n", msg));
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

static  char *fname = "nfm_activate_sa";

/*    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SA, NULL)) != UMS_S_SUCCESS)
      {*/
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "Choose Storage Location To Bulkload From." );
/*      }*/

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_STORAGE_AREAS, 
	SELECT_SET_SINGLE_ROW, NFM_SHORT_DISPLAY, "", "", "", "", "", "",
	"", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug ((fname, "NFAdisplay_elements : <0x%.8x>", status));
        if (status == NFM_E_NO_STORAGE_AREAS_FOUND)
	    return( status );
        else if( status == NFI_W_FORM_CANCELED )
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
    _NFIdebug ((fname, "%s\n", msg));
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
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "nfm_activate_wa";

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_WA, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Working Areas" );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_WORKING_AREAS,
        SELECT_SET_SINGLE_ROW, NFM_SHORT_DISPLAY, "", "", "", "", "", "",
        "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        if (status == NFM_E_NO_STORAGE_AREAS_FOUND)
            return( status );
        else if( status == NFI_W_FORM_CANCELED )
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

