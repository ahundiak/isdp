class implementation COpdu;
/*
   This file contains all functions invoked from EMS . 

   Author: Jamal Shakra
   Date: 9-30-93
*/

/* Include file section */
#include        "stdio.h"
#include        "OMlimits.h"
#include        "unistd.h"
#include        "sys/types.h"
#include        "sys/stat.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIprims.h"
#include        "DIglob.h"
#include        "PDUerror.h"
#include        "PDUstr.h"
#include        "PDUintdef.h"
#include        "PDUpart.h"
#include        "msdef.h"
#include        "godef.h"
#include        "igrdp.h"
#include        "partmacros.h"
#include        "part.h"
#include        "partdef.h"
#include        "string.h"
#include        "dpmacros.h"
#include        "grdpbmacros.h"
#include        "MEMstruct.h"
#include        "MEMerrordef.h"
#include        "comnmacros.h"
#include        "ctype.h"
#include        "PDUuser.h"
#include        "PDUfile_def.h"
#include        "PDUgrpart.h"
#include        "PDUprompt.h"
#include        "PDUnode.h"
#include        "PDUcommand.h"
#include        "PDUforms.h"



/* Global external variables */
extern  int      PDMdebug_on;
extern short PDU_activate_delete;
extern struct PDUuser    *user;

/* Global variables */

/* Imported messages */
from  GRowner     import       GRget_components;
from  GRowner     import       GRget_number_components;
from  GRowner     import       GRremove_components;
from  GRgraphics  import       GRchgname;
from  GRgraphics  import       GRdelete;

/*
 * This function executes upon an EMS exit with a save is performed.
 */
