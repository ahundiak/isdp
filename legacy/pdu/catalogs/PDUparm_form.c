#include <stdio.h>
#include "exdef.h"
#include <tools.h>
#include <FI.h>
#include <PDUstr.h>
#include <PDUcommand.h>
#include <PDUerror.h>
#include <PDUforms.h>
#include "PDUform_def.h"
#include <MEMerrordef.h>
#include "PDUfile_def.h"
#include "PDUproto.h"
#include "PDMproto.h"

/* TR# 139422665. 02/Dec/94 - raj. */
#include "PDUerror.h"


/* Gadgets */

#define MACRO_LIBRARY  	12
#define MACRO_NAME     	14
#define PARM_CAT_NAME 	22
#define MACRO_ATTR_MCF 	26
#define PARM_CAT_DESCR	15
#define SKETCH_FILE   	38
#define GROUP1        	40
#define GROUP2        	46
#define MACNAME_ASSOC_GADGET 17
#define SOURCE_ASSOC_GADGET 23 
#define UNITS_ASSOC_GADGET 21 
#define DEF_SUP_LIB     24 
#define CHKIN_MAC_LIB   31 


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FIg_get_text_length();
extern int FIg_get_text();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();

extern struct PDUforms forms;
extern struct PDUrefresh *refresh;
extern Form PDU_form_id; 
extern Form PDU_calling_form; 
extern char *PDU_cat_description;
extern char *PDU_macro_name;
extern char *PDU_macro_library;
extern char *PDU_store_catalog;
extern char *PDU_macro_catalog;
extern char *PDU_macro_partid;
extern char *PDU_macro_partrev;
extern char *PDU_value_list[605];
extern char *PDU_macro_dyn_list[50];
extern int   PDU_macro_dyn_num;
extern int   PDU_view;
extern int   PDU_list_size;
extern int   PDU_value_pulldown;
extern int   PDU_catalog_pulldown;
extern int   PDU_tempcat_pulldown;
extern int   PDU_command;
extern int   PDU_num_feet;
extern int   PDU_num_temp;
extern int   PDM_debug_on;
extern short PDU_checkin_lib;
extern MEMptr PDU_parameter_buffer;
extern MEMptr PDU_macro_buffer;

extern char *PDU_sketch_file;

