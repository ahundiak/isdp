class implementation PDUasmmgr;

/*
 * Author Jamal Shakra - 10-9-93.
 */

#include "igrtypedef.h"
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "exmacros.h"
#include "OMtypes.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "PDUprompt.h"
#include "PDUstr.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "PDUprtdyn.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "PDUgrpart.h"
#include "PDUcommand.h"
#include "PDUuser.h"
#include "PDUfile_def.h"

/* External global variables */
extern struct PDUuser    *user;
%safe
static short post_db = FALSE;
%endsafe

extern int PDMdebug_on;

#if defined (i386) && defined (__Sol2__)
method global_class.sleep( IGRint temp_sleep )
#else
method sleep( IGRint temp_sleep )
#endif
  {
   IGRint              status = PDM_S_SUCCESS;
   IGRchar             *err;
   IGRchar             *msg = NULL;
   IGRchar             answer[10];
   IGRchar             output_var[100];
   IGRint              bufsiz;
   struct GRmd_env     mod_env;
   IGRchar             file_path[DI_PATH_MAX];
   IGRchar             *file_name = NULL;

   extern struct part_dynamic_attrs *part_occur_list;
   extern struct PDUrefresh         *refresh;
   extern int PDU_command;

   _pdm_debug("In the method sleep", 0);

   post_db = FALSE;
   if ( ex$is_invis( mod_osnum = OM_Gw_current_OS ) )
   return(1);

   if( temp_sleep )
     {
      /* Save command case */
      _pdm_debug("Save command case", 0);

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

      /* reset update os flag if necessary */
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

      /* Get current module info. */
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = &mod_env);

      /* Construct path to file name */
      di$give_pathname(
                       osnum = mod_env.md_id.osnum,
                       pathname = file_path
                      );

      file_name = file_path;
      file_name = ++file_name;

      /* Post to database, if desired */
      strcpy(output_var, "");
      strcpy(output_var, file_name);
      UI_echo("");
      msg = (char *)PDUtranslate_message_and_vars(PDP_P_POST_DB, output_var);

          UI_prompt(msg);
          do 
            {
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
            post_db = TRUE;
          else
            post_db = FALSE;
     }

   else
       {
        /* Exit case */
        _pdm_debug("Exit case", 0);

        /* Cleanup parent-child-list */
        PDUfree_refid_list();

        /* Clear house */
        if (part_occur_list)
           pdmfree_part_occurrence();

        if (PDU_command != 0)
           {
            _pdm_debug("NULLING out active part information", 0);

            /* Copy active part info to review part */
            if ((refresh->act_catalog) && 
                (strcmp(refresh->act_catalog, "") != 0))
             PDUfill_in_string(&refresh->rev_catalog, refresh->act_catalog);
            if ((refresh->act_partid) && (strcmp(refresh->act_partid, "") != 0))
              PDUfill_in_string(&refresh->rev_partid, refresh->act_partid);
            if ((refresh->act_parttype) && 
                (strcmp(refresh->act_parttype, "") != 0))
              PDUfill_in_string(&refresh->rev_parttype, refresh->act_parttype);
            if ((refresh->act_revision) && 
                (strcmp(refresh->act_revision, "") != 0))
              PDUfill_in_string(&refresh->rev_revision, refresh->act_revision);
            if ((refresh->act_filename) && 
                (strcmp(refresh->act_filename, "") != 0))
              PDUfill_in_string(&refresh->rev_filename, refresh->act_filename);
            if ((refresh->act_description) && 
                (strcmp(refresh->act_description, "") != 0))
              PDUfill_in_string(&refresh->rev_description,
                                refresh->act_description);

            /* Clear active part info */
            PDUfill_in_string (&refresh->act_catalog, "");
            PDUfill_in_string (&refresh->act_partid, "");
            PDUfill_in_string (&refresh->act_parttype, "");
            PDUfill_in_string (&refresh->act_revision, "");
            PDUfill_in_string (&refresh->act_filename, "");
            PDUfill_in_string (&refresh->act_description, "");

            /* Update active part info on design form */
            PDUupdate_active_part_info();
           }

       } /* end of exit case */

  return(1);
 }


