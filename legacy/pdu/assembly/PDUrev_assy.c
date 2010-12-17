#include "stdio.h"
#include "string.h"
#include "PDUproto.h"
#include "PDMproto.h"
#include "PDUform_def.h"
#include "PDUforms.h"
#include "PDUextdef.h"
#include "PDUerror.h"
#include "MEMerrordef.h"
#include "PDUstorage.h"
#include "PDMdebug.h"
#include "PDUfile_def.h"
#include "PDUstr.h"
#include "PDUrev_str.h"
#include "FI.h"
#include "NFMerrordef.h"
#include "PDMtypes.h"
#include "PDMmessage.h"
#include "PDUcommand.h"
#include "exdef.h"


/* Gadgets for Revise Assembly */

#define REV_MCF       11
#define SEARCH_BTN    29
#define COPY_BTN      30
#define PLACE_BTN     31
#define DEL_BTN       32
#define UNDEL_BTN     33
#define SUFFIX_FLD    34
#define SUFFIX_TGL    40
#define PLCMT_OPTS    41 
#define UPDATE_ASSY   42 


/* Gadgets for attribute form */

#define CAT_FLD       14
#define PART_FLD      15
#define REV_FLD       16 
#define ATTR_MCF      18
#define VALUE_LIST    21 

/* columns in MCF */

#define EXLEV_COL      0
#define DISPEXT_COL    5
#define NEWLEV_COL     6
#define CAT_COL        7
#define PART_COL       8
#define REV_COL        9
#define DESC_COL      10
#define LOCFILE_COL   11
#define STGFILE_COL   12
#define DISPNEW_COL   13

/* gadgets for active part form */
#define ACT_CAT		34
#define ACT_PART	35
#define ACT_REV		36
#define ACT_DESC	12
#define IN_TEXT		15
#define OUT_TEXT	11
#define ADD_TEXT	14
#define COPY_TEXT	16
#define PLACE_TEXT	17
#define CANCEL_TEXT	18
#define DELETE_TEXT	19


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FIg_get_text_length();
extern int FIg_get_text();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();

extern int PDU_local_files_displayed;
extern int PDU_save_level;
extern int PDU_explode_depth;
extern int review_mode;
extern int change_mode;
extern int bufr_flag;
extern int PDM_debug_on;
extern int PDU_value_pulldown;
extern int PDU_load_search_data;
extern int PDU_command;
extern int PDU_func_bufr_exists;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_func_buffer;
extern MEMptr PDUsearch_part_list;
extern MEMptr PDU_attr_bufr;
extern MEMptr PDU_data_bufr;
extern MEMptr PDU_list_bufr;
extern MEMptr PDU_parm_attr_bufr;
extern MEMptr PDU_parm_data_bufr;
extern MEMptr PDU_parm_list_bufr;
extern struct PDUrefresh *refresh; 
extern struct PDUrev_assy *PDU_assy_ptr;  /* Top ptr to link list */
extern struct PDUrev_assy *PDU_save_ptr;  /* Copy of assy link list */
extern struct PDUstorage *storage;
extern struct PDUforms forms;
extern long PDU_display_attr_in_mcf();
extern long PDUget_part_bufrs();
extern Form PDU_form_id;
extern Form PDU_calling_form;
extern short PDU_main_form_cat;
extern short PDU_use_suffix;
extern short PDU_attach;
extern short PDU_os_modified;
extern short PDU_new_assembly;
extern char  *PDU_value_list[605];
extern char  *PDU_save_catalog;
extern char  *PDU_save_partid;
extern char  *PDU_save_revision;
extern char  *PDU_save_description;
extern char  *PDU_save_filename;
extern char  *PDU_save_act_filename;
extern char  *PDU_file_suffix;
extern char  *PDU_quantity;
extern char  *PDU_usage_id;
extern char  *PDU_alt_tagno;
extern char  *PDU_incl_BOM;
extern char  *PDU_incl_ASM;
extern char  *PDU_explode_BOM;
extern struct PDUrev_assy *current_rev_assy;
extern struct PDUparts_list *PDU_save_part_list;
extern struct PDUparts_list *PDU_checked_out_parts;
extern struct PDUassy_parts_list *PDU_modified_parts_list;
extern struct PDUfile_list *PDU_copied_files;
 

int compare_parts(cat1,part1,rev1,cat2,part2,rev2)
char *cat1,*part1,*rev1,*cat2,*part2,*rev2;
{
  _pdm_debug("in the function compare_parts", 0);

  if ((strcmp(cat1,cat2) != 0) ||
     ((strcmp(cat1,cat2) == 0) && (strcmp(part1,part2) != 0)) ||
     ((strcmp(cat1,cat2) == 0) && (strcmp(part2,part2) == 0) &&
      (strcmp(rev1,rev2) != 0)))
        {
        _pdm_debug("returning DIFFERENT", 0);
        return(1);  /* different */
        }
  else
      {
      _pdm_debug("parts are the SAME", 0);
      return(0);  
      }
}

long PDUcheck_nesting(assy_ptr,working_ptr)
struct PDUrev_assy *assy_ptr, *working_ptr;
{
  struct PDUrev_assy *top_ptr;

  _pdm_debug("in the function PDUcheck_nesting", 0);

  top_ptr = assy_ptr;
  while (top_ptr)
  {
    if (working_ptr->mcf_row != top_ptr->mcf_row)
     {
       if (compare_parts(top_ptr->new_catalog,
                         top_ptr->new_partid,
                         top_ptr->new_revision,
                         working_ptr->ex_catalog,
                         working_ptr->ex_partid,
                         working_ptr->ex_revision) == 0)
       {
          _pdm_debug("same part was nested", 0);
          PDUfill_in_string(&top_ptr->new_catalog,working_ptr->new_catalog);
          PDUfill_in_string(&top_ptr->new_partid,working_ptr->new_partid);
          PDUfill_in_string(&top_ptr->new_revision,working_ptr->new_revision);
          PDUfill_in_string(&top_ptr->new_desc,working_ptr->new_desc);
          PDUfill_in_string(&top_ptr->new_cofilename,working_ptr->new_cofilename);
          PDUfill_in_string(&top_ptr->new_cifilename,working_ptr->new_cifilename);
          top_ptr->new_attr_data = working_ptr->new_attr_data;
          if (strcmp(top_ptr->display,"Y") == 0)
           {
             _pdm_debug("update mcf with new data", 0);
             FIfld_set_text(PDU_form_id,REV_MCF,working_ptr->mcf_row,CAT_COL,
                            top_ptr->new_catalog,FALSE); 
             FIfld_set_text(PDU_form_id,REV_MCF,working_ptr->mcf_row,PART_COL,
                            top_ptr->new_partid,FALSE); 
             FIfld_set_text(PDU_form_id,REV_MCF,working_ptr->mcf_row,REV_COL,
                            top_ptr->new_revision,FALSE); 
             FIfld_set_text(PDU_form_id,REV_MCF,working_ptr->mcf_row,DESC_COL,
                            top_ptr->new_desc,FALSE); 
             FIfld_set_text(PDU_form_id,REV_MCF,working_ptr->mcf_row,
                            LOCFILE_COL, top_ptr->new_cofilename,FALSE); 
             FIfld_set_text(PDU_form_id,REV_MCF,working_ptr->mcf_row,
                            STGFILE_COL, top_ptr->new_cifilename,FALSE); 
           }
       } 
     }
    top_ptr = top_ptr->next;  
  } 
 return(PDM_S_SUCCESS);
}

void PDUprint_attr_data_buffers(attrs)
struct PDUattr_data *attrs;
{
  _pdm_debug("in the function PDUprint_attr_data_buffers", 0);

  if (!PDMdebug_on)
    return;

  if (!attrs)
    {
    _pdm_debug("attr structure is NULL", 0);
    return;
    }

  _pdm_debug("printing buffers", 0);
  MEMprint_buffer("attr buffer", attrs->attr_bufr, PDU_DEBUG_FILE);
  MEMprint_buffer("data buffer", attrs->data_bufr, PDU_DEBUG_FILE);
  MEMprint_buffers("list buffer", attrs->list_bufr, PDU_DEBUG_FILE);
  MEMprint_buffer("func buffer", attrs->func_bufr, PDU_DEBUG_FILE);
}

void free_attr_data_buffer(attrs)
struct PDUattr_data **attrs;
{
  _pdm_debug("in the function free_attr_data_buffer", 0);

  _pdm_debug("freeing buffers", 0);
  if ((*attrs)->attr_bufr)
   {
     MEMclose(&(*attrs)->attr_bufr);
     (*attrs)->attr_bufr = NULL;
   }
  if ((*attrs)->data_bufr)
   {
     MEMclose(&(*attrs)->data_bufr);
     (*attrs)->data_bufr = NULL;
   }
  if ((*attrs)->list_bufr)
   {
     MEMclose(&(*attrs)->list_bufr);
     (*attrs)->list_bufr = NULL;
   }
  if ((*attrs)->func_bufr)
   {
     MEMclose(&(*attrs)->func_bufr);
     (*attrs)->func_bufr = NULL;
   }
}

int attr_value_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  long   status = PDM_S_SUCCESS;
  int 	i, length, select, pos, row;
  int	col = 0;
  int  	n_name_col = 0;
  int  	n_syn_col = 0;
  int   list_row = 0;
  int   act_row = 0;
  int   type_col = 0;
  int   stg_buffer_no = 0;
  int   valueno_col = 0;
  int   name_col = 0;
  char  stgno[5];
  char  *attr_value = NULL;
  char  *attribute = NULL;
  char  *attr_name = NULL;
  char  *str = NULL;
  char  *msg = NULL;
  char  **data_row;
  char  **dummy_row;
  char  **dummy_col;
  char  **dummy_format;
  short found = FALSE;
  struct PDUattr_data *new_attrs = NULL;
  extern void PDUdisplay_status();
  MEMptr attr_bufr = NULL;
  MEMptr list_bufr = NULL;
  MEMptr stg_bufr = NULL;

  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  PDU_form_id = fp;

  switch ( g_label )
  {
    case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */

         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("resetting global buffers", 0);
         if (PDU_attr_bufr)
           {
           MEMclose(&PDU_attr_bufr);
           PDU_attr_bufr = NULL;
           }
         if (PDU_data_bufr)
           {
           MEMclose(&PDU_data_bufr);
           PDU_data_bufr = NULL;
           }
         if (PDU_list_bufr)
           {
           MEMclose(&PDU_list_bufr);
           PDU_list_bufr = NULL;
           }

         if ((PDMdebug_on) && (current_rev_assy))
           {
           if (current_rev_assy->new_attr_data)
             {
             _pdm_debug("printing new_attr_data", 0);
             PDUprint_attr_data_buffers(current_rev_assy->new_attr_data);
             }
           if (current_rev_assy->ex_attr_data)
             {
             _pdm_debug("printing ex_attr_data", 0);
             PDUprint_attr_data_buffers(current_rev_assy->ex_attr_data);
             }
           }

         FIf_erase ( fp );
         FIf_reset ( fp );
         PDU_form_id = forms.rev_assy_form_id;
         FIf_display(forms.rev_assy_form_id);
         review_mode = FALSE;

         break;

    case FI_RESET:     /* Member of group FI_CTRL_GROUP */

         if (review_mode)
           break;

         FIg_reset(fp, ATTR_MCF);

         status = PDU_display_attr_in_mcf(current_rev_assy->new_attr_data);
         _pdm_status("PDU_display_attr_in_mcf", status);
         if (status != PDM_S_SUCCESS)
           {
           PDUdisplay_status(status, fp);
           break;
           }

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

         if (!review_mode)
         {
          status = PDUcheck_for_required_attributes2();
          _pdm_status("PDUcheck_for_required_attributes2", status);
          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            FIg_set_state_off(fp, FI_ACCEPT);
            break;
            }

          if (PDM_debug_on)
            MEMprint_buffer("attr buffer",PDU_attr_bufr,PDU_DEBUG_FILE);
          if (PDM_debug_on)
           MEMprint_buffer("data buffer",PDU_data_bufr,PDU_DEBUG_FILE);
         }

         _pdm_debug("assigning global buffers to linklist", 0);
         if (!review_mode)
           {
           if (current_rev_assy->new_attr_data)
             {
             free_attr_data_buffer(&current_rev_assy->new_attr_data);
             current_rev_assy->new_attr_data = NULL;
             }

           _pdm_debug("mallocing space for buffers", 0);
           current_rev_assy->new_attr_data =
                  (struct PDUattr_data *)malloc(sizeof (struct PDUattr_data));
           new_attrs = current_rev_assy->new_attr_data;
           new_attrs->attr_bufr = NULL;
           new_attrs->data_bufr = NULL;
           new_attrs->list_bufr = NULL;
           new_attrs->func_bufr = NULL;
           new_attrs->file_bufr = NULL;

           status = MEMsplit_copy_buffer(PDU_attr_bufr,
                                         &(new_attrs)->attr_bufr, 0);
           _pdm_status("MEMsplit_copy_buffer", status);
           status = MEMsplit_copy_buffer(PDU_data_bufr,
                                         &(new_attrs)->data_bufr, 0);
           _pdm_status("MEMsplit_copy_buffer", status);
           status = MEMsplit_copy_buffer(PDU_list_bufr,
                                         &(new_attrs)->list_bufr, 1);
           _pdm_status("MEMsplit_copy_buffer", status);

           if (PDMdebug_on)
             MEMprint_buffer("data_bufr", new_attrs->data_bufr, PDU_DEBUG_FILE);
           }
        
         _pdm_debug("resetting global buffers", 0);
         if (PDU_attr_bufr)
           {
           MEMclose(&PDU_attr_bufr);
           PDU_attr_bufr = NULL;
           }
         if (PDU_data_bufr)
           {
           MEMclose(&PDU_data_bufr);
           PDU_data_bufr = NULL;
           }
         if (PDU_list_bufr)
           {
           MEMclose(&PDU_list_bufr);
           PDU_list_bufr = NULL;
           }
         FIf_erase ( fp );
         FIf_reset ( fp );
         PDU_form_id = forms.rev_assy_form_id;
         FIf_display(forms.rev_assy_form_id);

         break;

    case ATTR_MCF:
 
         _pdm_debug("ATTR_MCF", 0);

         FIfld_get_active_row(fp,ATTR_MCF,&row,&pos);
         FImcf_get_active_col(fp,ATTR_MCF,&col,&pos);

         if (col == 0)
          {
          /* check attr_name for "*" */
          FIfld_get_text_length(fp,ATTR_MCF,row,0,&length);
          attribute = (char *)malloc(sizeof(char) * length + 1);
          memset(attribute,NULL,sizeof(char) * length + 1);
          FIfld_get_text(fp,ATTR_MCF,row,0,length, 
           (unsigned char *)attribute, &select, &pos);
          _pdm_debug("attribute = <%s>", attribute);

          if (attribute[0] == '*')
             {
             /* strip off '*' from front of attr_name */
             attribute = attribute + 1;
             FIfld_pos_cursor(fp, ATTR_MCF, row, pos, 0, 0, 0, 0);
             status = MEMsplit_copy_buffer(PDU_attr_bufr, &attr_bufr, 1);
             _pdm_status("MEMsplit_copy_buffer", status);

             status = MEMsplit_copy_buffer(PDU_list_bufr, &list_bufr, 1);
             _pdm_status("MEMsplit_copy_buffer", status);
             if (status != MEM_S_SUCCESS)
               {
               status = PDM_E_COPY_BUFFER;
               PDUdisplay_status(status, fp);
               break;
               }
             status = PDUprocess_pulldown_list(attribute,attr_bufr, list_bufr);
             }
          else
             {
             FIfld_pos_cursor(fp, ATTR_MCF, row, pos, 1, 1, 0, 0);
             break;
             }
          break;
          }

         /* if column != 0 */
         FIfld_get_text_length(fp,ATTR_MCF,row,1,&length);
         attr_value = (char *)malloc(sizeof(char) * length + 1);
         memset(attr_value,NULL,sizeof(char) * length + 1);
         FIfld_get_text(fp,ATTR_MCF,row,1,length, 
          (unsigned char *)attr_value, &select, &pos);
         _pdm_debug("attr_value = <%s>", attr_value);

         if (!attr_value)
           PDUfill_in_string(&attr_value, NULL_STRING);

         FIfld_get_text_length(fp,ATTR_MCF,row,0,&length);
         attribute = (char *)malloc(sizeof(char) * length + 1);
         memset(attribute,NULL,sizeof(char) * length + 1);
         FIfld_get_text(fp,ATTR_MCF,row,0,length, 
          (unsigned char *)attribute, &select, &pos);
         _pdm_debug("attribute = <%s>", attribute);

         /* get the attribute n_name */
          status = MEMbuild_array(PDU_attr_bufr);
          _pdm_status("MEMbuild_array",status);

          if (status != MEM_S_SUCCESS)
             {
             PDUdisplay_status(PDM_E_BUILD_BUFFER_ARRAY, fp);
             break;
             }

          data_row = (char **) PDU_attr_bufr->data_ptr;

          status = PDUget_buffer_col(PDU_attr_bufr,"n_name", &n_name_col);
          if (status != PDM_S_SUCCESS)
            {
            PDUdisplay_status(status, fp);
            return(status);
            }
          status =PDUget_buffer_col(PDU_attr_bufr,"n_synonym", &n_syn_col);
          if (status != PDM_S_SUCCESS)
            {
            PDUdisplay_status(status, fp);
            return(status);
            }

          _pdm_debug("searching for attr <%s>", attribute);
          for (act_row = 0; act_row < PDU_attr_bufr->rows; ++act_row)
             {
             if (strcmp(data_row[(PDU_attr_bufr->columns * act_row)+n_syn_col],
                 attribute) == 0)
               {
               _pdm_debug("setting n_name for <%s>", attribute);
               PDUfill_in_string(&attr_name, 
                   data_row[(PDU_attr_bufr->columns * act_row) + n_name_col]);
               }
             }

          _pdm_debug("checking attr for range", 0);
         str = strstr(attribute, "(min:");
         _pdm_debug("str = <%s>", str);

         if (str)
            {
            _pdm_debug("Attribute is a range", 0);
            /* Strip off the min and max value text that was appended to the
               attribute when added to the catalog attributes */
            *((char *) strstr(attribute, "(min:")) = '\0';
            *((char *) strrchr(attribute, ' ')) = '\0';
            }

/* 11/21/95 - TR 139528269 & 28274 - MJG - Check attribute and attr_name for
   NULL */
         msg = (char *) PDUtranslate_message(PDM_I_INTERNAL_LOCATION);
         if (((attribute) && (strcmp(attribute, msg) == 0)) || 
             ((attr_name) && (strcmp(attr_name, "n_cisano") == 0)))
           {
           status = PDUget_buffer_col(PDU_attr_bufr,"n_valueno",&valueno_col);
           _pdm_status("PDUget_buffer_col",status);
           if (status != PDM_S_SUCCESS)
             {
             PDUdisplay_status(status, fp);
             break;
             }

           _pdm_debug("getting storage buffer number", 0);
           for (i = 0; i < PDU_attr_bufr->rows; ++i)
              {
              if (strcmp(data_row[(PDU_attr_bufr->columns * i) + name_col],
                  "n_cisano") == 0)
                {
                stg_buffer_no = atoi(data_row[(PDU_attr_bufr->columns * i) + 
                                valueno_col]);
                _pdm_debug("stg_buffer_no = %d", (char *)stg_buffer_no);
                break;
                }
              }

           status = MEMsplit_copy_buffer(PDU_list_bufr, &list_bufr, 1);
           _pdm_status("MEMsplit_copy_buffer", status);
           if (status != MEM_S_SUCCESS)
             {
             status = PDM_E_COPY_BUFFER;
             PDUdisplay_status(status, fp);
             break;
             }

           status = PDUsetup_buffer_list(list_bufr, 1, stg_buffer_no, 
                    &dummy_row, &dummy_col, &dummy_format, &stg_bufr);
           _pdm_status("PDUsetup_buffer_list",status);
           if (status != PDM_S_SUCCESS)
             {
             PDUdisplay_status(status, fp);
             break;
             }

           _pdm_debug("verifying storage area name", 0);
           status = PDUverify_storage_name(attr_value, stgno, stg_bufr);
           _pdm_status("PDUverify_storage_name", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUdisplay_status(status, fp);
             break;
             }

           PDUfill_in_string(&attr_value, stgno);
           _pdm_debug("new attr_value = <%s>", attr_value);
           }
         else
           {
           status = MEMsplit_copy_buffer(PDU_list_bufr, &list_bufr, 1);
           _pdm_status("MEMsplit_copy_buffer", status);
           if (status != MEM_S_SUCCESS)
             {
             status = PDM_E_COPY_BUFFER;
             PDUdisplay_status(status, fp);
             break;
             }

           status = PDUvalidate_data_value(attribute, attr_value,
                                           PDU_attr_bufr, list_bufr);
           _pdm_status("PDUvalidate_data_value", status);
           MEMclose(&list_bufr);
           }

         if (status == PDM_E_REQATTR_NOT_FOUND)
            {
            PDUdisplay_status(status, fp);
            break;
            }

         if (status == PDM_E_AT_MAXLEVEL)
            {
            FIfld_set_text(fp, ATTR_MCF,row,col,"50",FALSE);
            PDUfill_in_string(&attr_value, "50");
            status = PDM_S_SUCCESS;
            }

         if (status == PDM_E_INVALID_INPUT)
            {
            PDUdisplay_status(status, fp);
            FIfld_set_text(fp, ATTR_MCF, row, col, "", FALSE);
            break;
            }

         if (status == PDM_E_FAILURE)
            {
            PDUdisplay_status(PDM_E_ATTR_VALUE_GEN_FUNC, fp);
            FIfld_set_text(fp, ATTR_MCF, row, col, "", FALSE);
            break;
            }
         if (status != PDM_S_SUCCESS)
            {
            PDUdisplay_status(status, fp);
            FIfld_set_text(fp, ATTR_MCF,row,col,"",FALSE);
            break;
            }

          if ((attr_name) && (strcmp(attr_name, "p_parttype") == 0))
            {
            _pdm_debug("user entered a parttype", 0);
            _pdm_debug("catalog = <%s>", current_rev_assy->new_catalog);
            if (strlen(attr_value))
              {
              status = PDUvalidate_parttype(current_rev_assy->new_catalog, 
                                            attr_value);
              _pdm_status("PDMvalidate_parttype", status);
              if (status != PDM_S_SUCCESS)
                status = PDM_E_INVALID_PART_TYPE;
              }
            else 
              {
              _pdm_debug("user cleared out the part type field", 0);
              status = PDM_E_ENTER_PARTTYPE;
              }

            if (status != PDM_S_SUCCESS)
              {
              PDUdisplay_status(status, fp);

              _pdm_debug("resetting parttype", 0);
              MEMbuild_array(PDU_data_bufr);
              PDUsetup_buffer(PDU_data_bufr, ROW, &data_row);
              PDUget_buffer_col(PDU_data_bufr, "p_parttype", &type_col);
              FIfld_set_text(fp, ATTR_MCF,row,col,
                     data_row[(PDU_data_bufr->columns * 0 ) + type_col],FALSE);
              break;
              }

            if (((strcmp(attr_value, "N") == 0) || 
                 (strcmp(attr_value, "n") == 0)) &&
                 ((current_rev_assy->new_cofilename) &&
                 (strlen(current_rev_assy->new_cofilename))))
              {
              PDUdisplay_status(PDM_E_ADD_FILES_NG_PART, fp);
              FIfld_set_text(forms.rev_assy_form_id, REV_MCF,
                             current_rev_assy->mcf_row,LOCFILE_COL,"",FALSE);
              FIfld_set_text(forms.rev_assy_form_id, REV_MCF,
                             current_rev_assy->mcf_row,STGFILE_COL,"",FALSE);
              PDUfill_in_string(&current_rev_assy->new_cofilename, NULL_STRING);
              PDUfill_in_string(&current_rev_assy->new_cifilename, NULL_STRING);
              break;
              }
            }

          _pdm_debug("checking attr for *", 0);
          if (attribute[0] == '*')
            attribute = attribute + 1;
          _pdm_debug("attribute = <%s>", attribute);

          for (i = 0; i < PDU_attr_bufr->rows; i++)
             {
             if (strcmp(data_row[(PDU_attr_bufr->columns * i) +                                n_syn_col], attribute) == 0)
                {
                _pdm_debug("writing value <%s> to buffer", attr_value);
                _pdm_debug("column = %d", i + 1);
                status = MEMwrite_data(PDU_data_bufr,attr_value,1,i + 1);
                if (PDU_data_bufr->rows > 1)
                  status = MEMwrite_data(PDU_data_bufr,attr_value,2,i + 1);
                if (status != MEM_S_SUCCESS)
                   {
                   PDUdisplay_status(PDM_E_WRITE_BUFFER, fp);
                   break;
                   }
                else 
                   {
                   found = 1;
                   }
                }
             else if (strcmp(data_row[(PDU_attr_bufr->columns * i) +                              n_name_col], attribute) == 0)
                {
                _pdm_debug("writing value <%s> to buffer", attr_value);
                _pdm_debug("column = %d", i + 1);
                status = MEMwrite_data(PDU_data_bufr,attr_value,1,i + 1);
                if (PDU_data_bufr->rows > 1)
                  status = MEMwrite_data(PDU_data_bufr,attr_value,2,i + 1);
                if (status != MEM_S_SUCCESS)
                   {
                   PDUdisplay_status(PDM_E_WRITE_BUFFER, fp);
                   break;
                   }
                else
                   {
                   found = 1;
                   }
                }

             if (found == 1)
                break;
             } 

           if (PDMdebug_on)
             MEMprint_buffer("PDUdata_bufr", PDU_data_bufr, PDU_DEBUG_FILE);

           if (strcmp(attribute, "p_parttype") == 0)
             PDUfill_in_string(&(current_rev_assy->new_parttype), attr_value);

         break;

    case VALUE_LIST:
	 _pdm_debug("ENTER CASE: VALUE_LIST",0);

         _pdm_debug("closing buffers", 0);
         if (attr_bufr)
           MEMclose(&attr_bufr);
         if (list_bufr)
           MEMclose(&list_bufr);

         list_row = value - 1;
         FIfld_get_active_row(fp, ATTR_MCF, &row, &pos);
         FIfld_set_text(fp, ATTR_MCF, row, 1, PDU_value_list[list_row], FALSE);
         _pdm_debug("value selected = <%s>", PDU_value_list[list_row]);

         /* set value_text to value selected */

         FIfld_set_select(fp, ATTR_MCF, row, 0, FALSE);

         FIfld_get_text_length(fp,ATTR_MCF, row,0, &length);
         attribute = (char *) malloc (sizeof (char) * length + 1);
         memset(attribute, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp, ATTR_MCF,row,0,length,
                        (unsigned char *)attribute,&select,&pos);
         _pdm_debug("attribute = <%s>", attribute);
         attribute = attribute + 1;
         _pdm_debug("attribute = <%s>", attribute);

         status = MEMbuild_array(PDU_attr_bufr);
         _pdm_status("MEMbuild_array",status);

         if (status != MEM_S_SUCCESS)
           {
           PDUdisplay_status(PDM_E_BUILD_BUFFER_ARRAY, fp);
           break;
           }

         data_row = (char **) PDU_attr_bufr->data_ptr;

         PDUget_buffer_col(PDU_attr_bufr,"n_name", &n_name_col);
         PDUget_buffer_col(PDU_attr_bufr,"n_synonym", &n_syn_col);

         for (i = 0; i < PDU_attr_bufr->rows; i++)
            {
            if (strcmp(data_row[(PDU_attr_bufr->columns * i) +
                       n_syn_col], attribute) == 0)
               {
               status = MEMwrite_data(PDU_data_bufr,PDU_value_list[list_row],
                                      1,i + 1);
               if (PDU_data_bufr->rows > 1)
                 status = MEMwrite_data(PDU_data_bufr,PDU_value_list[list_row],
                                        2,i + 1);
               if (status != MEM_S_SUCCESS)
                  {
                  PDUdisplay_status(PDM_E_WRITE_BUFFER, fp);
                  break;
                  }
               else
                  {
                  found = 1;
                  }
               }
            else if (strcmp(data_row[(PDU_attr_bufr->columns * i) +
                     n_name_col], attribute) == 0)
               {
               status = MEMwrite_data(PDU_data_bufr,PDU_value_list[list_row],
                                      1,i + 1);
               if (PDU_data_bufr->rows > 1)
                 status = MEMwrite_data(PDU_data_bufr,PDU_value_list[list_row],
                                        2,i + 1);
               if (status != MEM_S_SUCCESS)
                  {
                  PDUdisplay_status(PDM_E_WRITE_BUFFER, fp);
                  break;
                  }
               else
                  {
                  found = 1;
                  }
               }
            if (found == 1)
                break;
            }

         break;

    case CAT_FLD:

         break;

    case PART_FLD:

         break;


    case REV_FLD:

         break;

  } /* END switch ( g_label ) */

 return(1);

} /* END notification_routine() */


