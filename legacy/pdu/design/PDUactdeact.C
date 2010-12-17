/*****************************************************************

*	Modifications:						 *
*		a.  January 23, 1989 by Lynn Mettlen--changed	 *
*		    flag in ex$retrieve_module to EX_overwrite	 *
*		    from EX_read_write.				 *
*		b.  January 24, 1989 by Lynn Mettlen--deleted	 *
*		    ex$save_module in PDUint_checkin.		 *
*		c.  April 4, 1989 by Lynn Mettlen--added check   *
*		    on reference description to make sure there  *
*		    were at least 3 colons, which indicates file *
*		    is a PDM reference file. (PDUreport_attached *
*		d.  7/11/89 lmm close attach_list in act and deact  *
*		    						 *
*		e.  8/13/90 baw replaced string redisplay refresh*
*		    with command key				 *
*****************************************************************/
#include	<string.h>
#include	<PDUint.h>
#include	<PDUstr.h>
#include	<PDUintdef.h>
#include	<exdef.h>
#include	<exmacros.h>
#include	<msdef.h>
#include	<dpmacros.h>
#include	<dp.h>
#include	<dpdef.h>
#include	<igrdef.h>
#include	<part_gadgets.h>
#include        <PDUforms.h>
#include        <PDUfile_def.h>
#include        "godef.h"
#include        "igrdp.h"
#include        "grdpbmacros.h"
#include        "OMindex.h"
#include        "igetypedef.h"
#include        "igrtypedef.h"
#include        "gr.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIprims.h"
#include        "DIglob.h"
#include        "OMminimum.h"
#include        "grdpbdef.h"
#include        "PDUqueue.h"
#include        "PDUpart.h"
#include        "PDUgrpart.h"
#include        "PDUproto.h"
#include        "PDMproto.h"
#include        "PDUstorage.h"
#include        "errno.h"
#include        "sys/types.h"
#include        "sys/stat.h"
#include        "PDUuser.h"
#include        "PDUprompt.h"
#include	"PDUerror.h"



extern IGRchar	PDU_last_file [];
extern struct PDUrefresh	*refresh; 
extern struct PDUpart   	*part; 
extern struct PDUforms   	forms; 
extern struct PDUpart_node      *PDU_parts_id_list;
extern int    PDU_refresh_gadgets[7];
extern int    PDU_local_files_displayed;
extern short PDU_design_perm_window;
extern short PDU_local_perm_window;
extern short PDU_perm_window;
extern short PDU_design_form_display;
extern short PDU_active_part;
extern MEMptr PDU_detach_buffer;
extern MEMptr PDU_attach_buffer;
extern MEMptr PDU_detach_macro_lib;
extern MEMptr PDUmacro_lib_list;
extern Form   PDU_form_id;
extern struct PDUstorage        *storage;
extern struct PDUattach_mac_node *PDU_attach_macro_lib;


/* Global queue variables */
struct   PDUqueue_info  *PDU_queue_info;
extern IGRchar *PDU_save;
extern IGRchar *PDU_delete_checkin;