method wake_up()
{
 IGRint                    status = PDM_S_SUCCESS;
 IGRchar                   *err;
 IGRchar             catalog[40];
 IGRchar             number[40];
 IGRchar             revision[40];
 IGRchar             *file_name = NULL;
 IGRint              bufsiz;
 struct GRmd_env     mod_env;
 IGRchar             file_path[DI_PATH_MAX];
 extern struct PDUrefresh *refresh;

 _pdm_debug("In the method wake_up", 0);

  /* Check to see if post to database */

  if (post_db)
    {
    post_db = FALSE;
    /* Check if user is logged in */
    if (PDUnullstr(user->username))
      return(1);

     status = PDM_S_SUCCESS;

     if (status == PDM_S_SUCCESS)
       { 
       status = PDUverify_part('a');
       _pdm_status("PDUverify_part", status);
       if (status != PDM_S_SUCCESS)
         {
         /* Get current module info. */
         bufsiz = sizeof(struct GRmd_env);
         gr$get_module_env(sizbuf = &bufsiz, buffer = &mod_env);

         /* Construct path to file name */
         di$give_pathname(
                         osnum = mod_env.md_id.osnum,
                         pathname = file_path
                         );

         file_name = file_path;
         file_name = ++file_name;

         /* Given filename, get part catalog, number,and revision. */
         status = PDMGetPartInfoGivenFileName(
                                              file_name,
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

           return(1);
           }

         /* Post to database */
         status = PDUpost_to_database(
                                      catalog,
                                      number, 
                                      revision,
                                      TRUE
                                     );
        _pdm_status("PDUpost_to_database", status);

        if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUpost_to_database failed", 0);

           PDUmessage_trans(status, 's');
           err = (IGRchar *)PDUtranslate_message(status);
           UI_error(err);

           return(1);
          }
        }
      else
        {
        /* Post to database */
        status = PDUpost_to_database(
                                     refresh->act_catalog,
                                     refresh->act_partid, 
                                     refresh->act_revision,
                                     TRUE
                                     );
        _pdm_status("PDUpost_to_database", status);

        if (status != PDM_S_SUCCESS)
          {
          _pdm_debug("PDUpost_to_database failed", 0);

          PDUmessage_trans(status, 's');
          err = (IGRchar *)PDUtranslate_message(status);
          UI_error(err);

          return(1);
          }
        }
      }
    }
 /*status = PDUdetect_assembly_change(NULL);
 _pdm_status("PDUdetect_assembly_change", status);

 if (status != PDM_S_SUCCESS)
    {
     _pdm_debug("PDUdetect_assembly_change failed", 0);
    
     err = (IGRchar *) PDUtranslate_message(PDM_E_UPON_EXIT);
     UI_error(err);

     return(1); 
    }*/

 /* Call PDU 2.0 object space convertor */
 status = PDUcvt_20objspace();
 _pdm_status("PDUcvt_20objspace", status);

 if (status != PDM_S_SUCCESS)
    {
     _pdm_debug("SEVERE error: PDUcvt_20objspace failed", 0);

     err = (IGRchar *) PDUtranslate_message(PDM_E_UPON_EXIT);
     UI_error(err);

     return(1);
    }
 _pdm_debug("leaving wake_up", 0);

 return(1);
}


/*
 * This function executes upon a save action (save/exit and save).
 */

IGRint PDUexecute_upon_save()
 {
  IGRint              status = PDM_S_SUCCESS;
  MEMptr              detach_buffer = NULL;
  IGRchar             *err = NULL;

  _pdm_debug("In the PDUexecute_upon_save function", 0);


  /* Mark parts for save */
  status = PDUflag_local_parts_for_save_in_assembly(NULL);
  _pdm_status("PDUflag_local_parts_for_save_in_assembly", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUflag_local_parts_for_save_in_assembly failed", 0);
      return(0);
     }

  /* Load detach buffer */
  status = PDUload_detach_buffer(
                                 NULL,
                                 -1,
                                 1,
                                 &detach_buffer
                                );
  _pdm_status("PDUload_detach_buffer", status);

  _pdm_debug("After PDUload_detach_buffer", 0);
  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUload_detach_buffer failed", 0);
      return(0);
     }

  /* Clean up local files, if necessary */
  if (detach_buffer)
     {
      if (detach_buffer->rows > 0)
         {
          /* Need to check if logged in */
          status  = PDUautomatic_login(FALSE);
          _pdm_status("PDUautomatic_login", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDUautomatic_login failed", 0);

              PDUmessage_trans(status, 's');
              err = (IGRchar *)PDUtranslate_message(status);
              UI_error(err);

              return(1);
             }

          status = PDMdetach_part(detach_buffer);
          _pdm_status("PDMdetach_part", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDMdetach_part failed", 0);
              return(0);
             }
         }
     }

  /* Delete parts marked for deletion */
  status = PDUdelete_flagged_parts_in_assembly(NULL);
  _pdm_status("PDUdelete_flagged_parts_in_assembly", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUdelete_flagged_parts_in_assembly failed", 0);
      return(0);
     }

  /* Free up variables */
  if (detach_buffer)
     MEMclose(&detach_buffer);

  return(PDM_S_SUCCESS);
 }

