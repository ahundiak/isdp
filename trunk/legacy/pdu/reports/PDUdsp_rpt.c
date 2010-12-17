#include        <PDUstr.h>
#include        <PDUstorage.h>
#include        <PDUerror.h>
#include        <PDUcommand.h>
#include        <PDUfile_def.h>
#include        <PDMtypes.h>
#include        <PDUforms.h>
#include        <MEMerrordef.h>
#include        <MRPstr.h>
#include        <rMRPstr.h>
#include        <PSUgadlabs.h>
#include        <MRPmessage.h>
#include        <MRPmacros.h>
#include        <FI.h>
#include        <PDUproto.h>
#include        <PDMproto.h>

#define SAVE_OP_TOG   50

extern int PDU_command;
extern struct PDUrefresh *refresh;
extern struct PDUstorage *storage;
extern struct PDUforms forms;
extern struct PSUrpt     *PDU_pdurpt;
extern char *PDU_report_name;
extern char *PDU_output_file;
extern char *PDU_report_title;
extern struct MRPvar *mrpvar;
extern struct rMRPvar *rmrpvar;
extern int PDM_debug_on;
extern int MRP_debug_on;
extern char   *PDU_delete_reports;

extern char *dba_support;
char errmsg[132];

int PDUdisplay_report()

  {
  int status;
  MEMptr del_rpt_bufr = NULL;
  char   *row = NULL;
  char   filename[240];
  int    i;
  int    length;
  int    state;
  short  CHAR_FOUND = FALSE;

  _pdm_debug("In the function PDUdisplay_report",0);

  PDUalloc_rpt(&PDU_pdurpt);
  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  strcpy(filename, "");

  /* fille in report structure */
  switch (PDU_command)
    {
     case PDC_M_BOM_DISPLAY_REVIEW:

         strcpy(PDU_pdurpt->templatetype,"X");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy(filename,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);

          break;

     case PDC_M_BOM_SUMMARY_BOM:

         strcpy(PDU_pdurpt->templatetype,"S");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy(filename,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);

          break;

     case PDC_M_EXPLODE_SUMMARY_BOM:

         strcpy(PDU_pdurpt->templatetype, "P");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy(filename,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);

          break;

     case PDC_M_BOM_PARTS_LIST:

         strcpy(PDU_pdurpt->templatetype,"O");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy(filename,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);

          break;

     case PDC_M_BOM_WHERE_HIGH_LEV:

         strcpy(PDU_pdurpt->templatetype,"W");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy(filename,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);

          break;

      case PDC_M_BOM_WHERE_USED_ASSEM:

         strcpy(PDU_pdurpt->templatetype,"U");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy(filename,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);

          break;

      case PDC_M_DISPLAY_LOC:

         strcpy(PDU_pdurpt->templatetype,"L");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy(filename,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);

          break;

      case PDC_M_DISPLAY_CATALOG:

         strcpy(PDU_pdurpt->templatetype,"C");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy(filename,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);

          break;
   
       } /* end switch(PDU_command */

    /* call PDM function to see if report exists */
    status = PDMvalidate_report_name(PDU_report_name, PDU_pdurpt->templatetype);
    _pdm_status("PDMvalidate_report_name", status);

    if (status != PDM_E_REPORT_EXISTS)
      {
      PDUmessage(status, 's');
      return(PDM_E_BAD_REPORT);
      }

  /* call function to format buffers */
  /*status = PDUformat_report_buffers(&def_op, &def_list);
  _pdm_status("PDUformat_report_buffers", status);

  if (status != PDM_S_SUCCESS)
    {
    FIf_display(forms.report_form_id);
    return(status);
    }*/

  /* call function to convert structures to buffers */
  /*status = PDUfrom_struct_to_buffers(&def_op, &def_list);
  _pdm_status("PDUfrom_struct_to_buffers", status);

  if (status != PDM_S_SUCCESS)
    {
    FIf_display(forms.report_form_id);
    return(status);
    }*/

   /* call PDMfunction to generate report */
  switch (PDU_command)
    {
     case PDC_M_BOM_DISPLAY_REVIEW:

         status = PDMprepare_explode_summary_bom(refresh->rev_catalog,
                                                 refresh->rev_partid,
                                                 refresh->rev_revision,
                                                 filename,
                                            (PDU_pdurpt->options).template_name,
                                                 storage->storage_name);
         _pdm_status("PDMprepare_summary_bom", status);

          break;

     case PDC_M_BOM_SUMMARY_BOM:

         /* call PDMprepare_summary_bom */
         status = PDMprepare_summary_bom(refresh->rev_catalog,
                                         refresh->rev_partid,
                                         refresh->rev_revision,
                                        filename,
                                         (PDU_pdurpt->options).template_name,
                                          storage->storage_name);
         _pdm_status("PDMprepare_summary_bom", status);

          break;

     case PDC_M_EXPLODE_SUMMARY_BOM:

          /* call PDUreport_from_buffers1 */
         status = PDMgen_bom_report(refresh->rev_catalog,
                                         refresh->rev_partid,
                                         refresh->rev_revision,
                                        filename,
                                         (PDU_pdurpt->options).template_name,
                                          storage->storage_name);
         _pdm_status("PDMgen_bom_report", status);

          break;

     case PDC_M_BOM_PARTS_LIST:

         /* call PDMprepare_bomparts_list */
         status = PDMprepare_bomparts_list(refresh->rev_catalog,
                                         refresh->rev_partid,
                                         refresh->rev_revision,
                                        filename,
                                         (PDU_pdurpt->options).template_name,
                                          storage->storage_name);
         _pdm_status("PDMprepare_bomparts_list", status);

          break;

     case PDC_M_BOM_WHERE_HIGH_LEV:

         /* call PDMgen_where_used_top */
         status = PDMgen_where_used_top(refresh->rev_catalog, 
                                        refresh->rev_partid, 
                                        refresh->rev_revision,
                                        filename,
                                        (PDU_pdurpt->options).template_name,
                                        storage->storage_name);
          _pdm_status("PDMgen_where_used_top", status);

          break;

      case PDC_M_BOM_WHERE_USED_ASSEM:

         /* call PDMgen_where_used_top */
         status = PDMgen_where_used_imm(refresh->rev_catalog, 
                                        refresh->rev_partid, 
                                        refresh->rev_revision,
                                        filename,
                                        PDU_report_name,
                                        storage->storage_name);
          _pdm_status("PDMgen_where_used_imm", status);

          break;

      case PDC_M_DISPLAY_LOC:

           status = PDMgen_loc_report((PDU_pdurpt->options).template_name,
                                       storage->storage_name, 
                                       filename);
           _pdm_status("PDMgen_loc_report", status);

          break;

      case PDC_M_DISPLAY_CATALOG:

         status = PDMgen_parts_in_catalog(refresh->rev_catalog,
                                         (PDU_pdurpt->options).template_name,
                                       storage->storage_name, 
                                       filename);
         _pdm_status("PDMgen_parts_in_catalog", status);

          break;
   
       } /* end switch(PDU_command */

   if (status != PDM_S_SUCCESS)
    {
     if(status != PDM_E_DBA_SINGLE && status != PDM_E_USER_NOT_LOGGED_IN)
    PDUmessage(status, 's');
    return(status);
    }
     
   _pdm_debug("calling PSUdisplay_rpt",0);
   _pdm_debug("Filename = <%s>",filename);
 
   if (PDM_debug_on)
     MRP_debug_on = TRUE;

   /* call function to see if report is local */
   status = PDUverify_file(filename);
   _pdm_status("PDUverify_file", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status); 
    }

   /* if first time to display report, open buffer */
   if (PDU_delete_reports == NULL)
     {
     /* call function to open and format buffer */
     status = PDUformat_delete_report_bufr(&del_rpt_bufr);
     _pdm_status("PDU_format_delete_report_buffer",0);

     PDU_delete_reports = (char *)del_rpt_bufr;
     }

    length = strlen(filename);
    for (i = 0; i < length; i++)
      if (!isdigit(filename[i]))
        {
        CHAR_FOUND = TRUE;
        break;
        }
    if (! CHAR_FOUND)
    {
   /* write filename to global buffer */
   del_rpt_bufr = (MEMptr)PDU_delete_reports;

   row = (char *)malloc(del_rpt_bufr->row_size);
   memset(row, NULL, del_rpt_bufr->row_size);

   sprintf(row, "%s\1", filename);

   status = MEMwrite(del_rpt_bufr, row);
   _pdm_status("MEMwrite", status);

   if (row)
     free(row);

   if (PDM_debug_on)
     MEMprint_buffer("delete report buffer", del_rpt_bufr, PDU_DEBUG_FILE);

   PDU_delete_reports = (char *)del_rpt_bufr;
   }

   /* call function to edit file */
   if ((PDU_command == PDC_M_BOM_DISPLAY_REVIEW) ||
       (PDU_command == PDC_M_EXPLODE_SUMMARY_BOM))
     {
     status = PDMIndentReportFile(filename, 10);
     _pdm_status("PDMIndentReportFile", status);
     }

   /* call PSUfunction to display report */
   status = PSUdisplay_rpt(filename);
   _pdm_status("PSUdisplay_rpt", status);
   PDUmessage(PDM_S_SUCCESS, 's');
   return(PDM_S_SUCCESS);
  }
