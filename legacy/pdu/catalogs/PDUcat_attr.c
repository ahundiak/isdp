#include <stdio.h>
#include <tools.h>
#include <FI.h>
#include <MEMerrordef.h>
#include <NFMdb.h>
#include <PDUstr.h>
#include <PDUcommand.h>
#include <PDUerror.h>
#include <PDUforms.h>
#include <PDUform_def.h>
#include <PDMmessage.h>
#include <PDMtypes.h>
#include <PDUfile_def.h>
#include <PDUproto.h>
#include <PDMproto.h>

/* Gadgets */

#define GROUP1        12
#define READ_TOG      27
#define READ_TEXT     31
#define WRITE_TOG     25
#define UPDATE_TOG    24
#define INPUT_TOG     28
#define GROUP2        29
#define COLATTR_GRP   30
#define MIN_VALUE     38
#define MAXIMUM_VALUE     39
#define ATTR_LIST     14
#define VALUE_LIST    21
#define GROUP4        43
#define STATDYN_GRP   45
#define DYNAMIC_ATTR  44
#define STATIC_ATTR   13
#define ADD_ATTR      46 
#define ATTRIBUTE_NAME 48 
#define ATTR_TEXT     49
#define DYN_ATTR_LIST 47  
#define ADD_ATTR_GRP  52 
#define LIST_GRP      57
#define RANGE_TOG     41
#define VALUE_TOG     55
#define FUNCTION_TOG  26
#define DATATYPE      54
#define RANGE_GRP     15
#define SYNONYM       22
#define DEFAULT_VAL   58
#define CHANGE_ATTR   62
#define TOG_GRP       67
#define DYN_TABLE     50
#define DYN_TABLE_ASSOC_GADGET 72
#define SYS_ATTR_TOG  73
#define MAX_TEXT      37
#define MIN_TEXT      36
#define FUNCTION_TEXT 51
#define DYN_TABLE_GRP 74

/* Externs */

extern char * calloc();
extern char * realloc();
extern int FIg_get_text_length();
extern int FIg_get_text();
extern int FIg_get_value();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();

/* Extern Global Variables */
extern int PDU_required_attr;
extern int PDU_parm_cat;
extern int PDU_view;
extern int PDU_list_cat;
extern struct PDUforms forms;
extern struct PDUrefresh *refresh;
extern int  PDU_cat_attr_create;
extern int  PDU_cat_attr_display;
extern int  PDU_value_pulldown;
extern int  PDM_debug_on;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_cat_func_bufr;
extern char *PDU_cat_description;

extern char *PDU_cat_atr ; /* global MEMptr to write user attribute information
                               in the notifcation routine */
extern char *PDU_cat_data ; /* global MEMptr to write user attribute defined
                               values in the notification routine */
extern char *PDU_cat_list ; /* global MEMptr to write user attribute defined 
                               list of values in the notification routine */
extern char *PDU_dyn_attr ; /* global MEMptr to write dynamic attributes in the
			       notification routine */
extern char *PDU_dyn_data ; /* global MEMptr to write dynamic attrobute defined
                               values in the notifcation routine */
extern char *PDU_dyn_list ; /* global MEMptr to write dynamic attribute defined 
                               list of values in the notifcation routine */
extern int PDU_command;
extern int PDU_view;
extern int PDM_debug_on;
extern Form PDU_form_id;
extern char *PDU_attr_name;
extern char *PDU_datatype;
extern char *PDU_default_value;
extern char *PDU_synonym;
extern char *PDU_dynamic_table;
extern char *PDU_value_list[605];

/* Global Variables */

extern char *min_value;
extern char *max_value;
extern char *order_no;
static int static_attr;
static int dynamic_attr;
static int range_list;
static int value_list;
static int func_sele;
static int mcf_label;
static short update_cat;
static short update_dyn;
extern MEMptr sort_attr;
extern MEMptr sort_data;

int cat_attr_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  static char   * text1;
  int             status;
  int             col;
  int             rows;
  int             position;
  int             mode;
  int             i;
  int             j;
  char            order_num[10];
  char            msgs[100];
  char		  *msg;
  char            spec_char;
  char            *search_str = NULL;
  static char	  temp_datatype[30];
  char		  temp_sysattr[30];
  MEMptr          cat_attr;
  MEMptr          cat_data;
  MEMptr          cat_list;
  MEMptr          dyn_attr;
  MEMptr          dyn_data;
  MEMptr          dyn_list;
  MEMptr          temp_attr = NULL;
  MEMptr          temp_data = NULL;
  MEMptr          temp_list = NULL;
  int             attr_row = -1;
  int             row_num;
  static int      active_row = 0;
  static int      act_pos = 0;
  double             max_num;
  double             min_num;
  int             list_row;
  int             state;
  int             state1;
  int             row;
  int             pos;
  int             select;
  int             length;

  /* set global buffers to the local buffers */
  cat_data = (MEMptr) PDU_cat_data;
  cat_attr = (MEMptr) PDU_cat_atr;
  cat_list = (MEMptr) PDU_cat_list;
  dyn_attr = (MEMptr) PDU_dyn_attr;
  dyn_data = (MEMptr) PDU_dyn_data;
  dyn_list = (MEMptr) PDU_dyn_list;

  PDUdismiss_subforms();

  switch ( g_label )
  {
    case ATTRIBUTE_NAME:
    
         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);

         FIfld_get_text_length(fp,ATTRIBUTE_NAME,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,ATTRIBUTE_NAME,0,0,length,(unsigned char *)text, 
                        &select, &pos);

         if ((text == NULL) || (strcmp(text, "") == 0))
           {
           if (PDU_attr_name)
             PDUfill_in_string(&PDU_attr_name, NULL);
           break;
           }

         /* verify the attribute is valid */
         if (mcf_label == ATTR_LIST)
           {
           MEMbuild_array(cat_attr);
           attr_row = PDUfind_attr_in_buffer(cat_attr, text);
           if (attr_row == -1)
             {
             status = PDUvalid_attr(text, "", msgs);
             _pdm_status("PDUvalid_attr(static)", status);
             }
           else
             {
             FIg_set_text(forms.cat_attr_form_id, ATTRIBUTE_NAME,"" ); 
            msg = (char *)PDUtranslate_message(PDM_E_ATTR_EXISTS);
            FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
            FIfld_pos_cursor(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, 0, 0, 0,
                            1, 1);
            break;
            }
           }
         else
           {
           if (PDU_dyn_attr)
             {
             status = PDUvalidate_dyn_attr_uniqueness(text, PDU_dyn_attr, msgs);
             _pdm_status("PDUvalid_dyn_attr_uniqueness", status);
             }
           else
             {
             status = PDUvalid_dynamic_attr(text, "", msgs);
             _pdm_status("PDUvalidate_dynamic_attr", status);
             }
           }
           if (status != PDM_S_SUCCESS)
             {
             _pdm_debug("Attribute <%s> is not valid", text);
             /* clear out attribute field and redisplay cursor at beginning */
             /*FIg_set_text(forms.cat_attr_form_id, ATTRIBUTE_NAME, ""); */
            FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msgs);
            FIfld_pos_cursor(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, 0, 0, 0,
                            1, 1);
            if (PDU_attr_name)
              PDUfill_in_string(&PDU_attr_name, NULL);
            break;
            }

         status = PDUcheck_for_reserved_words(text);
         if (status != PDM_S_SUCCESS)
             {
             /* clear out attribute field and redisplay cursor at beginning */
             /*FIg_set_text(forms.cat_attr_form_id, ATTRIBUTE_NAME, ""); */
            msg = (char *)PDUtranslate_message(PDM_E_RESERVED_ATTR);
            FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
            FIfld_pos_cursor(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, 0, 0, 0,
                            1, 1);
            if (PDU_attr_name)
              PDUfill_in_string(&PDU_attr_name, NULL);
            break;
            }

         status = PDUcheck_char(text, &spec_char);
         _pdm_status("PDUcheck_char", status);
         if (status != PDM_S_SUCCESS)
             {
             /* clear out attribute field and redisplay cursor at beginning */
             /*FIg_set_text(forms.cat_attr_form_id, ATTRIBUTE_NAME, ""); */
            search_str = (char *) malloc (sizeof (char) * 100);
            memset(search_str, NULL, 100);
         /*
          sprintf(search_str,"Attribute name cannot contain the character '%c'",
                    spec_char);
          */
            msg = (char *)PDUtranslate_message(PDM_E_INVALID_ATTR);
            FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
            free(search_str);
            FIfld_pos_cursor(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, 0, 0, 0,
                            1, 1);
            if (PDU_attr_name)
              PDUfill_in_string(&PDU_attr_name, NULL);
            break;
            }
         /* set sequence to PDU_datatype field */
          FIfld_pos_cursor(forms.cat_attr_form_id, DATATYPE, 0, 0, 0, 0,
                            1, 1);

         /* Code to process text string "text" */
         PDUfill_in_string(&PDU_attr_name, text);
    
         break;
        
    case DATATYPE:

         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);

         FIfld_get_text_length(fp,DATATYPE,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,DATATYPE,0,0,length,(unsigned char*)text,&select,
                        &pos);

         if ((text == NULL) || (strcmp(text, "") == 0))
           {
           if (PDU_datatype)
             PDUfill_in_string(&PDU_datatype, NULL);
           msg = (char *)PDUtranslate_message(PDM_E_INVALID_DATATYPE);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUcheck_if_datatype();
           break;
           }

         cat_attr = (MEMptr)PDU_cat_atr;
         dyn_attr = (MEMptr)PDU_dyn_attr;
         if ((static_attr) && (cat_attr) && (PDU_attr_name) && 
             (strcmp(PDU_attr_name, "") != 0))
           {
           MEMbuild_array(cat_attr);
           attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_attr_name);
           }
         else if ((dynamic_attr) && (dyn_attr) && (PDU_attr_name) && 
             (strcmp(PDU_attr_name, "") != 0))
           {
           MEMbuild_array(dyn_attr);
           attr_row = PDUfind_attr_in_buffer(dyn_attr, PDU_attr_name);
           }
         else 
           attr_row = -1;
         /* verify the attribute is valid */
         if ((PDU_datatype != NULL) && (strcmp(PDU_datatype, "") != 0) &&
             (attr_row != -1))
           {
             /* ALR if system attr check against value in temp_datatype */
            if (temp_datatype[0] != '\0')
             status = PDUvalid_datatype(text, temp_datatype, msgs);
            else
             status = PDUvalid_datatype(text, PDU_datatype, msgs);
           }
         else
           status = PDUvalid_datatype(text, "", msgs);
         _pdm_status("PDUvalid_datatype", status);

         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Datatype <%s> is not valid", text);
            /* ALR reset to old datatype if new one is invalid */
           if (PDU_datatype)
             FIg_set_text(forms.cat_attr_form_id, DATATYPE, PDU_datatype);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msgs);
           FIfld_pos_cursor(forms.cat_attr_form_id, DATATYPE, 0, 0, 0, 0, 1, 1);
           PDUcheck_if_datatype();
           break;
           }

        if ((PDU_default_value) && (strcmp(PDU_default_value, "") != 0))
         {
         /* verify the attribute is valid */
         status = PDUvalidate_value(PDU_default_value, text);
         _pdm_status("PDUvalidate_value", status);

         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Value <%s> is not valid", text);
           /* set field to "" and position cursor at the beginning */
           msg = (char *)PDUtranslate_message(PDM_E_INVALID_DEFAULT);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD,msg);
           }
         }

         /* set sequence to PDU_datatype field */
           FIfld_pos_cursor(forms.cat_attr_form_id, SYNONYM, 0, 0, 0, 0, 1, 1);
         /* Code to process text string "text" */
         PDUfill_in_string(&PDU_datatype, text);
    
         PDUcheck_if_datatype();
         break;

    case SYNONYM:

         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);

         /* Get the text string */
         FIfld_get_text_length(fp,SYNONYM,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,SYNONYM,0,0,length,(unsigned char*)text,&select,&pos);

         if ((text == NULL) || (strcmp(text, "") == 0))
           {
           if (PDU_synonym)
             PDUfill_in_string(&PDU_synonym, NULL);
           FIfld_pos_cursor(fp, DEFAULT_VAL, 0,0,0,0,1,1);
           break;
           }