int rev_assy_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  long status = PDM_S_SUCCESS;
  int act_row = 0,act_col = 0,pos,select,length;
  int num_rows;
  int row = 0;
  int new_row = 0;
  int list_size = 0;
  int level = 0;
  int tmp_level = 0;
  int type_col = 0;
  int childno = 0;
  int pchildno = 0;
  int parent_level = 0;
  int i = 0;
  int state = FALSE;
  static char *text = NULL;
  static char *string = NULL;
  static char *suffix = NULL;
  char spec_char;
  char *stg_filename = NULL;
  char *msg = NULL;
  char *filename = NULL;
  char *parttype = NULL;
  char *catalog = NULL;
  char *partid = NULL;
  char *revision = NULL;
  char *desc = NULL;
  char *add_msg = NULL;
  char *title = NULL;
  char *parent_cat = NULL;
  char *parent_part = NULL;
  char *parent_rev = NULL;
  char **data_row;
  char level_str[5];
  char newfile[15];
  char type[5];
  char prev_add_db_value[3];
  struct PDUattr_data *attrs = NULL;
  struct PDUrev_assy *backup_list = NULL;
  struct PDUrev_assy *assy_list = NULL;
  struct PDUrev_assy *save_list = NULL;
  struct PDUassy_parts_list *list = NULL;
  short  found = FALSE;
  short  change = FALSE;
  short  param = FALSE;
  short  p_exists = FALSE;
  MEMptr file_bufr = NULL;
  MEMptr assy_bufr = NULL;
  extern void PDUdisplay_status();
  extern void PDUactive_part_form();

  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  PDU_form_id = fp;

  switch ( g_label )
  {

    case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */

         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

/* 11/29/95 - MJG - TR - Unlock all parts whose attrs have been retrieved */

         if (current_rev_assy)
           {
           _pdm_debug("resetting refresh information", 0);
           current_rev_assy = PDU_assy_ptr;
           PDUfill_in_string(&refresh->rev_catalog, current_rev_assy->ex_catalog);
           PDUfill_in_string(&refresh->rev_partid, current_rev_assy->ex_partid);
           PDUfill_in_string(&refresh->rev_revision, 
                             current_rev_assy->ex_revision);
           if (current_rev_assy->ex_desc)
             PDUfill_in_string(&refresh->rev_description, 
                               current_rev_assy->ex_desc);
           PDUfill_in_string(&refresh->rev_filename, 
                             current_rev_assy->ex_cofilename);

           _pdm_debug("freeing global pointer to assy linklist", 0);
           if (PDU_assy_ptr)
             {
             status = PDUfree_assy_linklist(&PDU_assy_ptr);
             _pdm_status("PDUfree_assy_linklist", status);
             current_rev_assy = NULL;
  
             if (PDU_assy_ptr)
               _pdm_debug("ERROR>>> failed to free PDU_assy_ptr", 0);
             }
           if (PDU_save_ptr)
             {
             status = PDUfree_assy_linklist(&PDU_save_ptr);
             _pdm_status("PDUfree_assy_linklist", status);
             }
           }

         if (PDU_save_part_list)
           {
           _pdm_debug("freeing PDU_save_part_list", 0);
           status = PDUfree_parts_list(&PDU_save_part_list);
           _pdm_status("PDUfree_parts_list", status);
           PDU_save_part_list = NULL;
           }

         if (PDU_checked_out_parts)
           {
           _pdm_debug("freeing PDU_checked_out_parts", 0);
           status = PDUfree_parts_list(&PDU_checked_out_parts);
           _pdm_status("PDUfree_parts_list", status);
           PDU_checked_out_parts = NULL;
           }

         if (PDU_modified_parts_list)
           {
           _pdm_debug("freeing PDU_modified_parts_list", 0);
           status = PDUfree_assy_parts_list(&PDU_modified_parts_list);
           _pdm_status("PDUfree_assy_parts_list", status);
           PDU_modified_parts_list = NULL;
           }

         if (PDU_copied_files)
           {
           _pdm_debug("freeing PDU_copied_files", 0);
           status = PDUfree_file_list(&PDU_copied_files);
           _pdm_status("PDUfree_file_list", status);
           PDU_copied_files = NULL;
           }

         forms.rev_assy_form_id = 0;
         FIf_erase ( fp );
         FIf_delete ( fp );
         review_mode = FALSE;
         if (forms.attr_value_form_id)
           {
           _pdm_debug("deleting pull down list", 0);
           if (PDU_value_pulldown)
             {
             GRdelete_pull_down_list(PDU_value_pulldown);
             PDU_value_pulldown = 0;
             }

           _pdm_debug("deleting attr form", 0);
           FIf_delete ( forms.attr_value_form_id );
           }
         forms.attr_value_form_id = 0;
         PDU_command = 0;
         PDU_load_search_data = FALSE;
         PDU_form_id = forms.local_files_form_id;
         PDU_calling_form = 0;
         PDUrefresh_local_files_form();
         FIf_display(forms.local_files_form_id);
         PDU_local_files_displayed = TRUE;

         if (PDU_usage_id)
           {
           free(PDU_usage_id);
           PDU_usage_id = NULL;
           }
         if (PDU_alt_tagno)
           {
           free(PDU_alt_tagno);
           PDU_alt_tagno = NULL;
           }
         PDUfill_in_string(&PDU_quantity, "1.000000");
         PDU_attach = TRUE;
         PDU_os_modified = FALSE;
         PDU_new_assembly = FALSE;

         break;

    case FI_RESET:     /* Member of group FI_CTRL_GROUP */

         FIg_reset(fp, REV_MCF);

         _pdm_debug("setting suffix toggle", 0);
         if (PDU_use_suffix)
           {
           _pdm_debug("file suffix is ON", 0);
           FIg_set_state_on(forms.rev_assy_form_id, SUFFIX_TGL);
           FIfld_set_mode(forms.rev_assy_form_id,SUFFIX_FLD,0, FI_INSERT); 
           if (PDU_file_suffix)
             FIg_set_text(forms.rev_assy_form_id, SUFFIX_FLD, PDU_file_suffix);
           else
             FIg_set_text(forms.rev_assy_form_id, SUFFIX_FLD, NULL_STRING);
           }
         else
           {
           _pdm_debug("file suffix is OFF", 0);
           FIg_set_state_off(forms.rev_assy_form_id, SUFFIX_TGL);
           FIfld_set_mode(forms.rev_assy_form_id,SUFFIX_FLD,0, FI_REVIEW); 
           FIg_set_text(forms.rev_assy_form_id, SUFFIX_FLD, NULL_STRING);
           }
       
         if (PDU_assy_ptr)
           {
           _pdm_debug("freeing current linklist", 0);
           PDUfree_assy_linklist(&PDU_assy_ptr);
           current_rev_assy = NULL;
           PDU_assy_ptr = NULL;
           }

         if (PDU_save_part_list)
           {
           _pdm_debug("freeing PDU_save_part_list", 0);
           status = PDUfree_parts_list(&PDU_save_part_list);
           _pdm_status("PDUfree_parts_list", status);
           PDU_save_part_list = NULL;
           }

         if (PDU_checked_out_parts)
           {
           _pdm_debug("freeing PDU_checked_out_parts", 0);
           status = PDUfree_parts_list(&PDU_checked_out_parts);
           _pdm_status("PDUfree_parts_list", status);
           PDU_checked_out_parts = NULL;
           }

         if (PDU_modified_parts_list)
           {
           _pdm_debug("freeing PDU_modified_parts_list", 0);
           status = PDUfree_assy_parts_list(&PDU_modified_parts_list);
           _pdm_status("PDUfree_assy_parts_list", status);
           PDU_modified_parts_list = NULL;
           }

         if (PDU_copied_files)
           {
           _pdm_debug("freeing PDU_copied_files", 0);
           status = PDUfree_file_list(&PDU_copied_files);
           _pdm_status("PDUfree_file_list", status);
           PDU_copied_files = NULL;
           }

         _pdm_debug("restoring linklist", 0);
         assy_list = PDU_save_ptr;
         status = PDUcopy_assy_linklist(assy_list, &backup_list, 0); 
                                                          /* 0 = restore */
         _pdm_status("PDUcopy_assy_linklist", status);
         if (status != PDM_S_SUCCESS)
           {
           PDUfree_assy_linklist(&PDU_assy_ptr);
           PDUfree_assy_linklist(&PDU_save_ptr);
           assy_list = NULL;
           backup_list = NULL;
           PDUdisplay_status(status, fp);
           break;
           }

         status = PDUload_revise_assembly_form(backup_list, fp, REV_MCF);
         _pdm_status("PDUload_revise_assembly_form", status);
       
         if (status != PDM_S_SUCCESS)
           {
           PDUfree_assy_linklist(&PDU_assy_ptr);
           backup_list = NULL;
           PDUdisplay_status(status, fp);
           break;
           }

         PDU_load_search_data = FALSE;
         PDUdisplay_status(PDM_S_SUCCESS, fp);
         PDU_os_modified = FALSE;
         PDU_new_assembly = FALSE;
         current_rev_assy = assy_list;

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

         FIfld_get_text_length(fp,REV_MCF,0,REV_COL,&length);
         text = (char *)malloc(sizeof(char) * length + 1);
         memset(text,NULL,sizeof(char) * length + 1);
         FIfld_get_text(fp,REV_MCF,0,REV_COL,length, 
                         (unsigned char *)text, &select, &pos);
         if ((!text) || ((text) && (!strlen(text))))
           {
           PDUdisplay_status(PDM_E_REVISION_FOR_REVISE, fp);
           FIfld_pos_cursor(fp, REV_MCF, 0, 0, REV_COL, 0, 1, 1);
           FIg_set_state_off(fp, FI_ACCEPT);
           break;
           }

         current_rev_assy = PDU_assy_ptr;
         if (PDM_debug_on)
          {
            if (PDU_assy_ptr != NULL)
            {
             _pdm_debug("printing global assembly linklist",0);
             PDUprint_assy_linklist(PDU_assy_ptr);
            }
          }

         current_rev_assy = PDU_assy_ptr;

         _pdm_debug("update deleted parts in list", 0);
         PDUmark_deleted_parts_for_revise_assy();
         
         current_rev_assy = PDU_assy_ptr;

         _pdm_debug("creating mirror buffer", 0);
         status = PDUassy_list_to_ASSY_BUFR(current_rev_assy, &assy_bufr);
         _pdm_status("PDUassy_list_to_ASSY_BUFR", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUdisplay_status(status, fp);
           FIg_set_state_off(fp, FI_ACCEPT);
            if (assy_bufr)
              {
              MEMclose(&assy_bufr);
              assy_bufr = NULL;
              }
           break;
           }

         current_rev_assy = PDU_assy_ptr;

         _pdm_debug("check to see if structure has changed", 0);
         status = PDUcheck_assy_list_for_change(assy_bufr, &change);
         _pdm_status("PDUcheck_assy_list_for_change", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUdisplay_status(status, fp);
           FIg_set_state_off(fp, FI_ACCEPT);
            if (assy_bufr)
              {
              MEMclose(&assy_bufr);
              assy_bufr = NULL;
              }
           PDUcleanup_revise_assembly();
           break;
           }

         current_rev_assy = PDU_assy_ptr;

         if (!change)
           {
           PDUdisplay_status(PDM_E_ASSY_NOT_MODIFIED, fp);
           FIg_set_state_off(fp, FI_ACCEPT);
           break;
           }

         /*  The function PDUcheck_assy_list_for_change makes changes to the
             global assy link list that need to updated in the buffer.  The
             function also uses the buffer, so it must be created before the
             function is called and then reset after exiting the function. */
         _pdm_debug("recreating assembly buffer", 0);
         if (assy_bufr)
           {
           MEMclose(&assy_bufr);
           assy_bufr = NULL;
           }
         status = PDUassy_list_to_ASSY_BUFR(current_rev_assy, &assy_bufr);
         _pdm_status("PDUassy_list_to_ASSY_BUFR", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUdisplay_status(status, fp);
           FIg_set_state_off(fp, FI_ACCEPT);
            if (assy_bufr)
              {
              MEMclose(&assy_bufr);
              assy_bufr = NULL;
              }
           PDUcleanup_revise_assembly();
           break;
           }

         current_rev_assy = PDU_assy_ptr;

         PDUdisplay_status(status, fp);

         _pdm_debug("adding parts", 0);
         status = PDUadd_parts_for_revise_assy();
         _pdm_status("PDUadd_parts_for_revise_assy", status);

         PDUdisplay_status(status, fp);

         if (status != PDM_S_SUCCESS)
           {
           PDUcleanup_revise_assembly();
           FIg_set_state_off(fp, FI_ACCEPT);
           break;
           }

         status = PDUprocess_rev_assy_form(assy_bufr);
         _pdm_status("PDUprocess_rev_assy_form", status);

         PDUdisplay_status(status, fp);

         if (status != PDM_S_SUCCESS)
           {
           PDUcleanup_revise_assembly();
           FIg_set_state_off(fp, FI_ACCEPT);
            if (assy_bufr)
              {
              MEMclose(&assy_bufr);
              assy_bufr = NULL;
              }
           break;
           }

         current_rev_assy = PDU_assy_ptr;

         if (current_rev_assy)
           {
           _pdm_debug("resetting refresh information", 0);
           current_rev_assy = PDU_assy_ptr;
           PDUfill_in_string(&refresh->rev_catalog, current_rev_assy->ex_catalog);
           PDUfill_in_string(&refresh->rev_partid, current_rev_assy->ex_partid);
           PDUfill_in_string(&refresh->rev_revision, 
                             current_rev_assy->ex_revision);
           if (current_rev_assy->ex_desc)
             PDUfill_in_string(&refresh->rev_description, 
                               current_rev_assy->ex_desc);
           PDUfill_in_string(&refresh->rev_filename, 
                             current_rev_assy->ex_cofilename);

           _pdm_debug("freeing global pointer to assy linklist", 0);
           if (PDU_assy_ptr)
             {
             status = PDUfree_assy_linklist(&PDU_assy_ptr);
             _pdm_status("PDUfree_assy_linklist", status);
             current_rev_assy = NULL;
  
             if (PDU_assy_ptr)
               _pdm_debug("ERROR>>> failed to free PDU_assy_ptr", 0);
             }
           if (PDU_save_ptr)
             {
             status = PDUfree_assy_linklist(&PDU_save_ptr);
             _pdm_status("PDUfree_assy_linklist", status);
             PDU_save_ptr = NULL;
             }
           }

         if (PDU_save_part_list)
           {
           _pdm_debug("freeing PDU_save_part_list", 0);
           status = PDUfree_parts_list(&PDU_save_part_list);
           _pdm_status("PDUfree_parts_list", status);
           PDU_save_part_list = NULL;
           }

         if (PDU_checked_out_parts)
           {
           _pdm_debug("freeing PDU_checked_out_parts", 0);
           status = PDUfree_parts_list(&PDU_checked_out_parts);
           _pdm_status("PDUfree_parts_list", status);
           PDU_checked_out_parts = NULL;
           }

         if (PDU_modified_parts_list)
           {
           _pdm_debug("freeing PDU_modified_parts_list", 0);
           status = PDUfree_assy_parts_list(&PDU_modified_parts_list);
           _pdm_status("PDUfree_assy_parts_list", status);
           PDU_modified_parts_list = NULL;
           }

         if (PDU_copied_files)
           {
           _pdm_debug("freeing PDU_copied_files", 0);
           status = PDUfree_file_list(&PDU_copied_files);
           _pdm_status("PDUfree_file_list", status);
           PDU_copied_files = NULL;
           }

         _pdm_debug("exiting form", 0);
         forms.rev_assy_form_id = 0;
         FIf_erase ( fp );
         FIf_delete ( fp );
         review_mode = FALSE;
         if (forms.attr_value_form_id)
           {
           _pdm_debug("deleting pull down list", 0);
           if (PDU_value_pulldown)
             {
             GRdelete_pull_down_list(PDU_value_pulldown);
             PDU_value_pulldown = 0;
             }

           _pdm_debug("deleting attr form", 0);
           FIf_delete ( forms.attr_value_form_id );
           }
         forms.attr_value_form_id = 0;
         PDU_command = 0;
         PDU_load_search_data = FALSE;
         PDU_form_id = forms.local_files_form_id;
         PDU_calling_form = 0;
         PDUrefresh_local_files_form();
         FIf_display(forms.local_files_form_id);
         PDU_local_files_displayed = TRUE;
         if (PDU_usage_id)
           {
           free(PDU_usage_id);
           PDU_usage_id = NULL;
           }
         if (PDU_alt_tagno)
           {
           free(PDU_alt_tagno);
           PDU_alt_tagno = NULL;
           }
         PDUfill_in_string(&PDU_quantity, "1.000000");
         PDU_attach = TRUE;
         PDU_os_modified = FALSE;
         PDU_new_assembly = FALSE;

         break;

    case UPDATE_ASSY:     /* Member of group FI_CTRL_GROUP */

         FIfld_get_text_length(fp,REV_MCF,0,REV_COL,&length);
         text = (char *)malloc(sizeof(char) * length + 1);
         memset(text,NULL,sizeof(char) * length + 1);
         FIfld_get_text(fp,REV_MCF,0,REV_COL,length, 
                         (unsigned char *)text, &select, &pos);
         if ((!text) || ((text) && (!strlen(text))))
           {
           PDUdisplay_status(PDM_E_REVISION_FOR_REVISE, fp);
           FIfld_pos_cursor(fp, REV_MCF, 0, 0, REV_COL, 0, 1, 1);
           break;
           }

         current_rev_assy = PDU_assy_ptr;
         if (PDM_debug_on)
          {
            if (PDU_assy_ptr != NULL)
            {
             _pdm_debug("printing global assembly linklist",0);
             PDUprint_assy_linklist(PDU_assy_ptr);
            }
          }

         current_rev_assy = PDU_assy_ptr;

         _pdm_debug("update deleted parts in list", 0);
         PDUmark_deleted_parts_for_revise_assy();
         
         current_rev_assy = PDU_assy_ptr;

         _pdm_debug("creating mirror buffer", 0);
         status = PDUassy_list_to_ASSY_BUFR(current_rev_assy, &assy_bufr);
         _pdm_status("PDUassy_list_to_ASSY_BUFR", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUdisplay_status(status, fp);
            if (assy_bufr)
              {
              MEMclose(&assy_bufr);
              assy_bufr = NULL;
              }
           break;
           }

         current_rev_assy = PDU_assy_ptr;

         _pdm_debug("check to see if structure has changed", 0);
         status = PDUcheck_assy_list_for_change(assy_bufr, &change);
         _pdm_status("PDUcheck_assy_list_for_change", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUdisplay_status(status, fp);
            if (assy_bufr)
              {
              MEMclose(&assy_bufr);
              assy_bufr = NULL;
              }
           PDUcleanup_revise_assembly();
           break;
           }

         if (!change)
           {
           PDUdisplay_status(PDM_E_ASSY_NOT_MODIFIED, fp);
           PDUcleanup_revise_assembly();
           break;
           }

         current_rev_assy = PDU_assy_ptr;

         /*  The function PDUcheck_assy_list_for_change makes changes to the
             global assy link list that need to updated in the buffer.  The
             function also uses the buffer, so it must be created before the
             function is called and then reset after exiting the function. */
         _pdm_debug("recreating assembly buffer", 0);
         if (assy_bufr)
           {
           MEMclose(&assy_bufr);
           assy_bufr = NULL;
           }
         status = PDUassy_list_to_ASSY_BUFR(current_rev_assy, &assy_bufr);
         _pdm_status("PDUassy_list_to_ASSY_BUFR", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUdisplay_status(status, fp);
           FIg_set_state_off(fp, FI_ACCEPT);
            if (assy_bufr)
              {
              MEMclose(&assy_bufr);
              assy_bufr = NULL;
              }
           PDUcleanup_revise_assembly();
           break;
           }

         current_rev_assy = PDU_assy_ptr;

         PDUdisplay_status(status, fp);

         _pdm_debug("adding parts", 0);
         status = PDUadd_parts_for_revise_assy();
         _pdm_status("PDUadd_parts_for_revise_assy", status);

         PDUdisplay_status(status, fp);

         if (status != PDM_S_SUCCESS)
           {
           PDUcleanup_revise_assembly();
           break;
           }

         status = PDUprocess_rev_assy_form(assy_bufr);
         _pdm_status("PDUprocess_rev_assy_form", status);

         PDUdisplay_status(status, fp);

         if (status != PDM_S_SUCCESS)
           {
            if (assy_bufr)
              {
              MEMclose(&assy_bufr);
              assy_bufr = NULL;
              }
           PDUcleanup_revise_assembly();
           break;
           }

         /* retrieve the assembly structure again */
         FIf_reset(fp);

         current_rev_assy = PDU_assy_ptr;

         if (current_rev_assy)
           {
           _pdm_debug("resetting refresh information", 0);
           current_rev_assy = PDU_assy_ptr;
           PDUfill_in_string(&refresh->rev_catalog, 
                             current_rev_assy->new_catalog);
           PDUfill_in_string(&refresh->rev_partid, 
                             current_rev_assy->new_partid);
           PDUfill_in_string(&refresh->rev_revision, 
                             current_rev_assy->new_revision);
           if (current_rev_assy->ex_desc)
             PDUfill_in_string(&refresh->rev_description, 
                               current_rev_assy->new_desc);
           PDUfill_in_string(&refresh->rev_filename, 
                             current_rev_assy->new_cofilename);

           _pdm_debug("freeing global pointer to assy linklist", 0);
           if (PDU_assy_ptr)
             {
             status = PDUfree_assy_linklist(&PDU_assy_ptr);
             _pdm_status("PDUfree_assy_linklist", status);
             current_rev_assy = NULL;
  
             if (PDU_assy_ptr)
               _pdm_debug("ERROR>>> failed to free PDU_assy_ptr", 0);
             }
           if (PDU_save_ptr)
             {
             _pdm_debug("freeing PDU_save_ptr", 0);
             status = PDUfree_assy_linklist(&PDU_save_ptr);
             _pdm_status("PDUfree_assy_linklist", status);
             PDU_save_ptr = NULL;
             }
           }

         if (PDU_save_part_list)
           {
           _pdm_debug("freeing PDU_save_part_list", 0);
           status = PDUfree_parts_list(&PDU_save_part_list);
           _pdm_status("PDUfree_parts_list", status);
           PDU_save_part_list = NULL;
           }

         if (PDU_checked_out_parts)
           {
           _pdm_debug("freeing PDU_checked_out_parts", 0);
           status = PDUfree_parts_list(&PDU_checked_out_parts);
           _pdm_status("PDUfree_parts_list", status);
           PDU_checked_out_parts = NULL;
           }

         if (PDU_modified_parts_list)
           {
           _pdm_debug("freeing PDU_modified_parts_list", 0);
           status = PDUfree_assy_parts_list(&PDU_modified_parts_list);
           _pdm_status("PDUfree_assy_parts_list", status);
           PDU_modified_parts_list = NULL;
           }

         if (PDU_copied_files)
           {
           _pdm_debug("freeing PDU_copied_files", 0);
           status = PDUfree_file_list(&PDU_copied_files);
           _pdm_status("PDUfree_file_list", status);
           PDU_copied_files = NULL;
           }

         /* get the max level of display from the database */
         status = PDUget_max_level(&level);
         _pdm_status("PDUget_max_level", status);
         if (status != PDM_S_SUCCESS)
           {
           PDUdisplay_status(status, fp);
           break;
           }
       
         _pdm_debug("level = %d", (char *)level);
         _pdm_debug("setting PDU_explode_depth", 0);
         PDU_explode_depth = level;
         _pdm_debug("setting PDU_save_level", 0);
         PDU_save_level = level;
       
         _pdm_debug("explode_depth = %d", (char *)PDU_explode_depth);
         status = PDMget_assembly_structure(
                                         refresh->rev_catalog,
                                         refresh->rev_partid,
                                         refresh->rev_revision,
                                         PDU_explode_depth,
                                         &assy_bufr, 0);
         _pdm_status("PDMget_assembly_structure", status);
       
         if ((status != PDM_S_SUCCESS) && (status != PDM_E_PART_NOT_ASSEMBLY))
           {
           if (assy_bufr)
           MEMclose(&assy_bufr);
           PDUdisplay_status(status, fp);
           break;
           }
       
         status = PDUconvert_assy_buffer_to_linklist(assy_bufr, &assy_list);
         _pdm_status("PDUconvert_assy_buffer_to_linklist", status);
       
         if (status != PDM_S_SUCCESS)
           {
           PDUdisplay_status(status, fp);
           break;
           }
       
         status = PDUcreate_BOM_assy_list(&assy_list, assy_bufr);
         _pdm_status("PDUcreate_BOM_assy_list", status);
         if (assy_bufr)
           MEMclose(&assy_bufr);
       
         if (status != PDM_S_SUCCESS)
           {
           PDUfree_assy_linklist(&PDU_assy_ptr);
           assy_list = NULL;
           PDUdisplay_status(status, fp);
           break;
           }
       
         status = PDUadd_multiple_files_to_linklist(&assy_list);
         _pdm_status("PDUadd_multiple_files_to_linklist", status);
       
         if (status != PDM_S_SUCCESS)
           {
           PDUfree_assy_linklist(&PDU_assy_ptr);
           assy_list = NULL;
           PDUdisplay_status(status, fp);
           break;
           }
       
         _pdm_debug("setting suffix toggle", 0);
         if (PDU_use_suffix)
           {
           _pdm_debug("file suffix is ON", 0);
           FIg_set_state_on(forms.rev_assy_form_id, SUFFIX_TGL);
           FIfld_set_mode(forms.rev_assy_form_id,SUFFIX_FLD,0, FI_INSERT); 
           if (PDU_file_suffix)
             FIg_set_text(forms.rev_assy_form_id, SUFFIX_FLD, PDU_file_suffix);
           else
             FIg_set_text(forms.rev_assy_form_id, SUFFIX_FLD, NULL_STRING);
           }
         else
           {
           _pdm_debug("file suffix is OFF", 0);
           FIg_set_state_off(forms.rev_assy_form_id, SUFFIX_TGL);
           FIfld_set_mode(forms.rev_assy_form_id,SUFFIX_FLD,0, FI_REVIEW); 
           FIg_set_text(forms.rev_assy_form_id, SUFFIX_FLD, NULL_STRING);
           }
       
         assy_list = PDU_assy_ptr;
         status = PDUload_revise_assembly_form(assy_list, fp, REV_MCF);
         _pdm_status("PDUload_revise_assembly_form", status);
       
         if (status != PDM_S_SUCCESS)
           {
           PDUfree_assy_linklist(&PDU_assy_ptr);
           assy_list = NULL;
           PDUdisplay_status(status, fp);
           break;
           }
       
         status = PDUcopy_assy_linklist(assy_list, &save_list, 1); 
                                                             /* 1 = backup */
         _pdm_status("PDUcopy_assy_linklist", status);
       
         if (status != PDM_S_SUCCESS)
           {
           PDUfree_assy_linklist(&PDU_assy_ptr);
           PDUfree_assy_linklist(&PDU_save_ptr);
           assy_list = NULL;
           save_list = NULL;
           PDUdisplay_status(status, fp);
           break;
           }

         current_rev_assy = assy_list;

         if (PDU_usage_id)
           {
           free(PDU_usage_id);
           PDU_usage_id = NULL;
           }
         if (PDU_alt_tagno)
           {
           free(PDU_alt_tagno);
           PDU_alt_tagno = NULL;
           }
         PDUfill_in_string(&PDU_quantity, "1.000000");
         PDU_os_modified = FALSE;
         PDU_new_assembly = FALSE;

         PDUmessage(PDM_S_SUCCESS, 's');

         break;

    case FI_EXECUTE:

         break;

    case REV_MCF: 

         _pdm_debug("REV_MCF", 0);

         FIfld_get_active_row(fp,REV_MCF,&act_row,&pos);
         FImcf_get_active_col(fp,REV_MCF,&act_col,&pos);
         _pdm_debug("active row = %d", act_row);
         _pdm_debug("act_col = %d", act_col);

         /* if a row was selected, check for multiple files */

         if ((act_col < NEWLEV_COL) && (act_col != DISPEXT_COL))
           {
           FImcf_get_select(fp, REV_MCF, act_row, &select);
  
           if (!select)
             {
             _pdm_debug("row was deselected: breaking", 0);
             break;
             }

           for (row = act_row; row >= 0; --row)
              {
              FIfld_get_text_length(fp,REV_MCF,row,1,&length);
              text = (char *)malloc(sizeof(char) * length + 1);
              memset(text,NULL,sizeof(char) * length + 1);
              FIfld_get_text(fp,REV_MCF,row,1,length, 
                         (unsigned char *)text, &select, &pos);
              if (!text)
                {
                _pdm_debug("multiple file or reference file selected", 0);
                found = TRUE;
                continue;
                }
              else if (!strlen(text))
                {
                _pdm_debug("multiple file or reference file selected", 0);
                found = TRUE;
                continue;
                }
              else if (found)
                {
                _pdm_debug("last multiple file found", 0);
                FImcf_set_select(fp, REV_MCF, act_row, FALSE);
                FImcf_set_select(fp, REV_MCF, row, TRUE);
                FIfld_set_active_row(fp, REV_MCF, row, 0);
                break;
                }
              else
                {
                _pdm_debug("multiple file not selected", 0);
                break;
                }
              }
           if (!PDU_load_search_data)
             break;
           }

         FIfld_get_active_row(fp,REV_MCF,&act_row,&pos);
         _pdm_debug("act_row = %d", (char *)act_row);
         _pdm_debug("act_col = %d", (char *)act_col);

         /* find place in PDUrev_assy structure and set current_rev_assy */
         current_rev_assy = PDU_assy_ptr;
         _pdm_debug("finding active row in link list", 0);
         while (current_rev_assy)
          {
            if (current_rev_assy->mcf_row == act_row)
              {
              found = 1;
              break;
              }
            else if (current_rev_assy)
              current_rev_assy = current_rev_assy->next;
          }
         if (!found)
           {
           _pdm_debug("selected row is not in the link list", 0);
           PDUdisplay_status(PDM_E_PLACE_ROW, fp);
           FIfld_erase_cursor(fp, REV_MCF);
           FIfld_set_text(fp, REV_MCF, act_row, act_col, NULL_STRING, FALSE);
           break;
           }
         else
           _pdm_debug("current ptr mcf row %d\n",current_rev_assy->mcf_row);

         /* See if row selected is from a search */
         if ((PDUsearch_part_list) && (PDU_load_search_data))
          {
          _pdm_debug("found PDUsearch_part_list",0);

          _pdm_debug("check if row is valid", 0);
          if (current_rev_assy->ex_level == -1)
            {
            _pdm_debug("invalid row selected", 0);
            FImcf_set_select(fp, REV_MCF, act_row, FALSE);
            PDU_load_search_data = FALSE;
            break;
            }
          else if (current_rev_assy->ex_level == 0)
            {
            _pdm_debug("invalid row selected", 0);
            FImcf_set_select(fp, REV_MCF, act_row, FALSE);
            PDUdisplay_status(PDM_E_CANNOT_REPLACE_PARENT, fp);
            break;
            }

          add_msg = (char *)PDUtranslate_message(PDM_I_ADDED_ROW);
          if (strcmp(current_rev_assy->ex_catalog, add_msg) != 0)
            {
            _pdm_debug("make sure user selected a different part", 0);
            if ((strcmp(refresh->rev_catalog, 
                        current_rev_assy->ex_catalog) == 0) &&
                (strcmp(refresh->rev_partid,
                        current_rev_assy->ex_partid) == 0) &&
                (strcmp(refresh->rev_revision,
                        current_rev_assy->ex_revision) == 0))
               {
               _pdm_debug("user selected the same part", 0);
               strcpy(current_rev_assy->add, "N");
               PDUupdate_mult_files_for_rev_assy("add", "N");
               }

            FIfld_get_text_length(fp,REV_MCF,act_row,EXLEV_COL,&length);
            text = (char *)malloc(sizeof(char) * length + 1);
            memset(text,NULL,sizeof(char) * length + 1);
            FIfld_get_text(fp,REV_MCF,act_row,EXLEV_COL,length,
                (unsigned char *)text, &select, &pos);
            _pdm_debug("level = %s",text);
   
           if ((text) && (strcmp(text, "0") == 0))
             level = 0;
           else
             level = atoi(text);
   
            if (level != 0)
              {
              PDUfind_parent_in_mcf(act_row, level, &parent_cat, &parent_part,
                       &parent_rev, &row, &parent_level, &childno, &pchildno);
   
/* parts that have multiple files should have already been checked  &&
   each level 1 part should only appear on the form once  */
              if ((level != -1) && (parent_level != 0))
                {
                _pdm_debug("has part has been modified at a different level??",0);
                list = PDU_modified_parts_list;
                status = PDUis_part_in_assy_list(parent_level,
                                                 childno,
                                                 pchildno,
                                                 parent_cat,
                                                 parent_part,
                                                 parent_rev,
                                                 list);
                _pdm_status("PDUis_part_in_assy_list", status);
                if (status == 1)
                  {
                  _pdm_debug("part modified at different location", 0);
                  PDUdisplay_status(PDM_E_MODIFY_DUPLICATE_PART, fp);
                  break;
                  }
       
                _pdm_debug("add part to list of modified parts", 0);
                status = PDUadd_part_to_assy_list(parent_level,
                                                  childno,
                                                  pchildno,
                                                  parent_cat,
                                                  parent_part,
                                                  parent_rev,
                                                  &list);
                _pdm_status("PDUadd_part_to_assy_list", status);
                if (status != PDM_S_SUCCESS)
                  {
                  PDUdisplay_status(status, fp);
                  break;
                  }
                PDU_modified_parts_list = list;
                }
              }
            }

          /* Assign data from search to PDUrev_assy struct */

          PDUfill_in_string(&current_rev_assy->new_catalog,
                             refresh->rev_catalog);
          PDUfill_in_string(&current_rev_assy->new_partid,
                             refresh->rev_partid);
          PDUfill_in_string(&current_rev_assy->new_revision,
                             refresh->rev_revision);
          PDUfill_in_string(&current_rev_assy->new_desc,
                             refresh->rev_description);
          PDUfill_in_string(&current_rev_assy->new_cofilename,
                             refresh->rev_filename);

          strcpy(current_rev_assy->add, "Y");
          PDUupdate_mult_files_for_rev_assy("add", "N");

          if (current_rev_assy->new_level != 0)
            {
            _pdm_debug("check for cyclic placement", 0);
            status = PDUcheck_cyclic_placement_for_rev_assy(act_row);
            _pdm_status("PDUcheck_cyclic_placement_for_rev_assy", status);
            if (status != PDM_S_SUCCESS)
              break;
            }

          _pdm_debug("call PDUget_storage_filename\n",0);
          /* Get storage file name */
          PDUdisplay_status(PDS_M_GET_STG_FILENAME, fp);
          status  = PDUget_storage_filename(current_rev_assy->new_catalog,
                              current_rev_assy->new_partid, 
                              current_rev_assy->new_revision,
                              current_rev_assy->new_cofilename, 
                              &file_bufr, &stg_filename);

          if (stg_filename)
            {
            PDUfill_in_string(&current_rev_assy->new_cifilename,stg_filename);
            free(stg_filename);
            }
          else
            PDUfill_in_string(&current_rev_assy->new_cifilename,stg_filename);

          if (file_bufr)
            {
            MEMclose(&file_bufr);
            file_bufr = NULL;
            }

          _pdm_debug("fill mcf with data from search\n",0);

          /* Fill mcf with data */

          FIfld_set_text(PDU_form_id,REV_MCF,act_row,CAT_COL,
                      current_rev_assy->new_catalog, FALSE);
          FIfld_set_text(PDU_form_id,REV_MCF,act_row,PART_COL,
                     current_rev_assy->new_partid, FALSE);
          FIfld_set_text(PDU_form_id,REV_MCF,act_row,REV_COL,
                     current_rev_assy->new_revision, FALSE);
          FIfld_set_text(PDU_form_id,REV_MCF,act_row,DESC_COL,
                     current_rev_assy->new_desc, FALSE);
          FIfld_set_text(PDU_form_id,REV_MCF,act_row,LOCFILE_COL,
                       current_rev_assy->new_cofilename, FALSE);
          FIfld_set_text(PDU_form_id,REV_MCF,act_row,STGFILE_COL,
                       current_rev_assy->new_cifilename, FALSE); 

          PDU_load_search_data = FALSE;
          strcpy(current_rev_assy->delete, "N");
          PDUupdate_mult_files_for_rev_assy("delete", "N");
          strcpy(current_rev_assy->add_db, "N");
          PDUupdate_mult_files_for_rev_assy("add_db", "N");

          /* check for multiple files */
          while (current_rev_assy)
            {
            if (current_rev_assy->ex_level == -1)
              {
              strcpy(current_rev_assy->delete, "N");
              PDUupdate_mult_files_for_rev_assy("delete", "N");
              }
            else
              break;
            }

          PDUdisplay_status(PDM_S_SUCCESS, fp);

          break;
          }

         add_msg = (char *)PDUtranslate_message(PDM_I_ADDED_ROW);
         if (((act_col == CAT_COL)     || 
              (act_col == PART_COL)    || 
              (act_col == REV_COL)     || 
              (act_col == DESC_COL)    || 
              (act_col == LOCFILE_COL) || 
              (act_col == STGFILE_COL)) &&
              (strcmp(current_rev_assy->ex_catalog, add_msg) != 0))
           {
           FIfld_get_text_length(fp,REV_MCF,act_row,EXLEV_COL,&length);
           text = (char *)malloc(sizeof(char) * length + 1);
           memset(text,NULL,sizeof(char) * length + 1);
           FIfld_get_text(fp,REV_MCF,act_row,EXLEV_COL,length,
               (unsigned char *)text, &select, &pos);
           _pdm_debug("text = %s",text);
  
           if ((text) && (strcmp(text, "0") == 0))
             level = 0;
           else
             level = atoi(text);
  
           _pdm_debug("level = %d",(char *)level);
           if (level != 0)
             {
             PDUfind_parent_in_mcf(act_row, level, &parent_cat, &parent_part,
                      &parent_rev, &row, &parent_level, &childno, &pchildno);

/* parts that have multiple files should have already been checked  &&
   each level 1 part should only appear on the form once  */
             if ((level != -1) && (parent_level != 0))
               {
  /* add the parent part to the list of modified parts, not the child */
             _pdm_debug("has part has been modified at a different level??", 0);
               list = PDU_modified_parts_list;
               status = PDUis_part_in_assy_list(parent_level,
                                                childno,
                                                pchildno,
                                                parent_cat,
                                                parent_part,
                                                parent_rev,
                                                list);
               _pdm_status("PDUis_part_in_assy_list", status);
               if (status == 1)
                 {
                 _pdm_debug("part modified at different location", 0);
                 PDUdisplay_status(PDM_E_MODIFY_DUPLICATE_PART, fp);
                 break;
                 }
      
               _pdm_debug("add part to list of modified parts", 0);
               status = PDUadd_part_to_assy_list(parent_level,
                                                 childno,
                                                 pchildno,
                                                 parent_cat,
                                                 parent_part,
                                                 parent_rev,
                                                 &list);
               _pdm_status("PDUadd_part_to_assy_list", status);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUdisplay_status(status, fp);
                 break;
                 }
                PDU_modified_parts_list = list;
               }
             }
           }

         _pdm_debug("switching on active column", 0);
         switch(act_col)
         {
           case DISPEXT_COL:  /* Display Attribute form for existing assembly */
                _pdm_debug("DISPEXT_COL column", 0);

                review_mode = TRUE;

                msg = (char *)PDUtranslate_message(PDM_I_ADDED_ROW);

                if (strcmp(current_rev_assy->ex_catalog, msg) == 0)
                  {
                  _pdm_debug("row was added; no existing attrs", 0);
                  PDUdisplay_status(PDM_E_DISP_EXIST_ATTRS, fp);
                  break;
                  }

                if (current_rev_assy->ex_attr_data == NULL)
                 {
                 /* Get attributes for the catalog,part,and rev */
                 status = PDUget_part_bufrs(current_rev_assy->ex_catalog,
                                            current_rev_assy->ex_partid,
                                            current_rev_assy->ex_revision,
                                            &current_rev_assy->ex_attr_data,
                                            review_mode);
                 _pdm_status("PDUget_part_bufrs", status);
                 if (status != PDM_S_SUCCESS)
                   {
                   PDUdisplay_status(status, fp);
                   if (current_rev_assy->ex_attr_data)
                     {
                     free_attr_data_buffer(&current_rev_assy->ex_attr_data);
                     current_rev_assy->ex_attr_data = NULL;
                     break;
                     }
                   }
                 }

                if (!forms.attr_value_form_id)
                 {
                  _pdm_debug("creating attr form", 0);
                  status = FIf_new(ATTR_VALUE_FORM,"Attrib_Value",
                          attr_value_notification_routine, 
                          &forms.attr_value_form_id); 
                  if (status != FI_SUCCESS)
                    {
                    _pdm_debug("error creating form", 0);
                    break;
                    }
                  GRcreate_pull_down_list(ATTR_VALUE_FORM, 
                    forms.attr_value_form_id, VALUE_LIST,MAX_ROWS,
                    VIS_ROWS,PDU_value_list, list_size, 1, &PDU_value_pulldown);
                 } 

                 /* set mode of mcf to review mode */
                 _pdm_debug("setting form to FI_REVIEW mode", 0);
                 FIfld_set_mode(forms.attr_value_form_id,ATTR_MCF,0, FI_REVIEW); 
                 FIfld_set_mode(forms.attr_value_form_id,ATTR_MCF,1, FI_REVIEW);

                 /* Fill mcf with attribute data */
                 PDU_form_id = forms.attr_value_form_id;
                 _pdm_debug("loading attr form", 0);
                 status = PDU_display_attr_in_mcf(
                                            current_rev_assy->ex_attr_data);
                 _pdm_status("PDU_display_attr_in_mcf", status);
                 if (status != PDM_S_SUCCESS)
                   if (current_rev_assy->ex_attr_data)
                     {
                     free_attr_data_buffer(&current_rev_assy->ex_attr_data);
                     current_rev_assy->ex_attr_data = NULL;
                     PDUdisplay_status(status, fp);
                     break;
                     }
                
                 FIg_set_text(forms.attr_value_form_id,CAT_FLD,
                              current_rev_assy->ex_catalog);
                 FIg_set_text(forms.attr_value_form_id,PART_FLD,
                              current_rev_assy->ex_partid);
                 FIg_set_text(forms.attr_value_form_id,REV_FLD,
                              current_rev_assy->ex_revision);
                 FIf_erase(forms.rev_assy_form_id);
                 FIf_display(forms.attr_value_form_id);
                 PDUdisplay_status(PDM_S_SUCCESS, fp);

           break;  /* case 5 */

           case NEWLEV_COL:  /* ex level column */
                _pdm_debug("NEWLEV_COL column", 0);
           break;
           
           case CAT_COL:  /* catalog for new assembly */
                _pdm_debug("CAT_COL column", 0);
                 /* Get text from mcf catalog field */

                FIfld_get_text_length(fp,REV_MCF,act_row,act_col,&length);
                text = (char *)malloc(sizeof(char) * length + 1);
                memset(text,NULL,sizeof(char) * length + 1);
                FIfld_get_text(fp,REV_MCF,act_row,act_col,length, 
                              (unsigned char *)text, &select, &pos);
                _pdm_debug("text = <%s>", text);

                msg = (char *)PDUtranslate_message(PDM_I_DELETED);
                if ((strcmp(current_rev_assy->delete, "Y") == 0) &&
                    (text) && (strcmp(text, msg) == 0))
                  {
                  _pdm_debug("part is marked for deleted", 0);
                  FIfld_set_text(fp, REV_MCF, act_row, CAT_COL, msg, FALSE);
                  PDUdisplay_status(PDM_E_MARKED_FOR_DELETE, fp);
                  break;
                  }

                if (!text)
                  {
                  PDUfill_in_string(&(current_rev_assy)->new_catalog,
                                    NULL_STRING);
                  break;
                  }
                if (!(strlen(text)))
                  {
                  PDUfill_in_string(&(current_rev_assy)->new_catalog,
                                    NULL_STRING);
                  break;
                  }

                _pdm_debug("Entered catalog %s", text);

                if (strcmp(text,current_rev_assy->ex_catalog) != 0)
                  {
                  _pdm_debug("validating catalog", 0);
                  PDU_main_form_cat = FALSE;
                  status = PDUvalidate_catalog("",text, 0);
                  _pdm_debug("PDUvalidate_catalog", status);
                  if (status != PDM_S_SUCCESS)
                    {
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,NULL_STRING, 
                                   FALSE);
                    PDUfill_in_string(&current_rev_assy->new_catalog, 
                                      NULL_STRING);
                    PDUdisplay_status(status, fp);
                    break;
                    }
                  PDUdisplay_status(status, fp);
                  }

                if ((strcmp(current_rev_assy->ex_catalog, text) == 0) &&
                    (strcmp(current_rev_assy->ex_partid, 
                            current_rev_assy->new_partid) == 0) &&
                    (strcmp(current_rev_assy->ex_revision,
                            current_rev_assy->new_revision) == 0))
                  {
                  strcpy(current_rev_assy->add, "N");
                  PDUupdate_mult_files_for_rev_assy("add", "N");

                  strcpy(current_rev_assy->add_db, "N");
                  PDUupdate_mult_files_for_rev_assy("add_db", "N");

                  PDUfill_in_string(&(current_rev_assy)->new_catalog, text);
                  break;
                  }

                _pdm_debug("add = <%s>", current_rev_assy->add);

                /* Modify assembly */
                if (strcmp(current_rev_assy->add,"N") == 0)
                  {
                  _pdm_debug("modifying existing part", 0);
                  if (compare_parts(current_rev_assy->ex_catalog,
                                    current_rev_assy->ex_partid,
                                    current_rev_assy->ex_revision,
                                    text, 
                                    current_rev_assy->new_partid,
                                    current_rev_assy->new_revision))
                    {
                    /* catalog, part, rev are different */
                    strcpy(current_rev_assy->add,"Y");
                    PDUupdate_mult_files_for_rev_assy("add", "Y");

                    _pdm_debug("catalog %s", text);
                    /* verify if part exist in db */
                    status = PDMcheck_partnum(
                                             text,
                                             current_rev_assy->new_partid,
                                             current_rev_assy->new_revision);
                    _pdm_status("PDMcheck_partnum status",status);
                    if (status == PDM_S_SUCCESS)
                      {
                      strcpy(current_rev_assy->add_db,"N");
                      PDUupdate_mult_files_for_rev_assy("add_db", "N");

                      if (current_rev_assy->new_attr_data)
                        {
                        free_attr_data_buffer(&current_rev_assy->new_attr_data);
                        current_rev_assy->new_attr_data = NULL;
                        }
                      PDUdisplay_status(status, fp);
                      }
                    else if (status == PDM_E_PARTREV_NOT_FOUND)
                      {
                      strcpy(current_rev_assy->add_db,"Y");
                      PDUupdate_mult_files_for_rev_assy("add_db", "Y");
                      }
                    else if (status == SQL_I_NO_ROWS_FOUND)
                      {
                      status = PDUcheck_if_parametric(text, &param, &p_exists);
                      _pdm_status("PDUcheck_if_parametric", status);

                      if (param && p_exists)
                        {
                        _pdm_debug("setting add_db to N", 0);
                        strcpy(current_rev_assy->add_db, "N");
                        PDUupdate_mult_files_for_rev_assy("add_db", "N");
                        }
                      else if (param && (!p_exists))
                        {
                        _pdm_debug("parametric part does not exist", 0);
                        PDUdisplay_status(PDM_E_ADD_PARAM_REV_ASSY, fp);
                        PDUfill_in_string(&(current_rev_assy)->new_catalog,
                                          NULL_STRING);
                        FIfld_set_text(fp, REV_MCF, act_row, CAT_COL,
                                       NULL_STRING, FALSE);
                        strcpy(current_rev_assy->add_db, "N");
                        PDUupdate_mult_files_for_rev_assy("add_db", "N");
                        break;
                        }
                      }
                    }
                  else  /* same part, put defaults back */
                    {
                    _pdm_debug("parts are the same ",0);
                    strcpy(current_rev_assy->add,"N");
                    PDUupdate_mult_files_for_rev_assy("add", "N");

                    strcpy(current_rev_assy->add_db,"N");
                    PDUupdate_mult_files_for_rev_assy("add_db", "N");

                    if (current_rev_assy->new_attr_data)
                      {
                      free_attr_data_buffer(&current_rev_assy->new_attr_data);
                      current_rev_assy->new_attr_data = NULL;
                      }
                    }
                  }
                else
                  {
                  _pdm_debug("adding new row", 0);
                  if ((current_rev_assy->new_partid) &&
                      (current_rev_assy->new_revision) &&
                      (strlen(current_rev_assy->new_partid)) &&
                      (strlen(current_rev_assy->new_revision)))
                    {
                    /* verify if part exist in db */
                    status = PDMcheck_partnum(
                                            text,
                                            current_rev_assy->new_partid,
                                            current_rev_assy->new_revision);
                    _pdm_status("PDMcheck_partnum status",status);
                    if (status == PDM_S_SUCCESS)
                      {
                      strcpy(current_rev_assy->add_db,"N");
                      PDUupdate_mult_files_for_rev_assy("add_db", "N");

                      if (current_rev_assy->new_attr_data)
                        {
                        free_attr_data_buffer(&current_rev_assy->new_attr_data);
                        current_rev_assy->new_attr_data = NULL;
                        }
                      }
                    else if (status == PDM_E_PARTREV_NOT_FOUND)
                      {
                      strcpy(current_rev_assy->add_db,"Y");
                      PDUupdate_mult_files_for_rev_assy("add_db", "Y");
                      }
                    else if (status == SQL_I_NO_ROWS_FOUND)
                      {
                      status = PDUcheck_if_parametric(text, &param, &p_exists);
                      _pdm_status("PDUcheck_if_parametric", status);

                      if (param && p_exists)
                        {
                        _pdm_debug("setting add_db to N", 0);
                        strcpy(current_rev_assy->add_db, "N");
                        PDUupdate_mult_files_for_rev_assy("add_db", "N");
                        }
                      else if (param && (!p_exists))
                        {
                        _pdm_debug("parametric part does not exist", 0);
                        PDUdisplay_status(PDM_E_ADD_PARAM_REV_ASSY, fp);
                        PDUfill_in_string(&(current_rev_assy)->new_catalog,
                                          NULL_STRING);
                        FIfld_set_text(fp, REV_MCF, act_row, CAT_COL,
                                       NULL_STRING, FALSE);
                        strcpy(current_rev_assy->add_db, "N");
                        PDUupdate_mult_files_for_rev_assy("add_db", "N");
                        break;
                        }
                      }
                    }
                  else
                    {
                    strcpy(current_rev_assy->add_db,"Y");
                    PDUupdate_mult_files_for_rev_assy("add_db", "Y");
                    _pdm_debug("part and rev have not been entered yet", 0);
                    }
                  }
                 
                if (((current_rev_assy->new_catalog) &&
                     (strcmp(current_rev_assy->new_catalog, text) != 0) &&
                     (strcmp(current_rev_assy->add_db, "Y") == 0)))
                  {
                  _pdm_debug("checking catalog type", 0);
                  status = PDMquery_catalog_type(text, type);
                  _pdm_status("PDMquery_catalog_type", status);
                  _pdm_debug("catalog type = <%s>", type);

                  if ((strcmp(type, "P") != 0) &&
                      (strcmp(type, "CID") != 0) &&
                      (strcmp(type, "PXT") != 0) &&
                      (strcmp(type, "EID") != 0))
                    {
                    _pdm_debug("catalog is not parametric", 0);

                    _pdm_debug("checking to see if buffers exist", 0);
                    if (current_rev_assy->new_attr_data)
                      {
                      free_attr_data_buffer(&current_rev_assy->new_attr_data);
                      current_rev_assy->new_attr_data = NULL;
                      }
                    _pdm_debug("getting attributes", 0);
                    _pdm_debug("cat = <%s>", text);
                    _pdm_debug("part = <%s>", current_rev_assy->new_partid);
                    _pdm_debug("rev = <%s>",current_rev_assy->new_revision);

                    if ((!strlen(current_rev_assy->new_partid)) ||
                             (!strlen(current_rev_assy->new_revision)))
                      review_mode = FALSE;
                    else if (strcmp(current_rev_assy->add_db, "N") == 0)
                      review_mode = TRUE;
                    else
                      review_mode = FALSE;

                    status = PDUget_part_bufrs(
                                       text,
                                       current_rev_assy->new_partid,
                                       current_rev_assy->new_revision,
                                       &current_rev_assy->new_attr_data,
                                       review_mode);
                    _pdm_status("PDUget_part_bufrs", status);
                    if (status != PDM_S_SUCCESS)
                      {
                      PDUdisplay_status(status, fp);
                      if (current_rev_assy->new_attr_data)
                        {
                        free_attr_data_buffer(&current_rev_assy->new_attr_data);
                        current_rev_assy->new_attr_data = NULL;
                        }
                      break;
                      }
                    }
                  else
                    {
                    _pdm_debug("catalog is parametric", 0);
                    PDUfill_in_string(&(current_rev_assy)->new_parttype, "P");
                    }
                  }

                _pdm_debug("writing to new_catalog", 0);
                PDUfill_in_string(&current_rev_assy->new_catalog, text);

                if ((strlen(current_rev_assy->new_catalog)) &&
                    (strlen(current_rev_assy->new_partid)) &&
                    (strlen(current_rev_assy->new_revision)) &&
                    (strcmp(current_rev_assy->add, "Y") == 0))
                  {
                  if (strcmp(current_rev_assy->add_db, "N") == 0)
                    {
                    _pdm_debug("query for the parttype", 0);
                    status = PDUget_parttype(current_rev_assy->new_catalog,
                                             current_rev_assy->new_partid,
                                             current_rev_assy->new_revision,
                                             &(current_rev_assy)->new_parttype);
                    _pdm_status("PDUget_parttype", status);

                    if (current_rev_assy->new_level != 0)
                      {
                      _pdm_debug("check for cyclic placement", 0);
                      status = PDUcheck_cyclic_placement_for_rev_assy(act_row);
                  _pdm_status("PDUcheck_cyclic_placement_for_rev_assy", status);
                      if (status != PDM_S_SUCCESS)
                        break;
                      }
                    }
                  else
                    {
                    if ((strcmp(current_rev_assy->ex_catalog, 
                                current_rev_assy->new_catalog) == 0))
                      {
                      _pdm_debug("defaulting new parttype to ex_parttype", 0);
                      PDUfill_in_string(&(current_rev_assy)->new_parttype,
                                        current_rev_assy->ex_parttype);
                      }
                    else
                      {
                      _pdm_debug("get the parttype from the data bufr", 0);
                      if (current_rev_assy->new_attr_data)
                        {
                        attrs = current_rev_assy->new_attr_data;
                        if ((attrs) && (attrs->data_bufr))
                          {
                          MEMbuild_array(attrs->data_bufr);
                          PDUsetup_buffer(attrs->data_bufr, ROW, &data_row);
                          PDUget_buffer_col(attrs->data_bufr, "p_parttype",
                                            &type_col);
                          PDUfill_in_string(&current_rev_assy->new_parttype,
                          data_row[(attrs->data_bufr->columns * 0) + type_col]);
                          }
                        }
                      }
                    }

                  _pdm_debug("parttype = <%s>",current_rev_assy->new_parttype);
                  }

                PDUdisplay_status(PDM_S_SUCCESS, fp);

           break;

           case PART_COL:   /* part for new assembly */

                _pdm_debug("PART_COL column", 0);

                FIfld_get_text_length(fp,REV_MCF,act_row,act_col,&length);
                text = (char *)malloc(sizeof(char) * length + 1);
                memset(text,NULL,sizeof(char) * length + 1);
                FIfld_get_text(fp,REV_MCF,act_row,act_col,length,
                                   (unsigned char *)text, &select, &pos);

                msg = (char *)PDUtranslate_message(PDM_I_DELETED);
                if ((strcmp(current_rev_assy->delete, "Y") == 0) &&
                    (text) && (strcmp(text, msg) == 0))
                  {
                  _pdm_debug("part is marked for deleted", 0);
                  FIfld_set_text(fp, REV_MCF, act_row, PART_COL, msg, FALSE);
                  PDUdisplay_status(PDM_E_MARKED_FOR_DELETE, fp);
                  break;
                  }

                if (!text)
                  {
                  PDUfill_in_string(&(current_rev_assy)->new_partid,
                                    NULL_STRING);
                  break;
                  }
                if (!(strlen(text)))
                  {
                  PDUfill_in_string(&(current_rev_assy)->new_partid,
                                    NULL_STRING);
                  break;
                  }

                if ((!current_rev_assy->new_catalog) || 
                    ((current_rev_assy->new_catalog) && 
                    (!(strlen(current_rev_assy->new_catalog)))))
                  {
                  _pdm_debug("catalog has not been entered", 0);
                  PDUdisplay_status(PDM_I_ENTER_CATALOG, fp);
                  break;
                  }

                _pdm_debug("text = <%s>", text);

                if (strcmp(current_rev_assy->new_partid, text) == 0)
                  {
                  _pdm_debug("part was not changed", 0);
                  break;
                  }

                if ((strcmp(current_rev_assy->ex_partid, text) == 0) &&
                    (strcmp(current_rev_assy->ex_catalog, 
                            current_rev_assy->new_catalog) == 0) &&
                    (strcmp(current_rev_assy->ex_revision,
                            current_rev_assy->new_revision) == 0))
                  {
                  strcpy(current_rev_assy->add, "N");
                  PDUupdate_mult_files_for_rev_assy("add", "N");

                  strcpy(current_rev_assy->add_db, "N");
                  PDUupdate_mult_files_for_rev_assy("add_db", "N");

                  PDUfill_in_string(&(current_rev_assy)->new_partid, text);
                  break;
                  }

                /* Validate part */
                status = PDUcheck_part_syntax(text);
                if (status != PDM_S_SUCCESS)
                  {
                  PDUdisplay_status(status, fp);
                  FIfld_set_text(fp,REV_MCF,act_row,act_col,NULL_STRING,FALSE);
                  FIfld_pos_cursor(fp, REV_MCF, act_row, pos, PART_COL, 1,0,0);
                  break;
                  } 

                _pdm_debug("Entered part %s", text);
                strcpy(prev_add_db_value, current_rev_assy->add_db);

                /* Modify Assembly */
                if (strcmp(current_rev_assy->add,"N") == 0)
                  {
                  _pdm_debug("modifying existing part", 0);
                  if ((current_rev_assy->new_catalog) &&
                      (current_rev_assy->new_revision) &&
                      (strlen(current_rev_assy->new_catalog)) &&
                      (strlen(current_rev_assy->new_revision)) &&
                      (compare_parts(current_rev_assy->ex_catalog,
                                     current_rev_assy->ex_partid,
                                     current_rev_assy->ex_revision,
                                     current_rev_assy->new_catalog,
                                     text,
                                     current_rev_assy->new_revision)))
                    {
                    _pdm_debug("catalog, part, rev are different", 0);
                    strcpy(current_rev_assy->add,"Y");
                    PDUupdate_mult_files_for_rev_assy("add", "Y");

                    /* Verify if part exist in db */
                    status = PDMcheck_partnum(
                                 current_rev_assy->new_catalog,
                                 text,
                                 current_rev_assy->new_revision);
                    _pdm_status("PDMcheck_partnum",status);

                    if (status == PDM_S_SUCCESS)
                      {
                      strcpy(current_rev_assy->add_db,"N");
                      PDUupdate_mult_files_for_rev_assy("add_db", "N");

                      if (current_rev_assy->new_attr_data)
                        {
                        free_attr_data_buffer(&current_rev_assy->new_attr_data);
                        current_rev_assy->new_attr_data = NULL;
                        }

                      _pdm_debug("clearing out the desc", 0);
                      FIfld_set_text(fp, REV_MCF, act_row, DESC_COL, 
                                     NULL_STRING, FALSE);
                      PDUfill_in_string(&current_rev_assy->new_desc, 
                                     NULL_STRING);

                      _pdm_debug("getting the desc", 0);
                      status = PDUget_desc(current_rev_assy->new_catalog,
                                           text,
                                           current_rev_assy->new_revision,
                                           &desc);
                      _pdm_status("PDUget_desc", status);

                      if (status == PDM_S_SUCCESS)
                        {
                        FIfld_set_text(fp, REV_MCF, act_row, DESC_COL, 
                                       desc, FALSE);
                        PDUfill_in_string(&current_rev_assy->new_desc, desc);
                        }
                      }
                    else if (status == PDM_E_PARTREV_NOT_FOUND)
                      {
                      strcpy(current_rev_assy->add_db,"Y");
                      PDUupdate_mult_files_for_rev_assy("add_db", "Y");
                      }
                    else if (status == SQL_I_NO_ROWS_FOUND)
                      {
                      status = PDUcheck_if_parametric(
                                              current_rev_assy->new_catalog, 
                                              &param, &p_exists);
                      _pdm_status("PDUcheck_if_parametric", status);

                      if (param && p_exists)
                        {
                        _pdm_debug("setting add_db to N", 0);
                        strcpy(current_rev_assy->add_db, "N");
                        PDUupdate_mult_files_for_rev_assy("add_db", "N");
                        }
                      else if (param && (!p_exists))
                        {
                        _pdm_debug("parametric part does not exist", 0);
                        PDUdisplay_status(PDM_E_ADD_PARAM_REV_ASSY, fp);
                        PDUfill_in_string(&(current_rev_assy)->new_partid,
                                          NULL_STRING);
                        FIfld_set_text(fp, REV_MCF, act_row, PART_COL,
                                       NULL_STRING, FALSE);
                        strcpy(current_rev_assy->add_db, "N");
                        PDUupdate_mult_files_for_rev_assy("add_db", "N");
                        break;
                        }
                      }
                    PDUdisplay_status(status, fp);
                    } 
                  else
                    { 
                    _pdm_debug("Same new part as old part", 0);
                    strcpy(current_rev_assy->add,"N");
                    PDUupdate_mult_files_for_rev_assy("add", "N");

                    FIfld_set_text(fp,REV_MCF,act_row,LOCFILE_COL,"", FALSE);
                    FIfld_set_text(fp,REV_MCF,act_row,STGFILE_COL,"", FALSE);
                    PDUfill_in_string(&current_rev_assy->new_desc, NULL_STRING);
                    PDUfill_in_string(&current_rev_assy->new_cofilename,
                                       NULL_STRING);
                    PDUfill_in_string(&current_rev_assy->new_cifilename,
                                       NULL_STRING);
                    strcpy(current_rev_assy->add_db,"N");
                    PDUupdate_mult_files_for_rev_assy("add_db", "N");

                    if (current_rev_assy->new_attr_data)
                      {
                      free_attr_data_buffer(&current_rev_assy->new_attr_data);
                      current_rev_assy->new_attr_data = NULL;
                      }
                    PDUdisplay_status(PDM_S_SUCCESS, fp);
                    }
                  }
                else  /* adding new row */
                  {
                  _pdm_debug("adding new part to structure", 0);
                  /* Verify if part exist in db */
                  if ((current_rev_assy->new_catalog) &&
                      (text) &&
                      (current_rev_assy->new_revision) &&
                      (strlen(current_rev_assy->new_catalog)) &&
                      (strlen(text)) &&
                      (strlen(current_rev_assy->new_revision)))
                    {
                    status = PDMcheck_partnum(
                                  current_rev_assy->new_catalog,
                                  text,
                                  current_rev_assy->new_revision);
                    _pdm_status("PDMcheck_partnum",status);

                    if (status == PDM_S_SUCCESS)
                      {
                      strcpy(current_rev_assy->add_db,"N");
                      PDUupdate_mult_files_for_rev_assy("add_db", "N");

                      if (current_rev_assy->new_attr_data)
                        {
                        free_attr_data_buffer(&current_rev_assy->new_attr_data);
                        current_rev_assy->new_attr_data = NULL;
                        }
                      _pdm_debug("clearing out the desc", 0);
                      FIfld_set_text(fp, REV_MCF, act_row, DESC_COL, 
                                     NULL_STRING, FALSE);
                      PDUfill_in_string(&current_rev_assy->new_desc, 
                                     NULL_STRING);

                      _pdm_debug("getting the desc", 0);
                      status = PDUget_desc(current_rev_assy->new_catalog,
                                           text,
                                           current_rev_assy->new_revision,
                                           &desc);
                      _pdm_status("PDUget_desc", status);

                      if (status == PDM_S_SUCCESS)
                        {
                        FIfld_set_text(fp, REV_MCF, act_row, DESC_COL, 
                                       desc, FALSE);
                        PDUfill_in_string(&current_rev_assy->new_desc, 
                                       desc);
                        }
                      }
                    else if (status == PDM_E_PARTREV_NOT_FOUND)
                      {
                      strcpy(current_rev_assy->add_db,"Y");
                      PDUupdate_mult_files_for_rev_assy("add_db", "Y");
                      review_mode = FALSE;
                      }
                    else if (status == SQL_I_NO_ROWS_FOUND)
                      {
                      status = PDUcheck_if_parametric(
                                              current_rev_assy->new_catalog,
                                              &param, &p_exists);
                      _pdm_status("PDUcheck_if_parametric", status);

                      if (param && p_exists)
                        {
                        _pdm_debug("setting add_db to N", 0);
                        strcpy(current_rev_assy->add_db, "N");
                        PDUupdate_mult_files_for_rev_assy("add_db", "N");
                        }
                      else if (param && (!p_exists))
                        {
                        _pdm_debug("parametric part does not exist", 0);
                        PDUdisplay_status(PDM_E_ADD_PARAM_REV_ASSY, fp);
                        PDUfill_in_string(&(current_rev_assy)->new_partid,
                                          NULL_STRING);
                        FIfld_set_text(fp, REV_MCF, act_row, PART_COL,
                                       NULL_STRING, FALSE);
                        strcpy(current_rev_assy->add_db, "N");
                        PDUupdate_mult_files_for_rev_assy("add_db", "N");
                        break;
                        }
                      }
                    }
                  }

                if (((current_rev_assy->new_catalog) &&
                     (strlen(current_rev_assy->new_catalog)) &&
                     (current_rev_assy->new_revision) &&
                     (strlen(current_rev_assy->new_revision)) &&
                     (current_rev_assy->new_partid) &&
                     (strlen(current_rev_assy->new_partid)) &&  /* prev value */
                     (strcmp(current_rev_assy->new_partid, text) != 0) &&
                     (strcmp(current_rev_assy->add_db, "Y") == 0)))
                  {
                  _pdm_debug("checking catalog type", 0);
                  status = PDMquery_catalog_type(
                                         current_rev_assy->new_catalog, type);
                  _pdm_status("PDMquery_catalog_type", status);
                  _pdm_debug("catalog type = <%s>", type);

                  if ((strcmp(type, "P") == 0) ||
                      (strcmp(type, "CID") == 0) ||
                      (strcmp(type, "PXT") == 0) ||
                      (strcmp(type, "EID") == 0))
                    {
                    _pdm_debug("catalog is parametric", 0);
                    PDUdisplay_status(PDM_E_ADD_PARAM_REV_ASSY, fp);
                    FIfld_set_text(fp, REV_MCF, act_row, PART_COL,
                                   NULL_STRING, FALSE);
                    PDUfill_in_string(&current_rev_assy->new_partid,
                                      NULL_STRING);
                    break;
                    }

                  _pdm_debug("writing to new_partid", 0);
                  PDUfill_in_string(&current_rev_assy->new_partid, text);

                  _pdm_debug("checking to see if buffers exist", 0);
                  if ((strcmp(prev_add_db_value, "N") == 0) ||
                      (!current_rev_assy->new_attr_data))
                    {
                    if (current_rev_assy->new_attr_data)
                      {
                      free_attr_data_buffer(&current_rev_assy->new_attr_data);
                      current_rev_assy->new_attr_data = NULL;
                      }
                    _pdm_debug("getting attributes", 0);
                    _pdm_debug("cat = <%s>", current_rev_assy->new_catalog);
                    _pdm_debug("part = <%s>", current_rev_assy->new_partid);
                    _pdm_debug("rev = <%s>",current_rev_assy->new_revision);

                    if ((!strlen(current_rev_assy->new_partid)) ||
                             (!strlen(current_rev_assy->new_revision)))
                      review_mode = FALSE;
                    else if (strcmp(current_rev_assy->add_db, "N") == 0)
                      review_mode = TRUE;
                    else
                      review_mode = FALSE;

                    status = PDUget_part_bufrs(
                                       current_rev_assy->new_catalog,
                                       current_rev_assy->new_partid,
                                       current_rev_assy->new_revision,
                                       &current_rev_assy->new_attr_data,
                                       review_mode);
                    _pdm_status("PDUget_part_bufrs", status);
                    if (status != PDM_S_SUCCESS)
                      {
                      PDUdisplay_status(status, fp);
                      if (current_rev_assy->new_attr_data)
                        {
                        free_attr_data_buffer(&current_rev_assy->new_attr_data);
                        current_rev_assy->new_attr_data = NULL;
                        }
                      break;
                      }
                    }
                  }
                else
                  {
                  _pdm_debug("writing to new_partid", 0);
                  PDUfill_in_string(&current_rev_assy->new_partid, text);
                  }

                if ((strcmp(current_rev_assy->add_db,"Y") == 0) &&
                    (strcmp(current_rev_assy->new_parttype, "P") != 0) &&
                    (strcmp(current_rev_assy->new_parttype, "p") != 0))
                  {
                  _pdm_debug("accessing new_attr_data", 0);
                  if (current_rev_assy->new_attr_data)
                    attrs = current_rev_assy->new_attr_data;
                  else
                    {
                    PDUdisplay_status(PDM_E_NULL_BUFFER, fp);
                    PDUfill_in_string(&current_rev_assy->new_partid, 
                                      NULL_STRING);
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,NULL_STRING,
                                   FALSE);
                    break;
                    }
  
                  _pdm_debug("accessing attr_bufr", 0);
                  if (((attrs) && (!attrs->attr_bufr)) || (!attrs))
                    {
                    PDUdisplay_status(PDM_E_NULL_BUFFER, fp);
                    PDUfill_in_string(&current_rev_assy->new_partid, 
                                      NULL_STRING);
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,NULL_STRING,
                                   FALSE);
                    break;
                    }
  
                  status = PDUcheck_part_datatype(text, attrs->attr_bufr);
                  _pdm_status("PDUcheck_part_datatype", status);
                  if (status != PDM_S_SUCCESS)
                    {
                    PDUdisplay_status(status, fp);
                    PDUfill_in_string(&current_rev_assy->new_partid, 
                                      NULL_STRING);
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,NULL_STRING,
                                   FALSE);
                    break;
                    }
                  }

                if ((strlen(current_rev_assy->new_catalog)) &&
                    (strlen(current_rev_assy->new_partid)) &&
                    (strlen(current_rev_assy->new_revision)) &&
                    (strcmp(current_rev_assy->add, "Y") == 0))
                  {
                  if (strcmp(current_rev_assy->add_db, "N") == 0)
                    {
                    _pdm_debug("query for the parttype", 0);
                    status = PDUget_parttype(current_rev_assy->new_catalog,
                                             current_rev_assy->new_partid,
                                             current_rev_assy->new_revision,
                                             &(current_rev_assy)->new_parttype);
                    _pdm_status("PDUget_parttype", status);

                    if (current_rev_assy->new_level != 0)
                      {
                      _pdm_debug("check for cyclic placement", 0);
                      status = PDUcheck_cyclic_placement_for_rev_assy(act_row);
                  _pdm_status("PDUcheck_cyclic_placement_for_rev_assy", status);
                      if (status != PDM_S_SUCCESS)
                        break;
                      }
                    }
                  else
                    {
                    if ((strcmp(current_rev_assy->ex_catalog, 
                                current_rev_assy->new_catalog) == 0))
                      {
                      _pdm_debug("defaulting new parttype to ex_parttype", 0);
                      PDUfill_in_string(&(current_rev_assy)->new_parttype,
                                        current_rev_assy->ex_parttype);
                      }
                    else
                      {
                      _pdm_debug("get the parttype from the data bufr", 0);
                      if (current_rev_assy->new_attr_data)
                        {
                        attrs = current_rev_assy->new_attr_data;
                        if ((attrs) && (attrs->data_bufr))
                          {
                          MEMbuild_array(attrs->data_bufr);
                          PDUsetup_buffer(attrs->data_bufr, ROW, &data_row);
                          PDUget_buffer_col(attrs->data_bufr, "p_parttype",
                                            &type_col);
                          PDUfill_in_string(&current_rev_assy->new_parttype,
                          data_row[(attrs->data_bufr->columns * 0) + type_col]);
                          }
                        }
                      }
                    }

                  _pdm_debug("parttype = <%s>", current_rev_assy->new_parttype);
                  }

                PDUdisplay_status(PDM_S_SUCCESS, fp);

           break;
          
           case REV_COL:   /* revision column for new assembly */
                _pdm_debug("REV_COL column", 0);
              _pdm_debug("new_revision = <%s>", current_rev_assy->new_revision);

                 /* Get text from mcf revison column */
              
                 FIfld_get_text_length(fp,REV_MCF,act_row,act_col,&length);
                 text = (char *)malloc(sizeof(char) * length + 1);
                 memset(text,NULL,sizeof(char) * length + 1);
                 FIfld_get_text(fp,REV_MCF,act_row,act_col,length,
                    (unsigned char *)text, &select, &pos);
                 _pdm_debug("text = <%s>", text);
          
                msg = (char *)PDUtranslate_message(PDM_I_DELETED);
                if ((strcmp(current_rev_assy->delete, "Y") == 0) &&
                    (text) && (strcmp(text, msg) == 0))
                  {
                  _pdm_debug("part is marked for deleted", 0);
                  FIfld_set_text(fp, REV_MCF, act_row, REV_COL, msg, FALSE);
                  PDUdisplay_status(PDM_E_MARKED_FOR_DELETE, fp);
                  break;
                  }

                if (!text)
                  {
                  _pdm_debug("text string is empty", 0);
                  PDUfill_in_string(&(current_rev_assy)->new_revision,
                                    NULL_STRING);
                  break;
                  }
                if (!(strlen(text)))
                  {
                  _pdm_debug("text string is empty", 0);
                  PDUfill_in_string(&(current_rev_assy)->new_revision,
                                    NULL_STRING);
                  break;
                  }

                if (strcmp(current_rev_assy->delete, "Y") == 0)
                  {
                  _pdm_debug("part is marked for delete", 0);
                  break;
                  }

                if ((!current_rev_assy->new_catalog) || 
                    ((current_rev_assy->new_catalog) && 
                    (!(strlen(current_rev_assy->new_catalog)))))
                  {
                  _pdm_debug("catalog has not been entered", 0);
                  PDUdisplay_status(PDM_I_ENTER_CATALOG, fp);
                  break;
                  }

                if ((!current_rev_assy->new_partid) || 
                    ((current_rev_assy->new_partid) && 
                    (!(strlen(current_rev_assy->new_partid)))))
                  {
                  _pdm_debug("partid has not been entered", 0);
                  PDUdisplay_status(PDM_I_ENTER_PART, fp);
                  break;
                  }

                _pdm_debug("text %s",text);

                if (strcmp(current_rev_assy->new_revision, text) == 0)
                  {
                  _pdm_debug("new_revision = <%s>", current_rev_assy->new_revision);
                  _pdm_debug("entered revision = new_revision", 0);
                  break;
                  }

                if ((strcmp(current_rev_assy->ex_revision, text) == 0) &&
                    (strcmp(current_rev_assy->ex_catalog, 
                            current_rev_assy->new_catalog) == 0) &&
                    (strcmp(current_rev_assy->ex_partid,
                            current_rev_assy->new_partid) == 0))
                  {
                  _pdm_debug("entered revision = ex_revision", 0);
                  strcpy(current_rev_assy->add, "N");
                  PDUupdate_mult_files_for_rev_assy("add", "N");
                  strcpy(current_rev_assy->add_db, "N");
                  PDUupdate_mult_files_for_rev_assy("add_db", "N");
                  PDUfill_in_string(&(current_rev_assy)->new_revision, text);
                  break;
                  }

                /* Validate part */
                status = PDUcheck_rev_syntax(text);
                _pdm_status("PDUcheck_rev_syntax", status);
                if (status != PDM_S_SUCCESS)
                  {
                  PDUdisplay_status(status, fp);
                  PDUfill_in_string(&current_rev_assy->new_revision, 
                                    NULL_STRING);
                  FIfld_set_text(fp,REV_MCF,act_row,act_col,NULL_STRING,FALSE);
                  break;
                  } 

                _pdm_debug("Entered revision %s",text);

                strcpy(prev_add_db_value, current_rev_assy->add_db);

                /* Modify Assembly */
                if (strcmp(current_rev_assy->add,"N") == 0)
                  {
                  _pdm_debug("modifying existing part", 0);
                  if ((current_rev_assy->new_catalog) &&
                      (current_rev_assy->new_partid) &&
                      (strlen(current_rev_assy->new_catalog)) &&
                      (strlen(current_rev_assy->new_partid)) &&
                      (strlen(text)) &&
                      (compare_parts(current_rev_assy->ex_catalog,
                                     current_rev_assy->ex_partid,
                                     current_rev_assy->ex_revision,
                                     current_rev_assy->new_catalog,
                                     current_rev_assy->new_partid,
                                     text)))
                    {
                    _pdm_debug("catalog, part, rev are different", 0);
                    strcpy(current_rev_assy->add,"Y");
                    PDUupdate_mult_files_for_rev_assy("add", "Y");

                    /* Verify if part exist in db */
                    status = PDMcheck_partnum(
                                 current_rev_assy->new_catalog,
                                 current_rev_assy->new_partid,
                                 text);
                    _pdm_status("PDMcheck_partnum",status);

                    if (status == PDM_S_SUCCESS)
                      {
                      strcpy(current_rev_assy->add_db,"N");
                      PDUupdate_mult_files_for_rev_assy("add_db", "N");
                      if (current_rev_assy->new_attr_data)
                        {
                        free_attr_data_buffer(&current_rev_assy->new_attr_data);
                        current_rev_assy->new_attr_data = NULL;
                        }

                      _pdm_debug("clearing out the desc", 0);
                      FIfld_set_text(fp, REV_MCF, act_row, DESC_COL, 
                                     NULL_STRING, FALSE);
                      PDUfill_in_string(&current_rev_assy->new_desc, 
                                     NULL_STRING);

                      _pdm_debug("getting the desc", 0);
                      status = PDUget_desc(current_rev_assy->new_catalog,
                                           current_rev_assy->new_partid,
                                           text, &desc);
                      _pdm_status("PDUget_desc", status);

                      if (status == PDM_S_SUCCESS)
                        {
                        FIfld_set_text(fp, REV_MCF, act_row, DESC_COL, 
                                       desc, FALSE);
                        PDUfill_in_string(&current_rev_assy->new_desc, 
                                       desc);
                        }
                      }
                    else if (status == PDM_E_PARTREV_NOT_FOUND)
                      {
                      _pdm_debug("part does not exist; setting add_db to Y", 0);
                      strcpy(current_rev_assy->add_db,"Y");
                      PDUupdate_mult_files_for_rev_assy("add_db", "Y");
                      }
                    else if (status == SQL_I_NO_ROWS_FOUND)
                      {
                      status = PDUcheck_if_parametric(
                                              current_rev_assy->new_catalog, 
                                              &param, &p_exists);
                      _pdm_status("PDUcheck_if_parametric", status);

                      if (param && p_exists)
                        {
                        _pdm_debug("setting add_db to N", 0);
                        strcpy(current_rev_assy->add_db, "N");
                        PDUupdate_mult_files_for_rev_assy("add_db", "N");
                        }
                      else if (param && (!p_exists))
                        {
                        _pdm_debug("parametric part does not exist", 0);
                        PDUdisplay_status(PDM_E_ADD_PARAM_REV_ASSY, fp);
                        PDUfill_in_string(&(current_rev_assy)->new_revision,
                                          NULL_STRING);
                        FIfld_set_text(fp, REV_MCF, act_row, REV_COL, 
                                       NULL_STRING, FALSE);
                        strcpy(current_rev_assy->add_db, "N");
                        PDUupdate_mult_files_for_rev_assy("add_db", "N");
                        break;
                        }
                      }
                    } 
                  else
                    { 
                    _pdm_debug("same part as old part", 0);
                    strcpy(current_rev_assy->add,"N");
                    PDUupdate_mult_files_for_rev_assy("add", "N");
                    if (current_rev_assy->new_attr_data)
                      {
                      free_attr_data_buffer(
                                      &current_rev_assy->new_attr_data);
                      current_rev_assy->new_attr_data = NULL;
                      }
                    }
                  }
                else  /* adding new row */
                  {
                  _pdm_debug("adding new part to structure", 0);
                  /* Verify if part exist in db */
                  if ((current_rev_assy->new_catalog) &&
                      (current_rev_assy->new_partid) &&
                      (text) &&
                      (strlen(current_rev_assy->new_catalog)) &&
                      (strlen(current_rev_assy->new_partid)) &&
                      (strlen(text)))
                    {
                    status = PDMcheck_partnum(
                                  current_rev_assy->new_catalog,
                                  current_rev_assy->new_partid,
                                  text);
                    _pdm_status("PDMcheck_partnum",status);

                    if (status == PDM_S_SUCCESS)
                      {
                      strcpy(current_rev_assy->add_db,"N");
                      PDUupdate_mult_files_for_rev_assy("add_db", "N");
                      if (current_rev_assy->new_attr_data)
                        {
                        free_attr_data_buffer(&current_rev_assy->new_attr_data);
                        current_rev_assy->new_attr_data = NULL;
                        }
                      _pdm_debug("clearing out the desc", 0);
                      FIfld_set_text(fp, REV_MCF, act_row, DESC_COL, 
                                     NULL_STRING, FALSE);
                      PDUfill_in_string(&current_rev_assy->new_desc, 
                                     NULL_STRING);

                      _pdm_debug("getting the desc", 0);
                      status = PDUget_desc(current_rev_assy->new_catalog,
                                           current_rev_assy->new_partid,
                                           text, &desc);
                      _pdm_status("PDUget_desc", status);

                      if (status == PDM_S_SUCCESS)
                        {
                        FIfld_set_text(fp, REV_MCF, act_row, DESC_COL, 
                                       desc, FALSE);
                        PDUfill_in_string(&current_rev_assy->new_desc, 
                                       desc);
                        }
                      }
                    else if (status == PDM_E_PARTREV_NOT_FOUND)
                      {
                      strcpy(current_rev_assy->add_db,"Y");
                      PDUupdate_mult_files_for_rev_assy("add_db", "Y");
                      }
                    else if (status == SQL_I_NO_ROWS_FOUND)
                      {
                      status = PDUcheck_if_parametric(
                                              current_rev_assy->new_catalog, 
                                              &param, &p_exists);
                      _pdm_status("PDUcheck_if_parametric", status);

                      if (param && p_exists)
                        {
                        _pdm_debug("setting add_db to N", 0);
                        strcpy(current_rev_assy->add_db, "N");
                        PDUupdate_mult_files_for_rev_assy("add_db", "N");
                        }
                      else if (param && (!p_exists))
                        {
                        _pdm_debug("parametric part does not exist", 0);
                        PDUdisplay_status(PDM_E_ADD_PARAM_REV_ASSY, fp);
                        PDUfill_in_string(&(current_rev_assy)->new_revision,
                                          NULL_STRING);
                        FIfld_set_text(fp, REV_MCF, act_row, REV_COL,
                                       NULL_STRING, FALSE);
                        strcpy(current_rev_assy->add_db, "N");
                        PDUupdate_mult_files_for_rev_assy("add_db", "N");
                        break;
                        }
                      }
                    }
                  }         

                _pdm_debug("catalog = <%s>", current_rev_assy->new_catalog);
                _pdm_debug("partid = <%s>", current_rev_assy->new_partid);
                _pdm_debug("revision = <%s>", current_rev_assy->new_revision);
                _pdm_debug("add_db = <%s>", current_rev_assy->add_db);
                _pdm_debug("text = <%s>", text);

                if (((current_rev_assy->new_catalog) &&
                     (strlen(current_rev_assy->new_catalog)) &&
                     (current_rev_assy->new_partid) &&
                     (strlen(current_rev_assy->new_partid)) &&
                     (current_rev_assy->new_revision) &&  /* prev_value */
                     /*(strlen(current_rev_assy->new_revision)) &&*/
                     (strcmp(current_rev_assy->new_revision, text) != 0) &&
                     (strcmp(current_rev_assy->add_db, "Y") == 0)))
                  {
                  _pdm_debug("checking catalog type", 0);
                  status = PDMquery_catalog_type(
                                         current_rev_assy->new_catalog, type);
                  _pdm_status("PDMquery_catalog_type", status);
                  _pdm_debug("catalog type = <%s>", type);
     
                  if ((strcmp(type, "P") == 0) ||
                      (strcmp(type, "CID") == 0) ||
                      (strcmp(type, "PXT") == 0) ||
                      (strcmp(type, "EID") == 0))
                    {
                    _pdm_debug("catalog is parametric", 0);
                    PDUdisplay_status(PDM_E_ADD_PARAM_REV_ASSY, fp);
                    FIfld_set_text(fp, REV_MCF, act_row, REV_COL, 
                                   NULL_STRING, FALSE);
                    PDUfill_in_string(&current_rev_assy->new_revision, 
                                      NULL_STRING);
                    break;
                    }

                  _pdm_debug("writing to new_revision", 0);
                  PDUfill_in_string(&current_rev_assy->new_revision, text);

                  _pdm_debug("checking to see if buffers exist", 0);
                  if ((strcmp(prev_add_db_value, "N") == 0) ||
                      (!current_rev_assy->new_attr_data))
                    {
                    if (current_rev_assy->new_attr_data)
                      {
                      free_attr_data_buffer(&current_rev_assy->new_attr_data);
                      current_rev_assy->new_attr_data = NULL;
                      }
                    _pdm_debug("getting attributes", 0);
                    _pdm_debug("cat = <%s>", current_rev_assy->new_catalog);
                    _pdm_debug("part = <%s>", current_rev_assy->new_partid);
                    _pdm_debug("rev = <%s>",current_rev_assy->new_revision);

                    if ((!strlen(current_rev_assy->new_partid)) ||
                             (!strlen(current_rev_assy->new_revision)))
                      review_mode = FALSE;
                    else if (strcmp(current_rev_assy->add_db, "N") == 0)
                      review_mode = TRUE;
                    else
                      review_mode = FALSE;

                    status = PDUget_part_bufrs(
                                       current_rev_assy->new_catalog,
                                       current_rev_assy->new_partid,
                                       current_rev_assy->new_revision,
                                       &current_rev_assy->new_attr_data,
                                       review_mode);
                    _pdm_status("PDUget_part_bufrs", status);
                    if (status != PDM_S_SUCCESS)
                      {
                      PDUdisplay_status(status, fp);
                      if (current_rev_assy->new_attr_data)
                        {
                        free_attr_data_buffer(&current_rev_assy->new_attr_data);
                        current_rev_assy->new_attr_data = NULL;
                        }
                      break;
                      }
                    }
                  }
                else
                  {
                  _pdm_debug("writing to new_revision", 0);
                  PDUfill_in_string(&current_rev_assy->new_revision, text);
                  }

                if ((strcmp(current_rev_assy->add_db, "Y") == 0) &&
                    (strcmp(current_rev_assy->new_parttype, "P") != 0) &&
                    (strcmp(current_rev_assy->new_parttype, "p") != 0))
                  {
                  _pdm_debug("accessing new_attr_data", 0);
                  if (current_rev_assy->new_attr_data)
                    attrs = current_rev_assy->new_attr_data;
                  else
                    {
                    PDUdisplay_status(status, fp);
                    PDUfill_in_string(&current_rev_assy->new_revision, 
                                      NULL_STRING);
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,NULL_STRING,
                                   FALSE);
                    break;
                    }
  
                  if (((attrs) && (!attrs->attr_bufr)) || (!attrs))
                    {
                    PDUdisplay_status(status, fp);
                    PDUfill_in_string(&current_rev_assy->new_revision, 
                                      NULL_STRING);
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,NULL_STRING,
                                   FALSE);
                    break;
                    } 
  
                  status = PDUcheck_rev_datatype(text, attrs->attr_bufr);
                  _pdm_status("PDUcheck_rev_datatype", status);
                  if (status != PDM_S_SUCCESS)
                    {
                    PDUdisplay_status(status, fp);
                    PDUfill_in_string(&current_rev_assy->new_revision, 
                                      NULL_STRING);
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,NULL_STRING,
                                   FALSE);
                    break;
                    } 
                  } 

                if ((strlen(current_rev_assy->new_catalog)) &&
                    (strlen(current_rev_assy->new_partid)) &&
                    (strlen(current_rev_assy->new_revision)) &&
                    (strcmp(current_rev_assy->add, "Y") == 0))
                  {
                  if (strcmp(current_rev_assy->add_db, "N") == 0)
                    {
                    _pdm_debug("query for the parttype", 0);
                    status = PDUget_parttype(current_rev_assy->new_catalog,
                                             current_rev_assy->new_partid,
                                             current_rev_assy->new_revision,
                                             &(current_rev_assy)->new_parttype);
                    _pdm_status("PDUget_parttype", status);

                    if (current_rev_assy->new_level != 0)
                      {
                      _pdm_debug("check for cyclic placement", 0);
                      status = PDUcheck_cyclic_placement_for_rev_assy(act_row);
                  _pdm_status("PDUcheck_cyclic_placement_for_rev_assy", status);
                      if (status != PDM_S_SUCCESS)
                        break;
                      }
                    }
                  else
                    {
                    if ((strcmp(current_rev_assy->ex_catalog, 
                                current_rev_assy->new_catalog) == 0))
                      {
                      _pdm_debug("defaulting new parttype to ex_parttype", 0);
                      PDUfill_in_string(&(current_rev_assy)->new_parttype,
                                        current_rev_assy->ex_parttype);
                      }
                    else
                      {
                      _pdm_debug("get the parttype from the data bufr", 0);
                      if (current_rev_assy->new_attr_data)
                        {
                        attrs = current_rev_assy->new_attr_data;
                        if ((attrs) && (attrs->data_bufr))
                          {
                          MEMbuild_array(attrs->data_bufr);
                          PDUsetup_buffer(attrs->data_bufr, ROW, &data_row);
                          PDUget_buffer_col(attrs->data_bufr, "p_parttype",
                                            &type_col);
                          PDUfill_in_string(&current_rev_assy->new_parttype,
                          data_row[(attrs->data_bufr->columns * 0) + type_col]);
                          }
                        }
                      }
                    }

                  _pdm_debug("parttype = <%s>", current_rev_assy->new_parttype);
                  }

                PDUdisplay_status(PDM_S_SUCCESS, fp);

         current_rev_assy = PDU_assy_ptr;
         if (PDM_debug_on)
          {
            if (PDU_assy_ptr != NULL)
            {
             _pdm_debug("printing global assembly linklist",0);
             PDUprint_assy_linklist(PDU_assy_ptr);
            }
          }

           /* search for other parts with the same catalog name and part
              number; update the revision */
           
           break;

           case DESC_COL:  /* Description column for mcf */
                _pdm_debug("DESC_COL column", 0);
              
                FIfld_get_text_length(fp,REV_MCF,act_row,act_col,&length);
                text = (char *)malloc(sizeof(char) * length + 1);
                memset(text,NULL,sizeof(char) * length + 1);
                FIfld_get_text(fp,REV_MCF,act_row,act_col,length,
                    (unsigned char *)text, &select, &pos);
                _pdm_debug("description entered %s \n",text);

                msg = (char *)PDUtranslate_message(PDM_I_DELETED);
                if ((strcmp(current_rev_assy->delete, "Y") == 0) &&
                    (text) && (strcmp(text, msg) == 0))
                  {
                  _pdm_debug("part is marked for deleted", 0);
                  FIfld_set_text(fp, REV_MCF, act_row, DESC_COL, msg, FALSE);
                  PDUdisplay_status(PDM_E_MARKED_FOR_DELETE, fp);
                  break;
                  }

                if (strcmp(current_rev_assy->add_db, "N") == 0)
                  {
                  if ((text) && (strcmp(text, current_rev_assy->new_desc) == 0))
                    break;

                  if ((strlen(current_rev_assy->new_catalog)) &&
                      (strlen(current_rev_assy->new_partid)) &&
                      (strlen(current_rev_assy->new_revision)))
                    {
                    _pdm_debug("verifying desc", 0);
                    status = PDUget_desc(current_rev_assy->new_catalog,
                                         current_rev_assy->new_partid,
                                         current_rev_assy->new_revision, &desc);
                    _pdm_debug("desc = <%s>", desc);
                    if (strcmp(desc, text) == 0)
                      {
                      PDUdisplay_status(PDM_S_SUCCESS, fp);
                      PDUfill_in_string(&(current_rev_assy)->new_desc, text);
                      break;
                      }
                    }

                  _pdm_debug("desc cannot be changed; resetting desc", 0);
                  PDUdisplay_status(PDM_E_CHANGE_EXIST_DESC, fp);
                  FIfld_set_text(fp,REV_MCF,act_row,act_col,
                                 current_rev_assy->new_desc,FALSE);
                  break;
                  }

                if ((!current_rev_assy->new_catalog) || 
                    ((current_rev_assy->new_catalog) && 
                    (!(strlen(current_rev_assy->new_catalog)))))
                  {
                  _pdm_debug("catalog has not been entered", 0);
                  PDUdisplay_status(PDM_I_ENTER_CATALOG, fp);
                  break;
                  }

                if ((strcmp(current_rev_assy->new_parttype, "P") != 0) &&
                    (strcmp(current_rev_assy->new_parttype, "p") != 0))
                  {
                  _pdm_debug("accessing new_attr_data", 0);
                  if (current_rev_assy->new_attr_data)
                    attrs = current_rev_assy->new_attr_data;
                  else
                    {
                    _pdm_debug("getting attributes", 0);
                    _pdm_debug("cat = <%s>", current_rev_assy->new_catalog);
                    _pdm_debug("part = <%s>", current_rev_assy->new_partid);
                    _pdm_debug("rev = <%s>",current_rev_assy->new_revision);

                    if ((!strlen(current_rev_assy->new_partid)) ||
                             (!strlen(current_rev_assy->new_revision)))
                      review_mode = FALSE;
                    else if (strcmp(current_rev_assy->add_db, "N") == 0)
                      review_mode = TRUE;
                    else
                      review_mode = FALSE;
                    status = PDUget_part_bufrs(
                                       current_rev_assy->new_catalog,
                                       current_rev_assy->new_partid,
                                       current_rev_assy->new_revision,
                                       &current_rev_assy->new_attr_data,
                                       review_mode);
                    _pdm_status("PDUget_part_bufrs", status);
                    if (status != PDM_S_SUCCESS)
                      {
                      PDUdisplay_status(status, fp);
                      if (current_rev_assy->new_attr_data)
                        {
                        free_attr_data_buffer(&current_rev_assy->new_attr_data);
                        current_rev_assy->new_attr_data = NULL;
                        }
                      break;
                      }
                    attrs = current_rev_assy->new_attr_data;
                    } 
  
                  if (((attrs) && (!attrs->attr_bufr)) || (!attrs))
                    {
                    PDUdisplay_status(PDM_E_NULL_BUFFER, fp);
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,NULL_STRING,FALSE);
                    break;
                    } 
  
                  _pdm_debug("checking write permission", 0);
                  status = PDUcheck_attr_for_write_permission(
                                          attrs->attr_bufr, "n_itemdesc");
                  _pdm_status("PDUcheck_attr_for_write_permission", status);
                  if (status != PDM_S_SUCCESS)
                    {
                    PDUdisplay_status(status, fp);
                    FIfld_set_text(fp, REV_MCF, act_row, DESC_COL, 
                                   current_rev_assy->new_desc, FALSE);
                    break;
                    }
                  }
  
                if (!text)
                  PDUfill_in_string(&text, NULL_STRING);
                if (!strlen(text))
                  {
                  PDUfill_in_string(&current_rev_assy->new_desc,text);
                  _pdm_debug("current_rev_assy->new_desc = <%s>", text);
                  break;
                  }

                if ((strcmp(current_rev_assy->new_parttype, "P") != 0) &&
                    (strcmp(current_rev_assy->new_parttype, "p") != 0))
                  {
                  _pdm_debug("validating description", 0);
                  status = PDUcheck_desc_datatype(text, attrs->attr_bufr);
                  _pdm_status("PDUcheck_desc_datatype", status);
                  if (status != PDM_S_SUCCESS)
                    {
                    PDUdisplay_status(status, fp);
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,NULL_STRING,FALSE);
                    break;
                    } 
                  }

                PDUfill_in_string(&current_rev_assy->new_desc,text);
                _pdm_debug("current_rev_assy->new_desc = <%s>", text);

                PDUdisplay_status(PDM_S_SUCCESS, fp);

           break;

           case LOCFILE_COL:   /* Local file name */
                _pdm_debug("LOCFILE_COL column", 0);

                 /* Get text from mcf local file name column */
              
                FIfld_get_text_length(fp,REV_MCF,act_row,act_col,&length);
                text = (char *)malloc(sizeof(char) * length + 1);
                memset(text, NULL,sizeof(char) * length + 1);
                FIfld_get_text(fp,REV_MCF,act_row,act_col,length,
                    (unsigned char *)text, &select, &pos);
                _pdm_debug("entered local file name %s",text);
                
                if ((strcmp(current_rev_assy->delete, "Y") == 0) &&
                    (text) && (strlen(text)))
                  {
                  _pdm_debug("part is marked for delete", 0);
                  FIfld_set_text(fp, REV_MCF, act_row, LOCFILE_COL, 
                                 NULL_STRING, FALSE);
                  PDUdisplay_status(PDM_E_MARKED_FOR_DELETE, fp);
                  break;
                  }

                if (!text)
                  {
                  PDUfill_in_string(&(current_rev_assy)->new_cofilename, 
                                    NULL_STRING);
                  break;
                  }
                if (!strlen(text))
                  {
                  PDUfill_in_string(&(current_rev_assy)->new_cofilename, 
                                    NULL_STRING);
                  break;
                  }

                if (((strcmp(current_rev_assy->ex_catalog, 
                             current_rev_assy->new_catalog) == 0) &&
                     (strcmp(current_rev_assy->ex_partid,
                             current_rev_assy->new_partid) == 0) &&
                     (strcmp(current_rev_assy->ex_revision,
                             current_rev_assy->new_revision) == 0)) &&
                    ((strcmp(current_rev_assy->ex_cofilename, text) == 0)))
                  {
                  _pdm_debug("new filename is same as existing filename", 0);
                  PDUfill_in_string(&(current_rev_assy)->new_cofilename, text);
                  break;
                  }

                if (strcmp(current_rev_assy->new_cofilename, text) == 0)
                  {
                  _pdm_debug("filename was not changed", 0);
                  break;
                  }

                if (((strcmp(current_rev_assy->ex_catalog, 
                             current_rev_assy->new_catalog) != 0) ||
                     (strcmp(current_rev_assy->ex_partid,
                             current_rev_assy->new_partid) != 0) ||
                     (strcmp(current_rev_assy->ex_revision,
                             current_rev_assy->new_revision) != 0)) &&
                    ((strcmp(current_rev_assy->ex_cofilename, text) == 0)))
                  {
                  PDUdisplay_status(PDM_E_NEW_FILE_FOR_CHGD_PARTS, fp);
                  FIfld_set_text(fp, REV_MCF, act_row, LOCFILE_COL, "", FALSE);
                  break;
                  }

                if ((!current_rev_assy->new_catalog) || 
                    ((current_rev_assy->new_catalog) && 
                    (!(strlen(current_rev_assy->new_catalog)))))
                  {
                  if (current_rev_assy->new_level != -1)
                    {
                    _pdm_debug("catalog has not been entered", 0);
                    PDUdisplay_status(PDM_I_ENTER_CATALOG, fp);
                    break;
                    }
                  }

                if ((strcmp(current_rev_assy->add_db, "N") == 0) &&
                    (current_rev_assy->new_level == -1))
                  {
                  _pdm_debug("multiple file; get part info", 0);
                  for (i = act_row - 1; i >= 0; --i)
                     {
                     FIfld_get_text_length(fp,REV_MCF,i,NEWLEV_COL,&length);
                     string = (char *)malloc(sizeof(char) * length + 1);
                     memset(string, NULL,sizeof(char) * length + 1);
                     FIfld_get_text(fp,REV_MCF,i,NEWLEV_COL,length,
                         (unsigned char *)string, &select, &pos);
                     _pdm_debug("level is %s",string);
                     if (atoi(string) != -1)
                       {
                       _pdm_debug("part info found", 0);
                       FIfld_get_text_length(fp,REV_MCF,i,CAT_COL,&length);
                       string = (char *)malloc(sizeof(char) * length + 1);
                       memset(string, NULL,sizeof(char) * length + 1);
                       FIfld_get_text(fp,REV_MCF,i,CAT_COL,length,
                           (unsigned char *)string, &select, &pos);
                    PDUfill_in_string(&(current_rev_assy)->new_catalog, string);

                       FIfld_get_text_length(fp,REV_MCF,i,PART_COL,&length);
                       string = (char *)malloc(sizeof(char) * length + 1);
                       memset(string, NULL,sizeof(char) * length + 1);
                       FIfld_get_text(fp,REV_MCF,i,PART_COL,length,
                           (unsigned char *)string, &select, &pos);
                    PDUfill_in_string(&(current_rev_assy)->new_partid, string);

                       FIfld_get_text_length(fp,REV_MCF,i,REV_COL,&length);
                       string = (char *)malloc(sizeof(char) * length + 1);
                       memset(string, NULL,sizeof(char) * length + 1);
                       FIfld_get_text(fp,REV_MCF,i,REV_COL,length,
                           (unsigned char *)string, &select, &pos);
                   PDUfill_in_string(&(current_rev_assy)->new_revision, string);
                       break;
                       }
                     }
                  }

                if ((strcmp(current_rev_assy->add_db, "N") == 0) &&
                    (strlen(current_rev_assy->new_catalog)) &&
                    (strlen(current_rev_assy->new_partid)) &&
                    (strlen(current_rev_assy->new_revision)))
                  {
                  _pdm_debug("verify file <%s>", text);
                  status = PDUvalid_filename(current_rev_assy->new_catalog,
                                             current_rev_assy->new_partid,
                                             current_rev_assy->new_revision,
                                             text);
                  _pdm_status("PDUvalid_filename", status);
                  PDUdisplay_status(status, fp);
                  if (status != PDM_S_SUCCESS)
                    {
                    FIfld_set_text(fp, REV_MCF, act_row, LOCFILE_COL, 
                                   NULL_STRING, FALSE);
                    PDUfill_in_string(&(current_rev_assy)->new_cofilename, 
                                      NULL_STRING);
                    }
                  else
                    {
                    PDUfill_in_string(&(current_rev_assy)->new_cofilename, 
                                      text);
                    _pdm_debug("cofilename = <%s>", text);
                    }
                  break;
                  }

                /* save the current row */
                if (current_rev_assy->new_level == -1)
                  {
                  _pdm_debug("search backwards for first file", 0);
                  for (row = act_row - 1; row > 0; --row)
                     {
                     FIfld_get_text_length(fp,REV_MCF,row,NEWLEV_COL,&length);
                     string = (char *)malloc(sizeof(char) * length + 1);
                     memset(string, NULL,sizeof(char) * length + 1);
                     FIfld_get_text(fp,REV_MCF,row,NEWLEV_COL,length,
                         (unsigned char *)string, &select, &pos);
                     _pdm_debug("level is <%s>",string);
                     level = atoi(string);
                     if (level != -1)
                       {
                       _pdm_debug("first file found", 0);
                       _pdm_debug("mcf_row %d", (char *)row);
                       break;
                       }
                     }
                  _pdm_debug("find matching row in link list", 0);

                  current_rev_assy = PDU_assy_ptr;
                  while (current_rev_assy)
                    {
                    if (current_rev_assy->mcf_row == row)
                      break;
                    current_rev_assy = current_rev_assy->next;
                    }
                  }

                if (!(current_rev_assy->new_attr_data))
                  {
                  _pdm_debug("getting attributes", 0);
                  _pdm_debug("cat = <%s>", current_rev_assy->new_catalog);
                  _pdm_debug("part = <%s>", current_rev_assy->new_partid);
                  _pdm_debug("rev = <%s>",current_rev_assy->new_revision);

                  if ((!strlen(current_rev_assy->new_partid)) ||
                           (!strlen(current_rev_assy->new_revision)))
                    review_mode = FALSE;
                  else if (strcmp(current_rev_assy->add_db, "N") == 0)
                    review_mode = TRUE;
                  else
                    review_mode = FALSE;

                  status = PDUget_part_bufrs(
                                     current_rev_assy->new_catalog,
                                     current_rev_assy->new_partid,
                                     current_rev_assy->new_revision,
                                     &current_rev_assy->new_attr_data,
                                     review_mode);
                  _pdm_status("PDUget_part_bufrs", status);
                  if (status != PDM_S_SUCCESS)
                    {
                    PDUdisplay_status(status, fp);
                    if (current_rev_assy->new_attr_data)
                      {
                      free_attr_data_buffer(&current_rev_assy->new_attr_data);
                      current_rev_assy->new_attr_data = NULL;
                      }
                    break;
                    }
                  }

                if (current_rev_assy->new_attr_data)
                  {
                  attrs = current_rev_assy->new_attr_data;
                  if (attrs->data_bufr)
                    {
                    _pdm_debug("checking parttype", 0);
                    status = MEMbuild_array(attrs->data_bufr);
                    _pdm_status("MEMbuild_array", status);
                    status = PDUsetup_buffer(attrs->data_bufr, ROW, &data_row);
                    _pdm_status("PDUsetup_buffer", status);
                    status = PDUget_buffer_col(attrs->data_bufr, 
                                               "p_parttype", &type_col);
                    _pdm_status("PDUget_buffer_col", status);
                    PDUfill_in_string(&parttype, 
                       data_row[(attrs->data_bufr->columns * 0) + type_col]);

                    _pdm_debug("parttype = <%s>", parttype);
                    if ((parttype) && 
                       ((strcmp(parttype, "N") == 0) || 
                        (strcmp(parttype, "n") == 0)))
                      {
                      PDUdisplay_status(PDM_E_ADD_FILES_NG_PART, fp);
                      FIfld_set_text(forms.rev_assy_form_id, REV_MCF,
                                     act_row,LOCFILE_COL,"",FALSE);
                      _pdm_debug("find active row in link list", 0);
                      while (current_rev_assy)
                        {
                        if (current_rev_assy->mcf_row == act_row)
                          {
                          PDUfill_in_string(&current_rev_assy->new_cofilename, 
                                            NULL_STRING);
                          break;
                          }
                        current_rev_assy = current_rev_assy->next;
                        }
                      break;
                      }
                    }
                  if ((attrs) && (attrs->attr_bufr))
                    {
                    _pdm_debug("checking write permission", 0);
                    status = PDUcheck_attr_for_write_permission(
                                            attrs->attr_bufr, "n_cofilename");
                    _pdm_status("PDUcheck_attr_for_write_permission", status);
                    if (status != PDM_S_SUCCESS)
                      {
                      PDUdisplay_status(status, fp);
                      FIfld_set_text(fp, REV_MCF, act_row, LOCFILE_COL, 
                                     NULL_STRING, FALSE);
                      break;
                      }
                    }
                  }

                /* Verify file name */
                status = PDUverify_addpart_filename(text);
                _pdm_status("PDUverify_addpart_filename", status);
                if (status != PDM_S_SUCCESS)
                 {
                  FIfld_set_text(fp,REV_MCF,act_row,act_col,NULL_STRING,FALSE);
                  while (current_rev_assy)
                    {
                    if (current_rev_assy->mcf_row == act_row)
                      {
                      PDUfill_in_string(&current_rev_assy->new_cofilename, 
                                        NULL_STRING);
                      break;
                      }
                    current_rev_assy = current_rev_assy->next;
                    }
                  PDUdisplay_status(status, fp);
                  break;
                 } 

                while (current_rev_assy)
                 {
                 if (current_rev_assy->mcf_row == act_row)
                   {
                   PDUfill_in_string(&current_rev_assy->new_cofilename,text);
                   _pdm_debug("current_rev_assy->new_cofilename = <%s>", text);
                   break;
                   }
                 current_rev_assy = current_rev_assy->next;
                 }

                PDUdisplay_status(PDM_S_SUCCESS, fp);

           break;

           case STGFILE_COL: /* Storage file name */

                _pdm_debug("STGFILE_COL column", 0);
                 /* Get text from mcf local file name column */
              
                FIfld_get_text_length(fp,REV_MCF,act_row,act_col,&length);
                text = (char *)malloc(sizeof(char) * length + 1);
                memset(text,NULL,sizeof(char) * length + 1);
                FIfld_get_text(fp,REV_MCF,act_row,act_col,length,
                   (unsigned char *)text, &select, &pos);
                _pdm_debug("entered storage file name %s",text);

                if ((strcmp(current_rev_assy->delete, "Y") == 0) &&
                    (text) && (strlen(text)))
                  {
                  _pdm_debug("part is marked for deleted", 0);
                  FIfld_set_text(fp, REV_MCF, act_row, STGFILE_COL, 
                                 NULL_STRING, FALSE);
                  PDUdisplay_status(PDM_E_MARKED_FOR_DELETE, fp);
                  break;
                  }

                if (!text)
                  {
                  PDUfill_in_string(&(current_rev_assy)->new_cifilename, 
                                    NULL_STRING);
                  break;
                  }
                if (!strlen(text))
                  {
                  PDUfill_in_string(&(current_rev_assy)->new_cifilename, 
                                    NULL_STRING);
                  break;
                  }

                if (strcmp(current_rev_assy->new_cifilename, text) == 0)
                  {
                  _pdm_debug("filename was not changed", 0);
                  break;
                  }
 
                if ((!current_rev_assy->new_catalog) || 
                    ((current_rev_assy->new_catalog) && 
                    (!(strlen(current_rev_assy->new_catalog)))))
                  {
                  if (current_rev_assy->new_level != -1)
                    {
                    _pdm_debug("catalog has not been entered", 0);
                    PDUdisplay_status(PDM_I_ENTER_CATALOG, fp);
                    break;
                    }
                  }

                if ((!strlen(current_rev_assy->new_catalog)) ||
                    (!strlen(current_rev_assy->new_partid)) ||
                    (!strlen(current_rev_assy->new_revision)))
                  {
                  if (current_rev_assy->new_level != -1)
                    {
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,
                                   NULL_STRING,FALSE);
                    PDUfill_in_string(&current_rev_assy->new_cifilename,
                                      NULL_STRING);
                    PDUdisplay_status(PDM_E_ENTER_NEW_PART_DATA, fp);
                    break;
                    }
                  }

                /* save the current row */
                if (current_rev_assy->new_level == -1)
                  {
                  _pdm_debug("search backwards for first file", 0);
                  for (row = act_row - 1; row > 0; --row)
                     {
                     FIfld_get_text_length(fp,REV_MCF,row,NEWLEV_COL,&length);
                     string = (char *)malloc(sizeof(char) * length + 1);
                     memset(string, NULL,sizeof(char) * length + 1);
                     FIfld_get_text(fp,REV_MCF,row,NEWLEV_COL,length,
                         (unsigned char *)string, &select, &pos);
                     _pdm_debug("level is <%s>",string);
                     level = atoi(string);
                     if (level != -1)
                       {
                       _pdm_debug("first file found", 0);
                       _pdm_debug("mcf_row %d", (char *)row);
                       break;
                       }
                     }
                  _pdm_debug("find matching row in link list", 0);

                  current_rev_assy = PDU_assy_ptr;
                  while (current_rev_assy)
                    {
                    if (current_rev_assy->mcf_row == row)
                      break;
                    current_rev_assy = current_rev_assy->next;
                    }
                  }

                if (!(current_rev_assy->new_attr_data) &&
                     (strcmp(current_rev_assy->add_db, "Y") == 0))
                  {
                  _pdm_debug("getting attributes", 0);
                  _pdm_debug("cat = <%s>", current_rev_assy->new_catalog);
                  _pdm_debug("part = <%s>", current_rev_assy->new_partid);
                  _pdm_debug("rev = <%s>",current_rev_assy->new_revision);

                  if ((!strlen(current_rev_assy->new_partid)) ||
                           (!strlen(current_rev_assy->new_revision)))
                    review_mode = FALSE;
                  else if (strcmp(current_rev_assy->add_db, "N") == 0)
                    review_mode = TRUE;
                  else
                    review_mode = FALSE;

                  status = PDUget_part_bufrs(
                                     current_rev_assy->new_catalog,
                                     current_rev_assy->new_partid,
                                     current_rev_assy->new_revision,
                                     &current_rev_assy->new_attr_data,
                                     review_mode);
                  _pdm_status("PDUget_part_bufrs", status);
                  if (status != PDM_S_SUCCESS)
                    {
                    PDUdisplay_status(status, fp);
                    if (current_rev_assy->new_attr_data)
                      {
                      free_attr_data_buffer(&current_rev_assy->new_attr_data);
                      current_rev_assy->new_attr_data = NULL;
                      }
                    break;
                    }
                  }

                if (current_rev_assy->new_attr_data)
                  {
                  attrs = current_rev_assy->new_attr_data;
                  if (attrs->data_bufr)
                    {
                    status = MEMbuild_array(attrs->data_bufr);
                    _pdm_status("MEMbuild_array", status);
                    status = PDUsetup_buffer(attrs->data_bufr, ROW, &data_row);
                    _pdm_status("PDUsetup_buffer", status);
                    status = PDUget_buffer_col(attrs->data_bufr, 
                                               "p_parttype", &type_col);
                    _pdm_status("PDUget_buffer_col", status);
                    PDUfill_in_string(&parttype, 
                       data_row[(attrs->data_bufr->columns * 0) + type_col]);

                    _pdm_debug("parttype = <%s>", parttype);
                    if ((parttype) && 
                       ((strcmp(parttype, "N") == 0) || 
                        (strcmp(parttype, "n") == 0)))
                      {
                      PDUdisplay_status(PDM_E_ADD_FILES_NG_PART, fp);
                      FIfld_set_text(forms.rev_assy_form_id, REV_MCF,
                                     act_row,STGFILE_COL,"",FALSE);
                      _pdm_debug("find active row in link list", 0);
                      while (current_rev_assy)
                        {
                        if (current_rev_assy->mcf_row == act_row)
                          {
                          PDUfill_in_string(&current_rev_assy->new_cifilename,
                                            NULL_STRING);
                          break;
                          }
                        current_rev_assy = current_rev_assy->next;
                        }
                      break;
                      }
                    }
                  if ((attrs) && (attrs->attr_bufr))
                    {
                    if (strcmp(current_rev_assy->add_db, "Y") == 0)
                      {
                      _pdm_debug("checking write permission", 0);
                      status = PDUcheck_attr_for_write_permission(
                                              attrs->attr_bufr, "n_cifilename");
                      _pdm_status("PDUcheck_attr_for_write_permission", status);
                      if (status != PDM_S_SUCCESS)
                        {
                        PDUdisplay_status(status, fp);
                        FIfld_set_text(fp, REV_MCF, act_row, STGFILE_COL, 
                                       NULL_STRING, FALSE);
                        break;
                        }
                      }
                    }
                  }

                if (strcmp(current_rev_assy->add_db, "Y") == 0)
                  {
                  /* Verify file name for length and spec_char */
              
                  length = strlen(text);
                  if (length > 14)
                   {
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,"",FALSE);
                    _pdm_debug("find active row in link list", 0);
                    while (current_rev_assy)
                      {
                      if (current_rev_assy->mcf_row == act_row)
                        {
                        PDUfill_in_string(&current_rev_assy->new_cifilename,
                                          NULL_STRING);
                        break;
                        }
                      current_rev_assy = current_rev_assy->next;
                      }
                    PDUdisplay_status(PDM_E_STG_FN_TOO_LONG, fp);
                    break; 
                   }
  
                  status = PDUcheck_char(text,&spec_char);
                  _pdm_status("PDUcheck_char",status);
                  if (status != PDM_S_SUCCESS)
                    {
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,"",FALSE);
                    _pdm_debug("find active row in link list", 0);
                    while (current_rev_assy)
                      {
                      if (current_rev_assy->mcf_row == act_row)
                        {
                        PDUfill_in_string(&current_rev_assy->new_cifilename,
                                          NULL_STRING);
                        break;
                        }
                      current_rev_assy = current_rev_assy->next;
                      }
                    PDUdisplay_status(PDM_E_INVALID_CHAR_IN_STGFN, fp);
                    break;
                    }
  
                  /*  Verify if storage name is unique */
                  status = PDMrcheck_dup_sa_fname(
                                      current_rev_assy->new_catalog,
                                       current_rev_assy->new_partid,
                                       current_rev_assy->new_revision,
                                       text, storage->storage_name);
                  _pdm_status("PDMrcheck_dup_sa_fname",status);
                  if (status != PDM_S_SUCCESS)
                    {
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,NULL_STRING,
                                   FALSE);
                    _pdm_debug("find active row in link list", 0);
                    while (current_rev_assy)
                      {
                      if (current_rev_assy->mcf_row == act_row)
                        {
                        PDUfill_in_string(&current_rev_assy->new_cifilename,
                                          NULL_STRING);
                        break;
                        }
                      current_rev_assy = current_rev_assy->next;
                      }
                    PDUdisplay_status(PDM_E_STG_FN_NOT_UNIQUE, fp);
                    break;
                    }
                  }
                else
                  {
                  _pdm_debug("verifying stg filename for existence", 0);
                  status = PDUverify_storage_filename(
                                       current_rev_assy->new_catalog,
                                       current_rev_assy->new_partid,
                                       current_rev_assy->new_revision, text);
                  _pdm_status("PDUverify_storage_filename", status);
                  if (status != PDM_S_SUCCESS)
                    {
                    FIfld_set_text(fp,REV_MCF,act_row,act_col,
                                   NULL_STRING,FALSE);
                    _pdm_debug("find active row in link list", 0);
                    while (current_rev_assy)
                      {
                      if (current_rev_assy->mcf_row == act_row)
                        {
                        PDUfill_in_string(&current_rev_assy->new_cifilename,
                                          NULL_STRING);
                        break;
                        }
                      current_rev_assy = current_rev_assy->next;
                      }
                    PDUdisplay_status(status, fp);
                    break;
                    }
                  }
                  
                _pdm_debug("find active row in link list", 0);
                while (current_rev_assy)
                  {
                  if (current_rev_assy->mcf_row == act_row)
                    {
                    PDUfill_in_string(&current_rev_assy->new_cifilename,text);
                    _pdm_debug("current_rev_assy->new_cifilename = <%s>", text);
                    break;
                    }
                  current_rev_assy = current_rev_assy->next;
                  }

                PDUdisplay_status(PDM_S_SUCCESS, fp);

           break;

           case DISPNEW_COL:  /* Display attributes for new assembly */

                _pdm_debug("DISPNEW_COL column", 0);

                review_mode = FALSE;

                if (!forms.attr_value_form_id)
                  {
                  _pdm_debug("creating ATTR_VALUE_FORM", 0);
                  status = FIf_new(ATTR_VALUE_FORM,"Attrib_Value",
                          attr_value_notification_routine, 
                          &forms.attr_value_form_id);
                  if (status != FI_SUCCESS)
                    {
                    _pdm_debug("error creating form", 0);
                    break;
                    }
                  GRcreate_pull_down_list(ATTR_VALUE_FORM, 
                    forms.attr_value_form_id, VALUE_LIST,MAX_ROWS,
                    VIS_ROWS,PDU_value_list, list_size, 1, &PDU_value_pulldown);
                  }

                if (!(strlen(current_rev_assy->new_catalog)))
                  {
                  if ((strlen(current_rev_assy->ex_catalog)) &&
                      (current_rev_assy->ex_level == -1) &&
                      (strcmp(current_rev_assy->add, "N") == 0))
                    {
                    _pdm_debug("calling noti routine with DISPEXT_COL", 0);
                    FIfld_set_active_row(fp, REV_MCF, act_row, 0);
                    FImcf_set_active_col(fp, REV_MCF, DISPEXT_COL, 0);
                    FIg_call_notification_routine(fp, REV_MCF);
                    break;
                    }
                  else if ((current_rev_assy->ex_level == -1) &&
                           (strcmp(current_rev_assy->add, "Y") == 0))
                    {
                    _pdm_debug("searching backwards for row with cat name", 0);
                    for (row = act_row - 1; row >= 0; --row)
                       {
                       FIfld_get_text_length(fp,REV_MCF,row,0,&length);
                       text = (char *)malloc(sizeof(char) * length + 1);
                       memset(text,NULL,sizeof(char) * length + 1);
                       FIfld_get_text(fp,REV_MCF,row,0,length,
                          (unsigned char *)text, &select, &pos);
                       if ((text) && (strlen(text)))
                         {
                         PDUfill_in_string(&(current_rev_assy)->new_catalog,
                                           text);
                         _pdm_debug("catalog = <%s>", text);
                         break;
                         }
                       }
                    }
                  _pdm_debug("catalog field is empty", 0);
                  PDUdisplay_status(PDM_I_ENTER_CATALOG, fp);
                  break;
                  }

                if ((strlen(current_rev_assy->new_catalog)) &&
                    (strlen(current_rev_assy->new_partid)) &&
                    (strlen(current_rev_assy->new_revision)))
                  {
                  status = PDMcheck_partnum(current_rev_assy->new_catalog,
                                            current_rev_assy->new_partid,
                                            current_rev_assy->new_revision);
                  _pdm_status("PDMcheck_partnum status",status);
                  if (status == PDM_S_SUCCESS)
                    {
                     _pdm_debug("setting fields to read-only", 0);
                     /* set mode of mcf to review mode */
                     FIfld_set_mode(forms.attr_value_form_id,ATTR_MCF,0,
                                    FI_REVIEW); 
                     FIfld_set_mode(forms.attr_value_form_id,ATTR_MCF,1,
                                    FI_REVIEW); 
                     review_mode = TRUE;
                    }
                  else if (status == PDM_E_PARTREV_NOT_FOUND)
                    {
                     _pdm_debug("setting fields to insert", 0);
                     review_mode = FALSE;
                     /* set mode of mcf to review mode */
                     FIfld_set_mode(forms.attr_value_form_id,ATTR_MCF,0,
				    FI_SINGLE_SELECT);
                     FIfld_set_mode(forms.attr_value_form_id,ATTR_MCF,1,
                                    FI_INSERT);
                    }
                  else
                    {
                    PDUdisplay_status(status, fp);
                    break;
                    }
                  }

                _pdm_debug("checking to see if buffers exist", 0);
                if (current_rev_assy->new_attr_data == NULL)
                  {
                  /* Get attributes for the catalog,part,and rev */
                  _pdm_debug("catalog = <%s>", current_rev_assy->new_catalog);
                  _pdm_debug("partid = <%s>", current_rev_assy->new_partid);
                  _pdm_debug("revision = <%s>", current_rev_assy->new_revision);

                  if ((!strlen(current_rev_assy->new_partid)) ||
                      (!strlen(current_rev_assy->new_revision)))
                    review_mode = FALSE;
                  else if (strcmp(current_rev_assy->add_db, "N") == 0)
                    {
                    _pdm_debug("setting review mode to TRUE", 0);
                    review_mode = TRUE;
                    }
                  else
                    {
                    _pdm_debug("setting review mode to FALSE", 0);
                    review_mode = FALSE;
                    }

                  status = PDUget_part_bufrs(current_rev_assy->new_catalog,
                                             current_rev_assy->new_partid,
                                             current_rev_assy->new_revision,
                                             &current_rev_assy->new_attr_data,
                                             review_mode);
                  _pdm_status("PDUget_part_bufrs", status);
                  if (status != PDM_S_SUCCESS)
                    {
                    PDUdisplay_status(status, fp);
                    if (current_rev_assy->new_attr_data)
                      {
                      free_attr_data_buffer(&current_rev_assy->new_attr_data);
                      current_rev_assy->new_attr_data = NULL;
                      break;
                      }
                    }
                  }

                 /* Fill mcf with attribute data */
                 _pdm_debug("loading attr form", 0);
                 PDU_form_id = forms.attr_value_form_id;
                 status = PDU_display_attr_in_mcf(
                                              current_rev_assy->new_attr_data);
                 _pdm_status("PDU_display_attr_in_mcf", status);
                 if (status != PDM_S_SUCCESS)
                   if (current_rev_assy->new_attr_data)
                     {
                     free_attr_data_buffer(&current_rev_assy->new_attr_data);
                     current_rev_assy->new_attr_data = NULL;
                     PDUdisplay_status(status, fp);
                     break;
                     }

                 FIg_set_text(forms.attr_value_form_id,CAT_FLD,
                              current_rev_assy->new_catalog);
                 FIg_set_text(forms.attr_value_form_id,PART_FLD,
                              current_rev_assy->new_partid);
                 FIg_set_text(forms.attr_value_form_id,REV_FLD,
                              current_rev_assy->new_revision);
                 FIf_erase(forms.rev_assy_form_id);
                 FIf_display(forms.attr_value_form_id);
                 PDUdisplay_status(PDM_S_SUCCESS, fp);

           break;

         }  /* end switch column */
         break;    /* REV_MCF */ 

    case PLACE_BTN: 
         _pdm_debug("PLACE_BTN", 0);

         FIfld_get_num_rows(fp, REV_MCF, &num_rows);
         for (row = 0; row < num_rows; ++row)
            {
            FImcf_get_select(fp, REV_MCF, row, &select);
            if (select)
              {
              FIfld_set_active_row(fp, REV_MCF, row, 0);
              break;
              }
            }

         if (!select)
           {
           PDUdisplay_status(PDM_E_NO_PARTS_SELECTED, fp);
           break;
           }

         act_row = row;

         /* find place in PDUrev_assy structure and set current_rev_assy */
         current_rev_assy = PDU_assy_ptr;
         _pdm_debug("finding active row in link list", 0);
         while (current_rev_assy)
          {
            if (current_rev_assy->mcf_row == act_row)
              {
              found = 1;
              break;
              }
            else if (current_rev_assy)
              current_rev_assy = current_rev_assy->next;
          }
         if (!found)
           {
           _pdm_debug("selected row is not in the link list", 0);
           PDUdisplay_status(PDM_E_PLACE_ROW, fp);
           FIfld_erase_cursor(fp, REV_MCF);
           FIfld_set_text(fp, REV_MCF, act_row, act_col, NULL_STRING, FALSE);
           break;
           }
         else
           _pdm_debug("current ptr mcf row %d\n",current_rev_assy->mcf_row);

         if (strcmp(current_rev_assy->delete, "Y") == 0)
           {
           PDUdisplay_status(PDM_E_MARKED_FOR_DELETE, fp);
           break;
           }

