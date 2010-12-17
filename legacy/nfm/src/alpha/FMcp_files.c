#include "machine.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "WFcommands.h"
#include "NFMRlist.h"
#include "NFMtitles.h"
#include "UMS.h"
#include "NFMdisplays.h"

extern   struct NFMwf_info   NFAwf_info;
extern   struct NFMoperation NFAoperation;

long copy_item_files ()

{
int    confirm;
long   status;
long   catalog_no = -1;

static char *fname = "NFAcopy_item_files";

    NFAconfirm( "copy the files for this item", &confirm );
    if( confirm == 0 )
        return( NFI_S_SUCCESS );

    NFAset_global_config_info( NFM_WORKFLOW, COPY_ITEM_FILES,
	   		       NFMworkflow, "", "NFM" );

    SCdisplay_msg( "Working .." );

    status = NFMRcopy_item_files( NFMcatalog, catalog_no, NFMitem,
		NFMrev, NFMworking, NFAwf_info, NFAoperation );

    _NFIdebug(( fname, "Return from NFMRcopy_item_files -> 0x%.8x\n", 
		    status));

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg ));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long copy_item_files_from_list ()

{
int    confirm;
int    i;
int    j;
int    k;
int    count;
int    subsystem;
long   err_no;
long   status;
long   catalog_no = -1;
char   title[80];
struct SCfree_data_st data;
struct SCfree_data_st err_data;
NFMlist display_struct;

static char *fname = "NFAcopy_item_files_from_list";

    NFAset_global_config_info( NFM_WORKFLOW, COPY_ITEM_FILES,
	   		       NFMworkflow, "", "NFM" );

    SCdisplay_msg( "Working .." );

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ITEMS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Items in Catalog <%s>", NFMcatalog );
      }

    NFAfill_list_struct (&display_struct, DSP_ITEMS, SELECT_SET_MULTI_ROW,
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

    NFAconfirm( "copy the files for these item(s)", &confirm );
    if( confirm == 0 )
    {
	NFAfree_list_struct( &display_struct );
        return( NFI_S_SUCCESS );
    }

    /* set up error form */
    NFAprepare_error_form ( data, &err_data, count, 
			    "Status of Copy Item(s) Files");

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

            status = NFMRcopy_item_files( NFMcatalog, catalog_no, 
			data.data[j+NFMitem_loc], data.data[j+NFMrev_loc], 
			NFMworking, NFAwf_info, NFAoperation );

            _NFIdebug(( fname, "Return from NFMRcopy_item_files -> 0x%.8x\n", 
				status ));
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

long delete_copied_files ()

{
int    i;
int    j;
long   status;
struct  SCfree_data_st data;
NFMlist display_struct;
char   search[500];
char   msg[100];
char   title[80];
char   owner[NFM_USERNAME+1];
MEMptr data_list = NULL;

static char *fname = "NFAdelete_copied_files";

/*  Get owner of this working area and compare to the current user.
 *  If the current user is not the owner he cannot delete file.
 *  However, , if the owner is 'PUBLIC' or the current user is nfmadmin
 *  the files can be deleted.
 */
    status = NFMRvalidate_working_area( NFMworking, owner );
    if( status != NFM_S_SUCCESS )
    {
	_NFIdebug(( fname, "NFMRvalidate_wa <0x%.8x>\n", status ));
	return( status );
    }
    if( (strcmp( owner, "PUBLIC" ) == 0 ) ||
	(strcmp( owner, NFMuser )  == 0 ) ||
	(strcmp( NFMuser, "nfmadmin" ) == 0 ) )
    {
	_NFIdebug(( fname, "OK to delete for owner <%s>", owner ));
    }
    else
    {
	ERRload_struct( NFM, NFM_E_INVALID_WORKING_AREA, "%s",NFMworking );
	return( NFM_E_INVALID_WORKING_AREA );
    }

/*  Use display local files to get a list of valid files to delete. */

    strcpy( search, " (nfmsafiles.n_copy = 'Y') AND (nfmsafiles.n_co = 'N') ");

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_LOCAL_FILES, "%s", NFMworking )) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Local Files in Working Area <%s>",
                        NFMworking );
      }

    NFAfill_list_struct (&display_struct, DSP_LOCAL_FILES,
 SELECT_SET_MULTI_ROW, NFM_FULL_DISPLAY, -1, search,"", "",
 "", "", "", "", title);

    status = NFAdisplay_elements (&data, display_struct);
    _NFIdebug(( fname, "NFAdisplay_elements <0x%.8x>\n", status ));
    NFAfree_list_struct( &display_struct );
    if (status == NFI_W_COMMAND_CANCELLED)
        {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        return( status );
        }

    if (status != NFI_S_SUCCESS)
        {

         ERRload_struct(NFM, NFM_E_MESSAGE,  "%s", 
             "No local files available for DELETE", NULL);
        ERRget_message(msg);
        SCdisplay_msg(msg);

        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        return (status);
        }

/*  Format return buffer */

    status = MEMopen( &data_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMopen" );
        _NFIdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        return( NFI_E_MEMORY );
    }
  
    sprintf( title, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( data_list, "n_catalogname", title );
    if( status != MEM_S_SUCCESS )
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	MEMclose( &data_list );
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite_format" );
        _NFIdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFI_E_MEMORY );
    }
  
    sprintf( title, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( data_list, "n_itemname", title );
    if( status != MEM_S_SUCCESS )
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	MEMclose( &data_list );
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite_format" );
        _NFIdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFI_E_MEMORY );
    }
  
    sprintf( title, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( data_list, "n_itemrev", title );
    if( status != MEM_S_SUCCESS )
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
    	MEMclose( &data_list );
        ERRload_struct( NFI, NFI_E_MEMORY, fname, "MEMwrite_format" );
        _NFIdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        return( NFI_E_MEMORY );
    }
  
    sprintf( title, "char(%d)", NFM_COFILENAME );
    status = MEMwrite_format( data_list, "n_filename", title );
    if( status != MEM_S_SUCCESS )
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	MEMclose( &data_list );
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",fname, "MEMwrite_format" );
        _NFIdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFI_E_MEMORY );
    }
  
    sprintf( title, "char(%d)", NFM_FILEVERSION );
    status = MEMwrite_format( data_list, "n_fileversion", title );
    if( status != MEM_S_SUCCESS )
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	MEMclose( &data_list );
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite_format" );
        _NFIdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFI_E_MEMORY );
    }

    for (i=0; i<data.num_of_rows; ++i)
    {
	j = i*data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
        {
	    sprintf( search, "%s\1%s\1%s\1%s\1%s\1", 
		     data.data[j+1], data.data[j+2], data.data[j+3],
		     data.data[j], data.data[j+4] );
	    _NFIdebug(( fname, "Write <%s>\n", search ));
	    status = MEMwrite( data_list, search );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &data_list );
	        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
	        free (data.data);
	        _NFIdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
	 	ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
		return( NFI_E_MEMORY );
	    }
        }
    }
    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    status = NFMRdelete_copied_files( NFMworking, data_list );
    MEMclose( &data_list );
    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg ));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


