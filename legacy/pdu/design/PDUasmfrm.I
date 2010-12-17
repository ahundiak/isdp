class implementation COpdu;

#include <stdio.h>
#include "FI.h"
#include "exdef.h"
#include "gr.h"
#include "grdpbmacros.h"
#include "PDUforms.h"
#include "PDUform_def.h"
#include "PDUerror.h"
#include "PDUcommand.h"
#include "PDUstr.h"
#include "PDUfile_def.h"
#include "PDUgrpart.h"
#include "MEMerrordef.h"


/* Gadgets */

#define ASSEMBLY_MCF  33
#define DEPTH         23
#define GROUP1        40
#define GROUP2        11
#define GROUP3        14
#define GROUP4        19
#define GROUP5        20
#define GROUP6        29
#define GROUP7        21
#define GROUP8        38
#define GROUP9        22
#define GROUP10       25
#define GROUP11       13
#define LOCATE        41
#define GROUP12       28
#define SET_ALL       26
#define CLEAR_ALL     27


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();

extern struct PDUforms forms;
extern int PDM_debug_on;
%safe
static MEMptr assy_bufr = NULL;
static MEMptr save_assy_bufr = NULL;
static double display_level = 0;
static double max_display_level = 0;
%endsafe
static short put_on_queue;
static int static_call_command;
static struct GRmd_env *static_mod_env;

void assembly_display_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
 int status;
 int responses[1];
 char *strings[1];

  switch ( g_label )
  {
    case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */

         break;

    case FI_HELP:

         FIf_cvrt_to_perm_win(fp);
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */

         FIf_erase ( fp );
         FIf_delete ( fp );
         forms.assembly_display_form_id = 0;

         if (put_on_queue)
           {
           responses[0] = RESET;
           strings[0] = "";
           PDUprepare_queue(responses, strings, 1);
           }

          /* ALR  1/4/94  TR 139315082 */
           /* Display Design operations form if not checkout */

           if ((static_call_command != PDC_M_CHECKOUT) && 
               (static_call_command != -1))
              PDUdisplay_design_form();

         break;

    case FI_RESET:     /* Member of group FI_CTRL_GROUP */

         FIg_reset(fp, g_label);
         if (assy_bufr)
           {
           MEMclose(&assy_bufr);
           assy_bufr = NULL;
           }
         MEMsplit_copy_buffer(save_assy_bufr, &assy_bufr, 0);
         display_level = max_display_level;
         FIg_set_value(forms.assembly_display_form_id, DEPTH, 
                       max_display_level);
         PDUload_assembly_display_mcf(assy_bufr, max_display_level);
         PDUhighlight_assembly_rows();
         break;

    case FI_EXECUTE:     /* Member of group FI_CTRL_GROUP */

        /* Process form data */
        status = PDUprocess_assembly_display_information(assy_bufr, 
                                                         display_level);
        _pdm_status("PDUprocess_assembly_display_information", status);

         if (PDM_debug_on)
           MEMprint_buffer("assembly_buffer", assy_bufr, PDU_DEBUG_FILE);
         if (save_assy_bufr)
           {
           MEMclose(&save_assy_bufr);
           save_assy_bufr = NULL;
           }
         MEMsplit_copy_buffer(assy_bufr, &save_assy_bufr, 0);
         if (!put_on_queue)
           {
           status = PDUprocess_assembly_display(NULL, assy_bufr, TRUE,TRUE,
                                                TRUE);
           _pdm_status("PDUprocess_assembly_display", status);
           }
         else
           {
           if (static_call_command != PDC_M_CHECKOUT)
             status = PDUprocess_assembly_display(static_mod_env, assy_bufr, 
                                                  TRUE,TRUE, TRUE);
           else
             status = PDUprocess_assembly_display(static_mod_env, assy_bufr, 
                                                  TRUE,FALSE, TRUE);
             _pdm_status("PDUprocess_assembly_display", status);
           }

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */

         FIf_erase ( fp );

        /* Process form data */
        status = PDUprocess_assembly_display_information(assy_bufr, 
                                                         display_level);
        _pdm_status("PDUprocess_assembly_display_information", status);

         FIf_delete(fp);
         forms.assembly_display_form_id = 0;
         if (PDM_debug_on)
           MEMprint_buffer("assembly_buffer", assy_bufr, PDU_DEBUG_FILE);
         if (!put_on_queue)
           {
           status = PDUprocess_assembly_display(NULL, assy_bufr, TRUE,TRUE,
                                                TRUE);
           _pdm_status("PDUprocess_assembly_display", status);
           }
         else
           {
           if (static_call_command == -1)
             status = PDUprocess_assembly_display(static_mod_env, assy_bufr, 
                                                  TRUE,TRUE, FALSE);
           else if (static_call_command != PDC_M_CHECKOUT)
             status = PDUprocess_assembly_display(static_mod_env, assy_bufr, 
                                                  TRUE,TRUE, TRUE);
           else
             status = PDUprocess_assembly_display(static_mod_env, assy_bufr, 
                                                  TRUE,FALSE, TRUE);
             _pdm_status("PDUprocess_assembly_display", status);
           if (status != PDM_S_SUCCESS)
             responses[0] = RESET;
           else
             responses[0] = MOVE_ON;
           strings[0] = "";
           PDUprepare_queue(responses, strings, 1);
           }

          /* ALR  1/4/94  TR 139315082 */
           /* Display Design operations form if not checkout */

           if ((static_call_command != PDC_M_CHECKOUT) && 
               (static_call_command != -1))
              PDUdisplay_design_form();

         break;

    case ASSEMBLY_MCF:     /* Sequenced to     */

         PDUprocess_assembly_mcf(assy_bufr, display_level);

         break;

    case DEPTH:     /* Sequenced to     */

         _pdm_debug("value = %lf", value);
        if (display_level != value)
        {
        status = PDUprocess_assembly_display_information(assy_bufr, 
                                                         display_level);
        _pdm_status("PDUprocess_assembly_display_information", status);

        FIg_reset(fp, ASSEMBLY_MCF);
        display_level = value;
        PDUload_assembly_display_mcf(assy_bufr, display_level);
        PDUhighlight_assembly_rows();
        }

         break;

    case LOCATE:     /* Sequenced to     */

         break;

    case SET_ALL:
         
         PDUtoggle_assembly_display(TRUE);
         FIg_set_state_off(fp, g_label);

         break;

    case CLEAR_ALL:

         PDUtoggle_assembly_display(FALSE);
         FIg_set_state_off(fp, g_label);

         break;

  } /* END switch ( g_label ) */

} /* END notification_routine() */

