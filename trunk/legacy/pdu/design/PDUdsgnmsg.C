#include	<OMlimits.h>
#include	<OMerrordef.h>
#include	<PDUint.h>   
#include	<igrtypedef.h>  
#include	<msmacros.h>
#include	<msdef.h>
#include	<exmacros.h>
#include	<grmessage.h>
#include	<PDUintdef.h>
#include	<PDUint.h>   
#include        <PDUprompt.h>
#include        <PDUuser.h>
#include        <PDMmessage.h>
#include        <UMS.h>
#include        <PDUproto.h>

extern struct PDUrefresh	*refresh; 
extern struct PDUuser           *user;
extern short  PDU_design_form_display;
extern int    PDU_command;
extern char   *PDU_save_filename;
extern int    PDU_apiflag;
extern short  PDU_extadmin;
extern short  PDU_ex_help_init;
extern char   PDU_msg_path[256];


IGRchar	*PDUtranslate_message (msg_key)
  IGRint	msg_key;
  {
  IGRchar	*msg_string = NULL;
  IGRchar	output_string[256];
  IGRint        status = PDM_S_SUCCESS;

  if ( msg_key == 0 )  return ( NULL );

  strcpy(output_string, NULLSTR);

  /* translate and return message string */
  if (!PDU_extadmin)
    {
    ex$message ( buff = output_string, msgnumb = msg_key );
    _pdm_status ("ex$message (translate/return)", msg_key);
    }
  else
    {
    status = PDUtranslate_UMS_message(msg_key, output_string, NULL);
    _pdm_status("PDUtranslate_UMS_message", status);

    if (status == UMS_E_NOTFND)
      _pdm_debug("message not found in message files", 0);
    }

  PDUstrcpy( &msg_string, output_string );
  _pdm_debug("translated message = %s", msg_string);

  return ( msg_string );
  }

IGRint	PDUmsgs_to_attrs (msg_keys, num_attr, attrs)
  IGRint	msg_keys[];
  IGRint	num_attr;
  IGRchar	*attrs[];
  {
  IGRint	status = PDM_S_SUCCESS;
  IGRint	i;

  if ( !msg_keys || !attrs || !num_attr )  return ( PDM_E_FAILURE );

  _pdm_debug("number of messages to translate = %d", (char *)num_attr);

  for ( i = 0; i < num_attr; ++i )
      {
      attrs[i] = PDUtranslate_message( msg_keys[i] );

      if ( strcmp( attrs[i], NULLSTR ) == 0 )
	 {
	 status = PDM_E_MESSAGE;
	 _pdm_debug("unable to translate message key %d in list", (char *)i);
	 }
      }

  return ( status );
  }

IGRint	PDUmsgs_to_cols ( buffer, columns, num_cols )
  MEMptr	buffer;
  IGRint	columns[];
  IGRint	num_cols;
  {
  IGRint	status = PDM_S_SUCCESS;
  IGRint	i, j;
  IGRchar	**attributes = NULL, **buffer_cols = NULL;

  _pdm_debug("In function PDUmsgs_to_cols", 0);

  buffer_cols = (IGRchar **) buffer->column_ptr;

  attributes = (IGRchar **) malloc ( sizeof(IGRchar *) * num_cols );
  for ( i = 0; i < num_cols; ++i )  attributes[i] = NULL;

  status = PDUmsgs_to_attrs( columns, num_cols, attributes );
  _pdm_status ("PDUmsgs_to_attrs", status);
  _pdm_debug_list("attribute list", attributes, num_cols, 1);

  if ( 1&status )
     {
     /* find buffer columns corresponding to each select attribute */
     for ( j = 0; j < num_cols; ++j )
         {
	 columns[j] = PDU_K_MAXINT;		/* set column to constant value */

         for ( i = 0; i < buffer->columns; ++i )
	     {
	     /* compare current column to current select attribute */
	     /* copy current column to columns array at current select attr index */
	     if ( strcmp( attributes[j], buffer_cols[i] ) == 0 )
	        {
	        columns[j] = i;
	        break;
	        }
	     }
	 /* if column number was not found, constant value will persist */
	 if ( columns[j] == PDU_K_MAXINT )
	    {
	    status = PDM_E_MESSAGE;
	    }
	  }
      }     	      

  _pdm_debug("attribute column numbers:", 0);
  if ( PDM_debug_on )
     {
     for ( j = 0; j < num_cols; ++j )
	 printf("column[%d] = %d\n", j, columns[j]);
     }

  PDUfree_list( attributes, num_cols, 1 );
  PDUdealloc( attributes );

  return ( status );
  }

 /*
  * This function displays "Processing ... n% complete".
  */
