#include        <stdio.h>
#include        <PDUstr.h>
#include        <PDUerror.h>
#include        <PDUcommand.h>
#include        <PDUstorage.h>
#include        <PDUfile_def.h>
#include        <PDMtypes.h>
#include        <PDUforms.h>
#include        <MEMerrordef.h>
#include        <MRPmacros.h>
#include        <MRPstr.h>
#include        <PSUgadlabs.h>
#include        <MRPmessage.h>
#include        <PDUproto.h>
#include        <PDMproto.h>

#define SAVE_OP_TOG   50


extern int PDU_command;
extern struct PDUrefresh *refresh;
extern struct PDUstorage *storage;
extern struct PDUforms forms;
extern struct PSUrpt *PDU_pdurpt;
extern char *PDU_report_name;
extern char *PDU_output_file;
extern char *PDU_report_title;
extern char *PDU_template;
extern struct MRPvar *mrpvar;
extern struct rMRPvar *rmrpvar;
extern int PDM_debug_on;
extern short PDU_report_exists;
extern FILE *rMRPdbg_fileptr;


int PDUdefine_report_attributes(rpt_buffer)

MEMptr *rpt_buffer;
  {

   int status;
   MEMptr attr_list = NULL;
   MEMptr data_list = NULL;
   MEMptr value_list = NULL;
   char   *row;

   switch ( PDU_command )
     {
        case PDC_M_DEFINE_BOMSUM:
             /* create attribute buffer */
             status = PDUcreate_dynamic_attr_buffr(&attr_list);
             _pdm_status("PDUcreate_dynamic_attr_buff", status);
             
             /* malloc char string for row of data */
             row = (char *)malloc((attr_list)->row_size);

             /* set string to NULL */
             /*memset(row, NULL, attr_list->row_size);

             sprintf(row,
                    "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1%s\1",
               "p_seqno", "integer", "Sequential Sort Number","PDM","Y","N","N",
               "N","N",1,"0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }*/

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                    "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_catalogname", "char(12)", "Catalog","PDM","Y","N","N",
                     "N","N","2","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                    "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_itemname", "char(15)", "Part Number","PDM","Y","N","N",
                     "N","N","3","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_itemrev", "char(15)", "Revision","PDM","Y","N","N",
                     "N","N","4","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_itemdesc", "char(40)", "Part Description","PDM","Y","N",
                     "N","N","N","5","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "p_quantity", "double", "Part Quantity","PDM","Y","N","N",
                     "N","N","6","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }
             
              break;

        case PDC_M_DEFINE_BOMPRINT:
        case PDC_M_DEFINE_EXPSUM:
             
                status = PDMget_table_attributes(QUERY_TABLE, PDM_BOMCONTENT,
                                        "", &attr_list,
                                        &data_list, &value_list);
                _pdm_status("PDMget_table_attributes", status);

                if (status != PDM_S_SUCCESS)
                  {
                    MEMclose(&attr_list);
                    MEMclose(&data_list);
                    MEMclose(&value_list);
                    return(status);
                  }
             row = (char *)malloc((attr_list)->row_size);

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                    "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1%s\1",
               "n_level", "integer", "Level","PDM","Y","N","N",
               "N","N",(attr_list->rows + 1),"0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

              break;

        case PDC_M_DEF_BOM_WHERE_USED_PFORM:
             /* create attribute buffer */
             status = PDUcreate_dynamic_attr_buffr(&attr_list);
             _pdm_status("PDUcreate_dynamic_attr_buff", status);

             /* set string to NULL */
             /* malloc char string for row of data */
             row = (char *)malloc((attr_list)->row_size);
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_catalogname", "char(12)", "Catalog","PDM","Y","N","N",
                     "N","N","1","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_itemname", "char(15)", "Part Number","PDM","Y","N","N",
                     "N","N","2","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_itemrev", "char(15)", "Revision","PDM","Y","N","N",
                     "N","N","3","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             break;

        case PDC_M_DEF_BOM_WHERE_BOM_PFORM:
             /* create attribute buffer */
             status = PDUcreate_dynamic_attr_buffr(&attr_list);
             _pdm_status("PDUcreate_dynamic_attr_buff", status);

             /* malloc char string for row of data */
             row = (char *)malloc((attr_list)->row_size);
             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_catalogname", "char(12)", "Catalog","PDM","Y","N","N",
                     "N","N","1","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_itemname", "char(15)", "Part Number","PDM","Y","N","N",
                     "N","N","2","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_itemrev", "char(15)", "Revision","PDM","Y","N","N",
                     "N","N","3","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }
             break;

        case PDC_M_DEFINE_BOM_PARTS_FORM:
             /* create attribute buffer */
             status = PDUcreate_dynamic_attr_buffr(&attr_list);
             _pdm_status("PDUcreate_dynamic_attr_buff", status);

             /* malloc char string for row of data */
             row = (char *)malloc((attr_list)->row_size);
             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_catalogname", "char(12)", "Catalog","PDM","Y","N","N",
                     "N","N","1","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_itemname", "char(15)", "Part Number","PDM","Y","N","N",
                     "N","N","2","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_itemrev", "char(15)", "Revision","PDM","Y","N","N",
                     "N","N","3","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "n_itemdesc", "char(40)", "Part Description","PDM","Y","N",
                     "N","N","N","4","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             /*memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
               "p_seqno", "integer", "Sequential Sort Number","PDM","Y","N","N",
               "N","N","5","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }*/

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                   "p_tagno", "integer", "Unique Tag Number","PDM","Y","N","N",
                   "N","N","6","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
            "p_alttagno", "char(25)", "Alternate Tag Number","PDM","Y","N","N",
            "N","N","7","0","0");

             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

             /* set string to NULL */
             memset(row, NULL, attr_list->row_size);

             sprintf(row,
                     "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1",
                     "p_quantity", "double", "Part Quantity","PDM","Y","N","N",
                     "N","N","8","0","0");


             status = MEMwrite(attr_list,row);
             if (status != MEM_S_SUCCESS)
               {
               MEMclose(attr_list);
               return(PDM_E_WRITE_ROW);
               }

              break;

        case PDC_M_DEFINE_CATLIST:
                status = PDMquery_table_definition(refresh->rev_catalog,
                                        "catalog", &attr_list);
                _pdm_status("PDMquery_table_definition", status);

                if (status != PDM_S_SUCCESS)
                  {
                    MEMclose(&attr_list);
                    return(status);
                  }
                break;

       case PDC_M_DEFINE_LOC_DISPLAY:
                status = PDMget_table_attributes(QUERY_TABLE, PDM_LOC, "",
                                                 &attr_list, &data_list,
                                                 &value_list);
                _pdm_status("PDMget_table_attributes", status);

                if (status != PDM_S_SUCCESS)
                  {
                    MEMclose(&attr_list);
                    MEMclose(&data_list);
                    MEMclose(&value_list);
                    return(status);
                  }

                 break;

        default:

                break;

    }

  if (PDM_debug_on)
   MEMprint_buffer("attribute buffer", attr_list, PDU_DEBUG_FILE);
  *rpt_buffer = attr_list;
  return(PDM_S_SUCCESS);
  }

