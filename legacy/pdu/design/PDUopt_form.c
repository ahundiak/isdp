#include <stdio.h>
#include <tools.h>
#include <FI.h>
#include <exdef.h>
#include <PDUforms.h>
#include <PDUform_def.h>
#include <PDUfile_def.h>
#include <PDUintdef.h>
#include <PDUstr.h>
#include <PDUassy.h>
#include <PDUproto.h>
#include <PDMproto.h>
#include <PDUrev_str.h>

/* Gadgets */

#define INC_IN_STRUCT    12
#define INC_IN_BOM       13
#define EXP_IN_BOM       14
#define ATTACH_PART      16
#define DSP_DYN_ATTR     17
#define AUTO_PART_SEL    18
#define PLACE_BY         25
#define DEFAULT_COLOR    29
#define DEFAULT_STYLE    31
#define DEFAULT_WEIGHT   33
#define DEFAULT_LAYER    35
#define USAGE_ID         38
#define VALUE_ASSOC_GAD  22
#define PLACE_BY_GRP     24
#define PLACEMENT_GRP    37
#define CHANGE_SYM_GRP   23
#define EDIT_DISPLAY     21
#define CLIPPING         26


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FIg_get_text_length();
extern int FIg_get_text();

extern struct PDUforms forms;
extern short  PDU_display_dyn_attr;
extern short  PDU_attach;
extern short  PDU_clipping_on;
extern short  PDU_edit_display;
extern short  PDU_align;
extern char   *PDU_incl_BOM;
extern char   *PDU_incl_ASM;
extern char   *PDU_explode_BOM;
extern char   *PDU_usage_id;
extern char   *PDU_value_list[605];
extern char    PDU_place_part_by;
extern char    PDU_placement_type;
extern char    PDU_align_part_by;
extern int     PDU_design_opt_create;
extern short   PDU_display_pointers;
extern int     PDU_explode_depth;
extern int     PDU_save_level;
extern int     PDU_value_pulldown;
extern int     PDU_command;
extern Form    PDU_calling_form;
extern Form    PDU_form_id;
extern Form    place_part_f;
extern Form    ModifyPartForm;
extern struct  PDUrefresh *refresh;
extern struct  PDUrev_assy *current_rev_assy;
extern struct  PDUrev_assy *PDU_assy_ptr;
extern int     PDU_default_color;
extern int     PDU_default_style;
extern int     PDU_default_weight;
extern int     PDU_default_layer;
extern int     PDU_auto_part_selection;