IGRint PDUexit_save(
                    file_name,
                    flag
                   )
 IGRchar                         *file_name;
 IGRint                          flag;
 { 
 IGRint                          status = PDM_S_SUCCESS;
 IGRint                          responses[1];
 IGRchar                         *msg = NULL;
 IGRchar                         answer[10];
 IGRchar                         output_var[100];
 IGRchar                         catalog[40];
 IGRchar                         number[40];
 IGRchar                         revision[40];
 IGRchar                         *filename = NULL;
 IGRchar                         stamp_path[DI_PATH_MAX];

 IGRchar                         *err;
 IGRchar                         *strings[1];
 IGRint                          bufsiz;
 IGRint                          count = 0;
 struct GRmd_env                 mod_env;
 MEMptr                          filenames = NULL;
 static IGRshort                 save_refresh = FALSE;
 IGRchar                         *tmp_catalog = NULL;
 IGRchar                         *tmp_partid = NULL;
 IGRchar                         *tmp_revision = NULL;
 IGRchar                         *tmp_filename = NULL;

 extern struct PDUrefresh        *refresh;
 extern IGRint                   PDU_command;
 extern IGRint                   PDU_exit_case;
 extern IGRchar                  *PDU_checkin_file;
 extern mode_t                   PDU_review_file_permissions;
 extern IGRchar                  PDU_review_file[80];

   _pdm_debug("In the PDUexit_save function", 0);

   _pdm_debug("file name on entry = <%s>", file_name);

   Check_displayed_forms();

   /* Get file name */
   filename = (IGRchar *)strrchr(file_name, '/');
   filename = ++filename;

   /* Restore file permissions, if retrieved for review */
   if ( (PDU_review_file_permissions != 0) && 
        (strcmp(PDU_review_file, filename) == 0) )
      {
       status = PDUchange_review_file_permissions(
                                                  filename,
                                                  TRUE
                                                 );
       _pdm_status("PDUchange_review_file_permissions", status);
      }

   _pdm_debug("PDU_exit_case = %d", PDU_exit_case);

   if (PDU_exit_case == 4)
     {
      /* Reset exit case flag */
      PDUcleanup_detached_parts_after_save();
      PDU_exit_case = 0;

      return(1);
     }

   /* Check exit case flag */
   if (PDU_exit_case == 1)
      {
       /* Check if user is logged in */
       PDUcleanup_detached_parts_after_save();
       if (PDUnullstr(user->username))
          return(1);

       /* Given filename, get part catalog, number, and revision. */
       /*status = PDMGetPartInfoGivenFileName(
                                            filename,
                                            catalog,
                                            number,
                                            revision
                                           );
       _pdm_status("PDMGetPartInfoGivenFileName", status);

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("file <%s> has no entry in the LFM", filename);

           PDUmessage_trans(status, 's');
           err = (IGRchar *) PDUtranslate_message(PDM_E_PART_NOT_KNOWN);
           UI_error(err);

           PDU_exit_case = 0;

           return(1);
          }*/

       /* Load review fields */
       /*PDUfill_in_string(&refresh->rev_catalog, catalog);
       PDUfill_in_string(&refresh->rev_partid, number);
       PDUfill_in_string(&refresh->rev_revision, revision);
       PDUfill_in_string(&refresh->rev_filename, filename);*/
       
       /* Call db checkin */
      
       status = PDUverify_files_exist_locally(refresh->rev_catalog, 
                                              refresh->rev_partid, 
                                              refresh->rev_revision,&filenames);
       _pdm_status("PDUverify_files_exist_locally", status);

       if (status != PDM_S_SUCCESS)
          {
           PDU_exit_case = 0;
           /* Reset refresh structure */
           PDUfill_in_string(&refresh->rev_catalog, NULL);
           PDUfill_in_string(&refresh->rev_partid, NULL);
           PDUfill_in_string(&refresh->rev_revision, NULL);
           PDUfill_in_string(&refresh->rev_filename, NULL);
           PDUfill_in_string(&refresh->rev_description, NULL);
           PDUmessage(status, 's');
           err = (IGRchar *) PDUtranslate_message(status);
           UI_error(err);
           return(1);
          }

       status = PDUext_checkin();
       _pdm_status("PDUext_checkin", status);

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUext_checkin failed", 0);

           err = (IGRchar *) PDUtranslate_message(status);
           UI_error(err);
          }

       /* Reset exit case flag */
       PDU_exit_case = 0;
       /* Reset refresh structure */
       PDUfill_in_string(&refresh->rev_catalog, NULL);
       PDUfill_in_string(&refresh->rev_partid, NULL);
       PDUfill_in_string(&refresh->rev_revision, NULL);
       PDUfill_in_string(&refresh->rev_filename, NULL);
       PDUfill_in_string(&refresh->rev_description, NULL);
       if (!save_refresh)
         {
         PDUfill_in_string(&refresh->act_catalog, NULL);
         PDUfill_in_string(&refresh->act_partid, NULL);
         PDUfill_in_string(&refresh->act_revision, NULL);
         PDUfill_in_string(&refresh->act_filename, NULL);
         PDUfill_in_string(&refresh->act_description, NULL);
         }
       else
         {
         PDU_command = 0;
         }
       return(1);
      }

   /* Check if inavtive checkin */
   if (PDU_exit_case == 3)
      {
       _pdm_debug("inactive checkin case", 0);
       PDUcleanup_detached_parts_after_save();
 
       /* Check if user is logged in */
       if (PDUnullstr(user->username))
          return(1);

       /* Given filename, get part catalog, number, and revision. */
       /*status = PDMGetPartInfoGivenFileName(
                                            filename,
                                            catalog,
                                            number,
                                            revision
                                           );
       _pdm_status("PDMGetPartInfoGivenFileName", status);

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("file <%s> has no entry in the LFM", filename);

           PDUmessage_trans(status, 's');
           err = (IGRchar *) PDUtranslate_message(PDM_E_PART_NOT_KNOWN);
           UI_error(err);

           PDU_exit_case = 0;

           return(1);
          }*/

       /* Load review fields */
       /*PDUfill_in_string(&refresh->rev_catalog, catalog);
       PDUfill_in_string(&refresh->rev_partid, number);
       PDUfill_in_string(&refresh->rev_revision, revision);
       PDUfill_in_string(&refresh->rev_filename, filename);*/

       status = PDUverify_files_exist_locally(refresh->rev_catalog,
                                              refresh->rev_partid,
                                              refresh->rev_revision,&filenames);
       _pdm_status("PDUverify_files_exist_locally", status);

       if (status != PDM_S_SUCCESS)
          {
           PDU_exit_case = 0;
           /* Reset refresh structure */
           PDUfill_in_string(&refresh->rev_catalog, NULL);
           PDUfill_in_string(&refresh->rev_partid, NULL);
           PDUfill_in_string(&refresh->rev_revision, NULL);
           PDUfill_in_string(&refresh->rev_filename, NULL);
           PDUmessage(status, 's');
           err = (IGRchar *) PDUtranslate_message(status);
           UI_error(err);
           return(1);
          }

       status = PDUext_checkin();
       _pdm_status("PDUext_checkin", status);

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUext_checkin failed", 0);

           err = (IGRchar *) PDUtranslate_message(status);
           UI_error(err);
          }

       /* Reset exit case flag */
       PDU_exit_case = 0;
       /* Reset refresh structure */
       PDUfill_in_string(&refresh->rev_catalog, NULL);
       PDUfill_in_string(&refresh->rev_partid, NULL);
       PDUfill_in_string(&refresh->rev_revision, NULL);
       PDUfill_in_string(&refresh->rev_filename, NULL);
       PDUfill_in_string(&refresh->rev_description, NULL);
       if (!save_refresh)
         {
         PDUfill_in_string(&refresh->act_catalog, NULL);
         PDUfill_in_string(&refresh->act_partid, NULL);
         PDUfill_in_string(&refresh->act_revision, NULL);
         PDUfill_in_string(&refresh->act_filename, NULL);
         PDUfill_in_string(&refresh->act_description, NULL);
         }
       else
         {
         PDU_command = 0;
         }
       return(1);
      }

   /* Set exit case flag initially to 4 */
   PDU_exit_case = 4;
   save_refresh = FALSE;
 
   /* Execute actions upon save */
   status = PDUexecute_upon_save();
   _pdm_status("PDUexecute_upon_save", status);

   if (status != PDM_S_SUCCESS)
      {
       _pdm_debug("PDUexecute_upon_save failed", 0);

       err = (IGRchar *)PDUtranslate_message(PDM_E_UPON_EXIT);
       UI_error(err);

       return(1);
      }

   /* Check to see if user is logged in */
   if (PDUnullstr(user->username))
      return(1);

   status = PDUverify_part('a');
   _pdm_status("PDUverify_part", status);

   if (status == PDM_S_SUCCESS) 
     {
     PDUload_exec_structure(
                            "",
                            refresh->act_catalog,
                            refresh->act_partid,
                            refresh->act_revision,
                            "",
                            "",
                            "",
                            0,
                            0
                           );

     PDMset_update_os_flag("P");
     }

   if (PDU_command == PDC_M_ACTIVATE_PART)
     {
     PDUfill_in_string(&tmp_catalog, refresh->rev_catalog);
     PDUfill_in_string(&tmp_partid, refresh->rev_partid);
     PDUfill_in_string(&tmp_revision, refresh->rev_revision);
     PDUfill_in_string(&tmp_filename, refresh->rev_filename);
     PDUfill_in_string(&refresh->rev_catalog, NULL);
     PDUfill_in_string(&refresh->rev_partid, NULL);
     PDUfill_in_string(&refresh->rev_revision, NULL);
     PDUfill_in_string(&refresh->rev_filename, NULL);
     PDU_command = 0;
     save_refresh = TRUE;
     }
   /* Get current module info. */
   bufsiz = sizeof(struct GRmd_env);
   gr$get_module_env(sizbuf = &bufsiz, buffer = &mod_env);

   output_var[0] = '\0';
   strcpy(output_var, filename);

   if( !PDUdo_origins_exist(0, 1) )
    {
      msg = (char *)PDUtranslate_message_and_vars(PDP_P_CHECKIN_NO_ORIGIN,
                                                  output_var
                                                  );
    }
   else
     msg = (char *)PDUtranslate_message_and_vars(
                                               PDP_P_CHECKIN_PART,
                                               output_var
                                              );
   UI_prompt(msg);
     do
      {
      /* Set answer to no initially */
      strcpy(answer, "");

      status = PDUget_keyin(answer);
      if ((strcmp(answer, "Y") != 0) &&
          (strcmp(answer, "y") != 0) && (strcmp(answer, "n") != 0) &&
          (strcmp(answer, "N") != 0) && (strcmp(answer, "") != 0))
        {
         status = PDM_E_INVALID_INPUT;
        }

     else
        status = PDM_S_SUCCESS;
      }

    while (status == PDM_E_INVALID_INPUT);
    UI_prompt("");

    if ( (strcmp(answer, "N") == 0) || (strcmp(answer, "n") == 0) ||
           (strcmp(answer, "") == 0) )
       {
          _pdm_debug("checkin option was cancelled", 0);
          if (save_refresh)
            {
            PDUfill_in_string(&refresh->act_catalog, tmp_catalog);
            PDUfill_in_string(&refresh->act_partid, tmp_partid);
            PDUfill_in_string(&refresh->act_revision, tmp_revision);
            PDUfill_in_string(&refresh->act_filename, tmp_filename);
            PDU_command = 0;
            if (tmp_catalog)
              free(tmp_catalog);
            if (tmp_partid)
              free(tmp_partid);
            if (tmp_revision)
              free(tmp_revision);
            if (tmp_filename)
              free(tmp_filename);
            }
               
          return(1);
       }

    if ( (strcmp(answer, "Y") == 0) || (strcmp(answer, "y") == 0) )
      {

       status = PDM_S_SUCCESS;

       if (status == PDM_S_SUCCESS)
          {
           /* Check if user is logged in */
           if (PDUnullstr(user->username))
              return(1);

           status = PDUverify_part('a');
           _pdm_status("PDUverify_part", status);

            if (status != PDM_S_SUCCESS)
            {
           /* Given filename, get part catalog, number, and revision. */
           status = PDMGetPartInfoGivenFileName(
                                                filename,
                                                catalog,
                                                number,
                                                revision
                                               );
           _pdm_status("PDMGetPartInfoGivenFileName", status);

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("file <%s> has no entry in the LFM", filename);

               PDUmessage_trans(status, 's');
               err = (IGRchar *) PDUtranslate_message(PDM_E_PART_NOT_KNOWN);
               UI_error(err);
               if (save_refresh)
                 {
                 PDUfill_in_string(&refresh->act_catalog, tmp_catalog);
                 PDUfill_in_string(&refresh->act_partid, tmp_partid);
                 PDUfill_in_string(&refresh->act_revision, tmp_revision);
                 PDUfill_in_string(&refresh->act_filename, tmp_filename);
                 PDU_command = 0;
                 if (tmp_catalog)
                   free(tmp_catalog);
                 if (tmp_partid)
                   free(tmp_partid);
                 if (tmp_revision)
                   free(tmp_revision);
                 if (tmp_filename)
                   free(tmp_filename);
                 }
               return(1);
              }

           /* Check state */
           PDUfill_in_string(&refresh->rev_catalog, catalog);
           PDUfill_in_string(&refresh->rev_partid, number);
           PDUfill_in_string(&refresh->rev_revision, revision);
           PDUfill_in_string(&refresh->rev_filename, filename);
           }
           else
           {
           PDUfill_in_string(&refresh->rev_catalog, refresh->act_catalog);
           PDUfill_in_string(&refresh->rev_partid, refresh->act_partid);
           PDUfill_in_string(&refresh->rev_revision, refresh->act_revision);
           PDUfill_in_string(&refresh->rev_filename, refresh->act_filename);
           PDUfill_in_string(&refresh->rev_description, refresh->act_description);
           }

           status = PDUmessage_trans(PDC_M_CHECKIN, 'v');
           refresh->command = PDC_M_CHECKIN;
           _pdm_status("PDUmessage_trans", status);

           if (status == PDM_S_SUCCESS)
              {
               /* Construct path to <filename>:PDU_DESIGN_FILE directory */
               di$give_pathname(
                                osnum = mod_env.md_id.osnum,
                                pathname = stamp_path
                               );

               strcat(stamp_path, ":PDU_DESIGN_FILE");

               /* Check to see if file is stamped */
               status = di$ls(regexp = stamp_path, ptr = &count);

               if ( (status == DIR_S_SUCCESS) && (count > 0) )
                  {
                   _pdm_debug("file is stamped", 0);

                   /* Extract part checkin info. */
                   status = PDUload_active_checkin_info();
                   _pdm_status("PDUget_active_checkin_info", status);

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("PDUload_active_checkin_info failed", 0);

                       err = (IGRchar *)
                           PDUtranslate_message(PDM_E_COULD_NOT_LOAD_PART_INFO);
                       UI_error(err);
                       if (save_refresh)
                         {
                         PDUfill_in_string(&refresh->act_catalog, tmp_catalog);
                         PDUfill_in_string(&refresh->act_partid, tmp_partid);
                        PDUfill_in_string(&refresh->act_revision, tmp_revision);
                        PDUfill_in_string(&refresh->act_filename, tmp_filename);
                         PDU_command = 0;
                         if (tmp_catalog)
                           free(tmp_catalog);
                         if (tmp_partid)
                           free(tmp_partid);
                         if (tmp_revision)
                           free(tmp_revision);
                         if (tmp_filename)
                           free(tmp_filename);
                         }

                       return(1);
                      }

                   /* Set flag to indicate active checkin */
                   PDU_exit_case = 1;
                  }

               else
                   {
                    _pdm_debug("file not stamped yet", 0);

                    /* Display list of part files */
                    status = PDUselect_PDU_file(
                                                refresh->rev_catalog,
                                                refresh->rev_partid,
                                                refresh->rev_revision, 
                                                filename
                                               );
                    _pdm_status("PDUselect_PDU_file", status);

                    if (status != PDM_S_SUCCESS)
                       {
                        _pdm_debug("PDUselect_PDU_file failed", 0);

                        err = (IGRchar *)
                           PDUtranslate_message(status);
                        UI_error(err);
                       if (save_refresh)
                         {
                         PDUfill_in_string(&refresh->act_catalog, tmp_catalog);
                         PDUfill_in_string(&refresh->act_partid, tmp_partid);
                        PDUfill_in_string(&refresh->act_revision, tmp_revision);
                        PDUfill_in_string(&refresh->act_filename, tmp_filename);
                         PDU_command = 0;
                         if (tmp_catalog)
                           free(tmp_catalog);
                         if (tmp_partid)
                           free(tmp_partid);
                         if (tmp_revision)
                           free(tmp_revision);
                         if (tmp_filename)
                           free(tmp_filename);
                         }

                        return(1);
                       }
                  
                    if (strcmp(PDU_checkin_file, filename) == 0)
                       {
                        _pdm_debug("initial active checkin", 0);

                        /* Extract part checkin info. */
                        status = PDUload_active_checkin_info();
                        _pdm_status("PDUget_active_checkin_info", status);

                        if (status != PDM_S_SUCCESS)
                           {
                            _pdm_debug("PDUload_active_checkin_info failed", 0);

                            err = (IGRchar *)
                            PDUtranslate_message(PDM_E_COULD_NOT_LOAD_PART_INFO);
                            UI_error(err);
                            if (save_refresh)
                            {
                            PDUfill_in_string(&refresh->act_catalog, 
                                               tmp_catalog);
                            PDUfill_in_string(&refresh->act_partid, tmp_partid);
                            PDUfill_in_string(&refresh->act_revision, 
                                               tmp_revision);
                            PDUfill_in_string(&refresh->act_filename, 
                                               tmp_filename);
                            PDU_command = 0;
                            if (tmp_catalog)
                              free(tmp_catalog);
                            if (tmp_partid)
                              free(tmp_partid);
                            if (tmp_revision)
                              free(tmp_revision);
                            if (tmp_filename)
                             free(tmp_filename);
                           }

                            return(1);
                           }

                        /* Stamp active file */
                        if (PDUis_PDU_file(mod_env))
                          {
                          status = PDUstamp_PDU_design_file(mod_env);
                          _pdm_status("PDUstamp_PDU_design_file", status);
                          }

                        /* Set flag to indicate active checkin */
                        PDU_exit_case = 1;

                        /* Free up PDU_checkin_file */
                        if (PDU_checkin_file)
                           {
                            free(PDU_checkin_file);
                            PDU_checkin_file = NULL;
                           }
                       }

                    else
                        {
                         _pdm_debug("initial inactive checkin", 0);
                        /* Extract part checkin info. */
                         
                       if (PDUis_checkin_file_attached(&mod_env, 
                           PDU_checkin_file))
                         {
                         _pdm_debug("checkin file is attached", 0);
                         PDU_command = -1;
                         responses[0] = EX_CMD_KEY;
                         strings[0] = "PDDcChInPr";
                         status = PDUprepare_queue(responses, strings, 1);
                         _pdm_status("PDUprepare_queue", status);
                         responses[0] = EX_STRING;
                         strings[0] = "y";
                         status = PDUprepare_queue(responses, strings, 1);
                         _pdm_status("PDUprepare_queue", status);
                         responses[0] = EX_STRING;
                         strings[0] = "PduDummyFile";
                         status = PDUprepare_queue(responses, strings, 1);
                         _pdm_status("PDUprepare_queue", status);
                         return(1);
                         }

                       status = PDUload_inactive_checkin_info(PDU_checkin_file);
                       _pdm_status("PDUload_inactive_checkin_info", status);

                        if (status != PDM_S_SUCCESS)
                          {
                          _pdm_debug("PDUload_inactive_checkin_info failed", 0);

                          err = (IGRchar *)
                          PDUtranslate_message(PDM_E_COULD_NOT_LOAD_PART_INFO);
                          UI_error(err);
                            if (save_refresh)
                            {
                            PDUfill_in_string(&refresh->act_catalog, 
                                               tmp_catalog);
                            PDUfill_in_string(&refresh->act_partid, tmp_partid);
                            PDUfill_in_string(&refresh->act_revision, 
                                               tmp_revision);
                            PDUfill_in_string(&refresh->act_filename, 
                                               tmp_filename);
                            PDU_command = 0;
                            if (tmp_catalog)
                              free(tmp_catalog);
                            if (tmp_partid)
                              free(tmp_partid);
                            if (tmp_revision)
                              free(tmp_revision);
                            }

                          return(1);
                          }
                        
                        PDU_exit_case = 3;
                        if ((PDU_checkin_file) && 
                            (strcmp(PDU_checkin_file, "") != 0)) 
                          free(PDU_checkin_file);
                        }
                   }
              }

           else
               {
                _pdm_debug("PDUmessage_trans (PDC_M_CHECKIN) failed", 0);

                PDUmessage(status, 's');
                err = (IGRchar *)
                      PDUtranslate_message(PDM_E_COMPLETE_CHECKIN);
                UI_error(err);
                if (save_refresh)
                  {
                  PDUfill_in_string(&refresh->act_catalog, 
                                     tmp_catalog);
                  PDUfill_in_string(&refresh->act_partid, tmp_partid);
                  PDUfill_in_string(&refresh->act_revision, 
                                     tmp_revision);
                  PDUfill_in_string(&refresh->act_filename, 
                                     tmp_filename);
                  PDU_command = 0;
                  if (tmp_catalog)
                    free(tmp_catalog);
                  if (tmp_partid)
                   free(tmp_partid);
                  if (tmp_revision)
                    free(tmp_revision);
                  }
                return(1);
               }
          }
      }

  else
      {
       _pdm_debug("checkin option was not taken", 0);
      }

  if (save_refresh)
    {
    PDUfill_in_string(&refresh->act_catalog, tmp_catalog);
    PDUfill_in_string(&refresh->act_partid, tmp_partid);
    PDUfill_in_string(&refresh->act_revision, tmp_revision);
    PDUfill_in_string(&refresh->act_filename, tmp_filename);
    PDU_command = 0;
    if (tmp_catalog)
      free(tmp_catalog);
    if (tmp_partid)
      free(tmp_partid);
    if (tmp_revision)
      free(tmp_revision);
    if (tmp_filename)
      free(tmp_filename);
    }
  return(1);
 }


