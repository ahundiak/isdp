#include <stdio.h>
#include <sys/utsname.h>
#include <FI.h>
#include <tools.h>
#include <PDUuser.h>
#include <PDUstr.h>
#include <PDUforms.h>
#include <MEMstruct.h>
#include <MEMerrordef.h>
#include <NETerrordef.h>
#include <signal.h>
#include <PDMtypes.h>
#include <PDUerror.h>
#include <PDUintdef.h>
#include <PDUextdef.h>
#include <PDUform_def.h>
#include <PDUfile_def.h>
#include <PDUcommand.h>
#include <PDMtypes.h>
#include <PDMmessage.h>
#include <NFMerrordef.h>
#include <errno.h>
#include <exdef.h>
#include "PDUproto.h"
#include "PDMproto.h"


/* Gadgets */

#define USERNAME        14
#define PASSWORD        15
#define ENVIRONMENT     16
#define ENV_LIST_BTN    22


/* Externs */

extern char * calloc();
extern char * realloc();
extern char *** PDU_update_struct;
extern char *PDU_apimessage;
extern int * PDU_gadget_labels;
extern int FIg_get_text_length();
extern int FIg_get_text();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();
extern int FIg_get_type();
extern int PDU_login_created;
extern int PDU_login_displayed;
extern int PDU_login;
extern int PDU_connection;
extern int PDU_pdm_initialized;
extern int PDMsock;
extern int PDU_active_button;
extern int PDU_command;
extern int PDU_apiflag;
extern short PDU_default_env;
extern short PDU_auto_login;
extern short PDU_extadmin;
extern Form PDU_form_id;
extern MEMptr PDU_ret_bufr;
extern struct PDUuser      *user;
extern struct PDUrefresh   *refresh;
extern struct PDUforms      forms;

extern int    passwd;
 
static short login_from_ex_file_form = FALSE;

int login_notification_routine ( f_label, g_label, value, fp )
  int     f_label;        /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;          /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             length, select, pos;
  int             status = PDM_S_SUCCESS;
  int             all_flag = FALSE;
  int             row;
  int             responses[1];
  char          * strings[1];
  char         ** data_row = NULL;
  char          * msg = NULL;
  MEMptr          ret_bufr = NULL;

  FIg_set_text(fp, FI_PROMPT_FIELD, NULL_STRING);
  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  PDU_form_id = fp;
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

	 f_label = 0;
         value = 0.0;

         FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
         _pdm_debug ("User selected the HELP button", 0);
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         Help_topic("login");

         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */
         PDUmessage(PDM_E_CLEAR_FIELD, 's');

         /* reset the user structure */
         user->username = NULL;
         user->passwd = NULL;
         user->environment = NULL;

         _pdm_debug("User selected the cancel button", 0);

         if (PDU_login_displayed == TRUE)
           FIf_erase( fp );
         if (PDU_login_created == TRUE)
           FIf_delete( fp );

         PDUdismiss_subforms();

         PDU_login_displayed = FALSE;
         PDU_login_created = FALSE;

         status = PDM_E_CMD_CANCELLED;

         if ((PDU_auto_login) && (login_from_ex_file_form))
           {
           PDU_auto_login = FALSE;
           }
         else if (PDU_auto_login)
           {
           responses[0] = RESET;
           strings[0] = "";
           PDUprepare_queue(responses, strings, 1);
           }


         break;

    case FI_RESET:     /* Member of group FI_CTRL_GROUP */

         PDUdismiss_subforms();

         user->environment = NULL;
         user->username = NULL;
         user->passwd = NULL;

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

	 _pdm_debug("processing login form", 0);
	 _pdm_debug("user->username = <%s>", user->username);
	 _pdm_debug("user->passwd = <%s>", user->passwd);
	 _pdm_debug("user->environment = <%s>", user->environment);

         if ((user->username == NULL) || (strcmp(user->username, "") == 0))
           {
           _pdm_debug("User checked off form with username NULL", 0);
          
           msg = (char *)PDUtranslate_message(PDM_E_ENTER_USERNAME); 
           FIg_set_text(fp, FI_PROMPT_FIELD, msg);
           FIg_set_state_off(forms.login_form_id, FI_ACCEPT);
           break;
           }
 
         if ((user->environment == NULL) ||
             (strcmp(user->environment, "") == 0))
           {
           _pdm_debug("User checked off form with environment NULL", 0);
           msg = (char *)PDUtranslate_message(PDM_E_ENTER_ENVIRONMENT);
           FIg_set_text(fp, FI_PROMPT_FIELD, msg);
           FIg_set_state_off(forms.login_form_id, FI_ACCEPT);
           break;
           }

         /* erase the login form */