/* parts that have multiple files should have already been checked  &&
   each level 1 part should only appear on the form once  */
         if ((current_rev_assy->ex_level != 0) &&
             (current_rev_assy->ex_level != -1))
           {
           _pdm_debug("has part has been modified at a different level??", 0);
           list = PDU_modified_parts_list;
           status = PDUis_part_in_assy_list(current_rev_assy->ex_level,
                                            current_rev_assy->p_childno,
                                            current_rev_assy->p_pchildno,
                                            current_rev_assy->new_catalog,
                                            current_rev_assy->new_partid,
                                            current_rev_assy->new_revision,
                                            list);
           _pdm_status("PDUis_part_in_assy_list", status);
           if (status == 1)
             {
             _pdm_debug("part modified at different location", 0);
             PDUdisplay_status(PDM_E_MODIFY_DUPLICATE_PART, fp);
             break;
             }
  
           _pdm_debug("add part to list of modified parts", 0);
           status = PDUadd_part_to_assy_list(current_rev_assy->ex_level,
                                             current_rev_assy->p_childno,
                                             current_rev_assy->p_pchildno,
                                             current_rev_assy->new_catalog,
                                             current_rev_assy->new_partid,
                                             current_rev_assy->new_revision,
                                             &list);
           _pdm_status("PDUadd_part_to_assy_list", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUdisplay_status(status, fp);
             break;
             }
           PDU_modified_parts_list = list;
           }
  
         /* move pointer to the next row */
         if (current_rev_assy->next)
           {
           row = current_rev_assy->mcf_row;
           current_rev_assy = current_rev_assy->next;
           }
         else
           {
           row = current_rev_assy->mcf_row;
           /* do nothing */
           }

         FImcf_set_select(fp, REV_MCF, act_row, FALSE);
         FIg_display(fp, REV_MCF);

         if (act_row >= 0)
           {
           _pdm_debug("check rows for multiple files", 0);
           while ((current_rev_assy) && (current_rev_assy->ex_level == -1))
             {
             ++row;
             current_rev_assy = current_rev_assy->next;
             }

           _pdm_debug("adding row beneath row %d", (char *)row);
           new_row = row + 1;
           FIfld_insert_blank_row(fp, REV_MCF, new_row);


           _pdm_debug("get the level number", 0);
           for (row = act_row; row >= 0; --row)
              {
              /* search backwards to get the current level number */
              FIfld_get_text_length(fp,REV_MCF,row,0,&length);
              text = (char *)malloc(sizeof(char) * length + 1);
              memset(text,NULL,sizeof(char) * length + 1);
              FIfld_get_text(fp,REV_MCF,row,0,length,
                 (unsigned char *)text, &select, &pos);
              if (!text)
                continue;
              else if (!strlen(text))
                continue;
              else
                {
                if (row != act_row)
                  {
                  FImcf_set_select(fp, REV_MCF, act_row, FALSE);
                  act_row = row;
                  FIfld_set_active_row(fp, REV_MCF, row, 0);
                  }
                else
                  {
                  FImcf_set_select(fp, REV_MCF, act_row, FALSE);
                  FIfld_set_active_row(fp, REV_MCF, new_row, 0);
                  }

                strcpy(level_str, text);
                _pdm_debug("current level = <%s>", level_str);
                level = atoi(level_str);
		++level;
                _pdm_debug("new level = %d", (char *)level);
                sprintf(level_str, "%d", level);
                FIfld_set_text(fp, REV_MCF, new_row, 0, level_str, TRUE);
                FIfld_set_text(fp, REV_MCF, new_row, NEWLEV_COL, level_str, TRUE);
                break;
                }
              }

           status =PDUadd_blank_row_to_linklist(&current_rev_assy,
                                                new_row, level);
           _pdm_status("PDUadd_blank_row_to_linklist", status);

           _pdm_debug("setting text on new row", 0);
           msg = (char *)PDUtranslate_message(PDM_I_ADDED_ROW);
           FIfld_set_text(fp, REV_MCF, new_row, 1, msg, TRUE);
           FIfld_set_text(fp, REV_MCF, new_row, 2, msg, TRUE);
           FIfld_set_text(fp, REV_MCF, new_row, 3, msg, TRUE);
           FIfld_set_active_row(fp, REV_MCF, new_row, 0);
           }
         else
           {
           _pdm_debug("user has not selected a row", 0);
           PDUdisplay_status(PDM_I_NO_ROWS_SELECTED, fp);
           break;
           }

         PDUdisplay_status(PDM_I_KEY_IN_OR_SEARCH, fp);

         break;

    case DEL_BTN: 

         _pdm_debug("DEL_BTN", 0);

         FIfld_get_num_rows(fp, REV_MCF, &num_rows);
         for (row = 0; row < num_rows; ++row)
            {
            FImcf_get_select(fp, REV_MCF, row, &select);
            if (select)
              {
              FIfld_set_active_row(fp, REV_MCF, row, 0);
              break;
              }
            }

         if (!select)
           {
           PDUdisplay_status(PDM_E_NO_PARTS_SELECTED, fp);
           break;
           }

         act_row = row;

         if (act_row == 0)
           {
           PDUdisplay_status(PDM_E_CANNOT_DELETE_PARENT, fp);
           break;
           }

         FIfld_get_text_length(fp,REV_MCF,act_row,EXLEV_COL,&length);
         text = (char *)malloc(sizeof(char) * length + 1);
         memset(text,NULL,sizeof(char) * length + 1);
         FIfld_get_text(fp,REV_MCF,act_row,EXLEV_COL,length,
             (unsigned char *)text, &select, &pos);
         _pdm_debug("level = %s",text);

         level = atoi(text);

         PDUfind_parent_in_mcf(act_row, level, &parent_cat, &parent_part,
                  &parent_rev, &row, &parent_level, &childno, &pchildno);

