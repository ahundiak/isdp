#include "machine.h"
/******************************************************************************
*                                                                             *
* FUNCTION: NFMset_wf_state()                                                 *
*                                                                             *
* CREATED:  December 6, 1991                                                  *
*                                                                             *
* AUTHOR:   Dudley Thomas                                                     *
*                                                                             *
* VERSION:  3.0	                                                              *
*                                                                             *
* DESCRIPTION: This function was created for I/NFM version 3.0 to be used in  *
*              support of the process on transition capability and the        *
*              the combined client/server option.  The input arguments        *
*              contain the current error number and error message, as well    *
*              as the application name.  This is different from the           *
*              previous method (see WFto_state.c) in that the error no and    *
*              message will reflect the latest message, client or server.     *
*              Before, there was no way of maintaining the context sensitive  *
*              data from the client to the server.                            *
*              Also, this routine no longer resets the workflow structure.    *
*                                                                             *
* MODIFIED: Glenn Scott 6/4/92                                                *
*           Changed for 3.2 to check the message type (S, I, W, E) to         *
*           determine whether or not transition processing should occur.      *
*           All types except 'E' will cause transition processing to occur    *
*           with the sole exception of the NFI_W_COMMAND_CANCELLED status.    *
*           All entity types except the "Don't Check" type (D) will cause     *
*           activity logging and email to be sent.  Again, the sole exception *
*           to this is if the user cancelled the command (error_no =          *
*           NFI_W_COMMAND_CANCELLED).                                         *
*           These changes were made to accommodate developers loading warning *
*           messages and returning non- 'S' types of statuses.                *
*                                                                             *
******************************************************************************/
#include "WF.h"
#include "NFIerrordef.h"
#include "NFFdef.h"
#include "UMS.h"

 extern struct NFMglobal_st NFMglobal;
 extern struct WFstruct WFinfo;

 long NFMset_wf_state (app_name, error_no, error_msg)
   char      *app_name;
   long      error_no;
   char      *error_msg;
   {      
     auto    long   status;
     auto    long   proc_status;
     auto    char   type[4];
     auto    char   n_type [4] ;
     auto    MSGptr app_ptr;
     int     error_subsystem ;
     long    d_error ;
     char    message [NFF_MAX_MESSAGE+1] ;
     static  char   *fname = "NFMset_wf_state" ;

     _NFMdebug ((fname, "app_name = <%s>\n", app_name));
     _NFMdebug ((fname, "error_no = <0x%.8x>\n", error_no));
     _NFMdebug ((fname, "error_msg = <%s>\n", error_msg));
   
     NFMprint_wfinfo () ;

     n_type [0] = 0 ;
     UMSMsgCode (n_type, error_no,
		 UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
		 NULL, NULL, NULL) ;


     /* Construct MSGptr from input error number and message. */

     app_ptr.error_no = error_no;
     strncpy (app_ptr.error_msg, error_msg, (sizeof(app_ptr.error_msg) - 1));

     /* NULL terminator added to avoid occassional SEGV - SSRS 28 Feb 94 */
     app_ptr.error_msg[sizeof(app_ptr.error_msg) - 1] = '\0';

     _NFMdebug ((fname, "USE LATER FOR RESTORING MESSAGE storing the message no <0x%.8x> : message <%s> : with type <%s>\n",
		 error_no, error_msg, n_type)) ;

     /* Execute Process on Transition */

     proc_status = NFM_S_SUCCESS;

     if (WFinfo.transition > 0)
     {
        proc_status = NFMpost_execute_process (WFinfo.transition, app_ptr);
        _NFMdebug ((fname,"NFMpost_execute_process = <0x%.8x>\n",proc_status));
     }

     /* if a new error has been loaded reload original */
     ERRget_number (&d_error, &error_subsystem) ;
     if (d_error != error_no)
       {
	 /* reload previous error */
	 _NFMdebug ((fname, "Reloading error <0x%.8x> : message <%s> : type <%s>\n", 
		     error_no, error_msg, n_type)) ;
	 if (strcmp (n_type, "E") == 0)
	   ERRload_struct (NFM, NFM_E_MESSAGE, "%s", error_msg) ;
	 else if (strcmp (n_type, "W") == 0)
	   ERRload_struct (NFM, NFM_W_MESSAGE, "%s", error_msg) ;
	 else if (strcmp (n_type, "I") == 0)
	   ERRload_struct (NFM, NFM_I_MESSAGE, "%s", error_msg) ;
       }

     /* Set transaction autocommit OFF */

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMstop_transaction = <0x%.8x>\n", status));
        return (status);
      }

     /* Update state  */

    /*  Find out what type of status it is - Glenn 6/4/92  */

    if ((status = UMSMsgCode (type, error_no,
        UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
        NULL, NULL, NULL)) != UMS_S_SUCCESS)
      {
        _NFMdebug ((fname, "UMSMsgCode = <0x%.8x>\n", status));
        _NFMdebug ((fname, "Unable to find out message type.\n"));

        if (error_no == NFM_S_SUCCESS)
          {
            _NFMdebug ((fname, "Defaulting type to 'S'\n"));
            strcpy (type, "S");
          }
        else
          {
            _NFMdebug ((fname, "Defaulting type to 'E'\n"));
            strcpy (type, "E");
          }
      }

    _NFMdebug ((fname, "message type = <%s>\n", type));

    /*  Any type other than 'E' should cause a transition.
        This means 'S', 'I', and 'W'.  The only exception
        is NFI_W_COMMAND_CANCELLED which will NOT cause a
        transition or activity logging or email. - Glenn 6/4/92  */

    if (((strcmp (type, "E")) != 0) && (error_no != NFI_W_COMMAND_CANCELLED))
      {
        if (WFinfo.entity[0] == 'S')
          {
            status = WFenter_sdp_trans (NFMglobal.NFMuserid);
            if (status != NFM_S_SUCCESS)
              {  
                NFMrollback_transaction (0);
                _NFMdebug ((fname, "WFenter_sdp_trans = <0x%.8x>\n", status));
                return (status);           
              }
          }
        else if (WFinfo.entity[0] == 'A')
          {
            status = WFenter_admin_trans (NFMglobal.NFMuserid);
            if (status != NFM_S_SUCCESS)
              {
                NFMrollback_transaction (0);
                _NFMdebug ((fname,
                    "WFenter_admin_trans = <0x%.8x>\n", status));
                return (status);
              }
          }
        else if (WFinfo.entity[0] == 'C')
          {
            status = WFenter_catalog_trans (NFMglobal.NFMuserid);
            if (status != NFM_S_SUCCESS)
              {
                NFMrollback_transaction (0);
                _NFMdebug ((fname,
                    "WFenter_catalog_trans = <0x%.8x>\n", status));
                return (status);
              }
          }
        else if (WFinfo.entity[0] == 'P')
          {
            status = WFenter_project_trans (NFMglobal.NFMuserid);
            if (status != NFM_S_SUCCESS)
              {
                NFMrollback_transaction (0);
                _NFMdebug ((fname,
                    "WFenter_project_trans = <0x%.8x>\n", status));
                return (status);
              }
          }
        else if (WFinfo.entity[0] == 'I')
          {
            status = WFenter_item_trans (NFMglobal.NFMuserid);
            if (status != NFM_S_SUCCESS)
              {
                NFMrollback_transaction (0);
                _NFMdebug ((fname, "WFenter_item_trans = <0x%.8x>\n", status));
                return (status);
              }
          }
        else if (WFinfo.entity[0] == 'N')
          {
            _NFMdebug ((fname, "No entity\n")) ;
          }
        else if (WFinfo.entity[0] == 'D')
          {
            _NFMdebug ((fname, "No check validation\n"));
          }
        else
          {
            _NFMdebug ((fname, "Bad entity <%s>\n", WFinfo.entity)) ;
            NFMrollback_transaction (0) ;
            ERRload_struct (NFM, NFM_E_INVALID_ENTITY, "", "") ;
            return (NFM_E_INVALID_ENTITY) ;
          }
      }

    /*  Only log activities and send email if it's NOT a "Don't Check"
        entity type or if the user didn't cancel the command - Glenn 6/4/92  */

    if ((WFinfo.entity[0] != 'D') && (error_no != NFI_W_COMMAND_CANCELLED))
      {
        status = WFtransition_log (NFMglobal.NFMuserid, app_name, app_ptr);
        if (WFinfo.notify[0] == 'Y')
         {
           status = WFtransition_mail (NFMglobal.NFMuserid, app_name, app_ptr);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "WFtransition_log = <0x%.8x>\n", status));
              return (status);
            }
         }
      }

     if (proc_status == NFM_S_SUCCESS)
        NFMreset_message_struct (NFMglobal.NFMuserid);

/*******************************************************************************

Do not reset the workflow structure!

     _WFinit_info () ;

******************************************************************************/

     /* Commit work. Turn transaction autocommit ON. */

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
        status));
        return (status);
      }

     if (proc_status != NFM_S_SUCCESS)
     {
        _NFMdebug((fname,"PROCESS STATUS : status = <0x%.8x>\n", proc_status));
        return (proc_status);
     }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }
