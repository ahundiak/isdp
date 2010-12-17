#include <stdio.h>
#include <FI.h>
#include "PDUintdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUstr.h"
#include "PDUforms.h"
#include <PDUuser.h>
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDMcommand.h"
#include "part_gadgets.h"
#include "PDUform_def.h"
#include <exdef.h>
#include <PDUcommand.h>
#include "sys/types.h"
#include "sys/wait.h"
#include "sys/stat.h"
#include <PDUproto.h>
#include <PDMproto.h>

/* The #DEFINES for the gadgets on this form are in part_gadgets.h */

/* Externs */

extern char * calloc();
extern char * realloc();
extern int    PDM_debug_on;
extern int    FIg_get_text_length();
extern int    FIg_get_text();
extern int    PDU_single_list_displayed;
extern int    PDU_single_list_created;
extern int    PDU_mcf_list_displayed;
extern int    PDU_mcf_list_created;
extern int    PDU_command;
extern int    PDU_check_filename;
extern int    PDMdebug_on;
extern int    PDU_refresh_gadgets[7];
extern int    PDU_validate_access;
extern int    PDU_form_type;
extern int    PDU_search_type;
extern int    PDU_active_button;
extern Form   PDU_calling_form;
extern Form   PDU_struct_type;
extern Form   PDU_form_id;
extern struct PDUrefresh    *refresh;
extern struct PDUforms      forms;
extern struct PDUuser         *user;
extern int    *PDU_gadget_labels;
extern char   *PDU_value_list[605];
extern char *** PDU_update_struct;
extern int    PDU_value_pulldown;
extern short    PDU_list_filenames;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_display_buffer;
extern MEMptr PDU_design_parts_bufr;
extern short  PDU_check_file_refresh;
extern int      seed_form_created;
extern int      seed_form_displayed;
extern int      user_seed_file;
extern char	*PDU_save_act_catalog;
extern char	*PDU_save_act_partid;
extern char	*PDU_save_act_revision;
extern char	*PDU_save_act_description;
extern char	*PDU_save_act_filename;
extern char	*PDU_save_act_parttype;


/* Initialize the Part Operations Form */
static short auto_seed_file = FALSE;

void PDUseed_form_init()
{
_pdm_debug("INSIDE the PDUseed_form_init function",0);

user_seed_file = FALSE;

PDU_refresh_gadgets[0] = 0;
PDU_refresh_gadgets[1] = NFC_CATALOG_FLD;
PDU_refresh_gadgets[2] = NFC_PART_FLD;
PDU_refresh_gadgets[3] = NFC_REV_FLD;
PDU_refresh_gadgets[5] = NFC_DESC_FLD;
PDU_refresh_gadgets[6] = NFC_FILENAME_FLD;

PDU_save_act_catalog = NULL;
PDU_save_act_partid = NULL;
PDU_save_act_revision = NULL;
PDU_save_act_description = NULL;
PDU_save_act_filename = NULL;
PDU_save_act_parttype = NULL;

/* Fill in PDU_save_act_filename with the file you want to create */
/* PDU_save_act_filename is the file being copied TO */
/* refresh->rev_filename is the file being copied FROM after a filename is
   selected on the seed form. This means that after this fill in string, 
   refresh->rev_filename will be overwritten */
PDUfill_in_string1(&PDU_save_act_filename,refresh->rev_filename);

/* Fill in part info from PDM/PDU Form */
PDUfill_in_string1(&PDU_save_act_catalog,refresh->rev_catalog);
PDUfill_in_string1(&PDU_save_act_partid,refresh->rev_partid);
PDUfill_in_string1(&PDU_save_act_revision,refresh->rev_revision);
PDUfill_in_string1(&PDU_save_act_description,refresh->rev_description);
PDUfill_in_string1(&PDU_save_act_parttype,refresh->rev_parttype);

if ((refresh->rev_project) && (strcmp(refresh->rev_project, "") != 0))
  FIg_set_text(forms.local_files_form_id, PROJECT_FIELD, "");

refresh->rev_project = NULL;
refresh->rev_catalog = NULL;
refresh->rev_partid = NULL;
refresh->rev_revision = NULL;
refresh->rev_description = NULL;
refresh->rev_filename = NULL;
refresh->rev_parttype = NULL;
}