/* parts that have multiple files should have already been checked  &&
   each level 1 part should only appear on the form once  */
         if ((level != -1) && (parent_level != 0))
           {
           _pdm_debug("has part has been modified at a different level??", 0);
           list = PDU_modified_parts_list;
           status = PDUis_part_in_assy_list(parent_level,
                                            childno,
                                            pchildno,
                                            parent_cat,
                                            parent_part,
                                            parent_rev,
                                            list);
           _pdm_status("PDUis_part_in_assy_list", status);
           if (status == 1)
             {
             _pdm_debug("part modified at different location", 0);
             PDUdisplay_status(PDM_E_MODIFY_DUPLICATE_PART, fp);
             break;
             }
  
           _pdm_debug("add part to list of modified parts", 0);
           status = PDUadd_part_to_assy_list(parent_level,
                                             childno,
                                             pchildno,
                                             parent_cat,
                                             parent_part,
                                             parent_rev,
                                             &list);
           _pdm_status("PDUadd_part_to_assy_list", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUdisplay_status(status, fp);
             break;
             }
           PDU_modified_parts_list = list;
           }

         msg = (char *)PDUtranslate_message(PDM_I_DELETED);
         FIfld_set_text(fp, REV_MCF, act_row, CAT_COL,  msg, TRUE);
         FIfld_set_text(fp, REV_MCF, act_row, PART_COL, msg, TRUE);
         FIfld_set_text(fp, REV_MCF, act_row, REV_COL,  msg, TRUE);
         FIfld_set_text(fp, REV_MCF, act_row, DESC_COL, msg, TRUE);
         FIfld_set_text(fp, REV_MCF, act_row, LOCFILE_COL, NULL_STRING, TRUE);
         FIfld_set_text(fp, REV_MCF, act_row, STGFILE_COL, NULL_STRING, TRUE);

         _pdm_debug("marking children for delete on form", 0);
         for (row = act_row + 1; row < num_rows; ++row)
            {
            FIfld_get_text_length(fp,REV_MCF,row,EXLEV_COL,&length);
            text = (char *)malloc(sizeof(char) * length + 1);
            memset(text,NULL,sizeof(char) * length + 1);
            FIfld_get_text(fp,REV_MCF,row,EXLEV_COL,length,
                (unsigned char *)text, &select, &pos);
            _pdm_debug("level on form = %s",text);

            if (!strlen(text))
              tmp_level = -1;
            else
              tmp_level = atoi(text);

            if (tmp_level > level)
              {
              _pdm_debug("setting text on row %d", (char *)row);
              FIfld_set_text(fp, REV_MCF, row, CAT_COL,  msg, TRUE);
              FIfld_set_text(fp, REV_MCF, row, PART_COL, msg, TRUE);
              FIfld_set_text(fp, REV_MCF, row, REV_COL,  msg, TRUE);
              FIfld_set_text(fp, REV_MCF, row, DESC_COL, msg, TRUE);
              FIfld_set_text(fp, REV_MCF, row, LOCFILE_COL, NULL_STRING, TRUE);
              FIfld_set_text(fp, REV_MCF, row, STGFILE_COL, NULL_STRING, TRUE);
              }
            else if (tmp_level == -1)
              {
              FIfld_set_text(fp, REV_MCF, row, LOCFILE_COL, NULL_STRING, TRUE);
              FIfld_set_text(fp, REV_MCF, row, STGFILE_COL, NULL_STRING, TRUE);
              }
            else
              break;
            }

         current_rev_assy = PDU_assy_ptr;

         _pdm_debug("finding active row in link list", 0);
         while (current_rev_assy)
            {
            if (current_rev_assy->mcf_row == act_row)
              break;
            else
              current_rev_assy = current_rev_assy->next;
            }

         strcpy(current_rev_assy->delete, "Y");
         PDUupdate_mult_files_for_rev_assy("delete", "Y");

         _pdm_debug("saving part data", 0);
         PDUfill_in_string(&catalog, current_rev_assy->new_catalog);
         PDUfill_in_string(&partid, current_rev_assy->new_partid);
         PDUfill_in_string(&revision, current_rev_assy->new_revision);

         if (current_rev_assy)
           current_rev_assy = current_rev_assy->next;
         else
           return(PDM_S_SUCCESS);
       
         _pdm_debug("marking deleted children in link list", 0);
         while (current_rev_assy)
           {
           if (current_rev_assy->ex_level > level)
             {
             strcpy(current_rev_assy->delete, "Y");
             PDUupdate_mult_files_for_rev_assy("delete", "Y");
             }
           else if (current_rev_assy->ex_level == -1)  /* multiple file */
             {
             strcpy(current_rev_assy->delete, "Y");
             PDUupdate_mult_files_for_rev_assy("delete", "Y");
             }
           else
             break;
           current_rev_assy = current_rev_assy->next;
           }

         _pdm_debug("look for multiple occurrences at same level", 0);
         PDUdelete_multiple_occurrences(catalog, partid, revision, level,
                                        parent_cat, parent_part, parent_rev);

         PDUdisplay_status(status, fp);

         break;

    case UNDEL_BTN:

         _pdm_debug("UNDEL_BTN", 0);

         FIfld_get_num_rows(fp, REV_MCF, &num_rows);
         for (row = 0; row < num_rows; ++row)
            {
            FImcf_get_select(fp, REV_MCF, row, &select);
            if (select)
              {
              FIfld_set_active_row(fp, REV_MCF, row, 0);
              break;
              }
            }

         if (!select)
           {
           PDUdisplay_status(PDM_E_NO_PARTS_SELECTED, fp);
           break;
           }

         act_row = row;

         if (act_row == 0)
           {
           PDUdisplay_status(PDM_E_CANNOT_DELETE_PARENT, fp);
           break;
           }

         current_rev_assy = PDU_assy_ptr;
         _pdm_debug("finding active row in link list", 0);
         while (current_rev_assy)
            {
            if (current_rev_assy->mcf_row == act_row)
              break;
            else
              current_rev_assy = current_rev_assy->next;
            }

         if (current_rev_assy)
           {
           if (strcmp(current_rev_assy->delete, "N") == 0)
             {
             PDUdisplay_status(PDM_E_NOT_MARKED_FOR_DELETE, fp);
             break;
             }
  
           strcpy(current_rev_assy->delete, "N");
           PDUupdate_mult_files_for_rev_assy("delete", "N");
  
           FIfld_set_text(fp, REV_MCF, act_row, CAT_COL, 
                          current_rev_assy->new_catalog, TRUE);
           FIfld_set_text(fp, REV_MCF, act_row, PART_COL, 
                          current_rev_assy->new_partid, TRUE);
           FIfld_set_text(fp, REV_MCF, act_row, REV_COL, 
                          current_rev_assy->new_revision, TRUE);
           FIfld_set_text(fp, REV_MCF, act_row, DESC_COL, 
                          current_rev_assy->new_desc, TRUE);
           if (current_rev_assy->new_cofilename)
             FIfld_set_text(fp, REV_MCF, act_row, LOCFILE_COL, 
                          current_rev_assy->new_cofilename, TRUE);
           if (current_rev_assy->new_cifilename)
             FIfld_set_text(fp, REV_MCF, act_row, STGFILE_COL, 
                          current_rev_assy->new_cifilename, TRUE);
  
           level = current_rev_assy->ex_level;
           if (current_rev_assy)
             current_rev_assy = current_rev_assy->next;
           else
             break;
           }

         _pdm_debug("marking children and multiple files on form", 0);
         row = act_row + 1;
         while (current_rev_assy)
            {
            if (current_rev_assy->ex_level > level)
              {
              _pdm_debug("resetting undeleted children", 0);
              strcpy(current_rev_assy->delete, "N");
              PDUupdate_mult_files_for_rev_assy("delete", "N");

              FIfld_set_text(fp, REV_MCF, row, CAT_COL, 
                             current_rev_assy->new_catalog, TRUE);
              FIfld_set_text(fp, REV_MCF, row, PART_COL, 
                             current_rev_assy->new_partid, TRUE);
              FIfld_set_text(fp, REV_MCF, row, REV_COL, 
                             current_rev_assy->new_revision, TRUE);
              FIfld_set_text(fp, REV_MCF, row, DESC_COL, 
                             current_rev_assy->new_desc, TRUE);
              if (current_rev_assy->new_cofilename)
                FIfld_set_text(fp, REV_MCF, row, LOCFILE_COL, 
                             current_rev_assy->new_cofilename, TRUE);
              if (current_rev_assy->new_cifilename)
                FIfld_set_text(fp, REV_MCF, row, STGFILE_COL, 
                             current_rev_assy->new_cifilename, TRUE);
              ++row;
              current_rev_assy = current_rev_assy->next;
              }
            else if (current_rev_assy->ex_level == -1)
              {
              if (current_rev_assy->new_cofilename)
                FIfld_set_text(fp, REV_MCF, row, LOCFILE_COL, 
                             current_rev_assy->new_cofilename, TRUE);
              if (current_rev_assy->new_cifilename)
                FIfld_set_text(fp, REV_MCF, row, STGFILE_COL, 
                             current_rev_assy->new_cifilename, TRUE);
              ++row;
              current_rev_assy = current_rev_assy->next;
              }
            else
              break;
            }

         PDUfind_parent_in_mcf(act_row, level, &parent_cat, &parent_part,
                  &parent_rev, &row, &parent_level, &childno, &pchildno);

         current_rev_assy = PDU_assy_ptr;

         _pdm_debug("finding active row in link list", 0);
         while (current_rev_assy)
            {
            if (current_rev_assy->mcf_row == act_row)
              break;
            else
              current_rev_assy = current_rev_assy->next;
            }

         strcpy(current_rev_assy->delete, "N");
         PDUupdate_mult_files_for_rev_assy("delete", "N");

         _pdm_debug("saving part data", 0);
         PDUfill_in_string(&catalog, current_rev_assy->new_catalog);
         PDUfill_in_string(&partid, current_rev_assy->new_partid);
         PDUfill_in_string(&revision, current_rev_assy->new_revision);

         if (current_rev_assy)
           current_rev_assy = current_rev_assy->next;
         else
           return(PDM_S_SUCCESS);

         _pdm_debug("marking deleted children in link list", 0);
         while (current_rev_assy)
           {
           if (current_rev_assy->ex_level > level)
             {
             strcpy(current_rev_assy->delete, "N");
             PDUupdate_mult_files_for_rev_assy("delete", "N");
             }
           else if (current_rev_assy->ex_level == -1)  /* multiple file */
             {
             strcpy(current_rev_assy->delete, "N");
             PDUupdate_mult_files_for_rev_assy("delete", "N");
             }
           else
             break;
           current_rev_assy = current_rev_assy->next;
           }

         _pdm_debug("look for multiple occurrences at same level", 0);
         PDUundelete_multiple_occurrences(catalog, partid, revision, level,
                                        parent_cat, parent_part, parent_rev);

         PDUdisplay_status(PDM_S_SUCCESS, fp);

         break;

    case SUFFIX_FLD:

         _pdm_debug("getting file suffix", 0);
         FIfld_get_text_length(fp, SUFFIX_FLD, 0, 0, &length);
         suffix = (char *) malloc (sizeof (char) * length + 1);
         memset(suffix, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp, SUFFIX_FLD, 0, 0, length,
                       (unsigned char *)suffix, &select, &pos);
         _pdm_debug("suffix = <%s>", suffix);

         length = strlen(suffix);
         if (length > 5)
           {
           PDUdisplay_status(PDM_E_IDENTIFIER_TOO_LONG, fp);
           FIg_set_text(fp, SUFFIX_FLD, NULL_STRING);
           break;
           }

         PDUfill_in_string(&PDU_file_suffix, suffix);

         break;

    case SUFFIX_TGL:

         FIg_get_state(fp, SUFFIX_TGL, &state);
         if (state)
           {
           FIfld_set_mode(fp,SUFFIX_FLD,0, FI_INSERT); 
           if (PDU_file_suffix)
             FIg_set_text(fp, SUFFIX_FLD, PDU_file_suffix);
           PDU_use_suffix = TRUE;
           }
         else
           {
           FIfld_set_mode(fp,SUFFIX_FLD,0, FI_REVIEW); 
           FIg_set_text(fp, SUFFIX_FLD, NULL_STRING);
           PDU_use_suffix = FALSE;
           }

         break;

    case COPY_BTN:

         FIfld_get_num_rows(fp, REV_MCF, &num_rows);
         current_rev_assy = PDU_assy_ptr;
    
         _pdm_debug("getting file suffix", 0);
         FIfld_get_text_length(fp, SUFFIX_FLD, 0, 0, &length);
         suffix = (char *) malloc (sizeof (char) * length + 1);
         memset(suffix, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp, SUFFIX_FLD, 0, 0, length,
                       (unsigned char *)suffix, &select, &pos);
         _pdm_debug("suffix = <%s>", suffix);

         row = 0;
         while (current_rev_assy)
           {
           /* bypass the parts that are not displayed */
           if (strcmp(current_rev_assy->display, "N") == 0)
             {
             current_rev_assy = current_rev_assy->next;
             continue;
             }

           if (current_rev_assy->ex_level != -1)
             {
             sprintf(level_str, "%d", (current_rev_assy->ex_level));
             _pdm_debug("level = %d", (char *)level_str);
             FIfld_set_text(fp, REV_MCF, row, NEWLEV_COL, level_str, FALSE);
             current_rev_assy->new_level = current_rev_assy->ex_level;

             if (file_bufr)
               {
               MEMclose(&file_bufr);
               file_bufr = NULL;
               }
             }

           add_msg = (char *)PDUtranslate_message(PDM_I_ADDED_ROW);
           if (strcmp(current_rev_assy->ex_catalog, add_msg) != 0)
             {
             _pdm_debug("processing existing row", 0);

             if (current_rev_assy->ex_level != -1)
               {
               FIfld_set_text(fp, REV_MCF, row, CAT_COL, 
                              current_rev_assy->ex_catalog, FALSE);
               FIfld_set_text(fp, REV_MCF, row, PART_COL, 
                              current_rev_assy->ex_partid, FALSE);
               FIfld_set_text(fp, REV_MCF, row, REV_COL, 
                              NULL_STRING, FALSE);
    
               PDUfill_in_string(&(current_rev_assy)->new_catalog,
                                 current_rev_assy->ex_catalog);
               PDUfill_in_string(&(current_rev_assy)->new_partid,
                                 current_rev_assy->ex_partid);
               PDUfill_in_string(&(current_rev_assy)->new_revision,
                                 NULL_STRING);
  
               if (current_rev_assy->ex_desc)
                 {
                 FIfld_set_text(fp, REV_MCF, row, DESC_COL, 
                              current_rev_assy->ex_desc, FALSE);
                 PDUfill_in_string(&(current_rev_assy)->new_desc,
                                   current_rev_assy->ex_desc);
                 }
               }

             /* add the suffix for new_filename */
             _pdm_debug("adding suffix to cofilename filename", 0);
             if ((PDU_use_suffix) && (suffix) && (strlen(suffix)) &&
                 (strlen(current_rev_assy->ex_cofilename)))
               {
               status = PDUappend_file_suffix(current_rev_assy->ex_cofilename,
                                              suffix, newfile);
               _pdm_status("PDUappend_file_suffix", status);
               _pdm_debug("new filename = <%s>", newfile);
       
               PDUfill_in_string(&(current_rev_assy->new_cofilename), newfile);
               }
             else if (!strlen(current_rev_assy->ex_cofilename))
               {
               _pdm_debug("existing filename is empty", 0);
               PDUfill_in_string(&(current_rev_assy->new_cofilename),
                                 NULL_STRING);
               }
             else
               {
               _pdm_debug("file will not have a suffix", 0);
               PDUfill_in_string(&(current_rev_assy->new_cofilename),
                                 current_rev_assy->ex_cofilename);
               }

             FIfld_set_text(fp, REV_MCF, row, LOCFILE_COL, 
                           current_rev_assy->new_cofilename, FALSE);
  
             /* get the storage area filename */
             _pdm_debug("getting storage area filename", 0);
             status = PDUget_storage_filename(current_rev_assy->ex_catalog,
                                          current_rev_assy->ex_partid,
                                          current_rev_assy->ex_revision,
                                          current_rev_assy->ex_cofilename,
                                          &file_bufr, &filename);
             _pdm_status("PDUget_storage_filename", status);
  
             /* append suffix to storage area filename */
             if ((PDU_use_suffix) && (filename) && (strlen(filename)))
               {
               _pdm_debug("adding suffix to cifilename filename", 0);
               if ((suffix) && (strlen(suffix)))
                 {
                 status = PDUappend_file_suffix(filename, suffix, newfile);
                 _pdm_status("PDUappend_file_suffix", status);
                 _pdm_debug("new filename = <%s>", newfile);
    
                 PDUfill_in_string(&(current_rev_assy->new_cifilename),newfile);
                 }
               else
                 {
                 _pdm_debug("file will not have a suffix", 0);
                 PDUfill_in_string(&(current_rev_assy->new_cifilename),
                                   filename);
                 }
               FIfld_set_text(fp, REV_MCF, row, STGFILE_COL, 
                              current_rev_assy->new_cofilename, FALSE);
               }
             else
               FIfld_set_text(fp,REV_MCF, row, STGFILE_COL, NULL_STRING, FALSE);
             }
           else
             {
             _pdm_debug("processing added row", 0);

             /* add the suffix for new_filename */
             _pdm_debug("adding suffix to cofilename filename", 0);
             if ((PDU_use_suffix) && (suffix) && (strlen(suffix)))
               {
              if ((current_rev_assy->new_cofilename) &&
                  (strlen(current_rev_assy->new_cofilename)))
                {
                status = PDUappend_file_suffix(current_rev_assy->new_cofilename,
                                               suffix, newfile);
                _pdm_status("PDUappend_file_suffix", status);
                _pdm_debug("new filename = <%s>", newfile);
        
                PDUfill_in_string(&(current_rev_assy->new_cofilename), newfile);
                FIfld_set_text(fp, REV_MCF, row, LOCFILE_COL, 
                               current_rev_assy->new_cofilename, FALSE);
                }

              if ((current_rev_assy->new_cifilename) &&
                  (strlen(current_rev_assy->new_cifilename)))
                {
                status = PDUappend_file_suffix(current_rev_assy->new_cifilename,
                                               suffix, newfile);
                _pdm_status("PDUappend_file_suffix", status);
                _pdm_debug("new filename = <%s>", newfile);
        
                PDUfill_in_string(&(current_rev_assy->new_cifilename), newfile);
                FIfld_set_text(fp, REV_MCF, row, LOCFILE_COL, 
                               current_rev_assy->new_cifilename, FALSE);
                }
               }
             else
               {
               _pdm_debug("file for added part will not have a suffix", 0);
               }

             }

           ++row;
           current_rev_assy = current_rev_assy->next;
           }

         current_rev_assy = PDU_assy_ptr;

         if (file_bufr)
           {
           MEMclose(&file_bufr);
           file_bufr = NULL;
           }

         PDUdisplay_status(PDM_S_SUCCESS, fp);

         break;

    case SEARCH_BTN:
         _pdm_debug("SEARCH_BTN", 0);
  
         _pdm_debug("check to see if there is a valid row for placement", 0);
         FIfld_get_num_rows(fp, REV_MCF, &num_rows);
         for (row = 0; row < num_rows; ++row)
            {
            FIfld_get_text_length(fp,REV_MCF,row,0,&length);
            text = (char *)malloc(sizeof(char) * length + 1);
            memset(text,NULL,sizeof(char) * length + 1);
            FIfld_get_text(fp,REV_MCF,row,0,length,
                          (unsigned char *)text, &select, &pos);
            level = atoi(text);
            if (level > 0)
              {
              found = TRUE;
              break;
              }
            }
         if (!found)
           {
           PDUdisplay_status(PDM_E_PLACE_ROW_BEFORE_SEARCH, fp);
           break;
           }

         _pdm_debug("deselecting selected rows", 0);
         for (row = 0; row < num_rows; ++row)
            {
            FImcf_get_select(fp, REV_MCF, row, &select);
            if (select)
              {
              _pdm_debug("row = %d", (char *)row);
              FImcf_set_select(fp, REV_MCF, row, FALSE);
              break;
              }
            }

         /* Bring up the search form */
         PDU_form_id = forms.rev_assy_form_id;
         FIf_erase(fp);
         SelectOrPlacePart(TRUE,FALSE,fp);
             
         break;

    case PLCMT_OPTS:

         FIf_erase(fp);
         PDU_calling_form = fp;

         status = PDUdesign_options_form();
         _pdm_status("PDUdesign_options_form", status);

         break;

  } /* END switch ( g_label ) */

 return(1);

} /* END notification_routine() */



