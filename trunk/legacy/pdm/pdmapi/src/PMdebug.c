#include <stdio.h>
#include "PDUerror.h"
#include "DEBUG.h"
#include "PDMproto.h"
#include "PDUproto.h"

extern char PDU_DEBUG_FILE[];
extern char PDM_DEBUG_FILE[];

extern int PDMdebug_on;
extern int PDM_debug_on;

#define DELIM "/"

/****************************************************************************

Name
   pdmoDebugOn

Abstract
   Turns the debug option of PDU,PDM,and NFM subsystems to "ON".

Synopsis
  int pdmoDebugOn (iar_toggles[8], car_paths[8] )


Description
   The global variables are PDM_debug_on, and PDMdebug_on to "OFF".
   The path variables are PDU_DEBUG_FILE, and PDM_DEBUG_FILE.
    NFM variables of toggle and files for set.

   Algorithm:

    If both the inputs are null, then turn the debug flags
    as it is done in the user interface.

   1. If     toggles [0] =   1;    PDU deb on 
       Sets the global variables PDM_debug_on for PDU debug
        Checks the entry in files[0]
        if valid, copies the path to PDU_DEBUG_FILE variable, proceeds further
           else defaults to /usr/tmp/pdu.dbg
       else
        proceed further
   2. If     toggles [1] =   1;    PDM deb on 
       Sets the global variables PDMdebug_on for PDM sub sytem debug
         Checks the entry in files[1]
        if valid, copies the path to PDM_DEBUG_FILE variable, proceeds further
           else defaults to /usr/tmp/pdm.dbg
       else
        proceed further
   3. If     toggles [2] =   1;    NFM deb on 
       Sets the variable NFMtoggle[8] =1 for NFM subsystem debug
         Checks the entry in files[2]
        if valid, copies the path to NFMfiles[8] variable, proceeds further
           else defaults to /usr/tmp/nfm.dbg
       else
        proceed further
   4. If     toggles [3] =   1;    SQL deb on 
       Sets the variable NFMtoggle[9] =1 for SQL sub system debug
         Checks the entry in files[3]
        if valid, copies the path to NFMfiles[9] variable, proceeds further
           else defaults to /usr/tmp/sql.dbg
       else
        proceed further
   5. If     toggles [4] =   1;    MEMS deb on 
       Sets the variable NFMtoggle[11] =1 for MEM subsytem debug
         Checks the entry in files[4]
        if valid, copies the path to NFMfiles[11] variable, proceeds further
           else defaults to /usr/tmp/mems.dbg
       else
        proceed further
   8. If     toggles [5] =   1;    ERRS deb on 
       Sets the variable NFMtoggle[14] =1 for Error sub sytem debug
         Checks the entry in files[5]
        if valid, copies the path to NFMfiles[14] variable, proceeds further
           else defaults to /usr/tmp/errs.dbg
       else
        proceed further
   9. If     toggles [6] =   1;    NETclient deb on 
       Sets the variable NFMtoggle[6] =1 for Error sub sytem debug
         Checks the entry in files[6]
        if valid, copies the path to NFMfiles[6] variable, proceeds further
           else defaults to /usr/tmp/netc.dbg
       else
        proceed further
   9. If     toggles [7] =   1;    NETserver deb on 
       Sets the variable NFMtoggle[3] =1 for Error sub sytem debug
         Checks the entry in files[7]
        if valid, copies the path to NFMfiles[3] variable, proceeds further
           else defaults to /usr/tmp/nets.dbg
       else
        proceed further
         
then call NFMall_debug() function ; 
return success;

Input:
        toggles [0] =   1 or 0;    PDU deb on or debug off
        toggles [1] =   1 or 0;    PDM deb on or debug off
        toggles [2] =   1 or 0;    NFM deb on or debug off
        toggles [3] =   1 or 0;    SQL deb on or debug off
        toggles [4] =  1  or 0;     MEMS deb on or debug off
        toggles [5] =  1  or 0;     ERRS deb on or debug off
        toggles [6] =   1 or 0;    NET-CLIENT deb on or debug off
        toggles [7] =   1 or 0;    NET-SERVER deb on or debug off

   The path variables for NFM are

        files [0] =   "/usr2/tmp/pdu.dbg"; PDU debug file
        files [1] =   "/usr2/tmp/pdm.dbg";  PDM debug file
        files [2] =   "/usr2/tmp/nfm.dbg"; NFM debug file
        files [3] =   "/usr2/tmp/sql.dbg";  SQL debug file
        files [4] =   "/usr2/tmp/mem.dbg";  MEM debug file
        files [5] =   "/usr2/tmp/err.dbg";  ERRS debug file
        files [6] =   "/usr2/tmp/netc.dbg";  NETC debug file
        files [7] =   "/usr2/tmp/nets.dbg";  NETS debug file
   
   Input/Output:

   Output:
    Nothing.


Return Values
PDM_S_SUCCESS
PDM_E_OPEN_FILE
PDM_E_FAILURE 

Notes

Index
DEBUG

Keywords
DEBUG

History
   Kumar Narayanan Fri Jul 16 13:43:00 CDT 1993: Initial Creation
****************************************************************************/


