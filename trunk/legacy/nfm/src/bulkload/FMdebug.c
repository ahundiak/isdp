#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "DEBUG.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "ERR.h"
#include "NDXstruct.h"

#define  NFM_DEBUG_SUBSYSTEMS 15

extern struct _ERRstruct _ERRstruct;

extern long sqlstatus;

long debug_on ()

{
long   status;
int    i;
int    j;
int    count;
int    tot_data;
int    pos;
int    go_to_server = 0;
int    nfm_on = 0;
int    net_on = 0;
int    sql_on = 0;
int    mem_on = 0;
char   req_file[40];
char   nfm_file[40];
char   net_file[40];
char   sql_file[40];
char   mem_file[40];
struct SCcolumn_data_st data;
struct SCfree_data_st fdata;
int    FORM_FILLED;
static char *fname = "nfm_debug_on";

    _NFIdebug ((fname, "Enter.\n"));

    fdata.num_of_rows = 6;
    fdata.num_of_cols = 1;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_MULTI_ROW;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_size[0] = 9;

    fdata.col_pos = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_pos, 0 , (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_pos[0] = 0;

    fdata.col_just = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols * sizeof (int)));
    
    fdata.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h1_pos, 0, sizeof (int) + 1);
    fdata.h1_pos[0] = 0;
    fdata.h1_pos[1] = -1;

    fdata.h2_pos = (int *) malloc ((fdata.num_of_cols * sizeof (int)) + 1);
    memset (fdata.h2_pos, 0, (fdata.num_of_cols * sizeof (int)) + 1);
    fdata.h2_pos[0] = 0;
    fdata.h2_pos[1] = -1;
    
    fdata.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h3_pos, 0, sizeof (int) + 1);
    fdata.h3_pos[0] = 0;
    fdata.h3_pos[1] = -1;
    
    fdata.h1_data = (char **) malloc (sizeof (char *));
    memset (fdata.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&fdata.h1_data[0], "");
    
    fdata.h2_data = (char **) malloc (tot_data * (sizeof (char *)));
    memset (fdata.h2_data, NULL, tot_data * (sizeof (char *)));
    NFAput_string (&fdata.h2_data[0], "");
    
    fdata.h3_data = (char **) malloc (sizeof (char *));
    memset (fdata.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&fdata.h3_data[0], "");
    
    strcpy (fdata.title, "Choose Subsystem(s) For Server Debug");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&fdata.data[0], "REQ Debug");
    NFAput_string (&fdata.data[1], "NFM Debug");
    NFAput_string (&fdata.data[2], "SQL Debug");
    NFAput_string (&fdata.data[3], "MEM Debug");
    NFAput_string (&fdata.data[4], "NET Debug");
    NFAput_string (&fdata.data[5], "ERR Debug");
    /* process free form */
    status = SCprocess_free_form (&fdata, NFMprint_file);

    if (fdata.sts == FORM_CANCELED)
        {
        _NFIdebug ((fname, "Cancel from form. Return.\n"));
        NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        free (fdata.data);
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
        }

    count = 0;
    for (i=0; i<fdata.num_of_rows; ++i)
        {
        if ((fdata.select_set[i] == 1) || (fdata.sts == FORM_SELECTED))
            {
            ++count;
            }
        }

