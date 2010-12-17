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

long change_item_workflow()

{
int    i,j;
long   status;
long   NFAnew_display_simple_data();
char   wf_name[NFM_WORKFLOWNAME+1];
char   acl_name[NFM_ACLNAME+1];
char   acl_num[INTEGER+1];
char   state_name[NFM_STATENAME+1];
char   state_num[INTEGER+1];
struct SCfree_data_st data;
MEMptr syn_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFAchange_item_workflow";

    SCdisplay_msg ("Working..");    

    status = NFMRget_wf_and_completed_acl_list (&syn_list, &data_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&syn_list);
        MEMclose (&data_list);
	return (status);
        }

    strcpy( title, "Choose New Workflow for Item" ); 

    status = NFAnew_display_simple_data (&data, syn_list, data_list,
                   SELECT_SET_SINGLE_ROW, title );
    if( status != NFI_S_SUCCESS )
    {
        MEMclose( &syn_list );
        MEMclose( &data_list );
        return (status);
    }

    MEMclose( &syn_list );
    MEMclose( &data_list );

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (wf_name,  data.data[j]);
	    strcpy (acl_name, data.data[j+1] );
	    strcpy (acl_num,  data.data[j+2] );
            break;
            }
        }

    _NFIdebug(( fname, "Workflow <%s>\n", wf_name ));
    _NFIdebug(( fname, "ACL Name <%s>\n", acl_name ));
    _NFIdebug(( fname, "ACL No.  <%s>\n", acl_num ));
    
    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");    

    status = NFMRget_state_list_for_workflow (wf_name, &syn_list, &data_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&syn_list);
        MEMclose (&data_list);
	return (status);
        }

    sprintf( title, "Choose State from Workflow <%s>", wf_name ); 

    status = NFAnew_display_simple_data (&data, syn_list, data_list,
                   SELECT_SET_SINGLE_ROW, title );
    if( status != NFI_S_SUCCESS )
    {
        MEMclose( &syn_list );
        MEMclose( &data_list );
        return (status);
    }

    MEMclose( &syn_list );
    MEMclose( &data_list );

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (state_name, data.data[j]);
	    strcpy (state_num,  data.data[j+2] );
            break;
            }
        }

    _NFIdebug(( fname, "State Name <%s>\n", state_name ));
    _NFIdebug(( fname, "State No.  <%s>\n", state_num ));
    
    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);
   
    status =  NFMRchange_wf_item (NFMcatalog, NFMitem, NFMrev, wf_name,
                    acl_name, atol(acl_num), state_name, atol(state_num) );

    _NFIdebug(( fname, "Return from NFMRchange_wf_item -> 0x%.8x\n", 
		    status));
    
    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long change_item_workflow_from_list()