/*
         if (PDU_login_displayed == TRUE)
           FIf_erase( fp );
*/

         PDUdismiss_subforms();

         status = PDUprocess_wrkst_info();
         _pdm_status("PDUprocess_wrkst_info", status);

         if ((status != PDM_S_SUCCESS) && (!PDU_auto_login))
           return(status);
         else if ((status != PDM_S_SUCCESS) && (PDU_auto_login) && 
                  (login_from_ex_file_form))
           {
           PDU_auto_login = FALSE;
           break;
           }
         else if ((status != PDM_S_SUCCESS) && (PDU_auto_login))
           {
           responses[0] = RESET;
           strings[0] = "";
           PDUprepare_queue(responses, strings, 1);
           break;
           }

         status = PDUprocess_login();
         _pdm_status("PDUprocess_login", status);

         if ((PDU_auto_login) && (login_from_ex_file_form) && 
             (status == PDM_S_SUCCESS))
           {
           PDU_auto_login = FALSE;
           PDUprocess_ex_file_form_after_login();
           }
         else if (PDU_auto_login)
           {
           refresh->status = status;
           if (status != PDM_S_SUCCESS)
             responses[0] = RESET;
           else
             responses[0] = MOVE_ON;
           strings[0] = "";
           PDUprepare_queue(responses, strings, 1);
           }


         break;

    case USERNAME:         /* Field Type:    ASCII    */

          _pdm_debug("Getting the username field", 0);
	  FIfld_get_text_length(fp, USERNAME, 0, 0, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp, USERNAME, 0, 0, length, (unsigned char *)text,
                         &select, &pos);

          if ((text != NULL) && (strcmp(text, "") != 0))
            {
            PDUfill_in_string(&user->username, text);
            _pdm_debug("username = %s", user->username);
            }

         break;

    case PASSWORD:     /* Field Type:    ASCII    */ 

          _pdm_debug("Getting the password field", 0);
	  FIfld_get_text_length(fp, PASSWORD, 0, 0, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp, PASSWORD, 0, 0, length, (unsigned char *)text,
                         &select, &pos);

          if (text != NULL)
            {
            PDUfill_in_string(&user->passwd, text);
            _pdm_debug("passwd = %s", user->passwd);
            }

         break;

    case ENVIRONMENT:         /* Field Type:    ASCII    */

          _pdm_debug("Getting the environment field", 0);
	  FIfld_get_text_length(fp, ENVIRONMENT, 0, 0, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp, ENVIRONMENT, 0, 0, length, (unsigned char *)text,
                         &select, &pos);

          /* Code to process text string "text" */
          if (text == NULL)
            {
            user->environment = NULL_STRING;
            break;
            }
          else if (strcmp(text, "") == 0)
            {
            user->environment = NULL_STRING;
            break;
            }

#if !defined (sparc) && !defined (__Sol2__) && !defined (__sgi)
            /* call function to retrieve a list of environments to verify keyed
               in environment against  */
            status = NFMls_nodes("pdme_", &ret_bufr);
            _pdm_status("NFMls_nodes", status); 

            if ( status != NFM_S_SUCCESS )
              {
              msg = (char *)PDUtranslate_message(PDM_E_BAD_ENV);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              return(PDM_E_LIST_ENVS);
              }

#else

         /* call function to get list of SUN environments */
         status = PDUget_envs(&ret_bufr);

         if ( status != PDM_S_SUCCESS )
           {
           msg = (char *)PDUtranslate_message(PDM_E_BAD_ENV);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           MEMclose(&PDU_ret_bufr);
           return(PDM_E_LIST_ENVS);
           }

#endif

            status = PDM_E_INVALID_ENV;

            MEMbuild_array(ret_bufr);
            PDUsetup_buffer(ret_bufr, ROW, &data_row);
            for (row = 0; row < ret_bufr->rows; ++row)
               {
               if (strcmp(data_row[(ret_bufr->columns * row) + 0], text) == 0)
                 {
                 status = PDM_S_SUCCESS;
                 PDUfill_in_string(&user->environment, text);
                 _pdm_debug("user->environment = %s", user->environment);
                 break;
                 }
               }
            if (status == PDM_E_INVALID_ENV)
              {
              FIfld_set_text(fp, ENVIRONMENT, 0, 0, "", FALSE);
              FIfld_pos_cursor(fp, ENVIRONMENT, 0,0,0,0,1,1);
              msg = (char *)PDUtranslate_message(PDM_E_BAD_ENV);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              user->environment = NULL_STRING;
              }

         if (ret_bufr != NULL)
           MEMclose(&ret_bufr);
         break;

    case ENV_LIST_BTN:
         PDU_active_button = ENV_LIST_BTN;
         FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);

         /* set flag not to default the environment */
         PDU_default_env = FALSE;

         /* call function to retrieve a list of environments */
         if (PDU_ret_bufr != NULL)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }

