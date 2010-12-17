#include "machine.h"
#include <string.h>
#include "WF.h"

extern struct WFstruct WFinfo;
extern struct NFMglobal_st NFMglobal ;

/**************************************************************************
 *                                                                        *
 *      Function: _WFget_error_info                                       *
 *      Date:     February 1, 1990                                        *
 *                                                                        *
 *      This function used to be NFMtranslate_wf_struct                   *
 *      changed = 01/22/92 mms - successfail, failreason                  *
 *      This is an internal function only.                                *
 **************************************************************************/

long _WFget_error_info  (successfail, failreason, app_msg)
  char   *successfail;
  char   *failreason;
  MSGptr app_msg;
{
  static char *fname = "_WFget_error_info" ;
  long error_no ;

  _NFMdebug ((fname, "ENTER\n")) ;

  if (app_msg.error_no == NFM_S_SUCCESS)
  {
     sprintf (failreason, "%s", "");
     strcpy (successfail, "0");
  }
  else
  {
     /* add in the succession stuff. */
     switch (app_msg.error_no)
     {
         case NFM_E_FAILURE:
             ERRget_specific_number (NFM, &error_no) ;
             switch (error_no)
             {
                case NFM_E_NET:
                    if (app_msg.error_no == NET_E_MEM)
		      ERRget_specific_message (MEM, failreason) ;
                    else
                       sprintf (failreason, "%s", app_msg.error_msg);
                break;

                case NFM_E_SQL_STMT:
                case NFM_E_SQL_QUERY:
		    ERRget_specific_number (SQL, &error_no) ;
                    if (error_no == SQL_E_MEM)
		      ERRget_specific_message (MEM, failreason) ;
                    else
		      ERRget_specific_message (SQL, failreason) ;
                break;

                case NFM_E_MEM:
		      ERRget_specific_message (MEM, failreason) ;
                break;
              
                default:
                    sprintf (failreason, "%s", app_msg.error_msg);
                break;
             }
         break;

         case NFM_E_NET:
             if (app_msg.error_no == NET_E_MEM)
	       ERRget_specific_message (MEM, failreason) ;
             else
	       sprintf (failreason, "%s", app_msg.error_msg);
         break;

         case NFM_E_SQL_STMT:
         case NFM_E_SQL_QUERY:
             ERRget_specific_number (SQL, &error_no) ;
             if (error_no == SQL_E_MEM)
	       ERRget_specific_message (MEM, failreason) ;
             else
	       ERRget_specific_message (SQL, failreason) ;
         break;

         case NFM_E_MEM:
	     ERRget_specific_message (MEM, failreason) ;
         break;

         default:  /* application error. */
             sprintf (failreason, "%s", app_msg.error_msg);
         break;
     }
     strcpy (successfail, "-1");
  }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS); 
}