int PDUassembly_display_form(mod_env, assembly_buffer, put_queue, call_command)
struct GRmd_env *mod_env;
MEMptr assembly_buffer;
short put_queue;
int call_command;

  {
  IGRlong    NumberOfBytes, BytesReceived;
  IGRlong    msg;

  _pdm_debug("PDUassembly_display_form", 0);
  put_on_queue = put_queue;
  static_mod_env = mod_env;
  static_call_command = call_command;
  if (static_mod_env == NULL)
    {
    static_mod_env = (struct GRmd_env *)malloc(sizeof(struct GRmd_env));
    NumberOfBytes = sizeof(struct GRmd_env);
    gr$get_module_env(msg = &msg, sizbuf = &NumberOfBytes, 
                      buffer = static_mod_env, 
                      nret = &BytesReceived);
    }
  if (assembly_buffer == NULL)
    return(PDM_E_PART_NOT_ASSEMBLY);
  else if (assembly_buffer->rows == 0)
    return(PDM_E_PART_NOT_ASSEMBLY);
  else if (assembly_buffer->rows == 1)
    return(PDM_E_PART_NOT_ASSEMBLY);
  
  if (assy_bufr)
    {
    MEMclose(&assy_bufr);
    assy_bufr = NULL;
    }
  if (save_assy_bufr)
    {
    MEMclose(&save_assy_bufr);
    save_assy_bufr = NULL;
    }
  _pdm_debug("Before MEMsplit_copy", 0);
  MEMsplit_copy_buffer(assembly_buffer, &assy_bufr, 0);
  MEMsplit_copy_buffer(assembly_buffer, &save_assy_bufr, 0);
  _pdm_debug("Before FIf_new", 0);
  FIf_new(ASSEMBLY_DISPLAY_FORM, "asmdisplay.fm", 
          assembly_display_notification_routine,
          &forms.assembly_display_form_id);
  _pdm_debug("Before PDUfind_display_level", 0);
  PDUfind_display_level(assembly_buffer, &display_level);
  max_display_level = display_level;
  FIg_set_high_value(forms.assembly_display_form_id, DEPTH, max_display_level);
  FIg_set_value(forms.assembly_display_form_id, DEPTH, max_display_level);
  _pdm_debug("max_display_level = %lf", max_display_level);
  _pdm_debug("command = <%d>", call_command);
  PDUload_assembly_display_mcf(assembly_buffer, display_level);
  PDUhighlight_assembly_rows();
  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  FIf_display(forms.assembly_display_form_id);
  return(PDM_S_SUCCESS);
  }

int PDUhighlight_assembly_rows()

  {
  int i;
  int length;
  int select;
  int pos;
  int num_rows;
  char *text = NULL;
  
  _pdm_debug("In PDUhighlight_assembly_rows", 0);

  FIfld_get_num_rows(forms.assembly_display_form_id, ASSEMBLY_MCF, &num_rows);
  _pdm_debug("num_rows = <%d>", (char *)num_rows);

  for (i = 0; i < num_rows; i++)
    {
    FIfld_set_active_row(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 0);
    FImcf_set_active_col(forms.assembly_display_form_id, ASSEMBLY_MCF, 4, 4);
    FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 4, 
                          &length);
    text = (char *)malloc(length + 1);
    memset(text, NULL, (length + 1));
    FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 4, length, 
                   (unsigned char*)text, &select, &pos);
    if (strcmp(text, "on") == 0)
      select = TRUE;
    else
      select = FALSE;

    FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 0, 
                     select);
    FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 1, 
                     select);
    FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 2, 
                     select);
    FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 3, 
                     select);
    FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 4, 
                     select);
    if (text)
      free(text);
    }
  FIfld_set_active_row(forms.assembly_display_form_id, ASSEMBLY_MCF,0,0);
  return(PDM_S_SUCCESS);
  }

int PDUprocess_assembly_mcf(assy_bufr, display_level)
MEMptr assy_bufr;
double display_level;
  {
  short assembly = FALSE;
  short child_selected = FALSE;
  int act_row;
  int act_col;
  int sel_flag;
  int pos;
  int length;
  int select;
  int i;
  int num_rows;
  int row;
  int temp_level;
  int text_level;
  int level1_row = 0;
  int status;
  int num_assem_rows = 0;
  char *text = NULL;
  char *level = NULL;
  char *display_text = NULL;
  
  _pdm_debug("In PDUprocess_assembly_mcf", 0);
  FIfld_get_active_row(forms.assembly_display_form_id, ASSEMBLY_MCF, &act_row,
                       &pos);
  FImcf_get_active_col(forms.assembly_display_form_id, ASSEMBLY_MCF, &act_col, 
                       &pos);
  /* JBP - support not longer needed since parent needs to be displayed also
  if (act_col == 4)
    {
    _pdm_debug("User selected display column", 0);
    FIfld_get_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row, 
                     act_col, &sel_flag);
    if (sel_flag)
      {
      FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row, 
                     act_col, "on", TRUE);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row,
                       0, TRUE);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row,
                       1, TRUE);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row,
                       2, TRUE);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row,
                       3, TRUE);
      }
    else
      {
      FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row, 
                     act_col, "off", FALSE);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row,
                       0, FALSE);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row,
                       1, FALSE);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row,
                       2, FALSE);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row,
                       3, FALSE);
      }
    }
  else
    {*/
    _pdm_debug("Highlight/unhighlight any additional rows of the assembly", 0);
    FIfld_get_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row, 
                     act_col, &sel_flag);
    if (sel_flag)
      PDUfill_in_string(&display_text, "on");
    else
      PDUfill_in_string(&display_text, "off");
    FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF, 
                          act_row, 0, &length);
    level = (char *)malloc(sizeof (char) * length + 1);
    memset(level, NULL, (length + 1));
    FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row, 0, 
                   length, (unsigned char*)level, &sel_flag, &pos);
    _pdm_debug("level = <%s>", level);
    FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row, 
                   4, display_text, sel_flag);
    FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row, 
                     0, sel_flag);
    FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row, 
                     1, sel_flag);
    FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row, 
                     2, sel_flag);
    FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, act_row, 
                     3, sel_flag);
    FIfld_get_num_rows(forms.assembly_display_form_id, ASSEMBLY_MCF, &num_rows);
    for (i = 0; i < (act_row + 1); i ++)
      {
      length = 0;
      FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF, 
                            i, 0, &length);
      text = (char *)malloc(sizeof (char) * length + 1);
      memset(text, NULL, (length + 1));
      FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 0, 
                     length, (unsigned char*)text, &select, &pos);
      _pdm_debug("text = <%s>", text);
      if (strcmp(text, "1") == 0)
        level1_row = i;
      }
    if ((level1_row != act_row) && (sel_flag))
      {
      _pdm_debug("setting flag for top level part", 0);
      FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row, 
                     4, display_text, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row,
                       0, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row,
                       1, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row,
                       2, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row,
                       3, sel_flag);
      }