int PDUdefine_report_format()

  {
  int status;
  MEMptr attr_bufr = NULL;
  MEMptr def_op = NULL;
  MEMptr def_list = NULL;
  struct PSUattr *attr_struct = NULL;
  char   templatetype[2];
  int    listtotal;
  int    state;

  _pdm_debug("In the function PDUdefine_report_format", 0);

  /* call function to initialize PDUrpt struct */
  PDUalloc_rpt(&PDU_pdurpt);

  /* fill in report structure */
  switch (PDU_command)
    {
    case PDC_M_DEFINE_BOMPRINT:

         strcpy(PDU_pdurpt->templatetype ,"X");
         strcpy(templatetype ,"X");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy((PDU_pdurpt->options).output,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);
        
         PDUfill_in_string(&PDU_report_title, "DEFINING SUMMARY BOM FORMAT");
         break;

    case PDC_M_DEFINE_BOM_PARTS_FORM: 

         strcpy(PDU_pdurpt->templatetype,"O");
         strcpy(templatetype,"O");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy((PDU_pdurpt->options).output,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);
        
         PDUfill_in_string(&PDU_report_title, "DEFINING BOM PARTS LIST FORMAT");
         break;

    case PDC_M_DEFINE_BOMSUM:

         strcpy(PDU_pdurpt->templatetype ,"S");
         strcpy(templatetype ,"S");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy((PDU_pdurpt->options).output,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);
        
         PDUfill_in_string(&PDU_report_title, "DEFINING SUMMARY BOM FORMAT");
         break;

    case PDC_M_DEFINE_EXPSUM:

         strcpy(PDU_pdurpt->templatetype, "P");
         strcpy(templatetype, "P");
         _pdm_debug("report name = <%s>", PDU_report_name);
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy((PDU_pdurpt->options).output,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);
       
         PDUfill_in_string(&PDU_report_title, "DEFINING BOM PRINT FORMAT");
         break;
    case PDC_M_DEF_BOM_WHERE_BOM_PFORM:

         strcpy(PDU_pdurpt->templatetype, "W");
         strcpy(templatetype, "W");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy((PDU_pdurpt->options).output,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);
        
         PDUfill_in_string(&PDU_report_title, "DEFINING SUMMARY BOM FORMAT");
         break;

    case PDC_M_DEF_BOM_WHERE_USED_PFORM:

         strcpy(PDU_pdurpt->templatetype,"U");
         strcpy(templatetype,"U");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy((PDU_pdurpt->options).output,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);
        
         break;

    case PDC_M_DEFINE_LOC_DISPLAY:

         strcpy(PDU_pdurpt->templatetype, "L");
         strcpy(templatetype, "L");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy((PDU_pdurpt->options).output,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);
        
         PDUfill_in_string(&PDU_report_title, 
                           "DEFINING LIST OF CATALOGS FORMAT");
         break;

    case PDC_M_DEFINE_CATLIST:

         strcpy(PDU_pdurpt->templatetype,"C");
         strcpy(templatetype,"C");
         strcpy((PDU_pdurpt->options).template_name,PDU_report_name);
         FIg_get_state(forms.report_form_id, SAVE_OP_TOG, &state);
         if ((state) && (PDU_output_file != NULL))
           strcpy((PDU_pdurpt->options).output,PDU_output_file);
         _pdm_debug("Template Type = <%s>", PDU_pdurpt->templatetype);
        
         PDUfill_in_string(&PDU_report_title, 
                           "DEFINING CATALOG LIST FORMAT");
         break;

    } /* end switch(PDU_command)*/

  /* call PDM functio to see if report exists */
  status = PDMvalidate_report_name(PDU_report_name, templatetype);
  _pdm_status("PDMvalidate_report_name", status);

  if (status == PDM_E_REPORT_EXISTS)
  {
  _pdm_debug("report exists", 0);

  /* call function to format buffers */
  status = PDUformat_report_buffers(&def_op, &def_list);
  _pdm_status("PDUformat_report_buffers", status);

  if (status != PDM_S_SUCCESS)
    {
    _pdm_debug("Before displaying report form", 0);
    FIf_display(forms.report_form_id);
    _pdm_debug("After displaying report form", 0);
    return(status);
    }

  /* call function to convert structures to buffers */
  status = PDUfrom_struct_to_buffers(&def_op, &def_list);
  _pdm_status("PDUfrom_struct_to_buffers", status);

  if (status != PDM_S_SUCCESS)
    {
    FIf_display(forms.report_form_id);
    return(status);
    }

  /* call PDM function to see if report already exists */
  status = PDMread_report_format(refresh->rev_catalog, refresh->rev_partid, 
                               refresh->rev_revision , 0,templatetype, 
                               PDU_pdurpt->process, PDU_pdurpt->where, PDU_pdurpt->templib, 
                               &def_op, &def_list);
  _pdm_status("PDMread_report_format", status);

  if (status != PDM_S_SUCCESS)
    {
    FIf_display(forms.report_form_id);
    return(status);
    }

  if (PDU_pdurpt != NULL)
    rMRPfree_pdurpt(&PDU_pdurpt);
  /* call function to initialize PDUrpt struct */
  PDUalloc_rpt(&PDU_pdurpt);
  /* call function to convert buffers to struct */
  status = PDUfrom_bufrs_to_structures(def_op, def_list);
  _pdm_status("PDUfrom_bufrs_to_structures", status);
 
  if (status != PDM_S_SUCCESS)
    {
    FIf_display(forms.report_form_id);
    return(status);
    }
  strcpy(PDU_pdurpt->templatetype, templatetype);
  }

  /* call function to get the list of attributes according to command */
  status = PDUdefine_report_attributes(&attr_bufr);
  _pdm_status("PDUdefine_report_format", status);

  if (status != PDM_S_SUCCESS)
    {
    FIf_display(forms.report_form_id);
    PDUmessage(status, 's');
    return(status);
    }

  /* call function to load attributes in PSUattr structure */
  status = PDUload_PSUattr_struct(&attr_struct, attr_bufr, &listtotal);
  _pdm_status("PDUload_PSUattr_struct", status);

  if (status != PDM_S_SUCCESS)
    {
    FIf_display(forms.report_form_id);
    PDUmessage(status, 's');
    return(status);
    }

  /* MEMclose def_op and def_list */
  if (def_op)
    MEMclose(&def_op);

  if (def_list)
    MEMclose(&def_list);

  /* call function to format buffers */
  /* allocate MRP structures */
  status = MRPalloc_var();
  _pdm_status("MRPalloc_var", status);

  status = rMRPalloc_var();
  _pdm_status("rMRPmalloc_var", status);

  rMRPdbg_fileptr = stderr;

  /* call PSUload_list_format */
  status = PSUload_list_format(PDU_command, attr_struct, 
                               listtotal);
  _pdm_status("PSUload_list_format", status);

  _pdm_debug("report name = <%s>", PDU_pdurpt->options.template_name);

  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  return(PDM_S_SUCCESS);
  }