IGRint	PDUactivate ()
  {
  IGRint	status;
  IGRint        stat;
  IGRint        bufsiz;
  IGRint        msg;
  IGRint        responses[5];
  IGRchar       *strings [5];
  IGRchar       active_filename[DI_PATH_MAX];
  IGRchar       answer[10];
  IGRchar       output_var[100];
  IGRchar       tmp_filename[15];
  IGRchar       *prompt_msg = NULL;
  IGRchar       *save_filename = NULL;
  IGRshort      read_only = FALSE;
  struct        GRmd_env mod_env;
  extern        int PDU_command;
  extern        short PDU_edit_display;

  _pdm_debug("In the function PDUactivate", 0);

  /* Display command name */
  PDUmessage(PDC_M_ACTIVATE_PART, 'c');
  refresh->command = PDC_M_ACTIVATE_PART;
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  if (forms.local_files_form_id)
    FIf_erase(forms.local_files_form_id);

  bufsiz = sizeof(mod_env);
  gr$get_module_env(msg = &msg, sizbuf = bufsiz, buffer = &mod_env);
  di$give_pathname(osnum = mod_env.md_id.osnum,
                   pathname = active_filename);
  _pdm_debug("active_filename = <%s>", active_filename);

  _pdm_debug("checking to see if active file is read-only", 0);
  strcpy(tmp_filename, active_filename + 1);
  PDUfill_in_string(&save_filename, refresh->act_filename);
  PDUfill_in_string(&refresh->act_filename, tmp_filename);
  _pdm_debug("refresh->act_filename = <%s>", refresh->act_filename);

  status = PDUcheck_file_permissions();
  _pdm_status("PDUcheck_file_permissions", status);
  if (!status)
    {
    _pdm_debug("file is read-only; do not prompt to save", 0);
    read_only = TRUE;
    }
  _pdm_debug("resetting refresh->act_filename to <%s>", save_filename);
  PDUfill_in_string(&refresh->act_filename, save_filename);
  if (save_filename)
    free(save_filename);

  if ((strncmp(active_filename, ":PduDummyFile",9) != 0) && (!read_only))
  {
  strcpy(output_var, active_filename);
  prompt_msg = (char *)PDUtranslate_message_and_vars(PDP_P_SAVE_FILE,
                   output_var);
  UI_prompt(prompt_msg);
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
   if (strcmp(answer, "") == 0)
     PDUfill_in_string(&PDU_save, "n");
   else
     PDUfill_in_string(&PDU_save, answer);
   }
 else
   {
   PDUfill_in_string(&PDU_save, "n");
   }

  if ((strncmp(active_filename, ":PduDummyFile",9) != 0) && (!read_only))
  {
  if (prompt_msg)
    {
    free(prompt_msg);
    prompt_msg = NULL;
    }
  if ((strcmp(PDU_save, "y") == 0) || (strcmp(PDU_save, "Y") == 0))
    {
    strcpy(output_var, active_filename);
    prompt_msg = (char *)PDUtranslate_message_and_vars(PDP_P_CHECKIN_PART,
                     output_var);
    }
  else
    {
    prompt_msg = (char *)PDUtranslate_message(PDP_P_DELETE_LOCAL);
    }
  UI_prompt(prompt_msg);
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
   if (strcmp(answer, "") == 0)
     PDUfill_in_string(&PDU_delete_checkin, "n");
   else
     PDUfill_in_string(&PDU_delete_checkin, answer);
   }
 else
   {
   PDUfill_in_string(&PDU_delete_checkin, "n");
   }

  _pdm_debug("PDU_delete_checkin = <%s>", PDU_delete_checkin);
 /* see if review refresh file exists on local disk */
 if ((strcmp(refresh->rev_parttype, "M") == 0) || 
     (strcmp(refresh->rev_parttype, "m") == 0))
   {
   status = PDM_I_RET_FILE_MACRO;
   PDUmessage(status, 's');
   FIf_display(forms.local_files_form_id);
   return(status);
   }

  status = PDUverify_file( refresh->rev_filename );
  _pdm_status("PDUverify_file", status);

  if ( status != PDM_E_FILE_NULL )
    {
    _pdm_debug("activating file %s", refresh->rev_filename);

    if ( status == PDM_E_FILE_NOT_FOUND )
      {
      _pdm_debug("Case 1", 0);

     /* Case 1 designates the fact that the file being activated
        does not exist locally.  */

     /* Call a PDM function to see if the file is checked in. */
     stat = PDMcheck_if_checkedin(
                                  refresh->rev_catalog,
                                  refresh->rev_partid,
                                  refresh->rev_revision
                                 );

    _pdm_debug("Status is %d", (char *)stat);

    if ((stat == PDM_E_NOTCHECK_IN) || (stat == PDM_S_SUCCESS) ||
       (stat == PDM_E_PART_CHECKED_OUT) || (stat == PDM_E_ASSEMBLY_CHECKED_OUT))
      {
       _pdm_debug("New part being activated", 0);
       PDUmessage(PDM_I_CREATING_NEW_FILE, 's');
      }

    else
      {
      PDUmessage(stat, 's');
      _pdm_debug("Part can not be activated", 0);
      FIf_display(forms.local_files_form_id);
      return (stat);
      } 

    /* call seed file form */
    status = PDUseed_form();
    _pdm_status("PDUseed_form", status);

    return(status);
     }

    else
      {
      _pdm_debug("Case 2", 0);

      status = PDUcheck_if_graphic(refresh->rev_filename);
      _pdm_status("PDUcheck_if_graphic", status);

      if (status != PDM_S_SUCCESS)
        {
        status = PDM_I_RET_FILE_ASCII;
        FIf_display(forms.local_files_form_id);
        PDUmessage(status, 's');
        return(status);
        }

      _pdm_debug("Initializing global buffers to NULL", 0);
      if (PDU_detach_buffer)
        {
         status = MEMclose(&PDU_detach_buffer);
         PDU_detach_buffer = NULL;
        }

      if (PDU_attach_buffer)
        {
         MEMclose(&PDU_attach_buffer);
         PDU_attach_buffer = NULL;
        }

      /* Free up PDU_attach_macro_lib */
      if (PDU_attach_macro_lib)
         PDUfree_attach_mac_list();

      /* Free up PDU_detach_macro_lib */
      if (PDU_detach_macro_lib)
        {
         MEMclose(&PDU_detach_macro_lib);
         PDU_detach_macro_lib = NULL;
        }

      /* Initialize PDU_parts_id_list */
      PDU_parts_id_list = NULL;
      if ((PDU_edit_display) && (PDU_command != PDC_M_CHECKOUT_ACTIVATE))
      {
      responses[0] = EX_CMD_KEY;
      responses[1] = STRING;
      responses[2] = STRING;
      responses[3] = STRING;
      responses[4] = EX_CMD_KEY;

      strings[0] = "PDMnDp";
      strings[1] = refresh->rev_filename;
      strings[2] = PDU_delete_checkin;
      strings[3] = PDU_save;
      strings[4] = "EXRtFl";

      status = PDUprepare_queue ( responses, strings, 5 );
      PDU_command = PDC_M_ACTIVATE_PART;
      }
      else
      {
      responses[0] = STRING;
      responses[1] = STRING;
      responses[2] = STRING;
      responses[3] = EX_CMD_KEY;

      strings[0] = refresh->rev_filename;
      strings[1] = PDU_delete_checkin;
      strings[2] = PDU_save;
      strings[3] = "EXRtFl";

      status = PDUprepare_queue ( responses, strings, 4 );
      PDU_command = PDC_M_ACTIVATE_PART;
      }

     }

  PDU_active_part = TRUE;
  PDU_design_form_display = FALSE;
  status = PDM_S_SUCCESS;
  }
  else
  {
  _pdm_debug("No file assosciated with this part", 0);
   FIf_display(forms.local_files_form_id);
  PDUmessage(PDM_E_NO_PART_FILES, 's');
  }

  return (status);
  }