/*  Function to get attributes, data, list, and funcs  for the given catalog, 
    part and revision. Display the attributes on the attribute value form and 
    assign buffers to PDUattr_data structure in PDUrev_assy structure.
*/
long PDUget_part_bufrs(catalog, partid, revision, attr_data, exist)
char   *catalog;
char   *partid;
char   *revision;
struct PDUattr_data **attr_data;
short  exist;
{
  char **attr_col = NULL, **data_col = NULL;
  char **attr_row = NULL, **data_row = NULL;
  char **attr_format = NULL, **data_format = NULL;
  char cat_type[5];
  int status;
  MEMptr attr_bufr = NULL; 
  MEMptr data_bufr = NULL;
  MEMptr list_bufr = NULL;

    _pdm_debug("Enter: PDUget_part_bufrs",0);

    if (!(*attr_data))
      {
      _pdm_debug("mallocing structure for buffers", 0);
      *attr_data = (struct PDUattr_data *)malloc(sizeof (struct PDUattr_data));
      (*attr_data)->attr_bufr = NULL;
      (*attr_data)->data_bufr = NULL;
      (*attr_data)->list_bufr = NULL;
      (*attr_data)->func_bufr = NULL;
      (*attr_data)->file_bufr = NULL;
      }
    else
      {
      if ((*attr_data)->attr_bufr)
        {
        MEMclose(&(*attr_data)->attr_bufr);
        (*attr_data)->attr_bufr = NULL;
        }
      if ((*attr_data)->data_bufr)
        {
        MEMclose(&(*attr_data)->data_bufr);
        (*attr_data)->data_bufr = NULL;
        }
      if ((*attr_data)->list_bufr)
        {
        MEMclose(&(*attr_data)->list_bufr);
        (*attr_data)->list_bufr = NULL;
        }
      if ((*attr_data)->func_bufr)
        {
        MEMclose(&(*attr_data)->func_bufr);
        (*attr_data)->func_bufr = NULL;
        }
      if ((*attr_data)->file_bufr)
        {
        MEMclose(&(*attr_data)->file_bufr);
        (*attr_data)->file_bufr = NULL;
        }
      }

    _pdm_debug("catalog = <%s>", catalog);
    _pdm_debug("partid = <%s>", partid);
    _pdm_debug("revision = <%s>", revision);

    status = PDMquery_catalog_type(catalog, cat_type);
    _pdm_status("PDMquery_catalog", status);

    if ((strcmp(cat_type, "P") == 0) || (strcmp(cat_type, "PXT") == 0))
      {
      _pdm_debug("catalog type is parametric", 0);

      if (!strlen(catalog))
        return(PDM_I_ENTER_CATALOG);
      if (!strlen(partid))
        return(PDM_I_ENTER_PART);
      if (!strlen(revision))
        return(PDM_I_ENTER_REVISION);

      status = PDUget_param_attrs_for_rev_assy(catalog, partid, revision);
      _pdm_status("PDUget_param_attrs_for_rev_assy", status);
      if (status != PDM_S_SUCCESS)
        return(status);

      status = MEMsplit_copy_buffer(PDU_parm_attr_bufr,
                                    &(*attr_data)->attr_bufr,0);
      _pdm_status("MEMsplit_copy_buffer",status);

      status = MEMsplit_copy_buffer(PDU_parm_data_bufr,
                                    &(*attr_data)->data_bufr,0);
      _pdm_status("MEMsplit_copy_buffer",status);
    
      status = MEMsplit_copy_buffer(PDU_parm_list_bufr,
                                    &(*attr_data)->list_bufr,1);
      _pdm_status("MEMsplit_copy_buffer",status);
     
      if (PDU_parm_attr_bufr)
        {
        MEMclose(&PDU_parm_attr_bufr);
        PDU_parm_attr_bufr = NULL;
        }
      if (PDU_parm_data_bufr)
        {
        MEMclose(&PDU_parm_data_bufr);
        PDU_parm_data_bufr = NULL;
        }
      if (PDU_parm_list_bufr)
        {
        MEMclose(&PDU_parm_list_bufr);
        PDU_parm_list_bufr = NULL;
        }
      }
    else
      {
      if ((review_mode == TRUE) && (exist))
        {
        status = PDMget_existing_data(catalog, partid, revision);
        _pdm_status("PDMget_existing_data",status);
        }
      else
        {
        if (exist)
          {
          /* temporarily set change mode to TRUE */
          change_mode = TRUE;
          status = PDMget_existing_data(catalog, partid, revision);
          _pdm_status("PDMget_existing_data",status);
          change_mode = FALSE;
          }
        else /* part does not exist */
          {
          PDU_main_form_cat = FALSE;
          bufr_flag = TRUE;
          status = PDMrverify_catalog("", catalog);
          _pdm_status("PDMrverify_catalog", status);
          bufr_flag = FALSE;
          }
        }
    
      if ((review_mode == TRUE) && 
         ((status == PDM_E_PART_FLAGGED_FOR_ARCHIVE) ||
          (status == PDM_E_PART_ARCHIVED) ||
          (status == PDM_E_PART_FLAGGED_FOR_BACKUP) ||
          (status == PDM_E_PART_FLAGGED_FOR_DELETE) ||
          (status == NFM_E_ITEM_FLAGGED) ||
          (status == PDM_E_PART_FLAGGED_FOR_RESTORE)))
             status = PDM_S_SUCCESS;
      else if (status != PDM_S_SUCCESS)
        {
        _pdm_debug("part is not flagged and status != SUCCESS",0);
        PDUcleanup_attr_retrieval();
        return(status);
        }

      /* Data is in global buffer PDU_ret_bufr. Split data into buffers.*/
  
      _pdm_debug("splitting return buffer into attr buffer",0);
      status = PDUsetup_buffer_list(PDU_ret_bufr,1,0,&attr_row, &attr_col, 
                                    &attr_format,&attr_bufr);
      if (status != PDM_S_SUCCESS)
        {
          if (PDU_ret_bufr)
            {
              MEMclose(&PDU_ret_bufr);
              PDU_ret_bufr = NULL;
            } 
           if (attr_bufr)
             MEMclose(&attr_bufr);
           return(status);
        }
  
      _pdm_debug("splitting return buffer into data buffer",0);
      status = PDUsetup_buffer_list(PDU_ret_bufr,2,0,&data_row, &data_col, 
                                    &data_format,&data_bufr);
      if (status != PDM_S_SUCCESS)
        {
          if (PDU_ret_bufr)
            {
              MEMclose(&PDU_ret_bufr);
              PDU_ret_bufr = NULL;
            } 
           if (attr_bufr)
             MEMclose(&attr_bufr);
           if (data_bufr)
             MEMclose(&data_bufr);
           return(status);
        }
  
      status = MEMreset_buffer_no(PDU_ret_bufr, 3);
      _pdm_status("MEMreset_buffer_no", status);
  
      status = MEMsplit_copy_buffer(PDU_ret_bufr, &list_bufr, 1);
      _pdm_status("MEMsplit_copy_buffer", status);
   
      if (status != MEM_S_SUCCESS)
        {
          if (PDU_ret_bufr)
            {
              MEMclose(&PDU_ret_bufr);
              PDU_ret_bufr = NULL;
            } 
           if (attr_bufr)
             MEMclose(&attr_bufr);
           if (data_bufr)
             MEMclose(&data_bufr);
           if (list_bufr)
             MEMclose(&list_bufr);
           return(PDM_E_COPY_BUFFER);
        }

      /* Assign buffers to structure in rev_assy structure */ 
 
      _pdm_debug("setting buffers", 0);
    
      status = MEMsplit_copy_buffer(attr_bufr,&(*attr_data)->attr_bufr,0);
      _pdm_status("MEMsplit_copy_buffer",status);
    
      status = MEMsplit_copy_buffer(data_bufr,&(*attr_data)->data_bufr,0);
      _pdm_status("MEMsplit_copy_buffer",status);
    
      status = MEMsplit_copy_buffer(list_bufr,&(*attr_data)->list_bufr,1);
      _pdm_status("MEMsplit_copy_buffer",status);
     
/* 11/30/95 MJG - Unlock item before moving on */
      _pdm_debug("unlock table for existing part", 0);
      PDUunlock_item(catalog, partid, revision);
      status = PDMcancel_modify_part(catalog, partid, revision,
                                     attr_bufr, data_bufr);
      _pdm_status("PDMcancel_modify_part", status);
      }
  
   /* Get function buffer */

   _pdm_debug("calling PDMmove_functions", 0);
   if (PDU_func_buffer)
    {
      MEMclose(&PDU_func_buffer);
      PDU_func_buffer = NULL;
    }
   status = PDMmove_functions(catalog,
                               storage->storage_name,
                               &PDU_func_buffer);
   _pdm_status("PDMmove_functions", status);

  if (PDU_func_buffer)
    {
    _pdm_debug("saving PDU_func_buffer", 0);
    status = MEMsplit_copy_buffer(PDU_func_buffer, &(*attr_data)->func_bufr,0);
    _pdm_status("MEMsplit_copy_buffer",status);
    }

  if (PDM_debug_on)
    {
    _pdm_debug("printing attr_data", 0);
    PDUprint_attr_data_buffers(*attr_data);
    }

  if (attr_bufr)
    {
     MEMclose(&attr_bufr);
     attr_bufr = NULL;
    }

  if (data_bufr)
   {
     MEMclose(&data_bufr);
     data_bufr = NULL;
   }

  if (list_bufr)
   {
     MEMclose(&list_bufr);
     list_bufr = NULL;
   }

  if (PDU_func_buffer)
   {
     MEMclose(&PDU_func_buffer);
     PDU_func_buffer = NULL;
   }

  if (PDU_ret_bufr)
   {
     MEMclose(&PDU_ret_bufr);
     PDU_ret_bufr = NULL;
   }

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  _pdm_debug("Exit PDUget_part_bufrs",0);
  return(status);
}

  /* This function is used to fill the attribute value forms attr_mcf. */
