#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "WFcommands.h"
#include "RPSdef.h"
#include "SCdef.h"
#include "DEBUG.h"
#include "NFIerrordef.h"
#include "NFMRextern.h"
#include "NFMschema.h"
#include "NFMstruct.h"

extern long sqlstatus;
extern char SCexec[30];
extern char SCuser_cmd_file[150];
extern char SCadmin_cmd_file[150];
extern int    LOGIN_FLAG;   /* This is declared in ADMlogin.c */
extern char   SCHEMA[25];   /* This is declared in ADMlogin.c */
extern struct NFMglobal_st NFMglobal;

extern char cmd_line_env[20];
extern char cmd_line_username[20];
extern char cmd_line_password[20];

NFMfunction login_in()
{ 
    long  status;
    char  env_name[100];
    char *fname = "login_in";

  _NFMdebug (("NFMfunction", "%s\n", "login_in"));

   ERRreset_struct();

   if (LOGIN_FLAG==0)
    {

      status = NFM_I_ALREADY_LOGGED_IN;
ERRload_struct (NFM, NFM_I_ALREADY_LOGGED_IN, "%s", NFMglobal.environment_name,NULL);
      ERRget_message (msg) ;
      SCdisplay_msg( msg );
      ERRreset_struct();
      return (status) ;

    }
   else
    {
/* tmpPS 

	if ( (strcmp(environment, "")) || (strcmp(username, "")) || 
	     (strcmp(password, "")) ) 
	{
  		strcpy (SCHEMA, cmd_line_env);
  		status = NFMlog_in (cmd_line_username, cmd_line_password, 
				    cmd_line_env, "NFM") ;
 
  		_NFMdebug ((fname, "NFMlogin : <0x%.8x>\n", status));
  		ADMmessage ();
 
  		if (status != NFM_S_SUCCESS)
        	{
          		return (status);
        	}
	}
	else
	{
 tmpPS */
	
       		ERRreset_struct ();

       		status =ADMlogin ();
       		if (status != NFM_S_SUCCESS)
        	{
          		return (status);
        	}
/*	} */
      }
    ADMmessage (msg);
    SCdisplay_msg (msg);
    ERRreset_struct ();    
    return (status);
}

NFMfunction log_out()
{ 
    long  status;

_NFMdebug (("NFMfunction", "%s\n", "log_out"));

   ERRreset_struct();

   if (LOGIN_FLAG==1)
    {
      status = NFM_I_ALREADY_LOGGED_OUT;

      ERRload_struct (NFM, NFM_I_ALREADY_LOGGED_OUT, NULL,NULL);
      ERRget_message (msg) ;
      SCdisplay_msg( msg );
      ERRreset_struct();
      return (status); 
    }
   else
    {
    ERRreset_struct();    
    status =ADMlogout ();
    if (status != NFM_S_SUCCESS)
     {
       return (status);
     }

    ADMmessage (msg);
    SCdisplay_msg( msg );
    ERRreset_struct ();
    return (status);
  }
}
    

NFMfunction change_command ()
{
long status;

     _NFMdebug (("NFMfunction", "%s\n", "change_command"));

/*if (status != NFM_S_SUCCESS)
 {
    return(status);
 }*/
    ERRreset_struct ();
    status = NFMget_env ();
    if (status != NFM_S_SUCCESS)
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return (status);
     }

    ADMmessage (msg);
    SCdisplay_msg(msg);
    ERRreset_struct ();
    return (status);
}

