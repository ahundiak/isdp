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

long flag_set_archive ()
{
long   status;
int    level;
static char *fname = "NFAflag_set_archive";
   
    _NFIdebug(( fname, "%s\n", "Entering ..."));

    NFAchoose_set_flagging_level( &level );

    _NFIdebug(( fname, "Level <%d>\n", level ));

    status = NFMRflag_set_archive (NFMuser_id, NFMcatalog, 
				   NFMset, NFMset_rev);

    _NFIdebug(( fname, "Return from NFMRflag_set_archive -> <0x%.8x>\n", 
		status));

    if (status != NFM_S_SUCCESS)
        return (status);
        
    return (NFI_S_SUCCESS);
}

long flag_set_archive_from_list ()
{
int    i;
int    j;
int    k;
int    count;
int    confirm;
int    subsystem;
int    level;
long   err_no;
long   status;
struct SCfree_data_st data;
struct SCfree_data_st err_data;
NFMlist display_struct;

static char *fname = "NFAflag_set_archive_from_list";
   
    _NFIdebug(( fname, "%s\n", "Entering ..."));

    NFAchoose_set_flagging_level( &level );

    _NFIdebug(( fname, "Level <%d>\n", level ));

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SETS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Sets in Catalog <%s>", NFMcatalog );
      }

    NFAfill_list_struct (&display_struct, DSP_SETS, SELECT_SET_MULTI_ROW,
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
        if(( data.select_set[i] == 1 ) || ( data.sts == FORM_SELECTED))
            ++count;

    if( count == 0 )
    {
        NFAfree_list_struct (&display_struct);
        return( NFI_S_SUCCESS );
    }

    NFAconfirm( "flag these set(s) for archive", &confirm );
    if( confirm == 0 )
    {
	NFAfree_list_struct( &display_struct );
        return( NFI_S_SUCCESS );
    }

    /* set up error form */

    NFAprepare_error_form ( data, &err_data, count, 
			    "Status of Flag Set(s) for Archive");

    strcpy( title, "Working" );

    for (i=0, k=0; i<data.num_of_rows; ++i)
    {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
        {
	    strcat( title, "." );
	    SCdisplay_msg( title );

            NFAput_string( &err_data.data[k], data.data[j] );
            NFAput_string( &err_data.data[k+1], data.data[j+1] );

	    status = NFAalpha_validate_user_access (NFMuser_id, 
		FLAG_SET_ARCHIVE, NFMworkflow, NFMproject, NFMcatalog, 
		data.data[j], data.data[j+1] );
	    if (status != NFI_S_SUCCESS)
	    {
		NFAset_message();
		NFAput_string( &err_data.data[k+2], msg );
		break;
	    }
	    status = NFMRflag_set_archive (NFMuser_id, NFMcatalog, 
			data.data[j], data.data[j+1] );

	    _NFIdebug((fname,"Return from NFMRflag_set_archive -> <0x%.8x>\n", 
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

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}

long flag_set_backup ()

{
int    level;
long   status;
static char *fname = "NFAflag_set_backup";

    _NFIdebug(( fname, "%s\n", "Entering ..." ));

    NFAchoose_set_flagging_level( &level );

    _NFIdebug(( fname, "Level <%d>\n", level ));

    status = NFMRflag_set_backup (NFMuser_id, NFMcatalog, 
				  NFMset, NFMset_rev);

    _NFIdebug(( fname, "Return from NFMRflag_set_backup -> <0x%.8x>\n", 
		status));

    if (status != NFM_S_SUCCESS)
        return (status);
        
    return (NFI_S_SUCCESS);
}


long flag_set_backup_from_list ()
{
int    i;
int    j;
int    k;
int    count;
int    confirm;
int    subsystem;
int    level;
long   err_no;
long   status;
struct SCfree_data_st data;
struct SCfree_data_st err_data;
NFMlist display_struct;

static char *fname = "NFAflag_set_backup_from_list";
   
    _NFIdebug(( fname, "%s\n", "Entering ..."));

    NFAchoose_set_flagging_level( &level );

    _NFIdebug(( fname, "Level <%d>\n", level ));

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

    NFAconfirm( "flag these set(s) for backup", &confirm );
    if( confirm == 0 )
    {
	NFAfree_list_struct( &display_struct );
        return( NFI_S_SUCCESS );
    }

    /* set up error form */
    NFAprepare_error_form ( data, &err_data, count, 
			    "Status of Flag Set(s) for Backup");

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

	    status = NFAalpha_validate_user_access (NFMuser_id, 
		FLAG_SET_BACKUP, NFMworkflow, NFMproject, NFMcatalog, 
		data.data[j], data.data[j+1] );
	    if (status != NFI_S_SUCCESS)
	    {
		NFAset_message();
	  	NFAput_string( &err_data.data[k+2], msg );
		break;
	    }
	    status = NFMRflag_set_backup (NFMuser_id, NFMcatalog, 
			data.data[j], data.data[j+1] );

	    _NFIdebug((fname,"Return from NFMRflag_set_backup -> <0x%.8x>\n", 
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

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}

long flag_set_restore ()

{
int    level;
long   status;
static char *fname = "NFAflag_set_restore";

    _NFIdebug(( fname, "%s\n", "Entering ..." ));

    NFAchoose_set_flagging_level( &level );

    _NFIdebug(( fname, "Level <%d>\n", level ));

    status = NFMRflag_set_restore (NFMuser_id, NFMcatalog, 
				   NFMset, NFMset_rev);

    _NFIdebug(( fname, "Return from NFMRflag_set_restore -> <0x%.8x>\n", 
		status));

    if (status != NFM_S_SUCCESS)
        return (status);
        
    return (NFI_S_SUCCESS);
}

long flag_set_restore_from_list ()
{
int    i;
int    j;
int    k;
int    count;
int    confirm;
int    subsystem;
int    level;
long   err_no;
long   status;
struct SCfree_data_st data;
struct SCfree_data_st err_data;
NFMlist display_struct;

static char *fname = "NFAflag_set_restore_from_list";
   
    _NFIdebug(( fname, "%s\n", "Entering ..."));

    NFAchoose_set_flagging_level( &level );

    _NFIdebug(( fname, "Level <%d>\n", level ));

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SETS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Sets in Catalog <%s>", NFMcatalog );
      }

    NFAfill_list_struct (&display_struct, DSP_SETS, SELECT_SET_MULTI_ROW,
 NFM_FULL_DISPLAY, -1, NFMsearch_name, NFMsort_name, NFMcatalog, "", "", 
"", "",title);

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

    NFAconfirm( "flag these set(s) for restore", &confirm );
    if( confirm == 0 )
    {
	NFAfree_list_struct( &display_struct );
        return( NFI_S_SUCCESS );
    }

    /* set up error form */
    NFAprepare_error_form ( data, &err_data, count, 
			    "Status of Flag Set(s) for Restore");

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

	    status = NFAalpha_validate_user_access (NFMuser_id, 
		FLAG_SET_RESTORE, NFMworkflow, NFMproject, NFMcatalog, 
		data.data[j], data.data[j+1] );
	    if (status != NFI_S_SUCCESS)
	    {
		NFAset_message();
		NFAput_string( &err_data.data[k+2], msg );
		break;
	    }
	    status = NFMRflag_set_restore (NFMuser_id, NFMcatalog, 
			data.data[j], data.data[j+1] );

	    _NFIdebug((fname,"Return from NFMRflag_set_restore -> <0x%.8x>\n", 
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

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}