long PDU_display_attr_in_mcf(rev_attr_data)
struct PDUattr_data *rev_attr_data;
{

  int i,j,num_rows = 0;
  int read_write_col,status;
  int n_name_col;
  int n_syn_col;
  int FOUND = FALSE,buffer_number;
  int n_saname_col = 0;
  int n_sano_col = 0;
  int stg_buffer_no = 0;
  int stg_field_row = 0;
  int stg_col = 0;
  int cisano_row = 0;
  int n_valueno_col = 0;
  int type_col = 0;
  int row = 0;
  int select, pos, length = 0;
  char **dummy1;
  char **dummy2;
  char **stg_row;
  char *string = NULL;
  char *attr_name = NULL;
  char *attr_syn = NULL;
  char **func_data = NULL;
  char **attr_row;
  char **data_row;
  char **list_data;
  char **list_values;
  static char *text = NULL;
  MEMptr stg_bufr = NULL;

   _pdm_debug("Enter: PDU_display_attr_in_mcf",0);  

/*
   if (PDM_debug_on)
     {
    MEMprint_buffer("rev assem attr bufr",(rev_attr_data)->attr_bufr,
                    PDU_DEBUG_FILE);
    MEMprint_buffer("rev assem data bufr",(rev_attr_data)->data_bufr,
                    PDU_DEBUG_FILE);
    MEMprint_buffers("rev assem list bufr",(rev_attr_data)->list_bufr,
                    PDU_DEBUG_FILE);
    MEMprint_buffer("rev assem func bufr",(rev_attr_data)->func_bufr,
                    PDU_DEBUG_FILE);
     }
*/