/*
 * This function executes upon an EMS exit with a save is performed.
 */
IGRint PDUexit_nosave(
                      file_name,
                      flag
                     )
 IGRchar                         *file_name;
 IGRint                          flag;
 {
  IGRint              status = PDM_S_SUCCESS;
  MEMptr              detach_buffer = NULL;
  IGRchar             *err = NULL;
  IGRchar             *msg = NULL;
  IGRchar             answer[10];
  IGRint              row_count = 0;
  IGRint              i;
  IGRint              bufsiz;
  IGRchar             dir_entry_name[DI_PATH_MAX];
  IGRchar             **file_name_list = NULL ;
  struct stat         file_status;
  IGRchar             catalog[40];
  IGRchar             number[40];
  IGRchar             revision[40];
  IGRchar             *filename = NULL;
  MEMptr              buffer = NULL;
  MEMptr              ret_buffer = NULL;
  static struct PDUcat_node  *param_cat_list = NULL;
  struct PDUcat_node  *head = NULL;
  struct GRmd_env     mod_env;
  extern struct PDUrefresh         *refresh;
  extern struct PDUuser            *user;
  extern struct PDUforms           forms;
  extern int PDU_command;
  extern MEMptr                    PDU_delete_local_buffer;
  extern IGRint                    PDU_exit_case;
  extern mode_t                    PDU_review_file_permissions;
  extern IGRchar                   PDU_review_file[80];

  _pdm_debug("In the PDUexit_nosave function", 0);

  _pdm_debug("file name on entry = <%s>", file_name);

  Check_displayed_forms();

  /* Get file name */
  filename = (IGRchar *)strrchr(file_name, '/');
  filename = ++filename;

  /* Restore file permissions, if retrieved for review */
  if ( (PDU_review_file_permissions != 0) &&
       (strcmp(PDU_review_file, filename) == 0) )
     {
      status = PDUchange_review_file_permissions(
                                                 filename,
                                                 TRUE
                                                );
      _pdm_status("PDUchange_review_file_permissions", status);
     }

  _pdm_debug("PDU_exit_case = %d", PDU_exit_case);

  if (PDU_exit_case == 4)
     {
      /* Reset exit case flag */
      PDU_exit_case = 0;

      return(1);
     }

  if (PDU_exit_case == 2)
     {
      /* Need to check if logged in */
      if (PDUnullstr(user->username))
         return(1);

      /* Given filename, get part catalog, number, and revision. */
      status = PDMGetPartInfoGivenFileName(
                                           filename,
                                           catalog,
                                           number,
                                           revision
                                          );
      _pdm_status("PDMGetPartInfoGivenFileName", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("file has no entry in LFM", 0);

          PDUmessage_trans(status, 's');
          err = (IGRchar *)
          PDUtranslate_message(PDM_E_PART_NOT_KNOWN);
          UI_error(err);

          /* Reset exit case flag */
          PDU_exit_case = 0;

          return(1);
         }

      /* set the command */
      refresh->command = PDC_M_CANCEL_CHECKOUT;

      status = PDMrcheck_part_status(catalog, number, revision);
      _pdm_status("PDMrcheck_part_status", status);

      if (status == PDM_I_CHECKED_OUT_BY_YOU)
      {
      /* Validate user access */
      status = PDMvalidate_user_access(
                                       "PDMCancel Part Check Out",
                                        NULLSTR,
                                        catalog,
                                        NULLSTR,
                                        number,
                                        revision
                                       );
      _pdm_status ("PDMvalidate_user_access", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDMvalidate_user_access failed", 0);

          err = (IGRchar *)
          PDUtranslate_message(PDM_E_UPON_EXIT);
          UI_error(err);

          /* Reset exit case flag */
          PDU_exit_case = 0;

          return(1);
         }

      /* Delete file(s) locally */
      status = PDMrcancel_checkout_part(
                                        catalog,
                                        number,
                                        revision,
                                        PDU_delete_local_buffer,
                                        param_cat_list,
                                        &file_name_list,
                                        &row_count
                                       );
      _pdm_status("PDMrcancel_checkout_part",status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDMrcancel_checkout_part failed", 0);

          PDUmessage_trans(status, 's');
          err = (IGRchar *)
                PDUtranslate_message(status);
          UI_error(err);

          /* Reset exit case flag */
          PDU_exit_case = 0;

          return(1);
         }

      PDUmessage_trans(status, 's');
      _pdm_debug("rows found = %d", row_count);

      for (i = 0; i < row_count; ++i)
          {
           /* make sure file exists */
           strcpy(dir_entry_name, user->wrkst_cwd);
           strcat(dir_entry_name, "/");

           strcat(dir_entry_name, file_name_list[i]);
           _pdm_debug("full entry path name = <%s>", dir_entry_name);

           status = stat(dir_entry_name, &file_status);
           if (status == 0) /* entry exists */
              {
               /* delete file locally */
               status = unlink(dir_entry_name);
               if (status == 0)
                  {
                   _pdm_debug("entry <%s> was removed successfully",
                                     dir_entry_name);
                  }

               else
                   {
                    _pdm_debug("entry <%s> removal failed", dir_entry_name);
                   }
              }

           else
               _pdm_debug("entry <%s> was not found locally", dir_entry_name);

          } /* end for loop */

      /* Free up PDU_delete_local_buffer */
      if (PDU_delete_local_buffer)
         {
          MEMclose(&PDU_delete_local_buffer);
          PDU_delete_local_buffer = NULL;
         }
       }
      else if (status == PDM_I_COPIED_TO_LOCAL_BY_YOU)
      {
      /* Validate user access */
      status = PDMvalidate_user_access(
                                       "PDMDelete Local File",
                                        NULLSTR,
                                        catalog,
                                        NULLSTR,
                                        number,
                                        revision
                                       );
      _pdm_status ("PDMvalidate_user_access", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDMvalidate_user_access failed", 0);

          err = (IGRchar *)
          PDUtranslate_message(PDM_E_UPON_EXIT);
          UI_error(err);

          /* Reset exit case flag */
          PDU_exit_case = 0;

          return(1);
         }

      /* Delete file(s) locally */
      PDUfill_in_string(&refresh->rev_catalog, catalog);
      PDUfill_in_string(&refresh->rev_partid, number);
      PDUfill_in_string(&refresh->rev_revision, revision);
      
      status = PDUcreate_file_buffer_from_refresh(DELETE_LOCAL, &buffer);
      _pdm_status("PDUcreate_file_buffer_from_refresh", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDMdelete_local_files failed", 0);

          PDUmessage_trans(status, 's');
          err = (IGRchar *)
                PDUtranslate_message(PDM_I_FILE_DELETE);
          UI_error(err);

          /* Reset exit case flag */
          PDU_exit_case = 0;

          return(1);
         }

      status = PDMrdelete_local_files(buffer, &ret_buffer);
      _pdm_status("PDMrdelete_local_files", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDMdelete_local_files failed", 0);

          PDUmessage_trans(status, 's');
          err = (IGRchar *)
                PDUtranslate_message(PDM_I_FILE_DELETE);
          UI_error(err);

          /* Reset exit case flag */
          PDU_exit_case = 0;

          return(1);
         }

       if (ret_buffer)
         MEMclose(&ret_buffer);

       PDUmessage_trans(status, 's');
       PDUmessage(status, 's');
       }
 
      /* Reset exit case flag */
      PDU_exit_case = 0;
      /* Reset refresh structure */
      PDUfill_in_string(&refresh->rev_catalog, NULL);
      PDUfill_in_string(&refresh->rev_partid, NULL);
      PDUfill_in_string(&refresh->rev_revision, NULL);
      PDUfill_in_string(&refresh->rev_filename, NULL);

      return(1);
     }

  /* Set exit case flag */
  PDU_exit_case = 4;

  /* Load detach buffer */
  status = PDUload_detach_buffer(
                                 NULL,
                                 -1,
                                 0,
                                 &detach_buffer
                                );
  _pdm_status("PDUload_detach_buffer", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUload_detach_buffer failed", 0);

      err = (IGRchar *)PDUtranslate_message(PDM_E_UPON_EXIT);
      UI_error(err);

      return(1);
     }

  /* Clean up local files, if necessary */
  if (detach_buffer)
     {
      if (detach_buffer->rows > 0)
         {
          /* Need to check if logged in */
          status  = PDUautomatic_login(FALSE);
          _pdm_status("PDUautomatic_login", status);

          if (!status)
             {
              _pdm_debug("PDUautomatic_login failed", 0);

              FIf_erase(forms.login_form_id);
              err = (IGRchar *)PDUtranslate_message(refresh->status);
              UI_error(err);

              return(1);
             }

          status = PDMdetach_part(detach_buffer);
          _pdm_status("PDMdetach_part", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("SEVERE error: PDMdetach_part failed", 0);
 
              err = (IGRchar *) PDUtranslate_message(PDM_E_UPON_EXIT);
              UI_error(err);
 
              return(1);
             }
         }
     }


  /* Prompt for deleting local file(s) */

  /* Check to see if user is logged in */
  if (PDUnullstr(user->username))
     return(1);

  PDUfill_in_string(&refresh->act_catalog, NULL);
  PDUfill_in_string(&refresh->act_partid, NULL);
  PDUfill_in_string(&refresh->act_revision, NULL);
  PDUfill_in_string(&refresh->act_filename, NULL);
  PDUfill_in_string(&refresh->act_description, NULL);
  if (PDU_command == PDC_M_ACTIVATE_PART)
    {
    _pdm_debug("save refresh to active", 0);
    PDUfill_in_string(&refresh->act_catalog, refresh->rev_catalog);
    PDUfill_in_string(&refresh->act_partid, refresh->rev_partid);
    PDUfill_in_string(&refresh->act_revision, refresh->rev_revision);
    PDUfill_in_string(&refresh->act_filename, refresh->rev_filename);
    PDUfill_in_string(&refresh->act_description, refresh->rev_description);
    PDU_command = 0;
    }
  PDUfill_in_string(&refresh->rev_catalog, NULL);
  PDUfill_in_string(&refresh->rev_partid, NULL);
  PDUfill_in_string(&refresh->rev_revision, NULL);
  PDUfill_in_string(&refresh->rev_filename, NULL);
  PDUfill_in_string(&refresh->rev_description, NULL);
  msg = (char *)PDUtranslate_message(PDP_P_DELETE_LOCAL);
  UI_prompt(msg);

  do
    {
     /* Set answer to no initially */
     strcpy(answer, "");

     status = PDUget_keyin(answer);
     if ( (strcmp(answer, "Y") != 0) &&
          (strcmp(answer, "y") != 0) && (strcmp(answer, "n") != 0) &&
          (strcmp(answer, "N") != 0) && (strcmp(answer, "") != 0) )
        {
         status = PDM_E_INVALID_INPUT;
        }

     else
         status = PDM_S_SUCCESS;
    }

  while (status == PDM_E_INVALID_INPUT);

  UI_prompt("");

  if ( (strcmp(answer, "Y") == 0) || (strcmp(answer, "y") == 0) )
     {
      /* Clear PDU_delete_local_buffer */
      if (PDU_delete_local_buffer)
         {
          MEMclose(&PDU_delete_local_buffer);
          PDU_delete_local_buffer = NULL;
         }

      /* Load delete local files buffer */
      status = PDUload_delete_buffer(
                                     NULL,
                                     -1,
                                     &PDU_delete_local_buffer
                                    );
      _pdm_status("PDUload_delete_buffer", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUload_delete_buffer failed", 0);

          err = (IGRchar *)PDUtranslate_message(PDM_E_UPON_EXIT);
          UI_error(err);

          return(1);
         }

     if (param_cat_list)
       {
       head = param_cat_list;
       while (param_cat_list)
         {
         param_cat_list = param_cat_list->next;
         free(head);
         head = param_cat_list;
         }
       param_cat_list = NULL;
       }
     bufsiz = sizeof(struct GRmd_env);
     gr$get_module_env(sizbuf = &bufsiz, buffer = &mod_env);
     status = PDUprepare_param_cats_list(&mod_env, &param_cat_list);
     _pdm_status("PDUprepare_param_cats_list", status);

      /* Set exit case */
      PDU_exit_case = 2;

      /* Free up buffers */
      if (detach_buffer)
         MEMclose(&detach_buffer);

      return(1);
     }
 
  /* Free up buffers */
  if (detach_buffer)
     MEMclose(&detach_buffer);

  return(1);
 }