int design_options_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int             status;
  int             state;
  int             length;
  int             list_row;
  int             offset = 0;
  int             select = 0;
  int             pos = 0;
  int             display = 0;
  static char   * text;
  char		* msg;
  static          int place_part_by;

  switch ( g_label )
  {

    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("f_label = <%d>", (char *)f_label);
         FIf_erase(fp);

         if (place_part_f)
           {
           FIf_is_displayed(place_part_f, &display);
           if (display)
             FIf_cvrt_to_perm_win(place_part_f);
           }

         if (ModifyPartForm)
           {
           FIf_is_displayed(ModifyPartForm, &display);
           if (display)
             FIf_cvrt_to_perm_win(ModifyPartForm);
           }

         if ((PDU_calling_form == forms.design_parts_form_id) ||
             (PDU_calling_form == forms.dynamic_attr_form_id))
           {
           FIf_is_displayed(PDU_calling_form, &display);
           if (display)
             FIf_cvrt_to_perm_win(PDU_calling_form);
           }

         FIf_cvrt_to_perm_win(fp);
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("placeOpt");

         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

         FIf_delete(fp);

         if (((PDU_calling_form == forms.rev_assy_form_id) ||
              (PDU_calling_form == forms.design_parts_form_id)) &&
              (PDU_calling_form != 0))
         {
         PDU_form_id = PDU_calling_form;
         FIf_display(PDU_calling_form);
         }
         else
         {
         if (place_part_f)
           FIg_set_state_off(place_part_f, 19); 
         if (ModifyPartForm)
           FIg_set_state_off(ModifyPartForm, 19); 
         }
          

         PDUmessage(PDM_S_SUCCESS, 's');

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

         /* depending on checkbox's state flag part for attachment */
         _pdm_debug("Getting attach", 0);
         FIg_get_state(forms.design_options_form_id, ATTACH_PART, &state);
         if (state == 1)
           PDU_attach = TRUE;
          else
            PDU_attach = FALSE;

         FIg_get_state(forms.design_options_form_id, EDIT_DISPLAY, &state);
         if (state == 1)
           PDU_edit_display = TRUE;
          else
            PDU_edit_display = FALSE;

         FIg_get_state(forms.design_options_form_id, CLIPPING, &state);
         if (state == 1)
           PDU_clipping_on = TRUE;
          else
            PDU_clipping_on = FALSE;

         _pdm_debug("Getting explode", 0);
         /* depending on toggle's state set global variables */
         FIg_get_state(forms.design_options_form_id, EXP_IN_BOM, &state);
         _pdm_debug("state = %d", (char *)state);
         if (state == 1)
           PDUfill_in_string(&PDU_explode_BOM, "Y");
         else
           PDUfill_in_string(&PDU_explode_BOM, "N");

         /* depending on toggle's state set global variables */
         _pdm_debug("Getting default color", 0);
         FIg_get_state(forms.design_options_form_id, DEFAULT_COLOR, &state);
         if (state == 1)
           PDU_default_color = FALSE;
         else
           PDU_default_color = TRUE;

         /* depending on toggle's state set global variables */
         _pdm_debug("Getting default style", 0);
         FIg_get_state(forms.design_options_form_id, DEFAULT_STYLE, &state);
         if (state == 1)
           PDU_default_style = FALSE;
         else
           PDU_default_style = TRUE;

         /* depending on toggle's state set global variables */
         _pdm_debug("Getting default weight", 0);
         FIg_get_state(forms.design_options_form_id, DEFAULT_WEIGHT, &state);
         if (state == 1)
           PDU_default_weight = FALSE;
         else
           PDU_default_weight = TRUE;

         /* depending on toggle's state set global variables */
         _pdm_debug("Getting default layer", 0);
         FIg_get_state(forms.design_options_form_id, DEFAULT_LAYER, &state);
         if (state == 1)
           PDU_default_layer = FALSE;
         else
           PDU_default_layer = TRUE;

         _pdm_debug("Getting inc in BOM", 0);
         /* depending on checkbox's state set global variables */
         FIg_get_state(forms.design_options_form_id, INC_IN_BOM, &state);
         if (state == 1)
           PDUfill_in_string(&PDU_incl_BOM,"Y");
         else
           PDUfill_in_string(&PDU_incl_BOM,"N");
  
         FIg_get_state(forms.design_options_form_id, AUTO_PART_SEL, &state);
         if (state == 1)
           PDU_auto_part_selection = TRUE;
         else
           PDU_auto_part_selection = FALSE;
      
         /* depending on checkbox's state set global variables */
         FIg_get_state(forms.design_options_form_id, INC_IN_STRUCT, &state);
         if (state == 1)
           PDUfill_in_string(&PDU_incl_ASM, "Y");
         else
           PDUfill_in_string(&PDU_incl_ASM, "N");

         /* depending on checkbox's state display dyn_attr_form during placepart*/
         _pdm_debug("Getting display dynamic form", 0);
         status = FIg_get_state(forms.design_options_form_id, DSP_DYN_ATTR, 
                  &state);
         if (state == 1)
           PDU_display_dyn_attr = TRUE;
         else
           PDU_display_dyn_attr = FALSE;

         _pdm_debug("Getting place part by", 0);
         if ((PDU_calling_form != forms.rev_assy_form_id) ||
             (PDU_calling_form == 0))
           {
           FIfld_get_row_offset(fp, PLACE_BY, &offset);
           if (offset == 0)
             PDU_place_part_by = 'A';
           else if (offset == 1)
             PDU_place_part_by = 'P';
           else
             PDU_place_part_by = 'C';
  
           }

          /* Erase the displayed form */

         FIf_erase ( fp );
         FIf_delete ( fp );

         PDUmessage(PDM_S_SUCCESS, 's');
         if ((PDU_calling_form == forms.rev_assy_form_id) &&
             (PDU_calling_form != 0))
         {
         PDU_form_id = PDU_calling_form;
         FIf_display(PDU_calling_form);
         }
         else
         {
         if (place_part_f)
           FIg_set_state_off(place_part_f, 12); 
         if (ModifyPartForm)
           FIg_set_state_off(ModifyPartForm, 12); 
         }

         break;

    case INC_IN_STRUCT:     
         break;

    case INC_IN_BOM:     

         break;

    case EXP_IN_BOM:     
         break;

    case ATTACH_PART:     
         FIg_get_state(forms.design_options_form_id, ATTACH_PART, &state);
         if (state == 0)
           {
           FIg_set_state_off(fp, EDIT_DISPLAY);
           FIg_disable(fp, EDIT_DISPLAY);
           FIg_set_state_off(fp, CLIPPING);
           FIg_disable(fp, CLIPPING);
           }
         else
           {
           FIg_enable(fp, EDIT_DISPLAY);
           FIg_enable(fp, CLIPPING);
           }
         break;

    case EDIT_DISPLAY:     
         break;

    case DSP_DYN_ATTR:     

         break;

    case AUTO_PART_SEL:     

         break;

    case PLACE_BY:         /* Field Type:    ASCII    */

          place_part_by = TRUE;
          /* load value list values */
          /*PDUfill_in_string(&PDU_value_list[0], " View Alignment");
          PDUfill_in_string(&PDU_value_list[1], " 3 Points");
          PDUfill_in_string(&PDU_value_list[2], "Coordinate System");

          list_size = 3;

          GRchange_pull_down_text(PDU_value_pulldown, PDU_value_list,
                                  list_size);

          GRproc_pull_down_list(PDU_value_pulldown);*/

         break;

    case DEFAULT_COLOR:     

         break;

    case DEFAULT_STYLE:     

         break;

    case DEFAULT_WEIGHT:     

         break;

    case DEFAULT_LAYER:     

         break;

    case USAGE_ID:         /* Field Type:    ASCII    */

          /* Get the text string */

         FIfld_get_text_length(fp,USAGE_ID,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         status = FIfld_get_text(fp,USAGE_ID,0,0,length,
                                 (unsigned char*)text,&select,&pos);

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */
             FIg_set_text(forms.design_options_form_id, USAGE_ID, "");
             if (PDU_usage_id)
               PDUfill_in_string(&PDU_usage_id, NULL);
             break;
            }

          /* Code to process text string "text" */
          length = strlen(text);
          if (length > 25)
            {
            FIg_set_text(forms.design_options_form_id, USAGE_ID, "");
            msg = (char *)PDUtranslate_message(PDM_I_DEFAULT_USAGE_LENGTH);
            FIg_set_text(forms.design_options_form_id, FI_MSG_FIELD,msg);
            if ((PDU_usage_id != NULL) && (strcmp(PDU_usage_id, "") != 0))
              PDUfill_in_string(&PDU_usage_id, NULL);
            break;
            }

        /* verify the usage name is valid */
        if ((PDU_calling_form == forms.rev_assy_form_id) &&
           (PDU_calling_form != 0))
         {
         status = PDUcheck_usageid_for_rev_assy(current_rev_assy, text);
         _pdm_status("PDUcheck_usageid_for_rev_assy", status);
         if (status != PDM_S_SUCCESS)
           {
           if (status == PDM_E_UNIQUE_USAGE)
             {
             _pdm_debug("usage id is NOT unique!!", 0);
             msg = (char *)PDUtranslate_message(PDM_E_DUPLICATE_USAGEID);
             FIg_set_text(forms.design_options_form_id, FI_MSG_FIELD, msg);
             }
           PDUmessage(status, 's');
           FIg_set_text(forms.design_options_form_id, USAGE_ID, "");
           FIfld_pos_cursor(forms.design_options_form_id,USAGE_ID,0,0,0,0,1,1);
           if (PDU_usage_id)
             {
             _pdm_debug("freeing PDU_usage_id", 0);
             free(PDU_usage_id);
             PDU_usage_id = NULL;
             }
           break;
           }
         }
       else if (PDU_calling_form == 0)
         {
         status = PDUis_usage_unique(text);
         _pdm_status("PDUis_usage_unique", status);
           if (status != 1)
             {
             _pdm_debug("usage id is NOT unique!!", 0);
             PDUmessage(PDM_E_UNIQUE_USAGE, 's');
             FIg_set_text(forms.design_options_form_id, USAGE_ID, "");
             msg = (char *)PDUtranslate_message(PDM_E_DUPLICATE_USAGEID);
             FIg_set_text(forms.design_options_form_id, FI_MSG_FIELD, msg);
             if ((PDU_usage_id != NULL) && (strcmp(PDU_usage_id, "") != 0))
               PDUfill_in_string(&PDU_usage_id, NULL);
             break;
             }
          }
         


      /* put text in PDU_usage_id */
      PDUfill_in_string(&PDU_usage_id, text);

      _pdm_debug("usage id is unique", 0);
      _pdm_debug("usage_id = <%s>", PDU_usage_id);

     break;

    case VALUE_ASSOC_GAD:         /* Field Type:    ASCII    */

         list_row = value - 1;
           FIfld_set_text(fp, PLACE_BY, 0, 0,PDU_value_list[list_row], FALSE);

          break;

    case CLIPPING:
         break;

  } /* END switch ( g_label ) */
  return(1);
} /* END notification_routine() */