/* 5/25/95 MJG - Search backwards for parent parts */
    _pdm_debug("start level = <%s>", level);
    sscanf(level, "%d", &temp_level);
    for (i = act_row - 1; i >= 0; -- i)
      {
      if (child_selected)
        {
        _pdm_debug("parent part still has a child selected:  break", 0);
        break;
        }

      length = 0;
      FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF, 
                            i, 0, &length);
      text = (char *)malloc(sizeof (char) * length + 1);
      memset(text, NULL, (length + 1));
      FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 0, 
                     length, (unsigned char*)text, &select, &pos);
      _pdm_debug("text = <%s>", text);
      sscanf(text, "%d", &text_level);
      if (text_level > temp_level)
        {
        _pdm_debug("text > level:  continue", 0);
        continue;
        }
      if (temp_level == text_level)
        {
        _pdm_debug("level == text:  continue", 0);
        continue;
        }
      else if (strcmp(text, "1") == 0)
        {
        _pdm_debug("text = 1:  break", 0);
        break;
        }
      else if (text_level <= temp_level)
        {
        _pdm_debug("parent part found, resetting level", 0);
        --temp_level;
        _pdm_debug("temp_level = <%d>", (char *)temp_level);

        if (!sel_flag)
          {
          _pdm_debug("check for other selected child parts", 0);
          for (row = i + 1; row < num_rows; ++row)
             {
             child_selected = FALSE;
             FIfld_get_text_length(forms.assembly_display_form_id, 
                                   ASSEMBLY_MCF, row, 0, &length);
             text = (char *)malloc(sizeof (char) * length + 1);
             memset(text, NULL, (length + 1));
             FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, row,
                            0, length, (unsigned char*)text, &select, &pos);
             _pdm_debug("text = <%s>", text);
             sscanf(text, "%d", &text_level);

             if (text_level <= temp_level)
               {
               _pdm_debug("part does not have children", 0);
               break;
               }
             if (text_level > temp_level + 1)
               continue;
             if (text_level == temp_level + 1)
               {
               _pdm_debug("child part found", 0);
               FIfld_get_select(forms.assembly_display_form_id, 
                                ASSEMBLY_MCF, row, act_col, &select);
               if (select)
                 {
                 _pdm_debug("child part is ON: break", 0);
                 child_selected = TRUE;
                 break;
                 }
               }
             }
          }
        }
      if (!child_selected)
        {
        _pdm_debug("setting flag for parent part, row = %d", (char *)i);
        FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 
                       4, display_text, sel_flag);
        FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 
                         0, sel_flag);
        FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 
                         1, sel_flag);
        FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 
                         2, sel_flag);
        FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 
                         3, sel_flag);
        }
      }
    _pdm_debug("searching for child parts", 0);
    num_assem_rows = 0;
    for (i = (act_row + 1); i < num_rows; i ++)
      {
      length = 0;
      FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF, 
                            i, 0, &length);
      text = (char *)malloc(sizeof (char) * length + 1);
      memset(text, NULL, (length + 1));
      FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 0, 
                     length, (unsigned char*)text, &select, &pos);
      _pdm_debug("text = <%s>", text);
      _pdm_debug("level = <%s>", level);
      sscanf(text, "%d", &text_level);
      sscanf(level, "%d", &temp_level);
      if (strcmp(level, text) == 0)
        {
        _pdm_debug("level == text:  break", 0);
        break;
        }
      else if (strcmp(text, "1") == 0)
        {
        _pdm_debug("text = 1:  break", 0);
        break;
        }
      else if (text_level <= temp_level)
        {
        _pdm_debug("text_level <= temp_level", 0);
        break;
        }
      assembly = TRUE;
      num_assem_rows = num_assem_rows + 1;
      _pdm_debug("setting flag for child parts", 0);
      FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 
                     4, display_text, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 
                       0, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 
                       1, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 
                       2, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 
                       3, sel_flag);
      }

    _pdm_debug("num_assem_rows = %d", (char *)num_assem_rows);
    if (assembly)
      {
      status = PDUfind_nested_assemblies(assy_bufr, display_level, act_row, 
                                         display_text, num_assem_rows);
      _pdm_status("PDUfind_nested_assemblies", status);
      }
    else if (strcmp(level, "1") != 0)
      {
      status = PDUfind_matching_refids(assy_bufr, display_level, act_row, 
                                       display_text);
      _pdm_status("PDUfind_matching_refids", status);
      }
   
    if ((text) && (strcmp(text, "") != 0))
      free(text);
    if ((level) && (strcmp(level, "") != 0))
      free(level);
    if ((display_text) && (strcmp(display_text, "") != 0))
      free(display_text);
    /*}*/
  return(PDM_S_SUCCESS);
  }

int PDUtoggle_assembly_display(sel_flag)

int sel_flag;

  {
  int i;
  int num_rows;
  char *display_text = NULL;

  _pdm_debug("PDUtoggle_assembly_display", 0);
  if (sel_flag)
    PDUfill_in_string(&display_text, "on");
  else
    PDUfill_in_string(&display_text, "off");

  FIfld_get_num_rows(forms.assembly_display_form_id, ASSEMBLY_MCF, &num_rows);
  for (i = 0; i < num_rows; i++)
    {
    FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 4, 
                   display_text, sel_flag);
    }
  PDUhighlight_assembly_rows();
  return(PDM_S_SUCCESS);
  } 

int PDUprocess_assembly_display_information(assembly_bufr, display_level)