IGRint PDUcheck_os_tag_count()
  {
   IGRint       status;
   OMuword      osnum;
   OM_S_OBJID   osid;
   int          found = 0;

   _pdm_debug("In the function PDUcheck_os_tag_count", 0);

   /* get active module info */
    status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
    _pdm_status ("ex$get_cur_mod", status); 

   /* check to see if tag count directory exists in active module */
    _pdm_debug("check tag count dir",0);
    status = PDUcheck_tag_count(osnum,&found);
    _pdm_status ("PDUcheck_tag_count",status);
       if (status != PDM_S_SUCCESS)
          { _pdm_debug("unsuccessful tag count check",0);  
            return(status);
          }

    if (found)
       _pdm_debug("tag count was found",0);

    if (!found) 
       _pdm_debug("tag count was NOT found",0);

   return (status);
  }


IGRint PDUcheck_os_tag_count_for_create_graphics(osnum)
  OMuword	osnum;
  {
   IGRint       status;
   IGRint       found = 0;

   _pdm_debug("In the function PDUcheck_os_tag_count_for_create_graphics", 0);

   /* check to see if tag count directory exists in active module */
    _pdm_debug("check tag count dir",0);
    status = PDUcheck_tag_count(osnum,&found);
    _pdm_status ("PDUcheck_tag_count",status);
       if (status != PDM_S_SUCCESS)
          { _pdm_debug("unsuccessful tag count check",0);  
            return(status);
          }

    if (found)
       _pdm_debug("tag count was found",0);

    if (!found) 
       _pdm_debug("tag count was NOT found",0);

   return (status);
  }