#if !defined (sparc) && !defined (__Sol2__) && !defined (__sgi)
         status = NFMls_nodes("pdme_", &PDU_ret_bufr);
         _pdm_status("NFMls_nodes", status); 

         if ( status != NFM_S_SUCCESS )
           {
           msg = (char *)PDUtranslate_message(PDM_E_BAD_ENV);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           MEMclose(&PDU_ret_bufr);
           return(PDM_E_LIST_ENVS);
           }
#else
         
         /* call function to get list of SUN environments */
         status = PDUget_envs(&PDU_ret_bufr);

         if ( status != PDM_S_SUCCESS )
           {
           msg = (char *)PDUtranslate_message(PDM_E_BAD_ENV);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           MEMclose(&PDU_ret_bufr);
           return(PDM_E_LIST_ENVS);
           }
#endif

         PDUsetup_single_buffer(PDU_ret_bufr);
         PDU_form_id = forms.login_form_id;
         PDU_gadget_labels[0] = ENVIRONMENT;
         PDU_update_struct[0] = &user->environment; 

         all_flag = TRUE;

         PDUsetup_popup_list(NULL, 0, all_flag, PDU_ret_bufr);
         PDUsetup_form_fields(NULL, 0, all_flag, PDU_ret_bufr);
         PDUsetup_struct_fields(NULL, 0, all_flag, PDU_ret_bufr);

         status = PDUsingle_list_form();
         break;

  } /* END switch ( g_label ) */

  return(status);

} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the login form. */

int PDUlogin_form()
{
  int  sts = PDM_S_SUCCESS;
  int  xpos;
  int  ypos;

  _pdm_debug("entering PDUlogin", 0);

  if (PDU_login_created == TRUE)
    return(PDM_S_SUCCESS);

  if (user->username != NULL)
    return(PDM_S_SUCCESS);

  PDU_form_id = forms.login_form_id;

  PDU_command = PDC_M_LOGIN_USER;
  PDU_apiflag = FALSE;
  PDU_apimessage = NULL;

  PDU_login_created = FALSE;
  PDU_login_displayed = FALSE;

  sts = FIf_new(LOGIN_FORM, "login", login_notification_routine,
                &forms.login_form_id);

  _pdm_debug("Creating login form", 0);
  PDU_login_created = TRUE;

  /* Set location of login form */
  xpos = 306;
  ypos = 122;
  FIf_set_location(forms.login_form_id, xpos, ypos);

  /* Display the login form and set the displayed flag to TRUE. */
  _pdm_debug("Displaying the login form", 0);

  sts = FIf_display(forms.login_form_id);
  PDU_login_displayed = TRUE;

  sts = PDUget_login_form_data();
  if (sts != PDM_S_SUCCESS)
    {
    PDUmessage(sts, 's');
    return(sts);
    }

  /*_pdm_debug("server = <%s>", user->server);*/
  if (user->environment)
    _pdm_debug("environment = <%s>", user->environment);
  if (user->username)
    _pdm_debug("username (from refresh.dat file) = <%s>", user->username);

  if ((user->username) && (strcmp(user->username, "") != 0))
    {
    FIg_set_text(forms.login_form_id, USERNAME, user->username);

    if ((user->environment) && (strcmp(user->environment, "") != 0))
      FIg_set_text(forms.login_form_id, ENVIRONMENT, user->environment);
    else
      FIfld_pos_cursor(forms.login_form_id, ENVIRONMENT, 0, 0, 0, 0, 1, 1);

    FIfld_pos_cursor(forms.login_form_id, PASSWORD, 0, 0, 0, 0, 1, 1);
    }
  else
    FIfld_pos_cursor(forms.login_form_id, USERNAME, 0, 0, 0, 0, 1, 1);

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  return(PDM_S_SUCCESS);
}