/* SUN */
         else if ((PDU_synonym) && (strcmp(PDU_synonym,text) == 0))
           {
           FIfld_pos_cursor(fp, DEFAULT_VAL, 0,0,0,0,1,1);
           break;
           }

         /* verify the attribute is valid */
         status = PDUvalid_synonym(text, "", msgs);
         _pdm_status("PDUvalid_synonym", status);

         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Synonym <%s> is not valid", text);
           /* clear PDU_synonym field and position cursor at the begining */
           FIg_set_text(forms.cat_attr_form_id, SYNONYM, "");
           msg = (char *)PDUtranslate_message(PDM_E_SYNONYM_TOO_LONG);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           FIfld_pos_cursor(forms.cat_attr_form_id, SYNONYM, 0, 0, 0, 0, 1, 1);
           break;
           }

        /* verify synonym is unique */
        if ((dynamic_attr) && (dyn_attr))
          status = PDUvalidate_synonym_is_unique(text,dyn_attr);
        else if (static_attr)
          status = PDUvalidate_synonym_is_unique(text,cat_attr);
        else 
          status = PDM_S_SUCCESS;

         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Synonym <%s> is not valid", text);
           /* clear PDU_synonym field and position cursor at the begining */
           FIg_set_text(forms.cat_attr_form_id, SYNONYM, "");
           msg = (char *)PDUtranslate_message(PDM_E_SYNONYM_EXISTS);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD,msg); 
           FIfld_pos_cursor(forms.cat_attr_form_id, SYNONYM, 0, 0, 0, 0, 1, 1);
           break;
           }

         /* set sequence to PDU_datatype field */
        FIfld_pos_cursor(forms.cat_attr_form_id, DEFAULT_VAL, 0, 0, 0, 0, 1, 1);

         /* Code to process text string "text" */
         PDUfill_in_string(&PDU_synonym, text);
   
         break;

    case DEFAULT_VAL:

         /* Get the text string */
         FIfld_get_text_length(fp,DEFAULT_VAL,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,DEFAULT_VAL,0,0,length,(unsigned char *)text,&select,
                        &pos);

        if (strlen(text) > 40)
          {
           msg = (char *)PDUtranslate_message(PDM_E_DEFAULT_40_CHAR);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           FIg_set_text(forms.cat_attr_form_id, DEFAULT_VAL, "");
           if (PDU_default_value)
             PDUfill_in_string(&PDU_default_value,NULL);
           break;
           }

         if ((strcmp(PDU_attr_name, "p_parttype") == 0) && (PDU_parm_cat)) 
           {
           _pdm_debug("validate parttype is P, p, cid, or CID", 0);
           if ((strcmp(text, "P") == 0) || (strcmp(text, "p") == 0) || 
               (strcmp(text, "CID") == 0) || (strcmp(text, "cid") == 0))
             _pdm_debug("parttype for parametric catalog is valid", 0);
           else
           {
           _pdm_debug("Value <%s> is not valid", text);
           /* set field to "" and position cursor at the beginning */
           FIg_set_text(fp, DEFAULT_VAL, "P");
           msg = (char *)PDUtranslate_message(PDM_I_PARAM_PARTTYPE);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           PDUfill_in_string(&PDU_default_value, "P");
           break;
           }
           }
         else if (strcmp(PDU_attr_name, "p_parttype") == 0)
           {
           status = PDUvalid_part_type(text, NULL, msgs);
           _pdm_status("PDUvalid_part_type", status);
           if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Value <%s> is not valid", text);
           /* set field to "" and position cursor at the beginning */
           msg = (char *)PDUtranslate_message(PDM_I_STAND_PARTTYPE);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           if ((PDU_default_value) && (strcmp(PDU_default_value, "") != 0))
             PDUfill_in_string(&PDU_default_value, "");
           FIg_set_text(fp, DEFAULT_VAL, "");
           break;
           }
           }
         else if ((text == NULL) || (strcmp(text, "") == 0))
           {
           if (PDU_default_value)
             PDUfill_in_string(&PDU_default_value, NULL);
           break;
           }

         /* verify the attribute is valid */
         status = PDUvalidate_value(text, PDU_datatype);
         _pdm_status("PDUvalidate_value", status);

         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Value <%s> is not valid", text);
           /* set field to "" and position cursor at the beginning */
           FIg_set_text(fp, DEFAULT_VAL, "");
           msg = (char *)PDUtranslate_message(PDM_E_INVALID_DEFAULT);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           break;
           }

         if ((range_list) && (((min_value != NULL)  &&
             (strcmp(min_value, "") != 0)) || ((max_value != NULL) &&
             (strcmp(max_value, "") != 0))))
           {
           status = PDUvalidate_default_in_range(text, PDU_datatype);
           _pdm_status("PDUvalidate_default_in_range", status);
           if (status != PDM_S_SUCCESS)
             break;
          /* Code to process text */
          PDUfill_in_string(&PDU_default_value, text);
           }
         else if (value_list)
           {
           _pdm_debug("validate default_value against list", 0);
           FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &rows);
           if (rows != 0)
             {
             status = PDUvalidate_default_in_list(text);
             _pdm_status("PDU_validate_default_in_list",status);

             if (status != PDM_S_SUCCESS)
               break;
             else
               PDUfill_in_string(&PDU_default_value, text);
            }
          else
            PDUfill_in_string(&PDU_default_value,text);
           }
          else
            PDUfill_in_string(&PDU_default_value, text);

          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
   
         break;

    case DYN_TABLE:

         FIfld_get_text_length(forms.cat_attr_form_id,DYN_TABLE,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(forms.cat_attr_form_id,DYN_TABLE, 0, 0, length, 
                        (unsigned char *)text,
                        &select, &pos);

       PDUfill_in_string(&PDU_dynamic_table, text);
       PDUload_exec_structure("", "", "", "",text,"","",0, 0);

         status = PDMquery_dynamic_table_information(&temp_attr, &temp_data, 
                                                     &temp_list);
 
         _pdm_status("PDMquery_dynamic_table_information", status);
         if ( status != PDM_S_SUCCESS )
            {
            msg = (char *)PDUtranslate_message(PDM_E_TABLE_NOT_FOUND);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
            }

          if (PDM_debug_on)
            {
            MEMprint_buffer("dyn_attr", dyn_attr, PDU_DEBUG_FILE);
            MEMprint_buffer("dyn_data", dyn_data, PDU_DEBUG_FILE);
            }

        if ((temp_attr) && (temp_attr->rows > 0))
          {
          status = PDUfill_in_mcf(temp_attr, temp_data, DYN_ATTR_LIST);
          _pdm_status("PDUfill_in_mcf", status);
         }

          PDU_dyn_data = (char *)temp_data;
          PDU_dyn_attr = (char *)temp_attr;
          PDU_dyn_list = (char *)temp_list;
          break;

    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("f_label = <%d>", (char *)f_label);
         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         FIf_cvrt_to_perm_win(fp);
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("create_cat2");
         break;

    case FI_RESET:

         /* set dynamic table */
         FIg_set_text(forms.cat_attr_form_id, DYN_TABLE, PDU_dynamic_table);
         PDU_required_attr = FALSE;
         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         /* clear out fields */
         FIg_set_text(fp, ATTRIBUTE_NAME, "");
         FIfld_set_mode(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, FI_INSERT);
         FIg_display(fp, ATTRIBUTE_NAME);
         FIg_set_text(fp, DATATYPE, "");
         FIfld_set_mode(forms.cat_attr_form_id, DATATYPE, 0, FI_INSERT);
         FIg_display(fp, DATATYPE);
         FIg_set_text(fp, SYNONYM, "");
         FIg_set_text(fp, DEFAULT_VAL, "");
         FIfld_set_mode(forms.cat_attr_form_id, DEFAULT_VAL, 0, FI_INSERT);
         FIg_display(fp, DEFAULT_VAL);
         FIg_set_text(fp, MIN_VALUE, "");
         FIg_set_text(fp, MAXIMUM_VALUE, "");
         FIg_erase(fp, FUNCTION_TEXT);
         FIg_display(fp, MIN_TEXT);

         /* reset toggles */
         FIg_set_state_off(forms.cat_attr_form_id, READ_TOG);
         FIg_set_state_off(forms.cat_attr_form_id, WRITE_TOG);
         FIg_set_state_off(forms.cat_attr_form_id, UPDATE_TOG);
         FIg_set_state_on(forms.cat_attr_form_id, INPUT_TOG);
         
         /* clear out value list */
         FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &rows);
         if (rows != 0)
           {
           _pdm_debug("Blank out value list", 0);
           for (i = 0; i < rows; i++)
            FIfld_set_text(forms.cat_attr_form_id, VALUE_LIST, i, 0, "", 
                              FALSE);
          }

         FIg_erase(fp, VALUE_LIST);
          /* unselect row */
          FIfld_get_num_rows(forms.cat_attr_form_id, ATTR_LIST, &rows);
         for (i = 0; i < rows; i++)
           {
           for (j =0; j < 5; j ++)
             FIfld_set_select(fp, ATTR_LIST, i, j, FALSE);
            }

          FIfld_get_num_rows(forms.cat_attr_form_id, DYN_ATTR_LIST, &rows);
         for (i = 0; i < rows; i++)
           {
           for (j =0; j < 5; j ++)
             FIfld_set_select(fp, DYN_ATTR_LIST, i, j, FALSE);
           }

        if ((dyn_attr) && (dyn_attr->rows > 0))
          {
          status = PDUfill_in_mcf(dyn_attr, dyn_data, DYN_ATTR_LIST);
          _pdm_status("PDUfill_in_mcf", status);
         }

        if (mcf_label == DYN_ATTR_LIST)
        {
        FIg_erase(fp, DYN_ATTR_LIST);
        FIg_disable(fp, DYN_ATTR_LIST);
        FIg_display(fp, ATTR_LIST);
        }
  
        if (cat_attr->rows > 0)  
          {
        if (cat_attr->rows > 51)
          {
          if (sort_attr)
            MEMclose(&sort_attr);
          if (sort_data)
            MEMclose(&sort_data);
          status = PDUsort_by_order(cat_attr, cat_data, &sort_attr, &sort_data);
          _pdm_status("PDUsort_by_order", status);
          if (status != PDM_S_SUCCESS)
            status = PDUfill_in_mcf(cat_attr, cat_data, ATTR_LIST);
          else
            status = PDUfill_in_mcf(sort_attr, sort_data, ATTR_LIST);
          }
       else
         status = PDUfill_in_mcf(cat_attr, cat_data, ATTR_LIST);
         _pdm_status("PDUfill_in_mcf", status);
         }
  
        FIg_display(fp,ATTR_LIST);
          /* clean up */
          if (PDU_attr_name)
            PDUfill_in_string(&PDU_attr_name, NULL);
          if (PDU_synonym)
            PDUfill_in_string(&PDU_synonym, NULL);
          if (PDU_datatype)
            PDUfill_in_string(&PDU_datatype, NULL);
          if (max_value)
            PDUfill_in_string(&max_value, NULL);
          if (min_value)
            PDUfill_in_string(&min_value, NULL);
          if (PDU_default_value)
            PDUfill_in_string(&PDU_default_value, NULL);

          FIg_disable(fp, RANGE_GRP);
          FIg_disable(fp, RANGE_TOG);
          FIg_disable(fp, VALUE_TOG);
          FIg_disable(fp, VALUE_LIST);
          FIg_disable(fp, FUNCTION_TOG);
          FIg_disable(fp, CHANGE_ATTR);
          FIg_erase(fp, DYN_TABLE_GRP);
          if (PDU_view)
            FIg_erase(fp, ADD_ATTR_GRP);

          static_attr = TRUE;
          dynamic_attr = FALSE;
          mcf_label = ATTR_LIST;

          break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
          status = PDM_I_FORM_CANCEL;
          PDUmessage_trans(status, 's');

          /* clean up */
          if (PDU_attr_name)
            PDUfill_in_string(&PDU_attr_name, NULL);
          if (PDU_synonym)
            PDUfill_in_string(&PDU_synonym, NULL);
          if (PDU_datatype)
            PDUfill_in_string(&PDU_datatype, NULL);
          if (max_value)
            PDUfill_in_string(&max_value, NULL);
          if (min_value)
            PDUfill_in_string(&min_value, NULL);
          if (PDU_default_value)
            PDUfill_in_string(&PDU_default_value, NULL);  

         FIf_delete ( fp );

         if (cat_data)
           MEMclose(&cat_data);
         if (cat_attr)
           MEMclose(&cat_attr);
         if (cat_list)
           MEMclose(&cat_list);
         if (dyn_data)
           MEMclose(&dyn_data);
         if (dyn_attr)
           MEMclose(&dyn_attr);
         if (dyn_list)
           MEMclose(&dyn_list);
         if (sort_data)
           MEMclose(&sort_data);
         if (sort_attr)
           MEMclose(&sort_attr);

          if ((PDU_command == PDC_M_CREATE_CATALOG) && (refresh->rev_catalog) &&
              (strcmp(refresh->rev_catalog, "") != 0))
            PDUfill_in_string(&refresh->rev_catalog, NULL);

           status = PDUcatalog_name_form();

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         FIf_erase(fp);
 
          /* process multi-column forms */
          if (update_cat == TRUE)
            {
            cat_attr = (MEMptr)PDU_cat_atr;
            status = PDUupdate_attr_buffer(&cat_attr, ATTR_LIST);
            _pdm_status("PDUupdate_attr_buffer(cat_attr)", status);
            }
          if (update_dyn == TRUE)
            {
            dyn_attr = (MEMptr)PDU_dyn_attr;
            status = PDUupdate_attr_buffer(&dyn_attr, DYN_ATTR_LIST);
            _pdm_status("PDUupdate_attr_buffer(dyn_attr)", status);
            }

          /* clean up */
          if (PDU_attr_name) 
            PDUfill_in_string(&PDU_attr_name, NULL);
          if (PDU_synonym)
            PDUfill_in_string(&PDU_synonym, NULL);
          if (PDU_datatype)
            PDUfill_in_string(&PDU_datatype, NULL);
          if (max_value)
            PDUfill_in_string(&max_value, NULL);
          if (min_value)
            PDUfill_in_string(&min_value, NULL);
          if (PDU_default_value)
            PDUfill_in_string(&PDU_default_value, NULL);  

         if (sort_data)
           MEMclose(&sort_data);
         if (sort_attr)
           MEMclose(&sort_attr);
          
          FIf_delete(fp);

          if (PDM_debug_on)
            {
            MEMprint_buffer("cat_attr", cat_attr, PDU_DEBUG_FILE);
            MEMprint_buffer("dyn_attr", dyn_attr, PDU_DEBUG_FILE);
            }
          /* set new buffers to the global ones */
          PDU_cat_atr = (char *)cat_attr;
          PDU_cat_data = (char *)cat_data;
          PDU_cat_list = (char *)cat_list;
          PDU_dyn_data = (char *)dyn_data;
          PDU_dyn_attr = (char *)dyn_attr;
          PDU_dyn_list = (char *)dyn_list;

          refresh->command = PDU_command;
          status = PDUexternal();
          _pdm_status("PDUexternal", status);
          if (status != PDM_S_SUCCESS)
             {
             if (PDU_cat_description)
               PDUfill_in_string(&PDU_cat_description, NULL);
             PDUfill_in_string(&refresh->rev_catalog, NULL);
             }

        
          PDUmessage_trans(status, 's');
          PDUmessage(status, 's');
          PDUmessage(PDM_E_CLEAR_FIELD, 'c');
          
          if ((PDU_parm_cat) && (PDU_command != PDC_M_MODIFY_CATALOG) && 
              (status == PDM_S_SUCCESS))
            {
            status = PDUedit_macro_library();
            _pdm_status("PDUedit_macro_library", status);
            if (status != PDM_S_SUCCESS)
              PDUmessage(status, 's');
            }
          PDUcatalog_name_form();  
         break;

    case READ_TOG:     
         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         break;

    case WRITE_TOG:     
         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         FIg_get_state(fp, WRITE_TOG, &state);
         FIg_get_state(fp, UPDATE_TOG, &state1);
         if ((state == 1) && (state1 == 1) && (PDU_default_value == NULL))
           FIg_set_state_on(fp, INPUT_TOG);
         else if ((state == 1) && (state1 == 1) && 
                  (strcmp(PDU_default_value, "") == 0))
           FIg_set_state_on(fp, INPUT_TOG);

         break;

    case UPDATE_TOG:     
         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         FIg_get_state(fp, WRITE_TOG, &state);
         FIg_get_state(fp, UPDATE_TOG, &state1);
         if ((state == 1) && (state1 == 1) && (PDU_default_value == NULL))
           FIg_set_state_on(fp, INPUT_TOG);
         else if ((state == 1) && (state1 == 1) && 
                  (strcmp(PDU_default_value, "") == 0))
           FIg_set_state_on(fp, INPUT_TOG);
         break;

    case INPUT_TOG:     
         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         FIg_get_state(fp, WRITE_TOG, &state);
         FIg_get_state(fp, UPDATE_TOG, &state1);
         if ((state == 1) && (state1 == 1))
           {
           FIg_get_state(fp, INPUT_TOG, &state);
           if ((state == 0) && (PDU_default_value == NULL))
             {
             FIg_set_state_on(fp, INPUT_TOG);
             msg = (char *)PDUtranslate_message(PDM_I_ATTR_REQ);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             }
           else if ((state == 0) && (strcmp(PDU_default_value, "") == 0))
             {
             FIg_set_state_on(fp, INPUT_TOG);
             msg = (char *)PDUtranslate_message(PDM_I_ATTR_REQ);
             FIg_set_text(fp, FI_MSG_FIELD,msg);
             }
           }

         break;

    case MIN_VALUE:         /* Field Type:    INTEGER    */

         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);

          /* Get the text of the field */
         FIfld_get_text_length(fp,MIN_VALUE,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,MIN_VALUE,0,0,length,(unsigned char *)text,&select,
                        &pos);
           
          if ((text == NULL) || (strcmp(text, "") == 0))
            {
            if (min_value)
              PDUfill_in_string(&min_value, NULL);
             break;
             }

          FIg_get_state(fp, FUNCTION_TOG, &state);
          if (state == 1)
            {
            /* validate function name */
            status = PDUvalidate_function(text);
            _pdm_status("PDUvalidate_function", status);

            if (status != PDM_S_SUCCESS)
              {
              msg = (char *)PDUtranslate_message(PDM_E_FUNCTION_NAME);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              FIg_set_text(fp, MIN_VALUE, "");
              if ((min_value) && (strcmp(min_value, "") != 0))
                PDUfill_in_string(&min_value, NULL);
              break;
              }
           
            /* validate file is local */
            status = PDUverify_file(text);
           _pdm_status("PDUverify_file", status);

            if (status != PDM_S_SUCCESS)
              {
              msg = (char *)PDUtranslate_message(PDM_E_FUNCTION_EXISTS);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              FIg_set_text(fp, MIN_VALUE, "");
              if ((min_value) && (strcmp(min_value, "") != 0))
                PDUfill_in_string(&min_value, NULL);
              break;
              }
           
            break;
            }

          if ((max_value) && (strcmp(max_value, "") != 0))
            {
            sscanf(max_value, "%lf", &max_num);
            sscanf(text, "%lf", &min_num);
            if (min_num > max_num)
              {
              msg = (char *)PDUtranslate_message(PDM_E_MIN_MAX);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              FIg_set_text(fp, MIN_VALUE, "");
              if ((min_value) && (strcmp(min_value, "") != 0))
                PDUfill_in_string(&min_value, NULL);
              break;
              }
            }
         /* verify the attribute is valid */
         if ((PDU_datatype) && (strcmp(PDU_datatype, "") != 0))
         {
         status = PDUvalidate_value(text, PDU_datatype);
         _pdm_status("PDUvalidate_value", status);

         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Value <%s> is not valid", text);
           /* set field to "" and position cursor at the beginning */
           FIg_set_text(fp, MIN_VALUE, "");
           msg = (char *)PDUtranslate_message(PDM_E_INVALID_MIN_VALUE);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD,msg);
           if ((min_value) && (strcmp(min_value, "") != 0))
             PDUfill_in_string(&min_value, NULL);
           break;
           }
         }
 
          /* Code to process text */
          PDUfill_in_string(&min_value, text);

         _pdm_debug("Setting cursor in MAXIMUM_VALUE FIELD", 0);
         break;

    case MAXIMUM_VALUE:         /* Field Type:    INTEGER    */

         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
          /* get text from field */ 
         FIfld_get_text_length(fp,MAXIMUM_VALUE,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,MAXIMUM_VALUE,0,0,length,(unsigned char*)text,
                        &select,&pos);
 
          if ((text == NULL) || (strcmp(text, "") == 0))
            {
            if ((max_value) && (strcmp(max_value, "") != 0))
              PDUfill_in_string(&max_value, NULL);
            break;
            } 
            
          if ((min_value != NULL)  && (strcmp(min_value, "") != 0))
            {
            sscanf(min_value, "%lf", &min_num);
            sscanf(text, "%lf", &max_num);
            if (min_num > max_num)
            {
            msg = (char *)PDUtranslate_message(PDM_E_MAX_MIN);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            FIg_set_text(fp, MAXIMUM_VALUE, "");
            if (max_value)
              PDUfill_in_string(&max_value, NULL);
            break;
            }
           }

         /* verify the attribute is valid */
         if ((PDU_datatype) && (strcmp(PDU_datatype, "") != 0))
         {
         status = PDUvalidate_value(text, PDU_datatype);
         _pdm_status("PDUvalidate_value", status);

         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Value <%s> is not valid", text);
           /* set field to "" and position cursor at the beginning */
           FIg_set_text(fp, MAXIMUM_VALUE, "");
           msg = (char *)PDUtranslate_message(PDM_E_INVALID_MAX_VALUE);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           if ((max_value) && (strcmp(max_value, "") != 0))
             PDUfill_in_string(&max_value, NULL);
           break;
           }
         }
          /* Code to process text */
          PDUfill_in_string(&max_value, text);

         break;

    case DYN_ATTR_LIST:

         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
          /* Get the text string */
         FImcf_get_active_col(forms.cat_attr_form_id, DYN_ATTR_LIST,
                              &col, &position);
         FIfld_get_active_row(forms.cat_attr_form_id, DYN_ATTR_LIST, &row,
                                 &position);
         FIfld_get_text_length(fp,DYN_ATTR_LIST,row,col,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,DYN_ATTR_LIST,row,col,length,(unsigned char*)text,
                        &select,&pos);

           _pdm_debug("col = %d", (char *)col);
           if (col == 0)
             {
             /* reorder attributes to new sequences */
             if (text == NULL)
               break;
             else if (strcmp(text, "") == 0)
               break;
             update_dyn = TRUE;
             sscanf(text,"%d", &row_num);
             if (row_num == 1)
               row_num = row_num - 1;
             else
               row_num = row_num - 2;
             PDUfill_in_string(&order_no, text);
             for (i = 1; i < 5; i ++)
                {
              FImcf_set_active_col(forms.cat_attr_form_id, DYN_ATTR_LIST, i, i);

              FIfld_get_text_length(fp,DYN_ATTR_LIST,row,i,&length);
              text = (char *) malloc (sizeof (char) * length + 1);
              memset(text, NULL, sizeof (char) * length + 1);
              FIfld_get_text(fp,DYN_ATTR_LIST,row,i,length,(unsigned char*)text,
                             &select,&pos);

                if ( i == 1)
                  PDUfill_in_string(&PDU_attr_name, text);
                else if (i == 2)
                  PDUfill_in_string(&PDU_datatype, text);
                else if ( i == 3)
                  PDUfill_in_string(&PDU_synonym,text);
                else
                  PDUfill_in_string(&PDU_default_value, text);
                }
             FImcf_set_active_col(forms.cat_attr_form_id, DYN_ATTR_LIST, 0, 0);
             FIfld_get_active_row(fp, DYN_ATTR_LIST, &rows,
                                       &position);
             FIfld_delete_rows(fp, DYN_ATTR_LIST, rows, 1);
             FIfld_insert_blank_row(forms.cat_attr_form_id, DYN_ATTR_LIST, 
                                    row_num );
             FIfld_set_text(forms.cat_attr_form_id, DYN_ATTR_LIST, row_num ,0, 
                        order_no, FALSE);
             FIfld_set_text(forms.cat_attr_form_id, DYN_ATTR_LIST, row_num ,1, 
                        PDU_attr_name, FALSE);
             FIfld_set_text(forms.cat_attr_form_id, DYN_ATTR_LIST, row_num ,2, 
                        PDU_datatype, FALSE);
             FIfld_set_text(forms.cat_attr_form_id, DYN_ATTR_LIST, row_num ,3, 
                        PDU_synonym, FALSE);
             FIfld_set_text(forms.cat_attr_form_id, DYN_ATTR_LIST, row_num ,4, 
                        PDU_default_value, FALSE);
             
             FIfld_get_num_rows(forms.cat_attr_form_id, DYN_ATTR_LIST, &rows);
             /*for (i = (row_num + 1); i < rows; i ++)
                {
                sprintf(order_num, "%d", i);
                FIfld_set_text(forms.cat_attr_form_id, DYN_ATTR_LIST, i, 0, 
                               order_num, FALSE);
                }*/
             for (i = 0; i < rows; i ++)
                {
                sprintf(order_num, "%d", (i + 2));
                FIfld_set_text(forms.cat_attr_form_id, DYN_ATTR_LIST, i, 0, 
                               order_num, FALSE);
                }
             /*PDUfill_in_string(&PDU_default_value, NULL);
             PDUfill_in_string(&PDU_datatype, NULL);
             PDUfill_in_string(&PDU_synonym, NULL);
             PDUfill_in_string(&PDU_attr_name, NULL);*/
             }
            else
              {
              /* save active row */
              FIfld_get_active_row(fp, DYN_ATTR_LIST, &active_row, &act_pos);

              status = PDUupdate_attr_form(dyn_attr, dyn_data, dyn_list,
                                           DYN_ATTR_LIST);
              _pdm_status("PDUupdate_attr_form(DYN_ATTR_LIST)", status);
              if (status == PDM_E_BAD_ATTRIBUTE)
                {
                PDUfill_in_string(&PDU_attr_name, NULL);
                break;
                }
              else if (status != PDM_S_SUCCESS)
                {
                PDUmessage(status, 's'); 
                break;
                }
              status = PDUcheck_for_function(PDU_attr_name, &min_value, PDU_cat_func_bufr);
              _pdm_status("PDUcheck_for_function", status);

              if (status == PDM_S_SUCCESS)
                {
                func_sele = TRUE;
                range_list = FALSE;
                value_list = FALSE;
                FIg_erase(fp, RANGE_GRP);
                FIg_display(fp, MIN_VALUE);
                FIg_display(fp, FUNCTION_TEXT);
                FIg_erase(fp, MIN_TEXT);
                FIg_set_state_on(fp, FUNCTION_TOG);
                FIg_set_state_off(fp, RANGE_TOG);
                FIg_set_state_off(fp, VALUE_TOG);
                FIg_erase(fp, VALUE_LIST);
                FIg_set_text(fp, MIN_VALUE, min_value);
                PDUfill_in_string(&min_value, NULL);
                }
              else
                func_sele = FALSE;

              /* enable change attribute button */
              FIg_enable(fp, CHANGE_ATTR);
              FIg_disable(fp, ADD_ATTR);
              FIfld_set_mode(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, 
                             FI_REVIEW);
              FIg_display(forms.cat_attr_form_id, ATTRIBUTE_NAME);
              if ((strncmp(PDU_datatype, "char", 4) != 0) && 
                  (strncmp(PDU_datatype, "Char", 4) != 0))
                {
                FIfld_set_mode(forms.cat_attr_form_id, DATATYPE, 0, FI_REVIEW);
                FIg_display(forms.cat_attr_form_id, DATATYPE);
                }
              else
                {
                FIfld_set_mode(forms.cat_attr_form_id, DATATYPE, 0, FI_INSERT);
                FIg_display(forms.cat_attr_form_id, DATATYPE);
                }
              }
              
          PDUcheck_if_datatype();
          break;

    case ATTR_LIST:     /* Sequenced to     */

          FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);

          /* Code to process text string "text" */
           FImcf_get_active_col(forms.cat_attr_form_id,ATTR_LIST, &col,
                                         &position);
           
           FIfld_get_active_row(forms.cat_attr_form_id, ATTR_LIST, &row,
                                 &position);

           FIfld_get_text_length(fp,ATTR_LIST,row,col,&length);
           text = (char *) malloc (sizeof (char) * length + 1);
           memset(text, NULL, sizeof (char) * length + 1);
           FIfld_get_text(fp,ATTR_LIST,row,col,length,(unsigned char*)text, 
                          &select, &pos);

          /* ALR:  Save orig datatype */
           FIfld_get_text_length(fp,ATTR_LIST,row,1,&length);
           FIfld_get_text(fp,ATTR_LIST,row,1,length,
                          (unsigned char *)temp_sysattr,&select,&pos);
           if ((strncmp(temp_sysattr,"n_",2) == 0) ||
               (strncmp(temp_sysattr,"p_",2) == 0))
           {
             FIfld_get_text_length(fp,ATTR_LIST,row,2,&length);
             FIfld_get_text(fp,ATTR_LIST,row,2,length,
                            (unsigned char *)temp_datatype,&select,&pos);
            }
            else
             temp_datatype[0] = '\0';

           _pdm_debug("col = %d", (char *)col);
           if (col == 0)
             {
             /* reorder attribute sequences */
             if (text == NULL)
               break;
             else if (strcmp(text, "") == 0)
               break;
             update_cat = TRUE;
             sscanf(text,"%d", &row_num);
             FIfld_get_num_rows(forms.cat_attr_form_id, ATTR_LIST, &rows);
             if ((row_num > rows) && (PDU_required_attr))
               {
               msg = (char *)PDUtranslate_message(PDM_I_ORDER_EXCEEDS_ATTR);
               FIg_set_text(fp, FI_MSG_FIELD, msg);
               break;
               }
             else if ((row_num > cat_attr->rows) && (!PDU_required_attr))
               {
               msg = (char *)PDUtranslate_message(PDM_I_ORDER_EXCEEDS_ATTR);
               FIg_set_text(fp, FI_MSG_FIELD, msg);
               break;
               }
             else if (!PDU_required_attr)
                break;
             row_num = row_num - 1;
             PDUfill_in_string(&order_no, text);
             for (i = 1; i < 5; i ++)
                {
                FImcf_set_active_col(forms.cat_attr_form_id, ATTR_LIST, i, i);
  
                FIfld_get_text_length(fp,ATTR_LIST,row,i,&length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp,ATTR_LIST,row,i,length,(unsigned char*)text,
                               &select,&pos);

                if ( i == 1)
                  PDUfill_in_string(&PDU_attr_name, text);
                else if (i == 2)
                  PDUfill_in_string(&PDU_datatype, text);
                else if ( i == 3)
                  PDUfill_in_string(&PDU_synonym,text);
                else
                  PDUfill_in_string(&PDU_default_value, text);
                }
             FImcf_set_active_col(forms.cat_attr_form_id, ATTR_LIST, 0, 0);
             FIfld_get_active_row(forms.cat_attr_form_id, ATTR_LIST, &rows,
                                       &position);
             FIfld_delete_rows(forms.cat_attr_form_id, ATTR_LIST, rows, 1);
             FIfld_insert_blank_row(forms.cat_attr_form_id, ATTR_LIST, 
                                    row_num);
             FIfld_set_text(forms.cat_attr_form_id, ATTR_LIST, row_num ,0, 
                        order_no, FALSE);
             FIfld_set_text(forms.cat_attr_form_id, ATTR_LIST, row_num ,1, 
                        PDU_attr_name, FALSE);
             FIfld_set_text(forms.cat_attr_form_id, ATTR_LIST, row_num ,2, 
                        PDU_datatype, FALSE);
             FIfld_set_text(forms.cat_attr_form_id, ATTR_LIST, row_num ,3, 
                        PDU_synonym, FALSE);
             FIfld_set_text(forms.cat_attr_form_id, ATTR_LIST, row_num ,4, 
                        PDU_default_value, FALSE);
             
             FIfld_get_num_rows(forms.cat_attr_form_id, ATTR_LIST, &rows);
             for (i = 0; i < rows; i ++)
                {
                sprintf(order_num, "%d", (i + 1));
                FIfld_set_text(forms.cat_attr_form_id, ATTR_LIST, i, 0, 
                               order_num, FALSE);
                }
             /*PDUfill_in_string(&PDU_default_value, NULL);
             PDUfill_in_string(&PDU_datatype, NULL);
             PDUfill_in_string(&PDU_synonym, NULL);
             PDUfill_in_string(&PDU_attr_name, NULL);*/

             /*FIfld_get_num_rows(fp, ATTR_LIST, &rows);*/
             FIfld_set_active_row(fp, ATTR_LIST, (rows - 1), (rows - 1));
             FIfld_pos_cursor(forms.cat_attr_form_id, ATTRIBUTE_NAME,(rows - 1),
                              (rows - 1), 3, 3, 1, 1);
             FIf_display(fp);
             }
            else
              {
              /* save active row for later */
              FIfld_get_active_row(fp, ATTR_LIST, &active_row, &act_pos);

              status = PDUupdate_attr_form(cat_attr, cat_data, cat_list,
                                           ATTR_LIST);
              _pdm_status("PDUupdate_attr_form(ATTR_LIST)", status);
              if (status == PDM_E_BAD_ATTRIBUTE)
                {
                PDUfill_in_string(&PDU_attr_name, NULL);
                break;
                }
              else if (status != PDM_S_SUCCESS)
                {
                PDUmessage(status, 's'); 
                break;
                }
              status = PDUcheck_for_function(PDU_attr_name, &min_value, PDU_cat_func_bufr);
              _pdm_status("PDUcheck_for_function", status);

              if (status == PDM_S_SUCCESS)
                {
                func_sele = TRUE;
                range_list = FALSE;
                value_list = FALSE;
                FIg_erase(fp, RANGE_GRP);
                FIg_enable(fp, MIN_VALUE);
                FIg_display(fp, MIN_VALUE);
                FIg_display(fp, FUNCTION_TEXT);
                FIg_set_text(fp, MIN_VALUE,min_value);
                FIg_erase(fp, MIN_TEXT);
                FIg_set_state_on(fp, FUNCTION_TOG);
                FIg_set_state_off(fp, RANGE_TOG);
                FIg_set_state_off(fp, VALUE_TOG);
                FIg_erase(fp, VALUE_LIST);
                PDUfill_in_string(&min_value, NULL);
                }
              else
                func_sele = FALSE;
              /* enable change attribute */
              FIg_enable(fp, CHANGE_ATTR);
              FIg_disable(fp, ADD_ATTR);

              FIfld_set_mode(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, 
                             FI_REVIEW);
              FIg_display(forms.cat_attr_form_id, ATTRIBUTE_NAME);

              if (PDU_command == PDC_M_MODIFY_CATALOG)
                {
                _pdm_debug("check and see if attribute existed before", 0);
                status = PDUcheck_if_attribute_already_created();
                
                if (status == TRUE)
                  {
                 FIfld_set_mode(forms.cat_attr_form_id, DATATYPE, 0, FI_REVIEW);
                 FIg_display(forms.cat_attr_form_id, DATATYPE);
                  }
                else
                  {
                 FIfld_set_mode(forms.cat_attr_form_id, DATATYPE, 0, FI_INSERT);
                 FIg_display(forms.cat_attr_form_id, DATATYPE);
                  }
               }
              else if ((strncmp(PDU_datatype, "char", 4) != 0) && 
                       (strncmp(PDU_datatype, "Char", 4) != 0))
                {
                FIfld_set_mode(forms.cat_attr_form_id, DATATYPE, 0, FI_REVIEW);
                FIg_display(forms.cat_attr_form_id, DATATYPE);
                }
              else
                {
                status = PDUcheck_if_change_datatype(PDU_attr_name);
                _pdm_status("PDUcheck_if_change_datatype", status);
                if (status == PDM_S_SUCCESS)
                 FIfld_set_mode(forms.cat_attr_form_id, DATATYPE, 0, FI_INSERT);
                else
                 FIfld_set_mode(forms.cat_attr_form_id, DATATYPE, 0, FI_REVIEW);
                FIg_display(forms.cat_attr_form_id, DATATYPE);
                }
              }

          PDUcheck_if_datatype();
          break;

    case VALUE_LIST:     /* Sequenced to     */

         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         FIfld_get_active_row(forms.cat_attr_form_id, VALUE_LIST, &row,
                                 &position);
          /* Get the text string */

         FIfld_get_text_length(fp,VALUE_LIST,row,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,VALUE_LIST,row,0,length,(unsigned char*)text,&select,&pos);

          if (text == NULL)
            break;
          else if (strcmp(text, "") == 0)
            break;

           FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &rows);
          if (rows > 600)
            {
            FIfld_set_max_num_rows(fp, VALUE_LIST, 600);
            msg = (char *)PDUtranslate_message(PDM_I_MAX_600_VALUES);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            FIfld_get_active_row(fp, VALUE_LIST, &row, &pos);
            FIfld_set_text(fp, VALUE_LIST, row, 0, "", FALSE);
            break;
            }
            
          /* Code to process text string "text" */
          /* all values wil be processed at add or change attribute time */
          if ((PDU_datatype) && (strcmp(PDU_datatype, "") != 0))
            {
         /* verify the attribute is valid */
         status = PDUvalidate_value(text, PDU_datatype);
         _pdm_status("PDUvalidate_value", status);

         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Value <%s> is not valid", text);
           /* set field to "" and position cursor at the beginning */
           msg = (char *)PDUtranslate_message(PDM_E_BAD_DATA);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD,msg);
           FIfld_get_active_row(fp, VALUE_LIST, &row, &pos);
           FIfld_set_text(fp, VALUE_LIST, row, 0, "", FALSE);
           break;
           }
          }
         
        for (i = 0; i < (rows -1); i ++)
          {
          if (i == row)
            continue;
          FIfld_get_text_length(fp,VALUE_LIST,i,0,&length);
          text1 = (char *) malloc (sizeof (char) * length + 1);
          memset(text1, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp,VALUE_LIST,i,0,length,(unsigned char*)text1,
          &select,&pos);
          if (strcmp(text, text1) == 0)
            {
            msg = (char *)PDUtranslate_message(PDM_E_BAD_DATA);
            FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD,msg);
            FIfld_get_active_row(fp, VALUE_LIST, &row, &pos);
            FIfld_set_text(fp, VALUE_LIST, row, 0, "", FALSE);
            break;
            }
          }
            

         break;

    /*case DELETE_ATTR:     */

         /* delete attribute from buffer */
         /*if (static_attr == TRUE)
           mcf_label = ATTR_LIST;
         else 

           mcf_label = DYN_ATTR_LIST;*/

         /* get attribute for deletion */
         /*status = FImcf_set_active_col(forms.cat_attr_form_id,mcf_label,1, 1);
       
         if (status != FI_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         FIfld_get_text_length(fp,mcf_label,0,1,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,mcf_label,0,1,length,(unsigned char*)text,&select,
                        &pos);

       
         if (status != FI_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }*/

         /* verify attribute is not a required attribute */

         /*status = PDUvalid_attr(text, "", msg);
         _pdm_debug("Text is <%s>", text);
         _pdm_status("PDUvalid_attr(delete)" , status);

         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Required attribute <%s> cannot be deleted", text);
           PDUmessage(status, 's');
           break;
           }

         if (mcf_label == ATTR_LIST)
           {
           status = PDUdelete_attribute(text, &cat_attr, &cat_data);
           _pdm_status("PDUdelete_attribute(static)", status);
           }
         else
           {
           status = PDUdelete_attribute(text, &dyn_attr, &dyn_data);
           _pdm_status("PDUdelete_attribute(dynamic)", status);
           }
           
          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            break;
            }

         if (mcf_label == ATTR_LIST)
           {
           _pdm_debug("Set static buffers to global variables", 0);
           PDU_cat_atr = (char *) cat_attr;
           PDU_cat_data = (char *) cat_data;
           }
         else
           {
           _pdm_debug("Set dynamic buffers to global variables", 0);
           PDU_dyn_attr = (char *) dyn_attr;
           PDU_dyn_data = (char *) dyn_data;
           }
          
         status = FIfld_get_active_row(forms.cat_attr_form_id, mcf_label, &rows,
                                       &position);

         if (status != FI_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         status = FIfld_delete_rows(forms.cat_attr_form_id, mcf_label, rows, 1);

         if (status != FI_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         break;*/

    case ADD_ATTR:
         
         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         /* get mode of attribute name field */
        _pdm_debug("Before checking mode", 0);
         status = FIfld_get_mode(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, 
                                 &mode);
         if (status != FI_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_ATTR_MODE);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           break;
           }

         if (mode == FI_REVIEW)
           {
           msg = (char *)PDUtranslate_message(PDM_E_ATTR_EXISTS);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           break;
           }

         /* add attribute to buffer */
        _pdm_debug("Before checking attribute name", 0);
         if ((PDU_attr_name == NULL) || (strcmp(PDU_attr_name, "") == 0))
           {
           msg = (char *)PDUtranslate_message(PDM_E_ATTR_NOT_FOUND);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           break;
           }

        _pdm_debug("Before checking datatype", 0);
         if ((PDU_datatype == NULL) || (strcmp(PDU_datatype, "") == 0))
           {
           msg = (char *)PDUtranslate_message(PDM_E_DATATYPE);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           break;
           }

        _pdm_debug("Before validateing value", 0);
        if ((PDU_default_value) && (strcmp(PDU_default_value, "") != 0))
         {
         /* verify the attribute is valid */
         status = PDUvalidate_value(PDU_default_value, PDU_datatype);
         _pdm_status("PDUvalidate_value", status);

         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Value <%s> is not valid", text);
           /* set field to "" and position cursor at the beginning */
           msg = (char *)PDUtranslate_message(PDM_E_INVALID_DEFAULT);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD,msg);
           break;
           }
         }

        _pdm_debug("Before validateing value in range or list", 0);
         if (((PDU_default_value != NULL) && 
              (strcmp(PDU_default_value, "") != 0)) && (range_list) &&
             (((min_value != NULL) && (strcmp(min_value, "") != 0)) || 
              ((max_value != NULL) && (strcmp(max_value, "") != 0))))
           {
           status = PDUvalidate_default_in_range(PDU_default_value, PDU_datatype);
           _pdm_status("PDUvalidate_default_in_range", status);
           if (status != PDM_S_SUCCESS)
             break;
           }
         else if (((PDU_default_value != NULL) && 
                   (strcmp(PDU_default_value, "") != 0)) && (value_list))
           {
           _pdm_debug("validate default_value against list", 0);
           FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &rows);
           if (rows != 0)
             {
             status = PDUvalidate_default_in_list(PDU_default_value);
             _pdm_status("PDU_validate_default_in_list",status);

             if (status != PDM_S_SUCCESS)
               break;
             }
           }
        _pdm_debug("Before setting num of rows", 0);
         FIfld_get_max_num_rows(fp, mcf_label, &rows);
         FIfld_set_max_num_rows(fp, mcf_label, (rows + 1));
         /* add attribute info to the current buffer */
         if (mcf_label == ATTR_LIST)
           {
           _pdm_debug("Attribute label = ATTTR_LIST",0);
           status = PDUadd_attribute(&cat_attr,&cat_data, &cat_list);
           _pdm_status("PDUadd_attribute", status);
           if (status != PDM_S_SUCCESS)
            {
            msg = (char *)PDUtranslate_message(PDM_E_ADD_ATTR);
            FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
            PDUmessage(PDM_E_CLEAR_FIELD, 's');
            break;
            }
          else
            PDUmessage(status, 's');
             if (PDM_debug_on)
               {
               MEMprint_buffer("cat_attr", cat_attr, PDU_DEBUG_FILE);
               MEMprint_buffer("cat_data", cat_data, PDU_DEBUG_FILE);
               MEMprint_buffers("cat_list", cat_list, PDU_DEBUG_FILE);
               }
           } 
         else
           {
            status = PDUadd_attribute(&dyn_attr, &dyn_data,&dyn_list);
            _pdm_status("PDUadd_attribute", status);
           if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_ADD_ATTR);
             FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
            PDUmessage(PDM_E_CLEAR_FIELD, 's');
             break;
             }
            else
              PDUmessage(status, 's');
             if (PDM_debug_on)
               {
               MEMprint_buffer("dyn_attr", dyn_attr, PDU_DEBUG_FILE);
               MEMprint_buffer("dyn_data", dyn_data, PDU_DEBUG_FILE);
               MEMprint_buffers("dyn_list", dyn_list, PDU_DEBUG_FILE);
               }
            } 
        
        /* get number of rows of the mcf */
        FIg_reset(fp, VALUE_LIST);
        status = FIfld_get_num_rows(forms.cat_attr_form_id, mcf_label, &rows);
        if (status != FI_SUCCESS)
          {
          msg = (char *)PDUtranslate_message(PDM_E_ADD_ATTR_LIST);
          FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
          break;
          }

         if (rows == 1)
           {
           /* see if the first row is null */
           /*FIfld_set_active_row(forms.cat_attr_form_id, mcf_label, rows, rows);*/

           FIfld_get_text_length(fp,mcf_label,(rows - 1),1,&length);
           text = (char *) malloc (sizeof (char) * length + 1);
           memset(text, NULL, sizeof (char) * length + 1);
           FIfld_get_text(fp,mcf_label,(rows - 1),1,length,(unsigned char*)text,
                          &select,&pos);

           if ((text == NULL) || (strcmp(text, "") == 0))
             rows = rows - 1;
           FIfld_set_num_rows(fp, mcf_label, (rows + 1));
           }

         /* put the new PDU_attr_name in the mcf */
         FIfld_set_text(forms.cat_attr_form_id, mcf_label, rows ,1, 
                        PDU_attr_name, FALSE);

         PDUfill_in_string(&PDU_attr_name, NULL);
         /* put the new PDU_datatype in the mcf */
         FIfld_set_text(forms.cat_attr_form_id, mcf_label, rows ,2, 
                        PDU_datatype, FALSE);

         PDUfill_in_string(&PDU_datatype, NULL);
         /* put the new PDU_synonym in the mcf */
         if ((PDU_synonym != NULL) && (strcmp(PDU_synonym, "")!= 0))
           {
           FIfld_set_text(forms.cat_attr_form_id, mcf_label,rows ,3, 
                          PDU_synonym,FALSE);
           PDUfill_in_string(&PDU_synonym, NULL);
           }

         /* put new default value in the mcf */
         if ((PDU_default_value != NULL) && (strcmp(PDU_default_value, "") != 0))
           {
           FIfld_set_text(forms.cat_attr_form_id, mcf_label, rows ,4,
                          PDU_default_value, FALSE);
           PDUfill_in_string(&PDU_default_value, NULL);
           }

          /* default value for order_num */
           
          /* convert buffer->rows into number */
          if (mcf_label == ATTR_LIST)
            sprintf(order_num, "%d", cat_attr->rows);
          else
            sprintf(order_num, "%d", dyn_attr->rows);

           FIfld_set_text(forms.cat_attr_form_id,mcf_label,rows ,0,
                             order_num, 0);

         FIfld_set_active_row(forms.cat_attr_form_id, mcf_label, rows,0);

         /* point cat_attr to global variable*/

         if (mcf_label == ATTR_LIST)
           {
           PDU_cat_atr = (char *)cat_attr;
           PDU_cat_data = (char *)cat_data;
           PDU_cat_list = (char *)cat_list;
           }
         else
           {
           PDU_dyn_attr = (char *)dyn_attr;
           PDU_dyn_data = (char *)dyn_data;
           PDU_dyn_list = (char *)dyn_list;
           }

           /* set text in fields to NULL & position cursor in ATTRIBUTE_NAME */
           FIg_set_text(forms.cat_attr_form_id, ATTRIBUTE_NAME, "");
           FIfld_pos_cursor(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, 0, 0, 0,
                            1, 1);
           FIg_set_text(forms.cat_attr_form_id, DATATYPE, "");
           FIg_set_text(forms.cat_attr_form_id, SYNONYM, "");
           FIg_set_text(forms.cat_attr_form_id, DEFAULT_VAL, "");

           /* clear out list fields */
            if (min_value)
              PDUfill_in_string(&min_value, NULL);
            if (max_value)
              PDUfill_in_string(&max_value, NULL);
            FIg_set_text(forms.cat_attr_form_id, MAXIMUM_VALUE, "");
            FIg_set_text(forms.cat_attr_form_id, MIN_VALUE, "");
           FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &rows);
             if (rows != 0)
               {
               _pdm_debug("Blank out value list", 0);
               for (i = 0; i < rows; i++)
               FIfld_set_text(forms.cat_attr_form_id, VALUE_LIST, i, 0, "", 
                              FALSE);
               }

            /* reset toggles */
            FIg_set_state_off(forms.cat_attr_form_id, READ_TOG);
            FIg_set_state_off(forms.cat_attr_form_id, WRITE_TOG);
            FIg_set_state_off(forms.cat_attr_form_id, UPDATE_TOG);
            FIg_set_state_on(forms.cat_attr_form_id, INPUT_TOG);

            PDUcheck_if_datatype();

         break;

    case CHANGE_ATTR:

         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         /* get mode of attribute name field */
         status = FIfld_get_mode(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, 
                                 &mode);
         if (status != FI_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_ATTR_MODE);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           break;
           }
        
        if (PDU_datatype == NULL)
          {
          msg = (char *)PDUtranslate_message(PDM_E_DATATYPE);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          break;
          }

        if ((PDU_default_value) && (strcmp(PDU_default_value, "") != 0))
         {
         /* verify the attribute is valid */
         status = PDUvalidate_value(PDU_default_value, PDU_datatype);
         _pdm_status("PDUvalidate_value", status);

         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Value <%s> is not valid", text);
           /* set field to "" and position cursor at the beginning */
           msg = (char *)PDUtranslate_message(PDM_E_INVALID_DEFAULT);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           break;
           }
         }
        if (mode == FI_REVIEW)
          {
         if (((PDU_default_value != NULL) && (strcmp(PDU_default_value, "") != 0))
            && (range_list) &&
             (((min_value != NULL) && (strcmp(min_value, "") != 0)) ||
             ((max_value != NULL) && (strcmp(max_value, "") != 0))))
           {
           status = PDUvalidate_default_in_range(PDU_default_value, 
                                                 PDU_datatype);
           _pdm_status("PDUvalidate_default_in_range", status);
           if (status != PDM_S_SUCCESS)
             break;
           }
         else if (((PDU_default_value != NULL) && (strcmp(PDU_default_value, "") != 0))
             && (value_list))
           {
           _pdm_debug("validate default_value against list", 0);
           FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &rows);
           if (rows != 0)
             {
             status = PDUvalidate_default_in_list(PDU_default_value);
             _pdm_status("PDU_validate_default_in_list",status);

             if (status != PDM_S_SUCCESS)
               {
               msg = (char *)PDUtranslate_message(PDM_E_DEFAULT_VALUE);
               FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
               break;
              }
             }
           }
         FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
         /* change attribute info in the current buffer */
         if (mcf_label == ATTR_LIST)
           {
           status = PDUchange_attribute(&cat_attr,&cat_data, &cat_list);
           _pdm_status("PDUchange_attribute", status);
           if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_CATALOG_NOT_MODIFIED); 
             FIg_set_text(fp, FI_MSG_FIELD,msg);
             PDUmessage(PDM_E_CLEAR_FIELD, 's');
             break;
             }
           else
             PDUmessage(status, 's');
             if (PDM_debug_on)
               {
               MEMprint_buffers("cat_attr", cat_attr, PDU_DEBUG_FILE);
               MEMprint_buffers("cat_data", cat_data, PDU_DEBUG_FILE);
               MEMprint_buffers("cat_list", cat_list, PDU_DEBUG_FILE);
               }
           } 
         else
           {
            status = PDUchange_attribute(&dyn_attr, &dyn_data,&dyn_list);
            _pdm_status("PDUchange_attribute", status);
           if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_CATALOG_NOT_MODIFIED);
             FIg_set_text(fp, FI_MSG_FIELD,msg);
             PDUmessage(PDM_E_CLEAR_FIELD, 's');
             break;
             }
           else
             PDUmessage(status, 's');
             if (PDM_debug_on)
               {
               MEMprint_buffers("dyn_attr", dyn_attr, PDU_DEBUG_FILE);
               MEMprint_buffers("dyn_data", dyn_data, PDU_DEBUG_FILE);
               MEMprint_buffers("dyn_list", dyn_list, PDU_DEBUG_FILE);
               }
            } 
        
         FIg_reset(fp, VALUE_LIST);
         if (mcf_label == ATTR_LIST)
           {
           PDU_cat_atr = (char *)cat_attr;
           PDU_cat_data = (char *)cat_data;
           PDU_cat_list = (char *)cat_list;
           }
         else
           {
           PDU_dyn_attr = (char *)dyn_attr;
           PDU_dyn_data = (char *)dyn_data;
           PDU_dyn_list = (char *)dyn_list;
           }
         /* get active row and set new information to the mcf */
         FIfld_set_active_row(forms.cat_attr_form_id,mcf_label,active_row,
                              act_pos);
         _pdm_debug("active row = %d ",(char *)active_row);

         FIg_set_text(forms.cat_attr_form_id, ATTRIBUTE_NAME, "");
         FIg_set_text(forms.cat_attr_form_id, DATATYPE, "");
         FIg_set_text(forms.cat_attr_form_id, SYNONYM, "");
         FIg_set_text(forms.cat_attr_form_id, DEFAULT_VAL, "");
         FIfld_set_mode(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, FI_INSERT);
         status = FIfld_get_mode(forms.cat_attr_form_id, DATATYPE, 0, 
                                 &mode);
         if (mode == FI_REVIEW)
           {
           FIfld_set_mode(forms.cat_attr_form_id, DATATYPE, 0, FI_INSERT);
           FIg_display(forms.cat_attr_form_id, DATATYPE);
           }
        else
         FIfld_set_text(forms.cat_attr_form_id,mcf_label,active_row,2, PDU_datatype,
                         FALSE);
         FIfld_set_select(forms.cat_attr_form_id, mcf_label, active_row, 
                          0, FALSE);
         FIfld_set_select(forms.cat_attr_form_id, mcf_label, active_row, 
                          1, FALSE);
         FIfld_set_select(forms.cat_attr_form_id, mcf_label, active_row, 2, 
                          FALSE);
        FIfld_set_text(forms.cat_attr_form_id,mcf_label,active_row,3, PDU_synonym, 
                       FALSE);
         FIfld_set_text(forms.cat_attr_form_id,mcf_label,active_row, 4, 
                        PDU_default_value,
                        FALSE);
         FIg_display(forms.cat_attr_form_id, ATTRIBUTE_NAME);
         if (PDU_attr_name)
           PDUfill_in_string(&PDU_attr_name, NULL);
         if (PDU_datatype)
           PDUfill_in_string(&PDU_datatype, NULL);
         if (PDU_synonym)
           PDUfill_in_string(&PDU_synonym, NULL);
         if (PDU_default_value)
           PDUfill_in_string(&PDU_default_value, NULL);
         }
        else
         {
          msg = (char *)PDUtranslate_message(PDM_I_SELECT_ATTR_LIST);
          FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
          }

         /* clear out list fields */
              if (min_value)
                PDUfill_in_string(&min_value, NULL);
              if (max_value)
                PDUfill_in_string(&max_value, NULL);
              FIg_set_text(forms.cat_attr_form_id, MAXIMUM_VALUE, "");
              FIg_set_text(forms.cat_attr_form_id, MIN_VALUE, "");
             FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &rows);
             if (rows != 0)
               {
               _pdm_debug("Blank out value list", 0);
               for (i = 0; i < rows; i++)
               FIfld_set_text(forms.cat_attr_form_id, VALUE_LIST, i, 0, "", 
                              FALSE);
               }

            /* reset toggles */
            FIg_set_state_off(forms.cat_attr_form_id, READ_TOG);
            FIg_set_state_off(forms.cat_attr_form_id, WRITE_TOG);
            FIg_set_state_off(forms.cat_attr_form_id, UPDATE_TOG);
            FIg_set_state_on(forms.cat_attr_form_id, INPUT_TOG);

            /* disable button */
            FIg_disable(fp, CHANGE_ATTR);
            FIg_enable(fp, ADD_ATTR);

            FIg_enable(fp, TOG_GRP);
            FIfld_set_mode(forms.cat_attr_form_id, DEFAULT_VAL, 0, FI_INSERT);
            FIg_display(fp, DEFAULT_VAL);
  
            PDUcheck_if_datatype();

         break;


    case DYNAMIC_ATTR:     /* Member of group GROUP5  */

         FIg_disable(forms.cat_attr_form_id, SYS_ATTR_TOG);
         FIg_display(forms.cat_attr_form_id, ADD_ATTR_GRP);
         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         /* set dynamic_attr flag to TRUE */
         static_attr = FALSE;
         dynamic_attr = TRUE;
         mcf_label = DYN_ATTR_LIST;

         /*if (func_sele == TRUE)
           {
           FIg_disable(fp, FUNCTION_TOG);
           func_sele = FALSE;
           range_list = TRUE;
           FIg_set_text(fp, MIN_TEXT,"Minimum Value");
           FIg_set_
           FIg_display(fp, MIN_TEXT);
           FIg_set_state_on(fp, RANGE_TOG);
           FIg_display(forms.cat_attr_form_id, RANGE_GRP);
           }*/

         /* erase mcf for required and user defined attributes */
         status = FIg_erase(forms.cat_attr_form_id, ATTR_LIST);
         if (status != FI_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_ERASE_LIST);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           break;
           }

         /* display mcf for dynamic attributes */
         status = FIg_display(forms.cat_attr_form_id, DYN_ATTR_LIST);
         status = FIg_enable(forms.cat_attr_form_id, DYN_ATTR_LIST);
         if (status != FI_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_DISPLAY_LIST);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg); 
           FIg_display(forms.cat_attr_form_id, ATTR_LIST);
           break;
           }

         /* clear out fields */
         FIg_set_text(fp, ATTRIBUTE_NAME, "");
         FIfld_set_mode(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, FI_INSERT);
         FIg_display(fp, ATTRIBUTE_NAME);
         FIg_set_text(fp, DATATYPE, "");
         FIfld_set_mode(forms.cat_attr_form_id, DATATYPE, 0, FI_INSERT);
         FIg_display(fp, DATATYPE);
         FIg_set_text(fp, SYNONYM, "");
         FIg_set_text(fp, DEFAULT_VAL, "");
         FIfld_set_mode(forms.cat_attr_form_id, DEFAULT_VAL, 0, FI_INSERT);
         FIg_display(fp, DEFAULT_VAL);
         FIg_set_text(fp, MIN_VALUE, "");
         FIg_set_text(fp, MAXIMUM_VALUE, "");

         FIg_disable(fp, CHANGE_ATTR);
         FIg_enable(fp, ADD_ATTR);
         /* reset toggles */
         FIg_set_state_off(forms.cat_attr_form_id, READ_TOG);
         FIg_set_state_off(forms.cat_attr_form_id, WRITE_TOG);
         FIg_set_state_off(forms.cat_attr_form_id, UPDATE_TOG);
         FIg_set_state_on(forms.cat_attr_form_id, INPUT_TOG);
         
         /* display dynamic table group */
         FIg_display(fp, DYN_TABLE_GRP);

         /* clear out value list */
         FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &rows);
         if (rows != 0)
           {
           _pdm_debug("Blank out value list", 0);
           for (i = 0; i < rows; i++)
            FIfld_set_text(forms.cat_attr_form_id, VALUE_LIST, i, 0, "", 
                              FALSE);
          }

          /* unselect row */
          FIfld_get_num_rows(forms.cat_attr_form_id, ATTR_LIST, &rows);
         for (i = 0; i < rows; i++)
           {
           for (j =0; j < 5; j ++)
             FIfld_set_select(fp, ATTR_LIST, i, j, FALSE);
            }

          FIfld_get_num_rows(forms.cat_attr_form_id, DYN_ATTR_LIST, &rows);
         for (i = 0; i < rows; i++)
           {
           for (j =0; j < 5; j ++)
             FIfld_set_select(fp, DYN_ATTR_LIST, i, j, FALSE);
           }

          /* clean up */
          if (PDU_attr_name)
            PDUfill_in_string(&PDU_attr_name, NULL);
          if (PDU_synonym)
            PDUfill_in_string(&PDU_synonym, NULL);
          if (PDU_datatype)
            PDUfill_in_string(&PDU_datatype, NULL);
          if (max_value)
            PDUfill_in_string(&max_value, NULL);
          if (min_value)
            PDUfill_in_string(&min_value, NULL);
          if (PDU_default_value)
            PDUfill_in_string(&PDU_default_value, NULL);

       break;

    case STATIC_ATTR:     /* Member of group GROUP5  */
                             /* Sequenced to    */

         FIg_enable(forms.cat_attr_form_id, SYS_ATTR_TOG);
         if (PDU_view)
           FIg_erase(forms.cat_attr_form_id, ADD_ATTR_GRP);
         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         /* set static attribute flag to TRUE */
         static_attr = TRUE;
         dynamic_attr = FALSE;
         mcf_label = ATTR_LIST;

         /* erase mcf for dynamic attributes */
         status = FIg_erase(forms.cat_attr_form_id, DYN_ATTR_LIST);
         status = FIg_disable(forms.cat_attr_form_id, DYN_ATTR_LIST);
         
         if (status != FI_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_ERASE_LIST);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg); 
           break;
           }
   
         /* display mcf for required and user defined attributes */
         status = FIg_display(forms.cat_attr_form_id, ATTR_LIST);
       
         if (status != FI_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_DISPLAY_LIST);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg); 
           FIg_display(forms.cat_attr_form_id, DYN_ATTR_LIST);
           break;
           }

         /* clear out fields */
         FIg_set_text(fp, ATTRIBUTE_NAME, "");
         FIfld_set_mode(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, FI_INSERT);
         FIg_display(fp, ATTRIBUTE_NAME);
         FIg_set_text(fp, DATATYPE, "");
         FIfld_set_mode(forms.cat_attr_form_id, DATATYPE, 0, FI_INSERT);
         FIg_display(fp, DATATYPE);
         FIg_set_text(fp, SYNONYM, "");
         FIg_set_text(fp, DEFAULT_VAL, "");
         FIfld_set_mode(forms.cat_attr_form_id, DEFAULT_VAL, 0, FI_INSERT);
         FIg_display(fp, DEFAULT_VAL);
         FIg_set_text(fp, MIN_VALUE, "");
         FIg_set_text(fp, MAXIMUM_VALUE, "");

         FIg_disable(fp, CHANGE_ATTR);
         FIg_enable(fp, ADD_ATTR);
         /* reset toggles */
         FIg_set_state_off(forms.cat_attr_form_id, READ_TOG);
         FIg_set_state_off(forms.cat_attr_form_id, WRITE_TOG);
         FIg_set_state_off(forms.cat_attr_form_id, UPDATE_TOG);
         FIg_set_state_on(forms.cat_attr_form_id, INPUT_TOG);
         
         /* erase dynamic table group */
         FIg_erase(fp, DYN_TABLE_GRP);

         /* clear out value list */
         FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &rows);
         if (rows != 0)
           {
           _pdm_debug("Blank out value list", 0);
           for (i = 0; i < rows; i++)
            FIfld_set_text(forms.cat_attr_form_id, VALUE_LIST, i, 0, "", 
                              FALSE);
          }

          /* unselect row */
          FIfld_get_num_rows(forms.cat_attr_form_id, ATTR_LIST, &rows);
         for (i = 0; i < rows; i++)
           {
           for (j =0; j < 5; j ++)
             FIfld_set_select(fp, ATTR_LIST, i, j, FALSE);
            }

          FIfld_get_num_rows(forms.cat_attr_form_id, DYN_ATTR_LIST, &rows);
         for (i = 0; i < rows; i++)
           {
           for (j =0; j < 5; j ++)
             FIfld_set_select(fp, DYN_ATTR_LIST, i, j, FALSE);
           }

          /* clean up */
          if (PDU_attr_name)
            PDUfill_in_string(&PDU_attr_name, NULL);
          if (PDU_synonym)
            PDUfill_in_string(&PDU_synonym, NULL);
          if (PDU_datatype)
            PDUfill_in_string(&PDU_datatype, NULL);
          if (max_value)
            PDUfill_in_string(&max_value, NULL);
          if (min_value)
            PDUfill_in_string(&min_value, NULL);
          if (PDU_default_value)
            PDUfill_in_string(&PDU_default_value, NULL);

         break;

    case RANGE_TOG:
          
         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         /* set the range_list flag to TRUE */
         range_list = TRUE;
         value_list = FALSE;
         func_sele = FALSE;

         FIg_display(fp, MIN_TEXT);
         /* erase the static value list field */
         status = FIg_erase(forms.cat_attr_form_id, VALUE_LIST);
         status = FIg_erase(forms.cat_attr_form_id, FUNCTION_TEXT);
         if (status != FI_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_ERASE_LIST);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           break;
           }
         
         /* display the fields assosciated with entering range values */
         status = FIg_display(forms.cat_attr_form_id, RANGE_GRP);
       
         if (status != FI_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_DISPLAY_RANGE);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           FIg_display(forms.cat_attr_form_id, VALUE_LIST);
           break;
           }
    
         break;

    case VALUE_TOG:

         FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, NULL_STRING);
         /* set value_list flag to TRUE */
         range_list = FALSE;
         value_list = TRUE;
         func_sele = FALSE;

         /* erase range group field */
         status = FIg_erase(forms.cat_attr_form_id, RANGE_GRP);
         status = FIg_erase(forms.cat_attr_form_id, FUNCTION_TEXT);
         
         if (status != FI_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_ERASE_RANGE);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           break;
           }
   
         /* display the static value list */
         status = FIg_display(forms.cat_attr_form_id, VALUE_LIST);
       
         if (status != FI_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_DISPLAY_LIST);
           FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
           FIg_display(forms.cat_attr_form_id, RANGE_GRP);
           break;
           }

         break;

    case DYN_TABLE_ASSOC_GADGET:

         list_row = value - 1;
         if (strcmp(PDU_value_list[list_row], "KEYIN") == 0)
           {
           FIfld_set_mode(fp, DYN_TABLE, 0, FI_INSERT);
           FIg_display(fp, DYN_TABLE);
           FIfld_pos_cursor(fp, DYN_TABLE, 0, 0, 0,0,1,1);
           FIfld_set_text(fp, DYN_TABLE, 0,0,"", FALSE);
           break;
           }
         FIfld_set_mode(fp, DYN_TABLE, 0, FI_SINGLE_SELECT);
         FIg_display(fp, DYN_TABLE);
         FIfld_set_text(fp, DYN_TABLE, 0,0,PDU_value_list[list_row], FALSE);

         break;

    case SYS_ATTR_TOG:

         FIg_get_state(fp, SYS_ATTR_TOG, &state);
         if (state == 0)
           PDU_required_attr = FALSE;
         else
           PDU_required_attr = TRUE;
       
          if (update_cat == TRUE)
            {
            cat_attr = (MEMptr)PDU_cat_atr;
            status = PDUupdate_attr_buffer(&cat_attr, ATTR_LIST);
            _pdm_status("PDUupdate_attr_buffer(cat_attr)", status);
            }
          if (update_dyn == TRUE)
            {
            dyn_attr = (MEMptr)PDU_dyn_attr;
            status = PDUupdate_attr_buffer(&dyn_attr, DYN_ATTR_LIST);
            _pdm_status("PDUupdate_attr_buffer(dyn_attr)", status);
            }

          FIfld_get_num_rows(forms.cat_attr_form_id, ATTR_LIST, &rows);
         for (i = 0; i < rows; i++)
           {
           for (j =0; j < 5; j ++)
             FIfld_set_text(fp, ATTR_LIST, i, j, "",FALSE);
            }

        if (cat_attr->rows > 0)
          {
          if (cat_attr->rows > 51)
          {
          if (sort_attr)
            MEMclose(&sort_attr);
          if (sort_data)
            MEMclose(&sort_data);
          status = PDUsort_by_order(cat_attr, cat_data, &sort_attr, &sort_data);
          _pdm_status("PDUsort_by_order", status);
          if (status != PDM_S_SUCCESS)
            status = PDUfill_in_mcf(cat_attr, cat_data, ATTR_LIST);
          else
            status = PDUfill_in_mcf(sort_attr, sort_data, ATTR_LIST);
          }
       else
         status = PDUfill_in_mcf(cat_attr, cat_data, ATTR_LIST);
         _pdm_status("PDUfill_in_mcf", status);
         }

         static_attr = TRUE;
         dynamic_attr = FALSE;
         mcf_label = ATTR_LIST;

       FIg_set_state_off(fp, DYNAMIC_ATTR);
       FIg_set_state_on(fp, STATIC_ATTR);
       FIg_erase(fp, DYN_TABLE_GRP);
       FIg_erase(fp, DYN_ATTR_LIST);
       FIg_display(fp, ATTR_LIST);
       FIg_set_text(fp, ATTRIBUTE_NAME, "");
       FIfld_set_mode(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, FI_INSERT);
       FIg_display(fp, ATTRIBUTE_NAME);
       FIg_set_text(fp, DATATYPE, "");
       FIfld_set_mode(forms.cat_attr_form_id, DATATYPE, 0, FI_INSERT);
       FIg_display(fp, DATATYPE);
       FIg_set_text(fp, SYNONYM, "");
       FIg_set_text(fp, DEFAULT_VAL, "");
       FIfld_set_mode(forms.cat_attr_form_id, DEFAULT_VAL, 0, FI_INSERT);
       FIg_disable(forms.cat_attr_form_id, DEFAULT_VAL);
       FIg_display(fp, DEFAULT_VAL);
       FIg_disable(fp, CHANGE_ATTR);
       FIg_enable(fp, ADD_ATTR);
       FIg_set_state_off(forms.cat_attr_form_id, READ_TOG);
       FIg_set_state_off(forms.cat_attr_form_id, WRITE_TOG);
       FIg_set_state_off(forms.cat_attr_form_id, UPDATE_TOG);
       FIg_set_state_on(forms.cat_attr_form_id, INPUT_TOG);
       if ((PDU_attr_name) && (strcmp(PDU_attr_name, "") != 0))
          PDUfill_in_string(&PDU_attr_name, NULL);
       if ((PDU_synonym) && (strcmp(PDU_synonym, "") != 0))
          PDUfill_in_string(&PDU_synonym, NULL);
       if ((PDU_datatype) && (strcmp(PDU_datatype, "") != 0))
          PDUfill_in_string(&PDU_datatype, NULL);
        if (PDU_default_value)
          PDUfill_in_string(&PDU_default_value, NULL);
        if (PDU_view)
          FIg_erase(fp, ADD_ATTR_GRP);
         
       break;

  case FUNCTION_TOG:

       range_list = FALSE;
       value_list = FALSE;
       func_sele = TRUE;

       FIg_erase(fp, MIN_TEXT);
       FIg_enable(fp, MIN_TEXT);
       FIg_display(fp, FUNCTION_TEXT);
       FIg_erase(fp, MIN_TEXT);
       FIg_enable(fp, MIN_TEXT);
       FIg_enable(fp, MIN_VALUE);
       FIg_display(fp, MIN_VALUE);
       FIg_erase(fp, MAX_TEXT);
       FIg_erase(fp, MAXIMUM_VALUE);
       FIg_erase(fp, VALUE_LIST);

       break;
  } /* END switch ( g_label ) */
  return(1);
} /* END cat_attr_notification_routine() */