   if ((!rev_attr_data->attr_bufr) || (!rev_attr_data->data_bufr) ||
       (!rev_attr_data->list_bufr))
     {
     PDUmessage(PDM_E_NULL_BUFFER, 's');
     return(PDM_E_NULL_BUFFER);
     }

  _pdm_debug("setting global buffers", 0);
  if (PDU_attr_bufr)
    {
    MEMclose(&PDU_attr_bufr);
    PDU_attr_bufr = NULL;
    }
  if (PDU_data_bufr)
    {
    MEMclose(&PDU_data_bufr);
    PDU_data_bufr = NULL;
    }
  if (PDU_list_bufr)
    {
    MEMclose(&PDU_list_bufr);
    PDU_list_bufr = NULL;
    }
  if (PDU_func_buffer)
    {
    MEMclose(&PDU_func_buffer);
    PDU_func_buffer = NULL;
    }

   status = MEMsplit_copy_buffer(rev_attr_data->attr_bufr, &PDU_attr_bufr, 0);
   _pdm_status("MEMsplit_copy_buffer", status);
   status = MEMsplit_copy_buffer(rev_attr_data->data_bufr, &PDU_data_bufr, 0);
   _pdm_status("MEMsplit_copy_buffer", status);
   status = MEMsplit_copy_buffer(rev_attr_data->list_bufr, &PDU_list_bufr, 1);
   _pdm_status("MEMsplit_copy_buffer", status);
   status = MEMsplit_copy_buffer(rev_attr_data->func_bufr, &PDU_func_buffer, 1);
   _pdm_status("MEMsplit_copy_buffer", status);

   FIg_reset(PDU_form_id, ATTR_MCF);
   FIfld_set_max_num_rows(PDU_form_id, ATTR_MCF, PDU_attr_bufr->rows);

   /* Fill attribute value mcf */

    if (review_mode == TRUE)
      {
      read_write_col = PDU_NFM_READ_COL;
      _pdm_debug("review_mode = TRUE", 0);
      }
    else
      {
      read_write_col = PDU_NFM_WRITE_COL;
      _pdm_debug("review_mode = FALSE", 0);
      }

    status = MEMbuild_array(PDU_attr_bufr);
    _pdm_status("MEMbuild_array",status);
    status = MEMbuild_array(PDU_data_bufr);
    _pdm_status("MEMbuild_array",status);

