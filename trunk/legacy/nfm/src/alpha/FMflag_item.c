#include "machine.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "WFcommands.h"
#include "NFMdisplays.h"
#include "NFMRlist.h"
#include "NFMtitles.h"
#include "UMS.h"

char	 title[80];

long flag_item_archive ()

{
long   status;
static char *fname = "NFAflag_item_archive";
   
    _NFIdebug(( fname, "%s\n", "Entering ..."));

    status = NFMRflag_item_archive (NFMuser_id, NFMcatalog, 
				   NFMitem, NFMrev);

    _NFIdebug(( fname, "Return from NFMRflag_item_archive -> <0x%.8x>\n", 
		status));

    if (status != NFM_S_SUCCESS)
        return (status);
        
    return (NFI_S_SUCCESS);
}

long flag_item_archive_from_list ()

{
int    i;
int    j;
int    k;
int    subsystem;
int    confirm;
int    count;
long   err_no;
long   status;
long   NFAprepare_error_form();
static char *fname = "NFAflag_item_archive_from_list";
struct SCfree_data_st data;
struct SCfree_data_st err_data;
NFMlist display_struct;

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
        if(( data.select_set[i] == 1 ) || ( data.sts == FORM_SELECTED))
            ++count;

    if( count == 0 )
    {
        NFAfree_list_struct (&display_struct);
        return( NFI_S_SUCCESS );
    }

    NFAconfirm( "flag these item(s) for archive", &confirm );
    if( confirm == 0 )
    {
	NFAfree_list_struct( &display_struct );
        return( NFI_S_SUCCESS );
    }

    /* set up error form */
    NFAprepare_error_form ( data, &err_data, count,
			    "Status of Archive Flagging");

    strcpy( title, "Working" );

    for (i=0,k=0; i<data.num_of_rows; ++i)
    {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
        {
	    strcat( title, "." );
	    SCdisplay_msg( title );

            NFAput_string (&err_data.data[k],   data.data[j+NFMitem_loc]);
            NFAput_string (&err_data.data[k+1], data.data[j+NFMrev_loc]);
            
            status = NFAalpha_validate_user_access (NFMuser_id, 
		 FLAG_ITEM_ARCHIVE, NFMworkflow, NFMproject, NFMcatalog, 
		 data.data[j+NFMitem_loc], data.data[j+NFMrev_loc] );
            if (status != NFI_S_SUCCESS)
	    {
		NFAset_message();
		NFAput_string( &err_data.data[k+2], msg );
		break;
	    }
	    status = NFMRflag_item_archive (NFMuser_id, NFMcatalog, 
		   data.data[j+NFMitem_loc], data.data[j+NFMrev_loc]);

            _NFIdebug(( fname, "NFMRflag_item_archive -> 0x%.8x\n",status));

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

    if (status != NFM_S_SUCCESS)
        return (status);
        
    return (NFI_S_SUCCESS);
}

long flag_item_backup ()

{
long   status;
static char *fname = "NFAflag_item_backup";

    _NFIdebug(( fname, "%s\n", "Entering ..." ));

    status = NFMRflag_item_backup (NFMuser_id, NFMcatalog,  NFMitem, NFMrev);

    _NFIdebug(( fname, "Return from NFMRflag_item_backup -> <0x%.8x>\n", 
		status));

    if (status != NFM_S_SUCCESS)
        return (status);
        
    return (NFI_S_SUCCESS);
}


long flag_item_backup_from_list ()

{
int    i;
int    j;
int    k;
int    subsystem;
int    confirm;
int    count;
long   err_no;
long   status;
long   NFAprepare_error_form();
static char *fname = "NFAflag_item_backup_from_list";
struct SCfree_data_st data;
struct SCfree_data_st err_data;
NFMlist display_struct;

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

    NFAconfirm( "flag these item(s) for backup", &confirm );
    if( confirm == 0 )
    {
	NFAfree_list_struct( &display_struct );
        return( NFI_S_SUCCESS );
    }

    /* set up error form */
    NFAprepare_error_form ( data, &err_data, count,
			    "Status of Backup Flagging");

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

	    status = NFAalpha_validate_user_access (NFMuser_id, 
		FLAG_ITEM_BACKUP, NFMworkflow, NFMproject, NFMcatalog, 
		data.data[j+NFMitem_loc], data.data[j+NFMrev_loc] );
            if (status != NFI_S_SUCCESS)
	    {
                NFAset_message();
                NFAput_string( &err_data.data[k+2], msg );
                break;
	    }
	    status = NFMRflag_item_backup (NFMuser_id, NFMcatalog, 
		  data.data[j+NFMitem_loc], data.data[j+NFMrev_loc]);

	    _NFIdebug((fname,"Return from NFMRflag_item_backup -> <0x%.8x>\n", 
		status));

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

    if (status != NFM_S_SUCCESS)
        return (status);
        
    return (NFI_S_SUCCESS);
}

long flag_item_restore ()

{
    long   status;
    long   err_no;
    int    subsystem;
    int    i;
    int    j;
    int    k;
    int    count = 0;
    int    tot_data;
  
    char   **files_col_ptr;
    char   **files_data_ptr;

    MEMptr files = NULL;

    struct SCfree_data_st data;

    static char *fname = "NFAflag_item_restore";

    _NFIdebug(( fname, "%s\n", "Entering ..." ));

    SCdisplay_msg ("Working..");    
    status = NFMRnew_query_flag_restore( NFMcatalog, NFMitem, NFMrev, &files );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &files );
	return( status );
    }

    status = MEMbuild_array( files );
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFI, NFI_E_MEM, "%s%s","NFMflag_item_restore",
			"MEMbuild_array" );
        MEMclose( &files );
        return(NFI_E_MEM);
    }

    files_col_ptr  = (char**) files->column_ptr;
    files_data_ptr = (char**) files->data_ptr;

    if( files->rows == 0 )
    {
	ERRload_struct( NFI, NFI_E_NO_FILES_CAN_BE_FLAGGED, NULL, NULL );
	return( NFI_S_SUCCESS );	
    }

    data.num_of_rows = files->rows;
    data.num_of_cols = files->columns;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 1;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.col_size = (int*)malloc( data.num_of_cols * sizeof(int) );
    memset( data.col_size, 0, (data.num_of_cols * sizeof(int) ) );

    for( i=0; i<data.num_of_cols; ++i )
        NFAfind_max_data_len( files_col_ptr, files_data_ptr, i,
           files->columns, files->rows, &data.col_size[i]);
    
    data.col_pos = (int*) malloc( data.num_of_cols * sizeof(int) );
    memset( data.col_pos, 0, ( data.num_of_cols * sizeof(int) ) );

    count = 0;
    for( i=0; i<data.num_of_cols; ++i )
    {
 	data.col_pos[i] = count;
	count += data.col_size[i] + 2;
    }

    data.col_just = (int*)malloc(data.num_of_cols*sizeof(int));
    memset( data.col_just, LEFT_JUSTIFIED, (data.num_of_cols*sizeof(int)));

    data.h1_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h1_pos, 0, sizeof(int) + 1 );
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int*)malloc((data.num_of_cols * sizeof( int) ) + 1 );
    memset( data.h2_pos, 0, (data.num_of_cols*sizeof(int)) + 1 );
    count = 0;
    for( i=0; i<data.num_of_cols; ++i )
    {
	data.h2_pos[i] = count;
	count += data.col_size[i] + 2;
    }
    data.h2_pos[i] = -1;

    data.h3_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h3_pos, 0, sizeof( int ) + 1 );
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;

    data.h1_data = (char**) malloc( sizeof(char*) );
    memset( data.h1_data, NULL, (sizeof(char*)));
    NFAput_string( &data.h1_data[0], "" );

    data.h2_data = (char**) malloc(data.num_of_cols*sizeof(char*)+1 );
    memset( data.h2_data, NULL, (data.num_of_cols*sizeof(char*))+1);

    NFAput_string( &data.h2_data[0], files_col_ptr[0] );
    NFAput_string( &data.h2_data[1], files_col_ptr[1] );
    NFAput_string( &data.h2_data[2], files_col_ptr[2] );

    data.h3_data = (char**) malloc( sizeof(char*) );
    memset( data.h3_data, NULL, (sizeof(char*)));
    NFAput_string( &data.h3_data[0], "" );

    strcpy( data.title, "Files Available for Restore Flagging" );

    data.select_set = (int*) malloc( tot_data * sizeof(int) );
    memset( data.select_set, 0, ( tot_data * sizeof(int) ) );

    data.data = (char**) malloc ( tot_data * sizeof(char*) );
    memset( data.data, NULL, ( tot_data * sizeof(char*) ) );