/***********************************************************************
    Get Debug output file information
***********************************************************************/

    pos = 0;
    data.num_of_rows = count;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 10;
    data.col_width[1] = 40;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Debug File Names");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0, j=0; i<fdata.num_of_rows; ++i)
        {
        if ((fdata.select_set[i] == 1) || (fdata.sts == FORM_SELECTED))
            {
            NFAput_string (&data.data[j], fdata.data[i*fdata.num_of_cols]);
            NFAput_string (&data.data[j+1], "/dev/console");
            j+=data.num_of_cols;
            }
        }

    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            /* 48 character file limit because of MSGstruct.h */
            for (i=pos; i<tot_data; i+=data.num_of_cols)
                status = NFAvalidate_string ("char(48)", data.data[i+1]);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFIdebug ((fname, "Cancel from form. Return.\n"));
        NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        free (fdata.data);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
        }

    SCdisplay_msg ("Working..");

    strcpy (nfm_file, "/dev/console");
    strcpy (net_file, "/dev/console");
    strcpy (sql_file, "/dev/console");
    strcpy (mem_file, "/dev/console");
    strcpy (req_file, "/dev/console");

    for (i=0; i<tot_data; i+=data.num_of_cols)
        {
             if (strncmp (data.data[i], "NFM", 3) == 0)
                 {
                 nfm_on = 1;
                 strcpy (nfm_file, data.data[i+1]);
		 go_to_server = 1;
                 }

        else if (strncmp (data.data[i], "NET", 3) == 0)
                {
                net_on = 1;
                strcpy (net_file, data.data[i+1]);
		go_to_server = 1;
                }

        else if (strncmp (data.data[i], "SQL", 3) == 0)
                {
                sql_on = 1;
                strcpy (sql_file, data.data[i+1]);
		go_to_server = 1;
                }

        else if (strncmp (data.data[i], "MEM", 3) == 0)
                {
                mem_on = 1;
                strcpy (mem_file, data.data[i+1]);
            MEMmsg_ptr.debug_on = mem_on;
            strcpy (MEMmsg_ptr.debug_file, mem_file);
		go_to_server = 1;
                }

        else if (strncmp (data.data[i], "REQ", 3) == 0)
                {
                NFMRmsg_ptr.debug_on = 1;
                strcpy (NFMRmsg_ptr.debug_file, data.data[i+1]);
                }

        else if (strncmp (data.data[i], "ERR", 3) == 0)
                {
		nfm_on = 3;
                _ERRstruct.debug_on = 1;
                strcpy (_ERRstruct.debug_file, data.data[i+1]);
                }
        }

    status = NFM_S_SUCCESS;
    if( go_to_server )
    {
        status = NFMRdebug (nfm_on, nfm_file, net_on, net_file, sql_on,
			    sql_file, mem_on, mem_file);
        _NFIdebug ((fname, "NFMdebug -> <0x%.8x>\n", status));
    }

    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);
    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    switch (status)
        {
        case NFM_S_SUCCESS :
            {
            NFMmsg_ptr.debug_on = nfm_on;
            strcpy (NFMmsg_ptr.debug_file, nfm_file);
            break;
            }
        default :    
            break;
        }

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if( status != NFM_S_SUCCESS )
	return( status );

    return (NFI_S_SUCCESS);
}


long debug_off ()

{
long   status;
static char *fname = "nfm_debug_off";

    _NFIdebug ((fname, "Enter.\n"));

    NFMRmsg_ptr.debug_on = 0;

    status = NFMRdebug (0, "", 0, "", 0, "", 0, "");

    _NFIdebug ((fname, "NFIdebug -> <0x%.8x>\n", status));

    switch (status)
        {
        case NFM_S_SUCCESS :
            {
	    NFMRmsg_ptr.debug_on = 0;
	    strcpy( NFMRmsg_ptr.debug_file, "" );
            NFMmsg_ptr.debug_on = 0;
            strcpy (NFMmsg_ptr.debug_file, "");
	    _ERRstruct.debug_on = 0;
	    strcpy( _ERRstruct.debug_file, "" );
            break;
            }
        default :    
            {
            break;
            }
        }

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);

    if( status != NFM_S_SUCCESS )
	return( status );       
 
    return (NFI_S_SUCCESS);
}

long server_debug_on ()

{
long   status;
int    i;
int    j;
int    tot_data;
int    pos;
int    toggles[NFM_DEBUG_SUBSYSTEMS];
int    FORM_FILLED;
int    count;

char   files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];

struct SCcolumn_data_st data;
struct SCfree_data_st fdata;
static char *fname = "nfm_all_debug_on";

    _NFIdebug ((fname, "Enter.\n"));

    fdata.num_of_rows = 7;
    fdata.num_of_cols = 1;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_MULTI_ROW;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_size[0] = 12;

    fdata.col_pos = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_pos, 0 , (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_pos[0] = 0;

    fdata.col_just = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols * sizeof (int)));
    
    fdata.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h1_pos, 0, sizeof (int) + 1);
    fdata.h1_pos[0] = 0;
    fdata.h1_pos[1] = -1;

    fdata.h2_pos = (int *) malloc ((fdata.num_of_cols * sizeof (int)) + 1);
    memset (fdata.h2_pos, 0, (fdata.num_of_cols * sizeof (int)) + 1);
    fdata.h2_pos[0] = 0;
    fdata.h2_pos[1] = -1;
    
    fdata.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h3_pos, 0, sizeof (int) + 1);
    fdata.h3_pos[0] = 0;
    fdata.h3_pos[1] = -1;
    
    fdata.h1_data = (char **) malloc (sizeof (char *));
    memset (fdata.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&fdata.h1_data[0], "");
    
    fdata.h2_data = (char **) malloc (tot_data * (sizeof (char *)));
    memset (fdata.h2_data, NULL, tot_data * (sizeof (char *)));
    NFAput_string (&fdata.h2_data[0], "");
    
    fdata.h3_data = (char **) malloc (sizeof (char *));
    memset (fdata.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&fdata.h3_data[0], "");
    
    strcpy (fdata.title, "Choose Subsystem(s) For Debug");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&fdata.data[0], "NETS Debug");
    NFAput_string (&fdata.data[1], "NFMS Debug");
    NFAput_string (&fdata.data[2], "NFM  Debug");
    NFAput_string (&fdata.data[3], "SQL  Debug");
    NFAput_string (&fdata.data[4], "MEMS Debug");
    NFAput_string (&fdata.data[5], "UTI  Debug");
    NFAput_string (&fdata.data[6], "ERRS Debug");

    /* process free form */
    status = SCprocess_free_form (&fdata, NFMprint_file);

    if (fdata.sts == FORM_CANCELED)
        {
        _NFIdebug ((fname, "Cancel from form. Return.\n"));
        NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        free (fdata.data);
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
        }

    count = 0;
    for (i=0; i<fdata.num_of_rows; ++i)
        {
        if ((fdata.select_set[i] == 1) || (fdata.sts == FORM_SELECTED))
            {
            ++count;
            }
        }

