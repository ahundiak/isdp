/****************************************************************************

Name
   pdmoLogout

Abstract

Synopsis
  int pdmoLogout ( )

Description
   Input:

   Input/Output:

   Output:

   Algorithm:
   1)

Return Values

Notes

Index

Keywords

History
   Audra Romans Fri Jul  9 11:27:32 CDT 1993: Initial Creation
****************************************************************************/

#include <stdio.h>
#include <PDUstorage.h>
#include <PDUuser.h>
#include <PDUerror.h>
#include <PDUproto.h>
#include <PDMproto.h>

/* Externs */
extern int PDU_apiflag;
extern char *PDU_apimessage;

int pdmoLogout ( )

{
  long status;

  PDUload_exec_structure("","","","","LOGOUT","","",0,0);
  status = PDMterminate();
  if (status != PDM_S_SUCCESS)
   return(status);
  else
   {
     PDUuser_clear();
     PDUstorage_clear();
     PDU_apiflag = 0;
     if (PDU_apimessage)
       free(PDU_apimessage);

     PDU_apimessage = NULL;
     return(PDM_S_SUCCESS); 
   }
}