int PDUupdate_attr_form(attr_buffer, data_buffer, list_buffer, label)

MEMptr attr_buffer;
MEMptr data_buffer;
MEMptr list_buffer;
int label;

  {
  int status;
  char **attr_data;
  char **data_data;
  char **data_columns;
  char **list_data;
  char *text = NULL;
  int i, j;
  int num_rows;     
  int sel_flag; 
  int attr_row;
  int buffer_number;
  int change_attribute = FALSE;
  int select;
  int length;
  int pos;
  
  _pdm_debug("In PDUupdate_attr_form", 0);

  /* get selected PDU_attr_name from mcf */
  status = FIfld_get_num_rows(forms.cat_attr_form_id, label, &num_rows);
  if (status != FI_SUCCESS)
    return(PDM_E_FAILURE);
  _pdm_debug("num_rows = %d", (char *)num_rows);

  for (i = 0; i < num_rows; i++)
    {
    for (j =0; j < 5; j ++)
      {
      status = FIfld_get_select(forms.cat_attr_form_id, label, i, j, &sel_flag);
      _pdm_status("FIfld_get_select", status);
      if (status != FI_SUCCESS)
        return(PDM_E_FAILURE);
      if (sel_flag)
        {
        /* get attribute for selected row */
        status = FImcf_set_active_col(forms.cat_attr_form_id, label, 1, 1);
        if (status != FI_SUCCESS)
          return(PDM_E_FAILURE);

         FIfld_get_text_length(forms.cat_attr_form_id,label,i,1,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(forms.cat_attr_form_id,label,i,1,length,
                        (unsigned char*)text,&select,
                        &pos);

        _pdm_debug("attribute name = <%s>", text);
        PDUfill_in_string(&PDU_attr_name, text);
        break;
        }
      }
    if (sel_flag)
        break;
    }
/* SUN*/
  if ((PDU_attr_name) && (strcmp(PDU_attr_name, "") == 0))
    return(PDM_E_BAD_ATTRIBUTE);

  if (!sel_flag) 
    return(PDM_E_SELECT_ATTR);

  status = MEMbuild_array(attr_buffer);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_row = PDUfind_attr_in_buffer(attr_buffer, PDU_attr_name);

  /* set buffer data to character arrays */
  attr_data = (char **)attr_buffer->data_ptr;

  /* check for MODIFY_CATALOG if attribute has already been updated */
  if (PDU_command == PDC_M_MODIFY_CATALOG) 
    if ((attr_data[(attr_buffer->columns * attr_row) + PDU_NFM_READ_COL +
                           PDU_NFM_MOD_OFFSET] != NULL)  &&
        (strcmp(attr_data[(attr_buffer->columns * attr_row) + PDU_NFM_READ_COL +
                           PDU_NFM_MOD_OFFSET], "") != 0))
       {
       _pdm_debug("Attribute <%s> has been modified during this session",
                   PDU_attr_name);
       change_attribute = TRUE;
       }

  if (!change_attribute)
    {
    if (strcmp(attr_data[(attr_buffer->columns * attr_row) + PDU_NFM_READ_COL],
                "Y") == 0)
      FIg_set_state_off(forms.cat_attr_form_id, READ_TOG);
    else
      FIg_set_state_on(forms.cat_attr_form_id, READ_TOG);
    if (strcmp(attr_data[(attr_buffer->columns * attr_row) + PDU_NFM_WRITE_COL],
               "Y") == 0)
      FIg_set_state_off(forms.cat_attr_form_id, WRITE_TOG);
    else
      FIg_set_state_on(forms.cat_attr_form_id, WRITE_TOG);
    if (strcmp(attr_data[(attr_buffer->columns * attr_row) 
               + PDU_NFM_UPDATE_COL],"Y") == 0)
      FIg_set_state_off(forms.cat_attr_form_id, UPDATE_TOG);
    else
      FIg_set_state_on(forms.cat_attr_form_id, UPDATE_TOG);
    if (strcmp(attr_data[(attr_buffer->columns * attr_row) + PDU_NFM_REQ_COL],
               "Y") == 0)
      FIg_set_state_on(forms.cat_attr_form_id, INPUT_TOG);
    else
      FIg_set_state_off(forms.cat_attr_form_id,INPUT_TOG);
    /* update data fields */
    FIg_set_text(forms.cat_attr_form_id,ATTRIBUTE_NAME,
                 attr_data[(attr_buffer->columns
                 * attr_row) + PDU_NFM_ATTR_COL]);
    PDUfill_in_string(&PDU_attr_name, attr_data[(attr_buffer->columns * attr_row) +
                      PDU_NFM_ATTR_COL]);
    FIg_set_text(forms.cat_attr_form_id,SYNONYM, attr_data[(attr_buffer->columns
                   * attr_row) + PDU_NFM_SYN_COL]);
    PDUfill_in_string(&PDU_synonym, attr_data[(attr_buffer->columns * attr_row) +
                      PDU_NFM_SYN_COL]);
    FIg_set_text(forms.cat_attr_form_id,DATATYPE,attr_data[(attr_buffer->columns
                   * attr_row) + PDU_NFM_DATA_COL]);
    PDUfill_in_string(&PDU_datatype, attr_data[(attr_buffer->columns * attr_row) +
                      PDU_NFM_DATA_COL]);
    }
  else
    {
    if (strcmp(attr_data[(attr_buffer->columns * attr_row) + PDU_NFM_READ_COL
                          + PDU_NFM_MOD_OFFSET ],
                "Y") == 0)
      FIg_set_state_off(forms.cat_attr_form_id, READ_TOG);
    else
      FIg_set_state_on(forms.cat_attr_form_id, READ_TOG);
    if (strcmp(attr_data[(attr_buffer->columns * attr_row) + PDU_NFM_WRITE_COL
                          + PDU_NFM_MOD_OFFSET ],
               "Y") == 0)
      FIg_set_state_off(forms.cat_attr_form_id, WRITE_TOG);
    else
      FIg_set_state_on(forms.cat_attr_form_id, WRITE_TOG);
    if (strcmp(attr_data[(attr_buffer->columns * attr_row) 
               + PDU_NFM_UPDATE_COL + PDU_NFM_MOD_OFFSET ],"Y") == 0)
      FIg_set_state_off(forms.cat_attr_form_id, UPDATE_TOG);
    else
      FIg_set_state_on(forms.cat_attr_form_id, UPDATE_TOG);
    if (strcmp(attr_data[(attr_buffer->columns * attr_row) + PDU_NFM_REQ_COL
                         + PDU_NFM_MOD_OFFSET ],
               "Y") == 0)
      FIg_set_state_on(forms.cat_attr_form_id, INPUT_TOG);
    else
      FIg_set_state_off(forms.cat_attr_form_id,INPUT_TOG);
    /* update data fields */
    FIg_set_text(forms.cat_attr_form_id,ATTRIBUTE_NAME,
                 attr_data[(attr_buffer->columns
                   * attr_row) + PDU_NFM_ATTR_COL + PDU_NFM_MOD_OFFSET]);
    PDUfill_in_string(&PDU_attr_name, attr_data[(attr_buffer->columns * attr_row) +
                      PDU_NFM_ATTR_COL + PDU_NFM_MOD_OFFSET]);
    FIg_set_text(forms.cat_attr_form_id,SYNONYM, attr_data[(attr_buffer->columns
                   * attr_row) + PDU_NFM_SYN_COL + PDU_NFM_MOD_OFFSET]);
    PDUfill_in_string(&PDU_synonym, attr_data[(attr_buffer->columns * attr_row) +
                       PDU_NFM_MOD_OFFSET + PDU_NFM_SYN_COL]);
    FIg_set_text(forms.cat_attr_form_id,DATATYPE,attr_data[(attr_buffer->columns
                   * attr_row) + PDU_NFM_DATA_COL + PDU_NFM_MOD_OFFSET]);
    PDUfill_in_string(&PDU_datatype, attr_data[(attr_buffer->columns * attr_row) +
                      PDU_NFM_DATA_COL + PDU_NFM_MOD_OFFSET]);
    }

  status = PDUcheck_if_change_toggles(PDU_attr_name);
  _pdm_status("PDUcheck_if_change_tog", status);
  
  if (status != PDM_S_SUCCESS)
    {
    FIg_disable(forms.cat_attr_form_id, TOG_GRP);
    if ((strcmp(PDU_attr_name, "n_itemname") == 0) || 
        (strcmp(PDU_attr_name, "n_itemrev") == 0) ||
        (strcmp(PDU_attr_name, "n_itemno") == 0))
      FIg_disable(forms.cat_attr_form_id, READ_TOG);
    else
       {
       FIg_enable(forms.cat_attr_form_id, READ_TOG);
       FIg_enable(forms.cat_attr_form_id, READ_TEXT);
       }
    if ((strcmp(PDU_attr_name, "n_versionlimit") != 0) &&
        (strcmp(PDU_attr_name, "n_itemrev") != 0))
    {
    FIfld_set_mode(forms.cat_attr_form_id, DEFAULT_VAL, 0, FI_REVIEW);
    FIg_display(forms.cat_attr_form_id, DEFAULT_VAL);
    }
    else
    {
    FIfld_set_mode(forms.cat_attr_form_id, DEFAULT_VAL, 0, FI_INSERT);
    FIg_display(forms.cat_attr_form_id, DEFAULT_VAL);
    }
    }
  else
    {
    FIg_enable(forms.cat_attr_form_id, TOG_GRP);
    if (strcmp(PDU_attr_name, "n_cifilename") == 0)
      FIg_disable(forms.cat_attr_form_id, READ_TOG);
    else
      FIg_enable(forms.cat_attr_form_id, READ_TOG);
    FIfld_set_mode(forms.cat_attr_form_id, DEFAULT_VAL, 0, FI_INSERT);
    FIg_display(forms.cat_attr_form_id, DEFAULT_VAL);
    }

  if (data_buffer != NULL)
    {
    status = MEMbuild_array(data_buffer);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);
    data_data = (char **)data_buffer->data_ptr;
    data_columns = (char **)data_buffer->column_ptr;
    for ( i = 0; i < data_buffer->columns; i ++)
      {
      if (strcmp(data_columns[i], PDU_attr_name) == 0)
        {
        PDUfill_in_string(&PDU_default_value, data_data[(data_buffer->columns * 0)
                            + i]);
/* SUN */
        if (PDU_default_value == NULL)
          {
          PDUfill_in_string(&PDU_default_value, "");
          }
/* end SUN */

        _pdm_debug("defalut_value = <%s>", PDU_default_value);
        FIg_set_text(forms.cat_attr_form_id, DEFAULT_VAL, PDU_default_value);
        }
      }
    }

  _pdm_debug("Convert buffer_number to integer", 0);
  if ((PDU_command == PDC_M_MODIFY_CATALOG) && (change_attribute))
  sscanf(attr_data[(attr_buffer->columns * attr_row) + PDU_NFM_LISTNO_COL +
         PDU_NFM_MOD_OFFSET],"%d",
          &buffer_number);
  else
  sscanf(attr_data[(attr_buffer->columns * attr_row) + PDU_NFM_LISTNO_COL],"%d",
                   &buffer_number);
  _pdm_debug("buffer_number = %d ", (char *)buffer_number);
  if (buffer_number >= 1)
    {
    status = MEMreset_buffer_no(list_buffer, buffer_number);
    _pdm_status("MEMreset_buffer_no", status);
    _pdm_debug("buffer number = %d ", (char *)buffer_number);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_RESET_BUFFER);
    list_data = (char **)list_buffer->data_ptr;
    if (strcmp(list_data[0], "NFM_RANGE") == 0)
      {
      _pdm_debug("Range of values entered", 0);
      FIg_set_text(forms.cat_attr_form_id, MIN_VALUE, list_data[1]);
      FIg_set_text(forms.cat_attr_form_id, MAXIMUM_VALUE, list_data[2]);
      PDUfill_in_string(&max_value, list_data[2]);
      PDUfill_in_string(&min_value, list_data[1]);
      if (value_list)
        {
        FIg_set_state_on(forms.cat_attr_form_id, RANGE_TOG);
        /* check to see if any values are in VALUE_LIST */
        FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &num_rows);
        if (num_rows != 0)
        {
        _pdm_debug("Blank out value list", 0);
        for (i = 0; i < num_rows; i++)
          FIfld_set_text(forms.cat_attr_form_id, VALUE_LIST, i, 0, "", FALSE);
        }
        FIg_erase(forms.cat_attr_form_id, VALUE_LIST);
        FIg_display(forms.cat_attr_form_id, RANGE_GRP);
        range_list = TRUE;
        value_list = FALSE;
        }
      }
    else
      {
      /* check to see if any values are in VALUE_LIST */
      FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &num_rows);
      if (num_rows != 0)
        {
        _pdm_debug("Blank out value list", 0);
        for (i = 0; i < num_rows; i++)
          FIfld_set_text(forms.cat_attr_form_id, VALUE_LIST, i, 0, "", FALSE);
        }
      /* place new values in list */
      for ( i = 0; i < list_buffer->rows; i ++)
        {
        status = FIfld_set_text(forms.cat_attr_form_id, VALUE_LIST, i, 0, 
                       list_data[(list_buffer->columns * i) + 3], 0);
        _pdm_status("FIfld_set_text", status);
        }
      if (range_list)
        {
        FIg_set_state_on(forms.cat_attr_form_id, VALUE_TOG);
        if (min_value)
          PDUfill_in_string(&min_value, NULL);
        if (max_value)
          PDUfill_in_string(&max_value, NULL);
        FIg_set_text(forms.cat_attr_form_id, MAXIMUM_VALUE, "");
        FIg_set_text(forms.cat_attr_form_id, MIN_VALUE, "");
        FIg_erase(forms.cat_attr_form_id, RANGE_GRP);
        FIg_display(forms.cat_attr_form_id, VALUE_LIST);
        value_list = TRUE;
        range_list = FALSE;
        } 
      }
    }
  else
    {
    /* clear out additional info */
    FIg_set_text(forms.cat_attr_form_id, MIN_VALUE, "");
    FIg_set_text(forms.cat_attr_form_id, MAXIMUM_VALUE, "");
    /* check to see if any values are in VALUE_LIST */
    FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &num_rows);
    if (num_rows != 0)
      {
      _pdm_debug("Blank out value list", 0);
      for (i = 0; i < num_rows; i++)
        FIfld_set_text(forms.cat_attr_form_id, VALUE_LIST, i, 0, "", FALSE);
      }
     }

  return(PDM_S_SUCCESS);
  }
    