int parm_cat_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  static int      act_row = 0;
  int             length;
  int             select;
  int             status;
  int             list_row;
  int             col;
  int             pos;
  int             i;
  int             state;
  int             responses[1];
  char            *strings[1];
  char 		  *msg;

  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  PDUdismiss_subforms();

  switch ( g_label )
  {
    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */
                             /* Sequenced to    */

          /* Erase the displayed form */
         _pdm_debug("f_label = <%d>", (char *)f_label);
         GRdelete_pull_down_list(PDU_value_pulldown);
         GRdelete_pull_down_list(PDU_catalog_pulldown);

         FIf_delete ( fp );
         forms.parametric_catalog_form_id = 0;

         if ((PDU_command == PDC_M_CREATE_CATALOG) && (refresh->rev_catalog) &&
             (strcmp(refresh->rev_catalog, "") != 0))
           PDUfill_in_string(&refresh->rev_catalog, "");

         PDUcatalog_name_form();

         break;

    case FI_RESET:     /* Member of group FI_CTRL_GROUP */
                             /* Sequenced to    */

         FIg_set_text(fp, PARM_CAT_NAME, refresh->rev_catalog);
         FIg_set_text(fp, PARM_CAT_DESCR, PDU_cat_description);
         if (PDU_command == PDC_M_MODIFY_CATALOG)
           {
           FIg_disable(forms.parametric_catalog_form_id, MACRO_NAME);
           FIg_disable(forms.parametric_catalog_form_id, MACRO_LIBRARY);
           FIg_erase(forms.parametric_catalog_form_id, CHKIN_MAC_LIB);
           FIfld_set_mode(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 0, 
                   FI_REVIEW);
           FIfld_set_mode(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 1, 
                   FI_REVIEW);
           FIfld_set_mode(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 2, 
                   FI_REVIEW);
           FIfld_set_mode(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 0, 
                          FI_REVIEW);
           FIfld_set_mode(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 1, 
                         FI_REVIEW);
           if (PDM_debug_on) 
             MEMprint_buffer("macro buffer", PDU_macro_buffer,
                               PDU_DEBUG_FILE);

           status = PDUload_parametric_catalog_form(PDU_macro_buffer, 
                                                    PDU_parameter_buffer);
           _pdm_status("PDUload_parametric_catalog_form", status);
           break;
           }

         if ((PDU_macro_name != NULL) && (strcmp(PDU_macro_name, "") != 0))
           PDUfill_in_string(&PDU_macro_name, NULL);

         if ((PDU_macro_library != NULL) && (strcmp(PDU_macro_library,"") != 0))
           PDUfill_in_string(&PDU_macro_library, NULL);

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */
                             /* Sequenced to    */

          /* Erase the displayed form */

         FIfld_get_text_length(fp,PARM_CAT_NAME,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,PARM_CAT_NAME,0,0,length,
                        (unsigned char*)text,
                        &select,&pos);
         _pdm_debug("catalog text = <%s>", text);
         if ((text) && (strcmp(text, "") != 0))
           PDUfill_in_string(&refresh->rev_catalog, text);
         GRdelete_pull_down_list(PDU_value_pulldown);
         GRdelete_pull_down_list(PDU_catalog_pulldown);

         if ((PDU_macro_name == NULL) || (strcmp(PDU_macro_name, "") == 0))
           {
           msg = (char *)PDUtranslate_message(PDM_I_ENTER_MACRO_NAME);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           FIg_set_state_off(fp, FI_ACCEPT);
           break;
           }
         FIg_get_state(fp, CHKIN_MAC_LIB, &state);
         if (state == 1)
           PDU_checkin_lib = FALSE;
         else
           PDU_checkin_lib = TRUE;

         FIf_erase ( fp );
          /* Process form data */

         refresh->command = PDU_command;
         if (PDU_command == PDC_M_MODIFY_CATALOG)
           {
           status = PDUchange_parameters();
           _pdm_status("PDUchange_parameters", status);
           }

         PDUcatalog_attr_form();

         break;

    case MACRO_LIBRARY:     /* Sequenced to     */
                             /* Field Type:    ASCII    */


          /* Code to process text string "text" */
          /*PDUfill_in_string(&PDU_macro_library, text);

          FIg_enable(fp, DEF_SUP_LIB);*/

          FIf_erase(fp);
          PDUfill_in_string(&PDU_store_catalog, refresh->rev_catalog);
          PDUfill_in_string(&refresh->rev_catalog, NULL);
          SelectOrPlacePart(TRUE, FALSE, fp);

         break;

    case MACRO_NAME:     /* Sequenced to     */
                             /* Field Type:    ASCII    */

          /* Get the text string */

          if (PDU_macro_catalog == NULL)
            {
            msg = (char *)PDUtranslate_message(PDM_I_SEL_LIBRARY);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }
          else if (strcmp(PDU_macro_catalog, "") == 0)
            {
            msg = (char *)PDUtranslate_message(PDM_I_SEL_LIBRARY);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }
          else if (PDU_macro_partid == NULL)
            {
            msg = (char *)PDUtranslate_message(PDM_I_SEL_LIBRARY);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }
          else if (strcmp(PDU_macro_partid, "") == 0)
            {
            msg = (char *)PDUtranslate_message(PDM_I_SEL_LIBRARY);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }
          else if (PDU_macro_partrev == NULL)
            {
            msg = (char *)PDUtranslate_message(PDM_I_SEL_LIBRARY);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }
          else if (strcmp(PDU_macro_partrev, "") == 0)
            {
            msg = (char *)PDUtranslate_message(PDM_I_SEL_LIBRARY);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          /* make sure macro library exists in cwd */
          /*status = PDUverify_file(text);
          _pdm_status("PDUverify_file", status);
    
          if (status != PDM_S_SUCCESS)
            {
            msg = (char *)PDUtranslate_message(PDM_E_MACRO_LIB_LOCAL);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }*/

          /* get macro list from macro library */
          
           responses[0] = EX_CMD_KEY;

           strings[0] = "PDGtMcNm";

           status = PDUprepare_queue ( responses, strings, 1 );
           _pdm_status("PDUprepare_queue (delete catalog)",status);

         break;

    case PARM_CAT_NAME:     /* Sequenced to     */
                             /* Field Type:    ASCII    */
         break;

    case MACRO_ATTR_MCF:     /* Sequenced to     */

         FImcf_get_active_col(fp, MACRO_ATTR_MCF, &col, &pos);
         FIfld_get_active_row(fp, MACRO_ATTR_MCF, &act_row, &pos);

         if (col == 2)
           {
           _pdm_debug("user selected source column", 0);
           FIfld_get_text_length(fp,MACRO_ATTR_MCF,act_row,col,&length);
           text = (char *) malloc (sizeof (char) * length + 1);
           memset(text, NULL, sizeof (char) * length + 1);
           FIfld_get_text(fp,MACRO_ATTR_MCF,act_row,col,length,
                          (unsigned char*)text,
                          &select,&pos);
 
           if ((PDU_command == PDC_M_MODIFY_CATALOG) && ((text) &&
               (strcmp(text, "Static") == 0)))
             {
             msg = (char *)PDUtranslate_message(PDM_E_CHANGE_STATIC_ATTR);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             break;
             }
           else if ((PDU_command == PDC_M_MODIFY_CATALOG) && ((text) &&
                     (strcmp(text, "Dynamic - reportable") == 0)))
             {
             msg = (char *)PDUtranslate_message(PDM_E_CHANGE_DYN_REP_ATTR);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             break;
             }

           /* clear out old values */
           for (i = 0; i < PDU_list_size; i++)
             PDUfill_in_string(&PDU_value_list[i], "");
          
           if (PDU_view)
             {
             PDU_list_size = 2;

             PDUfill_in_string(&PDU_value_list[0], "Dynamic - file only");
             PDUfill_in_string(&PDU_value_list[1], "Dynamic - reportable");
             }
           else
             {
             PDU_list_size = 3;

             PDUfill_in_string(&PDU_value_list[0], "Static");
             PDUfill_in_string(&PDU_value_list[1], "Dynamic - file only");
             PDUfill_in_string(&PDU_value_list[2], "Dynamic - reportable");
             }
           /* load possible values */
           GRdelete_pull_down_list(PDU_catalog_pulldown);
           GRcreate_pull_down_list(PARAMETRIC_CATALOG_FORM,
                                   forms.parametric_catalog_form_id,
                                  SOURCE_ASSOC_GADGET, PDU_list_size, VIS_ROWS, 
                                   PDU_value_list, PDU_list_size, 1, 
                                   &PDU_catalog_pulldown);
           GRchange_pull_down_text(PDU_catalog_pulldown, PDU_value_list, 
                                   PDU_list_size);

           GRproc_pull_down_list(PDU_catalog_pulldown);
           }
        else if (col == 4)
           {
           _pdm_debug("user selected units column", 0);
           /* clear out old values */
           for (i = 0; i < PDU_list_size; i++)
             PDUfill_in_string(&PDU_value_list[i], "");
          
           PDU_list_size = 4;

           PDUfill_in_string(&PDU_value_list[0], "inch");
           PDUfill_in_string(&PDU_value_list[1], "mm");
           PDUfill_in_string(&PDU_value_list[2], "degree");
           PDUfill_in_string(&PDU_value_list[3], "constant");

           /* load possible values */
           GRdelete_pull_down_list(PDU_tempcat_pulldown);
           GRcreate_pull_down_list(PARAMETRIC_CATALOG_FORM,
                                   forms.parametric_catalog_form_id,
                                   UNITS_ASSOC_GADGET, PDU_list_size, VIS_ROWS, 
                                   PDU_value_list, PDU_list_size, 1, 
                                   &PDU_tempcat_pulldown);
           GRchange_pull_down_text(PDU_tempcat_pulldown, PDU_value_list, 
                                   PDU_list_size);

           GRproc_pull_down_list(PDU_tempcat_pulldown);
           }

         break;

    case PARM_CAT_DESCR:     /* Sequenced to     */
                             /* Field Type:    ASCII    */
         break;

    case SKETCH_FILE:         /* Field Type:    ASCII    */

          /* Get the text string */

         FIfld_get_text_length(fp,SKETCH_FILE,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         status = FIfld_get_text(fp,SKETCH_FILE,0,0,length,
                                 (unsigned char*)text,&select,&pos);

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */
              msg  = (char *)PDUtranslate_message(PDM_E_FILENAME_FORM);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              break;
            }

          /* Code to process text string "text" */
          PDUfill_in_string(&PDU_sketch_file, text);


         break;

  case MACNAME_ASSOC_GADGET:

         list_row = value - 1;
         FIfld_set_text(fp, MACRO_NAME, 0,0,PDU_value_list[list_row], FALSE);
         PDUfill_in_string(&PDU_macro_name, PDU_value_list[list_row]);

          /* get macro list from macro library */
          
           responses[0] = EX_CMD_KEY;

           strings[0] = "PDGtMcPm";

           status = PDUprepare_queue ( responses, strings, 1 );
           _pdm_status("PDUprepare_queue (delete catalog)",status);

         break;

  case SOURCE_ASSOC_GADGET:

         list_row = value - 1;
         FIfld_set_text(fp, MACRO_ATTR_MCF, act_row,2,PDU_value_list[list_row],
                         FALSE);

         break;

  case UNITS_ASSOC_GADGET:

         list_row = value - 1;
         FIfld_set_text(fp, MACRO_ATTR_MCF, act_row,4,PDU_value_list[list_row],
                         FALSE);

         break;

  case DEF_SUP_LIB:

       FIf_erase(fp);
       PDUdefine_library_form();

       break;

  case CHKIN_MAC_LIB:
 
       break;

  } /* END switch ( g_label ) */
  return(1);
} /* END notification_routine() */