int design_options_form()
{
  int  status;
  int  list_size;
  char cat_type[5];
  char usageid[40];
  char *temp_usageid = NULL;

  status = FIf_new(DESIGN_OPTIONS_FORM, "placeOpt",
                design_options_notification_routine,
                &forms.design_options_form_id);

  if (status != FI_SUCCESS)
    status = PDM_E_FAILURE;

  _pdm_debug("refresh->parttype = <%s>", refresh->rev_parttype);
  if ((refresh->rev_parttype) && (strcmp(refresh->rev_parttype, "") != 0) &&
     ((strcmp(refresh->rev_parttype, "N") == 0) || 
      (strcmp(refresh->rev_parttype, "n") == 0)))
    FIg_erase(forms.design_options_form_id, ATTACH_PART);
    
  if (PDU_auto_part_selection)
    FIg_set_state_on(forms.design_options_form_id, AUTO_PART_SEL);
  else
    FIg_set_state_off(forms.design_options_form_id, AUTO_PART_SEL);
  if (PDU_attach)
    FIg_set_state_on(forms.design_options_form_id, ATTACH_PART);
  else
    {
    FIg_set_state_off(forms.design_options_form_id, ATTACH_PART);
    FIg_set_state_off(forms.design_options_form_id, CLIPPING);
    FIg_disable(forms.design_options_form_id, CLIPPING);
    FIg_set_state_off(forms.design_options_form_id, EDIT_DISPLAY);
    FIg_disable(forms.design_options_form_id, EDIT_DISPLAY);
    }

  if (PDU_clipping_on)
    FIg_set_state_on(forms.design_options_form_id, CLIPPING);
  else
    FIg_set_state_off(forms.design_options_form_id, CLIPPING);

  if (PDU_edit_display)
    FIg_set_state_on(forms.design_options_form_id, EDIT_DISPLAY);
  else
    FIg_set_state_off(forms.design_options_form_id, EDIT_DISPLAY);

  if (!PDU_default_color)
    FIg_set_state_on(forms.design_options_form_id, DEFAULT_COLOR);
  else
    FIg_set_state_off(forms.design_options_form_id, DEFAULT_COLOR);

  if (!PDU_default_style)
    FIg_set_state_on(forms.design_options_form_id, DEFAULT_STYLE);
  else
    FIg_set_state_off(forms.design_options_form_id, DEFAULT_STYLE);

  if (!PDU_default_weight)
    FIg_set_state_on(forms.design_options_form_id, DEFAULT_WEIGHT);
  else
    FIg_set_state_off(forms.design_options_form_id, DEFAULT_WEIGHT);

  if (!PDU_default_layer)
    FIg_set_state_on(forms.design_options_form_id, DEFAULT_LAYER);
  else
    FIg_set_state_off(forms.design_options_form_id, DEFAULT_LAYER);

  if (PDU_incl_BOM == NULL)
    PDUfill_in_string(&PDU_incl_BOM, "Y");
  else if (strcmp(PDU_incl_BOM, "") == 0)
    PDUfill_in_string(&PDU_incl_BOM, "Y");

  if (strcmp(PDU_incl_BOM,"Y") == 0)
    FIg_set_state_on(forms.design_options_form_id, INC_IN_BOM);
  else
    FIg_set_state_off(forms.design_options_form_id, INC_IN_BOM);

  if (PDU_explode_BOM == NULL)
    PDUfill_in_string(&PDU_explode_BOM, "Y");
  else if (strcmp(PDU_explode_BOM, "") == 0)
    PDUfill_in_string(&PDU_explode_BOM, "Y");

  if (strcmp(PDU_explode_BOM, "Y") == 0)
    FIg_set_state_on(forms.design_options_form_id, EXP_IN_BOM);
  else
    FIg_set_state_off(forms.design_options_form_id, EXP_IN_BOM);

  if (PDU_incl_ASM == NULL)
    PDUfill_in_string(&PDU_incl_ASM, "Y");
  else if (strcmp(PDU_incl_ASM, "") == 0)
    PDUfill_in_string(&PDU_incl_ASM, "Y");

  if (strcmp(PDU_incl_ASM, "Y") == 0)
    FIg_set_state_on(forms.design_options_form_id, INC_IN_STRUCT);
  else
    FIg_set_state_off(forms.design_options_form_id, INC_IN_STRUCT);

  if (PDU_display_dyn_attr)
    FIg_set_state_on(forms.design_options_form_id, DSP_DYN_ATTR);
  else
    FIg_set_state_off(forms.design_options_form_id, DSP_DYN_ATTR);

  if (PDU_place_part_by == 'A')
    FIfld_set_active_row(forms.design_options_form_id, PLACE_BY, 0, 0);
  else if (PDU_place_part_by == 'P')
    FIfld_set_active_row(forms.design_options_form_id, PLACE_BY, 1, 0);
  else
    FIfld_set_active_row(forms.design_options_form_id, PLACE_BY, 2, 0);

  _pdm_debug("Creating Design Options Form", 0);
  PDU_design_opt_create = TRUE;

  /* create pulldown for place part by field */
     list_size = 0;
  _pdm_debug("Creating pull_down_list", 0);
   GRcreate_pull_down_list(DESIGN_OPTIONS_FORM, forms.design_options_form_id,
                 VALUE_ASSOC_GAD,MAX_ROWS,VIS_ROWS,PDU_value_list, list_size,
                  1, &PDU_value_pulldown);

  /* get catalog type */
  _pdm_debug("calling PDMquery_catalog_type", 0);
  _pdm_debug("catalog = <%s>", refresh->rev_catalog);
  if (refresh->rev_catalog)
    {
    status = PDMquery_catalog_type(refresh->rev_catalog,cat_type);
    _pdm_status("PDMquery_catalog_type", status);
    }
  else
    {
    cat_type[0] = '\0';
    strcpy(cat_type, "");
    }
 
  /* check parttype for form gadget display */
  _pdm_debug("checking cat_type", 0);
  if ((strcmp(cat_type, "P") == 0) ||
      (strcmp(cat_type, "EID") == 0) ||
      (strcmp(cat_type, "PXT") == 0) ||
      (strcmp(cat_type, "CID") == 0))
    {
    FIg_erase(forms.design_options_form_id, ATTACH_PART);
    FIg_erase(forms.design_options_form_id, EDIT_DISPLAY);
    FIg_erase(forms.design_options_form_id, CLIPPING);
    FIg_erase(forms.design_options_form_id, PLACE_BY_GRP);
    FIg_erase(forms.design_options_form_id, PLACEMENT_GRP);
    }
  else 
    {
    FIg_erase(forms.design_options_form_id, PLACEMENT_GRP);
    FIg_erase(forms.design_options_form_id, AUTO_PART_SEL);
    FIg_erase(forms.design_options_form_id, CHANGE_SYM_GRP);
    }

 if (PDU_command == PDC_M_POSITION_PARTS)
   {
   _pdm_debug("SKip default",0);
   strcpy(usageid, PDU_usage_id);
   FIg_erase(forms.design_options_form_id, DSP_DYN_ATTR);
   }
else
  {
  _pdm_debug("checking usageid", 0);
  if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
    PDUfill_in_string(&PDU_usage_id, "");

  /* initialize usageid */
  strcpy(usageid, "");
 
 if ((PDU_calling_form == forms.rev_assy_form_id) && (PDU_calling_form != 0))
   {
   _pdm_debug("processing for forms.rev_assy_form_id", 0);
   if (!current_rev_assy)
     current_rev_assy = PDU_assy_ptr;
   _pdm_debug("catalog = <%s>", current_rev_assy->new_catalog);
   if (strlen(current_rev_assy->new_catalog))
     {
     _pdm_debug("calling PDMget_usageid_cat", 0);
     status = PDMget_usageid_cat(current_rev_assy->new_catalog, &temp_usageid);
     _pdm_status("PDUget_usageid_cat", status);

     _pdm_debug("temp_usage = <%s>", temp_usageid);

     if ((temp_usageid) && (strcmp(temp_usageid, "") != 0))
       strcpy(usageid, temp_usageid);
     else
       strcpy(usageid, "");
     }
   }
 else if ((PDU_calling_form != forms.rev_assy_form_id) && 
          (PDU_calling_form != 0))
   {
   status = PDUget_default_usage_id(refresh->rev_catalog,NULL, NULL, usageid);
   _pdm_status("PDUget_default_usageid", status);
   }
 }
 
   if ((usageid != NULL) && (strcmp(usageid, "") != 0))
     {
     _pdm_debug("usageid = <%s>", usageid);
     PDUfill_in_string(&PDU_usage_id, usageid);
     FIg_set_text(forms.design_options_form_id, USAGE_ID, PDU_usage_id); 
     }

  /* disable gadgets that do not apply to the assembly structure form */
  if ((PDU_calling_form == forms.rev_assy_form_id) && (PDU_calling_form != 0))
    {
    _pdm_debug("erasing gadgets", 0);
    FIg_erase(forms.design_options_form_id, PLACE_BY);
    FIg_erase(forms.design_options_form_id, 20);
    FIg_erase(forms.design_options_form_id, EDIT_DISPLAY);
    FIg_erase(forms.design_options_form_id, ATTACH_PART);
    FIg_erase(forms.design_options_form_id, CLIPPING);
    }

  /* add tag no to usageid */
  FIf_set_orig_coord(forms.design_options_form_id, 572, 406);
  status = FIf_display(forms.design_options_form_id);

  return(status);
}

int PDUdesign_options_form()

{
  int status;

  PDU_design_opt_create = FALSE;

  _pdm_debug("Calling design_options_form", 0);
  status = design_options_form();
  _pdm_status("design_options_form", status);
  if (status == FI_SUCCESS)
    status = PDM_S_SUCCESS;
  return(status);
}

