#include "machine.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "WFcommands.h"
#include "NFMdisplays.h"
#include "NFMRlist.h"
#include "NFMtitles.h"
#include "UMS.h"

extern   struct NFMwf_info   NFAwf_info;
extern   struct NFMoperation NFAoperation;

long checkout_item ()

{
long   status;
long   catalog_no = -1;
int    confirm;
static char *fname = "NFAcheckout_item";

    SCdisplay_msg ("Working..");    

    NFAconfirm( "check out this item", &confirm );
    if( confirm == 0 )
        return( NFI_S_SUCCESS );

    SCdisplay_msg ("Working..");

    NFAset_global_config_info( NFM_WORKFLOW, CHECKOUT_ITEM,
	   		       NFMworkflow, "", "NFM" );

    status = NFMRcheckout_item( NFMcatalog, catalog_no, NFMitem,
		NFMrev, NFMworking, NFAwf_info, NFAoperation );

    _NFIdebug(( fname, "Return from NFMRcheckout_item -> 0x%.8x\n", 
		    status));
    if (status != NFM_S_SUCCESS)
        return (status);

    NFMset_ind = 0;

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg ));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long checkout_item_from_list ()

{
int    i;
int    j;
int    k;
int    count;
int    subsystem;
long   err_no;
long   status;
long   catalog_no = -1;
int    confirm;
char   title[80];
struct SCfree_data_st data;
struct SCfree_data_st err_data;
NFMlist display_struct;

static char *fname = "NFAcheckout_item_from_list";

    SCdisplay_msg ("Working..");    

    NFAset_global_config_info( NFM_WORKFLOW, CHECKOUT_ITEM,
	   		       NFMworkflow, "", "NFM" );

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ITEMS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Items in Catalog <%s>", NFMcatalog );
      }

    NFAfill_list_struct (&display_struct, DSP_ITEMS, SELECT_SET_MULTI_ROW,
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

    for( i=0,count=0; i<data.num_of_rows; ++i )
        if(( data.select_set[i] == 1 ) || (data.sts == FORM_SELECTED))
            ++count;

    if( count == 0 )
    {
        NFAfree_list_struct (&display_struct);
        return( NFI_S_SUCCESS );
    }

    NFAconfirm( "check out these item(s)", &confirm );
    if( confirm == 0 )
    {
	NFAfree_list_struct( &display_struct );
        return( NFI_S_SUCCESS );
    }

    /* set up error form */
    NFAprepare_error_form ( data, &err_data, count, 
			    "Status of Checkout Item(s)");

    strcpy( title, "Working" );
    for (i=0,k=0; i<data.num_of_rows; ++i)
    {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
        {
	    strcat( title, "." );
	    SCdisplay_msg( title );

	    NFAput_string( &err_data.data[k], data.data[j+NFMitem_loc] );
	    NFAput_string( &err_data.data[k+1], data.data[j+NFMrev_loc] );

 	    status = NFMRcheckout_item( NFMcatalog, catalog_no, 
			 data.data[j+NFMitem_loc], data.data[j+NFMrev_loc], 
			 NFMworking, NFAwf_info, NFAoperation );

            _NFIdebug(( fname, "NFMRcheckout_item -> 0x%.8x\n",status));

 	    NFAset_message();
            NFAput_string( &err_data.data[k+2], msg );
            ERRget_number( &err_no, &subsystem );
            NFAalpha_set_to_state ( err_no, msg );
 	    k+=err_data.num_of_cols;
        }
    }

    /* process error form */
    SCdisplay_msg ("<PF1> or <PF3> to Cancel Form.");
    status = SCprocess_free_form (&err_data, NFMprint_file);
    SCclear_msg ();
    NFAfree_list (err_data.data, err_data.num_of_rows, err_data.num_of_cols);
    free (err_data.data);

    NFAfree_list_struct (&display_struct);
        
    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}