/* ALR JRS   9/27/93   Function used by EMS as hook into delete.
                       This function tells EMS that PDU is loaded.
*/
#if defined (clipper) || defined (__Sol2__)

IGRboolean PDMloaded()
{
  return(TRUE);
}
#endif

/* ALR JRS  9/27/93   Function to be used by EMS as hook into delete.
                      This function calls the PDMDeletePartOccurrence.
*/

IGRboolean PDMpre_delete(
                     part_id,
                     mod_env
                    )
 struct  GRid     *part_id;
 struct GRmd_env  *mod_env;
 {
  IGRlong    status = PDM_S_SUCCESS;
  char stat_str[180];

  _pdm_debug("In the PDMpre_delete function", 0);

  /* Delete part */

  if (PDU_activate_delete)
   {
    status = PDMDeletePartOccurrence(&status, mod_env, part_id);
    sprintf(stat_str,"PDMpre_delete: PDMDeletePartOccurrence status <0x%.8x> \n"
,status);
  _pdm_debug(stat_str,0);
   }
  _pdm_debug("PDMpre_delete exit",0);
  return(TRUE);
 }


/* ALR  JRS   10/4/93    Function used as EMS hook for copy part occurrence */

IGRboolean PDMpost_copy (struct GRid     * part_id,
                         struct GRid    *new_part_id,
                         struct GRmd_env * from_env,
                         struct GRmd_env * to_env)
{