int seed_form_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text = NULL_STRING;
  int             status = PDM_S_SUCCESS;
  int             state = 0;
  int             all_flag;
  int             no_headings;
  int             select, pos, length;
  register int    ret_status;
  char            path[80];  /* path of exnucdp */
  char         ** headings;
  char            *msg = NULL;
  pid_t           child = 0;
  short           delete_file = FALSE;
  char            *save_filename = NULL;
  MEMptr          tmp_buffer = NULL;

  /* Clear the message field at the bottom of the form. */
  FIg_set_text(forms.seed_form_form_id,FI_MSG_FIELD,NULL_STRING);

  PDU_list_filenames = FALSE;
  PDU_check_file_refresh = FALSE;
  PDU_form_id = fp;
  f_label = 0;
  value = 0;
  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  if (refresh->command == PDC_M_LOGIN_USER)
    refresh->command = 0;


  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug ("User selected the HELP button", 0);
         FIf_cvrt_to_perm_win(forms.local_files_form_id);
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("seed_form");

         break;

    case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */

         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

         PDUdismiss_subforms();
         user_seed_file = FALSE;

         PDUfill_in_string1(&refresh->rev_catalog,PDU_save_act_catalog);
         PDUfill_in_string1(&refresh->rev_partid,PDU_save_act_partid);
         PDUfill_in_string1(&refresh->rev_revision,PDU_save_act_revision);
         PDUfill_in_string1(&refresh->rev_description,PDU_save_act_description);
         PDUfill_in_string1(&refresh->rev_filename,PDU_save_act_filename);

         /* reset the refresh 'act' fields */
         PDU_save_act_catalog = NULL;
         PDU_save_act_partid = NULL;
         PDU_save_act_revision = NULL;
         PDU_save_act_description = NULL;
         PDU_save_act_filename = NULL;

          /* Erase the displayed form */

         FIf_erase (forms.seed_form_form_id);
         FIf_delete (forms.seed_form_form_id);
         forms.seed_form_form_id = 0;

         if (auto_seed_file)
           {
           auto_seed_file = FALSE;
           PDUprocess_ex_file_form_after_seed_file();
           break;
           }

         FIf_display(forms.local_files_form_id);

         PDUmessage(PDM_E_CLEAR_FIELD,'s');

         PDUrefresh_local_files_form();

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("INSIDE the FI_ACCEPT for the seed form",0);

         if (user_seed_file == TRUE)
            {
            _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
            _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
            _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);
            _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);

            if ((refresh->rev_catalog == NULL) || 
                (strcmp(refresh->rev_catalog,"") == 0))
               {
               msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
               FIg_set_text(forms.seed_form_form_id, FI_MSG_FIELD, msg);
               FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
               break;
               }

            if ((refresh->rev_partid == NULL) || 
                (strcmp(refresh->rev_partid,"") == 0))
               {
               msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
               FIg_set_text(forms.seed_form_form_id, FI_MSG_FIELD, msg);
               FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
               break;
               }

            if ((refresh->rev_revision == NULL) || 
                (strcmp(refresh->rev_revision,"") == 0))
               {
               msg = (char *) PDUtranslate_message(PDM_I_ENTER_REVISION);
               FIg_set_text(forms.seed_form_form_id, FI_MSG_FIELD, msg);
               FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
               break;
               }

            if ((refresh->rev_filename == NULL) || 
                (strcmp(refresh->rev_filename,"") == 0))
               {
               msg = (char *) PDUtranslate_message(PDM_E_ENTER_FILENAME);
               FIg_set_text(forms.seed_form_form_id, FI_MSG_FIELD, msg);
               FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
               break;
               }
           
            _pdm_debug("checking assembly indicator", 0);
            status = PDMget_assembly_structure(refresh->rev_catalog,
                                    refresh->rev_partid, refresh->rev_revision,
                                    3, &tmp_buffer, 0);
            _pdm_status("PDMget_assembly_structure", status);
            if ((status == PDM_S_SUCCESS) && (tmp_buffer->rows == 1))
              status = PDM_E_PART_NOT_ASSEMBLY;
            if (status != PDM_E_PART_NOT_ASSEMBLY)
              {
              status = PDM_E_SEED_CANNOT_BE_ASSY;
              PDUmessage(status, 's');
              msg = (char *) PDUtranslate_message(PDM_E_SEED_CANNOT_BE_ASSY);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              break;
              }
            }

         if (user_seed_file == FALSE)
            {
            _pdm_debug("Taking the option to use the EMS seed file",0);
            FIf_erase(forms.seed_form_form_id);
            FIf_delete(forms.seed_form_form_id);
            forms.seed_form_form_id = 0;
            PDUfill_in_string1(&refresh->rev_catalog,PDU_save_act_catalog);
            PDUfill_in_string1(&refresh->rev_partid,PDU_save_act_partid);
            PDUfill_in_string1(&refresh->rev_revision,PDU_save_act_revision);
            PDUfill_in_string1(&refresh->rev_description,
                               PDU_save_act_description);
            PDUfill_in_string1(&refresh->rev_filename,PDU_save_act_filename);

            /* reset the refresh 'act' fields */
            PDU_save_act_catalog = NULL;
            PDU_save_act_partid = NULL;
            PDU_save_act_revision = NULL;
            PDU_save_act_description = NULL;
            PDU_save_act_filename = NULL;

            if (auto_seed_file)
             {
             auto_seed_file = FALSE;
             PDUprocess_ex_file_form_after_seed_file();
             break;
             }

            _pdm_debug("Call: PDUfinish_activate",0);
            PDUfinish_activate();
            break;
            }
          
         _pdm_debug("Taking the option to use a user defined seed file",0);

         /* Check if file is already local */
         status = PDUverify_file(refresh->rev_filename);
         _pdm_status("PDUverify_file",status);

         if (status != PDM_S_SUCCESS)
            {
            delete_file = TRUE;
            _pdm_debug("PDMscopy is called",0);
            _pdm_debug("Copying file locally",0);
            status = PDMscopy(refresh->rev_catalog,refresh->rev_partid, 
                              refresh->rev_revision, refresh->rev_filename);
            _pdm_status("PDMscopy",status);

            if (status != PDM_S_SUCCESS)
               {
               _pdm_debug("The PDMscopy was UNsuccessful",0);
               PDUmessage(status, 's');
               FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
               break;
               }

            /* Verify that the file was actually copied */
            status = PDUverify_file(refresh->rev_filename);
            _pdm_status("PDUverify_file",status);
   
            PDUmessage(status, 's');
   
            if (status != PDM_S_SUCCESS)
               {
               _pdm_debug("File <%s> does not exist",refresh->rev_filename);
               msg = (char *) PDUtranslate_message(PDM_E_FILE_NOT_LOCAL);
               FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
               FIg_set_text(PDU_form_id,NFC_FILENAME_FLD,"");
               refresh->rev_filename = NULL_STRING;
               FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
               break;
               }
            }
         else
            delete_file = FALSE;

         _pdm_debug("File <%s> was copied locally",refresh->rev_filename);
 
         /* Save the seed file name and path so the seed file can be
            removed later */

         status = PDUcheck_if_graphic(refresh->rev_filename);
         _pdm_status("PDUcheck_if_graphic",status);

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            _pdm_debug("File <%s> is not graphic",refresh->rev_filename);
            msg = (char *) PDUtranslate_message(PDM_E_FILE_NOT_GRAPHIC);
            FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
            FIg_set_text(PDU_form_id,NFC_FILENAME_FLD,"");
            FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
            refresh->rev_filename = NULL_STRING;

            if (delete_file == TRUE)
             {
             status = PDUdelete_single_local_file();
             _pdm_status("PDUdelete_single_local_file",status);
             }
 
            break;
            }

         _pdm_debug("File <%s> is graphic",refresh->rev_filename);
         _pdm_debug("Do a copyOS",0);

         _pdm_debug("checking to see if file is open", 0);
         status = PDUis_file_open(refresh->rev_filename);
         _pdm_status("PDUis_file_open", status);
         if (status == 1)
           {
           status = PDM_E_COPY_OPEN_FILE;
           PDUmessage(status, 's');
           return(status);
           }

         /* get path of exnuc on workstation */
         _pdm_debug("Getting path of EXNUC", 0);
         status = PDUget_exnuc_path(path);
         _pdm_status("PDUget_exnuc_path returns", status);

         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("failed to get EXNUC path", 0);
           FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
           msg = (char *) PDUtranslate_message(PDM_E_EXNUC_PATH);
           FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
           break;
           }

         strcat(path, "bin/copyOS");
         _pdm_debug("Path is <%s>", path);

         /* fill in filename fom buffer for copy file */

         /* forking  a child */
         /* The return statuses of vfork can be
            <  0 i.e the fork failed
            >  0  i.e it's the parent itself
            =  0   i.e it's the child process
         */

         /* Why use vfork instead of fork -
            vfork - carries the parent variables
            fork  - Doesn't use the parent variables
         */