MEMptr assembly_bufr;
double display_level;

  {
  int status;
  int i;
  int length;
  int pos;
  int select;
  int attached_col;
  int delete_col;
  int level_col;
  int parttype_col;
  int usageid_col;
  int refid_col;
  int num_rows;
  int temp_level;
  int asm_level;
  int start_row = 1;
  int count = 0;
  short positionless_part = FALSE;
  char *text = NULL;
  char **assembly_data = NULL;
  struct PDUpart_node *parts_id = NULL;
  
  _pdm_debug("PDUprocess_assembly_display_information", 0);
  if (assembly_bufr == NULL)
    return(PDM_E_PART_NOT_ASSEMBLY);
  else if (assembly_bufr->rows == 0)
    return(PDM_E_PART_NOT_ASSEMBLY);

  status = MEMbuild_array(assembly_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
  PDUget_all_GRpart_ids(static_mod_env->md_id.osnum, &parts_id, &count);
  PDUget_buffer_col(assembly_bufr, "p_refid", &refid_col);
  PDUget_buffer_col(assembly_bufr, "p_attached", &attached_col);
  PDUget_buffer_col(assembly_bufr, "p_delete", &delete_col);
  PDUget_buffer_col(assembly_bufr, "p_level", &level_col);
  PDUget_buffer_col(assembly_bufr, "p_parttype", &parttype_col);
  PDUget_buffer_col(assembly_bufr, "p_usageid", &usageid_col);
  assembly_data = (char **)assembly_bufr->data_ptr;
  assembly_data = (char **)assembly_bufr->data_ptr;
  num_rows = 0;
  if (static_call_command == PDC_M_PLACE_PART)
    start_row = 0;
  for (i = start_row; i < assembly_bufr->rows; i++)
    {
     if (((assembly_data[(assembly_bufr->columns * i) + parttype_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i) + 
              parttype_col], "P") == 0)) || 
              ((assembly_data[(assembly_bufr->columns * i) + parttype_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i) +
              parttype_col], "N") == 0)))
       continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") == 0) && (PDUis_part_positionless(static_mod_env, parts_id, 
              assembly_data[(assembly_bufr->columns * i) + usageid_col])))
       {
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") == 0) && 
              (strcmp(assembly_data[(assembly_bufr->columns * i) + 
               usageid_col], "") == 0))
       {
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") != 0) && (positionless_part))
       continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + refid_col]) &&
         (strcmp(assembly_data[(assembly_bufr->columns * i) + refid_col],
         "-1") == 0))
        continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + delete_col]) &&
         (strcmp(assembly_data[(assembly_bufr->columns * i) + delete_col], 
         "N") == 0))
     {
     positionless_part = FALSE;
    sscanf(assembly_data[(assembly_bufr->columns * i) + level_col], "%d", 
           &asm_level);
    if (asm_level > display_level)
      continue;
    length = 0;
    FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF,
                          num_rows, 0, &length);
    text = (char *)malloc(sizeof(char *) * length + 1);
    memset(text, NULL, (length + 1));
    FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 0,
                   length,(unsigned char*)text, &select, &pos);
    _pdm_debug("text = <%s>", text);
    if (strcmp(text, "") == 0)
      continue;  
    sscanf(text, "%d", &temp_level);
    if (text)
      free(text);
    _pdm_debug("temp_level = %d", temp_level);
    if (temp_level <= display_level)
      {
      length = 0;
      FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF, 
                            num_rows, 4, &length);
      text = (char *)malloc(sizeof(char *) * length + 1);
      memset(text, NULL, (length + 1));
      FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 4, 
                     length, (unsigned char*)text, &select, &pos);
      if (strcmp(text, "on") == 0)
        status = MEMwrite_data(assembly_bufr, "Y", (i + 1), (attached_col + 1));
      else
        status = MEMwrite_data(assembly_bufr, "N", (i + 1), (attached_col + 1));
      _pdm_status("MEMwrite_data", status);
      if (text)
        free(text);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_WRITE_BUFFER);
      num_rows = num_rows + 1;
      }
     }
    }
  return(PDM_S_SUCCESS);
  }

int PDUfind_display_level(assembly_buffer, display_level)

MEMptr assembly_buffer;
double *display_level;

  {
  int status;
  int i;
  int level_col;
  double level = 1;
  double text_level = 1;
  char **assembly_data = NULL;

  _pdm_debug("In PDUfind_display_level", 0);
  status = MEMbuild_array(assembly_buffer);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
  PDUget_buffer_col(assembly_buffer, "p_level", &level_col);
  assembly_data = (char **)assembly_buffer->data_ptr;
  for (i = 1; i < assembly_buffer->rows; i++)
    {
    sscanf(assembly_data[(assembly_buffer->columns * i) + level_col], "%lf", 
           &text_level);
    if (text_level > level)
      level = text_level;
    }
  *display_level = level;
  return(PDM_S_SUCCESS);
  }

int PDUload_assembly_display_mcf(assembly_buffer, display_level)

MEMptr assembly_buffer;
double display_level;

  {
  int status;
  int i;
  int start_row = 1;
  int level_col, itemname_col, itemrev_col, itemdesc_col, attach_col;
  int usageid_col, delete_col, parttype_col;
  int refid_col;
  int part_length;
  int usageid_length;
  int num_rows;
  int count = 0;
  int temp_level;
  short positionless_part = FALSE;
  char *text = NULL;
  char *msg = NULL;
  char **assembly_data = NULL;
  struct PDUpart_node *parts_id = NULL;

  _pdm_debug("PDUload_assembly_display_level", 0);
  
   status = MEMbuild_array(assembly_buffer);
   _pdm_status("MEMbuild_array", status);
   if (status != MEM_S_SUCCESS)
     return(PDM_E_BUILD_BUFFER_ARRAY);

   PDUget_all_GRpart_ids(static_mod_env->md_id.osnum, &parts_id, &count);
   PDUget_buffer_col(assembly_buffer, "p_level", &level_col);
   PDUget_buffer_col(assembly_buffer, "n_itemname", &itemname_col);
   PDUget_buffer_col(assembly_buffer, "n_itemrev", &itemrev_col);
   PDUget_buffer_col(assembly_buffer, "n_itemdesc", &itemdesc_col);
   PDUget_buffer_col(assembly_buffer, "p_attached", &attach_col);
   PDUget_buffer_col(assembly_buffer, "p_usageid", &usageid_col);
   PDUget_buffer_col(assembly_buffer, "p_delete", &delete_col);
   PDUget_buffer_col(assembly_buffer, "p_refid", &refid_col);
   PDUget_buffer_col(assembly_buffer, "p_parttype", &parttype_col);

   assembly_data = (char **)assembly_buffer->data_ptr;
   num_rows = 0;
   if (static_call_command == PDC_M_PLACE_PART)
     start_row = 0; 
   for (i = start_row; i < assembly_buffer->rows; i++)
     {
     if (((assembly_data[(assembly_buffer->columns * i) + parttype_col]) &&
          (strcmp(assembly_data[(assembly_buffer->columns * i) + 
           parttype_col], "P") == 0)) || 
          ((assembly_data[(assembly_buffer->columns * i) + parttype_col]) &&
          (strcmp(assembly_data[(assembly_buffer->columns * i) +
           parttype_col], "N") == 0)))
       continue;
     /*else if ((assembly_data[(assembly_buffer->columns * i) + attach_col]) &&
              (strcmp(assembly_data[(assembly_buffer->columns * i) + 
              attach_col], "N") == 0) && 
              (assembly_data[(assembly_buffer->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_buffer->columns * i) + level_col],
              "1") != 0))
       continue;*/
     else if ((assembly_data[(assembly_buffer->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_buffer->columns * i ) +level_col],
              "1") == 0) && (PDUis_part_positionless(static_mod_env, parts_id, 
              assembly_data[(assembly_buffer->columns * i) + usageid_col])))
       {
       _pdm_debug("setting positionless part to TRUE", 0);
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_buffer->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_buffer->columns * i ) +level_col],
              "1") == 0) && 
              (strcmp(assembly_data[(assembly_buffer->columns * i) + 
               usageid_col], "") == 0))
       {
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_buffer->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_buffer->columns * i ) +level_col],
              "1") != 0) && (positionless_part))
       continue;
     else if ((assembly_data[(assembly_buffer->columns * i) + refid_col]) &&
         (strcmp(assembly_data[(assembly_buffer->columns * i) + refid_col],
         "-1") == 0))
        continue;
     else if ((assembly_data[(assembly_buffer->columns * i) + delete_col]) &&
         (strcmp(assembly_data[(assembly_buffer->columns * i) + delete_col], 
         "N") == 0))
     {
     positionless_part = FALSE;
     sscanf(assembly_data[(assembly_buffer->columns * i) + level_col], "%d",
            &temp_level);
     _pdm_debug("temp_level = %d", temp_level);
     if (temp_level <= display_level)
     {
     FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 0, 
                    assembly_data[(assembly_buffer->columns * i) + level_col],
                    FALSE);
     part_length = strlen(assembly_data[(assembly_buffer->columns * i) + 
                          itemname_col]);
     usageid_length = strlen(assembly_data[(assembly_buffer->columns * i) + 
                             usageid_col]);
     text = (char *)malloc(part_length + usageid_length + 5);
     memset(text, NULL, (part_length + usageid_length + 5));
     strcpy(text, assembly_data[(assembly_buffer->columns * i) + itemname_col]);
     strcat(text, " [");
     strcat(text, assembly_data[(assembly_buffer->columns * i) + usageid_col]);
     strcat(text, "]");
     FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 1, 
                    text, FALSE);
     FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 2, 
                    assembly_data[(assembly_buffer->columns * i) + itemrev_col],
                    FALSE);
     FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 3, 
                   assembly_data[(assembly_buffer->columns * i) + itemdesc_col],
                    FALSE);
     if (strcmp(assembly_data[(assembly_buffer->columns * i) + attach_col], "Y")
         == 0)
       FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 4,
                      "on",FALSE);
     else if (strcmp(assembly_data[(assembly_buffer->columns * i) + attach_col],
              "") == 0)
       FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 4,
                      "on",FALSE);
     else
       FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 4,
                      "off",FALSE);
      num_rows = num_rows + 1;
     }
     }
     } 
   if (num_rows == 0)
     {
     FIg_disable(forms.assembly_display_form_id, ASSEMBLY_MCF);
     msg = (char *)PDUtranslate_message(PDM_E_NO_EDIT_DSP_ASSEMBLY);
     FIg_set_text(forms.assembly_display_form_id, FI_MSG_FIELD, msg);
     PDUmessage(PDM_E_NO_EDIT_DSP_ASSEMBLY, 's');
     }
   else
     FIfld_set_num_rows(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows);
 
   return (PDM_S_SUCCESS);
   }