 IGRlong          msg;
 IGRlong          status;
 IGRchar          part_label[MAX_VALUE];
 IGRchar          tmp_childno[DI_PATH_MAX];
 IGRchar          tmp_usageid[DI_PATH_MAX];
 IGRchar          usage_id[DI_PATH_MAX];
 IGRint           instance_no;
 IGRchar          serial_no[10];
 IGRchar          attach_value[10];
 IGRchar          refid_string[20];
 IGRchar          *dst_child_no;
 IGRint           type;
 IGRchar          catalog[MAX_VALUE];
 IGRchar          number[MAX_VALUE];
 IGRchar          revision[MAX_VALUE];
 IGRchar          new_catalog[MAX_VALUE];
 IGRchar          new_number[MAX_VALUE];
 IGRchar          new_revision[MAX_VALUE];
 IGRchar          src_child_no[MAX_VALUE];
 IGRchar          attr_value[MAX_VALUE];
 IGRchar          assy_dir[DI_PATH_MAX];
 IGRchar          class_msg[80];
 IGRchar	  *filename;
 IGRchar          *strings[1];
 IGRchar	  **attributes = NULL;
 IGRchar	  **values = NULL;
 MEMptr		  assembly_buffer = NULL;
 IGRint           max_comp_count = 0;
 IGRint           component_count = 0;
 IGRint           cs_index = 0;
 IGRint           reffile_index = 0;
 IGRint           i;
 IGRint           resp;
 IGRint           pos;
 IGRint           responses[1];
 IGRint           attribute_count = 0;
 IGRint           num_objects = 2;
 IGRint           *attribute_type = NULL;
 IGRlong          sts;
 struct GRid      *component_ids = NULL;
 struct GRid      tmp_part_id;
 struct GRid      contextid;
 GRobjid          obj;
 struct GRobj_env objects[2];
 extern int       PDU_command;
 extern struct GRid *PDU_dst_part_id;
 extern struct GRid *PDU_src_part_id;

/* Initialize local variables */
   dst_child_no = NULL;
   filename = NULL;