NFMfunction load_program ()
{
long   status ;
char   msg[250];
static char *fname = "NFMfunction load_program";

   _NFMdebug (("NFMfunction", "%s\n", "load_program"));
 
  ERRreset_struct ();   
  if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
      return (NFM_E_FAILURE);

  ERRreset_struct ();

  status = ADMload_program () ;
  if (status != NFM_S_SUCCESS);
    {
      ADMmessage (msg);
      ERRreset_struct ();
      return (status);
      }
/*
    if(LOGIN_FLAG==0)
     {
	
      if (status != NFM_S_SUCCESS)
       {
         return (NFM_E_FAILURE);
       }
     }
    else
     {

       _NFMdebug ((fname, "flagging is working\n"));

       ERRload_struct (NFM, NFM_I_MUST_LOGIN, NULL, NULL);
       ERRget_message (msg) ;
       SCdisplay_msg( msg );
       return (NFM_E_FAILURE) ;
     }
*/

  ADMmessage (msg);
  SCdisplay_msg( msg );        
  ERRget_message (msg) ;
  return (status) ;
}

NFMfunction prog_to_trans ()
{
long status ;

_NFMdebug (("NFMfunction", "%s\n", "prog_to_trans"));
  ERRreset_struct ();
  if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
      return (NFM_E_FAILURE);

  ERRreset_struct ();
  status = ADMactivate_workflow ();

  if (status != NFI_S_SUCCESS)
      {
      ADMmessage (msg);
      ERRreset_struct ();
      return (status);
      }

  ERRreset_struct ();

  status = ADMprog_to_trans () ;
  ADMmessage (msg);
  SCdisplay_msg( msg );        
  ERRreset_struct ();
  return (status) ;
}

NFMfunction display_trans_proc ()
{
long status ;

_NFMdebug (("NFMfunction", "%s\n", "display_trans_proc"));

  ERRreset_struct ();
  if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
      return (NFM_E_FAILURE);

  ERRreset_struct ();
  status = ADMactivate_workflow ();

  if (status != NFI_S_SUCCESS)
      {
      ADMmessage (msg);
      ERRreset_struct ();
      return (status);
      }

  status = ADMdisplay_transition_processes();
  ADMmessage (msg);
  SCdisplay_msg( msg );        
  ERRreset_struct ();
  return (status) ;

}

NFMfunction cross_ref()
{ 
	
long  status;

    _NFMdebug (("NFMfunction", "%s\n", "cross_ref"));
 
    ERRreset_struct ();

  if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
      return (NFM_E_FAILURE);

    ERRreset_struct ();
    status = ADMcross_ref ();
    if (status !=NFM_S_SUCCESS)
     {

       ADMmessage (msg);
       ERRreset_struct ();
       return (status);
     }
   
    ADMmessage (msg);
    SCdisplay_msg( msg );
    ERRreset_struct ();
    return (status);
}

/*
NFMfunction start_up()
{
 long status;
 
_NFMdebug (("NFMfunction", "%s\n", "start_up"));

    ERRreset_struct ();
    status = ADMstart_up();
    ADMmessage (msg);
    return (status);
}
*/

NFMfunction repair_uti() 
{
	 long status;
 
_NFMdebug (("NFMfunction", "%s\n", "repair_uti"));
    ERRreset_struct ();    
    if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
       return (NFM_E_FAILURE);

    ERRreset_struct ();
    status = ADMrepair_uti();

    if (status != NFM_S_SUCCESS)
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }

    ADMmessage (msg);
    SCdisplay_msg( msg );
    ERRreset_struct ();
    return(status);
}

NFMfunction server_file() 
{
	 long status;
 
_NFMdebug (("NFMfunction", "%s\n", "server_file"));

     ERRreset_struct (); 
    status = ADMserver();

    if (status != NFM_S_SUCCESS)
     {

       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }

    ADMmessage (msg);
    SCdisplay_msg( msg );
    ERRreset_struct ();
    return(status);
}

NFMfunction slot_file()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "slot_file"));
 
    ERRreset_struct ();
  if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
      return (NFM_E_FAILURE);
  
    ERRreset_struct ();
    status = ADMempty_slot();
    if (status != NFM_S_SUCCESS)
     {

       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }

       ADMmessage (msg);
       SCdisplay_msg(msg);
       ERRreset_struct ();
       return(status);
}

