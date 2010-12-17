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
#include "NFMtitles.h"
#include "UMS.h"
#include "ERR.h"
#include "NFMdisplays.h"
#include "NFIcommands.h"
#include "NFIerrordef.h"
#include "DEBUG.h"

extern long sqlstatus;
extern char NFMprogram_num[21];
extern char NFMprogram[21];
char title[80];

long ADMactivate_catalog ()
{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;
static char *fname = "ADMactivate_catalog";

    _NFMdebug ((fname, "ENTER\n"));

    if (strcmp (NFMcatalog, "") != 0)
        return (NFI_S_SUCCESS);


    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_CATALOGS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Catalogs" );
      }
    SCdisplay_msg ("Working..");

    NFMfill_list_struct (&list_struct, DSP_CATALOGS, SELECT_SET_SINGLE_ROW, 
                  NFM_SHORT_DISPLAY, "", "", "", "", "", "", "", title);

    status = ADMchoose_elements (&data, list_struct);

    NFMfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFMdebug ((fname, "ADMchoose_elements : <0x%.8x>\n", status));
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

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);
}


long ADMactivate_item ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;
static char *fname = "ADMactivate_item";

    _NFMdebug ((fname, "ENTER\n"));

    if (strcmp (NFMitem, "") != 0)
        return (NFI_S_SUCCESS);

    status = ADMactivate_catalog ();
    if (status != NFI_S_SUCCESS)
        return (status);


    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ITEMS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Items" );
      }        
    SCdisplay_msg ("Working..");

    NFMfill_list_struct (&list_struct, DSP_ITEMS, SELECT_SET_SINGLE_ROW,
             NFM_SHORT_DISPLAY, "", "", NFMcatalog, "", "", "", "", title);

    status = ADMchoose_elements (&data, list_struct);

    NFMfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFMdebug ((fname, "ADMchoose_elements : <0x%.8x>\n", status));
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

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);
}


long ADMactivate_transition ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;
static char *fname = "ADMactivate_transition";

    _NFIdebug ((fname, "ENTER\n"));


    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_TRANSITIONS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM TRANSITION" );
      }

    SCdisplay_msg ("Working..");

    NFMfill_list_struct (&list_struct, DSP_TRANSITIONS, SELECT_SET_SINGLE_ROW,
               0, "", "", "", "", "", NFMworkflow, "",title);

    status = ADMchoose_elements (&data, list_struct);

    NFMfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug ((fname, "ADMchoose_elements : <0x%.8x>\n", status));
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
            strcpy (NFMprogram_num, data.data[j]);
            strcpy (NFMprogram, data.data[j+1]);
            break;
            }
        }

    _NFIdebug ((fname, "Program : <%s:%s>\n", NFMprogram_num, NFMprogram));

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);
}


long ADMactivate_program ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;
static char *fname = "ADMactivate_program";

    _NFMdebug ((fname, "ENTER\n"));


    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_PROGRAMS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM program" );
      }

    SCdisplay_msg ("Working..");

    NFMfill_list_struct (&list_struct, DSP_PROGRAMS, SELECT_SET_SINGLE_ROW,
       1, "", "", "", "", "", "", "",title);

    status = ADMchoose_elements (&data, list_struct);

    NFMfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFMdebug ((fname, "ADMchoose_elements : <0x%.8x>\n", status));
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
            strcpy (NFMprogram_num, data.data[j]);
            strcpy (NFMprogram, data.data[j+1]);
            break;
            }
        }

    _NFIdebug ((fname, "Program : <%s:%s>\n", NFMprogram_num, NFMprogram));

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);
}


long ADMactivate_workflow ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;
char   search_str[100];
static char *fname = "ADMactivate_workflow";

    _NFMdebug ((fname, "ENTER\n"));

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_WF, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Workflows" );
      }
    SCdisplay_msg ("Working..");

    strcpy (search_str, "nfmworkflow.n_workflowtype = 'I'");
    NFMfill_list_struct (&list_struct, DSP_WORKFLOWS, SELECT_SET_SINGLE_ROW,
        NFM_SHORT_DISPLAY, search_str, "", "", "", "", "", "",title);

    status = ADMchoose_elements (&data, list_struct);

    NFMfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFMdebug ((fname, "ADMchoose_elements : <0x%.8x>\n", status));
        if (status == NFM_E_NO_WORKFLOWS_FOUND)
	    return( status );
        else if( status == NFI_W_FORM_CANCELED )
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

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);

}


long ADMactivate_acl ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;
static char *fname = "ADMactivate_acl";

    _NFMdebug ((fname, "ENTER\n"));

    if (strcmp (NFMacl, "") != 0)
        return (NFI_S_SUCCESS);

    status = ADMactivate_workflow ();
    if( status != NFI_S_SUCCESS)
        return(status);


    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ACLS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM ACLs" );
      }

    SCdisplay_msg ("Working..");

    NFMfill_list_struct (&list_struct, DSP_ACLS, SELECT_SET_SINGLE_ROW, 0, "",
                         "", "", "", "", NFMworkflow, "",title);

    status = ADMchoose_elements (&data, list_struct);

    NFMfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug ((fname, "ADMchoose_elements : <0x%.8x>\n", status));
        if (status == NFM_E_NO_ACLS_FOUND_IN_WF)
	    return( status );
        else if( status == NFI_W_FORM_CANCELED )
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

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (ROW_CHOSEN)
        return (NFI_S_SUCCESS);
    else
        return (NFI_E_FAILURE);

}