/****************************************************************************
Include Files
#include <DEBUG.h>
****************************************************************************/

/****************************************************************************
Main Function
****************************************************************************/


int pdmoDebugOn (int *apitog, char **apifiles )

{

        int i = 0, toggles[NFM_DEBUG_SUBSYSTEMS];
        char files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];


          PDM_DEBUG_FILE[0] = '\0';
          PDU_DEBUG_FILE[0] = '\0';
          files[8][0] = '\0';
          files[11][0] = '\0';
          files[6][0] = '\0';
          files[9][0] = '\0';
          files[14][0] = '\0';
          files[3][0] = '\0';;

         /* setting the defaults, if the input parameters are null */ 
         /* this design issue was brought by mychelle for better usagebility */

         if(apitog == NULL)
         {
          apitog = (int *) malloc (sizeof (int) * 9);
          apitog[0] = 1;    /*PDU deb */
          apitog[1] = 1;    /*PDM deb */
          apitog[2] = 1;    /*NFM deb  */
          apitog[3] = 1;    /*SQL deb  */
          apitog[7] = 1;    /*NET deb   */
         }

         if(apifiles == NULL)
         {
          apifiles  = (char **) malloc (sizeof (char *) * 9);
           for(i=0; i < 9; i++ )
            {
             apifiles[i] = (char *) malloc (sizeof (char) * 2);
             apifiles[i][0] = '\0';
            }
         }


        PDM_debug_on = apitog[0];
        PDMdebug_on  = apitog[1];

        if(!strcmp(apifiles[1],""))
        sprintf (PDM_DEBUG_FILE, "%s%s%s",  "/usr/tmp", DELIM, "pdm.dbg");
        else
        strcpy (PDM_DEBUG_FILE, apifiles[1]);

        if(!strcmp(apifiles[0],""))
        sprintf (PDU_DEBUG_FILE, "%s%s%s",  "/usr/tmp", DELIM, "pdu.dbg");
        else
        strcpy (PDM_DEBUG_FILE, apifiles[0]);

        toggles [6] = apitog[6];    /*NET deb  */
        toggles [8] = apitog[2];    /*NFM deb  */
        toggles [9] = apitog[3];    /*SQL deb  */
        toggles [11] = apitog[4];   /*MEMS deb  */
        toggles [14] = apitog[5];   /*ERRS deb  */
        toggles [3] = apitog[7];    /*NET deb   */


        if(!strcmp(apifiles[2],""))
        sprintf (files[8], "%s%s%s",  "/usr/tmp", DELIM, "nfm.dbg");
        else
        strcpy (files[8], apifiles[2]);
        if(!strcmp(apifiles[4],""))
        sprintf (files[11], "%s%s%s",  "/usr/tmp", DELIM, "mem.dbg");
        else
        strcpy (files[11], apifiles[4]);
        if(!strcmp(apifiles[6],""))
        sprintf (files[6], "%s%s%s",  "/usr/tmp", DELIM, "netc.dbg");
        else
        strcpy (files[6], apifiles[6]);
        if(!strcmp(apifiles[3],""))
        sprintf (files[9], "%s%s%s",  "/usr/tmp", DELIM, "sql.dbg");
        else
        strcpy (files[9], apifiles[3]);
        if(!strcmp(apifiles[5],""))
        sprintf (files[14], "%s%s%s",  "/usr/tmp", DELIM, "err.dbg");
        else
        strcpy (files[14], apifiles[5]);
        if(!strcmp(apifiles[7],""))
        sprintf (files[3], "%s%s%s",  "/usr/tmp", DELIM, "net.dbg");
        else
        strcpy (files[3], apifiles[7]);

         NFMall_debug (toggles, files);

        return (PDM_S_SUCCESS);
}