void PDUpercent_complete(task, percent)
  IGRchar *task;
  IGRint  percent;
  {
   IGRchar  str_msg[80];

   _pdm_debug("In the PDUpercent_complete function", 0);

   sprintf(str_msg, "%s ...   %d%% complete", task, percent);

   /* Display message */
   UI_status(str_msg);
  }

IGRchar	*PDUtranslate_message_and_vars (msg_key, output_var)
  IGRint	msg_key;
  IGRchar       *output_var;
  {
  IGRchar	*msg_string = NULL;
  IGRchar	output_string[256];
  IGRint        status = PDM_S_SUCCESS;

  if ( msg_key == 0 )  return ( NULL );

  strcpy(output_string, NULLSTR);

  /* translate and return message string */
  if (!PDU_extadmin)
    {
    ex$message ( buff = output_string, msgnumb = msg_key, type = "%s", 
                 var = ` output_var ` );
    _pdm_status ("ex$message (translate/return)", msg_key);
    }
  else
    {
    status = PDUtranslate_UMS_message(msg_key, output_string, output_var);
    _pdm_status("PDUtranslate_UMS_message", status);

    if (status == UMS_E_NOTFND)
      _pdm_debug("message not found in message files", 0);
    }
  
  PDUstrcpy( &msg_string, output_string );
  _pdm_debug("translated message = %s", msg_string);

  return ( msg_string );
  }

IGRint PDUinitialize_help()

  {

   IGRint status = PDM_S_SUCCESS;
/*
   IGRchar path[80];
   IGRchar save_path[80];
*/

  _pdm_debug("in PDUinitialze_help", 0);
/*
   status = PDUget_pdu_path(path);
   _pdm_status("PDUget_pdu_path", status);

   _pdm_debug("path = <%s>", path);
   strcpy(save_path, path);

   strcat(path, "config/english/HELPFILE");
   status = PDUverify_file(path);
   _pdm_status("PDUverify_file", status);

   if (status != PDM_S_SUCCESS)
     {
     _pdm_debug("help is not loaded", 0);
     PDUmessage(PDM_I_HELP_NOT_LOADED, 's');
     return(PDM_I_HELP_NOT_LOADED);
     }

  strcpy(path, save_path);
  strcat(path, "config/english/HELPINFO");
  status = PDUverify_file(path);
  _pdm_status("PDUverify_file", status);

  if (status != PDM_S_SUCCESS)
    {
    _pdm_debug("help is not loaded", 0);
    PDUmessage(PDM_I_HELP_NOT_LOADED, 's');
    return(PDM_I_HELP_NOT_LOADED);
    }
*/

  if (!PDU_ex_help_init)
    {
    _pdm_debug("calling ex$help_init", 0);
    status = ex$help_init();
    _pdm_status("ex$help_init", status);
    if ( 1&status )
       {
       PDU_ex_help_init = TRUE;
       status = PDM_S_SUCCESS;
       }
    else
       {
       status = PDM_E_ERROR_INIT_HELP;
       PDUmessage(status, 's');
       }
    }

  _pdm_debug("exiting PDUinitialize_help", 0);

  return(status);
  }