int PDUfinish_define_format()

  { 
  int status;
  MEMptr def_op = NULL;
  MEMptr def_list = NULL;
  char templatetype[2];

  _pdm_debug("In PDUfinish_define_format",0);

  _pdm_debug("report name = <%s>", PDU_pdurpt->options.template_name);
  status = PDUformat_report_buffers(&def_op, &def_list);
  _pdm_status("PDUformat_report_buffers", status);

  if (status != PDM_S_SUCCESS)
    {
    FIf_display(forms.report_form_id);
    PDUmessage(status, 's');
    refresh->status = status;
    return(status);
    }

  /* call function to convert structures to buffers */
  status = PDUfrom_struct_to_buffers(&def_op, &def_list);
  _pdm_status("PDUfrom_struct_to_buffers", status);

  if (status != PDM_S_SUCCESS)
    {
    FIf_display(forms.report_form_id);
    PDUmessage(status, 's');
    refresh->status = status;
    return(status);
    }

  if (((!def_op) || (!def_list)) || ((def_op) && (def_op->rows == 0)) ||
      ((def_list) && (def_list->rows == 0)))
    {
    FIf_display(forms.report_form_id);
    status = PDM_E_RPT_DEFN_EMPTY;
    PDUmessage(status, 's');
    refresh->status = status;
    return(status);
    }

  /* call PDMfunction to process changes */
  status = PDMadd_report(refresh->rev_catalog, refresh->rev_partid, 
                         refresh->rev_revision, def_list->rows, 
                         PDU_pdurpt->templatetype, PDU_pdurpt->process, PDU_pdurpt->where,
                         PDU_pdurpt->templib,def_op, def_list);
  _pdm_status("PDMadd_report", status);

  refresh->status = status;
  /* free up structures */
  if (def_op)
    MEMclose(&def_op);

  if (def_list)
    MEMclose(&def_list);

  if (PDU_pdurpt != NULL)
    rMRPfree_pdurpt(&PDU_pdurpt);
  
  /* set the state */
  PDUmessage_trans(status, 's');
  PDUmessage(status, 's');

  if (status == PDM_S_SUCCESS)
    {
    PDU_report_exists = TRUE;
    PDUget_templatetype(templatetype);
    PDUcheck_reportname(templatetype);
    }

  FIf_display(forms.report_form_id);
  return(PDM_S_SUCCESS);
  }