/****************************************************************************

Name
   pdmoDebugOff

Abstract
   Turns the debug option "OFF" of PDU,PDM,and NFM subsystems.

Synopsis
  int pdmoDebugOff ()


Description
   The global variables are PDM_debug_on, and PDMdebug_on to "OFF".
   The path variables are PDU_DEBUG_FILE, and PDM_DEBUG_FILE to "OFF".
    NFM variables of toggle and files for set.

   Algorithm:
       1. Sets the global variables PDM_debug_on for PDU debug to zero.
          Nullifies the path of PDU_DEBUG_FILE variable, proceeds further
       2. Sets the global variables PDMdebug_on for PDM debug to zero.
          Nullifies the path of PDM_DEBUG_FILE variable, proceeds further
       3. Sets the variable NFMtoggle[8] =0 for NFM subsystem debug.
          Nullifies the path to NFMfiles[8] variable, proceeds further
       4. Sets the variable NFMtoggle[9] =0 for SQL sub system debug
          Nullifies the path to NFMfiles[9] variable, proceeds further
       5. Sets the variable NFMtoggle[11] =0 for MEM subsytem debug
          Nullifies  the path to NFMfiles[11] variable, proceeds further
       6. Sets the variable NFMtoggle[14] =0 for Error sub sytem debug
          Nullifies the path to NFMfiles[14] variable, proceeds further
       7. Sets the variable NFMtoggle[6] =0 for Error sub sytem debug
          Nullifies the path to NFMfiles[6] variable, proceeds further
       8. Sets the variable NFMtoggle[3] =0 for Error sub sytem debug
          Nullifies the path to NFMfiles[3] variable, proceeds further
         
then call NFMall_debug() function ; 
return success;

Input:
Nothing

   Input/Output:
    Nothing

   Output:
    Nothing.


Return Values
PDM_S_SUCCESS
PDM_E_FAILURE 

Notes

Index
DEBUG

Keywords
DEBUG

History
   Kumar Narayanan Fri Jul 16 13:43:00 CDT 1993: Initial Creation
****************************************************************************/


/****************************************************************************
Include Files
#include <DEBUG.h>
****************************************************************************/

/****************************************************************************
Main Function
****************************************************************************/


int pdmoDebugOff ( )

{

        int toggles[NFM_DEBUG_SUBSYSTEMS];
        char files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];

          PDM_DEBUG_FILE[0] = '\0';
          PDU_DEBUG_FILE[0] = '\0';
          files[8][0] = '\0';
          files[11][0] = '\0';
          files[6][0] = '\0';
          files[9][0] = '\0';
          files[14][0] = '\0';
          files[3][0] = '\0';
       

        PDM_debug_on = 0;
        PDMdebug_on  = 0;

        toggles [0] = 0;
        toggles [1] = 0;
        toggles [2] = 0;
        toggles [3] = 0;    /*NET deb   */
        toggles [4] = 0;
        toggles [5] = 0;
        toggles [10] = 0;
        toggles [6] = 0;    /*NET deb  */
        toggles [7] = 0;    /*NET deb  */
        toggles [8] = 0;    /*NFM deb  */
        toggles [12] = 0;    /*NFM deb  */
        toggles [13] = 0;    /*NFM deb  */
        toggles [9] = 0;    /*SQL deb  */
        toggles [11] = 0;   /*MEMS deb  */
        toggles [14] = 0;   /*ERRS deb  */


         NFMall_debug (toggles, files);

        return (PDM_S_SUCCESS);
}