NFMfunction storage_file()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "storage_file"));

    ERRreset_struct ();
    if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
       return (NFM_E_FAILURE);

    ERRreset_struct ();
    status = ADMvalidate_storage();
    if (status != NFM_S_SUCCESS)
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }
  
    ERRreset_struct ();
    SCdisplay_msg (msg);
    ADMmessage (msg);
    return (status);
}

NFMfunction set_access()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "set_access"));

    ERRreset_struct ();
    if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
       return (NFM_E_FAILURE);

    ERRreset_struct ();
    status = ADMset_conf();
    if (status != NFM_S_SUCCESS)
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }
    ADMmessage (msg);  
    SCdisplay_msg (msg);
    ERRreset_struct ();
    return (status);
}

NFMfunction set_lock()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "set_lock"));

    ERRreset_struct ();
    if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
       return (NFM_E_FAILURE);

    ERRreset_struct ();
    status = ADMlock_item_config();
    if (status != NFM_S_SUCCESS)
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }
    ADMmessage (msg);  
    SCdisplay_msg (msg);
    ERRreset_struct ();
    return(status);
}

NFMfunction ser_login_out()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "ser_login_out"));

/*  if (status = ADMcheck_logout_flag()!= NFM_S_SUCCESS)
      return (status);*/
  
    ERRreset_struct ();
    status = server_log();
    if (status != NFM_S_SUCCESS);
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }

    ADMmessage (msg);
    SCdisplay_msg (msg);
    ERRreset_struct ();
    return (status);
}

NFMfunction purge_activity()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "purge_activity"));
    ERRreset_struct ();
    if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
       return (NFM_E_FAILURE);

    ERRreset_struct ();
    status = ADMactivity();
    if (status != NFM_S_SUCCESS)
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }  
    ADMmessage (msg);
    SCdisplay_msg (msg);
    ERRreset_struct ();
    return(status);
}


NFMfunction date_format()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "date_format"));
    ERRreset_struct ();
    if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
       return (NFM_E_FAILURE);

    ERRreset_struct ();
    status = ADMdate_conf();
    if (status != NFM_S_SUCCESS)
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }
    ADMmessage (msg);
    SCdisplay_msg (msg);
    ERRreset_struct ();
    return(status);
}

NFMfunction time_format()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "time_format"));

    ERRreset_struct ();
    if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
       return (NFM_E_FAILURE);

    ERRreset_struct ();
    status = ADMtime_conf();
    if (status != NFM_S_SUCCESS)
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }
    ADMmessage (msg);
    SCdisplay_msg (msg);
    ERRreset_struct ();
    return(status);

}

NFMfunction del_oper()
{
  long status;

  _NFMdebug (("NFMfunctions", "%s\n", "del_oper"));
    ERRreset_struct ();
    if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
       return (NFM_E_FAILURE);

    ERRreset_struct ();

    status = ADMget_env();
    if (status != NFM_S_SUCCESS)
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }

    ADMmessage (msg);
    SCdisplay_msg (msg);
    ERRreset_struct ();
    return (status);
}

NFMfunction import_env()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "import_env"));

/*
  if (status = ADMcheck_logout_flag()!= NFM_S_SUCCESS)
      return (NFM_E_FAILURE);
  */

    ERRreset_struct ();
    status = ADMget_heard_env();
    ADMmessage (msg);
}

NFMfunction export_env()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "export_env"));
/*
  if (status = ADMcheck_logout_flag()!= NFM_S_SUCCESS)
      return (NFM_E_FAILURE);
  */

    ERRreset_struct ();
    status = ADMget_exp_env();
    if (status != NFM_S_SUCCESS);
     {
       
       ADMmessage (msg);
       ERRreset_struct ();
       return (status);
     }

    ADMmessage (msg);
    SCdisplay_msg (msg);
    ERRreset_struct ();
    return (status);

}

NFMfunction ris_clean()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "ris_clean"));

