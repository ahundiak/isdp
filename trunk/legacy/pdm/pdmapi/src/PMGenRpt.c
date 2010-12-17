#include                <stdio.h>
#include                "SQLerrordef.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "NFMapi.h"
#include                "NFMschema.h"
#include                "MEMstruct.h"
#include                "NFMstruct.h"
#include                "PDMdbs_err.h"
#include                "PDUerror.h"
#include                "dbadev.h"
#include                "rMRPstr.h"
#include                "MRPmessage.h"
#include                "PDMproto.h"
#include                        "PDMbom_strct.h"

extern int                      PDMdebug_on;
extern char                     PDM_DEBUG_FILE[];
extern int                      PDMalt_bom_on;
extern char                     PDM_ALT_PARENT_ATTR[];



/* 
API description for creating Report for an Assembly


Author: Arun Madhwesh
Date  : 080293
Ver   : 1.01


Abstract:
This function creates exploded summary bom report.

Function Protocol:
pdmoReportAssembly ( char *cpr_Catalog,  
                     char *cpr_Partnum,  
                     char *cpr_Revision,  
                     char *cpr_SaName,  
                     int  ir_MaxLevel,  
                     char *cpr_FileName,  
                     char *cpr_TemplName,
                     char *cpr_RisTmplName,
                     char *cpw_ReportFileName)


Input:
 char *cpr_catalog        :   Name of the catalog containing the part.
                              Required.
                              char
  
 char *cpr_partnum        :   Name of the part for which the report is 
                                to be generated.
                              Required.
                              char

 char *cpr_revision       :   Revision of the part for which the report
                                 is to be generated
                              Required.
                              char

 char *cpr_SaName         :   Storage areaname containing RIS template file.
                              Optional (Required if cpr_templ_name = NULL)
                              char

 int  ir_MaxLevel         :   Max level to be exploded for the part
                              Optional 
                              integer
        
        
 char *cpr_FileName        :  Filename of file containing RIS templates.
                              Optional (Required if cpr_templ_name = NULL)
                              =< char[14]
       

 char *cpr_TemplName       :  Report format name
                              Optional (Required if prev two inputs are NULL)
                              =< char[14]

 char *cpr_RisTmplName     :  Ris template name in the library file
                              Optional (Required if FileName and TemplName are
                              not NULL)
                              =< char[14]

 char *cpw_ReportFileName  : Filename to which the report has been
                                   saved (User defined).
                             Optional
                              =< char[14]
                          

Output:
 char *cpw_ReportFileName  : Filename to which the report has been
                                   saved (sys generated).
                               pointer to char


Return Statii:

PDM_S_SUCCESS
PDM_E_DROP_BOM_TABLE
PDM_E_CATALOG_NOT_FOUND
PDM_I_ATOMIC_PART
PDM_E_PART_NOT_ASSEMBLY
PDM_E_PART_NOT_FOUND
PDM_E_EXPLODE_NOT_SET
PDM_I_NO_ROWS_FOUND
PDM_E_GEN_BOM_TABLE_NAME
PDM_E_QUERY_SET_MEMBERS
PDM_E_QUERY_TEMPLATE_DEF
PDM_E_REQ_COLUMN_NOT_FOUND
PDM_E_BOMREQATTR_NOT_FOUND
PDM_E_ADDTO_RPS_TAB
PDM_E_COULD_NOT_MALLOC
PDM_E_BUFFER_FORMAT
PDM_E_BUILD_ARRAY
PDM_E_BUILD_BUFFER_ARRAY
PDM_E_COPY_BUFFER
PDM_E_OPEN_BUFFER
PDM_E_SQL_QUERY
PDM_E_SQL_STMT
PDM_E_WRITE_BUFFER
PDM_E_WRITE_COLUMN
PDM_E_WRITE_FORMAT
PDM_E_WRITE_ROW
SQL errors

Algorithm:

1. Validate the required inputs
     All the required inputs are checked for NULL values
     if (NULL) return error

2. Verify whether user is logged in

3. Verify the inputs
     Catalog exists?
        No: return error
     Partnum and revision exists?
        No: return error

4. Load the inputs into PDMexec struct

5. Call PDMvalidate_user_access

6. Load catalog, partnum, revision, templatename,
     saname, filename, max_level into PDMexec structure

7. Call PDMgenerate_review_bom and pass a null MEMptr

8. If the status is successful,
    Allocate memory for the cppr_report_filename
    extract the filename from the single column buffer
    and load it into cppr_report_filename
    return Success.
  If the status is not successful,
     return error


Dependencies:

   Assumptions:
     Catalog, partnum, rev and template exists in the database.
     Part is an assembly.

   Impact:
     An entry is made in pdmtables table for this part.
     The BOM table does not exist; it is created and
     an entry made into pdmboms table.


Test Cases:

This report should work on all the following types of assemblies.

 1. Assemblies containing multiple levels of regular parts
 2. Assemblies containing multiple levels of parametric parts
 3. Assemblies containing multiple levels of view parts
 4. Assemblies containing multiple levels of both parametric & regular parts
 5. Assemblies containing multiple levels of parametric, view & regular parts
*/