  _pdm_debug("PDMpost_copy: Enter \n",0);
  
  if ((!(PDUis_PDU_part(part_id, from_env))) && 
      (!(PDUis_parametric_part(part_id))))
    {
    _pdm_debug("source part is not a PDU part", 0);
    return(1);
    }
 
  if (to_env->md_id.objid == NULL_OBJID)
   {
     _pdm_debug("PDMpost_copy: NULL_OBJID found \n",0);
     return(TRUE);
   }

  if (PDUis_parametric_part(part_id))
    {
    _pdm_debug("Part being copied is a PDU parametric part");
    PDU_activate_delete = FALSE;
    om$send(msg = message GRgraphics.GRdelete(&sts, to_env),
            senderid = NULL_OBJID,
            targetid = new_part_id->objid,
            targetos = new_part_id->osnum);

     PDU_activate_delete = TRUE;
     responses[0] = STRING;
     strings[0] = "n";

     PDUprepare_queue(responses, strings, 1);
     resp = EX_OBJID;
     obj = part_id->objid;
     pos = FRONT;
     PDUput_queue(2, NULL, NULL, NULL, NULL, &resp, &obj, NULL, NULL, &pos);
     PALcopy_part(NULL);
     _pdm_debug("Leaving PDMpost_copy", 0);
     return(FALSE);
     }