{
int    i,j,k;
int    confirm;
int    subsystem;
int    count;
long   err_no;
long   status;
long   NFAnew_display_simple_data();
char   wf_name[NFM_WORKFLOWNAME+1];
char   acl_name[NFM_ACLNAME+1];
char   acl_num[INTEGER+1];
char   state_name[NFM_STATENAME+1];
char   state_num[INTEGER+1];
struct SCfree_data_st data;
struct SCfree_data_st idata;
struct SCfree_data_st err_data;
NFMlist display_struct;
MEMptr syn_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFAchange_item_workflow_from_list";

    SCdisplay_msg ("Working..");    

    status = NFMRget_wf_and_completed_acl_list (&syn_list, &data_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&syn_list);
        MEMclose (&data_list);
	return (status);
        }

    strcpy( title, "Choose New Workflow for Item" ); 

    status = NFAnew_display_simple_data (&data, syn_list, data_list,
                   SELECT_SET_SINGLE_ROW, title );
    if( status != NFI_S_SUCCESS )
    {
        MEMclose( &syn_list );
        MEMclose( &data_list );
        return (status);
    }

    MEMclose( &syn_list );
    MEMclose( &data_list );

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (wf_name,  data.data[j]);
	    strcpy (acl_name, data.data[j+1] );
	    strcpy (acl_num,  data.data[j+2] );
            break;
            }
        }

    _NFIdebug(( fname, "Workflow <%s>\n", wf_name ));
    _NFIdebug(( fname, "ACL Name <%s>\n", acl_name ));
    _NFIdebug(( fname, "ACL No.  <%s>\n", acl_num ));
    
    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");    

    status = NFMRget_state_list_for_workflow (wf_name, &syn_list, &data_list);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&syn_list);
        MEMclose (&data_list);
	return (status);
        }

    sprintf( title, "Choose State from Workflow <%s>", wf_name ); 

    status = NFAnew_display_simple_data (&data, syn_list, data_list,
                   SELECT_SET_SINGLE_ROW, title );
    if( status != NFI_S_SUCCESS )
    {
        MEMclose( &syn_list );
        MEMclose( &data_list );
        return (status);
    }

    MEMclose( &syn_list );
    MEMclose( &data_list );

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (state_name, data.data[j]);
    	    strcpy (state_num,  data.data[j+2] );
            break;
            }
        }

    _NFIdebug(( fname, "State Name <%s>\n", state_name ));
    _NFIdebug(( fname, "State No.  <%s>\n", state_num ));
    
    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ITEMS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Items in Catalog <%s>", NFMcatalog );
      }

    NFAfill_list_struct (&display_struct, DSP_ITEMS, SELECT_SET_MULTI_ROW,
 NFM_FULL_DISPLAY, -1, NFMsearch_name, NFMsort_name, NFMcatalog, "", "", 
"", "",title);

    status = NFAdisplay_elements (&idata, display_struct);
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

    for( i=0,count=0; i<idata.num_of_rows; ++i )
        if(( idata.select_set[i] == 1 ) || ( idata.sts == FORM_SELECTED))
            ++count;

    if( count == 0 )
    {
        NFAfree_list_struct (&display_struct);
        return( NFI_S_SUCCESS );
    }

    NFAconfirm( "change the workflow for these item(s)", &confirm );
    if( confirm == 0 )
    {
	NFAfree_list_struct( &display_struct );
        return( NFI_S_SUCCESS );
    }

    /* set up error form */
    NFAprepare_error_form ( idata, &err_data, count, 
			    "Status of Change Item(s) Workflow");
			
    _NFIdebug ((fname,  " value OF data is %x\n", idata));
    strcpy( title, "Working" );

    for (i=0,k=0; i<idata.num_of_rows; ++i)
    {
        j = i * idata.num_of_cols;
        _NFIdebug((fname, "this is beging of for loop %d\n", i));
        if ((idata.select_set[i] == 1) || (idata.sts == FORM_SELECTED))
        {
	    strcat( title, "." );
	    SCdisplay_msg( title );

            _NFIdebug((fname, " inside if st %s , %s\n", 
         idata.data[j+NFMitem_loc],idata.data[j+NFMrev_loc]));

            NFAput_string( &err_data.data[k], idata.data[j+NFMitem_loc] );
            NFAput_string( &err_data.data[k+1], idata.data[j+NFMrev_loc] );


            _NFIdebug((fname, " inside if st 2 %s , %s\n", 
         idata.data[j+NFMitem_loc],idata.data[j+NFMrev_loc]));

            status = NFAalpha_validate_user_access (NFMuser_id, 
		CHANGE_WF_OF_ITEM, NFMworkflow, NFMproject, NFMcatalog, 
		idata.data[j+NFMitem_loc], idata.data[j+NFMrev_loc] );

            if (status != NFI_S_SUCCESS)
	    {
		NFAset_message();
		NFAput_string( &err_data.data[k+2], msg );
		break;
   	    }

	    status = NFMRchange_wf_item (NFMcatalog, idata.data[j+NFMitem_loc],
		idata.data[j+NFMrev_loc], wf_name, acl_name,
                atol(acl_num), state_name, atol(state_num) );

	    _NFIdebug(( fname, "Return from NFMRchange_wf_item -> 0x%.8x\n", 
		    status));
        
	    NFAset_message();
	    NFAput_string( &err_data.data[k+2], msg );
	    ERRget_number( &err_no, &subsystem );
	    NFAalpha_set_to_state ( err_no, msg );
  	    k+=err_data.num_of_cols;
        }
        _NFIdebug((fname, " Value of k is <%d>, i <%d>, j<%d>\n", k, i, j));
    }

    /* process error form */
    SCdisplay_msg ("<PF1> or <PF3> to Cancel Form.");
    status = SCprocess_free_form (&err_data, NFMprint_file);
    SCclear_msg ();
    NFAfree_list (err_data.data, err_data.num_of_rows, err_data.num_of_cols);
    free (err_data.data);

    NFAfree_list_struct (&display_struct);
        
    NFAfree_list (idata.data, idata.num_of_rows, idata.num_of_cols);
    free (idata.data);
    
    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