/***********************************************************************
    Get Debug output file information
***********************************************************************/

    pos = 0;
    data.num_of_rows = count;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 12;
    data.col_width[1] = 50;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Debug File Names");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0, j=0; i<fdata.num_of_rows; ++i)
        {
        if ((fdata.select_set[i] == 1) || (fdata.sts == FORM_SELECTED))
            {
            NFAput_string (&data.data[j], fdata.data[i*fdata.num_of_cols]);
            NFAput_string (&data.data[j+1], "/dev/console");
            j+=data.num_of_cols;
            }
        }

    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            /* 48 character file limit because of MSGstruct.h */
            for (i=pos; i<tot_data; i+=data.num_of_cols)
                status = NFAvalidate_string ("char(50)", data.data[i+1]);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFIdebug ((fname, "Cancel from form. Return.\n"));
        NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        free (fdata.data);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
        }

    SCdisplay_msg ("Working..");

    for( i=0; i<NFM_DEBUG_SUBSYSTEMS; ++i )
    {
	toggles[i] = 0;
	strcpy( files[i], "/dev/console" );
    }

    for (i=0; i<tot_data; i+=data.num_of_cols)
        {
        if (strncmp (data.data[i], "NETS", 4) == 0)
                {
                toggles[6] = 1;
                strcpy (files[6], data.data[i+1]);
                }

        else if (strncmp (data.data[i], "NFMS", 4) == 0)
                {
                toggles[7] = 1;
                strcpy (files[7], data.data[i+1]);
                }

        else if (strncmp (data.data[i], "NFM", 3) == 0)
                {
                toggles[8] = 1;
                strcpy (files[8], data.data[i+1]);
                }

        else if (strncmp (data.data[i], "SQL", 3) == 0)
                {
                toggles[9] = 1;
                strcpy (files[9], data.data[i+1]);
                }

        else if (strncmp (data.data[i], "MEMS", 4) == 0)
                {
                toggles[11] = 1;
                strcpy (files[11], data.data[i+1]);
                }

        else if (strncmp (data.data[i], "UTI", 3) == 0)
		{
		toggles[12] = 1;
                strcpy (files[12], data.data[i+1]);
                }

        else if (strncmp (data.data[i], "ERRS", 4) == 0)
                {
		toggles[14] = 1;
		strcpy (files[14], data.data[i+1]);
                }
        }
  
    status = NFMRall_debug ( toggles, files );

    _NFIdebug ((fname, "NFMRall_debug -> <0x%.8x>\n", status));

    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);
    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if( status != NFM_S_SUCCESS )
	return( status );

    return (NFI_S_SUCCESS);
}

long client_debug_on ()

{
long   status;
int    i;
int    j;
int    tot_data;
int    pos;
int    toggles[NFM_DEBUG_SUBSYSTEMS];
int    FORM_FILLED;
int    count;

char   files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];