IGRint	PDUdeactivate ()
  {
  IGRint        status;
  IGRlong	sts1 = MSSUCC;
  extern IGRchar *PDU_save;
  MEMptr        status_buffer = NULL;
  MEMptr        attach_info_bufr = NULL;
  struct        GRmd_env  mod_env;
  IGRlong       NumberOfBytes, BytesReceived;
  struct PDUpart_node      *head = NULL;
  MEMptr        local_files = NULL;
  struct        PDUattach_mac_node *head1;
  struct        GRmd_env  my_env;
  extern        struct PDUuser  *user;
  IGRint        responses[4];
  IGRchar       *strings [4];
  char          *msg = NULL;


  _pdm_debug("In the function PDUdeactivate_part", 0);

  /* Display command name */
  PDUmessage(PDC_M_DEACTIVATE_PART, 'c');

     if ((strcmp(PDU_save, "n")== 0) || (strcmp(PDU_save, "N")==0))
        {
         _pdm_debug("User said no to save",0);
         FIf_erase(forms.design_form_id);

         if (PDU_detach_buffer)
            {
             status = PDMrcopy_attach(PDU_detach_buffer, &status_buffer);
             _pdm_status("PDMrcopy_attach", status);

             MEMclose(&PDU_detach_buffer);
             PDU_detach_buffer = NULL;
            }

        if (PDU_attach_buffer)
           {
            status = PDMdetach_part(PDU_attach_buffer);
            if (PDU_attach_buffer)
              {
               MEMclose(&PDU_attach_buffer);
               PDU_attach_buffer = NULL;
              }
           }

         if (PDU_detach_macro_lib)
            {
             status = PDMcopy_macro_library(
                                            storage->storage_name, 
                                            PDU_detach_macro_lib, &status_buffer
                                           );
             _pdm_status("PDMcopy_macro_library", status);

             if (status != PDM_S_SUCCESS)
                {
                 _pdm_debug("PDMcopy_macro_library failed", 0);

                 MEMclose(&PDU_detach_macro_lib);
                 PDU_detach_macro_lib = NULL;

                 msg = (char *)PDUtranslate_message(PDM_E_FAILED_RESTORE_MACRO);
                 UI_status(msg);

                 return(status);
                }

             MEMclose(&PDU_detach_macro_lib);
             PDU_detach_macro_lib = NULL;
            }

         if (PDU_attach_macro_lib)
            {
             /* Get module info */
             get_mod_info( &my_env );

             head1 = PDU_attach_macro_lib;

             while (head1)
                   {
                    
                    msg = (char *)PDUtranslate_message(PDM_I_DELETE_MACRO_LIB);
                    UI_status(msg);

                    /* Detach macro libraries for this session */
                    status = PDMdetach_macro_library(
                                                     head1->part_cat,
                                                     head1->cat_list,
                                                     &local_files
                                                    );
                    _pdm_status("PDMdetach_macro_library", status);

                    if (status != PDM_S_SUCCESS)
                       {
                        _pdm_debug("PDMdetach_macro_library failed on <%s>",
                                   head1->part_cat);

                        /* Process next node */
                        head1 = head1->next;
                        continue;
                       }

                    if (local_files)
                       {
                        msg = (char *)PDUtranslate_message(PDM_I_DELETE_MACRO_LIB);
                        UI_status(msg);

                        /* Delete local macro libraries */
                        status = PDUremove_local_files_after_delete(
                                                                    local_files
                                                                   );
                        _pdm_debug("PDUremove_local_files_after_delete",status);
                       } 
                   
                    /* Process next node */
                    head1 = head1->next;

                   } /* end while loop */

              /* Free variables */
              if (local_files)
                 MEMclose(&local_files);

              /* Free up PDU_attach_macro_lib */
              PDUfree_attach_mac_list();
            }
        }

     else
         {
          /* Update attach info */
          status = PDUcreate_attach_info_buffer(&attach_info_bufr);
          _pdm_status("PDUcreate_attach_info_buffer", status);

          if (status == PDM_S_SUCCESS)
             {
              /* Get active module information */
              NumberOfBytes = sizeof(mod_env);
              status = gr$get_module_env(
                                         msg = &sts1,
                                         sizbuf = &NumberOfBytes,
                                         buffer = &mod_env,
                                         nret = &BytesReceived
                                        );

              /* Update obj space attach info */
              status = PDUupdate_attach_info(mod_env, attach_info_bufr);
              _pdm_status("PDUupdate_attach_info", status);
             }

          /* Close attach_info_bufr buffer */
          if (attach_info_bufr)
             MEMclose(&attach_info_bufr);
         }

      if (PDU_detach_buffer)
         {
          MEMclose(&PDU_detach_buffer);
          PDU_detach_buffer = NULL;
         }

       if (PDU_attach_buffer)
          {
           MEMclose(&PDU_attach_buffer);
           PDU_attach_buffer = NULL;
          }

     if (PDU_detach_macro_lib)
        {
         /* close buffer */
         MEMclose(&PDU_detach_macro_lib);
         PDU_detach_macro_lib = NULL;
        }

     if (PDU_attach_macro_lib)
        PDUfree_attach_mac_list();

     /* reset the gadget labels on the local files form */
     PDU_refresh_gadgets[0] = PROJECT_FLD;
     PDU_refresh_gadgets[1] = CATALOG_FLD;
     PDU_refresh_gadgets[2] = PARTNUM_FLD;
     PDU_refresh_gadgets[3] = PART_REV_FLD;
     PDU_refresh_gadgets[5] = PART_DESC_FLD;

     /* copy active refresh fields to review refresh fields */
     PDUfill_in_string( &refresh->rev_catalog, refresh->act_catalog );
     PDUfill_in_string( &refresh->rev_partid, refresh->act_partid );
     PDUfill_in_string( &refresh->rev_parttype, refresh->act_parttype );
     PDUfill_in_string( &refresh->rev_revision, refresh->act_revision );
     PDUfill_in_string( &refresh->rev_filename, refresh->act_filename );
     PDUfill_in_string( &refresh->rev_description, refresh->act_description);

     /* clear active refresh fields */
     MEMclose( &part->attach_list );
     PDUfill_in_string ( &refresh->act_catalog, NULL );
     PDUfill_in_string ( &refresh->act_partid, NULL );
     PDUfill_in_string ( &refresh->act_parttype, NULL );
     PDUfill_in_string ( &refresh->act_revision, NULL );
     PDUfill_in_string ( &refresh->act_filename, NULL );
     PDUfill_in_string ( &refresh->act_description, NULL );

     /* see if previous active file exists on local disk */
     status = PDUverify_file( PDU_last_file );
     _pdm_status("PDUverify_file", status);

     /* Skip retrieve if command is log out */
     if ( refresh->command == PDC_M_LOGOUT)
         return(PDM_S_SUCCESS);

     if ( status == PDM_S_SUCCESS )
	{
	 _pdm_debug("loading previous file: %s", PDU_last_file);

         /* Free PDU_parts_id_list */
         if (PDU_parts_id_list)
            {
             head = PDU_parts_id_list;

             while (PDU_parts_id_list)
                   {
                    PDU_parts_id_list = PDU_parts_id_list->next;
                    free(head);
                    head = PDU_parts_id_list;
                   } /* end while loop */

              PDU_parts_id_list = NULL;
             }

          /* erase design form */
          FIf_delete(forms.design_form_id);
          forms.design_form_id = 0;
          PDU_design_perm_window = FALSE;
          PDU_perm_window = FALSE;

          responses[0] = STRING;
          responses[1] = STRING;
          responses[2] = EX_CMD_KEY;

          strings[0] = PDU_last_file;
          strings[1] = PDU_save;
          strings[2] = "EXRtFl";
          PDUprepare_queue(responses, strings, 3);
          status = PDM_S_SUCCESS;
          if ( (strcmp(PDU_save, "Y") == 0) || (strcmp(PDU_save, "y") == 0) )
             {
             if (PDUis_PDU_design_file(&mod_env))
              {
              /* Load exec structure */
              PDUload_exec_structure(
                                     "",
                                     refresh->rev_catalog,
                                     refresh->rev_partid,
                                     refresh->rev_revision,
                                     "",
                                     "",
                                     "",
                                     0,
                                     0
                                    );

              /* Update "update os flag" */
              PDMset_update_os_flag("P");
              }
             }

       }

     else

	{
        /* Free PDU_parts_id_list */
        if (PDU_parts_id_list)
           {
            head = PDU_parts_id_list;

            while (PDU_parts_id_list)
                  {
                   PDU_parts_id_list = PDU_parts_id_list->next;
                   free(head);
                   head = PDU_parts_id_list;
                  } /* end while loop */

            PDU_parts_id_list = NULL;
           }

        /* erase design form */
        FIf_delete(forms.design_form_id);
        forms.design_form_id = 0;
        PDU_design_perm_window = FALSE;
        PDU_perm_window = FALSE;

        responses[0] = STRING;
        responses[1] = STRING;
        responses[2] = STRING;
        responses[3] = EX_CMD_KEY;

        strings[0] = "y";
        strings[1] = PDU_last_file;
        strings[2] = PDU_save;
        strings[3] = "EXRtFl";
        PDUprepare_queue(responses, strings, 4);
        status = PDM_S_SUCCESS;
      if ( (strcmp(PDU_save, "Y") == 0) || (strcmp(PDU_save, "y") == 0) )
         {
          /* Load exec structure */
          PDUload_exec_structure(
                                 "",
                                 refresh->rev_catalog,
                                 refresh->rev_partid,
                                 refresh->rev_revision,
                                 "",
                                 "",
                                 "",
                                 0,
                                 0
                                );

        /* Update "update os flag" */
        PDMset_update_os_flag("P");
       }
 
    }

   if (PDUmacro_lib_list)
      MEMclose(&PDUmacro_lib_list);

   PDU_active_part = FALSE;
  PDU_design_form_display = FALSE;
   return ( status );
  }