int PDUmanage_assembly_on_located_part(refid_string)
char *refid_string;

  {
  int status;
  int refid_col;
  int level_col;
  int itemname_col;
  int usageid_col;
  int i;
  int length = 0;
  int select;
  int pos;
  int num_rows;
  int part_length;
  int usageid_length;
  char *level = NULL;
  char *part_usageid = NULL;
  char *text = NULL;
  char *refid = NULL;
  char *osnum = NULL;
  char *tmp_refid = NULL;
  char *tmp_osnum = NULL;
  char *ptr = NULL;
  char **assy_data = NULL;
  
  _pdm_debug("PDUmanage_assembly_on_located_part", 0);
  _pdm_debug("refid_string = <%s>", refid_string);

  PDUfill_in_string(&refid, refid_string);
  ptr = (char *)strstr(refid, "|");
  if (ptr)
    *((char *)strstr(refid, "|")) = '\0';
  ptr = (char *)strstr(refid_string, "|");
  ptr = ptr + 1;
  ptr = (char *)strstr(ptr, "|");
  ptr = ptr + 1;
  PDUfill_in_string(&osnum, ptr);
  _pdm_debug("refid = <%s>", refid);
  _pdm_debug("osnum = <%s>", osnum);
  status = MEMbuild_array(assy_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = PDUget_buffer_col(assy_bufr, "p_refid", &refid_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);
  status = PDUget_buffer_col(assy_bufr, "n_itemname", &itemname_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);
  status = PDUget_buffer_col(assy_bufr, "p_usageid", &usageid_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);
  status = PDUget_buffer_col(assy_bufr, "p_level", &level_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);
  assy_data = (char **)assy_bufr->data_ptr;
  _pdm_debug("assy_bufr->rows = %d", (char *) assy_bufr->rows);
/*
  if (PDMdebug_on)
    MEMprint_buffer("assy_bufr", assy_bufr, PDU_DEBUG_FILE);
*/
  for (i = 1; i < assy_bufr->rows; i++)
    {
    PDUfill_in_string(&tmp_refid, 
                      assy_data[(assy_bufr->columns * i) + refid_col]);
/* 11/21/95 - MJG - TR 139528245 BEGIN */
    if ((!tmp_refid) || ((tmp_refid) && (!(strlen(tmp_refid)))))
      {
      _pdm_debug("refid is blank; CONTINUE", 0);
      continue;
      }
/* END */

    ptr = (char *)strstr(tmp_refid, "|");
    if (ptr)
      *((char *)strstr(tmp_refid, "|")) = '\0';
    _pdm_debug("tmp_refid = <%s>", tmp_refid);
    PDUfill_in_string(&tmp_osnum, 
                      assy_data[(assy_bufr->columns * i) + refid_col]);
    _pdm_debug("tmp_osnum (before strstr) = <%s>", tmp_osnum);
    if (!tmp_osnum)
      _pdm_debug("tmp_osnum is NULL", 0);
    ptr = (char *)strstr(tmp_osnum, "|");
    ptr = ptr + 1;
    ptr = (char *)strstr(ptr, "|");
    ptr = ptr + 1;
    _pdm_debug("ptr = <%s>", ptr);
    PDUfill_in_string(&tmp_osnum, ptr);
    _pdm_debug("tmp_osnum  = <%s>", tmp_osnum);
    if ((strcmp(refid, tmp_refid) == 0) && (strcmp(osnum, tmp_osnum) == 0))
      {
      _pdm_debug("match found for refid_string", 0);
      PDUfill_in_string(&level, 
                        assy_data[(assy_bufr->columns * i) + level_col]);
      part_length = strlen(assy_data[(assy_bufr->columns * i) + itemname_col]);
     usageid_length = strlen(assy_data[(assy_bufr->columns * i) + usageid_col]);
      part_usageid = (char *)malloc(part_length + usageid_length + 5);
      memset(part_usageid, NULL, (part_length + usageid_length + 5));
      strcpy(part_usageid, assy_data[(assy_bufr->columns * i) + itemname_col]);
      strcat(part_usageid, " [");
      strcat(part_usageid, assy_data[(assy_bufr->columns * i) + usageid_col]);
      strcat(part_usageid, "]");
      _pdm_debug("part_usageid = <%s>", part_usageid);
      break;
      }
    }
  if (part_usageid == NULL)
    return(PDM_E_FAILURE);
  else if (strcmp(part_usageid, "") == 0)
    return(PDM_E_FAILURE);
  
  FIfld_get_num_rows(forms.assembly_display_form_id, ASSEMBLY_MCF, &num_rows);
  _pdm_debug("num_rows = <%d>", num_rows);

  for (i = 0; i < num_rows; i++)
    {
    FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 1,
                          &length);
    text = (char *)malloc(length + 1);
    FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 1, length,
                   (unsigned char*)text, &select, &pos);
    _pdm_debug("text = <%s>", text);
    if (strcmp(text, part_usageid) == 0)
      {
      _pdm_debug("match found on form", 0);
      if (text)
        free(text);
      FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 0,
                            &length);
      text = (char *)malloc(length + 1);
      FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 0, length,
                     (unsigned char*)text, &select, &pos);
      _pdm_debug("text = <%s>", text);
      if (strcmp(level, text) == 0)
        {
        _pdm_debug("level match found", 0);
        if (text) 
          free(text);
        FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF, i,4,
                              &length);
        text = (char *)malloc(length + 1);
        FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF,i,4, length,
                       (unsigned char*)text, &select, &pos);
        _pdm_debug("text = <%s>", text);
       if (strcmp(text, "on") == 0)
         select = FALSE;
       else
         select = TRUE;
       FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 0, 
                        select);
       FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 1, 
                        select);
       FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 2, 
                        select);
       FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 3, 
                        select);
       if (select)
        FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 4, "on",
                        select);
       else
       FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, i, 4, "off",
                       select);
       break;
       }
     }
   }
  return(PDM_S_SUCCESS);
  }