IGRint PDUcleanup_detached_parts_after_save()

  {
  IGRint              status = PDM_S_SUCCESS;
  IGRchar             *err = NULL;
  extern MEMptr       PDU_detach_buffer;

  _pdm_debug("PDUcleanup_detached_parts_after_save", 0);
  /* Clean up local files, if necessary */
  if (PDU_detach_buffer)
     {
      if (PDU_detach_buffer->rows > 0)
         {
          /* Need to check if logged in */
          status  = PDUautomatic_login(FALSE);
          _pdm_status("PDUautomatic_login", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDUautomatic_login failed", 0);

              PDUmessage_trans(status, 's');
              err = (IGRchar *)PDUtranslate_message(status);
              UI_error(err);

              return(1);
             }

          status = PDMdetach_part(PDU_detach_buffer);
          _pdm_status("PDMdetach_part", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDMdetach_part failed", 0);
              return(0);
             }
         }
     }
  return(PDM_S_SUCCESS);
  }

/*
 * This function executes upon a save action (save/exit and save).
 */

IGRint PDUexecute_upon_save_for_rev_assy(mod_env)
  struct GRmd_env *mod_env;
 {
  IGRint              status = PDM_S_SUCCESS;
  IGRint              msg;
  MEMptr              detach_buffer = NULL;
  IGRchar             *err = NULL;
  IGRlong             NumberOfBytes, BytesReceived;

  _pdm_debug("In the PDUexecute_upon_save_for_rev_assy function", 0);

  /* Mark parts for save */
  status = PDUflag_local_parts_for_save_in_assembly(mod_env);
  _pdm_status("PDUflag_local_parts_for_save_in_assembly", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUflag_local_parts_for_save_in_assembly failed", 0);
      return(0);
     }

  /* Load detach buffer */
  status = PDUload_detach_buffer(
                                 mod_env,
                                 -1,
                                 1,
                                 &detach_buffer
                                );
  _pdm_status("PDUload_detach_buffer", status);

  _pdm_debug("After PDUload_detach_buffer", 0);
  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUload_detach_buffer failed", 0);
      return(0);
     }

  /* Clean up local files, if necessary */
  if (detach_buffer)
     {
      if (detach_buffer->rows > 0)
         {
          /* Need to check if logged in */
          status  = PDUautomatic_login(FALSE);
          _pdm_status("PDUautomatic_login", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDUautomatic_login failed", 0);

              PDUmessage_trans(status, 's');
              err = (IGRchar *)PDUtranslate_message(status);
              UI_error(err);

              return(1);
             }

          status = PDMdetach_part(detach_buffer);
          _pdm_status("PDMdetach_part", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDMdetach_part failed", 0);
              return(0);
             }
         }
     }

  /* Delete parts marked for deletion */
  status = PDUdelete_flagged_parts_in_assembly(mod_env);
  _pdm_status("PDUdelete_flagged_parts_in_assembly", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUdelete_flagged_parts_in_assembly failed", 0);
      return(0);
     }

  /* Free up variables */
  if (detach_buffer)
     MEMclose(&detach_buffer);

  return(PDM_S_SUCCESS);
 }

IGRint PDUcleanup_detached_parts_after_save_for_rev_assy()

  {
  IGRint              status = PDM_S_SUCCESS;
  IGRchar             *err = NULL;
  extern MEMptr       PDU_detach_buffer;

  _pdm_debug("PDUcleanup_detached_parts_after_save_for_rev_assy", 0);
  /* Clean up local files, if necessary */
  if (PDU_detach_buffer)
     {
      if (PDU_detach_buffer->rows > 0)
         {
          /* Need to check if logged in */
          status  = PDUautomatic_login(FALSE);
          _pdm_status("PDUautomatic_login", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDUautomatic_login failed", 0);

              PDUmessage_trans(status, 's');
              err = (IGRchar *)PDUtranslate_message(status);
              UI_error(err);

              return(1);
             }

          status = PDMdetach_part(PDU_detach_buffer);
          _pdm_status("PDMdetach_part", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDMdetach_part failed", 0);
              return(0);
             }
         }
     }
  return(PDM_S_SUCCESS);
  }

end implementation PDUasmmgr;