int PDUadd_attribute(attr_buffer, data_buffer, list_buffer)

MEMptr *attr_buffer;
MEMptr *data_buffer;
MEMptr *list_buffer;

  {

  int status;
  int state;
  int i;
  int no_buffers;
  int num_rows;
  int attr_row;
  int pos;
  int select;
  int length;
  char *row;
  char *read_tog = NULL;
  char *write_tog = NULL;
  char *update_tog = NULL;
  char *delete_tog = NULL;
  char *input_tog = NULL;
  char *text = NULL;
  char **new_data_columns = NULL;
  char char_string[10];
  MEMptr new_list = NULL;
  MEMptr new_attr = NULL;
  MEMptr new_data = NULL;

  _pdm_debug("In PDUadd_attribute", 0);
  
  /* display message */
  PDUmessage(PDS_M_ADDING_ATTRIBUTE, 's');

  new_attr = *attr_buffer;

  /* check and see if adding dynamic attribute */
  if ((mcf_label == DYN_ATTR_LIST) && (PDU_form_id == forms.cat_attr_form_id))
    {
    if (new_attr == NULL)
      {
      status = PDUcreate_dynamic_attr_buffr(&new_attr);
      _pdm_status("PDUcreate_dynamic_attr", status);
      if (status != PDM_S_SUCCESS)
        return(status);
       }
    }

  
  if (PDM_debug_on)
    MEMprint_buffer("new attr", new_attr, PDU_DEBUG_FILE);

  row = (char *)malloc((new_attr)->row_size);
  if ((new_attr->rows == 0) && (dynamic_attr) && 
       (PDU_form_id == forms.cat_attr_form_id))
    {
    /* NFM 3.0 - changed sprintf */
   if (new_attr->columns > 16)
    sprintf(row,
    "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1",
    "p_pdcno","integer","Pdc No","PDM","N","N","N","N","N","1","0");
  else
    sprintf(row,
    "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1\1",
    "p_pdcno","integer","Pdc No","PDM","N","N","N","N","N","1","0");
    /* NFNM 3.0 - end change */
    status = MEMwrite(new_attr, row);
    _pdm_status("MEMwrite", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
    memset(row, NULL, new_attr->row_size);
    }

  status = MEMbuild_array(new_attr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
 
  if (PDU_form_id == forms.cat_attr_form_id)
  {
  status = FIg_get_state(forms.cat_attr_form_id, READ_TOG, &state);
  if (status != FI_SUCCESS)
    return(PDM_E_FAILURE);

  if (state == 0)
    PDUfill_in_string(&read_tog, "Y");
  else
    PDUfill_in_string(&read_tog, "N");

  status = FIg_get_state(forms.cat_attr_form_id, WRITE_TOG, &state);
  if (status != FI_SUCCESS)
    return(PDM_E_FAILURE);

  if (state == 0)
    PDUfill_in_string(&write_tog, "Y");
  else
    PDUfill_in_string(&write_tog, "N");

  status = FIg_get_state(forms.cat_attr_form_id, UPDATE_TOG, &state);
  if (status != FI_SUCCESS)
    return(PDM_E_FAILURE);
  
  if (state == 0)
    PDUfill_in_string(&update_tog, "Y");
  else
    PDUfill_in_string(&update_tog, "N");

  PDUfill_in_string(&delete_tog, "N");
  status = FIg_get_state(forms.cat_attr_form_id, INPUT_TOG, &state);
  if (status != FI_SUCCESS)
    return(PDM_E_FAILURE);
  
  if (state == 0)
    PDUfill_in_string(&input_tog, "N");
  else
    PDUfill_in_string(&input_tog, "Y");
  }
  num_rows = new_attr->rows + 1;
  if (PDU_form_id == forms.cat_attr_form_id) 
  {
  /* NFM 3.0 - changed sprintf */
  if ((new_attr->columns > 16) && (PDU_synonym) && 
      (strcmp(PDU_synonym, "") != 0))
  sprintf(row, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1",
                PDU_attr_name, PDU_datatype, PDU_synonym, "PDM",read_tog, 
               write_tog,update_tog, delete_tog, input_tog, num_rows, "0");
  else if (new_attr->columns > 16)
  sprintf(row, "%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1",
                PDU_attr_name, PDU_datatype, "PDM",read_tog, 
               write_tog,update_tog, delete_tog, input_tog, num_rows, "0");
  else if ((PDU_synonym) && (strcmp(PDU_synonym, "") != 0))
  sprintf(row, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1\1",
           PDU_attr_name,
           PDU_datatype, PDU_synonym,"PDM",read_tog, write_tog, update_tog, 
           delete_tog, input_tog, num_rows, "0");
  else
  sprintf(row, "%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1\1",
           PDU_attr_name,
           PDU_datatype, "PDM",read_tog, write_tog, update_tog, 
           delete_tog, input_tog, num_rows, "0");
  }
  else 
    sprintf(row, "%s\1%s\1\1\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1",
            PDU_attr_name,
            PDU_datatype, "PDM","Y", "Y", "Y", "Y", "N", num_rows,
            "0");
  /* NFM 3.0 - end change */
  _pdm_debug("Row is %s", row);
  status = MEMwrite(new_attr,row);
  _pdm_status("MEMwrite_data", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  /* update_data_buffer and add PDU_default_value */
  new_data = *data_buffer;

  status = PDUupdate_data_buffer(&new_data, new_attr);
  _pdm_status("PDUupdate_data_buffer", status);
  if (status != PDM_S_SUCCESS)
    return(status);
  status = MEMbuild_array(new_data);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
  if ((PDU_default_value != NULL) && (strcmp(PDU_default_value, "") != 0))
    {
    new_data_columns = (char **)new_data->column_ptr;
    for ( i = 0; i < new_data->columns; i++)
      if (strcmp(new_data_columns[i], PDU_attr_name) == 0)
        {
        status = MEMwrite_data(new_data, PDU_default_value, 1, (i + 1));
        _pdm_status("MEMwrite_data", status);
        if (status != MEM_S_SUCCESS)
          return(PDM_E_WRITE_BUFFER);
        break;
        }
     }

  if (PDU_form_id == forms.cat_attr_form_id)
  {
  if ((range_list) && (((max_value != NULL) && (strcmp(max_value, "") != 0)) ||
     ((min_value != NULL) && (strcmp(min_value, "") != 0))))
    {
    _pdm_debug("range value(s) entered for attribute",0);
    if ((min_value != NULL) && (strcmp(min_value, "") != 0))
      {
      status = PDUvalidate_value(min_value, PDU_datatype);
      _pdm_status("PDUvalidate_value", status);
      if (status != PDM_S_SUCCESS)
        return(status);
      }
    if ((max_value != NULL) && (strcmp(max_value, "") != 0))
      {
      status = PDUvalidate_value(max_value, PDU_datatype);
      _pdm_status("PDUvalidate_value", status);
      if (status != PDM_S_SUCCESS)
        return(status);
      }
    status = PDUformat_list_buffer(&new_list);
    _pdm_status("PDUformat_list_buffer", status);
    if (status != PDM_S_SUCCESS)
      return(status);
    memset(row, NULL, new_attr->row_size);
    if ((min_value == NULL) || (strcmp(min_value, "") == 0))
      sprintf(row, "%s\1\1%s\1\1\1%s\1%s\1\1", 
              "NFM_RANGE",max_value, "S","NFM");
    else if ((max_value == NULL) || (strcmp(max_value, "") == 0))
      sprintf(row, "%s\1%s\1\1\1\1%s\1%s\1\1", 
              "NFM_RANGE",min_value, "S","NFM");
    else
      sprintf(row, "%s\1%s\1%s\1\1\1%s\1%s\1\1", 
              "NFM_RANGE",min_value, max_value, "S","NFM");
    status = MEMwrite(new_list, row);
   _pdm_status("MEMwrite(new_list)", status);
   if (status != MEM_S_SUCCESS)
     return(PDM_E_WRITE_ROW);
     }
  else if (value_list)
    {
    _pdm_debug("User could have entered a range of values", 0);
    /* check to see if any values have been entered in the list field */
    status = FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &num_rows);
    if (status != FI_SUCCESS)
      return(PDM_E_FAILURE);
    _pdm_debug("num_rows = %d", (char *)num_rows);
    FIfld_set_active_row(forms.cat_attr_form_id, VALUE_LIST, 0, 0);

    FIfld_get_text_length(forms.cat_attr_form_id,VALUE_LIST,0,0,&length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.cat_attr_form_id,VALUE_LIST,0,0,length,
                   (unsigned char*)text,&select,
                   &pos);
/* SUN */
    if ((num_rows != 0) && (text) && (strcmp(text, "") != 0))
      {
    status = PDUformat_list_buffer(&new_list);
    _pdm_status("PDUformat_buffer", status);
    if (status != PDM_S_SUCCESS)
      return(status);
    
    for (i = 0; i < (num_rows - 1); i++)
      {
      /* get values from the list */
      status = FIfld_set_active_row(forms.cat_attr_form_id, VALUE_LIST, i, i);
      _pdm_status("FIfld_set_active_row", status);
      if (status != FI_SUCCESS)
        return(PDM_E_FAILURE);

      FIfld_get_text_length(forms.cat_attr_form_id,VALUE_LIST,i,0,&length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL, sizeof (char) * length + 1);
      FIfld_get_text(forms.cat_attr_form_id,VALUE_LIST,i,0,length,
                     (unsigned char*)text,&select,
                     &pos);

      _pdm_debug("text = <%s>", text);
      if (strcmp(text, "") == 0)
        break;
      status = PDUvalidate_value(text, PDU_datatype);
      _pdm_status("PDUvalidate_value", status);
      if (status != PDM_S_SUCCESS)
        return(status);
      /* write values into buffer */
      memset(row, NULL, new_attr->row_size);
      sprintf(row, "%s\1\1\1%s\1\1%s\1%s\1\1",
              "NFM_STATIC",text,"S", "PDM");
      status = MEMwrite(new_list, row);
      _pdm_status("MEMwrite", status);
      if (status != MEM_S_SUCCESS)
        {
        _pdm_debug("MEMwrite failed", 0);
        return(PDM_E_WRITE_BUFFER);
        }
      }
    }
    }
  else if (func_sele)
    {
    _pdm_debug("add function for attribute", 0);
    if (PDU_cat_func_bufr == NULL)
      PDUformat_function_bufr(&PDU_cat_func_bufr);
      
    FIfld_get_text_length(forms.cat_attr_form_id,MIN_VALUE,0,0,&length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.cat_attr_form_id,MIN_VALUE,0,0,length,
                   (unsigned char*)text,&select,
                   &pos);

     if ((text) && (strcmp(text, "") != 0))
       {
       _pdm_debug("function name = <%s>", text);
       memset(row, NULL, new_attr->row_size);
       sprintf(row, "%s\1\1%s\1", PDU_attr_name, text);
       status = MEMwrite(PDU_cat_func_bufr, row);
       _pdm_status("MEMwrite", status);

       if (status != MEM_S_SUCCESS)
         return(PDM_E_WRITE_BUFFER);
       else
         status = PDM_S_SUCCESS;
       }
     }

  if ((new_list) && (*list_buffer != NULL))
    {
    /* append list_buffer to appropriate list or dyn_list buffers */ 
    _pdm_debug("Append new list buffer to cat_list buffer", 0);
    status = MEMno_buffers(*list_buffer, &no_buffers);
    _pdm_status("MEMno_buffers(list_buffer)", status);

    if ((status != MEM_S_SUCCESS) && (status != MEM_E_NULL_LIST))
      return(PDM_E_NUMBER_OF_BUFFERS);

    status = MEMappend(new_list, *list_buffer);
    _pdm_status("MEMappend(list_buffer)", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_APPEND_BUFFER);
    attr_row = PDUfind_attr_in_buffer(new_attr, PDU_attr_name);
    no_buffers = no_buffers + 1;
    _pdm_debug("No_buffers = %d", (char *)no_buffers);
    sprintf(char_string,"%d",no_buffers);
    status = MEMwrite_data(new_attr, char_string,(attr_row + 1) ,
                          (PDU_NFM_LISTNO_COL + 1));
    if (status != MEM_S_SUCCESS)
      return(status);
    }
  else
    if ((new_list) && (*list_buffer == NULL))
      {
      _pdm_debug("No list buffer before", 0);
      *list_buffer = new_list;
      no_buffers = 1;
      attr_row = PDUfind_attr_in_buffer(new_attr, PDU_attr_name);
      sprintf(char_string,"%d",no_buffers);
      status = MEMwrite_data(new_attr, char_string,(attr_row + 1) ,
                             (PDU_NFM_LISTNO_COL + 1));
      if (status != MEM_S_SUCCESS)
        return(status);
      }
   else
     {
      _pdm_debug("No assosciate list", 0);
      attr_row = PDUfind_attr_in_buffer(new_attr, PDU_attr_name);
      no_buffers = 0;
      sprintf(char_string,"%d",no_buffers);
      status = MEMwrite_data(new_attr,char_string ,(attr_row + 1) ,
                             (PDU_NFM_LISTNO_COL + 1));
      if (status != MEM_S_SUCCESS)
        return(status);
      }
  } /* end if (PDU_form_id == forms.cat_attr_form_id) */

  *attr_buffer = new_attr;
  *data_buffer = new_data;
  return(PDM_S_SUCCESS);
  }
 
int PDUchange_attribute(attr_buffer, data_buffer, list_buffer)

MEMptr *attr_buffer;
MEMptr *data_buffer;
MEMptr *list_buffer;

  {

  int status;
  int state;
  int i;
  int no_buffers;
  int num_rows;
  int attr_row;
  char *read_tog = NULL;
  char *write_tog = NULL;
  char *update_tog = NULL;
  char *delete_tog = NULL;
  char *input_tog = NULL;
  char *text = NULL;
  char **new_data_columns;
  char **attr_data;
  int  buffer_number;
  char *row;
  char *filename = NULL;
  char **func_data = NULL;
  char char_string[10];
  MEMptr new_list = NULL;
  MEMptr new_attr;
  MEMptr new_data;
  int    change_attribute = FALSE;
  int pos;
  int select;
  int length;

  _pdm_debug("In PDUchange_attribute", 0);

  /* display message */
  PDUmessage(PDS_M_CHANGING_ATTRIBUTE, 's');

  new_attr = *attr_buffer;
  status = MEMbuild_array(new_attr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
 
  if (PDU_form_id == forms.cat_attr_form_id)
  {
  status = FIg_get_state(forms.cat_attr_form_id, READ_TOG, &state);
  if (status != FI_SUCCESS)
    return(PDM_E_FAILURE);

  if (state == 0)
    PDUfill_in_string(&read_tog, "Y");
  else
    PDUfill_in_string(&read_tog, "N");

  status = FIg_get_state(forms.cat_attr_form_id, WRITE_TOG, &state);
  if (status != FI_SUCCESS)
    return(PDM_E_FAILURE);

  if (state == 0)
    PDUfill_in_string(&write_tog, "Y");
  else
    PDUfill_in_string(&write_tog, "N");

  status = FIg_get_state(forms.cat_attr_form_id, UPDATE_TOG, &state);
  if (status != FI_SUCCESS)
    return(PDM_E_FAILURE);
  
  if (state == 0)
    PDUfill_in_string(&update_tog, "Y");
  else
    PDUfill_in_string(&update_tog, "N");

  PDUfill_in_string(&delete_tog, "N");

  status = FIg_get_state(forms.cat_attr_form_id, INPUT_TOG, &state);
  if (status != FI_SUCCESS)
    return(PDM_E_FAILURE);
  
  if (state == 0)
    PDUfill_in_string(&input_tog, "N");
  else
    PDUfill_in_string(&input_tog, "Y");
  }

  attr_row = PDUfind_attr_in_buffer(new_attr, PDU_attr_name);
  attr_data = (char **)new_attr->data_ptr;

  /* check if Change Catalog, attribute was added before this session */
  if (PDU_command == PDC_M_MODIFY_CATALOG) 
    if ((attr_data[(new_attr->columns * attr_row) + PDU_NFM_READ_COL +
                           PDU_NFM_MOD_OFFSET] != NULL) && 
        (strcmp(attr_data[(new_attr->columns * attr_row) + PDU_NFM_READ_COL +
                           PDU_NFM_MOD_OFFSET], "") != 0))
       {
       _pdm_debug("Attribute <%s> has been modified during this session",
                   PDU_attr_name);
       change_attribute = TRUE;
       }


  if (attr_row != -1)
    {
    if ((PDU_command == PDC_M_MODIFY_CATALOG) && (change_attribute) &&
        (PDU_form_id == forms.cat_attr_form_id))

      status = MEMwrite_data(new_attr, PDU_attr_name, (attr_row + 1), 
                    (PDU_NFM_MOD_OFFSET + PDU_NFM_ATTR_COL + 1));
    else
      status = MEMwrite_data(new_attr, PDU_attr_name, (attr_row + 1), 
                  (PDU_NFM_ATTR_COL + 1));

    _pdm_status("MEMwrite_data(PDU_attr_name)",status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
     
    if ((PDU_command == PDC_M_MODIFY_CATALOG) && (change_attribute) &&
        (PDU_form_id == forms.cat_attr_form_id))
      status = MEMwrite_data(new_attr, PDU_datatype, (attr_row + 1), 
                            (PDU_NFM_MOD_OFFSET + PDU_NFM_DATA_COL + 1 ));
    else
      status = MEMwrite_data(new_attr, PDU_datatype, (attr_row + 1), 
                             (PDU_NFM_DATA_COL + 1));

    _pdm_status("MEMwrite_data(PDU_datatype)",status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
     
    if ((PDU_command == PDC_M_MODIFY_CATALOG) && (change_attribute) &&
        (PDU_form_id == forms.cat_attr_form_id) && (PDU_synonym) &&
        (strcmp(PDU_synonym, "") != 0))
      status = MEMwrite_data(new_attr, PDU_synonym, (attr_row + 1), 
                            (PDU_NFM_MOD_OFFSET + PDU_NFM_SYN_COL  + 1));
    else if ((PDU_command == PDC_M_MODIFY_CATALOG) && (change_attribute) &&
        (PDU_form_id == forms.cat_attr_form_id))
      status = MEMwrite_data(new_attr, "", (attr_row + 1), 
                            (PDU_NFM_MOD_OFFSET + PDU_NFM_SYN_COL  + 1));
    else if ((PDU_command == PDC_M_MODIFY_CATALOG) && 
             (PDU_form_id == forms.cat_attr_form_id) && (PDU_synonym) &&
             (strcmp(PDU_synonym, "") != 0))
      status = MEMwrite_data(new_attr, PDU_synonym, (attr_row + 1), 
                            (PDU_NFM_MOD_OFFSET + PDU_NFM_SYN_COL  + 1));
    else if ((PDU_command == PDC_M_MODIFY_CATALOG) && 
        (PDU_form_id == forms.cat_attr_form_id))
      status = MEMwrite_data(new_attr, "", (attr_row + 1), 
                            (PDU_NFM_SYN_COL  + 1));
    else if ((PDU_synonym) && (strcmp(PDU_synonym, "") != 0))
      status = MEMwrite_data(new_attr, PDU_synonym, (attr_row + 1), 
                            (PDU_NFM_SYN_COL + 1));
    else
      status = MEM_S_SUCCESS;

    _pdm_status("MEMwrite_data(PDU_synonym)",status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
     
    if (PDU_form_id == forms.cat_attr_form_id)
    {
    if ((PDU_command == PDC_M_MODIFY_CATALOG) && (change_attribute))
      status = MEMwrite_data(new_attr, read_tog, (attr_row + 1), 
                  (PDU_NFM_MOD_OFFSET + PDU_NFM_READ_COL  + 1));
    else
      status = MEMwrite_data(new_attr, read_tog, (attr_row + 1), 
                             (PDU_NFM_READ_COL + 1));

    _pdm_status("MEMwrite_data(read_tog)",status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
     
    if ((PDU_command == PDC_M_MODIFY_CATALOG) && (change_attribute))
      status = MEMwrite_data(new_attr, write_tog, (attr_row + 1), 
                            (PDU_NFM_MOD_OFFSET + PDU_NFM_WRITE_COL + 1));
    else
      status = MEMwrite_data(new_attr, write_tog, (attr_row + 1), 
                            (PDU_NFM_WRITE_COL + 1));

    _pdm_status("MEMwrite_data(write_tog)",status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
     
    if ((PDU_command == PDC_M_MODIFY_CATALOG) &&(change_attribute))
      status = MEMwrite_data(new_attr, update_tog, (attr_row + 1), 
                             (PDU_NFM_MOD_OFFSET + PDU_NFM_UPDATE_COL  + 1));
    else
      status = MEMwrite_data(new_attr, update_tog, (attr_row + 1), 
                             (PDU_NFM_UPDATE_COL + 1));

    _pdm_status("MEMwrite_data(update_tog)",status);
    
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
     
    if ((PDU_command == PDC_M_MODIFY_CATALOG) && (change_attribute))
      status = MEMwrite_data(new_attr, delete_tog, (attr_row + 1), 
                    (PDU_NFM_MOD_OFFSET + PDU_NFM_DELETE_COL + 1));
    else
      status = MEMwrite_data(new_attr, delete_tog, (attr_row + 1), 
                    (PDU_NFM_DELETE_COL + 1));

    _pdm_status("MEMwrite_data(delete_tog)",status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
     
    if ((PDU_command == PDC_M_MODIFY_CATALOG) && (change_attribute))
      status = MEMwrite_data(new_attr, input_tog, (attr_row + 1), 
                  (PDU_NFM_MOD_OFFSET + PDU_NFM_REQ_COL + 1 ));
    else
      status = MEMwrite_data(new_attr, input_tog, (attr_row + 1), 
                  (PDU_NFM_REQ_COL + 1));

    _pdm_status("MEMwrite_data(input_tog)",status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
    } 
    }
  
  status = PDUupdate_data_buffer(data_buffer, new_attr);
  _pdm_status("PDUupdate_data_buffer", status);
  if (status != PDM_S_SUCCESS)
    return(status);
  new_data = *data_buffer;
  status = MEMbuild_array(new_data);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
  new_data_columns = (char **)new_data->column_ptr;
  for ( i = 0; i < new_data->columns; i++)
    {
      if (strcmp(new_data_columns[i], PDU_attr_name) == 0)
        {
          if ((PDU_command == PDC_M_MODIFY_CATALOG) && (PDU_default_value))
            status = MEMwrite_data(new_data, PDU_default_value, 1, (i + 1));
          else if (PDU_default_value)
            status = MEMwrite_data(new_data, PDU_default_value, 1, (i + 1));
          else
            status = MEMwrite_data(new_data, "\1", 1, (i + 1));
        _pdm_status("MEMwrite_data", status);
        if (status != MEM_S_SUCCESS)
          return(PDM_E_WRITE_BUFFER);
        break;
        }
     }
   if (PDU_form_id == forms.cat_attr_form_id)
   {
   /* see if an assosciated list existed before */
   attr_data = (char **)new_attr->data_ptr;
   sscanf(attr_data[(new_attr->columns * attr_row) + PDU_NFM_LISTNO_COL],
                   "%d", &buffer_number);
   if ((range_list) && ((max_value != NULL) || (min_value != NULL)))
    {
    _pdm_debug("range value(s) entered for attribute",0);
    status = PDUformat_list_buffer(&new_list);
    _pdm_status("PDUformat_list_buffer", status);
    if (status != PDM_S_SUCCESS)
      return(status);
    row = (char *)malloc(new_attr->row_size);
    memset(row, NULL, new_attr->row_size);
    if ((min_value == NULL) || (strcmp(min_value, "") == 0))
      sprintf(row, "%s\1\1%s\1\1\1%s\1%s\1\1", 
             "NFM_RANGE",max_value, "S", "NFM");
    else if ((max_value == NULL) || (strcmp(max_value, "") == 0))
      sprintf(row, "%s\1%s\1\1\1\1%s\1%s\1\1", 
             "NFM_RANGE",min_value, "S", "NFM");
    else
     sprintf(row, "%s\1%s\1%s\1\1\1%s\1%s\1\1", 
           "NFM_RANGE",min_value, max_value, "S", "NFM");
    status = MEMwrite(new_list, row);
    _pdm_status("MEMwrite(new_list)", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_ROW);
    }
   else if (value_list)
    {
    _pdm_debug("User could have entered a range of values", 0);
    /* check to see if any values have been entered in the list field */
    FIfld_get_num_rows(forms.cat_attr_form_id,VALUE_LIST,&num_rows);
    _pdm_debug("num_rows = %d", (char *)num_rows);
    if (num_rows != 0)
      {
      status = PDUformat_list_buffer(&new_list);
      _pdm_status("PDUformat_buffer", status);
      if (status != PDM_S_SUCCESS)
        return(status);
   
      row = (char *)malloc(new_attr->row_size);
      for (i = 0; i < num_rows; i++)
        {
        /* get values from the list */
        status = FIfld_set_active_row(forms.cat_attr_form_id, VALUE_LIST, i, i);

        FIfld_get_text_length(forms.cat_attr_form_id,VALUE_LIST,i,0,&length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL, sizeof (char) * length + 1);
        FIfld_get_text(forms.cat_attr_form_id,VALUE_LIST,i,0,length,
                       (unsigned char*)text,
                       &select, &pos);

        /* write values into buffer */
        if (text == NULL)
          continue;
        else if (strcmp(text, "") == 0)
          continue;
        memset(row, NULL, new_attr->row_size);
        sprintf(row, "%s\1\1\1%s\1\1%s\1%s\1\1", 
                "NFM_STATIC", text, "S", "PDM");
        status = MEMwrite(new_list, row);
        _pdm_status("MEMwrite", status);
        if (status != MEM_S_SUCCESS)
          return(status);
        }
      if ((new_list) && (new_list->rows == 0))
        {
        MEMclose(&new_list);
        new_list = NULL;
        }
      } 
    }
  else if (func_sele)
    {
    _pdm_debug("add function for attribute", 0);
    if (PDU_cat_func_bufr == NULL)
      PDUformat_function_bufr(&PDU_cat_func_bufr);
      
    FIfld_get_text_length(forms.cat_attr_form_id,MIN_VALUE,0,0,&length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.cat_attr_form_id,MIN_VALUE,0,0,length,
                   (unsigned char*)text,&select,
                   &pos);
     if ((text) && (strcmp(text, "") != 0))
       {
       _pdm_debug("function name = <%s>", text);
      row = (char *)malloc(new_attr->row_size);
       memset(row, NULL, new_attr->row_size);
       status = PDUcheck_for_function(PDU_attr_name, &filename,
                                      PDU_cat_func_bufr);
       _pdm_status("PDUcheck_for_function", status);
       if (status == PDM_S_SUCCESS)
          {
          MEMbuild_array(PDU_cat_func_bufr);
          func_data = (char **)PDU_cat_func_bufr->data_ptr;
          for (i = 0; i < PDU_cat_func_bufr->rows; i++)
             {
             if ((func_data[(PDU_cat_func_bufr->columns * i) + 0]) &&
                 (strcmp(func_data[(PDU_cat_func_bufr->columns * i) + 0], 
                 PDU_attr_name) == 0))
              {
              _pdm_debug("Function found", 0);
              status = MEMwrite_data(PDU_cat_func_bufr, text, (i +1), 3);
              }
            }
         }
       else
         {
         sprintf(row, "%s\1\1%s\1", PDU_attr_name, text);
         status = MEMwrite(PDU_cat_func_bufr, row);
         }
       _pdm_status("MEMwrite", status);

       if (status != MEM_S_SUCCESS)
         return(PDM_E_WRITE_BUFFER);
       else
         status = PDM_S_SUCCESS;
       }
    }
    if (new_list)
    {
    /* append list_buffer to appropriate list or dyn_list buffers */ 
    _pdm_debug("Append new list buffer to cat_list buffer", 0);
    status = MEMno_buffers(*list_buffer, &no_buffers);
    _pdm_status("MEMno_buffers(list_buffer)", status);
    if ((status != MEM_S_SUCCESS) && (status != MEM_E_NULL_LIST))
      return(status);
    if ((no_buffers != 0) && (status != MEM_E_NULL_LIST))
      {
      _pdm_debug("Enter else", 0);
      status = MEMappend(new_list, *list_buffer);
      _pdm_status("MEMappend(list_buffer)", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_APPEND_BUFFER);
      attr_row = PDUfind_attr_in_buffer(new_attr, PDU_attr_name);
      no_buffers = no_buffers + 1;
      _pdm_debug("No_buffers = %d", (char *)no_buffers);
      sprintf(char_string,"%d",no_buffers);
      if ((PDU_command == PDC_M_MODIFY_CATALOG) && (change_attribute))
      status = MEMwrite_data(new_attr, char_string,(attr_row + 1) ,
                             (PDU_NFM_MOD_OFFSET + PDU_NFM_LISTNO_COL + 1));
      else
      status = MEMwrite_data(new_attr, char_string,(attr_row + 1) ,
                             (PDU_NFM_LISTNO_COL + 1));
      if (status != MEM_S_SUCCESS)
        return(status);
      }
    else if ((new_list) && (*list_buffer == NULL))
      {
      _pdm_debug("No list buffer before", 0);
      *list_buffer = new_list;
      no_buffers = 1;
      attr_row = PDUfind_attr_in_buffer(new_attr, PDU_attr_name);
      sprintf(char_string,"%d",no_buffers);
      if ((PDU_command == PDC_M_MODIFY_CATALOG) && (change_attribute))
      status = MEMwrite_data(new_attr, char_string,(attr_row + 1) ,
                             (PDU_NFM_MOD_OFFSET + PDU_NFM_LISTNO_COL + 1));
      else
      status = MEMwrite_data(new_attr, char_string,(attr_row + 1) ,
                             (PDU_NFM_LISTNO_COL + 1));
      if (status != MEM_S_SUCCESS)
        return(status);
      }
    }
    else if (new_list == NULL)
      {
      attr_row = PDUfind_attr_in_buffer(new_attr, PDU_attr_name);
      sprintf(char_string,"%d",0);
      if ((PDU_command == PDC_M_MODIFY_CATALOG) && (change_attribute))
      status = MEMwrite_data(new_attr, char_string,(attr_row + 1) ,
                             (PDU_NFM_MOD_OFFSET + PDU_NFM_LISTNO_COL + 1));
      else
      status = MEMwrite_data(new_attr, char_string,(attr_row + 1) ,
                             (PDU_NFM_LISTNO_COL + 1));
      if (status != MEM_S_SUCCESS)
        return(status);
      }
   }
   *attr_buffer = new_attr;
   *data_buffer = new_data;

   _pdm_debug("Exiting PDUchange_attribute with SUCCESS", 0);
   return(PDM_S_SUCCESS);
   } 

int PDUfill_in_mcf(attribute_buffer, data_buffer,mcf_label)

MEMptr attribute_buffer;
MEMptr data_buffer;
int mcf_label;

  {
  int status, row, col;
  char ** attribute_buffer_data = NULL;
  char ** data_buffer_data = NULL;
  char ** data_buffer_cols = NULL;
  int num_rows = 0;
  int FOUND;

  _pdm_debug("In PDUfill_in_mcf", 0);

  status = MEMbuild_array(attribute_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attribute_buffer_data = (char **)attribute_buffer->data_ptr;
  FIfld_set_max_num_rows(forms.cat_attr_form_id, mcf_label, 
                         attribute_buffer->rows);
  FIfld_set_num_rows(forms.cat_attr_form_id, mcf_label, attribute_buffer->rows);
  for (row = 0; row < attribute_buffer->rows; row ++)
    {
    FOUND = FALSE;
    for (col = 0; col < attribute_buffer->columns; col ++)
       {
       /* do not display required attributes */
       if (((!PDU_required_attr) && ((strncmp(attribute_buffer_data[(
         attribute_buffer->columns * row) + PDU_NFM_ATTR_COL], "p_", 2) == 0) ||
          (strncmp(attribute_buffer_data[(attribute_buffer->columns * row) +
           PDU_NFM_ATTR_COL], "n_", 2) == 0))) || 
          (strcmp(attribute_buffer_data[(attribute_buffer->columns * row) +
           PDU_NFM_ATTR_COL], "p_pdcno") == 0))
          {
          FOUND = TRUE;
          break;
          }

       if (col == PDU_NFM_ATTR_COL)
         {
        status = FIfld_set_text(forms.cat_attr_form_id, mcf_label, num_rows, 1, 
         attribute_buffer_data[(attribute_buffer->columns * row) + col], FALSE);
         _pdm_debug("PDU_attr_name = <%s>", 
                attribute_buffer_data[(attribute_buffer->columns * row) + col]);
         _pdm_status("FIfld_set_text", status);
         if (status != FI_SUCCESS)
           _pdm_debug("Set text failed", 0);
         }
       else if (col == PDU_NFM_SYN_COL)
         {
         if ((strcmp(attribute_buffer_data[(attribute_buffer->columns * row) +
              col], "") != 0) && (attribute_buffer_data[(attribute_buffer->
              columns * row) + col] != NULL))
           {
           if ((PDU_command == PDC_M_MODIFY_CATALOG) &&
               (strcmp(attribute_buffer_data[(attribute_buffer->columns * row)
                + col + PDU_NFM_MOD_OFFSET], "") != 0))
           {
           status = FIfld_set_text(forms.cat_attr_form_id, mcf_label, num_rows, 
                                  3, attribute_buffer_data[(attribute_buffer->
                                  columns * row) + col + PDU_NFM_MOD_OFFSET], 
                                  FALSE);
           _pdm_status("FIfld_set_text", status);
           }
           else
           {
           status = FIfld_set_text(forms.cat_attr_form_id, mcf_label, num_rows, 
                                  3, attribute_buffer_data[(attribute_buffer->
                                  columns * row) + col], FALSE);
           _pdm_status("FIfld_set_text", status);
           }
           }
         else
           {
           status = FIfld_set_text(forms.cat_attr_form_id, mcf_label, num_rows, 
                                  3, "", FALSE);
           _pdm_status("FIfld_set_text", status);
           }
         }
       else if (col == PDU_NFM_DATA_COL)
         {
        if ((PDU_command == PDC_M_MODIFY_CATALOG) &&
               (strcmp(attribute_buffer_data[(attribute_buffer->columns * row)
                + col + PDU_NFM_MOD_OFFSET], "") != 0))
          {
          status = FIfld_set_text(forms.cat_attr_form_id, mcf_label,num_rows,2, 
          attribute_buffer_data[(attribute_buffer->columns * row) + col + 
          PDU_NFM_MOD_OFFSET], FALSE);
          }
        else
          {
          status = FIfld_set_text(forms.cat_attr_form_id, mcf_label,num_rows,2, 
          attribute_buffer_data[(attribute_buffer->columns * row) + col],FALSE);
          _pdm_status("FIfld_set_text", status);
          }
         }
       else if (col == PDU_NFM_SEQNO_COL)
         {
         if ((PDU_command == PDC_M_MODIFY_CATALOG) &&
               (strcmp(attribute_buffer_data[(attribute_buffer->columns * row)
                + col + PDU_NFM_MOD_OFFSET], "") != 0))
           {
           status = FIfld_set_text(forms.cat_attr_form_id,mcf_label,num_rows,0, 
           attribute_buffer_data[(attribute_buffer->columns * row) + col + 
           PDU_NFM_MOD_OFFSET], FALSE);
           }
         else
           {
           status = FIfld_set_text(forms.cat_attr_form_id,mcf_label,num_rows,0, 
           attribute_buffer_data[(attribute_buffer->columns * row) + col], 
           FALSE);
           }
         _pdm_status("FIfld_set_text", status);
         }
       else
         _pdm_debug("Column's Info not on form", 0);
        }
      _pdm_debug("End inner for", 0);
      if (!FOUND)
        num_rows = num_rows + 1;
     }

   status = MEMbuild_array(data_buffer);
   _pdm_status("MEMbuild_array", status);

   if (status != MEM_S_SUCCESS)
     return(PDM_E_BUILD_BUFFER_ARRAY);

   data_buffer_data = (char **) data_buffer->data_ptr;
   data_buffer_cols = (char **) data_buffer->column_ptr;

   /* put any default values for the attribute in the column */
   num_rows = 0;
   for (col = 0; col < data_buffer->columns ; col ++)
     {
    if (((!PDU_required_attr) && ((strncmp(data_buffer_cols[col], "p_", 2) == 0)
         || (strncmp(data_buffer_cols[col], "n_", 2) == 0)))
         || (strcmp(data_buffer_cols[col], "p_pdcno", 2) == 0))
        {
        _pdm_debug("Required attributes not displayed", 0);
        }
      else
        {
        if ((PDU_command == PDC_M_MODIFY_CATALOG) && (data_buffer->rows == 2) &&
                (data_buffer_data[(data_buffer->columns * 1) +col] != NULL) && 
                 (strcmp(data_buffer_data[(data_buffer->columns * 1) + col], "")
                 != 0))
          { 
          status = FIfld_set_text(forms.cat_attr_form_id, mcf_label, num_rows, 
                         4, data_buffer_data[(data_buffer->columns * 1) + col],
                         FALSE);
          _pdm_status("FIfld_set_text", 0);
          }
        else if ((data_buffer_data[(data_buffer->columns * 0) +col] != NULL) && 
                 (strcmp(data_buffer_data[(data_buffer->columns * 0) + col], "")
                   != 0))
          { 
          status = FIfld_set_text(forms.cat_attr_form_id, mcf_label, num_rows, 
                         4, data_buffer_data[(data_buffer->columns * 0) + col],
                         FALSE);
          _pdm_status("FIfld_set_text", 0);
          }
        else
          FIfld_set_text(forms.cat_attr_form_id, mcf_label, num_rows, 4, "",
                         FALSE);
        num_rows = num_rows + 1;
        }
      }

   /* set max num_rows */
   if (mcf_label == ATTR_LIST)
   {
   if ((!PDU_required_attr) && (attribute_buffer->rows > 22) &&
       (PDU_view) && (PDU_command == PDC_M_MODIFY_CATALOG))
     {
     FIfld_set_max_num_rows(forms.cat_attr_form_id, mcf_label,
                            (attribute_buffer->rows - 22));
     FIfld_set_num_rows(forms.cat_attr_form_id, mcf_label,
                            (attribute_buffer->rows - 22));
     }
   else if ((!PDU_required_attr) && (attribute_buffer->rows > 30) &&
       (PDU_parm_cat) && (PDU_command == PDC_M_MODIFY_CATALOG))
     {
     FIfld_set_max_num_rows(forms.cat_attr_form_id, mcf_label,
                            (attribute_buffer->rows - 30));
     FIfld_set_num_rows(forms.cat_attr_form_id, mcf_label,
                            (attribute_buffer->rows - 30));
     }
   else if ((!PDU_required_attr) && (attribute_buffer->rows == 30) &&
       (PDU_parm_cat) && (PDU_command == PDC_M_MODIFY_CATALOG))
     {
     FIfld_set_max_num_rows(forms.cat_attr_form_id, mcf_label, 1);
     FIfld_set_num_rows(forms.cat_attr_form_id, mcf_label, 1);
     FIfld_set_text(forms.cat_attr_form_id, mcf_label, 0, 1, "", FALSE);
     }
   else if ((!PDU_required_attr) && (attribute_buffer->rows > 51))
     {
     FIfld_set_max_num_rows(forms.cat_attr_form_id, mcf_label,
                            (attribute_buffer->rows - 51));
     FIfld_set_num_rows(forms.cat_attr_form_id, mcf_label,
                            (attribute_buffer->rows - 51));
     }
   else if ((!PDU_required_attr) && (attribute_buffer->rows == 51))
     {
     FIfld_set_max_num_rows(forms.cat_attr_form_id, mcf_label,1);
     FIfld_set_num_rows(forms.cat_attr_form_id, mcf_label,1);
     FIfld_set_text(forms.cat_attr_form_id, mcf_label, 0, 1, "", FALSE);
     }
   else
     {
     FIfld_set_max_num_rows(forms.cat_attr_form_id, mcf_label, 
                            attribute_buffer->rows);
     FIfld_set_num_rows(forms.cat_attr_form_id, mcf_label, 
                            attribute_buffer->rows);
     }
   }
  else
   {
   if (attribute_buffer->rows == 0)
     {
     FIfld_set_max_num_rows(forms.cat_attr_form_id, mcf_label,1);
     FIfld_set_num_rows(forms.cat_attr_form_id, mcf_label, 1);
     FIfld_set_text(forms.cat_attr_form_id, mcf_label, 0, 1, "", FALSE);
     }
   else
     {
     FIfld_set_max_num_rows(forms.cat_attr_form_id, mcf_label, 
                            (attribute_buffer->rows - 1));
     FIfld_set_num_rows(forms.cat_attr_form_id, mcf_label, 
                            (attribute_buffer->rows - 1));
     }
   }

   return(PDM_S_SUCCESS);
   }

int PDUupdate_attr_buffer(attr_buffer,mcf_label)

MEMptr *attr_buffer;
int mcf_label;

{
  int status;
  int row, row_num = 0;
  int i; 
  int pos;
  int select;
  int length;
  char *text = NULL;
  char *PDU_attr_name = NULL;
  char *order_no = NULL;
  char **attr_data = NULL;
  int  change_attribute = FALSE;

  _pdm_debug("In PDUupdate_attr_buffer", 0);

  if ((*attr_buffer)->rows == 0)
    return(PDM_S_SUCCESS);

  status = FIfld_get_num_rows(forms.cat_attr_form_id, mcf_label, &row);
  _pdm_status("FIfld_get_num_rows", status);
  if (status != FI_SUCCESS)
    return(PDM_E_FAILURE);

  for (i = 0; i < row; i++)
    {
      status = FIfld_set_active_row(forms.cat_attr_form_id, mcf_label, i, i);
      _pdm_status("FIfld_set_active_row", status);
      FIfld_get_text_length(forms.cat_attr_form_id,mcf_label,i,0,&length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL, sizeof (char) * length + 1);
      FIfld_get_text(forms.cat_attr_form_id,mcf_label,i,0,length,
                     (unsigned char*)text,&select,
                     &pos);

       _pdm_debug("text = <%s>", text);
       PDUfill_in_string(&order_no, text);

      FIfld_get_text_length(forms.cat_attr_form_id,mcf_label,i,1,&length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL, sizeof (char) * length + 1);
      FIfld_get_text(forms.cat_attr_form_id,mcf_label,i,1,length,
                     (unsigned char*)text,&select,
                     &pos);

      _pdm_debug("text = <%s>", text);
      if (strcmp(text, "") == 0)
        break;

       PDUfill_in_string(&PDU_attr_name, text);

      _pdm_debug("find PDU_attr_name in buffer", 0);
      status = MEMbuild_array(*attr_buffer);
      _pdm_status("MEMbuild_array(attr_buffer)", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_BUILD_BUFFER_ARRAY);

      _pdm_debug("Attribute name = <%s>", PDU_attr_name);
      row_num = PDUfind_attr_in_buffer(*attr_buffer,PDU_attr_name);
      _pdm_debug("Row_num = %d", (char *)row_num);

      attr_data = (char **) (*attr_buffer)->data_ptr;
      /* check if Change Catalog, attribute was added before this session */
      if (PDU_command == PDC_M_MODIFY_CATALOG) 
        {
        if ((attr_data[((*attr_buffer)->columns * row_num) + PDU_NFM_READ_COL +
                           PDU_NFM_MOD_OFFSET] != NULL) && 
     (strcmp(attr_data[((*attr_buffer)->columns * row_num) + PDU_NFM_READ_COL +
                           PDU_NFM_MOD_OFFSET], "") != 0))
         change_attribute = TRUE;
        else
          change_attribute = FALSE;
        }

      if (row_num != -1)
        {
        _pdm_debug("order_no = <%s>", order_no);
       if ((PDU_command == PDC_M_MODIFY_CATALOG) && (change_attribute == TRUE)) 
          status = MEMwrite_data(*attr_buffer, order_no, (row_num + 1),
                                (PDU_NFM_MOD_OFFSET + PDU_NFM_SEQNO_COL + 1));
        else
          status = MEMwrite_data(*attr_buffer, order_no, (row_num + 1),
                                (PDU_NFM_SEQNO_COL + 1));
           
        _pdm_status("MEMwrite_data", status);
        if (status != MEM_S_SUCCESS)
          return(PDM_E_WRITE_BUFFER);
        }
      }
   if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

   if (PDM_debug_on)
     MEMprint_buffer("attr_buffer", *attr_buffer, PDU_DEBUG_FILE);

   _pdm_status("PDUupdate_attr_buffer returning ",status);
   return(status);
   }


int catalog_attr_form()

{
  int status;
  MEMptr cat_attr;
  MEMptr cat_data;
  MEMptr cat_list;
  MEMptr dyn_data;
  MEMptr dyn_attr;
  MEMptr dyn_list;
  MEMptr dummy_dyn_bufr = NULL;
  MEMptr table_bufr = NULL;
  char   **table_data = NULL;
  int    attr_row;
  int    acl_no;
  int    list_size;

  /* set global buffers to local buffers */
  cat_attr = (MEMptr)PDU_cat_atr;
  cat_data = (MEMptr)PDU_cat_data;
  cat_list = (MEMptr)PDU_cat_list;
  dyn_attr = (MEMptr)PDU_dyn_attr;
  dyn_data = (MEMptr)PDU_dyn_data;
  dyn_list = (MEMptr)PDU_dyn_list;

  /* set up other global variables */
  update_cat = FALSE;
  update_dyn = FALSE;

  if (PDM_debug_on)
    MEMprint_buffer("cat_attr", cat_attr, PDU_DEBUG_FILE);
 
  status = FIf_new(CATALOG_ATTR_FORM, "create_cat2", 
                cat_attr_notification_routine,
                &forms.cat_attr_form_id);

  _pdm_debug("Creating Catalog Attribute Form", 0);
  PDU_cat_attr_create = TRUE;
  
  PDU_required_attr = FALSE;

  /* see if dynamic attributes have a dyntable match */
  if (dyn_attr)
    {
    _pdm_debug("Search for a dynamic table", 0);
    status = PDUformat_search_dyntable_bufr(&dummy_dyn_bufr);
    _pdm_status("PDUformat_search_dyntable_bufr", status);

    if (status == PDM_S_SUCCESS)
      {
      /* put dynamic atributes into dummy search bufr */
      status = PDUload_search_dyntable_bufr(dyn_attr, &dummy_dyn_bufr);
      _pdm_status("PDUlaod_search_dyntable_bufr", status);

      if (status == PDM_S_SUCCESS)
        {
        /* call PDM for list of dynamic tables */
        /*status = PDMget_dyntable_for_attr(6, dummy_dyn_bufr, &table_bufr);
        _pdm_status("PDMget_dyntable_for_attr", status);*/

        if ((status == PDM_S_SUCCESS) && (table_bufr))
          {
          status = MEMbuild_array(table_bufr);
          _pdm_status("MEMbuild_array", status);

          if (status == MEM_S_SUCCESS)
            {
            table_data = (char **) table_bufr->data_ptr;
            PDUfill_in_string(&PDU_dynamic_table, table_data[0]);
            FIfld_set_text(forms.cat_attr_form_id, DYN_TABLE, 0,0,
                           PDU_dynamic_table, FALSE);
            }
         }
      }
    }
  }
  else
    {
  /* test for dynamic attributes */
  /* default dynamic table */

  FIfld_set_text(forms.cat_attr_form_id, DYN_TABLE, 0, 0, PDU_dynamic_table, 
                 FALSE);
  }
  if (PDU_view)
    {
    /* erase attribute toggles, add/delete buttons and attribute name field */
    _pdm_debug("View: Do not add user attributes", 0);
    FIfld_set_mode(forms.cat_attr_form_id, ATTRIBUTE_NAME, 0, FI_REVIEW);
    FIg_erase(forms.cat_attr_form_id, ADD_ATTR_GRP);
    }

  /* erase DYN_ATTR_LIST */
  _pdm_debug("erase dynattr list", 0);
  FIg_erase(forms.cat_attr_form_id, DYN_ATTR_LIST);
  FIg_disable(forms.cat_attr_form_id, DYN_ATTR_LIST);

  /* erase the value list field */
  _pdm_debug("erase value list field", 0);
  FIg_erase(forms.cat_attr_form_id, VALUE_LIST);

  /* disable range and value lists until PDU_datatype is entered */
  FIg_disable(forms.cat_attr_form_id, RANGE_GRP);
  FIg_disable(forms.cat_attr_form_id, VALUE_LIST);
  FIg_disable(forms.cat_attr_form_id, RANGE_TOG);
  FIg_disable(forms.cat_attr_form_id, VALUE_TOG);
  FIg_disable(forms.cat_attr_form_id, FUNCTION_TOG);
  FIg_disable(forms.cat_attr_form_id, DEFAULT_VAL);

  /* disable change attribute button */
  FIg_disable(forms.cat_attr_form_id, CHANGE_ATTR);

  static_attr = TRUE;
  dynamic_attr = FALSE;
  mcf_label = ATTR_LIST;
  range_list = TRUE;
  value_list = FALSE;
  func_sele = FALSE;

  if (PDU_command == PDC_M_CREATE_CATALOG)
  {
  _pdm_debug("Default Acl", 0);
  /* default acl_no to PDM acl */
    acl_no = 4;
    MEMbuild_array(cat_attr);
    MEMbuild_array(cat_data);
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_NFM_ACL_NO);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "6", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }

    /* default cisano to NFMFILES */
    /*attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_NFM_CISANO);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "4", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }*/

  /* default parttype to G */
  if (PDU_view)
    {
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_PARTTYPE_ATTR);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "CID", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }
    }
  else if (PDU_parm_cat)
    {
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_PARTTYPE_ATTR);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "P", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }
    }
  else
    {
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_PARTTYPE_ATTR);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "G", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }
    }

  /* default version limit to 1 */
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_NFM_VERSIONLIMIT);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "1", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }

  /* default explode in bom to Y */
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_EXPLODE_ATTR);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "Y", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }

  /* default max level of explosion to 50 */
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_MAXLEVEL_ATTR);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "50", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }
  
  /* default include part in summary */
    attr_row = PDUfind_attr_in_buffer(cat_attr, "p_incpartrpt");
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "Y", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }
 
  /* default input required column to yes for p_partnum and p_revision */ 
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_PARTID_ATTR);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_attr, "Y", (attr_row + 1), 
                             (PDU_NFM_REQ_COL + 1));
      _pdm_status("MEMwrite_data", status);
      }

    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_REVISION_ATTR);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_attr, "Y", (attr_row + 1), 
                             (PDU_NFM_REQ_COL + 1));
      _pdm_status("MEMwrite_data", status);
      }

    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_INCPARTRPT_ATTR);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_attr, "N", (attr_row + 1), 
                             (PDU_NFM_READ_COL + 1));
      status = MEMwrite_data(cat_attr, "N", (attr_row + 1), 
                             (PDU_NFM_WRITE_COL + 1));
      _pdm_status("MEMwrite_data", status);
      status = MEMwrite_data(cat_attr, "N", (attr_row + 1), 
                             (PDU_NFM_UPDATE_COL + 1));
      _pdm_status("MEMwrite_data", status);
      }
    if (PDU_parm_cat)
    {
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_NFM_VERSIONLIMIT);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_attr, "Y", (attr_row + 1), 
                             (PDU_NFM_REQ_COL + 1));
      _pdm_status("MEMwrite_data", status);
      status = MEMwrite_data(cat_attr, "N", (attr_row + 1), 
                             (PDU_NFM_WRITE_COL + 1));
      status = MEMwrite_data(cat_attr, "N", (attr_row + 1), 
                             (PDU_NFM_UPDATE_COL + 1));
      _pdm_status("MEMwrite_data", status);
      }
    }

    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_NFM_COCMT);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_attr, "N", (attr_row + 1), 
                             (PDU_NFM_WRITE_COL + 1));
      _pdm_status("MEMwrite_data", status);
      }

  }
  else if ((PDU_parm_cat) && (PDU_command == PDC_M_CREATE_LIKE_CATALOG))
    {
    MEMbuild_array(cat_attr);
    MEMbuild_array(cat_data);
    attr_row = PDUfind_attr_in_buffer(cat_attr, PDU_PARTTYPE_ATTR);
    if (attr_row != -1)
      {
      status = MEMwrite_data(cat_data, "P", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      }
    }

  PDU_cat_data = (char *)cat_data;

  /* put the buffer information in the mcf list*/

  if (cat_attr->rows > 0) 
    {
    /* order by seq */
    if (cat_attr->rows > 51)
      {
      status = PDUsort_by_order(cat_attr, cat_data, &sort_attr, &sort_data);
      _pdm_status("PDUsort_by_order", status);
      if (status != PDM_S_SUCCESS)
        status = PDUfill_in_mcf(cat_attr, cat_data, ATTR_LIST);
      else
        status = PDUfill_in_mcf(sort_attr, sort_data, ATTR_LIST);
      }
    else
      status = PDUfill_in_mcf(cat_attr, cat_data, ATTR_LIST);
    _pdm_status("PDUfill_in_mcf", status);
    }

  if (dyn_attr != NULL)
    {
    PDU_required_attr = TRUE;
    status = PDUfill_in_mcf(dyn_attr, dyn_data, DYN_ATTR_LIST);
    _pdm_status("PDUfill_in_mcf", status);
    PDU_required_attr = FALSE;
    if (PDM_debug_on)
      MEMprint_buffer("dyn_attr", dyn_attr, PDU_DEBUG_FILE);
    }
   else 
     {
     _pdm_debug("Set max Rows",0);
     FIfld_set_max_num_rows(forms.cat_attr_form_id, DYN_ATTR_LIST,1);
     }

  if ((PDU_dynamic_table) && (strcmp(PDU_dynamic_table, "") != 0))
  FIfld_set_text(forms.cat_attr_form_id, DYN_TABLE, 0, 0, PDU_dynamic_table, 
                 FALSE);
  /* Create pulldown */
  list_size = 0;
  GRcreate_pull_down_list(CATALOG_ATTR_FORM, forms.cat_attr_form_id, 
                          DYN_TABLE_ASSOC_GADGET, MAX_ROWS, VIS_ROWS,
                          PDU_value_list, list_size, 1, &PDU_value_pulldown);

  /* erase dynamic table group */
  FIg_erase(forms.cat_attr_form_id, DYN_TABLE_GRP);

  /* Display the Catalog attr form and set the displayed flag to TRUE. */

  PDU_form_id = forms.cat_attr_form_id;
  status = FIf_display(forms.cat_attr_form_id);
  PDU_cat_attr_display = TRUE;
  
  return(status); 
}

