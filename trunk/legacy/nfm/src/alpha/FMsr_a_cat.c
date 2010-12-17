#include "machine.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "WFcommands.h"
#include "NFMdisplays.h"
#include "NFMRlist.h"
#include "NFMtitles.h"
#include "UMS.h"

char     title[80];

long search_across_catalogs ()

{
int    i,j=0;
long   status;
int    ROW_CHOSEN = FALSE;
long   NFAnew_display_simple_data();
char   fmt[20];
char   old_item[NFM_ITEMNAME+1];
char   old_rev[NFM_ITEMREV+1];
char   old_cat[NFM_CATALOGNAME+1];
char   new_item[NFM_ITEMNAME+1];
char   new_rev[NFM_ITEMREV+1];
char   new_cat[NFM_CATALOGNAME+1];
struct SCfree_data_st data;
struct SCfree_data_st new_data;
MEMptr catalog_list = NULL;
MEMptr syn_list     = NULL;
MEMptr data_list    = NULL;

static char *fname = "NFAsearch_across_catalogs";

    SCdisplay_msg ("Working..");    

    strcpy (old_cat, NFMcatalog);
    strcpy (old_item, NFMitem);
    strcpy (old_rev, NFMrev);
    strcpy (new_cat, NFMcatalog);
    strcpy (new_item, NFMitem);
    strcpy (new_rev, NFMrev);


    if( NFMRglobal.query_rows > 0 )
    {
    _NFIdebug(( fname, "%s\n", "Using blocked listing ..." ));
    status =search_across_catalogs_partial();
    return( status );
    }

    status = NFMRdisplay_catalogs ( "", "", NFM_FULL_DISPLAY, 
				    &syn_list, &data_list);
    /*MEMprint_buffers("data1", data_list, "/dev/console");*/

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&syn_list);
        MEMclose (&data_list);
	return (status);
        }

    strcpy( title, "Choose Catalogs to be Searched" ); 

    status = NFAnew_display_simple_data (&data, syn_list, data_list,
                   SELECT_SET_MULTI_ROW, title );
/* MEMprint_buffers("syn_list", syn_list, "/dev/console");
 MEMprint_buffers("data_list", data_list, "/dev/console");*/
    if( status != NFI_S_SUCCESS )
    {
        MEMclose( &syn_list );
        MEMclose( &data_list );
        return (status);
    }

    MEMclose( &syn_list );
    MEMclose( &data_list );

    status = MEMopen( &catalog_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	_NFIdebug(( fname, "MEMopen <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME);
    status = MEMwrite_format (catalog_list, "n_catalogname", fmt);
    if( status != MEM_S_SUCCESS )
    {
	_NFIdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
	MEMclose( &catalog_list );
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
            {
	 	status = MEMwrite (catalog_list, data.data[j]);
	        if( status != MEM_S_SUCCESS )
              	  {
			_NFIdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
			MEMclose( &catalog_list );
			ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
			return( NFM_E_MEM );
		    }
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    status = NFMRmultiple_catalog_search ( catalog_list, NFMsearch_name,
		NFMsort_name, &data_list, &syn_list );
  /*  MEMprint_buffers("catalog_list", catalog_list, "/dev/console");
    MEMprint_buffers("syn_list1", syn_list, "/dev/console");
    MEMprint_buffers("data_list1", data_list, "/dev/console");*/

    _NFIdebug(( fname, "Return from NFMRmultiple_cat_search -> 0x%.8x\n", 
		    status));
    
    if (status != NFM_S_SUCCESS)
        return (status);

    strcpy( title, "List of I/NFM Items" ); 

    status = NFAnew_display_simple_data (&new_data, syn_list, data_list,
                   SELECT_SET_SINGLE_ROW, title );

    for (i=0; i<new_data.num_of_rows; ++i)
     {
       j = i * new_data.num_of_cols;
       if ((new_data.select_set[i] == 1) || (new_data.sts == FORM_SELECTED))
         {
            strcpy (new_cat, new_data.data[j]);
            strcpy (new_item, new_data.data[j+1]);
            strcpy (new_rev,  new_data.data[j+2]);
            break;
            }
        }
  /*  MEMprint_buffers("syn_list2", syn_list, "/dev/console");
    MEMprint_buffers("data_list2", data_list, "/dev/console");*/
    if( status != NFI_S_SUCCESS )
    {
        MEMclose( &syn_list );
        MEMclose( &data_list );
        return (status);
    }

    NFAfree_list (new_data.data, new_data.num_of_rows, new_data.num_of_cols);
    free (new_data.data);
    MEMclose( &syn_list );
    MEMclose( &data_list );


    if ((strcmp (new_cat, old_cat) !=0) ||
        (strcmp (new_item, old_item) != 0) ||
        (strcmp (new_rev, old_rev) != 0))
    {
        strcpy (NFMcatalog, new_cat);
        strcpy (NFMitem, new_item);
        strcpy (NFMrev, new_rev);
    }
    
    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