   status = PDUis_PDU_part(new_part_id, to_env);
   _pdm_status("PDUis_PDU_part", status);

  if (!status)
    return(1);
  /* Extract source part catalog */
  strcpy(catalog, "");
  co$part_get_attr (
                   msg = &msg,
                   mod_env = from_env,
                   part = part_id,
                   attr = "CATALOG",
                   value = catalog,
                   type = &type
                  );

  if (strcmp(catalog, "") == 0)
    return(1);
  /* Extract source part number */
  co$part_get_attr (
                   msg = &msg,
                   mod_env = from_env,
                   part = part_id,
                   attr = "NUMBER",
                   value = number,
                   type = &type
                  );

   /* Extract source part revision */
  co$part_get_attr (
                   msg = &msg,
                   mod_env = from_env,
                   part = part_id,
                   attr = "REVISION",
                   value = revision,
                   type = &type
                  );

  strcpy(new_catalog, "");
  /* Extract new part catalog */
  co$part_get_attr (
                   msg = &msg,
                   mod_env = to_env,
                   part = new_part_id,
                   attr = "CATALOG",
                   value = new_catalog,
                   type = &type
                  );

  if (strcmp(new_catalog, "") == 0)
    return(1);
  /* Extract new part number */
  co$part_get_attr (
                   msg = &msg,
                   mod_env = to_env,
                   part = new_part_id,
                   attr = "NUMBER",
                   value = new_number,
                   type = &type
                  );

   /* Extract new part revision */
  co$part_get_attr (
                   msg = &msg,
                   mod_env = to_env,
                   part = new_part_id,
                   attr = "REVISION",
                   value = new_revision,
                   type = &type
                  );


   if ((strcmp(catalog, new_catalog) != 0) || (strcmp(number, new_number) != 0)
       || (strcmp(revision, new_revision) != 0)) 
     {
     _pdm_debug("part information for copy does not match", 0);
      om$send(msg = message GRowner.GRget_number_components(&sts,
                                                            &max_comp_count),
              senderid = NULL_OBJID,
              targetid = new_part_id->objid,
              targetos = new_part_id->osnum);
      _pdm_debug("%d components were found", max_comp_count);
      component_ids = (struct GRid * )malloc(sizeof (struct GRid) *
                       max_comp_count);
      om$send(msg = message GRowner.GRget_components(&sts, to_env,
                                                     component_ids,
                                                     max_comp_count,
                                                     &component_count, 0,
                                                     max_comp_count - 1),
              senderid = NULL_OBJID,
              targetid = new_part_id->objid,
              targetos = new_part_id->osnum);
       _pdm_debug("After getting components", 0);
   
      if (component_count > 0)
        {
        for ( i = 0; i < component_count; i = i + 1)
          {
          sts = om$get_classname(objid = component_ids[i].objid,
                                 osnum = component_ids[i].osnum,
                                 classname = class_msg);
          _pdm_debug("class is %s", class_msg);
          if (strcmp(class_msg, "GRgencs") == 0)
            {
            _pdm_debug("CS found", 0);
            objects[0].mod_env = *to_env;
            objects[0].obj_id.objid = component_ids[i].objid;
            objects[0].obj_id.osnum = component_ids[i].osnum;
            }
          else if (strcmp(class_msg, "GRreffile") == 0)
            {
            _pdm_debug("reffile found", 0);
            reffile_index = i;
            objects[1].mod_env = *to_env;
            objects[1].obj_id.objid = component_ids[i].objid;
            objects[1].obj_id.osnum = component_ids[i].osnum;
            }
          else if (strcmp(class_msg, "GRdrawview") == 0)
            {
            _pdm_debug("drawing view", 0);
            reffile_index = i;
            objects[1].mod_env = *to_env;
            objects[1].obj_id.objid = component_ids[i].objid;
            objects[1].obj_id.osnum = component_ids[i].osnum;
            }
          }

        om$send(msg = message GRowner.GRremove_components(&sts, to_env,
                                                     &num_objects,
                                                     objects),
              senderid = NULL_OBJID,
              targetid = new_part_id->objid,
              targetos = new_part_id->osnum);
   
        _pdm_debug("After removing components", 0);
        }
       
       /* save attributes of part */

       status = PDUget_GRpart_all_attrs(*from_env, NULL, NULL, NULL, 
                                        &attributes, &values, &attribute_type,
                                        &attribute_count, part_id, 0);
       _pdm_status("PDUget_GRpart_all_attrs", status);

        attributes = attributes + 3;
        values = values + 3;
        attribute_type = attribute_type + 3;
        attribute_count = attribute_count - 3;

        om$send(msg = message GRgraphics.GRdelete(&sts, to_env),
              senderid = NULL_OBJID,
              targetid = new_part_id->objid,
              targetos = new_part_id->osnum);
      
        PDU_activate_delete = FALSE;
        _pdm_debug("After delete", 0);
        status = co$part_construct(msg = &sts, mod_env = to_env, 
                                   catalog = catalog, number = number, 
                                   revision = revision, 
                                   part = &tmp_part_id, attr = attributes, 
                                   value = values, type = attribute_type,
                                   num = attribute_count,
                                   object = objects, 
                                   num_objects = num_objects);
        _pdm_debug("After construct", 0);
        PDU_activate_delete = TRUE;
        pos = FRONT;
        resp = DATA;
        PDUput_queue(3, NULL, NULL, NULL, NULL, &resp, NULL, NULL, NULL, &pos);
        resp = EX_OBJID;
        obj = part_id->objid;
        PDUput_queue(2, NULL, NULL, NULL, NULL, &resp, &obj, NULL, NULL, &pos);
        resp = RESET;
        PDUput_queue(3, NULL, NULL, NULL, NULL, &resp, NULL, NULL, NULL, &pos);
        new_part_id->objid = tmp_part_id.objid;
        new_part_id->osnum = tmp_part_id.osnum;

        if (component_ids)
          {
          free(component_ids);
          component_ids = NULL;
          }
        component_count = 0;
        max_comp_count = 0;

     }

    _pdm_debug("Extracting child no", 0);
    /* Extract source part child no */
   co$part_get_attr (
                   msg = &msg,
                   mod_env = from_env,
                   part = part_id,
                   attr = "child_no",
                   value = src_child_no,
                   type = &type
                );


   /* Unquote child no */
   PDUunquote(src_child_no);

   status = PDUgenerate_child_no(
                                  &dst_child_no,
                                  to_env->md_id.osnum
                                 );
    _pdm_debug("dst_child_no = <%s>", dst_child_no);


   /* Get instance number for target part */
   status = PDUgenerate_instance_number(
                                      catalog,
                                      number,
                                      revision,
                                      &instance_no,
                                      to_env
                                     );

   _pdm_debug("instance no = %d", instance_no);

