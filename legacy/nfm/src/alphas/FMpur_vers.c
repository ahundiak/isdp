#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMRlist.h"
#include "NFMdisplays.h"
#include "NFMtitles.h"
#include "UMS.h"
#include "WFcommands.h"

long purge_versions ()

{
int    i;
int    j;
long   status;
char   title[80];
char   item[NFM_ITEMNAME+1];
char   rev[NFM_ITEMREV+1];
struct SCfree_data_st fdata;
NFMlist list_struct;
static  char *fname = "NFApurge_versions";

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ITEMS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Items" );
      }

    SCdisplay_msg ("Working..");    

    NFAfill_list_struct (&list_struct, DSP_ITEMS, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, NFMsearch_name, NFMsort_name, NFMcatalog,
        "", "", "", "", title);

    status = NFAdisplay_elements (&fdata, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
        NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        free (fdata.data);
        return (status);
        }

    for (i=0; i<fdata.num_of_rows; ++i)
    {
        j = i * fdata.num_of_cols;
        if (fdata.select_set[i] == 1)
	{
	    strcpy( item, fdata.data[j+1] );
	    strcpy( rev,  fdata.data[j+2] );
	    break;
	}
    }

    SCdisplay_msg ("Working..");    

    status = NFAalpha_validate_user_access (NFMuser_id, PURGE_FILE_VERSIONS,
                NFMworkflow, NFMproject, NFMcatalog, item, rev );
    if (status != NFI_S_SUCCESS)
        return (status);

    status = NFMRpurge_versions (NFMcatalog, item, rev );

    _NFIdebug(( fname, "Return from NFMRpurge_versions -> 0x%.8x\n", status));

    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