int PDUprocess_login()
{
int      *fn;
void       PDMterminate();
int       status = PDM_S_SUCCESS;
char     *msg = NULL;
struct utsname system_name;
char *env_var_name = NULL;

  _pdm_debug("in the function PDUprocess_login", 0);


  /* Set up the environment variable INGRHOME if it has not been set */
  /* ALR  2/3/94  */
   env_var_name = (char *)getenv("INGRHOME");
   _pdm_debug("env_var_name |%s| \n",env_var_name);
/* ALR   5/11/94   This is not the correct settings for SGI ?? 
   if (!((env_var_name) && (strcmp(env_var_name,"/usr/ip32") == 0)) ||
      ((env_var_name) && (strcmp(env_var_name,"/var/opt/ingr") == 0)) || 
      ((env_var_name) && (strcmp(env_var_name,"/opt/ingr") == 0)))
*/
    if (!env_var_name)
    {
     _pdm_debug("execute uname stmt \n",0);
     uname(&system_name);
     if (strncmp(system_name.sysname,"CLIX",4) == 0) 
       putenv("INGRHOME=/usr/ip32");
         /* SGI */
     if (strncmp(system_name.sysname,"IRIX",4) == 0)
       putenv("INGRHOME=/var/opt/ingr");
     if (strncmp(system_name.sysname,"SunOS",5) == 0)
      {     /* SunOS 4.1 */
        if (strncmp(system_name.release,"4.1",2) == 0)
          putenv("INGRHOME=/usr/ip32");
           /* Solaris */
        else 
          putenv("INGRHOME=/opt/ingr");
      }
    }

  /*_pdm_debug("server = <%s>", user->server);*/
  _pdm_debug("environment = <%s>", user->environment);
  _pdm_debug("username = <%s>", user->username);

  PDUload_storage_area();
/*
  status = PDUget_storage_buffer(&PDU_storage_area);
  _pdm_status("PDUget_storage_buffer", status);
*/

  if (status != PDM_S_SUCCESS)
    return(status);

  if (PDU_login_created)
    {
    msg = (char *)PDUtranslate_message(PDS_M_USER_LOGIN);
    FIg_set_text(forms.login_form_id, FI_MSG_FIELD, msg);
    }

  refresh->command = PDC_M_LOGIN_USER;
  status = PDMrlogin(	 user->username,
                         user->passwd,
                         user->environment, 
                         1, /* login flag */
                         &user->user_id);
  _pdm_status("PDMrlogin", status);

  if ( status == PDM_S_SUCCESS )
    {
    _pdm_debug("user id returned from host = %d", (char *)user->user_id);
    _pdm_debug("Setting up function call to PDUlogout", 0);
    fn = (int *)PDMterminate;
    exitadd(fn);

/* added 2 more signals...*/

    _pdm_debug("Added 2 more signals..", 0);
    signal(2,PDMterminate);
    signal(10,PDMterminate);
    signal(11,PDMterminate);
    signal(15,PDMterminate);
    signal(7,PDMterminate);
    signal(8,PDMterminate);
    /* ignore signal (13) */
    signal(13,SIG_IGN);
    PDUmessage(status, 's');

    }
  else
    {
    if (status == NFM_E_BAD_NODE)
      status = PDM_E_BAD_NODE;
    if (status == NFM_E_BAD_PROTOCOL)
      status = PDM_E_BAD_PROTOCOL;
    if (status == NFM_E_BAD_USER)
      status = PDM_E_BAD_USERNAME;
    if (status == NFM_E_BAD_ENV)
      status = PDM_E_BAD_ENV;
    if (status == NFM_E_CLH)
      status = PDM_E_CLH;
    if (status == NFM_E_USER_PASSWD)
      status = PDM_E_USER_PASSWD;
    if (status == NFM_E_LOCATE_SCHEMA_FILE)
      status = PDM_E_LOCATE_SCHEMA_FILE;

    PDUmessage(status, 's');

    /* redisplay the login form with same data */
    if (PDU_login_created == TRUE)
      {
/*
      FIf_display(forms.login_form_id);
*/
      FIg_set_state_off(forms.login_form_id, FI_ACCEPT);
      if (status == PDM_E_USER_PASSWD)
        {
        PDUfill_in_string1(&user->passwd, "");
        FIg_set_text(forms.login_form_id, PASSWORD, "");
        }
      }
    else  /* clear out the username field */
      user->username = NULL;

    /* close the PDM server socket */
/*
    status = NETclose(&PDMsock);
    if (status != NET_S_SUCCESS)
      {
      _pdm_debug("Could not close server socket", 0);
      return(status);
      }
    else
      PDU_connection = FALSE;
*/

    return(status);
    }

  if ( status == PDM_S_SUCCESS )
    {
      _pdm_debug("Calling PDMverify init", 0);

      /* Check to see if PDM has been initialized on the server */
      if (PDU_pdm_initialized == FALSE)
         {
          status = PDMrverify_init("PDM", "2.2.0"); 
          _pdm_status("PDMrverify_init", status);
     
          if ( status == PDM_S_SUCCESS )
             PDU_pdm_initialized = TRUE;
          else
             return(PDM_E_INITIALIZED);
         }


      /* save the current file name for use in PDUinternal only */
      status = PDUset_default_file();              
      _pdm_status("PDUset_default_file",status);

      PDU_login = TRUE;
      PDUmessage(PDM_S_LOGIN, 's');
       
      /* Delete the login form */
      if (PDU_login_created == TRUE)
        {
        FIf_delete( forms.login_form_id );
        PDU_login_created = FALSE;
        }

      if (PDU_extadmin)
        {
        PDU_form_id = forms.local_files_form_id;
        PDUlocal_files_form();
        }
      else
        {
        PDU_form_id = forms.design_form_id;
        PDUdesign_form();
        }
      }
    else
      if ( status != PDM_I_FORM_CANCEL )
        {
        _pdm_debug("Could not process form",0);
        }
/*
  _pdm_debug("PDUconnection = %d", PDU_connection);
*/

  return (status);
  }