IGRint	PDUprepare_queue (responses, commands, count)
  IGRint	*responses;
  IGRchar	**commands;
  IGRint	count;
  {
  IGRint        status = PDM_S_SUCCESS, i;
  IGRint	response; 
  IGRlong       byte_count;
  IGRchar       *command = NULL;
  IGRlong	msg_stat;

  _pdm_debug("In the function PDUprepare_queue, with %d queue entries", (char *)count );

  for ( i = 0; i < count; ++i )
     {
     command = commands[i];
     response = responses[i];
     byte_count = strlen( command ) + 1;

     /* put an entry at the front of the queue */
     status = ex$putque ( msg = &msg_stat,
			  response = &response,
			  pos = FRONT,
			  byte = &byte_count,
			  buffer = command );
     _pdm_status2 ("ex$putque", status, msg_stat);
     }

  _pdm_debug ("%d items added to software queue", (char *)i);

  if ( 1&status )
     status = PDM_S_SUCCESS;
  else
     status = PDM_E_QUEUE_FAILED;

  return ( status );
  }

/*
 * This function puts events on the queue.
 */
IGRint  PDUput_queue(
                     mode,            /* mode of adding to queue */
                     cmd,             /* command string */
                     cmd_key,         /* command key */
                     string,          /* string input */
                     point,           /* data point */
                     response,        /* response type */
                     obj,             /* object id */
                     value,           /* numeric input */
                     osnum,           /* object space number */
                     pos              /* queue position */
                    )

  IGRint        mode;
  IGRchar       *cmd;
  IGRchar       *cmd_key;
  IGRchar       *string;
  IGRdouble     point[3];
  IGRint        *response;
  GRobjid       *obj;
  IGRdouble     *value;
  OMuword       *osnum;
  IGRint        *pos;
  {
   IGRlong      status = PDM_S_SUCCESS;
   IGRint       responses[1];
   IGRchar      *strings [1];
   struct       PDUqueue_info *temp = NULL;

    _pdm_debug("In PDUput_queue function", 0);

    switch (mode)
         {
          case 0:
                 /* Put command string on the queue */

                 /* Create a node with queue info */
                 temp = (struct PDUqueue_info *)
                        malloc(sizeof(struct PDUqueue_info));

                 /* Initialize temp fields */
                 temp->mode = mode;
                 temp->cmd = NULL;
                 temp->cmd_key = NULL;
                 temp->string = NULL;

                 PDUfill_in_string(&(temp->cmd), cmd);
                 
                 temp->point[0] = 0;
                 temp->point[1] = 0;
                 temp->point[2] = 0;

                 temp->response = 0;
                 temp->obj = 0;
                 temp->value = 0;
                 temp->osnum = 0;
                 temp->pos = *pos;

                 /* Add queue node to the top of PDU_queue_info */
                 temp->next = PDU_queue_info;
                 PDU_queue_info = temp;

                 /* Put put_queue command on the q */
                 responses[0] = EX_CMD_KEY;
                 strings[0] = "PDPuQu";

                 status = PDUprepare_queue ( responses, strings, 1 );
                 _pdm_status("PDUprepare_queue (case 0)", status);

                 break;

          case 1:
                 /* Put command key on the queue */

                 /* Create a node with queue info */
                 temp = (struct PDUqueue_info *)
                        malloc(sizeof(struct PDUqueue_info));

                 /* Initialize temp fields */
                 temp->mode = mode;
                 temp->cmd = NULL;
                 temp->cmd_key = NULL;
                 temp->string = NULL;

                 PDUfill_in_string(&(temp->cmd_key), cmd_key);

                 temp->point[0] = 0;
                 temp->point[1] = 0;
                 temp->point[2] = 0;

                 temp->response = 0;
                 temp->obj = 0;
                 temp->value = 0;
                 temp->osnum = 0;
                 temp->pos = *pos;

                 /* Add queue node to the top of PDU_queue_info */
                 temp->next = PDU_queue_info;
                 PDU_queue_info = temp;

                 /* Put put_queue command on the q */
                 responses[0] = EX_CMD_KEY;
                 strings[0] = "PDPuQu";

                 status = PDUprepare_queue ( responses, strings, 1 );
                 _pdm_status("PDUprepare_queue (case 1)", status);

                 break;

          case 2:
                 /* Put object id on the queue */

                 /* Create a node with queue info */
                 temp = (struct PDUqueue_info *)
                        malloc(sizeof(struct PDUqueue_info));

                 /* Initialize temp fields */
                 temp->mode = mode;
                 temp->cmd = NULL;
                 temp->cmd_key = NULL;
                 temp->string = NULL;

                 temp->point[0] = 0;
                 temp->point[1] = 0;
                 temp->point[2] = 0;

                 temp->response = 0;
                 temp->obj = *obj;
                 temp->value = 0;
                 temp->osnum = 0;
                 temp->pos = *pos;

                 /* Add queue node to the top of PDU_queue_info */
                 temp->next = PDU_queue_info;
                 PDU_queue_info = temp;

                 /* Put put_queue command on the q */
                 responses[0] = EX_CMD_KEY;
                 strings[0] = "PDPuQu";

                 status = PDUprepare_queue ( responses, strings, 1 );
                 _pdm_status("PDUprepare_queue (case 2)", status);

                 break;

          case 3:
                 /* Put response on the queue */

                 /* Create a node with queue info */
                 temp = (struct PDUqueue_info *)
                        malloc(sizeof(struct PDUqueue_info));

                 /* Initialize temp fields */
                 temp->mode = mode;
                 temp->cmd = NULL;
                 temp->cmd_key = NULL;
                 temp->string = NULL;

                 temp->point[0] = 0;
                 temp->point[1] = 0;
                 temp->point[2] = 0;

                 temp->response = *response;
                 temp->obj = 0;
                 temp->value = 0;
                 temp->osnum = 0;
                 temp->pos = *pos;

                 /* Add queue node to the top of PDU_queue_info */
                 temp->next = PDU_queue_info;
                 PDU_queue_info = temp;

                 /* Put put_queue command on the q */
                 responses[0] = EX_CMD_KEY;
                 strings[0] = "PDPuQu";

                 status = PDUprepare_queue ( responses, strings, 1 );
                 _pdm_status("PDUprepare_queue (case 3)", status);

                 break;

          case 4:

                 /* Put data point on the queue */

                 /* Create a node with queue info */
                 temp = (struct PDUqueue_info *)
                        malloc(sizeof(struct PDUqueue_info));

                 /* Initialize temp fields */
                 temp->mode = mode;
                 temp->cmd = NULL;
                 temp->cmd_key = NULL;
                 temp->string = string;

                 temp->point[0] = 0;
                 temp->point[1] = 0;
                 temp->point[2] = 0;

                 temp->response = *response;
                 temp->obj = 0;
                 temp->value = 0;
                 temp->osnum = 0;
                 temp->pos = *pos;

                 /* Add queue node to the top of PDU_queue_info */
                 temp->next = PDU_queue_info;
                 PDU_queue_info = temp;

                 /* Put put_queue command on the q */
                 responses[0] = EX_CMD_KEY;
                 strings[0] = "PDPuQu";

                 status = PDUprepare_queue ( responses, strings, 1 );
                 _pdm_status("PDUprepare_queue (case 4)", status);

                 break;

          default:
                  break;

         } /* end switch */

   return ( status );
  }