pdmoReportAssembly ( long user_id,
                     char *cpr_Catalog,  
                     char *cpr_Partnum,  
                     char *cpr_Revision,  
                     char *cpr_SaName,  
                     int  ir_MaxLevel,  
                     char *cpr_FileName,  
                     char *cpr_TemplName,
                     char *cpr_RisTmplName,
                     char *cpw_ReportFileName)
{
 char		*fn = "pdmoReportAssembly";
 MEMptr		xpw_ReturnBuffer = NULL;
 char		**data = NULL;
 char		project[50], workflow[50];
 long                     status = 0;
 


 /* Validating required inputs */

  if ( (!strlen (cpr_Catalog)) || (!strlen (cpr_Partnum)) || 
                                             (!strlen (cpr_Revision))) {
     _PDMdebug (fn, "Required parameters are not input\n");
     return (PDM_E_PART_NOT_FOUND);
      }

  if ((strlen (cpr_TemplName)) && (!strlen (cpr_SaName)) ) {
     _PDMdebug (fn, "Required parameters are not input\n");
     return (PDM_E_PART_NOT_FOUND);
      }

  if ((!strlen (cpr_TemplName)) && (!strlen (cpr_SaName)) &&
      (!strlen (cpr_FileName)) ) {
     _PDMdebug (fn, "Required parameters are not input\n");
     return (PDM_E_PART_NOT_FOUND);
      }

  if ((!strlen (cpr_RisTmplName)) && (!strlen (cpr_TemplName)) &&
      (!strlen (cpr_FileName)) ) {
     _PDMdebug (fn, "Required parameters are not input\n");
     return (PDM_E_PART_NOT_FOUND);
      }
  
  /* Verify whether the user is logged in */

    if (!pdmcheck_log_in()) {
      _PDMdebug (fn, "User is not logged in\n");
      return (PDM_E_USER_NOT_LOGGED_IN);
      }

  /* Validate User Access */

     status = PDMvalidate_user_access("PDMCreate BOM for Review Part", "",
           cpr_Catalog, "", cpr_Partnum, cpr_Revision );
     if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "Validate User Access Failed : 0x%.8x \n", status);
       return(status);
      }


/*......
  status =  PDMsvalidate_user_access_cl (user_id,
                         "PDMGenerate Exploded BOM", workflow , 
                          project, cpr_Catalog,
                          cpr_Partnum, cpr_Revision);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug (fn, "Validate User Access Failed : 0x%.8x \n", status);
    return (status);
    }
   
.......*/

  _PDMdebug (fn, "Loading the exec structure...\n");

  PDUload_exec_structure("", cpr_Catalog, cpr_Partnum, cpr_Revision, "",
                           cpr_TemplName, cpr_SaName, 0, 0);

  _PDMdebug (fn, "exec structure loaded...\n");

  status =  PDMgenerate_review_bom (&xpw_ReturnBuffer);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug (fn, "PDMgenerate Review BOM Failed : 0x%.8x \n", status);
    return (status);
    }
   

  if (strlen (cpw_ReportFileName) == 0 ) {
   status = MEMbuild_array (xpw_ReturnBuffer);
   if (status != MEM_S_SUCCESS) {
     _PDMdebug (fn, "MEMbuild_array Failed : 0x%.8x \n", status);
     return (status);
     }
   
   data = (char **) xpw_ReturnBuffer->data_ptr;
   cpw_ReportFileName = (char *) malloc (strlen (data[0]));
   cpw_ReportFileName [0] = '\0';
   strcpy (cpw_ReportFileName, data[0]);
   _PDMdebug (fn, "reportfilename[%s]\n", cpw_ReportFileName);
   MEMclose (&xpw_ReturnBuffer);
  }
   
  _PDMdebug (fn, "EXIT\n");
  return (PDM_S_SUCCESS);
 
}