int PDUtranslate_UMS_message(key, string, var)
int  key;
char string[256];
char *var;
{
char  msg_path[256];
int   status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUtranslate_UMS_message", 0);

  msg_path[0] = '\0';
  strcpy (msg_path, PDU_msg_path);
  strcat (msg_path, "/PDUerror.msg");
  status = UMSInitMsg(msg_path, UMS_INDEX);
  _pdm_status("UMSInitMsg", status);

  if (!var)
    status = UMSGetByNum(string, key, 0);
  else
    status = UMSGetByNum(string, key, "%s", var);
  _pdm_status("UMSGetByNum", status);
  _pdm_debug("message string = <%s>", string);

  if (status == UMS_S_SUCCESS)
    return(PDM_S_SUCCESS);

  strcpy (msg_path, PDU_msg_path);
  strcat (msg_path, "/PDMmessage.msg");
  UMSInitMsg(msg_path, UMS_INDEX);

  if (!var)
    status = UMSGetByNum(string, key, 0);
  else
    status = UMSGetByNum(string, key, "%s", var);
  _pdm_status("UMSGetByNum", status);

  if (status == UMS_S_SUCCESS)
    return(PDM_S_SUCCESS);

  strcpy (msg_path, PDU_msg_path);
  strcat (msg_path, "/PDUcommand.msg");
  UMSInitMsg(msg_path, UMS_INDEX);

  if (!var)
    status = UMSGetByNum(string, key, 0);
  else
    status = UMSGetByNum(string, key, "%s", var);
  _pdm_status("UMSGetByNum", status);

  if (status == UMS_S_SUCCESS)
    return(PDM_S_SUCCESS);

  strcpy (msg_path, PDU_msg_path);
  strcat (msg_path, "/PDUprompt.msg");
  UMSInitMsg(msg_path, UMS_INDEX);

  if (!var)
    status = UMSGetByNum(string, key, 0);
  else
    status = UMSGetByNum(string, key, "%s", var);
  _pdm_status("UMSGetByNum", status);

  if (status == UMS_S_SUCCESS)
    return(PDM_S_SUCCESS);

  strcpy (msg_path, PDU_msg_path);
  strcat (msg_path, "/PALmsg.msg");
  UMSInitMsg(msg_path, UMS_INDEX);

  if (!var)
    status = UMSGetByNum(string, key, 0);
  else
    status = UMSGetByNum(string, key, "%s", var);
  _pdm_status("UMSGetByNum", status);

  if (status == UMS_S_SUCCESS)
    return(PDM_S_SUCCESS);

  strcpy (msg_path, PDU_msg_path);
  strcat (msg_path, "/NFMmsg.msg");
  UMSInitMsg(msg_path, UMS_INDEX);

  if (!var)
    status = UMSGetByNum(string, key, 0);
  else
    status = UMSGetByNum(string, key, "%s", var);
  _pdm_status("UMSGetByNum", status);

  if (status == UMS_S_SUCCESS)
    return(PDM_S_SUCCESS);

  strcpy (msg_path, PDU_msg_path);
  strcat (msg_path, "/MEMmsg.msg");
  UMSInitMsg(msg_path, UMS_INDEX);

  if (!var)
    status = UMSGetByNum(string, key, 0);
  else
    status = UMSGetByNum(string, key, "%s", var);
  _pdm_status("UMSGetByNum", status);

  if (status == UMS_S_SUCCESS)
    return(PDM_S_SUCCESS);

  strcpy (msg_path, PDU_msg_path);
  strcat (msg_path, "/NETmsg.msg");
  UMSInitMsg(msg_path, UMS_INDEX);

  if (!var)
    status = UMSGetByNum(string, key, 0);
  else
    status = UMSGetByNum(string, key, "%s", var);
  _pdm_status("UMSGetByNum", status);

  if (status == UMS_S_SUCCESS)
    return(PDM_S_SUCCESS);

  strcpy (msg_path, PDU_msg_path);
  strcat (msg_path, "/ERRmsg.msg");
  UMSInitMsg(msg_path, UMS_INDEX);

  if (!var)
    status = UMSGetByNum(string, key, 0);
  else
    status = UMSGetByNum(string, key, "%s", var);
  _pdm_status("UMSGetByNum", status);

  if (status == UMS_S_SUCCESS)
    return(PDM_S_SUCCESS);

  strcpy (msg_path, PDU_msg_path);
  strcat (msg_path, "/SQLmsg.msg");
  UMSInitMsg(msg_path, UMS_INDEX);

  if (!var)
    status = UMSGetByNum(string, key, 0);
  else
    status = UMSGetByNum(string, key, "%s", var);
  _pdm_status("UMSGetByNum", status);

  if (status == UMS_S_SUCCESS)
    return(PDM_S_SUCCESS);

  return(status);
}
