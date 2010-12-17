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

long NFAactivate_search_ac_cat ()

{
int    i, j;
int    ROW_CHOSEN = FALSE;
long   status;
struct SCfree_data_st data;
NFMlist list_struct;

static  char *fname = "NFAactivate_search_ac_cat";

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
/*         else
          {
            ROW_CHOSEN = FALSE;
            break;
           }*/
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

/*    if (ROW_CHOSEN)*/
        return (NFI_S_SUCCESS);
/*    else
        return (NFI_E_FAILURE);*/
     return (status);
  }
