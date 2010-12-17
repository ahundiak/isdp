#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "ERR.h"
#include "NDXstruct.h"

extern long sqlstatus;
extern char WORKING_user[20];

long change_user_passwd ()

{
long   status;
int    i;
int    tot_data;
int    pos;
struct SCcolumn_data_st data;
int    FORM_FILLED;
static char *fname = "change_user_passwd";

    _NFIdebug ((fname, "Enter.\n"));

    pos = 0;
    data.num_of_rows = 2;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 25;
    data.col_width[1] = 15;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "Enter User Password Information for '%s'", WORKING_user);

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "New Password");
    NFAput_string (&data.data[2], "New Password Verification");

    data.hidden[1] = 1;
    data.hidden[3] = 1;

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
                status = NFAvalidate_string ("char(15)", data.data[i+1]);

            /* new password must match verification password */
            if (strcmp (data.data[1], data.data[3]) != 0)
                {
                FORM_FILLED = FALSE;
                SCdisplay_msg ("NFM:  New Password Verification Error.");
                }
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    SCdisplay_msg ("Working..");

    status = NFMRchange_user_passwd (NFMuser_id, WORKING_user, " ",
                                     data.data[1]);

    _NFIdebug ((fname, "NFMRchange_user_passwd -> <0x%.8x>\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (status != NFM_S_SUCCESS)
	return( status );

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long change_self_passwd ()

{
long   status;
int    i;
int    tot_data;
int    pos;
struct SCcolumn_data_st data;
int    FORM_FILLED;
static char *fname = "change_self_passwd";

    _NFIdebug ((fname, "Enter.\n"));

    pos = 0;
    data.num_of_rows = 3;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 25;
    data.col_width[1] = 15;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "Enter User Password Information for '%s'", NFMuser);

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Old Password");
    NFAput_string (&data.data[2], "New Password");
    NFAput_string (&data.data[4], "New Password Verification");

    data.hidden[1] = 1;
    data.hidden[3] = 1;
    data.hidden[5] = 1;

    /* process column form until all info has been entered */
    do
     {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
         {
            /* compair the NFMpaswwd with passwd user enter */
            if (strcmp (data.data[1], NFMpasswd) !=0 )
             {
               _NFIdebug((fname, " the NFMpasswd is not match\n", NFMpasswd));
                FORM_FILLED = FALSE;
                SCdisplay_msg ("NFM:  Old Password doesn't match.");
              }
            /* new password must match verification password */
            if (strcmp (data.data[3], data.data[5]) != 0)
             {
                FORM_FILLED = FALSE;
                SCdisplay_msg ("NFM:  New Password Verification Error.");
              }
          }
      }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    SCdisplay_msg ("Working..");


    status = NFMRchange_user_passwd (NFMuser_id, NFMuser, data.data[1],
                                     data.data[3]);

    _NFIdebug ((fname, "NFMRchange_user_passwd -> <0x%.8x>\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (status != NFM_S_SUCCESS)
        {
	ERRload_struct( NFI, NFI_E_CHANGE_USER_PASSWORD, NULL, NULL );
	return( status );
        }

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long change_sa_passwd ()

{
long   status;
int    i;
int    tot_data;
int    pos;
struct SCcolumn_data_st data;
int    FORM_FILLED;
char   storage_name[20];
static char *fname = "change_sa_passwd";

    _NFIdebug ((fname, "Enter.\n"));

    pos = 2;
    data.num_of_rows = 4;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 25;
    data.col_width[1] = 15;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Storage Area Password Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    status = NFAget_st_area_name (storage_name);
    if (status != NFI_S_SUCCESS)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        NFMRset_error (status, "NFMchange_sa_passwd : NFAget_st_area_name.");
        return (NFM_E_FAILURE);
        }

    NFAput_string (&data.data[0], "Storage Area Name");
    NFAput_string (&data.data[1], storage_name);
    NFAput_string (&data.data[2], "Old Password");
    NFAput_string (&data.data[4], "New Password");
    NFAput_string (&data.data[6], "New Password Verification");

    data.hidden[3] = 1;
    data.hidden[5] = 1;
    data.hidden[7] = 1;

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
		{
                status = NFAvalidate_string ("char(15)", data.data[i+1]);
		if( data.data[i+1] == NULL )
		    NFAput_string( &data.data[i+1], "" );
		}
            /* new password must match verification password */
            if (strcmp (data.data[5], data.data[7]) != 0)
                {
                FORM_FILLED = FALSE;
                SCdisplay_msg ("NFM:  New Password Verification Error.");
                }
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    SCdisplay_msg ("Working..");

    status = NFMRchange_storage_area_passwd (NFMuser_id, data.data[1], 
                                             data.data[3], data.data[5]);

    _NFIdebug ((fname, "NFMRchange_sa_passwd -> <0x%.8x>\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (status != NFM_S_SUCCESS)
	return( status );

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long change_wa_passwd ()

{
long   status;
int    i;
int    tot_data;
int    pos;
struct SCcolumn_data_st data;
int    FORM_FILLED;
static char *fname = "change_wa_passwd";

    _NFIdebug ((fname, "Enter.\n"));

    pos = 0;
    data.num_of_rows = 3;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 25;
    data.col_width[1] = 15;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "Enter Password Information for <%s>",	NFMworking);

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Old Password");
    NFAput_string (&data.data[2], "New Password");
    NFAput_string (&data.data[4], "New Password Verification");

    data.hidden[1] = 1;
    data.hidden[3] = 1;
    data.hidden[5] = 1;

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
		{
                status = NFAvalidate_string ("char(15)", data.data[i+1]);
		if( data.data[i+1] == NULL )
		    NFAput_string( &data.data[i+1], "" );
		}
            /* new password must match verification password */
            if (strcmp (data.data[3], data.data[5]) != 0)
                {
                FORM_FILLED = FALSE;
                SCdisplay_msg ("NFM:  New Password Verification Error.");
                }
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    SCdisplay_msg ("Working..");

    status = NFMRchange_working_area_passwd (NFMworking, 
                                             data.data[1], data.data[3]);

    _NFIdebug ((fname, "NFMRchange_wa_passwd -> <0x%.8x>\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    if (status != NFM_S_SUCCESS)
	return( status );

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