/*  Now use data buffer
 */
    for( i=0; i<tot_data; i+=data.num_of_cols )
    {
        NFAput_string( &data.data[i],   files_data_ptr[i] );
        NFAput_string( &data.data[i+1], files_data_ptr[i+1] );
        NFAput_string( &data.data[i+2], files_data_ptr[i+2] );
    }

    status = SCprocess_free_form( &data, NFMprint_file );
    if( data.sts == FORM_CANCELED )
    {
	MEMclose( &files );
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
	free( data.data );
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
	return( NFI_W_COMMAND_CANCELLED);
    }

    SCclear_msg ();

    for (i=0; i<data.num_of_rows; ++i)
        {
	j = i* data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            SCdisplay_msg ("Working..");    

            status = NFMRvalidate_user_access (NFMuser_id, 
                                               FLAG_ITEM_RESTORE, "", "", 
                                               NFMcatalog, data.data[j],
                                               data.data[j+1]);
            _NFIdebug(( fname, "VALIDATE USER -> <0x%.8x>\n",status));

            if (status != NFM_S_SUCCESS)
                {
		NFAset_message();
                SCdisplay_msg (msg);
                }
            else
                {
                status = NFMRalpha_flag_item_restore (NFMuser_id, NFMcatalog, 
                             data.data[j], data.data[j+1], data.data[j+2]);

                _NFIdebug(( fname, "NFMRflag_item_restore -> <0x%.8x>\n",
			    status));

                if (status != NFM_S_SUCCESS)
		    {
		    NFAset_message();
                    SCdisplay_msg (msg);
                    }

	        NFAset_message();
	        ERRget_number( &err_no, &subsystem );

	        NFAalpha_set_to_state ( err_no, msg );
		break;
                }
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long flag_item_delete ()

{
long   status;
static char *fname = "NFAflag_item_delete";
   
    _NFIdebug(( fname, "%s\n", "Entering ..."));

    status = NFMRflag_item_delete (NFMuser_id, NFMcatalog, NFMitem, NFMrev);

    _NFIdebug(( fname, "Return from NFMRflag_item_delete -> <0x%.8x>\n", 
		status));

    if (status != NFM_S_SUCCESS)
        return (status);
        
    return (NFI_S_SUCCESS);
}

long flag_item_delete_from_list ()

{
int    i;
int    j;
int    k;
int    confirm;
int    subsystem;
int    count;
long   err_no;
long   status;
long   NFAprepare_error_form();
struct SCfree_data_st err_data;
struct SCfree_data_st data;
NFMlist display_struct;
static char *fname = "NFAflag_item_delete";

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

    NFAconfirm( "flag these item(s) for delete", &confirm );
    if( confirm == 0 )
    {
	NFAfree_list_struct( &display_struct );
        return( NFI_S_SUCCESS );
    }

    /* set up error form */
    NFAprepare_error_form ( data, &err_data, count, 
			    "Status of Delete Flagging");

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

            status = NFAalpha_validate_user_access (NFMuser_id, 
			FLAG_ITEM_DELETE, NFMworkflow, NFMproject, NFMcatalog,
			data.data[j+NFMitem_loc], data.data[j+NFMrev_loc] );
            if (status != NFI_S_SUCCESS)
	    {
                NFAset_message();
                NFAput_string( &err_data.data[k+2], msg );
                break;
	    }

	    status = NFMRflag_item_delete (NFMuser_id, NFMcatalog, 
		   data.data[j+NFMitem_loc], data.data[j+NFMrev_loc]);

	    _NFIdebug((fname,"Return from NFMRflag_item_delete -> <0x%.8x>\n", 
			status));

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

    if (status != NFM_S_SUCCESS)
        return (status);
        
    return (NFI_S_SUCCESS);
}


long flag_item_restore_from_list ()

{
int    i;
int    j;
int    k;
int    subsystem;
int    confirm;
int    count;
long   err_no;
long   status;
long   NFAprepare_error_form();
static char *fname = "NFAflag_item_restore_from_list";
struct SCfree_data_st data;
struct SCfree_data_st err_data;
NFMlist display_struct;

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
        if(( data.select_set[i] == 1 ) || ( data.sts == FORM_SELECTED))
            ++count;

    if( count == 0 )
    {
        NFAfree_list_struct (&display_struct);
        return( NFI_S_SUCCESS );
    }

    NFAconfirm( "flag these item(s) for restore", &confirm );
    if( confirm == 0 )
    {
    NFAfree_list_struct( &display_struct );
        return( NFI_S_SUCCESS );
    }

    /* set up error form */
    NFAprepare_error_form ( data, &err_data, count,
                "Status of Restore Flagging");

    strcpy( title, "Working" );

    for (i=0,k=0; i<data.num_of_rows; ++i)
    {
 j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
        {
        strcat( title, "." );
        SCdisplay_msg( title );

            NFAput_string (&err_data.data[k],   data.data[j+NFMitem_loc]);
            NFAput_string (&err_data.data[k+1], data.data[j+NFMrev_loc]);

            status = NFAalpha_validate_user_access (NFMuser_id,
         FLAG_ITEM_RESTORE, NFMworkflow, NFMproject, NFMcatalog,
         data.data[j+NFMitem_loc], data.data[j+NFMrev_loc] );
         if (status != NFI_S_SUCCESS)
          {
           NFAset_message();
           NFAput_string( &err_data.data[k+2], msg );
           break;
          }
        status = NFMRflag_item_restore (NFMuser_id, NFMcatalog,
           data.data[j+NFMitem_loc], data.data[j+NFMrev_loc]);
     _NFIdebug(( fname, "NFMRflag_item_archive -> 0x%.8x\n",status));

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

    if (status != NFM_S_SUCCESS)
        return (status);

    return (NFI_S_SUCCESS);
}