int PDUdefault_env(fp)
  Form       fp;
{
  int        status = PDM_S_SUCCESS;
  int        row;
  MEMptr     ret_bufr = NULL;
  char       **data_row;
  char       *msg = NULL;

  /* call function to retrieve a list of environments to verify keyed
     in server against  */

#if !defined (sparc) && !defined (__Sol2__) && !defined (__sgi)
  status = NFMls_nodes("pdme_", &ret_bufr);
  _pdm_status("NFMls_nodes", status); 

  if ( status != NFM_S_SUCCESS )
    {
    msg = (char *)PDUtranslate_message(PDM_E_BAD_ENV);
    FIg_set_text(fp, FI_MSG_FIELD, msg);
    return(PDM_E_LIST_ENVS);
    }
#else
    /* call function to get list of SUN servers */
    status = PDUget_envs(&ret_bufr);

    if ( status != PDM_S_SUCCESS )
      {
      msg = (char *)PDUtranslate_message(PDM_E_BAD_ENV);
      FIg_set_text(fp, FI_MSG_FIELD, msg);
      return(PDM_E_LIST_ENVS);
      }
#endif

  MEMbuild_array(ret_bufr);
  PDUsetup_buffer(ret_bufr, ROW, &data_row);
  for (row = 0; row < ret_bufr->rows; ++row)
     {
     if (strcmp(data_row[(ret_bufr->columns * row) + 0], user->server) == 0)
       {
       status = PDM_S_SUCCESS;
       PDUfill_in_string(&user->environment, user->server);
       FIfld_set_text(fp, ENVIRONMENT, 0, 0, user->environment, FALSE);
       _pdm_debug("user->environment = %s", user->environment);
       break;
       }
     }
  if (ret_bufr != NULL)
    MEMclose(&ret_bufr);

  FIfld_pos_cursor(fp, USERNAME, 0,0,0,0,1,1);

  return(status);
}

char *get_remote_path( path, node )
char *path, **node;
{
     path = "";
     node[0] = "";
     _pdm_debug ("get_remote_path: Stubbed for now", 0);
     return ( NULL_STRING );
}
 

int PDUautomatic_login(flag)
short flag;
{
  int   status = PDM_S_SUCCESS;
  int   status1 = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUautomatic_login", 0);

  _pdm_debug("verifying login", 0);
  if (user->username && (strcmp(user->username, "") != 0))
    return(PDM_S_SUCCESS);

  PDU_auto_login = TRUE;
  login_from_ex_file_form = flag;
  status = PDUlogin_form();
  _pdm_status("PDUlogin_form", 0);

  if (flag)
    return(status);

  status1 = WaitForEvent();
  _pdm_status("WaitForEvent", status1);

  PDU_auto_login = FALSE;
  if (status == PDM_E_CMD_CANCELLED)
    _pdm_debug("login form was cancelled", 0);
  else if (status != PDM_S_SUCCESS)
    _pdm_debug("login failed", 0);

  return(status1);
}