int PDUcatalog_attr_form() 

{
  int status;

  PDU_cat_attr_create = FALSE;
  PDU_cat_attr_display = FALSE;

  /* get catalog buffers initialized in global structure */
  if (PDU_cat_func_bufr)
    {
    MEMclose(&PDU_cat_func_bufr);
    PDU_cat_func_bufr = NULL;
    }
  status = PDUget_catalog_buffers(refresh->command);
  _pdm_status("PDUget_catalog_buffers", status);

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  _pdm_debug("Calling cat_attr_form", 0);
  status = catalog_attr_form();
  _pdm_status("cat_attr_form", status);
  
  return(PDM_S_SUCCESS);
}

int PDUcheck_if_datatype()
  {
  int state;

  if ((PDU_datatype != NULL) && (strcmp(PDU_datatype, "") !=0))
    {
    if ((PDU_attr_name) && (strcmp(PDU_attr_name, "") != 0) &&
        (strcmp(PDU_attr_name, "n_itemdesc") == 0))
      {
      FIg_disable(forms.cat_attr_form_id, VALUE_LIST);
      FIg_disable(forms.cat_attr_form_id, VALUE_TOG);
      }
    else
      {
      FIg_enable(forms.cat_attr_form_id, VALUE_LIST);
      FIg_enable(forms.cat_attr_form_id, VALUE_TOG);
      }
    FIg_enable(forms.cat_attr_form_id, DEFAULT_VAL);
    FIg_enable(forms.cat_attr_form_id, FUNCTION_TOG);
    if ((strcmp(PDU_datatype,"integer") != 0) && (strcmp(PDU_datatype, "real") 
         != 0) && (strcmp(PDU_datatype, "double") != 0) && 
        (strcmp(PDU_datatype, "smallint") != 0))
      {
      FIg_disable(forms.cat_attr_form_id, RANGE_GRP);
      FIg_disable(forms.cat_attr_form_id, RANGE_TOG);
      if (func_sele)
        {
        FIg_enable(forms.cat_attr_form_id, MIN_VALUE);
        FIg_display(forms.cat_attr_form_id, MIN_VALUE);
        FIg_display(forms.cat_attr_form_id, FUNCTION_TEXT);
        FIg_erase(forms.cat_attr_form_id, MIN_TEXT);
        }
      }
    else
      {
      FIg_enable(forms.cat_attr_form_id, RANGE_GRP);
      FIg_enable(forms.cat_attr_form_id, RANGE_TOG);
      }
    }
  else
    {
    FIg_disable(forms.cat_attr_form_id, RANGE_GRP);
    FIg_disable(forms.cat_attr_form_id, VALUE_LIST);
    FIg_disable(forms.cat_attr_form_id, RANGE_TOG);
    FIg_disable(forms.cat_attr_form_id, VALUE_TOG);
    FIg_disable(forms.cat_attr_form_id, FUNCTION_TOG);
    FIg_disable(forms.cat_attr_form_id, DEFAULT_VAL);
    }

  FIg_get_state(forms.cat_attr_form_id, WRITE_TOG, &state);
  if (state == 1)
    {
    FIg_disable(forms.cat_attr_form_id, RANGE_GRP);
    FIg_disable(forms.cat_attr_form_id, VALUE_LIST);
    FIg_disable(forms.cat_attr_form_id, RANGE_TOG);
    FIg_disable(forms.cat_attr_form_id, VALUE_TOG);
    FIg_disable(forms.cat_attr_form_id, DEFAULT_VAL);
    }
  return(PDM_S_SUCCESS);
  }