#if defined (__sgi)
         if ((child = fork()) == -1)
            {
            _pdm_debug("FORK did not work",0);
            FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
            break;
            }
#else
         if ((child = vfork()) == -1)
            {
            _pdm_debug("VFORK did not work",0);
            FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
            break;
            }
#endif
         else if((child == 0)) /* child = 0. Do the copyOS */
            {
            _pdm_debug("Execute the copyOS",0);
            ret_status = execlp(path,path,refresh->rev_filename,
                                PDU_save_act_filename,(char *)0);
            if (ret_status == -1)
               {
               PDUmessage(PDM_E_COPY_OBJECT_SPACE, 's');
               msg = (char *) PDUtranslate_message(PDM_E_COPY_OBJECT_SPACE);
               FIg_set_text(fp,FI_MSG_FIELD,msg);
               _pdm_debug("The copyOS was UNsuccessful",0);
               FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
               break;
               }
            else
               {
               _pdm_debug("The copyOS was Successful",0); 
               }
            }

         if (waitpid(child,NULL,0) < 0)
            _pdm_debug("Wait Error", 0);

         /* Remove the seed file that was copied locally */

         if (delete_file == TRUE)
           {
           status = PDUdelete_single_local_file();
           _pdm_status("PDUdelete_single_local_file",status);
           }

         if (status != PDM_S_SUCCESS)
            _pdm_debug("ERROR removing the seed file from local directory",0);

         /* Verify that the copyOs was successful by checking to see if
            the file is local */

         /* save refresh filename */
         PDUfill_in_string(&save_filename, refresh->rev_filename);
         PDUfill_in_string(&refresh->rev_filename, PDU_save_act_filename);

         _pdm_debug("Verifying file exists locally <%s>",PDU_save_act_filename);
         status = PDUverify_file(PDU_save_act_filename);
         _pdm_status("PDUverify_file",status);

         PDUfill_in_string(&refresh->rev_filename, save_filename);

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            _pdm_debug("The copyOS was UNsuccessful",0);
            msg = (char *) PDUtranslate_message(PDM_E_FILE_NOT_CREATED);
            FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
            FIg_set_text(PDU_form_id,NFC_FILENAME_FLD,"");
            FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
            break;
            }

         _pdm_debug("The copyOS was successful",0);
         _pdm_debug("activate the part",0);

         /* Erase the displayed form */
         FIf_erase ( fp );
         FIf_delete ( fp );
         forms.seed_form_form_id = 0;

         PDUfill_in_string1(&refresh->rev_catalog,PDU_save_act_catalog);
         PDUfill_in_string1(&refresh->rev_partid,PDU_save_act_partid);
         PDUfill_in_string1(&refresh->rev_revision,PDU_save_act_revision);
         PDUfill_in_string1(&refresh->rev_description,
                            PDU_save_act_description);
         PDUfill_in_string1(&refresh->rev_filename,PDU_save_act_filename);

         if (auto_seed_file)
           {
           auto_seed_file = FALSE;
           PDUprocess_ex_file_form_after_seed_file();
           break;
           }

         status = PDUfinish_activate();  
         _pdm_status("PDUfinish_activate",status); 

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
            _pdm_debug("The function PDUfinish_activate was UNsuccessful",0);
            break;
            }

         break;

    case SEED_FILE_TGL:     /* Sequenced to     */

         _pdm_debug("ENTER: SEED_FILE_TGL",0);

         status = FIg_get_state(PDU_form_id,SEED_FILE_TGL,&state);

         if (status != FI_SUCCESS)
            {
            PDUmessage(status,'s');
            break;
            }

         if (state == 0)
            {
            _pdm_debug("The SEED_FILE_TGL is set to Default EMS seed file",0);
 
            user_seed_file = FALSE;

            status = FIg_erase(PDU_form_id,NFC_PART_GRP);

            if (status != FI_SUCCESS)
               {
               PDUmessage(status,'s');
               break;
               }

            FIfld_set_text(PDU_form_id,NFC_CATALOG_FLD,0,0,"",FALSE);
            FIfld_set_text(PDU_form_id,NFC_PART_FLD,0,0,"",FALSE);
            FIfld_set_text(PDU_form_id,NFC_REV_FLD,0,0,"",FALSE);
            FIfld_set_text(PDU_form_id,NFC_FILENAME_FLD,0,0,"",FALSE);
            FIfld_set_text(PDU_form_id,NFC_DESC_FLD,0,0,"",FALSE);

            refresh->rev_catalog = NULL;
            refresh->rev_partid = NULL;
            refresh->rev_revision = NULL;
            refresh->rev_description = NULL;
            refresh->rev_filename = NULL;
            }
         else if (state == 1)
            {
            user_seed_file = TRUE;

            _pdm_debug("The SEED_FILE_TGL is set to User defined seed file",0);

            status = FIg_display(PDU_form_id,NFC_PART_GRP);

            if (status != FI_SUCCESS)
               {
               PDUmessage(status,'s');
               break;
               }

            FIfld_pos_cursor(PDU_form_id,NFC_CATALOG_FLD,0,0,0,0,0,0);

            }

         break;

    case NFC_CATALOG_FLD:     /* Member of group GROUP8  */
                             /* Field Type:    ASCII    */

         _pdm_debug("Entering CATALOG",0);

	 refresh->rev_catalog = NULL;
         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
 
         FIg_set_text(fp, NFC_PART_FLD, "");
         FIg_set_text(fp, NFC_REV_FLD, "");
         FIg_set_text(fp, NFC_FILENAME_FLD, "");
         FIg_set_text(fp, NFC_DESC_FLD, "");

         status = PDUep_cat_fld();
         _pdm_status("PDUep_cat_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         break;

    case NFC_PART_FLD:     /* Member of group GROUP8  */
                             /* Sequenced to    */
                             /* Field Type:    ASCII    */

         _pdm_debug("Entering PARTNUM",0);

         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
 
         FIg_set_text(fp, NFC_REV_FLD, "");
         FIg_set_text(fp, NFC_FILENAME_FLD, "");
         FIg_set_text(fp, NFC_DESC_FLD, "");

         status = PDUep_part_fld();
         _pdm_status("PDUep_part_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);

         break;

    case NFC_REV_FLD:     /* Member of group GROUP8  */
                             /* Field Type:    ASCII    */

         _pdm_debug("Entering EP_REV_FLD",0);

         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
 
         FIg_set_text(fp, NFC_FILENAME_FLD, "");
         FIg_set_text(fp, NFC_DESC_FLD, "");

         PDUfill_in_string1(&refresh->rev_filename,"");
         FIfld_set_text(PDU_form_id,NFC_FILENAME_FLD,0,0,
                        "",FALSE);

         status = PDUep_rev_fld();
         _pdm_status("PDUep_rev_fld",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);

         break;

    case NFC_FILENAME_FLD:     /* Member of group GROUP8  */
                             /* Field Type:    ASCII    */

         /* verify part is in part selection area */
          if ((refresh->rev_catalog == NULL) ||
              (strcmp(refresh->rev_catalog, "") == 0))
            {
            msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          if ((refresh->rev_partid == NULL) ||
              (strcmp(refresh->rev_partid, "") == 0))
            {
            msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          if ((refresh->rev_revision == NULL) ||
              (strcmp(refresh->rev_revision, "") == 0))
            {
            msg = (char *) PDUtranslate_message(PDM_I_ENTER_REVISION);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
          }

          FIfld_get_text_length(fp, NFC_FILENAME_FLD, 0, 0, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp, NFC_FILENAME_FLD,0,0,length, 
                         (unsigned char *)text, &select, &pos);

         if ((text == NULL) || (strcmp(text, "") == 0))
           {
           refresh->rev_filename = NULL;
           break;
           }

         status = PDUvalid_filename(refresh->rev_catalog,
				    refresh->rev_partid,
				    refresh->rev_revision,
				    text);
         _pdm_status("PDUvalid_filename", status);

         if (status != PDM_S_SUCCESS)
            {
            FIg_set_text(fp, NFC_FILENAME_FLD, "");
            FIfld_pos_cursor(fp, NFC_FILENAME_FLD, 0,0,0,0,0,0);
            PDUmessage(status, 's');
            break;
            }

         PDUfill_in_string(&refresh->rev_filename, text);

         break;

    case NFC_DESC_FLD:     /* Member of group GROUP8  */
                             /* Field Type:    ASCII    */

         _pdm_debug("Entering EP_DESC_BTN",0);

         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
         FIg_set_text(fp, NFC_FILENAME_FLD, "");

         status = PDUep_desc_fld();
         _pdm_status("PDUep_desc_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);
         break;

    case NFC_CATALOG_BTN:     /* Member of group GROUP8  */

         PDU_active_button = NFC_CATALOG_BTN;

         PDU_check_file_refresh = TRUE;

         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
 
         FIg_set_text(fp, NFC_PART_FLD, "");
         FIg_set_text(fp, NFC_REV_FLD, "");
         FIg_set_text(fp, NFC_DESC_FLD, "");
         FIg_set_text(fp, NFC_FILENAME_FLD, "");

         _pdm_debug("Entering PDUep_cat_btn",0);

         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');

         break;

    case NFC_PART_BTN:     /* Member of group GROUP8  */
                             /* Sequenced to    */

         PDU_active_button = NFC_PART_BTN;

         PDU_check_file_refresh = TRUE;

         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
 
         FIg_set_text(fp, NFC_REV_FLD, "");
         FIg_set_text(fp, NFC_DESC_FLD, "");
         FIg_set_text(fp, NFC_FILENAME_FLD, "");

         _pdm_debug("Entering PDUep_part_btn",0);

         status = PDUep_part_btn();
         _pdm_status("PDUep_part_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');

         break;

    case NFC_REV_BTN:     /* Member of group GROUP8  */
                             /* Sequenced to    */

         PDU_active_button = NFC_REV_BTN;

         PDU_check_file_refresh = TRUE;

         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
 
         FIg_set_text(fp, NFC_DESC_FLD, "");
         FIg_set_text(fp, NFC_FILENAME_FLD, "");

         _pdm_debug("Entering PDUep_rev_btn",0);

         status = PDUep_rev_btn();
         _pdm_status("PDUep_rev_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');

         break;

    case NFC_FILENAME_BTN:     /* Member of group GROUP8  */
                             /* Sequenced to    */

         PDU_active_button = NFC_FILENAME_BTN;

         if (refresh->rev_catalog == NULL)
           {
           _pdm_debug("No catalog",0);
           msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         if (refresh->rev_partid == NULL)
           {
           _pdm_debug("No partid",0);
           msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           break;
           }

         if (refresh->rev_revision == NULL)
           {
           _pdm_debug("No rev",0);
           msg = (char *) PDUtranslate_message(PDM_I_ENTER_REVISION);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         /* call PDM function to retrieve a list of filenames */
         if (PDU_ret_bufr != NULL)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }

         _pdm_debug("Call PDMget_filenames",0);
         status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                         refresh->rev_revision, &PDU_ret_bufr);
         _pdm_status("PDMget_filenames", status);

         if ( status != PDM_S_SUCCESS )
           {
           msg = (char *) PDUtranslate_message(status);
           FIg_set_text(fp,FI_MSG_FIELD,msg);
           MEMclose(&PDU_ret_bufr);
           break;
           }

         if (PDU_ret_bufr == NULL)
           {
           msg = (char *) PDUtranslate_message(PDM_E_NO_PART_FILES);
           FIg_set_text(forms.seed_form_form_id, FI_MSG_FIELD, msg);
           break;
           }

         PDUsetup_single_buffer(PDU_ret_bufr);
         PDU_form_id = forms.seed_form_form_id;
         PDU_gadget_labels[0] = NFC_FILENAME_FLD;
         PDU_update_struct[0] = &refresh->rev_filename;

         all_flag = FALSE;
         no_headings = 1;
         headings = (char **) malloc (sizeof (char *) * no_headings);
         memset(headings, NULL, sizeof (char *) * no_headings);

         PDUfill_in_string(&headings[0], "n_cofilename");

         PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);
         PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);
         PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

         PDUfree_string_array(&headings, no_headings);

         PDU_list_filenames = TRUE;

         _pdm_debug("Call PDUsingle_list_form",0);
         status = PDUsingle_list_form();

         break;

    case NFC_SEARCH_BTN:     /* Member of group GROUP8  */
                             /* Sequenced to    */

         PDU_form_id = forms.seed_form_form_id;
         PDU_form_type = SEED_FORM;
         PDU_search_type = PARTS;
         PDU_calling_form = forms.seed_form_form_id;

         FIf_erase(PDU_form_id);
         FIf_erase(forms.local_files_form_id);

         _pdm_debug("calling part selection form", 0);

         SelectOrPlacePart(TRUE, TRUE, fp);

         break;

  } /* END switch ( g_label ) */

return (1);

} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the New File
   Creation Form (seed form) */

int PDUseed_form()
{
  int  sts = PDM_S_SUCCESS;
  seed_form_created = FALSE;
  seed_form_displayed = FALSE;

  sts = FIf_new(SEED_FORM, "seed_form",
                seed_form_notification_routine,
                &forms.seed_form_form_id);

  seed_form_created = TRUE;

  _pdm_debug("CALLING the function PDUseed_form_init",0);
  PDUseed_form_init();

  /* Display the seed_form form and set the displayed flag to TRUE. */
  _pdm_debug("Display the seed form",0);
  sts = FIf_display(forms.seed_form_form_id);
  seed_form_displayed = TRUE;
  PDU_form_id = forms.seed_form_form_id;

  return(sts);

}

int PDUupdate_seed_form_after_select()
{
   int      status = PDM_S_SUCCESS;
   char            *msg = NULL;

   _pdm_debug("ENTERING: PDUupdate_seed_form_after_select",0);

   PDU_form_id = forms.seed_form_form_id;

   _pdm_debug("resetting refresh gadgets", 0);
   PDU_refresh_gadgets[0] = 0;
   PDU_refresh_gadgets[1] = NFC_CATALOG_FLD;

   FIf_display(forms.seed_form_form_id);

   if (refresh->status == PDM_E_CMD_CANCELLED)
     {
     status = PDM_E_CMD_CANCELLED;
     PDUmessage(status, 's');
     return(status);
     }

   if (refresh->rev_catalog)
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[1],0,0,
                    refresh->rev_catalog,FALSE);
   if (refresh->rev_partid)
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[2],0,0,
                    refresh->rev_partid,FALSE);
   if (refresh->rev_revision)
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[3],0,0,
                    refresh->rev_revision,FALSE);
   if (refresh->rev_filename)
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[6],0,0,
                    refresh->rev_filename,FALSE);

   _pdm_debug("description = <%s>", refresh->rev_description);
   _pdm_debug("parttype = <%s>", refresh->rev_parttype);

   status = PDMget_pt_desc(refresh->rev_catalog,refresh->rev_partid,
                           refresh->rev_revision);
   _pdm_status("PDMget_pt_desc",status);

   if (status != PDM_S_SUCCESS)
      {
      msg = (char *) PDUtranslate_message(PDM_E_RET_PARTTYPE_DESC);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      return(status);
      }

   status = PDUpull_pt_desc();
   _pdm_status("PDUpull_pt_desc",status);

   if (status != PDM_S_SUCCESS)
      {
      msg = (char *) PDUtranslate_message(PDM_E_DSP_PARTTYPE_DESC);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      return(status);
      }

