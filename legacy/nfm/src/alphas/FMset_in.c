#include "machine.h"
#include "SCstruct.h"
#include "NFMRextern.h"
#include "WFcommands.h"
#include "NFMdisplays.h"
#include "NFMRlist.h"
#include "NFMtitles.h"
#include "UMS.h"

extern   struct NFMwf_info   NFAwf_info;

long check_set_in ()

{
long   status;
long   msg_status;
long   catalog_no = -1;
long   set_no = -1;
long   level  = 0;
int    confirm;
struct NFMoperation *operation;
MEMptr msg_list = NULL;
static char *fname = "NFAcheckin_set";

    SCdisplay_msg ("Working..");    

    NFAconfirm( "checkin this set", &confirm );
    if( confirm == 0 )
        return( NFI_S_SUCCESS );

    SCdisplay_msg ("Working..");

    operation = (struct NFMoperation *)calloc(2,(sizeof(struct NFMoperation)));

    operation->transfer = NFM_CONDITIONAL_TRANSFER;
    operation->delete   = NFM_CONDITIONAL_DELETE;
    operation->purge    = NFM_PURGE;
    strncpy( operation->catalog, NFMcatalog, NFM_CATALOGNAME );
    operation->catalog_no = -1;
    strncpy( operation->item_name, NFMset, NFM_ITEMNAME );
    strncpy( operation->item_rev, NFMset_rev, NFM_ITEMREV );

    NFAset_global_config_info( NFM_WORKFLOW, CHECKIN_SET,
                               NFMworkflow, "", "NFM" );

    status = NFMRcheckin_set( NFMcatalog, catalog_no, NFMset,
		NFMset_rev, set_no, NFMworking, NFAwf_info, 
		NFM_SAME_OPERATION, operation, level );
   
    _NFIdebug(( fname, "Return from NFMRcheckin_set -> 0x%.8x\n", 
		    status));
    if (status != NFM_S_SUCCESS);
     return(status);

    msg_status = NFMRget_set_messages( &msg_list );
    if( msg_status != NFM_S_SUCCESS )
    {
	_NFIdebug(( fname, "NFMRget_set_messages <0x%.8x>\n", msg_status ));
    }
    else
    {
	NFAdisplay_set_messages( "Set Checkin Messages", msg_list );
    }
    MEMclose( &msg_list );

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg ));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long check_set_in_from_list ()

{
long   status;
long   msg_status;
long   catalog_no = -1;
long   set_no = -1;
long   level  = 0;
int    i;
int    j;
int    k;
int    count;
int    confirm;
struct SCfree_data_st data;
struct SCfree_data_st err_data;
char   title[80];
NFMlist display_struct;
struct NFMoperation *operation;
MEMptr msg_list = NULL;
static char *fname = "NFAcheck_set_in_from_list";

    SCdisplay_msg ("Working..");    

    NFAset_global_config_info( NFM_WORKFLOW, CHECKIN_SET,
                               NFMworkflow, "", "NFM" );

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SETS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Sets in Catalog <%s>", NFMcatalog );
      }

    NFAfill_list_struct (&display_struct, DSP_SETS, SELECT_SET_MULTI_ROW,
 NFM_FULL_DISPLAY, -1, NFMsearch_name, NFMsort_name, NFMcatalog, "", "", 
"", "", title);

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

    NFAconfirm( "check in these set(s)", &confirm );
    if( confirm == 0 )
    {
	NFAfree_list_struct( &display_struct );
        return( NFI_S_SUCCESS );
    }

    operation = (struct NFMoperation *)calloc(2,(sizeof(struct NFMoperation)));

    /* set up error form */
    NFAprepare_error_form ( data, &err_data, count, 
			    "Status of Set(s) Checkin");

    strcpy( title, "Working" );

    for (i=0,k=0; i<data.num_of_rows; ++i)
    {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
        {
	    strcat( title, "." );
	    SCdisplay_msg( title );

            NFAput_string( &err_data.data[k], data.data[j] );
            NFAput_string( &err_data.data[k+1], data.data[j+1] );

	    operation->transfer = NFM_CONDITIONAL_TRANSFER;
	    operation->delete   = NFM_CONDITIONAL_DELETE;
	    operation->purge    = NFM_PURGE;
	    strncpy( operation->catalog, NFMcatalog, NFM_CATALOGNAME );
	    operation->catalog_no = -1;
	    strncpy( operation->item_name, data.data[j], NFM_ITEMNAME );
	    strncpy( operation->item_rev, data.data[j+1], NFM_ITEMREV );

	    status = NFMRcheckin_set( NFMcatalog, catalog_no, data.data[j], 
		data.data[j+1], set_no, NFMworking, NFAwf_info, 
		NFM_SAME_OPERATION, operation, level );
   
	    _NFIdebug(( fname, "Return from NFMRcheckin_set -> 0x%.8x\n", 
		    status));
	    NFAset_message();
	    NFAput_string( &err_data.data[k+2], msg );

	    msg_status = NFMRget_set_messages( &msg_list );
 	    if( msg_status != NFM_S_SUCCESS )
   	    {
		_NFIdebug(( fname, "NFMRget_set_messages <0x%.8x>\n", 
			msg_status ));
	    }
	    else
	    {
		NFAdisplay_set_messages( "Set Checkin Messages", msg_list );
	    }
	    MEMclose( &msg_list );
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