   /* Default usage id */
  status = PDUget_default_usage_id(
                                  catalog,
                                  number,
                                  revision,
                                  part_label
                                 );
   if (status != PDM_S_SUCCESS)
    {
     _pdm_debug("PDUget_default_usage_id failed", 0);
      return(TRUE);
    }

  strcpy(usage_id, part_label);


   /* Enforce text type on part label "usage id" */
   sprintf(tmp_usageid,"\"%s\"", part_label);


   /* Enforce text type on child number */
   sprintf(tmp_childno,"\"%s\"", dst_child_no);

   /* Modify certain attrs in destination part */


      /* Modify destination part usage id */
     co$part_put_attr (
                        msg = &msg,
                        mod_env = to_env,
                        part = new_part_id,
                        attr = "usage_id",
                        value = tmp_usageid,
                        type = GR_DYNAMIC_ATTR
                       );

    /* Modify destination part child no */
       co$part_put_attr (
                        msg = &msg,
                        mod_env = to_env,
                        part = new_part_id,
                        attr = "child_no",
                        value = tmp_childno,
                        type = GR_DYNAMIC_ATTR 
                       );

      om$send(msg = message GRowner.GRget_number_components(&sts,
                                                            &max_comp_count),
              senderid = NULL_OBJID,
              targetid = new_part_id->objid,
              targetos = new_part_id->osnum);
      _pdm_debug("%d components were found", max_comp_count);
      component_ids = (struct GRid * )malloc(sizeof (struct GRid) *
                       max_comp_count);
      om$send(msg = message GRowner.GRget_components(&sts, to_env,
                                                     component_ids,
                                                     max_comp_count,
                                                     &component_count, 0,
                                                     max_comp_count - 1),
              senderid = NULL_OBJID,
              targetid = new_part_id->objid,
              targetos = new_part_id->osnum);
      if (component_count > 0)
        {
        for ( i = 0; i < component_count; i = i + 1)
          {
          sts = om$get_classname(objid = component_ids[i].objid,
                                 osnum = component_ids[i].osnum,
                                 classname = class_msg);
          _pdm_debug("class is %s", class_msg);
          if (strcmp(class_msg, "GRgencs") == 0)
            {
            _pdm_debug("CS found", 0);
            cs_index = i;
            }
          else if (strcmp(class_msg, "GRreffile") == 0)
            {
            _pdm_debug("reffile found", 0);
            reffile_index = i;
            }
          else if (strcmp(class_msg, "GRdrawview") == 0)
            {
            _pdm_debug("drawing view found", 0);
            reffile_index = i;
            }
          }
        }

      _pdm_debug("partlabel = %s", part_label);
      om$send(msg = message GRgraphics.GRchgname(&sts, to_env, part_label),
              senderid = to_env->md_id.objid,
              targetid = component_ids[cs_index].objid,
              targetos = component_ids[cs_index].osnum);
      _pdm_debug("GRgraphics.GRchgname msg = %d", msg);
      /* Extracted obj. id will be used as serial number */
     sprintf(serial_no,"%d", component_ids[cs_index].objid);

     /* Modify destination part serial no */
        co$part_put_attr (
                         msg = &msg,
                         mod_env = to_env,
                         part = new_part_id,
                         attr = "serial",
                         value = serial_no,
                         type = &type
                         );

    /* extracted refobjid will be attached flag *\
    sprintf(attach_value,"%d", component_ids[reffile_index].objid);

     /* Modify destination part serial no */
        co$part_put_attr (
                         msg = &msg,
                         mod_env = to_env,
                         part = new_part_id,
                         attr = "attach_flag",
                         value = attach_value,
                         type = &type
                         );

    /* Need to increment child number seed */
    PDUincrement_child_no(to_env->md_id.osnum);


    di$give_pathname(
                     osnum = from_env->md_id.osnum,
                     pathname = assy_dir
                    );

     strcat(assy_dir, ":ASSEMBLY:P");
     strcat(assy_dir, src_child_no);

      /* retrieve filename for assy_dir */
     status = PDUevaluate_exp(
                               assy_dir,
                               "file_name",
                               &filename
                              );
     if (status != PDM_S_SUCCESS)
       return(TRUE);

     status = PDUload_assy_struct_buffer(from_env,&assembly_buffer,-1,assy_dir);
     if (status != PDM_S_SUCCESS)
       return(TRUE);
   
     if (assembly_buffer == NULL)
       return(TRUE);
 
     if (assembly_buffer->rows == 0)
       return(TRUE);
 
     status = PDUadd_assy_struct_from_buffer(to_env,dst_child_no,filename,assembly_buffer,2);
     if (status != PDM_S_SUCCESS)
       return(TRUE);

    di$give_pathname(
                     osnum = to_env->md_id.osnum,
                     pathname = assy_dir
                    );

     strcat(assy_dir, ":ASSEMBLY:P");
     strcat(assy_dir, dst_child_no);

     PDUmodify_exp(0, assy_dir, "usage_id", usage_id, to_env->md_id.osnum);
     _pdm_debug("refid = <%d>", component_ids[reffile_index].objid);
     status = PDUget_context_from_refid(&(component_ids[reffile_index]), 
                                        &contextid);
     if (status != PDM_S_SUCCESS)
       return(TRUE);
     status = PDUconstruct_refid_string(&(component_ids[reffile_index]),
                                        &contextid, refid_string);
     _pdm_status("PDUconstruct_refid_string", status);

  /* update the attach flag for this GRpart */
  sprintf(attr_value, "%d", component_ids[reffile_index].objid);

   co$part_put_attr (
                      msg = &msg,
                      mod_env = to_env,
                      part = new_part_id,
                      attr = "attach_flag",
                      value = attr_value,
                      type = GR_DYNAMIC_ATTR);

     PDUmodify_exp(0, assy_dir, "refid", refid_string, to_env->md_id.osnum);

/* TR 139525192 - raj - 7/17/95 */
/* BEGIN fix. /////////////////////////////////////////////////////// */
     status = PDUupdate_local_flag_in_assembly(to_env);
     _pdm_status("PDUupdate_local_flag_in_assembly", status);

    if (assembly_buffer)
       {
       MEMclose(&assembly_buffer);
       assembly_buffer = NULL;
       }

    status = PDUload_assy_struct_buffer(to_env, &assembly_buffer, -1, assy_dir);
    _pdm_status("PDUload_assy_struct_buffer", status);

   status = PDUprocess_assembly_display(to_env, assembly_buffer, FALSE, TRUE,
            TRUE);
   _pdm_status("PDUprocess_assembly_display", status);

/* END fix. ///////////////////////////////////////////////////////// */

     if (dst_child_no)
            {
             free(dst_child_no);
             dst_child_no = NULL;
            }

    _pdm_debug("PDMpost_copy: Exit \n",0);
    dp$display(msg = &sts, oids = new_part_id, mode = GRbd);
    return(TRUE);
}

end implementation COpdu;