int PDUvalidate_default_in_range(default_value, type)
char *default_value;
char *type;

{
  int status = PDM_S_SUCCESS;
  double min_num, max_num;
  double real_min, real_max;
  double doub_min, doub_max;
  char *msg;

  _pdm_debug("validate default value in range", 0);
  if ((strcmp(type, "integer") == 0) || (strcmp(type, "smallint") == 0))
  {
  if (min_value) 
    {
     sscanf(min_value, "%lf", &min_num);
     sscanf(default_value, "%lf", &max_num);
     if (min_num > max_num)
       {
       msg = (char *)PDUtranslate_message(PDM_E_DEFAULT_LESS_MIN);
       FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
       FIg_set_text(forms.cat_attr_form_id, DEFAULT_VAL, "");
       return(PDM_E_FAILURE);
       }
     status = PDM_S_SUCCESS;
    }

  if (max_value) 
    {
     sscanf(default_value, "%lf", &min_num);
     sscanf(max_value, "%lf", &max_num);
     if (min_num > max_num)
       {
       msg = (char *)PDUtranslate_message(PDM_E_DEFAULT_GREAT_MAX);
       FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
       FIg_set_text(forms.cat_attr_form_id, DEFAULT_VAL, "");
       return(PDM_E_FAILURE);
       }
   status = PDM_S_SUCCESS;
   }
   }
  else if (strcmp(type, "real") == 0)
  {
  if (min_value) 
    {
     sscanf(min_value, "%lf", &real_min);
     sscanf(default_value, "%lf", &real_max);
     if (real_min > real_max)
       {
       msg = (char *)PDUtranslate_message(PDM_E_DEFAULT_LESS_MIN);
       FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
       FIg_set_text(forms.cat_attr_form_id, DEFAULT_VAL, "");
       return(PDM_E_FAILURE);
       }
     status = PDM_S_SUCCESS;
    }

  if (max_value) 
    {
     sscanf(default_value, "%lf", &real_min);
     sscanf(max_value, "%lf", &real_max);
     if (real_min > real_max)
       {
       msg = (char *)PDUtranslate_message(PDM_E_DEFAULT_GREAT_MAX);
       FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
       FIg_set_text(forms.cat_attr_form_id, DEFAULT_VAL, "");
       return(PDM_E_FAILURE);
       }
   status = PDM_S_SUCCESS;
   }
   }
  else
  {
  if (min_value) 
    {
     sscanf(min_value, "%lf", &doub_max);
     sscanf(default_value, "%lf", &doub_max);
     if (doub_min > doub_max)
       {
       msg = (char *)PDUtranslate_message(PDM_E_DEFAULT_LESS_MIN);
       FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
       FIg_set_text(forms.cat_attr_form_id, DEFAULT_VAL, "");
       return(PDM_E_FAILURE);
       }
     status = PDM_S_SUCCESS;
    }

  if (max_value) 
    {
     sscanf(default_value, "%lf", &doub_min);
     sscanf(max_value, "%lf", &doub_max);
     if (doub_min > doub_max)
       {
       msg = (char *)PDUtranslate_message(PDM_E_DEFAULT_GREAT_MAX);
       FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
       FIg_set_text(forms.cat_attr_form_id, DEFAULT_VAL, "");
       return(PDM_E_FAILURE);
       }
   status = PDM_S_SUCCESS;
   }
   }

  return(status);
  }

