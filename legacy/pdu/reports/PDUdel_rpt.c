#include        <stdio.h>
#include        <PDUstr.h>
#include        <PDUerror.h>
#include        <PDUcommand.h>
#include        <PDMtypes.h>
#include        <PDUforms.h>
#include        <FI.h>
#include        <PDUproto.h>
#include        <PDMproto.h>

extern int PDU_command;
extern char *PDU_report_name;
extern int PDM_debug_on;

int PDUdelete_report()

  {
  int status;
  char   *templatetype = NULL;

  _pdm_debug("In the function PDUdelete_report",0);


  /* fille in report structure */
  switch (PDU_command)
    {
     case PDC_M_DELETE_BOM_FORMAT:

         PDUfill_in_string(&templatetype, "X");

          break;

     case PDC_M_DEL_BOM_SUM_PR_FORM:

         PDUfill_in_string(&templatetype, "S");

          break;

     case PDC_M_DEL_BOM_EXP_PR_FORM:

         PDUfill_in_string(&templatetype, "P");

          break;

     case PDC_M_DEL_BOM_PARTS_LIST_PR_FORM:

         PDUfill_in_string(&templatetype, "O");

          break;

     case PDC_M_DEL_BOM_WHERE_BOM_PR_FORM:

         PDUfill_in_string(&templatetype, "W");

          break;

      case PDC_M_DEL_BOM_WHERE_USED_PR_FORM:

         PDUfill_in_string(&templatetype, "U");

          break;

      case PDC_M_DELETE_LOC_DISP_FORMAT:

         PDUfill_in_string(&templatetype, "L");

          break;

      case PDC_M_DELETE_CATLIST_FORMAT:

         PDUfill_in_string(&templatetype, "C");

          break;
   
       } /* end switch(PDU_command */

    /* call PDM function to see if report exists */
    status = PDMvalidate_report_name(PDU_report_name, templatetype);
    _pdm_status("PDMvalidate_report_name", status);

    if (status != PDM_E_REPORT_EXISTS)
      return(PDM_E_BAD_REPORT);

     /* call PDM to delete report */
     status = PDMdelete_report(PDU_report_name,templatetype);
     _pdm_status("PDMdelete_report", status);

     if (status == PDM_S_SUCCESS)
       PDUdelete_report_from_field();

     PDUmessage(status,'s');

   return(status);
  }