struct SCcolumn_data_st data;
struct SCfree_data_st fdata;
static char *fname = "nfm_client_debug_on";

    _NFIdebug ((fname, "Enter.\n"));

    fdata.num_of_rows = 5;
    fdata.num_of_cols = 1;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_MULTI_ROW;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_size[0] = 12;

    fdata.col_pos = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_pos, 0 , (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_pos[0] = 0;

    fdata.col_just = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols * sizeof (int)));
    
    fdata.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h1_pos, 0, sizeof (int) + 1);
    fdata.h1_pos[0] = 0;
    fdata.h1_pos[1] = -1;

    fdata.h2_pos = (int *) malloc ((fdata.num_of_cols * sizeof (int)) + 1);
    memset (fdata.h2_pos, 0, (fdata.num_of_cols * sizeof (int)) + 1);
    fdata.h2_pos[0] = 0;
    fdata.h2_pos[1] = -1;
    
    fdata.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h3_pos, 0, sizeof (int) + 1);
    fdata.h3_pos[0] = 0;
    fdata.h3_pos[1] = -1;
    
    fdata.h1_data = (char **) malloc (sizeof (char *));
    memset (fdata.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&fdata.h1_data[0], "");
    
    fdata.h2_data = (char **) malloc (tot_data * (sizeof (char *)));
    memset (fdata.h2_data, NULL, tot_data * (sizeof (char *)));
    NFAput_string (&fdata.h2_data[0], "");
    
    fdata.h3_data = (char **) malloc (sizeof (char *));
    memset (fdata.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&fdata.h3_data[0], "");
    
    strcpy (fdata.title, "Choose Subsystem(s) For Debug");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&fdata.data[0], "NFI  Debug");
    NFAput_string (&fdata.data[1], "NFMR Debug");
    NFAput_string (&fdata.data[2], "NETC Debug");
    NFAput_string (&fdata.data[3], "MEMC Debug");
    NFAput_string (&fdata.data[4], "ERRC Debug");

    /* process free form */
    status = SCprocess_free_form (&fdata, NFMprint_file);

    if (fdata.sts == FORM_CANCELED)
        {
        _NFIdebug ((fname, "Cancel from form. Return.\n"));
        NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        free (fdata.data);
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
        }

    count = 0;
    for (i=0; i<fdata.num_of_rows; ++i)
        {
        if ((fdata.select_set[i] == 1) || (fdata.sts == FORM_SELECTED))
            {
            ++count;
            }
        }

/***********************************************************************
    Get Debug output file information
***********************************************************************/

    pos = 0;
    data.num_of_rows = count;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 12;
    data.col_width[1] = 50;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Debug File Names");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0, j=0; i<fdata.num_of_rows; ++i)
        {
        if ((fdata.select_set[i] == 1) || (fdata.sts == FORM_SELECTED))
            {
            NFAput_string (&data.data[j], fdata.data[i*fdata.num_of_cols]);
            NFAput_string (&data.data[j+1], "/dev/console");
            j+=data.num_of_cols;
            }
        }

    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            /* 48 character file limit because of MSGstruct.h */
            for (i=pos; i<tot_data; i+=data.num_of_cols)
                status = NFAvalidate_string ("char(50)", data.data[i+1]);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFIdebug ((fname, "Cancel from form. Return.\n"));
        NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        free (fdata.data);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
        }

    SCdisplay_msg ("Working..");

    for( i=0; i<NFM_DEBUG_SUBSYSTEMS; ++i )
    {
	toggles[i] = 0;
	strcpy( files[i], "/dev/console" );
    }

    for (i=0; i<tot_data; i+=data.num_of_cols)
        {
             if (strncmp (data.data[i], "NFI", 3) == 0)
                 {
                 toggles[0] = 1;
                 strcpy (files[0], data.data[i+1]);
                 }

        else if (strncmp (data.data[i], "NFMR", 4) == 0)
                {
                toggles[2] = 1;
                strcpy (files[2], data.data[i+1]);
                 NFMRmsg_ptr.debug_on = 1;
                 strcpy (NFMRmsg_ptr.debug_file, data.data[i+1]);
                }

        else if (strncmp (data.data[i], "NETC", 4) == 0)
                {
                toggles[3] = 1;
                strcpy (files[3], data.data[i+1]);
                }

        else if (strncmp (data.data[i], "MEMC", 4) == 0)
                {
                toggles[4] = 1;
                strcpy (files[4], data.data[i+1]);
                }

        else if (strncmp (data.data[i], "ERRC", 4) == 0)
                {
                toggles[5] = 1;
                strcpy (files[5], data.data[i+1]);
                }
        }
  
    status = NFMRclient_debug ( toggles, files );

    _NFIdebug ((fname, "NFMRclient_debug -> <0x%.8x>\n", status));

    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);
    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    if( status != NFM_S_SUCCESS )
	return( status );

    return (NFI_S_SUCCESS);
}


long server_debug_off ()

