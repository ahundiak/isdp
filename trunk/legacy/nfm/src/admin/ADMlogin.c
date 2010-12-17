#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFIerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "SCextern.h"
#include "ERR.h"
#include "NDXstruct.h"
#include "MSGstruct.h"
#include "DEBUG.h"
#include "NFMstruct.h"

extern long sqlstatus;
long NFMuser_id ; 
extern char   NFMprint_file[] ;
extern struct NFMglobal_st NFMglobal;
char    SCHEMA [25];
int     LOGIN_FLAG =1;

ADMlogin () 
{
char   env_name[100];
char   user_name[100];
char   user_passwd[100];
long   user_pid ;
long   status;
int    i, j, k;
int    tot_data;
int    pos;
int    login_count = 0;
struct SCcolumn_data_st data;
int    FORM_FILLED;
static char *fname = "ADMlogin";

    _NFMdebug ((fname, "ENTER\n"));

    pos = 4;
    data.num_of_rows = 5;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
  
    data.col_width[0] = 15;
    data.col_width[1] = 20;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Log In To I/NFM");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFMput_string (&data.data[0], "Attribute");
    NFMput_string (&data.data[4], "Username");
    NFMput_string (&data.data[5], "");
    NFMput_string (&data.data[6], "Password");
    NFMput_string (&data.data[7], "");
    NFMput_string (&data.data[8], "Environment");
    NFMput_string (&data.data[9], "");

    /* hide password */
    data.hidden[7] = 1;

    SCclear_msg ();

/* if this is the first time through and they gave a command line user,
   don't call the login form */

do {
	    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));
      
    if (data.sts == FORM_CANCELED)
        {
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        _NFMdebug ((fname, "Cancel Form.\n"));
        ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        ADMmessage ();
        return (NFI_W_FORM_CANCELED);
        }
   
    /* save login user name and passwd */
    strcpy (user_name, data.data[5]);
    strcpy (user_passwd, data.data[7]);
    sprintf (env_name, "nfme_%s", data.data[9]);
    strcpy (NFMglobal.environment_name, data.data[9]);

    
  SCclear_ref ();
  SCdisplay_msg ("Working..");    

  ERRreset_struct ();  
  strcpy (SCHEMA, env_name);
  status = NFMlog_in (user_name, user_passwd, env_name, "NFM") ;

  _NFMdebug ((fname, "NFMlogin : <0x%.8x>\n", status));
  ADMmessage ();
  
  
  if (status != NFM_S_SUCCESS)
      ++login_count ;
}
while ((login_count < 3) && (status != NFM_S_SUCCESS)) ;

NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
free (data.data);
 ADMmessage ();

    if (login_count >= 3)
        {
        ERRload_struct( NFM, NFM_E_FAILURE, NULL, NULL);
        _NFMdebug ((fname, "EXIT - Login Retry Limit\n"));
        ADMmessage ();
        return (NFM_E_FAILURE);
        }

    _NFMdebug ((fname, "EXIT\n"));

    LOGIN_FLAG = 0;    

    return (status);
}

ADMlogout ()
{
long   status;
char   str [512];
static char *fname = "ADMlogout";

    _NFMdebug ((fname, "ENTER\n"));
 
     SCdisplay_msg("Working...");

     status = ADMlogoff(SCHEMA);
       _NFMdebug ((fname, "EXIT : status = <0x%.8x>\n", status));

     SCclear_msg ();

     LOGIN_FLAG =1;

    return (NFM_S_SUCCESS);
}