int PDUfind_matching_refids(assembly_bufr, display_level, act_row,
                            display_text)

MEMptr assembly_bufr;
double display_level;
int act_row;
char *display_text;

  {
  int status;
  int i;
  int j;
  int length;
  int pos;
  int select;
  int attached_col;
  int delete_col;
  int level_col;
  int refid_col;
  int parttype_col;
  int usageid_col;
  int catalogno_col;
  int itemno_col;
  int num_rows;
  int temp_level;
  int asm_level;
  int start_row = 1;
  int sel_flag;
  int count = 0;
  int level1_row = 0;
  int parent_row = 0;
  int child_row = 0;
  short positionless_part = FALSE;
  char *text = NULL;
  char *catalog_no = NULL;
  char *pcatalog_no = NULL;
  char *item_no = NULL;
  char *pitem_no = NULL;
  char **assembly_data = NULL;
  struct PDUpart_node *parts_id = NULL;
  
  _pdm_debug("PDUfind_matching_refids", 0);
  if (assembly_bufr == NULL)
    return(PDM_E_PART_NOT_ASSEMBLY);
  else if (assembly_bufr->rows == 0)
    return(PDM_E_PART_NOT_ASSEMBLY);

  status = MEMbuild_array(assembly_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
  PDUget_all_GRpart_ids(static_mod_env->md_id.osnum, &parts_id, &count);
  PDUget_buffer_col(assembly_bufr, "p_refid", &refid_col);
  PDUget_buffer_col(assembly_bufr, "p_attached", &attached_col);
  PDUget_buffer_col(assembly_bufr, "p_delete", &delete_col);
  PDUget_buffer_col(assembly_bufr, "p_level", &level_col);
  PDUget_buffer_col(assembly_bufr, "p_parttype", &parttype_col);
  PDUget_buffer_col(assembly_bufr, "p_usageid", &usageid_col);
  PDUget_buffer_col(assembly_bufr, "n_ccatalogno", &catalogno_col);
  PDUget_buffer_col(assembly_bufr, "n_citemno", &itemno_col);
  assembly_data = (char **)assembly_bufr->data_ptr;
  num_rows = 0;
  if (static_call_command == PDC_M_PLACE_PART)
    start_row = 0;
  for (i = start_row; i < assembly_bufr->rows; i++)
    {
     if (((assembly_data[(assembly_bufr->columns * i) + parttype_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i) + 
              parttype_col], "P") == 0)) || 
              ((assembly_data[(assembly_bufr->columns * i) + parttype_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i) +
              parttype_col], "N") == 0)))
       continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") == 0) && (PDUis_part_positionless(static_mod_env, parts_id, 
              assembly_data[(assembly_bufr->columns * i) + usageid_col])))
       {
       _pdm_debug("part is positionless", 0);
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") == 0) && 
              (strcmp(assembly_data[(assembly_bufr->columns * i) + 
               usageid_col], "") == 0))
       {
       _pdm_debug("part is positionless", 0);
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") != 0) && (positionless_part))
       continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + refid_col]) &&
         (strcmp(assembly_data[(assembly_bufr->columns * i) + refid_col],
         "-1") == 0))
        continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + delete_col]) &&
         (strcmp(assembly_data[(assembly_bufr->columns * i) + delete_col], 
         "N") == 0))
     {
     positionless_part = FALSE;
    sscanf(assembly_data[(assembly_bufr->columns * i) + level_col], "%d", 
           &asm_level);
    _pdm_debug("asm_level = %d", (char *)asm_level);
    _pdm_debug("display_level = %d", display_level);
    if (asm_level > display_level)
      {
      _pdm_debug("asm_level > display_level", 0);
      continue;
      }
    length = 0;
    FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF,
                          num_rows, 0, &length);
    text = (char *)malloc(sizeof(char *) * length + 1);

    memset(text, NULL, (length + 1));
    FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 0,
                   length,(unsigned char*)text, &select, &pos);
    _pdm_debug("text = <%s>", text);
    if (strcmp(text, "") == 0)
      continue;  
    sscanf(text, "%d", &temp_level);
    if (text)
      free(text);
    _pdm_debug("temp_level = %d", (char *)temp_level);
    if (temp_level <= display_level)
      {
      if (num_rows == act_row)
        {
        _pdm_debug("assembly info found for located row", 0);
        PDUfill_in_string(&catalog_no, assembly_data[(assembly_bufr->columns *
                          i) + catalogno_col]);
        _pdm_debug("catalog_no = <%s>", catalog_no);
        PDUfill_in_string(&item_no, assembly_data[(assembly_bufr->columns *
                          i) + itemno_col]);
        _pdm_debug("item_no = <%s>", item_no);
        child_row = num_rows;
        break;
        } 
      num_rows = num_rows + 1;
      }
     }
    }

  if (strcmp(display_text, "on") == 0)
    sel_flag = TRUE;
  else
    sel_flag = FALSE;
  asm_level = asm_level -1;
  num_rows = 0;
  _pdm_debug("sorting through rows on form", 0);
  for (i = start_row; i < act_row + 1; i++)
    {
     if (((assembly_data[(assembly_bufr->columns * i) + parttype_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i) + 
              parttype_col], "P") == 0)) || 
              ((assembly_data[(assembly_bufr->columns * i) + parttype_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i) +
              parttype_col], "N") == 0)))
       continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") == 0) && (PDUis_part_positionless(static_mod_env, parts_id, 
              assembly_data[(assembly_bufr->columns * i) + usageid_col])))
       {
       _pdm_debug("part is positionless", 0);
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") == 0) && 
              (strcmp(assembly_data[(assembly_bufr->columns * i) + 
               usageid_col], "") == 0))
       {
       _pdm_debug("part is positionless", 0);
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") != 0) && (positionless_part))
       continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + refid_col]) &&
         (strcmp(assembly_data[(assembly_bufr->columns * i) + refid_col],
         "-1") == 0))
        continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + delete_col]) &&
         (strcmp(assembly_data[(assembly_bufr->columns * i) + delete_col], 
         "N") == 0))
     {
     positionless_part = FALSE;
    sscanf(assembly_data[(assembly_bufr->columns * i) + level_col], "%d", 
           &temp_level);
    _pdm_debug("temp_level = %d", (char *)temp_level);
    _pdm_debug("display_level = %d", display_level);
    if (temp_level > display_level)
      {
      _pdm_debug("temp_level > display_level", 0);
      continue;
      }
    length = 0;
    FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF,
                          num_rows, 0, &length);
    text = (char *)malloc(sizeof(char *) * length + 1);

    memset(text, NULL, (length + 1));
    FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 0,
                   length,(unsigned char*)text, &select, &pos);
    _pdm_debug("text = <%s>", text);
    if (strcmp(text, "") == 0)
      continue;  
    sscanf(text, "%d", &temp_level);
    if (text)
      free(text);
    _pdm_debug("temp_level = %d", (char *)temp_level);
    _pdm_debug("asm_level = %d", (char *)asm_level);
    if (temp_level <= display_level)
      {
      _pdm_debug("temp_level <= display_level", 0);
      if (temp_level == asm_level)
        {
        _pdm_debug("temp_level == asm_level", 0);
        parent_row = num_rows;
        PDUfill_in_string(&pcatalog_no, assembly_data[(assembly_bufr->columns 
                          * i) + catalogno_col]);
        _pdm_debug("pcatalog_no = <%s>", pcatalog_no);
        PDUfill_in_string(&pitem_no, assembly_data[(assembly_bufr->columns * i)
                          + itemno_col]);
        _pdm_debug("pitem_no = <%s>", pitem_no);
        }
      num_rows = num_rows + 1;
      }
     }
    }

  num_rows = 0;
  _pdm_debug("sorting through assembly bufr", 0);
  for (i = start_row; i < assembly_bufr->rows; i++)
    {
     if (((assembly_data[(assembly_bufr->columns * i) + parttype_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i) + 
              parttype_col], "P") == 0)) || 
              ((assembly_data[(assembly_bufr->columns * i) + parttype_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i) +
              parttype_col], "N") == 0)))
       continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") == 0) && (PDUis_part_positionless(static_mod_env, parts_id, 
              assembly_data[(assembly_bufr->columns * i) + usageid_col])))
       {
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") == 0) && 
              (strcmp(assembly_data[(assembly_bufr->columns * i) + 
               usageid_col], "") == 0))
       {
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") != 0) && (positionless_part))
       continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + refid_col]) &&
         (strcmp(assembly_data[(assembly_bufr->columns * i) + refid_col],
         "-1") == 0))
        continue;
    else if ((assembly_data[(assembly_bufr->columns * i) + delete_col]) &&
        (strcmp(assembly_data[(assembly_bufr->columns * i) + delete_col], "N")
        == 0))
    {
    sscanf(assembly_data[(assembly_bufr->columns * i) + level_col], "%d", 
           &asm_level);
    _pdm_debug("display_level = %d", display_level);
    _pdm_debug("asm_level = %d", (char *)asm_level);
    if (asm_level > display_level)
      {
      _pdm_debug("asm_level > display_level", 0);
      continue;
      }
    length = 0;
    FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF,
                          num_rows, 0, &length);
    text = (char *)malloc(sizeof(char *) * length + 1);
    memset(text, NULL, (length + 1));
    FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 0,
                   length,(unsigned char*)text, &select, &pos);
    _pdm_debug("text = <%s>", text);
    if (strcmp(text, "") == 0)
      continue;  
    sscanf(text, "%d", &temp_level);
    if (text)
      free(text);
    _pdm_debug("temp_level = %d", (char *)temp_level);
    if (temp_level <= display_level)
    {
    if (parent_row == num_rows)
       {
       num_rows = num_rows + 1;
       continue;
       }
   else if (((pcatalog_no) && 
            (strcmp(assembly_data[(assembly_bufr->columns * i) + catalogno_col],
            pcatalog_no) == 0)) && 
            ((pitem_no) && (strcmp(assembly_data[(assembly_bufr->columns * i)
            + itemno_col], pitem_no) == 0)))
      {
      _pdm_debug("match found", 0);
      for (j = 0; j < num_rows + 1; j ++)
      {
      length = 0;
      FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF, 
                            j, 0, &length);
      text = (char *)malloc(sizeof (char) * length + 1);
      memset(text, NULL, (length + 1));
      FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, j, 0, 
                     length, (unsigned char*)text, &select, &pos);
      _pdm_debug("text = <%s>", text);
      if (strcmp(text, "1") == 0)
        level1_row = j;
      }
      if (sel_flag)
      {
      FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row, 
                     4, display_text, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row,
                       0, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row,
                       1, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row,
                       2, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row,
                       3, sel_flag);
      }
      level1_row = num_rows + (child_row - parent_row);
      _pdm_debug("level1_row = %d", level1_row);
      FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row, 
                     4, display_text, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row,
                       0, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row,
                       1, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row,
                       2, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, level1_row,
                       3, sel_flag);
      }
     num_rows = num_rows + 1;
     }
    }
    }
    
  return(PDM_S_SUCCESS);
  }
      