/*
  if (status = ADMcheck_logout_flag()!= NFM_S_SUCCESS)
      return (NFM_E_FAILURE);
  */
    ERRreset_struct ();
    status = ADMris_file();
    
    if (status != NFM_S_SUCCESS)
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }

    ADMmessage (msg);
    SCdisplay_msg (msg);
    ERRreset_struct ();
    return(status);
}

NFMfunction client_file()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "client_file"));

/*
  if (status = ADMcheck_logout_flag()!= NFM_S_SUCCESS)
      return (NFM_E_FAILURE);
  */
    ERRreset_struct ();
    status = ADMclientserver();
    if (status != NFM_S_SUCCESS)
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }
    ADMmessage (msg);
    SCdisplay_msg (msg);
    ERRreset_struct();
    return(status);
}

NFMfunction block_type()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "client_file"));

    ERRreset_struct ();
  if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
      return (NFM_E_FAILURE);
  
    ERRreset_struct ();
    status = ADMblock_conf();
    if (status != NFM_S_SUCCESS)
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }
    ADMmessage (msg);
    SCdisplay_msg (msg);
    ERRreset_struct();
    return(status);
}

NFMfunction nfs_clean()
{
  long status;
  _NFMdebug (("NFMfunctions", "%s\n", "client_file"));

    ERRreset_struct ();
  if (status = ADMcheck_login_flag()!= NFM_S_SUCCESS)
      return (NFM_E_FAILURE);
  
    ERRreset_struct ();
    status = ADMnfs_clean();
    if (status != NFM_S_SUCCESS)
     {
       ADMmessage (msg);
       ERRreset_struct ();
       return(status);
     }
    ERRreset_struct();
    SCdisplay_msg (msg);
    ADMmessage (msg);
    return(status);
}


NFMfunction nfm_adm_begin_record()
{
long status;

  status = ADMbegin_record ();

    ADMmessage (msg);
    ERRreset_struct();
    SCdisplay_msg (msg);

return (status);
}

NFMfunction nfm_adm_end_record ()
{
long status;

    status = ADMend_record ();

    ERRreset_struct();
    SCdisplay_msg (msg);
    ADMmessage (msg);

return (status);
}

NFMfunction nfm_adm_begin_playback ()
{
long status;

    status = ADMbegin_playback ();

    ERRreset_struct();
    SCdisplay_msg (msg);
    ADMmessage (msg);

return (status);
}

NFMfunction debug_on ()
{

/*
_NFMdebug (("NFMfunction", "%s\n", "debug_on"));
NFMmsg_ptr.debug_on = 1;
strcpy (NFMmsg_ptr.debug_file, "/dev/console");
SQLmsg_ptr.debug_on = 1;
strcpy (SQLmsg_ptr.debug_file, "/dev/console");
_NFMdebug_st.NFIdebug_on = 1;
strcpy (_NFMdebug_st.NFIdebug_file, "/dev/console");
_NFMdebug_st.SQLdebug_on = 1;
strcpy (_NFMdebug_st.SQLdebug_file, "/dev/console");
*/

ERRreset_struct ();
ADMdebug_on ();

ADMmessage (msg);
return (NFM_S_SUCCESS);
}

NFMfunction debug_off ()
{

/*
_NFMdebug (("NFMfunction", "%s\n", "debug_off"));
NFMmsg_ptr.debug_on = 0;
strcpy (NFMmsg_ptr.debug_file, "");
SQLmsg_ptr.debug_on = 0;
strcpy (SQLmsg_ptr.debug_file, "");

_NFMdebug_st.NFIdebug_on = 0;
strcpy (_NFMdebug_st.NFIdebug_file, "");
_NFMdebug_st.NFIdebug_on = 0;
strcpy (_NFMdebug_st.NFIdebug_file, "");
_NFMdebug_st.SQLdebug_on = 0;
strcpy (_NFMdebug_st.SQLdebug_file, "");
*/

ERRreset_struct ();
ADMdebug_off ();

ADMmessage (msg);
return (NFM_S_SUCCESS);
}

