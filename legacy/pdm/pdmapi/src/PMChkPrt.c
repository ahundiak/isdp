#include                <stdio.h>
#include                "SQLerrordef.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "MEMstruct.h"
#include                "NFMstruct.h"
#include                "PDMdbs_err.h"
#include                "PDUerror.h"
#include                "PDMproto.h"

extern int                      PDMdebug_on;
extern char                     PDM_DEBUG_FILE[];
extern PDMexec_ptr              PDMexec;
extern PDMpart_ptr              PDMpart;


/*


API description for Checking Part Existence


Author: Arun Madhwesh
Date  : 072693
Ver   : 1.00


Abstract:
This function checks to see whether given part exists in the
given catalog with given revision.

Function Protocol:
pdmoCheckPartExistence ( char *cpr_Catalog,  
                       char *cpr_Partnum,  
                       char *cpr_Revision);  


Input:

 char *cpr_catalog   :   Name of the catalog containing the part.
                         Required.
                         char
  
 char *cpr_partnum   :   Name of the part whose existance needs
                           to be checked.
                         Required.
                         char

 char *cpr_revision  :   Revision of the part whose existance needs
                           to be checked.
                         Required.
                         char

Output:

 int  *ipw_status    : Status returned by the function.
                           pointer to int


Return Statii:

PDM_S_SUCCESS
PDM_E_PART_NOT_FOUND
PDM_E_CATALOG_NOT_FOUND
PDM_E_NO_SUCH_TABLE
PDM_E_NO_SUCH_ATTRIBUTE
PDM_E_REQ_COLUMN_NOT_FOUND
SQL errors

Algorithm:

1. Validate the required inputs
     All the required inputs are checked for NULL values
     if (NULL) return error

2. Verify whether user is logged in

3. Call PDMverify_part (cpr_catalog, cpr_partnum, cpr_revision)

4. If the status is successful,
    return PDM_S_SUCCESS.
   else
    return error


Dependencies:

   Assumptions:
     Catalog exists in the database.

   Impact:
     None

*/


int pdmoCheckPartExistence ( char *cpr_Catalog,  
                       char *cpr_Partnum,  
                       char *cpr_Revision)  
{
 char		*fn = "pdmoCheckPartExistence";
 long		status = 0;
 

  _PDMdebug (fn, "ENTER\n");

 /* Validating required inputs */

  if ( (!strlen (cpr_Catalog)) || (!strlen (cpr_Partnum)) || 
                                             (!strlen (cpr_Revision))) {
     _PDMdebug (fn, "Required parameters are not input\n");
     return (PDM_E_PART_NOT_FOUND);
      }

  /* Verify whether the user is logged in */

    if (!pdmcheck_log_in()) {
      _PDMdebug (fn, "User is not logged in\n");
      return (PDM_E_USER_NOT_LOGGED_IN);
      }

  status =  PDMverify_part (cpr_Catalog,
                               cpr_Partnum,
                                  cpr_Revision );
  if (status != PDM_S_SUCCESS) {
    _PDMdebug (fn, "PDMverify Part Failed : 0x%.8x \n", status);
    return (status);
    }
   

  _PDMdebug (fn, "EXIT\n");
  return (PDM_S_SUCCESS);
 
}
