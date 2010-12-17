#include <stdio.h>
#include "MEMstruct.h"
#include "PDMnet.h"
#include "PDUerror.h"
#include "NFMerrordef.h"
#include "SQLerrordef.h"
#include "NETerrordef.h"
 
/* "sql.h" renamed "ris.h" in RIS V5. 28/Feb/95 - raj. */
#if defined ( RISV4 )
#include "sql.h"
#elif defined ( RISV5 )
#include "ris.h"
#else
#error "RIS version must be defined"
#endif
 
#include "PDUris_incl.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"
#include "PDUcommand.h"


static long     status;
/* static char	s[1024]; */
extern int      PDMdebug_on;
extern PDMexec_ptr PDMexec;
extern int      PDU_IS_LOGGED_IN;


/*
 * DESCRIPTION:  Verifies if PDM is initialized or not.
 * 
 * PARAMETERS:  NONE
 * 
 * INPUT:	NONE
 * 
 * OUTPUT:      NONE
 * 
 * RETURN CODES: PDM_S_SUCCESS   if PDM is initialized PDM_E_FAILURE   if PDM
 * not initialized
 */

int             PDMverify_init ()
{
   MEMptr          bufr = NULL;
   char            sql_str[512];
   char           *fname = "PDMverify_init";
   _PDMdebug (fname, "ENTER:\n");

   sql_str[0] = '\0';
   sprintf (sql_str, "SELECT n_rowno FROM nfmsyscat WHERE n_infotype = '%s' and  n_description in ('%s', '2.2.0', '2.1.0', '3.0.0')", PDMexec->part_num, PDMexec->revision);

   status = SQLquery (sql_str, &bufr, 512);
   if (status != SQL_S_SUCCESS) {
      MEMclose (&bufr);
      if (status == SQL_I_NO_ROWS_FOUND) {
	 sql_str[0] = '\0';
	 sprintf (sql_str, "%s '%s' %s '%s') or n_description = '2.1.0'",
		  "SELECT n_rowno FROM nfmsyscat WHERE (n_description = ",
		  PDMexec->revision,
		  "AND n_infotype = ",
		  PDMexec->part_num);
	 status = SQLquery (sql_str, &bufr, 512);
	 if (status != SQL_S_SUCCESS) {
	    MEMclose (&bufr);
	    return (PDM_E_FAILURE);
	 }
	 MEMclose (&bufr);
	 PDMdebug ("EXIT:PDMverify_init\n");
	 return (PDM_S_SUCCESS);
      }
      return (PDM_E_FAILURE);
   }

   MEMclose (&bufr);
   PDMdebug ("EXIT:PDMverify_init\n");
   return (PDM_S_SUCCESS);
}

int             PDMterminate ()
{
   char           *fn = "PDMlog_off";
   schema_file_parms parms;
   char		*parms_file_loc;

   _PDMdebug (fn, "ENTER:\n");


   /* Added fix to cleanup only when PDM crashes */
   if (strcmp (PDMexec->dcatalog, "LOGOUT")) {
      status = PDUcleanup_local_filemgr ();
      if (status != PDM_S_SUCCESS)
	 _PDMdebug (fn, 
            "PDUcleanup_local_filemgr() failed status 0x%.8x\n", status);
   }


   if ((parms_file_loc = ((char *)getenv ("RIS_PARAMETERS"))) == 0) {
      _PDMdebug (fn, "RIS_PARAMETERS is not set before NFMlog off\n");
       }
   else {
   _PDMdebug (fn, "parameters file location before nfmlogoff [%s]\n",
                                                    parms_file_loc);
      }

   status = NFMlogoff ();
   if (status != NFM_S_SUCCESS) {
      _PDMdebug (fn, "NFMlogoff failed status  0x%.8x\n", status);
      return (PDM_E_LOGOFF);
   }

   if ((parms_file_loc = ((char *)getenv ("RIS_PARAMETERS"))) == 0) {
      _PDMdebug (fn, "RIS_PARAMETERS is not set after NFMlogoff\n");
       }
   else {
   _PDMdebug (fn, "parameters file location after nfmlogoff [%s]\n",
                                                    parms_file_loc);
      }

   /* Initialize the paramaters variable */

   /* set the environment variable to the parameters file */
/*
   if ((status = (int) putenv ("RIS_PARAMETERS=/usr/tmp/parameters")) != 0) {
      _PDMdebug (fn, "Failed to set the RIS_PARAMETERS to /usr/tmp/parameters <%d>\n", status);
   }
*/

/* Added fix to get the existing schema information. MaC */
/*

   RISget_schema_file_location (&parms);

   _PDMdebug (fn, 
   "parms struct:\n\t%s [%c]\n\t%s [%s]\n\t%s [%s]\n\t%s [%s]\n\t%s [%s]\n",
   "parms.protocol", parms.protocol,
   "parms.address", parms.address,
   "parms.username", parms.username,
   "parms.password", "NOT PRINTED",
   "parms.filename", parms.filename);


   parms.protocol = 'M';
   strcpy (parms.address, "");
   strcpy (parms.username, "");
   strcpy (parms.password, "");
   strcpy (parms.filename, "schemas");


   RISlocate_schema_file (&parms);

   if ((parms_file_loc = ((char *)getenv ("RIS_PARAMETERS"))) == 0) {
      _PDMdebug (fn, "RIS_PARAMETERS is not set\n");
       }
   else {
      _PDMdebug (fn, "parameters file location [%s]\n", parms_file_loc);
      }
*/

   /* ALR  8/5/93  Turn off login flag for api's */
   PDU_IS_LOGGED_IN = 0;
   /*RISterminate ();*/
   _PDMdebug (fn, "EXIT:-SUCCESS\n");
   return (PDM_S_SUCCESS);
}