return(status);
}

/* This function will delete a single file that was copied local and update
   the local file manager */

int PDUdelete_single_local_file()
{
  int             status = PDM_S_SUCCESS;
  MEMptr          buffer = NULL;

  _pdm_debug("in the function PDUdelete_single_local_file", 0);

  _pdm_debug("catalog = <%s>", refresh->rev_catalog);
  _pdm_debug("partid = <%s>", refresh->rev_partid);
  _pdm_debug("revision = <%s>", refresh->rev_revision);
  _pdm_debug("filename = <%s>", refresh->rev_filename);

  _pdm_debug("loading file buffer", 0);
  status=PDUcreate_file_buffer_from_refresh(DELETE_LOCAL, &buffer);
  _pdm_status("PDUcreate_file_bufferfrom_refresh", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  if ((buffer) && (buffer->rows == 0))
    {
    status = PDM_E_DELETE_LIST_EMPTY;
    PDUmessage(status, 's');
    MEMclose(&buffer);
    return(status);
    }

  status = PDUdelete_local_files(buffer,DELETE_LOCAL, REFRESH_PART);
  _pdm_status("PDUdelete_local_files", status);

  PDUmessage(status, 's');

  return(status);
}

int PDUautomatic_seed_file()
  {
  int status = PDM_S_SUCCESS;

  _pdm_debug("In the function PDUautomatic_seed_file", 0);

  if (user->username == NULL)
    return(PDM_S_SUCCESS);
  else if (strcmp(user->username, "") == 0)
    return(PDM_S_SUCCESS);

  auto_seed_file = TRUE;
  status = PDUseed_form();
  _pdm_status("PDUseed_form", status);

  return(PDM_S_SUCCESS);
  }