int parametric_catalog_form()
{
  int  status;
  char *msg;

  status = FIf_new(PARAMETRIC_CATALOG_FORM, "MOAddPrt",
                parm_cat_notification_routine,
                &forms.parametric_catalog_form_id);

  _pdm_debug("Creating Catalog Name Form", 0);

  /* initialize global variables */
  if ((PDU_macro_library) && (strcmp(PDU_macro_library, "") != 0))
    PDUfill_in_string(&PDU_macro_library, NULL);

  if ((PDU_macro_name) && (strcmp(PDU_macro_name, "") != 0))
    PDUfill_in_string(&PDU_macro_name, NULL);

  PDU_macro_dyn_num = 0;
  status = PDUvalid_catalog("", refresh->rev_catalog);
  _pdm_status("PDUvalid_catalog", status);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(PDM_S_SUCCESS, 's');
    FIg_disable(forms.parametric_catalog_form_id, DEF_SUP_LIB);
    }

  /* create GRpulldowns */
  PDU_list_size = 0;
  GRcreate_pull_down_list(PARAMETRIC_CATALOG_FORM,
                          forms.parametric_catalog_form_id,
                          MACNAME_ASSOC_GADGET, MAX_ROWS, VIS_ROWS, 
                         PDU_value_list, PDU_list_size, 1, &PDU_value_pulldown);

  GRcreate_pull_down_list(PARAMETRIC_CATALOG_FORM,
                          forms.parametric_catalog_form_id,
                          SOURCE_ASSOC_GADGET, MAX_ROWS, VIS_ROWS, 
                       PDU_value_list, PDU_list_size, 1, &PDU_catalog_pulldown);

  GRcreate_pull_down_list(PARAMETRIC_CATALOG_FORM,
                          forms.parametric_catalog_form_id,
                          UNITS_ASSOC_GADGET, MAX_ROWS, VIS_ROWS, 
                       PDU_value_list, PDU_list_size, 1, &PDU_tempcat_pulldown);


  PDU_form_id = forms.parametric_catalog_form_id;

  if ((refresh->rev_catalog != NULL) && (strcmp(refresh->rev_catalog,"") != 0))
    FIg_set_text(forms.parametric_catalog_form_id, PARM_CAT_NAME, 
                 refresh->rev_catalog);

  if ((PDU_cat_description != NULL) && (strcmp(PDU_cat_description, "") != 0))
    FIg_set_text(forms.parametric_catalog_form_id, PARM_CAT_DESCR, 
                 PDU_cat_description);

  if (PDU_checkin_lib)
    FIg_set_state_off(forms.parametric_catalog_form_id, CHKIN_MAC_LIB);
  else
    FIg_set_state_on(forms.parametric_catalog_form_id, CHKIN_MAC_LIB);

  if (PDU_command == PDC_M_MODIFY_CATALOG)
    {
    FIg_disable(forms.parametric_catalog_form_id, MACRO_NAME);
    FIg_disable(forms.parametric_catalog_form_id, MACRO_LIBRARY);
    FIg_erase(forms.parametric_catalog_form_id, CHKIN_MAC_LIB);
    FIfld_set_mode(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 0, 
                   FI_REVIEW);
    FIfld_set_mode(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 1, 
                   FI_REVIEW);
    FIfld_set_mode(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 2, 
                   FI_REVIEW);
    if (PDU_parameter_buffer)
      {
      MEMclose(&PDU_parameter_buffer);
      PDU_parameter_buffer = NULL;
      }
    status = PDMget_macro_parameters(refresh->rev_catalog, &PDU_macro_buffer, 
                                     &PDU_parameter_buffer);
    _pdm_status("PDMget_macro_paraemeters", status);

    if (status != PDM_S_SUCCESS)
     {
      msg = (char *)PDUtranslate_message(PDM_E_PARAMETERS_DB);
      FIg_set_text(forms.parametric_catalog_form_id, FI_MSG_FIELD, msg);
     }
    else
      {
      FIfld_set_mode(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 0, 
                     FI_REVIEW);
      FIfld_set_mode(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 1, 
                     FI_REVIEW);
      if (PDM_debug_on) 
         MEMprint_buffer("macro buffer", PDU_macro_buffer,
                               PDU_DEBUG_FILE);

      status = PDUload_parametric_catalog_form(PDU_macro_buffer, 
                                            PDU_parameter_buffer);
      _pdm_status("PDUload_parametric_catalog_form", status);
      }
    }
  _pdm_debug("Displaying the Parametric Catalog Form", 0);

  status = FIf_display(forms.parametric_catalog_form_id);

  return(status);

}