IGRint        PDUfinish_activate ()
   {
   IGRint        status;
   IGRint        responses[5];
   IGRchar       *strings [5];
   extern        int PDU_command;

   _pdm_debug("In the function PDUfinish_activate", 0);

   /* Display command name */
   PDUmessage(PDC_M_ACTIVATE_PART, 'c');
   PDU_command = PDC_M_ACTIVATE_PART;

   status = PDUverify_file(refresh->rev_filename);
   _pdm_status("PDUverify_file", status);

   if (status != PDM_S_SUCCESS)
    {
    /* Initialize PDU_parts_id_list */
    PDU_parts_id_list = NULL;

    responses[0] = STRING;
    responses[1] = STRING;
    responses[2] = STRING;
    responses[3] = STRING;
    responses[4] = EX_CMD_KEY;

    strings[0] = "y";
    strings[1] = refresh->rev_filename;
    strings[2] = PDU_delete_checkin;
    strings[3] = PDU_save;
    strings[4] = "EXRtFl";
    status = PDUprepare_queue(responses, strings, 5);
    _pdm_status("PDUprepare_queue", status);
    status = PDM_S_SUCCESS;
   }
   else
   {
    
    /* Initialize PDU_parts_id_list */
    PDU_parts_id_list = NULL;

    responses[0] = STRING;
    responses[1] = STRING;
    responses[2] = STRING;
    responses[3] = EX_CMD_KEY;

    strings[0] = refresh->rev_filename;
    strings[1] = PDU_delete_checkin;
    strings[2] = PDU_save;
    strings[3] = "EXRtFl";
    PDUprepare_queue(responses, strings, 4);

    status = PDM_S_SUCCESS;
    /* Display design form */
   }

    if (status == PDM_S_SUCCESS)
      {
      _pdm_debug("Initializing global buffers to NULL", 0);
      if (PDU_detach_buffer)
        {
         MEMclose(&PDU_detach_buffer);
         PDU_detach_buffer = NULL;
        }

      if (PDU_attach_buffer)
        {
         MEMclose(&PDU_attach_buffer);
         PDU_attach_buffer = NULL;
        }

       /* Free up PDU_detach_macro_lib */
       if (PDU_detach_macro_lib)
         {
          MEMclose(&PDU_detach_macro_lib);
          PDU_detach_macro_lib = NULL;
         }

       /* Free up PDU_attach_macro_lib */
       if (PDU_attach_macro_lib)
          PDUfree_attach_mac_list();
       }

    PDU_active_part = TRUE;
    PDU_command = PDC_M_ACTIVATE_PART;
   PDU_design_form_display = FALSE;
    return (status);
   }