int PDUimport_ris_report(template_file, local_flag)

  char *template_file;
  int local_flag;

  {
  int status = PDM_S_SUCCESS;
  char   templatetype[3];
  struct PSUrpt report;
  extern MEMptr PDU_storage_area;
  
  _pdm_debug("In PDUimport_ris_report", 0);

  _pdm_debug("template_file <%s>", template_file);
  /* call function to get template type */
  PDUget_templatetype(templatetype);
  _pdm_debug("templatetype <%s>", templatetype);

  /* based on templatetype decide report name */
  if (strcmp(templatetype, "P") == 0)
    strcpy(report.options.table, "pdmbom_rpt");
  else if (strcmp(templatetype, "S") == 0)
    strcpy(report.options.table, "pdmsumbom_rpt");
  else if (strcmp(templatetype, "O") == 0)
    strcpy(report.options.table, "pdmparts_rpt");
  else if (strcmp(templatetype, "W") == 0)
    strcpy(report.options.table, "pdmwherehigh_rpt");
  else if (strcmp(templatetype, "U") == 0)
    strcpy(report.options.table, "pdmwhereimm_rpt");
  else if (strcmp(templatetype, "L") == 0)
    strcpy(report.options.table, "pdmloc_rpt");
  else if (strcmp(templatetype, "X") == 0)
    strcpy(report.options.table, "pdmexpbom_rpt");
  else
    strcpy(report.options.table, "pdmloc_rpt");

  strcat(templatetype,"F");
  /* fill in report structure */
  strcpy(report.templatetype,templatetype);
  _pdm_debug("report->templatetype = <%s>", report.templatetype);
  strcpy(report.options.template_name, PDU_report_name);
  _pdm_debug("report.options.template_name = <%s>", 
              report.options.template_name);
  report.templib = NULL;
  strcpy(report.options.output, "");
  /*PDUfill_in_string(&report.templib, template_file);
  _pdm_debug("report.templib = <%s>", report.templib);*/

  /* get storage_name from global buffer */
status = PDMimport_ris_rpt(storage->storage_name, report, local_flag);
_pdm_status("PDMimport_ris_rpt", status);
  if (status == PDM_S_SUCCESS)
    {
    PDU_report_exists = TRUE;
    strcpy(templatetype, "");
    PDUget_templatetype(templatetype);
    PDUcheck_reportname(templatetype);
    }

  return(status);
  }
