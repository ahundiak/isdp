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

#define         COFILE_BUFR      2011
#define         COASSY_BUFR      2012

extern struct NFMitem_entry  *NFMitem_files;


/*
 * The part is either an assy or atomic part If it is atomic use
 * NFMprepare_item_checkout  & NFMcomplete_item_checkout If it is an assy
 * Handle CIT attachments using NFMprepare_set_checkout  &
 * NFMcomplete_set_checkout
 * 
 * BOM attachments are handled individually by PDM
 */

/*
int pdmoCheckOutPart (spr_part, ipw_status)
PDMparts  *spr_part;
long      *ipw_status;
*/
int pdmoCheckOutPart (cpr_Catalog, cpr_Partnum, cpr_Revision, ipw_status)
char      *cpr_Catalog, *cpr_Partnum, *cpr_Revision;
long      *ipw_status;
{

  char                          *fn = "PDMcheckout_part";
  char                          sql_str[512];
  /*char      cpr_Catalog[40], cpr_Partnum[240], cpr_Revision[240];*/
  MEMptr    status_buffer = NULL;
  MEMptr    file_bufr = NULL;
  MEMptr    out_file_bufr = NULL;
  MEMptr    AssyBufr = NULL;
  MEMptr    ChildBufr = NULL;
  char		caw_formatfile[512], caw_datafile[512], cpw_SetInd[7];

  PDMdebug("ENTER: pdmoCheckOutPart:\n");

  strcpy(glob_var,"Checking out part");
  _PDMdebug (fn, "catalog[%s] part[%s] rev[%s]\n",
                PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
   
  sql_str[0] = '\0';
  caw_formatfile[0] = '\0';
  caw_datafile[0] = '\0';
  cpw_SetInd[0] = '\0';
/*
  cpr_Catalog[0] = '\0';
  cpr_Partnum[0] = '\0';
  cpr_Revision[0] = '\0';

  strcpy (cpr_Catalog, spm_part->cpr_Catalog);
  strcpy (cpr_Partnum, spm_part->cpr_itemname);
  strcpy (cpr_Revision, spm_part->cpr_itemrev);
*/

 /* Validating required inputs */

  if ( (!strlen (cpr_Catalog)) || (!strlen (cpr_Partnum)) ||
                                             (!strlen (cpr_Revision))) {
     _PDMdebug (fn, "Required parameters are not input\n");
     return (PDM_E_PART_NOT_FOUND);
      }

/*
  if (!strlen (cpr_SaName) ) {
     _PDMdebug (fn, "Required parameters are not input\n");
     return (PDM_E_PART_NOT_FOUND);
      }
*/


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

     status = PDMvalidate_user_access("PDMCheck Out Part", "",
           cpr_Catalog, "", cpr_Partnum, cpr_Revision );
     if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "Validate User Access Failed : 0x%.8x \n", status);
       return(status);
      }

  /* check if part exists */

  _PDMdebug (fn, "Checking out Part or Parent of Assy..\n");

  status =  PDMcheckout_part (file_bufr, &out_file_bufr, &AssyBufr);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug (fn, "Checkout Parent/part : status = <0x%.8x>\n", status);
    return (status);
  }
  
  cpw_SetInd[0] = '\0';

  status = PDMquery_assembly_ind(cpr_Catalog, cpr_Partnum, cpr_Revision, 
                                     cpw_SetInd);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug (fn, "Checkout Parent/part : status = <0x%.8x>\n", status);
    PDMcancel_checkout_part(NULL, NULL, NULL);
    return (status);
  }

 if ((!strcmp (cpw_SetInd, "Y")) || (!strcmp (cpw_SetInd, "y")) ) {

/* Function Plug in for routine which writes the buffer information
   into shared memory...*/

   caw_formatfile[0] = '\0';
   caw_datafile[0] = '\0';

   sprintf(caw_formatfile, "/usr/tmp/%d.for", COASSY_BUFR);
   sprintf(caw_datafile, "/usr/tmp/%d.dat", COASSY_BUFR);

   status = PDMbuffer_to_file (AssyBufr, caw_formatfile, caw_datafile);
   if(status != PDM_S_SUCCESS) {
        _PDMdebug(fn, "PDMbuffer_to_file failed status %d\n", status);
        PDMcancel_checkout_part(NULL, NULL, NULL);
         return(status);
       }

   caw_formatfile[0] = '\0';
   caw_datafile[0] = '\0';

   sprintf(caw_formatfile, "/usr/tmp/%d.for", COFILE_BUFR);
   sprintf(caw_datafile, "/usr/tmp/%d.dat", COFILE_BUFR);

   status = PDMbuffer_to_file (out_file_bufr, caw_formatfile, caw_datafile);
   if(status != PDM_S_SUCCESS) {
        _PDMdebug(fn, "PDMbuffer_to_file failed status %d\n", status);
        PDMcancel_checkout_part(NULL, NULL, NULL);
         return(status);
       }


/* Function Plug in for routine which reads the information
   about files to be brought local into shared memory...*/

 /************************************************************/

pdmoObjectSpaceInfoForCheckout();

 /************************************************************/

/* retrieve children files....*/

/* Function Plug in for routine which reads the struct info into
   buffer */

    caw_formatfile[0] = '\0';
    caw_datafile[0] = '\0';

    sprintf(caw_formatfile, "/usr/tmp/%d.for", COASSY_BUFR);
    sprintf(caw_datafile, "/usr/tmp/%d.dat", COASSY_BUFR);

    status = PDMfile_to_tmp_bufr(&ChildBufr, caw_formatfile, caw_datafile);
    if(status != PDM_S_SUCCESS) {
        _PDMdebug(fn, "PDMfile_to_tmp_bufr failed status %d\n", status);
        PDMcancel_checkout_part(NULL, NULL, NULL);
         return(status);
       }

 
  status = PDMRetrieveAssyFiles (ChildBufr, &status_buffer);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug (fn, "RetrieveAssyFiles  Failed : status = <0x%.8x>\n", status);
    PDMcancel_checkout_part(NULL, NULL, NULL);
    return (status);
   }
  MEMclose (&ChildBufr);
  }


/*
  _PDMdebug (fn, "catno = %d, partno = %d, parttype = %s,n_status = %s\n",
    PDMpart.n_catalogno,PDMpart.n_itemno,PDMpart.p_parttype, PDMpart.n_status);

  PDMdebug("EXIT:PDMcheckout_part\n");
*/


  
  *ipw_status = PDM_S_SUCCESS;
  _PDMdebug ("EXIT", "pdmoCheckOutPart\n");
  return (PDM_S_SUCCESS);
}