{
long   status;
int    i;
int    toggles[NFM_DEBUG_SUBSYSTEMS];
char   files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];
static char *fname = "nfm_server_debug_off";

    _NFIdebug ((fname, "Enter.\n"));

    /*for( i=0; i<(NFM_DEBUG_SUBSYSTEMS+1); ++i )*/
    /* Array is accessed beyond size - SSRS 25 Jan 94*/
    for( i=0; i<(NFM_DEBUG_SUBSYSTEMS); ++i )
    {
	toggles[i] = 0;
	strcpy( files[i], "" );
    }

    status = NFMRall_debug ( toggles, files );

    _NFIdebug ((fname, "NFMRall_debug -> <0x%.8x>\n", status));

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);

    if( status != NFM_S_SUCCESS )
	return( status );       
 
    return (NFI_S_SUCCESS);
}

long client_debug_off ()

{
long   status;
int    i;
int    toggles[NFM_DEBUG_SUBSYSTEMS];
char   files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];
static char *fname = "nfm_client_debug_off";

    _NFIdebug ((fname, "Enter.\n"));

    /*for( i=0; i<(NFM_DEBUG_SUBSYSTEMS+1); ++i )*/
    /* Array is accessed beyond size - SSRS 25 Jan 94*/
    for( i=0; i<(NFM_DEBUG_SUBSYSTEMS); ++i )
    {
	toggles[i] = 0;
	strcpy( files[i], "" );
    }

    NFMRmsg_ptr.debug_on = 0;
    strcpy (NFMRmsg_ptr.debug_file, "");

    status = NFMRclient_debug ( toggles, files );

    _NFIdebug ((fname, "NFMRclient_debug -> <0x%.8x>\n", status));

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);

    if( status != NFM_S_SUCCESS )
	return( status );       
 
    return (NFI_S_SUCCESS);
}

long catalog ()

{
long   status;
int    i;
int    tot_data;
int    pos;

struct SCcolumn_data_st data;
int    FORM_FILLED;
static char *fname = "nfm_catalog";

    _NFIdebug ((fname, "Enter.\n"));

    pos = 0;
    data.num_of_rows = 7;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 13;
    data.col_width[1] = 60;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter NFM Catalog and Item/Revision");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Project Name");
    NFAput_string (&data.data[2], "Catalog Name");
    NFAput_string (&data.data[4], "Item Name");
    NFAput_string (&data.data[6], "Item Revision");
    NFAput_string (&data.data[8], "Set Indicator");
    NFAput_string (&data.data[10], "Node");
    NFAput_string (&data.data[12], "Storage Area");

    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            for (i=pos; i<tot_data; i+=data.num_of_cols)
                status = NFAvalidate_string ("char(60)", data.data[i+1]);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFIdebug ((fname, "Cancel from form. Return.\n"));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
        }

    if (data.data[1] != NULL)
        strcpy (NFMproject, data.data[1]);
    if (data.data[3] != NULL)
        strcpy (NFMcatalog, data.data[3]);
    if (data.data[5] != NULL)
        strcpy (NFMitem, data.data[5]);
    if (data.data[7] != NULL)
        strcpy (NFMrev, data.data[7]);
    if (data.data[9] != NULL)
        NFMset_ind = atoi( data.data[9] );
    if (data.data[11] != NULL)
        strcpy (NFMnode, data.data[11]);
    if (data.data[13] != NULL)
        strcpy (NFMstorage, data.data[13]);

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long print_file ()

{
long   status;
int    i;
int    tot_data;
int    pos;
int    FORM_FILLED;

struct SCcolumn_data_st data;
static char *fname = "nfm_print_file";

    _NFIdebug ((fname, "Enter.\n"));

    pos = 0;
    data.num_of_rows = 1;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 20;
    data.col_width[1] = 40;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Print File Name");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "File Name");

    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            for (i=pos; i<tot_data; i+=data.num_of_cols)
                status = NFAvalidate_string ("char(40)", data.data[i+1]);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFIdebug ((fname, "Cancel from form. Return.\n"));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
        }

    if (data.data[1] != NULL)
        strcpy (NFMprint_file, data.data[1]);

    _NFIdebug ((fname, "NFMprint_file <%s>\n", NFMprint_file));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long test_messages()
{
    long  status;
    long  user_id = 100;
    MEMptr attr = NULL;
    MEMptr bdata = NULL;
    MEMptr value = NULL;
static char *fname = "test_messages";

    _NFIdebug ((fname, "Enter.\n"));

    status = NFMRquery_user_defaults ( user_id, &attr, &bdata, &value );

    _NFIdebug ((fname,
          "NFMRtest_messages (NFMRquery_user_defaults) -> <0x%.8x>\n", status));
    status = NFAdisplay_message_set( "Who Cares ?" );

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);

    if( status != NFM_S_SUCCESS )
	return( status );       
 
    return (NFI_S_SUCCESS);
}