int PDUfind_nested_assemblies(assembly_bufr, display_level, act_row,
                            display_text, num_assem_rows)

MEMptr assembly_bufr;
double display_level;
int act_row;
char *display_text;
int num_assem_rows;

  {
  int status;
  int i;
  int j;
  int length;
  int pos;
  int select;
  int attached_col;
  int delete_col;
  int level_col;
  int refid_col;
  int parttype_col;
  int usageid_col;
  int catalogno_col;
  int itemno_col;
  int num_rows;
  int temp_level;
  int asm_level;
  int start_row = 1;
  int sel_flag;
  int count = 0;
  int assembly_row = 0;
  short positionless_part = FALSE;
  char *text = NULL;
  char *catalog_no = NULL;
  char *item_no = NULL;
  char **assembly_data = NULL;
  struct PDUpart_node *parts_id = NULL;
  
  _pdm_debug("PDUfind_nested_assemblies", 0);
  if (assembly_bufr == NULL)
    return(PDM_E_PART_NOT_ASSEMBLY);
  else if (assembly_bufr->rows == 0)
    return(PDM_E_PART_NOT_ASSEMBLY);

  status = MEMbuild_array(assembly_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
  PDUget_all_GRpart_ids(static_mod_env->md_id.osnum, &parts_id, &count);
  PDUget_buffer_col(assembly_bufr, "p_refid", &refid_col);
  PDUget_buffer_col(assembly_bufr, "p_attached", &attached_col);
  PDUget_buffer_col(assembly_bufr, "p_delete", &delete_col);
  PDUget_buffer_col(assembly_bufr, "p_level", &level_col);
  PDUget_buffer_col(assembly_bufr, "p_parttype", &parttype_col);
  PDUget_buffer_col(assembly_bufr, "p_usageid", &usageid_col);
  PDUget_buffer_col(assembly_bufr, "n_ccatalogno", &catalogno_col);
  PDUget_buffer_col(assembly_bufr, "n_citemno", &itemno_col);
  assembly_data = (char **)assembly_bufr->data_ptr;
  num_rows = 0;
  if (static_call_command == PDC_M_PLACE_PART)
    start_row = 0;
  for (i = start_row; i < assembly_bufr->rows; i++)
    {
     if (((assembly_data[(assembly_bufr->columns * i) + parttype_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i) + 
              parttype_col], "P") == 0)) || 
              ((assembly_data[(assembly_bufr->columns * i) + parttype_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i) +
              parttype_col], "N") == 0)))
       continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") == 0) && (PDUis_part_positionless(static_mod_env, parts_id, 
              assembly_data[(assembly_bufr->columns * i) + usageid_col])))
       {
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") == 0) && 
              (strcmp(assembly_data[(assembly_bufr->columns * i) + 
               usageid_col], "") == 0))
       {
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") != 0) && (positionless_part))
       continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + refid_col]) &&
         (strcmp(assembly_data[(assembly_bufr->columns * i) + refid_col],
         "-1") == 0))
        continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + delete_col]) &&
         (strcmp(assembly_data[(assembly_bufr->columns * i) + delete_col], 
         "N") == 0))
     {
     positionless_part = FALSE;
    sscanf(assembly_data[(assembly_bufr->columns * i) + level_col], "%d", 
           &asm_level);
    if (asm_level > display_level)
      continue;
    length = 0;
    FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF,
                          num_rows, 0, &length);
    text = (char *)malloc(sizeof(char *) * length + 1);

    memset(text, NULL, (length + 1));
    FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 0,
                   length,(unsigned char*)text, &select, &pos);
    _pdm_debug("text = <%s>", text);
    if (strcmp(text, "") == 0)
      continue;  
    sscanf(text, "%d", &temp_level);
    if (text)
      free(text);
    _pdm_debug("temp_level = %d", temp_level);
    if (temp_level <= display_level)
      {
      if (num_rows == act_row)
        {
        _pdm_debug("assembly info found for located row", 0);
        PDUfill_in_string(&catalog_no, assembly_data[(assembly_bufr->columns *
                          i) + catalogno_col]);
        _pdm_debug("catalog_no = <%s>", catalog_no);
        PDUfill_in_string(&item_no, assembly_data[(assembly_bufr->columns *
                          i) + itemno_col]);
        _pdm_debug("item_no = <%s>", item_no);
        assembly_row = i;
        break;
        } 
      num_rows = num_rows + 1;
      }
     }
    }

  if (strcmp(display_text, "on") == 0)
    sel_flag = TRUE;
  else
    sel_flag = FALSE;
  num_rows = 0;
  for (i = start_row; i < assembly_bufr->rows; i++)
    {
     if (((assembly_data[(assembly_bufr->columns * i) + parttype_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i) + 
              parttype_col], "P") == 0)) || 
              ((assembly_data[(assembly_bufr->columns * i) + parttype_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i) +
              parttype_col], "N") == 0)))
       continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") == 0) && (PDUis_part_positionless(static_mod_env, parts_id, 
              assembly_data[(assembly_bufr->columns * i) + usageid_col])))
       {
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") == 0) && 
              (strcmp(assembly_data[(assembly_bufr->columns * i) + 
               usageid_col], "") == 0))
       {
       positionless_part = TRUE;
       continue;
       }
     else if ((assembly_data[(assembly_bufr->columns * i) + level_col]) &&
              (strcmp(assembly_data[(assembly_bufr->columns * i ) +level_col],
              "1") != 0) && (positionless_part))
       continue;
     else if ((assembly_data[(assembly_bufr->columns * i) + refid_col]) &&
         (strcmp(assembly_data[(assembly_bufr->columns * i) + refid_col],
         "-1") == 0))
        continue;
    else if ((assembly_data[(assembly_bufr->columns * i) + delete_col]) &&
        (strcmp(assembly_data[(assembly_bufr->columns * i) + delete_col], "N")
        == 0))
    {
    sscanf(assembly_data[(assembly_bufr->columns * i) + level_col], "%d", 
           &asm_level);
    if (asm_level > display_level)
      continue;
    length = 0;
    FIfld_get_text_length(forms.assembly_display_form_id, ASSEMBLY_MCF,
                          num_rows, 0, &length);
    text = (char *)malloc(sizeof(char *) * length + 1);
    memset(text, NULL, (length + 1));
    FIfld_get_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows, 0,
                   length,(unsigned char*)text, &select, &pos);
    _pdm_debug("text = <%s>", text);
    if (strcmp(text, "") == 0)
      continue;  
    sscanf(text, "%d", &temp_level);
    if (text)
      free(text);
    _pdm_debug("temp_level = %d", temp_level);
    if (temp_level <= display_level)
    {
    if ((strcmp(assembly_data[(assembly_bufr->columns * i) + catalogno_col], 
        catalog_no) == 0) && (strcmp(assembly_data[(assembly_bufr->columns * i) 
        + itemno_col], item_no) == 0))
      {
      _pdm_debug("match found", 0);
      FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows,
                   4, display_text, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows,
                     0, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows,
                     1, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows,
                     2, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, num_rows,
                     3, sel_flag);
      for (j = num_rows + 1; j < num_rows + 1 + num_assem_rows; j++)
      {
      FIfld_set_text(forms.assembly_display_form_id, ASSEMBLY_MCF, j, 
                     4, display_text, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, j,
                       0, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, j,
                       1, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, j,
                       2, sel_flag);
      FIfld_set_select(forms.assembly_display_form_id, ASSEMBLY_MCF, j,
                       3, sel_flag);
      }
      }
     num_rows = num_rows + 1;
     }
    }
    }
    
  return(PDM_S_SUCCESS);
  }
end implementation COpdu;