int PDUvalidate_default_in_list(default_value)
char *default_value;

  {
  int status = PDM_S_SUCCESS;
  static char   * text;
  int rows;
  int i;
  int pos;
  int select;
  int length;
  int DEFAULT_VALID = FALSE;
  char *msg;

  _pdm_debug("PDUvalidate_default_in_list", 0);

  FIfld_get_num_rows(forms.cat_attr_form_id, VALUE_LIST, &rows);
  for (i = 0; i < rows; i++)
     {
     FIfld_set_active_row(forms.cat_attr_form_id, VALUE_LIST, i,i);

     FIfld_get_text_length(forms.cat_attr_form_id,VALUE_LIST,i,0,&length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL, sizeof (char) * length + 1);
     FIfld_get_text(forms.cat_attr_form_id,VALUE_LIST,i,0,length,
                    (unsigned char*)text,&select,
                    &pos);

/* SUN */
     if ((i == 0) && (text) && (strcmp(text, "") == 0))
       {
       DEFAULT_VALID = TRUE;
       break;
       }
  else if (strcmp(default_value, text) == 0)
      {
       DEFAULT_VALID = TRUE;
       break;
       }
    }
  if (DEFAULT_VALID == FALSE)
    {
     FIg_set_text(forms.cat_attr_form_id,DEFAULT_VAL, "");
     msg = (char *)PDUtranslate_message(PDM_E_DEFAULT_VALUE);
     FIg_set_text(forms.cat_attr_form_id, FI_MSG_FIELD, msg);
     return(PDM_E_FAILURE);
    }
  else
   status = PDM_S_SUCCESS;
  return(status);
   }