    status = PDUget_buffer_col(PDU_attr_bufr,"n_name", &n_name_col);
    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return(status);
      }

    status = PDUget_buffer_col(PDU_attr_bufr,"n_valueno", &n_valueno_col);
    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return(status);
      }
    
    status = PDUget_buffer_col(PDU_data_bufr,"p_parttype", &type_col);
    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return(status);
      }
    
    attr_row = (char **)PDU_attr_bufr->data_ptr;
    data_row = (char **)PDU_data_bufr->data_ptr;

    _pdm_debug("attr_bufr rows = <%d>", (char *)(PDU_attr_bufr->rows));

    for (i=0; i < PDU_attr_bufr->rows; i++)
     {
       if (strcmp(attr_row[(PDU_attr_bufr->columns * i) + read_write_col],"Y")
         == 0)
        {
         if ((strcmp(attr_row[(PDU_attr_bufr->columns * i) + n_name_col], 
             "n_itemname") != 0) &&
             (strcmp(attr_row[(PDU_attr_bufr->columns * i) + n_name_col],
             "n_itemrev") != 0) &&
             (strcmp(attr_row[(PDU_attr_bufr->columns * i) + n_name_col],
             "n_itemdesc") != 0) &&
             (strcmp(attr_row[(PDU_attr_bufr->columns * i) + n_name_col],
             "n_cofilename") != 0) &&
             (strcmp(attr_row[(PDU_attr_bufr->columns * i) + n_name_col],
             "n_cifilename") != 0))
         {
         if (strcmp(attr_row[(PDU_attr_bufr->columns * i) + n_name_col], 
             "n_cisano") == 0)
           stg_field_row = num_rows;
           
         PDUfill_in_string(&attr_name, attr_row[(PDU_attr_bufr->columns * i)+PDU_NFM_ATTR_COL]);
         _pdm_debug("attr_name = <%s>", attr_name);

          if ((strcmp(attr_row[(PDU_attr_bufr->columns * i) + 
               PDU_NFM_LISTNO_COL], "0") == 0) && (PDU_func_buffer))
          {
          _pdm_debug("check for function", 0);
/*
          MEMprint_buffer("PDU_func_buffer", PDU_func_buffer, PDU_DEBUG_FILE);
*/
          status = MEMbuild_array(PDU_func_buffer);
          _pdm_status("MEMbuild_array", status);

          if (status != MEM_S_SUCCESS)
            return(PDM_E_BUILD_BUFFER_ARRAY);
          status = PDM_S_SUCCESS;

          func_data = (char **)PDU_func_buffer->data_ptr;

          FOUND = FALSE;
          _pdm_debug("search through rows in PDU_func_buffer", 0);
          for (j = 0; j < PDU_func_buffer->rows; j++)
           {
            _pdm_debug("row = <%d>", j);
            if (strcmp(attr_name,func_data[(PDU_func_buffer->columns *j) + 0])==0)
             {
              _pdm_debug("function attr found", 0);
              FOUND = TRUE;
              string = (char *)malloc((PDU_attr_bufr)->row_size);
              if ((strcmp(attr_row[(PDU_attr_bufr->columns * i) + 
                   PDU_NFM_SYN_COL], "") != 0) && 
                  (attr_row[(PDU_attr_bufr->columns * i) + 
                   PDU_NFM_SYN_COL] != NULL)) 
              {
                _pdm_debug("writing synonym to string", 0);
                sprintf(string, "*%s", attr_row[(PDU_attr_bufr->columns * i) + 
                        PDU_NFM_SYN_COL]);
                _pdm_debug("string after sprintf = <%s>", string);
                FIfld_set_text(PDU_form_id, ATTR_MCF, num_rows, 0,string,FALSE);
              }
              else
              {
                _pdm_debug("writing n_name to string", 0);
                sprintf(string, "*%s", attr_row[(PDU_attr_bufr->columns * i) + 
                        PDU_NFM_ATTR_COL]);
                _pdm_debug("string after sprintf = <%s>", string);
                FIfld_set_text(PDU_form_id, ATTR_MCF, num_rows, 0,string,FALSE);
              }
              free(string);
              break;
             }
            }
           if (!FOUND)
           {
             _pdm_debug("attr does not have a function", 0);
             string = (char *)malloc((PDU_attr_bufr)->row_size);
             if ((strcmp(attr_row[(PDU_attr_bufr->columns * i) + 
                  PDU_NFM_SYN_COL],"") != 0) && 
                 (attr_row[(PDU_attr_bufr->columns * i) + 
                  PDU_NFM_SYN_COL] != NULL))
              {
               sprintf(string,"%s",attr_row[(PDU_attr_bufr->columns * i) + 
                       PDU_NFM_SYN_COL]);
               _pdm_debug("writing synonym <%s> to form", string);
               FIfld_set_text(PDU_form_id, ATTR_MCF, num_rows, 0,string,FALSE);
              }
             else
              {
                sprintf(string,"%s",attr_row[(PDU_attr_bufr->columns * i) + 
                        PDU_NFM_ATTR_COL]);
                _pdm_debug("writing n_name <%s> to form", string);
                FIfld_set_text(PDU_form_id, ATTR_MCF,num_rows,0,string,FALSE);
               }
            free(string);
            }
          }
          else if (strcmp(attr_row[(PDU_attr_bufr->columns * i) + 
                   PDU_NFM_LISTNO_COL], "0") == 0)
           {
             if ((strcmp(attr_row[(PDU_attr_bufr->columns * i) + 
                  PDU_NFM_SYN_COL], "") != 0) && 
                 (attr_row[(PDU_attr_bufr->columns * i) + 
                  PDU_NFM_SYN_COL] != NULL))
                  FIfld_set_text(PDU_form_id, ATTR_MCF, num_rows, 0,
                      attr_row[(PDU_attr_bufr->columns * i) + PDU_NFM_SYN_COL],
                      FALSE);
             else
               FIfld_set_text(PDU_form_id, ATTR_MCF, num_rows, 0, 
                      attr_row[(PDU_attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
                      FALSE);
           }
          else
           {
             sscanf(attr_row[(PDU_attr_bufr->columns * i) + PDU_NFM_LISTNO_COL],
                    "%d", &buffer_number);
             status = MEMreset_buffer_no(PDU_list_bufr, buffer_number);
             _pdm_status("MEMreset_buffer_no", status);

             if (status != MEM_S_SUCCESS)
             return(PDM_E_RESET_BUFFER);

            list_data = (char **)PDU_list_bufr->column_ptr;

             if (strcmp(list_data[0], "n_value") == 0)
              {
                string = (char *)malloc(PDU_attr_bufr->row_size);
                if ((strcmp(attr_row[(PDU_attr_bufr->columns * i) + 
                     PDU_NFM_SYN_COL], "") != 0) && 
                    (attr_row[(PDU_attr_bufr->columns * i) + 
                     PDU_NFM_SYN_COL] != NULL))
                  {
                  sprintf(string, "*%s", attr_row[(PDU_attr_bufr->columns * i)+
                          PDU_NFM_SYN_COL]);
                  _pdm_debug("string after sprintf = <%s>", string);
                  FIfld_set_text(PDU_form_id,ATTR_MCF,num_rows,0,string,FALSE);
                  }
                 else
                  {
                  sprintf(string, "*%s", attr_row[(PDU_attr_bufr->columns * i) +
                          PDU_NFM_ATTR_COL]);
                  _pdm_debug("string after sprintf = <%s>", string);
                  FIfld_set_text(PDU_form_id,ATTR_MCF,num_rows,0,string,FALSE);
                  }
                free(string);
               }
              else if ((strcmp(list_data[0], "n_input") == 0) && 
                   (strcmp(list_data[1], "n_minvalue") == 0))
               {
                 string = (char *)malloc(PDU_attr_bufr->row_size);
                 memset(string, NULL, PDU_attr_bufr->row_size);
                 list_values = (char **)PDU_list_bufr->data_ptr;
                 if ((strcmp(attr_row[(PDU_attr_bufr->columns * i) + 
                      PDU_NFM_SYN_COL], "") != 0) && 
                     (attr_row[(PDU_attr_bufr->columns * i) + PDU_NFM_SYN_COL])) 
                   {
                      sprintf(string, "%s (min: %s max: %s)", 
                            attr_row[(PDU_attr_bufr->columns * i) + 
                            PDU_NFM_SYN_COL],
                            list_values[1], list_values[2]);
                      _pdm_debug("string = <%s>", string);
                      FIfld_set_text(PDU_form_id, ATTR_MCF, num_rows, 0, string,                                      FALSE);
                     }
                    else
                     {
                       sprintf(string, "%s (min: %s max: %s)",
                          attr_row[(PDU_attr_bufr->columns * i) + 
                          PDU_NFM_ATTR_COL], 
                          list_values[1], list_values[2]);
                        _pdm_debug("string = <%s>", string);
                        FIfld_set_text(PDU_form_id, ATTR_MCF, num_rows, 0, 
                               string, FALSE);
                      }
                      if (string)
                         free(string);
                    }
                    else
                     {
                       if ((strcmp(attr_row[(PDU_attr_bufr->columns * i) + 
                            PDU_NFM_SYN_COL], "") != 0) && 
                            (attr_row[(PDU_attr_bufr->columns * i) + 
                            PDU_NFM_SYN_COL] != NULL))
                         {
                           FIfld_set_text(PDU_form_id,ATTR_MCF, num_rows, 0, 
                             attr_row[(PDU_attr_bufr->columns * i) + 
                             PDU_NFM_SYN_COL],FALSE);
                         }
                        else
                         {
                          FIfld_set_text(PDU_form_id, ATTR_MCF, num_rows, 0, 
                            attr_row[(PDU_attr_bufr->columns * i) + 
                            PDU_NFM_ATTR_COL],FALSE);
                         }
                      }
            }
            _pdm_debug("PDU_data_bufr->columns %d", (char *)PDU_data_bufr->columns);
            _pdm_debug("Filling in dynamic data col", 0);
            if (strcmp(data_row[i], "") != 0)
              FIfld_set_text(PDU_form_id,ATTR_MCF,num_rows,1,data_row[i],FALSE);
            else
              FIfld_set_text(PDU_form_id, ATTR_MCF, num_rows, 1, "",FALSE);
           num_rows = num_rows + 1;
          }
         }
      }

   for (i=0; i < PDU_attr_bufr->rows; i++)
     {
     if ((strcmp(attr_row[(PDU_attr_bufr->columns * i) + 
          read_write_col],"Y") == 0) &&
         (strcmp(attr_row[(PDU_attr_bufr->columns * i) + n_name_col], 
           "n_cisano") == 0))
       {
       _pdm_debug("retrieving stg_buffer_no", 0);
       _pdm_debug("n_valueno_col = %d", (char *)n_valueno_col);
       _pdm_debug("i = %d", (char *)i);

       PDUsetup_buffer(PDU_attr_bufr, ROW, &attr_row);

       stg_buffer_no = atoi(attr_row[(PDU_attr_bufr->columns * i) + 
                       n_valueno_col]);
       _pdm_debug("stg_buffer_no = <%d>", (char *)stg_buffer_no);

       _pdm_debug("retrieving stg_bufr", 0);
       status = PDUsetup_buffer_list(PDU_list_bufr, 1, stg_buffer_no,
                                     &stg_row, &dummy1,&dummy2, &stg_bufr);
       _pdm_status("PDUsetup_buffer_list",status);
    
       if (status != PDM_S_SUCCESS)
          return(status);

       if (PDM_debug_on)
         MEMprint_buffer("stg_bufr", stg_bufr, PDU_DEBUG_FILE);
    
       status = PDUget_buffer_col(stg_bufr,"n_sano", &n_sano_col);
       if (status != PDM_S_SUCCESS)
         return (status);
    
       status = PDUget_buffer_col(stg_bufr,"n_saname", &n_saname_col);
       if (status != PDM_S_SUCCESS)
         return (status);
    
       status = PDUget_buffer_col(PDU_data_bufr,"n_cisano", &stg_col);
       if (status != PDM_S_SUCCESS)
         return (status);
    
       /* Find defaulted storage area in the stg_bufr */
       for (i = 0; i < stg_bufr->rows; i ++)
          {
          if (strcmp(stg_row[(stg_bufr->columns * i) + n_sano_col],
              data_row[stg_col]) == 0)
             {
             cisano_row = i;
             break;
             }
          }
    
       /* Write storage area name to the form */
       _pdm_debug("storage area name = <%s>", stg_row[(stg_bufr->columns * cisano_row) + n_saname_col]);
       FIfld_set_text(forms.attr_value_form_id,ATTR_MCF, stg_field_row, 1,
              stg_row[(stg_bufr->columns * cisano_row) + n_saname_col], FALSE);

       /* Put default storage area number into the data buffer */
       _pdm_debug("storage area number = <%s>", stg_row[(stg_bufr->columns * cisano_row) + n_sano_col]);
       status = MEMwrite_data(PDU_data_bufr, stg_row[(stg_bufr->columns * 
                cisano_row) + n_sano_col], 1,stg_col + 1);
       if (PDU_data_bufr->rows > 1)
         status = MEMwrite_data(PDU_data_bufr, stg_row[(stg_bufr->columns * 
                  cisano_row) + n_sano_col], 2,stg_col + 1);
       break;
       }
     }

   _pdm_debug("num_rows == <%d>", (char *)num_rows);

   if (num_rows > 0)
     FIfld_set_max_num_rows(PDU_form_id, ATTR_MCF, num_rows);
   else
     FIfld_set_max_num_rows(PDU_form_id, ATTR_MCF, 1);

   _pdm_debug("checking for pdmlibraries catalog", 0);
   if ((!review_mode) && 
       (strcmp(current_rev_assy->new_catalog, "pdmlibraries") == 0))
     {
     _pdm_debug("defaulting parttype", 0);
     status = PDUget_buffer_col(PDU_attr_bufr, "n_name", &n_name_col);
     if (status != PDM_S_SUCCESS)
       return(status);

     status = PDUget_buffer_col(PDU_attr_bufr, "n_synonym", &n_syn_col);
     if (status != PDM_S_SUCCESS)
       return(status);

     for (row = 0; row < PDU_attr_bufr->rows; ++row)
        {
        if (strcmp(attr_row[(PDU_attr_bufr->columns * row)+ n_name_col],
            "p_parttype") == 0)
          {
          PDUfill_in_string(&attr_name, 
              attr_row[(PDU_attr_bufr->columns * row) + n_name_col]);
          PDUfill_in_string(&attr_syn, 
              attr_row[(PDU_attr_bufr->columns * row) + n_syn_col]);
          _pdm_debug("attr_name = <%s>", attr_name);
          _pdm_debug("attr_syn = <%s>", attr_syn);
          break;
          }
        }

     _pdm_debug("searching through ATTR_MCF", 0);
     for (row = 0; row < num_rows; ++row)
        {
        FIfld_get_text_length(PDU_form_id,ATTR_MCF,row,0,&length);
        text = (char *)malloc(sizeof(char) * length + 1);
        memset(text,NULL,sizeof(char) * length + 1);
        FIfld_get_text(PDU_form_id,ATTR_MCF,row,0,length,
            (unsigned char *)text, &select, &pos);
        _pdm_debug("text = <%s>", text);
        if ((text) && ((strcmp(text, attr_name) == 0) || 
                       (strcmp(text, attr_syn) == 0)))
          {
          _pdm_debug("parttype found on row %d", (char *)row);
          FIfld_set_text(PDU_form_id, ATTR_MCF, row, 1, "M" ,FALSE);
          MEMwrite_data(PDU_data_bufr, "M", 1,type_col + 1);
          break;
          }
        }
     }

   if (PDMdebug_on)
     {
     if (rev_attr_data)
       {
       _pdm_debug("printing rev_attr_data", 0);
       PDUprint_attr_data_buffers(rev_attr_data);
       }
     if (current_rev_assy->new_attr_data)
       {
       _pdm_debug("printing current_rev_assy->new_attr_data", 0);
       PDUprint_attr_data_buffers(current_rev_assy->new_attr_data);
       }
     }

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  if (PDU_func_buffer)
    PDU_func_bufr_exists = TRUE;
  else
    PDU_func_bufr_exists = FALSE;

  _pdm_debug("Exit PDU_display_attr_in_mcf", 0);
  return(status);
}

/* This function is called by the Search routines 
   (PDUlf_form.c PDURetFromSelect) */

long PDUupdate_revise_assy_form_after_select()
{
    short  found = FALSE;

    extern void PDUdisplay_status();

    _pdm_debug("PDUupdate_revise_assy_form_after_select: ENTER\n",0);

    PDU_form_id = forms.rev_assy_form_id;
    FIf_display(forms.rev_assy_form_id);

    if (refresh->status == PDM_E_CMD_CANCELLED)
      {
      PDU_load_search_data = FALSE;
      PDUdisplay_status(PDM_E_CMD_CANCELLED, forms.rev_assy_form_id);
      return(PDM_E_CMD_CANCELLED);
      }

    current_rev_assy = PDU_assy_ptr;
    while (current_rev_assy)
      {
      if ((strlen(current_rev_assy->new_catalog)) &&
          (strlen(current_rev_assy->new_partid)) &&
          (strlen(current_rev_assy->new_revision)))
        current_rev_assy = current_rev_assy->next;
      else
        {
        _pdm_debug("an incomplete row of data was found", 0);
        found = TRUE;
        break;
        }
      }

    if (found)
      PDUdisplay_status(PDM_I_SELECT_ROW_FOR_PART, PDU_form_id);
    else
      PDUdisplay_status(PDM_I_SELECT_FOR_REPLACE, PDU_form_id);

    if (PDUsearch_part_list == NULL)
      {
       PDUmessage(PDM_I_NO_FILES_FOUND,'s');
       return(PDM_I_NO_FILES_FOUND); 
      }

    PDU_load_search_data = TRUE;

    _pdm_debug("PDUupdate_revise_assy_form_after_select: EXIT\n",0);

    return(PDM_S_SUCCESS);
}

/* This function creates the revise assembly form */
int PDUrevise_assembly_form()
{
  int  sts = PDM_S_SUCCESS;
  int  level = 50;

  MEMptr assy_bufr = NULL;
  struct PDUrev_assy *assy_list = NULL;
  struct PDUrev_assy *save_list = NULL;

  _pdm_debug("entering PDUrevise_assembly_form", 0);

  /* get the max level of display from the database */
  sts = PDUget_max_level(&level);
  _pdm_status("PDUget_max_level", sts);

  if (sts != PDM_S_SUCCESS)
    {
    PDUmessage(sts, 's');
    FIf_display(forms.local_files_form_id);
    PDU_local_files_displayed = TRUE;
    PDU_command = 0;
    return(sts);
   }

  _pdm_debug("level = %d", (char *)level);
  _pdm_debug("setting PDU_explode_depth", 0);
  PDU_explode_depth = level;
  _pdm_debug("setting PDU_save_level", 0);
  PDU_save_level = level;

  _pdm_debug("explode_depth = %d", (char *)PDU_explode_depth);
  sts = PDMget_assembly_structure(
                                  refresh->rev_catalog,
                                  refresh->rev_partid,
                                  refresh->rev_revision,
                                  PDU_explode_depth,
                                  &assy_bufr, 0);
  _pdm_status("PDMget_assembly_structure", sts);

  if ((sts != PDM_S_SUCCESS) && (sts != PDM_E_PART_NOT_ASSEMBLY))
    {
    FIf_display(forms.local_files_form_id);
    PDU_local_files_displayed = TRUE;
    PDUmessage(sts, 's');
    if (assy_bufr)
    MEMclose(&assy_bufr);
    PDU_command = 0;
    return(sts);
    }

  sts = PDUconvert_assy_buffer_to_linklist(assy_bufr, &assy_list);
  _pdm_status("PDUconvert_assy_buffer_to_linklist", sts);

  if (sts != PDM_S_SUCCESS)
    {
    FIf_display(forms.local_files_form_id);
    PDU_local_files_displayed = TRUE;
    PDUmessage(sts, 's');
    PDU_command = 0;
    return(sts);
    }

  sts = PDUcreate_BOM_assy_list(&assy_list, assy_bufr);
  _pdm_status("PDUcreate_BOM_assy_list", sts);
  if (assy_bufr)
    MEMclose(&assy_bufr);

  if (sts != PDM_S_SUCCESS)
    {
    PDUfree_assy_linklist(&PDU_assy_ptr);
    assy_list = NULL;
    FIf_display(forms.local_files_form_id);
    PDU_local_files_displayed = TRUE;
    PDUmessage(sts, 's');
    PDU_command = 0;
    return(sts);
    }

  sts = PDUadd_multiple_files_to_linklist(&assy_list);
  _pdm_status("PDUadd_multiple_files_to_linklist", sts);

  if (sts != PDM_S_SUCCESS)
    {
    PDUfree_assy_linklist(&PDU_assy_ptr);
    assy_list = NULL;
    FIf_display(forms.local_files_form_id);
    PDU_local_files_displayed = TRUE;
    PDUmessage(sts, 's');
    PDU_command = 0;
    return(sts);
    }

  _pdm_debug("Creating revise assembly form", 0);

  sts = FIf_new(REV_ASSY_FORM, "revise_assy", rev_assy_notification_routine,
                &forms.rev_assy_form_id);
  _pdm_status("FIf_new", sts);

  _pdm_debug("setting suffix toggle", 0);
  if (PDU_use_suffix)
    {
    _pdm_debug("file suffix is ON", 0);
    FIg_set_state_on(forms.rev_assy_form_id, SUFFIX_TGL);
    FIfld_set_mode(forms.rev_assy_form_id,SUFFIX_FLD,0, FI_INSERT); 
    if (PDU_file_suffix)
      FIg_set_text(forms.rev_assy_form_id, SUFFIX_FLD, PDU_file_suffix);
    else
      {
      FIg_set_text(forms.rev_assy_form_id, SUFFIX_FLD, "1");
      PDUfill_in_string(&PDU_file_suffix, "1");
      }
    }
  else
    {
    _pdm_debug("file suffix is OFF", 0);
    FIg_set_state_off(forms.rev_assy_form_id, SUFFIX_TGL);
    FIfld_set_mode(forms.rev_assy_form_id,SUFFIX_FLD,0, FI_REVIEW); 
    FIg_set_text(forms.rev_assy_form_id, SUFFIX_FLD, NULL_STRING);
    }

  assy_list = PDU_assy_ptr;
  sts = PDUload_revise_assembly_form(assy_list, forms.rev_assy_form_id,
                                     REV_MCF);
  _pdm_status("PDUload_revise_assembly_form", sts);

  if (sts != PDM_S_SUCCESS)
    {
    PDUfree_assy_linklist(&PDU_assy_ptr);
    assy_list = NULL;
    FIf_display(forms.local_files_form_id);
    PDU_local_files_displayed = TRUE;
    PDUmessage(sts, 's');
    PDU_command = 0;
    return(sts);
    }

  sts = PDUcopy_assy_linklist(assy_list, &save_list, 1); /* 1 = backup */
  _pdm_status("PDUcopy_assy_linklist", sts);

  if (sts != PDM_S_SUCCESS)
    {
    PDUfree_assy_linklist(&PDU_assy_ptr);
    PDUfree_assy_linklist(&PDU_save_ptr);
    assy_list = NULL;
    save_list = NULL;
    FIf_display(forms.local_files_form_id);
    PDU_local_files_displayed = TRUE;
    PDUmessage(sts, 's');
    PDU_command = 0;
    return(sts);
    }

  /* Display the revise assembly form and set the displayed flag to TRUE. */
  _pdm_debug("Displaying the revise assembly form", 0);

  sts = FIf_display(forms.rev_assy_form_id);

  PDU_form_id = forms.rev_assy_form_id;
  current_rev_assy = assy_list;
  forms.attr_value_form_id = 0;
  PDU_value_pulldown = 0;
  PDU_load_search_data = FALSE;
  PDUfill_in_string(&PDU_quantity, "1.000000");
  PDUfill_in_string(&PDU_incl_BOM, "Y");
  PDUfill_in_string(&PDU_incl_ASM, "Y");
  PDUfill_in_string(&PDU_explode_BOM, "Y");
  PDUfill_in_string(&PDU_usage_id, NULL_STRING);

  PDUmessage(PDM_S_SUCCESS, 's');

  return(PDM_S_SUCCESS);
}

/* This function queries the database for the storage file name(s) for the
   given part */

int PDUget_storage_filename(catalog, part, rev, loc_filename, file_bufr,stg_filename)
char  *catalog;
char  *part;
char  *rev;
char  *loc_filename;
MEMptr *file_bufr;
char  **stg_filename;
{
  char    **data_row;
  char    *file = NULL;
  int     row = 0;
  int     cofile_col = 0;
  int     cifile_col = 0;
  int     status = PDM_S_SUCCESS;
  MEMptr  ret_bufr = NULL;

  _pdm_debug("in the function PDUget_storage_filename", 0);

  if (!(*file_bufr))
    {
    _pdm_debug("calling PDMget_stg_filename", 0);
    status = PDMget_stg_filename(catalog, part, rev, &ret_bufr);
    _pdm_status("PDMget_stg_filename", status);
  
    if (status != PDM_S_SUCCESS)
      return(status);
  
    if (PDMdebug_on)
      MEMprint_buffers("file_bufr", ret_bufr, PDU_DEBUG_FILE);
  
    if (!(ret_bufr))
      return(PDM_E_RET_LIST_FILENAMES);

    status = MEMsplit_copy_buffer(ret_bufr, file_bufr, 0);
    _pdm_status("MEMsplit_copy_buffer", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_COPY_BUFFER);

    status = MEMbuild_array(*file_bufr);
    _pdm_status("MEMbuild_array", status);
  
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    status = PDM_S_SUCCESS;

    PDUsetup_buffer(*file_bufr, ROW, &data_row);
    }
  else
    {
    _pdm_debug("buffer already exists", 0);
    MEMbuild_array(*file_bufr);
    PDUsetup_buffer(*file_bufr, ROW, &data_row);
    }

  if (PDMdebug_on)
     MEMprint_buffer("file_bufr",*file_bufr,PDU_DEBUG_FILE);

  PDUget_buffer_col(*file_bufr, "n_cofilename", &cofile_col);
  PDUget_buffer_col(*file_bufr, "n_cifilename", &cifile_col);

  for (row = 0; row < (*file_bufr)->rows; ++row)
     {
     PDUfill_in_string(&file, data_row[((*file_bufr)->columns * row) + cofile_col]);
     _pdm_debug("loc_filename = <%s>", loc_filename);
     _pdm_debug("file = <%s>", file);

     if (strcmp(loc_filename, file) == 0)
       {
       PDUfill_in_string(stg_filename, data_row[((*file_bufr)->columns * row) + cifile_col]);
       _pdm_debug("stg_filename = <%s>", *stg_filename);
       break;
       }
     }

  if (ret_bufr)
    MEMclose(&ret_bufr);
  if (file)
    free(file);

  return(status);
}

int PDUverify_storage_filename(cat, part, rev, stgfile)
  char  *cat;
  char  *part;
  char  *rev;
  char  *stgfile;
{
  int   status = PDM_S_SUCCESS;
  int   row = 0;
  int   cofile_col = 0;
  char  *filename = NULL;
  char  **data_row;
  MEMptr bufr = NULL;
  short found = FALSE;

  _pdm_debug("in the function PDUverify_storage_filename", 0);

  _pdm_debug("filename to verify is <%s>", stgfile);

  status = PDUget_storage_filename(cat, part, rev, "", &bufr, &filename);
  _pdm_status("PDUget_storage_filename", 0);
  if (status != PDM_S_SUCCESS)
    return(status);

  if ((!bufr) && (!filename))
    {
    _pdm_debug("bufr and filename are NULL", 0);
    return(PDM_E_INVALID_STG_FILENAME);
    }

  if ((filename) && (strcmp(filename, stgfile) == 0))
    return(PDM_S_SUCCESS);

  status = MEMbuild_array(bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
  status = PDM_S_SUCCESS;

  PDUsetup_buffer(bufr, ROW, &data_row);
  PDUget_buffer_col(bufr, "n_cofilename", &cofile_col);

  for (row = 0; row < bufr->rows; ++row)
     {
     if (strcmp(data_row[(bufr->columns * row) + cofile_col], stgfile) == 0)
       {
       found = TRUE;
       _pdm_debug("stgname was found in buffer", 0);
       }
     }
  
  if (found)
    return(PDM_S_SUCCESS);
  else
    return(PDM_E_INVALID_STG_FILENAME);
}

/* This function displays a return status on the EMS command strip and on the
   given form. */

void PDUdisplay_status(status, form)
  long  status;
  Form  form;
{
  char  *msg = NULL;

  msg = (char *)PDUtranslate_message(status);
  FIg_set_text(form,FI_MSG_FIELD,msg);

  if ((strlen(msg) < 57))
    PDUmessage(status, 's');
  else
    PDUmessage(PDM_E_CLEAR_FIELD, 's');

  return;
}

/* This function checks the write permission of a given attr */

int PDUcheck_attr_for_write_permission(attr_bufr, attr)
MEMptr attr_bufr;
char   *attr;
{

  int	status = PDM_S_SUCCESS;
  int	attr_row = -1;
  int   write_col = 0;
  char  write[3];
  char  **data_row;

  _pdm_debug("in the function PDUcheck_attr_for_write_permission", 0);

  write[0] = '\0';

  if (attr_bufr)
    {
    _pdm_debug("checking attr <%s> for write permission", attr);
    status = MEMbuild_array(attr_bufr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    status = PDUsetup_buffer(attr_bufr, ROW, &data_row);
    _pdm_status("PDUsetup_buffer", status);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(attr_bufr, "n_write", &write_col);
    _pdm_status("PDUget_buffer_col", status);
    if (status != PDM_S_SUCCESS)
      return(status);

    attr_row = -1;
    attr_row = PDUfind_attr_in_buffer(attr_bufr, attr);
    if (attr_row != -1)
      {
      strcpy(write, data_row[(attr_bufr->columns * attr_row)+write_col]);
      _pdm_debug("write = <%s>", write);
      }
    }

  if (strcmp(write, "Y") == 0)
    return(PDM_S_SUCCESS);
  else
    return(PDM_E_NOT_WRITABLE);
}

int PDUget_desc(cat, part, rev, desc)
char  *cat;
char  *part;
char  *rev;
char  **desc;
{
  int   status = PDM_S_SUCCESS;
  int   desc_col = 0;
  char  **data_row;
  extern void PDUdisplay_status();

  _pdm_debug("in the function PDUget_desc", 0);

  PDUdisplay_status(PDS_M_GET_PART_DESC, forms.rev_assy_form_id);

  status = PDMget_pt_desc(cat, part, rev);
  _pdm_status("PDMget_pt_desc", status);
  if (status != PDM_S_SUCCESS)
    return(PDM_E_RET_PARTTYPE_DESC);

  if ((!PDU_ret_bufr) || ((PDU_ret_bufr) && (PDU_ret_bufr->rows == 0)))
    return(PDM_E_RET_PARTTYPE_DESC);

  if (PDMdebug_on)
    MEMprint_buffer("PDU_ret_bufr", PDU_ret_bufr, PDU_DEBUG_FILE);

  status = MEMbuild_array(PDU_ret_bufr);
  _pdm_status("MEMbuild_array",status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
  status = PDM_S_SUCCESS;

  PDUsetup_buffer(PDU_ret_bufr, ROW, &data_row);

  PDUget_buffer_col(PDU_ret_bufr, "n_itemdesc", &desc_col);

  PDUfill_in_string(desc, data_row[(PDU_ret_bufr->columns * 0) + desc_col]);
  _pdm_debug("desc = <%s>", *desc);

  if (PDU_ret_bufr)
    {
    MEMclose(&PDU_ret_bufr);
    PDU_ret_bufr = NULL;
    }

  PDUdisplay_status(status, forms.rev_assy_form_id);

  return(status);
}

int act_part_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  switch ( g_label )
  {
  }

  return(1);
} /* END NOTIFICATION ROUTINE */

void PDUactive_part_form(catalog, partid, revision, desc, title)
  char  *catalog;
  char  *partid;
  char  *revision;
  char  *desc;
  char  *title;
{

  int   sts = PDM_S_SUCCESS;
  char  *in_msg = NULL;
  char  *out_msg = NULL;
  char  *add_msg = NULL;
  char  *copy_msg = NULL;
  char  *place_msg = NULL;
  char  *cancel_msg = NULL;
  char  *delete_msg = NULL;

  _pdm_debug("in the function PDUactive_part_form", 0);

  _pdm_debug("Creating active part form", 0);

  sts = FIf_new(ACTIVE_PART, "active_part", act_part_notification_routine,
                &forms.active_part_form_id);
  _pdm_status("FIf_new", sts);

  FIg_set_text(forms.active_part_form_id, ACT_CAT, catalog);
  FIg_set_text(forms.active_part_form_id, ACT_PART, partid);
  FIg_set_text(forms.active_part_form_id, ACT_REV, revision);
  FIg_set_text(forms.active_part_form_id, ACT_DESC, desc);

  in_msg = (char *)PDUtranslate_message(PDM_I_CHECKING_PART_IN);
  out_msg = (char *)PDUtranslate_message(PDM_I_CHECKING_PART_OUT);
  add_msg = (char *)PDUtranslate_message(PDM_I_ADDING_PART);
  copy_msg = (char *)PDUtranslate_message(PDM_I_COPYING_FILES);
  place_msg = (char *)PDUtranslate_message(PDM_I_PLACING_PART);
  cancel_msg = (char *)PDUtranslate_message(PDM_I_CANCELLING_CHECKOUT);
  delete_msg = (char *)PDUtranslate_message(PDM_I_DELETING_PART);
  if ((title) && (strcmp(title, in_msg) == 0))
    FIg_display(forms.active_part_form_id, IN_TEXT);
  else if ((title) && (strcmp(title, out_msg) == 0))
    FIg_display(forms.active_part_form_id, OUT_TEXT);
  else if ((title) && (strcmp(title, add_msg) == 0))
    FIg_display(forms.active_part_form_id, ADD_TEXT);
  else if ((title) && (strcmp(title, copy_msg) == 0))
    FIg_display(forms.active_part_form_id, COPY_TEXT);
  else if ((title) && (strcmp(title, place_msg) == 0))
    FIg_display(forms.active_part_form_id, PLACE_TEXT);
  else if ((title) && (strcmp(title, cancel_msg) == 0))
    FIg_display(forms.active_part_form_id, CANCEL_TEXT);
  else if ((title) && (strcmp(title, delete_msg) == 0))
    FIg_display(forms.active_part_form_id, DELETE_TEXT);

  if (in_msg) free(in_msg);
  if (out_msg) free(out_msg);
  if (add_msg) free(add_msg);
  if (place_msg) free(place_msg);
  if (copy_msg) free(copy_msg);
  if (cancel_msg) free(cancel_msg);
  if (delete_msg) free(delete_msg);

  FIf_display(forms.active_part_form_id);

  return;
}

int PDUcheck_if_parametric(catalog, parametric, exists)
char   *catalog;
short  *parametric;
short  *exists;
{
  int  status = PDM_S_SUCCESS;
  char type[5];

  _pdm_debug("in the function PDUcheck_if_parametric", 0);

  _pdm_debug("checking catalog type", 0);
  if (strlen(catalog))
    {
    status = PDMquery_catalog_type(catalog, type);
    _pdm_status("PDMquery_catalog_type", status);
    _pdm_debug("catalog type = <%s>", type);
    
    if ((strcmp(type, "P") == 0) ||
        (strcmp(type, "CID") == 0) ||
        (strcmp(type, "PXT") == 0) ||
        (strcmp(type, "EID") == 0))
      {
      _pdm_debug("catalog is parametric", 0);
      *parametric = TRUE;
      }
    }
  else
    {
    _pdm_debug("catalog has not been entered", 0);
    *parametric = FALSE;
    *exists = FALSE;
    }

  if (*parametric)
    _pdm_debug("returning catalog is parametric", 0);
  else
    _pdm_debug("returning catalog is not parametric", 0);

  if (*exists)
    _pdm_debug("returning parametric part already exists", 0);
  else
    _pdm_debug("returning parametric part does not exist", 0);

  return(PDM_S_SUCCESS);
}

int PDUcheck_cyclic_placement_for_rev_assy(act_row)
int   act_row;
{
  int    status = PDM_S_SUCCESS;
  Form   fp;
  MEMptr bufr = NULL;
  struct PDUrev_assy *save_list = NULL;
  extern void PDUdisplay_status();

  _pdm_debug("in the function PDUcheck_cyclic_placement_for_rev_assy", 0);

  fp = forms.rev_assy_form_id;

  save_list = PDU_assy_ptr;
  PDUfill_in_string(&refresh->act_catalog, save_list->new_catalog);
  PDUfill_in_string(&refresh->act_partid, save_list->new_partid);
  PDUfill_in_string(&refresh->act_revision, save_list->new_revision);

  _pdm_debug("PDU_incl_ASM = <%s>", PDU_incl_ASM);
  status = PDUis_cyclic_placement(current_rev_assy->new_catalog,
                                  current_rev_assy->new_partid,
                                  current_rev_assy->new_revision,
                                  &bufr);
  _pdm_status("PDUis_cyclic_placement", status);
  MEMclose(&bufr);
  bufr = NULL;
  
  if (status == 1)
    {
    PDUdisplay_status(PDM_E_CYCLIC_1STLEVEL, fp);
    FIfld_set_text(fp, REV_MCF, act_row, CAT_COL, NULL_STRING, FALSE);
    FIfld_set_text(fp, REV_MCF, act_row, PART_COL, NULL_STRING, FALSE);
    FIfld_set_text(fp, REV_MCF, act_row, REV_COL, NULL_STRING, FALSE);
    FIfld_set_text(fp, REV_MCF, act_row, DESC_COL, NULL_STRING, FALSE);
    FIfld_set_text(fp, REV_MCF, act_row, LOCFILE_COL, NULL_STRING, FALSE);
    FIfld_set_text(fp, REV_MCF, act_row, STGFILE_COL, NULL_STRING, FALSE);

    PDUfill_in_string(&(current_rev_assy)->new_catalog, NULL_STRING);
    PDUfill_in_string(&(current_rev_assy)->new_partid, NULL_STRING);
    PDUfill_in_string(&(current_rev_assy)->new_revision, NULL_STRING);
    PDUfill_in_string(&(current_rev_assy)->new_desc, NULL_STRING);
    PDUfill_in_string(&(current_rev_assy)->new_cofilename, NULL_STRING);
    PDUfill_in_string(&(current_rev_assy)->new_cifilename, NULL_STRING);
    }
  else
    status = PDM_S_SUCCESS;

  return(status);
}

int PDUfind_parent_in_mcf(act_row, level, parent_cat, parent_part, parent_rev,
                          parent_row, parent_level, childno, pchildno)
  int     act_row;
  int     level;
  char    **parent_cat;
  char    **parent_part;
  char    **parent_rev;
  int     *parent_row;
  int     *parent_level;
  int     *childno;
  int     *pchildno;
{
  Form    fp;
  int     row = 0;
  int     length = 0;
  int     select, pos;
  int     tmp_level = 0;
  static char *text = NULL;
  struct PDUrev_assy *temp_list = NULL;

  _pdm_debug("in the function PDUfind_parent_in_mcf", 0);

  fp = forms.rev_assy_form_id;

  _pdm_debug("searching backwards for parent part", 0);
  _pdm_debug("starting on row %d", (char *)act_row);
  for (row = act_row; row >= 0; --row)
     {
     FIfld_get_text_length(fp,REV_MCF,row,EXLEV_COL,&length);
     text = (char *)malloc(sizeof(char) * length + 1);
     memset(text,NULL,sizeof(char) * length + 1);
     FIfld_get_text(fp,REV_MCF,row,EXLEV_COL,length,
         (unsigned char *)text, &select, &pos);
     _pdm_debug("level on form = %s",text);

     if (!strlen(text))
       tmp_level = -1;
     else
       tmp_level = atoi(text);

     _pdm_debug("temp_level = %d", (char *)tmp_level);

     if (tmp_level == level - 1)
       {
       _pdm_debug("parent part found on row %d", row);

       _pdm_debug("find parent part in link list", 0);
       temp_list = current_rev_assy;
       current_rev_assy = PDU_assy_ptr;
     
       _pdm_debug("row = %d", (char *)row);
       while (current_rev_assy)
          {
          _pdm_debug("checking row %d", (char *) current_rev_assy->mcf_row);
          if (current_rev_assy->mcf_row == row)
            break;
          else
            current_rev_assy = current_rev_assy->next;
          }
       _pdm_debug("setting parent part information", 0);
       PDUfill_in_string(parent_cat, current_rev_assy->new_catalog);
       PDUfill_in_string(parent_part, current_rev_assy->new_partid);
       PDUfill_in_string(parent_rev, current_rev_assy->new_revision);
       *parent_row = current_rev_assy->mcf_row;
       *parent_level = current_rev_assy->ex_level;
       *childno = current_rev_assy->p_childno;
       *pchildno = current_rev_assy->p_pchildno;

       current_rev_assy = temp_list;

       break;
       }
     }

  return(PDM_S_SUCCESS);
}
