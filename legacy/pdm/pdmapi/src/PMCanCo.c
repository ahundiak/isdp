#include    <stdio.h>
#include    "PDUerror.h"
#include    "MEMstruct.h"
#include    "MEMerrordef.h"
#include    "NFMerrordef.h"
#include    "SQLerrordef.h"
#include    "PDUris_incl.h"
#include    "NFMfile.h"
#include    "NFMstruct.h"
#include    "PDUstorage.h"
#include    "ERR.h"
#include    "PDMproto.h"
#include    "PDUpdmrpro.h"
#include    "PDUnode.h"

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
char     PDMuser[25];
extern PDMpart_ptr PDMpart;
extern PDMexec_ptr PDMexec;
static long     status;
extern struct sto_area_info STO_info;
extern struct WFstruct WFinfo;
extern struct NFMglobal_st NFMglobal;
extern struct PDUcat_node *PDMparam_cat_list;
extern struct PDUstorage *storage;
extern char   glob_var[100];

/* additional declarations for NFM3.0 */
#include                "NFMschema.h"
#include                "NFMapi.h"
#include                "NFMitems.h"
#include                "NFMitemfiles.h"
#include                "NFMfto_buf.h"
#include                "WFexterns.h"
extern struct NFMwf_info  PDMwf_info;
extern struct NFMoperation  *PDMoperation, *PDMlast_oper;

/* Global variable to maintain processed items and files information */

#define         CANCOFILE_BUFR      2013
#define         CANCOASSY_BUFR      2014

extern struct NFMitem_entry  *NFMitem_files;

int pdmoCancelPartCheckOut ( char *cpr_Catalog,
                             char *cpr_Partnum,
                             char *cpr_Revision)
{

  char                          *fn = "pdmoCancelPartCheckOut";
  char                          sql_str[512];
  MEMptr    status_buffer = NULL;
  MEMptr    mul_files = NULL;
  MEMptr    delete_list = NULL;
  MEMptr    attach_list = NULL;
  char		caw_formatfile[14], caw_datafile[14], cpw_SetInd[7];

  PDMdebug("ENTER: pdmoCheckOutPart:\n");

  strcpy(glob_var,"Checking out part");
  _PDMdebug (fn, "catalog[%s] part[%s] rev[%s]\n",
                PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
   
  sql_str[0] = '\0';
  caw_formatfile[0] = '\0';
  caw_datafile[0] = '\0';
  cpw_SetInd[0] = '\0';

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


  _PDMdebug (fn, "Loading the exec structure...\n");

  PDUload_exec_structure("", cpr_Catalog, cpr_Partnum, cpr_Revision, "",
                           "", "", 0, 0);

  _PDMdebug (fn, "exec structure loaded...\n");


  /* Validate User Access */

  _PDMdebug (fn, "Validating  User Access...\n");

     status = PDMvalidate_user_access("PDMCancel Part Check Out", "",
                             cpr_Catalog, "", cpr_Partnum, cpr_Revision );
     if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "Validate User Access Failed : 0x%.8x \n", status);
       return(status);
      }

  cpw_SetInd[0] = '\0';

  status = PDMquery_assembly_ind(cpr_Catalog, cpr_Partnum, cpr_Revision, 
                                     cpw_SetInd);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug (fn, "Checkout Parent/part : status = <0x%.8x>\n", status);
    return (status);
  }

  status = PDMget_file_names (&mul_files);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug (fn, "Checkout Parent/part : status = <0x%.8x>\n", status);
    return (status);
  }


  caw_formatfile[0] = '\0';
  caw_datafile[0] = '\0';

  sprintf(caw_formatfile, "/usr/tmp/%d.for", CANCOFILE_BUFR);
  sprintf(caw_datafile, "/usr/tmp/%d.dat", CANCOFILE_BUFR);

  status = PDMbuffer_to_file (mul_files, caw_formatfile, caw_datafile);
  if(status != PDM_S_SUCCESS) {
        _PDMdebug(fn, "PDMfile_to_tmp_bufr failed status %d\n", status);
         return(status);
  }

  MEMclose (&mul_files);
 
 delete_list = NULL;
 attach_list = NULL;
 mul_files = NULL;

 if ((!strcmp (cpw_SetInd, "Y")) || (!strcmp (cpw_SetInd, "y")) ) {

/********************************************************************/

status = pdmoObjectSpaceInfoForCancelPartCheckout();

/********************************************************************/

/* Function Plug in for routine which reads the delete list into
   buffer */

    caw_formatfile[0] = '\0';
    caw_datafile[0] = '\0';

    sprintf(caw_formatfile, "/usr/tmp/%d.for", CANCOFILE_BUFR);
    sprintf(caw_datafile, "/usr/tmp/%d.dat", CANCOFILE_BUFR);

    status = PDMfile_to_tmp_bufr(&delete_list, caw_formatfile, caw_datafile);
    if(status != PDM_S_SUCCESS) {
        _PDMdebug(fn, "PDMfile_to_tmp_bufr failed status %d\n", status);
         return(status);
       }

    caw_formatfile[0] = '\0';
    caw_datafile[0] = '\0';

    sprintf(caw_formatfile, "/usr/tmp/%d.for", CANCOASSY_BUFR);
    sprintf(caw_datafile, "/usr/tmp/%d.dat", CANCOASSY_BUFR);

    status = PDMfile_to_tmp_bufr(&attach_list, caw_formatfile, caw_datafile);
    if(status != PDM_S_SUCCESS) {
        _PDMdebug(fn, "PDMfile_to_tmp_bufr failed status %d\n", status);
         return(status);
       }
     } /* If it is an assy*/

  status =  PDMcancel_checkout_part (&delete_list,
                                      attach_list,
                                      NULL,
                                      &mul_files);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug (fn, "Checkout Parent/part : status = <0x%.8x>\n", status);
    return (status);
  }
  
 if ((!strcmp (cpw_SetInd, "Y")) || (!strcmp (cpw_SetInd, "y")) ) {

/* Function Plug in for routine which writes the buffer information
   into shared memory...*/

   caw_formatfile[0] = '\0';
   caw_datafile[0] = '\0';

   sprintf(caw_formatfile, "/usr/tmp/%d.for", CANCOASSY_BUFR);
   sprintf(caw_datafile, "/usr/tmp/%d.dat", CANCOASSY_BUFR);

   status = PDMbuffer_to_file (delete_list, caw_formatfile, caw_datafile);
   if(status != PDM_S_SUCCESS) {
        _PDMdebug(fn, "PDMbuffer_to_file failed status %d\n", status);
         return(status);
       }

   caw_formatfile[0] = '\0';
   caw_datafile[0] = '\0';

   sprintf(caw_formatfile, "/usr/tmp/%d.for", CANCOFILE_BUFR);
   sprintf(caw_datafile, "/usr/tmp/%d.dat", CANCOFILE_BUFR);

   status = PDMbuffer_to_file (mul_files, caw_formatfile, caw_datafile);
   if(status != PDM_S_SUCCESS) {
        _PDMdebug(fn, "PDMbuffer_to_file failed status %d\n", status);
         return(status);
       }

 MEMclose (&mul_files);
 MEMclose (&delete_list);
 MEMclose (&attach_list);

/* Function Plug in for routine which reads the information
   about files to be deleted locally into shared memory...*/

 /************************************************************/


 /************************************************************/

  }
  
  _PDMdebug ("EXIT", "pdmoCancelPartCheckOut\n");
  return (PDM_S_SUCCESS);
}