int PDUload_search_dyntable_bufr(dyn_attr, new_bufr)

  MEMptr dyn_attr; /* I - dynamic attribute bufr to find */
  MEMptr *new_bufr; /* O - attributes to serach for */

  {
  int status;
  int i;
  char **attr_data = NULL;
  char *row = NULL;

  _pdm_debug("In PDUload_search_dyntable_bufr", 0);

  status = MEMbuild_array(dyn_attr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_data = (char **)dyn_attr->data_ptr;

  row = (char *)malloc((*new_bufr)->row_size);
  for (i = 0; i < dyn_attr->rows; i++)
    {
    memset(row, NULL, (*new_bufr)->row_size);
    if ((attr_data[(dyn_attr->columns * i) + PDU_NFM_SYN_COL]) && 
        (strcmp(attr_data[(dyn_attr->columns * i) + PDU_NFM_SYN_COL], "") != 0))
      sprintf(row, "%s\1%s\1%s\1", 
              attr_data[(dyn_attr->columns * i) + PDU_NFM_ATTR_COL], 
              attr_data[(dyn_attr->columns * i) + PDU_NFM_SYN_COL], 
              attr_data[(dyn_attr->columns * i) + PDU_NFM_DATA_COL]);
    else
      sprintf(row, "%s\1\1%s\1", 
              attr_data[(dyn_attr->columns * i) + PDU_NFM_ATTR_COL], 
              attr_data[(dyn_attr->columns * i) + PDU_NFM_DATA_COL]);
    status = MEMwrite(*new_bufr, row);
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      break;
    }

  if (status != MEM_S_SUCCESS)
    status = PDM_E_WRITE_BUFFER;
  else
    status = PDM_S_SUCCESS;

  return(status);
  }