int PDUparametric_catalog_form()

{
  int status;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  status = parametric_catalog_form();
  _pdm_status("parametric_catalog_form", status);

  if (status == FI_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
 }

int PDUload_parametric_attributes(attr_bufr, data_bufr, dyn_attr, dyn_data,
                                  gadget_label)

MEMptr *attr_bufr;
MEMptr *data_bufr;
MEMptr *dyn_attr;
MEMptr *dyn_data;
int    gadget_label;

  {
  int length;
  int select;
  int pos;
  int status = PDM_S_SUCCESS;
  long status1;
  int rows;
  int num_rows;
  int i;
  char *attr_name = NULL;
  char *datatype = NULL;
  char *type_attr = NULL;
  char *synonym = NULL;
  char *text = NULL;
  char *row = NULL;

  _pdm_debug("In PDUload_parametric_attributes", 0);

  row = (char *)malloc((*attr_bufr)->row_size);
  memset(row, NULL, (*attr_bufr)->row_size);

  FIfld_get_num_rows(forms.parametric_catalog_form_id, gadget_label, &rows);
  _pdm_debug("Num rows = %d", (char *)rows);
  
  for (i = 0; i < rows; i ++)
    {
    FImcf_set_active_col(forms.parametric_catalog_form_id, gadget_label, 0,0);
    FIfld_set_active_row(forms.parametric_catalog_form_id, gadget_label, i,i);
    FIfld_get_text_length(forms.parametric_catalog_form_id,gadget_label,i,0,
                          &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.parametric_catalog_form_id,gadget_label,i,0,length,
                   (unsigned char*)text, &select, &pos);

    if (text == NULL)
      break;
    else if (strcmp(text, "") == 0)
      break;
    else
      PDUfill_in_string(&attr_name, text);

    FImcf_set_active_col(forms.parametric_catalog_form_id, gadget_label, 1,1);
    FIfld_get_text_length(forms.parametric_catalog_form_id,gadget_label,i,1,
                          &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.parametric_catalog_form_id,gadget_label,i,1,length,
                   (unsigned char*)text, &select, &pos);
    if (text == NULL)
      break;
    else if (strcmp(text, "") == 0)
      break;
    else
      {
      status = PDUconvert_parametric_datatype(text, &datatype);
      _pdm_status("PDUconvert_parametric_datatype", status);
      _pdm_debug("datatype = <%s>", datatype);
      }

    FImcf_set_active_col(forms.parametric_catalog_form_id, gadget_label, 2,2);
    FIfld_get_text_length(forms.parametric_catalog_form_id,gadget_label,i,2,
                          &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.parametric_catalog_form_id,gadget_label,i,2,length,
                   (unsigned char*)text, &select, &pos);
    if (text == NULL)
      break;
    else if (strcmp(text, "") == 0)
      break;
    else
      PDUfill_in_string(&type_attr, text);

    FImcf_set_active_col(forms.parametric_catalog_form_id, gadget_label, 3,3);
    FIfld_get_text_length(forms.parametric_catalog_form_id,gadget_label,i,3,
                          &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.parametric_catalog_form_id,gadget_label,i,3,length,
                   (unsigned char*)text, &select, &pos);
    if (text == NULL)
      PDUfill_in_string(&synonym, attr_name);
    else if (strcmp(text, "") == 0)
      PDUfill_in_string(&synonym, attr_name);
    else
      PDUfill_in_string(&synonym, text);

     /* by type_attr, determine which buffer to write to */
     if ((strcmp(type_attr, "Static") == 0) && (!PDU_view))
       {
       _pdm_debug("attribute is static", 0);
       num_rows = (*attr_bufr)->rows + 1;
       sprintf(row,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1\1",
       attr_name,datatype,synonym,"PDM","Y","Y","Y","N","Y",num_rows,"0");
       _pdm_debug("row = %s", row);
       status1 = MEMwrite(*attr_bufr, row);
       _pdm_status("MEMwrite", status1);

       if (status1 != MEM_S_SUCCESS)
         {
         status = PDM_E_WRITE_BUFFER;
         break;
         }
       }
     else if (strcmp(type_attr, "Dynamic - reportable") == 0)
       {
        _pdm_debug("attribute is dynamic - reportable", 0);
       if (*dyn_attr == NULL)
         {
         status = PDUcreate_dynamic_attr_buffr(dyn_attr);
         _pdm_status("PDUcreate_dynamic_attr_buffr", status);

         if (status != PDM_S_SUCCESS)
           return(status);
         sprintf(row,
                 "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1\1",
                "p_pdcno","integer","Pdc No","PDM","N","N","N","N","N","1","0");
         status = MEMwrite(*dyn_attr, row); 
         _pdm_status("MEMwrite", status);

         if (status != MEM_S_SUCCESS)
           return(PDM_E_WRITE_BUFFER);

         memset(row, NULL, (*attr_bufr)->row_size);
         }
       num_rows = (*dyn_attr)->rows + 1;
       if (((*dyn_attr)->columns > 16) && (gadget_label == MACRO_ATTR_MCF))
         sprintf(row,
         "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1%s\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1",
       attr_name,datatype,synonym,"PDM","Y","Y","Y","N","Y",num_rows,"0", "0");
       else if ((*dyn_attr)->columns > 16)
         sprintf(row,
         "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1%s\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1",
       attr_name,datatype,synonym,"PDM","Y","N","Y","N","Y",num_rows,"0", "0");
       else if (gadget_label == MACRO_ATTR_MCF)
         sprintf(row,
         "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1\1",
       attr_name,datatype,synonym,"PDM","Y","Y","Y","N","Y",num_rows,"0");
       else 
         sprintf(row,
         "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1\1",
       attr_name,datatype,synonym,"PDM","Y","N","Y","N","Y",num_rows,"0");
       _pdm_debug("row = %s", row);
       status = MEMwrite(*dyn_attr, row);
       _pdm_status("MEMwrite", status);

       if (status != MEM_S_SUCCESS)
         {
         status = PDM_E_WRITE_BUFFER;
         break;
         }
       PDUfill_in_string(&PDU_macro_dyn_list[PDU_macro_dyn_num], attr_name);
       PDU_macro_dyn_num = PDU_macro_dyn_num + 1;
       }
     else
         {
        _pdm_debug("attribute is dynamic - file only", 0);
        PDUfill_in_string(&PDU_macro_dyn_list[PDU_macro_dyn_num], attr_name);
        PDU_macro_dyn_num = PDU_macro_dyn_num + 1;
        }

      memset(row, NULL, (*attr_bufr)->row_size);
      status = PDM_S_SUCCESS;
      }
  if (row)
    free(row);

  if (status != PDM_S_SUCCESS)
    return(status);

  /* update data buffers with new attribute */
  status = PDUupdate_data_buffer(data_bufr, *attr_bufr);
  _pdm_status("PDUupdate_data_buffer", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  if (*dyn_attr)
  {
  status = PDUupdate_data_buffer(dyn_data, *dyn_attr);
  _pdm_status("PDUupdate_data_buffer", status);
  }

  return(status);
  }

int PDUload_macro_parameters()

  {
  int status;
  int i, j;
  int char_index = 0;
  int length;
  int select;
  int pos;
  char *row = NULL;
  char *text = NULL;
  char *parameter = NULL;
  char *datatype = NULL;
  char *synonym = NULL;
  char *units = NULL;
  char *iotype = NULL; 
  char *type = NULL; 

  _pdm_debug("PDUload_parameters", 0);

  if (PDU_parameter_buffer)
    {
    MEMclose(&PDU_parameter_buffer);
    PDU_parameter_buffer = NULL;
    }

  status = PDUformat_parameter_buffer(&PDU_parameter_buffer);
  _pdm_status("PDUformat_parameter_buffer", status);

  if (PDM_debug_on) 
      MEMprint_buffer("parameter buffer", PDU_parameter_buffer,
                       PDU_DEBUG_FILE);

  row = (char *)malloc(PDU_parameter_buffer->row_size);
  for (i = 0; i < PDU_num_temp; i++)
   {
   memset(row, NULL, PDU_parameter_buffer->row_size);
   char_index = 0;
   PDUadd_buffer_string(row, &char_index, refresh->rev_catalog);
   _pdm_debug("setting active row", 0);
   FIfld_set_active_row(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, i, i);
   for (j = 0; j < 5; j ++)
     {
     _pdm_debug("setting active col", 0);
     FImcf_set_active_col(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 
                          j, j);
     _pdm_debug("getting text", 0);
    FIfld_get_text_length(forms.parametric_catalog_form_id,MACRO_ATTR_MCF,i,j,
                          &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.parametric_catalog_form_id,MACRO_ATTR_MCF,i,j,length,
                   (unsigned char*)text, &select, &pos);
     if (j == 0)
       PDUfill_in_string(&parameter, text);
     else if (j == 1)
       PDUfill_in_string(&datatype, text);
     else if (j == 2)
       PDUfill_in_string(&type, text);
     else if (j == 3)
       PDUfill_in_string(&synonym, text);
     else if (j == 4)
       PDUfill_in_string(&units, text);
     }
   _pdm_debug("char_index = %d", (char *)char_index);
   _pdm_debug("synonym = %s", synonym);
   if ((synonym) && (strcmp(synonym, "") != 0))
     PDUadd_buffer_string(row, &char_index, synonym);
   else 
     row[char_index++] = '\1';

   _pdm_debug("char_index = %d", (char *)char_index);
   _pdm_debug("parameter = %s", parameter);
    if ((parameter) && (strcmp(parameter, "") != 0))
      PDUadd_buffer_string(row, &char_index, parameter);
    else
       row[char_index++] = '\1';

   _pdm_debug("char_index = %d", (char *)char_index);
   _pdm_debug("datatype = %s", datatype);
    if ((datatype) && (strcmp(datatype, "") != 0))
      PDUadd_buffer_string(row, &char_index, datatype);
    else
       row[char_index++] = '\1';

    PDUconvert_to_iotype(datatype, &iotype, type);
   
    if ((iotype) && (strcmp(iotype, "") != 0))
      PDUadd_buffer_string(row, &char_index, iotype);
    else
      row[char_index++] = '\1';

    if ((units) && (strcmp(units, "") != 0))
      PDUadd_buffer_string(row, &char_index, units);
    else
      row[char_index++] = '\1';

    _pdm_debug("row = <%s>", row);

    status = MEMwrite(PDU_parameter_buffer, row);
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
    }
  _pdm_debug("loading feet parameters", 0);

  /*for (i = PDU_num_temp; i < (PDU_num_temp + PDU_num_feet); i++)
   {
   memset(row, NULL, PDU_parameter_buffer->row_size);
   char_index = 0;
   PDUadd_buffer_string(row, &char_index, refresh->rev_catalog);
   FIfld_set_active_row(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, i, i);
   for (j = 0; j < 5; j ++)
     {
     FImcf_set_active_col(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 
                          j, j);
     FIfld_get_text_length(forms.parametric_catalog_form_id,MACRO_ATTR_MCF,i,j,
                           &length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL, sizeof (char) * length + 1);
     FIfld_get_text(forms.parametric_catalog_form_id,MACRO_ATTR_MCF,i,j,length,
                    (unsigned char*)text, &select, &pos);
     if (j == 0)
       PDUfill_in_string(&parameter, text);
     else if (j == 2)
       PDUfill_in_string(&datatype, text);
     else if (j == 3)
       PDUfill_in_string(&synonym, text);
     else if (j == 4)
       PDUfill_in_string(&units, text);
     }
   if ((synonym) && (strcmp(synonym, "") != 0))
     PDUadd_buffer_string(row, &char_index, synonym);
   else 
     row[char_index++] = '\1';

    if ((parameter) && (strcmp(parameter, "") != 0))
      PDUadd_buffer_string(row, &char_index, parameter);
    else
       row[char_index++] = '\1';

    if ((datatype) && (strcmp(datatype, "") != 0))
      PDUadd_buffer_string(row, &char_index, datatype);
    else
       row[char_index++] = '\1';

    PDUconvert_to_iotype(datatype, &iotype);
    _pdm_debug("iotype = <%s>", iotype);
   
    if ((iotype) && (strcmp(iotype, "") != 0))
      PDUadd_buffer_string(row, &char_index, iotype);
    else
      row[char_index++] = '\1';

    if ((units) && (strcmp(units, "") != 0))
      PDUadd_buffer_string(row, &char_index, units);
    else
      row[char_index++] = '\1';

    _pdm_debug("row = <%s>", row);

    status = MEMwrite(PDU_parameter_buffer, row);
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
    }*/

  return(PDM_S_SUCCESS);
  }

int PDUload_map_buffer(buffer)

MEMptr *buffer;

  {
  int status;
  int char_index = 0;
  char *row = NULL;
  
  _pdm_debug("In PDUload_map_buffer", 0);

  status = PDUformat_macro_buffer(buffer);
  _pdm_status("PDUformat_macro_buffer", status);

  row = (char *)malloc((*buffer)->row_size);
  memset(row, NULL, (*buffer)->row_size);

  PDUadd_buffer_string(row, &char_index, refresh->rev_catalog);
  PDUadd_buffer_string(row, &char_index, PDU_macro_catalog);
  PDUadd_buffer_string(row, &char_index, PDU_macro_partid);
  PDUadd_buffer_string(row, &char_index, PDU_macro_partrev);
  PDUadd_buffer_string(row, &char_index, PDU_macro_name);
  if ((PDU_sketch_file) && (strcmp(PDU_sketch_file, "") != 0))
   PDUadd_buffer_string(row, &char_index, PDU_sketch_file);
  else
    row[char_index++] = '\1';

  _pdm_debug("row = <%s>", row);

  status = MEMwrite(*buffer, row);
  _pdm_status("MEMwrite", status);

  if (status != PDM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);
  
  return(PDM_S_SUCCESS);
  }

int PDUupdate_parametric_catalog_form()

  {
  int status;
  int cat_length;
  int part_length;
  int rev_length;
  int str_length;
  char *text = NULL;
  char **ret_data = NULL;
  extern MEMptr PDU_ret_bufr;
  char *msg;

  _pdm_debug("in PDUupdate_parametric_catalog_form", 0);

  /*
   * TR# 139422665. 02/Dec/94 - raj. Begin.
   * Edited macro definition is written to the macro library during
   * create catalog command. Error out if macro library is not writable.
   */
  status = PDUis_maclib_writable(refresh->rev_filename);
  if (!(status &1))
  {
    char	msgstr[256];
     
    PDUtranslate_UMS_message(PDM_E_MLIB_READ_ONLY, msgstr, NULL);
    FI_msg_box("WARNING",FI_YELLOW, msgstr, FI_BLACK);

    /* Erase the displayed form */
    GRdelete_pull_down_list(PDU_value_pulldown);
    GRdelete_pull_down_list(PDU_catalog_pulldown);

    FIf_delete (forms.parametric_catalog_form_id);
    forms.parametric_catalog_form_id = 0;

    if ((PDU_command == PDC_M_CREATE_CATALOG) &&
         (refresh->rev_catalog) &&
          (strcmp(refresh->rev_catalog, "") != 0))
            PDUfill_in_string(&refresh->rev_catalog, "");

    PDUcatalog_name_form();

    return(PDM_E_FAILURE);
  }
  /* TR# 139422665. 02/Dec/94 - raj. End.	*/

  FIg_set_text(forms.parametric_catalog_form_id, FI_MSG_FIELD, "");
  if (( refresh->rev_catalog == NULL) || (refresh->rev_partid == NULL) || 
      (refresh->rev_revision == NULL))
    {
   FIf_display(forms.parametric_catalog_form_id);
    return(PDM_S_SUCCESS);
    }
  else if ((strcmp(refresh->rev_catalog, "") == 0) || 
           (strcmp(refresh->rev_partid , "") == 0) ||
           (strcmp(refresh->rev_revision, "") == 0))
    {
    FIf_display(forms.parametric_catalog_form_id);
    return(PDM_S_SUCCESS);
    }
    
  cat_length = strlen(refresh->rev_catalog);
  part_length = strlen(refresh->rev_partid);
  rev_length = strlen(refresh->rev_revision);
  str_length = cat_length + part_length + rev_length + 5;
  text = (char *) malloc(str_length);
  memset(text, NULL, str_length);

  sprintf(text, "%s:%s:%s", refresh->rev_catalog, refresh->rev_partid, 
          refresh->rev_revision);

  FIfld_set_text(forms.parametric_catalog_form_id, MACRO_LIBRARY, 0,0,text, 
                 FALSE);
  FIg_enable(forms.parametric_catalog_form_id, DEF_SUP_LIB);
  PDUfill_in_string(&PDU_macro_catalog, refresh->rev_catalog);
  PDUfill_in_string(&PDU_macro_partid, refresh->rev_partid);
  PDUfill_in_string(&PDU_macro_partrev, refresh->rev_revision);
  PDUfill_in_string(&PDU_macro_library, refresh->rev_filename);
  PDUfill_in_string(&refresh->rev_catalog, PDU_store_catalog);
  if (PDU_ret_bufr)
    {
    MEMclose(&PDU_ret_bufr);
    PDU_ret_bufr = NULL;
    }
  status = PDMget_pt_desc(PDU_macro_catalog, PDU_macro_partid, 
                          PDU_macro_partrev);
  _pdm_status("PDMget_pt_desc", status);
  if ((status != PDM_S_SUCCESS) || (PDU_ret_bufr == NULL))
    {
    FIf_display(forms.parametric_catalog_form_id);
    return(PDM_S_SUCCESS);
    }

    if (PDM_debug_on)
    MEMprint_buffer("description", PDU_ret_bufr, PDU_DEBUG_FILE);

  status = MEMbuild_array(PDU_ret_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    {
    FIf_display(forms.parametric_catalog_form_id);
    return(PDM_S_SUCCESS);
    }

  ret_data = (char **)PDU_ret_bufr->data_ptr;

  PDUfill_in_string(&refresh->rev_description, ret_data[1]);
  PDUfill_in_string(&refresh->rev_parttype, ret_data[0]);
 if ((strcmp(refresh->rev_parttype, "M") != 0) && 
      (strcmp(refresh->rev_parttype, "m") != 0))
    {
    _pdm_debug("Part must have parttype of M", 0);
    msg = (char *)PDUtranslate_message(PDM_E_PARTTYPE_M);
    FIg_set_text(forms.parametric_catalog_form_id, FI_MSG_FIELD, msg);
    FIf_display(forms.parametric_catalog_form_id);
    PDUfill_in_string(&PDU_macro_catalog, NULL);
    PDUfill_in_string(&PDU_macro_partid, NULL);
    PDUfill_in_string(&PDU_macro_partrev, NULL);
    PDUfill_in_string(&PDU_macro_library, NULL);
    FIfld_set_text(forms.parametric_catalog_form_id, MACRO_LIBRARY, 0,0,"", 
                   FALSE);
    FIg_disable(forms.parametric_catalog_form_id, DEF_SUP_LIB);
    return(PDM_S_SUCCESS);
    }
 FIf_display(forms.parametric_catalog_form_id);
  return(PDM_S_SUCCESS);
  }

int PDUload_parametric_catalog_form(macro_buffer, parm_buffer)

MEMptr macro_buffer;
MEMptr parm_buffer;

  {
  int status;
  int i;
  int text_length = 0;
  char *text = NULL;
  char **macro_data = NULL;
  char **parm_data = NULL;

  _pdm_debug("PDUload_parametric_part_form", 0);

  status = MEMbuild_array(macro_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(status);

  macro_data = (char **)macro_buffer->data_ptr;
  PDUfill_in_string(&PDU_macro_catalog, macro_data[1]);
  PDUfill_in_string(&PDU_macro_partid, macro_data[2]);
  PDUfill_in_string(&PDU_macro_partrev, macro_data[3]);
  PDUfill_in_string(&PDU_macro_name, macro_data[4]);
  PDUfill_in_string(&PDU_sketch_file, macro_data[5]);

  _pdm_debug("PDU_macro_name = <%s>", PDU_macro_name);
  _pdm_debug("PDU_sketch_file = <%s>", PDU_sketch_file);
  text_length = strlen(PDU_macro_catalog) + strlen(PDU_macro_partid) + 
                strlen(PDU_macro_partrev) + 5;
  _pdm_debug("length = <%d>", (char *)text_length);

  text = (char *)malloc(text_length);
  memset(text, NULL, text_length);

  sprintf(text, "%s:%s:%s", PDU_macro_catalog, PDU_macro_partid, 
          PDU_macro_partrev);
  _pdm_debug("text = <%s>", text);

  FIfld_set_text(forms.parametric_catalog_form_id, MACRO_LIBRARY, 0,0,text, 
                 FALSE);
  FIfld_set_text(forms.parametric_catalog_form_id, MACRO_NAME, 0,0,
                 PDU_macro_name, 
                 FALSE);
  FIg_set_text(forms.parametric_catalog_form_id, SKETCH_FILE,
                 PDU_sketch_file);

  _pdm_debug("process parameters", 0);

  status = MEMbuild_array(parm_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(status);

  parm_data = (char **)parm_buffer->data_ptr;

  for (i = 0; i < parm_buffer->rows; i++)
   {
   FIfld_set_text(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, i, 0, 
                  parm_data[(parm_buffer->columns * i) + 2], FALSE);
   FIfld_set_text(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, i, 1, 
                  parm_data[(parm_buffer->columns * i) + 3], FALSE);
   FIfld_set_text(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, i, 3, 
                  parm_data[(parm_buffer->columns * i) + 1], FALSE);
   FIfld_set_text(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, i, 4, 
                  parm_data[(parm_buffer->columns * i) + 5], FALSE);
   }
  return(PDM_S_SUCCESS);
  }

int PDUchange_parameters()

  {
  int length;
  int select;
  int pos;
  int status = PDM_S_SUCCESS;
  int i; 
  int num_rows;
  char *text = NULL;

  _pdm_debug("In PDUchange_parameters", 0);

  status = MEMbuild_array(PDU_macro_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(status);

  if ((PDU_sketch_file) && (strcmp(PDU_sketch_file, "") != 0))
    {
    status = MEMwrite_data(PDU_macro_buffer, PDU_sketch_file, 1, 6);
    _pdm_status("MEMwrite_data", status);

    if (status != MEM_S_SUCCESS)
      return(status);
     }
  else
    {
    status = MEMwrite_data(PDU_macro_buffer, "", 1, 6);
    _pdm_status("MEMwrite_data", status);

    if (status != MEM_S_SUCCESS)
      return(status);
     }

  FIfld_get_num_rows(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 
                     &num_rows);
  _pdm_debug("num_rows = <%d>", (char *)num_rows);

  status = MEMbuild_array(PDU_parameter_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(status);
  for (i = 0; i < num_rows; i ++)
    {
   FIfld_set_active_row(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, i, i);
    FImcf_set_active_col(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 3,3);
    FIfld_get_text_length(forms.parametric_catalog_form_id,MACRO_ATTR_MCF,i,3,
                          &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.parametric_catalog_form_id,MACRO_ATTR_MCF,i,3,length,
                   (unsigned char*)text, &select, &pos);

    if (text != NULL)
      {
      status = MEMwrite_data(PDU_parameter_buffer, text, (i + 1), 2);
      _pdm_status("MEMwrite_data", status);

      if (status != MEM_S_SUCCESS)
        return(status);
      }
    FImcf_set_active_col(forms.parametric_catalog_form_id, MACRO_ATTR_MCF, 4,4);
    FIfld_get_text_length(forms.parametric_catalog_form_id,MACRO_ATTR_MCF,i,4,
                          &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.parametric_catalog_form_id,MACRO_ATTR_MCF,i,4,length,
                   (unsigned char*)text, &select, &pos);
    if (text != NULL)
      {
      status = MEMwrite_data(PDU_parameter_buffer, text, (i + 1), 6);
      _pdm_status("MEMwrite_data", status);

      if (status != MEM_S_SUCCESS)
        return(status);
      }
    }

  return(PDM_S_SUCCESS);
  }

int PDUmodify_parametric_synonym(cat_attr, dyn_attr)

  MEMptr *cat_attr;
  MEMptr *dyn_attr;

  {
  int status = PDM_S_SUCCESS;
  int i; 
  int attr_row = -1;
  char **parm_data = NULL;
  char **cat_data = NULL;

  _pdm_debug("In PDUmodify_parametric_syn", 0);

  status = MEMbuild_array(PDU_parameter_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(status);

  status = MEMbuild_array(*cat_attr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(status);

  parm_data = (char **)PDU_parameter_buffer->data_ptr;
  cat_data = (char **)(*cat_attr)->data_ptr;

  if (*dyn_attr)
  {
  status = MEMbuild_array(*dyn_attr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(status);
  }
  for (i = 0; i < PDU_parameter_buffer->rows; i ++)
    {
    attr_row = PDUfind_attr_in_buffer(*cat_attr, 
                           parm_data[(PDU_parameter_buffer->columns * i) + 2]);
    _pdm_debug("attr_row = <%d>", (char *)attr_row);
    if (attr_row != -1)
    {
    if (PDU_command == PDC_M_MODIFY_CATALOG)
    {
    status = MEMwrite_data(*cat_attr, parm_data[(PDU_parameter_buffer->columns *
                           i) + 1], (attr_row + 1), (PDU_NFM_SYN_COL + 
                           PDU_NFM_MOD_OFFSET + 1));
    _pdm_status("MEMwrite_data", status);
    }
    else
    {
    status = MEMwrite_data(*cat_attr, parm_data[(PDU_parameter_buffer->columns *
                           i) + 1], (attr_row + 1), (PDU_NFM_SYN_COL + 1));
    _pdm_status("MEMwrite_data", status);
    }
    }
    else if (*dyn_attr)
    {
    attr_row = PDUfind_attr_in_buffer(*dyn_attr, 
                           parm_data[(PDU_parameter_buffer->columns * i) + 2]);
    _pdm_debug("attr_row = <%d>", (char *)attr_row);
    if (attr_row != -1)
    {
    if (PDU_command == PDC_M_MODIFY_CATALOG)
    {
    status = MEMwrite_data(*dyn_attr, parm_data[(PDU_parameter_buffer->columns *
                           i) + 1], (attr_row + 1), (PDU_NFM_SYN_COL + 
                           PDU_NFM_MOD_OFFSET + 1));
    _pdm_status("MEMwrite_data", status);
    }
    else
    {
    status = MEMwrite_data(*dyn_attr, parm_data[(PDU_parameter_buffer->columns *
                           i) + 1], (attr_row + 1), (PDU_NFM_SYN_COL + 1));
    _pdm_status("MEMwrite_data", status);
    }
    }
    }
    else
    {
    _pdm_debug("attribute must be file only", 0);
    status = MEM_S_SUCCESS;
    }
    if (status != MEM_S_SUCCESS)
      return(status);
    }
  return(PDM_S_SUCCESS);
  }