IGRint PDUfree_attach_mac_list()
 {
  struct        PDUattach_mac_node *head = NULL;
  struct        PDUcat_node        *head1 = NULL;
  IGRint        status = PDM_S_SUCCESS;

  _pdm_debug("In the PDUfree_attach_mac_list function", 0);

  if (PDU_attach_macro_lib)
     {
      head = PDU_attach_macro_lib;

      while (PDU_attach_macro_lib)
            {
             PDU_attach_macro_lib = PDU_attach_macro_lib->next;

             if (head->part_cat)
                free(head->part_cat);

             if (head->cat_list)
                {
                 head1 = head->cat_list;

                 while (head->cat_list)
                       {
                        head->cat_list = (head->cat_list)->next;
                        if (head1->catalog)
                           free(head1->catalog);

                        free(head1);
                        head1 = head->cat_list;
                       }
                 }

             free(head);
             head = PDU_attach_macro_lib;
            } /* end while loop */

      PDU_attach_macro_lib = NULL;
     }

  return(status);
 }


/*
 * This function changes the permissions of the design file retrieved for
 * review.
 */
IGRint PDUchange_review_file_permissions(
                                         file,
                                         flag
                                        )
 IGRchar          *file;
 IGRshort         flag;
 {
  IGRint         status = PDM_S_SUCCESS;
  struct stat    file_status;
  mode_t         mode;
  IGRchar        full_path[1023];
  IGRchar        *cwd = NULL;

  extern mode_t  PDU_review_file_permissions;
  extern IGRchar PDU_review_file[80];

  _pdm_debug("In the PDUchange_review_file_permissions function", 0);

  if (file == NULL)
    return(PDM_S_SUCCESS);
  else if (strcmp(file, "") == 0)
    return(PDM_S_SUCCESS);

  /* Get woking directory path */
  cwd = PDUgetcwd((char *)NULL, 64);

  if ( (!cwd) || (strcmp(cwd,"") ==0) )
     return(PDM_E_WRKST_CWD);

  /* Check if need to restore review file permissions */
  if (flag)
     {
      /* Construct file full path */
      full_path[0] = '\0';
      strcpy(full_path, cwd);
      strcat(full_path, "/");
      strcat(full_path, PDU_review_file);

      _pdm_debug("restoring permissions on <%s>", full_path);

      /* Get current file permissions */
      status = stat(full_path, &file_status );
      _pdm_status("stat", status);

      if (status == -1)
         {
          _pdm_debug("file <%s> does not exist", full_path);
          return(PDM_S_SUCCESS);
         }

      mode = PDU_review_file_permissions;

      /* Change file permissions */
      status = PDUchmod(full_path, mode);
      _pdm_status("PDUchmod", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUchmod failed", 0);
          return(status);
         }

      /* Reset flag values */
      PDU_review_file_permissions = 0;
      PDU_review_file[0] = '\0';

      return(status);
     }

  /* Construct file full path */
  full_path[0] = '\0';
  strcpy(full_path, cwd);
  strcat(full_path, "/");
  strcat(full_path, file);

  _pdm_debug("file full path = <%s>", full_path);

  /* Get current file permissions */
  status = stat(full_path, &file_status );
  _pdm_status("stat", status);
 
  if (status == -1)
     {
      _pdm_debug("file <%s> does not exist", full_path);
      return(PDM_S_SUCCESS);
     }

  /* Save file current permissions */
  PDU_review_file_permissions = file_status.st_mode;
  strcpy(PDU_review_file, file);

  /* Change file permissions to read only */
  mode = S_IRUSR | S_IRGRP | S_IROTH;
 
  /* Change file permissions */
  status = PDUchmod(full_path, mode);
  _pdm_status("PDUchmod", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUchmod failed", 0);
      return(status);
     } 

  return(status);
 }
